/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		03/30/2020
	Solution:			Perioperative
	Source file name:	cov_rpt_external_reporting.prg
	Object name:		cov_rpt_external_reporting
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	03/30/2020  Chad Cummings			Initial Release
******************************************************************************/

drop program cov_rpt_external_reporting:dba go
create program cov_rpt_external_reporting:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Include All Facilities" = 0
	, "Facilitiy" = 0
	, "Report Option" = 0 

with OUTDEV, ALL_FACILITIES, FACILITY, REPORT_OPTION


call echo(build("loading script:",curprog	))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))

if (not(validate(reply,0)))
record  reply
(
	1 text = vc
	1 status_data
	 2 status = c1
	 2 subeventstatus[1]
	  3 operationname = c15
	  3 operationstatus = c1
	  3 targetobjectname = c15
	  3 targetobjectvalue = c100
)
endif

set reply->status_data.status = "F"

call set_codevalues(null)
call check_ops(null)

free set t_rec
record t_rec
(
	1 curprog					= vc
	1 custom_code_set			= i4
	1 records_attachment		= vc
	1 cnt						= i4
	1 prompt_report_type		= i2
	1 prompt_all_fac_ind		= i2
	1 prompt_loc_cnt			= i2
	1 prompt_loc_qual[*]
	 2 location_cd 				= f8
	 2 location_type_cd			= f8
	1 location_label_cnt		= i2
	1 location_label_qual[*]
	 2 location_cd				= f8
	 2 display					= vc
	 2 alias_type_meaning		= vc
	 2 alias					= vc
	1 diagnosis_search_cnt		= i2
	1 diagnosis_search_qual[*]
	 2 search_description		= vc
	 2 search_string			= vc
	 2 source_vocabulary_cnt	= i2
	 2 source_vocabulary_qual[*]
	  3 display					= vc
	  3 source_vocabulary_cd	= f8
	1 diagnosis_cnt				= i2
	1 diagnosis_qual[*]
	 2 nomenclature_id			= f8
	 2 source_string			= vc
	 2 source_vocabulary_cd		= f8
	1 encntr_type
	 2 ip_cnt					= i2
	 2 ip_qual[*]
	  3 encntr_type_cd			= f8
	 2 ed_cnt					= i2
	 2 ed_qual[*]
	  3 encntr_type_cd			= f8
	1 vent
	 2 stock_cnt				= i2
	 2 stock_qual[*]
	  3 model_name				= vc
	  3 vent_type				= c1
	 2 model_cnt				= i2
	 2 model_qual[*]
	  3 event_cd				= f8
	  3 vent_type				= c1
	 2 result_cnt				= i2
	 2 result_qual[*]
	  3 event_cd				= f8
	  3 lookback_hrs			= i2
	  3 vent_type				= c1
	1 covid19
	 2 expired_lookback_ind		= i2
	 2 expired_lookback_hours	= i2
	 2 expired_start_dt_tm		= dq8
	 2 expired_end_dt_tm		= dq8
	 2 admission_lookback_ind	= i2
	 2 admission_lookback_hours	= i2
	 2 admission_start_dt_tm	= dq8
	 2 admission_end_dt_tm		= dq8
	 2 onset_lookback_ind	  	= i2
	 2 onset_lookback_hours		= i2
	 2 onset_start_dt_tm		= dq8
	 2 onset_end_dt_tm			= dq8
	 2 positive_cnt				= i2
	 2 positive_qual[*]
	  3 result_val				= vc
	 2 result_cnt				= i2
	 2 result_qual[*]
	  3 event_cd				= f8
	 2 covid_oc_cnt				= i2
	 2 covid_oc_qual[*]
	  3 catalog_cd				= f8
	  3 activity_type_cd		= f8
	  3 catalog_type_cd			= f8
	 2 covid_status_cnt			= i2
	 2 covid_status_qual[*]
	  3 order_status_cd			= f8
	 2 covid_ignore_cnt			= i2
	 2 covid_ignore_qual[*]
	  3 oe_field_id				= f8
	  3 oe_field_value			= f8
	  3 oe_field_value_display	= vc
	1 pso
	 2 ip_pso_cnt				= i2
	 2 ip_pso_qual[*]
	  3 catalog_cd				= f8
	  3 activity_type_cd		= f8
	  3 catalog_type_cd			= f8
	 2 ip_pso_status_cnt		= i2
	 2 ip_pso_status_qual[*]
	  3 order_status_cd			= f8
	 2 ob_pso_cnt				= i2
	 2 ob_pso_qual[*]
	  3 catalog_cd				= f8
	  3 activity_type_cd		= f8
	  3 catalog_type_cd			= f8
	 2 ob_pso_status_cnt		= i2
	 2 ob_pso_status_qual[*]
	  3 order_status_cd			= f8
	1 patient_cnt				= i2
	1 patient_qual[*]
	 2 encntr_id				= f8
	 2 person_id				= f8
	 2 cov_facility_alias		= vc
	 2 cov_unit_alias			= vc
	 2 cov_room_alias			= vc
	 2 cov_bed_alias			= vc
	 2 loc_facility_cd			= f8
	 2 loc_unit_cd				= f8
	 2 loc_room_cd				= f8
	 2 loc_bed_cd				= f8
	 2 loc_class_1				= vc
	 2 encntr_type_cd			= f8
	 2 expired_ind				= i2
	 2 previous_admission_ind	= i2
	 2 previous_onset_ind		= i2
	 2 expired_dt_tm			= dq8
	 2 reg_dt_tm				= dq8
	 2 disch_dt_tm				= dq8
	 2 inpatient_dt_tm			= dq8
	 2 observation_dt_tm		= dq8
	 2 arrive_dt_tm				= dq8
	 2 dob						= dq8
	 2 positive_onset_dt_tm		= dq8
	 2 suspected_onset_dt_tm	= dq8
	 2 ip_los_hours				= i2
	 2 ip_los_days				= i2
	 2 fin						= vc
	 2 name_full_formatted		= vc
	 2 encntr_ignore			= i2
	 2 orders_cnt				= i2
	 2 orders_qual[*]			
	  3 order_id				= f8
	  3 catalog_cd				= f8
	  3 order_mnemonic			= vc
	  3 order_status_cd			= f8
	  3 order_status_display	= vc
	  3 orig_order_dt_tm		= dq8
	  3 order_status_dt_tm		= dq8
	  3 activity_type_cd		= f8
	  3 catalog_type_cd			= f8
	  3 order_ignore			= i2
	  3 order_detail_cnt		= i2
	  3 order_detal_qual[*]
	   4 oe_field_id			= f8
	   4 oe_field_value			= f8
	   4 oe_field_display_value	= vc
	   4 oe_field_dt_tm_value	= dq8
	 2 lab_results_cnt			= i2
	 2 lab_results_qual[*]
	  3 event_id				= f8
	  3 event_cd				= f8
	  3 task_assay_cd			= f8
	  3 order_id				= f8
	  3 result_val				= vc
	  3 event_tag				= vc
	  3 comment					= vc
	  3 event_end_dt_tm			= dq8
	  3 valid_from_dt_tm		= dq8
	  3 clinsig_updt_dt_tm		= dq8
	  3 result_ignore			= i2
	 2 vent_results_cnt			= i2
	 2 vent_results_qual[*]
	  3 event_id				= f8
	  3 event_cd				= f8
	  3 task_assay_cd			= f8
	  3 order_id				= f8
	  3 result_val				= vc
	  3 event_tag				= vc
	  3 comment					= vc
	  3 ventilator_type			= c1
	  3 event_end_dt_tm			= dq8
	  3 model_event_id			= f8
	  3 model_event_cd			= f8
	  3 model_result_val		= vc
	  3 covenant_stock_ind		= i2
	  3 result_ignore			= i2
	 2 diagnosis_cnt			= i2
	 2 diagnosis_qual[*]
	  3 diagnosis_id			= f8
	  3 source_string			= vc
	  3 nomenclature_id			= f8
	  3 orig_nomenclature_id	= f8
	  3 orig_source_string		= vc
	  3 daig_dt_tm				= dq8
)

free record hrts_covid19
record hrts_covid19
(
	1 summary_cnt					= i2
	1 summary_qual[*]           
	 2 facility						= vc
	 2 q1_total_pos_inp				= i2
	 2 q1_1_icu_pos_inp				= i2
	 2 q1_2_pos_inp_vent			= i2
	 2 q2_total_pend_inp			= i2
	 2 q2_1_icu_pend_inp			= i2
	 2 q2_2_pend_inp_vent			= i2
	1 patient_cnt 				= i2
	1 patient_qual[*]			
	 2 encntr_id				= f8
	 2 person_id				= f8
	 2 patient_name				= vc
	 2 fin						= vc
	 2 facility					= vc
	 2 unit						= vc
	 2 room_bed					= vc
	 2 location_class_1			= vc
	 2 encntr_type				= vc
	 2 pso						= vc
	 2 los_days					= i2
	 2 diagnosis				= vc
	 2 covid19_order			= vc
	 2 covid19_result			= vc
	 2 ventilator_result		= vc
	 2 ventilator_model			= vc
	 2 suspected				= c1
	 2 confirmed				= c1
	 2 ventilator			    = c1
	 2 ventilator_invasive		= c1
	 2 covenant_vent_stock		= c1
	 2 ip_pso					= c1
	 2 expired					= c1
	 2 prev_admission			= c1
	 2 prev_onset				= c1
)

free record nhsn_covid19
record nhsn_covid19
(
	1 summary_cnt					= i2
	1 summary_qual[*]           
	 2 facility						= vc
	 2 qa_numc19confnewadm			= i2
	 2 qb_numc19suspnewadm			= i2
	 2 qc_numc19honewpats			= i2
	 2 q1_ip_confirmed				= i2
	 2 q1_ip_suspected				= i2
	 2 q1_total						= i2	;numc19hosppats
	 2 q2_ip_confirmed_vent			= i2
	 2 q2_ip_suspected_vent			= i2
	 2 q2_total						= i2	;numc19mechventpats
	 2 q3_ip_conf_susp_los14		= i2	;numc19hopats
	 2 q4_ed_of_conf_susp_wait		= i2	;numc19overflowpats
	 2 q5_ed_of_conf_susp_wait_vent = i2	;numc19ofmechventpats
	 2 q6_disch_expired				= i2	;numc19prevdied
	 2 q6a_all_expired				= i2	;numc19died
	 2 q7_all_beds_total			= i2	;numtotbeds
	 2 q8_all_beds_total_surge		= i2	;numbeds
	 2 q9_occupied_ip_beds			= i2	;numbedsocc
	 2 q10_avail_icu_beds			= i2	;numicubeds
	 2 q11_occupied_icu_beds		= i2	;numicubedsocc
	 2 q12_ventilator_total			= i2	;numvent
	 2 q13_ventilator_in_use		= i2	;numventuse
	1 patient_cnt 				= i2
	1 patient_qual[*]			
	 2 encntr_id				= f8
	 2 person_id				= f8
	 2 patient_name				= vc
	 2 fin						= vc
	 2 facility					= vc
	 2 unit						= vc
	 2 room_bed					= vc
	 2 location_class_1			= vc
	 2 encntr_type				= vc
	 2 pso						= vc
	 2 los_days					= i2
	 2 diagnosis				= vc
	 2 covid19_order			= vc
	 2 covid19_result			= vc
	 2 ventilator_result		= vc
	 2 ventilator_model			= vc
	 2 suspected				= c1
	 2 confirmed				= c1
	 2 ventilator			    = c1
	 2 ventilator_invasive		= c1
	 2 covenant_vent_stock		= c1
	 2 ip_pso					= c1
	 2 expired					= c1
	 2 prev_admission			= c1
	 2 prev_onset				= c1
)

free record t_output
record t_output
(
	1 cnt 						= i2
	1 qual[*]
	 2 person_id				= f8
	 2 encntr_id				= f8
	 2 facility					= vc
	 2 patient_name				= vc
	 2 fin						= vc
	 2 dob						= vc
	 2 unit						= vc
	 2 room_bed					= vc
	 2 location_class_1			= vc
	 2 arrive_dt_tm				= vc
	 2 reg_dt_tm				= vc
	 2 inpatient_dt_tm			= vc
	 2 observation_dt_tm		= vc
	 2 disch_dt_tm				= vc
	 2 expired_dt_tm			= vc
	 2 encntr_type				= vc
	 2 pso						= vc
	 2 los_days					= i2
	 2 los_hours				= i2
	 2 diagnosis				= vc
	 2 covid19_order			= vc
	 2 covid19_order_dt_tm		= vc
	 2 covid19_result			= vc
	 2 covid19_result_dt_tm		= vc
	 2 ventilator_type			= vc
	 2 ventilator_model			= vc
	 2 ventilator_dt_tm			= vc
	 2 ventilator				= vc
	 2 positive_onset_dt_tm		= vc
	 2 suspected_onset_dt_tm	= vc
	 2 encntr_ignore			= i2
	 2 hrts_ignore				= i2
	 2 cov_summary_ignore		= i2
	 2 positive_ind				= i2
	 2 suspected_ind			= i2
	 2 ventilator_ind			= i2
	 2 covenant_vent_stock_ind	= i2
	 2 pending_test_ind			= i2
	 2 expired_ind				= i2
	 2 previous_admission_ind	= i2
	 2 previous_onset_ind		= i2
)

free record cov_unit_summary
record cov_unit_summary
(
	1 summary_cnt					= i2
	1 summary_qual[*]           
	 2 facility						= vc
	 2 unit_cnt						= i2
	 2 unit_qual[*]
	  3 unit						= vc
	  3 room_bed_cnt				= i2
	  3 room_bed_qual[*]
	   4 room_bed					= vc
	   4 suspected					= c1
	   4 confirmed					= c1
	1 patient_cnt 				= i2
	1 patient_qual[*]			
	 2 encntr_id				= f8
	 2 person_id				= f8
	 2 patient_name				= vc
	 2 fin						= vc
	 2 facility					= vc
	 2 unit						= vc
	 2 room_bed					= vc
	 2 location_class_1			= vc
	 2 encntr_type				= vc
	 2 pso						= vc
	 2 los_days					= i2
	 2 diagnosis				= vc
	 2 covid19_order			= vc
	 2 covid19_result			= vc
	 2 ventilator_result		= vc
	 2 ventilator_model			= vc
	 2 suspected				= c1
	 2 confirmed				= c1
	 2 ventilator			    = c1
	 2 ventilator_invasive		= c1
	 2 covenant_vent_stock		= c1
	 2 ip_pso					= c1
	 2 expired					= c1
	 2 prev_admission			= c1
	 2 prev_onset				= c1
)


if (program_log->run_from_ops = 0)
	if ($OUTDEV = "OPS")
		set program_log->run_from_ops = 1
		set t_rec->prompt_all_fac_ind = 1
		set t_rec->prompt_report_type = 0
	else
		set t_rec->prompt_all_fac_ind = $ALL_FACILITIES
		set t_rec->prompt_report_type = $REPORT_OPTION
	endif
else
	set t_rec->prompt_all_fac_ind = 1
	set t_rec->prompt_report_type = 0
endif

set t_rec->records_attachment = concat(trim(cnvtlower(curprog)),"_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")

set t_rec->curprog = curprog
set t_rec->curprog = "cov_rpt_op_readiness" ;override for dev script

declare diagnosis = vc with noconstant(" ")
declare facility = vc with noconstant(" ")
declare encntr_id = f8 with noconstant(0.0)

call addEmailLog("chad.cummings@covhlth.com")


select into "nl:"
from
	code_value_set cvs
plan cvs
	    where cvs.definition            = "COVCUSTOM"
order by
	 cvs.definition
	,cvs.updt_dt_tm desc
head report
	call writeLog(build2("->inside code_value_set query"))
head cvs.definition
	t_rec->custom_code_set = cvs.code_set
	call writeLog(build2("-->t_rec->custom_code_set=",trim(cnvtstring(t_rec->custom_code_set))))
with nocounter

if (t_rec->custom_code_set = 0)
	set program_log->display_on_exit = 1
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "CODE_SET"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "CODE_SET"
	set reply->status_data.subeventstatus.targetobjectvalue = "The Custom Code Set was not Found"
	go to exit_script
endif

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("* START Finding Locations **********************************"))
if (t_rec->prompt_all_fac_ind = 1)
	select into "nl:"
	     location = trim(uar_get_code_display(l.location_cd))
	    ,l.location_cd
	from
	     location   l
	    ,organization   o
	    ,code_value cv1
	    ,code_value cv2
	plan cv1
	    where cv1.code_set              = t_rec->custom_code_set
	    and   cv1.definition            = trim(cnvtlower(t_rec->curprog))   
	    and   cv1.active_ind            = 1
	    and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	    and   cv1.end_effective_dt_tm   >= cnvtdatetime(curdate,curtime3)
	    and   cv1.cdf_meaning           = "FACILITY"
	join l 
	    where   l.location_type_cd      = value(uar_get_code_by("MEANING",222,"FACILITY"))
	    and     l.active_ind            = 1
	join cv2
	    where   cv2.code_value          = l.location_cd
	    and     cv2.display             = cv1.display
	join o 
	    where o.organization_id         = l.organization_id
	order by
	    cv2.code_value
	head report
		t_rec->prompt_loc_cnt = 0
		call writeLog(build2("->inside code_value query"))
	head cv2.code_value
		t_rec->prompt_loc_cnt = (t_rec->prompt_loc_cnt + 1)
		stat = alterlist(t_rec->prompt_loc_qual,t_rec->prompt_loc_cnt)
		t_rec->prompt_loc_qual[t_rec->prompt_loc_cnt].location_cd = cv1.code_value
		t_rec->prompt_loc_qual[t_rec->prompt_loc_cnt].location_type_cd = l.location_type_cd
		call writeLog(build2(	 "-->t_rec->prompt_loc_qual[",trim(cnvtstring(t_rec->prompt_loc_cnt)),"].location_cd="
								,trim(cnvtstring(t_rec->prompt_loc_qual[t_rec->prompt_loc_cnt].location_cd))
								,"(",trim(uar_get_code_display(t_rec->prompt_loc_qual[t_rec->prompt_loc_cnt].location_cd)),")"))
	with nocounter
else
	select into "nl:"
	from
		code_value cv1
		,location   l
	plan cv1
		where cv1.code_value = $FACILITY
		and   cv1.code_value > 0.0
		and   cv1.active_ind = 1
	join l
		where l.location_cd = cv1.code_value
		and   l.active_ind	= 1
	order by
		cv1.code_value
	head report
		t_rec->prompt_loc_cnt = 0
		call writeLog(build2("->inside code_value query"))
	head cv1.code_value
		t_rec->prompt_loc_cnt = (t_rec->prompt_loc_cnt + 1)
		stat = alterlist(t_rec->prompt_loc_qual,t_rec->prompt_loc_cnt)
		t_rec->prompt_loc_qual[t_rec->prompt_loc_cnt].location_cd = cv1.code_value
		t_rec->prompt_loc_qual[t_rec->prompt_loc_cnt].location_type_cd = l.location_type_cd
		call writeLog(build2(	 "-->t_rec->prompt_loc_qual[",trim(cnvtstring(t_rec->prompt_loc_cnt)),"].location_cd="
								,trim(cnvtstring(t_rec->prompt_loc_qual[t_rec->prompt_loc_cnt].location_cd))
								,"(",trim(uar_get_code_display(t_rec->prompt_loc_qual[t_rec->prompt_loc_cnt].location_cd)),")"))
	with nocounter
endif

