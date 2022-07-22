/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		   	03/01/2019
	Solution:			
	Source file name:	 	cov_mak_unauth_doc_report.prg
	Object name:		   	cov_mak_unauth_doc_report
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	08/26/2019  Chad Cummings
******************************************************************************/

drop program cov_mak_unauth_doc_report:dba go
create program cov_mak_unauth_doc_report:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date and Time" = "SYSDATE"
	, "End Date and Time" = "SYSDATE" 

with OUTDEV, beg_dt_tm, end_dt_tm


call echo(build("loading script:",curprog))
set nologvar = 1	;do not create log = 1		, create log = 0
set noaudvar = 1	;do not create audit = 1	, create audit = 0
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

call set_codevalues(null)
call check_ops(null)

free set t_rec
record t_rec
(
	1 cnt			= i4
)

free set him_request
record him_request
(
  1 sort_flag = i2
  1 date_flag = i2
  1 start_dt_tm = dq8
  1 end_dt_tm = dq8
  1 org_qual[*]
    2 organization_id = f8
  1 debug_ind = i2
)

free set him_temp
record him_temp
(
 1  qual[*]
     2  encntr_id               = f8
     2  person_id               = f8
     2  mrn_formatted           = c20
     2  fin_formatted           = c20
     2  name_full_formatted     = c35
     2  encntr_type_disp        = c15
     2  med_service_cd			= f8
     2  loc_facility_cd			= f8
     2  loc_nurse_unit_cd		= f8
     2  visit_age               = i2
     2  visit_alloc_dt_tm       = dq8
     2  disch_dt_tm             = dq8
     2  tdo                     = c20
     2  organization_id         = f8
     2  org_name                = vc
     2  doc_qual[*]
         3 clinical_event_id    = f8
         3 event_disp           = c20
         3 event_cd				= f8
         3 verified_prsnl_id    = f8
         3 verified_prsnl  		= vc
         3 valid_from_dt_tm     = dq8
)

call addEmailLog("chad.cummings@covhlth.com")

set him_request->date_flag = 1
set him_request->debug_ind = 1
set him_request->sort_flag = 1
set him_request->start_dt_tm = cnvtdatetime($beg_dt_tm)
set him_request->end_dt_tm = cnvtdatetime($end_dt_tm)


call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("* START Execute cov_mak_unauth_doc_driver ******************"))

free set reply
record reply
(
  1 file_name = vc
%i cclsource:status_block.inc
)

execute cov_mak_unauth_doc_driver with replace(request,him_request), replace(temp,him_temp)

if (size(him_temp->qual,5) <= 0)
	go to exit_script
endif

call writeLog(build2("* END   Execute cov_mak_unauth_doc_driver *******************"))

call writeLog(build2("* START Getting Encounter Information ***********************"))

select into "nl:"
from
	 encounter e
	,(dummyt d1 with seq=value(size(him_temp->qual,5)))
plan d1
join e
	where e.encntr_id = him_temp->qual[d1.seq].encntr_id
order by
	e.encntr_id
head e.encntr_id
	him_temp->qual[d1.seq].med_service_cd = e.med_service_cd
	him_temp->qual[d1.seq].loc_facility_cd = e.loc_facility_cd
	him_temp->qual[d1.seq].loc_nurse_unit_cd = e.loc_building_cd
with nocounter

call writeLog(build2("* END   Getting Encounter Information ***********************"))

call writeLog(build2("* START Getting Document Information ************************"))

select into "nl:"
from
	 clinical_event ce
	,(dummyt d1 with seq=size(him_temp->qual,5))
	,(dummyt d2 with seq=1)
plan d1
	where maxrec(d2,size(him_temp->qual[d1.seq].doc_qual,5))
join d2
join ce
	where ce.clinical_event_id = him_temp->qual[d1.seq].doc_qual[d2.seq].clinical_event_id
order by
	ce.clinical_event_id
head ce.clinical_event_id
	 him_temp->qual[d1.seq].doc_qual[d2.seq].event_cd = ce.event_cd
	 him_temp->qual[d1.seq].doc_qual[d2.seq].verified_prsnl_id = ce.verified_prsnl_id
	 if (him_temp->qual[d1.seq].doc_qual[d2.seq].verified_prsnl_id = 0.0)
	 	him_temp->qual[d1.seq].doc_qual[d2.seq].verified_prsnl_id = ce.performed_prsnl_id
	 endif
with nocounter
call writeLog(build2("* END   Getting Document Information ************************"))

call writeLog(build2("* START Getting Document Author *****************************"))

select into "nl:"
from
	 prsnl p1
	,(dummyt d1 with seq=size(him_temp->qual,5))
	,(dummyt d2 with seq=1)
plan d1
	where maxrec(d2,size(him_temp->qual[d1.seq].doc_qual,5))
join d2
join p1
	where p1.person_id = him_temp->qual[d1.seq].doc_qual[d2.seq].verified_prsnl_id
detail
	him_temp->qual[d1.seq].doc_qual[d2.seq].verified_prsnl = p1.name_full_formatted
with nocounter
call writeLog(build2("* END   Getting Document Author *****************************"))



call writeLog(build2("* START Generating Output ***********************************"))

select into $OUTDEV
	 Facility = trim(substring(1,25,uar_get_code_display(him_temp->qual[d1.seq].loc_facility_cd)))
	,Unit = trim(substring(1,25,,uar_get_code_display(him_temp->qual[d1.seq].loc_nurse_unit_cd)))
	,MRN = trim(substring(1,15,him_temp->qual[d1.seq].mrn_formatted))
	,FIN = trim(substring(1,15,him_temp->qual[d1.seq].fin_formatted))
	,Patient_Name = trim(substring(1,50,him_temp->qual[d1.seq].name_full_formatted))
	,Encounter_Type = trim(substring(1,20,him_temp->qual[d1.seq].encntr_type_disp))
	,Medical_Service = trim(substring(1,20,uar_get_code_display(him_temp->qual[d1.seq].med_service_cd)))
	,Visit_Age = him_temp->qual[d1.seq].visit_age
	,Document_Type = trim(substring(1,50,uar_get_code_display(him_temp->qual[d1.seq].doc_qual[d2.seq].event_cd)))
	,Author = trim(substring(1,50,him_temp->qual[d1.seq].doc_qual[d2.seq].verified_prsnl))
	,Clinical_Event_ID = him_temp->qual[d1.seq].doc_qual[d2.seq].clinical_event_id
from
	 (dummyt d1 with seq=size(him_temp->qual,5))
	,(dummyt d2 with seq=1)
plan d1
	where maxrec(d2,size(him_temp->qual[d1.seq].doc_qual,5))
join d2
order by
	 him_temp->qual[d1.seq].fin_formatted
	,him_temp->qual[d1.seq].doc_qual[d2.seq].valid_from_dt_tm
with nocounter, format, separator=" "		
	
call writeLog(build2("* END   Generating Output ***********************************"))
	
call writeLog(build2("*************************************************************"))
call writeLog(build2("* START Custom   ************************************"))
call writeLog(build2("* END   Custom   ************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call exitScript(null)
;call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)
call echorecord(him_request)
call echorecord(him_temp)

end
go
