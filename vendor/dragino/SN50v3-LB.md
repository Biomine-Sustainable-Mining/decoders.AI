# Dragino SN50v3-LB LoRaWAN Decoder

## Device Information
- **Manufacturer**: Dragino
- **Model**: SN50v3-LB/LS
- **Type**: Generic LoRaWAN Sensor Node
- **LoRaWAN Version**: 1.0.3
- **Regions**: CN470, EU433, KR920, US915, EU868, AS923, AU915, IN865
- **Official Reference**: https://wiki.dragino.com/xwiki/bin/view/Main/User%20Manual%20for%20LoRaWAN%20End%20Nodes/SN50v3-LB/

## Implementation Details
- **Driver Version**: 1.3.0
- **Generated**: 2025-09-02
- **Coverage**: 36/36 uplinks implemented, 12/12 downlinks implemented
- **Framework**: v2.5.0
- **Template**: v2.5.0

## Expected UI Examples

### Example 1: Normal Default Mode
```
┌─────────────────────────────────────┐
│ 🏠 SN50v3LB-slot2  Dragino SN50v3-LB│
│ 🔋 3.3V 📶 -85dBm ⏱️ 2m ago        │
├─────────────────────────────────────┤
│ 🔋 3.3V 🔧 Default 🌡️ 27.0°C      │
│ 💧 65% 📊 543                      │
└─────────────────────────────────────┘
```

### Example 2: Distance Mode
```
┌─────────────────────────────────────┐
│ 🏠 SN50v3LB-slot2  Dragino SN50v3-LB│
│ 🔋 3.3V 📶 -82dBm ⏱️ 1m ago        │
├─────────────────────────────────────┤
│ 🔋 3.3V 📏 Distance 🌡️ 26.8°C     │
│ 📏 3.0m 📊 420                     │
└─────────────────────────────────────┘
```

### Example 3: Weight Mode
```
┌─────────────────────────────────────┐
│ 🏠 SN50v3LB-slot2  Dragino SN50v3-LB│
│ 🔋 3.2V 📶 -78dBm ⏱️ 30s ago       │
├─────────────────────────────────────┤
│ 🔋 3.2V ⚖️ Weight 🌡️ 25.2°C       │
│ ⚖️ 5.0kg 📊 380                    │
└─────────────────────────────────────┘
```

## Command Reference

### Test Commands (slot = driver slot 1-16):
| Command | Description | Usage | Example |
|---------|-------------|-------|---------|
| LwSN50v3LBTestUI<slot> | UI scenarios | `<scenario>` | `LwSN50v3LBTestUI2 normal` |

### Control Commands (slot = driver slot 1-16):
| Command | Description | Usage | Downlink Hex |
|---------|-------------|-------|---------------|
| LwSN50v3LBInterval<slot> | Set interval | `<seconds>` | `01XXXXXX` |
| LwSN50v3LBStatus<slot> | Request status | (no params) | `2601` |
| LwSN50v3LBMode<slot> | Set working mode | `<1-12 or name>` | `0AXX` |
| LwSN50v3LBInterrupt<slot> | Configure interrupt | `<pin>,<mode>[,<delay_ms>]` | `0600XXXX[XXXX]` |
| LwSN50v3LBOutput<slot> | 5V output duration | `<ms>` | `07XXXX` |
| LwSN50v3LBWeight<slot> | Weight calibration | `zero` or `<factor>` | `08XX[XXXXXX]` |
| LwSN50v3LBSetCount<slot> | Set count value | `<1-2>,<value>` | `09XXXXXXXXXX` |

## Usage Examples

### Driver in Slot 2:
```bash
# Test realistic scenarios 
LwSN50v3LBTestUI2 normal      # Normal default mode
LwSN50v3LBTestUI2 distance    # Distance measurement mode
LwSN50v3LBTestUI2 weight      # Weight measurement mode
LwSN50v3LBTestUI2 counting    # Counting mode

# Control device
LwSN50v3LBInterval2 600       # Set 10-minute interval
LwSN50v3LBMode2 2             # Set distance mode
LwSN50v3LBMode2 WEIGHT        # Set weight mode
LwSN50v3LBInterrupt2 0,1,500  # Pin 0, rising+falling edge, 500ms delay
```

