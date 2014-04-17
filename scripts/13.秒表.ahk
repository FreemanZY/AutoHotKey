#SingleInstance Force
#Persistent
SetBatchLines -1
DetectHiddenWindows, On
Gosub, TrayMenu
FileSetAttrib, -A, StopWatch.ini
SetTimer, UpdatedScript
IfNotExist, StopWatch.ini
   {
   IniWrite, Center, StopWatch.ini, Settings, xPos
   IniWrite, Center, StopWatch.ini, Settings, yPos
   IniWrite, Lime, StopWatch.ini, Settings, Text_Color
   IniWrite, 0, StopWatch.ini, Settings, Msec
   IniWrite, 00, StopWatch.ini, Settings, Sec
   IniWrite, 00, StopWatch.ini, Settings, Min
   IniWrite, 00, StopWatch.ini, Settings, Hour
   IniWrite, Off, StopWatch.ini, Settings, Transparent
   IniWrite, 13, StopWatch.ini, Settings, Text_Size
   IniWrite, Black, StopWatch.ini, Settings, Background_Color
   IniWrite, Off, StopWatch.ini, Settings, Always_On_Top
   }
IfExist, StopWatch.ini
   {
   IniRead, xPos, StopWatch.ini, Settings, xPos
   IniRead, yPos, StopWatch.ini, Settings, yPos
   IniRead, Text_Color, StopWatch.ini, Settings, Text_Color
   IniRead, Msec, StopWatch.ini, Settings, Msec
   IniRead, Sec, StopWatch.ini, Settings, Sec
   IniRead, Min, StopWatch.ini, Settings, Min
   IniRead, Hour, StopWatch.ini, Settings, Hour
   IniRead, Background_Color, StopWatch.ini, Settings, Background_Color
   IniRead, Text_Size, StopWatch.ini, Settings, Text_Size
   IniRead, Transparent, StopWatch.ini, Settings, Transparent
   IniRead, Always_On_Top, StopWatch.ini, Settings, Always_On_Top
   }
Text_Color_Check = %Text_Color%
If Text_Color_Check = FF8000
   Text_Color_Check = Orange
Menu, TextColor_%Text_Color_Check%, Check, %Text_Color_Check%
Background_Color_Check = %Background_Color%
If Background_Color_Check = FF8000
   Background_Color_Check = Orange
Menu, BackgroundColor_%Background_Color_Check%, Check, %Background_Color_Check%
Menu, Transparent, Check, %Transparent%
Menu, TextSize, Check, %Text_Size%
Menu, Always_On_Top, Check, %Always_On_Top%
Menu, BackgroundColor, ToggleEnable, %Text_Color_Check%
Menu, TextColor, ToggleEnable, %Background_Color_Check%
If Always_On_Top = On
   AlwaysOnTop = +AlwaysOnTop
If Always_On_Top = Off
   AlwaysOnTop =
HourMinSec = %Hour%%Min%%Sec%%Msec%
If HourMinSec = 0000000
   Menu, Tray, Disable, Clear
Gui, Color, %Background_Color%
Gui, Font, c%Text_Color% s%Text_Size% Bold
Gui, Add, Text, , %Hour%:%Min%:%Sec%.%Msec%
If Transparent = Off
   {
   Gui, +ToolWindow +Border %AlwaysOnTop% 
   If Text_Size = 13
      {
      Gui, Font, cBlack s7 Normal
      Gui, Add, Button, y+5 w38 h20, Start
      Gui, Add, Button, x+10 w38 h20, Stop
      }
   If Text_Size = 15
      {
      Gui, Font, cBlack s7 Normal
      Gui, Add, Button, y+5 w45 h20, Start
      Gui, Add, Button, x+13 w45 h20, Stop
      }
   If Text_Size = 18
      {
      Gui, Font, cBlack s8 Normal
      Gui, Add, Button, y+5 w50 h22, Start
      Gui, Add, Button, x+18 w50 h22, Stop
      }
   If Text_Size = 20
      {
      Gui, Font, cBlack s10 bold
      Gui, Add, Button, y+10 w60 h25, Start
      Gui, Add, Button, x+18 w60 h25, Stop
      }
   If Text_Size = 25
      {
      Gui, Font, cBlack s12 bold
      Gui, Add, Button, y+10 w65 h30, Start
      Gui, Add, Button, x+30 w65 h30, Stop
      }
   If Text_Size = 30
      {
      Gui, Font, cBlack s14 bold
      Gui, Add, Button, y+10 w78 h35, Start
      Gui, Add, Button, x+36 w78 h35, Stop
      }
   If Text_Size = 35
      {
      Gui, Font, cBlack s17 bold
      Gui, Add, Button, y+10 w90 h40, Start
      Gui, Add, Button, x+47 w90 h40, Stop
      }
   }
