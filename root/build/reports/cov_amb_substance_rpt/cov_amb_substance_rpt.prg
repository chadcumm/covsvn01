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
	, "Practice" = ""
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Provider" = 0
	;<<hidden>>"Search" = ""
	;<<hidden>>"Delete" = "" 

with OUTDEV, PRACTICE, start_dt_tm, end_dt_tm, NEW_PROVIDER


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
  1 csa_ind						= i2
  1 medonly_ind					= i2
  1 encntr_type_cnt				= i2
  1 encntr_type[*]
   2 encntr_type_cd				= f8
  1 note_type_cnt				= i2
  1 note_type[*]
   2 event_cd					= f8
  1 facility_cnt              	= i2
  1 facility_qual[*]
   2 facility_disp          	= vc
	1 order_cnt					= i4
  1 order_qual[*]
   2 order_id                 	= f8
   2 encntr_id					= f8
   2 csa_schedule				= i2
   2 csa_schedule_numeral		= vc
   2 clinical_disp_line			= vc
   2 supervising_provider_id	= f8
   2 supervising_provider		= vc
   2 supervising_position		= vc
   2 ordering_provider_id		= f8
   2 ordering_provider			= vc
   2 ordering_position			= vc
   2 order_synonym				= vc
  1 encntr_cnt					= i4
  1 encntr_qual[*]
   2 encntr_id					= f8
   2 person_id					= f8
   2 loc_facility_cd			= f8
   2 practice					= vc
   2 facility_disp				= vc
   2 patient_name				= vc
   2 fin						= vc
   2 cmrn						= vc
   2 reg_dt_tm					= dq8
   2 encntr_type_cd				= f8
   2 order_cnt					= i4
   2 attending_id				= f8
   2 attending_provider			= vc
   2 attending_position			= vc
  1 doc_cnt						= i4
  1 doc_qual[*]
   2 encntr_id					= f8
   2 event_id					= f8
   2 event_cd					= f8	
   2 perform_id					= f8
   2 perform_prsnl				= vc
   2 perform_position			= vc
   2 verified_id				= f8
   2 verified_prsnl				= vc
   2 verified_position			= vc
   2 signed_id					= f8
   2 action_type_cd				= f8
   2 verified_dt_tm				= f8
   2 signed_dt_tm				= f8
   2 ce_event_prsnl_id			= f8
   2 review_prsnl_id			= f8
   2 review_prsnl				= vc
   2 review_position			= vc
  1 summary_cnt 				= i2
  1 summary_qual[*]
   2 practice					= vc
   2 unique_patient_cnt			= i2
   2 patients_with_cs			= i2
   2 patients_with_no_cs		= i2
   2 patients_with_cs_0			= i2
   2 patients_with_cs_i			= i2
   2 patients_with_cs_ii		= i2
   2 patients_with_cs_iii		= i2
   2 patients_with_cs_iv		= i2
   2 patients_with_cs_v			= i2
   2 percentage					= f8
   2 facility_cnt				= i2
   2 facility_qual[*]
    3 facility					= vc
    3 unique_patient_cnt		= i2
    3 patients_with_cs			= i2
    3 percentage				= f8
  1 summary_provider_cnt		= i2
  1 summary_provider_qual[*]
   2 prsnl_id					= f8
   2 provider_name				= vc
   2 practice					= vc
   2 unique_patient_cnt			= i2
   2 patients_with_cs			= i2
   2 percentage					= f8
   2 facility_cnt				= i2
   2 facility_qual[*]
    3 facility					= vc
    3 unique_patient_cnt		= i2
    3 patients_with_cs			= i2
    3 percentage				= f8
  	
)

call addEmailLog("chad.cummings@covhlth.com")

set t_rec->start_dt_tm = cnvtdatetime($start_dt_tm)
set t_rec->end_dt_tm = cnvtdatetime($end_dt_tm)
set t_rec->csa_ind = 1 ;$csa_ind
set t_rec->medonly_ind = 0 ;$medonly_ind

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
	;call writeLog(build2("---->checking $FACILITY=",$FACILITY))
	;call AddLocationList("FACILITY",$FACILITY)
	;set log_message = concat("---->checking $FACILITY=",$FACILITY)
