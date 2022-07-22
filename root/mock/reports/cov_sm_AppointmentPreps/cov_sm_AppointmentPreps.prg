/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		01/20/2022
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_AppointmentPreps.prg
	Object name:		cov_sm_AppointmentPreps
	Request #:			11990, 12349, 12995
 
	Program purpose:	Lists scheduled appointments with preps for selected CMRN.
 
	Executing from:		CCL
 
 	Special Notes:		Used by external apps.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	03/07/2022	Todd A. Blanchard		Changed practice site display to org name.
002	06/02/2022	Todd A. Blanchard		Added outbound alias for appointment type synonym.
 	
******************************************************************************/
 
drop program cov_sm_AppointmentPreps:DBA go
create program cov_sm_AppointmentPreps:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "CMRN" = "" 

with OUTDEV, CMRN
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare start_datetime			= dq8 with noconstant(cnvtdatetime(curdate, 000000))

declare ssn_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 4, "SSN"))
declare cmrn_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 4, "COMMUNITYMEDICALRECORDNUMBER"))
declare fin_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare mrn_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "MRN"))
;declare personnel_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 213, "PERSONNEL"))
;declare order_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "ORDER"))
declare contrib_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 13016, "ORDCAT"))
declare bill_item_type_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 13019, "BILLCODE"))
declare cpt_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 14002, "CPT"))
declare cpt4_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 400, "CPT4"))
declare attach_type_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 16110, "ORDER"))
declare stardoc_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 263, "STARDOCTORNUMBER"))
declare covenant_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 73, "COVENANT"))
declare patient_friendly_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 73, "PATIENTFRIENDLYDISPLAY")) ;002
;declare physician_order_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "PHYSICIANORDER"))
;declare outside_order_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "OUTSIDEORDER"))

declare num						= i4 with noconstant(0)
declare crlf					= vc with constant(build(char(13), char(10)))
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
record sched_appt (
	1 sched_cnt				= i4
	1 list[*]
		2 sch_appt_id		= f8
		2 appt_dt_tm		= dq8
		2 resource			= c40
		2 location			= c40
		2 org_name			= c100
		2 facility			= c1
 
		2 schedule_id			= f8
		2 sch_event_id			= f8
		2 appt_type				= c40
		2 appt_type_alias		= c100 ;002
		2 sch_state				= c12
		2 reason_exam			= c100
		2 order_phy				= c100
		2 order_phy_id			= c20
		2 ord_phys_group		= c100
		2 practice_site_id		= f8
 
		2 proc_cnt					= i4
		2 procedures[*]
			3 order_id				= f8
			3 catalog_cd			= f8
			3 order_mnemonic		= c100
			3 order_dt_tm			= dq8
			3 order_comment			= c255
			3 cpt_cd				= c10
			3 cpt_desc				= c100
		
			3 prep_cnt				= i4
			3 preparations[*]
				4 preparation		= c100
				4 prep_text 		= c2048
 
		2 person_id			= f8
		2 patient_name		= c100
		2 ssn				= c11
		2 dob				= dq8
		2 dob_tz			= i4
		2 language			= c40
 
 		2 encntr_id			= f8
 		2 encntr_type		= c40
		2 fin				= c20
		2 mrn				= c20
		2 cmrn				= c20
		2 icd10				= c50
		2 icd10_desc		= c255
		2 health_plan		= c100
		2 comment			= c255
		
		2 prep_cnt				= i4
		2 preparations[*]
			3 preparation		= c100
			3 prep_text			= c2048
		
;		2 guide_cnt				= i4
;		2 guidelines[*]
;			3 guideline			= c100
;			3 guide_text		= c2048
)

record final_data (
	1 cnt						= i4
	1 list[*]
		2 person_id				= f8
		2 patient_name			= c100
		2 cmrn					= c20
		2 mrn					= c20
		2 fin					= c20
		2 org_name				= c100
		2 facility				= c1
	
		2 dob					= dq8									
		2 ssn					= c11
		2 language				= c40
									
		2 encntr_type			= c40
		
		2 order_id				= f8
		2 order_mnemonic		= c100
		2 order_phy_id			= c20
		2 order_phy				= c100
		2 ord_phys_group		= c100
		2 cpt_cd				= c10
		2 cpt_desc				= c100
		2 icd10					= c50
		2 icd10_desc			= c255
		2 order_comment			= c255
		
		2 order_preparation		= c100
		2 order_prep_text		= c2048
	
		2 health_plan			= c100
		2 sch_state				= c12
		2 location				= c40
		2 resource				= c40
		2 appt_dt_tm			= dq8
		2 appt_type				= c40
		2 appt_type_alias		= c100 ;002
		2 reason_exam			= c100
		2 comment				= c255
		
		2 preparation			= c100
		2 prep_text				= c2048
)


