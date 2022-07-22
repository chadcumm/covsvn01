
drop program cov_mm_item_inactivate go
create program cov_mm_item_inactivate

call echo(build2("Initializing"))

if (not validate(frec))
    record frec
    (
    1 file_desc         = i4
    1 file_offset       = i4
    1 file_dir          = i4
    1 file_name         = vc
    1 file_buf          = vc
    ) with protect
endif

if (not validate(t_rec))
	record t_rec
	(
	1 filename			= vc
	1 cnt				= i4
	1 qual[*]
	 2 person_id 		= f8
	)
endif

set t_rec->filename = "ccluserdir:cov_mm_item_inactivate.csv"
;open a file named ccl_test.dat with read access
set frec->file_name = t_rec->filename
set frec->file_buf = "r" /* file_buf values are case sensitive so lowercase r is used */
set stat = cclio("OPEN",frec)
;allocate buffer for desired read size
set frec->file_buf = notrim(fillstring(300," "))
if (frec->file_desc != 0)
	set stat = 1
	while (stat > 0)
		;read the file one record at a time
		set stat = cclio("GETS",frec)
		if (stat > 0)
			set pos = findstring(char(0),frec->file_buf)
			;call echo(build2("pos=",pos))
			set pos = evaluate(pos,0,size(frec->file_buf),pos)
			;call echo(build2("pos=",pos))
			;call echo(substring(1,pos,trim(frec->file_buf)))
			if (substring(1,pos,trim(frec->file_buf))) > " ")
				set t_rec->cnt = (t_rec->cnt + 1)
				set stat = alterlist(t_rec->qual,t_rec->cnt)
				set t_rec->qual[t_rec->cnt].person_id = cnvtreal(substring(1,pos,trim(frec->file_buf)))
            else
				call echo(build2("buf=",frec->file_buf,"<---"))
			endif
		endif
       endwhile
        ;close the file
       set stat = cclio("close",frec)
endif

if (t_rec->cnt = 0)
 go to exit_script
endif


#exit_script
call echo(build2("Exiting"))
call echorecord(t_rec)
end 
go