If Transparent = On
   {
   WinSet, TransColor, %Background_Color% 255, StopWatch
   Gui, +ToolWindow -SysMenu -Caption %AlwaysOnTop% 
   }
Gui, Show, x%xPos% y%yPos%, StopWatch 
Return



UpdatedScript:
FileGetAttrib, Attribs, StopWatch.ini
IfInString, Attribs, A 
   { 
   IniWrite, %Msec%, StopWatch.ini, Settings, Msec
   IniWrite, %Sec%, StopWatch.ini, Settings, Sec
   IniWrite, %Min%, StopWatch.ini, Settings, Min
   IniWrite, %Hour%, StopWatch.ini, Settings, Hour
   FileSetAttrib, -A, StopWatch.ini
   Reload 
   } 
Return 

   

F9::
Start:
ButtonStart:
WinActivate, StopWatch
Critical, On
StringLeft, Old, A_MSec, 1 
SetTimer, Loop, 50 
Menu, Tray, NoIcon
GuiControl, Disable, Button1
GuiControlGet, Stop_Clear, , Button2
If Stop_Clear = Clear
   GuiControl, , Button2, Stop
Menu, Tray, Enable, Clear
Return



Loop:
StringLeft, New, A_MSec, 1 
If (New = Old) 
    Return 
StringLeft, Old, A_MSec, 1 
Msec += 1
If Msec >= 10
   {
   Msec = 0
   Sec += 1
   }
StringLen, Sec_SL, Sec
If Sec_SL = 1   
   Sec = 0%Sec%
If Sec >= 60
   {
   Sec = 00
   Min += 01
   }
StringLen, Min_SL, Min
If Min_SL = 1   
   Min = 0%Min%
If Min >= 60
   {
   Min = 00
   Hour += 01
   }
StringLen, Hour_SL, Hour
If Hour_SL = 1
   Hour = 0%Hour%
GuiControl, , Static1, %Hour%:%Min%:%Sec%.%Msec%
Return



F10::
ButtonStop:
WinActivate, StopWatch 
GuiControlGet, Stop_Clear, , Button2
If Stop_Clear = Clear
   Goto, ButtonClear
SetTimer, Loop, Off
GuiControl, Enable, Button1
GuiControl, , Button2, Clear
Menu, Tray, Icon
Return



F11::
ButtonClear:
WinActivate, StopWatch
GuiControlGet, Stop_Clear, , Button2
If Stop_Clear = Stop
   Goto, ButtonStop
GuiControl, Enable, Button1
Menu, Tray, ToggleEnable, Clear
Msec = 0
Sec = 00
Min = 00
Hour = 00
GuiControl, , %Time%, %Hour%:%Min%:%Sec%.%Msec%
Return



F12::
Goto, Exit



