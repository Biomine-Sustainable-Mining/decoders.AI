# Auto-Update System Setup Guide

## 🔧 Installation

1. **Install Dependencies**
   ```bash
   cd C:\Project\AI Project\decoders.AI\decoders.AI
   pip install -r requirements.txt
   ```

2. **Test the System**
   ```bash
   python auto_update.py
   ```

3. **Start File Watcher** (optional - for real-time monitoring)
   ```bash
   python file_watcher.py
   ```

## 🎯 Usage

### Manual Trigger
```python
from auto_update import trigger_auto_update
trigger_auto_update()  # Update SESSION-STATE.md now
```

### Automatic Monitoring
- Modify any ROOT .md file (except SESSION-STATE.md)
- System automatically updates SESSION-STATE.md
- Add SESSION-STATE.md to your commit

## 📋 Monitored Files

✅ **Triggers Auto-Update:**
- GENERATED-DRIVER-LIST.md → Updates statistics
- DEVELOPER-PROMPT.md → Updates template version  
- README.md → Updates framework status
- FRAMEWORK.md → Updates capabilities
- emoji-reference.md → Updates emoji count
- PR-DESCRIPTION.md → Updates template status
- EXAMPLE-PROMPTS.md → Updates documentation

❌ **Ignored:**
- SESSION-STATE.md → Prevents infinite loops
- vendor/*.md → Not in ROOT directory  
- *.be, *.py files → Not markdown

## 🔄 Auto-Update Process

1. **File Modified** → ROOT .md file saved
2. **Debouncing** → Wait 2 seconds for multiple changes
3. **Statistics** → Extract from GENERATED-DRIVER-LIST.md
4. **Template Version** → Extract from DEVELOPER-PROMPT.md  
5. **File Counts** → Scan filesystem automatically
6. **SESSION-STATE.md** → Generate v2.1.2 with new data
7. **Git Ready** → Add SESSION-STATE.md to current commit

## 🚨 Safety Features

- **Loop Prevention** → SESSION-STATE.md modifications ignored
- **Debouncing** → Max 1 update per 2 seconds per file
- **Error Handling** → Graceful fallback if update fails
- **Backup Protection** → Original content preserved on error

## 🧪 Testing

```bash
# Test 1: Manual update
python -c "from auto_update import trigger_auto_update; trigger_auto_update()"

# Test 2: File modification simulation  
echo "# Test" >> README.md
# Should trigger auto-update

# Test 3: Check SESSION-STATE.md version
grep "Session State v" SESSION-STATE.md
# Should show v2.1.2 with auto-update status
```
