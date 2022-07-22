/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		10/20/2020
	Solution:			Revenue Cycle - HIM
	Source file name:	cov_him_PresentTimely_OP.prg
	Object name:		cov_him_PresentTimely_OP
	Request #:			8331, 11977
 
	Program purpose:	Lists data for presence and timeliness of operative, 
						post-operative, and subsequent operative reports.
 
	Executing from:		CCL
 
 	Special Notes:		Report Type:
 							1 - IP/OB
 							2 - Day Surgery/OP Bed
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	07/07/2022	Todd A. Blanchard		Added logic for PACU II Discharge records.
										Added logic for PostOperative records.
										Adjusted compliance logic.
 
******************************************************************************/
 
drop program cov_him_PresentTimely_OP_TEST:dba go
create program cov_him_PresentTimely_OP_TEST:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility" = VALUE(0.0            )
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Report Type" = 1 

with OUTDEV, facility, start_datetime, end_datetime, report_type

 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare in_error_var				= f8 with constant(uar_get_code_by("MEANING", 8, "IN ERROR"))
declare inerrnomut_var				= f8 with constant(uar_get_code_by("MEANING", 8, "INERRNOMUT"))
declare inerrnoview_var				= f8 with constant(uar_get_code_by("MEANING", 8, "INERRNOVIEW"))
declare inerror_var					= f8 with constant(uar_get_code_by("MEANING", 8, "INERROR"))
declare anticipated_var				= f8 with constant(uar_get_code_by("MEANING", 8, "ANTICIPATED"))
declare sign_action_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 21, "SIGN"))
declare perform_action_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 21, "PERFORM"))
declare modify_action_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 21, "MODIFY"))
declare root_var					= f8 with constant(uar_get_code_by("MEANING", 24, "ROOT"))
declare child_var					= f8 with constant(uar_get_code_by("MEANING", 24, "CHILD"))
declare otg_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 25, "OTG"))
declare mdoc_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 53, "MDOC"))
declare doc_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 53, "DOC"))
declare daysurgery_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "DAYSURGERY")), protect
declare inpatient_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "INPATIENT")), protect
declare observation_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "OBSERVATION")), protect
declare outpatientinabed_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "OUTPATIENTINABED")), protect
declare opnotebrief_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "SURGERYOPNOTEBRIEF")), protect
declare out_room_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "SNCTMPATIENTOUTROOMTIME")), protect
declare pacu1_discharge_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "SNPACUICTMDISCHARGEFROMPACUI")), protect
declare pacu2_discharge_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "SNPACUIICTMDISCHARGEFROMPACU")), protect
declare covenant_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 73, "COVENANT")), protect
declare preoprecord_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 93, "PREOPERATIVERECORD"))
declare perioprecord_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 93, "PERIOPERATIVERECORD"))
declare intraoprecord_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 93, "INTRAOPERATIVERECORD"))
declare postoprecord_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 93, "POSTOPERATIVERECORD"))
declare surgicaldocs_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 93, "SURGICALDOCUMENTATION"))
declare provider_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 254571, "PROVIDER"))

declare op_facility_var				= vc with noconstant(fillstring(2, " "))
declare op_encntr_type_var			= vc with noconstant("1 = 1"), protect
declare num							= i4 with noconstant(0)
 
; define operator for $facility
if (substring(1, 1, reflect(parameter(parameter2($facility), 0))) = "L") ; multiple values selected
    set op_facility_var = "IN"
elseif (parameter(parameter2($facility), 1) = 0.0) ; any selected
    set op_facility_var = "!="
else ; single value selected
    set op_facility_var = "="
endif
 
; define encounter type filter
if ($report_type = 1)
	set op_encntr_type_var = "e.encntr_type_cd in (inpatient_var, observation_var)"
 
elseif ($report_type = 2)
	set op_encntr_type_var = "e.encntr_type_cd in (daysurgery_var, outpatientinabed_var)"

endif


/**************************************************************
; DVDev Start Coding
**************************************************************/

free record opeventdata
record opeventdata (
	1 cnt							= i4
	1 qual [*]
		2 event_cd					= f8
)

free record briefopeventdata
record briefopeventdata (
	1 cnt							= i4
	1 qual [*]
		2 event_cd					= f8
)

free record intraopeventdata
record intraopeventdata (
	1 cnt							= i4
	1 qual [*]
		2 event_cd					= f8
)

;001
free record postopeventdata
record postopeventdata (
	1 cnt							= i4
	1 qual [*]
		2 event_cd					= f8
)

free record opdata
record opdata (
	1 cnt							= i4
	1 qual [*]
		2 encntr_id					= f8
		2 encntr_type_cd			= f8
		2 med_service_cd			= f8
		2 person_id					= f8
		2 reg_dt_tm					= dq8
		
		2 surg_cnt						= i4
		2 surg [*]
			3 surg_case_id				= f8
			3 surg_case_nbr_formatted	= c100
			3 surg_start_dt_tm			= dq8
			3 surg_start_tz				= i4
			3 surg_stop_dt_tm			= dq8
			3 surg_stop_tz				= i4
			3 surg_start_dt				= dq8
			3 surg_stop_dt				= dq8
			3 surgeon_prsnl_id			= f8
			3 surgeon					= c100
			
			3 out_room_dt_tm			= dq8
			3 out_room_tz				= i4
			3 pacu1_end_dt_tm			= dq8
			3 pacu1_tz					= i4
			3 pacu2_end_dt_tm			= dq8
			3 pacu2_tz					= i4
			3 pacu_dt_tm				= dq8
			3 pacu_tz					= i4
		
		2 intraop_cnt					= i4
		2 intraop [*]
			3 event_id					= f8
			3 event_cd					= f8
			3 event_class_cd			= f8
			3 performed_dt_tm			= dq8
			3 performed_tz				= i4
			3 performed_prsnl_id		= f8
			3 performed_by				= c100
			3 result_status_cd			= f8
			3 result_dt_tm				= dq8
			3 result_tz					= i4
			3 entry_mode_cd				= f8
			3 storage_cd				= f8
			3 intraop_dt_tm				= dq8
			3 intraop_tz				= i4
			3 intraop_dt				= dq8
			3 surg_case_id				= f8
		
		;001
		2 postop_cnt					= i4
		2 postop [*]
			3 event_id					= f8
			3 event_cd					= f8
			3 event_class_cd			= f8
			3 performed_dt_tm			= dq8
			3 performed_tz				= i4
			3 performed_prsnl_id		= f8
			3 performed_by				= c100
			3 result_status_cd			= f8
			3 result_dt_tm				= dq8
			3 result_tz					= i4
			3 entry_mode_cd				= f8
			3 storage_cd				= f8
			3 postop_dt_tm				= dq8
			3 postop_tz					= i4
			3 postop_dt					= dq8
			3 surg_case_id				= f8
		
		2 op_cnt						= i4
		2 op [*]
			3 event_id					= f8
			3 event_cd					= f8
			3 event_class_cd			= f8
			3 performed_dt_tm			= dq8
			3 performed_tz				= i4
			3 performed_prsnl_id		= f8
			3 performed_by				= c100
			3 modified_dt_tm			= dq8
			3 modified_tz				= i4
			3 modified_prsnl_id			= f8
			3 modified_by				= c100
			3 result_status_cd			= f8
			3 result_dt_tm				= dq8
			3 result_tz					= i4
			3 entry_mode_cd				= f8
			3 storage_cd				= f8
			3 op_dt_tm					= dq8
			3 op_tz						= i4
			3 op_dt						= dq8
			3 surg_case_id				= f8
		
			; indicators for compliance logic
			3 is_scanned								= i2
			3 complete_within_four_hours				= i2
			3 modified_within_four_hours				= i2
			3 prior_to_surgery							= i2
			3 performed_prior_to_pacu					= i2
			3 modified_prior_to_pacu					= i2
			3 performed_prior_to_phaseii_postproc		= i2 ;001
			3 modified_prior_to_phaseii_postproc		= i2 ;001
			3 is_compliant								= i2
			3 is_tjc_compliant							= i2
		
		; indicators for compliance logic
		2 is_anticipated				= i2		
		2 has_intraop					= i2	
		2 has_postop					= i2 ;001
		2 has_op						= i2
		2 has_briefop					= i2
)

