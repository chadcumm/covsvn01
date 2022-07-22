/******************************************************************************
 *
 *  Copyright Notice:  (c) 1983 Laboratory Information Systems &
 *                              Technology, Inc.
 *       Revision      (c) 1984-2005 Cerner Corporati
 *
 *  Cerner (R) Proprietary Rights Notice:  All rights reserved.
 *  This material contains the valuable properties and trade secrets of
 *  Cerner Corporation of Kansas City, Missouri, United States of
 *  America (Cerner), embodying substantial creative efforts and
 *  confidential information, ideas and expressions, no part of which
 *  may be reproduced or transmitted in any form or by any means, or
 *  retained in any storage or retrieval system without the express
 *  written permission of Cerner.
 *
 *  Cerner is a registered mark of Cerner Corporation.
 *
 ******************************************************************************/
 
/******************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
*******************************************************************************
 	Author:				Chad Cummings
						Dan Herren
	Date Written:		Oct 2019
	Solution:			Radiology
	Source file name:  	cov_echo_extract_sl.prg
	Object name:		cov_echo_extract_sl
	CR#:				6139
 
	Program purpose:	Runs in OPS JOB "COV Radiology Extract Service Line"
	Executing from:		CCL
  	Special Notes:
 
*******************************************************************************
*   GENERATED MODIFICATION CONTROL LOG
*
*   Mod #	Mod Date	Developer             	Comment
*   -------	----------- --------------------  	---------------------------
*
*
*******************************************************************************/
 
drop program cov_echo_extract_sl:dba go
create program cov_echo_extract_sl:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "START_DATE" = "SYSDATE"
	, "END_DATE" = "SYSDATE"
	, "Output To File" = 0 

with OUTDEV, START_DATE, END_DATE, OUTPUT_FILE
 
 
;call echo(build("loading script:",curprog))
;%i ccluserdir:cov_custom_ccl_common.inc
 
 
free record t_rec
record t_rec
(
	1 prompt_startdate       				= f8
	1 prompt_enddate         				= f8
	1 startdate_format						= vc
	1 enddate_format						= vc
	1 runtime								= vc
	1 tot_cnt								= i4
	1 process_duration						= vc
	1 output_file_ind						= i2
	1 version								= vc
	1 qual[*]
		2 person_id							= f8
		2 encntr_id							= f8
		2 order_id							= f8
		2 event_id							= f8
		2 rad_report_id						= f8
		2 catalog_cd						= f8
		2 loc_facility_cd					= f8
		2 facility 							= vc
		2 department 						= vc
		2 section							= vc
		2 loc_exam 							= vc
		2 loc_patient						= vc
		2 modality 							= vc
		2 patient_name 						= vc
		2 account_number 					= vc
		2 accession_nbr						= vc
		2 check_in_type 					= vc
		2 ordering_provider 				= vc
		2 request_order_dt_tm 				= dq8
		2 orig_order_dt_tm 					= dq8
		2 schedule_dt_tm					= dq8
		2 activate_dt_tm 					= dq8
		2 exam_code 						= vc
		2 exam_code_mod						= vc
		2 exam_code_cdm						= vc
		2 exam_name 						= vc
		2 exam_start_dt_tm 					= dq8
		2 exam_stop_dt_tm 					= dq8
		2 exam_status 						= vc
		2 report_status						= vc
		2 films_prepared_ready_dt_tm 		= dq8
		2 technician 						= vc
		2 read_start_dt_tm 					= dq8
		2 read_stop_dt_tm 					= dq8
		2 dictated_reporting_physician		= vc
		2 approved_dt_tm 					= dq8
		2 transcribed_reporting_physician	= vc
		2 transcribed_dt_tm					= dq8
		2 priority 							= vc
		2 report_completed_dt_tm 			= dq8
		2 final_reporting_physician 		= vc
		2 performing_physician_nbr 			= vc
		2 performing_physician_name 		= vc
		2 performing_physician_specialty 	= vc
		2 patient_type 						= vc
		2 prelim_rpt_del_dt_tm 				= dq8
		2 prelim_rpt 						= vc
		2 addendum_cnt						= i2
		2 addendum_qual[*]
		 3 event_id							= f8
		 3 action_dt_tm						= dq8
		 3 report_prsnl_id					= f8
		 3 prsnl							= vc
)
 
 
;==============================================================================
; DVDev DECLARED VARIABLES
;==============================================================================
declare FINNBR_VAR					= f8 with constant(uar_get_code_by("DISPLAYKEY",   319, "FINNBR")),protect
declare COMPLETED_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14123, "COMPLETED" )),protect
declare ORGDOCTOR_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY",   320, "ORGANIZATIONDOCTOR")),protect
declare SCHED_VAR					= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "SCHEDULED")),protect
declare APPT_VAR					= f8 with constant(uar_get_code_by("DISPLAYKEY", 14232, "APPOINTMENT")),protect
declare CHECKIN_VAR					= f8 with constant(uar_get_code_by("DISPLAYKEY", 14232, "CHECKIN")),protect
declare EMERGENCY_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY",   321, "EMERGENCY")),protect
declare INPATIENT_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY",   321, "INPATIENT")),protect
declare OUTPATIENT_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY",   321, "OUTPATIENT")),protect
declare PREADMIT_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY",   321, "PREADMIT")),protect
declare CDM_VAR						= f8 with constant(uar_get_code_by("DISPLAYKEY", 14002, "HOSPITALCDMTECH")),protect
declare CPT_VAR						= f8 with constant(uar_get_code_by("DISPLAYKEY", 14002, "CPT")),protect
declare CPTMODIFIER_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14002, "CPTMODIFIER")),protect
declare ADDENDED_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY", 28880, "ADDENDED")),protect
declare DEPT_STATUS_COMPLETED_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY", 14281, "EXAMCOMPLETED")),protect
declare RAD_TYPE_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY",  6000, "RADIOLOGY")),protect
declare RAD_STATUS_COMPLETED_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY", 14192, "COMPLETED")),protect
declare RPT_STATUS_NEW_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY", 14202, "NEW")),protect
declare RPT_STATUS_CANCELED_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY", 14202, "CANCELED")),protect
declare RPT_STATUS_FINAL_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY", 14202, "FINAL")),protect
declare RPT_ACTION_DICTATED_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY", 28880, "DICTATED")),protect
declare RPT_ACTION_TRANSCRIBED_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY", 28880, "TRANSCRIBED")),protect
declare RPT_ACTION_APPROVED_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY", 28880, "APPROVED")),protect
declare ADDENDUM_VAR				= f8 with constant(uar_get_code_by("DISPLAY", 72, "Addendum")),protect
;--
declare num							= i4 with noconstant(0)
declare idx							= i4 with noconstant(0)
 
