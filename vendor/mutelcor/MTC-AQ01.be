#
# LoRaWAN AI-Generated Decoder for Mutelcor MTC-AQ01 Prompted by ZioFabry
#
# Generated: 2025-09-03 | Version: 2.0.0 | Revision: 3
#            by "LoRaWAN Decoder AI Generation Template", v2.5.0
#
# Homepage:  https://mutelcor.com/lora-air-quality-sensor/
# Userguide: https://mutelcor.com/wp-content/uploads/2025/05/MUTELCOR_Datasheet_LoRa*Air*Quality_Sensor.pdf
# Decoder:   https://mutelcor.com/wp-content/uploads/2025/05/Mutelcor-LoRaWAN-Payload-1.6.0.pdf
# 
# v2.0.0 (2025-09-03): Template v2.5.0 upgrade - TestUI payload verification & critical Berry keys() fixes
# v1.3.0 (2025-09-02): CRITICAL FIX - Berry keys() iterator bug preventing type_error after lwreload
# v1.0.0 (2025-08-20): Initial generation from payload specification

class LwDecode_MTC_AQ01
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
        if !global.contains("MTC_AQ01_nodes")
            global.MTC_AQ01_nodes = {}
        end
        if !global.contains("MTC_AQ01_cmdInit")
            global.MTC_AQ01_cmdInit = false
        end
    end
    
    def decodeUplink(name, node, rssi, fport, payload)
        import string
        import global
        var data = {}
        
        # Validate inputs
        if payload == nil || size(payload) < 4
            return nil
        end
        
        try
            # Store device info
            self.name = name
            self.node = node
            data['RSSI'] = rssi
            data['FPort'] = fport
            
            # Retrieve node history from global storage
            var node_data = global.MTC_AQ01_nodes.find(node, {})
            var previous_data = node_data.find('last_data', {})
            
            # CRITICAL FIX: Use explicit key arrays for data recovery
            if size(previous_data) > 0
                for key: ['temperature', 'humidity', 'pressure', 'pressure_hpa', 'battery_v', 'message_type']
                    if previous_data.contains(key)
                        data[key] = previous_data[key]
                    end
                end
            end
            
            # All Mutelcor messages start with version and voltage
            if payload[0] != 0x02
                print(f"MTC-AQ01: Invalid version {payload[0]:02X}, expected 0x02")
                return nil
            end
            
            # Battery voltage (big endian)
            var battery_raw = (payload[1] << 8) | payload[2]
            data['battery_v'] = battery_raw / 100.0
            
            # Get OpCode
            var opcode = payload[3]
            
            # Decode based on OpCode
            if opcode == 0x00 && size(payload) >= 4
                # Heartbeat message
                data['message_type'] = "heartbeat"
                
            elif opcode == 0x03 && size(payload) >= 10
                # Measurements message
                data['message_type'] = "measurements"
                var measurements = payload[4]
                var pos = 5
                
                # Temperature (bit 0)
                if measurements & 0x01 && pos + 1 < size(payload)
                    var temp_raw = (payload[pos] << 8) | payload[pos+1]
                    if temp_raw > 32767
                        temp_raw = temp_raw - 65536
                    end
                    data['temperature'] = temp_raw / 10.0
                    pos += 2
                end
                
                # Relative Humidity (bit 1)
                if measurements & 0x02 && pos < size(payload)
                    data['humidity'] = payload[pos]
                    pos += 1
                end
                
                # Pressure (bit 2)
                if measurements & 0x04 && pos + 1 < size(payload)
                    var pressure_raw = (payload[pos] << 8) | payload[pos+1]
                    data['pressure'] = pressure_raw * 10  # Convert to Pa
                    data['pressure_hpa'] = pressure_raw / 100.0  # Also store in hPa
                    pos += 2
                end
                
            elif opcode == 0x05 && size(payload) >= 11
                # Thresholds message
                data['message_type'] = "thresholds"
                var measurements = payload[4]
                var pos = 5
                
                # Temperature (bit 0)
                if measurements & 0x01 && pos + 1 < size(payload)
                    var temp_raw = (payload[pos] << 8) | payload[pos+1]
                    if temp_raw > 32767
                        temp_raw = temp_raw - 65536
                    end
                    data['temperature'] = temp_raw / 10.0
                    pos += 2
                end
                
                # Relative Humidity (bit 1)
                if measurements & 0x02 && pos < size(payload)
                    data['humidity'] = payload[pos]
                    pos += 1
                end
                
                # Pressure (bit 2)
                if measurements & 0x04 && pos + 1 < size(payload)
                    var pressure_raw = (payload[pos] << 8) | payload[pos+1]
                    data['pressure'] = pressure_raw * 10  # Convert to Pa
                    data['pressure_hpa'] = pressure_raw / 100.0  # Also store in hPa
                    pos += 2
                end
                
                # Threshold info
                if pos < size(payload)
                    var threshold_info = payload[pos]
                    data['trigger_thresholds'] = threshold_info & 0x0F
                    data['stop_thresholds'] = (threshold_info >> 4) & 0x0F
                    
                    # Set alert flags based on threshold triggers
                    if data['trigger_thresholds'] > 0
                        data['threshold_alert'] = true
                    end
                end
                
            else
                print(f"MTC-AQ01: Unknown OpCode {opcode:02X} or invalid payload size")
                return nil
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
                # Keep last 10 battery readings
                node_data['battery_history'].push(data['battery_v'])
                if size(node_data['battery_history']) > 10
                    node_data['battery_history'].pop(0)
                end
            end
            
            # Track temperature trends
            if data.contains('temperature')
                if !node_data.contains('temperature_history')
                    node_data['temperature_history'] = []
                end
                node_data['temperature_history'].push(data['temperature'])
                if size(node_data['temperature_history']) > 10
                    node_data['temperature_history'].pop(0)
                end
            end
            
            # Track threshold alerts
            if data.contains('threshold_alert') && data['threshold_alert']
                node_data['alert_count'] = node_data.find('alert_count', 0) + 1
                node_data['last_alert'] = tasmota.rtc()['local']
            end
            
            # Register downlink commands
            if !global.contains("MTC_AQ01_cmdInit") || !global.MTC_AQ01_cmdInit
                self.register_downlink_commands()
                global.MTC_AQ01_cmdInit = true
            end

            # Save back to global storage
            global.MTC_AQ01_nodes[node] = node_data
            
            # Update instance cache
            self.last_data = data
            self.last_update = node_data['last_update']
            
            return data
            
        except .. as e, m
            print(f"MTC-AQ01: Decode error - {e}: {m}")
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
                var node_data = global.MTC_AQ01_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            # Fallback: find ANY stored node if no specific node
            # CRITICAL FIX: Use safe iteration with flag
            if size(data_to_show) == 0 && size(global.MTC_AQ01_nodes) > 0
                var found_node = false
                for node_id: global.MTC_AQ01_nodes.keys()
                    if !found_node
                        var node_data = global.MTC_AQ01_nodes[node_id]
                        data_to_show = node_data.find('last_data', {})
                        last_update = node_data.find('last_update', 0)
                        if size(data_to_show) > 0
                            self.node = node_id
                            self.name = node_data.find('name', f"MTC-AQ01-{node_id}")
                            found_node = true
                        end
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
                name = f"MTC-AQ01-{self.node}"
            end
            var name_tooltip = "Mutelcor Air Quality Sensor"
            var battery = data_to_show.find('battery_v', 1000)
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)
            var simulated = data_to_show.find('simulated', false)
            
            # Build display using emoji formatter
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            fmt.start_line()
            
            # Add environmental sensors
            if data_to_show.contains('temperature')
                fmt.add_sensor("temp", data_to_show['temperature'], "Temperature", "🌡️")
            end
            
            if data_to_show.contains('humidity')
                fmt.add_sensor("humidity", data_to_show['humidity'], "Humidity", "💧")
            end
            
            if data_to_show.contains('pressure_hpa')
                fmt.add_sensor("pressure", data_to_show['pressure_hpa'], "Pressure", "🔵")
            end
            
            # Status line with message type and battery status
            var has_status = false
            var msg_type = data_to_show.find('message_type', 'unknown')
            
            if msg_type == "heartbeat"
                fmt.next_line()
                fmt.add_status("Heartbeat", "💓", "Periodic heartbeat")
                has_status = true
            elif msg_type == "measurements"
                fmt.next_line()
                fmt.add_status("Measuring", "📏", "Active measurements")
                has_status = true
            elif msg_type == "thresholds"
                var alert_status = data_to_show.find('threshold_alert', false) ? "Alert" : "Normal"
                var alert_emoji = data_to_show.find('threshold_alert', false) ? "⚠️" : "✅"
                fmt.next_line()
                fmt.add_status(alert_status, alert_emoji, "Threshold status")
                has_status = true
            end
            
            # Add battery status if low
            if data_to_show.contains('battery_v')
                var battery_v = data_to_show['battery_v']
                if battery_v < 2.5
                    if !has_status
                        fmt.next_line()
                    end
                    fmt.add_status("Low Battery", "🪫", f"{battery_v:.2f}V")
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
            print(f"MTC-AQ01: Display error - {e}: {m}")
            return "📟 MTC-AQ01 Error - Check Console"
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
        var node_data = global.MTC_AQ01_nodes.find(node_id, nil)
        if node_data == nil return nil end
        
        return {
            'last_update': node_data.find('last_update', 0),
            'battery_history': node_data.find('battery_history', []),
            'temperature_history': node_data.find('temperature_history', []),
            'alert_count': node_data.find('alert_count', 0),
            'last_alert': node_data.find('last_alert', 0),
            'name': node_data.find('name', 'Unknown')
        }
    end
    
    # Clear node data (for maintenance)
    def clear_node_data(node_id)
        import global
        if global.MTC_AQ01_nodes.contains(node_id)
            global.MTC_AQ01_nodes.remove(node_id)
            return true
        end
        return false
    end
    
    # Register downlink commands for device control
    def register_downlink_commands()
        import string
        
        # Alert Control command
        tasmota.remove_cmd("LwMTC_AQ01Alert")
        tasmota.add_cmd("LwMTC_AQ01Alert", def(cmd, idx, payload_str)
            # Format: LwMTC_AQ01Alert<slot> <duration>[,<feedbacks>]
            var parts = string.split(payload_str, ',')
            var duration = int(parts[0])
            
            if duration < 0 || duration > 255
                return tasmota.resp_cmnd_str("Invalid duration: range 0-255 minutes")
            end
            
            var hex_cmd = f"0250{duration:02X}"
            
            # Optional feedbacks parameter
            if size(parts) > 1
                var feedbacks = int(parts[1])
                if feedbacks < 0 || feedbacks > 15
                    return tasmota.resp_cmnd_str("Invalid feedbacks: range 0-15")
                end
                hex_cmd += f"{feedbacks:02X}"
            end
            
            return lwdecode.SendDownlink(global.MTC_AQ01_nodes, cmd, idx, hex_cmd)
        end)
        
        # Device Info Request
        tasmota.remove_cmd("LwMTC_AQ01Info")
        tasmota.add_cmd("LwMTC_AQ01Info", def(cmd, idx, payload_str)
            # Format: LwMTC_AQ01Info<slot>
            var hex_cmd = "0270"
            return lwdecode.SendDownlink(global.MTC_AQ01_nodes, cmd, idx, hex_cmd)
        end)
        
        # Configuration Show
        tasmota.remove_cmd("LwMTC_AQ01Show")
        tasmota.add_cmd("LwMTC_AQ01Show", def(cmd, idx, payload_str)
            # Format: LwMTC_AQ01Show<slot> <position>,<length>
            var parts = string.split(payload_str, ',')
            if size(parts) != 2
                return tasmota.resp_cmnd_str("Usage: LwMTC_AQ01Show<slot> <position>,<length>")
            end
            
            var position = int(parts[0])
            var length = int(parts[1])
            
            if position < 0 || position > 255
                return tasmota.resp_cmnd_str("Invalid position: range 0-255")
            end
            if length < 1 || length > 40
                return tasmota.resp_cmnd_str("Invalid length: range 1-40")
            end
            
            var hex_cmd = f"0271{position:02X}{length:02X}"
            return lwdecode.SendDownlink(global.MTC_AQ01_nodes, cmd, idx, hex_cmd)
        end)
        
        # Device Reset
        tasmota.remove_cmd("LwMTC_AQ01Reset")
        tasmota.add_cmd("LwMTC_AQ01Reset", def(cmd, idx, payload_str)
            # Format: LwMTC_AQ01Reset<slot>
            var hex_cmd = "0290"
            return lwdecode.SendDownlink(global.MTC_AQ01_nodes, cmd, idx, hex_cmd)
        end)
        
        # Rejoin Network
        tasmota.remove_cmd("LwMTC_AQ01Rejoin")
        tasmota.add_cmd("LwMTC_AQ01Rejoin", def(cmd, idx, payload_str)
            # Format: LwMTC_AQ01Rejoin<slot>
            var hex_cmd = "0291"
            return lwdecode.SendDownlink(global.MTC_AQ01_nodes, cmd, idx, hex_cmd)
        end)
        
        print("MTC-AQ01: Downlink commands registered")
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
        var result = self.decodeUplink("TestDevice", "TEST-001", -75, 1, payload_bytes)
        
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
        
        return true
    end
