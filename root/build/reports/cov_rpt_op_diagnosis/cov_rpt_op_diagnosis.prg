drop program cov_rpt_op_diagnosis go
create program cov_rpt_op_diagnosis 

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
	 2 beg_effective_dt_tm		= dq8
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
	  3 beg_effective_dt_tm     = dq8
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

/*
call writeLog(build2("* START Finding Diagnosis Qualifiers ************************"))
select into "nl:"
from
      code_value cv1
     ,code_value_extension cve1
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog)) 
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "DIAGNOSIS"
join cve1
	where cve1.code_value			= cv1.code_value
	and   cve1.field_name			= "DX_CATEGORY"
order by
	 cve1.field_value
	,cv1.code_value
head report
	call writeLog(build2("->inside diagnosis code_value query"))
head cve1.field_value
	call writeLog(build2("->found cve1.field_value=",trim(cnvtstring(cve1.field_value))))
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
				t_rec->diagnosis_search_qual[t_rec->diagnosis_search_cnt].source_vocabulary_qual[
					t_rec->diagnosis_search_qual[t_rec->diagnosis_search_cnt].source_vocabulary_cnt].dx_category = 
						trim(cve1.field_value)
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
			 if (n.source_string not in(
											 "Educated about 2019 novel coronavirus infection"
											,"Educated about COVID-19 virus infection"
											,"Educated about infection due to severe acute respiratory"
											,"Encounter for laboratory testing for COVID-19 virus"
											,"Encounter for laboratory testing for severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2)"

										))
				call writeLog(build2("-->adding nomen ",trim(n.source_string)," (",trim(n.source_identifier),")"
								 ," [",trim(cnvtstring(n.nomenclature_id)),"]"))			
				t_rec->diagnosis_cnt = (t_rec->diagnosis_cnt + 1)
				stat = alterlist(t_rec->diagnosis_qual,t_rec->diagnosis_cnt)
				t_rec->diagnosis_qual[t_rec->diagnosis_cnt].nomenclature_id 		= n.nomenclature_id
				t_rec->diagnosis_qual[t_rec->diagnosis_cnt].source_string 			= n.source_string
				t_rec->diagnosis_qual[t_rec->diagnosis_cnt].source_vocabulary_cd 	= n.source_vocabulary_cd
				t_rec->diagnosis_qual[t_rec->diagnosis_cnt].source_identifier 		= n.source_identifier
				t_rec->diagnosis_qual[t_rec->diagnosis_cnt].search_string           = t_rec->diagnosis_search_qual[i].search_string
				t_rec->diagnosis_qual[t_rec->diagnosis_cnt].dx_category				
														= t_rec->diagnosis_search_qual[i].source_vocabulary_qual[j].dx_category
			 endif
			with nocounter
			endif
		endfor
	endif
endfor
call writeLog(build2("** Finished Vocabularies ************************"))
call writeLog(build2("* END   Finding Diagnosis Qualifiers ************************"))
*/

call writeLog(build2("* START Finding Diagnosis Qualifiers ************************"))
select into "nl:"
from
      code_value cv1
     ,code_value_extension cve1
plan cv1
	where cv1.code_set 				= t_rec->custom_code_set
	and   cv1.definition 			= trim(cnvtlower(t_rec->curprog)) 
	and   cv1.active_ind 			= 1
	and   cv1.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv1.end_effective_dt_tm 	>= cnvtdatetime(curdate,curtime3)
	and   cv1.cdf_meaning			= "DIAGNOSIS"
join cve1
	where cve1.code_value			= cv1.code_value
	and   cve1.field_name			= "DX_CATEGORY"
