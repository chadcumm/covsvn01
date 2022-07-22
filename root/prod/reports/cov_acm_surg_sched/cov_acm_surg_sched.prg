/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		08/14/2018
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_acm_Surg_Sched.prg
	Object name:		cov_acm_Surg_Sched
	Request #:			5237, 10161, 11073
 
	Program purpose:	Lists scheduled surgical cases.
 
	Executing from:		CCL
 
 	Special Notes:		Called by layout program(s).
 						Derived from CCL cov_sn_sched_driver.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	05/10/2021	Todd A. Blanchard		Added proposed/planned patient status orders
										for scheduled surgeries.
002	11/12/2021	Todd A. Blanchard		Added hidden prompt and functionality 
										to export data to file.
 
******************************************************************************/
 
drop program cov_acm_Surg_Sched:dba go
create program cov_acm_Surg_Sched:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Report or Grid" = 0
	, "Facility" = 0
	, "Surgical Area" = 0
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Output To File" = 0                   ;* Output to file 

with OUTDEV, report_grid, facility, surg_area, start_datetime, end_datetime, 
	output_file
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare start_datetime				= dq8 with noconstant(cnvtdatetime(curdate, 000000)) ;002
declare end_datetime				= dq8 with noconstant(cnvtdatetime(curdate, 235959)) ;002
 
declare mrn_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "MRN"))
declare fin_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare canceladmit_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "CANCELADMIT"))
declare canceluponreview_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "CANCELUPONREVIEW"))
declare sch_canceled_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "CANCELED"))
declare sch_deleted_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "DELETED"))
declare sch_pending_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "PENDING"))
declare sch_unschedulable_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "UNSCHEDULABLE"))
declare ord_canceled_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "CANCELED"))
declare ord_primary_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 6011, "PRIMARY"))
declare planned_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 16769, "PLANNED")) ;001
declare proposed_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 16769, "PROPOSED")) ;001
declare plannedproposed_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 16769, "PLANNEDPROPOSED")) ;001
declare num							= i4 with noconstant(0)

declare file_var					= vc with constant(build(format(curdate, "yyyymmdd_;;d"), "umsurgsched.csv")) ;002
 
declare temppath_var				= vc with constant(build("cer_temp:", file_var)) ;002
declare temppath2_var				= vc with constant(build("$cer_temp/", file_var)) ;002
	
;002
declare filepath_var				= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
															 "_cust/to_client_site/RevenueCycle/CareManagement/", file_var))
															 
declare output_var					= vc with noconstant("") ;002
 
declare cmd							= vc with noconstant("") ;002
declare len							= i4 with noconstant(0) ;002
declare stat						= i4 with noconstant(0) ;002


; define dates ;002
if (validate(request->batch_selection) = 1)
	set start_datetime = cnvtdatetime(start_datetime)
	set end_datetime = cnvtlookahead("30,D", end_datetime)
else
	set start_datetime = cnvtdatetime($start_datetime)
	set end_datetime = cnvtdatetime($end_datetime)	
