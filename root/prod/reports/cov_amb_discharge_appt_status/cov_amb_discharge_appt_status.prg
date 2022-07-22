/*****************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
******************************************************************************************
	Author:				Dan Herren
	Date Written:		July 2020
	Solution:			AMB
	Source file name:  	cov_amb_Discharge_Appt_Status.prg
	Object name:		cov_amb_Discharge_Appt_Status
	CR#:				8083
 
	Program purpose:	Need a report that pulls discharges from acute facilities and if
						an follow up appointment was made or was left for the patient to
						make. Need to break out CMG pts versus all pts.
	Executing from:		CCL
  	Special Notes:
 
******************************************************************************************
*  	GENERATED MODIFICATION CONTROL LOG
*
*  	Revision #   Mod Date    Developer             Comment
*  	-----------  ----------  --------------------  ---------------------------------------
*	001			 Nov 2021	 Dan				   CR 10597	
*
******************************************************************************************/
 
drop program cov_amb_Discharge_Appt_Status:dba go
create program cov_amb_Discharge_Appt_Status:dba
 
; cov_amb_Discharge_Appt_Status 0, "01-APR-2020 00:00:00", "27-APR-2020 23:59:00", 2552503635 go
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Discharge Begin DT/TM" = "SYSDATE"
	, "Discharge End DT/TM" = "SYSDATE"
	, "Facility" = 0
	, "Specialty" = 0
	, "Quick Pick" = 0
	, "Output To File" = 0
 
with OUTDEV, STARTDATE_PMPT, ENDDATE_PMPT, FACILITY_PMPT, SPECIALTY_PMPT,
	QUICKPICK_PMPT, OUTPUT_FILE
 
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
Record rec (
	1 username          			= vc
	1 startdate         			= vc
	1 enddate          	 			= vc
	1 encntr_cnt					= i4
	1 list[*]
		2 facility      			= vc
		2 nurse_unit				= vc
		2 encntr_type    			= vc
		2 med_service				= vc
		2 ord_dischg_dt				= dq8
		2 enc_dischg_dt				= dq8
		2 enc_dischg_day			= vc
		2 dischg_dispo				= vc
		2 dischg_provider			= vc
		2 dischg_nurse				= vc
		2 pat_name      			= vc
		2 fin           			= vc
		2 mrn           			= vc
		2 cmrn						= vc
		2 order_mnem				= vc
		2 person_id					= f8
		2 encntr_id					= f8
		2 order_id					= f8
		2 sch_appt_id				= f8
		2 sch_event_id				= f8
		2 folwup_doc_id				= f8
		2 ins_primary_plan_name		= vc
		2 ins_primary_auth_nbr		= vc
		2 ins_secondary_plan_name	= vc
		2 ins_secondary_auth_nbr	= vc
;
		2 sch_appts_cnt				= i4
		2 sch_appts[*]
			3 sch_appt_id			= f8
			3 sch_event_id			= f8
			3 sch_appt_state		= vc
			3 sch_appt_provider		= vc
			3 sch_appt_loc			= vc
			3 sch_appt_beg_dt		= dq8
			3 sch_appt_end_dt		= dq8
;
		2 folwups_cnt				= i4
		2 folwups[*]
			3 folwup_doc_id			= f8
			3 folwup_days_or_weeks	= i4
			3 folwup_within_days	= i4
			3 folwup_within_dt		= dq8
			3 folwup_within_range	= vc
			3 folwup_time_frame		= vc
			3 folwup_details		= c255
			3 folwup_speciality		= vc
			3 folwup_provider_id	= f8
			3 folwup_provider_loc	= vc
			3 folwup_addr			= vc
			3 slt_qualify_ind		= i2 ;cmc
			3 qpk_qualify_ind		= i2 ;cmc
)
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare ACTIVE_VAR         		= f8 with constant(uar_get_code_by("DISPLAYKEY",   48, "ACTIVE")),protect
declare INPATIENT_VAR   		= f8 with constant(uar_get_code_by("DISPLAYKEY",   71, "INPATIENT")),protect
declare OBSERVATION_VAR   		= f8 with constant(uar_get_code_by("DISPLAYKEY",   71, "OBSERVATION")),protect
declare SSN_VAR 				= f8 with constant(uar_get_code_by("DISPLAYKEY",    4, "SSN"))
declare FIN_TYPE_VAR        	= f8 with constant(uar_get_code_by("DISPLAYKEY",  319, "FINNBR")),protect
declare MRN_TYPE_VAR        	= f8 with constant(uar_get_code_by("DISPLAYKEY",  319, "MRN")),protect
declare CMRN_TYPE_VAR       	= f8 with constant(uar_get_code_by("DISPLAYKEY",  263, "CMRN")),protect
declare HOME_SELF_CARE_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",   19, "HOMEORSELFCARE01")),protect
declare HOME_HEALTH_VISIT_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY",   19, "HOMEHEALTHCAREVISITSNOTDME06")),protect
declare LEFT_AGAINST_ADVICE_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY",   19, "LEFTAGAINSTMEDICALADVICE07")),protect
declare STAR_DOCTOR_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",  263, "STARDOCTORNUMBER")),protect
declare ORG_DOC_VAR     		= f8 with constant(uar_get_code_by("DISPLAYKEY",  320, "ORGANIZATIONDOCTOR")),protect
declare ORDER_PHY_VAR   		= f8 with constant(uar_get_code_by("DISPLAYKEY",  333, "ORDERREVIEW")),protect
declare DISCHG_PATIENT_VAR   	= f8 with constant(uar_get_code_by("DISPLAYKEY",  200, "DISCHARGEPATIENT")),protect
declare CONFIRMED_VAR   		= f8 with constant(uar_get_code_by("DISPLAYKEY",14233, "CONFIRMED")),protect
declare SCHEDULED_VAR   		= f8 with constant(uar_get_code_by("DISPLAYKEY",14233, "SCHEDULED")),protect
declare RESCHEDULED_VAR   		= f8 with constant(uar_get_code_by("DISPLAYKEY",14233, "RESCHEDULED")),protect
declare HOME_ADDRESS_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",  212, "HOME"))
declare BUSINESS_ADDRESS_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY",  212, "BUSINESS"))
declare HOME_PHONE_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",   43, "HOME"))
declare EMPLOYER_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",  338, "EMPLOYER"))
declare FAMILY_PRACTICE_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",14151, "FAMILYPRACTICE"))
declare INTERNAL_MEDICINE_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY",14151, "INTERNALMEDICINE"))
;
declare OPR_FAC_VAR		   		= vc with noconstant(fillstring(1000," "))
declare OPR_SLT_VAR		   		= vc with noconstant(fillstring(1000," "))
declare OPR_QPK_VAR		   		= vc with noconstant(fillstring(1000," "))
;
declare username           		= vc with protect
declare initcap()          		= c100
;
declare num						= i4 with noconstant(0)
declare idx						= i4 with noconstant(0)
 