/**************************************************************/
; select scheduled appointment data - primary data set
select into "NL:"
from
 	; scheduled patient
	SCH_APPT sa
 
 	; scheduled resource
	, (inner join SCH_APPT sar on sar.sch_event_id = sa.sch_event_id
		and sar.schedule_id = sa.schedule_id
		and sar.beg_dt_tm >= cnvtdatetime(start_datetime)
		and sar.role_meaning != "PATIENT"
		and sar.sch_state_cd > 0.0
		and sar.primary_role_ind = 1
		and sar.active_ind = 1)
		
	; last confirm
	, (inner join SCH_EVENT_ACTION seva on seva.sch_event_id = sa.sch_event_id
		and seva.schedule_id = sa.schedule_id
		and seva.action_meaning = "CONFIRM"
		and seva.action_dt_tm = (
			select max(seva2.action_dt_tm)
			from SCH_EVENT_ACTION seva2
			where
				seva2.sch_event_id = seva.sch_event_id
				and seva2.schedule_id = seva.schedule_id
				and seva2.action_meaning = "CONFIRM"
				and seva2.active_ind = 1
			group by
				seva2.sch_event_id
				, seva2.schedule_id
		)
		and seva.active_ind = 1
		)
 
;	, (inner join PRSNL per_seva on per_seva.person_id = seva.action_prsnl_id)
 
 	; encounter
	, (inner join ENCOUNTER e on e.encntr_id = sa.encntr_id
		and e.person_id = sa.person_id
		and e.active_ind = 1)
 
	, (left join ENCNTR_ALIAS eaf on eaf.encntr_id = e.encntr_id
		and eaf.encntr_alias_type_cd = fin_var
		and eaf.active_ind = 1)
 
	, (left join ENCNTR_ALIAS eam on eam.encntr_id = e.encntr_id
		and eam.encntr_alias_type_cd = mrn_var
		and eam.active_ind = 1)
 
 	; patient
	, (inner join PERSON p on p.person_id = sa.person_id
		and p.active_ind = 1)

	, (left join PERSON_ALIAS pas on pas.person_id = p.person_id
		and pas.person_alias_type_cd = ssn_var
		and pas.person_alias_id > 0.0
		and pas.active_ind = 1)
	
	, (inner join PERSON_ALIAS pac on pac.person_id = p.person_id
		and pac.person_alias_type_cd = cmrn_var
		and pac.person_alias_id > 0.0
		and pac.alias = $CMRN
		and pac.active_ind = 1)
 
	; patient location
	, (inner join LOCATION l on l.location_cd = sa.appt_location_cd)
 
 	; encounter organization
	, (inner join ORGANIZATION org on org.organization_id = e.organization_id)
	
	, (inner join LOCATION l2 on l2.organization_id = org.organization_id)
 
	, (inner join CODE_VALUE_OUTBOUND cvo on cvo.code_value = l2.location_cd
		and cvo.code_set = 220
		and cvo.alias_type_meaning = "FACILITY"
		and cvo.contributor_source_cd = covenant_var)
 
where
	sa.beg_dt_tm >= cnvtdatetime(start_datetime)
	and sa.role_meaning = "PATIENT"
	and sa.state_meaning = "CONFIRMED"
	and sa.active_ind = 1
 
order by
	sa.sch_appt_id
 
 
; populate sched_appt record structure
head report
	cnt = 0
 
	call alterlist(sched_appt->list, 100)
 
head sa.sch_appt_id
	cnt = cnt + 1
 
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(sched_appt->list, cnt + 9)
	endif
 
	sched_appt->sched_cnt							= cnt
	sched_appt->list[cnt].sch_appt_id				= sa.sch_appt_id
	sched_appt->list[cnt].appt_dt_tm				= sa.beg_dt_tm
	sched_appt->list[cnt].resource					= trim(uar_get_code_display(sar.resource_cd), 3)
	sched_appt->list[cnt].location					= trim(uar_get_code_display(sa.appt_location_cd), 3)
	sched_appt->list[cnt].org_name					= trim(org.org_name, 3)
	sched_appt->list[cnt].facility					= trim(cvo.alias, 3)
	
	sched_appt->list[cnt].schedule_id				= sa.schedule_id
	sched_appt->list[cnt].sch_event_id				= sa.sch_event_id
	sched_appt->list[cnt].sch_state					= trim(sa.state_meaning, 3)
		
	sched_appt->list[cnt].encntr_id					= e.encntr_id
	sched_appt->list[cnt].encntr_type				= trim(uar_get_code_display(e.encntr_type_cd), 3)

	sched_appt->list[cnt].fin						= trim(eaf.alias, 3)
	sched_appt->list[cnt].mrn						= trim(cnvtalias(eam.alias, eam.alias_pool_cd), 3)
	
	sched_appt->list[cnt].person_id					= p.person_id
	sched_appt->list[cnt].patient_name				= p.name_full_formatted
	sched_appt->list[cnt].ssn						= trim(pas.alias, 3)
	sched_appt->list[cnt].cmrn						= trim(pac.alias, 3)
	sched_appt->list[cnt].dob						= p.birth_dt_tm
	sched_appt->list[cnt].dob_tz					= p.birth_tz
	sched_appt->list[cnt].language					= trim(uar_get_code_display(p.language_cd), 3)
 