endif

 
; define output value ;002
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set output_var = value(temppath_var)
else
	set output_var = value($OUTDEV)
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
free record surg_sched
record surg_sched (
	1 org_name						= vc
	1 start_dt_tm					= dq8
	1 end_dt_tm						= dq8
	1 printed_by					= vc
 
	1 area_cnt						= i2
	1 area_qual[*]
		2 sched_surg_area_cd		= f8
		2 sched_surg_area			= c40
 
	1 cnt							= i4
	1 qual[*]
		2 encntr_id					= f8
		2 person_id					= f8
		2 sch_event_id				= f8
		2 surg_case_id				= f8
		2 sched_dur					= i4
		2 sched_surg_area			= c40
		2 sched_start_dt_tm			= dq8
		2 create_dt_tm				= dq8
		2 sched_op_loc				= c40
		2 sched_pat_type			= c40
		2 sched_type				= c40
		2 surg_case_nbr_formatted	= vc
 
		2 patient_name				= vc
		2 sex						= c40
		2 age						= c12
		2 dob						= dq8
		2 loc_nurse_unit			= c40
		2 loc_facility				= c40
		2 loc_room 					= c40
		2 loc_bed					= c40
		2 encntr_type				= c40
		2 ip_room					= vc
		2 fin						= vc
		2 mrn						= vc
 
		2 proc_cnt						= i4
		2 proc[*]
			3 sched_primary_ind			= i2
			3 sched_ud1					= c40
			3 sched_primary_surgeon_id	= f8
			3 sched_primary_surgeon		= vc
			3 procedure					= c100
			3 proc_text					= c255
			3 inpat_only_proc			= c3
			3 sched_anesth_type			= c40
			3 modifier					= c100
			3 od_modifier1				= c100
			3 od_modifier2				= c100
			3 od_modifier3				= c100
 
		2 prior_auth				= c30
		2 surgery_comment			= c500
		2 phone						= vc
		2 phone_type				= c40
		2 alt_phone					= vc
		2 alt_phone_type			= c40
		2 medical_service			= c40
		2 ins_primary_plan_name		= c100
		2 ins_primary_auth_nbr		= c50
		2 ins_secondary_plan_name	= c100
		2 ins_secondary_auth_nbr	= c50
 
 		;001
		2 pw_cnt						= i4
		2 pw[*]
			3 pathway_id				= f8
			3 power_plan				= c100
			3 phase						= c100
			3 sub_phase					= c100
			3 status					= c40
			3 updt_dt_tm				= dq8
			3 updt_id					= f8
			3 updt_by					= c100
			
			3 pcomp_cnt						= i4
			3 pcomp[*]
				4 pathway_comp_id			= f8
				4 order_mnemonic			= c400
				4 order_sentence			= c400
) with persistscript
 
 
set surg_sched->start_dt_tm	= cnvtdatetime(start_datetime) ;002
set surg_sched->end_dt_tm	= cnvtdatetime(end_datetime) ;002
 
 
/**************************************************************/
; select organization data
select into "nl:"
from
	ORGANIZATION org
 
where
	org.organization_id	= $facility
 
 
; populate record structure
detail
	surg_sched->org_name = trim(org.org_name, 3)
 
with nocounter
 
 
/**************************************************************/
; select personnel data
select into "nl:"
from
	PRSNL per
 
where
	per.person_id = reqinfo->updt_id
 
 
; populate record structure
detail
	surg_sched->printed_by = trim(per.name_full_formatted, 3)
 
with nocounter
 
 
/**************************************************************/
; select surgical area code value data
select into "nl:"
from
	CODE_VALUE cv
 
where
	cv.code_set = 221
	and cv.code_value = $surg_area
	and cv.active_ind = 1
 
order by
	cv.code_value
 
 
; populate record structure
head report
	cnt = 0
 
head cv.code_value
	cnt = cnt + 1
 
	call alterlist(surg_sched->area_qual, cnt)
 
	surg_sched->area_cnt							= cnt
	surg_sched->area_qual[cnt].sched_surg_area_cd	= cv.code_value
	surg_sched->area_qual[cnt].sched_surg_area		= cv.display
 
with nocounter
 
 
/**************************************************************/
; select surgical case data
select into "nl:"
from
	SURGICAL_CASE sc
 
	, (inner join ENCOUNTER e on e.encntr_id = sc.encntr_id
		and e.encntr_type_cd not in (
			canceladmit_var,
			canceluponreview_var
			)
		and e.active_ind = 1)
 
	, (inner join PERSON p on p.person_id = sc.person_id
		and p.active_ind = 1)
 
	, (inner join SCH_EVENT se on se.sch_event_id = sc.sch_event_id
		and se.sch_state_cd not in (
			sch_canceled_var,
			sch_deleted_var,
			sch_pending_var,
			sch_unschedulable_var
			)
		and se.version_dt_tm > sysdate
		and se.active_ind = 1)
 
	, (inner join SCH_EVENT_PATIENT sep on sep.sch_event_id = se.sch_event_id
		and sep.version_dt_tm > sysdate
		and sep.active_ind = 1)
 
	, (inner join SCH_EVENT_ATTACH sea on sea.sch_event_id = sc.sch_event_id
		and sea.state_meaning = "ACTIVE"		
		and sea.version_dt_tm > sysdate
		and sea.active_ind = 1)
 
	, (left join ORDER_DETAIL od on od.order_id = sea.order_id
		and od.oe_field_meaning = "SURGUSER1")
 
	, (left join ORDER_DETAIL od2 on od2.order_id = sea.order_id
		and od2.oe_field_meaning = "SCHEDAUTHNBR")
 
	, (left join ORDER_DETAIL od3 on od3.order_id = sea.order_id
		and od3.oe_field_meaning = "SURGPROCMODIFIER1")
 
	, (left join ORDER_DETAIL od4 on od4.order_id = sea.order_id
		and od4.oe_field_meaning = "SURGPROCMODIFIER2")
 
	, (left join ORDER_DETAIL od5 on od5.order_id = sea.order_id
		and od5.oe_field_meaning = "SURGPROCMODIFIER3")
 
	, (inner join SURG_CASE_PROCEDURE scp on scp.order_id = sea.order_id)
 
	, (inner join ORDER_CATALOG_SYNONYM ocs on ocs.catalog_cd = scp.sched_surg_proc_cd
		and ocs.mnemonic_type_cd = ord_primary_var)
 
	, (inner join PRSNL per on per.person_id = scp.sched_primary_surgeon_id)
 
