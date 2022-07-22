 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Saravanan
	Date Written:		July'2018
	Solution:			population Health Quality
	Source file name:  	cov_phq_tob_assessment.prg
	Object name:		cov_phq_tob_assessment
	Request#:			1049
 
	Program purpose:	      Tobacco cessation education detail
	Executing from:		CCL/DA2/Quality folder
  	Special Notes:          Excel file.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_phq_tob_assessment:DBA go
create program cov_phq_tob_assessment:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Admit Date/Time" = "SYSDATE"
	, "End Admit Date/Time" = "SYSDATE"
	, "FacilityListBox" = 0
 
with OUTDEV, start_datetime, end_datetime, facility_list
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare initcap()  = c100
 
declare adult_pat_his_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Adult Patient History Form')),protect
declare procedure_chklist_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Preprocedure Checklist Form')),protect
declare OB_triage_var          = f8 with constant(2563736601.00) ;OB Triage
declare admit_his_var          = f8 with constant(2556947191.00) ;Admission History Outpatient - Text
declare OB_pat_his_var         = f8 with constant(2563736593.00) ;OB Patient History Form
declare pre_admit_asses_var    = f8 with constant(3624163.00)    ;Pre-Admission Assessment
declare ED_triage_part2_var    = f8 with constant(275169681.00)  ;ED Triage Part 2 - Adult
declare preop_chklist_var      = f8 with constant(2700675.00)    ;Perioperative Preprocedure Checklist
 
declare adult_pat_his_form_var = vc with constant('Adult Patient History Form'),protect
declare proce_chklist_form_var = vc with constant('Preprocedure Checklist Form'),protect
declare admit_his_form_var     = vc with constant('Admission History Outpatient'),protect
declare OB_triage_form_var     = vc with constant('OB Triage'),protect
declare OB_pat_his_form_var    = vc with constant('OB Patient History Form'),protect
declare pre_admit_ase_form_var = vc with constant('Pre-Admission Assessment'),protect
declare ED_triage_p2_form_var  = vc with constant('ED Triage Part 2 - Adult'),protect
declare preop_chklist_form_var = vc with constant('Perioperative Preprocedure Checklist'),protect
 
declare quit_line_ref_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Tobacco Cessation - Quit Line Referral')),protect
declare counsel_accp_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Tobacco Cessation - Counsel Accepted')),protect
declare counsel_decl_var       = f8 with constant(2559217485.00) ;'Tobacco Cessation - Counsel Declined'
 
/*
 
select * from code_value where code_set = 72 and code_value in(2557006357,2556947191)
 
 2556947191.00	Admission History Outpatient - Text
 2563736601.00	OB Triage
 2563736593.00	OB Patient History Form
 3624163.00       Pre-Admission Assessment
 275169681.00     ED Triage Part 2 - Adult
  2700675.00	Perioperative Preprocedure Checklist
 
 */
 
 
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
Record tob(
	1 reccnt = i4
	1 plist[*]
		2 facility = f8
		2 personid = f8
		2 encntrid = f8
		2 fin = vc
		2 mrn = vc
		2 pat_name = vc
		2 age = vc
		2 gender = vc
		2 admit_status = vc
		2 arrive_dt = vc
		2 admit_dt = vc
		2 disch_dt = vc
		2 admit_unit = vc
		2 form_name = vc
		2 form_dt = vc
		2 nurse_completed = vc
		2 tob_use_doc_dt = vc
		2 tob_doc_action_type = vc
		2 tob_use_doc_nurse = vc
		2 tob_use_result = vc
		2 task_fired_dt = vc
		2 task_status = vc
 		2 sh_order_id = f8
		2 quit_line_ref = vc
		2 counsel_accp = vc
		2 counsel_decl = vc
		2 tob_edu_doc_dt = vc
		2 tob_edu_doc_nurse = vc
)
 
 
;Get clinical events
select distinct into 'NL:';$outdev
 
