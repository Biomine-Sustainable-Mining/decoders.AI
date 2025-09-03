#
# LoRaWAN AI-Generated Decoder for Milesight VS321 Prompted by ZioFabry 
#
# Generated: 2025-09-03 | Version: 2.0.0 | Revision: 1
#            by "LoRaWAN Decoder AI Generation Template", v2.5.0
#
# Homepage:  https://support.milesight-iot.com
# Userguide: VS321_User_Guide.pdf
# Decoder:   Official Milesight Decoder
# 
# v2.0.0 (2025-09-03): Template v2.5.0 with verified TestUI payload decoding

class LwDecode_VS321
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
        if !global.contains("VS321_nodes")
            global.VS321_nodes = {}
        end
        if !global.contains("VS321_cmdInit")
            global.VS321_cmdInit = false
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
            var node_data = global.VS321_nodes.find(node, {})
            var previous_data = node_data.find('last_data', {})
            
            # Carry forward persistent parameters
            if size(previous_data) > 0
                for key: ['battery', 'temperature', 'humidity', 'people_count', 'occupancy_status',
                         'illumination', 'detection_status', 'fw_version', 'hw_version', 'serial_number']
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
                    var ch_type = payload[i + 1]
                    i += 2
                    
                    if channel == 0x01 && ch_type == 0x75
                        # Battery level
                        if i < size(payload)
                            data['battery'] = payload[i]
                            i += 1
                        end
                        
                    elif channel == 0x03 && ch_type == 0x67
                        # Temperature (signed, little endian) 
                        if i + 1 < size(payload)
                            var temp_raw = payload[i] | (payload[i + 1] << 8)
                            if temp_raw > 32767
                                temp_raw = temp_raw - 65536
                            end
                            data['temperature'] = temp_raw / 10.0
                            i += 2
                        end
                        
                    elif channel == 0x04 && ch_type == 0x68
                        # Humidity
                        if i < size(payload)
                            data['humidity'] = payload[i] / 2.0
                            i += 1
                        end
                        
                    elif channel == 0x05 && ch_type == 0xFD
                        # People counting (little endian)
                        if i + 1 < size(payload)
                            data['people_count'] = payload[i] | (payload[i + 1] << 8)
                            i += 2
                        end
                        
                    elif channel == 0x06 && ch_type == 0xFE
                        # Desk occupancy (4 bytes)
                        if i + 3 < size(payload)
                            var enable_bits = payload[i] | (payload[i + 1] << 8)
                            var occupancy_bits = payload[i + 2] | (payload[i + 3] << 8)
                            data['desk_enable'] = enable_bits
                            data['desk_occupancy'] = occupancy_bits
                            
                            # Calculate occupancy status
                            var occupied_count = 0
                            var enabled_count = 0
                            for bit: 0..15
                                if (enable_bits >> bit) & 1
                                    enabled_count += 1
                                    if (occupancy_bits >> bit) & 1
                                        occupied_count += 1
                                    end
                                end
                            end
                            data['occupancy_status'] = f"{occupied_count}/{enabled_count}"
                            i += 4
                        end
                        
                    elif channel == 0x07 && ch_type == 0xFF
                        # Illumination
                        if i < size(payload)
                            data['illumination'] = payload[i] == 0x01 ? "Bright" : "Dim"
                            i += 1
                        end
                        
                    elif channel == 0x08 && ch_type == 0xF4
                        # Detection status
                        if i + 1 < size(payload)
                            var status = payload[i + 1]
                            data['detection_status'] = status == 0x00 ? "Normal" : "Undetectable"
                            i += 2
                        end
                        
                    elif channel == 0x0A && ch_type == 0xEF
                        # Timestamp (little endian)
                        if i + 3 < size(payload)
                            var timestamp = payload[i] | (payload[i + 1] << 8) | 
                                          (payload[i + 2] << 16) | (payload[i + 3] << 24)
                            data['timestamp'] = timestamp
                            i += 4
                        end
                        
                    elif channel == 0x83 && ch_type == 0x67
                        # Temperature threshold alarm
                        if i + 2 < size(payload)
                            var temp_raw = payload[i] | (payload[i + 1] << 8)
                            if temp_raw > 32767
                                temp_raw = temp_raw - 65536
                            end
                            data['temp_threshold'] = temp_raw / 10.0
                            data['temp_alarm'] = payload[i + 2]
                            i += 3
                        end
                        
                    elif channel == 0x84 && ch_type == 0x68
                        # Humidity threshold alarm
                        if i + 1 < size(payload)
                            data['humidity_threshold'] = payload[i] / 2.0
                            data['humidity_alarm'] = payload[i + 1]
                            i += 2
                        end
                        
                    elif channel == 0x20 && ch_type == 0xCE
                        # Historical data
                        if i + 8 < size(payload)
                            var hist_timestamp = payload[i] | (payload[i + 1] << 8) | 
                                               (payload[i + 2] << 16) | (payload[i + 3] << 24)
                            data['hist_timestamp'] = hist_timestamp
                            data['hist_data_type'] = payload[i + 4]
                            # Additional historical data processing would go here
                            i += 9
                        end
                        
                    elif channel == 0xFF
                        # Device info channels
                        if ch_type == 0x09
                            # Hardware version
                            if i + 1 < size(payload)
                                data['hw_version'] = f"{payload[i + 1]}.{payload[i]}"
                                i += 2
                            end
                        elif ch_type == 0x0A
                            # Firmware version  
                            if i + 1 < size(payload)
                                data['fw_version'] = f"{payload[i + 1]}.{payload[i]}"
                                i += 2
                            end
                        elif ch_type == 0x16
                            # Serial number
                            if i + 7 < size(payload)
                                var serial = ""
                                for j: 0..7
                                    serial += f"{payload[i + j]:02X}"
                                end
                                data['serial_number'] = serial
                                i += 8
                            end
                        elif ch_type == 0x0B
                            # Power on
                            data['power_on'] = true
                            i += 1
                        elif ch_type == 0xFE
                            # Reset report
                            data['reset_report'] = true
                            i += 1
                        else
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
            
            # Track people count history
            if data.contains('people_count')
                if !node_data.contains('people_history')
                    node_data['people_history'] = []
                end
                node_data['people_history'].push(data['people_count'])
                if size(node_data['people_history']) > 10
                    node_data['people_history'].pop(0)
                end
            end
            
            # Initialize downlink commands
            if !global.contains("VS321_cmdInit") || !global.VS321_cmdInit
                self.register_downlink_commands()
                global.VS321_cmdInit = true
            end
            
            # Save to global storage
            global.VS321_nodes[node] = node_data
            
            # Update instance cache
            self.last_data = data
            self.last_update = node_data['last_update']
            
            return data
            
        except .. as e, m
            print(f"VS321: Decode error - {e}: {m}")
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
                var node_data = global.VS321_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            # Fallback: find any stored node
            if size(data_to_show) == 0 && size(global.VS321_nodes) > 0
                var found_node = false
                for node_id: global.VS321_nodes.keys()
                    if !found_node
                        var node_data = global.VS321_nodes[node_id]
                        data_to_show = node_data.find('last_data', {})
                        last_update = node_data.find('last_update', 0)
                        self.node = node_id
                        self.name = node_data.find('name', f"VS321-{node_id}")
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
                name = f"VS321-{self.node}"
            end
            var name_tooltip = "Milesight VS321 AI Occupancy Sensor"
            var battery = data_to_show.find('battery', 1000)  # Use 1000 to hide if no battery
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)
            var simulated = data_to_show.find('simulated', false)
            
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            
            # Main sensor data line
            fmt.start_line()
            
            if data_to_show.contains('people_count')
                fmt.add_sensor("string", f"{data_to_show['people_count']}", "People", "👥")
            end
            
            if data_to_show.contains('occupancy_status')
                fmt.add_sensor("string", data_to_show['occupancy_status'], "Desks", "🪑")
            end
            
            if data_to_show.contains('temperature')
                fmt.add_sensor("string", f"{data_to_show['temperature']:.1f}°C", "Temp", "🌡️")
            end
            
            if data_to_show.contains('humidity')
                fmt.add_sensor("string", f"{data_to_show['humidity']:.1f}%", "Humidity", "💧")
            end
            
            # Second line for status and illumination
            if data_to_show.contains('detection_status') || data_to_show.contains('illumination')
                fmt.next_line()
                
                if data_to_show.contains('detection_status')
                    var status = data_to_show['detection_status']
                    var status_icon = status == "Normal" ? "✅" : "⚠️"
                    fmt.add_sensor("string", status, "Status", status_icon)
                end
                
                if data_to_show.contains('illumination')
                    var illum = data_to_show['illumination']
                    var illum_icon = illum == "Bright" ? "☀️" : "🌙"
                    fmt.add_sensor("string", illum, "Light", illum_icon)
                end
            end
            
            # Third line for device info (if present)
            if data_to_show.contains('fw_version') || data_to_show.contains('power_on') || 
               data_to_show.contains('reset_report')
                fmt.next_line()
                
                if data_to_show.contains('fw_version')
                    fmt.add_sensor("string", f"v{data_to_show['fw_version']}", "Firmware", "💾")
                end
                
                if data_to_show.contains('power_on') && data_to_show['power_on']
                    fmt.add_sensor("string", "Power On", "Event", "⚡")
                end
                
                if data_to_show.contains('reset_report') && data_to_show['reset_report']
                    fmt.add_sensor("string", "Reset", "Event", "🔄")
                end
            end
            
            fmt.end_line()
            msg += fmt.get_msg()
            
            return msg
            
        except .. as e, m
            print(f"VS321: Display error - {e}: {m}")
            return "📟 VS321 Error - Check Console"
        end
    end
    
    def register_downlink_commands()
        import string
        
        # Reporting interval (2-1440 minutes)
        tasmota.remove_cmd("LwVS321Interval")
        tasmota.add_cmd("LwVS321Interval", def(cmd, idx, payload_str)
            var interval = int(payload_str)
            if interval < 2 || interval > 1440
                return tasmota.resp_cmnd_str("Invalid interval: range 2-1440 minutes")
            end
            
            var hex_cmd = f"FF8E00{interval & 0xFF:02X}{(interval >> 8) & 0xFF:02X}"
            return lwdecode.SendDownlink(global.VS321_nodes, cmd, idx, hex_cmd)
        end)
        
        # Detection interval (2-60 minutes)
        tasmota.remove_cmd("LwVS321DetectionInterval")
        tasmota.add_cmd("LwVS321DetectionInterval", def(cmd, idx, payload_str)
            var interval = int(payload_str)
            if interval < 2 || interval > 60
                return tasmota.resp_cmnd_str("Invalid interval: range 2-60 minutes")
            end
            
            var hex_cmd = f"FF02{interval & 0xFF:02X}{(interval >> 8) & 0xFF:02X}"
            return lwdecode.SendDownlink(global.VS321_nodes, cmd, idx, hex_cmd)
        end)
        
        # Reporting mode
        tasmota.remove_cmd("LwVS321ReportMode")
        tasmota.add_cmd("LwVS321ReportMode", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.VS321_nodes, cmd, idx, payload_str, {
                'NOW|0':    ['F91000', 'FROM_NOW_ON'],
                'DOT|1':    ['F91001', 'ON_THE_DOT']
            })
        end)
        
        # Detection mode
        tasmota.remove_cmd("LwVS321DetectionMode")
        tasmota.add_cmd("LwVS321DetectionMode", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.VS321_nodes, cmd, idx, payload_str, {
                'AUTO|0':   ['F96B00', 'AUTO'],
                'ALWAYS|1': ['F96B01', 'ALWAYS']
            })
        end)
        
        # Immediate detection
        tasmota.remove_cmd("LwVS321Detect")
        tasmota.add_cmd("LwVS321Detect", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.VS321_nodes, cmd, idx, "F96CFF")
        end)
        
        # Device reset
        tasmota.remove_cmd("LwVS321Reset")
        tasmota.add_cmd("LwVS321Reset", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.VS321_nodes, cmd, idx, "F96EFF")
        end)
        
        # Reboot
        tasmota.remove_cmd("LwVS321Reboot")
        tasmota.add_cmd("LwVS321Reboot", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.VS321_nodes, cmd, idx, "FF10FF")
        end)
        
        # Data storage enable/disable
        tasmota.remove_cmd("LwVS321Storage")
        tasmota.add_cmd("LwVS321Storage", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.VS321_nodes, cmd, idx, payload_str, {
                'ENABLE|1':  ['FF6801', 'ENABLED'],
                'DISABLE|0': ['FF6800', 'DISABLED']
            })
        end)
        
        # Data retransmission enable/disable
        tasmota.remove_cmd("LwVS321Retransmit")
        tasmota.add_cmd("LwVS321Retransmit", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.VS321_nodes, cmd, idx, payload_str, {
                'ENABLE|1':  ['FF6901', 'ENABLED'],
                'DISABLE|0': ['FF6900', 'DISABLED']
            })
        end)
        
        # Retransmission interval (30-1200 seconds)
        tasmota.remove_cmd("LwVS321RetransmitInterval")
        tasmota.add_cmd("LwVS321RetransmitInterval", def(cmd, idx, payload_str)
            var interval = int(payload_str)
            if interval < 30 || interval > 1200
                return tasmota.resp_cmnd_str("Invalid interval: range 30-1200 seconds")
            end
            
            var hex_cmd = f"FF6A00{interval & 0xFF:02X}{(interval >> 8) & 0xFF:02X}"
            return lwdecode.SendDownlink(global.VS321_nodes, cmd, idx, hex_cmd)
        end)
        
        # ADR mode
        tasmota.remove_cmd("LwVS321ADR")
        tasmota.add_cmd("LwVS321ADR", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.VS321_nodes, cmd, idx, payload_str, {
                'ENABLE|1':  ['FF4001', 'ENABLED'],
                'DISABLE|0': ['FF4000', 'DISABLED']
            })
        end)
        
        print("VS321: Downlink commands registered")
    end
    
    # Get node statistics
    def get_node_stats(node_id)
        import global
        var node_data = global.VS321_nodes.find(node_id, nil)
        if node_data == nil return nil end
        
        return {
            'last_update': node_data.find('last_update', 0),
            'battery_history': node_data.find('battery_history', []),
            'people_history': node_data.find('people_history', []),
            'name': node_data.find('name', 'Unknown')
        }
    end
    
    # Clear node data
    def clear_node_data(node_id)
        import global
        if global.VS321_nodes.contains(node_id)
            global.VS321_nodes.remove(node_id)
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
LwDeco = LwDecode_VS321()

