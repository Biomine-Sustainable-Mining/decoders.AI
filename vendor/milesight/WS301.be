#
# LoRaWAN AI-Generated Decoder for Milesight WS301 Prompted by ZioFabry
#
# Generated: 2025-09-03 | Version: 2.0.0 | Revision: 6
#            by "LoRaWAN Decoder AI Generation Template", v2.5.0
#
# Homepage:  https://www.milesight-iot.com/lorawan/sensor/ws301/
# Userguide: https://resource.milesight.com/milesight/iot/document/ws301-user-guide-en.pdf
# Decoder:   https://github.com/Milesight-IoT/SensorDecoders
# 
# v2.0.0 (2025-09-03): Template v2.5.0 upgrade - TestUI payload verification & critical Berry keys() fixes
# v1.5.0 (2025-09-02): Framework v2.4.1 upgrade - CRITICAL BERRY KEYS() ITERATOR BUG FIX
# v1.4.0 (2025-08-26): Framework v2.2.9 + Template v2.3.6 upgrade - enhanced error handling
# v1.3.0 (2025-08-20): Complete regeneration with framework v2.2.6
# v1.2.0 (2025-08-20): Enhanced door state tracking and security features
# v1.1.0 (2025-08-16): Added comprehensive test scenarios
# v1.0.0 (2025-08-15): Initial generation from PDF specification

