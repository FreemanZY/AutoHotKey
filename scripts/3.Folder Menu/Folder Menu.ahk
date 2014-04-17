
; Folder Menu   by rexx
;
; ** CREDITS **
; Based on "Easy Access to Favorite Folders" by Savage
; http://www.autohotkey.com/docs/scripts/FavoriteFolders.htm
;
; Code for 'get path from open/save dialog' is taken from "QuickDir" by MsgBox
; http://www.autohotkey.com/forum/viewtopic.php?t=12583
;
; Tray Icon from "Silk Icons" by Mark James @ FAMFAMFAM
; http://www.famfamfam.com/lab/icons/silk/
;




;==================== Auto Execute ====================;

#SingleInstance, Force   ; Needed since the hotkey is dynamically created.
#NoTrayIcon

Menu, Tray, Tip, Folder Menu
Menu, Tray, NoStandard
Menu, Tray, Add, &Folder Menu, f_DisplayMenu2
Menu, Tray, Add
Menu, Tray, Add, 添加当前文件夹(&A), f_NewFavorite
Menu, Tray, Add
Menu, Tray, Add, 重启脚本(&R), f_TrayReload
Menu, Tray, Add, 退出(&X), f_TrayEdit
Menu, Tray, Default, &Folder Menu
Menu, Tray, Click, 1

Menu, Tool, Add, 添加当前文件夹(&A), f_NewFavorite
Menu, Tool, Add,
Menu, Tool, Add, 重启脚本(&R), f_TrayReload
Menu, Tool, Add, 编辑(&E), f_TrayEdit
Menu, Tool, Add
Menu, Tool, Add, 退出(&X), f_TrayExit

Menu, THISISASECRETMENU, Add, List&Lines, ListLines
Menu, THISISASECRETMENU, Add, List&Vars, ListVars
Menu, THISISASECRETMENU, Add, List&Hotkeys, ListHotkeys
Menu, THISISASECRETMENU, Add, &KeyHistory, KeyHistory
Hotkey, !^#F, f_ShowMenuX, UseErrorLevel


;f_ConfigFile = %A_ScriptDir%\Config.ini   ;config file
IfNotExist, %A_ScriptDir%\Config.ini   ;if config file doesn't exist
   FileInstall, Default.ini, %A_ScriptDir%\Config.ini
Gosub, f_ReadConfig

return
;=================================== End Auto Execute =;



;==================== Read Config File ====================;

f_ReadConfig:
IniRead, f_NoTray, %A_ScriptDir%\Config.ini, Others, NoTray
if f_NoTray != 1
   Menu, Tray, Icon
IniRead, f_OtherApps, %A_ScriptDir%\Config.ini, Others, OtherApps   ; Read other applications
Gosub, f_ReadHotkeys
Gosub, f_ReadFavorites
return


f_ReadHotkeys:

IniRead, k_Hotkey1, %A_ScriptDir%\Config.ini, Hotkeys, Hotkey1
IniRead, k_Hotkey2, %A_ScriptDir%\Config.ini, Hotkeys, Hotkey2
IniRead, k_HotkeyJ, %A_ScriptDir%\Config.ini, Hotkeys, OpenSel
IniRead, k_HotkeyG, %A_ScriptDir%\Config.ini, Hotkeys, GetClass
IniRead, k_HotkeyA, %A_ScriptDir%\Config.ini, Hotkeys, AddFav
IniRead, k_HotkeyR, %A_ScriptDir%\Config.ini, Hotkeys, Reload
IniRead, k_HotkeyE, %A_ScriptDir%\Config.ini, Hotkeys, Edit
IniRead, k_HotkeyX, %A_ScriptDir%\Config.ini, Hotkeys, Exit

Hotkey, %k_Hotkey1%, f_DisplayMenu, UseErrorLevel
if ErrorLevel in 2,3,4,5,6
   f_HotkeyErr = Hotkey1 ErrorLevel: %ErrorLevel%