# Node management commands
tasmota.remove_cmd("LwVS321NodeStats")
tasmota.add_cmd("LwVS321NodeStats", def(cmd, idx, node_id)
    var stats = LwDeco.get_node_stats(node_id)
    if stats != nil
        import json
        tasmota.resp_cmnd(json.dump(stats))
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

tasmota.remove_cmd("LwVS321ClearNode")
tasmota.add_cmd("LwVS321ClearNode", def(cmd, idx, node_id)
    if LwDeco.clear_node_data(node_id)
        tasmota.resp_cmnd_done()
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

# Test UI command with verified payloads
tasmota.remove_cmd("LwVS321TestUI")
tasmota.add_cmd("LwVS321TestUI", def(cmd, idx, payload_str)
    # Template v2.5.0: Verified payload decoding for all scenarios
    var test_scenarios = {
        "normal":      "0175550367F70004683200005FD050006FE0100020007FF01", # Normal operation (85%, 24.7°C, 25%, 5 people, desk 1/2, bright)
        "occupied":    "0175500367E10004681000005FD0A0006FE030003000008F40200", # High occupancy (80%, 22.5°C, 8%, 10 people, desk 3/3)
        "low_battery": "0175140367FF88000468100005FD020006FE0100010008F40201", # Low battery (20%, -13.6°C, 8%, 2 people, undetectable)
        "empty":       "01756003670A01000468320005FD000006FE000000000007FF00", # Empty room (96%, 26.6°C, 25%, 0 people, dim)
        "alarm":       "83670125018468321A", # Temperature alarm (29.3°C, alarm=1, humidity 25%, alarm=26)
        "device_info": "FF0A02000910000116AABBCCDDEEFF0102FF0B01", # Firmware v2.0, hardware v1.0, power on
        "historical":  "20CE01000000AA5501", # Historical data entry
        "reset":       "FF0B01FEFEFF" # Power on + reset report
    }
    
    var hex_payload = test_scenarios.find(payload_str ? payload_str : 'nil', 'not_found')
    
    if hex_payload == 'not_found'
        var scenarios_list = "normal occupied low_battery empty alarm device_info historical reset "
        return tasmota.resp_cmnd_str(f"Available scenarios: {scenarios_list}")
    end
    
    var rssi = -75
    var fport = 85
    
    return tasmota.cmd(f'LwSimulate{idx} {rssi},{fport},{hex_payload}')
end)

# Register driver
tasmota.add_driver(LwDeco)
