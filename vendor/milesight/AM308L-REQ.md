# Milesight AM308L Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.5.0 | Platform: Tasmota Berry

### Generation Request File (AM308L-REQ.md)

```yaml
# Milesight AM308L Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.5.0 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] FULL - Complete driver with all features

### Device Information
vendor: "Milesight"
model: "AM308L"
type: "Environmental Monitoring Sensor"
description: "Multi-sensor with CO2, TVOC, PM2.5/10, temperature, humidity, pressure, PIR, light"

### Official References
homepage: "https://www.milesight.com/iot/product/lorawan-sensor/am319"
userguide: "https://github.com/Milesight-IoT/SensorDecoders/tree/main/am-series/am308l"
decoder_reference: "https://github.com/Milesight-IoT/SensorDecoders/tree/main/am-series/am308l"
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
  single_line_preferred: false
  multi_line_for_alerts: true
  custom_emojis: 
    sensors: ["🌡️", "💧", "💨", "🌬️", "🌫️", "🔵", "💡"]
    motion: ["🏠", "🚶"]
    history: "📊"
    calibration: "⚙️"
  hide_technical_info: false
  emphasize_alerts: true
  battery_prominance: "hidden"
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: ["temperature"]
  unit_conversions: ["pressure:Pa→hPa", "tvoc_iaq:/100", "humidity:/2"]
  threshold_monitoring: ["co2_ppm", "tvoc_iaq", "pm25_ugm3"]
  custom_validation_rules: ["history_format_detection", "dual_tvoc_units"]

### Test Configuration
custom_test_scenarios:
  - name: "normal"
    description: "Standard environmental monitoring"
    expected_params: ["battery_pct", "temperature", "humidity", "co2_ppm"]
  - name: "motion"
    description: "PIR motion detection active"
    expected_params: ["pir_motion", "temperature", "air_quality"]
  - name: "history_iaq"
    description: "Historical data in IAQ format"
    expected_params: ["timestamp", "history_type", "tvoc_iaq"]
  - name: "device_info"
    description: "Device information and versions"
    expected_params: ["firmware_version", "serial_number"]

### Additional Notes
Current Implementation Features (v1.2.0):
```
CRITICAL: Maintain these exact features in regeneration:

1. **Dual TVOC Unit Support**:
   - IAQ index format (type 0x7D)
   - µg/m³ concentration format (type 0xE6)
   - History data format detection

2. **Historical Data Decoding**:
   - 20-byte IAQ format (0x20:0xCE)
   - 20-byte µg/m³ format (0x21:0xCE)
   - Timestamp extraction and parsing

3. **Complete Device Info Support**:
   - Firmware/hardware versions
   - Serial number extraction
   - LoRaWAN class identification
   - Reset event detection

4. **CO2 Calibration Commands**:
   - Factory/ABC/Manual/Background/Zero modes
   - Manual calibration with PPM values
   - Comprehensive parameter validation

5. **All Downlink Commands Working**:
   - LwAM308LReboot - Device restart
   - LwAM308LBuzzer - Audio control
   - LwAM308LInterval - Report timing
   - LwAM308LTimeSync - Time synchronization
   - LwAM308LTimeZone - UTC offset
   - LwAM308LTVOCUnit - Unit selection
   - LwAM308LCO2Cal - Calibration modes
   - LwAM308LHistory - History management
```

### Request Summary
Request ID: AM308L-REQ-2025-09-02
Submitted: 2025-09-02 20:30:00
Version Target: v1.2.0
Expected Deliverables:
- [x] Driver file: vendor/milesight/AM308L.be
- [x] Documentation: vendor/milesight/AM308L.md
- [x] Generation report: vendor/milesight/AM308L-REPORT.md

*Form Version: 2.5.0 | Compatible with Template Version: 2.5.0*
*Generated: 2025-09-02 20:30:00 | Framework: LwDecode v2.5.0*
```