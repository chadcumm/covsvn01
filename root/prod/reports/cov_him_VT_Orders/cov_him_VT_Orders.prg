/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		09/29/2020
	Solution:			Revenue Cycle - HIM
	Source file name:	cov_him_VT_Orders.prg
	Object name:		cov_him_VT_Orders
	Request #:			8330
 
	Program purpose:	Lists data for TJC requirements to determine percentage 
						of telephone and verbal orders against all orders 
						(signed and unsigned).
 
	Executing from:		CCL
 
 	Special Notes:		
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program cov_him_VT_Orders:dba go
create program cov_him_VT_Orders:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"                    ;* Enter or select the printer or file name to send this report to.
	, "Facility(ies)" = 0
	, "Physician(s)" = 0
	, "Latest Communication Type" = VALUE(2560.00, 2561.00)
	, "FIN" = ""
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE" 

with OUTDEV, ORGANIZATIONS, PHYSICIANS, COMM_TYPE, FIN, START_DATETIME, 
	END_DATETIME
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare canceluponreview_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "CANCELUPONREVIEW"))
declare nonpatientlabspecimen_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "NONPATIENTLABSPECIMEN"))
declare order_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "ORDER"))
declare t_flag_none 				= i2 with constant(0)
declare t_flag_template 			= i2 with constant(1)

declare fin_sql						= vc with noconstant("1 = 1")
declare op_comm_type_var			= vc with noconstant(" ")


; define sql for fin
if ($FIN != "")
	set fin_sql = build2("data->qual[d.seq]->fin = '", $FIN, "'")
endif


; define operator for $COMM_TYPE
if (substring(1, 1, reflect(parameter(parameter2($COMM_TYPE), 0))) = "L") ; multiple values selected
    set op_comm_type_var = "IN"
elseif (parameter(parameter2($COMM_TYPE), 1) = 0.0) ; any selected
    set op_comm_type_var = ">="
else ; single value selected
    set op_comm_type_var = "="
endif


/**************************************************************
; DVDev Start Coding
**************************************************************/

free record finaldata
record finaldata (
	1 cnt_all_orders = i4
	
	1 cnt = i4
	1 qual [*]
		2 location = c100
		2 physician = c100
		2 physician_position = c40
		2 physician_starid = c20
		2 patient_name = c100
		2 patient_type = c40
		2 mrn = c20
		2 fin = c20
		2 admit_date = dq8
		2 discharge_date = dq8
		2 deficiency = c100
		2 status = c40
		2 deficiency_age_days = f8
		2 deficiency_age_hours = f8
		2 order_notif_id = f8
		2 order_entry_date = dq8
		2 order_prsnl = c100
		2 order_prsnl_position = c40
		2 physician_person_id = f8
		2 event_id = f8
		2 scanning_personnel = c100
		2 refusing_physician = c100
		2 refusing_reason = c40
		2 communication_type = c40
		2 powerplan_name = c100
)


/**************************************************************/
; select deficiency data
execute cov_mak_defic_by_phys_driver_2 $OUTDEV, $ORGANIZATIONS, $PHYSICIANS, $COMM_TYPE, $START_DATETIME, $END_DATETIME, 2

;call echorecord(data)

;go to exitscript


/**************************************************************/
; select order data
select into "nl:"
	total_orders = count(*)
	
from 
	ORDERS o
	
	, (inner join ORDER_ACTION oa on oa.order_id = o.order_id
		and oa.action_type_cd = order_var
		and oa.action_sequence > 0
		and oa.action_dt_tm between cnvtdatetime($START_DATETIME) and cnvtdatetime($END_DATETIME))
	
where 
	o.template_order_flag in (t_flag_none, t_flag_template)
	and o.need_doctor_cosign_ind > 0
	
head report
	finaldata->cnt_all_orders = total_orders
	
with nocounter, time = 300
 
 
/**************************************************************/ 
; select final deficiency data
select into "nl:"
from
	(dummyt d with seq = value(size(data->qual, 5)))
	, (dummyt ddefic with seq = value(data->max_defic_qual_count))
     
plan d
where
	parser(fin_sql)

join ddefic 
where 
	ddefic.seq <= size(data->qual[d.seq].defic_qual, 5)	
	and operator(data->qual[d.seq]->defic_qual[ddefic.seq]->order_qual[1].orders_latest_communication_type_cd, 
		op_comm_type_var, $COMM_TYPE)	
	and data->qual[d.seq]->defic_qual[ddefic.seq]->order_qual[1]->orders_order_action_dt_tm between
		cnvtdatetime($START_DATETIME) and cnvtdatetime($END_DATETIME)
	and data->qual[d.seq]->encntr_encntr_type_cd not in (canceluponreview_var, nonpatientlabspecimen_var)

head report
	cnt = 0
	
