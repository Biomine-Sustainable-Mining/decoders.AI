# WS101 Driver Generation Request
## Version: 2.3.6 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

---

## 📋 GENERATION REQUEST

### Request Type
- [x] **REGENERATE** - Fresh generation from existing MAP file
- [x] **FULL** - Complete driver with all features

---

## 🏭 DEVICE INFORMATION

### Basic Details
```yaml
vendor: "Milesight"
model: "WS101"
type: "Smart Button"
description: "LoRaWAN smart button with multiple press modes and battery monitoring"
```

### Official References
```yaml
homepage: "https://www.milesight.com/iot/product/lorawan-sensor/ws101"
userguide: "https://resource.milesight.com/milesight/iot/document/ws101-datasheet-en.pdf"
decoder_reference: "https://github.com/Milesight-IoT/SensorDecoders"
firmware_version: "latest"
lorawan_version: "1.0.3"
regions: ["EU868", "US915", "AU915", "AS923", "KR920", "IN865", "RU864"]
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
  battery_tracking: true
  reset_detection: true
  configuration_sync: true
  error_recovery: true
  performance_optimization: true
  button_statistics: true
```

### UI Customization
```yaml
display_preferences:
  single_line_preferred: true
  custom_emojis:
    short_press: "🔘"
    long_press: "🔴" 
    double_press: "⚫"
    battery_low: "🪫"
    battery_normal: "🔋"
    power_on: "🔄"
    device_info: "📋"
  hide_technical_info: false
  emphasize_alerts: true
  battery_prominance: "prominent"
  rssi_display: "icon"
```

---

## 🎯 CUSTOM REQUIREMENTS

### Special Handling
```yaml
special_requirements:
  button_event_tracking: true
  battery_trend_analysis: true
  press_type_statistics: true
  visual_press_feedback: true
  emergency_detection: true
```

---

## 🧪 TESTING CONFIGURATION

### Test Scenarios
```yaml
custom_test_scenarios:
  - name: "normal"
    description: "Short press + 80% battery"
    expected_params: ["button_event", "battery_pct", "press_type"]
    
  - name: "long" 
    description: "Long press + 50% battery"
    expected_params: ["button_event", "battery_pct", "press_type"]
    
  - name: "double"
    description: "Double press + 20% battery"
    expected_params: ["button_event", "battery_pct", "press_type"]
    
  - name: "emergency"
    description: "Long press (SOS) + low battery"
    expected_params: ["button_event", "battery_pct", "battery_status"]
    
  - name: "powerup"
    description: "Power on event + device info"
    expected_params: ["power_on_event", "sw_version", "device_class"]
```

---

## 💬 ADDITIONAL NOTES

### Current Implementation Features (v1.3.0)
```
CRITICAL: Maintain these exact features in regeneration:

1. **Enhanced Button Tracking**:
   - Press type statistics (short/long/double counters)
   - Visual feedback per press type
   - Battery trend indicators (↓/↑)
   
2. **Framework v2.2.9 Patterns**:
   - UPPERCASE field names (RSSI, FPort)
   - Simulated parameter handling
   - Error handling with try/catch
   - Data recovery fallback patterns

3. **Smart Button Features**:
   - Emergency detection (long press + low battery)
   - Scene control (double press)
   - Battery trend analysis
   - Device reset tracking
```

---

## 📞 GENERATION REQUEST SUMMARY

**Request ID**: `WS101-REQ-2025-08-25`  
**Submitted**: `2025-08-25 19:50:00`  
**Priority**: `high`
**Version Target**: v1.3.0 (framework v2.2.9 + template v2.3.6)

**Expected Deliverables**:
- [x] Driver file: `vendor/milesight/WS101.be`
- [x] Documentation: `vendor/milesight/WS101.md`
- [x] Generation report: `vendor/milesight/WS101-REPORT.md`
- [x] Request file: `vendor/milesight/WS101-REQ.md`

---

*Generated: 2025-08-25 19:50:00 | Framework: LwDecode v2.2.9*
