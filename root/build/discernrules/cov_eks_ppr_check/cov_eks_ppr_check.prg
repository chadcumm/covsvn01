/*****************************************************************************
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   cov_eks_ppr_check.prg
  Object name:        cov_eks_ppr_check
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).
  						https://connect.cerner.com/message/872481#872481

						PM_ENS_ENCNTR_PRSNL_RELTN
						pts_add_prsnl_reltn	600312
						PTS_CHG_PRSNL_RELTN 600313
						PTS_GET_PRSNL_RELTN	600311
						600324 - pts_get_ppr_summary
						
						3072006     DiscernDialogueRequest            RR   CPM.EKS
						
						phsa_cd_obs_translate_rule
						phsa_cd_obs_post_process
						
						

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   03/01/2019  Chad Cummings			initial build
******************************************************************************/
drop program cov_eks_ppr_check:dba go
create program cov_eks_ppr_check:dba

set retval = -1

free record t_rec
record t_rec
(
	1 patient
	 2 encntr_id 					= f8
	 2 person_id 					= f8
	 2 order_id						= f8
	1 provider
	 2 provider_id					= f8
	 2 provider_name				= vc
	 2 start_dt_tm					= f8
	 2 current
	  3 provider_id					= f8
	  3 provider_name				= vc
	  3 person_prsnl_reltn_id		= f8
	1 action
	 2 oef							= vc
	 2 type							= vc
	1 orderable
	 2 mnemonic						= vc
	 2 catalog_cd					= f8
	1 retval 						= i2
	1 log_message 					=  vc
	1 log_misc1 					= vc
	1 return_value 					= vc
	1 code_value
	 2 person_prsnl_reltn_331
	  3 primary_care_physician_cd 	= f8
	  3 oncology_lifetime_cd 		= f8

)

/*
record request (
  1 Req_type_cd = f8   
  1 Passthru_ind = i2   
  1 Trigger_app = i4   
  1 Person_id = f8   
  1 Encntr_id = f8   
  1 Position_cd = f8   
  1 Sex_cd = f8   
  1 Birth_dt_tm = dq8   
  1 Weight = f8   
  1 Weight_unit_cd = f8   
  1 Height = f8   
  1 Height_unit_cd = f8   
  1 OrderList [*]   
    2 synonym_code = f8   
    2 catalog_code = f8   
    2 catalogTypeCd = f8   
    2 orderId = f8   
    2 actionTypeCd = f8   
    2 activityTypeCd = f8   
    2 activitySubTypeCd = f8   
    2 dose = f8   
    2 dose_unit = f8   
    2 start_dt_tm = dq8   
    2 end_dt_tm = dq8   
    2 route = f8   
    2 frequency = f8   
    2 physician = f8   
    2 rate = f8   
    2 infuse_over = i4   
    2 infuse_over_unit_cd = f8   
    2 DetailList [*]   
      3 oeFieldId = f8   
      3 oeFieldValue = f8   
      3 oeFieldDisplayValue = vc  
      3 oeFieldDtTmValue = dq8   
      3 oeFieldMeaning = vc  
    2 DiagnosisList [*]   
      3 dx = vc  
    2 IngredientList [*]   
      3 catalogCd = f8   
      3 synonymId = f8   
      3 item_id = f8   
      3 strengthDose = f8   
      3 strengthUnit = f8   
      3 volumeDose = f8   
      3 volumeUnit = f8   
      3 bag_frequency_cd = f8   
      3 freetextDose = vc  
      3 doseQuantity = f8   
      3 doseQuantityUnit = f8   
      3 ivseq = i4   
      3 normalized_rate = f8   
      3 normalized_rate_unit = f8   
    2 protocol_order_ind = i2   
    2 DayOfTreatment_order_ind = i2   
  1 Alert_Titlebar = vc  
  1 commonreply_ind = i2   
  1 freetextParam = vc  
  1 expert_trigger = vc  
) 

*/

record 600324_request (
  1 person_id = f8   
) 

declare i = i2 with noconstant(0), protect

set t_rec->retval							= -1
set t_rec->return_value						= "FAILED"
set t_rec->patient.encntr_id 				= request->encntr_id
set t_rec->patient.person_id				= request->person_id