foot report
	call alterlist(sched_appt->list, cnt)
 
WITH nocounter, time = 60

;call echorecord(sched_appt)
;
;go to exitscript


/**************************************************************/
; select additional scheduled appointment data
select into "NL:"
from
 	; scheduled event
	SCH_APPT sa	
	
	, (inner join SCH_EVENT sev on sev.sch_event_id = sa.sch_event_id
		and sev.sch_state_cd > 0.0
		and sev.active_ind = 1)
	
	;002
	, (left join CODE_VALUE_OUTBOUND cvo on cvo.code_value = sev.appt_synonym_cd
		and cvo.code_set = 14249
		and cvo.contributor_source_cd = patient_friendly_var)
 
 	; reason for exam
	, (left join SCH_EVENT_DETAIL sed1 on sed1.sch_event_id = sev.sch_event_id
		and sed1.oe_field_meaning = "REASONFOREXAM"
		and sed1.active_ind = 1)
 
 	; ordering physician
	, (left join SCH_EVENT_DETAIL sed2 on sed2.sch_event_id = sev.sch_event_id
		and sed2.oe_field_meaning = "SCHORDPHYS"
		and sed2.active_ind = 1)
 
	, (left join PRSNL per2 on per2.person_id = sed2.oe_field_value
		and per2.active_ind = 1)
 
	, (left join PRSNL_ALIAS pera2 on pera2.person_id = per2.person_id
		and pera2.alias_pool_cd = stardoc_var
		and pera2.active_ind = 1)
 
	; first practice site
	, (left join PRSNL_RELTN pr on pr.person_id = per2.person_id
		and pr.parent_entity_name = "PRACTICE_SITE"
		and pr.active_ind = 1
		and pr.parent_entity_id = (
			select min(pr2.parent_entity_id)
			from PRSNL_RELTN pr2
			where
				pr2.person_id = pr.person_id
				and pr2.parent_entity_name = pr.parent_entity_name
				and pr2.active_ind = pr.active_ind
			group by
				pr2.person_id
		))
 
	, (left join PRACTICE_SITE ps on ps.practice_site_id = pr.parent_entity_id)
 
	, (left join ORGANIZATION org on org.organization_id = ps.organization_id) ;001

	; comments
	, (left join SCH_EVENT_DETAIL sed3 on sed3.sch_event_id = sev.sch_event_id
		and sed3.oe_field_meaning in ("SPECINX")
		and sed3.active_ind = 1)
 
 	; encounter
	, (inner join ENCOUNTER e on e.encntr_id = sa.encntr_id
		and e.person_id = sa.person_id
		and e.active_ind = 1)
	
	; diagnosis
	, (left join DIAGNOSIS d on d.encntr_id = e.encntr_id
		and d.active_ind = 1)
	
	, (left join NOMENCLATURE n on n.nomenclature_id = d.nomenclature_id
		and n.source_vocabulary_cd in (
			select cv.code_value
			from CODE_VALUE cv
			where
				cv.code_set = 400
				and cv.display_key in ("ICD10*")
				and cv.active_ind = 1
		))
 
 	; health plan
	, (left join ENCNTR_PLAN_RELTN epr on epr.encntr_id = e.encntr_id
		and epr.priority_seq = 1
		and epr.end_effective_dt_tm > sysdate
		and epr.active_ind = 1)
 	
	, (left join HEALTH_PLAN hp on hp.health_plan_id = epr.health_plan_id)

where
	expand(num, 1, sched_appt->sched_cnt, sa.sch_appt_id, sched_appt->list[num].sch_appt_id,
		sev.sch_event_id, sched_appt->list[num].sch_event_id)

order by
	sa.sch_appt_id
	, sev.sch_event_id
 
 
; populate sched_appt record structure
head sa.sch_appt_id
	idx = 0
	numx = 0
	
	idx = locateval(numx, 1, sched_appt->sched_cnt, sa.sch_appt_id, sched_appt->list[numx].sch_appt_id,
		sev.sch_event_id, sched_appt->list[numx].sch_event_id)
	
