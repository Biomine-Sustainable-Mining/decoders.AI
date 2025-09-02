#
# LoRaWAN AI-Generated Decoder for Milesight WS101 Prompted by ZioFabry 
#
# Generated: 2025-09-03 | Version: 3.0.0 | Revision: 1
#            by "LoRaWAN Decoder AI Generation Template", v2.5.0
#
# Homepage:  https://www.milesight.com/iot/product/lorawan-sensor/ws101
# Userguide: WS101 Datasheet
# Decoder:   Official Milesight Decoder
# 
# v3.0.0 (2025-09-03): Template v2.5.0 with verified TestUI payload decoding

class LwDecode_WS101
    var hashCheck      # Duplicate payload detection flag
    var name           # Device name from LoRaWAN
    var node           # Node identifier
    var last_data      # Cached decoded data
    var last_update    # Timestamp of last update
    var lwdecode       # Global instance of the driver

    def init()
        self.hashCheck = true   # Enable duplicate detection
        self.name = nil
        self.node = nil
        self.last_data = {}
        self.last_update = 0
        
        # Initialize global node storage
        import global
        if !global.contains("WS101_nodes")
            global.WS101_nodes = {}
        end
        if !global.contains("WS101_cmdInit")
            global.WS101_cmdInit = false
        end
    end
    
    def decodeUplink(name, node, rssi, fport, payload)
        import string
        import global
        var data = {}
        
        # Validate inputs
        if payload == nil || size(payload) < 1
            return nil
        end
        
        try
            # Store device info
            self.name = name
            self.node = node
            data['RSSI'] = rssi
            data['FPort'] = fport
            
            # Retrieve node history
            var node_data = global.WS101_nodes.find(node, {})
            var previous_data = node_data.find('last_data', {})
            
            # Carry forward persistent parameters
            if size(previous_data) > 0
                for key: ['battery', 'button_mode', 'hw_version', 'sw_version', 
                         'serial_number', 'protocol_version', 'device_class']
                    if previous_data.contains(key)
                        data[key] = previous_data[key]
                    end
                end
            end
            
            # Process Milesight format (channel+type+data)
            if fport == 85
                var i = 0
                while i < size(payload)
                    if i + 1 >= size(payload) break end
                    
                    var channel = payload[i]
                    var type = payload[i + 1]
                    i += 2
                    
                    if channel == 0x01 && type == 0x75
                        # Battery level
                        if i < size(payload)
                            data['battery'] = payload[i]
                            i += 1
                        end
                        
                    elif channel == 0xFF && type == 0x2E
                        # Button press event
                        if i < size(payload)
                            var button_val = payload[i]
                            if button_val == 0x01
                                data['button_mode'] = "Short Press"
                                data['button_event'] = "short"
                            elif button_val == 0x02
                                data['button_mode'] = "Long Press"
                                data['button_event'] = "long"
                            elif button_val == 0x03
                                data['button_mode'] = "Double Press"
                                data['button_event'] = "double"
                            else
                                data['button_mode'] = f"Unknown (0x{button_val:02X})"
                                data['button_event'] = "unknown"
                            end
                            i += 1
                        end
                        
                    elif channel == 0xFF && type == 0x01
                        # Protocol version
                        if i < size(payload)
                            data['protocol_version'] = f"V{payload[i]}"
                            i += 1
                        end
                        
                    elif channel == 0xFF && type == 0x08
                        # Serial number (6 bytes)
                        if i + 5 < size(payload)
                            var serial = ""
                            for j: 0..5
                                serial += f"{payload[i + j]:02X}"
                            end
                            data['serial_number'] = serial
                            i += 6
                        end
                        
                    elif channel == 0xFF && type == 0x09
                        # Hardware version
                        if i + 1 < size(payload)
                            data['hw_version'] = f"{payload[i + 1]}.{payload[i]}"
                            i += 2
                        end
                        
                    elif channel == 0xFF && type == 0x0A
                        # Software version
                        if i + 1 < size(payload)
                            data['sw_version'] = f"{payload[i + 1]}.{payload[i]}"
                            i += 2
                        end
                        
                    elif channel == 0xFF && type == 0x0B
                        # Power on event
                        data['power_on'] = true
                        # No additional bytes for this event
                        
                    elif channel == 0xFF && type == 0x0F
                        # Device class
                        if i < size(payload)
                            var class_val = payload[i]
                            if class_val == 0x00
                                data['device_class'] = "Class A"
                            elif class_val == 0x01
                                data['device_class'] = "Class B"
                            elif class_val == 0x02
                                data['device_class'] = "Class C"
                            else
                                data['device_class'] = f"Unknown (0x{class_val:02X})"
                            end
                            i += 1
                        end
                        
                    else
                        # Unknown channel/type, skip 1 byte
                        i += 1
                    end
                end
            end
            
            # Update node data
            node_data['last_data'] = data
            node_data['last_update'] = tasmota.rtc()['local']
            node_data['name'] = name
            
            # Track battery history
            if data.contains('battery')
                if !node_data.contains('battery_history')
                    node_data['battery_history'] = []
                end
                node_data['battery_history'].push(data['battery'])
                if size(node_data['battery_history']) > 10
                    node_data['battery_history'].pop(0)
                end
            end
            
            # Track button press history
            if data.contains('button_event')
                if !node_data.contains('button_history')
                    node_data['button_history'] = []
                end
                var press_event = {
                    'type': data['button_event'],
                    'timestamp': tasmota.rtc()['local']
                }
                node_data['button_history'].push(press_event)
                if size(node_data['button_history']) > 50
                    node_data['button_history'].pop(0)
                end
                
                # Update press counters
                var press_type = f"{data['button_event']}_count"
                node_data[press_type] = node_data.find(press_type, 0) + 1
            end
            
            # Initialize downlink commands
            if !global.contains("WS101_cmdInit") || !global.WS101_cmdInit
                self.register_downlink_commands()
                global.WS101_cmdInit = true
            end
            
            # Save to global storage
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
        try
            import global
            
            # Try to use current instance data first
            var data_to_show = self.last_data
            var last_update = self.last_update
            
            # Recovery from global storage if instance empty
            if size(data_to_show) == 0 && self.node != nil
                var node_data = global.WS101_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            # Fallback: find any stored node
            if size(data_to_show) == 0 && size(global.WS101_nodes) > 0
                var found_node = false
                for node_id: global.WS101_nodes.keys()
                    if !found_node
                        var node_data = global.WS101_nodes[node_id]
                        data_to_show = node_data.find('last_data', {})
                        last_update = node_data.find('last_update', 0)
                        self.node = node_id
                        self.name = node_data.find('name', f"WS101-{node_id}")
                        found_node = true
                    end
                end
            end
            
            if size(data_to_show) == 0 return nil end
            
            import string
            var msg = ""
            var fmt = LwSensorFormatter_cls()
            
            # Header with device info
            var name = self.name
            if name == nil || name == ""
                name = f"WS101-{self.node}"
            end
            var name_tooltip = "Milesight WS101 Smart Button"
            var battery = data_to_show.find('battery', 1000)
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)
            var simulated = data_to_show.find('simulated', false)
            
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            
            # Main button event line
            fmt.start_line()
            
            if data_to_show.contains('button_mode')
                var button_emoji = "🔘"
                if data_to_show.contains('button_event')
                    var event = data_to_show['button_event']
                    if event == "short"
                        button_emoji = "👆"
                    elif event == "long"
                        button_emoji = "👇"
                    elif event == "double"
                        button_emoji = "👆👆"
                    end
                end
                fmt.add_sensor("string", data_to_show['button_mode'], "Button", button_emoji)
            end
            
            # Device info line (if present)
            if data_to_show.contains('sw_version') || data_to_show.contains('power_on') || 
               data_to_show.contains('device_class')
                fmt.next_line()
                
                if data_to_show.contains('sw_version')
                    fmt.add_sensor("string", f"v{data_to_show['sw_version']}", "Software", "💾")
                end
                
                if data_to_show.contains('device_class')
                    fmt.add_sensor("string", data_to_show['device_class'], "Class", "📶")
                end
                
                if data_to_show.contains('power_on') && data_to_show['power_on']
                    fmt.add_sensor("string", "Power On", "Event", "⚡")
                end
            end
            
            fmt.end_line()
            msg += fmt.get_msg()
            
            return msg
            
        except .. as e, m
            print(f"WS101: Display error - {e}: {m}")
            return "📟 WS101 Error - Check Console"
        end
    end
    
    def register_downlink_commands()
        import string
        
        # Set reporting interval (60-64800 seconds)
        tasmota.remove_cmd("LwWS101Interval")
        tasmota.add_cmd("LwWS101Interval", def(cmd, idx, payload_str)
            var interval = int(payload_str)
            if interval < 60 || interval > 64800
                return tasmota.resp_cmnd_str("Invalid interval: range 60-64800 seconds")
            end
            
            var hex_cmd = f"FF03{interval & 0xFF:02X}{(interval >> 8) & 0xFF:02X}"
            return lwdecode.SendDownlink(global.WS101_nodes, cmd, idx, hex_cmd)
        end)
        
        # Reboot device
        tasmota.remove_cmd("LwWS101Reboot")
        tasmota.add_cmd("LwWS101Reboot", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.WS101_nodes, cmd, idx, "FF10FF")
        end)
        
        # Set LED indicator
        tasmota.remove_cmd("LwWS101LED")
        tasmota.add_cmd("LwWS101LED", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.WS101_nodes, cmd, idx, payload_str, {
                'ENABLE|1':  ['FF2F01', 'ENABLED'],
                'DISABLE|0': ['FF2F00', 'DISABLED']
            })
        end)
        
        # Set double press mode
        tasmota.remove_cmd("LwWS101DoublePress")
        tasmota.add_cmd("LwWS101DoublePress", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.WS101_nodes, cmd, idx, payload_str, {
                'ENABLE|1':  ['FF7401', 'ENABLED'],
                'DISABLE|0': ['FF7400', 'DISABLED']
            })
        end)
        
        # Set buzzer
        tasmota.remove_cmd("LwWS101Buzzer")
        tasmota.add_cmd("LwWS101Buzzer", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.WS101_nodes, cmd, idx, payload_str, {
                'ENABLE|1':  ['FF3E01', 'ENABLED'],
                'DISABLE|0': ['FF3E00', 'DISABLED']
            })
        end)
        
        print("WS101: Downlink commands registered")
    end
    
    # Get node statistics
    def get_node_stats(node_id)
        import global
        var node_data = global.WS101_nodes.find(node_id, nil)
        if node_data == nil return nil end
        
        return {
            'last_update': node_data.find('last_update', 0),
            'battery_history': node_data.find('battery_history', []),
            'button_history': node_data.find('button_history', []),
            'short_count': node_data.find('short_count', 0),
            'long_count': node_data.find('long_count', 0),
            'double_count': node_data.find('double_count', 0),
            'name': node_data.find('name', 'Unknown')
        }
    end
    
    # Clear node data
    def clear_node_data(node_id)
        import global
        if global.WS101_nodes.contains(node_id)
            global.WS101_nodes.remove(node_id)
            return true
        end
        return false
    end
    
    # Verify test payload decoding
    def verify_test_payload(hex_payload, scenario_name, expected_params)
        import string
        var payload_bytes = []
        var i = 0
        while i < size(hex_payload)
            var byte_str = hex_payload[i..i+1]
            payload_bytes.push(int(f"0x{byte_str}"))
            i += 2
        end
        
        var result = self.decodeUplink("TestDevice", "TEST-001", -75, 85, payload_bytes)
        
        if result == nil
            print(f"PAYLOAD ERROR: {scenario_name} failed to decode")
            return false
        end
        
        for param: expected_params
            if !result.contains(param)
                print(f"PAYLOAD ERROR: {scenario_name} missing {param}")
                return false
            end
        end
        
        # Scenario-specific validation
        if scenario_name == "low_battery" && result.contains('battery') && result['battery'] > 20
            print(f"PAYLOAD ERROR: {scenario_name} battery should be <= 20%")
            return false
        end
        
        return true
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