free record finaldata
record finaldata (
	1 cnt						= i4
	1 qual [*]
		2 patient_name			= c100
		2 fin					= c20
		2 encntr_id				= f8
		2 encntr_type_cd		= f8
		2 med_service_cd		= f8
		2 med_service_alias		= c20
		2 compliant_ind			= i2
		2 tjc_compliant_ind		= i2

		; surgical case							  	
		2 surg_case_nbr			= c100
		2 surgeon_prsnl_id		= f8
		2 surgeon				= c100
		2 surg_start_dt_tm		= dq8
		2 surg_start_tz			= i4
		2 surg_stop_dt_tm		= dq8
		2 surg_stop_tz			= i4
			
;		2 out_room_dt_tm		= dq8
;		2 out_room_tz			= i4
;		2 pacu1_end_dt_tm		= dq8
;		2 pacu1_tz				= i4
;		2 pacu2_end_dt_tm		= dq8
;		2 pacu2_tz				= i4
		2 pacu_dt_tm			= dq8
		2 pacu_tz				= i4

		; intraoperative
		2 intraop_event_cd					= f8
		2 intraop_performed_dt_tm			= dq8
		2 intraop_performed_tz				= i4
		2 intraop_performed_prsnl_id		= f8
		2 intraop_performed_by				= c100
		2 intraop_result_status_cd			= f8
		2 intraop_result_dt_tm				= dq8
		2 intraop_result_tz					= i4

		;001
		; postoperative
		2 postop_event_cd					= f8
		2 postop_performed_dt_tm			= dq8
		2 postop_performed_tz				= i4
		2 postop_performed_prsnl_id			= f8
		2 postop_performed_by				= c100
		2 postop_result_status_cd			= f8
		2 postop_result_dt_tm				= dq8
		2 postop_result_tz					= i4

		; operative
		2 op_event_cd						= f8
		2 op_performed_dt_tm				= dq8
		2 op_performed_tz					= i4
		2 op_performed_prsnl_id				= f8
		2 op_performed_by					= c100
		2 op_modified_dt_tm					= dq8
		2 op_modified_tz					= i4
		2 op_modified_prsnl_id				= f8
		2 op_modified_by					= c100
		2 op_result_status_cd				= f8
		2 op_result_dt_tm					= dq8
		2 op_result_tz						= i4
		
		; indicators
		2 op_complete_within_four_hours					= i2
		2 op_modified_within_four_hours					= i2
		2 op_prior_to_surgery							= i2
		2 op_performed_prior_to_pacu					= i2
		2 op_modified_prior_to_pacu						= i2
		2 op_performed_prior_to_phaseii_postproc		= i2 ;001
		2 op_modified_prior_to_phaseii_postproc			= i2 ;001
		
		; brief operative
		2 has_briefop						= i2
)


/**************************************************************/ 
; select operative notes event set data
select into "nl:"	
from 
	CODE_VALUE cv
	
	, (inner join CODE_VALUE_EXTENSION cve on cve.code_set = cv.code_set
		and cve.code_value = cv.code_value
		and cve.field_name = "event_set_cd")
		
	, (inner join V500_EVENT_SET_CODE vesc on vesc.event_set_cd = cve.field_value)
 
	, (inner join V500_EVENT_SET_EXPLODE vese on vese.event_set_cd = vesc.event_set_cd)
 
	, (inner join V500_EVENT_CODE vec on vec.event_cd = vese.event_cd)
	
where 
	cv.code_set = 100526 ; HIM Operative Reports Event Sets
	and cv.cdf_meaning = "PRTIME_OPRPT"
	and cv.active_ind = 1
	
order by
	cv.display_key	 
	 
; populate record structure
head report
	cnt = 0
 
detail
	cnt = cnt + 1
	
	call alterlist(opeventdata->qual, cnt)
 
	opeventdata->cnt					= cnt
	opeventdata->qual[cnt].event_cd		= vec.event_cd

with nocounter, time = 300

call echorecord(opeventdata)

;go to exitscript


/**************************************************************/ 
; select brief operative notes event set data
select into "nl:"	
from 
	V500_EVENT_SET_CANON vescn
		
	, (inner join V500_EVENT_SET_CODE vesc on vesc.event_set_cd = vescn.event_set_cd)
 
	, (inner join V500_EVENT_SET_EXPLODE vese on vese.event_set_cd = vesc.event_set_cd)
 
	, (inner join V500_EVENT_CODE vec on vec.event_cd = vese.event_cd
		and vec.event_cd_disp_key in ("*BRIEF*NOTE*", "*NOTE*BRIEF*"))
	
where 
	vescn.parent_event_set_cd in (surgicaldocs_var) 
	 
; populate record structure
head report
	cnt = 0
 
detail
	cnt = cnt + 1
	
	call alterlist(briefopeventdata->qual, cnt)
 
	briefopeventdata->cnt						= cnt
	briefopeventdata->qual[cnt].event_cd		= vec.event_cd

with nocounter, time = 300

call echorecord(briefopeventdata)

;go to exitscript


/**************************************************************/ 
; select intraoperative record event set data
select into "nl:"	
from 
	V500_EVENT_SET_EXPLODE vese
	
where 
	vese.event_set_cd = intraoprecord_var 
	 
; populate record structure
head report
	cnt = 0
 
detail
	cnt = cnt + 1
	
	call alterlist(intraopeventdata->qual, cnt)
 
	intraopeventdata->cnt						= cnt
	intraopeventdata->qual[cnt].event_cd		= vese.event_cd

with nocounter, time = 300

call echorecord(intraopeventdata)

;go to exitscript


/**************************************************************/ 
; select postoperative record event set data ;001
select into "nl:"	
from 
	V500_EVENT_SET_EXPLODE vese
	
where 
	vese.event_set_cd = postoprecord_var 
	 
; populate record structure
head report
	cnt = 0
 
detail
	cnt = cnt + 1
	
	call alterlist(postopeventdata->qual, cnt)
 
	postopeventdata->cnt					= cnt
	postopeventdata->qual[cnt].event_cd		= vese.event_cd

with nocounter, time = 300

call echorecord(postopeventdata)

;go to exitscript
 
 
/**************************************************************/ 
; select surgery data
select into "nl:"
	sc.surg_case_id	
	, sc.surg_case_nbr_formatted
	, sc.encntr_id
	, e.encntr_type_cd
	, e.med_service_cd
	, e.reg_dt_tm
	, sc.person_id
	, sc.surgeon_prsnl_id
	, per.name_full_formatted
	, surg_start_dt_tm		= min(sc.surg_start_dt_tm)
	, sc.surg_start_tz
	, surg_stop_dt_tm		= max(sc.surg_stop_dt_tm)
	, sc.surg_stop_tz
	, surg_start_dt			= cnvtdate(min(sc.surg_start_dt_tm))
	, surg_stop_dt			= cnvtdate(max(sc.surg_stop_dt_tm))
	, out_room_dt_tm		= ct1.case_time_dt_tm
	, out_room_tz			= ct1.case_time_tz
	, pacu1_end_dt_tm		= ct2.case_time_dt_tm
	, pacu1_tz				= ct2.case_time_tz
	, pacu2_end_dt_tm		= ct3.case_time_dt_tm ;001
	, pacu2_tz				= ct3.case_time_tz ;001	
	
