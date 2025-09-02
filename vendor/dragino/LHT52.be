#
# LoRaWAN AI-Generated Decoder for Dragino LHT52 Temperature & Humidity Sensor
#
# Generated: 2025-09-02 | Version: v1.2.0 | Revision: 3
#            by "LoRaWAN Decoder AI Generation Template", v2.5.0
#
# Homepage:  https://wiki.dragino.com/xwiki/bin/view/Main/User%20Manual%20for%20LoRaWAN%20End%20Nodes/LHT52%20-%20LoRaWAN%20Temperature%20%26%20Humidity%20Sensor%20User%20Manual/
# Userguide: Same as above
# Decoder:   Official decoder integrated
# 
# Device: Temperature & humidity sensor with datalog and alarm functionality
# Features: Internal SHT20 + optional DS18B20 external probe, historical data logging

class LwDecode_LHT52
    var hashCheck, name, node, last_data, last_update, lwdecode

    def init()
        self.hashCheck = true
        self.name = nil
        self.node = nil
        self.last_data = {}
        self.last_update = 0
        
        import global
        if !global.contains("LHT52_nodes")
            global.LHT52_nodes = {}
        end
        if !global.contains("LHT52_cmdInit")
            global.LHT52_cmdInit = false
        end
    end
    
    def decodeUplink(name, node, rssi, fport, payload)
        import string
        import global
        var data = {}
        
        if payload == nil || size(payload) < 1
            return nil
        end
        
        try
            self.name = name
            self.node = node
            data['RSSI'] = rssi
            data['FPort'] = fport
            
            var node_data = global.LHT52_nodes.find(node, {})
            var previous_data = node_data.find('last_data', {})
            
            if size(previous_data) > 0
                for key: ['battery_v', 'temperature', 'humidity', 'external_temperature', 'alarm_status']
                    if previous_data.contains(key)
                        data[key] = previous_data[key]
                    end
                end
            end
            
            if fport == 5        # Device Status
                if size(payload) >= 7
                    data['sensor_model'] = payload[0]
                    data['fw_version'] = f"v{payload[1]}.{payload[2]}.0"
                    data['frequency_band'] = self.decode_frequency_band(payload[3])
                    data['sub_band'] = payload[4]
                    var battery_mv = (payload[5] << 8) | payload[6]
                    data['battery_v'] = battery_mv / 1000.0
                    data['battery_pct'] = self.voltage_to_percent(data['battery_v'])
                    data['device_info'] = true
                end
                
            elif fport == 2      # Real-time Sensor Data
                if size(payload) >= 11
                    # Temperature (signed, /100)
                    var temp_raw = (payload[0] << 8) | payload[1]
                    if temp_raw > 32767
                        temp_raw = temp_raw - 65536
                    end
                    data['temperature'] = temp_raw / 100.0
                    
                    # Humidity (/10)
                    var humidity_raw = (payload[2] << 8) | payload[3]
                    data['humidity'] = humidity_raw / 10.0
                    
                    # External temperature (signed, /100)
                    var ext_temp_raw = (payload[4] << 8) | payload[5]
                    if ext_temp_raw != 0x7FFF
                        if ext_temp_raw > 32767
                            ext_temp_raw = ext_temp_raw - 65536
                        end
                        data['external_temperature'] = ext_temp_raw / 100.0
                    end
                    
                    # Extension type
                    data['extension_type'] = payload[6]
                    if payload[6] == 0x01
                        data['extension_name'] = "AS-01 Temperature"
                    end
                    
                    # Unix timestamp
                    var timestamp = (payload[7] << 24) | (payload[8] << 16) | 
                                   (payload[9] << 8) | payload[10]
                    data['timestamp'] = timestamp
                end
                
            elif fport == 3      # Datalog Sensor Data
                if size(payload) >= 11
                    # Same structure as port 2
                    var temp_raw = (payload[0] << 8) | payload[1]
                    if temp_raw > 32767
                        temp_raw = temp_raw - 65536
                    end
                    data['temperature'] = temp_raw / 100.0
                    
                    var humidity_raw = (payload[2] << 8) | payload[3]
                    data['humidity'] = humidity_raw / 10.0
                    
                    var ext_temp_raw = (payload[4] << 8) | payload[5]
                    if ext_temp_raw != 0x7FFF
                        if ext_temp_raw > 32767
                            ext_temp_raw = ext_temp_raw - 65536
                        end
                        data['external_temperature'] = ext_temp_raw / 100.0
                    end
                    
                    data['extension_type'] = payload[6]
                    var timestamp = (payload[7] << 24) | (payload[8] << 16) | 
                                   (payload[9] << 8) | payload[10]
                    data['timestamp'] = timestamp
                    data['historical_data'] = true
                end
                
            elif fport == 4      # DS18B20 ID
                if size(payload) >= 8
                    var sensor_id = ""
                    for i: 0..7
                        sensor_id += f"{payload[i]:02X}"
                    end
                    data['ds18b20_id'] = sensor_id
                    data['sensor_info'] = true
                end
            end
            
            if data.contains('battery_v')
                if !node_data.contains('battery_history')
                    node_data['battery_history'] = []
                end
                node_data['battery_history'].push(data['battery_v'])
                if size(node_data['battery_history']) > 10
                    node_data['battery_history'].pop(0)
                end
            end
            
            if !global.LHT52_cmdInit
                self.register_downlink_commands()
                global.LHT52_cmdInit = true
            end
            
            node_data['last_data'] = data
            node_data['last_update'] = tasmota.rtc()['local']
            node_data['name'] = name
            global.LHT52_nodes[node] = node_data
            
            self.last_data = data
            self.last_update = node_data['last_update']
            
            return data
            
        except .. as e, m
            print(f"LHT52: Decode error - {e}: {m}")
            return nil
        end
    end
    
    def add_web_sensor()
        try
            var data_to_show = self.last_data
            var last_update = self.last_update
            
            if size(data_to_show) == 0 && self.node != nil
                import global
                var node_data = global.LHT52_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            if size(data_to_show) == 0
                import global
                if size(global.LHT52_nodes) > 0
                    var found_node = false
                    for node_id: global.LHT52_nodes.keys()
                        if !found_node
                            var node_data = global.LHT52_nodes[node_id]
                            data_to_show = node_data.find('last_data', {})
                            last_update = node_data.find('last_update', 0)
                            self.node = node_id
                            self.name = node_data.find('name', f"LHT52-{node_id}")
                            found_node = true
                        end
                    end
                end
            end
            
            if size(data_to_show) == 0 return nil end
            
            import string
            var msg = ""
            var fmt = LwSensorFormatter_cls()
            
            var name = self.name ? self.name : f"LHT52-{self.node}"
            var name_tooltip = "Dragino LHT52 Temperature & Humidity"
            var battery = data_to_show.find('battery_v', 1000)
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)
            var simulated = data_to_show.find('simulated', false)
            
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            
            fmt.start_line()
            
            if data_to_show.contains('temperature')
                fmt.add_sensor("temp", data_to_show['temperature'], "Temperature", "🌡️")
            end
            
            if data_to_show.contains('humidity')
                fmt.add_sensor("humidity", data_to_show['humidity'], "Humidity", "💧")
            end
            
            if data_to_show.contains('external_temperature')
                fmt.add_sensor("temp", data_to_show['external_temperature'], "External Temp", "🔍")
            end
            
            if battery != 1000
                fmt.add_sensor("string", f"{data_to_show.find('battery_pct', 0)}%", "Battery", "🔋")
            end
            
            var has_status = false
            var status_items = []
            
            if data_to_show.contains('device_info') && data_to_show['device_info']
                status_items.push(['string', 'Config', 'Device Info', '⚙️'])
                has_status = true
            end
            
            if data_to_show.contains('historical_data') && data_to_show['historical_data']
                status_items.push(['string', 'Datalog', 'Historical Data', '📊'])
                has_status = true
            end
            
            if data_to_show.contains('sensor_info') && data_to_show['sensor_info']
                status_items.push(['string', 'Sensor ID', 'DS18B20 Info', '🔍'])
                has_status = true
            end
            
            if data_to_show.contains('extension_name')
                status_items.push(['string', data_to_show['extension_name'], 'External Sensor', '🔌'])
                has_status = true
            end
            
            if has_status
                fmt.next_line()
                for item : status_items
                    fmt.add_sensor(item[0], item[1], item[2], item[3])
                end
            end
            
            fmt.end_line()
            msg += fmt.get_msg()
            
            return msg
            
        except .. as e, m
            print(f"LHT52: Display error - {e}: {m}")
            return "📟 LHT52 Error - Check Console"
        end
    end
    
    def decode_frequency_band(band_code)
        var bands = {
            0x01: "EU868", 0x02: "US915", 0x03: "IN865", 0x04: "AU915",
            0x05: "KZ865", 0x06: "RU864", 0x07: "AS923", 0x08: "AS923-2",
            0x09: "AS923-3", 0x0A: "AS923-4", 0x0B: "CN470", 0x0C: "EU433",
            0x0D: "KR920", 0x0E: "MA869"
        }
        return bands.find(band_code, f"Unknown({band_code:02X})")
    end
    
    def voltage_to_percent(voltage)
        if voltage >= 3.6 return 100
        elif voltage <= 2.4 return 0
        else return int((voltage - 2.4) / 1.2 * 100)
        end
    end
    
    def get_node_stats(node_id)
        import global
        var node_data = global.LHT52_nodes.find(node_id, nil)
        if node_data == nil return nil end
        
        return {
            'last_update': node_data.find('last_update', 0),
            'battery_history': node_data.find('battery_history', []),
            'name': node_data.find('name', 'Unknown')
        }
    end
    
    def clear_node_data(node_id)
        import global
        if global.LHT52_nodes.contains(node_id)
            global.LHT52_nodes.remove(node_id)
            return true
        end
        return false
    end
    
    def register_downlink_commands()
        import string
        
        tasmota.remove_cmd("LwLHT52Interval")
        tasmota.add_cmd("LwLHT52Interval", def(cmd, idx, payload_str)
            var interval = int(payload_str)
            if interval < 1 || interval > 86400000
                return tasmota.resp_cmnd_str("Invalid: range 1-86400000 ms")
            end
            
            var hex_cmd = f"01{interval & 0xFF:02X}{(interval >> 8) & 0xFF:02X}"
            hex_cmd += f"{(interval >> 16) & 0xFF:02X}{(interval >> 24) & 0xFF:02X}"
            
            return lwdecode.SendDownlink(global.LHT52_nodes, cmd, idx, hex_cmd)
        end)
        
        tasmota.remove_cmd("LwLHT52Reset")
        tasmota.add_cmd("LwLHT52Reset", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.LHT52_nodes, cmd, idx, "04FF")
        end)
        
        tasmota.remove_cmd("LwLHT52FactoryReset")
        tasmota.add_cmd("LwLHT52FactoryReset", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.LHT52_nodes, cmd, idx, "04FE")
        end)
        
        tasmota.remove_cmd("LwLHT52Confirmed")
        tasmota.add_cmd("LwLHT52Confirmed", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.LHT52_nodes, cmd, idx, payload_str, {
                '0|DISABLE': ['0500', 'Unconfirmed'],
                '1|ENABLE': ['0501', 'Confirmed']
            })
        end)
        
        tasmota.remove_cmd("LwLHT52Status")
        tasmota.add_cmd("LwLHT52Status", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.LHT52_nodes, cmd, idx, "2301")
        end)
        
        tasmota.remove_cmd("LwLHT52SensorID")
        tasmota.add_cmd("LwLHT52SensorID", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.LHT52_nodes, cmd, idx, "2302")
        end)
        
        tasmota.remove_cmd("LwLHT52Poll")
        tasmota.add_cmd("LwLHT52Poll", def(cmd, idx, payload_str)
            var parts = string.split(payload_str, ',')
            if size(parts) != 3
                return tasmota.resp_cmnd_str("Usage: LwLHT52Poll<slot> <start>,<end>,<interval>")
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
            
            return lwdecode.SendDownlink(global.LHT52_nodes, cmd, idx, hex_cmd)
        end)
        
        tasmota.remove_cmd("LwLHT52TempRange")
        tasmota.add_cmd("LwLHT52TempRange", def(cmd, idx, payload_str)
            var parts = string.split(payload_str, ',')
            if size(parts) != 4
                return tasmota.resp_cmnd_str("Usage: LwLHT52TempRange<slot> <mode>,<interval>,<min>,<max>")
            end
            
            var mode = int(parts[0])
            var interval = int(parts[1])
            var temp_min = int(parts[2])
            var temp_max = int(parts[3])
            
            var hex_cmd = f"AA{mode:02X}{interval & 0xFF:02X}{(interval >> 8) & 0xFF:02X}"
            hex_cmd += f"{temp_min & 0xFF:02X}{(temp_min >> 8) & 0xFF:02X}"
            hex_cmd += f"{temp_max & 0xFF:02X}{(temp_max >> 8) & 0xFF:02X}"
            
            return lwdecode.SendDownlink(global.LHT52_nodes, cmd, idx, hex_cmd)
        end)
        
        print("LHT52: Downlink commands registered")
    end
