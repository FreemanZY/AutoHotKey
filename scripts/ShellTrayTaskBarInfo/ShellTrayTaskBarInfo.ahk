; AutoHotkey Version: 1.0.47.06
; Platform:       WinXP
; Author:         Yonken <yonken@163.com>
; Last updated: 2008-12-12
; Copyright:	
;		You are allowed to include the source code in your own product(in any form) when 
;	your product is released in binary form.
;		You are allowed to copy/modify/distribute the code in any way you want except
;	you can NOT modify/remove the copyright details at the top of each script file.

; References:
;	http://blog.csdn.net/hailongchang/archive/2008/12/05/3454569.aspx
;	http://blog.csdn.net/hailongchang/archive/2008/12/10/3490353.aspx
;	http://www.codeproject.com/KB/shell/taskbarsorter.aspx

#NoEnv
#NoTrayIcon
#SingleInstance ignore
SetWorkingDir %A_ScriptDir%

#Include ShellTrayHelper.ahk
#Include TaskBarHelper.ahk

if A_OSVersion in WIN_NT4,WIN_95,WIN_98,WIN_ME
{
    MsgBox This script only works under Windows 2000/XP or later
	ExitApp
}

OnExit, MyExit

g_szAppName := "ShellTrayTaskBarInfo"
g_szAppVersion := "1.0"

; **** Do NOT modify following variable when script is running! ****
g_szShellTrayName	:= "ShellTray"
g_szTaskBarName	:= "TaskBar"

g_szToolbarName_1 := g_szShellTrayName	; To visit current selected info, use g_szToolbarName_%g_nSelectedInfo%
g_szToolbarName_2 := g_szTaskBarName

; Main window

Gui, +Resize +MinSize850x95
Gui, Add, Button, gBtnRefresh, Refresh
Gui, Add, Button, xp+150 yp gSendLeftClick, SendLeftClick
Gui, Add, Button, xp+150 yp gMoveLeft, << MoveLeft
Gui, Add, Button, xp+100 yp gMoveRight, MoveRight >>
Gui, Add, GroupBox, xp+100 yp-5 w220 h30, 
Gui, Add, Radio, xp+10 yp+10 vg_nSelectedInfo gSwitchInfoView Checked, ShellTrayInfo
Gui, Add, Radio, xp+120 yp gSwitchInfoView, TaskBarInfo
Gui, Add, Checkbox, xp+100 yp gSwitchShowHiddenItems vg_bShowHiddenItems, ShowHiddenItems

Gui, Add, ListView
	, xp-730 yp+30 w875 h350 cBlue Grid NoSortHdr -Multi -LV0x10 AltSubmit vInfoListView gInfoListViewEvent
	, Icon|Tips|Process|Window
	
g_ImageListID := IL_Create(10)
LV_SetImageList(g_ImageListID)

