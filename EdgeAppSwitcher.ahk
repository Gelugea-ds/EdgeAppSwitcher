#SingleInstance Force
#Persistent
#NoEnv
CoordMode, Mouse, Screen
SetTimer, CheckEdge, 30

; ================== DEFAULT SETTINGS ==================
enableEdgeSwitch := 1
enableLauncher := 1
enablePredictive := 1
enableTeleport := 1

edgeSize := 6
hoverDelay := 220
cooldownDelay := 500
directionMemoryTimeout := 1200

topBlockPercent := 20     ; blocks from top
bottomBlockPercent := 20  ; blocks from bottom

cornerSize := 10
; =====================================================

lastEdge := ""
hoverStart := 0
cooldown := 0

lastDirection := ""
lastSwitchTime := 0

launcherVisible := false

; ================== OVERLAY ==================
Gui, Overlay:+AlwaysOnTop -Caption +ToolWindow +E0x20
Gui, Overlay:Color, 00FF00
WinSet, Transparent, 80, Overlay

; ================== SETTINGS WINDOW ==================
Gui, Settings:Font, s10, Segoe UI

Gui, Settings:Add, Checkbox, vUI_enableEdgeSwitch Checked%enableEdgeSwitch%, Enable Edge Switching
Gui, Settings:Add, Checkbox, vUI_enablePredictive Checked%enablePredictive%, Enable Predictive Switching
Gui, Settings:Add, Checkbox, vUI_enableTeleport Checked%enableTeleport%, Enable Cursor Teleport

Gui, Settings:Add, Text,, Edge Width (px)
Gui, Settings:Add, Slider, vUI_edgeSize Range2-30 ToolTip gUpdateOverlay, %edgeSize%

Gui, Settings:Add, Text,, Block From Top (`%)
Gui, Settings:Add, Slider, vUI_topBlockPercent Range0-80 ToolTip gUpdateOverlay, %topBlockPercent%

Gui, Settings:Add, Text,, Block From Bottom (`%)
Gui, Settings:Add, Slider, vUI_bottomBlockPercent Range0-80 ToolTip gUpdateOverlay, %bottomBlockPercent%

Gui, Settings:Add, Text,, Hover Delay (ms)
Gui, Settings:Add, Slider, vUI_hoverDelay Range50-800 ToolTip, %hoverDelay%

Gui, Settings:Add, Text,, Cooldown (ms)
Gui, Settings:Add, Slider, vUI_cooldownDelay Range200-1500 ToolTip, %cooldownDelay%

Gui, Settings:Add, Button, gApplySettings w120, Apply

Gui, Settings:Show, x200 y200, EdgeAppSwitcher Settings

; ================== MAIN LOOP ==================
CheckEdge:
    MouseGetPos, x, y
    SysGet, screenW, 78
    SysGet, screenH, 79

    if (!enableEdgeSwitch)
        return

    if (cooldown)
        return

    ; Compute active vertical zone
    topBlockPx := screenH * (topBlockPercent / 100)
    bottomBlockPx := screenH * (bottomBlockPercent / 100)

    activeTop := topBlockPx
    activeBottom := screenH - bottomBlockPx

    ; If mouse is outside allowed vertical zone → ignore
    if (y < activeTop || y > activeBottom)
        return

    now := A_TickCount

    ; LEFT EDGE
    if (x <= edgeSize) {
        if (lastEdge != "left") {
            lastEdge := "left"
            hoverStart := now
            return
        }
        if (now - hoverStart >= hoverDelay) {
            DoSwitch("left", y, screenW)
        }
    }
    ; RIGHT EDGE
    else if (x >= screenW - edgeSize) {
        if (lastEdge != "right") {
            lastEdge := "right"
            hoverStart := now
            return
        }
        if (now - hoverStart >= hoverDelay) {
            DoSwitch("right", y, screenW)
        }
    }
    else {
        lastEdge := ""
        hoverStart := 0
    }
return

; ================== SWITCH LOGIC ==================
DoSwitch(side, y, screenW) {
    global lastDirection, lastSwitchTime, directionMemoryTimeout
    global cooldown, cooldownDelay, enablePredictive, enableTeleport

    now := A_TickCount

    if (enablePredictive) {
        if (now - lastSwitchTime > directionMemoryTimeout)
            lastDirection := ""

        if (lastDirection = "")
            direction := side
        else if (side = lastDirection)
            direction := lastDirection
        else
            direction := side
    } else {
        direction := side
    }

    if (direction = "right") {
        Send, !{Tab}
        if (enableTeleport)
            MouseMove, 15, y, 0
    } else {
        Send, !+{Tab}
        if (enableTeleport)
            MouseMove, screenW - 15, y, 0
    }

    lastDirection := direction
    lastSwitchTime := now

    cooldown := 1
    SetTimer, ResetCooldown, -%cooldownDelay%
}

ResetCooldown:
    cooldown := 0
return

; ================== OVERLAY ==================
UpdateOverlay:
    Gui, Settings:Submit, NoHide
    ShowOverlay()
return

ShowOverlay() {
    global UI_edgeSize, UI_topBlockPercent, UI_bottomBlockPercent

    SysGet, screenW, 78
    SysGet, screenH, 79

    topBlockPx := screenH * (UI_topBlockPercent / 100)
    bottomBlockPx := screenH * (UI_bottomBlockPercent / 100)

    activeTop := topBlockPx
    activeBottom := screenH - bottomBlockPx
    height := activeBottom - activeTop

    if (height < 10)
        height := 10

    Gui, Overlay:Show, x0 y%activeTop% w%UI_edgeSize% h%height% NoActivate
    SetTimer, HideOverlay, -1200
}

HideOverlay:
    Gui, Overlay:Hide
return

; ================== APPLY SETTINGS ==================
ApplySettings:
    Gui, Settings:Submit, NoHide

    enableEdgeSwitch := UI_enableEdgeSwitch
    enablePredictive := UI_enablePredictive
    enableTeleport := UI_enableTeleport

    edgeSize := UI_edgeSize
    topBlockPercent := UI_topBlockPercent
    bottomBlockPercent := UI_bottomBlockPercent
    hoverDelay := UI_hoverDelay
    cooldownDelay := UI_cooldownDelay

    ToolTip, Settings Applied!
    SetTimer, RemoveTip, -800
return

RemoveTip:
    ToolTip
return
