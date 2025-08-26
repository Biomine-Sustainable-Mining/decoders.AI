# AI-Generated LoRaWAN Driver List

## Overview
This document maintains a comprehensive list of all AI-generated drivers for the LwDecode framework with version tracking and generation dates.

## Versioning Strategy
- v<major>.<minor>.<fix>
  - **major**: Increased only when official sensor specs change from vendor (starts at 1)
  - **minor**: Increased only when fresh regeneration is requested (resets to 0 on major change)
  - **fix**: Increased on all other cases (resets to 0 on minor change)
- All publish dates must be greater than 2025-08-13 (framework start date)

## Driver Registry

### Dragino
| Model | Version | Date | Channels | Model Version | Prompt Ver | Description |
|-------|---------|------|----------|---------------|------------|-------------|
| [D2x](vendor/dragino/D2x.md) | [1.0.0](vendor/dragino/D2x.be) | 2025-08-20 | 15/15 | D20/D20S/D22/D23-LB/LS | [v2.2.8](vendor/dragino/D2x-REPORT.md) | [Multi-probe temperature sensor series](vendor/dragino/D2x-REQ.md) |
| [DDS75-LB](vendor/dragino/DDS75-LB.md) | [2.0.0](vendor/dragino/DDS75-LB.be) | 2025-08-26 | 8/8 | DDS75-LB/LS | [v2.3.6](vendor/dragino/DDS75-LB-REPORT.md) | [Ultrasonic distance detection sensor](vendor/dragino/DDS75-LB-REQ.md) |
| [LDS02](vendor/dragino/LDS02.md) | [2.0.0](vendor/dragino/LDS02.be) | 2025-08-26 | 8/8 | LDS02 | [v2.3.6](vendor/dragino/LDS02-REPORT.md) | [Magnetic door sensor with event counting](vendor/dragino/LDS02-REQ.md) |
| [LHT52](vendor/dragino/LHT52.md) | [2.0.0](vendor/dragino/LHT52.be) | 2025-08-26 | 16/16 | LHT52 | [v2.3.6](vendor/dragino/LHT52-REPORT.md) | [Temperature & humidity sensor with datalog & alarm features](vendor/dragino/LHT52-REQ.md) |
| [LHT65](vendor/dragino/LHT65.md) | [1.0.0](vendor/dragino/LHT65.be) | 2025-08-16 | 18/18 | LHT65 | [v2.3.0](vendor/dragino/LHT65-REPORT.md) | [Temperature & humidity sensor with 9 external sensor types](vendor/dragino/LHT65-REQ.md) |
| [PS-LB](vendor/dragino/PS-LB.md) | [2.0.0](vendor/dragino/PS-LB.be) | 2025-08-26 | 13/13 | PS-LB/LS | [v2.3.6](vendor/dragino/PS-LB-REPORT.md) | [Pressure/water level sensor with probe detection](vendor/dragino/PS-LB-REQ.md) |
| [SE01-LB](vendor/dragino/SE01-LB.md) | [1.0.0](vendor/dragino/SE01-LB.be) | 2025-08-20 | 28/28 | SE01-LB/LS | [v2.3.3](vendor/dragino/SE01-LB-REPORT.md) | [Soil moisture & EC sensor with multi-mode support](vendor/dragino/SE01-LB-REQ.md) |
| [SN50v3-LB](vendor/dragino/SN50v3-LB.md) | [1.0.0](vendor/dragino/SN50v3-LB.be) | 2025-08-20 | 36/36 | SN50v3-LB/LS | [v2.3.3](vendor/dragino/SN50v3-LB-REPORT.md) | [Generic LoRaWAN sensor node with 12 working modes](vendor/dragino/SN50v3-LB-REQ.md) |

