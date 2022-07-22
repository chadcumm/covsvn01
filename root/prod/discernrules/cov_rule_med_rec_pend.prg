/*****************************************************
Author		 :  Michael Layman
Date Written :  4/24/18
Program Title:  Pending Medication Reconcilation Orders
Source File	 :  cov_rule_med_rec_pend.prg
Object Name	 :	cov_rule_med_rec_pend
Directory	 :	cust_script
DVD version  :	2017.11.1.81
HNA version  :	2017
CCL version  :	8.2.3
Purpose      :  This program is called by the rule
				cov_med_rec_pending. The program will
				evaluate any medication reconciliation
				orders that are pending and return a
				true status to the rule if found.
 
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
drop program cov_rule_med_rec_pend go
create program cov_rule_med_rec_pend
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
;DECLARE retval = i4 WITH NOCONSTANT(0), PROTECT
DECLARE encntrid = f8 WITH NOCONSTANT(0.0), PROTECT
DECLARE pendcomp = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',4002695,'PENDINGCOMPLETE')), PROTECT
DECLARE pendpart = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',4002695,'PENDINGPARTIAL')), PROTECT
DECLARE notstarted = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',4002695,'NOTSTARTED')), PROTECT
DECLARE partial = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 4002695, 'PARTIAL')), PROTECT
DECLARE complete = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 4002695, 'COMPLETE')), PROTECT
DECLARE attdoc = f8 WITH CONSTANT(UAR_gET_CODE_BY('DISPLAYKEY',333,'ATTENDINGPHYSICIAN')), PROTECT
DECLARE medrecqual = i2 WITH NOCONSTANT(0), PROTECT
DECLARE physind = i2 WITH NOCONSTANT(0),PROTECT
/**************************************************************
; DVDev Start Coding
**************************************************************/
SET retval = 0
SET log_misc1 = fillstring(25,' ')
SET encntrid = trigger_encntrid
 
 
 
;check if triggering position is physician and if they are attending.
 
SELECT into 'nl:'
 
FROM encounter e,
	 prsnl pr,
	 encntr_prsnl_reltn epr
 
PLAN e
WHERE e.encntr_id = encntrid
AND e.active_ind = 1
JOIN epr
WHERE e.encntr_id = epr.encntr_id
;OUTERJOIN(pr.person_id) = epr.prsnl_person_id
AND attdoc = epr.encntr_prsnl_r_cd
AND epr.active_ind = 1
JOIN pr
WHERE epr.prsnl_person_id = pr.person_id
AND pr.person_id = reqinfo->updt_id
AND pr.physician_ind = 1
AND pr.active_ind = 1
 
DETAIL
 
	medrecqual = 1
 
WITH nocounter
 
;check for nonphysician
SELECT into 'nl:'
 
FROM prsnl pr
WHERE pr.person_id = reqinfo->updt_id
AND pr.active_ind = 1
 
DETAIL
 
	physind = pr.physician_ind
 
WITH nocounter
 
 
 
if (medrecqual = 1 OR physind = 0)
	SELECT into 'nl:'
 
	FROM order_recon orec
 
	PLAN orec
	WHERE orec.encntr_id = encntrid
	;AND orec.recon_status_cd IN (pendcomp, notstarted, partial, pendpart)
	AND orec.recon_type_flag in (1,2,3) ;admission, transfer, discharge
 	
 	ORDER BY orec.performed_dt_tm DESC
 	
 	HEAD REPORT
 		cnt = 0
 		compsts = 0
 	
	HEAD orec.performed_dt_tm
		call echo(build('orec.recon_id :', orec.order_recon_id))
		cnt = cnt + 1
; 		if (orec.recon_status_cd = complete)
; 			compsts = 1
; 		endif
 		
		if (orec.recon_type_flag = 3)
		
		 	if (orec.recon_status_cd IN
 			(pendcomp, notstarted, partial, pendpart))
 			retval = 100
 			log_misc1 = cnvtstring(orec.recon_type_flag)
 			elseif (orec.recon_status_cd = complete AND cnt = 1)
 				compsts = 1
 			endif
 		elseif (orec.recon_type_flag in (1,2))
 			if (orec.recon_status_cd IN	(pendcomp, notstarted, partial))
 
			retval = 100
			log_misc1 = cnvtstring(orec.recon_type_flag) ;
			elseif (orec.recon_status_cd =  complete AND cnt = 1)
				compsts = 1
			endif
		endif
		
		
	FOOT REPORT
		
		if (compsts = 1)
			retval = 0
			log_misc1 = cnvtstring(orec.recon_type_flag)
		endif
		call echo(build('compsts :', compsts))
		call echo(build('cnt :', cnt))
		
		
		
	WITH nocounter
endif
 
 
call echo(build('retval : ', retval))
call echo(build('log_misc1 :', log_misc1))

 
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 
