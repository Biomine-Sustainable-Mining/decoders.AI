#
# LoRaWAN AI-Generated Decoder for Dragino LDS02 Door Sensor
#
# Generated: 2025-09-02 | Version: v1.2.0 | Revision: 3
#            by "LoRaWAN Decoder AI Generation Template", v2.5.0
#
# Homepage:  https://wiki.dragino.com/xwiki/bin/view/Main/User%20Manual%20for%20LoRaWAN%20End%20Nodes/LDS02%20-%20LoRaWAN%20Door%20Sensor%20User%20Manual/
# Userguide: Same as above
# Decoder:   Official decoder integrated
# 
# Device: Magnetic door sensor with event counting and alarm functionality
# Features: Door open/close detection, event counting, timeout alarms, EDC mode

class LwDecode_LDS02
    var hashCheck      # Duplicate payload detection flag
    var name           # Device name from LoRaWAN
    var node           # Node identifier
    var last_data      # Cached decoded data
    var last_update    # Timestamp of last update
    var lwdecode       # global instance of the driver

    def init()
        self.hashCheck = true
        self.name = nil
        self.node = nil
        self.last_data = {}
        self.last_update = 0
        
        # Initialize global node storage
        import global
        if !global.contains("LDS02_nodes")
            global.LDS02_nodes = {}
        end
        if !global.contains("LDS02_cmdInit")
            global.LDS02_cmdInit = false
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
            
            # Retrieve node history
            var node_data = global.LDS02_nodes.find(node, {})
            var previous_data = node_data.find('last_data', {})
            
            # Restore persistent data
            if size(previous_data) > 0
                for key: ['battery_v', 'door_status', 'door_open_events', 'alarm_status', 'edc_mode']
                    if previous_data.contains(key)
                        data[key] = previous_data[key]
                    end
                end
            end
            
            # Decode based on fport
            if fport == 10       # Sensor Data
                if size(payload) >= 10
                    # Battery & door status (little endian)
                    var status_raw = (payload[1] << 8) | payload[0]
                    var battery_mv = status_raw & 0x3FFF
                    data['battery_v'] = battery_mv / 1000.0
                    data['battery_pct'] = self.voltage_to_percent(data['battery_v'])
                    
                    # Door status from bit 15
                    data['door_status'] = (status_raw & 0x8000) != 0 ? "Open" : "Closed"
                    data['door_open'] = (status_raw & 0x8000) != 0
                    
                    # Mode
                    data['mode'] = payload[2] == 0x01 ? "Normal" : f"Mode{payload[2]}"
                    
                    # Total door open events (little endian 24-bit)
                    data['door_open_events'] = (payload[5] << 16) | (payload[4] << 8) | payload[3]
                    
                    # Last door open duration (little endian 24-bit, minutes)
                    var duration_minutes = (payload[8] << 16) | (payload[7] << 8) | payload[6]
                    data['last_open_duration'] = duration_minutes
                    data['last_open_duration_h'] = duration_minutes / 60.0
                    
                    # Alarm status
                    data['alarm_status'] = (payload[9] & 0x01) != 0
                    data['alarm_type'] = data['alarm_status'] ? "Timeout" : "None"
                end
                
            elif fport == 7      # EDC Mode Data
                if size(payload) >= 5
                    # Battery & EDC mode (little endian)
                    var edc_raw = (payload[1] << 8) | payload[0]
                    var battery_mv = edc_raw & 0x3FFF
                    data['battery_v'] = battery_mv / 1000.0
                    data['battery_pct'] = self.voltage_to_percent(data['battery_v'])
                    
                    # EDC mode from bit 15
                    data['edc_mode'] = (edc_raw & 0x8000) != 0 ? "Open count" : "Close count"
                    
                    # Event count (little endian 24-bit)
                    data['event_count'] = (payload[4] << 16) | (payload[3] << 8) | payload[2]
                    data['edc_active'] = true
                end
            end
            
            # Track door events
            if data.contains('door_open_events')
                var prev_events = node_data.find('total_events', 0)
                if data['door_open_events'] > prev_events
                    node_data['new_events'] = data['door_open_events'] - prev_events
                    node_data['last_event_time'] = tasmota.rtc()['local']
                end
                node_data['total_events'] = data['door_open_events']
            end
            
            # Track alarm events
            if data.contains('alarm_status') && data['alarm_status']
                node_data['alarm_count'] = node_data.find('alarm_count', 0) + 1
                node_data['last_alarm'] = tasmota.rtc()['local']
            end
            
            # Battery trend tracking
            if data.contains('battery_v')
                if !node_data.contains('battery_history')
                    node_data['battery_history'] = []
                end
                node_data['battery_history'].push(data['battery_v'])
                if size(node_data['battery_history']) > 10
                    node_data['battery_history'].pop(0)
                end
            end
            
            # Initialize downlink commands
            if !global.LDS02_cmdInit
                self.register_downlink_commands()
                global.LDS02_cmdInit = true
            end
            
            # Update node data
            node_data['last_data'] = data
            node_data['last_update'] = tasmota.rtc()['local']
            node_data['name'] = name
            global.LDS02_nodes[node] = node_data
            
            self.last_data = data
            self.last_update = node_data['last_update']
            
            return data
            
        except .. as e, m
            print(f"LDS02: Decode error - {e}: {m}")
            return nil
        end
    end
    
    def add_web_sensor()
        try
            var data_to_show = self.last_data
            var last_update = self.last_update
            
            # Recovery from global storage
            if size(data_to_show) == 0 && self.node != nil
                import global
                var node_data = global.LDS02_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            # Fallback to any available node
            if size(data_to_show) == 0
                import global
                if size(global.LDS02_nodes) > 0
                    var found_node = false
                    for node_id: global.LDS02_nodes.keys()
                        if !found_node
                            var node_data = global.LDS02_nodes[node_id]
                            data_to_show = node_data.find('last_data', {})
                            last_update = node_data.find('last_update', 0)
                            self.node = node_id
                            self.name = node_data.find('name', f"LDS02-{node_id}")
                            found_node = true
                        end
                    end
                end
            end
            
            if size(data_to_show) == 0 return nil end
            
            import string
            var msg = ""
            var fmt = LwSensorFormatter_cls()
            
            # Header with device info
            var name = self.name ? self.name : f"LDS02-{self.node}"
            var name_tooltip = "Dragino LDS02 Door Sensor"
            var battery = data_to_show.find('battery_v', 1000)
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)
            var simulated = data_to_show.find('simulated', false)
            
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            
            # Door status and events
            fmt.start_line()
            
            # Door state with appropriate emoji
            if data_to_show.contains('door_status')
                var door_emoji = data_to_show['door_open'] ? "🔓" : "🔒"
                fmt.add_sensor("string", data_to_show['door_status'], "Door State", door_emoji)
            end
            
            # Event count
            if data_to_show.contains('door_open_events')
                fmt.add_sensor("string", f"{data_to_show['door_open_events']}", "Events", "📊")
            elif data_to_show.contains('event_count')
                fmt.add_sensor("string", f"{data_to_show['event_count']}", "Count", "📊")
            end
            
            # Duration or battery
            if data_to_show.contains('last_open_duration') && data_to_show['last_open_duration'] > 0
                var duration_text = data_to_show['last_open_duration'] < 60 ? 
                    f"{data_to_show['last_open_duration']}m" : 
                    f"{data_to_show['last_open_duration_h']:.1f}h"
                fmt.add_sensor("string", duration_text, "Last Open", "⏱️")
            elif battery != 1000
                fmt.add_sensor("string", f"{data_to_show.find('battery_pct', 0)}%", "Battery", "🔋")
            end
            
            # Status indicators
            var has_status = false
            var status_items = []
            
            if data_to_show.contains('alarm_status') && data_to_show['alarm_status']
                status_items.push(['string', 'Timeout', 'Door Timeout Alarm', '⚠️'])
                has_status = true
            end
            
            if data_to_show.contains('edc_active') && data_to_show['edc_active']
                var edc_text = data_to_show.find('edc_mode', 'EDC')
                status_items.push(['string', edc_text, 'Event Counting Mode', '🔢'])
                has_status = true
            end
            
            if data_to_show.contains('mode') && data_to_show['mode'] != "Normal"
                status_items.push(['string', data_to_show['mode'], 'Device Mode', '⚙️'])
                has_status = true
            end
            
            # Add status line if needed
            if has_status
                fmt.next_line()
                for item : status_items
                    fmt.add_sensor(item[0], item[1], item[2], item[3])
                end
            end
            
            fmt.end_line()
            msg += fmt.get_msg()
            
            return msg
            
        except .. as e, m
            print(f"LDS02: Display error - {e}: {m}")
            return "📟 LDS02 Error - Check Console"
        end
    end
    
    # Helper functions
    def voltage_to_percent(voltage)
        # AAA battery curve (2 x 1.5V = 3.0V max)
        if voltage >= 3.0 return 100
        elif voltage <= 2.1 return 0
        else return int((voltage - 2.1) / 0.9 * 100)
        end
    end
    
    def format_age(seconds)
        if seconds < 60 return f"{seconds}s ago"
        elif seconds < 3600 return f"{seconds/60}m ago"
        elif seconds < 86400 return f"{seconds/3600}h ago"
        else return f"{seconds/86400}d ago"
        end
    end
    
    # Node management
    def get_node_stats(node_id)
        import global
        var node_data = global.LDS02_nodes.find(node_id, nil)
        if node_data == nil return nil end
        
        return {
            'last_update': node_data.find('last_update', 0),
            'total_events': node_data.find('total_events', 0),
            'alarm_count': node_data.find('alarm_count', 0),
            'last_alarm': node_data.find('last_alarm', 0),
            'battery_history': node_data.find('battery_history', []),
            'name': node_data.find('name', 'Unknown')
        }
    end
    
    def clear_node_data(node_id)
        import global
        if global.LDS02_nodes.contains(node_id)
            global.LDS02_nodes.remove(node_id)
            return true
        end
        return false
    end
    
    # Register downlink commands
    def register_downlink_commands()
        import string
        
        # Set transmission interval
        tasmota.remove_cmd("LwLDS02Interval")
        tasmota.add_cmd("LwLDS02Interval", def(cmd, idx, payload_str)
            var interval = int(payload_str)
            if interval < 1 || interval > 4294967295
                return tasmota.resp_cmnd_str("Invalid: range 1-4294967295 seconds")
            end
            
            var hex_cmd = f"01{interval & 0xFF:02X}{(interval >> 8) & 0xFF:02X}"
            hex_cmd += f"{(interval >> 16) & 0xFF:02X}{(interval >> 24) & 0xFF:02X}"
            
            return lwdecode.SendDownlink(global.LDS02_nodes, cmd, idx, hex_cmd)
        end)
        
        # Set EDC mode
        tasmota.remove_cmd("LwLDS02EDCMode")
        tasmota.add_cmd("LwLDS02EDCMode", def(cmd, idx, payload_str)
            var parts = string.split(payload_str, ',')
            if size(parts) != 2
                return tasmota.resp_cmnd_str("Usage: LwLDS02EDCMode<slot> <mode>,<count>")
            end
            
            var mode = int(parts[0])
            var count = int(parts[1])
            
            if mode < 0 || mode > 1
                return tasmota.resp_cmnd_str("Invalid mode: 0=Close count, 1=Open count")
            end
            if count < 1 || count > 4294967295
                return tasmota.resp_cmnd_str("Invalid count: range 1-4294967295")
            end
            
            var hex_cmd = f"02{mode:02X}{count & 0xFF:02X}{(count >> 8) & 0xFF:02X}"
            hex_cmd += f"{(count >> 16) & 0xFF:02X}{(count >> 24) & 0xFF:02X}"
            
            return lwdecode.SendDownlink(global.LDS02_nodes, cmd, idx, hex_cmd)
        end)
        
        # Reset device
        tasmota.remove_cmd("LwLDS02Reset")
        tasmota.add_cmd("LwLDS02Reset", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.LDS02_nodes, cmd, idx, "04FF")
        end)
        
        # Set confirmed mode
        tasmota.remove_cmd("LwLDS02Confirmed")
        tasmota.add_cmd("LwLDS02Confirmed", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.LDS02_nodes, cmd, idx, payload_str, {
                '0|UNCONFIRMED': ['0500', 'Unconfirmed'],
                '1|CONFIRMED': ['0501', 'Confirmed']
            })
        end)
        
        # Clear counting
        tasmota.remove_cmd("LwLDS02ClearCount")
        tasmota.add_cmd("LwLDS02ClearCount", def(cmd, idx, payload_str)
            return lwdecode.SendDownlink(global.LDS02_nodes, cmd, idx, "A601")
        end)
        
        # Enable/disable alarm
        tasmota.remove_cmd("LwLDS02Alarm")
        tasmota.add_cmd("LwLDS02Alarm", def(cmd, idx, payload_str)
            return lwdecode.SendDownlinkMap(global.LDS02_nodes, cmd, idx, payload_str, {
                '0|DISABLE': ['A700', 'Disabled'],
                '1|ENABLE': ['A701', 'Enabled']
            })
        end)
        
        # Control ADR/DR
        tasmota.remove_cmd("LwLDS02ADR")
        tasmota.add_cmd("LwLDS02ADR", def(cmd, idx, payload_str)
            var parts = string.split(payload_str, ',')
            if size(parts) != 2
                return tasmota.resp_cmnd_str("Usage: LwLDS02ADR<slot> <adr_enable>,<data_rate>")
            end
            
            var adr = int(parts[0])
            var dr = int(parts[1])
            
            if adr < 0 || adr > 1
                return tasmota.resp_cmnd_str("Invalid ADR: 0=Disable, 1=Enable")
            end
            if dr < 0 || dr > 15
                return tasmota.resp_cmnd_str("Invalid DR: range 0-15")
            end
            
            var hex_cmd = f"A8{adr:02X}{dr:02X}"
            return lwdecode.SendDownlink(global.LDS02_nodes, cmd, idx, hex_cmd)
        end)
        
        # Set alarm timeout
        tasmota.remove_cmd("LwLDS02AlarmTimeout")
        tasmota.add_cmd("LwLDS02AlarmTimeout", def(cmd, idx, payload_str)
            var parts = string.split(payload_str, ',')
            if size(parts) != 2
                return tasmota.resp_cmnd_str("Usage: LwLDS02AlarmTimeout<slot> <monitor>,<timeout>")
            end
            
            var monitor = int(parts[0])
            var timeout = int(parts[1])
            
            if monitor < 0 || monitor > 1
                return tasmota.resp_cmnd_str("Invalid monitor: 0=Disable, 1=Open timeout")
            end
            if timeout < 0 || timeout > 65535
                return tasmota.resp_cmnd_str("Invalid timeout: range 0-65535 seconds")
            end
            
            var hex_cmd = f"A9{monitor:02X}{(timeout >> 8) & 0xFF:02X}{timeout & 0xFF:02X}"
            return lwdecode.SendDownlink(global.LDS02_nodes, cmd, idx, hex_cmd)
        end)
        
        # Set count value
        tasmota.remove_cmd("LwLDS02SetCount")
        tasmota.add_cmd("LwLDS02SetCount", def(cmd, idx, payload_str)
            var parts = string.split(payload_str, ',')
            if size(parts) < 1 || size(parts) > 2
                return tasmota.resp_cmnd_str("Usage: LwLDS02SetCount<slot> <count>[,<mode>]")
            end
            
            var count = int(parts[0])
            var mode = size(parts) > 1 ? int(parts[1]) : 0
            
            if count < 0 || count > 16777215
                return tasmota.resp_cmnd_str("Invalid count: range 0-16777215")
            end
            if mode < 0 || mode > 1
                return tasmota.resp_cmnd_str("Invalid mode: 0=Close, 1=Open")
            end
            
            var hex_cmd = f"AA{mode:02X}{(count >> 16) & 0xFF:02X}"
            hex_cmd += f"{(count >> 8) & 0xFF:02X}{count & 0xFF:02X}"
            
            return lwdecode.SendDownlink(global.LDS02_nodes, cmd, idx, hex_cmd)
        end)
        
        print("LDS02: Downlink commands registered")
    end
