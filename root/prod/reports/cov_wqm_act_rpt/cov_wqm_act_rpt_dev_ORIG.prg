/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		03/30/2020
	Solution:			
	Source file name:	cov_wqm_act_rpt.prg
	Object name:		cov_wqm_act_rpt
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	06/10/2020  Chad Cummings			Initial Release
******************************************************************************/

drop program cov_wqm_act_rpt_dev:dba go
create program cov_wqm_act_rpt_dev:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Report Type" = 1
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Personnel " = 0
	;<<hidden>>"Search" = ""
	;<<hidden>>"Delete" = "" 

with OUTDEV, REPORT_TYPE, START_DATETIME, END_DATETIME, NEW_PROVIDER


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

call set_codevalues(null)
call check_ops(null)

free set t_rec
record t_rec
(
	1 cnt					= i4
	1 report_type			= i2
	1 search
	 2 beg_dt_tm			= dq8
	 2 end_dt_tm			= dq8
	 2 cdi_queue_cd 		= f8
	 2 prsnl_cnt			= i2
	 2 prsnl_qual[*]
	  3 person_id			= f8
	 2 prsnl_string			= vc
	 2 prsnl_ignore_cnt		= i2
	 2 prsnl_ignore_qual[*]
	  3 username			= vc
	  3 person_id			= f8
	1 batch_cnt				= i2
	1 batch_qual[*]
	 2 batch_name_key		= vc
	 2 blob_handle			= vc
	 2 external_batch_ident	= i4
	 2 perf_prsnl_id		= f8
	 2 name_full_formatted	= vc
	 2 ignore_ind			= i2
	 2 create_dt_tm			= dq8
	 2 first_dt_tm			= dq8
	 2 final_dt_tm			= dq8
	 2 inital_pages			= i2
	 2 final_pages			= i2
	 2 doc_cnt				= i2
	 2 doc_qual[*]
	  3 ax_docid			= i4
	  3 blob_handle			= vc
	  3 encntr_id			= f8
	  3 event_cd			= f8
	  3 event_id			= f8
	 2 encntr_cnt			= i2
	 2 encntr_qual[*]	
	  3 encntr_id			= f8
	  3 action_dt_tm		= dq8
	  3 page_cnt			= i2
	1 summary_cnt			= i2
	1 summary_qual[*]
	 2 person_id			= f8
	 2 username				= vc
	 2 name_full_formatted	= vc
	 2 position_cd			= f8
	 2 position				= vc
	 2 batch_count			= i2
	 2 doc_cnt				= i2
	 2 total_time			= i4
	1 user_table			= vc 
)

free record temp_batch_lyt
record temp_batch_lyt (
   1 batch_details [* ]
     2 module_name = vc
     2 ascent_user = vc
     2 ac_start_dt_tm = dq8
     2 ac_end_dt_tm = dq8
     2 blob_handle = vc
     2 cdi_queue_cd = f8
     2 action_type = vc
     2 reason_cd = f8
     2 perf_prsnl_id = f8
     2 action_dt_tm = dq8
     2 batch_name = vc
     2 patient_name = vc
     2 encntr_id = f8
     2 person_id = f8
     2 ax_appid = i4
     2 ax_docid = i4
     2 blob_type = vc
     2 blob_ref_id = f8
     2 page_cnt = i4
     2 external_batch_ident = i4
     2 perf_prsnl_name = vc
     2 create_dt_tm = dq8
     2 change_description [* ]
       3 change = vc
       3 action_sequence = i4
     2 parent_entity_alias = vc
     2 ac_ind = i2
     2 doc_type = vc
     2 version = vc
     2 result_status_cd = f8
     2 trans_log_id = f8
     2 doc_type_alias = vc
     2 subject = vc
     2 parent_aliases [* ]
       3 name_1 = vc
       3 value_1 = vc
       3 codeval_1 = f8
       3 name_2 = vc
       3 value_2 = vc
       3 codeval_2 = f8
     2 version_nbr = f8
     2 event_id = f8
)

