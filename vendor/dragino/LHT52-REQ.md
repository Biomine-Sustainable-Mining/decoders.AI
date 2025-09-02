# Dragino LHT52 Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.3.0 | Platform: Tasmota Berry

---

### Generation Request File (LHT52-REQ.md)

**Purpose**: Document current implementation for future regeneration

```yaml
# Dragino LHT52 Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.3.0 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] FULL - Complete driver with all features

### Device Information
vendor: "Dragino"
model: "LHT52"
type: "Temperature & Humidity Sensor"
description: "Temperature & humidity sensor with datalog and optional external DS18B20"

### Official References
homepage: "https://wiki.dragino.com/xwiki/bin/view/Main/User%20Manual%20for%20LoRaWAN%20End%20Nodes/LHT52%20-%20LoRaWAN%20Temperature%20%26%20Humidity%20Sensor%20User%20Manual/"
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
  custom_emojis: {"temperature": "🌡️", "humidity": "💧", "external": "🔍"}
  hide_technical_info: true
  emphasize_alerts: true
  battery_prominance: "normal"
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: ["temperature", "external_temperature"]
  unit_conversions: ["temperature: /100", "humidity: /10"]
  threshold_monitoring: []
  custom_validation_rules: ["external_temp: 0x7FFF=invalid"]

### Test Configuration
custom_test_scenarios:
  - name: "normal"
    description: "Normal temperature and humidity"
    expected_params: ["temperature", "humidity", "timestamp"]
  - name: "external"
    description: "With external temperature sensor"
    expected_params: ["external_temperature", "extension_name"]
  - name: "config"
    description: "Device configuration"
    expected_params: ["fw_version", "frequency_band", "device_info"]

### Additional Notes
Current Implementation Features (v2.0.0):
```
CRITICAL: Maintain these exact features in regeneration:

1. **Critical Berry Patterns (MANDATORY)**:
   - Template v2.5.0 TestUI payload verification
   - Safe keys() iteration with found_node flag
   - Signed temperature handling with proper conversion
   - Try/catch error handling in display

2. **Enhanced UI Display**:
   - Temperature and humidity formatters
   - External sensor support display
   - Battery voltage display
   - Multi-mode status indicators

3. **Global Storage Patterns**:
   - Multi-node support with LHT52_nodes
   - Battery history tracking
   - Node statistics and management

4. **All Downlink Commands Working**:
   - Transmission interval setting
   - Device reset and factory reset
   - Status and sensor ID requests
   - Historical data polling

5. **Framework Compatibility**:
   - LwDecode v2.3.0 integration
   - SendDownlink/SendDownlinkMap usage
```

### Request Summary
Request ID: LHT52-REQ-2025-09-03
Submitted: 2025-09-03 00:00:00
Version Target: v2.0.0
Expected Deliverables:
- [x] Driver file: vendor/dragino/LHT52.be
- [x] Documentation: vendor/dragino/LHT52.md
- [x] Generation report: vendor/dragino/LHT52-REPORT.md

*Form Version: 2.5.0 | Compatible with Template Version: 2.5.0*
*Generated: 2025-09-03 00:00:00 | Framework: LwDecode v2.3.0*
```
