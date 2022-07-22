/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		06/01/2020
	Solution:			
	Source file name:	cov_pcs_add_covid_aoe.prg
	Object name:		cov_pcs_add_covid_aoe
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
drop program cov_pcs_add_covid_aoe:dba go
create program cov_pcs_add_covid_aoe:dba
 
 
/*   
free record request go
record REQUEST (
  1 order_id = f8   
  1 catalog_cd = f8   
  1 accession_id = f8   
  1 accession = vc  
  1 order_mnemonic = vc  
  1 result_list [*]   
    2 oe_field_id = f8   
    2 result_value = f8   
    2 result_dt_tm_value = dq8   
    2 result_display_value = vc  
  1 result_personnel_id = f8   
) go
*/

free record 1050056_request 
record 1050056_request (
  1 order_id = f8   
  1 catalog_cd = f8   
  1 accession_id = f8   
  1 accession = vc  
  1 order_mnemonic = vc  
  1 result_list [*]   
    2 oe_field_id = f8   
    2 result_value = f8   
    2 result_dt_tm_value = dq8   
    2 result_display_value = vc  
  1 result_personnel_id = f8   
) 
call echo(build("setting up t_rec"))

record t_rec
(
	1 log_message 			= vc
	1 misc1					= vc
	1 retval 				= i2
	1 prompt_oef			= vc
	1 version_1_0			= i2
 	1 log_filename 			= vc
 	1 result_personnel_id 	= f8
	1 accession				= vc
	1 accession_id			= f8
	1 order_mnemonic		= vc 
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
	1 result_val
	 2 yes					= f8
	 2 no					= f8
	 2 pregnant				= f8
	 2 not_pregnant			= f8
	 2 unknown				= f8
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

declare result_cnt = i2 
declare temp_display_value = vc
declare temp_value = f8

set t_rec->retval 		= -1 ;initialize to failed
set t_rec->encntr_id	= link_encntrid
set t_rec->person_id    = link_personid
set t_rec->order_id  	= link_orderid

set t_rec->log_message = concat(trim(cnvtstring(link_encntrid)),":",trim(cnvtstring(t_rec->encntr_id)))

if (t_rec->encntr_id = 0.0)
	go to exit_script
endif

if (t_rec->person_id = 0.0)
	go to exit_script
endif

if (t_rec->order_id  = 0.0)
	go to exit_script
endif

set t_rec->log_filename = concat("cclscratch:",trim(cnvtlower(curprog)),"_",trim(format(sysdate,"mmdd_hhmmss;;d")),"_rec.dat")

set t_rec->result_val.no				= 959903
set t_rec->result_val.not_pregnant		= 292428329
set t_rec->result_val.pregnant			= 292428327
set t_rec->result_val.unknown			= 281017135
set t_rec->result_val.yes				= 959901


select into "nl:"
from
	orders o
	,accession_order_r aor
plan o
	where o.order_id = t_rec->order_id
join aor
	where aor.order_id = o.order_id
detail
	t_rec->catalog_cd = o.catalog_cd
	t_rec->person_id  = o.person_id
	t_rec->encntr_id  = o.encntr_id
	t_rec->accession  = aor.accession
	t_rec->accession_id = aor.accession_id
	t_rec->order_mnemonic = o.order_mnemonic
	t_rec->result_personnel_id = 1.0
with nocounter

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

call echo(build("setting up general info"))
set 1050056_request->order_id 			=		 t_rec->order_id                          
set 1050056_request->catalog_cd 		=		t_rec->catalog_cd                      
set 1050056_request->accession_id 		=		t_rec->accession_id		
set 1050056_request->accession 			=		t_rec->accession
set 1050056_request->order_mnemonic 	=		t_rec->order_mnemonic
set 1050056_request->result_personnel_id =		t_rec->result_personnel_id



/*
set 1050056_request->result_list[result_cnt].oe_field_id			= 
set 1050056_request->result_list[result_cnt].result_value			=
set 1050056_request->result_list[result_cnt].result_dt_tm_value		=
set 1050056_request->result_list[result_cnt].result_display_value	=
*/
set result_cnt = (result_cnt + 1)
set stat = alterlist(1050056_request->result_list,result_cnt)
set 1050056_request->result_list[result_cnt].oe_field_id			= t_rec->first_test_id
set 1050056_request->result_list[result_cnt].result_value			= t_rec->result_val.unknown
set 1050056_request->result_list[result_cnt].result_display_value	= "Unknown"

if (t_rec->covid19_first_test_question_result = "Yes")
	set 1050056_request->result_list[result_cnt].result_value			= t_rec->result_val.no
	set 1050056_request->result_list[result_cnt].result_display_value	= "No"
elseif (t_rec->covid19_first_test_question_result = "No")
	set 1050056_request->result_list[result_cnt].result_value			= t_rec->result_val.yes
	set 1050056_request->result_list[result_cnt].result_display_value	= "Yes"
else
	set 1050056_request->result_list[result_cnt].result_value			= t_rec->result_val.unknown
	set 1050056_request->result_list[result_cnt].result_display_value	= "Unknown"
endif

set result_cnt = (result_cnt + 1)
set stat = alterlist(1050056_request->result_list,result_cnt)
set 1050056_request->result_list[result_cnt].oe_field_id			= t_rec->employed_in_healtcare_id
set 1050056_request->result_list[result_cnt].result_value			= t_rec->result_val.unknown
set 1050056_request->result_list[result_cnt].result_display_value	= "Unknown"

if (t_rec->covid19_healthcare_worker_result > "")
	if (t_rec->covid19_healthcare_worker_result = "Yes")
		set 1050056_request->result_list[result_cnt].result_value			= t_rec->result_val.yes
		set 1050056_request->result_list[result_cnt].result_display_value	= "Yes"
	elseif (t_rec->covid19_healthcare_worker_result = "No")
		set 1050056_request->result_list[result_cnt].result_value			= t_rec->result_val.no
		set 1050056_request->result_list[result_cnt].result_display_value	= "No"
	else
		set 1050056_request->result_list[result_cnt].result_value			= t_rec->result_val.unknown
		set 1050056_request->result_list[result_cnt].result_display_value	= "Unknown"
	endif
else
	set 1050056_request->result_list[result_cnt].result_value			= t_rec->result_val.unknown
	set 1050056_request->result_list[result_cnt].result_display_value	= "Unknown"
endif


set result_cnt = (result_cnt + 1)
set stat = alterlist(1050056_request->result_list,result_cnt)
set 1050056_request->result_list[result_cnt].oe_field_id			= t_rec->symptomatic_id
set 1050056_request->result_list[result_cnt].result_value			= t_rec->result_val.unknown
set 1050056_request->result_list[result_cnt].result_display_value	= "Unknown"

if (t_rec->covid_risk_result = "None of the above")
	set 1050056_request->result_list[result_cnt].result_value			= t_rec->result_val.no
	set 1050056_request->result_list[result_cnt].result_display_value	= "No"
elseif (t_rec->covid_risk_result = "Unable*")
	set 1050056_request->result_list[result_cnt].result_value			= t_rec->result_val.unknown
	set 1050056_request->result_list[result_cnt].result_display_value	= "Unknown"
else
	if (t_rec->covid19_symptoms_start_date_result > " ")
		set 1050056_request->result_list[result_cnt].result_value			= t_rec->result_val.yes
		set 1050056_request->result_list[result_cnt].result_display_value	= "Yes"
		set result_cnt = (result_cnt + 1)
		set stat = alterlist(1050056_request->result_list,result_cnt)
		set 1050056_request->result_list[result_cnt].oe_field_id			= t_rec->symptoms_start_dt_tm_id
		set 1050056_request->result_list[result_cnt].result_dt_tm_value		
				= cnvtdatetime(t_rec->covid19_symptoms_start_date_result)
		set 1050056_request->result_list[result_cnt].result_display_value	= t_rec->covid19_symptoms_start_date_result
	endif
endif


set result_cnt = (result_cnt + 1)
set stat = alterlist(1050056_request->result_list,result_cnt)
set 1050056_request->result_list[result_cnt].oe_field_id			= t_rec->hopsitalized_id
set 1050056_request->result_list[result_cnt].result_value			= t_rec->result_val.unknown
set 1050056_request->result_list[result_cnt].result_display_value	= "Unknown"

if (t_rec->inpatient_dt_tm > 0.0)
	set 1050056_request->result_list[result_cnt].result_value			= t_rec->result_val.yes
	set 1050056_request->result_list[result_cnt].result_display_value	= "Yes"
else
	set 1050056_request->result_list[result_cnt].result_value			= t_rec->result_val.no
	set 1050056_request->result_list[result_cnt].result_display_value	= "No"
endif

set result_cnt = (result_cnt + 1)
set stat = alterlist(1050056_request->result_list,result_cnt)
set 1050056_request->result_list[result_cnt].oe_field_id			= t_rec->icu_id
set 1050056_request->result_list[result_cnt].result_value			= t_rec->result_val.unknown
set 1050056_request->result_list[result_cnt].result_display_value	= "Unknown"

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
		1050056_request->result_list[result_cnt].result_value			= t_rec->result_val.no
		1050056_request->result_list[result_cnt].result_display_value	= "No"
	detail
		1050056_request->result_list[result_cnt].result_value			= t_rec->result_val.yes
		1050056_request->result_list[result_cnt].result_display_value	= "Yes"
	with nullreport,nocounter


set result_cnt = (result_cnt + 1)
set stat = alterlist(1050056_request->result_list,result_cnt)
set 1050056_request->result_list[result_cnt].oe_field_id			= t_rec->congregate_care_setting_id
set 1050056_request->result_list[result_cnt].result_value			= t_rec->result_val.unknown
set 1050056_request->result_list[result_cnt].result_display_value	= "Unknown"

if (t_rec->covid19_congregate_question_result > "")
	if (t_rec->covid19_congregate_question_result = "Yes")
		set 1050056_request->result_list[result_cnt].result_value			= t_rec->result_val.yes
		set 1050056_request->result_list[result_cnt].result_display_value	= "Yes"
	elseif (t_rec->covid19_congregate_question_result = "No")
		set 1050056_request->result_list[result_cnt].result_value			= t_rec->result_val.no
		set 1050056_request->result_list[result_cnt].result_display_value	= "No"
	endif
endif

set result_cnt = (result_cnt + 1)
set stat = alterlist(1050056_request->result_list,result_cnt)
set 1050056_request->result_list[result_cnt].oe_field_id			= t_rec->pregnant_id
set 1050056_request->result_list[result_cnt].result_value			= t_rec->result_val.unknown
set 1050056_request->result_list[result_cnt].result_display_value	= "Unknown"

if (uar_get_code_meaning(t_rec->sex_cd) = "MALE")
	set 1050056_request->result_list[result_cnt].result_value			= t_rec->result_val.not_pregnant
	set 1050056_request->result_list[result_cnt].result_display_value	= "Not Pregnant"
else
	if (t_rec->pregnancy_result = "Confirmed positive")
		set 1050056_request->result_list[result_cnt].result_value			= t_rec->result_val.pregnant
		set 1050056_request->result_list[result_cnt].result_display_value	= "Pregnant"
	elseif (t_rec->pregnancy_result in("Patient denies","Confirmed negative"))
		set 1050056_request->result_list[result_cnt].result_value			= t_rec->result_val.not_pregnant
		set 1050056_request->result_list[result_cnt].result_display_value	= "Not Pregnant"
	endif
endif

free record 1050056_reply
set stat = tdbexecute(560201,273020,1050056,"REC",1050056_request,"REC",1050056_reply)
;execute pcs_upd_prompt_results with replace("REQUEST",1050056_request)
commit 
#exit_script

set t_rec->log_message = concat(trim(t_rec->log_message),";",trim(cnvtrectojson(1050056_reply)))
set t_rec->retval = 100
set t_rec->log_message = t_rec->misc1

set retval		= t_rec->retval
set log_misc1 	= t_rec->misc1
set log_message = t_rec->log_message

;call echojson(t_rec,	t_rec->log_filename,1)
;call echojson(eksdata,	t_rec->log_filename,1)
;call echojson(request,	t_rec->log_filename,1)
;call echojson(reqinfo,	t_rec->log_filename,1)
call echorecord(t_rec)
call echorecord(1050056_request)
call echorecord(1050056_reply)
 
end
go
 
 
 
