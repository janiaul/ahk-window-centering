# Advanced Window Positioning AHK Script

This AutoHotkey v2 script provides comprehensive window positioning and alignment capabilities across multiple monitors. It intelligently handles various taskbar configurations and third-party modifications for precise window placement.

## Features

- **Multi-monitor support** with automatic monitor detection
- **Smart taskbar handling** for various configurations:
  - Standard Windows taskbar
  - [SmartTaskbar](https://github.com/Oliviaophia/SmartTaskbar) compatibility
  - [Windhawk](https://github.com/ramensoftware/windhawk) taskbar modifications (auto-hide when maximized)
- **Precise positioning** with window frame compensation
- **Enhanced bottom snapping** with configurable taskbar gap
- **Comprehensive error handling** for restricted windows
- **9-point grid positioning** (corners, edges, center)

## Hotkeys

### Basic Positioning
- `Ctrl + Shift + Win + S`: **Center** - Center window horizontally and vertically
- `Ctrl + Shift + Win + W`: **Top** - Center horizontally, align to top
- `Ctrl + Shift + Win + X`: **Bottom** - Center horizontally, align to bottom (with taskbar gap)
- `Ctrl + Shift + Win + A`: **Left** - Center vertically, align to left
- `Ctrl + Shift + Win + D`: **Right** - Center vertically, align to right

### Corner Positioning
- `Ctrl + Shift + Win + Q`: **Top-left** corner
- `Ctrl + Shift + Win + E`: **Top-right** corner
- `Ctrl + Shift + Win + Z`: **Bottom-left** corner (with taskbar gap)
- `Ctrl + Shift + Win + C`: **Bottom-right** corner (with taskbar gap)

## Smart Taskbar Integration

The script automatically detects and adjusts for:

### SmartTaskbar
- Automatically hides taskbar when no windows are maximized on primary monitor
- Script compensates by reducing available work area when taskbar is hidden

### Windhawk Modifications
- Detects "Taskbar auto-hide when maximized" mod
- Reads configuration from `C:\ProgramData\Windhawk\userprofile.json`
- Adjusts positioning when taskbar auto-hides with maximized windows

## Configuration

### Taskbar Gap
Modify the `TASKBAR_GAP` variable at the top of the script to adjust spacing from taskbar:

```autohotkey
global TASKBAR_GAP := 1  ; Pixels between window and taskbar
```

### Advanced Features

- **Window frame detection** - Compensates for window decorations for pixel-perfect positioning
- **Monitor detection** - Uses both window coordinates and Windows API for accurate monitor identification
- **Work area calculation** - Dynamically adjusts for taskbar visibility and third-party modifications
- **Access control handling** - Graceful error handling for system-restricted windows

## Requirements

- **AutoHotkey v2.0** or later
- **Windows 10/11** (tested primarily on Windows 11)

## Installation

1. Download and install [AutoHotkey v2](https://www.autohotkey.com/)
2. Save the script as `WindowPositioning.ahk`
3. Double-click to run, or set to start with Windows

## Compatibility Notes

- Works with native Windows taskbar auto-hide
- Compatible with SmartTaskbar third-party application  
- Supports Windhawk taskbar modifications
- Handles high-DPI displays and multiple monitor setups
- Gracefully handles windows that cannot be moved (system dialogs, etc.)

## Troubleshooting

### "Access is denied" errors
Some system windows cannot be moved. The script will show a message suggesting to run as administrator if needed.

### Incorrect positioning
If windows aren't positioning correctly:
1. Check if third-party taskbar modifications are properly detected
2. Adjust `TASKBAR_GAP` value if needed
3. Ensure AutoHotkey is running with appropriate permissions

## License

This project is licensed under the MIT License - see the LICENSE file for details.