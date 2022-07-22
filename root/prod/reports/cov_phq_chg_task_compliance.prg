/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		May 2021
	Solution:			Quality
	Source file name:	      cov_phq_chg_task_compliance.prg
	Object name:		cov_phq_chg_task_compliance
	Request#:			9964
	Program purpose:	      MRSA/CHG Project
	Executing from:		DA2/Ops
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date  Developer	Comment
 
8-6-21    Geetha     Show report only for active patients
----------	-------------------------------------------------------------------------------------------------------*/
 
 
drop program cov_phq_chg_task_compliance:dba go
create program cov_phq_chg_task_compliance:dba
 
prompt
	"Output to File/Printer/MINe" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 0
	, "Nurse Unit" = 0
 
with OUTDEV, acute_facility_list, nurse_unit
 
 
/**************************************************************
; Variable Declaration
**************************************************************/
 
declare initcap()     = c100
declare opr_nu_var    = vc with noconstant("")
declare num  = i4 with noconstant(0)
declare problem_list = vc with noconstant('')
declare diagnosis_list = vc with noconstant('')
 
declare urinary_cath_var     = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Urinary Catheter Activity:'))), protect
declare urinary_site_var     = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Urinary Catheter Insertion Site:'))),protect
declare central_line_var     = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Central Line Activity.'))), protect
declare central_site_var     = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Central Line Insertion Site:'))), protect
declare chg_treat_var        = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Chlorohexidine treatment'))), protect
declare cvl_indication_var   = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Central Line Indication.'))), protect
declare cvl_type_var         = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Central Line Access Type'))), protect
declare foley_indication_var = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Urinary Catheter Indications:'))), protect
declare foley_type_var       = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Urinary Catheter Type:'))), protect
declare chg_task_var         = vc with constant('Perform Chlorhexidine Treatment'), protect
 
 
;-------------------------------------------------------------------------------------------------------
;Set nurse unit variable
if(substring(1,1,reflect(parameter(parameter2($nurse_unit),0))) = "L");multiple values were selected
	set opr_nu_var = "in"
elseif(parameter(parameter2($nurse_unit),1)= 0.0) ;all[*] values were selected
	set opr_nu_var = "!="
else								  ;a single value was selected
	set opr_nu_var = "="
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
 
Record unit(
	1 list[*]
		2 nu_unit = vc
		2 nu_descrpt = vc
		2 nu_cd = f8
		2 cdf_mean = vc
)
 
;Store the selected units
select into $outdev
nurse_unit = trim(uar_get_code_display(nu.location_cd)),unit_desc = trim(uar_get_code_description(nu.location_cd))
,nurse_unit_cd = nu.location_cd, cv1.cdf_meaning
 
from nurse_unit nu
	,code_value cv1
 
plan nu where nu.loc_facility_cd = $acute_facility_list
	and operator(nu.location_cd, opr_nu_var, $nurse_unit)
	and nu.active_status_cd = 188
	and nu.active_ind = 1
	and nu.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and nu.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
 
join cv1 where nu.location_cd = cv1.code_value
	and cv1.code_set = 220
	and cv1.cdf_meaning = 'NURSEUNIT'
 
order nu.location_cd
 
Head report
	ncnt = 0
Head nu.location_cd
	ncnt += 1
	call alterlist(unit->list, ncnt)
Detail
	unit->list[ncnt].nu_unit = nurse_unit
	unit->list[ncnt].nu_descrpt = unit_desc
	unit->list[ncnt].nu_cd = nu.location_cd
	unit->list[ncnt].cdf_mean = cv1.cdf_meaning
with nocounter
 
call echorecord(unit)
 
;----------------------------------------------------------------------------------------------
 
