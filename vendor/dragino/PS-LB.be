#
# LoRaWAN AI-Generated Decoder for Dragino PS-LB Pressure Sensor
#
# Generated: 2025-09-02 | Version: v1.2.0 | Revision: 3
#            by "LoRaWAN Decoder AI Generation Template", v2.5.0
#
# Homepage:  https://wiki.dragino.com/xwiki/bin/view/Main/User%20Manual%20for%20LoRaWAN%20End%20Nodes/PS-LB%20--%20LoRaWAN%20Pressure%20Sensor/
# Userguide: Same as above
# Decoder:   Official decoder integrated
# 
# Device: 4-20mA/0-30V pressure sensor with datalog and ROC features
# Features: Water depth/pressure monitoring, ROC alarms, multi-collection mode

class LwDecode_PS_LB
    var hashCheck, name, node, last_data, last_update, lwdecode

    def init()
        self.hashCheck = true
        self.name = nil
        self.node = nil
        self.last_data = {}
        self.last_update = 0
        
        import global
        if !global.contains("PS_LB_nodes")
            global.PS_LB_nodes = {}
        end
        if !global.contains("PS_LB_cmdInit")
            global.PS_LB_cmdInit = false
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
            
            var node_data = global.PS_LB_nodes.find(node, {})
            var previous_data = node_data.find('last_data', {})
            
            if size(previous_data) > 0
                for key: ['battery_v', 'idc_current', 'vdc_voltage', 'probe_type', 'roc_status']
                    if previous_data.contains(key)
                        data[key] = previous_data[key]
                    end
                end
            end
            
            if fport == 5        # Device Status
                if size(payload) >= 6
                    data['sensor_model'] = payload[0]
                    data['fw_version'] = f"v{payload[1]}.{payload[2]}.0"
                    data['frequency_band'] = self.decode_frequency_band(payload[3])
                    data['sub_band'] = payload[4]
                    var battery_mv = (payload[5] << 8) | payload[6]
                    data['battery_v'] = battery_mv / 1000.0
                    data['battery_pct'] = self.voltage_to_percent(data['battery_v'])
                    data['device_info'] = true
                end
                
            elif fport == 2      # Sensor Data
                if size(payload) >= 9
                    # Probe model and configuration
                    data['probe_model'] = (payload[0] << 8) | payload[1]
                    data['probe_type'] = self.decode_probe_type(data['probe_model'])
                    
                    # IDC input (4-20mA)
                    var idc_raw = (payload[2] << 8) | payload[3]
                    data['idc_current'] = idc_raw / 1000.0
                    
                    # VDC input (0-30V)
                    var vdc_raw = (payload[4] << 8) | payload[5]
                    data['vdc_voltage'] = vdc_raw / 1000.0
                    
                    # Battery voltage
                    var battery_mv = (payload[6] << 8) | payload[7]
                    data['battery_v'] = battery_mv / 1000.0
                    data['battery_pct'] = self.voltage_to_percent(data['battery_v'])
                    
                    # Status flags
                    var flags = payload[8]
                    data['in1_level'] = (flags & 0x08) != 0
                    data['in2_level'] = (flags & 0x04) != 0
                    data['int_level'] = (flags & 0x02) != 0
                    data['int_status'] = (flags & 0x01) != 0
                    
                    # ROC flags (bits 4-7)
                    var roc_flags = (flags >> 4) & 0x0F
                    if roc_flags > 0
                        data['roc_triggered'] = true
                        data['idc_decrease'] = (roc_flags & 0x08) != 0
                        data['idc_increase'] = (roc_flags & 0x04) != 0
                        data['vdc_decrease'] = (roc_flags & 0x02) != 0
                        data['vdc_increase'] = (roc_flags & 0x01) != 0
                    end
                    
                    # Calculate derived values based on probe type
                    self.calculate_derived_values(data)
                end
                
            elif fport == 7      # Multi-collection Data
                if size(payload) >= 4
                    var data_count = (payload[0] << 8) | payload[1]
                    data['collection_count'] = data_count
                    data['voltage_readings'] = []
                    
                    var i = 2
                    var reading_idx = 0
                    while i < size(payload) && reading_idx < data_count
                        var voltage = (payload[i] << 8) | payload[i+1]
                        data['voltage_readings'].push(voltage / 1000.0)
                        i += 2
                        reading_idx += 1
                    end
                    
                    data['multi_collection'] = true
                end
                
            elif fport == 3      # Datalog
                if size(payload) >= 11
                    # Same structure as port 2 with timestamp
                    data['probe_model'] = (payload[0] << 8) | payload[1]
                    data['vdc_voltage'] = ((payload[2] << 8) | payload[3]) / 1000.0
                    data['idc_current'] = ((payload[4] << 8) | payload[5]) / 1000.0
                    data['status_flags'] = payload[6]
                    
                    # Unix timestamp
                    var timestamp = (payload[7] << 24) | (payload[8] << 16) | 
                                   (payload[9] << 8) | payload[10]
                    data['timestamp'] = timestamp
                    data['historical_data'] = true
                    
                    self.calculate_derived_values(data)
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
            
            if !global.PS_LB_cmdInit
                self.register_downlink_commands()
                global.PS_LB_cmdInit = true
            end
            
            node_data['last_data'] = data
            node_data['last_update'] = tasmota.rtc()['local']
            node_data['name'] = name
            global.PS_LB_nodes[node] = node_data
            
            self.last_data = data
            self.last_update = node_data['last_update']
            
            return data
            
        except .. as e, m
            print(f"PS-LB: Decode error - {e}: {m}")
            return nil
        end
    end
    
    def add_web_sensor()
        try
            var data_to_show = self.last_data
            var last_update = self.last_update
            
            if size(data_to_show) == 0 && self.node != nil
                import global
                var node_data = global.PS_LB_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            if size(data_to_show) == 0
                import global
                if size(global.PS_LB_nodes) > 0
                    var found_node = false
                    for node_id: global.PS_LB_nodes.keys()
                        if !found_node
                            var node_data = global.PS_LB_nodes[node_id]
                            data_to_show = node_data.find('last_data', {})
                            last_update = node_data.find('last_update', 0)
                            self.node = node_id
                            self.name = node_data.find('name', f"PS-LB-{node_id}")
                            found_node = true
                        end
                    end
                end
            end
            
            if size(data_to_show) == 0 return nil end
            
            import string
            var msg = ""
            var fmt = LwSensorFormatter_cls()
            
            var name = self.name ? self.name : f"PS-LB-{self.node}"
            var name_tooltip = "Dragino PS-LB Pressure Sensor"
            var battery = data_to_show.find('battery_v', 1000)
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)
            var simulated = data_to_show.find('simulated', false)
            
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            
            fmt.start_line()
            
            # Main pressure/current readings
            if data_to_show.contains('idc_current')
                fmt.add_sensor("string", f"{data_to_show['idc_current']:.1f}mA", "Current", "🔌")
            end
            
            if data_to_show.contains('vdc_voltage')
                fmt.add_sensor("volt", data_to_show['vdc_voltage'], "Voltage", "⚡")
            end
            
            # Derived values (pressure/depth)
            if data_to_show.contains('pressure_pa')
                var pressure_val = data_to_show['pressure_pa']
                if pressure_val >= 1000000
                    fmt.add_sensor("string", f"{pressure_val/1000000:.2f}MPa", "Pressure", "💧")
                else
                    fmt.add_sensor("string", f"{pressure_val:.0f}Pa", "Pressure", "💧")
                end
            end
            
            if data_to_show.contains('water_depth')
                fmt.add_sensor("distance", data_to_show['water_depth'], "Depth", "🌊")
            end
            
            if battery != 1000
                fmt.add_sensor("string", f"{data_to_show.find('battery_pct', 0)}%", "Battery", "🔋")
            end
            
            var has_status = false
            var status_items = []
            
            if data_to_show.contains('roc_triggered') && data_to_show['roc_triggered']
                status_items.push(['string', 'ROC Alert', 'Rate of Change', '📈'])
                has_status = true
            end
            
            if data_to_show.contains('int_status') && data_to_show['int_status']
                status_items.push(['string', 'Interrupt', 'Digital Input', '⚡'])
                has_status = true
            end
            
            if data_to_show.contains('historical_data') && data_to_show['historical_data']
                status_items.push(['string', 'Datalog', 'Historical Data', '📊'])
                has_status = true
            end
            
            if data_to_show.contains('multi_collection') && data_to_show['multi_collection']
                status_items.push(['string', 'Multi-Data', 'Collection Mode', '📋'])
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
            print(f"PS-LB: Display error - {e}: {m}")
            return "📟 PS-LB Error - Check Console"
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
    
    def decode_probe_type(probe_model)
        var aa = (probe_model >> 8) & 0xFF
        var bb = probe_model & 0xFF
        
        if aa == 0x00
            return f"Water depth: {bb}m range"
        elif aa == 0x01
            return f"Pressure type: {bb}"
        elif aa == 0x02
            return f"Differential: {bb} range"
        else
            return f"Unknown probe: {probe_model:04X}"
        end
    end
    
    def calculate_derived_values(data)
        # Calculate pressure/depth based on probe configuration
        if data.contains('probe_model') && data.contains('idc_current')
            var probe_model = data['probe_model']
            var aa = (probe_model >> 8) & 0xFF
            var bb = probe_model & 0xFF
            var current = data['idc_current']
            
            # 4-20mA to 0-100% conversion
            if current >= 4.0 && current <= 20.0
                var percent = (current - 4.0) / 16.0 * 100.0
                
                if aa == 0x00  # Water depth
                    data['water_depth'] = percent / 100.0 * bb  # meters
                elif aa == 0x01  # Pressure
                    # Assume bb represents pressure range in different units
                    data['pressure_pa'] = percent / 100.0 * bb * 1000  # Convert to Pa
                end
            end
        end
    end
    
    def voltage_to_percent(voltage)
        if voltage >= 3.6 return 100
        elif voltage <= 2.5 return 0
        else return int((voltage - 2.5) / 1.1 * 100)
        end
    end
    
    def get_node_stats(node_id)
        import global
        var node_data = global.PS_LB_nodes.find(node_id, nil)
        if node_data == nil return nil end
        
        return {
            'last_update': node_data.find('last_update', 0),
            'battery_history': node_data.find('battery_history', []),
            'name': node_data.find('name', 'Unknown')
        }
    end
    
    def clear_node_data(node_id)
        import global
        if global.PS_LB_nodes.contains(node_id)
            global.PS_LB_nodes.remove(node_id)
            return true
        end
        return false
    end
    
    def register_downlink_commands()
        import string
        
        tasmota.remove_cmd("LwPSInterval")
        tasmota.add_cmd("LwPSInterval", def(cmd, idx, payload_str)
            var interval = int(payload_str)
            if interval < 30 || interval > 16777215
                return tasmota.resp_cmnd_str("Invalid: range 30-16777215 seconds")
            end
            
            var hex_cmd = f"01{(interval >> 16) & 0xFF:02X}{(interval >> 8) & 0xFF:02X}{interval & 0xFF:02X}"
            return lwdecode.SendDownlink(global.PS_LB_nodes, cmd, idx, hex_cmd)
        end)
        
        tasmota.remove_cmd("LwPSInterrupt")
        tasmota.add_cmd("LwPSInterrupt", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.PS_LB_nodes, cmd, idx, payload_str, {
                '0|DISABLE': ['06000000', 'Disabled'],
                '1|FALL': ['06000001', 'Falling Edge'],
                '2|RISE': ['06000002', 'Rising Edge'],
                '3|BOTH': ['06000003', 'Both Edges']
            })
        end)
        
        tasmota.remove_cmd("LwPSOutput")
        tasmota.add_cmd("LwPSOutput", def(cmd, idx, payload_str)
            var parts = string.split(payload_str, ',')
            if size(parts) != 2
                return tasmota.resp_cmnd_str("Usage: LwPSOutput<slot> <type>,<duration>")
            end
            
            var output_type = int(parts[0])
            var duration = int(parts[1])
            
            if output_type < 1 || output_type > 3
                return tasmota.resp_cmnd_str("Invalid type: 1=3V3, 2=5V, 3=12V")
            end
            
            var hex_cmd = f"07{output_type:02X}{(duration >> 8) & 0xFF:02X}{duration & 0xFF:02X}"
            return lwdecode.SendDownlink(global.PS_LB_nodes, cmd, idx, hex_cmd)
        end)
        
        tasmota.remove_cmd("LwPSProbeModel")
        tasmota.add_cmd("LwPSProbeModel", def(cmd, idx, payload_str)
            var model = int(payload_str)
            if model < 0 || model > 65535
                return tasmota.resp_cmnd_str("Invalid: range 0-65535")
            end
            
            var hex_cmd = f"08{(model >> 8) & 0xFF:02X}{model & 0xFF:02X}"
            return lwdecode.SendDownlink(global.PS_LB_nodes, cmd, idx, hex_cmd)
        end)
        
        tasmota.remove_cmd("LwPSStatus")
        tasmota.add_cmd("LwPSStatus", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.PS_LB_nodes, cmd, idx, "2601")
        end)
        
        tasmota.remove_cmd("LwPSClearData")
        tasmota.add_cmd("LwPSClearData", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.PS_LB_nodes, cmd, idx, "A301")
        end)
        
        print("PS-LB: Downlink commands registered")
    end
