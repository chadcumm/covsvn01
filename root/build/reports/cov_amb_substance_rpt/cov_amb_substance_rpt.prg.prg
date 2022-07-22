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
	, "Controlled Substances Only" = 0
	, "Include Encounters without Medications" = 1
	, "Provider" = 0
	;<<hidden>>"Search" = ""
	;<<hidden>>"Delete" = "" 

with OUTDEV, FACILITY, start_dt_tm, end_dt_tm, CSA_IND, MEDONLY_IND, NEW_PROVIDER


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
   2 clinical_disp_line			= vc
   2 supervising_provider_id	= f8
   2 ordering_provider_id		= f8
   2 order_synonym				= vc
  1 encntr_cnt					= i4
  1 encntr_qual[*]
   2 encntr_id					= f8
   2 person_id					= f8
   2 loc_facility_cd			= f8
   2 patient_name				= vc
   2 fin						= vc
   2 reg_dt_tm					= dq8
   2 encntr_type_cd				= f8
   2 order_cnt					= i4
   2 attending_id				= f8
  1 doc_cnt						= i4
  1 doc_qual[*]
   2 encntr_id					= f8
   2 event_id					= f8
   2 event_cd					= f8	
   2 perform_id					= f8
   2 verified_id				= f8
   2 signed_id					= f8
   2 action_type_cd				= f8
   2 verified_dt_tm				= f8
   2 signed_dt_tm				= f8
   2 ce_event_prsnl_id			= f8
)

call addEmailLog("chad.cummings@covhlth.com")

set t_rec->start_dt_tm = cnvtdatetime($start_dt_tm)
set t_rec->end_dt_tm = cnvtdatetime($end_dt_tm)
set t_rec->csa_ind = $csa_ind
set t_rec->medonly_ind = $medonly_ind

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

call writeLog(build2("* START Finding Doc Types ***********************************"))

select into "nl:"
from
	note_type nt
plan nt
	where nt.data_status_ind 		= 1
	and   nt.note_type_description  = "*Office*"
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
	 d1seq
	,epr.encntr_id
	,epr.active_ind desc
	,epr.beg_effective_dt_tm desc
head d1.seq
	call writeLog(build2("---->e.encntr_id=",trim(cnvtstring(epr.encntr_id)),":",trim(uar_get_code_display(epr.encntr_prsnl_r_cd)),
		":prsnl_id=",trim(cnvtstring(epr.prsnl_person_id))))
	t_rec->encntr_qual[d1.seq].attending_id = epr.prsnl_person_id
with nocounter 

call writeLog(build2("* END   Attending Selection ************************************"))

call writeLog(build2("* START PCP Selection ************************************"))

select into "nl:"
	d1seq=d1.seq
from
	 (dummyt d1 with seq=t_rec->encntr_cnt)
	,person_prsnl_reltn epr
plan d1
	where t_rec->encntr_qual[d1.seq].attending_id = 0.0
join epr
	where epr.person_id 		= t_rec->encntr_qual[d1.seq].person_id
	and   epr.person_prsnl_r_cd = code_values->cv.cs_331.pcp_cd
	and   (		(epr.active_ind 		= 1) )
	and   epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	and   epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
order by
	 d1seq
	,epr.person_id
	,epr.active_ind desc
	,epr.beg_effective_dt_tm desc
head d1.seq
		call writeLog(build2("---->e.person_id=",trim(cnvtstring(epr.person_id)),":",trim(uar_get_code_display(epr.person_prsnl_r_cd)),
		":prsnl_id=",trim(cnvtstring(epr.prsnl_person_id))))
	t_rec->encntr_qual[d1.seq].attending_id = epr.prsnl_person_id
with nocounter 

call writeLog(build2("* END   PCP Selection ************************************"))

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
									,code_values->cv.cs_21.review_cd
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
with nocounter 

call writeLog(build2("* END   Document Co-Sign ************************************"))

call writeLog(build2("* START Creating Output   ************************************"))

