LEFT::
MouseGetPos, x, y
        ; 获得鼠标位置，并把获得的 X，Y 坐标分别赋值给 x，y
Mousemove, x-1, y
        ; 移动鼠标，保持 y 坐标不变，向左移动一个像素。
Return

UP::
MouseGetPos, x, y
Mousemove, x, y-1
Return

RIGHT::
MouseGetPos, x, y
Mousemove, x+1, y
Return

DOWN::
MouseGetPos, x, y
Mousemove, x, y+1
Return

