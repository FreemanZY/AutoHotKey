; 打开脚本,进入游戏后,按小键盘上的 * ,就禁用了,设置一次就行了.记录在game_list.txt CODELoop, Read,game_list.txt
GroupAdd,game,%A_LoopReadLine%
NumpadMult::
WinGetClass, class, A
FileAppend,ahk_class %class%`n,game_list.txt
RELOAD
return
#IfWinActive,ahk_group game
LWin::return
; 作者：Helfee
; http://hi.baidu.com/helfee/blog/item/a8c5b78f3ade1dedf01f36cd.html