if (t_rec->prompt_loc_cnt = 0)
	set program_log->display_on_exit = 1
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "LOCATIONS"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "FACILITY_CD"
	set reply->status_data.subeventstatus.targetobjectvalue = "No prompt location code values were found"
	go to exit_script
endif

for (i=1 to t_rec->prompt_loc_cnt)
	call writeLog(build2(	 ^AddLocationList("^
							,value(trim(uar_get_code_meaning(t_rec->prompt_loc_qual[i].location_type_cd)))
							,^","^
							,value(trim(uar_get_code_display(t_rec->prompt_loc_qual[i].location_cd)))
							,")"))
	call AddLocationList(
		 value(trim(uar_get_code_meaning(t_rec->prompt_loc_qual[i].location_type_cd)))
		,value(trim(uar_get_code_display(t_rec->prompt_loc_qual[i].location_cd))))
endfor

if (location_list->location_cnt = 0)
	set program_log->display_on_exit = 1
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "LOCATIONS"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "FACILITY_CD"
	set reply->status_data.subeventstatus.targetobjectvalue = "No location code values were found"
	go to exit_script
endif

call writeLog(build2(cnvtrectojson(location_list)))
call writeLog(build2("* END   Finding Locations **********************************"))


call writeLog(build2("* START Finding Location Aliases ***************************"))
select into "nl:"
from
	 code_value_outbound cvo
plan cvo
	where cvo.contributor_source_cd = value(uar_get_code_by("DISPLAY",73,"COVDEV1"))
	and   cvo.code_set = 220
	and   cvo.alias_type_meaning in("NURSEUNIT","FACILITY","AMBULATORY","ROOM","BED")
order by
	 cvo.alias_type_meaning
	,cvo.code_value
head report
	call writeLog(build2("->inside code_value_outbound query"))
head cvo.alias_type_meaning
	call writeLog(build2("-->inside cvo.alias_type_meaning=",trim(cvo.alias_type_meaning)))
head cvo.code_value
	call writeLog(build2("--->found cvo.code_value=",trim(cnvtstring(cvo.code_value))))
	t_rec->location_label_cnt = (t_rec->location_label_cnt + 1)
	stat = alterlist(t_rec->location_label_qual,t_rec->location_label_cnt)
	t_rec->location_label_qual[t_rec->location_label_cnt].location_cd = cvo.code_value
	t_rec->location_label_qual[t_rec->location_label_cnt].display = trim(uar_get_code_display(cvo.code_value))
	t_rec->location_label_qual[t_rec->location_label_cnt].alias_type_meaning = trim(cvo.alias_type_meaning)
	t_rec->location_label_qual[t_rec->location_label_cnt].alias = trim(cvo.alias)
with nocounter

call writeLog(build2("* END   Finding Location Aliases ***************************"))

call writeLog(build2("* START Finding Encounter Types ****************************"))
select into "nl:"
from
     code_value cv1
	,code_value cv2
	,code_value_group cvg
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog)) 
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "ENCNTR_TYPE"
join cvg
	where cvg.parent_code_value		= cv1.code_value
	and   cvg.code_set				= 71
join cv2
	where cv2.code_value			= cvg.child_code_value
order by
	 cv1.description
	,cv2.code_value
head report
	call writeLog(build2("->inside encntr_type query"))
head cv1.description
	call writeLog(build2("-->inside cv1.description=",trim(cv1.description)))
head cv2.code_value
	call writeLog(build2("--->found cv2.code_value=",trim(cnvtstring(cv2.code_value))," (",trim(cv2.display),")"))
	case (cv1.description)
		of "INPATIENT":	t_rec->encntr_type.ip_cnt = (t_rec->encntr_type.ip_cnt + 1)
						stat = alterlist(t_rec->encntr_type.ip_qual,t_rec->encntr_type.ip_cnt)
						t_rec->encntr_type.ip_qual[t_rec->encntr_type.ip_cnt].encntr_type_cd = cv2.code_value
		of "EMERGENCY":	t_rec->encntr_type.ed_cnt = (t_rec->encntr_type.ed_cnt + 1)
						stat = alterlist(t_rec->encntr_type.ed_qual,t_rec->encntr_type.ed_cnt)
						t_rec->encntr_type.ed_qual[t_rec->encntr_type.ed_cnt].encntr_type_cd = cv2.code_value
	endcase
with nocounter

if ((t_rec->encntr_type.ip_cnt = 0) or (t_rec->encntr_type.ed_cnt = 0))
	set program_log->display_on_exit = 1
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "ENCNTR_TYPE"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "ENCNTR_TYPE"
	set reply->status_data.subeventstatus.targetobjectvalue = "The Inpatient encounter types were not found"
	go to exit_script
endif
call writeLog(build2("* END   Finding Encounter Types ****************************"))

call writeLog(build2("* START Finding Order Qualifiers ***************************"))
select into "nl:"
from
     code_value cv1
	,code_value cv2
	,code_value_group cvg
	,order_catalog oc
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog)) 
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "ORDERS"
join cvg
	where cvg.parent_code_value		= cv1.code_value
	and   cvg.code_set				in(200)
join cv2
	where cv2.code_value			= cvg.child_code_value
	and   cv2.active_ind			= 1
join oc	
	where oc.catalog_cd				= cv2.code_value
	and   oc.active_ind				= 1
order by
	 cv1.description
	,cvg.collation_seq
	,cv2.code_value
head report
	call writeLog(build2("->inside order_catalog query"))
head cv1.description
	call writeLog(build2("-->inside cv1.description=",trim(cv1.description)))
head cv2.code_value
	call writeLog(build2("--->found cv2.code_value=",trim(cnvtstring(cv2.code_value))," (",trim(cv2.display),")"))
	case (cv1.description)
		of "COVID19":	t_rec->covid19.covid_oc_cnt = (t_rec->covid19.covid_oc_cnt + 1)
						stat = alterlist(t_rec->covid19.covid_oc_qual,t_rec->covid19.covid_oc_cnt)
						t_rec->covid19.covid_oc_qual[t_rec->covid19.covid_oc_cnt].catalog_cd 		= oc.catalog_cd
						t_rec->covid19.covid_oc_qual[t_rec->covid19.covid_oc_cnt].activity_type_cd	= oc.activity_type_cd
						t_rec->covid19.covid_oc_qual[t_rec->covid19.covid_oc_cnt].catalog_type_cd	= oc.catalog_type_cd
		of "PSOIP":		t_rec->pso.ip_pso_cnt = (t_rec->pso.ip_pso_cnt + 1)
						stat = alterlist(t_rec->pso.ip_pso_qual,t_rec->pso.ip_pso_cnt)
						t_rec->pso.ip_pso_qual[t_rec->pso.ip_pso_cnt].catalog_cd 		= oc.catalog_cd
						t_rec->pso.ip_pso_qual[t_rec->pso.ip_pso_cnt].activity_type_cd 	= oc.activity_type_cd
						t_rec->pso.ip_pso_qual[t_rec->pso.ip_pso_cnt].catalog_type_cd	= oc.catalog_type_cd
		of "PSOOB":		t_rec->pso.ob_pso_cnt = (t_rec->pso.ob_pso_cnt + 1)
						stat = alterlist(t_rec->pso.ob_pso_qual,t_rec->pso.ob_pso_cnt)
						t_rec->pso.ob_pso_qual[t_rec->pso.ob_pso_cnt].catalog_cd 		= oc.catalog_cd
						t_rec->pso.ob_pso_qual[t_rec->pso.ob_pso_cnt].activity_type_cd 	= oc.activity_type_cd
						t_rec->pso.ob_pso_qual[t_rec->pso.ob_pso_cnt].catalog_type_cd	= oc.catalog_type_cd
	endcase
with nocounter

if ((t_rec->pso.ip_pso_cnt = 0) or (t_rec->covid19.covid_oc_cnt = 0))
	set program_log->display_on_exit = 1
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "ORDER_CATALOG"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "ORDER_CATALOG"
	set reply->status_data.subeventstatus.targetobjectvalue = "COVID-19 or PSO Orderables not found"
	go to exit_script
endif

select into "nl:"
from
     code_value cv1
	,code_value cv2
	,code_value_group cvg
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog)) 
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "ORDERS"
join cvg
	where cvg.parent_code_value		= cv1.code_value
	and   cvg.code_set				in(6004)
join cv2
	where cv2.code_value			= cvg.child_code_value
	and   cv2.active_ind			= 1
order by
	 cv1.description
	,cvg.collation_seq
	,cv2.code_value
head report
	call writeLog(build2("->inside order_status query"))
head cv1.description
	call writeLog(build2("-->inside cv1.description=",trim(cv1.description)))
head cv2.code_value
	call writeLog(build2("--->found cv2.code_value=",trim(cnvtstring(cv2.code_value))," (",trim(cv2.display),")"))
	case (cv1.description)
		of "COVID19":	t_rec->covid19.covid_status_cnt = (t_rec->covid19.covid_status_cnt + 1)
						stat = alterlist(t_rec->covid19.covid_status_qual,t_rec->covid19.covid_status_cnt)
						t_rec->covid19.covid_status_qual[t_rec->covid19.covid_status_cnt].order_status_cd 		= cv2.code_value
		of "PSOIP":		t_rec->pso.ip_pso_status_cnt = (t_rec->pso.ip_pso_status_cnt + 1)
						stat = alterlist(t_rec->pso.ip_pso_status_qual,t_rec->pso.ip_pso_status_cnt)
						t_rec->pso.ip_pso_status_qual[t_rec->pso.ip_pso_status_cnt].order_status_cd 			= cv2.code_value
		of "PSOOB":		t_rec->pso.ob_pso_status_cnt = (t_rec->pso.ob_pso_status_cnt + 1)
						stat = alterlist(t_rec->pso.ob_pso_status_qual,t_rec->pso.ob_pso_status_cnt)
						t_rec->pso.ob_pso_status_qual[t_rec->pso.ob_pso_status_cnt].order_status_cd 			= cv2.code_value
	endcase
with nocounter

if ((t_rec->pso.ip_pso_cnt = 0) or (t_rec->covid19.covid_oc_cnt = 0))
	set program_log->display_on_exit = 1
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "CODE_VALUE"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "CODE_VALUE"
	set reply->status_data.subeventstatus.targetobjectvalue = "Order Status not found"
	go to exit_script
endif

call writeLog(build2("* END   Finding Order Qualifiers ***************************"))

call writeLog(build2("* START Finding Order Disqualifiers *************************"))
select into "nl:"
from
     code_value cv1
	,code_value cv2
	,code_value cv3
	,code_value_group cvg
	,code_value_group cvb
	,code_value_extension cve
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog)) 
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "ORDERS"
join cvg
	where cvg.parent_code_value		= cv1.code_value
	and   cvg.code_set				= t_rec->custom_code_set
join cvb
	where cvb.parent_code_value		= cvg.child_code_value
join cv2
	where cv2.code_value			= cvg.child_code_value
	and   cv2.active_ind			= 1
join cv3
	where cv3.code_value			= cvb.child_code_value
	and   cv3.active_ind			= 1
join cve
	where cve.code_value			= cv2.code_value
	and   cve.field_name			= "OE_FIELD_ID"
order by
	 cv1.description
	,cvg.collation_seq
	,cv2.code_value
	,cvb.collation_seq
	,cv3.code_value
head report
	call writeLog(build2("->inside order_entry query"))
head cv2.code_value
	call writeLog(build2("-->looking at oe_field_id=",trim(cnvtstring(cve.field_value))," for ",trim(cv2.display)))
head cv3.code_value
	call writeLog(build2("---->adding code_value=",trim(cnvtstring(cv3.code_value))," (",trim(cv3.display),")"))
	t_rec->covid19.covid_ignore_cnt = (t_rec->covid19.covid_ignore_cnt + 1)
	stat = alterlist(t_rec->covid19.covid_ignore_qual,t_rec->covid19.covid_ignore_cnt)
	t_rec->covid19.covid_ignore_qual[t_rec->covid19.covid_ignore_cnt].oe_field_id			= cnvtreal(cve.field_value)
	t_rec->covid19.covid_ignore_qual[t_rec->covid19.covid_ignore_cnt].oe_field_value		= cv3.code_value	
	t_rec->covid19.covid_ignore_qual[t_rec->covid19.covid_ignore_cnt].oe_field_value_display= cv3.display
with nocounter
call writeLog(build2("* END   Finding Order Disqualifiers *************************"))

call writeLog(build2("* START Finding Result Qualifiers **************************"))
/*
select into "nl:"
from	
	 (dummyt d1 with seq=t_rec->covid19.covid_oc_cnt)
	,order_catalog oc
	,profile_task_r ptr
	,discrete_task_assay dta
	,code_value_event_r cver
	,code_value cv
plan d1
join oc
	where oc.catalog_cd = t_rec->covid19.covid_oc_qual[d1.seq].catalog_cd
join ptr
	where ptr.catalog_cd = oc.catalog_cd
	and   ptr.active_ind = 1
join cver
	where cver.parent_cd = ptr.task_assay_cd
join dta 
	where dta.task_assay_cd = ptr.task_assay_cd
join cv
	where cv.code_value = cver.event_cd
order by
	 oc.catalog_cd
	,dta.task_assay_cd
	,cv.code_value
head report
	call writeLog(build2("->inside profile_task query"))
head oc.catalog_cd
	call writeLog(build2("-->inside oc.catalog_cd=",trim(cnvtstring(oc.catalog_cd))
		," (",trim(uar_get_code_display(oc.catalog_cd)),")"))
head dta.task_assay_cd
	call writeLog(build2("--->inside dta.task_assay_cd=",trim(cnvtstring(dta.task_assay_cd))
		," (",trim(dta.description),")"))
head cv.code_value
	call writeLog(build2("---->found cv.code_value=",trim(cnvtstring(cv.code_value))
		," (",trim(cv.display),")"))
	t_rec->covid19.result_cnt = (t_rec->covid19.result_cnt + 1)
	stat = alterlist(t_rec->covid19.result_qual,t_rec->covid19.result_cnt)
	t_rec->covid19.result_qual[t_rec->covid19.result_cnt].event_cd = cv.code_value
with nocounter
*/

select into "nl:"
from
     code_value cv1
	,code_value cv2
	,code_value_group cvg
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog)) 
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "EVENT_CODE"
join cvg
	where cvg.parent_code_value		= cv1.code_value
	and   cvg.code_set				in(72)
join cv2
	where cv2.code_value			= cvg.child_code_value
	and   cv2.active_ind			= 1
order by
	 cv1.description
	,cvg.collation_seq
	,cv2.code_value
head report
	call writeLog(build2("->inside event_code query"))
head cv1.description
	call writeLog(build2("-->inside cv1.description=",trim(cv1.description)))
head cv2.code_value
	call writeLog(build2("--->found cv2.code_value=",trim(cnvtstring(cv2.code_value))," (",trim(cv2.display),")"))
	case (cv1.description)
		of "COVID19":
						t_rec->covid19.result_cnt = (t_rec->covid19.result_cnt + 1)
						stat = alterlist(t_rec->covid19.result_qual,t_rec->covid19.result_cnt)
						t_rec->covid19.result_qual[t_rec->covid19.result_cnt].event_cd = cv2.code_value	
	endcase
with nocounter

select into "nl:"
from
     code_value cv1
	,code_value cv2
	,code_value_group cvg
	,code_value_extension cve1
	,code_value_extension cve2
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog)) 
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "VENTILATOR"
join cvg
	where cvg.parent_code_value		= cv1.code_value
	and   cvg.code_set				in(72)
join cv2
	where cv2.code_value			= cvg.child_code_value
	and   cv2.active_ind			= 1
join cve1
	where cve1.code_value			= outerjoin(cv1.code_value)
	and   cve1.field_name			= outerjoin("LOOKBACK_HRS")
join cve2
	where cve2.code_value			= outerjoin(cv1.code_value)
	and   cve2.field_name			= outerjoin("VENT_TYPE")
order by
	 cv1.description
	,cvg.collation_seq
	,cv2.code_value
head report
	call writeLog(build2("->inside ventilator query"))
head cv1.description
	call writeLog(build2("-->inside cv1.description=",trim(cv1.description)))
head cv2.code_value
	call writeLog(build2("--->found cv2.code_value=",trim(cnvtstring(cv2.code_value))," (",trim(cv2.display),")"))
	call writeLog(build2("--->found cve1.field_value=",trim(cnvtstring(cve1.field_value))," (",trim(cve1.field_value),")"))
	case (cv1.description)
		of "ACTIVITY":
			t_rec->vent.result_cnt = (t_rec->vent.result_cnt + 1)
			stat = alterlist(t_rec->vent.result_qual,t_rec->vent.result_cnt)
			t_rec->vent.result_qual[t_rec->vent.result_cnt].event_cd = cv2.code_value
			t_rec->vent.result_qual[t_rec->vent.result_cnt].lookback_hrs = cnvtint(cve1.field_value)
			t_rec->vent.result_qual[t_rec->vent.result_cnt].vent_type = substring(1,1,cve2.field_value)
		of "MODEL":
			t_rec->vent.model_cnt = (t_rec->vent.model_cnt + 1)
			stat = alterlist(t_rec->vent.model_qual,t_rec->vent.model_cnt)
			t_rec->vent.model_qual[t_rec->vent.model_cnt].event_cd = cv2.code_value
			t_rec->vent.model_qual[t_rec->vent.model_cnt].vent_type = substring(1,1,cve2.field_value)
	endcase
with nocounter

if (t_rec->vent.result_cnt = 0)
	set program_log->display_on_exit = 1
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "CODE_VALUE"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "EVENT_CD"
	set reply->status_data.subeventstatus.targetobjectvalue = "Vent Event Codes not found"
	go to exit_script
endif

call writeLog(build2("* END   Finding Result Qualifiers **************************"))

call writeLog(build2("* START Finding Diagnosis Qualifiers ************************"))
select into "nl:"
from
     code_value cv1
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog)) 
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "DIAGNOSIS"
order by
	cv1.code_value
head report
	call writeLog(build2("->inside diagnosis code_value query"))
head cv1.code_value
	call writeLog(build2("-->found cv1.code_value=",trim(cnvtstring(cv1.code_value))," (",trim(cv1.display),")"))
	call writeLog(build2("--->found cv1.description=",trim(cv1.description)))
	t_rec->diagnosis_search_cnt = (t_rec->diagnosis_search_cnt + 1)
	stat = alterlist(t_rec->diagnosis_search_qual,t_rec->diagnosis_search_cnt)
	t_rec->diagnosis_search_qual[t_rec->diagnosis_search_cnt].search_description = cv1.description
foot cv1.code_value
	call writeLog(build2("--->parsing cv1.description=",trim(cv1.description)))
	call writeLog(build2("---->piece 1=",trim(piece(cv1.description,"|",1,notfnd))))
	if (piece(cv1.description,"|",1,notfnd) != notfnd)
		t_rec->diagnosis_search_qual[t_rec->diagnosis_search_cnt].search_string = trim(cnvtupper(piece(cv1.description,"|",1,notfnd)))
		pos = 1
		str = ""
		call writeLog(build2("---->piece 2=",trim(piece(cv1.description,"|",2,notfnd))))
		while (str != notfnd)
			str = piece(piece(cv1.description,"|",2,notfnd),',',pos,notfnd)
			if (str != notfnd)
				call writeLog(build2("----->vocab ",trim(cnvtstring(pos))," =",trim(str)))
				t_rec->diagnosis_search_qual[t_rec->diagnosis_search_cnt].source_vocabulary_cnt = 
					(t_rec->diagnosis_search_qual[t_rec->diagnosis_search_cnt].source_vocabulary_cnt + 1)
				stat = alterlist(t_rec->diagnosis_search_qual[t_rec->diagnosis_search_cnt].source_vocabulary_qual,
					t_rec->diagnosis_search_qual[t_rec->diagnosis_search_cnt].source_vocabulary_cnt)
				t_rec->diagnosis_search_qual[t_rec->diagnosis_search_cnt].source_vocabulary_qual[
					t_rec->diagnosis_search_qual[t_rec->diagnosis_search_cnt].source_vocabulary_cnt].display = trim(str,3)
				t_rec->diagnosis_search_qual[t_rec->diagnosis_search_cnt].source_vocabulary_qual[
					t_rec->diagnosis_search_qual[t_rec->diagnosis_search_cnt].source_vocabulary_cnt].source_vocabulary_cd = 
						uar_get_code_by("DISPLAY",400,trim(str,3))
			endif
			pos = pos+1
		endwhile
	endif
