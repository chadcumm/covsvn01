 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha
	Date Written:		Feb'2019
	Solution:			Quality/Nursing
	Source file name:  	cov_phq_past_suicide_orders.prg
	Object name:		cov_phq_past_suicide_orders
	CR#:				AdHoc referencing CR# 4428
 
	Program purpose:		Quality - Columbia Suicide Severity Rating Scale Screen or CSSRS
	Executing from:		CCL/DA2
  	Special Notes:		used for Joint Commission Review
 
******************************************************************************/
 
drop program cov_phq_past_suicide_orders:DBA go
create program cov_phq_past_suicide_orders:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
 
with OUTDEV, start_datetime, end_datetime
 
;---------------------------------------------------------------------------------------------------------------------------
;Active orders on given past date
 
select into $outdev
 
fin = trim(ea.alias), patient_name = trim(p.name_full_formatted)
, o.order_id, original_order_initiate_dt = o.orig_order_dt_tm "@SHORTDATETIME"
, order_mnemonic = trim(o.order_mnemonic)
, action_sequence = oa.action_sequence
, action_type = uar_get_code_display(oa.action_type_cd)
, order_action_dt = oa.order_dt_tm "@SHORTDATETIME"
, discharge_dt = e.disch_dt_tm "@SHORTDATETIME"
 
from
	orders o
	, encounter e
	, order_action oa
	, encntr_alias ea
	, person p
 
plan o where o.orig_order_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and o.template_order_id = 0.00
	and o.active_ind = 1
	and o.catalog_cd = 4149527.00	;Precaution Suicide
 
join e where e.encntr_id = o.encntr_id
	and e.active_ind = 1
 
join oa where oa.order_id = o.order_id
	and oa.action_type_cd in(2534.00, 2532.00) ;order, discontinue
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
order by o.encntr_id, oa.order_id, oa.action_sequence, oa.order_dt_tm
 
with nocounter, separator=" ", format
 
 
end go
 
 
 
