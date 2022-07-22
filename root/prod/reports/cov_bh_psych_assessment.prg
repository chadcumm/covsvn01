/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		July 2019
	Solution:			Behavior Health
	Source file name:	      cov_bh_psych_assessment.prg
	Object name:		cov_bh_psych_assessment
	Request#:			4223
	Program purpose:	      Psych Assessments Compliance Report
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/

drop program cov_bh_psych_assessment:dba go
create program cov_bh_psych_assessment:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Select Facility" = 0 

with OUTDEV, start_datetime, end_datetime, facility_list

/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare  adult_psych_var     = f8 with constant(uar_get_code_by("DISPLAY", 71, 'Hospital Adult Psych')), protect
declare  behavior_hlth_var   = f8 with constant(uar_get_code_by("DISPLAY", 71, 'Behavioral Health')), protect
declare  adulocent_psych_var = f8 with constant(uar_get_code_by("DISPLAY", 71, 'Hospital Adolescent Psych')), protect
declare  psych_form_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, 'BH Psychosocial Assessment Form')), protect

;2555137035.00	Hospital Adult Psych
;2555137051.00	Behavioral Health
;2555137131.00	Hospital Adolescent Psych
;33188349.00	BH Psychosocial Assessment Form


/**************************************************************
; DVDev Start Coding
**************************************************************/

select into $outdev

facility = trim(uar_get_code_display(e.loc_facility_cd))
, fin = ea.alias, patient_name = trim(p.name_full_formatted)
, admit_dt_tm = format(e.reg_dt_tm, 'mm/dd/yyyy hh:mm;;d')
, form_completed_dt_tm = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;d')
, form = uar_get_code_display(ce.event_cd) 
, patient_type = uar_get_code_display(e.encntr_type_cd)
, verified_by = trim(pr.name_full_formatted)
;,e.encntr_id, ce.event_cd, ce.event_id

from 
	encounter e 
	,encntr_alias ea
	,person p
	,clinical_event ce
	,prsnl pr

plan e where e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.loc_facility_cd = $facility_list
	and e.encntr_type_cd in (adult_psych_var, behavior_hlth_var, adulocent_psych_var)
		;(2555137035.00, 2555137051.00, 2555137131.00)
	and e.active_ind = 1
	
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
	
join p where p.person_id = e.person_id
	and p.active_ind = 1
	
join ce where ce.person_id = e.person_id
	and ce.encntr_id = e.encntr_id
	and ce.event_cd = psych_form_var
      and ce.view_level = 1 ;active
      and ce.publish_flag = 1 ;active
      and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
      and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth (Verified), Modified
	
join pr where pr.person_id = ce.verified_prsnl_id
	
order by e.loc_facility_cd, e.reg_dt_tm, p.name_full_formatted, ce.event_id

with nocounter, separator=" ", format


/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

end
go

