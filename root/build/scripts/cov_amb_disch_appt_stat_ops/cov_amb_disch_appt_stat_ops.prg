/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:
  Source file name:   cov_amb_disch_appt_stat_ops.prg
  Object name:        cov_amb_disch_appt_stat_ops
  Request #:
 
  Program purpose:
 
  Executing from:     CCL
 
  Special Notes:      Called by ccl program(s).
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   03/01/2019  Chad Cummings			initial build
******************************************************************************/
drop program cov_amb_disch_appt_stat_ops go
create program cov_amb_disch_appt_stat_ops
 
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
 
set reply->status_data.status = "F"
 
record t_rec
(
	1 cnt = i2
	1 audit_mode = i2
	1 qual[*]
	 2 encntr_id = f8
	 2 person_id = f8
	 2 task_id = f8
)
 
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
 
declare i = i2 with noconstant(0), protect
declare j = i2 with noconstant(0), protect
declare k = i2 with noconstant(0), protect
declare bad_followup = i2 with noconstant(0), protect
 
declare start_dt_tm_vc = vc with noconstant(" ")
declare end_dt_tm_vc = vc with noconstant(" ")
 
 
set start_dt_tm_vc = format(cnvtdatetime(curdate-30,0),"DD-MMM-YYYY HH:MM:SS;;q")
set end_dt_tm_vc = format(cnvtdatetime(curdate,235959),"DD-MMM-YYYY HH:MM:SS;;q")
;set start and end date
 
set trace recpersist ;https://wiki.cerner.com/display/public/1101discernHP/SET+TRACE+Using+Discern+Explorer
execute cov_amb_discharge_appt_check "NOFORMS",value(start_dt_tm_vc), value(end_dt_tm_vc),0.0,0
 
;call echorecord(rec)
 
if (not validate(rec))
 go to exit_script
endif
 
;find the bad follow-ups
for (i=1 to rec->encntr_cnt)
	set bad_followup = 0
	for (j=1 to rec->list[i].folwups_cnt)
		if (rec->list[i].folwups[j].folwup_doc_id > 0.0)
		 if ((rec->list[i].folwups[j].folwup_within_dt = 0.0) or (rec->list[i].folwups[j].folwup_days_or_weeks in(0,1)))
		 	;assume this is a bad followup - need to review with Lori and team to determine what a 'bad' follow up is.
			;ignore Follow-up in Emergency Department
			 ;FOLWUP_PROVIDER_LOC=VC33   {Follow-up in Emergency Department}
			call echo(build("->checking followup=",rec->list[i].folwups[j].folwup_doc_id))
			call echo(build("->checking folwup_within_dt=",rec->list[i].folwups[j].folwup_within_dt))
			call echo(build("->checking folwup_days_or_weeks=",rec->list[i].folwups[j].folwup_days_or_weeks))
			set bad_followup = 1
			if ((bad_followup = 1) and (rec->list[i].folwups[j].folwup_provider_loc = "Follow-up in Emergency Department"))
				set bad_followup = 0
			endif
		 endif
		endif
	endfor
	call echo(build("-->bad_followup=",bad_followup))
	if (bad_followup = 1)
		set t_rec->cnt = (t_rec->cnt + 1)
		set stat = alterlist(t_rec->qual,t_rec->cnt)
		set t_rec->qual[t_rec->cnt].encntr_id = rec->list[i].encntr_id
		set t_rec->qual[t_rec->cnt].person_id = rec->list[i].person_id
	endif
endfor
 
set trace norecpersist
 
if (t_rec->cnt = 0)
	set reply->status_data.status = "Z"
	go to exit_script
endif
 
;double check to see if this encoutner already has the task
;need a query here.
select into "nl:"
from
	 task_activity ta
	,order_task ot
	plan ot
		where ot.task_description = "Follow Up Appointment"
		and   ot.active_ind = 1
	join ta
		where ta.reference_task_id = ot.reference_task_id
		and ta.task_status_cd in(
									 ; value(uar_get_code_by("MEANING",79,"COMPLETE"))
									  value(uar_get_code_by("MEANING",79,"PENDING"))
									 ,value(uar_get_code_by("MEANING",79,"OVERDUE"))
									 ,value(uar_get_code_by("MEANING",79,"INPROCESS"))
									 ;,value(uar_get_code_by("MEANING",79,"DROPPED"))
								)
		and expand(i,1,t_rec->cnt,ta.encntr_id,t_rec->qual[i].encntr_id)
order by
	ta.encntr_id
head report
	k = 0
head ta.encntr_id
	k = 0
	k = locateval(j,1,t_rec->cnt,ta.encntr_id,t_rec->qual[j].encntr_id)
	if (k > 0)
		t_rec->qual[k].task_id = ta.task_id
	endif
with nocounter,expand = 1
 
;if no task and bad follow-up call rule to create task.
%i cclsource:eks_run3091001.inc
for (i=1 to t_rec->cnt)
 if (t_rec->qual[i].task_id = 0.0)
	set stat = initrec(EKSOPSRequest)
 
	select into "NL:"
		e.encntr_id,
		e.person_id,
		e.reg_dt_tm,
		p.birth_dt_tm,
		p.sex_cd
	from
		person p,
		encounter e
	plan e
		where e.encntr_id = t_rec->qual[i].encntr_id
	join p where p.person_id= e.person_id
	head report
		cnt = 0
		EKSOPSRequest->expert_trigger = "COV_EE_FOLLOWUP_TSK"
	detail
		cnt = cnt +1
		stat = alterlist(EKSOPSRequest->qual, cnt)
		EKSOPSRequest->qual[cnt].person_id 		= p.person_id
		EKSOPSRequest->qual[cnt].sex_cd  		= p.sex_cd
		EKSOPSRequest->qual[cnt].birth_dt_tm  	= p.birth_dt_tm
		EKSOPSRequest->qual[cnt].encntr_id 		= e.encntr_id
	with nocounter
	set dparam = 0
	if (t_rec->audit_mode != 1)
		set dparam = tdbexecute(3055000,4801,3091001,"REC",EKSOPSRequest,"REC",ReplyOut) ;002
		call echo("call rule")
	endif
 endif
endfor
 
set reply->status_data.status = "S"
 
#exit_script
 
call echorecord(t_rec)
call echorecord(reply)
 
end
go
 