e.loc_facility_cd
, e.person_id, e.encntr_id
, fin = ea.alias
, mrn = ea1.alias
, name = initcap(p.name_full_formatted)
, reg_age = substring(1,3,cnvtage(p.birth_dt_tm, e.reg_dt_tm, 0))
, pat_gender = uar_get_code_display(p.sex_cd)
, adm_status = uar_get_code_display(e.encntr_type_cd)
, ar_dt = format(e.arrive_dt_tm, "mm/dd/yyyy hh:mm;;d")
, adm_dt = format(e.reg_dt_tm, "mm/dd/yyyy hh:mm;;d")
, dis_dt = format(e.disch_dt_tm, "mm/dd/yyyy hh:mm;;d")
, adm_unit = uar_get_code_display(e.loc_nurse_unit_cd)
, event =  uar_get_code_display(ce.event_cd)
, ce.event_cd
, ce.result_val
, verified_dt = format(ce.verified_dt_tm, "mm/dd/yyyy hh:mm:ss;;d")
, verified_prsnl = initcap(pr.name_full_formatted)
 
from
 
 encounter e
,(left join clinical_event ce on ce.person_id = e.person_id
	and ce.encntr_id = e.encntr_id
	and ce.result_status_cd in (25,34,35)
	and ce.event_cd in (quit_line_ref_var, counsel_accp_var, counsel_decl_var
			,adult_pat_his_var, procedure_chklist_var, admit_his_var, pre_admit_asses_var
			,OB_triage_var, OB_pat_his_var, ED_triage_part2_var, preop_chklist_var)
	and ce.event_id =
		(select max(ce1.event_id)
		 	from clinical_event ce1
 		 	where ce1.encntr_id = e.encntr_id and ce1.event_cd = ce.event_cd
 		 	and ce1.result_status_cd in (25,34,35)
 		 	group by ce1.encntr_id)
 )
 
, (left join prsnl pr on pr.person_id = ce.verified_prsnl_id)
, encntr_alias ea
, encntr_alias ea1
, person p
 
plan e where e.loc_facility_cd = $facility_list
	and e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.encntr_type_cd in(309308.00, 309312.00, 19962820.00)
		;Inpatient, Observation, Outpatient in a Bed
	and e.encntr_id != 0.0
	and e.active_ind = 1
 
join ce
 
join pr
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077 ;fin
	and ea.active_ind = 1
 
join ea1 where ea1.encntr_id = e.encntr_id
	and ea1.encntr_alias_type_cd = 1079 ;fin
	and ea1.active_ind = 1
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
	and datetimediff(e.reg_dt_tm, p.birth_dt_tm) >= 6574
	 ;18 years * 365.25 days in a year = 6574.5 days
 
order by e.loc_facility_cd, e.encntr_id, ce.event_cd
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT, TIME = 120
 
 
Head report
 	cnt = 0
	call alterlist(tob->plist, 100)
 
Head e.encntr_id
 	cnt = cnt + 1
 	tob->reccnt = cnt
	call alterlist(tob->plist, cnt)
 