from
	SURGICAL_CASE sc
	
	, (inner join ENCOUNTER e on e.encntr_id = sc.encntr_id
		and operator(e.organization_id, op_facility_var, $facility)
		and e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
		and parser(op_encntr_type_var)
		and e.active_ind = 1)
		
	, (inner join PERSON p on p.person_id = e.person_id
		and p.name_last_key not in ("ZZZ*")
		and p.active_ind = 1)
	
	, (left join PRSNL per on per.person_id = sc.surgeon_prsnl_id
;		and per.active_ind = 1
		)
	
	, (left join CASE_TIMES ct1 on ct1.surg_case_id = sc.surg_case_id
		and ct1.task_assay_cd in (
			select dta.task_assay_cd
			from DISCRETE_TASK_ASSAY dta
			where dta.event_cd = out_room_var
		))
	
	, (left join CASE_TIMES ct2 on ct2.surg_case_id = sc.surg_case_id
		and ct2.task_assay_cd in (
			select dta.task_assay_cd
			from DISCRETE_TASK_ASSAY dta
			where dta.event_cd = pacu1_discharge_var
		))
	
	;001
	, (left join CASE_TIMES ct3 on ct3.surg_case_id = sc.surg_case_id
		and ct3.task_assay_cd in (
			select dta.task_assay_cd
			from DISCRETE_TASK_ASSAY dta
			where dta.event_cd = pacu2_discharge_var
		))

where
	sc.surg_start_dt_tm > cnvtdatetime("01-JAN-1970 000000")
	and sc.active_ind = 1
	
group by
	sc.surg_case_id
	, sc.surg_case_nbr_formatted
	, sc.encntr_id
	, e.encntr_type_cd
	, e.med_service_cd
	, e.reg_dt_tm
	, sc.person_id
	, sc.surgeon_prsnl_id
	, per.name_full_formatted
	, sc.surg_start_tz
	, sc.surg_stop_tz
	, ct1.case_time_dt_tm
	, ct1.case_time_tz
	, ct2.case_time_dt_tm
	, ct2.case_time_tz
	, ct3.case_time_dt_tm ;001
	, ct3.case_time_tz ;001
	
order by
	sc.encntr_id
	, sc.surg_case_id
	
; populate record structure
head report
	cnt = 0
	
head sc.encntr_id
	scnt = 0
	
	cnt += 1
	
	call alterlist(opdata->qual, cnt)
	
	opdata->cnt 								= cnt
	opdata->qual[cnt].encntr_id					= sc.encntr_id
	opdata->qual[cnt].encntr_type_cd			= e.encntr_type_cd
	opdata->qual[cnt].med_service_cd			= e.med_service_cd
	opdata->qual[cnt].person_id					= sc.person_id
	opdata->qual[cnt].reg_dt_tm					= e.reg_dt_tm

detail
	scnt += 1
	
	call alterlist(opdata->qual[cnt].surg, scnt)
	
	opdata->qual[cnt].surg_cnt									= scnt
	opdata->qual[cnt].surg[scnt].surg_case_id					= sc.surg_case_id
	opdata->qual[cnt].surg[scnt].surg_case_nbr_formatted		= sc.surg_case_nbr_formatted
	opdata->qual[cnt].surg[scnt].surg_start_dt_tm				= surg_start_dt_tm
	opdata->qual[cnt].surg[scnt].surg_start_tz					= sc.surg_start_tz
	opdata->qual[cnt].surg[scnt].surg_stop_dt_tm				= surg_stop_dt_tm
	opdata->qual[cnt].surg[scnt].surg_stop_tz					= sc.surg_stop_tz
	opdata->qual[cnt].surg[scnt].surg_start_dt					= surg_start_dt
	opdata->qual[cnt].surg[scnt].surg_stop_dt					= surg_stop_dt
	opdata->qual[cnt].surg[scnt].surgeon_prsnl_id				= sc.surgeon_prsnl_id
	opdata->qual[cnt].surg[scnt].surgeon						= per.name_full_formatted
	
	opdata->qual[cnt].surg[scnt].out_room_dt_tm					= ct1.case_time_dt_tm
	opdata->qual[cnt].surg[scnt].out_room_tz					= ct1.case_time_tz
	opdata->qual[cnt].surg[scnt].pacu1_end_dt_tm				= ct2.case_time_dt_tm
	opdata->qual[cnt].surg[scnt].pacu1_tz						= ct2.case_time_tz
	opdata->qual[cnt].surg[scnt].pacu2_end_dt_tm				= ct3.case_time_dt_tm ;001
	opdata->qual[cnt].surg[scnt].pacu2_tz						= ct3.case_time_tz ;001

	if (opdata->qual[cnt].surg[scnt].pacu1_end_dt_tm > 0.0)
		opdata->qual[cnt].surg[scnt].pacu_dt_tm		= opdata->qual[cnt].surg[scnt].pacu1_end_dt_tm
		opdata->qual[cnt].surg[scnt].pacu_tz		= opdata->qual[cnt].surg[scnt].pacu1_tz
	
	;001
	elseif (opdata->qual[cnt].surg[scnt].pacu2_end_dt_tm > 0.0)
		opdata->qual[cnt].surg[scnt].pacu_dt_tm		= opdata->qual[cnt].surg[scnt].pacu2_end_dt_tm
		opdata->qual[cnt].surg[scnt].pacu_tz		= opdata->qual[cnt].surg[scnt].pacu2_tz

	;001		
;	else
;		opdata->qual[cnt].surg[scnt].pacu_dt_tm		= opdata->qual[cnt].surg[scnt].out_room_dt_tm
;		opdata->qual[cnt].surg[scnt].pacu_tz		= opdata->qual[cnt].surg[scnt].out_room_tz
		
	endif
	
with nocounter, expand = 1, time = 300

;call echorecord(opdata)

if (opdata->cnt = 0)
	go to exitscript
endif
 
 
/**************************************************************/ 
; select intraoperative data
select into "nl:"
from
	CLINICAL_EVENT ce
 
	, (inner join CE_EVENT_PRSNL cep on cep.event_id = ce.event_id
		and cep.action_type_cd = perform_action_var
		and cep.valid_until_dt_tm >= cnvtdatetime(curdate, curtime))
	
	, (left join CE_BLOB_RESULT cbr on cbr.event_id = ce.event_id
		and cbr.storage_cd = otg_var
		and cbr.valid_until_dt_tm > cnvtdatetime(curdate, curtime))
		
	, (inner join PRSNL per on per.person_id = ce.performed_prsnl_id
;		and per.active_ind = 1
		)
		
	, (left join PERIOPERATIVE_DOCUMENT pd on pd.periop_doc_id = 
		substring(1, findstring("SN", ce.reference_nbr) - 1, ce.reference_nbr))
		
	, (dummyt d1 with seq = value(opdata->cnt))
	
plan d1

join ce
join cep
join cbr
join per
join pd

where
	ce.encntr_id = opdata->qual[d1.seq].encntr_id
	and expand(num, 1, intraopeventdata->cnt, ce.event_cd, intraopeventdata->qual[num].event_cd)
	and ce.event_class_cd = doc_var
	and ce.event_reltn_cd = child_var
	;and ce.performed_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and ce.result_status_cd not in (in_error_var, inerrnomut_var, inerrnoview_var, inerror_var)
	and ce.valid_until_dt_tm > cnvtdatetime(curdate, curtime)
	
order by
	ce.encntr_id
	, ce.event_id
	 	 
; populate record structure
head ce.encntr_id
	icnt = 0

detail
	icnt += 1
	
	call alterlist(opdata->qual[d1.seq].intraop, icnt)
	
	opdata->qual[d1.seq].intraop_cnt							= icnt
	opdata->qual[d1.seq].intraop[icnt].event_id					= ce.event_id
	opdata->qual[d1.seq].intraop[icnt].event_cd					= ce.event_cd
	opdata->qual[d1.seq].intraop[icnt].event_class_cd			= ce.event_class_cd
	opdata->qual[d1.seq].intraop[icnt].performed_dt_tm			= ce.performed_dt_tm
	opdata->qual[d1.seq].intraop[icnt].performed_tz				= ce.performed_tz
	opdata->qual[d1.seq].intraop[icnt].performed_prsnl_id		= ce.performed_prsnl_id
	opdata->qual[d1.seq].intraop[icnt].performed_by				= per.name_full_formatted
	opdata->qual[d1.seq].intraop[icnt].result_status_cd			= ce.result_status_cd
	opdata->qual[d1.seq].intraop[icnt].result_dt_tm				= ce.event_end_dt_tm
	opdata->qual[d1.seq].intraop[icnt].result_tz				= ce.event_end_tz
	opdata->qual[d1.seq].intraop[icnt].entry_mode_cd			= ce.entry_mode_cd
	opdata->qual[d1.seq].intraop[icnt].storage_cd				= cbr.storage_cd
	opdata->qual[d1.seq].intraop[icnt].intraop_dt_tm 			= ce.performed_dt_tm
	opdata->qual[d1.seq].intraop[icnt].intraop_tz	 			= ce.performed_tz
	opdata->qual[d1.seq].intraop[icnt].intraop_dt	 			= cnvtdate(ce.performed_dt_tm)
	opdata->qual[d1.seq].intraop[icnt].surg_case_id				= pd.surg_case_id	
	
