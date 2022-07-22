/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		03/30/2020
	Solution:			Perioperative
	Source file name:	cov_pcp_result_check.prg
	Object name:		cov_pcp_result_check
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	03/30/2020  Chad Cummings			Initial Release
******************************************************************************/

drop program cov_pcp_result_check:dba go
create program cov_pcp_result_check:dba

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.

with OUTDEV


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

record t_rec
(
	1 log_filename	= vc
	1 trigger		= vc
	1 audit_mode	= i2
	1 cnt			= i4
	1 qual[*]
	 2 person_id	= f8
	 2 name_full	= vc
	 2 cmrn			= vc
	 2 encntr_id	= f8
	 2 result_cnt	= i2
	 2 result_qual[*]
	  3 event_id	= f8
	  3 encntr_id	= f8
	  3 fin			= vc
	  3 result_val	= vc
	  3 remove_ind	= i2
	 2 pcp_id		= f8
	 2 pcp_prsnl_id	= f8
	 2 pcp_name		= vc
	 2 all_removed	= i2
	 2 update_ind	= i2
) with protect

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

;call addEmailLog("chad.cummings@covhlth.com")

declare i = i4 with noconstant(0)
declare j = i4 with noconstant(0)
declare fin = vc with noconstant("")

set t_rec->log_filename = concat(	 trim(cnvtlower(curdomain))
										,"_"
										,trim(cnvtlower(curprog))
										,"_"
										,trim(format(sysdate,"yyyymmdd_hhmmss;;d")),".dat")
								
call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
select into "nl:"
from
	 clinical_event ce
plan ce
	where ce.event_cd	in(	select 
								cv1.code_value
    						from code_value cv1 where cv1.code_set = 72
    						and   cv1.display in("D-Primary Care Physician")
    						and   cv1.active_ind = 1)
    and	  ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
    and   ce.result_status_cd in(
                                      value(uar_get_code_by("MEANING",8,"AUTH"))
                                     ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
                                     ,value(uar_get_code_by("MEANING",8,"ALTERED"))
                                )
    and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
    and   ce.event_tag        != "Date\Time Correction"
    and   ce.result_val        >  " "
order by
	 ce.person_id
	,ce.event_id
head report
	call writeLog(build2("->Inside First Clinical Event Query"))
head ce.person_id
	t_rec->cnt = (t_rec->cnt + 1)
	if ((mod(t_rec->cnt,10000) = 1) or (t_rec->cnt = 1))
		stat = alterlist(t_rec->qual,(t_rec->cnt + 9999))
	endif
	t_rec->qual[t_rec->cnt].person_id = ce.person_id
	call writeLog(build2("->t_rec->cnt=",cnvtstring(t_rec->cnt)))
	call writeLog(build2("->person_id=",cnvtstring(ce.person_id)))
head ce.event_id
	t_rec->qual[t_rec->cnt].result_cnt = (t_rec->qual[t_rec->cnt].result_cnt + 1)
	stat = alterlist(t_rec->qual[t_rec->cnt].result_qual,t_rec->qual[t_rec->cnt].result_cnt)
	t_rec->qual[t_rec->cnt].result_qual[t_rec->qual[t_rec->cnt].result_cnt].encntr_id 	= ce.encntr_id
	t_rec->qual[t_rec->cnt].result_qual[t_rec->qual[t_rec->cnt].result_cnt].event_id	= ce.event_id
	t_rec->qual[t_rec->cnt].result_qual[t_rec->qual[t_rec->cnt].result_cnt].result_val	= ce.result_val
	
	call writeLog(build2("->cnt=",cnvtstring(t_rec->qual[t_rec->cnt].result_cnt)))
	call writeLog(build2("-->encntr_id=",cnvtstring(ce.encntr_id)))
	call writeLog(build2("-->event_id=",cnvtstring(ce.event_id)))
	call writeLog(build2("-->result_val=",trim(ce.result_val)))
foot ce.event_id
	null
foot ce.person_id
	null
foot report
	stat = alterlist(t_rec->qual,(t_rec->cnt))
	call writeLog(build2("<-Leaving First Clinical Event Query"))
with nocounter   							
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
select into "nl:"
from
	 person_prsnl_reltn ppr
	,prsnl p
	,(dummyt d1 with seq=t_rec->cnt)
plan d1
	where t_rec->qual[d1.seq].person_id > 0.0
