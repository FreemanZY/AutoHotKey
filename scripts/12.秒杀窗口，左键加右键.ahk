~LButton & RButton::
        ; 按住不放 A 键再按 B 键的写法是 “A & B”（真的可以这样写哦，真的可以实现这样的快捷键）。“~”在这里是指示原有的左键仍要处理，若不加“~”则左键就失效了。
WinGetClass, class, A
        ; 这个语句是专门对付 Gtalk 的。获得当前活动窗口（最后的 A 参数就是代表当前活动窗口）的类（class）名，并赋值给 class。类名这个词好专业啊。GTalk 的聊天窗口的标题是没有规律的，但它们都是同一类，其类名都是 Chat View。用比喻来说，我们都是同一个“类”，我们都是人类，人这个类又可以细分为很多“类”。
IfInString, class, Chat
        ; 判断 class 中是否含有 chat
{
send !{F4}
return
        ; 有的话，说明很可能（99.9%）是 Gtalk 的聊天窗口啦，发送 Alt + F4 关闭聊天窗口。并且结束脚本。
}
WinGetActiveTitle, Title
        ; 获取当前活动窗口的标题，赋值给 Title
IfInString, Title, Firefox
        ; 判断 Title 中是否含有 Firefox ，无论我们打开什么网页，这个是永远不变的，你也可以试试用类名来判断。文末会介绍怎么获得一个窗口的类名。
{
send ^w
return
}
IfInString, Title, AutoHotkey
{
send {esc}
return
}
else
        ; 这个 else 是多余的，历史遗留问题。orz
WinClose, %Title%
return

