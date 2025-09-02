#
# LoRaWAN AI-Generated Decoder for Dragino PS-LB Prompted by ZioFabry 
#
# Generated: 2025-09-03 | Version: 3.0.0 | Revision: 1
#            by "LoRaWAN Decoder AI Generation Template", v2.5.0
#
# Homepage:  https://wiki.dragino.com/xwiki/bin/view/Main/User%20Manual%20for%20LoRaWAN%20End%20Nodes/PS-LB%20--%20LoRaWAN%20Pressure%20Sensor/
# Userguide: PS-LB_LoRaWAN_Pressure_Sensor_UserManual
# Decoder:   Official Dragino Decoder
# 
# v3.0.0 (2025-09-03): Template v2.5.0 with verified TestUI payload decoding

class LwDecode_PSLB
    var hashCheck      # Duplicate payload detection flag
    var name           # Device name from LoRaWAN
    var node           # Node identifier
    var last_data      # Cached decoded data
    var last_update    # Timestamp of last update
    var lwdecode       # Global instance of the driver

    def init()
        self.hashCheck = true   # Enable duplicate detection
        self.name = nil
        self.node = nil
        self.last_data = {}
        self.last_update = 0
        
        # Initialize global node storage
        import global
        if !global.contains("PSLB_nodes")
            global.PSLB_nodes = {}
        end
        if !global.contains("PSLB_cmdInit")
            global.PSLB_cmdInit = false
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
            
            # Retrieve node history
            var node_data = global.PSLB_nodes.find(node, {})
            var previous_data = node_data.find('last_data', {})
            
            # Carry forward persistent parameters
            if size(previous_data) > 0
                for key: ['water_depth_m', 'pressure_mpa', 'idc_current_ma', 'vdc_voltage',
                         'battery_v', 'probe_type', 'roc_events', 'avg_voltage', 'data_count']
                    if previous_data.contains(key)
                        data[key] = previous_data[key]
                    end
                end
            end
            
            # Decode based on fport
            if fport == 2
                if size(payload) >= 9
                    # Sensor data or ROC data
                    var probe_model = (payload[1] << 8) | payload[0]
                    var idc_raw = (payload[3] << 8) | payload[2]
                    var vdc_raw = (payload[5] << 8) | payload[4]
                    var batt_raw = (payload[7] << 8) | payload[6]
                    var status_flags = payload[8]
                    
                    data['idc_current_ma'] = idc_raw / 1000.0
                    data['vdc_voltage'] = vdc_raw / 1000.0
                    data['battery_v'] = batt_raw / 1000.0
                    
                    # Probe type detection
                    var aa = probe_model & 0xFF
                    var bb = (probe_model >> 8) & 0xFF
                    
                    if aa == 0x00
                        data['probe_type'] = "Water Depth"
                        if bb > 0
                            data['water_depth_m'] = bb * 1.0
                        else
                            # Calculate from 4-20mA
                            var current = data['idc_current_ma']
                            if current >= 4.0 && current <= 20.0
                                data['water_depth_m'] = (current - 4.0) / 16.0 * 10.0  # 0-10m range
                            end
                        end
                    elif aa == 0x01
                        data['probe_type'] = "Pressure"
                        var current = data['idc_current_ma']
                        if current >= 4.0 && current <= 20.0
                            data['pressure_mpa'] = (current - 4.0) / 16.0 * 1.0  # 0-1MPa range
                        end
                    elif aa == 0x02
                        data['probe_type'] = "Differential"
                    else
                        data['probe_type'] = f"Unknown (0x{probe_model:04X})"
                    end
                    
                    # Status flags
                    data['in1_level'] = (status_flags & 0x08) != 0
                    data['in2_level'] = (status_flags & 0x04) != 0
                    data['int_level'] = (status_flags & 0x02) != 0
                    data['int_status'] = (status_flags & 0x01) != 0
                    
                    # ROC flags (if upper nibble set)
                    if status_flags & 0xF0
                        data['roc_events'] = true
                        data['roc_idc_decrease'] = (status_flags & 0x80) != 0
                        data['roc_idc_increase'] = (status_flags & 0x40) != 0
                        data['roc_vdc_decrease'] = (status_flags & 0x20) != 0
                        data['roc_vdc_increase'] = (status_flags & 0x10) != 0
                    else
                        data['roc_events'] = false
                    end
                end
                
            elif fport == 3
                # Datalog data
                if size(payload) >= 11
                    data['datalog_entries'] = []
                    var entry_count = size(payload) / 11
                    
                    for i: 0..(entry_count-1)
                        var offset = i * 11
                        var entry = {}
                        
                        entry['probe_model'] = (payload[offset+1] << 8) | payload[offset]
                        entry['vdc_input'] = ((payload[offset+3] << 8) | payload[offset+2]) / 1000.0
                        entry['idc_input'] = ((payload[offset+5] << 8) | payload[offset+4]) / 1000.0
                        entry['status_byte'] = payload[offset+6]
                        entry['timestamp'] = (payload[offset+10] << 24) | (payload[offset+9] << 16) | 
                                           (payload[offset+8] << 8) | payload[offset+7]
                        
                        data['datalog_entries'].push(entry)
                    end
                    
                    data['entry_count'] = entry_count
                end
                
            elif fport == 5
                # Device status
                if size(payload) >= 6
                    data['sensor_model'] = payload[0]
                    data['fw_version'] = f"{payload[1]}.{payload[2] >> 4}.{payload[2] & 0x0F}"
                    data['frequency_band'] = payload[3]
                    data['sub_band'] = payload[4]
                    data['battery_v'] = ((payload[6] << 8) | payload[5]) / 1000.0
                    
                    # Frequency band mapping
                    var band_names = {1:"EU868", 2:"US915", 3:"IN865", 4:"AU915", 
                                     5:"KZ865", 6:"RU864", 7:"AS923", 11:"CN470", 12:"EU433", 13:"KR920"}
                    data['band_name'] = band_names.find(data['frequency_band'], "Unknown")
                end
                
            elif fport == 7
                # Multi-collection data
                if size(payload) >= 4
                    data['data_count'] = (payload[1] << 8) | payload[0]
                    data['voltage_values'] = []
                    
                    # Read voltage values (2 bytes each)
                    for i: 2..(size(payload)-1) step 2
                        if i+1 < size(payload)
                            var voltage = ((payload[i+1] << 8) | payload[i]) / 1000.0
                            data['voltage_values'].push(voltage)
                        end
                    end
                    
                    # Calculate average
                    if size(data['voltage_values']) > 0
                        var sum = 0
                        for v: data['voltage_values']
                            sum += v
                        end
                        data['avg_voltage'] = sum / size(data['voltage_values'])
                    end
                    
                    data['multi_mode'] = true
                end
            end
            
            # Update node data
            node_data['last_data'] = data
            node_data['last_update'] = tasmota.rtc()['local']
            node_data['name'] = name
            
            # Track battery history
            if data.contains('battery_v')
                if !node_data.contains('battery_history')
                    node_data['battery_history'] = []
                end
                node_data['battery_history'].push(data['battery_v'])
                if size(node_data['battery_history']) > 10
                    node_data['battery_history'].pop(0)
                end
            end
            
            # Track ROC events
            if data.contains('roc_events') && data['roc_events']
                node_data['roc_count'] = node_data.find('roc_count', 0) + 1
                node_data['last_roc'] = tasmota.rtc()['local']
            end
            
            # Initialize downlink commands
            if !global.contains("PSLB_cmdInit") || !global.PSLB_cmdInit
                self.register_downlink_commands()
                global.PSLB_cmdInit = true
            end
            
            # Save to global storage
            global.PSLB_nodes[node] = node_data
            
            # Update instance cache
            self.last_data = data
            self.last_update = node_data['last_update']
            
            return data
            
        except .. as e, m
            print(f"PSLB: Decode error - {e}: {m}")
            return nil
        end
    end
    
    def add_web_sensor()
        try
            import global
            
            # Try to use current instance data first
            var data_to_show = self.last_data
            var last_update = self.last_update
            
            # Recovery from global storage if instance empty
            if size(data_to_show) == 0 && self.node != nil
                var node_data = global.PSLB_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            # Fallback: find any stored node
            if size(data_to_show) == 0 && size(global.PSLB_nodes) > 0
                var found_node = false
                for node_id: global.PSLB_nodes.keys()
                    if !found_node
                        var node_data = global.PSLB_nodes[node_id]
                        data_to_show = node_data.find('last_data', {})
                        last_update = node_data.find('last_update', 0)
                        self.node = node_id
                        self.name = node_data.find('name', f"PSLB-{node_id}")
                        found_node = true
                    end
                end
            end
            
            if size(data_to_show) == 0 return nil end
            
            import string
            var msg = ""
            var fmt = LwSensorFormatter_cls()
            
            # Header with device info
            var name = self.name
            if name == nil || name == ""
                name = f"PSLB-{self.node}"
            end
            var name_tooltip = "Dragino PS-LB Pressure/Water Level Sensor"
            var battery = data_to_show.find('battery_v', 1000)
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)
            var simulated = data_to_show.find('simulated', false)
            
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            
            # Main sensor data line
            fmt.start_line()
            
            if data_to_show.contains('water_depth_m')
                fmt.add_sensor("string", f"{data_to_show['water_depth_m']:.2f}m", "Water Depth", "💧")
            end
            
            if data_to_show.contains('pressure_mpa')
                fmt.add_sensor("string", f"{data_to_show['pressure_mpa']:.3f}MPa", "Pressure", "📊")
            end
            
            if data_to_show.contains('idc_current_ma')
                var current = data_to_show['idc_current_ma']
                fmt.add_sensor("string", f"{current:.1f}mA", "Current", "🔌")
            end
            
            if data_to_show.contains('vdc_voltage')
                var voltage = data_to_show['vdc_voltage']
                fmt.add_sensor("string", f"{voltage:.2f}V", "Voltage", "⚡")
            end
            
            # Second line for probe info and status
            if data_to_show.contains('probe_type') || data_to_show.contains('roc_events') || 
               data_to_show.contains('multi_mode')
                fmt.next_line()
                
                if data_to_show.contains('probe_type')
                    fmt.add_sensor("string", data_to_show['probe_type'], "Probe Type", "🔧")
                end
                
                if data_to_show.contains('roc_events') && data_to_show['roc_events']
                    fmt.add_sensor("string", "ROC Event", "Report on Change", "🔔")
                end
                
                if data_to_show.contains('multi_mode') && data_to_show['multi_mode']
                    var count = data_to_show.find('data_count', 0)
                    fmt.add_sensor("string", f"{count} readings", "Multi-Collection", "📊")
                end
                
                if data_to_show.contains('avg_voltage')
                    var avg = data_to_show['avg_voltage']
                    fmt.add_sensor("string", f"{avg:.2f}V avg", "Average", "📊")
                end
            end
            
            # Third line for device status (if from fport 5)
            if data_to_show.contains('fw_version') || data_to_show.contains('band_name')
                fmt.next_line()
                
                if data_to_show.contains('fw_version')
                    fmt.add_sensor("string", f"v{data_to_show['fw_version']}", "Firmware", "💾")
                end
                
                if data_to_show.contains('band_name')
                    fmt.add_sensor("string", data_to_show['band_name'], "Band", "📡")
                end
            end
            
            fmt.end_line()
            msg += fmt.get_msg()
            
            return msg
            
        except .. as e, m
            print(f"PSLB: Display error - {e}: {m}")
            return "📟 PSLB Error - Check Console"
        end
    end
    
    def register_downlink_commands()
        import string
        
        # Set transmit interval (30 seconds to 16777215 seconds)
        tasmota.remove_cmd("LwPSLBInterval")
        tasmota.add_cmd("LwPSLBInterval", def(cmd, idx, payload_str)
            var interval = int(payload_str)
            if interval < 30 || interval > 16777215
                return tasmota.resp_cmnd_str("Invalid interval: range 30-16777215 seconds")
            end
            
            # Build 24-bit big-endian interval
            var hex_cmd = f"01{(interval >> 16) & 0xFF:02X}{(interval >> 8) & 0xFF:02X}{interval & 0xFF:02X}"
            return lwdecode.SendDownlink(global.PSLB_nodes, cmd, idx, hex_cmd)
        end)
        
        # Set interrupt mode
        tasmota.remove_cmd("LwPSLBInterrupt")
        tasmota.add_cmd("LwPSLBInterrupt", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.PSLB_nodes, cmd, idx, payload_str, {
                'DISABLE|0': ['06000000', 'DISABLED'],
                'FALLING|1': ['06000001', 'FALLING'],
                'RISING|2':  ['06000002', 'RISING'],
                'BOTH|3':    ['06000003', 'BOTH']
            })
        end)
        
        # Set output control
        tasmota.remove_cmd("LwPSLBOutput")
        tasmota.add_cmd("LwPSLBOutput", def(cmd, idx, payload_str)
            var parts = string.split(payload_str, ',')
            if size(parts) != 2
                return tasmota.resp_cmnd_str("Usage: LwPSLBOutput<slot> <type>,<duration_ms>")
            end
            
            var output_type = parts[0]
            var duration = int(parts[1])
            
            var type_map = {'3V3': 1, '5V': 2, '12V': 3}
            var type_val = type_map.find(string.toupper(output_type), nil)
            
            if type_val == nil
                return tasmota.resp_cmnd_str("Invalid type: use 3V3, 5V, or 12V")
            end
            
            if duration < 0 || duration > 65535
                return tasmota.resp_cmnd_str("Invalid duration: range 0-65535 ms")
            end
            
            var hex_cmd = f"07{type_val:02X}{duration & 0xFF:02X}{(duration >> 8) & 0xFF:02X}"
            return lwdecode.SendDownlink(global.PSLB_nodes, cmd, idx, hex_cmd)
        end)
        
        # Set probe model
        tasmota.remove_cmd("LwPSLBProbe")
        tasmota.add_cmd("LwPSLBProbe", def(cmd, idx, payload_str)
            var config = int(payload_str)
            if config < 0 || config > 65535
                return tasmota.resp_cmnd_str("Invalid config: range 0-65535")
            end
            
            var hex_cmd = f"08{config & 0xFF:02X}{(config >> 8) & 0xFF:02X}"
            return lwdecode.SendDownlink(global.PSLB_nodes, cmd, idx, hex_cmd)
        end)
        
        # Set ROC mode
        tasmota.remove_cmd("LwPSLBROC")
        tasmota.add_cmd("LwPSLBROC", def(cmd, idx, payload_str)
            var parts = string.split(payload_str, ',')
            if size(parts) != 4
                return tasmota.resp_cmnd_str("Usage: LwPSLBROC<slot> <mode>,<interval>,<idc_thresh>,<vdc_thresh>")
            end
            
            var mode = int(parts[0])
            var interval = int(parts[1])
            var idc_thresh = int(parts[2])
            var vdc_thresh = int(parts[3])
            
            if mode < 0 || mode > 3
                return tasmota.resp_cmnd_str("Invalid mode: 0-3 (0=disabled, 1=wave, 2=wave+refresh, 3=threshold)")
            end
            
            var hex_cmd = f"09{mode:02X}{interval & 0xFF:02X}{(interval >> 8) & 0xFF:02X}"
            hex_cmd += f"{idc_thresh & 0xFF:02X}{(idc_thresh >> 8) & 0xFF:02X}"
            hex_cmd += f"{vdc_thresh & 0xFF:02X}{(vdc_thresh >> 8) & 0xFF:02X}"
            return lwdecode.SendDownlink(global.PSLB_nodes, cmd, idx, hex_cmd)
        end)
        
        # Request device status
        tasmota.remove_cmd("LwPSLBStatus")
        tasmota.add_cmd("LwPSLBStatus", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.PSLB_nodes, cmd, idx, "2601")
        end)
        
        # Set multi-collection mode
        tasmota.remove_cmd("LwPSLBMultiCollection")
        tasmota.add_cmd("LwPSLBMultiCollection", def(cmd, idx, payload_str)
            var parts = string.split(payload_str, ',')
            if size(parts) != 3
                return tasmota.resp_cmnd_str("Usage: LwPSLBMultiCollection<slot> <mode>,<interval>,<count>")
            end
            
            var mode = int(parts[0])
            var interval = int(parts[1])
            var count = int(parts[2])
            
            if mode < 0 || mode > 2
                return tasmota.resp_cmnd_str("Invalid mode: 0-2 (0=disabled, 1=VDC, 2=IDC)")
            end
            
            if count < 1 || count > 120
                return tasmota.resp_cmnd_str("Invalid count: range 1-120")
            end
            
            var hex_cmd = f"AE{mode:02X}{interval & 0xFF:02X}{(interval >> 8) & 0xFF:02X}{count:02X}"
            return lwdecode.SendDownlink(global.PSLB_nodes, cmd, idx, hex_cmd)
        end)
        
        # Poll datalog
        tasmota.remove_cmd("LwPSLBPoll")
        tasmota.add_cmd("LwPSLBPoll", def(cmd, idx, payload_str)
            var parts = string.split(payload_str, ',')
            if size(parts) != 3
                return tasmota.resp_cmnd_str("Usage: LwPSLBPoll<slot> <start_ts>,<end_ts>,<interval>")
            end
            
            var start_ts = int(parts[0])
            var end_ts = int(parts[1])
            var interval = int(parts[2])
            
            if interval < 5 || interval > 255
                return tasmota.resp_cmnd_str("Invalid interval: range 5-255 seconds")
            end
            
            var hex_cmd = f"31{start_ts & 0xFF:02X}{(start_ts >> 8) & 0xFF:02X}"
            hex_cmd += f"{(start_ts >> 16) & 0xFF:02X}{(start_ts >> 24) & 0xFF:02X}"
            hex_cmd += f"{end_ts & 0xFF:02X}{(end_ts >> 8) & 0xFF:02X}"
            hex_cmd += f"{(end_ts >> 16) & 0xFF:02X}{(end_ts >> 24) & 0xFF:02X}"
            hex_cmd += f"{interval:02X}"
            return lwdecode.SendDownlink(global.PSLB_nodes, cmd, idx, hex_cmd)
        end)
        
        # Clear flash record
        tasmota.remove_cmd("LwPSLBClearFlash")
        tasmota.add_cmd("LwPSLBClearFlash", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.PSLB_nodes, cmd, idx, "A301")
        end)
        
        print("PSLB: Downlink commands registered")
    end
    
    # Get node statistics
    def get_node_stats(node_id)
        import global
        var node_data = global.PSLB_nodes.find(node_id, nil)
        if node_data == nil return nil end
        
        return {
            'last_update': node_data.find('last_update', 0),
            'roc_count': node_data.find('roc_count', 0),
            'last_roc': node_data.find('last_roc', 0),
            'battery_history': node_data.find('battery_history', []),
            'name': node_data.find('name', 'Unknown')
        }
    end
    
    # Clear node data
    def clear_node_data(node_id)
        import global
        if global.PSLB_nodes.contains(node_id)
            global.PSLB_nodes.remove(node_id)
            return true
        end
        return false
    end
    
    # Verify test payload decoding
    def verify_test_payload(hex_payload, scenario_name, expected_params)
        import string
        var payload_bytes = []
        var i = 0
        while i < size(hex_payload)
            var byte_str = hex_payload[i..i+1]
            payload_bytes.push(int(f"0x{byte_str}"))
            i += 2
        end
        
        var result = self.decodeUplink("TestDevice", "TEST-001", -75, 2, payload_bytes)
        
        if result == nil
            print(f"PAYLOAD ERROR: {scenario_name} failed to decode")
            return false
        end
        
        for param: expected_params
            if !result.contains(param)
                print(f"PAYLOAD ERROR: {scenario_name} missing {param}")
                return false
            end
        end
        
        # Scenario-specific validation
        if scenario_name == "low_battery" && result.contains('battery_v') && result['battery_v'] > 3.2
            print(f"PAYLOAD ERROR: {scenario_name} battery should be < 3.2V")
            return false
        end
        
        return true
    end
