# Milesight AM300 Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.5.0 | Platform: Tasmota Berry

### Generation Request File (AM300-REQ.md)

```yaml
# Milesight AM300 Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.5.0 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] FULL - Complete driver with all features

### Device Information
vendor: "Milesight"
model: "AM300"
type: "Indoor Air Quality Monitor"
description: "9-in-1 air quality monitor with WELL certification"

### Official References
homepage: "https://www.milesight-iot.com/lorawan/sensor/am300/"
userguide: "https://www.milesight-iot.com/lorawan/sensor/am300/"
decoder_reference: "https://www.milesight-iot.com/lorawan/sensor/am300/"
firmware_version: "latest"
lorawan_version: "1.0.3"
regions: ["EU868", "US915", "AS923", "AU915", "IN865", "RU864", "KR920"]

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
    air_quality: ["🟢", "🟡", "🟠", "🔴", "🚨"]
    sensors: ["🌡️", "💧", "💨", "🌬️", "🌫️", "🔵"]
    occupancy: ["🏠", "🚶"]
    well_status: ["✅", "❌"]
  hide_technical_info: false
  emphasize_alerts: true
  battery_prominance: "hidden"
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: ["temperature"]
  unit_conversions: ["pressure:Pa→hPa", "tvoc_level:/100", "hcho_mgm3:/100"]
  threshold_monitoring: ["co2_ppm", "tvoc_level", "pm25_ugm3"]
  custom_validation_rules: ["air_quality_calculation", "well_compliance_check"]

### Test Configuration
custom_test_scenarios:
  - name: "normal"
    description: "Normal indoor air quality conditions"
    expected_params: ["battery_pct", "temperature", "humidity", "co2_ppm", "air_quality_status"]
  - name: "occupied"
    description: "Space occupied with moderate air quality"
    expected_params: ["pir_occupancy", "co2_ppm", "tvoc_level", "air_quality_status"]
  - name: "poor"
    description: "Poor air quality with high pollutants"
    expected_params: ["co2_ppm", "tvoc_level", "pm25_ugm3", "air_quality_status"]
  - name: "excellent"
    description: "Excellent air quality conditions"
    expected_params: ["co2_ppm", "tvoc_level", "pm25_ugm3", "well_status"]
  - name: "alert"
    description: "Alert conditions with high pollutants"
    expected_params: ["co2_ppm", "tvoc_level", "pm25_ugm3", "air_quality_status"]

### Additional Notes
Current Implementation Features (v1.4.0):
```
CRITICAL: Maintain these exact features in regeneration:

1. **Critical Berry Patterns (MANDATORY)**:
   - Explicit key arrays for air quality parameters
   - Safe iteration patterns with found_node flags
   - Static scenario lists in TestUI commands
   - Multi-line display for 9-in-1 sensors

2. **Enhanced Air Quality Display**:
   - Environmental sensors line (temp, humidity, pressure, light)
   - Air quality line (CO2, TVOC, HCHO)
   - Particulate matter line (PM2.5, PM10, O3)
   - Status line (occupancy, air quality, WELL compliance)

3. **Smart Air Quality Calculation**:
   - CO2 impact scoring (>1000ppm high impact)
   - TVOC impact scoring (>3.0 high impact)
   - PM2.5 impact scoring (>55μg/m³ high impact)
   - Combined status (Excellent/Good/Fair/Poor/Unhealthy)

4. **WELL Building Standard Compliance**:
   - CO2 threshold: 800ppm
   - TVOC threshold: 2.0 level
   - PM2.5 threshold: 15μg/m³
   - Real-time compliance checking

5. **All Downlink Commands Working**:
   - LwAM300Interval - Set reporting interval
   - LwAM300Buzzer - Control buzzer alarms
   - LwAM300Screen - E-ink display control
   - LwAM300TimeSync - Time synchronization
   - LwAM300Reboot - Device restart

6. **Framework Compatibility**:
   - Template v2.5.0 with TestUI payload verification
   - Framework v2.4.1 with Berry keys() bug fixes
   - Multi-sensor channel protocol support
   - Air quality emoticon system
```

### Request Summary
Request ID: AM300-REQ-2025-09-02
Submitted: 2025-09-02 20:25:00
Version Target: v1.4.0
Expected Deliverables:
- [x] Driver file: vendor/milesight/AM300.be
- [x] Documentation: vendor/milesight/AM300.md
- [x] Generation report: vendor/milesight/AM300-REPORT.md

*Form Version: 2.5.0 | Compatible with Template Version: 2.5.0*
*Generated: 2025-09-02 20:25:00 | Framework: LwDecode v2.5.0*
```