# WS52x Driver Generation Request
## Version: 2.3.5 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

---

## 📋 GENERATION REQUEST

### Request Type
- [x] **REGENERATE** - Fresh generation from existing MAP file
- [ ] **UPDATE** - Partial update/fix existing driver
- [ ] **FROM_MAP** - Generate only from MAP cache file (skip PDF parsing)

### Generation Mode
- [x] **FULL** - Complete driver with all features

---

## 🏭 DEVICE INFORMATION

### Basic Details
```yaml
vendor: "Milesight"
model: "WS52x"
type: "Smart Power Socket"
description: "LoRaWAN smart power socket with power monitoring and remote control"
```

### Official References
```yaml
homepage: "https://www.milesight.com/iot/product/lorawan-sensor/ws52x"
userguide: "WS52x LoRaWAN Application Guide v1.1"
decoder_reference: "Official Milesight Decoder v1.0.3"
firmware_version: "latest"
lorawan_version: "1.0.3"
regions: ["EU868", "US915", "AU915", "AS923", "KR920", "IN865", "RU864"]
```

---

## 📄 SOURCE DOCUMENTATION

### Existing Resources
```yaml
map_file_exists: true
use_cached_map: true
previous_driver_version: "1.5.2"
```

---

## ⚙️ GENERATION PREFERENCES

### Feature Selection
```yaml
include_features:
  uplink_decoding: true
  downlink_commands: true
  test_ui_scenarios: true
  node_management: true
  battery_tracking: false          # Mains powered device
  reset_detection: true
  configuration_sync: true
  error_recovery: true
  performance_optimization: true

exclude_features:
  unused_channels: []
  unsupported_downlinks: []
  legacy_modes: false
  debug_logging: false
```

### UI Customization
```yaml
display_preferences:
  single_line_preferred: false      # Use multi-line for comprehensive display
  multi_line_for_alerts: true
  custom_emojis:
    socket_on: "🟢"
    socket_off: "🔴"
    voltage: "⚡"
    current: "🔌"
    power: "💡"
    energy: "🏠"
    power_factor: "📊"
    power_on_event: "⚡"
    power_outage_event: "⚠️"
    device_reset: "🔄"
    software_version: "📟"
  hide_technical_info: true         # Hide serial number from display
  emphasize_alerts: true
  battery_prominance: "hidden"      # Mains powered
  rssi_display: "icon"
```

### Command Preferences
```yaml
command_configuration:
  command_prefix: "LwWS52x"
  include_aliases: false
  parameter_validation: "strict"
  error_responses: "detailed"
  backwards_compatibility: false
```

---

## 🎯 CUSTOM REQUIREMENTS

### Special Handling
```yaml
special_requirements:
  custom_crc_validation: false
  signed_value_handling: ["active_power"]
  endianness_override: {}
  unit_conversions:
    energy_wh: "smart_scaling"      # Auto-scale to kWh/MWh/GWh when >= 1000
  threshold_monitoring: ["active_power", "current"]
  custom_validation_rules:
    voltage: "range_90_300"
    current: "range_0_30000"
    active_power: "range_-3000_3000"
```

### Performance Requirements
```yaml
performance_targets:
  max_decode_time_ms: 5
  memory_optimization: "normal"
  stack_usage_limit: 50
  payload_size_limit: 100
```

### Integration Requirements
```yaml
integration_needs:
  mqtt_topic_override: ""
  home_assistant_discovery: true
  influxdb_formatting: false
  prometheus_metrics: false
  custom_web_ui_elements:
    - "cumulative_state_display"
    - "event_timestamp_formatting"
    - "lwreload_recovery"
```

---

## 🧪 TESTING CONFIGURATION

### Test Scenarios
```yaml
test_configuration:
  realistic_test_data: true
  stress_test_payloads: false
  regression_test_suite: true
  performance_benchmarks: true
  
custom_test_scenarios:
  - name: "normal"
    description: "240V, 100W, 100%, 4730Wh, 420mA, ON"
    expected_params: ["voltage", "active_power", "power_factor", "energy_wh", "current", "socket_on"]
    
  - name: "low"
    description: "90V, 25W, 50%, 4721Wh, 50mA, OFF"
    expected_params: ["voltage", "active_power", "power_factor", "energy_wh", "current", "socket_on"]
    
  - name: "high"
    description: "500V, 1000W, 100%, 50000Wh, 1000mA, ON"
    expected_params: ["voltage", "active_power", "power_factor", "energy_wh", "current", "socket_on"]
    
  - name: "alert"
    description: "420V, 800W, 80%, 4730Wh, 700mA, ON, power outage event"
    expected_params: ["voltage", "active_power", "power_factor", "energy_wh", "current", "socket_on", "power_outage_event"]
    
  - name: "config"
    description: "SW v1.3, OC alarm 5A, LED on, power rec off, 10min interval"
    expected_params: ["sw_version", "oc_alarm_enabled", "oc_alarm_threshold", "led_enabled", "power_recording", "report_interval_min"]
    
  - name: "info"
    description: "Protocol v1, HW v1.10, SW v1.3, Class A, Serial"
    expected_params: ["protocol_version", "hw_version", "sw_version", "device_class", "serial_number"]
    
  - name: "ack_interval"
    description: "Interval ACK: 60 minutes confirmed"
    expected_params: ["interval_ack"]
    
  - name: "ack_reboot"
    description: "Reboot ACK: confirmed"
    expected_params: ["reboot_ack"]
    
  - name: "ack_delay"
    description: "Delay Task ACK: 3600 seconds confirmed"
    expected_params: ["delay_task_ack"]
    
  - name: "ack_delete"
    description: "Delete Task ACK: task #5 confirmed"
    expected_params: ["delete_task_ack"]
```

