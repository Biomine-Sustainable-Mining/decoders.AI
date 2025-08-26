# Milesight WS52x LoRaWAN Decoder

## Device Information
- **Manufacturer**: Milesight
- **Model**: WS52x Series
- **Type**: Smart Power Socket
- **LoRaWAN Version**: 1.0.3
- **Regions**: EU868, US915, AU915, AS923, KR920, IN865, RU864
- **Official Reference**: https://www.milesight.com/iot/product/lorawan-sensor/ws52x

## Implementation Details
- **Driver Version**: 2.0.0
- **Generated**: 2025-08-25
- **Coverage**: 25/25 uplinks implemented, 12/12 downlinks implemented
- **Framework**: LwDecode v2.2.9
- **Template**: v2.3.6

## Expected UI Examples

### Example 1: Normal Operation (Socket ON)
```
┌─────────────────────────────────────┐
│ 🏠 WS52x-slot2  Smart Power Socket  │
│     📶 -78dBm ⏱️ 2m ago             │
├─────────────────────────────────────┤
│ 🟢 ON ⚡ 240.0V 🔌 420mA 💡 100W    │
│ 📊 100% 🏠 4.7kWh                  │
└─────────────────────────────────────┘
```

### Example 2: Socket OFF (Standby)
```
┌─────────────────────────────────────┐
│ 🏠 WS52x-slot2  Smart Power Socket  │
│     📶 -82dBm ⏱️ 5m ago             │
├─────────────────────────────────────┤
│ 🔴 OFF ⚡ 240.0V 🔌 0mA 💡 0W       │
│ 📊 0% 🏠 4.7kWh                     │
└─────────────────────────────────────┘
```

### Example 3: High Power with Configuration
```
┌─────────────────────────────────────┐
│ 🏠 WS52x-slot2  Smart Power Socket  │
│     📶 -75dBm ⏱️ 1m ago             │
├─────────────────────────────────────┤
│ 🟢 ON ⚡ 230.0V 🔌 8700mA 💡 2000W  │
│ 📊 95% 🏠 50.0kWh                  │
│ 📟 v1.3 🛡️ OC Prot 🔒 Locked       │
└─────────────────────────────────────┘
```

## Command Reference

**Test Commands** (slot = driver slot 1-16):
| Command | Description | Usage | Example |
|---------|-------------|-------|---------|
| LwWS52xTestUI<slot> | UI scenarios | `<scenario>` | `LwWS52xTestUI2 normal` |

**Control Commands** (slot = driver slot 1-16):
| Command | Description | Usage | Downlink Hex |
|---------|-------------|-------|---------------|
| LwWS52xControl<slot> | Socket control | `on/off` | `08FF/0800` |
| LwWS52xInterval<slot> | Set interval | `<minutes>` | `FE02<LE16>` |
| LwWS52xOCAlarm<slot> | OC alarm config | `<enabled>,<threshold>` | `FF24<EN><TH>` |
| LwWS52xOCProtection<slot> | OC protection | `<enabled>,<threshold>` | `FF30<EN><TH>` |
| LwWS52xButtonLock<slot> | Button lock | `locked/unlocked` | `FF250080/FF250000` |
| LwWS52xLED<slot> | LED control | `on/off` | `FF2F01/FF2F00` |
| LwWS52xPowerRecording<slot> | Power recording | `on/off` | `FF2601/FF2600` |
| LwWS52xResetEnergy<slot> | Reset energy | (no params) | `FF2700` |
| LwWS52xStatus<slot> | Request status | (no params) | `FF2800` |
| LwWS52xReboot<slot> | Device reboot | (no params) | `FF10FF` |
| LwWS52xDelayTask<slot> | Delay task | `<seconds>` | `FE22<LE32>` |
| LwWS52xDeleteTask<slot> | Delete task | `<task_number>` | `FE23<LE16>` |

## Usage Examples

```bash
# Test scenarios
LwWS52xTestUI2 normal      # Normal operation
LwWS52xTestUI2 alert       # Alert condition  
LwWS52xTestUI2 high        # High power load

# Control
LwWS52xControl2 on         # Turn socket ON
LwWS52xInterval2 60        # Set 60 minute interval
LwWS52xOCAlarm2 1,10       # Enable OC alarm at 10A
```

## Key Features (v2.0.0)

### Clean Regeneration
- Pure MAP-based implementation
- Framework v2.2.9 + template v2.3.6
- Simplified display (removed complex timing)
- Standard power monitoring channels

### Smart Energy Display
- Auto-scaling: Wh → kWh → MWh → GWh
- Power factor percentage
- Socket state with visual indicators

## Test Scenarios
```bash
LwWS52xTestUI2 normal      # 240V, 100W, ON, 4.7kWh
LwWS52xTestUI2 low         # 90V, 25W, OFF, low power
LwWS52xTestUI2 high        # 500V, 1000W, ON, high power
LwWS52xTestUI2 alert       # Power events
LwWS52xTestUI2 config      # Configuration display
```

## Changelog
- v2.0.0 (2025-08-25): Complete MAP-based regeneration - clean implementation with framework v2.2.9
