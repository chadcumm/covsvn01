/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		May 2021
	Solution:			Pre Op
	Source file name:	      cov_phq_copy_powerplan.prg
	Object name:		cov_phq_copy_powerplan
	Request#:			10299
	Program purpose:	      AdHoc for Lori & Dr.Halford
	Executing from:
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date		Developer			Comment
-------------------------------------------------------------------------------------------------------
 
 
*******************************************************************************************************/
 
drop program cov_phq_copy_powerplan:dba go
create program cov_phq_copy_powerplan:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Begin Date/time" = "SYSDATE"
	, "Select End Date/Time" = "SYSDATE"
	, "Select Facility" = 675844.00
	, "Nurse Unit" = 0
 
with OUTDEV, begdate, enddate, Facility, nurse_unit
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
 
;Power Plan query for Lori
 
select * from orders o where o.encntr_id =   118741070.00
 
select o.order_mnemonic, o.updt_dt_tm ';;q', o.* from orders o where o.person_id = 18214848.00
order by o.updt_dt_tm, o.order_mnemonic
 
select op.order_mnemonic, op.created_dt_tm ';;q', op.updt_dt_tm ';;q', op.*
from order_proposal op where op.person_id = 18214848.00
order by op.updt_dt_tm, op.order_mnemonic
 
 
select
 fin = ea.alias ,pw.encntr_id, pw.person_id, apc.pathway_id
 , ocs.mnemonic , pw.order_dt_tm ';;q' ,powerplan_status = uar_get_code_display(pw.pw_status_cd)
 , action_type = uar_get_code_display(pa.action_type_cd)
 ,component_status = uar_get_code_display(apc.comp_status_cd)
 ,component_type = uar_get_code_display(apc.comp_type_cd), apc.parent_entity_name
 , category = uar_get_code_display(apc.dcp_clin_cat_cd)
 ;, pw.pathway_id , apc.included_ind, apc.parent_entity_name
 ;, catatlog = uar_get_code_display(ocs.catalog_cd)
 ;, dcp = uar_get_code_display(apc.dcp_clin_cat_cd)
 
from
 pathway pw
 , pathway_action pa
 , act_pw_comp apc
 , order_catalog_synonym ocs
 , encntr_alias ea
 /*, order_sentence_detail osd*/
 
plan pw
where pw.person_id = 18214848.00
;where pw.encntr_id =   118741070.00
and pw.active_ind = 1
and pw.order_dt_tm > cnvtdatetime('03-MAY-2021 15:00:00.00')
;and pw.pw_status_cd in (
; value(uar_get_code_by("meaning", 16769, "PLANPROPOSE"))
; , value(uar_get_code_by("meaning", 16769, "PLANNED"))
;)
 
join pa where pw.pathway_id = pa.pathway_id
 
join ea where ea.encntr_id = pw.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
;join dfr where dfr.dcp_form_instance_id = pw.comp_forms_ref_id
;	and dfr.active_ind = 1
 
join apc
where apc.pathway_id = pw.pathway_id
;and apc.ref_prnt_ent_name = "ORDER_CATALOG_SYNONYM"
;and apc.dcp_clin_cat_cd = value(uar_get_code_by("meaning", 16389, "MEDICATIONS"))
;and apc.parent_entity_name in ("PROPOSAL", "ORDERS")
and apc.active_ind = 1
;and apc.included_ind = 1 /*Order is included in PowerPlan*/
 
join ocs
where ocs.synonym_id = apc.ref_prnt_ent_id
;and ocs.catalog_type_cd = value(uar_get_code_by("meaning", 6000, "PHARMACY"))
and ocs.active_ind = 1
 
order by pw.person_id, pw.encntr_id
 
;------------------------------------------------------------------------------------
 
 
SELECT
  PLAN_NAME=P.DESCRIPTION
  ,PHASE_DESC=PCA2.DESCRIPTION
FROM
  PATHWAY_CATALOG   P
  , PW_CAT_RELTN   PCR
  , PATHWAY_CATALOG   PCA2
 
  WHERE P.ACTIVE_IND=1
  AND P.REF_OWNER_PERSON_ID=0
  AND P.TYPE_MEAN != "PHASE"
  AND P.BEG_EFFECTIVE_DT_TM < CNVTDATETIME(SYSDATE) ;PRODUCTION PLANS ONLY
  AND PCR.pw_cat_s_id= OUTERJOIN (P.pathway_catalog_id)
  AND PCR.type_mean= OUTERJOIN ("GROUP")
  AND PCA2.pathway_catalog_id=  OUTERJOIN (PCR.pw_cat_t_id)
 
 
 
select * from dcp_forms_ref dfr
 
select * from pathway_catalog pc
 
 
      10745.00	Activated
      10746.00	Canceled
      10747.00	Excluded
      10748.00	Included
     674357.00	Failed Create
    3542934.00	Unavailable
   18650561.00	Moved
    4370689.00	Skipped
 
;------------------------------------------------------------------------------------------
 
 
#exitscript
 
end
go
 
