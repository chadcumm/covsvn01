/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		06/01/2020
	Solution:			Perioperative
	Source file name:	cov_preprocess_oef_covid19.prg
	Object name:		cov_preprocess_oef_covid19
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
drop program cov_ce_from_oef_covid19:dba go
create program cov_ce_from_oef_covid19:dba
 
 
/*   
record request   
(    
     1 encntrid              = f8   
     1 personid              = f8   
     1 synonymid             = f8   
     1 catalogcd             = f8   
     1 orderid               = f8   
     1 detaillist[*]   
       2 oefieldid           = f8   
       2 oefieldvalue        = f8   
       2 oefielddisplayvalue = vc   
       2 oefielddttmvalue    = dq8   
       2 oefieldmeaningid    = f8   
       2 valuerequiredind    = i2   
)  
*/

if (not(validate(reply,0))) 
	record reply (
	  1 status_data
	    2 status = c1
	   2 subeventstatus [1]
	      3 sourceobjectname = c15
	      3 sourceobjectqual = i4
	      3 sourceobjectvalue = c50
	      3 operationname = c15
	      3 operationstatus = c1
	      3 targetobjectname = c15
	      3 targetobjectvalue = c50
	)
endif

free record t_rec
record t_rec
(
%i cust_script:cov_oef_covid19.inc
	1 cnt = i2
	1 patient
	 2 encntr_id = f8
	 2 person_id = f8
	1 retval = i2
	1 log_message =  vc
	1 log_misc1 = vc
	1 return_value = vc
	1 orderchangeflag = i2
	1 orderid = f8
	1 detaillist [*]
	    2 oefieldid = f8
	    2 oefieldvalue = f8
	    2 oefielddisplayvalue = vc
	    2 oefielddttmvalue = dq8
	    2 oefieldmeaningid = f8
	    2 valuerequiredind = i2
)


set retval = -1

set t_rec->retval							= -1
set t_rec->return_value						= "FAILED"
set t_rec->patient.encntr_id 				= link_encntrid
set t_rec->patient.person_id				= link_personid

if (t_rec->patient.encntr_id <= 0.0)
	set t_rec->log_message = concat("link_encntrid not found")
	go to exit_script
else
	set t_rec->log_message = concat(t_rec->log_message,";","link_encntrid=",trim(cnvtstring(link_encntrid)))
endif

if (t_rec->patient.person_id <= 0.0)
	set t_rec->log_message = concat("link_personid not found")
	go to exit_script
else
	set t_rec->log_message = concat(t_rec->log_message,";","link_personid=",trim(cnvtstring(link_personid)))
endif

/* Use if parameters are needed
if(size(trim(reflect(parameter(1,0))),1) > 0)
  set t_rec->log_message = value(parameter(1,0))
endif */

set t_rec->return_value = "FALSE"

%i cust_script:cov_sub_covid19.inc
 
set reply_cnt = 0
 
call get_oef_fields(0)
set t_rec->log_message = "get_oef_fields(0)"

set reply_cnt = reply_cnt + 1
set stat = alterlist(t_rec->detaillist, reply_cnt)
set t_rec->detaillist[reply_cnt]->oefieldid = t_rec->first_test_id
set t_rec->detaillist[reply_cnt]->oefieldvalue = "Yes"
set t_rec->detaillist[reply_cnt]->oefielddisplayvalue = "Yes"
set t_rec->detaillist[reply_cnt]->oefieldmeaningid = t_rec->first_test_mean

set reply_cnt = reply_cnt + 1
set stat = alterlist(t_rec->detaillist, reply_cnt)
set t_rec->detaillist[reply_cnt]->oefieldid = t_rec->employed_in_healtcare_id
set t_rec->detaillist[reply_cnt]->oefieldmeaningid = t_rec->employed_in_healtcare_mean
set t_rec->detaillist[reply_cnt]->oefieldvalue = "Unknown"
set t_rec->detaillist[reply_cnt]->oefielddisplayvalue = "Unknown"

set reply_cnt = reply_cnt + 1
set stat = alterlist(t_rec->detaillist, reply_cnt)
set t_rec->detaillist[reply_cnt]->oefieldid = t_rec->symptomatic_id
set t_rec->detaillist[reply_cnt]->oefieldmeaningid = t_rec->symptomatic_mean
set t_rec->detaillist[reply_cnt]->oefieldvalue = "Yes"
set t_rec->detaillist[reply_cnt]->oefielddisplayvalue = "Yes"

set reply_cnt = reply_cnt + 1
set stat = alterlist(t_rec->detaillist, reply_cnt)
set t_rec->detaillist[reply_cnt]->oefieldid = t_rec->hopsitalized_id
set t_rec->detaillist[reply_cnt]->oefieldmeaningid = t_rec->hopsitalized_mean
set t_rec->detaillist[reply_cnt]->oefieldvalue = "No"
set t_rec->detaillist[reply_cnt]->oefielddisplayvalue = "No"

set reply_cnt = reply_cnt + 1
set stat = alterlist(t_rec->detaillist, reply_cnt)
set t_rec->detaillist[reply_cnt]->oefieldid = t_rec->congregate_care_setting_id
set t_rec->detaillist[reply_cnt]->oefieldmeaningid = t_rec->congregate_care_setting_mean
set t_rec->detaillist[reply_cnt]->oefieldvalue = "No"
set t_rec->detaillist[reply_cnt]->oefielddisplayvalue = "No"

set reply_cnt = reply_cnt + 1
set stat = alterlist(t_rec->detaillist, reply_cnt)
set t_rec->detaillist[reply_cnt]->oefieldid = t_rec->pregnant_id
set t_rec->detaillist[reply_cnt]->oefieldmeaningid = t_rec->pregnant_mean
set t_rec->detaillist[reply_cnt]->oefieldvalue = "No"
set t_rec->detaillist[reply_cnt]->oefielddisplayvalue = "No"

set t_rec->return_value = "TRUE"

#exit_script

if (trim(cnvtupper(t_rec->return_value)) = "TRUE")
	set t_rec->retval = 100
	set t_rec->log_misc1 = ""
	set reply->status_data->status = "S"
elseif (trim(cnvtupper(t_rec->return_value)) = "FALSE")
	set t_rec->retval = 0
	set reply->status_data->status = "Z"
else
	set t_rec->retval = 0
	set reply->status_data->status = "Z"
endif

set t_rec->log_message = concat(
										trim(t_rec->log_message),";",
										trim(cnvtupper(t_rec->return_value)),":",
										trim(cnvtstring(t_rec->patient.person_id)),"|",
										trim(cnvtstring(t_rec->patient.encntr_id)),"|"
									)
call echorecord(t_rec)

set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1

call echojson(t_rec,build(trim(cnvtlower(curprog)),"_t_rec.dat"))
call echojson(reply,build(trim(cnvtlower(curprog)),"_reply.dat"))
call echojson(request,build(trim(cnvtlower(curprog)),"_request.dat"))
call echojson(reqinfo,build(trim(cnvtlower(curprog)),"_reqinfo.dat"))
 
end
go
 
 
 
