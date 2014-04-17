; 特别提示，不兼容带有A盘的系统。
DriveGet, DriverList, list,REMOVABLE
	; 获得移动设备的盘符，如果你有两个移动设备，它们的盘符分别是 H: 和 I: 的话，那么这里 DriverList 的值是：HI。
StringSplit, DriverListArray, DriverList
	; 把 DriverList 的值进行字符串分解，后面不带任何要分割的符号的话，表示按照一个字母一个字母来分解，这样我们就可以得到每一个盘符了。
loop %DriverListArray0%
{
RegRead, UnlockerPath, HKEY_LOCAL_MACHINE, SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Unlocker, DisplayIcon
	; 读取注册表，获得 Unlocker.exe 所在路径。
target = % DriverListArray%A_Index% . ":"
	; 从后面开始解释：
	; . ":"，连接一个字符串“：”
	; %A_Index%，表示当前循环到第几次
	; % DriverListArray%A_Index%，表示第 N 个移动磁盘
runwait %UnlockerPath% %target% /s
run %A_ScriptDir%\unplug.exe %target%
	; %A_ScriptDir%，代表当前脚本所在的文件夹
}
TrayTip,,所有移动设备全部弹出！,3000
	; 弹出气泡提示，3 秒后气泡消失。TrayTip 的完整语法是：TrayTip [, 标题, 文字, 时间, Options]

sleep 3000