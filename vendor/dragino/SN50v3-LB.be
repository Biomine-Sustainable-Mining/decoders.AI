#
# LoRaWAN AI-Generated Decoder for Dragino SN50v3-LB Prompted by ZioFabry 
#
# Generated: 2025-09-02 | Version: 1.3.0 | Revision: REV3
#            by "LoRaWAN Decoder AI Generation Template", v2.5.0
#
# Homepage:  https://wiki.dragino.com/xwiki/bin/view/Main/User%20Manual%20for%20LoRaWAN%20End%20Nodes/SN50v3-LB/
# Userguide: https://wiki.dragino.com/xwiki/bin/view/Main/User%20Manual%20for%20LoRaWAN%20End%20Nodes/SN50v3-LB/
# Decoder:   https://wiki.dragino.com/xwiki/bin/view/Main/User%20Manual%20for%20LoRaWAN%20End%20Nodes/SN50v3-LB/
# 
# v1.3.0 (2025-09-02): Template v2.5.0 upgrade with TestUI payload verification
# v1.2.0 (2025-09-02): Framework v2.4.1 upgrade with critical Berry keys() fixes
# v1.1.0 (2025-08-20): Enhanced display with working mode support
# v1.0.0 (2025-08-20): Initial generation from MAP specification

class LwDecode_SN50v3LB
    var hashCheck, name, node, last_data, last_update, lwdecode

    def init()
        self.hashCheck = true
        self.name = nil
        self.node = nil
        self.last_data = {}
        self.last_update = 0
        
        import global
        if !global.contains("SN50v3LB_nodes")
            global.SN50v3LB_nodes = {}
        end
        if !global.contains("SN50v3LB_cmdInit")
            global.SN50v3LB_cmdInit = false
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
            
            var node_data = global.SN50v3LB_nodes.find(node, {})
            var previous_data = node_data.find('last_data', {})
            
            if size(previous_data) > 0
                for key: ['battery_v', 'ds18b20_temp', 'sht31_temp', 'sht31_humidity', 'adc_value', 
                         'distance', 'weight', 'count_value', 'working_mode', 'firmware_version',
                         'frequency_band', 'subband', 'digital_input', 'temp117_temp']
                    if previous_data.contains(key)
                        data[key] = previous_data[key]
                    end
                end
            end
            
            if fport == 5
                # Device Status
                if size(payload) >= 7
                    data['sensor_model'] = payload[0]
                    var fw_high = payload[1]
                    var fw_low = payload[2]
                    data['firmware_version'] = f"{fw_high & 0x0F}.{(fw_low >> 4) & 0x0F}.{fw_low & 0x0F}"
                    
                    var freq_bands = {
                        0x01: "EU868", 0x02: "US915", 0x03: "IN865", 0x04: "AU915",
                        0x05: "KZ865", 0x06: "RU864", 0x07: "AS923", 0x08: "AS923-1",
                        0x09: "AS923-2", 0x0A: "AS923-3", 0x0B: "CN470", 0x0C: "EU433",
                        0x0D: "KR920", 0x0E: "MA869"
                    }
                    data['frequency_band'] = freq_bands.find(payload[3], f"Unknown({payload[3]:02X})")
                    data['subband'] = payload[4]
                    
                    var battery_mv = (payload[5] << 8) | payload[6]
                    data['battery_v'] = battery_mv / 1000.0
                end
                
            elif fport == 2
                var payload_size = size(payload)
                var battery_mv = (payload[0] << 8) | payload[1]
                data['battery_v'] = battery_mv / 1000.0
                
                if payload_size == 11
                    var ds18b20_raw = (payload[2] << 8) | payload[3]
                    if ds18b20_raw > 32767
                        ds18b20_raw = ds18b20_raw - 65536
                    end
                    data['ds18b20_temp'] = ds18b20_raw / 10.0
                    
                    var adc_value = (payload[4] << 8) | payload[5]
                    data['adc_value'] = adc_value
                    data['digital_input'] = payload[6]
                    
                    var high_bytes = (payload[7] << 8) | payload[8]
                    var low_bytes = (payload[9] << 8) | payload[10]
                    
                    if high_bytes >= 240 && high_bytes <= 6000 && low_bytes == 0
                        data['working_mode'] = "Distance"
                        data['distance'] = high_bytes
                    elif payload[6] == 0 || payload[6] == 1
                        var weight = (payload[7] << 24) | (payload[8] << 16) | (payload[9] << 8) | payload[10]
                        data['working_mode'] = "Weight"
                        data['weight'] = weight
                    elif high_bytes == 0 || low_bytes > 1000
                        var count = (payload[7] << 24) | (payload[8] << 16) | (payload[9] << 8) | payload[10]
                        data['working_mode'] = "Counting"
                        data['count_value'] = count
                    elif high_bytes > -400 && high_bytes < 850
                        data['working_mode'] = "SHT31"
                        var sht31_temp_raw = high_bytes
                        if sht31_temp_raw > 32767
                            sht31_temp_raw = sht31_temp_raw - 65536
                        end
                        data['sht31_temp'] = sht31_temp_raw / 10.0
                        data['sht31_humidity'] = low_bytes / 10.0
                    elif low_bytes == 0
                        data['working_mode'] = "TEMP117"
                        var temp117_raw = high_bytes
                        if temp117_raw > 32767
                            temp117_raw = temp117_raw - 65536
                        end
                        data['temp117_temp'] = temp117_raw / 10.0
                    else
                        data['working_mode'] = "Default"
                        var sht_temp_raw = high_bytes
                        if sht_temp_raw > 32767
                            sht_temp_raw = sht_temp_raw - 65536
                        end
                        data['sht31_temp'] = sht_temp_raw / 10.0
                        data['sht31_humidity'] = low_bytes / 10.0
                    end
                    
                elif payload_size == 12
                    data['working_mode'] = "3ADC+I2C"
                    data['adc1_value'] = (payload[0] << 8) | payload[1]
                    data['adc2_value'] = (payload[2] << 8) | payload[3]
                    data['adc3_value'] = (payload[4] << 8) | payload[5]
                    data['digital_interrupt'] = payload[6]
                    
                    var i2c_temp_raw = (payload[7] << 8) | payload[8]
                    if i2c_temp_raw > 32767
                        i2c_temp_raw = i2c_temp_raw - 65536
                    end
                    data['sht31_temp'] = i2c_temp_raw / 10.0
                    data['sht31_humidity'] = ((payload[9] << 8) | payload[10]) / 10.0
                    data['battery_v'] = payload[11] / 10.0
                    
                elif payload_size == 9
                    data['working_mode'] = "3Interrupt"
                    var battery_mv = (payload[0] << 8) | payload[1]
                    data['battery_v'] = battery_mv / 1000.0
                    
                    var ds18b20_raw = (payload[2] << 8) | payload[3]
                    if ds18b20_raw > 32767
                        ds18b20_raw = ds18b20_raw - 65536
                    end
                    data['ds18b20_temp'] = ds18b20_raw / 10.0
                    
                    data['adc_value'] = (payload[4] << 8) | payload[5]
                    data['interrupt1'] = payload[6]
                    data['interrupt2'] = payload[7]
                    data['interrupt3'] = payload[8]
                    
                elif payload_size == 17
                    data['working_mode'] = "3DS18B20+2Count"
                    var battery_mv = (payload[0] << 8) | payload[1]
                    data['battery_v'] = battery_mv / 1000.0
                    
                    var temp1_raw = (payload[2] << 8) | payload[3]
                    if temp1_raw > 32767
                        temp1_raw = temp1_raw - 65536
                    end
                    data['ds18b20_temp1'] = temp1_raw / 10.0
                    
                    var temp2_raw = (payload[4] << 8) | payload[5]
                    if temp2_raw > 32767
                        temp2_raw = temp2_raw - 65536
                    end
                    data['ds18b20_temp2'] = temp2_raw / 10.0
                    
                    data['digital_interrupt'] = payload[6]
                    
                    var temp3_raw = (payload[7] << 8) | payload[8]
                    if temp3_raw > 32767
                        temp3_raw = temp3_raw - 65536
                    end
                    data['ds18b20_temp3'] = temp3_raw / 10.0
                    
                    data['count1_value'] = (payload[9] << 24) | (payload[10] << 16) | (payload[11] << 8) | payload[12]
                    data['count2_value'] = (payload[13] << 24) | (payload[14] << 16) | (payload[15] << 8) | payload[16]
                    
                else
                    data['working_mode'] = "Unknown"
                end
            end
            
            node_data['last_data'] = data
            node_data['last_update'] = tasmota.rtc()['local']
            node_data['name'] = name
            
            if data.contains('battery_v')
                if !node_data.contains('battery_history')
                    node_data['battery_history'] = []
                end
                node_data['battery_history'].push(data['battery_v'])
                if size(node_data['battery_history']) > 10
                    node_data['battery_history'].pop(0)
                end
            end
            
            if !global.contains("SN50v3LB_cmdInit") || !global.SN50v3LB_cmdInit
                self.register_downlink_commands()
                global.SN50v3LB_cmdInit = true
            end

            global.SN50v3LB_nodes[node] = node_data
            
            self.last_data = data
            self.last_update = node_data['last_update']
            
            return data
            
        except .. as e, m
            print(f"SN50v3LB: Decode error - {e}: {m}")
            return nil
        end
    end
    
    def add_web_sensor()
        import global
        
        try
            var data_to_show = self.last_data
            var last_update = self.last_update
            
            if size(data_to_show) == 0 && self.node != nil
                var node_data = global.SN50v3LB_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            if size(data_to_show) == 0 && size(global.SN50v3LB_nodes) > 0
                var found_node = false
                for node_id: global.SN50v3LB_nodes.keys()
                    if !found_node
                        var node_data = global.SN50v3LB_nodes[node_id]
                        data_to_show = node_data.find('last_data', {})
                        last_update = node_data.find('last_update', 0)
                        self.node = node_id
                        self.name = node_data.find('name', f"SN50v3LB-{node_id}")
                        found_node = true
                    end
                end
            end
            
            if size(data_to_show) == 0 return nil end
            
            import string
            var msg = ""
            var fmt = LwSensorFormatter_cls()
            
            var name = self.name
            if name == nil || name == ""
                name = f"SN50v3LB-{self.node}"
            end
            var name_tooltip = "Dragino SN50v3-LB"
            var battery = data_to_show.find('battery_v', 1000)
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)
            var simulated = data_to_show.find('simulated', false)
            
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            
            fmt.start_line()
            
            if data_to_show.contains('battery_v')
                fmt.add_sensor("volt", data_to_show['battery_v'], "Battery", "🔋")
            end
            
            if data_to_show.contains('working_mode')
                var mode_emoji = {
                    "Default": "🔧", "Distance": "📏", "Weight": "⚖️", "Counting": "🔢",
                    "SHT31": "🌡️", "3ADC+I2C": "📊", "3DS18B20": "🌡️", "3Interrupt": "⚡",
                    "3DS18B20+2Count": "🔢", "PWM": "⚡", "TEMP117": "🌡️"
                }.find(data_to_show['working_mode'], "⚙️")
                fmt.add_sensor("string", data_to_show['working_mode'], "Mode", mode_emoji)
            end
            
            if data_to_show.contains('ds18b20_temp')
                fmt.add_sensor("temp", data_to_show['ds18b20_temp'], "DS18B20", "🌡️")
            end
            
            if data_to_show.contains('sht31_temp')
                fmt.add_sensor("temp", data_to_show['sht31_temp'], "Temp", "🌡️")
            end
            
            if data_to_show.contains('temp117_temp')
                fmt.add_sensor("temp", data_to_show['temp117_temp'], "TEMP117", "🌡️")
            end
            
            if data_to_show.contains('sht31_humidity')
                fmt.add_sensor("humidity", data_to_show['sht31_humidity'], "Humidity", "💧")
            end
            
            if data_to_show.contains('distance')
                fmt.add_sensor("distance", data_to_show['distance'] / 1000.0, "Distance", "📏")
            end
            
            if data_to_show.contains('weight')
                var weight_kg = data_to_show['weight'] / 1000.0
                fmt.add_sensor("string", f"{weight_kg:.1f}kg", "Weight", "⚖️")
            end
            
            if data_to_show.contains('count_value')
                fmt.add_sensor("string", f"{data_to_show['count_value']}", "Count", "🔢")
            end
            
            fmt.next_line()
            
            var has_secondary = false
            
            if data_to_show.contains('ds18b20_temp1')
                fmt.add_sensor("temp", data_to_show['ds18b20_temp1'], "T1", "🌡️")
                has_secondary = true
            end
            
            if data_to_show.contains('ds18b20_temp2')
                fmt.add_sensor("temp", data_to_show['ds18b20_temp2'], "T2", "🌡️")
                has_secondary = true
            end
            
            if data_to_show.contains('ds18b20_temp3')
                fmt.add_sensor("temp", data_to_show['ds18b20_temp3'], "T3", "🌡️")
                has_secondary = true
            end
            
            if data_to_show.contains('count1_value')
                fmt.add_sensor("string", f"{data_to_show['count1_value']}", "C1", "🔢")
                has_secondary = true
            end
            
            if data_to_show.contains('count2_value')
                fmt.add_sensor("string", f"{data_to_show['count2_value']}", "C2", "🔢")
                has_secondary = true
            end
            
            if data_to_show.contains('adc1_value')
                fmt.add_sensor("string", f"{data_to_show['adc1_value']}", "ADC1", "📊")
                has_secondary = true
            end
            
            if data_to_show.contains('adc2_value')
                fmt.add_sensor("string", f"{data_to_show['adc2_value']}", "ADC2", "📊")
                has_secondary = true
            end
            
            if data_to_show.contains('adc3_value')
                fmt.add_sensor("string", f"{data_to_show['adc3_value']}", "ADC3", "📊")
                has_secondary = true
            end
            
            if data_to_show.contains('firmware_version') || data_to_show.contains('frequency_band')
                if has_secondary
                    fmt.next_line()
                end
                
                if data_to_show.contains('firmware_version')
                    fmt.add_sensor("string", data_to_show['firmware_version'], "FW", "💾")
                end
                
                if data_to_show.contains('frequency_band')
                    fmt.add_sensor("string", data_to_show['frequency_band'], "Band", "📡")
                end
            end
            
            fmt.end_line()
            
            if last_update > 0
                var age = tasmota.rtc()['local'] - last_update
                if age > 3600
                    fmt.start_line()
                    fmt.add_status(self.format_age(age), "⏱️", nil)
                    fmt.end_line()
                end
            end
            
            msg += fmt.get_msg()
            return msg
            
        except .. as e, m
            print(f"SN50v3LB: Display error - {e}: {m}")
            return "📟 SN50v3LB Error - Check Console"
        end
    end
    
    def format_age(seconds)
        if seconds < 60 return f"{seconds}s ago"
        elif seconds < 3600 return f"{seconds/60}m ago"
        elif seconds < 86400 return f"{seconds/3600}h ago"
        else return f"{seconds/86400}d ago"
        end
    end
    
    def get_node_stats(node_id)
        import global
        var node_data = global.SN50v3LB_nodes.find(node_id, nil)
        if node_data == nil return nil end
        
        return {
            'last_update': node_data.find('last_update', 0),
            'battery_history': node_data.find('battery_history', []),
            'name': node_data.find('name', 'Unknown')
        }
    end
    
    def clear_node_data(node_id)
        import global
        if global.SN50v3LB_nodes.contains(node_id)
            global.SN50v3LB_nodes.remove(node_id)
            return true
        end
        return false
    end
    
    def register_downlink_commands()
        import string
        
        tasmota.remove_cmd("LwSN50v3LBInterval")
        tasmota.add_cmd("LwSN50v3LBInterval", def(cmd, idx, payload_str)
            var interval = int(payload_str)
            if interval < 30 || interval > 16777215
                return tasmota.resp_cmnd_str("Invalid: range 30-16777215 seconds")
            end
            
            var hex_cmd = f"01{(interval >> 16) & 0xFF:02X}{(interval >> 8) & 0xFF:02X}{interval & 0xFF:02X}"
            return lwdecode.SendDownlink(global.SN50v3LB_nodes, cmd, idx, hex_cmd)
        end)
        
        tasmota.remove_cmd("LwSN50v3LBStatus")
        tasmota.add_cmd("LwSN50v3LBStatus", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.SN50v3LB_nodes, cmd, idx, "2601")
        end)
        
        tasmota.remove_cmd("LwSN50v3LBMode")
        tasmota.add_cmd("LwSN50v3LBMode", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.SN50v3LB_nodes, cmd, idx, payload_str, { 
                '1|DEFAULT': ['0A01', 'DEFAULT'], '2|DISTANCE': ['0A02', 'DISTANCE'], 
                '3|3ADC': ['0A03', '3ADC'], '4|3DS18B20': ['0A04', '3DS18B20'],
                '5|WEIGHT': ['0A05', 'WEIGHT'], '6|COUNTING': ['0A06', 'COUNTING'],
                '7|3INTERRUPT': ['0A07', '3INTERRUPT'], '8|3ADCDS18B20': ['0A08', '3ADCDS18B20'],
                '9|3DS18B202COUNT': ['0A09', '3DS18B202COUNT'], '10|PWM': ['0A0A', 'PWM'],
                '11|TEMP117': ['0A0B', 'TEMP117'], '12|COUNTSHT31': ['0A0C', 'COUNTSHT31']
            })
        end)
        
        tasmota.remove_cmd("LwSN50v3LBInterrupt")
        tasmota.add_cmd("LwSN50v3LBInterrupt", def(cmd, idx, payload_str)
            var parts = string.split(payload_str, ',')
            if size(parts) < 2 || size(parts) > 3
                return tasmota.resp_cmnd_str("Usage: pin,mode[,delay_ms] (pin: 0-2, mode: 0-3)")
            end
            
            var pin = int(parts[0])
            var mode = int(parts[1])
            var delay_ms = size(parts) > 2 ? int(parts[2]) : 0
            
            if pin < 0 || pin > 2 || mode < 0 || mode > 3
                return tasmota.resp_cmnd_str("Invalid: pin 0-2, mode 0-3")
            end
            
            var hex_cmd = f"0600{pin:02X}{mode:02X}"
            if delay_ms > 0
                hex_cmd += f"{(delay_ms >> 8) & 0xFF:02X}{delay_ms & 0xFF:02X}"
            end
            
            return lwdecode.SendDownlink(global.SN50v3LB_nodes, cmd, idx, hex_cmd)
        end)
        
        tasmota.remove_cmd("LwSN50v3LBOutput")
        tasmota.add_cmd("LwSN50v3LBOutput", def(cmd, idx, payload_str)
            var duration = int(payload_str)
            if duration < 0 || duration > 65535
                return tasmota.resp_cmnd_str("Invalid: range 0-65535 ms")
            end
            
            var hex_cmd = f"07{(duration >> 8) & 0xFF:02X}{duration & 0xFF:02X}"
            return lwdecode.SendDownlink(global.SN50v3LB_nodes, cmd, idx, hex_cmd)
        end)
        
        tasmota.remove_cmd("LwSN50v3LBWeight")
        tasmota.add_cmd("LwSN50v3LBWeight", def(cmd, idx, payload_str)
            if payload_str == "zero" || payload_str == "0"
                return lwdecode.SendDownlink(global.SN50v3LB_nodes, cmd, idx, "0801")
            else
                var factor = real(payload_str) * 10
                var factor_int = int(factor)
                var hex_cmd = f"0802{(factor_int >> 16) & 0xFF:02X}{(factor_int >> 8) & 0xFF:02X}{factor_int & 0xFF:02X}"
                return lwdecode.SendDownlink(global.SN50v3LB_nodes, cmd, idx, hex_cmd)
            end
        end)
        
        tasmota.remove_cmd("LwSN50v3LBSetCount")
        tasmota.add_cmd("LwSN50v3LBSetCount", def(cmd, idx, payload_str)
            var parts = string.split(payload_str, ',')
            if size(parts) != 2
                return tasmota.resp_cmnd_str("Usage: count_select,value (1-2, 0-4294967295)")
            end
            
            var count_select = int(parts[0])
            var count_value = int(parts[1])
            
            if count_select < 1 || count_select > 2
                return tasmota.resp_cmnd_str("Invalid count_select: use 1 or 2")
            end
            
            var hex_cmd = f"09{count_select:02X}{(count_value >> 24) & 0xFF:02X}{(count_value >> 16) & 0xFF:02X}{(count_value >> 8) & 0xFF:02X}{count_value & 0xFF:02X}"
            return lwdecode.SendDownlink(global.SN50v3LB_nodes, cmd, idx, hex_cmd)
        end)
        
        print("SN50v3LB: Downlink commands registered")
    end
