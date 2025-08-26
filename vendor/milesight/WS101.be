#
# LoRaWAN AI-Generated Decoder for Milesight WS101 Prompted by ZioFabry
#
# Generated: 2025-08-26 | Version: 2.0.0 | Revision: 1
#            by "LoRaWAN Decoder AI Generation Template", v2.3.6
#
# Homepage:  https://www.milesight.com/iot/product/lorawan-sensor/ws101
# Userguide: WS101_LoRaWAN_Smart_Button_UserGuide
# Decoder:   Official Milesight Decoder
# 
# v2.0.0 (2025-08-26): Framework v2.2.9 + Template v2.3.6 major upgrade with enhanced error handling
# v1.0.0 (2025-08-15): Smart button with multiple press types

class LwDecode_WS101
    var hashCheck      # Duplicate payload detection flag (true = skip duplicates)
    var name           # Device name from LoRaWAN
    var node           # Node identifier
    var last_data      # Cached decoded data
    var last_update    # Timestamp of last update
    var lwdecode       # global instance of the driver

    def init()
        self.hashCheck = true   # Enable duplicate detection by default
        self.name = nil
        self.node = nil
        self.last_data = {}
        self.last_update = 0
        
        # Initialize global node storage (survives decoder reload)
        import global
        if !global.contains("WS101_nodes")
            global.WS101_nodes = {}
        end
        if !global.contains("WS101_cmdInit")
            global.WS101_cmdInit = false
        end
    end
    
    def decodeUplink(name, node, rssi, fport, payload, simulated)
        import string
        import global
        var data = {}
        
        # Validate inputs
        if payload == nil || size(payload) < 1
            return nil
        end
        
        try
            # Store device info (Framework v2.2.9 compatibility)
            self.name = name
            self.node = node
            data['RSSI'] = rssi      # Framework v2.2.9 uses UPPERCASE
            data['FPort'] = fport    # Framework v2.2.9 uses UPPERCASE
            data['simulated'] = simulated  # Framework v2.2.9 passes simulated
            
            # Retrieve node history from global storage
            var node_data = global.WS101_nodes.find(node, {})
            
            if fport == 85  # Standard WS101 data port
                var i = 0
                while i < size(payload)
                    var channel_id = payload[i]
                    var channel_type = payload[i+1]
                    i += 2
                    
                    # Button event channels
                    if channel_id == 0xFF && channel_type == 0x2E  # Button Message
                        var button_mode = payload[i]
                        data['button_mode'] = button_mode
                        
                        if button_mode == 0x01
                            data['button_event'] = "Short Press"
                        elif button_mode == 0x02
                            data['button_event'] = "Long Press"
                        elif button_mode == 0x03
                            data['button_event'] = "Double Press"
                        else
                            data['button_event'] = f"Unknown Mode {button_mode}"
                        end
                        i += 1
                        
                    # Battery monitoring
                    elif channel_id == 0x01 && channel_type == 0x75  # Battery Level
                        data['battery_pct'] = payload[i]
                        data['battery_level'] = data['battery_pct']  # Alias for compatibility
                        i += 1
                        
                    # Device information channels
                    elif channel_id == 0xFF && channel_type == 0x01  # Protocol Version
                        data['protocol_version'] = payload[i]
                        if payload[i] == 0x01
                            data['protocol_name'] = "V1"
                        end
                        i += 1
                        
                    elif channel_id == 0xFF && channel_type == 0x08  # Device Serial Number
                        var serial = ""
                        for j: 0..(size(payload) - i - 1)
                            if j >= 6 break end
                            serial += f"{payload[i+j]:02X}"
                        end
                        data['serial_number'] = serial
                        i += 6
                        
                    elif channel_id == 0xFF && channel_type == 0x09  # Hardware Version
                        var hw_major = payload[i]
                        var hw_minor = payload[i+1]
                        data['hw_version'] = f"{hw_major}.{hw_minor}"
                        i += 2
                        
                    elif channel_id == 0xFF && channel_type == 0x0A  # Software Version
                        var sw_major = payload[i]
                        var sw_minor = payload[i+1]
                        data['sw_version'] = f"{sw_major}.{sw_minor}"
                        i += 2
                        
                    elif channel_id == 0xFF && channel_type == 0x0B  # Power On Event
                        data['power_on_event'] = true
                        # No additional bytes for this event
                        
                    elif channel_id == 0xFF && channel_type == 0x0F  # Device Class
                        var device_class = payload[i]
                        var classes = ["Class A", "Class B", "Class C"]
                        data['device_class'] = device_class < size(classes) ? classes[device_class] : f"Unknown({device_class})"
                        i += 1
                        
                    else
                        # Unknown channel - log and try to continue
                        print(f"WS101: Unknown channel ID={channel_id:02X} Type={channel_type:02X}")
                        break
                    end
                end
            end
            
            # Update node history in global storage
            node_data['last_data'] = data
            node_data['last_update'] = tasmota.rtc()['local']
            node_data['name'] = name
            
            # Track button press events
            if data.contains('button_event')
                var press_type = data['button_event']
                var press_key = f"{press_type}_count"
                node_data[press_key] = node_data.find(press_key, 0) + 1
                node_data['last_press_type'] = press_type
                node_data['last_press_time'] = tasmota.rtc()['local']
                node_data['total_presses'] = node_data.find('total_presses', 0) + 1
            end
            
            # Store battery trend if available
            if data.contains('battery_pct')
                if !node_data.contains('battery_history')
                    node_data['battery_history'] = []
                end
                node_data['battery_history'].push(data['battery_pct'])
                if size(node_data['battery_history']) > 10
                    node_data['battery_history'].pop(0)
                end
            end
            
            # Track power on events
            if data.contains('power_on_event') && data['power_on_event']
                node_data['power_on_count'] = node_data.find('power_on_count', 0) + 1
                node_data['last_power_on'] = tasmota.rtc()['local']
            end
            
            # Initialize downlink commands once
            if !global.contains("WS101_cmdInit") || !global.WS101_cmdInit
                self.register_downlink_commands()
                global.WS101_cmdInit = true
            end

            # Save back to global storage
            global.WS101_nodes[node] = node_data
            
            # Update instance cache
            self.last_data = data
            self.last_update = node_data['last_update']
            
            return data
            
        except .. as e, m
            print(f"WS101: Decode error - {e}: {m}")
            return nil
        end
    end
    
    def add_web_sensor()
        import global
        
        try
            # Try to use current instance data first
            var data_to_show = self.last_data
            var last_update = self.last_update
            
            # If no instance data, try to recover from global storage
            if size(data_to_show) == 0 && self.node != nil
                var node_data = global.WS101_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            # Fallback: find ANY stored node if no specific node
            if size(data_to_show) == 0 && size(global.WS101_nodes) > 0
                for node_id: global.WS101_nodes.keys()
                    var node_data = global.WS101_nodes[node_id]
                    data_to_show = node_data.find('last_data', {})
                    last_update = node_data.find('last_update', 0)
                    self.node = node_id  # Update instance
                    self.name = node_data.find('name', f"WS101-{node_id}")
                    break  # Use first found
                end
            end
            
            if size(data_to_show) == 0 return "" end
            
            import string
            var msg = ""
            var fmt = LwSensorFormatter_cls()
            
            # MANDATORY: Add header line with device info
            var name = self.name
            if name == nil || name == ""
                name = f"WS101-{self.node}"
            end
            var name_tooltip = "Milesight WS101 Smart Button"
            # Use battery percentage converted to voltage scale (for header display)
            var battery = data_to_show.find('battery_pct', 100)
            if battery < 100
                battery = 100000 + battery  # Convert to percentage format for header
            else
                battery = 1000  # Hide if no battery data
            end
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)
            var simulated = data_to_show.find('simulated', false)
            
            # Build display using emoji formatter
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            
            fmt.start_line()
            
            # Button event (main display)
            if data_to_show.contains('button_event')
                var button_event = data_to_show['button_event']
                var button_emoji = "🔘"
                
                if button_event == "Short Press"
                    button_emoji = "👆"
                elif button_event == "Long Press"
                    button_emoji = "👇"
                elif button_event == "Double Press"
                    button_emoji = "✌️"
                end
                
                fmt.add_status(button_event, button_emoji, f"Button: {button_event}")
            end
            
            # Battery percentage (if available and not in header)
            if data_to_show.contains('battery_pct') && battery >= 1000
                fmt.add_sensor("string", f"{data_to_show['battery_pct']}%", "Battery", "🔋")
            end
            
            # Device info line (when available)
            var has_device_info = false
            if data_to_show.contains('sw_version') || data_to_show.contains('hw_version') || data_to_show.contains('device_class')
                fmt.next_line()
                has_device_info = true
                
                if data_to_show.contains('sw_version')
                    fmt.add_status(f"SW v{data_to_show['sw_version']}", "💾", "Software Version")
                end
                
                if data_to_show.contains('hw_version')
                    fmt.add_status(f"HW v{data_to_show['hw_version']}", "🔧", "Hardware Version")
                end
                
                if data_to_show.contains('device_class')
                    fmt.add_status(data_to_show['device_class'], "📡", "LoRaWAN Class")
                end
            end
            
            # Events line (when present)
            var events = []
            if data_to_show.contains('power_on_event') && data_to_show['power_on_event']
                events.push(["Power On", "⚡", "Device power-on event"])
            end
            
            if data_to_show.contains('protocol_name')
                events.push([data_to_show['protocol_name'], "📋", "Protocol Version"])
            end
            
            if data_to_show.contains('serial_number')
                var serial_short = data_to_show['serial_number']
                if size(serial_short) > 8
                    serial_short = serial_short[0..7] + "..."
                end
                events.push([f"SN:{serial_short}", "🏷️", f"Serial: {data_to_show['serial_number']}"])
            end
            
            # Add events line only if we have events
            if size(events) > 0
                if !has_device_info
                    fmt.next_line()
                else
                    fmt.next_line()
                end
                
                for i: 0..(size(events) - 1)
                    if i >= 3 break end  # Max 3 events per line
                    var event = events[i]
                    fmt.add_status(event[0], event[1], event[2])
                end
            end
            
            fmt.end_line()
            
            # ONLY get_msg() return a string that can be used with +=
            msg += fmt.get_msg()

            return msg
            
        except .. as e, m
            print(f"WS101: Display error - {e}: {m}")
            return "📟 WS101 Error - Check Console"
        end
    end
    
    def format_age(seconds)
        if seconds == nil return "Unknown" end
        if seconds < 60 return f"{seconds}s ago"
        elif seconds < 3600 return f"{seconds/60}m ago"
        elif seconds < 86400 return f"{seconds/3600}h ago"
        else return f"{seconds/86400}d ago"
        end
    end
    
    # Get node statistics
    def get_node_stats(node_id)
        import global
        var node_data = global.WS101_nodes.find(node_id, nil)
        if node_data == nil return nil end
        
        return {
            'last_update': node_data.find('last_update', 0),
            'battery_history': node_data.find('battery_history', []),
            'total_presses': node_data.find('total_presses', 0),
            'Short Press_count': node_data.find('Short Press_count', 0),
            'Long Press_count': node_data.find('Long Press_count', 0),
            'Double Press_count': node_data.find('Double Press_count', 0),
            'last_press_type': node_data.find('last_press_type', 'None'),
            'last_press_time': node_data.find('last_press_time', 0),
            'power_on_count': node_data.find('power_on_count', 0),
            'last_power_on': node_data.find('last_power_on', 0),
            'name': node_data.find('name', 'Unknown')
        }
    end
    
    # Clear node data (for maintenance)
    def clear_node_data(node_id)
        import global
        if global.WS101_nodes.contains(node_id)
            global.WS101_nodes.remove(node_id)
            return true
        end
        return false
    end
    
    # Register downlink commands for device control
    def register_downlink_commands()
        import string
        
        # Set Reporting Interval
        tasmota.remove_cmd("LwWS101Interval")
        tasmota.add_cmd("LwWS101Interval", def(cmd, idx, payload_str)
            # Format: LwWS101Interval<slot> <seconds>
            var seconds = int(payload_str)
            if seconds < 60 || seconds > 64800
                return tasmota.resp_cmnd_str("Invalid: range 60-64800 seconds (1min-18h)")
            end
            
            var hex_cmd = f"FF03{lwdecode.uint16le(seconds)}"
            return lwdecode.SendDownlink(global.WS101_nodes, cmd, idx, hex_cmd)
        end)
        
        # Reboot Device
        tasmota.remove_cmd("LwWS101Reboot")
        tasmota.add_cmd("LwWS101Reboot", def(cmd, idx, payload_str)
            # Format: LwWS101Reboot<slot>
            var hex_cmd = "FF10FF"
            return lwdecode.SendDownlink(global.WS101_nodes, cmd, idx, hex_cmd)
        end)
        
        # Set LED Indicator
        tasmota.remove_cmd("LwWS101LED")
        tasmota.add_cmd("LwWS101LED", def(cmd, idx, payload_str)
            # Format: LwWS101LED<slot> <enable|disable|1|0>
            return lwdecode.SendDownlinkMap(global.WS101_nodes, cmd, idx, payload_str, { 
                '1|ENABLE':  ['FF2F01', 'LED Enabled'],
                '0|DISABLE': ['FF2F00', 'LED Disabled']
            })
        end)
        
        # Set Double Press Mode
        tasmota.remove_cmd("LwWS101DoublePress")
        tasmota.add_cmd("LwWS101DoublePress", def(cmd, idx, payload_str)
            # Format: LwWS101DoublePress<slot> <enable|disable|1|0>
            return lwdecode.SendDownlinkMap(global.WS101_nodes, cmd, idx, payload_str, { 
                '1|ENABLE':  ['FF7401', 'Double Press Enabled'],
                '0|DISABLE': ['FF7400', 'Double Press Disabled']
            })
        end)
        
        # Set Buzzer
        tasmota.remove_cmd("LwWS101Buzzer")
        tasmota.add_cmd("LwWS101Buzzer", def(cmd, idx, payload_str)
            # Format: LwWS101Buzzer<slot> <enable|disable|1|0>
            return lwdecode.SendDownlinkMap(global.WS101_nodes, cmd, idx, payload_str, { 
                '1|ENABLE':  ['FF3E01', 'Buzzer Enabled'],
                '0|DISABLE': ['FF3E00', 'Buzzer Disabled']
            })
        end)
        
        print("WS101: Downlink commands registered")
    end
