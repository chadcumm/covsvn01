/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Jul'2021
	Solution:			Quality
	Source file name:	      cov_phq_covid_vaccin_status.prg
	Object name:		cov_phq_covid_vaccin_status
	Request#:			CR# 10900
	Program purpose:	      
	Executing from:		DA2/CCL
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------	------------------------------------------
******************************************************************************/
 
 
drop program cov_phq_covid_vaccin_status:dba go
create program cov_phq_covid_vaccin_status:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Acute Facility List" = 0 

with OUTDEV, acute_facility_list
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
;COVID19
declare sars_rna_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, 'SARS CoV2 RNA, RT PCR')), protect
declare sars_cov2_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, 'SARS-CoV-2')), protect
declare covid_reflab_var = f8 with constant(uar_get_code_by("DISPLAY", 72, 'COVID19 Reference Lab')), protect

;Vaccine
declare sars1_var = f8 with constant(uar_get_code_by("DISPLAY", 72, 'SARS-CoV-2 (COVID-19) mRNA-1273 vaccine')), protect
declare sars2_var = f8 with constant(uar_get_code_by("DISPLAY", 72, 'SARS-CoV-2 (COVID-19) mRNA BNT-162b2 vax')), protect
declare sars3_var = f8 with constant(uar_get_code_by("DISPLAY", 72, 'SARS-CoV-2 (COVID-19) ChAdOx1 vaccine')), protect
declare sars4_var = f8 with constant(uar_get_code_by("DISPLAY", 72, 'SARS-CoV-2 (COVID-19) Ad26 vaccine')), protect

declare 14day_vacin_var = f8 with constant(uar_get_code_by("DISPLAY", 72, '14 days post COVID-19 vaccine series')), protect
declare chief_complaint_var = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Chief Complaint')), protect 


 /*
 3655405385.00	SARS-CoV-2 (COVID-19) mRNA-1273 vaccine
 3655406899.00	SARS-CoV-2 (COVID-19) mRNA BNT-162b2 vax
 3751858609.00	SARS-CoV-2 (COVID-19) ChAdOx1 vaccine
 3751858835.00	SARS-CoV-2 (COVID-19) Ad26 vaccine
 3802078281.00	14 days post COVID-19 vaccine series
  704668.00		Chief Complaint
 */


 
declare cnt = i4 with noconstant(0)
declare covid_positive_var = vc with noconstant('')
declare mis_result_var = vc with noconstant('')
declare fever_result_var = vc with noconstant('')
 
set covid_positive_var = fillstring(1000," ")
set fever_result_var = fillstring(3000," ")
set mis_result_var = fillstring(3000," ")
 
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
RECORD vac(
	1 rec_cnt = i4
	1 plist[*]
		2 facility = vc
		2 unit = vc
		2 fin = vc
		2 encntrid = f8
		2 personid = f8
		2 pat_type = vc
		2 pat_name = vc
		2 reg_dt = vc
		2 disch_dt = vc
		2 vacin_last_act = vc
		2 vacin_last_act_dt = vc
		2 vacin_name = vc
		2 c14_day_answer = vc
		2 covid_result = vc
		2 diagnosis_rs = vc
		2 cf_complaint = vc
		2 visit_reason = vc
)
 
;-----------------------------------------------------------------------------------------------------------
;Patient population Vaccine history - nurse unit assigned for a given date range

select into $outdev
 
e.encntr_id
 
from
	encounter e
	,encntr_loc_hist elh
 
plan e where e.loc_facility_cd = $acute_facility_list
	and e.active_ind = 1
	and e.disch_dt_tm is null
	and e.encntr_status_cd = 854.00 ;Active
	and e.reg_dt_tm >= cnvtdatetime("01-JAN-2021 00:00:00")
 
join elh where elh.encntr_id = e.encntr_id
	;and elh.beg_effective_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and elh.active_ind = 1
	and (elh.beg_effective_dt_tm <= sysdate and elh.end_effective_dt_tm >= sysdate)
	
order by e.encntr_id	
 
Head Report
	cnt = 0
Head e.encntr_id
	cnt += 1
	vac->rec_cnt = cnt
	call alterlist(vac->plist, cnt)
Detail	
	vac->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	vac->plist[cnt].unit = uar_get_code_display(elh.loc_nurse_unit_cd)
	vac->plist[cnt].encntrid = e.encntr_id
	vac->plist[cnt].personid = e.person_id
	vac->plist[cnt].pat_type = uar_get_code_display(e.encntr_type_cd)
	vac->plist[cnt].reg_dt = format(e.reg_dt_tm, 'mm/dd/yy hh:mm ;;q')
	vac->plist[cnt].disch_dt = format(e.disch_dt_tm, 'mm/dd/yy hh:mm ;;q')
	if(cnvtlower(e.reason_for_visit) = 'gi bleed')
		vac->plist[cnt].visit_reason = e.reason_for_visit
	endif		
with nocounter 

if(vac->rec_cnt > 0)
;---------------------------------------------------------------------------
;Demographic

