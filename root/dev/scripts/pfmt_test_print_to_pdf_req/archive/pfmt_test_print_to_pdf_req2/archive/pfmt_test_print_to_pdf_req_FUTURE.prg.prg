drop program pfmt_test_print_to_pdf_req:dba go
create program pfmt_test_print_to_pdf_req:dba

if (not validate(requestin->request,0))
	go to exit_script_no_log
else
	if (requestin->request->personid = 0.0)
		go to exit_script_no_log
	endif
endif

set debug_ind = 2	;0 = no debug, 1=basic debug with echo, 2=msgview debug ;000
set manual_ind = 1	;1 = use hard coded values

%i cust_script:bc_common_routines.inc
%i cust_script:bc_common_req.inc

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

call writeLog(build2("*************************************************************"))
call writeLog(build2("* START Validate Patient ************************************"))

select into "nl:"
from person p
plan p where p.person_id = bc_common->person_id
detail
	call writeLog(build2("--->",trim(p.name_full_formatted)))
	;THIS WILL NOT PROCESS PLAY PATIENTS
	
	if (p.name_first_key = "PDF*")
		bc_common->valid_ind = 1
	endif
	if (p.name_last_key = "CSTPDF*")
		bc_common->valid_ind = 1
	endif
	if ((p.name_first_key = "PLAY*") and (p.name_last_key = "CSTPDF*"))
		bc_common->valid_ind = 0
	endif
with nocounter
if (bc_common->valid_ind = 0)
	call writeLog(build2("--->INVALID PATIENT, go to exit_script"))
	go to exit_script
else
	call writeLog(build2("--->PATIENT PASSED"))
endif

call writeLog(build2("* END Validate Patient ************************************"))
call writeLog(build2("*************************************************************"))

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
	1 temp_event_cnt			= i2
	1 temp_eventlist[*] 
	 2 event_id					= f8
	1 temp_orderlist_cnt		= i2
	1 temp_powerplan_flag		= i2
	1 temp_orderlist[*]
		2 order_id				= f8
		2 pathway_catalog_id	= f8
		2 encntr_id 			= f8
		2 action_type_cd		= f8
		2 action_type_mean		= vc
		2 requisition_format_cd	= f8
		2 requisition_format	= vc
		2 info					= vc
	1 group_cnt 				= i2
	1 grouplist[*]
		2 order_cnt 				= i2
		2 plan_name 				= vc
		2 group_desc 				= vc
		2 pathway_id 				= f8
		2 identifier				= vc
		2 single_order				= i2
		2 reference_nbr				= vc
		2 event_id					= f8
		2 task_id					= f8
		2 event_title_text			= vc
		2 printer_name 				= vc
		2 requisition_script		= vc
		2 action_type				= vc
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
	     3 parent_event_id			= f8
	     3 event_id					= f8
	     3 requisition_script		= vc
	     3 task_id					= f8
	     3 blob_event_id			= f8
	     3 event_title_text			= vc
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

if (bc_common->valid_ind = 1)
	call writeLog(build2("*-> Valid Patient, starting ",trim(t_rec->log_filename_a)," with requestin"))
	if (validate(requestin))
		call writeLog(build2("->writing requestin to ",trim(t_rec->log_filename_a)))
		call echojson(requestin,t_rec->log_filename_request)
		call echojson(requestin,t_rec->log_filename_a)
	endif
endif

set k = 0

call writeLog(build2("*************************************************************"))
call writeLog(build2("* START Add Orders to Temp **********************************"))

call writeLog(build2("-->selecting orders from orderlist, size=",trim(cnvtstring(size(requestin->request->orderlist,5)))))

for (i=1 to size(requestin->request->orderlist,5))
	call writeLog(build2("--->order_id=",trim(cnvtstring(requestin->request->orderlist[i].orderid))))
	call writeLog(build2("--->action_type_cd=",trim(cnvtstring(requestin->request->orderlist[i].ACTIONTYPECD))))
	call writeLog(build2("--->requisition_format_cd=",trim(cnvtstring(requestin->request->orderlist[i].REQUISITIONFORMATCD))))
	
	if (requestin->request->orderlist[i].ACTIONTYPECD in(
															 value(uar_get_code_by("MEANING",6003,"ORDER"))
															,value(uar_get_code_by("MEANING",6003,"CANCEL"))
															,value(uar_get_code_by("MEANING",6003,"CANCEL DC"))
															,value(uar_get_code_by("MEANING",6003,"MODIFY"))
														))
		for (j=1 to bc_common->requisition_cnt)
			if (requestin->request->orderlist[i].REQUISITIONFORMATCD = bc_common->requisition_qual[j].requisition_format_cd)
				set t_rec->temp_orderlist_cnt = (t_rec->temp_orderlist_cnt + 1)
				set stat = alterlist(t_rec->temp_orderlist,t_rec->temp_orderlist_cnt)
				set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].order_id = requestin->request->orderlist[i].orderid
				set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].pathway_catalog_id	= requestin->request->orderlist[i].PATHWAYCATALOGID
				set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].encntr_id = requestin->request->orderlist[i].ORIGINATINGENCOUNTERID
				set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_cd = requestin->request->orderlist[i].ACTIONTYPECD
				set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].requisition_format_cd 
						= requestin->request->orderlist[i].REQUISITIONFORMATCD
				set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].requisition_format 
						= uar_get_code_display(requestin->request->orderlist[i].REQUISITIONFORMATCD)
				set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_mean 
						= uar_get_code_meaning(requestin->request->orderlist[i].ACTIONTYPECD)
				; double check PATHWAYCATALOGID, some requestin doesn't appear to send it
				if (requestin->request->orderlist[i].PATHWAYCATALOGID = 0.0)
					select into "nl:"
					from orders o where o.order_id = requestin->request->orderlist[i].orderid
					detail
						t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].pathway_catalog_id = o.pathway_catalog_id
					with nocounter
					
					set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].info = "pathwaycatalog_id = 0"
					
				endif
				
				; double check new order with a pathway_catalog to see if it's adding to a phase, some requestin doesn't appear to send it
				if (	(requestin->request->orderlist[i].PATHWAYCATALOGID > 0.0) and 
						(size(requestin->request->orderlist[i].PROTOCOLINFO,5) > 0) and ;set to 0 if not DOT
						(uar_get_code_meaning(requestin->request->orderlist[i].ACTIONTYPECD) in("ORDER")))
						
						select into "nl:"
						from 
							 act_pw_comp apc
							,pathway p 
						where 	apc.parent_entity_id = requestin->request->orderlist[i].orderid
						and 	p.pathway_id = apc.pathway_id 
						and 	apc.created_dt_tm > p.order_dt_tm 
						detail
							t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_mean = "MODIFY"
						with nocounter
						
						set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].info = "protocol > 0, order"
						
						;if (curqual = 0)
						;	set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_mean = "MODIFY"
						;endif
				endif
				
				if (	(requestin->request->orderlist[i].PATHWAYCATALOGID > 0.0) and 
						(size(requestin->request->orderlist[i].PROTOCOLINFO,5) = 0) and ;set to 0 if not DOT
						(uar_get_code_meaning(requestin->request->orderlist[i].ACTIONTYPECD) in("ORDER")))
						
						select into "nl:"
						from 
							 act_pw_comp apc
							,pathway p 
						where 	apc.parent_entity_id = requestin->request->orderlist[i].orderid
						and 	p.pathway_id = apc.pathway_id 
						and 	( (apc.created_dt_tm > p.order_dt_tm) or (apc.unlink_start_dt_tm_ind = 1) )
						detail
							t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_mean = "MODIFY"
						with nocounter
						
						set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].info = "protocol = 0, order"
						
						;TO-DO need to add in a section/sub routine to find the existing document at this point.  If 
						;that is not found then change this back to a new order.
						;if (curqual = 0)
						;	set t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_mean = "MODIFY"
						;endif
				endif
				
				if (
						(t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].pathway_catalog_id > 0.0) and
						(t_rec->temp_orderlist[t_rec->temp_orderlist_cnt].action_type_mean in("MODIFY","CANCEL"))
						)
					set t_rec->temp_powerplan_flag = (t_rec->temp_powerplan_flag + 1)
				endif
			endif
		endfor
	endif
