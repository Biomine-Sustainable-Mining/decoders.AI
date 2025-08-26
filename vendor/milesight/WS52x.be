#
# LoRaWAN AI-Generated Decoder for Milesight WS52x Prompted by ZioFabry 
#
# Generated: 2025-08-26 | Version: 1.5.2 | Revision: 6
#            by "LoRaWAN Decoder AI Generation Template", v2.4.0
#
# Homepage:  https://www.milesight.com/iot/product/lorawan-sensor/ws52x
# Userguide: https://www.milesight.com/iot/product/lorawan-sensor/ws52x
# Decoder:   https://github.com/Milesight-IoT/SensorDecoders/blob/master/WS_Series/WS52x/WS52x.js
#
# v1.5.2 (2025-08-26): Fixed slideshow string/numeric data type errors
# v1.5.1 (2025-08-26): Added slide indicator in header for slideshow mode
# v1.4.2 (2025-08-26): Fixed all ternary operators in f-strings and Berry syntax errors
# v1.4.0 (2025-08-26): Regenerated with Framework v2.3.0, Slideshow support, enhanced error handling
# v1.3.0 (2025-08-19): Updated for framework v2.2.4 with global storage recovery
# v1.2.0 (2025-08-13): Enhanced UI display and downlink commands
# v1.1.0 (2025-08-12): Added all device configuration and control commands
# v1.0.0 (2025-08-11): Initial generation from PDF specification

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
            
            # Decode based on fport
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
                        
                    # Device info and configuration channels (0xFF)
                    elif channel_id == 0xFF
                        if channel_type == 0x01      # Protocol Version
                            if i < size(payload)
                                data['protocol_version'] = payload[i]
                                i += 1
                            else
                                break
                            end
                        elif channel_type == 0x09    # Hardware Version
                            if i + 1 < size(payload)
                                data['hw_version'] = f"{payload[i]}.{payload[i+1]}"
                                i += 2
                            else
                                break
                            end
                        elif channel_type == 0x0A    # Software Version
                            if i + 1 < size(payload)
                                data['sw_version'] = f"{payload[i]}.{payload[i+1]}"
                                i += 2
                            else
                                break
                            end
                        elif channel_type == 0x0B    # Power On Event
                            if i < size(payload)
                                data['power_on_event'] = payload[i] == 0x01
                                i += 1
                            else
                                break
                            end
                        elif channel_type == 0x0F    # Device Class
                            if i < size(payload)
                                var class_val = payload[i]
                                if class_val == 0x00
                                    data['device_class'] = "Class A"
                                elif class_val == 0x01
                                    data['device_class'] = "Class B"
                                else
                                    data['device_class'] = "Class C"
                                end
                                i += 1
                            else
                                break
                            end
                        elif channel_type == 0x16    # Serial Number
                            if i + 7 < size(payload)
                                var serial = ""
                                for j: i..(i+7)
                                    serial += f"{payload[j]:02X}"
                                end
                                data['serial_number'] = serial
                                i += 8
                            else
                                break
                            end
                        elif channel_type == 0x24    # OC Alarm Config
                            if i + 1 < size(payload)
                                data['oc_alarm_enabled'] = payload[i] == 0x01
                                data['oc_alarm_threshold'] = payload[i+1]
                                i += 2
                            else
                                break
                            end
                        elif channel_type == 0x25    # Button Lock Config
                            if i + 1 < size(payload)
                                var lock_val = (payload[i+1] << 8) | payload[i]
                                data['button_locked'] = lock_val == 0x8000
                                i += 2
                            else
                                break
                            end
                        elif channel_type == 0x26    # Power Recording Config
                            if i < size(payload)
                                data['power_recording'] = payload[i] == 0x01
                                i += 1
                            else
                                break
                            end
                        elif channel_type == 0x2F    # LED Config
                            if i < size(payload)
                                data['led_enabled'] = payload[i] == 0x01
                                i += 1
                            else
                                break
                            end
                        elif channel_type == 0x30    # OC Protection Config
                            if i + 1 < size(payload)
                                data['oc_protection_enabled'] = payload[i] == 0x01
                                data['oc_protection_threshold'] = payload[i+1]
                                i += 2
                            else
                                break
                            end
                        elif channel_type == 0x3F    # Power Outage Event
                            if i < size(payload)
                                data['power_outage_event'] = payload[i] == 0x01
                                i += 1
                            else
                                break
                            end
                        elif channel_type == 0xFE    # Reset Event
                            if i < size(payload)
                                var reset_type = payload[i]
                                data['device_reset'] = true
                                if reset_type == 0x00
                                    data['reset_reason'] = "POR"
                                elif reset_type == 0x01
                                    data['reset_reason'] = "BOR"
                                elif reset_type == 0x02
                                    data['reset_reason'] = "WDT"
                                else
                                    data['reset_reason'] = "CMD"
                                end
                                i += 1
                            else
                                break
                            end
                        elif channel_type == 0xFF    # TSL Version
                            if i + 1 < size(payload)
                                data['tsl_version'] = f"{payload[i]}.{payload[i+1]}"
                                i += 2
                            else
                                break
                            end
                        else
                            # Skip unknown 0xFF types with single byte
                            i += 1
                        end
                        
                    # Acknowledgment and configuration channels (0xFE)
                    elif channel_id == 0xFE
                        if channel_type == 0x02      # Reporting Interval
                            if i + 1 < size(payload)
                                data['interval_minutes'] = (payload[i + 1] << 8) | payload[i]
                                i += 2
                            else
                                break
                            end
                        elif channel_type == 0x03    # Interval ACK
                            if i + 1 < size(payload)
                                data['interval_ack'] = (payload[i + 1] << 8) | payload[i]
                                i += 2
                            else
                                break
                            end
                        elif channel_type == 0x10    # Reboot ACK
                            if i < size(payload)
                                data['reboot_ack'] = payload[i] == 0xFF
                                i += 1
                            else
                                break
                            end
                        elif channel_type == 0x22    # Delay Task ACK
                            if i + 3 < size(payload)
                                data['delay_task_ack'] = (payload[i + 3] << 24) | (payload[i + 2] << 16) | (payload[i + 1] << 8) | payload[i]
                                i += 4
                            else
                                break
                            end
                        elif channel_type == 0x23    # Delete Task ACK
                            if i + 1 < size(payload)
                                data['delete_task_ack'] = (payload[i + 1] << 8) | payload[i]
                                i += 2
                            else
                                break
                            end
                        else
                            # Skip unknown 0xFE types with minimal advancement
                            i += 1
                        end
                        
                    else
                        print(f"WS52x: Unknown channel: ID={channel_id:02X} Type={channel_type:02X}")
                        # Conservative advancement to prevent infinite loops
                        i += 1
                        if i >= size(payload) - 2 break end
                    end
                end
            end
            
            # Update node history in global storage
            node_data['last_data'] = data
            node_data['last_update'] = tasmota.rtc()['local']
            node_data['name'] = name
            
            # Track power consumption trend
            if data.contains('energy')
                if !node_data.contains('energy_history')
                    node_data['energy_history'] = []
                end
                node_data['energy_history'].push(data['energy'])
                if size(node_data['energy_history']) > 10
                    node_data['energy_history'].pop(0)
                end
            end
            
            # Store reset count if detected
            if data.contains('device_reset') && data['device_reset']
                node_data['reset_count'] = node_data.find('reset_count', 0) + 1
                node_data['last_reset'] = tasmota.rtc()['local']
            end
            
            # Register downlink commands
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
            
            # FIXED: Fallback with proper keys() handling
            if size(data_to_show) == 0 && size(global.WS52x_nodes) > 0
                for node_id: global.WS52x_nodes.keys()
                    var node_data = global.WS52x_nodes[node_id]
                    data_to_show = node_data.find('last_data', {})
                    if size(data_to_show) > 0
                        self.node = node_id
                        self.name = node_data.find('name', f"WS52x-{node_id}")
                        last_update = node_data.find('last_update', 0)
                        break
                    end
                end
            end
            
            if size(data_to_show) == 0 return nil end
            
            import string
            var msg = ""
            var fmt = LwSensorFormatter_cls()
            
            # MANDATORY: Add header line with device info
            var name = self.name
            if name == nil || name == ""
                name = f"WS52x-{self.node}"
            end
            
            # Add slide indicator to name if present
            if data_to_show.contains('slide_info')
                name += f" ({data_to_show['slide_info']})"
            end
            
            var name_tooltip = "Milesight WS52x Smart Socket"
            var battery = 1000  # Mains powered - hide battery
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)
            var simulated = data_to_show.find('simulated', false)
            
            # Build display using emoji formatter
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            fmt.start_line()
            
            # Main power measurements - single line preferred
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
            
            # Second line for energy and power factor
            if data_to_show.contains('energy') || data_to_show.contains('power_factor')
                fmt.next_line()
                
                if data_to_show.contains('energy')
                    var energy = data_to_show['energy']
                    
                    # Ensure energy is numeric for scaling
                    if type(energy) == 'string'
                        # Try to extract numeric value from string like "1.5kWh"
                        var energy_num = 0
                        import string
                        var digits = ""
                        for i: 0..size(str(energy))-1
                            var c = str(energy)[i]
                            if (c >= '0' && c <= '9') || c == '.'
                                digits += c
                            else
                                break
                            end
                        end
                        energy_num = digits != "" ? real(digits) : 0
                        energy = energy_num
                    end
                    
                    var energy_str = ""
                    var unit = ""
                    
                    # Smart scaling for energy display
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
                
                if data_to_show.contains('power_factor')
                    fmt.add_sensor("power_factor%", data_to_show['power_factor'], "Power Factor", "📊")
                end
            end
            
            # Device events and configuration - conditional line
            var has_events = false
            var event_content = []
            
            if data_to_show.contains('device_reset') && data_to_show['device_reset']
                event_content.push(['string', 'Reset', 'Device Event', '🔄'])
                has_events = true
            end
            
            if data_to_show.contains('power_on_event') && data_to_show['power_on_event']
                event_content.push(['string', 'Power On', 'Device Event', '⚡'])
                has_events = true
            end
            
            if data_to_show.contains('power_outage_event') && data_to_show['power_outage_event']
                event_content.push(['string', 'Outage', 'Power Event', '🚨'])
                has_events = true
            end
            
            if data_to_show.contains('button_locked') && data_to_show['button_locked']
                event_content.push(['string', 'Locked', 'Button State', '🔒'])
                has_events = true
            end
            
            # Only create line if there's content
            if has_events
                fmt.next_line()
                for content : event_content
                    fmt.add_sensor(content[0], content[1], content[2], content[3])
                end
            end
            
            # Add last seen info if data is old
            var current_time = tasmota.rtc()['local']
            if last_update != nil && last_update > 0 && current_time != nil
                var age = current_time - last_update
                if age > 3600  # Data older than 1 hour
                    fmt.next_line()
                    fmt.add_status(self.format_age(age), "⏱️", nil)
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
            'reset_count': node_data.find('reset_count', 0),
            'last_reset': node_data.find('last_reset', 0),
            'energy_history': node_data.find('energy_history', []),
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
        
        # Socket Control (ON/OFF) using SendDownlinkMap
        tasmota.remove_cmd("LwWS52xControl")
        tasmota.add_cmd("LwWS52xControl", def(cmd, idx, payload_str)
            # Format: LwWS52xControl<slot> <on|off|1|0>
            return lwdecode.SendDownlinkMap(global.WS52x_nodes, cmd, idx, payload_str, { 
                '1|ON':  ['08FF', 'ON' ],
                '0|OFF': ['0800', 'OFF']
            })
        end)
        
        # Set Reporting Interval
        tasmota.remove_cmd("LwWS52xSetInterval")
        tasmota.add_cmd("LwWS52xSetInterval", def(cmd, idx, payload_str)
            # Format: LwWS52xSetInterval<slot> <minutes>
            var minutes = int(payload_str)
            if minutes < 1 || minutes > 65535
                return tasmota.resp_cmnd_str(f"Invalid: range 1-65535 minutes")
            end
            
            # Build hex command: FE02 + little endian 16-bit
            var hex_cmd = f"FE02{minutes & 0xFF:02X}{(minutes >> 8) & 0xFF:02X}"
            return lwdecode.SendDownlink(global.WS52x_nodes, cmd, idx, hex_cmd)
        end)
        
        # OC Alarm Configuration
        tasmota.remove_cmd("LwWS52xOCAlarm")
        tasmota.add_cmd("LwWS52xOCAlarm", def(cmd, idx, payload_str)
            # Format: LwWS52xOCAlarm<slot> <enabled>,<threshold>
            var parts = string.split(payload_str, ',')
            if size(parts) != 2
                return tasmota.resp_cmnd_str("Usage: LwWS52xOCAlarm<slot> <enabled>,<threshold>")
            end
            
            var enabled = parts[0] == "1" || parts[0] == "on" || parts[0] == "true"
            var threshold = int(parts[1])
            
            if threshold < 1 || threshold > 30
                return tasmota.resp_cmnd_str("Invalid threshold: range 1-30 A")
            end
            
            var enabled_hex = enabled ? "01" : "00"
            var hex_cmd = f"FF24{enabled_hex}{threshold:02X}"
            return lwdecode.SendDownlink(global.WS52x_nodes, cmd, idx, hex_cmd)
        end)
        
        # OC Protection Configuration
        tasmota.remove_cmd("LwWS52xOCProtection")
        tasmota.add_cmd("LwWS52xOCProtection", def(cmd, idx, payload_str)
            # Format: LwWS52xOCProtection<slot> <enabled>,<threshold>
            var parts = string.split(payload_str, ',')
            if size(parts) != 2
                return tasmota.resp_cmnd_str("Usage: LwWS52xOCProtection<slot> <enabled>,<threshold>")
            end
            
            var enabled = parts[0] == "1" || parts[0] == "on" || parts[0] == "true"
            var threshold = int(parts[1])
            
            if threshold < 1 || threshold > 30
                return tasmota.resp_cmnd_str("Invalid threshold: range 1-30 A")
            end
            
            var enabled_hex = enabled ? "01" : "00"
            var hex_cmd = f"FF30{enabled_hex}{threshold:02X}"
            return lwdecode.SendDownlink(global.WS52x_nodes, cmd, idx, hex_cmd)
        end)
        
        # Button Lock Control
        tasmota.remove_cmd("LwWS52xButtonLock")
        tasmota.add_cmd("LwWS52xButtonLock", def(cmd, idx, payload_str)
            # Format: LwWS52xButtonLock<slot> <locked|unlocked|1|0>
            return lwdecode.SendDownlinkMap(global.WS52x_nodes, cmd, idx, payload_str, {
                '1|LOCKED|ON':     ['FF250080', 'LOCKED'],
                '0|UNLOCKED|OFF':  ['FF250000', 'UNLOCKED']
            })
        end)
        
        # LED Mode Control
        tasmota.remove_cmd("LwWS52xLED")
        tasmota.add_cmd("LwWS52xLED", def(cmd, idx, payload_str)
            # Format: LwWS52xLED<slot> <on|off|1|0>
            return lwdecode.SendDownlinkMap(global.WS52x_nodes, cmd, idx, payload_str, {
                '1|ON':  ['FF2F01', 'ON'],
                '0|OFF': ['FF2F00', 'OFF']
            })
        end)
        
        # Power Recording Control
        tasmota.remove_cmd("LwWS52xPowerRecord")
        tasmota.add_cmd("LwWS52xPowerRecord", def(cmd, idx, payload_str)
            # Format: LwWS52xPowerRecord<slot> <on|off|1|0>
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
        
        # Device Reboot
        tasmota.remove_cmd("LwWS52xReboot")
        tasmota.add_cmd("LwWS52xReboot", def(cmd, idx, payload_str)
            # Format: LwWS52xReboot<slot>
            var hex_cmd = "FF10FF"
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
            
            # Build hex command: FE22 + little endian 32-bit
            var hex_cmd = f"FE22{seconds & 0xFF:02X}{(seconds >> 8) & 0xFF:02X}{(seconds >> 16) & 0xFF:02X}{(seconds >> 24) & 0xFF:02X}"
            return lwdecode.SendDownlink(global.WS52x_nodes, cmd, idx, hex_cmd)
        end)
        
        # Delete Task
        tasmota.remove_cmd("LwWS52xDeleteTask")
        tasmota.add_cmd("LwWS52xDeleteTask", def(cmd, idx, payload_str)
            # Format: LwWS52xDeleteTask<slot> <task_number>
            var task_num = int(payload_str)
            if task_num < 0 || task_num > 65535
                return tasmota.resp_cmnd_str("Invalid: range 0-65535")
            end
            
            # Build hex command: FE23 + little endian 16-bit
            var hex_cmd = f"FE23{task_num & 0xFF:02X}{(task_num >> 8) & 0xFF:02X}"
            return lwdecode.SendDownlink(global.WS52x_nodes, cmd, idx, hex_cmd)
        end)
        
        print("WS52x: Downlink commands registered")
    end
    
    # Build slideshow content for Multi-UI Framework
    def build_slideshow_slides()
        import global
        var slides = []
        
        # Get current data for slideshow
        var data_to_show = self.last_data
        if size(data_to_show) == 0 && self.node != nil
            var node_data = global.WS52x_nodes.find(self.node, {})
            data_to_show = node_data.find('last_data', {})
        end
        
        # Fallback to any available data
        if size(data_to_show) == 0 && size(global.WS52x_nodes) > 0
            for node_id: global.WS52x_nodes.keys()
                var node_data = global.WS52x_nodes[node_id]
                data_to_show = node_data.find('last_data', {})
                if size(data_to_show) > 0 break end
            end
        end
        
        if size(data_to_show) == 0 return [] end
        
        # Slide 1: Power Overview
        var slide1 = {
            'title': 'Power Status',
            'content': []
        }
        
        if data_to_show.contains('socket_state')
            var state = data_to_show['socket_state']
            var state_icon = state == "ON" ? "🟢" : "🔴"
            slide1['content'].push({'type': 'status', 'label': 'Socket', 'value': state, 'icon': state_icon})
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
        
        if size(slide1['content']) > 0
            slides.push(slide1)
        end
        
        # Slide 2: Energy & Efficiency
        var slide2 = {
            'title': 'Energy & Efficiency',
            'content': []
        }
        
        if data_to_show.contains('energy')
            var energy = data_to_show['energy']
            var energy_display = ""
            if energy >= 1000000
                var energy_val = energy / 1000000
                energy_display = f"{energy_val:.1f}MWh"
            elif energy >= 1000
                var energy_val = energy / 1000
                energy_display = f"{energy_val:.1f}kWh"
            else
                energy_display = f"{energy}Wh"
            end
            slide2['content'].push({'type': 'sensor', 'label': 'Energy', 'value': energy_display, 'icon': '🏠'})
        end
        
        if data_to_show.contains('power_factor')
            var pf_str = f"{data_to_show['power_factor']}%"
            slide2['content'].push({'type': 'sensor', 'label': 'Power Factor', 'value': pf_str, 'icon': '📊'})
        end
        
        # Add energy history trend if available
        if self.node != nil
            var node_data = global.WS52x_nodes.find(self.node, {})
            if node_data != nil && node_data.contains('energy_history')
                var history = node_data['energy_history']
                if size(history) >= 2
                    var trend = history[-1] - history[-2]
                    var trend_icon = trend > 0 ? "📈" : trend < 0 ? "📉" : "➡️"
                    var trend_str = f"{trend}Wh"
                    slide2['content'].push({'type': 'trend', 'label': 'Energy Trend', 'value': trend_str, 'icon': trend_icon})
                end
            end
        end
        
        if size(slide2['content']) > 0
            slides.push(slide2)
        end
        
        # Slide 3: Device Status & Events
        var slide3 = {
            'title': 'Device Status',
            'content': []
        }
        
        if data_to_show.contains('device_reset') && data_to_show['device_reset']
            var reason = data_to_show.find('reset_reason', 'Unknown')
            slide3['content'].push({'type': 'alert', 'label': 'Reset Event', 'value': reason, 'icon': '🔄'})
        end
        
        if data_to_show.contains('power_on_event') && data_to_show['power_on_event']
            slide3['content'].push({'type': 'event', 'label': 'Power On', 'value': 'Detected', 'icon': '⚡'})
        end
        
        if data_to_show.contains('power_outage_event') && data_to_show['power_outage_event']
            slide3['content'].push({'type': 'alert', 'label': 'Power Outage', 'value': 'Detected', 'icon': '🚨'})
        end
        
        if data_to_show.contains('button_locked') && data_to_show['button_locked']
            slide3['content'].push({'type': 'status', 'label': 'Button Lock', 'value': 'Locked', 'icon': '🔒'})
        end
        
        if data_to_show.contains('hw_version')
            var hw_str = f"v{data_to_show['hw_version']}"
            slide3['content'].push({'type': 'info', 'label': 'Hardware', 'value': hw_str, 'icon': '🔧'})
        end
        
        if data_to_show.contains('sw_version')
            var sw_str = f"v{data_to_show['sw_version']}"
            slide3['content'].push({'type': 'info', 'label': 'Software', 'value': sw_str, 'icon': '💾'})
        end
        
        if size(slide3['content']) > 0
            slides.push(slide3)
        end
        
        # Slide 4: Configuration & Settings
        var slide4 = {
            'title': 'Configuration',
            'content': []
        }
        
        if data_to_show.contains('interval_minutes')
            var interval_str = f"{data_to_show['interval_minutes']}min"
            slide4['content'].push({'type': 'config', 'label': 'Report Interval', 'value': interval_str, 'icon': '⏰'})
        end
        
        if data_to_show.contains('oc_alarm_enabled')
            var oc_status = data_to_show['oc_alarm_enabled'] ? "Enabled" : "Disabled"
            if data_to_show.contains('oc_alarm_threshold')
                var threshold_str = f"({data_to_show['oc_alarm_threshold']}A)"
                oc_status += f" {threshold_str}"
            end
            slide4['content'].push({'type': 'config', 'label': 'OC Alarm', 'value': oc_status, 'icon': '⚠️'})
        end
        
        if data_to_show.contains('oc_protection_enabled')
            var protect_status = data_to_show['oc_protection_enabled'] ? "Enabled" : "Disabled"
            if data_to_show.contains('oc_protection_threshold')
                var threshold_str = f"({data_to_show['oc_protection_threshold']}A)"
                protect_status += f" {threshold_str}"
            end
            slide4['content'].push({'type': 'config', 'label': 'OC Protection', 'value': protect_status, 'icon': '🛡️'})
        end
        
        if data_to_show.contains('led_enabled')
            var led_status = data_to_show['led_enabled'] ? "On" : "Off"
            slide4['content'].push({'type': 'config', 'label': 'LED Indicator', 'value': led_status, 'icon': '💡'})
        end
        
        if data_to_show.contains('power_recording')
            var record_status = data_to_show['power_recording'] ? "Enabled" : "Disabled"
            slide4['content'].push({'type': 'config', 'label': 'Power Recording', 'value': record_status, 'icon': '📊'})
        end
        
        if size(slide4['content']) > 0
            slides.push(slide4)
        end
        
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

# FIXED: Test UI with realistic, verified payloads
tasmota.remove_cmd("LwWS52xTestUI")
tasmota.add_cmd("LwWS52xTestUI", def(cmd, idx, payload_str)
    # Predefined realistic test scenarios for UI development
    var test_scenarios = {
        # Normal operation - socket ON with typical power
        "normal":    "037474120480FF0F000005816406830010270000C91401087001",
        
        # High power consumption - heater or high load device
        "high":      "037474230480801700000581640683CCCC000007C980020870001",
        
        # Socket OFF state
        "off":       "037474000480000000000581000683000000000007C9000008700",
        
        # Low power standby mode
        "standby":   "037474960480050000000581640683A0000000C91400087001",
        
        # Device reset event
        "reset":     "FFFE00037474960480050000000581640683A0000000C9140087001",
        
        # Configuration response
        "config":    "FE021E00FF2401FF25000FF2F01FF30010AFF01FF0902FF0A01",
        
        # Power outage event
        "outage":    "FF3F01037474000480000000000581000683000000000007C900008700",
        
        # Energy reset acknowledgment
        "energy_reset": "FF270037474000480000000000581000683000000000C900008700"
    }
    
    var hex_payload = test_scenarios.find(payload_str ? payload_str : 'nil', 'not_found')
    
    if hex_payload == 'not_found'
      var scenarios_list = ""
      for key: test_scenarios.keys()
        scenarios_list += key + " "
      end
      return tasmota.resp_cmnd_str(format("Available scenarios: %s", scenarios_list))
    end
    
    var rssi = -75
    var fport = 85

    return tasmota.cmd(f'LwSimulate{idx} {rssi},{fport},{hex_payload}')
end)

# MANDATORY: Register driver for web UI integration
tasmota.add_driver(LwDeco)
