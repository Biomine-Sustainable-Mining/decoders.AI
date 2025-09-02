# Dragino D2x Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.3.0 | Platform: Tasmota Berry

---

### Generation Request File (D2x-REQ.md)

**Purpose**: Document current implementation for future regeneration

```yaml
# Dragino D2x Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.3.0 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] FULL - Complete driver with all features

### Device Information
vendor: "Dragino"
model: "D2x"
type: "Temperature Sensor Series"
description: "Multi-probe temperature sensor with alarm functionality"

### Official References
homepage: "http://wiki.dragino.com/xwiki/bin/view/Main/User Manual for LoRaWAN End Nodes/D20-LBD22-LBD23-LB_LoRaWAN_Temperature_Sensor_User_Manual/"
userguide: "Same as homepage"
decoder_reference: "Official decoder integrated"
firmware_version: "latest"
lorawan_version: "1.0.3"
regions: [CN470, EU433, KR920, US915, EU868, AS923, AU915, IN865]

### Feature Selection
include_features:
  uplink_decoding: true
  downlink_commands: true
  test_ui_scenarios: true
  node_management: true
  battery_tracking: true
  reset_detection: false
  configuration_sync: true
  error_recovery: true
  performance_optimization: true

### UI Customization
display_preferences:
  single_line_preferred: true
  multi_line_for_alerts: true
  custom_emojis: {"red_probe": "🔴", "white_probe": "⚪", "black_probe": "⚫"}
  hide_technical_info: true
  emphasize_alerts: true
  battery_prominance: "normal"
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: ["temp_red_white", "temp_white", "temp_black"]
  unit_conversions: ["temperature_scaling: /10.0", "battery_voltage: /1000.0"]
  threshold_monitoring: ["alarm_flag", "pa8_level"]
  custom_validation_rules: ["invalid_temp: 0x7FFF", "multi_probe_support"]

### Test Configuration
custom_test_scenarios:
  - name: "normal"
    description: "Normal operation with single probe"
    expected_params: ["battery_v", "temp_red_white", "alarm_flag"]
  - name: "multi"
    description: "Multi-probe operation (D22/D23)"
    expected_params: ["temp_red_white", "temp_white", "temp_black"]
  - name: "alarm"
    description: "Temperature alarm condition"
    expected_params: ["alarm_flag", "temp_red_white"]
  - name: "config"
    description: "Device configuration and status"
    expected_params: ["fw_version", "frequency_band", "sensor_model"]

### Additional Notes
Current Implementation Features (v2.0.0):
```
CRITICAL: Maintain these exact features in regeneration:

1. **Critical Berry Patterns (MANDATORY)**:
   - Template v2.5.0 TestUI payload verification
   - Safe keys() iteration with found_node flag
   - Nil safety in all comparisons
   - Try/catch error handling in display

2. **Enhanced UI Display**:
   - Multi-probe support with probe-specific emojis (🔴⚪⚫)
   - Temperature formatter for all probes
   - Battery voltage display
   - Status indicators for alarms and configuration

3. **Robust Error Handling**:
   - Invalid temperature detection (0x7FFF)
   - Signed temperature conversion (-327.6 to 327.6°C)
   - Payload size validation
   - Display error protection

4. **Global Storage Patterns**:
   - Multi-node support with D2x_nodes
   - Battery history tracking (10 readings)
   - Alarm event counting and timestamps
   - Node statistics and management

5. **All Downlink Commands Working**:
   - Transmission interval setting (30-16777215 seconds)
   - Alarm threshold configuration (-128 to 127°C)
   - Device status request
   - Interrupt mode control
   - Historical data polling

6. **Framework Compatibility**:
   - LwDecode v2.3.0 integration
   - SendDownlink/SendDownlinkMap usage
   - Command registration with proper cleanup
```

### Request Summary
Request ID: D2x-REQ-2025-09-03
Submitted: 2025-09-03 00:00:00
Version Target: v2.0.0
Expected Deliverables:
- [x] Driver file: vendor/dragino/D2x.be
- [x] Documentation: vendor/dragino/D2x.md
- [x] Generation report: vendor/dragino/D2x-REPORT.md

*Form Version: 2.5.0 | Compatible with Template Version: 2.5.0*
*Generated: 2025-09-03 00:00:00 | Framework: LwDecode v2.3.0*
```