;--
declare	start_process_dt		 	= f8
set		start_process_dt 			= cnvtdatetime(curdate,curtime3)
set	    t_rec->runtime				= format(start_process_dt,";;q")
;==============================================================================
; SET DATA-RANGE VARIABLES
;==============================================================================
declare START_DATE = f8
declare END_DATE   = f8
 
; 1 DAY BACK FROM CURRENT DATE
;set START_DATE = cnvtlookbehind("2,D")
;set START_DATE = datetimefind(START_DATE,"D","B","B")
;set START_DATE = cnvtlookahead("1,D",START_DATE)
;set END_DATE   = cnvtlookahead("1,D",START_DATE)
;set END_DATE   = cnvtlookbehind("1,SEC", END_DATE)
;set end_date = cnvtdatetime(sysdate)
; 30 DAYS BACK FROM CURRENT DATE
;set START_DATE = cnvtlookbehind("31,D")
;set START_DATE = datetimefind(START_DATE,"D","B","B")
;set START_DATE = cnvtlookahead("1,D",START_DATE)
;set END_DATE   = cnvtlookahead("30,D",START_DATE)
;set END_DATE   = cnvtlookbehind("1,SEC", END_DATE)
 
; 60 DAYS BACK FROM CURRENT DATE
;set START_DATE = cnvtlookbehind("61,D")
;set START_DATE = datetimefind(START_DATE,"D","B","B")
;set START_DATE = cnvtlookahead("1,D",START_DATE)
;set END_DATE   = cnvtlookahead("60,D",START_DATE)
;set END_DATE   = cnvtlookbehind("1,SEC", END_DATE)
 
;-----------------------------------------------------
; SET DATE PROMPT VARIABLES FOR MANUAL TESTING
;-----------------------------------------------------
;set START_DATE = CNVTDATETIME("17-FEB-2020 00:00:00")
;set END_DATE   = CNVTDATETIME("25-FEB-2020 23:59:59")
 
;-----------------------------------------------------
; SET DATE PROMPTS TO RECORD STRUCTURE
;-----------------------------------------------------
;set t_rec->prompt_startdate = cnvtdatetime($START_DATE)
;set t_rec->prompt_enddate   = cnvtdatetime($END_DATE)
 
 
;==============================================================================
; SET DATA-FILE VARIABLES
;==============================================================================
;--TESTING--
;declare FILENAME_VAR	= vc with constant(build(trim(cnvtlower(curprog)), ".txt"))
 
;--LIVE--
;declare FILENAME_DT_TM	= vc with constant(format(cnvtdatetime(curdate, curtime3), "yyyy_mm_dd_hh_mm_ss;;d"))
;declare FILENAME_VAR	= vc with constant(build(cnvtlower(curdomain),"_",cnvtlower(trim(curprog)),"_", FILENAME_DT_TM, ".txt"))
declare FILENAME_VAR	= vc with constant(build("radservicelinedaily", ".txt"))
 
declare DIRNAME1_VAR	= vc with constant(build("cer_temp:",  FILENAME_VAR))
declare DIRNAME2_VAR	= vc with constant(build("$cer_temp/", FILENAME_VAR))
 
declare FILEPATH_VAR	= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
													"_cust/to_client_site/ClinicalAncillary/Radiology/Extracts/ServiceLine/", FILENAME_VAR))
