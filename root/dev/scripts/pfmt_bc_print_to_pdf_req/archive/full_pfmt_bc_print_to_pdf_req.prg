/*****************************************************************************
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   pfmt_bc_print_to_pdf_req.prg
  Object name:        pfmt_bc_print_to_pdf_req
  Request #:

  Program purpose:

  Executing from:     

  Special Notes:       

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
000   01/20/2020  Chad Cummings			REMOVE OR UPDATE AFTER POC
001   10/01/2019  Chad Cummings			Initial Release
******************************************************************************/
drop program pfmt_bc_print_to_pdf_req:dba go
create program pfmt_bc_print_to_pdf_req:dba

call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set debug_ind = 2	;0 = no debug, 1=basic debug with echo, 2=msgview debug ;000

%i cust_script:bc_common_routines.inc

/*  Commenting out for POC Purposes.
	Values are hard coded until custom code set is approved and built	;000
	
call bc_custom_code_set(0)
call bc_log_level(0)
call bc_check_validation(0)
call bc_pdf_event_code(0)
call bc_pdf_content_type(0)
call bc_get_requisitions(0)
call bc_get_task_definition(0)

if (bc_common->log_level >= 1)
	if (validate(requestin))
		call writeLog(build2(cnvtrectojson(requestin)))
	endif
endif


*/	;000
set bc_common->log_level = 2								;000
set bc_common->pdf_event_cd 		= 2595426677.00			;000
set bc_common->reference_task_id 	= 2595731141.00			;000
set bc_common->pdf_content_type		= "PATIENT_PROVIDED"	;000

select into "nl:"																;000
from code_value cv where cv.code_value = bc_common->pdf_event_cd				;000
detail																			;000
	bc_common->pdf_display_key							= cv.display_key		;000
with nocounter																	;000
			
set bc_common->requisition_cnt		= 9
set stat = alterlist(bc_common->requisition_qual,bc_common->requisition_cnt)	;000
set bc_common->requisition_qual[1].requisition_format_cd 	= 2553014753
set bc_common->requisition_qual[1].requisition_object		= "CCMIREQUISITN"
set bc_common->requisition_qual[1].requisition_title		= "Medical Imaging Requisition"

set bc_common->requisition_qual[2].requisition_format_cd 	= 2554787169
set bc_common->requisition_qual[2].requisition_object		= "ccoutpatw:group1"
set bc_common->requisition_qual[2].requisition_title		= "Laboratory Requisition"

set bc_common->requisition_qual[3].requisition_format_cd 	= 2553479159
set bc_common->requisition_qual[3].requisition_object		= "CCAMBREFERREQ"
set bc_common->requisition_qual[3].requisition_title		= "Referral"

set bc_common->requisition_qual[4].requisition_format_cd 	= 2555181737
set bc_common->requisition_qual[4].requisition_object		= "CCECGORDERREQ"
set bc_common->requisition_qual[4].requisition_title		= "Medical Imaging Requisition"

set bc_common->requisition_qual[5].requisition_format_cd 	= 2552936143
set bc_common->requisition_qual[5].requisition_object		= "REQBLOODGAS"
set bc_common->requisition_qual[5].requisition_title		= "Laboratory Requisition"

set bc_common->requisition_qual[6].requisition_format_cd 	= 2556445043
set bc_common->requisition_qual[6].requisition_object		= "GRPSCRNWRAP"
set bc_common->requisition_qual[6].requisition_title		= "Laboratory Requisition"

set bc_common->requisition_qual[7].requisition_format_cd 	= 2555169917
set bc_common->requisition_qual[7].requisition_object		= "REQCRDBLOOD"
set bc_common->requisition_qual[7].requisition_title		= "Laboratory Requisition"

set bc_common->requisition_qual[8].requisition_format_cd 	= 2554612947
set bc_common->requisition_qual[8].requisition_object		= "LABPATHORAL"
set bc_common->requisition_qual[8].requisition_title		= "Laboratory Requisition"

