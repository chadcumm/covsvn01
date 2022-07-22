/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       06/10/2020
  Solution:           
  Source file name:   cov_him_auth_batch_doc.prg
  Object name:        cov_him_auth_batch_doc
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   06/10/2020  Chad Cummings			Initial Release
******************************************************************************/
drop program cov_him_auth_batch_doc go
create program cov_him_auth_batch_doc

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
		1 cur_cnt			= i4
		1 log_message		= vc
		1 qual[*]
		 2 event_id 		= f8
		1 batch_size		= i2
		1 current_cnt		= i2
		1 batch_cnt			= i2
		1 batch_qual[*]
		 2 event_cnt		= i2
		 2 event_qual[*]
		  3 event_id		= f8
	)
endif

set t_rec->batch_size = 30

if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->filename = value(parameter(1,0))
endif

if (t_rec->filename = " ")
	set t_rec->log_message = "Missing Filename parameter"
	go to exit_script
else
	if (findfile(t_rec->filename) = 0)
		set t_rec->log_message = "File not found on backend"
		go to exit_script
	endif
endif


set frec->file_name = t_rec->filename
set frec->file_buf = "r" ;file_buf values are case sensitive so lowercase r is used 
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
			if (cnvtreal(substring(1,pos,trim(frec->file_buf))) > 0.0)
				set t_rec->cnt = (t_rec->cnt + 1)
				set stat = alterlist(t_rec->qual,t_rec->cnt)
				set t_rec->qual[t_rec->cnt].event_id = cnvtreal(substring(1,pos,trim(frec->file_buf)))
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

set t_rec->cur_cnt = 0

while (t_rec->cur_cnt <= t_rec->cnt)
	while (t_rec->current_cnt <= t_rec->batch_size)
		set t_rec->cur_cnt = (t_rec->cur_cnt + 1)
		if (t_rec->cur_cnt <= t_rec->cnt)
			if (t_rec->current_cnt = 0)
				set t_rec->batch_cnt = (t_rec->batch_cnt + 1)
				set stat = alterlist(t_rec->batch_qual,t_rec->batch_cnt)
			endif
			set t_rec->batch_qual[t_rec->batch_cnt].event_cnt = (t_rec->batch_qual[t_rec->batch_cnt].event_cnt + 1)
			set stat = alterlist(t_rec->batch_qual[t_rec->batch_cnt].event_qual,t_rec->batch_qual[t_rec->batch_cnt].event_cnt)
			set t_rec->batch_qual[t_rec->batch_cnt].event_qual[t_rec->batch_qual[t_rec->batch_cnt].event_cnt].event_id 
				= t_rec->qual[t_rec->cur_cnt].event_id
			set t_rec->current_cnt = (t_rec->current_cnt + 1)
			if (t_rec->current_cnt > t_rec->batch_size)
				set t_rec->current_cnt = 0
			endif
		endif
	endwhile
endwhile


#exit_script

call echo(build2("Exiting"))
call echorecord(t_rec)
end 
go
