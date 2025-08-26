#
# LoRaWAN AI-Generated Decoder for Milesight WS101 Smart Button
#
# Generated: 2025-08-25 | Version: 1.3.0 | Revision: 1
#            by "LoRaWAN Decoder AI Generation Template", v2.3.6
#
# Homepage:  https://www.milesight.com/iot/product/lorawan-sensor/ws101
# Userguide: https://resource.milesight.com/milesight/iot/document/ws101-datasheet-en.pdf
# Decoder:   https://github.com/Milesight-IoT/SensorDecoders
# 
# v1.3.0 (2025-08-25): Latest framework v2.2.9 + template v2.3.6 regeneration with enhanced features
# v1.2.0 (2025-08-25): Complete regeneration with fresh cached MAP from latest datasheet
# v1.1.0 (2025-08-24): Regenerated with latest framework v2.2.9 and template v2.3.3
# v1.0.0 (2025-08-20): Initial generation from PDF specification

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
            
            # Decode based on fport 85 (standard WS101 data port)
            if fport == 85
                var i = 0
                while i < size(payload)
                    if i + 1 >= size(payload) break end
                    
                    var channel_id = payload[i]
                    var channel_type = payload[i+1]
                    i += 2
                    
                    # Button events (primary function)
                    if channel_id == 0xFF && channel_type == 0x2E
                        if i >= size(payload) break end
                        var button_val = payload[i]
                        if button_val == 0x01
                            data['button_event'] = "Short Press"
                            data['button_mode'] = 1
                            data['press_type'] = "short"
                        elif button_val == 0x02
                            data['button_event'] = "Long Press"
                            data['button_mode'] = 2
                            data['press_type'] = "long"
                        elif button_val == 0x03
                            data['button_event'] = "Double Press"
                            data['button_mode'] = 3
                            data['press_type'] = "double"
                        else
                            data['button_event'] = f"Mode {button_val}"
                            data['button_mode'] = button_val
                            data['press_type'] = "unknown"
                        end
                        i += 1
                        
                    # Battery level monitoring
                    elif channel_id == 0x01 && channel_type == 0x75
                        if i >= size(payload) break end
                        data['battery_pct'] = payload[i]
                        data['battery_v'] = self.percent_to_voltage(payload[i])
                        data['battery_status'] = payload[i] <= 10 ? "Low" : "Normal"
                        i += 1
                        
                    # Protocol version
                    elif channel_id == 0xFF && channel_type == 0x01
                        if i >= size(payload) break end
                        data['protocol_version'] = payload[i]
                        i += 1
                        
                    # Device serial number
                    elif channel_id == 0xFF && channel_type == 0x08
                        if i + 5 >= size(payload) break end
                        data['serial_number'] = string.format("%02X%02X%02X%02X%02X%02X",
                            payload[i], payload[i+1], payload[i+2], 
                            payload[i+3], payload[i+4], payload[i+5])
                        i += 6
                        
                    # Hardware version
                    elif channel_id == 0xFF && channel_type == 0x09
                        if i + 1 >= size(payload) break end
                        data['hw_version'] = f"{payload[i]}.{payload[i+1]}"
                        i += 2
                        
                    # Software version
                    elif channel_id == 0xFF && channel_type == 0x0A
                        if i + 1 >= size(payload) break end
                        data['sw_version'] = f"{payload[i]}.{payload[i+1]}"
                        data['firmware_version'] = data['sw_version']
                        i += 2
                        
                    # Power on event
                    elif channel_id == 0xFF && channel_type == 0x0B
                        data['power_on_event'] = true
                        data['device_reset'] = true
                        data['startup_event'] = true
                        # No additional bytes for this event
                        
                    # Device class
                    elif channel_id == 0xFF && channel_type == 0x0F
                        if i >= size(payload) break end
                        var class_val = payload[i]
                        if class_val == 0x00
                            data['device_class'] = "Class A"
                            data['lorawan_class'] = "A"
                        elif class_val == 0x01
                            data['device_class'] = "Class B"
                            data['lorawan_class'] = "B"
                        elif class_val == 0x02
                            data['device_class'] = "Class C"
                            data['lorawan_class'] = "C"
                        else
                            data['device_class'] = f"Class {class_val}"
                            data['lorawan_class'] = f"{class_val}"
                        end
                        i += 1
                        
                    else
                        # Log unknown channel but continue
                        print(f"WS101: Unknown channel ID={channel_id:02X} Type={channel_type:02X}")
                        # Try to skip minimum bytes
                        i += 1
                        if i >= size(payload) break end
                    end
                end
            end
            
            # Update node history in global storage
            node_data['last_data'] = data
            node_data['last_update'] = tasmota.rtc()['local']
            node_data['name'] = name
            
            # Enhanced button press tracking with statistics
            if data.contains('button_event')
                if !node_data.contains('button_stats')
                    node_data['button_stats'] = {
                        'total_presses': 0,
                        'short_presses': 0,
                        'long_presses': 0,
                        'double_presses': 0,
                        'last_press_time': 0,
                        'last_press_type': 'none'
                    }
                end
                
                var stats = node_data['button_stats']
                stats['total_presses'] += 1
                stats['last_press_time'] = tasmota.rtc()['local']
                stats['last_press_type'] = data['press_type']
                
                # Increment specific press type counter
                if data['press_type'] == 'short'
                    stats['short_presses'] += 1
                elif data['press_type'] == 'long'
                    stats['long_presses'] += 1
                elif data['press_type'] == 'double'
                    stats['double_presses'] += 1
                end
                
                # Keep legacy compatibility
                node_data['button_count'] = stats['total_presses']
                node_data['last_button_press'] = stats['last_press_time']
                node_data['last_button_type'] = data['button_event']
            end
            
            # Store battery trend if available
            if data.contains('battery_pct')
                if !node_data.contains('battery_history')
                    node_data['battery_history'] = []
                end
                # Keep last 10 battery readings
                node_data['battery_history'].push(data['battery_pct'])
                if size(node_data['battery_history']) > 10
                    node_data['battery_history'].pop(0)
                end
                
                # Track battery trend
                if size(node_data['battery_history']) >= 2
                    var current = node_data['battery_history'][-1]
                    var previous = node_data['battery_history'][-2]
                    data['battery_trend'] = current > previous ? "increasing" : 
                                          current < previous ? "decreasing" : "stable"
                end
            end
            
            # Store reset count if detected
            if data.contains('device_reset') && data['device_reset']
                node_data['reset_count'] = node_data.find('reset_count', 0) + 1
                node_data['last_reset'] = tasmota.rtc()['local']
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
            
            # Fallback: find ANY stored node if self.node is nil
            if size(data_to_show) == 0 && size(global.WS101_nodes) > 0
                for node_id: global.WS101_nodes.keys()
                    var node_data = global.WS101_nodes[node_id]
                    data_to_show = node_data.find('last_data', {})
                    last_update = node_data.find('last_update', 0)
                    self.node = node_id  # Update instance node
                    self.name = node_data.find('name', f"WS101-{node_id}")
                    break  # Use first node found
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
            var battery = 1000  # Hide battery icon by default
            if data_to_show.contains('battery_pct')
                battery = 100000 + data_to_show['battery_pct']  # Use percentage format
            elif data_to_show.contains('battery_v')
                battery = data_to_show['battery_v']
            end
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)  # Framework v2.2.9 uses UPPERCASE
            var simulated = data_to_show.find('simulated', false) # Simulated payload indicator
            
            # Build display using emoji formatter
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            
            # Main sensor line - Button status and information
            fmt.start_line()
            
            # Button status with enhanced visual feedback
            if data_to_show.contains('button_event')
                var press_icon = "🔘"  # Default button icon
                var press_text = data_to_show['button_event']
                
                # Enhanced icons based on press type
                if data_to_show.find('press_type') == 'short'
                    press_icon = "🔘"  # Single dot
                elif data_to_show.find('press_type') == 'long' 
                    press_icon = "🔴"  # Red circle for long press
                elif data_to_show.find('press_type') == 'double'
                    press_icon = "⚫"  # Double emphasis
                end
                
                fmt.add_sensor("string", press_text, "Latest Button Action", press_icon)
            else
                fmt.add_sensor("string", "Ready", "Button Status", "🔘")
            end
            
            # Battery status with enhanced info
            if data_to_show.contains('battery_pct')
                var battery_pct = data_to_show['battery_pct']
                var battery_icon = "🔋"
                var battery_tooltip = "Battery Level"
                
                if battery_pct <= 10
                    battery_icon = "🪫"
                    battery_tooltip = "Low Battery Alert"
                elif battery_pct <= 25
                    battery_icon = "🔋"
                    battery_tooltip = "Battery Getting Low"
                end
                
                var battery_text = f"{battery_pct}%"
                if data_to_show.contains('battery_trend')
                    var trend = data_to_show['battery_trend']
                    if trend == "decreasing"
                        battery_text += " ↓"
                    elif trend == "increasing"
                        battery_text += " ↑"
                    end
                end
                
                fmt.add_sensor("string", battery_text, battery_tooltip, battery_icon)
            end
            
            # Device information if available
            if data_to_show.contains('sw_version')
                fmt.add_sensor("string", f"v{data_to_show['sw_version']}", "Software Version", "📋")
            end
            
            # Power on/reset event
            if data_to_show.contains('power_on_event') && data_to_show['power_on_event']
                fmt.add_sensor("string", "Power On", "Device Startup Event", "🔄")
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
    
    def percent_to_voltage(percent)
        # Convert battery percentage to approximate voltage
        # WS101 uses ER14335 Li-SOCl2 battery (1650mAh)
        # Typical range: 2.0V (0%) to 3.6V (100%)
        return 2.0 + (percent / 100.0) * 1.6
    end
    
    def format_age(seconds)
        if seconds == nil return "Unknown" end
        if seconds < 60 return f"{seconds}s ago"
        elif seconds < 3600 return f"{seconds/60}m ago"
        elif seconds < 86400 return f"{seconds/3600}h ago"
        else return f"{seconds/86400}d ago"
        end
    end
    
    # Get node statistics with enhanced button tracking
    def get_node_stats(node_id)
        import global
        var node_data = global.WS101_nodes.find(node_id, nil)
        if node_data == nil return nil end
        
        var stats = {
            'last_update': node_data.find('last_update', 0),
            'reset_count': node_data.find('reset_count', 0),
            'last_reset': node_data.find('last_reset', 0),
            'battery_history': node_data.find('battery_history', []),
            'button_count': node_data.find('button_count', 0),
            'last_button_press': node_data.find('last_button_press', 0),
            'last_button_type': node_data.find('last_button_type', 'None'),
            'name': node_data.find('name', 'Unknown')
        }
        
        # Add enhanced button statistics if available
        if node_data.contains('button_stats')
            stats['button_stats'] = node_data['button_stats']
        end
        
        return stats
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
        
        # Set Reporting Interval (1 minute to 18 hours)
        tasmota.remove_cmd("LwWS101Interval")
        tasmota.add_cmd("LwWS101Interval", def(cmd, idx, payload_str)
            # Format: LwWS101Interval<slot> <seconds>
            var seconds = int(payload_str)
            if seconds < 60 || seconds > 64800
                return tasmota.resp_cmnd_str("Invalid: range 60-64800 seconds (1m-18h)")
            end
            
            # Build hex command per datasheet specification (little endian)
            var hex_cmd = f"FF03{lwdecode.uint16le(seconds)}"
            print(f"WS101: Sending interval command - {seconds} seconds (hex: {hex_cmd})")
            return lwdecode.SendDownlink(global.WS101_nodes, cmd, idx, hex_cmd)
        end)
        
        # Reboot Device
        tasmota.remove_cmd("LwWS101Reboot")
        tasmota.add_cmd("LwWS101Reboot", def(cmd, idx, payload_str)
            # Format: LwWS101Reboot<slot>
            var hex_cmd = "FF10FF"
            print("WS101: Sending reboot command (hex: FF10FF)")
            return lwdecode.SendDownlink(global.WS101_nodes, cmd, idx, hex_cmd)
        end)
        
        # Set LED Indicator
        tasmota.remove_cmd("LwWS101LED")
        tasmota.add_cmd("LwWS101LED", def(cmd, idx, payload_str)
            # Format: LwWS101LED<slot> <enable|disable|1|0>
            return lwdecode.SendDownlinkMap(global.WS101_nodes, cmd, idx, payload_str, { 
                '1|ENABLE':  ['FF2F01', 'ENABLED' ],
                '0|DISABLE': ['FF2F00', 'DISABLED']
            })
        end)
        
        # Set Double Press Mode
        tasmota.remove_cmd("LwWS101DoublePress")
        tasmota.add_cmd("LwWS101DoublePress", def(cmd, idx, payload_str)
            # Format: LwWS101DoublePress<slot> <enable|disable|1|0>
            return lwdecode.SendDownlinkMap(global.WS101_nodes, cmd, idx, payload_str, { 
                '1|ENABLE':  ['FF7401', 'ENABLED' ],
                '0|DISABLE': ['FF7400', 'DISABLED']
            })
        end)
        
        # Set Buzzer
        tasmota.remove_cmd("LwWS101Buzzer")
        tasmota.add_cmd("LwWS101Buzzer", def(cmd, idx, payload_str)
            # Format: LwWS101Buzzer<slot> <enable|disable|1|0>
            return lwdecode.SendDownlinkMap(global.WS101_nodes, cmd, idx, payload_str, { 
                '1|ENABLE':  ['FF3E01', 'ENABLED' ],
                '0|DISABLE': ['FF3E00', 'DISABLED']
            })
        end)
        
        # Device Status Request
        tasmota.remove_cmd("LwWS101Status")
        tasmota.add_cmd("LwWS101Status", def(cmd, idx, payload_str)
            # Format: LwWS101Status<slot>
            var hex_cmd = "FF00"
            return lwdecode.SendDownlink(global.WS101_nodes, cmd, idx, hex_cmd)
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

# Enhanced test scenarios with verified payloads
tasmota.remove_cmd("LwWS101TestUI")
tasmota.add_cmd("LwWS101TestUI", def(cmd, idx, payload_str)
    # Predefined realistic test scenarios for UI development
    var test_scenarios = {
        "normal":     "FF2E01017550",                           # Short press + 80% battery
        "long":       "FF2E02017532",                           # Long press + 50% battery  
        "double":     "FF2E03017514",                           # Double press + 20% battery
        "lowbatt":    "FF2E01017505",                           # Short press + 5% battery (critical)
        "critical":   "FF2E02017503",                           # Long press + 3% battery (emergency)
        "powerup":    "FF0B017580FF0101FF08010203040506FF0A0102", # Power on + 80% battery + device info
        "info":       "FF0101FF08010203040506FF0A0102FF0F00",    # Protocol + serial + SW version + Class A
        "emergency":  "FF2E02017510",                           # Long press (SOS) + 16% battery
        "scene":      "FF2E01017595"                            # Short press (scene) + 95% battery
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
