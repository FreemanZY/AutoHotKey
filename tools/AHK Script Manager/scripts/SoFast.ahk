;原作者：sfufoet
;====================================
; 蓝蓝小雪 修改作品
; http://wwww.snow518.cn/
;====================================

#Persistent
#SingleInstance
; 保证程序一直运行
Menu,Tray,NoStandard
Menu,Tray,DeleteAll
; 删除 AutoHotKey 默认的托盘图标右键菜单
Menu,Tray,Add,检查(&R), mycheck
Menu,Tray,Add
Menu,Tray,Add,编辑(&E)..., editme
Menu,Tray,Add
Menu,Tray,Add,退出(&X), Exit
Menu,Tray,Add
Menu,Tray,Tip,博客更新检查工具
Menu,Tray,Default, 检查(&R)
Menu,Tray,Click,1
icon=F
changed=F
count=0
; 每一分钟运行一次 loopcheck，这个数字请根据需要修改，单位是毫秒，如果你想手工检查的话，右击托盘图标，选择“检查”
app := SubStr(A_ScriptName, 1, StrLen(A_ScriptName) - 4)
iniFile = %app%.ini

iconNone=%app%_none.ico
iconNew=%app%_new.ico
iconNormal=%app%.ico
Menu,Tray,Icon,%iconNormal%

SetTimer, changeicon, 500
SetTimer, loopcheck,60000
Return

mycheck:
gosub loopcheck
Return

loopcheck:
Loop
{
	FileReadLine, TargetURL, %iniFile%, %A_Index%
	; 读取文件 urls.txt 的每一行，放到变量 TargetURL 里面，这个 urls.txt 中，一个网址放在一行。
	if ErrorLevel
		break
	; 如果找不到文件的话，跳出循环。

	nowf=%TargetURL%
	StringReplace,nowf,nowf,\,_,All
	StringReplace,nowf,nowf,/,_,All
	StringReplace,nowf,nowf,:,_,All
	StringReplace,nowf,nowf,*,_,All
	StringReplace,nowf,nowf,?,_,All
	StringReplace,nowf,nowf,`",_,All
	StringReplace,nowf,nowf,<,_,All
	StringReplace,nowf,nowf,>,_,All
	StringReplace,nowf,nowf,|,_,All

	UrlDownloadToFile, %TargetURL%, %app%_data\%nowf%.txt
	; 下载读取到的网址到一个以循环数（A_Index）命名的 txt 中。
	FileRead, alltext, %app%_data\%nowf%.txt
	; 把读取下载到的文件到 alltext
	;SplitText=<div id="content">
	SplitText=<div class="post"
	; 设置分割字符串，以 Wordpres 中最常见的的标记。
	StringGetPos, textPos, alltext, %SplitText%
	if textPos < 0
	{
		SplitText=<div id="content">
		StringGetPos, textPos, alltext, %SplitText%
	}
	; 获得 SplitText 在 alltext 中的位置
	StringTrimLeft, alltext, alltext, %textPos%
	; 去除 <div id="content"> 之前的所有字符。
	RegExMatch(alltext, "http://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)?",URL)
	; 在剩下的文字中用正则表达式（不懂的朋友请搜索）匹配网址。
	IfNotExist %app%_data\%nowf%_url.txt
	{
		FileAppend, %URL%, %app%_data\%nowf%_url.txt
	}
	; 如果文件不存在，把匹配到的网址写入一个 txt
	else
	{
	; 如果文件存在，先读取，然后删除，再比较读取的数据和匹配到的数据是不是一样的。
		FileRead, temp, %app%_data\%nowf%_url.txt
		FileDelete, %app%_data\%nowf%_url.txt
		FileAppend, %URL%, %app%_data\%nowf%_url.txt
		if (URL<>temp)
		{
			traytip,[%TargetURL%] 刚刚更新了～！,%URL% ,,1
			menu,tray,add,%URL%,show
			count:=count+1
			;run %URL%
			; 不一样的话，弹出气泡提示，并运行匹配到的网址，也就是直接打开新文章。
		}
	}
}
return

changeicon:
if count=0
{
	if changed=F
	{
		menu,tray,icon,%iconNormal%
		changed=T
	}
}
else
{
	changed=F
	if icon=F
	{
		menu,tray,icon,%iconNew%
		icon=T
	}
	else
	{
		menu,tray,icon,%iconNone%
		icon=F
	}
}
return

editme:
Run, edit %A_ScriptDir%\%app%.ini
return

show:
Run %A_ThisMenuItem%
Menu,Tray,Delete,%A_ThisMenuItem%
count:=count-1
Return

Exit:
ExitApp
