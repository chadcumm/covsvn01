/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		09/04/2020
	Solution:			
	Source file name:	cov_ina_inerror_temp.prg
	Object name:		cov_ina_inerror_temp
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	09/04/2020  Chad Cummings			Initial Release
******************************************************************************/

drop program cov_ina_inerror_temp:dba go
create program cov_ina_inerror_temp:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "FIN" = ""                             ;* Patient Encounter FIN
	;<<hidden>>"Patient Name" = 0
	, "Temperature Results" = 0 

with OUTDEV, FIN, RESULTS


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
) with private
endif

set reply->status_data.status = "F"

call set_codevalues(null)
call check_ops(null)

free set t_rec
record t_rec
(
	1 user_prompts
	 2 outdev				= vc
	 2 fin					= vc
	 2 result_cnt			= i2
	 2 result_qual[*]
	  3 event_id			= f8
	1 records_attachment	= vc
	1 cnt					= i4
	1 trigger				= vc
	1 audit_mode			= i2
	1 prsnl_id				= f8
	1 prsnl_name			= vc
	1 prsnl_username		= vc
	1 qual[*]
	 2 event_id				= f8
	 2 event_pass			= f8
	 2 event_cd				= f8
	 2 event_disp			= vc
	 2 event_end_dt_tm 		= dq8
	 2 result_val 			= vc
	 2 inerror_ind			= i2
	 2 success_ind  		= i2
	 2 name_full_formatted	= vc
	 2 fin					= vc
	 2 encntr_id			= f8
	 2 person_id			= f8
) with protect

free record EKSOPSRequest
record EKSOPSRequest (
   1 expert_trigger	= vc
   1 qual[*]
	2 person_id	= f8
	2 sex_cd	= f8
	2 birth_dt_tm	= dq8
	2 encntr_id	= f8
	2 accession_id	= f8
	2 order_id	= f8
	2 data[*]
	     3 vc_var		= vc
	     3 double_var	= f8
	     3 long_var		= i4
	     3 short_var	= i2
)

%i cclsource:eks_rprq3091001.inc


call addEmailLog("chad.cummings@covhlth.com")

set t_rec->user_prompts.fin = $FIN
set t_rec->user_prompts.outdev = $OUTDEV

set t_rec->trigger = "HIM_REMOVE_DOCUMENTS"
set t_rec->audit_mode = 0

set t_rec->records_attachment = concat(trim(cnvtlower(curprog)),"_",trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")

if (t_rec->user_prompts.fin = "")
	set program_log->display_on_exit = 1
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "ENCNTR_ALIAS"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "ENCNTR_ALIAS"
	set reply->status_data.subeventstatus.targetobjectvalue = "No Encounter FIN was Receieved"
	go to exit_script
endif

set t_rec->prsnl_id = reqinfo->updt_id
select into "nl:"
from
	prsnl p
plan p
	where p.person_id = t_rec->prsnl_id
detail
	t_rec->prsnl_name = p.name_full_formatted
	t_rec->prsnl_username = p.username
with nocounter

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Getting Events *************************************"))

select into "nl:"
	 ce.event_id 
	,type=trim(cv1.display)
	,result=trim(ce.result_val)
	,date_time=trim(format(ce.event_end_dt_tm,";;q"))
from
	encntr_alias ea
	,encounter e
	,person p
	,clinical_event ce
	,code_value cv1
plan ea
	where ea.alias = $FIN
	and   ea.active_ind = 1
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
join e
	where e.encntr_id = ea.encntr_id
join p
	where p.person_id = e.person_id
join ce
	where ce.encntr_id = e.encntr_id
	and   ce.event_id = $RESULTS
	and   ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val        >  " "
join cv1
	where cv1.code_value = ce.event_cd
	and   cv1.code_set = 72
	and   cv1.display = "Temperature*F"
order by
	ce.event_id
head ce.event_id
	t_rec->user_prompts.result_cnt = (t_rec->user_prompts.result_cnt + 1)
	stat = alterlist(t_rec->user_prompts.result_qual,t_rec->user_prompts.result_cnt)
	t_rec->user_prompts.result_qual[t_rec->user_prompts.result_cnt].event_id = ce.event_id
with nocounter
	

if (t_rec->user_prompts.result_cnt <= 0)
	set program_log->display_on_exit = 1
	set reply->status_data.status = "Z"
	set reply->status_data.subeventstatus.operationname = "CLINICAL_EVENTS"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "CLINICAL_EVENTS"
	set reply->status_data.subeventstatus.targetobjectvalue = "No Valide Events where Recieved"
	go to exit_script
endif

call writeLog(build2("* END   Getting Events *************************************"))
call writeLog(build2("************************************************************"))

select into "nl:"
	 ce.event_id 
	,type=trim(cv1.display)
	,result=trim(ce.result_val)
	,date_time=trim(format(ce.event_end_dt_tm,";;q"))
from
	encntr_alias ea
	,encounter e
	,person p
	,clinical_event ce
	,code_value cv1
plan ea
	where ea.alias = $FIN
	and   ea.active_ind = 1
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
join e
	where e.encntr_id = ea.encntr_id
join p
	where p.person_id = e.person_id
join ce
	where ce.encntr_id = e.encntr_id
	and   expand(i,1,t_rec->user_prompts.result_cnt,ce.event_id,t_rec->user_prompts.result_qual[i].event_id)
	and   ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
								)
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.result_val        >  " "
join cv1
	where cv1.code_value = ce.event_cd
	and   cv1.code_set = 72
	and   cv1.display = "Temperature*F"