Record pat(
	1 rec_cnt = i4
	1 plist[*]
		2 facility = vc
		2 unit = vc
		2 fin = vc
		2 age = vc
		2 pat_name = vc
		2 pat_type = vc
		2 encntrid = f8
		2 patientid = f8
		2 orderid = f8
		2 admitdt = dq8
		2 dischdt = vc
		2 allergy_doc = vc
		2 allergy_doc_dt = vc
		2 allergy_begdt = vc
		2 allergy_enddt = vc
		2 chg_not_done_doc = vc
		2 chg_not_done_doc_dt = vc
		2 tsk_not_done_doc = vc
		2 tsk_not_done_doc_dt = vc
		2 cvl_action = vc
		2 cvl_beg_dt = vc
		2 cvl_end_dt = vc
		2 cvl_indcat = vc
		2 cvl_indcat_dt = vc
		2 cvl_typ = vc
		2 foley_indcat = vc
		2 foley_indcat_dt = vc
		2 foley_action = vc
		2 foley_beg_dt = vc
		2 foley_end_dt = vc
		2 foley_typ = vc
		2 mrsa_p_doc = vc
		2 mrsa_dg_doc = vc
		2 chlor_treatment = vc
		2 chg_complete_dt = vc
		2 task_info = vc
		2 task[*]
			3 tsk_name = vc
			3 tsk_dt = vc
			3 tsk_status = vc
			3 tskid = f8
	)
 
;-----------------------------------------------------------------------------------------------
;Patient population - active patients
 
select into $outdev
 
fac = trim(uar_get_code_display(e.loc_facility_cd))
,e.encntr_id, nunit = uar_get_code_display(elh.loc_nurse_unit_cd)
 ,beg_dt = elh.beg_effective_dt_tm ';;q', end_dt = elh.end_effective_dt_tm ';;q'
 
from   encounter e
	, encntr_loc_hist elh
	, (dummyt d with seq = value(size(unit->list, 5)))
 
plan e where e.loc_facility_cd = $acute_facility_list
	and e.active_ind = 1
	and e.encntr_type_cd in(309308.00, 309312.00,19962820.00);Inpatient,Observation,Outpatient in a Bed
	and e.disch_dt_tm is null
	and e.encntr_status_cd = 854.00 ;Active
 
join elh where elh.encntr_id = e.encntr_id
	and elh.active_ind = 1
 
join d where elh.loc_nurse_unit_cd = unit->list[d.seq].nu_cd
 
order by e.encntr_id, elh.beg_effective_dt_tm
 
Head report
	cnt = 0
Head e.encntr_id
	cnt += 1
	pat->rec_cnt = cnt
	call alterlist(pat->plist, cnt)
Detail
	pat->plist[cnt].facility = fac
	pat->plist[cnt].admitdt = e.reg_dt_tm
	pat->plist[cnt].pat_type = uar_get_code_display(e.encntr_type_cd)
	pat->plist[cnt].encntrid = e.encntr_id
	pat->plist[cnt].patientid = e.person_id
	pat->plist[cnt].unit = nunit
 
with nocounter
 
IF(pat->rec_cnt > 0)
;------------------------------------------------------------------------------------------
;Demographic
 
select into $outdev
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, person p
	, encntr_alias ea
 
plan d
 
join p where p.person_id = pat->plist[d.seq].patientid
	and p.active_ind = 1
 
join ea where ea.encntr_id = pat->plist[d.seq].encntrid
	and ea.active_ind = 1
	and ea.encntr_alias_type_cd = 1077
 
order by ea.encntr_id
 
Head ea.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,ea.encntr_id ,pat->plist[icnt].encntrid)
	if(idx > 0)
		pat->plist[idx].pat_name = p.name_full_formatted
		pat->plist[idx].fin = trim(ea.alias)
	endif
 
with nocounter
 
;------------------------------------------------------------------------------------------------------------------
;allergy documentation
 
select into $outdev
 
a.encntr_id, a.beg_effective_dt_tm ';;q', a.end_effective_dt_tm ';;q', n.source_string
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, allergy a
	, nomenclature n
 
plan d
 
join a where a.person_id = pat->plist[d.seq].patientid
	and a.active_ind = 1
 
join n where n.nomenclature_id = a.substance_nom_id
	and n.active_ind = 1
	and cnvtlower(n.source_string) in('chlorhexidine topical', 'chlorhexidine gluconate')
	and cnvtlower(n.source_identifier) = 'd01231'
 
order by a.person_id, a.encntr_id
 
