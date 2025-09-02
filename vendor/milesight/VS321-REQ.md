# VS321 REQ-REQ Generation Request
## Version: 2.4.0 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] FULL - Complete driver with all features

### Device Information
vendor: "Milesight"
model: "VS321"
type: "AI Occupancy Sensor"
description: "AI-powered occupancy sensor with people counting, temperature, humidity, and desk detection"

### Official References
homepage: "https://www.milesight.com/iot/product/lorawan-sensor/vs321"
userguide: "https://resource.milesight.com/milesight/document/vs321-datasheet.pdf"
decoder_reference: "https://github.com/Milesight-IoT/SensorDecoders/tree/master/VS_Series"
firmware_version: "latest"
lorawan_version: "1.0.4"
regions: ["EU868", "US915", "AS923"]

### Feature Selection
include_features:
  uplink_decoding: true
  downlink_commands: false
  test_ui_scenarios: true
  node_management: true
  battery_tracking: true
  reset_detection: true
  configuration_sync: true
  error_recovery: true
  performance_optimization: true

### UI Customization
display_preferences:
  single_line_preferred: false
  multi_line_for_alerts: true
  custom_emojis: {
    "people": "👥",
    "occupancy_occupied": "🟢", 
    "occupancy_vacant": "⭕",
    "light_bright": "☀️",
    "light_dim": "🌙",
    "temp_alarm": "🚨",
    "reset": "🔄"
  }
  hide_technical_info: true
  emphasize_alerts: true
  battery_prominance: "normal"
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: ["temperature", "temp_threshold"]
  unit_conversions: []
  threshold_monitoring: ["temp_alarm", "humidity_alarm"]
  custom_validation_rules: ["people_count_range", "desk_bitmap_validation"]

### Test Configuration
custom_test_scenarios:
  - name: "normal"
    description: "Normal operation with 3 people, 27.2°C, bright light"
    expected_params: ["temperature", "humidity", "people_count", "occupancy", "illuminance"]
  - name: "occupied" 
    description: "High occupancy with 5 people, warm temperature"
    expected_params: ["people_count", "occupancy", "temperature"]
  - name: "vacant"
    description: "Empty space with 0 people, dim light"
    expected_params: ["people_count", "occupancy", "illuminance"]
  - name: "hot"
    description: "Temperature alarm triggered at 40°C"
    expected_params: ["temp_threshold", "temp_alarm"]
  - name: "humid"
    description: "Humidity alarm triggered at 50%"
    expected_params: ["humidity_threshold", "humidity_alarm"] 
  - name: "reset"
    description: "Device reset event with low battery"
    expected_params: ["device_reset", "battery_pct"]
  - name: "lowbatt"
    description: "Low battery warning at 10%"
    expected_params: ["battery_pct", "battery_v"]
  - name: "config"
    description: "Device configuration info"
    expected_params: ["device_type", "fw_version", "hw_version", "serial_number"]
  - name: "desks"
    description: "Desk sensor with 10 regions, 4 occupied"
    expected_params: ["desk_enabled", "desk_occupied", "vacant_regions", "total_regions"]
  - name: "powerup"
    description: "Power-on event with high battery"
    expected_params: ["power_on", "battery_pct"]

### Additional Notes
Current Implementation Features (v1.0.0):

CRITICAL: Maintain these exact features in regeneration:

1. **Critical Berry Patterns (MANDATORY)**:
   - Fixed keys() iterator bug with explicit key arrays
   - Safe data recovery after lwreload
   - Global node storage with VS321_nodes
   - Multi-line UI formatting with event management
   - Try/catch error protection in add_web_sensor()

2. **Enhanced UI Display**:
   - Multi-line format: temp/humidity/status | people/light | events
   - Persistent sensor values between payloads
   - Event-only display for alarms/resets
   - Conditional line building to avoid empty lines

3. **Robust Error Handling**:
   - Try/catch blocks in all critical methods
   - Graceful fallback for missing data
   - Console error logging with context
   - Safe payload parsing with bounds checking

4. **Global Storage Patterns**:
   - VS321_nodes for multi-device support
   - Data persistence across driver reloads
   - Historical data tracking for trends
   - Reset/alarm event management

5. **All Test Scenarios Working**:
   - 10 diverse scenarios covering all device states
   - Realistic payloads with proper channel structure
   - Comprehensive coverage of all channels
   - Creative scenarios beyond basic operation

6. **Framework Compatibility**:
   - Framework v2.2.9 integration
   - People formatter added to LwDecode.be
   - Standard command patterns (LwVS321TestUI)
   - Proper driver registration

### Request Summary
Request ID: VS321-REQ-20250902
Submitted: 2025-09-02 16:45:00
Version Target: v1.0.0
Expected Deliverables:
- [x] Driver file: vendor/milesight/VS321.be
- [x] Documentation: vendor/milesight/VS321.md  
- [x] Generation report: vendor/milesight/VS321-REPORT.md

*Form Version: 2.4.0 | Compatible with Template Version: 2.4.0*
*Generated: 2025-09-02 16:45:00 | Framework: LwDecode v2.2.9*