set bc_common->requisition_qual[9].requisition_format_cd 	= 2593843391
set bc_common->requisition_qual[9].requisition_object		= "LABVENOSAMP"
set bc_common->requisition_qual[9].requisition_title		= "Laboratory Requisition"


call writeLog(build2("* Check to see whether we got reestin-request or just requestin"))

if(not validate(requestin->request,0))
   call writeLog(build2("->Order was processed by async order server and request 560200.  Therefore we got requestin as requestin"))
   set bc_common->person_id = requestin->personid
   set bc_common->requestin_ind = 0	;requestin as requestin
else
   call writeLog(build2("->Order was processed by sync order server and request 560201. requestin as requestin->request."))
   set bc_common->person_id = requestin->request->personid
   set bc_common->requestin_ind = 1	;requestin as requestin->request
endif


call writeLog(build2("->bc_common->person_id =",trim(cnvtstring(bc_common->person_id))))

call writeLog(build2("* START Validate Patient ************************************"))

select into "nl:"
from person p
plan p where p.person_id = bc_common->person_id
detail
	call writeLog(build2("--->",trim(p.name_full_formatted)))
	if (p.name_first_key = "PDF*")
		bc_common->valid_ind = 1
	endif
	if (p.name_last_key = "CSTPDF*")
		bc_common->valid_ind = 1
	endif
with nocounter
if (bc_common->valid_ind = 0)
	call writeLog(build2("--->INVALID PATIENT, go to exit_script"))
	go to exit_script
else
	call writeLog(build2("--->PATIENT PASSED"))
endif

call writeLog(build2("* END Validate Patient ************************************"))


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
 
free record mmf_store_reply
record mmf_store_reply
(
   1 identifier = vc ; unique identifier if successfully stored
%i cclsource:status_block.inc
)
free set mmf_store_request
record mmf_store_request
(
   1 filename = vc
   1 contentType = vc
   1 mediaType = vc
   1 name = vc
   1 personId = f8
   1 encounterId = f8
)
  
free set req_request
record req_request (
  1 person_id = f8
  1 print_prsnl_id = f8
  1 order_qual[*]
    2 order_id = f8
    2 encntr_id = f8
    2 conversation_id = f8
  1 printer_name = c50
  1 requisition_script = vc
  1 execute_statement = vc
)
 
