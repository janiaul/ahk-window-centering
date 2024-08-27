# Window Centering AHK Script

This AutoHotkey (AHK) script provides hotkeys for centering and aligning windows on multiple monitors. It's designed to work with AHK v2 and includes compatibility with [SmartTaskbar](https://github.com/Oliviaophia/SmartTaskbar) on Windows 11.

## Features

- Multi-monitor support
- Compatible with SmartTaskbar on Windows 11
- Adjusts for taskbar height, including auto-hide taskbars
- Improved error handling for access-restricted windows

## Hotkeys

- `Ctrl + Alt + C`: Center window both horizontally and vertically
- `Ctrl + Alt + H`: Center window horizontally only
- `Ctrl + Alt + V`: Center window vertically only
- `Ctrl + Alt + T`: Center window horizontally and align to top of monitor
- `Ctrl + Alt + B`: Center window horizontally and align to bottom of monitor
- `Ctrl + Alt + L`: Center window vertically and align to left of monitor
- `Ctrl + Alt + R`: Center window vertically and align to right of monitor

## Compatibility

- Tested on Windows 11
- Uses a fixed height calculation for taskbar when SmartTaskbar is active

## Requirements

- AutoHotkey v2.0 or later

## License

This project is licensed under the MIT License - see the LICENSE file for details.