class LwDecode_WS301
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
        if !global.contains("WS301_nodes")
            global.WS301_nodes = {}
        end
        if !global.contains("WS301_cmdInit")
            global.WS301_cmdInit = false
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
            var node_data = global.WS301_nodes.find(node, {})
            var previous_data = node_data.find('last_data', {})
            
            # CRITICAL FIX: Use explicit key arrays for data recovery
            if size(previous_data) > 0
                for key: ['battery_level', 'battery_v', 'door_state', 'door_open', 'tamper_detected', 'device_installed']
                    if previous_data.contains(key)
                        data[key] = previous_data[key]
                    end
                end
            end
            
            # Parse multi-channel payload
            var i = 0
            while i < size(payload) - 1
                var channel_id = payload[i]
                var channel_type = payload[i+1]
                i += 2
                
                # Device Information Channels (0xFF)
                if channel_id == 0xFF
                    if channel_type == 0x01 && i < size(payload)
                        # Protocol Version
                        data['protocol_version'] = payload[i]
                        i += 1
                        
                    elif channel_type == 0x08 && i + 5 < size(payload)
                        # Device Serial Number (6 bytes)
                        var sn_hex = ""
                        for j: 0..5
                            sn_hex += string.format("%02X", payload[i+j])
                        end
                        data['device_sn'] = sn_hex
                        i += 6
                        
                    elif channel_type == 0x09 && i + 1 < size(payload)
                        # Hardware Version
                        var hw_major = payload[i]
                        var hw_minor = payload[i+1]
                        data['hw_version'] = string.format("V%d.%d", hw_major, hw_minor)
                        i += 2
                        
                    elif channel_type == 0x0A && i + 1 < size(payload)
                        # Software Version
                        var sw_major = payload[i]
                        var sw_minor = payload[i+1]
                        data['sw_version'] = string.format("V%d.%d", sw_major, sw_minor)
                        i += 2
                        
                    elif channel_type == 0x0B && i < size(payload)
                        # Power On Event
                        data['power_on_event'] = true
                        data['device_reset'] = true
                        i += 1
                        
                    elif channel_type == 0x0F && i < size(payload)
                        # Device Type
                        var device_type = payload[i]
                        if device_type == 0x00
                            data['device_class'] = "Class A"
                        elif device_type == 0x01
                            data['device_class'] = "Class B"
                        elif device_type == 0x02
                            data['device_class'] = "Class C"
                        else
                            data['device_class'] = string.format("Unknown (%02X)", device_type)
                        end
                        i += 1
                    else
                        # Unknown FF channel type
                        print(f"WS301: Unknown device info channel: {channel_type:02X}")
                        break
                    end
                    
                # Battery Level (0x01, 0x75)
                elif channel_id == 0x01 && channel_type == 0x75 && i < size(payload)
                    data['battery_level'] = payload[i]
                    # Convert to voltage format for framework compatibility
                    var voltage = 2.5 + (payload[i] / 100.0) * 1.1  # 2.5V-3.6V range
                    data['battery_v'] = voltage
                    i += 1
                    
                # Magnet Status (0x03, 0x00)
                elif channel_id == 0x03 && channel_type == 0x00 && i < size(payload)
                    var door_state = payload[i]
                    data['door_state'] = door_state
                    data['door_open'] = door_state == 0x01
                    
                    # Track door state changes
                    var prev_state = node_data.find('last_door_state', nil)
                    if prev_state != nil && prev_state != door_state
                        data['door_state_changed'] = true
                        node_data['door_change_count'] = node_data.find('door_change_count', 0) + 1
                        node_data['last_door_change'] = tasmota.rtc()['local']
                    end
                    node_data['last_door_state'] = door_state
                    i += 1
                    
                # Tamper Status (0x04, 0x00)
                elif channel_id == 0x04 && channel_type == 0x00 && i < size(payload)
                    var tamper_state = payload[i]
                    data['tamper_detected'] = tamper_state == 0x01
                    data['device_installed'] = tamper_state == 0x00
                    
                    # Track tamper events
                    if tamper_state == 0x01
                        node_data['tamper_count'] = node_data.find('tamper_count', 0) + 1
                        node_data['last_tamper'] = tasmota.rtc()['local']
                    end
                    i += 1
                    
                else
                    # Unknown channel
                    print(f"WS301: Unknown channel ID={channel_id:02X} Type={channel_type:02X}")
                    break
                end
            end
            
            # Update node history in global storage
            node_data['last_data'] = data
            node_data['last_update'] = tasmota.rtc()['local']
            node_data['name'] = name
            
            # Store battery trend if available
            if data.contains('battery_level')
                if !node_data.contains('battery_history')
                    node_data['battery_history'] = []
                end
                # Keep last 10 battery readings
                node_data['battery_history'].push(data['battery_level'])
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
            if !global.contains("WS301_cmdInit") || !global.WS301_cmdInit
                self.register_downlink_commands()
                global.WS301_cmdInit = true
            end

            # Save back to global storage
            global.WS301_nodes[node] = node_data
            
            # Update instance cache
            self.last_data = data
            self.last_update = node_data['last_update']
            
            return data
            
        except .. as e, m
            print(f"WS301: Decode error - {e}: {m}")
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
                var node_data = global.WS301_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            # Fallback: find ANY stored node if no specific node
            # CRITICAL FIX: Use safe iteration with flag
            if size(data_to_show) == 0 && size(global.WS301_nodes) > 0
                var found_node = false
                for node_id: global.WS301_nodes.keys()
                    if !found_node
                        var node_data = global.WS301_nodes[node_id]
                        data_to_show = node_data.find('last_data', {})
                        last_update = node_data.find('last_update', 0)
                        self.node = node_id
                        self.name = node_data.find('name', f"WS301-{node_id}")
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
                name = f"WS301-{self.node}"
            end
            var name_tooltip = "Milesight WS301"
            var battery = data_to_show.find('battery_v', 1000)  # Use 1000 if no battery
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)  # Use 1000 if no RSSI
            var simulated = data_to_show.find('simulated', false) # Simulated payload indicator
            
            # Build display using emoji formatter
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            fmt.start_line()
            
            # Door state with appropriate emoji
            if data_to_show.contains('door_open')
                var door_emoji = data_to_show['door_open'] ? "🔓" : "🔒"
                var door_text = data_to_show['door_open'] ? "Open" : "Closed"
                fmt.add_sensor("string", door_text, "Door State", door_emoji)
            end
            
            # Installation/tamper status
            if data_to_show.contains('device_installed')
                var install_emoji = data_to_show['device_installed'] ? "✅" : "⚠️"
                var install_text = data_to_show['device_installed'] ? "Installed" : "Tamper"
                fmt.add_sensor("string", install_text, "Security", install_emoji)
            end
            
            # Battery level
            if data_to_show.contains('battery_level')
                fmt.add_sensor("string", f"{data_to_show['battery_level']}%", "Battery", "🔋")
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
            print(f"WS301: Display error - {e}: {m}")
            return "📟 WS301 Error - Check Console"
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
        var node_data = global.WS301_nodes.find(node_id, nil)
        if node_data == nil return nil end
        
        return {
            'last_update': node_data.find('last_update', 0),
            'reset_count': node_data.find('reset_count', 0),
            'last_reset': node_data.find('last_reset', 0),
            'battery_history': node_data.find('battery_history', []),
            'name': node_data.find('name', 'Unknown'),
            'door_change_count': node_data.find('door_change_count', 0),
            'last_door_change': node_data.find('last_door_change', 0),
            'tamper_count': node_data.find('tamper_count', 0),
            'last_tamper': node_data.find('last_tamper', 0)
        }
    end
    
    # Clear node data (for maintenance)
    def clear_node_data(node_id)
        import global
        if global.WS301_nodes.contains(node_id)
            global.WS301_nodes.remove(node_id)
            return true
        end
        return false
    end
    
    # Register downlink commands for device control
    def register_downlink_commands()
        import string
        
        # Set Reporting Interval command
        tasmota.remove_cmd("LwWS301SetInterval")
        tasmota.add_cmd("LwWS301SetInterval", def(cmd, idx, payload_str)
            # Format: LwWS301SetInterval<slot> <seconds>
            var seconds = int(payload_str)
            if seconds < 60 || seconds > 64800
                return tasmota.resp_cmnd_str("Invalid: range 60-64800 seconds")
            end
            
            # Build hex command: FF03 + 16-bit little endian seconds
            var hex_cmd = f"FF03{lwdecode.uint16le(seconds)}"
            return lwdecode.SendDownlink(global.WS301_nodes, cmd, idx, hex_cmd)
        end)
        
        # Device reboot command
        tasmota.remove_cmd("LwWS301Reboot")
        tasmota.add_cmd("LwWS301Reboot", def(cmd, idx, payload_str)
            # Format: LwWS301Reboot<slot>
            var hex_cmd = "FF10FF"
            return lwdecode.SendDownlink(global.WS301_nodes, cmd, idx, hex_cmd)
        end)
        
        print("WS301: Downlink commands registered")
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
        if scenario_name == "low" && result.contains('battery_level') && result['battery_level'] > 15
            print(f"PAYLOAD ERROR: {scenario_name} battery should be <= 15%")
            return false
        end
        
        return true
    end
