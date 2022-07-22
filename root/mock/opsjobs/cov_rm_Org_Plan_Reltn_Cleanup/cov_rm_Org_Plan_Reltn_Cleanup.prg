/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		11/19/2021
	Solution:			Revenue Cycle - HIM
	Source file name:	cov_him_EventAlloc_Cleanup.prg
	Object name:		cov_him_EventAlloc_Cleanup
	Request #:			11638
 
	Program purpose:	Completes 'in error' records from table HIM_EVENT_ALLOCATION.
 
	Executing from:		CCL
 
 	Special Notes:		Called by CCL cov_mak_defic_by_phys_ops, which is run from
 						Ops Job 'HIM Physician Deficiencies Correction'.
 
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