free set mmf_publish_ce_request 
record mmf_publish_ce_request
(
   1 personId = f8
   1 encounterId = f8
   1 documentType_key = vc ;  code set 72 display_key
   1 title = vc
   1 service_dt_tm = dq8
   1 reference_nbr = c100
   1 order_id = f8
   1 notetext = vc
   1 noteformat = vc ; code set 23 cdf_meaning
   1 personnel[*]
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

free set mmf_publish_ce_reply
record mmf_publish_ce_reply (
	1 parentEventId = f8
%i cclsource:status_block.inc
)
 
free set 560300_request 
record 560300_request
(
  1 person_id             = f8
  1 encntr_id             = f8
  1 stat_ind              = i2
  1 task_type_cd          = f8
  1 task_class_cd		  = f8
  1 task_dt_tm            = dq8
  1 task_activity_cd      = f8
  1 msg_text              = vc
  1 msg_subject_cd        = f8
  1 msg_subject           = vc
  1 confidential_ind      = i2
  1 read_ind              = i2
  1 delivery_ind          = i2
  1 task_status_cd        = f8
  1 reference_task_id     = f8
  1 event_id              = f8
  1 event_class_cd        = f8
  1 assign_prsnl_list[*]
    2 assign_prsnl_id     = f8
) 
 
free set 560300_reply 
record 560300_reply
( 1 result
    2 task_status = c1
    2 task_id = f8
    2 assign_prsnl_list[*]
      3 assign_prsnl_id = f8
%i cclsource:status_block.inc
) 

free set t_rec
record t_rec
(
	1 cnt						= i4
	1 requestin_ind				= i2
	1 identifier				= vc
	1 sysdate_string			= vc
	1 general_lab_cd			= f8
	1 radiology_cd				= f8
	1 ambulatory_referrals_cd	= f8
	1 future_status_cd			= f8
	1 print_dir					= vc
	1 log_filename_a			= vc
	1 log_filename_request		= vc
	1 prsnl_id 					= f8
	1 identifier 				= vc
	1 group_cnt 				= i2
	1 grouplist[*]
		2 order_cnt 				= i2
		2 plan_name 				= vc
		2 group_desc 				= vc
		2 pathway_id 				= f8
		2 identifier				= vc
		2 single_order				= i2
		2 reference_nbr				= c100
		2 event_id					= f8
		2 orderlist[*]
		 3 plan_name 				= vc
		 3 group_id 				= i2
	     3 order_id 				= f8
	     3 encntr_id 				= f8
	     3 conversation_id 			= f8
	     3 pathway_id 				= f8
	     3 printer_name 			= vc
	     3 action_cd				= f8
	     3 requisition_cd			= f8
	     3 event_id					= f8
	     3 requisition_script		= vc
)

set t_rec->general_lab_cd 			= uar_get_code_by("MEANING",6000,"GENERAL LAB")
set t_rec->radiology_cd				= uar_get_code_by("MEANING",6000,"RADIOLOGY")
set t_rec->ambulatory_referrals_cd	= uar_get_code_by("MEANING",6000,"AMB REFERRAL")
set t_rec->future_status_cd			= uar_get_code_by("MEANING",6004,"FUTURE")
set t_rec->print_dir 				= concat(
												 "/cerner/d_"
												,trim(cnvtlower(curdomain))
												,"/print/"
											)
set t_rec->sysdate_string 			= format(sysdate,"yyyymmddhhmmss;;d") 
set t_rec->log_filename_request 	= concat ("cclscratch:requestin_560201_" ,t_rec->sysdate_string ,".dat" )
set t_rec->log_filename_a 			= concat ("cclscratch:560201_records_" ,t_rec->sysdate_string ,".dat" )

if (bc_common->requestin_ind = 0)
	call writeLog(build2("-->EXITING, current script not built to handle requestin as requestin"))
	go to exit_script
endif

if (bc_common->valid_ind = 1)
	call writeLog(build2("*-> Valid Patient, starting ",tirm(t_rec->log_filename_a)," with requestin"))
	if (validate(requestin))
		call writeLog(build2("->writing requestin to ",trim(t_rec->log_filename_a)))
		call echojson(requestin,t_rec->log_filename_request)
		call echojson(requestin,t_rec->log_filename_a)
		call echorecord(requestin)
	endif
endif

call writeLog(build2("-->selecting orders from orderlist, size=",trim(cnvtstring(size(requestin->request->orderlist,5)))))
select into "nl:"
from
	 (dummyt d with seq=size(requestin->request->orderlist,5))
	,orders o
	,order_catalog oc
	,encounter e
	,pathway_catalog pc
plan d
join o
	where o.order_id 				= requestin->request->orderlist[d.seq].orderid
join oc
	where oc.catalog_cd				= o.catalog_cd
join pc
	where pc.pathway_catalog_id 	= o.pathway_catalog_id
join e
	where e.encntr_id 				= o.originating_encntr_id
order by
	 o.pathway_catalog_id
	,oc.requisition_format_cd
	,o.order_id
head report
	cnt = 0
	gcnt = 0
	call writeLog(build2("---->inside order selection query"))
;head o.pathway_catalog_id
head oc.requisition_format_cd
	gcnt = (gcnt + 1)
	cnt = 0
	stat = alterlist(t_rec->grouplist,gcnt)
	t_rec->group_cnt = gcnt
head o.order_id
	bc_common->encntr_id = o.originating_encntr_id
	cnt = (cnt + 1)
	t_rec->grouplist[gcnt].order_cnt = cnt
	stat = alterlist(t_rec->grouplist[gcnt].orderlist,cnt)
	t_rec->grouplist[gcnt].orderlist[cnt].order_id 				= o.order_id
	t_rec->grouplist[gcnt].orderlist[cnt].encntr_id 			= o.originating_encntr_id
	t_rec->grouplist[gcnt].orderlist[cnt].group_id 				= gcnt
	t_rec->grouplist[gcnt].orderlist[cnt].pathway_id 			= o.pathway_catalog_id
	t_rec->grouplist[gcnt].orderlist[cnt].printer_name 			= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id)),".pdf")
	t_rec->grouplist[gcnt].orderlist[cnt].conversation_id 		= 0.0
	t_rec->grouplist[gcnt].orderlist[cnt].requisition_cd 		= oc.requisition_format_cd
	t_rec->grouplist[gcnt].orderlist[cnt].action_cd 			= requestin->request->orderlist[d.seq].actiontypecd

	for (j=1 to bc_common->requisition_cnt)
		if (oc.requisition_format_cd = bc_common->requisition_qual[j].requisition_format_cd)
			
			t_rec->grouplist[gcnt].orderlist[cnt].requisition_script = bc_common->requisition_qual[j].requisition_object
			t_rec->grouplist[gcnt].orderlist[cnt].plan_name			 = bc_common->requisition_qual[j].requisition_title
			
		endif
	endfor

	if (o.pathway_catalog_id = 0)
		t_rec->grouplist[gcnt].group_desc 		= t_rec->grouplist[gcnt].orderlist[cnt].plan_name
	else
		t_rec->grouplist[gcnt].plan_name 		= pc.description
		t_rec->grouplist[gcnt].pathway_id 		= pc.pathway_catalog_id
	endif
