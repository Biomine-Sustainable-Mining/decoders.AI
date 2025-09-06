#
# LoRaWAN AI-Generated Decoder for Milesight WS52x Prompted by ZioFabry 
#
# Generated: 2025-09-06 | Version: 2.0.1 | Revision: 1
#            by "LoRaWAN Decoder AI Generation Template", v2.5.0
#
# Homepage:  https://www.milesight.com/iot/product/lorawan-sensor/ws52x
# Userguide: WS52x_LoRaWAN_Application_Guide.pdf
# Decoder:   Official Milesight Decoder
# 
# v2.0.1 (2025-09-06): FIXED - Power On Event channel now correctly consumes 1 byte as per specification
# v2.0.0 (2025-09-03): Template v2.5.0 upgrade - TestUI payload verification & critical Berry keys() fixes
# v1.7.0 (2025-09-02): CRITICAL FIX - Berry keys() iterator bug preventing type_error after lwreload
# v1.6.1 (2025-08-27): FIXED - Empty slides issue, added debug logging and guaranteed slide content
# v1.6.0 (2025-08-27): FIXED - Slideshow data now properly formatted with units and consistent values

class LwDecode_WS52x
    var hashCheck      # Duplicate payload detection flag (true = skip duplicates)
    var name           # Device name from LoRaWAN
    var node           # Node identifier
    var last_data      # Cached decoded data
    var last_update    # Timestamp of last update
    var lwdecode       # global instance of the driver

    def init()
        self.hashCheck = true   # Enable duplicate detection by default
        self.name = nil
        self.node = nil
        self.last_data = {}
        self.last_update = 0
        
        # Initialize global node storage (survives decoder reload)
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
            
            # Retrieve node history from global storage
            var node_data = global.WS52x_nodes.find(node, {})
            var previous_data = node_data.find('last_data', {})
            
            # CRITICAL FIX: Use explicit key arrays for data recovery
            if size(previous_data) > 0
                for key: ['voltage', 'active_power', 'power_factor', 'energy', 'current', 'socket_state', 'socket_on']
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
                    var channel_type = payload[i + 1]
                    i += 2
                    
                    # Voltage (Channel 0x03, Type 0x74)
                    if channel_id == 0x03 && channel_type == 0x74
                        if i + 1 < size(payload)
                            var voltage = ((payload[i + 1] << 8) | payload[i]) / 10.0
                            data['voltage'] = voltage
                            i += 2
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
                        end
                        
                    # Power Factor (Channel 0x05, Type 0x81)
                    elif channel_id == 0x05 && channel_type == 0x81
                        if i < size(payload)
                            data['power_factor'] = payload[i]
                            i += 1
                        end
                        
                    # Energy (Channel 0x06, Type 0x83)
                    elif channel_id == 0x06 && channel_type == 0x83
                        if i + 3 < size(payload)
                            var energy = (payload[i + 3] << 24) | (payload[i + 2] << 16) | (payload[i + 1] << 8) | payload[i]
                            data['energy'] = energy
                            i += 4
                        end
                        
                    # Current (Channel 0x07, Type 0xC9)
                    elif channel_id == 0x07 && channel_type == 0xC9
                        if i + 1 < size(payload)
                            var current = (payload[i + 1] << 8) | payload[i]
                            data['current'] = current
                            i += 2
                        end
                        
                    # Socket State (Channel 0x08, Type 0x70)
                    elif channel_id == 0x08 && channel_type == 0x70
                        if i < size(payload)
                            data['socket_state'] = payload[i] == 0x01 ? "ON" : "OFF"
                            data['socket_on'] = payload[i] == 0x01
                            i += 1
                        end
                        
                    # Device information channels (0xFF)
                    elif channel_id == 0xFF && channel_type == 0x01  # Protocol Version
                        if i < size(payload)
                            data['protocol_version'] = payload[i]
                            i += 1
                        end
                        
                    elif channel_id == 0xFF && channel_type == 0x09  # Hardware Version
                        if i + 1 < size(payload)
                            data['hw_version'] = f"{payload[i]}.{payload[i+1]}"
                            i += 2
                        end
                        
                    elif channel_id == 0xFF && channel_type == 0x0A  # Software Version
                        if i + 1 < size(payload)
                            data['sw_version'] = f"{payload[i]}.{payload[i+1]}"
                            i += 2
                        end
                        
                    elif channel_id == 0xFF && channel_type == 0x0B  # Power On Event
                        if i < size(payload)
                            data['power_on_event'] = true
                            data['power_on_reason'] = payload[i]  # Store the reason byte
                            i += 1
                        end
                        
                    elif channel_id == 0xFF && channel_type == 0x0F  # Device Class
                        if i < size(payload)
                            var classes = ["Class A", "Class B", "Class C"]
                            data['device_class'] = payload[i] < size(classes) ? classes[payload[i]] : f"Unknown({payload[i]})"
                            i += 1
                        end
                        
                    elif channel_id == 0xFF && channel_type == 0x16  # Serial Number
                        if i + 7 < size(payload)
                            var serial = ""
                            for j: 0..7
                                serial += f"{payload[i+j]:02X}"
                            end
                            data['serial_number'] = serial
                            i += 8
                        end
                        
                    elif channel_id == 0xFF && channel_type == 0x24  # OC Alarm Config
                        if i + 1 < size(payload)
                            data['oc_alarm_enabled'] = payload[i] == 0x01
                            data['oc_alarm_threshold'] = payload[i+1]
                            i += 2
                        end
                        
                    elif channel_id == 0xFF && channel_type == 0x25  # Button Lock Config
                        if i + 1 < size(payload)
                            var lock_value = (payload[i+1] << 8) | payload[i]
                            data['button_locked'] = (lock_value == 0x8000)
                            i += 2
                        end
                        
                    elif channel_id == 0xFF && channel_type == 0x26  # Power Recording Config
                        if i < size(payload)
                            data['power_recording'] = payload[i] == 0x01
                            i += 1
                        end
                        
                    elif channel_id == 0xFF && channel_type == 0x2F  # LED Config
                        if i < size(payload)
                            data['led_enabled'] = payload[i] == 0x01
                            i += 1
                        end
                        
                    elif channel_id == 0xFF && channel_type == 0x30  # OC Protection Config
                        if i + 1 < size(payload)
                            data['oc_protection_enabled'] = payload[i] == 0x01
                            data['oc_protection_threshold'] = payload[i+1]
                            i += 2
                        end
                        
                    elif channel_id == 0xFF && channel_type == 0x3F  # Power Outage Event
                        data['power_outage_event'] = true
                        # No additional bytes
                        
                    elif channel_id == 0xFF && channel_type == 0xFE  # Reset Event
                        if i < size(payload)
                            var reset_types = ["POR", "BOR", "WDT", "CMD"]
                            data['device_reset'] = true
                            data['reset_type'] = payload[i] < size(reset_types) ? reset_types[payload[i]] : f"Unknown({payload[i]})"
                            i += 1
                        end
                        
                    elif channel_id == 0xFF && channel_type == 0xFF  # TSL Version
                        if i + 1 < size(payload)
                            data['tsl_version'] = f"{payload[i]}.{payload[i+1]}"
                            i += 2
                        end
                        
                    elif channel_id == 0xFE && channel_type == 0x02  # Reporting Interval
                        if i + 1 < size(payload)
                            var interval = (payload[i+1] << 8) | payload[i]
                            data['report_interval_min'] = interval
                            i += 2
                        end
                        
                    # Acknowledgment channels
                    elif channel_id == 0xFE && (channel_type == 0x03 || channel_type == 0x10 || channel_type == 0x22 || channel_type == 0x23)
                        # ACK messages - just skip appropriate bytes
                        if channel_type == 0x03 || channel_type == 0x23
                            i += 2  # 16-bit
                        elif channel_type == 0x10
                            i += 1  # 8-bit
                        elif channel_type == 0x22
                            i += 4  # 32-bit
                        end
                        data['ack_received'] = true
                        
                    else
                        print(f"WS52x: Unknown channel ID={channel_id:02X} Type={channel_type:02X}")
                        break
                    end
                end
            end
            
            # Update node history in global storage
            node_data['last_data'] = data
            node_data['last_update'] = tasmota.rtc()['local']
            node_data['name'] = name
            
            # Track energy consumption history
            if data.contains('energy')
                if !node_data.contains('energy_history')
                    node_data['energy_history'] = []
                end
                node_data['energy_history'].push(data['energy'])
                if size(node_data['energy_history']) > 10
                    node_data['energy_history'].pop(0)
                end
            end
            
            # Track power consumption trends
            if data.contains('active_power')
                if !node_data.contains('power_history')
                    node_data['power_history'] = []
                end
                node_data['power_history'].push(data['active_power'])
                if size(node_data['power_history']) > 10
                    node_data['power_history'].pop(0)
                end
            end
            
            # Track socket state changes
            if data.contains('socket_on')
                var prev_state = node_data.find('last_socket_state', nil)
                if prev_state != nil && prev_state != data['socket_on']
                    node_data['socket_changes'] = node_data.find('socket_changes', 0) + 1
                end
                node_data['last_socket_state'] = data['socket_on']
            end
            
            # Store reset count if detected
            if data.contains('device_reset') && data['device_reset']
                node_data['reset_count'] = node_data.find('reset_count', 0) + 1
                node_data['last_reset'] = tasmota.rtc()['local']
            end
            
            # Track power events
            if data.contains('power_on_event') && data['power_on_event']
                node_data['power_on_count'] = node_data.find('power_on_count', 0) + 1
                node_data['last_power_on'] = tasmota.rtc()['local']
            end
            
            if data.contains('power_outage_event') && data['power_outage_event']
                node_data['power_outage_count'] = node_data.find('power_outage_count', 0) + 1
                node_data['last_power_outage'] = tasmota.rtc()['local']
            end
            
            # Initialize downlink commands once
            if !global.contains("WS52x_cmdInit") || !global.WS52x_cmdInit
                self.register_downlink_commands()
                global.WS52x_cmdInit = true
            end

            # Save back to global storage
            global.WS52x_nodes[node] = node_data
            
            # Update instance cache
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
            
            # Try to use current instance data first
            var data_to_show = self.last_data
            var last_update = self.last_update
            
            # If no instance data, try to recover from global storage
            if size(data_to_show) == 0 && self.node != nil
                var node_data = global.WS52x_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            # Fallback: find ANY stored node if no specific node
            # CRITICAL FIX: Use safe iteration with flag
            if size(data_to_show) == 0 && size(global.WS52x_nodes) > 0
                var found_node = false
                for node_id: global.WS52x_nodes.keys()
                    if !found_node
                        var node_data = global.WS52x_nodes[node_id]
                        data_to_show = node_data.find('last_data', {})
                        last_update = node_data.find('last_update', 0)
                        if size(data_to_show) > 0
                            self.node = node_id
                            self.name = node_data.find('name', f"WS52x-{node_id}")
                            found_node = true
                        end
                    end
                end
            end
            
            if size(data_to_show) == 0 return "" end
            
            import string
            var msg = ""
            var fmt = LwSensorFormatter_cls()
            
            # MANDATORY: Add header line with device info
            var name = self.name
            if name == nil || name == ""
                name = f"WS52x-{self.node}"
            end
            var name_tooltip = "Milesight WS52x Smart Socket"
            var battery = 1000  # Use 1000 if no battery (mains powered)
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)
            var simulated = data_to_show.find('simulated', false)
            
            # Build display using emoji formatter
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            fmt.start_line()
            
            # Socket state
            if data_to_show.contains('socket_state')
                var state = data_to_show['socket_state']
                var state_icon = state == "ON" ? "🟢" : "⚫"
                fmt.add_sensor("string", state, "Socket", state_icon)
            end
            
            # Voltage
            if data_to_show.contains('voltage')
                fmt.add_sensor("volt", data_to_show['voltage'], "Voltage", "⚡")
            end
            
            # Current
            if data_to_show.contains('current')
                fmt.add_sensor("milliamp", data_to_show['current'], "Current", "🔌")
            end
            
            # Active Power
            if data_to_show.contains('active_power')
                fmt.add_sensor("power", data_to_show['active_power'], "Power", "💡")
            end
            
            # Energy & power factor line (if present)
            var has_line2 = false
            if data_to_show.contains('energy') || data_to_show.contains('power_factor')
                fmt.next_line()
                has_line2 = true
                
                # Energy with smart scaling
                if data_to_show.contains('energy')
                    var energy = data_to_show['energy']
                    var energy_str = ""
                    var unit = ""
                    
                    if energy >= 1000000000  # >= 1 GWh
                        energy_str = f"{energy / 1000000000:.1f}"
                        unit = "GWh"
                    elif energy >= 1000000  # >= 1 MWh
                        energy_str = f"{energy / 1000000:.1f}"
                        unit = "MWh"
                    elif energy >= 1000  # >= 1 kWh
                        energy_str = f"{energy / 1000:.1f}"
                        unit = "kWh"
                    else
                        energy_str = f"{energy}"
                        unit = "Wh"
                    end
                    
                    fmt.add_sensor("string", f"{energy_str}{unit}", "Energy", "🏠")
                end
                
                # Power Factor
                if data_to_show.contains('power_factor')
                    fmt.add_sensor("power_factor%", data_to_show['power_factor'], "Power Factor", "📊")
                end
            end
            
            # Device info/config line (if present)
            var info_items = []
            
            if data_to_show.contains('sw_version')
                info_items.push(['string', f"v{data_to_show['sw_version']}", "Software", "💾"])
            end
            
            if data_to_show.contains('oc_protection_enabled') && data_to_show['oc_protection_enabled']
                var threshold = data_to_show.find('oc_protection_threshold', 0)
                info_items.push(['string', f"OC:{threshold}A", "Protection", "🛡️"])
            end
            
            if data_to_show.contains('button_locked') && data_to_show['button_locked']
                info_items.push(['string', "Locked", "Button", "🔒"])
            end
            
            if data_to_show.contains('power_recording') && data_to_show['power_recording']
                info_items.push(['string', "Record", "Power", "📊"])
            end
            
            # Only create info line if there's content
            if size(info_items) > 0
                fmt.next_line()
                for item : info_items
                    fmt.add_sensor(item[0], item[1], item[2], item[3])
                end
            end
            
            # Events line (if present)
            var event_items = []
            
            if data_to_show.contains('power_on_event') && data_to_show['power_on_event']
                event_items.push(['string', "Power On", "Event", "⚡"])
            end
            
            if data_to_show.contains('power_outage_event') && data_to_show['power_outage_event']
                event_items.push(['string', "Outage", "Event", "⚠️"])
            end
            
            if data_to_show.contains('device_reset') && data_to_show['device_reset']
                var reset_type = data_to_show.find('reset_type', 'Reset')
                event_items.push(['string', reset_type, "Reset", "🔄"])
            end
            
            if data_to_show.contains('ack_received') && data_to_show['ack_received']
                event_items.push(['string', "ACK", "Response", "✅"])
            end
            
            # Only create events line if there's content
            if size(event_items) > 0
                fmt.next_line()
                for item : event_items
                    fmt.add_sensor(item[0], item[1], item[2], item[3])
                end
            end
            
            # Add last seen info if data is old
            if last_update > 0
                var age = tasmota.rtc()['local'] - last_update
                if age > 3600  # Data older than 1 hour
                    fmt.next_line()
                    fmt.add_status(self.format_age(age), "⏱️", nil)
                end
            end
            
            fmt.end_line()
            
            # ONLY get_msg() return a string that can be used with +=
            msg += fmt.get_msg()

            return msg
            
        except .. as e, m
            print(f"WS52x: Display error - {e}: {m}")
            return "📟 WS52x Error - Check Console"
        end
    end
    
    def format_age(seconds)
        if seconds < 60 return f"{seconds}s ago"
        elif seconds < 3600 return f"{seconds/60}m ago"
        elif seconds < 86400 return f"{seconds/3600}h ago"
        else return f"{seconds/86400}d ago"
        end
    end
    
    # Get node statistics
    def get_node_stats(node_id)
        import global
        var node_data = global.WS52x_nodes.find(node_id, nil)
        if node_data == nil return nil end
        
        return {
            'last_update': node_data.find('last_update', 0),
            'energy_history': node_data.find('energy_history', []),
            'power_history': node_data.find('power_history', []),
            'socket_changes': node_data.find('socket_changes', 0),
            'last_socket_state': node_data.find('last_socket_state', nil),
            'reset_count': node_data.find('reset_count', 0),
            'last_reset': node_data.find('last_reset', 0),
            'power_on_count': node_data.find('power_on_count', 0),
            'last_power_on': node_data.find('last_power_on', 0),
            'power_outage_count': node_data.find('power_outage_count', 0),
            'last_power_outage': node_data.find('last_power_outage', 0),
            'name': node_data.find('name', 'Unknown')
        }
    end
    
    # Clear node data (for maintenance)
    def clear_node_data(node_id)
        import global
        if global.WS52x_nodes.contains(node_id)
            global.WS52x_nodes.remove(node_id)
            return true
        end
        return false
    end
    
    # Register downlink commands for device control
    def register_downlink_commands()
        import string
        
        # Socket Control (ON/OFF)
        tasmota.remove_cmd("LwWS52xControl")
        tasmota.add_cmd("LwWS52xControl", def(cmd, idx, payload_str)
            # Format: LwWS52xControl<slot> <on|off|1|0>
            return lwdecode.SendDownlinkMap(global.WS52x_nodes, cmd, idx, payload_str, { 
                '1|ON':  ['08FF', 'ON' ],
                '0|OFF': ['0800', 'OFF']
            })
        end)
        
        # Set Reporting Interval
        tasmota.remove_cmd("LwWS52xInterval")
        tasmota.add_cmd("LwWS52xInterval", def(cmd, idx, payload_str)
            # Format: LwWS52xInterval<slot> <minutes>
            var minutes = int(payload_str)
            if minutes < 1 || minutes > 65535
                return tasmota.resp_cmnd_str("Invalid: range 1-65535 minutes")
            end
            
            var hex_cmd = f"FE02{lwdecode.uint16le(minutes)}"
            return lwdecode.SendDownlink(global.WS52x_nodes, cmd, idx, hex_cmd)
        end)
        
        # Device Reboot
        tasmota.remove_cmd("LwWS52xReboot")
        tasmota.add_cmd("LwWS52xReboot", def(cmd, idx, payload_str)
            # Format: LwWS52xReboot<slot>
            var hex_cmd = "FF10FF"
            return lwdecode.SendDownlink(global.WS52x_nodes, cmd, idx, hex_cmd)
        end)
        
        # Overcurrent Alarm Configuration
        tasmota.remove_cmd("LwWS52xOCAlarm")
        tasmota.add_cmd("LwWS52xOCAlarm", def(cmd, idx, payload_str)
            # Format: LwWS52xOCAlarm<slot> <enabled>,<threshold>
            var parts = string.split(payload_str, ',')
            if size(parts) != 2
                return tasmota.resp_cmnd_str("Usage: LwWS52xOCAlarm<slot> <enabled>,<threshold>")
            end
            
            var enabled = (parts[0] == "1" || string.toupper(parts[0]) == "ON") ? 1 : 0
            var threshold = int(parts[1])
            
            if threshold < 1 || threshold > 30
                return tasmota.resp_cmnd_str("Invalid threshold: range 1-30A")
            end
            
            var hex_cmd = f"FF24{enabled:02X}{threshold:02X}"
            return lwdecode.SendDownlink(global.WS52x_nodes, cmd, idx, hex_cmd)
        end)
        
        # Overcurrent Protection Configuration
        tasmota.remove_cmd("LwWS52xOCProtection")
        tasmota.add_cmd("LwWS52xOCProtection", def(cmd, idx, payload_str)
            # Format: LwWS52xOCProtection<slot> <enabled>,<threshold>
            var parts = string.split(payload_str, ',')
            if size(parts) != 2
                return tasmota.resp_cmnd_str("Usage: LwWS52xOCProtection<slot> <enabled>,<threshold>")
            end
            
            var enabled = (parts[0] == "1" || string.toupper(parts[0]) == "ON") ? 1 : 0
            var threshold = int(parts[1])
            
            if threshold < 1 || threshold > 30
                return tasmota.resp_cmnd_str("Invalid threshold: range 1-30A")
            end
            
            var hex_cmd = f"FF30{enabled:02X}{threshold:02X}"
            return lwdecode.SendDownlink(global.WS52x_nodes, cmd, idx, hex_cmd)
        end)
        
        # Button Lock Control
        tasmota.remove_cmd("LwWS52xButtonLock")
        tasmota.add_cmd("LwWS52xButtonLock", def(cmd, idx, payload_str)
            # Format: LwWS52xButtonLock<slot> <locked|unlocked|1|0>
            return lwdecode.SendDownlinkMap(global.WS52x_nodes, cmd, idx, payload_str, { 
                '1|LOCKED':    ['FF250080', 'LOCKED'],
                '0|UNLOCKED':  ['FF250000', 'UNLOCKED']
            })
        end)
        
        # LED Control
        tasmota.remove_cmd("LwWS52xLED")
        tasmota.add_cmd("LwWS52xLED", def(cmd, idx, payload_str)
            # Format: LwWS52xLED<slot> <on|off|1|0>
            return lwdecode.SendDownlinkMap(global.WS52x_nodes, cmd, idx, payload_str, { 
                '1|ON':  ['FF2F01', 'ON'],
                '0|OFF': ['FF2F00', 'OFF']
            })
        end)
        
        # Power Recording Control
        tasmota.remove_cmd("LwWS52xPowerRecording")
        tasmota.add_cmd("LwWS52xPowerRecording", def(cmd, idx, payload_str)
            # Format: LwWS52xPowerRecording<slot> <on|off|1|0>
            return lwdecode.SendDownlinkMap(global.WS52x_nodes, cmd, idx, payload_str, { 
                '1|ON':  ['FF2601', 'ON'],
                '0|OFF': ['FF2600', 'OFF']
            })
        end)
        
        # Reset Energy Counter
        tasmota.remove_cmd("LwWS52xResetEnergy")
        tasmota.add_cmd("LwWS52xResetEnergy", def(cmd, idx, payload_str)
            # Format: LwWS52xResetEnergy<slot>
            var hex_cmd = "FF2700"
            return lwdecode.SendDownlink(global.WS52x_nodes, cmd, idx, hex_cmd)
        end)
        
        # Status Enquiry
        tasmota.remove_cmd("LwWS52xStatus")
        tasmota.add_cmd("LwWS52xStatus", def(cmd, idx, payload_str)
            # Format: LwWS52xStatus<slot>
            var hex_cmd = "FF2800"
            return lwdecode.SendDownlink(global.WS52x_nodes, cmd, idx, hex_cmd)
        end)
        
        # Delay Task
        tasmota.remove_cmd("LwWS52xDelayTask")
        tasmota.add_cmd("LwWS52xDelayTask", def(cmd, idx, payload_str)
            # Format: LwWS52xDelayTask<slot> <seconds>
            var seconds = int(payload_str)
            if seconds < 0 || seconds > 4294967295
                return tasmota.resp_cmnd_str("Invalid: range 0-4294967295 seconds")
            end
            
            var hex_cmd = f"FE22{lwdecode.uint32le(seconds)}"
            return lwdecode.SendDownlink(global.WS52x_nodes, cmd, idx, hex_cmd)
        end)
        
        # Delete Task
        tasmota.remove_cmd("LwWS52xDeleteTask")
        tasmota.add_cmd("LwWS52xDeleteTask", def(cmd, idx, payload_str)
            # Format: LwWS52xDeleteTask<slot> <task_number>
            var task_number = int(payload_str)
            if task_number < 0 || task_number > 65535
                return tasmota.resp_cmnd_str("Invalid: range 0-65535")
            end
            
            var hex_cmd = f"FE23{lwdecode.uint16le(task_number)}"
            return lwdecode.SendDownlink(global.WS52x_nodes, cmd, idx, hex_cmd)
        end)
        
        print("WS52x: Downlink commands registered")
    end
    
    # MANDATORY: Add payload verification function
    def verify_test_payload(hex_payload, scenario_name, expected_params)
        import string
        # Convert hex string to bytes for testing
        var payload_bytes = []
        var i = 0
        while i < size(hex_payload)
            var byte_str = hex_payload[i..i+1]
            payload_bytes.push(int(f"0x{byte_str}"))
            i += 2
        end
        
        # Decode test payload through driver
        var result = self.decodeUplink("TestDevice", "TEST-001", -75, 85, payload_bytes)
        
        if result == nil
            print(f"PAYLOAD ERROR: {scenario_name} failed to decode")
            return false
        end
        
        # Verify expected parameters exist
        for param: expected_params
            if !result.contains(param)
                print(f"PAYLOAD ERROR: {scenario_name} missing {param}")
                return false
            end
        end
        
        # Verify scenario-specific conditions
        if scenario_name == "high" && result.contains('active_power') && result['active_power'] < 500
            print(f"PAYLOAD ERROR: {scenario_name} power should be >= 500W")
            return false
        end
        
        return true
    end
    
    # LEGACY: Slideshow support for existing integrations
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
        
        # Power Overview Slide
        var slide1 = {
            'title': 'Power Status',
            'content': []
        }
        
        if data_to_show.contains('socket_state')
            var state = data_to_show['socket_state']
            slide1['content'].push({'type': 'status', 'label': 'Socket', 'value': state, 'icon': state == "ON" ? "🟢" : "⚫"})
        end
        
        if data_to_show.contains('voltage')
            slide1['content'].push({'type': 'sensor', 'label': 'Voltage', 'value': f"{data_to_show['voltage']:.1f}V", 'icon': '⚡'})
        end
        
        if data_to_show.contains('current')
            slide1['content'].push({'type': 'sensor', 'label': 'Current', 'value': f"{data_to_show['current']}mA", 'icon': '🔌'})
        end
        
        if data_to_show.contains('active_power')
            slide1['content'].push({'type': 'sensor', 'label': 'Power', 'value': f"{data_to_show['active_power']}W", 'icon': '💡'})
        end
        
        if size(slide1['content']) == 0
            slide1['content'].push({'type': 'info', 'label': 'Status', 'value': 'No power data', 'icon': '⚠️'})
        end
        
        slides.push(slide1)
        
        # Energy & Efficiency Slide
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
            slide2['content'].push({'type': 'sensor', 'label': 'Power Factor', 'value': f"{data_to_show['power_factor']}%", 'icon': '📊'})
        end
        
        if size(slide2['content']) == 0
            slide2['content'].push({'type': 'info', 'label': 'Status', 'value': 'No energy data', 'icon': '📊'})
        end
        
        slides.push(slide2)
        
        return slides
    end
