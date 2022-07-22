drop program cov_anes_pending_orders go
create program cov_anes_pending_orders

;cov_mak_defic_by_phys_ccl

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility(ies)" = 0 

with OUTDEV, ORGANIZATIONS

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
	,powerplan_name = substring(1,100,t_rec->qual[d.seq].powerplan_desc)
	,status = substring(1,15,t_rec->qual[d.seq].status)
	,deficiency_age_days = t_rec->qual[d.seq].deficiency_age_days
	,deficiency_age_hours = t_rec->qual[d.seq].deficiency_age_hours
	,encounter_type = substring(1,15,t_rec->qual[d.seq].encounter_type)
	,physician_id = t_rec->qual[d.seq].physician_id
	,ordering_prsnl_position = substring(1,50, t_rec->qual[d.seq].ordering_prsnl_pos)
	,ordering_prsnl = substring(1,50,t_rec->qual[d.seq].ordering_prsnl_name)
	,ordering_comm_type = substring(1,50,t_rec->qual[d.seq].communication_type)
	,latest_comm_type = substring(1,50,t_rec->qual[d.seq].latest_comm_type)
	,order_id = t_rec->qual[d.seq].order_id
	,order_notif_id = t_rec->qual[d.seq].order_notification_id
from (dummyt d with seq = t_rec->cnt) 
plan d
	where t_rec->qual[d.seq].order_id > 0.0
	and   t_rec->qual[d.seq].status = "Pending"
	and   t_rec->qual[d.seq].communication_type != null
with nocounter, separator = " ", format

#exit_script


end
go