;go to exitscript
 
/**************************************************************
; DVDev START CODING
**************************************************************/
;GET USERNAME FOR REPORT
select into "NL:"
from
	prsnl p
where p.person_id = reqinfo->updt_id
detail
	rec->username = p.username
with nocounter
 

;SET DATE PROMPTS TO DATE VARIABLES 
if (validate(request->batch_selection) = 1 or $OUTPUT_FILE = 1) ;begin 001
	;OPS-JOB
	declare START_DATE 	= f8
	declare END_DATE 	= f8
 
	;=== PREVIOUS 30 DAYS FROM CURRENT DATE ===
	set START_DATE = cnvtlookbehind("31,D")
	set START_DATE = datetimefind(START_DATE,"D","B","B")
	set START_DATE = cnvtlookahead("1,D",START_DATE)
	set END_DATE   = cnvtlookahead("30,D",START_DATE)
	set END_DATE   = cnvtlookbehind("1,SEC", END_DATE)

	declare START_DATETIME_VAR 	= vc with protect ,constant(format(cnvtdatetime(START_DATE), "dd-mmm-yyyy hh:mm:ss;;d"))
	declare END_DATETIME_VAR 	= vc with protect ,constant(format(cnvtdatetime(END_DATE), "dd-mmm-yyyy hh:mm:ss;;q"))
else ;end 001
	;USER INTERACTION
	if (($2 in ("*curdate*"))) ;STARTDATE_PMPT
		declare _dq8 = dq8 with noconstant ,private
	  	declare _parse = vc with constant (concat("set _dq8 = cnvtdatetime(" , $2 ,", 0) go")) ,private
	  	call parser(_parse)
	  	declare START_DATETIME_VAR = vc with protect ,constant (format(_dq8 ,"dd-mmm-yyyy;;d"))
	else
	 	declare START_DATETIME_VAR = vc with protect ,constant ($2)
	endif
 
	if (($3 in ("*curdate*"))) ;ENDDATE_PMPT
	  	declare _dq8 = dq8 with noconstant ,private
	  	declare _parse2 = vc with constant (concat("set _dq8 = cnvtdatetime(" , $3 ,", 235959) go")) ,private
	  	call parser(_parse2)
	  	declare END_DATETIME_VAR = vc with protect ,constant (format(_dq8 ,"dd-mmm-yyyy hh:mm;;q"))
	else
	  	declare END_DATETIME_VAR = vc with protect ,constant (concat(trim ($3) ," 23:59:59"))
	endif
endif

; SET DATE VARIABLES FOR *****  MANUAL TESTING  *****
;set START_DATETIME_VAR = cnvtdatetime("01-AUG-2020 00:00:00")
;set END_DATETIME_VAR   = cnvtdatetime("07-AUG-2020 23:59:59")
 
 
; SET DATES VARIABLES TO RECORD STRUCTURE
set rec->startdate = format(cnvtdatetime(START_DATETIME_VAR), "mm/dd/yyyy;;q")
set rec->enddate   = format(cnvtdatetime(END_DATETIME_VAR), "mm/dd/yyyy;;q")
 
 
;SET FACILITY VARIABLE
if(substring(1,1,reflect(parameter(parameter2($FACILITY_PMPT),0))) = "L")	;multiple values were selected
	set OPR_FAC_VAR = "in"
elseif(parameter(parameter2($FACILITY_PMPT),1) = 0.0)						;all (any) values were selected
	set OPR_FAC_VAR = "!="
else																		;a single value was selected
	set OPR_FAC_VAR = "="
endif
 
 
;SET SPECIALTY VARIABLE
if(substring(1,1,reflect(parameter(parameter2($SPECIALTY_PMPT),0))) = "L")	;multiple values were selected
	set OPR_SLT_VAR = "in"
elseif(parameter(parameter2($SPECIALTY_PMPT),1) = 0.0)						;all (any) values were selected
	set OPR_SLT_VAR = "!="