## Working Modes

| Mode | ID | Description | Payload Size |
|------|----|-------------|--------------|
| Default | 1 | DS18B20 + ADC + SHT20/31 | 11 bytes |
| Distance | 2 | LIDAR/Ultrasonic distance | 11 bytes |
| 3ADC+I2C | 3 | Three ADC channels + I2C sensor | 12 bytes |
| 3DS18B20 | 4 | Three DS18B20 temperature sensors | 11 bytes |
| Weight | 5 | HX711 load cell interface | 11 bytes |
| Counting | 6 | Digital pulse counting | 11 bytes |
| 3Interrupt | 7 | Three interrupt pins | 9 bytes |
| 3ADC+DS18B20 | 8 | Three ADC + one DS18B20 | 11 bytes |
| 3DS18B20+2Count | 9 | Three DS18B20 + two counters | 17 bytes |
| PWM | 10 | PWM input/output | 11 bytes |
| TEMP117 | 11 | High precision TEMP117 | 11 bytes |
| Count+SHT31 | 12 | Counting + SHT31 sensor | 11 bytes |

## Uplink Coverage Matrix
| Port | Type | Description | Status | Size |
|------|------|-------------|--------|------|
| 2 | MOD=1 | Default mode | ✅ Implemented | 11 bytes |
| 2 | MOD=2 | Distance mode | ✅ Implemented | 11 bytes |
| 2 | MOD=3 | 3 ADC + I2C | ✅ Implemented | 12 bytes |
| 2 | MOD=4 | 3 DS18B20 | ✅ Implemented | 11 bytes |
| 2 | MOD=5 | Weight (HX711) | ✅ Implemented | 11 bytes |
| 2 | MOD=6 | Counting | ✅ Implemented | 11 bytes |
| 2 | MOD=7 | 3 Interrupt | ✅ Implemented | 9 bytes |
| 2 | MOD=8 | 3 ADC + DS18B20 | ✅ Implemented | 11 bytes |
| 2 | MOD=9 | 3 DS18B20 + 2 Count | ✅ Implemented | 17 bytes |
| 2 | MOD=10 | PWM mode | ✅ Implemented | 11 bytes |
| 2 | MOD=11 | TEMP117 | ✅ Implemented | 11 bytes |
| 2 | MOD=12 | Count + SHT31 | ✅ Implemented | 11 bytes |
| 5 | Status | Device information | ✅ Implemented | 7 bytes |

## Decoded Parameters
| Parameter | Unit | Range | Notes |
|-----------|------|-------|-------|
| battery_v | V | 2.5 to 3.6 | Lithium battery voltage |
| ds18b20_temp | °C | -40 to 85 | DS18B20 temperature sensor |
| sht31_temp | °C | -40 to 85 | SHT31 temperature sensor |
| sht31_humidity | % | 0 to 100 | SHT31 humidity sensor |
| temp117_temp | °C | -40 to 85 | High precision TEMP117 |
| adc_value | raw | 0 to 4095 | ADC reading (PA4 pin) |
| distance | mm | 240 to 6000 | LIDAR/ultrasonic distance |
| weight | g | 0 to 4294967295 | HX711 weight measurement |
| count_value | count | 0 to 4294967295 | Digital pulse count |
| firmware_version | string | x.x.x | Firmware version |
| frequency_band | string | EU868, US915, etc | LoRaWAN frequency band |
| working_mode | string | Default, Distance, etc | Current operation mode |
| RSSI | dBm | -120 to 0 | LoRaWAN signal strength |

## Changelog
```
- v1.3.0 (2025-09-02): Template v2.5.0 upgrade with TestUI payload verification
- v1.2.0 (2025-09-02): Framework v2.4.1 upgrade with critical Berry keys() fixes  
- v1.1.0 (2025-08-20): Enhanced display with working mode support
- v1.0.0 (2025-08-20): Initial generation from MAP specification
```