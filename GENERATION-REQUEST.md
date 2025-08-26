# LoRaWAN Decoder Generation Request Form v2.4.0

## Overview
Structured form for requesting AI-generated LoRaWAN sensor drivers with comprehensive feature coverage and reproducibility support.

## Request Template

```yaml
# [VENDOR] [MODEL] Driver Generation Request
## Version: 2.4.0 | Framework: LwDecode v2.3.0 | Platform: Tasmota Berry

### Request Type
- [ ] NEW - First-time driver generation
- [ ] REGENERATE - Fresh generation from existing MAP file
- [ ] UPGRADE - Framework/template version upgrade
- [ ] FEATURE - Add specific capabilities

### Device Information
vendor: "[VENDOR]"
model: "[MODEL]"
type: "[DEVICE_TYPE]"
description: "[DEVICE_DESCRIPTION]"

### Official References
homepage: "[HOMEPAGE_URL]"
userguide: "[USERGUIDE_URL]"
decoder_reference: "[DECODER_URL]"
firmware_version: "latest"
lorawan_version: "[LORAWAN_VERSION]"
regions: [REGIONS_LIST]

### Feature Selection
include_features:
  uplink_decoding: true
  downlink_commands: true
  test_ui_scenarios: true
  node_management: true
  battery_tracking: [true/false]
  reset_detection: true
  configuration_sync: true
  error_recovery: true
  performance_optimization: true
  multi_ui_support: true              # NEW v2.4.0
  slideshow_mode: [true/false]        # NEW v2.4.0

### Multi-UI Configuration (v2.4.0)
ui_styles_supported: 
  - "minimal"      # Icons + values only
  - "compact"      # Default behavior
  - "detailed"     # With labels
  - "technical"    # Full device info

slideshow_configuration:
  enable_slideshow: [true/false]
  slide_types:
    - "primary"     # Main sensor data
    - "secondary"   # Additional measurements
    - "events"      # Alerts/warnings
    - "technical"   # Device information
    - "trends"      # Historical data
  slide_duration: 5000              # Default 5 seconds
  
### UI Customization
display_preferences:
  single_line_preferred: [true/false]
  multi_line_for_alerts: true
  custom_emojis: [EMOJI_MAPPINGS]
  hide_technical_info: [true/false]
  emphasize_alerts: true
  battery_prominance: "[hidden/normal/prominent]"
  rssi_display: "icon"

### Custom Requirements
special_requirements:
  signed_value_handling: [SIGNED_PARAMS]
  unit_conversions: [UNIT_CONVERSIONS]
  threshold_monitoring: [THRESHOLD_PARAMS]
  custom_validation_rules: [VALIDATION_RULES]

### Test Configuration
custom_test_scenarios:
  - name: "normal"
    description: "[NORMAL_SCENARIO_DESCRIPTION]"
    expected_params: [EXPECTED_PARAMETERS]
  - name: "alert"
    description: "[ALERT_SCENARIO_DESCRIPTION]"
    expected_params: [EXPECTED_PARAMETERS]
  [ADDITIONAL_SCENARIOS...]

### Request Summary
Request ID: [MODEL]-REQ-[DATE]
Submitted: [TIMESTAMP]
Version Target: v[TARGET_VERSION]
Expected Deliverables:
- [ ] Driver file: vendor/[vendor]/[MODEL].be
- [ ] Documentation: vendor/[vendor]/[MODEL].md
- [ ] MAP cache: vendor/[vendor]/[MODEL]-MAP.md
- [ ] Generation report: vendor/[vendor]/[MODEL]-REPORT.md
- [ ] Generation request: vendor/[vendor]/[MODEL]-REQ.md
```

## Multi-UI & Slideshow Features (v2.4.0)

### Style Examples
```yaml
minimal_style:
  format: "🌡️ 23.4°C ⏱️2m"
  description: "Icons and values only"

compact_style:
  format: "🌡️ 23.4°C 💧 65% ⏱️2m ago"
  description: "Current default behavior"

detailed_style:
  format: "🌡️ Temperature: 23.4°C\n💧 Humidity: 65%"
  description: "With descriptive labels"

technical_style:
  format: "Device: WS523-A1B2C3\nFW: v2.1.0 HW: v1.3\n🌡️ Temperature: 23.4°C"
  description: "Full technical information"
```

### Slideshow Implementation
```yaml
slide_structure:
  slide_1_primary:
    content: "Main sensor readings"
    always_shown: true
    
  slide_2_secondary:
    content: "Additional measurements"
    condition: "has_secondary_data()"
    
  slide_3_events:
    content: "Recent events/alerts"
    condition: "has_recent_events()"
    
  slide_4_technical:
    content: "Device info/diagnostics"
    condition: "has_technical_info()"
    
  slide_5_trends:
    content: "Historical data/trends"
    condition: "has_trends_data()"
```

## Advanced Request Examples

### Environmental Sensor with Slideshow
```yaml
vendor: "Dragino"
model: "LHT65N"
type: "Environmental Sensor"
include_features:
  multi_ui_support: true
  slideshow_mode: true
  
slideshow_configuration:
  enable_slideshow: true
  slide_types: ["primary", "secondary", "events", "technical"]
  slide_duration: 4000
  
display_preferences:
  single_line_preferred: false
  multi_line_for_alerts: true
```

### Simple Sensor - Minimal UI
```yaml
vendor: "Milesight" 
model: "WS101"
type: "Smart Button"
include_features:
  multi_ui_support: true
  slideshow_mode: false
  
ui_styles_supported: ["minimal", "compact"]
display_preferences:
  single_line_preferred: true
```

## Usage Instructions

1. **Copy template** above and fill in device-specific information
2. **Specify UI requirements** - Choose appropriate styles and slideshow settings
3. **Define test scenarios** - Include realistic payload examples
4. **Submit to AI** - Provide completed form with device documentation
5. **Review output** - Verify all requested features are implemented

## Version History

- **v2.4.0** (2025-08-26): Added Multi-UI Style System and Slideshow Framework support
- **v2.3.3** (2025-08-20): Enhanced test scenario specification
- **v2.3.0** (2025-08-16): Added feature selection and UI customization
- **v2.2.0** (2025-08-14): REQ file generation for reproducibility

---

*Form Version: 2.4.0 | Compatible with Template Version: 2.4.0*  
*Framework: LwDecode v2.3.0 | Platform: Tasmota Berry*

---

*Author: [ZioFabry](https://github.com/ZioFabry)*
