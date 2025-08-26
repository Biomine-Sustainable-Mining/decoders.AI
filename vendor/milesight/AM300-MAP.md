# Milesight AM300 Protocol MAP
# Generated: 2025-08-26 11:15:00 | Updated from URL specifications
# Source: Milesight AM300 Series User Guide + Product Information

device_info:
  vendor: "Milesight"
  model: "AM300"
  type: "Indoor Air Quality Monitor"
  series: "AM300 Series (AM300/AM307/AM308/AM319)"
  lorawan_version: "1.0.3"
  regions: ["EU868", "US915", "AS923", "AU915", "IN865", "RU864", "KR920"]
  official_link: "https://www.milesight-iot.com/lorawan/sensor/am300/"

hardware_info:
  sensors: "9-in-1 built-in sensors"
  display: "4.2 inch E-ink screen"
  power: "4×2700mAh ER14505 Li-SOCl2 batteries (replaceable)"
  battery_life: "4+ years (configurable reporting interval)"
  installation: ["3M tape", "wall mounting", "86box mounting"]
  operating_temp: "0°C to 45°C"
  operating_humidity: "10% to 90% RH (non-condensing)"
  protection: "IP30"

uplinks:
  - port: 85
    name: "Periodic Data Report"
    description: "Multi-channel sensor readings"
    channels:
      - id: 0x01
        type: 0x75
        name: "Battery"
        size: 1
        unit: "%"
        description: "Battery percentage (0-100%)"
        
      - id: 0x03  
        type: 0x67
        name: "Temperature"
        size: 2
        unit: "°C"
        resolution: 0.1
        range: [-40, 85]
        endian: "little"
        signed: true
        description: "Ambient temperature"
        
      - id: 0x04
        type: 0x68
        name: "Humidity" 
        size: 1
        unit: "%RH"
        resolution: 0.5
        range: [0, 100]
        description: "Relative humidity"
        
      - id: 0x05
        type: 0x02
        name: "PIR"
        size: 1
        values:
          0: "Vacant"
          1: "Occupied"
        description: "Motion detection status"
        
      - id: 0x06
        type: 0xcb
        name: "Light Level"
        size: 1
        unit: "level"
        range: [0, 10]
        description: "Illumination level (0-10 scale)"
        
      - id: 0x06  
        type: 0x10
        name: "Light Level (Alt)"
        size: 1
        unit: "level"
        range: [0, 10]
        description: "Alternative light level format"
        
      - id: 0x07
        type: 0x7d
        name: "CO2"
        size: 2
        unit: "ppm"
        range: [400, 5000]
        endian: "little"
        description: "Carbon dioxide concentration"
        
      - id: 0x08
        type: 0x7d
        name: "TVOC Level"
        size: 2
        unit: "IAQ index"
        resolution: 0.01
        range: [0, 500]
        endian: "little"
        description: "Total volatile organic compounds (index)"
        
      - id: 0x08
        type: 0xe6  
        name: "TVOC Concentration"
        size: 2
        unit: "ppb"
        endian: "little"
        description: "TVOC concentration"
        
      - id: 0x09
        type: 0x73
        name: "Barometric Pressure"
        size: 2
        unit: "hPa"
        resolution: 0.1
        range: [300, 1100]
        endian: "little"
        description: "Atmospheric pressure"
        
      - id: 0x0a
        type: 0x7d
        name: "HCHO"
        size: 2
        unit: "mg/m³"
        resolution: 0.01
        range: [0, 6]
        endian: "little"
        description: "Formaldehyde concentration"
        
      - id: 0x0b
        type: 0x7d
        name: "PM2.5"
        size: 2
        unit: "μg/m³"
        endian: "little"
        description: "Fine particulate matter"
        
      - id: 0x0c
        type: 0x7d
        name: "PM10"
        size: 2
        unit: "μg/m³"
        endian: "little"
        description: "Coarse particulate matter"
        
      - id: 0x0d
        type: 0x7d
        name: "O3"
        size: 2
        unit: "ppm"
        resolution: 0.001
        range: [0, 10]
        endian: "little"
        description: "Ozone concentration"
        
      - id: 0x0e
        type: 0x01
        name: "Buzzer Status"
        size: 1
        values:
          0: "OFF"
          1: "ON" 
        description: "Audio alarm status"
        
      - id: 0x0f
        type: 0x01
        name: "Activity Event"
        size: 1
        description: "Movement activity event"
        
      - id: 0x10
        type: 0x01
        name: "Power Event" 
        size: 1
        description: "Device power-on event"
        
  - port: 85
    name: "Configuration Response"
    description: "Device configuration and info"
    channels:
      - id: 0xff
        type: 0x0b
        name: "Device Info"
        description: "Firmware, hardware, protocol version"
        
  - port: 85
    name: "Historical Data"
    description: "Data retransmission with timestamps"
    features: ["timestamp", "retransmission"]

downlinks:
  - command: "Reporting Interval"
    hex_prefix: "ff"
    code: 0x01
    description: "Set data reporting interval"
    parameters:
      - name: "interval_minutes"
        type: "uint16"
        range: [1, 1440]
        unit: "minutes"
        default: 20
        endian: "little"
        
  - command: "Buzzer Control"  
    hex_prefix: "ff"
    code: 0x0e
    description: "Enable/disable buzzer alarm"
    parameters:
      - name: "buzzer_enable"
        type: "boolean"
        values:
          enable: 0x01
          disable: 0x00
          
  - command: "Screen Control"
    hex_prefix: "ff"
    code: 0x2d
    description: "Turn screen on/off"
    parameters:
      - name: "screen_enable"
        type: "boolean" 
        values:
          on: 0x01
          off: 0x00
          
  - command: "Time Sync"
    hex_prefix: "ff"
    code: 0x02
    description: "Synchronize device time"
    parameters:
      - name: "timestamp"
        type: "uint32"
        unit: "unix_timestamp"
        endian: "little"
        
  - command: "Threshold Alarms"
    hex_prefix: "ff"
    code: 0x03
    description: "Configure threshold-based alarms"
    parameters:
      - name: "parameter_id"
        type: "uint8"
        description: "Sensor parameter to monitor"
      - name: "threshold_value"
        type: "uint16"
        endian: "little"
        
  - command: "Device Reboot"
    hex_prefix: "ff"
    code: 0x10
    description: "Restart device"
    parameters: []

special_handling:
  multi_channel_protocol: true
  crc_required: false
  reset_events: true
  battery_monitoring: true
  timestamp_support: true
  retransmission_support: true
  signed_values: ["temperature"]
  screen_control: true
  buzzer_control: true
  pir_smart_mode: "Screen auto-off after 20min when vacant"
  
measurement_units:
  temperature: "°C"
  humidity: "%RH"
  co2: "ppm"
  pressure: "hPa"
  tvoc_level: "IAQ index"
  tvoc_concentration: "ppb"
  hcho: "mg/m³"
  pm25: "μg/m³"
  pm10: "μg/m³"
  o3: "ppm"
  light_level: "level (0-10)"
  battery: "%"

air_quality_features:
  emoticon_display: "Shows air quality status on screen"
  threshold_alarms: "Configurable for all pollutants"
  real_time_display: "E-ink screen with 30s/60s refresh"
  data_logging: "Local storage with retransmission"
  works_with_well: "WELL Building Standard certified"

calibration_info:
  factory_calibrated: true
  field_calibration: "Supported via ToolBox app"
  sensors_replaceable: "HCHO/O3 sensor replaceable"
  co2_calibration: "NDIR sensor with auto-calibration"
