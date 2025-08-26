# Micropelt MLR003 Generation Request
## Version: 2.3.6 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

---

### Generation Request File (MLR003-REQ.md)

**Purpose**: Document current implementation for future regeneration

```yaml
# Micropelt MLR003 Driver Generation Request
## Version: 2.3.6 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] UPGRADE - Framework v2.2.9 + Template v2.3.6

### Device Information
vendor: "Micropelt"
model: "MLR003"
type: "Thermostatic Radiator Valve"
description: "Energy harvesting thermostatic radiator valve with advanced control modes and PID parameters"

### Official References
homepage: "https://micropelt.atlassian.net/wiki/spaces/MH/pages/19300575/MLR003RiEU61-07+Title+Page"
userguide: "https://www.thethingsnetwork.org/device-repository/devices/micropelt/mlr003/"
decoder_reference: "https://raw.githubusercontent.com/TheThingsNetwork/lorawan-devices/master/vendor/micropelt/mlr003.js"
firmware_version: "latest"
lorawan_version: "1.0.3"
regions: ["EU868"]

### Feature Selection
include_features:
  uplink_decoding: true
  downlink_commands: true
  test_ui_scenarios: true
  node_management: true
  battery_tracking: false  # Uses energy harvesting storage
  reset_detection: false
  configuration_sync: true
  error_recovery: true
  performance_optimization: true

### UI Customization
display_preferences:
  single_line_preferred: false  # Multi-line for valve control data
  multi_line_for_alerts: true
  custom_emojis: 
    valve_position: "🔧"
    temperature: "🌡️"
    flow_temp: "🌊"
    energy: "⚡"
    mode: "⚙️"
    error: "⚠️"
    calibration: "🔧"
  hide_technical_info: false
  emphasize_alerts: true
  battery_prominance: "hidden"  # Uses storage voltage instead
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: []
  unit_conversions: 
    - "valve_position: direct (percentage)"
    - "temperatures: *0.5 or *0.25 (celsius)"
    - "storage_voltage: *0.02 (volts)"
    - "current: *10 (mA)"
  threshold_monitoring: []
  custom_validation_rules:
    - "Multiple FPort support (1-15) with different data structures"
    - "Complex status flag interpretation"
    - "Energy harvesting status monitoring"
    - "User mode detection and value interpretation"

### Test Configuration
custom_test_scenarios:
  - name: "normal"
    description: "Normal valve operation"
    expected_params: ["valve_position", "ambient_temperature", "flow_temperature", "storage_voltage", "user_mode"]
  - name: "high_temp"
    description: "High flow temperature condition"
    expected_params: ["valve_position", "flow_temperature", "storage_voltage"]
  - name: "low_battery"
    description: "Low storage voltage"
    expected_params: ["valve_position", "storage_voltage"]
  - name: "motor_error"
    description: "Motor malfunction detected"
    expected_params: ["motor_error", "valve_position"]
  - name: "sensor_fail"
    description: "Sensor failure condition"
    expected_params: ["ambient_sensor_failure", "flow_sensor_failure"]
  - name: "valve_mode"
    description: "Valve position mode operation"
    expected_params: ["user_mode", "valve_position"]
  - name: "detecting"
    description: "Detecting opening point mode"
    expected_params: ["user_mode", "valve_position"]
  - name: "slow_harvest"
    description: "Slow harvesting energy mode"
    expected_params: ["user_mode", "harvesting_active"]
  - name: "version"
    description: "Device version information (FPort=2)"
    expected_params: ["fw_version", "hw_version", "rev"]
  - name: "motor_range"
    description: "Motor range configuration (FPort=3)"
    expected_params: ["motor_range"]
  - name: "spread_factor"
    description: "LoRaWAN spreading factor (FPort=4)"
    expected_params: ["spreading_factor"]
  - name: "opd_status"
    description: "Opening point detection status (FPort=5)"
    expected_params: ["opening_percent_found", "opd_status"]

### Additional Notes
Current Implementation Features (v1.1.0):
```
CRITICAL: Maintain these exact features in regeneration:

1. **Critical Berry Patterns (MANDATORY)**:
   - Global storage patterns: MLR003_nodes for multi-device support
   - Error handling with try/catch blocks in display functions
   - Display error protection prevents UI crashes
   - Global storage recovery after driver reload
   - RSSI/FPort uppercase parameter compatibility

2. **Enhanced UI Display**:
   - Multi-line format for comprehensive valve control data
   - Energy harvesting status indication
   - User mode display with appropriate emojis
   - Error and warning indicators
   - Valve position and temperature monitoring

3. **Robust Error Handling**:
   - Multiple FPort validation (1-15)
   - Complex status flag interpretation
   - Try/catch blocks in all display functions
   - Fallback data recovery from global storage

4. **Global Storage Patterns**:
   - Multi-node support with persistent storage
   - Storage voltage history tracking (energy harvesting)
   - Node statistics and management commands

5. **All Downlink Commands Working**:
   - LwMLR003Config: Main configuration with multiple parameters
   - LwMLR003MotorRange: Motor range configuration
   - LwMLR003SpreadFactor: LoRaWAN spreading factor setting
   - LwMLR003RoomTemp: Room temperature setting
   - LwMLR003Beep: Beep command with count
   - LwMLR003Control: Device control (operate/recalibrate/turnoff)

6. **Framework Compatibility**:
   - Framework v2.2.9: RSSI/FPort uppercase, simulated parameter
   - Template v2.3.6: Enhanced error handling patterns
   - Multi-FPort support with complex payload structures
   - Energy harvesting monitoring system
   - Advanced valve control with multiple operating modes
```

### Request Summary
Request ID: MLR003-REQ-2025-08-26
Submitted: 2025-08-26 15:04:00
Version Target: v1.1.0
Expected Deliverables:
- [x] Driver file: vendor/micropelt/MLR003.be
- [x] Documentation: vendor/micropelt/MLR003.md
- [x] Generation report: vendor/micropelt/MLR003-REPORT.md

*Form Version: 2.3.6 | Compatible with Template Version: 2.3.6*
*Generated: 2025-08-26 15:04:00 | Framework: LwDecode v2.2.9*
```

## 🎯 OBJECTIVE
Template upgrade from v2.3.3 to v2.3.6 for MLR003 driver maintaining all existing functionality while adding enhanced error handling patterns and framework compatibility updates.

---

### Upgrade Changes Applied
- **Framework v2.2.9**: RSSI/FPort uppercase parameter compatibility and simulated parameter support
- **Template v2.3.6**: Enhanced try/catch error handling in display functions
- **Global Storage Recovery**: Fallback patterns for data recovery after driver reload
- **Display Error Protection**: Error handling prevents UI crashes from display issues

---
*MLR003 Generation Request v1.1.0 - Framework v2.2.9 + Template v2.3.6*
*Generated: 2025-08-26 | Status: Template Upgrade Complete*