with nocounter

call writeLog(build2("** Finding Vocabularies ************************"))
for (i=1 to t_rec->diagnosis_search_cnt)
	if (t_rec->diagnosis_search_qual[i].search_string > " ")
		for	(j=1 to t_rec->diagnosis_search_qual[i].source_vocabulary_cnt)
			if (t_rec->diagnosis_search_qual[i].source_vocabulary_qual[j].source_vocabulary_cd > 0.0)
			select into "nl:"
			from
				nomenclature n
			plan n
				where n.source_vocabulary_cd = t_rec->diagnosis_search_qual[i].source_vocabulary_qual[j].source_vocabulary_cd
				and   n.active_ind = 1
				and   cnvtdatetime(curdate,curtime3) between n.beg_effective_dt_tm and n.end_effective_dt_tm
				and   n.source_string_keycap = patstring(concat("*",t_rec->diagnosis_search_qual[i].search_string,"*"))
			order by
				n.nomenclature_id
			head report
				call writeLog(build2("->inside nomenclature ",trim(uar_get_code_display(n.source_vocabulary_cd))
					," for ",trim(t_rec->diagnosis_search_qual[i].search_string)))
			head n.nomenclature_id
				call writeLog(build2("-->adding nomen ",trim(n.source_string)," (",trim(n.source_identifier),")"
								 ," [",trim(cnvtstring(n.nomenclature_id)),"]"))			
				t_rec->diagnosis_cnt = (t_rec->diagnosis_cnt + 1)
				stat = alterlist(t_rec->diagnosis_qual,t_rec->diagnosis_cnt)
				t_rec->diagnosis_qual[t_rec->diagnosis_cnt].nomenclature_id 		= n.nomenclature_id
				t_rec->diagnosis_qual[t_rec->diagnosis_cnt].source_string 			= n.source_string
				t_rec->diagnosis_qual[t_rec->diagnosis_cnt].source_vocabulary_cd 	= n.source_vocabulary_cd
			with nocounter
			endif
		endfor
	endif
endfor
call writeLog(build2("** Finished Vocabularies ************************"))
call writeLog(build2("* END   Finding Diagnosis Qualifiers ************************"))

call writeLog(build2("* START Finding Positive Result Qualifiers ******************"))
select into "nl:"
from
     code_value cv1
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog)) 
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "RESPONSE"
order by
	 cv1.code_value
head report
	call writeLog(build2("->inside response code_value query"))
head cv1.code_value
	call writeLog(build2("-->found cv1.code_value=",trim(cnvtstring(cv1.code_value))," (",trim(cv1.display),")"))
	call writeLog(build2("--->parsing cv1.description=",trim(cv1.description)))
	pos = 1
	str = " "
	while (str != notfnd)
		call writeLog(build2("---->checking ",trim(cnvtstring(pos))))
		str = piece(cv1.description,',',pos,notfnd)
		call writeLog(build2("---->got ",trim(str)))
		if (str != notfnd)
			if (str > " ")
				t_rec->covid19.positive_cnt = (t_rec->covid19.positive_cnt + 1)
				stat = alterlist(t_rec->covid19.positive_qual,t_rec->covid19.positive_cnt)
				call writeLog(build2("----->term ",trim(cnvtstring(pos))," =",trim(str)))
				t_rec->covid19.positive_qual[t_rec->covid19.positive_cnt].result_val = trim(str,3)
			endif
		endif
		pos = pos+1
	endwhile

with nocounter
call writeLog(build2("* END   Finding Positive Result Qualifiers ******************"))

call writeLog(build2("* START Finding Ventilator Stock Qualifiers *****************"))
select into "nl:"
from
     code_value cv1
	,code_value cv2
	,code_value_group cvg
	,code_value_extension cve
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog)) 
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "STOCK"
join cvg
	where cvg.parent_code_value		= cv1.code_value
	and   cvg.code_set				= t_rec->custom_code_set
join cv2
	where cv2.code_value			= cvg.child_code_value
	and   cv2.active_ind			= 1
join cve
	where cve.code_value			= outerjoin(cv2.code_value)
	and   cve.field_name			= outerjoin("VENT_TYPE")
order by
	 cv1.description
	,cvg.collation_seq
	,cv2.code_value
head report
	call writeLog(build2("->inside stock query"))
head cv1.description
	call writeLog(build2("-->inside cv1.description=",trim(cv1.description)))
head cv2.code_value
	call writeLog(build2("--->found cv2.code_value=",trim(cnvtstring(cv2.code_value))," (",trim(cv2.display),")"))
	case (cv1.description)
		of "VENTILATOR":
						t_rec->vent.stock_cnt = (t_rec->vent.stock_cnt + 1)
						stat = alterlist(t_rec->vent.stock_qual,t_rec->vent.stock_cnt)
						t_rec->vent.stock_qual[t_rec->vent.stock_cnt].model_name = cv2.display
						t_rec->vent.stock_qual[t_rec->vent.stock_cnt].vent_type = substring(1,1,cve.field_value)
		
	endcase
with nocounter


call writeLog(build2("* END   Finding Ventilator Stock Qualifiers *****************"))

call writeLog(build2("* START Finding Expired Patient Lookback ********************"))
select into "nl:"
from
      code_value cv1
     ,code_value_extension cve
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog)) 
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "EXPIRED"
join cve
	where cve.code_value			= outerjoin(cv1.code_value)
	and   cve.field_name			= outerjoin("LOOKBACK_HRS")
order by
	  cv1.description
	 ,cv1.code_value
	 ,cve.field_name
head report
	call writeLog(build2("->inside expired code_value query"))
head cv1.description
	call writeLog(build2("-->inside cv1.description=",trim(cv1.description)))
head cv1.code_value
	call writeLog(build2("--->found cv1.code_value=",trim(cnvtstring(cv1.code_value))," (",trim(cv1.display),")"))
head cve.field_name	
	call writeLog(build2("---->found cve.field_name=",trim(cve.field_name)," (",trim(cve.field_value),")"))
	if (cv1.description = "COVID19")
		if (cnvtint(cve.field_value) > 0)
			t_rec->covid19.expired_lookback_ind = 1
			t_rec->covid19.expired_lookback_hours = cnvtint(cve.field_value)
		endif
	endif
foot cve.field_name
	row +0
foot cv1.code_value
	row +0
foot cv1.description
	row +0
foot report
	row +0
with nocounter

if (t_rec->covid19.expired_lookback_ind = 1)
	set t_rec->covid19.expired_start_dt_tm 	= cnvtlookbehind(
																build(t_rec->covid19.expired_lookback_hours, ",", "H"),
																cnvtdatetime(curdate,curtime3))
	set t_rec->covid19.expired_end_dt_tm 	= cnvtdatetime(curdate,curtime3)
else
	set t_rec->covid19.expired_start_dt_tm = datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'B', 'B')
	set t_rec->covid19.expired_end_dt_tm = datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'E', 'E')
endif
call writeLog(build2("* START Finding Expired Patient Lookback ********************"))

call writeLog(build2("* START Finding Previous Admission **************************"))
select into "nl:"
from
      code_value cv1
     ,code_value_extension cve
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog)) 
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "ADMISSION"
join cve
	where cve.code_value			= outerjoin(cv1.code_value)
	and   cve.field_name			= outerjoin("LOOKBACK_HRS")
order by
	  cv1.description
	 ,cv1.code_value
	 ,cve.field_name
head report
	call writeLog(build2("->inside expired code_value query"))
head cv1.description
	call writeLog(build2("-->inside cv1.description=",trim(cv1.description)))
head cv1.code_value
	call writeLog(build2("--->found cv1.code_value=",trim(cnvtstring(cv1.code_value))," (",trim(cv1.display),")"))
head cve.field_name	
	call writeLog(build2("---->found cve.field_name=",trim(cve.field_name)," (",trim(cve.field_value),")"))
	if (cv1.description = "COVID19")
		if (cnvtint(cve.field_value) > 0)
			t_rec->covid19.admission_lookback_ind = 1
			t_rec->covid19.admission_lookback_hours = cnvtint(cve.field_value)
		endif
	endif
foot cve.field_name
	row +0
foot cv1.code_value
	row +0
foot cv1.description
	row +0
foot report
	row +0
with nocounter

if (t_rec->covid19.admission_lookback_ind = 1)
	set t_rec->covid19.admission_start_dt_tm 	= cnvtlookbehind(
																build(t_rec->covid19.expired_lookback_hours, ",", "H"),
																cnvtdatetime(curdate,curtime3))
	set t_rec->covid19.admission_end_dt_tm 	= cnvtdatetime(curdate,curtime3)
else
	set t_rec->covid19.admission_start_dt_tm = datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'B', 'B')
	set t_rec->covid19.admission_end_dt_tm = datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'E', 'E')
endif
call writeLog(build2("* END   Finding Previous Admission **************************"))

call writeLog(build2("* START Finding Previous Onset ******************************"))
select into "nl:"
from
      code_value cv1
     ,code_value_extension cve
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog)) 
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "ONSET"
join cve
	where cve.code_value			= outerjoin(cv1.code_value)
	and   cve.field_name			= outerjoin("LOOKBACK_HRS")
order by
	  cv1.description
	 ,cv1.code_value
	 ,cve.field_name
head report
	call writeLog(build2("->inside expired code_value query"))
head cv1.description
	call writeLog(build2("-->inside cv1.description=",trim(cv1.description)))
head cv1.code_value
	call writeLog(build2("--->found cv1.code_value=",trim(cnvtstring(cv1.code_value))," (",trim(cv1.display),")"))
head cve.field_name	
	call writeLog(build2("---->found cve.field_name=",trim(cve.field_name)," (",trim(cve.field_value),")"))
	if (cv1.description = "COVID19")
		if (cnvtint(cve.field_value) > 0)
			t_rec->covid19.onset_lookback_ind = 1
			t_rec->covid19.onset_lookback_hours = cnvtint(cve.field_value)
		endif
	endif
foot cve.field_name
	row +0
foot cv1.code_value
	row +0
foot cv1.description
	row +0
foot report
	row +0
with nocounter

if (t_rec->covid19.onset_lookback_ind = 1)
	set t_rec->covid19.onset_start_dt_tm 	= cnvtlookbehind(
																build(t_rec->covid19.expired_lookback_hours, ",", "H"),
																cnvtdatetime(curdate,curtime3))
	set t_rec->covid19.onset_end_dt_tm 		= cnvtdatetime(curdate,curtime3)
else
	set t_rec->covid19.onset_start_dt_tm 	= datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'B', 'B')
	set t_rec->covid19.onset_end_dt_tm 		= datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'E', 'E')
endif
call writeLog(build2("* END   Finding Previous Onset *****************************"))

call writeLog(build2("* START Finding Encounter Domain Patients ******************"))
select into "nl:"
from
	 encntr_domain ed
	,encounter e
	,person p
plan ed	
	where expand(i,1,location_list->location_cnt,ed.loc_facility_cd,location_list->locations[i].location_cd)
	and   ed.active_ind = 1
	and   ed.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00")
	and   ed.encntr_domain_type_cd = value(uar_get_code_by("MEANING",339,"CENSUS"))
join e
	where e.encntr_id = ed.encntr_id
	and	  (
				(expand(j,1,t_rec->encntr_type.ip_cnt,e.encntr_type_cd,t_rec->encntr_type.ip_qual[j].encntr_type_cd))
			or
				(expand(j,1,t_rec->encntr_type.ed_cnt,e.encntr_type_cd,t_rec->encntr_type.ed_qual[j].encntr_type_cd))
		   )
join p
	where p.person_id = e.person_id
	and   p.name_last_key not in(
									 "ZZZTEST"
									,"TTTEST"
									,"TTTTEST"
									,"TTTTMAYO"
									,"TTTTTEST"
									,"FFFFOP"
									,"TTTTGENLAB"
									,"TTTTQUEST"			
								)
order by
	 e.loc_facility_cd
	,e.person_id
	,e.encntr_id
head report
	call writeLog(build2("->Inside encntr_domain query"))
head e.encntr_id
	t_rec->patient_cnt = (t_rec->patient_cnt + 1)
	stat = alterlist(t_rec->patient_qual,t_rec->patient_cnt)
	t_rec->patient_qual[t_rec->patient_cnt].encntr_id 				= e.encntr_id
	t_rec->patient_qual[t_rec->patient_cnt].person_id				= e.person_id
	t_rec->patient_qual[t_rec->patient_cnt].loc_facility_cd			= e.loc_facility_cd
	t_rec->patient_qual[t_rec->patient_cnt].loc_unit_cd				= e.loc_nurse_unit_cd
	t_rec->patient_qual[t_rec->patient_cnt].loc_room_cd				= e.loc_room_cd
	t_rec->patient_qual[t_rec->patient_cnt].loc_bed_cd				= e.loc_bed_cd
	t_rec->patient_qual[t_rec->patient_cnt].encntr_type_cd			= e.encntr_type_cd
	t_rec->patient_qual[t_rec->patient_cnt].reg_dt_tm				= e.reg_dt_tm
	t_rec->patient_qual[t_rec->patient_cnt].inpatient_dt_tm			= e.inpatient_admit_dt_tm
	t_rec->patient_qual[t_rec->patient_cnt].arrive_dt_tm			= e.arrive_dt_tm
	t_rec->patient_qual[t_rec->patient_cnt].disch_dt_tm				= e.disch_dt_tm
	t_rec->patient_qual[t_rec->patient_cnt].expired_dt_tm			= p.deceased_dt_tm
	t_rec->patient_qual[t_rec->patient_cnt].dob						= cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1)
	t_rec->patient_qual[t_rec->patient_cnt].ip_los_hours			= datetimediff(sysdate,e.inpatient_admit_dt_tm,3)
	t_rec->patient_qual[t_rec->patient_cnt].ip_los_days				= datetimediff(sysdate,e.inpatient_admit_dt_tm,1)
	t_rec->patient_qual[t_rec->patient_cnt].name_full_formatted		= p.name_full_formatted
	
	call writeLog(build2(	 "-->t_rec->patient_qual[",trim(cnvtstring(t_rec->patient_cnt)),"].person_id="
								,trim(cnvtstring(t_rec->patient_qual[t_rec->patient_cnt].person_id))))
	call writeLog(build2(	 "-->t_rec->patient_qual[",trim(cnvtstring(t_rec->patient_cnt)),"].encntr_id="
								,trim(cnvtstring(t_rec->patient_qual[t_rec->patient_cnt].encntr_id))))
	call writeLog(build2(	 "-->t_rec->patient_qual[",trim(cnvtstring(t_rec->patient_cnt)),"].loc_facility_cd="
								,trim(cnvtstring(t_rec->patient_qual[t_rec->patient_cnt].loc_facility_cd))							
								,"(",trim(uar_get_code_display(t_rec->patient_qual[t_rec->patient_cnt].loc_facility_cd)),")"))
	call writeLog(build2(	 "-->t_rec->patient_qual[",trim(cnvtstring(t_rec->patient_cnt)),"].loc_unit_cd="
								,trim(cnvtstring(t_rec->patient_qual[t_rec->patient_cnt].loc_unit_cd))							
								,"(",trim(uar_get_code_display(t_rec->patient_qual[t_rec->patient_cnt].loc_unit_cd)),")"))
	call writeLog(build2(	 "-->t_rec->patient_qual[",trim(cnvtstring(t_rec->patient_cnt)),"].encntr_type_cd="
								,trim(cnvtstring(t_rec->patient_qual[t_rec->patient_cnt].encntr_type_cd))							
								,"(",trim(uar_get_code_display(t_rec->patient_qual[t_rec->patient_cnt].encntr_type_cd)),")"))
	pos = 0
	stat = 0
	;Start with Bed
	pos = locateval(j,1,t_rec->location_label_cnt,t_rec->patient_qual[t_rec->patient_cnt].loc_bed_cd
						,t_rec->location_label_qual[j].location_cd)
	if (pos > 0)
		t_rec->patient_qual[t_rec->patient_cnt].loc_class_1 = t_rec->location_label_qual[pos].alias
	else
		;Check Room
		pos = locateval(j,1,t_rec->location_label_cnt,t_rec->patient_qual[t_rec->patient_cnt].loc_room_cd
							,t_rec->location_label_qual[j].location_cd)
		if (pos > 0)
			t_rec->patient_qual[i].loc_class_1 = t_rec->location_label_qual[pos].alias
		else
			;Check unit
			pos = locateval(j,1,t_rec->location_label_cnt,t_rec->patient_qual[t_rec->patient_cnt].loc_unit_cd
							,t_rec->location_label_qual[j].location_cd)
			if (pos > 0)
				t_rec->patient_qual[t_rec->patient_cnt].loc_class_1 = t_rec->location_label_qual[pos].alias
			else
				t_rec->patient_qual[t_rec->patient_cnt].loc_class_1 = "NA"
			endif
		endif
	endif
with nocounter

if (t_rec->patient_cnt = 0)
	set program_log->display_on_exit = 1
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "ENCNTR_DOMAIN"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "ENCNTR_DOMAIN"
	set reply->status_data.subeventstatus.targetobjectvalue = "No Patients found for parameters"
	go to exit_script
endif

call writeLog(build2("* END   Finding Encounter Domain Patients ******************"))


call writeLog(build2("* START Finding Expired Patients ***************************"))
select into "nl:"
from
	 encounter e
	,person p
plan e
	where expand(i,1,location_list->location_cnt,e.loc_facility_cd,location_list->locations[i].location_cd)
	and	  (
				(expand(j,1,t_rec->encntr_type.ip_cnt,e.encntr_type_cd,t_rec->encntr_type.ip_qual[j].encntr_type_cd))
			or
				(expand(j,1,t_rec->encntr_type.ed_cnt,e.encntr_type_cd,t_rec->encntr_type.ed_qual[j].encntr_type_cd))
		   )
	and e.disch_disposition_cd in(
									 value(uar_get_code_by("DISPLAY",19,"Expired (Hospice Claims Only) 41"))
 									,value(uar_get_code_by("MEANING",19,"EXPIRED"))
 								  )
	and e.data_status_cd 	in(
									 value(uar_get_code_by("MEANING",8,"AUTH"))
 									,value(uar_get_code_by("MEANING",8,"MODIFIED"))
 							  )
	;and e.exp <= cnvtdatetime(t_rec->covid19.expired_end_dt_tm)
	and e.active_ind = 1
join p
	where p.person_id = e.person_id
	and   p.name_last_key not in(
									 "ZZZTEST"
									,"TTTEST"
									,"TTTTEST"
									,"TTTTMAYO"
									,"TTTTTEST"
									,"FFFFOP"
									,"TTTTGENLAB"
									,"TTTTQUEST"			
								)
	and   p.deceased_dt_tm between cnvtdatetime(t_rec->covid19.expired_start_dt_tm) and cnvtdatetime(t_rec->covid19.expired_end_dt_tm)
