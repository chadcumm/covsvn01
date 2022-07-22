 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:				Chad Cummings
	Date Written:		Apr'2019
	Solution:			Quality
	Source file name:	cov_cpoe_report_by_prsnl.prg
	Object name:		cov_cpoe_report_by_prsnl
	Request#:			
	Program purpose:	CPOE communication type validation
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_amb_cpoe_report:dba go
create program cov_amb_cpoe_report:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Search By" = 0
	, "New Provider" = 0
	;<<hidden>>"Search" = ""
	;<<hidden>>"Delete" = ""
	, "Facility" = 0 

with OUTDEV, START_DATETIME, END_DATETIME, SEARCH_BY, NEW_PROVIDER, FACILITY
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare action_seq_var = i4 with noconstant(0)
declare inpatient_var  = f8 with constant(uar_get_code_by("DISPLAY", 71, "Inpatient")), protect
 
 
 
Record orders(
	1 rec_cnt = i4
	1 olist[*]
		2 facility = vc
		2 fin = vc
		2 patient_name = vc
	 	2 encntrid = f8
	 	2 orderid = f8
	 	2 order_dt = vc
	 	2 admit_dt = vc
	 	2 disch_dt = vc
	 	2 comm_type_cd = f8
	 	2 comm_type = vc
	 	2 order_status = vc
	 	2 order_type = vc
	 	2 order_mnemonic = vc
	 	2 action_seq = i4
	 	2 action_dt = vc
	 	2 contributing_system = vc
)
 
Record tot(
	1 list[*]
		2 facility = vc
		2 comm_type = vc
		2 order_tot = i4
)
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
;Get orders
 
select into $outdev
 provider=i.p2name
,fin = i.alias
,patient_name = trim(i.name_full_formatted)
,order_type = trim(uar_get_code_display(i.med_order_type_cd))
,order_status = trim(uar_get_code_display(i.order_status_cd))
,i.action_sequence
,action_type = trim(uar_get_code_display(i.action_type_cd))
,action_dt = format(i.action_dt_tm, 'mm/dd/yyyy hh:mm;;q')
,communication_type = trim(uar_get_code_display(i.communication_type_cd))
,i.denominator
,i.numerator
,order_dt = format(i.orig_order_dt_tm, 'mm/dd/yyyy hh:mm;;q')
,order_mmyyyy = format(i.orig_order_dt_tm, 'YYYYMM;;q')
,order_mnemonic = trim(i.order_mnemonic), i.order_id
,admit_dt = format(i.reg_dt_tm, 'mm/dd/yyyy hh:mm;;q')
,disch_dt = format(i.disch_dt_tm, 'mm/dd/yyyy hh:mm;;q')
,patient_type = trim(uar_get_code_display(i.encntr_type_cd))
,facility=trim(uar_get_code_display(i.loc_facility_cd))
,nurse_unit=trim(uar_get_code_display(i.loc_nurse_unit_cd))
from(
(select distinct
	p2name = p2.name_full_formatted,
	ea.alias,
	p.name_full_formatted,
	e.reg_dt_tm,
	e.disch_dt_tm,
	e.encntr_type_cd,
	o.order_id,
	e.encntr_id,
	e.person_id
	,o.med_order_type_cd,
	oa.order_status_cd,
	oa.action_sequence,
	oa.action_type_cd,
	oa.action_dt_tm,
	oa.communication_type_cd
	,o.orig_order_dt_tm,
	o.order_mnemonic
	, denominator = 1
	, numerator = evaluate2(
		if(oa.communication_type_cd     = 2560) 0 ;Telephone Read Back/Verified Cosign
		elseif(oa.communication_type_cd = 2561) 0 ;Verbal Read Back/Verified Cosign
		elseif(oa.communication_type_cd = 2562) 1 ;Direct
		elseif(oa.communication_type_cd = 54416801) 0	;Written Paper Order/Fax No Cosign
		elseif(oa.communication_type_cd = 2576706321) 0 ;Per Nutrition Policy No Cosign
		elseif(oa.communication_type_cd = 2553560097) 0 ;Per Protocol No Cosign
		elseif(oa.communication_type_cd = 2553560089) 1 ;Standing Order Cosign
		else 0 endif)
	,e.loc_facility_cd
	,e.loc_nurse_unit_cd
	;,p1.name_full_formatted
	;,p1.position_cd
	;,p2.name_full_formatted
	;,p2.position_cd
	from encounter e, orders o, order_action oa, encntr_alias ea, person p,prsnl p1,prsnl p2
	;removed for dr. specific: where e.loc_facility_cd = $acute_facility_list
 	where e.encntr_type_cd > 0.0 ;setup for just DR.
	and e.active_ind = 1
	;; and e.encntr_id != 0.00 ;;UPDATED FOR AMBULATORY
	;; and o.encntr_id = e.encntr_id ;;UPDATED FOR AMBULATORY
	and o.originating_encntr_id = e.encntr_id ; UPDATED FOR AMBULATORY 
	and o.active_ind = 1
	and o.orig_order_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	;and o.orig_order_dt_tm between cnvtdatetime("01-APR-2019 00:00:00") and cnvtdatetime("01-MAY-2019 00:00:00")
	and o.template_order_flag in(0,1,5)
	and  o.orderable_type_flag != 6
 	and oa.order_id = o.order_id
	and oa.action_sequence = 1
	and oa.communication_type_cd in(
	      2560.00	;Telephone Read Back/Verified Cosign
       ,2561.00	;Verbal Read Back/Verified Cosign
      , 2562.00	;Direct
;     ,681544.00	;No Cosign Required
;   ,19468404.00	;Cosign Required
;   ,20094437.00	;Initiate Planned Orders No Cosign
   ,54416801.00	;Written Paper Order/Fax No Cosign
 ,2553560089.00	;Standing Order Cosign
; ,2553560097.00	;Per Protocol No Cosign
; ,2576706321.00	;Per Nutrition Policy No Cosign
	)
	and oa.template_order_flag in (0,1,5)
 	and ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 	and p.person_id = e.person_id
	and p.active_ind = 1
	and p1.person_id = oa.action_personnel_id
	and p2.person_id = oa.order_provider_id
	and parser(p2.person_id =$NEW_PROVIDER); specific Dr.
	with sqltype('vc','vc','vc','dq8','dq8','f8','f8','f8','f8','f8','f8','i2'
	,'f8','dq8','f8','dq8','vc','i2','i2','f8','f8')
	)i
)
 
order by provider,patient_name, communication_type
 
with nocounte, separator = " ", format
 
 
 
 
 
end
go
 
 
 
 
 
 
 
 
