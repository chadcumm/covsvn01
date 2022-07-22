/*****************************************************
Author		 :  Michael Layman
Date Written :  4/30/18
Program Title:  Existing Behavioral Health Audit C
Source File	 :  cov_rule_exist_auditc.prg
Object Name	 :	cov_rule_exist_auditc
Directory	 :	cust_script
DVD version  :	2017.11.1.81
HNA version  :	2017
CCL version  :	8.2.3
Purpose      :  This program is called by the rule
				cov_bh_intv_comp. The program will
				evaluate any existing BH audit c
				results to be sure the rule only fires
				for one event and not any subsequent events.
 
Tables Read  :  order_recon
Tables
Updated      :	NA
Include Files:  NA
Executing
Application  :	Discern Rules
Special Notes: 	Launched from the rule cov_med_rec_pending.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Mod #        By           Date           Purpose
*****************************************************/
drop program cov_rule_exist_auditc go
create program cov_rule_exist_auditc
 
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
;DECLARE retval = i4 WITH NOCONSTANT(0), PROTECT
DECLARE encntrid = f8 WITH NOCONSTANT(0.0), PROTECT
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
SET retval = 0
SET log_misc1 = fillstring(25,' ')
SET encntrid = trigger_encntrid
SET personid = trigger_personid
 
DECLARE auditc = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 72, 'BEHAUDITCSCORINGTOOL')), PROTECT
 
SELECT into 'nl:'
 
FROM clinical_event ce
WHERE ce.person_id = personid
AND ce.event_cd = auditc
AND ce.encntr_id = trigger_encntrid
 
 
HEAD REPORT
 
	cnt = 0
 
DETAIL
 
	cnt = cnt + 1
 
 
 
FOOT REPORT
 
	if (cnt > 1)
		retval = 100
	endif
 
WITH nocounter
 
 
 
call echo(build('retval : ', retval))
call echo(build('log_misc1 :', log_misc1))
call echo(build('auditc :', auditc))
 
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 
