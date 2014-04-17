FileSelectFolder, Folder
FileList =  ; 初始化为空。
Loop, %Folder%\*.jpg, , 1  ; 在子文件夹中搜索。
FileList = %FileList%%A_LoopFileName%`n
Sort, FileList, StringSort
StringSort(a1, a2)
{
    if(StrLen(a1)>strlen(a2))

	return a1 > a2 ? 1 : a1 < a2 ? -1 : 0
}

Loop, parse, FileList, `n
{
    if A_LoopField =  ; 忽略在列表底部的空白。
        continue
    FileAppend, <img src="%A_LoopField%" />`n, d:\Test.txt
}