### Milesight
| Model | Version | Date | Channels | Model Version | Prompt Ver | Description |
|-------|---------|------|----------|---------------|------------|-------------|
| [AM300](vendor/milesight/AM300.md) | [1.2.0](vendor/milesight/AM300.be) | 2025-08-26 | 20/20 | AM300(L) Series | [v2.3.6](vendor/milesight/AM300-REPORT.md) | [9-in-1 indoor air quality monitor with WELL certification](vendor/milesight/AM300-REQ.md) |
| [WS101](vendor/milesight/WS101.md) | [2.0.0](vendor/milesight/WS101.be) | 2025-08-26 | 8/8 | WS101 | [v2.3.6](vendor/milesight/WS101-REPORT.md) | [Smart button with multiple press types](vendor/milesight/WS101-REQ.md) |
| [WS202](vendor/milesight/WS202.md) | [1.2.0](vendor/milesight/WS202.be) | 2025-08-20 | 9/9 | WS202 | [v2.2.6](vendor/milesight/WS202-REPORT.md) | [PIR & Light sensor for motion and illuminance detection](vendor/milesight/WS202-REQ.md) |
| [WS301](vendor/milesight/WS301.md) | [1.3.0](vendor/milesight/WS301.be) | 2025-08-20 | 10/10 | WS301 | [v2.2.6](vendor/milesight/WS301-REPORT.md) | [Magnetic door/window sensor](vendor/milesight/WS301-REQ.md) |
| [WS523](vendor/milesight/WS523.md) | [3.0.0](vendor/milesight/WS523.be) | 2025-08-26 | 33/33 | WS523 | [v2.3.6](vendor/milesight/WS523-REPORT.md) | [Portable smart socket with power monitoring](vendor/milesight/WS523-REQ.md) |
| [WS52x](vendor/milesight/WS52x.md) | [2.0.0](vendor/milesight/WS52x.be) | 2025-08-25 | 25/25 | WS52x Series | [v2.3.6](vendor/milesight/WS52x-REPORT.md) | [Smart socket series with comprehensive power monitoring](vendor/milesight/WS52x-REQ.md) |

### Mutelcor
| Model | Version | Date | Channels | Model Version | Prompt Ver | Description |
|-------|---------|------|----------|---------------|------------|-------------|
| [MTC-AQ01](vendor/mutelcor/MTC-AQ01.md) | [1.0.0](vendor/mutelcor/MTC-AQ01.be) | 2025-08-20 | 12/12 | MTC-AQ01/02/03 | [v2.3.3](vendor/mutelcor/MTC-AQ01-REPORT.md) | [Air quality sensor with temperature, humidity & pressure](vendor/mutelcor/MTC-AQ01-REQ.md) |

### Micropelt
| Model | Version | Date | Channels | Model Version | Prompt Ver | Description |
|-------|---------|------|----------|---------------|------------|-------------|
| [MLR003](vendor/micropelt/MLR003.md) | [1.0.0](vendor/micropelt/MLR003.be) | 2025-08-20 | 52/52 | MLR003 | [v2.3.3](vendor/micropelt/MLR003-REPORT.md) | [Thermostatic radiator valve with energy harvesting](vendor/micropelt/MLR003-REQ.md) |

### Watteco
| Model | Version | Date | Channels | Model Version | Prompt Ver | Description |
|-------|---------|------|----------|---------------|------------|-------------|
| [BOB-ASSISTANT](vendor/watteco/BOB-ASSISTANT.md) | [1.0.0](vendor/watteco/BOB-ASSISTANT.be) | 2025-08-20 | 68/68 | Bob Assistant | [v2.3.3](vendor/watteco/BOB-ASSISTANT-REPORT.md) | [Vibration sensor with ML anomaly detection & FFT](vendor/watteco/BOB-ASSISTANT-REQ.md) |

## Coverage Statistics

### By Vendor
- **Dragino**: 8 drivers, 142 total channels
- **Milesight**: 6 drivers, 104 total channels
- **Mutelcor**: 1 driver, 12 total channels
- **Micropelt**: 1 driver, 52 total channels
- **Watteco**: 1 driver, 68 total channels

### Total
- **Drivers**: 17
- **Channels**: 378
- **Coverage**: 100% (all documented channels implemented)

### File Statistics
- **Driver Files (.be)**: 17
- **Documentation (.md)**: 17
- **MAP Cache Files**: 16 (Dragino: 8, Milesight: 5, Mutelcor: 1, Micropelt: 1, Watteco: 1)
- **Report Files**: 14 (Dragino: 7, Milesight: 4, Mutelcor: 1, Micropelt: 1, Watteco: 1)
- **Framework Files**: 16
- **Total Project Files**: 80

