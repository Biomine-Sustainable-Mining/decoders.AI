#
# LoRaWAN AI-Generated Decoder for Milesight AM300 Prompted by ZioFabry 
#
# Generated: 2025-09-02 | Version: 1.3.0 | Revision: 7
#            by "LoRaWAN Decoder AI Generation Template", v2.4.1
#
# Homepage:  https://www.milesight-iot.com/lorawan/sensor/am300/
# Userguide: https://resource.milesight-iot.com/milesight/iot/document/am300-user-guide.pdf
# Decoder:   https://github.com/Milesight-IoT/SensorDecoders/tree/master/AM_Series
# 
# Changelog:
# v1.3.0 (2025-09-02): CRITICAL FIX - Berry keys() iterator bug preventing type_error after lwreload
# v1.2.4 (2025-08-26): Fixed device info scenario decoding
#   - Fixed index out of range error in device info parsing
#   - Extended info payload to proper 12-byte format (FF0B + 10 data bytes)
#   - Added dedicated device info display with firmware, hardware, protocol, serial
#   - Info scenario now shows: FW 1.2.3, HW 4.5, Protocol 6, SN 0708090A
# v1.2.3 (2025-08-26): Rebuilt ALL test scenario payloads
#   - Reconstructed all 8 test scenarios with proper multi-channel structure
#   - Fixed temperature calculations for all scenarios (no more negative temps)
#   - Added realistic air quality progression: good->normal->moderate->poor->alert
#   - Enhanced buzzer_on scenario with actual buzzer and activity events
#   - All scenarios now decode correctly with full sensor data
# v1.2.2 (2025-08-26): Fixed moderate test scenario payload
#   - Reconstructed proper moderate air quality test payload
#   - Temperature 22.5°C, CO2 800ppm, TVOC 120, Pressure 1015.5hPa
#   - All sensors now display correctly in moderate scenario
# v1.2.1 (2025-08-26): Fixed light level channel type handling
#   - Added support for light level channel type 0x10 (alternative format)
#   - Updated MAP documentation to include both 0xcb and 0x10 formats
#   - Fixed "moderate" test scenario decoding issue
# v1.2.0 (2025-08-26): Regenerated with framework v2.2.9 + template v2.3.6
#   - Updated to latest framework error handling patterns
#   - Enhanced global storage with battery trend tracking
#   - Added comprehensive test scenarios with realistic payloads
#   - Improved air quality sensor display with proper emojis
#   - Added buzzer and screen control downlinks
#   - Updated emoji usage: 🌬️ CO2, 🏭 TVOC, 🌫️ PM2.5, 💨 PM10, 🧪 HCHO, ⚗️ O3
# v1.1.0 (2025-08-15): Enhanced with template v2.1.8 patterns
# v1.0.0 (2025-08-14): Initial generation from PDF specification

