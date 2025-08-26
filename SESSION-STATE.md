# Session State v2.8.2

## ⚠️ READ ONLY FILE WARNING ⚠️ (NEVER IGNORE)
- this file it's a read only file, execpt for the specific command `save to default session`
- when the a session is save to default:
   1) increase the version
   2) update all the dynamic sections
   3) populate the section `Session Override` with the difference of the local session with the session file
   4) DON'T MODIFY ANYTHING ELSE

## Root Directory
```
C:\Project\AI Project\decoders.AI\
```

## ⚠️ Critical Constraints ⚠️ (NEVER IGNORE)
- **Path Restriction**: NEVER access folders above ROOT
- **Edit Policy**: Only edit/run/create when directly asked
- **Language**: English ONLY for all responses
- **Path Format**: Always use relative paths from ROOT
- **Response Mode**: Concise by default, detailed when requested

## Awaiting Input
- **PDF Upload**: For new driver generation
- **Driver Updates**: For existing driver modifications
- **Test Management**: Update physical test status
- **Framework Updates**: For system enhancements
- **Documentation**: For guide improvements
- **Statistics**: Real-time channel/driver tracking

## Response Additions **FOR EVERY RESPONSE**
- at the end of the process produce in sequence:
  1) if modified file > 0 then render git commands snippet by `Git Workflow`
  2) detailed statistics about token used by this action with the progressive totals 

## Session Override
```
# Updated: 2025-08-25 19:45:00
# Template v2.3.6: Added [MODEL]-REQ.md generation to workflow
# Enhanced: Generation process now creates request file for reproduction
# Workflow: 14 steps including documentation + generation request
# Phase 4: Added "Generation Request" to expected deliverables
# Quality: Added mandatory REQ file to checklist
# FRAMEWORK.md: v2.3.0 (critical Berry patterns documented)
# TEMPLATE: v2.3.5 → v2.3.6 (REQ file workflow added)
# Total files: 73 (16 framework + 57 drivers)
# WS52x: v1.5.2 stable + WS52x-REQ.md generated as example
# Total drivers: 17 (all framework compliant + reproducible)
# Total channels: 386 (100% coverage maintained)
# Session token usage: ~72,800 progressive total
# Generation completeness: All drivers now have reproduction instructions
```

## Git Workflow
```bash
# Driver files (single line)
git add vendor/vendor_name/MODEL.be vendor/vendor_name/MODEL.md vendor/vendor_name/MODEL-MAP.md

# Framework files (one per line)
git add GENERATED-DRIVER-LIST.md
git add SESSION-STATE.md
git add emoji-reference.md

# Commit template
git commit -m "(AI) [MODEL|MODULE] v1.0.0 (FW v2.1.12) <title>
<description>
<token usage statististc>
"

# NO PUSH
```

## System Status (Dynamic)
- **Framework**: ✅ LwDecode v2.2.9 Stable (latest)
- **Template**: ✅ v2.3.4 RSSI/FPort Field Consistency (latest)
- **File System**: ✅ Complete Structure Mapped (72 files)
- **Dependencies**: ✅ All Core Documents Loaded and Updated
- **Performance**: ✅ <5ms Average Decode Time
- **Memory**: ✅ ESP32 Optimized (<600 bytes/decode)
- **Tokens**: Progressive session tracking active (~42,500 total)