order by
	 e.loc_facility_cd
	,e.person_id
	,e.encntr_id
head report
	call writeLog(build2("->Inside expired patients query"))
head e.encntr_id
	t_rec->patient_cnt = (t_rec->patient_cnt + 1)
	stat = alterlist(t_rec->patient_qual,t_rec->patient_cnt)
	t_rec->patient_qual[t_rec->patient_cnt].encntr_id 				= e.encntr_id
	t_rec->patient_qual[t_rec->patient_cnt].person_id				= e.person_id
	t_rec->patient_qual[t_rec->patient_cnt].loc_facility_cd			= e.loc_facility_cd
	t_rec->patient_qual[t_rec->patient_cnt].loc_unit_cd				= e.loc_nurse_unit_cd
	t_rec->patient_qual[t_rec->patient_cnt].loc_room_cd				= e.loc_room_cd
	t_rec->patient_qual[t_rec->patient_cnt].loc_bed_cd				= e.loc_bed_cd
	t_rec->patient_qual[t_rec->patient_cnt].encntr_type_cd			= e.encntr_type_cd
	t_rec->patient_qual[t_rec->patient_cnt].reg_dt_tm				= e.reg_dt_tm
	t_rec->patient_qual[t_rec->patient_cnt].inpatient_dt_tm			= e.inpatient_admit_dt_tm
	t_rec->patient_qual[t_rec->patient_cnt].arrive_dt_tm			= e.arrive_dt_tm
	t_rec->patient_qual[t_rec->patient_cnt].disch_dt_tm				= e.disch_dt_tm
	t_rec->patient_qual[t_rec->patient_cnt].expired_dt_tm			= p.deceased_dt_tm
	t_rec->patient_qual[t_rec->patient_cnt].dob						= cnvtdatetimeutc(datetimezone(p.birth_dt_tm,p.birth_tz),1)
	t_rec->patient_qual[t_rec->patient_cnt].ip_los_hours			= datetimediff(e.disch_dt_tm,e.inpatient_admit_dt_tm,3)
	t_rec->patient_qual[t_rec->patient_cnt].ip_los_days				= datetimediff(e.disch_dt_tm,e.inpatient_admit_dt_tm,1)
	t_rec->patient_qual[t_rec->patient_cnt].name_full_formatted		= p.name_full_formatted
	t_rec->patient_qual[t_rec->patient_cnt].expired_ind				= 1
	
	call writeLog(build2(	 "-->t_rec->patient_qual[",trim(cnvtstring(t_rec->patient_cnt)),"].person_id="
								,trim(cnvtstring(t_rec->patient_qual[t_rec->patient_cnt].person_id))))
	call writeLog(build2(	 "-->t_rec->patient_qual[",trim(cnvtstring(t_rec->patient_cnt)),"].encntr_id="
								,trim(cnvtstring(t_rec->patient_qual[t_rec->patient_cnt].encntr_id))))
	call writeLog(build2(	 "-->t_rec->patient_qual[",trim(cnvtstring(t_rec->patient_cnt)),"].loc_facility_cd="
								,trim(cnvtstring(t_rec->patient_qual[t_rec->patient_cnt].loc_facility_cd))							
								,"(",trim(uar_get_code_display(t_rec->patient_qual[t_rec->patient_cnt].loc_facility_cd)),")"))
	call writeLog(build2(	 "-->t_rec->patient_qual[",trim(cnvtstring(t_rec->patient_cnt)),"].loc_unit_cd="
								,trim(cnvtstring(t_rec->patient_qual[t_rec->patient_cnt].loc_unit_cd))							
								,"(",trim(uar_get_code_display(t_rec->patient_qual[t_rec->patient_cnt].loc_unit_cd)),")"))
	call writeLog(build2(	 "-->t_rec->patient_qual[",trim(cnvtstring(t_rec->patient_cnt)),"].encntr_type_cd="
								,trim(cnvtstring(t_rec->patient_qual[t_rec->patient_cnt].encntr_type_cd))							
								,"(",trim(uar_get_code_display(t_rec->patient_qual[t_rec->patient_cnt].encntr_type_cd)),")"))
	pos = 0
	stat = 0
	;Start with Bed
	pos = locateval(j,1,t_rec->location_label_cnt,t_rec->patient_qual[t_rec->patient_cnt].loc_bed_cd
						,t_rec->location_label_qual[j].location_cd)
	if (pos > 0)
		t_rec->patient_qual[t_rec->patient_cnt].loc_class_1 = t_rec->location_label_qual[pos].alias
	else
		;Check Room
		pos = locateval(j,1,t_rec->location_label_cnt,t_rec->patient_qual[t_rec->patient_cnt].loc_room_cd
							,t_rec->location_label_qual[j].location_cd)
		if (pos > 0)
			t_rec->patient_qual[i].loc_class_1 = t_rec->location_label_qual[pos].alias
		else
			;Check unit
			pos = locateval(j,1,t_rec->location_label_cnt,t_rec->patient_qual[t_rec->patient_cnt].loc_unit_cd
							,t_rec->location_label_qual[j].location_cd)
			if (pos > 0)
				t_rec->patient_qual[t_rec->patient_cnt].loc_class_1 = t_rec->location_label_qual[pos].alias
			else
				t_rec->patient_qual[t_rec->patient_cnt].loc_class_1 = "NA"
			endif
		endif
	endif
with nocounter
call writeLog(build2("* END   Finding Expired Patients ***************************"))


call writeLog(build2("* START Finding Patient Orders *****************************"))
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->patient_cnt)
	,orders o
plan d1
	where t_rec->patient_qual[d1.seq].expired_ind = 0
join o
	where o.encntr_id = t_rec->patient_qual[d1.seq].encntr_id
	and   o.person_id = t_rec->patient_qual[d1.seq].person_id
	
	and	(
		 (		 expand(i,1,t_rec->pso.ip_pso_cnt			,o.catalog_cd		,t_rec->pso.ip_pso_qual[i].catalog_cd)
			and  expand(i,1,t_rec->pso.ip_pso_status_cnt	,o.order_status_cd	,t_rec->pso.ip_pso_status_qual[i].order_status_cd)		 
		 )
	   or
	     (		 expand(i,1,t_rec->pso.ob_pso_cnt			,o.catalog_cd		,t_rec->pso.ob_pso_qual[i].catalog_cd)
			and  expand(i,1,t_rec->pso.ob_pso_status_cnt	,o.order_status_cd	,t_rec->pso.ob_pso_status_qual[i].order_status_cd)		 
		  )
	   or	
	     ( 			expand(i,1,t_rec->covid19.covid_oc_cnt		,o.catalog_cd		,t_rec->covid19.covid_oc_qual[i].catalog_cd)
	    	 and	expand(i,1,t_rec->covid19.covid_status_cnt	,o.order_status_cd	,t_rec->covid19.covid_status_qual[i].order_status_cd)
	      )
	     ) 
	and   o.template_order_id = 0.0
	and   o.order_id > 0.0
order by
	 o.encntr_id
	,o.catalog_cd
	,o.orig_order_dt_tm desc
	,o.order_id
head report
	call writeLog(build2("->Inside encntr_domain query"))
	j = 0
head o.encntr_id
	j = locateval(i,1,t_rec->patient_cnt,o.encntr_id,t_rec->patient_qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(o.encntr_id))," at position=",trim(cnvtstring(j))))
;head o.catalog_cd DO WE NEED JUST THE MOST RECENT TEST?
head o.order_id	
 if (j > 0)
	call writeLog(build2("--->order_id=",trim(cnvtstring(o.order_id))," (",trim(o.order_mnemonic),")"))
	call writeLog(build2("---->adding ",trim(uar_get_code_display(o.catalog_type_cd))," order"))
	t_rec->patient_qual[j].orders_cnt = (t_rec->patient_qual[j].orders_cnt + 1)
	stat = alterlist(t_rec->patient_qual[j].orders_qual,t_rec->patient_qual[j].orders_cnt)
	t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].order_id 				= o.order_id
	t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].activity_type_cd		= o.activity_type_cd
	t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].catalog_cd			= o.catalog_cd
	t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].catalog_type_cd		= o.catalog_type_cd
	t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].order_mnemonic		= o.hna_order_mnemonic
	t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].order_status_cd		= o.order_status_cd
	t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].order_status_display	= 
																									uar_get_code_display(o.order_status_cd)
	t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].orig_order_dt_tm		= o.orig_order_dt_tm
	t_rec->patient_qual[j].orders_qual[t_rec->patient_qual[j].orders_cnt].order_status_dt_tm	= o.status_dt_tm
	/* not using 
	if 	(locateval(i,1,t_rec->pso.ip_pso_cnt,o.catalog_cd,t_rec->pso.ip_pso_qual[i].catalog_cd) > 0)
		
		
	elseif	(locateval(i,1,t_rec->covid19.covid_oc_cnt,o.catalog_cd,t_rec->covid19.covid_oc_qual[i].catalog_cd))
		
	endif
	*/
 endif
foot o.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(o.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
with nocounter

call writeLog(build2("* END   Finding Patient Orders *****************************"))

call writeLog(build2("* START Finding Patient Orders Details *********************"))
if (t_rec->covid19.covid_ignore_cnt > 0)
	select into "nl:"
	from
		 (dummyt d1 with seq=t_rec->patient_cnt)
		,(dummyt d2 with seq=1)
		,order_detail od
	plan d1
		where maxrec(d2,t_rec->patient_qual[d1.seq].orders_cnt)
		and   t_rec->patient_qual[d1.seq].expired_ind = 0
	join d2
	join od
		where od.order_id = t_rec->patient_qual[d1.seq].orders_qual[d2.seq].order_id
		and   expand(i,1,t_rec->covid19.covid_ignore_cnt,od.oe_field_id,t_rec->covid19.covid_ignore_qual[i].oe_field_id)
	order by
		 od.order_id
		,od.oe_field_id
		,od.action_sequence desc
	head report
		call writeLog(build2("->Inside order_detail query"))
	head od.order_id
		call writeLog(build2("-->entering od.order_id=",trim(cnvtstring(od.order_id))))
	head od.oe_field_id
		call writeLog(build2("--->checking od.oe_field_id=",trim(cnvtstring(od.oe_field_id))))
		t_rec->patient_qual[d1.seq].orders_qual[d2.seq].order_detail_cnt 
			= (t_rec->patient_qual[d1.seq].orders_qual[d2.seq].order_detail_cnt + 1)
		stat = alterlist(t_rec->patient_qual[d1.seq].orders_qual[d2.seq].order_detal_qual
			,t_rec->patient_qual[d1.seq].orders_qual[d2.seq].order_detail_cnt)
		t_rec->patient_qual[d1.seq].orders_qual[d2.seq].order_detal_qual[t_rec->patient_qual[d1.seq].orders_qual[d2.seq].
			order_detail_cnt].oe_field_id = od.oe_field_id
		t_rec->patient_qual[d1.seq].orders_qual[d2.seq].order_detal_qual[t_rec->patient_qual[d1.seq].orders_qual[d2.seq].
			order_detail_cnt].oe_field_display_value = od.oe_field_display_value
		t_rec->patient_qual[d1.seq].orders_qual[d2.seq].order_detal_qual[t_rec->patient_qual[d1.seq].orders_qual[d2.seq].
			order_detail_cnt].oe_field_dt_tm_value = od.oe_field_dt_tm_value
		t_rec->patient_qual[d1.seq].orders_qual[d2.seq].order_detal_qual[t_rec->patient_qual[d1.seq].orders_qual[d2.seq].
			order_detail_cnt].oe_field_value = od.oe_field_value
	with nocounter
endif
call writeLog(build2("* END Finding Patient Orders Details *********************"))

call writeLog(build2("* START Finding Patient Lab Results ****************************"))
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->patient_cnt)
	,clinical_event ce
plan d1
join ce
	where ce.person_id = t_rec->patient_qual[d1.seq].person_id
	and	  expand(i,1,t_rec->covid19.result_cnt,ce.event_cd,t_rec->covid19.result_qual[i].event_cd)
	and   ce.encntr_id = t_rec->patient_qual[d1.seq].encntr_id
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val        >  " "
order by
	 ce.encntr_id
	,ce.event_end_dt_tm desc
	,ce.event_cd
	,ce.event_id
head report
	call writeLog(build2("->Inside clinical_event query"))
	j = 0
head ce.encntr_id
	j = locateval(i,1,t_rec->patient_cnt,ce.encntr_id,t_rec->patient_qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
;head ce.event_cd ;DO WE WANT JUST THE MOST RECENT RESULT per event code or encounter?
head ce.event_id
 if (j > 0)
	call writeLog(build2("--->event_id=",trim(cnvtstring(ce.event_id))," (",trim(uar_get_code_display(ce.event_cd)),")"))
	call writeLog(build2("---->adding ",trim(ce.result_val)," result"))
	t_rec->patient_qual[j].lab_results_cnt = (t_rec->patient_qual[j].lab_results_cnt + 1)
	stat = alterlist(t_rec->patient_qual[j].lab_results_qual,t_rec->patient_qual[j].lab_results_cnt)
	t_rec->patient_qual[j].lab_results_qual[t_rec->patient_qual[j].lab_results_cnt].event_id 		 	= ce.event_id
	t_rec->patient_qual[j].lab_results_qual[t_rec->patient_qual[j].lab_results_cnt].event_cd			= ce.event_cd
	t_rec->patient_qual[j].lab_results_qual[t_rec->patient_qual[j].lab_results_cnt].event_tag			= ce.event_tag
	t_rec->patient_qual[j].lab_results_qual[t_rec->patient_qual[j].lab_results_cnt].order_id			= ce.order_id
	t_rec->patient_qual[j].lab_results_qual[t_rec->patient_qual[j].lab_results_cnt].result_val			= ce.result_val
	t_rec->patient_qual[j].lab_results_qual[t_rec->patient_qual[j].lab_results_cnt].task_assay_cd		= ce.task_assay_cd
	t_rec->patient_qual[j].lab_results_qual[t_rec->patient_qual[j].lab_results_cnt].event_end_dt_tm		= ce.event_end_dt_tm
	t_rec->patient_qual[j].lab_results_qual[t_rec->patient_qual[j].lab_results_cnt].clinsig_updt_dt_tm	= ce.clinsig_updt_dt_tm
	t_rec->patient_qual[j].lab_results_qual[t_rec->patient_qual[j].lab_results_cnt].valid_from_dt_tm	= ce.valid_from_dt_tm
	
 endif
foot ce.event_id	
	row +0
foot ce.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
with nocounter

call writeLog(build2("* END   Finding Patient Lab Results ****************************"))

call writeLog(build2("* START Finding Patient Ventilator Results ****************************"))
call writeLog(build2("* Searching for Activity"))

select into "nl:"
from
	 (dummyt d1 with seq=t_rec->patient_cnt)
	,clinical_event ce
plan d1
	where t_rec->patient_qual[d1.seq].expired_ind = 0
join ce
	where ce.person_id = t_rec->patient_qual[d1.seq].person_id
	and	  expand(i,1,t_rec->vent.result_cnt,ce.event_cd,t_rec->vent.result_qual[i].event_cd)
	and   ce.encntr_id = t_rec->patient_qual[d1.seq].encntr_id
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val        >  " "
order by
	 ce.encntr_id
	,ce.event_cd
	,ce.event_end_dt_tm desc
	,ce.event_id
head report
	call writeLog(build2("->Inside clinical_event query"))
	j = 0
	pos = 0
head ce.encntr_id
	j = locateval(i,1,t_rec->patient_cnt,ce.encntr_id,t_rec->patient_qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
head ce.event_cd 
;head ce.event_id ;DO WE WANT JUST THE MOST RECENT RESULT per event code or encounter?
 if (j > 0)
	call writeLog(build2("--->event_id=",trim(cnvtstring(ce.event_id))," (",trim(uar_get_code_display(ce.event_cd)),")"))
	call writeLog(build2("---->adding ",trim(ce.result_val)," result"))
	t_rec->patient_qual[j].vent_results_cnt = (t_rec->patient_qual[j].vent_results_cnt + 1)
	stat = alterlist(t_rec->patient_qual[j].vent_results_qual,t_rec->patient_qual[j].vent_results_cnt)
	t_rec->patient_qual[j].vent_results_qual[t_rec->patient_qual[j].vent_results_cnt].event_id 		 	= ce.event_id
	t_rec->patient_qual[j].vent_results_qual[t_rec->patient_qual[j].vent_results_cnt].event_cd			= ce.event_cd
	t_rec->patient_qual[j].vent_results_qual[t_rec->patient_qual[j].vent_results_cnt].event_tag			= ce.event_tag
	t_rec->patient_qual[j].vent_results_qual[t_rec->patient_qual[j].vent_results_cnt].order_id			= ce.order_id
	t_rec->patient_qual[j].vent_results_qual[t_rec->patient_qual[j].vent_results_cnt].result_val		= ce.result_val
	t_rec->patient_qual[j].vent_results_qual[t_rec->patient_qual[j].vent_results_cnt].task_assay_cd		= ce.task_assay_cd
	t_rec->patient_qual[j].vent_results_qual[t_rec->patient_qual[j].vent_results_cnt].event_end_dt_tm	= ce.event_end_dt_tm
	
	pos = locateval(i,1,t_rec->vent.result_cnt,ce.event_cd,t_rec->vent.result_qual[i].event_cd)
	t_rec->patient_qual[j].vent_results_qual[t_rec->patient_qual[j].vent_results_cnt].ventilator_type 	= 
																						t_rec->vent.result_qual[pos].vent_type
 endif
head ce.event_end_dt_tm 
	row +0
head ce.event_id
	row +0
foot ce.event_id
	row +0
foot ce.event_end_dt_tm
	row +0
foot ce.event_cd
	row +0
foot ce.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
with nocounter

call writeLog(build2("* Searching for Models "))
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->patient_cnt)
	,(dummyt d2 with seq=1)
	,clinical_event ce
plan d1
	where maxrec(d2,t_rec->patient_qual[d1.seq].vent_results_cnt)
	and   t_rec->patient_qual[d1.seq].expired_ind = 0
join d2
	where t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_id > 0.0
join ce
	where ce.person_id = t_rec->patient_qual[d1.seq].person_id
	and	  expand(i,1,t_rec->vent.model_cnt,ce.event_cd,t_rec->vent.model_qual[i].event_cd)
	;and   ce.event_end_dt_tm >= cnvtdatetime(curdate-1,0)
	and   ce.event_end_dt_tm = cnvtdatetime(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_end_dt_tm)
	and   ce.encntr_id = t_rec->patient_qual[d1.seq].encntr_id
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val        >  " "
order by
	 ce.encntr_id
	,ce.event_cd
	,ce.event_end_dt_tm desc
	,ce.event_id
head report
	call writeLog(build2("->Inside clinical_event query ventilator models"))
	j = 0
	pos = 0
head ce.encntr_id
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
	j = locateval(i,1,t_rec->patient_cnt,ce.encntr_id,t_rec->patient_qual[i].encntr_id)
head ce.event_cd 
	call writeLog(build2("--->checking event_cd=",trim(uar_get_code_display(ce.event_cd))," (",trim(cnvtstring(ce.result_val)),")"))
	pos = locateval(i,1,t_rec->vent.model_cnt,ce.event_cd,t_rec->vent.model_qual[i].event_cd)
	call writeLog(build2("---->checking type=",trim(t_rec->vent.model_qual[pos].vent_type)," (",trim(cnvtstring(pos)),")"))
	if (t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].ventilator_type = t_rec->vent.model_qual[pos].vent_type)
		t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].model_event_cd	= ce.event_cd
		t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].model_event_id	= ce.event_id
		t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].model_result_val	= trim(ce.result_val)
	endif
	pos = locateval(i,1,t_rec->vent.stock_cnt,trim(ce.result_val),t_rec->vent.stock_qual[i].model_name)
	if (pos > 0)
		t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].covenant_stock_ind = 1
	endif