detail 
	sched_appt->list[idx].appt_type					= trim(uar_get_code_display(sev.appt_type_cd), 3)
	sched_appt->list[idx].appt_type_alias			= trim(cvo.alias, 3) ;002
	sched_appt->list[idx].reason_exam				= trim(replace(sed1.oe_field_display_value, crlf, " ", 4), 3);	

	sched_appt->list[idx].order_phy					= trim(sed2.oe_field_display_value, 3)
	sched_appt->list[idx].order_phy_id				= trim(pera2.alias, 3)
	sched_appt->list[idx].ord_phys_group			= trim(org.org_name, 3) ;001
	sched_appt->list[idx].practice_site_id			= ps.practice_site_id
	
	sched_appt->list[idx].icd10						= trim(n.source_identifier, 3)
	sched_appt->list[idx].icd10_desc				= trim(n.source_string, 3)
	
	sched_appt->list[idx].health_plan				= trim(hp.plan_name, 3)								  

 	comment = fillstring(255, " ") 	
	comment	= trim(sed3.oe_field_display_value, 3)
	comment = replace(comment, char(13), " ", 4)
	comment = replace(comment, char(10), " ", 4)
	comment = replace(comment, char(0), " ", 4)	

	sched_appt->list[idx].comment					= trim(comment, 3)
 
WITH nocounter, expand = 1, time = 60
 
 
/**************************************************************/
; select scheduled procedures data
select into "NL:"
from	
	SCH_APPT sa
	
	, (inner join SCH_EVENT_ATTACH sea on sea.sch_event_id = sa.sch_event_id
		and sea.attach_type_cd = attach_type_var
		and sea.order_status_meaning not in ("CANCELED", "DISCONTINUED")
		and sea.active_ind = 1)
 
	, (inner join ORDERS o on o.order_id = sea.order_id
		and o.active_ind = 1)
		
	, (left join ORDER_DETAIL od4 on od4.order_id = o.order_id
		and od4.oe_field_meaning = "SPECINX"
		and od4.action_sequence = (
			select max(od42.action_sequence)
			from ORDER_DETAIL od42
			where 
				od42.order_id = od4.order_id
				and od42.oe_field_meaning = "SPECINX"
			group by
				od42.order_id
		))
		
	, (left join ORDER_CATALOG ocat on ocat.catalog_cd = o.catalog_cd
		and ocat.active_ind = 1)
	
	, (left join BILL_ITEM bi on bi.ext_parent_reference_id = ocat.catalog_cd
		and bi.ext_parent_contributor_cd = contrib_var
		and bi.ext_owner_cd = ocat.activity_type_cd
		and bi.ext_child_reference_id = 0.0
		and bi.parent_qual_cd = 1.0
		and bi.active_ind = 1)
 
	, (left join BILL_ITEM_MODIFIER bim on bim.bill_item_id = bi.bill_item_id
		and bim.bill_item_type_cd = bill_item_type_var
		and bim.key1_id = cpt_var
		and bim.beg_effective_dt_tm < cnvtdatetime(curdate, curtime3)
		and bim.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
		and bim.active_ind = 1)
		
	, (left join NOMENCLATURE n on n.nomenclature_id = bim.key3_id
		and n.source_vocabulary_cd = cpt4_var
		and n.active_ind = 1)
 
where
	expand(num, 1, sched_appt->sched_cnt, sa.sch_appt_id, sched_appt->list[num].sch_appt_id,
		sea.sch_event_id, sched_appt->list[num].sch_event_id)
 
order by
	sa.sch_appt_id
	, sea.sch_event_id
	, o.order_id
 
 
; populate sched_appt record structure with procedure data	
head sa.sch_appt_id
	cntx = 0
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, sched_appt->sched_cnt, sa.sch_appt_id, sched_appt->list[numx].sch_appt_id,
		sea.sch_event_id, sched_appt->list[numx].sch_event_id)
	
detail
	cntx = cntx + 1
 
	call alterlist(sched_appt->list[idx].procedures, cntx)
 
 	sched_appt->list[idx].proc_cnt								= cntx
	sched_appt->list[idx].procedures[cntx].order_id				= o.order_id
	sched_appt->list[idx].procedures[cntx].catalog_cd			= o.catalog_cd
	sched_appt->list[idx].procedures[cntx].order_mnemonic		= trim(o.order_mnemonic, 3)
	sched_appt->list[idx].procedures[cntx].order_dt_tm			= o.current_start_dt_tm
  
 	comment = fillstring(255, " ") 	
	comment	= trim(od4.oe_field_display_value, 3)
	comment = replace(comment, char(13), " ", 4)
	comment = replace(comment, char(10), " ", 4)
	comment = replace(comment, char(0), " ", 4)
	
	sched_appt->list[idx].procedures[cntx].order_comment 		= trim(comment, 3)
	
	sched_appt->list[idx].procedures[cntx].cpt_cd				= trim(bim.key6, 3)
	sched_appt->list[idx].procedures[cntx].cpt_desc				= trim(n.source_string, 3)
	
WITH nocounter, expand = 1, time = 60

;call echorecord(sched_appt)

;go to exitscript


