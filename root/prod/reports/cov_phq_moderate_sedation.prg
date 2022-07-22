 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha
	Date Written:		Feb'2019
	Solution:			Quality/Nursing
	Source file name:  	cov_phq_moderate_sedation.prg
	Object name:		cov_phq_moderate_sedation
	CR#:				1204
 
	Program purpose:		Quality - patient's with moderate sedation.
	Executing from:		CCL/DA2
  	Special Notes:		used for Joint Commission Review
 
******************************************************************************
*  GENERATED MODIFICATION CONTROL LOG
*
*  Revision #   Mod Date    Developer             Comment
*  -----------  ----------  --------------------  ----------------------------
*
*
******************************************************************************/
 
drop program cov_phq_moderate_sedation:DBA go
create program cov_phq_moderate_sedation:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Select Facility" = 0 

with OUTDEV, start_datetime, end_datetime, facility_list
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare initcap() = c100
declare anes_type_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, "Anesthesia Type Adult Procedure")),protect
declare pat_tole_proc_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Patient Tolerated Procedure")),protect
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
select distinct into $outdev
 
Facility = trim(uar_get_code_display(e.loc_facility_cd))
;, e.person_id, e.encntr_id
, admit_nurse_unit = trim(uar_get_code_display(e.loc_nurse_unit_cd))
, fin = trim(ea.alias)
, patient_name = trim(p.name_full_formatted)
;, anesthesia_type_event = uar_get_code_display(ce.event_cd)
, anesthesia_type = trim(ce.result_val)
, anes_event_date = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;q')
, performed_nurse_unit = trim(uar_get_code_display(elh.loc_nurse_unit_cd))
;, ce.txn_id_text
;, tolerated_proc_event = uar_get_code_display(ce1.event_cd)
, patient_tolerated_procedure = trim(ce1.result_val)
, proc_event_date = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;q')
;, ce1.txn_id_text
 
 
from
	encounter e
	,clinical_event ce
	,clinical_event ce1
	,encntr_loc_hist elh
	,encntr_alias ea
	,person p
 
plan e where e.loc_facility_cd = $facility_list
	;e.loc_nurse_unit_cd = $nurse_unit
	and e.active_ind = 1
 
join ce where ce.person_id = e.person_id
	and ce.encntr_id = e.encntr_id
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
      and ce.view_level = 1
      and ce.publish_flag = 1 ;active
      and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
      and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth (Verified), Modified
 	and ce.event_cd = anes_type_var ;Moderate Sedation
 	and cnvtlower(ce.result_val) = '*moderate*'
 
join ce1 where ce1.person_id = ce.person_id
	and ce1.encntr_id = ce.encntr_id
	and ce1.txn_id_text = ce.txn_id_text
      and ce1.view_level = 1
      and ce1.publish_flag = 1 ;active
      and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
      and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth (Verified), Modified
 	and ce1.event_cd = pat_tole_proc_var ;Tolerated Procedure
 	and (cnvtlower(ce1.result_val) = 'yes' OR cnvtlower(ce1.result_val) = 'no')
 
join elh where elh.encntr_id = outerjoin(ce.encntr_id)
	and elh.beg_effective_dt_tm <= outerjoin(ce.event_end_dt_tm)
	and elh.end_effective_dt_tm >= outerjoin(ce.event_end_dt_tm)
	and elh.active_ind = outerjoin(1)
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
join p where p.person_id = e.person_id
 
order by e.loc_facility_cd, e.loc_nurse_unit_cd, anes_event_date, proc_event_date, patient_name, fin
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT, time = 120
 
 
end
go
 
 
; 2559791171.00	Anesthesia Type Adult Procedure
; 2555198569.00	Patient Tolerated Procedure
 
