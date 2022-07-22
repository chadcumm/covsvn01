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
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE" 

with OUTDEV, FACILITY, start_dt_tm, end_dt_tm


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
  1 start_dt_tm					= dq8
  1 end_dt_tm					= dq8
  1 facility_cnt              	= i2
  1 facility_qual[*]
   2 facility_disp          	= vc
	1 order_cnt					= i2
  1 order_qual[*]
   2 order_id                 	= f8
   2 encntr_id					= f8
  1 encntr_cnt					= i2
  1 encntr_qual[*]
   2 encntr_id					= f8
   2 loc_facility_cd			= f8
   2 encntr_type_cd				= f8
   2 order_cnt					= i2
   2 attending_id				= f8
)

call addEmailLog("chad.cummings@covhlth.com")

set t_rec->start_dt_tm = cnvtdatetime($start_dt_tm)
set t_rec->end_dt_tm = cnvtdatetime($end_dt_tm)

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("* START Finding Location ***********************************"))
call LogActivity(build2("Finding Location Information"))
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
  order by
  	cv.display
  head cv.display
  		t_rec->facility_cnt = (t_rec->facility_cnt + 1)
  		stat = alterlist(t_rec->facility_qual,t_rec->facility_cnt)
  		call writeLog(build2("--adding t_rec->facility_qual[",trim(cnvtstring(t_rec->facility_cnt)),"].facility_disp=",
  		trim(cv.display)))
  		t_rec->facility_qual[t_rec->facility_cnt].facility_disp=cv.display
	with nocounter

	for (i=1 to t_rec->facility_cnt)
		call AddLocationList("FACILITY",trim(t_rec->facility_qual[i].facility_disp))
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

call writeLog(build2("* START Order Selection ************************************"))
call LogActivity(build2("Finding Orders Information"))
select into "nl:"
from
	 encounter e
	,order_action oa
	,orders o
	,mltm_ndc_main_drug_code mn
plan e
	where expand(cnt,1,location_list->location_cnt,e.loc_facility_cd,location_list->locations[cnt].location_cd)
	and e.reg_dt_tm between cnvtdatetime(t_rec->start_dt_tm) and cnvtdatetime(t_rec->end_dt_tm)
	and e.active_ind = 1
join o
	where o.encntr_id = e.encntr_id
	and o.active_ind = 1
	and o.activity_type_cd = value(uar_get_code_by("MEANING",106,"PHARMACY"))
	and o.dcp_clin_cat_cd = value(uar_get_code_by("MEANING",16389,"MEDICATIONS")) ;Medication
	and o.template_order_id = 0.00
	and o.orig_ord_as_flag not in(2,3) ;exclude home, patient own meds
join oa where oa.order_id = o.order_id
	and oa.action_type_cd = value(uar_get_code_by("MEANING",6003,"ORDER")) ;003 ;Order
	;and oa.action_dt_tm between cnvtdatetime(curdate-60,0) and cnvtdatetime(curdate,curtime3)
join mn where mn.drug_identifier = substring(9,6,o.cki)
	and cnvtint(mn.csa_schedule) > 0 ;controlled substance
order by
	 e.loc_facility_cd
	,e.encntr_id
	,o.order_id
head report
	call writeLog(build2("->INSIDE ORDER QUERY"))
	order_cnt = 0
head e.loc_facility_cd
	call writeLog(build2("--->e.loc_facility_cd=",trim(cnvtstring(e.loc_facility_cd)),
		":",trim(uar_get_code_display(e.loc_facility_cd))))
head e.encntr_id
	call writeLog(build2("---->e.encntr_id=",trim(cnvtstring(e.encntr_id)),":",trim(uar_get_code_display(e.encntr_type_cd))))
	t_rec->encntr_cnt = (t_rec->encntr_cnt + 1)
	stat = alterlist(t_rec->encntr_qual,t_rec->encntr_cnt)
	t_rec->encntr_qual[t_rec->encntr_cnt].encntr_id 			= e.encntr_id
	t_rec->encntr_qual[t_rec->encntr_cnt].loc_facility_cd 		= e.loc_facility_cd
	t_rec->encntr_qual[t_rec->encntr_cnt].encntr_type_cd		= e.encntr_type_cd
	order_cnt = 0
head o.order_id
	t_rec->order_cnt = (t_rec->order_cnt + 1)
	stat = alterlist(t_rec->order_qual,t_rec->order_cnt)
	call writeLog(build2("t_rec->order_qual[",trim(cnvtstring(t_rec->order_cnt)),"].order_id=",trim(cnvtstring(o.order_id))))
	t_rec->order_qual[t_rec->order_cnt].order_id = o.order_id
	t_rec->order_qual[t_rec->order_cnt].encntr_id = o.encntr_id
	order_cnt = (order_cnt + 1)
foot e.encntr_id	
	t_rec->encntr_qual[t_rec->encntr_cnt].order_cnt = order_cnt
