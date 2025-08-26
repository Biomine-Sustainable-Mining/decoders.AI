# Mutelcor MTC-AQ01 Generation Request
## Version: 2.3.6 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

---

### Generation Request File (MTC-AQ01-REQ.md)

**Purpose**: Document current implementation for future regeneration

```yaml
# Mutelcor MTC-AQ01 Driver Generation Request
## Version: 2.3.6 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] UPGRADE - Framework v2.2.9 + Template v2.3.6

### Device Information
vendor: "Mutelcor"
model: "MTC-AQ01"
type: "Air Quality Sensor"
description: "LoRaWAN air quality sensor with temperature, humidity, and pressure measurements plus threshold monitoring"

### Official References
homepage: "https://mutelcor.com/lora-air-quality-sensor/"
userguide: "https://mutelcor.com/wp-content/uploads/2025/05/MUTELCOR_Datasheet_LoRa*Air*Quality_Sensor.pdf"
decoder_reference: "https://mutelcor.com/wp-content/uploads/2025/05/Mutelcor-LoRaWAN-Payload-1.6.0.pdf"
firmware_version: "latest"
lorawan_version: "1.0.3"
regions: ["EU868", "US915", "AS923", "AU915"]

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
  custom_emojis: 
    temperature: "🌡️"
    humidity: "💧"
    pressure: "📊"
    heartbeat: "💓"
    alert: "⚠️"
    normal: "✅"
  hide_technical_info: false
  emphasize_alerts: true
  battery_prominance: "normal"
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: ["temperature"]
  unit_conversions: 
    - "battery: /100.0 (volts)"
    - "temperature: /10.0 (celsius) with signed handling"
    - "humidity: direct (percentage)"
    - "pressure: *10 (Pa) with hPa conversion"
  threshold_monitoring: ["temperature", "humidity", "pressure"]
  custom_validation_rules:
    - "Version validation: payload[0] must be 0x02"
    - "OpCode-based message type detection"
    - "Threshold alert processing with trigger/stop indicators"

### Test Configuration
custom_test_scenarios:
  - name: "heartbeat"
    description: "Periodic heartbeat message"
    expected_params: ["message_type", "battery_v"]
  - name: "normal"
    description: "Normal measurements with all sensors"
    expected_params: ["temperature", "humidity", "pressure_hpa", "battery_v", "message_type"]
  - name: "cold"
    description: "Cold temperature reading"
    expected_params: ["temperature", "humidity", "pressure_hpa", "battery_v"]
  - name: "hot"
    description: "Hot temperature reading"
    expected_params: ["temperature", "humidity", "pressure_hpa", "battery_v"]
  - name: "dry"
    description: "Dry humidity conditions"
    expected_params: ["temperature", "humidity", "pressure_hpa", "battery_v"]
  - name: "humid"
    description: "High humidity conditions"
    expected_params: ["temperature", "humidity", "pressure_hpa", "battery_v"]
  - name: "threshold"
    description: "Threshold alert triggered"
    expected_params: ["threshold_alert", "trigger_thresholds", "stop_thresholds", "message_type"]
  - name: "pressure_high"
    description: "High pressure reading"
    expected_params: ["pressure_hpa", "temperature", "battery_v"]
  - name: "pressure_low"
    description: "Low pressure reading"
    expected_params: ["pressure_hpa", "temperature", "battery_v"]
  - name: "low_battery"
    description: "Low battery warning"
    expected_params: ["temperature", "battery_v"]

### Additional Notes
Current Implementation Features (v1.1.0):
```
CRITICAL: Maintain these exact features in regeneration:

1. **Critical Berry Patterns (MANDATORY)**:
   - Global storage patterns: MTC_AQ01_nodes for multi-device support
   - Error handling with try/catch blocks in display functions
   - Display error protection prevents UI crashes
   - Global storage recovery after driver reload
   - RSSI/FPort uppercase parameter compatibility

2. **Enhanced UI Display**:
   - Single-line format for air quality measurements
   - Message type indication (heartbeat/measurements/thresholds)
   - Threshold alert system with visual indicators
   - Temperature, humidity, and pressure display
   - Battery status monitoring

3. **Robust Error Handling**:
   - Version validation (must be 0x02)
   - OpCode-based message type detection
   - Signed temperature value handling
   - Try/catch blocks in all display functions
   - Fallback data recovery from global storage

4. **Global Storage Patterns**:
   - Multi-node support with persistent storage
   - Battery history tracking (last 10 readings)
   - Node statistics and management commands

5. **All Downlink Commands Working**:
   - LwMTC_AQ01Alert: Alert control with duration and feedbacks
   - LwMTC_AQ01Info: Device information request
   - LwMTC_AQ01Show: Configuration show with position/length
   - LwMTC_AQ01Reset: Device reset command
   - LwMTC_AQ01Rejoin: Force network rejoin

6. **Framework Compatibility**:
   - Framework v2.2.9: RSSI/FPort uppercase, simulated parameter
   - Template v2.3.6: Enhanced error handling patterns
   - Multi-message type support (OpCode 0x00, 0x03, 0x05)
   - Threshold monitoring with alert generation
   - Environmental sensor data processing
```

### Request Summary
Request ID: MTC-AQ01-REQ-2025-08-26
Submitted: 2025-08-26 15:03:00
Version Target: v1.1.0
Expected Deliverables:
- [x] Driver file: vendor/mutelcor/MTC-AQ01.be
- [x] Documentation: vendor/mutelcor/MTC-AQ01.md
- [x] Generation report: vendor/mutelcor/MTC-AQ01-REPORT.md

*Form Version: 2.3.6 | Compatible with Template Version: 2.3.6*
*Generated: 2025-08-26 15:03:00 | Framework: LwDecode v2.2.9*
```

## 🎯 OBJECTIVE
Template upgrade from v2.3.3 to v2.3.6 for MTC-AQ01 driver maintaining all existing functionality while adding enhanced error handling patterns and framework compatibility updates.

---

### Upgrade Changes Applied
- **Framework v2.2.9**: RSSI/FPort uppercase parameter compatibility and simulated parameter support
- **Template v2.3.6**: Enhanced try/catch error handling in display functions
- **Global Storage Recovery**: Fallback patterns for data recovery after driver reload
- **Display Error Protection**: Error handling prevents UI crashes from display issues

---
*MTC-AQ01 Generation Request v1.1.0 - Framework v2.2.9 + Template v2.3.6*
*Generated: 2025-08-26 | Status: Template Upgrade Complete*
