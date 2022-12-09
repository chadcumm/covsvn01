/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
   Program:             cov_item_nonchargeable_upd
   Folder:              CUST_SCRIPT
   Owner:               Covenant
   Author:              Dawn Greer, DBA
   Created Date:        06/21/2022
   Solution:			Supply Chain
   Original CR:         12453
 
   Purpose: Program to set the item nonchargeable if the charge code has been
            removed
 
   Schedule:            Runs daily at 2:00 am
   Ops Job:             Supply Chain Item Sync
   Step:                Last Step
 
   Executing from:		CCL
 
   Special Notes:		x
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod   Date	       Developer            Comment
---   ----------   --------------------	---------------------------------------
001   06/27/2022   Dawn Greer, DBA      Copied this from MOCK to implement in PROD
002   10/07/2022   Dawn Greer, DBA      CR 13766 - Made changes to the query to
                                        mark nonchargeable for any account code
                                        other than 800800 and 802400 and 111111
                                        and the charge code is blank.
003   11/07/2022   Dawn Greer, DBA      CR 13959 - Removed the bill_item_modifier
                                        table from the query since new and re-activated
                                        items do not have the bill_item_modifiers
                                        qualifiers set until the Supply Chain
                                        Charge Services Integration Ops Job runs
004   11/09/2022   Dawn Greer, DBA      CR 13959 - Removed the bill_item table from
                                        the query because the entry for a new item
                                        isn't created into the Supply Chain
                                        Charge Services Integration Ops Job runs.
005   11/14/2022   Dawn Greer, DBA      CR 13959 - moved to PROD from MOCK                                        
******************************************************************************/
drop program cov_item_nonchargeable_upd:dba go
create program cov_item_nonchargeable_upd:dba
 
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
AND moim.class_name IN ('IMPLANT','SUPPLY','SUPPLIES','TDC','SOLUTION','INSTRUMENTS','EQUIPMENT','MEDICATIONS','PROCEDURE CHARGE')
AND id.active_ind = 1
AND moim.active_ind = 1
AND id.chargeable_ind = 1
 
 
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
	SET id.chargeable_ind = 0
	,id.updt_id = 17496723	/*Scripting Updates, Dawn Greer*/
	,id.updt_dt_tm = CNVTDATETIME(CURDATE,CURTIME3)
	,id.updt_cnt = id.updt_cnt + 1
	,id.updt_task = 5021
	PLAN D
	JOIN id WHERE id.item_id = BREC->LIST[D.SEQ].ITEM_ID
	AND id.active_ind = 1
	AND id.chargeable_IND = 1
	WITH MAXCOMMIT = 1000
	COMMIT
ENDIF
 
CALL ECHORECORD(brec)
free record brec
 
END GO
