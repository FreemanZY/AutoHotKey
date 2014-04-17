; 显示 / 隐藏 隐藏系统文件：
; 作者： iLEMONed
; http://cn.ilemoned.com/
^!+h::
If value = 1
value = 2
Else
value = 1
RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\, Hidden, %Value%
send { AppsKey } e
return