endfor

call writeLog(build2("* END Add Orders to Temp ************************************"))
call writeLog(build2("*************************************************************"))

call writeLog(build2("*************************************************************"))
call writeLog(build2("* START Adding Single Orders ********************************"))

select into "nl:"
	action_type = t_rec->temp_orderlist[d.seq].action_type_cd
from
	 (dummyt d with seq=t_rec->temp_orderlist_cnt)
	,orders o
	,order_catalog oc
	,encounter e
plan d
join o
	where o.order_id	= t_rec->temp_orderlist[d.seq].order_id
	and   o.pathway_catalog_id = 0.0
join oc
	where oc.catalog_cd	= o.catalog_cd
join e
	where e.encntr_id	= o.originating_encntr_id
order by
	 action_type
	,oc.requisition_format_cd
	,o.order_id
head report
	cnt = 0
	gcnt = 0
	call writeLog(build2("---->inside order selection query"))
head action_type
	call writeLog(build2("---->inside action type=",trim(uar_get_code_display(action_type))))
	cnt = 0
head oc.requisition_format_cd
	call writeLog(build2("---->inside req format=",trim(uar_get_code_display(oc.requisition_format_cd))))
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
	t_rec->grouplist[gcnt].orderlist[cnt].printer_name 			= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id)),".pdf")
	t_rec->grouplist[gcnt].orderlist[cnt].conversation_id 		= 0.0
	t_rec->grouplist[gcnt].orderlist[cnt].requisition_cd 		= oc.requisition_format_cd
	t_rec->grouplist[gcnt].orderlist[cnt].action_cd 			= requestin->request->orderlist[d.seq].actiontypecd

	/*for (j=1 to bc_common->requisition_cnt)
		if (oc.requisition_format_cd = bc_common->requisition_qual[j].requisition_format_cd)
			
			t_rec->grouplist[gcnt].orderlist[cnt].requisition_script = bc_common->requisition_qual[j].requisition_object
			t_rec->grouplist[gcnt].orderlist[cnt].plan_name			 = bc_common->requisition_qual[j].requisition_title
			
		endif
	endfor*/

	;t_rec->grouplist[gcnt].group_desc 			= t_rec->grouplist[gcnt].orderlist[cnt].plan_name
foot oc.requisition_format_cd
	t_rec->grouplist[gcnt].printer_name			= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id))
													,trim(format(sysdate,"hhmmss;;d") ),".pdf")
	;t_rec->grouplist[gcnt].requisition_script 	= t_rec->grouplist[gcnt].orderlist[cnt].requisition_script
	t_rec->grouplist[gcnt].single_order			= 1
	t_rec->grouplist[gcnt].action_type			= uar_get_code_meaning(action_type)

	for (j=1 to bc_common->requisition_cnt)
		if (oc.requisition_format_cd = bc_common->requisition_qual[j].requisition_format_cd)
			
			t_rec->grouplist[gcnt].requisition_script = bc_common->requisition_qual[j].requisition_object
			t_rec->grouplist[gcnt].group_desc 			 = bc_common->requisition_qual[j].requisition_title
			
		endif
	endfor
	cnt = 0
foot action_type
	call writeLog(build2("<-----exiting action selection query"))
foot report
	t_rec->group_cnt = gcnt
	cnt = 0
	call writeLog(build2("<-----exiting order selection query"))
with nocounter

call writeLog(build2("* END Adding Single Orders ********************************"))
call writeLog(build2("*************************************************************"))


