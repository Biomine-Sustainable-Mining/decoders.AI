class LwDecode_VS321
    var hashCheck, name, node, last_data, last_update

    def init()
        self.hashCheck = true
        self.name = nil
        self.node = nil
        self.last_data = {}
        self.last_update = 0
        
        import global
        if !global.contains("VS321_nodes")
            global.VS321_nodes = {}
        end
        if !global.contains("VS321_cmdInit")
            global.VS321_cmdInit = false
        end
    end
    
    def decodeUplink(name, node, rssi, fport, payload)
        if payload == nil || size(payload) < 1
            return nil
        end
        
        try
            self.name = name
            self.node = node
            var data = {}
            data['RSSI'] = rssi
            data['FPort'] = fport
            
            var node_data = global.VS321_nodes.find(node, {})
            var previous_data = node_data.find('last_data', {})
            
            # Start with previous sensor data for persistence, excluding events
            # Critical fix: Use size() check instead of keys() iterator to avoid Berry bug
            if size(previous_data) > 0
                for key: ['temperature', 'humidity', 'people_count', 'occupancy', 'desk_enabled', 
                         'desk_occupied', 'vacant_regions', 'total_regions', 'illuminance', 
                         'detection_status', 'temp_threshold', 'humidity_threshold',
                         'battery_pct', 'battery_v', 'device_type', 'tsl_version', 
                         'hw_version', 'fw_version', 'serial_number', 'protocol_version']
                    if previous_data.contains(key)
                        data[key] = previous_data[key]
                    end
                end
            end
            
            var i = 0
            while i < size(payload)
                if i + 1 >= size(payload) 
                    break
                end
                
                var channel = payload[i]
                var channel_type = payload[i + 1]
                i += 2
                
                # All channels handling
                if channel == 0xFF && channel_type == 0x0F
                    if i < size(payload)
                        data['device_type'] = payload[i] == 0x00 ? "Class A" : "Unknown"
                        i += 1
                    end
                elif channel == 0xFF && channel_type == 0xFF
                    if i + 1 < size(payload)
                        var version = (payload[i + 1] << 8) | payload[i]
                        data['tsl_version'] = f"{version / 100}.{version % 100}"
                        i += 2
                    end
                elif channel == 0xFF && channel_type == 0x09
                    if i + 1 < size(payload)
                        var version = (payload[i + 1] << 8) | payload[i]
                        data['hw_version'] = f"{version / 100}.{version % 100}"
                        i += 2
                    end
                elif channel == 0xFF && channel_type == 0x0A
                    if i + 1 < size(payload)
                        var version = (payload[i + 1] << 8) | payload[i]
                        data['fw_version'] = f"{version / 100}.{version % 100}"
                        i += 2
                    end
                elif channel == 0xFF && channel_type == 0x16
                    if i + 7 < size(payload)
                        var sn = ""
                        for j: 0..7
                            sn += f"{payload[i + j]:02X}"
                        end
                        data['serial_number'] = sn
                        i += 8
                    end
                elif channel == 0xFF && channel_type == 0x0B
                    if i < size(payload)
                        data['power_on'] = payload[i] == 0xFF
                        i += 1
                    end
                elif channel == 0xFF && channel_type == 0x01
                    if i < size(payload)
                        data['protocol_version'] = f"V{payload[i]}"
                        i += 1
                    end
                elif channel == 0xFF && channel_type == 0xFE
                    if i < size(payload)
                        data['device_reset'] = payload[i] == 0xFF
                        i += 1
                    end
                elif channel == 0x01 && channel_type == 0x75
                    if i < size(payload)
                        data['battery_pct'] = payload[i]
                        data['battery_v'] = payload[i] / 100.0 * 4.2
                        i += 1
                    end
                elif channel == 0x03 && channel_type == 0x67
                    if i + 1 < size(payload)
                        var temp = (payload[i + 1] << 8) | payload[i]
                        if temp > 32767
                            temp = temp - 65536
                        end
                        data['temperature'] = temp / 10.0
                        i += 2
                    end
                elif channel == 0x04 && channel_type == 0x68
                    if i < size(payload)
                        data['humidity'] = payload[i] / 2.0
                        i += 1
                    end
                elif channel == 0x05 && channel_type == 0xFD
                    if i + 1 < size(payload)
                        var count = (payload[i + 1] << 8) | payload[i]
                        data['people_count'] = count
                        data['occupancy'] = count > 0 ? "Occupied" : "Vacant"
                        i += 2
                    end
                elif channel == 0x06 && channel_type == 0xFE
                    if i + 3 < size(payload)
                        var enabled = (payload[i + 1] << 8) | payload[i]
                        var occupied = (payload[i + 3] << 8) | payload[i + 2]
                        data['desk_enabled'] = enabled
                        data['desk_occupied'] = occupied
                        
                        var vacant_count = 0
                        var total_enabled = 0
                        for bit: 0..9
                            if (enabled & (1 << bit)) != 0
                                total_enabled += 1
                                if (occupied & (1 << bit)) == 0
                                    vacant_count += 1
                                end
                            end
                        end
                        data['vacant_regions'] = vacant_count
                        data['total_regions'] = total_enabled
                        data['occupancy'] = vacant_count < total_enabled ? "Occupied" : "Vacant"
                        i += 4
                    end
                elif channel == 0x07 && channel_type == 0xFF
                    if i < size(payload)
                        data['illuminance'] = payload[i] == 0x01 ? "Bright" : "Dim"
                        i += 1
                    end
                elif channel == 0x08 && channel_type == 0xF4
                    if i + 1 < size(payload)
                        data['detection_status'] = payload[i + 1] == 0x00 ? "Normal" : "Undetectable"
                        i += 2
                    end
                elif channel == 0x83 && channel_type == 0x67
                    if i + 2 < size(payload)
                        var temp = (payload[i + 1] << 8) | payload[i]
                        if temp > 32767
                            temp = temp - 65536
                        end
                        data['temp_threshold'] = temp / 10.0
                        data['temp_alarm'] = payload[i + 2] == 0x01
                        i += 3
                    end
                elif channel == 0x84 && channel_type == 0x68
                    if i + 1 < size(payload)
                        data['humidity_threshold'] = payload[i] / 2.0
                        data['humidity_alarm'] = payload[i + 1] == 0x01
                        i += 2
                    end
                else
                    print(f"VS321: Unknown channel {channel:02X} type {channel_type:02X}")
                    i += 1
                end
            end
            
            # Update global storage
            node_data['last_data'] = data
            node_data['last_update'] = tasmota.rtc()['local']
            node_data['name'] = name
            global.VS321_nodes[node] = node_data
            
            self.last_data = data
            self.last_update = node_data['last_update']
            
            return data
            
        except .. as e, m
            print(f"VS321: Error - {e}: {m}")
            return nil
        end
    end
    
    def add_web_sensor()
        try
            var data_to_show = self.last_data
            var last_update = self.last_update
            
            if size(data_to_show) == 0 && self.node != nil
                var node_data = global.VS321_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            # Fallback: find ANY stored node if no specific node (with keys() bug fix)
            if size(data_to_show) == 0 && size(global.VS321_nodes) > 0
                # Use first available node - iterate safely without keys()
                var found_node = false
                for node_id: global.VS321_nodes.keys()
                    if !found_node
                        var node_data = global.VS321_nodes[node_id]
                        data_to_show = node_data.find('last_data', {})
                        last_update = node_data.find('last_update', 0)
                        self.node = node_id
                        self.name = node_data.find('name', f"VS321-{node_id}")
                        found_node = true
                    end
                end
            end
            
            if size(data_to_show) == 0
                return nil
            end
            
            var msg = ""
            var fmt = LwSensorFormatter_cls()
            
            var name = self.name
            if name == nil || name == ""
                name = f"VS321-{self.node}"
            end
            
            fmt.header(name, "Milesight VS321", data_to_show.find('battery_v', 1000), 
                      last_update, data_to_show.find('RSSI', 1000), 
                      last_update, data_to_show.find('simulated', false))
            
            # Always show main data line with persistent values
            var has_main_data = false
            fmt.start_line()
            
            if data_to_show.contains('temperature')
                fmt.add_sensor("temp", data_to_show['temperature'], "Temperature", "🌡️")
                has_main_data = true
            end
            if data_to_show.contains('humidity')
                fmt.add_sensor("humidity", data_to_show['humidity'], "Humidity", "💧")
                has_main_data = true
            end
            if data_to_show.contains('battery_pct')
                var batt_emoji = data_to_show['battery_pct'] <= 20 ? "🪫" : "🔋"
                fmt.add_sensor("string", f"{data_to_show['battery_pct']}%", "Battery", batt_emoji)
                has_main_data = true
            end
            if data_to_show.contains('occupancy')
                var occupancy = data_to_show['occupancy']
                var emoji = occupancy == "Occupied" ? "🟢" : "⭕"
                fmt.add_sensor("string", occupancy, "Status", emoji)
                has_main_data = true
            end
            
            if has_main_data
                fmt.end_line()
                msg += fmt.get_msg()
            end
            
            # Second line for people count, desk info, and illumination
            var has_secondary = false
            if data_to_show.contains('people_count') || data_to_show.contains('illuminance') || data_to_show.contains('desk_occupied')
                fmt.start_line()
                
                if data_to_show.contains('people_count')
                    fmt.add_sensor("people", data_to_show['people_count'], "People", "👥")
                    has_secondary = true
                end
                if data_to_show.contains('desk_occupied') && data_to_show.contains('desk_enabled')
                    var occupied = data_to_show['desk_occupied']
                    var enabled = data_to_show['desk_enabled']
                    fmt.add_sensor("string", f"{occupied}/{enabled}", "Desks O/E", "🪑")
                    has_secondary = true
                end
                if data_to_show.contains('illuminance')
                    var illum_emoji = data_to_show['illuminance'] == "Bright" ? "☀️" : "🌙"
                    fmt.add_sensor("string", data_to_show['illuminance'], "Light", illum_emoji)
                    has_secondary = true
                end
                if data_to_show.contains('detection_status')
                    var detect_emoji = data_to_show['detection_status'] == "Normal" ? "👁️" : "❌"
                    fmt.add_sensor("string", data_to_show['detection_status'], "Detection", detect_emoji)
                    has_secondary = true
                end
                
                if has_secondary
                    fmt.end_line()
                    msg += fmt.get_msg()
                end
            end
            
            # Third line for device info (for demo/config scenarios)
            var has_device_info = false
            if data_to_show.contains('fw_version') || data_to_show.contains('hw_version') || data_to_show.contains('device_type')
                fmt.start_line()
                
                if data_to_show.contains('fw_version')
                    fmt.add_sensor("string", f"FW{data_to_show['fw_version']}", "Firmware", "⚙️")
                    has_device_info = true
                end
                if data_to_show.contains('hw_version')
                    fmt.add_sensor("string", f"HW{data_to_show['hw_version']}", "Hardware", "🔧")
                    has_device_info = true
                end
                if data_to_show.contains('device_type')
                    fmt.add_sensor("string", data_to_show['device_type'], "Type", "📡")
                    has_device_info = true
                end
                if data_to_show.contains('protocol_version')
                    fmt.add_sensor("string", data_to_show['protocol_version'], "Protocol", "📋")
                    has_device_info = true
                end
                
                if has_device_info
                    fmt.end_line()
                    msg += fmt.get_msg()
                end
            end
            
            # Fourth line for thresholds (when alarms are present)
            var has_thresholds = false
            if data_to_show.contains('temp_threshold') || data_to_show.contains('humidity_threshold')
                fmt.start_line()
                
                if data_to_show.contains('temp_threshold')
                    fmt.add_sensor("temp", data_to_show['temp_threshold'], "Temp Limit", "🚨")
                    has_thresholds = true
                end
                if data_to_show.contains('humidity_threshold')
                    fmt.add_sensor("humidity", data_to_show['humidity_threshold'], "Humid Limit", "💦")
                    has_thresholds = true
                end
                
                if has_thresholds
                    fmt.end_line()
                    msg += fmt.get_msg()
                end
            end
            
            # Events line - show all possible events with enhanced details
            var has_events = false
            var event_content = []
            
            if data_to_show.contains('device_reset') && data_to_show['device_reset']
                event_content.push(['string', 'Reset', 'Device Reset Event', '🔄'])
                has_events = true
            end
            if data_to_show.contains('power_on') && data_to_show['power_on']
                event_content.push(['string', 'PowerUp', 'Power-On Event', '⚡'])
                has_events = true
            end
            if data_to_show.contains('temp_alarm') && data_to_show['temp_alarm']
                event_content.push(['string', 'TempAlert', 'Temperature Alarm Active', '🌡️'])
                has_events = true
            end
            if data_to_show.contains('humidity_alarm') && data_to_show['humidity_alarm']
                event_content.push(['string', 'HumidAlert', 'Humidity Alarm Active', '💧'])
                has_events = true
            end
            
            if has_events
                fmt.start_line()
                for content : event_content
                    fmt.add_sensor(content[0], content[1], content[2], content[3])
                end
                fmt.end_line()
                msg += fmt.get_msg()
            end
            
            # Serial number line (for demo/config with long serial)
            if data_to_show.contains('serial_number')
                fmt.start_line()
                fmt.add_sensor("string", f"S/N:{data_to_show['serial_number']}", "Serial Number", "🏷️")
                fmt.end_line()
                msg += fmt.get_msg()
            end
            
            return msg
            
        except .. as e, m
            return "📟 VS321 Error"
        end
    end
