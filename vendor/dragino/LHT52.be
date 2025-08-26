#
# LoRaWAN AI-Generated Decoder for Dragino LHT52 Prompted by ZioFabry
#
# Generated: 2025-08-26 | Version: 2.0.0 | Revision: 1
#            by "LoRaWAN Decoder AI Generation Template", v2.3.6
#
# Homepage:  https://wiki.dragino.com/xwiki/bin/view/Main/User%20Manual%20for%20LoRaWAN%20End%20Nodes/LHT52%20-%20LoRaWAN%20Temperature%20%26%20Humidity%20Sensor%20User%20Manual/
# Userguide: LHT52_LoRaWAN_Temperature_Humidity_Sensor_UserManual v1.0.0
# Decoder:   Official Dragino Decoder
# 
# v2.0.0 (2025-08-26): Framework v2.2.9 + Template v2.3.6 major upgrade with enhanced error handling
# v1.0.0 (2025-08-16): Initial generation from MAP cache specification

class LwDecode_LHT52
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
        if !global.contains("LHT52_nodes")
            global.LHT52_nodes = {}
        end
        if !global.contains("LHT52_cmdInit")
            global.LHT52_cmdInit = false
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
            # Store device info (Framework v2.2.9 compatibility)
            self.name = name
            self.node = node
            data['RSSI'] = rssi      # Framework v2.2.9 uses UPPERCASE
            data['FPort'] = fport    # Framework v2.2.9 uses UPPERCASE
            data['simulated'] = simulated  # Framework v2.2.9 passes simulated
            
            # Retrieve node history from global storage
            var node_data = global.LHT52_nodes.find(node, {})
            
            if fport == 5  # Device Status
                if size(payload) >= 7
                    # Sensor model (byte 0)
                    data['sensor_model'] = payload[0]
                    if payload[0] == 0x09
                        data['model_name'] = "LHT52"
                    end
                    
                    # Firmware version (bytes 1-2, little endian)
                    var fw_raw = (payload[2] << 8) | payload[1]
                    data['fw_version'] = f"v{(fw_raw >> 8) & 0xFF}.{fw_raw & 0xFF}"
                    
                    # Frequency band (byte 3)
                    var bands = {
                        0x01: "EU868", 0x02: "US915", 0x03: "IN865", 0x04: "AU915",
                        0x05: "KZ865", 0x06: "RU864", 0x07: "AS923", 0x08: "AS923-2",
                        0x09: "AS923-3", 0x0A: "AS923-4", 0x0B: "CN470", 0x0C: "EU433",
                        0x0D: "KR920", 0x0E: "MA869"
                    }
                    data['frequency_band'] = bands.find(payload[3], f"Unknown(0x{payload[3]:02X})")
                    
                    # Sub-band (byte 4)
                    data['sub_band'] = payload[4]
                    
                    # Battery voltage (bytes 5-6, little endian)
                    var battery_mv = (payload[6] << 8) | payload[5]
                    data['battery_v'] = battery_mv / 1000.0
                    data['battery_mv'] = battery_mv
                end
                
            elif fport == 2  # Real-time Sensor Value
                if size(payload) >= 11
                    # Temperature (bytes 0-1, signed little endian)
                    var temp_raw = (payload[1] << 8) | payload[0]
                    if temp_raw > 32767
                        temp_raw = temp_raw - 65536
                    end
                    data['temperature'] = temp_raw / 100.0
                    
                    # Humidity (bytes 2-3, little endian)
                    var hum_raw = (payload[3] << 8) | payload[2]
                    data['humidity'] = hum_raw / 10.0
                    
                    # External temperature (bytes 4-5, signed little endian)
                    var ext_temp_raw = (payload[5] << 8) | payload[4]
                    if ext_temp_raw != 0x7FFF  # Not disconnected
                        if ext_temp_raw > 32767
                            ext_temp_raw = ext_temp_raw - 65536
                        end
                        data['ext_temperature'] = ext_temp_raw / 100.0
                    else
                        data['ext_disconnected'] = true
                    end
                    
                    # Extension type (byte 6)
                    data['extension_type'] = payload[6]
                    if payload[6] == 0x01
                        data['extension_name'] = "AS-01 Temperature Probe"
                    end
                    
                    # Unix timestamp (bytes 7-10, little endian)
                    if size(payload) >= 11
                        var timestamp = (payload[10] << 24) | (payload[9] << 16) | (payload[8] << 8) | payload[7]
                        data['timestamp'] = timestamp
                        data['timestamp_readable'] = self.format_timestamp(timestamp)
                    end
                end
                
            elif fport == 3  # Datalog Sensor Value
                if size(payload) >= 11
                    # Same structure as real-time but from datalog
                    var temp_raw = (payload[1] << 8) | payload[0]
                    if temp_raw > 32767
                        temp_raw = temp_raw - 65536
                    end
                    data['datalog_temperature'] = temp_raw / 100.0
                    
                    var hum_raw = (payload[3] << 8) | payload[2]
                    data['datalog_humidity'] = hum_raw / 10.0
                    
                    var ext_temp_raw = (payload[5] << 8) | payload[4]
                    if ext_temp_raw != 0x7FFF
                        if ext_temp_raw > 32767
                            ext_temp_raw = ext_temp_raw - 65536
                        end
                        data['datalog_ext_temperature'] = ext_temp_raw / 100.0
                    end
                    
                    data['datalog_extension'] = payload[6]
                    
                    var timestamp = (payload[10] << 24) | (payload[9] << 16) | (payload[8] << 8) | payload[7]
                    data['datalog_timestamp'] = timestamp
                    data['datalog_time_readable'] = self.format_timestamp(timestamp)
                end
                
            elif fport == 4  # DS18B20 ID
                if size(payload) >= 8
                    var sensor_id = ""
                    for i: 0..7
                        sensor_id += f"{payload[i]:02X}"
                    end
                    data['ds18b20_id'] = sensor_id
                end
            end
            
            # Update node history in global storage
            node_data['last_data'] = data
            node_data['last_update'] = tasmota.rtc()['local']
            node_data['name'] = name
            
            # Store battery trend if available
            if data.contains('battery_v')
                if !node_data.contains('battery_history')
                    node_data['battery_history'] = []
                end
                node_data['battery_history'].push(data['battery_v'])
                if size(node_data['battery_history']) > 10
                    node_data['battery_history'].pop(0)
                end
            end
            
            # Store temperature trends
            if data.contains('temperature')
                if !node_data.contains('temp_history')
                    node_data['temp_history'] = []
                end
                node_data['temp_history'].push(data['temperature'])
                if size(node_data['temp_history']) > 10
                    node_data['temp_history'].pop(0)
                end
            end
            
            # Store humidity trends
            if data.contains('humidity')
                if !node_data.contains('humidity_history')
                    node_data['humidity_history'] = []
                end
                node_data['humidity_history'].push(data['humidity'])
                if size(node_data['humidity_history']) > 10
                    node_data['humidity_history'].pop(0)
                end
            end
            
            # Initialize downlink commands once
            if !global.contains("LHT52_cmdInit") || !global.LHT52_cmdInit
                self.register_downlink_commands()
                global.LHT52_cmdInit = true
            end

            # Save back to global storage
            global.LHT52_nodes[node] = node_data
            
            # Update instance cache
            self.last_data = data
            self.last_update = node_data['last_update']
            
            return data
            
        except .. as e, m
            print(f"LHT52: Decode error - {e}: {m}")
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
                var node_data = global.LHT52_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            # Fallback: find ANY stored node if no specific node
            if size(data_to_show) == 0 && size(global.LHT52_nodes) > 0
                for node_id: global.LHT52_nodes.keys()
                    var node_data = global.LHT52_nodes[node_id]
                    data_to_show = node_data.find('last_data', {})
                    last_update = node_data.find('last_update', 0)
                    self.node = node_id  # Update instance
                    self.name = node_data.find('name', f"LHT52-{node_id}")
                    break  # Use first found
                end
            end
            
            if size(data_to_show) == 0 return "" end
            
            import string
            var msg = ""
            var fmt = LwSensorFormatter_cls()
            
            # MANDATORY: Add header line with device info
            var name = self.name
            if name == nil || name == ""
                name = f"LHT52-{self.node}"
            end
            var name_tooltip = "Dragino LHT52 Temperature & Humidity Sensor"
            var battery = data_to_show.find('battery_v', 1000)
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)
            var simulated = data_to_show.find('simulated', false)
            
            # Build display using emoji formatter
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            
            fmt.start_line()
            
            # Main sensor readings
            if data_to_show.contains('temperature')
                fmt.add_sensor("temp", data_to_show['temperature'], "Temperature", "🌡️")
            elif data_to_show.contains('datalog_temperature')
                fmt.add_sensor("temp", data_to_show['datalog_temperature'], "DataLog Temp", "🌡️")
            end
            
            if data_to_show.contains('humidity')
                fmt.add_sensor("humidity", data_to_show['humidity'], "Humidity", "💧")
            elif data_to_show.contains('datalog_humidity')
                fmt.add_sensor("humidity", data_to_show['datalog_humidity'], "DataLog Humidity", "💧")
            end
            
            # External temperature sensor
            if data_to_show.contains('ext_temperature')
                fmt.add_sensor("temp", data_to_show['ext_temperature'], "External Temp", "🔗")
            elif data_to_show.contains('datalog_ext_temperature')
                fmt.add_sensor("temp", data_to_show['datalog_ext_temperature'], "DataLog Ext Temp", "🔗")
            elif data_to_show.contains('ext_disconnected') && data_to_show['ext_disconnected']
                fmt.add_status("Probe Disc", "⚠️", "External probe disconnected")
            end
            
            # Battery (if available)
            if data_to_show.contains('battery_v')
                fmt.add_sensor("volt", data_to_show['battery_v'], "Battery", "🔋")
            end
            
            # Device info line (when available)
            var has_device_info = false
            if data_to_show.contains('model_name') || data_to_show.contains('fw_version') || data_to_show.contains('frequency_band')
                fmt.next_line()
                has_device_info = true
                
                if data_to_show.contains('model_name')
                    fmt.add_status(data_to_show['model_name'], "📟", "Device Model")
                end
                
                if data_to_show.contains('fw_version')
                    fmt.add_status(data_to_show['fw_version'], "💾", "Firmware Version")
                end
                
                if data_to_show.contains('frequency_band')
                    fmt.add_status(data_to_show['frequency_band'], "📡", "LoRaWAN Band")
                end
            end
            
            # Timestamp info line (when available)
            var has_timestamp = false
            if data_to_show.contains('timestamp_readable') || data_to_show.contains('datalog_time_readable') || data_to_show.contains('ds18b20_id')
                if !has_device_info
                    fmt.next_line()
                else
                    fmt.next_line()
                end
                has_timestamp = true
                
                if data_to_show.contains('timestamp_readable')
                    fmt.add_status(data_to_show['timestamp_readable'], "⏰", "Sample Time")
                elif data_to_show.contains('datalog_time_readable')
                    fmt.add_status(data_to_show['datalog_time_readable'], "⏰", "DataLog Time")
                end
                
                if data_to_show.contains('extension_name')
                    fmt.add_status(data_to_show['extension_name'], "🔌", "External Sensor")
                end
                
                if data_to_show.contains('ds18b20_id')
                    fmt.add_status(f"ID:{data_to_show['ds18b20_id'][0..7]}...", "🏷️", f"DS18B20 ID: {data_to_show['ds18b20_id']}")
                end
            end
            
            fmt.end_line()
            
            # ONLY get_msg() return a string that can be used with +=
            msg += fmt.get_msg()

            return msg
            
        except .. as e, m
            print(f"LHT52: Display error - {e}: {m}")
            return "📟 LHT52 Error - Check Console"
        end
    end
    
    def format_timestamp(ts)
        if ts == 0 || ts == nil return "Unknown" end
        
        # Convert to readable format
        var rtc = tasmota.rtc()
        var diff = rtc['local'] - ts
        
        if diff < 0 diff = -diff end  # Handle future timestamps
        
        if diff < 60 return f"Now"
        elif diff < 3600 return f"{diff/60}m ago"
        elif diff < 86400 return f"{diff/3600}h ago"
        else return f"{diff/86400}d ago"
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
        var node_data = global.LHT52_nodes.find(node_id, nil)
        if node_data == nil return nil end
        
        return {
            'last_update': node_data.find('last_update', 0),
            'battery_history': node_data.find('battery_history', []),
            'temp_history': node_data.find('temp_history', []),
            'humidity_history': node_data.find('humidity_history', []),
            'name': node_data.find('name', 'Unknown')
        }
    end
    
    # Clear node data (for maintenance)
    def clear_node_data(node_id)
        import global
        if global.LHT52_nodes.contains(node_id)
            global.LHT52_nodes.remove(node_id)
            return true
        end
        return false
    end
    
    # Register downlink commands for device control
    def register_downlink_commands()
        import string
        
        # Set TDC Time (Transmission Interval)
        tasmota.remove_cmd("LwLHT52Interval")
        tasmota.add_cmd("LwLHT52Interval", def(cmd, idx, payload_str)
            # Format: LwLHT52Interval<slot> <milliseconds>
            var ms = int(payload_str)
            if ms < 1 || ms > 86400000
                return tasmota.resp_cmnd_str("Invalid: range 1-86400000ms")
            end
            
            var hex_cmd = f"01{lwdecode.uint32le(ms)}"
            return lwdecode.SendDownlink(global.LHT52_nodes, cmd, idx, hex_cmd)
        end)
        
        # Reset Device
        tasmota.remove_cmd("LwLHT52Reset")
        tasmota.add_cmd("LwLHT52Reset", def(cmd, idx, payload_str)
            # Format: LwLHT52Reset<slot>
            var hex_cmd = "04FF"
            return lwdecode.SendDownlink(global.LHT52_nodes, cmd, idx, hex_cmd)
        end)
        
        # Factory Reset
        tasmota.remove_cmd("LwLHT52FactoryReset")
        tasmota.add_cmd("LwLHT52FactoryReset", def(cmd, idx, payload_str)
            # Format: LwLHT52FactoryReset<slot>
            var hex_cmd = "04FE"
            return lwdecode.SendDownlink(global.LHT52_nodes, cmd, idx, hex_cmd)
        end)
        
        # Set Confirmation Mode
        tasmota.remove_cmd("LwLHT52Confirmed")
        tasmota.add_cmd("LwLHT52Confirmed", def(cmd, idx, payload_str)
            # Format: LwLHT52Confirmed<slot> <enable|disable|1|0>
            return lwdecode.SendDownlinkMap(global.LHT52_nodes, cmd, idx, payload_str, { 
                '1|ENABLE':  ['0501', 'Confirmed Mode Enabled'],
                '0|DISABLE': ['0500', 'Confirmed Mode Disabled']
            })
        end)
        
        # Set Sub-band
        tasmota.remove_cmd("LwLHT52Subband")
        tasmota.add_cmd("LwLHT52Subband", def(cmd, idx, payload_str)
            # Format: LwLHT52Subband<slot> <0-8>
            var subband = int(payload_str)
            if subband < 0 || subband > 8
                return tasmota.resp_cmnd_str("Invalid: range 0-8")
            end
            
            var hex_cmd = f"07{subband:02X}"
            return lwdecode.SendDownlink(global.LHT52_nodes, cmd, idx, hex_cmd)
        end)
        
        # Set Network Join Mode
        tasmota.remove_cmd("LwLHT52JoinMode")
        tasmota.add_cmd("LwLHT52JoinMode", def(cmd, idx, payload_str)
            # Format: LwLHT52JoinMode<slot> <otaa|abp>
            return lwdecode.SendDownlinkMap(global.LHT52_nodes, cmd, idx, payload_str, { 
                'OTAA': ['2001', 'OTAA Mode'],
                'ABP':  ['2000', 'ABP Mode']
            })
        end)
        
        # Set ADR
        tasmota.remove_cmd("LwLHT52ADR")
        tasmota.add_cmd("LwLHT52ADR", def(cmd, idx, payload_str)
            # Format: LwLHT52ADR<slot> <enable|disable|1|0>
            return lwdecode.SendDownlinkMap(global.LHT52_nodes, cmd, idx, payload_str, { 
                '1|ENABLE':  ['2201', 'ADR Enabled'],
                '0|DISABLE': ['2200', 'ADR Disabled']
            })
        end)
        
        # Request Device Status
        tasmota.remove_cmd("LwLHT52Status")
        tasmota.add_cmd("LwLHT52Status", def(cmd, idx, payload_str)
            # Format: LwLHT52Status<slot>
            var hex_cmd = "2301"
            return lwdecode.SendDownlink(global.LHT52_nodes, cmd, idx, hex_cmd)
        end)
        
        # Request DS18B20 ID
        tasmota.remove_cmd("LwLHT52ProbeID")
        tasmota.add_cmd("LwLHT52ProbeID", def(cmd, idx, payload_str)
            # Format: LwLHT52ProbeID<slot>
            var hex_cmd = "2302"
            return lwdecode.SendDownlink(global.LHT52_nodes, cmd, idx, hex_cmd)
        end)
        
        # Set DWELL Time
        tasmota.remove_cmd("LwLHT52DwellTime")
        tasmota.add_cmd("LwLHT52DwellTime", def(cmd, idx, payload_str)
            # Format: LwLHT52DwellTime<slot> <enable|disable|1|0>
            return lwdecode.SendDownlinkMap(global.LHT52_nodes, cmd, idx, payload_str, { 
                '1|ENABLE':  ['2501', 'DWELL Time Enabled'],
                '0|DISABLE': ['2500', 'DWELL Time Disabled']
            })
        end)
        
        # Set Rejoin Interval
        tasmota.remove_cmd("LwLHT52RejoinInterval")
        tasmota.add_cmd("LwLHT52RejoinInterval", def(cmd, idx, payload_str)
            # Format: LwLHT52RejoinInterval<slot> <minutes>
            var minutes = int(payload_str)
            if minutes < 1 || minutes > 65535
                return tasmota.resp_cmnd_str("Invalid: range 1-65535 minutes")
            end
            
            var hex_cmd = f"26{lwdecode.uint16le(minutes)}"
            return lwdecode.SendDownlink(global.LHT52_nodes, cmd, idx, hex_cmd)
        end)
        
        # Poll Sensor Data
        tasmota.remove_cmd("LwLHT52Poll")
        tasmota.add_cmd("LwLHT52Poll", def(cmd, idx, payload_str)
            # Format: LwLHT52Poll<slot> <start_ts>,<end_ts>,<interval>
            var parts = string.split(payload_str, ',')
            if size(parts) != 3
                return tasmota.resp_cmnd_str("Usage: LwLHT52Poll<slot> <start_ts>,<end_ts>,<interval>")
            end
            
            var start_ts = int(parts[0])
            var end_ts = int(parts[1])
            var interval = int(parts[2])
            
            if interval < 5 || interval > 255
                return tasmota.resp_cmnd_str("Invalid interval: range 5-255 seconds")
            end
            
            var hex_cmd = f"31{lwdecode.uint32le(start_ts)}{lwdecode.uint32le(end_ts)}{interval:02X}"
            return lwdecode.SendDownlink(global.LHT52_nodes, cmd, idx, hex_cmd)
        end)
        
        # Set Alarm Mode
        tasmota.remove_cmd("LwLHT52AlarmMode")
        tasmota.add_cmd("LwLHT52AlarmMode", def(cmd, idx, payload_str)
            # Format: LwLHT52AlarmMode<slot> <enable|disable|1|0>
            return lwdecode.SendDownlinkMap(global.LHT52_nodes, cmd, idx, payload_str, { 
                '1|ENABLE':  ['A501', 'Alarm Mode Enabled'],
                '0|DISABLE': ['A500', 'Alarm Mode Disabled']
            })
        end)
        
        # Set Temperature Check Interval
        tasmota.remove_cmd("LwLHT52TempCheckInterval")
        tasmota.add_cmd("LwLHT52TempCheckInterval", def(cmd, idx, payload_str)
            # Format: LwLHT52TempCheckInterval<slot> <minutes>
            var minutes = int(payload_str)
            if minutes < 1 || minutes > 65535
                return tasmota.resp_cmnd_str("Invalid: range 1-65535 minutes")
            end
            
            var hex_cmd = f"A7{lwdecode.uint16le(minutes)}"
            return lwdecode.SendDownlink(global.LHT52_nodes, cmd, idx, hex_cmd)
        end)
        
        print("LHT52: Downlink commands registered")
    end
