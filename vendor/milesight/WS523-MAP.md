# Milesight WS523 Protocol MAP
# Generated: 2025-08-26 14:30:00 | Device Version: Latest
# Source: Official Milesight WS523 User Guide V1.3

device_info:
  vendor: Milesight
  model: WS523
  type: Portable Smart Socket
  lorawan_version: 1.0.3
  regions: [EU868, US915, AU915, AS923, KR920, IN865, RU864, CN470]
  official_link: https://www.milesight.com/iot/product/lorawan-sensor/ws523
  datasheet: https://resource.milesight.com/milesight/iot/document/ws523-datasheet-en.pdf

hardware_info:
  power_supply: AC 100-240V 50/60Hz
  max_current: "10A (EU), 16A (UK)"
  dimensions: "50 × 50 × 82 mm"
  weight: 89g
  operating_temp: "-10°C to 55°C"
  ip_rating: IP30
  antenna: Internal
  tx_power: "14 dBm (868 MHz)/22 dBm (915 MHz)"
  sensitivity: "-137 dBm @300bps"
  features: [Power Monitoring, Overcurrent Protection, Remote Control, Energy Recording, Power Outage Alert]

uplinks:
  - port: 85
    type: Data
    name: "Power Monitoring & Device Information"
    channels:
      # Power monitoring channels
      - id: 0x03
        type: 0x74
        name: "Voltage"
        size: 2
        unit: "V"
        resolution: 0.1
        range: [100, 250]
        
      - id: 0x04
        type: 0x80
        name: "Active Power"
        size: 4
        unit: "W"
        signed: true
        range: [-2400, 2400]
        
      - id: 0x05
        type: 0x81

        name: "Power Factor"
        size: 1
        unit: "%"
        range: [0, 100]
        
      - id: 0x06
        type: 0x83
        name: "Energy Consumption"
        size: 4
        unit: "Wh"
        range: [0, 4294967295]
        
      - id: 0x07
        type: 0xC9
        name: "Current"
        size: 2
        unit: "mA"
        range: [0, 16000]
        
      - id: 0x08
        type: 0x70
        name: "Socket State"
        size: 1
        values:
          0x00: "OFF"
          0x01: "ON"
          
      # Device information channels
      - id: 0xFF
        type: 0x01
        name: "Protocol Version"
        size: 1
        values:
          0x01: "V1"
          
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
        type: 0x16
        name: "Device Serial Number"
        size: 8
        format: "hex"
        
      - id: 0xFF
        type: 0x0F
        name: "Device Class"
        size: 1
        values:
          0x00: "Class A"
          0x01: "Class B"
          0x02: "Class C"
          
      # Configuration status channels
      - id: 0xFF
        type: 0x24
        name: "Overcurrent Alarm Config"
        size: 2
        format: "enable_flag,threshold_A"
        
      - id: 0xFF
        type: 0x25
        name: "Button Lock Config"
        size: 2
        format: "lock_state"
        values:
          0x0000: "Unlocked"
          0x8000: "Locked"
          
      - id: 0xFF
        type: 0x26
        name: "Power Recording Config"
        size: 1
        values:
          0x00: "Disabled"
          0x01: "Enabled"
          
      - id: 0xFF
        type: 0x30
        name: "Overcurrent Protection Config"
        size: 2
        format: "enable_flag,threshold_A"
        
      - id: 0xFF
        type: 0x3F
        name: "Power Outage Event"
        size: 0
        description: "Power outage alert (HW v1.2+)"
        
      - id: 0xFE
        type: 0x02
        name: "Reporting Interval"
        size: 2
        unit: "seconds"
        range: [60, 64800]
        
      - id: 0xFF
        type: 0xFE
        name: "Reset Event"
        size: 1
        values:
          0x00: "Power On Reset (POR)"
          0x01: "Brown Out Reset (BOR)"
          0x02: "Watchdog Reset (WDT)"
          0x03: "Command Reset (CMD)"
          
      - id: 0xFF
        type: 0xFF
        name: "TSL Version"
        size: 2
        format: "major.minor"

