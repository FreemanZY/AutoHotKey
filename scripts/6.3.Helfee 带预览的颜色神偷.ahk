lx := A_ScreenWidth - 110
ly := 60
Gui, +AlwaysOnTop +ToolWindow -caption
;Gui, Add, Text, x1 y25 w35,
Gui, Show,NoActivate W37 H37 X%lx% Y%ly% ,
gosub,color
return
color:
loop
{
MouseGetPos, x, y
PixelGetColor, c, %x%, %y%, RGB
StringRight c,c,6
if c <> %c2%
{
c2 = %c%
Gui, color, %c%
; GUICONTROL,,Static1,%c%
traytip,,WIN+C¸´ÖÆ `n %c%
}
SLEEP,50
}
return
#c::
clipboard = %c%
return
;http://hi.baidu.com/helfee/blog/item/29150ff3a34d02c80a46e0c2.html
;×÷Õß£ºhelfee