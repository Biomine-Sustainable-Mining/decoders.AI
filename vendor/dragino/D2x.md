# Dragino D2x LoRaWAN Driver Documentation

## Device Information
- **Manufacturer**: Dragino
- **Model**: D2x Series (D20/D22/D23-LB/LS)
- **Type**: Multi-probe Temperature Sensor
- **Coverage**: 15/15 uplinks, 8/8 downlinks
- **Framework**: v2.4.1 + Template v2.4.1

## Driver Version
- **Version**: 1.2.0 (2025-09-02)
- **Critical Fix**: Berry keys() iterator bug resolved
- **Framework Upgrade**: Enhanced error handling and data recovery

## Command Reference
| Command | Description | Usage |
|---------|-------------|-------|
| LwD2xTestUI<slot> | Test scenarios | `normal/multi/alarm/cold/status/datalog` |
| LwD2xSetInterval<slot> | Set interval | `<seconds>` (30-16777215) |
| LwD2xSetAlarmAll<slot> | Set alarm for all probes | `<min_temp>,<max_temp>` |
| LwD2xSetAlarmProbe<slot> | Set alarm for probe | `<min>,<max>,<probe>` |

## Features
- Multi-probe temperature sensing (Red/White, White, Black)
- Temperature alarms with configurable thresholds
- Datalog functionality with timestamps
- Battery monitoring and PA8 level detection
- Enhanced data recovery after driver reload