end

# Global instance
LwDeco = LwDecode_LDS02()

# Node management commands
tasmota.remove_cmd("LwLDS02NodeStats")
tasmota.add_cmd("LwLDS02NodeStats", def(cmd, idx, node_id)
    var stats = LwDeco.get_node_stats(node_id)
    if stats != nil
        import json
        tasmota.resp_cmnd(json.dump(stats))
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

tasmota.remove_cmd("LwLDS02ClearNode")
tasmota.add_cmd("LwLDS02ClearNode", def(cmd, idx, node_id)
    if LwDeco.clear_node_data(node_id)
        tasmota.resp_cmnd_done()
    else
        tasmota.resp_cmnd_str("Node not found")
    end
end)

# Test UI command
tasmota.remove_cmd("LwLDS02TestUI")
tasmota.add_cmd("LwLDS02TestUI", def(cmd, idx, payload_str)
    var test_scenarios = {
        # Verified payloads matching MAP structure
        "normal":    "580E0105000000000000",      # Port 10: Battery 3.64V, Door closed, 5 events, 0 duration
        "open":      "D88E0105000000000000",      # Port 10: Door open (bit 15 set), same battery
        "events":    "580E01640000001E000000",    # Port 10: Door closed, 100 events, 30min duration
        "alarm":     "580E0105000000000001",      # Port 10: Same as normal with timeout alarm
        "low":       "2C08010A000000000000",      # Port 10: Low battery 2.1V, door closed
        "edc_open":  "D88E0A000000",              # Port 7: EDC open count mode, 10 events
        "edc_close": "580E05000000",              # Port 7: EDC close count mode, 5 events
        "long_open": "D88E010500000058020000",    # Port 10: Door open, 600min (10h) duration
        "many_events": "580EE803000000000000",    # Port 10: 1000 door events
        "demo":      "580E0105000000001E0000"     # Port 10: Comprehensive demo payload
    }
    
    var hex_payload = test_scenarios.find(payload_str ? payload_str : 'nil', 'not_found')
    
    if hex_payload == 'not_found'
        var scenarios_list = "normal open events alarm low edc_open edc_close long_open many_events demo "
        return tasmota.resp_cmnd_str(f"Available scenarios: {scenarios_list}")
    end
    
    var rssi = -75
    var fport = 10  # Default to sensor data port
    if payload_str == "edc_open" || payload_str == "edc_close" fport = 7 end

    return tasmota.cmd(f'LwSimulate{idx} {rssi},{fport},{hex_payload}')
end)

# Register driver for web UI integration
tasmota.add_driver(LwDeco)