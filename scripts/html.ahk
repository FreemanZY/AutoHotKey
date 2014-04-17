xunhuan=95
num=92
Loop, 100
{
    FileAppend, <a href="watch_img/%xunhuan%.jpg">NO.%num%<img border="0" src="watch_img/small/%xunhuan%_small.jpg" xthumbnail-orig-image="watch_img/%xunhuan%.jpg"></a>`n, d:\Test.txt
	xunhuan:=xunhuan+1
	num:=num+1
}