order by
	 cve1.field_value
	,cv1.code_value
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
				t_rec->diagnosis_search_qual[t_rec->diagnosis_search_cnt].source_vocabulary_qual[
					t_rec->diagnosis_search_qual[t_rec->diagnosis_search_cnt].source_vocabulary_cnt].dx_category = 
						trim(cve1.field_value)
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
			 if (n.source_string not in(
											 "Educated about 2019 novel coronavirus infection"
											,"Educated about COVID-19 virus infection"
											,"Educated about infection due to severe acute respiratory"
											,"Encounter for laboratory testing for COVID-19 virus"
											,"Encounter for laboratory testing for severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2)"
											,"Advice given about 2019 novel coronavirus by telephone"
											,"Advice given about 2019 novel coronavirus infection"
											,"Advice given about COVID-19 virus by telephone"
											,"Advice given about COVID-19 virus infection"
											,"Advice given about severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) by telephone"
											,"Advice given about severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) infection"
											,"COVID-19 ruled out"
					,"COVID-19 ruled out by clinical criteria"
					,"COVID-19 ruled out by laboratory testing"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) infection ruled out"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) infection ruled out by clinical criteria"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) infection ruled out by laboratory testing"
					,"COVID-19 ruled out"
					,"COVID-19 ruled out by clinical criteria"
					,"COVID-19 ruled out by laboratory testing"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) infection ruled out"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) infection ruled out by clinical criteria"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) infection ruled out by laboratory testing"	
					,"2019 novel coronavirus not detected"
					,"2019 novel coronavirus vaccination contraindicated"
					,"2019 novel coronavirus vaccination declined"
					,"2019 novel coronavirus vaccination not done"
					,"2019 novel coronavirus vaccine not available"
					,"COVID-19 virus antibody negative"
					,"COVID-19 virus not detected"
					,"COVID-19 virus vaccination contraindicated"
					,"COVID-19 virus vaccination declined"
					,"COVID-19 virus vaccination not done"
					,"COVID-19 virus vaccine not available"
					,"Did not attend severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccination"
					,"Educated about infection due to severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2)"
					,"High priority for 2019 novel coronavirus vaccination"
					,"High priority for COVID-19 virus vaccination"
					,"High priority for severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccination"
					,"History of 2019 novel coronavirus disease (COVID-19)"
					,"History of 2019 novel coronavirus disease (COVID-19)"
					,"History of severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) disease"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) antibody negative"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) not detected"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccination contraindicated"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccination declined"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine not administered"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine not available"	
					,"Adverse effect of COVID-19 vaccine"
					,"Adverse effect of severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine"
					,"Allergic reaction to COVID-19 vaccine"
					,"Allergic reaction to severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine"
					,"COVID-19 vaccine administered"
					,"COVID-19 vaccine dose declined"
					,"COVID-19 vaccine dose not administered"
					,"COVID-19 vaccine first dose declined"
					,"COVID-19 vaccine first dose not administered"
					,"COVID-19 vaccine not available"
					,"COVID-19 vaccine second dose declined"
					,"COVID-19 vaccine second dose not administered"
					,"COVID-19 vaccine series completed"
					,"COVID-19 vaccine series contraindicated"
					,"COVID-19 vaccine series declined"
					,"COVID-19 vaccine series not administered"
					,"COVID-19 vaccine series not completed"
					,"COVID-19 vaccine series not indicated"
					,"COVID-19 vaccine series started"
					,"Encounter for administration of COVID-19 vaccine"
					,"Encounter for administration of severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine"
					,"Erythema at injection site of COVID-19 vaccine"
					,"Erythema at injection site of severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine"
					,"Local reaction to COVID-19 vaccine"
					,"Local reaction to severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine"
					,"Need for COVID-19 vaccine"
					,"Need for second dose of COVID-19 vaccine"
					,"Need for second dose of severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine"
					,"Need for severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine"
					,"Pain at injection site of COVID-19 vaccine"
					,"Pain at injection site of severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine administered"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine dose declined"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine dose not administered"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine first dose declined"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine first dose not administered"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine second dose declined"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine second dose not administered"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine series contraindicated"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine series declined"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine series not administered"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine series not completed"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine series not indicated"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine series started"
					,"Status post administration of all doses of COVID-19 vaccine series"
					,"Status post administration of all doses of severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine series"
					,"Swelling at injection site of COVID-19 vaccine"
					,"Swelling at injection site of severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine"
					,"Systemic adverse effect of COVID-19 vaccine"
					,"Systemic adverse effect of severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccine"
					,"Adverse neurologic event after COVID-19 vaccination"
					,"Adverse neurologic event after severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccination"
					,"COVID-19 vaccination contraindicated"
					,"COVID-19 vaccination declined"
					,"COVID-19 vaccination not done"
					,"COVID-19 vaccination refused"
					,"Fatigue after COVID-19 vaccination"
					,"Fatigue after severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccination"
					,"Fever after COVID-19 vaccination"
					,"Fever after severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccination"
					,"High priority for COVID-19 vaccination"
					,"Myalgia after COVID-19 vaccination"
					,"Myalgia after severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccination"
					,"Shortness of breath after COVID-19 vaccination"
					,"Shortness of breath after severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) vaccination"
					,"COVID-19 virus IgG antibody not detected"
					,"COVID-19 virus IgG antibody test result equivocal"
					,"COVID-19 virus IgG antibody test result unknown"
					,"COVID-19 virus IgM antibody not detected"
					,"COVID-19 virus IgM antibody test result equivocal"
					,"COVID-19 virus IgM antibody test result unknown"
					,"COVID-19 virus RNA not detected"
					,"COVID-19 virus RNA test result equivocal"
					,"COVID-19 virus RNA test result unknown"
					,"COVID-19 virus test result equivocal"
					,"COVID-19 virus test result unknown"
					,"Equivocal immunity to COVID-19 virus"
					,"Equivocal immunity to severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2)"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) IgG antibody not detected"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) IgG antibody test result equivocal"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) IgG antibody test result unknown"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) IgM antibody not detected"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) IgM antibody test result equivocal"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) IgM antibody test result unknown"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) RNA not detected"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) RNA test result equivocal"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) RNA test result unknown"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) test result equivocal"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) test result unknown"
					,"Unknown status of immunity to COVID-19 virus"
					,"Unknown status of immunity to severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2)"
					,"COVID-19 virus RNA test result indeterminate"
					,"Severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2) RNA test result indeterminate"
					,"Has immunity to COVID-19 virus"
					,"History of COVID-19"
					,"Immune to severe acute respiratory syndrome coronavirus 2 (SARS-CoV-2)"
					
										))
				call writeLog(build2("-->adding nomen ",trim(n.source_string)," (",trim(n.source_identifier),")"
								 ," [",trim(cnvtstring(n.nomenclature_id)),"]"))			
				t_rec->diagnosis_cnt = (t_rec->diagnosis_cnt + 1)
				stat = alterlist(t_rec->diagnosis_qual,t_rec->diagnosis_cnt)
				t_rec->diagnosis_qual[t_rec->diagnosis_cnt].nomenclature_id 		= n.nomenclature_id
				t_rec->diagnosis_qual[t_rec->diagnosis_cnt].source_string 			= n.source_string
				t_rec->diagnosis_qual[t_rec->diagnosis_cnt].source_vocabulary_cd 	= n.source_vocabulary_cd
				t_rec->diagnosis_qual[t_rec->diagnosis_cnt].source_identifier 		= n.source_identifier
				t_rec->diagnosis_qual[t_rec->diagnosis_cnt].search_string           = t_rec->diagnosis_search_qual[i].search_string
				t_rec->diagnosis_qual[t_rec->diagnosis_cnt].beg_effective_dt_tm		= n.beg_effective_dt_tm
				t_rec->diagnosis_qual[t_rec->diagnosis_cnt].dx_category				
														= t_rec->diagnosis_search_qual[i].source_vocabulary_qual[j].dx_category
			 endif
			with nocounter
			endif
		endfor
	endif
