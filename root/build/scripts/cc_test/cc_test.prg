drop program cc_test go
Create program cc_Test

Set cnt = 10

For (i=1 to cnt)
	call echo(build2("i=",i))
	call pause(3)
endfor

End go
