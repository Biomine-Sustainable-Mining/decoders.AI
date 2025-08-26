# Milesight WS202 Driver Generation Request
## Version: 2.3.6 | Framework: LwDecode v2.2.9 | Platform: Tasmota Berry

```yaml
# Milesight WS202 Driver Generation Request
vendor: "Milesight"
model: "WS202"  
type: "PIR & Light Sensor"
version: "1.3.0"
framework: "v2.2.9"
template: "v2.3.6"
upgrade_type: "Framework + Template"

features:
  - PIR motion detection (occupied/vacant)
  - Light level sensing (bright/dark)
  - Battery monitoring with percentage
  - Device information tracking
  - Power-on event detection

critical_patterns:
  - Framework v2.2.9 compatibility (RSSI/FPort uppercase)
  - Template v2.3.6 enhanced error handling
  - Global storage with recovery patterns
  - Display error protection with try/catch

coverage:
  uplinks: "9/9 (100%)"
  downlinks: "2/2 (100%)"
  test_scenarios: "6 scenarios"
```
