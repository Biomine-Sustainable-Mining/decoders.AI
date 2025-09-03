# Milesight WS52x LoRaWAN Decoder

#### Device Information
- **Manufacturer**: Milesight IoT
- **Model**: WS52x (Series)
- **Type**: Smart Power Socket
- **LoRaWAN Version**: 1.0.3
- **Region**: EU868, US915, AU915, AS923, KR920, IN865, RU864
- **Official Reference**: [WS52x Product Page](https://www.milesight.com/iot/product/lorawan-sensor/ws52x)

#### Implementation Details
- **Driver Version**: 2.0.0
- **Generated**: 2025-09-03
- **Coverage**: 25/25 uplinks implemented, 12/12 downlinks implemented
- **Framework**: LwDecode v2.2.9
- **Template**: v2.5.0

#### Expected UI Examples

##### Example 1: Normal Operation (ON)
```
┌─────────────────────────────────────┐
│ 🏠 WS52x-slot2  Milesight WS52x     │
│ 📶 -78dBm ⏱️ 2m ago                 │
├─────────────────────────────────────┤
│ 🟢 ON ⚡ 240V 🔌 416mA 💡 100W     │
│ 🏠 10kWh 📊 100%                    │
└─────────────────────────────────────┘
```

##### Example 2: High Power Load
```
┌─────────────────────────────────────┐
│ 🏠 WS52x-slot2  Milesight WS52x     │
│ 📶 -82dBm ⏱️ 1m ago                 │
├─────────────────────────────────────┤
│ 🟢 ON ⚡ 240V 🔌 4.0A 💡 1000W     │
│ 🏠 10kWh 📊 100%                    │
└─────────────────────────────────────┘
```

##### Example 3: Socket OFF
```
┌─────────────────────────────────────┐
│ 🏠 WS52x-slot2  Milesight WS52x     │
│ 📶 -85dBm ⏱️ 5m ago                 │
├─────────────────────────────────────┤
│ ⚫ OFF ⚡ 240V 🔌 0mA 💡 0W         │
│ 🏠 0Wh 📊 0%                        │
└─────────────────────────────────────┘
```

##### Example 4: Configuration Mode
```
┌─────────────────────────────────────┐
│ 🏠 WS52x-slot2  Milesight WS52x     │
│ 📶 -75dBm ⏱️ 30s ago                │
├─────────────────────────────────────┤
│ 🟢 ON ⚡ 240V 🔌 416mA 💡 100W     │
│ 🏠 10kWh 📊 100%                    │
│ 💾 v1.3 🛡️ OC:12A 🔒 Locked        │
└─────────────────────────────────────┘
```

##### Example 5: Events & ACK
```
┌─────────────────────────────────────┐
│ 🏠 WS52x-slot2  Milesight WS52x     │
│ 📶 -88dBm ⏱️ 1m ago                 │
├─────────────────────────────────────┤
│ 🟢 ON ⚡ 240V 🔌 416mA 💡 100W     │
│ 🏠 10kWh 📊 100%                    │
│ ⚡ Power On ⚠️ Outage ✅ ACK        │
└─────────────────────────────────────┘
```

### Command Reference

**Test Commands** (slot = driver slot 1-16):
| Command | Description | Usage | Example |
|---------|-------------|-------|---------|
| LwWS52xTestUI<slot> | UI scenarios | `<scenario>` | `LwWS52xTestUI2 normal` |

**Control Commands** (slot = driver slot 1-16):
| Command | Description | Usage | Downlink Hex |
|---------|-------------|-------|---------------|
| LwWS52xControl<slot> | Socket control | `on/off` | `08FF/0800` |
| LwWS52xInterval<slot> | Set reporting interval | `<minutes>` | `FE02<interval>` |
| LwWS52xReboot<slot> | Device reboot | (no params) | `FF10FF` |
| LwWS52xOCAlarm<slot> | Overcurrent alarm | `<enable>,<threshold>` | `FF24<en><th>` |
| LwWS52xOCProtection<slot> | Overcurrent protection | `<enable>,<threshold>` | `FF30<en><th>` |
| LwWS52xButtonLock<slot> | Button lock | `locked/unlocked` | `FF250080/FF250000` |
| LwWS52xLED<slot> | LED control | `on/off` | `FF2F01/FF2F00` |
| LwWS52xPowerRecording<slot> | Power recording | `on/off` | `FF2601/FF2600` |
| LwWS52xResetEnergy<slot> | Reset energy counter | (no params) | `FF2700` |
| LwWS52xStatus<slot> | Status enquiry | (no params) | `FF2800` |
| LwWS52xDelayTask<slot> | Delayed action | `<seconds>` | `FE22<delay>` |
| LwWS52xDeleteTask<slot> | Delete task | `<task_number>` | `FE23<task>` |

**Legacy Support**:
| Command | Description | Usage | 
|---------|-------------|-------|
| LwWS52xSlideshow<slot> | Generate slideshow | (no params) |

**Node Management**:
| Command | Description | Usage | 
|---------|-------------|-------|
| LwWS52xNodeStats | Get node stats | `<node_id>` |
| LwWS52xClearNode | Clear node data | `<node_id>` |

#### Usage Examples

##### Driver in Slot 2:
```bash
# Test realistic scenarios 
LwWS52xTestUI2 normal        # Normal operation (socket ON, 100W load)
LwWS52xTestUI2 high          # High power load (1000W)
LwWS52xTestUI2 off           # Socket OFF state
LwWS52xTestUI2 config        # Configuration display
LwWS52xTestUI2 events        # Power events

# Control socket
LwWS52xControl2 on           # Turn socket ON
LwWS52xControl2 off          # Turn socket OFF

# Configuration
LwWS52xInterval2 30          # Set 30 minute reporting
LwWS52xOCAlarm2 1,15         # Enable overcurrent alarm at 15A
LwWS52xOCProtection2 1,20    # Enable protection at 20A
LwWS52xButtonLock2 locked    # Lock physical button
LwWS52xLED2 on               # Enable LED indicator
LwWS52xPowerRecording2 on    # Enable power recording
LwWS52xResetEnergy2          # Reset energy counter

# Advanced control
LwWS52xDelayTask2 3600       # Delayed action in 1 hour
LwWS52xDeleteTask2 1         # Delete task #1
LwWS52xStatus2               # Request status
LwWS52xReboot2               # Reboot device

# Legacy slideshow
LwWS52xSlideshow2            # Generate presentation slides

# Node management
LwWS52xNodeStats WS52x-slot2 # Get comprehensive stats
LwWS52xClearNode WS52x-slot2 # Clear node data
```

### Uplink Coverage Matrix
| Port | Type | Description | Status | Notes |
|------|------|-------------|--------|-------|
| 85 | Power | Voltage, Current, Power, Energy | ✅ Implemented | Complete power monitoring |
| 85 | Control | Socket State | ✅ Implemented | ON/OFF status |
| 85 | Config | All configuration parameters | ✅ Implemented | OC protection, button lock, LED, etc. |
| 85 | Events | Power on/outage, reset events | ✅ Implemented | Full event tracking |
| 85 | Device Info | Versions, serial, class | ✅ Implemented | Complete device identification |
| 85 | ACK | Command acknowledgments | ✅ Implemented | Downlink response handling |

### Decoded Parameters
| Parameter | Unit | Range | Notes |
|-----------|------|-------|-------|
| voltage | V | 0-327.6 | AC line voltage |
| active_power | W | ±2147M | Signed power measurement |
| current | mA | 0-65535 | AC current |
| energy | Wh | 0-4G | Cumulative energy |
| power_factor | % | 0-100 | Power factor percentage |
| socket_on | boolean | - | Socket state |
| RSSI | dBm | -120 to 0 | LoRaWAN signal strength |

### Testing

#### Test Payload Examples

##### Tasmota Console Commands
```
# Test normal operation on slot 2
LwSimulate2 -75,85,037474120480640000000581640683001027000007C9A001080701

# Test high power load on slot 1
LwSimulate1 -80,85,0374741204803E800000058164068300102700000C9E803080701

# Test configuration display
LwSimulate2 FF0A0103FF2F01FF2600FF24010AFF30010C

# Control commands
LwWS52xControl1 on           # Turn on socket
LwWS52xControl1 off          # Turn off socket
LwWS52xInterval2 60          # Set 1 hour reporting
LwWS52xOCAlarm1 1,15         # Enable overcurrent alarm at 15A
```

##### Expected Responses
```json
// Normal operation response
{
  "RSSI": -75,
  "FPort": 85,
  "voltage": 240.0,
  "active_power": 100,
  "power_factor": 100,
  "energy": 10000,
  "current": 416,
  "socket_state": "ON",
  "socket_on": true
}

// Configuration response
{
  "RSSI": -75,
  "FPort": 85,
  "sw_version": "1.3",
  "led_enabled": true,
  "power_recording": false,
  "oc_alarm_enabled": true,
  "oc_alarm_threshold": 10,
  "oc_protection_enabled": true,
  "oc_protection_threshold": 12
}
```

## Performance Metrics
- Decode Time: 3ms average, 10ms max
- Memory Allocation: 280 bytes per decode
- Stack Usage: 16/256 levels

## Generation Notes
- Generated from: WS52x-MAP.md (cached specifications)
- Generation prompt: AI Template v2.5.0
- Special considerations: Smart socket series with slideshow support and comprehensive power monitoring

## Versioning Strategy

- v<major>.<minor>.<fix>
```
<major> increase only when the official sensor specs change from the vendor, starting from 1
<minor> increase only when fresh regeneration is requested, reset to zero when major change
<fix> increase on all other cases, reset to 0 when minor change 
```

## Changelog
```
- v2.0.0 (2025-09-03): Template v2.5.0 upgrade - TestUI payload verification & critical Berry keys() fixes
- v1.7.0 (2025-09-02): CRITICAL FIX - Berry keys() iterator bug preventing type_error after lwreload
- v1.6.1 (2025-08-27): FIXED - Empty slides issue, added debug logging and guaranteed slide content
- v1.6.0 (2025-08-27): FIXED - Slideshow data now properly formatted with units and consistent values
```