detail
	cnt = cnt + 1
	
	call alterlist(finaldata->qual, cnt)
	
	finaldata->cnt								= cnt
	finaldata->qual[cnt].location 				= data->qual[d.seq]->org_org_name
	finaldata->qual[cnt].physician				= data->qual[d.seq]->physician_name_full_formatted
	finaldata->qual[cnt].physician_position		= uar_get_code_display(data->qual[d.seq]->physician_position_cd)
	finaldata->qual[cnt].physician_starid		= data->qual[d.seq]->physician_star_id
	finaldata->qual[cnt].patient_name			= data->qual[d.seq]->patient_name
	finaldata->qual[cnt].patient_type			= uar_get_code_display(data->qual[d.seq]->encntr_encntr_type_cd)
	finaldata->qual[cnt].mrn					= data->qual[d.seq]->mrn
	finaldata->qual[cnt].fin					= data->qual[d.seq]->fin
	finaldata->qual[cnt].admit_date				= data->qual[d.seq]->encntr_reg_dt_tm
	finaldata->qual[cnt].discharge_date			= data->qual[d.seq]->disch_dt_tm
	finaldata->qual[cnt].deficiency				= data->qual[d.seq]->defic_qual[ddefic.seq]->deficiency_name
	finaldata->qual[cnt].status					= data->qual[d.seq]->defic_qual[ddefic.seq]->status
	finaldata->qual[cnt].deficiency_age_days	= data->qual[d.seq]->defic_qual[ddefic.seq]->order_qual[1]->orders_order_age / 24
	finaldata->qual[cnt].deficiency_age_hours	= data->qual[d.seq]->defic_qual[ddefic.seq]->order_qual[1]->orders_order_age
	
	finaldata->qual[cnt].order_notif_id			= 
		data->qual[d.seq]->defic_qual[ddefic.seq]->order_qual[1]->order_notif_order_notification_id
		
	finaldata->qual[cnt].order_entry_date		= 
		data->qual[d.seq]->defic_qual[ddefic.seq]->order_qual[1]->orders_order_action_dt_tm
				
	finaldata->qual[cnt].order_prsnl			= data->qual[d.seq]->defic_qual[ddefic.seq]->order_qual[1]->orders_order_provider
	
	finaldata->qual[cnt].order_prsnl_position	= 	
		uar_get_code_display(data->qual[d.seq]->defic_qual[ddefic.seq]->order_qual[1]->orders_order_provider_position_cd)
		
	finaldata->qual[cnt].physician_person_id	= data->qual[d.seq]->physician_person_id
	finaldata->qual[cnt].event_id				= data->qual[d.seq]->defic_qual[ddefic.seq].event_id
	finaldata->qual[cnt].scanning_personnel		= data->qual[d.seq]->defic_qual[ddefic.seq].scanning_prsnl
	finaldata->qual[cnt].refusing_physician		= data->qual[d.seq]->defic_qual[ddefic.seq].reject_prsnl
	finaldata->qual[cnt].refusing_reason		= data->qual[d.seq]->defic_qual[ddefic.seq].reject_reason
	
	finaldata->qual[cnt].communication_type		= 
		data->qual[d.seq]->defic_qual[ddefic.seq]->order_qual[1].orders_latest_communication_type
	
	finaldata->qual[cnt].powerplan_name			= 
		data->qual[d.seq]->defic_qual[ddefic.seq]->order_qual[1].orders_pathway_description

with nocounter, time = 60
 
 
/**************************************************************/ 
; select final non-deficiency order data
select into "nl:"
from
	(dummyt d with seq = value(size(data2->qual, 5)))
	, (dummyt d2 with seq = 1)
     
plan d 
where 
	maxrec(d2, size(data2->qual[d.seq].order_qual, 5))
	and data2->qual[d.seq]->encntr_type_cd not in (canceluponreview_var, nonpatientlabspecimen_var)
	and parser(fin_sql)
	
join d2

head report
	cnt = size(finaldata->qual, 5)
	
