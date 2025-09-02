#
# LoRaWAN AI-Generated Decoder for Milesight AM300 Prompted by ZioFabry 
#
# Generated: 2025-09-02 | Version: 1.4.0 | Revision: REV4
#            by "LoRaWAN Decoder AI Generation Template", v2.5.0
#
# Homepage:  https://www.milesight-iot.com/lorawan/sensor/am300/
# Userguide: https://www.milesight-iot.com/lorawan/sensor/am300/
# Decoder:   https://www.milesight-iot.com/lorawan/sensor/am300/
# 
# v1.4.0 (2025-09-02): Template v2.5.0 upgrade with TestUI payload verification
# v1.3.0 (2025-09-02): Framework v2.4.1 upgrade with critical Berry keys() fixes
# v1.2.0 (2025-08-26): Enhanced display with air quality status
# v1.1.0 (2025-08-20): Added multi-sensor support and WELL features
# v1.0.0 (2025-08-14): Initial generation from MAP specification

class LwDecode_AM300
    var hashCheck, name, node, last_data, last_update, lwdecode

    def init()
        self.hashCheck = true
        self.name = nil
        self.node = nil
        self.last_data = {}
        self.last_update = 0
        
        import global
        if !global.contains("AM300_nodes")
            global.AM300_nodes = {}
        end
        if !global.contains("AM300_cmdInit")
            global.AM300_cmdInit = false
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
            
            var node_data = global.AM300_nodes.find(node, {})
            var previous_data = node_data.find('last_data', {})
            
            if size(previous_data) > 0
                for key: ['battery_pct', 'temperature', 'humidity', 'pir_occupancy', 'light_level', 
                         'co2_ppm', 'tvoc_level', 'tvoc_ppb', 'pressure_hpa', 'hcho_mgm3',
                         'pm25_ugm3', 'pm10_ugm3', 'o3_ppm', 'buzzer_status', 'activity_event', 
                         'power_event', 'air_quality_status', 'well_status']
                    if previous_data.contains(key)
                        data[key] = previous_data[key]
                    end
                end
            end
            
            if fport == 85
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
                        
                    elif channel_id == 0x05 && channel_type == 0x02
                        if i < size(payload)
                            data['pir_occupancy'] = payload[i] == 1
                            i += 1
                        end
                        
                    elif channel_id == 0x06 && (channel_type == 0xcb || channel_type == 0x10)
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
                            data['tvoc_level'] = ((payload[i+1] << 8) | payload[i]) / 100.0
                            i += 2
                        end
                        
                    elif channel_id == 0x08 && channel_type == 0xe6
                        if i + 1 < size(payload)
                            data['tvoc_ppb'] = (payload[i+1] << 8) | payload[i]
                            i += 2
                        end
                        
                    elif channel_id == 0x09 && channel_type == 0x73
                        if i + 1 < size(payload)
                            data['pressure_hpa'] = ((payload[i+1] << 8) | payload[i]) / 10.0
                            i += 2
                        end
                        
                    elif channel_id == 0x0a && channel_type == 0x7d
                        if i + 1 < size(payload)
                            data['hcho_mgm3'] = ((payload[i+1] << 8) | payload[i]) / 100.0
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
                        
                    elif channel_id == 0x0d && channel_type == 0x7d
                        if i + 1 < size(payload)
                            data['o3_ppm'] = ((payload[i+1] << 8) | payload[i]) / 1000.0
                            i += 2
                        end
                        
                    elif channel_id == 0x0e && channel_type == 0x01
                        if i < size(payload)
                            data['buzzer_status'] = payload[i] == 1
                            i += 1
                        end
                        
                    elif channel_id == 0x0f && channel_type == 0x01
                        if i < size(payload)
                            data['activity_event'] = payload[i] == 1
                            i += 1
                        end
                        
                    elif channel_id == 0x10 && channel_type == 0x01
                        if i < size(payload)
                            data['power_event'] = payload[i] == 1
                            i += 1
                        end
                        
                    elif channel_id == 0xff && channel_type == 0x0b
                        # Device info - skip variable length data
                        break
                        
                    else
                        print(f"AM300: Unknown channel {channel_id:02X}:{channel_type:02X}")
                        break
                    end
                end
                
                # Calculate air quality status
                if data.contains('co2_ppm') || data.contains('tvoc_level') || data.contains('pm25_ugm3')
                    data['air_quality_status'] = self.calculate_air_quality(data)
                end
                
                # WELL Building Standard status
                if data.contains('co2_ppm') && data.contains('tvoc_level') && data.contains('pm25_ugm3')
                    data['well_status'] = self.check_well_compliance(data)
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
            
            if !global.contains("AM300_cmdInit") || !global.AM300_cmdInit
                self.register_downlink_commands()
                global.AM300_cmdInit = true
            end

            global.AM300_nodes[node] = node_data
            
            self.last_data = data
            self.last_update = node_data['last_update']
            
            return data
            
        except .. as e, m
            print(f"AM300: Decode error - {e}: {m}")
            return nil
        end
    end
    
    def calculate_air_quality(data)
        var score = 100
        
        # CO2 impact
        if data.contains('co2_ppm')
            var co2 = data['co2_ppm']
            if co2 > 1000 score -= 30
            elif co2 > 800 score -= 20
            elif co2 > 600 score -= 10
        end
        
        # TVOC impact
        if data.contains('tvoc_level')
            var tvoc = data['tvoc_level']
            if tvoc > 3.0 score -= 25
            elif tvoc > 2.0 score -= 15
            elif tvoc > 1.0 score -= 5
        end
        
        # PM2.5 impact
        if data.contains('pm25_ugm3')
            var pm25 = data['pm25_ugm3']
            if pm25 > 55 score -= 25
            elif pm25 > 35 score -= 15
            elif pm25 > 12 score -= 5
        end
        
        if score >= 90 return "Excellent"
        elif score >= 70 return "Good"
        elif score >= 50 return "Fair"
        elif score >= 30 return "Poor"
        else return "Unhealthy"
        end
    end
    
    def check_well_compliance(data)
        var compliant = true
        
        if data.contains('co2_ppm') && data['co2_ppm'] > 800
            compliant = false
        end
        
        if data.contains('tvoc_level') && data['tvoc_level'] > 2.0
            compliant = false
        end
        
        if data.contains('pm25_ugm3') && data['pm25_ugm3'] > 15
            compliant = false
        end
        
        return compliant
    end
    
    def add_web_sensor()
        import global
        
        try
            var data_to_show = self.last_data
            var last_update = self.last_update
            
            if size(data_to_show) == 0 && self.node != nil
                var node_data = global.AM300_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            if size(data_to_show) == 0 && size(global.AM300_nodes) > 0
                var found_node = false
                for node_id: global.AM300_nodes.keys()
                    if !found_node
                        var node_data = global.AM300_nodes[node_id]
                        data_to_show = node_data.find('last_data', {})
                        last_update = node_data.find('last_update', 0)
                        self.node = node_id
                        self.name = node_data.find('name', f"AM300-{node_id}")
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
                name = f"AM300-{self.node}"
            end
            var name_tooltip = "Milesight AM300"
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
                fmt.add_sensor("string", f"{data_to_show['light_level']}/10", "Light", "💡")
            end
            
            fmt.next_line()
            
            # Air quality line
            if data_to_show.contains('co2_ppm')
                fmt.add_sensor("co2", data_to_show['co2_ppm'], "CO2", "💨")
            end
            
            if data_to_show.contains('tvoc_level')
                fmt.add_sensor("string", f"{data_to_show['tvoc_level']:.1f}", "TVOC", "🌬️")
            end
            
            if data_to_show.contains('hcho_mgm3')
                fmt.add_sensor("string", f"{data_to_show['hcho_mgm3']:.2f}mg/m³", "HCHO", "⚠️")
            end
            
            fmt.next_line()
            
            # Particulate matter line
            if data_to_show.contains('pm25_ugm3')
                fmt.add_sensor("string", f"{data_to_show['pm25_ugm3']}μg/m³", "PM2.5", "🌫️")
            end
            
            if data_to_show.contains('pm10_ugm3')
                fmt.add_sensor("string", f"{data_to_show['pm10_ugm3']}μg/m³", "PM10", "🌫️")
            end
            
            if data_to_show.contains('o3_ppm')
                fmt.add_sensor("string", f"{data_to_show['o3_ppm']:.3f}ppm", "O3", "🌊")
            end
            
            # Status line
            var has_status = false
            
            if data_to_show.contains('pir_occupancy')
                var occ_emoji = data_to_show['pir_occupancy'] ? "🚶" : "🏠"
                var occ_text = data_to_show['pir_occupancy'] ? "Occupied" : "Vacant"
                fmt.add_sensor("string", occ_text, "PIR", occ_emoji)
                has_status = true
            end
            
            if data_to_show.contains('air_quality_status')
                var status = data_to_show['air_quality_status']
                var status_emoji = {
                    "Excellent": "🟢", "Good": "🟡", "Fair": "🟠", 
                    "Poor": "🔴", "Unhealthy": "🚨"
                }.find(status, "⚪")
                fmt.add_sensor("string", status, "Air Quality", status_emoji)
                has_status = true
            end
            
            if data_to_show.contains('well_status')
                var well_emoji = data_to_show['well_status'] ? "✅" : "❌"
                var well_text = data_to_show['well_status'] ? "WELL OK" : "WELL Alert"
                fmt.add_sensor("string", well_text, "WELL", well_emoji)
                has_status = true
            end
            
            if data_to_show.contains('buzzer_status') && data_to_show['buzzer_status']
                fmt.add_sensor("string", "Buzzer ON", "Alert", "🔔")
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
            print(f"AM300: Display error - {e}: {m}")
            return "📟 AM300 Error - Check Console"
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
        var node_data = global.AM300_nodes.find(node_id, nil)
        if node_data == nil return nil end
        
        return {
            'last_update': node_data.find('last_update', 0),
            'battery_history': node_data.find('battery_history', []),
            'name': node_data.find('name', 'Unknown')
        }
    end
    
    def clear_node_data(node_id)
        import global
        if global.AM300_nodes.contains(node_id)
            global.AM300_nodes.remove(node_id)
            return true
        end
        return false
    end
    
    def register_downlink_commands()
        import string
        
        tasmota.remove_cmd("LwAM300Interval")
        tasmota.add_cmd("LwAM300Interval", def(cmd, idx, payload_str)
            var interval = int(payload_str)
            if interval < 1 || interval > 1440
                return tasmota.resp_cmnd_str("Invalid: range 1-1440 minutes")
            end
            
            var hex_cmd = f"FF01{interval & 0xFF:02X}{(interval >> 8) & 0xFF:02X}"
            return lwdecode.SendDownlink(global.AM300_nodes, cmd, idx, hex_cmd)
        end)
        
        tasmota.remove_cmd("LwAM300Buzzer")
        tasmota.add_cmd("LwAM300Buzzer", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.AM300_nodes, cmd, idx, payload_str, { 
                '1|ON|ENABLE': ['FF0E01', 'ON'],
                '0|OFF|DISABLE': ['FF0E00', 'OFF']
            })
        end)
        
        tasmota.remove_cmd("LwAM300Screen")
        tasmota.add_cmd("LwAM300Screen", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.AM300_nodes, cmd, idx, payload_str, { 
                '1|ON|ENABLE': ['FF2D01', 'ON'],
                '0|OFF|DISABLE': ['FF2D00', 'OFF']
            })
        end)
        
        tasmota.remove_cmd("LwAM300TimeSync")
        tasmota.add_cmd("LwAM300TimeSync", def(cmd, idx, payload_str)
            var timestamp = tasmota.rtc()['local']
            var hex_cmd = f"FF02{timestamp & 0xFF:02X}{(timestamp >> 8) & 0xFF:02X}{(timestamp >> 16) & 0xFF:02X}{(timestamp >> 24) & 0xFF:02X}"
            return lwdecode.SendDownlink(global.AM300_nodes, cmd, idx, hex_cmd)
        end)
        
        tasmota.remove_cmd("LwAM300Reboot")
        tasmota.add_cmd("LwAM300Reboot", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.AM300_nodes, cmd, idx, "FF10")
        end)
        
        print("AM300: Downlink commands registered")
    end
