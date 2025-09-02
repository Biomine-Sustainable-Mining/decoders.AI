# LwDecode Framework - Consolidated Emoji Reference Guide

## Overview
This document maintains the definitive list of emojis used across all LwDecode drivers for consistent sensor representation in the web UI. Each emoji is standardized for specific measurement types across all drivers to ensure a uniform user experience.

## Comprehensive Emoji Usage Table

| Emoji | Unicode | Name | Unit/Type | Current Drivers | Status | Description |
|-------|---------|------|-----------|----------------|--------|-------------|
| **🌡️** | U+1F321 | Thermometer | Temperature (°C) | [AM300](vendor/milesight/AM300.md), [BOB-ASSISTANT](vendor/watteco/BOB-ASSISTANT.md), [D2x](vendor/dragino/D2x.md), [DDS75-LB](vendor/dragino/DDS75-LB.md), [LHT52](vendor/dragino/LHT52.md), [LHT65](vendor/dragino/LHT65.md), [MLR003](vendor/micropelt/MLR003.md), [MTC-AQ01](vendor/mutelcor/MTC-AQ01.md), [PS-LB](vendor/dragino/PS-LB.md), [SE01-LB](vendor/dragino/SE01-LB.md), [SN50v3-LB](vendor/dragino/SN50v3-LB.md), [WS202](vendor/milesight/WS202.md), [WS301](vendor/milesight/WS301.md) | ✅ Standard | **Universal temperature sensor** |
| **💧** | U+1F4A7 | Droplet | Humidity (%RH) / Water Depth (m) | [AM300](vendor/milesight/AM300.md), [LHT52](vendor/dragino/LHT52.md), [LHT65](vendor/dragino/LHT65.md), [PS-LB](vendor/dragino/PS-LB.md), [SE01-LB](vendor/dragino/SE01-LB.md), [SN50v3-LB](vendor/dragino/SN50v3-LB.md), [WS301](vendor/milesight/WS301.md) | ✅ Standard | **Universal humidity sensor / water depth** |
| **⏱️** | U+23F1 | Stopwatch | Last Seen/Age | ALL DRIVERS (17/17) | ✅ Universal | **Universal "last seen" indicator** |
| **⚠️** | U+26A0 | Warning Sign | Error/Warning/Alert | [AM300](vendor/milesight/AM300.md), [BOB-ASSISTANT](vendor/watteco/BOB-ASSISTANT.md), [DDS75-LB](vendor/dragino/DDS75-LB.md), [LHT65](vendor/dragino/LHT65.md), [MLR003](vendor/micropelt/MLR003.md), [MTC-AQ01](vendor/mutelcor/MTC-AQ01.md), [SE01-LB](vendor/dragino/SE01-LB.md), [WS301](vendor/milesight/WS301.md) | ✅ Standard | Sensor errors, cable disconnection, tamper, alerts |
| **📟** | U+1F4DF | Pager | Device Model/Info | [D2x](vendor/dragino/D2x.md), [DDS75-LB](vendor/dragino/DDS75-LB.md), [LHT52](vendor/dragino/LHT52.md), [SE01-LB](vendor/dragino/SE01-LB.md), [SN50v3-LB](vendor/dragino/SN50v3-LB.md) | ✅ Standard | Device model identifier |
| **📡** | U+1F4E1 | Satellite Antenna | Frequency Band/Signal | [D2x](vendor/dragino/D2x.md), [DDS75-LB](vendor/dragino/DDS75-LB.md), [LHT52](vendor/dragino/LHT52.md), [SE01-LB](vendor/dragino/SE01-LB.md), [SN50v3-LB](vendor/dragino/SN50v3-LB.md) | ✅ Standard | LoRaWAN frequency band |
| **🟢** | U+1F7E2 | Green Circle | Active/On/Normal | [AM300](vendor/milesight/AM300.md), [LHT65](vendor/dragino/LHT65.md), [WS101](vendor/milesight/WS101.md), [WS523](vendor/milesight/WS523.md), [WS52x](vendor/milesight/WS52x.md) | ✅ Standard | Normal state, socket on, occupied |
| **🔢** | U+1F522 | Input Numbers | Counter/Events | [LDS02](vendor/dragino/LDS02.md), [LHT65](vendor/dragino/LHT65.md), [SE01-LB](vendor/dragino/SE01-LB.md), [SN50v3-LB](vendor/dragino/SN50v3-LB.md) | ✅ Standard | Digital counters, event counting |
| **💡** | U+1F4A1 | Light Bulb | Illuminance (lux) / Power (W) | [AM300](vendor/milesight/AM300.md), [LHT65](vendor/dragino/LHT65.md), [WS202](vendor/milesight/WS202.md), [WS523](vendor/milesight/WS523.md), [WS52x](vendor/milesight/WS52x.md) | ✅ Standard | Light sensors, active power |
| **📊** | U+1F4CA | Bar Chart | Pressure (hPa/MPa) / Power Factor | [AM300](vendor/milesight/AM300.md), [MTC-AQ01](vendor/mutelcor/MTC-AQ01.md), [PS-LB](vendor/dragino/PS-LB.md), [SN50v3-LB](vendor/dragino/SN50v3-LB.md), [WS523](vendor/milesight/WS523.md), [WS52x](vendor/milesight/WS52x.md) | ✅ Standard | Barometric pressure, power factor |
| **🔄** | U+1F504 | Counterclockwise Arrows | Device Reset | [AM300](vendor/milesight/AM300.md), [SE01-LB](vendor/dragino/SE01-LB.md), [WS301](vendor/milesight/WS301.md), [WS523](vendor/milesight/WS523.md), [WS52x](vendor/milesight/WS52x.md) | ✅ Standard | Device reset events |
| **💾** | U+1F4BE | Floppy Disk | Firmware/Datalog | [D2x](vendor/dragino/D2x.md), [LHT52](vendor/dragino/LHT52.md), [SE01-LB](vendor/dragino/SE01-LB.md), [SN50v3-LB](vendor/dragino/SN50v3-LB.md) | ✅ Standard | Firmware version, datalog storage |
| **⚡** | U+26A1 | High Voltage | Voltage (V) / Electrical | [LHT65](vendor/dragino/LHT65.md), [PS-LB](vendor/dragino/PS-LB.md), [SE01-LB](vendor/dragino/SE01-LB.md), [WS523](vendor/milesight/WS523.md), [WS52x](vendor/milesight/WS52x.md) | ✅ Standard | Electrical voltage, EC measurements |
| **🔌** | U+1F50C | Electric Plug | Current (mA) | [PS-LB](vendor/dragino/PS-LB.md), [WS523](vendor/milesight/WS523.md), [WS52x](vendor/milesight/WS52x.md) | ✅ Standard | Electrical current |
| **📏** | U+1F4CF | Straight Ruler | Distance (mm/cm/m) | [DDS75-LB](vendor/dragino/DDS75-LB.md), [SN50v3-LB](vendor/dragino/SN50v3-LB.md) | ✅ Standard | Distance/proximity measurement |
| **⚖️** | U+2696 | Balance Scale | Weight (kg) | [SN50v3-LB](vendor/dragino/SN50v3-LB.md) | ✅ Standard | Weight/load measurement |
| **〰️** | U+3030 | Wavy Dash | PWM/Frequency | [SN50v3-LB](vendor/dragino/SN50v3-LB.md) | ✅ Standard | PWM frequency, waveform signals |
| **🔓** | U+1F513 | Open Lock | Door Open/Unlocked | [LDS02](vendor/dragino/LDS02.md), [WS301](vendor/milesight/WS301.md) | ✅ Standard | Door/lock open state |
| **🔒** | U+1F512 | Locked | Door Closed/Locked | [LDS02](vendor/dragino/LDS02.md), [WS301](vendor/milesight/WS301.md) | ✅ Standard | Door/lock closed state |
| **🔋** | U+1F50B | Battery | Battery Status | ALL DRIVERS (17/17) | ✅ Universal | Battery charge level/voltage |
| **🔴** | U+1F534 | Red Circle | Alert/Error/Active | [LHT65](vendor/dragino/LHT65.md), [WS101](vendor/milesight/WS101.md), [WS523](vendor/milesight/WS523.md), [WS52x](vendor/milesight/WS52x.md) | ✅ Standard | Alert state, error conditions |
| **⚫** | U+26AB | Black Circle | Inactive/Vacant/Off | [AM300](vendor/milesight/AM300.md), [WS101](vendor/milesight/WS101.md), [WS202](vendor/milesight/WS202.md) | ✅ Standard | PIR vacant, inactive state |
| **🏠** | U+1F3E0 | House | Energy (Wh/kWh) | [WS523](vendor/milesight/WS523.md), [WS52x](vendor/milesight/WS52x.md) | ✅ Standard | Energy consumption |
| **🌬️** | U+1F32C | Wind Face | CO2 (ppm) | [AM300](vendor/milesight/AM300.md) | ✅ Standard | Carbon dioxide concentration |
| **🏭** | U+1F3ED | Factory | TVOC (ppb) | [AM300](vendor/milesight/AM300.md) | ✅ Standard | Total volatile organic compounds |
| **🌫️** | U+1F32B | Fog | PM10 (μg/m³) | [AM300](vendor/milesight/AM300.md), [AM308L](vendor/milesight/AM308L.md) | ✅ Standard | Coarse particulate matter |
| **💨** | U+1F4A8 | Dashing Away | CO2 (ppm) / TVOC | [AM300](vendor/milesight/AM300.md), [AM308L](vendor/milesight/AM308L.md) | ✅ Standard | Carbon dioxide, volatile compounds |
| **🫧** | U+1FAE7 | Bubbles | PM2.5 (μg/m³) | [AM308L](vendor/milesight/AM308L.md) | ✅ New | Fine particulate matter |
| **🌿** | U+1F33F | Herb | TVOC (IAQ) | [AM308L](vendor/milesight/AM308L.md) | ✅ New | TVOC in IAQ units |
| **🧪** | U+1F9EA | Test Tube | HCHO (mg/m³) | [AM300](vendor/milesight/AM300.md) | ✅ Standard | Formaldehyde concentration |
| **⚗️** | U+2697 | Alembic | O3 (ppm) | [AM300](vendor/milesight/AM300.md) | ✅ Standard | Ozone concentration |
| **🔊** | U+1F50A | Speaker High Volume | Frequency/Audio/Buzzer | [AM300](vendor/milesight/AM300.md), [BOB-ASSISTANT](vendor/watteco/BOB-ASSISTANT.md) | ✅ Standard | Buzzer on/audio alert, peak frequency |
| **📳** | U+1F4F3 | Vibration Mode | Vibration (g) | [BOB-ASSISTANT](vendor/watteco/BOB-ASSISTANT.md) | ✅ New | Vibration monitoring, predictive maintenance |
| **🧠** | U+1F9E0 | Brain | Machine Learning | [BOB-ASSISTANT](vendor/watteco/BOB-ASSISTANT.md) | ✅ New | ML learning progress, AI anomaly detection |
| **🔇** | U+1F507 | Muted Speaker | Buzzer Off/Muted | [AM300](vendor/milesight/AM300.md) | ✅ New | Muted audio state |
| **✅** | U+2705 | Check Mark Button | OK Status/Normal | [MLR003](vendor/micropelt/MLR003.md), [MTC-AQ01](vendor/mutelcor/MTC-AQ01.md), [WS301](vendor/milesight/WS301.md) | ✅ Standard | Installation confirmed, normal operation |
| **❌** | U+274C | Cross Mark | Error/Failed | [DDS75-LB](vendor/dragino/DDS75-LB.md), [MLR003](vendor/micropelt/MLR003.md), [WS301](vendor/milesight/WS301.md) | ✅ Standard | Installation error, sensor error |
| **🔧** | U+1F527 | Wrench | Configuration/Valve/Calibration | [DDS75-LB](vendor/dragino/DDS75-LB.md), [MLR003](vendor/micropelt/MLR003.md), [PS-LB](vendor/dragino/PS-LB.md), [SE01-LB](vendor/dragino/SE01-LB.md) | ✅ Standard | Valve control, calibration, probe type |
| **🌊** | U+1F30A | Ocean Wave | Flow Temperature | [MLR003](vendor/micropelt/MLR003.md) | ✅ New | Radiator flow water temperature |
| **⏰** | U+23F0 | Alarm Clock | Time Events | [DDS75-LB](vendor/dragino/DDS75-LB.md), [LHT65](vendor/dragino/LHT65.md) | ✅ New | Time synchronization, periodic events |
| **🔔** | U+1F514 | Bell | Interrupt/ROC | [DDS75-LB](vendor/dragino/DDS75-LB.md), [PS-LB](vendor/dragino/PS-LB.md) | ✅ New | Interrupt events, report on change |
| **🚨** | U+1F6A8 | Police Car Light | Alarm/Critical | [AM300](vendor/milesight/AM300.md), [BOB-ASSISTANT](vendor/watteco/BOB-ASSISTANT.md), [D2x](vendor/dragino/D2x.md) | ✅ New | Temperature alarms, critical alerts |
| **💓** | U+1F493 | Beating Heart | Heartbeat/Status | [MTC-AQ01](vendor/mutelcor/MTC-AQ01.md) | ✅ New | Heartbeat messages, alive status |
| **📶** | U+1F4F6 | Antenna Bars | Signal/Interrupt | [SE01-LB](vendor/dragino/SE01-LB.md), [SN50v3-LB](vendor/dragino/SN50v3-LB.md) | ✅ New | Signal strength, interrupt status |
| **🚶** | U+1F6B6 | Person Walking | Motion/PIR | [WS202](vendor/milesight/WS202.md) | ✅ New | Motion detection, PIR sensor |
| **👥** | U+1F465 | People | People Count | [VS321](vendor/milesight/VS321.md) | ✅ New | AI people counting |
| **🪑** | U+1FA91 | Chair | Desk Occupancy | [VS321](vendor/milesight/VS321.md) | ✅ New | Desk/workspace occupancy |
| **⭕** | U+2B55 | Red Circle | Vacant/Off | [VS321](vendor/milesight/VS321.md) | ✅ New | Vacant occupancy state |
| **☀️** | U+2600 | Sun | Bright Light | [VS321](vendor/milesight/VS321.md) | ✅ New | Bright illuminance |
| **🌙** | U+1F319 | Moon | Dim Light | [VS321](vendor/milesight/VS321.md) | ✅ New | Dim illuminance |
| **💦** | U+1F4A6 | Sweat Droplets | Humidity Alarm | [VS321](vendor/milesight/VS321.md) | ✅ New | Humidity threshold alarm |

