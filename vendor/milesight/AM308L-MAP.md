# Milesight AM308L Protocol MAP
# Generated: 2025-08-26 16:53:42 | Source: Official Milesight Repository
# References: README.md, decoder.js, encoder.js, codec.json

device_info:
  vendor: "Milesight"
  model: "AM308L"
  type: "Ambience Monitoring Sensor"
  description: "Multi-sensor environmental monitoring device with CO2, TVOC, PM2.5/PM10, temperature, humidity, pressure, PIR, and light sensing"
  lorawan_version: "1.0.x"
  regions: ["EU868", "US915", "AS923", "AU915"]
  official_link: "https://www.milesight.com/iot/product/lorawan-sensor/am319"
  repository: "https://github.com/Milesight-IoT/SensorDecoders/tree/main/am-series/am308l"

uplinks:
  - name: "Device Information"
    channels:
      - id: 0xFF
        type: 0x01
        name: "IPSO Version"
        size: 1
        format: "Protocol version (major.minor)"
      - id: 0xFF
        type: 0x09
        name: "Hardware Version" 
        size: 2
        format: "vX.Y from bytes"
      - id: 0xFF
        type: 0x0A
        name: "Firmware Version"
        size: 2
        format: "vX.Y from bytes"
      - id: 0xFF
        type: 0xFF
        name: "TSL Version"
        size: 2
        format: "vX.Y from bytes"
      - id: 0xFF
        type: 0x16
        name: "Serial Number"
        size: 8
        format: "Hex string"
      - id: 0xFF
        type: 0x0F
        name: "LoRaWAN Class"
        size: 1
        values:
          0: "Class A"
          1: "Class B" 
          2: "Class C"
          3: "Class CtoB"
      - id: 0xFF
        type: 0xFE
        name: "Reset Event"
        size: 1
        format: "Reset event indicator"
      - id: 0xFF
        type: 0x0B
        name: "Device Status"
        size: 1
        values:
          0: "off"
          1: "on"

  - name: "Sensor Data"
    channels:
      - id: 0x01
        type: 0x75
        name: "Battery"
        size: 1
        unit: "%"
        format: "uint8"
      - id: 0x03
        type: 0x67
        name: "Temperature"
        size: 2
        unit: "°C"
        format: "int16LE/10"
        range: [-40, 125]
      - id: 0x04
        type: 0x68
        name: "Humidity"
        size: 1
        unit: "%RH"
        format: "uint8/2"
        range: [0, 100]
      - id: 0x05
        type: 0x00
        name: "PIR Motion"
        size: 1
        values:
          0: "idle"
          1: "trigger"
      - id: 0x06
        type: 0xCB
        name: "Light Level"
        size: 1
        format: "uint8"
        unit: "level"
      - id: 0x07
        type: 0x7D
        name: "CO2"
        size: 2
        unit: "ppm"
        format: "uint16LE"
      - id: 0x08
        type: 0x7D
        name: "TVOC (IAQ)"
        size: 2
        unit: "iaq"
        format: "uint16LE/100"
      - id: 0x08
        type: 0xE6
        name: "TVOC (µg/m³)"
        size: 2
        unit: "µg/m³"
        format: "uint16LE"
      - id: 0x09
        type: 0x73
        name: "Pressure"
        size: 2
        unit: "hPa"
        format: "uint16LE/10"
      - id: 0x0B
        type: 0x7D
        name: "PM2.5"
        size: 2
        unit: "µg/m³"
        format: "uint16LE"
      - id: 0x0C
        type: 0x7D
        name: "PM10"
        size: 2
        unit: "µg/m³"
        format: "uint16LE"
      - id: 0x0E
        type: 0x01
        name: "Buzzer Status"
        size: 1
        values:
          0: "off"
          1: "on"

  - name: "History Data (IAQ)"
    id: 0x20
    type: 0xCE
    size: 20
    format: "timestamp(4B) + temp(2B) + humidity(2B) + pir(1B) + light(1B) + co2(2B) + tvoc_iaq(2B) + pressure(2B) + pm2.5(2B) + pm10(2B)"

  - name: "History Data (µg/m³)"  
    id: 0x21
    type: 0xCE
    size: 20
    format: "timestamp(4B) + temp(2B) + humidity(2B) + pir(1B) + light(1B) + co2(2B) + tvoc_ugm3(2B) + pressure(2B) + pm2.5(2B) + pm10(2B)"