else																		;a single value was selected
	set OPR_SLT_VAR = "="
endif
 
 
;SET QUICKPICK VARIABLE
if(substring(1,1,reflect(parameter(parameter2($QUICKPICK_PMPT),0))) = "L")	;multiple values were selected
	set OPR_QPK_VAR = "in"
elseif(parameter(parameter2($QUICKPICK_PMPT),1) = 0.0)						;all (any) values were selected
	set OPR_QPK_VAR = "!="
else																		;a single value was selected
	set OPR_QPK_VAR = "="
endif
 
;begin 001 
;**************************************************************
; SET DATA-FILE VARIABLES
;**************************************************************
;declare filename_var	= vc with constant(build2("dischargeapptstatus_", format(END_DATETIME_VAR, "yyyymm;;q"), ".txt"))
declare filename_var	= vc with constant(build2("dischargeapptstatus", ".txt"))
;declare filename_var	= vc with constant(build2("djhtest", ".txt"))
;
declare dirname1_var	= vc with constant(build("cer_temp:",  filename_var))
declare dirname2_var	= vc with constant(build("$cer_temp/", filename_var))
 
;--PRODUCTION ASTREAM--
declare filepath_var	= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
													"_cust/to_client_site/ClinicalAncillary\DischargeAppointment/", filename_var))
 
;--DEVELOPMENT FILE PATH FOR TESTING-
;declare filepath_var	= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
;													"_cust/to_client_site/CernerCCL/", filename_var))
;
;-----------------------------
; DECLARE OUTPUT VALUES
;-----------------------------
declare output_var		= vc with noconstant("")
declare cmd				= vc with noconstant("")
declare len				= i4 with noconstant(0)
declare stat			= i4 with noconstant(0)
 
;-----------------------------
; DEFINE OUTPUT VALUE
;-----------------------------
if (validate(request->batch_selection) = 1 or $OUTPUT_FILE = 1)
	set output_var = value(dirname1_var)   ;OPS JOB
else
	set output_var = value($OUTDEV)        ;DISPLAY TO SCREEN
endif
;end 001
 
;==============================================================================
; MAIN DATA SELECT
;==============================================================================
;call echo(build("*** MAIN DATA SELECT ***"))
 
select into "NL:"
from ENCOUNTER e
 
	,(inner join PERSON p on p.person_id = e.person_id
		and p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
		and p.active_ind = 1)
 
	,(inner join ORDERS o on o.encntr_id = e.encntr_id
		and o.catalog_cd = DISCHG_PATIENT_VAR ;3224545.00
		and o.active_ind = 1)
 
;	,(left join SCH_APPT sa on sa.person_id = e.person_id
;		and (sa.beg_effective_dt_tm <= sysdate and sa.end_effective_dt_tm > sysdate)
;		and sa.sch_appt_id > 0.0
;;;		and sa.encntr_id = 0.0
;		and sa.role_meaning = "PATIENT"
;		and sa.sch_state_cd in (CONFIRMED_VAR) ;, SCHEDULED_VAR, RESCHEDULED_VAR) ;4538, 4546, 4545
;		and sa.appt_location_cd in (
;				select
;					l.location_cd
;				from ORG_SET os
;					,ORG_SET_ORG_R osor
;					,ORGANIZATION org
;	;					,LOCATION l
;				where os.org_set_id = osor.org_set_id
;				and osor.organization_id = org.organization_id
;				and l.organization_id = osor.organization_id
;				and osor.active_ind = 1
;				and os.name like '*CMG*'
;				and l.location_type_cd = 772) ;CMG Amb Facilities Only
;		and sa.active_ind = 1)
;;
;	,(left join SCH_APPT sar on sar.sch_event_id = sa.sch_event_id
;		and sar.schedule_id = sa.schedule_id
;		and sar.role_meaning = "RESOURCE"
;		and sar.primary_role_ind = 1)
 
	,(left join PAT_ED_DOCUMENT ped on ped.encntr_id = e.encntr_id)
 
	,(left join PAT_ED_DOC_FOLLOWUP pedf on pedf.pat_ed_doc_id = ped.pat_ed_document_id
		;and operator(pedf.quick_pick_cd, OPR_QPK_VAR, $QUICKPICK_PMPT)
		and pedf.active_ind = 1)
 
	,(left join PRSNL_SPECIALTY_RELTN pr on pr.prsnl_id = pedf.provider_id
		;and operator(pr.specialty_cd, OPR_SLT_VAR, $SPECIALTY_PMPT)
;		and pr.specialty_cd in (FAMILY_PRACTICE_VAR, INTERNAL_MEDICINE_VAR) ;4074,4091
		and pr.active_ind = 1)
 
	,(left join LONG_TEXT lt on lt.long_text_id = pedf.cmt_long_text_id
		and lt.active_ind = 1)
 
	,(left join ADDRESS ap on ap.parent_entity_id = pedf.provider_id
		and ap.active_ind = 1)
 
	,(left join ADDRESS ao on ao.parent_entity_id = pedf.organization_id
		and ao.active_ind = 1)
 
	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
;		and ea.alias = "2009101360"
		and ea.encntr_alias_type_cd = FIN_TYPE_VAR   ;1077
		and ea.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
		and ea.active_ind = 1)
 