else
  select into "nl:"
  from
    code_value cv
    ,location l
    ,code_value_outbound cvo
  plan cv
    where cv.code_set = 220
    and   cv.active_ind = 1
  join l
  	where l.location_cd = cv.code_value
  	and   l.location_type_cd = value(uar_get_code_by("MEANING",222,"FACILITY"))
  	and   l.active_ind = 1
  join cvo
	where cvo.code_value = l.location_cd
	and	  cvo.contributor_source_cd = value(uar_get_code_by("DISPLAY",73,"COVDEV1"))
	and   cvo.code_set = 220
	and   cvo.alias_type_meaning in("FACILITY")
	and   cvo.alias = $PRACTICE
  order by
  	 cvo.alias
  	,cv.display
  head cvo.alias
   call writeLog(build2("--adding t_rec->summary_qual[",trim(cnvtstring(t_rec->summary_cnt)),"].practice=",trim(cvo.alias)))
  		t_rec->summary_cnt = (t_rec->summary_cnt + 1)
		stat = alterlist(t_rec->summary_qual,t_rec->summary_cnt)
		t_rec->summary_qual[t_rec->summary_cnt].practice = cvo.alias
  head cv.display
  	call writeLog(build2("--adding t_rec->facility_qual[",trim(cnvtstring(t_rec->facility_cnt)),"].facility_disp=",trim(cv.display)))
  	t_rec->facility_cnt = (t_rec->facility_cnt + 1)
  	stat = alterlist(t_rec->facility_qual,t_rec->facility_cnt)
  	t_rec->facility_qual[t_rec->facility_cnt].facility_disp=cv.display
  	t_rec->summary_qual[t_rec->summary_cnt].facility_cnt = (t_rec->summary_qual[t_rec->summary_cnt].facility_cnt + 1)
    stat = alterlist(t_rec->summary_qual[t_rec->summary_cnt].facility_qual,t_rec->summary_qual[t_rec->summary_cnt].facility_cnt)
  	t_rec->summary_qual[t_rec->summary_cnt].facility_qual[t_rec->summary_qual[t_rec->summary_cnt].facility_cnt].facility = cv.display
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

call writeLog(build2("* START Finding Doc Types ***********************************"))

select into "nl:"
from
	note_type nt
plan nt
	where nt.data_status_ind 		= 1
	and   ((nt.note_type_description  = "*Office Note*")
			or
			(nt.note_type_description  = "Office Note*"))
order by
	nt.event_cd
head report
	t_rec->note_type_cnt = 0
head nt.event_cd
	call writeLog(build2("--->note_description=",trim(nt.note_type_description),":",trim(cnvtstring(nt.note_type_id)),
		trim(cnvtstring(nt.event_cd))))
	t_rec->note_type_cnt = (t_rec->note_type_cnt + 1)
	stat = alterlist(t_rec->note_type,t_rec->note_type_cnt)
	t_rec->note_type[t_rec->note_type_cnt].event_cd = nt.event_cd
	call writeLog(build2("t_rec->note_type[",trim(cnvtstring(t_rec->note_type_cnt)),"].event_cd=",trim(cnvtstring(nt.event_cd))))
with nocounter

call writeLog(build2("* END   Finding Doc Types ***********************************"))

call writeLog(build2("* START Finding Encounter Types ***********************************"))

select into "nl:"
from
	code_value cv
plan cv
	where cv.code_set = 71
	and   cv.active_ind = 1
	and   cv.display in(
							"Results Only"
						)
order by
	cv.code_value
head report
	t_rec->encntr_type_cnt = 0
head cv.code_value
	call writeLog(build2("--->encntr_type=",trim(cv.display),":",trim(cnvtstring(cv.code_value))))
	t_rec->encntr_type_cnt = (t_rec->encntr_type_cnt + 1)
	stat = alterlist(t_rec->encntr_type,t_rec->encntr_type_cnt)
	t_rec->encntr_type[t_rec->encntr_type_cnt].encntr_type_cd = cv.code_value
	call writeLog(build2("t_rec->encntr_type[",trim(cnvtstring(t_rec->encntr_type_cnt)),"].encntr_type_cd="
		,trim(cnvtstring(cv.code_value))))
with nocounter

call writeLog(build2("* END   Finding Encounter Types ***********************************"))


call writeLog(build2("* START Order Selection ************************************"))
call LogActivity(build2("Finding Orders Information"))
select 
	into "nl:"
from
	 encounter e
	,person p
	,order_action oa
	,orders o
	,mltm_ndc_main_drug_code mn
plan e
	where expand(cnt,1,location_list->location_cnt,e.loc_facility_cd,location_list->locations[cnt].location_cd)
	and e.reg_dt_tm between cnvtdatetime(t_rec->start_dt_tm) and cnvtdatetime(t_rec->end_dt_tm)
	and not expand(i,1,t_rec->encntr_type_cnt,e.encntr_type_cd,t_rec->encntr_type[i].encntr_type_cd)
	and e.active_ind = 1
join p
	where p.person_id = e.person_id
	and   p.name_last_key not in(
										 "ZZZTEST"
										,"TTTEST"
										,"TTTTEST"
										,"TTTTMAYO"
										,"TTTTTEST"
										,"FFFFOP"
										,"TTTTGENLAB"
										,"TTTTQUEST"			
									)
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
	;and cnvtint(mn.csa_schedule) > 0 ;controlled substance
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
	call writeLog(build2("---->e.encntr_id=",trim(cnvtstring(e.encntr_id)),":",trim(uar_get_code_display(e.encntr_type_cd)),
		":t_rec->encntr_cnt=",trim(cnvtstring(t_rec->encntr_cnt))))
