/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		03/30/2020
	Solution:			
	Source file name:	cov_wqm_act_rpt.prg
	Object name:		cov_wqm_act_rpt
	Request #:			11282, 12783

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Parameter Values:
 	
 						SCHED_TYPE:
							0 - Daily
							1 - Monthly
							2 - Yearly
							3 - Year To Date


******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	06/10/2020  Chad Cummings			Initial Release
001 	10/27/2021  Todd A. Blanchard		Added ability to export data to file.
002 	12/17/2021  Todd A. Blanchard		Added additional sched_type parameter values.
003 	04/26/2022  Todd A. Blanchard		Fixed bug with summary_qual person_id assignment.
											Adjusted dynamic sql for ccllink function.
004 	05/16/2022  Todd A. Blanchard		Added additional clinical event result statuses.
******************************************************************************/

drop program cov_wqm_act_rpt_dev_test:dba go
create program cov_wqm_act_rpt_dev_test:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Report Type" = 1
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Position" = 0
	, "Personnel" = 0
	;<<hidden>>"Search" = ""
	;<<hidden>>"Delete" = ""
	, "Sched Type" = 0
	, "Output To File" = 0                   ;* Output to file 

with OUTDEV, REPORT_TYPE, START_DATETIME, END_DATETIME, POSITION, NEW_PROVIDER, 
	SCHED_TYPE, OUTPUT_FILE


call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare file_var			= vc with noconstant("") ;001 
declare temppath_var		= vc with noconstant("") ;001
declare temppath2_var		= vc with noconstant("") ;001 
declare filepath_var		= vc with noconstant("") ;001 
declare output_var			= vc with noconstant("") ;001
 
declare cmd					= vc with noconstant("") ;001
declare len					= i4 with noconstant(0) ;001
declare stat				= i4 with noconstant(0) ;001
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/

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
	1 new_provider_id		= f8
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
	  3 cdi_trans_log_id	= f8
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
	1 document_cnt			= i4 
	1 document_qual[*]
	 2 prsnl_id				= f8
	 2 prsnl_name			= vc
	 2 prsnl_username		= vc
	 2 prsnl_position		= vc
	 2 prsnl_position_cd	= f8
	 2 action_dt_tm			= dq8
	 2 encntr_id			= f8
	 2 person_id			= f8
	 2 patient_name			= vc
	 2 loc_facility_cd		= f8
	 2 fin					= vc
	 2 event_id				= f8
	 2 event_cd				= f8
	 2 event_end_dt_tm		= dq8
     2 result_status_cd		= f8 ;004
	 2 subject				= vc
	 2 document_type		= vc
	 2 batch_name_key		= vc
	 2 create_dt_tm			= dq8 ;001
	 2 page_cnt				= i4
	 2 cdi_trans_log_id	    = f8
	 2 blob_handle			= vc
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

if (validate(request->batch_selection) = 1 or $OUTPUT_FILE = 1) ;001
	if ($SCHED_TYPE = 0)
		; daily
		call writeLog(build2("-->Setting default date range to previous day for export"))
		set t_rec->search.beg_dt_tm = datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'B', 'B')
		set t_rec->search.end_dt_tm = datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'E', 'E')
		
		set file_var = "wqm_daily.csv"
		
	elseif ($SCHED_TYPE = 1)
		; monthly
		call writeLog(build2("-->Setting default date range to previous month for export"))
		set t_rec->search.beg_dt_tm = datetimefind(cnvtlookbehind("1,M",cnvtdatetime(curdate,curtime3)), 'M', 'B', 'B')
		set t_rec->search.end_dt_tm = datetimefind(cnvtlookbehind("1,M",cnvtdatetime(curdate,curtime3)), 'M', 'E', 'E')
		
		set file_var = "wqm_monthly.csv"
		
	elseif ($SCHED_TYPE = 2)
		; yearly
		call writeLog(build2("-->Setting default date range to previous month for export"))
		set t_rec->search.beg_dt_tm = datetimefind(cnvtlookbehind("1,Y",cnvtdatetime(curdate,curtime3)), 'D', 'B', 'B')
		set t_rec->search.end_dt_tm = datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'E', 'E')
		
		set file_var = "wqm_yearly.csv"
		
	elseif ($SCHED_TYPE = 3)
		; year to date
		call writeLog(build2("-->Setting default date range to previous month for export"))
		set t_rec->search.beg_dt_tm = datetimefind(cnvtdatetime(curdate,curtime3), 'Y', 'B', 'B')
		set t_rec->search.end_dt_tm = datetimefind(cnvtdatetime(curdate,curtime3), 'D', 'E', 'E')
		
		set file_var = "wqm_ytd.csv"
	endif
 
	set temppath_var		= build("cer_temp:", file_var)
	set temppath2_var		= build("$cer_temp/", file_var)
	 
	set filepath_var		= build("/cerner/w_custom/", cnvtlower(curdomain),
									"_cust/to_client_site/RevenueCycle/HIM/", file_var) ;001
