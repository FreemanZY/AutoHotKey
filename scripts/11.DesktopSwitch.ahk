
; DesktopSwitch
;
; AutoHotkey Version: 1.0.40.00 (that's at least the version I'm using)
; Language:       English
; Platform:       Win9x/NT/XP
; Author:         Christian Sch?c_schueler@gmx.at>
; last changes:   22. Nov. 2005
;
; Script Function:
;
; A small tool for switching between multiple virtual desktops.
; Use Alt-<desktop index> (e.g. Alt-2) to switch between desktops and
; Alt-0 to quit the script, showing all windows on all virtual desktops
; at once. Currently, 4 desktops are supported, because more will start
; to confuse me...
;
; Version history:
;
; v1.11, 22. Nov. 2005
; Fixed bug: windows are now corrrectly activated after switching/sending
;
; v1.1, 05. Nov. 2005
; Added feature: pressing Ctrl/Alt-<index> sends the active window to the desktop <index>.
;
; v1.0, 04. Nov. 2005
; It works!
; Switching can be done using Alt-<desktop index>, e.g. Alt-1. Pressing
; Alt-0 will exit the script and show all windows from all virtual desktops
; at once.


; ***** initialization *****

SetBatchLines, -1   ; maximize script speed!
SetWinDelay, -1
OnExit, CleanUp      ; clean up in case of error (otherwise some windows will get lost)

numDesktops := 4   ; maximum number of desktops
curDesktop := 1      ; index number of current desktop

WinGet, windows1, List   ; get list of all currently visible windows

; Transparent Banner GUI
Gui, -Caption +ToolWindow +LastFound +AlwaysOnTop
Gui, Add, Picture, x0 y0, C:\Program Files\Autohotkey\Scripts\banner.png
Gui, Add, Text, x15 y5 w70 +BackgroundTrans vString

; ***** hotkeys *****

#MaxThreadsPerHotkey 6
!1::SwitchToDesktop(1)
!2::SwitchToDesktop(2)
!3::SwitchToDesktop(3)
!4::SwitchToDesktop(4)
#MaxThreadsPerHotkey 1

^!1::SendActiveToDesktop(1)
^!2::SendActiveToDesktop(2)
^!3::SendActiveToDesktop(3)
^!4::SendActiveToDesktop(4)

!0::ExitApp


; ***** functions *****

; switch to the desktop with the given index number
SwitchToDesktop(newDesktop)
{
   global

   if (curDesktop <> newDesktop)
   {
      GetCurrentWindows(curDesktop)

      ;WinGet, windows%curDesktop%, List,,, Program Manager   ; get list of all visible windows

      ShowHideWindows(curDesktop, false)
      ShowHideWindows(newDesktop, true)

      curDesktop := newDesktop

      Send, {ALT DOWN}{TAB}{ALT UP}   ; activate the right window
   }
   
   WinClose, ahk_class SysShadow
   ShowBanner("Desktop: " newDesktop)

   return
}

; sends the given window from the current desktop to the given desktop
SendToDesktop(windowID, newDesktop)
{
   global
   RemoveWindowID(curDesktop, windowID)

   ; add window to destination desktop
   windows%newDesktop% += 1
   i := windows%newDesktop%

   windows%newDesktop%%i% := windowID
   
   WinHide, ahk_id %windowID%

   Send, {ALT DOWN}{TAB}{ALT UP}   ; activate the right window
}

; sends the currently active window to the given desktop
SendActiveToDesktop(newDesktop)
{
   WinGet, id, ID, A
   SendToDesktop(id, newDesktop)
}

; removes the given window id from the desktop <desktopIdx>
RemoveWindowID(desktopIdx, ID)
{
   global   
   Loop, % windows%desktopIdx%
   {
      if (windows%desktopIdx%%A_Index% = ID)
      {
         RemoveWindowID_byIndex(desktopIdx, A_Index)
         Break
      }
   }
}

; this removes the window id at index <ID_idx> from desktop number <desktopIdx>
RemoveWindowID_byIndex(desktopIdx, ID_idx)
{
   global
   Loop, % windows%desktopIdx% - ID_idx
   {
      idx1 := % A_Index + ID_idx - 1
      idx2 := % A_Index + ID_idx
      windows%desktopIdx%%idx1% := windows%desktopIdx%%idx2%
   }
   windows%desktopIdx% -= 1
}

; this builds a list of all currently visible windows in stores it in desktop <index>
GetCurrentWindows(index)
{
   global
   WinGet, windows%index%, List,,, Program Manager      ; get list of all visible windows

   ; now remove task bar "window" (is there a simpler way?)
   Loop, % windows%index%
   {
      id := % windows%index%%A_Index%

      WinGetClass, windowClass, ahk_id %id%
      if windowClass = Shell_TrayWnd      ; remove task bar window id
      {
         RemoveWindowID_byIndex(index, A_Index)
         Break
      }
   }
}

; if show=true then shows windows of desktop %index%, otherwise hides them
ShowHideWindows(index, show)
{
   global

   Loop, % windows%index%
   {
      id := % windows%index%%A_Index%

      if show
         WinShow, ahk_id %id%
      else
         WinHide, ahk_id %id%
   }
}

ShowBanner(Text)
{
    global
    Trans := 255
    
    GuiControl, Text, String, % Text
    Gui, Show, x895 y677 h24 w92 NoActivate, MyTransparentBanner
    WinSet, Transparent, %Trans%, MyTransparentBanner
    Sleep 500
    
    Loop
    {
        if(Trans <= 0)
        {
            Trans := 0
            WinSet, Transparent, %Trans%, MyTransparentBanner
            break
        }
                
        WinSet, Transparent, %Trans%, MyTransparentBanner
        Trans := Trans - 5
        Sleep, 10
    }
    
    return
}

; show all windows from all desktops on exit
CleanUp:
Loop, %numDesktops%
   ShowHideWindows(A_Index, true)
ExitApp
