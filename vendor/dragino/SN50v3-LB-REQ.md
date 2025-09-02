# Dragino SN50v3-LB Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.5.0 | Platform: Tasmota Berry

---

### Generation Request File (SN50v3-LB-REQ.md)

**Purpose**: Document current implementation for future regeneration

```yaml
# Dragino SN50v3-LB Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.5.0 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] FULL - Complete driver with all features

### Device Information
vendor: "Dragino"
model: "SN50v3-LB"
type: "Generic LoRaWAN Sensor Node"
description: "Multi-mode sensor node with 12 working modes"

### Official References
homepage: "https://wiki.dragino.com/xwiki/bin/view/Main/User%20Manual%20for%20LoRaWAN%20End%20Nodes/SN50v3-LB/"
userguide: "https://wiki.dragino.com/xwiki/bin/view/Main/User%20Manual%20for%20LoRaWAN%20End%20Nodes/SN50v3-LB/"
decoder_reference: "https://wiki.dragino.com/xwiki/bin/view/Main/User%20Manual%20for%20LoRaWAN%20End%20Nodes/SN50v3-LB/"
firmware_version: "latest"
lorawan_version: "1.0.3"
regions: ["CN470", "EU433", "KR920", "US915", "EU868", "AS923", "AU915", "IN865"]

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
  single_line_preferred: false
  multi_line_for_alerts: true
  custom_emojis: 
    default_mode: "🔧"
    distance_mode: "📏"
    weight_mode: "⚖️"
    counting_mode: "🔢"
    temperature: "🌡️"
    interrupt: "⚡"
    adc: "📊"
  hide_technical_info: false
  emphasize_alerts: true
  battery_prominance: "normal"
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: ["ds18b20_temp", "sht31_temp", "temp117_temp"]
  unit_conversions: ["weight:g→kg", "distance:mm→m", "battery:mV→V"]
  threshold_monitoring: []
  custom_validation_rules: ["working_mode_detection", "payload_size_validation"]

### Test Configuration
custom_test_scenarios:
  - name: "normal"
    description: "Normal default mode operation with SHT31 sensor"
    expected_params: ["battery_v", "ds18b20_temp", "working_mode", "sht31_temp", "sht31_humidity"]
  - name: "distance"
    description: "Distance measurement mode with LIDAR/ultrasonic"
    expected_params: ["battery_v", "ds18b20_temp", "working_mode", "distance"]
  - name: "weight"
    description: "Weight measurement mode with HX711 load cell"
    expected_params: ["battery_v", "ds18b20_temp", "working_mode", "weight"]
  - name: "counting"
    description: "Digital pulse counting mode"
    expected_params: ["battery_v", "ds18b20_temp", "working_mode", "count_value"]
  - name: "3adc"
    description: "Three ADC channels + I2C sensor mode"
    expected_params: ["adc1_value", "adc2_value", "adc3_value", "sht31_temp", "sht31_humidity"]
  - name: "3ds18b20"
    description: "Three DS18B20 temperature sensors"
    expected_params: ["battery_v", "ds18b20_temp1", "ds18b20_temp2", "ds18b20_temp3"]
  - name: "interrupt"
    description: "Three interrupt mode"
    expected_params: ["battery_v", "ds18b20_temp", "interrupt1", "interrupt2", "interrupt3"]
  - name: "temp117"
    description: "High precision TEMP117 sensor"
    expected_params: ["battery_v", "ds18b20_temp", "working_mode", "temp117_temp"]
  - name: "status"
    description: "Device status information"
    expected_params: ["sensor_model", "firmware_version", "frequency_band", "battery_v"]
  - name: "multi"
    description: "Multi-count mode with two counters"
    expected_params: ["battery_v", "ds18b20_temp1", "ds18b20_temp2", "ds18b20_temp3", "count1_value", "count2_value"]

### Additional Notes
Current Implementation Features (v1.3.0):
```
CRITICAL: Maintain these exact features in regeneration:

1. **Critical Berry Patterns (MANDATORY)**:
   - Explicit key arrays for data recovery
   - Safe iteration patterns with found_node flags
   - Static scenario lists in TestUI commands
   - Nil safety in all comparisons

2. **Enhanced UI Display**:
   - Multi-line display for complex modes
   - Mode-specific emoji mapping
   - Working mode detection and display
   - Secondary sensor line for multi-sensor modes

3. **Robust Error Handling**:
   - Try/catch blocks in all major functions
   - Display error protection with fallback messages
   - Payload size validation
   - Mode detection logic with fallbacks

4. **Global Storage Patterns**:
   - Node-specific data persistence
   - Battery trend tracking
   - Working mode state preservation
   - Recovery after driver reload

5. **All Downlink Commands Working**:
   - LwSN50v3LBInterval - Set transmission interval
   - LwSN50v3LBStatus - Request device status
   - LwSN50v3LBMode - Set working mode (1-12 or names)
   - LwSN50v3LBInterrupt - Configure interrupt pins
   - LwSN50v3LBOutput - Set 5V output duration
   - LwSN50v3LBWeight - Weight calibration commands
   - LwSN50v3LBSetCount - Set counter values

6. **Framework Compatibility**:
   - Template v2.5.0 with TestUI payload verification
   - Framework v2.4.1 with Berry keys() bug fixes
   - All payloads verified to decode correctly
   - Multi-mode intelligent detection system
```

### Request Summary
Request ID: SN50v3-LB-REQ-2025-09-02
Submitted: 2025-09-02 20:20:00
Version Target: v1.3.0
Expected Deliverables:
- [x] Driver file: vendor/dragino/SN50v3-LB.be
- [x] Documentation: vendor/dragino/SN50v3-LB.md
- [x] Generation report: vendor/dragino/SN50v3-LB-REPORT.md

*Form Version: 2.5.0 | Compatible with Template Version: 2.5.0*
*Generated: 2025-09-02 20:20:00 | Framework: LwDecode v2.5.0*
```