/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		06/01/2020
	Solution:			Perioperative
	Source file name:	cov_eks_covid19_oef.prg
	Object name:		cov_eks_covid19_oef
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	06/01/2020	  Chad Cummings
******************************************************************************/
drop program cov_eks_covid19_oef:dba go
create program cov_eks_covid19_oef:dba

prompt 
	"OEF" = "" 

with OEF

 
call echo(build("setting up t_rec"))

record t_rec
(
	1 log_message 			= vc
	1 misc1					= vc
	1 retval 				= i2
	1 prompt_oef			= vc
	1 version_1_0			= i2
	1 log_filename 			= vc
    1 encntr_id             = f8   
    1 person_id             = f8   
    1 synonym_id            = f8   
    1 catalog_cd            = f8   
    1 order_id              = f8   	
    1 sex_cd				= f8
    1 fin 					= vc
	1 name					= vc
	1 facility				= vc
	1 unit					= vc
	1 facility_cd			= f8
	1 unit_cd				= f8
	1 room_cd				= f8
	1 room					= vc
	1 encntr_type			= vc
	1 encntr_type_cd		= f8
	1 inpatient_dt_tm		= dq8
	1 symptomatic_ind		= i2
	1 cnt 					= i2
	1 qual[*]
	 2 event_id				= f8
	 2 event_cd				= f8
	 2 event_display		= vc
	 2 event_end_dt_tm		= dq8
	 2 result_val			= vc
	 2 result_dt_tm			= dq8
%i cust_script:cov_oef_covid19.inc
)

call echo(build("setting up subroutines"))
%i cust_script:cov_sub_covid19.inc

call echo(build("setting up base values")) 
set reply_cnt = 0
declare temp_display_value = vc
declare temp_value = f8

set t_rec->retval 		= -1 ;initialize to failed
set t_rec->encntr_id	= link_encntrid
set t_rec->person_id    = link_personid
set t_rec->prompt_oef	= $OEF

set t_rec->log_message = concat(trim(cnvtstring(link_encntrid)),":",trim(cnvtstring(t_rec->encntr_id)))

if (t_rec->encntr_id = 0.0)
	go to exit_script
endif

if (t_rec->person_id = 0.0)
	go to exit_script
endif

set t_rec->log_filename = concat("cclscratch:",trim(cnvtlower(curprog)),"_",trim(format(sysdate,"mmdd_hhmmss;;d")),"_rec.dat")


call echo(build("setting up get_oef_fields"))
call get_oef_fields(0)

call echo(build("setting up get_event_codes"))
call get_event_codes(0)

call echo(build("setting up get_results"))
call get_results(0)

call echo(build("setting up get_patient_info"))
call get_patient_info(0)

call echo(build("setting up get_pregnancy_status"))
call get_pregnancy_status(0)

set t_rec->misc1 = "Unknown"

if (t_rec->prompt_oef = "First Test")
	if (t_rec->covid19_first_test_question_result = "Yes")
		set t_rec->misc1 = "No" ;The question asked is the opposite responsese 
	elseif (t_rec->covid19_first_test_question_result = "No")
		set t_rec->misc1 = "Yes" ;The question asked is the opposite responsese 
	endif
endif

if (t_rec->prompt_oef = "Employed in Healthcare")
	if (t_rec->covid19_healthcare_worker_result > "")
		set t_rec->misc1 = t_rec->covid19_healthcare_worker_result
	endif
endif

if (t_rec->prompt_oef = "Symptomatic")
	if (t_rec->covid_risk_result = "None of the above")
		set t_rec->misc1 = "No"
	elseif (t_rec->covid_risk_result = "Unable*")
		set t_rec->misc1 = "Unknown"
	else
		if (t_rec->covid19_symptoms_start_date_result > " ")
			set t_rec->misc1 = "Yes"
			set t_rec->symptomatic_ind = 1
		endif
	endif
endif

if (t_rec->prompt_oef = "Date of Onset")
	if (t_rec->covid19_symptoms_start_date_result > " ")
			set t_rec->misc1 = t_rec->covid19_symptoms_start_date_result
			set t_rec->misc1 = format(cnvtdatetime(t_rec->covid19_symptoms_start_date_result),";;q")
			set t_rec->symptomatic_ind = 1
	endif
endif

if (t_rec->prompt_oef = "Hospitalized")
	if (t_rec->inpatient_dt_tm > 0.0)
		set t_rec->misc1 = "Yes"
	else
		set t_rec->misc1 = "No"
	endif
endif

if (t_rec->prompt_oef = "ICU")
	select into "nl:"
	from
		 location l
		,code_value_outbound cvo
	plan l
		where l.location_cd = t_rec->unit_cd
		and   cnvtdatetime(curdate,curtime3) between l.beg_effective_dt_tm and l.end_effective_dt_tm
		and   l.location_type_cd = value(uar_get_code_by("MEANING",222,"NURSEUNIT"))
	join cvo
		where cvo.code_value = l.location_cd
		and   cvo.contributor_source_cd = value(uar_get_code_by("DISPLAY",73,"COVDEV1"))
		and   cvo.alias in("ICU")
	head report
		t_rec->misc = "No"
	detail
		t_rec->misc = "Yes"
	with nullreport,nocounter
endif

if (t_rec->prompt_oef = "Congregate care setting")
	if (t_rec->covid19_congregate_question_result > "")
		set t_rec->misc1 = t_rec->covid19_congregate_question_result
	endif
endif

if (t_rec->prompt_oef = "Pregnant")
	if (uar_get_code_meaning(t_rec->sex_cd) = "MALE")
		set t_rec->misc1 = "Not Pregnant"
	else
		if (t_rec->pregnancy_result = "Confirmed positive")
			set t_rec->misc1 = "Pregnant"	
		elseif (t_rec->pregnancy_result in("Patient denies","Confirmed negative"))
			set t_rec->misc1 = "Not Pregnant"	
		endif
	endif
endif



#exit_script

set t_rec->log_message = concat(trim(t_rec->log_message),";",trim(cnvtrectojson(t_rec)))
set t_rec->retval = 100
set t_rec->log_message = t_rec->misc1

set retval		= t_rec->retval
set log_misc1 	= t_rec->misc1
set log_message = t_rec->log_message

call echojson(t_rec,	t_rec->log_filename,1)
call echojson(eksdata,	t_rec->log_filename,1)
call echojson(request,	t_rec->log_filename,1)
call echojson(reqinfo,	t_rec->log_filename,1)
call echorecord(t_rec)

end
go
 
 
 