;	t_rec->encntr_cnt = (t_rec->encntr_cnt + 1)
;	stat = alterlist(t_rec->encntr_qual,t_rec->encntr_cnt)
;	t_rec->encntr_qual[t_rec->encntr_cnt].encntr_id 			= e.encntr_id
;	t_rec->encntr_qual[t_rec->encntr_cnt].person_id				= e.person_id
;	t_rec->encntr_qual[t_rec->encntr_cnt].loc_facility_cd 		= e.loc_facility_cd
;	t_rec->encntr_qual[t_rec->encntr_cnt].encntr_type_cd		= e.encntr_type_cd
;	t_rec->encntr_qual[t_rec->encntr_cnt].patient_name			= p.name_full_formatted
;	t_rec->encntr_qual[t_rec->encntr_cnt].reg_dt_tm				= e.reg_dt_tm
	order_cnt = 0
head o.order_id
	if ( ((t_rec->csa_ind = 0) and (cnvtint(mn.csa_schedule) > 0)) or t_rec->csa_ind = 1)
		t_rec->order_cnt = (t_rec->order_cnt + 1)
		stat = alterlist(t_rec->order_qual,t_rec->order_cnt)
		call writeLog(build2("t_rec->order_qual[",trim(cnvtstring(t_rec->order_cnt)),"].order_id=",trim(cnvtstring(o.order_id))))
		t_rec->order_qual[t_rec->order_cnt].order_id 					= o.order_id
		t_rec->order_qual[t_rec->order_cnt].encntr_id 					= o.encntr_id
		t_rec->order_qual[t_rec->order_cnt].csa_schedule 				= cnvtint(mn.csa_schedule)
		t_rec->order_qual[t_rec->order_cnt].clinical_disp_line 			= o.clinical_display_line
		t_rec->order_qual[t_rec->order_cnt].supervising_provider_id 	= oa.supervising_provider_id
		t_rec->order_qual[t_rec->order_cnt].order_synonym				= o.order_mnemonic
		t_rec->order_qual[t_rec->order_cnt].ordering_provider_id		= oa.order_provider_id
		order_cnt = (order_cnt + 1)
		case (t_rec->order_qual[t_rec->order_cnt].csa_schedule)
			of 1: t_rec->order_qual[t_rec->order_cnt].csa_schedule_numeral = "I"
			of 2: t_rec->order_qual[t_rec->order_cnt].csa_schedule_numeral = "II"
			of 3: t_rec->order_qual[t_rec->order_cnt].csa_schedule_numeral = "III"
			of 4: t_rec->order_qual[t_rec->order_cnt].csa_schedule_numeral = "IV"
			of 5: t_rec->order_qual[t_rec->order_cnt].csa_schedule_numeral = "V"
		endcase
	endif
foot e.encntr_id
	if (order_cnt > 0)
		t_rec->encntr_cnt = (t_rec->encntr_cnt + 1)
		stat = alterlist(t_rec->encntr_qual,t_rec->encntr_cnt)
		t_rec->encntr_qual[t_rec->encntr_cnt].encntr_id 			= e.encntr_id
		t_rec->encntr_qual[t_rec->encntr_cnt].person_id				= e.person_id
		t_rec->encntr_qual[t_rec->encntr_cnt].loc_facility_cd 		= e.loc_facility_cd
		t_rec->encntr_qual[t_rec->encntr_cnt].encntr_type_cd		= e.encntr_type_cd
		t_rec->encntr_qual[t_rec->encntr_cnt].patient_name			= p.name_full_formatted
		t_rec->encntr_qual[t_rec->encntr_cnt].reg_dt_tm				= e.reg_dt_tm	
		t_rec->encntr_qual[t_rec->encntr_cnt].order_cnt 			= order_cnt
	endif
foot report
	call writeLog(build2("<-OUTSIDE ORDER QUERY"))
with nocounter

if (t_rec->medonly_ind = 0)
select into "nl:"
from
	 encounter e
	 ,person p
	 ,dummyt d1
plan d1
join e
	where expand(cnt,1,location_list->location_cnt,e.loc_facility_cd,location_list->locations[cnt].location_cd)
	and e.reg_dt_tm between cnvtdatetime(t_rec->start_dt_tm) and cnvtdatetime(t_rec->end_dt_tm)
	and not expand(i,1,t_rec->encntr_type_cnt,e.encntr_type_cd,t_rec->encntr_type[i].encntr_type_cd)
	and e.encntr_id != t_rec->encntr_qual[d1.seq].encntr_id