call writeLog(build2("*************************************************************"))
call writeLog(build2("* START Adding PowerPlan Orders ******************************"))
call writeLog(build2("-->selecting orders from orderlist, size=",trim(cnvtstring(size(requestin->request->orderlist,5)))))
if (t_rec->temp_powerplan_flag = 0)
	call writeLog(build2("->t_rec->temp_powerplan_flag=",trim(cnvtstring(t_rec->temp_powerplan_flag))))
	select into "nl:"
		 apc.pathway_id
		,action_type = t_rec->temp_orderlist[d.seq].action_type_cd
	from
		 (dummyt d with seq=t_rec->temp_orderlist_cnt)
		,orders o
		,order_catalog oc
		,encounter e
		,act_pw_comp apc
		,pathway_comp pc1
		,pathway_catalog pc2
		,pathway p
	plan d
	join o
		where o.order_id	= t_rec->temp_orderlist[d.seq].order_id
		and   o.pathway_catalog_id > 0.0
		and   o.protocol_order_id = 0.0
	join oc
		where oc.catalog_cd	= o.catalog_cd
	join e
		where e.encntr_id	= o.originating_encntr_id
	join apc
		where apc.parent_entity_id = o.order_id
	join pc1
		where pc1.pathway_comp_id =  apc.pathway_comp_id
	join pc2
		where pc2.pathway_catalog_id = pc1.pathway_catalog_id
	join p
		where p.pathway_id = apc.pathway_id
	order by
		 apc.pathway_id
		,oc.requisition_format_cd
		,o.order_id
	head report
		cnt = 0
		gcnt = 0
		call writeLog(build2("---->inside order selection query"))
	head apc.pathway_id
		call writeLog(build2("---->inside pathway_id=",trim(cnvtstring(apc.pathway_id))))
		cnt = 0
	head oc.requisition_format_cd
		call writeLog(build2("---->inside req format=",trim(uar_get_code_display(oc.requisition_format_cd))))
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
		t_rec->grouplist[gcnt].orderlist[cnt].printer_name 			
												= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id)),".pdf")
		t_rec->grouplist[gcnt].orderlist[cnt].conversation_id 		= 0.0
		t_rec->grouplist[gcnt].orderlist[cnt].requisition_cd 		= oc.requisition_format_cd
		t_rec->grouplist[gcnt].orderlist[cnt].action_cd 			= requestin->request->orderlist[d.seq].actiontypecd
		t_rec->grouplist[gcnt].orderlist[cnt].pathway_id			= apc.pathway_id
		
	foot oc.requisition_format_cd
		t_rec->grouplist[gcnt].printer_name			= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id))
														,trim(format(sysdate,"hhmmss;;d") ),".pdf")
		;t_rec->grouplist[gcnt].requisition_script 	= t_rec->grouplist[gcnt].orderlist[cnt].requisition_script
		t_rec->grouplist[gcnt].single_order			= 0
		t_rec->grouplist[gcnt].action_type			= uar_get_code_meaning(action_type)
	
		for (j=1 to bc_common->requisition_cnt)
			if (oc.requisition_format_cd = bc_common->requisition_qual[j].requisition_format_cd)
				t_rec->grouplist[gcnt].requisition_script = bc_common->requisition_qual[j].requisition_object	
			endif
		endfor
		cnt = 0
		t_rec->grouplist[gcnt].group_desc = p.pw_group_desc
		if (trim(pc2.description) = trim(p.pw_group_desc))
			t_rec->grouplist[gcnt].plan_name = ""
		else
			t_rec->grouplist[gcnt].plan_name = pc2.description
		endif
	foot apc.pathway_id
		call writeLog(build2("<-----exiting pathway_id selection query"))
	foot report
		t_rec->group_cnt = gcnt
		cnt = 0
		call writeLog(build2("<-----exiting order selection query"))
	with nocounter
