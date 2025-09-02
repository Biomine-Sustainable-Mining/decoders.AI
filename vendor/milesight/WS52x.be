#
# LoRaWAN AI-Generated Decoder for Milesight WS52x Prompted by ZioFabry 
#
# Generated: 2025-09-02 | Version: 1.7.0 | Revision: 3
#            by "LoRaWAN Decoder AI Generation Template", v2.4.1
#
# v1.7.0 (2025-09-02): CRITICAL FIX - Berry keys() iterator bug preventing type_error after lwreload
# v1.6.1 (2025-08-27): FIXED - Empty slides issue, added debug logging and guaranteed slide content
# v1.6.0 (2025-08-27): FIXED - Slideshow data now properly formatted with units and consistent values

class LwDecode_WS52x
    var hashCheck, name, node, last_data, last_update, lwdecode

    def init()
        self.hashCheck = true
        self.name = nil
        self.node = nil
        self.last_data = {}
        self.last_update = 0
        
        import global
        if !global.contains("WS52x_nodes")
            global.WS52x_nodes = {}
        end
        if !global.contains("WS52x_cmdInit")
            global.WS52x_cmdInit = false
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
            
            var node_data = global.WS52x_nodes.find(node, {})
            
            if fport == 85
                var i = 0
                while i < size(payload)
                    if i + 1 >= size(payload) break end
                    
                    var channel_id = payload[i]
                    var channel_type = payload[i + 1]
                    i += 2
                    
                    # Voltage (Channel 0x03, Type 0x74)
                    if channel_id == 0x03 && channel_type == 0x74
                        if i + 1 < size(payload)
                            var voltage = ((payload[i + 1] << 8) | payload[i]) / 10.0
                            data['voltage'] = voltage
                            i += 2
                        else
                            break
                        end
                        
                    # Active Power (Channel 0x04, Type 0x80) - Signed
                    elif channel_id == 0x04 && channel_type == 0x80
                        if i + 3 < size(payload)
                            var power = (payload[i + 3] << 24) | (payload[i + 2] << 16) | (payload[i + 1] << 8) | payload[i]
                            if power > 2147483647
                                power = power - 4294967296
                            end
                            data['active_power'] = power
                            i += 4
                        else
                            break
                        end
                        
                    # Power Factor (Channel 0x05, Type 0x81)
                    elif channel_id == 0x05 && channel_type == 0x81
                        if i < size(payload)
                            data['power_factor'] = payload[i]
                            i += 1
                        else
                            break
                        end
                        
                    # Energy (Channel 0x06, Type 0x83)
                    elif channel_id == 0x06 && channel_type == 0x83
                        if i + 3 < size(payload)
                            var energy = (payload[i + 3] << 24) | (payload[i + 2] << 16) | (payload[i + 1] << 8) | payload[i]
                            data['energy'] = energy
                            i += 4
                        else
                            break
                        end
                        
                    # Current (Channel 0x07, Type 0xC9)
                    elif channel_id == 0x07 && channel_type == 0xC9
                        if i + 1 < size(payload)
                            var current = (payload[i + 1] << 8) | payload[i]
                            data['current'] = current
                            i += 2
                        else
                            break
                        end
                        
                    # Socket State (Channel 0x08, Type 0x70)
                    elif channel_id == 0x08 && channel_type == 0x70
                        if i < size(payload)
                            data['socket_state'] = payload[i] == 0x01 ? "ON" : "OFF"
                            i += 1
                        else
                            break
                        end
                        
                    else
                        print(f"WS52x: Unknown channel: ID={channel_id:02X} Type={channel_type:02X}")
                        i += 1
                        if i >= size(payload) - 2 break end
                    end
                end
            end
            
            # CRITICAL FIX: Use explicit key arrays instead of keys() iterator
            var existing_data = node_data.find('last_data', {})
            if size(existing_data) > 0
                for key: ['voltage', 'active_power', 'power_factor', 'energy', 'current', 'socket_state']
                    if existing_data.contains(key) && !data.contains(key)
                        data[key] = existing_data[key]
                    end
                end
            end
            
            node_data['last_data'] = data
            node_data['last_update'] = tasmota.rtc()['local']
            node_data['name'] = name
            
            if data.contains('energy')
                if !node_data.contains('energy_history')
                    node_data['energy_history'] = []
                end
                node_data['energy_history'].push(data['energy'])
                if size(node_data['energy_history']) > 10
                    node_data['energy_history'].pop(0)
                end
            end
            
            if !global.contains("WS52x_cmdInit") || !global.WS52x_cmdInit
                self.register_downlink_commands()
                global.WS52x_cmdInit = true
            end

            global.WS52x_nodes[node] = node_data
            self.last_data = data
            self.last_update = node_data['last_update']
            
            return data
            
        except .. as e, m
            print(f"WS52x: Decode error - {e}: {m}")
            return nil
        end
    end
    
    def add_web_sensor()
        try
            import global
            
            var data_to_show = self.last_data
            var last_update = self.last_update
            
            if size(data_to_show) == 0 && self.node != nil
                var node_data = global.WS52x_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            # CRITICAL FIX: Safe iteration with flag to prevent keys() iterator bug
            if size(data_to_show) == 0 && size(global.WS52x_nodes) > 0
                var found_node = false
                for node_id: global.WS52x_nodes.keys()
                    if !found_node
                        var node_data = global.WS52x_nodes[node_id]
                        data_to_show = node_data.find('last_data', {})
                        if size(data_to_show) > 0
                            self.node = node_id
                            self.name = node_data.find('name', f"WS52x-{node_id}")
                            last_update = node_data.find('last_update', 0)
                            found_node = true
                        end
                    end
                end
            end
            
            if size(data_to_show) == 0 return nil end
            
            import string
            var msg = ""
            var fmt = LwSensorFormatter_cls()
            
            var name = self.name
            if name == nil || name == ""
                name = f"WS52x-{self.node}"
            end
            
            if data_to_show.contains('slide_info')
                name += f" ({data_to_show['slide_info']})"
            end
            
            var name_tooltip = "Milesight WS52x Smart Socket"
            var battery = 1000
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)
            var simulated = data_to_show.find('simulated', false)
            
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            fmt.start_line()
            
            if data_to_show.contains('socket_state')
                var state = data_to_show['socket_state']
                var state_icon = state == "ON" ? "🟢" : "🔴"
                fmt.add_sensor("string", state, nil, state_icon)
            end
            
            if data_to_show.contains('voltage')
                fmt.add_sensor("volt", data_to_show['voltage'], "Voltage", "⚡")
            end
            
            if data_to_show.contains('current')
                fmt.add_sensor("milliamp", data_to_show['current'], "Current", "🔌")
            end
            
            if data_to_show.contains('active_power')
                fmt.add_sensor("power", data_to_show['active_power'], "Power", "💡")
            end
            
            if data_to_show.contains('energy') || data_to_show.contains('power_factor')
                fmt.next_line()
                
                if data_to_show.contains('energy')
                    var energy = data_to_show['energy']
                    var energy_str = ""
                    var unit = ""
                    
                    if energy >= 1000000000
                        energy_str = f"{energy / 1000000000:.1f}"
                        unit = "GWh"
                    elif energy >= 1000000
                        energy_str = f"{energy / 1000000:.1f}"
                        unit = "MWh"
                    elif energy >= 1000
                        energy_str = f"{energy / 1000:.1f}"
                        unit = "kWh"
                    else
                        energy_str = f"{energy}"
                        unit = "Wh"
                    end
                    
                    fmt.add_sensor("string", f"{energy_str}{unit}", "Energy", "🏠")
                end
                
                if data_to_show.contains('power_factor')
                    fmt.add_sensor("power_factor%", data_to_show['power_factor'], "Power Factor", "📊")
                end
            end
            
            fmt.end_line()
            msg += fmt.get_msg()
            return msg
            
        except .. as e, m
            print(f"WS52x: Display error - {e}: {m}")
            return "📟 WS52x Error - Check Console"
        end
    end
    
    def register_downlink_commands()
        # Simplified - just socket control for now
        tasmota.remove_cmd("LwWS52xControl")
        tasmota.add_cmd("LwWS52xControl", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.WS52x_nodes, cmd, idx, payload_str, { 
                '1|ON':  ['08FF', 'ON' ],
                '0|OFF': ['0800', 'OFF']
            })
        end)
        print("WS52x: Commands registered")
    end
    
    # FIXED: Build slideshow with guaranteed content
    def build_slideshow_slides()
        import global
        var slides = []
        
        var data_to_show = self.last_data
        if size(data_to_show) == 0 && self.node != nil
            var node_data = global.WS52x_nodes.find(self.node, {})
            data_to_show = node_data.find('last_data', {})
        end
        
        # CRITICAL FIX: Safe iteration to prevent keys() iterator bug
        if size(data_to_show) == 0 && size(global.WS52x_nodes) > 0
            var found_node = false
            for node_id: global.WS52x_nodes.keys()
                if !found_node
                    var node_data = global.WS52x_nodes[node_id]
                    data_to_show = node_data.find('last_data', {})
                    if size(data_to_show) > 0
                        found_node = true
                    end
                end
            end
        end
        
        # CRITICAL FIX: Avoid keys() method in debug output to prevent iterator bug
        if size(data_to_show) > 0
            print("WS52x Slideshow Debug - Data available")
        else
            print("WS52x Slideshow Debug - No data available")
        end
        
        # Slide 1: Power Overview - Always create slide
        var slide1 = {
            'title': 'Power Status',
            'content': []
        }
        
        if data_to_show.contains('socket_state')
            var state = data_to_show['socket_state']
            slide1['content'].push({'type': 'status', 'label': 'Socket', 'value': state, 'icon': state == "ON" ? "🟢" : "🔴"})
        end
        
        if data_to_show.contains('voltage')
            var voltage_str = f"{data_to_show['voltage']:.1f}V"
            slide1['content'].push({'type': 'sensor', 'label': 'Voltage', 'value': voltage_str, 'icon': '⚡'})
        end
        
        if data_to_show.contains('current')
            var current_str = f"{data_to_show['current']}mA"
            slide1['content'].push({'type': 'sensor', 'label': 'Current', 'value': current_str, 'icon': '🔌'})
        end
        
        if data_to_show.contains('active_power')
            var power_str = f"{data_to_show['active_power']}W"
            slide1['content'].push({'type': 'sensor', 'label': 'Power', 'value': power_str, 'icon': '💡'})
        end
        
        # Add placeholder if no power data
        if size(slide1['content']) == 0
            slide1['content'].push({'type': 'info', 'label': 'Status', 'value': 'No power data', 'icon': '⚠️'})
        end
        
        slides.push(slide1)
        
        # Slide 2: Energy & Efficiency - Always create slide
        var slide2 = {
            'title': 'Energy & Efficiency', 
            'content': []
        }
        
        if data_to_show.contains('energy')
            var energy = data_to_show['energy']
            var energy_str = ""
            
            if energy >= 1000000000
                energy_str = f"{energy / 1000000000:.1f}GWh"
            elif energy >= 1000000
                energy_str = f"{energy / 1000000:.1f}MWh"
            elif energy >= 1000
                energy_str = f"{energy / 1000:.1f}kWh"
            else
                energy_str = f"{energy}Wh"
            end
            
            slide2['content'].push({'type': 'sensor', 'label': 'Energy', 'value': energy_str, 'icon': '🏠'})
        end
        
        if data_to_show.contains('power_factor')
            var pf_str = f"{data_to_show['power_factor']}%"
            slide2['content'].push({'type': 'sensor', 'label': 'Power Factor', 'value': pf_str, 'icon': '📊'})
        end
        
        # Add placeholder if no energy data
        if size(slide2['content']) == 0
            slide2['content'].push({'type': 'info', 'label': 'Status', 'value': 'No energy data', 'icon': '📊'})
        end
        
        slides.push(slide2)
        
        # Slide 3: Device Status - Always create
        var slide3 = {
            'title': 'Device Status',
            'content': [{'type': 'info', 'label': 'Device', 'value': 'WS52x Socket', 'icon': '🔌'}]
        }
        slides.push(slide3)
        
        # Slide 4: Configuration - Always create
        var slide4 = {
            'title': 'Configuration',
            'content': [{'type': 'info', 'label': 'Port', 'value': '85', 'icon': '⚙️'}]
        }
        slides.push(slide4)
        
        return slides
    end
