off|1|0>
            # idx = driver slot (0-15), SendDownlinkMap handles node lookup
            return lwdecode.SendDownlinkMap(global.WS52x_nodes, cmd, idx, payload_str, { 
                '1|ON':  ['08FF', 'ON' ],     # Maps "1" or "ON" to hex 08FF then return result "ON"
                '0|OFF': ['0800', 'OFF']      # Maps "0" or "OFF" to hex 0800 then return result "OFF"
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
            
            var hex_cmd = f"FF24{enabled ? '01' : '00'}{threshold:02X}"
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
            
            var hex_cmd = f"FF30{enabled ? '01' : '00'}{threshold:02X}"
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
        
        # Try to use current instance data first
        var data_to_show = self.last_data
        var last_update = self.last_update
        
        # If no instance data, try to recover from global storage
        if size(data_to_show) == 0 && self.node != nil
            var node_data = global.WS52x_nodes.find(self.node, {})
            data_to_show = node_data.find('last_data', {})
            last_update = node_data.find('last_update', 0)
        end
        
        # Fallback: find ANY stored node if no specific node
        if size(data_to_show) == 0 && size(global.WS52x_nodes) > 0
            for node_id: global.WS52x_nodes.keys()
                var node_data = global.WS52x_nodes[node_id]
                data_to_show = node_data.find('last_data', {})
                self.node = node_id
                self.name = node_data.find('name', f"WS52x-{node_id}")
                last_update = node_data.find('last_update', 0)
                break
            end
        end
        
        if size(data_to_show) == 0 return [] end
        
        var slides = []
        var slide_builder = LwSlideBuilder()
        
        # Slide 1: Power Status
        if data_to_show.contains('socket_state') || data_to_show.contains('active_power')
            slides.push(slide_builder.power_slide(
                data_to_show.find('socket_state', 'UNKNOWN'),
                data_to_show.find('active_power', 0),
                data_to_show.find('voltage', 0),
                data_to_show.find('current', 0)
            ))
        end
        
        # Slide 2: Energy Summary
        if data_to_show.contains('energy') || data_to_show.contains('power_factor')
            slides.push(slide_builder.energy_slide(
                data_to_show.find('energy', 0),
                data_to_show.find('power_factor', 0)
            ))
        end
        
        # Slide 3: Device Status
        var has_status_info = data_to_show.contains('sw_version') || 
                             data_to_show.contains('hw_version') ||
                             data_to_show.contains('device_reset')
        if has_status_info
            slides.push(slide_builder.status_slide(
                data_to_show.find('sw_version', 'Unknown'),
                data_to_show.find('hw_version', 'Unknown'),
                data_to_show.find('device_reset', false),
                data_to_show.find('reset_reason', 'None')
            ))
        end
        
        # Slide 4: Configuration
        var has_config_info = data_to_show.contains('button_locked') ||
                             data_to_show.contains('led_enabled') ||
                             data_to_show.contains('power_recording')
        if has_config_info
            slides.push(slide_builder.config_slide(
                data_to_show.find('button_locked', false),
                data_to_show.find('led_enabled', true),
                data_to_show.find('power_recording', false),
                data_to_show.find('interval_minutes', 0)
            ))
        end
        
        # Slide 5: Events & Alerts
        var has_events = data_to_show.contains('power_on_event') ||
                        data_to_show.contains('power_outage_event') ||
                        data_to_show.contains('oc_alarm_enabled')
        if has_events
            slides.push(slide_builder.events_slide(
                data_to_show.find('power_on_event', false),
                data_to_show.find('power_outage_event', false),
                data_to_show.find('oc_alarm_enabled', false),
                data_to_show.find('oc_protection_enabled', false)
            ))
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

# Command usage: LwWS52xTestUI<slot> <scenario>
tasmota.remove_cmd("LwWS52xTestUI")
tasmota.add_cmd("LwWS52xTestUI", def(cmd, idx, payload_str)
    # Predefined realistic test scenarios for UI development
    var test_scenarios = {
        # Normal operation - socket ON with typical power consumption
        "normal":    "0370741A020480FF0F00000581640683FF2710000007C9960008700103010109020A050B000F000016FFFFFFFFFFFFFFFF24000A25000026012F0130000AFF03",
        
        # High power consumption - heater or high load device
        "high":      "0370742301048080170000058164068300CCCC000007C980020870010101090A050B000F001624000A25000026012F0130000A",
        
        # Socket OFF state
        "off":       "037074000104800000000005810006830000000007C900000870001709020A050B000F00162500002601",
        
        # Low power standby mode
        "standby":   "037074960204800500000058164068300000A000007C9140008700109020A050B00",
        
        # Device reset event
        "reset":     "FFFE00037074960204800500000005816406830000A000007C9140008700109020A050B00",
        
        # Configuration response with all settings
        "config":    "FE021E002400100002500002601FF2F01FF30010AFF01090203002F012F0130000A",
        
        # Power outage event
        "outage":    "FF3F01037074000104800000000005810006830000000007C9000008700009020A050B00",
        
        # Energy reset acknowledgment
        "energy_reset": "FF2700037074000104800000000005810006830000000007C9000008700009020A050B00"
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