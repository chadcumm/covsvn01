drop program cov_mak_defic_by_phys_doc go
create program cov_mak_defic_by_phys_doc

;cov_mak_defic_by_phys_ccl

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility(ies)" = ""
	, "Discharge Start Date" = "SYSDATE"     ;* Enter the start date for the discharge date range.
	, "Discharge End Date" = "SYSDATE"       ;* Enter the end date for the discharge date range. 

with OUTDEV, ORGANIZATIONS, start_datetime, end_datetime

execute cov_mak_defic_by_phys_ccl $OUTDEV, $ORGANIZATIONS, 0, $start_datetime, $end_datetime


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
	and   t_rec->qual[d.seq].physician_name != "HIM, REFUSAL INBOX Cerner"
with nocounter, separator = " ", format

#exit_script


end
go