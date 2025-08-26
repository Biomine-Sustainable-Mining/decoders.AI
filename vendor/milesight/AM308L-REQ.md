# Milesight AM308L Driver Generation Request
## Version: 2.3.6 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] FULL - Complete driver with all features

### Device Information
vendor: "Milesight"
model: "AM308L"
type: "Ambience Monitoring Sensor"
description: "Multi-sensor environmental monitoring device with CO2, TVOC, PM2.5/PM10, temperature, humidity, pressure, PIR, and light sensing"

### Official References
homepage: "https://www.milesight.com/iot/product/lorawan-sensor/am319"
userguide: "https://github.com/Milesight-IoT/SensorDecoders/tree/main/am-series/am308l"
decoder_reference: "https://github.com/Milesight-IoT/SensorDecoders/blob/main/am-series/am308l/am308l-decoder.js"
firmware_version: "latest"
lorawan_version: "1.0.x"
regions: ["EU868", "US915", "AS923", "AU915"]

### Feature Selection
include_features:
  uplink_decoding: true
  downlink_commands: true
  test_ui_scenarios: true
  node_management: true
  battery_tracking: true
  reset_detection: true
  configuration_sync: true
  error_recovery: true
  performance_optimization: true

### UI Customization
display_preferences:
  single_line_preferred: false  # Multi-line for comprehensive sensor data
  multi_line_for_alerts: true
  custom_emojis: 
    co2: "💨"
    pm25: "🫧"
    pm10: "🌫️"
    tvoc: "🌿"
    pressure: "🔵"
    motion: "🚶"
  hide_technical_info: false
  emphasize_alerts: true
  battery_prominance: "normal"
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: ["temperature"]
  unit_conversions: 
    - "temperature: int16/10"
    - "humidity: uint8/2"
    - "pressure: uint16/10"
    - "tvoc_iaq: uint16/100"
  threshold_monitoring: ["co2", "tvoc", "pm2_5", "pm10"]
  custom_validation_rules:
    - "co2: 400-5000 ppm"
    - "report_interval: 10-86400 seconds"
    - "timezone: -120 to 140"

### Test Configuration
custom_test_scenarios:
  - name: "normal"
    description: "Normal environmental readings"
    expected_params: ["temperature", "humidity", "co2", "tvoc", "pressure", "pm2_5", "pm10"]
  - name: "alert"
    description: "High pollution alert conditions"
    expected_params: ["temperature", "humidity", "co2", "tvoc"]
  - name: "high"
    description: "Maximum sensor readings"
    expected_params: ["temperature", "humidity", "co2", "tvoc", "pressure", "pm2_5", "pm10"]
  - name: "motion"
    description: "PIR motion detection"
    expected_params: ["temperature", "humidity", "pir", "light_level", "co2", "tvoc"]
  - name: "history"
    description: "Historical data payload"
    expected_params: ["history"]
  - name: "config"
    description: "Device configuration data"
    expected_params: ["ipso_version", "hardware_version", "firmware_version", "serial_number", "battery", "device_status"]

### Additional Notes
Current Implementation Features (v1.0.0):
```
CRITICAL: Maintain these exact features in regeneration:

1. **Critical Berry Patterns (MANDATORY)**:
   - Channel-based decoding with complete coverage
   - Dual TVOC unit support (IAQ and µg/m³)
   - History data decoding for both formats
   - Proper signed temperature handling

2. **Enhanced UI Display**:
   - Multi-line display for comprehensive sensor data
   - Air quality grouping (PM2.5, PM10, pressure)
   - Status events line (motion, buzzer, reset)
   - Device info line for configuration data

3. **Robust Error Handling**:
   - Try/catch in display function
   - Global storage recovery patterns
   - Unknown channel logging

4. **Global Storage Patterns**:
   - AM308L_nodes global storage
   - Battery trend tracking
   - Reset event counting
   - Node data persistence

5. **All Downlink Commands Working**:
   - 22 complete downlink commands implemented
   - Device reboot, buzzer control, status query
   - Configuration: report interval, time sync, time zone
   - TVOC unit switching, PM2.5 collection interval
   - CO2 calibration (ABC and manual)
   - LED indicator, child lock, retransmit settings
   - History management commands

6. **Framework Compatibility**:
   - LwDecode v2.2.9 integration
   - Template v2.3.6 compliance
   - SendDownlink and SendDownlinkMap usage
```

### Request Summary
Request ID: AM308L-REQ-2025-08-26
Submitted: 2025-08-26 16:53:42
Version Target: v1.0.0
Expected Deliverables:
- [x] Driver file: vendor/milesight/AM308L.be
- [x] Documentation: vendor/milesight/AM308L.md
- [x] Generation report: vendor/milesight/AM308L-REPORT.md

*Form Version: 2.3.6 | Compatible with Template Version: 2.3.6*
*Generated: 2025-08-26 16:53:42 | Framework: LwDecode v2.2.9*
