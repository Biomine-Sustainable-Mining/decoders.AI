# Feature Request 0001: Multi-UI Style & Timed Slideshow Framework
## Version: 1.0 | Date: 2025-08-26 | Framework: LwDecode v2.2.9+

---

## Overview
Add framework-level support for multiple UI display styles and synchronized multi-slide presentations across all drivers, enabling dynamic sensor information display with configurable detail levels and timed rotation.

## Problem Statement
Current framework limitations:
- Fixed single-line display format across all drivers
- No dynamic information presentation capability
- Limited customization for different use cases (minimal vs detailed)
- No synchronized multi-device UI updates
- Information overload on complex sensors vs insufficient detail on simple sensors

## Proposed Solution

### 1. Multi-UI Style System

#### 1.1 Style Definitions
```yaml
ui_styles:
  minimal:
    format: "icon_value_age"
    example: "🔋 3.8V 2m"
    description: "Icons, values, age only - no text labels"
    
  minimal_text:
    format: "icon_value_age_newline"  
    example: "🔋 3.8V ⏱️2m ago\n📶 -75dBm ⏱️2m ago"
    description: "Icons, values with age on new lines"
    
  compact:
    format: "icon_value_inline"
    example: "🔋 3.8V 📶 -75dBm ⏱️ 2m"
    description: "Current framework style (default)"
    
  detailed:
    format: "icon_label_value_unit"
    example: "🔋 Battery: 3.8V\n📶 Signal: -75dBm"
    description: "Icons with descriptive labels"
    
  technical:
    format: "full_technical_info"
    example: "Device: WS523-A1B2C3\nFW: v2.1.0 HW: v1.3"
    description: "Technical details and diagnostics"
```

#### 1.2 Framework API Addition
```berry
class LwDisplayManager
    static var current_style = "compact"  # Global style setting
    static var style_config = {}
    
    static def set_ui_style(style)
        # Validate and set global UI style
    end
    
    def apply_style(formatter, data, style_override)
        # Apply style-specific formatting rules
    end
end
```

### 2. Timed Slideshow Framework

#### 2.1 Slide System Architecture
```berry
class LwSlideshowManager
    static var slide_duration = 5000    # 5 seconds per slide
    static var current_slide = 0
    static var slide_cycle_start = 0
    static var sync_enabled = true
    
    static def get_current_slide_index()
        # Calculate synchronized slide index across all drivers
        var elapsed = tasmota.millis() - slide_cycle_start
        var slides_per_cycle = 5
        return int(elapsed / slide_duration) % slides_per_cycle
    end
end

class LwSlideBuilder
    var slides = []
    
    def add_slide(priority, builder_func, condition_func)
        # Add slide with priority, content builder, and show condition
    end
    
    def build_slideshow()
        # Generate final slide sequence based on available data
    end
end
```

#### 2.2 Standard Slide Types
1. **Primary Data** (Priority 1): Main sensor readings - always present
2. **Secondary Data** (Priority 2): Additional measurements if available  
3. **Events/Alerts** (Priority 3): Recent events, warnings, alerts
4. **Technical Info** (Priority 4): Firmware, serial, diagnostics
5. **Trends/Stats** (Priority 5): Historical data, statistics, trends

### 3. Driver Integration Pattern

#### 3.1 Enhanced Driver Structure
```berry
def add_web_sensor()
    try
        var slideshow = LwSlideBuilder()
        
        # Slide 1: Primary data (always shown)
        slideshow.add_slide(1, def() 
            return self.build_primary_slide()
        end, def() return true end)
        
        # Slide 2: Secondary data (conditional)
        slideshow.add_slide(2, def()
            return self.build_secondary_slide() 
        end, def() return self.has_secondary_data() end)
        
        # Slide 3: Events (conditional)
        slideshow.add_slide(3, def()
            return self.build_events_slide()
        end, def() return self.has_recent_events() end)
        
        # Slide 4: Technical (conditional)
        slideshow.add_slide(4, def()
            return self.build_technical_slide()
        end, def() return self.has_technical_info() end)
        
        # Slide 5: Trends (conditional)
        slideshow.add_slide(5, def()
            return self.build_trends_slide()
        end, def() return self.has_trends_data() end)
        
        # Get current slide content
        var slides = slideshow.build_slideshow()
        var current_idx = LwSlideshowManager.get_current_slide_index()
        var active_slide = slides.find(current_idx % size(slides), slides[0])
        
        return active_slide
        
    except .. as e, m
        print(f"{self.model}: Display error - {e}: {m}")
        return f"📟 {self.model} Error - Check Console"
    end
end
```

