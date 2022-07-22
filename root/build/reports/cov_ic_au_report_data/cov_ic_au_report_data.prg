/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		03/30/2020
	Solution:			Perioperative
	Source file name:	cov_ic_au_report_data.prg
	Object name:		cov_ic_au_report_data
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	03/30/2020  Chad Cummings			Initial Release
******************************************************************************/

drop program cov_ic_au_report_data:dba go
create program cov_ic_au_report_data:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date and Time" = "SYSDATE"
	, "End Date and Time" = "SYSDATE"
	, "Facility" = 0 

with OUTDEV, START_DT_TM, END_DT_TM, FACILITY


call echo(build("loading script:",curprog))
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
)

;call addEmailLog("chad.cummings@covhlth.com")

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))

select into $OUTDEV
	 l.facility_cd
	,l.nurse_unit_cd
	,p.name_full_formatted
	,ea.alias
	,l.*
from
	 lh_cnt_ic_med_admin_event l
	,clinical_event ce
	,orders o
	,encounter e
	,person p
	,encntr_alias ea
plan o
	where o.orig_order_dt_tm between cnvtdatetime($START_DT_TM) and cnvtdatetime($END_DT_TM)
	and   o.catalog_type_cd = value(uar_get_code_by("MEANING",6000,"PHARMACY"))
join l
	where l.order_id = o.order_id
	and   l.facility_cd = $FACILITY
join ce
	where ce.event_id = l.event_id
	and   ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
join e
	where e.encntr_id = ce.encntr_id
join p
	where p.person_id = e.person_id
join ea
	where ea.encntr_id = e.encntr_id
	and   ea.active_ind = 1
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
 	
with format(date,"dd-mmm-yyyy hh:mm:ss;;q"),uar_code(d,1),format,separator=" "


call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call exitScript(null)
call echorecord(t_rec)
call echorecord(code_values)
call echorecord(program_log)


end
go
