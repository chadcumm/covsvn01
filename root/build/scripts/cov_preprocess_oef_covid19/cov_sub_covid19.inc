declare get_oef_fields(null)=null
subroutine get_oef_fields(null)
	select   into "nl:"
	from
		 order_entry_format oef
		,oe_format_fields off
		,order_entry_fields oef2
	plan oef
		where oef.oe_format_name = "Lab - Quest Coronavirus"
		and   oef.action_type_cd = value(uar_get_code_by("MEANING",6003,"ORDER"))
	join off
		where off.oe_format_id = oef.oe_format_id
	join oef2
		where oef2.oe_field_id = off.oe_field_id
 
		and   oef2.description in(
										 "First Test"
										,"Employed in Healthcare"
										,"Symptomatic"
										,"Hospitalized"
										,"ICU"
										,"Congregate care setting"
										,"Pregnant"
										,"Pregnant - Lab"
										,"Date of Onset"
									)
	order by
		oef2.oe_field_id
	head report
		cnt = 0
	head oef2.oe_field_id
		case (oef2.description)
			of "First Test"					: 	t_rec->first_test_id = oef2.oe_field_id
												t_rec->first_test_mean = oef2.oe_field_meaning_id
			of "Employed in Healthcare"     : 	t_rec->employed_in_healtcare_id = oef2.oe_field_id
												t_rec->employed_in_healtcare_mean = oef2.oe_field_meaning_id
			of "Symptomatic"                : 	t_rec->symptomatic_id = oef2.oe_field_id
												t_rec->symptomatic_mean = oef2.oe_field_meaning_id
			of "Hospitalized"               : 	t_rec->hopsitalized_id = oef2.oe_field_id
												t_rec->hopsitalized_mean = oef2.oe_field_meaning_id
			of "ICU"                        : 	t_rec->icu_id = oef2.oe_field_id
												t_rec->icu_mean = oef2.oe_field_meaning_id
			of "Congregate care setting"    : 	t_rec->congregate_care_setting_id = oef2.oe_field_id
												t_rec->congregate_care_setting_mean = oef2.oe_field_meaning_id
			of "Pregnant"                   : 	t_rec->pregnant_id = oef2.oe_field_id
												t_rec->pregnant_mean = oef2.oe_field_meaning_id
			of "Pregnant - Lab"             : 	t_rec->pregnant_id = oef2.oe_field_id
												t_rec->pregnant_mean = oef2.oe_field_meaning_id
			of "Date of Onset"             : 	t_rec->symptoms_start_dt_tm_id = oef2.oe_field_id
												t_rec->symptoms_start_dt_tm_mean = oef2.oe_field_meaning_id
		endcase
	foot report
		cnt = 0
	with nocounter
end ;get_oef_fields
 
declare get_event_codes(null)=null
subroutine get_event_codes(null)
	select into "nl:"
	from
		code_value cv
	plan cv
		where cv.code_set = 72
		and   cv.display in(	"COVID Risk",
								"COVID-19 congregate question",
								"COVID-19 first test question",
								"COVID-19  first test question",
								"COVID-19 healthcare worker",
								"COVID-19 healthcare worker exposure",
								"COVID-19 symptoms start date",
								"COVID-19 test past 14 days",
								"COVID-19 test past results",
								"Pregnancy Status"
							)
		and	  cv.active_ind = 1
	order by
		 cv.display
		,cv.code_value
	head report
		cnt = 0
	head cv.code_value
		case (cv.display)
			of "COVID Risk"								: t_rec->covid_risk_cd = cv.code_value
			of "COVID-19 congregate question"			: t_rec->covid19_congregate_question_cd = cv.code_value
			of "COVID-19 first test question"         	: t_rec->covid19_first_test_question_cd = cv.code_value
			of "COVID-19  first test question"         	: t_rec->covid19_first_test_question_cd = cv.code_value
			of "COVID-19 healthcare worker"           	: t_rec->covid19_healthcare_worker_cd = cv.code_value
			of "COVID-19 healthcare worker exposure"  	: t_rec->covid19_healthcare_worker_exposure_cd = cv.code_value
			of "COVID-19 symptoms start date"         	: t_rec->covid19_symptoms_start_date_cd = cv.code_value
			of "COVID-19 test past 14 days"           	: t_rec->covid19_test_past_14_days_cd = cv.code_value
			of "COVID-19 test past results"           	: t_rec->covid19_test_past_results_cd = cv.code_value
			of "Pregnancy Status"           			: t_rec->pregnancy_cd = cv.code_value
		endcase
	foot report
		cnt = 0
	with nocounter
end ;get_event_codes
 