Detail
 	tob->plist[cnt].facility = e.loc_facility_cd
 	tob->plist[cnt].personid = e.person_id
 	tob->plist[cnt].encntrid = e.encntr_id
 	tob->plist[cnt].fin = fin
 	tob->plist[cnt].mrn = mrn
	tob->plist[cnt].pat_name = name
	tob->plist[cnt].age = reg_age
	tob->plist[cnt].gender = pat_gender
	tob->plist[cnt].admit_status = adm_status
	tob->plist[cnt].arrive_dt = ar_dt
	tob->plist[cnt].admit_dt = adm_dt
	tob->plist[cnt].disch_dt = dis_dt
	tob->plist[cnt].admit_unit = adm_unit
 
 	case (ce.event_cd)
		of adult_pat_his_var:
	 		tob->plist[cnt].form_name = adult_pat_his_form_var
		      tob->plist[cnt].form_dt = verified_dt
		      tob->plist[cnt].nurse_completed   = verified_prsnl
		of procedure_chklist_var:
			if(tob->plist[cnt].form_name = ' ')
	 			tob->plist[cnt].form_name = proce_chklist_form_var
	 		endif
		      tob->plist[cnt].form_dt = verified_dt
		      tob->plist[cnt].nurse_completed   = verified_prsnl
		of admit_his_var:
	      	if(tob->plist[cnt].form_name = ' ')
	 			tob->plist[cnt].form_name = admit_his_form_var
	 		endif
		      tob->plist[cnt].form_dt = verified_dt
		      tob->plist[cnt].nurse_completed   = verified_prsnl
		of pre_admit_asses_var:
	      	if(tob->plist[cnt].form_name = ' ')
	 			tob->plist[cnt].form_name = pre_admit_ase_form_var
	 		endif
		      tob->plist[cnt].form_dt = verified_dt
		      tob->plist[cnt].nurse_completed   = verified_prsnl
		of OB_triage_var:
			if(tob->plist[cnt].form_name = ' ')
	 			tob->plist[cnt].form_name = OB_triage_form_var
	 		endif
		      tob->plist[cnt].form_dt = verified_dt
		      tob->plist[cnt].nurse_completed   = verified_prsnl
		of OB_pat_his_var:
			if(tob->plist[cnt].form_name = ' ')
	 			tob->plist[cnt].form_name = OB_pat_his_form_var
	 		endif
		      tob->plist[cnt].form_dt = verified_dt
		      tob->plist[cnt].nurse_completed   = verified_prsnl
		 of ED_triage_part2_var:
			if(tob->plist[cnt].form_name = ' ')
	 			tob->plist[cnt].form_name = ED_triage_p2_form_var
	 		endif
		      tob->plist[cnt].form_dt = verified_dt
		      tob->plist[cnt].nurse_completed   = verified_prsnl
		 of preop_chklist_var:
			if(tob->plist[cnt].form_name = ' ')
	 			tob->plist[cnt].form_name = preop_chklist_form_var
	 		endif
		      tob->plist[cnt].form_dt = verified_dt
		      tob->plist[cnt].nurse_completed   = verified_prsnl
		of counsel_accp_var:
			tob->plist[cnt].counsel_accp      = ce.result_val
			tob->plist[cnt].tob_edu_doc_dt    = verified_dt
			tob->plist[cnt].tob_edu_doc_nurse = verified_prsnl
 		of counsel_decl_var:
			tob->plist[cnt].counsel_decl      = ce.result_val
			tob->plist[cnt].tob_edu_doc_dt    = verified_dt
			tob->plist[cnt].tob_edu_doc_nurse = verified_prsnl
 		of quit_line_ref_var:
			tob->plist[cnt].quit_line_ref     = ce.result_val
			tob->plist[cnt].tob_edu_doc_dt    = verified_dt
			tob->plist[cnt].tob_edu_doc_nurse = verified_prsnl
	endcase
 
foot e.encntr_id
	call alterlist(tob->plist, cnt)
 
with nocounter
 
;call echorecord(tob)
 
 
 
;****************************************************************************************************************
 
;Get Tobacco/Smoking history
select distinct into 'NL:' ;$outdev
 
  e.loc_facility_cd
, e.person_id, e.encntr_id, fin = tob->plist[d.seq].fin
, reg = format(e.reg_dt_tm, "mm/dd/yyyy hh:mm;;d")
, group_id = sa.shx_activity_group_id
, perform_dt = format(sa.perform_dt_tm, "mm/dd/yyyy hh:mm;;d")
, sax.action_type_mean, se.response_label
, action_dt = format(sax.action_dt_tm, "mm/dd/yyyy hh:mm;;d")
, sr.shx_response_id
, n.source_string
, nurse_doc_sh = initcap(pr.name_full_formatted)
, version_dt = format(dfa.version_dt_tm, "mm/dd/yyyy hh:mm;;d")
 