foot report
	call writeLog(build2("<-OUTSIDE ORDER QUERY"))
with nocounter

select into "nl:"
from
	 encounter e
	 ,dummyt d1
plan d1
join e
	where expand(cnt,1,location_list->location_cnt,e.loc_facility_cd,location_list->locations[cnt].location_cd)
	and e.reg_dt_tm between cnvtdatetime(t_rec->start_dt_tm) and cnvtdatetime(t_rec->end_dt_tm)
	and e.encntr_id != t_rec->encntr_qual[d1.seq].encntr_id
order by
	 e.loc_facility_cd
	,e.encntr_id
head report
	call writeLog(build2("->INSIDE ENCOUNTER QUERY"))
	order_cnt = 0
head e.loc_facility_cd
	call writeLog(build2("--->e.loc_facility_cd=",trim(cnvtstring(e.loc_facility_cd)),
		":",trim(uar_get_code_display(e.loc_facility_cd))))
head e.encntr_id
	call writeLog(build2("---->e.encntr_id=",trim(cnvtstring(e.encntr_id)),":",trim(uar_get_code_display(e.encntr_type_cd))))
	t_rec->encntr_cnt = (t_rec->encntr_cnt + 1)
	stat = alterlist(t_rec->encntr_qual,t_rec->encntr_cnt)
	t_rec->encntr_qual[t_rec->encntr_cnt].encntr_id 			= e.encntr_id
	t_rec->encntr_qual[t_rec->encntr_cnt].loc_facility_cd 		= e.loc_facility_cd
	t_rec->encntr_qual[t_rec->encntr_cnt].encntr_type_cd		= e.encntr_type_cd
with nocounter


call writeLog(build2("* END   Order Selection ************************************"))


call writeLog(build2("* START Attending Selection ************************************"))

select into "nl:"
from
	 (dummyt d1 with seq=t_rec->encntr_cnt)
	,encntr_prsnl_reltn epr
plan d1
join epr
	where epr.encntr_id 		= t_rec->encntr_qual[d1.seq].encntr_id
	and   epr.encntr_prsnl_r_cd = code_values->cv.cs_333.attenddoc_cd
	and   (		(epr.active_ind 		= 1)
			or 
				(epr.expiration_ind     = 1)
		   )
	and   epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	and   epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
order by
	 d1.seq
	,epr.encntr_id
	,epr.active_ind desc
	,epr.beg_effective_dt_tm desc
head d1.seq
	t_rec->encntr_qual[d1.seq].attending_id = epr.prsnl_person_id
with nocounter 

call writeLog(build2("* END   Attending Selection ************************************"))

call writeLog(build2("* START Creating Output   ************************************"))

select into $OUTDEV
	 location = uar_get_code_display(e.loc_facility_cd)
	,encntr_type = uar_get_code_display(e.encntr_type_cd)
	,e.reg_dt_tm ";;q"
	,fin = cnvtalias(ea.alias,ea.alias_pool_cd)
	,order_provider=p1.name_full_formatted
	,provider_position=uar_get_code_display(p1.position_cd)
	,order_synonym=o.order_mnemonic
	,e_encntr_id = t_rec->encntr_qual[d1.seq].encntr_id
	,o_encntr_id = t_rec->order_qual[d2.seq].encntr_id
	,o_order_id  = t_rec->order_qual[d2.seq].order_id
	,on1.notification_display_dt_tm ";;q"
from
	 (dummyt d1 with seq=t_rec->encntr_cnt)
	,(dummyt d2 with seq=t_rec->order_cnt)
	,(dummyt d3)
	,(dummyt d4)
	,encounter e
	,person p
	,encntr_alias ea
	,orders o
	,order_action oa
	,prsnl p1
	,order_notification on1
plan d1
join e
	where e.encntr_id = t_rec->encntr_qual[d1.seq].encntr_id
join p
	where p.person_id = e.person_id
join ea
	where ea.encntr_id = e.encntr_id
	and   ea.active_ind = 1
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	and   ea.encntr_alias_type_cd = code_values->cv.cs_319.fin_nbr_cd
join d3
join d2
	where t_rec->order_qual[d2.seq].encntr_id = t_rec->encntr_qual[d1.seq].encntr_id
join o
	where o.order_id = t_rec->order_qual[d2.seq].order_id
join oa
	where oa.order_id = o.order_id
	and   oa.action_type_cd = code_values->cv.cs_6003.order_cd
join p1
	where p1.person_id = oa.order_provider_id
join d4
join on1
	where on1.order_id = o.order_id
	and   on1.notification_type_flag = 2
order by
	 location
	,order_provider
	,fin
with nocounter,format,separator=" ",outerjoin = d3, outerjoin = d4

call writeLog(build2("* END   Creating Output   ************************************"))
	
	
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   ************************************"))
call writeLog(build2("* END   Custom   ************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
call echorecord(program_log)
;call echorecord(location_list)



end
go