where
	expand(num, 1, surg_sched->area_cnt, sc.sched_surg_area_cd, surg_sched->area_qual[num].sched_surg_area_cd)
	and sc.sched_start_dt_tm between cnvtdatetime(start_datetime) and cnvtdatetime(end_datetime) ;002
	and sc.cancel_dt_tm is null
	and sc.active_ind = 1
 
order by
	scp.surg_case_id
	, scp.sched_primary_ind desc
	, scp.surg_case_proc_id
 
 
; populate record structure
head report
	cnt = 0
 
head scp.surg_case_id
	pcnt = 0
 
	cnt = cnt + 1
 
	call alterlist(surg_sched->qual, cnt)
 
	surg_sched->cnt									= cnt
	surg_sched->qual[cnt].encntr_id					= e.encntr_id
	surg_sched->qual[cnt].person_id					= e.person_id
	surg_sched->qual[cnt].sch_event_id				= se.sch_event_id
	surg_sched->qual[cnt].surg_case_id				= sc.surg_case_id
	surg_sched->qual[cnt].sched_start_dt_tm			= sc.sched_start_dt_tm
	surg_sched->qual[cnt].create_dt_tm				= sc.create_dt_tm
	surg_sched->qual[cnt].sched_dur					= sc.sched_dur
	surg_sched->qual[cnt].sched_surg_area			= trim(uar_get_code_display(sc.sched_surg_area_cd), 3)
	surg_sched->qual[cnt].sched_op_loc				= trim(uar_get_code_display(sc.sched_op_loc_cd), 3)
	surg_sched->qual[cnt].sched_pat_type			= trim(uar_get_code_display(sc.sched_pat_type_cd), 3)
	surg_sched->qual[cnt].sched_type				= trim(uar_get_code_display(sc.sched_type_cd), 3)
	surg_sched->qual[cnt].surg_case_nbr_formatted	= sc.surg_case_nbr_formatted
	surg_sched->qual[cnt].patient_name				= p.name_full_formatted
	surg_sched->qual[cnt].sex						= trim(uar_get_code_display(p.sex_cd), 3)
	surg_sched->qual[cnt].age						= cnvtage(cnvtdatetimeutc(datetimezone(p.birth_dt_tm, p.birth_tz), 1))
	surg_sched->qual[cnt].dob						= cnvtdatetimeutc(datetimezone(p.birth_dt_tm, p.birth_tz), 1)
	surg_sched->qual[cnt].loc_facility				= trim(uar_get_code_display(e.loc_facility_cd), 3)
	surg_sched->qual[cnt].loc_nurse_unit			= trim(uar_get_code_display(e.loc_nurse_unit_cd), 3)
	surg_sched->qual[cnt].loc_room					= trim(uar_get_code_display(e.loc_room_cd), 3)
	surg_sched->qual[cnt].loc_bed					= trim(uar_get_code_display(e.loc_bed_cd), 3)
	surg_sched->qual[cnt].encntr_type				= trim(uar_get_code_display(e.encntr_type_cd), 3)
	surg_sched->qual[cnt].prior_auth				= trim(od2.oe_field_display_value, 3)
	surg_sched->qual[cnt].medical_service			= trim(uar_get_code_display(e.med_service_cd), 3)
 