end

# Global instance
LwDeco = LwDecode_WS301()

# Node management commands
tasmota.remove_cmd("LwWS301NodeStats")
tasmota.add_cmd("LwWS301NodeStats", def(cmd, idx, node_id)
    var stats = LwDeco.get_node_stats(node_id)
    if stats != nil
        import json
        tasmota.resp_cmnd(json.dump(stats))
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

tasmota.remove_cmd("LwWS301ClearNode")
tasmota.add_cmd("LwWS301ClearNode", def(cmd, idx, node_id)
    if LwDeco.clear_node_data(node_id)
        tasmota.resp_cmnd_done()
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

# Command usage: LwWS301TestUI<slot> <scenario>
tasmota.remove_cmd("LwWS301TestUI")
tasmota.add_cmd("LwWS301TestUI", def(cmd, idx, payload_str)
    # Predefined realistic test scenarios for UI development
    # CRITICAL REQUIREMENT v2.5.0 - ALL PAYLOADS VERIFIED TO DECODE CORRECTLY
    var test_scenarios = {
        "normal":    "01754A030000040000",                    # Door closed, installed, 74% battery
        "open":      "01754A030001040000",                    # Door open, installed, 74% battery  
        "tamper":    "01754A030000040001",                    # Door closed, tamper detected, 74% battery
        "low":       "01750A030001040000",                    # Door open, low battery (10%), installed
        "config":    "FF0BFF01754AFF0101FF090140FF0A0114",    # Power on + device info
        "info":      "FF086538B2232131FF090140FF0A0114FF0F00" # Serial + versions + class
    }
    
    var hex_payload = test_scenarios.find(payload_str ? payload_str : 'nil', 'not_found')
    
    if hex_payload == 'not_found'
      # CRITICAL FIX: Use static string to avoid keys() iterator bug
      var scenarios_list = "normal open tamper low config info "
      return tasmota.resp_cmnd_str(f"Available scenarios: {scenarios_list}")
    end
    
    var rssi = -75
    var fport = 85

    return tasmota.cmd(f'LwSimulate{idx} {rssi},{fport},{hex_payload}')
end)

# MANDATORY: Register driver for web UI integration
tasmota.add_driver(LwDeco)
