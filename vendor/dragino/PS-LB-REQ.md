# Dragino PS-LB Generation Request
## Version: 2.3.6 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

---

### Generation Request File (PS-LB-REQ.md)

**Purpose**: Document current implementation for future regeneration

```yaml
# Dragino PS-LB Driver Generation Request
## Version: 2.3.6 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] UPGRADE - Framework v2.2.9 + Template v2.3.6

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
    expected_params: ["roc_events", "roc_mode", "idc_current_ma", "battery_v"]
  - name: "multi_data"
    description: "Multi-collection mode with multiple readings"
    expected_params: ["voltage_values", "avg_voltage", "data_count", "multi_mode"]
  - name: "status"
    description: "Device status information (FPort=5)"
    expected_params: ["sensor_model", "fw_version", "frequency_band", "battery_v"]
  - name: "datalog"
    description: "Datalog entries with timestamps"
    expected_params: ["datalog_entries", "entry_count", "datalog_mode"]
  - name: "low_battery"
    description: "Low battery warning condition"
    expected_params: ["water_depth_m", "battery_v"]

### Additional Notes
Current Implementation Features (v2.0.0):
```
CRITICAL: Maintain these exact features in regeneration:

1. **Critical Berry Patterns (MANDATORY)**:
   - Global storage patterns: PSLB_nodes for multi-device support
   - Error handling with try/catch blocks in display functions
   - Display error protection prevents UI crashes
   - Global storage recovery after driver reload
   - RSSI/FPort uppercase parameter compatibility

2. **Enhanced UI Display**:
   - Multi-line format for comprehensive sensor data
   - Probe type detection and display
   - Water depth and pressure calculations from 4-20mA
   - ROC (Report on Change) event indication
   - Multi-collection mode with statistics
   - Digital input status display

3. **Robust Error Handling**:
   - Probe model validation and type detection
   - 4-20mA and 0-30V input range validation
   - Try/catch blocks in all display functions
   - Fallback data recovery from global storage

4. **Global Storage Patterns**:
   - Multi-node support with persistent storage
   - Battery history tracking (last 10 readings)
   - Water depth and pressure trend tracking
   - ROC event counting and timestamp tracking
   - Node statistics and management commands

5. **All Downlink Commands Working**:
   - LwPSLBInterval: Set transmit interval (30-16777215 seconds)
   - LwPSLBInterrupt: Configure interrupt modes (disable/falling/rising/both)
   - LwPSLBOutput: Control output voltages (3V3/5V/12V with duration)
   - LwPSLBProbe: Set probe model configuration
   - LwPSLBROC: Configure Report on Change mode and thresholds
   - LwPSLBStatus: Request device status
   - LwPSLBMultiCollection: Set multi-collection mode parameters
   - LwPSLBPoll: Poll datalog with timestamp range
   - LwPSLBClearFlash: Clear flash record storage

6. **Framework Compatibility**:
   - Framework v2.2.9: RSSI/FPort uppercase, simulated parameter
   - Template v2.3.6: Enhanced error handling patterns
   - Probe detection system with type identification
   - Multi-mode operation (sensor/ROC/multi-collection/datalog)
   - Current loop and voltage input processing
```

### Request Summary
Request ID: PSLB-REQ-2025-08-26
Submitted: 2025-08-26 15:02:00
Version Target: v2.0.0
Expected Deliverables:
- [x] Driver file: vendor/dragino/PS-LB.be
- [x] Documentation: vendor/dragino/PS-LB.md
- [x] Generation report: vendor/dragino/PS-LB-REPORT.md

*Form Version: 2.3.6 | Compatible with Template Version: 2.3.6*
*Generated: 2025-08-26 15:02:00 | Framework: LwDecode v2.2.9*
```

## 🎯 OBJECTIVE
Template upgrade from v2.3.3 to v2.3.6 for PS-LB driver maintaining all existing functionality while adding enhanced error handling patterns and framework compatibility updates.

---

### Upgrade Changes Applied
- **Framework v2.2.9**: RSSI/FPort uppercase parameter compatibility and simulated parameter support
- **Template v2.3.6**: Enhanced try/catch error handling in display functions
- **Global Storage Recovery**: Fallback patterns for data recovery after driver reload
- **Display Error Protection**: Error handling prevents UI crashes from display issues

---
*PS-LB Generation Request v2.0.0 - Framework v2.2.9 + Template v2.3.6*
*Generated: 2025-08-26 | Status: Template Upgrade Complete*
