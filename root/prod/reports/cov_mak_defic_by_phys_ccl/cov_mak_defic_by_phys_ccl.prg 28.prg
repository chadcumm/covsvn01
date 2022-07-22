drop program cov_mak_defic_by_phys_ccl go
create program cov_mak_defic_by_phys_ccl

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Facility(ies)" = 0
	, "Physician(s)" = 0 

with OUTDEV, ORGANIZATIONS, PHYSICIANS


free record t_rec
record t_rec
(
	1 cnt = i4
	1 def_check = i2
	1 qual[*]
		2 location              = vc
		2 physician_name        = vc
		2 physician_position    = vc
		2 physician_position_cd	= f8
		2 physician_star_id     = vc
		2 patient_name          = vc
		2 mrn                   = vc
		2 fin                   = vc
		2 discharge_dt_tm       = dq8
		2 dicharge_date         = vc
		2 deficiency            = vc
		2 status                = vc
		2 deficiency_age_days   = i4
		2 deficiency_age_hours  = i4
		2 encounter_type        = vc
		2 order_notification_id = f8
		2 physician_id          = f8
		2 scanned_image         = vc
		2 scanning_prsnl        = vc
		2 event_id              = f8
		2 order_id              = f8
		2 communication_type_cd = f8
		2 communication_type    = vc
		2 ordering_prsnl_id		= f8
		2 ordering_prsnl_name	= vc
		2 ordering_prsnl_pos	= vc
		2 ordering_prsnl_pos_cd	= f8
		2 refuse_provider_name	= vc
		2 refuse_provider_id    = f8
		2 refuse_reason			= vc
		
) with persistscript


%i cclsource:him_reports_prompts.inc
%i cclsource:him_reports_layout.inc
%i cust_script:cov_him_mak_defic_by_phys_prmpt.inc

;set t_rec->def_check = $DEF_CHECK


call echo(build2("Finding STAR Doctor Number"))

select into "nl:"
from 
	 (dummyt d with seq = value(size(data->qual,5)))
    ,prsnl_alias pa
plan d
join pa
	where 	pa.person_id 			= data->qual[d.seq]->physician_person_id
	and		pa.active_ind 			= 1
	and		pa.prsnl_alias_type_cd	= value(uar_get_code_by("DISPLAY",320,"ORGANIZATION DOCTOR"))
	and		pa.alias_pool_cd		= value(uar_get_code_by("DISPLAY",263,"STAR Doctor Number"))
	and		pa.beg_effective_dt_tm	<= cnvtdatetime(curdate,curtime3)
	and		pa.end_effective_dt_tm	>= cnvtdatetime(curdate,curtime3)
detail
	data->qual[d.seq]->physician_star_id = pa.alias
with nocounter


if ((t_rec->def_check = 0) or (t_rec->def_check = 1)) ;documents 

call echo(build2("Determining if the document is a scanned document"))

select into "nl:" 
from 
	 (dummyt d with seq = value(size(data->qual,5)))
	,(dummyt ddefic with seq = value(data->max_defic_qual_count))
    ,ce_blob_result cbr
plan (d where (d.seq > 0))

join ddefic 
	where ddefic.seq <= size(data->qual[d.seq].defic_qual,5)
join cbr 
	where	cbr.event_id 			= data->qual[d.seq]->defic_qual[ddefic.seq].event_id 
	and		cbr.storage_cd 			= value(uar_get_code_by("DISPLAYKEY", 25, "OTG")) 
	and		cbr.valid_until_dt_tm 	>= cnvtdatetime(curdate,curtime3)
detail
	data->qual[d.seq]->defic_qual[ddefic.seq].otg_id = 1
with nocounter

call echo(build2("Finding Transcribing Personnel"))
select into "nl:" 
from 
	 (dummyt d with seq = value(size(data->qual,5)))
    ,(dummyt ddefic with seq = value(data->max_defic_qual_count))
    ,ce_event_prsnl cbr
    ,prsnl p
plan d
join ddefic 
	where 	ddefic.seq <= size(data->qual[d.seq].defic_qual,5)
join cbr 
	where	cbr.event_id = data->qual[d.seq]->defic_qual[ddefic.seq].event_id 
	and		cbr.action_type_cd = value(uar_get_code_by("MEANING",21,"TRANSCRIBE"))
join p
	where p.person_id = cbr.action_prsnl_id
order by
	 cbr.event_id
	,cbr.action_dt_tm
head cbr.event_id
	data->qual[d.seq]->defic_qual[ddefic.seq].scanning_prsnl_id = cbr.action_prsnl_id
	data->qual[d.seq]->defic_qual[ddefic.seq].scanning_prsnl = p.name_full_formatted
with nocounter
endif

if ((t_rec->def_check = 0) or (t_rec->def_check = 2)) ;orders
call echo(build2("Finding ordering personnel and communication type "))
select into "nl:"
from
	 (dummyt   d1  with seq = value(size(data->qual, 5)))
	,(dummyt   d2  with seq = 1)
	,orders o
	,order_action oa
	,prsnl p
