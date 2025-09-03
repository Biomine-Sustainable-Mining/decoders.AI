# Milesight WS301 Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

---

### Generation Request File (WS301-REQ.md)

**Purpose**: Document current implementation for future regeneration

```yaml
# Milesight WS301 Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] FULL - Complete driver with all features

### Device Information
vendor: "Milesight"
model: "WS301"
type: "Magnetic Contact Switch"
description: "Door/window sensor with magnetic contact and tamper detection"

### Official References
homepage: "https://www.milesight-iot.com/lorawan/sensor/ws301/"
userguide: "https://resource.milesight.com/milesight/iot/document/ws301-user-guide-en.pdf"
decoder_reference: "https://github.com/Milesight-IoT/SensorDecoders"
firmware_version: "latest"
lorawan_version: "1.0.3"
regions: [EU868, US915, AU915, CN470]

### Feature Selection
include_features:
  uplink_decoding: true
  downlink_commands: true
  test_ui_scenarios: true
  node_management: true
  battery_tracking: true      # Magnetic sensor with battery monitoring
  reset_detection: true
  configuration_sync: true
  error_recovery: true
  performance_optimization: true

### UI Customization
display_preferences:
  single_line_preferred: true  # Simple door state + tamper + battery display
  multi_line_for_alerts: false
  custom_emojis:
    door_open: "🔓"
    door_closed: "🔒"
    installed: "✅"
    tamper: "⚠️"
    battery: "🔋"
    low_battery: "🪫"
    power_on: "⚡"
    reset: "🔄"
  hide_technical_info: false    # Show versions when available
  emphasize_alerts: true
  battery_prominance: "normal"  # Standard battery display
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: []   # All values unsigned
  unit_conversions: ["battery_pct_to_voltage"]  # Convert percentage to voltage
  threshold_monitoring: ["battery_level", "tamper_detected"]  # Monitor for low battery/tamper
  custom_validation_rules: ["door_state_tracking", "tamper_event_counting"]

### Test Configuration
custom_test_scenarios:
  - name: "normal"
    description: "Door closed, installed, normal battery"
    expected_params: ["battery_level", "door_open", "device_installed"]
  - name: "open"
    description: "Door open, installed, normal battery"
    expected_params: ["door_state", "door_open", "device_installed"]
  - name: "tamper"
    description: "Tamper/uninstalled detection"
    expected_params: ["tamper_detected", "device_installed"]
  - name: "low"
    description: "Low battery warning with door open"
    expected_params: ["battery_level", "door_state"]
  - name: "config"
    description: "Device configuration with power-on event"
    expected_params: ["power_on_event", "device_reset", "battery_level"]
  - name: "info"
    description: "Device information with versions and serial"
    expected_params: ["device_sn", "hw_version", "sw_version"]

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
   - Single line: Door state + security status + battery
   - Multi line: Device info (versions, events) when present
   - Conditional line building to prevent empty lines
   - Age indicator for stale data

3. **Robust Error Handling**:
   - Try/catch blocks in decodeUplink and add_web_sensor
   - Console error logging with context
   - Graceful fallback for missing data
   - Recovery after lwreload with global storage

4. **Global Storage Patterns**:
   - WS301_nodes persistent storage
   - Battery trend tracking (last 10 readings)
   - Door state change counting and tracking
   - Tamper event counting and timestamps
   - Reset count tracking

5. **All Downlink Commands Working**:
   - LwWS301SetInterval (60-64800 seconds range)
   - LwWS301Reboot (device reboot command)
   - Proper validation and error messages

6. **Framework Compatibility**:
   - LwDecode v2.2.9 API compliance
   - Template v2.5.0 payload verification
   - TestUI payload validation mandatory
```

### Request Summary
Request ID: WS301-REQ-2025-09-03
Submitted: 2025-09-03 15:20:00
Version Target: v2.0.0
Expected Deliverables:
- [x] Driver file: vendor/milesight/WS301.be
- [x] Documentation: vendor/milesight/WS301.md
- [x] Generation report: vendor/milesight/WS301-REPORT.md

*Form Version: 2.5.0 | Compatible with Template Version: 2.5.0*
*Generated: 2025-09-03 15:20:00 | Framework: LwDecode v2.2.9*
```