set reply->status_data.status = "F"

if (validate(request->params))
	call writeLog(build2("* Incoming Parameters=",trim(request->params)))
endif

if (($START_DATETIME = "SYSDATE") or ($END_DATETIME = "SYSDATE"))
	call writeLog(build2("-->Setting default date range to previous month"))
	set t_rec->search.beg_dt_tm = datetimefind(cnvtlookbehind("1,M",cnvtdatetime(curdate,curtime3)), 'M', 'B', 'B')
	set t_rec->search.end_dt_tm = datetimefind(cnvtlookbehind("1,M",cnvtdatetime(curdate,curtime3)), 'M', 'E', 'E')
else
	call writeLog(build2("-->Setting date range to user defined. START_DATETIME="
		,trim($START_DATETIME),";END_DATETIME=",trim($END_DATETIME)))
	set t_rec->search.beg_dt_tm = cnvtdatetime($START_DATETIME)
	set t_rec->search.end_dt_tm = cnvtdatetime($END_DATETIME)
endif

set t_rec->report_type = $REPORT_TYPE

set t_rec->search.cdi_queue_cd = uar_get_code_by("MEANING",257571,"WORKQUEUE")


call writeLog(build2("** Adding Personnel Accounts to Ignore "))
select into "nl:"
from 
	prsnl p
plan p
	where p.username in(
							"CPDISERVICE"
						)
	and   p.person_id > 0.0
order by
	p.person_id
head report
	call writeLog(build2("-->Inside Personnel Ignore Query"))	
head p.person_id
	call writeLog(build2("--->found:",trim(p.name_full_formatted)," (",trim(cnvtstring(p.person_id)),")"))	
	t_rec->search.prsnl_ignore_cnt = (t_rec->search.prsnl_ignore_cnt + 1)
	stat = alterlist(t_rec->search.prsnl_ignore_qual,t_rec->search.prsnl_ignore_cnt)
	t_rec->search.prsnl_ignore_qual[t_rec->search.prsnl_ignore_cnt].person_id = p.person_id
	t_rec->search.prsnl_ignore_qual[t_rec->search.prsnl_ignore_cnt].username = p.username
foot p.person_id
	call writeLog(build2("<---leave:",trim(p.name_full_formatted)," (",trim(cnvtstring(p.person_id)),")"))
foot report
	call writeLog(build2("<--Leaving Personnel Ignore Query"))	
with nocounter


call writeLog(build2("** Adding PRSNL "))
select into "nl:"
from 
	prsnl p
plan p
	where p.person_id = $NEW_PROVIDER
	and   p.person_id > 0.0
order by
	p.person_id
head report
	call writeLog(build2("-->Inside Personnel Query"))	
head p.person_id
	call writeLog(build2("--->found:",trim(p.name_full_formatted)," (",trim(cnvtstring(p.person_id)),")"))	
	t_rec->search.prsnl_cnt = (t_rec->search.prsnl_cnt + 1)
	stat = alterlist(t_rec->search.prsnl_qual,t_rec->search.prsnl_cnt)
	t_rec->search.prsnl_qual[t_rec->search.prsnl_cnt].person_id = p.person_id
foot p.person_id
	call writeLog(build2("<---leave:",trim(p.name_full_formatted)," (",trim(cnvtstring(p.person_id)),")"))
foot report
	call writeLog(build2("<--Leaving Personnel Query"))	
with nocounter

if (t_rec->search.prsnl_cnt > 0)
	set t_rec->search.prsnl_string = ^expand(i,1,t_rec->search.prsnl_cnt,ctl.perf_prsnl_id,t_rec->search.prsnl_qual[i].person_id)^
else
	set t_rec->search.prsnl_string = ^1=1^
endif

call addEmailLog("chad.cummings@covhlth.com")

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Batches ************************************"))
select into "nl:"
from
	 cdi_trans_log ctl
	,prsnl p