where operator(e.loc_facility_cd, OPR_FAC_VAR, $FACILITY_PMPT)
	and e.encntr_type_cd in (INPATIENT_VAR, OBSERVATION_VAR) ;309308,309312
	and e.disch_disposition_cd in (HOME_SELF_CARE_VAR, HOME_HEALTH_VISIT_VAR, LEFT_AGAINST_ADVICE_VAR) ;638671,638672,312916
	and e.disch_dt_tm between cnvtdatetime(START_DATETIME_VAR) and cnvtdatetime(END_DATETIME_VAR)
	and e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
	and e.active_ind = 1
 
order by e.encntr_id, pedf.pat_ed_doc_followup_id
;order by e.encntr_id, sa.sch_appt_id, pedf.pat_ed_doc_followup_id
 
head report
	cnt  = 0
	scnt = 0
 	fcnt = 0
 
	call alterlist(rec->list, 10)
 
;get base information
head e.encntr_id
 
	cnt = cnt + 1
 
	if(mod(cnt, 10) = 1 and cnt > 10)
		call alterlist(rec->list, cnt + 9)
	endif
 
 	rec->encntr_cnt = cnt
 
	rec->list[cnt].facility  		= uar_get_code_display(e.loc_facility_cd)
	rec->list[cnt].nurse_unit		= uar_get_code_description(e.loc_nurse_unit_cd)
	rec->list[cnt].encntr_type		= uar_get_code_display(e.encntr_type_cd)
	rec->list[cnt].med_service		= uar_get_code_display(e.med_service_cd)
	rec->list[cnt].ord_dischg_dt	= o.orig_order_dt_tm
	rec->list[cnt].enc_dischg_dt	= e.disch_dt_tm
	rec->list[cnt].dischg_dispo		= uar_get_code_display(e.disch_disposition_cd)
	rec->list[cnt].pat_name     	= p.name_full_formatted
	rec->list[cnt].order_mnem		= o.order_mnemonic
 	rec->list[cnt].person_id		= p.person_id
 	rec->list[cnt].encntr_id		= e.encntr_id
 	rec->list[cnt].order_id			= o.order_id
 
	case (weekday(e.disch_dt_tm))
		of 0: rec->list[cnt].enc_dischg_day	 = "Sunday"
		of 1: rec->list[cnt].enc_dischg_day	 = "Monday"
		of 2: rec->list[cnt].enc_dischg_day	 = "Tuesday"
		of 3: rec->list[cnt].enc_dischg_day	 = "Wednesday"
		of 4: rec->list[cnt].enc_dischg_day	 = "Thursday"
		of 5: rec->list[cnt].enc_dischg_day	 = "Friday"
		of 6: rec->list[cnt].enc_dischg_day	 = "Saturday"
	endcase
 
;	scnt = 0
 
;get scheduled appointments
;head sa.sch_appt_id
;
;	scnt = scnt + 1
;
;	call alterlist(rec->list[cnt].sch_appts, scnt)
;
;	rec->list[cnt].sch_appts_cnt = scnt
;
;	rec->list[cnt].sch_appts[scnt].sch_appt_id			= sa.sch_appt_id
;	rec->list[cnt].sch_appts[scnt].sch_event_id			= sa.sch_event_id
;	rec->list[cnt].sch_appts[scnt].sch_appt_state		= uar_get_code_display(sa.sch_state_cd)
;	rec->list[cnt].sch_appts[scnt].sch_appt_provider	= uar_get_code_display(sar.resource_cd)
;	rec->list[cnt].sch_appts[scnt].sch_appt_loc 		= uar_get_code_display(sa.appt_location_cd)
;	rec->list[cnt].sch_appts[scnt].sch_appt_beg_dt		= sa.beg_dt_tm
;	rec->list[cnt].sch_appts[scnt].sch_appt_end_dt		= sa.end_dt_tm
;
	fcnt = 0
 
 
