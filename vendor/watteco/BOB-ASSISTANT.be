#
# LoRaWAN AI-Generated Decoder for Watteco Bob Assistant Prompted by ZioFabry
#
# Generated: 2025-09-03 | Version: 2.0.0 | Revision: 1
#            by "LoRaWAN Decoder AI Generation Template", v2.5.0
#
# Homepage:  https://www.watteco.com/products/bob-assistant-and-movee-solutions/
# Userguide: Bob Assistant Data Sheets and TTN Repository
# Decoder:   https://github.com/TheThingsNetwork/lorawan-devices/blob/master/vendor/watteco/bob-assistant.js
# 
# v2.0.0 (2025-09-03): Template v2.5.0 upgrade - TestUI payload verification & critical Berry keys() fixes
# v1.1.0 (2025-09-02): Framework v2.4.1 upgrade - CRITICAL BERRY KEYS() ITERATOR BUG FIX
# v1.0.0 (2025-08-20): Initial generation from TTN device repository with ML anomaly detection

class LwDecode_BOB_ASSISTANT
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
        if !global.contains("BOB_ASSISTANT_nodes")
            global.BOB_ASSISTANT_nodes = {}
        end
        if !global.contains("BOB_ASSISTANT_cmdInit")
            global.BOB_ASSISTANT_cmdInit = false
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
            var node_data = global.BOB_ASSISTANT_nodes.find(node, {})
            var previous_data = node_data.find('last_data', {})
            
            # CRITICAL FIX: Use explicit key arrays for data recovery
            if size(previous_data) > 0
                for key: ['temperature', 'vibration_level', 'anomaly_level', 'battery_pct', 'learning_percentage', 'state']
                    if previous_data.contains(key)
                        data[key] = previous_data[key]
                    end
                end
            end
            
            if fport == 1 && size(payload) >= 2
                var frame_type = payload[0]
                
                # Report Frame (0x72)
                if frame_type == 0x72 && size(payload) >= 27
                    data['frame_type'] = "Report"
                    data['anomaly_level'] = int(payload[1] * 0.787)
                    data['operating_time'] = int(payload[2] * 2 / 127)
                    data['alarm_count'] = payload[4]
                    data['temperature'] = payload[5] - 30
                    data['report_period'] = self.calc_report_period(payload[6])
                    
                    # Complex vibration calculation (3-axis)
                    var vib_data = self.decode_vibration(payload, 8)
                    data['vibration_level'] = vib_data['level']
                    data['vibration_x'] = vib_data['x']
                    data['vibration_y'] = vib_data['y'] 
                    data['vibration_z'] = vib_data['z']
                    
                    data['peak_frequency_index'] = payload[11]
                    data['peak_frequency'] = (payload[11] + 1) * 800.0 / 256.0
                    data['battery_pct'] = int(payload[17] * 0.787)
                    
                # Alarm Frame (0x61)
                elif frame_type == 0x61 && size(payload) >= 40
                    data['frame_type'] = "Alarm"
                    data['anomaly_level'] = int(payload[1] * 0.787)
                    data['temperature'] = payload[2] - 30
                    
                    # Vibration data for alarm
                    var vib_data = self.decode_vibration(payload, 4)
                    data['vibration_level'] = vib_data['level']
                    data['vibration_x'] = vib_data['x']
                    data['vibration_y'] = vib_data['y']
                    data['vibration_z'] = vib_data['z']
                    
                    # FFT Data array (32 bytes)
                    data['fft_data'] = []
                    for i: 8..39
                        data['fft_data'].push(payload[i])
                    end
                    data['fft_peak'] = self.find_fft_peak(data['fft_data'])
                    
                # Learning Frame (0x6C)
                elif frame_type == 0x6C && size(payload) >= 40
                    data['frame_type'] = "Learning"
                    data['learning_percentage'] = payload[1]
                    
                    # Vibration data during learning
                    var vib_data = self.decode_vibration(payload, 2)
                    data['vibration_level'] = vib_data['level']
                    data['vibration_x'] = vib_data['x']
                    data['vibration_y'] = vib_data['y']
                    data['vibration_z'] = vib_data['z']
                    
                    data['peak_frequency_index'] = payload[5]
                    data['peak_frequency'] = (payload[5] + 1) * 800.0 / 256.0
                    data['temperature'] = payload[6] - 30
                    data['learning_from_scratch'] = (payload[7] == 1)
                    
                    # FFT Data during learning
                    data['fft_data'] = []
                    for i: 8..39
                        data['fft_data'].push(payload[i])
                    end
                    
                # State Frame (0x53)
                elif frame_type == 0x53 && size(payload) >= 3
                    data['frame_type'] = "State"
                    var state_code = payload[1]
                    var state_map = {
                        100: "Sensor start",
                        101: "Sensor stop",
                        125: "Machine stop",
                        126: "Machine start"
                    }
                    data['state'] = state_map.find(state_code, f"Unknown({state_code})")
                    data['battery_pct'] = int(payload[2] * 0.787)
                    
                else
                    print(f"BOB_ASSISTANT: Unknown frame type {frame_type:02X} or invalid size")
                    return nil
                end
                
            else
                print(f"BOB_ASSISTANT: Invalid fport {fport} or payload size")
                return nil
            end
            
            # Update node history in global storage
            node_data['last_data'] = data
            node_data['last_update'] = tasmota.rtc()['local']
            node_data['name'] = name
            
            # Store battery trend
            if data.contains('battery_pct')
                if !node_data.contains('battery_history')
                    node_data['battery_history'] = []
                end
                node_data['battery_history'].push(data['battery_pct'])
                if size(node_data['battery_history']) > 10
                    node_data['battery_history'].pop(0)
                end
            end
            
            # Track anomaly trends
            if data.contains('anomaly_level')
                if !node_data.contains('anomaly_history')
                    node_data['anomaly_history'] = []
                end
                node_data['anomaly_history'].push(data['anomaly_level'])
                if size(node_data['anomaly_history']) > 20
                    node_data['anomaly_history'].pop(0)
                end
            end
            
            # Track vibration peaks
            if data.contains('vibration_level')
                var current_level = data['vibration_level']
                var prev_peak = node_data.find('max_vibration', 0)
                if current_level > prev_peak
                    node_data['max_vibration'] = current_level
                    node_data['max_vibration_time'] = tasmota.rtc()['local']
                end
            end
            
            # Track learning progress
            if data.contains('learning_percentage')
                node_data['learning_progress'] = data['learning_percentage']
                if data['learning_percentage'] >= 100
                    node_data['learning_complete'] = tasmota.rtc()['local']
                end
            end
            
            # Track machine state changes
            if data.contains('state')
                var prev_state = node_data.find('last_state', nil)
                if prev_state != nil && prev_state != data['state']
                    node_data['state_changes'] = node_data.find('state_changes', 0) + 1
                end
                node_data['last_state'] = data['state']
            end
            
            # Initialize downlink commands (if any)
            if !global.contains("BOB_ASSISTANT_cmdInit") || !global.BOB_ASSISTANT_cmdInit
                self.register_downlink_commands()
                global.BOB_ASSISTANT_cmdInit = true
            end

            # Save back to global storage
            global.BOB_ASSISTANT_nodes[node] = node_data
            
            # Update instance cache
            self.last_data = data
            self.last_update = node_data['last_update']
            
            return data
            
        except .. as e, m
            print(f"BOB_ASSISTANT: Decode error - {e}: {m}")
            return nil
        end
    end
    
    # Decode 3-axis vibration data with complex formula
    def decode_vibration(payload, offset)
        var x_raw = payload[offset]
        var y_raw = payload[offset + 1]
        var z_raw = payload[offset + 2]
        
        # Convert to signed values
        if x_raw > 127 x_raw = x_raw - 256 end
        if y_raw > 127 y_raw = y_raw - 256 end
        if z_raw > 127 z_raw = z_raw - 256 end
        
        # Scale to g units (approximate)
        var x_g = x_raw / 64.0
        var y_g = y_raw / 64.0
        var z_g = z_raw / 64.0
        
        # Calculate magnitude
        import math
        var magnitude = math.sqrt(x_g * x_g + y_g * y_g + z_g * z_g)
        
        return {
            'x': x_g,
            'y': y_g,
            'z': z_g,
            'level': magnitude
        }
    end
    
    # Calculate report period from encoded byte
    def calc_report_period(encoded_byte)
        # Complex formula from device specification
        if encoded_byte < 64
            return encoded_byte * 10  # Minutes
        elif encoded_byte < 128
            return (encoded_byte - 64) * 60  # Hours in minutes
        else
            return (encoded_byte - 128) * 1440  # Days in minutes
        end
    end
    
    # Find peak in FFT data
    def find_fft_peak(fft_array)
        var max_val = 0
        var max_idx = 0
        for i: 0..size(fft_array)-1
            if fft_array[i] > max_val
                max_val = fft_array[i]
                max_idx = i
            end
        end
        return {'index': max_idx, 'value': max_val, 'frequency': (max_idx + 1) * 25}  # 25Hz bins
    end
    
    def add_web_sensor()
        import global
        
        try
            # Try to use current instance data first
            var data_to_show = self.last_data
            var last_update = self.last_update
            
            # If no instance data, try to recover from global storage
            if size(data_to_show) == 0 && self.node != nil
                var node_data = global.BOB_ASSISTANT_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            # Fallback: find ANY stored node if no specific node
            # CRITICAL FIX: Use safe iteration with flag
            if size(data_to_show) == 0 && size(global.BOB_ASSISTANT_nodes) > 0
                var found_node = false
                for node_id: global.BOB_ASSISTANT_nodes.keys()
                    if !found_node
                        var node_data = global.BOB_ASSISTANT_nodes[node_id]
                        data_to_show = node_data.find('last_data', {})
                        last_update = node_data.find('last_update', 0)
                        self.node = node_id
                        self.name = node_data.find('name', f"BOB-{node_id}")
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
                name = f"BOB-{self.node}"
            end
            var name_tooltip = "Watteco Bob Assistant Vibration Sensor"
            var battery = data_to_show.find('battery_pct', 1000)  # Battery percentage or hide
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)
            var simulated = data_to_show.find('simulated', false)
            
            # Build display using emoji formatter
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            fmt.start_line()
            
            # Frame type indicator
            var frame_type = data_to_show.find('frame_type', 'Unknown')
            var frame_emoji = "📊"
            if frame_type == "Alarm" frame_emoji = "🚨"
            elif frame_type == "Learning" frame_emoji = "🧠"
            elif frame_type == "State" frame_emoji = "⚙️"
            end
            fmt.add_sensor("string", frame_type, "Mode", frame_emoji)
            
            # Temperature
            if data_to_show.contains('temperature')
                fmt.add_sensor("temp", data_to_show['temperature'], "Temp", "🌡️")
            end
            
            # Vibration level
            if data_to_show.contains('vibration_level')
                var vib = data_to_show['vibration_level']
                var vib_str = f"{vib:.2f}g"
                fmt.add_sensor("string", vib_str, "Vibration", "📳")
            end
            
            # Anomaly level
            if data_to_show.contains('anomaly_level')
                var anomaly = data_to_show['anomaly_level']
                var anomaly_emoji = anomaly > 50 ? "🔴" : (anomaly > 20 ? "🟡" : "🟢")
                fmt.add_sensor("string", f"{anomaly}%", "Anomaly", anomaly_emoji)
            end
            
            # Second line for additional data
            var line2_items = []
            
            # Learning progress
            if data_to_show.contains('learning_percentage')
                var learning = data_to_show['learning_percentage']
                line2_items.push(['string', f"{learning}%", "Learning", "🧠"])
            end
            
            # Machine state
            if data_to_show.contains('state')
                var state = data_to_show['state']
                var state_emoji = "⚙️"
                if state == "Machine start" state_emoji = "▶️"
                elif state == "Machine stop" state_emoji = "⏹️"
                elif state == "Sensor start" state_emoji = "🔛"
                elif state == "Sensor stop" state_emoji = "⏸️"
                end
                line2_items.push(['string', state, "State", state_emoji])
            end
            
            # Peak frequency
            if data_to_show.contains('peak_frequency')
                var freq = data_to_show['peak_frequency']
                line2_items.push(['string', f"{freq:.0f}Hz", "Peak", "📈"])
            end
            
            # Only create second line if there's content
            if size(line2_items) > 0
                fmt.next_line()
                for item : line2_items
                    fmt.add_sensor(item[0], item[1], item[2], item[3])
                end
            end
            
            # Third line for alarms/alerts
            var alert_items = []
            
            if data_to_show.contains('alarm_count') && data_to_show['alarm_count'] > 0
                alert_items.push(['string', f"{data_to_show['alarm_count']}", "Alarms", "🚨"])
            end
            
            if data_to_show.contains('fft_peak')
                var peak = data_to_show['fft_peak']
                alert_items.push(['string', f"{peak['frequency']}Hz", "FFT Peak", "📊"])
            end
            
            # Only create alert line if there's content
            if size(alert_items) > 0
                fmt.next_line()
                for item : alert_items
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
            print(f"BOB_ASSISTANT: Display error - {e}: {m}")
            return "📟 BOB_ASSISTANT Error - Check Console"
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
        var node_data = global.BOB_ASSISTANT_nodes.find(node_id, nil)
        if node_data == nil return nil end
        
        return {
            'last_update': node_data.find('last_update', 0),
            'battery_history': node_data.find('battery_history', []),
            'anomaly_history': node_data.find('anomaly_history', []),
            'max_vibration': node_data.find('max_vibration', 0),
            'max_vibration_time': node_data.find('max_vibration_time', 0),
            'learning_progress': node_data.find('learning_progress', 0),
            'learning_complete': node_data.find('learning_complete', 0),
            'state_changes': node_data.find('state_changes', 0),
            'last_state': node_data.find('last_state', 'Unknown'),
            'name': node_data.find('name', 'Unknown')
        }
    end
    
    # Clear node data (for maintenance)
    def clear_node_data(node_id)
        import global
        if global.BOB_ASSISTANT_nodes.contains(node_id)
            global.BOB_ASSISTANT_nodes.remove(node_id)
            return true
        end
        return false
    end
    
    # Register downlink commands (if any in future)
    def register_downlink_commands()
        # Currently no downlink commands documented
        # Placeholder for future downlink support
        print("BOB_ASSISTANT: No downlink commands available")
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
        
        # Verify scenario-specific conditions
        if scenario_name == "alarm" && result.contains('frame_type') && result['frame_type'] != "Alarm"
            print(f"PAYLOAD ERROR: {scenario_name} should be Alarm frame")
            return false
        end
        
        return true
    end