plan ctl
	where 	ctl.action_dt_tm between cnvtdatetime(t_rec->search.beg_dt_tm) and cnvtdatetime(t_rec->search.end_dt_tm)
	and   	ctl.cdi_queue_cd = t_rec->search.cdi_queue_cd
	and     ctl.action_type_flag not in(10)
	and     not expand(i,1,t_rec->search.prsnl_ignore_cnt,ctl.perf_prsnl_id,t_rec->search.prsnl_ignore_qual[i].person_id)
	and 	parser(t_rec->search.prsnl_string)
join p
	where p.person_id = ctl.perf_prsnl_id
order by
	 ctl.perf_prsnl_id
	,ctl.batch_name_key
	,ctl.action_dt_tm
head report
	call writeLog(build2("-->Inside Batch Query"))	
	batch_cnt = 0
head ctl.perf_prsnl_id
	call writeLog(build2("--->found:",trim(p.name_full_formatted)," (",trim(cnvtstring(ctl.perf_prsnl_id)),")"))	
	batch_cnt = 0
head ctl.batch_name_key
	call writeLog(build2("---->adding batch:",trim(ctl.batch_name_key)," (",trim(cnvtstring(ctl.cdi_trans_log_id)),") ",
		trim(format(ctl.action_dt_tm,";;q"))))
	t_rec->batch_cnt = (t_rec->batch_cnt + 1)
	stat = alterlist(t_rec->batch_qual,t_rec->batch_cnt)
	t_rec->batch_qual[t_rec->batch_cnt].batch_name_key 			= ctl.batch_name_key
	t_rec->batch_qual[t_rec->batch_cnt].perf_prsnl_id 			= ctl.perf_prsnl_id
	t_rec->batch_qual[t_rec->batch_cnt].blob_handle     		= ctl.blob_handle
	t_rec->batch_qual[t_rec->batch_cnt].external_batch_ident    = ctl.external_batch_ident
foot ctl.batch_name_key
	batch_cnt = (batch_cnt + 1)
	call writeLog(build2("<----adding batch:",trim(ctl.batch_name_key)," (",trim(cnvtstring(ctl.cdi_trans_log_id)),")"))	
foot ctl.perf_prsnl_id
	call writeLog(build2("----batch count:",trim(cnvtstring(batch_cnt))))
	call writeLog(build2("<---leave:",trim(p.name_full_formatted)," (",trim(cnvtstring(ctl.perf_prsnl_id)),")"))	
foot report
	call writeLog(build2("<--Leaving Batch Query"))	
with nocounter
call writeLog(build2("* END   Finding Batches ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Missing Batches ****************************"))
select into "nl:"
	ctl.blob_handle
from
	(dummyt d1 with seq=t_rec->batch_cnt)
	,cdi_trans_log ctl
plan d1
	where t_rec->batch_qual[d1.seq].batch_name_key = " "
	and   t_rec->batch_qual[d1.seq].blob_handle > " "
join ctl
	where ctl.blob_handle = t_rec->batch_qual[d1.seq].blob_handle
order by
	ctl.blob_handle
head report
	call writeLog(build2("-->Inside Missing Batch Query"))
head ctl.blob_handle
	call writeLog(build2("---->inside blob_handle:",trim(ctl.blob_handle)," (",trim(cnvtstring(ctl.cdi_trans_log_id)),") ",
		trim(format(ctl.action_dt_tm,";;q"))))
detail
	if (ctl.batch_name > " ")
		call writeLog(build2("----->setting batch_name_key:",trim(ctl.batch_name_key)))
		t_rec->batch_qual[d1.seq].batch_name_key = ctl.batch_name_key
	endif
foot ctl.blob_handle
	call writeLog(build2("---->leaving blob_handle:",trim(ctl.blob_handle)))
foot report
	call writeLog(build2("<--Leaving Missing Batch Query"))
