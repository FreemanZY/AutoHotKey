IfNotExist, RunSetting.ini
{
 ini=%ini%[Settings]
 ini=%ini%`nFolder=.`n `; 设置快捷方式所在位置，一个“.”表示快捷方式和 ahk 文件在一起。
 ini=%ini%`nIsWait=0`n`; 这个参数为 0 的话，使用 run 命令启动程序并暂停一下，否则的话，用 runwait 命令启动程序。
 ini=%ini%`nSleepTime=1`n`; 当 IsWait=0 时才启作用，运行一个程序后暂停多久，单位是秒。
 FileAppend, %ini%, RunSetting.ini
 ini=
}

IniRead, Folder, RunSetting.ini, Settings, Folder
IniRead, IsWait, RunSetting.ini, Settings, IsWait
IniRead, SleepTime, RunSetting.ini, Settings, SleepTime

SleepTime:=SleepTime*1000

Loop, %Folder%\*.lnk
{
	If IsWait=0
	{
		run %Folder%\%A_LoopFileName%
		tooltip %Folder%\%A_LoopFileName%
		sleep %SleepTime%
	}
	else
	{
		runwait %Folder%\%A_LoopFileName%
		tooltip %Folder%\%A_LoopFileName%
	}
}

ExitApp