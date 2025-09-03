# AI-Generated LoRaWAN Driver List

## Overview
This document maintains a comprehensive list of all AI-generated drivers for the LwDecode framework with version tracking and generation dates.

## Versioning Strategy
- v`<major>`.`<minor>`.`<fix>`
  - **major**: Increased only when official sensor specs change from vendor (starts at 1)
  - **minor**: Increased only when fresh regeneration is requested (resets to 0 on major change)
  - **fix**: Increased on all other cases (resets to 0 on minor change)
- All publish dates must be greater than 2025-08-13 (framework start date)

## Driver Registry

### Dragino
| Model | Version | Date | Channels | Model Version | Prompt Ver | Description |
|-------|---------|------|----------|---------------|------------|-------------|
| [D2x](vendor/dragino/D2x.md) | [2.0.0](vendor/dragino/D2x.be) | 2025-09-03 | 15/15 | D20/D20S/D22/D23-LB/LS | [v2.5.0](vendor/dragino/D2x-REPORT.md) | [Multi-probe temperature sensor series](vendor/dragino/D2x-REQ.md) |
| [DDS75-LB](vendor/dragino/DDS75-LB.md) | [2.0.0](vendor/dragino/DDS75-LB.be) | 2025-09-03 | 8/8 | DDS75-LB/LS | [v2.5.0](vendor/dragino/DDS75-LB-REPORT.md) | [Ultrasonic distance detection sensor](vendor/dragino/DDS75-LB-REQ.md) |
| [LDS02](vendor/dragino/LDS02.md) | [2.0.0](vendor/dragino/LDS02.be) | 2025-09-03 | 8/8 | LDS02 | [v2.5.0](vendor/dragino/LDS02-REPORT.md) | [Magnetic door sensor with event counting](vendor/dragino/LDS02-REQ.md) |
| [LHT52](vendor/dragino/LHT52.md) | [2.0.0](vendor/dragino/LHT52.be) | 2025-09-03 | 16/16 | LHT52 | [v2.5.0](vendor/dragino/LHT52-REPORT.md) | [Temperature & humidity sensor with datalog & alarm features](vendor/dragino/LHT52-REQ.md) |
| [LHT65](vendor/dragino/LHT65.md) | [2.0.0](vendor/dragino/LHT65.be) | 2025-09-03 | 18/18 | LHT65 | [v2.5.0](vendor/dragino/LHT65-REPORT.md) | [Temperature & humidity sensor with 9 external sensor types](vendor/dragino/LHT65-REQ.md) |
| [PS-LB](vendor/dragino/PS-LB.md) | [3.0.0](vendor/dragino/PS-LB.be) | 2025-09-03 | 13/13 | PS-LB/LS | [v2.5.0](vendor/dragino/PS-LB-REPORT.md) | [Pressure/water level sensor with probe detection](vendor/dragino/PS-LB-REQ.md) |
| [SE01-LB](vendor/dragino/SE01-LB.md) | [2.0.0](vendor/dragino/SE01-LB.be) | 2025-09-03 | 28/28 | SE01-LB/LS | [v2.5.0](vendor/dragino/SE01-LB-REPORT.md) | [Soil moisture & EC sensor with multi-mode support](vendor/dragino/SE01-LB-REQ.md) |
| [SN50v3-LB](vendor/dragino/SN50v3-LB.md) | [1.3.0](vendor/dragino/SN50v3-LB.be) | 2025-09-02 | 36/36 | SN50v3-LB/LS | [v2.5.0](vendor/dragino/SN50v3-LB-REPORT.md) | [Generic LoRaWAN sensor node with 12 working modes](vendor/dragino/SN50v3-LB-REQ.md) |

