/*****************************************************
Author	 :  GEETHA SARAVANAN
Date Written :  Nov'2018
Program Title:  Existing Tobacco Instruction order
Source File	 :  cov_rule_exist_tobacco
Object Name	 :  cov_rule_exist_tobacco
Directory	 :  cust_script
 
Purpose      :  This program is called by the rule
		    cov_phq_smoking_cessatin1. The program will
		    evaluate any existing Tobacco Instruction order.
 
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Mod #        By           Date           Purpose
*****************************************************/
drop program cov_rule_exist_tobacco go
create program cov_rule_exist_tobacco
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
DECLARE retval = i4 ;WITH NOCONSTANT(0), PROTECT
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
;SET retval = 0
SET log_misc1 = fillstring(25,' ')
 
;set trigger_encntrid = 110458582
;set trigger_personid = 16601334
 
 
select
 
from orders o
where o.person_id = trigger_personid
;and o.encntr_id = (select e.encntr_id from encounter e where e.person_id = trigger_personid order e.reg_dt_tm desc)
and o.order_mnemonic in('Tobacco Cessation Instruction', 'PBH Tobacco Cessation Instruction')
and o.encntr_id = trigger_encntrid
and o.order_status_cd in(643466.00,	2543.00,2550.00)	;Pending Complete, Completed, Ordered
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
IF (CURQUAL > 0)
	set RETVAL = 0 ; set to be false - rule not to fire (order exist)
else
	set RETVAL = 100 ; set to be true - rule should fire (order does not exist)
endif
 
 
call echo(build('retval : ', retval))
call echo(build('log_misc1 :', log_misc1))
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 
/*
 
select * from orders where encntr_id =     110458582.00
and order_mnemonic = 'Tobacco Cessation Instruction'
 
select * from encntr_alias where encntr_id = 110458200
 
select * from encntr_alias where alias = '1829100010'
 
select type = uar_get_code_display(encntr_type_cd)
,e_class = uar_get_code_display(encntr_type_class_cd) ,class = uar_get_code_display(encntr_class_cd) ,*
from encounter where encntr_id = 110458197
 
 
select
 from orders o
where o.person_id = 16601334
and o.encntr_id = 110458582
and o.order_mnemonic = 'Tobacco Cessation Instruction'
and o.order_status_cd in(643466.00,	2543.00,2550.00)	;Pending Complete, Completed, Ordered
 
 
*/
 
 
 
 
 