/**************************************************************/
; select appointment type preparation data
select distinct into "NL:"
	sa.sch_appt_id
	, sev.sch_event_id
	, sat.appt_type_cd
	, sal.location_cd
	, accept_format 	= decode(oef.seq, oef.oe_format_name)
	, preparation 		= decode(st.seq, st.mnemonic)
	, prep_text 		= decode(st.seq, substring(1, 2048, ltr.long_text))
	, prep_flexing 		= decode(sfs.seq, sfs.mnemonic)
	
from
	SCH_APPT sa	
	
	, (inner join SCH_EVENT sev on sev.sch_event_id = sa.sch_event_id
		and sev.sch_state_cd > 0.0
		and sev.active_ind = 1)
	
	, (inner join SCH_APPT_TYPE sat on sat.appt_type_cd = sev.appt_type_cd
		and	sat.description not in (" *")
		and sat.active_ind = 1)
	
	, (inner join SCH_APPT_LOC sal on sal.appt_type_cd = sat.appt_type_cd
		and sal.location_cd = sa.appt_location_cd)
	
	, (left join ORDER_ENTRY_FORMAT oef on oef.oe_format_id = sat.oe_format_id)
	
	, (left join SCH_TEXT_LINK stl on stl.parent2_id = sal.location_cd
		and	stl.parent_id = sat.appt_type_cd
		and	stl.text_type_meaning = "PREAPPT"
		and	stl.active_ind = 1)
	
	, (left join SCH_SUB_LIST ssl on ssl.parent_table = "SCH_TEXT_LINK"
		and ssl.parent_id = stl.text_link_id
		and ssl.active_ind = 1)
	
	, (left join SCH_TEMPLATE st on st.template_id = ssl.template_id)
	
	, (left join LONG_TEXT_REFERENCE ltr on ltr.long_text_id = st.text_id)
	
	, (left join SCH_FLEX_STRING sfs on sfs.sch_flex_id = ssl.sch_flex_id)

	, (dummyt d)
	
plan d

join sa
join sev
join sat
join sal
join oef
join stl
join ssl
join st
join ltr
join sfs

where 
	expand(num, 1, sched_appt->sched_cnt, sa.sch_appt_id, sched_appt->list[num].sch_appt_id,
		sev.sch_event_id, sched_appt->list[num].sch_event_id)

order by
	sa.sch_appt_id
	, sev.sch_event_id
	, sat.appt_type_cd
	, sal.location_cd
	, accept_format
	, preparation
	, prep_text
	, prep_flexing
 
 
; populate sched_appt record structure
head sa.sch_appt_id
	idx = 0
	numx = 0
	cnt = 0
	
	idx = locateval(numx, 1, sched_appt->sched_cnt, sa.sch_appt_id, sched_appt->list[numx].sch_appt_id,
		sev.sch_event_id, sched_appt->list[numx].sch_event_id)
		
detail
	cnt = cnt + 1
	
	call alterlist(sched_appt->list[idx].preparations, cnt)
	
	sched_appt->list[idx].prep_cnt								= cnt	
	sched_appt->list[idx].preparations[cnt].preparation			= trim(replace(preparation, crlf, " ", 4), 3)
	sched_appt->list[idx].preparations[cnt].prep_text			= trim(replace(prep_text, crlf, " ", 4), 3)
	
with nocounter, expand = 1, time = 60


/**************************************************************/
; select orderable preparation data
select distinct into "NL:"
	sa.sch_appt_id
	, sev.sch_event_id
	, o.order_id
	, oc.catalog_cd
	, sat.appt_type_cd
	, sol.location_cd
	, preparation 		= decode(st.seq, st.mnemonic)
	, prep_text 		= decode(st.seq, substring(1, 2048, ltr.long_text))
	
from
	SCH_APPT sa	
	
	, (inner join SCH_EVENT sev on sev.sch_event_id = sa.sch_event_id
		and sev.sch_state_cd > 0.0
		and sev.active_ind = 1)
	
	, (inner join SCH_EVENT_ATTACH sea on sea.sch_event_id = sev.sch_event_id
		and sea.attach_type_cd = attach_type_var
		and sea.order_status_meaning not in ("CANCELED", "DISCONTINUED")
		and sea.active_ind = 1)
 
	, (inner join ORDERS o on o.order_id = sea.order_id
		and o.active_ind = 1)
	
	, (inner join SCH_ORDER_APPT soa on soa.appt_type_cd = sev.appt_type_cd
		and soa.catalog_cd = o.catalog_cd
		and soa.active_ind = 1)
	
	, (left join SCH_APPT_TYPE sat on sat.appt_type_cd = soa.appt_type_cd
		and	sat.description not in (" *")
		and sat.active_ind = 1)
	
	, (inner join ORDER_CATALOG oc on oc.catalog_cd = soa.catalog_cd
		and	oc.primary_mnemonic not in ("ZZ*")
		and	oc.primary_mnemonic not in ("zz*"))
	
	, (inner join SCH_ORDER_LOC sol on sol.catalog_cd = oc.catalog_cd
		and sol.location_cd = sa.appt_location_cd)
	
	, (left join SCH_TEXT_LINK stl on stl.parent2_id = sol.location_cd
		and	stl.parent_id = soa.catalog_cd
		and	stl.text_type_meaning = "PREAPPT"
		and	stl.active_ind = 1)
	
	, (left join SCH_SUB_LIST ssl on ssl.parent_table = "SCH_TEXT_LINK"
		and ssl.parent_id = stl.text_link_id
		and ssl.active_ind = 1)
	
	, (left join SCH_TEMPLATE st on st.template_id = ssl.template_id)
	
	, (left join LONG_TEXT_REFERENCE ltr on ltr.long_text_id = st.text_id)

	, (dummyt d)
	