declare get_results(null)=null
subroutine get_results(null)
	select into "nl:"
	from
		  clinical_event ce
		 ,ce_date_result cdr
		 ,(dummyt d1)
	plan ce
		where ce.person_id = t_rec->person_id
		and   ce.event_cd in(
								 t_rec->covid_risk_cd
								,t_rec->covid19_congregate_question_cd
								,t_rec->covid19_first_test_question_cd
								,t_rec->covid19_healthcare_worker_cd
								,t_rec->covid19_healthcare_worker_exposure_cd
								,t_rec->covid19_symptoms_start_date_cd
								,t_rec->covid19_test_past_14_days_cd
								,t_rec->covid19_test_past_results_cd
								,t_rec->pregnancy_cd
							)
		and   ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
		and	  ce.result_status_cd in(
										  value(uar_get_code_by("MEANING",8,"AUTH"))
										 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
										 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
									)
		and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
		and   ce.event_tag        != "Date\Time Correction"
		and   ce.result_val        >  " "
	join d1
	join cdr
		where cdr.event_id 			= ce.event_id
		and   cdr.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
		and   cdr.valid_from_dt_tm  <= cnvtdatetime(curdate, curtime3)
	order by
		 ce.person_id
		,ce.event_cd
		,ce.event_end_dt_tm
	head report
		cnt = 0
	head ce.event_cd
		t_rec->cnt = (t_rec->cnt + 1)
		stat = alterlist(t_rec->qual,t_rec->cnt)
		t_rec->qual[t_rec->cnt].event_id 			= ce.event_id
		t_rec->qual[t_rec->cnt].event_cd			= ce.event_cd
	 	t_rec->qual[t_rec->cnt].event_display		= uar_get_code_display(ce.event_cd)
	 	t_rec->qual[t_rec->cnt].event_end_dt_tm		= ce.event_end_dt_tm
	 	t_rec->qual[t_rec->cnt].result_val			= ce.result_val
 
		case (ce.event_cd)
			of t_rec->covid_risk_cd: 								t_rec->covid_risk_result = trim(ce.result_val)
			of t_rec->covid19_congregate_question_cd: 				t_rec->covid19_congregate_question_result = trim(ce.result_val)
			of t_rec->covid19_first_test_question_cd: 				t_rec->covid19_first_test_question_result = trim(ce.result_val)
			of t_rec->covid19_healthcare_worker_cd: 				t_rec->covid19_healthcare_worker_result = trim(ce.result_val)
			of t_rec->covid19_healthcare_worker_exposure_cd: 		t_rec->covid19_healthcare_worker_exposure_result = trim(ce.result_val)
			of t_rec->covid19_symptoms_start_date_cd: 				t_rec->covid19_symptoms_start_date_result
				 = format(cdr.result_dt_tm,"dd-mmm-yyyy;;q")
			of t_rec->covid19_test_past_14_days_cd: 				t_rec->covid19_test_past_14_days_result = trim(ce.result_val)
			of t_rec->covid19_test_past_results_cd: 				t_rec->covid19_test_past_results_result = trim(ce.result_val)
			of t_rec->pregnancy_cd:					 				t_rec->pregnancy_result  = trim(ce.result_val)
		endcase
	foot ce.event_cd
		cnt = 0
	foot report
		cnt = 0
	with nocounter,outerjoin=d1
end ;get_results
 
 
declare get_pregnancy_status(null)=null
subroutine get_pregnancy_status(null)
	;if (t_rec->pregnancy_result = "")
		free record preg_request
		record preg_request
		(
	  		1 patient_id 		= f8
	  		1 encounter_id  = f8
	  		1 org_sec_override = i2
	  	)
 
		set preg_request->patient_id = t_rec->person_id
		set preg_request->org_sec_override = 1
 
		execute dcp_chk_active_preg with replace("REQUEST","PREG_REQUEST"),replace("REPLY","PREG_REPLY")
 
		if (validate(preg_reply->pregnancy_id))
			if (preg_reply->pregnancy_id > 0.0)
				set t_rec->pregnancy_result = "Confirmed positive"
			endif
		endif
	;endif
end ;get_pregnancy_status
 
declare get_patient_info(null)=null
subroutine get_patient_info(null)
	select into "nl:"
	from
		 person p
		,encounter e
		,encntr_alias ea
	plan p
		where p.person_id = t_rec->person_id
	join e
		where e.encntr_id = t_rec->encntr_id
	join ea
		where ea.encntr_id = e.encntr_id
		and   ea.active_ind = 1
		and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
		and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
		and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	order by
		 e.encntr_id
	head report
		t_rec->fin 				= cnvtalias(ea.alias,ea.alias_pool_cd)
		t_rec->sex_cd 			= p.sex_cd
		t_rec->name				= p.name_full_formatted
		t_rec->facility			= uar_get_code_display(e.loc_facility_cd)
		t_rec->unit				= uar_get_code_display(e.loc_nurse_unit_cd)
		t_rec->facility_cd		= e.loc_facility_cd
		t_rec->unit_cd			= e.loc_nurse_unit_cd
		t_rec->room_cd			= e.loc_room_cd
		t_rec->room				= uar_get_code_display(e.loc_room_cd)
		t_rec->encntr_type_cd	= e.encntr_type_cd
		t_rec->encntr_type		= uar_get_code_display(e.encntr_type_cd)
		t_rec->inpatient_dt_tm	= e.inpatient_admit_dt_tm
	with nocounter
end ;get_patient_info
