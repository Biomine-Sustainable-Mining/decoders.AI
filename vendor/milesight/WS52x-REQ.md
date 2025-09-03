# Milesight WS52x Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

---

### Generation Request File (WS52x-REQ.md)

```yaml
# Milesight WS52x Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] FULL - Complete driver with all features

### Device Information
vendor: "Milesight"
model: "WS52x"
type: "Smart Power Socket"
description: "Smart socket series with comprehensive power monitoring and slideshow support"

### Official References
homepage: "https://www.milesight.com/iot/product/lorawan-sensor/ws52x"
userguide: "WS52x_LoRaWAN_Application_Guide.pdf"
decoder_reference: "Official Milesight Decoder"
firmware_version: "latest"
lorawan_version: "1.0.3"
regions: [EU868, US915, AU915, AS923, KR920, IN865, RU864]

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
    locked: "🔒"
    outage: "⚠️"
    reset: "🔄"
    ack: "✅"
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
  legacy_support: ["slideshow_generation"]

### Test Configuration
custom_test_scenarios:
  - name: "normal"
    description: "Normal operation with 100W load, socket ON"
    expected_params: ["voltage", "active_power", "current", "energy", "socket_on"]
  - name: "high" 
    description: "High power load scenario (1000W)"
    expected_params: ["voltage", "active_power", "current", "socket_on"]
  - name: "off"
    description: "Socket OFF state"
    expected_params: ["voltage", "socket_on"]
  - name: "config"
    description: "Configuration parameters display"
    expected_params: ["sw_version", "led_enabled", "oc_alarm_enabled"]
  - name: "events"
    description: "Multiple events (power on, outage)"
    expected_params: ["power_on_event", "power_outage_event"]
  - name: "ack"
    description: "Command acknowledgment handling"
    expected_params: ["ack_received"]

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
   - Multi-line: Socket state + power metrics
   - Line 2: Energy (smart scaling) + power factor
   - Line 3: Device info (versions, protection settings)
   - Line 4: Events (power on/outage, ACK, resets)
   - Conditional line building to prevent empty lines

3. **Legacy Slideshow Support**:
   - build_slideshow_slides() method maintained
   - LwWS52xSlideshow command preserved
   - Safe iteration patterns in slide generation
   - Guaranteed slide content with placeholders

4. **Robust Error Handling**:
   - Try/catch blocks in decodeUplink and add_web_sensor
   - Console error logging with context
   - Graceful fallback for missing data
   - Recovery after lwreload with global storage

5. **Global Storage Patterns**:
   - WS52x_nodes persistent storage
   - Energy consumption tracking (last 10 readings)
   - Power consumption trends
   - Socket state change counting
   - Reset/power event tracking

6. **All Downlink Commands Working**:
   - LwWS52xControl (socket on/off)
   - LwWS52xInterval (reporting interval)
   - LwWS52xReboot (device reboot)
   - LwWS52xOCAlarm (overcurrent alarm config)
   - LwWS52xOCProtection (overcurrent protection)
   - LwWS52xButtonLock (physical button lock)
   - LwWS52xLED (LED control)
   - LwWS52xPowerRecording (energy recording)
   - LwWS52xResetEnergy (counter reset)
   - LwWS52xStatus (status enquiry)
   - LwWS52xDelayTask (delayed actions)
   - LwWS52xDeleteTask (task management)

7. **Framework Compatibility**:
   - LwDecode v2.2.9 API compliance
   - Template v2.5.0 payload verification
   - TestUI payload validation mandatory
   - Legacy slideshow support maintained
```

### Request Summary
Request ID: WS52x-REQ-2025-09-03
Submitted: 2025-09-03 15:35:00
Version Target: v2.0.0
Expected Deliverables:
- [x] Driver file: vendor/milesight/WS52x.be
- [x] Documentation: vendor/milesight/WS52x.md
- [x] Generation report: vendor/milesight/WS52x-REPORT.md

*Form Version: 2.5.0 | Compatible with Template Version: 2.5.0*
*Generated: 2025-09-03 15:35:00 | Framework: LwDecode v2.2.9*
```
