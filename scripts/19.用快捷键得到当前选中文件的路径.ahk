^#c::
; null= 
;多谢 helfee 的提醒，删除线部分是多余的。
send ^c
sleep,200
clipboard=%clipboard% ;%null%
        ; 这句还是废话一下：windows 复制的时候，剪贴板保存的是“路径”。只是路径不是字符串，只要转换成字符串就可以粘贴出来了。
tooltip,%clipboard%
sleep,500
tooltip,
return