endfor
call writeLog(build2("** Finished Vocabularies ************************"))
call writeLog(build2("* END   Finding Diagnosis Qualifiers ************************"))

declare diagnosis = vc with noconstant(" ")
 
select into $OUTDEV
	 nomen_id = substring(1,10,cnvtstring(t_rec->diagnosis_qual[d1.seq].nomenclature_id))
	,vocabulary = substring(1,10,uar_get_code_display(t_rec->diagnosis_qual[d1.seq].source_vocabulary_cd))
	;,diagnosis = substring(1,100,t_rec->diagnosis_qual[d1.seq].source_string)
	,diagnosis = substring(1,255,t_rec->diagnosis_qual[d1.seq].source_string)
	,code = substring(1,50,t_rec->diagnosis_qual[d1.seq].source_identifier)
	;,beg_effective = format(t_rec->diagnosis_qual[d1.seq].beg_effective_dt_tm,";;q")
	,search_pattern = substring(1,30,t_rec->diagnosis_qual[d1.seq].search_string)
	,dx_category = substring(1,30,t_rec->diagnosis_qual[d1.seq].dx_category)
	,suspected_ind = if (t_rec->diagnosis_qual[d1.seq].source_string in( "SARS-associated coronavirus exposure"
																				,"Exposure to SARS-associated coronavirus"
																				,"Exposure*"
																				,"*exposure*"
																				,"*Person under investigation*"
																				,"Person under investigation*"
																				,"Suspected*")) "X" else "" endif
from
	(dummyt d1 with seq = t_rec->diagnosis_cnt)
order by
	 vocabulary
	,diagnosis
with format,separator=" ",nocounter


call exitScript(null)
;call echorecord(code_values)
call echorecord(program_log)
call echorecord(t_rec)

end 
go

