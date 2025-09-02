# Dragino LDS02 Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.3.0 | Platform: Tasmota Berry

---

### Generation Request File (LDS02-REQ.md)

**Purpose**: Document current implementation for future regeneration

```yaml
# Dragino LDS02 Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.3.0 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] FULL - Complete driver with all features

### Device Information
vendor: "Dragino"
model: "LDS02"
type: "Door Sensor"
description: "Magnetic door sensor with event counting and alarm functionality"

### Official References
homepage: "https://wiki.dragino.com/xwiki/bin/view/Main/User%20Manual%20for%20LoRaWAN%20End%20Nodes/LDS02%20-%20LoRaWAN%20Door%20Sensor%20User%20Manual/"
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
  custom_emojis: {"door_open": "🔓", "door_closed": "🔒", "events": "📊", "alarm": "⚠️"}
  hide_technical_info: true
  emphasize_alerts: true
  battery_prominance: "normal"
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: []
  unit_conversions: ["battery: mV->V", "duration: min->h"]
  threshold_monitoring: ["alarm_status", "door_status"]
  custom_validation_rules: ["edc_mode", "event_counting"]

### Test Configuration
custom_test_scenarios:
  - name: "normal"
    description: "Normal door closed with events"
    expected_params: ["battery_v", "door_status", "door_open_events"]
  - name: "open"
    description: "Door open state"
    expected_params: ["door_open", "door_status"]
  - name: "alarm"
    description: "Timeout alarm triggered"
    expected_params: ["alarm_status", "alarm_type"]
  - name: "edc_mode"
    description: "Event counting mode active"
    expected_params: ["edc_active", "event_count"]

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
   - Door state with open/closed emojis (🔓/🔒)
   - Event counting display
   - Duration formatting (minutes/hours)
   - EDC mode indicators

3. **Robust Error Handling**:
   - Battery voltage validation and conversion
   - Event counting overflow handling
   - Payload size validation
   - Display error protection

4. **Global Storage Patterns**:
   - Multi-node support with LDS02_nodes
   - Battery history tracking
   - Event counting and alarm tracking
   - Node statistics and management

5. **All Downlink Commands Working**:
   - Transmission interval setting
   - EDC mode configuration
   - Device reset and confirmation modes
   - Counter clearing and alarm control

6. **Framework Compatibility**:
   - LwDecode v2.3.0 integration
   - SendDownlink/SendDownlinkMap usage
   - Command registration with proper cleanup
```

### Request Summary
Request ID: LDS02-REQ-2025-09-03
Submitted: 2025-09-03 00:00:00
Version Target: v2.0.0
Expected Deliverables:
- [x] Driver file: vendor/dragino/LDS02.be
- [x] Documentation: vendor/dragino/LDS02.md
- [x] Generation report: vendor/dragino/LDS02-REPORT.md

*Form Version: 2.5.0 | Compatible with Template Version: 2.5.0*
*Generated: 2025-09-03 00:00:00 | Framework: LwDecode v2.3.0*
```
