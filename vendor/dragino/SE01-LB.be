#
# LoRaWAN AI-Generated Decoder for Dragino SE01-LB Soil Moisture & EC Sensor
#
# Generated: 2025-09-02 | Version: v1.2.0 | Revision: 3
#            by "LoRaWAN Decoder AI Generation Template", v2.5.0
#
# Homepage:  https://wiki.dragino.com/xwiki/bin/view/Main/User%20Manual%20for%20LoRaWAN%20End%20Nodes/SE01-LB_LoRaWAN_Soil%20Moisture%26EC_Sensor_User_Manual/
# Userguide: Same as above
# Decoder:   Official decoder integrated
# 
# Device: Soil moisture & electrical conductivity sensor with DS18B20 temperature
# Features: FDR moisture measurement, EC with temp compensation, interrupt/counting modes

class LwDecode_SE01_LB
    var hashCheck, name, node, last_data, last_update, lwdecode

    def init()
        self.hashCheck = true
        self.name = nil
        self.node = nil
        self.last_data = {}
        self.last_update = 0
        
        import global
        if !global.contains("SE01_LB_nodes")
            global.SE01_LB_nodes = {}
        end
        if !global.contains("SE01_LB_cmdInit")
            global.SE01_LB_cmdInit = false
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
            
            var node_data = global.SE01_LB_nodes.find(node, {})
            var previous_data = node_data.find('last_data', {})
            
            if size(previous_data) > 0
                for key: ['battery_v', 'soil_moisture', 'soil_temperature', 'soil_conductivity', 'ds18b20_temp']
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
                
            elif fport == 2      # Sensor Data (various MOD types)
                if size(payload) >= 11
                    # DS18B20 temperature (signed)
                    var ds18b20_raw = (payload[0] << 8) | payload[1]
                    if ds18b20_raw != 0x7FFF && ds18b20_raw < 0x7FF0  # Valid range check
                        if ds18b20_raw > 32767
                            ds18b20_raw = ds18b20_raw - 65536
                        end
                        data['ds18b20_temp'] = ds18b20_raw / 10.0
                    else
                        data['ds18b20_status'] = "Disconnected"
                    end
                    
                    # MOD and flags
                    var mod_flags = payload[10]
                    var mod_type = (mod_flags >> 4) & 0x0F
                    data['mod_type'] = mod_type
                    data['i_flag'] = (mod_flags & 0x02) != 0
                    data['s_flag'] = (mod_flags & 0x01) != 0
                    
                    if mod_type == 0  # Calibrated values mode
                        # Soil moisture (calibrated %)
                        var moisture_raw = (payload[2] << 8) | payload[3]
                        data['soil_moisture'] = moisture_raw / 100.0
                        
                        # Soil temperature (signed, calibrated)
                        var soil_temp_raw = (payload[4] << 8) | payload[5]
                        if soil_temp_raw > 32767
                            soil_temp_raw = soil_temp_raw - 65536
                        end
                        data['soil_temperature'] = soil_temp_raw / 100.0
                        
                        # Soil conductivity (calibrated uS/cm)
                        data['soil_conductivity'] = (payload[6] << 8) | payload[7]
                        
                        # Battery voltage
                        var battery_mv = (payload[8] << 8) | payload[9]
                        data['battery_v'] = battery_mv / 1000.0
                        data['battery_pct'] = self.voltage_to_percent(data['battery_v'])
                        
                        # Count value if counting mode (size 15)
                        if size(payload) >= 15
                            var count = (payload[11] << 24) | (payload[12] << 16) | 
                                       (payload[13] << 8) | payload[14]
                            data['count_value'] = count
                            data['counting_mode'] = true
                        else
                            data['interrupt_mode'] = true
                        end
                        
                    elif mod_type == 1  # Raw values mode
                        # Raw conductivity
                        data['raw_conductivity'] = (payload[2] << 8) | payload[3]
                        
                        # Raw moisture AD value
                        data['raw_moisture'] = (payload[4] << 8) | payload[5]
                        
                        # Raw dielectric constant
                        data['raw_dielectric'] = (payload[6] << 8) | payload[7]
                        
                        # Battery voltage
                        var battery_mv = (payload[8] << 8) | payload[9]
                        data['battery_v'] = battery_mv / 1000.0
                        data['battery_pct'] = self.voltage_to_percent(data['battery_v'])
                        
                        data['raw_mode'] = true
                        
                        # Count value if counting mode (size 15)
                        if size(payload) >= 15
                            var count = (payload[11] << 24) | (payload[12] << 16) | 
                                       (payload[13] << 8) | payload[14]
                            data['count_value'] = count
                            data['counting_mode'] = true
                        else
                            data['interrupt_mode'] = true
                        end
                    end
                end
                
            elif fport == 3      # Datalog
                if size(payload) >= 11
                    # Datalog entries have same structure as real-time
                    # Parse based on MOD type embedded in each entry
                    var mod_flags = payload[6]
                    var mod_type = (mod_flags >> 4) & 0x0F
                    
                    if mod_type == 0
                        var moisture_raw = (payload[0] << 8) | payload[1]
                        data['soil_moisture'] = moisture_raw / 100.0
                        
                        var temp_raw = (payload[2] << 8) | payload[3]
                        if temp_raw > 32767
                            temp_raw = temp_raw - 65536
                        end
                        data['soil_temperature'] = temp_raw / 100.0
                        
                        data['soil_conductivity'] = (payload[4] << 8) | payload[5]
                    end
                    
                    # Timestamp
                    var timestamp = (payload[7] << 24) | (payload[8] << 16) | 
                                   (payload[9] << 8) | payload[10]
                    data['timestamp'] = timestamp
                    data['historical_data'] = true
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
            
            if !global.SE01_LB_cmdInit
                self.register_downlink_commands()
                global.SE01_LB_cmdInit = true
            end
            
            node_data['last_data'] = data
            node_data['last_update'] = tasmota.rtc()['local']
            node_data['name'] = name
            global.SE01_LB_nodes[node] = node_data
            
            self.last_data = data
            self.last_update = node_data['last_update']
            
            return data
            
        except .. as e, m
            print(f"SE01-LB: Decode error - {e}: {m}")
            return nil
        end
    end
    
    def add_web_sensor()
        try
            var data_to_show = self.last_data
            var last_update = self.last_update
            
            if size(data_to_show) == 0 && self.node != nil
                import global
                var node_data = global.SE01_LB_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            if size(data_to_show) == 0
                import global
                if size(global.SE01_LB_nodes) > 0
                    var found_node = false
                    for node_id: global.SE01_LB_nodes.keys()
                        if !found_node
                            var node_data = global.SE01_LB_nodes[node_id]
                            data_to_show = node_data.find('last_data', {})
                            last_update = node_data.find('last_update', 0)
                            self.node = node_id
                            self.name = node_data.find('name', f"SE01-{node_id}")
                            found_node = true
                        end
                    end
                end
            end
            
            if size(data_to_show) == 0 return nil end
            
            import string
            var msg = ""
            var fmt = LwSensorFormatter_cls()
            
            var name = self.name ? self.name : f"SE01-{self.node}"
            var name_tooltip = "Dragino SE01-LB Soil Sensor"
            var battery = data_to_show.find('battery_v', 1000)
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)
            var simulated = data_to_show.find('simulated', false)
            
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            
            fmt.start_line()
            
            # Soil parameters
            if data_to_show.contains('soil_moisture')
                fmt.add_sensor("humidity", data_to_show['soil_moisture'], "Soil Moisture", "🌱")
            end
            
            if data_to_show.contains('soil_temperature')
                fmt.add_sensor("temp", data_to_show['soil_temperature'], "Soil Temp", "🌍")
            end
            
            if data_to_show.contains('soil_conductivity')
                fmt.add_sensor("string", f"{data_to_show['soil_conductivity']}μS", "EC", "⚡")
            end
            
            # External temperature
            if data_to_show.contains('ds18b20_temp')
                fmt.add_sensor("temp", data_to_show['ds18b20_temp'], "Air Temp", "🌡️")
            end
            
            # Battery or count
            if data_to_show.contains('count_value')
                fmt.add_sensor("string", f"{data_to_show['count_value']}", "Count", "🔢")
            elif battery != 1000
                fmt.add_sensor("string", f"{data_to_show.find('battery_pct', 0)}%", "Battery", "🔋")
            end
            
            var has_status = false
            var status_items = []
            
            if data_to_show.contains('raw_mode') && data_to_show['raw_mode']
                status_items.push(['string', 'Raw Mode', 'ADC Values', '📊'])
                has_status = true
            end
            
            if data_to_show.contains('counting_mode') && data_to_show['counting_mode']
                status_items.push(['string', 'Counting', 'Count Mode', '🔢'])
                has_status = true
            end
            
            if data_to_show.contains('ds18b20_status')
                status_items.push(['string', data_to_show['ds18b20_status'], 'DS18B20', '❌'])
                has_status = true
            end
            
            if data_to_show.contains('historical_data') && data_to_show['historical_data']
                status_items.push(['string', 'Datalog', 'Historical', '📋'])
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
            print(f"SE01-LB: Display error - {e}: {m}")
            return "📟 SE01-LB Error - Check Console"
        end
    end
    
    def decode_frequency_band(band_code)
        var bands = {
            0x01: "EU868", 0x02: "US915", 0x03: "IN865", 0x04: "AU915",
            0x05: "KZ865", 0x06: "RU864", 0x07: "AS923", 0x08: "AS923-1",
            0x09: "AS923-2", 0x0A: "AS923-3", 0x0B: "CN470", 0x0C: "EU433",
            0x0D: "KR920", 0x0E: "MA869"
        }
        return bands.find(band_code, f"Unknown({band_code:02X})")
    end
    
    def voltage_to_percent(voltage)
        if voltage >= 3.6 return 100
        elif voltage <= 2.5 return 0
        else return int((voltage - 2.5) / 1.1 * 100)
        end
    end
    
    def get_node_stats(node_id)
        import global
        var node_data = global.SE01_LB_nodes.find(node_id, nil)
        if node_data == nil return nil end
        
        return {
            'last_update': node_data.find('last_update', 0),
            'battery_history': node_data.find('battery_history', []),
            'name': node_data.find('name', 'Unknown')
        }
    end
    
    def clear_node_data(node_id)
        import global
        if global.SE01_LB_nodes.contains(node_id)
            global.SE01_LB_nodes.remove(node_id)
            return true
        end
        return false
    end
    
    def register_downlink_commands()
        import string
        
        tasmota.remove_cmd("LwSE01Interval")
        tasmota.add_cmd("LwSE01Interval", def(cmd, idx, payload_str)
            var interval = int(payload_str)
            if interval < 30 || interval > 16777215
                return tasmota.resp_cmnd_str("Invalid: range 30-16777215 seconds")
            end
            
            var hex_cmd = f"01{(interval >> 16) & 0xFF:02X}{(interval >> 8) & 0xFF:02X}{interval & 0xFF:02X}"
            return lwdecode.SendDownlink(global.SE01_LB_nodes, cmd, idx, hex_cmd)
        end)
        
        tasmota.remove_cmd("LwSE01Reset")
        tasmota.add_cmd("LwSE01Reset", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.SE01_LB_nodes, cmd, idx, "04FF")
        end)
        
        tasmota.remove_cmd("LwSE01Confirmed")
        tasmota.add_cmd("LwSE01Confirmed", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.SE01_LB_nodes, cmd, idx, payload_str, {
                '0|DISABLE': ['05000000', 'Unconfirmed'],
                '1|ENABLE': ['05000001', 'Confirmed']
            })
        end)
        
        tasmota.remove_cmd("LwSE01Interrupt")
        tasmota.add_cmd("LwSE01Interrupt", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.SE01_LB_nodes, cmd, idx, payload_str, {
                '0|DISABLE': ['06000000', 'Disabled'],
                '1|RISING': ['06000003', 'Rising Edge']
            })
        end)
        
        tasmota.remove_cmd("LwSE01OutputDuration")
        tasmota.add_cmd("LwSE01OutputDuration", def(cmd, idx, payload_str)
            var duration = int(payload_str)
            if duration < 0 || duration > 65535
                return tasmota.resp_cmnd_str("Invalid: range 0-65535 ms")
            end
            
            var hex_cmd = f"07{(duration >> 8) & 0xFF:02X}{duration & 0xFF:02X}"
            return lwdecode.SendDownlink(global.SE01_LB_nodes, cmd, idx, hex_cmd)
        end)
        
        tasmota.remove_cmd("LwSE01CountValue")
        tasmota.add_cmd("LwSE01CountValue", def(cmd, idx, payload_str)
            var count = int(payload_str)
            
            var hex_cmd = f"09{(count >> 24) & 0xFF:02X}{(count >> 16) & 0xFF:02X}"
            hex_cmd += f"{(count >> 8) & 0xFF:02X}{count & 0xFF:02X}"
            
            return lwdecode.SendDownlink(global.SE01_LB_nodes, cmd, idx, hex_cmd)
        end)
        
        tasmota.remove_cmd("LwSE01WorkMode")
        tasmota.add_cmd("LwSE01WorkMode", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.SE01_LB_nodes, cmd, idx, payload_str, {
                '0|CALIBRATED': ['0A00', 'Calibrated Values'],
                '1|RAW': ['0A01', 'Raw ADC Values']
            })
        end)
        
        tasmota.remove_cmd("LwSE01CountMode")
        tasmota.add_cmd("LwSE01CountMode", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.SE01_LB_nodes, cmd, idx, payload_str, {
                '0|INTERRUPT': ['1000', 'Interrupt Mode'],
                '1|COUNTING': ['1001', 'Counting Mode']
            })
        end)
        
        tasmota.remove_cmd("LwSE01Status")
        tasmota.add_cmd("LwSE01Status", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.SE01_LB_nodes, cmd, idx, "2601")
        end)
        
        print("SE01-LB: Downlink commands registered")
    end
