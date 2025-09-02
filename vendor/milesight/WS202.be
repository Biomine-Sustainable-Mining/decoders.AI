#
# LoRaWAN AI-Generated Decoder for Milesight WS202 Prompted by ZioFabry
#
# Generated: 2025-09-03 | Version: 2.0.0 | Revision: 5
#            by "LoRaWAN Decoder AI Generation Template", v2.5.0
#
# Homepage:  https://resource.milesight.com/milesight/iot/document/ws202-user-guide-en.pdf
# Userguide: https://resource.milesight.com/milesight/iot/document/ws202-user-guide-en.pdf
# Decoder:   https://resource.milesight.com/milesight/iot/document/ws202-user-guide-en.pdf
# 
# v2.0.0 (2025-09-03): Template v2.5.0 upgrade - TestUI payload verification & critical Berry keys() fixes
# v1.4.0 (2025-09-02): Framework v2.4.1 upgrade - CRITICAL BERRY KEYS() ITERATOR BUG FIX
# v1.3.0 (2025-08-26): Framework v2.2.9 + Template v2.3.6 upgrade - enhanced error handling
# v1.0.1 (2025-08-20): Fixed hex payload spaces in TestUI scenarios
# v1.0.0 (2025-08-20): Initial generation from PDF specification

class LwDecode_WS202
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
        if !global.contains("WS202_nodes")
            global.WS202_nodes = {}
        end
        if !global.contains("WS202_cmdInit")
            global.WS202_cmdInit = false
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
            
            # Retrieve node history from global storage
            var node_data = global.WS202_nodes.find(node, {})
            var previous_data = node_data.find('last_data', {})
            
            # CRITICAL FIX: Use explicit key arrays for data recovery
            if size(previous_data) > 0
                for key: ['battery_pct', 'battery_v', 'pir_status', 'occupancy', 'light_status', 'illuminance']
                    if previous_data.contains(key)
                        data[key] = previous_data[key]
                    end
                end
            end
            
            # Decode based on fport
            if fport == 85
                var i = 0
                
                while i < size(payload)
                    if i + 1 >= size(payload) break end
                    
                    var channel_id = payload[i]
                    var channel_type = payload[i+1]
                    i += 2
                    
                    # Device Information channels
                    if channel_id == 0xFF
                        if channel_type == 0x01  # Protocol Version
                            if i < size(payload)
                                data['protocol_version'] = payload[i]
                                i += 1
                            end
                        elif channel_type == 0x08  # Device Serial Number
                            if i + 5 < size(payload)
                                var serial = ""
                                for j: 0..5
                                    serial += string.format("%02X", payload[i+j])
                                end
                                data['serial_number'] = serial
                                i += 6
                            end
                        elif channel_type == 0x09  # Hardware Version
                            if i + 1 < size(payload)
                                var hw_major = payload[i]
                                var hw_minor = payload[i+1]
                                data['hw_version'] = string.format("V%d.%d", hw_major, hw_minor)
                                i += 2
                            end
                        elif channel_type == 0x0A  # Software Version
                            if i + 1 < size(payload)
                                var sw_major = payload[i]
                                var sw_minor = payload[i+1]
                                data['sw_version'] = string.format("V%d.%d", sw_major, sw_minor)
                                i += 2
                            end
                        elif channel_type == 0x0B  # Power On Event
                            if i < size(payload)
                                data['power_on_event'] = payload[i] == 0xFF
                                if data['power_on_event']
                                    data['device_reset'] = true
                                end
                                i += 1
                            end
                        elif channel_type == 0x0F  # Device Type
                            if i < size(payload)
                                var device_type = payload[i]
                                data['device_class'] = device_type == 0 ? "Class A" : 
                                                      device_type == 1 ? "Class B" : 
                                                      device_type == 2 ? "Class C" : "Unknown"
                                i += 1
                            end
                        else
                            # Unknown device info channel - attempt to skip
                            print(f"WS202: Unknown device info channel: {channel_type:02X}")
                            break
                        end
                    # Sensor Data channels
                    elif channel_id == 0x01 && channel_type == 0x75  # Battery Level
                        if i < size(payload)
                            data['battery_pct'] = payload[i]
                            # Convert to voltage format for framework compatibility
                            var voltage = 2.5 + (payload[i] / 100.0) * 1.5  # 2.5V-4.0V range
                            data['battery_v'] = voltage
                            i += 1
                        end
                    elif channel_id == 0x03 && channel_type == 0x00  # PIR Status
                        if i < size(payload)
                            data['pir_status'] = payload[i] == 1
                            data['occupancy'] = data['pir_status'] ? "Occupied" : "Vacant"
                            i += 1
                        end
                    elif channel_id == 0x04 && channel_type == 0x00  # Light Status
                        if i < size(payload)
                            data['light_status'] = payload[i] == 1
                            data['illuminance'] = data['light_status'] ? "Bright" : "Dark"
                            i += 1
                        end
                    else
                        # Unknown channel
                        print(f"WS202: Unknown channel: ID={channel_id:02X} Type={channel_type:02X}")
                        break
                    end
                end
            end
            
            # Update node history in global storage
            node_data['last_data'] = data
            node_data['last_update'] = tasmota.rtc()['local']
            node_data['name'] = name
            
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
            end
            
            # Store reset count if detected
            if data.contains('device_reset') && data['device_reset']
                node_data['reset_count'] = node_data.find('reset_count', 0) + 1
                node_data['last_reset'] = tasmota.rtc()['local']
            end
            
            # Initialize downlink commands
            if !global.contains("WS202_cmdInit") || !global.WS202_cmdInit
                self.register_downlink_commands()
                global.WS202_cmdInit = true
            end

            # Save back to global storage
            global.WS202_nodes[node] = node_data
            
            # Update instance cache
            self.last_data = data
            self.last_update = node_data['last_update']
            
            return data
            
        except .. as e, m
            print(f"WS202: Decode error - {e}: {m}")
            return nil
        end
    end
    
    def add_web_sensor()
        try
            import global
            
            # Try to use current instance data first
            var data_to_show = self.last_data
            var last_update = self.last_update
            
            # If no instance data, try to recover from global storage
            if size(data_to_show) == 0 && self.node != nil
                var node_data = global.WS202_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            # Fallback: find ANY stored node if no specific node
            # CRITICAL FIX: Use safe iteration with flag
            if size(data_to_show) == 0 && size(global.WS202_nodes) > 0
                var found_node = false
                for node_id: global.WS202_nodes.keys()
                    if !found_node
                        var node_data = global.WS202_nodes[node_id]
                        data_to_show = node_data.find('last_data', {})
                        last_update = node_data.find('last_update', 0)
                        self.node = node_id
                        self.name = node_data.find('name', f"WS202-{node_id}")
                        found_node = true
                    end
                end
            end
            
            if size(data_to_show) == 0 return "" end
            
            import string
            var msg = ""
            var fmt = LwSensorFormatter_cls()
            
            # MANDATORY: Add header line with device info
            var name = self.name
            if name == nil || name == ""
                name = f"WS202-{self.node}"
            end
            var name_tooltip = "Milesight WS202"
            var battery = data_to_show.find('battery_v', 1000)  # Use 1000 if no battery
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)  # Use 1000 if no RSSI
            var simulated = data_to_show.find('simulated', false) # Simulated payload indicator
            
            # Build display using emoji formatter
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            fmt.start_line()
            
            # Main sensor line
            if data_to_show.contains('occupancy')
                var pir_icon = data_to_show['pir_status'] ? "🚶" : "🏠"
                fmt.add_sensor("string", data_to_show['occupancy'], "PIR Motion", pir_icon)
            end
            
            if data_to_show.contains('illuminance')
                var light_icon = data_to_show['light_status'] ? "☀️" : "🌙"
                fmt.add_sensor("string", data_to_show['illuminance'], "Light Level", light_icon)
            end
            
            if data_to_show.contains('battery_pct')
                fmt.add_sensor("string", f"{data_to_show['battery_pct']}%", "Battery", "🔋")
            end
            
            # Device info/events line (if present)
            var has_info = false
            var info_items = []
            
            if data_to_show.contains('sw_version')
                info_items.push(['string', data_to_show['sw_version'], "Software", "💿"])
                has_info = true
            end
            if data_to_show.contains('hw_version')
                info_items.push(['string', data_to_show['hw_version'], "Hardware", "🔧"])
                has_info = true
            end
            if data_to_show.contains('device_class')
                info_items.push(['string', data_to_show['device_class'], "LoRaWAN", "📡"])
                has_info = true
            end
            if data_to_show.contains('power_on_event') && data_to_show['power_on_event']
                info_items.push(['string', "Power On", "Event", "⚡"])
                has_info = true
            end
            if data_to_show.contains('device_reset') && data_to_show['device_reset']
                info_items.push(['string', "Reset", "Event", "🔄"])
                has_info = true
            end
            
            # Only create line if there's content
            if has_info
                fmt.next_line()
                for item : info_items
                    fmt.add_sensor(item[0], item[1], item[2], item[3])
                end
            end
            
            # Add last seen info if data is old
            if last_update > 0
                var age = tasmota.rtc()['local'] - last_update
                if age > 3600  # Data older than 1 hour
                    fmt.next_line()
                    fmt.add_status(self.format_age(age), "⏱️", nil)
                end
            end
            
            fmt.end_line()
            
            # ONLY get_msg() return a string that can be used with +=
            msg += fmt.get_msg()

            return msg
            
        except .. as e, m
            print(f"WS202: Display error - {e}: {m}")
            return "📟 WS202 Error - Check Console"
        end
    end
    
    def format_age(seconds)
        if seconds < 60 return f"{seconds}s ago"
        elif seconds < 3600 return f"{seconds/60}m ago"
        elif seconds < 86400 return f"{seconds/3600}h ago"
        else return f"{seconds/86400}d ago"
        end
    end
    
    # Get node statistics
    def get_node_stats(node_id)
        import global
        var node_data = global.WS202_nodes.find(node_id, nil)
        if node_data == nil return nil end
        
        return {
            'last_update': node_data.find('last_update', 0),
            'reset_count': node_data.find('reset_count', 0),
            'last_reset': node_data.find('last_reset', 0),
            'battery_history': node_data.find('battery_history', []),
            'name': node_data.find('name', 'Unknown')
        }
    end
    
    # Clear node data (for maintenance)
    def clear_node_data(node_id)
        import global
        if global.WS202_nodes.contains(node_id)
            global.WS202_nodes.remove(node_id)
            return true
        end
        return false
    end
    
    # Register downlink commands for device control
    def register_downlink_commands()
        import string
        
        # Set Reporting Interval command
        tasmota.remove_cmd("LwWS202SetInterval")
        tasmota.add_cmd("LwWS202SetInterval", def(cmd, idx, payload_str)
            # Format: LwWS202SetInterval<slot> <seconds>
            var interval = int(payload_str)
            if interval < 60 || interval > 64800
                return tasmota.resp_cmnd_str("Invalid: range 60-64800 seconds")
            end
            
            # Build hex command: FF03 + 16-bit little endian interval
            var hex_cmd = f"FF03{lwdecode.uint16le(interval)}"
            return lwdecode.SendDownlink(global.WS202_nodes, cmd, idx, hex_cmd)
        end)
        
        # Reboot Device command
        tasmota.remove_cmd("LwWS202Reboot")
        tasmota.add_cmd("LwWS202Reboot", def(cmd, idx, payload_str)
            # Format: LwWS202Reboot<slot>
            var hex_cmd = "FF10FF"
            return lwdecode.SendDownlink(global.WS202_nodes, cmd, idx, hex_cmd)
        end)
        
        print("WS202: Downlink commands registered")
    end
    
    # MANDATORY: Add payload verification function
    def verify_test_payload(hex_payload, scenario_name, expected_params)
        import string
        # Convert hex string to bytes for testing
        var payload_bytes = []
        var i = 0
        while i < size(hex_payload)
            var byte_str = hex_payload[i..i+1]
            payload_bytes.push(int(f"0x{byte_str}"))
            i += 2
        end
        
        # Decode test payload through driver
        var result = self.decodeUplink("TestDevice", "TEST-001", -75, 85, payload_bytes)
        
        if result == nil
            print(f"PAYLOAD ERROR: {scenario_name} failed to decode")
            return false
        end
        
        # Verify expected parameters exist
        for param: expected_params
            if !result.contains(param)
                print(f"PAYLOAD ERROR: {scenario_name} missing {param}")
                return false
            end
        end
        
        # Verify scenario-specific conditions
        if scenario_name == "low" && result.contains('battery_pct') && result['battery_pct'] > 15
            print(f"PAYLOAD ERROR: {scenario_name} battery should be <= 15%")
            return false
        end
        
        return true
    end
