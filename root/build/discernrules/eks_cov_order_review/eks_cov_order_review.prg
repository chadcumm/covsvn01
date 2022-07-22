/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		06/22/2020
	Solution:				
	Source file name:	 	eks_cov_order_review.prg
	Object name:		   	eks_cov_order_review
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	06/22/2020  Chad Cummings			Initial Deployment
******************************************************************************/

drop program eks_cov_order_review:dba go
create program eks_cov_order_review:dba

declare processRequestinWithRequest(null)=null
declare processRequestinWithoutRequest(null)=null
declare processOrders(null)=null
declare sendNotification(null)=null
declare debugMode(null)=i2
declare html_output = vc with noconstant(" ") 

record t_rec
(
	1 patient
	 2 encntr_id = f8
	 2 person_id = f8
	1 retval = i2
	1 log_message =  vc
	1 log_misc1 = vc
	1 return_value = vc
	1 person_id = f8
	1 encntr_id = f8
	1 log_file_requestin = vc
	1 log_file_path = vc
	1 log_file = vc
	1 debug_ind = i2
	1 active_ind = i2
	1 log_comments = vc
	1 testing_only_username = vc
	1 session_sent = i2
) with protect

free record temp_ord
record temp_ord
(
	1 cnt = i2
	1 qual[*]
	 2 order_id = f8
	 2 synonym_id = f8
	 2 communication_type_cd = f8
	 2 pathway_id = f8
	 2 pathway_catalog_id = f8
	 2 originating_encntr_id = f8
	 2 encntr_id = f8
	 2 person_id = f8
	 2 action_prsnl_id = f8
	 2 action_username = vc
)

free record orderdata
record orderdata
(
	1 ordercnt = i2
	1 username = vc
	1 orderlist[*]
	 2 order_id = f8
	 2 synonym_id = f8
	1 powerplancnt = i2
	1 powerplans[*]
	 2 pathway_id = f8
)

free record patientdata
record patientdata
(
	1 encntr_id = f8
	1 person_id = f8
	1 fin = vc
)

free record 3011001Request 
record 3011001Request (
  1 Module_Dir = vc  
  1 Module_Name = vc  
  1 bAsBlob = i2   
) 

free record 3011001Reply 
record 3011001Reply (
    1 info_line [* ]
      2 new_line = vc
    1 data_blob = gvc
    1 data_blob_size = i4
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) 
  
free record 3051004Request 
record 3051004Request (
  1 MsgText = vc  
  1 Priority = i4   
  1 TypeFlag = i4   
  1 Subject = vc  
  1 MsgClass = vc  
  1 MsgSubClass = vc  
  1 Location = vc  
  1 UserName = vc  
) 

set t_rec->retval							= -1
set t_rec->return_value						= "FAILED"

select into "nl:"
from
	code_value_set cvs
	,code_value cv
plan cvs
	where cvs.definition = "COVCUSTOM"
join cv
	where cv.code_set = cvs.code_set
	and   cv.definition = trim(cnvtlower(curprog))	
	and   cv.active_ind = 1
	and   cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
order by
	cv.cdf_meaning
	,cv.begin_effective_dt_tm desc
head cv.cdf_meaning	
	case (cv.cdf_meaning)
		of "DEBUG_IND":		t_rec->debug_ind 	= cnvtint(cv.description)
							t_rec->log_comments = concat(t_rec->log_comments,";","found debug_ind=",trim(cv.description))
		of "ACTIVE_IND":	t_rec->active_ind 	= cnvtint(cv.description)
							t_rec->log_comments = concat(t_rec->log_comments,";","found active_ind=",trim(cv.description))
		of "TEST_USER":		t_rec->testing_only_username 	= trim(cv.description)
							t_rec->log_comments = concat(t_rec->testing_only_username,";","found testing_only_username=",trim(cv.description))
	endcase
with nocounter

set t_rec->return_value = "FALSE"

if (t_rec->active_ind <= 0)
	go to exit_script_not_active
endif


/************************************************************************************
 *  Call the appropriate subroutine for requestin processing:                       *
 *  - If the order is processed by the async order server, request 560200 is used.  *
 *    The requestin for 560200 does not have the request sub-level.                 *
 *  - If the order is processed by the sync order server, request 560201 is used.   *
 *    The requestin for 560201 does have the request sub-level.                     *
 ************************************************************************************/