### Framework Compliance Verification
- ✅ **Command Naming**: All commands use "Lw[MODEL][Function]" pattern
- ✅ **Global Storage**: All drivers implement global node persistence
- ✅ **Error Handling**: All drivers use try/catch blocks
- ✅ **Header Integration**: All drivers call lwdecode.header()
- ✅ **Test Commands**: All drivers register test/management commands
- ✅ **Hash Check**: All drivers implement duplicate detection
- ✅ **Memory Optimization**: All drivers follow ESP32 constraints

### Framework Upgrade Status
#### Current Framework: v2.2.9 | Current Template: v2.3.6

**🟢 Fully Current (Framework v2.2.9 + Template v2.3.6)**: 9 drivers (53%)
- AM300 v1.2.0, WS52x v2.0.0, WS101 v2.0.0, WS523 v3.0.0, DDS75-LB v2.0.0, LDS02 v2.0.0, LHT52 v2.0.0, PS-LB v2.0.0

**🟡 Needs Framework + Template Upgrade**: 4 drivers (23%)
- D2x (v2.2.8), LHT65 (v2.3.0), WS202 (v2.2.6), WS301 (v2.2.6)

**🟠 Needs Template-Only Upgrade**: 5 drivers (29%)
- SE01-LB, SN50v3-LB, MTC-AQ01, MLR003, BOB-ASSISTANT (all v2.3.3)

**🔴 Major Upgrades Complete**: 0 drivers (0%)
- ✅ All major upgrades completed!





## Technical Standards

All drivers follow these standards:
- Berry 0.1.10+ syntax compliance
- Tasmota 13.0+ API compatibility
- LwSensorFormatter_cls() framework usage
- No Berry reserved words as variables
- Emoji-first display format
- Memory optimization (<500 lines per driver)
- Complete channel coverage (100%)
- Global node storage for multi-device support
- Test command registration with auto-cleanup
- Node management commands (stats, clear)

## Driver Features

### Core Features (All Drivers)
- ✅ Complete uplink decoding (100% coverage)
- ✅ Global persistent node storage
- ✅ Recovery after driver reload
- ✅ Device trend tracking (battery, power, energy)
- ✅ Device reset detection
- ✅ Last seen timestamp tracking
- ✅ Test command with port-specific payloads
- ✅ Node statistics and management

### Display Features
- ✅ Emoji-first single-line format
- ✅ Dynamic value display (only show when relevant)
- ✅ Age indicator for stale data (>1 hour)
- ✅ Status indicators for alerts/errors
- ✅ Compact notation for large numbers

## Validation Checklist

Each driver has been validated for:
- ✅ No use of Berry reserved words ('type', 'class', etc.)
- ✅ Correct LwSensorFormatter_cls() usage
- ✅ Complete uplink decoding coverage
- ✅ Proper error handling with try/except blocks
- ✅ Memory-efficient implementation
- ✅ Consistent emoji usage per reference guide
- ✅ Global node storage initialization
- ✅ Test command registration with cleanup
- ✅ Documentation with test examples for ALL uplink types

## Changelog

### 2025-08-26: Major Framework Upgrade Session - 6 Critical Drivers Upgraded (COMPLETE)
- **MAJOR UPGRADE COMPLETION**: Upgraded 6 critical drivers from v2.1.x to Framework v2.2.9 + Template v2.3.6
- **Progress**: 9/17 drivers now fully current (53% completion rate)
- **ACHIEVEMENT**: 100% of major upgrades completed - no more v2.1.x drivers remaining!
- **Remaining**: Only framework/template upgrades needed (9 drivers total)

#### Completed Major Upgrades:
- **DDS75-LB v2.0.0**: Upgraded from v2.1.8 → Framework v2.2.9 + Template v2.3.6
  - Enhanced distance sensor with ultrasonic probe detection and error handling
  - Framework v2.2.9 compatibility: RSSI/FPort uppercase, simulated parameter support
  - Complete downlink coverage: interval, interrupt modes, delta detection, status polling
  - Global node storage with distance trends and interrupt event tracking
  - Comprehensive test scenarios: normal/close/interrupt/no-sensor/invalid readings

