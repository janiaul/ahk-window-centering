#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

; Determine which monitor a window is on based on its coordinates
GetActiveMonitor(X, Y) {
    MonitorCount := MonitorGetCount()
    Loop MonitorCount {
        MonitorGet(A_Index, &Left, &Top, &Right, &Bottom)
        if (X >= Left && X < Right && Y >= Top && Y < Bottom) {
            return A_Index
        }
    }
    return 1  ; Default to primary monitor if not found
}

; Check if a window with the given title exists
WindowExists(WinTitle := "A") {
    return WinExist(WinTitle) != 0
}

; Safely move a window, handling potential errors
MoveWindowSafely(X, Y, W := "", H := "", WinTitle := "A") {
    if (!WindowExists(WinTitle)) {
        MsgBox("The specified window does not exist.", "Error", 16)
        return
    }
    try {
        if (W = "" and H = "") {
            WinMove(X, Y, , , WinTitle)
        } else if (W = "") {
            WinMove(X, Y, , H, WinTitle)
        } else if (H = "") {
            WinMove(X, Y, W, , WinTitle)
        } else {
            WinMove(X, Y, W, H, WinTitle)
        }
    } catch as err {
        if (InStr(err.Message, "Access is denied")) {
            MsgBox("Unable to move this window due to system restrictions. Try running the script as administrator.", "Access Denied", 48)
        } else {
            MsgBox("An unexpected error occurred: " . err.Message, "Error", 16)
        }
    }
}

; Get the height of the taskbar, accounting for display scaling
GetTaskbarHeight() {
    ; Try to get the taskbar window
    if (taskbar := WinExist("ahk_class Shell_TrayWnd")) {
        WinGetPos(&Left, &Top, &Width, &Height, taskbar)
        return Height
    }
    
    ; If taskbar window not found, estimate based on primary monitor resolution and scaling
    MonitorGetWorkArea(MonitorGetPrimary(), &Left, &Top, &Right, &Bottom)
    
    ; Get the display DPI scaling
    hDC := DllCall("GetDC", "Ptr", 0)
    dpi := DllCall("GetDeviceCaps", "Ptr", hDC, "Int", 88)  ; LOGPIXELSX
    DllCall("ReleaseDC", "Ptr", 0, "Ptr", hDC)
    scaleFactor := dpi / 96  ; 96 is the base DPI
    
    ; Base taskbar height is 48 pixels at 100% scaling
    baseHeight := 48
    
    ; Adjust height based on scaling factor
    return Round(baseHeight * scaleFactor)
}

; Check if the given monitor is the primary monitor
IsPrimaryMonitor(MonitorIndex) {
    MonitorInfo := MonitorGetPrimary()
    return MonitorIndex = MonitorInfo
}

; Check if SmartTaskbar is running
IsSmartTaskbarRunning() {
    return ProcessExist("SmartTaskbar.exe")
}

; Get the adjusted work area for a monitor, accounting for SmartTaskbar if running
GetAdjustedWorkArea(MonitorIndex) {
    MonitorGetWorkArea(MonitorIndex, &Left, &Top, &Right, &Bottom)
    if (IsPrimaryMonitor(MonitorIndex) && IsSmartTaskbarRunning()) {
        TaskbarHeight := GetTaskbarHeight()
        Bottom -= TaskbarHeight
    }
    return [Left, Top, Right, Bottom]
}

; Get information about the currently focused window
GetFocusedWindowInfo() {
    if (!WindowExists("A")) {
        throw Error("No active window found.")
    }
    WinGetPos(&WinX, &WinY, &WinW, &WinH, "A")
    return {X: WinX, Y: WinY, W: WinW, H: WinH}
}