with nocounter
call writeLog(build2("* END   Finding Missing Batches ****************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Batch Details ******************************"))
for (i=1 to t_rec->batch_cnt)
 if (t_rec->batch_qual[i].ignore_ind = 0)
	
	select into "nl:"
	from
		cdi_trans_log ctl
	plan ctl
		where ctl.batch_name_key = t_rec->batch_qual[i].batch_name_key
		and   ctl.action_type_flag in(0,6,9)
		and   ctl.batch_name > " "
	order by
		 ctl.action_dt_tm
		,ctl.ax_docid
		,ctl.cdi_trans_log_id
	head report
		call writeLog(build2("-->Inside Batch Query ",trim(ctl.batch_name_key)))	
		t_rec->batch_qual[i].create_dt_tm = ctl.create_dt_tm
		t_rec->batch_qual[i].first_dt_tm = ctl.create_dt_tm
		t_rec->batch_qual[i].inital_pages = ctl.page_cnt
		action_cnt = 0
		pos = 0
		first_ind = 0
	head ctl.ax_docid
		call writeLog(build2("---->ax_docid=",trim(cnvtstring(ctl.ax_docid))))
		t_rec->batch_qual[i].doc_cnt = (t_rec->batch_qual[i].doc_cnt + 1)
		stat = alterlist(t_rec->batch_qual[i].doc_qual,t_rec->batch_qual[i].doc_cnt)
		t_rec->batch_qual[i].doc_qual[t_rec->batch_qual[i].doc_cnt].ax_docid = ctl.ax_docid
		t_rec->batch_qual[i].doc_qual[t_rec->batch_qual[i].doc_cnt].blob_handle = ctl.blob_handle
	head ctl.cdi_trans_log_id
		action_cnt = (action_cnt + 1)
		call writeLog(build2("----->action_dt_tm=",format(ctl.action_dt_tm,";;q")," (type=",trim(cnvtstring(ctl.action_type_flag)),")"))
		pos = 0
		pos = locateval(j,1,t_rec->search.prsnl_ignore_cnt,ctl.perf_prsnl_id,t_rec->search.prsnl_ignore_qual[j].person_id)
		call writeLog(build2("----->ctl.perf_prsnl_id=",trim(cnvtstring(ctl.perf_prsnl_id))
			," (pos=",trim(cnvtstring(pos)),")"))
		if ((pos = 0) and (t_rec->batch_qual[i].first_dt_tm < cnvtdatetime(ctl.action_dt_tm)) and (first_ind = 0))
			t_rec->batch_qual[i].first_dt_tm = ctl.action_dt_tm
			first_ind = 1
			call writeLog(build2("------>first_dt_tm=",format(t_rec->batch_qual[i].first_dt_tm,";;q")
				," (type=",trim(cnvtstring(ctl.action_type_flag)),")"))
		endif
	foot ctl.ax_docid
		call writeLog(build2("<----ax_docid=",trim(cnvtstring(ctl.ax_docid))))
	foot report
		t_rec->batch_qual[i].final_dt_tm = ctl.action_dt_tm
		call writeLog(build2("<--Leaving Batch Query ",trim(ctl.batch_name_key)))
	with nocounter
	
	;set stat = initrec(temp_batch_lyt)
	;execute cdi_rpt_doc_hist_drvr t_rec->batch_qual[i].blob_handle with replace("BATCH_LYT",temp_batch_lyt)
	;call echorecord(temp_batch_lyt)
 endif
endfor
call writeLog(build2("* END   Finding Batch Details ******************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Building Summary ***********************************"))

select into "nl:"
	  p.person_id
	 ,batch_key = t_rec->batch_qual[d1.seq].batch_name_key
	 ,doc_id	= t_rec->batch_qual[d1.seq].doc_qual[d2.seq].ax_docid
from 
	 (dummyt d1 with seq=t_rec->batch_cnt)
	,(dummyt d2)
	,prsnl p
plan d1
	where 	maxrec(d2,t_rec->batch_qual[d1.seq].doc_cnt)
	and		t_rec->batch_qual[d1.seq].ignore_ind = 0
join d2
join p
	where p.person_id = t_rec->batch_qual[d1.seq].perf_prsnl_id
