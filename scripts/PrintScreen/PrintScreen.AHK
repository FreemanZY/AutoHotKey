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
Run, ST03A.exe
Label1:
PrintScreen::
Send, !{PrintScreen}
Times = %A_Now%
Gui, +AlwaysOnTop -SysMenu
Gui, Add, DropDownList, x10 y10 w70 h100 vTrain, 801|802|803|804|805|806|807|808|809|810|811|812|813|814|815|816|817|818|819|820|821|822|823|824|825|826|827|828
Gui, Add, DropDownList, x120 y10 w70 h100 vCar, TC1|MP1|M1|M2|MP2|TC2
Gui, Add, Button, x50 y45 w100 h25 , 确认
; Generated using SmartGUI Creator 4.0
Gui, Show, h90 w200 Center, 请选择列车信息
Return

Button确认:
Gui, Submit
Loop
{
	FileSelectFolder, Fold, , 2
	if Fold =
		MsgBox, 48, 错误, 请选择截屏保存路径！
	else
		Break
}
Run, PngOptimizer.exe
WinWaitActive, PngOptimizer
Send, ^{v}
WinWaitActive, Please enter file name
ControlSetText, Edit1, %Train%_%Car%_%Times%.png, Please enter file name
ControlClick,Button1, Please enter file name
Send,{Enter}
Loop
{
	IfExist, %A_Temp%\%Train%_%Car%_%Times%.png
	{
		FileMove, %A_Temp%\%Train%_%Car%_%Times%.png, %Fold%, 1
		Break
	}
}
WinActivate, PngOptimizer
WinClose, PngOptimizer
IfExist, %Fold%\%Train%_%Car%_%Times%.png
	MsgBox, 64, 成功, 截屏保存成功！
Else
	Gosub, Label1
ExitApp