declare OUTPUT_VAR		= vc with noconstant("")
declare CMD_VAR			= vc with noconstant("")
declare LEN_VAR			= i4 with noconstant(0)
declare STAT_VAR		= i4 with noconstant(0)

if (validate(request->batch_selection))
	set t_rec->output_file_ind = 1
else
	set t_rec->output_file_ind = $OUTPUT_FILE
endif
 
;==============================================================================
; DEFINE OUTPUT VALUE
;==============================================================================
set t_rec->version = "started"

if (t_rec->output_file_ind = 1)
	set OUTPUT_VAR = value(DIRNAME1_VAR)   ;WRITES TO CER_TEMP:
	set t_rec->prompt_startdate = cnvtdatetime(datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'B', 'B'))
	set t_rec->prompt_enddate   = cnvtdatetime(datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'E', 'E'))
	if (validate(request))
		set t_rec->version = concat("ops2:",cnvtrectojson(request))
	endif
else
	set OUTPUT_VAR = value($OUTDEV)        ;DISPLAY TO SCREEN
	set t_rec->prompt_startdate = cnvtdatetime($START_DATE)
	set t_rec->prompt_enddate   = cnvtdatetime($END_DATE)
	if (validate(request))
		set t_rec->version = concat("other2:",cnvtrectojson(request))
	else
		set t_rec->version = concat("other3:")
	endif
endif

set t_rec->startdate_format = format(t_rec->prompt_startdate,";;q")
set t_rec->enddate_format = format(t_rec->prompt_enddate,";;q") 
 
;==============================================================================
; GET EXAMS
;==============================================================================
call echo(build("(Q1/10) *** GET EXAMS ***"))
select into "nl:"
 
from OMF_RADMGMT_ORDER_ST oros
 
	,(inner join ORDER_CATALOG oc on oc.catalog_cd = oros.catalog_cd
		and oc.catalog_type_cd = RAD_TYPE_VAR ;2517
		and oc.description = "CA*Echo*"
		and oc.active_ind = 1)
 
	,(inner join ORDERS o on o.order_id = oros.order_id
;		and o.order_id = 1237425613
;		and o.dept_status_cd = DEPT_STATUS_COMPLETED_VAR  ;9316
		and o.active_ind = 1)
 
	,(inner join ORDER_RADIOLOGY ord on ord.order_id = o.order_id
		and ord.exam_status_cd = RAD_STATUS_COMPLETED_VAR ;4224
		and ord.report_status_cd != RPT_STATUS_CANCELED_VAR) ;4265
 
	,(inner join ENCOUNTER e on e.encntr_id = o.encntr_id
		and e.encntr_class_cd in (EMERGENCY_VAR, INPATIENT_VAR, OUTPATIENT_VAR, PREADMIT_VAR) ;319455,319456,319457,319458
		;and e.loc_facility_cd =   2552503645.00 ;PW
		and e.active_ind = 1)
 
 	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = FINNBR_VAR ;1077
;		and ea.alias = "2001303476"  ;FIN
		and	ea.active_ind = 1)
 
	,(inner join RAD_EXAM re on re.order_id = o.order_id)
 
	,(inner join RAD_EXAM_PRSNL rep on rep.rad_exam_id = re.rad_exam_id
		and	rep.action_type_cd = COMPLETED_VAR)  ;3966
 
	,(inner join PERSON p on p.person_id = o.person_id
		and p.active_ind = 1)
 
	,(inner join PRSNL p1 on p1.person_id = ord.order_physician_id
		and p1.active_ind = 1)
 
	,(inner join PRSNL p2 on p2.person_id = rep.exam_prsnl_id
		and p2.active_ind = 1)
 
where (oros.updt_dt_tm between cnvtdatetime(t_rec->prompt_startdate) and cnvtdatetime(t_rec->prompt_enddate))
;where (oros.start_dt_tm between cnvtdatetime(t_rec->prompt_startdate) and cnvtdatetime(t_rec->prompt_enddate))
 
head report
	cnt = 0
 
