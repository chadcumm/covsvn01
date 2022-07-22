 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Mar'2020
	Solution:			Quality
	Source file name:	      cov_ccu_nozin_order_rule.prg
	Object name:		cov_ccu_nozin_order_rule
	Request#:			CCU Nozin rule
	Program purpose:	      Previous Nurse unit and active Postop orders check
	Executing from:		CCL
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------*/
;06/01/21    Geetha                  New unit added - FSR ICU SD

;------------------------------------------------------------------------------
 
drop program cov_ccu_nozin_unit_rule:dba go
create program cov_ccu_nozin_unit_rule:dba
 
declare encntrid = f8 with noconstant(0.0), protect
declare personid = f8 with noconstant(0.0), protect
declare ccu_nu_var = vc with noconstant('')
declare active_nozin_var = vc with noconstant('')
declare active_bacto_var = vc with noconstant('')
 
;set personid = trigger_personid
set encntrid = trigger_encntrid
set retval = 0
 
;------------------------------------------------------------------------------------
;Find- previous nurse unit
select into 'nl:'
 
 nurse_unit = uar_get_code_display(elh.loc_nurse_unit_cd)
 ,beg_dt = elh.beg_effective_dt_tm  "@SHORTDATETIME", end_dt = elh.end_effective_dt_tm  "@SHORTDATETIME"
 
from encntr_loc_hist elh
 
plan elh where elh.encntr_id = encntrid
	and elh.end_effective_dt_tm = (select max(elh1.end_effective_dt_tm) from encntr_loc_hist elh1
						where elh1.encntr_id = elh.encntr_id
						and elh1.end_effective_dt_tm != cnvtdatetime("31-DEC-2100 00:00:00")
						group by elh1.encntr_id)
	and elh.loc_nurse_unit_cd in(
				2552503829  ;FLMC CCU
				,2552520343 ;FSR CV ICU
				,2619633665 ;FSR ICU
				,38616903   ;FSR NEURO ICU
				,2552520747	;FSR ICU SD
				,2552513125 ;LCMC ICU
				,2552508305 ;MHHS CCU
				,2552505957 ;MMC ICU
				,2552505625 ;MMC CCU
				,2552505673 ;MMC CVU
				,2552511121 ;PW C1
				,2552511237);PW C2
 
Detail
	ccu_nu_var = 'Yes'
 
with nocounter
 
call echo(build2('ccu_nu_var = ', ccu_nu_var))
 
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
if(ccu_nu_var = 'Yes' and active_nozin_var != 'Yes' and active_bacto_var != 'Yes')
	 set retval = 100
elseif(ccu_nu_var != 'Yes' and active_nozin_var != 'Yes' and active_bacto_var != 'Yes')
	set retval = 100
elseif(ccu_nu_var = 'Yes' and active_nozin_var = 'Yes' or active_bacto_var = 'Yes')
	 set retval = 0
elseif(ccu_nu_var != 'Yes' and active_nozin_var = 'Yes' or active_bacto_var = 'Yes')
	 set retval = 0
endif
 
call echo(build2('retval = ', retval))
 
 
end
go
 
 
