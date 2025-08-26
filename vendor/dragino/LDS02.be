#
# LoRaWAN AI-Generated Decoder for Dragino LDS02 Prompted by ZioFabry
#
# Generated: 2025-08-26 | Version: 2.0.0 | Revision: 1
#            by "LoRaWAN Decoder AI Generation Template", v2.3.6
#
# Homepage:  https://wiki.dragino.com/xwiki/bin/view/Main/User%20Manual%20for%20LoRaWAN%20End%20Nodes/LDS02%20-%20LoRaWAN%20Door%20Sensor%20User%20Manual/
# Userguide: LDS02_LoRaWAN_Door_Sensor_User_Manual v1.8.2
# Decoder:   Official Dragino Decoder
# 
# v2.0.0 (2025-08-26): Framework v2.2.9 + Template v2.3.6 upgrade with enhanced error handling
# v1.0.0 (2025-08-16): Initial generation from PDF specification

class LwDecode_LDS02
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
        if !global.contains("LDS02_nodes")
            global.LDS02_nodes = {}
        end
        if !global.contains("LDS02_cmdInit")
            global.LDS02_cmdInit = false
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
            var node_data = global.LDS02_nodes.find(node, {})
            
            if fport == 10  # Sensor Data
                if size(payload) >= 10
                    # Battery & Door Status (bytes 0-1, little endian)
                    var status_word = (payload[1] << 8) | payload[0]
                    data['battery_mv'] = status_word & 0x3FFF  # Lower 14 bits
                    data['battery_v'] = data['battery_mv'] / 1000.0
                    data['door_open'] = (status_word & 0x8000) != 0  # MSB bit
                    data['door_status'] = data['door_open'] ? "Open" : "Closed"
                    
                    # Mode (byte 2)
                    data['mode'] = payload[2]
                    data['mode_name'] = (payload[2] == 0x01) ? "Normal Mode" : f"Mode {payload[2]}"
                    
                    # Total Door Open Events (bytes 3-5, little endian)
                    data['total_events'] = (payload[5] << 16) | (payload[4] << 8) | payload[3]
                    
                    # Last Door Open Duration in minutes (bytes 6-8, little endian)
                    var duration_minutes = (payload[8] << 16) | (payload[7] << 8) | payload[6]
                    data['last_duration_min'] = duration_minutes
                    
                    # Convert duration to readable format
                    if duration_minutes > 0
                        if duration_minutes < 60
                            data['last_duration_text'] = f"{duration_minutes}min"
                        elif duration_minutes < 1440  # < 24 hours
                            data['last_duration_text'] = f"{duration_minutes / 60:.1f}h"
                        else
                            data['last_duration_text'] = f"{duration_minutes / 1440:.1f}d"
                        end
                    else
                        data['last_duration_text'] = "0min"
                    end
                    
                    # Alarm Status (byte 9)
                    data['alarm_active'] = (payload[9] & 0x01) != 0
                    data['alarm_status'] = data['alarm_active'] ? "Timeout Alarm" : "No Alarm"
                end
                
            elif fport == 7  # EDC Mode Data
                if size(payload) >= 5
                    # Battery & EDC Mode (bytes 0-1, little endian)
                    var edc_word = (payload[1] << 8) | payload[0]
                    data['battery_mv'] = edc_word & 0x3FFF  # Lower 14 bits
                    data['battery_v'] = data['battery_mv'] / 1000.0
                    data['edc_mode'] = (edc_word & 0x8000) != 0  # MSB bit
                    data['edc_mode_name'] = data['edc_mode'] ? "Open Count" : "Close Count"
                    
                    # Event Count (bytes 2-4, little endian)
                    data['event_count'] = (payload[4] << 16) | (payload[3] << 8) | payload[2]
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
            
            # Track door state changes
            if data.contains('door_open')
                var prev_state = node_data.find('last_door_state', nil)
                if prev_state != nil && prev_state != data['door_open']
                    node_data['door_changes'] = node_data.find('door_changes', 0) + 1
                    node_data['last_state_change'] = tasmota.rtc()['local']
                end
                node_data['last_door_state'] = data['door_open']
            end
            
            # Track event counting
            if data.contains('total_events')
                node_data['event_tracking'] = data['total_events']
            elif data.contains('event_count')
                node_data['edc_tracking'] = data['event_count']
            end
            
            # Track alarm events
            if data.contains('alarm_active') && data['alarm_active']
                node_data['alarm_count'] = node_data.find('alarm_count', 0) + 1
                node_data['last_alarm'] = tasmota.rtc()['local']
            end
            
            # Initialize downlink commands once
            if !global.contains("LDS02_cmdInit") || !global.LDS02_cmdInit
                self.register_downlink_commands()
                global.LDS02_cmdInit = true
            end

            # Save back to global storage
            global.LDS02_nodes[node] = node_data
            
            # Update instance cache
            self.last_data = data
            self.last_update = node_data['last_update']
            
            return data
            
        except .. as e, m
            print(f"LDS02: Decode error - {e}: {m}")
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
                var node_data = global.LDS02_nodes.find(self.node, {})
                data_to_show = node_data.find('last_data', {})
                last_update = node_data.find('last_update', 0)
            end
            
            # Fallback: find ANY stored node if no specific node
            if size(data_to_show) == 0 && size(global.LDS02_nodes) > 0
                for node_id: global.LDS02_nodes.keys()
                    var node_data = global.LDS02_nodes[node_id]
                    data_to_show = node_data.find('last_data', {})
                    last_update = node_data.find('last_update', 0)
                    self.node = node_id  # Update instance
                    self.name = node_data.find('name', f"LDS02-{node_id}")
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
                name = f"LDS02-{self.node}"
            end
            var name_tooltip = "Dragino LDS02 Door Sensor"
            var battery = data_to_show.find('battery_v', 1000)
            var battery_last_seen = last_update
            var rssi = data_to_show.find('RSSI', 1000)
            var simulated = data_to_show.find('simulated', false)
            
            # Build display using emoji formatter
            fmt.header(name, name_tooltip, battery, battery_last_seen, rssi, last_update, simulated)
            
            fmt.start_line()
            
            # Door status
            if data_to_show.contains('door_open')
                if data_to_show['door_open']
                    fmt.add_status("Open", "🔓", "Door is open")
                else
                    fmt.add_status("Closed", "🔒", "Door is closed")
                end
            end
            
            # Battery voltage
            if data_to_show.contains('battery_v')
                fmt.add_sensor("volt", data_to_show['battery_v'], "Battery", "🔋")
            end
            
            # Event counts
            if data_to_show.contains('total_events')
                fmt.add_sensor("count", data_to_show['total_events'], "Events", "🔢")
            elif data_to_show.contains('event_count')
                fmt.add_sensor("count", data_to_show['event_count'], "Count", "🔢")
            end
            
            # Last duration (for normal mode)
            if data_to_show.contains('last_duration_text') && data_to_show['last_duration_text'] != "0min"
                fmt.add_status(data_to_show['last_duration_text'], "⏱️", f"Last open duration: {data_to_show['last_duration_text']}")
            end
            
            # Mode and alarm status line (when present)
            var has_status_line = false
            if data_to_show.contains('mode_name') || data_to_show.contains('edc_mode_name') || data_to_show.contains('alarm_active')
                fmt.next_line()
                has_status_line = true
                
                # Mode display
                if data_to_show.contains('mode_name')
                    fmt.add_status(data_to_show['mode_name'], "🔧", "Operation Mode")
                elif data_to_show.contains('edc_mode_name')
                    fmt.add_status(data_to_show['edc_mode_name'], "🔧", "EDC Mode")
                end
                
                # Alarm status
                if data_to_show.contains('alarm_active')
                    if data_to_show['alarm_active']
                        fmt.add_status("Timeout", "🚨", "Timeout alarm active")
                    else
                        fmt.add_status("Normal", "✅", "No alarm")
                    end
                end
            end
            
            fmt.end_line()
            
            # ONLY get_msg() return a string that can be used with +=
            msg += fmt.get_msg()

            return msg
            
        except .. as e, m
            print(f"LDS02: Display error - {e}: {m}")
            return "📟 LDS02 Error - Check Console"
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
        var node_data = global.LDS02_nodes.find(node_id, nil)
        if node_data == nil return nil end
        
        return {
            'last_update': node_data.find('last_update', 0),
            'battery_history': node_data.find('battery_history', []),
            'door_changes': node_data.find('door_changes', 0),
            'last_state_change': node_data.find('last_state_change', 0),
            'last_door_state': node_data.find('last_door_state', nil),
            'event_tracking': node_data.find('event_tracking', 0),
            'edc_tracking': node_data.find('edc_tracking', 0),
            'alarm_count': node_data.find('alarm_count', 0),
            'last_alarm': node_data.find('last_alarm', 0),
            'name': node_data.find('name', 'Unknown')
        }
    end
    
    # Clear node data (for maintenance)
    def clear_node_data(node_id)
        import global
        if global.LDS02_nodes.contains(node_id)
            global.LDS02_nodes.remove(node_id)
            return true
        end
        return false
    end
    
    # Register downlink commands for device control
    def register_downlink_commands()
        import string
        
        # Set Transmit Interval
        tasmota.remove_cmd("LwLDS02Interval")
        tasmota.add_cmd("LwLDS02Interval", def(cmd, idx, payload_str)
            # Format: LwLDS02Interval<slot> <seconds>
            var seconds = int(payload_str)
            if seconds < 1 || seconds > 4294967295
                return tasmota.resp_cmnd_str("Invalid: range 1-4294967295 seconds")
            end
            
            # Build hex command (32-bit little endian)
            var hex_cmd = f"01{lwdecode.uint32le(seconds)}"
            return lwdecode.SendDownlink(global.LDS02_nodes, cmd, idx, hex_cmd)
        end)
        
        # Set EDC Mode
        tasmota.remove_cmd("LwLDS02EDCMode")
        tasmota.add_cmd("LwLDS02EDCMode", def(cmd, idx, payload_str)
            # Format: LwLDS02EDCMode<slot> <mode>,<threshold>
            var parts = string.split(payload_str, ',')
            if size(parts) != 2
                return tasmota.resp_cmnd_str("Usage: LwLDS02EDCMode<slot> <open|close>,<threshold>")
            end
            
            var mode = (string.toupper(parts[0]) == "OPEN") ? 1 : 0
            var threshold = int(parts[1])
            
            if threshold < 1 || threshold > 4294967295
                return tasmota.resp_cmnd_str("Invalid threshold: range 1-4294967295")
            end
            
            var hex_cmd = f"02{mode:02X}{lwdecode.uint32le(threshold)}"
            return lwdecode.SendDownlink(global.LDS02_nodes, cmd, idx, hex_cmd)
        end)
        
        # Reset Device
        tasmota.remove_cmd("LwLDS02Reset")
        tasmota.add_cmd("LwLDS02Reset", def(cmd, idx, payload_str)
            # Format: LwLDS02Reset<slot>
            var hex_cmd = "04FF"
            return lwdecode.SendDownlink(global.LDS02_nodes, cmd, idx, hex_cmd)
        end)
        
        # Set Confirmed Mode
        tasmota.remove_cmd("LwLDS02Confirmed")
        tasmota.add_cmd("LwLDS02Confirmed", def(cmd, idx, payload_str)
            # Format: LwLDS02Confirmed<slot> <on|off|1|0>
            return lwdecode.SendDownlinkMap(global.LDS02_nodes, cmd, idx, payload_str, { 
                '1|ON':  ['0501', 'Confirmed Mode ON'],
                '0|OFF': ['0500', 'Confirmed Mode OFF']
            })
        end)
        
        # Clear Counting
        tasmota.remove_cmd("LwLDS02ClearCount")
        tasmota.add_cmd("LwLDS02ClearCount", def(cmd, idx, payload_str)
            # Format: LwLDS02ClearCount<slot>
            var hex_cmd = "A601"
            return lwdecode.SendDownlink(global.LDS02_nodes, cmd, idx, hex_cmd)
        end)
        
        # Enable/Disable Alarm
        tasmota.remove_cmd("LwLDS02Alarm")
        tasmota.add_cmd("LwLDS02Alarm", def(cmd, idx, payload_str)
            # Format: LwLDS02Alarm<slot> <enable|disable|1|0>
            return lwdecode.SendDownlinkMap(global.LDS02_nodes, cmd, idx, payload_str, { 
                '1|ENABLE':  ['A701', 'Alarm Enabled'],
                '0|DISABLE': ['A700', 'Alarm Disabled']
            })
        end)
        
        # Control ADR/DR
        tasmota.remove_cmd("LwLDS02ADR")
        tasmota.add_cmd("LwLDS02ADR", def(cmd, idx, payload_str)
            # Format: LwLDS02ADR<slot> <adr_enable>,<data_rate>
            var parts = string.split(payload_str, ',')
            if size(parts) != 2
                return tasmota.resp_cmnd_str("Usage: LwLDS02ADR<slot> <0|1>,<0-15>")
            end
            
            var adr = int(parts[0])
            var dr = int(parts[1])
            
            if adr < 0 || adr > 1
                return tasmota.resp_cmnd_str("Invalid ADR: 0=disable, 1=enable")
            end
            if dr < 0 || dr > 15
                return tasmota.resp_cmnd_str("Invalid DR: range 0-15")
            end
            
            var hex_cmd = f"A8{adr:02X}{dr:02X}"
            return lwdecode.SendDownlink(global.LDS02_nodes, cmd, idx, hex_cmd)
        end)
        
        # Set Alarm Timeout
        tasmota.remove_cmd("LwLDS02AlarmTimeout")
        tasmota.add_cmd("LwLDS02AlarmTimeout", def(cmd, idx, payload_str)
            # Format: LwLDS02AlarmTimeout<slot> <enable>,<timeout_seconds>
            var parts = string.split(payload_str, ',')
            if size(parts) != 2
                return tasmota.resp_cmnd_str("Usage: LwLDS02AlarmTimeout<slot> <0|1>,<timeout>")
            end
            
            var enable = int(parts[0])
            var timeout = int(parts[1])
            
            if enable < 0 || enable > 1
                return tasmota.resp_cmnd_str("Invalid enable: 0=disable, 1=enable")
            end
            if timeout < 0 || timeout > 65535
                return tasmota.resp_cmnd_str("Invalid timeout: range 0-65535 seconds")
            end
            
            var hex_cmd = f"A9{enable:02X}{lwdecode.uint16be(timeout)}"
            return lwdecode.SendDownlink(global.LDS02_nodes, cmd, idx, hex_cmd)
        end)
        
        # Set Count Value
        tasmota.remove_cmd("LwLDS02SetCount")
        tasmota.add_cmd("LwLDS02SetCount", def(cmd, idx, payload_str)
            # Format: LwLDS02SetCount<slot> <mode>,<count>
            var parts = string.split(payload_str, ',')
            if size(parts) != 2
                return tasmota.resp_cmnd_str("Usage: LwLDS02SetCount<slot> <open|close>,<count>")
            end
            
            var mode = (string.toupper(parts[0]) == "OPEN") ? 1 : 0
            var count = int(parts[1])
            
            if count < 0 || count > 16777215
                return tasmota.resp_cmnd_str("Invalid count: range 0-16777215")
            end
            
            # Build 24-bit big endian count
            var count_hex = f"{(count >> 16) & 0xFF:02X}{(count >> 8) & 0xFF:02X}{count & 0xFF:02X}"
            var hex_cmd = f"AA{mode:02X}{count_hex}"
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
    # Predefined realistic test scenarios for UI development
    var test_scenarios = {
        "normal_closed":   "C00E01000100001E0000",    # Normal: 3776mV, closed, mode 1, 1 event, 30min duration, no alarm
        "normal_open":     "C08E01000200003C0000",    # Normal: 3776mV, open, mode 1, 2 events, 60min duration, no alarm
        "alarm":           "C08E01000300001E0001",    # Alarm: 3776mV, open, mode 1, 3 events, 30min duration, timeout alarm
        "low_battery":     "400A01000500005A0000",    # Low battery: 2624mV, closed, mode 1, 5 events, 90min duration, no alarm
        "many_events":     "C00E010064000078120000", # Many events: 3776mV, closed, mode 1, 100 events, 4728min duration, no alarm
        "edc_open":        "C08E0A0000",             # EDC mode: 3776mV, open count mode, 10 events
        "edc_close":       "C00E140000"             # EDC mode: 3776mV, close count mode, 20 events
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
    var fport = (payload_str && (payload_str == "edc_open" || payload_str == "edc_close")) ? 7 : 10

    return tasmota.cmd(f'LwSimulate{idx} {rssi},{fport},{hex_payload}')
end)

# MANDATORY: Register driver for web UI integration
tasmota.add_driver(LwDeco)
