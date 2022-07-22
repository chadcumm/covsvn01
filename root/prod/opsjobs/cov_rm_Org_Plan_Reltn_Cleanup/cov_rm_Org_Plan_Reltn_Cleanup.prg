/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		01/19/2022
	Solution:			Revenue Cycle - Registration Management
	Source file name:	cov_rm_Org_Plan_Reltn_Cleanup.prg
	Object name:		cov_rm_Org_Plan_Reltn_Cleanup
	Request #:			9411
 
	Program purpose:	Inactivates unauthorized records in table ORG_PLAN_RELTN.
 
	Executing from:		Ops Job
 
 	Special Notes:		
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program cov_rm_Org_Plan_Reltn_Cleanup:DBA go
create program cov_rm_Org_Plan_Reltn_Cleanup:DBA


/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/ 

declare carrier_rx_var		= f8 with constant(uar_get_code_by("MEANING", 370, "CARRIER_RX"))
declare carrier_var			= f8 with constant(uar_get_code_by("MEANING", 370, "CARRIER"))
declare sponsor_var			= f8 with constant(uar_get_code_by("MEANING", 370, "SPONSOR"))

 
/**************************************************************
; DVDev Start Coding
**************************************************************/

; prescription carrier
update into ORG_PLAN_RELTN opr
set
	opr.active_ind = 0
	, opr.active_status_cd = reqdata->inactive_status_cd
	, opr.active_status_dt_tm = sysdate
	, opr.updt_dt_tm = sysdate
	, opr.updt_task = -4683
	, opr.updt_id = 17496726.00 ; SCRIPTING UPDATES, TODD BLANCHARD
where
	opr.data_status_cd = reqdata->auth_unauth_cd
	and opr.org_plan_reltn_cd in (carrier_rx_var)
	and opr.end_effective_dt_tm >sysdate
	and opr.active_ind = 1
	

; carrier / sponsor
update into ORG_PLAN_RELTN opr
set 
	opr.active_ind = 0
	, opr.active_status_cd = reqdata->inactive_status_cd
	, opr.active_status_dt_tm = sysdate
	, opr.updt_dt_tm = sysdate
	, opr.updt_task = -4683
	, opr.updt_id = 17496726.00 ; SCRIPTING UPDATES, TODD BLANCHARD
where
	opr.data_status_cd = reqdata->auth_unauth_cd
	and opr.org_plan_reltn_cd in (carrier_var, sponsor_var)
	and opr.end_effective_dt_tm >sysdate
	and opr.active_ind = 1
	
	
commit


if (validate(request->batch_selection) = 1)
	set reply->status_data.status = "S"
endif

 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

;#exitscript
 
end
go


