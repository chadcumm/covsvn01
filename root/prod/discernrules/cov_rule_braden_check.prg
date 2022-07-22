/*****************************************************
Author		 :  Michael Layman
Date Written :  7/10/18
Program Title:  1st Charted Braden Skin Score Check
Source File	 :  cov_rule_braden_check.prg
Object Name	 :	cov_rule_braden_check
Directory	 :	cust_script
DVD version  :	2017.11.1.81
HNA version  :	2017
CCL version  :	8.2.3
Purpose      :  This program is called by the rule
				COV_BRADEN_LTE12_RD_WOCN. The program will
				evaluate the passed in clinical event and
				be sure it is the 1st charted Braden Skin
				Score.
 
Tables Read  :  order_recon
Tables
Updated      :	NA
Include Files:  NA
Executing
Application  :	Discern Rules
Special Notes: 	Launched from the rule COV_BRADEN_LTE12_RD_WOCN.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Mod #        By           Date           Purpose
*****************************************************/
 
 
 
drop program cov_rule_braden_check go
create program cov_rule_braden_check
 
 
 
/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
**************************************************************/
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
DECLARE encntrid = f8 WITH NOCONSTANT(0.0), PROTECT
DECLARE personid = f8 WITH NOCONSTANT(0.0), PROTECT
DECLARE bradenScoreCd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'BRADENSCORE')), PROTECT
DECLARE clineventid = f8 WITH NOCONSTANT(0.0), PROTECT
DECLARE authvercd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',8,'AUTHVERIFIED')), PROTECT
DECLARE alteredcd = f8 WITH CONSTANT(UAR_GET_CODE_BY('MEANINING',8, 'ALTERED')), PROTECT
DECLARE modifiedcd = f8 WITH CONSTANT(UAR_GET_CODE_BY('MEANING', 8, 'MODIFIED')), PROTECT
DECLARE firstCharted = i2 WITH NOCONSTANT(0), PROTECT
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
 
 
set encntrid = trigger_encntrid
SET personid = trigger_personid
SET clineventid = link_clineventid
set retval = 0
 
CALL ECHO(BUILD('encntrid :', encntrid))
CALL ECHO(BUILD('personid :', personid))
CALL ECHO(BUILD('clineventid :', clineventid))
CALL ECHO(BUILD('bradenscore :', bradenscorecd))
 
 
SELECT into 'nl:'
 
FROM clinical_event ce
WHERE personid = ce.person_id
AND ce.event_cd = bradenScoreCd
AND encntrid = ce.encntr_id
AND ce.result_status_cd IN (authvercd,alteredcd,modifiedcd)
AND ce.valid_until_dt_tm = CNVTDATETIME("31-dec-2100 0")
 
ORDER by ce.performed_dt_tm
 
HEAD REPORT
	cnt = 0
 
DETAIL
 
	cnt = cnt + 1
	if (cnt = 1 AND ce.clinical_event_id = clineventid)
		firstcharted = 1
	endif
 
 
WITH nocounter
 
 
if (firstcharted = 1)
 
	SET retval = 100
 
endif
 
CALL ECHO(BUILD('retval :', retval))
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 
