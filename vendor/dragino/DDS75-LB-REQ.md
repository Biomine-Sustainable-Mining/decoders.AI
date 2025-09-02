# Dragino DDS75-LB Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.3.0 | Platform: Tasmota Berry

---

### Generation Request File (DDS75-LB-REQ.md)

**Purpose**: Document current implementation for future regeneration

```yaml
# Dragino DDS75-LB Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.3.0 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] FULL - Complete driver with all features

### Device Information
vendor: "Dragino"
model: "DDS75-LB"
type: "Distance Detection Sensor"
description: "Ultrasonic distance sensor with optional DS18B20 temperature probe"

### Official References
homepage: "https://wiki.dragino.com/xwiki/bin/view/Main/User%20Manual%20for%20LoRaWAN%20End%20Nodes/DDS75-LB_LoRaWAN_Distance_Detection_Sensor_User_Manual/"
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
  custom_emojis: {"distance": "📏", "temperature": "🌡️", "interrupt": "⚡"}
  hide_technical_info: true
  emphasize_alerts: true
  battery_prominance: "normal"
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: ["ds18b20_temperature"]
  unit_conversions: ["distance: mm->m", "battery: mV->V"]
  threshold_monitoring: ["interrupt_flag", "sensor_detected"]
  custom_validation_rules: ["distance_invalid: 0x0000/0x0014"]

### Test Configuration
custom_test_scenarios:
  - name: "normal"
    description: "Normal operation with distance and temperature"
    expected_params: ["battery_v", "distance_mm", "temperature"]
  - name: "interrupt"
    description: "Interrupt triggered"
    expected_params: ["interrupt_flag", "distance_mm"]
  - name: "no_sensor"
    description: "No ultrasonic sensor detected"
    expected_params: ["sensor_detected", "distance_status"]
  - name: "config"
    description: "Device configuration and status"
    expected_params: ["fw_version", "frequency_band", "device_info"]

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
   - Distance measurement in meters with precision
   - Optional temperature display
   - Status indicators for sensor issues
   - Interrupt event display

3. **Robust Error Handling**:
   - Distance validation (0x0000=no sensor, 0x0014=invalid)
   - Signed temperature conversion for DS18B20
   - Payload size validation
   - Display error protection

4. **Global Storage Patterns**:
   - Multi-node support with DDS75_LB_nodes
   - Battery and distance history tracking
   - Interrupt event counting
   - Node statistics and management

5. **All Downlink Commands Working**:
   - Transmission interval setting
   - Interrupt mode configuration
   - Delta detect mode with parameters
   - Device status request
   - Historical data polling

6. **Framework Compatibility**:
   - LwDecode v2.3.0 integration
   - SendDownlink/SendDownlinkMap usage
   - Command registration with proper cleanup
```

### Request Summary
Request ID: DDS75-LB-REQ-2025-09-03
Submitted: 2025-09-03 00:00:00
Version Target: v2.0.0
Expected Deliverables:
- [x] Driver file: vendor/dragino/DDS75-LB.be
- [x] Documentation: vendor/dragino/DDS75-LB.md
- [x] Generation report: vendor/dragino/DDS75-LB-REPORT.md

*Form Version: 2.5.0 | Compatible with Template Version: 2.5.0*
*Generated: 2025-09-03 00:00:00 | Framework: LwDecode v2.3.0*
```
