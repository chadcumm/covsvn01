/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		   	03/01/2019
	Solution:			Ambulatory
	Source file name:	 	cov_tog_prov_doc_audit.prg
	Object name:		   	cov_tog_prov_doc_audit
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	03/01/2019  Chad Cummings
******************************************************************************/

drop program cov_tog_prov_doc_audit:dba go
create program cov_tog_prov_doc_audit:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Clinic" = 0.0
	, "Physician" = 0
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE" 

with OUTDEV, loc_clinic, loc_phys, start_datetime, end_datetime


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
	1 start_dt_tm		= dq8
	1 end_dt_tm			= dq8
	1 app_loc_cnt		= i2
	1 app_loc[*]
	 2 app_location_cd 	= f8
	 2 description 		= vc
	1 res_cnt			= i2
	1 res_list[*]
	 2 resource_cd		= f8
	 2 prsnl_id			= f8
	 2 provider_name	= vc
	 2 resource_name	= vc
	1 cnt 				= i2
	1 qual[*]
	 2 sch_event_id		= f8
	 2 encntr_id		= f8
	 2 person_id		= f8
	 2 fin				= vc
	 2 patient_name		= vc
	 
)

call addEmailLog("chad.cummings@covhlth.com")

set t_rec->start_dt_tm 		= cnvtdatetime($start_datetime)
set t_rec->end_dt_tm		= cnvtdatetime($end_datetime)

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("* START Adding Appointment Location   **********************"))

select into "nl:"
	description = uar_get_code_display(sl.location_cd)
from
	sch_location sl
plan sl
	where sl.location_cd 			= $loc_clinic
	and   sl.active_ind 			= 1
	and   sl.beg_effective_dt_tm	<= cnvtdatetime(curdate,curtime3)
	and   sl.end_effective_dt_tm	>= cnvtdatetime(curdate,curtime3)
order by
	 description
	,sl.location_cd
head report
	t_rec->app_loc_cnt = 0
head sl.location_cd	
	t_rec->app_loc_cnt = (t_rec->app_loc_cnt + 1)
	stat = alterlist(t_rec->app_loc,t_rec->app_loc_cnt)
	t_rec->app_loc[t_rec->app_loc_cnt].app_location_cd 		= sl.location_cd
	t_rec->app_loc[t_rec->app_loc_cnt].description			= uar_get_code_display(sl.location_cd)
with nocounter

call writeLog(build2("* END   Adding Appointment Location   **********************"))
call writeLog(build2("* START Adding Appointment Resource   **********************"))

select into "nl:"
from
	sch_resource sr
	,prsnl p
plan sr
	where sr.resource_cd 			= $loc_phys
	and   sr.active_ind 			= 1
	and   sr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
join p
	where p.person_id 				= sr.person_id
order by
	 sr.description
	,sr.resource_cd
head report
	t_rec->res_cnt = 0
head sr.resource_cd
	t_rec->res_cnt = (t_rec->res_cnt + 1)
	stat = alterlist(t_rec->res_list,t_rec->res_cnt)
	t_rec->res_list[t_rec->res_cnt].resource_cd			= sr.resource_cd
	t_rec->res_list[t_rec->res_cnt].prsnl_id 			= sr.person_id
	t_rec->res_list[t_rec->res_cnt].provider_name		= p.name_full_formatted
	t_rec->res_list[t_rec->res_cnt].resource_name		= sr.description
with nocounter

call writeLog(build2("* END   Adding Appointment Resource   **********************"))
call writeLog(build2("* START Custom   ************************************"))
call writeLog(build2("* END   Custom   ************************************"))
call writeLog(build2("* START Custom   ************************************"))
call writeLog(build2("* END   Custom   ************************************"))
call writeLog(build2("* START Custom   ************************************"))
call writeLog(build2("* END   Custom   ************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   ************************************"))
call writeLog(build2("* END   Custom   ************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call exitScript(null)
call echorecord(t_rec)
call echorecord(code_values)
call echorecord(program_log)


end
go
