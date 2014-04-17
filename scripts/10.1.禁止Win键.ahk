LWin::return
        ; 这样写的话 LWin （左边的 Win 键）就完全废掉了。

#~LButton::
        ; 快捷键 Win + 左键，没错， AHK 要实现双击判断的话，要用下面的代码
Keywait, LButton, , t0.5
if errorlevel = 1
return
else
Keywait, LButton, d, t0.1
if errorlevel = 0
{
        ; 上面这段代码是来自简睿随笔《科技篇》，作者的解释是这样的，我死活没弄明白：
        ; 用 KeyWait 读取键盘输入，如果 0.5 秒内不是按 LButton 则结束
        ; 0.5 秒内按了 LButton 则再读第二个按键，若为 LButton 则执行下面的代码
        ; 若第二个按键不为 LButton 则结束
sleep 1000
        ; 暂停 1 秒，等待程序运行。机子慢一点的电脑可以把这个时间调大一点。
WinGetActiveTitle, Title
        ; 获得活动窗口的标题，赋值给 Title。这段代码就是根据标题来禁止 LWin 的。
hotkey, LWin, nowin
        ; hotkey 这个函数就是今天重点要讲的。有时候我们需要在不同的情况启用或者禁用自定义的热键。解释一下：这里先用 hotkey 定义了一个新的热键 LWin 。当按下 LWin 的时候，会运行下面的 nowin 代码段。
hotkey, LWin, on
        ; hotkey 另一个用法，启用已定义的热键 LWin。
SetTimer,check,10
        ; 设置一个定时器，间隔 10 毫秒运行一次 check ，check 就是下面的代码片段。这时候会有读者担心，哇，这样 CPU 的占用率不是会非常高？一个 AHk 的脚本会占用 2～4M 的内存，CPU 不会占用。
}
return

check:
        ; 一个代码片段以一个冒号作为标志。复习一下：热键是两个，热字符串是开头两个，结束也是两个。
IfWinNotExist %Title%
        ; 如果名字叫 Title （就是上面获得的）的窗口不存在，也就是被关闭了。
hotkey, LWin, off
        ; 关闭热键 LWin，这一关一开只是实现我们定义的热键的关闭与启用。真正实现屏蔽的是下面的 nowin 代码片段。
return

nowin:
return
        ; 这里一定要分开成两行，一行的话， AHK 死活不认。

