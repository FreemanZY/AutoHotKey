; AutoHotkey Version: 1.x
; Language:       English
; Platform:       WinXP.SP3
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
Gui, Add, DropDownList, x6 y17 w100 h100 vTrain, 801|802|803|804|805|806|807|808|809|810|811|812|813|814|815|816|817|818|819|820|821|822|823|824|825|826|827|828
Gui, Add, Button, x116 y17 w70 h20 , 开始
; Generated using SmartGUI Creator 4.0
Gui, Show, x253 y136 h57 w198, Winscope自动下载
Return

GuiClose:
ExitApp

Button开始:
Gui, Submit
;保存路径
IniRead, Save, MMAP_Configuration.INI, Save, Save
Times=%A_Now%
FileCreateDir, %Save%%Train%_%Times%
;程序运行路径
IniRead, App, MMAP_Configuration.INI, Run_App, App
;辅逆配置文件路径
IniRead, Auxiliary, MMAP_Configuration.INI, Auxiliary, Auxiliary
;牵引配置文件路径
IniRead, Traction, MMAP_Configuration.INI, Traction, Traction

Loop, 7
{
	;读取配置文件名
	IniRead, EQP%A_Index%, MMAP_Configuration.INI, EQP%A_Index%, EQP%A_Index%
	IniRead, Name%A_Index%, MMAP_Configuration.INI, EQP%A_Index%, Train%A_Index%
}
Run %App%
WinWaitActive, licence owning informations,
ControlClick,Button1, licence owning informations,
Send,{Enter}
Loop, 6
{
	EQP:=EQP%A_Index%
	Name:=Name%A_Index%
	If A_Index<=2
		Path=%Auxiliary%
	Else
		Path=%Traction%
	WinWaitActive, Agate Family debugging/maintenance application,
	WinMenuSelectItem, Agate Family debugging/maintenance application, , Equipment, Open
	WinWaitActive, Browse File(s),
	ControlSetText, Edit1, %Path%%EQP%, Browse File(s)
	Send,{Enter}
	WinMenuSelectItem, Agate Family debugging/maintenance application, , Equipment, Edit
	WinWaitActive, C:\Program Files\,
	Control, Choose, 3, ComboBox1, C:\Program Files\,
	ControlClick,Button8,C:\Program Files\,
	Send,{Enter}
	WinMenuSelectItem, Agate Family debugging/maintenance application, , Equipment, Dialog
	Loop
	{
		ifwinexist, C:\Program Files\,
			break
		else
			{
				ifwinexist, MMAPDLL.DLL
					{
						ControlClick,Button1,MMAPDLL.DLL,
						Send, {Enter}
						MsgBox, 48, 连接失败, 请检查连接后再点击确认！
						WinActivate, Agate Family debugging/maintenance application,
						WinMenuSelectItem, Agate Family debugging/maintenance application, , Equipment, Dialog
					}
			}
	}
	WinWaitActive, C:\Program Files\
	WinActivate, Agate Family debugging/maintenance application,
	WinMenuSelectItem, Agate Family debugging/maintenance application, , Tools, Events
	WinWaitActive, Recorder selection,
	ControlClick,Button1,Recorder selection,
	Send, {Enter}
	WinWaitActive, Agate Family debugging/maintenance application - Events - Handle [i960],
	WinMenuSelectItem, Agate Family debugging/maintenance application - Events - Handle [i960], , Action, Retrieve All
	WinWaitActive, Agate Family debugging/maintenance application - Events - View,
	WinMenuSelectItem, Agate Family debugging/maintenance application - Events - View, , File, Save
	WinWaitActive, 另存为
	ControlSetText, Edit1, %Save%%Train%_%Times%\%Train%_%Name%_%Times%, 另存为
	ControlClick,Button2, 另存为,
	Send, {Enter}
	Loop, 2
		{
			WinWaitActive, ahk_class #32770
			Send, {Space}
		}
	;IfWinExist, Trace file heading,
	;	ControlClick, Button1, Trace file heading,
	;WinWaitActive, ahk_class #32770,
	;Send, {Space}
	WinWaitActive, Agate Family debugging/maintenance application - Events - View,
	WinMenuSelectItem, Agate Family debugging/maintenance application - Events - View, , File, Save
	WinWaitActive, 另存为
	Control, Choose, 2, ComboBox3, 另存为,
	ControlSetText, Edit1, %Save%%Train%_%Times%\%Train%_%Name%_%Times%, 另存为
	ControlClick,Button2, 另存为,
	Send,{Enter}
	Loop, 2
		{
			WinWaitActive, ahk_class #32770
			Send, {Space}
		}
	;IfWinExist, Trace file heading,
	;	ControlClick, Button1, Trace file heading,
	;WinWaitActive, ahk_class #32770,
	;Send, {Space}
	WinWaitActive, Agate Family debugging/maintenance application - Events - View,
	WinMenuSelectItem, Agate Family debugging/maintenance application - Events - View, , Window, 2
	WinWaitActive, Agate Family debugging/maintenance application - Events - Handle [i960],
	WinMenuSelectItem, Agate Family debugging/maintenance application - Events - Handle [i960], , Action, Clear All
	WinWaitActive, ahk_class #32770,
	Send, {Space}
	WinWaitActive, Agate Family debugging/maintenance application,
	WinMenuSelectItem, Agate Family debugging/maintenance application, , Equipment, Close
	WinWaitActive, ahk_class #32770,
	Send, {Space}
}
WinWaitActive, Agate Family debugging/maintenance application
WinMenuSelectItem, Agate Family debugging/maintenance application, , File, Exit
MsgBox, 48, 完成, 故障下载完成！
ExitApp
Return