# Milesight AM300 Driver Generation Request
## Version: 2.3.6 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] FULL - Complete driver with all features

### Device Information
vendor: "Milesight"
model: "AM300"
type: "Indoor Air Quality Monitor"
description: "9-in-1 environmental sensor with E-ink display and WELL certification"

### Official References
homepage: "https://www.milesight-iot.com/lorawan/sensor/am300/"
userguide: "https://resource.milesight-iot.com/milesight/iot/document/am300-user-guide.pdf"
decoder_reference: "https://github.com/Milesight-IoT/SensorDecoders/tree/master/AM_Series"
firmware_version: "latest"
lorawan_version: "1.0.3"
regions: ["EU868", "US915", "AS923", "AU915", "IN865", "RU864", "KR920"]

### Feature Selection
include_features:
  uplink_decoding: true
  downlink_commands: true
  test_ui_scenarios: true
  node_management: true
  battery_tracking: true      # 4×2700mAh ER14505 Li-SOCl2 batteries
  reset_detection: true
  configuration_sync: true
  error_recovery: true
  performance_optimization: true

### UI Customization
display_preferences:
  single_line_preferred: false  # Multi-line required for 9 sensors
  multi_line_for_alerts: true
  custom_emojis: {
    "co2": "🌬️",
    "tvoc": "🏭", 
    "pm25": "🌫️",
    "pm10": "💨",
    "hcho": "🧪",
    "o3": "⚗️",
    "pir_occupied": "🟢",
    "pir_vacant": "⚫",
    "buzzer_on": "🔊",
    "buzzer_off": "🔇"
  }
  hide_technical_info: false    # Show firmware versions and device info
  emphasize_alerts: true
  battery_prominance: "normal"  # Replaceable batteries with 4+ year life
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: ["temperature"]   # Signed 16-bit temperature values
  unit_conversions: {
    "tvoc_level": "IAQ_index_to_display",
    "hcho": "mg_m3_precision_2",
    "o3": "ppm_precision_3",
    "pressure": "hPa_precision_1"
  }
  threshold_monitoring: ["co2", "tvoc_level", "pm25", "pm10", "hcho", "o3"] # All air quality params
  custom_validation_rules: {
    "light_level": "range_0_to_10",
    "pir": "binary_0_1",
    "co2": "range_400_to_5000"
  }

### Test Configuration
custom_test_scenarios:
  - name: "normal"
    description: "Normal air quality with good ventilation"
    expected_params: ["temperature", "humidity", "co2", "tvoc_level", "pressure", "battery"]
  - name: "good"
    description: "Excellent air quality conditions"
    expected_params: ["temperature", "humidity", "co2", "tvoc_level", "pressure"]
  - name: "moderate"
    description: "Moderate air quality with some pollution"
    expected_params: ["temperature", "humidity", "co2", "tvoc_level", "pm25", "pm10"]
  - name: "poor"
    description: "Poor air quality exceeding thresholds"
    expected_params: ["co2", "tvoc_level", "pm25", "pm10", "hcho"]
  - name: "occupied"
    description: "Motion detected scenario with PIR active"
    expected_params: ["pir", "pir_status", "light_level"]
  - name: "alert"
    description: "High pollution alert with multiple parameters exceeded"
    expected_params: ["co2", "tvoc_level", "pm25", "pm10", "hcho", "o3"]
  - name: "info"
    description: "Device information and configuration response"
    expected_params: ["fw_version", "hw_version", "protocol_version", "serial_number"]
  - name: "buzzer_on"
    description: "Audio alert activated with buzzer status"
    expected_params: ["buzzer_status", "buzzer", "activity_event"]

### Additional Notes
Current Implementation Features (v1.2.0):
```
CRITICAL: Maintain these exact features in regeneration:

1. **Critical Berry Patterns (MANDATORY)**:
   - Multi-channel protocol parsing with proper i += increments
   - Signed temperature handling with 32767 threshold conversion
   - Global storage with AM300_nodes persistent across reloads
   - Conditional display logic to avoid empty lines in UI
   - Proper emoji usage for all 9 air quality sensors

2. **Enhanced UI Display**:
   - Multi-line format: Environmental -> Air Quality -> Chemical -> Status
   - Conditional content blocks to prevent empty lines
   - Specialized air quality emojis: 🌬️🏭🌫️💨🧪⚗️
   - PIR status with 🟢 Occupied / ⚫ Vacant display
   - Smart formatting with units and precision for each sensor

3. **Robust Error Handling**:
   - Try/catch blocks in both decodeUplink and add_web_sensor
   - Display error protection returning "📟 AM300 Error - Check Console"
   - Nil safety checks for all data access
   - Global storage recovery for data persistence after reload

4. **Global Storage Patterns**:
   - AM300_nodes map with node-specific data persistence
   - Battery history tracking (last 10 readings)
   - Activity and power event counting with timestamps
   - Node data structure: last_data, last_update, name, battery_history, activity_count

5. **All Downlink Commands Working**:
   - LwAM300Interval<slot> - reporting interval (1-1440 minutes)
   - LwAM300Buzzer<slot> - buzzer control (on/off)
   - LwAM300Screen<slot> - E-ink screen control (on/off)
   - LwAM300TimeSync<slot> - time synchronization
   - LwAM300Reboot<slot> - device reboot

6. **Framework Compatibility**:
   - Framework v2.2.9 compliance with enhanced error handling
   - Template v2.3.6 with REQ file generation workflow
   - LwSensorFormatter_cls() proper usage with get_msg() string safety
   - Global node management with statistics and data clearing commands
```

### Request Summary
Request ID: AM300-REQ-2025-08-26
Submitted: 2025-08-26 11:30:00
Version Target: v1.2.0
Expected Deliverables:
- [x] Driver file: vendor/milesight/AM300.be
- [x] Documentation: vendor/milesight/AM300.md
- [x] MAP cache: vendor/milesight/AM300-MAP.md
- [x] Generation report: vendor/milesight/AM300-REPORT.md

*Form Version: 2.3.6 | Compatible with Template Version: 2.3.6*
*Generated: 2025-08-26 11:30:00 | Framework: LwDecode v2.2.9*