select into $outdev

from (dummyt d with seq = value(size(vac->plist, 5)))
	, person p
	, encntr_alias ea

plan d 

join p where p.person_id = vac->plist[d.seq].personid
	and p.active_ind = 1
	
join ea where ea.encntr_id = vac->plist[d.seq].encntrid
	and ea.active_ind = 1
	and ea.encntr_alias_type_cd = 1077	

order by ea.encntr_id

Head ea.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(vac->plist,5) ,ea.encntr_id ,vac->plist[icnt].encntrid)
	if(idx > 0)
		vac->plist[idx].pat_name = p.name_full_formatted
		vac->plist[idx].fin = trim(ea.alias)
	endif

with nocounter 

;--------------------------------------------------------------------------- 
;Immunization doc
 
select into $outdev
 
pat_id = vac->plist[d.seq].personid, ce.encntr_id, ce.event_id, immunization = uar_get_code_display(ce.event_cd)
,admin_date = cmr.admin_start_dt_tm ';;q'
 
from (dummyt d with seq = value(size(vac->plist, 5)))
	,clinical_event ce
	,ce_med_result cmr
 
plan d
 
join ce where ce.person_id = vac->plist[d.seq].personid
	and ce.event_cd in(sars1_var, sars2_var, sars3_var, sars4_var)
	;if there is 2 dose administered then it will pull the latest one
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 
	where ce1.person_id = ce.person_id
		and ce1.event_cd = ce.event_cd
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
		and ce1.result_status_cd IN (34.00, 25.00, 35.00)
		and ce.event_tag != "Date\Time Correction"
		group by ce1.encntr_id, ce1.event_cd)
		
join cmr where cmr.event_id = ce.event_id

order by pat_id

Head pat_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(vac->plist,5) ,pat_id ,vac->plist[icnt].personid)
	if(idx > 0)
		vac->plist[idx].vacin_last_act_dt = format(cmr.admin_start_dt_tm, 'mm/dd/yy hh:mm ;;q')
		vac->plist[idx].vacin_name = immunization
	endif

with nocounter 
 
;------------------------------------------------------------------------------------------------
;Post Vacin question

select into $outdev
 
ce.encntr_id, result = uar_get_code_display(ce.event_cd)
 
from (dummyt d with seq = value(size(vac->plist, 5)))
	,clinical_event ce
 
plan d
 
join ce where ce.encntr_id = vac->plist[d.seq].encntrid
	and ce.event_cd = 14day_vacin_var
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 
	where ce1.person_id = ce.person_id
		and ce1.event_cd = ce.event_cd
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
		and ce1.result_status_cd IN (34.00, 25.00, 35.00)
		and ce.event_tag != "Date\Time Correction"
		group by ce1.encntr_id, ce1.event_cd)
		
order by ce.encntr_id

Head ce.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(vac->plist,5), ce.encntr_id ,vac->plist[icnt].encntrid)
	if(idx > 0)
		vac->plist[idx].c14_day_answer = trim(ce.result_val)
	endif

with nocounter 

;------------------------------------------------------------------------------------------------
;Chief complaint

select into $outdev
 
ce.encntr_id, result = uar_get_code_display(ce.event_cd)
 
from (dummyt d with seq = value(size(vac->plist, 5)))
	,clinical_event ce
 
plan d
 
join ce where ce.encntr_id = vac->plist[d.seq].encntrid
	and ce.event_cd = chief_complaint_var
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 
	where ce1.person_id = ce.person_id
		and ce1.event_cd = ce.event_cd
		;and cnvtlower(trim(ce1.result_val)) = 'gi bleed'
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
		and ce1.result_status_cd IN (34.00, 25.00, 35.00)
		and ce.event_tag != "Date\Time Correction"
		group by ce1.encntr_id, ce1.event_cd)
		
order by ce.encntr_id

Head ce.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(vac->plist,5), ce.encntr_id ,vac->plist[icnt].encntrid)
	if(idx > 0)
		vac->plist[idx].cf_complaint = trim(ce.result_val)
	endif

with nocounter 

;------------------------------------------------------------------------------------------------
;Diagnosis

select into $outdev
 
