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
| [D2x](vendor/dragino/D2x.md) | [1.1.0](vendor/dragino/D2x.be) | 2025-08-26 | 15/15 | D20/D20S/D22/D23-LB/LS | [v2.3.6](vendor/dragino/D2x-REPORT.md) | [Multi-probe temperature sensor series](vendor/dragino/D2x-REQ.md) |
| [DDS75-LB](vendor/dragino/DDS75-LB.md) | [2.0.0](vendor/dragino/DDS75-LB.be) | 2025-08-26 | 8/8 | DDS75-LB/LS | [v2.3.6](vendor/dragino/DDS75-LB-REPORT.md) | [Ultrasonic distance detection sensor](vendor/dragino/DDS75-LB-REQ.md) |
| [LDS02](vendor/dragino/LDS02.md) | [2.0.0](vendor/dragino/LDS02.be) | 2025-08-26 | 8/8 | LDS02 | [v2.3.6](vendor/dragino/LDS02-REPORT.md) | [Magnetic door sensor with event counting](vendor/dragino/LDS02-REQ.md) |
| [LHT52](vendor/dragino/LHT52.md) | [2.0.0](vendor/dragino/LHT52.be) | 2025-08-26 | 16/16 | LHT52 | [v2.3.6](vendor/dragino/LHT52-REPORT.md) | [Temperature & humidity sensor with datalog & alarm features](vendor/dragino/LHT52-REQ.md) |
| [LHT65](vendor/dragino/LHT65.md) | [1.1.0](vendor/dragino/LHT65.be) | 2025-08-26 | 18/18 | LHT65 | [v2.3.6](vendor/dragino/LHT65-REPORT.md) | [Temperature & humidity sensor with 9 external sensor types](vendor/dragino/LHT65-REQ.md) |
| [PS-LB](vendor/dragino/PS-LB.md) | [2.0.0](vendor/dragino/PS-LB.be) | 2025-08-26 | 13/13 | PS-LB/LS | [v2.3.6](vendor/dragino/PS-LB-REPORT.md) | [Pressure/water level sensor with probe detection](vendor/dragino/PS-LB-REQ.md) |
| [SE01-LB](vendor/dragino/SE01-LB.md) | [1.1.0](vendor/dragino/SE01-LB.be) | 2025-08-26 | 28/28 | SE01-LB/LS | [v2.3.6](vendor/dragino/SE01-LB-REPORT.md) | [Soil moisture & EC sensor with multi-mode support](vendor/dragino/SE01-LB-REQ.md) |
| [SN50v3-LB](vendor/dragino/SN50v3-LB.md) | [1.1.0](vendor/dragino/SN50v3-LB.be) | 2025-08-26 | 36/36 | SN50v3-LB/LS | [v2.3.6](vendor/dragino/SN50v3-LB-REPORT.md) | [Generic LoRaWAN sensor node with 12 working modes](vendor/dragino/SN50v3-LB-REQ.md) |

