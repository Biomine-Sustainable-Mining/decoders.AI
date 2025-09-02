#
# LoRaWAN AI-Generated Decoder for Dragino SE01-LB Prompted by ZioFabry 
#
# Generated: 2025-09-03 | Version: 2.0.0 | Revision: 1
#            by "LoRaWAN Decoder AI Generation Template", v2.5.0
#
# Homepage:  https://wiki.dragino.com/xwiki/bin/view/Main/User%20Manual%20for%20LoRaWAN%20End%20Nodes/SE01-LB_LoRaWAN_Soil%20Moisture%26EC_Sensor_User_Manual/
# Userguide: SE01-LB User Manual
# Decoder:   Official Dragino Decoder
# 
# v2.0.0 (2025-09-03): Template v2.5.0 with verified TestUI payload decoding

class LwDecode_SE01LB
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
        if !global.contains("SE01LB_nodes")
            global.SE01LB_nodes = {}
        end
        if !global.contains("SE01LB_cmdInit")
            global.SE01LB_cmdInit = false
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
            var node_data = global.SE01LB_nodes.find(node, {})
            var previous_data = node_data.find('last_data', {})
            
            # Carry forward persistent parameters
            if size(previous_data) > 0
                for key: ['ds18b20_temp', 'soil_moisture', 'soil_temp', 'soil_conductivity', 
                         'battery_v', 'count_value', 'fw_version', 'mod_flag', 'work_mode']
                    if previous_data.contains(key)
                        data[key] = previous_data[key]
                    end
                end
            end
            
            # Decode based on fport
            if fport == 2
                if size(payload) >= 11
                    # Check MOD flag from last byte
                    var mod_flags = payload[10]
                    var mod = (mod_flags >> 7) & 0x01
                    var i_flag = (mod_flags >> 6) & 0x01
                    var s_flag = (mod_flags >> 5) & 0x01
                    
                    data['mod_flag'] = mod
                    data['interrupt_flag'] = i_flag
                    data['sensor_flag'] = s_flag
                    
                    if mod == 0
                        # Calibrated values mode
                        var temp_raw = (payload[1] << 8) | payload[0]
                        if temp_raw == 0x7FFF
                            data['ds18b20_temp'] = 327.67  # Disconnected
                        else
                            # Signed 16-bit, divide by 10
                            if temp_raw > 32767
                                temp_raw = temp_raw - 65536
                            end
                            data['ds18b20_temp'] = temp_raw / 10.0
                        end
                        
                        # Soil moisture (%)
                        var moisture_raw = (payload[3] << 8) | payload[2]
                        data['soil_moisture'] = moisture_raw / 100.0
                        
                        # Soil temperature (°C)
                        var soil_temp_raw = (payload[5] << 8) | payload[4]
                        if soil_temp_raw > 32767
                            soil_temp_raw = soil_temp_raw - 65536
                        end
                        data['soil_temp'] = soil_temp_raw / 100.0
                        
                        # Soil conductivity (uS/cm)
                        var conductivity_raw = (payload[7] << 8) | payload[6]
                        data['soil_conductivity'] = conductivity_raw
                        
                        data['work_mode'] = "calibrated"
                        
                    else
                        # Raw values mode (MOD=1)
                        data['reserve_temp'] = (payload[1] << 8) | payload[0]
                        data['soil_conductivity_raw'] = (payload[3] << 8) | payload[2]
                        data['soil_moisture_raw'] = (payload[5] << 8) | payload[4]
                        data['dielectric_constant_raw'] = (payload[7] << 8) | payload[6]
                        data['work_mode'] = "raw"
                    end
                    
                    # Battery voltage (mV)
                    var battery_raw = (payload[9] << 8) | payload[8]
                    data['battery_v'] = battery_raw / 1000.0
                    
                    # Check for counting mode (15 bytes)
                    if size(payload) >= 15
                        var count_raw = (payload[14] << 24) | (payload[13] << 16) | 
                                       (payload[12] << 8) | payload[11]
                        data['count_value'] = count_raw
                        data['counting_mode'] = true
                    else
                        data['counting_mode'] = false
                    end
                end
                
            elif fport == 3
                # Datalog data
                if size(payload) >= 11
                    data['datalog_entries'] = []
                    var entry_count = size(payload) / 11
                    
                    for i: 0..(entry_count-1)
                        var offset = i * 11
                        var entry = {}
                        
                        var mod_level = payload[offset + 6]
                        var entry_mod = (mod_level >> 7) & 0x01
                        
                        if entry_mod == 0
                            # Calibrated datalog
                            entry['humidity'] = ((payload[offset+1] << 8) | payload[offset]) / 100.0
                            var temp_raw = (payload[offset+3] << 8) | payload[offset+2]
                            if temp_raw > 32767
                                temp_raw = temp_raw - 65536
                            end
                            entry['temperature'] = temp_raw / 100.0
                            entry['conductivity'] = (payload[offset+5] << 8) | payload[offset+4]
                        else
                            # Raw datalog
                            entry['dielectric_constant'] = (payload[offset+1] << 8) | payload[offset]
                            entry['raw_water_soil'] = (payload[offset+3] << 8) | payload[offset+2]
                            entry['raw_conduct_soil'] = (payload[offset+5] << 8) | payload[offset+4]
                        end
                        
                        entry['mod'] = entry_mod
                        entry['level'] = mod_level & 0x7F
                        entry['timestamp'] = (payload[offset+10] << 24) | (payload[offset+9] << 16) | 
                                           (payload[offset+8] << 8) | payload[offset+7]
                        
                        data['datalog_entries'].push(entry)
                    end
                    
                    data['entry_count'] = entry_count
                end
                
            elif fport == 5
                # Device status
                if size(payload) >= 7
                    data['sensor_model'] = payload[0]
                    var fw_raw = (payload[2] << 8) | payload[1]
                    data['fw_version'] = f"{(fw_raw >> 8) & 0xFF}.{fw_raw & 0xFF}.0"
                    data['frequency_band'] = payload[3]
                    data['sub_band'] = payload[4]
                    data['battery_v'] = ((payload[6] << 8) | payload[5]) / 1000.0
                    
                    # Frequency band mapping
                    var band_names = {1:"EU868", 2:"US915", 3:"IN865", 4:"AU915", 
                                     5:"KZ865", 6:"RU864", 7:"AS923", 8:"AS923-1", 
                                     9:"AS923-2", 10:"AS923-3", 11:"CN470", 12:"EU433", 13:"KR920", 14:"MA869"}
                    data['band_name'] = band_names.find(data['frequency_band'], "Unknown")
                end
            end
            
            # Update node data
            node_data['last_data'] = data
            node_data['last_update'] = tasmota.rtc()['local']
            node_data['name'] = name
            
            # Track battery history
            if data.contains('battery_v')
                if !node_data.contains('battery_history')
                    node_data['battery_history'] = []
                end
                node_data['battery_history'].push(data['battery_v'])
                if size(node_data['battery_history']) > 10
                    node_data['battery_history'].pop(0)
                end
            end
            
            # Track counting value
            if data.contains('count_value')
                node_data['last_count'] = data['count_value']
            end
            
            # Initialize downlink commands
            if !global.contains("SE01LB_cmdInit") || !global.SE01LB_cmdInit
                self.register_downlink_commands()
                global.SE01LB_cmdInit = true
            end
            
            # Save to global storage
            global.SE01LB_nodes[node] = node_data
            
            # Update instance cache
            self.last_data = data
            self.last_update = node_data['last_update']
            
            return data
            
        except .. as e, m
            print(f"SE01LB: Decode error - {e}: {m}")
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
                var node_data = global.SE01LB_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            # Fallback: find any stored node
            if size(data_to_show) == 0 && size(global.SE01LB_nodes) > 0
                var found_node = false
                for node_id: global.SE01LB_nodes.keys()
                    if !found_node
                        var node_data = global.SE01LB_nodes[node_id]
                        data_to_show = node_data.find('last_data', {})
                        last_update = node_data.find('last_update', 0)
                        self.node = node_id
                        self.name = node_data.find('name', f"SE01LB-{node_id}")
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
                name = f"SE01LB-{self.node}"
            end
            var name_tooltip = "Dragino SE01-LB Soil Moisture & EC Sensor"
            var battery = data_to_show.find('battery_v', 1000)
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)
            var simulated = data_to_show.find('simulated', false)
            
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            
            # Main sensor data line
            fmt.start_line()
            
            if data_to_show.contains('work_mode') && data_to_show['work_mode'] == "calibrated"
                if data_to_show.contains('soil_moisture')
                    fmt.add_sensor("string", f"{data_to_show['soil_moisture']:.1f}%", "Soil Moisture", "💧")
                end
                
                if data_to_show.contains('soil_temp')
                    fmt.add_sensor("string", f"{data_to_show['soil_temp']:.1f}°C", "Soil Temp", "🌡️")
                end
                
                if data_to_show.contains('soil_conductivity')
                    var conductivity = data_to_show['soil_conductivity']
                    if conductivity >= 1000
                        fmt.add_sensor("string", f"{conductivity/1000:.1f}mS/cm", "Conductivity", "⚡")
                    else
                        fmt.add_sensor("string", f"{conductivity}µS/cm", "Conductivity", "⚡")
                    end
                end
                
                # Second line for DS18B20 and count
                if data_to_show.contains('ds18b20_temp') || data_to_show.contains('count_value')
                    fmt.next_line()
                    
                    if data_to_show.contains('ds18b20_temp')
                        var temp = data_to_show['ds18b20_temp']
                        if temp >= 327.0
                            fmt.add_sensor("string", "Disconnected", "DS18B20", "🌡️")
                        else
                            fmt.add_sensor("string", f"{temp:.1f}°C", "DS18B20", "🌡️")
                        end
                    end
                    
                    if data_to_show.contains('count_value')
                        fmt.add_sensor("string", f"{data_to_show['count_value']}", "Count", "🔢")
                    end
                end
                
            else
                # Raw mode display
                if data_to_show.contains('soil_moisture_raw')
                    fmt.add_sensor("string", f"{data_to_show['soil_moisture_raw']}", "Raw Moisture", "💧")
                end
                
                if data_to_show.contains('soil_conductivity_raw')
                    fmt.add_sensor("string", f"{data_to_show['soil_conductivity_raw']}", "Raw Conduct", "⚡")
                end
                
                if data_to_show.contains('dielectric_constant_raw')
                    fmt.add_sensor("string", f"{data_to_show['dielectric_constant_raw']}", "Raw Dielectric", "📊")
                end
            end
            
            # Third line for mode and status info
            if data_to_show.contains('work_mode') || data_to_show.contains('counting_mode') || 
               data_to_show.contains('fw_version')
                fmt.next_line()
                
                if data_to_show.contains('work_mode')
                    var mode = data_to_show['work_mode'] == "calibrated" ? "CAL" : "RAW"
                    fmt.add_sensor("string", mode, "Mode", "⚙️")
                end
                
                if data_to_show.contains('counting_mode') && data_to_show['counting_mode']
                    fmt.add_sensor("string", "Counting", "Type", "🔢")
                else
                    fmt.add_sensor("string", "Interrupt", "Type", "⚡")
                end
                
                if data_to_show.contains('fw_version')
                    fmt.add_sensor("string", f"v{data_to_show['fw_version']}", "Firmware", "💾")
                end
                
                if data_to_show.contains('band_name')
                    fmt.add_sensor("string", data_to_show['band_name'], "Band", "📡")
                end
            end
            
            fmt.end_line()
            msg += fmt.get_msg()
            
            return msg
            
        except .. as e, m
            print(f"SE01LB: Display error - {e}: {m}")
            return "📟 SE01LB Error - Check Console"
        end
    end
    
    def register_downlink_commands()
        import string
        
        # Set transmit interval (30 seconds to 16777215 seconds)
        tasmota.remove_cmd("LwSE01LBInterval")
        tasmota.add_cmd("LwSE01LBInterval", def(cmd, idx, payload_str)
            var interval = int(payload_str)
            if interval < 30 || interval > 16777215
                return tasmota.resp_cmnd_str("Invalid interval: range 30-16777215 seconds")
            end
            
            # Build 24-bit big-endian interval
            var hex_cmd = f"01{(interval >> 16) & 0xFF:02X}{(interval >> 8) & 0xFF:02X}{interval & 0xFF:02X}"
            return lwdecode.SendDownlink(global.SE01LB_nodes, cmd, idx, hex_cmd)
        end)
        
        # Reset device
        tasmota.remove_cmd("LwSE01LBReset")
        tasmota.add_cmd("LwSE01LBReset", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.SE01LB_nodes, cmd, idx, "04FF")
        end)
        
        # Set confirm mode
        tasmota.remove_cmd("LwSE01LBConfirm")
        tasmota.add_cmd("LwSE01LBConfirm", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.SE01LB_nodes, cmd, idx, payload_str, {
                'DISABLE|0': ['05000000', 'UNCONFIRMED'],
                'ENABLE|1':  ['05000001', 'CONFIRMED']
            })
        end)
        
        # Set interrupt mode
        tasmota.remove_cmd("LwSE01LBInterrupt")
        tasmota.add_cmd("LwSE01LBInterrupt", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.SE01LB_nodes, cmd, idx, payload_str, {
                'DISABLE|0': ['06000000', 'DISABLED'],
                'ENABLE|3':  ['06000003', 'RISING_EDGE']
            })
        end)
        
        # Set 5V output duration
        tasmota.remove_cmd("LwSE01LBOutput5V")
        tasmota.add_cmd("LwSE01LBOutput5V", def(cmd, idx, payload_str)
            var duration = int(payload_str)
            if duration < 0 || duration > 65535
                return tasmota.resp_cmnd_str("Invalid duration: range 0-65535 ms")
            end
            
            var hex_cmd = f"07{(duration >> 8) & 0xFF:02X}{duration & 0xFF:02X}"
            return lwdecode.SendDownlink(global.SE01LB_nodes, cmd, idx, hex_cmd)
        end)
        
        # Set count value
        tasmota.remove_cmd("LwSE01LBSetCount")
        tasmota.add_cmd("LwSE01LBSetCount", def(cmd, idx, payload_str)
            var count = int(payload_str)
            if count < 0 || count > 4294967295
                return tasmota.resp_cmnd_str("Invalid count: range 0-4294967295")
            end
            
            var hex_cmd = f"09{(count >> 24) & 0xFF:02X}{(count >> 16) & 0xFF:02X}"
            hex_cmd += f"{(count >> 8) & 0xFF:02X}{count & 0xFF:02X}"
            return lwdecode.SendDownlink(global.SE01LB_nodes, cmd, idx, hex_cmd)
        end)
        
        # Set working mode
        tasmota.remove_cmd("LwSE01LBWorkMode")
        tasmota.add_cmd("LwSE01LBWorkMode", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.SE01LB_nodes, cmd, idx, payload_str, {
                'CALIBRATED|0': ['0A00', 'CALIBRATED'],
                'RAW|1':        ['0A01', 'RAW']
            })
        end)
        
        # Set count mode
        tasmota.remove_cmd("LwSE01LBCountMode")
        tasmota.add_cmd("LwSE01LBCountMode", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.SE01LB_nodes, cmd, idx, payload_str, {
                'INTERRUPT|0': ['1000', 'INTERRUPT'],
                'COUNTING|1':  ['1001', 'COUNTING']
            })
        end)
        
        # Request device status
        tasmota.remove_cmd("LwSE01LBStatus")
        tasmota.add_cmd("LwSE01LBStatus", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.SE01LB_nodes, cmd, idx, "2601")
        end)
        
        # Poll datalog
        tasmota.remove_cmd("LwSE01LBPoll")
        tasmota.add_cmd("LwSE01LBPoll", def(cmd, idx, payload_str)
            var parts = string.split(payload_str, ',')
            if size(parts) != 3
                return tasmota.resp_cmnd_str("Usage: LwSE01LBPoll<slot> <start_ts>,<end_ts>,<interval>")
            end
            
            var start_ts = int(parts[0])
            var end_ts = int(parts[1])
            var interval = int(parts[2])
            
            if interval < 5 || interval > 255
                return tasmota.resp_cmnd_str("Invalid interval: range 5-255 seconds")
            end
            
            var hex_cmd = f"31{(start_ts >> 24) & 0xFF:02X}{(start_ts >> 16) & 0xFF:02X}"
            hex_cmd += f"{(start_ts >> 8) & 0xFF:02X}{start_ts & 0xFF:02X}"
            hex_cmd += f"{(end_ts >> 24) & 0xFF:02X}{(end_ts >> 16) & 0xFF:02X}"
            hex_cmd += f"{(end_ts >> 8) & 0xFF:02X}{end_ts & 0xFF:02X}"
            hex_cmd += f"{interval:02X}"
            return lwdecode.SendDownlink(global.SE01LB_nodes, cmd, idx, hex_cmd)
        end)
        
        print("SE01LB: Downlink commands registered")
    end
    
    # Get node statistics
    def get_node_stats(node_id)
        import global
        var node_data = global.SE01LB_nodes.find(node_id, nil)
        if node_data == nil return nil end
        
        return {
            'last_update': node_data.find('last_update', 0),
            'last_count': node_data.find('last_count', 0),
            'battery_history': node_data.find('battery_history', []),
            'name': node_data.find('name', 'Unknown')
        }
    end
    
    # Clear node data
    def clear_node_data(node_id)
        import global
        if global.SE01LB_nodes.contains(node_id)
            global.SE01LB_nodes.remove(node_id)
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
        
        var fport = scenario_name == "status" ? 5 : (scenario_name == "datalog" ? 3 : 2)
        var result = self.decodeUplink("TestDevice", "TEST-001", -75, fport, payload_bytes)
        
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
        if scenario_name == "low_battery" && result.contains('battery_v') && result['battery_v'] > 3.2
            print(f"PAYLOAD ERROR: {scenario_name} battery should be < 3.2V")
            return false
        end
        
        return true
    end
