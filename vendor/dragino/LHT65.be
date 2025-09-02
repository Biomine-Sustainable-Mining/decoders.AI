#
# LoRaWAN AI-Generated Decoder for Dragino LHT65 Temperature & Humidity Sensor
#
# Generated: 2025-09-02 | Version: v1.2.0 | Revision: 3
#            by "LoRaWAN Decoder AI Generation Template", v2.5.0
#
# Homepage:  https://www.dragino.com/products/lora-lorawan-end-node/item/151-lht65.html
# Userguide: https://www.dragino.com/downloads/downloads/LHT65/UserManual/LHT65_Temperature_Humidity_Sensor_UserManual_v1.8.5.pdf
# Decoder:   Official decoder integrated
# 
# Device: Temperature & humidity sensor with 9 external sensor types support
# Features: SHT20 internal + DS18B20/interrupt/illumination/ADC/counting external sensors

class LwDecode_LHT65
    var hashCheck, name, node, last_data, last_update, lwdecode

    def init()
        self.hashCheck = true
        self.name = nil
        self.node = nil
        self.last_data = {}
        self.last_update = 0
        
        import global
        if !global.contains("LHT65_nodes")
            global.LHT65_nodes = {}
        end
        if !global.contains("LHT65_cmdInit")
            global.LHT65_cmdInit = false
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
            
            var node_data = global.LHT65_nodes.find(node, {})
            var previous_data = node_data.find('last_data', {})
            
            if size(previous_data) > 0
                for key: ['battery_v', 'temperature', 'humidity', 'ext_temperature', 'ext_sensor_type']
                    if previous_data.contains(key)
                        data[key] = previous_data[key]
                    end
                end
            end
            
            if fport == 2 && size(payload) >= 11
                # Battery status and voltage
                var bat_raw = (payload[0] << 8) | payload[1]
                var battery_status = (bat_raw >> 14) & 0x03
                var battery_mv = bat_raw & 0x3FFF
                data['battery_v'] = battery_mv / 1000.0
                data['battery_pct'] = self.voltage_to_percent(data['battery_v'])
                data['battery_status'] = self.decode_battery_status(battery_status)
                
                # Built-in temperature (signed)
                var temp_raw = (payload[2] << 8) | payload[3]
                if temp_raw > 32767
                    temp_raw = temp_raw - 65536
                end
                data['temperature'] = temp_raw / 100.0
                
                # Built-in humidity
                var humidity_raw = (payload[4] << 8) | payload[5]
                data['humidity'] = humidity_raw / 10.0
                
                # External sensor
                var ext_type = payload[6]
                data['ext_sensor_type'] = ext_type
                data['ext_sensor_name'] = self.decode_ext_sensor_name(ext_type)
                
                # Decode external sensor data based on type
                if ext_type == 0x01        # E1 Temperature
                    var ext_temp_raw = (payload[7] << 8) | payload[8]
                    if ext_temp_raw != 0x7FFF
                        if ext_temp_raw > 32767
                            ext_temp_raw = ext_temp_raw - 65536
                        end
                        data['ext_temperature'] = ext_temp_raw / 100.0
                    else
                        data['ext_sensor_error'] = "No sensor connected"
                    end
                    
                elif ext_type == 0x04      # E4 Interrupt
                    var int_byte = payload[7]
                    data['cable_connected'] = (int_byte & 0x80) != 0
                    data['interrupt_triggered'] = (int_byte & 0x40) != 0
                    data['pin_level'] = (int_byte & 0x01) != 0 ? "High" : "Low"
                    
                elif ext_type == 0x05      # E5 Illumination
                    var illuminance = (payload[7] << 8) | payload[8]
                    data['illuminance'] = illuminance
                    data['cable_connected'] = (payload[9] & 0x80) != 0
                    
                elif ext_type == 0x06      # E6 ADC
                    var adc_voltage = (payload[7] << 8) | payload[8]
                    data['adc_voltage'] = adc_voltage
                    data['cable_connected'] = (payload[9] & 0x80) != 0
                    
                elif ext_type == 0x07      # E7 Counting 16-bit
                    var count = (payload[7] << 8) | payload[8]
                    data['event_count'] = count
                    data['cable_connected'] = (payload[9] & 0x80) != 0
                    
                elif ext_type == 0x08      # E7 Counting 32-bit
                    var count = (payload[7] << 24) | (payload[8] << 16) | 
                               (payload[9] << 8) | payload[10]
                    data['event_count'] = count
                    
                elif ext_type == 0x09      # E1 with Unix timestamp
                    var ext_temp_raw = (payload[7] << 8) | payload[8]
                    if ext_temp_raw > 32767
                        ext_temp_raw = ext_temp_raw - 65536
                    end
                    data['ext_temperature'] = ext_temp_raw / 100.0
                    
                    var builtin_temp_raw = (payload[9] << 8) | payload[10]
                    if builtin_temp_raw > 32767
                        builtin_temp_raw = builtin_temp_raw - 65536
                    end
                    # Override with timestamp version
                    data['temperature'] = builtin_temp_raw / 100.0
                    data['datalog_mode'] = true
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
            
            if !global.LHT65_cmdInit
                self.register_downlink_commands()
                global.LHT65_cmdInit = true
            end
            
            node_data['last_data'] = data
            node_data['last_update'] = tasmota.rtc()['local']
            node_data['name'] = name
            global.LHT65_nodes[node] = node_data
            
            self.last_data = data
            self.last_update = node_data['last_update']
            
            return data
            
        except .. as e, m
            print(f"LHT65: Decode error - {e}: {m}")
            return nil
        end
    end
    
    def add_web_sensor()
        try
            var data_to_show = self.last_data
            var last_update = self.last_update
            
            if size(data_to_show) == 0 && self.node != nil
                import global
                var node_data = global.LHT65_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            if size(data_to_show) == 0
                import global
                if size(global.LHT65_nodes) > 0
                    var found_node = false
                    for node_id: global.LHT65_nodes.keys()
                        if !found_node
                            var node_data = global.LHT65_nodes[node_id]
                            data_to_show = node_data.find('last_data', {})
                            last_update = node_data.find('last_update', 0)
                            self.node = node_id
                            self.name = node_data.find('name', f"LHT65-{node_id}")
                            found_node = true
                        end
                    end
                end
            end
            
            if size(data_to_show) == 0 return nil end
            
            import string
            var msg = ""
            var fmt = LwSensorFormatter_cls()
            
            var name = self.name ? self.name : f"LHT65-{self.node}"
            var name_tooltip = "Dragino LHT65 Multi-sensor"
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
            
            # External sensor display
            var ext_type = data_to_show.find('ext_sensor_type', 0)
            if ext_type == 0x01 && data_to_show.contains('ext_temperature')
                fmt.add_sensor("temp", data_to_show['ext_temperature'], "Ext Temp", "🔍")
            elif ext_type == 0x05 && data_to_show.contains('illuminance')
                fmt.add_sensor("lux", data_to_show['illuminance'], "Light", "☀️")
            elif ext_type == 0x06 && data_to_show.contains('adc_voltage')
                fmt.add_sensor("string", f"{data_to_show['adc_voltage']}mV", "ADC", "📊")
            elif ext_type == 0x07 || ext_type == 0x08
                if data_to_show.contains('event_count')
                    fmt.add_sensor("string", f"{data_to_show['event_count']}", "Count", "🔢")
                end
            end
            
            if battery != 1000
                fmt.add_sensor("string", f"{data_to_show.find('battery_pct', 0)}%", "Battery", "🔋")
            end
            
            var has_status = false
            var status_items = []
            
            if data_to_show.contains('interrupt_triggered') && data_to_show['interrupt_triggered']
                status_items.push(['string', 'Interrupt', 'External Trigger', '⚡'])
                has_status = true
            end
            
            if data_to_show.contains('cable_connected') && !data_to_show['cable_connected']
                status_items.push(['string', 'Disconnected', 'Cable Status', '🔌'])
                has_status = true
            end
            
            if data_to_show.contains('ext_sensor_error')
                status_items.push(['string', 'No Sensor', 'External Error', '❌'])
                has_status = true
            end
            
            if data_to_show.contains('datalog_mode') && data_to_show['datalog_mode']
                status_items.push(['string', 'Datalog', 'Historical Mode', '📊'])
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
            print(f"LHT65: Display error - {e}: {m}")
            return "📟 LHT65 Error - Check Console"
        end
    end
    
    def decode_battery_status(status_code)
        var status_map = {
            0x00: "Ultra Low", 0x01: "Low", 
            0x02: "OK", 0x03: "Good"
        }
        return status_map.find(status_code, f"Unknown({status_code})")
    end
    
    def decode_ext_sensor_name(sensor_type)
        var sensor_names = {
            0x00: "None", 0x01: "E1 Temperature", 0x04: "E4 Interrupt",
            0x05: "E5 Illumination", 0x06: "E6 ADC", 0x07: "E7 Count16",
            0x08: "E7 Count32", 0x09: "E1 Timestamp"
        }
        return sensor_names.find(sensor_type, f"Unknown({sensor_type:02X})")
    end
    
    def voltage_to_percent(voltage)
        if voltage >= 3.6 return 100
        elif voltage <= 2.45 return 0
        else return int((voltage - 2.45) / 1.15 * 100)
        end
    end
    
    def get_node_stats(node_id)
        import global
        var node_data = global.LHT65_nodes.find(node_id, nil)
        if node_data == nil return nil end
        
        return {
            'last_update': node_data.find('last_update', 0),
            'battery_history': node_data.find('battery_history', []),
            'name': node_data.find('name', 'Unknown')
        }
    end
    
    def clear_node_data(node_id)
        import global
        if global.LHT65_nodes.contains(node_id)
            global.LHT65_nodes.remove(node_id)
            return true
        end
        return false
    end
    
    def register_downlink_commands()
        import string
        
        tasmota.remove_cmd("LwLHT65Interval")
        tasmota.add_cmd("LwLHT65Interval", def(cmd, idx, payload_str)
            var interval = int(payload_str)
            if interval < 1 || interval > 16777215
                return tasmota.resp_cmnd_str("Invalid: range 1-16777215 seconds")
            end
            
            var hex_cmd = f"01{(interval >> 16) & 0xFF:02X}{(interval >> 8) & 0xFF:02X}{interval & 0xFF:02X}"
            return lwdecode.SendDownlink(global.LHT65_nodes, cmd, idx, hex_cmd)
        end)
        
        tasmota.remove_cmd("LwLHT65ExtSensor")
        tasmota.add_cmd("LwLHT65ExtSensor", def(cmd, idx, payload_str)
            var parts = string.split(payload_str, ',')
            var sensor_type = int(parts[0])
            
            if sensor_type < 1 || sensor_type > 9
                return tasmota.resp_cmnd_str("Invalid type: 1=E1, 4=E4, 5=E5, 6=E6, 7=E7-16, 8=E7-32, 9=E1-TS")
            end
            
            var hex_cmd = f"A2{sensor_type:02X}"
            
            if size(parts) > 1
                var param = int(parts[1])
                hex_cmd += f"{param:02X}"
                
                if size(parts) > 2 && sensor_type == 0x06
                    var timeout = int(parts[2])
                    hex_cmd += f"{(timeout >> 8) & 0xFF:02X}{timeout & 0xFF:02X}"
                end
            end
            
            return lwdecode.SendDownlink(global.LHT65_nodes, cmd, idx, hex_cmd)
        end)
        
        tasmota.remove_cmd("LwLHT65ProbeID")
        tasmota.add_cmd("LwLHT65ProbeID", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.LHT65_nodes, cmd, idx, payload_str, {
                '0|DISABLE': ['A800', 'Disabled'],
                '1|ENABLE': ['A801', 'Enabled']
            })
        end)
        
        tasmota.remove_cmd("LwLHT65SetTime")
        tasmota.add_cmd("LwLHT65SetTime", def(cmd, idx, payload_str)
            var timestamp = int(payload_str)
            
            var hex_cmd = f"30{(timestamp >> 24) & 0xFF:02X}{(timestamp >> 16) & 0xFF:02X}"
            hex_cmd += f"{(timestamp >> 8) & 0xFF:02X}{timestamp & 0xFF:02X}"
            
            return lwdecode.SendDownlink(global.LHT65_nodes, cmd, idx, hex_cmd)
        end)
        
        tasmota.remove_cmd("LwLHT65ClearData")
        tasmota.add_cmd("LwLHT65ClearData", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.LHT65_nodes, cmd, idx, "A301")
        end)
        
        tasmota.remove_cmd("LwLHT65Poll")
        tasmota.add_cmd("LwLHT65Poll", def(cmd, idx, payload_str)
            var parts = string.split(payload_str, ',')
            if size(parts) != 3
                return tasmota.resp_cmnd_str("Usage: LwLHT65Poll<slot> <start>,<end>,<interval>")
            end
            
            var start_time = int(parts[0])
            var end_time = int(parts[1])
            var interval = int(parts[2])
            
            if interval < 5 || interval > 255
                return tasmota.resp_cmnd_str("Invalid interval: range 5-255 seconds")
            end
            
            var hex_cmd = f"31{(start_time >> 24) & 0xFF:02X}{(start_time >> 16) & 0xFF:02X}"
            hex_cmd += f"{(start_time >> 8) & 0xFF:02X}{start_time & 0xFF:02X}"
            hex_cmd += f"{(end_time >> 24) & 0xFF:02X}{(end_time >> 16) & 0xFF:02X}"
            hex_cmd += f"{(end_time >> 8) & 0xFF:02X}{end_time & 0xFF:02X}"
            hex_cmd += f"{interval:02X}"
            
            return lwdecode.SendDownlink(global.LHT65_nodes, cmd, idx, hex_cmd)
        end)
        
        print("LHT65: Downlink commands registered")
    end