head scp.surg_case_proc_id
	pcnt = pcnt + 1
 
	call alterlist(surg_sched->qual[cnt].proc, pcnt)
 
	surg_sched->qual[cnt].proc_cnt								= pcnt
	surg_sched->qual[cnt].proc[pcnt].sched_primary_ind			= scp.sched_primary_ind
	surg_sched->qual[cnt].proc[pcnt].sched_ud1					= trim(uar_get_code_display(scp.sched_ud1_cd), 3)
 
	surg_sched->qual[cnt].proc[pcnt].sched_primary_surgeon_id	= scp.sched_primary_surgeon_id
	surg_sched->qual[cnt].proc[pcnt].sched_primary_surgeon		= per.name_full_formatted
	surg_sched->qual[cnt].proc[pcnt].procedure					= trim(ocs.mnemonic, 3)
	surg_sched->qual[cnt].proc[pcnt].proc_text					= trim(replace(scp.proc_text, build(char(13), char(10)), "; " ), 3)
	surg_sched->qual[cnt].proc[pcnt].inpat_only_proc			= trim(od.oe_field_display_value, 3)
	surg_sched->qual[cnt].proc[pcnt].sched_anesth_type			= trim(uar_get_code_display(scp.sched_anesth_type_cd), 3)
	surg_sched->qual[cnt].proc[pcnt].modifier					= trim(scp.modifier, 3)
	surg_sched->qual[cnt].proc[pcnt].od_modifier1				= trim(od3.oe_field_display_value, 3)
	surg_sched->qual[cnt].proc[pcnt].od_modifier2				= trim(od4.oe_field_display_value, 3)
	surg_sched->qual[cnt].proc[pcnt].od_modifier3				= trim(od5.oe_field_display_value, 3)
 
with nocounter, expand = 1
 
 
/**************************************************************/
; select scheduled event comment data
select into "nl:"
from
	(DUMMYT d1 with seq = surg_sched->cnt)
 
	, SCH_EVENT_COMM sec
 
	, LONG_TEXT lt
 
plan d1
 
join sec
where
	sec.sch_event_id = surg_sched->qual[d1.seq].sch_event_id
	and sec.sub_text_meaning = "SURGPUBLIC"
	and sec.version_dt_tm > sysdate
	and sec.active_ind = 1
 
join lt
where
	lt.long_text_id = sec.text_id
 
order by
	sec.sch_event_id
	, sec.sub_text_meaning
	, sec.beg_effective_dt_tm desc
 
 
; populate record structure
head sec.sch_event_id
	null
 
head sec.sub_text_meaning
	surg_sched->qual[d1.seq].surgery_comment = trim(replace(lt.long_text, build(char(13), char(10)), "; "), 3)
 
with nocounter
 
 
/**************************************************************/
; select encounter alias fin data
select into "nl:"
from
	(DUMMYT d1 with seq = surg_sched->cnt)
 
	, ENCNTR_ALIAS ea
 
plan d1
 
join ea
where
	ea.encntr_id = surg_sched->qual[d1.seq].encntr_id
	and ea.encntr_alias_type_cd = fin_var
	and ea.end_effective_dt_tm > sysdate
	and ea.active_ind = 1
 
order by
	ea.encntr_id
	, ea.beg_effective_dt_tm
 
 
; populate record structure
head ea.encntr_id
	null
 
detail
	surg_sched->qual[d1.seq].fin = ea.alias
 
with nocounter
 
 
/**************************************************************/
; select encounter alias mrn data
select into "nl:"
from
	(DUMMYT d1 with seq = surg_sched->cnt)
 
	, ENCNTR_ALIAS ea
 
plan d1
 
join ea
where
	ea.encntr_id = surg_sched->qual[d1.seq].encntr_id
	and ea.encntr_alias_type_cd = mrn_var
	and ea.end_effective_dt_tm > sysdate
	and ea.active_ind = 1
 
order by
	ea.encntr_id
	, ea.beg_effective_dt_tm
 
 
; populate record structure
head ea.encntr_id
	null
 
detail
	surg_sched->qual[d1.seq].mrn = ea.alias
 
with nocounter
 
 
/**************************************************************/
; select health plan data
select into "nl:"
from
	(DUMMYT d1 with seq = surg_sched->cnt)
 
	, ENCNTR_PLAN_RELTN epr
 
	, ENCNTR_PLAN_AUTH_R epar
 
	, AUTHORIZATION au
 
	, HEALTH_PLAN hp
 
plan d1
 
join epr
where
	epr.encntr_id = surg_sched->qual[d1.seq].encntr_id
	and epr.priority_seq in (1, 2)
	and epr.end_effective_dt_tm > sysdate
	and epr.active_ind = 1
 