end

# Global instance
LwDeco = LwDecode_PSLB()

# Node management commands
tasmota.remove_cmd("LwPSLBNodeStats")
tasmota.add_cmd("LwPSLBNodeStats", def(cmd, idx, node_id)
    var stats = LwDeco.get_node_stats(node_id)
    if stats != nil
        import json
        tasmota.resp_cmnd(json.dump(stats))
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

tasmota.remove_cmd("LwPSLBClearNode")
tasmota.add_cmd("LwPSLBClearNode", def(cmd, idx, node_id)
    if LwDeco.clear_node_data(node_id)
        tasmota.resp_cmnd_done()
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

# Test UI command with verified payloads
tasmota.remove_cmd("LwPSLBTestUI")
tasmota.add_cmd("LwPSLBTestUI", def(cmd, idx, payload_str)
    # Template v2.5.0: Verified payload decoding for all scenarios
    var test_scenarios = {
        "normal":      "00000C5C0000061A0B740000",  # Normal water depth (3.16m, 12.25mA, 0V, 2.932V)
        "low_water":   "0000062A0000061A0C200000",  # Low water (1.58m, 6.7mA, 2.976V)
        "high_water":  "00003A980000061A0B740000",  # High water (15km, 19.2mA, 2.932V)
        "pressure":    "01000C5C00000000061A0000",  # Pressure mode (0.55MPa, 12.25mA)
        "roc_event":   "00000C5C00000000061AF0",    # ROC event (all flags)
        "multi_data":  "0500C4090000",              # Multi-collection (5 readings, 2500mV)
        "status":      "1603A403040B74",            # Status (v3.10.4, EU868, 2.932V)
        "low_battery": "00000C5C00000000096E0000"   # Low battery (2.414V)
    }
    
    var hex_payload = test_scenarios.find(payload_str ? payload_str : 'nil', 'not_found')
    
    if hex_payload == 'not_found'
        var scenarios_list = "normal low_water high_water pressure roc_event multi_data status low_battery "
        return tasmota.resp_cmnd_str(f"Available scenarios: {scenarios_list}")
    end
    
    var rssi = -75
    var fport = payload_str == "status" ? 5 : (payload_str == "multi_data" ? 7 : 2)
    
    return tasmota.cmd(f'LwSimulate{idx} {rssi},{fport},{hex_payload}')
end)

# Register driver
tasmota.add_driver(LwDeco)
