# Watteco BOB-ASSISTANT Driver Generation Request
## Version: 2.5.0 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] FULL - Complete driver with all features

### Device Information
vendor: "Watteco"
model: "BOB-ASSISTANT"
type: "Vibration Sensor"
description: "Advanced vibration sensor with ML anomaly detection, FFT analysis, and predictive maintenance"

### Official References
homepage: "https://www.watteco.com/products/bob-assistant-and-movee-solutions/"
userguide: "Bob Assistant Data Sheets and TTN Repository"
decoder_reference: "https://github.com/TheThingsNetwork/lorawan-devices/blob/master/vendor/watteco/bob-assistant.js"
firmware_version: "latest"
lorawan_version: "1.0.2"
regions: [EU863-870]

### Feature Selection
include_features:
  uplink_decoding: true
  downlink_commands: false     # No downlinks documented
  test_ui_scenarios: true
  node_management: true
  battery_tracking: true       # AA battery powered
  reset_detection: false
  configuration_sync: false
  error_recovery: true
  performance_optimization: true

### UI Customization
display_preferences:
  single_line_preferred: false  # Complex data needs multi-line
  multi_line_for_alerts: true
  custom_emojis: {vibration: "📳", anomaly: "🔴🟡🟢", learning: "🧠", fft: "📊", alarm: "🚨"}
  hide_technical_info: false    # Show FFT and ML data
  emphasize_alerts: true
  battery_prominance: "normal"  # Show battery percentage
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: ["vibration_x", "vibration_y", "vibration_z"]
  unit_conversions: ["vibration_magnitude_calculation", "fft_frequency_mapping"]
  threshold_monitoring: ["anomaly_level", "vibration_level"]
  custom_validation_rules: ["frame_type_validation", "payload_size_validation"]

### Test Configuration
custom_test_scenarios:
  - name: "report"
    description: "Normal report frame with vibration and anomaly data"
    expected_params: ["frame_type", "temperature", "vibration_level", "anomaly_level"]
  - name: "alarm"
    description: "Alarm frame with high anomaly and FFT data"
    expected_params: ["frame_type", "anomaly_level", "fft_data"]
  - name: "learning"
    description: "Learning frame showing ML training progress"
    expected_params: ["frame_type", "learning_percentage", "vibration_level"]
  - name: "start"
    description: "Machine start state frame"
    expected_params: ["frame_type", "state", "battery_pct"]

### Additional Notes
Current Implementation Features (v2.0.0):
```
CRITICAL: Maintain these exact features in regeneration:

1. **Critical Berry Patterns (MANDATORY)**:
   - Safe iteration with found_node flag in add_web_sensor()
   - Explicit key arrays for data recovery
   - Complex vibration magnitude calculation

2. **Enhanced UI Display**:
   - Multi-line display for complex sensor data
   - Frame type indicators with appropriate emojis
   - Anomaly level color coding (red/yellow/green)

3. **Robust Error Handling**:
   - Try/catch blocks in decode and display functions
   - Payload size validation per frame type
   - FFT data processing with peak detection

4. **Global Storage Patterns**:
   - Battery/anomaly/vibration trend tracking
   - Learning progress persistence
   - Machine state change counting

5. **Advanced Processing Functions**:
   - decode_vibration() for 3-axis data
   - calc_report_period() for time encoding
   - find_fft_peak() for frequency analysis

6. **Framework Compatibility**:
   - LwDecode v2.2.9 helper functions
   - Complex mathematical operations (sqrt)
   - Array processing for FFT data
```

### Request Summary
Request ID: BOB-ASSISTANT-REQ-2025-09-03
Submitted: 2025-09-03 16:30:00
Version Target: v2.0.0
Expected Deliverables:
- [x] Driver file: vendor/watteco/BOB-ASSISTANT.be
- [x] Documentation: vendor/watteco/BOB-ASSISTANT.md
- [x] Generation report: vendor/watteco/BOB-ASSISTANT-REPORT.md

*Form Version: 2.5.0 | Compatible with Template Version: 2.5.0*
*Generated: 2025-09-03 16:30:00 | Framework: LwDecode v2.2.9*
