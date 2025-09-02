#
# LoRaWAN AI-Generated Decoder for Dragino DDS75-LB Prompted by ZioFabry
#
# Generated: 2025-09-02 | Version: 2.1.0 | Revision: 2
#            by "LoRaWAN Decoder AI Generation Template", v2.4.1
#
# Homepage:  https://wiki.dragino.com/xwiki/bin/view/Main/User%20Manual%20for%20LoRaWAN%20End%20Nodes/DDS75-LB_LoRaWAN_Distance_Detection_Sensor_User_Manual/
# Userguide: DDS75-LB_LoRaWAN_Distance_Detection_Sensor_User_Manual v1.3
# Decoder:   Official Dragino Decoder
# 
# v2.1.0 (2025-09-02): Framework v2.4.1 upgrade - CRITICAL BERRY KEYS() ITERATOR BUG FIX
# v2.0.0 (2025-08-26): Framework v2.2.9 + Template v2.3.6 upgrade with enhanced error handling
# v1.0.0 (2025-08-16): Initial generation from PDF specification

class LwDecode_DDS75LB
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
        if !global.contains("DDS75LB_nodes")
            global.DDS75LB_nodes = {}
        end
        if !global.contains("DDS75LB_cmdInit")
            global.DDS75LB_cmdInit = false
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
            var node_data = global.DDS75LB_nodes.find(node, {})
            var previous_data = node_data.find('last_data', {})
            
            # CRITICAL FIX: Use explicit key arrays for data recovery
            if size(previous_data) > 0
                # Define persistent keys explicitly (avoid keys() iterator)
                for key: ['battery_v', 'distance_mm', 'distance_cm', 'temperature', 'sensor_detected', 
                         'ultrasonic_detected', 'distance_error', 'interrupt_triggered']
                    if previous_data.contains(key)
                        data[key] = previous_data[key]
                    end
                end
            end
            
            if fport == 1  # Periodic Data
                if size(payload) >= 8
                    # Battery voltage (bytes 0-1, little endian)
                    var battery_mv = (payload[1] << 8) | payload[0]
                    data['battery_v'] = battery_mv / 1000.0
                    
                    # Distance (bytes 2-3, little endian)
                    var distance_mm = (payload[3] << 8) | payload[2]
                    if distance_mm == 0x0000
                        data['distance_error'] = "No ultrasonic sensor detected"
                        data['sensor_detected'] = false
                    elif distance_mm == 0x0014
                        data['distance_error'] = "Invalid distance (<280mm)"
                        data['sensor_detected'] = true
                    else
                        data['distance_mm'] = distance_mm
                        data['distance_cm'] = distance_mm / 10.0
                        data['sensor_detected'] = true
                    end
                    
                    # Digital interrupt flag (byte 4)
                    data['interrupt_triggered'] = (payload[4] == 0x01)
                    
                    # DS18B20 Temperature (bytes 5-6, little endian, signed)
                    if size(payload) >= 7
                        var temp_raw = (payload[6] << 8) | payload[5]
                        if temp_raw & 0xFC00  # Check if temperature is negative
                            temp_raw = temp_raw - 65536
                        end
                        data['temperature'] = temp_raw / 10.0
                    end
                    
                    # Sensor flag (byte 7)
                    if size(payload) >= 8
                        data['ultrasonic_detected'] = (payload[7] == 0x01)
                    end
                end
                
            elif fport == 5  # Device Status
                if size(payload) >= 7
                    # Sensor model (byte 0)
                    data['sensor_model'] = f"0x{payload[0]:02X}"
                    if payload[0] == 0x27
                        data['model_name'] = "DDS75-LB/LS"
                    end
                    
                    # Firmware version (bytes 1-2, little endian)
                    var fw_version = (payload[2] << 8) | payload[1]
                    data['fw_version'] = f"v{fw_version:04X}"
                    
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
                # Keep last 10 battery readings
                node_data['battery_history'].push(data['battery_v'])
                if size(node_data['battery_history']) > 10
                    node_data['battery_history'].pop(0)
                end
            end
            
            # Store distance trend if available
            if data.contains('distance_cm')
                if !node_data.contains('distance_history')
                    node_data['distance_history'] = []
                end
                node_data['distance_history'].push(data['distance_cm'])
                if size(node_data['distance_history']) > 10
                    node_data['distance_history'].pop(0)
                end
            end
            
            # Track interrupt events
            if data.contains('interrupt_triggered') && data['interrupt_triggered']
                node_data['interrupt_count'] = node_data.find('interrupt_count', 0) + 1
                node_data['last_interrupt'] = tasmota.rtc()['local']
            end
            
            # Initialize downlink commands once
            if !global.contains("DDS75LB_cmdInit") || !global.DDS75LB_cmdInit
                self.register_downlink_commands()
                global.DDS75LB_cmdInit = true
            end

            # Save back to global storage
            global.DDS75LB_nodes[node] = node_data
            
            # Update instance cache
            self.last_data = data
            self.last_update = node_data['last_update']
            
            return data
            
        except .. as e, m
            print(f"DDS75LB: Decode error - {e}: {m}")
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
                var node_data = global.DDS75LB_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            # Fallback: find ANY stored node if no specific node
            # CRITICAL FIX: Use safe iteration with flag (recommended)
            if size(data_to_show) == 0 && size(global.DDS75LB_nodes) > 0
                var found_node = false
                for node_id: global.DDS75LB_nodes.keys()
                    if !found_node
                        var node_data = global.DDS75LB_nodes[node_id]
                        data_to_show = node_data.find('last_data', {})
                        last_update = node_data.find('last_update', 0)
                        self.node = node_id  # Update instance
                        self.name = node_data.find('name', f"DDS75LB-{node_id}")
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
                name = f"DDS75LB-{self.node}"
            end
            var name_tooltip = "Dragino DDS75-LB Distance Detection Sensor"
            var battery = data_to_show.find('battery_v', 1000)
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)
            var simulated = data_to_show.find('simulated', false)
            
            # Build display using emoji formatter
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            
            fmt.start_line()
            
            # Distance measurement
            if data_to_show.contains('distance_cm')
                fmt.add_sensor("distance", data_to_show['distance_cm'], "Distance", "📏")
            elif data_to_show.contains('distance_error')
                fmt.add_status(data_to_show['distance_error'], "⚠️", "Distance Error")
            end
            
            # Battery voltage
            if data_to_show.contains('battery_v')
                fmt.add_sensor("volt", data_to_show['battery_v'], "Battery", "🔋")
            end
            
            # Temperature if available
            if data_to_show.contains('temperature')
                fmt.add_sensor("temp", data_to_show['temperature'], "Temperature", "🌡️")
            end
            
            # Sensor status
            var sensor_detected = data_to_show.find('sensor_detected', nil)
            if sensor_detected != nil
                if sensor_detected
                    fmt.add_status("Detected", "✅", "Ultrasonic sensor connected")
                else
                    fmt.add_status("No Sensor", "❌", "Ultrasonic sensor not detected")
                end
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
                    fmt.add_status(data_to_show['fw_version'], "🔧", "Firmware Version")
                end
                
                if data_to_show.contains('frequency_band')
                    fmt.add_status(data_to_show['frequency_band'], "📡", "LoRaWAN Frequency Band")
                end
            end
            
            # Event line (when present)
            var events = []
            if data_to_show.contains('interrupt_triggered') && data_to_show['interrupt_triggered']
                events.push(["Interrupt", "🔔", "Digital interrupt triggered"])
            end
            
            # Add events line only if we have events
            if size(events) > 0
                fmt.next_line()
                for event : events
                    fmt.add_status(event[0], event[1], event[2])
                end
            end
            
            fmt.end_line()
            
            # ONLY get_msg() return a string that can be used with +=
            msg += fmt.get_msg()

            return msg
            
        except .. as e, m
            print(f"DDS75LB: Display error - {e}: {m}")
            return "📟 DDS75LB Error - Check Console"
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
        var node_data = global.DDS75LB_nodes.find(node_id, nil)
        if node_data == nil return nil end
        
        return {
            'last_update': node_data.find('last_update', 0),
            'battery_history': node_data.find('battery_history', []),
            'distance_history': node_data.find('distance_history', []),
            'interrupt_count': node_data.find('interrupt_count', 0),
            'last_interrupt': node_data.find('last_interrupt', 0),
            'name': node_data.find('name', 'Unknown')
        }
    end
    
    # Clear node data (for maintenance)
    def clear_node_data(node_id)
        import global
        if global.DDS75LB_nodes.contains(node_id)
            global.DDS75LB_nodes.remove(node_id)
            return true
        end
        return false
    end
    
    # Register downlink commands for device control
    def register_downlink_commands()
        import string
        
        # Set Transmit Interval
        tasmota.remove_cmd("LwDDS75LBInterval")
        tasmota.add_cmd("LwDDS75LBInterval", def(cmd, idx, payload_str)
            # Format: LwDDS75LBInterval<slot> <seconds>
            var seconds = int(payload_str)
            if seconds < 10 || seconds > 16777215
                return tasmota.resp_cmnd_str("Invalid: range 10-16777215 seconds")
            end
            
            # Build hex command (24-bit little endian)
            var hex_cmd = f"01{lwdecode.uint16le(seconds & 0xFFFF)}{(seconds >> 16) & 0xFF:02X}"
            return lwdecode.SendDownlink(global.DDS75LB_nodes, cmd, idx, hex_cmd)
        end)
        
        # Set Interrupt Mode
        tasmota.remove_cmd("LwDDS75LBInterrupt")
        tasmota.add_cmd("LwDDS75LBInterrupt", def(cmd, idx, payload_str)
            # Format: LwDDS75LBInterrupt<slot> <disable|rising>
            return lwdecode.SendDownlinkMap(global.DDS75LB_nodes, cmd, idx, payload_str, { 
                'DISABLE': ['06000000', 'Interrupt Disabled'],
                'RISING':  ['06030000', 'Rising Edge Interrupt']
            })
        end)
        
        # Set Delta Detect Mode
        tasmota.remove_cmd("LwDDS75LBDeltaMode")
        tasmota.add_cmd("LwDDS75LBDeltaMode", def(cmd, idx, payload_str)
            # Format: LwDDS75LBDeltaMode<slot> <mode>,<interval>,<threshold>,<samples>
            var parts = string.split(payload_str, ',')
            if size(parts) != 4
                return tasmota.resp_cmnd_str("Usage: LwDDS75LBDeltaMode<slot> <mode>,<interval>,<threshold>,<samples>")
            end
            
            var mode = int(parts[0])
            var interval = int(parts[1])
            var threshold = int(parts[2])
            var samples = int(parts[3])
            
            if mode < 1 || mode > 2
                return tasmota.resp_cmnd_str("Invalid mode: 1=normal, 2=delta")
            end
            if interval < 1 || interval > 65535
                return tasmota.resp_cmnd_str("Invalid interval: range 1-65535 seconds")
            end
            if threshold < 1 || threshold > 65535
                return tasmota.resp_cmnd_str("Invalid threshold: range 1-65535 cm")
            end
            if samples < 5 || samples > 20
                return tasmota.resp_cmnd_str("Invalid samples: range 5-20")
            end
            
            var hex_cmd = f"FB{mode:02X}{lwdecode.uint16be(interval)}{lwdecode.uint16be(threshold)}{samples:02X}"
            return lwdecode.SendDownlink(global.DDS75LB_nodes, cmd, idx, hex_cmd)
        end)
        
        # Request Device Status
        tasmota.remove_cmd("LwDDS75LBStatus")
        tasmota.add_cmd("LwDDS75LBStatus", def(cmd, idx, payload_str)
            # Format: LwDDS75LBStatus<slot>
            var hex_cmd = "2601"
            return lwdecode.SendDownlink(global.DDS75LB_nodes, cmd, idx, hex_cmd)
        end)
        
        # Poll Sensor Data
        tasmota.remove_cmd("LwDDS75LBPoll")
        tasmota.add_cmd("LwDDS75LBPoll", def(cmd, idx, payload_str)
            # Format: LwDDS75LBPoll<slot> <start_ts>,<end_ts>,<interval>
            var parts = string.split(payload_str, ',')
            if size(parts) != 3
                return tasmota.resp_cmnd_str("Usage: LwDDS75LBPoll<slot> <start_ts>,<end_ts>,<interval>")
            end
            
            var start_ts = int(parts[0])
            var end_ts = int(parts[1])
            var interval = int(parts[2])
            
            if interval < 5 || interval > 255
                return tasmota.resp_cmnd_str("Invalid interval: range 5-255 seconds")
            end
            
            var hex_cmd = f"31{lwdecode.uint32be(start_ts)}{lwdecode.uint32be(end_ts)}{interval:02X}"
            return lwdecode.SendDownlink(global.DDS75LB_nodes, cmd, idx, hex_cmd)
        end)
        
        print("DDS75LB: Downlink commands registered")
    end
