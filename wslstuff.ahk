
#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
#Warn ; Enable warnings to assist with detecting common errors.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
DetectHiddenWindows, On
DetectHiddenText, On
SetCapsLockState, off

; *********************************************************************
; Set Debug to 1 for log output.  You need a debug log viewer. You can
; use https://docs.microsoft.com/en-us/sysinternals/downloads/debugview
; *********************************************************************
Debug = 0

Log(value) {
    global Debug
    if (Debug > 0) {
        OutputDebug AHK: %value% `n
    }
}

; *********************************************************************
; Get and set some global variables
; *********************************************************************
EnvGet UserFolder, USERPROFILE
LocalAppData = %UserFolder%\AppData\Local\
RoamingAppData = %UserFolder%\AppData\Roaming\
ScriptDir = %UserFolder%\.ahkstuff

; *********************************************************************
; Create the script to run xfce4-appfinder in a hidden window if it
; does not already exist.
; *********************************************************************
runxfce4ScriptPath = %ScriptDir%\runxfce4.vbs
runxfce4DistScriptSource := "dist=WScript.Arguments(0)`nargs = ""-d "" + dist + "" -- export DISPLAY=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2; exit;}'):0.0; if [ -z $(pidof xfsettingsd) ]; then export LIBGL_ALWAYS_INDIRECT=1; export NO_AT_BRIDGE=1; cd ~; xfsettingsd --sm-client-disable; fi; xfce4-appfinder""`nWScript.CreateObject(""Shell.Application"").ShellExecute ""wsl.exe"", args, """", ""open"", 0`n"

if !FileExist(runxfce4ScriptPath) {
    Log("runxfce4 does not exist. Creating file " runxfce4ScriptPath)
    FileCreateDir %ScriptDir%

    FileAppend %runxfce4DistScriptSource%, %runxfce4ScriptPath%
} else {
    Log("RunXfce4 exists")
}

; *********************************************************************
; Create a script to run any command hidden if it does not already exist
; this is not currently used in this script but may be needed
; if the runxfce4 script does not do what is needed for other distros
; *********************************************************************
RunHiddenScriptPath = %ScriptDir%\runhidden.vbs
RunHiddenScriptSource := "exe = WScript.Arguments(0)`n sep = """"`n for i = 1 to WScript.Arguments.Count -1`n args = args & sep & """""""" & WScript.Arguments(i) & """"""""`n sep = "" ""`n next`n WScript.CreateObject(""Shell.Application"").ShellExecute exe, args, """", ""open"", 0`n "

if !FileExist(RunHiddenScriptPath) {
    Log("RunHidden does not exist. Creating file " RunHiddenScriptPath)
    FileCreateDir %ScriptDir%
    FileDelete %ScriptDir%\runhidden.vbs
    FileAppend %RunHiddenScriptSource%, %ScriptDir%\runhidden.vbs
} else {
    Log("RunHidden exists")
}

; *********************************************************************
; Function for editing AHK code in Visual Studio Code from the
; AutoHotkey ToolTray menu
; *********************************************************************
EditWithVsCode(filename) {
    global ScriptDir
    global LocalAppData
    Run %ScriptDir%\runhidden.vbs %LocalAppData%"\Programs\Microsoft VS Code\bin\code.cmd" %filename%
}

EditAhkScript() {
    EditWithVsCode(A_ScriptFullPath)
}

; *********************************************************************
; Show the WSL Environment it a Windows Notification
; *********************************************************************
ShowCurrentWslEnvironment(num) {
    global WslEnvironmentNames
    environmentName := WslEnvironmentNames[num]
    TrayTip X410, Environment set to %environmentName%,,1 
}

; *********************************************************************
; Set the WSL distro to launc xfce4-appfinder in
; There is only one in this file but others can be added
; *********************************************************************
SetWslEnvironment(num) 
{
    global CurrentEnvironment
    global ScriptDir
    CurrentEnvironment := num
    ShowCurrentWslEnvironment(CurrentEnvironment)
    FileDelete %ScriptDir%\defaultenv.txt
    FileAppend %CurrentEnvironment%, %ScriptDir%\defaultenv.txt
}	

; *********************************************************************
; run the appfinder in the currently selected distro
; add as many as you want here.
; *********************************************************************
RunAppfinder()
{ 
    global CurrentEnvironment
    global ScriptDir	
    global LocalAppData
    global WslV1Run	
    global Wsl2NoDbusRun
    global WslV2UlRunSource

    switch CurrentEnvironment {
        Case 1:		
            Run %ScriptDir%\runxfce4.vbs WLinux
        return		
    }
}

; *********************************************************************
; The distro list for displaying in notifications
; There is only one in this file but others can be added
; *********************************************************************
WslEnvironmentNames := ["Pengwin WSL"]

; *********************************************************************
; Default to distro 1
; *********************************************************************
CurrentEnvironment = 1

; *********************************************************************
; Read file to set last distro 
; *********************************************************************
FileReadLine CurrentEnvironment, %ScriptDir%\defaultenv.txt, 1

if (CurrentEnvironment = "") {
    CurrentEnvironment = 1
}

Log("CurrentEnvironment: " . CurrentEnvironment)
Log("ScriptDir : " . ScriptDir)

; *********************************************************************
; Show current environment on script start
; *********************************************************************
ShowCurrentWslEnvironment(CurrentEnvironment)

; ***************************************************************************
;  Modify Tool Tray Menu          
; ***************************************************************************
Menu, Tray, NoStandard
Menu Tray, Add, Edit with VSCode, EditAhkScript
Menu, Tray, Add
Menu, Tray, Standard

; ***************************************************************************
;  Key Mapping
; ***************************************************************************

; *********************************************************************
; Win+Space will launch xfce4-appfinder in the current distro
; *********************************************************************
#Space::RunAppfinder() 

; *********************************************************************
; shift+alt+0 - show the current distro
; *********************************************************************
!+0::ShowCurrentWslEnvironment(CurrentEnvironment)
; *********************************************************************
; shift+alt+1 - set the current distro to WLinux
; *********************************************************************
!+1::SetWslEnvironment(1)