else
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
endif

 
; define output value ;001
if (validate(request->batch_selection) = 1 or $OUTPUT_FILE = 1)
	set output_var = value(temppath_var)
else
	set output_var = value($OUTDEV)
endif


set t_rec->report_type = $REPORT_TYPE
;set t_rec->new_provider_id = $NEW_PROVIDER

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

call writeLog(build2("** Adding prsnl by position "))
select into "nl:"
from prsnl p 
plan p
	where p.position_cd = $POSITION
	and p.position_cd > 0.0
	and p.active_ind = 1
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
	set t_rec->search.prsnl_string = ^expand(i,1,t_rec->search.prsnl_cnt,ctl1.perf_prsnl_id,t_rec->search.prsnl_qual[i].person_id)^
else
	set t_rec->search.prsnl_string = ^1=1^
endif

;call addEmailLog("chad.cummings@covhlth.com")

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Documents **********************************"))

select distinct into "nl:"
	 prsnl=pr.name_full_formatted
	,pr.username
	,position=uar_get_code_display(pr.position_cd)
	,action_date=format(ctl1.action_dt_tm,";;q")
	,facility=uar_get_code_display(e.loc_facility_cd)
	,fin=ea.alias
	,patient=p.name_full_formatted
	,document_type=uar_get_code_display(ce.event_cd)
	,document_subject=ce.event_tag
	,document_date=format(ce.event_end_dt_tm,";;q")
	,document_id=ce.event_id
	,ctl1.page_cnt
	,ctl1.batch_name_key
from 
	 cdi_trans_log ctl1
	,cdi_trans_log ctl2
	,clinical_event ce 
	,ce_blob_result cen
	,encntr_alias ea
	,encounter e
	,person p
	,prsnl pr
plan ctl1 
	where ctl1.action_type_flag = 0
	and   ctl1.cdi_queue_cd = value(uar_get_code_by("MEANING",257571,"HNAM"))
	and   ctl1.action_dt_tm between cnvtdatetime(t_rec->search.beg_dt_tm) and cnvtdatetime(t_rec->search.end_dt_tm)
	and   not expand(i,1,t_rec->search.prsnl_ignore_cnt,ctl1.perf_prsnl_id,t_rec->search.prsnl_ignore_qual[i].person_id)
	and   parser(t_rec->search.prsnl_string)
join ctl2
	where ctl2.batch_name_key = ctl1.batch_name_key
	and   ctl2.cdi_queue_cd = value(uar_get_code_by("MEANING",257571,"WORKQUEUE"))
join ce
	where ce.event_id = ctl1.event_id
	and   ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	and	  ce.result_status_cd in(
			  value(uar_get_code_by("MEANING",8,"AUTH"))
			 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
			 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
			 ;004
			 ,value(uar_get_code_by("MEANING",8,"IN ERROR"))
			 ,value(uar_get_code_by("MEANING",8,"INERRNOMUT"))
			 ,value(uar_get_code_by("MEANING",8,"INERRNOVIEW"))
			 ,value(uar_get_code_by("MEANING",8,"INERROR"))
			 ,value(uar_get_code_by("MEANING",8,"TRANSCRIBED"))
			 ,value(uar_get_code_by("MEANING",8,"UNAUTH"))
			)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	
