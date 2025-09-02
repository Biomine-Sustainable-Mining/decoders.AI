# Milesight WS202 Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

---

### Generation Request File (WS202-REQ.md)

**Purpose**: Document current implementation for future regeneration

```yaml
# Milesight WS202 Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] FULL - Complete driver with all features

### Device Information
vendor: "Milesight"
model: "WS202"
type: "PIR & Light Sensor"
description: "Motion detection sensor with light threshold sensing"

### Official References
homepage: "https://resource.milesight.com/milesight/iot/document/ws202-user-guide-en.pdf"
userguide: "https://resource.milesight.com/milesight/iot/document/ws202-user-guide-en.pdf"
decoder_reference: "https://resource.milesight.com/milesight/iot/document/ws202-user-guide-en.pdf"
firmware_version: "latest"
lorawan_version: "1.0.3"
regions: [EU868, US915, AU915, AS923, KR920, IN865, RU864, CN470]

### Feature Selection
include_features:
  uplink_decoding: true
  downlink_commands: true
  test_ui_scenarios: true
  node_management: true
  battery_tracking: true      # PIR sensor with battery monitoring
  reset_detection: true
  configuration_sync: true
  error_recovery: true
  performance_optimization: true

### UI Customization
display_preferences:
  single_line_preferred: true  # Simple PIR + light + battery display
  multi_line_for_alerts: false
  custom_emojis:
    pir_occupied: "🚶"
    pir_vacant: "🏠"
    light_bright: "☀️"
    light_dark: "🌙"
    battery: "🔋"
    low_battery: "🪫"
    power_on: "⚡"
    reset: "🔄"
    device_info: "💿"
  hide_technical_info: false    # Show versions when available
  emphasize_alerts: true
  battery_prominance: "normal"  # Standard battery display
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: []   # All values unsigned
  unit_conversions: ["battery_pct_to_voltage"]  # Convert percentage to voltage
  threshold_monitoring: ["battery_pct"]  # Monitor for low battery
  custom_validation_rules: ["pir_immediate_report", "light_threshold_config"]

### Test Configuration
custom_test_scenarios:
  - name: "normal"
    description: "Vacant state with dark environment, normal battery"
    expected_params: ["battery_pct", "occupancy", "illuminance"]
  - name: "occupied"
    description: "Motion detected in bright environment"
    expected_params: ["pir_status", "occupancy", "light_status", "illuminance"]
  - name: "vacant"
    description: "No motion in bright environment"
    expected_params: ["pir_status", "occupancy", "light_status", "illuminance"]
  - name: "low"
    description: "Low battery warning with motion"
    expected_params: ["battery_pct", "pir_status", "occupancy"]
  - name: "config"
    description: "Device configuration with power-on event"
    expected_params: ["power_on_event", "device_reset", "battery_pct"]
  - name: "info"
    description: "Device information with versions and serial"
    expected_params: ["serial_number", "hw_version", "sw_version"]

### Additional Notes
Current Implementation Features (v2.0.0):
```
CRITICAL: Maintain these exact features in regeneration:

1. **Critical Berry Patterns (MANDATORY)**:
   - Safe keys() iteration with found_node flag
   - Explicit key arrays for data recovery
   - Static scenario lists in TestUI commands
   - Nil safety in all comparisons
   - Display error protection with try/catch

2. **Enhanced UI Display**:
   - Single line: PIR status + light level + battery
   - Multi line: Device info (versions, events) when present
   - Conditional line building to prevent empty lines
   - Age indicator for stale data

3. **Robust Error Handling**:
   - Try/catch blocks in decodeUplink and add_web_sensor
   - Console error logging with context
   - Graceful fallback for missing data
   - Recovery after lwreload with global storage

4. **Global Storage Patterns**:
   - WS202_nodes persistent storage
   - Battery trend tracking (last 10 readings)
   - Reset count tracking
   - Node data recovery after reload

5. **All Downlink Commands Working**:
   - LwWS202SetInterval (60-64800 seconds range)
   - LwWS202Reboot (immediate reboot command)
   - Proper validation and error messages

6. **Framework Compatibility**:
   - LwDecode v2.2.9 API compliance
   - Template v2.5.0 payload verification
   - TestUI payload validation mandatory
```

### Request Summary
Request ID: WS202-REQ-2025-09-03
Submitted: 2025-09-03 15:15:00
Version Target: v2.0.0
Expected Deliverables:
- [x] Driver file: vendor/milesight/WS202.be
- [x] Documentation: vendor/milesight/WS202.md
- [x] Generation report: vendor/milesight/WS202-REPORT.md

*Form Version: 2.5.0 | Compatible with Template Version: 2.5.0*
*Generated: 2025-09-03 15:15:00 | Framework: LwDecode v2.2.9*
```