;get follow-up instructions
head pedf.pat_ed_doc_followup_id
 
	fcnt = fcnt + 1
 
	call alterlist(rec->list[cnt].folwups, fcnt)
 
	rec->list[cnt].folwups_cnt = fcnt
 
	rec->list[cnt].folwups[fcnt].folwup_doc_id			= pedf.pat_ed_doc_followup_id
	rec->list[cnt].folwups[fcnt].folwup_days_or_weeks	= pedf.days_or_weeks
	rec->list[cnt].folwups[fcnt].folwup_within_days		= pedf.fol_within_days
	rec->list[cnt].folwups[fcnt].folwup_within_dt		= pedf.fol_within_dt_tm
	rec->list[cnt].folwups[fcnt].folwup_within_range	= pedf.fol_within_range
	rec->list[cnt].folwups[fcnt].folwup_provider_id 	= pedf.provider_id
	rec->list[cnt].folwups[fcnt].folwup_provider_loc 	= pedf.provider_name
	rec->list[cnt].folwups[fcnt].folwup_details 		= lt.long_text
	rec->list[cnt].folwups[fcnt].folwup_speciality 		= uar_get_code_display(pr.specialty_cd)
 
	rec->list[cnt].folwups[fcnt].folwup_details =
		replace(replace(rec->list[cnt].folwups[fcnt].folwup_details, char(13), " ", 0), char(10), " ", 0)
 
	case (rec->list[cnt].folwups[fcnt].folwup_provider_id)
		;Organization
		of 0: 	rec->list[cnt].folwups[fcnt].folwup_addr =
					concat(trim(ao.street_addr,3), " ", trim(ao.city,3), " ", trim(ao.state,3), " ", trim(ao.zipcode,3))
		;Provider
		else  	rec->list[cnt].folwups[fcnt].folwup_addr =
					concat(trim(ap.street_addr,3), " ", trim(ap.city,3), " ", trim(ap.state,3), " ", trim(ap.zipcode,3))
	endcase
 
	if (rec->list[cnt].folwups[fcnt].folwup_days_or_weeks = 0)
		rec->list[cnt].folwups[fcnt].folwup_time_frame = build2(pedf.fol_within_days, " Days")
 
	elseif (rec->list[cnt].folwups[fcnt].folwup_days_or_weeks = 1
		and rec->list[cnt].folwups[fcnt].folwup_within_days > 0
		and rec->list[cnt].folwups[fcnt].folwup_within_range = null)
			rec->list[cnt].folwups[fcnt].folwup_time_frame = build2(pedf.fol_within_days, " Weeks")
 
	elseif (rec->list[cnt].folwups[fcnt].folwup_days_or_weeks < 0
		and rec->list[cnt].folwups[fcnt].folwup_within_range != null)
			rec->list[cnt].folwups[fcnt].folwup_time_frame = rec->list[cnt].folwups[fcnt].folwup_within_range
 
	elseif (rec->list[cnt].folwups[fcnt].folwup_within_dt != null)
		rec->list[cnt].folwups[fcnt].folwup_time_frame = format(rec->list[cnt].folwups[fcnt].folwup_within_dt, "mm/dd/yyyy hh:mm;;d")
 
	else null
	endif
 
	/* start cmc */
	if ((OPR_SLT_VAR = "in") or (OPR_SLT_VAR = "="))
		if (pr.specialty_cd = $SPECIALTY_PMPT)
			rec->list[cnt].folwups[fcnt].slt_qualify_ind = 1
		endif
	else
		rec->list[cnt].folwups[fcnt].slt_qualify_ind = 1
	endif
 
	if ((OPR_QPK_VAR = "in") or (OPR_QPK_VAR = "="))
		if (pedf.quick_pick_cd = $QUICKPICK_PMPT)
			rec->list[cnt].folwups[fcnt].qpk_qualify_ind = 1
		endif
	else
		rec->list[cnt].folwups[fcnt].qpk_qualify_ind = 1
	endif
	/* end cmc */
 
foot report
	stat = alterlist(rec->list, cnt)
 
with nocounter, separator=" ", format
 
;call echorecord(rec)
;go to exitscript
 
 
;============================================================================
; GET PERSON & ENCOUNTER ALIAS'S: FIN, MRN, CMRN
;============================================================================
call echo(build("*** GET PERSON & ENCOUNTER ALIAS'S DATA ***"))
select into "NL:"
 
from ENCOUNTER e
 
	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = FIN_TYPE_VAR   ;1077
		and ea.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
		and ea.active_ind = 1)
 
	,(inner join ENCNTR_ALIAS ea2 on ea2.encntr_id = e.encntr_id
		and ea2.encntr_alias_type_cd = MRN_TYPE_VAR   ;1079
		and ea2.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
		and ea2.active_ind = 1)
 
	,(left join PERSON_ALIAS pa on pa.person_id = e.person_id
		and pa.person_alias_type_cd = CMRN_TYPE_VAR    ;263
		and pa.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
		and pa.active_ind = 1)
 
where expand(num, 1, size(rec->list, 5), e.encntr_id, rec->list[num].encntr_id)
	and e.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
	and e.active_ind = 1
 
detail
	numx = 0
	idx  = 0
 
	idx = locateval(numx, 1, size(rec->list,5), e.encntr_id, rec->list[numx].encntr_id)
 
	while (idx > 0)
		rec->list[idx].fin  = ea.alias	;fin
		rec->list[idx].mrn  = ea2.alias	;mrn
		rec->list[idx].cmrn = pa.alias	;cmrn
 
		idx = locateval(numx, idx+1, size(rec->list,5), e.encntr_id, rec->list[numx].encntr_id)
	endwhile
 
with nocounter, expand = 1
 
 
;============================================================================
; GET DISCHARGE PROVIDER
;============================================================================
call echo("*** GET DISCHARGE PHYSICIAN  ***")
 
select into "NL:"
 
from ORDERS o
 
	,(inner join PRSNL pr on pr.person_id = o.last_update_provider_id
		and pr.active_ind = 1)
 
where expand(num, 1, size(rec->list, 5), o.encntr_id, rec->list[num].encntr_id)
		and o.catalog_cd = DISCHG_PATIENT_VAR ;3224545.00
		and o.active_ind = 1
 
order by o.encntr_id
 
head o.encntr_id
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(rec->list, 5), o.encntr_id, rec->list[numx].encntr_id)
 
    while(idx > 0)
		rec->list[idx].dischg_provider = trim(pr.name_full_formatted)
 
 		idx = locateval(numx, idx+1, size(rec->list, 5), o.encntr_id, rec->list[numx].encntr_id)
	endwhile
 
with nocounter, expand = 1
 
 
;============================================================================
; GET DISCHARGE NURSE
;============================================================================
call echo("*** GET DISCHARGE NURSE  ***")
 
select into "NL:"
 
from ORDER_REVIEW orv
 
	,(inner join PRSNL pr on pr.person_id = orv.review_personnel_id
		and pr.active_ind = 1)
 
where expand(num, 1, size(rec->list, 5), orv.order_id, rec->list[num].order_id)
	and orv.review_type_flag = 1 ;nurse
 