Head a.person_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5),a.person_id ,pat->plist[icnt].patientid)
	while(idx > 0)
		pat->plist[idx].allergy_doc = trim(n.source_string)
		pat->plist[idx].allergy_doc_dt = format(a.created_dt_tm, 'mm/dd/yy hh:mm ;;q')
		pat->plist[idx].allergy_begdt = format(a.beg_effective_dt_tm, 'mm/dd/yy hh:mm ;;q')
		pat->plist[idx].allergy_enddt = format(a.end_effective_dt_tm, 'mm/dd/yy hh:mm ;;q')
	      idx = locateval(icnt,(idx+1) ,size(pat->plist,5),a.person_id ,pat->plist[icnt].patientid)
	endwhile
 
with nocounter
 
;------------------------------------------------------------------------------------------------------------------
;chlorhexidine treatment
 
select into $outdev
ce.encntr_id, ce.event_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm ';;q'
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, clinical_event ce
 
plan d
 
join ce where ce.encntr_id = pat->plist[d.seq].encntrid
	and ce.event_cd =  chg_treat_var
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
					and ce1.event_cd = ce.event_cd
					and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
					and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
					group by ce1.encntr_id, ce1.event_cd)
 
order by ce.encntr_id
 
Head ce.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,ce.encntr_id ,pat->plist[icnt].encntrid)
	pat->plist[idx].chlor_treatment = trim(ce.result_val)
	pat->plist[idx].chg_complete_dt = format(ce.event_end_dt_tm, 'mm/dd/yy hh:mm ;;q')
with nocounter
 
;------------------------------------------------------------------------------------------------------------------
;CVL and Foley Start...
 
select into $outdev
ce.encntr_id, ce.event_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm ';;q'
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, clinical_event ce
 
plan d
 
join ce where ce.encntr_id = pat->plist[d.seq].encntrid
	and ce.event_cd in(urinary_cath_var, central_line_var)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and cnvtlower(ce.result_val) != "straight/intermittent"
	and cnvtlower(ce.result_val) in('present on admission','present on admission.','uc present on admission','insert',
		'inserted','inserted in surgery/procedure','uc inserted in surgery/procedure','cl access port')
	/*and not exists (select ce1.encntr_id from clinical_event ce1
				where(ce1.encntr_id = ce.encntr_id
				and ce1.event_cd = ce.event_cd
				and cnvtlower(ce1.result_val) = "discontinued"))*/
 
order by ce.encntr_id, ce.event_cd
 
Head ce.encntr_id
	idx = 0
	icnt = 0
	cvl_list = fillstring(1000," "), foley_list = fillstring(1000," ")
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,ce.encntr_id ,pat->plist[icnt].encntrid)
Detail
	case(ce.event_cd)
		of urinary_cath_var:
			pat->plist[idx].foley_action = trim(ce.result_val)
			pat->plist[idx].foley_beg_dt = format(ce.event_end_dt_tm, 'mm/dd/yy hh:mm ;;q')
		of central_line_var:
			pat->plist[idx].cvl_action = trim(ce.result_val)
			pat->plist[idx].cvl_beg_dt = format(ce.event_end_dt_tm, 'mm/dd/yy hh:mm ;;q')
	endcase
with nocounter
 
 
;------------------------------------------------------------------------------------------------------------------
;CVL and Foley end...
 
select into $outdev
ce.encntr_id, ce.event_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm ';;q'
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, clinical_event ce
 
plan d
 
join ce where ce.encntr_id = pat->plist[d.seq].encntrid
	and ce.event_cd in(urinary_cath_var, central_line_var)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.result_val = "Discontinued"
 
order by ce.encntr_id, ce.event_cd
 
Head ce.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,ce.encntr_id ,pat->plist[icnt].encntrid)
Detail
	case(ce.event_cd)
		of urinary_cath_var:
			pat->plist[idx].foley_end_dt = format(ce.event_end_dt_tm, 'mm/dd/yy hh:mm ;;q')
		of central_line_var:
			pat->plist[idx].cvl_end_dt = format(ce.event_end_dt_tm, 'mm/dd/yy hh:mm ;;q')
	endcase
with nocounter
 
;------------------------------------------------------------------------------------------------------------------
;Cvl and Foley indication & type
 
select into $outdev
 
ce.encntr_id, ce.event_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm ';;q'
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, clinical_event ce
 
plan d
 
