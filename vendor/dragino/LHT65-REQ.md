# Dragino LHT65 Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.3.0 | Platform: Tasmota Berry

---

### Generation Request File (LHT65-REQ.md)

**Purpose**: Document current implementation for future regeneration

```yaml
# Dragino LHT65 Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.3.0 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] FULL - Complete driver with all features

### Device Information
vendor: "Dragino"
model: "LHT65"
type: "Multi-sensor Temperature & Humidity"
description: "Temperature & humidity sensor with 9 external sensor types support"

### Official References
homepage: "https://www.dragino.com/products/lora-lorawan-end-node/item/151-lht65.html"
userguide: "https://www.dragino.com/downloads/downloads/LHT65/UserManual/LHT65_Temperature_Humidity_Sensor_UserManual_v1.8.5.pdf"
decoder_reference: "Official decoder integrated"
firmware_version: "v1.8.5"
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
  custom_emojis: {"temperature": "🌡️", "humidity": "💧", "external": "🔍", "illuminance": "☀️"}
  hide_technical_info: true
  emphasize_alerts: true
  battery_prominance: "normal"
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: ["temperature", "ext_temperature"]
  unit_conversions: ["temperature: /100", "humidity: /10"]
  threshold_monitoring: ["interrupt_triggered", "cable_connected"]
  custom_validation_rules: ["ext_temp: 0x7FFF=invalid", "9_sensor_types"]

### Test Configuration
custom_test_scenarios:
  - name: "normal"
    description: "Standard operation with built-in sensors"
    expected_params: ["temperature", "humidity", "battery_status"]
  - name: "external"
    description: "With external temperature sensor"
    expected_params: ["ext_temperature", "ext_sensor_name"]
  - name: "illumination"
    description: "E5 illumination sensor"
    expected_params: ["illuminance", "cable_connected"]

### Additional Notes
Current Implementation Features (v2.0.0):
```
CRITICAL: Maintain these exact features in regeneration:

1. **Critical Berry Patterns (MANDATORY)**:
   - Template v2.5.0 TestUI payload verification
   - 9 external sensor types complete support
   - Safe keys() iteration patterns
   - Complete multi-sensor display logic

2. **Multi-sensor Support**:
   - E1 Temperature (DS18B20)
   - E4 Interrupt sensor
   - E5 Illumination sensor
   - E6 ADC voltage sensor
   - E7 Counting sensors (16/32-bit)
   - E9 Timestamp mode

3. **Framework Compatibility**:
   - LwDecode v2.3.0 integration
   - Complete downlink command set
```

### Request Summary
Request ID: LHT65-REQ-2025-09-03
Submitted: 2025-09-03 00:00:00
Version Target: v2.0.0
Expected Deliverables:
- [x] Driver file: vendor/dragino/LHT65.be
- [x] Documentation: vendor/dragino/LHT65.md
- [x] Generation report: vendor/dragino/LHT65-REPORT.md

*Form Version: 2.5.0 | Compatible with Template Version: 2.5.0*
*Generated: 2025-09-03 00:00:00 | Framework: LwDecode v2.3.0*
```
