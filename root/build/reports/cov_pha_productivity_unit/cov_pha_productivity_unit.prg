drop program cov_pha_productivity_unit go
create program cov_pha_productivity_unit

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Enter Start Date" = "SYSDATE"
	, "Enter End Date" = "SYSDATE"
	, "Select Facility" = 0
	, "Nurse Unit" = 0 

with OUTDEV, vStart_dt, vEnd_dt, vFacility, vNurseUnit


record t_rec (
  1 cnt = i2   
  1 prompt_outdev = vc   
  1 prompt_report_type = i2   
  1 override_facility = vc   
  1 verify_period_min = i2   
  1 code_values   
    2 cancelcd = f8   
    2 pharmordcd = f8   
    2 fin = f8   
    2 ordacttype = f8   
    2 dcacttype = f8   
    2 modacttype = f8   
    2 pharmposcd = f8   
    2 pharmt1poscd = f8   
    2 pharmt2poscd = f8   
    2 pharmt3poscd = f8   
    2 pharmmgmntcd = f8   
    2 itpharmnetcd = f8   
    2 techaddrcd = f8   
  1 files   
    2 filename_strata = vc   
    2 filename_rph = vc   
    2 filename_details = vc   
    2 filename_pwafter_hrs = vc   
    2 filename_pwafter_str = vc   
    2 cer_temp = vc   
    2 full_path = vc   
    2 astream_path = vc   
    2 astream_mv = vc   
    2 astream_path_strata = vc   
    2 astream_mv_strata = vc   
  1 query   
    2 new_provider_var = vc   
    2 new_provider_id = f8   
    2 facility_cd = f8   
    2 facility_var = vc   
    2 facoper = vc   
  1 dates   
    2 bdate = dq8   
    2 edate = dq8   
  1 verify_cnt = i4   
  1 verify_qual [*]  
    2 physician_name = vc   
    2 orderable = vc   
    2 synonym = vc   
    2 order_sentence = vc   
    2 ordered_date = c10   
    2 ordered_time = c9   
    2 orig_order_dt_tm = dq8   
    2 action_dt_tm = dq8   
    2 verified_day_of_week = i2   
    2 verified_time_of_day = i2   
    2 verified_date = c10   
    2 verified_time = c9   
    2 verified_dt_tm = dq8   
    2 updt_dt_tm = dq8   
    2 verifying_rph = vc   
    2 verifying_rph_position = vc   
    2 oa_action_type_disp = vc   
    2 oa_order_status_disp = vc   
    2 ordering_facility = vc   
    2 ordering_location = vc   
    2 encntr_type = vc   
    2 encntr_type_class = vc   
    2 patient_type_alias = c1   
    2 tat_minutes = f8   
    2 tat2_minutes = f8   
    2 financial_number = vc   
    2 after_hours_ind = i2   
    2 rph_qualify_ind = i2   
    2 strata_qualify_ind = i2   
    2 strata_after_qualify_ind = i2   
    2 order_id = f8   
    2 loc_facility_cd = f8   
    2 loc_nurse_unit_cd = f8   
    2 encntr_id = f8   
    2 person_id = f8   
    2 verifying_prsnl_id = f8   
    2 location_qualifier = vc   
    2 location_company = vc   
    2 location_department = vc   
    2 original_company = vc   
    2 original_department = vc   
  1 rph_cnt = i2   
  1 rph_qual [*]  
    2 verifying_prsnl_id = f8   
    2 verifying_prsnl = vc   
    2 verifying_prsnl_position = vc   
    2 verify_cnt = i2   
    2 verify_qual [*]  
      3 verified_dt_tm = dq8   
      3 verified_date = c10   
      3 verified_time = c9   
      3 verified_hour = c2   
      3 verified_cnt = i2   
      3 order_id = f8   
      3 location_qualifier = vc   
  1 strata_cnt = i2   
  1 strata_qual [*]  
    2 company = vc   
    2 department = vc   
    2 activity_code = vc   
    2 date_of_service = vc   
    2 weight = vc   
    2 ip_value = vc   
    2 ip_cnt = i2   
    2 op_value = vc   
    2 op_cnt = i2   
    2 total_value = vc   
    2 total_cnt = i2   
  1 strata_after_cnt = i2   
  1 strata_after_qual [*]  
    2 company = vc   
    2 department = vc   
    2 activity_code = vc   
    2 date_of_service = vc   
    2 weight = vc   
    2 ip_value = vc   
    2 ip_cnt = i2   
    2 op_value = vc   
    2 op_cnt = i2   
    2 total_value = vc   
    2 total_cnt = i2   
) with public