head oros.order_id
	cnt = cnt + 1
 
	if (mod(cnt,10) = 1)
		stat = alterlist(t_rec->qual, cnt + 9)
    endif
 
	t_rec->qual[cnt].order_id				= o.order_id
   	t_rec->qual[cnt].person_id				= o.person_id
    t_rec->qual[cnt].encntr_id				= o.encntr_id
    t_rec->qual[cnt].catalog_cd				= o.catalog_cd
    t_rec->qual[cnt].rad_report_id			= oros.rad_report_id
   	t_rec->qual[cnt].facility				= uar_get_code_display(e.loc_facility_cd)
    t_rec->qual[cnt].department				= trim(uar_get_code_description(oros.perf_dept_cd),3)  ;rr.perf_loc_cd
    t_rec->qual[cnt].section				= trim(uar_get_code_description(oros.section_cd),3)  ;rr.perf_loc_cd
   	t_rec->qual[cnt].loc_exam				= uar_get_code_display(re.service_resource_cd)
   	t_rec->qual[cnt].loc_patient			= uar_get_code_display(e.loc_room_cd)
    t_rec->qual[cnt].modality				= trim(uar_get_code_display(e.loc_nurse_unit_cd),3)
    t_rec->qual[cnt].patient_name			= p.name_full_formatted
	t_rec->qual[cnt].account_number			= ea.alias
    t_rec->qual[cnt].accession_nbr			= ord.accession
	t_rec->qual[cnt].check_in_type			= uar_get_code_display(e.encntr_type_cd)
    t_rec->qual[cnt].ordering_provider		= p1.name_full_formatted
   	t_rec->qual[cnt].loc_facility_cd		= e.loc_facility_cd
    t_rec->qual[cnt].orig_order_dt_tm		= o.orig_order_dt_tm
    t_rec->qual[cnt].request_order_dt_tm	= o.current_start_dt_tm
	t_rec->qual[cnt].report_status			= uar_get_code_display(ord.report_status_cd)
    t_rec->qual[cnt].exam_status			= uar_get_code_display(ord.exam_status_cd)
   	t_rec->qual[cnt].exam_name				= uar_get_code_display(ord.catalog_cd)
    t_rec->qual[cnt].exam_start_dt_tm		= ord.start_dt_tm
    t_rec->qual[cnt].exam_stop_dt_tm		= ord.complete_dt_tm
    t_rec->qual[cnt].priority				= uar_get_code_display(ord.priority_cd)
    t_rec->qual[cnt].patient_type			= uar_get_code_display(e.encntr_type_cd)
    t_rec->qual[cnt].technician				= p2.name_full_formatted
 
foot report
	t_rec->tot_cnt = cnt
	stat = alterlist(t_rec->qual, t_rec->tot_cnt)
 
with nocounter
 
 
;==============================================================================
; GET SCHEDULING DATA
;==============================================================================
call echo(build("(Q2/10) *** GET SCHEDULING SCHEDULED DATE TIME ***"))
select into "nl:"
 
from SCH_EVENT_ATTACH sea
 
	,(inner join SCH_APPT sa on sa.sch_event_id = sea.sch_event_id
		and sa.role_meaning = "PATIENT"
;		and sa.state_meaning = "CONFIRMED"  ;SCHEDULED ;CONFIRMED
		and sa.active_ind = 1)
 
where expand(num, 1, size(t_rec->qual, 5), sea.order_id, t_rec->qual[num].order_id)
	and sea.active_ind = 1
 
detail
	idx = 0
	pos = 0
 
	pos = locateval(idx, 1, size(t_rec->qual,5), sea.order_id, t_rec->qual[idx].order_id)
 
	if (pos > 0)
		t_rec->qual[pos].schedule_dt_tm = sa.beg_dt_tm
	endif
 
with nocounter, expand = 1
 
;------------------------------------------------------------------------------
call echo(build("(Q3/10) *** GET SCHEDULING ACTIVATE DATE TIME ***"))
select into "nl:"
 
from SCH_EVENT_ATTACH sea
 
	,(inner join SCH_EVENT se on se.sch_event_id = sea.sch_event_id
		and se.active_ind = 1)
 
	,(inner join SCH_EVENT_ACTION sen on sen.sch_event_id = se.sch_event_id
		and	sen.action_dt_tm is not	NULL
		and	sen.sch_action_cd = CHECKIN_VAR
		and	sen.active_ind = 1)
 
where expand(num, 1, size(t_rec->qual, 5), sea.order_id, t_rec->qual[num].order_id)
	and sea.active_ind = 1
 
detail
	idx = 0
	pos = 0
 
	pos = locateval(idx, 1, size(t_rec->qual,5), sea.order_id, t_rec->qual[idx].order_id)
 
	if (pos > 0)
		t_rec->qual[pos].activate_dt_tm = sen.action_dt_tm
	endif
 
with nocounter, expand = 1
 
 
;==============================================================================
; GET RAD REPORT DATA
;==============================================================================
call echo(build("(Q4/10) *** GET RAD REPORT DICTATED DATE TIME / PHYSICIAN NAME ***"))
select into "nl:"
 
from ORDER_RADIOLOGY ord
 
	,(inner join RAD_REPORT rr on rr.order_id = ord.parent_order_id)
 
	,(inner join RAD_RPT_PRSNL_HIST rrph on rrph.rad_report_id = rr.rad_report_id
		and rrph.action_cd = RPT_ACTION_DICTATED_VAR) ;673069
 
	,(inner join PRSNL p1 on p1.person_id = rrph.report_prsnl_id)
 
where expand(num, 1, size(t_rec->qual, 5), ord.order_id, t_rec->qual[num].order_id, ord.accession, t_rec->qual[num].accession_nbr)
 	and ord.report_status_cd != RPT_STATUS_NEW_VAR ;4265
 