downlinks:
  - command: "Socket Control"
    hex_prefix: "08"
    parameters:
      - name: "state"
        type: "boolean"
        values:
          on: "FF"
          off: "00"
        description: "Turn socket ON/OFF"
        
  - command: "Set Reporting Interval"
    hex_prefix: "FE02"
    parameters:
      - name: "seconds"
        type: "uint16"
        range: [60, 64800]
        endian: "little"
        description: "Reporting period in seconds"
        
  - command: "Device Reboot"
    hex_prefix: "FF10"
    parameters:
      - name: "reboot"
        type: "fixed"
        value: "FF"
        description: "Reboot device"
        
  - command: "Delay Task"
    hex_prefix: "FE22"
    parameters:
      - name: "delay_seconds"
        type: "uint32"
        range: [1, 4294967295]
        endian: "little"
        description: "Delay before action in seconds"
        
  - command: "Delete Task"
    hex_prefix: "FE23"
    parameters:
      - name: "task_id"
        type: "uint16"
        endian: "little"
        description: "Task ID to delete"
        
  - command: "Overcurrent Alarm Config"
    hex_prefix: "FF24"
    parameters:
      - name: "enable"
        type: "boolean"
        values:
          enable: "01"
          disable: "00"
      - name: "threshold"
        type: "uint8"
        range: [1, 16]
        unit: "A"
        description: "Current threshold in amperes"
        
  - command: "Button Lock Control"
    hex_prefix: "FF25"
    parameters:
      - name: "lock_state"
        type: "uint16"
        endian: "little"
        values:
          unlock: "0000"
          lock: "8000"
        description: "Physical button lock state"
        
  - command: "Power Recording Control"
    hex_prefix: "FF26"
    parameters:
      - name: "enable"
        type: "boolean"
        values:
          enable: "01"
          disable: "00"
        description: "Enable/disable power consumption recording"
        
  - command: "Reset Energy Counter"
    hex_prefix: "FF27"
    parameters:
      - name: "reset"
        type: "fixed"
        value: "00"
        description: "Reset energy consumption counter"
        
  - command: "Request Status"
    hex_prefix: "FF28"
    parameters:
      - name: "status_request"
        type: "fixed"
        value: "00"
        description: "Request device electrical status"
        
  - command: "LED Control"
    hex_prefix: "FF2F"
    parameters:
      - name: "enable"
        type: "boolean"
        values:
          enable: "01"
          disable: "00"
        description: "Control LED indicator"
        
  - command: "Overcurrent Protection Config"
    hex_prefix: "FF30"
    parameters:
      - name: "enable"
        type: "boolean"
        values:
          enable: "01"
          disable: "00"
      - name: "threshold"
        type: "uint8"
        range: [1, 16]
        unit: "A"
        description: "Protection threshold in amperes"

special_handling:
  crc_required: false
  reset_events: true
  power_monitoring: true
  overcurrent_protection: true
  power_outage_alert: true
  delayed_tasks: true
  energy_recording: true
  button_lock: true
  
measurement_units:
  voltage: "V"
  current: "mA"
  power: "W"
  energy: "Wh"
  power_factor: "%"
  interval: "seconds"
  
device_variants:
  WS523:
    type: "Portable"
    plug_type: "Type C (EU), Type G (UK)"
    max_current: "10A (EU), 16A (UK)"
  WS522:
    type: "Wall Mount" 
    plug_type: "Type C (EU), Type G (UK)"
    max_current: "10A (EU), 16A (UK)"
    
applications:
  - "Smart homes (appliance control)"
  - "Energy monitoring and management"
  - "Remote power switching"
  - "Overcurrent protection"
  - "Power outage detection"
  - "Load scheduling and automation"
