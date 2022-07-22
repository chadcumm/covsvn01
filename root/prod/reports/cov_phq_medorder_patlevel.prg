 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha
	Date Written:		Apr'2019
	Solution:			Quality
	Source file name:	      cov_phq_medorder_patlevel.prg
	Object name:		cov_phq_medorder_patlevel
	Request#:			4903
	Program purpose:	      As per Tommy & Lori's request - communication type validation - CPOE
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
 
drop program cov_phq_medorder_patlevel:dba go
create program cov_phq_medorder_patlevel:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "FIN" = ""
 
with OUTDEV, fin
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
;Get all orders
 
select distinct into $outdev
 
fin = ea.alias, patient_name = trim(p.name_full_formatted)
,admit_dt = format(e.reg_dt_tm, 'mm/dd/yyyy hh:mm;;q')
,disch_dt = format(e.disch_dt_tm, 'mm/dd/yyyy hh:mm;;q')
,o.order_id, order_type = trim(uar_get_code_display(o.med_order_type_cd))
,order_status = trim(uar_get_code_display(oa.order_status_cd))
,oa.action_sequence, action_type = trim(uar_get_code_display(oa.action_type_cd))
,action_dt = format(oa.action_dt_tm, 'mm/dd/yyyy hh:mm;;q')
,communication_type = trim(uar_get_code_display(oa.communication_type_cd))
,order_dt = format(oa.order_dt_tm, 'mm/dd/yyyy hh:mm;;q') , order_mnemonic = trim(o.order_mnemonic)
 
from
	encounter e
	,orders o
	,order_action oa
	,encntr_alias ea
	,person p
 
plan ea where ea.alias = $fin
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
join e where e.encntr_id = ea.encntr_id
	and e.active_ind = 1
	and e.encntr_id != 0.00
 
join o where o.encntr_id = e.encntr_id
	and o.active_ind = 1
	;and o.med_order_type_cd = 10915.00 ;Med
 
join oa where oa.order_id = o.order_id
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
order by ea.alias, oa.action_sequence
 
with nocounter, separator=" ", format
 
end
go
 
 
 
 
 
 
 
