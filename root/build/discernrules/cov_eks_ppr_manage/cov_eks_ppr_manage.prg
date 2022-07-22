/*****************************************************************************
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   cov_eks_ppr_manage.prg
  Object name:        cov_eks_ppr_manage
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
drop program cov_eks_ppr_manage:dba go
create program cov_eks_ppr_manage:dba

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
	1 retval 						= i2
	1 log_message 					=  vc
	1 log_misc1 					= vc
	1 return_value 					= vc
	1 code_value
	 2 person_prsnl_reltn_331
	  3 primary_care_physician_cd 	= f8
	  3 oncology_lifetime_cd 		= f8

)

record 600312_request (
  1 prsnl_person_id = f8   
  1 person_prsnl_reltn_cd = f8   
  1 person_id = f8   
  1 encntr_prsnl_reltn_cd = f8   
  1 encntr_id = f8   
  1 beg_effective_dt_tm = dq8   
  1 end_effective_dt_tm = dq8   
) 

record 600324_request (
  1 person_id = f8   
) 

record 600313_request (
  1 prsnl_person_id = f8   
  1 person_qual [*]   
    2 person_prsnl_reltn_id = f8   
  1 encntr_qual [*]   
    2 encntr_prsnl_reltn_id = f8   
) 

set t_rec->retval							= -1
set t_rec->return_value						= "FAILED"
set t_rec->patient.encntr_id 				= link_encntrid
set t_rec->patient.person_id				= link_personid
set t_rec->patient.order_id					= link_orderid

if (t_rec->patient.encntr_id <= 0.0)
	set t_rec->log_message = concat("link_encntrid not found")
	go to exit_script
endif

if (t_rec->patient.person_id <= 0.0)
	set t_rec->log_message = concat("link_personid not found")
	go to exit_script
endif

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


select into "nl:"
from
	 encounter e
	,orders o
	,person p
	,order_detail od
	,order_entry_fields oef
plan e
	where e.encntr_id = t_rec->patient.encntr_id
	and   e.person_id = t_rec->patient.person_id
join o
	where o.order_id = t_rec->patient.order_id
	and   e.encntr_id = e.encntr_id
join p
	where p.person_id = e.person_id
join od
	where od.order_id = o.order_id
join oef
	where oef.oe_field_id = od.oe_field_id
	and   oef.description in ("Provider","Lifetime Action","Requested Start Date/Time")
order by
	 o.order_id
	,oef.oe_field_id
	,od.detail_sequence desc
head o.order_id
	t_rec->log_message = concat(trim(t_rec->log_message),";","Query Executed")
head oef.oe_field_id
	case (oef.description)
		of "Provider":					t_rec->provider.provider_id = od.oe_field_value
		of "Lifetime Action":			t_rec->action.oef = od.oe_field_display_value
		of "Requested Start Date/Time":	t_rec->provider.start_dt_tm = od.oe_field_dt_tm_value
	endcase	
with nocounter

select into "nl:"
from
	prsnl p
plan p
	where p.person_id = t_rec->provider.provider_id
detail
	t_rec->provider.provider_name = p.name_full_formatted
with nocounter

if (t_rec->provider.provider_id <= 0.0)
	set t_rec->log_message = concat("provider not found")
	go to exit_script
endif

if (t_rec->action.oef not in("Add/Update","Remove"))
	set t_rec->log_message = concat("action not found")
	go to exit_script
endif

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

if (t_rec->action.oef = "Add/Update")
	if (t_rec->provider.current.provider_id = 0.0)
		set t_rec->action.type = "Add"
	else
		set t_rec->action.type = "Update"
	endif
elseif (t_rec->action.oef = "Remove")
	if (t_rec->provider.current.provider_id = t_rec->provider.provider_id)
		set t_rec->action.type = "Remove"
	endif
endif
	

if (t_rec->action.type = "Add")

	set stat = initrec(600312_request)
	free record 600312_reply
	
	set 600312_request->person_id				= t_rec->patient.person_id
	set 600312_request->encntr_id				= t_rec->patient.encntr_id
	set 600312_request->person_prsnl_reltn_cd 	= t_rec->code_value.person_prsnl_reltn_331.oncology_lifetime_cd
	set 600312_request->prsnl_person_id 		=  t_rec->provider.provider_id
	set 600312_request->beg_effective_dt_tm  	= cnvtdatetime(t_rec->provider.start_dt_tm)
	
	set stat = tdbexecute(600005,600600,600312,"REC",600312_request,"REC",600312_reply)
	
	call echorecord(600312_reply)
	
elseif (t_rec->action.type = "Remove")

	set stat = initrec(600313_request)
	free record 600313_reply
	
	set 600313_request->prsnl_person_id = t_rec->provider.current.provider_id
	set stat = alterlist(600313_request->person_qual,1)
	set 600313_request->person_qual[1].person_prsnl_reltn_id = t_rec->provider.current.person_prsnl_reltn_id
	
	set stat = tdbexecute(600005,600600,600313,"REC",600313_request,"REC",600313_reply)
	
	call echorecord(600313_reply)
	
elseif (t_rec->action.type = "Update")

	set stat = initrec(600313_request)
	free record 600313_reply
	
	set 600313_request->prsnl_person_id = t_rec->provider.current.provider_id
	set stat = alterlist(600313_request->person_qual,1)
	set 600313_request->person_qual[1].person_prsnl_reltn_id = t_rec->provider.current.person_prsnl_reltn_id
	
	set stat = tdbexecute(600005,600600,600313,"REC",600313_request,"REC",600313_reply)
	
	call echorecord(600313_reply)
	
	set stat = initrec(600312_request)
	free record 600312_reply
	
	set 600312_request->person_id				= t_rec->patient.person_id
	set 600312_request->encntr_id				= t_rec->patient.encntr_id
	set 600312_request->person_prsnl_reltn_cd 	= t_rec->code_value.person_prsnl_reltn_331.oncology_lifetime_cd
	set 600312_request->prsnl_person_id 		=  t_rec->provider.provider_id
	set 600312_request->beg_effective_dt_tm  	= cnvtdatetime(t_rec->provider.start_dt_tm)
	
	set stat = tdbexecute(600005,600600,600312,"REC",600312_request,"REC",600312_reply)
	
	call echorecord(600312_reply)
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
										trim(t_rec->provider.provider_name),"|",
										trim(t_rec->action.oef),"|",
										trim(t_rec->action.type),"|"
									)
call echorecord(t_rec)

set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1


end 
go