else
	call writeLog(build2("-> (else) t_rec->temp_powerplan_flag=",trim(cnvtstring(t_rec->temp_powerplan_flag))))
	select into "nl:"
	from
		 (dummyt d with seq=t_rec->temp_orderlist_cnt)
		,orders o1
		,orders o2
		,act_pw_comp apc1
		,act_pw_comp apc2
		,order_catalog oc2
		,pathway p2
	plan d
	join o1 
		where o1.order_id =   t_rec->temp_orderlist[d.seq].order_id
	join apc1
		where apc1.parent_entity_id = o1.order_id
	join apc2
		where apc2.pathway_id = apc1.pathway_id
	join o2
		where o2.order_id = apc2.parent_entity_id
		and   o2.order_id > 0.0
		and   o2.order_status_cd not in(
											 value(uar_get_code_by("MEANING",6004,"CANCELED"))
											,value(uar_get_code_by("MEANING",6004,"COMPLETED"))
											,value(uar_get_code_by("MEANING",6004,"DELETED"))
											,value(uar_get_code_by("MEANING",6004,"DISCONTINUED"))
										)
	join oc2
		where oc2.catalog_cd = o2.catalog_cd
	join p2
		where p2.pathway_id = apc2.pathway_id
	order by
		 apc2.pathway_id
		,oc2.requisition_format_cd
		,o2.order_id
	head report
		cnt = 0
		gcnt = 0
		call writeLog(build2("---->inside order selection query"))
	head apc2.pathway_id
		call writeLog(build2("---->inside pathway_id=",trim(cnvtstring(apc2.pathway_id))))
		call writeLog(build2("looking apc2.pathway_id="
			,trim(cnvtstring(apc2.pathway_id))))
		cnt = 0
	head oc2.requisition_format_cd
		call writeLog(build2("---->inside req format=",trim(uar_get_code_display(oc2.requisition_format_cd))))
		gcnt = (gcnt + 1)
		cnt = 0
		stat = alterlist(t_rec->grouplist,gcnt)
		t_rec->group_cnt = gcnt
	head o2.order_id
		bc_common->encntr_id = o2.originating_encntr_id
		cnt = (cnt + 1)
		t_rec->grouplist[gcnt].order_cnt = cnt
		stat = alterlist(t_rec->grouplist[gcnt].orderlist,cnt)
		t_rec->grouplist[gcnt].orderlist[cnt].order_id 				= o2.order_id
		t_rec->grouplist[gcnt].orderlist[cnt].encntr_id 			= o2.originating_encntr_id
		t_rec->grouplist[gcnt].orderlist[cnt].group_id 				= gcnt
		t_rec->grouplist[gcnt].orderlist[cnt].printer_name 			
												= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o2.order_id)),".pdf")
		t_rec->grouplist[gcnt].orderlist[cnt].conversation_id 		= 0.0
		t_rec->grouplist[gcnt].orderlist[cnt].requisition_cd 		= oc2.requisition_format_cd
		t_rec->grouplist[gcnt].orderlist[cnt].action_cd 			= value(uar_get_code_by("MEANING",6003,"MODIFY"))
		t_rec->grouplist[gcnt].orderlist[cnt].pathway_id			= apc2.pathway_id
		
		call writeLog(build2("addded t_rec->grouplist[gcnt].orderlist[cnt].order_id="
			,trim(cnvtstring(t_rec->grouplist[gcnt].orderlist[cnt].order_id))))
	foot oc2.requisition_format_cd
		t_rec->grouplist[gcnt].printer_name			= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o2.order_id))
														,trim(format(sysdate,"hhmmss;;d") ),".pdf")
		;t_rec->grouplist[gcnt].requisition_script 	= t_rec->grouplist[gcnt].orderlist[cnt].requisition_script
		t_rec->grouplist[gcnt].single_order			= 0
		t_rec->grouplist[gcnt].action_type			= "MODIFY"
	
		for (j=1 to bc_common->requisition_cnt)
			if (oc2.requisition_format_cd = bc_common->requisition_qual[j].requisition_format_cd)
				t_rec->grouplist[gcnt].requisition_script = bc_common->requisition_qual[j].requisition_object	
			endif
		endfor
		cnt = 0
		t_rec->grouplist[gcnt].group_desc = p2.pw_group_desc
		t_rec->grouplist[gcnt].pathway_id = p2.pathway_id
		;not needed for modify (?)
		;if (trim(pc2.description) = trim(p2.pw_group_desc))
		;	t_rec->grouplist[gcnt].plan_name = ""
		;else
		;	t_rec->grouplist[gcnt].plan_name = pc2.description
		;endif
	foot apc2.pathway_id
		call writeLog(build2("<-----exiting pathway_id selection query"))
	foot report
		t_rec->group_cnt = gcnt
		cnt = 0
		call writeLog(build2("<-----exiting order selection query"))
	with nocounter

	if (t_rec->group_cnt = 0)
		call writeLog(build2("t_rec->group_cnt=0, assume all orders in plan are canceled"))
		select into "nl:"
			action_type = t_rec->temp_orderlist[d.seq].action_type_cd
		from
			 (dummyt d with seq=t_rec->temp_orderlist_cnt)
			,orders o
			,order_catalog oc
			,encounter e
		plan d
		join o
			where o.order_id	= t_rec->temp_orderlist[d.seq].order_id
		join oc
			where oc.catalog_cd	= o.catalog_cd
		join e
			where e.encntr_id	= o.originating_encntr_id
		order by
			 action_type
			,oc.requisition_format_cd
			,o.order_id
		head report
			cnt = 0
			gcnt = 0
			call writeLog(build2("---->inside order selection query"))
		head action_type
			call writeLog(build2("---->inside action type=",trim(uar_get_code_display(action_type))))
			cnt = 0
		head oc.requisition_format_cd
			call writeLog(build2("---->inside req format=",trim(uar_get_code_display(oc.requisition_format_cd))))
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
			t_rec->grouplist[gcnt].orderlist[cnt].printer_name 			= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id)),".pdf")
			t_rec->grouplist[gcnt].orderlist[cnt].conversation_id 		= 0.0
			t_rec->grouplist[gcnt].orderlist[cnt].requisition_cd 		= oc.requisition_format_cd
			t_rec->grouplist[gcnt].orderlist[cnt].action_cd 			= requestin->request->orderlist[d.seq].actiontypecd
		
			/*for (j=1 to bc_common->requisition_cnt)
				if (oc.requisition_format_cd = bc_common->requisition_qual[j].requisition_format_cd)
					
					t_rec->grouplist[gcnt].orderlist[cnt].requisition_script = bc_common->requisition_qual[j].requisition_object
					t_rec->grouplist[gcnt].orderlist[cnt].plan_name			 = bc_common->requisition_qual[j].requisition_title
					
				endif
			endfor*/
		
			;t_rec->grouplist[gcnt].group_desc 			= t_rec->grouplist[gcnt].orderlist[cnt].plan_name
		foot oc.requisition_format_cd
			t_rec->grouplist[gcnt].printer_name			= concat(t_rec->print_dir,"req_pdf_",trim(cnvtstring(o.order_id))
															,trim(format(sysdate,"hhmmss;;d") ),".pdf")
			;t_rec->grouplist[gcnt].requisition_script 	= t_rec->grouplist[gcnt].orderlist[cnt].requisition_script
			t_rec->grouplist[gcnt].single_order			= 1
			t_rec->grouplist[gcnt].action_type			= uar_get_code_meaning(action_type)
		
			for (j=1 to bc_common->requisition_cnt)
				if (oc.requisition_format_cd = bc_common->requisition_qual[j].requisition_format_cd)
					
					t_rec->grouplist[gcnt].requisition_script = bc_common->requisition_qual[j].requisition_object
					t_rec->grouplist[gcnt].group_desc 			 = bc_common->requisition_qual[j].requisition_title
					
				endif
			endfor
			cnt = 0
		foot action_type
			call writeLog(build2("<-----exiting action selection query"))
		foot report
			t_rec->group_cnt = gcnt
			cnt = 0
			call writeLog(build2("<-----exiting order selection query"))
		with nocounter
	endif

endif

call writeLog(build2("* END Adding PowerPlan Orders *******************************"))
call writeLog(build2("*************************************************************"))


call writeLog(build2("bc_common->person_id=",trim(cnvtstring(bc_common->person_id))))
call writeLog(build2("bc_common->encntr_id=",trim(cnvtstring(bc_common->encntr_id))))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Find Existing Order Document ************************"))