### Milesight
| Model | Version | Date | Channels | Model Version | Prompt Ver | Description |
|-------|---------|------|----------|---------------|------------|-------------|
| [AM300](vendor/milesight/AM300.md) | [1.4.0](vendor/milesight/AM300.be) | 2025-09-02 | 20/20 | AM300(L) Series | [v2.5.0](vendor/milesight/AM300-REPORT.md) | [9-in-1 indoor air quality monitor with WELL certification](vendor/milesight/AM300-REQ.md) |
| [AM308L](vendor/milesight/AM308L.md) | [1.2.0](vendor/milesight/AM308L.be) | 2025-09-02 | 22/22 | AM308L | [v2.5.0](vendor/milesight/AM308L-REPORT.md) | [Environmental monitoring sensor with CO2, TVOC, PM2.5/10, temperature, humidity, pressure, PIR, and light](vendor/milesight/AM308L-REQ.md) |
| [VS321](vendor/milesight/VS321.md) | [2.0.0](vendor/milesight/VS321.be) | 2025-09-03 | 17/17 | VS321 | [v2.5.0](vendor/milesight/VS321-REPORT.md) | [AI Occupancy Sensor with people counting & desk detection](vendor/milesight/VS321-REQ.md) |
| [WS101](vendor/milesight/WS101.md) | [3.0.0](vendor/milesight/WS101.be) | 2025-09-03 | 8/8 | WS101 | [v2.5.0](vendor/milesight/WS101-REPORT.md) | [Smart button with multiple press types](vendor/milesight/WS101-REQ.md) |
| [WS202](vendor/milesight/WS202.md) | [2.0.0](vendor/milesight/WS202.be) | 2025-09-03 | 9/9 | WS202 | [v2.5.0](vendor/milesight/WS202-REPORT.md) | [PIR & Light sensor for motion and illuminance detection](vendor/milesight/WS202-REQ.md) |
| [WS301](vendor/milesight/WS301.md) | [2.0.0](vendor/milesight/WS301.be) | 2025-09-03 | 10/10 | WS301 | [v2.5.0](vendor/milesight/WS301-REPORT.md) | [Magnetic door/window sensor](vendor/milesight/WS301-REQ.md) |
| [WS523](vendor/milesight/WS523.md) | [5.0.0](vendor/milesight/WS523.be) | 2025-09-03 | 33/33 | WS523 | [v2.5.0](vendor/milesight/WS523-REPORT.md) | [Portable smart socket with power monitoring](vendor/milesight/WS523-REQ.md) |
| [WS52x](vendor/milesight/WS52x.md) | [2.0.0](vendor/milesight/WS52x.be) | 2025-09-03 | 25/25 | WS52x Series | [v2.5.0](vendor/milesight/WS52x-REPORT.md) | [Smart socket with slideshow support & enhanced error handling](vendor/milesight/WS52x-REQ.md) |

### Mutelcor
| Model | Version | Date | Channels | Model Version | Prompt Ver | Description |
|-------|---------|------|----------|---------------|------------|-------------|
| [MTC-AQ01](vendor/mutelcor/MTC-AQ01.md) | [2.0.0](vendor/mutelcor/MTC-AQ01.be) | 2025-09-03 | 15/15 | MTC-AQ01/02/03 | [v2.5.0](vendor/mutelcor/MTC-AQ01-REPORT.md) | [Air quality sensor with temperature, humidity & pressure](vendor/mutelcor/MTC-AQ01-REQ.md) |

### Micropelt
| Model | Version | Date | Channels | Model Version | Prompt Ver | Description |
|-------|---------|------|----------|---------------|------------|-------------|
| [MLR003](vendor/micropelt/MLR003.md) | [1.2.0](vendor/micropelt/MLR003.be) | 2025-09-02 | 52/52 | MLR003 | [v2.4.1](vendor/micropelt/MLR003-REPORT.md) | [Thermostatic radiator valve with energy harvesting](vendor/micropelt/MLR003-REQ.md) |

### Watteco
| Model | Version | Date | Channels | Model Version | Prompt Ver | Description |
|-------|---------|------|----------|---------------|------------|-------------|
| [BOB-ASSISTANT](vendor/watteco/BOB-ASSISTANT.md) | [2.0.0](vendor/watteco/BOB-ASSISTANT.be) | 2025-09-03 | 68/68 | Bob Assistant | [v2.5.0](vendor/watteco/BOB-ASSISTANT-REPORT.md) | [Vibration sensor with ML anomaly detection & FFT](vendor/watteco/BOB-ASSISTANT-REQ.md) |

## Coverage Statistics

### By Vendor
- **Dragino**: 8 drivers, 142 total channels
- **Milesight**: 8 drivers, 144 total channels
- **Mutelcor**: 1 driver, 12 total channels
- **Micropelt**: 1 driver, 52 total channels
- **Watteco**: 1 driver, 68 total channels

### Total
- **Drivers**: 19
- **Channels**: 418
- **Coverage**: 100% (all documented channels implemented)

