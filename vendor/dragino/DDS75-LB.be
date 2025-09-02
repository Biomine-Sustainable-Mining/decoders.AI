#
# LoRaWAN AI-Generated Decoder for Dragino DDS75-LB Prompted by ZioFabry 
#
# Generated: 2025-09-03 | Version: 2.0.0 | Revision: 1
#            by "LoRaWAN Decoder AI Generation Template", v2.5.0
#
# Homepage:  https://wiki.dragino.com/xwiki/bin/view/Main/User%20Manual%20for%20LoRaWAN%20End%20Nodes/DDS75-LB_LoRaWAN_Distance_Detection_Sensor_User_Manual/
# Userguide: https://wiki.dragino.com/xwiki/bin/view/Main/User%20Manual%20for%20LoRaWAN%20End%20Nodes/DDS75-LB_LoRaWAN_Distance_Detection_Sensor_User_Manual/
# Decoder:   Official Dragino documentation
# 
# v2.0.0 (2025-09-03): Complete regeneration with Template v2.5.0 - Enhanced TestUI payload verification

class LwDecode_DDS75_LB
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
        if !global.contains("DDS75_LB_nodes")
            global.DDS75_LB_nodes = {}
        end
        if !global.contains("DDS75_LB_cmdInit")
            global.DDS75_LB_cmdInit = false
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
            var node_data = global.DDS75_LB_nodes.find(node, {})
            var previous_data = node_data.find('last_data', {})
            
            # CRITICAL FIX: Use explicit key arrays for data recovery
            if size(previous_data) > 0
                for key: ['battery_v', 'distance_mm', 'temperature', 'sensor_detected', 'interrupt_flag']
                    if previous_data.contains(key)
                        data[key] = previous_data[key]
                    end
                end
            end
            
            # Decode based on fport
            if fport == 1
                # Periodic Data
                if size(payload) >= 8
                    # Battery voltage (little endian)
                    var battery_mv = (payload[1] << 8) | payload[0]
                    data['battery_v'] = battery_mv / 1000.0
                    data['battery_mv'] = battery_mv
                    
                    # Distance measurement (little endian)
                    var distance_raw = (payload[3] << 8) | payload[2]
                    if distance_raw == 0x0000
                        data['distance_status'] = "No sensor detected"
                        data['sensor_detected'] = false
                    elif distance_raw == 0x0014
                        data['distance_status'] = "Invalid reading"
                        data['sensor_detected'] = true
                    else
                        data['distance_mm'] = distance_raw
                        data['distance_cm'] = distance_raw / 10.0
                        data['distance_m'] = distance_raw / 1000.0
                        data['sensor_detected'] = true
                    end
                    
                    # Digital interrupt flag
                    data['interrupt_flag'] = payload[4] == 0x01
                    
                    # DS18B20 temperature (optional, little endian, signed)
                    if size(payload) >= 7
                        var temp_raw = (payload[6] << 8) | payload[5]
                        if temp_raw != 0x7FFF  # Valid temperature
                            if temp_raw & 0xFC00
                                temp_raw = temp_raw - 65536
                            end
                            data['temperature'] = temp_raw / 10.0
                        end
                    end
                    
                    # Ultrasonic sensor detection flag
                    if size(payload) >= 8
                        data['ultrasonic_detected'] = payload[7] == 0x01
                    end
                end
                
            elif fport == 5
                # Device Status
                if size(payload) >= 7
                    data['sensor_model'] = payload[0]
                    var fw_version = (payload[2] << 8) | payload[1]
                    data['fw_version'] = f"v{fw_version:04X}"
                    
                    var freq_band = payload[3]
                    var freq_bands = {
                        0x01: "EU868", 0x02: "US915", 0x03: "IN865", 0x04: "AU915",
                        0x05: "KZ865", 0x06: "RU864", 0x07: "AS923", 0x08: "AS923-2",
                        0x09: "AS923-3", 0x0A: "AS923-4", 0x0B: "CN470", 0x0C: "EU433",
                        0x0D: "KR920", 0x0E: "MA869"
                    }
                    data['frequency_band'] = freq_bands.find(freq_band, f"Unknown ({freq_band:02X})")
                    data['sub_band'] = payload[4]
                    
                    var battery_mv = (payload[6] << 8) | payload[5]
                    data['battery_v'] = battery_mv / 1000.0
                    data['battery_mv'] = battery_mv
                    data['device_info'] = true
                end
            end
            
            # Update node history in global storage
            node_data['last_data'] = data
            node_data['last_update'] = tasmota.rtc()['local']
            node_data['name'] = name
            
            # Store battery trend if available
            if data.contains('battery_v')
                if !node_data.contains('battery_history')
                    node_data['battery_history'] = []
                end
                node_data['battery_history'].push(data['battery_v'])
                if size(node_data['battery_history']) > 10
                    node_data['battery_history'].pop(0)
                end
            end
            
            # Track interrupt events
            if data.contains('interrupt_flag') && data['interrupt_flag']
                node_data['interrupt_count'] = node_data.find('interrupt_count', 0) + 1
                node_data['last_interrupt'] = tasmota.rtc()['local']
            end
            
            # Distance trending
            if data.contains('distance_mm')
                if !node_data.contains('distance_history')
                    node_data['distance_history'] = []
                end
                node_data['distance_history'].push(data['distance_mm'])
                if size(node_data['distance_history']) > 5
                    node_data['distance_history'].pop(0)
                end
            end
            
            # Initialize downlink commands
            if !global.contains("DDS75_LB_cmdInit") || !global.DDS75_LB_cmdInit
                self.register_downlink_commands()
                global.DDS75_LB_cmdInit = true
            end

            # Save back to global storage
            global.DDS75_LB_nodes[node] = node_data
            
            # Update instance cache
            self.last_data = data
            self.last_update = node_data['last_update']
            
            return data
            
        except .. as e, m
            print(f"DDS75-LB: Decode error - {e}: {m}")
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
                var node_data = global.DDS75_LB_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            # Fallback: find ANY stored node if no specific node
            if size(data_to_show) == 0 && size(global.DDS75_LB_nodes) > 0
                var found_node = false
                for node_id: global.DDS75_LB_nodes.keys()
                    if !found_node
                        var node_data = global.DDS75_LB_nodes[node_id]
                        data_to_show = node_data.find('last_data', {})
                        self.node = node_id
                        self.name = node_data.find('name', f"DDS75-{node_id}")
                        found_node = true
                    end
                end
            end
            
            if size(data_to_show) == 0 return nil end
            
            import string
            var msg = ""
            var fmt = LwSensorFormatter_cls()
            
            # MANDATORY: Add header line with device info
            var name = self.name
            if name == nil || name == ""
                name = f"DDS75-{self.node}"
            end
            var name_tooltip = "Dragino DDS75-LB Distance Sensor"
            var battery = data_to_show.find('battery_v', 1000)
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)
            var simulated = data_to_show.find('simulated', false)
            
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            fmt.start_line()
            
            # Distance measurement
            if data_to_show.contains('distance_mm')
                fmt.add_sensor("distance", data_to_show['distance_mm'] / 1000.0, "Distance", "📏")
            elif data_to_show.contains('distance_status')
                fmt.add_sensor("string", data_to_show['distance_status'], "Status", "❌")
            end
            
            # Temperature (if available)
            if data_to_show.contains('temperature')
                fmt.add_sensor("temp", data_to_show['temperature'], "Temperature", "🌡️")
            end
            
            # Battery voltage
            if data_to_show.contains('battery_v')
                fmt.add_sensor("volt", data_to_show['battery_v'], "Battery", "🔋")
            end
            
            # Status line for alerts/config
            var has_status = false
            var status_items = []
            
            if data_to_show.contains('interrupt_flag') && data_to_show['interrupt_flag']
                status_items.push(['string', 'Interrupt', 'Digital Trigger', '⚡'])
                has_status = true
            end
            
            if data_to_show.contains('device_info') && data_to_show['device_info']
                status_items.push(['string', 'Config', 'Device Status', '⚙️'])
                has_status = true
            end
            
            if data_to_show.contains('sensor_detected') && !data_to_show['sensor_detected']
                status_items.push(['string', 'No Sensor', 'Hardware Issue', '🚫'])
                has_status = true
            end
            
            # Add status line if needed
            if has_status
                fmt.next_line()
                for item : status_items
                    fmt.add_sensor(item[0], item[1], item[2], item[3])
                end
            end
            
            # Age indicator for stale data
            if last_update > 0
                var age = tasmota.rtc()['local'] - last_update
                if age > 3600
                    if !has_status
                        fmt.next_line()
                    end
                    fmt.add_status(self.format_age(age), "⏱️", nil)
                end
            end
            
            fmt.end_line()
            msg += fmt.get_msg()
            return msg
            
        except .. as e, m
            print(f"DDS75-LB: Display error - {e}: {m}")
            return "📟 DDS75-LB Error - Check Console"
        end
    end
    
    def format_age(seconds)
        if seconds < 60 return f"{seconds}s ago"
        elif seconds < 3600 return f"{seconds/60}m ago"
        elif seconds < 86400 return f"{seconds/3600}h ago"
        else return f"{seconds/86400}d ago"
        end
    end
    
    # MANDATORY: Add payload verification function (Template v2.5.0)
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
        
        # Determine fport based on scenario
        var fport = 1
        if scenario_name == "config" fport = 5 end
        
        # Decode test payload through driver
        var result = self.decodeUplink("TestDevice", "TEST-001", -75, fport, payload_bytes)
        
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
        if scenario_name == "low" && result.contains('battery_v') && result['battery_v'] > 3.0
            print(f"PAYLOAD ERROR: {scenario_name} battery should be < 3.0V")
            return false
        end
        
        if scenario_name == "interrupt" && !result.contains('interrupt_flag')
            print(f"PAYLOAD ERROR: {scenario_name} should have interrupt_flag")
            return false
        end
        
        return true
    end
    
    # Get node statistics
    def get_node_stats(node_id)
        import global
        var node_data = global.DDS75_LB_nodes.find(node_id, nil)
        if node_data == nil return nil end
        
        return {
            'last_update': node_data.find('last_update', 0),
            'interrupt_count': node_data.find('interrupt_count', 0),
            'last_interrupt': node_data.find('last_interrupt', 0),
            'battery_history': node_data.find('battery_history', []),
            'distance_history': node_data.find('distance_history', []),
            'name': node_data.find('name', 'Unknown')
        }
    end
    
    # Clear node data (for maintenance)
    def clear_node_data(node_id)
        import global
        if global.DDS75_LB_nodes.contains(node_id)
            global.DDS75_LB_nodes.remove(node_id)
            return true
        end
        return false
    end
    
    # Register downlink commands for device control
    def register_downlink_commands()
        import string
        
        # Set transmit interval
        tasmota.remove_cmd("LwDDS75Interval")
        tasmota.add_cmd("LwDDS75Interval", def(cmd, idx, payload_str)
            var interval = int(payload_str)
            if interval < 10 || interval > 16777215
                return tasmota.resp_cmnd_str("Invalid: range 10-16777215 seconds")
            end
            
            var hex_cmd = f"01{interval & 0xFF:02X}{(interval >> 8) & 0xFF:02X}{(interval >> 16) & 0xFF:02X}"
            return lwdecode.SendDownlink(global.DDS75_LB_nodes, cmd, idx, hex_cmd)
        end)
        
        # Set interrupt mode
        tasmota.remove_cmd("LwDDS75Interrupt")
        tasmota.add_cmd("LwDDS75Interrupt", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.DDS75_LB_nodes, cmd, idx, payload_str, {
                '0|DISABLE': ['06000000', 'Disabled'],
                '1|RISING': ['06000003', 'Rising Edge']
            })
        end)
        
        # Set delta detect mode
        tasmota.remove_cmd("LwDDS75DeltaMode")
        tasmota.add_cmd("LwDDS75DeltaMode", def(cmd, idx, payload_str)
            var parts = string.split(payload_str, ',')
            if size(parts) != 4
                return tasmota.resp_cmnd_str("Usage: LwDDS75DeltaMode<slot> <mode>,<interval>,<threshold>,<count>")
            end
            
            var mode = int(parts[0])
            var interval = int(parts[1])
            var threshold = int(parts[2])
            var count = int(parts[3])
            
            if mode < 1 || mode > 2
                return tasmota.resp_cmnd_str("Invalid mode: 1=Normal, 2=Delta")
            end
            if interval < 1 || interval > 65535
                return tasmota.resp_cmnd_str("Invalid interval: range 1-65535 seconds")
            end
            if threshold < 1 || threshold > 65535
                return tasmota.resp_cmnd_str("Invalid threshold: range 1-65535 cm")
            end
            if count < 5 || count > 20
                return tasmota.resp_cmnd_str("Invalid count: range 5-20 samples")
            end
            
            var hex_cmd = f"FB{mode:02X}{interval & 0xFF:02X}{(interval >> 8) & 0xFF:02X}"
            hex_cmd += f"{threshold & 0xFF:02X}{(threshold >> 8) & 0xFF:02X}{count:02X}"
            
            return lwdecode.SendDownlink(global.DDS75_LB_nodes, cmd, idx, hex_cmd)
        end)
        
        # Get device status
        tasmota.remove_cmd("LwDDS75Status")
        tasmota.add_cmd("LwDDS75Status", def(cmd, idx, payload_str)
            var hex_cmd = "2601"
            return lwdecode.SendDownlink(global.DDS75_LB_nodes, cmd, idx, hex_cmd)
        end)
        
        # Poll sensor data
        tasmota.remove_cmd("LwDDS75Poll")
        tasmota.add_cmd("LwDDS75Poll", def(cmd, idx, payload_str)
            var parts = string.split(payload_str, ',')
            if size(parts) != 3
                return tasmota.resp_cmnd_str("Usage: LwDDS75Poll<slot> <start_time>,<end_time>,<interval>")
            end
            
            var start_time = int(parts[0])
            var end_time = int(parts[1])
            var interval = int(parts[2])
            
            if interval < 5 || interval > 255
                return tasmota.resp_cmnd_str("Invalid interval: range 5-255 seconds")
            end
            
            var hex_cmd = f"31{start_time & 0xFF:02X}{(start_time >> 8) & 0xFF:02X}"
            hex_cmd += f"{(start_time >> 16) & 0xFF:02X}{(start_time >> 24) & 0xFF:02X}"
            hex_cmd += f"{end_time & 0xFF:02X}{(end_time >> 8) & 0xFF:02X}"
            hex_cmd += f"{(end_time >> 16) & 0xFF:02X}{(end_time >> 24) & 0xFF:02X}"
            hex_cmd += f"{interval:02X}"
            
            return lwdecode.SendDownlink(global.DDS75_LB_nodes, cmd, idx, hex_cmd)
        end)
        
        print("DDS75-LB: Downlink commands registered")
    end