; Center window horizontally and vertically
^!c:: {
    try {
        WinInfo := GetFocusedWindowInfo()
        ActiveMonitor := GetActiveMonitor(WinInfo.X, WinInfo.Y)
        WorkArea := GetAdjustedWorkArea(ActiveMonitor)
        CenterX := WorkArea[1] + (WorkArea[3] - WorkArea[1] - WinInfo.W) // 2
        CenterY := WorkArea[2] + (WorkArea[4] - WorkArea[2] - WinInfo.H) // 2
        MoveWindowSafely(CenterX, CenterY)
    } catch as err {
        MsgBox("Error: " . err.Message, "Window Centering Error", 16)
    }
}

; Center window horizontally only
^!h:: {
    try {
        WinInfo := GetFocusedWindowInfo()
        ActiveMonitor := GetActiveMonitor(WinInfo.X, WinInfo.Y)
        WorkArea := GetAdjustedWorkArea(ActiveMonitor)
        CenterX := WorkArea[1] + (WorkArea[3] - WorkArea[1] - WinInfo.W) // 2
        MoveWindowSafely(CenterX, WinInfo.Y)
    } catch as err {
        MsgBox("Error: " . err.Message, "Window Centering Error", 16)
    }
}

; Center window vertically only
^!v:: {
    try {
        WinInfo := GetFocusedWindowInfo()
        ActiveMonitor := GetActiveMonitor(WinInfo.X, WinInfo.Y)
        WorkArea := GetAdjustedWorkArea(ActiveMonitor)
        CenterY := WorkArea[2] + (WorkArea[4] - WorkArea[2] - WinInfo.H) // 2
        MoveWindowSafely(WinInfo.X, CenterY)
    } catch as err {
        MsgBox("Error: " . err.Message, "Window Centering Error", 16)
    }
}

; Center window horizontally and align to top of monitor
^!t:: {
    try {
        WinInfo := GetFocusedWindowInfo()
        ActiveMonitor := GetActiveMonitor(WinInfo.X, WinInfo.Y)
        WorkArea := GetAdjustedWorkArea(ActiveMonitor)
        CenterX := WorkArea[1] + (WorkArea[3] - WorkArea[1] - WinInfo.W) // 2
        TopY := WorkArea[2]
        MoveWindowSafely(CenterX, TopY)
    } catch as err {
        MsgBox("Error: " . err.Message, "Window Centering Error", 16)
    }
}

; Center window horizontally and align to bottom of monitor
^!b:: {
    try {
        WinInfo := GetFocusedWindowInfo()
        ActiveMonitor := GetActiveMonitor(WinInfo.X, WinInfo.Y)
        WorkArea := GetAdjustedWorkArea(ActiveMonitor)
        CenterX := WorkArea[1] + (WorkArea[3] - WorkArea[1] - WinInfo.W) // 2
        BottomY := WorkArea[4] - WinInfo.H
        MoveWindowSafely(CenterX, BottomY)
    } catch as err {
        MsgBox("Error: " . err.Message, "Window Centering Error", 16)
    }
}

; Center window vertically and align to left of monitor
^!l:: {
    try {
        WinInfo := GetFocusedWindowInfo()
        ActiveMonitor := GetActiveMonitor(WinInfo.X, WinInfo.Y)
        WorkArea := GetAdjustedWorkArea(ActiveMonitor)
        CenterY := WorkArea[2] + (WorkArea[4] - WorkArea[2] - WinInfo.H) // 2
        MoveWindowSafely(WorkArea[1], CenterY)
    } catch as err {
        MsgBox("Error: " . err.Message, "Window Centering Error", 16)
    }
}

; Center window vertically and align to right of monitor
^!r:: {
    try {
        WinInfo := GetFocusedWindowInfo()
        ActiveMonitor := GetActiveMonitor(WinInfo.X, WinInfo.Y)
        WorkArea := GetAdjustedWorkArea(ActiveMonitor)
        RightX := WorkArea[3] - WinInfo.W
        CenterY := WorkArea[2] + (WorkArea[4] - WorkArea[2] - WinInfo.H) // 2
        MoveWindowSafely(RightX, CenterY)
    } catch as err {
        MsgBox("Error: " . err.Message, "Window Centering Error", 16)
    }
}