head ce.event_end_dt_tm 
	row +0
head ce.event_id
	row +0
foot ce.event_id
	row +0
foot ce.event_end_dt_tm
	row +0
foot ce.event_cd
	row +0
foot ce.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
with nocounter


call writeLog(build2("* Searching for Models when missing documentation "))
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->patient_cnt)
	,(dummyt d2 with seq=1)
	,clinical_event ce
plan d1
	where maxrec(d2,t_rec->patient_qual[d1.seq].vent_results_cnt)
	and   t_rec->patient_qual[d1.seq].expired_ind = 0
join d2
	where t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_id > 0.0
	and   t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].model_event_id = 0.0
join ce
	where ce.person_id = t_rec->patient_qual[d1.seq].person_id
	and	  expand(i,1,t_rec->vent.model_cnt,ce.event_cd,t_rec->vent.model_qual[i].event_cd)
	and   ce.event_end_dt_tm >= cnvtdatetime(curdate-1,0)
	;and   ce.event_end_dt_tm = cnvtdatetime(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_end_dt_tm)
	and   ce.encntr_id = t_rec->patient_qual[d1.seq].encntr_id
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val        >  " "
order by
	 ce.encntr_id
	,ce.event_cd
	,ce.event_end_dt_tm desc
	,ce.event_id
head report
	call writeLog(build2("->Inside clinical_event for missing ventilator models query"))
	j = 0
	pos = 0
head ce.encntr_id
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
	j = locateval(i,1,t_rec->patient_cnt,ce.encntr_id,t_rec->patient_qual[i].encntr_id)
	pos = 0
head ce.event_cd 
	call writeLog(build2("--->checking event_cd=",trim(uar_get_code_display(ce.event_cd))," (",trim(ce.result_val),")"))
	t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].model_event_cd	= ce.event_cd
	t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].model_event_id	= ce.event_id
	t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].model_result_val	= trim(ce.result_val)
	pos = locateval(i,1,t_rec->vent.stock_cnt,trim(ce.result_val),t_rec->vent.stock_qual[i].model_name)
	if (pos > 0)
		t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].covenant_stock_ind = 1
	endif
/*
head ce.event_end_dt_tm 
	row +0
head ce.event_id
	row +0
foot ce.event_id
	row +0
foot ce.event_end_dt_tm
	row +0
foot ce.event_cd
	row +0
foot ce.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
*/
with nocounter

call writeLog(build2("* END   Finding Patient Ventilator Results ****************************"))

call writeLog(build2("* START Finding Result Comments ****************************"))
select into "nl:"
from
	 (dummyt d1 with seq=t_rec->patient_cnt)
	,(dummyt d2 with seq=1)
	,clinical_event ce
	,result r
	,result_comment rc
	,long_text lt
plan d1
	where maxrec(d2,t_rec->patient_qual[d1.seq].lab_results_cnt)
	and t_rec->patient_qual[d1.seq].expired_ind = 0
join d2
join ce
	where ce.event_id = t_rec->patient_qual[d1.seq].lab_results_qual[d2.seq].event_id
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
join r
	where r.order_id = ce.order_id
join rc
	where rc.result_id = r.result_id
join lt
	where lt.long_text_id = rc.long_text_id
order by
	 ce.encntr_id
	,r.result_id
head report
	call writeLog(build2("->Inside clinical_event query"))
	j = 0
head ce.encntr_id
	j = locateval(i,1,t_rec->patient_cnt,ce.encntr_id,t_rec->patient_qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
head r.result_id
 if (j > 0)
	call writeLog(build2("--->result_id=",trim(cnvtstring(r.result_id))," (",trim(uar_get_code_display(ce.event_cd)),")"))
	for (i=1 to t_rec->patient_qual[j].lab_results_cnt)
		if (t_rec->patient_qual[j].lab_results_qual[i].order_id = ce.order_id)
			t_rec->patient_qual[j].lab_results_qual[i].comment = lt.long_text
			call writeLog(build2("---->comment for order ",trim(cnvtstring(t_rec->patient_qual[j].lab_results_qual[i].order_id))
								,"=",trim(lt.long_text)))
		endif
	endfor
 endif 
foot ce.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(ce.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
with nocounter
	
call writeLog(build2("* END   Finding Result Comments ****************************"))

call writeLog(build2("* START Finding Observation Date and Time ******************"))
select into "nl:"
from
	 patient_event ea
	,(dummyt d1 with seq=t_rec->patient_cnt)
plan d1
join ea
	where ea.encntr_id = t_rec->patient_qual[d1.seq].encntr_id
	and   ea.active_ind	= 1
order by
	 ea.encntr_id
	,ea.event_type_cd
	,ea.transaction_dt_tm desc
head report
	call writeLog(build2("->Inside patient_event query"))
	j = 0
head ea.encntr_id
	j = locateval(i,1,t_rec->patient_cnt,ea.encntr_id,t_rec->patient_qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(ea.encntr_id))," at position=",trim(cnvtstring(j))))
head ea.event_type_cd
 if (j > 0)
	case (uar_get_code_display(ea.event_type_cd))
		of "Observation Start": t_rec->patient_qual[j].observation_dt_tm = ea.event_dt_tm
								call writeLog(build2("--->adding observation start=",trim(format(ea.event_dt_tm,";;q"))))
	endcase
 endif
foot ea.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(ea.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
with nocounter

call writeLog(build2("* END   Finding Observation Date and Time ******************"))

call writeLog(build2("* START Finding Diagnosis **********************************"))
select into "nl:"
from
	 diagnosis ea
	,nomenclature n
	,(dummyt d1 with seq=t_rec->patient_cnt)
plan d1
join ea
	where ea.encntr_id = t_rec->patient_qual[d1.seq].encntr_id
	and   ea.active_ind	= 1
	and	  cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
	and   ea.classification_cd in(
									 value(uar_get_code_by("MEANING",12033,"MEDICAL"))
									,value(uar_get_code_by("MEANING",12033,"PATSTATED"))
								 )
	and	  (
				(expand(i,1,t_rec->diagnosis_cnt,ea.originating_nomenclature_id,t_rec->diagnosis_qual[i].nomenclature_id))
			or
				(expand(i,1,t_rec->diagnosis_cnt,ea.nomenclature_id,t_rec->diagnosis_qual[i].nomenclature_id))
		   )
join n
	where n.nomenclature_id = ea.nomenclature_id
order by
	 ea.encntr_id
	,ea.diagnosis_id
head report
	call writeLog(build2("->Inside diagnosis query"))
	j = 0
head ea.encntr_id
	j = locateval(i,1,t_rec->patient_cnt,ea.encntr_id,t_rec->patient_qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(ea.encntr_id))," at position=",trim(cnvtstring(j))))
	if (j > 0)
	 	t_rec->patient_qual[j].diagnosis_cnt = (t_rec->patient_qual[j].diagnosis_cnt + 1)
	 	stat = alterlist(t_rec->patient_qual[j].diagnosis_qual,t_rec->patient_qual[j].diagnosis_cnt)
	 	t_rec->patient_qual[j].diagnosis_qual[t_rec->patient_qual[j].diagnosis_cnt].diagnosis_id 			= ea.diagnosis_id
	 	t_rec->patient_qual[j].diagnosis_qual[t_rec->patient_qual[j].diagnosis_cnt].nomenclature_id			= ea.nomenclature_id
	 	t_rec->patient_qual[j].diagnosis_qual[t_rec->patient_qual[j].diagnosis_cnt].orig_nomenclature_id	= ea.originating_nomenclature_id
	 	t_rec->patient_qual[j].diagnosis_qual[t_rec->patient_qual[j].diagnosis_cnt].source_string			= ea.diagnosis_display
	 	t_rec->patient_qual[j].diagnosis_qual[t_rec->patient_qual[j].diagnosis_cnt].daig_dt_tm				= ea.diag_dt_tm
	 	call writeLog(build2("--->added diagnosis=",trim(ea.diagnosis_display)))
	endif
foot ea.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(ea.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
with nocounter

call writeLog(build2("* END Finding Diagnosis **********************************"))

call writeLog(build2("* START Finding FIN ****************************************"))
select into "nl:"
from
	 encntr_alias ea
	,(dummyt d1 with seq=t_rec->patient_cnt)
plan d1
join ea
	where ea.encntr_id = t_rec->patient_qual[d1.seq].encntr_id
	and   ea.active_ind	= 1
	and	  cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
order by
	 ea.encntr_id
	,ea.beg_effective_dt_tm desc
head report
	call writeLog(build2("->Inside encntr_alias query"))
	j = 0
head ea.encntr_id
	j = locateval(i,1,t_rec->patient_cnt,ea.encntr_id,t_rec->patient_qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(ea.encntr_id))," at position=",trim(cnvtstring(j))))
	if (j > 0)
	 	t_rec->patient_qual[j].fin = cnvtalias(ea.alias,ea.alias_pool_cd)
	 	call writeLog(build2("--->added fin nbr=",trim(t_rec->patient_qual[j].fin)))
	endif
foot ea.encntr_id
	call writeLog(build2("-->leaving encntr_id=",trim(cnvtstring(ea.encntr_id))," at position=",trim(cnvtstring(j))))
	j = 0
with nocounter

call writeLog(build2("* END   Finding FIN ****************************************"))

call writeLog(build2("* START Finding Covenant Aliases ***************************"))
select into "nl:"
from
	 code_value_outbound cvo
	,encounter e
	,(dummyt d1 with seq=t_rec->patient_cnt)
plan d1
join e
	where 	t_rec->patient_qual[d1.seq].encntr_id = e.encntr_id
join cvo
	where	(
					(cvo.code_value = t_rec->patient_qual[d1.seq].loc_facility_cd)
				or	(cvo.code_value = t_rec->patient_qual[d1.seq].loc_unit_cd)
				or	(cvo.code_value = t_rec->patient_qual[d1.seq].loc_room_cd)
				or	(cvo.code_value = t_rec->patient_qual[d1.seq].loc_bed_cd)
			)
	and cvo.contributor_source_cd = value(uar_get_code_by("DISPLAY",73,"COVENANT"))
order by
	  e.encntr_id
	 ,cvo.alias_type_meaning
head report
	call writeLog(build2("->Inside encntr_alias query"))
	j = 0
head e.encntr_id
	j = locateval(i,1,t_rec->patient_cnt,e.encntr_id,t_rec->patient_qual[i].encntr_id)
	call writeLog(build2("-->entering encntr_id=",trim(cnvtstring(e.encntr_id))," at position=",trim(cnvtstring(j))))
head cvo.alias_type_meaning
	call writeLog(build2("--->entering cvo.alias_type_meaning=",trim(cvo.alias_type_meaning)," at position=",trim(cnvtstring(j))))
detail
	if (cvo.code_value = t_rec->patient_qual[j].loc_facility_cd)
		t_rec->patient_qual[j].cov_facility_alias = trim(cvo.alias)
	elseif (cvo.code_value = t_rec->patient_qual[j].loc_unit_cd)
		t_rec->patient_qual[j].cov_unit_alias = trim(cvo.alias)
	elseif (cvo.code_value = t_rec->patient_qual[j].loc_room_cd)
		t_rec->patient_qual[j].cov_room_alias = trim(cvo.alias)
	elseif (cvo.code_value = t_rec->patient_qual[j].loc_bed_cd)
		t_rec->patient_qual[j].cov_bed_alias = trim(cvo.alias)
	endif
with nocounter

call writeLog(build2("* END   Finding Covenant Aliases ***************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Building Output ************************************"))

