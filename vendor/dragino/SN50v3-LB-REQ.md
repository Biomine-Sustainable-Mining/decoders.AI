# Dragino SN50v3-LB Generation Request
## Version: 2.3.6 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

---

### Generation Request File (SN50v3-LB-REQ.md)

**Purpose**: Document current implementation for future regeneration

```yaml
# Dragino SN50v3-LB Driver Generation Request
## Version: 2.3.6 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] UPGRADE - Framework v2.2.9 + Template v2.3.6

### Device Information
vendor: "Dragino"
model: "SN50v3-LB"
type: "Generic LoRaWAN Sensor Node"
description: "Multi-mode LoRaWAN sensor with 12 working modes including temperature, distance, weight, counting, PWM and more"

### Official References
homepage: "https://www.dragino.com/products/lora-lorawan-end-node/item/260-sn50v3-lb-ls.html"
userguide: "https://wiki.dragino.com/xwiki/bin/view/Main/User%20Manual%20for%20LoRaWAN%20End%20Nodes/SN50v3-LB/"
decoder_reference: "https://github.com/dragino/dragino-end-node-decoder/tree/main/SN50_v3-LB"
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
  single_line_preferred: false  # Multi-line for different working modes
  multi_line_for_alerts: true
  custom_emojis: 
    temperature: "🌡️"
    distance: "📏"
    weight: "⚖️"
    counting: "🔢"
    pwm: "〰️"
    adc: "📊"
    interrupt: "📶"
    mode: "⚙️"
  hide_technical_info: false
  emphasize_alerts: true
  battery_prominance: "normal"
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: ["ds18b20_temperature", "sht31_temperature", "temp117_temperature"]
  unit_conversions: 
    - "battery: /1000.0 (volts)"
    - "temperature: /10.0 (celsius)"
    - "humidity: /10.0 (percentage)"
    - "distance: /10.0 (cm)"
    - "weight: /1000.0 (kg)"
  threshold_monitoring: []
  custom_validation_rules:
    - "12 working modes with different payload structures"
    - "Mode detection from flags byte position 6"
    - "Variable payload sizes based on mode"

### Test Configuration
custom_test_scenarios:
  - name: "default"
    description: "MOD=1 default mode with DS18B20 and I2C sensors"
    expected_params: ["ds18b20_temperature", "i2c_temperature", "i2c_humidity", "adc_pa4", "battery_v"]
  - name: "distance"
    description: "MOD=2 distance measurement mode"
    expected_params: ["distance_cm", "ds18b20_temperature", "adc_pa4", "battery_v"]
  - name: "3adc"
    description: "MOD=3 three ADC channels with I2C"
    expected_params: ["adc1_pa4", "adc2_pa5", "adc3_pa8", "i2c_temperature", "i2c_humidity"]
  - name: "3temp"
    description: "MOD=4 three DS18B20 temperature sensors"
    expected_params: ["ds18b20_1_temperature", "ds18b20_2_temperature", "ds18b20_3_temperature", "battery_v"]
  - name: "weight"
    description: "MOD=5 weight measurement mode"
    expected_params: ["weight_kg", "ds18b20_temperature", "adc_pa4", "battery_v"]
  - name: "counting"
    description: "MOD=6 counting mode"
    expected_params: ["count_value", "ds18b20_temperature", "adc_pa4", "battery_v"]
  - name: "interrupt"
    description: "MOD=7 three interrupt mode"
    expected_params: ["interrupt_pa8", "interrupt_pa4", "interrupt_pb15", "ds18b20_temperature", "battery_v"]
  - name: "pwm"
    description: "MOD=10 PWM mode"
    expected_params: ["frequency_hz", "duty_cycle_pct", "pulse_period", "high_duration", "battery_v"]
  - name: "sht31"
    description: "MOD=12 Count + SHT31 mode"
    expected_params: ["sht31_temperature", "sht31_humidity", "count_value", "battery_v"]
  - name: "status"
    description: "Device status information (FPort=5)"
    expected_params: ["sensor_model", "firmware_version", "frequency_band", "battery_v"]

### Additional Notes
Current Implementation Features (v1.1.0):
```
CRITICAL: Maintain these exact features in regeneration:

1. **Critical Berry Patterns (MANDATORY)**:
   - Global storage patterns: SN50v3LB_nodes for multi-device support
   - Error handling with try/catch blocks in display functions
   - Display error protection prevents UI crashes
   - Global storage recovery after driver reload
   - RSSI/FPort uppercase parameter compatibility

2. **Enhanced UI Display**:
   - Multi-mode display system with 12 working modes
   - Mode-specific sensor data presentation
   - Working mode indicator with MOD numbers
   - Complex sensor combinations (3 temps, 3 ADCs, etc.)
   - Interrupt status display for multiple pins

3. **Robust Error Handling**:
   - Working mode detection from payload flags
   - Variable payload size handling per mode
   - Signed temperature value handling
   - Try/catch blocks in all display functions
   - Fallback data recovery from global storage

4. **Global Storage Patterns**:
   - Multi-node support with persistent storage
   - Battery history tracking (last 10 readings)
   - Temperature trend tracking
   - Count increment tracking for counting modes
   - Node statistics and management commands

5. **All Downlink Commands Working**:
   - LwSN50v3LBInterval: Set transmit interval (30-16777215 seconds)
   - LwSN50v3LBStatus: Request device status
   - LwSN50v3LBInterrupt: Configure interrupt pins and modes
   - LwSN50v3LBPower5V: Set 5V output duration (0-65535ms)
   - LwSN50v3LBWeight: Weight calibration (zero/factor)
   - LwSN50v3LBSetCount: Set counter values for PA8/PA4
   - LwSN50v3LBMode: Set working mode (1-12)
   - LwSN50v3LBPWM: PWM output control (freq/duty/time)
   - LwSN50v3LBPWMSet: PWM time unit (microseconds/milliseconds)

6. **Framework Compatibility**:
   - Framework v2.2.9: RSSI/FPort uppercase, simulated parameter
   - Template v2.3.6: Enhanced error handling patterns
   - 12-mode support with dynamic payload structures
   - Complex sensor combinations and measurement types
   - Comprehensive downlink command set for all modes
```

### Request Summary
Request ID: SN50v3LB-REQ-2025-08-26
Submitted: 2025-08-26 14:56:00
Version Target: v1.1.0
Expected Deliverables:
- [x] Driver file: vendor/dragino/SN50v3-LB.be
- [x] Documentation: vendor/dragino/SN50v3-LB.md
- [x] Generation report: vendor/dragino/SN50v3-LB-REPORT.md

*Form Version: 2.3.6 | Compatible with Template Version: 2.3.6*
*Generated: 2025-08-26 14:56:00 | Framework: LwDecode v2.2.9*
```

## 🎯 OBJECTIVE
Template upgrade from v2.3.3 to v2.3.6 for SN50v3-LB driver maintaining all existing functionality while adding enhanced error handling patterns and framework compatibility updates.

---

### Upgrade Changes Applied
- **Framework v2.2.9**: RSSI/FPort uppercase parameter compatibility and simulated parameter support
- **Template v2.3.6**: Enhanced try/catch error handling in display functions
- **Global Storage Recovery**: Fallback patterns for data recovery after driver reload
- **Display Error Protection**: Error handling prevents UI crashes from display issues

---
*SN50v3-LB Generation Request v1.1.0 - Framework v2.2.9 + Template v2.3.6*
*Generated: 2025-08-26 | Status: Template Upgrade Complete*
