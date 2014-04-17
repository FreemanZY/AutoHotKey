~LAlt::
errorlevel = 5
Keywait, LAlt, , t0.5
if errorlevel = 1
return
else
tooltip,%errorlevel%
return