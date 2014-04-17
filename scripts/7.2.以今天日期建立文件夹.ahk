#+f::
        ; 第一行增加快捷键
Click right
Send, wf
Sleep, 125
        ; 把暂停时间改小
clipboard = %A_YYYY%-%A_MM%-%A_DD%
        ; 增加上面这句，把当前的系统日期发送到剪贴板
Send, ^v{Enter}
        ; 发送 Ctrl + v 和回车
return