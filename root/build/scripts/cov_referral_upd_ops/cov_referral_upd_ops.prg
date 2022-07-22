/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		
	Solution:			
	Source file name:	cov_referral_upd_ops.prg
	Object name:		cov_referral_upd_ops
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	08/12/2021  Chad Cummings			Initial Release
******************************************************************************/

drop program cov_referral_upd_ops:dba go
create program cov_referral_upd_ops:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Number of Days to Look Back:" = 0 

with OUTDEV, DAYS_BACK


call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

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

set reply->status_data.status = "F"

call set_codevalues(null)
call check_ops(null)

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))

free set t_rec
record t_rec
(
	1 prompts
	 2 days					= i4
	1 cons
	 2 days					= i4
	 2 beg_dt_tm			= dq8
	 2 run_dt_tm			= dq8
	 2 temp_filename		= vc
	 2 temp_directory		= vc
	1 ascii
	 2 quote				= vc
	 2 comma				= vc
	 2 line_feed			= vc
	1 var
	 2 line					= vc
	1 cnt					= i4
	1 qual[*] 
	 2 referral_id			= f8
	 2 person_id			= f8
	 2 create_dt_tm			= f8
	 2 referral_status_cd 	= f8
	 2 order_id				= f8
	 2 order_mnemonic		= vc
	 2 mrn					= vc
)	 

record file_temp (
   1 file_desc = i4
   1 file_name = vc
   1 file_buf = vc
   1 file_dir = i4
   1 file_offset = i4
 ) with protect

;call addEmailLog("chad.cummings@covhlth.com")

set t_rec->prompts.days	= cnvtint($DAYS_BACK)

if (t_rec->prompts.days <= 0)
	set t_rec->cons.days = 1
else
	set t_rec->cons.days = t_rec->prompts.days
endif

set t_rec->ascii.comma			= char (44)
set t_rec->ascii.line_feed		= concat(char (13),char (10))
set t_rec->ascii.quote			= char (34)

set t_rec->cons.run_dt_tm = cnvtdatetime(curdate,curtime3)
set t_rec->cons.temp_directory = program_log->files.file_path
set t_rec->cons.temp_filename = concat(trim(cnvtlower(curprog)),"_",trim(format(t_rec->cons.run_dt_tm,"yyyymmdd_hhmmss;;d")),".csv")
set t_rec->cons.beg_dt_tm = datetimefind(	 ;find the date and time
											 cnvtlookbehind(	;look back for the date and time
																 build(trim(cnvtstring(t_rec->cons.days)),",D")	;number of days
																,cnvtdatetime(curdate,curtime3)					;from right now
														   )
										  	, 'D', 'B', 'B'	;beginning of the day and beginning time
										 )

call writeLog(build2(cnvtrectojson(t_rec)))
call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

set reply->status_data.status = "Z"

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Referrals **********************************"))

select into "nl:"
from
	referral r
plan r
	where r.referral_status_cd in(value(uar_get_code_by("MEANING",4002978,"COMPLETED")))
	and   r.create_dt_tm <= cnvtdatetime(t_rec->cons.beg_dt_tm)
	and	  r.active_ind = 1
	;and   r.referral_id in(4041913,91231,2039305)
order by
	r.referral_id
head report
	call writeLog(build2("->entering referral information gathering"))
head r.referral_id
	call writeLog(build2("-->r.referral_id=",r.referral_id))
	call writeLog(build2("-->r.person_id=",r.person_id))
	call writeLog(build2("-->r.create_dt_tm=",format(r.create_dt_tm,";;q")))
	t_rec->cnt = (t_rec->cnt + 1)
	stat = alterlist(t_rec->qual,t_rec->cnt)
	t_rec->qual[t_rec->cnt].referral_id				= r.referral_id
	t_rec->qual[t_rec->cnt].person_id				= r.person_id
	t_rec->qual[t_rec->cnt].create_dt_tm			= r.create_dt_tm
	t_rec->qual[t_rec->cnt].order_id				= r.order_id
	t_rec->qual[t_rec->cnt].referral_status_cd		= r.referral_status_cd
foot r.referral_id
	call writeLog(build2("-->t_rec->cnt=",t_rec->cnt))
foot report
	call writeLog(build2("<-leaving referral information gathering"))
with nocounter,nullreport

call writeLog(build2("* END   Finding Referrals **********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Creating Backend File ******************************"))

set file_temp->file_name 	= concat(t_rec->cons.temp_directory,t_rec->cons.temp_filename)
set file_temp->file_buf 	= "w"
set stat = cclio("OPEN",file_temp)

for (i = 1 to t_rec->cnt)
	set t_rec->var.line = ""
	set t_rec->var.line = build2(
										 t_rec->qual[i].referral_id
										,t_rec->ascii.comma
								)
   set file_temp->file_buf = concat(trim(t_rec->var.line),char(13),char(10))
   set stat = cclio ("WRITE",file_temp)
endfor

set stat = cclio ("CLOSE",file_temp)

call writeLog(build2("* END   Creating Backend File ******************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding MRN ****************************************"))

call get_mrn(null)

call writeLog(build2("* END   Finding MRN ****************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Running rfm_upd_referral_to_stat_18011 *************"))


execute rfm_upd_referral_to_stat_18011 
										 "NOFORMS"
										,concat(t_rec->cons.temp_directory,t_rec->cons.temp_filename)
										,"CLOSED"

call writeLog(build2("* END   Running rfm_upd_referral_to_stat_18011 *************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("t_rec->cons.temp_directory=",t_rec->cons.temp_directory))
call writeLog(build2("t_rec->cons.temp_filename=",t_rec->cons.temp_filename))

call AddAttachment(t_rec->cons.temp_directory,t_rec->cons.temp_filename)

#exit_script

set reply->status_data.status = "S"

call exitScript(null)
call echorecord(code_values)
call echorecord(program_log)
call echorecord(t_rec)

end
go
