 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Apr'2020
	Solution:			Quality
	Source file name:	      cov_postop_nozin_order_rule.prg
	Object name:		cov_postop_nozin_order_rule
	Request#:			PostOp Nozin rule
	Program purpose:	      Active Postop order check
	Executing from:		CCL
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------*/
 
drop program cov_postop_nozin_order_rule:dba go
create program cov_postop_nozin_order_rule:dba
 
declare encntrid = f8 with noconstant(0.0), protect
declare personid = f8 with noconstant(0.0), protect
declare ccu_nu_var = vc with noconstant('')
declare active_nozin_var = vc with noconstant('')
declare active_bacto_var = vc with noconstant('')
 
;set personid = trigger_personid
set encntrid = trigger_encntrid
set retval = 0
 
;------------------------------------------------------------------------------------

;Evaluate if there is an active Nozin Postop order
select into 'nl:'
 
 o.encntr_id, o.order_id, o.template_order_id, o.ordered_as_mnemonic, o.order_status_cd
 , status = uar_get_code_display(o.order_status_cd) ,o.orig_order_dt_tm "@SHORTDATETIME", o.dept_misc_line
 , od.oe_field_meaning, od.oe_field_display_value , od1.oe_field_meaning, od1.oe_field_display_value
 
from orders o, order_detail od, order_detail od1
 
plan o where o.encntr_id = encntrid
	and o.catalog_cd = 2757685.00 ;Nozin / Ethanol Topical
	and o.active_ind = 1
	and o.order_status_cd = 2550.00 ;ordered
 
join od where od.order_id = o.order_id
	and od.action_sequence = 1
	and od.oe_field_id = 12690.00	;FREQ
	and trim(od.oe_field_display_value) = 'BID'
 
join od1 where od1.order_id = o.order_id
	and od1.action_sequence = 1
	and od1.oe_field_id = 663785.00 ;RXPRIORITY
	and trim(od1.oe_field_display_value) = 'STAT'
 
detail
	if(o.order_id is not null) active_nozin_var = 'Yes' endif
 
with nocounter
 
call echo(build2('active_nozin_var = ', active_nozin_var))
 
;------------------------------------------------------------------------------------
;Evaluate if there is an active Bactroban order
select into 'nl:'
 
 o.encntr_id, o.order_id, o.template_order_id, o.ordered_as_mnemonic, o.order_status_cd
 , status = uar_get_code_display(o.order_status_cd) ,o.orig_order_dt_tm "@SHORTDATETIME", o.dept_misc_line
 , od.oe_field_meaning, od.oe_field_display_value , od1.oe_field_meaning, od1.oe_field_display_value
 
from orders o, order_detail od, order_detail od1
 
plan o where o.encntr_id = encntrid
	and o.catalog_cd = 2764663.00	;Bactroban / mupirocin topical
	and o.active_ind = 1
	and o.order_status_cd = 2550.00 ;ordered
 
join od where od.order_id = o.order_id
	and od.action_sequence = 1
	and od.oe_field_id = 12690.00	;FREQ
	and trim(od.oe_field_display_value) = 'BID'
 
join od1 where od1.order_id = o.order_id
	and od1.action_sequence = 1
	and od1.oe_field_id = 12711.00 ;RXROUTE
	and trim(od1.oe_field_display_value) = 'Nasal-Both'
 
detail
	if(o.order_id is not null) active_bacto_var = 'Yes' endif
 
with nocounter
 
call echo(build2('active_bacto_var = ', active_bacto_var))
 
;---------------------------------------------------------------------------------------------------------------------
;Final evaluation
if(active_nozin_var != 'Yes' and active_bacto_var != 'Yes')
	 set retval = 100
endif
 
call echo(build2('retval = ', retval))
 
 
end
go
 
 
