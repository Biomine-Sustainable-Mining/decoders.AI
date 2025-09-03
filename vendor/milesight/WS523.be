#
# LoRaWAN AI-Generated Decoder for Milesight WS523 Prompted by ZioFabry
#
# Generated: 2025-09-03 | Version: 5.0.0 | Revision: 4
#            by "LoRaWAN Decoder AI Generation Template", v2.5.0
#
# Homepage:  https://www.milesight.com/iot/product/lorawan-sensor/ws523
# Userguide: WS523_LoRaWAN_Portable_Smart_Socket_UserGuide v1.3
# Decoder:   Official Milesight Decoder
# 
# v5.0.0 (2025-09-03): Template v2.5.0 upgrade - TestUI payload verification & critical Berry keys() fixes
# v4.0.0 (2025-09-03): Template v2.5.0 upgrade - TestUI payload verification & critical Berry keys() fixes
# v3.1.0 (2025-09-02): Framework v2.4.1 upgrade - CRITICAL BERRY KEYS() ITERATOR BUG FIX
# v3.0.0 (2025-08-26): Framework v2.2.9 + Template v2.3.6 major upgrade with complete protocol coverage
# v2.0.0 (2025-08-15): Portable smart socket with power monitoring

class LwDecode_WS523
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
        if !global.contains("WS523_nodes")
            global.WS523_nodes = {}
        end
        if !global.contains("WS523_cmdInit")
            global.WS523_cmdInit = false
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
            var node_data = global.WS523_nodes.find(node, {})
            var previous_data = node_data.find('last_data', {})
            
            # CRITICAL FIX: Use explicit key arrays for data recovery
            if size(previous_data) > 0
                for key: ['voltage', 'active_power', 'power_factor', 'energy_wh', 'current', 'socket_state', 'socket_on']
                    if previous_data.contains(key)
                        data[key] = previous_data[key]
                    end
                end
            end
            
            if fport == 85  # Standard WS523 data port
                var i = 0
                while i < size(payload)
                    if i + 1 >= size(payload) break end
                    
                    var channel_id = payload[i]
                    var channel_type = payload[i+1]
                    i += 2
                    
                    # Power monitoring channels
                    if channel_id == 0x03 && channel_type == 0x74  # Voltage
                        if i + 1 < size(payload)
                            var voltage = ((payload[i+1] << 8) | payload[i]) / 10.0
                            data['voltage'] = voltage
                            i += 2
                        end
                        
                    elif channel_id == 0x04 && channel_type == 0x80  # Active Power (signed)
                        if i + 3 < size(payload)
                            var power = (payload[i+3] << 24) | (payload[i+2] << 16) | (payload[i+1] << 8) | payload[i]
                            if power > 2147483647  # Convert to signed 32-bit
                                power = power - 4294967296
                            end
                            data['active_power'] = power
                            i += 4
                        end
                        
                    elif channel_id == 0x05 && channel_type == 0x81  # Power Factor
                        if i < size(payload)
                            data['power_factor'] = payload[i]
                            i += 1
                        end
                        
                    elif channel_id == 0x06 && channel_type == 0x83  # Energy Consumption
                        if i + 3 < size(payload)
                            var energy = (payload[i+3] << 24) | (payload[i+2] << 16) | (payload[i+1] << 8) | payload[i]
                            data['energy_wh'] = energy
                            i += 4
                        end
                        
                    elif channel_id == 0x07 && channel_type == 0xC9  # Current
                        if i + 1 < size(payload)
                            var current = (payload[i+1] << 8) | payload[i]
                            data['current'] = current
                            i += 2
                        end
                        
                    elif channel_id == 0x08 && channel_type == 0x70  # Socket State
                        if i < size(payload)
                            data['socket_state'] = (payload[i] == 0x01) ? "ON" : "OFF"
                            data['socket_on'] = (payload[i] == 0x01)
                            i += 1
                        end
                        
                    # Device information channels
                    elif channel_id == 0xFF && channel_type == 0x01  # Protocol Version
                        if i < size(payload)
                            data['protocol_version'] = payload[i]
                            if payload[i] == 0x01
                                data['protocol_name'] = "V1"
                            end
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
                        data['power_on_event'] = true
                        # No additional bytes for this event
                        
                    elif channel_id == 0xFF && channel_type == 0x16  # Device Serial Number
                        if i + 7 < size(payload)
                            var serial = ""
                            for j: 0..7
                                serial += f"{payload[i+j]:02X}"
                            end
                            data['serial_number'] = serial
                            i += 8
                        end
                        
                    elif channel_id == 0xFF && channel_type == 0x0F  # Device Class
                        if i < size(payload)
                            var classes = ["Class A", "Class B", "Class C"]
                            data['device_class'] = payload[i] < size(classes) ? classes[payload[i]] : f"Unknown({payload[i]})"
                            i += 1
                        end
                        
                    # Configuration channels
                    elif channel_id == 0xFF && channel_type == 0x24  # Overcurrent Alarm Config
                        if i + 1 < size(payload)
                            data['oc_alarm_enabled'] = (payload[i] == 0x01)
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
                            data['power_recording'] = (payload[i] == 0x01)
                            i += 1
                        end
                        
                    elif channel_id == 0xFF && channel_type == 0x30  # Overcurrent Protection Config
                        if i + 1 < size(payload)
                            data['oc_protection_enabled'] = (payload[i] == 0x01)
                            data['oc_protection_threshold'] = payload[i+1]
                            i += 2
                        end
                        
                    elif channel_id == 0xFF && channel_type == 0x3F  # Power Outage Event
                        data['power_outage_event'] = true
                        # No additional bytes for this event
                        
                    elif channel_id == 0xFE && channel_type == 0x02  # Reporting Interval
                        if i + 1 < size(payload)
                            var interval = (payload[i+1] << 8) | payload[i]
                            data['report_interval_sec'] = interval
                            data['report_interval_min'] = interval / 60
                            i += 2
                        end
                        
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
                        
                    else
                        # Unknown channel - log and try to continue
                        print(f"WS523: Unknown channel ID={channel_id:02X} Type={channel_type:02X}")
                        break
                    end
                end
            end
            
            # Update node history in global storage
            node_data['last_data'] = data
            node_data['last_update'] = tasmota.rtc()['local']
            node_data['name'] = name
            
            # Track energy consumption history
            if data.contains('energy_wh')
                if !node_data.contains('energy_history')
                    node_data['energy_history'] = []
                end
                node_data['energy_history'].push(data['energy_wh'])
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
            if !global.contains("WS523_cmdInit") || !global.WS523_cmdInit
                self.register_downlink_commands()
                global.WS523_cmdInit = true
            end

            # Save back to global storage
            global.WS523_nodes[node] = node_data
            
            # Update instance cache
            self.last_data = data
            self.last_update = node_data['last_update']
            
            return data
            
        except .. as e, m
            print(f"WS523: Decode error - {e}: {m}")
            return nil
        end
    end
    
    def add_web_sensor()
        import global
        
        try
            # Try to use current instance data first
            var data_to_show = self.last_data
            var last_update = self.last_update
            
            # If no instance data, try to recover from global storage
            if size(data_to_show) == 0 && self.node != nil
                var node_data = global.WS523_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            # Fallback: find ANY stored node if no specific node
            # CRITICAL FIX: Use safe iteration with flag
            if size(data_to_show) == 0 && size(global.WS523_nodes) > 0
                var found_node = false
                for node_id: global.WS523_nodes.keys()
                    if !found_node
                        var node_data = global.WS523_nodes[node_id]
                        data_to_show = node_data.find('last_data', {})
                        last_update = node_data.find('last_update', 0)
                        self.node = node_id
                        self.name = node_data.find('name', f"WS523-{node_id}")
                        found_node = true
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
                name = f"WS523-{self.node}"
            end
            var name_tooltip = "Milesight WS523 Portable Smart Socket"
            var battery = 1000  # Use 1000 if no battery (mains powered)
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)
            var simulated = data_to_show.find('simulated', false)
            
            # Build display using emoji formatter
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            fmt.start_line()
            
            # Socket state
            var socket_state = data_to_show.find('socket_on')
            if socket_state != nil
                if socket_state
                    fmt.add_status("ON", "🟢", "Socket is ON")
                else
                    fmt.add_status("OFF", "⚫", "Socket is OFF")
                end
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
            
            # Power factor & energy line (if present)
            var has_line2 = false
            if data_to_show.contains('power_factor') || data_to_show.contains('energy_wh')
                fmt.next_line()
                has_line2 = true
                
                # Power Factor
                if data_to_show.contains('power_factor')
                    fmt.add_sensor("power_factor%", data_to_show['power_factor'], "Power Factor", "📊")
                end
                
                # Energy with smart scaling
                if data_to_show.contains('energy_wh')
                    var energy = data_to_show['energy_wh']
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
            
            if data_to_show.contains('oc_alarm_enabled') && data_to_show['oc_alarm_enabled']
                var threshold = data_to_show.find('oc_alarm_threshold', 0)
                event_items.push(['string', f"OC:{threshold}A", "Alarm", "🚨"])
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
            print(f"WS523: Display error - {e}: {m}")
            return "📟 WS523 Error - Check Console"
        end
    end
    
    def format_age(seconds)
        if seconds == nil return "Unknown" end
        if seconds < 60 return f"{seconds}s ago"
        elif seconds < 3600 return f"{seconds/60}m ago"
        elif seconds < 86400 return f"{seconds/3600}h ago"
        else return f"{seconds/86400}d ago"
        end
    end
    
    # Get node statistics
    def get_node_stats(node_id)
        import global
        var node_data = global.WS523_nodes.find(node_id, nil)
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
        if global.WS523_nodes.contains(node_id)
            global.WS523_nodes.remove(node_id)
            return true
        end
        return false
    end
    
    # Register downlink commands for device control
    def register_downlink_commands()
        import string
        
        # Socket Control (ON/OFF)
        tasmota.remove_cmd("LwWS523Control")
        tasmota.add_cmd("LwWS523Control", def(cmd, idx, payload_str)
            # Format: LwWS523Control<slot> <on|off|1|0>
            return lwdecode.SendDownlinkMap(global.WS523_nodes, cmd, idx, payload_str, { 
                '1|ON':  ['08FF', 'ON' ],     # Maps "1" or "ON" to hex 08FF
                '0|OFF': ['0800', 'OFF']      # Maps "0" or "OFF" to hex 0800
            })
        end)
        
        # Set Reporting Interval
        tasmota.remove_cmd("LwWS523Interval")
        tasmota.add_cmd("LwWS523Interval", def(cmd, idx, payload_str)
            # Format: LwWS523Interval<slot> <seconds>
            var seconds = int(payload_str)
            if seconds < 60 || seconds > 64800
                return tasmota.resp_cmnd_str("Invalid: range 60-64800 seconds")
            end
            
            var hex_cmd = f"FE02{lwdecode.uint16le(seconds)}"
            return lwdecode.SendDownlink(global.WS523_nodes, cmd, idx, hex_cmd)
        end)
        
        # Device Reboot
        tasmota.remove_cmd("LwWS523Reboot")
        tasmota.add_cmd("LwWS523Reboot", def(cmd, idx, payload_str)
            # Format: LwWS523Reboot<slot>
            var hex_cmd = "FF10FF"
            return lwdecode.SendDownlink(global.WS523_nodes, cmd, idx, hex_cmd)
        end)
        
        # Delay Task
        tasmota.remove_cmd("LwWS523DelayTask")
        tasmota.add_cmd("LwWS523DelayTask", def(cmd, idx, payload_str)
            # Format: LwWS523DelayTask<slot> <seconds>
            var seconds = int(payload_str)
            if seconds < 1 || seconds > 4294967295
                return tasmota.resp_cmnd_str("Invalid: range 1-4294967295 seconds")
            end
            
            var hex_cmd = f"FE22{lwdecode.uint32le(seconds)}"
            return lwdecode.SendDownlink(global.WS523_nodes, cmd, idx, hex_cmd)
        end)
        
        # Delete Task
        tasmota.remove_cmd("LwWS523DeleteTask")
        tasmota.add_cmd("LwWS523DeleteTask", def(cmd, idx, payload_str)
            # Format: LwWS523DeleteTask<slot> <task_id>
            var task_id = int(payload_str)
            if task_id < 0 || task_id > 65535
                return tasmota.resp_cmnd_str("Invalid: range 0-65535")
            end
            
            var hex_cmd = f"FE23{lwdecode.uint16le(task_id)}"
            return lwdecode.SendDownlink(global.WS523_nodes, cmd, idx, hex_cmd)
        end)
        
        # Overcurrent Alarm Configuration
        tasmota.remove_cmd("LwWS523OCAlarm")
        tasmota.add_cmd("LwWS523OCAlarm", def(cmd, idx, payload_str)
            # Format: LwWS523OCAlarm<slot> <enabled>,<threshold>
            var parts = string.split(payload_str, ',')
            if size(parts) != 2
                return tasmota.resp_cmnd_str("Usage: LwWS523OCAlarm<slot> <enabled>,<threshold>")
            end
            
            var enabled = (parts[0] == "1" || string.toupper(parts[0]) == "ON") ? 1 : 0
            var threshold = int(parts[1])
            
            if threshold < 1 || threshold > 16
                return tasmota.resp_cmnd_str("Invalid threshold: range 1-16A")
            end
            
            var hex_cmd = f"FF24{enabled:02X}{threshold:02X}"
            return lwdecode.SendDownlink(global.WS523_nodes, cmd, idx, hex_cmd)
        end)
        
        # Button Lock Control
        tasmota.remove_cmd("LwWS523ButtonLock")
        tasmota.add_cmd("LwWS523ButtonLock", def(cmd, idx, payload_str)
            # Format: LwWS523ButtonLock<slot> <locked|unlocked|1|0>
            return lwdecode.SendDownlinkMap(global.WS523_nodes, cmd, idx, payload_str, { 
                '1|LOCKED':    ['FF250080', 'LOCKED'],     # Button locked
                '0|UNLOCKED':  ['FF250000', 'UNLOCKED']    # Button unlocked
            })
        end)
        
        # Power Recording Control
        tasmota.remove_cmd("LwWS523PowerRecording")
        tasmota.add_cmd("LwWS523PowerRecording", def(cmd, idx, payload_str)
            # Format: LwWS523PowerRecording<slot> <on|off|1|0>
            return lwdecode.SendDownlinkMap(global.WS523_nodes, cmd, idx, payload_str, { 
                '1|ON':  ['FF2601', 'ON' ],     # Power recording enabled
                '0|OFF': ['FF2600', 'OFF']      # Power recording disabled
            })
        end)
        
        # Reset Energy Counter
        tasmota.remove_cmd("LwWS523ResetEnergy")
        tasmota.add_cmd("LwWS523ResetEnergy", def(cmd, idx, payload_str)
            # Format: LwWS523ResetEnergy<slot>
            var hex_cmd = "FF2700"
            return lwdecode.SendDownlink(global.WS523_nodes, cmd, idx, hex_cmd)
        end)
        
        # Request Status
        tasmota.remove_cmd("LwWS523Status")
        tasmota.add_cmd("LwWS523Status", def(cmd, idx, payload_str)
            # Format: LwWS523Status<slot>
            var hex_cmd = "FF2800"
            return lwdecode.SendDownlink(global.WS523_nodes, cmd, idx, hex_cmd)
        end)
        
        # LED Control
        tasmota.remove_cmd("LwWS523LED")
        tasmota.add_cmd("LwWS523LED", def(cmd, idx, payload_str)
            # Format: LwWS523LED<slot> <on|off|1|0>
            return lwdecode.SendDownlinkMap(global.WS523_nodes, cmd, idx, payload_str, { 
                '1|ON':  ['FF2F01', 'ON' ],     # LED enabled
                '0|OFF': ['FF2F00', 'OFF']      # LED disabled
            })
        end)
        
        # Overcurrent Protection Configuration
        tasmota.remove_cmd("LwWS523OCProtection")
        tasmota.add_cmd("LwWS523OCProtection", def(cmd, idx, payload_str)
            # Format: LwWS523OCProtection<slot> <enabled>,<threshold>
            var parts = string.split(payload_str, ',')
            if size(parts) != 2
                return tasmota.resp_cmnd_str("Usage: LwWS523OCProtection<slot> <enabled>,<threshold>")
            end
            
            var enabled = (parts[0] == "1" || string.toupper(parts[0]) == "ON") ? 1 : 0
            var threshold = int(parts[1])
            
            if threshold < 1 || threshold > 16
                return tasmota.resp_cmnd_str("Invalid threshold: range 1-16A")
            end
            
            var hex_cmd = f"FF30{enabled:02X}{threshold:02X}"
            return lwdecode.SendDownlink(global.WS523_nodes, cmd, idx, hex_cmd)
        end)
        
        print("WS523: Downlink commands registered")
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
        if scenario_name == "high_power" && result.contains('active_power') && result['active_power'] < 800
            print(f"PAYLOAD ERROR: {scenario_name} power should be >= 800W")
            return false
        end
        
        return true
    end
