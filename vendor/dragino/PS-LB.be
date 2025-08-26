#
# LoRaWAN AI-Generated Decoder for Dragino PS-LB Prompted by ZioFabry
#
# Generated: 2025-08-26 | Version: 2.0.0 | Revision: 1
#            by "LoRaWAN Decoder AI Generation Template", v2.3.6
#
# Homepage:  https://wiki.dragino.com/xwiki/bin/view/Main/User%20Manual%20for%20LoRaWAN%20End%20Nodes/PS-LB%20--%20LoRaWAN%20Pressure%20Sensor/
# Userguide: PS-LB_LoRaWAN_Pressure_Sensor_UserManual
# Decoder:   Official Dragino Decoder
# 
# v2.0.0 (2025-08-26): Framework v2.2.9 + Template v2.3.6 major upgrade with enhanced error handling
# v1.1.0 (2025-08-16): Pressure/water level sensor with probe detection

class LwDecode_PSLB
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
        if !global.contains("PSLB_nodes")
            global.PSLB_nodes = {}
        end
        if !global.contains("PSLB_cmdInit")
            global.PSLB_cmdInit = false
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
            var node_data = global.PSLB_nodes.find(node, {})
            
            if fport == 5  # Device Status
                if size(payload) >= 6
                    # Sensor model (byte 0)
                    data['sensor_model'] = payload[0]
                    if payload[0] == 0x16
                        data['model_name'] = "PS-LB/LS"
                    end
                    
                    # Firmware version (bytes 1-2, little endian)
                    var fw_raw = (payload[2] << 8) | payload[1]
                    data['fw_version'] = f"v{(fw_raw >> 8) & 0xFF}.{fw_raw & 0xFF}"
                    
                    # Frequency band (byte 3)
                    var bands = {
                        1: "EU868", 2: "US915", 3: "IN865", 4: "AU915", 5: "KZ865",
                        6: "RU864", 7: "AS923", 8: "AS923-1", 9: "AS923-2", 10: "AS923-3",
                        11: "CN470", 12: "EU433", 13: "KR920", 14: "MA869"
                    }
                    data['frequency_band'] = bands.find(payload[3], f"Unknown({payload[3]})")
                    
                    # Sub-band (byte 4)
                    data['sub_band'] = payload[4]
                    
                    # Battery voltage (bytes 4-5, little endian)
                    var battery_mv = (payload[5] << 8) | payload[4]
                    data['battery_v'] = battery_mv / 1000.0
                    data['battery_mv'] = battery_mv
                end
                
            elif fport == 2  # Sensor Value or ROC Data
                if size(payload) >= 9
                    # Probe model (bytes 0-1, little endian)
                    var probe_model = (payload[1] << 8) | payload[0]
                    data['probe_model'] = f"0x{probe_model:04X}"
                    data['probe_aa'] = payload[0]
                    data['probe_bb'] = payload[1]
                    
                    # Decode probe type
                    if payload[0] == 0x00
                        data['probe_type'] = f"Water Depth ({payload[1]}m range)"
                    elif payload[0] == 0x01
                        data['probe_type'] = f"Pressure (Type {payload[1]})"
                    elif payload[0] == 0x02
                        data['probe_type'] = f"Differential (Range {payload[1]})"
                    else
                        data['probe_type'] = f"Unknown Type (aa={payload[0]}, bb={payload[1]})"
                    end
                    
                    # IDC Input (bytes 2-3, little endian) - 4-20mA current
                    var idc_raw = (payload[3] << 8) | payload[2]
                    data['idc_current_ma'] = idc_raw / 1000.0
                    
                    # VDC Input (bytes 4-5, little endian) - 0-30V voltage
                    var vdc_raw = (payload[5] << 8) | payload[4]
                    data['vdc_voltage'] = vdc_raw / 1000.0
                    
                    # Convert current to pressure/depth based on probe type
                    if payload[0] == 0x00  # Water depth
                        var depth_range = payload[1]
                        data['water_depth_m'] = (data['idc_current_ma'] - 4) * depth_range / 16.0
                        if data['water_depth_m'] < 0 data['water_depth_m'] = 0.0 end
                    elif payload[0] == 0x01  # Pressure
                        # Convert 4-20mA to pressure (example for 0-1MPa range)
                        data['pressure_mpa'] = (data['idc_current_ma'] - 4) / 16.0
                        if data['pressure_mpa'] < 0 data['pressure_mpa'] = 0.0 end
                    end
                    
                    # Battery voltage (bytes 6-7, little endian)
                    var battery_mv = (payload[7] << 8) | payload[6]
                    data['battery_v'] = battery_mv / 1000.0
                    
                    # Status flags (byte 8)
                    var status = payload[8]
                    data['in1_level'] = (status & 0x08) != 0
                    data['in2_level'] = (status & 0x04) != 0
                    data['int_level'] = (status & 0x02) != 0
                    data['int_status'] = (status & 0x01) != 0
                    
                    # Check for ROC flags (upper nibble)
                    var roc_flags = (status >> 4) & 0x0F
                    if roc_flags != 0
                        data['roc_mode'] = true
                        data['idc_decrease'] = (roc_flags & 0x08) != 0
                        data['idc_increase'] = (roc_flags & 0x04) != 0
                        data['vdc_decrease'] = (roc_flags & 0x02) != 0
                        data['vdc_increase'] = (roc_flags & 0x01) != 0
                        
                        var roc_events = []
                        if data['idc_decrease'] roc_events.push("IDC↓") end
                        if data['idc_increase'] roc_events.push("IDC↑") end
                        if data['vdc_decrease'] roc_events.push("VDC↓") end
                        if data['vdc_increase'] roc_events.push("VDC↑") end
                        
                        data['roc_events'] = string.join(roc_events, ",")
                    end
                end
                
            elif fport == 7  # Multiple Sensor Data
                if size(payload) >= 2
                    var data_count = (payload[1] << 8) | payload[0]
                    data['data_count'] = data_count
                    data['multi_mode'] = true
                    
                    var voltage_values = []
                    var i = 2
                    while i < size(payload) - 1 && size(voltage_values) < data_count
                        var voltage = ((payload[i+1] << 8) | payload[i]) / 1000.0
                        voltage_values.push(voltage)
                        i += 2
                    end
                    
                    data['voltage_values'] = voltage_values
                    if size(voltage_values) > 0
                        data['avg_voltage'] = self.calculate_average(voltage_values)
                        data['min_voltage'] = self.find_minimum(voltage_values)
                        data['max_voltage'] = self.find_maximum(voltage_values)
                    end
                end
                
            elif fport == 3  # Datalog Data
                if size(payload) >= 11
                    data['datalog_mode'] = true
                    var entries = []
                    
                    var i = 0
                    while i <= size(payload) - 11
                        var entry = {}
                        entry['probe_model'] = (payload[i+1] << 8) | payload[i]
                        entry['vdc_voltage'] = ((payload[i+3] << 8) | payload[i+2]) / 1000.0
                        entry['idc_current_ma'] = ((payload[i+5] << 8) | payload[i+4]) / 1000.0
                        entry['status'] = payload[i+6]
                        entry['timestamp'] = (payload[i+10] << 24) | (payload[i+9] << 16) | (payload[i+8] << 8) | payload[i+7]
                        entry['time_readable'] = self.format_timestamp(entry['timestamp'])
                        
                        entries.push(entry)
                        i += 11
                    end
                    
                    data['datalog_entries'] = entries
                    data['entry_count'] = size(entries)
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
            
            # Store pressure/depth trends
            if data.contains('water_depth_m')
                if !node_data.contains('depth_history')
                    node_data['depth_history'] = []
                end
                node_data['depth_history'].push(data['water_depth_m'])
                if size(node_data['depth_history']) > 10
                    node_data['depth_history'].pop(0)
                end
            end
            
            if data.contains('pressure_mpa')
                if !node_data.contains('pressure_history')
                    node_data['pressure_history'] = []
                end
                node_data['pressure_history'].push(data['pressure_mpa'])
                if size(node_data['pressure_history']) > 10
                    node_data['pressure_history'].pop(0)
                end
            end
            
            # Track ROC events
            if data.contains('roc_mode') && data['roc_mode']
                node_data['roc_event_count'] = node_data.find('roc_event_count', 0) + 1
                node_data['last_roc_event'] = tasmota.rtc()['local']
            end
            
            # Initialize downlink commands once
            if !global.contains("PSLB_cmdInit") || !global.PSLB_cmdInit
                self.register_downlink_commands()
                global.PSLB_cmdInit = true
            end

            # Save back to global storage
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
        import global
        
        try
            # Try to use current instance data first
            var data_to_show = self.last_data
            var last_update = self.last_update
            
            # If no instance data, try to recover from global storage
            if size(data_to_show) == 0 && self.node != nil
                var node_data = global.PSLB_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            # Fallback: find ANY stored node if no specific node
            if size(data_to_show) == 0 && size(global.PSLB_nodes) > 0
                for node_id: global.PSLB_nodes.keys()
                    var node_data = global.PSLB_nodes[node_id]
                    data_to_show = node_data.find('last_data', {})
                    last_update = node_data.find('last_update', 0)
                    self.node = node_id  # Update instance
                    self.name = node_data.find('name', f"PSLB-{node_id}")
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
                name = f"PSLB-{self.node}"
            end
            var name_tooltip = "Dragino PS-LB Pressure/Water Level Sensor"
            var battery = data_to_show.find('battery_v', 1000)
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)
            var simulated = data_to_show.find('simulated', false)
            
            # Build display using emoji formatter
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            
            fmt.start_line()
            
            # Main measurements
            if data_to_show.contains('water_depth_m')
                fmt.add_sensor("string", f"{data_to_show['water_depth_m']:.2f}m", "Water Depth", "💧")
            elif data_to_show.contains('pressure_mpa')
                fmt.add_sensor("string", f"{data_to_show['pressure_mpa']:.3f}MPa", "Pressure", "📊")
            end
            
            # Current and voltage
            if data_to_show.contains('idc_current_ma')
                fmt.add_sensor("milliamp", data_to_show['idc_current_ma'], "Current", "🔌")
            end
            
            if data_to_show.contains('vdc_voltage')
                fmt.add_sensor("volt", data_to_show['vdc_voltage'], "Voltage", "⚡")
            end
            
            # Battery (if not already in header)
            if data_to_show.contains('battery_v') && battery >= 1000
                fmt.add_sensor("volt", data_to_show['battery_v'], "Battery", "🔋")
            end
            
            # Probe and device info line
            var has_info_line = false
            if data_to_show.contains('probe_type') || data_to_show.contains('model_name') || data_to_show.contains('fw_version')
                fmt.next_line()
                has_info_line = true
                
                if data_to_show.contains('probe_type')
                    var probe_short = data_to_show['probe_type']
                    # Shorten probe type for display
                    if string.find(probe_short, "Water Depth") >= 0
                        probe_short = f"Depth{data_to_show['probe_bb']}m"
                    elif string.find(probe_short, "Pressure") >= 0
                        probe_short = f"Press T{data_to_show['probe_bb']}"
                    elif string.find(probe_short, "Differential") >= 0
                        probe_short = f"Diff R{data_to_show['probe_bb']}"
                    end
                    fmt.add_status(probe_short, "🔧", data_to_show['probe_type'])
                end
                
                if data_to_show.contains('model_name')
                    fmt.add_status(data_to_show['model_name'], "📟", "Device Model")
                end
                
                if data_to_show.contains('fw_version')
                    fmt.add_status(data_to_show['fw_version'], "💾", "Firmware Version")
                end
            end
            
            # Multi-data or ROC status line
            var has_status_line = false
            if data_to_show.contains('multi_mode') || data_to_show.contains('roc_events') || data_to_show.contains('datalog_mode')
                if !has_info_line
                    fmt.next_line()
                else
                    fmt.next_line()
                end
                has_status_line = true
                
                if data_to_show.contains('multi_mode')
                    fmt.add_status(f"Multi({data_to_show['data_count']})", "📊", "Multi-collection mode")
                    
                    if data_to_show.contains('avg_voltage')
                        fmt.add_status(f"Avg{data_to_show['avg_voltage']:.2f}V", "📈", "Average voltage")
                    end
                    
                elif data_to_show.contains('roc_events')
                    fmt.add_status("ROC", "🔔", "Report on Change")
                    fmt.add_status(data_to_show['roc_events'], "📊", "ROC Events")
                    
                elif data_to_show.contains('datalog_mode')
                    fmt.add_status(f"Log({data_to_show['entry_count']})", "💾", "Datalog entries")
                end
                
                # Digital input status
                if data_to_show.contains('in1_level')
                    var in1_icon = data_to_show['in1_level'] ? "🟢" : "⚫"
                    fmt.add_status(f"IN1", in1_icon, f"Input 1: {data_to_show['in1_level'] ? 'High' : 'Low'}")
                end
                
                if data_to_show.contains('int_status') && data_to_show['int_status']
                    fmt.add_status("INT", "🔔", "Interrupt triggered")
                end
            end
            
            fmt.end_line()
            
            # ONLY get_msg() return a string that can be used with +=
            msg += fmt.get_msg()

            return msg
            
        except .. as e, m
            print(f"PSLB: Display error - {e}: {m}")
            return "📟 PS-LB Error - Check Console"
        end
    end
    
    def calculate_average(values)
        if size(values) == 0 return 0.0 end
        var sum = 0.0
        for value : values
            sum += value
        end
        return sum / size(values)
    end
    
    def find_minimum(values)
        if size(values) == 0 return 0.0 end
        var min_val = values[0]
        for value : values
            if value < min_val min_val = value end
        end
        return min_val
    end
    
    def find_maximum(values)
        if size(values) == 0 return 0.0 end
        var max_val = values[0]
        for value : values
            if value > max_val max_val = value end
        end
        return max_val
    end
    
    def format_timestamp(ts)
        if ts == 0 || ts == nil return "Unknown" end
        
        var rtc = tasmota.rtc()
        var diff = rtc['local'] - ts
        
        if diff < 0 diff = -diff end
        
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
        var node_data = global.PSLB_nodes.find(node_id, nil)
        if node_data == nil return nil end
        
        return {
            'last_update': node_data.find('last_update', 0),
            'battery_history': node_data.find('battery_history', []),
            'depth_history': node_data.find('depth_history', []),
            'pressure_history': node_data.find('pressure_history', []),
            'roc_event_count': node_data.find('roc_event_count', 0),
            'last_roc_event': node_data.find('last_roc_event', 0),
            'name': node_data.find('name', 'Unknown')
        }
    end
    
    # Clear node data (for maintenance)
    def clear_node_data(node_id)
        import global
        if global.PSLB_nodes.contains(node_id)
            global.PSLB_nodes.remove(node_id)
            return true
        end
        return false
    end
    
    # Register downlink commands for device control
    def register_downlink_commands()
        import string
        
        # Set Transmit Interval
        tasmota.remove_cmd("LwPSLBInterval")
        tasmota.add_cmd("LwPSLBInterval", def(cmd, idx, payload_str)
            # Format: LwPSLBInterval<slot> <seconds>
            var seconds = int(payload_str)
            if seconds < 30 || seconds > 16777215
                return tasmota.resp_cmnd_str("Invalid: range 30-16777215 seconds")
            end
            
            # Build hex command (24-bit big endian)
            var hex_cmd = f"01{(seconds >> 16) & 0xFF:02X}{(seconds >> 8) & 0xFF:02X}{seconds & 0xFF:02X}"
            return lwdecode.SendDownlink(global.PSLB_nodes, cmd, idx, hex_cmd)
        end)
        
        # Set Interrupt Mode
        tasmota.remove_cmd("LwPSLBInterrupt")
        tasmota.add_cmd("LwPSLBInterrupt", def(cmd, idx, payload_str)
            # Format: LwPSLBInterrupt<slot> <disable|falling|rising|both>
            var modes = {
                'DISABLE': 0,
                'FALLING': 1,
                'RISING': 2,
                'BOTH': 3
            }
            var mode = modes.find(string.toupper(payload_str), nil)
            if mode == nil
                return tasmota.resp_cmnd_str("Invalid mode: disable|falling|rising|both")
            end
            
            var hex_cmd = f"06{(mode >> 16) & 0xFF:02X}{(mode >> 8) & 0xFF:02X}{mode & 0xFF:02X}"
            return lwdecode.SendDownlink(global.PSLB_nodes, cmd, idx, hex_cmd)
        end)
        
        # Set Output Control
        tasmota.remove_cmd("LwPSLBOutput")
        tasmota.add_cmd("LwPSLBOutput", def(cmd, idx, payload_str)
            # Format: LwPSLBOutput<slot> <3v3|5v|12v>,<duration_ms>
            var parts = string.split(payload_str, ',')
            if size(parts) != 2
                return tasmota.resp_cmnd_str("Usage: LwPSLBOutput<slot> <3v3|5v|12v>,<duration>")
            end
            
            var output_types = { '3V3': 1, '5V': 2, '12V': 3 }
            var output_type = output_types.find(string.toupper(parts[0]), nil)
            if output_type == nil
                return tasmota.resp_cmnd_str("Invalid output: 3v3|5v|12v")
            end
            
            var duration = int(parts[1])
            if duration < 0 || duration > 65535
                return tasmota.resp_cmnd_str("Invalid duration: range 0-65535ms")
            end
            
            var hex_cmd = f"07{output_type:02X}{lwdecode.uint16le(duration)}"
            return lwdecode.SendDownlink(global.PSLB_nodes, cmd, idx, hex_cmd)
        end)
        
        # Set Probe Model
        tasmota.remove_cmd("LwPSLBProbe")
        tasmota.add_cmd("LwPSLBProbe", def(cmd, idx, payload_str)
            # Format: LwPSLBProbe<slot> <probe_config_hex>
            var probe_config = int(f"0x{payload_str}")
            if probe_config < 0 || probe_config > 65535
                return tasmota.resp_cmnd_str("Invalid config: use hex format (e.g., 0100)")
            end
            
            var hex_cmd = f"08{lwdecode.uint16le(probe_config)}"
            return lwdecode.SendDownlink(global.PSLB_nodes, cmd, idx, hex_cmd)
        end)
        
        # Set ROC Mode
        tasmota.remove_cmd("LwPSLBROC")
        tasmota.add_cmd("LwPSLBROC", def(cmd, idx, payload_str)
            # Format: LwPSLBROC<slot> <mode>,<interval>,<idc_threshold>,<vdc_threshold>
            var parts = string.split(payload_str, ',')
            if size(parts) != 4
                return tasmota.resp_cmnd_str("Usage: LwPSLBROC<slot> <mode>,<interval>,<idc_uA>,<vdc_mV>")
            end
            
            var mode = int(parts[0])
            var interval = int(parts[1])
            var idc_threshold = int(parts[2])
            var vdc_threshold = int(parts[3])
            
            if mode < 0 || mode > 3
                return tasmota.resp_cmnd_str("Invalid mode: 0=disable, 1=wave, 2=wave+TDC, 3=threshold")
            end
            
            var hex_cmd = f"09{mode:02X}{lwdecode.uint16le(interval)}{lwdecode.uint16le(idc_threshold)}{lwdecode.uint16le(vdc_threshold)}"
            return lwdecode.SendDownlink(global.PSLB_nodes, cmd, idx, hex_cmd)
        end)
        
        # Request Device Status
        tasmota.remove_cmd("LwPSLBStatus")
        tasmota.add_cmd("LwPSLBStatus", def(cmd, idx, payload_str)
            # Format: LwPSLBStatus<slot>
            var hex_cmd = "2601"
            return lwdecode.SendDownlink(global.PSLB_nodes, cmd, idx, hex_cmd)
        end)
        
        # Set Multi-Collection Mode
        tasmota.remove_cmd("LwPSLBMultiCollection")
        tasmota.add_cmd("LwPSLBMultiCollection", def(cmd, idx, payload_str)
            # Format: LwPSLBMultiCollection<slot> <mode>,<interval>,<count>
            var parts = string.split(payload_str, ',')
            if size(parts) != 3
                return tasmota.resp_cmnd_str("Usage: LwPSLBMultiCollection<slot> <0|1|2>,<interval>,<count>")
            end
            
            var mode = int(parts[0])
            var interval = int(parts[1])
            var count = int(parts[2])
            
            if mode < 0 || mode > 2
                return tasmota.resp_cmnd_str("Invalid mode: 0=disable, 1=VDC, 2=IDC")
            end
            if count < 1 || count > 120
                return tasmota.resp_cmnd_str("Invalid count: range 1-120")
            end
            
            var hex_cmd = f"AE{mode:02X}{lwdecode.uint16le(interval)}{count:02X}"
            return lwdecode.SendDownlink(global.PSLB_nodes, cmd, idx, hex_cmd)
        end)
        
        # Poll Datalog
        tasmota.remove_cmd("LwPSLBPoll")
        tasmota.add_cmd("LwPSLBPoll", def(cmd, idx, payload_str)
            # Format: LwPSLBPoll<slot> <start_ts>,<end_ts>,<interval>
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
            
            var hex_cmd = f"31{lwdecode.uint32le(start_ts)}{lwdecode.uint32le(end_ts)}{interval:02X}"
            return lwdecode.SendDownlink(global.PSLB_nodes, cmd, idx, hex_cmd)
        end)
        
        # Clear Flash Record
        tasmota.remove_cmd("LwPSLBClearFlash")
        tasmota.add_cmd("LwPSLBClearFlash", def(cmd, idx, payload_str)
            # Format: LwPSLBClearFlash<slot>
            var hex_cmd = "A301"
            return lwdecode.SendDownlink(global.PSLB_nodes, cmd, idx, hex_cmd)
        end)
        
        print("PSLB: Downlink commands registered")
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

