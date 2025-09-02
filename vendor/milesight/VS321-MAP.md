# Milesight VS321 Protocol MAP
# Generated: 2025-09-02 12:15:00 | PDF Version: V1.0
# Source: VS321_User_Guide.pdf

device_info:
  vendor: Milesight
  model: VS321
  type: AI Occupancy Sensor
  lorawan_version: V1.0.2/V1.0.3
  regions: [EU868, US915, AU915]
  official_link: support.milesight-iot.com
  app_port: 85

uplinks:
  - port: 85
    name: "Basic Information"
    description: "Device join and reset information"
    channels:
      - id: 0xFF
        type: 0x0F
        name: "Device Type"
        size: 1
        value: 0x00
        description: "Class A"
      - id: 0xFF
        type: 0xFF
        name: "TSL Version"
        size: 2
        format: "little_endian"
      - id: 0xFF
        type: 0x09
        name: "Hardware Version"
        size: 2
        format: "little_endian"
      - id: 0xFF
        type: 0x0A
        name: "Firmware Version"
        size: 2
        format: "little_endian"
      - id: 0xFF
        type: 0x16
        name: "Device Serial Number"
        size: 8
      - id: 0xFF
        type: 0x0B
        name: "Power On"
        size: 1
        value: 0xFF
      - id: 0xFF
        type: 0x01
        name: "Protocol Version"
        size: 1
      - id: 0xFF
        type: 0xFE
        name: "Reset Report"
        size: 1
        value: 0xFF

  - port: 85
    name: "Periodic Report"
    description: "Regular sensor data transmission"
    channels:
      - id: 0x01
        type: 0x75
        name: "Battery Level"
        size: 1
        unit: "%"
        range: [1, 100]
      - id: 0x03
        type: 0x67
        name: "Temperature"
        size: 2
        unit: "°C"
        resolution: 0.1
        signed: true
        format: "little_endian"
      - id: 0x04
        type: 0x68
        name: "Humidity"
        size: 1
        unit: "%RH"
        resolution: 0.5
      - id: 0x05
        type: 0xFD
        name: "People Counting"
        size: 2
        unit: "persons"
        format: "little_endian"
      - id: 0x06
        type: 0xFE
        name: "Desk Occupancy"
        size: 4
        description: "Byte1-2: Enable bits, Byte3-4: Occupancy bits"
        format: "little_endian"
      - id: 0x07
        type: 0xFF
        name: "Illumination"
        size: 1
        values:
          bright: 0x01
          dim: 0x00
      - id: 0x08
        type: 0xF4
        name: "Detection Status"
        size: 2
        description: "Byte1: 02, Byte2: 00-Normal, 01-Undetectable"
      - id: 0x0A
        type: 0xEF
        name: "Timestamp"
        size: 4
        unit: "Unix timestamp"
        format: "little_endian"

  - port: 85
    name: "Alarm Report"
    description: "Threshold alarm notifications"
    channels:
      - id: 0x83
        type: 0x67
        name: "Temperature Threshold"
        size: 3
        description: "Byte1-2: Value, Byte3: Alarm status"
        unit: "°C"
        resolution: 0.1
        signed: true
      - id: 0x84
        type: 0x68
        name: "Humidity Threshold"
        size: 2
        description: "Byte1: Value, Byte2: Alarm status"
        unit: "%"
        resolution: 0.5

  - port: 85
    name: "Historical Data"
    description: "Data retransmission and stored data"
    channels:
      - id: 0x20
        type: 0xCE
        name: "Historical Data"
        size: 9
        description: "Timestamp + Data type + Values"
        format: "little_endian"

downlinks:
  - port: 85
    name: "Reporting Mode"
    channel: 0xF9
    type: 0x10
    size: 1
    values:
      from_now_on: 0x00
      on_the_dot: 0x01

  - port: 85
    name: "Detection Mode"
    channel: 0xF9
    type: 0x6B
    size: 1
    values:
      auto: 0x00
      always: 0x01

  - port: 85
    name: "Immediate Detection"
    channel: 0xF9
    type: 0x6C
    size: 1
    value: 0xFF

  - port: 85
    name: "Reset"
    channel: 0xF9
    type: 0x6E
    size: 1
    value: 0xFF

  - port: 85
    name: "Reboot"
    channel: 0xFF
    type: 0x10
    size: 1
    value: 0xFF

  - port: 85
    name: "Reporting Interval"
    channel: 0xFF
    type: 0x8E
    size: 3
    format: "00 + little_endian_uint16"
    unit: "minutes"
    range: [2, 1440]

  - port: 85
    name: "Detection Interval"
    channel: 0xFF
    type: 0x02
    size: 2
    unit: "minutes"
    range: [2, 60]
    format: "little_endian"

  - port: 85
    name: "Illuminance Collection"
    channel: 0xFF
    type: 0x06
    size: 9
    description: "1C + Dark(2) + Light(2) + 00000000"

  - port: 85
    name: "Data Storage"
    channel: 0xFF
    type: 0x68
    size: 1
    values:
      enable: 0x01
      disable: 0x00

  - port: 85
    name: "Data Retransmission"
    channel: 0xFF
    type: 0x69
    size: 1
    values:
      enable: 0x01
      disable: 0x00

  - port: 85
    name: "Retransmission Interval"
    channel: 0xFF
    type: 0x6A
    size: 3
    format: "00 + little_endian_uint16"
    unit: "seconds"
    range: [30, 1200]

  - port: 85
    name: "Threshold Setting"
    channel: 0xFF
    type: 0x06
    size: 9
    description: "Complex threshold configuration"

  - port: 85
    name: "ADR Mode"
    channel: 0xFF
    type: 0x40
    size: 1
    values:
      enable: 0x01
      disable: 0x00

  - port: 85
    name: "Application Port"
    channel: 0xFF
    type: 0x65
    size: 1
    range: [1, 223]

  - port: 85
    name: "D2D Feature"
    channel: 0xFF
    type: 0x84
    size: 1
    values:
      enable: 0x01
      disable: 0x00

  - port: 85
    name: "D2D Key"
    channel: 0xFF
    type: 0x35
    size: 8
    description: "First 16 digits"

  - port: 85
    name: "D2D Settings"
    channel: 0xFF
    type: 0x96
    size: 8
    description: "Complex D2D configuration"

  - port: 85
    name: "Historical Data Enquiry Point"
    channel: 0xFD
    type: 0x6B
    size: 4
    description: "Unix timestamp"

  - port: 85
    name: "Historical Data Enquiry Range"
    channel: 0xFD
    type: 0x6C
    size: 8
    description: "Start + End timestamps"

  - port: 85
    name: "Stop Query Data"
    channel: 0xFD
    type: 0x6D
    size: 1
    value: 0xFF

special_handling:
  crc_required: false
  reset_events: true
  battery_monitoring: true
  signed_values:
    - "temperature"
    - "temperature_threshold"
  little_endian_fields:
    - "temperature"
    - "people_counting"
    - "desk_occupancy"
    - "timestamp"
    - "reporting_interval"
    - "detection_interval"

measurement_units:
  temperature: "°C"
  humidity: "%RH"
  battery: "%"
  people_count: "persons"
  illumination: "Bright/Dim"
  timestamp: "Unix timestamp"
  interval: "minutes"