/*
create program cov_pha_productivity_rpt
 prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Report Type" = 0
	, "Enter Start Date" = "SYSDATE"
	, "Enter End Date" = "SYSDATE"
	, "Select Facility" = 0
	, "Personnel" = 0
	;<<hidden>>"Search" = ""
	;<<hidden>>"Delete" = "" 

with OUTDEV, REPORT_TYPE, vStart_dt, vEnd_dt, vFacility, NEW_PROVIDER
*/

execute COV_PHA_PRODUCTIVITY_RPT
	  "nl:"
	 ,0
	 ,$vStart_dt
	 ,$vEnd_dt
	 ,$vFacility
	 ,value(0)


select into $OUTDEV
		 physician_name 		= substring(1,200,t_rec->verify_qual[d1.seq].physician_name)
		,orderable 				= substring(1,200,t_rec->verify_qual[d1.seq].orderable)
		,synonym 				= substring(1,200,t_rec->verify_qual[d1.seq].synonym)
		,order_sentence 		= substring(1,200,t_rec->verify_qual[d1.seq].order_sentence)
		,ordered_date 			= substring(1,10,t_rec->verify_qual[d1.seq].ordered_date)
		,ordered_time 			= substring(1,9,t_rec->verify_qual[d1.seq].ordered_time)
		,action_dt_tm 			= substring(1,20,format(t_rec->verify_qual[d1.seq].action_dt_tm,";;q"))
		,updt_dt_tm	 			= substring(1,20,format(t_rec->verify_qual[d1.seq].updt_dt_tm,";;q"))
		,verified_date 			= substring(1,10,t_rec->verify_qual[d1.seq].verified_date)
		,verified_time 			= substring(1,9,t_rec->verify_qual[d1.seq].verified_time)
		,verified_day_of_week 	= t_rec->verify_qual[d1.seq].verified_day_of_week
		,verified_time_of_day 	= t_rec->verify_qual[d1.seq].verified_time_of_day
		,verifying_rph 			= substring(1,200,t_rec->verify_qual[d1.seq].verifying_rph)
		,verifying_rph_position	= substring(1,200,t_rec->verify_qual[d1.seq].verifying_rph_position)
		,oa_action_type_disp 	= substring(1,200,t_rec->verify_qual[d1.seq].oa_action_type_disp)
		,oa_order_status_disp	= substring(1,200,t_rec->verify_qual[d1.seq].oa_order_status_disp)
		,ordering_facility 		= substring(1,30,t_rec->verify_qual[d1.seq].ordering_facility)
		,ordering_location 		= substring(1,30,t_rec->verify_qual[d1.seq].ordering_location)
		,location_qualifer 		= substring(1,30,t_rec->verify_qual[d1.seq].location_qualifier)
		,location_company 		= substring(1,30,t_rec->verify_qual[d1.seq].location_company)
		,location_department	= substring(1,30,t_rec->verify_qual[d1.seq].location_department)
		,patient_type_alias		= substring(1,1,t_rec->verify_qual[d1.seq].patient_type_alias)
		,encntr_type_class		= substring(1,30,t_rec->verify_qual[d1.seq].encntr_type_class)
		,encntr_type			= substring(1,30,t_rec->verify_qual[d1.seq].encntr_type)
		,tat_minutes 			= t_rec->verify_qual[d1.seq].tat_minutes
		,tat2_minutes 			= t_rec->verify_qual[d1.seq].tat2_minutes
		,financial_number 		= substring(1,20,t_rec->verify_qual[d1.seq].financial_number)
		,after_hours_ind		= t_rec->verify_qual[d1.seq].after_hours_ind
		,rph_qualify_ind		= t_rec->verify_qual[d1.seq].rph_qualify_ind
		,strata_qualify_ind		= t_rec->verify_qual[d1.seq].strata_qualify_ind
		,order_id 				= t_rec->verify_qual[d1.seq].order_id
		,loc_facility_cd 		= t_rec->verify_qual[d1.seq].loc_facility_cd
		,encntr_id 				= t_rec->verify_qual[d1.seq].encntr_id
		,person_id 				= t_rec->verify_qual[d1.seq].person_id
		,verifying_prsnl_id 	= t_rec->verify_qual[d1.seq].verifying_prsnl_id
	from
		(dummyt d1 with seq=t_rec->verify_cnt)
		,code_value cv
	plan d1
	join cv
		where cv.code_set = 220
		and   cv.code_value = $vNurseUnit
		and   cv.display = t_rec->verify_qual[d1.seq].ordering_location
	order by
		 ordering_facility
		,verifying_rph
		,verified_date
		,ordered_time
	with nocounter,separator = " ", format
end 
go