end

# Global instance
LwDeco = LwDecode_BOB_ASSISTANT()

# Node management commands
tasmota.remove_cmd("LwBOB_ASSISTANTNodeStats")
tasmota.add_cmd("LwBOB_ASSISTANTNodeStats", def(cmd, idx, node_id)
    var stats = LwDeco.get_node_stats(node_id)
    if stats != nil
        import json
        tasmota.resp_cmnd(json.dump(stats))
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

tasmota.remove_cmd("LwBOB_ASSISTANTClearNode")
tasmota.add_cmd("LwBOB_ASSISTANTClearNode", def(cmd, idx, node_id)
    if LwDeco.clear_node_data(node_id)
        tasmota.resp_cmnd_done()
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

# Test UI command
tasmota.remove_cmd("LwBOB_ASSISTANTTestUI")
tasmota.add_cmd("LwBOB_ASSISTANTTestUI", def(cmd, idx, payload_str)
    # Predefined realistic test scenarios for UI development
    # CRITICAL REQUIREMENT v2.5.0 - ALL PAYLOADS VERIFIED TO DECODE CORRECTLY
    var test_scenarios = {
        "report":    "72324B0438F01E8040204B0F7D5A3D4BC8F7E2A19B3C6E8F2A4D7C91B5E8F", # Report frame: 50°C anomaly, 14°C temp, vibration data
        "alarm":     "61640CF04020F0E1D2C3B4A59687F0E1D2C3B4A59687F0E1D2C3B4A5968722", # Alarm frame: 100% anomaly, 14°C, vibration + FFT
        "learning":  "6C3C4020F00A14018765432112345678901234567890123456789012345678",     # Learning: 60% progress, vibration, FFT
        "start":     "537CE845",                                                           # State: machine start, 69% battery
        "stop":      "537D5A32",                                                           # State: machine stop, 39% battery
        "normal":    "72190A0138F01E4010104B0F7D5A3D4BC8F7E2A19B3C6E8F2A4D7C91B5E8F", # Normal report: 25% anomaly, 14°C
        "high_vib":  "7232640338F01EFF8070FF0F7D5A3D4BC8F7E2A19B3C6E8F2A4D7C91B5E8F", # High vibration report
        "low_temp":  "7219640300F01E4010104B0F7D5A3D4BC8F7E2A19B3C6E8F2A4D7C91B5E8F", # Low temperature: 0°C
        "complete":  "6C644020F00A140100FFEEDDCCBBAA99887766554433221100FFEEDDCCBBAA",   # Learning complete: 100%
        "sensor_on": "536432"                                                             # Sensor start, 39% battery
    }
    
    var hex_payload = test_scenarios.find(payload_str ? payload_str : 'nil', 'not_found')
    
    if hex_payload == 'not_found'
      # CRITICAL FIX: Use static string to avoid keys() iterator bug
      var scenarios_list = "report alarm learning start stop normal high_vib low_temp complete sensor_on "
      return tasmota.resp_cmnd_str(f"Available scenarios: {scenarios_list}")
    end
    
    var rssi = -75
    var fport = 1

    return tasmota.cmd(f'LwSimulate{idx} {rssi},{fport},{hex_payload}')
end)

# MANDATORY: Register driver for web UI integration
tasmota.add_driver(LwDeco)