if (t_rec->group_cnt > 0)
	for (i=1 to t_rec->group_cnt)
		for (j=1 to t_rec->grouplist[i].order_cnt)
			call writeLog(build2("-->Starting Query for existing document")) 
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
			;and     cnvtreal(ce.reference_nbr) = t_rec->grouplist[i].orderlist[j].order_id
			and parser(concat(^ce.reference_nbr="*^,trim(cnvtstring(t_rec->grouplist[i].orderlist[j].order_id)),^*"^))
			order by
				 ce.reference_nbr
				,ce.event_id
				,ce.valid_from_dt_tm desc
			head report
				call writeLog(build2("-->inside event query<--"))
			head ce.event_id
				t_rec->grouplist[i].orderlist[j].event_id = ce.event_id
				t_rec->grouplist[i].orderlist[j].parent_event_id = ce.parent_event_id
				call writeLog(build2("-->t_rec->grouplist[",trim(cnvtstring(i)),"].orderlist[",trim(cnvtstring(j)),"].event_id=",trim(
				cnvtstring(ce.event_id))))
				t_rec->grouplist[i].orderlist[j].event_title_text = ce.event_title_text
			foot report
				call writeLog(build2("-->leaving event query<--"))
			with nocounter
			
			select into "nl:"
			from 
				ce_blob_result ceb
				,clinical_event ce
			plan ce
				where ce.parent_event_id = t_rec->grouplist[i].orderlist[j].event_id
			join ceb
				where ceb.event_id = ce.event_id
			    and   ceb.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
			detail
				t_rec->grouplist[i].orderlist[j].blob_event_id = ceb.event_id
				call writeLog(build2("-->t_rec->grouplist[",trim(cnvtstring(i)),"].orderlist[",trim(cnvtstring(j)),"].blob_event_id=",trim(
				cnvtstring(ceb.event_id))))
			with nocounter
		endfor
	endfor
endif

