/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           Ambulatory
  Source file name:   cov_amb_substance_rpt.prg
  Object name:        cov_amb_substance_rpt
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   03/24/2019  Chad Cummings
******************************************************************************/
drop program cov_amb_substance_rpt:dba go
create program cov_amb_substance_rpt:dba


prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Facility:" = ""
	, "Location(s)" = "" 

with OUTDEV, FACILITY, LOCATION


call echo(build("loading script:",curprog))
set nologvar = 1	;do not create log = 1		, create log = 0
set noaudvar = 1	;do not create audit = 1	, create audit = 0
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
  1 facility_cnt              	= i2
  1 facility_qual[*]
   2 facility_disp          	= vc
	1 order_cnt					= i2
  1 order_qual[*]
   2 order_id                 = f8

)

call addEmailLog("chad.cummings@covhlth.com")

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("* START Finding Location ***********************************"))

if (program_log->run_from_ops = 1)
	if (validate(parm_list))
		call writeLog(build2("->parm_list is available"))
		if (size(parm_list->p_list,5) > 0)
			call writeLog(build2("-->parm_list->p_list size is ",trim(cnvtstring(size(parm_list->p_list,5)))))
			for (j=1 to size(parm_list->p_list,5))
				call writeLog(build2("---->checking parm_list->p_list[",trim(cnvtstring(j)),"]->parm=",parm_list->p_list[j].parm))
				call AddLocationList("FACILITY",parm_list->p_list[j].parm)
			endfor
		endif
	endif
elseif (program_log->run_from_eks = 1)
	set log_message = concat("program_log->run_from_eks =",program_log->run_from_eks)
	call writeLog(build2("---->checking $FACILITY=",$FACILITY))
	call AddLocationList("FACILITY",$FACILITY)
	set log_message = concat("---->checking $FACILITY=",$FACILITY)
else
  	select into "nl:"
  from
    code_value cv
    ,location l
  plan cv
    where cv.display = $FACILITY
    and   cv.code_set = 220
  join l
  	where l.location_cd = cv.code_value
  	and   l.location_type_cd = value(uar_get_code_by("MEANING",222,"FACILITY"))
  	and   l.active_ind = 1
  detail
  		t_rec->facility_cnt = (t_rec->facility_cnt + 1)
  		call writeLog("--adding t_rec->facility_qual[",trim(cnvtstring(t_rec->facility_cnt)),"].facility_disp=",trim(cv.display))
  		t_rec->facility_qual[t_rec->facility_cnt].facility_disp=cv.display
	with nocounter

	for (i=1 to t_rec->facility_cnt)
		call AddLocationList("FACILITY",trim(t_rec->facility_qual[1].facility_disp))
  	endfor
endif

if (location_list->location_cnt <= 0)
	call writeLog(substring(1,99,build2("FAILED: Invalid Location Parameter Passed")))
	if (program_log->run_from_ops = 1)
		set reply->ops_event = substring(1,99,build2("FAILED: Invalid Location Parameter Passed"))
	endif
	if (validate(reply->status_data.subeventstatus.operationname,0))
		set reply->status_data.subeventstatus.operationname = "Find Location"
		set reply->status_data.subeventstatus.operationstatus = "F"
		set reply->status_data.subeventstatus.targetobjectname = "LOCATION"
	endif
	go to exit_script
endif
call writeLog(build2("* END   Finding Location ***********************************"))

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