### 4. Implementation Details

#### 4.1 Global Configuration
```berry
# Add to LwDecode.be framework
class LwConfig
    static var ui_style = "compact"           # Default style
    static var slideshow_enabled = false     # Feature toggle
    static var slide_duration = 5000         # 5 second slides
    static var slide_sync_enabled = true     # Cross-driver sync
end

# Tasmota commands for configuration
tasmota.add_cmd("LwUIStyle", def(cmd, idx, style)
    LwDisplayManager.set_ui_style(style)
    tasmota.resp_cmnd_done()
end)

tasmota.add_cmd("LwSlideshow", def(cmd, idx, enabled)
    LwConfig.slideshow_enabled = (enabled == "1" || enabled == "on")
    tasmota.resp_cmnd_done()
end)
```

#### 4.2 Memory Optimization
- Lazy slide generation (build only when displayed)
- Slide content caching with TTL
- Conditional slide registration to minimize memory usage
- ESP32-friendly timing using `tasmota.millis()`

#### 4.3 Backward Compatibility
- Current drivers continue working unchanged
- New feature activated only when explicitly enabled
- Default behavior identical to current framework
- Gradual migration path for existing drivers

### 5. Configuration Examples

#### 5.1 Console Commands
```bash
# Set UI style
LwUIStyle minimal          # Minimal icons only
LwUIStyle compact          # Current default
LwUIStyle detailed         # With labels

# Enable slideshow
LwSlideshow on             # Enable timed slides
LwSlideDuration 3000       # 3 second slides
LwSlideSync off            # Disable cross-driver sync
```

#### 5.2 Driver Usage Examples
```berry
# Minimal implementation (backward compatible)
def add_web_sensor()
    if !LwConfig.slideshow_enabled
        return self.legacy_display()  # Current behavior
    end
    return self.slideshow_display()   # New slideshow
end

# Full implementation with all slides
def build_primary_slide()
    var fmt = LwSensorFormatter_cls()
    fmt.header(name, tooltip, battery, battery_ls, rssi, last_seen, simulated)
    fmt.start_line()
    fmt.add_sensor("temp", temperature, "Temperature", "🌡️")
    fmt.add_sensor("humidity", humidity, "Humidity", "💧")
    fmt.end_line()
    return fmt.get_msg()
end
```

### 6. Technical Specifications

#### 6.1 Framework Changes Required
- **LwDecode.be**: Add display manager and slideshow classes
- **LwSensorFormatter_cls**: Extend with style support
- **Driver Template**: Update generation template v2.4.0
- **Command System**: Add UI configuration commands

#### 6.2 Performance Impact
- Memory: +2-3KB framework overhead
- CPU: +5-10ms per display cycle (negligible)
- Flash: +1KB per driver with full slideshow support

#### 6.3 ESP32 Compatibility
- Uses existing `tasmota.millis()` for timing
- No additional libraries required
- Memory usage controlled through lazy loading
- Compatible with existing driver architecture

### 7. Migration Path

#### Phase 1: Framework Enhancement
1. Extend LwDecode.be with new classes
2. Add UI style and slideshow configuration
3. Update LwSensorFormatter_cls with style support
4. Add Tasmota configuration commands

#### Phase 2: Template Update
1. Update driver generation template to v2.4.0
2. Add slideshow support to generated drivers
3. Maintain backward compatibility
4. Test with existing drivers

#### Phase 3: Driver Migration
1. Regenerate drivers with slideshow support (optional)
2. Gradual rollout to complex sensors first
3. User adoption through configuration commands
4. Performance monitoring and optimization

### 8. Success Criteria
- ✅ Backward compatibility: All existing drivers work unchanged
- ✅ Memory efficient: <3KB framework overhead
- ✅ Synchronized display: Cross-driver slide timing
- ✅ User configurable: Console commands for all settings
- ✅ Extensible: Easy addition of new UI styles
- ✅ Performance: No impact on existing driver performance

---

## Implementation Priority: Medium
**Estimated Development**: 2-3 days  
**Testing Required**: Regression testing on all 18 existing drivers  
**Rollout**: Gradual adoption through driver regeneration

---

*Feature Request by: Framework Development Team*  
*Review Status: Draft - Pending Technical Review*
