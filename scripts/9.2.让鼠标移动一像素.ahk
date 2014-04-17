Left::  MouseMove, -1,  0,, R
        ; MouseMove 的完整语法是：
        ; MouseMove, X, Y [, Speed, R]
        ; X - X 坐标；Y - Y 坐标；[ ] 里面的是可选参数，Speed - 移动的速度，其范围是 0 - 100，不填写任何数字的话，参数默认是 0 ，最快速移动；最后的 R 表示前面的参数 X、Y 是相对鼠标当前位置，如果不带这个参数， X、Y 就表示屏幕上的坐标。讲起来很啰嗦，大家比较上面的代码就明白。
Up::    MouseMove,  0, -1,, R
Right:: MouseMove,  1,  0,, R
Down::  MouseMove,  0,  1,, R
