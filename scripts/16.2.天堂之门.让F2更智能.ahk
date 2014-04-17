; 功能是在按F2的时候自动不选中后缀名，当然前提是你显示所有文件的后缀名。

;用复制获得的绝对路径来判断其是目录还是文件或快捷方式。不知是否还有其他比复制更好的获得绝对路径的方法？因为先复制毕竟有停顿的感觉。
;感谢Helfee和写了BetterRename.ahk的Adam Pash。天堂之门2008年7月27日

;说明：
;首先定义了一个窗口组，并在窗口组激活的情况下自设热键F2，来和系统的F2热键分开，这样能在非重命名状态下通过复制文件或文件夹在剪贴板里获得绝对路径，而绝对路径对后面的分析重命名部分有关键作用。
;分开判断是否为快捷方式是因为系统默认不显示快捷方式的“.lnk”后缀，所以也就不需要分析后缀名来移位。

#SingleInstance,Force
;#NoEnv ;我调用此脚本的另一个脚本已经设置了，所以这里不启用了。
SendMode Input

窗口集合=CabinetWClass,Progman,ExploreWClass,WorkerW,#32770 ;分别为Win+D后的桌面窗口类，桌面，新资源管理器，资源管理器，另存为等
Loop,Parse,窗口集合,`, ;以逗号分隔，循环解析出每部分，逗号前面用了转义符
GroupAdd,窗口组,ahk_class %A_LoopField% ;用循环解析出的字段添加到窗口组

Hotkey, IfWinActive,ahk_group 窗口组 ;在窗口组激活的情况下
Hotkey,F2,分析重命名 ;启用自设热键F2跳转至分析重命名标签
Return

分析重命名:
剪贴板备份 = %ClipboardAll%
Clipboard=
Send, ^c ;为了能在剪贴板取得文件或文件夹的绝对路径
ClipWait,3 ;等待剪贴板有数据不超过3秒
if ErrorLevel ;等待剪贴板有数据时超时
MsgBox, 尝试复制文本到剪贴板失败。`n见鬼~！你就不能选择点什么？`n没事别乱按F2来玩！

Hotkey,F2,Off ;停用自设热键F2
Send,{F2} ;发送系统f2热键来重命名时选中名称

属性字串 := FileExist(Clipboard) ;以剪贴板里获得的文件或文件夹的绝对路径来得到其属性字串
IfNotInString,属性字串,d ;如果属性字串里没有“d”，那么可判断是文件，执行下面区块
{ 
IfNotInString,Clipboard,`.lnk ;如果剪贴板中的绝对路径里没有“.lnk”，执行下面区块
{
StringGetPos,后缀点位置, Clipboard,.,R ;将字串里的“.”的位置输出给变量，如果字串里有多个“.”，那么以右边开始的第一个为准，计数以0开始
左移位数 := StrLen(Clipboard) - 后缀点位置 
Send, +{Left %左移位数%} ;按住Shift再左移
}
}
Clipboard = %剪贴板备份%
Hotkey,F2,On ;启用自设热键
Return
; http://hi.baidu.com/ttzm33/blog/item/bc41f10e8876c8cc7bcbe18b.html
; 作者：天堂之门