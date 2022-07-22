drop program cov_saved_progress_notes go
create program cov_saved_progress_notes

;cov_mak_defic_by_phys_ccl

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Facility(ies)" = 0 

with OUTDEV, ORGANIZATIONS

execute cov_mak_defic_by_phys_driver $OUTDEV, $ORGANIZATIONS


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
	,event_id = t_rec->qual[d.seq].event_id
from (dummyt d with seq = t_rec->cnt) 
plan d
	where t_rec->qual[d.seq].event_id > 0.0
	and   t_rec->qual[d.seq].status = "Expected Sign"
with nocounter, separator = " ", format


#exit_script


end
go
