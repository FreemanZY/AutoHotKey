#j::
send ^c
        ; 复制选中的文字
clipwait
        ; 等待复制动作的完成
StringReplace, clipboard, clipboard, ＼,　\, All
        ; 网络一些文章很不严谨，“＼”“\”不分。替换掉剪贴板中所有的“＼”，并且再把替换后的文字发送到剪贴板。
RegWrite, REG_SZ, HKEY_CURRENT_USER, Software\Microsoft\Windows\CurrentVersion\Applets\Regedit, LastKey, 我的电脑\%clipboard%
        ; 把负责注册表最近打开的键值修改为剪贴板中的路径。参数 REG_SZ 就是右上角图片中 LastKey 的类型。HKEY_CURRENT_USER 就是目标注册表分支，接着的参数是目标路径，然后是要修改的键，最后是要修改的值。
run regedit
        ; 运行注册表
return