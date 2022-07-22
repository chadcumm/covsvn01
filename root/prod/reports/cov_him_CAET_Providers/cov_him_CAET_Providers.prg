/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		10/02/2020
	Solution:			Revenue Cycle - HIM
	Source file name:	cov_him_CAET_Providers.prg
	Object name:		cov_him_CAET_Providers
	Request #:			8330
 
	Program purpose:	Lists data for CAET provider deficiencies.
 
	Executing from:		CCL
 
 	Special Notes:		
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program cov_him_CAET_Providers:dba go
create program cov_him_CAET_Providers:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Physician(s)" = VALUE(0.0) 

with OUTDEV, PHYSICIANS
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare inpatient_var 				= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "INPATIENT"))
declare outpatient_var 				= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "OUTPATIENT"))
declare observation_var 			= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "OBSERVATION"))
declare outpatientinabed_var 		= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "OUTPATIENTINABED"))

declare op_physician_var	= vc with noconstant(" ")


/**************************************************************
; DVDev Start Coding
**************************************************************/

free record finaldata
record finaldata (
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
		2 physician_person_id = f8
		2 event_id = f8
		2 scanning_personnel = c100
		2 refusing_physician = c100
		2 refusing_reason = c40
)

/**************************************************************/ 
; select deficiency data
execute cov_mak_defic_by_phys_driver_2 $OUTDEV, 0.0, $PHYSICIANS, 0.0, "", "", 3

;call echorecord(data)

;go to exitscript
 
 
/**************************************************************/ 
; select final deficiency data
select into "nl:"
from
	(dummyt d with seq = value(size(data->qual, 5)))
	, (dummyt ddefic with seq = value(data->max_defic_qual_count))
     
plan d
where
	data->qual[d.seq]->encntr_encntr_type_cd in (
		inpatient_var, 
		outpatient_var, 
		observation_var, 
		outpatientinabed_var
	)

join ddefic 
where 
	ddefic.seq <= size(data->qual[d.seq].defic_qual, 5)

head report
	cnt = 0
	
detail
	cnt = cnt + 1
	
	call alterlist(finaldata->qual, cnt)
	
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
;	finaldata->qual[cnt].deficiency_age_days	= ?
;	finaldata->qual[cnt].deficiency_age_hours	= ?
	
	finaldata->qual[cnt].physician_person_id	= data->qual[d.seq]->physician_person_id
	finaldata->qual[cnt].event_id				= data->qual[d.seq]->defic_qual[ddefic.seq].event_id
	finaldata->qual[cnt].scanning_personnel		= data->qual[d.seq]->defic_qual[ddefic.seq].scanning_prsnl
	finaldata->qual[cnt].refusing_physician		= data->qual[d.seq]->defic_qual[ddefic.seq].reject_prsnl
	finaldata->qual[cnt].refusing_reason		= data->qual[d.seq]->defic_qual[ddefic.seq].reject_reason

with nocounter, time = 60
 
 
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
;	, deficiency_age_days	= finaldata->qual[d.seq]->deficiency_age_days
;	, deficiency_age_hours	= finaldata->qual[d.seq]->deficiency_age_hours	
	, physician_person_id	= trim(cnvtstring(finaldata->qual[d.seq]->physician_person_id), 3)
	, event_id				= trim(cnvtstring(finaldata->qual[d.seq]->event_id), 3)
	
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
 