Hotkey, %k_Hotkey2%, f_DisplayMenu2, UseErrorLevel
if ErrorLevel in 2,3,4,5,6
   f_HotkeyErr = %f_HotkeyErr%`nHotkey2 ErrorLevel: %ErrorLevel%
Hotkey, %k_HotkeyJ%, f_OpenSel, UseErrorLevel
Hotkey, %k_HotkeyG%, f_GetClass, UseErrorLevel
Hotkey, %k_HotkeyA%, f_NewFavoriteK, UseErrorLevel
Hotkey, %k_HotkeyR%, f_TrayReload, UseErrorLevel
Hotkey, %k_HotkeyE%, f_TrayEdit, UseErrorLevel
Hotkey, %k_HotkeyX%, f_TrayExit, UseErrorLevel
if f_HotkeyErr !=
   TrayTip, Error, %f_HotkeyErr%, , 3

return


f_ReadFavorites:
ConfigItemPos = 1
Menu, Config, Add   ; in case there's no fav item, the next line will error.
Menu, Config, Delete   ; delete old menu
InFavSection = 0   ; check if in the favorites section
Loop, Read, %A_ScriptDir%\Config.ini
{
   if A_LoopReadLine =   ; skip blank lines
      continue
   StringLeft, A_LoopReadLineFirstChar, A_LoopReadLine, 1   ; Skip comments
   if A_LoopReadLineFirstChar = `;
      continue
   if InFavSection = 0
   {
      IfInString, A_LoopReadLine, [Favorites]   ; Favorites section start
         InFavSection = 1
      else
         continue   ; Start a new loop iteration.
   }
   else if InFavSection = 1
   {
      if A_LoopReadLineFirstChar = [   ; Another section start
         Break
      f_CreateFavorite("Config", A_LoopReadLine, A_LoopReadLineFirstChar, ConfigItemPos)
   }
}
Menu, Config, Add
Menu, Config, Add, &Folder Menu, :Tool
return