end

# Global instance
LwDeco = LwDecode_WS202()

# Node management commands
tasmota.remove_cmd("LwWS202NodeStats")
tasmota.add_cmd("LwWS202NodeStats", def(cmd, idx, node_id)
    var stats = LwDeco.get_node_stats(node_id)
    if stats != nil
        import json
        tasmota.resp_cmnd(json.dump(stats))
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

tasmota.remove_cmd("LwWS202ClearNode")
tasmota.add_cmd("LwWS202ClearNode", def(cmd, idx, node_id)
    if LwDeco.clear_node_data(node_id)
        tasmota.resp_cmnd_done()
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

# Command usage: LwWS202TestUI<slot> <scenario>
tasmota.remove_cmd("LwWS202TestUI")
tasmota.add_cmd("LwWS202TestUI", def(cmd, idx, payload_str)
    # Predefined realistic test scenarios for UI development
    # CRITICAL REQUIREMENT v2.5.0 - ALL PAYLOADS VERIFIED TO DECODE CORRECTLY
    var test_scenarios = {
        "normal":      "01754A030000040000",    # 74% battery, vacant, dark
        "occupied":    "01754A030001040001",    # 74% battery, occupied, bright  
        "vacant":      "01754A030000040001",    # 74% battery, vacant, bright
        "low":         "01750A030001040000",    # 10% battery, occupied, dark
        "config":      "FF0BFF017550FF0101FF090140FF0A0114", # Power on + device info
        "info":        "FF086538B2232131FF090140FF0A0114FF0F00" # Serial + versions
    }
    
    var hex_payload = test_scenarios.find(payload_str ? payload_str : 'nil', 'not_found')
    
    if hex_payload == 'not_found'
      # CRITICAL FIX: Use static string to avoid keys() iterator bug
      var scenarios_list = "normal occupied vacant low config info "
      return tasmota.resp_cmnd_str(format("Available scenarios: %s", scenarios_list))
    end
    
    var rssi = -75
    var fport = 85

    return tasmota.cmd(f'LwSimulate{idx} {rssi},{fport},{hex_payload}')
end)

# MANDATORY: Register driver for web UI integration
tasmota.add_driver(LwDeco)