dg.encntr_id, dg.diagnosis_display, dg_dt1 = format(dg.diag_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
 
from (dummyt d with seq = value(size(vac->plist, 5)))
	, diagnosis dg
 
plan d
 
join dg where dg.encntr_id = vac->plist[d.seq].encntrid
	and dg.active_ind = 1
	and (dg.beg_effective_dt_tm <= sysdate and dg.end_effective_dt_tm >= sysdate)
	and dg.beg_effective_dt_tm = (select max(dg1.beg_effective_dt_tm) from diagnosis dg1 where dg1.encntr_id = dg.encntr_id
			and dg1.diagnosis_display = dg.diagnosis_display
			group by dg1.diagnosis_display)
 
order by dg.encntr_id, dg.diag_priority asc 
 
Head dg.encntr_id
	icnt = 0
	ocnt = 0
 	idx = 0
      idx = locateval(icnt ,1 ,vac->rec_cnt ,dg.encntr_id ,vac->plist[icnt].encntrid)
      dg_list_var = fillstring(1000," ")
Detail
	if(idx > 0)
		dg_list_var = build2(trim(dg_list_var),trim(dg.diagnosis_display),',')
	endif
Foot dg.encntr_id
	vac->plist[idx].diagnosis_rs = replace(trim(dg_list_var),",","",2)
 
with nocounter


;------------------------------------------------------------------------------------------------
call echorecord(vac)

;with nocounter, separator=" ", format, time = 180
;go to exitscript

/*
;-----------------------------------------------------------------------------------------------------------

;Covid positive
 
select into $outdev
 
ce.encntr_id, elh.loc_nurse_unit_cd, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm ';;q'
 
from
	encounter e
	, encntr_loc_hist elh
	,clinical_event ce
 
plan e where e.loc_facility_cd = $acute_facility_list
	and e.active_ind = 1
	;and e.disch_dt_tm is null
 
join elh where elh.encntr_id = e.encntr_id
	and elh.beg_effective_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and elh.active_ind = 1
 
join ce where ce.encntr_id = e.encntr_id
	and ce.person_id = e.person_id
	and ce.event_cd in(sars_rna_var, sars_cov2_var, covid_reflab_var)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (25.00, 34.00, 35.00)
	and cnvtupper(ce.result_val) = 'POSITIVE'
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
		and ce1.event_cd = ce.event_cd
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
		and ce1.result_status_cd IN (34.00, 25.00, 35.00)
		group by ce1.encntr_id, ce1.event_cd)
 
order by e.encntr_id, ce.event_cd, ce.event_end_dt_tm

;with nocounter, separator=" ", format, time = 180

Head Report
	ecnt = 0
Head e.encntr_id
	cnt += 1
	mis->reccnt = cnt
	call alterlist(mis->plist, cnt)
	mis->plist[cnt].encntrid = e.encntr_id
	mis->plist[cnt].unit = uar_get_code_display(elh.loc_nurse_unit_cd)
	
Head ce.event_cd
	case (ce.event_cd)
		of sars_rna_var:
			covid_positive_var = build2(trim(covid_positive_var),'[' ,trim(event), ' - ', trim(ce.result_val)
					, ' - ', format(ce.event_end_dt_tm,"mm-dd-yy hh:mm;;d"),']',',')
		of sars_cov2_var:
			covid_positive_var = build2(trim(covid_positive_var),'[' ,trim(event), ' - ', trim(ce.result_val)
					, ' - ', format(ce.event_end_dt_tm,"mm-dd-yy hh:mm;;d"),']',',')
		of covid_reflab_var:
			covid_positive_var = build2(trim(covid_positive_var),'[' ,trim(event), ' - ', trim(ce.result_val)
					, ' - ', format(ce.event_end_dt_tm,"mm-dd-yy hh:mm;;d"),']',',')
	endcase
 
Foot e.encntr_id
	mis->plist[cnt].covid_result = replace(trim(covid_positive_var),",","",2)
 
with nocounter
*/
 
;------------------------------------------------------------------------------------------------
select into $outdev
	facility = trim(substring(1, 30, vac->plist[d1.seq].facility))
	, unit = trim(substring(1, 30, vac->plist[d1.seq].unit))
	, fin = trim(substring(1, 30, vac->plist[d1.seq].fin))
	;, encntrid = vac->plist[d1.seq].encntrid
	;, personid = vac->plist[d1.seq].personid
	, patient_type = trim(substring(1, 50, vac->plist[d1.seq].pat_type))
	, patient_name = trim(substring(1, 50, vac->plist[d1.seq].pat_name))
	, admit_dt = trim(substring(1, 30, vac->plist[d1.seq].reg_dt))
	, disch_dt = trim(substring(1, 30, vac->plist[d1.seq].disch_dt))
	, vacin_last_action = trim(substring(1, 30, vac->plist[d1.seq].vacin_last_act))
	, vacin_last_action_dt = trim(substring(1, 30, vac->plist[d1.seq].vacin_last_act_dt))
	, vacin_name = trim(substring(1, 100, vac->plist[d1.seq].vacin_name))
	, post_14_day_answer = trim(substring(1, 30, vac->plist[d1.seq].c14_day_answer))
	, diagnosis = trim(substring(1, 3000, vac->plist[d1.seq].diagnosis_rs))
	, chief_complaint = trim(substring(1, 300, vac->plist[d1.seq].cf_complaint))
	, visit_reason = trim(substring(1, 30, vac->plist[d1.seq].visit_reason))

from
	(dummyt   d1  with seq = size(vac->plist, 5))

plan d1

order by facility, unit

with nocounter, separator=" ", format


 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
endif ;rec_cnt
 
 
#exitscript
 
end
go


;BLOB - chief complaint
;https://community.cerner.com/t5/CCL-Discern-Explorer-Client-and/Trouble-finding-an-additional-comment-field/m-p/315509 
