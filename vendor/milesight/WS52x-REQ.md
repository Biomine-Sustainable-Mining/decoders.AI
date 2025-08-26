# Milesight WS52x Driver Generation Request
## Version: 2.4.0 | Framework: LwDecode v2.3.0 | Platform: Tasmota Berry

### Request Type
- [x] REGENERATE - Fresh generation from existing MAP file
- [x] FULL - Complete driver with all features

### Device Information
vendor: "Milesight"
model: "WS52x"
type: "Smart Power Socket"
description: "AC Power Socket with Energy Metering and Remote Control"

### Official References
homepage: "https://www.milesight.com/iot/product/lorawan-sensor/ws52x"
userguide: "https://www.milesight.com/iot/product/lorawan-sensor/ws52x"
decoder_reference: "https://github.com/Milesight-IoT/SensorDecoders/blob/master/WS_Series/WS52x/WS52x.js"
firmware_version: "latest"
lorawan_version: "1.0.3"
regions: ["EU868", "US915", "AU915", "AS923", "KR920", "IN865", "RU864"]

### Feature Selection
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
  slideshow_support: true          # NEW: Multi-UI slideshow capability

### UI Customization
display_preferences:
  single_line_preferred: false      # Power data benefits from multi-line
  multi_line_for_alerts: true
  custom_emojis: {
    "socket_on": "🟢",
    "socket_off": "🔴", 
    "voltage": "⚡",
    "current": "🔌",
    "power": "💡",
    "energy": "🏠",
    "power_factor": "📊",
    "reset": "🔄",
    "power_on": "⚡",
    "outage": "🚨",
    "locked": "🔒"
  }
  hide_technical_info: false       # Show device versions and serial
  emphasize_alerts: true
  battery_prominence: "hidden"     # Mains powered - no battery display
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: ["active_power"]     # Power can be negative
  unit_conversions: ["smart_scaling"]         # Energy auto-scaling (Wh/kWh/MWh/GWh)
  threshold_monitoring: ["oc_alarm_threshold", "oc_protection_threshold"]
  custom_validation_rules: ["energy_counter_overflow", "power_factor_range"]

### Test Configuration
custom_test_scenarios:
  - name: "normal"
    description: "Normal operation with socket ON and typical power consumption"
    expected_params: ["socket_state", "voltage", "current", "active_power", "energy", "power_factor"]
  - name: "high"
    description: "High power load scenario (heater/appliance)"
    expected_params: ["socket_state", "voltage", "current", "active_power", "energy"]
  - name: "off"
    description: "Socket OFF state with no power consumption"
    expected_params: ["socket_state", "voltage", "current", "active_power", "energy"]
  - name: "standby"
    description: "Low power standby mode"
    expected_params: ["socket_state", "voltage", "current", "active_power", "energy"]
  - name: "reset"
    description: "Device reset event with power data"
    expected_params: ["device_reset", "reset_reason", "socket_state", "voltage"]
  - name: "config"
    description: "Configuration response with all device settings"
    expected_params: ["interval_minutes", "oc_alarm_enabled", "button_locked"]
  - name: "outage"
    description: "Power outage event scenario"
    expected_params: ["power_outage_event", "socket_state", "voltage"]
  - name: "energy_reset"
    description: "Energy counter reset acknowledgment"
    expected_params: ["socket_state", "voltage", "current", "energy"]

### Additional Notes
Current Implementation Features (v1.4.0):
```
CRITICAL: Maintain these exact features in regeneration:

1. **Critical Berry Patterns (MANDATORY)**:
   - Global storage for WS52x_nodes with energy_history tracking
   - Nil-safe keys() iteration with size() checks
   - Try/catch blocks in add_web_sensor() for display error protection
   - Data recovery after lwreload using fallback node discovery
   - Smart energy scaling with GWh/MWh/kWh/Wh auto-selection

2. **Enhanced UI Display**:
   - Multi-line power display with socket state, voltage, current, power
   - Energy and power factor on second line
   - Conditional events line (reset, power on, outage, button lock)
   - Age display for stale data (>1 hour old)
   - Smart energy unit scaling based on magnitude

3. **Robust Error Handling**:
   - Payload size validation before channel parsing
   - Conservative byte advancement to prevent infinite loops
   - Bounds checking for all payload access operations
   - Unknown channel logging without parser termination
   - Display error protection with fallback error message

4. **Global Storage Patterns**:
   - WS52x_nodes map for multi-device support
   - Energy consumption history (last 10 readings)
   - Reset event counting and timestamp tracking
   - Node data persistence across driver reloads
   - Name and last_update caching

5. **All Downlink Commands Working**:
   - LwWS52xControl (socket on/off with SendDownlinkMap)
   - LwWS52xSetInterval (reporting interval configuration)
   - LwWS52xOCAlarm/LwWS52xOCProtection (overcurrent settings)
   - LwWS52xButtonLock (physical button control)
   - LwWS52xLED/LwWS52xPowerRecord (device feature toggles)
   - LwWS52xResetEnergy/LwWS52xStatus/LwWS52xReboot (maintenance commands)
   - LwWS52xDelayTask/LwWS52xDeleteTask (advanced task management)
   - All commands use proper parameter validation and error messages

6. **NEW: Slideshow Framework Integration**:
   - build_slideshow_slides() method implemented
   - Five slide types: Power Status, Energy Summary, Device Status, Configuration, Events & Alerts
   - Integration with LwSlideBuilder for consistent slide formatting
   - Data recovery patterns applied to slideshow content
   - Conditional slide creation based on available data

7. **Framework Compatibility**:
   - Framework v2.3.0 with Multi-UI and Slideshow support
   - Backward compatibility maintained with existing UI styles
   - Enhanced error handling with try/catch in display functions
   - Global storage recovery patterns for driver reload scenarios
   - All 25 uplink channels and 12 downlink commands fully implemented
```

### Request Summary
Request ID: WS52x-REQ-20250826
Submitted: 2025-08-26 18:45:00
Version Target: v1.4.0
Expected Deliverables:
- [x] Driver file: vendor/milesight/WS52x.be
- [x] Documentation: vendor/milesight/WS52x.md
- [x] Generation report: vendor/milesight/WS52x-REPORT.md

*Form Version: 2.4.0 | Compatible with Template Version: 2.4.0*
*Generated: 2025-08-26 18:45:00 | Framework: LwDecode v2.3.0*