foot o.pathway_catalog_id
	cnt = 0
	/*
	if (o.pathway_catalog_id = 0)
		t_rec->grouplist[gcnt].group_desc = t_rec->grouplist[gcnt].orderlist[cnt].plan_name
	else
		t_rec->grouplist[gcnt].plan_name = pc.description
		t_rec->grouplist[gcnt].pathway_id = pc.pathway_catalog_id
	endif 
	*/
foot report
	t_rec->group_cnt = gcnt
with nocounter


call writeLog(build2("bc_common->person_id=",trim(cnvtstring(bc_common->person_id))))
call writeLog(build2("bc_common->encntr_id=",trim(cnvtstring(bc_common->encntr_id))))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Find Existing Order Document ************************"))

if (t_rec->group_cnt > 0)
	for (i=1 to t_rec->group_cnt)
		for (j=1 to t_rec->grouplist[i].order_cnt)
		call writeLog(build2("-->Starting Query")) 
		call writeLog(build2("-->t_rec->grouplist[",trim(cnvtstring(i)),"].orderlist[",trim(cnvtstring(j)),"].order_id=",trim(
	cnvtstring(t_rec->grouplist[i].orderlist[j].order_id))))
select into "nl:"
from
	clinical_Event ce 
where 	ce.person_id = bc_common->person_id
and		ce.event_cd = bc_common->pdf_event_cd
and     ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
and     ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
and     ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))

								)	
and     cnvtreal(ce.reference_nbr) = t_rec->grouplist[i].orderlist[j].order_id
order by
	 ce.reference_nbr
	,ce.event_id
	,ce.valid_from_dt_tm desc
head report
	call writeLog(build2("-->inside event query<--"))
head ce.event_id
	t_rec->grouplist[i].orderlist[j].event_id = ce.event_id
	call writeLog(build2("-->t_rec->grouplist[",trim(cnvtstring(i)),"].orderlist[",trim(cnvtstring(j)),"].event_id=",trim(
	cnvtstring(ce.event_id))))
