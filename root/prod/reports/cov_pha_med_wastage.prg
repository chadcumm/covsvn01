/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Jan'2020
	Solution:			Pharmacy
	Source file name:	      cov_pha_med_wastage.prg
	Object name:		cov_pha_med_wastage
	Request#:
	Program purpose:
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------*/
 
drop program cov_pha_med_wastage go
create program cov_pha_med_wastage
 
prompt
	"Output to File/Printer/MINE" = "MINE"       ;* Enter or select the printer or file name to send this report to.
	, "Start Admit Date/Time" = "SYSDATE"
	, "End Admit Date/Time" = "SYSDATE"
	, "Select Facility" = 0
 
with OUTDEV, start_datetime, end_datetime, facility_list
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare pca_waste_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, 'PCA Waste')),protect
declare pca_waste_amount_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, 'PCA Wasted Amount')),protect
declare pca_unit_measure_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, 'PCA Concentration Unit of Measure')),protect
declare pca_dose_mg_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, 'PCA Total Dose Given/4hr (mg)')),protect
declare pca_dose_mcg_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, 'PCA Total Dose Given/4hr (mcg)')),protect
declare pca_medication_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, 'PCA Medication')),protect
 
/*
 2569947375.00	PCA Waste
 2569947529.00	PCA Wasted Amount
    4180353.00	PCA Concentration Unit of Measure
 2569952355.00	PCA Total Dose Given/4hr (mg)
 2569961961.00	PCA Total Dose Given/4hr (mcg)
 2986470123.00	PCA Medication
*/
 
Record med(
	1 reccnt = i4
	1 plist[*]
		2 facility = vc
		2 encntrid = f8
		2 personid = f8
		2 fin = vc
		2 pca_waste = vc
		2 pca_waste_amount_var  = vc
		2 pca_unit_measure_var  = vc
		2 pca_dose_mg_var       = vc
		2 pca_dose_mcg_var      = vc
		2 pca_medication_var    = vc
		2 med_dispense = f8
)
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
;Get Demographic
select into 'nl:'
 
from encounter e, encntr_alias ea
 
plan e where e.loc_facility_cd = $facility_list
	and e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	;and e.encntr_type_cd in(309310.00, 309308.00, 309312.00, 19962820.00, 2555267433.00, 309311.00)
			;Emergency, Inpatient, Observation, Outpatient in a Bed, Newborn, Day Surgery
	and e.encntr_id != 0.00
	and e.active_ind = 1
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
order by e.encntr_id
 
Head report
 	cnt = 0
Head e.encntr_id
 	cnt += 1
 	med->reccnt = cnt
 	call alterlist(med->plist, cnt)
Detail
 	med->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
 	med->plist[cnt].personid = e.person_id
 	med->plist[cnt].encntrid = e.encntr_id
 	med->plist[cnt].fin = ea.alias
 
with nocounter
 
call echorecord(med)
 
;------------------------------------------------------------------------------------------------------
;Get Clinical events
 
select into $outdev
facility = med->plist[d.seq].facility
,fin = med->plist[d.seq].fin
;ce.encntr_id, ce.order_id
, event = uar_get_code_description(ce.event_cd), ce.result_val
;, ce.event_id, ce.parent_event_id, ce.ce_dynamic_label_id
;, ce.event_title_text, ce.event_tag, ce.view_level
;, result_status = uar_get_code_display(ce.result_status_cd)
;, event_start_dt  = format(ce.event_start_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, event_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
;, perform_dt = format(ce.performed_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
;, verify_dt = format(ce.verified_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
 
 
from (dummyt d with seq = value(size(med->plist,5)))
	, clinical_event ce
 
plan d
 
join ce where ce.encntr_id = med->plist[d.seq].encntrid
	and ce.person_id = med->plist[d.seq].personid
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00")
	and ce.event_cd in(pca_waste_var, pca_waste_amount_var, pca_unit_measure_var, pca_dose_mg_var, pca_dose_mcg_var, pca_medication_var)
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth (Verified), Modified
 
order by ce.encntr_id, ce.event_start_dt_tm, ce.event_id, ce.event_cd
 
with nocounter, separator=" ", format
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 
 
;select * from med_admin_event mae where mae.order_id =  2492682061.00
