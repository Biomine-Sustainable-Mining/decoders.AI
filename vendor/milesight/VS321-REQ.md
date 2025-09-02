# Milesight VS321 Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

---

### Generation Request File (VS321-REQ.md)

**Purpose**: Document current implementation for future regeneration

```yaml
# Milesight VS321 Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] FULL - Complete driver with all features

### Device Information
vendor: "Milesight"
model: "VS321"
type: "AI Occupancy Sensor"
description: "LoRaWAN AI-powered occupancy sensor with people counting, desk occupancy detection, temperature/humidity monitoring, and illumination sensing"

### Official References
homepage: "https://support.milesight-iot.com"
userguide: "VS321_User_Guide.pdf"
decoder_reference: "Official Milesight Decoder"
firmware_version: "latest"
lorawan_version: "V1.0.2/V1.0.3"
regions: ["EU868", "US915", "AU915"]

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
  single_line_preferred: false  # Multi-line for occupancy data
  multi_line_for_alerts: true
  custom_emojis: 
    people: "👥"
    desk: "🪑"
    temperature: "🌡️"
    humidity: "💧"
    illumination_bright: "☀️"
    illumination_dim: "🌙"
    status_normal: "✅"
    status_error: "⚠️"
  hide_technical_info: false
  emphasize_alerts: true
  battery_prominance: "normal"
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: ["temperature", "temperature_threshold"]
  unit_conversions: 
    - "temperature: /10.0 (°C)"
    - "humidity: /2.0 (%RH)"
    - "battery: direct (%)"
  threshold_monitoring: ["temperature_threshold", "humidity_threshold"]
  custom_validation_rules:
    - "Milesight channel+type format parsing"
    - "Little endian multi-byte values"
    - "Desk occupancy bit field processing (16 positions)"
    - "People counting with trend tracking"
    - "Historical data entry parsing"

### Test Configuration
custom_test_scenarios:
  - name: "normal"
    description: "Normal operation with all sensors"
    expected_params: ["battery", "temperature", "humidity", "people_count", "occupancy_status", "illumination"]
  - name: "occupied"
    description: "High occupancy scenario"
    expected_params: ["people_count", "occupancy_status", "temperature"]
  - name: "low_battery"
    description: "Low battery warning condition"
    expected_params: ["battery", "people_count", "detection_status"]
  - name: "empty"
    description: "Empty room scenario"
    expected_params: ["people_count", "illumination", "temperature"]
  - name: "alarm"
    description: "Threshold alarm conditions"
    expected_params: ["temp_threshold", "temp_alarm", "humidity_threshold", "humidity_alarm"]
  - name: "device_info"
    description: "Device information and version data"
    expected_params: ["fw_version", "hw_version", "serial_number", "power_on"]
  - name: "historical"
    description: "Historical data entry"
    expected_params: ["hist_timestamp", "hist_data_type"]
  - name: "reset"
    description: "Power on and reset events"
    expected_params: ["power_on", "reset_report"]

### Additional Notes
Current Implementation Features (v2.0.0):
```
CRITICAL: Maintain these exact features in regeneration:

1. **Critical Berry Patterns (MANDATORY)**:
   - Global storage patterns: VS321_nodes for multi-device support
   - Enhanced lwreload recovery with found_node flag pattern
   - Display error protection with try/catch wrapper
   - Template v2.5.0 payload verification system
   - Static scenario list to avoid keys() iterator bug

2. **Enhanced UI Display**:
   - Multi-line format for occupancy sensor data
   - People counting with trend tracking and display
   - Desk occupancy bit field parsing (16 positions) with "occupied/total" format
   - Temperature/humidity with threshold alarm indicators
   - Illumination status (Bright/Dim) with appropriate emoji
   - Detection status monitoring (Normal/Undetectable)
   - Device info display with firmware/hardware versions

3. **Robust Error Handling**:
   - Milesight channel+type format validation
   - Little endian multi-byte value parsing
   - Signed temperature value handling
   - Try/catch blocks in all display functions
   - Enhanced display error protection

4. **Global Storage Patterns**:
   - Multi-node support with persistent VS321_nodes storage
   - Battery history tracking (last 10 readings with trend analysis)
   - People count history tracking (last 10 readings for occupancy trends)
   - Node statistics and management commands for maintenance

5. **All Downlink Commands Working**:
   - LwVS321Interval: Set reporting interval (2-1440 minutes) with validation
   - LwVS321DetectionInterval: Set detection interval (2-60 minutes)
   - LwVS321ReportMode: Set reporting mode (from now/on the dot)
   - LwVS321DetectionMode: Set detection mode (auto/always)
   - LwVS321Detect: Immediate detection trigger
   - LwVS321Reset: Device reset command
   - LwVS321Reboot: Device reboot command
   - LwVS321Storage: Data storage enable/disable
   - LwVS321Retransmit: Data retransmission enable/disable
   - LwVS321RetransmitInterval: Set retransmission interval (30-1200 seconds)
   - LwVS321ADR: ADR mode enable/disable

6. **Framework Compatibility**:
   - Framework v2.2.9: RSSI/FPort uppercase, simulated parameter support
   - Template v2.5.0: Verified TestUI payload decoding system
   - Milesight channel+type protocol parsing
   - Multi-byte little endian value processing
   - Historical data entry parsing with timestamps
   - Enhanced payload verification with decode-back testing
```

### Request Summary
Request ID: VS321-REQ-2025-09-03
Submitted: 2025-09-03 14:45:00
Version Target: v2.0.0
Expected Deliverables:
- [x] Driver file: vendor/milesight/VS321.be
- [x] Documentation: vendor/milesight/VS321.md
- [x] Generation report: vendor/milesight/VS321-REPORT.md

*Form Version: 2.5.0 | Compatible with Template Version: 2.5.0*
*Generated: 2025-09-03 14:45:00 | Framework: LwDecode v2.2.9*
```

## 🎯 OBJECTIVE
Template upgrade from v2.4.1 to v2.5.0 for VS321 driver maintaining all existing functionality while adding verified TestUI payload decoding system and enhanced error recovery patterns.

---

### Upgrade Changes Applied
- **Framework v2.2.9**: Maintained RSSI/FPort uppercase parameter compatibility
- **Template v2.5.0**: Added verified TestUI payload decoding with decode-back validation
- **Enhanced Recovery**: Improved lwreload recovery with found_node flag pattern
- **Payload Verification**: All TestUI scenarios now validate through actual decoding
- **Static Scenarios**: Fixed Berry keys() iterator bug with static scenario list

---
*VS321 Generation Request v2.0.0 - Framework v2.2.9 + Template v2.5.0*
*Generated: 2025-09-03 | Status: Template v2.5.0 Complete*