## File Structure (Dynamic)
```
ROOT/
├── Core Framework (15 files)
│   ├── SESSION-STATE.md           ← This file v2.8.0
│   ├── DEVELOPER-PROMPT.md        ← Template v2.3.4 (updated)
│   ├── README.md                  ← Framework overview
│   ├── FRAMEWORK.md               ← Implementation guide (updated)
│   ├── LwDecode.be               ← Core framework code v2.2.9
│   ├── emoji-reference.md         ← 42 emoji mappings v1.08
│   ├── GENERATED-DRIVER-LIST.md   ← 17 drivers registry
│   ├── BERRY-CUSTOM-LANGUAGE-REFERENCE.md ← Berry syntax v1.2.0
│   └── [other framework files]
└── Driver Storage (57 files)
    ├── vendor/dragino/ (24 files)   ← 8 drivers + docs + MAP
    ├── vendor/milesight/ (21 files) ← 6 drivers + docs + MAP + WS101 regeneration
    ├── vendor/mutelcor/ (4 files)   ← 1 driver + docs + MAP + report
    ├── vendor/micropelt/ (4 files)  ← 1 driver + docs + MAP + report
    └── vendor/watteco/ (4 files)    ← 1 driver + docs + MAP + report
```

## Current Statistics (Dynamic)
- **Total Files**: 72 (15 framework + 57 drivers)
- **Active Drivers**: 17 (.be files)
- **Documentation**: 17 (.md files)
- **Reports**: 12 (generation reports, +1 WS101)
- **MAP Cache**: 15 (protocol specs, WS101 refreshed)
- **Vendors**: 5 (Dragino, Milesight, Mutelcor, Micropelt, Watteco)
- **Total Channels**: 386 (100% coverage, +8 WS101 enhanced)
- **Physical Tests**: 1 running (6% coverage)
- **Success Rate**: 99.7%

## Operational Capabilities (Dynamic)
- **PDF Analysis**: Extract specs + MAP caching
- **FROM_URL Generation**: TTN repository, online docs, GitHub
- **Driver Generation**: Complete uplink/downlink coverage
- **Berry Compliance**: Reserved word validation + F-string syntax checking v1.2.0
- **Memory Optimization**: ESP32 constraints adherence
- **Global Storage**: Multi-node persistence
- **Command System**: Lw prefix enforcement
- **Error Recovery**: Stack traces + retry logic
- **Documentation**: Complete test examples
- **Emoji System**: 42 sensor formatters
- **Physical Testing**: Test status tracking (1 driver running)
- **Version Control**: Automated git workflow integration
- **Filesystem Safety**: ESP32 flat structure enforcement
- **Session Management**: Consolidated state tracking v2.8.0
- **Multi-Vendor Support**: 5 vendor frameworks
- **Advanced Protocols**: FFT analysis, ML integration, energy harvesting
- **Datasheet Integration**: Live datasheet fetching and MAP refresh
- **Template Consistency**: RSSI/FPort field naming standardization
- **Framework Documentation**: Complete API reference v2.2.9

## Ready State (Dynamic)
- ✅ Framework v2.2.9 loaded and operational (latest)
- ✅ Template v2.3.4 RSSI/FPort Field Consistency (latest)
- ✅ Complete file system mapped (72 files verified)
- ✅ All 15 core documents loaded and updated in memory
- ✅ Driver registry updated with 17 drivers
- ✅ Physical test tracking active (1 driver running)
- ✅ Error recovery patterns active
- ✅ Memory optimization patterns loaded
- ✅ Command standardization enforced (Lw prefix)
- ✅ Git workflow integration configured
- ✅ F-string syntax validation active v1.2.0
- ✅ ESP32 filesystem constraints enforced
- ✅ Global node storage patterns loaded
- ✅ Emoji reference system v1.08 active (42 emojis)
- ✅ Simulated payload support enabled
- ✅ Session state consolidated v2.8.0
- ✅ FROM_URL capability: TTN repository, online documentation
- ✅ Multi-vendor framework support (5 vendors)
- ✅ Advanced sensor protocols: vibration, ML, energy harvesting
- ✅ Live datasheet integration and MAP cache refresh capability
- ✅ Enhanced driver regeneration with complete feature tracking
- ✅ Template/Framework consistency: RSSI/FPort field naming aligned
- ✅ Complete API documentation and reference guides loaded


---
*Session State v2.8.2 - Framework v2.2.9 + Template v2.3.4*  
*Last Updated: 2025-08-25*  
*Status: WS52x v1.5.2 - UI enhancements with smart energy scaling*