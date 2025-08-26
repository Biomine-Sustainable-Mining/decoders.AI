#
# LoRaWAN AI-Generated Decoder for Milesight AM308L Prompted by ZioFabry 
#
# Generated: 2025-08-26 | Version: 1.0.0 | Revision: 1
#            by "LoRaWAN Decoder AI Generation Template", v2.3.6
#
# Homepage:  https://www.milesight.com/iot/product/lorawan-sensor/am319
# Userguide: https://github.com/Milesight-IoT/SensorDecoders/tree/main/am-series/am308l
# Decoder:   https://github.com/Milesight-IoT/SensorDecoders/blob/main/am-series/am308l/am308l-decoder.js
# 
# Changelog:
# v1.0.0 (2025-08-26): Initial generation from Milesight repository

class LwDecode_AM308L
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
            var node_data = global.AM308L_nodes.find(node, {})
            
            # Channel-based decoding (Milesight standard format)
            var i = 0
            while i < size(payload)
                var channel_id = payload[i]
                var channel_type = payload[i + 1]
                i += 2
                
                # IPSO VERSION
                if channel_id == 0xFF && channel_type == 0x01
                    var version_byte = payload[i]
                    var major = (version_byte & 0xF0) >> 4
                    var minor = version_byte & 0x0F
                    data['ipso_version'] = f"v{major}.{minor}"
                    i += 1
                    
                # HARDWARE VERSION
                elif channel_id == 0xFF && channel_type == 0x09
                    var major = payload[i] & 0xFF
                    var minor = (payload[i + 1] & 0xFF) >> 4
                    data['hardware_version'] = f"v{major}.{minor}"
                    i += 2
                    
                # FIRMWARE VERSION
                elif channel_id == 0xFF && channel_type == 0x0A
                    var major = payload[i] & 0xFF
                    var minor = payload[i + 1] & 0xFF
                    data['firmware_version'] = f"v{major}.{minor}"
                    i += 2
                    
                # TSL VERSION
                elif channel_id == 0xFF && channel_type == 0xFF
                    var major = payload[i] & 0xFF
                    var minor = payload[i + 1] & 0xFF
                    data['tsl_version'] = f"v{major}.{minor}"
                    i += 2
                    
                # DEVICE STATUS
                elif channel_id == 0xFF && channel_type == 0x0B
                    var status_val = payload[i]
                    data['device_status'] = (status_val == 1) ? "on" : "off"
                    i += 1
                    
                # LORAWAN CLASS
                elif channel_id == 0xFF && channel_type == 0x0F
                    var class_map = {0: "Class A", 1: "Class B", 2: "Class C", 3: "Class CtoB"}
                    data['lorawan_class'] = class_map.find(payload[i], "unknown")
                    i += 1
                    
                # SERIAL NUMBER
                elif channel_id == 0xFF && channel_type == 0x16
                    var sn_parts = []
                    for j: 0..7
                        sn_parts.push(string.format("%02X", payload[i + j]))
                    end
                    data['serial_number'] = string.join(sn_parts, "")
                    i += 8
                    
                # RESET EVENT
                elif channel_id == 0xFF && channel_type == 0xFE
                    data['device_reset'] = true
                    data['reset_event'] = payload[i]
                    i += 1
                    
                # BATTERY
                elif channel_id == 0x01 && channel_type == 0x75
                    data['battery'] = payload[i]
                    data['battery_v'] = payload[i] / 100.0 * 4.2  # Convert % to voltage estimate
                    i += 1
                    
                # TEMPERATURE
                elif channel_id == 0x03 && channel_type == 0x67
                    var temp_raw = (payload[i + 1] << 8) | payload[i]
                    if temp_raw > 32767
                        temp_raw = temp_raw - 65536
                    end
                    data['temperature'] = temp_raw / 10.0
                    i += 2
                    
                # HUMIDITY
                elif channel_id == 0x04 && channel_type == 0x68
                    data['humidity'] = payload[i] / 2.0
                    i += 1
                    
                # PIR MOTION
                elif channel_id == 0x05 && channel_type == 0x00
                    data['pir'] = (payload[i] == 1) ? "trigger" : "idle"
                    data['motion_detected'] = payload[i] == 1
                    i += 1
                    
                # LIGHT LEVEL
                elif channel_id == 0x06 && channel_type == 0xCB
                    data['light_level'] = payload[i]
                    i += 1
                    
                # CO2
                elif channel_id == 0x07 && channel_type == 0x7D
                    data['co2'] = (payload[i + 1] << 8) | payload[i]
                    i += 2
                    
                # TVOC (IAQ)
                elif channel_id == 0x08 && channel_type == 0x7D
                    data['tvoc'] = ((payload[i + 1] << 8) | payload[i]) / 100.0
                    data['tvoc_unit'] = "iaq"
                    i += 2
                    
                # TVOC (µg/m³)
                elif channel_id == 0x08 && channel_type == 0xE6
                    data['tvoc'] = (payload[i + 1] << 8) | payload[i]
                    data['tvoc_unit'] = "µg/m³"
                    i += 2
                    
                # PRESSURE
                elif channel_id == 0x09 && channel_type == 0x73
                    data['pressure'] = ((payload[i + 1] << 8) | payload[i]) / 10.0
                    i += 2
                    
                # PM2.5
                elif channel_id == 0x0B && channel_type == 0x7D
                    data['pm2_5'] = (payload[i + 1] << 8) | payload[i]
                    i += 2
                    
                # PM10
                elif channel_id == 0x0C && channel_type == 0x7D
                    data['pm10'] = (payload[i + 1] << 8) | payload[i]
                    i += 2
                    
                # BUZZER STATUS
                elif channel_id == 0x0E && channel_type == 0x01
                    data['buzzer_status'] = (payload[i] == 1) ? "on" : "off"
                    i += 1
                    
                # HISTORY DATA (IAQ)
                elif channel_id == 0x20 && channel_type == 0xCE
                    var hist = {}
                    hist['timestamp'] = (payload[i + 3] << 24) | (payload[i + 2] << 16) | (payload[i + 1] << 8) | payload[i]
                    var temp_raw = (payload[i + 5] << 8) | payload[i + 4]
                    if temp_raw > 32767
                        temp_raw = temp_raw - 65536
                    end
                    hist['temperature'] = temp_raw / 10.0
                    hist['humidity'] = ((payload[i + 7] << 8) | payload[i + 6]) / 2.0
                    hist['pir'] = (payload[i + 8] == 1) ? "trigger" : "idle"
                    hist['light_level'] = payload[i + 9]
                    hist['co2'] = (payload[i + 11] << 8) | payload[i + 10]
                    hist['tvoc'] = ((payload[i + 13] << 8) | payload[i + 12]) / 100.0
                    hist['pressure'] = ((payload[i + 15] << 8) | payload[i + 14]) / 10.0
                    hist['pm2_5'] = (payload[i + 17] << 8) | payload[i + 16]
                    hist['pm10'] = (payload[i + 19] << 8) | payload[i + 18]
                    
                    if !data.contains('history')
                        data['history'] = []
                    end
                    data['history'].push(hist)
                    i += 20
                    
                # HISTORY DATA (µg/m³)
                elif channel_id == 0x21 && channel_type == 0xCE
                    var hist = {}
                    hist['timestamp'] = (payload[i + 3] << 24) | (payload[i + 2] << 16) | (payload[i + 1] << 8) | payload[i]
                    var temp_raw = (payload[i + 5] << 8) | payload[i + 4]
                    if temp_raw > 32767
                        temp_raw = temp_raw - 65536
                    end
                    hist['temperature'] = temp_raw / 10.0
                    hist['humidity'] = ((payload[i + 7] << 8) | payload[i + 6]) / 2.0
                    hist['pir'] = (payload[i + 8] == 1) ? "trigger" : "idle"
                    hist['light_level'] = payload[i + 9]
                    hist['co2'] = (payload[i + 11] << 8) | payload[i + 10]
                    hist['tvoc'] = (payload[i + 13] << 8) | payload[i + 12]  # µg/m³ unit
                    hist['pressure'] = ((payload[i + 15] << 8) | payload[i + 14]) / 10.0
                    hist['pm2_5'] = (payload[i + 17] << 8) | payload[i + 16]
                    hist['pm10'] = (payload[i + 19] << 8) | payload[i + 18]
                    
                    if !data.contains('history')
                        data['history'] = []
                    end
                    data['history'].push(hist)
                    i += 20
                    
                # DOWNLINK RESPONSES
                elif channel_id == 0xFE || channel_id == 0xFF
                    var result = self.handle_downlink_response(channel_type, payload, i)
                    for key: result['data'].keys()
                        data[key] = result['data'][key]
                    end
                    i = result['offset']
                    
                else
                    print(f"AM308L: Unknown channel ID={channel_id:02X} Type={channel_type:02X}")
                    break
                end
            end
            
            # Update node history in global storage
            node_data['last_data'] = data
            node_data['last_update'] = tasmota.rtc()['local']
            node_data['name'] = name
            
            # Store battery trend if available
            if data.contains('battery')
                if !node_data.contains('battery_history')
                    node_data['battery_history'] = []
                end
                node_data['battery_history'].push(data['battery'])
                if size(node_data['battery_history']) > 10
                    node_data['battery_history'].pop(0)
                end
            end
            
            # Store reset count if detected
            if data.contains('device_reset') && data['device_reset']
                node_data['reset_count'] = node_data.find('reset_count', 0) + 1
                node_data['last_reset'] = tasmota.rtc()['local']
            end
            
            # Register downlink commands
            if !global.contains("AM308L_cmdInit") || !global.AM308L_cmdInit
                self.register_downlink_commands()
                global.AM308L_cmdInit = true
            end

            # Save back to global storage
            global.AM308L_nodes[node] = node_data
            
            # Update instance cache
            self.last_data = data
            self.last_update = node_data['last_update']
            
            return data
            
        except .. as e, m
            print(f"AM308L: Decode error - {e}: {m}")
            return nil
        end
    end
    
    def handle_downlink_response(channel_type, payload, offset)
        var decoded = {}
        
        if channel_type == 0x03  # Report interval
            decoded['report_interval'] = (payload[offset + 1] << 8) | payload[offset]
            offset += 2
        elif channel_type == 0x10  # Reboot response
            decoded['reboot'] = "yes"
            offset += 1
        elif channel_type == 0x17  # Time zone
            var zone_raw = (payload[offset + 1] << 8) | payload[offset]
            if zone_raw > 32767
                zone_raw = zone_raw - 65536
            end
            var timezone_map = {-120: "UTC-12", -110: "UTC-11", -100: "UTC-10", -90: "UTC-9", -80: "UTC-8", -70: "UTC-7", -60: "UTC-6", -50: "UTC-5", -40: "UTC-4", -30: "UTC-3", -20: "UTC-2", -10: "UTC-1", 0: "UTC", 10: "UTC+1", 20: "UTC+2", 30: "UTC+3", 40: "UTC+4", 50: "UTC+5", 60: "UTC+6", 70: "UTC+7", 80: "UTC+8", 90: "UTC+9", 100: "UTC+10", 110: "UTC+11", 120: "UTC+12"}
            decoded['time_zone'] = timezone_map.find(zone_raw, f"UTC{zone_raw > 0 ? '+' : ''}{zone_raw/10}")
            offset += 2
        elif channel_type == 0x1A  # CO2 calibration settings
            var mode_val = payload[offset]
            var calibration_mode_map = {0: "factory", 1: "abc", 2: "manual", 3: "background", 4: "zero"}
            decoded['co2_calibration_settings'] = {}
            decoded['co2_calibration_settings']['mode'] = calibration_mode_map.find(mode_val, "unknown")
            if mode_val == 2
                decoded['co2_calibration_settings']['calibration_value'] = (payload[offset + 2] << 8) | payload[offset + 1]
                offset += 3
            else
                offset += 1
            end
        elif channel_type == 0x25  # Child lock settings
            var buttons_val = payload[offset]
            decoded['child_lock_settings'] = {}
            decoded['child_lock_settings']['off_button'] = ((buttons_val & 0x01) != 0) ? "enable" : "disable"
            decoded['child_lock_settings']['on_button'] = ((buttons_val & 0x02) != 0) ? "enable" : "disable"
            decoded['child_lock_settings']['collection_button'] = ((buttons_val & 0x04) != 0) ? "enable" : "disable"
            offset += 1
        elif channel_type == 0x27  # Clear history
            decoded['clear_history'] = "yes"
            offset += 1
        elif channel_type == 0x2C  # Query status
            decoded['query_status'] = "yes"
            offset += 1
        elif channel_type == 0x2E  # LED indicator mode
            var led_mode_map = {0: "off", 1: "on", 2: "blink"}
            decoded['led_indicator_mode'] = led_mode_map.find(payload[offset], "unknown")
            offset += 1
        elif channel_type == 0xEB  # TVOC unit
            var tvoc_unit_map = {0: "iaq", 1: "µg/m³"}
            decoded['tvoc_unit'] = tvoc_unit_map.find(payload[offset], "unknown")
            offset += 1
        elif channel_type == 0x39  # CO2 ABC calibration enable
            decoded['co2_abc_calibration_enable'] = (payload[offset] == 1) ? "enable" : "disable"
            offset += 5  # Skip 4 bytes as per spec
        elif channel_type == 0x3A  # Report interval (alt)
            decoded['report_interval'] = (payload[offset + 1] << 8) | payload[offset]
            offset += 2
        elif channel_type == 0x3B  # Time sync enable
            decoded['time_sync_enable'] = (payload[offset] == 2) ? "enable" : "disable"
            offset += 1
        elif channel_type == 0x3D  # Stop buzzer
            decoded['stop_buzzer'] = "yes"
            offset += 1
        elif channel_type == 0x3E  # Buzzer enable
            decoded['buzzer_enable'] = (payload[offset] == 1) ? "enable" : "disable"
            offset += 1
        elif channel_type == 0x65  # PM2.5 collection interval
            decoded['pm2_5_collection_interval'] = (payload[offset + 1] << 8) | payload[offset]
            offset += 2
        elif channel_type == 0x68  # History enable
            decoded['history_enable'] = (payload[offset] == 1) ? "enable" : "disable"
            offset += 1
        elif channel_type == 0x69  # Retransmit enable
            decoded['retransmit_enable'] = (payload[offset] == 1) ? "enable" : "disable"
            offset += 1
        elif channel_type == 0x6A  # Retransmit/resend interval
            var interval_type = payload[offset]
            if interval_type == 0
                decoded['retransmit_interval'] = (payload[offset + 2] << 8) | payload[offset + 1]
            elif interval_type == 1
                decoded['resend_interval'] = (payload[offset + 2] << 8) | payload[offset + 1]
            end
            offset += 3
        elif channel_type == 0x6D  # Stop transmit
            decoded['stop_transmit'] = "yes"
            offset += 1
        elif channel_type == 0xF4  # CO2 calibration enable
            decoded['co2_calibration_enable'] = (payload[offset] == 1) ? "enable" : "disable"
            offset += 1
        else
            print(f"AM308L: Unknown downlink response type: {channel_type:02X}")
            offset += 1
        end
        
        return {'data': decoded, 'offset': offset}
    end
    
    def add_web_sensor()
        import global
        
        try
            # Try to use current instance data first
            var data_to_show = self.last_data
            var last_update = self.last_update
            
            # If no instance data, try to recover from global storage
            if size(data_to_show) == 0 && self.node != nil
                var node_data = global.AM308L_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            # Fallback: find ANY stored node if no specific node
            if size(data_to_show) == 0 && size(global.AM308L_nodes) > 0
                for node_id: global.AM308L_nodes.keys()
                    var node_data = global.AM308L_nodes[node_id]
                    data_to_show = node_data.find('last_data', {})
                    self.node = node_id
                    self.name = node_data.find('name', f"AM308L-{node_id}")
                    last_update = node_data.find('last_update', 0)
                    break
                end
            end
            
            if size(data_to_show) == 0 return nil end
            
            import string
            var msg = ""
            var fmt = LwSensorFormatter_cls()
            
            # MANDATORY: Add header line with device info
            var name = self.name
            if name == nil || name == ""
                name = f"AM308L-{self.node}"
            end
            var name_tooltip = "Milesight AM308L"
            var battery = data_to_show.find('battery_v', 1000)  # Use 1000 if no battery
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)
            var simulated = data_to_show.find('simulated', false)
            
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            
            # Main sensor data line
            fmt.start_line()
            
            if data_to_show.contains('temperature')
                fmt.add_sensor("temp", data_to_show['temperature'], "Temperature", "🌡️")
            end
            
            if data_to_show.contains('humidity')
                fmt.add_sensor("humidity", data_to_show['humidity'], "Humidity", "💧")
            end
            
            if data_to_show.contains('co2')
                fmt.add_sensor("co2", data_to_show['co2'], "CO2", "💨")
            end
            
            if data_to_show.contains('tvoc') && data_to_show['tvoc'] > 0
                var tvoc_emoji = data_to_show.find('tvoc_unit', 'iaq') == 'iaq' ? "🌿" : "💨"
                var tvoc_tooltip = data_to_show.find('tvoc_unit', 'iaq') == 'iaq' ? "TVOC IAQ" : "TVOC µg/m³"
                fmt.add_sensor("string", f"{data_to_show['tvoc']}", tvoc_tooltip, tvoc_emoji)
            end
            
            # Air quality line
            fmt.next_line()
            
            if data_to_show.contains('pm2_5') && data_to_show['pm2_5'] > 0
                fmt.add_sensor("pm25", data_to_show['pm2_5'], "PM2.5", "🫧")
            end
            
            if data_to_show.contains('pm10') && data_to_show['pm10'] > 0
                fmt.add_sensor("pm10", data_to_show['pm10'], "PM10", "🌫️")
            end
            
            if data_to_show.contains('pressure')
                fmt.add_sensor("pressure", data_to_show['pressure'], "Pressure", "🔵")
            end
            
            if data_to_show.contains('light_level')
                fmt.add_sensor("string", f"{data_to_show['light_level']}", "Light", "💡")
            end
            
            # Status and events line
            var has_status = false
            
            if data_to_show.contains('pir') && data_to_show['pir'] == "trigger"
                fmt.next_line()
                fmt.add_sensor("string", "Motion", "PIR Detected", "🚶")
                has_status = true
            end
            
            if data_to_show.contains('buzzer_status') && data_to_show['buzzer_status'] == "on"
                if !has_status
                    fmt.next_line()
                    has_status = true
                end
                fmt.add_sensor("string", "Buzzer", "Buzzer Active", "🔔")
            end
            
            if data_to_show.contains('device_reset') && data_to_show['device_reset']
                if !has_status
                    fmt.next_line()
                    has_status = true
                end
                fmt.add_sensor("string", "Reset", "Device Reset", "🔄")
            end
            
            # Device info line (only if present)
            var has_info = false
            
            if data_to_show.contains('firmware_version') || data_to_show.contains('device_status')
                fmt.next_line()
                has_info = true
                
                if data_to_show.contains('firmware_version')
                    fmt.add_sensor("string", data_to_show['firmware_version'], "Firmware", "📋")
                end
                
                if data_to_show.contains('device_status')
                    var status_emoji = data_to_show['device_status'] == "on" ? "✅" : "❌"
                    fmt.add_sensor("string", data_to_show['device_status'], "Status", status_emoji)
                end
            end
            
            fmt.end_line()
            
            # Add last seen info if data is old
            if last_update > 0
                var age = tasmota.rtc()['local'] - last_update
                if age > 3600  # Data older than 1 hour
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
    
    # Get node statistics
    def get_node_stats(node_id)
        import global
        var node_data = global.AM308L_nodes.find(node_id, nil)
        if node_data == nil return nil end
        
        return {
            'last_update': node_data.find('last_update', 0),
            'reset_count': node_data.find('reset_count', 0),
            'last_reset': node_data.find('last_reset', 0),
            'battery_history': node_data.find('battery_history', []),
            'name': node_data.find('name', 'Unknown')
        }
    end
    
    # Clear node data (for maintenance)
    def clear_node_data(node_id)
        import global
        if global.AM308L_nodes.contains(node_id)
            global.AM308L_nodes.remove(node_id)
            return true
        end
        return false
    end
    
    # Register downlink commands for device control
    def register_downlink_commands()
        import string
        
        # Device Reboot
        tasmota.remove_cmd("LwAM308LReboot")
        tasmota.add_cmd("LwAM308LReboot", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.AM308L_nodes, cmd, idx, "FF10FF")
        end)
        
        # Stop Buzzer
        tasmota.remove_cmd("LwAM308LStopBuzzer")
        tasmota.add_cmd("LwAM308LStopBuzzer", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.AM308L_nodes, cmd, idx, "FF3D00")
        end)
        
        # Query Status
        tasmota.remove_cmd("LwAM308LQueryStatus")
        tasmota.add_cmd("LwAM308LQueryStatus", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.AM308L_nodes, cmd, idx, "FF2C00")
        end)
        
        # Report Interval
        tasmota.remove_cmd("LwAM308LReportInterval")
        tasmota.add_cmd("LwAM308LReportInterval", def(cmd, idx, payload_str)
            var interval = int(payload_str)
            if interval < 10 || interval > 86400
                return tasmota.resp_cmnd_str("Invalid: range 10-86400 seconds")
            end
            var hex_cmd = f"FF03{lwdecode.uint16le(interval)}"
            return lwdecode.SendDownlink(global.AM308L_nodes, cmd, idx, hex_cmd)
        end)
        
        # Time Sync Enable
        tasmota.remove_cmd("LwAM308LTimeSync")
        tasmota.add_cmd("LwAM308LTimeSync", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.AM308L_nodes, cmd, idx, payload_str, {
                'enable|1|2': ['FF3B02', 'Enable'],
                'disable|0': ['FF3B00', 'Disable']
            })
        end)
        
        # Time Zone
        tasmota.remove_cmd("LwAM308LTimeZone")
        tasmota.add_cmd("LwAM308LTimeZone", def(cmd, idx, payload_str)
            var zone = int(payload_str)
            if zone < -120 || zone > 140
                return tasmota.resp_cmnd_str("Invalid: range -120 to 140 (UTC offset * 10)")
            end
            var hex_cmd = f"FF17{lwdecode.int16le(zone)}"
            return lwdecode.SendDownlink(global.AM308L_nodes, cmd, idx, hex_cmd)
        end)
        
        # TVOC Unit
        tasmota.remove_cmd("LwAM308LTVOCUnit")
        tasmota.add_cmd("LwAM308LTVOCUnit", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.AM308L_nodes, cmd, idx, payload_str, {
                'iaq|0': ['FFEB00', 'IAQ'],
                'ugm3|1': ['FFEB01', 'µg/m³']
            })
        end)
        
        # PM2.5 Collection Interval
        tasmota.remove_cmd("LwAM308LPM25Interval")
        tasmota.add_cmd("LwAM308LPM25Interval", def(cmd, idx, payload_str)
            var interval = int(payload_str)
            if interval < 60 || interval > 86400
                return tasmota.resp_cmnd_str("Invalid: range 60-86400 seconds")
            end
            var hex_cmd = f"FF65{lwdecode.uint16le(interval)}"
            return lwdecode.SendDownlink(global.AM308L_nodes, cmd, idx, hex_cmd)
        end)
        
        # CO2 ABC Calibration Enable
        tasmota.remove_cmd("LwAM308LCO2ABC")
        tasmota.add_cmd("LwAM308LCO2ABC", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.AM308L_nodes, cmd, idx, payload_str, {
                'enable|1': ['FF390100000000', 'Enable'],
                'disable|0': ['FF390000000000', 'Disable']
            })
        end)
        
        # CO2 Calibration Enable
        tasmota.remove_cmd("LwAM308LCO2Calibration")
        tasmota.add_cmd("LwAM308LCO2Calibration", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.AM308L_nodes, cmd, idx, payload_str, {
                'enable|1': ['FFF401', 'Enable'],
                'disable|0': ['FFF400', 'Disable']
            })
        end)
        
        # CO2 Calibration Settings
        tasmota.remove_cmd("LwAM308LCO2CalibrationSettings")
        tasmota.add_cmd("LwAM308LCO2CalibrationSettings", def(cmd, idx, payload_str)
            var parts = string.split(payload_str, ',')
            var mode = int(parts[0])
            
            if mode < 0 || mode > 4
                return tasmota.resp_cmnd_str("Invalid mode: 0=factory, 1=abc, 2=manual, 3=background, 4=zero")
            end
            
            if mode == 2  # Manual mode requires calibration value
                if size(parts) != 2
                    return tasmota.resp_cmnd_str("Manual mode requires: mode,value")
                end
                var value = int(parts[1])
                if value < 400 || value > 5000
                    return tasmota.resp_cmnd_str("Invalid CO2 value: range 400-5000 ppm")
                end
                var hex_cmd = f"FF1A{mode:02X}{lwdecode.uint16le(value)}"
                return lwdecode.SendDownlink(global.AM308L_nodes, cmd, idx, hex_cmd)
            else
                var hex_cmd = f"FF1A{mode:02X}"
                return lwdecode.SendDownlink(global.AM308L_nodes, cmd, idx, hex_cmd)
            end
        end)
        
        # Buzzer Enable
        tasmota.remove_cmd("LwAM308LBuzzer")
        tasmota.add_cmd("LwAM308LBuzzer", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.AM308L_nodes, cmd, idx, payload_str, {
                'enable|1|on': ['FF3E01', 'Enable'],
                'disable|0|off': ['FF3E00', 'Disable']
            })
        end)
        
        # LED Indicator Mode
        tasmota.remove_cmd("LwAM308LLED")
        tasmota.add_cmd("LwAM308LLED", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.AM308L_nodes, cmd, idx, payload_str, {
                'off|0': ['FF2E00', 'Off'],
                'on|1': ['FF2E01', 'On'],
                'blink|2': ['FF2E02', 'Blink']
            })
        end)
        
        # Child Lock Settings
        tasmota.remove_cmd("LwAM308LChildLock")
        tasmota.add_cmd("LwAM308LChildLock", def(cmd, idx, payload_str)
            var parts = string.split(payload_str, ',')
            if size(parts) != 3
                return tasmota.resp_cmnd_str("Usage: off_button,on_button,collection_button (0/1 each)")
            end
            
            var off_button = int(parts[0])
            var on_button = int(parts[1])
            var collection_button = int(parts[2])
            
            if off_button < 0 || off_button > 1 || on_button < 0 || on_button > 1 || collection_button < 0 || collection_button > 1
                return tasmota.resp_cmnd_str("Invalid values: use 0 (disable) or 1 (enable)")
            end
            
            var buttons_val = off_button | (on_button << 1) | (collection_button << 2)
            var hex_cmd = f"FF25{buttons_val:02X}"
            return lwdecode.SendDownlink(global.AM308L_nodes, cmd, idx, hex_cmd)
        end)
        
        # Retransmit Enable
        tasmota.remove_cmd("LwAM308LRetransmit")
        tasmota.add_cmd("LwAM308LRetransmit", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.AM308L_nodes, cmd, idx, payload_str, {
                'enable|1': ['FF6901', 'Enable'],
                'disable|0': ['FF6900', 'Disable']
            })
        end)
        
        # Retransmit Interval
        tasmota.remove_cmd("LwAM308LRetransmitInterval")
        tasmota.add_cmd("LwAM308LRetransmitInterval", def(cmd, idx, payload_str)
            var interval = int(payload_str)
            if interval < 1 || interval > 64800
                return tasmota.resp_cmnd_str("Invalid: range 1-64800 seconds")
            end
            var hex_cmd = f"FF6A00{lwdecode.uint16le(interval)}"
            return lwdecode.SendDownlink(global.AM308L_nodes, cmd, idx, hex_cmd)
        end)
        
        # Resend Interval
        tasmota.remove_cmd("LwAM308LResendInterval")
        tasmota.add_cmd("LwAM308LResendInterval", def(cmd, idx, payload_str)
            var interval = int(payload_str)
            if interval < 1 || interval > 64800
                return tasmota.resp_cmnd_str("Invalid: range 1-64800 seconds")
            end
            var hex_cmd = f"FF6A01{lwdecode.uint16le(interval)}"
            return lwdecode.SendDownlink(global.AM308L_nodes, cmd, idx, hex_cmd)
        end)
        
        # History Enable
        tasmota.remove_cmd("LwAM308LHistory")
        tasmota.add_cmd("LwAM308LHistory", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.AM308L_nodes, cmd, idx, payload_str, {
                'enable|1': ['FF6801', 'Enable'],
                'disable|0': ['FF6800', 'Disable']
            })
        end)
        
        # Fetch History
        tasmota.remove_cmd("LwAM308LFetchHistory")
        tasmota.add_cmd("LwAM308LFetchHistory", def(cmd, idx, payload_str)
            var parts = string.split(payload_str, ',')
            var start_time = int(parts[0])
            
            if size(parts) == 1
                # Single start time
                var hex_cmd = f"FD6B{lwdecode.uint32le(start_time)}"
                return lwdecode.SendDownlink(global.AM308L_nodes, cmd, idx, hex_cmd)
            elif size(parts) == 2
                # Start and end time
                var end_time = int(parts[1])
                if start_time >= end_time
                    return tasmota.resp_cmnd_str("Start time must be less than end time")
                end
                var hex_cmd = f"FD6C{lwdecode.uint32le(start_time)}{lwdecode.uint32le(end_time)}"
                return lwdecode.SendDownlink(global.AM308L_nodes, cmd, idx, hex_cmd)
            else
                return tasmota.resp_cmnd_str("Usage: start_time or start_time,end_time")
            end
        end)
        
        # Stop Transmit
        tasmota.remove_cmd("LwAM308LStopTransmit")
        tasmota.add_cmd("LwAM308LStopTransmit", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.AM308L_nodes, cmd, idx, "FD6DFF")
        end)
        
        # Clear History
        tasmota.remove_cmd("LwAM308LClearHistory")
        tasmota.add_cmd("LwAM308LClearHistory", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.AM308L_nodes, cmd, idx, "FF2701")
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

# Test UI command
tasmota.remove_cmd("LwAM308LTestUI")
tasmota.add_cmd("LwAM308LTestUI", def(cmd, idx, payload_str)
    var test_scenarios = {
        "normal":    "03670A0104685805000106CB01077DFF02087DE3000973FE270B7D07000C7D0800",
        "alert":     "03671A0504687F050001077DE007087DE30109734527",
        "high":      "036719050468B405000107E9070882710D097310270B7D19000C7D2000",
        "motion":    "03670B010468650500010CB02077D8803087D2701",
        "history":   "20CE1234567889AB140050020100A8032500FE27070008000800",
        "config":    "FF010AFF090110FF0A0110FF16010203040506070801758CFF0B01"
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