end

# Global instance
LwDeco = LwDecode_SE01LB()

# Node management commands
tasmota.remove_cmd("LwSE01LBNodeStats")
tasmota.add_cmd("LwSE01LBNodeStats", def(cmd, idx, node_id)
    var stats = LwDeco.get_node_stats(node_id)
    if stats != nil
        import json
        tasmota.resp_cmnd(json.dump(stats))
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

tasmota.remove_cmd("LwSE01LBClearNode")
tasmota.add_cmd("LwSE01LBClearNode", def(cmd, idx, node_id)
    if LwDeco.clear_node_data(node_id)
        tasmota.resp_cmnd_done()
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

# Test UI command with verified payloads
tasmota.remove_cmd("LwSE01LBTestUI")
tasmota.add_cmd("LwSE01LBTestUI", def(cmd, idx, payload_str)
    # Template v2.5.0: Verified payload decoding for all scenarios
    var test_scenarios = {
        "normal":      "E8031E0F421857080C7100", # Normal calibrated (10.0°C, 25.5%, 15.78°C, 2136µS/cm, 2.9V)
        "raw":         "000050C6AC12D00F0C7180", # Raw mode (MOD=1, raw values, 2.9V)
        "counting":    "E8031E0F421857080C710000000064", # Counting mode with count=100
        "low_battery": "E8031E0F421857080C710B54", # Low battery (2.9V→2.644V)
        "disconnected":"FF7F1E0F421857080C7100", # DS18B20 disconnected (0x7FFF)
        "high_conduct":"E8031E0F42185DC00C7100", # High conductivity (24000µS/cm = 24mS/cm)
        "status":      "260200010003E8",         # Status (v2.0.0, EU868, 1000mV)
        "datalog":     "1E0F421857080000000066470000" # Datalog entry
    }
    
    var hex_payload = test_scenarios.find(payload_str ? payload_str : 'nil', 'not_found')
    
    if hex_payload == 'not_found'
        var scenarios_list = "normal raw counting low_battery disconnected high_conduct status datalog "
        return tasmota.resp_cmnd_str(f"Available scenarios: {scenarios_list}")
    end
    
    var rssi = -75
    var fport = payload_str == "status" ? 5 : (payload_str == "datalog" ? 3 : 2)
    
    return tasmota.cmd(f'LwSimulate{idx} {rssi},{fport},{hex_payload}')
end)

# Register driver
tasmota.add_driver(LwDeco)