plan d1 where maxrec(d2, size(data->qual[d1.seq].defic_qual, 5))
join d2 where data->qual[d1.seq].defic_qual[d2.seq].order_id > 0.0
join o
	where o.order_id = data->qual[d1.seq].defic_qual[d2.seq].order_id
join oa
	where oa.order_id = o.order_id
	and   oa.action_type_cd = value(uar_get_code_by("MEANING",6003,"ORDER"))
join p
	where p.person_id = oa.action_personnel_id
	and   p.physician_ind != 1
detail
	data->qual[d1.seq].defic_qual[d2.seq].order_communication_type = uar_get_code_display(oa.communication_type_cd)
	data->qual[d1.seq].defic_qual[d2.seq].order_communication_type_cd = oa.communication_type_cd
	data->qual[d1.seq].defic_qual[d2.seq].order_action_prsnl_id = p.person_id
	data->qual[d1.seq].defic_qual[d2.seq].order_action_prsnl_name = p.name_full_formatted
	data->qual[d1.seq].defic_qual[d2.seq].order_action_prsnl_position = uar_get_code_display(p.position_cd)
	data->qual[d1.seq].defic_qual[d2.seq].order_action_prsnl_position_cd = p.position_cd
	;call echo(p.name_full_formatted)
with nocounter

call echo(build2("Finding refused order notifications "))
select into "nl:"
from
	 (dummyt   d1  with seq = value(size(data->qual, 5)))
	,(dummyt   d2  with seq = 1)
	,order_notification on1
    ,order_notification on2
	,prsnl p1
plan d1 where maxrec(d2, size(data->qual[d1.seq].defic_qual, 5))
join d2 where data->qual[d1.seq].defic_qual[d2.seq].order_id > 0.0
join on1
	where 	on1.order_id = data->qual[d1.seq].defic_qual[d2.seq].order_id
	and 	on1.notification_status_flag = 3 
   	and		on1.notification_type_flag = 2
join on2
	where	on2.order_id = on1.order_id
	and		on2.parent_order_notification_id = on1.order_notification_id
   	and 	on2.caused_by_flag = 2
join p1
	where 	p1.person_id = on1.to_prsnl_id
detail
	data->qual[d1.seq].defic_qual[d2.seq].order_refuse_provider_id = p1.person_id
	data->qual[d1.seq].defic_qual[d2.seq].order_refuse_provider_name = p1.name_full_formatted
	data->qual[d1.seq].defic_qual[d2.seq].order_refuse_reason = on2.notification_comment
	;call echo(p.name_full_formatted)
with nocounter
endif

call echo(build2("Calculating Deficiency age in days "))
select into "nl:" 
from 
	 (dummyt d with seq = value(size(data->qual,5)))
    ,(dummyt ddefic with seq = value(data->max_defic_qual_count))
plan d
join ddefic 
	where 	ddefic.seq <= size(data->qual[d.seq].defic_qual,5)
detail
	data->qual[d.seq]->defic_qual[ddefic.seq]->age_days = (data->qual[d.seq]->defic_qual[ddefic.seq]->defic_age/24)
with nocounter

call echo(build2("Building Output Records"))
select into "nl:"
from (dummyt d with seq = value(size(data->qual,5))),
     (dummyt ddefic with seq = value(data->max_defic_qual_count))
plan d
join ddefic 
	where ddefic.seq <= size(data->qual[d.seq].defic_qual,5)
