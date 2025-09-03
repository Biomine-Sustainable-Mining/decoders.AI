# Milesight WS523 Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] FULL - Complete driver with all features

### Device Information
vendor: "Milesight"
model: "WS523"
type: "Portable Smart Socket"
description: "AC-powered smart socket with power monitoring, overcurrent protection, and remote control"

### Official References
homepage: "https://www.milesight.com/iot/product/lorawan-sensor/ws523"
userguide: "WS523_LoRaWAN_Portable_Smart_Socket_UserGuide v1.3"
decoder_reference: "Official Milesight Decoder"
firmware_version: "latest"
lorawan_version: "1.0.3"
regions: [EU868, US915, AU915, AS923, KR920, IN865, RU864, CN470]

### Feature Selection
include_features:
  uplink_decoding: true
  downlink_commands: true
  test_ui_scenarios: true
  node_management: true
  battery_tracking: false      # Mains powered device
  reset_detection: true
  configuration_sync: true
  error_recovery: true
  performance_optimization: true

### UI Customization
display_preferences:
  single_line_preferred: false  # Multi-line for power data
  multi_line_for_alerts: true
  custom_emojis: {socket_on: "🟢", socket_off: "⚫", power: "💡", energy: "🏠", protection: "🛡️"}
  hide_technical_info: false    # Show version info
  emphasize_alerts: true
  battery_prominance: "hidden"  # Mains powered
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: ["active_power"]   # Power can be negative (generation)
  unit_conversions: ["smart_energy_scaling"] # Wh -> kWh -> MWh -> GWh
  threshold_monitoring: ["oc_alarm_threshold", "oc_protection_threshold"]
  custom_validation_rules: ["power_range_validation", "current_range_validation"]

### Test Configuration
custom_test_scenarios:
  - name: "normal"
    description: "Normal operation - 240V, 100W, socket ON"
    expected_params: ["voltage", "active_power", "socket_on"]
  - name: "high_power"
    description: "High power load - 800W consumption"
    expected_params: ["voltage", "active_power", "current"]
  - name: "outage"
    description: "Power outage event detected"
    expected_params: ["power_outage_event"]
  - name: "config"
    description: "Configuration data with protection settings"
    expected_params: ["sw_version", "oc_alarm_enabled"]

### Additional Notes
Current Implementation Features (v5.0.0):
```
CRITICAL: Maintain these exact features in regeneration:

1. **Critical Berry Patterns (MANDATORY)**:
   - Safe iteration with found_node flag in add_web_sensor()
   - Explicit key arrays for data recovery
   - Static scenario string list in TestUI command

2. **Enhanced UI Display**:
   - Smart energy scaling (Wh/kWh/MWh/GWh)
   - Multi-line power monitoring display
   - Conditional event lines with content validation

3. **Robust Error Handling**:
   - Try/catch blocks in display and decode functions
   - Payload verification for TestUI scenarios
   - Channel ID validation with logging

4. **Global Storage Patterns**:
   - Power/energy history tracking (10 samples)
   - Socket state change counting
   - Power event tracking (outages, resets)

5. **All Downlink Commands Working**:
   - LwWS523Control, LwWS523Interval, LwWS523Reboot
   - LwWS523OCAlarm, LwWS523OCProtection, LwWS523ButtonLock
   - LwWS523PowerRecording, LwWS523ResetEnergy, LwWS523Status
   - LwWS523LED, LwWS523DelayTask, LwWS523DeleteTask

6. **Framework Compatibility**:
   - LwDecode v2.2.9 helper functions
   - SendDownlinkMap for binary commands
   - uint16le/uint32le for multi-byte parameters
```

### Request Summary
Request ID: WS523-REQ-2025-09-03
Submitted: 2025-09-03 16:20:00
Version Target: v5.0.0
Expected Deliverables:
- [x] Driver file: vendor/milesight/WS523.be
- [x] Documentation: vendor/milesight/WS523.md
- [x] Generation report: vendor/milesight/WS523-REPORT.md

*Form Version: 2.5.0 | Compatible with Template Version: 2.5.0*
*Generated: 2025-09-03 16:20:00 | Framework: LwDecode v2.2.9*
