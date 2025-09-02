# Milesight WS101 Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

---

### Generation Request File (WS101-REQ.md)

**Purpose**: Document current implementation for future regeneration

```yaml
# Milesight WS101 Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] FULL - Complete driver with all features

### Device Information
vendor: "Milesight"
model: "WS101"
type: "Smart Button"
description: "LoRaWAN smart button with multiple press types, battery monitoring, and configurable LED/buzzer feedback"

### Official References
homepage: "https://www.milesight.com/iot/product/lorawan-sensor/ws101"
userguide: "WS101 Datasheet"
decoder_reference: "Official Milesight Decoder"
firmware_version: "latest"
lorawan_version: "1.0.3"
regions: ["EU868", "US915", "AU915", "AS923", "KR920", "IN865", "RU864", "CN470"]

### Feature Selection
include_features:
  uplink_decoding: true
  downlink_commands: true
  test_ui_scenarios: true
  node_management: true
  battery_tracking: true
  reset_detection: true
  configuration_sync: true
  error_recovery: true
  performance_optimization: true

### UI Customization
display_preferences:
  single_line_preferred: true
  multi_line_for_alerts: false
  custom_emojis: 
    short_press: "👆"
    long_press: "👇"
    double_press: "👆👆"
    button: "🔘"
    power_on: "⚡"
  hide_technical_info: false
  emphasize_alerts: false
  battery_prominance: "normal"
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: []
  unit_conversions: []
  threshold_monitoring: []
  custom_validation_rules:
    - "Button event types (0x01=Short, 0x02=Long, 0x03=Double)"
    - "Milesight channel+type format parsing"
    - "Battery level percentage tracking"
    - "Press history and counters by type"

### Test Configuration
custom_test_scenarios:
  - name: "short_press"
    description: "Short button press event"
    expected_params: ["button_mode", "button_event"]
  - name: "long_press"
    description: "Long button press event"
    expected_params: ["button_mode", "button_event"]
  - name: "double_press"
    description: "Double button press event"
    expected_params: ["button_mode", "button_event"]
  - name: "battery"
    description: "Battery level report"
    expected_params: ["battery"]
  - name: "low_battery"
    description: "Low battery condition"
    expected_params: ["battery"]
  - name: "power_on"
    description: "Power on event"
    expected_params: ["power_on"]
  - name: "device_info"
    description: "Device version information"
    expected_params: ["sw_version", "hw_version"]
  - name: "full_info"
    description: "Complete device information"
    expected_params: ["button_mode", "battery", "sw_version", "power_on"]

### Additional Notes
Current Implementation Features (v3.0.0):
```
CRITICAL: Maintain these exact features in regeneration:

1. **Critical Berry Patterns (MANDATORY)**:
   - Global storage patterns: WS101_nodes for multi-device support
   - Enhanced lwreload recovery with found_node flag pattern
   - Display error protection with try/catch wrapper
   - Template v2.5.0 payload verification system
   - Static scenario list to avoid keys() iterator bug

2. **Enhanced UI Display**:
   - Single-line format for button events
   - Button event emoji indicators (👆/👇/👆👆)
   - Press type identification and display
   - Device information with version display
   - Power-on event indication

3. **Robust Error Handling**:
   - Milesight channel+type format validation
   - Button event type parsing (0x01/0x02/0x03)
   - Try/catch blocks in all display functions
   - Enhanced display error protection

4. **Global Storage Patterns**:
   - Multi-node support with persistent WS101_nodes storage
   - Battery history tracking (last 10 readings)
   - Button press history (last 50 events with timestamps)
   - Press counters by type (short/long/double counts)
   - Node statistics and management commands

5. **All Downlink Commands Working**:
   - LwWS101Interval: Set reporting interval (60-64800 seconds)
   - LwWS101Reboot: Device reboot command
   - LwWS101LED: LED indicator enable/disable
   - LwWS101DoublePress: Double press mode enable/disable
   - LwWS101Buzzer: Buzzer feedback enable/disable

6. **Framework Compatibility**:
   - Framework v2.2.9: RSSI/FPort uppercase, simulated parameter support
   - Template v2.5.0: Verified TestUI payload decoding system
   - Button event tracking with press counters
   - Enhanced payload verification with decode-back testing
```

### Request Summary
Request ID: WS101-REQ-2025-09-03
Submitted: 2025-09-03 15:00:00
Version Target: v3.0.0
Expected Deliverables:
- [x] Driver file: vendor/milesight/WS101.be
- [x] Documentation: vendor/milesight/WS101.md
- [x] Generation report: vendor/milesight/WS101-REPORT.md

*Form Version: 2.5.0 | Compatible with Template Version: 2.5.0*
*Generated: 2025-09-03 15:00:00 | Framework: LwDecode v2.2.9*
```

## 🎯 OBJECTIVE
Template upgrade from v2.4.1 to v2.5.0 for WS101 driver maintaining all existing functionality while adding verified TestUI payload decoding system and enhanced error recovery patterns.

---

### Upgrade Changes Applied
- **Framework v2.2.9**: Maintained RSSI/FPort uppercase parameter compatibility
- **Template v2.5.0**: Added verified TestUI payload decoding with decode-back validation
- **Enhanced Recovery**: Improved lwreload recovery with found_node flag pattern
- **Payload Verification**: All TestUI scenarios now validate through actual decoding
- **Static Scenarios**: Fixed Berry keys() iterator bug with static scenario list

---
*WS101 Generation Request v3.0.0 - Framework v2.2.9 + Template v2.5.0*
*Generated: 2025-09-03 | Status: Template v2.5.0 Complete*
