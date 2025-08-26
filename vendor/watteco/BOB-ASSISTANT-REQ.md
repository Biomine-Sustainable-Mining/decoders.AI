# Watteco BOB-ASSISTANT Generation Request
## Version: 2.3.6 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

---

### Generation Request File (BOB-ASSISTANT-REQ.md)

**Purpose**: Document current implementation for future regeneration

```yaml
# Watteco BOB-ASSISTANT Driver Generation Request
## Version: 2.3.6 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] UPGRADE - Framework v2.2.9 + Template v2.3.6

### Device Information
vendor: "Watteco"
model: "BOB-ASSISTANT"
type: "Vibration Sensor"
description: "AI-powered vibration sensor with ML anomaly detection, FFT analysis, and predictive maintenance capabilities"

### Official References
homepage: "https://www.watteco.com/products/bob-assistant-and-movee-solutions/"
userguide: "https://www.youtube.com/watch?v=MTV40U8OKg0"
decoder_reference: "https://raw.githubusercontent.com/TheThingsNetwork/lorawan-devices/master/vendor/watteco/bob-assistant.js"
firmware_version: "latest"
lorawan_version: "1.0.3"
regions: ["EU868", "US915", "AS923"]

### Feature Selection
include_features:
  uplink_decoding: true
  downlink_commands: false  # Read-only sensor
  test_ui_scenarios: true
  node_management: true
  battery_tracking: true
  reset_detection: false
  configuration_sync: false
  error_recovery: true
  performance_optimization: true

### UI Customization
display_preferences:
  single_line_preferred: true
  multi_line_for_alerts: true
  custom_emojis: 
    vibration: "📳"
    temperature: "🌡️"
    anomaly: "🚨"
    learning: "🧠"
    alarm: "🚨"
    report: "📊"
    state: "🔄"
    fft: "📊"
  hide_technical_info: false
  emphasize_alerts: true
  battery_prominance: "normal"
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: []
  unit_conversions: 
    - "battery: *100.0/127 (percentage)"
    - "anomaly: *100.0/127 (percentage)"
    - "vibration: complex calculation with /10.0/121.45"
    - "temperature: -30 offset (celsius)"
  threshold_monitoring: ["vibration_level", "anomaly_level"]
  custom_validation_rules:
    - "Frame type detection from first byte (0x72, 0x52, 0x61, 0x6C, 0x53)"
    - "Complex vibration calculation with FFT processing"
    - "ML anomaly detection with time-series analysis"
    - "Variable payload sizes based on frame type"

### Test Configuration
custom_test_scenarios:
  - name: "report"
    description: "Normal report frame with vibration and anomaly data"
    expected_params: ["vibration_level", "anomaly_level", "temperature", "battery_percent", "frame_type"]
  - name: "alarm"
    description: "Alarm frame with FFT data"
    expected_params: ["vibration_level", "anomaly_level", "temperature", "fft_count", "fft_max", "frame_type"]
  - name: "learning"
    description: "Learning frame during ML training"
    expected_params: ["learning_percentage", "vibration_level", "temperature", "peak_frequency_hz", "frame_type"]
  - name: "sensor_start"
    description: "Sensor start state frame"
    expected_params: ["state", "battery_percent", "frame_type"]
  - name: "sensor_stop"
    description: "Sensor stop state frame"
    expected_params: ["state", "battery_percent", "frame_type"]
  - name: "machine_start"
    description: "Machine start detection"
    expected_params: ["state", "battery_percent", "frame_type"]
  - name: "machine_stop"
    description: "Machine stop detection"
    expected_params: ["state", "battery_percent", "frame_type"]
  - name: "high_vibration"
    description: "High vibration report"
    expected_params: ["vibration_level", "anomaly_level", "frame_type"]
  - name: "low_battery"
    description: "Low battery report"
    expected_params: ["battery_percent", "vibration_level", "frame_type"]

### Additional Notes
Current Implementation Features (v1.1.0):
```
CRITICAL: Maintain these exact features in regeneration:

1. **Critical Berry Patterns (MANDATORY)**:
   - Global storage patterns: BOB_ASSISTANT_nodes for multi-device support
   - Error handling with try/catch blocks in display functions
   - Display error protection prevents UI crashes
   - Global storage recovery after driver reload
   - RSSI/FPort lowercase parameter (legacy support)

2. **Enhanced UI Display**:
   - Frame type specific display modes
   - Vibration level with ML anomaly detection
   - Learning progress indication
   - Machine state monitoring
   - FFT data processing and display

3. **Robust Error Handling**:
   - Frame type validation (0x72, 0x52, 0x61, 0x6C, 0x53)
   - Complex vibration calculation handling
   - Try/catch blocks in all display functions
   - Fallback data recovery from global storage

4. **Global Storage Patterns**:
   - Multi-node support with persistent storage
   - Battery percentage history tracking
   - Vibration trend analysis (last 20 readings)
   - Alarm counting and timestamp tracking
   - Node statistics and management commands

5. **Advanced ML Features**:
   - Anomaly detection with time-series data
   - FFT analysis and peak frequency detection
   - Learning mode progress tracking
   - Machine state detection and monitoring
   - Report generation with multiple time periods

6. **Framework Compatibility**:
   - Framework v2.2.9: Enhanced parameter handling
   - Template v2.3.6: Enhanced error handling patterns
   - Multi-frame type support with complex payload structures
   - ML-powered vibration analysis system
   - Predictive maintenance capabilities
```

### Request Summary
Request ID: BOB-ASSISTANT-REQ-2025-08-26
Submitted: 2025-08-26 15:05:00
Version Target: v1.1.0
Expected Deliverables:
- [x] Driver file: vendor/watteco/BOB-ASSISTANT.be
- [x] Documentation: vendor/watteco/BOB-ASSISTANT.md
- [x] Generation report: vendor/watteco/BOB-ASSISTANT-REPORT.md

*Form Version: 2.3.6 | Compatible with Template Version: 2.3.6*
*Generated: 2025-08-26 15:05:00 | Framework: LwDecode v2.2.9*
```

## 🎯 OBJECTIVE
Template upgrade from v2.3.3 to v2.3.6 for BOB-ASSISTANT driver maintaining all existing functionality while adding enhanced error handling patterns and framework compatibility updates.

---

### Upgrade Changes Applied
- **Framework v2.2.9**: Parameter handling improvements and simulated parameter support
- **Template v2.3.6**: Enhanced try/catch error handling in display functions
- **Global Storage Recovery**: Fallback patterns for data recovery after driver reload
- **Display Error Protection**: Error handling prevents UI crashes from display issues

---
*BOB-ASSISTANT Generation Request v1.1.0 - Framework v2.2.9 + Template v2.3.6*
*Generated: 2025-08-26 | Status: Template Upgrade Complete*