## Current Driver Status (17 Drivers Complete)

### **Dragino (8 drivers)**
- **[D2x](vendor/dragino/D2x.md)**: 6 emojis (multi-probe temperature sensor)
- **[DDS75-LB](vendor/dragino/DDS75-LB.md)**: 10 emojis (ultrasonic distance sensor)
- **[LDS02](vendor/dragino/LDS02.md)**: 6 emojis (magnetic door sensor)
- **[LHT52](vendor/dragino/LHT52.md)**: 9 emojis (temperature/humidity with datalog)
- **[LHT65](vendor/dragino/LHT65.md)**: 11 emojis (multi-sensor with external probes)
- **[PS-LB](vendor/dragino/PS-LB.md)**: 8 emojis (pressure/water level sensor)
- **[SE01-LB](vendor/dragino/SE01-LB.md)**: 8 emojis (soil moisture & EC sensor)
- **[SN50v3-LB](vendor/dragino/SN50v3-LB.md)**: 10 emojis (generic 12-mode sensor node)

### **Milesight (8 drivers)**
- **[AM300](vendor/milesight/AM300.md)**: 16 emojis (9-in-1 air quality monitor)
- **[AM308L](vendor/milesight/AM308L.md)**: 11 emojis (environmental monitoring sensor)
- **[VS321](vendor/milesight/VS321.md)**: 10 emojis (AI occupancy sensor)
- **[WS101](vendor/milesight/WS101.md)**: 4 emojis (smart button)
- **[WS202](vendor/milesight/WS202.md)**: 4 emojis (PIR & light sensor)
- **[WS301](vendor/milesight/WS301.md)**: 8 emojis (magnetic door/window sensor)
- **[WS523](vendor/milesight/WS523.md)**: 8 emojis (portable smart socket)
- **[WS52x](vendor/milesight/WS52x.md)**: 8 emojis (smart socket series)

