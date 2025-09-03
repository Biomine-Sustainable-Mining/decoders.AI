# Milesight WS523 Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

---

### Generation Request File (WS523-REQ.md)

```yaml
# Milesight WS523 Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] FULL - Complete driver with all features

### Device Information
vendor: "Milesight"
model: "WS523"
type: "Portable Smart Socket"
description: "AC power monitoring and control with overcurrent protection"

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
  battery_tracking: false     # Mains powered device
  reset_detection: true
  configuration_sync: true
  error_recovery: true
  performance_optimization: true

### UI Customization
display_preferences:
  single_line_preferred: false # Multi-line for power data
  multi_line_for_alerts: true
  custom_emojis:
    socket_on: "🟢"
    socket_off: "⚫"
    voltage: "⚡"
    current: "🔌"
    power: "💡"
    energy: "🏠"
    power_factor: "📊"
    protection: "🛡️"
    alarm: "🚨"
    locked: "🔒"
    outage: "⚠️"
    reset: "🔄"
  hide_technical_info: false
  emphasize_alerts: true
  battery_prominance: "hidden"  # Mains powered
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: ["active_power"]  # Power can be negative
  unit_conversions: ["smart_energy_scaling"]  # Wh -> kWh -> MWh -> GWh
  threshold_monitoring: ["overcurrent_alarm", "overcurrent_protection"]
  custom_validation_rules: ["power_monitoring_validation"]

### Test Configuration
custom_test_scenarios:
  - name: "normal"
    description: "Normal operation with 100W load, socket ON"
    expected_params: ["voltage", "active_power", "current", "energy_wh", "socket_on"]
  - name: "high_power"
    description: "High power load scenario (800W+)"
    expected_params: ["voltage", "active_power", "current", "socket_on"]
  - name: "low_power"
    description: "Low power or OFF state"
    expected_params: ["voltage", "active_power", "socket_on"]
  - name: "outage"
    description: "Power outage event detection"
    expected_params: ["power_outage_event", "socket_on"]
  - name: "config"
    description: "Configuration parameters display"
    expected_params: ["sw_version", "oc_alarm_enabled"]
  - name: "events"
    description: "Multiple events (power on, reset, etc.)"
    expected_params: ["power_on_event", "device_reset"]

### Additional Notes
Current Implementation Features (v4.0.0):
```
CRITICAL: Maintain these exact features in regeneration:

1. **Critical Berry Patterns (MANDATORY)**:
   - Safe keys() iteration with found_node flag
   - Explicit key arrays for data recovery
   - Static scenario lists in TestUI commands
   - Nil safety in all comparisons
   - Display error protection with try/catch

2. **Enhanced UI Display**:
   - Multi-line: Socket state + power metrics
   - Line 2: Power factor + energy (smart scaling)
   - Line 3: Device info (versions, protection settings)
   - Line 4: Events (power on/outage, alarms, resets)
   - Conditional line building to prevent empty lines

3. **Robust Error Handling**:
   - Try/catch blocks in decodeUplink and add_web_sensor
   - Console error logging with context
   - Graceful fallback for missing data
   - Recovery after lwreload with global storage

4. **Global Storage Patterns**:
   - WS523_nodes persistent storage
   - Energy consumption tracking (last 10 readings)
   - Power consumption trends
   - Socket state change counting
   - Reset/power event tracking

5. **All Downlink Commands Working**:
   - LwWS523Control (socket on/off)
   - LwWS523Interval (reporting interval)
   - LwWS523DelayTask (delayed actions)
   - LwWS523DeleteTask (task management)
   - LwWS523OCAlarm (overcurrent alarm config)
   - LwWS523ButtonLock (physical button lock)
   - LwWS523PowerRecording (energy recording)
   - LwWS523ResetEnergy (counter reset)
   - LwWS523Status (status request)
   - LwWS523LED (LED control)
   - LwWS523OCProtection (overcurrent protection)
   - LwWS523Reboot (device reboot)

6. **Framework Compatibility**:
   - LwDecode v2.2.9 API compliance
   - Template v2.5.0 payload verification
   - TestUI payload validation mandatory
```

### Request Summary
Request ID: WS523-REQ-2025-09-03
Submitted: 2025-09-03 15:30:00
Version Target: v4.0.0
Expected Deliverables:
- [x] Driver file: vendor/milesight/WS523.be
- [x] Documentation: vendor/milesight/WS523.md
- [x] Generation report: vendor/milesight/WS523-REPORT.md

*Form Version: 2.5.0 | Compatible with Template Version: 2.5.0*
*Generated: 2025-09-03 15:30:00 | Framework: LwDecode v2.2.9*
```