order by orv.order_id
 
head orv.order_id
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(rec->list, 5), orv.order_id, rec->list[numx].order_id)
 
    while(idx > 0)
		rec->list[idx].dischg_nurse = trim(pr.name_full_formatted)
 
 		idx = locateval(numx, idx+1, size(rec->list, 5), orv.order_id, rec->list[numx].order_id)
	endwhile
 
with nocounter, expand = 1
 
 
;============================================================================
; GET HEALTH PLAN DATA
;============================================================================
call echo("*** GET HEALTH PLAN DATA  ***")
 
select into "NL:"
 
from ENCNTR_PLAN_RELTN epr
 
	,(inner join HEALTH_PLAN hp on hp.health_plan_id = epr.health_plan_id
		and hp.active_ind = 1)
 
	,(left join ENCNTR_PLAN_AUTH_R epar on epar.encntr_plan_reltn_id = epr.encntr_plan_reltn_id
 		and epar.active_ind = 1)
 
	,(left join AUTHORIZATION au on au.authorization_id = epar.authorization_id
	and au.active_ind = 1)
 
where expand(num, 1, size(rec->list, 5), epr.encntr_id, rec->list[num].encntr_id)
	and epr.priority_seq in (1, 2)
	and epr.end_effective_dt_tm > sysdate
	and epr.active_ind = 1
 
order by epr.encntr_id
 
head epr.encntr_id
	numx = 0
	idx = 0
 
	idx = locateval(numx, 1, size(rec->list, 5), epr.encntr_id, rec->list[numx].encntr_id)
 
	while (idx > 0)
		case (epr.priority_seq)
			of 1:	rec->list[idx].ins_primary_plan_name	= hp.plan_name
					rec->list[idx].ins_primary_auth_nbr		= trim(au.auth_nbr, 3)
			of 2:	rec->list[idx].ins_secondary_plan_name	= hp.plan_name
					rec->list[idx].ins_secondary_auth_nbr	= trim(au.auth_nbr, 3)
		endcase
 
 		idx = locateval(numx, idx+1, size(rec->list, 5), epr.encntr_id, rec->list[numx].encntr_id)
	endwhile
 
with nocounter, expand = 1
 
call echorecord(rec)
;go to exitscript
 
 
;============================================================================
; REPORT OUTPUT
;============================================================================
if (rec->encntr_cnt > 0)
 
	if (validate(request->batch_selection) = 1 or $OUTPUT_FILE = 1)
		set modify filestream
	endif
 
	select
		if (validate(request->batch_selection) = 1 or $OUTPUT_FILE = 1)