join p
	where p.person_id = e.person_id
    and   p.name_last_key not in(
										 "ZZZTEST"
										,"TTTEST"
										,"TTTTEST"
										,"TTTTMAYO"
										,"TTTTTEST"
										,"FFFFOP"
										,"TTTTGENLAB"
										,"TTTTQUEST"			
									)
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
	call writeLog(build2("---->e.encntr_id=",trim(cnvtstring(e.encntr_id)),":",trim(uar_get_code_display(e.encntr_type_cd)),
		":t_rec->encntr_cnt=",trim(cnvtstring(t_rec->encntr_cnt))))
	t_rec->encntr_cnt = (t_rec->encntr_cnt + 1)
	stat = alterlist(t_rec->encntr_qual,t_rec->encntr_cnt)
	t_rec->encntr_qual[t_rec->encntr_cnt].encntr_id 			= e.encntr_id
	t_rec->encntr_qual[t_rec->encntr_cnt].person_id				= e.person_id
	t_rec->encntr_qual[t_rec->encntr_cnt].loc_facility_cd 		= e.loc_facility_cd
	t_rec->encntr_qual[t_rec->encntr_cnt].encntr_type_cd		= e.encntr_type_cd
	t_rec->encntr_qual[t_rec->encntr_cnt].patient_name			= p.name_full_formatted
	t_rec->encntr_qual[t_rec->encntr_cnt].reg_dt_tm				= e.reg_dt_tm
with nocounter
endif

call writeLog(build2("* END   Order Selection ************************************"))


call writeLog(build2("* START Attending Selection ************************************"))

select into "nl:"
	d1seq=d1.seq
from
	 (dummyt d1 with seq=t_rec->encntr_cnt)
	,encntr_prsnl_reltn epr
	,prsnl p
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
join p
	where p.person_id = epr.prsnl_person_id
order by
	 d1seq
	,epr.encntr_id
	,epr.active_ind desc
	,epr.beg_effective_dt_tm desc
head d1.seq
	call writeLog(build2("---->e.encntr_id=",trim(cnvtstring(epr.encntr_id)),":",trim(uar_get_code_display(epr.encntr_prsnl_r_cd)),
		":prsnl_id=",trim(cnvtstring(epr.prsnl_person_id)),":",trim(p.name_full_formatted)))
	t_rec->encntr_qual[d1.seq].attending_id = epr.prsnl_person_id
	if (p.person_id > 0.0)
		t_rec->encntr_qual[d1.seq].attending_provider = p.name_full_formatted
		t_rec->encntr_qual[d1.seq].attending_position = uar_get_code_display(p.position_cd)
	else
		t_rec->encntr_qual[d1.seq].attending_provider = ""
		t_rec->encntr_qual[d1.seq].attending_position = ""
	endif	
with nocounter 

call writeLog(build2("* END   Attending Selection ************************************"))

call writeLog(build2("* START PCP Selection ************************************"))

select into "nl:"
	d1seq=d1.seq
from
	 (dummyt d1 with seq=t_rec->encntr_cnt)
	,person_prsnl_reltn epr
	,prsnl p
plan d1
	where t_rec->encntr_qual[d1.seq].attending_id = 0.0
join epr
	where epr.person_id 		= t_rec->encntr_qual[d1.seq].person_id
	and   epr.person_prsnl_r_cd = code_values->cv.cs_331.pcp_cd
	and   (		(epr.active_ind 		= 1) )
	and   epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	and   epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
join p
	where p.person_id = epr.prsnl_person_id
order by
	 d1seq
	,epr.person_id
	,epr.active_ind desc
	,epr.beg_effective_dt_tm desc
head d1.seq
		call writeLog(build2("---->e.person_id=",trim(cnvtstring(epr.person_id)),":",trim(uar_get_code_display(epr.person_prsnl_r_cd)),
		":prsnl_id=",trim(cnvtstring(epr.prsnl_person_id)),":",trim(p.name_full_formatted)))
	t_rec->encntr_qual[d1.seq].attending_id = epr.prsnl_person_id
	if (p.person_id > 0.0)
		t_rec->encntr_qual[d1.seq].attending_provider = p.name_full_formatted
		t_rec->encntr_qual[d1.seq].attending_position = uar_get_code_display(p.position_cd)
	else
		t_rec->encntr_qual[d1.seq].attending_provider = ""
		t_rec->encntr_qual[d1.seq].attending_position = ""
	endif	
with nocounter 