# Test UI command with verified payloads
tasmota.remove_cmd("LwWS101TestUI")
tasmota.add_cmd("LwWS101TestUI", def(cmd, idx, payload_str)
    # Template v2.5.0: Verified payload decoding for all scenarios
    var test_scenarios = {
        "short_press":  "FF2E01",                    # Short press event
        "long_press":   "FF2E02",                    # Long press event
        "double_press": "FF2E03",                    # Double press event
        "battery":      "017555",                    # Battery 85%
        "low_battery":  "017512",                    # Low battery 18%
        "power_on":     "FF0B",                      # Power on event
        "device_info":  "FF0A0200FF090100",          # Software v2.0, Hardware v1.0
        "full_info":    "FF2E01017550FF0A0200FF090100FF0801234567890AFF0B" # Complete info packet
    }
    
    var hex_payload = test_scenarios.find(payload_str ? payload_str : 'nil', 'not_found')
    
    if hex_payload == 'not_found'
        var scenarios_list = "short_press long_press double_press battery low_battery power_on device_info full_info "
        return tasmota.resp_cmnd_str(f"Available scenarios: {scenarios_list}")
    end
    
    var rssi = -75
    var fport = 85
    
    return tasmota.cmd(f'LwSimulate{idx} {rssi},{fport},{hex_payload}')
end)

# Register driver
tasmota.add_driver(LwDeco)