order by
	ce.event_id
head report
	call writeLog(build2("->inside event query"))
head ce.event_id
	call writeLog(build2("-->ce.event_id=",trim(cnvtstring(ce.event_id))))
	t_rec->cnt = (t_rec->cnt + 1)
	stat = alterlist(t_rec->qual,t_rec->cnt)
	t_rec->qual[t_rec->cnt].encntr_id					= e.encntr_id
	t_rec->qual[t_rec->cnt].event_pass					= ce.event_id
	t_rec->qual[t_rec->cnt].event_cd					= ce.event_cd
	t_rec->qual[t_rec->cnt].event_disp					= uar_get_code_display(ce.event_cd)
	t_rec->qual[t_rec->cnt].event_end_dt_tm				= ce.event_end_dt_tm
	t_rec->qual[t_rec->cnt].event_id					= ce.event_id
	t_rec->qual[t_rec->cnt].fin							= cnvtalias(ea.alias,ea.alias_pool_cd)
	t_rec->qual[t_rec->cnt].inerror_ind					= 1
	t_rec->qual[t_rec->cnt].name_full_formatted			= p.name_full_formatted
	t_rec->qual[t_rec->cnt].person_id					= p.person_id
	t_rec->qual[t_rec->cnt].result_val					= ce.result_val
	t_rec->qual[t_rec->cnt].success_ind					= 0
foot report
	call writeLog(build2("<-leaving event query"))
with nocounter	


if (t_rec->cnt <= 0)
	set program_log->display_on_exit = 1
	set reply->status_data.status = "Z"
	set reply->status_data.subeventstatus.operationname = "CLINICAL_EVENTS"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "CLINICAL_EVENTS"
	set reply->status_data.subeventstatus.targetobjectvalue = "No Events Found"
	go to exit_script
endif


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Sending Documents to EKS ***************************"))

%i cclsource:eks_run3091001.inc