detail
	idx = 0
	pos = 0
 
	pos = locateval(idx, 1, size(t_rec->qual,5), ord.order_id, t_rec->qual[idx].order_id, ord.accession,
		t_rec->qual[idx].accession_nbr)
 
	if (pos > 0)
		t_rec->qual[pos].read_start_dt_tm				= rr.dictated_dt_tm
		t_rec->qual[pos].read_stop_dt_tm				= rr.original_trans_dt_tm
		t_rec->qual[pos].dictated_reporting_physician	= p1.name_full_formatted
		if (t_rec->qual[pos].facility not in("FSR","MHHS","FSR FSW Diagn"))
			t_rec->qual[pos].read_stop_dt_tm 					= t_rec->qual[pos].read_start_dt_tm
			;t_rec->qual[pos].transcribed_dt_tm 					= t_rec->qual[pos].read_start_dt_tm
			t_rec->qual[pos].dictated_reporting_physician		= p1.name_full_formatted
			t_rec->qual[pos].transcribed_reporting_physician 	= t_rec->qual[pos].dictated_reporting_physician
			t_rec->qual[pos].transcribed_dt_tm 					=  t_rec->qual[pos].read_start_dt_tm
		endif
	endif
 	
with nocounter, expand = 1
 
 
;------------------------------------------------------------------------------
call echo(build("(Q5/10) *** GET RAD REPORT TRANSCRIBED DATE TIME / PHYSICIAN NAME ***"))
select into "nl:"
 
from ORDER_RADIOLOGY ord
 
	,(inner join RAD_REPORT rr on rr.order_id = ord.parent_order_id)
 
	,(inner join RAD_RPT_PRSNL_HIST rrph on rrph.rad_report_id = rr.rad_report_id
		and rrph.action_cd = RPT_ACTION_TRANSCRIBED_VAR)  ;673075
;		and rrp.prsnl_relation_flag = 0) ;Transcriptionist
 
	,(inner join PRSNL p1 on p1.person_id = rrph.report_prsnl_id)
 
where expand(num, 1, size(t_rec->qual, 5), ord.order_id, t_rec->qual[num].order_id, ord.accession, t_rec->qual[num].accession_nbr)
 	and ord.report_status_cd != RPT_STATUS_NEW_VAR ;4265
 
detail
	idx = 0
	pos = 0
 
	pos = locateval(idx, 1, size(t_rec->qual,5), ord.order_id, t_rec->qual[idx].order_id, ord.accession,
		t_rec->qual[idx].accession_nbr)
 
	if (pos > 0)
		
		t_rec->qual[pos].transcribed_dt_tm					= rr.original_trans_dt_tm
		t_rec->qual[pos].transcribed_reporting_physician	= p1.name_full_formatted
		if (t_rec->qual[pos].facility in("FSR","MHHS","FSR FSW Diagn"))
			t_rec->qual[pos].read_start_dt_tm 					= t_rec->qual[pos].transcribed_dt_tm 		
			t_rec->qual[pos].transcribed_reporting_physician	= t_rec->qual[pos].dictated_reporting_physician
		endif
		if (t_rec->qual[pos].read_start_dt_tm <= t_rec->qual[pos].transcribed_dt_tm)
			t_rec->qual[pos].read_start_dt_tm = t_rec->qual[pos].transcribed_dt_tm
		endif
	endif
 
with nocounter, expand = 1
 
 
;--------------------------------------------------------------------------------------
call echo(build("(Q6/10) *** GET RAD REPORT COMPLETED (FINAL) DATE TIME / PHYSICIAN NAME ***"))
select into "nl:"
 
from ORDER_RADIOLOGY ord
 
	,(inner join RAD_REPORT rr on rr.order_id = ord.parent_order_id)
 
	,(inner join RAD_RPT_PRSNL_HIST rrph on rrph.rad_report_id = rr.rad_report_id
		and rrph.action_cd = RPT_ACTION_APPROVED_VAR) ;673076
;		and rrp.prsnl_relation_flag = 2) ;Radiologist
 
	,(inner join PRSNL p1 on p1.person_id = rrph.report_prsnl_id)
 
where expand(num, 1, size(t_rec->qual, 5), ord.order_id, t_rec->qual[num].order_id, ord.accession, t_rec->qual[num].accession_nbr)
	and ord.report_status_cd = RPT_STATUS_FINAL_VAR  ;4263
 
detail
	idx = 0
	pos = 0
 
	pos = locateval(idx, 1, size(t_rec->qual,5), ord.order_id, t_rec->qual[idx].order_id, ord.accession,
		t_rec->qual[idx].accession_nbr)
 
	if (pos > 0)
		t_rec->qual[pos].approved_dt_tm				= rr.final_dt_tm
		t_rec->qual[pos].report_completed_dt_tm		= rr.final_dt_tm  ;rr.posted_final_dt_tm
		t_rec->qual[pos].final_reporting_physician	= p1.name_full_formatted
	endif
 
with nocounter, expand = 1
 
;------------------------------------------------------------------------------
call echo(build("(Q7/10) *** GET RAD REPORT ADDENDUMS ***"))

select into "nl:"
 
from CLINICAL_EVENT ce
 
	,(inner join PRSNL p on p.person_id = ce.verified_prsnl_id
		and p.active_ind = 1)

 
