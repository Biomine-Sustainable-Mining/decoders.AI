# Milesight WS101 Protocol MAP
# Updated: 2025-08-25 10:45:00 | Device Version: Latest
# Source: Official Milesight Datasheet 2024-2025

device_info:
  vendor: Milesight
  model: WS101
  type: Smart Button
  lorawan_version: 1.0.3
  regions: [EU868, US915, AU915, AS923, KR920, IN865, RU864, CN470]
  official_link: https://www.milesight.com/iot/product/lorawan-sensor/ws101
  datasheet: https://resource.milesight.com/milesight/iot/document/ws101-datasheet-en.pdf

hardware_info:
  battery: 1650mAh ER14335 Li-SOCl2
  battery_life: 9.5 years (SF7, EU868, 10 presses/day)
  dimensions: "50 × 50 × 18 mm"
  weight: 38.8g
  operating_temp: "-20°C to 60°C"
  ip_rating: IP30
  antenna: Internal
  tx_power: "16 dBm (868 MHz)/22 dBm (915 MHz)/19 dBm (470 MHz)"
  sensitivity: "-137 dBm @300bps"
  button_modes: [Short Press, Long Press, Double Press]
  features: [NFC Configuration, LED Indicator, Buzzer, D2D Protocol]

uplinks:
  - port: 85
    type: Data
    name: "Device Information & Button Events"
    channels:
      # Button events (primary function)
      - id: 0xFF
        type: 0x2E
        name: "Button Message"
        size: 1
        values:
          0x01: "Mode 1 (Short Press)"
          0x02: "Mode 2 (Long Press)"  
          0x03: "Mode 3 (Double Press)"
          
      # Battery monitoring
      - id: 0x01
        type: 0x75
        name: "Battery Level"
        size: 1
        unit: "%"
        range: [0, 100]
        
      # Device information channels
      - id: 0xFF
        type: 0x01
        name: "Protocol Version"
        size: 1
        values:
          0x01: "V1"
          
      - id: 0xFF
        type: 0x08
        name: "Device Serial Number"
        size: 6
        format: "hex"
        
      - id: 0xFF
        type: 0x09
        name: "Hardware Version"
        size: 2
        format: "major.minor"
        
      - id: 0xFF
        type: 0x0A
        name: "Software Version"
        size: 2
        format: "major.minor"
        
      - id: 0xFF
        type: 0x0B
        name: "Power On Event"
        size: 0
        description: "Device startup indicator"
        
      - id: 0xFF
        type: 0x0F
        name: "Device Class"
        size: 1
        values:
          0x00: "Class A"
          0x01: "Class B"
          0x02: "Class C"

downlinks:
  - command: "Set Reporting Interval"
    hex_prefix: "FF03"
    parameters:
      - name: "seconds"
        type: "uint16"
        range: [60, 64800]  # 1 minute to 18 hours
        endian: "little"
        unit: "seconds"
        default: 1080
        
  - command: "Reboot Device"
    hex_prefix: "FF10"
    parameters:
      - name: "reserved"
        type: "fixed"
        value: "FF"
        description: "Fixed parameter for device reboot"
        
  - command: "Set LED Indicator"
    hex_prefix: "FF2F"
    parameters:
      - name: "enable"
        type: "uint8"
        values:
          disable: "00"
          enable: "01"
        description: "Enable/disable LED indicator for button presses"
          
  - command: "Set Double Press Mode"
    hex_prefix: "FF74"
    parameters:
      - name: "enable"
        type: "uint8"
        values:
          disable: "00"
          enable: "01"
        description: "Enable/disable double press detection"
          
  - command: "Set Buzzer"
    hex_prefix: "FF3E"
    parameters:
      - name: "enable"
        type: "uint8"
        values:
          disable: "00"
          enable: "01"
        description: "Enable/disable buzzer feedback for button presses"

special_handling:
  crc_required: false
  reset_events: true
  button_events: true
  battery_monitoring: true
  low_battery_threshold: 10
  default_reporting_interval: 1080
  nfc_configuration: true
  d2d_protocol: true
  emergency_button: true
  
button_behavior:
  short_press: "< 2 seconds"
  long_press: ">= 2 seconds, < 10 seconds"  
  double_press: "Two presses within 2 seconds"
  press_debounce: "50ms minimum"
  
measurement_units:
  battery: "%"
  rssi: "dBm"
  interval: "seconds"
  temperature: "°C"
  
device_variants:
  scene_button:
    color: "White"
    primary_use: "Scene control, automation triggers"
  sos_button:
    color: "Red" 
    primary_use: "Emergency alarms, panic button"
    
applications:
  - "Smart homes (scene control)"
  - "Smart offices (meeting room booking, help desk)"
  - "Hotels (housekeeping, service requests)"
  - "Schools (emergency alerts, maintenance)"
  - "Healthcare (nurse call, patient assistance)"
  - "Retail (inventory requests, staff alerts)"
