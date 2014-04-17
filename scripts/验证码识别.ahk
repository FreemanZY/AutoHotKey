/*

**********************************
  验证码识别 v2.0   By：feiyue
**********************************

为了解决：http://www.123shipin.com/register.php

使用说明：先按F1选择验证码范围，然后F4识别，先自动生成字库

*/


#NoEnv
#SingleInstance Force
SetBatchLines, -1
CoordMode, Pixel
CoordMode, Mouse
CoordMode, ToolTip
SetTitleMatchMode, 2
SetWorkingDir, %A_ScriptDir%
IniRead, wt, a.ini, 0, wt, %A_Space%
IniRead, pos, a.ini, 0, pos, %A_Space%

okzhi:=10      ;//阀值设置非常关键，学习取10，使用取25

Return


Esc::      ;//Esc为重启脚本热键
IfWinExist, %A_ScriptName% ahk_class Notepad
{
  PostMessage, 0x111, 3
  Sleep, 500
}
Reload
Return


Pause::Pause      ;//暂停脚本热键，用于调试


F2::Run, Notepad.exe %A_ScriptName%      ;//编辑脚本热键


F1::      ;//选择验证码的范围的启动热键，用鼠标选择
Gui,9: Destroy
Gui,9: +LastFound +AlwaysOnTop
WinSet, Transparent, 10
Gui,9: -Caption +ToolWindow +E0x08000000
Gui,9: Show, NA x0 y0 w%A_ScreenWidth% h%A_ScreenHeight%
;-----------------------------
Gui,8: Destroy
Gui,8: +LastFound +AlwaysOnTop
WinSet, Transparent, 100
Gui,8: -Caption +ToolWindow +E0x08000000
Gui,8: Color, Red
down=0
Loop {
  Sleep, 50
  MouseGetPos, x, y
  if (down=0)
  {
    ToolTip, 按住鼠标左键选择范围！`n取消请按【Ctrl】键
    if GetKeyState("LButton","P")
      down:=1, x1:=x, y1:=y
    if GetKeyState("Ctrl","P")
      Break
  }
  else
  {
    ToolTip, 松开鼠标左键确定范围！
    w:=Abs(x-x1), h:=Abs(y-y1)
    x:=x1<x ? x1:x, y:=y1<y ? y1:y
    Gui,8: Show, NA x%x% y%y% w%w% h%h%
    if not GetKeyState("LButton","P")
      Break
  }
}
ToolTip
Gui,9: Destroy
Gui,8: Destroy
IfEqual, down, 0, Return
MouseGetPos,,, id
WinGetTitle, wt, ahk_id %id%
WinGetClass, wc, ahk_id %id%
WinGetPos, wx, wy,,, ahk_id %id%
wt:=SubStr(wt,1,20)
wt.=(wc="") ? "":" ahk_class " wc
r1:=x-wx, r2:=y-wy, r3:=x+w-1-wx, r4:=y+h-1-wy
pos=%r1%-%r2%-%r3%-%r4%
IniWrite, %wt%, a.ini, 0, wt
IniWrite, %pos%, a.ini, 0, pos
MsgBox, 4096,, 选择范围成功！可以按【F4】识别了！, 2
Return


F4::  ;//主运行热键
if (wt="" or pos="")
{
  MsgBox, 4096,, 还没选择范围，请先按【F1】选择！, 2
  Return
}
WinActivate %wt%
WinWaitActive %wt%,, 3
if (ErrorLevel)
{
  MsgBox, 没有找到窗口！也许是窗口标题变了，请修改a.ini中的wt值
  Return
}
WinGetPos , wx, wy,,, %wt%
StringSplit, r, pos, -
x1:=wx+r1, y1:=wy+r2, x2:=wx+r3, y2:=wy+r4
t1:=A_TickCount

识别结果:=YanZhengMa(X1,Y1,X2,Y2,okzhi,4)

t2:=A_TickCount-t1
MsgBox,4096,, `n识别结果：%识别结果%  耗时：%t2% ms`n,1
Return



;****************** 下面是函数 ******************


getc(x1,y1,x2,y2,ByRef width,ByRef height) {
  SetBatchLines, -1
  nW:=A_ScreenWidth, nH:=A_ScreenHeight
  if (x1<x2)
    left:=x1, right:=x2
  else
    left:=x2, right:=x1
  if (y1<y2)
    top:=y1, end:=y2
  else
    top:=y2, end:=y1
  if (left>nW-1 or top>nH-1 or right<0 or end<0)
    Return, ""
  if (left<0)
    left=0
  if (right>nW-1)
    right:=nW-1
  if (top<0)
    top=0
  if (end>nH-1)
    end:=nH-1
  width:=right-left+1, height:=end-top+1

  if !DllCall("GetModuleHandle", "str", "gdiplus")
    DllCall("LoadLibrary", "str", "gdiplus")
  VarSetCapacity(si, 16, 0), si := Chr(1)
  DllCall("gdiplus\GdiplusStartup", "uintP", pToken, "uint", &si, "uint", 0)

  mDC := DllCall("CreateCompatibleDC", "uint", 0)
  NumPut(VarSetCapacity(bi, 40, 0), bi)
  NumPut(nW, bi, 4)
  NumPut(nH, bi, 8)
  NumPut(32, NumPut(1, bi, 12, "UShort"), 0, "Ushort")
  NumPut(0,  bi,16)
  hBuffer := DllCall("gdi32\CreateDIBSection", "uint", mDC
  , "uint", &bi, "uint", 0, "uintP", pBits, "uint", 0, "uint", 0)

  oldObject := DllCall("SelectObject", "uint", mDC, "uint", hBuffer)
  screenDC := DllCall("GetDC", "uint", 0)
  DllCall("gdi32\BitBlt", "uint", mDC, "int", 0, "int", 0, "int", nW
  , "int", nH, "uint", screenDC, "int", 0, "int", 0, "uint", 0x00CC0020)
  DllCall("ReleaseDC", "uint", 0, "uint", screenDC)

  DllCall("gdiplus\GdipCreateBitmapFromHBITMAP"
  , "uint", hBuffer, "uint", 0, "uintP", pBitmap)

  DllCall("SelectObject", "uint", mDC, "uint", oldObject)
  DllCall("DeleteObject", "uint", hBuffer)
  DllCall("DeleteDC", "uint", screenDC)
  DllCall("DeleteDC", "uint", mDC)

  VarSetCapacity(Rect, 16)
  NumPut(0, Rect, 0, "uint")
  NumPut(0, Rect, 4, "uint")
  NumPut(nW, Rect, 8, "uint")
  NumPut(nH, Rect, 12, "uint")

  VarSetCapacity(BitmapData, 21, 0)
  DllCall("Gdiplus\GdipBitmapLockBits", "uint", pBitmap
  , "uint", &Rect, "uint", 3, "int", 0x26200a, "uint", &BitmapData)
  Stride:=NumGet(BitmapData, 8)
  Scan0:=NumGet(BitmapData, 16)

  ;//生成图像的灰度数组
  arr:=[]
  Loop, %width%
    arr[A_Index]:=[]
  j:=stride-width*4
  i:=top*stride+left*4-4-j
  Loop, %height% {
    y:=A_Index, i+=j
    Loop, %width%
      c:=NumGet(Scan0+0,i+=4)
      , arr[A_Index][y]:=((c>>16&0xFF)*299
        +(c>>8&0xFF)*587+(c&0xFF)*114)//1000
  }

  DllCall("gdiplus\GdipBitmapUnlockBits", "uint", pBitmap, "uint", &BitmapData)
  DllCall("gdiplus\GdipDisposeImage", "uint", pBitmap)

  DllCall("gdiplus\GdiplusShutdown", "uint", pToken)
  if (hModule:=DllCall("GetModuleHandle", "str", "gdiplus"))
    DllCall("FreeLibrary", "uint", hModule)
  Return, arr    ;//返回数组
}


YanZhengMa(x1,y1,x2,y2,okzhi=10000,zishu=4)
{
  cc:=getc(x1,y1,x2,y2,nW,nH)  ;//首先得到图像的灰度数组

;//准备好GUI窗口用于查看归一化效果
k:=(zishu+1)//2
IfWinExist, 查看归一化效果
  Gui, Show, NA
else
{
  Gui, +LastFoundExist
  IfWinExist
    Gui, Destroy
  Gui, +AlwaysOnTop
  Loop, % k*2 {
    j:=Mod(A_Index,k)=1 ? "xm":"x+15"
    Gui, Add, Edit, %j% w150 r17
  }
  x:=A_ScreenWidth-(150+15)*k-15+3
  Gui, Show, NA y0 x%x%, 查看归一化效果
}

;;【第一步】，采用Ostu法二值化，并初步过滤椒盐噪点

;//生成灰度统计直方图，趁机过滤椒盐噪点（与周围八点都有色差）
pp:=[], SeCha:=50    ;//色差阀值越小过滤越多
Loop, 256
  pp[A_Index-1]:=0
Loop, %nH% {
  j:=A_Index
  Loop, %nW% {
    i:=A_Index, c:=cc[i][j]
    Loop {
      if (i=1 or j=1 or i=nW or j=nH)
        Break
      if Abs(c-cc[i-1][j])<SeCha
        Break
      if Abs(c-cc[i+1][j])<SeCha
        Break
      if Abs(c-cc[i][j-1])<SeCha
        Break
      if Abs(c-cc[i][j+1])<SeCha
        Break
      if Abs(c-cc[i-1][j-1])<SeCha
        Break
      if Abs(c-cc[i+1][j-1])<SeCha
        Break
      if Abs(c-cc[i-1][j+1])<SeCha
        Break
      if Abs(c-cc[i+1][j+1])<SeCha
        Break
      c.="-" cc[i-1][j] "-" cc[i+1][j]
       . "-" cc[i][j-1] "-" cc[i][j+1]
       . "-" cc[i-1][j-1] "-" cc[i+1][j-1]
       . "-" cc[i-1][j+1] "-" cc[i+1][j+1]
      Sort, c, D-
      StringSplit, r, c, -
      c:=cc[i][j]:=r5  ;//中值过滤
      Break
    }
    pp[c]++
  }
}
;//Ostu法计算阀值
IP:=IS:=0
Loop 256
  k:=A_Index-1, IP+=k*pp[k], IS+=pp[k]
fmax:=-1, IP1:=IS1:=0
Loop 256 {
  k:=A_Index-1
  if (pp[k]=0)
    continue
  IS1+=pp[k], IS2:=IS-IS1
  if (IS2=0)
    break
  IP1+=k*pp[k], IP2:=IP-IP1
  m1:=IP1/IS1, m2:=IP2/IS2
  sb:=IS1*IS2*(m1-m2)*(m1-m2)
  if (sb>fmax)
    fmax:=sb, ek:=k
}
;//利用阀值将图像数组二值化为黑白图像
Loop, %nH% {
  j:=A_Index
  Loop, %nW%    ;//如果是黑底白字，这改为0:1进行反色
    cc[A_Index][j]:=cc[A_Index][j]<=ek ? 1:0
}

;;【第二步】，简单降噪处理，过滤孤立黑点

Loop, %nH% {
  j:=A_Index
  Loop, %nW% {
    i:=A_Index
    if (cc[i][j]=0)
      Continue
    if !( cc[i-1][j-1]=1 || cc[i][j-1]=1
     || cc[i+1][j-1]=1 || cc[i-1][j]=1 || cc[i+1][j]=1
     || cc[i-1][j+1]=1 || cc[i][j+1]=1 || cc[i+1][j+1]=1 )
      cc[i][j]:=0
  }
}

;;【第三步】，下面是我创新的快速连通域分析

;//初始化一个与图像完全对照的标记数组
aa:=[], n:=1
Loop, %nW%
  aa[A_Index]:=[]
Loop, %nH% {
  j:=A_Index
  Loop, %nW%
    aa[A_Index][j]:=n++
}
;//只用一次扫描便完成标记和生成连通等价关系表
ks:="-"
Loop, %nH% {
  j:=A_Index
  Loop, %nW% {
    i:=A_Index
    if (cc[i][j]=0)
      Continue
    ;//a取左边、上边、左上、右上的最小值
    a:=cc[i-1][j]=1 ? aa[i-1][j] : aa[i][j]
    if (cc[i][j-1]=1 and a>aa[i][j-1])
      a:=aa[i][j-1]
    else
    {
      if (cc[i-1][j-1]=1 and a>aa[i-1][j-1])
        a:=aa[i-1][j-1]
      if (cc[i+1][j-1]=1 and a>aa[i+1][j-1])
        a:=aa[i+1][j-1]
    }
    if (cc[i+1][j]=1)
    {
      aa[i][j]:=a
      Continue
    }
    ;//达到一条线段的最右边，就开始向左生成连通等价关系表
    Loop, %i% {
      if (cc[i][j]=0)
        Break
      ;//用不含等号记录新连通域的一个起始标记
      if !RegExMatch(ks,"[\-=]" a "[\-=]")
        ks.=a "-"
      aa[i][j]:=a, a2:=aa[i][j-1]
      if (cc[i][j-1]=1 and a<>a2)
       and !InStr(ks,"-" a "=" a2 "-")
        ks.=a "=" a2 "-"
      else
      {
        a1:=aa[i-1][j-1], a3:=aa[i+1][j-1]
        if (cc[i-1][j-1]=1 and a<>a1)
         and !InStr(ks,"-" a "=" a1 "-")
          ks.=a "=" a1 "-"
        if (cc[i+1][j-1]=1 and a<>a3)
         and !InStr(ks,"-" a "=" a3 "-")
        ks.=a "=" a3 "-"
      }
      i--
    }
  }
}
;//整理连通等价关系表
zs:="-", num:=0, Stack:=[]  ;//用数组模拟堆栈
Loop, Parse, ks, -
{
  v:=A_LoopField
  if (v="") or InStr(v,"=") or InStr(zs,"-" v ">")
    Continue
  ;//初始的 v 代表新连通域的一个起始标记
  s:="-" v "-", ds:=ks, num++    ;//连通域总共找到了num个
  Loop {
    re1=-(\d+)=%v%-
    re2=-%v%=(\d+)-
    if RegExMatch(ds,re1,r) or RegExMatch(ds,re2,r)
    {
      if !InStr(s,"-" r1 "-")
        s.=r1 "-", Stack.Insert(r1)
      StringReplace, ds, ds, %r%, -, All
    }
    else if Stack.MaxIndex()
      v:=Stack.Remove()
    else Break     ;//循环直到堆栈为空，s可防止重复入栈
  }
  Sort, s, U D-
  s:=Trim(s,"-")
  Loop, Parse, s, -
    zs.=A_LoopField ">" num "-"
}
;//整理连通域标记，并统计连通域的点数直方图
pN:=[]
Loop, %num%
  pN[A_Index]:=0
Loop, %nH% {
  j:=A_Index
  Loop, %nW% {
    i:=A_Index
    if RegExMatch(zs,"-" aa[i][j] ">(\d+)-",r)
      aa[i][j]:=r1, pN[r1]++
    else aa[i][j]:=0
  }
}
zs:="-"
Loop, %num%
  if (pN[A_Index]>=3)  ;//连通域分析可以过滤部分噪点
    zs.=A_Index "-"


;;【第四步】，两种方法自适应分割数字

ss:=wenzi:="", liantongmode:=0, wz_index:=ii:=0
Loop {
  if (++ii>nW)
  {
    ;//竖直分割的份数小于参数zishu时自动换到连通域分割
    if (wz_index<zishu and liantongmode=0)
    {
      liantongmode:=1, wz_index:=0, ii:=0
      Continue
    }
    Break
  }
  s=    ;//s用于获取单条竖线
  Loop, %nH% {
    j:=A_Index, a:=aa[ii][j]
    if (liantongmode=0)
      s.=InStr(zs,"-" a "-") ? 1:0
    else
    {
      if (wenzi="")
        wenzi:=InStr(zs,"-" a "-") ? a:"", s.=wenzi ? 1:0
      else
        s.=(a=wenzi) ? 1:0
    }
  }
  ;//若这一竖向包含文字颜色则继续
  IfInString, s, 1
  {
    ss.=s "`n"
    if (ii<nW)
      Continue
  }
  ;//否则就可能是边缘分割线，先排除空列
  if (ss="")
    Continue
  ;//处理这个字的数据
  n:=InStr(ss,"`n")
  zW:=StrLen(ss)//n  ;//得到字的宽度
  ts=
  Loop, % n-1 {
    i:=A_Index, s:=""
    Loop, %zW%
      s.=SubStr(ss,(A_Index-1)*n+i,1)
    IfInString, s, 1
      ts.=s "`n"
  }
  zH:=StrLen(ts)//(zW+1)  ;//得到字的高度
  ;//验证码所占面积自己限定必须不低于20，可以过滤部分噪点团
  if (zW*zH>=20)
  {
    wz_index++   ;//已处理文字数加一
    wz_%wz_index%:=ss    ;//保存每个字的字符串数据
    wz_%wz_index%_w:=zW  ;//保存每个字的宽度作为合并的依据
  }
  ;//如果是连通域分割，清理当前的连通域
  if (liantongmode=1)
  {
    StringReplace, zs, zs, -%wenzi%-, -
    wenzi:="", ii:=0
  }
  ss=    ;//清空为下一个字做准备
}