class LwDecode_AM300
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
        if !global.contains("AM300_nodes")
            global.AM300_nodes = {}
        end
        if !global.contains("AM300_cmdInit")
            global.AM300_cmdInit = false
        end
    end
    
    def decodeUplink(name, node, rssi, fport, payload, simulated)
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
            data['simulated'] = simulated != nil ? simulated : false
            
            # Retrieve node history from global storage
            var node_data = global.AM300_nodes.find(node, {})
            
            # Decode based on fport - AM300 uses port 85 for all data
            if fport == 85 && size(payload) >= 4
                var i = 0
                while i < size(payload) - 1
                    var channel_id = payload[i]
                    var channel_type = payload[i+1]
                    i += 2
                    
                    # BATTERY
                    if channel_id == 0x01 && channel_type == 0x75
                        data['battery'] = payload[i]
                        i += 1
                        
                    # TEMPERATURE  
                    elif channel_id == 0x03 && channel_type == 0x67
                        var temp = (payload[i+1] << 8) | payload[i]
                        if temp > 32767 temp = temp - 65536 end
                        data['temperature'] = temp / 10.0
                        i += 2
                        
                    # HUMIDITY
                    elif channel_id == 0x04 && channel_type == 0x68
                        data['humidity'] = payload[i] / 2.0
                        i += 1
                        
                    # PIR (Motion)
                    elif channel_id == 0x05 && channel_type == 0x02
                        data['pir'] = payload[i]
                        data['pir_status'] = payload[i] == 1 ? "Occupied" : "Vacant"
                        i += 1
                        
                    # LIGHT LEVEL (multiple formats)
                    elif channel_id == 0x06 && (channel_type == 0xcb || channel_type == 0x10)
                        data['light_level'] = payload[i]
                        i += 1
                        
                    # CO2
                    elif channel_id == 0x07 && channel_type == 0x7d
                        data['co2'] = (payload[i+1] << 8) | payload[i]
                        i += 2
                        
                    # TVOC LEVEL (IAQ Index)
                    elif channel_id == 0x08 && channel_type == 0x7d
                        data['tvoc_level'] = ((payload[i+1] << 8) | payload[i]) / 100.0
                        i += 2
                        
                    # TVOC CONCENTRATION  
                    elif channel_id == 0x08 && channel_type == 0xe6
                        data['tvoc_concentration'] = (payload[i+1] << 8) | payload[i]
                        i += 2
                        
                    # BAROMETRIC PRESSURE
                    elif channel_id == 0x09 && channel_type == 0x73
                        data['pressure'] = ((payload[i+1] << 8) | payload[i]) / 10.0
                        i += 2
                        
                    # HCHO (Formaldehyde)
                    elif channel_id == 0x0a && channel_type == 0x7d
                        data['hcho'] = ((payload[i+1] << 8) | payload[i]) / 100.0
                        i += 2
                        
                    # PM2.5
                    elif channel_id == 0x0b && channel_type == 0x7d
                        data['pm25'] = (payload[i+1] << 8) | payload[i]
                        i += 2
                        
                    # PM10
                    elif channel_id == 0x0c && channel_type == 0x7d
                        data['pm10'] = (payload[i+1] << 8) | payload[i]
                        i += 2
                        
                    # O3 (Ozone)
                    elif channel_id == 0x0d && channel_type == 0x7d
                        data['o3'] = ((payload[i+1] << 8) | payload[i]) / 1000.0
                        i += 2
                        
                    # BUZZER STATUS
                    elif channel_id == 0x0e && channel_type == 0x01
                        data['buzzer_status'] = payload[i]
                        data['buzzer'] = payload[i] == 1 ? "ON" : "OFF"
                        i += 1
                        
                    # ACTIVITY EVENT
                    elif channel_id == 0x0f && channel_type == 0x01
                        data['activity_event'] = true
                        i += 1
                        
                    # POWER EVENT
                    elif channel_id == 0x10 && channel_type == 0x01
                        data['power_event'] = true
                        i += 1
                        
                    # DEVICE INFO
                    elif channel_id == 0xff && channel_type == 0x0b
                        if size(payload) - i >= 10  # Need 10 bytes: 3+2+1+4
                            data['fw_version'] = f"{payload[i]}.{payload[i+1]}.{payload[i+2]}"
                            data['hw_version'] = f"{payload[i+3]}.{payload[i+4]}"
                            data['protocol_version'] = payload[i+5]
                            data['serial_number'] = string.format("%02X%02X%02X%02X", 
                                payload[i+6], payload[i+7], payload[i+8], payload[i+9])
                            i += 10
                        else
                            print(f"AM300: Device info insufficient data: {size(payload) - i} bytes available")
                            break
                        end
                        
                    else
                        # Unknown channel - log but continue
                        print(f"AM300: Unknown channel ID={channel_id:02X} Type={channel_type:02X}")
                        break
                    end
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
                # Keep last 10 battery readings
                node_data['battery_history'].push(data['battery'])
                if size(node_data['battery_history']) > 10
                    node_data['battery_history'].pop(0)
                end
            end
            
            # Track air quality events
            if data.contains('activity_event') && data['activity_event']
                node_data['activity_count'] = node_data.find('activity_count', 0) + 1
                node_data['last_activity'] = tasmota.rtc()['local']
            end
            
            # Track power events  
            if data.contains('power_event') && data['power_event']
                node_data['power_on_count'] = node_data.find('power_on_count', 0) + 1
                node_data['last_power_on'] = tasmota.rtc()['local']
            end
            
            # Register downlink commands
            if !global.contains("AM300_cmdInit") || !global.AM300_cmdInit
                self.register_downlink_commands()
                global.AM300_cmdInit = true
            end

            # Save back to global storage
            global.AM300_nodes[node] = node_data
            
            # Update instance cache
            self.last_data = data
            self.last_update = node_data['last_update']
            
            return data
            
        except .. as e, m
            print(f"AM300: Decode error - {e}: {m}")
            return nil
        end
    end
    
    def add_web_sensor()
        import global
        
        # Try to use current instance data first
        var data_to_show = self.last_data
        var last_update = self.last_update
        
        # If no instance data, try to recover from global storage
        if size(data_to_show) == 0 && self.node != nil
            var node_data = global.AM300_nodes.find(self.node, {})
            data_to_show = node_data.find('last_data', {})
            last_update = node_data.find('last_update', 0)
        end
        
        # CRITICAL FIX: Safe iteration with flag to prevent keys() iterator bug
        if size(data_to_show) == 0 && size(global.AM300_nodes) > 0
            var found_node = false
            for node_id: global.AM300_nodes.keys()
                if !found_node
                    var node_data = global.AM300_nodes[node_id]
                    data_to_show = node_data.find('last_data', {})
                    self.node = node_id  # Update instance
                    self.name = node_data.find('name', f"AM300-{node_id}")
                    last_update = node_data.find('last_update', 0)
                    found_node = true
                end
            end
        end
        
        if size(data_to_show) == 0 return nil end
        
        try
            import string
            var msg = ""
            var fmt = LwSensorFormatter_cls()
            
            # MANDATORY: Add header line with device info
            var name = self.name
            if name == nil || name == ""
                name = f"AM300-{self.node}"
            end
            var name_tooltip = "Milesight AM300 Indoor Air Quality Monitor"
            var battery = data_to_show.find('battery', 1000)  # Use 1000 if no battery 
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)  # Use 1000 if no RSSI
            var simulated = data_to_show.find('simulated', false) # Simulated payload indicator
            
            # Build display using emoji formatter
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            
            # Device info display (special case)
            if data_to_show.contains('fw_version')
                fmt.start_line()
                fmt.add_sensor("string", f"FW {data_to_show['fw_version']}", "Firmware", "⚙️")
                if data_to_show.contains('hw_version')
                    fmt.add_sensor("string", f"HW {data_to_show['hw_version']}", "Hardware", "🔧")
                end
                if data_to_show.contains('protocol_version')
                    fmt.add_sensor("string", f"P{data_to_show['protocol_version']}", "Protocol", "📡")
                end
                fmt.next_line()
                if data_to_show.contains('serial_number')
                    fmt.add_sensor("string", data_to_show['serial_number'], "Serial Number", "🏷️")
                end
                fmt.end_line()
                msg += fmt.get_msg()
                return msg
            end
            
            # Environmental sensors (single line)
            fmt.start_line()
            if data_to_show.contains('temperature')
                fmt.add_sensor("temp", data_to_show['temperature'], "Temperature", "🌡️")
            end
            if data_to_show.contains('humidity')
                fmt.add_sensor("humidity", data_to_show['humidity'], "Humidity", "💧")
            end
            if data_to_show.contains('pressure')
                fmt.add_sensor("string", f"{data_to_show['pressure']}hPa", "Pressure", "📊")
            end
            
            # Air quality sensors (next line)
            fmt.next_line()
            if data_to_show.contains('co2')
                fmt.add_sensor("string", f"{data_to_show['co2']}ppm", "CO2", "🌬️")
            end
            if data_to_show.contains('tvoc_level')
                fmt.add_sensor("string", f"{data_to_show['tvoc_level']:.0f}", "TVOC", "🏭")
            end
            if data_to_show.contains('pm25')
                fmt.add_sensor("string", f"{data_to_show['pm25']}μg", "PM2.5", "🌫️")
            end
            if data_to_show.contains('pm10')
                fmt.add_sensor("string", f"{data_to_show['pm10']}μg", "PM10", "💨")
            end
            
            # Chemical sensors and status (third line)
            var has_third_line = false
            if data_to_show.contains('hcho') && data_to_show['hcho'] > 0
                if !has_third_line fmt.next_line() has_third_line = true end
                fmt.add_sensor("string", f"{data_to_show['hcho']:.2f}mg/m³", "HCHO", "🧪")
            end
            if data_to_show.contains('o3') && data_to_show['o3'] > 0
                if !has_third_line fmt.next_line() has_third_line = true end
                fmt.add_sensor("string", f"{data_to_show['o3']:.3f}ppm", "O3", "⚗️")
            end
            if data_to_show.contains('pir_status')
                if !has_third_line fmt.next_line() has_third_line = true end
                var pir_emoji = data_to_show['pir'] == 1 ? "🟢" : "⚫"
                fmt.add_sensor("string", data_to_show['pir_status'], "Motion", pir_emoji)
            end
            if data_to_show.contains('light_level')
                if !has_third_line fmt.next_line() has_third_line = true end
                fmt.add_sensor("string", f"L{data_to_show['light_level']}", "Light", "💡")
            end
            
            # Status and events (fourth line if needed)
            var has_events = false
            var event_content = []
            
            if data_to_show.contains('buzzer') && data_to_show['buzzer'] == "ON"
                event_content.push(['string', 'Buzzer', 'Audio Alert', '🔊'])
                has_events = true
            end
            if data_to_show.contains('activity_event') && data_to_show['activity_event']
                event_content.push(['string', 'Activity', 'Motion Event', '🚶'])
                has_events = true
            end
            if data_to_show.contains('power_event') && data_to_show['power_event']
                event_content.push(['string', 'Power On', 'Device Event', '⚡'])
                has_events = true
            end
            
            # Only create line if there's content
            if has_events
                fmt.next_line()
                for content : event_content
                    fmt.add_sensor(content[0], content[1], content[2], content[3])
                end
            end
            
            fmt.end_line()
            
            # ONLY get_msg() returns a string that can be used with +=
            msg += fmt.get_msg()

            return msg
            
        except .. as e, m
            print(f"AM300: Display error - {e}: {m}")
            return "📟 AM300 Error - Check Console"
        end
    end
    
    # Get node statistics
    def get_node_stats(node_id)
        import global
        var node_data = global.AM300_nodes.find(node_id, nil)
        if node_data == nil return nil end
        
        return {
            'last_update': node_data.find('last_update', 0),
            'activity_count': node_data.find('activity_count', 0),
            'power_on_count': node_data.find('power_on_count', 0),
            'last_activity': node_data.find('last_activity', 0),
            'last_power_on': node_data.find('last_power_on', 0),
            'battery_history': node_data.find('battery_history', []),
            'name': node_data.find('name', 'Unknown')
        }
    end
    
    # Clear node data (for maintenance)
    def clear_node_data(node_id)
        import global
        if global.AM300_nodes.contains(node_id)
            global.AM300_nodes.remove(node_id)
            return true
        end
        return false
    end
    
    # Register downlink commands for device control
    def register_downlink_commands()
        import string
        
        # Reporting interval control
        tasmota.remove_cmd("LwAM300Interval")
        tasmota.add_cmd("LwAM300Interval", def(cmd, idx, payload_str)
            # Format: LwAM300Interval<slot> <minutes>
            var minutes = int(payload_str)
            if minutes < 1 || minutes > 1440
                return tasmota.resp_cmnd_str("Invalid: range 1-1440 minutes")
            end
            
            var hex_cmd = f"FF01{lwdecode.uint16le(minutes)}"
            return lwdecode.SendDownlink(global.AM300_nodes, cmd, idx, hex_cmd, f"Interval {minutes}min")
        end)
        
        # Buzzer control
        tasmota.remove_cmd("LwAM300Buzzer")
        tasmota.add_cmd("LwAM300Buzzer", def(cmd, idx, payload_str)
            # Format: LwAM300Buzzer<slot> <on|off|1|0>
            return lwdecode.SendDownlinkMap(global.AM300_nodes, cmd, idx, payload_str, { 
                '1|ON':  ['FF0E01', 'Buzzer ON'],
                '0|OFF': ['FF0E00', 'Buzzer OFF']
            })
        end)
        
        # Screen control
        tasmota.remove_cmd("LwAM300Screen")
        tasmota.add_cmd("LwAM300Screen", def(cmd, idx, payload_str)
            # Format: LwAM300Screen<slot> <on|off|1|0>
            return lwdecode.SendDownlinkMap(global.AM300_nodes, cmd, idx, payload_str, { 
                '1|ON':  ['FF2D01', 'Screen ON'],
                '0|OFF': ['FF2D00', 'Screen OFF']
            })
        end)
        
        # Time synchronization
        tasmota.remove_cmd("LwAM300TimeSync")
        tasmota.add_cmd("LwAM300TimeSync", def(cmd, idx, payload_str)
            # Format: LwAM300TimeSync<slot> [timestamp] (optional, uses current time if empty)
            var timestamp = payload_str != nil && payload_str != "" ? int(payload_str) : tasmota.rtc()['local']
            var hex_cmd = f"FF02{lwdecode.uint32le(timestamp)}"
            return lwdecode.SendDownlink(global.AM300_nodes, cmd, idx, hex_cmd, "Time synced")
        end)
        
        # Device reboot
        tasmota.remove_cmd("LwAM300Reboot")
        tasmota.add_cmd("LwAM300Reboot", def(cmd, idx, payload_str)
            # Format: LwAM300Reboot<slot>
            return lwdecode.SendDownlink(global.AM300_nodes, cmd, idx, "FF10", "Rebooting")
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

# Test UI command with realistic scenarios
tasmota.remove_cmd("LwAM300TestUI")
tasmota.add_cmd("LwAM300TestUI", def(cmd, idx, payload_str)
    # Predefined realistic test scenarios for UI development
    var test_scenarios = {
        # Realistic test payloads for different air quality conditions - All reconstructed with proper channel structure
        "normal":    "0175640367EB0004685A050200061004077DA401087DDC0509739727",      # Normal air quality: 23.5°C, 45%, CO2 420ppm
        "good":      "01755F0367DC00046864050200061006077D7C01087D20030973DA27",      # Good conditions: 22.0°C, 50%, CO2 380ppm  
        "moderate":  "0175500367E100046850050201061005077D2003087DE02E0973AB27",      # Moderate air quality: 22.5°C, 40%, CO2 800ppm
        "poor":      "01754603671801046882050201061003077DB004087DA86109736027",      # Poor conditions: 28.0°C, 65%, CO2 1200ppm
        "occupied":  "0175550367F100046860050201061007077DC201087DC4090973B827",      # Motion detected: 24.1°C, 48%, CO2 450ppm
        "alert":     "01753C03674501046896050201061002077D0807087D409C0973E326",      # High pollution alert: 32.5°C, 75%, CO2 1800ppm
        "info":      "FF0B0102030405060708090A",                                      # Device info: FW 1.2.3, HW 4.5, Protocol 6, SN 0708090A
        "buzzer_on": "01754B0367FC0004686E050201061005077D5802087D401F09738B270E01010F0101"  # Buzzer activated: 25.2°C, 55%, events
    }
    
    var hex_payload = test_scenarios.find(payload_str ? payload_str : 'nil', 'not_found')
    
    if hex_payload == 'not_found'
        # CRITICAL FIX: Use static string to avoid keys() iterator bug
        var scenarios_list = "normal good moderate poor occupied alert info buzzer_on "
        return tasmota.resp_cmnd_str(format("Available scenarios: %s", scenarios_list))
    end
    
    var rssi = -75
    var fport = 85

    return tasmota.cmd(f'LwSimulate{idx} {rssi},{fport},{hex_payload}')
end)

# MANDATORY: Register driver for web UI integration
tasmota.add_driver(LwDeco)