foot report
	call writeLog(build2("-->leaving event query<--"))
with nocounter

endfor
endfor
endif

call writeLog(build2("* START Find Existing Order Document ***********************"))
call writeLog(build2("************************************************************"))
     
call writeLog(build2("* START Add Orders to Request ******************************"))

if (t_rec->group_cnt > 0)
	for (i=1 to t_rec->group_cnt)
		if (t_rec->grouplist[i].order_cnt > 0)
 			
 			
			set stat = initrec(req_request)
			
			set req_request->person_id 			= bc_common->person_id
			set req_request->print_prsnl_id 	= reqinfo->updt_id
			set req_request->printer_name 		= t_rec->grouplist[i].orderlist[1].printer_name
			
			for (j=1 to t_rec->grouplist[i].order_cnt)
			
			if (t_rec->grouplist[i].orderlist[j].action_cd in(
																 value(uar_get_code_by("MEANING",6003,"ORDER"))
																,value(uar_get_code_by("MEANING",6003,"MODIFY"))
															))
				set stat = alterlist(req_request->order_qual,j)
				set req_request->order_qual[j].order_id 			= t_rec->grouplist[i].orderlist[j].order_id
				set req_request->order_qual[j].encntr_id 			= t_rec->grouplist[i].orderlist[j].encntr_id
				set req_request->order_qual[j].conversation_id 		= 0.0
				;set req_request->order_qual[j].conversation_id 	= t_rec->grouplist[i].orderlist[1].conversation_id
				set req_request->requisition_script 				= t_rec->grouplist[i].orderlist[j].requisition_script
				set t_rec->grouplist[i].reference_nbr				= trim(cnvtstring(req_request->order_qual[j].order_id))
				
				
				call writeLog(build2("-->adding:req_request->order_qual[",trim(cnvtstring(i)),"].order_id=",
					trim(cnvtstring(req_request->order_qual[i].order_id))))
				call writeLog(build2("-->adding:req_request->order_qual[",trim(cnvtstring(i)),"].encntr_id=",
					trim(cnvtstring(req_request->order_qual[i].encntr_id))))
				call writeLog(build2("-->adding:req_request->order_qual[",trim(cnvtstring(i)),"].conversation_id=",
					trim(cnvtstring(req_request->order_qual[i].conversation_id))))
				call writeLog(build2("-->adding:req_request->printer_name=",trim(req_request->printer_name)))
				call writeLog(build2("-->adding:req_request->requisition_script=",trim(req_request->requisition_script)))
			endif
			endfor
			call echorecord(req_request)
				
			if (req_request->requisition_script > " ")
				set req_request->execute_statement =
					build2(^execute ^,trim(req_request->requisition_script),^ with replace("REQUEST",REQ_REQUEST) go^)  
				call writeLog(build2(req_request->execute_statement))
				call parser(req_request->execute_statement)  
			else
				call writeLog(build2(^--->execute backup ccoutpatw:group1 with replace("REQUEST","REQ_REQUEST")^))
				execute ccoutpatw:group1 with replace("REQUEST","REQ_REQUEST")
 			endif
 			
 			if (validate(req_request))
				call writeLog(build2("->writing req_request to ",trim(t_rec->log_filename_a)))
				call echojson(req_request,t_rec->log_filename_a)
				call echorecord(req_request)
			endif
	
			set stat = initrec(mmf_store_reply)
			set stat = initrec(mmf_store_request)
			set stat = initrec(mmf_publish_ce_request)
			set stat = initrec(mmf_publish_ce_reply)
 
			set mmf_store_request->filename 			= concat(req_request->printer_name)
			set mmf_store_request->mediatype 			= "application/pdf"
			set mmf_store_request->contenttype 			= bc_common->pdf_content_type
			set mmf_store_request->name 				= concat("Requisition ",trim(format(sysdate,";;q")))
			set mmf_store_request->personid 			= bc_common->person_id
			set mmf_store_request->encounterid 			= bc_common->encntr_id
 
 			call echorecord(mmf_store_request)
 			
 			call writeLog(build2(
 				^--->execute mmf_store_object_with_xref with replace("REQUEST",mmf_store_request),replace("REPLY",mmf_store_reply)^))
			execute mmf_store_object_with_xref with replace("REQUEST",mmf_store_request), replace("REPLY",mmf_store_reply)
 			
 			set t_rec->identifier = mmf_store_reply->identifier
 			call writeLog(build2("---->set t_rec->identifier=",t_rec->identifier))
			
 			set mmf_publish_ce_request->documenttype_key 			= bc_common->pdf_display_key
			set mmf_publish_ce_request->service_dt_tm 				= cnvtdatetime(curdate, curtime3)
			set mmf_publish_ce_request->personId 					= bc_common->person_id
			set mmf_publish_ce_request->encounterId 				= bc_common->encntr_id
			
			set stat = alterlist(mmf_publish_ce_request->mediaObjects,2)
			set mmf_publish_ce_request->mediaObjects[1]->display 	= 'Requisition Attachment 1'
			set mmf_publish_ce_request->mediaObjects[1]->identifier = t_Rec->identifier

			set mmf_publish_ce_request->mediaObjects[2]->display 	= 'Requisition Attachment 2'
			set mmf_publish_ce_request->mediaObjects[2]->identifier = t_Rec->identifier
			set stat = alterlist(mmf_publish_ce_request->mediaObjects,1) ;remove the second attachment as it doesn't work
 
			set mmf_publish_ce_request->title = nullterm(
															concat(
																		t_rec->grouplist[i].group_desc, " ",
																		t_rec->grouplist[i].plan_name
																	)
														)
			;set mmf_publish_ce_request->notetext = nullterm(' Note text from request structure. ')
			set mmf_publish_ce_request->noteformat = 'AS'
			set mmf_publish_ce_request->publishAsNote=1
			set mmf_publish_ce_request->debug=1
			
			if (t_rec->grouplist[i].single_order = 0)
				set mmf_publish_ce_request->reference_nbr = build(trim(t_rec->grouplist[i].reference_nbr))
				set mmf_publish_ce_request->order_id =t_rec->grouplist[i].orderlist[1].order_id
			endif
			
			set stat = alterlist(mmf_publish_ce_request->personnel,4)
			
			set mmf_publish_ce_request->personnel[1]->id 		= req_request->print_prsnl_id
			set mmf_publish_ce_request->personnel[1]->action 	= 'PERFORM'
			set mmf_publish_ce_request->personnel[1]->status 	= 'COMPLETED'
			
			set mmf_publish_ce_request->personnel[2]->id 		=  req_request->print_prsnl_id
			set mmf_publish_ce_request->personnel[2]->action 	= 'SIGN'
			set mmf_publish_ce_request->personnel[2]->status 	= 'COMPLETED'
			
			set mmf_publish_ce_request->personnel[3]->id 		=  req_request->print_prsnl_id
			set mmf_publish_ce_request->personnel[3]->action 	= 'VERIFY'
			set mmf_publish_ce_request->personnel[3]->status 	= 'COMPLETED'
			
			set mmf_publish_ce_request->personnel[4]->id 		=  req_request->print_prsnl_id
			set mmf_publish_ce_request->personnel[4]->action 	= 'ORDER'
			set mmf_publish_ce_request->personnel[4]->status 	= 'COMPLETED'

			if (validate(mmf_publish_ce_request))
				call echojson(mmf_publish_ce_request,t_rec->log_filename_a,1)
				call echorecord(mmf_publish_ce_request)
			endif
 			call writeLog(build2(^--->execute bc_mmf_publish_ce with^))
			execute bc_mmf_publish_ce with replace("REQUEST",mmf_publish_ce_request),replace("REPLY",mmf_publish_ce_reply)
			
 			if (validate(mmf_publish_ce_reply))
				call echojson(mmf_publish_ce_reply,t_rec->log_filename_a,1)
				call echorecord(mmf_publish_ce_reply)
			endif
		endif
	endfor