### Validation Requirements
```yaml
validation_requirements:
  syntax_validation: true
  framework_compliance: true
  memory_leak_detection: true
  error_path_testing: true
  command_parameter_validation: true
  downlink_hex_accuracy: true
```

---

## 📝 DOCUMENTATION REQUIREMENTS

### Documentation Level
```yaml
documentation_preferences:
  comprehensive_docs: true
  api_reference: true
  usage_examples: true
  troubleshooting_guide: false
  integration_guide: true
  performance_metrics: true
```

### Output Format
```yaml
output_configuration:
  generate_map_file: false       # MAP file already exists and current
  generate_md_docs: true
  update_emoji_reference: false  # No new emojis needed
  update_driver_list: true
  create_generation_report: true
```

---

## 🚀 EXECUTION PREFERENCES

### Generation Workflow
```yaml
workflow_preferences:
  silent_generation: false       # Show progress for comprehensive generation
  validation_before_output: true
  optimization_passes: 3
  backup_existing: true
```

### Quality Assurance
```yaml
quality_requirements:
  uplink_coverage: 100
  downlink_coverage: 100
  test_payload_coverage: 100
  error_handling_coverage: true
  code_review_level: "production"
```

---

## 💬 ADDITIONAL NOTES

### Current Implementation Features (v1.5.2)
```
CRITICAL: Maintain these exact features in regeneration:

1. **Critical Berry Patterns (MANDATORY)**:
   - Keys() method safety: size() check before for..keys() iteration
   - Nil safety: all timestamp comparisons with != nil checks
   - Display error protection: try/catch wrapper in add_web_sensor()
   - lwreload recovery: fallback to ANY stored node when self.node nil

2. **Enhanced UI Display**:
   - 4-sensor lines: Socket+Voltage+Current+Power, PowerFactor+Energy+Delta, Version+Config, Events
   - Smart energy scaling: Wh → kWh → MWh → GWh when >= 1000
   - Event timestamps: "02m Power On", "15s Outage", "01h Reset(CMD)"
   - Cumulative state: permanent data persists, events show for 1 minute
   - No serial number in display (removed for cleaner UI)

3. **Robust Error Handling**:
   - All format_age_short/format_age functions nil-safe
   - Display function never crashes, shows error message instead
   - Current_time nil checks before any arithmetic

4. **Global Storage Patterns**:
   - Device state separation: permanent vs temporary events
   - Event timestamps stored: power_on_timestamp, power_outage_timestamp, device_reset_timestamp  
   - History tracking: energy_history, socket_changes, reset_count

5. **All Downlink Commands Working**:
   - LwWS52xControl, LwWS52xInterval, LwWS52xOCAlarm, LwWS52xOCProtection
   - LwWS52xButtonLock, LwWS52xLED, LwWS52xPowerRecording
   - LwWS52xResetEnergy, LwWS52xStatus, LwWS52xReboot
   - LwWS52xDelayTask, LwWS52xDeleteTask

6. **Framework Compatibility**:
   - UPPERCASE field names: data['RSSI'], data['FPort'] 
   - Simulated parameter handling
   - Framework v2.2.9 patterns
```

### Known Working Patterns
```
- Uplink coverage: 25/25 channels (100%)
- Downlink coverage: 12/12 commands (100%)  
- Test scenarios: 10 scenarios (normal, low, high, alert, config, info, 4x ACK)
- Performance: <5ms decode time, <500 bytes memory per node
- UI: 4-line display, smart scaling, event timing, clean layout
- Error handling: Production-grade with nil safety throughout
```

---

## 📞 GENERATION REQUEST SUMMARY

**Request ID**: `WS52x-REQ-2025-08-25`  
**Submitted**: `2025-08-25 19:30:00`  
**Priority**: `high`  
**Estimated Complexity**: `complex`  
**Expected Deliverables**:
- [x] Driver file: `vendor/milesight/WS52x.be`
- [x] Documentation: `vendor/milesight/WS52x.md`
- [ ] MAP cache: `vendor/milesight/WS52x-MAP.md` (already current)
- [x] Test scenarios: Integrated in driver
- [x] Generation report: `vendor/milesight/WS52x-REPORT.md`

**Version Target**: v1.6.0 (maintain all v1.5.2 features + template v2.3.5 patterns)

---

## ✅ PRE-SUBMISSION CHECKLIST

- [x] Device information complete
- [x] Source documentation available (MAP file current)
- [x] Feature requirements clearly specified
- [x] Test scenarios defined (10 scenarios)
- [x] Special requirements documented (critical patterns)
- [x] Output preferences configured
- [x] Additional notes added (current implementation details)

---

**🤖 AI Generation Ready**: Request for WS52x regeneration with all current features + latest template patterns.

---

*Form Version: 2.3.5 | Compatible with Template Version: 2.3.5*  
*Generated: 2025-08-25 19:30:00 | Framework: LwDecode v2.2.9*