;			with nocounter, pcformat (^"^, ^,^, 1,0), format, format=stream, formfeed=none  ;no padding
			with nocounter, pcformat (^^,  ^|^, 1,1), format, format=stream, formfeed=none  ;no padding/eliminates nulls
		else
			with nocounter, separator = " ", format
		endif
 
	distinct into value(output_var)
;	select distinct into value ($OUTDEV)
		 facility      			= rec->list[d.seq].facility
		,nurse_unit				= substring(1,50,trim(rec->list[d.seq].nurse_unit))
		,ord_dischg_dt			= format(rec->list[d.seq].ord_dischg_dt, "mm/dd/yyyy hh:mm;;q")
		,enc_dischg_date		= format(rec->list[d.seq].enc_dischg_dt, "mm/dd/yyyy;;q")
		,enc_dischg_time		= format(rec->list[d.seq].enc_dischg_dt, "hh:mm;;q")
		,ord_enc_dt_diff		= format(datetimediff(rec->list[d.seq].enc_dischg_dt, rec->list[d.seq].ord_dischg_dt,7),"####.##:##")
		,enc_dischg_day			= rec->list[d.seq].enc_dischg_day
		,dischg_dispo			= substring(1,50,trim(rec->list[d.seq].dischg_dispo))
		,patient_name	   		= substring(1,50,trim(rec->list[d.seq].pat_name))
		,fin		   			= rec->list[d.seq].fin
		,encntr_type			= rec->list[d.seq].encntr_type
		,med_service			= substring(1,50,trim(rec->list[d.seq].med_service))
		,ins_primary			= substring(1,50,trim(rec->list[d.seq].ins_primary_plan_name))
		,dischg_provider		= substring(1,50,trim(rec->list[d.seq].dischg_provider))
		,dischg_nurse			= substring(1,50,trim(rec->list[d.seq].dischg_nurse))
;
;		,sch_appt_id			= rec->list[d.seq].sch_appts[d2.seq].sch_appt_id
;		,sch_appt_state			= substring(1,50,trim(rec->list[d.seq].sch_appts[d2.seq].sch_appt_state))
;		,sch_appt_provider		= substring(1,50,trim(rec->list[d.seq].sch_appts[d2.seq].sch_appt_provider))
;		,sch_appt_loc			= substring(1,50,trim(rec->list[d.seq].sch_appts[d2.seq].sch_appt_loc))
;		,sch_appt_dt			= format(rec->list[d.seq].sch_appts[d2.seq].sch_appt_beg_dt, "mm/dd/yyyy hh:mm;;q")
;		,sch_appt_end_dt		= format(rec->list[d.seq].sch_appts[d2.seq].sch_appt_end_dt, "mm/dd/yyyy hh:mm;;q")
;
;		,followup_provider_id	= rec->list[d.seq].folwups[d3.seq].folwup_provider_id
;		,followup_doc_id		= rec->list[d.seq].folwups[d3.seq].folwup_doc_id
;		,followup_days_or_wks	= rec->list[d.seq].folwups[d3.seq].folwup_days_or_weeks
;		,followup_within_days	= rec->list[d.seq].folwups[d3.seq].folwup_within_days
;		,followup_within_dt		= format(rec->list[d.seq].folwups[d3.seq].folwup_within_dt, "mm/dd/yyyy hh:mm;;q")
;		,followup_within_range	= rec->list[d.seq].folwups[d3.seq].folwup_within_range
		,followup_speciality	= substring(1,70,rec->list[d.seq].folwups[d3.seq].folwup_speciality)
		,followup_time_frame	= format(substring(1,20,rec->list[d.seq].folwups[d3.seq].folwup_time_frame),";R")
		,followup_provider_loc	= substring(1,200,trim(replace(replace(rec->list[d.seq].folwups[d3.seq].folwup_provider_loc,
											char(13), " ", 0), char(10), " ", 0)))
		,followup_details		= replace(replace(rec->list[d.seq].folwups[d3.seq].folwup_details,
											char(13), " ", 0), char(10), " ", 0)
;		,followup_addr			= substring(1,100,trim(rec->list[d.seq].folwups[d3.seq].folwup_addr))
;
;		,sch_appt_id			= rec->list[d.seq].sch_appts[d2.seq].sch_appt_id
;		,sch_event_id			= rec->list[d.seq].sch_appts[d2.seq].sch_event_id
;		,person_id				= rec->list[d.seq].person_id
;		,order_mnem				= substring(1,50,trim(rec->list[d.seq].order_mnem))
;		,encntr_id     			= rec->list[d.seq].encntr_id
;		,order_id				= rec->list[d.seq].order_id
;		,sch_appts_cnt			= rec->list[d.seq].sch_appts_cnt
;		,folwups_cnt			= rec->list[d.seq].folwups_cnt
;		,encntr_cnt	   			= rec->encntr_cnt
;		,username      			= rec->username
;		,prompt_date_range		= concat(rec->startdate," to ",rec->enddate)
		,prompt_start_dt		= rec->startdate
		,prompt_end_dt			= rec->enddate
 
	from (DUMMYT d  with seq = value(size(rec->list,5)))
;		,(DUMMYT d2 with seq = 1)
		,(DUMMYT d3 with seq = 1)
 
	plan d
	where maxrec(d3,size(rec->list[d.seq].folwups,5))
;	where maxrec(d2,size(rec->list[d.seq].sch_appts,5))
;		and maxrec(d3,size(rec->list[d.seq].folwups,5))
 
;	join d2
;	where (rec->list[d.seq].sch_appts[d2.seq].sch_appt_id > 0)
 
	join d3
	where (rec->list[d.seq].folwups[d3.seq].folwup_doc_id > 0)
 		and rec->list[d.seq].folwups[d3.seq].slt_qualify_ind = 1 ;cmc
 		and rec->list[d.seq].folwups[d3.seq].qpk_qualify_ind = 1 ;cmc
 
	order by facility, followup_speciality, followup_provider_loc, enc_dischg_date, patient_name,
		rec->list[d.seq].encntr_id, rec->list[d.seq].folwups[d3.seq].folwup_doc_id
;	order by patient_name, rec->list[d.seq].encntr_id,
;		rec->list[d.seq].sch_appts[d2.seq].sch_appt_id, rec->list[d.seq].folwups[d3.seq].folwup_doc_id
 
	with nocounter, format, check, separator = " ", outerjoin=d3
;	with nocounter, format, check, separator = " ", outerjoin=d2, outerjoin=d3
 
	;begin 001
	;==============================
	; COPY FILE TO AStream
	;==============================
	if (validate(request->batch_selection) = 1 or $OUTPUT_FILE = 1)
		set cmd = build2("cp ", dirname2_var, " ", filepath_var)
		set len = size(trim(cmd))
 
		call dcl(cmd, len, stat)
		call echo(build2(cmd, " : ", stat))
	endif
 
	;;call echo("**************************************************")
	;;call echo(build2("*** Directory/File name: ", dirname2_var))
	;;call echo("**************************************************")
 	;end 001

else
 
	select into $OUTDEV
	from DUMMYT d
 
	head report
		call center("No records found for parameter input.",0,150)
 
	with nocounter
 
endif
 
#exitscript
end
go
 
 
/*
;	select into value ($OUTDEV)
;		 facility      		= rec->list[d.seq].facility
;;		,nurse_unit			= substring(1,50,trim(rec->list[d.seq].nurse_unit))
;;		,ord_dischg_dt		= format(rec->list[d.seq].ord_dischg_dt, "mm/dd/yyyy hh:mm;;q")
;		,enc_dischg_date	= format(rec->list[d.seq].enc_dischg_dt, "mm/dd/yyyy;;q")
;		,enc_dischg_time	= format(rec->list[d.seq].enc_dischg_dt, "hh:mm;;q")
;;		,ord_enc_dt_diff	= format(datetimediff(rec->list[d.seq].enc_dischg_dt, rec->list[d.seq].ord_dischg_dt,7),"####.##:##")
;;		,enc_dischg_day		= rec->list[d.seq].enc_dischg_day
;;		,dischg_dispo		= substring(1,50,trim(rec->list[d.seq].dischg_dispo))
;		,patient_name	   	= substring(1,50,trim(rec->list[d.seq].pat_name))
;		,fin		   		= rec->list[d.seq].fin
;;		,encntr_type		= rec->list[d.seq].encntr_type
;;		,ins_primary		= substring(1,50,trim(rec->list[d.seq].ins_primary_plan_name))
;;		,dischg_provider	= substring(1,50,trim(rec->list[d.seq].dischg_provider))
;;		,dischg_nurse		= substring(1,50,trim(rec->list[d.seq].dischg_nurse))
;;
;;		,sch_appt_id		= rec->list[d.seq].sch_appts[d2.seq].sch_appt_id
;		,sch_appt_state		= substring(1,50,trim(rec->list[d.seq].sch_appts[d2.seq].sch_appt_state))
;		,sch_appt_dt		= format(rec->list[d.seq].sch_appts[d2.seq].sch_appt_beg_dt, "mm/dd/yyyy hh:mm;;q")
;		,dchg_sch_dt_diff	= format(datetimediff(rec->list[d.seq].sch_appts[d2.seq].sch_appt_beg_dt,
;				rec->list[d.seq].enc_dischg_dt,7),"####.##:##")
;		,sch_appt_provider	= substring(1,50,trim(rec->list[d.seq].sch_appts[d2.seq].sch_appt_provider))
;		,sch_appt_loc		= substring(1,50,trim(rec->list[d.seq].sch_appts[d2.seq].sch_appt_loc))
;;		,sch_appt_dt		= format(rec->list[d.seq].sch_appts[d2.seq].sch_appt_beg_dt, "mm/dd/yyyy hh:mm;;q")
;;		,sch_appt_end_dt	= format(rec->list[d.seq].sch_appts[d2.seq].sch_appt_end_dt, "mm/dd/yyyy hh:mm;;q")
;;		,dchg_sch_dt_diff	= format(datetimediff(rec->list[d.seq].sch_appts[d2.seq].sch_appt_beg_dt,
;;				rec->list[d.seq].enc_dischg_dt,7),"####.##:##")
;;
;;		,folwup_provider_id	= rec->list[d.seq].folwups[d3.seq].folwup_provider_id
;;		,folwup_doc_id		= rec->list[d.seq].folwups[d3.seq].folwup_doc_id
;;		,folwup_days_or_wks	= rec->list[d.seq].folwups[d3.seq].folwup_days_or_weeks
;;		,folwup_within_days	= rec->list[d.seq].folwups[d3.seq].folwup_within_days
;;		,folwup_within_dt	= format(rec->list[d.seq].folwups[d3.seq].folwup_within_dt, "mm/dd/yyyy hh:mm;;q")
;;		,folwup_within_range= rec->list[d.seq].folwups[d3.seq].folwup_within_range
;		,folwup_time_frame	= format(substring(1,20,rec->list[d.seq].folwups[d3.seq].folwup_time_frame),";R")
;		,folwup_provider_loc= substring(1,50,trim(rec->list[d.seq].folwups[d3.seq].folwup_provider_loc))
;		,folwup_details		= substring(1,50,trim(rec->list[d.seq].folwups[d3.seq].folwup_details))
;;		,folwup_addr		= substring(1,100,trim(rec->list[d.seq].folwups[d3.seq].folwup_addr))
;;
;;		,sch_appt_id		= rec->list[d.seq].sch_appts[d2.seq].sch_appt_id
;;		,sch_event_id		= rec->list[d.seq].sch_appts[d2.seq].sch_event_id
;;		,person_id			= rec->list[d.seq].person_id
;;		,order_mnem			= substring(1,50,trim(rec->list[d.seq].order_mnem))
;;		,encntr_id     		= rec->list[d.seq].encntr_id
;;		,order_id			= rec->list[d.seq].order_id
;;		,sch_appts_cnt		= rec->list[d.seq].sch_appts_cnt
;;		,folwups_cnt		= rec->list[d.seq].folwups_cnt
;;		,encntr_cnt	   		= rec->encntr_cnt
;;		,username      		= rec->username
;		,prompt_startdate 	= rec->startdate
;		,prompt_enddate   	= rec->enddate
;
;	from (DUMMYT d  with seq = value(size(rec->list,5)))
;		,(DUMMYT d2 with seq = 1)
;		,(DUMMYT d3 with seq = 1)
;
;	plan d
;	where maxrec(d2,size(rec->list[d.seq].sch_appts,5))
;		and maxrec(d3,size(rec->list[d.seq].folwups,5))
;
;	join d2
;	where (rec->list[d.seq].sch_appts[d2.seq].sch_appt_id > 0)
;;		and rec->list[d.seq].sch_appts[d2.seq].sch_appt_beg_dt between rec->list[d.seq].enc_dischg_dt and cnvtlookahead("10,D"))
;
;	join d3
;	where (rec->list[d.seq].folwups[d3.seq].folwup_doc_id > 0)
;
;;	order by facility, nurse_unit, patient_name, rec->list[d.seq].encntr_id,
;;		rec->list[d.seq].sch_appts[d2.seq].sch_appt_id, rec->list[d.seq].folwups[d3.seq].folwup_doc_id
;	order by patient_name, rec->list[d.seq].encntr_id,
;		rec->list[d.seq].sch_appts[d2.seq].sch_appt_id, rec->list[d.seq].folwups[d3.seq].folwup_doc_id
;
;	with nocounter, format, check, separator = " ", outerjoin=d2, outerjoin=d3
*/
 
 