from
	 (dummyt d WITH seq = value(size(tob->plist,5)))
	, encounter e
	, (left join dcp_forms_activity dfa on dfa.encntr_id = e.encntr_id
		and dfa.form_status_cd in (value(uar_get_code_by ("MEANING", 8, "AUTH")), value(uar_get_code_by ("MEANING", 8, "MODIFIED")))
		and dfa.active_ind = 1
		and dfa.flags = 2)
 
	, (left join dcp_forms_ref dfr on dfr.dcp_forms_ref_id = dfa.dcp_forms_ref_id
		and dfr.active_ind = 1)
 
	, (left join dcp_forms_activity_comp dfac on dfac.dcp_forms_activity_id = dfa.dcp_forms_activity_id
		and dfac.parent_entity_name = 'Social History')
 
	, (left join shx_activity sa on sa.person_id = e.person_id
		;and sa.shx_activity_group_id = dfac.parent_entity_id
		and sa.active_ind = 1
		and sa.organization_id = e.organization_id
		and sa.status_cd = 4374372.00 ;active
		and sa.beg_effective_dt_tm > e.arrive_dt_tm 
		and (sa.beg_effective_dt_tm < e.disch_dt_tm or sa.beg_effective_dt_tm <= sysdate ))
 
	, shx_action sax
	, (left join prsnl pr on pr.person_id = sax.prsnl_id)
	, shx_category_ref scr
	, shx_response sr
	, shx_element se
	, shx_alpha_response sar
	, nomenclature n
 
plan d
 
join e where e.person_id = tob->plist[d.seq].personid
	and e.encntr_id = tob->plist[d.seq].encntrid
	and e.loc_facility_cd = $facility_list
	and e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.encntr_type_cd in(309308.00, 309312.00, 19962820.00);Inpatient, Observation, Outpatient in a Bed
	and e.encntr_id != 0.0
	and e.active_ind = 1
 
join dfa
 
join dfr
 
join dfac
 
join sa
 
join pr
 
join sax where sax.shx_activity_id = sa.shx_activity_id
	and sax.shx_activity_group_id = sa.shx_activity_group_id
	and sax.action_type_mean in('CREATE','MODIFY', 'REVIEW')
	and sax.beg_effective_dt_tm > e.arrive_dt_tm 
	and (sax.beg_effective_dt_tm < e.disch_dt_tm or sax.beg_effective_dt_tm <= sysdate)
 
 
join scr where scr.shx_category_ref_id = sa.shx_category_ref_id
	and scr.category_cd = 4374350.00 ;Tobacco
 
join sr where sr.shx_activity_id = sa.shx_activity_id
	and sr.active_ind = 1
	and sr.task_assay_cd in(4625825.00, 275217525.00) ;Tobacco use: ,Smokeless tobacco use:
	and sr.beg_effective_dt_tm > e.arrive_dt_tm 
	and (sr.beg_effective_dt_tm < e.disch_dt_tm or sr.beg_effective_dt_tm < sysdate)
 
join se where se.shx_category_def_id = sa.shx_category_def_id
	and se.task_assay_cd = sr.task_assay_cd
 
join sar where sar.shx_response_id = sr.shx_response_id
	and sar.active_ind = 1
	and sar.beg_effective_dt_tm > e.arrive_dt_tm 
	and (sar.beg_effective_dt_tm < e.disch_dt_tm or sar.beg_effective_dt_tm < sysdate)
 
join n where n.nomenclature_id = sar.nomenclature_id
	 and n.nomenclature_id in(12191116.00,64772443.00,64772456.00,64772469.00,64772509.00,64772585.00,64772573.00,64772580.00
	,64772566.00, 64772498.00, 64772526.00, 64772537.00,14169324.00, 281116728.00, 279982266.00, 280911946.00, 965054.00, 13023119.00)
	and n.active_ind = 1
 