end

# Global instance
LwDeco = LwDecode_DDS75LB()

# Node management commands
tasmota.remove_cmd("LwDDS75LBNodeStats")
tasmota.add_cmd("LwDDS75LBNodeStats", def(cmd, idx, node_id)
    var stats = LwDeco.get_node_stats(node_id)
    if stats != nil
        import json
        tasmota.resp_cmnd(json.dump(stats))
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

tasmota.remove_cmd("LwDDS75LBClearNode")
tasmota.add_cmd("LwDDS75LBClearNode", def(cmd, idx, node_id)
    if LwDeco.clear_node_data(node_id)
        tasmota.resp_cmnd_done()
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

# Test UI command
tasmota.remove_cmd("LwDDS75LBTestUI")
tasmota.add_cmd("LwDDS75LBTestUI", def(cmd, idx, payload_str)
    # Predefined realistic test scenarios for UI development
    var test_scenarios = {
        "normal":        "C00E7A1F00FF8601",    # Normal: 3776mV, 1400cm, no interrupt, 25.5°C, sensor detected
        "close":         "C00E180100FFA201",    # Close object: 3776mV, 28cm, no interrupt, 25.8°C, sensor detected
        "interrupt":     "C00E7A1F01FF8601",    # With interrupt: 3776mV, 1400cm, interrupt triggered, 25.5°C, sensor detected
        "no_sensor":     "C00E000000FF8600",    # No sensor: 3776mV, 0mm (no sensor), no interrupt, 25.5°C, not detected
        "invalid":       "C00E140000FF8601",    # Invalid reading: 3776mV, 20mm (<280mm), no interrupt, 25.5°C, sensor detected
        "low_battery":   "800A7A1F00FF8601",    # Low battery: 2688mV, 1400cm, no interrupt, 25.5°C, sensor detected
        "cold":          "C00E7A1F0088FF01",    # Cold: 3776mV, 1400cm, no interrupt, -12.0°C, sensor detected
        "status":        "2748021B055E0E"      # Device status: Model 0x27, FW v1.2, EU868, sub-band 5, 3678mV
    }
    
    var hex_payload = test_scenarios.find(payload_str ? payload_str : 'nil', 'not_found')
    
    if hex_payload == 'not_found'
      # CRITICAL FIX: Use static string to avoid keys() iterator bug
      var scenarios_list = "normal close interrupt no_sensor invalid low_battery cold status "
      return tasmota.resp_cmnd_str(format("Available scenarios: %s", scenarios_list))
    end
    
    var rssi = -75
    var fport = (payload_str == "status") ? 5 : 1

    return tasmota.cmd(f'LwSimulate{idx} {rssi},{fport},{hex_payload}')
end)

# MANDATORY: Register driver for web UI integration
tasmota.add_driver(LwDeco)