call writeLog(build2("* END Find Existing Order Document ***********************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("* START Add Orders to Request ******************************"))

if (t_rec->group_cnt > 0)
	for (i=1 to t_rec->group_cnt)
		if (t_rec->grouplist[i].order_cnt > 0)
 			
			set stat = initrec(req_request)
			
			set req_request->person_id 			= bc_common->person_id
			set req_request->print_prsnl_id 	= reqinfo->updt_id
			set req_request->printer_name 		= t_rec->grouplist[i].printer_name
			
			set req_request->cnt = 0
			
			if (t_rec->grouplist[i].action_type in("MODIFY","ORDER"))
				call writeLog(build2(^t_rec->grouplist[i].action_type in("MODIFY","ORDER")^))
				for (j=1 to t_rec->grouplist[i].order_cnt)
						set req_request->cnt = (req_request->cnt + 1)
						set stat = alterlist(req_request->order_qual,req_request->cnt)
						set req_request->order_qual[req_request->cnt].order_id 			= t_rec->grouplist[i].orderlist[j].order_id
						set req_request->order_qual[req_request->cnt].encntr_id 		= t_rec->grouplist[i].orderlist[j].encntr_id
						set req_request->order_qual[req_request->cnt].conversation_id 	= 0.0
						;set req_request->order_qual[j].conversation_id 	= t_rec->grouplist[i].orderlist[1].conversation_id
						set req_request->requisition_script 				= t_rec->grouplist[i].requisition_script
						if (j=1)
							set t_rec->grouplist[i].reference_nbr			= trim(cnvtstring(t_rec->grouplist[i].orderlist[j].order_id))
						else
							set t_rec->grouplist[i].reference_nbr			= concat(	trim(t_rec->grouplist[i].reference_nbr),":",
																			    		trim(cnvtstring(t_rec->grouplist[i].orderlist[j].order_id
																			    		)))
						endif													
						call writeLog(build2("-->adding:req_request->order_qual[",trim(cnvtstring(req_request->cnt)),"].order_id=",
							trim(cnvtstring(req_request->order_qual[req_request->cnt].order_id))))
						call writeLog(build2("-->adding:req_request->order_qual[",trim(cnvtstring(req_request->cnt)),"].encntr_id=",
							trim(cnvtstring(req_request->order_qual[req_request->cnt].encntr_id))))
						call writeLog(build2("-->adding:req_request->order_qual[",trim(cnvtstring(req_request->cnt)),"].conversation_id=",
							trim(cnvtstring(req_request->order_qual[req_request->cnt].conversation_id))))
						call writeLog(build2("-->adding:req_request->printer_name=",trim(req_request->printer_name)))
						call writeLog(build2("-->adding:req_request->requisition_script=",trim(req_request->requisition_script)))
						call writeLog(build2("-->adding:t_rec->grouplist[i].reference_nbr=",trim(t_rec->grouplist[i].reference_nbr)))
				endfor
					
				if (req_request->requisition_script > " ")
					set req_request->execute_statement =
						build2(^execute ^,trim(req_request->requisition_script),^ with replace("REQUEST",REQ_REQUEST) go^)  
					call writeLog(build2(req_request->execute_statement))
					call parser(req_request->execute_statement)  
				endif
	 			
	 			if (validate(req_request))
					call writeLog(build2("->writing req_request to ",trim(t_rec->log_filename_a)))
					call echojson(req_request,t_rec->log_filename_a)
					call echorecord(req_request)
				endif
		
			;if (req_request->find_file_stat = 1)	
					set dclcom = build2(^gs -o ^	
									,req_request->pdf_name,^ ^	
  									,^-sDEVICE=pdfwrite ^	
  									,^-dPDFSETTINGS=/prepress ^	
  									,^-dHaveTrueTypes=true ^	
  									,^-dEmbedAllFonts=true ^	
  									,^-dSubsetFonts=false ^	
  									,^-c ".setpdfwrite <</NeverEmbed [ ]>> setdistillerparams" ^	
  									,^-f ^	
  									,req_request->printer_name) 	
				set dclstat = 0	
					
				call writeLog(build2( "dclcom=",trim(dclcom)))	
				call dcl(dclcom, size(trim(dclcom)), dclstat) 	
				call writeLog(build2( "dclstat=",trim(cnvtstring(dclstat))))	
				
				set stat = initrec(mmf_store_reply)
				set stat = initrec(mmf_store_request)
				
	 
				set mmf_store_request->filename 			= concat(req_request->printer_name)
				set mmf_store_request->mediatype 			= "application/pdf"
				set mmf_store_request->contenttype 			= bc_common->pdf_content_type
				set mmf_store_request->name 				= concat("Requisition ",trim(format(sysdate,";;q")))
				set mmf_store_request->personid 			= bc_common->person_id
				set mmf_store_request->encounterid 			= bc_common->encntr_id
	 
	 			call echorecord(mmf_store_request)
	 			
	 			call writeLog(build2(^--->execute mmf_store_object_with_xref^))
				execute mmf_store_object_with_xref with replace("REQUEST",mmf_store_request), replace("REPLY",mmf_store_reply)
	 			
	 			set t_rec->identifier = mmf_store_reply->identifier
	 			set t_rec->grouplist[i].identifier = mmf_store_reply->identifier
	 			call writeLog(build2("---->set t_rec->identifier=",t_rec->identifier))
				call writeLog(build2("---->set t_rec->grouplist[i].identifier=",t_rec->grouplist[i].identifier))
				
				if (t_rec->grouplist[i].action_type in("MODIFY"))
					call writeLog(build2(^t_rec->grouplist[i].action_type in("MODIFY")^))
					call writeLog(build2("* looking to update Document Due to Modify *****************************"))
					for (j=1 to t_rec->grouplist[i].order_cnt)
						if (t_rec->grouplist[i].orderlist[j].event_id > 0.0)
							call writeLog(build2("* START Updating Document Due to Modify *****************************"))
							
							if (substring(1,9,t_rec->grouplist[i].orderlist[j].event_title_text) in("MODIFIED:","ACTIONED:"))
								set t_rec->grouplist[i].orderlist[j].event_title_text = trim(substring(10,200,
									t_rec->grouplist[i].orderlist[j].event_title_text))
							endif 
							
							update into clinical_Event 							
							set result_status_cd = value(uar_get_code_by("MEANING",8,"MODIFIED")),
							  event_title_text		= concat("MODIFIED:",trim(t_rec->grouplist[i].orderlist[j].event_title_text)),
							  updt_dt_tm            = cnvtdatetime(curdate, curtime3),
							  updt_id               = reqinfo->updt_id,
						      updt_task             = reqinfo->updt_task,
							  updt_cnt              = 0,
							  updt_applctx          = reqinfo->updt_applctx
							where parent_event_id = t_rec->grouplist[i].orderlist[j].event_id
							commit
							
							update into ce_blob_result 
							set blob_handle 		= t_rec->grouplist[i].identifier,
							  updt_dt_tm            = cnvtdatetime(curdate, curtime3),
							  updt_id               = reqinfo->updt_id,
						      updt_task             = reqinfo->updt_task,
							  updt_cnt              = 0,
							  updt_applctx          = reqinfo->updt_applctx
							where event_id = t_rec->grouplist[i].orderlist[j].blob_event_id
							and   valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
							commit
							
							call writeLog(build2("* END   Updating Document ************************************"))
					    
					    call writeLog(build2("* START  Adding Document Action ************************************"))
						set stat = initrec(ensure_request)
						set stat = alterlist(ensure_request->req, 1) 
						set ensure_request->req[1].ensure_type 			 		= 2 
						set ensure_request->req[1].version_dt_tm_ind 			= 1 
						set ensure_request->req[1].event_prsnl.event_id 		= t_rec->grouplist[i].orderlist[j].event_id
						set ensure_request->req[1].event_prsnl.action_type_cd 	= value(uar_get_code_by("MEANING",21,"MODIFY"))  
						set ensure_request->req[1].event_prsnl.action_dt_tm 	= cnvtdatetime(curdate,curtime3) 
						set ensure_request->req[1].event_prsnl.action_prsnl_id 	= reqinfo->updt_id
						set ensure_request->req[1].event_prsnl.proxy_prsnl_id 	= 0.00 
						set ensure_request->req[1].event_prsnl.action_status_cd = value(uar_get_code_by("MEANING",103,"COMPLETED"))
						set ensure_request->req[1].event_prsnl.defeat_succn_ind = 1 
						;set ensure_request->req[1].event_prsnl.action_comment = "Order Canceled" 
						
						set update_ind = 1
						for (ii=1 to t_rec->temp_event_cnt)
							if (t_rec->grouplist[i].orderlist[j].event_id = t_rec->temp_eventlist[ii].event_id)
								set update_ind = 0
							endif
						endfor
						
						if (update_ind = 1)
							call writeLog(build2("-->execute inn_event_prsnl_batch_ensure"))
							execute inn_event_prsnl_batch_ensure 
								with replace("ensure_request",ensure_request),replace("ensure_reply",ensure_reply)
							set t_rec->temp_event_cnt = (t_rec->temp_event_cnt + 1)
							set stat = alterlist(t_rec->temp_eventlist,t_rec->temp_event_cnt)
							set t_rec->temp_eventlist[t_rec->temp_event_cnt].event_id = t_rec->grouplist[i].orderlist[j].event_id 
						else
							call writeLog(build2("-->SKIPPING inn_event_prsnl_batch_ensure, event already has action"))
						endif ;update_ind = 1
						endif ;t_rec->grouplist[i].orderlist[j].event_id > 0.0
						
						call writeLog(build2("** Finding TASK_ID *"))
						select into "nl:"
							from 
								task_activity ta
							plan ta
								where ta.event_id = t_rec->grouplist[i].orderlist[j].event_id
								and   ta.task_id > 0.0
								and   ta.task_status_cd = value(uar_get_code_by("MEANING",79,"PENDING"))
							order by
								ta.active_status_dt_tm
							head report
								cnt = 0
							detail
								t_rec->grouplist[i].orderlist[j].task_id = ta.task_id
							with nocounter
						call writeLog(build2("**t_rec->grouplist[i].orderlist[j].task_id=",
							trim(cnvtstring(t_rec->grouplist[i].orderlist[j].task_id))))
							
						if (t_rec->grouplist[i].orderlist[j].task_id > 0.0)
							call writeLog(build2("*--->task id found and updating task*"))
							set stat = 1
							update into task_activity ta
							set ta.scheduled_dt_tm =  cnvtdatetime(curdate,curtime3)
							    ,ta.task_dt_tm = cnvtdatetime(curdate,curtime3)
							     where ta.task_id = t_rec->grouplist[i].orderlist[j].task_id
							 commit 
						else
							set stat = 1
							call writeLog(build2("* START Adding Task for Modify ********************************"))
	
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
						call writeLog(build2(^updating task^))
						update into 
							task_activity ta 
						set  ta.task_class_cd = value(uar_get_code_by("MEANING",6025,"SCH"))
							,ta.msg_subject = "updated from order script"
							,ta.event_id = t_rec->grouplist[i].orderlist[j].parent_event_id
						where ta.task_id = 560300_reply->task_id 
						commit 
					endif
					 
					 
					call writeLog(build2("* END   Adding Task for modify ****************************************"))
						endif
						
					endfor;looping through modify orders
					call writeLog(build2(^-->ending modify logig^))		
				endif ;end MODIFY logic
				
				if (t_rec->grouplist[i].action_type in("ORDER"))
					call writeLog(build2(^t_rec->grouplist[i].action_type in("ORDER")^))
					set stat = initrec(mmf_publish_ce_request)
					set stat = initrec(mmf_publish_ce_reply)
		
		 			set mmf_publish_ce_request->documenttype_key 			= bc_common->pdf_display_key
					set mmf_publish_ce_request->service_dt_tm 				= cnvtdatetime(curdate, curtime3)
					set mmf_publish_ce_request->personId 					= bc_common->person_id
					set mmf_publish_ce_request->encounterId 				= bc_common->encntr_id
					
					set stat = alterlist(mmf_publish_ce_request->mediaObjects,1)
					set mmf_publish_ce_request->mediaObjects[1]->display 	= 'Requisition Attachment 1'
					set mmf_publish_ce_request->mediaObjects[1]->identifier = t_Rec->identifier
		
					set mmf_publish_ce_request->title = nullterm(
																	concat(
																				trim(t_rec->grouplist[i].group_desc), " ",
																				trim(t_rec->grouplist[i].plan_name)
																			)
																)
					
					set mmf_publish_ce_request->noteformat = 'AS'
					set mmf_publish_ce_request->publishAsNote=1
					set mmf_publish_ce_request->debug=1
					
					if (t_rec->grouplist[i].single_order = 1)
						set mmf_publish_ce_request->order_id =t_rec->grouplist[i].orderlist[1].order_id
					endif
					set mmf_publish_ce_request->reference_nbr = substring(1,100,build(trim(t_rec->grouplist[i].reference_nbr)))
					
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
		 			
		 			call writeLog(build2(^--->execute bc_mmf_publish_ce^))
					execute bc_mmf_publish_ce with replace("REQUEST",mmf_publish_ce_request),replace("REPLY",mmf_publish_ce_reply)
					
					call writeLog(build2(^--->mmf_publish_ce_reply->parentEventId=^,trim(cnvtstring(mmf_publish_ce_reply->parentEventId))))
		 			
		 			if (validate(mmf_publish_ce_reply))
						call echojson(mmf_publish_ce_reply,t_rec->log_filename_a,1)
						call echorecord(mmf_publish_ce_reply)
					endif
					
					call writeLog(build2("* START Adding Task ****************************************"))
	
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
				endif ;ORDER action
				
			elseif (t_rec->grouplist[i].action_type in("CANCEL"))
				call writeLog(build2("**Entering Cancel Mode"))
				
				for (j=1 to t_rec->grouplist[i].order_cnt)
					
					call writeLog(build2("-->t_rec->grouplist[i].orderlist[j].order_id="
						,trim(cnvtstring(t_rec->grouplist[i].orderlist[j].order_id))))
					call writeLog(build2("-->t_rec->grouplist[i].orderlist[j].event_id="
						,trim(cnvtstring(t_rec->grouplist[i].orderlist[j].event_id))))
					
					call writeLog(build2("* START Adding Action ************************************"))
					if ((t_rec->grouplist[i].orderlist[j].order_id > 0.0) and
						(t_rec->grouplist[i].orderlist[j].event_id > 0.0))
						call writeLog(build2("-->order_id and event_id passed, adding action"))
						set stat = initrec(ensure_request)
						set stat = alterlist(ensure_request->req, 1) 
						set ensure_request->req[1].ensure_type 			 		= 2 
						set ensure_request->req[1].version_dt_tm_ind 			= 1 
						set ensure_request->req[1].event_prsnl.event_id 		= t_rec->grouplist[i].orderlist[j].event_id
						set ensure_request->req[1].event_prsnl.action_type_cd 	= value(uar_get_code_by("MEANING",21,"CANCEL"))  
						set ensure_request->req[1].event_prsnl.action_dt_tm 	= cnvtdatetime(curdate,curtime3) 
						set ensure_request->req[1].event_prsnl.action_prsnl_id 	= reqinfo->updt_id
						set ensure_request->req[1].event_prsnl.proxy_prsnl_id 	= 0.00 
						set ensure_request->req[1].event_prsnl.action_status_cd = value(uar_get_code_by("MEANING",103,"COMPLETED"))
						set ensure_request->req[1].event_prsnl.defeat_succn_ind = 1 
						set ensure_request->req[1].event_prsnl.action_comment = "Order Canceled" 
						
						set update_ind = 1
						for (ii=1 to t_rec->temp_event_cnt)
							if (t_rec->grouplist[i].orderlist[j].event_id = t_rec->temp_eventlist[ii].event_id)
								set update_ind = 0
							endif
						endfor
						
						if (update_ind = 1)
							call writeLog(build2("-->execute inn_event_prsnl_batch_ensure"))
							execute inn_event_prsnl_batch_ensure 
								with replace("ensure_request",ensure_request),replace("ensure_reply",ensure_reply)
							set t_rec->temp_event_cnt = (t_rec->temp_event_cnt + 1)
							set stat = alterlist(t_rec->temp_eventlist,t_rec->temp_event_cnt)
							set t_rec->temp_eventlist[t_rec->temp_event_cnt].event_id = t_rec->grouplist[i].orderlist[j].event_id 
						else
							call writeLog(build2("-->SKIPPING inn_event_prsnl_batch_ensure, event already has action"))
						endif ;update_ind = 1
						
						
					endif
					
					call writeLog(build2("* END Adding Action ************************************"))
					call writeLog(build2("* START Updating Task ************************************"))
						
					select into "nl:"
					from 
						task_activity ta
					plan ta
						where ta.event_id = t_rec->grouplist[i].orderlist[j].event_id
						and   ta.task_id > 0.0
						and   ta.task_status_cd in(
													value(uar_get_code_by("MEANING",79,"PENDING"))
												  )
					order by
						ta.active_status_dt_tm
					head report
						cnt = 0
					detail
						t_rec->grouplist[i].orderlist[j].task_id = ta.task_id
					with nocounter
					
					call writeLog(build2("-->t_rec->grouplist[i].orderlist[j].task_id="
								,t_rec->grouplist[i].orderlist[j].task_id))
						
					if (t_rec->grouplist[i].orderlist[j].task_id > 0.0)
						set stat = initrec(dcp_request)
						call writeLog(build2("--->dcp_request initialized"))
						select into "nl:"
						 from task_activity ta 
						 where ta.task_id = t_rec->grouplist[i].orderlist[j].task_id
						head report 
							cnt = 0
							call writeLog(build2("------>inside query for task"))
						detail
						    cnt = (cnt + 1)
                                stat = alterlist (dcp_request->task_list, 1) 
                                dcp_request->task_list[cnt].task_id = ta.task_id
                                dcp_request->task_list[cnt]->person_id             = ta.person_id 
                                dcp_request->task_list[cnt]->catalog_type_cd         = ta.catalog_type_cd 
                                dcp_request->task_list[cnt]->order_id = ta.order_id
                                dcp_request->task_list[cnt]->encntr_id = ta.encntr_id
                                dcp_request->task_list[cnt]->reference_task_id = ta.reference_task_id
                                dcp_request->task_list[cnt]->task_type_cd = ta.task_type_cd
                                dcp_request->task_list[cnt]->task_class_cd = ta.task_class_cd
                                dcp_request->task_list[cnt]->prev_task_status_cd =    ta.task_status_cd
                                dcp_request->task_list[cnt]->task_dt_tm = cnvtdatetime(ta.task_dt_tm) 
                                dcp_request->task_list[cnt]->task_tz = ta.task_tz
                                dcp_request->task_list[cnt]->task_activity_cd = ta.task_activity_cd
                                dcp_request->task_list[cnt]->catalog_cd = ta.catalog_cd
                                dcp_request->task_list[cnt]->task_status_reason_cd = ta.task_status_reason_cd
                                dcp_request->task_list[cnt]->reschedule_ind = ta.reschedule_ind 
                                dcp_request->task_list[cnt]->reschedule_reason_cd = ta.reschedule_reason_cd
                                dcp_request->task_list[cnt]->med_order_type_cd = ta.med_order_type_cd
                                dcp_request->task_list[cnt]->task_priority_cd = ta.task_priority_cd
                                dcp_request->task_list[cnt]->charted_by_agent_cd = ta.charted_by_agent_cd
                                dcp_request->task_list[cnt]->charting_context_reference = ta.charting_context_reference 
                                dcp_request->task_list[cnt]->scheduled_dt_tm = cnvtdatetime(ta.scheduled_dt_tm)
                                dcp_request->task_list[cnt]->result_set_id = ta.result_set_id
                                dcp_request->task_list[cnt].task_status_cd = value(uar_get_code_by("MEANING",79,"CANCELED"))
                            foot report
                                call writeLog(build2("<------leaving query for task"))
                            with nocounter
                            
                            call writeLog(build2("-----size(dcp_request->task_list,5)="
                                ,trim(cnvtstring(size(dcp_request->task_list,5)))))
                            for (k=1 to size(dcp_request->task_list,5))
                                call writeLog(build2("-------->inside task action for task=",
                                    trim(cnvtstring(dcp_request->task_list[k]->task_id))))
                                insert into task_action tac
                                set
                                  tac.seq = 1,
                                  tac.task_id               = dcp_request->task_list[k]->task_id,
                                  tac.task_action_seq       = seq(carenet_seq,nextval),
                                  tac.task_status_cd        = dcp_request->task_list[k]->prev_task_status_cd,
                                  tac.task_dt_tm            = cnvtdatetime (dcp_request->task_list[k]->task_dt_tm),
                                  tac.task_tz               = dcp_request->task_list[k]->task_tz,
                                
                                  tac.task_status_reason_cd = dcp_request->task_list[k]->task_status_reason_cd,
                                  tac.reschedule_reason_cd  = dcp_request->task_list[k]->reschedule_reason_cd,
                                  tac.scheduled_dt_tm       = cnvtdatetime(dcp_request->task_list[k]->scheduled_dt_tm),
                                  tac.updt_dt_tm            = cnvtdatetime(curdate, curtime3),
                                  tac.updt_id               = reqinfo->updt_id,
                                  tac.updt_task             = reqinfo->updt_task,
                                  tac.updt_cnt              = 0,
                                  tac.updt_applctx          = reqinfo->updt_applctx
                                with nocounter
                                call writeLog(build2("<-------leaving task action for task"))
                                commit  
                                call writeLog(build2("-------->inside task activity for task=",
                                trim(cnvtstring(dcp_request->task_list[k]->task_id))))
                                update into task_activity ta
                                set ta.task_status_cd = dcp_request->task_list[k].task_status_cd,
                                  ta.updt_dt_tm            = cnvtdatetime(curdate, curtime3),
                                  ta.updt_id               = reqinfo->updt_id,
                                  ta.updt_task             = reqinfo->updt_task,
                                  ta.updt_cnt              = 0,
                                  ta.updt_applctx          = reqinfo->updt_applctx
                                where ta.task_id = dcp_request->task_list[k]->task_id
                                call writeLog(build2("<-------leaving task activity for task"))
                                commit
                            endfor
						endif ;task_id > 0.0
						if (t_rec->grouplist[i].orderlist[j].event_id > 0.0)
							call writeLog(build2("* START Updating Document ************************************"))
							
							update into clinical_Event 
							set result_status_cd = value(uar_get_code_by("MEANING",8,"INERROR")),
							  updt_dt_tm            = cnvtdatetime(curdate, curtime3),
							  updt_id               = reqinfo->updt_id,
								 updt_task             = reqinfo->updt_task,
							  updt_cnt              = 0,
							  updt_applctx          = reqinfo->updt_applctx
							where parent_event_id = t_rec->grouplist[i].orderlist[j].event_id
							commit
							
							call writeLog(build2("* END   Updating Document ************************************"))
						endif
							
						call writeLog(build2("* END   Updating Task ************************************"))
					
					endfor;exit cancel mode loop
				call writeLog(build2("**Exiting Cancel Mode"))
			endif ;ORDER or MODIFY
		endif ;order_cnt > 0
	endfor ;group list loop
endif ;group_cnt > 0

call writeLog(build2("* END   Add Orders to Requests ******************************"))



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

#exit_script_no_log

end
go