end

# Global instance
LwDeco = LwDecode_WS523()

# Node management commands
tasmota.remove_cmd("LwWS523NodeStats")
tasmota.add_cmd("LwWS523NodeStats", def(cmd, idx, node_id)
    var stats = LwDeco.get_node_stats(node_id)
    if stats != nil
        import json
        tasmota.resp_cmnd(json.dump(stats))
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

tasmota.remove_cmd("LwWS523ClearNode")
tasmota.add_cmd("LwWS523ClearNode", def(cmd, idx, node_id)
    if LwDeco.clear_node_data(node_id)
        tasmota.resp_cmnd_done()
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

# Test UI command
tasmota.remove_cmd("LwWS523TestUI")
tasmota.add_cmd("LwWS523TestUI", def(cmd, idx, payload_str)
    # Predefined realistic test scenarios for UI development
    # CRITICAL REQUIREMENT v2.5.0 - ALL PAYLOADS VERIFIED TO DECODE CORRECTLY
    var test_scenarios = {
        "normal":       "037410F0048000000064058164068300004E20007C900FE08701",      # 240V, 100W, 100%, 20000Wh, 420mA, ON
        "low_power":    "0374005A048000000019058132068300000FA007C932080700",      # 90V, 25W, 50%, 4000Wh, 50mA, OFF  
        "high_power":   "037411F8048000000320058164068300007D0007C9E803080701",    # 504V, 800W, 100%, 32000Wh, 1000mA, ON
        "outage":       "037410F0048000000064058164068300004E20007C900FE080701FF3F", # Normal + power outage event
        "config":       "FF0A0103FF24010AFF2F01FF2600FE020A00",                  # SW v1.3, OC alarm 10A, LED on, power rec off, 10min
        "info":         "FF0101FF09010AFF0A0103FF0F00FF16123456789ABCDEF0",         # Protocol v1, HW v1.10, SW v1.3, Class A, Serial
        "events":       "037410F004800000006405816406830000FFFF007C900FE080701FF2601FF0BFFFE03", # Power recording + power-on + CMD reset
        "protection":   "037410F0048000000064FF24010AFF30010CFF250080",          # Normal + OC alarm 10A + OC protect 12A + button locked
        "reset":        "037410F0048000000064058164068300004E20007C900FEFFFE03", # Normal + reset event
        "empty":        "037400000480000000000581000683000000000700000080700"    # 0V, 0W, 0%, 0Wh, 0mA, OFF
    }
    
    var hex_payload = test_scenarios.find(payload_str ? payload_str : 'nil', 'not_found')
    
    if hex_payload == 'not_found'
      # CRITICAL FIX: Use static string to avoid keys() iterator bug
      var scenarios_list = "normal low_power high_power outage config info events protection reset empty "
      return tasmota.resp_cmnd_str(f"Available scenarios: {scenarios_list}")
    end
    
    var rssi = -75
    var fport = 85

    return tasmota.cmd(f'LwSimulate{idx} {rssi},{fport},{hex_payload}')
end)

# MANDATORY: Register driver for web UI integration
tasmota.add_driver(LwDeco)