foot ce.encntr_id
	opdata->qual[d1.seq].has_intraop = evaluate(icnt, 0, 0, 1)
	
with nocounter, time = 300

;call echorecord(opdata)
 
 
/**************************************************************/ 
; select postoperative data
select into "nl:"
from
	CLINICAL_EVENT ce
 
	, (inner join CE_EVENT_PRSNL cep on cep.event_id = ce.event_id
		and cep.action_type_cd = perform_action_var
		and cep.valid_until_dt_tm >= cnvtdatetime(curdate, curtime))
	
	, (left join CE_BLOB_RESULT cbr on cbr.event_id = ce.event_id
		and cbr.storage_cd = otg_var
		and cbr.valid_until_dt_tm > cnvtdatetime(curdate, curtime))
		
	, (inner join PRSNL per on per.person_id = ce.performed_prsnl_id
;		and per.active_ind = 1
		)
		
	, (left join PERIOPERATIVE_DOCUMENT pd on pd.periop_doc_id = 
		substring(1, findstring("SN", ce.reference_nbr) - 1, ce.reference_nbr))
		
	, (dummyt d1 with seq = value(opdata->cnt))
	
plan d1

join ce
join cep
join cbr
join per
join pd

where
	ce.encntr_id = opdata->qual[d1.seq].encntr_id
	and expand(num, 1, postopeventdata->cnt, ce.event_cd, postopeventdata->qual[num].event_cd)
	and ce.event_class_cd = doc_var
	and ce.event_reltn_cd = child_var
	;and ce.performed_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and ce.result_status_cd not in (in_error_var, inerrnomut_var, inerrnoview_var, inerror_var)
	and ce.valid_until_dt_tm > cnvtdatetime(curdate, curtime)
	
order by
	ce.encntr_id
	, ce.event_id
	 	 
; populate record structure
head ce.encntr_id
	pcnt = 0

detail
	pcnt += 1
	
	call alterlist(opdata->qual[d1.seq].postop, pcnt)
	
	opdata->qual[d1.seq].postop_cnt								= pcnt
	opdata->qual[d1.seq].postop[pcnt].event_id					= ce.event_id
	opdata->qual[d1.seq].postop[pcnt].event_cd					= ce.event_cd
	opdata->qual[d1.seq].postop[pcnt].event_class_cd			= ce.event_class_cd
	opdata->qual[d1.seq].postop[pcnt].performed_dt_tm			= ce.performed_dt_tm
	opdata->qual[d1.seq].postop[pcnt].performed_tz				= ce.performed_tz
	opdata->qual[d1.seq].postop[pcnt].performed_prsnl_id		= ce.performed_prsnl_id
	opdata->qual[d1.seq].postop[pcnt].performed_by				= per.name_full_formatted
	opdata->qual[d1.seq].postop[pcnt].result_status_cd			= ce.result_status_cd
	opdata->qual[d1.seq].postop[pcnt].result_dt_tm				= ce.event_end_dt_tm
	opdata->qual[d1.seq].postop[pcnt].result_tz					= ce.event_end_tz
	opdata->qual[d1.seq].postop[pcnt].entry_mode_cd				= ce.entry_mode_cd
	opdata->qual[d1.seq].postop[pcnt].storage_cd				= cbr.storage_cd
	opdata->qual[d1.seq].postop[pcnt].postop_dt_tm 				= ce.performed_dt_tm
	opdata->qual[d1.seq].postop[pcnt].postop_tz	 				= ce.performed_tz
	opdata->qual[d1.seq].postop[pcnt].postop_dt	 				= cnvtdate(ce.performed_dt_tm)
	opdata->qual[d1.seq].postop[pcnt].surg_case_id				= pd.surg_case_id	
	
foot ce.encntr_id
	opdata->qual[d1.seq].has_postop = evaluate(pcnt, 0, 0, 1)
	
with nocounter, time = 300

;call echorecord(opdata)
 
 
/**************************************************************/ 
; select operative data
select distinct into "nl:"
from
	CLINICAL_EVENT ce
 
	, (inner join CE_EVENT_PRSNL cep on cep.event_id = ce.event_id
		and cep.action_type_cd = perform_action_var
		and cep.valid_until_dt_tm >= cnvtdatetime(curdate, curtime))
 
	, (left join CE_EVENT_PRSNL cep2 on cep2.event_id = ce.event_id
		and cep2.action_type_cd = modify_action_var
		and cep2.valid_until_dt_tm >= cnvtdatetime(curdate, curtime))
		
	, (inner join CLINICAL_EVENT ce2 on ce2.encntr_id = ce.encntr_id
		and ce2.parent_event_id = ce.parent_event_id
		and expand(num, 1, opeventdata->cnt, ce2.event_cd, opeventdata->qual[num].event_cd)
;		and ce2.event_class_cd = doc_var
		and ce2.event_reltn_cd = child_var
		and ce2.result_status_cd not in (in_error_var, inerrnomut_var, inerrnoview_var, inerror_var)
		and ce2.valid_until_dt_tm > cnvtdatetime(curdate, curtime))
	
	, (left join CE_BLOB_RESULT cbr on cbr.event_id = ce2.event_id
		and cbr.storage_cd = otg_var
		and cbr.valid_until_dt_tm > cnvtdatetime(curdate, curtime))
		
	, (inner join PRSNL per on per.person_id = ce.performed_prsnl_id
;		and per.active_ind = 1
		)
		
	, (left join PRSNL per2 on per2.person_id = cep2.action_prsnl_id
;		and per2.active_ind = 1
		)
  
	, (dummyt d1 with seq = value(opdata->cnt))
	
plan d1

join ce
join cep
join cep2
join ce2
join cbr
join per
join per2

where
	ce.encntr_id = opdata->qual[d1.seq].encntr_id
	and expand(num, 1, opeventdata->cnt, ce.event_cd, opeventdata->qual[num].event_cd)
;	and ce.event_class_cd = mdoc_var
	and ce.event_reltn_cd = root_var
	and ce.result_status_cd not in (in_error_var, inerrnomut_var, inerrnoview_var, inerror_var)
	and ce.valid_until_dt_tm > cnvtdatetime(curdate, curtime)
	
order by
	ce.encntr_id
	, ce.performed_dt_tm
	, ce.event_end_dt_tm
	, cep2.action_dt_tm
	 	 
; populate record structure	
head ce.encntr_id
	ocnt = 0
	