plan d

join sa
join sev
join sea
join o
join sat
join sol
join soa
join oc
join stl
join ssl
join st
join ltr

where 
	expand(num, 1, sched_appt->sched_cnt, sa.sch_appt_id, sched_appt->list[num].sch_appt_id,
		sev.sch_event_id, sched_appt->list[num].sch_event_id)

order by
	sa.sch_appt_id
	, sev.sch_event_id
	, o.order_id
	, oc.catalog_cd
	, sat.appt_type_cd
	, sol.location_cd
	, preparation
	, prep_text
 
 
; populate sched_appt record structure
head sa.sch_appt_id
	idx = 0
	numx = 0
	
	idx = locateval(numx, 1, sched_appt->sched_cnt, sa.sch_appt_id, sched_appt->list[numx].sch_appt_id,
		sev.sch_event_id, sched_appt->list[numx].sch_event_id)
		
head o.order_id
	cnt = 0

detail
	for (i = 1 to sched_appt->list[idx].proc_cnt)
		if (sched_appt->list[idx].procedures[i].order_id = o.order_id)
			cnt = cnt + 1
			
			call alterlist(sched_appt->list[idx].procedures[i].preparations, cnt)
			
			sched_appt->list[idx].procedures[i].prep_cnt							= cnt	
			sched_appt->list[idx].procedures[i].preparations[cnt].preparation		= trim(replace(preparation, crlf, " ", 4), 3)
			sched_appt->list[idx].procedures[i].preparations[cnt].prep_text			= trim(replace(prep_text, crlf, " ", 4), 3)
		endif
	endfor
	
with nocounter, expand = 1, time = 60


;/**************************************************************/
;; select appointment type guideline data
;select distinct into "NL:"
;	sa.sch_appt_id
;	, sev.sch_event_id
;	, sat.appt_type_cd
;	, sal.location_cd
;	, accept_format 	= decode(oef.seq, oef.oe_format_name)
;	, guideline 		= decode(st.seq, st.mnemonic)
;	, guide_text 		= decode(st.seq, substring(1, 2048, ltr.long_text))
;	, guide_flexing		= decode(sfs.seq, sfs.mnemonic)
;	
;from
;	SCH_APPT sa	
;	
;	, (inner join SCH_EVENT sev on sev.sch_event_id = sa.sch_event_id
;		and sev.sch_state_cd > 0.0
;		and sev.active_ind = 1)
;	
;	, (inner join SCH_APPT_TYPE sat on sat.appt_type_cd = sev.appt_type_cd
;		and	sat.description not in (" *")
;		and sat.active_ind = 1)
;	
;	, (inner join SCH_APPT_LOC sal on sal.appt_type_cd = sat.appt_type_cd
;		and sal.location_cd = sa.appt_location_cd)
;	
;	, (left join ORDER_ENTRY_FORMAT oef on oef.oe_format_id = sat.oe_format_id)
;	
;	, (left join SCH_TEXT_LINK stl on stl.parent2_id = sal.location_cd
;		and	stl.parent_id = sat.appt_type_cd
;		and	stl.text_type_meaning = "GUIDELINE"
;		and	stl.active_ind = 1)
;	
;	, (left join SCH_SUB_LIST ssl on ssl.parent_table = "SCH_TEXT_LINK"
;		and ssl.parent_id = stl.text_link_id
;		and ssl.active_ind = 1)
;	
;	, (left join SCH_TEMPLATE st on st.template_id = ssl.template_id)
;	
;	, (left join LONG_TEXT_REFERENCE ltr on ltr.long_text_id = st.text_id)
;	
;	, (left join SCH_FLEX_STRING sfs on sfs.sch_flex_id = ssl.sch_flex_id)
;
;	, (dummyt d)
;	
;plan d
;
;join sa
;join sev
;join sat
;join sal
;join oef
;join stl
;join ssl
;join st
;join ltr
;join sfs
;
;where 
;	expand(num, 1, sched_appt->sched_cnt, sa.sch_appt_id, sched_appt->list[num].sch_appt_id,
;		sev.sch_event_id, sched_appt->list[num].sch_event_id)
;
;order by
;	sa.sch_appt_id
;	, sev.sch_event_id
;	, sat.appt_type_cd
;	, sal.location_cd
;	, accept_format
;	, guideline
;	, guide_text
;	, guide_flexing
; 
; 
;; populate sched_appt record structure
;head sa.sch_appt_id
;	idx = 0
;	numx = 0
;	cnt = 0
;	
;	idx = locateval(numx, 1, sched_appt->sched_cnt, sa.sch_appt_id, sched_appt->list[numx].sch_appt_id,
;		sev.sch_event_id, sched_appt->list[numx].sch_event_id)
;		
;detail
;	cnt = cnt + 1
;	
;	call alterlist(sched_appt->list[idx].guidelines, cnt)
;	
;	sched_appt->list[idx].guide_cnt							= cnt
;	sched_appt->list[idx].guidelines[cnt].guideline			= trim(replace(guideline, crlf, " ", 4), 3)
;	sched_appt->list[idx].guidelines[cnt].guide_text		= trim(replace(guide_text, crlf, " ", 4), 3)
;	
;with nocounter, expand = 1, time = 60
 
