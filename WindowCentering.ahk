#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

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

WindowExists(WinTitle := "A") {
    return WinExist(WinTitle) != 0
}

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

; Center window horizontally and vertically
^!c:: {  ; Ctrl+Alt+C hotkey
    WinGetPos(&WinX, &WinY, &WinW, &WinH, "A")
    ActiveMonitor := GetActiveMonitor(WinX, WinY)
    MonitorGet(ActiveMonitor, &Left, &Top, &Right, &Bottom)
    CenterX := Left + (Right - Left - WinW) // 2
    CenterY := Top + (Bottom - Top - WinH) // 2
    MoveWindowSafely(CenterX, CenterY)
}

; Center window horizontally only
^!h:: {  ; Ctrl+Alt+H hotkey
    WinGetPos(&WinX, &WinY, &WinW, &WinH, "A")
    ActiveMonitor := GetActiveMonitor(WinX, WinY)
    MonitorGet(ActiveMonitor, &Left, &Top, &Right, &Bottom)
    CenterX := Left + (Right - Left - WinW) // 2
    MoveWindowSafely(CenterX, WinY)
}

; Center window vertically only
^!v:: {  ; Ctrl+Alt+V hotkey
    WinGetPos(&WinX, &WinY, &WinW, &WinH, "A")
    ActiveMonitor := GetActiveMonitor(WinX, WinY)
    MonitorGet(ActiveMonitor, &Left, &Top, &Right, &Bottom)
    CenterY := Top + (Bottom - Top - WinH) // 2
    MoveWindowSafely(WinX, CenterY)
}

; Center window horizontally and align to top of monitor
^!t:: {  ; Ctrl+Alt+T hotkey
    WinGetPos(&WinX, &WinY, &WinW, &WinH, "A")
    ActiveMonitor := GetActiveMonitor(WinX, WinY)
    MonitorGet(ActiveMonitor, &Left, &Top, &Right, &Bottom)
    CenterX := Left + (Right - Left - WinW) // 2
    MoveWindowSafely(CenterX, Top)
}

; Center window horizontally and align to bottom of monitor
^!b:: {  ; Ctrl+Alt+B hotkey
    WinGetPos(&WinX, &WinY, &WinW, &WinH, "A")
    ActiveMonitor := GetActiveMonitor(WinX, WinY)
    MonitorGet(ActiveMonitor, &Left, &Top, &Right, &Bottom)
    CenterX := Left + (Right - Left - WinW) // 2
    BottomY := Bottom - WinH
    MoveWindowSafely(CenterX, BottomY)
}

; Center window vertically and align to left of monitor
^!l:: {  ; Ctrl+Alt+L hotkey
    WinGetPos(&WinX, &WinY, &WinW, &WinH, "A")
    ActiveMonitor := GetActiveMonitor(WinX, WinY)
    MonitorGet(ActiveMonitor, &Left, &Top, &Right, &Bottom)
    CenterY := Top + (Bottom - Top - WinH) // 2
    MoveWindowSafely(Left, CenterY)
}

; Center window vertically and align to right of monitor
^!r:: {  ; Ctrl+Alt+R hotkey
    WinGetPos(&WinX, &WinY, &WinW, &WinH, "A")
    ActiveMonitor := GetActiveMonitor(WinX, WinY)
    MonitorGet(ActiveMonitor, &Left, &Top, &Right, &Bottom)
    RightX := Right - WinW
    CenterY := Top + (Bottom - Top - WinH) // 2
    MoveWindowSafely(RightX, CenterY)
}