endif

call writeLog(build2("* END   Add Orders to Requests ******************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Find Existing Order Document ************************"))

call writeLog(build2("* START Find Existing Order Document ***********************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("* START Adding Task v6 ****************************************"))

set stat = initrec(560300_request)
set 560300_request->person_id				= bc_common->person_id
set 560300_request->encntr_id				= bc_common->encntr_id
set 560300_request->stat_ind				= 0
set 560300_request->task_class_cd 			= value(uar_get_code_by("MEANING",6025,"SCH")) 
set 560300_request->reference_task_id 		= bc_common->reference_task_id
set 560300_request->task_type_cd			= value(uar_get_code_by("DISPLAY",6026,"Patient Care"))
set 560300_request->task_activity_cd 		= value(uar_get_code_by("MEANING",6027,"CHART RESULT"))
set 560300_request->task_status_cd 			= value(uar_get_code_by("MEANING",79,"PENDING"))
set 560300_request->task_dt_tm				= cnvtdatetime(curdate,curtime3)

call writeLog(build2(^560300_request->person_id=^,trim(cnvtstring(560300_request->person_id))))
call writeLog(build2(^560300_request->encntr_id=^,trim(cnvtstring(560300_request->encntr_id))))
call writeLog(build2(^560300_request->reference_task_id=^,trim(cnvtstring(560300_request->reference_task_id))))
call writeLog(build2(^560300_request->task_type_cd=^,trim(cnvtstring(560300_request->task_type_cd))))
call writeLog(build2(^560300_request->task_activity_cd=^,trim(cnvtstring(560300_request->task_activity_cd))))
call writeLog(build2(^560300_request->task_status_cd=^,trim(cnvtstring(560300_request->task_status_cd))))

call writeLog(build2(^execute dcp_add_task with replace("REQUEST",560300_request), replace("REPLY",560300_reply)^))

execute dcp_add_task with replace("REQUEST",560300_request), replace("REPLY",560300_reply)  
call writeLog(build2(cnvtrectojson(560300_reply)))
call writeLog(build2(^560300_reply->task_id=^,trim(cnvtstring(560300_reply->task_id))))

if (560300_reply->task_id > 0)
	update into 
		task_activity ta 
	set  ta.task_class_cd = value(uar_get_code_by("MEANING",6025,"SCH"))
		,ta.msg_subject = "testing"
		,ta.event_id = mmf_publish_ce_reply->parentEventId
	where ta.task_id = 560300_reply->task_id 
	commit 
endif
 
 
call writeLog(build2("* END   Adding Task ****************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

#exit_script
if (bc_common->valid_ind = 1)
	;if (validate(requestin))
	;	call writeLog(build2("->writing requestin to ",trim(t_rec->log_filename_a)))
;		call echojson(requestin,t_rec->log_filename_a);
;		call echorecord(requestin)
;	endif
	
	if (validate(request))
		call echojson(request,t_rec->log_filename_a,1)
		call echorecord(request)
	endif
	if (validate(reqinfo))
		call echojson(reqinfo,t_rec->log_filename_a,1)
		call echorecord(reqinfo)
	endif
	if (validate(bc_common))
		call echojson(bc_common,t_rec->log_filename_a,1)
		call echorecord(bc_common)
	endif
	if (validate(t_rec))
		call echojson(t_rec,t_rec->log_filename_a,1)
		call echorecord(t_rec)
	endif
endif






call exitScript(null)
call echorecord(t_rec)
call echorecord(program_log)
call echorecord(bc_common)

end 
go