join p
	where p.person_id = ce.person_id
join e
	where e.encntr_id = ce.encntr_id
join ea
	where ea.encntr_id = e.encntr_id
	and   ea.active_ind = 1
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
join cen
	where cen.event_id = ce.event_id
join pr
	where pr.person_id = ctl1.perf_prsnl_id
order by
	ce.event_id
head report
	call writeLog(build2("->inside document discovery query"))
head ce.event_id
	t_rec->document_cnt = (t_rec->document_cnt + 1)
	if ((mod(t_rec->document_cnt,10000) = 1) or (t_rec->document_cnt = 1))
		stat = alterlist(t_rec->document_qual,(t_rec->document_cnt + 9999))
	endif
	t_rec->document_qual[t_rec->document_cnt].action_dt_tm			= ctl1.action_dt_tm
	t_rec->document_qual[t_rec->document_cnt].batch_name_key		= ctl1.batch_name_key
	t_rec->document_qual[t_rec->document_cnt].create_dt_tm			= ctl1.create_dt_tm ;001
	t_rec->document_qual[t_rec->document_cnt].document_type			= uar_get_code_display(ce.event_cd)
	t_rec->document_qual[t_rec->document_cnt].encntr_id				= e.encntr_id
	t_rec->document_qual[t_rec->document_cnt].event_cd				= ce.event_cd
	t_rec->document_qual[t_rec->document_cnt].event_end_dt_tm		= ce.event_end_dt_tm
	t_rec->document_qual[t_rec->document_cnt].event_id				= ce.event_id
	t_rec->document_qual[t_rec->document_cnt].result_status_cd		= ce.result_status_cd ;004
	t_rec->document_qual[t_rec->document_cnt].fin					= cnvtalias(ea.alias,ea.alias_pool_cd)
	t_rec->document_qual[t_rec->document_cnt].loc_facility_cd		= e.loc_facility_cd
	t_rec->document_qual[t_rec->document_cnt].page_cnt				= ctl1.page_cnt
;	t_rec->document_qual[t_rec->document_cnt].page_cnt				= ctl2.page_cnt
	t_rec->document_qual[t_rec->document_cnt].cdi_trans_log_id		= ctl1.cdi_trans_log_id
	t_rec->document_qual[t_rec->document_cnt].blob_handle			= ctl1.blob_handle
	t_rec->document_qual[t_rec->document_cnt].person_id				= p.person_id
	t_rec->document_qual[t_rec->document_cnt].patient_name			= p.name_full_formatted
	t_rec->document_qual[t_rec->document_cnt].prsnl_id				= pr.person_id
	t_rec->document_qual[t_rec->document_cnt].prsnl_name			= pr.name_full_formatted
	t_rec->document_qual[t_rec->document_cnt].prsnl_position		= uar_get_code_display(pr.position_cd)
	t_rec->document_qual[t_rec->document_cnt].prsnl_position_cd 	= pr.position_cd
	t_rec->document_qual[t_rec->document_cnt].prsnl_username		= pr.username
	t_rec->document_qual[t_rec->document_cnt].subject				= replace(replace(ctl1.subject, char(13), ""), char(10), "") ;001
foot report
	stat = alterlist(t_rec->document_qual,t_rec->document_cnt)
	call writeLog(build2("->leaving document discovery query"))
with nocounter


select into "nl:"
from
	 cdi_trans_log ctl1
	,(dummyt d1 with seq=t_rec->document_cnt)
plan d1
join ctl1
	where ctl1.blob_handle = t_rec->document_qual[d1.seq].blob_handle
	and   ctl1.event_id    = t_rec->document_qual[d1.seq].event_id
