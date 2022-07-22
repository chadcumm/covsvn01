/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Dec'2019
	Solution:			Pharmacy
	Source file name:	      cov_pha_discharge_rx_phys.prg
	Object name:		cov_pha_discharge_rx_phys
 	Request#:			6794
	Program purpose:	      Count of physicians prescribing in Cerner as per Tommy's request
	Executing from:		
 	Special Notes:          AdHoc based on Discharged Rx feed
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_pha_discharge_rx_phys:DBA go
create program cov_pha_discharge_rx_phys:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"      ;* Enter or select the printer or file name to send this report to.
	, "Start Discharge Date/Time" = "SYSDATE"
	, "End Discharge  Date/Time" = "SYSDATE"
	, "Location" = 0 

with OUTDEV, start_datetime, end_datetime, all_cov_facilities
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
*************************************************************/
 
declare super_phys_var   = f8 with constant(uar_get_code_by('DISPLAY', 333, 'Supervising Physician')), protect
declare star_var         = f8 with constant(uar_get_code_by("DISPLAY", 263, 'STAR Doctor Number')), protect
declare org_doc_var      = f8 with constant(uar_get_code_by("DISPLAY", 320, 'ORGANIZATION DOCTOR')), protect
 
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
RECORD rx(
	1 rx_rec_cnt = i4
	1 olist[*]
		2 facility = vc
		2 nurse_unit = vc
		2 fin = vc
		2 personid = f8
		2 encntrid = f8
		2 patient_name = vc
		2 orderid = f8
		2 medication_name = vc
		2 order_date = vc
		2 synonymid = f8
		2 charge_number = vc
		2 status = vc
		2 strength_dose = vc
		2 strength_dose_unit = vc
		2 route_of_admin_tmp = vc
		2 route_of_admin = vc
		2 volume_dose = vc
		2 volume_dose_unit = vc
		2 rate = vc
		2 rate_unit = vc
		2 drug_form = vc
		2 frequency = vc
		2 duration = vc
		2 duration_unit = vc
		2 quantity = f8
		2 quantity_unit = vc
		2 disp_qty = vc
		2 disp_unit = vc
		2 no_refil = vc
		2 tot_refil = vc
		2 prescriber = vc
		2 prescriber_id = f8
		2 prescriber_number = vc
		2 supervising_phys = vc
		2 supervising_phys_id = f8
		2 supervising_phys_number = vc
		2 order_cki = vc
		2 drug_class_code1 = vc
		2 drug_class_description1 = vc
		2 drug_class_code2 = vc
		2 drug_class_description2 = vc
		2 drug_class_code3 = vc
		2 drug_class_description3 = vc
		2 drug_generic_name = vc
		2 drug_brand_name = vc
		2 item_number = vc
		2 special_instruction = vc
 		2 med_start_date = vc
 		2 med_stop_date = vc
 		2 prn_instruction = vc
 		2 indication = vc
 		2 pharmacy_route = vc
 		2 pharmacy_name = vc
 		2 eRx_note_pharmacy = vc
)
 
;--------------------------------------------------------------------------------------------------------------
;Order qualification - changes need to be in both section(if statement)
 
select distinct into $outdev
 
 prescriber = trim(pr.name_full_formatted)
 
from
	encounter e
	, orders o
	, order_action oa
	, prsnl pr
 
plan e where e.loc_facility_cd != 0.00
	;and e.disch_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.active_ind = 1
	and e.encntr_id != 0
 
join o where o.encntr_id = e.encntr_id
	and o.orig_ord_as_flag = 1 ;Prescription/Discharge Order
	and o.active_ind = 1
	and o.order_status_cd in(2550.00) ;Ordered
	and o.activity_type_cd = 705.00 ;Pharmacy
 
join oa where oa.order_id = o.order_id
	and oa.action_sequence = o.last_action_sequence
 
join pr where pr.person_id = oa.order_provider_id
	and pr.active_ind = 1
 
with nocounter, separator=" ", format

end go 
 