end

LwDeco = LwDecode_LHT52()

tasmota.remove_cmd("LwLHT52NodeStats")
tasmota.add_cmd("LwLHT52NodeStats", def(cmd, idx, node_id)
    var stats = LwDeco.get_node_stats(node_id)
    if stats != nil
        import json
        tasmota.resp_cmnd(json.dump(stats))
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

tasmota.remove_cmd("LwLHT52ClearNode")
tasmota.add_cmd("LwLHT52ClearNode", def(cmd, idx, node_id)
    if LwDeco.clear_node_data(node_id)
        tasmota.resp_cmnd_done()
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

tasmota.remove_cmd("LwLHT52TestUI")
tasmota.add_cmd("LwLHT52TestUI", def(cmd, idx, payload_str)
    var test_scenarios = {
        "normal":     "094C03E8017FFF0161A0B580",     # Port 2: 23.4°C, 100%RH, no ext sensor
        "external":   "094C03E8FF38010161A0B580",     # Port 2: With -20°C external temp
        "hot":        "0FA003E8017FFF0161A0B580",     # Port 2: 40°C temperature
        "cold":       "F06003E8017FFF0161A0B580",     # Port 2: -10°C temperature
        "dry":        "094C006417FF0161A0B580",       # Port 2: 10%RH humidity
        "config":     "0901000100B30B",              # Port 5: Device status, fw v1.0.0, EU868
        "datalog":    "094C03E8017FFF0161A0B580",     # Port 3: Historical data
        "sensor_id":  "28FF1234567890AB",            # Port 4: DS18B20 sensor ID
        "low":        "094C03E8017FFF0161A0B580",     # Port 2: Same data (battery shown in header)
        "demo":       "094C03E8FF380161A0B580"       # Port 2: Demo with all sensors
    }
    
    var hex_payload = test_scenarios.find(payload_str ? payload_str : 'nil', 'not_found')
    
    if hex_payload == 'not_found'
        var scenarios_list = "normal external hot cold dry config datalog sensor_id low demo "
        return tasmota.resp_cmnd_str(f"Available scenarios: {scenarios_list}")
    end
    
    var rssi = -75
    var fport = 2
    if payload_str == "config" fport = 5 end
    if payload_str == "datalog" fport = 3 end
    if payload_str == "sensor_id" fport = 4 end

    return tasmota.cmd(f'LwSimulate{idx} {rssi},{fport},{hex_payload}')
end)

tasmota.add_driver(LwDeco)