where expand(num, 1, size(t_rec->qual, 5), ce.encntr_id, t_rec->qual[num].encntr_id, ce.accession_nbr,
		t_rec->qual[num].accession_nbr)
	 and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.event_cd 			= ADDENDUM_VAR
 	
detail
	idx = 0
	pos = 0
 
	pos = locateval(idx, 1, size(t_rec->qual,5), ce.encntr_id, t_rec->qual[idx].encntr_id, ce.accession_nbr,
		t_rec->qual[idx].accession_nbr)
 
	if (pos > 0)
		t_rec->qual[pos].addendum_cnt = (t_rec->qual[pos].addendum_cnt + 1)
		stat = alterlist(t_rec->qual[pos].addendum_qual,t_rec->qual[pos].addendum_cnt)
		t_rec->qual[pos].addendum_qual[t_rec->qual[pos].addendum_cnt].event_id = ce.event_id
		t_rec->qual[pos].addendum_qual[t_rec->qual[pos].addendum_cnt].action_dt_tm = ce.event_end_dt_tm
		t_rec->qual[pos].addendum_qual[t_rec->qual[pos].addendum_cnt].report_prsnl_id = ce.verified_prsnl_id
		t_rec->qual[pos].addendum_qual[t_rec->qual[pos].addendum_cnt].prsnl = p.name_full_formatted
	endif
 
with nocounter, expand = 1
/*
select into "nl:"
 
from ORDER_RADIOLOGY ord
 
	,(inner join RAD_REPORT rr on rr.order_id = ord.parent_order_id)
 
	,(inner join RAD_RPT_PRSNL_HIST rrph on rrph.rad_report_id = rr.rad_report_id
		and rrph.action_cd = ADDENDED_VAR)
 
where expand(num, 1, size(t_rec->qual, 5), ord.encntr_id, t_rec->qual[num].encntr_id, ord.order_id, t_rec->qual[num].order_id)
 
detail
	idx = 0
	pos = 0
 
	pos = locateval(idx, 1, size(t_rec->qual,5), ord.encntr_id, t_rec->qual[idx].encntr_id, ord.order_id, t_rec->qual[idx].order_id)
 
	if (pos > 0)
		t_rec->qual[pos].prelim_rpt_del_dt_tm = rrph.action_dt_tm
		t_rec->qual[pos].addendum_cnt = (t_rec->qual[pos].addendum_cnt + 1)
		stat = alterlist(t_rec->qual[pos].addendum_qual,t_rec->qual[pos].addendum_cnt)
		t_rec->qual[pos].addendum_qual[t_rec->qual[pos].addendum_cnt].rpt_prsnl_hist_id = rrph.rpt_prsnl_hist_id
		t_rec->qual[pos].addendum_qual[t_rec->qual[pos].addendum_cnt].action_dt_tm = rrph.action_dt_tm
		t_rec->qual[pos].addendum_qual[t_rec->qual[pos].addendum_cnt].report_prsnl_id = rrph.report_prsnl_id
;		t_rec->qual[pos].prelim_rpt = uar_get_code_display(rrph.action_cd)
	endif
 
with nocounter, expand = 1
*/

;------------------------------------------------------------------------------
call echo(build("(Q8/10) *** GET RAD REPORT FILMS PREPARED/READY DATE TIME ***"))
select into "nl:"
 
from ORDER_RADIOLOGY ord
 
	,(inner join ORDER_ACTION oa on (oa.order_id = ord.parent_order_id or oa.ordeR_id = ord.order_id)
		and oa.dept_status_cd = DEPT_STATUS_COMPLETED_VAR) ;9316
 
where expand(num, 1, size(t_rec->qual, 5), ord.encntr_id, t_rec->qual[num].encntr_id, ord.order_id, t_rec->qual[num].order_id)
 
detail
	idx = 0
	pos = 0
 
	pos = locateval(idx, 1, size(t_rec->qual,5), ord.encntr_id, t_rec->qual[idx].encntr_id, ord.order_id, t_rec->qual[idx].order_id)
 
	if (pos > 0)
		t_rec->qual[pos].films_prepared_ready_dt_tm = oa.action_dt_tm
	endif
 
with nocounter, expand = 1
 
 
;==============================================================================
; GET CPT DATA
;==============================================================================
call echo(build("(Q9/10) *** GET CPT DATA ***"))
select into "nl:"
 
from CHARGE c
 
	,(inner join CHARGE_MOD cm on cm.charge_item_id = c.charge_item_id
		and cm.field1_id in (CPT_VAR, CPTMODIFIER_VAR, CDM_VAR)
		and not cm.field6 = null
	  	and cm.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3)
	  	and cm.active_ind = 1)
 
where expand(num, 1, size(t_rec->qual, 5), c.order_id, t_rec->qual[num].order_id)
 
detail
	idx = 0
	pos = 0
 
	pos = locateval(idx, 1, size(t_rec->qual,5), c.encntr_id, t_rec->qual[idx].encntr_id, c.order_id, t_rec->qual[idx].order_id)
 
	if (pos > 0)
		if (cm.field1_id = CPT_VAR)
			t_rec->qual[pos].exam_code 		= trim(cm.field6,3)
		elseif (cm.field1_id = CPTMODIFIER_VAR)
			t_rec->qual[pos].exam_code_mod 	= trim(cm.field6,3)
		elseif (cm.field1_id = CDM_VAR)
		 	t_rec->qual[pos].exam_code_cdm	= trim(cm.field6,3)
		endif
	endif
 
