/*****************************************************
Author		 :  Michael Layman
Date Written :  4/24/18
Program Title:  1st Charted Braden Skin Score Check
Source File	 :  cov_rule_braden_2nd_chk.prg
Object Name	 :	cov_rule_braden_2nd_chk
Directory	 :	cust_script
DVD version  :	2017.11.1.81
HNA version  :	2017
CCL version  :	8.2.3
Purpose      :  This program is called by the rule
				COV_BRADEN_LTE12_RD_WOCN. The program will
				evaluate the passed in clinical event and
				evaluate it for a second Braden Score. This will
				review all the results and check that at some
				point the Braden Score went above 18 and has
				returned to <12.
 
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
 
 
 
drop program cov_rule_braden_2nd_chk go
create program cov_rule_braden_2nd_chk
 
 
 
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
DECLARE NormBradScoreInd = i2 WITH NOCONSTANT(0), PROTECT
DECLARE curBradScoreInd = i2 WITH NOCONSTANT(0), PROTECT
DECLARE rdConsordCd = f8 WITH NOCONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',200,'CONSULTTOREGISTEREDDIETITIAN')), PROTECT
DECLARE EntConsordCd = f8 WITH NOCONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',200,'CONSULTENTEROSTOMALWOUNDCARENURSE')), PROTECT
DECLARE ordFndInd	=	i2 WITH NOCONSTANT(0), PROTECT
DECLARE ordered = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6004,'ORDERED')), PROTECT
DECLARE completed = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6004,'COMPLETED')), PROTECT
 
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
 
 
 
;Check for normal Braden Score and Compare against current event.
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
 	prvScoreInd = 0
DETAIL
 
	cnt = cnt + 1
 
 
	if (CNVTINT(ce.result_val) >=18 AND ce.performed_dt_tm <= CNVTDATETIME(CURDATE, CURTIME3))
		NormBradScoreInd = 1
 
 
	endif
 
 
 
	if (ce.clinical_event_id = clineventid AND CNVTINT(ce.result_val)<12 AND prvScoreInd = 0)
 
		curBradScoreInd = 1
 
	endif
 
 	if (CNVTINT(ce.result_val) < 12)
 
		prvScoreInd = 1
 
	else
		prvScoreInd = 0
 
	endif
 
WITH nocounter
 
 
;If clin event is not the 1st charted skin score, it may have been charted
;after the rule was turned on and be a subsequent score that still needs
;a consult order placed. We want to check and be sure not consult order
;has been placed with the comments from the rule before we qualify it.
 
/***** -- Removing order comment from rule section per Paul Hester -- *******/
 
SELECT into 'nl:'
 
FROM encounter e,
	 orders o
	; order_comment oc,
	; long_text lt
PLAN e
WHERE encntrid = e.encntr_id
AND e.active_ind = 1
JOIN o
WHERE e.encntr_id = o.encntr_id
AND o.catalog_cd IN (rdConsordCd, EntConsordCd)
AND o.order_status_cd in (ordered, completed)
AND o.orig_order_dt_tm >=e.reg_dt_tm
;JOIN oc
;WHERE o.order_id = oc.order_id
;JOIN lt
;WHERE oc.long_text_id = lt.long_text_id
;AND lt.long_text = 'Order entered secondary to documenting patient having a Braden score less than 12'
 
HEAD REPORT
	RDordFnd = 0
 	EntOrdFnd = 0
DETAIL
 
	CASE (o.catalog_cd)
 
		OF (rdConsordCd):
			;if (TRIM(lt.long_text) = 'Order entered secondary to documenting patient having a Braden score less than 12')
				RDordFnd = 1
			;endif
		OF (EntConsordCd):
			;if (TRIM(lt.long_text) = 'Order entered secondary to documenting patient having a Braden score less than 12')
				EntordFnd = 1
			;endif
	ENDCASE
FOOT REPORT
	if (RDordFnd = 1 AND EntOrdFnd = 1)
 
		ordFndInd = 1
 
	endif
 
WITH nocounter
 
 
 
 
 
 
 
if (NormBradScoreInd = 1 AND curBradScoreInd = 1)
 	;if(ordFndInd = 0)
		SET retval = 100
 	;endif
;elseif (ordFndInd = 0 AND curBradScoreInd = 1)
;
;	SET retval = 100
 
endif
CALL ECHO(BUILD('OrdFndInd :', ordFndInd))
CALL ECHO(BUILD('curBradScoreInd :', curBradScoreInd))
CALL ECHO(BUILD('retval :', retval))
CALL ECHO(BUILD('NormBradScoreInd :', NormBradScoreInd))
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 