order by e.loc_facility_cd, e.person_id, e.encntr_id, sar.shx_response_id, n.source_string
 
;order by e.loc_facility_cd, e.encntr_id, sa.shx_activity_id, n.source_string
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT;, TIME = 120;, maxrec = 10000
 
 
Head e.person_id ;e.encntr_id
 	cnt = 0
 	idx = 0
	idx = locateval(cnt, 1, size(tob->plist, 5), e.encntr_id, tob->plist[cnt].encntrid)
 
Detail
 
   if(idx > 0)
	tob->plist[idx].tob_use_doc_dt = action_dt
	tob->plist[idx].tob_doc_action_type = sax.action_type_mean
	tob->plist[idx].tob_use_doc_nurse = nurse_doc_sh
	tob->plist[idx].tob_use_result = n.source_string
   endif
 
with nocounter
 
call echorecord(tob)
 
 
;*****************************************************************************************************************
 
;Task details
select distinct into 'nl:' ;$outdev
 
 ta.person_id, ta.encntr_id, ta.task_id
 , task_stat = uar_get_code_display(ta.task_status_cd)
 , task_catalog = uar_get_code_display(ta.catalog_cd)
 , task_dt = format(ta.task_dt_tm, "mm/dd/yyyy hh:mm;;d")
 , task_create_dt = format(ta.task_create_dt_tm, "mm/dd/yyyy hh:mm;;d")
 , ot.task_description
 
from
 	(dummyt d WITH seq = value(size(tob->plist,5)))
 	, encounter e
 	, task_activity ta
	, order_task ot
 
plan d
 
join e where e.encntr_id = tob->plist[d.seq].encntrid
	and e.person_id = tob->plist[d.seq].personid
 
join ta where ta.person_id = e.person_id
	and ta.encntr_id = e.encntr_id
	and ta.task_create_dt_tm >= e.arrive_dt_tm
 
join ot where ot.reference_task_id = ta.reference_task_id
	and ot.reference_task_id in(2652237483,2652252293,2652244237) ;Smoking cessation tasks for acute, sbu & peninsula
	OR ta.reference_task_id in(2580093123,2580201899,2580093165) ;errored, referencing Build(couple of days was in prod)
	or ta.reference_task_id in(2794561.00,202064191.00) ;old
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
Head e.encntr_id
 	cnt = 0
 	idx = 0
	idx = locateval(cnt, 1, size(tob->plist, 5), e.encntr_id, tob->plist[cnt].encntrid)
Detail
   if(idx > 0)
	tob->plist[idx].task_fired_dt = task_dt
	tob->plist[idx].task_status = task_stat
	tob->plist[idx].sh_order_id = ta.order_id
   endif
 
with nocounter
 
