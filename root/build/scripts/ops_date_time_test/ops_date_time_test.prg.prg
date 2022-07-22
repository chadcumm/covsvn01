drop program ops_date_time_test go
create program ops_date_time_test
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to. 
with OUTDEV
SELECT INTO $OUTDEV
	e.encntr_id
	, reg_dt_tm = format(e.reg_dt_tm,  "mm/dd/yyyy hh:mm;;d")
	, disch_dt_tm = format(e.disch_dt_tm,  "mm/dd/yyyy hh:mm;;d")
	, curtimezone
FROM
	encounter   e
where
	e.encntr_id > 0
WITH MAXREC = 10, MAXCOL = 2000, nocounter, format, formfeed=stream, SEPARATOR='|'
if (validate(request))
	call echojson(request,"ops_date_time_test.out")
endif
end 
go
