/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
   Program:             cov_item_chargeable_upd
   Folder:              CUST_SCRIPT
   Owner:               Covenant
   Author:              Dawn Greer, DBA
   Created Date:        11/16/2022
   Solution:			Supply Chain
   Original CR:         13959
 
   Purpose: Program to set the item chargeable if the charge code has been
            removed
 
   Schedule:            
   Ops Job:             
   Step:                
 
   Executing from:		CCL
 
   Special Notes:		x
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod   Date	       Developer            Comment
---   ----------   --------------------	---------------------------------------
001   11/16/2022   Dawn Greer, DBA      Temporary to fix issue

******************************************************************************/
drop program cov_item_chargeable_upd:dba go
create program cov_item_chargeable_upd:dba
 
record brec (
     1 item_count = i4
     1 list[*]
       2 ITEM_ID = f8)
 
SELECT INTO "NL:"
FROM item_definition id
,item_master im
,code_value cvsub
,mm_omf_item_master moim
WHERE id.item_id = im.item_id
AND im.sub_account_cd = cvsub.code_value
AND cvsub.display NOT IN ('800800' /*SUPPLIES - IMPLANT*/,
	'802400' /*SUPPLIES - MEDIC CHARGEABLE*/, '111111' /*SN SUPPLIES*/)
AND moim.item_master_Id = im.item_id
AND moim.class_name IN ('INSTRUMENTS','EQUIPMENT','MEDICATIONS','PROCEDURE CHARGE')
AND id.active_ind = 1
AND moim.active_ind = 1
AND id.chargeable_ind = 0
AND id.updt_dt_tm >= CNVTDATETIME('07-NOV-2022 00:00')
 
 
HEAD REPORT
    brec->item_count = 0
DETAIL
    brec->item_count = brec->item_count+1
    stat = alterlist(brec->list,brec->item_count)
    brec->list[brec->item_count].ITEM_ID = id.item_id
 
WITH nocounter
 
IF (BREC->item_count > 0)
	UPDATE INTO item_definition id,
	     (DUMMYT D WITH SEQ = BREC->item_count)
	SET id.chargeable_ind = 1
	,id.updt_id = 17496723	/*Scripting Updates, Dawn Greer*/
	,id.updt_dt_tm = CNVTDATETIME(CURDATE,CURTIME3)
	,id.updt_cnt = id.updt_cnt + 1
	,id.updt_task = 5021
	PLAN D
	JOIN id WHERE id.item_id = BREC->LIST[D.SEQ].ITEM_ID
	AND id.active_ind = 1
	AND id.chargeable_IND = 0
	WITH MAXCOMMIT = 1000
	COMMIT
ENDIF
 
CALL ECHORECORD(brec)
free record brec
 
END GO