end

LwDeco = LwDecode_PS_LB()

tasmota.remove_cmd("LwPSNodeStats")
tasmota.add_cmd("LwPSNodeStats", def(cmd, idx, node_id)
    var stats = LwDeco.get_node_stats(node_id)
    if stats != nil
        import json
        tasmota.resp_cmnd(json.dump(stats))
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

tasmota.remove_cmd("LwPSClearNode")
tasmota.add_cmd("LwPSClearNode", def(cmd, idx, node_id)
    if LwDeco.clear_node_data(node_id)
        tasmota.resp_cmnd_done()
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

tasmota.remove_cmd("LwPSTestUI")
tasmota.add_cmd("LwPSTestUI", def(cmd, idx, payload_str)
    var test_scenarios = {
        "normal":     "001039304E200FA000",    # Port 2: Water depth probe, 15.6mA, 20V, normal
        "pressure":   "010139304E200FA000",    # Port 2: Pressure probe, 15.6mA, 20V
        "low_current": "00102EE04E200FA000",   # Port 2: 12mA current (low pressure)
        "high_current": "00104E204E200FA000",  # Port 2: 20mA current (high pressure)
        "roc_alert":  "001039304E200FA0F0",    # Port 2: ROC triggered (all flags)
        "interrupt":  "001039304E200FA001",    # Port 2: Interrupt triggered
        "config":     "1601000100FA0",         # Port 5: Device status
        "multi":      "000A39303930",          # Port 7: Multi-collection, 2 readings
        "datalog":    "001039304E2000000000000", # Port 3: Historical with timestamp
        "demo":       "001039304E200FA000"     # Port 2: Comprehensive demo
    }
    
    var hex_payload = test_scenarios.find(payload_str ? payload_str : 'nil', 'not_found')
    
    if hex_payload == 'not_found'
        var scenarios_list = "normal pressure low_current high_current roc_alert interrupt config multi datalog demo "
        return tasmota.resp_cmnd_str(f"Available scenarios: {scenarios_list}")
    end
    
    var rssi = -75
    var fport = 2
    if payload_str == "config" fport = 5 end
    if payload_str == "multi" fport = 7 end
    if payload_str == "datalog" fport = 3 end

    return tasmota.cmd(f'LwSimulate{idx} {rssi},{fport},{hex_payload}')
end)

tasmota.add_driver(LwDeco)