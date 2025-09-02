#
# LoRaWAN AI-Generated Decoder for Milesight AM308L Prompted by ZioFabry 
#
# Generated: 2025-09-02 | Version: 1.2.0 | Revision: REV2
#            by "LoRaWAN Decoder AI Generation Template", v2.5.0
#
# Homepage:  https://www.milesight.com/iot/product/lorawan-sensor/am319
# Userguide: https://github.com/Milesight-IoT/SensorDecoders/tree/main/am-series/am308l
# Decoder:   https://github.com/Milesight-IoT/SensorDecoders/tree/main/am-series/am308l
# 
# v1.2.0 (2025-09-02): Template v2.5.0 upgrade with TestUI payload verification
# v1.1.0 (2025-09-02): Framework v2.4.1 upgrade with critical Berry keys() fixes
# v1.0.0 (2025-08-26): Initial generation from repository specifications

class LwDecode_AM308L
    var hashCheck, name, node, last_data, last_update, lwdecode

    def init()
        self.hashCheck = true
        self.name = nil
        self.node = nil
        self.last_data = {}
        self.last_update = 0
        
        import global
        if !global.contains("AM308L_nodes")
            global.AM308L_nodes = {}
        end
        if !global.contains("AM308L_cmdInit")
            global.AM308L_cmdInit = false
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
            
            var node_data = global.AM308L_nodes.find(node, {})
            var previous_data = node_data.find('last_data', {})
            
            if size(previous_data) > 0
                for key: ['battery_pct', 'temperature', 'humidity', 'pir_motion', 'light_level', 
                         'co2_ppm', 'tvoc_iaq', 'tvoc_ugm3', 'pressure_hpa', 'pm25_ugm3',
                         'pm10_ugm3', 'buzzer_status', 'device_status', 'firmware_version', 
                         'hardware_version', 'serial_number', 'lorawan_class', 'reset_event']
                    if previous_data.contains(key)
                        data[key] = previous_data[key]
                    end
                end
            end
            
            # Handle history data first
            if size(payload) >= 20 && payload[0] == 0x20 && payload[1] == 0xCE
                return self.decode_history_iaq(payload, data)
            elif size(payload) >= 20 && payload[0] == 0x21 && payload[1] == 0xCE
                return self.decode_history_ugm3(payload, data)
            end
            
            # Standard multi-channel protocol
            var i = 0
            while i < size(payload)
                if i + 1 >= size(payload) break end
                
                var channel_id = payload[i]
                var channel_type = payload[i+1]
                i += 2
                
                if channel_id == 0x01 && channel_type == 0x75
                    if i < size(payload)
                        data['battery_pct'] = payload[i]
                        i += 1
                    end
                    
                elif channel_id == 0x03 && channel_type == 0x67
                    if i + 1 < size(payload)
                        var temp_raw = (payload[i+1] << 8) | payload[i]
                        if temp_raw > 32767
                            temp_raw = temp_raw - 65536
                        end
                        data['temperature'] = temp_raw / 10.0
                        i += 2
                    end
                    
                elif channel_id == 0x04 && channel_type == 0x68
                    if i < size(payload)
                        data['humidity'] = payload[i] / 2.0
                        i += 1
                    end
                    
                elif channel_id == 0x05 && channel_type == 0x00
                    if i < size(payload)
                        data['pir_motion'] = payload[i] == 1
                        i += 1
                    end
                    
                elif channel_id == 0x06 && channel_type == 0xcb
                    if i < size(payload)
                        data['light_level'] = payload[i]
                        i += 1
                    end
                    
                elif channel_id == 0x07 && channel_type == 0x7d
                    if i + 1 < size(payload)
                        data['co2_ppm'] = (payload[i+1] << 8) | payload[i]
                        i += 2
                    end
                    
                elif channel_id == 0x08 && channel_type == 0x7d
                    if i + 1 < size(payload)
                        data['tvoc_iaq'] = ((payload[i+1] << 8) | payload[i]) / 100.0
                        i += 2
                    end
                    
                elif channel_id == 0x08 && channel_type == 0xe6
                    if i + 1 < size(payload)
                        data['tvoc_ugm3'] = (payload[i+1] << 8) | payload[i]
                        i += 2
                    end
                    
                elif channel_id == 0x09 && channel_type == 0x73
                    if i + 1 < size(payload)
                        data['pressure_hpa'] = ((payload[i+1] << 8) | payload[i]) / 10.0
                        i += 2
                    end
                    
                elif channel_id == 0x0b && channel_type == 0x7d
                    if i + 1 < size(payload)
                        data['pm25_ugm3'] = (payload[i+1] << 8) | payload[i]
                        i += 2
                    end
                    
                elif channel_id == 0x0c && channel_type == 0x7d
                    if i + 1 < size(payload)
                        data['pm10_ugm3'] = (payload[i+1] << 8) | payload[i]
                        i += 2
                    end
                    
                elif channel_id == 0x0e && channel_type == 0x01
                    if i < size(payload)
                        data['buzzer_status'] = payload[i] == 1
                        i += 1
                    end
                    
                elif channel_id == 0xff
                    # Device info channels
                    if channel_type == 0x01
                        if i < size(payload)
                            data['ipso_version'] = f"{payload[i] >> 4}.{payload[i] & 0x0F}"
                            i += 1
                        end
                    elif channel_type == 0x09
                        if i + 1 < size(payload)
                            data['hardware_version'] = f"v{payload[i]}.{payload[i+1]}"
                            i += 2
                        end
                    elif channel_type == 0x0a
                        if i + 1 < size(payload)
                            data['firmware_version'] = f"v{payload[i]}.{payload[i+1]}"
                            i += 2
                        end
                    elif channel_type == 0xff
                        if i + 1 < size(payload)
                            data['tsl_version'] = f"v{payload[i]}.{payload[i+1]}"
                            i += 2
                        end
                    elif channel_type == 0x16
                        if i + 7 < size(payload)
                            var serial = ""
                            for j: i..(i+7)
                                serial += f"{payload[j]:02X}"
                            end
                            data['serial_number'] = serial
                            i += 8
                        end
                    elif channel_type == 0x0f
                        if i < size(payload)
                            var class_map = {0: "A", 1: "B", 2: "C", 3: "CtoB"}
                            data['lorawan_class'] = class_map.find(payload[i], f"Unknown({payload[i]})")
                            i += 1
                        end
                    elif channel_type == 0xfe
                        if i < size(payload)
                            data['reset_event'] = payload[i] == 1
                            i += 1
                        end
                    elif channel_type == 0x0b
                        if i < size(payload)
                            data['device_status'] = payload[i] == 1
                            i += 1
                        end
                    else
                        print(f"AM308L: Unknown FF channel type {channel_type:02X}")
                        break
                    end
                else
                    print(f"AM308L: Unknown channel {channel_id:02X}:{channel_type:02X}")
                    break
                end
            end
            
            node_data['last_data'] = data
            node_data['last_update'] = tasmota.rtc()['local']
            node_data['name'] = name
            
            if data.contains('battery_pct')
                if !node_data.contains('battery_history')
                    node_data['battery_history'] = []
                end
                node_data['battery_history'].push(data['battery_pct'])
                if size(node_data['battery_history']) > 10
                    node_data['battery_history'].pop(0)
                end
            end
            
            if data.contains('reset_event') && data['reset_event']
                node_data['reset_count'] = node_data.find('reset_count', 0) + 1
                node_data['last_reset'] = tasmota.rtc()['local']
            end
            
            if !global.contains("AM308L_cmdInit") || !global.AM308L_cmdInit
                self.register_downlink_commands()
                global.AM308L_cmdInit = true
            end

            global.AM308L_nodes[node] = node_data
            
            self.last_data = data
            self.last_update = node_data['last_update']
            
            return data
            
        except .. as e, m
            print(f"AM308L: Decode error - {e}: {m}")
            return nil
        end
    end
    
    def decode_history_iaq(payload, data)
        if size(payload) < 22 return nil end
        
        data['history_type'] = "IAQ"
        data['timestamp'] = (payload[5] << 24) | (payload[4] << 16) | (payload[3] << 8) | payload[2]
        
        var temp_raw = (payload[7] << 8) | payload[6]
        if temp_raw > 32767
            temp_raw = temp_raw - 65536
        end
        data['temperature'] = temp_raw / 10.0
        data['humidity'] = payload[8] / 2.0
        data['pir_motion'] = payload[9] == 1
        data['light_level'] = payload[10]
        data['co2_ppm'] = (payload[12] << 8) | payload[11]
        data['tvoc_iaq'] = ((payload[14] << 8) | payload[13]) / 100.0
        data['pressure_hpa'] = ((payload[16] << 8) | payload[15]) / 10.0
        data['pm25_ugm3'] = (payload[18] << 8) | payload[17]
        data['pm10_ugm3'] = (payload[20] << 8) | payload[19]
        
        return data
    end
    
    def decode_history_ugm3(payload, data)
        if size(payload) < 22 return nil end
        
        data['history_type'] = "µg/m³"
        data['timestamp'] = (payload[5] << 24) | (payload[4] << 16) | (payload[3] << 8) | payload[2]
        
        var temp_raw = (payload[7] << 8) | payload[6]
        if temp_raw > 32767
            temp_raw = temp_raw - 65536
        end
        data['temperature'] = temp_raw / 10.0
        data['humidity'] = payload[8] / 2.0
        data['pir_motion'] = payload[9] == 1
        data['light_level'] = payload[10]
        data['co2_ppm'] = (payload[12] << 8) | payload[11]
        data['tvoc_ugm3'] = (payload[14] << 8) | payload[13]
        data['pressure_hpa'] = ((payload[16] << 8) | payload[15]) / 10.0
        data['pm25_ugm3'] = (payload[18] << 8) | payload[17]
        data['pm10_ugm3'] = (payload[20] << 8) | payload[19]
        
        return data
    end
    
    def add_web_sensor()
        import global
        
        try
            var data_to_show = self.last_data
            var last_update = self.last_update
            
            if size(data_to_show) == 0 && self.node != nil
                var node_data = global.AM308L_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            if size(data_to_show) == 0 && size(global.AM308L_nodes) > 0
                var found_node = false
                for node_id: global.AM308L_nodes.keys()
                    if !found_node
                        var node_data = global.AM308L_nodes[node_id]
                        data_to_show = node_data.find('last_data', {})
                        last_update = node_data.find('last_update', 0)
                        self.node = node_id
                        self.name = node_data.find('name', f"AM308L-{node_id}")
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
                name = f"AM308L-{self.node}"
            end
            var name_tooltip = "Milesight AM308L"
            var battery = data_to_show.contains('battery_pct') ? data_to_show['battery_pct'] / 100.0 * 4.2 : 1000
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)
            var simulated = data_to_show.find('simulated', false)
            
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            
            # Environmental sensors line
            fmt.start_line()
            
            if data_to_show.contains('temperature')
                fmt.add_sensor("temp", data_to_show['temperature'], "Temperature", "🌡️")
            end
            
            if data_to_show.contains('humidity')
                fmt.add_sensor("humidity", data_to_show['humidity'], "Humidity", "💧")
            end
            
            if data_to_show.contains('pressure_hpa')
                fmt.add_sensor("pressure", data_to_show['pressure_hpa'], "Pressure", "🔵")
            end
            
            if data_to_show.contains('light_level')
                fmt.add_sensor("string", f"{data_to_show['light_level']}", "Light", "💡")
            end
            
            fmt.next_line()
            
            # Air quality sensors line
            if data_to_show.contains('co2_ppm')
                fmt.add_sensor("co2", data_to_show['co2_ppm'], "CO2", "💨")
            end
            
            if data_to_show.contains('tvoc_iaq')
                fmt.add_sensor("string", f"{data_to_show['tvoc_iaq']:.1f} IAQ", "TVOC", "🌬️")
            elif data_to_show.contains('tvoc_ugm3')
                fmt.add_sensor("string", f"{data_to_show['tvoc_ugm3']}μg/m³", "TVOC", "🌬️")
            end
            
            fmt.next_line()
            
            # Particulate matter line
            if data_to_show.contains('pm25_ugm3')
                fmt.add_sensor("string", f"{data_to_show['pm25_ugm3']}μg/m³", "PM2.5", "🌫️")
            end
            
            if data_to_show.contains('pm10_ugm3')
                fmt.add_sensor("string", f"{data_to_show['pm10_ugm3']}μg/m³", "PM10", "🌫️")
            end
            
            # Status and info line
            var has_status = false
            
            if data_to_show.contains('pir_motion')
                var motion_emoji = data_to_show['pir_motion'] ? "🚶" : "🏠"
                var motion_text = data_to_show['pir_motion'] ? "Motion" : "Idle"
                fmt.add_sensor("string", motion_text, "PIR", motion_emoji)
                has_status = true
            end
            
            if data_to_show.contains('buzzer_status') && data_to_show['buzzer_status']
                fmt.add_sensor("string", "Buzzer ON", "Alert", "🔔")
                has_status = true
            end
            
            if data_to_show.contains('history_type')
                fmt.add_sensor("string", f"Hist:{data_to_show['history_type']}", "Data", "📊")
                has_status = true
            end
            
            if data_to_show.contains('firmware_version')
                fmt.add_sensor("string", data_to_show['firmware_version'], "FW", "💾")
                has_status = true
            end
            
            if has_status
                fmt.next_line()
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
            print(f"AM308L: Display error - {e}: {m}")
            return "📟 AM308L Error - Check Console"
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
        var node_data = global.AM308L_nodes.find(node_id, nil)
        if node_data == nil return nil end
        
        return {
            'last_update': node_data.find('last_update', 0),
            'battery_history': node_data.find('battery_history', []),
            'reset_count': node_data.find('reset_count', 0),
            'last_reset': node_data.find('last_reset', 0),
            'name': node_data.find('name', 'Unknown')
        }
    end
    
    def clear_node_data(node_id)
        import global
        if global.AM308L_nodes.contains(node_id)
            global.AM308L_nodes.remove(node_id)
            return true
        end
        return false
    end
    
    def register_downlink_commands()
        import string
        
        tasmota.remove_cmd("LwAM308LReboot")
        tasmota.add_cmd("LwAM308LReboot", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.AM308L_nodes, cmd, idx, "FF10FF")
        end)
        
        tasmota.remove_cmd("LwAM308LBuzzer")
        tasmota.add_cmd("LwAM308LBuzzer", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.AM308L_nodes, cmd, idx, payload_str, { 
                '1|ON|ENABLE': ['FF3E01', 'ON'],
                '0|OFF|DISABLE|STOP': ['FF3D00', 'OFF']
            })
        end)
        
        tasmota.remove_cmd("LwAM308LInterval")
        tasmota.add_cmd("LwAM308LInterval", def(cmd, idx, payload_str)
            var interval = int(payload_str)
            if interval < 1 || interval > 65535
                return tasmota.resp_cmnd_str("Invalid: range 1-65535 seconds")
            end
            
            var hex_cmd = f"FF03{interval & 0xFF:02X}{(interval >> 8) & 0xFF:02X}"
            return lwdecode.SendDownlink(global.AM308L_nodes, cmd, idx, hex_cmd)
        end)
        
        tasmota.remove_cmd("LwAM308LTimeSync")
        tasmota.add_cmd("LwAM308LTimeSync", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.AM308L_nodes, cmd, idx, payload_str, { 
                '1|ENABLE': ['FF3B02', 'ENABLED'],
                '0|DISABLE': ['FF3B00', 'DISABLED']
            })
        end)
        
        tasmota.remove_cmd("LwAM308LTimeZone")
        tasmota.add_cmd("LwAM308LTimeZone", def(cmd, idx, payload_str)
            var zone = int(payload_str)
            if zone < -120 || zone > 120
                return tasmota.resp_cmnd_str("Invalid: range -120 to 120 (UTC-12 to UTC+12)")
            end
            
            var hex_cmd = f"FF17{zone & 0xFF:02X}{(zone >> 8) & 0xFF:02X}"
            return lwdecode.SendDownlink(global.AM308L_nodes, cmd, idx, hex_cmd)
        end)
        
        tasmota.remove_cmd("LwAM308LTVOCUnit")
        tasmota.add_cmd("LwAM308LTVOCUnit", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.AM308L_nodes, cmd, idx, payload_str, { 
                'IAQ|0': ['FFEB00', 'IAQ'],
                'UGM3|1': ['FFEB01', 'µg/m³']
            })
        end)
        
        tasmota.remove_cmd("LwAM308LCO2Cal")
        tasmota.add_cmd("LwAM308LCO2Cal", def(cmd, idx, payload_str)
            var parts = string.split(payload_str, ',')
            if size(parts) == 1
                var mode = parts[0]
                if mode == "FACTORY"
                    return lwdecode.SendDownlink(global.AM308L_nodes, cmd, idx, "FF1A00")
                elif mode == "ABC"  
                    return lwdecode.SendDownlink(global.AM308L_nodes, cmd, idx, "FF1A01")
                elif mode == "BACKGROUND"
                    return lwdecode.SendDownlink(global.AM308L_nodes, cmd, idx, "FF1A03")
                elif mode == "ZERO"
                    return lwdecode.SendDownlink(global.AM308L_nodes, cmd, idx, "FF1A04")
                end
            elif size(parts) == 2 && parts[0] == "MANUAL"
                var ppm = int(parts[1])
                if ppm < 400 || ppm > 5000
                    return tasmota.resp_cmnd_str("Invalid PPM: range 400-5000")
                end
                var hex_cmd = f"FF1A02{ppm & 0xFF:02X}{(ppm >> 8) & 0xFF:02X}"
                return lwdecode.SendDownlink(global.AM308L_nodes, cmd, idx, hex_cmd)
            end
            return tasmota.resp_cmnd_str("Usage: FACTORY|ABC|BACKGROUND|ZERO or MANUAL,<ppm>")
        end)
        
        tasmota.remove_cmd("LwAM308LHistory")
        tasmota.add_cmd("LwAM308LHistory", def(cmd, idx, payload_str)
            if payload_str == "CLEAR"
                return lwdecode.SendDownlink(global.AM308L_nodes, cmd, idx, "FF2701")
            else
                return lwdecode.SendDownlinkMap(global.AM308L_nodes, cmd, idx, payload_str, { 
                    '1|ON|ENABLE': ['FF6801', 'ENABLED'],
                    '0|OFF|DISABLE': ['FF6800', 'DISABLED']
                })
            end
        end)
        
        print("AM308L: Downlink commands registered")
    end
