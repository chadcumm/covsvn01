/*****************************************************************************
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   bc_common_log.prg
  Object name:        bc_common_log
  Request #:

  Program purpose:

  Executing from:     

  Special Notes:       

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   10/01/2019  Chad Cummings			Initial Release
******************************************************************************/
drop program pfmt_bc_common_msgview:dba go
create program pfmt_bc_common_msgview:dba

call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set debug_ind = 2	;0 = no debug, 1=basic debug with echo, 2=msgview debug

%i cust_script:bc_common_routines.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))

if (not(validate(reply,0)))
record  reply
(
	1 text = vc
	1 status_data
	 2 status = c1
	 2 subeventstatus[1]
	  3 operationname = c15
	  3 operationstatus = c1
	  3 targetobjectname = c15
	  3 targetobjectvalue = c100
)
endif

free set t_rec
record t_rec
(
	1 cnt			= i4
)

set bc_common->log_level = 2
;call bc_custom_code_set(0)
;call bc_check_validation(0)


call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))

if (validate(requestin) = 1)
	if (program_log->produce_log = 0)
		call writeLog(build2("-->writing requestin to ",program_log->files.filename_audit))
		call echojson(requestin,program_log->files.filename_audit,1)
	endif
	call echorecord(requestin)
endif

if (validate(request) = 1)
	if (program_log->produce_log = 0)
		call writeLog(build2("-->writing request to ",program_log->files.filename_audit))
		call echojson(request,program_log->files.filename_audit,1)
	endif
	call echorecord(request)
endif

if (validate(t_rec) = 1)
	if (program_log->produce_log = 0)
		call writeLog(build2("-->writing t_rec to ",program_log->files.filename_audit))
		call echojson(t_rec,program_log->files.filename_audit,1)
	endif
	call echorecord(t_rec)
endif

if (validate(reqinfo) = 1)
	if (program_log->produce_log = 0)
		call writeLog(build2("-->writing reqinfo to ",program_log->files.filename_audit))
		call echojson(reqinfo,program_log->files.filename_audit,1)
	endif
	call echorecord(reqinfo)
endif

call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call exitScript(null)
call echorecord(t_rec)
call echorecord(program_log)

end 
go