end

LwDeco = LwDecode_VS321()

tasmota.remove_cmd("LwVS321TestUI")
tasmota.add_cmd("LwVS321TestUI", def(cmd, idx, payload_str)
    var test_scenarios = {
        "normal":     "0175640367100104683205FD030006FE030007FF01",      # Normal: 3 people, temp 27.2°C, humidity 41%
        "occupied":   "0175600367120104683505FD050006FE0F000AFF01",      # High occupancy: 5 people, temp 27.4°C, humidity 43%, bright light
        "vacant":     "0175580367110104683005FD000006FE000007FF00",      # Empty: 0 people, temp 27.3°C, humidity 40%, dim light
        "hot":        "8367280101846E32",                               # Temperature alarm: 40.0°C threshold exceeded
        "humid":      "84683201",                                       # Humidity alarm: 50% threshold exceeded
        "reset":      "FFFEFF01750A",                                   # Device reset event + battery 10%
        "lowbatt":    "01750A0367100104683205FD030007FF00",             # Low battery: 10%, normal readings, dim light
        "config":     "FF0F00FF0A02D0FF09020AFF16000102030405060708",     # Device info: Class A, FW v7.20, HW v5.22, serial
        "desks":      "06FE1F000F000367220104684605FD0A00",             # Desk sensor: 10 regions, 4 occupied, 10 people, temp 34°C, humidity 70%
        "demo":       "FF0F00FF0A02D0FF09020AFF16000102030405060708FF0BFFFF01010175750367100104683205FD0F0006FE3FF00F0007FF0108F40100FFFEFF8367190184643201", # Complete demo: all sensors + events
    }
    
    var hex_payload = test_scenarios.find(payload_str != nil ? payload_str : 'nil', 'not_found')
    
    if hex_payload == 'not_found'
      var scenarios_list = "normal occupied vacant hot humid reset lowbatt config desks demo "
      # Fixed: Avoid Berry keys() iterator bug in test scenarios
      return tasmota.resp_cmnd_str(f"Available scenarios: {scenarios_list}")
    end
    return tasmota.cmd(f'LwSimulate{idx} -75,85,{hex_payload}')
end)

tasmota.add_driver(LwDeco)
