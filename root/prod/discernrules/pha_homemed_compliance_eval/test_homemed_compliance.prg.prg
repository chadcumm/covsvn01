;set trace backdoor p30ins go
drop program test_homemed_compliance_eval:dba go
create program test_homemed_compliance_eval:dba
 
set retval = 0
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 set var_convert = uar_get_code_by("MEANING",4001987,"CONVERT")
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
select into "nl:"
	oor.related_from_order_id
	,ocd.compliance_status_cd
	,ocd.last_occurred_dt_tm
	,lt.long_text
from
	order_order_reltn oor
	,order_compliance_detail ocd
	,long_text lt
	,orders o
plan oor
	where oor.relation_type_cd = var_convert
	and oor.related_to_order_id = trigger_orderid
join o
	where o.order_id = oor.related_from_order_id
	and o.orig_ord_as_flag in (1,2)
join ocd
	where ocd.order_nbr = outerjoin(oor.related_from_order_id)
	and ocd.compliance_status_cd != 0
join lt
	where lt.long_text_id = outerjoin(ocd.long_text_id)
detail
  retval = 100
  if(ocd.long_text_id != 0
  		or ocd.last_occurred_dt_tm != 0
  		;or ocd.compliance_status_cd != 4146548.00)
  		or ocd.compliance_status_cd in (
  		    4146546.00,	 ;Investigating
		    4146547.00,	 ;Not taking
		    ;4146548.00,	 ;Still taking, as prescribed
		 ;2570428973.00,	 ;Still Taking- Needs Refills
		    4146549.00,	 ;Still taking, not as prescribed
		    4146550.00,	 ;Unable to obtain
		   20008580.00,	  ;Given Prior to Arrival
		     242455181.00  ; blank
		   ))
  log_misc1 = concat(" Status: ",uar_get_code_display(ocd.compliance_status_cd)
  						,"@NEWLINE Comments: ",lt.long_text
  						,"@NEWLINE Last Taken: ",format(ocd.last_occurred_dt_tm, "@SHORTDATETIME"))
  else
  	log_misc1 = "No Compliance Details Found"
  endif
  with nocounter
  if (retval = 0) go to exit_program endif
 
# exit_program
 
call echo(concat("retval =", build(retval)))
call echo(concat("log_misc1 size=",build(size(log_misc1,1))))
call echo(concat("log_misc1 =",log_misc1))
 
end go
