#Persistent
; 保证程序一直运行
Menu,Tray,NoStandard
Menu,Tray,DeleteAll
; 删除 AutoHotKey 默认的托盘图标右键菜单
Menu,Tray,Add,检查, loopcheck
Menu,Tray,Add,退出, Exit
SetTimer, loopcheck,60000
; 每一分钟运行一次 loopcheck，这个数字请根据需要修改，单位是毫秒，如果你想手工检查的话，右击托盘图标，选择“检查”

loopcheck:
Loop
{
	FileReadLine, TargetURL, urls.txt, %A_Index%
	; 读取文件 urls.txt 的每一行，放到变量 TargetURL 里面，这个 urls.txt 中，一个网址放在一行。
	if ErrorLevel
		break
	; 如果找不到文件的话，跳出循环。
	UrlDownloadToFile, %TargetURL%, %A_Index%.txt
	; 下载读取到的网址到一个以循环数（A_Index）命名的 txt 中。
	FileRead, alltext, %A_Index%.txt
	; 把读取下载到的文件到 alltext
	SplitText=<div id="content">
	; 设置分割字符串，以 Wordpres 中最常见的的标记。
	StringGetPos, textPos, alltext, %SplitText%
	; 获得 SplitText 在 alltext 中的位置
	StringTrimLeft, alltext, alltext, %textPos%
	; 去除 <div id="content"> 之前的所有字符。
	RegExMatch(alltext, "http://([\w-]+\.)+[\w-]+(/[\w- ./?%&=]*)?",URL)
	; 在剩下的文字中用正则表达式（不懂的朋友请搜索）匹配网址。
	IfNotExist %A_Index%1.txt
	{
		FileAppend, %URL%, %A_Index%1.txt
	}
	; 如果文件不存在，把匹配到的网址写入一个 txt
	else
	{
	; 如果文件存在，先读取，然后删除，再比较读取的数据和匹配到的数据是不是一样的。
		FileRead, temp, %A_Index%1.txt
		FileDelete, %A_Index%1.txt 
		FileAppend, %URL%, %A_Index%1.txt
		if (URL<>temp)
		{
			traytip,, %TargetURL% 刚刚更新！
			run %URL%
			; 不一样的话，弹出气泡提示，并运行匹配到的网址，也就是直接打开新文章。
		}
	}
}
return

Exit:
ExitApp

; Author：sfufoet - 小众软件 - http://www.appinn.com