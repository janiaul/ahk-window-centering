#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

global TASKBAR_GAP := 1  ; Change this value as needed

; Determine which monitor a window is on based on its coordinates
GetActiveMonitor(X, Y, W := 0, H := 0, WinTitle := "A") {
    if (WinTitle != "") {
        if (hWnd := WinExist(WinTitle)) {
            ; Create RECT structure
            RECT := Buffer(16)
            DllCall("GetWindowRect", "Ptr", hWnd, "Ptr", RECT)

            ; Get monitor from window rect
            MONITOR_DEFAULTTOPRIMARY := 0x1
            hMonitor := DllCall("MonitorFromRect", "Ptr", RECT, "UInt", MONITOR_DEFAULTTOPRIMARY, "Ptr")

            ; Get monitor info
            MONITORINFO := Buffer(40)
            NumPut("UInt", 40, MONITORINFO, 0)  ; cbSize
            if (DllCall("GetMonitorInfo", "Ptr", hMonitor, "Ptr", MONITORINFO)) {
                ; Loop through monitors to find matching one
                loop MonitorGetCount() {
                    MonitorGetWorkArea(A_Index, &Left, &Top, &Right, &Bottom)
                    testRECT := Buffer(16)
                    NumPut("Int", Left, testRECT, 0)
                    NumPut("Int", Top, testRECT, 4)
                    NumPut("Int", Right, testRECT, 8)
                    NumPut("Int", Bottom, testRECT, 12)

                    currHMonitor := DllCall("MonitorFromRect", "Ptr", testRECT, "UInt", MONITOR_DEFAULTTOPRIMARY)
                    if (currHMonitor = hMonitor)
                        return A_Index
                }
            }
        }
    }

    ; Fall back to coordinate-based detection
    PrimaryMonitor := MonitorGetPrimary()
    MonitorCount := MonitorGetCount()

    ; First check primary monitor
    MonitorGetWorkArea(PrimaryMonitor, &Left, &Top, &Right, &Bottom)
    if (X >= Left && X < Right && Y >= Top && Y < Bottom)
        return PrimaryMonitor

    ; Then check other monitors
    loop MonitorCount {
        if (A_Index = PrimaryMonitor)
            continue
        MonitorGetWorkArea(A_Index, &Left, &Top, &Right, &Bottom)
        if (X >= Left && X < Right && Y >= Top && Y < Bottom)
            return A_Index
    }
    return PrimaryMonitor
}

; Check if a window with the given title exists
WindowExists(WinTitle := "A") {
    return WinExist(WinTitle) != 0
}

; Get window frame thickness (for better positioning accuracy)
GetWindowFrameSize(WinTitle := "A") {
    if (!WindowExists(WinTitle)) {
        return { Left: 0, Top: 0, Right: 0, Bottom: 0 }
    }

    try {
        hWnd := WinExist(WinTitle)

        ; Get window rect (including frame)
        WindowRECT := Buffer(16)
        DllCall("GetWindowRect", "Ptr", hWnd, "Ptr", WindowRECT)
        WinLeft := NumGet(WindowRECT, 0, "Int")
        WinTop := NumGet(WindowRECT, 4, "Int")
        WinRight := NumGet(WindowRECT, 8, "Int")
        WinBottom := NumGet(WindowRECT, 12, "Int")

        ; Get client rect (actual usable area)
        ClientRECT := Buffer(16)
        DllCall("GetClientRect", "Ptr", hWnd, "Ptr", ClientRECT)
        ClientWidth := NumGet(ClientRECT, 8, "Int")
        ClientHeight := NumGet(ClientRECT, 12, "Int")

        ; Get client area position
        ClientPOINT := Buffer(8)
        NumPut("Int", 0, ClientPOINT, 0)
        NumPut("Int", 0, ClientPOINT, 4)
        DllCall("ClientToScreen", "Ptr", hWnd, "Ptr", ClientPOINT)
        ClientLeft := NumGet(ClientPOINT, 0, "Int")
        ClientTop := NumGet(ClientPOINT, 4, "Int")

        return {
            Left: ClientLeft - WinLeft,
            Top: ClientTop - WinTop,
            Right: WinRight - (ClientLeft + ClientWidth),
            Bottom: WinBottom - (ClientTop + ClientHeight)
        }
    } catch {
        return { Left: 0, Top: 0, Right: 0, Bottom: 0 }
    }
}