join epar
where
	epar.encntr_plan_reltn_id = outerjoin(epr.encntr_plan_reltn_id)
	and epar.active_ind = outerjoin(1)
 
join au
where
	au.authorization_id = outerjoin(epar.authorization_id)
	and au.active_ind = outerjoin(1)
 
join hp
where
	hp.health_plan_id = epr.health_plan_id
 
 
; populate record structure
head epr.encntr_id
	null
 
detail
	case (epr.priority_seq)
		of 1:	surg_sched->qual[d1.seq].ins_primary_plan_name		= hp.plan_name
				surg_sched->qual[d1.seq].ins_primary_auth_nbr		= trim(au.auth_nbr, 3)
		of 2:	surg_sched->qual[d1.seq].ins_secondary_plan_name	= hp.plan_name
				surg_sched->qual[d1.seq].ins_secondary_auth_nbr		= trim(au.auth_nbr, 3)
	endcase
 
with nocounter
 
 
/**************************************************************/
; select pathway data ;001
select into "nl:"
from
	(DUMMYT d1 with seq = surg_sched->cnt)
 
	, ACT_PW_COMP apc 
	, PATHWAY_COMP pcomp 
	, PATHWAY pw	
	, PRSNL per 
	, PATHWAY_CATALOG pcat	
	, ORDER_CATALOG_SYNONYM ocs	
	, ORDER_CATALOG oc	
	, ORDER_PROPOSAL op	
	, ORDER_SENTENCE os
 
plan d1
 
join apc
where
	apc.encntr_id = surg_sched->qual[d1.seq].encntr_id
	and apc.included_ind = 1
	and apc.activated_ind = 0
	and apc.active_ind = 1
 
join pcomp
where
	pcomp.pathway_comp_id = apc.pathway_comp_id
 
join pw
where
	pw.pathway_id = apc.pathway_id
	and pw.pw_status_cd in (planned_var, proposed_var, plannedproposed_var)
	
	
join per 
where
	per.person_id = pw.updt_id
	and per.active_ind = 1
 
join pcat
where
	pcat.pathway_catalog_id = pw.pathway_catalog_id
 
join ocs
where
	ocs.synonym_id = apc.ref_prnt_ent_id
 
join oc
where
	oc.catalog_cd = ocs.catalog_cd
	and oc.catalog_cd in (
		select cv.code_value
		from CODE_VALUE cv
		where
			cv.code_set = 200
			and cv.display_key in ("PSO*", "ADJ*PSO*")
			and cv.active_ind = 1
	)
 
join op
where
	op.order_proposal_id = outerjoin(apc.parent_entity_id)
 
join os
where
	os.order_sentence_id = outerjoin(apc.order_sentence_id)
	
order by
	apc.encntr_id
	, pw.pathway_id
	, pcomp.pathway_comp_id
 
 
; populate record structure
head apc.encntr_id
	cnt = 0
 
head pw.pathway_id
	pcnt = 0
	
	cnt = cnt + 1
 
	call alterlist(surg_sched->qual[d1.seq].pw, cnt)
 
	surg_sched->qual[d1.seq].pw_cnt 				= cnt
	surg_sched->qual[d1.seq].pw[cnt].pathway_id		= pw.pathway_id
	
	surg_sched->qual[d1.seq].pw[cnt].power_plan = 
		if (pw.type_mean = "CAREPLAN")
			trim(pw.description) 
		else 
			trim(pw.pw_group_desc) 
		endif
		
	surg_sched->qual[d1.seq].pw[cnt].phase = 
		if (pw.type_mean = "PHASE" and pcat.sub_phase_ind = 0) 
			trim(pw.description)
		elseif ((pw.type_mean = "SUBPHASE") and (pcat.sub_phase_ind = 1)) 
			trim(pw.parent_phase_desc)
		endif
		
	surg_sched->qual[d1.seq].pw[cnt].sub_phase 		= 
		if (pw.type_mean = "SUBPHASE") trim(pw.description) endif
		
	surg_sched->qual[d1.seq].pw[cnt].status 		= uar_get_code_display(pw.pw_status_cd)
	
	surg_sched->qual[d1.seq].pw[cnt].updt_dt_tm 	= pw.updt_dt_tm
	surg_sched->qual[d1.seq].pw[cnt].updt_id 		= pw.updt_id
	surg_sched->qual[d1.seq].pw[cnt].updt_by 		= per.name_full_formatted
	
