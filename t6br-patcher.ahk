; YouTube: @game_play267
; Twitch: RR_357000
; X:@relliK_2048
#NoEnv
#SingleInstance Force
#Persistent
SetWorkingDir %A_ScriptDir%

; ─── CONFIG ───────────────────────────────────────────────
basePath  := A_ScriptDir . "\dev_hdd0\game\SCEEXE000\USRDIR"
rpcs3Exe  := A_ScriptDir . "\rpcs3.exe"
ebootPath := basePath . "\EBOOT.BIN"

; === Install each file (must be literal for FileInstall in AHK v1) ===
FileInstall, VER.206G, %A_ScriptDir%\VER.206G, 0
FileInstall, VER.206O, %A_ScriptDir%\VER.206O, 0
FileInstall, VER.206T, %A_ScriptDir%\VER.206T, 0


; ─── Set as admin. ─────────────────────────────────────────
if not A_IsAdmin
{
    try
    {
        Run *RunAs "%A_ScriptFullPath%"
    }
    catch
    {
        MsgBox, 0, Error, This script needs to be run as Administrator.
    }
    ExitApp
}

; ─── GUI ─────────────────────────────────────────────────
Gui, Add, Text, x20 y10 w300, Select VER.206 version to apply:
Gui, Add, Button, x20 y40 w100 h30 gSetTest, TEST
Gui, Add, Button, x140 y40 w100 h30 gSetGame, GAME
Gui, Add, Button, x260 y40 w100 h30 gSetRestore, RESTORE
Gui, Add, Button, x20  y90 w100 h30 gRunRPCS3, RUN RPCS3
Gui, Add, Button, x140 y90 w100 h30 gRunGame, RUN TEKKEN 6
Gui, Add, Button, x260 y90 w100 h30 gQuitRPCS3, EXIT RPCS3

title := "T6BR Patcher - " . Chr(169) . " " . A_YYYY . " - Philip"
Gui, Show, w400 h150, %title%
return

; ─── BUTTON HANDLERS ─────────────────────────────────────
SetTest:
    SwitchVersion("T")
return

SetGame:
    SwitchVersion("G")
return

SetRestore:
    SwitchVersion("O")
return


RunRPCS3:
    if FileExist(rpcs3Exe)
        Run, %rpcs3Exe%
    else
        MsgBox, 48, Error, RPCS3 not found:`n%rpcs3Exe%
return


RunGame:
    if !FileExist(rpcs3Exe) {
        MsgBox, 48, Error, RPCS3 not found:`n%rpcs3Exe%
        return
    }
    if !FileExist(ebootPath) {
        MsgBox, 48, Error, EBOOT.BIN not found:`n%ebootPath%
        return
    }

    ; Build run command with quotes around EBOOT.BIN
    runCommand := rpcs3Exe . " --no-gui --fullscreen """ . ebootPath . """"
    Run, %runCommand%, %A_ScriptDir%, UseErrorLevel

    if (ErrorLevel)
        MsgBox, 48, Error, Failed to launch RPCS3 with game.
return


; ─── Kill RPCS3 with button function. ────────────────────────────────────────────────────────────────────
QuitRPCS3:
    Process, Exist, rpcs3.exe
    pid := ErrorLevel

    if (pid) {
        RunWait, %ComSpec% /c taskkill /im rpcs3.exe /f,, Hide
        RunWait, %ComSpec% /c taskkill /im powershell.exe /f,, Hide
    } else {
        MsgBox, 64, Info, No RPCS3 processes running.
    }
return


; ─── kill all processes for RPCS3. ────────────────────────────────────────────────────────────────────
KillAllProcesses(pid := "") {
    ahkPid := DllCall("GetCurrentProcessId")

    if (pid) {
        ; Run, "%A_ScriptFullPath%" activate
        RunWait, taskkill /im %rpcs3Exe% /F,, Hide
        RunWait, taskkill /im powershell.exe /F,, Hide
        RunWait, %ComSpec% /c taskkill /PID %pid% /F,, Hide
        ; Optional: Kill any potential child processes
        RunWait, %ComSpec% /c taskkill /im powershell.exe /F,, Hide
    } else {
        MsgBox, 64, Info, "WARN", "KillAllProcesses: No PID provided."
    }
}


; ─── FUNCTION ─────────────────────────────────────────────
SwitchVersion(type)
{
    global basePath
    source := A_ScriptDir . "\VER.206" . type
    target := basePath . "\VER.206"

    if !FileExist(source) {
        MsgBox, 48, Error, Missing source file:`n%source%
        return
    }

    FileDelete, %target%
    FileCopy, %source%, %target%, 1

    if ErrorLevel
        MsgBox, 48, Error, Failed to copy file!
    else
        MsgBox, 64, Done, Switched to version: %type%
}


GuiClose:
ExitApp