join ce where ce.encntr_id = pat->plist[d.seq].encntrid
	and ce.event_cd in(cvl_indication_var, cvl_type_var, foley_indication_var, foley_type_var)
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
					and ce1.event_cd = ce.event_cd
					and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
					and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
					group by ce1.encntr_id, ce1.event_cd)
 
order by ce.encntr_id, ce.event_cd
 
Head ce.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,ce.encntr_id ,pat->plist[icnt].encntrid)
Head ce.event_cd
	case(ce.event_cd)
      	of cvl_indication_var:
			pat->plist[idx].cvl_indcat = trim(ce.result_val)
			pat->plist[idx].cvl_indcat_dt = format(ce.event_end_dt_tm, 'mm/dd/yy hh:mm ;;q')
		of cvl_type_var:
			pat->plist[idx].cvl_typ = trim(ce.result_val)
		of foley_indication_var:
			pat->plist[idx].foley_indcat = trim(ce.result_val)
			pat->plist[idx].foley_indcat_dt = format(ce.event_end_dt_tm, 'mm/dd/yy hh:mm ;;q')
		of foley_type_var:
			pat->plist[idx].foley_typ = trim(ce.result_val)
	endcase
 
with nocounter
 
 
;------------------------------------------------------------------------------------------------------------------
;Task information
 
select into $outdev
 
ta.encntr_id, task_status = uar_get_code_display(ta.task_status_cd), task_loc = uar_get_code_display(ta.location_cd)
,ta.task_create_dt_tm ';;q', ot.task_description
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, task_activity ta
	, order_task ot
 
plan d
 
join ta where ta.encntr_id = pat->plist[d.seq].encntrid
	and ta.active_ind = 1
 
join ot where ot.reference_task_id = ta.reference_task_id
	and ot.task_description = "Perform Chlorhexidine Treatment"
	and ot.active_ind = 1
 
order by ta.encntr_id, ta.task_id
 
Head ta.encntr_id
	idx = 0
	icnt = 0
	task_list = fillstring(1000," ")
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,ta.encntr_id ,pat->plist[icnt].encntrid)
      tcnt = 0
Head ta.task_id
      task_list = build2(trim(task_list),'[ Task_dt = ',format(ta.task_create_dt_tm, 'mm/dd/yy hh:mm ;;q'),
      	' - Status = ', trim(uar_get_code_display(ta.task_status_cd)),']',',')
Foot ta.encntr_id
		pat->plist[idx].task_info = replace(trim(task_list),",","",2)
 
	/*tcnt += 1
	call alterlist(pat->plist[idx]->task, tcnt)
	pat->plist[idx].task[tcnt].tsk_name = ot.task_description
	pat->plist[idx].task[tcnt].tsk_dt = format(ta.task_create_dt_tm, 'mm/dd/yy hh:mm ;;q')
	pat->plist[idx].task[tcnt].tsk_status = uar_get_code_display(ta.task_status_cd)
	pat->plist[idx].task[tcnt].tskid = ta.task_id*/
 
with nocounter
 
;------------------------------------------------------------------------------------------------------------------
;Task Not done reason
 
select into $outdev
ce.encntr_id, ce.event_title_text, ce.result_val
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, clinical_event ce
 
plan d
 
join ce where ce.encntr_id = pat->plist[d.seq].encntrid
	and trim(ce.event_title_text) = chg_task_var
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
					where ce1.encntr_id = ce.encntr_id
					and ce1.event_title_text = ce.event_title_text
					and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
					group by ce1.encntr_id, ce1.event_title_text)
 
order by ce.encntr_id
 
Head ce.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,ce.encntr_id ,pat->plist[icnt].encntrid)
	if(idx > 0)
		pat->plist[idx].tsk_not_done_doc = trim(ce.result_val)
		pat->plist[idx].tsk_not_done_doc_dt = format(ce.event_end_dt_tm, 'mm/dd/yy hh:mm ;;q')
	endif
 
with nocounter
 
;------------------------------------------------------------------------------------------------------------------
;Chg treatment Not Done Reason
 
select into $outdev
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, clinical_event ce
 
plan d
 