with nocounter, expand = 1
 
 
;==============================================================================
; GET PHYSICIAN DATA
;==============================================================================
call echo(build("(Q10/10) *** GET PHYSICIAN DATA ***"))
select into "nl:"
 
from CLINICAL_EVENT ce
 
	,(inner join PRSNL p on p.person_id = ce.performed_prsnl_id
		and p.active_ind = 1)
 
	,(inner join PRSNL_SPECIALTY_RELTN psr on psr.prsnl_id = ce.performed_prsnl_id
		and psr.active_ind = 1)
 
	,(left  join PRSNL_ALIAS pa on pa.person_id = p.person_id
		and pa.prsnl_alias_type_cd = ORGDOCTOR_VAR
		and pa.active_ind = 1)
 
where expand(num, 1, size(t_rec->qual, 5), ce.encntr_id, t_rec->qual[num].encntr_id, ce.accession_nbr,
		t_rec->qual[num].accession_nbr)
	/* and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val        >  " "
	and   ce.performed_prsnl_id > 0.0
 	*/
detail
	idx = 0
	pos = 0
 
	pos = locateval(idx, 1, size(t_rec->qual,5), ce.encntr_id, t_rec->qual[idx].encntr_id, ce.accession_nbr,
		t_rec->qual[idx].accession_nbr)
 
	if (pos > 0)
		t_rec->qual[pos].performing_physician_nbr		= pa.alias ;phy nbr
		t_rec->qual[pos].performing_physician_name		= p.name_full_formatted
		t_rec->qual[pos].performing_physician_specialty	= uar_get_code_display(psr.specialty_cd)
		t_rec->qual[pos].event_id						= ce.event_id
	endif
 
with nocounter, expand = 1
 
 
;==============================================================================
; REPORT OUTPUT
;==============================================================================
call echo(build("*** REPORT OUTPUT ***"))
if (t_rec->output_file_ind = 1)
	set modify filestream
endif
 
set t_rec->process_duration = build2(trim(cnvtstring(datetimediff(cnvtdatetime(curdate,curtime3), start_process_dt,5))), " seconds")
 
select
	if (t_rec->output_file_ind = 1)
;		with nocounter, separator='|', format, format=stream
		with nocounter, pcformat (^^, ^|^, 1,1), format, format=stream, formfeed=none,outerjoin=d2,check
		;with format, formfeed=stream, check,separator='|',outerjoin=d2
	else
		with nocounter, separator = " ", format,outerjoin=d2 ;, time = 240
	endif
 
into value(OUTPUT_VAR)
	 facility							= substring(1,30,t_rec->qual[d.seq].facility)
	,department							= substring(1,60,t_rec->qual[d.seq].department)
	,section							= substring(1,60,t_rec->qual[d.seq].section)
	,exam_room							= substring(1,30,t_rec->qual[d.seq].loc_exam)
	,patient_room						= substring(1,30,t_rec->qual[d.seq].loc_patient)
	,patient_unit						= substring(1,40,t_rec->qual[d.seq].modality)
	,patient_name						= substring(1,40,t_rec->qual[d.seq].patient_name)
	,account_number						= t_rec->qual[d.seq].account_number
	,accession_nbr						= cnvtacc(t_rec->qual[d.seq].accession_nbr)
	,check_in_type						= substring(1,30,t_rec->qual[d.seq].check_in_type)
	,ordering_provider					= substring(1,40,t_rec->qual[d.seq].ordering_provider)
	,priority							= t_rec->qual[d.seq].priority
	,orig_order_dt_tm					= format(t_rec->qual[d.seq].orig_order_dt_tm, "mm/dd/yy hh:mm;;d")
	,request_order_dt_tm				= format(t_rec->qual[d.seq].request_order_dt_tm, "mm/dd/yy hh:mm;;d")
	,schedule_dt						= format(t_rec->qual[d.seq].schedule_dt_tm, "mm/dd/yyyy hh:mm;;d")
	,checkin_dt_tm						= format(t_rec->qual[d.seq].activate_dt_tm, "mm/dd/yyyy hh:mm;;d")
	,technician							= substring(1,40,t_rec->qual[d.seq].technician)
	,exam_status						= t_rec->qual[d.seq].exam_status
	,exam_code_cpt						= t_rec->qual[d.seq].exam_code
	,exam_code_mod						= t_rec->qual[d.seq].exam_code_mod
	,exam_code_cdm						= t_rec->qual[d.seq].exam_code_cdm
	,exam_name							= substring(1,50,t_rec->qual[d.seq].exam_name)
	,exam_start_dt						= format(t_rec->qual[d.seq].exam_start_dt_tm, "mm/dd/yyyy hh:mm;;d")
	,exam_stop_dt						= format(t_rec->qual[d.seq].exam_stop_dt_tm, "mm/dd/yyyy hh:mm;;d")
	,tech_complete_dt_tm				= format(t_rec->qual[d.seq].films_prepared_ready_dt_tm, "mm/dd/yyyy hh:mm;;d")
	,report_status						= t_rec->qual[d.seq].report_status
	,dictated_reporting_physician		= substring(1,40,t_rec->qual[d.seq].dictated_reporting_physician)
	,read_start_dt						= format(t_rec->qual[d.seq].read_start_dt_tm, "mm/dd/yyyy hh:mm;;d")
	;,read_stop_dt						= format(t_rec->qual[d.seq].read_stop_dt_tm, "mm/dd/yyyy hh:mm;;d")
	,transcribed_reporting_physician	= t_rec->qual[d.seq].transcribed_reporting_physician
	,transcribed_dt						= format(t_rec->qual[d.seq].transcribed_dt_tm, "mm/dd/yyyy hh:mm;;d")
	,final_reporting_physician			= substring(1,40,t_rec->qual[d.seq].final_reporting_physician)
	,final_report_dt_tm					= format(t_rec->qual[d.seq].report_completed_dt_tm, "mm/dd/yyyy hh:mm;;d")
