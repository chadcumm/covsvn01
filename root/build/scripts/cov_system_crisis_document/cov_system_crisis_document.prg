/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		
	Solution:			
	Source file name:	cov_system_crisis_document.prg
	Object name:		cov_system_crisis_document
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	08/12/2021  Chad Cummings			Initial Release
******************************************************************************/

drop program cov_system_crisis_document:dba go
create program cov_system_crisis_document:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Encounter ID:" = 0 

with OUTDEV, ENCNTR_ID


call echo(build("loading script:",curprog))
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

  
free record document_request 
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
 
free record document_reply
record document_reply (
	1 parentEventId = f8
%i cclsource:status_block.inc
)

set reply->status_data.status = "F"

call set_codevalues(null)
call check_ops(null)

record t_rec
(
	1 prompts
	 2 outdev		= vc
	 2 encntr_id	= f8
	1 values
	 2 document_key = vc
	 2 html_template = vc
	 2 encntr_id = f8
	1 files
	 2 records_attachment		= vc
	1 cnt			= i4
	1 qual[*]
	 2 person_id				= f8
	 2 encntr_id				= f8
	 2 mrn						= vc
	 2 fin						= vc
	 2 encntr_facility			= vc
	 2 encntr_type				= vc
	 2 patient_name				= vc
	 2 powerform_event_id		= f8
	 2 ordering_provider_id		= f8
	 2 document_title		 	= vc
	 2 document_created_ind		= i2
	 2 html_document			= vc
	 2 event_id					= f8
) with protect


record 3011001_request (
  1 module_dir = vc  
  1 module_name = vc  
  1 basblob = i2   
) 

set 3011001_request->module_dir = "cust_script:"
set 3011001_request->module_name = "cov_system_crisis_document.html" ;
set 3011001_request->basblob = 1

free record 3011001_reply

call writeLog(build2(cnvtrectojson(3011001_request)))

set stat = tdbexecute(3010000,3011002,3011001,"REC",3011001_request,"REC",3011001_reply)

if (validate(3011001_reply))
	call writeLog(build2(cnvtrectojson(3011001_reply)))
	if (3011001_reply->status_data.status = "S")
		set t_rec->values.html_template = 3011001_reply->data_blob
	else
		call writeLog(build2("HTML Template not found, exiting"))
		go to exit_script
	endif
else	
	call writeLog(build2("HTML Template not found, exiting"))
	go to exit_script
endif

set t_rec->prompts.outdev = $OUTDEV
set t_rec->prompts.encntr_id = $ENCNTR_ID

set t_rec->values.encntr_id = t_rec->prompts.encntr_id

call writeLog(build2("* END   Custom Section  ************************************"))


;call addEmailLog("chad.cummings@covhlth.com")


set t_rec->values.document_key = "SYSTEMNOTECRISISDOCUMENTATION"

set t_rec->files.records_attachment = concat(trim(cnvtlower(curprog)),"_rec_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")


set retval = 0

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Getting Encounter Information **********************"))

select into "nl:"
from
	encounter e
	,person p
plan e
	where e.encntr_id = t_rec->values.encntr_id 
join p
	where p.person_id = e.person_id
order by
	e.encntr_id
head report
	call writeLog(build2("->entering encounter information gathering"))
	k = 0
head e.encntr_id
	k = (k + 1)
	stat = alterlist(t_rec->qual,k)
	t_rec->qual[k].encntr_id 				 = e.encntr_id
	t_rec->qual[k].person_id 				 = e.person_id
	t_rec->qual[k].encntr_facility 			 = uar_get_code_display(e.loc_facility_cd)
	t_rec->qual[k].encntr_type 				 = uar_get_code_display(e.encntr_type_cd)
	t_rec->qual[k].ordering_provider_id		 = 1.0
	t_rec->qual[k].patient_name				 = p.name_full_formatted        
foot report
	t_rec->cnt = k
	call writeLog(build2("<-leavig encounter information gathering"))
with nocounter

call writeLog(build2("* END   Getting Encounter Information **********************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Document Creation **********************************"))

subroutine add_html(text)
	call writeLog(build2("_add_html=",trim(text)))
	set t_rec->qual[d1.seq].html_document = concat(t_rec->qual[d1.seq].html_document,text)
	call writeLog(build2("->t_rec->qual[d1.seq].html_document=",t_rec->qual[d1.seq].html_document))
end

select into "nl:"
from
	 (dummyt d1 with seq=t_rec->cnt)
	 ,encounter e
	 ,person p
plan d1	
	where t_rec->qual[d1.seq].encntr_id > 0.0
join e
	where e.encntr_id = t_rec->qual[d1.seq].encntr_id
join p
	where p.person_id = e.person_id
order by
	e.encntr_id
head report
	call writeLog(build2("->entering document creation"))
	k = 0
head e.encntr_id
	call writeLog(build2("-->head e.encntr_id=",cnvtstring(e.encntr_id)))
	call writeLog(build2("-->head e.encntr_id (d1.seq) =",cnvtstring(d1.seq)))
	call writeLog(build2("-->t_rec->qual[d1.seq].ordering_provider_id=",cnvtstring(t_rec->qual[d1.seq].ordering_provider_id)))

	t_rec->qual[d1.seq].document_title = concat(trim("System Note - Crisis Document"))
	t_rec->qual[d1.seq].html_document = t_rec->values.html_template
	
