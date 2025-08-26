# LwDecode Framework - Consolidated Emoji Reference Guide

## Overview
This document maintains the definitive list of emojis used across all LwDecode drivers for consistent sensor representation in the web UI. Each emoji is standardized for specific measurement types across all drivers to ensure a uniform user experience.

## Comprehensive Emoji Usage Table

| Emoji | Unicode | Name | Unit/Type | Current Drivers | Status | Description |
|-------|---------|------|-----------|----------------|--------|-------------|
| **🌡️** | U+1F321 | Thermometer | Temperature (°C) | AM300, BOB-ASSISTANT, D2x, DDS75-LB, LHT52, LHT65, MLR003, MTC-AQ01, PS-LB, SE01-LB, SN50v3-LB, WS202, WS301 | ✅ Standard | **Universal temperature sensor** |
| **💧** | U+1F4A7 | Droplet | Humidity (%RH) / Water Depth (m) | AM300, LHT52, LHT65, PS-LB, SE01-LB, SN50v3-LB, WS301 | ✅ Standard | **Universal humidity sensor / water depth** |
| **⏱️** | U+23F1 | Stopwatch | Last Seen/Age | ALL DRIVERS (17/17) | ✅ Universal | **Universal "last seen" indicator** |
| **⚠️** | U+26A0 | Warning Sign | Error/Warning/Alert | AM300, BOB-ASSISTANT, DDS75-LB, LHT65, MLR003, MTC-AQ01, SE01-LB, WS301 | ✅ Standard | Sensor errors, cable disconnection, tamper, alerts |
| **📟** | U+1F4DF | Pager | Device Model/Info | D2x, DDS75-LB, LHT52, SE01-LB, SN50v3-LB | ✅ Standard | Device model identifier |
| **📡** | U+1F4E1 | Satellite Antenna | Frequency Band/Signal | D2x, DDS75-LB, LHT52, SE01-LB, SN50v3-LB | ✅ Standard | LoRaWAN frequency band |
| **🟢** | U+1F7E2 | Green Circle | Active/On/Normal | AM300, LHT65, WS101, WS523, WS52x | ✅ Standard | Normal state, socket on, occupied |
| **🔢** | U+1F522 | Input Numbers | Counter/Events | LDS02, LHT65, SE01-LB, SN50v3-LB | ✅ Standard | Digital counters, event counting |
| **💡** | U+1F4A1 | Light Bulb | Illuminance (lux) / Power (W) | AM300, LHT65, WS202, WS523, WS52x | ✅ Standard | Light sensors, active power |
| **📊** | U+1F4CA | Bar Chart | Pressure (hPa/MPa) / Power Factor | AM300, MTC-AQ01, PS-LB, SN50v3-LB, WS523, WS52x | ✅ Standard | Barometric pressure, power factor |
| **🔄** | U+1F504 | Counterclockwise Arrows | Device Reset | AM300, SE01-LB, WS301, WS523, WS52x | ✅ Standard | Device reset events |
| **💾** | U+1F4BE | Floppy Disk | Firmware/Datalog | D2x, LHT52, SE01-LB, SN50v3-LB | ✅ Standard | Firmware version, datalog storage |
| **⚡** | U+26A1 | High Voltage | Voltage (V) / Electrical | LHT65, PS-LB, SE01-LB, WS523, WS52x | ✅ Standard | Electrical voltage, EC measurements |
| **🔌** | U+1F50C | Electric Plug | Current (mA) | PS-LB, WS523, WS52x | ✅ Standard | Electrical current |
| **📏** | U+1F4CF | Straight Ruler | Distance (mm/cm/m) | DDS75-LB, SN50v3-LB | ✅ Standard | Distance/proximity measurement |
| **⚖️** | U+2696 | Balance Scale | Weight (kg) | SN50v3-LB | ✅ Standard | Weight/load measurement |
| **〰️** | U+3030 | Wavy Dash | PWM/Frequency | SN50v3-LB | ✅ Standard | PWM frequency, waveform signals |
| **🔓** | U+1F513 | Open Lock | Door Open/Unlocked | LDS02, WS301 | ✅ Standard | Door/lock open state |
| **🔒** | U+1F512 | Locked | Door Closed/Locked | LDS02, WS301 | ✅ Standard | Door/lock closed state |
| **🔋** | U+1F50B | Battery | Battery Status | ALL DRIVERS (17/17) | ✅ Universal | Battery charge level/voltage |
| **🔴** | U+1F534 | Red Circle | Alert/Error/Active | LHT65, WS101, WS523, WS52x | ✅ Standard | Alert state, error conditions |
| **⚫** | U+26AB | Black Circle | Inactive/Vacant/Off | AM300, WS101, WS202 | ✅ Standard | PIR vacant, inactive state |
| **🏠** | U+1F3E0 | House | Energy (Wh/kWh) | WS523, WS52x | ✅ Standard | Energy consumption |
| **🌬️** | U+1F32C | Wind Face | CO2 (ppm) | AM300 | ✅ Standard | Carbon dioxide concentration |
| **🏭** | U+1F3ED | Factory | TVOC (ppb) | AM300 | ✅ Standard | Total volatile organic compounds |
| **🌫️** | U+1F32B | Fog | PM2.5 (μg/m³) | AM300 | ✅ Standard | Fine particulate matter |
| **💨** | U+1F4A8 | Dashing Away | PM10 (μg/m³) | AM300 | ✅ Standard | Coarse particulate matter |
| **🧪** | U+1F9EA | Test Tube | HCHO (mg/m³) | AM300 | ✅ Standard | Formaldehyde concentration |
| **⚗️** | U+2697 | Alembic | O3 (ppm) | AM300 | ✅ Standard | Ozone concentration |
| **🔊** | U+1F50A | Speaker High Volume | Frequency/Audio/Buzzer | AM300, BOB-ASSISTANT | ✅ Standard | Buzzer on/audio alert, peak frequency |
| **📳** | U+1F4F3 | Vibration Mode | Vibration (g) | BOB-ASSISTANT | ✅ New | Vibration monitoring, predictive maintenance |
| **🧠** | U+1F9E0 | Brain | Machine Learning | BOB-ASSISTANT | ✅ New | ML learning progress, AI anomaly detection |
| **🔇** | U+1F507 | Muted Speaker | Buzzer Off/Muted | AM300 | ✅ New | Muted audio state |
| **✅** | U+2705 | Check Mark Button | OK Status/Normal | MLR003, MTC-AQ01, WS301 | ✅ Standard | Installation confirmed, normal operation |
| **❌** | U+274C | Cross Mark | Error/Failed | DDS75-LB, MLR003, WS301 | ✅ Standard | Installation error, sensor error |
| **🔧** | U+1F527 | Wrench | Configuration/Valve/Calibration | DDS75-LB, MLR003, PS-LB, SE01-LB | ✅ Standard | Valve control, calibration, probe type |
| **🌊** | U+1F30A | Ocean Wave | Flow Temperature | MLR003 | ✅ New | Radiator flow water temperature |
| **⏰** | U+23F0 | Alarm Clock | Time Events | DDS75-LB, LHT65 | ✅ New | Time synchronization, periodic events |
| **🔔** | U+1F514 | Bell | Interrupt/ROC | DDS75-LB, PS-LB | ✅ New | Interrupt events, report on change |
| **🚨** | U+1F6A8 | Police Car Light | Alarm/Critical | AM300, BOB-ASSISTANT, D2x | ✅ New | Temperature alarms, critical alerts |
| **💓** | U+1F493 | Beating Heart | Heartbeat/Status | MTC-AQ01 | ✅ New | Heartbeat messages, alive status |
| **📶** | U+1F4F6 | Antenna Bars | Signal/Interrupt | SE01-LB, SN50v3-LB | ✅ New | Signal strength, interrupt status |
| **🚶** | U+1F6B6 | Person Walking | Motion/PIR | WS202 | ✅ New | Motion detection, PIR sensor |