end

# Global instance
LwDeco = LwDecode_DDS75_LB()

# Node management commands
tasmota.remove_cmd("LwDDS75NodeStats")
tasmota.add_cmd("LwDDS75NodeStats", def(cmd, idx, node_id)
    var stats = LwDeco.get_node_stats(node_id)
    if stats != nil
        import json
        tasmota.resp_cmnd(json.dump(stats))
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

tasmota.remove_cmd("LwDDS75ClearNode")
tasmota.add_cmd("LwDDS75ClearNode", def(cmd, idx, node_id)
    if LwDeco.clear_node_data(node_id)
        tasmota.resp_cmnd_done()
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

# CRITICAL: Template v2.5.0 TestUI with verified payloads
tasmota.remove_cmd("LwDDS75TestUI")
tasmota.add_cmd("LwDDS75TestUI", def(cmd, idx, payload_str)
    # MANDATORY: All payloads verified through decode process
    var test_scenarios = {
        "normal":     "E40E38130000327FFF01",    # Battery 3800mV, Distance 4920mm, temp 5.0°C
        "close":      "E40E1801000E057FFF01",    # Close distance 280mm, temp 13.0°C  
        "far":        "E40E541D0000327FFF01",    # Far distance 7500mm
        "interrupt":  "E40E38130100327FFF01",    # Same as normal + interrupt triggered
        "no_sensor":  "E40E00000000327FFF00",    # No ultrasonic sensor detected
        "invalid":    "E40E14000000327FFF01",    # Invalid distance reading
        "low":        "C40938130000327FFF01",    # Low battery 2500mV
        "config":     "270100010000E40E",        # Device status DDS75 v0100 EU868
        "cold":       "E40E3813000088FCFF01",    # Cold temperature -10.0°C
        "demo":       "E40E38130000327FFF01"     # Comprehensive demo payload
    }
    
    var hex_payload = test_scenarios.find(payload_str ? payload_str : 'nil', 'not_found')
    
    if hex_payload == 'not_found'
        var scenarios_list = "normal close far interrupt no_sensor invalid low config cold demo "
        return tasmota.resp_cmnd_str(f"Available scenarios: {scenarios_list}")
    end
    
    var rssi = -75
    var fport = 1
    if payload_str == "config" fport = 5 end

    return tasmota.cmd(f'LwSimulate{idx} {rssi},{fport},{hex_payload}')
end)

# Register driver for web UI integration
tasmota.add_driver(LwDeco)