downlinks:
  - command: "Device Reboot"
    hex: "FF10FF"
    parameters: "none"
  - command: "Stop Buzzer"
    hex: "FF3D00"
    parameters: "none"
  - command: "Query Status"
    hex: "FF2C00"
    parameters: "none"
  - command: "Report Interval"
    hex: "FF03[INTERVAL_LE]"
    parameters:
      - name: "interval"
        type: "uint16"
        unit: "seconds"
  - command: "Time Sync Enable"
    hex: "FF3B[ENABLE]"
    parameters:
      - name: "enable"
        type: "uint8"
        values:
          0: "disable"
          2: "enable"
  - command: "Time Zone"
    hex: "FF17[ZONE_LE]"
    parameters:
      - name: "zone"
        type: "int16"
        values:
          -120: "UTC-12"
          -110: "UTC-11"
          -100: "UTC-10"
          -90: "UTC-9"
          -80: "UTC-8"
          -70: "UTC-7"
          -60: "UTC-6"
          -50: "UTC-5"
          -40: "UTC-4"
          -30: "UTC-3"
          -20: "UTC-2"
          -10: "UTC-1"
          0: "UTC"
          10: "UTC+1"
          20: "UTC+2"
          30: "UTC+3"
          40: "UTC+4"
          50: "UTC+5"
          60: "UTC+6"
          70: "UTC+7"
          80: "UTC+8"
          90: "UTC+9"
          100: "UTC+10"
          110: "UTC+11"
          120: "UTC+12"
  - command: "TVOC Unit"
    hex: "FFEB[UNIT]"
    parameters:
      - name: "unit"
        type: "uint8"
        values:
          0: "iaq"
          1: "µg/m³"
  - command: "PM2.5 Collection Interval"
    hex: "FF65[INTERVAL_LE]"
    parameters:
      - name: "interval"
        type: "uint16"
        unit: "seconds"
  - command: "CO2 ABC Calibration Enable"
    hex: "FF39[ENABLE]00000000"
    parameters:
      - name: "enable"
        type: "uint8"
        values:
          0: "disable"
          1: "enable"
  - command: "CO2 Calibration Enable"
    hex: "FFF4[ENABLE]"
    parameters:
      - name: "enable"
        type: "uint8"
        values:
          0: "disable"
          1: "enable"
  - command: "CO2 Calibration Settings"
    hex: "FF1A[MODE][VALUE_LE]"
    parameters:
      - name: "mode"
        type: "uint8"
        values:
          0: "factory"
          1: "abc"
          2: "manual"
          3: "background"
          4: "zero"
      - name: "value"
        type: "uint16"
        required_for_mode: 2
  - command: "Buzzer Enable"
    hex: "FF3E[ENABLE]"
    parameters:
      - name: "enable"
        type: "uint8"
        values:
          0: "disable"
          1: "enable"
  - command: "LED Indicator Mode"
    hex: "FF2E[MODE]"
    parameters:
      - name: "mode"
        type: "uint8"
        values:
          0: "off"
          1: "on"
          2: "blink"
  - command: "Child Lock Settings"
    hex: "FF25[BUTTONS]"
    parameters:
      - name: "buttons"
        type: "uint8"
        format: "bit field: bit0=off_button, bit1=on_button, bit2=collection_button"
        values:
          0: "disable"
          1: "enable"
  - command: "Retransmit Enable"
    hex: "FF69[ENABLE]"
    parameters:
      - name: "enable"
        type: "uint8"
        values:
          0: "disable"
          1: "enable"
  - command: "Retransmit Interval"
    hex: "FF6A00[INTERVAL_LE]"
    parameters:
      - name: "interval"
        type: "uint16"
        unit: "seconds"
        range: [1, 64800]
  - command: "Resend Interval"
    hex: "FF6A01[INTERVAL_LE]"
    parameters:
      - name: "interval"
        type: "uint16"
        unit: "seconds"
        range: [1, 64800]
  - command: "History Enable"
    hex: "FF68[ENABLE]"
    parameters:
      - name: "enable"
        type: "uint8"
        values:
          0: "disable"
          1: "enable"
  - command: "Fetch History"
    hex: "FD6B[START_TIME_LE]"
    parameters:
      - name: "start_time"
        type: "uint32"
        unit: "unix timestamp"
  - command: "Fetch History Range"
    hex: "FD6C[START_TIME_LE][END_TIME_LE]"
    parameters:
      - name: "start_time"
        type: "uint32"
        unit: "unix timestamp"
      - name: "end_time"
        type: "uint32"
        unit: "unix timestamp"
  - command: "Stop Transmit"
    hex: "FD6DFF"
    parameters: "none"
  - command: "Clear History"
    hex: "FF2701"
    parameters: "none"

special_handling:
  crc_required: false
  reset_events: true
  battery_monitoring: true
  history_data: true
  tvoc_dual_units: true  # Both IAQ and µg/m³ supported
  signed_values: ["temperature"]
  configuration_responses: true
  
measurement_units:
  temperature: "°C"
  humidity: "%RH"
  battery: "%"
  pressure: "hPa"
  co2: "ppm"
  tvoc_iaq: "iaq"
  tvoc_ugm3: "µg/m³"
  pm2_5: "µg/m³"
  pm10: "µg/m³"
  light_level: "level"
