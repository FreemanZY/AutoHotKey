; AutoHotkey Version: 1.x
; Language:       English
; Platform:       WinXP.SP2
; Author:         FreemanZY
;
; Script Function:
; Template script (you can customize this template by editing "ShellNew\Template.ahk" in your Windows folder)
;

#NoEnv ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir% ; Ensures a consistent starting directory.
#NoTrayIcon
============================================================
Gui, Add, Button, x15 y10 w90 h30 , 文润楼5楼
Gui, Add, Button, x15 y50 w90 h30 , 文华楼6楼
Gui, Add, Button, x15 y90 w90 h30 , 还原
; Generated using SmartGUI Creator 4.0
Gui, Show, x131 y91 h130 w120, Web
Return

GuiClose:
ExitApp


Button文润楼5楼:
WinMinimize, Web
Run, MAC Address Changer.exe
WinWaitActive, MAC Address Changer for Windows XP/2003 v1.0
ControlSetText, Edit1, 50 78 1C 23 2A 99, MAC Address Changer for Windows XP/2003 v1.0
ControlFocus,Button1, MAC Address Changer for Windows XP/2003 v1.0,
Send, {Space}
WinWaitActive, , 此适配器 MAC ID 已成功修改
Send, {Space}
WinWaitActive, MAC Address Changer for Windows XP/2003 v1.0
ControlFocus,Button2, MAC Address Changer for Windows XP/2003 v1.0,
Send, {Space}
WinWaitActive, , 是否确定想要关闭程序?
Send, {Space}
WinActivate, Web
Return

Button文华楼6楼:
WinMinimize, Web
Run, MAC Address Changer.exe
WinWaitActive, MAC Address Changer for Windows XP/2003 v1.0
ControlSetText, Edit1, 50 78 1C 23 2A A0, MAC Address Changer for Windows XP/2003 v1.0
ControlFocus,Button1, MAC Address Changer for Windows XP/2003 v1.0,
Send, {Space}
WinWaitActive, , 此适配器 MAC ID 已成功修改
Send, {Space}
WinWaitActive, MAC Address Changer for Windows XP/2003 v1.0
ControlFocus,Button2, MAC Address Changer for Windows XP/2003 v1.0,
Send, {Space}
WinWaitActive, , 是否确定想要关闭程序?
Send, {Space}
WinActivate, Web
Return

Button还原:
WinMinimize, Web
Run, MAC Address Changer.exe
WinWaitActive, MAC Address Changer for Windows XP/2003 v1.0
ControlFocus,Button3, MAC Address Changer for Windows XP/2003 v1.0,
Send, {Space}
WinWaitActive, , 此适配器 MAC ID 已成功重设
Send, {Space}
WinWaitActive, MAC Address Changer for Windows XP/2003 v1.0
ControlFocus,Button2, MAC Address Changer for Windows XP/2003 v1.0,
Send, {Space}
WinWaitActive, , 是否确定想要关闭程序?
Send, {Space}
WinActivate, Web
Return