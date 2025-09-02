# Dragino PS-LB Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

---

### Generation Request File (PS-LB-REQ.md)

**Purpose**: Document current implementation for future regeneration

```yaml
# Dragino PS-LB Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] FULL - Complete driver with all features

### Device Information
vendor: "Dragino"
model: "PS-LB"
type: "Pressure/Water Level Sensor"
description: "LoRaWAN pressure and water level sensor with 4-20mA and 0-30V inputs, probe detection, and multi-collection modes"

### Official References
homepage: "https://wiki.dragino.com/xwiki/bin/view/Main/User%20Manual%20for%20LoRaWAN%20End%20Nodes/PS-LB%20--%20LoRaWAN%20Pressure%20Sensor/"
userguide: "PS-LB_LoRaWAN_Pressure_Sensor_UserManual"
decoder_reference: "Official Dragino Decoder"
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
  single_line_preferred: false  # Multi-line for sensor data + probe info
  multi_line_for_alerts: true
  custom_emojis: 
    water_depth: "💧"
    pressure: "📊"
    current: "🔌"
    voltage: "⚡"
    probe: "🔧"
    roc: "🔔"
    multi: "📊"
  hide_technical_info: false
  emphasize_alerts: true
  battery_prominance: "normal"
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: []
  unit_conversions: 
    - "current: /1000.0 (mA)"
    - "voltage: /1000.0 (V)"
    - "battery: /1000.0 (V)"
    - "water_depth: 4-20mA to depth calculation"
    - "pressure: 4-20mA to pressure calculation"
  threshold_monitoring: []
  custom_validation_rules:
    - "Probe model detection from bytes 0-1"
    - "4-20mA current loop measurement"
    - "0-30V voltage input measurement"
    - "Multi-collection mode with multiple readings"
    - "ROC (Report on Change) event detection"

### Test Configuration
custom_test_scenarios:
  - name: "normal"
    description: "Normal water depth measurement"
    expected_params: ["water_depth_m", "idc_current_ma", "vdc_voltage", "battery_v", "probe_type"]
  - name: "low_water"
    description: "Low water level condition"
    expected_params: ["water_depth_m", "idc_current_ma", "battery_v"]
  - name: "high_water"
    description: "High water level condition"
    expected_params: ["water_depth_m", "idc_current_ma", "battery_v"]
  - name: "pressure"
    description: "Pressure measurement mode"
    expected_params: ["pressure_mpa", "idc_current_ma", "vdc_voltage", "battery_v"]
  - name: "roc_event"
    description: "Report on Change event triggered"
    expected_params: ["roc_events", "idc_current_ma", "battery_v"]
  - name: "multi_data"
    description: "Multi-collection mode with multiple readings"
    expected_params: ["voltage_values", "avg_voltage", "data_count", "multi_mode"]
  - name: "status"
    description: "Device status information (FPort=5)"
    expected_params: ["sensor_model", "fw_version", "frequency_band", "battery_v"]
  - name: "low_battery"
    description: "Low battery warning condition"
    expected_params: ["water_depth_m", "battery_v"]

### Additional Notes
Current Implementation Features (v3.0.0):
```
CRITICAL: Maintain these exact features in regeneration:

1. **Critical Berry Patterns (MANDATORY)**:
   - Global storage patterns: PSLB_nodes for multi-device support
   - Enhanced lwreload recovery with found_node flag pattern
   - Display error protection with try/catch wrapper
   - Template v2.5.0 payload verification system
   - Static scenario list to avoid keys() iterator bug

2. **Enhanced UI Display**:
   - Multi-line format for comprehensive sensor data
   - Probe type detection and display with 4-20mA calculations
   - Water depth and pressure calculations with unit conversions
   - ROC (Report on Change) event indication with flag decoding
   - Multi-collection mode with statistics and averaging
   - Device status display with frequency band mapping

3. **Robust Error Handling**:
   - Probe model validation and type detection (aa/bb bytes)
   - 4-20mA and 0-30V input range validation with calculations
   - Try/catch blocks in all display functions
   - Fallback data recovery from global storage
   - Enhanced display error protection

4. **Global Storage Patterns**:
   - Multi-node support with persistent PSLB_nodes storage
   - Battery history tracking (last 10 readings with trend analysis)
   - Water depth and pressure trend tracking for analytics
   - ROC event counting and timestamp tracking for alerts
   - Node statistics and management commands for maintenance

5. **All Downlink Commands Working**:
   - LwPSLBInterval: Set transmit interval (30-16777215 seconds) with validation
   - LwPSLBInterrupt: Configure interrupt modes (disable/falling/rising/both)
   - LwPSLBOutput: Control output voltages (3V3/5V/12V with duration)
   - LwPSLBProbe: Set probe model configuration (16-bit config)
   - LwPSLBROC: Configure Report on Change mode and thresholds
   - LwPSLBStatus: Request device status (firmware, band info)
   - LwPSLBMultiCollection: Set multi-collection mode parameters
   - LwPSLBPoll: Poll datalog with timestamp range queries
   - LwPSLBClearFlash: Clear flash record storage

6. **Framework Compatibility**:
   - Framework v2.2.9: RSSI/FPort uppercase, simulated parameter support
   - Template v2.5.0: Verified TestUI payload decoding system
   - Probe detection system with type identification and calculations
   - Multi-mode operation (sensor/ROC/multi-collection/datalog)
   - Current loop and voltage input processing with unit conversions
   - Enhanced payload verification with decode-back testing
```

### Request Summary
Request ID: PSLB-REQ-2025-09-03
Submitted: 2025-09-03 14:15:00
Version Target: v3.0.0
Expected Deliverables:
- [x] Driver file: vendor/dragino/PS-LB.be
- [x] Documentation: vendor/dragino/PS-LB.md
- [x] Generation report: vendor/dragino/PS-LB-REPORT.md

*Form Version: 2.5.0 | Compatible with Template Version: 2.5.0*
*Generated: 2025-09-03 14:15:00 | Framework: LwDecode v2.2.9*
```

## 🎯 OBJECTIVE
Template upgrade from v2.4.1 to v2.5.0 for PS-LB driver maintaining all existing functionality while adding verified TestUI payload decoding system and enhanced error recovery patterns.

---

### Upgrade Changes Applied
- **Framework v2.2.9**: Maintained RSSI/FPort uppercase parameter compatibility
- **Template v2.5.0**: Added verified TestUI payload decoding with decode-back validation
- **Enhanced Recovery**: Improved lwreload recovery with found_node flag pattern
- **Payload Verification**: All TestUI scenarios now validate through actual decoding
- **Static Scenarios**: Fixed Berry keys() iterator bug with static scenario list

---
*PS-LB Generation Request v3.0.0 - Framework v2.2.9 + Template v2.5.0*
*Generated: 2025-09-03 | Status: Template v2.5.0 Complete*