;//竖直分割的份数大于参数zishu时，考虑合并被切为两半的数字
if (wz_index>zishu and liantongmode=0)
{
  w:=0
  Loop, %wz_index%
    w+=wz_%A_index%_w  ;//得到所有宽度之和
  w:=Round(w/zishu)        ;//得到字的平均宽度
  Loop, %wz_index% {
    k:=A_Index, i:=k-1, j:=k+1
    if (wz_%k%_w<w//2)   ;//合并到前面或后面
    {
      if (k=1)
        wz_%j%:=wz_%k% . wz_%j%, wz_%j%_w+=wz_%k%_w
      else if (k=wz_index)
        wz_%i%.=wz_%k%
      else if (wz_%i%_w<wz_%j%_w)
        wz_%i%.=wz_%k%
      else
        wz_%j%:=wz_%k% . wz_%j%, wz_%j%_w+=wz_%k%_w
      wz_%k%:="", wz_%k%_w:=w*4
    }
  }
}

;;【第五步】，开始循环识别每一个字，同时进行识别和学习。

result:="", this_index:=0
Loop, %wz_index% {
  ss:=wz_%A_Index%
  IfEqual, ss,, Continue
  this_index++
  ;//处理这个字的数据
  n:=InStr(ss,"`n")
  zW:=StrLen(ss)//n  ;//得到字的宽度
  ts=
  Loop, % n-1 {
    i:=A_Index, s:=""
    Loop, %zW%
      s.=SubStr(ss,(A_Index-1)*n+i,1)
    IfInString, s, 1
      ts.=s . "`n"
  }
  zH:=StrLen(ts)//(zW+1)  ;//得到字的高度


;;//先归一化成统一的大小16*16

if (zH>zW)
{
  ;//使宽度和高度相等，缩放图像不致变形
  k1:=(zH-zW)//2, k2:=zH-zW-k1, zW:=zH
  t1:=t2:=""
  Loop, %k1%
    t1.="0"
  Loop, %k2%
    t2.="0"
  s:=SubStr(ts,1,-1), ts:=""
  Loop, Parse, s, `n
    ts.=t1 . A_LoopField . t2 . "`n"
}
s:=RegExReplace(ts,"\n")
gc:=[], fx:=zW/16, fy:=zH/16
Loop, 16 {
  i:=A_Index, gc[i]:=[]
  Loop, 16 {
    j:=A_Index, x:=i*fx, y:=j*fy
    m:=x-Floor(x), n:=y-Floor(y)
    x:=Floor(x), y:=Floor(y)
    ;// l：左；u：上；r：右；d：下
    lu:=(x=0 or y=0) ? 0:SubStr(s,(y-1)*zW+x,1)
    ld:=(x=0 or y=zH) ? 0:SubStr(s,y*zW+x,1)
    ru:=(x=zW or y=0) ? 0:SubStr(s,(y-1)*zW+x+1,1)
    rd:=(x=zW or y=zH) ? 0:SubStr(s,y*zW+x+1,1)
    pix:=(1-m)*(1-n)*lu+(1-m)*n*ld+m*(1-n)*ru+m*n*rd
    gc[i][j]:=( pix>0.33 ) ? 1:0    ;//这个阀值也可取0.5
  }
}

;//生成16*16=256长度的加权特征数组
mb:=[], k:=0
Loop, 16 {
  j:=A_Index
  Loop, 16 {
    i:=A_Index, m:=0
    m+=gc[i-1][j-1]
    m+=gc[i][j-1]
    m+=gc[i+1][j-1]
    m+=gc[i-1][j]
    m+=gc[i][j]
    m+=gc[i+1][j]
    m+=gc[i-1][j+1]
    m+=gc[i][j+1]
    m+=gc[i+1][j+1]
    mb[++k]:=m
  }
}

;;//与字库中的模板比较，得到差距最小的
small:=1000000, wz:=""
Loop, read, 字库.txt
{
  v:=A_LoopReadLine
  IfNotInString, v, =, Continue
  StringSplit, r, v, =
  n1:=n2:=n3:=0    ;//允许每个模板左右平移一次来匹配
  Loop, Parse, r2
  {
    i:=A_Index, k:=A_LoopField
    n1+=Abs(k-mb[i])<4 ? 0:1
    if Mod(i,16)<>1        ;//模板左移一位
      n2+=Abs(k-mb[i-1])<4 ? 0:1
    if Mod(i,16)<>0        ;//模板右移一位
      n3+=Abs(k-mb[i+1])<4 ? 0:1
    if (n1>small and n2>small and n3>small)
      Break
  }
  n1:=n1<n2 ? n1:n2, n1:=n1<n3 ? n1:n3
  if (n1<small)
    small:=n1, wz:=r1
  if (small=0)
    Break
}

;//用于显示归一化效果及匹配结果
ws=
Loop, 16 {
  j:=A_Index
  Loop, 16
    ws.=gc[A_Index][j]
  ws.="`r`n"
}
tip:=" " wz "-" small
ws:=RegExReplace(RegExReplace(ws,"0","_"),"1","0")
GuiControl,, Edit%this_index%, %ws%`r`n%tip%

if (small<=okzhi)  ;//阀值决定匹配成功还是添加新字库
{
  result.=wz
  Continue
}

;//所有模板的比较全部超出了阀值，就生成新模板添加到字库中
  ToolTip, % RegExReplace(RegExReplace(ts,"0","_"),"1","0")
  InputBox, wz,,确认文字`n%tip%
  ToolTip
  IfEqual, wz,, Continue
  result.=wz
  mbs=
  Loop, % mb.MaxIndex()
    mbs.=mb[A_Index]
  cs:="`n", k:=wz "=" mbs "`n`n"
  FileRead, s, 字库.txt
  Loop, Parse, s, `n, `r
  {
    v:=A_LoopField
    IfInString, v, %wz%=
      cs.=k, k:=""
    if (v<>"")
      cs.=v "`n`n"
  }
  cs.=k
  FileDelete, 字库.txt
  FileAppend, %cs%, 字库.txt
}
  Return, result
}


;//程序结束