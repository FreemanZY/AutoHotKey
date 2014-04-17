;====================================
; 蓝蓝小雪 作品
; http://wwww.snow518.cn/
; 修改自：http://ahk.5d6d.com/thread-701-1-3.html
; 增加了快捷键、编辑、重载某个单独的脚本
;====================================
#Persistent
#SingleInstance force

SetWorkingDir %A_ScriptDir%\scripts\

DetectHiddenWindows On  ; 允许探测脚本中隐藏的主窗口。
SetTitleMatchMode 2  ; 避免需要指定如下所示的文件的完整路径。

scriptCount = 0

OnExit ExitSub

Menu scripts_unopen, Add, 启动脚本, Menu_Tray_Exit
Menu scripts_unopen, ToggleEnable, 启动脚本
Menu scripts_unopen, Default, 启动脚本
Menu scripts_unopen, Add
Menu scripts_unclose, Add, 关闭脚本, Menu_Tray_Exit
Menu scripts_unclose, ToggleEnable, 关闭脚本
Menu scripts_unclose, Default, 关闭脚本
Menu scripts_unclose, Add
Menu scripts_edit, Add, 编辑脚本, Menu_Tray_Exit
Menu scripts_edit, ToggleEnable, 编辑脚本
Menu scripts_edit, Default, 编辑脚本
Menu scripts_edit, Add
Menu scripts_reload, Add, 重载脚本, Menu_Tray_Exit
Menu scripts_reload, ToggleEnable, 重载脚本
Menu scripts_reload, Default, 重载脚本
Menu scripts_reload, Add

; 遍历scripts目录下的ahk文件
Loop, %A_ScriptDir%\scripts\*.ahk
{
    StringRePlace menuName, A_LoopFileName, .ahk

    scriptCount += 1
    scripts%scriptCount%0 := A_LoopFileName

    IfWinExist %A_LoopFileName% - AutoHotkey    ; 已经打开
    {
        Menu scripts_unclose, add, %menuName%, tsk_close
        scripts%scriptCount%1 = 1
    }
    else
    {
        Menu scripts_unopen, add, %menuName%, tsk_open
        scripts%scriptCount%1 = 0
    }
    Menu scripts_edit, add, %menuName%, tsk_edit
    Menu scripts_reload, add, %menuName%, tsk_reload
}


; 增加管理按钮
Menu, Tray, Icon, %A_ScriptDir%\resources\ahk.ico
Menu, Tray, Click, 1
Menu, Tray, Tip, AHK Script Manager
Menu, Tray, Add, AHK Script Manager, Menu_Show
Menu, Tray, ToggleEnable, AHK Script Manager
Menu, Tray, Default, AHK Script Manager
Menu, Tray, Add
Menu, Tray, Add, 启动所有脚本(&A)`tCtrl + Alt + Shift + Q, tsk_openAll
Menu, Tray, Add, 启动脚本(&O)`tCtrl + Alt + Shift + W, :scripts_unopen
Menu, Tray, Add, 关闭所有脚本(&L)`tCtrl + Alt + Shift + A, tsk_closeAll
Menu, Tray, Add, 关闭脚本(&C)`tCtrl + Alt + Shift + S, :scripts_unclose
Menu, Tray, Add
Menu, Tray, Add, 编辑脚本(&I)`tCtrl + Alt + Shift + E, :scripts_edit
Menu, Tray, Add, 重载脚本(&S)`tCtrl + Alt + Shift + D, :scripts_reload
Menu, Tray, Add
Menu, Tray, Add, 打开伴侣目录(&D)`t%A_ScriptDir%, Menu_Tray_OpenDir
Menu, Tray, Add
Menu, Tray, Add, 重启伴侣(&R), Menu_Tray_Reload
Menu, Tray, Add
Menu, Tray, Add, 编辑代码(&E), Menu_Tray_Edit
Menu, Tray, Add
Menu, Tray, Add, 退出(&X)`tCtrl + Alt + Shift + X, Menu_Tray_Exit
Menu, Tray, NoStandard

GoSub tsk_openAll

Return

tsk_openAll:
Loop, %scriptCount%
{
    thisScript := scripts%A_index%0
    If  scripts%A_index%1 = 0    ;没打开
    {
        ifinstring, thisScript, !
	    continue
        IfWinNotExist %thisScript% - AutoHotkey    ; 没有打开
            Run %A_ScriptDir%\scripts\%thisScript%

        scripts%A_index%1 = 1

        StringRePlace menuName, thisScript, .ahk
        Menu scripts_unclose, add, %menuName%, tsk_close
        Menu scripts_unopen, delete, %menuName%
    }
}
Return

tsk_open:
Loop, %scriptCount%
{
    thisScript := scripts%A_index%0
    If thisScript = %A_thismenuitem%.ahk  ; match found.
    {
        IfWinNotExist %thisScript% - AutoHotkey    ; 没有打开
            Run %A_ScriptDir%\scripts\%thisScript%

        scripts%A_index%1 := 1

        Menu scripts_unclose, add, %A_thismenuitem%, tsk_close
        Menu scripts_unopen, delete, %A_thismenuitem%

        Break
    }
}
Return

tsk_close:
Loop, %scriptCount%
{
    thisScript := scripts%A_index%0
    If thisScript = %A_thismenuitem%.ahk  ; match found.
    {
        WinClose %thisScript% - AutoHotkey
        scripts%A_index%1 := 0

        Menu scripts_unopen, add, %A_thismenuitem%, tsk_open
        Menu scripts_unclose, delete, %A_thismenuitem%

        Break
    }
}
Return

tsk_closeAll:
Loop, %scriptCount%
{
    thisScript := scripts%A_index%0
    If scripts%A_index%1 = 1  ; 已打开
    {
        WinClose %thisScript% - AutoHotkey
        scripts%A_index%1 = 0

        StringRePlace menuName, thisScript, .ahk
        Menu scripts_unopen, add, %menuName%, tsk_open
        Menu scripts_unclose, delete, %menuName%
    }
}
Return

tsk_edit:
Run, edit %A_ScriptDir%\scripts\%A_thismenuitem%.ahk
Return

tsk_reload:
Loop, %scriptCount%
{
    thisScript := scripts%A_index%0
    If thisScript = %A_thismenuitem%.ahk  ; match found.
    {
        WinClose %thisScript% - AutoHotkey
        Run %A_ScriptDir%\scripts\%thisScript%
        Break
    }
}
Return

+^!Z::
    Menu, Tray, Show
Return

+^!X::
	Goto Menu_Tray_Exit
Return

+^!Q::
	Goto tsk_openAll
Return

+^!W::
	Menu, scripts_unopen, Show
Return

+^!A::
	Goto tsk_closeAll
Return

+^!S::
	Menu, scripts_unclose, Show
Return

+^!E::
	Menu, scripts_edit, Show
Return

+^!D::
	Menu, scripts_reload, Show
Return

Menu_Tray_OpenDir:
	Run %A_ScriptDir%
Return

Menu_Tray_Exit:
	ExitApp
Return

Menu_Tray_Reload:
	Reload
Return

Menu_Tray_Edit:
	Edit
Return

ExitSub:
    Loop, %scriptCount%
    {
        thisScript := scripts%A_index%0
        If scripts%A_index%1 = 1  ; 已打开
        {
            WinClose %thisScript% - AutoHotkey
            scripts%A_index%1 = 0

            StringRePlace menuName, thisScript, .ahk
        }
    }
	Menu, Tray, NoIcon
    ExitApp
Return

Menu_Show:
    Menu, Tray, Show
Return