- **LDS02 v2.0.0**: Upgraded from v2.1.8 → Framework v2.2.9 + Template v2.3.6
  - Enhanced magnetic door sensor with comprehensive event tracking capabilities
  - Framework v2.2.9 compatibility: RSSI/FPort uppercase, simulated parameter support
  - Complete downlink coverage: interval, EDC mode, reset, confirmed mode, alarm control
  - Global node storage with door state changes and alarm event tracking
  - Comprehensive test scenarios: normal/EDC modes, door states, alarm conditions, counting

- **LHT52 v2.0.0**: Upgraded from v2.1.8 → Framework v2.2.9 + Template v2.3.6
  - Enhanced temperature/humidity sensor with datalog and external sensor support
  - Framework v2.2.9 compatibility: RSSI/FPort uppercase, simulated parameter support
  - Complete downlink coverage: interval, reset, confirmation, sub-band, ADR, alarm modes
  - Multi-port support: device status (5), real-time data (2), datalog (3), probe ID (4)
  - Global node storage with temperature, humidity, and battery trend tracking
  - External DS18B20 probe support with disconnect detection and ID reporting

- **PS-LB v2.0.0**: Upgraded from v2.1.10 → Framework v2.2.9 + Template v2.3.6
  - Enhanced pressure/water level sensor with advanced probe type support
  - Framework v2.2.9 compatibility: RSSI/FPort uppercase, simulated parameter support
  - Complete downlink coverage: interval, interrupt, output control, probe config, ROC mode
  - Multi-port support: device status (5), sensor data (2), multi-collection (7), datalog (3)
  - Advanced probe decoding: water depth, pressure, differential measurements with ROC detection
  - Global node storage with pressure/depth trends and ROC event tracking

- **WS101 v2.0.0**: Upgraded from v2.1.8 → Framework v2.2.9 + Template v2.3.6
  - Enhanced smart button with comprehensive press type detection and device management
  - Framework v2.2.9 compatibility: RSSI/FPort uppercase, simulated parameter support
  - Complete downlink coverage: reporting interval, reboot, LED control, double-press mode, buzzer
  - Button event tracking: short press, long press, double press with individual counters
  - Global node storage with press statistics, battery trends, and power-on event tracking
  - Enhanced display with press-specific emojis and device information

- **WS523 v3.0.0**: Upgraded from v2.1.8 → Framework v2.2.9 + Template v2.3.6 (FINAL MAJOR UPGRADE)
  - Enhanced portable smart socket with comprehensive power monitoring and protection
  - Framework v2.2.9 compatibility: RSSI/FPort uppercase, simulated parameter support
  - Complete downlink coverage: socket control, interval, reboot, delay tasks, OC protection, button lock
  - Advanced power monitoring: voltage, current, power, energy, power factor with smart scaling
  - Overcurrent protection and alarm configuration with threshold management
  - Global node storage with energy/power trends, socket state changes, and event tracking
  - Power outage detection and device reset event management

#### Technical Improvements Applied:
- ✅ **Framework v2.2.9 Integration**: Uppercase RSSI/FPort, simulated parameter handling
- ✅ **Template v2.3.6 Patterns**: Enhanced error handling with try/catch blocks
- ✅ **Global Node Storage**: Persistent data across driver reloads with trend tracking
- ✅ **Display Enhancement**: Improved emoji formatting and multi-line conditional content
- ✅ **Memory Optimization**: ESP32-optimized patterns with efficient data structures
- ✅ **Test Scenario Coverage**: Realistic payloads for all device states and configurations

### 2025-08-26: AM300 v1.2.0 Framework v2.2.9 Complete Regeneration from URL
[Previous changelog entries continue unchanged...]

---
*Last Updated: 2025-08-26 - Major Framework Upgrade Session: 5 drivers upgraded to v2.2.9*

---

*Author: [ZioFabry](https://github.com/ZioFabry)*
