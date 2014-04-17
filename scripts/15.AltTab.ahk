HELP = ; Gui, 99
(LTrim0


ALT-TAB REPLACEMENT (WITH ICONS AND WINDOW TITLES IN A LISTVIEW).


HOTKEYS:
  Default:
    Alt+Tab - move forwards in window stack
    Alt+Shift+Tab - move backwards in window stack
    Alt+Esc - cancel switching window
  Window Groups can be assigned hotkeys to load the group/cycle through the windows.

EVENTS:
  Single-click a row to select that item and switch to it.

  Type first letter of program's title to cycle through them while still holding Alt
    (ignores "-- Dialog --" prefix if present and matches the parent window's title).

  Columns can be sorted by clicking on their titles.

  Right-Click (context menu):
    Basic hotkey support for switching to specific windows (using window groups and adding window classes)
    Exclude (and un-exclude) specific windows and specific exe's - see "Window Groups" below.
    Edge-docking - dock windows to the edges of the screen and have them auto-hide (like the taskbar can)
    Window Groups - define lists of windows to easily switch between only showing certain apps

  Close windows:
    Alt+Middle mouse - close window under the mouse pointer in the Alt-Tab listview.
    Alt+\ "hotkey"  - close selected window (while list is displayed)
    Alt+/ "hotkey"  - close ALL windows whose EXE matches that of the selected entry (while list is displayed)
    Process menu entry - end selected process or all instance of the EXE in the list.

SETTINGS:
  See "; USER EDITABLE SETTINGS:" section near top of source code.

TO EXIT:
  Kill process or remove #NoTrayIcon first


NOTE: Stroke-It (and maybe other mouse gesture programs) can cause the context menu to be shown twice/problematic.
        Solution = exclude the program within the gesture recognition program (window title = Alt-Tab Replacement).


)



LATEST_VERSION_CHANGES = ; Gui, 98
(LTrim0


TO DO (maybe):
  configuration window
  save other settings between restarts
  include a filter for docked windows to be displayed in alt-tab or not
  stick items to top or bottom of list
    use listview insert command to place windows at specific locations in list
    change window titles (for pressing 1st letter of title more easily)?
    indicate/sort min/max/normal/on top windows - and filter/arrange
  arrange/tile windows + min all and max all for exe type



LATEST VERSION CHANGES:
> 25-03-06
  Fixed some group hotkey bugs when cycling through windows.
  Fixed a bug with closing all instances of an exe.
  Docked windows - doesn't re-dock if mouse moved under 10 pixels e.g. clicked on taskbar (not when activating with mouse-over)
  Hotkeys can be set to use XButton and Wheel mouse keys as part of Alt/Tab (use caution when changing the hotkeys - delete the ini file if it goes wrong)

> For older changes, see the forum: http://www.autohotkey.com/forum/viewtopic.php?t=6422


)



;========================================================================================================
; USER EDITABLE SETTINGS:

  ; Icons
    Use_Large_Icons =1 ; 0 = small icons, 1 = large icons in listview

  ; Fonts
    Font_Size =13 ; (default = 13)
    Font_Type =MS sans serif ; (default = MS sans serif)

  ; Position
    Gui_x =Center ; (Default = Center)
    Gui_y :=A_ScreenHeight * 0.25 ; ~150 pixels on 1024*768 (Default = A_ScreenHeight * 0.25 ; OR: "Center" WITH quotes)

  ; Max height
    Height_Max_Modifier =0.95 ; multiplier for screen height (e.g. 0.95 = 95% of screen height max ) (Default = 0.9)

  ; Width
    Listview_Width := A_ScreenWidth * 0.55 ; width of listview (default = A_ScreenHeight * 0.55)

  ; Edge-Docking of windows to screen edges
    Edge_Dock_Activation_Delay =750 ;  Delay in milliseconds for hovering over edge-docked window/dismissing window
    Edge_Dock_Border_Visible =5 ; number of pixels of window to remain visible on screen edge

;========================================================================================================
; USER OVERRIDABLE SETTINGS:

  ; Widths
    Col_1 =Auto ; icon column (default = Auto)
    Col_2 =0 ; hidden column for row number (default = 0)
    ; col 3 is autosized based on other column sizes
    Col_4 =Auto ; exe (default = Auto)

  ; Max height
    Height_Max := A_ScreenHeight * Height_Max_Modifier ; limit height of listview (default = A_ScreenHeight * 0.9)
    Small_to_Large_Ratio =1.6 ; height of small rows compared to large rows (default = 1.6)

  ; Colours
    Listview_Colour =E4E2FC ; (default = E4E2FC)

;========================================================================================================



#SingleInstance force
#Persistent
#InstallKeybdHook
#InstallMouseHook
;#NoTrayIcon

Process Priority,,High
SetBatchLines, -1

Gosub, Load_Settings_From_Ini

OnExit, OnExit_Script_Closing

OnMessage( 0x06, "WM_ACTIVATE" )

Gosub, Initiate_Hotkeys ; initiate Alt-Tab and Alt-Shift-Tab hotkeys and translate some modifier symbols

WS_EX_APPWINDOW =0x40000
WS_EX_TOOLWINDOW =0x80
WS_DISABLED =0x8000000
WS_VSCROLL =0x200000
GW_OWNER = 4

SysGet, Scrollbar_Vertical_Thickness, 2 ; 2 is SM_CXVSCROLL, Width of a vertical scroll bar
If A_OSVersion =WIN_2000
  lv_h_win_2000_adj =2 ; adjust height of main listview by +2 pixels to avoid scrollbar in windows 2000
Else
  lv_h_win_2000_adj =0

WinGet, TaskBar_ID, ID, ahk_class Shell_TrayWnd ; for docked windows check

Display_List_Shown =0
Window_Hotkey =0
Use_Large_Icons_Current =%Use_Large_Icons% ; for remembering original user setting but changing on the fly
Gui_Dock_Windows_List = ; keep track of number of docked windows
Blank = ; for If(array != blank)
Time_Since_Last_Alt_Close =0 ; initialise time for repeat rate allowed for closing windows with alt+\
Number_Tabs_To_Send =-1 ; initialise for Group hotkey
New_Group_Loaded =1
Viewed_Window_List =
Return



;========================================================================================================



Initiate_Hotkeys:
  Use_AND_Symbol = ; initiate
  ; If both Alt and Tab are modifier keys, write Tab as a word not a modifier symbol, else Alt-Tab is invalid hotkey
  If Alt_Hotkey contains #,!,^,+
    {
    If Tab_Hotkey contains #,!,^,+
      Replace_Modifier_Symbol( "Tab_Hotkey" , "Tab_Hotkey" )
    }
  Else If Alt_Hotkey contains XButton1,XButton2
    Use_AND_Symbol :=" & "
  Else If Tab_Hotkey contains WheelUp,WheelDown
    Use_AND_Symbol :=" & "
  Hotkey, %Alt_Hotkey%%Use_AND_Symbol%%Tab_Hotkey%, Alt_Tab, On ; turn on alt-tab hotkey here to be able to turn it off for simple switching of apps in script
  Hotkey, %Alt_Hotkey%%Use_AND_Symbol%%Shift_Tab_Hotkey%, Alt_Shift_Tab, On ; turn on alt-tab hotkey here to be able to turn it off for simple switching of apps in script
  
  If Single_Key_Show_Alt_Tab !=
    {
    If Single_Key_Show_Alt_Tab contains #,!,^,+
      Replace_Modifier_Symbol( "Single_Key_Show_Alt_Tab" , "Single_Key_Show_Alt_Tab" )
    Hotkey, *%Single_Key_Show_Alt_Tab%, Single_Key_Show_Alt_Tab, On
    If Single_Key_Hide_Alt_Tab contains #,!,^,+
      Replace_Modifier_Symbol( "Single_Key_Hide_Alt_Tab" , "Single_Key_Hide_Alt_Tab" )
    }
  
  Replace_Modifier_Symbol( "Alt_Hotkey" , "Alt_Hotkey2" )
  
  If Tab_Hotkey not contains Wheel ; wheel isn't used as an alt-tab hotkey so cna be used for scrolling list instead
    Use_Wheel_Scroll_List =1
  If Shift_Tab_Hotkey not contains Wheel ; wheel isn't used as an alt-tab hotkey so cna be used for scrolling list instead
    Use_Wheel_Scroll_List =1
Return



Alt_Tab: ; alt-tab hotkey - turn on alt-tab hotkey earlier to be able to turn it off for simple switching of apps in script
  Critical
  Gosub, Alt_Tab_Common_Stuff
  Selected_Row += 1
  If Selected_Row >  %Window_Found_Count%
    Selected_Row =1
  Gosub, ListView_Get_Selected_and_Ensure_Visible
  SetTimer, Check_Alt_Hotkey2_Up, 50
Return



Alt_Shift_Tab: ; alt-shift-tab hotkey
  Critical
  Gosub, Alt_Tab_Common_Stuff
  Selected_Row -= 1
  If Selected_Row =0
    Selected_Row =%Window_Found_Count%
  Gosub, ListView_Get_Selected_and_Ensure_Visible
  SetTimer, Check_Alt_Hotkey2_Up, 50
Return



ListView_Get_Selected_and_Ensure_Visible: 
  LV_Modify(Selected_Row, "Focus Select")
  SendMessage, 0x1000+19, LV_GetNext("", "F")-1, 0, SysListView321, ahk_id %Gui_ID% ; LVM_ENSUREVISIBLE =(LVM_FIRST + 19), LVM_FIRST = 0x1000
Return 



Single_Key_Show_Alt_Tab:
  Single_Key_Show_Alt_Tab_Used =1
  Send, {%Alt_Hotkey2% down}{%Tab_Hotkey%}
  Hotkey, *%Single_Key_Hide_Alt_Tab%, ListView_Destroy, On
Return



Alt_Esc: ; abort switching
  Critical
  Alt_Esc =1
  Gosub, ListView_Destroy
  Alt_Esc =
Return



Alt_Esc_Check_Alt_State: ; hides alt-tab gui - shows again if alt still pressed
  Gosub, Alt_Esc
  If ( GetKeyState(Alt_Hotkey2, "P") or GetKeyState(Alt_Hotkey2)) ; Alt key still pressed - show alt-tab again
    Gosub, Alt_Tab
Return



Alt_Tab_Common_Stuff:
  Hotkey, %Alt_Hotkey%%Use_AND_Symbol%%Esc_Hotkey%, Alt_Esc, On ; abort
  If Use_Wheel_Scroll_List =1
    {
    Hotkey, %Alt_Hotkey%%Use_AND_Symbol%WheelUp, Alt_Shift_Tab, On ; previous window
    Hotkey, %Alt_Hotkey%%Use_AND_Symbol%WheelDown, Alt_Tab, On ; next window
    }
  Hotkey, %Alt_Hotkey%%Use_AND_Symbol%Mbutton, MButton_Close, On ; close the window clicked on

  If Display_List_Shown =0
    {
    If Group_Hotkey_Switching !=1
      Number_Tabs_To_Send =-1 ; initialise for Group hotkey
    WinGet, Active_ID, ID, A
    Gosub, Display_List

    ; limit gui height / auto-switch icon sizes
    If (Listview_NowH > Height_Max AND Use_Large_Icons_Current =1) ; switch to small icons
      {
      Use_Large_Icons_Current =0
      IL_Destroy(ImageListID1) ; destroy gui, listview and associated icon imagelist.
      LV_Delete()
      Gui, 1: Destroy
      Display_List_Shown =0
      Gosub, Display_List
      }
    If ((Listview_NowH * Small_to_Large_Ratio) < Height_Max AND Use_Large_Icons_Current =0 AND Use_Large_Icons=1) ; switch to large icons
      {
      Use_Large_Icons_Current =1
      IL_Destroy(ImageListID1) ; destroy gui, listview and associated icon imagelist.
      LV_Delete()
      Gui, 1: Destroy
      Display_List_Shown =0
      Gosub, Display_List
      }

    If ( GetKeyState(Alt_Hotkey2, "P") or GetKeyState(Alt_Hotkey2)) ; Alt key still pressed, else gui not shown
      Gui, 1: Show, AutoSize x%Gui_x_Now% y%Gui_y_Now%, Alt-Tab Replacement

    Active_ID_Found =0
    Loop, %Window_Found_Count% ; select active program in list (not always the top item)
      {
      If Window%A_Index% =%Active_ID%
        {
        Active_ID_Found =1
        LV_Modify(A_Index, "Focus Select")
        Break
        }
      }

    If Active_ID_Found =0 ; active window has an icon in another main window & was excluded from Alt-Tab list
      {
      WinGet, Active_Process, ProcessName, ahk_id %Active_ID%
      WinGetClass, Active_Class, ahk_id %Active_ID%

      ; If desktop/taskbar selected or nothing at all, don't select item in alt-tab list
      If (Active_Class ="Progman" OR Active_Class ="WorkerW" OR Active_Class ="Shell_TrayWnd" OR Active_Class ="")
        {
        Active_ID_Loop =1
        Active_ID_Found =1
        }
      If Active_ID_Found =0
        {
        Active_ID_Loop =0
        Loop, %Window_Found_Count% ; find top item in window list with same exe name as active window
          {
          Active_ID_Loop +=1
          If Exe_Name%Active_ID_Loop% =%Active_Process%
            {
            Active_ID_Found =1
            LV_Modify(Active_ID_Loop, "Focus Select")
            Break
            }
          }
        }
      }
    }
  Selected_Row := LV_GetNext(0, "F")
Return


Check_Alt_Hotkey2_Up:
  If ! ( GetKeyState(Alt_Hotkey2, "P") or GetKeyState(Alt_Hotkey2)) ; Alt key released
    Gosub, ListView_Destroy
Return



;========================================================================================================



Display_List:
  Critical
  If Display_List_Shown =1 ; empty listview and image list if only updating
    {
    IL_Destroy(ImageListID1)
    LV_Delete()
    }

  ; Create an ImageList so that the ListView can display some icons
  ImageListID1 := IL_Create(10,5,Use_Large_Icons_Current)

  ; Gather a list of running programs:
  WinGet, Window_List, List

  Process, Exist, explorer.exe ; get PID of explorer.exe for later comparison
    Explorer_PID =%ErrorLevel%

  Window_Found_Count =0
  Loop, %Window_List%
    {
    wid := Window_List%A_Index%
    WinGetTitle, wid_Title, ahk_id %wid%

    If wid_Title = ; skip windows with no title - e.g. popup windows
      Continue



    ; CUSTOM GROUP FILTERING
    If (Custom_Group_Active != "") ; i.e. list is filtered, check filter contents to include
      {
      WinGet, wid_Process_Name_temp, ProcessName, ahk_id %wid%
      Custom_Group_Include_wid_temp = ; initialise/reset
      Loop, Parse, %Custom_Group_Active%,| ; check current window id against the list to filter
        {
        If (A_Index =1 and A_LoopField ="Exclude_Not_In_List") ; skip - data entry not filter entry.
          Continue
        StringLeft, Exclude_Item, A_LoopField, 1
        If Exclude_Item =! ; remove ! for matching strings
          StringTrimLeft, Loop_Item, A_LoopField, 1 
        Else
          Loop_Item=%A_LoopField%

        If Loop_Item =%wid_Process_Name_temp% ; match exe name instead of title
          Custom_Group_Include_wid_temp =1 ; include this window
        Else
          {
          If wid_Title contains %Loop_Item%
            Custom_Group_Include_wid_temp =1 ; include this window
          Else ; also check parent title
            {
            Parent := DllCall( "GetParent", "uint", wid )
            SetFormat, integer, hex ; change Parent to hex format
            Parent += 0
            SetFormat, integer, d
            WinGetTitle, wid_Parent_Title_temp, ahk_id %Parent%
            If wid_Parent_Title_temp contains %Loop_Item% ; check that any parent window isn't included, else continue
              Custom_Group_Include_wid_temp =1 ; include this window
            }
          }
        If Custom_Group_Include_wid_temp =1
          Break
        }
      If (Exclude_Item ="!" and Custom_Group_Include_wid_temp =1) ; was found but should be excluded
        Continue
      If (Custom_Group_Include_wid_temp !=1 and Exclude_Not_In_List =1) ; skip window if not in included list
        Continue
      }



    WinGet, es, ExStyle, ahk_id %wid%
    WinGet, Style, Style, ahk_id %wid%

    ; RETRIEVE ICONS
    If ( ( ! DllCall( "GetWindow", "uint", wid, "uint", GW_OWNER ) and  ! ( es & WS_EX_TOOLWINDOW )
           and ! ( Style & WS_DISABLED )) or ( es & WS_EX_APPWINDOW ) )
      {
      Window_Found_Count += 1
      Gosub, Retrive_Window_Icon
      Window_Parent_%Window_Found_Count% = ; store Parent ahk_id's to a list to later see if window is owned
      Window%Window_Found_Count% =%wid% ; store ahk_id's to a list
      WinGet, Exe_Name%Window_Found_Count%, ProcessName, ahk_id %wid% ; store processes to a list
      Continue
      }

    If ( ! DllCall( "GetWindow", "uint", wid, "uint", GW_OWNER ) and ( Style & WS_DISABLED ) ) ; e.g. generally includes WS_POPUP
      {
      Window_Found_Count += 1

      hw_popup := DllCall( "GetLastActivePopup", "uint", wid )
      SetFormat, integer, hex ; change Parent to hex format
      hw_popup += 0
      SetFormat, integer, d

      Gosub, Retrive_Window_Icon
      WinGetTitle, hw_popup_title, ahk_id %hw_popup% ; over-ride title from Gosub, Retrive_Window_Icon
      Title%Window_Found_Count% := "-- Dialog --  " hw_popup_title "  >  " wid_Title ; indent listview title text to stand out, / symbol to use as Alt-/ hotkey
      Window_Parent_%Window_Found_Count% =%wid% ; store Parent ahk_id's to a list to later see if window is owned
      Window%Window_Found_Count% =%hw_popup% ; store ahk_id's to a list
      WinGet, Exe_Name%Window_Found_Count%, ProcessName, ahk_id %hw_popup% ; store processes to a list
      Continue
      }

    WinGetClass, Win_Class, ahk_id %wid%
    If ( ! ( Win_Class ="#32770" ) )
      Continue
    Parent := DllCall( "GetParent", "uint", wid )
    SetFormat, integer, hex ; change Parent to hex format
    Parent += 0
    SetFormat, integer, d
    WinGet, es, ExStyle, ahk_id %Parent%
    WinGet, Style, Style, ahk_id %Parent%


    ; Check parent to dialog isn't already included above
    If ( ( ( ! DllCall( "GetWindow", "uint", Parent, "uint", GW_OWNER ) and  ! ( es & WS_EX_TOOLWINDOW )
           and ! ( Style & WS_DISABLED )) or ( es & WS_EX_APPWINDOW ) ) )
        {
        Window_Found_Count += 1
        CPA_file_name := GetCPA_file_name( wid )
        If ( CPA_file_name )
          Gui_Icon_Number := IL_Add( ImageListID1, CPA_file_name, 1 )
        Else
          Gosub, Retrive_Window_Icon ; retrieve parent's icon for display

        Title%Window_Found_Count% :="-- Dialog --  " wid_Title ; indent listview title text to stand out
        Window_Parent_%Window_Found_Count% = ; store Parent ahk_id's to a list to later see if window is owned
        Window%Window_Found_Count% =%wid% ; store ahk_id's to a list
        WinGet, Exe_Name%Window_Found_Count%, ProcessName, ahk_id %wid% ; store processes to a list
        }
    }

  If Display_List_Shown !=1 ; no need to create gui for updating listview
    {
    ; Create the ListView gui
    Gui, 1: +AlwaysOnTop +ToolWindow -Caption
    Gui, 1: Font, s%Font_Size%, %Font_Type%
    Gui, 1: Color, 404040 ; i.e. border/background (default = 404040) ; barely visible - right and bottom sides only
    Gui, 1: Margin, 1, 1
    Gui, 1: Add, ListView, x-1 y-1 r%Window_Found_Count% w%Listview_Width% AltSubmit -Multi NoSort Background%Listview_Colour% Count10 gListView_Event vListView1,#| |Window|Exe
    }

  ; Attach the ImageLists to the ListView so that it can later display the icons:
  LV_SetImageList(ImageListID1, 1)

If Window_Found_Count =0
  {
  Window_Found_Count =1
    LV_Add("","","", No Windows Found!,"")
  }
Else
  {
  Loop, %Window_Found_Count% ; add all rows to listview
    LV_Add("Icon" . A_Index,"", A_Index, Title%A_Index%, Exe_Name%A_Index%)
  }













;;;;;;;;;;;;
/*
; manipulate and filter listview items

; use LV_Insert(RowNumber [, Options, Col1, Col2, ...]):  to add rows at end, after other windows, in middle, etc

;;;  need to write filtered windows to _another_ list and then put those in listview
; get titles, etc for final list only - for titles for dialog windows, store title to temporary location
*/


  Gosub, Gui_Resize_and_Position

  If Display_List_Shown =1 ; resize gui for updating listview
    {
    Gui, 1: Show, AutoSize x%Gui_x_Now% y%Gui_y_Now%, Alt-Tab Replacement
    If Selected_Row >%Window_Found_Count% ; less windows
      Selected_Row =%Window_Found_Count%
    LV_Modify(Selected_Row, "Focus Select") ; select 1st entry since nothing selected
    }

  Display_List_Shown =1 ; Gui 1 is shown back in Alt_Tab_Common_Stuff: section for initial creation
Return



Gui_Resize_and_Position:
  DetectHiddenWindows, On ; retrieving column widths to enable calculation of col 3 width

  Gui, +LastFound   
  Gui_ID := WinExist() ; for auto-sizing columns later

  If Display_List_Shown !=1 ; no need to resize columns for updating listview
    {
    ; resize listview columns
    LV_ModifyCol(1, Col_1) ; icon column
    LV_ModifyCol(2, Col_2) ; hidden column for row number
    ; col 3 see below
    LV_ModifyCol(4, Col_4) ; exe

    SendMessage, 0x1000+29, 0, 0, SysListView321, ahk_id %Gui_ID% ; LVM_GETCOLUMNWIDTH is 0x1000+29
      Width_Column_1 := ErrorLevel
    SendMessage, 0x1000+29, 1, 0, SysListView321, ahk_id %Gui_ID% ; LVM_GETCOLUMNWIDTH is 0x1000+29
      Width_Column_2 := ErrorLevel
    SendMessage, 0x1000+29, 3, 0, SysListView321, ahk_id %Gui_ID% ; LVM_GETCOLUMNWIDTH is 0x1000+29
      Width_Column_4 := ErrorLevel
    Col_3 := Listview_Width - Width_Column_1 - Width_Column_2 - Width_Column_4 - 4 ; total width of columns - 4 for border
    LV_ModifyCol(3, Col_3) ; resize title column

    LV_ModifyCol(2, "Integer") ; sort hidden column 2 as numbers

    LV_ModifyCol(Sort_Order_Column, Sort_Order_Direction) ; sort by columm
    }

  ListView_Resize_Vertically(Gui_ID) ; Automatically resize listview vertically - pass the gui id value 
  
  GuiControlGet, Listview_Now, Pos, ListView1 ; retrieve listview dimensions/position ; for auto-sizing (elsewhere)

  ; auto-position gui upwards according to size
  Gui_x_Now := Gui_x
  Gui_y_Now := Gui_y
  If Gui_y_Now !=Center
    {
    If ((Gui_y_Now + Listview_NowH) > Height_Max) ; gui nearly off bottom of screen
      Gui_y_Now := Gui_y_Now + (Height_Max - (Listview_NowH + Gui_y_Now))
    }
  If (Listview_NowH > Height_Max AND Use_Large_Icons_Current =0) ; already using small icons -limit height
    {
    Col_3 := Col_3 - Scrollbar_Vertical_Thickness ; allow for vertical scrollbar being visible
    LV_ModifyCol(3, Col_3) ; resize title column
    Gui_y_Now := (A_ScreenHeight - Height_Max) / 2
    GuiControl, Move, ListView1, h%Height_Max%
    }

  DetectHiddenWindows, Off
Return



;========================================================================================================



ListView_Event:
  Critical
  If MButton_Clicked =1 ; closing a window so don't process events
    Return
  If A_GuiEvent =Normal ; activate clicked window
    Gosub, ListView_Destroy
  If A_GuiEvent =K ; letter was pressed, select next window name starting with that letter
    Gosub, Key_Pressed_1st_Letter
  If A_GuiEvent =ColClick ; column was clicked - do custom sort to allow for sorting hidden column + remembering state
    Gosub, ColumnClickSort
Return



GuiContextMenu:  ; Launched in response to a right-click or press of the Apps key.
                 ; displays the menu only for clicks inside the ListView
  Selected_Row := LV_GetNext(0, "F")
  LV_GetText(RowText, Selected_Row, 2)  ; Get the row's first-column text (hidden column).
  Gui_wid := Window%RowText%
  Gui_wid_Title :=Title%RowText%
  StringLeft, Gui_wid_Title, Gui_wid_Title, 40

  If (A_GuiControl = "ListView1")
    {
    ; Add blank entry to menus so they exist all the time for deletion command
    Menu, ContextMenu1, Add
    Menu, Gui_Dock_Windows, Add
    Menu, Gui_Un_Exclude_Windows, Add
    Menu, Gui_Window_Group_Load, Add
    Menu, Gui_Window_Group_Delete, Add
    Menu, Gui_Processes, Add
    Menu, Gui_Settings_Help, Add

    ; Clear previous entries
    Menu, ContextMenu1, DeleteAll
    Menu, Gui_Dock_Windows, DeleteAll
    Menu, Gui_Un_Exclude_Windows, DeleteAll
    Menu, Gui_Window_Group_Load, DeleteAll
    Menu, Gui_Window_Group_Delete, DeleteAll
    Menu, Gui_Processes, DeleteAll
    Menu, Gui_Settings_Help, DeleteAll

    ; Dock to Screen Edge entries
    Menu, Gui_Dock_Windows, Add, Left, Gui_Dock_Windows
    Menu, Gui_Dock_Windows, Add, Right, Gui_Dock_Windows
    Menu, Gui_Dock_Windows, Add, Top, Gui_Dock_Windows
    Menu, Gui_Dock_Windows, Add, Bottom, Gui_Dock_Windows
    Menu, Gui_Dock_Windows, Add
    Menu, Gui_Dock_Windows, Add, Corner - Top Left, Gui_Dock_Windows
    Menu, Gui_Dock_Windows, Add, Corner - Top Right, Gui_Dock_Windows
    Menu, Gui_Dock_Windows, Add, Corner - Bottom Left, Gui_Dock_Windows
    Menu, Gui_Dock_Windows, Add, Corner - Bottom Right, Gui_Dock_Windows
    Menu, Gui_Dock_Windows, Add
    Menu, Gui_Dock_Windows, Add, Un-Dock, Gui_Un_Dock_Window
    Menu, Gui_Dock_Windows, Add, Un-Dock All, Gui_Un_Dock_Windows_All
    IfNotInString, Gui_Dock_Windows_List,%Gui_wid%
      Menu, Gui_Dock_Windows, Disable, Un-Dock
    Else
      {
      Menu, Gui_Dock_Windows, Disable, Left
      Menu, Gui_Dock_Windows, Disable, Right
      Menu, Gui_Dock_Windows, Disable, Top
      Menu, Gui_Dock_Windows, Disable, Bottom
      Menu, Gui_Dock_Windows, Disable, Corner - Top Left
      Menu, Gui_Dock_Windows, Disable, Corner - Top Right
      Menu, Gui_Dock_Windows, Disable, Corner - Bottom Left
      Menu, Gui_Dock_Windows, Disable, Corner - Bottom Right
      If (Edge_Dock_Position_%Gui_wid% !="") ; produces error if doesn't exist
        Menu, Gui_Dock_Windows, Check, % Edge_Dock_Position_%Gui_wid%
      }
    If Gui_Dock_Windows_List =
      Menu, Gui_Dock_Windows, Disable, Un-Dock All
    Menu, ContextMenu1, Add, &Dock to Edge, :Gui_Dock_Windows

    ; Window Group sub-menu entry
    Menu, ContextMenu1, Add ; spacer
    Menu, ContextMenu1, Add, Group - &No Filter, Gui_Window_Group_No_Filter
    If Custom_Group_Active =
      Menu, ContextMenu1, Disable, Group - &No Filter

    Loop, Parse, Custom_Group_List,|
      Menu, Gui_Window_Group_Load, Add,%A_LoopField%, Gui_Window_Group_Load
    If (Custom_Group_Active !="") ; produces error if doesn't exist
      Menu, Gui_Window_Group_Load, Check, %Custom_Group_Active%
    Menu, ContextMenu1, Add, Group - &Load, :Gui_Window_Group_Load
    If Custom_Group_List = ; add something to be able to display disabled menu
      {
      Menu, Gui_Window_Group_Load, Add
      Menu, ContextMenu1, Disable, Group - &Load
      }

    Menu, ContextMenu1, Add, Group - &Save/Edit, Gui_Window_Group_Save_Edit
    
    Menu, Gui_Window_Group_Delete, Color, E10000, Single ; warning colour
    Loop, Parse, Custom_Group_List,|
      Menu, Gui_Window_Group_Delete, Add,%A_LoopField%, Gui_Window_Group_Delete
    If (Custom_Group_Active !="") ; produces error if doesn't exist
      Menu, Gui_Window_Group_Delete, Check, %Custom_Group_Active%
    Menu, ContextMenu1, Add, Group - &Delete, :Gui_Window_Group_Delete
    If Custom_Group_List = ; add something to be able to display disabled menu
      {
      Menu, Gui_Window_Group_Delete, Add
      Menu, ContextMenu1, Disable, Group - &Delete
      }

    ; Hotkeys entry
    Menu, ContextMenu1, Add ; spacer
    Menu, ContextMenu1, Add, &Hotkeys, Gui_Hotkeys

    ; Processes entry
    Menu, ContextMenu1, Add ; spacer
    Menu, Gui_Processes, Color, E10000, Single ; warning colour
    Menu, Gui_Processes, Add, % "End:  " Gui_wid_Title, End_Process_Single
    Loop, Parse, Gui_Dock_Windows_List,| ; don't close docked window - window may remember off-screen position
      {
      If A_LoopField =%Gui_wid%
        Menu, Gui_Processes, Disable, % "End:  " Gui_wid_Title
      }
    Menu, Gui_Processes, Add ; spacer
    Menu, Gui_Processes, Add, % "End All:  " Exe_Name%RowText%, End_Process_All_Instances
    Menu, ContextMenu1, Add, &Processes, :Gui_Processes

    ; Help + Latest changes
    Menu, ContextMenu1, Add ; spacer
    Menu, Gui_Settings_Help, Add, Delete Settings (.ini) && Reload, Delete_Ini_File_Settings
    Menu, Gui_Settings_Help, Add, ; spacer
    Menu, Gui_Settings_Help, Add, Help, HELP_and_LATEST_VERSION_CHANGES
    Menu, Gui_Settings_Help, Add, Latest Changes, HELP_and_LATEST_VERSION_CHANGES
    Menu, ContextMenu1, Add, Settings && Help, :Gui_Settings_Help

    Menu, ContextMenu1, Show, %A_GuiX%, %A_GuiY%
    }
Return



; DOCKED WINDOWS MENU SECTION:
;============================================================================================================================

Gui_Dock_Windows:
  Edge_Dock_%Gui_wid% =%Gui_wid% ; write window ID to a unique variable
  Edge_Dock_Position_%Gui_wid% :=A_ThisMenuItem ; store Left, Right, etc
  WinGet, Edge_Dock_State_%Gui_wid%, MinMax, ahk_id %Gui_wid%
  If Edge_Dock_State_%Gui_wid% =-1 ; if window is mimised, un-minimise
    WinRestore, ahk_id %Gui_wid%
  WinGetPos, Edge_Dock_X_%Gui_wid%, Edge_Dock_Y_%Gui_wid%, Edge_Dock_Width_%Gui_wid%, Edge_Dock_Height_%Gui_wid%, ahk_id %Gui_wid%
  Edge_Dock_X_Initial_%Gui_wid% := Edge_Dock_X_%Gui_wid%
  Edge_Dock_Y_Initial_%Gui_wid% := Edge_Dock_Y_%Gui_wid%
  Edge_Dock_Width_Initial_%Gui_wid% := Edge_Dock_Width_%Gui_wid%
  Edge_Dock_Height_Initial_%Gui_wid% := Edge_Dock_Height_%Gui_wid%
  WinGet, Edge_Dock_AlwaysOnTop_%Gui_wid%, ExStyle, ahk_id %Gui_wid% ; store AlwaysOnTop original status
  If Gui_Dock_Windows_List =
    Gui_Dock_Windows_List =%Gui_wid% ; keep track of number of docked windows
  Else
    Gui_Dock_Windows_List =%Gui_Dock_Windows_List%|%Gui_wid%
  WinSet, AlwaysOnTop, On, ahk_id %Gui_wid%
  Gosub, Alt_Esc_Check_Alt_State ; hides alt-tab gui - shows again if alt still pressed
Gui_Dock_Windows_ReDock:
  Edge_Dock_X =
  Edge_Dock_Y =
  ; leave just 5 pixels (Edge_Dock_Border_Visible) of side visible
  If Edge_Dock_Position_%Gui_wid% contains Left
    Edge_Dock_X := - ( Edge_Dock_Width_%Gui_wid% - Edge_Dock_Border_Visible )
  If Edge_Dock_Position_%Gui_wid% contains Right
    Edge_Dock_X := A_ScreenWidth - Edge_Dock_Border_Visible
  If Edge_Dock_Position_%Gui_wid% contains Top
    Edge_Dock_Y := - ( Edge_Dock_Height_%Gui_wid% - Edge_Dock_Border_Visible )
  If Edge_Dock_Position_%Gui_wid% contains Bottom
    Edge_Dock_Y := A_ScreenHeight - Edge_Dock_Border_Visible
  WinMove, ahk_id %Gui_wid%,, %Edge_Dock_X%, %Edge_Dock_Y%

  SetTimer, Check_Mouse_Position, %Edge_Dock_Activation_Delay% ; change to affect response time to having mouse over edge-docked window
Return



Check_Mouse_Position:
  If Gui_Dock_Windows_List = ; keep track of number of docked windows
    {
    SetTimer, Check_Mouse_Position, Off
    SetTimer, Check_Mouse_Position_Deactivate, Off
    Return
    }

  Loop, Parse, Gui_Dock_Windows_List,| ; check if windows in docked list have been closed before un-docking
    {
    IfWinNotExist, ahk_id %A_LoopField%
      {
      Gui_wid =%A_LoopField%
      Gosub, Gui_Un_Dock_Window
      }
    }

  WinGet, Previously_Active_Window_Before_Using_Docked, ID, A
  Edge_Dock_Active_Window =

  If ( Edge_Dock_%Previously_Active_Window_Before_Using_Docked% != Blank ) ; check keyboard focus
    {
    CoordMode, Mouse, Screen
    MouseGetPos,Check_Mouse_Position_X, Check_Mouse_Position_Y
    Edge_Dock_Active_Window =%Previously_Active_Window_Before_Using_Docked%
    }
  MouseGetPos,,, Mouse_Over_Window
  If ( Edge_Dock_%Mouse_Over_Window% != Blank ) ; over-ride keyboard with mouse "focus" if necessary
    {
    Edge_Dock_Active_Window =%Mouse_Over_Window%
    WinActivate, ahk_id %Mouse_Over_Window%
    }

  If Edge_Dock_Active_Window != ; i.e. window is already docked
    {
    SetTimer, Check_Mouse_Position, Off

    WinGet, PID_Edge_Dock_Active_Window, PID, ahk_id %Edge_Dock_Active_Window%
    Edge_Dock_X =
    Edge_Dock_Y =
    ; move window onto screen
    If Edge_Dock_Position_%Edge_Dock_Active_Window% contains Left
      Edge_Dock_X =0
    If Edge_Dock_Position_%Edge_Dock_Active_Window% contains Right
      Edge_Dock_X := A_ScreenWidth - Edge_Dock_Width_%Edge_Dock_Active_Window%
    If Edge_Dock_Position_%Edge_Dock_Active_Window% contains Top
      Edge_Dock_Y =0
    If Edge_Dock_Position_%Edge_Dock_Active_Window% contains Bottom
      Edge_Dock_Y := A_ScreenHeight - Edge_Dock_Height_%Edge_Dock_Active_Window%

    WinSet, AlwaysOnTop, Off, ahk_id %Edge_Dock_Active_Window%
    WinMove, ahk_id %Edge_Dock_Active_Window%,, %Edge_Dock_X%, %Edge_Dock_Y%
    SetTimer, Check_Mouse_Position_Deactivate, %Edge_Dock_Activation_Delay%
    }
Return



Check_Mouse_Position_Deactivate: ; check if not over an edge-docked window any more
  Loop, Parse, Gui_Dock_Windows_List,| ; check if windows in docked list have been closed before un-docking
    {
    IfWinNotExist, ahk_id %A_LoopField%
      {
      Gui_wid =%A_LoopField%
      Gui_Un_Dock_Window_No_Alt_Esc =1
      Gosub, Gui_Un_Dock_Window
      }
    }

    WinGet, Style, Style, ahk_id %Edge_Dock_Active_Window%
    If ( Style & WS_DISABLED ) ; don't allow disabled windows to be undocked (e.g., showing save box)
      Return

    ; retrieve active window focus and mouse over window - active window has priority
    WinGet, PID_Active_Window_Now, PID, A
    WinGet, Active_Window_Now_ID, ID, A
    WinGetTitle, Active_Window_Now_Title, A ; use titles to check if in same program title but over a problematic control such as xplorer2 dropdownbox (different id and pid)
    WinGetTitle, Edge_Dock_Active_Window_Title, ahk_id %Edge_Dock_Active_Window%
    WinGetTitle, Active_Window_Now_Mouse_Title, ahk_id %Active_Window_Now_Mouse%

    CoordMode, Mouse, Screen
    MouseGetPos,Active_Window_Now_Mouse_X, Active_Window_Now_Mouse_Y, Active_Window_Now_Mouse
    If ((Check_Mouse_Position_X >= Active_Window_Now_Mouse_X -10 and Check_Mouse_Position_X <= Active_Window_Now_Mouse_X +10) ; ; mouse not moved - e.g. clicked taskbar
      and (Check_Mouse_Position_Y >= Active_Window_Now_Mouse_Y -10 and Check_Mouse_Position_Y <= Active_Window_Now_Mouse_Y +10)
      and (Active_Window_Now_Title = Edge_Dock_Active_Window_Title))
        Return    

    If (Active_Window_Now_Title = Edge_Dock_Active_Window_Title and Active_Window_Now_Mouse_Title = ""
          and (Active_Window_Now_ID != TaskBar_ID and Active_Window_Now_Mouse != TaskBar_ID))
        Return
    If (PID_Active_Window_Now != PID_Edge_Dock_Active_Window) ; compare pid to check that a child window is not created/active
      Gosub, Gui_Dock_Windows_ReDock_Initiate
    Else
      {
      WinGet, PID_Active_Window_Now_Mouse, PID, ahk_id %Active_Window_Now_Mouse%
      If (PID_Active_Window_Now_Mouse != PID_Edge_Dock_Active_Window)
        {
        Gosub, Gui_Dock_Windows_ReDock_Initiate
        If Gui_Dock_Windows_List contains %Previously_Active_Window_Before_Using_Docked% ; activate window under mouse to prevent looping
          WinActivate, ahk_id %Active_Window_Now_Mouse%
        Else
          WinActivate, ahk_id %Previously_Active_Window_Before_Using_Docked%
        }
      }
Return



Gui_Dock_Windows_ReDock_Initiate:
  SetTimer, Check_Mouse_Position_Deactivate, Off
  WinSet, AlwaysOnTop, On, ahk_id %Edge_Dock_Active_Window%
  WinGetPos, Edge_Dock_X_%Edge_Dock_Active_Window%, Edge_Dock_Y_%Edge_Dock_Active_Window%, Edge_Dock_Width_%Edge_Dock_Active_Window%
    , Edge_Dock_Height_%Edge_Dock_Active_Window%, ahk_id %Edge_Dock_Active_Window%
  Gui_wid =%Edge_Dock_Active_Window%
  Gosub, Gui_Dock_Windows_ReDock
Return




Gui_Un_Dock_Window:
  If Gui_Un_Dock_Window_No_Alt_Esc !=1
    Gosub, Alt_Esc_Check_Alt_State ; hides alt-tab gui - shows again if alt still pressed
  Gui_Un_Dock_Window_No_Alt_Esc = ; reset
  If ! ( Edge_Dock_AlwaysOnTop_%Gui_wid% & 0x8 ) ; 0x8 is WS_EX_TOPMOST - keep AlwaysOnTop if originally on top
    WinSet, AlwaysOnTop, Off, ahk_id %Gui_wid%
  WinMove, ahk_id %Gui_wid%,, % Edge_Dock_X_Initial_%Gui_wid%, % Edge_Dock_Y_Initial_%Gui_wid%, % Edge_Dock_Width_Initial_%Gui_wid%
    , % Edge_Dock_Height_Initial_%Gui_wid% ; original position

  ; erase variables
  Edge_Dock_%Gui_wid% =
  Edge_Dock_X_Initial_%Gui_wid% =
  Edge_Dock_Y_Initial_%Gui_wid% =
  Edge_Dock_Width_Initial_%Gui_wid% =
  Edge_Dock_Height_Initial_%Gui_wid% =
  Edge_Dock_State_%Gui_wid% =
  Edge_Dock_X_%Gui_wid% =
  Edge_Dock_Y_%Gui_wid% =
  Edge_Dock_Width_%Gui_wid% =
  Edge_Dock_Height_%Gui_wid% =
  Edge_Dock_Position_%Gui_wid% =
  Edge_Dock_AlwaysOnTop_%Gui_wid% =

  If Gui_Dock_Windows_List =%Gui_wid%
    StringReplace, Gui_Dock_Windows_List, Gui_Dock_Windows_List,%Gui_wid% ; keep track of number of docked windows
  Else
    StringReplace, Gui_Dock_Windows_List, Gui_Dock_Windows_List,%Gui_wid%| ; keep track of number of docked windows
Return



Gui_Un_Dock_Windows_All:
;;  If Gui_Un_Dock_Windows_All_No_Alt_Esc != 1
;;    Gosub, Alt_Esc
  Loop, Parse, Gui_Dock_Windows_List,| ; check if windows in docked list have been closed before un-docking
    {
    Gui_wid := A_LoopField
    Gui_Un_Dock_Window_No_Alt_Esc =1
    Gosub, Gui_Un_Dock_Window
    }
Return



; HOTKEYS MENU SECTION:
;============================================================================================================================

Gui_Hotkeys:
  Gosub, Alt_Esc
  Gui, 2: Default ; for listview operations
  Gui, 2: Font, s10
  Gui, 2: Add, Text, xm y+15, Main hotkeys:
  Gui, 2: Font
  Gui, 2: Add, Text, x+5 yp+2, (Note that "Alt" must be either Alt, Ctrl, Shift, Win or mouse XButton1 / 2 - but using XButton requires "Shift+Tab" is a single key!)
  ; Gui_Add_Hotkey(Gui number, Text, Comment, variable name)
  Gui_Add_Hotkey(2, "Alt","(key in Alt+Tab)", "Alt_Hotkey")
    GuiControl, 2: Disable, Alt_Hotkey_Tab
    GuiControl, 2: Disable, Alt_Hotkey_Esc
    GuiControl, 2: Disable, Alt_Hotkey_Enter
    GuiControl, 2: Disable, Alt_Hotkey_WheelUp 
    GuiControl, 2: Disable, Alt_Hotkey_WheelDown
    GuiControl, 2: Disable, Alt_Hotkey_Hotkey 
  Gui_Add_Hotkey(2, "Tab","(key in Alt+Tab)", "Tab_Hotkey")
  Gui_Add_Hotkey(2, "Shift+Tab","(Key(s) in Alt+Shift+Tab)", "Shift_Tab_Hotkey")
  Gui_Add_Hotkey(2, "Esc","(key in Alt+Esc)", "Esc_Hotkey")
    Gui, 2: Font, s10
  Gui, 2: Add, Text,xm y+15, Single keys:
    Gui, 2: Font
  Gui, 2: Add, Text, x+5 yp+2, (Alternative way to show the Alt+Tab list by a 1 key (blank for no hotkey) and another for selection)
  Gui_Add_Hotkey(2, "Alt+Tab list", "", "Single_Key_Show_Alt_Tab")
  Gui_Add_Hotkey(2, "Alt+Tab selection", "", "Single_Key_Hide_Alt_Tab")
    Gui, 2: Font, s10
  Gui, 2: Add, Text,xm y+30, Group hotkeys:
    Gui, 2: Font
  GuiControl, 2: Focus, Static1

  Gui, 2: Add, ListView, section xm r15 w470 -Multi, Group name|Assigned hotkey
  Loop, Parse, Custom_Group_List, |
  	LV_Add("", A_LoopField, %A_LoopField%_Group_Hotkey)
  Gui, 2: Add, Button, x+10 yp+40 gGui_2_Group_Hotkey_Assign w170, Assign hotkey to selected group:
  Gui, 2: Add, Hotkey, vGui_2_Group_Hotkey xp y+5, %Hotkey%
  Gui, 2: Add, Button, xp y+30 gGui_2_Group_Hotkey_Clear w170, Clear hotkey of selected group
  Gui, 2: Add, Text, xp y+30, ( Key: !=Alt, ^=Ctrl, +=Shift, #=Win )
  Gui, 2: Add, Text, xm+305, WARNING! No error checking for hotkeys - be careful what you choose!
  Gui, 2: Add, Button, xm+430 g2GuiClose w100, &Cancel
  Gui, 2: Add, Button, x+20 gGui_2_OK wp Default, &OK
  Gui, 2: Show,, Hotkeys
Return


  
Gui_2_Group_Hotkey_Assign:
  Selected_Row := LV_GetNext(0, "F")
  If not Selected_Row
    Return
  Gui, 2: Submit, NoHide
  If not Gui_2_Group_Hotkey
    Return
  Loop, Parse, Custom_Group_List,|
    {
    If %A_LoopField%_Group_Hotkey =%Gui_2_Group_Hotkey%
      {
      Msgbox, Hotkey already exists! Please clear the duplicate hotkey first.
      Return
      }
    }
  LV_Modify(Selected_Row, "Col2", Gui_2_Group_Hotkey)
Return



Gui_2_Group_Hotkey_Clear:
  Selected_Row := LV_GetNext(0, "F")
  If not Selected_Row
    Return
  LV_Modify(Selected_Row, "Col2", "")
Return



Gui_2_OK:
  Loop, % LV_GetCount() ; process group hotkeys from listview
    {
    LV_GetText(Group_Name, A_Index, 1)
    LV_GetText(Group_Hotkey, A_Index, 2)
    %Group_Name%_Group_Hotkey =%Group_Hotkey%
    }
  Gui, 2: Submit
  Gui, 2: Destroy
  Gui_Read_Hotkey(2, "Alt_Hotkey") ; Gui_Read_Hotkey(Gui number, associated variable)
  Gui_Read_Hotkey(2, "Tab_Hotkey")
  Gui_Read_Hotkey(2, "Shift_Tab_Hotkey")
  Gui_Read_Hotkey(2, "Esc_Hotkey")
  Gui_Read_Hotkey(2, "Single_Key_Show_Alt_Tab")
  Gui_Read_Hotkey(2, "Single_Key_Hide_Alt_Tab")
  Reload 
Return



Gui_Read_Hotkey(Gui, var_name)
{
  Global
  %var_name% =
  If %var_name%_Alt =1
    %var_name% = % %var_name% "!"
  If %var_name%_Ctrl =1
    %var_name% = % %var_name% "^"
  If %var_name%_Shift =1
    %var_name% = % %var_name% "+"
  If %var_name%_Win =1
    %var_name% = % %var_name% "#"
  If %var_name%_Tab =1
    %var_name% = % %var_name% "Tab"
  If %var_name%_Esc =1
    %var_name% = % %var_name% "Esc"
  If %var_name%_Enter =1
    %var_name% = % %var_name% "Enter"
  If %var_name%_XButton1 =1
    %var_name% = % %var_name% "XButton1"
  If %var_name%_XButton2 =1
    %var_name% = % %var_name% "XButton2"
  If %var_name%_WheelUp =1
    %var_name% = % %var_name% "WheelUp"
  If %var_name%_WheelDown =1
    %var_name% = % %var_name% "WheelDown"
  If (%var_name%_Hotkey != "None" and %var_name% = "")
    %var_name% = % %var_name% %var_name%_Hotkey
}



Gui_Add_Hotkey(Gui, Text, Comment, var_name)
{
  Global
  Local Alt, Ctrl, Shift, Win, Tab, Esc, Enter, XButton1, XButton2, WheelUp, WheelDown, Hotkey, temp_hotkey
  temp_hotkey =% %var_name%
  If %var_name% contains !
    {
    Alt=1
    StringReplace, temp_hotkey, temp_hotkey, !,
    }
  Else
    Alt=0
  If %var_name% contains ^
    {
    Ctrl=1
    StringReplace, temp_hotkey, temp_hotkey, ^,
    }
  Else
    Ctrl=0
  If %var_name% contains +
    {
    Shift=1
    StringReplace, temp_hotkey, temp_hotkey, +,
    }
  Else
    Shift=0
  If %var_name% contains #
    {
    Win=1
    StringReplace, temp_hotkey, temp_hotkey, #,
    }
  Else
    Win=0
  If %var_name% contains Tab
    {
    Tab=1
    StringReplace, temp_hotkey, temp_hotkey, Tab,
    }
  Else
    Tab=0
  If %var_name% contains Esc
    {
    Esc=1
    StringReplace, temp_hotkey, temp_hotkey, Esc,
    }
  Else
    Esc=0
  If %var_name% contains Enter
    {
    Enter=1
    StringReplace, temp_hotkey, temp_hotkey, Enter,
    }
  Else
    Enter=0
  If %var_name% contains XButton1
    {
    XButton1=1
    StringReplace, temp_hotkey, temp_hotkey, XButton1,
    }
  Else
    XButton1=0
  If %var_name% contains XButton2
    {
    XButton2=1
    StringReplace, temp_hotkey, temp_hotkey, XButton2,
    }
  Else
    XButton2=0
  If %var_name% contains WheelUp
    {
    WheelUp=1
    StringReplace, temp_hotkey, temp_hotkey, WheelUp,
    }
  Else
    WheelUp=0
  If %var_name% contains WheelDown
    {
    WheelDown=1
    StringReplace, temp_hotkey, temp_hotkey, WheelDown,
    }
  Else
    WheelDown=0
  Hotkey=%temp_hotkey% ; remainder
  
  Gui, %Gui%: Font, bold
  Gui, %Gui%: Add, Text, xm, %Text%
  Gui, %Gui%: Font
  If Comment !=
    Gui, %Gui%: Add, Text, x80 yp, %Comment%
  Gui, %Gui%: Add, Checkbox, v%var_name%_Alt Checked%Alt% x200 yp, Alt
  Gui, %Gui%: Add, Checkbox, v%var_name%_Ctrl Checked%Ctrl% x+10, Ctrl
  Gui, %Gui%: Add, Checkbox, v%var_name%_Shift Checked%Shift% x+10, Shift
  Gui, %Gui%: Add, Checkbox, v%var_name%_Win Checked%Win% x+10, Win
  Gui, %Gui%: Add, Checkbox, v%var_name%_Tab Checked%Tab% x+10, Tab
  Gui, %Gui%: Add, Checkbox, v%var_name%_Esc Checked%Esc% x+10, Esc
  Gui, %Gui%: Add, Checkbox, v%var_name%_Enter Checked%Enter% x+10, Enter
  Gui, %Gui%: Add, Text, x+10, XButton:
  Gui, %Gui%: Add, Checkbox, v%var_name%_XButton1 Checked%XButton1% x+2, 1
  Gui, %Gui%: Add, Checkbox, v%var_name%_XButton2 Checked%XButton2% x+2, 2
  Gui, %Gui%: Add, Text, x+10, Wheel:
  Gui, %Gui%: Add, Checkbox, v%var_name%_WheelUp Checked%WheelUp% x+2, Up
  Gui, %Gui%: Add, Checkbox, v%var_name%_WheelDown Checked%WheelDown% x+2, Down
  Gui, %Gui%: Add, Hotkey, v%var_name%_Hotkey x+10 yp-3, %Hotkey%
}



; GROUPS MENU SECTION:
;============================================================================================================================

Gui_Window_Group_No_Filter:
  Custom_Group_Active =
  Gosub, Alt_Esc_Check_Alt_State
Return



Gui_Window_Group_Load:
  Custom_Group_Active =%A_ThisMenuItem%
  If %A_ThisMenuItem% contains Exclude_Not_In_List
    Exclude_Not_In_List =1 ; need to set variable Exclude_Not_In_List=value in exclude list each time a list is loaded!
  Else
    Exclude_Not_In_List =
  Gosub, Alt_Esc_Check_Alt_State ; hides alt-tab gui - shows again if alt still pressed
Return



Gui_Window_Group_Save_Edit:
  Gosub, Alt_Esc
  Gui, 3: Default ; for listview operations
  Gui, 3: Add, Text, y+15,
                    (
Choose window titles/exes to include/exclude when LOADING a list:

  - Double-click / F2 to rename an entry.
  - Titles match anywhere within a target window's title (exe is ignored).
  - Delete the title completely to match the EXE instead.
  - To EXCLUDE a window, prefix title or EXE with an exclamation: e.g. !notepad.exe, or only ! in title column.
  - "Exclude all windows not in list?" ignores new windows that do not match the list.
  - Only ticked items are added to the list. Unticked are removed.
  - Priority of rules is top (highest) to bottom (lowest).
  - Not case sensitive. 
                    )
  IL_Destroy(Gui_3_ImageList)
  Gui, 3: Add, ListView, xm y+15 r15 w500 Checked -ReadOnly -Multi NoSortHdr AltSubmit gListView3_Event, (Partial) Window Title|EXE
    Gui_3_ImageList:= IL_Create(15,5,0)
    LV_SetImageList(Gui_3_ImageList, 1)
    IL_Add( Gui_3_ImageList, "C:\WINDOWS\system32\shell32.dll" , 110) ; not included icon

  Gui, Add, Picture, icon48 x+10 yp+100 gGui_3_ListView_Swap_Rows_Up, C:\WINDOWS\system32\progman.exe ; up arrow
  Gui, Add, Picture, icon45 gGui_3_ListView_Swap_Rows_Down, C:\WINDOWS\system32\progman.exe ; down arrow
  Gui, 3: Add, Text, xm+20, Manual add:
  Gui_3_Manual_Allow_Blank =1
  Gui, 3: Add, Edit, x+5 w200 gGui_3_Manual_Exe_Blank vGui_3_Manual_Title, [window title]
  Gui, 3: Add, Edit, x+5 w100 gGui_3_Manual_Title_Blank vGui_3_Manual_Exe, [program.exe]
  Gui, 3: Add, Button, x+10 w80 gGui3_Manual_Add, A&dd
  Gui, 3: Add, Text, xm+20 y+30, Group name:
  If Custom_Group_List contains Exclude_Not_In_List
    StringReplace, Gui_3_Combobox_Custom_Group_List, Gui_3_Combobox_Custom_Group_List, Exclude_Not_In_List, ; blank
  Else
    Gui_3_Combobox_Custom_Group_List =%Custom_Group_List%
  Gui, 3: Add, ComboBox, x+5 w200 vCustom_Name, %Gui_3_Combobox_Custom_Group_List%
    GuiControl, ChooseString, Custom_Name, %Custom_Group_Active%
  Gui, 3: Add, Checkbox, x+20 vExclude_Not_In_List, Exclude all windows not in list?
  If Custom_Group_Active != ; else step below gives an error
    If %Custom_Group_Active% contains Exclude_Not_In_List
      GuiControl,, Exclude_Not_In_List, 1 ; check box
  Gui, 3: Add, Button, xm+10 y+20 w80 gGui3_RESET, &Reset List
  Gui, 3: Add, Button, x+20 wp gGui3_SelectALL, Select &All
  Gui, 3: Add, Button, x+20 wp gGui3_SelectNONE, Select &None
  Gui, 3: Add, Button, x+20 wp g3GuiClose, &Cancel
  Gui, 3: Add, Button, x+20 wp Default gGui3_OK, &OK

  If Custom_Group_Active =
    Loop, %Window_Found_Count% ; populate listview
      {
      If ( InStr(Title%A_Index%, "-- Dialog --") and not InStr(Title%A_Index%, ">") )
        {
        StringReplace, Cropped_Title_temp, Title%A_Index%, -- Dialog --%A_Space%%A_Space%, ; remove prefix
        LV_Add("Check Icon2", Cropped_Title_temp, Exe_Name%A_Index%) ; Icon 1 = not included icon, Icon 2 = blank
        continue
        }
      LV_Add("Check Icon2", Title%A_Index%, Exe_Name%A_Index%) ; Icon 1 = not included icon, Icon 2 = blank
      }
  Else
    Loop, Parse, %Custom_Group_Active%,|
      {
      If A_LoopField =Exclude_Not_In_List
        Continue
      If A_LoopField contains .exe
        LV_Add("Check Icon2" ,"", A_LoopField) ; Icon 1 = not included icon, Icon 2 = blank
      Else
        LV_Add("Check Icon2" ,A_LoopField,"") ; Icon 1 = not included icon, Icon 2 = blank
      }
  Gosub, Gui_3_Update_Icons

  DetectHiddenWindows, On
  Gui, 3: +LastFound 
  Gui_3_ID := WinExist() ; for auto-sizing columns later
  LV_ModifyCol(1, 350)
  ControlGet, Gui_3_Listview_Style, Style,, SysListView321, ahk_id %Gui_3_ID%
  If ( Gui_3_Listview_Style & WS_VSCROLL ) ; has a vertical scrollbar - reduced width for listview
    Gui_3_Col_2_w := 500 - 350 - Scrollbar_Vertical_Thickness - 4
  Else
    Gui_3_Col_2_w := 500 - 350 - 4
  LV_ModifyCol(2, Gui_3_Col_2_w)
  Gui, 3: Show,, Group - Save/Edit
Return




Gui_3_ListView_Swap_Rows_Up:
  If LV_GetNext() =0 ; no row selected
    {
    LV_Modify(LV_GetCount(), "Select Focus")
    Return
    }
  ListView_Swap_Rows("Up") ; "move" selected row up 1 - higher priority
  Gosub, Gui_3_Update_Icons
Return


Gui_3_ListView_Swap_Rows_Down:
  If LV_GetNext() =0 ; no row selected
    {
    LV_Modify(1, "Select Focus")
    Return
    }
  ListView_Swap_Rows("Down") ; "move" selected row down 1 - lower priority
  Gosub, Gui_3_Update_Icons
Return



ListView_Swap_Rows(Direction) ; Direction=Up/Down -swaps all text in each column of 2 adjacent rows and their checked states
{
  Row_Selected := LV_GetNext()
  If Direction =Up
    {
    Row_Swap_With := Row_Selected -1
    If Row_Swap_With =0 ; reached top of listview
      Return 
    }
  Else
    {
    Row_Swap_With := Row_Selected +1
    If ( Row_Swap_With > LV_GetCount() ) ; reached end of listview
      Return 
    }
  Loop, % LV_GetCount("Col")
    {
    LV_GetText(Row_Text_%Row_Selected%_%A_Index%, Row_Selected, A_Index)
    LV_GetText(Row_Text_%Row_Swap_With%_%A_Index%, Row_Swap_With, A_Index)
    }
  If ( LV_GetNext(Row_Selected - 1, "C") = Row_Selected ) ; save box checked states
    Row_Selected_Checked =Check
  Else
    Row_Selected_Checked =
  If ( LV_GetNext(Row_Swap_With - 1, "C") = Row_Swap_With )
    Row_Swap_With_Checked =Check
  Else
    Row_Swap_With_Checked =
  Loop, % LV_GetCount("Col")
    {
    LV_Modify(Row_Selected, "-Focus -Select Col" . A_Index, Row_Text_%Row_Swap_With%_%A_Index%)
    LV_Modify(Row_Swap_With, "Focus Select Col" . A_Index, Row_Text_%Row_Selected%_%A_Index%)
    }
  If Row_Swap_With_Checked =Check
    LV_Modify(Row_Selected, "Check")
  Else
    LV_Modify(Row_Selected, "-Check")
  If Row_Selected_Checked =Check
    LV_Modify(Row_Swap_With, "Check")
  Else
    LV_Modify(Row_Swap_With, "-Check")
}



Gui3_OK:
  Gui, 3: Submit
  
  If Custom_Name =
    {
    MsgBox, 48, ERROR, Enter a valid name for the group!
    Gui, 3: Show
    Return
    }
  StringReplace, Custom_Name, Custom_Name,%A_Space%,_,All

  If Exclude_Not_In_List =1 ; checked - add suffix to variable name to filter
    %Custom_Name% = |Exclude_Not_In_List ; add first entry - will parse and process when filtering alt-tab listview
    ; need to set variable Exclude_Not_In_List=value in exclude list each time a list is loaded!
  Else
    %Custom_Name% = ; make sure it is empty in case it previously existed (over-writing)
  Loop
    {
  	RowNumber := LV_GetNext(RowNumber, "C")  ; Resume the search at the row after that found by the previous iteration.
  	If not RowNumber  ; The above returned zero, so there are no more checked rows.
  		Break
  	LV_GetText(Title_temp, RowNumber)
  	If Title_temp = ; blank therefore set the exe name instead
    	LV_GetText(Title_temp, RowNumber, 2)
  	If Title_temp =! ; exclude exe name instead
      {
    	LV_GetText(Title_temp, RowNumber, 2)
    	If Title_temp not contains !
      	Title_temp =!%Title_temp%
    	}
    %Custom_Name% = % %Custom_Name% "|" Title_temp
    }
  StringTrimLeft, %Custom_Name%, %Custom_Name%, 1 ; trim initial |
  If Custom_Group_List = ; blank, no need for seperator
    Custom_Group_List =% Custom_Name ; store name to a list for finding later
  Else
    {
    If Custom_Group_List not contains %Custom_Name%
      Custom_Group_List =% Custom_Group_List "|" Custom_Name ; store name to a list for finding later
    }
  Custom_Group_Active =% Custom_Name ; automatically apply the saved group filter
  Gosub, 3GuiClose
Return



ListView3_Event:
  If A_GuiEvent = E ; edited a row
    Gosub, Gui_3_Update_Icons

  If A_GuiEvent = DoubleClick
     SendMessage, 0x1017, LV_GetNext(0, "Focused") - 1, 0, SysListView321  ; 0x1017 is LVM_EDITLABEL 

  If (A_GuiEvent = "K" AND A_EventInfo = 0x71)  ; Key-down of the F2 key (0x71 is its virtual key). 
     SendMessage, 0x1017, LV_GetNext(0, "Focused") - 1, 0, SysListView321  ; 0x1017 is LVM_EDITLABEL 
Return



Gui_3_Update_Icons:
  Loop, % LV_GetCount()
    {
    Gui_3_Row_To_Modify =%A_Index%
    Gui_3_Icon =2 ; blank icon as default
    Loop, 2 ; check column 1 and 2
      {
      LV_GetText(Title_temp, Gui_3_Row_To_Modify, A_Index)
      If Title_temp contains !
        Gui_3_Icon =1 ; not included icon
      }
    LV_Modify(Gui_3_Row_To_Modify, "Icon" . Gui_3_Icon)
    }
Return



Gui3_Manual_Add:
  Gui, 3: Submit, NoHide
  Gui_3_Manual_Allow_Blank =1
  Gosub, Gui_3_Manual_Title_Blank
  Gui_3_Manual_Allow_Blank =1
  Gosub, Gui_3_Manual_Exe_Blank
  Gui_3_Icon =2 ; blank icon
  If Gui_3_Manual_Title contains !
    Gui_3_Icon =1 ; not included icon
  If Gui_3_Manual_Exe contains !
    Gui_3_Icon =1
  LV_Add("Check Icon" . Gui_3_Icon,Gui_3_Manual_Title,Gui_3_Manual_Exe)
  GuiControl, Focus, &OK
  Sleep, 50
  GuiControl, +Default, &OK
Return



Gui3_RESET:
  Gui, 3: Destroy
  Gosub, Gui_Window_Group_Save_Edit
Return



Gui3_SelectALL:
  Loop, %Window_Found_Count%
    LV_Modify(A_Index, "Check")
Return



Gui3_SelectNONE:
  Loop, %Window_Found_Count%
    LV_Modify(A_Index, "-Check")
Return



Gui_3_Manual_Title_Blank:
  If Gui_3_Manual_Allow_Blank =1
    GuiControl,, Gui_3_Manual_Title, ; blank 
  Gui_3_Manual_Allow_Blank =0
  GuiControl, +Default, A&dd
Return



Gui_3_Manual_Exe_Blank:
  If Gui_3_Manual_Allow_Blank =1
    GuiControl,, Gui_3_Manual_Exe, ; blank 
  Gui_3_Manual_Allow_Blank =0
  GuiControl, +Default, A&dd
Return





Gui_Window_Group_Delete:
  If Custom_Group_Active =%A_ThisMenuItem%
    Custom_Group_Active =
  StringReplace, Custom_Group_List, Custom_Group_List, |%A_ThisMenuItem% ; remove item from list
  If ErrorLevel =1
    {
    StringReplace, Custom_Group_List, Custom_Group_List, %A_ThisMenuItem%| ; remove 1st item from list
    If ErrorLevel =1
      StringReplace, Custom_Group_List, Custom_Group_List, %A_ThisMenuItem% ; remove only item from list
    }
  Hotkey, % %A_ThisMenuItem%_Group_Hotkey, Off, UseErrorLevel
  IniDelete, Alt_Tab_Settings.ini, Custom_Groups, %A_ThisMenuItem%
  IniDelete, Alt_Tab_Settings.ini, Group_Hotkey, %A_ThisMenuItem%_Group_Hotkey
  Gosub, Alt_Esc_Check_Alt_State ; hides alt-tab gui - shows again if alt still pressed
Return



Group_Hotkey: ; from loading ini file - determine hotkey behaviour based on current hotkey
  Loop, Parse, Custom_Group_List,|
    {
    If %A_LoopField%_Group_Hotkey =%A_ThisHotkey% ; find which group to activate
      {
      If Custom_Group_Active !=%A_LoopField%
        {
        Custom_Group_Active=%A_LoopField% ; load custom group
        If %Custom_Group_Active% contains Exclude_Not_In_List
          Exclude_Not_In_List =1 ; need to set variable Exclude_Not_In_List=value in exclude list each time a list is loaded!
        Else
          Exclude_Not_In_List =
        Number_Tabs_To_Send =-1 ; initialise
        New_Group_Loaded =1
        }

      ; check if currently active window is in the newly loaded group, else switch to 1st
      Group_Hotkey_Switching =1 ; skip selected code in Alt+Tab section
      Gosub, Single_Key_Show_Alt_Tab ; show list to generate updated variables to check
      WinWaitActive, Alt-Tab Replacement
      If Active_ID_Found =0 ; switch to 1st window in new window list if active window wasn't included (i.e. wasn't in group)
        {
        Gosub, ListView_Destroy
        Group_Hotkey_Switching = ; reset
        New_Group_Loaded = ; reset
        Return
        }
      If  New_Group_Loaded =1
        {
        Gosub, ListView_Destroy
        Group_Hotkey_Switching = ; reset
        New_Group_Loaded = ; reset
        Return
        }

      ; abort switching and start to cycle through windows in list next
      If Viewed_Window_List =
        Viewed_Window_List =%Active_ID%
      Else
        Viewed_Window_List = % Viewed_Window_List "|" Active_ID
      If Window_Found_Count <=1 ; fix for for 1 or 0 windows
        Gosub, Alt_Esc
      Loop, %Window_Found_Count%
        {
        IfNotInString , Viewed_Window_List, % Window%A_Index%
          {
          WinActivate, % "ahk_id" Window%A_Index%
          If A_Index =%Window_Found_Count%
            Viewed_Window_List = ; viewed all windows so reset list
          Break
          }
        }
      Group_Hotkey_Switching = ; reset
      New_Group_Loaded = ; reset
      Break
      }
    }
Return




MButton_Close:
  MButton_Clicked =1
  MouseGetPos,,, Mouse_Over_Gui
  If Mouse_Over_Gui =%Gui_ID%
    {
    SetTimer, MButton_Close_Cont, 50
    MouseClick, Left
    ; weird pause after left click - hence using timers - continues after moving mouse
    }
  MButton_Clicked =
Return

MButton_Close_Cont:
SetTimer, MButton_Close_Cont, Off
  GuiControl, Disable, ListView1
  Selected_Row := LV_GetNext()
  LV_GetText(RowText, Selected_Row, 2)  ; Get the row's hidden text
  Gui_wid =% Window%RowText%
  If Gui_wid = ; prevent error if nothing was selected due to delay in program
    Return
  Gosub, End_Process_Single
Return




End_Process_Single:
  GuiControl, Disable, ListView1
  Selected_Row := Selected_Row + 1 ; find window after window to close for positioning focus in listview afterwards
  LV_GetText(RowText, Selected_Row, 2)  ; Get the row's hidden text
  Window_After_1st_Ending_Window_ID =% Window%RowText%
  Gosub, End_Process_Subroutine
  Gosub, End_Process_Update_Listview
Return



End_Process_Subroutine:
  Loop, Parse, Gui_Dock_Windows_List,| ; un-dock docked window first (might remember off-screen position)
    {
    If A_LoopField =%Gui_wid%
      {
      Gui_Un_Dock_Window_No_Alt_Esc =1
      Gosub, Gui_Un_Dock_Window
      }
    }
  PostMessage, 0x112, 0xF060,,, ahk_id %Gui_wid% ; 0x112 = WM_SYSCOMMAND, 0xF060 = SC_CLOSE
  WinWaitClose, ahk_id %Gui_wid%,, 1
Return



End_Process_All_Instances:
  GuiControl, Disable, ListView1
  List_of_Process_To_End = ; need to store list now as re-drawing the listview over-writes necessary variables
  Loop, %Window_Found_Count%
    {
    WinGetClass, Win_Class, % "ahk_id " Window%A_Index%
    If Win_Class = #32770 ; don't try to close dialog windows (e.g. save prompts)
      Continue
    If Exe_Name%RowText% = % Exe_Name%A_Index%
      List_of_Process_To_End =% List_of_Process_To_End "|" Window%A_Index%
    }
  StringTrimLeft, List_of_Process_To_End, List_of_Process_To_End, 1 ; remove 1st | character (empty reference otherwise)

  Window_After_1st_Ending_Window_ID := Selected_Row + 1 ; find window after window to close for positioning focus in listview afterwards
  LV_GetText(RowText, Window_After_1st_Ending_Window_ID, 2)  ; Get the row's hidden text
  Window_After_1st_Ending_Window_ID =% Window%RowText% ; over-ridden below if necessary
  If Exe_Name%RowText% = % Exe_Name%Selected_Row% ; find an earlier window which won't be closed
    {
    Loop, %Window_Found_Count%
      {
      Window_After_1st_Ending_Window_ID := Selected_Row + 1 + A_Index
      If Window_After_1st_Ending_Window_ID =% Window_Found_Count
        {
        LV_GetText(RowText, %Window_Found_Count%, 2)  ; Get the row's hidden text
        If RowText not between 1 and %Window_Found_Count% ; avoid an error when closing all windows
          Break
        Window_After_1st_Ending_Window_ID =% Window%RowText%
        Break
        }
      LV_GetText(RowText, Window_After_1st_Ending_Window_ID, 2)  ; Get the row's hidden text
      If Exe_Name%RowText% != % Exe_Name%Selected_Row% ; find an earlier window which won't be closed
        {
        Window_After_1st_Ending_Window_ID =% Window%RowText%
        Break
        }
      }
    }

  Loop, Parse, List_of_Process_To_End,|
    {
    Gui_wid := A_LoopField
    Gosub, End_Process_Subroutine
    }
  List_of_Process_To_End = ; reset
  Gosub, End_Process_Update_Listview
Return



End_Process_Update_Listview:
  Gosub, Display_List
  Loop, %Window_Found_Count%
    {
    If Window%A_Index% =%Window_After_1st_Ending_Window_ID%
      {
      LV_GetText(RowText, A_Index, 2)  ; Get the row's hidden text
      LV_Modify(RowText, "Focus Select")
      }
    }
  GuiControl, Enable, ListView1
  GuiControl, Focus, ListView1
Return



Key_Pressed_1st_Letter:
  Key_Pressed_ASCII =%A_EventInfo%
  Selected_Row := LV_GetNext(0, "F")
  LV_GetText(RowText, Selected_Row, 2)  ; Get the row's hidden text

  If Key_Pressed_ASCII =93 ; Alt+Apps key - context menu
    {
    Gosub, GuiContextMenu
    Return
    }

  ; \ key - close window
  If (Key_Pressed_ASCII =92 or Key_Pressed_ASCII =220) ; \ or Alt+\
    {
    If ( A_TickCount - Time_Since_Last_Alt_Close < 200 ) ; prevention of accidentally closing too many windows
      Return
    Time_Since_Last_Alt_Close := A_TickCount
    Gui_wid := Window%RowText%
    Gosub, End_Process_Single
    Return
    }

  ; / key - close all instances of exe
  If (Key_Pressed_ASCII =47 or Key_Pressed_ASCII =191) ; / or Alt+/
    {
    If ( A_TickCount - Time_Since_Last_Alt_Close < 200 ) ; prevention of accidentally closing too many windows
      Return
    Time_Since_Last_Alt_Close := A_TickCount
    Gui_wid := Window%RowText%
    Gosub, End_Process_All_Instances
    Return
    }

  Loop, %Window_Found_Count%
    {
    Selected_Row +=1
    If Selected_Row > %Window_Found_Count% ; wrap around to start
      Selected_Row =1
    LV_GetText(List_Title_Text, Selected_Row, 2) ; hidden number column

    ; Check for parent's title for typing first letter
    If Window_Parent_%List_Title_Text% !=
      WinGetTitle, List_Title_Text, % "ahk_id " Window_Parent_%List_Title_Text%
    Else
      WinGetTitle, List_Title_Text, % "ahk_id " Window%List_Title_Text%
    StringUpper, List_Title_Text, List_Title_Text ; need to match against upper case when alt is held down
    List_Title_Text:=Asc(List_Title_Text) ; convert to ASCII key code

    If Key_Pressed_ASCII =%List_Title_Text%
      {
      LV_Modify(Selected_Row, "Focus Select")
      Break
      }
    }
Return



ColumnClickSort:
  If A_EventInfo = 1
    {
    Gosub, Column_Order_Switch
    LV_ModifyCol(2, Sort_By_Column_1)
    Sort_Order_Column =2 ; store sort order for between displaying list
    Sort_Order_Direction =%Sort_By_Column_1%
    }
  Else
    {
    Gosub, Column_Order_Switch
    LV_ModifyCol(A_EventInfo, Sort_By_Column_%A_EventInfo%)
    Sort_Order_Column =%A_EventInfo% ; store sort order for between displaying list
    Sort_Order_Direction = % Sort_By_Column_%A_EventInfo%
    }
Return

Column_Order_Switch:
  If Sort_By_Column_1 = ; for initial click, already sorted by number
    Sort_By_Column_1 =SortDesc
  Else
    {
    If Sort_By_Column_%A_EventInfo% =Sort
      Sort_By_Column_%A_EventInfo% =SortDesc
    Else
      Sort_By_Column_%A_EventInfo% =Sort
    }
Return



ListView_Destroy:
  Critical
  SetTimer, Check_Alt_Hotkey2_Up, Off
  If Single_Key_Show_Alt_Tab_Used =1
    {
    Send, {%Alt_Hotkey2% up}
    Hotkey, *%Single_Key_Hide_Alt_Tab%, Off
    Single_Key_Show_Alt_Tab_Used = ; reset
    }
  Hotkey, %Alt_Hotkey%%Use_AND_Symbol%%Esc_Hotkey%, Off, UseErrorLevel ; UseErrorLevel in case of exiting script before hotkey created
  If Use_Wheel_Scroll_List =1
    {
    Hotkey, %Alt_Hotkey%%Use_AND_Symbol%WheelUp, Off, UseErrorLevel ; previous window
    Hotkey, %Alt_Hotkey%%Use_AND_Symbol%WheelDown, Off, UseErrorLevel ; next window
    }
  Hotkey, %Alt_Hotkey%%Use_AND_Symbol%Mbutton, Off, UseErrorLevel ; close the window clicked on
  Gui, 1: Default
  If Alt_Esc != 1 ; i.e. not called from Alt_Esc
    {
    Selected_Row := LV_GetNext(0, "F")
    LV_GetText(RowText, Selected_Row, 2)  ; Get the row's first-column text.
    }
  Display_List_Shown =0
  Gui, 1: Destroy
  If Alt_Esc != 1 ; i.e. not called from Alt_Esc
    {  
    wid := Window%RowText%
    WinGet, wid_MinMax, MinMax, ahk_id %wid%
    If wid_MinMax =-1 ;minimised
      WinRestore, ahk_id %wid%
    WinActivate, ahk_id %wid%
    }
  Else If Alt_Esc_No_Re_Activate != 1 ; WM_ACTIVATE - clicked outside alt-tab gui 1
    WinActivate, ahk_id %Active_ID%
Return



Retrive_Window_Icon:
  ; WM_GETICON values -    ICON_SMALL =0,   ICON_BIG =1,   ICON_SMALL2 =2

  If Use_Large_Icons_Current =1
    {
    SendMessage, 0x7F, 1, 0,, ahk_id %wid%
    h_icon := ErrorLevel
    }
  Else
    h_icon =
  If ( ! h_icon )
    {
    SendMessage, 0x7F, 2, 0,, ahk_id %wid%
    h_icon := ErrorLevel
      If ( ! h_icon )
        {
        SendMessage, 0x7F, 0, 0,, ahk_id %wid%
        h_icon := ErrorLevel
        If ( ! h_icon )
          {
          If Use_Large_Icons_Current =1
            h_icon := DllCall( "GetClassLong", "uint", wid, "int", -14 ) ; GCL_HICON is -14
          If ( ! h_icon )
            {
            h_icon := DllCall( "GetClassLong", "uint", wid, "int", -34 ) ; GCL_HICONSM is -34
              If ( ! h_icon )
                h_icon := DllCall( "LoadIcon", "uint", 0, "uint", 32512 ) ; IDI_APPLICATION is 32512
            }
          }
        }
    }
  If (h_icon =FAIL or ! h_icon) ; no icon found
    {
  	Gui_Icon_Number := IL_Add(ImageListID1, "C:\WINDOWS\system32\shell32.dll" , 3) ; generic icon
    WinGetTitle, Title%Window_Found_Count%, ahk_id %wid% ; store titles to a list
    Title%Window_Found_Count% :="/      NOT RESPONDING!!!: " Title%Window_Found_Count% ; indent listview title text to stand out
    }
  If h_icon !=FAIL
    {
  	Gui_Icon_Number := DllCall("ImageList_ReplaceIcon", UInt, ImageListID1, Int, -1, UInt, h_icon)	; Add the HICON directly to the icon list
    WinGetTitle, Title%Window_Found_Count%, ahk_id %wid% ; store titles to a list
    }
Return



2GuiClose:
2GuiEscape:
  Gui, 2: Destroy
  Gui, 1: Default
Return



3GuiClose:
3GuiEscape:
  Gui, 3: Destroy
  Gui, 1: Default
Return
    
    
    
Load_Settings_From_Ini:
  ; Hotkeys
    IniRead, Alt_Hotkey, Alt_Tab_Settings.ini, Hotkeys, Alt_Hotkey, !
    IniRead, Tab_Hotkey, Alt_Tab_Settings.ini, Hotkeys, Tab_Hotkey, Tab
    IniRead, Shift_Tab_Hotkey, Alt_Tab_Settings.ini, Hotkeys, Shift_Tab_Hotkey, +Tab
    IniRead, Esc_Hotkey, Alt_Tab_Settings.ini, Hotkeys, Esc_Hotkey, Esc
    IniRead, Single_Key_Show_Alt_Tab, Alt_Tab_Settings.ini, Hotkeys, Single_Key_Show_Alt_Tab, %Blank%
      If Single_Key_Show_Alt_Tab =ERROR ; set to blank value
        Single_Key_Show_Alt_Tab =
    IniRead, Single_Key_Hide_Alt_Tab, Alt_Tab_Settings.ini, Hotkeys, Single_Key_Hide_Alt_Tab, Enter

  ; Sort_Order
    IniRead, Sort_Order_Column, Alt_Tab_Settings.ini, Sort_Order, Sort_Order_Column, 2 ; initial column to sort (2 is a hidden column)
    IniRead, Sort_Order_Direction, Alt_Tab_Settings.ini, Sort_Order, Sort_Order_Direction, Sort ; initial sort direction

  ; Custom_Groups + Group_Hotkey - remember lists of windows
    IniRead, Custom_Group_List, Alt_Tab_Settings.ini, Custom_Groups, Custom_Group_List,%Blank%
      If Custom_Group_List =ERROR ; set to blank value
        Custom_Group_List =
    IniRead, Exclude_Not_In_List, Alt_Tab_Settings.ini, Custom_Groups, Exclude_Not_In_List,%Blank%
        If Exclude_Not_In_List =ERROR ; set to blank value
          Exclude_Not_In_List =
    IniRead, Custom_Group_Active, Alt_Tab_Settings.ini, Custom_Groups, Custom_Group_Active,%Blank%
        If Custom_Group_Active =ERROR ; set to blank value
          Custom_Group_Active =
    Loop, Parse, Custom_Group_List,|
      {
      IniRead, %A_LoopField%, Alt_Tab_Settings.ini, Custom_Groups, %A_LoopField%,%Blank%
        If %A_LoopField% =ERROR ; set to blank value
          %A_LoopField% =
      IniRead, %A_LoopField%_Group_Hotkey, Alt_Tab_Settings.ini, Group_Hotkey, %A_LoopField%_Group_Hotkey,%Blank%
        If %A_LoopField%_Group_Hotkey =ERROR ; set to blank value
          %A_LoopField%_Group_Hotkey =
       Else If %A_LoopField%_Group_Hotkey !=
         Hotkey, % %A_LoopField%_Group_Hotkey, Group_Hotkey, On
      }
Return


Save_Settings_To_Ini:
  If Save_Settings =0
    Return

  ; Hotkeys
    IniWrite, %Alt_Hotkey%, Alt_Tab_Settings.ini, Hotkeys, Alt_Hotkey
    IniWrite, %Tab_Hotkey%, Alt_Tab_Settings.ini, Hotkeys, Tab_Hotkey
    IniWrite, %Shift_Tab_Hotkey%, Alt_Tab_Settings.ini, Hotkeys, Shift_Tab_Hotkey
    IniWrite, %Esc_Hotkey%, Alt_Tab_Settings.ini, Hotkeys, Esc_Hotkey
    IniWrite, %Single_Key_Show_Alt_Tab%, Alt_Tab_Settings.ini, Hotkeys, Single_Key_Show_Alt_Tab
    IniWrite, %Single_Key_Hide_Alt_Tab%, Alt_Tab_Settings.ini, Hotkeys, Single_Key_Hide_Alt_Tab
    
  ; Sort_Order
    IniWrite, %Sort_Order_Column%, Alt_Tab_Settings.ini, Sort_Order, Sort_Order_Column 
    IniWrite, %Sort_Order_Direction%, Alt_Tab_Settings.ini, Sort_Order, Sort_Order_Direction 

  ; Custom_Groups + Group_Hotkey - remember lists of windows
    IniWrite, %Custom_Group_List%, Alt_Tab_Settings.ini, Custom_Groups, Custom_Group_List
    IniWrite, %Exclude_Not_In_List%, Alt_Tab_Settings.ini, Custom_Groups, Exclude_Not_In_List
    IniWrite, %Custom_Group_Active%, Alt_Tab_Settings.ini, Custom_Groups, Custom_Group_Active
    Loop, Parse, Custom_Group_List,|
        {
        IniWrite, % %A_LoopField%, Alt_Tab_Settings.ini, Custom_Groups, %A_LoopField%
        IniWrite, % %A_LoopField%_Group_Hotkey, Alt_Tab_Settings.ini, Group_Hotkey, %A_LoopField%_Group_Hotkey
        }
Return



;========================================================================================================


Replace_Modifier_Symbol( Variable_Name , New_Variable_Name )
{
  ; replace 1st modifier symbol in Alt_Hotkey,etc with its equivalent text (for hotkey up event compatability)
  Global
  %New_Variable_Name% :=%Variable_Name%
  StringReplace, %New_Variable_Name%, %New_Variable_Name%,#,LWin
  StringReplace, %New_Variable_Name%, %New_Variable_Name%,!,Alt
  StringReplace, %New_Variable_Name%, %New_Variable_Name%,^,Control
  StringReplace, %New_Variable_Name%, %New_Variable_Name%,+,Shift
  StringReplace, %New_Variable_Name%, %New_Variable_Name%,%A_Space%&%A_Space%, ; remove & for hotkeys like XButton1
}



ListView_Resize_Vertically(Gui_ID) ; Automatically resize listview vertically
{
  Global Window_Found_Count, lv_h_win_2000_adj
  SendMessage, 0x1000+31, 0, 0, SysListView321, ahk_id %Gui_ID% ; LVM_GETHEADER
  WinGetPos,,,, lv_header_h, ahk_id %ErrorLevel%
  VarSetCapacity( rect, 16, 0 )
  SendMessage, 0x1000+14, 0, &rect, SysListView321, ahk_id %Gui_ID% ; LVM_GETITEMRECT ; LVIR_BOUNDS
  y1 := 0
  y2 := 0
  Loop, 4
    {
    y1 += *( &rect + 3 + A_Index )
    y2 += *( &rect + 11 + A_Index )
    }
  lv_row_h := y2 - y1
  lv_h := 4 + lv_header_h + ( lv_row_h * Window_Found_Count ) + lv_h_win_2000_adj
  GuiControl, Move, SysListView321, h%lv_h%
}



GetCPA_file_name( p_hw_target ) ; retrives Control Panel applet icon
{
   WinGet, pid_target, PID, ahk_id %p_hw_target%

   hp_target := DllCall( "OpenProcess", "uint", 0x18, "int", false, "uint", pid_target )

   hm_kernel32 := DllCall( "GetModuleHandle", "str", "kernel32.dll" )

   pGetCommandLineA := DllCall( "GetProcAddress", "uint", hm_kernel32, "str", "GetCommandLineA" )

   buffer_size = 6
   VarSetCapacity( buffer, buffer_size )

   DllCall( "ReadProcessMemory", "uint", hp_target, "uint", pGetCommandLineA, "uint", &buffer, "uint", buffer_size, "uint", 0 )

   loop, 4
      ppCommandLine += ( ( *( &buffer+A_Index ) ) << ( 8*( A_Index-1 ) ) )

   buffer_size = 4
   VarSetCapacity( buffer, buffer_size, 0 )

   DllCall( "ReadProcessMemory", "uint", hp_target, "uint", ppCommandLine, "uint", &buffer, "uint", buffer_size, "uint", 0 )

   loop, 4
      pCommandLine += ( ( *( &buffer+A_Index-1 ) ) << ( 8*( A_Index-1 ) ) )

   buffer_size = 260
   VarSetCapacity( buffer, buffer_size, 1 )

   DllCall( "ReadProcessMemory", "uint", hp_target, "uint", pCommandLine, "uint", &buffer, "uint", buffer_size, "uint", 0 )

   DllCall( "CloseHandle", "uint", hp_target )

  IfInString, buffer, desk.cpl ; exception to usual string format
    return, "C:\WINDOWS\system32\desk.cpl"

   ix_b := InStr( buffer, "Control_RunDLL" )+16
   ix_e := InStr( buffer, ".cpl", false, ix_b )+3
   StringMid, CPA_file_name, buffer, ix_b, ix_e-ix_b+1

   if ( ix_e )
      return, CPA_file_name
   else
      return, false
}



;========================================================================================================

WM_ACTIVATE(wParam) 
{
  Global
  If ( wParam =0 and A_Gui =1 and Display_List_Shown =1) ; i.e. don't trigger when submitting gui
    {
    Alt_Esc_No_Re_Activate =1
    Gosub, Alt_Esc ; hides alt-tab gui    
    Alt_Esc_No_Re_Activate =
    }
} 



OnExit_Script_Closing:
  Gosub, Save_Settings_To_Ini
  Gui_Un_Dock_Windows_All_No_Alt_Esc = 1
  Gosub, Gui_Un_Dock_Windows_All
  ExitApp
Return



;========================================================================================================

Delete_Ini_File_Settings:
  FileDelete, Alt_Tab_Settings.ini
  Save_Settings =0 ; don't save settings on program exit
  Reload
Return



HELP_and_LATEST_VERSION_CHANGES:
  Gosub, Alt_Esc ; hides alt-tab gui
  Gui, 99: Font, s9, Courier New
  Gui, 99: Add, ListView, r25 w900 -Hdr, Text
  Gui, 99: Default
  If A_ThisMenuItem =Help
    {
    Loop, Parse, HELP,`n
      LV_Add("", A_LoopField)
    }
  If A_ThisMenuItem =Latest Changes
    {
    Loop, Parse, LATEST_VERSION_CHANGES,`n
      LV_Add("", A_LoopField)
    }
  LV_ModifyCol(1, 870)
  Gui, 99: Show,, %A_ThisMenuItem%
Return

99GuiClose:
99GuiEscape:
  LV_Delete()
  Gui, 99: Destroy
Return


/*

============================================================================================================================

 NOTES:

add items to tray menu

when showing context menu, start a settimer to catch alt+esc key or similar?

use settimer to more accurately check time over a docked window?

maybe duplicate entries:     WinGetTitle, Title%Window_Found_Count% ....

make a gosub for auto resizing listviews

minimise all instances, maximise all instances, hide window/hide all instances (need to write hidden to a list)
min/max/restore all windows

find out time a window was created?

*/