Gui, Show, w900 h400, %g_szAppName% %g_szAppVersion% by Yonken [http://yonken.blogcn.com]
Gosub, SwitchInfoView
Return

GuiEscape:
GuiClose:
ExitApp

GuiSize:
	if( A_EventInfo = 1 )
		return
	GuiControl, Move, InfoListView, % "W" . (A_GuiWidth - 20) . " H" . (A_GuiHeight - 50)
Return

MyExit:	; Do the cleanup stuffs on exit
	TW_Cleanup(g_szShellTrayName)
	TW_Cleanup(g_szTaskBarName)
	ExitApp
Return

SwitchInfoView:
	Gui, Submit, NoHide
	if(g_nSelectedInfo = 1)	; that is ShellTrayInfo
	{
		GuiControl, Show, SendLeftClick
	}
	else	; that is TaskBarInfo
	{
		GuiControl, Hide, SendLeftClick
	}
	GoSub, BtnRefresh
Return

SwitchShowHiddenItems:
	Gui, Submit, NoHide
	GoSub, BtnRefresh
Return

BtnRefresh:
	GuiControl, Disable, Refresh
	GuiControl, Disable, SendLeftClick
	GuiControl, Disable, << MoveLeft
	GuiControl, Disable, MoveRight >>
	GuiControl, Disable, ShellTrayInfo
	GuiControl, Disable, TaskBarInfo
	
	pUpdateFunction := % "Update" . g_szToolbarName_%g_nSelectedInfo% . "Info"
	%pUpdateFunction%()
	
	GuiControl, Enable, Refresh
	GuiControl, Enable, SendLeftClick
	GuiControl, Enable, << MoveLeft
	GuiControl, Enable, MoveRight >>
	GuiControl, Enable, ShellTrayInfo
	GuiControl, Enable, TaskBarInfo
Return

SendLeftClick:
	nBtnIndex := LV_GetNext()
	if(nBtnIndex)
		LV_GetText(nBtnIndex, nBtnIndex, 1)
	else
		return
	if( GetShellTrayToolbarTrayDataByIndex( g_szShellTrayName, nBtnIndex, pTRAYDATA ) )
		LeftClickShellTrayToolbarButton(pTRAYDATA)
Return

MoveLeft:
	nSelectedItemIndex := LV_GetNext()
	if(nSelectedItemIndex)
		LV_GetText(nBtnIndex, nSelectedItemIndex, 1)
	else
		return
	if( nBtnIndex > 0 )
	{
		TW_MoveToolbarButton( g_szToolbarName_%g_nSelectedInfo%, nBtnIndex, nBtnIndex-1 )
		GoSub, BtnRefresh
		LV_Modify(nSelectedItemIndex-1, "Select")
	}
Return

MoveRight:
	nSelectedItemIndex := LV_GetNext()
	if(nSelectedItemIndex)
		LV_GetText(nBtnIndex, nSelectedItemIndex, 1)
	else
		return
	if( nBtnIndex < TW_GetToolbarButtonCount(g_szToolbarName_%g_nSelectedInfo%)-1 )
	{
		TW_MoveToolbarButton( g_szToolbarName_%g_nSelectedInfo%, nBtnIndex, nBtnIndex+1 )
		GoSub, BtnRefresh
		LV_Modify(nSelectedItemIndex+1, "Select")
	}
Return

InfoListViewEvent:
	if(A_EventInfo <= 0 || g_nSelectedInfo != 1 || A_EventInfo > LV_GetCount() )
		return
	LV_GetText(nBtnIndex, A_EventInfo, 1)
	if ( A_GuiEvent = "DoubleClick" )
	{
		if( GetShellTrayToolbarTrayDataByIndex( g_szShellTrayName, nBtnIndex, pTRAYDATA ) )
			LeftDbClickShellTrayToolbarButton(pTRAYDATA)
	}
	else if( A_GuiEvent = "RightClick" )
	{
		if( GetShellTrayToolbarTrayDataByIndex( g_szShellTrayName, nBtnIndex, pTRAYDATA ) )
			RightClickShellTrayToolbarButton(pTRAYDATA)
	}
Return

UpdateShellTrayInfo()
{
	Global g_ImageListID, g_szShellTrayName, InfoListView, g_bShowHiddenItems
	nRtn := 0
	GuiControl, -Redraw, InfoListView
	LV_Delete()
	nButtonCount := TW_GetToolbarButtonCount( g_szShellTrayName )
	Loop, % nButtonCount
	{
		if( !TW_GetToolbarButton( g_szShellTrayName, A_Index-1, pTBBUTTON ) )
		{
			OutputDebug, GetShellTrayToolbarButton failed!
		}
		else if( !GetShellTrayToolbarTrayDataByBtn( pTBBUTTON, pTRAYDATA ) )
		{
			OutputDebug, GetShellTrayToolbarTrayDataByBtn failed!
		}
		else
		{
			hIcon := _TD_hIcon(pTRAYDATA)
			;szTips := _TD_szTips(pTRAYDATA)
			if( !TW_GetToolbarButtonText(g_szShellTrayName, _TB_idCommand(pTBBUTTON), szTips) )
				szTips := ""
			szProcess := _TD_szExePath(pTRAYDATA)
			hWnd := _TD_hWnd(pTRAYDATA)
			nProcessId := GetWindowProcessID(hWnd)
			if( IsTBHidden(pTBBUTTON) )
			{
				if(g_bShowHiddenItems)
					szTips .= "[Hidden]"
				else
					continue
			}
			SetFormat, integer, hex
			hWnd += 0
			SetFormat, integer, d
			DetectHiddenWindows, on
			WinGetTitle, szWndTitle, ahk_id %hWnd%
			DetectHiddenWindows, off
			nIconNumber := DllCall("ImageList_ReplaceIcon", "UInt", g_ImageListID, "int", -1, "UInt", hIcon) + 1
			LV_Add("Icon" . nIconNumber, A_Index-1, szTips, "[" . nProcessId . "] " . szProcess, "[" . hWnd . "] " . szWndTitle)
		}
	}
	
	GuiControl, +Redraw, InfoListView
	LV_ModifyCol()
	return nRtn
}

UpdateTaskBarInfo()
{
	Global g_ImageListID, g_szTaskBarName, InfoListView, g_bShowHiddenItems
	nRtn := 0
	GuiControl, -Redraw, InfoListView
	LV_Delete()
	nButtonCount := TW_GetToolbarButtonCount( g_szTaskBarName )
	Loop, % nButtonCount
	{
		if( !TW_GetToolbarButton( g_szTaskBarName, A_Index-1, pTBBUTTON ) )
		{
			OutputDebug, GetTaskBarToolbarButton failed!
		}
		else
		{
			hWnd := 0
			hIcon := 0
			nProcessId := -1
			nIconNumber := 0
			szProcess := ""
			szWndTitle := ""
			
			hWnd := GetTaskBarButtonBuddyWindowHandle(g_szTaskBarName, pTBBUTTON)
			
			if(!hWnd && !g_bShowHiddenItems)
				continue
			
			if( !TW_GetToolbarButtonText(g_szTaskBarName, _TB_idCommand(pTBBUTTON), szTips) )
				szTips := ""
			
			if(hWnd != 0)
			{
				hIcon := GetWindowHICON( hWnd )

				if( IsTBHidden(pTBBUTTON) )
					szTips .= " [Hidden]"
				WinGet, szProcess, ProcessName, ahk_id %hWnd%
				nProcessId := GetWindowProcessID(hWnd)
				
				DetectHiddenWindows, on
				WinGetTitle, szWndTitle, ahk_id %hWnd%
				DetectHiddenWindows, off
				
				SetFormat, integer, hex
				hWnd += 0
				SetFormat, integer, d
				
				if(hIcon != 0)
					nIconNumber := DllCall("ImageList_ReplaceIcon", "UInt", g_ImageListID, "int", -1, "UInt", hIcon) + 1
			}

			if(hWnd != 0)
				LV_Add(hIcon ? "Icon" . nIconNumber : "Icon999999", A_Index-1, szTips, "[" . nProcessId . "] " . szProcess, "[" . hWnd . "] " . szWndTitle)
			else
				LV_Add("Icon999999", A_Index-1, szTips, "-", "-")
		}
	}
	
	GuiControl, +Redraw, InfoListView
	LV_ModifyCol()
	return nRtn
}
