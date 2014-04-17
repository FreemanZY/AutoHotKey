SetTitleMatchMode, 2 ;设定ahk匹配窗口标题的模式
run c:\Program Files\vim\vim71\gvim.exe ;启动gvim
winactivate, No Name ; 激活此窗口
sleep, 500 ; 延时，确保

send :e d:\Notebook\txt\temp.txt{enter} ;打开笔记文件

sleep, 500
winmove, temp.txt,,-1,-6,1408,1062 ;设置窗口：大小、位置,这些数值需要根据使用者的屏幕分辩率调整,这里是1400 X 1050 分辨率屏幕的一个参考值

WinSet, Style, -0xC00000, temp.txt  ;WS_CAPTION, 去掉title bar
WinSet, Style, 0x10000000, temp.txt ;WS_VISIBLE, 全屏模式