call writeLog(build2("Starting EKSOPSRequest calls:",trim(cnvtstring(t_rec->cnt))))
for (i=1 to t_rec->cnt)
	if (t_rec->qual[i].encntr_id > 0.0)
		if (t_rec->qual[i].inerror_ind = 1)
			call writeLog(build2("-->Looking at Item:",trim(cnvtstring(i))))
			call writeLog(build2("-->Setting Expert Trigger to ",t_rec->trigger))
			set stat = initrec(EKSOPSRequest)
			select into "NL:"
				e.encntr_id,
				e.person_id,
				e.reg_dt_tm,
				p.birth_dt_tm,
				p.sex_cd
			from
				person p,
				encounter e,
				clinical_event ce
			plan ce
				where ce.event_id = t_rec->qual[i].event_id
			join e where e.encntr_id = ce.encntr_id
			join p where p.person_id= e.person_id
			head report
				cnt = 0
				EKSOPSRequest->expert_trigger = t_rec->trigger
			detail
				cnt = cnt +1
				stat = alterlist(EKSOPSRequest->qual, cnt)
				EKSOPSRequest->qual[cnt].person_id = p.person_id
				EKSOPSRequest->qual[cnt].sex_cd  = p.sex_cd
				EKSOPSRequest->qual[cnt].birth_dt_tm  = p.birth_dt_tm
				EKSOPSRequest->qual[cnt].encntr_id  = e.encntr_id
				stat = alterlist(EKSOPSRequest->qual[cnt].data,1)
				EKSOPSRequest->qual[cnt].data[1].double_var = ce.clinical_event_id
				call writeLog(build2("---->EKSOPSRequest->qual[",trim(cnvtstring(cnt)),"].person_id=",
					trim(cnvtstring(EKSOPSRequest->qual[cnt].person_id))))
				call writeLog(build2("---->EKSOPSRequest->qual[",trim(cnvtstring(cnt)),"].encntr_id=",
					trim(cnvtstring(EKSOPSRequest->qual[cnt].encntr_id))))
				call writeLog(build2("---->EKSOPSRequest->qual[",trim(cnvtstring(cnt)),"].data[1].double_var=",
					trim(cnvtstring(EKSOPSRequest->qual[cnt].data[1].double_var))))
			with nocounter
			set dparam = 0
			if (t_rec->audit_mode != 1)
				call writeLog(build2("------>CALLING srvRequest"))
				;call srvRequest(dparam)
				set dparam = tdbexecute(3055000,4801,3091001,"REC",EKSOPSRequest,"REC",ReplyOut) 
				;call pause(3)
			else
				call writeLog(build2("------>AUDIT MODE, Not calling srvRequest"))
			endif
			set t_rec->qual[i].success_ind = dparam
		endif
	endif
endfor


call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))

set audit_header = concat(
								^"FIN"^				,^,^,
								^"Patient"^			,^,^, 
								^"Result DT/TM"^	,^,^,
								^"Result Type"^		,^,^,
								^"Result Value"^	,^,^,
								^"Status"^			,^,^,
								^"EVENT_ID"^		,^,^,
								^"User"^			,^,^
						)

call writeAudit(audit_header)

for (i=1 to t_rec->cnt)
	set audit_line = ""
	set audit_line = concat(
								^"^,trim(t_rec->qual[i].fin),^"^,^,^,
								^"^,trim(t_rec->qual[i].name_full_formatted),^"^,^,^,
								^"^,trim(format(t_rec->qual[i].event_end_dt_tm,";;q")),^"^,^,^, ;001
								^"^,trim(t_rec->qual[i].event_disp),^"^,^,^,
								^"^,trim(t_rec->qual[i].result_val),^"^,^,^,
								^"^,trim(cnvtstring(t_rec->qual[i].success_ind)),^"^,^,^,
								^"^,trim(cnvtstring(t_rec->qual[i].event_id)),^"^,^,^,
								^"^,trim(t_rec->prsnl_name),^"^,^,^
							)
	call writeAudit(audit_line)				
endfor

call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))


call echojson(t_rec, concat("cclscratch:",t_rec->records_attachment) , 1) 
call echojson(program_log, concat("cclscratch:",t_rec->records_attachment) , 1) 

call writeLog(build2(cnvtrectojson(t_rec)))

call addAttachment(program_log->files.file_path, t_rec->records_attachment) 

set reply->status_data.status = "S"

#exit_script
if (reply->status_data.status = "S")
	select into t_rec->user_prompts.outdev
		 fin=substring(1,20,t_rec->qual[d1.seq].fin)
		,name=substring(1,75,t_rec->qual[d1.seq].name_full_formatted)
		,result_date=substring(1,20,format(t_rec->qual[d1.seq].event_end_dt_tm,";;q"))
		,result_type=substring(1,30,t_rec->qual[d1.seq].event_disp)
		,result=substring(1,20,t_rec->qual[d1.seq].result_val)
		,user=substring(1,20,t_rec->prsnl_username)
		,event_id=t_rec->qual[d1.seq].event_id
		,success=if(t_rec->qual[d1.seq].success_ind = 0) substring(1,3,"YES") else substring(1,2,"NO") endif
	from
		(dummyt d1 with seq=t_rec->cnt)
	with nocounter,seperator= " ",format
else
	set program_log->display_on_exit = 1
endif

call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