for (i=1 to t_rec->patient_cnt)
	set t_output->cnt = (t_output->cnt + 1)
	set stat = alterlist(t_output->qual,t_output->cnt)
	
	set t_output->qual[t_output->cnt].person_id				= t_rec->patient_qual[i].person_id
	set t_output->qual[t_output->cnt].encntr_id				= t_rec->patient_qual[i].encntr_id
	set t_output->qual[t_output->cnt].facility				= trim(uar_get_code_display(t_rec->patient_qual[i].loc_facility_cd))
	set t_output->qual[t_output->cnt].encntr_type			= trim(uar_get_code_display(t_rec->patient_qual[i].encntr_type_cd))
	set t_output->qual[t_output->cnt].patient_name			= trim(t_rec->patient_qual[i].name_full_formatted)
	set t_output->qual[t_output->cnt].fin					= trim(t_rec->patient_qual[i].fin)
	set t_output->qual[t_output->cnt].dob					= trim(format(t_rec->patient_qual[i].dob,";;d"))
	set t_output->qual[t_output->cnt].unit					= trim(uar_get_code_display(t_rec->patient_qual[i].loc_unit_cd))
	
	if ((t_rec->patient_qual[i].loc_room_cd = 0.0) and (t_rec->patient_qual[i].loc_bed_cd > 0.0))
		set t_output->qual[t_output->cnt].room_bed				= trim(concat(	
																			trim(uar_get_code_display(t_rec->patient_qual[i].loc_bed_cd),3)
																			),3)
	elseif ((t_rec->patient_qual[i].loc_room_cd > 0.0) and (t_rec->patient_qual[i].loc_bed_cd = 0.0))
		set t_output->qual[t_output->cnt].room_bed				= trim(concat(	
																			trim(uar_get_code_display(t_rec->patient_qual[i].loc_room_cd),3)
																			),3)
	elseif ((t_rec->patient_qual[i].loc_room_cd > 0.0) and (t_rec->patient_qual[i].loc_bed_cd > 0.0))
		set t_output->qual[t_output->cnt].room_bed				= trim(concat(	
																			trim(uar_get_code_display(t_rec->patient_qual[i].loc_room_cd),3)
																			,"-"
																			,trim(uar_get_code_display(t_rec->patient_qual[i].loc_bed_cd),3)
																			),3)
	endif
	
	set t_output->qual[t_output->cnt].los_days				= t_rec->patient_qual[i].ip_los_days
	set t_output->qual[t_output->cnt].los_hours				= t_rec->patient_qual[i].ip_los_hours
	set t_output->qual[t_output->cnt].inpatient_dt_tm		= format(t_rec->patient_qual[i].inpatient_dt_tm,";;q")
	set t_output->qual[t_output->cnt].observation_dt_tm		= format(t_rec->patient_qual[i].observation_dt_tm,";;q")
	set t_output->qual[t_output->cnt].reg_dt_tm				= format(t_rec->patient_qual[i].reg_dt_tm,";;q")
	set t_output->qual[t_output->cnt].arrive_dt_tm			= format(t_rec->patient_qual[i].arrive_dt_tm,";;q")
	
	;Diagnosis Column
	if (t_rec->patient_qual[i].diagnosis_cnt > 0)
		for (j=1 to t_rec->patient_qual[i].diagnosis_cnt)
			if (j>1)
				set t_output->qual[t_output->cnt].diagnosis = concat(	 t_output->qual[t_output->cnt].diagnosis,";"
																		,trim(t_rec->patient_qual[i].diagnosis_qual[j].source_string))
			else
				set t_output->qual[t_output->cnt].diagnosis = trim(t_rec->patient_qual[i].diagnosis_qual[j].source_string)
			endif
			if (t_rec->patient_qual[i].diagnosis_qual[j].source_string in(
																				 "SARS-associated coronavirus exposure"
																				,"Exposure to SARS-associated coronavirus"
																				,"Exposure*"
																				,"*exposure*"
																				,"Suspected*"
																			  ))
				set t_output->qual[t_output->cnt].suspected_ind = 1
				set t_rec->patient_qual[i].suspected_onset_dt_tm = t_rec->patient_qual[i].diagnosis_qual[j].daig_dt_tm
			else
				set t_output->qual[t_output->cnt].positive_ind = 1
				set t_rec->patient_qual[i].positive_onset_dt_tm = t_rec->patient_qual[i].diagnosis_qual[j].daig_dt_tm
			endif
		endfor
	endif
	
	;PSO Column
	if (t_rec->patient_qual[i].orders_cnt > 0)
		set stat = 0
		for (j=1 to t_rec->patient_qual[i].orders_cnt)
			if (stat = 0)
				for (k=1 to t_rec->pso.ip_pso_cnt)
					if (stat = 0)
						if (t_rec->pso.ip_pso_qual[k].catalog_cd = t_rec->patient_qual[i].orders_qual[j].catalog_cd)
							set t_output->qual[t_output->cnt].pso = concat(trim(t_rec->patient_qual[i].orders_qual[j].order_mnemonic))
							set stat = 1
						endif
					endif
				endfor		
			endif
		endfor
		for (j=1 to t_rec->patient_qual[i].orders_cnt)
			if (stat = 0)
				for (k=1 to t_rec->pso.ob_pso_cnt)
					if (stat = 0)
						if (t_rec->pso.ob_pso_qual[k].catalog_cd = t_rec->patient_qual[i].orders_qual[j].catalog_cd)
							set t_output->qual[t_output->cnt].pso = concat(trim(t_rec->patient_qual[i].orders_qual[j].order_mnemonic))
							set stat = 1
						endif
					endif
				endfor		
			endif
		endfor		
	endif
	
	;COVID-19 Order Column
	if (t_rec->patient_qual[i].orders_cnt > 0)
		set stat = 0
		set ignore = 0
		for (j=1 to t_rec->patient_qual[i].orders_cnt)
			for (k=1 to t_rec->covid19.covid_oc_cnt)
				if (stat = 0)
					if (t_rec->covid19.covid_oc_qual[k].catalog_cd = t_rec->patient_qual[i].orders_qual[j].catalog_cd)
					 set ignore = 0
					 if (t_rec->covid19.covid_ignore_cnt > 0)
					 	for (pos=1 to t_rec->covid19.covid_ignore_cnt)
					 	 for (ii=1 to t_rec->patient_qual[i].orders_qual[j].order_detail_cnt)
					 	  if (t_rec->patient_qual[i].orders_qual[j].order_detal_qual[ii].oe_field_id =
					 	  	  t_rec->covid19.covid_ignore_qual[pos].oe_field_id)
					 	  	 if (t_rec->patient_qual[i].orders_qual[j].order_detal_qual[ii].oe_field_value = 
					 	  	     t_rec->covid19.covid_ignore_qual[pos].oe_field_value)
					 	  	   set ignore = 1
					 	  	   set t_rec->patient_qual[i].orders_qual[j].order_ignore = 1
					 	  	 endif
					 	  endif
					 	 endfor
					 	endfor
					 endif		
						if (ignore = 0)	
							set t_output->qual[t_output->cnt].covid19_order = concat(trim(t_rec->patient_qual[i].orders_qual[j].order_status_display))
							set t_output->qual[t_output->cnt].covid19_order_dt_tm = 
								;switching to orig_order_dt_tm format(t_rec->patient_qual[i].orders_qual[j].order_status_dt_tm,";;q")
								format(t_rec->patient_qual[i].orders_qual[j].orig_order_dt_tm,";;q")
							set stat = 1
							if (t_rec->patient_qual[i].orders_qual[j].order_status_display in("Ordered"))
								set t_output->qual[t_output->cnt].suspected_ind = 1
								set t_output->qual[t_output->cnt].pending_test_ind = 1
								if (t_rec->patient_qual[i].orders_qual[j].orig_order_dt_tm > t_rec->patient_qual[i].suspected_onset_dt_tm)
									set t_rec->patient_qual[i].suspected_onset_dt_tm = t_rec->patient_qual[i].orders_qual[j].orig_order_dt_tm
								endif
							endif
						endif
					set ignore = 0	
					endif
				endif
			endfor
		endfor		
	endif
	
	;COVID-19 Result Column
	if (t_rec->patient_qual[i].lab_results_cnt > 0)
		set stat = 0
		for (j=1 to t_rec->covid19.positive_cnt)
			if (t_rec->patient_qual[i].lab_results_qual[1].result_val = t_rec->covid19.positive_qual[j].result_val)
				set stat = 1
				set t_output->qual[t_output->cnt].covid19_result 		= concat("Positive")
				set t_output->qual[t_output->cnt].covid19_result_dt_tm 	= 
						;changing to clinsig_updt_dt_tm trim(format(t_rec->patient_qual[i].lab_results_qual[1].event_end_dt_tm,";;q"))
						trim(format(t_rec->patient_qual[i].lab_results_qual[1].clinsig_updt_dt_tm,";;q"))
				set t_output->qual[t_output->cnt].positive_ind = 1
				set t_rec->patient_qual[i].positive_onset_dt_tm = t_rec->patient_qual[i].lab_results_qual[1].clinsig_updt_dt_tm
			endif
		endfor
		if (stat = 0)
			if (t_rec->patient_qual[i].lab_results_cnt = 1)
				set t_output->qual[t_output->cnt].covid19_result = concat(	 t_rec->patient_qual[i].lab_results_qual[1].result_val)
				set t_output->qual[t_output->cnt].covid19_result_dt_tm	=
					;changing to clinsig_updt_dt_tm trim(format(t_rec->patient_qual[i].lab_results_qual[1].event_end_dt_tm,";;q"))
					trim(format(t_rec->patient_qual[i].lab_results_qual[1].clinsig_updt_dt_tm,";;q"))
			else
				set pos = 1
				while (pos <= t_rec->patient_qual[i].lab_results_cnt)
					if (stat = 0)
						if (t_rec->patient_qual[i].lab_results_qual[pos].result_val not in("DUPLICATE","RE-ORDERED","SEE BELOW"))
							set stat = 1
							set t_output->qual[t_output->cnt].covid19_result = concat(t_rec->patient_qual[i].lab_results_qual[pos].result_val)	
							set t_output->qual[t_output->cnt].covid19_result_dt_tm = 	
								;changing to clinsig_updt_dt_tm trim(format(t_rec->patient_qual[i].lab_results_qual[pos].event_end_dt_tm,";;q"))					
								trim(format(t_rec->patient_qual[i].lab_results_qual[1].clinsig_updt_dt_tm,";;q"))
						endif
					endif
					set pos = (pos + 1)
				endwhile
			endif
		endif
	endif
	
	;Ventilator Column
	select into "nl:"
		 encntr_id		 = t_rec->patient_qual[d1.seq].encntr_id
		,event_end_dt_tm = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_end_dt_tm
	from 
		 (dummyt d1 with seq=t_rec->patient_cnt)
		,(dummyt d2)
	plan d1
		where t_rec->patient_qual[d1.seq].encntr_id = t_rec->patient_qual[i].encntr_id
		and   maxrec(d2,t_rec->patient_qual[d1.seq].vent_results_cnt)
	join d2
	order by
		 encntr_id
		,event_end_dt_tm desc
	head encntr_id
		stat = 0
	head event_end_dt_tm
	 if (stat = 0)
		if (cnvtupper(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].result_val) in("*DISCONTINUE*"))
			stat = 1
		else
			for (j=1 to t_rec->vent.result_cnt)
				if (t_rec->vent.result_qual[j].lookback_hrs > 0)
					if ((t_rec->vent.result_qual[j].event_cd = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_cd) and
						(datetimediff(cnvtdatetime(curdate,curtime3),t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_end_dt_tm,3)
																				<= t_rec->vent.result_qual[j].lookback_hrs))
						t_output->qual[t_output->cnt].ventilator = concat(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].result_val)
						t_output->qual[t_output->cnt].ventilator_dt_tm = 
							trim(format(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_end_dt_tm,";;q"))
						t_output->qual[t_output->cnt].ventilator_type = uar_get_code_display(t_rec->patient_qual[d1.seq].
							vent_results_qual[d2.seq].event_cd)
						t_output->qual[t_output->cnt].ventilator_model = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].model_result_val
						stat = 1
						if (t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].ventilator_type = "I")
							t_output->qual[t_output->cnt].ventilator_ind = 1
						elseif (t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].ventilator_type = "N")
							t_output->qual[t_output->cnt].ventilator_ind = 2
						endif
						t_output->qual[t_output->cnt].covenant_vent_stock_ind 
							= t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].covenant_stock_ind
					endif
				elseif (t_rec->vent.result_qual[j].event_cd = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_cd)
					t_output->qual[t_output->cnt].ventilator = concat(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].result_val)
					t_output->qual[t_output->cnt].ventilator_dt_tm = 
						trim(format(t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].event_end_dt_tm,";;q"))
					t_output->qual[t_output->cnt].ventilator_type = uar_get_code_display(t_rec->patient_qual[d1.seq].
						vent_results_qual[d2.seq].event_cd)
					t_output->qual[t_output->cnt].ventilator_model = t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].model_result_val
					stat = 1
					t_output->qual[t_output->cnt].ventilator_ind = 1
					t_output->qual[t_output->cnt].covenant_vent_stock_ind 
						= t_rec->patient_qual[d1.seq].vent_results_qual[d2.seq].covenant_stock_ind
				endif
			endfor
		endif
	 endif
	with nocounter
	
	;Location Class 1
	set t_output->qual[t_output->cnt].location_class_1 = t_rec->patient_qual[i].loc_class_1

	;Expired Column
	set t_output->qual[t_output->cnt].expired_ind = t_rec->patient_qual[i].expired_ind
	set t_output->qual[t_output->cnt].expired_dt_tm = trim(format(t_rec->patient_qual[i].expired_dt_tm,";;q"))
	
	;Previous Admission Column
	if (
			(cnvtdatetime(t_rec->patient_qual[i].observation_dt_tm) 
				between cnvtdatetime(t_rec->covid19.admission_start_dt_tm) and cnvtdatetime(t_rec->covid19.admission_end_dt_tm))
		or
			(cnvtdatetime(t_rec->patient_qual[i].inpatient_dt_tm) 
				between cnvtdatetime(t_rec->covid19.admission_start_dt_tm) and cnvtdatetime(t_rec->covid19.admission_end_dt_tm))
		)
		set t_rec->patient_qual[i].previous_admission_ind = 1
		set t_output->qual[t_output->cnt].previous_admission_ind = t_rec->patient_qual[i].previous_admission_ind
	endif
	
	;Previous Onset Column
	if (t_output->qual[t_output->cnt].suspected_ind = 1)
		set t_output->qual[t_output->cnt].suspected_onset_dt_tm = format(t_rec->patient_qual[i].suspected_onset_dt_tm,";;q")
		
		if (cnvtdatetime(t_rec->patient_qual[i].suspected_onset_dt_tm) between	cnvtdatetime(t_rec->covid19.onset_start_dt_tm)
		 																	and		cnvtdatetime(t_rec->covid19.onset_end_dt_tm))
		
			set t_rec->patient_qual[i].previous_onset_ind = 1
			set t_output->qual[t_output->cnt].previous_onset_ind = t_rec->patient_qual[i].previous_onset_ind
		endif
	endif
	
	if (t_output->qual[t_output->cnt].positive_ind = 1)
		set t_output->qual[t_output->cnt].positive_onset_dt_tm = format(t_rec->patient_qual[i].positive_onset_dt_tm,";;q")
		
		if	(cnvtdatetime(t_rec->patient_qual[i].positive_onset_dt_tm) between	cnvtdatetime(t_rec->covid19.onset_start_dt_tm)
																					and		cnvtdatetime(t_rec->covid19.onset_end_dt_tm))
			set t_rec->patient_qual[i].previous_onset_ind = 1
			set t_output->qual[t_output->cnt].previous_onset_ind = t_rec->patient_qual[i].previous_onset_ind
		endif
	endif
	
	/*
	;Ventilator Column
	if (t_rec->patient_qual[i].vent_results_cnt > 0)
		set pos = 1
		set stat = 0
	  for (pos=1 to t_rec->patient_qual[i].vent_results_cnt)
		for (j=1 to t_rec->vent.result_cnt)
			if (cnvtupper(t_rec->patient_qual[i].vent_results_qual[pos].result_val) not in("*DISCONTINUE*"))
				if (t_rec->vent.result_qual[j].lookback_hrs > 0)
					if ((t_rec->vent.result_qual[j].event_cd = t_rec->patient_qual[i].vent_results_qual[pos].event_cd) and
						(datetimediff(cnvtdatetime(curdate,curtime3),t_rec->patient_qual[i].vent_results_qual[pos].event_end_dt_tm,3)
																				<= t_rec->vent.result_qual[j].lookback_hrs))
						set t_output->qual[t_output->cnt].ventilator = concat(t_rec->patient_qual[i].vent_results_qual[pos].result_val)
						set t_output->qual[t_output->cnt].ventilator_dt_tm = 
							trim(format(t_rec->patient_qual[i].vent_results_qual[pos].event_end_dt_tm,";;q"))
						set t_output->qual[t_output->cnt].ventilator_type = uar_get_code_display(t_rec->patient_qual[i].
							vent_results_qual[pos].event_cd)
					endif
				elseif (t_rec->vent.result_qual[j].event_cd = t_rec->patient_qual[i].vent_results_qual[pos].event_cd)
					set t_output->qual[t_output->cnt].ventilator = concat(t_rec->patient_qual[i].vent_results_qual[pos].result_val)
					set t_output->qual[t_output->cnt].ventilator_dt_tm = 
						trim(format(t_rec->patient_qual[i].vent_results_qual[pos].event_end_dt_tm,";;q"))
					set t_output->qual[t_output->cnt].ventilator_type = uar_get_code_display(t_rec->patient_qual[i].
						vent_results_qual[pos].event_cd)
				endif
			endif
		endfor
	  endfor
	endif
	*/
/*
	 x person_id				= f8
	 x encntr_id				= f8
	 x facility					= vc
	 x patient_name				= vc
	 x fin						= vc
	 x dob						= vc
	 x unit						= vc
	 x room_bed					= vc
	 x pso						= vc
	 x los						= i2
	 x diagnosis				= vc
	 2 covid19_order			= vc
	 2 covid19_result			= vc
	 2 ventilator				= vc
*/
endfor

call writeLog(build2("* END   Building Output ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Building NHSN Data *********************************"))

for (i=1 to t_output->cnt)
  call writeLog(build2("-->checking encntr_id=",trim(cnvtstring(t_output->qual[i].encntr_id))))
  set t_output->qual[i].encntr_ignore = 1
  if (t_output->qual[i].expired_ind = 0)
	;Checking Q1 Count of Patients in an inpatient bed with confirmed or suspected COVID-19  
	;Checking Q2 Count of Patients in an inpatient bed with confirmed or suspected COVID-19 and on a ventilator
	;Checking Q3 Count of Patients in an inpatient bed with confirmed or suspected COVID-19, LOS 14 days or More
	if ((t_output->qual[i].positive_ind = 1) or (t_output->qual[i].suspected_ind = 1))
		if (t_output->qual[i].location_class_1 in("ICU","MSU"))
			set t_output->qual[i].encntr_ignore = 0
		endif
	endif
	
	;Checking Q4 Count of Patients in ED or Overflow with confirmed or suspected COVID-19, and waiting on an inpatient bed
	if ((t_output->qual[i].positive_ind = 1) or (t_output->qual[i].suspected_ind = 1))
		if (t_output->qual[i].location_class_1 in("ED","EB"))
			if (t_output->qual[i].pso in("PSO Admit to Inpatient"))
				set t_output->qual[i].encntr_ignore = 0
			endif
		endif
	endif
	;Checking Q13 Checking if Patient is on a vent
	if ((t_output->qual[i].ventilator_ind > 0) and (t_output->qual[i].covenant_vent_stock_ind > 0))
		set t_output->qual[i].encntr_ignore = 0
	endif
 elseif (t_output->qual[i].expired_ind = 1)
  set t_output->qual[i].encntr_ignore = 0
  endif
	call writeLog(build2("--->checking encntr_ignore=",trim(cnvtstring(t_output->qual[i].encntr_ignore))))
	if (t_output->qual[i].encntr_ignore = 0)
		set nhsn_covid19->patient_cnt = (nhsn_covid19->patient_cnt + 1)
		set stat = alterlist(nhsn_covid19->patient_qual,nhsn_covid19->patient_cnt)
		
		call writeLog(build2("---->adding nhsn_covid19->patient_cnt=",trim(cnvtstring(nhsn_covid19->patient_cnt))))
		
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].encntr_id = t_output->qual[i].encntr_id 
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].person_id = t_output->qual[i].person_id
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].patient_name = t_output->qual[i].patient_name
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].encntr_type = t_output->qual[i].encntr_type
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].facility = t_output->qual[i].facility
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].unit = t_output->qual[i].unit
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].room_bed = t_output->qual[i].room_bed
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].fin = t_output->qual[i].fin
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].los_days = t_output->qual[i].los_days
		if ((t_output->qual[i].expired_ind = 1) and (t_output->qual[i].positive_ind = 1))
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].expired = "Y"
		endif
		if (t_output->qual[i].covid19_order > " ")
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].covid19_order = concat(
																					t_output->qual[i].covid19_order
																					," ("
																					,t_output->qual[i].covid19_order_dt_tm
																					,")"
																					)
		endif
		if (t_output->qual[i].covid19_result > " ")
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].covid19_result = concat(
																					t_output->qual[i].covid19_result
																					," ("
																					,t_output->qual[i].covid19_result_dt_tm
																					,")"
																					)
		endif																					
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].diagnosis = t_output->qual[i].diagnosis
		if (t_output->qual[i].pso in("PSO Admit to Inpatient"))
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].ip_pso = "Y"
		endif
		set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].location_class_1 = t_output->qual[i].location_class_1
		if ((t_output->qual[i].suspected_ind = 1) and (t_output->qual[i].positive_ind = 0))
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].suspected = "Y"
		endif
		
		if (t_output->qual[i].positive_ind = 1)
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].confirmed = "Y"
		endif
		
		if (t_output->qual[i].ventilator_ind > 0)
			if (t_output->qual[i].ventilator_ind = 1)
				set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].ventilator = "I"
			elseif (t_output->qual[i].ventilator_ind = 2)
				set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].ventilator = "N"
			endif
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].ventilator_model = t_output->qual[i].ventilator_model
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].ventilator_result = t_output->qual[i].ventilator_type
			if (t_output->qual[i].covenant_vent_stock_ind = 1)
				set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].covenant_vent_stock = "Y"
			endif
		endif
		
		if (t_output->qual[i].previous_admission_ind = 1)
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].prev_admission = "Y"
		endif
		
		if (t_output->qual[i].previous_onset_ind = 1)
			set nhsn_covid19->patient_qual[nhsn_covid19->patient_cnt].prev_onset = "Y"
		endif
		
	endif ;end if encntr_ignore = 0
	
	;end check, reset
	set t_output->qual[i].encntr_ignore = 1
endfor


call writeLog(build2("** Building Summary Table"))

for (i=1 to location_list->location_cnt)
	call writeLog(build2("->location:",trim(location_list->locations[i].display)))
	select into "nl:"
		encntr_id				= nhsn_covid19->patient_qual[d1.seq].encntr_id
	from
		(dummyt d1 with seq=nhsn_covid19->patient_cnt)
	plan d1
		where nhsn_covid19->patient_qual[d1.seq].facility = location_list->locations[i].display
	order by
	 	 encntr_id
	head report
		call writeLog(build2("-->inside nhsn_covid19 query for ",trim(location_list->locations[i].display)))
		nhsn_covid19->summary_cnt = (nhsn_covid19->summary_cnt + 1)
		stat = alterlist(nhsn_covid19->summary_qual,nhsn_covid19->summary_cnt)
		nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].facility = trim(location_list->locations[i].display)
		call writeLog(build2("-->nhsn_covid19->summary_cnt=",trim(cnvtstring(nhsn_covid19->summary_cnt))))
	head encntr_id
		call writeLog(build2("--->analyzing encntr_id=",trim(cnvtstring(encntr_id))))
	 if (nhsn_covid19->patient_qual[d1.seq].expired = "Y")
	 	call writeLog(build2("---->found expired=",trim(nhsn_covid19->patient_qual[d1.seq].expired)))
	 	nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q6_disch_expired = 
	 		(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q6_disch_expired + 1)
	 else
		call writeLog(build2("---->reviewing location_class_1=",trim(nhsn_covid19->patient_qual[d1.seq].location_class_1)))
		if (nhsn_covid19->patient_qual[d1.seq].location_class_1 in("MSU","ICU"))
			call writeLog(build2("---->found location_class_1=",trim(nhsn_covid19->patient_qual[d1.seq].location_class_1)))
			;Confirmed
			call writeLog(build2("----->reviewing confirmation=",trim(nhsn_covid19->patient_qual[d1.seq].confirmed)))
			if (nhsn_covid19->patient_qual[d1.seq].confirmed = "Y")
				nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q1_ip_confirmed = 
				(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q1_ip_confirmed + 1)
				call writeLog(build2("--->setting q1_ip_confirmed=",
					trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q1_ip_confirmed))))
				if (nhsn_covid19->patient_qual[d1.seq].prev_admission = "Y")
					nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].qa_numc19confnewadm = 
					 (nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].qa_numc19confnewadm + 1)
					call writeLog(build2("--->setting qa_numc19confnewadm=",
					trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].qa_numc19confnewadm))))
				endif
		
				;LOS >= 14
				call writeLog(build2("----->reviewing los_days=",	
					trim(cnvtstring(nhsn_covid19->patient_qual[d1.seq].los_days))))
				if (nhsn_covid19->patient_qual[d1.seq].los_days >= 14)
						nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q3_ip_conf_susp_los14 = 
						(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q3_ip_conf_susp_los14 + 1)
						call writeLog(build2("--->setting q3_ip_conf_susp_los14=",
							trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q3_ip_conf_susp_los14))))
						if (nhsn_covid19->patient_qual[d1.seq].prev_onset = "Y")
							nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].qc_numc19honewpats = 
							 (nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].qc_numc19honewpats + 1)
							call writeLog(build2("--->setting qc_numc19honewpats=",
							trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].qc_numc19honewpats))))
						endif
				endif	
				
				;Ventilator
				call writeLog(build2("----->reviewing ventilator=",trim(nhsn_covid19->patient_qual[d1.seq].ventilator)))
				if (nhsn_covid19->patient_qual[d1.seq].ventilator in("I"))
					nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q2_ip_confirmed_vent = 
					(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q2_ip_confirmed_vent + 1)
					call writeLog(build2("--->setting q2_ip_confirmed_vent=",
						trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q2_ip_confirmed_vent))))
				endif
			endif

			call writeLog(build2("----->reviewing suspected=",trim(nhsn_covid19->patient_qual[d1.seq].suspected)))
			if (nhsn_covid19->patient_qual[d1.seq].suspected = "Y")
				;Suspected
				nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q1_ip_suspected = 
				(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q1_ip_suspected + 1)
				call writeLog(build2("--->setting q1_ip_suspected=",
					trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q1_ip_suspected))))
				
				if (nhsn_covid19->patient_qual[d1.seq].prev_admission = "Y")
					nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].qb_numc19suspnewadm = 
					 (nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].qb_numc19suspnewadm + 1)
					call writeLog(build2("--->setting qb_numc19suspnewadm=",
					trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].qb_numc19suspnewadm))))
				endif
				
				;LOS >= 14
				call writeLog(build2("----->reviewing suspected=",trim(cnvtstring(nhsn_covid19->patient_qual[d1.seq].los_days))))
				if (nhsn_covid19->patient_qual[d1.seq].los_days >= 14)
						nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q3_ip_conf_susp_los14 = 
						(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q3_ip_conf_susp_los14 + 1)
					call writeLog(build2("--->setting q3_ip_conf_susp_los14=",
						trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q3_ip_conf_susp_los14))))				
					endif
						
				;Ventilator
				call writeLog(build2("----->reviewing ventilator=",trim(nhsn_covid19->patient_qual[d1.seq].ventilator)))
				if (nhsn_covid19->patient_qual[d1.seq].ventilator in("I"))
					nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q2_ip_suspected_vent = 
					(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q2_ip_suspected_vent + 1)
					call writeLog(build2("--->setting q2_ip_suspected_vent=",
						trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q2_ip_suspected_vent))))		
				endif
			endif
		elseif (nhsn_covid19->patient_qual[d1.seq].location_class_1 in("ED","EB"))
			call writeLog(build2("---->found location_class_1=",trim(nhsn_covid19->patient_qual[d1.seq].location_class_1)))
			;ED with PSO
			nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q4_ed_of_conf_susp_wait = 
			(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q4_ed_of_conf_susp_wait + 1)
			call writeLog(build2("--->setting q4_ed_of_conf_susp_wait=",
						trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q4_ed_of_conf_susp_wait))))		
						
			;Ventilator
			call writeLog(build2("----->reviewing ventilator=",trim(nhsn_covid19->patient_qual[d1.seq].ventilator)))
			if (nhsn_covid19->patient_qual[d1.seq].ventilator in("I"))
				nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q5_ed_of_conf_susp_wait_vent = 
				(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q5_ed_of_conf_susp_wait_vent + 1)
				call writeLog(build2("--->setting q5_ed_of_conf_susp_wait_vent=",
						trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q5_ed_of_conf_susp_wait_vent))))	
			endif
		endif
		if ((nhsn_covid19->patient_qual[d1.seq].ventilator in("I","N")) 
					and (nhsn_covid19->patient_qual[d1.seq].covenant_vent_stock = "Y"))
			nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q13_ventilator_in_use = 
			(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q13_ventilator_in_use + 1)
			call writeLog(build2("--->setting q13_ventilator_in_use=",
			trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q13_ventilator_in_use))))		
		endif
	 endif
	foot report
		call writeLog(build2("-->leaving nhsn_covid19 query for ",trim(location_list->locations[i].display)))
		call writeLog(build2("-->nhsn_covid19->summary_cnt=",trim(cnvtstring(nhsn_covid19->summary_cnt))))
		nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q1_total = 
			(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q1_ip_confirmed +
			 nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q1_ip_suspected)
		call writeLog(build2("-->nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q1_total="
			,trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q1_total))))
			
		nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q2_total = 
			(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q2_ip_confirmed_vent +
			 nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q2_ip_suspected_vent)
				call writeLog(build2("-->nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q2_total="
			,trim(cnvtstring(nhsn_covid19->summary_qual[nhsn_covid19->summary_cnt].q2_total))))
	with nocounter,nullreport