; Enhanced window moving function that accounts for window frames
MoveWindowSafelyEnhanced(X, Y, W := "", H := "", WinTitle := "A", ForceToTaskbar := false) {
    if (!WindowExists(WinTitle)) {
        MsgBox("The specified window does not exist.", "Error", 16)
        return
    }

    try {
        ; Get window frame information for more accurate positioning
        FrameSize := GetWindowFrameSize(WinTitle)

        ; If ForceToTaskbar is true, adjust the Y position to account for potential app-specific margins
        if (ForceToTaskbar) {
            ; Get current window info
            WinGetPos(&CurX, &CurY, &CurW, &CurH, WinTitle)
            ActiveMonitor := GetActiveMonitor(CurX, CurY, CurW, CurH, WinTitle)
            WorkArea := GetAdjustedWorkArea(ActiveMonitor)

            ; Calculate the absolute bottom position (taskbar top) minus the gap
            AbsoluteBottom := WorkArea[4] - TASKBAR_GAP

            ; Try to position the window so its bottom edge is TASKBAR_GAP pixels above the taskbar
            ; Account for window frame
            AdjustedY := AbsoluteBottom - CurH + FrameSize.Bottom

            ; Use the adjusted Y position
            Y := AdjustedY
        }

        if (W = "" and H = "") {
            WinMove(X, Y, , , WinTitle)
        } else if (W = "") {
            WinMove(X, Y, , H, WinTitle)
        } else if (H = "") {
            WinMove(X, Y, W, , WinTitle)
        } else {
            WinMove(X, Y, W, H, WinTitle)
        }

        ; Verify position and make final adjustment if needed for bottom snapping
        if (ForceToTaskbar) {
            Sleep(10)  ; Small delay to ensure the move completed
            WinGetPos(&NewX, &NewY, &NewW, &NewH, WinTitle)
            WorkArea := GetAdjustedWorkArea(GetActiveMonitor(NewX, NewY, NewW, NewH, WinTitle))

            ; If window still isn't at the correct position, try one more adjustment
            ExpectedBottom := WorkArea[4] - TASKBAR_GAP
            if (NewY + NewH < ExpectedBottom - 5) {  ; 5 pixel tolerance
                FinalY := ExpectedBottom - NewH
                WinMove(NewX, FinalY, , , WinTitle)
            }
        }

    } catch as err {
        if (InStr(err.Message, "Access is denied")) {
            MsgBox("Unable to move this window due to system restrictions. Try running the script as administrator.",
                "Access Denied", 48)
        } else {
            MsgBox("An unexpected error occurred: " . err.Message, "Error", 16)
        }
    }
}

; Safely move a window, handling potential errors
MoveWindowSafely(X, Y, W := "", H := "", WinTitle := "A") {
    MoveWindowSafelyEnhanced(X, Y, W, H, WinTitle, false)
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

; Check if Windhawk taskbar auto-hide mod is enabled
IsTaskbarAutoHideModEnabled() {
    ; First check if Windhawk is running
    if (!ProcessExist("windhawk.exe"))
        return false

    try {
        ; Read the Windhawk userprofile.json file
        jsonPath := "C:\ProgramData\Windhawk\userprofile.json"
        if (!FileExist(jsonPath))
            return false

        jsonContent := FileRead(jsonPath)

        ; Look for the taskbar-auto-hide-when-maximized section
        modName := '"taskbar-auto-hide-when-maximized": {'
        modPos := InStr(jsonContent, modName)

        if (!modPos)
            return false  ; Mod not found

        ; Find the end of this mod's section (next '}' at the same level)
        startPos := modPos + StrLen(modName)
        braceCount := 1
        pos := startPos
        endPos := 0

        while (pos <= StrLen(jsonContent) && braceCount > 0) {
            char := SubStr(jsonContent, pos, 1)
            if (char = '{')
                braceCount++
            else if (char = '}') {
                braceCount--
                if (braceCount = 0)
                    endPos := pos
            }
            pos++
        }

        if (!endPos)
            return false

        ; Extract just this mod's content
        modSection := SubStr(jsonContent, startPos, endPos - startPos)

        ; Check for disabled status in this section only
        if (InStr(modSection, '"disabled": true'))
            return false

        ; If we get here, mod exists and is either disabled: false or has no disabled property
        return true

    } catch {
        return false
    }
}