TrayMenu:
Menu, Tray, MainWindow
Menu, Tray, NoStandard 
Menu, Tray, DeleteAll 
Menu, Tray, Add, StopWatch, StopWatch
Menu, Tray, Add
Menu, Tray, Add, Start, Start
Menu, Tray, Add, Clear, ButtonClear
Menu, TextColor_Black, Add, Black
Menu, TextColor, Add, Black, :TextColor_Black
Menu, TextColor_Black, Color, Black
Menu, TextColor_White, Add, White
Menu, TextColor, Add, White, :TextColor_White
Menu, TextColor_White, Color, White
Menu, TextColor_Red, Add, Red
Menu, TextColor, Add, Red, :TextColor_Red
Menu, TextColor_Red, Color, Red
Menu, TextColor_Blue, Add, Blue
Menu, TextColor, Add, Blue, :TextColor_Blue
Menu, TextColor_Blue, Color, Blue
Menu, TextColor_Green, Add, Green
Menu, TextColor, Add, Green, :TextColor_Green
Menu, TextColor_Green, Color, Green
Menu, TextColor_Orange, Add, Orange
Menu, TextColor, Add, Orange, :TextColor_Orange
Menu, TextColor_Orange, Color, FF8000
Menu, TextColor_Yellow, Add, Yellow
Menu, TextColor, Add, Yellow, :TextColor_Yellow
Menu, TextColor_Yellow, Color, Yellow
Menu, TextColor_Gray, Add, Gray
Menu, TextColor, Add, Gray, :TextColor_Gray
Menu, TextColor_Gray, Color, Gray
Menu, TextColor_Lime, Add, Lime
Menu, TextColor, Add, Lime, :TextColor_Lime
Menu, TextColor_Lime, Color, Lime
Menu, TextColor_Navy, Add, Navy
Menu, TextColor, Add, Navy, :TextColor_Navy
Menu, TextColor_Navy, Color, Navy
Menu, Tray, Add, Text Color, :TextColor
Menu, BackgroundColor_Black, Add, Black
Menu, BackgroundColor, Add, Black, :BackgroundColor_Black
Menu, BackgroundColor_Black, Color, Black
Menu, BackgroundColor_White, Add, White
Menu, BackgroundColor, Add, White, :BackgroundColor_White
Menu, BackgroundColor_White, Color, White
Menu, BackgroundColor_Red, Add, Red
Menu, BackgroundColor, Add, Red, :BackgroundColor_Red
Menu, BackgroundColor_Red, Color, Red
Menu, BackgroundColor_Blue, Add, Blue
Menu, BackgroundColor, Add, Blue, :BackgroundColor_Blue
Menu, BackgroundColor_Blue, Color, Blue
Menu, BackgroundColor_Green, Add, Green
Menu, BackgroundColor, Add, Green, :BackgroundColor_Green
Menu, BackgroundColor_Green, Color, Green
Menu, BackgroundColor_Orange, Add, Orange
Menu, BackgroundColor, Add, Orange, :BackgroundColor_Orange
Menu, BackgroundColor_Orange, Color, FF8000
Menu, BackgroundColor_Yellow, Add, Yellow
Menu, BackgroundColor, Add, Yellow, :BackgroundColor_Yellow
Menu, BackgroundColor_Yellow, Color, Yellow
Menu, BackgroundColor_Gray, Add, Gray
Menu, BackgroundColor, Add, Gray, :BackgroundColor_Gray
Menu, BackgroundColor_Gray, Color, Gray
Menu, BackgroundColor_Lime, Add, Lime
Menu, BackgroundColor, Add, Lime, :BackgroundColor_Lime
Menu, BackgroundColor_Lime, Color, Lime
Menu, BackgroundColor_Navy, Add, Navy
Menu, BackgroundColor, Add, Navy, :BackgroundColor_Navy
Menu, BackgroundColor_Navy, Color, Navy
Menu, Tray, Add, Background Color, :BackgroundColor
Menu, TextSize, Add, 13
Menu, TextSize, Add, 15
Menu, TextSize, Add, 18
Menu, TextSize, Add, 20
Menu, TextSize, Add, 25
Menu, TextSize, Add, 30
Menu, TextSize, Add, 35
Menu, Tray, Add, Text Size, :TextSize
Menu, Transparent, Add, On
Menu, Transparent, Add, Off
Menu, Tray, Add, Transparent, :Transparent
Menu, Always_On_Top, Add, On
Menu, Always_On_Top, Add, Off
Menu, Tray, Add, Always on Top, :Always_On_Top
Menu, Tray, Add, Hide, Hide
Menu, Tray, Add, Show, Show
Menu, Tray, Add, HotKeys, HotKeys
Menu, Tray, Add, Exit, Exit
Menu, Tray, Disable, Show
Menu, Tray, Default, StopWatch 
Return


StopWatch:
Gui, Show, , StopWatch
Return


Black:
If A_ThisMenu = TextColor_Black
   IniWrite, Black, StopWatch.ini, Settings, Text_Color
If A_ThisMenu = BackgroundColor_Black
   IniWrite, Black, StopWatch.ini, Settings, Background_Color
Gosub, Menu_Change
Return


White:
If A_ThisMenu = TextColor_White
   IniWrite, White, StopWatch.ini, Settings, Text_Color
If A_ThisMenu = BackgroundColor_White
   IniWrite, White, StopWatch.ini, Settings, Background_Color
Gosub, Menu_Change
Return 


Red:
If A_ThisMenu = TextColor_Red
   IniWrite, Red, StopWatch.ini, Settings, Text_Color
If A_ThisMenu = BackgroundColor_Red
   IniWrite, Red, StopWatch.ini, Settings, Background_Color
Gosub, Menu_Change
Return 


Blue:
If A_ThisMenu = TextColor_Blue
   IniWrite, Blue, StopWatch.ini, Settings, Text_Color
If A_ThisMenu = BackgroundColor_Blue
   IniWrite, Blue, StopWatch.ini, Settings, Background_Color
Gosub, Menu_Change
Return 


Green:
If A_ThisMenu = TextColor_Green
   IniWrite, Green, StopWatch.ini, Settings, Text_Color
If A_ThisMenu = BackgroundColor_Green
   IniWrite, Green, StopWatch.ini, Settings, Background_Color
Gosub, Menu_Change
Return 