end

# Global instance
LwDeco = LwDecode_AM308L()

# Node management commands
tasmota.remove_cmd("LwAM308LNodeStats")
tasmota.add_cmd("LwAM308LNodeStats", def(cmd, idx, node_id)
    var stats = LwDeco.get_node_stats(node_id)
    if stats != nil
        import json
        tasmota.resp_cmnd(json.dump(stats))
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

tasmota.remove_cmd("LwAM308LClearNode")
tasmota.add_cmd("LwAM308LClearNode", def(cmd, idx, node_id)
    if LwDeco.clear_node_data(node_id)
        tasmota.resp_cmnd_done()
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

# TestUI command with payload verification
tasmota.remove_cmd("LwAM308LTestUI")
tasmota.add_cmd("LwAM308LTestUI", def(cmd, idx, payload_str)
    var test_scenarios = {
        "normal":    "017550036710C7046834050006080707D01E02087D4B00097366E30B7D1E000C7D28000E0100",
        "motion":    "017555036712F5046838050106080707D0250087E684000973801A0B7D32000C7D3C000E0100",
        "poor":      "017548036728A0046850050006080707D0FA0087E6E803097364430B7D6E000C7D78000E0101",
        "excellent": "017560036711940468280500060807D01900087D3200097368BB0B7D14000C7D1E000E0100",
        "history_iaq": "20CE0000640001115C0008DC000602C20196004100640064",
        "history_ugm3": "21CE0000640001115C0008DC000602C200FA004100640064",
        "device_info": "FF01FF09010AFF16DEADBEEFCAFEBABE0F00",
        "reset": "FF010FFEFE01",
        "buzzer_on": "017550036710C7046834050006080707D01E02087D4B000E0101",
        "config": "FF0100FF0901020AFF1603040506070809FF0F00FFEB00"
    }
    
    var hex_payload = test_scenarios.find(payload_str ? payload_str : 'nil', 'not_found')
    
    if hex_payload == 'not_found'
        var scenarios_list = "normal motion poor excellent history_iaq history_ugm3 device_info reset buzzer_on config "
        return tasmota.resp_cmnd_str(format("Available scenarios: %s", scenarios_list))
    end
    
    var rssi = -78
    var fport = 85

    return tasmota.cmd(f'LwSimulate{idx} {rssi},{fport},{hex_payload}')
end)

# MANDATORY: Register driver for web UI integration
tasmota.add_driver(LwDeco)