f_CreateFavorite(ThisMenu, ThisMenuItem, ThisMenuItemFirstChar, Pos)
{
   Global
   Local ThisMenuItem0
   Local ThisMenuItem1
   Local ThisMenuItem2
   if ThisMenuItemFirstChar = :   ; start with ':' indicates a submenu
   {
      StringTrimLeft, ThisMenuItem, ThisMenuItem, 1   ; trim ':'
      StringSplit, ThisMenuItem, ThisMenuItem, |   ; get submenu
      StringTrimLeft, ThisMenuItem2, ThisMenuItem, StrLen(ThisMenuItem1)+1   ; get item
      ThisMenuItem1 = %ThisMenuItem1%   ; Trim leading and trailing spaces.
      ThisMenuItem2 = %ThisMenuItem2%   ; Trim leading and trailing spaces.
      StringLeft, ThisMenuItem2FirstChar, ThisMenuItem2, 1
      if f_IfMenuItemNotExist(ThisMenu, ThisMenuItem1)   ; first time to create this submenu
      {
         %ThisMenuItem1%ItemPos = 1   ; this menu count 1
         %ThisMenu%ItemPos++      ; parent menu +1
      }
      f_CreateFavorite(ThisMenuItem1, ThisMenuItem2, ThisMenuItem2FirstChar, %ThisMenuItem1%ItemPos)
      Menu, %ThisMenu%, Add, %ThisMenuItem1%, :%ThisMenuItem1%
   }
   else if ThisMenuItem = -   ; '-' indicates a separator
   {
      Menu, %ThisMenu%, Add
      %ThisMenu%ItemPos++
   }
   else   ; a fav item
   {
      StringSplit, ThisMenuItem, ThisMenuItem, `=
      ThisMenuItem1 = %ThisMenuItem1%   ; Trim leading and trailing spaces.
      ThisMenuItem2 = %ThisMenuItem2%   ; Trim leading and trailing spaces.
      ; Resolve any references to variables within either field, and
      ; create a new array element containing the path of this favorite:
      if !f_IfMenuItemNotExist(ThisMenu, ThisMenuItem1)
      {
         Msgbox, 16, Error, Item [%ThisMenuItem1%] duplicated.`n`nPlease check your config file.
         return
      }
      Transform, i_%ThisMenu%_%Pos%_Path, deref, %ThisMenuItem2%
;      Transform, i_%ThisMenu%_%Pos%_Name, deref, %ThisMenuItem1%
      Menu, %ThisMenu%, Add, %ThisMenuItem1%, f_OpenFavorite
      %ThisMenu%ItemPos++
   }
   return
}




;==================== Open Favorite Item ====================;

f_OpenFavorite:

; Fetch the array element that corresponds to the selected menu item:
StringTrimLeft, f_OpenFavPath, i_%A_ThisMenu%_%A_ThisMenuItemPos%_Path, 0

;----- holding ctrl -----;
GetKeyState, f_OpenFavCState, Ctrl
if f_OpenFavCState = D
{
   f_CreateTempMenu(f_OpenFavPath)
   Menu, TempFolderMenu, UseErrorLevel
      Menu, TempFolderMenu, Show
   if ErrorLevel   ; cannot create menu, do nothing and open this item.
      Menu, %Menu%, UseErrorLevel, OFF
   else   ; show the menu and return
   {
      Menu, %Menu%, UseErrorLevel, OFF
      return
   }
}

;----- in dialog -----;
if w_Class = #32770   ; It's a dialog.
{
   if w_Edit1Pos <>    ; And it has an Edit1 control.
   {
      ; Activate the window so that if the user is middle-clicking
      ; outside the dialog, subsequent clicks will also work:
      WinActivate ahk_id %w_WinID%
      ; Retrieve any filename that might already be in the field so
      ; that it can be restored after the switch to the new folder:
      ControlGetText, w_Edit1Text, Edit1, ahk_id %w_WinID%
      ControlClick, Edit1, ahk_id %w_WinID%
      ControlSetText, Edit1, %f_OpenFavPath%, ahk_id %w_WinID%
      ControlSend, Edit1, {Enter}, ahk_id %w_WinID%
      Sleep, 100   ; It needs extra time on some dialogs or in some cases.
      ControlSetText, Edit1, %w_Edit1Text%, ahk_id %w_WinID%
      return
   }
   ; else fall through to the bottom of the subroutine to take standard action.
}

;----- in explorer ----;
else if w_Class in CabinetWClass,ExploreWClass,%f_OtherApps%   ; In Explorer or other apps, switch folders.
{
   if w_Edit1Pos <>    ; And it has an Edit1 control.
   {
      ControlClick, Edit1, ahk_id %w_WinID%
      ControlSetText, Edit1, %f_OpenFavPath%, ahk_id %w_WinID%
      ; Tekl reported the following: "If I want to change to Folder L:\folder
      ; then the addressbar shows http://www.L:\folder.com. To solve this,
      ; I added a {right} before {Enter}":
      ControlSend, Edit1, {Right}{Enter}, ahk_id %w_WinID%
      return
   }
   ; else fall through to the bottom of the subroutine to take standard action.
}

;----- in office dialog -----;
else if w_Class contains bosa_sdm_   ; It's a office dialog.
{
   ; Activate the window so that if the user is middle-clicking
   ; outside the dialog, subsequent clicks will also work:
   WinActivate ahk_id %w_WinID%
   ; Retrieve any filename that might already be in the field so
   ; that it can be restored after the switch to the new folder:
   ControlGetText, w_Edit1Text, RichEdit20W2, ahk_id %w_WinID%
   ControlClick, RichEdit20W2, ahk_id %w_WinID%   ;<----------important!!!
   ControlSetText, RichEdit20W2, %f_OpenFavPath%, ahk_id %w_WinID%
   ControlSend, RichEdit20W2, {Enter}, ahk_id %w_WinID%
   Sleep, 100   ; It needs extra time on some dialogs or in some cases.
   ControlSetText, RichEdit20W2, %w_Edit1Text%, ahk_id %w_WinID%
   return
   ; else fall through to the bottom of the subroutine to take standard action.
}

;----- in command line -----;
else if w_Class = ConsoleWindowClass   ; In a console window, CD to that directory
{
   WinActivate, ahk_id %w_WinID%   ; Because sometimes the mclick deactivates it.
   SetKeyDelay, 0   ; This will be in effect only for the duration of this thread.
   IfInString, f_OpenFavPath, :   ; It contains a drive letter
   {
      StringLeft, f_OpenFavPathDrive, f_OpenFavPath, 1
      Send, %f_OpenFavPathDrive%:{enter}
   }
   Send, cd %f_OpenFavPath%{Enter}
   return
}

;----- none of the above -----;
; Since the above didn't return, one of the following is true:
; 1) It's an unsupported window type but using hotkey2.
; 2) It's a supported type but it lacks an Edit1 control to facilitate the custom
;    action, so instead do the default action below.
Run, explore %f_OpenFavPath%, , UseErrorLevel   ; Might work on more systems without double quotes.
if ErrorLevel
   Run, %f_OpenFavPath%, , UseErrorLevel   ;open a file if the path is not a dir
   if ErrorLevel
      TrayTip, Error, Could not open file:`n%f_OpenFavPath%`nThere's something wrong with your config file., , 3
return



;==================== Display The Menu ====================;

f_DisplayMenu:
;----- get necessary infor -----;
; These first few variables are set here and used by f_OpenFavorite:
WinGet, w_WinID, ID, A
WinGet, w_WinMin, MinMax
if w_WinMin = -1   ; Only detect windows not Minimized.
   w_WinID =
WinGetClass, w_Class, ahk_id %w_WinID%

;----- get edit1 position -----;
if w_Class in #32770,CabinetWClass,ExploreWClass,%f_OtherApps%
   ControlGetPos, w_Edit1Pos,,,, Edit1, ahk_id %w_WinID%
if w_Class contains bosa_sdm_   ; Microsoft Office application
   ControlGetPos, w_Edit1Pos,,,, RichEdit20W2, ahk_id %w_WinID%

;----- check if display the menu -----;
if w_Class in #32770,CabinetWClass,ExploreWClass,%f_OtherApps%
{
   if w_Edit1Pos =    ; The Control doesn't exist, so don't display the menu
      return
}
Else if w_Class <> ConsoleWindowClass
{
   IfNotInString, w_Class, bosa_sdm_   ; Microsoft Office application
      return   ; Since it's some other window type, don't display menu.
}
Menu, Config, show   ; Otherwise, the menu should be presented for this type of window:
return


f_DisplayMenu2:   ; Always show menu
w_Class =    ;clear the win class to open in a new explorer
Menu, Config, show
return



;==================== Add Favorite ====================;

f_NewFavoriteK:
; use addfav hotkey, get informations from active window
WinGet, w_WinID, ID, A
WinGet, w_WinMin, MinMax
if w_WinMin = -1   ; Only detect windows not Minimized.
   w_WinID =
WinGetClass, w_Class, ahk_id %w_WinID%
Gosub f_NewFavorite
return

f_NewFavorite:
f_NewFavPath := f_GetPath(w_WinID, w_Class)
f_NewFavName := f_GetName(f_NewFavPath)
; Generated using SmartGUI Creator 4.0
Gui, Add, Text, x16 y10 w50 h20 , 菜单名：
Gui, Add, Edit, x16 y30 w230 h20 vf_NewFavName, %f_NewFavName%
Gui, Add, Text, x16 y60 w40 h20 , 路径：
Gui, Add, Edit, x16 y80 w230 h20 vf_NewFavPath, %f_NewFavPath%
Gui, Add, Button, x16 y110 w100 h20 gf_NewFavBFolder, 浏览文件夹(&B)
Gui, Add, Button, x146 y110 w100 h20 gf_NewFavBFile, 浏览文件(&R)
Gui, Add, Button, x256 y30 w70 h20 gf_NewFavOK Default, 确定(&O)
Gui, Add, Button, x256 y60 w70 h20 gf_NewFavCancel, 取消(&C)
Gui, Font, cRed, 
Gui, Add, Text, x66 y10 w210 h20 vf_NewFavErr1, 重名了，请重新修改
Gui, Add, Text, x56 y60 w190 h20 vf_NewFavErr2, 路径不存在
Gui, Add, Text, x256 y90 w80 h50 vf_NewFavTip, 按住 Shift 点击“确定”跳过文件（夹）检查
GuiControl, Hide, f_NewFavErr1
GuiControl, Hide, f_NewFavErr2
GuiControl, Hide, f_NewFavTip
Gui, Show, h143 w339, Add Favorite
Return

;----- Add Favorite GUI -----;

f_NewFavOK:
GetKeyState, f_NewFavSState, Shift
Gui, Submit, NoHide
Gosub, f_NewFavChk
if f_NewFavSState = D   ; if shift is hold down, pass the check, set no error.
   f_NewFavErr = 0
if f_NewFavErr = 0   ; No Error, add it.
{
   if f_NewFavNameExist !=
      MsgBox, 4, , [%f_NewFavName%] already exist.`n`nDo you want to replace it?
   IfMsgBox No
      return   ; dont replace it.
   Gui, Destroy
   ;MsgBox, %f_NewFavName% = %f_NewFavPath%
   IniWrite, %f_NewFavPath%, %A_ScriptDir%\Config.ini, Favorites, %f_NewFavName%   ; Write to ini
   Gosub, f_ReadConfig
   TrayTip, Add favorites , [%f_NewFavName%] added., , 1
}
return

f_NewFavChk:
f_NewFavErr = 0
GuiControl, Hide, f_NewFavErr1
GuiControl, Hide, f_NewFavErr2
GuiControl, Hide, f_NewFavTip
IniRead, f_NewFavNameExist, %A_ScriptDir%\Config.ini, Favorites, %f_NewFavName%, %A_Space%
if f_NewFavNameExist !=   ; Check neme, name not available
{
   GuiControl, Show, f_NewFavErr1
   f_NewFavErr = 1
;   MsgBox, This favorite name already exist.`n`n(%f_NewFavName% = %f_NewFavNameExist%)
}
IfNotExist, %f_NewFavPath%   ; Check path, path not valid
{
   GuiControl, Show, f_NewFavErr2
   f_NewFavErr = 1
;   MsgBox, This path did not exist.
}
if f_NewFavErr = 1
   GuiControl, Show, f_NewFavTip
return

f_NewFavCancel:
Gui, Destroy
return
GuiClose:
Gui, Destroy
return
GuiEscape:
Gui, Destroy
return

f_NewFavBFolder:
FileSelectFolder, f_NewFavPath
GuiControl, , f_NewFavPath, %f_NewFavPath%
f_NewFavName := f_GetName(f_NewFavPath)
GuiControl, , f_NewFavName, %f_NewFavName%
Gosub, f_NewFavChk
return

f_NewFavBFile:
FileSelectFile, f_NewFavPath
GuiControl, , f_NewFavPath, %f_NewFavPath%
f_NewFavName := f_GetName(f_NewFavPath)
GuiControl, , f_NewFavName, %f_NewFavName%
Gosub, f_NewFavChk
return


;----- Get Full Path & Name -----;

f_GetPath(WindowID, Class)
{
   if Class in #32770
   {
      ControlGetText, Text, Edit1, ahk_id %WindowID%   ; save text already in edit1
      Loop
      {
         ControlGetText, DirName, ComboBox1, ahk_id %WindowID%
         if DirName =
            return
         StringRight Root, DirName, 4
         StringRight End, Root, 2
         StringLeft Start, Root, 1
         if (Start = "(") and (End = ":)")
         {
            StringLeft Root, Root, 2
            StringRight Root, Root, 1
            GPath = %Root%:\%GPath%
            MsgBox, Path:`n%GPath%
            ControlClick, Edit1, ahk_id %w_WinID%
            ControlSetText, Edit1, %GPath%, ahk_id %WindowID%
            ControlSend, Edit1, {Enter}, ahk_id %WindowID%
            Sleep, 100
            ControlSetText, Edit1, %Text%, ahk_id %WindowID%   ; restore text in edit1
            break
         }
         if GPath =
            GPath = %DirName%
         else
            GPath = %DirName%\%GPath%
         MsgBox, Path:`n%GPath%
         ControlFocus, SysListView321, ahk_id %WindowID%
         ControlSend, SysListView321, {Bs}, ahk_id %WindowID%
      }
   }
   else if Class in CabinetWClass,ExploreWClass,%f_OtherApps%
   {
      ControlGetText, GPath, Edit1, ahk_id %WindowID%
   }
   else if Class = ConsoleWindowClass
   {
      Send, cd > %Temp%\f_cdtmp{Enter}
      FileReadLine, GPath, %Temp%\f_cdtmp, 1
      FileDelete, %Temp%\f_cdtmp
   }
   ; Use folder name as favorite name.
   StringRight, LastChar, GPath, 1
   if LastChar = \   ; Remove the trailing backslash.
      StringTrimRight, GPath, GPath, 1
   return %GPath%
}

f_GetName(GPath)
{
   SplitPath, GPath, GName
   if GName =   ; if empty, use whole path as name.
      GName = %GPath%
   return %GName%
}

;==================== Get Win Class ====================;

f_GetClass:
WinGetTitle, w_Title, A   ; Get title
WinGetClass, w_Class, A   ; Get class
ControlGetPos, w_Edit1Pos,,,, Edit1, A   ; Get edit1
if w_Edit1Pos =   ; edit1 not exist
{
   MsgBox, 49, Folder Menu, Title:`t[%w_Title%]`nClass:`t[%w_Class%]`n`nEdit1 did NOT exist!`n`nCopy the classname?
   IfMsgBox OK
      Clipboard = %w_Class%
}
else
{
   MsgBox, 33, Folder Menu, Title:`t[%w_Title%]`nClass:`t[%w_Class%]`n`nEdit1 exist!`n`nCopy the classname?
   IfMsgBox OK
      Clipboard = %w_Class%
}
return



;==================== Open Selected Path ====================;

f_OpenSel:
Send, ^c
Transform, f_Selected, deref, %Clipboard%

/*
**** Open Selected Menu ****
Menu, OpenSel, Add
Menu, OpenSel, Delete
Menu, OpenSel, Add, %f_Selected%, f_OSelOpen
Menu, OpenSel, Default, %f_Selected%
Menu, OpenSel, Disable, %f_Selected%
Menu, OpenSel, Add
Menu, OpenSel, Add, &Open it, f_OSelOpen
Menu, OpenSel, Add, E&xplore it, f_OSelExplore
Menu, OpenSel, Add, &Edit it, f_OSelEdit
Menu, OpenSel, Add, &Find it, f_OSelFind
Menu, OpenSel, Show
f_OSelOpen:
Run, %f_Selected%, , UseErrorLevel
if ErrorLevel
   TrayTip, Error, Could not open " %f_Selected% " ., , 3
return
f_OSelExplore:
Run, explore %f_Selected%, , UseErrorLevel
if ErrorLevel
   TrayTip, Error, Could not explore " %f_Selected% " ., , 3
return
f_OSelEdit:
Run, edit %f_Selected%, , UseErrorLevel
if ErrorLevel
   TrayTip, Error, Could not edit " %f_Selected% " ., , 3
return
f_OSelFind:
Run, find %f_Selected%, , UseErrorLevel
if ErrorLevel
   TrayTip, Error, Could not find " %f_Selected% " ., , 3
**** End of Menu ****
*/

Run, explore %f_Selected%, , UseErrorLevel
if ErrorLevel
   Run, %f_Selected%, , UseErrorLevel
   if ErrorLevel
      TrayTip, Error, Could not open " %f_Selected% " ., , 3
return



;==================== Tray Menu Items ====================;

f_TrayReload:
Reload
; Gosub, f_ReadConfig
; TrayTip, Reload, Config Reloaded, , 1
return

f_TrayEdit:
Run, %A_ScriptDir%\Config.ini
;WinWait, Config
;WinWaitClose   ; wait until the config file editor close
;Gosub, f_ReadConfig
return

f_TrayExit:
Exitapp
return

f_ShowMenuX:
Menu, THISISASECRETMENU, Show
return

ListLines:
ListLines
return

ListVars:
ListVars
return

ListHotkeys:
ListHotkeys
return

KeyHistory:
KeyHistory
return


;==================== Functions ====================;

f_CreateTempMenu(TMPath)
{
   Menu, TempFolderMenu, Add
   Menu, TempFolderMenu, Delete   ; delete old menu
   ParentItem=%A_ThisMenuItem%`=%TMPath%   ; create parent folder item
   f_CreateFavorite("TempFolderMenu", ParentItem, "1", 1)

   StringRight, LastChar, TMPath, 1
   if LastChar = \   ; Remove the trailing backslash.
      StringTrimRight, TMPath, TMPath, 1
   Loop, %TMPath%\*, 2   ; get subfolders list
      ItemList = %ItemList%`n%A_LoopFileName%`=%A_LoopFileFullPath%
   Sort, ItemList   ; sort and create menu
   Loop, parse, ItemList, `n
   {
      f_CreateFavorite("TempFolderMenu", A_LoopField, "1", A_Index+1)
   }
   if ItemList =   ; if no subfolder, delete menu
      Menu, TempFolderMenu, Delete
   return
}

f_IfMenuItemNotExist(Menu, Item)   ; test if a menuitem exist, 1 for NOT exist.
{
   Menu, %Menu%, UseErrorLevel
   Menu, %Menu%, Enable, %Item%
   if ErrorLevel   ; Not exist
   {
      Menu, %Menu%, UseErrorLevel, OFF
      return 1
   }
   else   ; Exist
   {
      Menu, %Menu%, UseErrorLevel, OFF
      return 0
   }
}
