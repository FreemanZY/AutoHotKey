Loop
{
	FileReadLine, TargetURL, urls.txt, %A_Index%
	; 读取文件 urls.txt 的每一行，放到变量 TargetURL 里面，这个 urls.txt 中，一个网址放在一行。
	if ErrorLevel
		break
	; 如果找不到文件的话，跳出循环。
	IfNotExist %A_Index%1.txt
	{
		UrlDownloadToFile, %TargetURL%, %A_Index%1.html
		; 把网址下载为文件
		FileRead, TempVar, %A_Index%1.html
		; 读取下载到的文件
		FileDelete, %A_Index%1.html
		; 删除下载到的文件
		Transform, Clipboard, Unicode, %TempVar%
		; 利用剪贴板把 utf-8 转换为 Unicode
		FileAppend, %Clipboard%, %A_Index%1.txt
		; 把剪贴板的文字写入一个 txt，就变成 gb2312 编码了，
	}
	else IfNotExist %A_Index%2.txt
	{
		UrlDownloadToFile, %TargetURL%, %A_Index%2.html
		FileRead, TempVar, %A_Index%2.html
		FileDelete, %A_Index%2.html
		Transform, Clipboard, Unicode, %TempVar%
		FileAppend, %Clipboard%, %A_Index%2.txt
		RunWait %ComSpec% /c "fc %A_Index%1.txt %A_Index%2.txt > %A_Index%3.txt"
		; 利用命令行提示符（%ComSpec%）的 fc 命令比较文件的不同，把比较结果写入一个 txt
		run %A_Index%3.txt
		; 打开结果
	}
	else
	{
		FileDelete, %A_Index%1.txt 
		FileMove, %A_Index%2.txt,%A_Index%1.txt
		UrlDownloadToFile, %TargetURL%, %A_Index%2.html
		FileRead, TempVar, %A_Index%2.html
		FileDelete, %A_Index%2.html
		Transform, Clipboard, Unicode, %TempVar%
		FileAppend, %Clipboard%, %A_Index%2.txt
		RunWait %ComSpec% /c "fc %A_Index%1.txt %A_Index%2.txt > %A_Index%3.txt"
		run %A_Index%3.txt
	}
}

; Author：sfufoet - 小众软件 - http://www.appinn.com