detail
	ocnt += 1
	
	call alterlist(opdata->qual[d1.seq].op, ocnt)
	
	opdata->qual[d1.seq].op_cnt								= ocnt
	opdata->qual[d1.seq].op[ocnt].event_id					= ce.event_id
	opdata->qual[d1.seq].op[ocnt].event_cd					= ce.event_cd
	opdata->qual[d1.seq].op[ocnt].event_class_cd			= ce.event_class_cd
	opdata->qual[d1.seq].op[ocnt].performed_dt_tm			= ce.performed_dt_tm
	opdata->qual[d1.seq].op[ocnt].performed_tz				= ce.performed_tz
	opdata->qual[d1.seq].op[ocnt].performed_prsnl_id		= ce.performed_prsnl_id
	opdata->qual[d1.seq].op[ocnt].performed_by				= per.name_full_formatted
	opdata->qual[d1.seq].op[ocnt].modified_dt_tm			= cep2.action_dt_tm
	opdata->qual[d1.seq].op[ocnt].modified_tz				= cep2.action_tz
	opdata->qual[d1.seq].op[ocnt].modified_prsnl_id			= cep2.action_prsnl_id
	opdata->qual[d1.seq].op[ocnt].modified_by				= per2.name_full_formatted
	opdata->qual[d1.seq].op[ocnt].result_status_cd			= ce.result_status_cd
	opdata->qual[d1.seq].op[ocnt].result_dt_tm				= ce.event_end_dt_tm
	opdata->qual[d1.seq].op[ocnt].result_tz					= ce.event_end_tz
	opdata->qual[d1.seq].op[ocnt].entry_mode_cd				= ce2.entry_mode_cd
	opdata->qual[d1.seq].op[ocnt].storage_cd				= cbr.storage_cd
	
	; indicators
	if (opdata->qual[d1.seq].op[ocnt].result_status_cd = anticipated_var)
		opdata->qual[d1.seq].is_anticipated = 1
	endif
	
	opdata->qual[d1.seq].op[ocnt].is_scanned = evaluate(opdata->qual[d1.seq].op[ocnt].storage_cd, 0.0, 0, 1)
	
	if (opdata->qual[d1.seq].op[ocnt].is_scanned)
		opdata->qual[d1.seq].op[ocnt].op_dt_tm	= ce.event_end_dt_tm
		opdata->qual[d1.seq].op[ocnt].op_tz		= ce.event_end_tz
		opdata->qual[d1.seq].op[ocnt].op_dt		= cnvtdate(ce.event_end_dt_tm)
	else
		opdata->qual[d1.seq].op[ocnt].op_dt_tm	= ce.performed_dt_tm
		opdata->qual[d1.seq].op[ocnt].op_tz		= ce.performed_tz
		opdata->qual[d1.seq].op[ocnt].op_dt		= cnvtdate(ce.performed_dt_tm)
	endif
	
foot ce.encntr_id
	opdata->qual[d1.seq].has_op = evaluate(ocnt, 0, 0, 1)

with nocounter, expand = 1, time = 300

;call echorecord(opdata)
 
 
/**************************************************************/ 
; select brief operative data
select distinct into "nl:"
from
	CLINICAL_EVENT ce
 
	, (inner join CE_EVENT_PRSNL cep on cep.event_id = ce.event_id
		and cep.action_type_cd = perform_action_var
		and cep.valid_until_dt_tm >= cnvtdatetime(curdate, curtime))
		
	, (inner join CLINICAL_EVENT ce2 on ce2.encntr_id = ce.encntr_id
		and ce2.parent_event_id = ce.parent_event_id
		and expand(num, 1, briefopeventdata->cnt, ce2.event_cd, briefopeventdata->qual[num].event_cd)
;		and ce2.event_class_cd = doc_var
		and ce2.event_reltn_cd = child_var
		and ce2.result_status_cd not in (in_error_var, inerrnomut_var, inerrnoview_var, inerror_var)
		and ce2.valid_until_dt_tm > cnvtdatetime(curdate, curtime))
	
	, (left join CE_BLOB_RESULT cbr on cbr.event_id = ce2.event_id
		and cbr.storage_cd = otg_var
		and cbr.valid_until_dt_tm > cnvtdatetime(curdate, curtime))
  
	, (dummyt d1 with seq = value(opdata->cnt))
	
plan d1

join ce
join cep
join ce2
join cbr

where
	ce.encntr_id = opdata->qual[d1.seq].encntr_id
	and expand(num, 1, briefopeventdata->cnt, ce.event_cd, briefopeventdata->qual[num].event_cd)
;	and ce.event_class_cd = mdoc_var
	and ce.event_reltn_cd = root_var
	and ce.result_status_cd not in (in_error_var, inerrnomut_var, inerrnoview_var, inerror_var)
	and ce.valid_until_dt_tm > cnvtdatetime(curdate, curtime)
	 	 
; populate record structure	
head ce.encntr_id
	ocnt = 0
	
detail
	ocnt += 1
	
foot ce.encntr_id
	opdata->qual[d1.seq].has_briefop = evaluate(ocnt, 0, 0, 1)

with nocounter, time = 300

;call echorecord(opdata)
 
 
/**************************************************************/ 
; select indicator data
select into "nl:"
from
	(dummyt d1 with seq = value(opdata->cnt))
	, (dummyt d2 with seq = 1)
	, (dummyt d3 with seq = 1)
	, (dummyt d4 with seq = 1)
	, (dummyt d5 with seq = 1) ;001
	     
plan d1
where
	maxrec(d2, opdata->qual[d1.seq].surg_cnt)
	and maxrec(d3, opdata->qual[d1.seq].intraop_cnt)
	and maxrec(d4, opdata->qual[d1.seq].postop_cnt) ;001
	and maxrec(d5, opdata->qual[d1.seq].op_cnt) ;001

join d2

join d3
where
	opdata->qual[d1.seq].intraop[d3.seq].surg_case_id = opdata->qual[d1.seq].surg[d2.seq].surg_case_id

;001
join d4
where
	opdata->qual[d1.seq].postop[d4.seq].surg_case_id = opdata->qual[d1.seq].surg[d2.seq].surg_case_id

;001
join d5

; populate record structure
detail
	if (not opdata->qual[d1.seq].is_anticipated)
;		if (opdata->qual[d1.seq].has_intraop)
			if (opdata->qual[d1.seq].has_op)
				if (not opdata->qual[d1.seq].op[d5.seq].is_scanned)	
					if (opdata->qual[d1.seq].surg[d2.seq].surgeon_prsnl_id = opdata->qual[d1.seq].op[d5.seq].performed_prsnl_id)
						; for compliance
						if (opdata->qual[d1.seq].op[d5.seq].op_dt_tm < opdata->qual[d1.seq].surg[d2.seq].surg_start_dt_tm)
							opdata->qual[d1.seq].op[d5.seq].prior_to_surgery = 1
						endif
						
						if ((opdata->qual[d1.seq].op[d5.seq].op_dt_tm >= opdata->qual[d1.seq].surg[d2.seq].surg_start_dt_tm) and
							(datetimediff(opdata->qual[d1.seq].op[d5.seq].op_dt_tm, 
										  opdata->qual[d1.seq].surg[d2.seq].surg_stop_dt_tm, 3) <= 4))
										  
							opdata->qual[d1.seq].op[d5.seq].complete_within_four_hours = 1
						endif						
						
						if (opdata->qual[d1.seq].op[d5.seq].op_dt_tm < opdata->qual[d1.seq].surg[d2.seq].pacu_dt_tm)							
							opdata->qual[d1.seq].op[d5.seq].performed_prior_to_pacu = 1
						endif					
						
						;001
						if (opdata->qual[d1.seq].has_postop)
							if (opdata->qual[d1.seq].op[d5.seq].op_dt_tm < opdata->qual[d1.seq].postop[d4.seq].performed_dt_tm)							
								opdata->qual[d1.seq].op[d5.seq].performed_prior_to_phaseii_postproc = 1
							endif
						endif
	
						if (opdata->qual[d1.seq].op[d5.seq].modified_dt_tm > 0)
							if ((opdata->qual[d1.seq].op[d5.seq].modified_dt_tm >= opdata->qual[d1.seq].surg[d2.seq].surg_start_dt_tm) and
								(datetimediff(opdata->qual[d1.seq].op[d5.seq].modified_dt_tm, 
											  opdata->qual[d1.seq].surg[d2.seq].surg_stop_dt_tm, 3) <= 4))
											 
								opdata->qual[d1.seq].op[d5.seq].modified_within_four_hours = 1
							endif
							
							if (opdata->qual[d1.seq].op[d5.seq].modified_dt_tm < opdata->qual[d1.seq].surg[d2.seq].pacu_dt_tm)
								opdata->qual[d1.seq].op[d5.seq].modified_prior_to_pacu = 1
							endif
							
							;001
							if (opdata->qual[d1.seq].has_postop)
								if (opdata->qual[d1.seq].op[d5.seq].modified_dt_tm < opdata->qual[d1.seq].postop[d4.seq].performed_dt_tm)
									opdata->qual[d1.seq].op[d5.seq].modified_prior_to_phaseii_postproc = 1
								endif
							endif
						endif

						; for display
						if (opdata->qual[d1.seq].op[d5.seq].result_dt_tm >= opdata->qual[d1.seq].surg[d2.seq].surg_start_dt_tm)
							opdata->qual[d1.seq].op[d5.seq].surg_case_id = opdata->qual[d1.seq].surg[d2.seq].surg_case_id
						endif
					endif
	
					if ((opdata->qual[d1.seq].op[d5.seq].surg_case_id = 0.0) and (opdata->qual[d1.seq].surg_cnt = 1))
						opdata->qual[d1.seq].op[d5.seq].surg_case_id = opdata->qual[d1.seq].surg[d2.seq].surg_case_id
					endif
				
					if (opdata->qual[d1.seq].op[d5.seq].surg_case_id = opdata->qual[d1.seq].surg[d2.seq].surg_case_id)
						; indicators
						if ((opdata->qual[d1.seq].op[d5.seq].complete_within_four_hours) or 
							(opdata->qual[d1.seq].op[d5.seq].modified_within_four_hours))
							
							opdata->qual[d1.seq].op[d5.seq].is_compliant = 1
						endif

						;001
						if ((opdata->qual[d1.seq].op[d5.seq].performed_prior_to_pacu) or 
							(opdata->qual[d1.seq].op[d5.seq].modified_prior_to_pacu) or
							(opdata->qual[d1.seq].op[d5.seq].performed_prior_to_phaseii_postproc) or
							(opdata->qual[d1.seq].op[d5.seq].modified_prior_to_phaseii_postproc) or
							(opdata->qual[d1.seq].op[d5.seq].complete_within_four_hours) or 
							(opdata->qual[d1.seq].op[d5.seq].modified_within_four_hours))
							
							opdata->qual[d1.seq].op[d5.seq].is_tjc_compliant = 1
						endif
					endif
				endif
			endif
