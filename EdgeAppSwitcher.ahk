#SingleInstance Force
#Persistent
#NoEnv
CoordMode, Mouse, Screen
SetTimer, CheckEdge, 30

; ================= SETTINGS =================
enableEdgeSwitch := 1
enablePredictive := 1
enableTeleport := 1
showGuides := 1

edgeSize := 6
hoverDelay := 220
cooldownDelay := 400

blockTopPct := 10
blockBottomPct := 10

cooldown := 0
lastEdge := ""
hoverStart := 0

; ================= GET SCREEN =================
SysGet, screenW, 78
SysGet, screenH, 79

; ================= GUIDE WINDOWS =================
Gui, GuideL:+AlwaysOnTop -Caption +ToolWindow +E0x20
Gui, GuideL:Color, 00FF00

Gui, GuideR:+AlwaysOnTop -Caption +ToolWindow +E0x20
Gui, GuideR:Color, 00FF00

; ================= CONTROL PANEL =================
Gui, Settings:Font, s10, Segoe UI
Gui, Settings:Add, Checkbox, vUI_enableEdgeSwitch Checked, Enable Edge Switching
Gui, Settings:Add, Checkbox, vUI_enablePredictive Checked, Enable Predictive Switching
Gui, Settings:Add, Checkbox, vUI_enableTeleport Checked, Enable Cursor Teleport
Gui, Settings:Add, Checkbox, vUI_showGuides Checked, Show Guide Lines

Gui, Settings:Add, Text,, Edge Width (px)
Gui, Settings:Add, Slider, vUI_edgeSize Range2-30 ToolTip gLiveUpdate, %edgeSize%

Gui, Settings:Add, Text,, Block From Top (percent)
Gui, Settings:Add, Slider, vUI_blockTop Range0-45 ToolTip gLiveUpdate, %blockTopPct%

Gui, Settings:Add, Text,, Block From Bottom (percent)
Gui, Settings:Add, Slider, vUI_blockBottom Range0-45 ToolTip gLiveUpdate, %blockBottomPct%

Gui, Settings:Add, Text,, Hover Delay (ms)
Gui, Settings:Add, Slider, vUI_hoverDelay Range50-600 ToolTip, %hoverDelay%

Gui, Settings:Add, Text,, Cooldown (ms)
Gui, Settings:Add, Slider, vUI_cooldown Range100-1000 ToolTip, %cooldownDelay%

Gui, Settings:Add, Button, gApplySettings w100, Apply
Gui, Settings:Show, x200 y200, EdgeAppSwitcher

; ================= LIVE UPDATE =================
LiveUpdate:
    Gui, Settings:Submit, NoHide
    edgeSize := UI_edgeSize
    blockTopPct := UI_blockTop
    blockBottomPct := UI_blockBottom
    showGuides := UI_showGuides
    DrawGuides()
return

; ================= APPLY =================
ApplySettings:
    Gui, Settings:Submit, NoHide

    enableEdgeSwitch := UI_enableEdgeSwitch
    enablePredictive := UI_enablePredictive
    enableTeleport := UI_enableTeleport
    showGuides := UI_showGuides

    edgeSize := UI_edgeSize
    hoverDelay := UI_hoverDelay
    cooldownDelay := UI_cooldown
    blockTopPct := UI_blockTop
    blockBottomPct := UI_blockBottom

    DrawGuides()
return

; ================= DRAW GUIDES =================
DrawGuides() {
    global showGuides, edgeSize, blockTopPct, blockBottomPct, screenH, screenW

    if (!showGuides) {
        Gui, GuideL:Hide
        Gui, GuideR:Hide
        return
    }

    topBlockPx := Round(screenH * blockTopPct / 100)
    bottomBlockPx := Round(screenH * blockBottomPct / 100)

    usableY := topBlockPx
    usableH := screenH - topBlockPx - bottomBlockPx

    if (usableH < 10)
        usableH := 10

    ; LEFT
    Gui, GuideL:Show, x0 y%usableY% w%edgeSize% h%usableH% NoActivate

    ; RIGHT
    xR := screenW - edgeSize
    Gui, GuideR:Show, x%xR% y%usableY% w%edgeSize% h%usableH% NoActivate
}

; ================= MAIN LOOP =================
CheckEdge:
    if (!enableEdgeSwitch)
        return

    if (cooldown)
        return

    MouseGetPos, x, y

    topBlockPx := Round(screenH * blockTopPct / 100)
    bottomBlockPx := Round(screenH * blockBottomPct / 100)

    if (y < topBlockPx)
        return

    if (y > screenH - bottomBlockPx)
        return

    now := A_TickCount

    ; LEFT
    if (x <= edgeSize) {
        if (lastEdge != "L") {
            lastEdge := "L"
            hoverStart := now
            return
        }
        if (now - hoverStart >= hoverDelay)
            DoSwitch("L", y)
    }
    ; RIGHT
    else if (x >= screenW - edgeSize) {
        if (lastEdge != "R") {
            lastEdge := "R"
            hoverStart := now
            return
        }
        if (now - hoverStart >= hoverDelay)
            DoSwitch("R", y)
    }
    else {
        lastEdge := ""
        hoverStart := 0
    }
return

; ================= SWITCH =================
DoSwitch(side, y) {
    global cooldown, cooldownDelay, enableTeleport, screenW

    if (side = "R") {
        Send, !{Tab}
        if (enableTeleport)
            MouseMove, 20, y, 0
    } else {
        Send, !+{Tab}
        if (enableTeleport)
            MouseMove, screenW-20, y, 0
    }

    cooldown := 1
    SetTimer, ResetCooldown, -%cooldownDelay%
}

ResetCooldown:
    cooldown := 0
return

; ================= INIT =================
DrawGuides()
