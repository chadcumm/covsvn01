drop program cov_add_test_document:dba go
create program cov_add_test_document:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "FIN" = "2118903378" 

with OUTDEV, FIN


call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section 001 *********************************"))

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

  
free record document_request 
free record document_reply 
 
record document_request
(
   1 personId = f8
   1 encounterId = f8
   1 documentType_key = vc ;  code set 72 display_key
   1 title = vc
   1 service_dt_tm = dq8
   1 notetext = vc
   1 noteformat = vc ; code set 23 cdf_meaning
   1 personnel[3]
     2 id = f8
     2 action = vc     ; code set 21 cdf_meaning
     2 status = vc     ; code set 103 cdf_meanings
   1 mediaObjects[*]
     2 display = vc
     2 identifier = vc
   1 mediaObjectGroups[*]
     2 identifier = vc
   1 publishAsNote = i2
   1 debug = i2
)
 
record document_reply (
	1 parentEventId = f8
%i cclsource:status_block.inc
)
 
free set t_rec
record t_rec
(
	1 cv
	 2 waste_charge_cd	= f8
	1 dates
	 2 start_dt_tm		= dq8
	 2 end_dt_tm		= dq8
	1 document_key		= vc
	1 dminfo
	 2 info_domain		= vc
	 2 info_name		= vc
	1 cnt				= i4
	1 patient
	 2 encntr_id			= f8
	 2 person_id			= f8
	1 prsnl
	 2 prsnl_id				= f8
	1 qual[*]
	 2 dispense_hx_id		= f8
	 2 waste_dispense_hx_id	= f8
	 2 encntr_id			= f8
	 2 person_id			= f8
	 2 prod_desc			= vc		;005
	 2 event_id				= f8
	 2 waste_qty			= f8
	 2 prsnl_id				= f8
	 2 order_id				= f8
	 2 status				= i2
)

;call addEmailLog("chad.cummings@covhlth.com")

set t_rec->document_key = "PHARMACYWASTAGTEXT"
set t_rec->document_key = "PHYSICIANORDER"

set t_rec->prsnl.prsnl_id = 1.0; reqinfo->updt_id

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("* START Finding Encounter ***************************"))

select into "nl:"
from
	encntr_alias ea
	,encounter e
	,person p
plan ea
	where ea.alias = $FIN
join e
	where e.encntr_id = ea.encntr_id
join p
	where p.person_id = e.person_id
detail
	t_rec->patient.encntr_id = e.encntr_id
	t_rec->patient.person_id = p.person_id
with nocounter

call writeLog(build2("* END   Finding Encounter ****************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   ************************************"))

set t_rec->cnt = 1

for (i = 1 to t_rec->cnt)
	set stat = initrec(document_request)
	set stat = initrec(document_reply)
	set document_request->service_dt_tm			= cnvtdatetime(curdate,curtime3)
	set document_request->documenttype_key 		= t_rec->document_key
	set document_request->personId 				= t_rec->patient.person_id
	set document_request->encounterId 			= t_rec->patient.encntr_id
	set document_request->title 				= nullterm(build2('Test Document ',format(sysdate,";;q")))
	set document_request->notetext				= nullterm("Note Text")
	set document_request->noteformat 			= '' 
	set document_request->personnel[1]->id 		= t_rec->prsnl.prsnl_id
	set document_request->personnel[1]->action 	= 'PERFORM'  
	set document_request->personnel[1]->status 	= 'COMPLETED'  
	set document_request->personnel[2]->id 		= t_rec->prsnl.prsnl_id
	set document_request->personnel[2]->action 	= 'SIGN' 
	set document_request->personnel[2]->status 	= 'COMPLETED'  
	set document_request->personnel[3]->id 		= t_rec->prsnl.prsnl_id
	set document_request->personnel[3]->action 	= 'VERIFY' 
	set document_request->personnel[3]->status 	= 'COMPLETED'  

	set document_request->publishAsNote=0
	set document_request->debug=1 
	
	call writeLog(build2(^execute mmf_publish_ce with replace("REQUEST", "DOCUMENT_REQUEST"), replace("REPLY", "DOCUMENT_REPLY")^))
	call writeLog(build2(cnvtrectojson(document_request)))
	execute mmf_publish_ce with replace("REQUEST", "DOCUMENT_REQUEST"), replace("REPLY", "DOCUMENT_REPLY")
	call writeLog(build2(cnvtrectojson(document_reply)))

endfor

set reply->status_data.status = "S"

call writeLog(build2("* END   Custom   ************************************"))
call writeLog(build2("************************************************************"))


#exit_script

call writeLog(build2(cnvtrectojson(t_rec))) 

set program_log->display_on_exit = 1

call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
call echorecord(program_log)


end
go



