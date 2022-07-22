drop program cov_log_ccl go
create program cov_log_ccl

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to. 

with OUTDEV

call echo(build("loading script:",curprog))

set modify maxvarlen 268435456 ;increases max file size

set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

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

call set_codevalues(null)
call check_ops(null)

free set t_rec
record t_rec
(
	1 cnt			= i4
	1 filename_a    = vc
	1 filename_a_f	= vc
	1 filename_b    = vc
	1 filename_c = vc
	1 filename_d = vc
	1 filename_e = vc
	1 audit_cnt = i4
	1 audit[*]
	 2 section = vc
	 2 title = vc
	 2 alias = vc
	 2 misc = vc
)


call addEmailLog("chad.cummings@covhlth.com")

set t_rec->filename_a = concat(trim(cnvtlower(curprog)),"_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
set t_rec->filename_a_f = concat("cclscratch:",t_rec->filename_a)

if (validate(request))
	call echojson(request, t_rec->filename_a_f , 1) 
endif

if (validate(reqinfo))
	call echojson(reqinfo,t_rec->filename_a_f, 1)
endif

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   ************************************"))

call addAttachment(program_log->files.file_path, t_rec->filename_a) 

call writeLog(build2("* END   Custom   ************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
call echorecord(program_log)



end
go