call echorecord(sched_appt)

 
/**************************************************************/
; select final data 
select into "NL:" 
from
	(dummyt d1 with seq = value(sched_appt->sched_cnt))
	, (dummyt d2)	
	, (dummyt d3) 
	, (dummyt d4)
 
plan d1
where
	maxrec(d2, sched_appt->list[d1.seq].proc_cnt)
	and maxrec(d3, sched_appt->list[d1.seq].prep_cnt)
	
join d2
where
	maxrec(d4, sched_appt->list[d1.seq].procedures[d2.seq].prep_cnt)
	
join d3
join d4
 
 
; populate final_data record structure
head report
	cnt = 0
	
detail
	cnt = cnt + 1
	
	call alterlist(final_data->list, cnt)
	
	final_data->cnt								= cnt
	final_data->list[cnt].person_id				= sched_appt->list[d1.seq].person_id
	final_data->list[cnt].patient_name			= trim(sched_appt->list[d1.seq].patient_name, 3)
	final_data->list[cnt].cmrn					= trim(sched_appt->list[d1.seq].cmrn, 3)
	final_data->list[cnt].mrn					= trim(sched_appt->list[d1.seq].mrn, 3)
	final_data->list[cnt].fin					= trim(sched_appt->list[d1.seq].fin, 3)
	final_data->list[cnt].org_name				= trim(sched_appt->list[d1.seq].org_name, 3)
	final_data->list[cnt].facility				= trim(sched_appt->list[d1.seq].facility, 3)

	final_data->list[cnt].dob					= cnvtdatetimeutc(datetimezone(sched_appt->list[d1.seq].dob, 
																			   sched_appt->list[d1.seq].dob_tz), 1)
								
	final_data->list[cnt].ssn					= trim(sched_appt->list[d1.seq].ssn, 3)
	final_data->list[cnt].language				= trim(sched_appt->list[d1.seq].language, 3)
								
	final_data->list[cnt].encntr_type			= trim(sched_appt->list[d1.seq].encntr_type, 3)
	
	final_data->list[cnt].order_id				= sched_appt->list[d1.seq].procedures[d2.seq].order_id
	final_data->list[cnt].order_mnemonic		= trim(sched_appt->list[d1.seq].procedures[d2.seq].order_mnemonic, 3)
	final_data->list[cnt].order_phy_id			= trim(sched_appt->list[d1.seq].order_phy_id, 3)
	final_data->list[cnt].order_phy				= trim(sched_appt->list[d1.seq].order_phy, 3)
	final_data->list[cnt].ord_phys_group		= trim(sched_appt->list[d1.seq].ord_phys_group, 3)
	final_data->list[cnt].cpt_cd				= trim(sched_appt->list[d1.seq].procedures[d2.seq].cpt_cd, 3)
	final_data->list[cnt].cpt_desc				= trim(sched_appt->list[d1.seq].procedures[d2.seq].cpt_desc, 3)
	final_data->list[cnt].icd10					= trim(sched_appt->list[d1.seq].icd10, 3)
	final_data->list[cnt].icd10_desc			= trim(sched_appt->list[d1.seq].icd10_desc, 3)
	final_data->list[cnt].order_comment			= trim(sched_appt->list[d1.seq].procedures[d2.seq].order_comment, 3)
	
	final_data->list[cnt].order_preparation		= trim(sched_appt->list[d1.seq].procedures[d2.seq].preparations[d4.seq].preparation, 3)
	final_data->list[cnt].order_prep_text		= trim(sched_appt->list[d1.seq].procedures[d2.seq].preparations[d4.seq].prep_text, 3)

	final_data->list[cnt].health_plan			= trim(sched_appt->list[d1.seq].health_plan, 3)
	final_data->list[cnt].sch_state				= trim(sched_appt->list[d1.seq].sch_state, 3)
	final_data->list[cnt].location				= trim(sched_appt->list[d1.seq].location, 3)
	final_data->list[cnt].resource				= trim(sched_appt->list[d1.seq].resource, 3)
	final_data->list[cnt].appt_dt_tm			= sched_appt->list[d1.seq].appt_dt_tm
	final_data->list[cnt].appt_type				= trim(sched_appt->list[d1.seq].appt_type, 3)
	final_data->list[cnt].appt_type_alias		= trim(sched_appt->list[d1.seq].appt_type_alias, 3) ;002
	final_data->list[cnt].reason_exam			= trim(sched_appt->list[d1.seq].reason_exam, 3)
	final_data->list[cnt].comment				= trim(sched_appt->list[d1.seq].comment, 3)
	
	final_data->list[cnt].preparation			= trim(sched_appt->list[d1.seq].preparations[d3.seq].preparation, 3)
	final_data->list[cnt].prep_text				= trim(sched_appt->list[d1.seq].preparations[d3.seq].prep_text, 3)

