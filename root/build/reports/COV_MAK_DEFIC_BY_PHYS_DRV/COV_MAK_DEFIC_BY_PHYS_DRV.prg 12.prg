drop program cov_mak_defic_by_phys_drv go
create program cov_mak_defic_by_phys_drv

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility(ies)" = 0
	, "Physician(s)" = 0

with OUTDEV, ORGANIZATIONS, PHYSICIANS



execute ReportRtl
%i cclsource:him_reports_prompts.inc
%i cclsource:him_reports_layout.inc
%i cust_script:cov_him_mak_defic_by_phys_prmpt.inc

free record t_rec
record t_rec
(
	1 cnt = i4
	1 qual[*]
		2 location              = vc
		2 physician_name        = vc
		2 physician_position    = vc
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
)

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

call echo(build2("Determining if the document is a scanned document"))

select into "nl:" ;$OUTDEV
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
	
	if (validate(data->qual[d.seq]->defic_qual[ddefic.seq]->order_qual[1]->order_notif_order_notification_id))
    	t_rec->qual[t_rec->cnt].order_notification_id = 
    		data->qual[d.seq]->defic_qual[ddefic.seq]->order_qual[1]->order_notif_order_notification_id
    endif
	t_rec->qual[t_rec->cnt].physician_id			= data->qual[d.seq]->physician_person_id
	t_rec->qual[t_rec->cnt].scanned_image			= data->qual[d.seq]->defic_qual[ddefic.seq].otg_id
	t_rec->qual[t_rec->cnt].scanning_prsnl			= data->qual[d.seq]->defic_qual[ddefic.seq].scanning_prsnl
	t_rec->qual[t_rec->cnt].event_id				= data->qual[d.seq]->defic_qual[ddefic.seq].event_id
	t_rec->qual[t_rec->cnt].order_id				= data->qual[d.seq]->defic_qual[ddefic.seq].order_id
with nocounter


/*
select 
	if (cnvtint(GetParameter("_PREPARE_")) = 1)
		with nocounter, reporthelp, check, maxrec = 1
	else
		with nocounter, reporthelp, check
	endif
into "nl:"
*/
;call echorecord(data)

end go