foot e.encntr_id
	t_rec->qual[d1.seq].document_created_ind = 1	
foot report
	call writeLog(build2("<-leaving document creation"))
with nocounter


call writeLog(build2("* END   Document Creation **********************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Adding Document to Chart ***************************"))

for (i=1 to t_rec->cnt)
	if (t_rec->qual[i].document_created_ind = 1)
		set stat = initrec(document_request)
		set stat = initrec(document_reply)
		
		set document_request->service_dt_tm			= cnvtdatetime(curdate,curtime3)
		set document_request->documenttype_key 		= t_rec->values.document_key
		set document_request->personId 				= t_rec->qual[i].person_id
		set document_request->encounterId 			= t_rec->qual[i].encntr_id
		set document_request->title 				= nullterm(build2(t_rec->qual[i].document_title))
		set document_request->notetext 				= nullterm(build2(t_rec->qual[i].html_document))
		set document_request->noteformat 			= 'HTML' 
		set document_request->personnel[1]->id 		= t_rec->qual[i].ordering_provider_id
		set document_request->personnel[1]->action 	= 'PERFORM'  
		set document_request->personnel[1]->status 	= 'COMPLETED'  
		set document_request->personnel[2]->id 		= t_rec->qual[i].ordering_provider_id
		set document_request->personnel[2]->action 	= 'SIGN' 
		set document_request->personnel[2]->status 	= 'COMPLETED'  
		set document_request->personnel[3]->id 		= t_rec->qual[i].ordering_provider_id
		set document_request->personnel[3]->action 	= 'VERIFY' 
		set document_request->personnel[3]->status 	= 'COMPLETED'  

		set document_request->publishAsNote=0 
		set document_request->debug=1 
		set t_rec->qual[i].document_created_ind = 2
		
		call writeLog(build2(^execute mmf_publish_ce with replace("REQUEST", "DOCUMENT_REQUEST"), replace("REPLY", "DOCUMENT_REPLY")^))
		
		call writeLog(build2(^->mrn=^,t_rec->qual[i].mrn))
		call writeLog(build2(^->fin=^,t_rec->qual[i].fin))
		call writeLog(build2(^->person_id=^,t_rec->qual[i].person_id))
		call writeLog(build2(^->encntr_id=^,t_rec->qual[i].encntr_id))
		
		;call writeLog(build2(cnvtrectojson(document_request)))
		execute mmf_publish_ce with replace("REQUEST", "DOCUMENT_REQUEST"), replace("REPLY", "DOCUMENT_REPLY")
		
		;call writeLog(build2(cnvtrectojson(document_reply)))
		set t_rec->qual[i].event_id = document_reply->parentEventId
		set t_rec->qual[i].html_document = "" ;clelaring html document so log file isn't oversized
	endif
endfor

call writeLog(build2("* END   Adding Document to Chart ***************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Creating Audit *************************************"))
	call writeAudit(build2(
							char(34),^SEQUENCE^,char(34),char(44),
							char(34),^MRN^,char(34),char(44),
							char(34),^FIN^,char(34),char(44),
							char(34),^PATIENT_NAME^,char(34),char(44),
							char(34),^FACILITY^,char(34),char(44),
							char(34),^ENCNTR_TYPE^,char(34),char(44),
							char(34),^DOCUMENT_CREATED_IND^,char(34),char(44),
							char(34),^DOCUMENT_TITLE^,char(34),char(44),
							char(34),^PERSON_ID^,char(34),char(44),
							char(34),^ENCNTR_ID^,char(34),char(44),
							char(34),^ORDERING_PROVIDER_ID^,char(34),char(44),
							char(34),^EVENT_ID^,char(34)
						))
for (i=1 to t_rec->cnt)
		call writeAudit(build2(
							char(34),i,char(34),char(44),
							char(34),t_rec->qual[i].mrn											,char(34),char(44),
							char(34),t_rec->qual[i].fin											,char(34),char(44),
							char(34),t_rec->qual[i].patient_name								,char(34),char(44),
							char(34),t_rec->qual[i].encntr_facility								,char(34),char(44),
							char(34),t_rec->qual[i].encntr_type									,char(34),char(44),
							char(34),t_rec->qual[i].document_created_ind						,char(34),char(44),
							char(34),t_rec->qual[i].document_title								,char(34),char(44),
							char(34),t_rec->qual[i].person_id									,char(34),char(44),
							char(34),t_rec->qual[i].encntr_id									,char(34),char(44),
							char(34),t_rec->qual[i].ordering_provider_id						,char(34),char(44),
							char(34),t_rec->qual[i].event_id									,char(34)
						))

endfor
call writeLog(build2("* END   Creating Audit *************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

;


set reply->status_data.status = "S"
set retval = 100

#exit_script


/*
call echojson(t_rec, concat("cclscratch:",t_rec->files.records_attachment) , 1)
if (validate(noncmg_data->cnt))
	call echojson(noncmg_data, concat("cclscratch:",t_rec->files.records_attachment) , 1)
endif

if (validate(tat_data->list))
	call echojson(tat_data, concat("cclscratch:",t_rec->files.records_attachment) , 1)
endif

execute  cov_astream_ccl_sync value(program_log->files.file_path),value(t_rec->files.records_attachment)
*/

call exitScript(null)
;call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