join ppr
	where 	ppr.person_id = t_rec->qual[d1.seq].person_id
	and		ppr.person_prsnl_r_cd = value(uar_get_code_by("MEANING",331,"PCP"))
	and   	ppr.active_ind = 1
	and   	ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   	ppr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
join p
	where p.person_id = ppr.prsnl_person_id
order by
	 ppr.person_id
	,ppr.prsnl_person_id
	,ppr.beg_effective_dt_tm desc
head report
	call writeLog(build2("->Entering PPR Query"))
head ppr.person_id
	t_rec->qual[d1.seq].pcp_id 			= ppr.person_prsnl_reltn_id
	t_rec->qual[d1.seq].pcp_prsnl_id 	= ppr.prsnl_person_id
	t_rec->qual[d1.seq].pcp_name		= p.name_full_formatted
	
	call writeLog(build2("-->d1.seq=",cnvtstring(d1.seq)))
	call writeLog(build2("-->pcp_id=",cnvtstring(t_rec->qual[d1.seq].pcp_id)))
	call writeLog(build2("-->pcp_prsnl_id=",cnvtstring(t_rec->qual[d1.seq].pcp_prsnl_id)))
	call writeLog(build2("-->pcp_name=",trim(t_rec->qual[d1.seq].pcp_name)))
	
foot report
	call writeLog(build2("<-Leaving PPR Query"))
with nocounter
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
select into "nl:"
	 person_id = t_rec->qual[d1.seq].person_id
	,event_id = t_rec->qual[d1.seq].result_qual[d2.seq].event_id
from
	 (dummyt d1 with seq=t_rec->cnt)
	,(dummyt d2)
plan d1
	where maxrec(d2,t_rec->qual[d1.seq].result_cnt)
	and t_rec->qual[d1.seq].result_cnt > 1
join d2
order by
	 person_id
	,event_id
head report
	call writeLog(build2("->Entering Removal Calculation"))
	cnt = 0
head person_id
	call writeLog(build2("->person_id=",cnvtstring(t_rec->qual[d1.seq].person_id)))
	call writeLog(build2("->pcp_name=",t_rec->qual[d1.seq].pcp_name))
	cnt = 0
head event_id
	call writeLog(build2("-->event_id=",cnvtstring(t_rec->qual[d1.seq].result_qual[d2.seq].event_id)))
	call writeLog(build2("-->result_val=",t_rec->qual[d1.seq].result_qual[d2.seq].result_val))
	if (t_rec->qual[d1.seq].result_qual[d2.seq].result_val != t_rec->qual[d1.seq].pcp_name)
		t_rec->qual[d1.seq].result_qual[d2.seq].remove_ind = 1
		cnt = (cnt + 1)
		call writeLog(build2("--->remove_ind=",t_rec->qual[d1.seq].result_qual[d2.seq].remove_ind))	
	endif
foot event_id
	null
foot person_id
	if (cnt = t_rec->qual[d1.seq].result_cnt)
		t_rec->qual[d1.seq].all_removed = 1
		t_rec->qual[d1.seq].encntr_id = t_rec->qual[d1.seq].result_qual[d2.seq].encntr_id
	endif
	call writeLog(build2("->all_removed=",cnvtstring(t_rec->qual[d1.seq].all_removed)))
	cnt = 0
foot report
	call writeLog(build2("<-Entering Removal Calculation"))
with nocounter
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
select into "nl:"
	 person_id = t_rec->qual[d1.seq].person_id
	,event_id = t_rec->qual[d1.seq].result_qual[d2.seq].event_id
from
	 (dummyt d1 with seq=t_rec->cnt)
	,(dummyt d2)
	,encntr_alias ea
plan d1
	where maxrec(d2,t_rec->qual[d1.seq].result_cnt)
join d2
join ea
	where ea.encntr_id = t_rec->qual[d1.seq].result_qual[d2.seq].encntr_id
	and   ea.active_ind = 1
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
detail
	t_rec->qual[d1.seq].result_qual[d2.seq].fin = cnvtalias(ea.alias,ea.alias_pool_cd)
with nocounter
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
select into "nl:"
	 person_id = t_rec->qual[d1.seq].person_id
from
	 (dummyt d1 with seq=t_rec->cnt)
	,person_alias pa