order by
	 p.person_id
	,batch_key
	,doc_id
head report
	call writeLog(build2("-->Inside Summary Query"))	
	batch_cnt = 0
	batch_min = 0.0
	doc_cnt = 0
head p.person_id
	call writeLog(build2("--->found:",trim(p.name_full_formatted)," (",trim(cnvtstring(p.person_id)),")"))	
	batch_cnt = 0
	batch_min = 0.0
	doc_cnt = 0
head batch_key
	call writeLog(build2("---->adding batch:",trim(batch_key)))
	batch_cnt = (batch_cnt + 1)
head doc_id
	call writeLog(build2("----->adding doc:",trim(cnvtstring(doc_id))))
	doc_cnt = (doc_cnt + 1)
detail
	t_rec->batch_qual[d1.seq].name_full_formatted = p.name_full_formatted
foot doc_id
	call writeLog(build2("<-----leaving doc:",trim(cnvtstring(doc_id))))
foot batch_key
	call writeLog(build2("<----leaving batch:",trim(batch_key)))
	batch_min = (batch_min + (datetimediff(t_rec->batch_qual[d1.seq].final_dt_tm,t_rec->batch_qual[d1.seq].first_dt_tm,4)))
foot p.person_id
	call writeLog(build2("----batch count:",trim(cnvtstring(batch_cnt))))
	call writeLog(build2("<---leave:",trim(p.name_full_formatted)," (",trim(cnvtstring(p.person_id)),")"))	
	t_rec->summary_cnt = (t_rec->summary_cnt + 1)
	stat = alterlist(t_rec->summary_qual,t_rec->summary_cnt)
	t_rec->summary_qual[t_rec->summary_cnt].person_id = p.person_id
	t_rec->summary_qual[t_rec->summary_cnt].name_full_formatted = p.name_full_formatted
	t_rec->summary_qual[t_rec->summary_cnt].position_cd = p.position_cd
	t_rec->summary_qual[t_rec->summary_cnt].position = trim(uar_get_code_display(p.position_cd))
	t_rec->summary_qual[t_rec->summary_cnt].batch_count = batch_cnt
	t_rec->summary_qual[t_rec->summary_cnt].total_time = batch_min
	t_rec->summary_qual[t_rec->summary_cnt].doc_cnt = doc_cnt
foot report
	call writeLog(build2("<--Leaving Summary Query"))	
with nocounter,outerjoin=d2

set t_rec->user_table = ^<table border = 1>^
set t_rec->user_table = concat(t_rec->user_table
													,^<tr>^
													,^<th>Name</th>^
													,^<th>Position</th>^
													,^<th>Batch Count</th>^
													,^<th>Batch Minutes</th>^
													,^<th>Document Count</th>^
													,^</tr>^
								)
select into "nl:"
	name = substring(1,100,t_rec->summary_qual[d1.seq].name_full_formatted)
from 
	(dummyt d1 with seq=t_rec->summary_cnt)
plan d1
order by
	name
detail
	disp_line = ""
	disp_line = concat('"',trim(curprog),'"')
	disp_line = concat(disp_line,',"')
	disp_line = concat(disp_line,'^MINE^')
	disp_line = concat(disp_line,',0')
	disp_line = concat(disp_line,',^',format(t_rec->search.beg_dt_tm,";;q"),'^')
	disp_line = concat(disp_line,',^',format(t_rec->search.end_dt_tm,";;q"),'^')
	disp_line = concat(disp_line,',',trim(cnvtstring(t_rec->summary_qual[d1.seq].person_id)))
	disp_line = concat(disp_line,'"')
	disp_line = concat(disp_line,',1')
	t_rec->user_table = concat(t_rec->user_table
														,^<tr>^
														,^<td>^
														,^<a href='javascript:CCLLINK(^,disp_line,^)'>^
														,trim(t_rec->summary_qual[d1.seq].name_full_formatted)
														,^</a>^
														,^</td>^
														,^<td>^,trim(t_rec->summary_qual[d1.seq].position),^</td>^
														,^<td>^,trim(cnvtstring(t_rec->summary_qual[d1.seq].batch_count)),^</td>^
														,^<td>^,trim(cnvtstring(t_rec->summary_qual[d1.seq].total_time)),^</td>^
														,^<td>^,trim(cnvtstring(t_rec->summary_qual[d1.seq].doc_cnt)),^</td>^
														,^</tr>^
									)