order by
	 ctl1.event_id
	,ctl1.action_dt_tm desc
head report
	call writeLog(build2("<-leaving document page count query"))
head ctl1.event_id
	if (ctl1.page_cnt < t_rec->document_qual[d1.seq].page_cnt)
		t_rec->document_qual[d1.seq].page_cnt = ctl1.page_cnt
	endif
foot report
	call writeLog(build2("->leaving document page count query"))
with nocounter
	


call writeLog(build2("* END   Finding Documents **********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Building Summary ***********************************"))
select distinct
	into $OUTDEV
	 prsnl					= substring(1,100,t_rec->document_qual[d1.seq].prsnl_name)
	,username				= substring(1,20,t_rec->document_qual[d1.seq].prsnl_username)
	,position				= substring(1,50,t_rec->document_qual[d1.seq].prsnl_position)
	,action_date			= substring(1,30,format(t_rec->document_qual[d1.seq].action_dt_tm,";;q"))
	,facility				= substring(1,20,uar_get_code_display(t_rec->document_qual[d1.seq].loc_facility_cd))
	,fin					= substring(1,20,t_rec->document_qual[d1.seq].fin)
	,patient				= substring(1,100,t_rec->document_qual[d1.seq].patient_name)
	,document_type			= substring(1,100,t_rec->document_qual[d1.seq].document_type)
	,document_subject		= substring(1,100,t_rec->document_qual[d1.seq].subject)
	,document_date			= substring(1,30,format(t_rec->document_qual[d1.seq].event_end_dt_tm,";;q"))
	,document_id			= t_rec->document_qual[d1.seq].event_id
	,page_cnt				= t_rec->document_qual[d1.seq].page_cnt
	,result_status			= substring(1,40,uar_get_code_display(t_rec->document_qual[d1.seq].result_status_cd)) ;004
	,batch_name_key			= substring(1,100,t_rec->document_qual[d1.seq].batch_name_key)
	,batch_date				= substring(1,30,format(t_rec->document_qual[d1.seq].create_dt_tm,"mm/dd/yyyy hh:mm:ss;;q")) ;004
	,cdi_trans_log_id		= t_rec->document_qual[d1.seq].cdi_trans_log_id
from 
	 (dummyt d1 with seq=t_rec->document_cnt)
plan d1
order by
	 prsnl
	,batch_name_key
	,action_date
	,facility
	,fin
	,patient
	,document_type
	,document_subject
	,document_date
	,document_id
	
head report
	call writeLog(build2("->leaving document discovery query"))
head prsnl	
	t_rec->summary_cnt = (t_rec->summary_cnt + 1)
	stat = alterlist(t_rec->summary_qual,t_rec->summary_cnt)
	t_rec->summary_qual[t_rec->summary_cnt].person_id = t_rec->document_qual[d1.seq].prsnl_id ;003
	t_rec->summary_qual[t_rec->summary_cnt].name_full_formatted = t_rec->document_qual[d1.seq].prsnl_name
	t_rec->summary_qual[t_rec->summary_cnt].position_cd = t_rec->document_qual[d1.seq].prsnl_position_cd
	t_rec->summary_qual[t_rec->summary_cnt].position = trim(t_rec->document_qual[d1.seq].prsnl_position)
head batch_name_key
	t_rec->summary_qual[t_rec->summary_cnt].batch_count = (t_rec->summary_qual[t_rec->summary_cnt].batch_count + 1)
head document_id
	t_rec->summary_qual[t_rec->summary_cnt].doc_cnt = (t_rec->summary_qual[t_rec->summary_cnt].doc_cnt + 1)
foot report
	call writeLog(build2("<--Leaving Summary Query"))	
with nocounter