plan d1
join pa
	where pa.person_id = t_rec->qual[d1.seq].person_id
	and   pa.person_alias_type_cd = value(uar_get_code_by("MEANING",4,"CMRN"))
	and   cnvtdatetime(curdate,curtime3) between pa.beg_effective_dt_tm and pa.end_effective_dt_tm
	and   pa.active_ind = 1
detail
	t_rec->qual[d1.seq].cmrn = cnvtalias(pa.alias,pa.alias_pool_cd)
with nocounter
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
select into "nl:"
	 person_id = t_rec->qual[d1.seq].person_id
from
	 (dummyt d1 with seq=t_rec->cnt)
	,person pa
plan d1
join pa
	where pa.person_id = t_rec->qual[d1.seq].person_id
detail
	t_rec->qual[d1.seq].name_full = pa.name_full_formatted
with nocounter
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
select into $OUTDEV
	 person_id=t_rec->qual[d1.seq].person_id
	,patient_name = substring(1,100,t_rec->qual[d1.seq].name_full)
	,cmrn = substring(1,20,t_rec->qual[d1.seq].cmrn)
	,pcp_id = t_rec->qual[d1.seq].pcp_id
	,pcp_name = substring(1,100,t_rec->qual[d1.seq].pcp_name)
	,all_removed = t_rec->qual[d1.seq].all_removed
	,result_cnt = t_rec->qual[d1.seq].result_cnt
	,fin = substring(1,15,t_rec->qual[d1.seq].result_qual[d2.seq].fin)
	,event_id=t_rec->qual[d1.seq].result_qual[d2.seq].event_id
	,result_val=substring(1,100,t_rec->qual[d1.seq].result_qual[d2.seq].result_val)
	,remove_ind=t_rec->qual[d1.seq].result_qual[d2.seq].remove_ind
from
	 (dummyt d1 with seq=t_rec->cnt)
	,(dummyt d2)
	
plan d1
	where maxrec(d2,t_rec->qual[d1.seq].result_cnt)
join d2
order by
	result_cnt desc
with nocounter
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))
/*
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))
%i cclsource:eks_run3091001.inc
set check = 0
set t_rec->audit_mode = 0
set t_rec->trigger = "COV_EE_UPDT_PCP"
for (i = 1 to t_rec->cnt)
 if (check = 0)
	for (j=1 to t_rec->qual[i].result_cnt)
		if ((t_rec->qual[i].result_qual[j].remove_ind = 1) and (t_rec->qual[i].result_qual[j].event_id > 0.0))
			call writeLog(build2("->invalidating=",cnvtstring(t_rec->qual[i].result_qual[j].event_id)))
			update into clinical_event ce set ce.valid_until_dt_tm = cnvtdatetime(curdate,curtime3)
			where ce.event_id = t_rec->qual[i].result_qual[j].event_id
			commit 	 
		endif
	endfor
	if (t_rec->qual[i].all_removed = 1)
		set check = 1
		call writeLog(build2("-->calling COV_EE_UPDT_PCP"))
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
			encounter e
		plan e
			where e.encntr_id = t_rec->qual[i].encntr_id
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
			call writeLog(build2("---->EKSOPSRequest->qual[",trim(cnvtstring(cnt)),"].person_id=",
				trim(cnvtstring(EKSOPSRequest->qual[cnt].person_id))))
			call writeLog(build2("---->EKSOPSRequest->qual[",trim(cnvtstring(cnt)),"].encntr_id=",
				trim(cnvtstring(EKSOPSRequest->qual[cnt].encntr_id))))
		with nocounter
		set dparam = 0
		if (t_rec->audit_mode != 1)
			call writeLog(build2("------>CALLING srvRequest"))
			;002 call pause(3)
			set dparam = tdbexecute(3055000,4801,3091001,"REC",EKSOPSRequest,"REC",ReplyOut) ;002
			call writeLog(build2(cnvtrectojson(ReplyOut)))	;002
		else
			call writeLog(build2("------>AUDIT MODE, Not calling srvRequest"))
		endif
		call writeLog(build2(cnvtrectojson(EKSOPSRequest)))	;002 
	endif
 endif
endfor
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))
*/

#exit_script

call echojson(t_rec, concat("cclscratch:",t_rec->log_filename) , 1) 
execute cov_astream_file_transfer "cclscratch",replace(t_rec->log_filename,"cclscratch:",""),"","MV"

call exitScript(null)
;call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
