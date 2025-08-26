# Dragino LHT65 LoRaWAN Driver Documentation

## Device Information
- **Manufacturer**: Dragino
- **Model**: LHT65
- **Type**: Temperature & Humidity Sensor with 9 External Sensor Types
- **Framework**: v2.2.9 + Template v2.3.6
- **Version**: 1.1.0

## Features
- Built-in temperature and humidity
- 9 external sensor types (E1-E9)
- Battery monitoring with status
- External sensor connection detection
- Datalog and timestamp support

## Command Reference  
| Command | Description |
|---------|-------------|
| LwLHT65TestUI<slot> | Test scenarios |
| LwLHT65SetInterval<slot> | Set transmit interval |
| LwLHT65ExtSensor<slot> | Configure external sensor |
| LwLHT65Poll<slot> | Poll sensor data |

## Test Scenarios
- normal, ext_temp, illumination, adc, counting, interrupt, low_battery, disconnected