if(not validate(request->request,0))
   ;Order was processed by async order server and request 560200.  Therefore we got requestin as requestin.
   call processRequestinWithoutRequest(null)
else
   ; Order was processed by sync order server and request 560201.  Therefore we got requestin as requestin->request.
   call processRequestinWithRequest(null)
endif

if (temp_ord->cnt > 0)
	call processOrders(null)
else
	go to exit_script
endif

select into "nl:"
from
	encntr_alias ea
plan ea
	where ea.encntr_id = patientdata->encntr_id
	and   ea.active_ind = 1
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
detail
	patientdata->fin = cnvtalias(ea.alias,ea.alias_pool_cd)
with nocounter



if (
				(patientdata->encntr_id > 0.0)
		and		(patientdata->person_id > 0.0)
		and  	(orderdata->ordercnt > 0)
		and  	(orderdata->username > "")
	)
	
	if (t_rec->testing_only_username > " ")
		call echo(build2("test username active=",t_rec->testing_only_username))
		if (orderdata->username = t_rec->testing_only_username)
			call echo(build2("matched username for order=",orderdata->username))
			if (eks_common->event_repeat_index = 1)
				call sendNotification(null)
			endif
		else
			call echo(build2("did not match username, exiting without logging"))
			go to exit_script_not_active
		endif
	else
		if (eks_common->event_repeat_index = 1)
			call sendNotification(null)
		endif
	endif
endif

;set t_rec->person_id 	= requestin->request->patient_id
set t_rec->log_file_requestin = build(
										 cnvtlower(trim(curdomain))
										,"_",cnvtlower(trim(curprog))
										,"_",format(cnvtdatetime(curdate, curtime3)
										,"yyyy_mm_dd_hh_mm_ss;;d")
										,".log"
										)
set t_rec->log_file_path = build("/cerner/d_",cnvtlower(trim(curdomain)),"/cclscratch/")
set t_rec->log_file = build(t_rec->log_file_path,t_rec->log_file_requestin)

subroutine sendNotification(null)
	call echo("sendNotification")
	set 3011001Request->Module_Dir = "cust_script:" 
	set 3011001Request->Module_Name = "cov_eks_alert_wrong_order.html" 
	set 3011001Request->bAsBlob = 1 
	
	execute eks_get_source with replace ("REQUEST" ,3011001Request ) , replace ("REPLY" ,3011001Reply ) 
	set html_output = 3011001Reply->data_blob 
	
	set html_output = replace(html_output,"@MESSAGE:[PATIENTDATA]",cnvtrectojson(patientdata))
	set html_output = replace(html_output,"@MESSAGE:[ORDERDATA]",cnvtrectojson(orderdata))
	
	set 3051004Request->MsgText = html_output 
	set 3051004Request->Priority = 100 
	set 3051004Request->TypeFlag = 0 
	set 3051004Request->Subject = "Invalid Ordering Provider and Communication Type" 
	set 3051004Request->MsgClass = "APPLICATION" 
	set 3051004Request->MsgSubClass = "DISCERN" 
	set 3051004Request->Location = "REPLY" 
	set 3051004Request->UserName = orderdata->username 
	call echo(html_output)
	set stat = tdbexecute(3030000,3036100,3051004,"REC",3051004Request,"REC",3051004Reply) 
	set t_rec->return_value = "TRUE"
end ;sendNotification

