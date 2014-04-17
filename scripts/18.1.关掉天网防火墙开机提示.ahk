#Persistent

count = 1

SetTimer, CloseSkyNet, 50
return

CloseSkyNet:
IfWinExist, 请购买天网防墙个人版
        ; orz, 竟然少了个“火”字。每个窗口都有一个名字，用 AHK 附带的 window spy 就可以轻松获得窗口名字啦。
{
sleep 1000
WinClose, 请购买天网防墙个人版
ExitApp
        ; 这句就是退出命令啦。
}
else
{
sleep 1000
count := count + 1
if count = 60
ExitApp
}
return