detail
	cnt = cnt + 1
	
	call alterlist(finaldata->qual, cnt)
	
	finaldata->cnt								= cnt
	finaldata->qual[cnt].location 				= data2->qual[d.seq]->organization_name
	finaldata->qual[cnt].physician				= data2->qual[d.seq]->order_qual[d2.seq]->orders_order_provider
	finaldata->qual[cnt].physician_position		= uar_get_code_display(
													data2->qual[d.seq]->order_qual[d2.seq]->orders_order_provider_position_cd
													)
	finaldata->qual[cnt].physician_starid		= data2->qual[d.seq]->order_qual[d2.seq]->orders_order_provider_star_id
	finaldata->qual[cnt].patient_name			= data2->qual[d.seq]->patient_name
	finaldata->qual[cnt].patient_type			= uar_get_code_display(data2->qual[d.seq]->encntr_type_cd)
	finaldata->qual[cnt].mrn					= data2->qual[d.seq]->mrn
	finaldata->qual[cnt].fin					= data2->qual[d.seq]->fin
	finaldata->qual[cnt].admit_date				= data2->qual[d.seq]->encntr_reg_dt_tm
	finaldata->qual[cnt].discharge_date			= data2->qual[d.seq]->encntr_disch_dt_tm
	finaldata->qual[cnt].deficiency				= data2->qual[d.seq]->order_qual[d2.seq]->deficiency_name
	finaldata->qual[cnt].status					= data2->qual[d.seq]->order_qual[d2.seq]->status
	finaldata->qual[cnt].deficiency_age_days	= data2->qual[d.seq]->order_qual[d2.seq]->orders_order_age / 24
	finaldata->qual[cnt].deficiency_age_hours	= data2->qual[d.seq]->order_qual[d2.seq]->orders_order_age
	
	finaldata->qual[cnt].order_notif_id			= 
		data2->qual[d.seq]->order_qual[d2.seq]->order_notif_order_notification_id
		
	finaldata->qual[cnt].order_entry_date		= 
		data2->qual[d.seq]->order_qual[d2.seq]->orders_order_action_dt_tm
				
	finaldata->qual[cnt].order_prsnl			= data2->qual[d.seq]->order_qual[d2.seq]->orders_order_provider
	
	finaldata->qual[cnt].order_prsnl_position	= uar_get_code_display(
													data2->qual[d.seq]->order_qual[d2.seq]->orders_order_provider_position_cd
													)
					
	finaldata->qual[cnt].physician_person_id	= data2->qual[d.seq]->order_qual[d2.seq]->orders_order_provider_id
	finaldata->qual[cnt].event_id				= 0.0
	finaldata->qual[cnt].scanning_personnel		= ""
	finaldata->qual[cnt].refusing_physician		= ""
	finaldata->qual[cnt].refusing_reason		= ""
	
	finaldata->qual[cnt].communication_type		= 
		data2->qual[d.seq]->order_qual[d2.seq].orders_latest_communication_type
	
	finaldata->qual[cnt].powerplan_name			= 
		data2->qual[d.seq]->order_qual[d2.seq].orders_pathway_description

with nocounter, time = 60

;call echorecord(finaldata)
;
;go to exitscript
 
 
/**************************************************************/ 
; select data
select into value($OUTDEV)
	location				= trim(finaldata->qual[d.seq]->location, 3)
	, physician				= trim(finaldata->qual[d.seq]->physician, 3)
	, physician_position	= trim(finaldata->qual[d.seq]->physician_position, 3)
	, physician_starid		= trim(finaldata->qual[d.seq]->physician_starid, 3)
	, patient_name			= trim(finaldata->qual[d.seq]->patient_name, 3)
	, patient_type			= trim(finaldata->qual[d.seq]->patient_type, 3)
	, mrn					= trim(finaldata->qual[d.seq]->mrn, 3)
	, fin					= trim(finaldata->qual[d.seq]->fin, 3)
	, admit_date			= format(finaldata->qual[d.seq]->admit_date, "mm/dd/yyyy hh:mm;;q")
	, discharge_date		= format(finaldata->qual[d.seq]->discharge_date, "mm/dd/yyyy hh:mm;;q")
	, deficiency			= trim(finaldata->qual[d.seq]->deficiency, 3)
	, status				= trim(finaldata->qual[d.seq]->status, 3)
	, deficiency_age_days	= finaldata->qual[d.seq]->deficiency_age_days
	, deficiency_age_hours	= finaldata->qual[d.seq]->deficiency_age_hours		
	, order_notif_id		= trim(cnvtstring(finaldata->qual[d.seq]->order_notif_id), 3)		
	, order_entry_date		= format(finaldata->qual[d.seq]->order_entry_date, "mm/dd/yyyy hh:mm;;q")				
	, order_prsnl			= trim(finaldata->qual[d.seq]->order_prsnl, 3)
	, order_prsnl_position	= trim(finaldata->qual[d.seq]->order_prsnl_position, 3)		
	, physician_person_id	= trim(cnvtstring(finaldata->qual[d.seq]->physician_person_id), 3)
	, event_id				= trim(cnvtstring(finaldata->qual[d.seq]->event_id), 3)
	, scanning_personnel	= trim(finaldata->qual[d.seq]->scanning_personnel, 3)
	, refusing_physician	= trim(finaldata->qual[d.seq]->refusing_physician, 3)
	, refusing_reason		= trim(finaldata->qual[d.seq]->refusing_reason, 3)
	, communication_type	= trim(finaldata->qual[d.seq]->communication_type, 3)
	, powerplan_name		= trim(finaldata->qual[d.seq]->powerplan_name, 3)
	, total_vt_orders		= finaldata->cnt
	, total_all_orders		= finaldata->cnt_all_orders
	, percent_vt_orders		= ((finaldata->cnt * 1.0) / (finaldata->cnt_all_orders * 1.0) * 100)
	
from
	(dummyt d with seq = value(size(finaldata->qual, 5)))
     
plan d

order by
	location
	, physician
	, patient_name
	, fin

with nocounter, separator = " ", format, time = 60

 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

#exitscript

end go
 
