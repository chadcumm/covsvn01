drop program cov_him_refused_orders go
create program cov_him_refused_orders

;cov_mak_defic_by_phys_ccl

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility(ies)" = ""
	, "Physician(s)" = "" 

with OUTDEV, ORGANIZATIONS, PHYSICIANS

execute cov_mak_defic_by_phys_ccl $OUTDEV, $ORGANIZATIONS


select into $OUTDEV
	 location = t_rec->qual[d.seq].location
	,physician_position = substring(1,50,t_rec->qual[d.seq].physician_position)
	,physician_name = substring(1,50,t_rec->qual[d.seq].physician_name)
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
	,ordering_prsnl_position = substring(1,50, t_rec->qual[d.seq].ordering_prsnl_pos)
	,ordering_prsnl = substring(1,50,t_rec->qual[d.seq].ordering_prsnl_name)
	,ordering_comm_type = substring(1,50,t_rec->qual[d.seq].communication_type)
	,refusing_provider = substring(1,50,t_rec->qual[d.seq].refuse_provider_name)
	,refusing_reason = substring(1,50,t_rec->qual[d.seq].refuse_reason)
	,event_id = t_rec->qual[d.seq].event_id
	,order_id = t_rec->qual[d.seq].order_id
from (dummyt d with seq = t_rec->cnt) 
plan d
with nocounter, separator = " ", format

#exit_script


end
go