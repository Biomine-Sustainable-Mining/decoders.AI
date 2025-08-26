# Dragino SE01-LB Generation Request
## Version: 2.3.6 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

---

### Generation Request File (SE01-LB-REQ.md)

**Purpose**: Document current implementation for future regeneration

```yaml
# Dragino SE01-LB Driver Generation Request
## Version: 2.3.6 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] UPGRADE - Framework v2.2.9 + Template v2.3.6

### Device Information
vendor: "Dragino"
model: "SE01-LB"
type: "Soil Moisture & EC Sensor"
description: "LoRaWAN soil moisture, temperature and conductivity sensor with external DS18B20 support"

### Official References
homepage: "https://www.dragino.com/products/agriculture-weather-station/item/277-se01-lb.html"
userguide: "https://wiki.dragino.com/xwiki/bin/view/Main/User%20Manual%20for%20LoRaWAN%20End%20Nodes/SE01-LB_LoRaWAN_Soil%20Moisture%26EC_Sensor_User_Manual/"
decoder_reference: "https://github.com/dragino/dragino-end-node-decoder/tree/main/"
firmware_version: "latest"
lorawan_version: "1.0.3"
regions: ["EU868", "US915", "CN470", "AS923", "AU915", "IN865", "KR920", "EU433"]

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
  single_line_preferred: false  # Multi-line for sensor data + device status
  multi_line_for_alerts: true
  custom_emojis: 
    soil_moisture: "💧"
    soil_temp: "🌡️"
    soil_ec: "⚡"
    ext_temp: "🌡️"
    mode: "⚙️"
    count: "🔢"
    datalog: "📊"
  hide_technical_info: false
  emphasize_alerts: true
  battery_prominance: "normal"
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: ["ds18b20_temperature", "soil_temperature"]
  unit_conversions: 
    - "moisture: /100.0 (percentage)"
    - "soil_temp: /100.0 (celsius)" 
    - "battery: /1000.0 (volts)"
    - "conductivity: raw (µS/cm)"
  threshold_monitoring: []
  custom_validation_rules:
    - "ds18b20_temp > 300 = disconnected sensor"
    - "payload size: 11 bytes (interrupt), 15 bytes (counting)"

### Test Configuration
custom_test_scenarios:
  - name: "normal"
    description: "Normal soil monitoring with moderate values"
    expected_params: ["soil_moisture", "soil_temperature", "soil_conductivity", "ds18b20_temperature", "battery_v"]
  - name: "dry"
    description: "Dry soil conditions with low moisture"
    expected_params: ["soil_moisture", "soil_temperature", "soil_conductivity", "battery_v"]
  - name: "wet"
    description: "Wet soil conditions with high moisture"
    expected_params: ["soil_moisture", "soil_temperature", "soil_conductivity", "battery_v"]
  - name: "counting"
    description: "Counting mode operation with count value"
    expected_params: ["soil_moisture", "count_value", "counting_mode", "battery_v"]
  - name: "raw"
    description: "Raw mode with unprocessed ADC values"
    expected_params: ["soil_conductivity_raw", "soil_moisture_raw", "battery_v"]
  - name: "status"
    description: "Device status information (FPort=5)"
    expected_params: ["sensor_model", "firmware_version", "frequency_band", "battery_v"]
  - name: "disconn"
    description: "External DS18B20 sensor disconnected"
    expected_params: ["ds18b20_disconnected", "soil_moisture", "battery_v"]
  - name: "lowbatt"
    description: "Low battery warning condition"
    expected_params: ["soil_moisture", "battery_v"]

### Additional Notes
Current Implementation Features (v1.1.0):
```
CRITICAL: Maintain these exact features in regeneration:

1. **Critical Berry Patterns (MANDATORY)**:
   - Global storage patterns: SE01LB_nodes for multi-device support
   - Error handling with try/catch blocks in display functions
   - Display error protection prevents UI crashes
   - Global storage recovery after driver reload
   - RSSI/FPort uppercase parameter compatibility

2. **Enhanced UI Display**:
   - Multi-line format for comprehensive soil sensor data
   - External DS18B20 temperature sensor integration
   - Working mode indicator (Cal/Raw)
   - Counting mode display with count values
   - Device status information (firmware, frequency band)
   - Sensor disconnect detection and alerts

3. **Robust Error Handling**:
   - Payload size validation for different modes
   - DS18B20 disconnect detection (temp > 300°C)
   - Try/catch blocks in all display functions
   - Fallback data recovery from global storage

4. **Global Storage Patterns**:
   - Multi-node support with persistent storage
   - Battery history tracking (last 10 readings)
   - Soil moisture trend tracking
   - Count increment tracking for counting mode
   - Node statistics and management commands

5. **All Downlink Commands Working**:
   - LwSE01LBInterval: Set transmit interval (30-16777215 seconds)
   - LwSE01LBReset: Device reset
   - LwSE01LBConfirm: Set confirm mode (on/off)
   - LwSE01LBInterrupt: Interrupt mode control (disable/rising edge)
   - LwSE01LBPower5V: 5V output duration (0-65535ms)
   - LwSE01LBSetCount: Set count value (0-4294967295)
   - LwSE01LBMode: Working mode (default/raw)
   - LwSE01LBCountMode: Count mode (interrupt/counting)
   - LwSE01LBStatus: Request device status
   - LwSE01LBPollLog: Poll datalog with timestamp range

6. **Framework Compatibility**:
   - Framework v2.2.9: RSSI/FPort uppercase, simulated parameter
   - Template v2.3.6: Enhanced error handling patterns
   - Multi-mode support: Default/Raw modes, Interrupt/Counting modes
   - External sensor integration with DS18B20 support
   - Datalog functionality with timestamp parsing
```

### Request Summary
Request ID: SE01LB-REQ-2025-08-26
Submitted: 2025-08-26 14:55:00
Version Target: v1.1.0
Expected Deliverables:
- [x] Driver file: vendor/dragino/SE01-LB.be
- [x] Documentation: vendor/dragino/SE01-LB.md
- [x] Generation report: vendor/dragino/SE01-LB-REPORT.md

*Form Version: 2.3.6 | Compatible with Template Version: 2.3.6*
*Generated: 2025-08-26 14:55:00 | Framework: LwDecode v2.2.9*
```

## 🎯 OBJECTIVE
Template upgrade from v2.3.3 to v2.3.6 for SE01-LB driver maintaining all existing functionality while adding enhanced error handling patterns and framework compatibility updates.

---

### Upgrade Changes Applied
- **Framework v2.2.9**: RSSI/FPort uppercase parameter compatibility and simulated parameter support
- **Template v2.3.6**: Enhanced try/catch error handling in display functions
- **Global Storage Recovery**: Fallback patterns for data recovery after driver reload
- **Display Error Protection**: Error handling prevents UI crashes from display issues

---
*SE01-LB Generation Request v1.1.0 - Framework v2.2.9 + Template v2.3.6*
*Generated: 2025-08-26 | Status: Template Upgrade Complete*
