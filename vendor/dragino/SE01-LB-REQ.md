# Dragino SE01-LB Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

---

### Generation Request File (SE01-LB-REQ.md)

**Purpose**: Document current implementation for future regeneration

```yaml
# Dragino SE01-LB Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] FULL - Complete driver with all features

### Device Information
vendor: "Dragino"
model: "SE01-LB"
type: "Soil Moisture & EC Sensor"
description: "LoRaWAN soil moisture and electrical conductivity sensor with DS18B20 external temperature, calibrated/raw modes, and interrupt/counting operation"

### Official References
homepage: "https://wiki.dragino.com/xwiki/bin/view/Main/User%20Manual%20for%20LoRaWAN%20End%20Nodes/SE01-LB_LoRaWAN_Soil%20Moisture%26EC_Sensor_User_Manual/"
userguide: "SE01-LB User Manual"
decoder_reference: "Official Dragino Decoder"
firmware_version: "latest"
lorawan_version: "1.0.3"
regions: ["CN470", "EU433", "KR920", "US915", "EU868", "AS923", "AU915", "IN865"]

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
  single_line_preferred: false  # Multi-line for sensor data + mode info
  multi_line_for_alerts: true
  custom_emojis: 
    soil_moisture: "💧"
    temperature: "🌡️"
    conductivity: "⚡"
    counting: "🔢"
    mode: "⚙️"
    raw: "📊"
  hide_technical_info: false
  emphasize_alerts: true
  battery_prominance: "normal"
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: ["ds18b20_temperature", "soil_temperature"]
  unit_conversions: 
    - "ds18b20_temp: /10.0 (°C)"
    - "soil_moisture: /100.0 (%)"
    - "soil_temp: /100.0 (°C)"
    - "battery: /1000.0 (V)"
    - "conductivity: auto µS/cm to mS/cm scaling"
  threshold_monitoring: []
  custom_validation_rules:
    - "MOD flag detection from bit 7 of byte 10"
    - "DS18B20 disconnection detection (0x7FFF = 327.67°C)"
    - "Calibrated vs raw mode based on MOD flag"
    - "Interrupt vs counting mode detection (11 vs 15 bytes)"
    - "Datalog entry parsing with timestamps"

### Test Configuration
custom_test_scenarios:
  - name: "normal"
    description: "Normal calibrated mode operation"
    expected_params: ["ds18b20_temp", "soil_moisture", "soil_temp", "soil_conductivity", "battery_v"]
  - name: "raw"
    description: "Raw values mode (MOD=1)"
    expected_params: ["soil_moisture_raw", "soil_conductivity_raw", "dielectric_constant_raw", "work_mode"]
  - name: "counting"
    description: "Counting mode with counter value"
    expected_params: ["count_value", "counting_mode", "soil_moisture"]
  - name: "low_battery"
    description: "Low battery warning condition"
    expected_params: ["soil_moisture", "battery_v"]
  - name: "disconnected"
    description: "DS18B20 temperature sensor disconnected"
    expected_params: ["ds18b20_temp", "soil_moisture"]
  - name: "high_conduct"
    description: "High conductivity (>1000µS/cm for mS/cm display)"
    expected_params: ["soil_conductivity", "soil_moisture"]
  - name: "status"
    description: "Device status information (FPort=5)"
    expected_params: ["sensor_model", "fw_version", "frequency_band", "battery_v"]
  - name: "datalog"
    description: "Datalog entry with timestamp"
    expected_params: ["datalog_entries", "entry_count"]

### Additional Notes
Current Implementation Features (v2.0.0):
```
CRITICAL: Maintain these exact features in regeneration:

1. **Critical Berry Patterns (MANDATORY)**:
   - Global storage patterns: SE01LB_nodes for multi-device support
   - Enhanced lwreload recovery with found_node flag pattern
   - Display error protection with try/catch wrapper
   - Template v2.5.0 payload verification system
   - Static scenario list to avoid keys() iterator bug

2. **Enhanced UI Display**:
   - Multi-line format for comprehensive soil sensor data
   - Calibrated vs raw mode detection and display
   - DS18B20 disconnection indicator (327.67°C → "Disconnected")
   - Conductivity auto-scaling (µS/cm to mS/cm at ≥1000)
   - Mode indicators (CAL/RAW, Interrupt/Counting)
   - Counter value display in counting mode

3. **Robust Error Handling**:
   - MOD flag validation and dual-mode processing
   - DS18B20 disconnection detection (0x7FFF raw value)
   - Signed temperature value handling for soil sensor
   - Try/catch blocks in all display functions
   - Enhanced display error protection

4. **Global Storage Patterns**:
   - Multi-node support with persistent SE01LB_nodes storage
   - Battery history tracking (last 10 readings with trend analysis)
   - Counter value tracking for counting mode operations
   - Node statistics and management commands for maintenance

5. **All Downlink Commands Working**:
   - LwSE01LBInterval: Set transmit interval (30-16777215 seconds) with validation
   - LwSE01LBReset: Device reset with fixed FF flag
   - LwSE01LBConfirm: Set confirmed/unconfirmed uplink mode
   - LwSE01LBInterrupt: Configure interrupt mode enable/disable
   - LwSE01LBOutput5V: Set 5V output duration (0-65535ms)
   - LwSE01LBSetCount: Set 32-bit counter value (0-4294967295)
   - LwSE01LBWorkMode: Switch calibrated/raw value modes
   - LwSE01LBCountMode: Switch interrupt/counting operation modes
   - LwSE01LBStatus: Request device status (firmware, band info)
   - LwSE01LBPoll: Poll datalog with timestamp range queries

6. **Framework Compatibility**:
   - Framework v2.2.9: RSSI/FPort uppercase, simulated parameter support
   - Template v2.5.0: Verified TestUI payload decoding system
   - Dual-mode operation detection (calibrated/raw based on MOD flag)
   - Multi-payload size handling (11-byte interrupt, 15-byte counting)
   - Datalog parsing with timestamp and MOD-based field interpretation
   - Enhanced payload verification with decode-back testing
```

### Request Summary
Request ID: SE01LB-REQ-2025-09-03
Submitted: 2025-09-03 14:30:00
Version Target: v2.0.0
Expected Deliverables:
- [x] Driver file: vendor/dragino/SE01-LB.be
- [x] Documentation: vendor/dragino/SE01-LB.md
- [x] Generation report: vendor/dragino/SE01-LB-REPORT.md

*Form Version: 2.5.0 | Compatible with Template Version: 2.5.0*
*Generated: 2025-09-03 14:30:00 | Framework: LwDecode v2.2.9*
```

## 🎯 OBJECTIVE
Template upgrade from v2.4.1 to v2.5.0 for SE01-LB driver maintaining all existing functionality while adding verified TestUI payload decoding system and enhanced error recovery patterns.

---

### Upgrade Changes Applied
- **Framework v2.2.9**: Maintained RSSI/FPort uppercase parameter compatibility
- **Template v2.5.0**: Added verified TestUI payload decoding with decode-back validation
- **Enhanced Recovery**: Improved lwreload recovery with found_node flag pattern
- **Payload Verification**: All TestUI scenarios now validate through actual decoding
- **Static Scenarios**: Fixed Berry keys() iterator bug with static scenario list

---
*SE01-LB Generation Request v2.0.0 - Framework v2.2.9 + Template v2.5.0*
*Generated: 2025-09-03 | Status: Template v2.5.0 Complete*