set t_rec->user_table = ^<table border = 1>^
set t_rec->user_table = concat(t_rec->user_table
							,^<tr>^
							,^<th>Name</th>^
							,^<th>Position</th>^
							,^<th>Batch Count</th>^
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
	disp_line = concat(disp_line,',value(0)') ;003
	disp_line = concat(disp_line,',',trim(cnvtstring(t_rec->summary_qual[d1.seq].person_id)))
	disp_line = concat(disp_line,',1')
	disp_line = concat(disp_line,',0') ;003
	disp_line = concat(disp_line,'"')
	disp_line = concat(disp_line,',1') ;003
	t_rec->user_table = concat(t_rec->user_table
		,^<tr>^
		,^<td>^
		,^<a href='javascript:CCLLINK(^,disp_line,^)'>^
		,trim(t_rec->summary_qual[d1.seq].name_full_formatted)
		,^</a>^
		,^</td>^
		,^<td>^,trim(t_rec->summary_qual[d1.seq].position),^</td>^
		,^<td>^,trim(cnvtstring(t_rec->summary_qual[d1.seq].batch_count)),^</td>^
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

if (t_rec->document_cnt = 0)
	set reply->status_data.status = "Z"
else
	set reply->status_data.status = "S"
endif

#exit_script

if (reply->status_data.status in("F","Z"))
	set program_log->display_on_exit = 1
else
	if (t_rec->report_type = 0)
		;001
		if (validate(request->batch_selection) = 1 or $OUTPUT_FILE = 1)
			set modify filestream
		endif
		
		;001
		select if (validate(request->batch_selection) = 1 or $OUTPUT_FILE = 1)
			with nocounter, pcformat (^"^, ^,^, 1), format = stream, format
		else
			with nocounter, uar_code(d), format(date,";;q"), separator = " ", format
		endif
	 
		distinct into value(output_var) ;001
			 prsnl					= substring(1,100,t_rec->document_qual[d1.seq].prsnl_name)
			,username				= substring(1,20,t_rec->document_qual[d1.seq].prsnl_username)
			,position				= substring(1,50,t_rec->document_qual[d1.seq].prsnl_position)
			,action_date			= substring(1,30,format(t_rec->document_qual[d1.seq].action_dt_tm,"mm/dd/yyyy hh:mm:ss;;q")) ;001
			,facility				= substring(1,20,uar_get_code_display(t_rec->document_qual[d1.seq].loc_facility_cd))
			,fin					= substring(1,20,t_rec->document_qual[d1.seq].fin)
			,patient				= substring(1,100,t_rec->document_qual[d1.seq].patient_name)
			,document_type			= substring(1,100,t_rec->document_qual[d1.seq].document_type)
			,document_subject		= substring(1,100,t_rec->document_qual[d1.seq].subject)
			,document_date			= substring(1,30,format(t_rec->document_qual[d1.seq].event_end_dt_tm,"mm/dd/yyyy hh:mm:ss;;q")) ;001
			,document_id			= t_rec->document_qual[d1.seq].event_id
			,page_cnt				= t_rec->document_qual[d1.seq].page_cnt
			,result_status			= substring(1,40,uar_get_code_display(t_rec->document_qual[d1.seq].result_status_cd)) ;004
			,batch_name_key			= substring(1,100,t_rec->document_qual[d1.seq].batch_name_key)
			,batch_date				= substring(1,30,format(t_rec->document_qual[d1.seq].create_dt_tm,"mm/dd/yyyy hh:mm:ss;;q")) ;001
			,cdi_trans_log_id		= t_rec->document_qual[d1.seq].cdi_trans_log_id
		from 
			 (dummyt d1 with seq=t_rec->document_cnt)
		plan d1
		order by
			 prsnl
			,action_date
			,facility
			,fin
			,patient
			,document_type
			,document_subject
			,document_date
			,document_id
			,batch_name_key
 
		; copy file to AStream ;001
		if (validate(request->batch_selection) = 1 or $OUTPUT_FILE = 1)
			set cmd = build2("cp ", temppath2_var, " ", filepath_var)
			set len = size(trim(cmd))
		 
			call dcl(cmd, len, stat)
			call echo(build2(cmd, " : ", stat))
		endif

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
