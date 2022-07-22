/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Dawn Greer, DBA
	Date Written:		12/21/2018
	Solution:			Supply Chain
	Source file name:	cov_sup_chain_charge_svcs_fix.prg
	Object name:		cov_sup_chain_charge_svcs_fix
	Request #:			4053
 
	Program purpose:	Supply Chain Charge Services Fix per SR 422256017
 
	Executing from:		CCL
 
 	Special Notes:		x
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	---------------------------------------
 
******************************************************************************/
DROP PROGRAM cov_sup_chain_charge_svcs_fix:DBA GO
CREATE PROGRAM cov_sup_chain_charge_svcs_fix:DBA
 
UPDATE INTO dm_info di
SET di.info_char = "26-MAR-2017 00:00:00.00",
di.UPDT_DT_TM = CNVTDATETIME(CURDATE, CURTIME3),
di.UPDT_TASK = 0,
di.UPDT_CNT = updt_cnt+1,
di.UPDT_APPLCTX = 0,
di.UPDT_ID = 17496723		;DG Scripting Updates
WHERE di.info_domain = "SUPPLYCHAIN"
AND di.info_name = "SUPPLY_CHAIN_LOAD_ITEM_MASTER13"
AND di.info_domain_id = 0.00
END
GO
 