## Usage Categories

### **Universal Emojis (All 17 drivers)**
- **⏱️** Last seen/Age - Used by ALL drivers for data age indication
- **🔋** Battery Status - Used by ALL drivers for power monitoring

### **Temperature Sensors (13 drivers)**
- **🌡️** Temperature - Universal standard for temperature sensors

### **Common Emojis (5+ drivers)**
- **💧** Humidity/Water depth - 7 drivers
- **⚠️** Warnings/Errors - 8 drivers
- **📊** Pressure/Power Factor - 6 drivers
- **💡** Light/Power - 5 drivers
- **🔄** Device Reset - 5 drivers
- **📟** Device Info - 5 drivers
- **📡** LoRaWAN Band - 5 drivers
- **🟢** Active/Normal - 5 drivers

### **Power & Energy (WS52x, WS523)**
- **⚡** Voltage measurement
- **🔌** Current measurement  
- **🏠** Energy consumption
- **📊** Power factor

### **Air Quality (AM300)**
- **🌬️** CO2 concentration
- **🏭** TVOC levels
- **🌫️** PM2.5 particles
- **💨** PM10 particles
- **🧪** HCHO formaldehyde
- **⚗️** O3 ozone

### **Industrial IoT (BOB-ASSISTANT)**
- **📳** Vibration monitoring
- **🧠** ML anomaly detection
- **🚨** Alarm conditions

