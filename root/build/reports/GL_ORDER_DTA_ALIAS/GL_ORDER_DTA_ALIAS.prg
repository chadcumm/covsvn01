drop program GL_ORDER_DTA_ALIAS go
create program GL_ORDER_DTA_ALIAS
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Activity Type" = 0
	, "Contributor Source" = 0
 
with OUTDEV, ACT, Contrib
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
 
;    Your Code Goes Here
select distinct into $OUTDEV
 
       Code_Set = uar_get_code_set(oc.catalog_cd),
       Order_Code = oc.catalog_cd,
       Order_Display = uar_get_code_display(oc.catalog_cd),
       Order_Description = uar_get_code_description(oc.catalog_cd),
       Contributor_Source_IN=uar_get_code_display(cva.contributor_source_cd),
       Inbound_order_alias=cva.alias,
       Contributor_source_OUT=uar_get_code_display(cvo.contributor_source_cd),
       Outbound_order_alias = cvo.alias,
      Code_Set =  uar_get_code_set(p.task_assay_cd),
      Task_Assay_Code  = p.task_assay_cd,
      Task_Assay_Display =  uar_get_code_display(p.task_assay_cd),
       Task_Assay_Description = uar_get_code_description(p.task_assay_cd),
       Contributor_Source_IN=uar_get_code_display(cva2.contributor_source_cd),
       Inbound_Task_Assay_alias = cva2.alias,
       Contributor_Source_OUT=uar_get_code_display(cvo2.contributor_source_cd),
       Outbound_Task_Assay_alias = cvo2.alias,
       Code_Set = uar_get_code_set(cve.event_cd),
       cve.event_cd,
      Event_Code_Display =  uar_get_code_display(cve.event_cd),
       Event_Code_Description = uar_get_code_description(cve.event_cd),
       Contributor_Source_IN=uar_get_code_display(cva3.contributor_source_cd),
       Inbound_EC_alias = cva3.alias,
       Contributor_Source_OUT=uar_get_code_display(cvo3.contributor_source_cd),
       Outbound_EC_alias = cvo3.alias
 from
       orc_resource_list ol,
       order_catalog oc,
       profile_task_r p,
       discrete_task_assay d,
       code_value_event_r cve,
       code_value_outbound cvo,
       code_value_outbound cvo2,
       code_value_outbound cvo3,
       code_value_alias cva,
       code_value_alias cva2,
       code_value_alias cva3
 
Plan OL where ol.active_ind = 1
Join OC where ol.catalog_cd = oc.catalog_cd
       and oc.active_ind = 1 and oc.activity_type_cd = $ACT
Join P where ol.catalog_cd = p.catalog_cd and p.active_ind = 1
Join D where d.task_assay_cd = p.task_assay_cd
       and d.active_ind = 1
Join cve where cve.parent_cd = d.task_assay_cd
join cva where cva.code_value = outerjoin(oc.catalog_cd)
       and cva.CONTRIBUTOR_SOURCE_CD = outerjoin($Contrib)
join cvo where cvo.code_value = outerjoin(oc.catalog_cd)
       and cvo.CONTRIBUTOR_SOURCE_CD = outerjoin($Contrib)
join cva2 where cva2.code_value = outerjoin(p.task_assay_cd)
       and cva2.CONTRIBUTOR_SOURCE_CD = outerjoin($Contrib)
join cvo2 where cvo2.code_value = outerjoin(p.task_assay_cd)
       and  cvo2.CONTRIBUTOR_SOURCE_CD = outerjoin($Contrib)
join cva3 where cva3.code_value = outerjoin(cve.event_cd)
       and cva3.CONTRIBUTOR_SOURCE_CD = outerjoin($Contrib)
join cvo3 where cvo3.code_value = outerjoin(cve.event_cd)
       and  cvo3.CONTRIBUTOR_SOURCE_CD = outerjoin($Contrib)
order by oc.primary_mnemonic, p.sequence
with nocounter, separator = " ", format
 
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 
