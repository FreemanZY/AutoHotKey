; 显示 / 隐藏 文件扩展名：
; 作者： iLEMONed
; http://cn.ilemoned.com/

^!+e::
If value = 0
value = 1
Else
value = 0
RegWrite, REG_DWORD, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\, HideFileExt, %Value%
send { AppsKey } e
        ; 点击键盘上的 AppsKey ，弹出右键，选择“刷新(e)” 。
return