# Test UI command
tasmota.remove_cmd("LwPSLBTestUI")
tasmota.add_cmd("LwPSLBTestUI", def(cmd, idx, payload_str)
    # Predefined realistic test scenarios for UI development
    var test_scenarios = {
        "normal":        "0005C43E5C13C00E08",    # Water depth: 5m range, 16.0mA (3.0m), 5.0V, 3776mV, normal status
        "low_water":     "0005580B5C13C00E08",    # Water depth: 5m range, 4.2mA (0.3m), 5.0V, 3776mV, normal status  
        "high_water":    "000570175C13C00E08",    # Water depth: 5m range, 19.0mA (4.7m), 5.0V, 3776mV, normal status
        "pressure":      "01019C405C13C00E08",    # Pressure: Type 1, 16.5mA (0.78MPa), 5.0V, 3776mV, normal status
        "roc_event":     "0005C43E5C13C00EF8",    # ROC: same as normal but with ROC flags (IDC increase + VDC increase)
        "low_battery":   "0005C43E5C13800A08",    # Low battery: same readings but 2688mV battery
        "multi_data":    "050058022C0164014B0196027D02", # Multi-mode: 5 readings, various voltages
        "status":        "1610000101B80B",       # Device status: Model 0x16, FW v1.0, EU868, sub 1, 3000mV
        "datalog":       "0005C43E5C13004A7B6F660105D04E5C13804A7B6F66" # Datalog: 2 entries with timestamps
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
    elif payload_str == "multi_data"
        fport = 7
    elif payload_str == "datalog"
        fport = 3
    end

    return tasmota.cmd(f'LwSimulate{idx} {rssi},{fport},{hex_payload}')
end)

# MANDATORY: Register driver for web UI integration
tasmota.add_driver(LwDeco)