end

# Global instance
LwDeco = LwDecode_LHT52()

# Node management commands
tasmota.remove_cmd("LwLHT52NodeStats")
tasmota.add_cmd("LwLHT52NodeStats", def(cmd, idx, node_id)
    var stats = LwDeco.get_node_stats(node_id)
    if stats != nil
        import json
        tasmota.resp_cmnd(json.dump(stats))
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

tasmota.remove_cmd("LwLHT52ClearNode")
tasmota.add_cmd("LwLHT52ClearNode", def(cmd, idx, node_id)
    if LwDeco.clear_node_data(node_id)
        tasmota.resp_cmnd_done()
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

# Test UI command
tasmota.remove_cmd("LwLHT52TestUI")
tasmota.add_cmd("LwLHT52TestUI", def(cmd, idx, payload_str)
    # Predefined realistic test scenarios for UI development
    var test_scenarios = {
        "normal":        "AC0ADA0A64140100B97B6F66",    # Normal: 27.24°C, 56.2%RH, 50.52°C ext, AS-01, timestamp
        "cold":          "D0FE5009641401009C8A6F66",    # Cold: -7.20°C, 24.5%RH, 50.52°C ext, AS-01, timestamp  
        "no_external":   "AC0ADA0AFFFF000000000000",    # No external: 27.24°C, 56.2%RH, no ext sensor
        "datalog":       "7C09C40A32190100A0C86F66",    # Datalog: 24.60°C, 70.0%RH, 65.46°C ext, timestamp
        "low_humidity":  "AC0A0A00641401005C7D6F66",    # Low humidity: 27.24°C, 1.0%RH, ext temp
        "high_temp":     "E817DA0A641401004A886F66",    # High temp: 61.00°C, 56.2%RH, ext temp
        "status":        "0910000101B80B",             # Device status: Model 0x09, FW v1.0, EU868, sub 1, 3000mV
        "probe_id":      "28FF123456789ABC01"          # DS18B20 ID response
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
    var fport = 2  # Default to sensor data
    
    # Override fport for specific scenarios
    if payload_str == "status"
        fport = 5
    elif payload_str == "datalog"
        fport = 3
    elif payload_str == "probe_id"
        fport = 4
    end

    return tasmota.cmd(f'LwSimulate{idx} {rssi},{fport},{hex_payload}')
end)

# MANDATORY: Register driver for web UI integration
tasmota.add_driver(LwDeco)