;		endif
	endif
	
with nocounter, outerjoin = d2, time = 300

call echorecord(opdata)
 
 
/**************************************************************/ 
; select final data
select into "nl:"	
from
	(dummyt d1 with seq = value(opdata->cnt))
	, (dummyt d2 with seq = 1)
	, (dummyt d3 with seq = 1)
	, (dummyt d4 with seq = 1)
	, (dummyt d5 with seq = 1) ;001
	, ENCNTR_ALIAS ea
	, CODE_VALUE_ALIAS cva
	, PERSON p
     
plan d1
where
	maxrec(d2, opdata->qual[d1.seq].surg_cnt)
	and maxrec(d3, opdata->qual[d1.seq].intraop_cnt)
	and maxrec(d4, opdata->qual[d1.seq].postop_cnt) ;001
	and maxrec(d5, opdata->qual[d1.seq].op_cnt) ;001

join ea
where
	ea.encntr_id = opdata->qual[d1.seq].encntr_id
	and ea.encntr_alias_type_cd = 1077.00 ; fin
	and ea.active_ind = 1

join cva
where
	cva.code_value = outerjoin(opdata->qual[d1.seq].med_service_cd)
	and cva.contributor_source_cd = outerjoin(covenant_var)

join p
where 
	p.person_id = opdata->qual[d1.seq].person_id
	and p.active_ind = 1

join d2

join d3
where
	opdata->qual[d1.seq].intraop[d3.seq].surg_case_id = opdata->qual[d1.seq].surg[d2.seq].surg_case_id

;001
join d4
where
	opdata->qual[d1.seq].postop[d4.seq].surg_case_id = opdata->qual[d1.seq].surg[d2.seq].surg_case_id

;001
join d5
where
	opdata->qual[d1.seq].op[d5.seq].is_scanned = 0
	and opdata->qual[d1.seq].op[d5.seq].surg_case_id = opdata->qual[d1.seq].surg[d2.seq].surg_case_id
	and opdata->qual[d1.seq].op[d5.seq].performed_prsnl_id = opdata->qual[d1.seq].surg[d2.seq].surgeon_prsnl_id
;	and opdata->qual[d1.seq].op[d5.seq].op_dt >= opdata->qual[d1.seq].surg[d2.seq].surg_stop_dt
;	and (
;		datetimediff(opdata->qual[d1.seq].op[d5.seq].op_dt_tm, opdata->qual[d1.seq].surg[d2.seq].surg_stop_dt_tm, 3) <= 24
;		and (
;			opdata->qual[d1.seq].op[d5.seq].complete_within_four_hours
;			or opdata->qual[d1.seq].op[d5.seq].modified_within_four_hours
;		)
;	)

; populate record structure
head report
	cnt = 0
	
detail
	cnt += 1
	
	call alterlist(finaldata->qual, cnt)
	
	finaldata->cnt								= cnt
	finaldata->qual[cnt].patient_name			= p.name_full_formatted
	finaldata->qual[cnt].fin					= ea.alias
	finaldata->qual[cnt].encntr_id				= opdata->qual[d1.seq].encntr_id
	finaldata->qual[cnt].encntr_type_cd			= opdata->qual[d1.seq].encntr_type_cd
	finaldata->qual[cnt].med_service_cd			= opdata->qual[d1.seq].med_service_cd
	finaldata->qual[cnt].med_service_alias		= cva.alias
	
	if (opdata->qual[d1.seq].surg[d2.seq].surg_case_id = opdata->qual[d1.seq].op[d5.seq].surg_case_id)
		finaldata->qual[cnt].compliant_ind			= opdata->qual[d1.seq].op[d5.seq].is_compliant
		finaldata->qual[cnt].tjc_compliant_ind		= opdata->qual[d1.seq].op[d5.seq].is_tjc_compliant
	endif

	; surgical case
	finaldata->qual[cnt].surg_case_nbr			= opdata->qual[d1.seq].surg[d2.seq].surg_case_nbr_formatted
	finaldata->qual[cnt].surgeon_prsnl_id		= opdata->qual[d1.seq].surg[d2.seq].surgeon_prsnl_id
	finaldata->qual[cnt].surgeon				= opdata->qual[d1.seq].surg[d2.seq].surgeon
	finaldata->qual[cnt].surg_start_dt_tm		= opdata->qual[d1.seq].surg[d2.seq].surg_start_dt_tm
	finaldata->qual[cnt].surg_start_tz			= opdata->qual[d1.seq].surg[d2.seq].surg_start_tz
	finaldata->qual[cnt].surg_stop_dt_tm		= opdata->qual[d1.seq].surg[d2.seq].surg_stop_dt_tm
	finaldata->qual[cnt].surg_stop_tz			= opdata->qual[d1.seq].surg[d2.seq].surg_stop_tz
	
;	finaldata->qual[cnt].out_room_dt_tm			= opdata->qual[d1.seq].surg[d2.seq].out_room_dt_tm
;	finaldata->qual[cnt].out_room_tz			= opdata->qual[d1.seq].surg[d2.seq].out_room_tz
;	finaldata->qual[cnt].pacu1_end_dt_tm		= opdata->qual[d1.seq].surg[d2.seq].pacu1_end_dt_tm
;	finaldata->qual[cnt].pacu1_tz				= opdata->qual[d1.seq].surg[d2.seq].pacu1_tz
;	finaldata->qual[cnt].pacu2_end_dt_tm		= opdata->qual[d1.seq].surg[d2.seq].pacu2_end_dt_tm
;	finaldata->qual[cnt].pacu2_tz				= opdata->qual[d1.seq].surg[d2.seq].pacu2_tz

	if (opdata->qual[d1.seq].surg[d2.seq].pacu1_end_dt_tm > 0.0)
		finaldata->qual[cnt].pacu_dt_tm		= opdata->qual[d1.seq].surg[d2.seq].pacu1_end_dt_tm
		finaldata->qual[cnt].pacu_tz		= opdata->qual[d1.seq].surg[d2.seq].pacu1_tz
	
	;001
	elseif (opdata->qual[d1.seq].surg[d2.seq].pacu2_end_dt_tm > 0.0)
		finaldata->qual[cnt].pacu_dt_tm		= opdata->qual[d1.seq].surg[d2.seq].pacu2_end_dt_tm
		finaldata->qual[cnt].pacu_tz		= opdata->qual[d1.seq].surg[d2.seq].pacu2_tz
	
	;001