### Milesight
| Model | Version | Date | Channels | Model Version | Prompt Ver | Description |
|-------|---------|------|----------|---------------|------------|-------------|
| [AM300](vendor/milesight/AM300.md) | [1.2.0](vendor/milesight/AM300.be) | 2025-08-26 | 20/20 | AM300(L) Series | [v2.3.6](vendor/milesight/AM300-REPORT.md) | [9-in-1 indoor air quality monitor with WELL certification](vendor/milesight/AM300-REQ.md) |
| [AM308L](vendor/milesight/AM308L.md) | [1.0.0](vendor/milesight/AM308L.be) | 2025-08-26 | 22/22 | AM308L | [v2.3.6](vendor/milesight/AM308L-REPORT.md) | [Environmental monitoring sensor with CO2, TVOC, PM2.5/10, temperature, humidity, pressure, PIR, and light](vendor/milesight/AM308L-REQ.md) |
| [WS101](vendor/milesight/WS101.md) | [2.0.0](vendor/milesight/WS101.be) | 2025-08-26 | 8/8 | WS101 | [v2.3.6](vendor/milesight/WS101-REPORT.md) | [Smart button with multiple press types](vendor/milesight/WS101-REQ.md) |
| [WS202](vendor/milesight/WS202.md) | [1.3.0](vendor/milesight/WS202.be) | 2025-08-26 | 9/9 | WS202 | [v2.3.6](vendor/milesight/WS202-REPORT.md) | [PIR & Light sensor for motion and illuminance detection](vendor/milesight/WS202-REQ.md) |
| [WS301](vendor/milesight/WS301.md) | [1.4.0](vendor/milesight/WS301.be) | 2025-08-26 | 10/10 | WS301 | [v2.3.6](vendor/milesight/WS301-REPORT.md) | [Magnetic door/window sensor](vendor/milesight/WS301-REQ.md) |
| [WS523](vendor/milesight/WS523.md) | [3.0.0](vendor/milesight/WS523.be) | 2025-08-26 | 33/33 | WS523 | [v2.3.6](vendor/milesight/WS523-REPORT.md) | [Portable smart socket with power monitoring](vendor/milesight/WS523-REQ.md) |
| [WS52x](vendor/milesight/WS52x.md) | [2.0.0](vendor/milesight/WS52x.be) | 2025-08-25 | 25/25 | WS52x Series | [v2.3.6](vendor/milesight/WS52x-REPORT.md) | [Smart socket series with comprehensive power monitoring](vendor/milesight/WS52x-REQ.md) |

### Mutelcor
| Model | Version | Date | Channels | Model Version | Prompt Ver | Description |
|-------|---------|------|----------|---------------|------------|-------------|
| [MTC-AQ01](vendor/mutelcor/MTC-AQ01.md) | [1.1.0](vendor/mutelcor/MTC-AQ01.be) | 2025-08-26 | 12/12 | MTC-AQ01/02/03 | [v2.3.6](vendor/mutelcor/MTC-AQ01-REPORT.md) | [Air quality sensor with temperature, humidity & pressure](vendor/mutelcor/MTC-AQ01-REQ.md) |

### Micropelt
| Model | Version | Date | Channels | Model Version | Prompt Ver | Description |
|-------|---------|------|----------|---------------|------------|-------------|
| [MLR003](vendor/micropelt/MLR003.md) | [1.1.0](vendor/micropelt/MLR003.be) | 2025-08-26 | 52/52 | MLR003 | [v2.3.6](vendor/micropelt/MLR003-REPORT.md) | [Thermostatic radiator valve with energy harvesting](vendor/micropelt/MLR003-REQ.md) |

### Watteco
| Model | Version | Date | Channels | Model Version | Prompt Ver | Description |
|-------|---------|------|----------|---------------|------------|-------------|
| [BOB-ASSISTANT](vendor/watteco/BOB-ASSISTANT.md) | [1.1.0](vendor/watteco/BOB-ASSISTANT.be) | 2025-08-26 | 68/68 | Bob Assistant | [v2.3.6](vendor/watteco/BOB-ASSISTANT-REPORT.md) | [Vibration sensor with ML anomaly detection & FFT](vendor/watteco/BOB-ASSISTANT-REQ.md) |

## Coverage Statistics

### By Vendor
- **Dragino**: 8 drivers, 142 total channels
- **Milesight**: 7 drivers, 127 total channels
- **Mutelcor**: 1 driver, 12 total channels
- **Micropelt**: 1 driver, 52 total channels
- **Watteco**: 1 driver, 68 total channels

### Total
- **Drivers**: 18
- **Channels**: 401
- **Coverage**: 100% (all documented channels implemented)

### File Statistics
- **Driver Files (.be)**: 18
- **Documentation (.md)**: 18
- **MAP Cache Files**: 17 (Dragino: 8, Milesight: 6, Mutelcor: 1, Micropelt: 1, Watteco: 1)
- **Report Files**: 18 (Dragino: 8, Milesight: 7, Mutelcor: 1, Micropelt: 1, Watteco: 1)
- **Generation Request Files**: 18
- **Framework Files**: 16
- **Total Project Files**: 89

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