join ce where ce.encntr_id = pat->plist[d.seq].encntrid
	and ce.event_cd = value(uar_get_code_by("DISPLAY", 72, "Chlorhexidine treatment"))
	and ce.result_status_cd in (34.00, 25.00, 35.00)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_val in("Not done due to patient allergy, Patient refused" , "Not done due to patient allergy" , "Patient refused")
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
					where ce1.encntr_id = ce.encntr_id
					and ce1.event_cd = ce.event_cd
					group by ce1.encntr_id, ce1.event_cd)
 
order by ce.encntr_id
 
Head ce.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,ce.encntr_id ,pat->plist[icnt].encntrid)
	if(idx > 0)
		pat->plist[idx].chg_not_done_doc = trim(ce.result_val)
		pat->plist[idx].chg_not_done_doc_dt = format(ce.event_end_dt_tm, 'mm/dd/yy hh:mm ;;q')
	endif
 
with nocounter
 
call echorecord(pat)
 
;------------------------------------------------------------------------------------------------------------------
;Final Result
 
select into $outdev
	facility = trim(substring(1, 30, pat->plist[d1.seq].facility))
	, unit = trim(substring(1, 30, pat->plist[d1.seq].unit))
	, fin = trim(substring(1, 30, pat->plist[d1.seq].fin))
	, patient_name = trim(substring(1, 50, pat->plist[d1.seq].pat_name))
	, patient_type = trim(substring(1, 30, pat->plist[d1.seq].pat_type))
	, admit_dt = format(pat->plist[d1.seq].admitdt,'mm/dd/yyyy hh:mm:ss ;;q')
	, cvl_activity = trim(substring(1, 30, pat->plist[d1.seq].cvl_action))
	, cvl_begin_dt = trim(substring(1, 30, pat->plist[d1.seq].cvl_beg_dt))
	, cvl_indication = trim(substring(1, 30, pat->plist[d1.seq].cvl_indcat))
	, cvl_indication_doc_dt = trim(substring(1, 30, pat->plist[d1.seq].cvl_indcat_dt))
	, cvl_type = trim(substring(1, 30, pat->plist[d1.seq].cvl_typ))
	, cvl_discontinue_dt = trim(substring(1, 30, pat->plist[d1.seq].cvl_end_dt))
	, foley_activity = trim(substring(1, 30, pat->plist[d1.seq].foley_action))
	, foley_begin_dt = trim(substring(1, 30, pat->plist[d1.seq].foley_beg_dt))
	, foley_indication = trim(substring(1, 30, pat->plist[d1.seq].foley_indcat))
	, foley_indication_doc_dt = trim(substring(1, 30, pat->plist[d1.seq].foley_indcat_dt))
	, foley_type = trim(substring(1, 30, pat->plist[d1.seq].foley_typ))
	, foley_discontinue_dt = trim(substring(1, 30, pat->plist[d1.seq].foley_end_dt))
	, chlorhexidine_treatment = trim(substring(1, 50, pat->plist[d1.seq].chlor_treatment))
	, chg_perform_dt = trim(substring(1, 50, pat->plist[d1.seq].chg_complete_dt))
	, chg_task_fired = trim(substring(1, 1000, pat->plist[d1.seq].task_info))
	, task_not_done_reason = trim(substring(1, 100, pat->plist[d1.seq].tsk_not_done_doc))
	, task_not_done_reason_dt = trim(substring(1, 30, pat->plist[d1.seq].tsk_not_done_doc_dt))
	, allergy_documentation = trim(substring(1, 200, pat->plist[d1.seq].allergy_doc))
	, allergy_begin_dt = trim(substring(1, 30, pat->plist[d1.seq].allergy_begdt))
	, allergy_end_dt = trim(substring(1, 30, pat->plist[d1.seq].allergy_enddt))
	, chg_not_done_reason = trim(substring(1, 100, pat->plist[d1.seq].chg_not_done_doc))
	, chg_not_done_reason_dt = trim(substring(1, 30, pat->plist[d1.seq].chg_not_done_doc_dt))
 
	;, task_name = trim(substring(1, 100, pat->plist[d1.seq].task[d2.seq].tsk_name))
	;, task_fired_dt = trim(substring(1, 30, pat->plist[d1.seq].task[d2.seq].tsk_dt))
	;, task_status = trim(substring(1, 30, pat->plist[d1.seq].task[d2.seq].tsk_status))
 