Orange:
If A_ThisMenu = TextColor_Orange
   IniWrite, FF8000, StopWatch.ini, Settings, Text_Color
If A_ThisMenu = BackgroundColor_Orange
   IniWrite, FF8000, StopWatch.ini, Settings, Background_Color
Gosub, Menu_Change
Return 


Yellow:
If A_ThisMenu = TextColor_Yellow
   IniWrite, Yellow, StopWatch.ini, Settings, Text_Color
If A_ThisMenu = BackgroundColor_Yellow
   IniWrite, Yellow, StopWatch.ini, Settings, Background_Color
Gosub, Menu_Change
Return 


Gray:
If A_ThisMenu = TextColor_Gray
   IniWrite, Gray, StopWatch.ini, Settings, Text_Color
If A_ThisMenu = BackgroundColor_Gray
   IniWrite, Gray, StopWatch.ini, Settings, Background_Color
Gosub, Menu_Change
Return 


Lime:
If A_ThisMenu = TextColor_Lime
   IniWrite, Lime, StopWatch.ini, Settings, Text_Color
If A_ThisMenu = BackgroundColor_Lime
   IniWrite, Lime, StopWatch.ini, Settings, Background_Color
Gosub, Menu_Change
Return


Navy:
If A_ThisMenu = TextColor_Navy
   IniWrite, Navy, StopWatch.ini, Settings, Text_Color
If A_ThisMenu = BackgroundColor_Navy
   IniWrite, Navy, StopWatch.ini, Settings, Background_Color
Gosub, Menu_Change
Return


13:
IniWrite, 13, StopWatch.ini, Settings, Text_Size
Gosub, Menu_Change
Return


15:
IniWrite, 15, StopWatch.ini, Settings, Text_Size
Gosub, Menu_Change
Return


18:
IniWrite, 18, StopWatch.ini, Settings, Text_Size
Gosub, Menu_Change
Return


20:
IniWrite, 20, StopWatch.ini, Settings, Text_Size
Gosub, Menu_Change
Return


25:
IniWrite, 25, StopWatch.ini, Settings, Text_Size
Gosub, Menu_Change
Return


30:
IniWrite, 30, StopWatch.ini, Settings, Text_Size
Gosub, Menu_Change
Return


35:
IniWrite, 35, StopWatch.ini, Settings, Text_Size
Gosub, Menu_Change
Return


On:
If A_ThisMenu = Transparent
   IniWrite, On, StopWatch.ini, Settings, Transparent
If A_ThisMenu = Always_On_Top
   IniWrite, On, StopWatch.ini, Settings, Always_On_Top
Gosub, Menu_Change
Return 


Off:
If A_ThisMenu = Transparent
   IniWrite, Off, StopWatch.ini, Settings, Transparent
If A_ThisMenu = Always_On_Top
   IniWrite, Off, StopWatch.ini, Settings, Always_On_Top
Gosub, Menu_Change
Return


Show:
Gui, Show, , StopWatch
Menu, Tray, ToggleEnable, Show
Menu, Tray, ToggleEnable, Hide
Return


Hide:
Gui, Submit, StopWatch
Menu, Tray, ToggleEnable, Hide
Menu, Tray, ToggleEnable, Show
Return


HotKeys:
MsgBox, 64, StopWatch, Hotkeys:`n`n Start   -   F9          `n Stop   -   F10          `n Clear  -   F11          `n Exit     -   F12          `n
Return 


Menu_Change:
WinGetPos, xPos, yPos, Width, Height, StopWatch
IniWrite, %xPos%, StopWatch.ini, Settings, xPos
IniWrite, %yPos%, StopWatch.ini, Settings, yPos
Return


Exit:
GuiClose:
SetTimer, UpdatedScript, Off
IniWrite, 0, StopWatch.ini, Settings, Msec
IniWrite, 00, StopWatch.ini, Settings, Sec
IniWrite, 00, StopWatch.ini, Settings, Min
IniWrite, 00, StopWatch.ini, Settings, Hour
IniWrite, %Text_Size%, StopWatch.ini, Settings, Text_Size
IniWrite, %Text_Color%, StopWatch.ini, Settings, Text_Color
IniWrite, %Transparent%, StopWatch.ini, Settings, Transparent
IniWrite, %Always_On_Top%, StopWatch.ini, Settings, Always_On_Top
IniWrite, %Background_Color%, StopWatch.ini, Settings, Background_Color
WinGetPos, xPos, yPos, Width, Height, StopWatch
IniWrite, %xPos%, StopWatch.ini, Settings, xPos
IniWrite, %yPos%, StopWatch.ini, Settings, yPos
ExitApp