end

LwDeco = LwDecode_SE01_LB()

tasmota.remove_cmd("LwSE01NodeStats")
tasmota.add_cmd("LwSE01NodeStats", def(cmd, idx, node_id)
    var stats = LwDeco.get_node_stats(node_id)
    if stats != nil
        import json
        tasmota.resp_cmnd(json.dump(stats))
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

tasmota.remove_cmd("LwSE01ClearNode")
tasmota.add_cmd("LwSE01ClearNode", def(cmd, idx, node_id)
    if LwDeco.clear_node_data(node_id)
        tasmota.resp_cmnd_done()
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

tasmota.remove_cmd("LwSE01TestUI")
tasmota.add_cmd("LwSE01TestUI", def(cmd, idx, payload_str)
    var test_scenarios = {
        "normal":     "0F501F4017700FA000",        # Port 2: 39.5°C air, 80%moisture, 23.2°C soil, 6000μS/cm EC
        "dry":        "0F5000C817700FA000",        # Port 2: Low moisture 20%
        "wet":        "0F5027101F4017700FA000",    # Port 2: High moisture 100%
        "cold":       "0F50FA0013880FA000",        # Port 2: -15°C air temp, 50% moisture
        "raw_mode":   "0F5003E800C89C400FA010",    # Port 2: Raw mode (MOD=1)
        "counting":   "0F501F4017700FA000000003E8", # Port 2: Counting mode with 1000 count
        "config":     "2602000100FA0",             # Port 5: Device status
        "datalog":    "1F4017700000000061A0B580",  # Port 3: Historical data
        "disconnect": "7FFF1F4017700FA000",        # Port 2: DS18B20 disconnected
        "demo":       "0F501F4017700FA000"         # Port 2: Comprehensive demo
    }
    
    var hex_payload = test_scenarios.find(payload_str ? payload_str : 'nil', 'not_found')
    
    if hex_payload == 'not_found'
        var scenarios_list = "normal dry wet cold raw_mode counting config datalog disconnect demo "
        return tasmota.resp_cmnd_str(f"Available scenarios: {scenarios_list}")
    end
    
    var rssi = -75
    var fport = 2
    if payload_str == "config" fport = 5 end
    if payload_str == "datalog" fport = 3 end

    return tasmota.cmd(f'LwSimulate{idx} {rssi},{fport},{hex_payload}')
end)

tasmota.add_driver(LwDeco)