endfor


call writeLog(build2("** Building Summary Table from Extensions"))

for (i=1 to nhsn_covid19->summary_cnt)
	select into "nl:"
	from
		 (dummyt d1 with seq=nhsn_covid19->summary_cnt)
	    ,code_value cv1
	    ,code_value_extension cve1
	plan d1
		where nhsn_covid19->summary_qual[1].facility
	join cv1
	    where cv1.code_set              = t_rec->custom_code_set
	    and   cv1.definition            = trim(cnvtlower(t_rec->curprog))   
	    and   cv1.active_ind            = 1
	    and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	    and   cv1.end_effective_dt_tm   >= cnvtdatetime(curdate,curtime3)
	    and   cv1.cdf_meaning           = "FACILITY"
	    and   cv1.display				= nhsn_covid19->summary_qual[d1.seq].facility
	join cve1
		where cve1.code_value			= cv1.code_value
		and   cve1.field_name			in(
											 "Q7"
											,"Q8"
											,"Q10"
											,"Q12"
											,"NUMC19DIED"
											)
	order by
		 cv1.code_value
		,cve1.field_name
	head report
		call writeLog(build2("->inside :",trim(nhsn_covid19->summary_qual[d1.seq].facility)))
	head cv1.code_value
		call writeLog(build2("-->inside :",trim(cv1.display)))
	head cve1.field_name
		call writeLog(build2("--->inside :",trim(cve1.field_name)))
		case (cve1.field_name)
			of "Q7": 	nhsn_covid19->summary_qual[d1.seq].q7_all_beds_total			= cnvtint(cve1.field_value)
			of "Q8": 	nhsn_covid19->summary_qual[d1.seq].q8_all_beds_total_surge		= cnvtint(cve1.field_value)
			of "Q10": 	nhsn_covid19->summary_qual[d1.seq].q10_avail_icu_beds			= cnvtint(cve1.field_value)
			of "Q12": 	nhsn_covid19->summary_qual[d1.seq].q12_ventilator_total			= cnvtint(cve1.field_value)
			of "NUMC19DIED": nhsn_covid19->summary_qual[d1.seq].q6a_all_expired			= cnvtint(cve1.field_value)
		endcase
	foot cv1.code_value
		call writeLog(build2("-->leaving :",trim(nhsn_covid19->summary_qual[d1.seq].facility)))
	foot report
		call writeLog(build2("->leaving :",trim(nhsn_covid19->summary_qual[d1.seq].facility)))
	with nocounter
endfor


call writeLog(build2("** Building Summary Table for Bed Counts"))

for (i=1 to nhsn_covid19->summary_cnt)
	select into "nl:"
		 facility = t_output->qual[d1.seq].facility
		,encntr_id = t_output->qual[d1.seq].encntr_id
	from
		 (dummyt d1 with seq=t_output->cnt)
	plan d1
		where t_output->qual[d1.seq].facility = nhsn_covid19->summary_qual[i].facility
		and   t_output->qual[d1.seq].expired_ind = 0
	order by
		  facility
		 ,encntr_id
	head report
		call writeLog(build2("->inside :",trim(facility)))
	head facility
		call writeLog(build2("-->inside :",trim(facility)))
	head encntr_id
		call writeLog(build2("--->checking encntr_id=",trim(cnvtstring(encntr_id))))
		if (t_output->qual[d1.seq].location_class_1 in("ICU","MSU"))
			nhsn_covid19->summary_qual[i].q9_occupied_ip_beds = (nhsn_covid19->summary_qual[i].q9_occupied_ip_beds + 1)
		endif
		if (t_output->qual[d1.seq].location_class_1 in("ICU"))
			nhsn_covid19->summary_qual[i].q11_occupied_icu_beds = (nhsn_covid19->summary_qual[i].q11_occupied_icu_beds + 1)
		endif
	foot encntr_id
		call writeLog(build2("--->leaving encntr_id=",trim(cnvtstring(encntr_id))))
	foot facility
		call writeLog(build2("-->leaving :",trim(facility)))
	foot report
		call writeLog(build2("->leaving :",trim(facility)))
	with nocounter
endfor

call writeLog(build2("* END   Building NHSN Data *********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Building HRTS Data *********************************"))

for (i=1 to t_output->cnt)
	call writeLog(build2("-->checking encntr_id=",trim(cnvtstring(t_output->qual[i].encntr_id))))
  	set t_output->qual[i].hrts_ignore = 1
  	if (t_output->qual[i].expired_ind = 0)
  	  ;if (t_output->qual[i].encntr_type = "Inpatient")
  	  if (t_output->qual[i].location_class_1 > " ")
		;Checking Question 1 series for positive patients
		if ((t_output->qual[i].positive_ind = 1))
			set t_output->qual[i].hrts_ignore = 0
		endif
		;Checking Question 2 series for positive patients
		;if ((t_output->qual[i].pending_test_ind = 1))
		if ((t_output->qual[i].suspected_ind = 1))
			set t_output->qual[i].hrts_ignore = 0
		endif
	  endif
  	endif
  
 	call writeLog(build2("--->checking encntr_ignore=",trim(cnvtstring(t_output->qual[i].hrts_ignore))))
	if (t_output->qual[i].hrts_ignore = 0)
		set hrts_covid19->patient_cnt = (hrts_covid19->patient_cnt + 1)
		set stat = alterlist(hrts_covid19->patient_qual,hrts_covid19->patient_cnt)
		
		call writeLog(build2("---->adding hrts_covid19->patient_cnt=",trim(cnvtstring(hrts_covid19->patient_cnt))))
		
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].encntr_id = t_output->qual[i].encntr_id 
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].person_id = t_output->qual[i].person_id
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].patient_name = t_output->qual[i].patient_name
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].encntr_type = t_output->qual[i].encntr_type
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].facility = t_output->qual[i].facility
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].unit = t_output->qual[i].unit
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].room_bed = t_output->qual[i].room_bed
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].fin = t_output->qual[i].fin
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].los_days = t_output->qual[i].los_days
		if ((t_output->qual[i].expired_ind = 1) and (t_output->qual[i].positive_ind = 1))
			set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].expired = "Y"
		endif
		if (t_output->qual[i].covid19_order > " ")
			set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].covid19_order = concat(
																					t_output->qual[i].covid19_order
																					," ("
																					,t_output->qual[i].covid19_order_dt_tm
																					,")"
																					)
		endif
		if (t_output->qual[i].covid19_result > " ")
			set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].covid19_result = concat(
																					t_output->qual[i].covid19_result
																					," ("
																					,t_output->qual[i].covid19_result_dt_tm
																					,")"
																					)
		endif																					
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].diagnosis = t_output->qual[i].diagnosis
		if (t_output->qual[i].pso in("PSO Admit to Inpatient"))
			set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].ip_pso = "Y"
		endif
		set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].location_class_1 = t_output->qual[i].location_class_1
		if ((t_output->qual[i].suspected_ind = 1) and (t_output->qual[i].positive_ind = 0))
			set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].suspected = "Y"
		endif
		
		if (t_output->qual[i].positive_ind = 1)
			set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].confirmed = "Y"
		endif
		
		if (t_output->qual[i].ventilator_ind > 0)
			if (t_output->qual[i].ventilator_ind = 1)
				set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].ventilator = "I"
			elseif (t_output->qual[i].ventilator_ind = 2)
				set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].ventilator = "N"
			endif
			set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].ventilator_model = t_output->qual[i].ventilator_model
			set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].ventilator_result = t_output->qual[i].ventilator_type
			if (t_output->qual[i].covenant_vent_stock_ind = 1)
				set hrts_covid19->patient_qual[hrts_covid19->patient_cnt].covenant_vent_stock = "Y"
			endif
		endif
	endif
	;end check, reset
	set t_output->qual[i].hrts_ignore = 1
endfor

call writeLog(build2("** Building Summary Table"))

for (i=1 to location_list->location_cnt)
	call writeLog(build2("->location:",trim(location_list->locations[i].display)))
	select into "nl:"
		encntr_id				= hrts_covid19->patient_qual[d1.seq].encntr_id
	from
		(dummyt d1 with seq=hrts_covid19->patient_cnt)
	plan d1
		where hrts_covid19->patient_qual[d1.seq].facility = location_list->locations[i].display
	order by
	 	 encntr_id
	head report
		call writeLog(build2("-->inside hrts_covid19 query for ",trim(location_list->locations[i].display)))
		hrts_covid19->summary_cnt = (hrts_covid19->summary_cnt + 1)
		stat = alterlist(hrts_covid19->summary_qual,hrts_covid19->summary_cnt)
		hrts_covid19->summary_qual[hrts_covid19->summary_cnt].facility = trim(location_list->locations[i].display)
		call writeLog(build2("-->hrts_covid19->summary_cnt=",trim(cnvtstring(hrts_covid19->summary_cnt))))
	head encntr_id
		call writeLog(build2("--->analyzing encntr_id=",trim(cnvtstring(encntr_id))))
		if (hrts_covid19->patient_qual[d1.seq].confirmed = "Y")
			call writeLog(build2("--->analyzing confirmed=",trim(hrts_covid19->patient_qual[d1.seq].confirmed)))
			hrts_covid19->summary_qual[hrts_covid19->summary_cnt].q1_total_pos_inp = 
				(hrts_covid19->summary_qual[hrts_covid19->summary_cnt].q1_total_pos_inp + 1)
	 		if (hrts_covid19->patient_qual[d1.seq].location_class_1 in("ICU"))
	 			hrts_covid19->summary_qual[hrts_covid19->summary_cnt].q1_1_icu_pos_inp = 
					(hrts_covid19->summary_qual[hrts_covid19->summary_cnt].q1_1_icu_pos_inp + 1)
	 		endif
	 		if (hrts_covid19->patient_qual[d1.seq].ventilator in("I","N"))
				hrts_covid19->summary_qual[hrts_covid19->summary_cnt].q1_2_pos_inp_vent = 
					(hrts_covid19->summary_qual[hrts_covid19->summary_cnt].q1_2_pos_inp_vent + 1)
			endif
	 	endif
	 	if (hrts_covid19->patient_qual[d1.seq].suspected = "Y")
			call writeLog(build2("--->analyzing suspected=",trim(hrts_covid19->patient_qual[d1.seq].suspected)))
			hrts_covid19->summary_qual[hrts_covid19->summary_cnt].q2_total_pend_inp = 
				(hrts_covid19->summary_qual[hrts_covid19->summary_cnt].q2_total_pend_inp + 1)
	 		if (hrts_covid19->patient_qual[d1.seq].location_class_1 in("ICU"))
	 			hrts_covid19->summary_qual[hrts_covid19->summary_cnt].q2_1_icu_pend_inp = 
					(hrts_covid19->summary_qual[hrts_covid19->summary_cnt].q2_1_icu_pend_inp + 1)
	 		endif
	 		if (hrts_covid19->patient_qual[d1.seq].ventilator in("I","N"))
				hrts_covid19->summary_qual[hrts_covid19->summary_cnt].q2_2_pend_inp_vent = 
					(hrts_covid19->summary_qual[hrts_covid19->summary_cnt].q2_2_pend_inp_vent + 1)
			endif
	 	endif
	foot report
		call writeLog(build2("-->leaving hrts_covid19 query for ",trim(location_list->locations[i].display)))
		call writeLog(build2("-->hrts_covid19->summary_cnt=",trim(cnvtstring(hrts_covid19->summary_cnt))))
	with nocounter,nullreport
endfor
	 
call writeLog(build2("* END   Building HRTS Data *********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Building Facility Unit *****************************"))

for (i=1 to t_output->cnt)
	call writeLog(build2("-->checking encntr_id=",trim(cnvtstring(t_output->qual[i].encntr_id))))
  	set t_output->qual[i].cov_summary_ignore = 1
  	if (t_output->qual[i].expired_ind = 0)
  	  ;if (t_output->qual[i].encntr_type = "Inpatient")
  	  	;if (t_output->qual[i].location_class_1 > " ")
		if ((t_output->qual[i].positive_ind = 1))
			set t_output->qual[i].cov_summary_ignore = 0
		endif
		;if ((t_output->qual[i].pending_test_ind = 1))
		if ((t_output->qual[i].suspected_ind = 1))
			set t_output->qual[i].cov_summary_ignore = 0
		endif
	endif
  
 	call writeLog(build2("--->checking encntr_ignore=",trim(cnvtstring(t_output->qual[i].cov_summary_ignore))))
	if (t_output->qual[i].cov_summary_ignore = 0)
			
		set cov_unit_summary->patient_cnt = (cov_unit_summary->patient_cnt + 1)
		set stat = alterlist(cov_unit_summary->patient_qual,cov_unit_summary->patient_cnt)
		
		call writeLog(build2("---->adding cov_unit_summary->patient_cnt=",trim(cnvtstring(cov_unit_summary->patient_cnt))))
		
		set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].encntr_id = t_output->qual[i].encntr_id 
		set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].person_id = t_output->qual[i].person_id
		set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].patient_name = t_output->qual[i].patient_name
		set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].encntr_type = t_output->qual[i].encntr_type
		set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].facility = t_output->qual[i].facility
		set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].unit = t_output->qual[i].unit
		set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].room_bed = t_output->qual[i].room_bed
		set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].fin = t_output->qual[i].fin
		set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].los_days = t_output->qual[i].los_days
		if ((t_output->qual[i].expired_ind = 1) and (t_output->qual[i].positive_ind = 1))
			set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].expired = "Y"
		endif
		if (t_output->qual[i].covid19_order > " ")
			set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].covid19_order = concat(
																					t_output->qual[i].covid19_order
																					," ("
																					,t_output->qual[i].covid19_order_dt_tm
																					,")"
																					)
		endif
		if (t_output->qual[i].covid19_result > " ")
			set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].covid19_result = concat(
																					t_output->qual[i].covid19_result
																					," ("
																					,t_output->qual[i].covid19_result_dt_tm
																					,")"
																					)
		endif																					
		set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].diagnosis = t_output->qual[i].diagnosis
		if (t_output->qual[i].pso in("PSO Admit to Inpatient"))
			set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].ip_pso = "Y"
		endif
		set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].location_class_1 = t_output->qual[i].location_class_1
		if ((t_output->qual[i].suspected_ind = 1) and (t_output->qual[i].positive_ind = 0))
			set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].suspected = "Y"
		endif
		
		if (t_output->qual[i].positive_ind = 1)
			set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].confirmed = "Y"
		endif
		
		if (t_output->qual[i].ventilator_ind > 0)
			if (t_output->qual[i].ventilator_ind = 1)
				set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].ventilator = "I"
			elseif (t_output->qual[i].ventilator_ind = 2)
				set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].ventilator = "N"
			endif
			set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].ventilator_model = t_output->qual[i].ventilator_model
			set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].ventilator_result = t_output->qual[i].ventilator_type
			if (t_output->qual[i].covenant_vent_stock_ind = 1)
				set cov_unit_summary->patient_qual[cov_unit_summary->patient_cnt].covenant_vent_stock = "Y"
			endif
		endif
	endif
	;end check, reset
endfor

call writeLog(build2("** Building Summary Table"))

