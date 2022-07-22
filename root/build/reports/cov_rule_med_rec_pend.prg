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
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
SET retval = 0
 
SET encntrid = trigger_encntrid
 
SELECT into 'nl:'
 
FROM order_recon orec
 
PLAN orec
WHERE orec.encntr_id = encntrid
AND orec.recon_status_cd IN (pendcomp, pendpart,notstarted, partial)
AND orec.recon_type_flag = 1 ;admission
 
DETAIL
 
 
	retval = 100
 
WITH nocounter
 
call echo(build('retval : ', retval))
 
 
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 