;	,prelim_report_deliver_dt			= format(t_rec->qual[d.seq].prelim_rpt_del_dt_tm, "mm/dd/yyyy hh:mm;;d")
;	,prelim_rpt							= t_rec->qual[d.seq].prelim_rpt
	,performing_physician_name			= substring(1,40,t_rec->qual[d.seq].performing_physician_name)
	,performing_physician_nbr			= t_rec->qual[d.seq].performing_physician_nbr						;
	,performing_physician_specialty		= substring(1,30,t_rec->qual[d.seq].performing_physician_specialty)
;	,patient_type						= substring(1,30,t_rec->qual[d.seq].patient_type)
	,addendum_dt_tm						= format(t_rec->qual[d.seq].addendum_qual[d1.seq].action_dt_tm,";;q")
	,addendum_prsnl						= substring(1,40,t_rec->qual[d.seq].addendum_qual[d1.seq].prsnl)
	,encntr_id							= t_rec->qual[d.seq].encntr_id
	,order_id							= t_rec->qual[d.seq].order_id
	,rad_report_id							= t_rec->qual[d.seq].rad_report_id
	,event_id							= t_rec->qual[d.seq].event_id
	,prompt_startdate   				= format(t_rec->prompt_startdate, "mm/dd/yyyy;;d")
	,prompt_enddate     				= format(t_rec->prompt_enddate, "mm/dd/yyyy;;d")
	,tot_rec							= format(t_rec->tot_cnt,";L")
	,process_duration					= t_rec->process_duration
 
from (dummyt d with seq = value(size(t_rec->qual,5)))
	,(dummyt d1 with seq = 1)
	,(dummyt d2)
 
plan d
	where maxrec(d1,size(t_Rec->qual[d.seq].addendum_qual,5))
join d2
join d1 
order by facility, department, patient_name, accession_nbr
 
 
;==============================================================================
; COPY FILE TO AStream
;==============================================================================
call echo(build("*** COPY FILE TO AStream ***"))
if (t_rec->output_file_ind = 1)
 
	set CMD_VAR  = build2("cp ", DIRNAME2_VAR, " ", FILEPATH_VAR)
	set LEN_VAR  = size(trim(CMD_VAR))
	set STAT_VAR = 0
 
	call dcl(CMD_VAR, LEN_VAR, STAT_VAR)
	call echo(build2(CMD_VAR, " : ", STAT_VAR))
 
endif
 
#exit_script
call echojson(t_rec,build(trim(cnvtlower(curprog)), ".dat"))
call echorecord(t_rec)
end
go
 
;;==============================================================================
 
;;------------------------------------------------------------------------------
 
;	,checked_in_dt					= format(t_rec->qual[d.seq].checked_in_dt_tm, "mm/dd/yyyy;;d")
;	,checked_in_tm					= format(t_rec->qual[d.seq].checked_in_dt_tm, "hh:mm;;q")
 
;;call echo(build("*** GET SCHEDULING CHECKED-IN DATE TIME ***"))
;;select into "nl:"
;;
;;from SCH_EVENT_ATTACH sea
;;
;;	,(inner join SCH_EVENT_ACTION sa on sa.sch_event_id = sea.sch_event_id
;;		and sa.action_meaning = "CHECKIN"
;;		and sa.active_ind = 1)
;;
;;where expand(num, 1, size(t_rec->qual, 5), sea.order_id, t_rec->qual[num].order_id)
;;	and sea.active_ind = 1
;;
;;detail
;;	idx = 0
;;	pos = 0
;;
;;	pos = locateval(idx, 1, size(t_rec->qual,5), sea.order_id, t_rec->qual[idx].order_id)
;;
;;	if (pos > 0)
;;		t_rec->qual[pos].checked_in_dt_tm = sa.action_dt_tm
;;	endif
;;
;;with nocounter, expand = 1