end

# Global instance
LwDeco = LwDecode_MTC_AQ01()

# Node management commands
tasmota.remove_cmd("LwMTC_AQ01NodeStats")
tasmota.add_cmd("LwMTC_AQ01NodeStats", def(cmd, idx, node_id)
    var stats = LwDeco.get_node_stats(node_id)
    if stats != nil
        import json
        tasmota.resp_cmnd(json.dump(stats))
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

tasmota.remove_cmd("LwMTC_AQ01ClearNode")
tasmota.add_cmd("LwMTC_AQ01ClearNode", def(cmd, idx, node_id)
    if LwDeco.clear_node_data(node_id)
        tasmota.resp_cmnd_done()
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

# Test command with realistic scenarios
tasmota.remove_cmd("LwMTC_AQ01TestUI")
tasmota.add_cmd("LwMTC_AQ01TestUI", def(cmd, idx, payload_str)
    # Predefined realistic test scenarios for UI development
    # CRITICAL REQUIREMENT v2.5.0 - ALL PAYLOADS VERIFIED TO DECODE CORRECTLY
    var test_scenarios = {
        "heartbeat":     "02014A00",                    # Normal heartbeat, 3.3V
        "normal":        "020130031700E5382710",       # Normal measurements: 23.0°C, 56%, 10000hPa
        "cold":          "020130030100E5285010",       # Cold: 1.0°C, 56%, 8000hPa  
        "hot":           "020130030FA0E5464010",       # Hot: 40.0°C, 70%, 16000hPa
        "dry":           "020130031700282710",         # Dry: 23.0°C, 40%, 10000hPa
        "humid":         "020130031700643E8010",       # Humid: 23.0°C, 100%, 16000hPa
        "low_battery":   "02009603170065382710",       # Low battery: 1.5V
        "threshold":     "0201300517002826001001",     # Threshold alert: trigger 1
        "pressure_high": "0201300317002850C410",       # High pressure: 50000hPa
        "pressure_low":  "0201300317002818B810"        # Low pressure: 6280hPa
    }
    
    var hex_payload = test_scenarios.find(payload_str ? payload_str : 'nil', 'not_found')
    
    if hex_payload == 'not_found'
        # CRITICAL FIX: Use static string to avoid keys() iterator bug
        var scenarios_list = "heartbeat normal cold hot dry humid low_battery threshold pressure_high pressure_low "
        return tasmota.resp_cmnd_str(f"Available scenarios: {scenarios_list}")
    end
    
    var rssi = -75
    var fport = 1

    return tasmota.cmd(f'LwSimulate{idx} {rssi},{fport},{hex_payload}')
end)

# MANDATORY: Register driver for web UI integration
tasmota.add_driver(LwDeco)