end

# Global instance
LwDeco = LwDecode_SN50v3LB()

# Node management commands
tasmota.remove_cmd("LwSN50v3LBNodeStats")
tasmota.add_cmd("LwSN50v3LBNodeStats", def(cmd, idx, node_id)
    var stats = LwDeco.get_node_stats(node_id)
    if stats != nil
        import json
        tasmota.resp_cmnd(json.dump(stats))
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

tasmota.remove_cmd("LwSN50v3LBClearNode")
tasmota.add_cmd("LwSN50v3LBClearNode", def(cmd, idx, node_id)
    if LwDeco.clear_node_data(node_id)
        tasmota.resp_cmnd_done()
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

# TestUI command with payload verification
tasmota.remove_cmd("LwSN50v3LBTestUI")
tasmota.add_cmd("LwSN50v3LBTestUI", def(cmd, idx, payload_str)
    var test_scenarios = {
        "normal":    "0C800AE6001F4700022C0384",
        "distance":  "0C800AE6001F47000BB8000000",
        "weight":    "0C800AE6001F470000001388",
        "counting":  "0C800AE6001F470000000064",
        "3adc":      "021F0200030400054600070008C9",
        "3ds18b20":  "0C800AE6001F47000A140CDED8",
        "interrupt": "0C800AE6001F470001020103",
        "temp117":   "0C800AE6001F47000ABE000000",
        "status":    "1C0100050C80",
        "multi":     "0C800AE6001F070000000064000000000001F4"
    }
    
    var hex_payload = test_scenarios.find(payload_str ? payload_str : 'nil', 'not_found')
    
    if hex_payload == 'not_found'
        var scenarios_list = "normal distance weight counting 3adc 3ds18b20 interrupt temp117 status multi "
        return tasmota.resp_cmnd_str(format("Available scenarios: %s", scenarios_list))
    end
    
    var rssi = -85
    var fport = payload_str == "status" ? 5 : 2

    return tasmota.cmd(f'LwSimulate{idx} {rssi},{fport},{hex_payload}')
end)

# MANDATORY: Register driver for web UI integration
tasmota.add_driver(LwDeco)