## Implementation Standards

### **Consistency Rules**
1. **Same Unit = Same Emoji**: Always use the same emoji for the same measurement type
2. **Universal Emojis**: ⏱️ and 🔋 must be used consistently across ALL drivers
3. **Temperature Standard**: 🌡️ for all temperature measurements
4. **Framework Integration**: Use LwSensorFormatter_cls for all new drivers

### **Framework Formatter Patterns**
```berry
# Universal formatters (required in all drivers)
"temp":        {"u": "°C",  "f": " %.1f", "i": "🌡️"},
"humidity":    {"u": "%",   "f": " %.0f", "i": "💧"},
"pressure":    {"u": "hPa", "f": " %.0f", "i": "📊"},
"volt":        {"u": "V",   "f": " %.1f", "i": "⚡"},
"milliamp":    {"u": "mA",  "f": " %.0f", "i": "🔌"},
"power":       {"u": "W",   "f": " %.0f", "i": "💡"},
"energy":      {"u": "Wh",  "f": " %.0f", "i": "🏠"},
```

## Current Driver Status (17 Drivers Complete)

### **Dragino (8 drivers)**
- **D2x**: 6 emojis (multi-probe temperature sensor)
- **DDS75-LB**: 10 emojis (ultrasonic distance sensor)
- **LDS02**: 6 emojis (magnetic door sensor)
- **LHT52**: 9 emojis (temperature/humidity with datalog)
- **LHT65**: 11 emojis (multi-sensor with external probes)
- **PS-LB**: 8 emojis (pressure/water level sensor)
- **SE01-LB**: 8 emojis (soil moisture & EC sensor)
- **SN50v3-LB**: 10 emojis (generic 12-mode sensor node)

### **Milesight (6 drivers)**
- **AM300**: 16 emojis (9-in-1 air quality monitor)
- **WS101**: 4 emojis (smart button)
- **WS202**: 4 emojis (PIR & light sensor)
- **WS301**: 8 emojis (magnetic door/window sensor)
- **WS523**: 8 emojis (portable smart socket)
- **WS52x**: 8 emojis (smart socket series)

### **Mutelcor (1 driver)**
- **MTC-AQ01**: 6 emojis (air quality with heartbeat)

### **Micropelt (1 driver)**
- **MLR003**: 6 emojis (thermostatic radiator valve)

### **Watteco (1 driver)**
- **BOB-ASSISTANT**: 8 emojis (vibration sensor with ML)

### **Framework Statistics**
- **Total unique emojis**: 42
- **Universal coverage**: 100% (⏱️ and 🔋 in all drivers)
- **Temperature consistency**: 100% (🌡️ in all temp sensors)
- **Framework integration**: 100% (all use LwSensorFormatter_cls)
- **Complete documentation**: 17/17 drivers with full emoji coverage

## Quality Assurance Checklist

Before driver release:
- ✅ Universal emojis (⏱️, 🔋) implemented correctly
- ✅ Temperature emoji (🌡️) used for all temperature sensors
- ✅ No duplicate emoji usage for different measurement types
- ✅ All emojis documented in this reference
- ✅ Formatter patterns follow framework standards
- ✅ Visual consistency tested across different devices

---

## Version History
- **v1.08** (2025-08-26): Complete coverage update - All 17 drivers
  - Added comprehensive coverage verification for all current drivers
  - Updated emoji usage statistics: 42 unique emojis across 17 drivers
  - Added new driver emojis: 📶 (SN50v3-LB), 💓 (MTC-AQ01), 🚶 (WS202)
  - Verified universal emoji compliance: ⏱️ and 🔋 in all 17 drivers
  - Framework v2.2.9 + Template v2.3.6 compatibility confirmed
- **v1.07** (2025-08-16): Added PS-LB pressure sensor emojis
- **v1.06** (2025-08-16): Complete consolidation across 8 drivers
- **v1.05-1.00**: Progressive development with individual driver additions

---

*This reference is automatically maintained as part of LwDecode framework development*  
*Last updated: 2025-08-26 | Framework version: 2.2.9 | Template version: 2.3.6*

---

*Author: [ZioFabry](https://github.com/ZioFabry)*
