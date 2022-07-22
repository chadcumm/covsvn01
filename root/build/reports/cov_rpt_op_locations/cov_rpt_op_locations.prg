drop program cov_rpt_op_locations go
create program cov_rpt_op_locations 

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to. 

with OUTDEV


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
	  3 dx_category				= vc
	1 diagnosis_cnt				= i2
	1 diagnosis_qual[*]
	 2 nomenclature_id			= f8
	 2 source_string			= vc
	 2 source_vocabulary_cd		= f8
	 2 search_string			= vc
	 2 source_identifier		= vc
	 2 dx_category				= vc
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
	 2 expired_dt_tm			= dq8
	 2 reg_dt_tm				= dq8
	 2 disch_dt_tm				= dq8
	 2 inpatient_dt_tm			= dq8
	 2 observation_dt_tm		= dq8
	 2 arrive_dt_tm				= dq8
	 2 dob						= dq8
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
	  3 result_ignore			= i2
	 2 diagnosis_cnt			= i2
	 2 diagnosis_qual[*]
	  3 diagnosis_id			= f8
	  3 source_string			= vc
	  3 nomenclature_id			= f8
	  3 orig_nomenclature_id	= f8
	  3 orig_source_string		= vc
)

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

declare diagnosis = vc with noconstant(" ")
 
select distinct into $OUTDEV
	 o.org_name
	,location=substring(1,100,t_rec->location_label_qual[d1.seq].display)
	,cv.display
	,cv.description
	,star_alias=substring(1,100,cva.alias)
	,location_type=substring(1,25,uar_get_code_display(l.location_type_cd))
	,location_cd=t_rec->location_label_qual[d1.seq].location_cd
	,covid_reporting=substring(1,5,t_rec->location_label_qual[d1.seq].alias)
from
	(dummyt d1 with seq = t_rec->location_label_cnt)
	,(dummyt d2)
	,location_group lg
	,location l
	,organization o
	,code_value cv
	,code_value_alias cva
plan cva
	where cva.contributor_source_cd = value(uar_get_code_by("DISPLAY",73,"COVENANT"))
join l
	where l.location_cd = cva.code_value
join cv
	where cv.code_value = l.location_cd
join lg
	where lg.child_loc_cd = l.location_cd
join o
	where o.organization_id = l.organization_id
join d2
join d1
	where t_rec->location_label_qual[d1.seq].location_cd = l.location_cd
order by
	o.org_name
	,location
	,star_alias
with format,separator=" ",nocounter,outerjoin=d2


call exitScript(null)
;call echorecord(code_values)
call echorecord(program_log)
call echorecord(t_rec)

end 
go