;	else
;		finaldata->qual[cnt].pacu_dt_tm		= opdata->qual[d1.seq].surg[d2.seq].out_room_dt_tm
;		finaldata->qual[cnt].pacu_tz		= opdata->qual[d1.seq].surg[d2.seq].out_room_tz
		
	endif
	
	; intraoperative
	finaldata->qual[cnt].intraop_event_cd				= opdata->qual[d1.seq].intraop[d3.seq].event_cd
	finaldata->qual[cnt].intraop_performed_dt_tm		= opdata->qual[d1.seq].intraop[d3.seq].performed_dt_tm
	finaldata->qual[cnt].intraop_performed_tz			= opdata->qual[d1.seq].intraop[d3.seq].performed_tz
	finaldata->qual[cnt].intraop_performed_prsnl_id		= opdata->qual[d1.seq].intraop[d3.seq].performed_prsnl_id
	finaldata->qual[cnt].intraop_performed_by			= opdata->qual[d1.seq].intraop[d3.seq].performed_by
	finaldata->qual[cnt].intraop_result_status_cd		= opdata->qual[d1.seq].intraop[d3.seq].result_status_cd
	finaldata->qual[cnt].intraop_result_dt_tm			= opdata->qual[d1.seq].intraop[d3.seq].result_dt_tm
	finaldata->qual[cnt].intraop_result_tz				= opdata->qual[d1.seq].intraop[d3.seq].result_tz
	
	;001
	; postoperative
	finaldata->qual[cnt].postop_event_cd				= opdata->qual[d1.seq].postop[d4.seq].event_cd
	finaldata->qual[cnt].postop_performed_dt_tm			= opdata->qual[d1.seq].postop[d4.seq].performed_dt_tm
	finaldata->qual[cnt].postop_performed_tz			= opdata->qual[d1.seq].postop[d4.seq].performed_tz
	finaldata->qual[cnt].postop_performed_prsnl_id		= opdata->qual[d1.seq].postop[d4.seq].performed_prsnl_id
	finaldata->qual[cnt].postop_performed_by			= opdata->qual[d1.seq].postop[d4.seq].performed_by
	finaldata->qual[cnt].postop_result_status_cd		= opdata->qual[d1.seq].postop[d4.seq].result_status_cd
	finaldata->qual[cnt].postop_result_dt_tm			= opdata->qual[d1.seq].postop[d4.seq].result_dt_tm
	finaldata->qual[cnt].postop_result_tz				= opdata->qual[d1.seq].postop[d4.seq].result_tz
	
	; operative
	if (opdata->qual[d1.seq].surg[d2.seq].surg_case_id = opdata->qual[d1.seq].op[d5.seq].surg_case_id)
		finaldata->qual[cnt].op_event_cd								= opdata->qual[d1.seq].op[d5.seq].event_cd
		finaldata->qual[cnt].op_performed_dt_tm							= opdata->qual[d1.seq].op[d5.seq].performed_dt_tm
		finaldata->qual[cnt].op_performed_tz							= opdata->qual[d1.seq].op[d5.seq].performed_tz
		finaldata->qual[cnt].op_performed_prsnl_id						= opdata->qual[d1.seq].op[d5.seq].performed_prsnl_id
		finaldata->qual[cnt].op_performed_by							= opdata->qual[d1.seq].op[d5.seq].performed_by
		finaldata->qual[cnt].op_modified_dt_tm							= opdata->qual[d1.seq].op[d5.seq].modified_dt_tm
		finaldata->qual[cnt].op_modified_tz								= opdata->qual[d1.seq].op[d5.seq].modified_tz
		finaldata->qual[cnt].op_modified_prsnl_id						= opdata->qual[d1.seq].op[d5.seq].modified_prsnl_id
		finaldata->qual[cnt].op_modified_by								= opdata->qual[d1.seq].op[d5.seq].modified_by
		finaldata->qual[cnt].op_result_status_cd						= opdata->qual[d1.seq].op[d5.seq].result_status_cd
		finaldata->qual[cnt].op_result_dt_tm							= opdata->qual[d1.seq].op[d5.seq].result_dt_tm
		finaldata->qual[cnt].op_result_tz								= opdata->qual[d1.seq].op[d5.seq].result_tz
		finaldata->qual[cnt].op_complete_within_four_hours				= opdata->qual[d1.seq].op[d5.seq].complete_within_four_hours
		finaldata->qual[cnt].op_modified_within_four_hours				= opdata->qual[d1.seq].op[d5.seq].modified_within_four_hours
		finaldata->qual[cnt].op_prior_to_surgery						= opdata->qual[d1.seq].op[d5.seq].prior_to_surgery
		finaldata->qual[cnt].op_performed_prior_to_pacu					= opdata->qual[d1.seq].op[d5.seq].performed_prior_to_pacu
		finaldata->qual[cnt].op_modified_prior_to_pacu					= opdata->qual[d1.seq].op[d5.seq].modified_prior_to_pacu
		finaldata->qual[cnt].op_performed_prior_to_phaseii_postproc		= opdata->qual[d1.seq].op[d5.seq].performed_prior_to_phaseii_postproc
		finaldata->qual[cnt].op_modified_prior_to_phaseii_postproc		= opdata->qual[d1.seq].op[d5.seq].modified_prior_to_phaseii_postproc
	endif
	
	; brief operative
	finaldata->qual[cnt].has_briefop		= opdata->qual[d1.seq].has_briefop
	
with nocounter, outerjoin = d2, time = 300

call echorecord(finaldata)
 
 
/**************************************************************/ 
; select data
select distinct into value($OUTDEV)
	patient_name			= trim(finaldata->qual[d1.seq].patient_name, 3)
	, fin					= trim(finaldata->qual[d1.seq].fin, 3)
	, encntr_id				= finaldata->qual[d1.seq].encntr_id
	, encntr_type			= trim(uar_get_code_display(finaldata->qual[d1.seq].encntr_type_cd), 3)	
	, med_service			= trim(uar_get_code_display(finaldata->qual[d1.seq].med_service_cd), 3)	
	, med_service_alias		= trim(finaldata->qual[d1.seq].med_service_alias, 3)
	
	, compliant_ind			= if (finaldata->qual[d1.seq].op_event_cd > 0.0)
								if (finaldata->qual[d1.seq].surgeon_prsnl_id = finaldata->qual[d1.seq].op_performed_prsnl_id)
									evaluate(finaldata->qual[d1.seq].compliant_ind, 1, "Y", "N")
								else
									""
								endif
							  else
								"N"
							  endif
							  
	, tjc_compliant_ind		= if (finaldata->qual[d1.seq].op_event_cd > 0.0)
								if (finaldata->qual[d1.seq].surgeon_prsnl_id = finaldata->qual[d1.seq].op_performed_prsnl_id)
									evaluate(finaldata->qual[d1.seq].tjc_compliant_ind, 1, "Y", "N")
								else
									""
								endif
							  else
								"N"
							  endif
						  
	; surgical case							  	
	, surg_case_nbr			= trim(finaldata->qual[d1.seq].surg_case_nbr, 3)
	, surgeon				= trim(finaldata->qual[d1.seq].surgeon, 3)
	, surg_start_dt_tm		= datetimezoneformat(finaldata->qual[d1.seq].surg_start_dt_tm, 
												 finaldata->qual[d1.seq].surg_start_tz, "mm/dd/yyyy hh:mm zzz;;q", 0)
	, surg_stop_dt_tm		= datetimezoneformat(finaldata->qual[d1.seq].surg_stop_dt_tm, 
												 finaldata->qual[d1.seq].surg_stop_tz, "mm/dd/yyyy hh:mm zzz;;q", 0)
