/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
   Program:             cov_item_price_sch_date_upd
   Folder:              CUST_SCRIPT
   Owner:               Covenant
   Author:              Dawn Greer, DBA
   Created Date:        9/23/2019
   Solution:			Supply Chain
   Original CR:         6185 (new) / 5498 (old)
 
   Purpose: Program to set the price schedule effective
            date (PRICE_SCHED_ITEMS.BEG_EFFECTIVE_DT_TM) field to be
            the same date as the Bill Item effective date field
            (BILL_ITEM_MODIFIER.BEG_EFFECTIVE_DT_TM).
 
   Schedule:            Runs daily at 7:00 am
   Ops Job:             Supply Chain Charge Services Integration
   Step: 4
 
   Schedule:            As needed/manual run
   Ops Job:             Cov Item Price Schedule Date Upd MANUAL
   Step: 1
 
   Executing from:		CCL
 
   Special Notes:		x
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	---------------------------------------
 
******************************************************************************/
drop program cov_item_price_sch_date_upd:dba go
create program cov_item_price_sch_date_upd:dba
 
record brec (
     1 charge_count = i4
     1 list[*]
       2 BILL_ITEM_ID = f8
       2 beg_effective_dt_tm = dq8)
 
SELECT INTO "NL:"
FROM bill_item_modifier bm , price_sched_items p
WHERE bm.bill_item_id = p.bill_item_id
AND bm.key1_id = 2556027807.00  ;Hospital CDM Schedule
AND p.price_sched_id = 72051157.00	;Hospital Price
AND bm.active_ind = 1
AND p.active_ind = 1
AND p.updt_id IN (12397986.00 /*Contributor_system, MSCM*/, 1.00 /*System, System Cerner */)
AND bm.updt_id = 12397986.00 /*Contributor_system, MSCM*/
AND bm.beg_effective_dt_tm < p.beg_effective_dt_tm
 
HEAD REPORT
    brec->charge_count = 0
DETAIL
    brec->charge_count = brec->charge_count+1
    stat = alterlist(brec->list,brec->charge_count)
    brec->list[brec->charge_count].BILL_ITEM_ID = bm.BILL_ITEM_ID
    brec->list[brec->charge_count].beg_effective_dt_tm = bm.beg_effective_dt_tm
WITH nocounter
 
IF (brec->charge_count > 0)
	UPDATE INTO price_sched_items P,
	     (DUMMYT D WITH SEQ = brec->charge_count)
	SET P.beg_effective_dt_tm = CNVTDATETIME(brec->LIST[D.SEQ].beg_effective_dt_tm)
	,p.updt_id = 17496723	/*Scripting Updates, Dawn Greer*/
	,p.updt_dt_tm = CNVTDATETIME(CURDATE,CURTIME3)
	,p.updt_cnt = p.updt_cnt + 1
	PLAN D
	JOIN P WHERE P.BILL_ITEM_ID = brec->LIST[D.SEQ].BILL_ITEM_ID
	AND p.price_sched_id = 72051157.00 ;Hospital Price
	AND p.active_ind = 1
	AND p.updt_id IN (12397986.00 /*Contributor_system, MSCM*/, 1.00 /*System, System Cerner */)
	AND CNVTDATETIME(brec->LIST[D.SEQ].beg_effective_dt_tm) < p.beg_effective_dt_tm
	WITH MAXCOMMIT = 1000
	COMMIT
ENDIF
 
free record brec
 
END GO