### File Statistics
- **Driver Files (.be)**: 19
- **Documentation (.md)**: 19
- **MAP Cache Files**: 18 (Dragino: 8, Milesight: 7, Mutelcor: 1, Micropelt: 1, Watteco: 1)
- **Report Files**: 19 (Dragino: 8, Milesight: 8, Mutelcor: 1, Micropelt: 1, Watteco: 1)
- **Generation Request Files**: 19
- **Framework Files**: 16
- **Total Project Files**: 93

### Framework Compliance Verification
- ✅ **Command Naming**: All commands use "Lw[MODEL][Function]" pattern
- ✅ **Global Storage**: All drivers implement global node persistence
- ✅ **Error Handling**: All drivers use try/catch blocks
- ✅ **Header Integration**: All drivers call lwdecode.header()
- ✅ **Test Commands**: All drivers register test/management commands
- ✅ **Hash Check**: All drivers implement duplicate detection
- ✅ **Memory Optimization**: All drivers follow ESP32 constraints

### Framework Upgrade Status
#### Current Framework: v2.3.0 | Current Template: v2.4.1

**🟢 ALL DRIVERS CURRENT (Framework v2.4.1 + Template v2.4.1)**: 19 drivers
- **Dragino (8)**: D2x v1.2.0, DDS75-LB v2.1.0, LDS02 v2.1.0, LHT52 v2.1.0, LHT65 v1.2.0, PS-LB v2.1.0, SE01-LB v1.2.0, SN50v3-LB v1.2.0
- **Milesight (8)**: VS321 v1.0.0, AM300 v1.3.0, AM308L v1.1.0, WS101 v2.1.0, WS202 v1.4.0, WS301 v1.5.0, WS523 v3.1.0, WS52x v1.7.0
- **Mutelcor (1)**: MTC-AQ01 v1.3.0
- **Micropelt (1)**: MLR003 v1.2.0
- **Watteco (1)**: BOB-ASSISTANT v1.1.0

**🟡 Framework v2.2.9 + Template v2.3.6**: 0 drivers
- ✅ ALL DRIVERS NOW CURRENT

**🔴 Major Upgrades Needed**: 0 drivers (0%)

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
- ✅ Enhanced error handling with try/catch blocks
- ✅ Display error protection
- ✅ RSSI/FPort uppercase parameter support
- ✅ Simulated payload indicator support

### Display Features
- ✅ Emoji-first single-line format
- ✅ Dynamic value display (only show when relevant)
- ✅ Age indicator for stale data (>1 hour)
- ✅ Status indicators for alerts/errors
- ✅ Compact notation for large numbers
- ✅ Multi-line support for complex sensors
- ✅ Error recovery patterns after driver reload

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
- ✅ Enhanced display error protection
- ✅ Framework compatibility
- ✅ Latest template patterns

## Changelog

### 2025-09-02: Framework Upgrade COMPLETE - Critical Berry Keys() Bug Fixes
- **FRAMEWORK UPGRADE COMPLETE**: ALL 19 drivers now at v2.4.1
- **CRITICAL FIXES**: Berry keys() iterator bug ELIMINATED across all drivers
- **Bug Eliminated**: type_error after lwreload prevented with safe iteration patterns
- **Patterns Fixed**: Explicit key arrays, safe iteration flags, static scenario lists
- **Data Recovery**: Enhanced lwreload recovery prevents UI crashes across ecosystem
- **Total Drivers**: 19 (100% at latest framework)
- **Total Channels**: 418 (maintained)
- **Success Rate**: 100% (critical stability fixes applied ecosystem-wide)

### Previous Major Milestones:
- **2025-08-26**: Framework maintenance completed on 18 drivers
- **2025-08-26**: AM308L v1.0.0 - Environmental monitoring sensor
- **2025-08-26**: Template v2.3.6 upgrade to final 5 drivers
- **2025-08-26**: Framework v2.2.9 rollout to 13 drivers

### Achievement Summary:
- **Total Drivers**: 19 (across 5 vendors)
- **Total Channels**: 418 (100% coverage)
- **Latest Framework**: v2.4.1 (ALL drivers)
- **Success Rate**: 100% (all drivers functional)
- **Error Handling**: Enhanced across all drivers
- **Multi-Node Support**: Complete global storage patterns
- **Test Coverage**: Comprehensive scenarios for all drivers
- **Berry Keys() Bug**: ELIMINATED across entire ecosystem

---
*Last Updated: 2025-09-02 - Framework Upgrade COMPLETE: All 19 drivers at v2.4.1*

---

*Author: [ZioFabry](https://github.com/ZioFabry)*