for (i=1 to location_list->location_cnt)
	call writeLog(build2("->location:",trim(location_list->locations[i].display)))
	select into "nl:"
		 facility				= cov_unit_summary->patient_qual[d1.seq].facility
		,unit					= cov_unit_summary->patient_qual[d1.seq].unit
		,room_bed				= cov_unit_summary->patient_qual[d1.seq].room_bed
		,encntr_id				= cov_unit_summary->patient_qual[d1.seq].encntr_id
	from
		(dummyt d1 with seq=cov_unit_summary->patient_cnt)
	plan d1
		where cov_unit_summary->patient_qual[d1.seq].facility = location_list->locations[i].display
	order by
		 facility
		,unit
		,room_bed
	 	,encntr_id
	head report
		call writeLog(build2("-->inside cov_unit_summary query for ",trim(location_list->locations[i].display)))
		cov_unit_summary->summary_cnt = (cov_unit_summary->summary_cnt + 1)
		stat = alterlist(cov_unit_summary->summary_qual,cov_unit_summary->summary_cnt)
		cov_unit_summary->summary_qual[cov_unit_summary->summary_cnt].facility = trim(location_list->locations[i].display)
		call writeLog(build2("-->cov_unit_summary->summary_cnt=",trim(cnvtstring(cov_unit_summary->summary_cnt))))
		unit_cnt = 0
		room_bed_cnt = 0
		summary_cnt = 0
	head facility
		call writeLog(build2("-->inside facility query for ",trim(cov_unit_summary->patient_qual[d1.seq].facility)))
		summary_cnt = cov_unit_summary->summary_cnt
		unit_cnt = 0
		room_bed_cnt = 0
	head unit
		call writeLog(build2("-->inside unit query for ",trim(cov_unit_summary->patient_qual[d1.seq].unit)))
		unit_cnt = (unit_cnt + 1)
		cov_unit_summary->summary_qual[summary_cnt].unit_cnt = unit_cnt
		stat = alterlist(cov_unit_summary->summary_qual[summary_cnt].unit_qual,unit_cnt)
		cov_unit_summary->summary_qual[summary_cnt].unit_qual[unit_cnt].unit = trim(cov_unit_summary->patient_qual[d1.seq].unit)
		room_bed_cnt = 0
	head room_bed
		call writeLog(build2("-->inside cov_unit_summary query for ",trim(cov_unit_summary->patient_qual[d1.seq].room_bed)))
		room_bed_cnt = (room_bed_cnt + 1)
		cov_unit_summary->summary_qual[summary_cnt].unit_qual[unit_cnt].room_bed_cnt = room_bed_cnt
		stat = alterlist(cov_unit_summary->summary_qual[summary_cnt].unit_qual[unit_cnt].room_bed_qual,room_bed_cnt)
		cov_unit_summary->summary_qual[summary_cnt].unit_qual[unit_cnt].room_bed_qual[room_bed_cnt].room_bed = trim(
		cov_unit_summary->patient_qual[d1.seq].room_bed)
	head encntr_id
		call writeLog(build2("--->analyzing encntr_id=",trim(cnvtstring(encntr_id))))
		if (cov_unit_summary->patient_qual[d1.seq].confirmed = "Y")
			call writeLog(build2("--->analyzing confirmed=",trim(cov_unit_summary->patient_qual[d1.seq].confirmed)))
			cov_unit_summary->summary_qual[summary_cnt].unit_qual[unit_cnt].room_bed_qual[room_bed_cnt].confirmed = "Y"
	 	endif
	 	if (cov_unit_summary->patient_qual[d1.seq].suspected = "Y")
			call writeLog(build2("--->analyzing suspected=",trim(cov_unit_summary->patient_qual[d1.seq].suspected)))
			cov_unit_summary->summary_qual[summary_cnt].unit_qual[unit_cnt].room_bed_qual[room_bed_cnt].suspected = "Y"
	 	endif
	foot room_bed
		call writeLog(build2("-->leaving room_bed query for ",trim(location_list->locations[i].display)))
	foot unit
		call writeLog(build2("-->leaving unit query for ",trim(location_list->locations[i].display)))
	foot facility
		call writeLog(build2("-->leaving facility query for ",trim(location_list->locations[i].display)))
	foot report
		call writeLog(build2("-->leaving cov_unit_summary query for ",trim(location_list->locations[i].display)))
		call writeLog(build2("-->cov_unit_summary->summary_cnt=",trim(cnvtstring(cov_unit_summary->summary_cnt))))
	with nocounter,nullreport
endfor
	
call writeLog(build2("* END   Building Facility Unit *****************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Output   *******************************************"))
if (t_rec->prompt_report_type = 1)

select into $OUTDEV
	 facility 					= trim(nhsn_covid19->summary_qual[d1.seq].facility)
	,collectiondate				= trim(format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy;;d"))
	,numc19confnewadm			= nhsn_covid19->summary_qual[d1.seq].qa_numc19confnewadm
	,numc19suspnewadm			= nhsn_covid19->summary_qual[d1.seq].qb_numc19suspnewadm
	,numc19honewpats			= nhsn_covid19->summary_qual[d1.seq].qc_numc19honewpats
	,numc19hosppats_susp		= nhsn_covid19->summary_qual[d1.seq].q1_ip_suspected
	,numc19hosppats_conf		= nhsn_covid19->summary_qual[d1.seq].q1_ip_confirmed
	,numc19hosppats				= nhsn_covid19->summary_qual[d1.seq].q1_total
	,numc19mechventpats_susp	= nhsn_covid19->summary_qual[d1.seq].q2_ip_suspected_vent
	,numc19mechventpats_conf	= nhsn_covid19->summary_qual[d1.seq].q2_ip_confirmed_vent
	,numc19mechventpats			= nhsn_covid19->summary_qual[d1.seq].q2_total
	,numc19hopats	 			= nhsn_covid19->summary_qual[d1.seq].q3_ip_conf_susp_los14
	,numc19overflowpats			= nhsn_covid19->summary_qual[d1.seq].q4_ed_of_conf_susp_wait
	,numc19ofmechventpats		= nhsn_covid19->summary_qual[d1.seq].q5_ed_of_conf_susp_wait_vent
	;,numc19died					= nhsn_covid19->summary_qual[d1.seq].q6a_all_expired
	,numc19died					= nhsn_covid19->summary_qual[d1.seq].q6_disch_expired
	,numc19prevdied				= nhsn_covid19->summary_qual[d1.seq].q6_disch_expired
	,numtotbeds 				= nhsn_covid19->summary_qual[d1.seq].q7_all_beds_total
	,numbeds 					= nhsn_covid19->summary_qual[d1.seq].q8_all_beds_total_surge
	,numbedsocc 				= nhsn_covid19->summary_qual[d1.seq].q9_occupied_ip_beds
	,numicubeds 				= nhsn_covid19->summary_qual[d1.seq].q10_avail_icu_beds
	,numicubedsocc 				= nhsn_covid19->summary_qual[d1.seq].q11_occupied_icu_beds
	,numvent					= nhsn_covid19->summary_qual[d1.seq].q12_ventilator_total
	,numventuse					= nhsn_covid19->summary_qual[d1.seq].q13_ventilator_in_use
from
	(dummyt d1 with seq=nhsn_covid19->summary_cnt)
plan d1
order by
	 facility
with nocounter,separator = " ", format

elseif (t_rec->prompt_report_type = 3)

select into $OUTDEV
	 facility 			= trim(hrts_covid19->summary_qual[d1.seq].facility)
	,date				= trim(format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy;;d"))
	,q1_total_pos		= hrts_covid19->summary_qual[d1.seq].q1_total_pos_inp
	,q1_1_icu_pos		= hrts_covid19->summary_qual[d1.seq].q1_1_icu_pos_inp
	,q1_2_inp_pos_vent	= hrts_covid19->summary_qual[d1.seq].q1_2_pos_inp_vent
	,q2_total_susp		= hrts_covid19->summary_qual[d1.seq].q2_total_pend_inp
	,q2_1_icu_susp		= hrts_covid19->summary_qual[d1.seq].q2_1_icu_pend_inp
	,q2_2_inp_susp_vent	= hrts_covid19->summary_qual[d1.seq].q2_2_pend_inp_vent
from
	(dummyt d1 with seq=hrts_covid19->summary_cnt)
plan d1
order by
	 facility
with nocounter,separator = " ", format

elseif (t_rec->prompt_report_type = 4)

select into $OUTDEV
	 facility 				= trim(hrts_covid19->patient_qual[d1.seq].facility)
	,unit	 				= trim(substring(1,30,hrts_covid19->patient_qual[d1.seq].unit))
	,encntr_type			= trim(substring(1,30,hrts_covid19->patient_qual[d1.seq].encntr_type))
	,patient				= substring(1,50,hrts_covid19->patient_qual[d1.seq].patient_name)
	,fin					= substring(1,10,hrts_covid19->patient_qual[d1.seq].fin)
	,room_bed				= substring(1,10,hrts_covid19->patient_qual[d1.seq].room_bed)
	,location_class_1		= substring(1,10,hrts_covid19->patient_qual[d1.seq].location_class_1)
	,los_days				= substring(1,6,cnvtstring(round(hrts_covid19->patient_qual[d1.seq].los_days,0),17,0))
	,pso					= substring(1,50,hrts_covid19->patient_qual[d1.seq].ip_pso)
	,diagnosis				= substring(1,50,hrts_covid19->patient_qual[d1.seq].diagnosis)
	,covid19_order			= substring(1,50,hrts_covid19->patient_qual[d1.seq].covid19_order)
	,covid19_result			= substring(1,50,hrts_covid19->patient_qual[d1.seq].covid19_result)
	,ventilator_type		= substring(1,50,hrts_covid19->patient_qual[d1.seq].ventilator_result)
	,ventilator_model		= substring(1,20,hrts_covid19->patient_qual[d1.seq].ventilator_model)
	,confirmed				= substring(1,50,hrts_covid19->patient_qual[d1.seq].confirmed)
	,suspected				= substring(1,50,hrts_covid19->patient_qual[d1.seq].suspected)
	,ventilator				= substring(1,50,hrts_covid19->patient_qual[d1.seq].ventilator)
	,expired				= substring(1,50,hrts_covid19->patient_qual[d1.seq].expired)
	,person_id				= hrts_covid19->patient_qual[d1.seq].person_id
	,encntr_id				= hrts_covid19->patient_qual[d1.seq].encntr_id
from
	(dummyt d1 with seq=hrts_covid19->patient_cnt)
plan d1
order by
	 facility
	,unit
	,room_bed
	,patient
with nocounter,separator = " ", format

elseif (t_rec->prompt_report_type = 2)

select into $OUTDEV
	 facility 				= trim(nhsn_covid19->patient_qual[d1.seq].facility)
	,unit	 				= trim(substring(1,30,nhsn_covid19->patient_qual[d1.seq].unit))
	,encntr_type			= trim(substring(1,30,nhsn_covid19->patient_qual[d1.seq].encntr_type))
	,patient				= substring(1,50,nhsn_covid19->patient_qual[d1.seq].patient_name)
	,fin					= substring(1,10,nhsn_covid19->patient_qual[d1.seq].fin)
	,room_bed				= substring(1,10,nhsn_covid19->patient_qual[d1.seq].room_bed)
	,location_class_1		= substring(1,10,nhsn_covid19->patient_qual[d1.seq].location_class_1)
	,los_days				= substring(1,6,cnvtstring(round(nhsn_covid19->patient_qual[d1.seq].los_days,0),17,0))
	,pso					= substring(1,50,nhsn_covid19->patient_qual[d1.seq].ip_pso)
	,diagnosis				= substring(1,50,nhsn_covid19->patient_qual[d1.seq].diagnosis)
	,covid19_order			= substring(1,50,nhsn_covid19->patient_qual[d1.seq].covid19_order)
	,covid19_result			= substring(1,50,nhsn_covid19->patient_qual[d1.seq].covid19_result)
	,ventilator_type		= substring(1,50,nhsn_covid19->patient_qual[d1.seq].ventilator_result)
	,ventilator_model		= substring(1,20,nhsn_covid19->patient_qual[d1.seq].ventilator_model)
	,confirmed				= substring(1,50,nhsn_covid19->patient_qual[d1.seq].confirmed)
	,suspected				= substring(1,50,nhsn_covid19->patient_qual[d1.seq].suspected)
	,prev_admission			= substring(1,50,nhsn_covid19->patient_qual[d1.seq].prev_admission)
	,prev_onset				= substring(1,50,nhsn_covid19->patient_qual[d1.seq].prev_onset)
	,ventilator				= substring(1,50,nhsn_covid19->patient_qual[d1.seq].ventilator)
	,expired				= substring(1,50,nhsn_covid19->patient_qual[d1.seq].expired)
	,person_id				= nhsn_covid19->patient_qual[d1.seq].person_id
	,encntr_id				= nhsn_covid19->patient_qual[d1.seq].encntr_id
from
	(dummyt d1 with seq=nhsn_covid19->patient_cnt)
plan d1
order by
	 facility
	,unit
	,room_bed
	,patient
with nocounter,separator = " ", format

elseif (t_rec->prompt_report_type = 5)

select into $OUTDEV
	 facility 	= substring(1,10,cov_unit_summary->summary_qual[d1.seq].facility)
	,unit 		= substring(1,20,cov_unit_summary->summary_qual[d1.seq].unit_qual[d2.seq].unit)
	,room_bed 	= substring(1,20,cov_unit_summary->summary_qual[d1.seq].unit_qual[d2.seq].room_bed_qual[d3.seq].room_bed)
	,suspected	= cov_unit_summary->summary_qual[d1.seq].unit_qual[d2.seq].room_bed_qual[d3.seq].suspected
	,confirmed	= cov_unit_summary->summary_qual[d1.seq].unit_qual[d2.seq].room_bed_qual[d3.seq].confirmed
from
	 (dummyt d1 with seq=cov_unit_summary->summary_cnt)
	,(dummyt d2 with seq=1)
	,(dummyt d3 with seq=1)
plan d1	
	where maxrec(d2,size(cov_unit_summary->summary_qual[d1.seq].unit_qual,5))
join d2
	where maxrec(d3,size(cov_unit_summary->summary_qual[d1.seq].unit_qual[d2.seq].room_bed_qual,5))
join d3
order by
	 facility
	,unit
	,room_bed
head report
	row +1 "<html>"
	row +1 "<head>"
	row +1 "<title>COVID-19 Facility Dashboard</title>"
	row +1 "</head>"
	row +1 "<body>"
	call print(concat("<table border='1' padding=5 width=300>"))
	call print(concat("<tr><th>Facility</th><th>Unit</th><th>Room</th><th>Status</th></tr>"))
head facility
	row +1
	;call print(concat("<tr><td colspan=3><b>",trim(cov_unit_summary->summary_qual[d1.seq].facility),"</b></td></tr>"))
head unit
	row +1
	;call print(concat("<tr><td colspan=3>",trim(cov_unit_summary->summary_qual[d1.seq].unit_qual[d2.seq].unit),"</td></tr>"))
detail
	call print(concat("<tr>"))
	call print(concat("<td>",trim(cov_unit_summary->summary_qual[d1.seq].facility),"</td>"))
	call print(concat("<td>",trim(cov_unit_summary->summary_qual[d1.seq].unit_qual[d2.seq].unit),"</td>"))
	call print(concat("<td>",trim(cov_unit_summary->summary_qual[d1.seq].unit_qual[d2.seq].room_bed_qual[d3.seq].room_bed),"</td>"))
	if (cov_unit_summary->summary_qual[d1.seq].unit_qual[d2.seq].room_bed_qual[d3.seq].confirmed = "Y")
		call print(concat("<td>Confirmed</td>"))
	elseif (cov_unit_summary->summary_qual[d1.seq].unit_qual[d2.seq].room_bed_qual[d3.seq].suspected = "Y")
		call print(concat("<td>Suspected</td>"))
	endif
	call print(concat("</tr>"))
foot unit
	row +1
foot facility
	row +1
foot report
	call print(concat("</table>"))
	row +1 "</body>"
	row +1 "</html>"
with nocounter,maxcol=32000,outerjoin=d2,outerjoin=d3

else
select into $OUTDEV
	 facility 				= trim(t_output->qual[d1.seq].facility)
	,unit	 				= trim(substring(1,30,t_output->qual[d1.seq].unit))
	,encntr_type			= trim(substring(1,30,t_output->qual[d1.seq].encntr_type))
	,patient				= substring(1,50,t_output->qual[d1.seq].patient_name)
	,fin					= substring(1,10,t_output->qual[d1.seq].fin)
	,room_bed				= substring(1,10,t_output->qual[d1.seq].room_bed)
	,location_class_1		= substring(1,10,t_output->qual[d1.seq].location_class_1)
	,arrive_dt_tm			= substring(1,20,t_output->qual[d1.seq].arrive_dt_tm)
	,reg_dt_tm				= substring(1,20,t_output->qual[d1.seq].reg_dt_tm)
	,inpatient_dt_tm		= substring(1,20,t_output->qual[d1.seq].inpatient_dt_tm)
	,observation_dt_tm		= substring(1,20,t_output->qual[d1.seq].observation_dt_tm)
	,expired_dt_tm			= substring(1,20,t_output->qual[d1.seq].expired_dt_tm)
	,los_days				= substring(1,6,cnvtstring(round(t_output->qual[d1.seq].los_days,0),17,0))
	,los_hours				= substring(1,6,cnvtstring(round(t_output->qual[d1.seq].los_hours,0),17,0))
	,pso					= substring(1,50,t_output->qual[d1.seq].pso)
	,diagnosis				= substring(1,50,t_output->qual[d1.seq].diagnosis)
	,covid19_order			= substring(1,50,t_output->qual[d1.seq].covid19_order)
	,covid19_order_dt_tm	= substring(1,50,t_output->qual[d1.seq].covid19_order_dt_tm)
	,covid19_result			= substring(1,50,t_output->qual[d1.seq].covid19_result)
	,covid19_result_dt_tm	= substring(1,50,t_output->qual[d1.seq].covid19_result_dt_tm)
	,ventilator_type		= substring(1,50,t_output->qual[d1.seq].ventilator_type)
	,ventilator				= substring(1,50,t_output->qual[d1.seq].ventilator)
	,ventilator_model		= substring(1,20,t_output->qual[d1.seq].ventilator_model)
	,ventilator_dt_tm		= substring(1,50,t_output->qual[d1.seq].ventilator_dt_tm)
	,suspected_onset_dt_tm	= substring(1,50,t_output->qual[d1.seq].suspected_onset_dt_tm)
	,positive_onset_dt_tm	= substring(1,50,t_output->qual[d1.seq].positive_onset_dt_tm)
	,person_id				= t_output->qual[d1.seq].person_id
	,encntr_id				= t_output->qual[d1.seq].encntr_id
	,positive_ind			= t_output->qual[d1.seq].positive_ind
	,suspected_ind			= t_output->qual[d1.seq].suspected_ind
	,ventilator_ind			= t_output->qual[d1.seq].ventilator_ind
	,covenant_vent_stock_ind= t_output->qual[d1.seq].covenant_vent_stock_ind
	,expired_ind			= t_output->qual[d1.seq].expired_ind
	,previous_admission_ind	= t_output->qual[d1.seq].previous_admission_ind
	,previous_onset_ind		= t_output->qual[d1.seq].previous_onset_ind
from
	(dummyt d1 with seq=t_output->cnt)
plan d1
order by
	 facility
	,unit
	,room_bed
	,patient
with nocounter,separator = " ", format
endif

set reply->status_data.status = "S"

call writeLog(build2("* END   Output   *******************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("* START Checking Final Status ******************************"))
if (reply->status_data.status = "F") ;t_rec->cnt = 0
	set program_log->display_on_exit = 1
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "RESULTS"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "RESULTS"
	set reply->status_data.subeventstatus.targetobjectvalue = "No data was found"
	go to exit_script
endif
call writeLog(build2("* START Checking Final Status ******************************"))

#exit_script
if (reply->status_data.status = "F")
	call writeLog(build2(cnvtrectojson(reply)))
endif

call echojson(t_rec, concat("cclscratch:",t_rec->records_attachment) , 1) 
call echojson(t_output, concat("cclscratch:",t_rec->records_attachment) , 1) 
call echojson(nhsn_covid19, concat("cclscratch:",t_rec->records_attachment) , 1) 
call echojson(hrts_covid19, concat("cclscratch:",t_rec->records_attachment) , 1) 
call echojson(cov_unit_summary, concat("cclscratch:",t_rec->records_attachment) , 1) 

call addAttachment(program_log->files.file_path, t_rec->records_attachment) 

call exitScript(null)
;call echorecord(code_values)
call echorecord(program_log)
call echorecord(cov_unit_summary)


end
go