;	, out_room_dt_tm		= datetimezoneformat(finaldata->qual[d1.seq].out_room_dt_tm, 
;												 finaldata->qual[d1.seq].out_room_tz, "mm/dd/yyyy hh:mm zzz;;q", 0)
;	, pacu1_end_dt_tm		= datetimezoneformat(finaldata->qual[d1.seq].pacu1_end_dt_tm, 
;												 finaldata->qual[d1.seq].pacu1_tz, "mm/dd/yyyy hh:mm zzz;;q", 0)
;	, pacu2_end_dt_tm		= datetimezoneformat(finaldata->qual[d1.seq].pacu2_end_dt_tm, 
;												 finaldata->qual[d1.seq].pacu2_tz, "mm/dd/yyyy hh:mm zzz;;q", 0)
	, pacu_dt_tm			= datetimezoneformat(finaldata->qual[d1.seq].pacu_dt_tm, 
												 finaldata->qual[d1.seq].pacu_tz, "mm/dd/yyyy hh:mm zzz;;q", 0)
	
	; intraoperative
;	, intraop_event					= trim(uar_get_code_display(finaldata->qual[d1.seq].intraop_event_cd), 3)
;	, intraop_performed_dt_tm		= datetimezoneformat(finaldata->qual[d1.seq].intraop_performed_dt_tm, 
;														 finaldata->qual[d1.seq].intraop_performed_tz, "mm/dd/yyyy hh:mm:ss zzz;;q", 0)
;	, intraop_performed_by			= trim(finaldata->qual[d1.seq].intraop_performed_by, 3)
;	, intraop_result_status			= trim(uar_get_code_display(finaldata->qual[d1.seq].intraop_result_status_cd), 3)
;	, intraop_result_dt_tm			= datetimezoneformat(finaldata->qual[d1.seq].intraop_result_dt_tm, 
;														 finaldata->qual[d1.seq].intraop_result_tz, "mm/dd/yyyy hh:mm:ss zzz;;q", 0)
	
	; postoperative
	, postop_event					= trim(uar_get_code_display(finaldata->qual[d1.seq].postop_event_cd), 3)
	, postop_performed_dt_tm		= datetimezoneformat(finaldata->qual[d1.seq].postop_performed_dt_tm, 
														 finaldata->qual[d1.seq].postop_performed_tz, "mm/dd/yyyy hh:mm:ss zzz;;q", 0)
	, postop_performed_by			= trim(finaldata->qual[d1.seq].postop_performed_by, 3)
	, postop_result_status			= trim(uar_get_code_display(finaldata->qual[d1.seq].postop_result_status_cd), 3)
	, postop_result_dt_tm			= datetimezoneformat(finaldata->qual[d1.seq].postop_result_dt_tm, 
														 finaldata->qual[d1.seq].postop_result_tz, "mm/dd/yyyy hh:mm:ss zzz;;q", 0)
	
	; brief operative
	, has_brief_op_note					= evaluate(finaldata->qual[d1.seq].has_briefop, 1, "Y", "N")
	
	; operative
	, op_event							= trim(uar_get_code_display(finaldata->qual[d1.seq].op_event_cd), 3)
	, op_performed_dt_tm				= datetimezoneformat(finaldata->qual[d1.seq].op_performed_dt_tm, 
															 finaldata->qual[d1.seq].op_performed_tz, "mm/dd/yyyy hh:mm:ss zzz;;q", 0)
	, op_performed_by					= trim(finaldata->qual[d1.seq].op_performed_by, 3)
	, op_modified_dt_tm					= datetimezoneformat(finaldata->qual[d1.seq].op_modified_dt_tm, 
															 finaldata->qual[d1.seq].op_modified_tz, "mm/dd/yyyy hh:mm:ss zzz;;q", 0)
	, op_modified_by					= trim(finaldata->qual[d1.seq].op_modified_by, 3)
	, op_result_status					= trim(uar_get_code_display(finaldata->qual[d1.seq].op_result_status_cd), 3)
;	, op_result_dt_tm					= datetimezoneformat(finaldata->qual[d1.seq].op_result_dt_tm, 
;															 finaldata->qual[d1.seq].op_result_tz, "mm/dd/yyyy hh:mm zzz;;q", 0)

	, op_complete_within_four_hours		= if (finaldata->qual[d1.seq].op_event_cd > 0.0)
											if (finaldata->qual[d1.seq].surgeon_prsnl_id = finaldata->qual[d1.seq].op_performed_prsnl_id)
												evaluate(finaldata->qual[d1.seq].op_complete_within_four_hours, 1, "Y", "N")
											else
												""
											endif
										  else
										  	""
										  endif
										  
	, op_modified_within_four_hours		= if (finaldata->qual[d1.seq].op_event_cd > 0.0)
											if (finaldata->qual[d1.seq].surgeon_prsnl_id = finaldata->qual[d1.seq].op_performed_prsnl_id)
												evaluate(finaldata->qual[d1.seq].op_modified_within_four_hours, 1, "Y", "N")
											else
												""
											endif
										  else
										  	""
										  endif
										  
	, op_prior_to_surgery				= if (finaldata->qual[d1.seq].op_event_cd > 0.0)
											if (finaldata->qual[d1.seq].surgeon_prsnl_id = finaldata->qual[d1.seq].op_performed_prsnl_id)
												evaluate(finaldata->qual[d1.seq].op_prior_to_surgery, 1, "Y", "N")
											else
												""
											endif
										  else
										  	""
										  endif
										  
	, op_performed_prior_to_pacu		= if (finaldata->qual[d1.seq].op_event_cd > 0.0)
											if (finaldata->qual[d1.seq].surgeon_prsnl_id = finaldata->qual[d1.seq].op_performed_prsnl_id)
												evaluate(finaldata->qual[d1.seq].op_performed_prior_to_pacu, 1, "Y", "N")
											else
												""
											endif
										  else
										  	""
										  endif
										  
	, op_modified_prior_to_pacu			= if (finaldata->qual[d1.seq].op_event_cd > 0.0)
											if (finaldata->qual[d1.seq].surgeon_prsnl_id = finaldata->qual[d1.seq].op_performed_prsnl_id)
												evaluate(finaldata->qual[d1.seq].op_modified_prior_to_pacu, 1, "Y", "N")
											else
												""
											endif
										  else
										  	""
										  endif
										  
	, op_performed_prior_to_phaseii_postproc		= if (finaldata->qual[d1.seq].op_event_cd > 0.0)
														if (finaldata->qual[d1.seq].surgeon_prsnl_id = finaldata->qual[d1.seq].op_performed_prsnl_id)
															evaluate(finaldata->qual[d1.seq].op_performed_prior_to_phaseii_postproc, 1, "Y", "N")
														else
															""
														endif
													  else
														""
													  endif
										  
	, op_modified_prior_to_phaseii_postproc			= if (finaldata->qual[d1.seq].op_event_cd > 0.0)
														if (finaldata->qual[d1.seq].surgeon_prsnl_id = finaldata->qual[d1.seq].op_performed_prsnl_id)
															evaluate(finaldata->qual[d1.seq].op_modified_prior_to_phaseii_postproc, 1, "Y", "N")
														else
															""
														endif
													  else
														""
													  endif

from
	(dummyt d1 with seq = value(finaldata->cnt))

order by
	patient_name
	, finaldata->qual[d1.seq].surg_start_dt_tm
	, op_event
	, finaldata->qual[d1.seq].op_performed_dt_tm
	, finaldata->qual[d1.seq].op_modified_dt_tm
	, compliant_ind
;	, op_complete_within_four_hours
;	, op_modified_within_four_hours
;	, op_prior_to_surgery
;	, op_performed_prior_to_pacu
;	, op_modified_prior_to_pacu
	
with nocounter, separator = " ", format, time = 300

 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

#exitscript

end go
 
