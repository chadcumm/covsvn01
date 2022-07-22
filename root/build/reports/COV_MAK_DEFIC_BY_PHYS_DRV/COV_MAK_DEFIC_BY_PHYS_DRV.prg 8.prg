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

;call echorecord(data)

end go