;call echorecord(tob)
 
 
;*****************************************************************************************************************
 
 
;Get from record structure to display as excel
SELECT DISTINCT INTO VALUE($OUTDEV)
 
 	  FACILITY = UAR_GET_CODE_DISPLAY(TOB->plist[D1.SEQ].facility)
	, FIN = TRIM(SUBSTRING(1, 30, TOB->plist[D1.SEQ].fin))
	, MRN = TRIM(SUBSTRING(1, 30, TOB->plist[D1.SEQ].mrn))
	, PAT_NAME = TRIM(SUBSTRING(1, 50, TOB->plist[D1.SEQ].pat_name))
	, AGE = SUBSTRING(1, 30, TOB->plist[D1.SEQ].age)
	, GENDER = SUBSTRING(1, 30, TOB->plist[D1.SEQ].gender)
	, ADMIT_STATUS = SUBSTRING(1, 30, TOB->plist[D1.SEQ].admit_status)
	, ARRIVE_DT = SUBSTRING(1, 30, TOB->plist[D1.SEQ].arrive_dt)
	, ADMIT_DT = SUBSTRING(1, 30, TOB->plist[D1.SEQ].admit_dt)
	, DISCH_DT = SUBSTRING(1, 30, TOB->plist[D1.SEQ].disch_dt)
	, ADMIT_UNIT = SUBSTRING(1, 30, TOB->plist[D1.SEQ].admit_unit)
	, FORM_COMPLETED = SUBSTRING(1, 100, TOB->plist[D1.SEQ].form_name)
	, FORM_DT = SUBSTRING(1, 30, TOB->plist[D1.SEQ].form_dt)
	, NURSE_DOCUMENTED = SUBSTRING(1, 50, TOB->plist[D1.SEQ].nurse_completed)
	, TOB_USE_DOC_DT = SUBSTRING(1, 30, TOB->plist[D1.SEQ].tob_use_doc_dt)
	, TOB_USE_DOC_TYPE = SUBSTRING(1, 30, TOB->plist[D1.SEQ].tob_doc_action_type)
	, TOB_USE_DOC_NURSE = SUBSTRING(1, 50, TOB->plist[D1.SEQ].tob_use_doc_nurse)
	, TOBACCO_USE = SUBSTRING(1, 50, TOB->plist[D1.SEQ].tob_use_result)
	, TASK_FIRED_DT = SUBSTRING(1, 30, TOB->plist[D1.SEQ].task_fired_dt)
	, TASK_STATUS = SUBSTRING(1, 30, TOB->plist[D1.SEQ].task_status)
	, TOB_EDU_DOC_DT = SUBSTRING(1, 30, TOB->plist[D1.SEQ].tob_edu_doc_dt)
	, COUNSEL_ACCP = SUBSTRING(1, 100, TOB->plist[D1.SEQ].counsel_accp)
	, QUIT_LINE_REF = SUBSTRING(1, 100, TOB->plist[D1.SEQ].quit_line_ref)
	, COUNSEL_DECL = SUBSTRING(1, 100, TOB->plist[D1.SEQ].counsel_decl)
	, TOB_EDU_DOC_NURSE = SUBSTRING(1, 50, TOB->plist[D1.SEQ].tob_edu_doc_nurse)
 
FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(TOB->plist, 5)))
 
PLAN D1
 
ORDER BY FACILITY, ADMIT_DT, ADMIT_UNIT, PAT_NAME
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT, TIME = 120, SKIPREPORT = 1
 
 
end
go
 
 
;Task Reference id's
 
/*       2794561.00	         1	Tobacco Cessation
     202064191.00	         1	Tobacco Cessation Education
    2652237483.00	         1	Tobacco Cessation Instruction - Acute Facilities
    2652252293.00	         1	Tobacco Cessation Instruction - Peninsula
    2652244237.00	         1	Tobacco Cessation Instruction - SBU
*/
 
 
 
/* Tobacco DTA's used in the rule
 
64772566.00 Never (less than 100 in lifetime)
64772456.00 4 or less cigarettes(less than 1/4 pack)/day in last 30 days
64772469.00 5-9 cigarettes (between 1/4 to 1/2 pack)/day in last 30 days
64772443.00 10 or more cigarettes (1/2 pack or more)/day in last 30 days
64772509.00 Cigars or pipes daily within last 30 days
64772498.00	Cigars or pipes, but not daily within last 30 days
64772526.00	Former smokeless tobacco user, quit more than 30 days ago
64772537.00	Former smoker, quit more than 30 days ago
64772585.00 Smokeless tobacco user within last 30 days
12191116.00 Smoker, current status unknown
64772573.00 Not obtained due to cognitive impairment
64772580.00 Refused tobacco status screen
281116728.00	Unable to assess due to cognitive impairment
    14169324.00	Other
   279982266.00	other
   280911946.00	Other
      965054.00	Other
    13023119.00	Other
 
*/
 
 
 
