subroutine COV_CE_UPDATE_SVSREC_A (STATUS, SERVICE_RESOURCE, LINK, OPT_COMMENT_TYPE, OPT_COMMENT,RESEND)

set tname = "COV_CE_UPDATE_SVSREC_A"
set stat = 0
set retval = 0
; Check if any of the applicable parameters have been dynamically defined.  Allow for most to be list parameters even
; though they are not really defined as such.  This is so that the Advisor can send in more than one result at a time
; to be posted to the CE table.  EKS_PARSE_DYNAMIC_PARAMS_L was most likely used.
 
%i cclsource:eks_chkDynamicParam.inc
if (eksdata->bldMsg_paramInd)
   call eks_chkDynamicParam("STATUS", STATUS, 1, 1)
   call eks_chkDynamicParam("SERVICE_RESOURCE", SERVICE_RESOURCE, 1, 1)
   call eks_chkDynamicParam("LINK", LINK, 0, 0)
   call eks_chkDynamicParam("OPT_COMMENT_TYPE", OPT_COMMENT_TYPE, 1, 1)
   call eks_chkDynamicParam("OPT_COMMENT", OPT_COMMENT, 1, 1)
   call eks_chkDynamicParam("RESEND", RESEND, 0, 0)   
endif
 
; End of Dynamic Parameters

;set VALUE1 = OPT_VALUE1
set CE_UPDATE_IND = 1

execute cov_t_ce_upd_resource_cd

return(retval)

end

