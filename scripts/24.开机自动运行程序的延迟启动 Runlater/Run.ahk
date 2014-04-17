folder = F:\Run

Loop, %folder%\*.lnk
{
runwait %folder%\%A_LoopFileName%
}

ExitApp