call writeLog(build2("* END   PCP Selection ************************************"))
/*
call writeLog(build2("* START Document Selection ************************************"))

select into "nl:"
	d1seq=d1.seq
from
	 (dummyt d1 with seq=t_rec->encntr_cnt)
	,clinical_event ce1
plan d1
	where t_rec->encntr_qual[d1.seq].order_cnt > 0
join ce1
    where 	ce1.encntr_id			= t_rec->encntr_qual[d1.seq].encntr_id
    and		ce1.result_status_cd   	 in(
    										 code_values->cv.cs_8.auth_cd
    										,code_values->cv.cs_8.modified_cd
    										,code_values->cv.cs_8.altered_cd
    									)
    and   	ce1.valid_until_dt_tm   	>= cnvtdatetime (curdate,curtime3)
    and     ce1.event_tag        != "Date\Time Correction"

    and		expand(i,1,t_rec->note_type_cnt,ce1.event_cd,t_rec->note_type[i].event_cd)
head report
	t_rec->doc_cnt = 0
detail
	t_rec->doc_cnt = (t_rec->doc_cnt + 1)
	stat = alterlist(t_rec->doc_qual,t_rec->doc_cnt)
	t_rec->doc_qual[t_rec->doc_cnt].encntr_id = ce1.encntr_id
	t_rec->doc_qual[t_rec->doc_cnt].event_id  = ce1.event_id
	t_rec->doc_qual[t_rec->doc_cnt].perform_id  = ce1.performed_prsnl_id
	t_rec->doc_qual[t_rec->doc_cnt].verified_id = ce1.verified_prsnl_id
	t_rec->doc_qual[t_rec->doc_cnt].verified_dt_tm = ce1.verified_dt_tm
	call writeLog(build2("---->e.encntr_id=",trim(cnvtstring(ce1.encntr_id)),":",trim(uar_get_code_display(ce1.event_cd)),
		":",trim(ce1.event_title_text)))
with nocounter 

call writeLog(build2("* END   Document Selection ************************************"))

call writeLog(build2("* START Document Co-Sign  ************************************"))

select into "nl:"
	d1seq=d1.seq
from
	 (dummyt d1 with seq=t_rec->doc_cnt)
	,ce_event_prsnl cep1
plan d1
join cep1
    where 	cep1.event_id			= t_rec->doc_qual[d1.seq].event_id
	and		cep1.valid_until_dt_tm	>= cnvtdatetime(curdate,curtime3)
	and     cep1.action_type_cd	in(
									 code_values->cv.cs_21.sign_cd
									;,code_values->cv.cs_21.review_cd
								   )
    and		cep1.action_status_cd in(
    									code_values->cv.cs_103.completed_cd
    								)
order by
	 cep1.event_id
	,cep1.action_dt_tm desc
head report
	call writeLog(build2("---->INSIDE DOCUMENT SIGN/REVIEW QUERY"))
head cep1.event_id
	call writeLog(build2("---->cep1.event_id=",trim(cnvtstring(cep1.event_id)),":",trim(uar_get_code_display(cep1.action_type_cd)),
		":",trim(uar_get_code_display(cep1.action_status_cd)),":",trim(cnvtstring(cep1.action_prsnl_id))))
	t_rec->doc_qual[d1.seq].signed_id = cep1.action_prsnl_id
	t_rec->doc_qual[d1.seq].signed_dt_tm = cep1.action_dt_tm
	t_rec->doc_qual[d1.seq].ce_event_prsnl_id = cep1.ce_event_prsnl_id
	t_rec->doc_qual[d1.seq].action_type_cd = cep1.action_type_cd
with nocounter 

call writeLog(build2("* END   Document Co-Sign ************************************"))
*/

call writeLog(build2("* START Finding FIN ******************************************"))
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->encntr_cnt)
	,encntr_alias ea
plan d1
	where t_rec->encntr_qual[d1.seq].encntr_id > 0.0
join ea
	where ea.encntr_id 			    = t_rec->encntr_qual[d1.seq].encntr_id
	and	  ea.encntr_alias_type_cd	= code_values->cv.cs_319.fin_nbr_cd
	and   ea.active_ind				= 1
	and   ea.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   ea.beg_effective_dt_tm 	<= cnvtdatetime(curdate,curtime3)
order by
	 ea.encntr_id
	,ea.beg_effective_dt_tm
detail
		call writeLog(build2("---->ea.encntr_id=",trim(cnvtstring(ea.encntr_id)),":",trim(uar_get_code_display(ea.encntr_alias_type_cd)),
		":alias=",trim(ea.alias)))
	t_rec->encntr_qual[d1.seq].fin = cnvtalias(ea.alias,ea.alias_pool_cd)
with nocounter 
call writeLog(build2("* END   Finding FIN ******************************************"))

call writeLog(build2("* START Finding cMRN *****************************************"))
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->encntr_cnt)
	,person_alias ea
plan d1
	where t_rec->encntr_qual[d1.seq].person_id > 0.0
join ea
	where ea.person_id 			    = t_rec->encntr_qual[d1.seq].person_id
	and	  ea.person_alias_type_cd	= code_values->cv.cs_4.community_medical_record_number_cd
	and   ea.active_ind				= 1
	and   ea.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   ea.beg_effective_dt_tm 	<= cnvtdatetime(curdate,curtime3)