; Check if any window on the specified monitor is maximized
IsWindowMaximized(MonitorIndex) {
    DetectHiddenWindows(false)
    windows := WinGetList()

    for window in windows {
        try {
            title := WinGetTitle("ahk_id " . window)
            state := WinGetMinMax("ahk_id " . window)
            WinGetPos(&wx, &wy, &ww, &wh, "ahk_id " . window)
            monitor := GetActiveMonitor(wx, wy, ww, wh, "ahk_id " . window)

            if (monitor = MonitorIndex && state = 1)
                return true
        } catch Error {
            continue
        }
    }
    return false
}

; Get the adjusted work area for a monitor, accounting for SmartTaskbar and Windhawk mods
GetAdjustedWorkArea(MonitorIndex) {
    MonitorGetWorkArea(MonitorIndex, &Left, &Top, &Right, &Bottom)
    PrimaryMonitor := MonitorGetPrimary()

    SmartTaskbarCondition := MonitorIndex = PrimaryMonitor && IsSmartTaskbarRunning() && !IsWindowMaximized(
        PrimaryMonitor)
    WindhawkCondition := IsTaskbarAutoHideModEnabled() && !IsWindowMaximized(MonitorIndex)

    if (SmartTaskbarCondition || WindhawkCondition)
        Bottom -= GetTaskbarHeight()

    return [Left, Top, Right, Bottom]
}

; Get information about the currently focused window
GetFocusedWindowInfo() {
    if (!WindowExists("A")) {
        throw Error("No active window found.")
    }
    WinGetPos(&WinX, &WinY, &WinW, &WinH, "A")
    return { X: WinX, Y: WinY, W: WinW, H: WinH }
}

; Center window horizontally and vertically
^#s:: ; CTRL+WIN+S
{
    try {
        WinInfo := GetFocusedWindowInfo()
        ActiveMonitor := GetActiveMonitor(WinInfo.X, WinInfo.Y, WinInfo.W, WinInfo.H, "A")
        WorkArea := GetAdjustedWorkArea(ActiveMonitor)
        CenterX := WorkArea[1] + (WorkArea[3] - WorkArea[1] - WinInfo.W) // 2
        CenterY := WorkArea[2] + (WorkArea[4] - WorkArea[2] - WinInfo.H) // 2
        MoveWindowSafely(CenterX, CenterY)
    } catch as err {
        MsgBox("Error: " . err.Message, "Window Centering Error", 16)
    }
}

; Snap left (center vertically, align to left)
^#a:: ; CTRL+WIN+A
{
    try {
        WinInfo := GetFocusedWindowInfo()
        ActiveMonitor := GetActiveMonitor(WinInfo.X, WinInfo.Y, WinInfo.W, WinInfo.H, "A")
        WorkArea := GetAdjustedWorkArea(ActiveMonitor)
        CenterY := WorkArea[2] + (WorkArea[4] - WorkArea[2] - WinInfo.H) // 2
        MoveWindowSafely(WorkArea[1], CenterY)
    } catch as err {
        MsgBox("Error: " . err.Message, "Window Positioning Error", 16)
    }
}

; Snap right (center vertically, align to right)
^#d:: ; CTRL+WIN+D
{
    try {
        WinInfo := GetFocusedWindowInfo()
        ActiveMonitor := GetActiveMonitor(WinInfo.X, WinInfo.Y, WinInfo.W, WinInfo.H, "A")
        WorkArea := GetAdjustedWorkArea(ActiveMonitor)
        RightX := WorkArea[3] - WinInfo.W
        CenterY := WorkArea[2] + (WorkArea[4] - WorkArea[2] - WinInfo.H) // 2
        MoveWindowSafely(RightX, CenterY)
    } catch as err {
        MsgBox("Error: " . err.Message, "Window Positioning Error", 16)
    }
}

