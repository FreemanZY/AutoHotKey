#Persistent
settimer,copy,1
return
        ; 小提示，如果你看不懂这些代码请回头看看 AHK 快餐店系列文章。

copy:
FileCopy,D:\QQ\QQMusicData\Temp\UserList*.tmp, E:\桌面\temp, 1
        ; 请注意修改 QQ 的路径。后面的 E:\桌面\temp 是文件复制到哪里去。1，代表覆盖同名文件，反之就是 0。
IfExist E:\桌面\temp\UserList.tmp
        ; E:\桌面\temp\UserList.tmp 这个文件名可能是 UserList7.tmp 之类的。
{
settimer,copy, off
        ; 关闭计时器
Loop
{
FileReadLine, line, E:\桌面\temp\UserList.tmp, %A_Index%
        ; 读取文件的每一行，放到变量 line 里面
if ErrorLevel
break
        ; 如果找不到文件的话，跳出循环。
RegExMatch(line, “http://(.*).wma”,URL)
        ; 利用正则表达式提取 line 中的地址。提取后的地址放在 URL 中。
if (StrLen(URL)<>0)
URLs=%URLs%%URL%`n
        ; 如果 URL 的长度不等于 0 ，说明找到地址了，加上一个回车（`n）并把 每一个 URL 合并到 URLs 里面
}
FileAppend , %URLs%, E:\桌面\temp\MusicURL.lst
        ; 把 URLs 的值写到 MusicURL.lst 里面
}
return