order by
	 ea.person_id
	,ea.beg_effective_dt_tm
detail
		call writeLog(build2("---->ea.person_id=",trim(cnvtstring(ea.person_id)),":",trim(uar_get_code_display(ea.person_alias_type_cd)),
		":alias=",trim(ea.alias)))
	t_rec->encntr_qual[d1.seq].cmrn = cnvtalias(ea.alias,ea.alias_pool_cd)
with nocounter 
call writeLog(build2("* END   Finding cMRN *****************************************"))

call writeLog(build2("* START Populating Providers *********************************"))

select into "nl:"
from 
	 (dummyt d1 with seq=t_rec->order_cnt)
	,prsnl p
plan d1
	where t_rec->order_qual[d1.seq].order_id > 0.0
join p
	where p.person_id = t_rec->order_qual[d1.seq].supervising_provider_id
detail
	if (p.person_id > 0.0)
		t_rec->order_qual[d1.seq].supervising_provider = p.name_full_formatted
		t_rec->order_qual[d1.seq].supervising_position = uar_get_code_display(p.position_cd)
	else
		t_rec->order_qual[d1.seq].supervising_provider = ""
		t_rec->order_qual[d1.seq].supervising_position = ""
	endif	
with nocounter

select into "nl:"
from 
	 (dummyt d1 with seq=t_rec->order_cnt)
	,prsnl p
plan d1
	where t_rec->order_qual[d1.seq].order_id > 0.0
join p
	where p.person_id = t_rec->order_qual[d1.seq].ordering_provider_id
detail
	if (p.person_id > 0.0)
		t_rec->order_qual[d1.seq].ordering_provider = p.name_full_formatted
		t_rec->order_qual[d1.seq].ordering_position = uar_get_code_display(p.position_cd)
	else
		t_rec->order_qual[d1.seq].ordering_provider = ""
		t_rec->order_qual[d1.seq].ordering_position = ""
	endif	
with nocounter

/*
select into "nl:"
from 
	 (dummyt d1 with seq=t_rec->doc_cnt)
	,prsnl p
plan d1
	where t_rec->doc_qual[d1.seq].event_id > 0.0
join p
	where p.person_id = t_rec->doc_qual[d1.seq].perform_id
detail
	if (p.person_id > 0.0)
		t_rec->doc_qual[d1.seq].perform_prsnl 		= p.name_full_formatted
		t_rec->doc_qual[d1.seq].perform_position 	= uar_get_code_display(p.position_cd)
	else
		t_rec->doc_qual[d1.seq].perform_prsnl 		= ""
		t_rec->doc_qual[d1.seq].perform_position 	= ""
	endif	
with nocounter

select into "nl:"
from 
	 (dummyt d1 with seq=t_rec->doc_cnt)
	,prsnl p
plan d1
	where t_rec->doc_qual[d1.seq].event_id > 0.0
join p
	where p.person_id = t_rec->doc_qual[d1.seq].verified_id
detail
	if (p.person_id > 0.0)
		t_rec->doc_qual[d1.seq].verified_prsnl 		= p.name_full_formatted
		t_rec->doc_qual[d1.seq].verified_position 	= uar_get_code_display(p.position_cd)
	else
		t_rec->doc_qual[d1.seq].verified_prsnl 		= ""
		t_rec->doc_qual[d1.seq].verified_position 	= ""
	endif	
with nocounter

select into "nl:"
from 
	 (dummyt d1 with seq=t_rec->doc_cnt)
	,prsnl p
plan d1
	where t_rec->doc_qual[d1.seq].event_id > 0.0
join p
	where p.person_id = t_rec->doc_qual[d1.seq].signed_id
detail
	if (p.person_id > 0.0)
		t_rec->doc_qual[d1.seq].review_prsnl 		= p.name_full_formatted
		t_rec->doc_qual[d1.seq].review_position 	= uar_get_code_display(p.position_cd)
	else
		t_rec->doc_qual[d1.seq].review_prsnl 		= ""
		t_rec->doc_qual[d1.seq].review_position 	= ""
	endif	
with nocounter
*/

call writeLog(build2("* END   Populating Providers *********************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Get Practice Aliases *******************************"))
select into "nl:"
	encntr_id = t_rec->encntr_qual[d1.seq].encntr_id
from
	  code_value_outbound cvo
	 ,(dummyt d1 with seq=t_rec->encntr_cnt)
plan d1
join cvo
	where cvo.code_value = t_rec->encntr_qual[d1.seq].loc_facility_cd
	and	  cvo.contributor_source_cd = value(uar_get_code_by("DISPLAY",73,"COVDEV1"))
	and   cvo.code_set = 220
	and   cvo.alias_type_meaning in("FACILITY")
order by
	encntr_id