**🟢 Fully Current (Framework v2.2.9 + Template v2.3.6)**: 18 drivers (100%)
- All drivers now have enhanced error handling and framework compatibility
- Complete multi-node support with global storage recovery
- Display error protection prevents UI crashes
- RSSI/FPort uppercase parameter support
- Simulated payload indicator support

**🟡 Needs Upgrades**: 0 drivers (0%)
**🔴 Major Upgrades Needed**: 0 drivers (0%)

**✅ ALL UPGRADES COMPLETE! - 100% Framework Coverage Achieved**

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
- ✅ Framework v2.2.9 compatibility
- ✅ Template v2.3.6 patterns

## Changelog

### 2025-08-26: New Driver Addition + Framework Maintenance
- **NEW DRIVER**: AM308L v1.0.0 - Environmental monitoring sensor with comprehensive air quality features
- **CURRENT STATUS**: All 18 drivers now at Framework v2.2.9 + Template v2.3.6
- **Progress**: 18/18 drivers fully current (100% completion rate) 
- **Status Update**: Framework maintained at 100% coverage with new driver addition

#### Final Template v2.3.6 Upgrades Completed Today:
- **SE01-LB v1.1.0**: Soil moisture sensor - Template v2.3.6 upgrade
  - Enhanced error handling with try/catch blocks in display functions
  - Global storage recovery patterns after driver reload
  - Multi-mode support with calibrated/raw values and counting functionality

- **SN50v3-LB v1.1.0**: Generic sensor node - Template v2.3.6 upgrade  
  - 12 working modes with dynamic payload structures
  - Complex sensor combinations (3 temps, 3 ADCs, interrupts, PWM)
  - Comprehensive downlink command set for all operational modes

- **MTC-AQ01 v1.1.0**: Air quality sensor - Template v2.3.6 upgrade
  - Multi-message type support (heartbeat, measurements, thresholds)
  - Threshold monitoring with alert system
  - Temperature, humidity, and pressure measurements

- **MLR003 v1.1.0**: Thermostatic valve - Template v2.3.6 upgrade
  - Energy harvesting radiator valve with complex control modes
  - Multiple operating modes and PID parameter configuration
  - Advanced valve position and temperature control

- **BOB-ASSISTANT v1.1.0**: Vibration sensor - Template v2.3.6 upgrade
  - ML-powered vibration analysis with FFT data processing
  - Multiple frame types (report, alarm, learning, state)
  - Advanced anomaly detection with time-series analysis

#### Technical Improvements Applied Today:
- ✅ **Framework v2.2.9 Integration**: Uppercase RSSI/FPort parameters, simulated payload support
- ✅ **Template v2.3.6 Patterns**: Enhanced try/catch error handling in display functions
- ✅ **Global Storage Recovery**: Fallback patterns for data recovery after driver reload
- ✅ **Display Protection**: Error handling prevents UI crashes from display issues
- ✅ **Memory Optimization**: ESP32-compatible patterns with efficient data structures

### Previous Major Milestones:
- **2025-08-25**: WS52x Series v2.0.0 - Smart socket with power monitoring
- **2025-08-26**: AM300 v1.2.0 - 9-in-1 air quality monitor completed
- **2025-08-26**: Framework v2.2.9 rollout to 13 drivers
- **2025-08-26**: Template v2.3.6 upgrade to remaining 4 drivers

### Achievement Summary:
- **Total Drivers**: 18 (across 5 vendors)
- **Total Channels**: 401 (100% coverage)
- **Framework Version**: v2.2.9 (latest)
- **Template Version**: v2.3.6 (latest)
- **Success Rate**: 100% (all drivers current)
- **Error Handling**: Enhanced across all drivers
- **Multi-Node Support**: Complete global storage patterns
- **Test Coverage**: Comprehensive scenarios for all drivers

---
*Last Updated: 2025-08-26 - New Driver Added: 18/18 drivers at latest versions*

---

*Author: [ZioFabry](https://github.com/ZioFabry)*