; Snap top (center horizontally, align to top)
^#w:: ; CTRL+WIN+W
{
    try {
        WinInfo := GetFocusedWindowInfo()
        ActiveMonitor := GetActiveMonitor(WinInfo.X, WinInfo.Y, WinInfo.W, WinInfo.H, "A")
        WorkArea := GetAdjustedWorkArea(ActiveMonitor)
        CenterX := WorkArea[1] + (WorkArea[3] - WorkArea[1] - WinInfo.W) // 2
        TopY := WorkArea[2]
        MoveWindowSafely(CenterX, TopY)
    } catch as err {
        MsgBox("Error: " . err.Message, "Window Positioning Error", 16)
    }
}

; Enhanced snap bottom (center horizontally, align to bottom) - IMPROVED VERSION
^#x:: ; CTRL+WIN+X
{
    try {
        WinInfo := GetFocusedWindowInfo()
        ActiveMonitor := GetActiveMonitor(WinInfo.X, WinInfo.Y, WinInfo.W, WinInfo.H, "A")
        WorkArea := GetAdjustedWorkArea(ActiveMonitor)
        CenterX := WorkArea[1] + (WorkArea[3] - WorkArea[1] - WinInfo.W) // 2
        ; Use the enhanced function with ForceToTaskbar flag
        MoveWindowSafelyEnhanced(CenterX, 0, "", "", "A", true)
    } catch as err {
        MsgBox("Error: " . err.Message, "Window Positioning Error", 16)
    }
}

; Top-left corner
^#q:: ; CTRL+WIN+Q
{
    try {
        WinInfo := GetFocusedWindowInfo()
        ActiveMonitor := GetActiveMonitor(WinInfo.X, WinInfo.Y, WinInfo.W, WinInfo.H, "A")
        WorkArea := GetAdjustedWorkArea(ActiveMonitor)
        MoveWindowSafely(WorkArea[1], WorkArea[2])
    } catch as err {
        MsgBox("Error: " . err.Message, "Window Positioning Error", 16)
    }
}

; Top-right corner
^#e:: ; CTRL+WIN+E
{
    try {
        WinInfo := GetFocusedWindowInfo()
        ActiveMonitor := GetActiveMonitor(WinInfo.X, WinInfo.Y, WinInfo.W, WinInfo.H, "A")
        WorkArea := GetAdjustedWorkArea(ActiveMonitor)
        RightX := WorkArea[3] - WinInfo.W
        MoveWindowSafely(RightX, WorkArea[2])
    } catch as err {
        MsgBox("Error: " . err.Message, "Window Positioning Error", 16)
    }
}

; Enhanced bottom-left corner
^#z:: ; CTRL+WIN+Z
{
    try {
        WinInfo := GetFocusedWindowInfo()
        ActiveMonitor := GetActiveMonitor(WinInfo.X, WinInfo.Y, WinInfo.W, WinInfo.H, "A")
        WorkArea := GetAdjustedWorkArea(ActiveMonitor)
        ; Use enhanced function for better bottom alignment
        MoveWindowSafelyEnhanced(WorkArea[1], 0, "", "", "A", true)
    } catch as err {
        MsgBox("Error: " . err.Message, "Window Positioning Error", 16)
    }
}

; Enhanced bottom-right corner
^#c:: ; CTRL+WIN+C
{
    try {
        WinInfo := GetFocusedWindowInfo()
        ActiveMonitor := GetActiveMonitor(WinInfo.X, WinInfo.Y, WinInfo.W, WinInfo.H, "A")
        WorkArea := GetAdjustedWorkArea(ActiveMonitor)
        RightX := WorkArea[3] - WinInfo.W
        ; Use enhanced function for better bottom alignment
        MoveWindowSafelyEnhanced(RightX, 0, "", "", "A", true)
    } catch as err {
        MsgBox("Error: " . err.Message, "Window Positioning Error", 16)
    }
}