FROM
	(dummyt   d1  with seq = size(pat->plist, 5))
	;, (dummyt   d2  with seq = 1)
 
plan d1; where maxrec(d2, size(pat->plist[d1.seq].task, 5))
;join d2
 
order by unit, patient_name
 
WITH nocounter, separator=" ", format
 
 
;---------------------------------- NOT NEEDED AS OF 05/20/21- LORI --------------------------------------------------------------------------------
 
;MRSA documentation -Problem
/*
select into $outdev
 
p.person_id, n.nomenclature_id, n.source_string, start_eff_dt = format(p.beg_effective_dt_tm, 'mm/dd/yy hh:mm ;;q')
,end_eff_dt = format(p.end_effective_dt_tm, 'mm/dd/yy hh:mm ;;q')
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, problem p
	, nomenclature n
 
plan d
 
join p where p.person_id = pat->plist[d.seq].patientid
	and p.active_ind = 1
	and p.confirmation_status_cd = 3305.00 ;Confirmed
	and p.data_status_cd in(23.00,25.00,34.000);Active, Verified, Modified
 
join n where n.nomenclature_id = p.nomenclature_id
	and n.active_ind = 1
	and n.nomenclature_id in(7794500,7958649,8787155,10999060,11705547,13247390,13325322,17761300
		,17821788,273232044,273245604,275273024,281232681
		,291205716,8788824,13246940,13247261,13247390,13260527,13271142,13321551)
 
order by p.person_id, n.nomenclature_id
 
Head p.person_id
	idx = 0
	icnt = 0
	problem_list = fillstring(1000," ")
      idx = locateval(icnt ,1 ,size(pat->plist,5),p.person_id ,pat->plist[icnt].patientid)
 
Head n.nomenclature_id
      problem_list = build2(trim(problem_list),'[' ,trim(n.source_string),' - (Effective) - ',start_eff_dt,' TO ',end_eff_dt,']',',')
 
Foot p.person_id
	while(idx > 0)
		pat->plist[idx].mrsa_p_doc = replace(trim(problem_list),",","",2)
	      idx = locateval(icnt,(idx+1) ,size(pat->plist,5),p.person_id ,pat->plist[icnt].patientid)
	endwhile
 
with nocounter
 
;----------------------------------------------------------------------------------------------------------
;MRSA documentation - Diagnosis
 
select into $outdev
 
dg.person_id, n.nomenclature_id, n.source_string, start_eff_dt = format(dg.beg_effective_dt_tm, 'mm/dd/yy hh:mm ;;q')
,end_eff_dt = format(dg.end_effective_dt_tm, 'mm/dd/yy hh:mm ;;q')
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, diagnosis dg
	, nomenclature n
 
plan d
 
join dg where dg.person_id = pat->plist[d.seq].patientid
	and dg.active_ind = 1
 
join n where n.nomenclature_id = dg.nomenclature_id
	and n.active_ind = 1
	and n.nomenclature_id in(7794500,7958649,8787155,10999060,11705547,13247390,13325322,17761300
		,17821788,273232044,273245604,275273024,281232681
		,291205716,8788824,13246940,13247261,13247390,13260527,13271142,13321551)
 
order by dg.person_id, n.nomenclature_id
 
Head dg.person_id
	idx = 0
	icnt = 0
	diagnosis_list = fillstring(1000," ")
      idx = locateval(icnt ,1 ,size(pat->plist,5),dg.person_id ,pat->plist[icnt].patientid)
 
Head n.nomenclature_id
	diagnosis_list = build2(trim(diagnosis_list),'[' ,trim(n.source_string),' - (Effective) - ',start_eff_dt,' TO ',end_eff_dt,']',',')
 
Foot dg.person_id
	while(idx > 0)
		pat->plist[idx].mrsa_dg_doc = replace(trim(diagnosis_list),",","",2)
	      idx = locateval(icnt,(idx+1) ,size(pat->plist,5),dg.person_id ,pat->plist[icnt].patientid)
	endwhile
 
with nocounter
*/
;------------------------------------------------------------------------------------------------------------
 
 
 
ENDIF
 
 
#exitscript
 
end
go
 