with nocounter, outerjoin = d1, time = 60
 
call echorecord(final_data)

 
/**************************************************************/
; select data 
select into value($OUTDEV)
	person_id				= final_data->list[d1.seq].person_id
	, patient_name			= trim(final_data->list[d1.seq].patient_name, 3)
	, cmrn					= trim(final_data->list[d1.seq].cmrn, 3)
	, mrn					= trim(final_data->list[d1.seq].mrn, 3)
	, fin					= trim(final_data->list[d1.seq].fin, 3)
	, org_name				= trim(final_data->list[d1.seq].org_name, 3)
	, facility				= trim(final_data->list[d1.seq].facility, 3)

	, dob					= format(final_data->list[d1.seq].dob, "mm/dd/yyyy;;d")
								
	, ssn					= trim(final_data->list[d1.seq].ssn, 3)
	, language				= trim(final_data->list[d1.seq].language, 3)
								
	, encntr_type			= trim(final_data->list[d1.seq].encntr_type, 3)
	
	, order_id				= final_data->list[d1.seq].order_id
	, order_mnemonic		= trim(final_data->list[d1.seq].order_mnemonic, 3)
	, order_phy_id			= trim(final_data->list[d1.seq].order_phy_id, 3)
	, order_phy				= trim(final_data->list[d1.seq].order_phy, 3)
	, ord_phys_group		= trim(final_data->list[d1.seq].ord_phys_group, 3)
	, cpt_cd				= trim(final_data->list[d1.seq].cpt_cd, 3)
	, cpt_desc				= trim(final_data->list[d1.seq].cpt_desc, 3)
	, icd10					= trim(final_data->list[d1.seq].icd10, 3)
	, icd10_desc			= trim(final_data->list[d1.seq].icd10_desc, 3)
	, order_comment			= trim(final_data->list[d1.seq].order_comment, 3)
	
	, order_preparation		= trim(final_data->list[d1.seq].order_preparation, 3)
	, order_prep_text		= trim(final_data->list[d1.seq].order_prep_text, 3)

	, health_plan			= trim(final_data->list[d1.seq].health_plan, 3)
	, sch_state				= trim(final_data->list[d1.seq].sch_state, 3)
	, location				= trim(final_data->list[d1.seq].location, 3)
	, resource				= trim(final_data->list[d1.seq].resource, 3)
	
	, appt_dt_tm			= cnvtupper(build2(format(final_data->list[d1.seq].appt_dt_tm, "mm/dd/yyyy;;d"), " ",
											   format(final_data->list[d1.seq].appt_dt_tm, "hh:mm;;s")))
	
	;002
	, appt_type				= if (trim(final_data->list[d1.seq].appt_type_alias, 3) > " ")
								trim(final_data->list[d1.seq].appt_type_alias, 3)
							  else
							  	trim(final_data->list[d1.seq].appt_type, 3)
							  endif
							  
	, reason_exam			= trim(final_data->list[d1.seq].reason_exam, 3)
	, comment				= trim(final_data->list[d1.seq].comment, 3)
	
	, preparation			= trim(final_data->list[d1.seq].preparation, 3)
	, prep_text				= trim(final_data->list[d1.seq].prep_text, 3)
 
from
	(dummyt d1 with seq = value(final_data->cnt))
 
plan d1
 
order by
	patient_name
	, final_data->list[d1.seq].appt_dt_tm
	, org_name

with nocounter, noheading, separator = "|", format, time = 60
;with nocounter, separator = " ", format, time = 60
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript
 
end
go
 