end

# Global instance
LwDeco = LwDecode_WS101()

# Node management commands
tasmota.remove_cmd("LwWS101NodeStats")
tasmota.add_cmd("LwWS101NodeStats", def(cmd, idx, node_id)
    var stats = LwDeco.get_node_stats(node_id)
    if stats != nil
        import json
        tasmota.resp_cmnd(json.dump(stats))
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

tasmota.remove_cmd("LwWS101ClearNode")
tasmota.add_cmd("LwWS101ClearNode", def(cmd, idx, node_id)
    if LwDeco.clear_node_data(node_id)
        tasmota.resp_cmnd_done()
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

# Test UI command
tasmota.remove_cmd("LwWS101TestUI")
tasmota.add_cmd("LwWS101TestUI", def(cmd, idx, payload_str)
    # Predefined realistic test scenarios for UI development
    var test_scenarios = {
        "short_press":   "FF2E01017550",           # Short press + 80% battery
        "long_press":    "FF2E02017540",           # Long press + 64% battery  
        "double_press":  "FF2E030175FF",           # Double press + 255% battery (full)
        "low_battery":   "FF2E01017514",           # Short press + 20% battery
        "power_on":      "FF0B017550",             # Power on event + 80% battery
        "device_info":   "FF0101FF09010AFF0A0103FF0F00", # Protocol v1, HW v1.10, SW v1.3, Class A
        "serial":        "FF08123456789ABC",       # Serial number response
        "full_info":     "FF2E01017550FF0101FF09010AFF0A0103" # Button press + device info
    }
    
    var hex_payload = test_scenarios.find(payload_str ? payload_str : 'nil', 'not_found')
    
    if hex_payload == 'not_found'
      var scenarios_list = ""
      for key: test_scenarios.keys()
        scenarios_list += key + " "
      end
      return tasmota.resp_cmnd_str(format("Available scenarios: %s", scenarios_list))
    end
    
    var rssi = -75
    var fport = 85

    return tasmota.cmd(f'LwSimulate{idx} {rssi},{fport},{hex_payload}')
end)

# MANDATORY: Register driver for web UI integration
tasmota.add_driver(LwDeco)