select distinct into $OUTDEV
	 location = uar_get_code_display(e.loc_facility_cd)
	,encntr_type = uar_get_code_display(e.encntr_type_cd)
	,e.reg_dt_tm ";;q"
	,fin = cnvtalias(ea.alias,ea.alias_pool_cd)
	,order_provider=trim(p1.name_full_formatted)
	,provider_position=trim(uar_get_code_display(p1.position_cd))
	,order_synonym=trim(substring(1,100,t_rec->order_qual[d2.seq].order_synonym));o.order_mnemonic
	,csa_schedule = t_rec->order_qual[d2.seq].csa_schedule
	,clin_disp_line = t_rec->order_qual[d2.seq].clinical_disp_line
	,supervising_physician = p2.name_full_formatted
	,supervising_phys_position = uar_get_code_display(p2.position_cd)
	/* ,cosign_status = 
	 	  if (on1.notification_type_flag = 1.00)	    "Pending"
          elseif (on1.notification_type_flag = 2.00)	"Completed"
          elseif (on1.notification_type_flag = 3.00)	"Refused"
          elseif (on1.notification_type_flag = 4.00)	"Forwarded"
          elseif (on1.notification_type_flag = 5.00)	"Admin-Cleared"
          elseif (on1.notification_type_flag = 6.00)	"No Longer Needed"
		endif
	,cosign_provider = p2.name_full_formatted
	,cosign_provider_position = uar_get_code_display(p2.position_cd)
	,cosign_status_dt_tm = format(on1.status_change_dt_tm,";;q") */
	,document_type = uar_get_code_display(ce1.event_cd)
	,document_author = p3.name_full_formatted
	,document_author_pos = uar_get_code_display(p3.position_cd)
	,review_type = uar_get_code_display(cep1.action_type_cd)
	,review_prsnl = p4.name_full_formatted
	,review_prsnl_pos = uar_get_code_display(p4.position_cd)	
	,e_person_id = t_rec->encntr_qual[d1.seq].person_id
	,o_encntr_id = t_rec->order_qual[d2.seq].encntr_id
	,o_order_id  = o.order_id;t_rec->order_qual[d2.seq].order_id
	,ce_event_id = t_rec->doc_qual[d4.seq].event_id
	;,o_order_notificatio_id = on1.order_notification_id
from
	 (dummyt d1 with seq=t_rec->encntr_cnt)
	,(dummyt d2 with seq=t_rec->order_cnt)
	,(dummyt d3)
	,(dummyt d4 with seq=t_rec->doc_cnt)
	,(dummyt d5)
	,(dummyt d6)
	,(dummyt d7)
	,(dummyt d8)
	,(dummyt d9)
	,(dummyt d10)
	,encounter e
	,person p
	,encntr_alias ea
	,orders o
	,order_action oa
	,prsnl p1
	;,order_notification on1
	,prsnl p2
	,clinical_event ce1
	,prsnl p3
	,ce_event_prsnl cep1
	,prsnl p4
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
join d5
join d4
	where t_rec->doc_qual[d4.seq].encntr_id = t_rec->encntr_qual[d1.seq].encntr_id
join d8
join o
	where o.order_id = t_rec->order_qual[d2.seq].order_id
join d9
join oa
	where oa.order_id = o.order_id
	and   oa.action_type_cd = code_values->cv.cs_6003.order_cd
join d10
join p1
	where p1.person_id = t_rec->order_qual[d2.seq].ordering_provider_id
join d6
join ce1
	where ce1.event_id = t_rec->doc_qual[d4.seq].event_id
join p3
	where p3.person_id = ce1.verified_prsnl_id
join d7
join cep1
	where cep1.ce_event_prsnl_id = t_rec->doc_qual[d4.seq].ce_event_prsnl_id
join p4
	where p4.person_id = cep1.action_prsnl_id

;join d4
;join on1
;	where on1.order_id = o.order_id
;	and   on1.notification_type_flag = 2
;join d5
;join p2
;	where p2.person_id = on1.to_prsnl_id
join p2
	where p2.person_id = oa.supervising_provider_id
order by
	 location
	,order_provider
	,fin
with nocounter,format,separator=" ",outerjoin = d3, outerjoin = d5, outerjoin = d6, outerjoin = d7, outerjoin = d8
	, outerjoin = d9, outerjoin = d10

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
