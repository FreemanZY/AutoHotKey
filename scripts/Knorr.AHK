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

============================================================
Send, !{PrintScreen}
MsgBox, %A_ScriptDir%
Run, ".PngOptimizer.exe"
WinWaitActive, "PngOptimizer 1.6 ? 2002/2007 Hadrien Nilsson - psydk.org"
Send, ^{v}