with nocounter

set t_rec->user_table = concat(t_rec->user_table,^</table>^)

call writeLog(build2("* END   Building Summary ***********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

if (t_rec->batch_cnt = 0)
	set reply->status_data.status = "Z"
else
	set reply->status_data.status = "S"
endif

#exit_script

if (reply->status_data.status in("F","Z"))
	set program_log->display_on_exit = 1
else
	if (t_rec->report_type = 0)
		select into $OUTDEV
			 personnel			= trim(t_rec->batch_qual[d1.seq].name_full_formatted)
			,prsnl_id			= t_rec->batch_qual[d1.seq].perf_prsnl_id
			,batch_key			= t_rec->batch_qual[d1.seq].batch_name_key
			,batch_start_dt_tm	= format(t_rec->batch_qual[d1.seq].create_dt_tm,";;q")
			,batch_first_dt_tm	= format(t_rec->batch_qual[d1.seq].first_dt_tm,";;q")
			,batch_end_dt_tm	= format(t_rec->batch_qual[d1.seq].final_dt_tm,";;q")
			,create_to_final_min= datetimediff(t_rec->batch_qual[d1.seq].final_dt_tm,t_rec->batch_qual[d1.seq].create_dt_tm,4)
			,first_to_final_min	= datetimediff(t_rec->batch_qual[d1.seq].final_dt_tm,t_rec->batch_qual[d1.seq].first_dt_tm,4)
			,doc_count			= t_rec->batch_qual[d1.seq].doc_cnt
			,page_count			= t_rec->batch_qual[d1.seq].doc_cnt ;need page count
			,doc_id				= t_rec->batch_qual[d1.seq].doc_qual[d2.seq].ax_docid
		from
			(dummyt d1 with seq=t_rec->batch_cnt)
			,(dummyt d2)
		plan d1 where maxrec(d2,t_rec->batch_qual[d1.seq].doc_cnt)
		join d2
		order by
			personnel
		with nocounter, separator = " ", format
	else
		free record getReply 
		record getREPLY (
		  1 INFO_LINE[*]
		    2 new_line                = vc
		  1 data_blob                 = gvc
		  1 data_blob_size            = i4
%i cclsource:status_block.inc
		)
		
		free record getREQUEST 
		record getREQUEST (
		  1 Module_Dir = vc
		  1 Module_Name = vc
		  1 bAsBlob = i2
		)
		
		record putREQUEST (
		  1 source_dir = vc
		  1 source_filename = vc
		  1 nbrlines = i4
		  1 line [*]
		    2 lineData = vc
		  1 OverFlowPage [*]
		    2 ofr_qual [*]
		      3 ofr_line = vc
		  1 IsBlob = c1
		  1 document_size = i4
		  1 document = gvc
		)
		  
		; Read in the html file
		set getrequest->module_dir	= "ccluserdir:"
		set getrequest->Module_name = "wqm.html"
		set getrequest->bAsBlob 	= 1
		execute eks_get_source with replace (REQUEST,getREQUEST),replace(REPLY,getREPLY)
		
		set putRequest->source_dir = $OUTDEV
		set putRequest->IsBlob = "1"
		set putRequest->document = replace(getReply->data_blob,"__REPLACE_USER_TABLE__",t_rec->user_table)
		set putRequest->document_size = size(putRequest->document)
		 
		; This outputs the display
		execute eks_put_source with replace(Request,putRequest),replace(reply,putReply)
	endif
endif
call echojson(t_rec,program_log->files.filename_audit,1)
call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