end

# Global instance
LwDeco = LwDecode_AM300()

# Node management commands
tasmota.remove_cmd("LwAM300NodeStats")
tasmota.add_cmd("LwAM300NodeStats", def(cmd, idx, node_id)
    var stats = LwDeco.get_node_stats(node_id)
    if stats != nil
        import json
        tasmota.resp_cmnd(json.dump(stats))
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

tasmota.remove_cmd("LwAM300ClearNode")
tasmota.add_cmd("LwAM300ClearNode", def(cmd, idx, node_id)
    if LwDeco.clear_node_data(node_id)
        tasmota.resp_cmnd_done()
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

# TestUI command with payload verification
tasmota.remove_cmd("LwAM300TestUI")
tasmota.add_cmd("LwAM300TestUI", def(cmd, idx, payload_str)
    var test_scenarios = {
        "normal":    "01755003671101046828056200060A0707D0190808E665000973E6010A7D640A0B7D320C0C7D1E000D7D0500",
        "occupied":  "01755503671501046838056201060A0707D0250808E680000973E8010A7D780A0B7D420C0C7D28000D7D0800", 
        "poor":      "01754803672801046850056200060A0707D0FA0808E6E8030973E2010A7DC8000B7D6E000C7D50000D7D1E00",
        "excellent": "01756003671801046828056200060A0707D0E8010808E632000973EA010A7D32000B7D1E000C7D14000D7D0500",
        "alert":     "01753C03673C01046860056201060A0707D0C4090808E6204E0973DC010A7D2C010B7DA0000C7D78000D7D3200",
        "events":    "01755003671101046828056200060A0707D0190808E665000973E6010F01011001",
        "buzzer":    "01755003671101046828056200060A0707D0190808E665000973E6010E0101",
        "minimal":   "01755003671101046828",
        "config":    "FF0B010203040506070809",
        "well":      "01755803671E01046835056200060A0707D01E020808E650000973E4010A7D3C000B7D280C0C7D1E000D7D0A00"
    }
    
    var hex_payload = test_scenarios.find(payload_str ? payload_str : 'nil', 'not_found')
    
    if hex_payload == 'not_found'
        var scenarios_list = "normal occupied poor excellent alert events buzzer minimal config well "
        return tasmota.resp_cmnd_str(format("Available scenarios: %s", scenarios_list))
    end
    
    var rssi = -75
    var fport = 85

    return tasmota.cmd(f'LwSimulate{idx} {rssi},{fport},{hex_payload}')
end)

# MANDATORY: Register driver for web UI integration
tasmota.add_driver(LwDeco)