detail
	t_rec->cnt 	= (t_rec->cnt + 1)
	stat 		= alterlist(t_rec->qual,t_rec->cnt)
	t_rec->qual[t_rec->cnt].location				= data->qual[d.seq]->org_org_name
	t_rec->qual[t_rec->cnt].physician_name			= data->qual[d.seq]->physician_name_full_formatted
	t_rec->qual[t_rec->cnt].physician_position		= trim(uar_get_code_display(data->qual[d.seq]->physician_position_cd),3)
	t_rec->qual[t_rec->cnt].physician_position_cd	= data->qual[d.seq]->physician_position_cd
	t_rec->qual[t_rec->cnt].physician_star_id		= data->qual[d.seq]->physician_star_id
	t_rec->qual[t_rec->cnt].patient_name			= data->qual[d.seq]->patient_name
	t_rec->qual[t_rec->cnt].mrn						= data->qual[d.seq]->mrn
	t_rec->qual[t_rec->cnt].fin						= data->qual[d.seq]->fin
	t_rec->qual[t_rec->cnt].discharge_dt_tm			= data->qual[d.seq]->disch_dt_tm
	t_rec->qual[t_rec->cnt].dicharge_date			= format(data->qual[d.seq]->disch_dt_tm,"DD-MMM-YYYY HH:MM;;Q")
	t_rec->qual[t_rec->cnt].deficiency				= data->qual[d.seq]->defic_qual[ddefic.seq]->deficiency_name
	t_rec->qual[t_rec->cnt].status					= data->qual[d.seq]->defic_qual[ddefic.seq]->status
	t_rec->qual[t_rec->cnt].deficiency_age_days		= data->qual[d.seq]->defic_qual[ddefic.seq]->age_days
	t_rec->qual[t_rec->cnt].deficiency_age_hours	= data->qual[d.seq]->defic_qual[ddefic.seq]->defic_age
	t_rec->qual[t_rec->cnt].encounter_type			= trim(uar_get_code_display(data->qual[d.seq]->encntr_encntr_type_cd),3)
	t_rec->qual[t_rec->cnt].physician_id			= data->qual[d.seq]->physician_person_id
	t_rec->qual[t_rec->cnt].scanned_image			= cnvtstring(data->qual[d.seq]->defic_qual[ddefic.seq].otg_id)
	t_rec->qual[t_rec->cnt].scanning_prsnl			= data->qual[d.seq]->defic_qual[ddefic.seq].scanning_prsnl
	t_rec->qual[t_rec->cnt].event_id				= data->qual[d.seq]->defic_qual[ddefic.seq].event_id
	t_rec->qual[t_rec->cnt].order_id				= data->qual[d.seq]->defic_qual[ddefic.seq].order_id
	t_rec->qual[t_rec->cnt].communication_type		= data->qual[d.seq]->defic_qual[ddefic.seq].order_communication_type
	t_rec->qual[t_rec->cnt].communication_type_cd	= data->qual[d.seq]->defic_qual[ddefic.seq].order_communication_type_cd
	t_rec->qual[t_rec->cnt].ordering_prsnl_id		= data->qual[d.seq]->defic_qual[ddefic.seq].order_action_prsnl_id
	t_rec->qual[t_rec->cnt].ordering_prsnl_name		= data->qual[d.seq]->defic_qual[ddefic.seq].order_action_prsnl_name
	t_rec->qual[t_rec->cnt].refuse_provider_id		= data->qual[d.seq]->defic_qual[ddefic.seq].order_refuse_provider_id
	t_rec->qual[t_rec->cnt].refuse_provider_name	= data->qual[d.seq]->defic_qual[ddefic.seq].order_refuse_provider_name
	t_rec->qual[t_rec->cnt].refuse_reason			= data->qual[d.seq]->defic_qual[ddefic.seq].order_refuse_reason
	t_rec->qual[t_rec->cnt].ordering_prsnl_pos_cd	= data->qual[d.seq]->defic_qual[ddefic.seq].order_action_prsnl_position_cd
	t_rec->qual[t_rec->cnt].ordering_prsnl_pos		
									= uar_get_code_display(data->qual[d.seq]->defic_qual[ddefic.seq].order_action_prsnl_position_cd)
	
with nocounter
/*
select into $OUTDEV ;into "nl:"
	 location = t_rec->qual[d.seq].location
	,physician_name = substring(1,50,t_rec->qual[d.seq].physician_name)
	,physician_position = substring(1,50,t_rec->qual[d.seq].physician_position)
	,physician_star_id = t_rec->qual[d.seq].physician_star_id
	,patient_name = substring(1,50,t_rec->qual[d.seq].patient_name)
	,mrn = substring(1,15,t_rec->qual[d.seq].mrn)
	,fin = substring(1,15,t_rec->qual[d.seq].fin)
	,discharge_dt_tm = t_rec->qual[d.seq].discharge_dt_tm ";;q"
	,deficiency = substring(1,50,t_rec->qual[d.seq].deficiency)
	,status = substring(1,15,t_rec->qual[d.seq].status)
	,deficiency_age_days = t_rec->qual[d.seq].deficiency_age_days
	,deficiency_age_hours = t_rec->qual[d.seq].deficiency_age_hours
	,encounter_type = substring(1,15,t_rec->qual[d.seq].encounter_type)
	,physician_id = t_rec->qual[d.seq].physician_id
	,scanned_image = t_rec->qual[d.seq].scanned_image
	,scanning_prsnl = substring(1,50,t_rec->qual[d.seq].scanning_prsnl)
	,ordering_prsnl = substring(1,50,t_rec->qual[d.seq].ordering_prsnl_name)
	,ordering_comm_type = substring(1,50,t_rec->qual[d.seq].communication_type)
	,refusing_provider = substring(1,50,t_rec->qual[d.seq].refuse_provider_name)
	,refusing_reason = substring(1,50,t_rec->qual[d.seq].refuse_reason)
	,event_id = t_rec->qual[d.seq].event_id
	,order_id = t_rec->qual[d.seq].order_id
	from (dummyt d with seq = t_rec->cnt) 
with nocounter, separator = " ", format
*/
#exit_script

call echorecord(data,"ccluserdir:cov_make_defic_by_phys_ccl_data.dat")

end go