set t_rec->orderable.mnemonic				= "Lifetime Oncology Provider"

set t_rec->orderable.catalog_cd				= uar_get_code_by("DISPLAY",200,t_rec->orderable.mnemonic)

if (t_rec->patient.encntr_id <= 0.0)
	set t_rec->log_message = concat("link_encntrid not found")
	go to exit_script
endif

if (t_rec->patient.person_id <= 0.0)
	set t_rec->log_message = concat("link_personid not found")
	go to exit_script
endif

if (t_rec->orderable.catalog_cd	 <= 0.0)
	set t_rec->log_message = concat("order in catalog not found")
	go to exit_script
endif

for (i=1 to size(request->orderlist,5))
	if (request->orderlist[i].catalog_code = t_rec->orderable.catalog_cd)
		set t_rec->provider.provider_id = request->orderlist[i].physician
		set t_rec->patient.order_id	= request->orderlist[i].orderid
	endif
endfor

if (t_rec->patient.order_id <= 0.0)
	set t_rec->log_message = concat("link_orderid not found")
	go to exit_script
endif

/* Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->log_message = value(parameter(1,0))
endif */

set t_rec->return_value = "FALSE"

;set t_rec->code_value.person_prsnl_reltn_331.oncology_lifetime_cd 		= uar_get_code_by("DISPLAY",331,"Oncology Lifetime")
set t_rec->code_value.person_prsnl_reltn_331.oncology_lifetime_cd 		= uar_get_code_by("DISPLAY",331,"Oncologist")
set t_rec->code_value.person_prsnl_reltn_331.primary_care_physician_cd 	= uar_get_code_by("DISPLAY",331,"Primary Care Physician")

set stat = initrec(600324_request)
free record 600324_reply
	
set 600324_request->person_id	= t_rec->patient.person_id

set stat = tdbexecute(600005,967400,600324,"REC",600324_request,"REC",600324_reply)

call echorecord(600324_reply)

select into "nl:"
from
	(dummyt d1 with seq=size(600324_reply->data,5))
plan d1
	where 600324_reply->data[d1.seq].reltn_cd = t_rec->code_value.person_prsnl_reltn_331.oncology_lifetime_cd
	and   cnvtdatetime(curdate,curtime3) 
		between cnvtdatetime(600324_reply->data[d1.seq].beg_effective_dt_tm) 
		and 	cnvtdatetime(600324_reply->data[d1.seq].end_effective_dt_tm)
order by
	600324_reply->data[d1.seq].beg_effective_dt_tm
detail
	t_rec->provider.current.provider_id 			= 600324_reply->data[d1.seq].prsnl_person_id
	t_rec->provider.current.provider_name 			= 600324_reply->data[d1.seq].prsnl_name
	t_rec->provider.current.person_prsnl_reltn_id 	= 600324_reply->data[d1.seq].generic_prsnl_reltn_id
with nocounter

if (t_rec->provider.current.provider_id = 0.0)
	set t_rec->log_message = concat("no current active relationship to remove")
	go to exit_script
elseif (t_rec->provider.current.provider_id = t_rec->provider.provider_id)
	set t_rec->log_message = concat("ordering provider matches existing relationship")
	go to exit_script
endif

set t_rec->return_value = "TRUE"

#exit_script

if (trim(cnvtupper(t_rec->return_value)) = "TRUE")
	set t_rec->retval = 100
elseif (trim(cnvtupper(t_rec->return_value)) = "FALSE")
	set t_rec->retval = 0
else
	set t_rec->retval = 0
endif

set t_rec->log_message = concat(
										trim(t_rec->log_message),";",
										trim(cnvtupper(t_rec->return_value)),":",
										trim(cnvtstring(t_rec->patient.person_id)),"|",
										trim(cnvtstring(t_rec->patient.encntr_id)),"|",
										trim(cnvtstring(t_rec->provider.provider_id)),"|",
										trim(cnvtstring(t_rec->provider.current.provider_id)),"|",
										trim(t_rec->action.oef),"|",
										trim(t_rec->action.type),"|"
									)
call echorecord(t_rec)

set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1


end 
go