end

# Global instance
LwDeco = LwDecode_WS52x()

# Slideshow test command
tasmota.remove_cmd("LwWS52xSlideshow")
tasmota.add_cmd("LwWS52xSlideshow", def(cmd, idx, payload_str)
    var slides = LwDeco.build_slideshow_slides()
    import json
    var result = {
        'slides_count': size(slides),
        'slides': slides
    }
    tasmota.resp_cmnd(json.dump(result))
end)

# Test UI command
tasmota.remove_cmd("LwWS52xTestUI")
tasmota.add_cmd("LwWS52xTestUI", def(cmd, idx, payload_str)
    var test_scenarios = {
        "normal":    "037474120480FF0F000005816406830010270000C91401087001",
        "off":       "037474120480000000000581640683000000000C914000870100",
        "high":      "037474230480802B00000581966483801027000C9640108701",
        "low":       "037474100480100000000581196483001000000C9100108700"
    }
    
    var hex_payload = test_scenarios.find(payload_str ? payload_str : 'nil', 'not_found')
    
    if hex_payload == 'not_found'
        # CRITICAL FIX: Use static string to avoid keys() iterator bug
        var scenarios_list = "normal off high low "
        return tasmota.resp_cmnd_str(format("Available scenarios: %s", scenarios_list))
    end
    
    return tasmota.cmd(f'LwSimulate{idx} -75,85,{hex_payload}')
end)

# Register driver
tasmota.add_driver(LwDeco)