head report
	call writeLog(build2("->inside code_value_outbound query"))
head encntr_id
	call writeLog(build2("--->found encntr_id=",trim(cnvtstring(encntr_id))))
	t_rec->encntr_qual[d1.seq].practice = cvo.alias
	t_rec->encntr_qual[d1.seq].facility_disp = uar_get_code_display(cvo.code_value)
with nocounter

call writeLog(build2("* END   Get Practice Aliases *******************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Summary Calculations *******************************"))

select into "nl:"
	 encntr_id = t_rec->encntr_qual[d1.seq].encntr_id
	,person_id = t_rec->encntr_qual[d1.seq].person_id
	,practice = substring(1,50,t_rec->encntr_qual[d1.seq].practice)
	,facility = substring(1,50,t_rec->encntr_qual[d1.seq].facility_disp)
	,o_order_id  = t_rec->order_qual[d2.seq].order_id
	,csa_schedule = substring(1,2,t_rec->order_qual[d2.seq].csa_schedule_numeral)
from
	 (dummyt d1 with seq=t_rec->encntr_cnt)
	,(dummyt d2 with seq=t_rec->order_cnt)
	,(dummyt d3)
plan d1
	where t_rec->encntr_qual[d1.seq].practice > " "
	and   t_rec->encntr_qual[d1.seq].facility_disp > " "
join d3
join d2
	where t_rec->order_qual[d2.seq].encntr_id = t_rec->encntr_qual[d1.seq].encntr_id
order by
	 practice
	,facility
	,person_id
	,encntr_id
	,o_order_id
head report
	p_cnt	= 0
	f_cnt	= 0
	e_cnt	= 0
	cs_cnt	= 0
	unique_patient_facility = 0
	patients_with_cs		= 0
	patients_with_no_cs		= 0
	patients_with_cs_ii		= 0
	patients_with_cs_iii	= 0
	patients_with_cs_iv		= 0
	patients_with_cs_v		= 0
head practice
	unique_patient_facility = 0
	f_cnt	= 0
	e_cnt	= 0
	cs_cnt	= 0
	p_cnt = (p_cnt + 1)
	stat = alterlist(t_rec->summary_qual,p_cnt)
	t_rec->summary_qual[p_cnt].practice = practice
	patients_with_cs		= 0
	patients_with_no_cs		= 0
	patients_with_cs_0		= 0
	patients_with_cs_i		= 0
	patients_with_cs_ii		= 0
	patients_with_cs_iii	= 0
	patients_with_cs_iv		= 0
	patients_with_cs_v		= 0
head facility
	unique_patient_facility = 0
	e_cnt	= 0
	cs_cnt	= 0
	f_cnt = (f_cnt + 1)
	stat = alterlist(t_rec->summary_qual[p_cnt].facility_qual,f_cnt)
	t_rec->summary_qual[p_cnt].facility_qual[f_cnt].facility = facility
	call echo(build("reviewing facility:",facility))
head person_id
	e_cnt = (e_cnt + 1)
	unique_patient_facility = (unique_patient_facility + 1)
	call echo(build("adding person_id:",cnvtstring(person_id)))
	/*
	1 summary_qual[*]
	   2 practice					= vc
	   2 unique_patient_cnt			= i2
	   2 patients_with_cs			= i2
	   2 patients_with_no_cs		= i2
	   2 patients_with_cs_ii		= i2
	   2 patients_with_cs_iii		= i2
	   2 patients_with_cs_iv		= i2
	   2 patients_with_cs_v			= i2
	   2 percentage					= f8
	   2 facility_cnt				= i2
    */
head o_order_id
	if (csa_schedule = "0")
		patients_with_cs_0 = (patients_with_cs_0 + 1)
	elseif (csa_schedule = "I")
		patients_with_cs_i = (patients_with_cs_i + 1)
	elseif (csa_schedule = "II")
		patients_with_cs_ii = (patients_with_cs_ii + 1)
	elseif (csa_schedule = "III")
		patients_with_cs_iii = (patients_with_cs_iii + 1)
	elseif (csa_schedule = "IV")
		patients_with_cs_iv = (patients_with_cs_iv + 1)
	elseif (csa_schedule = "V")
		patients_with_cs_v = (patients_with_cs_v + 1)
	else
		patients_with_no_cs = (patients_with_no_cs + 1)
	endif
head encntr_id
	stat = 0
foot encntr_id
	stat = 0
foot person_id
	stat = 0
foot facility
	t_rec->summary_qual[p_cnt].facility_qual[f_cnt].unique_patient_cnt = unique_patient_facility
	t_rec->summary_qual[p_cnt].unique_patient_cnt = (t_rec->summary_qual[p_cnt].unique_patient_cnt + unique_patient_facility)
