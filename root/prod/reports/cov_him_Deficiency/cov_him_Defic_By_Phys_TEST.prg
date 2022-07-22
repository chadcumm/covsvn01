/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		02/09/2021
	Solution:			Revenue Cycle - HIM
	Source file name:	cov_him_Defic_By_Phys.prg
	Object name:		cov_him_Defic_By_Phys
	Request #:			9273, 11509
 
	Program purpose:	Lists deficiency data for physicians.
 
	Executing from:		CCL
 
 	Special Notes:		Provides option to export data.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	11/12/2021	Todd A. Blanchard		Added Peninsula Behavioral Health and
										Covenant Health Diagnostics West.
 
******************************************************************************/
 
drop program cov_him_Defic_By_Phys_TEST:dba go
create program cov_him_Defic_By_Phys_TEST:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility(ies)" = 0
	, "Output To File" = 0                   ;* Output to file 

with OUTDEV, ORGANIZATIONS, OUTPUT_FILE
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare canceluponreview_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "CANCELUPONREVIEW"))
declare nonpatientlabspecimen_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "NONPATIENTLABSPECIMEN"))

declare file_var					= vc with constant("defic_by_phy.csv")
 
declare temppath_var				= vc with constant(build("cer_temp:", file_var))
declare temppath2_var				= vc with constant(build("$cer_temp/", file_var))

declare filepath_var				= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
															 	 "_cust/to_client_site/RevenueCycle/HIM/", file_var))
															 
declare output_var					= vc with noconstant("")
 
declare cmd							= vc with noconstant("")
declare len							= i4 with noconstant(0)
declare stat						= i4 with noconstant(0)
	
 
; define output value
if (validate(request->batch_selection) = 1 or $OUTPUT_FILE = 1)
	set output_var = value(temppath_var)
else
	set output_var = value($OUTDEV)
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
		2 encounter_type = c40
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
execute cov_mak_defic_by_phys_driver_2 $OUTDEV, $ORGANIZATIONS, 0.0, 0.0, "", "", 0

;call echorecord(data)

;go to exitscript

 
/**************************************************************/ 
; select final deficiency data
select into "nl:"
from
	(dummyt d with seq = value(size(data->qual, 5)))
	, (dummyt ddefic with seq = value(data->max_defic_qual_count))
     
plan d

join ddefic 
where 
	ddefic.seq <= size(data->qual[d.seq].defic_qual, 5)
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
	finaldata->qual[cnt].encounter_type			= uar_get_code_display(data->qual[d.seq]->encntr_encntr_type_cd)
	finaldata->qual[cnt].mrn					= data->qual[d.seq]->mrn
	finaldata->qual[cnt].fin					= data->qual[d.seq]->fin
	finaldata->qual[cnt].admit_date				= data->qual[d.seq]->encntr_reg_dt_tm
	finaldata->qual[cnt].discharge_date			= data->qual[d.seq]->disch_dt_tm
	finaldata->qual[cnt].deficiency				= data->qual[d.seq]->defic_qual[ddefic.seq]->deficiency_name
	finaldata->qual[cnt].status					= data->qual[d.seq]->defic_qual[ddefic.seq]->status
	finaldata->qual[cnt].deficiency_age_days	= data->qual[d.seq]->defic_qual[ddefic.seq]->defic_age / 24
	finaldata->qual[cnt].deficiency_age_hours	= data->qual[d.seq]->defic_qual[ddefic.seq]->defic_age
	
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

call echorecord(finaldata)

;go to exitscript
 
 
/**************************************************************/ 
; select data
if (validate(request->batch_selection) = 1 or $OUTPUT_FILE = 1)
	set modify filestream
endif

select if (validate(request->batch_selection) = 1 or $OUTPUT_FILE = 1)
	with nocounter, expand = 1, pcformat (^"^, ^,^, 1), format = stream, format, time = 600
else
	with nocounter, expand = 1, separator = " ", format, time = 600
endif

into value(output_var)
	location				= trim(finaldata->qual[d.seq]->location, 3)
	, physician				= trim(finaldata->qual[d.seq]->physician, 3)
	, physician_position	= trim(finaldata->qual[d.seq]->physician_position, 3)
	, physician_starid		= trim(finaldata->qual[d.seq]->physician_starid, 3)
	, patient_name			= trim(finaldata->qual[d.seq]->patient_name, 3)
	, mrn					= trim(finaldata->qual[d.seq]->mrn, 3)
	, fin					= trim(finaldata->qual[d.seq]->fin, 3)
	, discharge_date		= format(finaldata->qual[d.seq]->discharge_date, "mm/dd/yyyy hh:mm;;q")
	, deficiency			= trim(finaldata->qual[d.seq]->deficiency, 3)
	, status				= trim(finaldata->qual[d.seq]->status, 3)
	, deficiency_age_days	= finaldata->qual[d.seq]->deficiency_age_days
	, deficiency_age_hours	= finaldata->qual[d.seq]->deficiency_age_hours	
	, encounter_type		= trim(finaldata->qual[d.seq]->encounter_type, 3)	
	, order_notif_id		= trim(cnvtstring(finaldata->qual[d.seq]->order_notif_id), 3)
	, physician_person_id	= trim(cnvtstring(finaldata->qual[d.seq]->physician_person_id), 3)
	, event_id				= trim(cnvtstring(finaldata->qual[d.seq]->event_id), 3)
	, scanning_personnel	= trim(finaldata->qual[d.seq]->scanning_personnel, 3)
	, refusing_physician	= trim(finaldata->qual[d.seq]->refusing_physician, 3)
	, refusing_reason		= trim(finaldata->qual[d.seq]->refusing_reason, 3)
	, communication_type	= trim(finaldata->qual[d.seq]->communication_type, 3)
	, powerplan_name		= trim(finaldata->qual[d.seq]->powerplan_name, 3)
	
from
	(dummyt d with seq = value(size(finaldata->qual, 5)))
     
plan d

order by
	location
	, physician
	, patient_name
	, fin

with nocounter

 
; copy file to AStream
if (validate(request->batch_selection) = 1 or $OUTPUT_FILE = 1)
	set cmd = build2("cp ", temppath2_var, " ", filepath_var)
	set len = size(trim(cmd))
 
	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
endif

 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

#exitscript

end go
 