subroutine processOrders(null)
	call echo("process Ad Hoc Orders")
	select into "nl:"
		order_id = temp_ord->qual[d1.seq].order_id
	from
		(dummyt d1 with seq=temp_ord->cnt)
		,order_action oa
		,prsnl p1
	plan d1
		where temp_ord->qual[d1.seq].pathway_catalog_id = 0.0
	join oa
		where oa.order_id = temp_ord->qual[d1.seq].order_id
		and   oa.action_type_cd in(value(uar_get_code_by("MEANING",6003,"ORDER")))
	join p1
		where p1.person_id 		= oa.action_personnel_id
		and   p1.person_id 		!= 0.0
		and   p1.position_cd 	!= 0.0
	order by
		order_id
	head report
		i = 0
	head order_id
		i = (i + 1)
		stat = alterlist(orderdata->orderlist,i)
		orderdata->orderlist[i].order_id = temp_ord->qual[d1.seq].order_id
		orderdata->orderlist[i].synonym_id = temp_ord->qual[d1.seq].synonym_id
		if (patientdata->person_id = 0.0)
			patientdata->person_id = temp_ord->qual[d1.seq].person_id
		endif
		if (patientdata->encntr_id = 0.0)
			if (temp_ord->qual[d1.seq].encntr_id = 0.0)
				patientdata->encntr_id = temp_ord->qual[d1.seq].originating_encntr_id
			else
				patientdata->encntr_id = temp_ord->qual[d1.seq].encntr_id
			endif
		endif
		temp_ord->qual[d1.seq].action_prsnl_id = p1.person_id
		temp_ord->qual[d1.seq].action_username = p1.username
		if (orderdata->username = " ")
			orderdata->username = temp_ord->qual[d1.seq].action_username
		endif
	foot report
		orderdata->ordercnt = i
	with nocounter
	
	call echo("process PowerPlan")
	select into "nl:"
		order_id = temp_ord->qual[d1.seq].order_id
	from
		(dummyt d1 with seq=temp_ord->cnt)
		,order_action oa
		,prsnl p1
		,act_pw_comp apc
		,pathway p
	plan d1
		where temp_ord->qual[d1.seq].pathway_catalog_id > 0.0
	join oa
		where oa.order_id = temp_ord->qual[d1.seq].order_id
		and   oa.action_type_cd in(value(uar_get_code_by("MEANING",6003,"ORDER")))
	join p1
		where p1.person_id 		= oa.action_personnel_id
		and   p1.person_id 		!= 0.0
		and   p1.position_cd 	!= 0.0
	join apc
		where apc.parent_entity_id = temp_ord->qual[d1.seq].order_id
	join p
		where p.pathway_id = apc.pathway_id
	order by
		p.pathway_id
	head report
		i = 0
	head p.pathway_id
		i = (i + 1)
		stat = alterlist(orderdata->powerplans,i)
		orderdata->powerplans[i].pathway_id = p.pathway_id
		if (patientdata->person_id = 0.0)
			patientdata->person_id = temp_ord->qual[d1.seq].person_id
		endif
		if (patientdata->encntr_id = 0.0)
			if (temp_ord->qual[d1.seq].encntr_id = 0.0)
				patientdata->encntr_id = temp_ord->qual[d1.seq].originating_encntr_id
			else
				patientdata->encntr_id = temp_ord->qual[d1.seq].encntr_id
			endif
		endif
		temp_ord->qual[d1.seq].action_prsnl_id = p1.person_id
		temp_ord->qual[d1.seq].action_username = p1.username
		if (orderdata->username = " ")
			orderdata->username = temp_ord->qual[d1.seq].action_username
		endif
	foot report
		orderdata->powerplancnt = i
	with nocounter
end ;subroutine processOrders(null)

subroutine debugMode(null)
	declare debugModeInd = i2 with protect, noconstant(0)
	set debugModeInd = t_rec->debug_ind
	call echo(concat("debugModeInd return value = ", build(debugModeInd)))
	return(debugModeInd)
end ;subroutine debugMode(null)

subroutine processRequestinWithoutRequest(null)
	call echo("processRequestinWithoutRequest")
	select into "nl:"
	from
		(dummyt d1 with seq=size(request->orderlist,5))
		,orders o
		,prsnl p1
		,code_value cv
		,code_value_extension cve
	plan d1
		where request->orderlist[d1.seq].actiontypecd in(value(uar_get_code_by("MEANING",6003,"ORDER")))
		;and   request->orderlist[d1.seq].pathwaycatalogid = 0.0
		and   request->orderlist[d1.seq].orderproviderid != 0.0
		and   request->orderlist[d1.seq].communicationtypecd != 0.0
	join o
		where o.order_id = request->orderlist[d1.seq].orderid
		;and   o.pathway_catalog_id = 0.0
	join p1
		where p1.person_id = request->orderlist[d1.seq].orderproviderid 
		and   p1.position_cd in(
									 0.0
									,value(uar_get_code_by("DISPLAY",88,"View Only"))
								)
	join cv
		where cv.code_value = request->orderlist[d1.seq].communicationtypecd
	join cve
		where cve.code_value = cv.code_value
		and   cve.field_name = "skip_cosign_ind"
		and   cve.field_value = "0"
	order by
		o.order_id
	head report
		i = 0
	head o.order_id
		i = (i + 1)
		stat = alterlist(temp_ord->qual,i)
		temp_ord->qual[i].order_id 				= o.order_id
		temp_ord->qual[i].communication_type_cd	= request->orderlist[d1.seq].communicationtypecd
		temp_ord->qual[i].synonym_id			= o.synonym_id
		temp_ord->qual[i].originating_encntr_id	= o.originating_encntr_id
		temp_ord->qual[i].encntr_id				= o.encntr_id
		temp_ord->qual[i].person_id				= o.person_id
		temp_ord->qual[i].pathway_catalog_id	= o.pathway_catalog_id
	foot report
		temp_ord->cnt = i
	with nocounter
	
	
	