foot practice
	t_rec->summary_qual[p_cnt].facility_cnt = f_cnt
	t_rec->summary_qual[p_cnt].patients_with_cs			= patients_with_cs
	t_rec->summary_qual[p_cnt].patients_with_no_cs		= patients_with_no_cs
	t_rec->summary_qual[p_cnt].patients_with_cs_0		= patients_with_cs_0
	t_rec->summary_qual[p_cnt].patients_with_cs_i		= patients_with_cs_i
	t_rec->summary_qual[p_cnt].patients_with_cs_ii		= patients_with_cs_ii
	t_rec->summary_qual[p_cnt].patients_with_cs_iii		= patients_with_cs_iii
	t_rec->summary_qual[p_cnt].patients_with_cs_iv		= patients_with_cs_iv
	t_rec->summary_qual[p_cnt].patients_with_cs_v		= patients_with_cs_v
foot report
	t_rec->summary_cnt = p_cnt
with nocounter,outerjoin = d3

call writeLog(build2("* END   Summary Calculations *******************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Provider Calculations ******************************"))
call writeLog(build2("* END   Provider Calculations ******************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("* START Creating Output   ************************************"))

;if (report_option = grid)

select distinct into $OUTDEV
	 practice = trim(substring(1,100,t_rec->encntr_qual[d1.seq].practice))
	,location = trim(substring(1,100,uar_get_code_display(t_rec->encntr_qual[d1.seq].loc_facility_cd)))
	,encntr_type = trim(substring(1,100,uar_get_code_display(t_rec->encntr_qual[d1.seq].encntr_type_cd)))
	,reg_dt_tm = format(t_rec->encntr_qual[d1.seq].reg_dt_tm,";;q")
	,fin = trim(substring(1,20,t_rec->encntr_qual[d1.seq].fin))
	,cmrn = trim(substring(1,20,t_rec->encntr_qual[d1.seq].cmrn))
	,order_provider=trim(substring(1,100,t_rec->order_qual[d2.seq].ordering_provider))
	,provider_position=trim(substring(1,100,t_rec->order_qual[d2.seq].ordering_position))
	,order_synonym=if (t_rec->order_qual[d2.seq].order_id > 0.0) 
					trim(substring(1,100,t_rec->order_qual[d2.seq].order_synonym));o.order_mnemonic
				   else
				    trim(substring(1,100,"No Prescriptions"));o.order_mnemonic
				   endif
	,csa_schedule = substring(1,2,t_rec->order_qual[d2.seq].csa_schedule_numeral)
	,clin_disp_line = trim(substring(1,200,check(t_rec->order_qual[d2.seq].clinical_disp_line)))
	,supervising_physician = trim(substring(1,100,t_rec->order_qual[d2.seq].supervising_provider))
	,supervising_phys_position = trim(substring(1,100,t_rec->order_qual[d2.seq].supervising_position))
	;,document_type = trim(substring(1,100,uar_get_code_display(t_rec->doc_qual[d4.seq].event_cd)))
	;,document_author = trim(substring(1,100,t_rec->doc_qual[d4.seq].perform_prsnl))
	;,document_author_pos = trim(substring(1,100,t_rec->doc_qual[d4.seq].perform_position))
	;,review_type = trim(substring(1,100,uar_get_code_display(t_rec->doc_qual[d4.seq].action_type_cd)))
	;,review_prsnl = trim(substring(1,100,t_rec->doc_qual[d4.seq].review_prsnl))
	;,review_prsnl_pos = trim(substring(1,100,t_rec->doc_qual[d4.seq].review_position))
	,e_person_id = t_rec->encntr_qual[d1.seq].person_id
	,o_encntr_id = t_rec->order_qual[d2.seq].encntr_id
	,o_order_id  = t_rec->order_qual[d2.seq].order_id
	;,ce_event_id = t_rec->doc_qual[d4.seq].event_id
	;,o_order_notificatio_id = on1.order_notification_id
from
	 (dummyt d1 with seq=t_rec->encntr_cnt)
	,(dummyt d2 with seq=t_rec->order_cnt)
	,(dummyt d3)
	;,(dummyt d4 with seq=t_rec->doc_cnt)
	;,(dummyt d5)
plan d1
join d3
join d2
	where t_rec->order_qual[d2.seq].encntr_id = t_rec->encntr_qual[d1.seq].encntr_id
;join d5
;join d4
;	where t_rec->doc_qual[d4.seq].encntr_id = t_rec->encntr_qual[d1.seq].encntr_id
order by
     csa_schedule
	,location
	,order_provider
	,fin
with nocounter,format,separator=" ",outerjoin = d3;, outerjoin = d5


;else

;execute cov_amb_substance_rpt $OUTDEV

;endif	

call writeLog(build2("* END   Creating Output   ************************************"))
	
	
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   ************************************"))
call writeLog(build2("* END   Custom   ************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)
;call echorecord(location_list)



end
go
