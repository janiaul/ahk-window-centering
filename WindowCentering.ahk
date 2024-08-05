#NoTrayIcon

; Function to get the active monitor
GetActiveMonitor(X, Y) {
    SysGet, MonitorCount, MonitorCount
    Loop, %MonitorCount%
    {
        SysGet, MonitorWorkArea, MonitorWorkArea, %A_Index%
        if (X >= MonitorWorkAreaLeft && X < MonitorWorkAreaRight && Y >= MonitorWorkAreaTop && Y < MonitorWorkAreaBottom)
        {
            return A_Index
        }
    }
    return 1  ; Default to primary monitor if not found
}

; Center window horizontally and vertically
^!c::  ; Ctrl+Alt+C hotkey
WinGetPos, X, Y, Width, Height, A
ActiveMonitor := GetActiveMonitor(X, Y)
SysGet, MonitorWorkArea, MonitorWorkArea, %ActiveMonitor%
CenterX := MonitorWorkAreaLeft + (MonitorWorkAreaRight - MonitorWorkAreaLeft - Width) / 2
CenterY := MonitorWorkAreaTop + (MonitorWorkAreaBottom - MonitorWorkAreaTop - Height) / 2
WinMove, A,, %CenterX%, %CenterY%
return

; Center window horizontally only
^!h::  ; Ctrl+Alt+H hotkey
WinGetPos, X, Y, Width, Height, A
ActiveMonitor := GetActiveMonitor(X, Y)
SysGet, MonitorWorkArea, MonitorWorkArea, %ActiveMonitor%
CenterX := MonitorWorkAreaLeft + (MonitorWorkAreaRight - MonitorWorkAreaLeft - Width) / 2
WinMove, A,, %CenterX%, Y  ; Keep the current Y position, only change X
return

; Center window vertically only
^!v::  ; Ctrl+Alt+V hotkey
WinGetPos, X, Y, Width, Height, A
ActiveMonitor := GetActiveMonitor(X, Y)
SysGet, MonitorWorkArea, MonitorWorkArea, %ActiveMonitor%
CenterY := MonitorWorkAreaTop + (MonitorWorkAreaBottom - MonitorWorkAreaTop - Height) / 2
WinMove, A,, X, %CenterY%  ; Keep the current X position, only change Y
return

; Center window horizontally and align to top of monitor
^!t::  ; Ctrl+Alt+T hotkey
WinGetPos, X, Y, Width, Height, A
ActiveMonitor := GetActiveMonitor(X, Y)
SysGet, MonitorWorkArea, MonitorWorkArea, %ActiveMonitor%
CenterX := MonitorWorkAreaLeft + (MonitorWorkAreaRight - MonitorWorkAreaLeft - Width) / 2
TopY := MonitorWorkAreaTop  ; Align to the top of the work area
WinMove, A,, %CenterX%, %TopY%
return

; Center window horizontally and align to bottom of monitor
^!b::  ; Ctrl+Alt+B hotkey
WinGetPos, X, Y, Width, Height, A
ActiveMonitor := GetActiveMonitor(X, Y)
SysGet, MonitorWorkArea, MonitorWorkArea, %ActiveMonitor%
CenterX := MonitorWorkAreaLeft + (MonitorWorkAreaRight - MonitorWorkAreaLeft - Width) / 2
BottomY := MonitorWorkAreaBottom - Height  ; Align to the bottom of the work area
WinMove, A,, %CenterX%, %BottomY%
return

; Center window vertically and align to left of monitor
^!l::  ; Ctrl+Alt+L hotkey
WinGetPos, X, Y, Width, Height, A
ActiveMonitor := GetActiveMonitor(X, Y)
SysGet, MonitorWorkArea, MonitorWorkArea, %ActiveMonitor%
LeftX := MonitorWorkAreaLeft  ; Align to the left of the work area
CenterY := MonitorWorkAreaTop + (MonitorWorkAreaBottom - MonitorWorkAreaTop - Height) / 2
WinMove, A,, %LeftX%, %CenterY%
return

; Center window vertically and align to right of monitor
^!r::  ; Ctrl+Alt+R hotkey
WinGetPos, X, Y, Width, Height, A
ActiveMonitor := GetActiveMonitor(X, Y)
SysGet, MonitorWorkArea, MonitorWorkArea, %ActiveMonitor%
RightX := MonitorWorkAreaRight - Width  ; Align to the right of the work area
CenterY := MonitorWorkAreaTop + (MonitorWorkAreaBottom - MonitorWorkAreaTop - Height) / 2
WinMove, A,, %RightX%, %CenterY%
return