end ;subroutine processRequestinWithoutRequest(null)

subroutine processRequestinWithRequest(null)
	call echo("processRequestinWithRequest")
	select into "nl:"
	from
		(dummyt d1 with seq=size(request->request->orderlist,5))
		,orders o
		,prsnl p1
		,code_value cv
		,code_value_extension cve
	plan d1
		where request->request->orderlist[d1.seq].actiontypecd in(value(uar_get_code_by("MEANING",6003,"ORDER")))
		;and   request->request->orderlist[d1.seq].pathwaycatalogid = 0.0
		and   request->request->orderlist[d1.seq].orderproviderid != 0.0
		and   request->request->orderlist[d1.seq].communicationtypecd != 0.0
	join o
		where o.order_id = request->request->orderlist[d1.seq].orderid
		;and   o.pathway_catalog_id = 0.0
	join p1
		where p1.person_id = request->request->orderlist[d1.seq].orderproviderid 
		and   p1.position_cd in(
									 0.0
									,value(uar_get_code_by("DISPLAY",88,"View Only"))
								)
	join cv
		where cv.code_value = request->request->orderlist[d1.seq].communicationtypecd
	join cve
		where cve.code_value = cv.code_value
		and   cve.field_name = "skip_cosign_ind"
		and   cve.field_value = "0"
	order by
		o.order_id
	head report
		i = 0
	head o.order_id
		i = (i + 1)
		stat = alterlist(temp_ord->qual,i)
		temp_ord->qual[i].order_id 				= o.order_id
		temp_ord->qual[i].communication_type_cd	= request->request->orderlist[d1.seq].communicationtypecd
		temp_ord->qual[i].synonym_id			= o.synonym_id
		temp_ord->qual[i].originating_encntr_id	= o.originating_encntr_id
		temp_ord->qual[i].encntr_id				= o.encntr_id
		temp_ord->qual[i].person_id				= o.person_id
		temp_ord->qual[i].pathway_catalog_id	= o.pathway_catalog_id
	foot report
		temp_ord->cnt = i
	with nocounter
end ;subroutine processRequestinWithoutRequest(null)

#exit_script

set t_rec->return_value = "TRUE"
/*
if ((validate(request)) and (debugMode(0)))
	call echojson(request,t_rec->log_file,1)
	call echorecord(request)
endif

if ((validate(temp_ord)) and (debugMode(0)))
	call echojson(temp_ord,t_rec->log_file,1)
	call echorecord(temp_ord)
endif

if ((validate(orderdata)) and (debugMode(0)))
	call echojson(orderdata,t_rec->log_file,1)
	call echorecord(orderdata)
endif

if ((validate(patientdata)) and (debugMode(0)))
	call echojson(patientdata,t_rec->log_file,1)
	call echorecord(patientdata)
endif

if ((validate(t_rec)) and (debugMode(0)))
	call echojson(t_rec,t_rec->log_file,1)
	call echorecord(t_rec)
endif
*/

#exit_script_not_active

if (trim(cnvtupper(t_rec->return_value)) = "TRUE")
	set t_rec->retval = 100
	set t_rec->log_misc1 = ""
elseif (trim(cnvtupper(t_rec->return_value)) = "FALSE")
	set t_rec->retval = 0
else
	set t_rec->retval = 0
endif

set t_rec->log_message = concat(
										trim(t_rec->log_message),";",
										trim(t_rec->log_comments),";",
										trim(eks_common->event_repeat_index),";",
										trim(cnvtupper(t_rec->return_value)),":",
										trim(cnvtstring(t_rec->patient.person_id)),"|",
										trim(cnvtstring(t_rec->patient.encntr_id)),"|"
									)
call echorecord(t_rec)

set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1

end go


