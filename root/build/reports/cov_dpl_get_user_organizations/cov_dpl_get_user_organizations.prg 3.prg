
drop program cov_dpl_get_user_organizations:dba go
create program cov_dpl_get_user_organizations:dba
 
%i cclsource:i18n_uar.inc
declare GetUserFacilities(remove_trust_ind = i2) = i2 with protect

if (validate(org_list) !=1)
    Record org_list
        (
            1 organizations[*]
                2 organization_id     = f8
                2 confid_cd            = f8
                2 confid_level      = i4
        ) 
endif
 
subroutine GetUserFacilities(remove_trust_ind)
    declare logon_type_flag = i2 with protect, noconstant(0)
    declare org_cnt         = i4 with protect, noconstant(0)
    declare ret_stat        = i4 with protect, noconstant(0)
    
    
    execute sac_get_user_organizations with replace ("REPLY", "ORG_LIST")    
    execute sacrtl
    
    set logon_type_flag = uar_SacGetUserLogontype()
 
    if(logon_type_flag = 1 and remove_trust_ind = 1) ;NHS security mode
        set org_cnt = size(org_list->organizations, 5)
        set ret_stat = alterlist(org_list->organizations, org_cnt - 1, 0)
    endif
end
 
declare i1MultiFacilityLogicInd = i1 with noConstant(0), protect
declare i1EncntrOrgSecInd = i1 with noConstant(0), protect
declare i18nAllFacilities = vc with noConstant(""), protect
 
 
declare batch_size      = i2 with noconstant(20), protect ;74990
declare cur_list_size   = i4 with noconstant(0), protect ;74990
declare new_list_size   = i4 with noconstant(0), protect ;74990
declare nstart          = i4 with noconstant(0), protect ;74990
declare idx             = i4 with noconstant(0), protect ;74990
declare loop_cnt        = i4 with noconstant(0), protect ;74990
 
set i18nHandleHIM = 0
set lRetVal = uar_i18nlocalizationinit(i18nHandleHIM, curprog, "", curcclrev)
 
set i18nAllFacilities    = uar_i18ngetmessage(i18nHandleHIM, "KEY_0", "All Facilities")
 
/*Determine if encounter org security is on or off.*/
select into "nl:"
   SEC_IND = cnvtInt(d.info_number)
from dm_info d
where d.info_domain = "SECURITY"
   and d.info_name = "SEC_ORG_RELTN"
detail
   i1EncntrOrgSecInd = SEC_IND
with noCounter
 
/*Determine if multifacility logic is on or off.*/
select into "nl:"
 
from him_system_params h
   where h.beg_effective_dt_tm <= cnvtDateTime(curdate, curtime3)
      and h.end_effective_dt_tm >= cnvtDateTime(curdate, curtime3)
      and h.active_ind = 1
 
detail
   i1MultiFacilityLogicInd = h.facility_logic_ind
 
with noCounter
 
if(i1EncntrOrgSecInd != 0 or i1MultiFacilityLogicInd != 0)
   ;74990select distinct into "nl:"
 
   ;74990   organization_id = o.organization_id,
   ;74990   ORGANIZATION_NAME = substring(1,100,o.org_name)
   ;74990from prsnl_org_reltn p
   ;74990   ,organization o
 
   ;74990plan p
   ;74990   where p.person_id = reqinfo->updt_Id
   ;74990      and p.beg_effective_Dt_Tm <= cnvtdatetime(curdate,curtime3)
   ;74990      and p.end_effective_Dt_Tm >= cnvtdatetime(curdate,curtime3)
   ;74990      and p.active_Ind = 1
 
   ;74990join o
   ;74990   where o.organization_id = p.organization_id
 
   ;74990 Begin
   
;76470 - Structure declared in include file
;76470free record org_list
 
;76470Record org_list
;76470(
;76470   1 organizations[*]
;76470      2 organization_id    = f8
;76470      2 confid_cd          = f8
;76470      2 confid_level      = i4
;76470)
;76470 Call GetUserFacilities(org_list, 1)
Call GetUserFacilities(1) ;76470
 
    set cur_list_size = size(org_list->organizations,5)
    
    if (cur_list_size > 0) ;76470
        set loop_cnt = ceil( cnvtreal(cur_list_size) /batch_size)
        set new_list_size = loop_cnt * batch_size
        set stat = alterlist(org_list->organizations,new_list_size)
        set nstart = 1
        set idx = 0
     
        ;pad the extra record structure members so that the 0 org is not returned
        for (idx = cur_list_size+1 to new_list_size)
          set org_list->organizations[idx].organization_id
              = org_list->organizations[cur_list_size].organization_id
       endfor
     
        select distinct into "nl:"
            organization_id = o.organization_id,
           ORGANIZATION_NAME = substring(1,100,o.org_name)
         
     
            from (dummyt d with seq = value(loop_cnt)),
               organization o
            plan d
               where initarray(nstart,evaluate(d.seq,1,1,nstart+batch_size))
            join o
             where expand(idx, nstart, nstart+(batch_size-1), o.organization_id,
                            org_list->organizations[idx].organization_id)
             and o.org_name in
             						("Fort Sanders Regional Medical Center")
        ;74990 End
       ;185876 order ORGANIZATION_NAME
       order cnvtupper(o.org_name) ;185876
     
       head report
          delta = 1000
          columnTitle = ConCat(reportInfo(1), "$")
          count=0
          stat = AlterList(reply->data, delta)
     
       detail
          count = count+1
          if (Mod(count, delta) = 1)
          stat = AlterList(reply->data, count+delta)
          endif
     
          reply->data[count].buffer = ConCat(reportInfo(2), "$")
     
       foot report
          stat = AlterList(reply->data, count);
          reply->status_data.status = "S"
          valid = 1
     
       with maxrow = 1, reportHelp, check, nocounter
    endif ;76470
 
else
   select into "nl:"
      ID = 0
      ,NAME = i18nAllFacilities
   from (dummyt d with seq = 1)
 
 
   head report
      delta = 1000
      columnTitle = ConCat(reportInfo(1), "$")
      count=0
      stat = AlterList(reply->data, delta)
 
   detail
      count = count+1
      if (Mod(count, delta) = 1)
      stat = AlterList(reply->data, count+delta)
      endif
 
      reply->data[count].buffer = ConCat(reportInfo(2), "$")
 
   foot report
      stat = AlterList(reply->data, count);
      reply->status_data.status = "S"
      valid = 1
 
   with maxrow = 1, reportHelp, check, nocounter
 
endif
 
end
go
 