end

LwDeco = LwDecode_LHT65()

tasmota.remove_cmd("LwLHT65NodeStats")
tasmota.add_cmd("LwLHT65NodeStats", def(cmd, idx, node_id)
    var stats = LwDeco.get_node_stats(node_id)
    if stats != nil
        import json
        tasmota.resp_cmnd(json.dump(stats))
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

tasmota.remove_cmd("LwLHT65ClearNode")
tasmota.add_cmd("LwLHT65ClearNode", def(cmd, idx, node_id)
    if LwDeco.clear_node_data(node_id)
        tasmota.resp_cmnd_done()
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

tasmota.remove_cmd("LwLHT65TestUI")
tasmota.add_cmd("LwLHT65TestUI", def(cmd, idx, payload_str)
    var test_scenarios = {
        "normal":     "C00E094C03E8007FFF0000",      # Standard: 23.4°C, 100%RH, no external
        "external":   "C00E094C03E801FF380000",      # E1 temp: -20°C external
        "illumination": "C00E094C03E8051F400000",    # E5: 8000 lux illumination
        "adc":        "C00E094C03E806CE800000",      # E6: 3300mV ADC reading
        "counting":   "C00E094C03E80764800000",      # E7-16: 100 events
        "interrupt":  "C00E094C03E804C1000000",      # E4: Interrupt triggered
        "datalog":    "C00E094C03E809FF380940",      # E9: With timestamp mode
        "low":        "800A094C03E8007FFF0000",      # Low battery status
        "disconnect": "C00E094C03E80500000000",      # E5 with cable disconnected
        "demo":       "C00E094C03E8051F40C000"       # Demo: illumination with cable
    }
    
    var hex_payload = test_scenarios.find(payload_str ? payload_str : 'nil', 'not_found')
    
    if hex_payload == 'not_found'
        var scenarios_list = "normal external illumination adc counting interrupt datalog low disconnect demo "
        return tasmota.resp_cmnd_str(f"Available scenarios: {scenarios_list}")
    end
    
    var rssi = -75
    var fport = 2

    return tasmota.cmd(f'LwSimulate{idx} {rssi},{fport},{hex_payload}')
end)

tasmota.add_driver(LwDeco)