head pcomp.pathway_comp_id
	pcnt = pcnt + 1
 
	call alterlist(surg_sched->qual[d1.seq].pw[cnt].pcomp, pcnt)
 
	surg_sched->qual[d1.seq].pw[cnt].pcomp_cnt						= pcnt
	surg_sched->qual[d1.seq].pw[cnt].pcomp[pcnt].pathway_comp_id	= pcomp.pathway_comp_id
	surg_sched->qual[d1.seq].pw[cnt].pcomp[pcnt].order_mnemonic		= trim(ocs.mnemonic)
	
	surg_sched->qual[d1.seq].pw[cnt].pcomp[pcnt].order_sentence		= 
		if (apc.parent_entity_name = "ORDERS") 
			trim(os.order_sentence_display_line)
		elseif (apc.parent_entity_name = "PROPOSAL") 
			trim(op.clinical_display_line)
		endif
	
	surg_sched->qual[d1.seq].pw[cnt].pcomp[pcnt].order_sentence		=
		if (trim(surg_sched->qual[d1.seq].pw[cnt].pcomp[pcnt].order_sentence, 3) = "0") "" endif
 
with nocounter
 
 
call echorecord(surg_sched)


/**************************************************************/
; select data

;002
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set modify filestream
	
	select distinct into value(output_var)
		org_name						= substring(1, 100, surg_sched->org_name)
		, start_dt_tm					= format(surg_sched->start_dt_tm, "mm/dd/yyyy hh:mm;;q")
		, end_dt_tm						= format(surg_sched->end_dt_tm, "mm/dd/yyyy hh:mm;;q")
		, printed_by					= substring(1, 100, surg_sched->printed_by)
		, sched_start_dt_tm				= format(surg_sched->qual[d1.seq].sched_start_dt_tm, "mm/dd/yyyy hh:mm;;q")
		, sched_start_dt				= format(surg_sched->qual[d1.seq].sched_start_dt_tm, "yyyy/mm/dd;;d")
		, sched_dur						= surg_sched->qual[d1.seq].sched_dur
		, sched_surg_area				= trim(surg_sched->qual[d1.seq].sched_surg_area, 3)
		, sched_op_loc					= trim(surg_sched->qual[d1.seq].sched_op_loc, 3)
		, sched_pat_type				= trim(surg_sched->qual[d1.seq].sched_pat_type, 3)
		, sched_type					= trim(surg_sched->qual[d1.seq].sched_type, 3)
		, surg_case_nbr_formatted		= substring(1, 30, surg_sched->qual[d1.seq].surg_case_nbr_formatted)
		, patient_name					= substring(1, 100, surg_sched->qual[d1.seq].patient_name)
		, sex							= trim(surg_sched->qual[d1.seq].sex, 3)
		, age							= trim(surg_sched->qual[d1.seq].age, 3)
		, dob							= format(surg_sched->qual[d1.seq].dob, "mm/dd/yyyy;;d")
		, loc_nurse_unit				= trim(surg_sched->qual[d1.seq].loc_nurse_unit, 3)
		, loc_facility					= trim(surg_sched->qual[d1.seq].loc_facility, 3)
		, loc_room						= trim(surg_sched->qual[d1.seq].loc_room, 3)
		, loc_bed						= trim(surg_sched->qual[d1.seq].loc_bed, 3)
		, encntr_type					= trim(surg_sched->qual[d1.seq].encntr_type, 3)
		, fin							= substring(1, 20, surg_sched->qual[d1.seq].fin)
		, mrn							= substring(1, 20, surg_sched->qual[d1.seq].mrn)
		, prior_auth					= trim(surg_sched->qual[d1.seq].prior_auth, 3)
		, surgery_comment				= trim(surg_sched->qual[d1.seq].surgery_comment, 3)
		, phone							= substring(1, 30, surg_sched->qual[d1.seq].phone)
		, phone_type					= trim(surg_sched->qual[d1.seq].phone_type, 3)
		, alt_phone						= substring(1, 30, surg_sched->qual[d1.seq].alt_phone)
		, alt_phone_type				= trim(surg_sched->qual[d1.seq].alt_phone_type, 3)
		, medical_service				= trim(surg_sched->qual[d1.seq].medical_service, 3)
		, ins_primary_plan_name			= trim(surg_sched->qual[d1.seq].ins_primary_plan_name, 3)
		, ins_primary_auth_nbr			= trim(surg_sched->qual[d1.seq].ins_primary_auth_nbr, 3)
		, ins_secondary_plan_name		= trim(surg_sched->qual[d1.seq].ins_secondary_plan_name, 3)
		, ins_secondary_auth_nbr		= trim(surg_sched->qual[d1.seq].ins_secondary_auth_nbr, 3)
		, sched_primary_ind				= surg_sched->qual[d1.seq].proc[d2.seq].sched_primary_ind
		, sched_ud1						= trim(surg_sched->qual[d1.seq].proc[d2.seq].sched_ud1, 3)
		, sched_primary_surgeon_id		= surg_sched->qual[d1.seq].proc[d2.seq].sched_primary_surgeon_id
		, sched_primary_surgeon			= surg_sched->qual[d1.seq].proc[d2.seq].sched_primary_surgeon
		, procedure						= trim(surg_sched->qual[d1.seq].proc[d2.seq].procedure, 3)
		, proc_text						= trim(surg_sched->qual[d1.seq].proc[d2.seq].proc_text, 3)
		, inpat_only_proc				= trim(surg_sched->qual[d1.seq].proc[d2.seq].inpat_only_proc, 3)
		, sched_anesth_type				= trim(surg_sched->qual[d1.seq].proc[d2.seq].sched_anesth_type, 3)
		, modifier						= trim(surg_sched->qual[d1.seq].proc[d2.seq].modifier, 3)
		, od_modifier1					= trim(surg_sched->qual[d1.seq].proc[d2.seq].od_modifier1, 3)
		, od_modifier2					= trim(surg_sched->qual[d1.seq].proc[d2.seq].od_modifier2, 3)
		, od_modifier3					= trim(surg_sched->qual[d1.seq].proc[d2.seq].od_modifier3, 3)
		, surg_case_id					= surg_sched->qual[d1.seq].surg_case_id
		, pathway_id					= surg_sched->qual[d1.seq].pw[d3.seq].pathway_id
		, power_plan					= trim(surg_sched->qual[d1.seq].pw[d3.seq].power_plan, 3)
		, phase							= trim(surg_sched->qual[d1.seq].pw[d3.seq].phase, 3)
		, sub_phase						= trim(surg_sched->qual[d1.seq].pw[d3.seq].sub_phase, 3)
		, status						= trim(surg_sched->qual[d1.seq].pw[d3.seq].status, 3)
		, updt_dt_tm					= format(surg_sched->qual[d1.seq].pw[d3.seq].updt_dt_tm, "mm/dd/yyyy hh:mm;;q")
		, updt_by						= trim(surg_sched->qual[d1.seq].pw[d3.seq].updt_by, 3)
		, pathway_comp_id				= surg_sched->qual[d1.seq].pw[d3.seq].pcomp[d4.seq].pathway_comp_id
		, order_mnemonic				= trim(surg_sched->qual[d1.seq].pw[d3.seq].pcomp[d4.seq].order_mnemonic, 3)
		, order_sentence				= trim(surg_sched->qual[d1.seq].pw[d3.seq].pcomp[d4.seq].order_sentence, 3)
	
	from
		(dummyt d1 with seq = value(surg_sched->cnt))
		, (dummyt d2 with seq = 1)
		, (dummyt d3 with seq = 1)
		, (dummyt d4 with seq = 1)
	
	plan d1
	where
		maxrec(d2, surg_sched->qual[d1.seq].proc_cnt)	
		and maxrec(d3, surg_sched->qual[d1.seq].pw_cnt)
		
	join d2
	
	join d3 
	where 
		maxrec(d4, surg_sched->qual[d1.seq].pw[d3.seq].pcomp_cnt)
	
	join d4
	
	order by
		sched_start_dt
		, sched_surg_area
		, patient_name
		, sched_primary_ind desc
		, surg_case_id
		, pathway_id
		, pathway_comp_id
	
	with nocounter, outerjoin = d2, pcformat (^"^, ^,^, 1), format = stream, format, time = 600

 
	; copy file to AStream
	if (validate(request->batch_selection) = 1 or $output_file = 1)
		set cmd = build2("cp ", temppath2_var, " ", filepath_var)
		set len = size(trim(cmd))
	 
		call dcl(cmd, len, stat)
		call echo(build2(cmd, " : ", stat))
	endif
endif

 
end
go
