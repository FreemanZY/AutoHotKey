CoordMode Mouse, Screen
	;设置鼠标的坐标系统，以屏幕为绝对坐标。

^LButton::
MouseGetPos x0, y0, id0                    ; 鼠标开始拖动的位置
Loop
{
Sleep 20                            ; 暂停 20 毫秒
GetKeyState, keystate, LButton, p         ; 获得左键的按键状态
IfEqual, keystate, U, {
MouseGetPos, x1, y1                 ; 鼠标左键松开时候的位置
WinActivate Appinn.com         ; 激活标题包含 Appinn.com 的程序
        ; 假设光标已经在第一个输入框里
clipboard = %x0%, %y0%
clipwait
send ^v
send {tab}
        ; 发送其他三个坐标的代码我就不列出了，请自行补完。
break        ; 最后不要忘记跳出循环哦。
}
}
return