### **Mutelcor (1 driver)**
- **[MTC-AQ01](vendor/mutelcor/MTC-AQ01.md)**: 6 emojis (air quality with heartbeat)

### **Micropelt (1 driver)**
- **[MLR003](vendor/micropelt/MLR003.md)**: 6 emojis (thermostatic radiator valve)

### **Watteco (1 driver)**
- **[BOB-ASSISTANT](vendor/watteco/BOB-ASSISTANT.md)**: 8 emojis (vibration sensor with ML)

### **Framework Statistics**
- **Total unique emojis**: 50 (6 new for VS321)
- **Universal coverage**: 100% (⏱️ and 🔋 in all drivers)
- **Temperature consistency**: 100% (🌡️ in all temp sensors)
- **Framework integration**: 100% (all use LwSensorFormatter_cls)
- **Complete documentation**: 19/19 drivers with full emoji coverage

---

## Version History
- **v1.09** (2025-09-02): VS321 AI Occupancy Sensor Addition
  - Added 6 new emojis for occupancy detection: 👥 🪑 ⭕ ☀️ 🌙 💦
  - Updated driver count to 19 (8 Milesight drivers)
  - Total unique emojis: 50 (new high)
  - Framework v2.3.0 + Template v2.4.0 compatibility
- **v1.08** (2025-08-26): Complete coverage update with linked model references
  - Added clickable links to all model documentation (.md files)
  - Updated comprehensive coverage verification for all 17 drivers
  - Enhanced navigation with direct links to driver documentation
  - Framework v2.2.9 + Template v2.3.6 compatibility confirmed

---

*This reference is automatically maintained as part of LwDecode framework development*  
*Last updated: 2025-09-02 | Framework version: 2.3.0 | Template version: 2.4.0*

---

*Author: [ZioFabry](https://github.com/ZioFabry)*