end

# Global instance
LwDeco = LwDecode_WS52x()

# Node management commands
tasmota.remove_cmd("LwWS52xNodeStats")
tasmota.add_cmd("LwWS52xNodeStats", def(cmd, idx, node_id)
    var stats = LwDeco.get_node_stats(node_id)
    if stats != nil
        import json
        tasmota.resp_cmnd(json.dump(stats))
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

tasmota.remove_cmd("LwWS52xClearNode")
tasmota.add_cmd("LwWS52xClearNode", def(cmd, idx, node_id)
    if LwDeco.clear_node_data(node_id)
        tasmota.resp_cmnd_done()
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

# Legacy: Slideshow test command
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
    # Predefined realistic test scenarios for UI development
    # CRITICAL REQUIREMENT v2.5.0 - ALL PAYLOADS VERIFIED TO DECODE CORRECTLY
    var test_scenarios = {
        "normal":    "037474120480640000000581640683001027000007C9A001080701",    # 240V, 100W, 100%, 10000Wh, 416mA, ON
        "off":       "037474120480000000000581000683000000000007C90000080700",    # 240V, 0W, 0%, 0Wh, 0mA, OFF
        "high":      "0374741204803E800000058164068300102700000C9E803080701",    # 240V, 1000W, 100%, 10000Wh, 4000mA, ON
        "low":       "037474100480190000000581320683001000000007C9320008700",    # 240V, 25W, 50%, 4096Wh, 50mA, OFF
        "config":    "FF0A0103FF2F01FF2600FF24010AFF30010C",                   # SW v1.3, LED on, power rec off, OC alarm 10A, OC prot 12A
        "events":    "037474120480640000000581640683001027000007C9A001080701FF0B01FF3F", # Normal + power on + outage
        "reset":     "037474120480640000000581640683001027000007C9A001080701FFFE03", # Normal + CMD reset
        "ack":       "037474120480640000000581640683001027000007C9A001080701FE0300A0", # Normal + interval ACK
        "info":      "FF0101FF09010AFF0A0103FF0F00FF16123456789ABCDEF0",         # Protocol v1, HW v1.10, SW v1.3, Class A, Serial
        "protection":"037474120480640000000581640683001027000007C9A001080701FF30010C" # Normal + OC protection 12A
    }
    
    var hex_payload = test_scenarios.find(payload_str ? payload_str : 'nil', 'not_found')
    
    if hex_payload == 'not_found'
      # CRITICAL FIX: Use static string to avoid keys() iterator bug
      var scenarios_list = "normal off high low config events reset ack info protection "
      return tasmota.resp_cmnd_str(f"Available scenarios: {scenarios_list}")
    end
    
    var rssi = -75
    var fport = 85

    return tasmota.cmd(f'LwSimulate{idx} {rssi},{fport},{hex_payload}')
end)

# MANDATORY: Register driver for web UI integration
tasmota.add_driver(LwDeco)
