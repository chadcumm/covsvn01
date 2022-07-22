/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		03/30/2020
	Solution:			Perioperative
	Source file name:	cov_cmg_patient_email.prg
	Object name:		cov_cmg_patient_email
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

drop program cov_cmg_patient_email:dba go
create program cov_cmg_patient_email:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Email List To" = ""
	;<<hidden>>"Included Locations Locations (Not a Prompt)" = 0 

with OUTDEV, EMAIL


call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))

set modify maxvarlen 268435456 ;increases max file size

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

call set_codevalues(null)
call check_ops(null)

free set t_rec
record t_rec
(
	1 prompt_email		= vc
	1 cnt				= i4
	1 qual[*]
	 2 person_id		= f8
	 2 email_address	= vc
	 2 encntr_cnt		= i2
	 2 age				= vc
	 2 locations		= vc
	 2 full_name		= vc
	 2 encntr_qual[*]
	  3 encntr_id		= f8
	  3 encntr_type		= vc
	  3 encntr_loc		= vc
	  3 reg_dt_tm		= vc
)

if ($EMAIL > " ")
	set t_rec->prompt_email = trim($EMAIL)
endif

call addEmailLog("chad.cummings@covhlth.com")

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("* START Finding Patients ***********************************"))
select into "nl:"
from
	 person p
	,encounter e
	,organization o
	,org_set os
	,org_set_org_r osor
plan p
	where p.person_id > 0.0
	and   p.active_ind = 1
	and   cnvtdatetime(curdate,curtime3) between p.beg_effective_dt_tm and p.end_effective_dt_tm
	and   cnvtint((DATETIMEDIFF(cnvtdatetime(curdate,0), p.birth_dt_tm)/365.25)) >= (18)
	and   p.deceased_dt_tm is null
	and   p.deceased_cd not in(value(uar_get_code_by("MEANING",268,"YES")))
	and   p.name_last_key not in(
									 "ZZZTEST"
									,"TTTEST"
									,"TTTTEST"
									,"TTTTMAYO"
									,"TTTTTEST"
									,"FFFFOP"
									,"TTTTGENLAB"
									,"TTTTQUEST"			
								)
join e
	where e.person_id = p.person_id
	and   e.person_id > 0.0
	and   e.active_ind = 1
	and   cnvtdatetime(curdate,curtime3) between e.beg_effective_dt_tm and e.end_effective_dt_tm
	and   e.encntr_status_cd not in(
										value(uar_get_code_by("MEANING",261,"CANCELLED"))
									)
	and   e.encntr_type_cd not in(
									value(uar_get_code_by("DISPLAY",71,"Phone Message"))
								 )
	and   e.reg_dt_tm >= cnvtlookbehind("1,Y")
join o
	where o.organization_id = e.organization_id
	and   o.active_ind = 1 
join osor
	where osor.organization_id = o.organization_id
	and   osor.active_ind = 1
	and   cnvtdatetime(curdate,curtime3) between osor.beg_effective_dt_tm and osor.end_effective_dt_tm
join os
	where os.org_set_id = osor.org_set_id
	and   os.active_ind = 1
	and   cnvtdatetime(curdate,curtime3) between os.beg_effective_dt_tm and os.end_effective_dt_tm
	and   os.name like '*CMG*'
order by
	 p.person_id
	,e.encntr_id
head report
	t_rec->cnt = 0
	call writeLog(build2("->inside patient discovery"))
head p.person_id
	;call writeLog(build2("-->found patient person_id=",trim(cnvtstring(p.person_id))))
	t_rec->cnt = (t_rec->cnt + 1)
	if(mod(t_rec->cnt,1000) = 1)
        stat = alterlist(t_rec->qual, t_rec->cnt + 999)
    endif
    t_rec->qual[t_rec->cnt].person_id = p.person_id
    t_rec->qual[t_rec->cnt].full_name = p.name_full_formatted
    t_rec->qual[t_rec->cnt].age = cnvtage(p.birth_dt_tm)
head e.encntr_id
	;call writeLog(build2("--->found patient encntr_id=",trim(cnvtstring(e.encntr_id))))
	t_rec->qual[t_rec->cnt].encntr_cnt = (t_rec->qual[t_rec->cnt].encntr_cnt + 1)
	stat = alterlist(t_rec->qual[t_rec->cnt].encntr_qual,t_rec->qual[t_rec->cnt].encntr_cnt)
	t_rec->qual[t_rec->cnt].encntr_qual[t_rec->qual[t_rec->cnt].encntr_cnt].encntr_id = e.encntr_id
	t_rec->qual[t_rec->cnt].encntr_qual[t_rec->qual[t_rec->cnt].encntr_cnt].encntr_loc = trim(uar_get_code_display(e.loc_facility_cd))
	t_rec->qual[t_rec->cnt].encntr_qual[t_rec->qual[t_rec->cnt].encntr_cnt].encntr_type = trim(uar_get_code_display(e.encntr_type_cd))
	t_rec->qual[t_rec->cnt].encntr_qual[t_rec->qual[t_rec->cnt].encntr_cnt].reg_dt_tm  = trim(format(e.reg_dt_tm,"mm/dd/yyyy;;d"))
foot p.person_id
	;call writeLog(build2("-->leaving patient person_id=",trim(cnvtstring(p.person_id))))
	for (i=1 to t_rec->qual[t_rec->cnt].encntr_cnt)
		if (i=1)
			t_rec->qual[t_rec->cnt].locations = concat(	t_rec->qual[t_rec->cnt].encntr_qual[i].encntr_loc, 
														" (",
														t_rec->qual[t_rec->cnt].encntr_qual[i].encntr_type,
														" [",
														t_rec->qual[t_rec->cnt].encntr_qual[i].reg_dt_tm,
														"]",
														")"
													)
		else
			t_rec->qual[t_rec->cnt].locations = concat( t_rec->qual[t_rec->cnt].locations,";",
														t_rec->qual[t_rec->cnt].encntr_qual[i].encntr_loc,
														" (",
														t_rec->qual[t_rec->cnt].encntr_qual[i].encntr_type,
														" [",
														t_rec->qual[t_rec->cnt].encntr_qual[i].reg_dt_tm,
														"]",
														")"
													)
		endif
	endfor
foot report
	call writeLog(build2("->exiting patient discovery"))
	stat = alterlist(t_rec->qual, t_rec->cnt)
with nocounter

if (t_rec->cnt <= 0)
	set reply->status_data.status = "Z"
	set reply->status_data.subeventstatus.operationname = "PERSON"
	set reply->status_data.subeventstatus.operationstatus = "Z"
	set reply->status_data.subeventstatus.targetobjectname = "PERSON"
	set reply->status_data.subeventstatus.targetobjectvalue = "No Patients Found"
	go to exit_script
endif

call writeLog(build2("* END   Finding Patients ***********************************"))	
call writeLog(build2("************************************************************"))

call writeLog(build2("* START Email (phone table) ********************************"))
select into "nl:"
from
	(dummyt d1 with seq=t_rec->cnt)
	,phone p
plan d1
join p
	where p.parent_entity_id = t_rec->qual[d1.seq].person_id
	and   p.active_ind = 1
	and   cnvtdatetime(curdate,curtime3) between p.beg_effective_dt_tm and p.end_effective_dt_tm
	and   p.contact_method_cd in(value(uar_get_code_by("MEANING",23056,"MAILTO")))
order by
	 p.parent_entity_id
	,p.beg_effective_dt_tm desc
head p.parent_entity_id
	t_rec->qual[d1.seq].email_address = trim(p.phone_num)
with nocounter

call writeLog(build2("* END   Email (phone table) ********************************"))

call writeLog(build2("* START Writing File ***************************************"))

set audit_header = concat(
                                char(34),   "PERSON_ID",		char(34),char(44),
                                char(34),   "PATIENT_NAME",		char(34),char(44),
                                char(34),   "EMAIL_ADDRESS",	char(34),char(44),
                                char(34),   "AGE",				char(34),char(44),
                                char(34),   "LOCATIONS",		char(34),char(44)
                               )

call writeAudit(audit_header)

for (i=1 to t_rec->cnt)
	set audit_line = ""
	set pos = 0
	if (t_rec->qual[i].email_address > " ")
		set pos = findstring("@",t_rec->qual[i].email_address)
		if (pos > 0)
			set audit_line = build2(
	 							char(34),   t_rec->qual[i].person_id,		char(34),char(44),
                                char(34),   t_rec->qual[i].full_name,		char(34),char(44),
                                char(34),   t_rec->qual[i].email_address,	char(34),char(44),
                                char(34),   t_rec->qual[i].age,				char(34),char(44),
                                char(34),   t_rec->qual[i].locations,		char(34),char(44)	
								)
			call writeAudit(audit_line)
		endif
	endif
endfor

set reply->status_data.status = "S"

call writeLog(build2("* END  Writing File ****************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("* START Final Output ***************************************"))

if ((reply->status_data.status = "S") and (t_rec->prompt_email > " "))
	call addEmailLog(t_rec->prompt_email)
	set program_log->display_on_exit = 1
elseif (reply->status_data.status = "S")
	select into $OUTDEV
		 person_id = t_rec->qual[d1.seq].person_id
		,name = substring(1,100,t_rec->qual[d1.seq].full_name)
		,age = substring(1,20,t_rec->qual[d1.seq].age)
		,email = substring(1,150,t_rec->qual[d1.seq].email_address)
	from
		(dummyt d1 with seq=t_rec->cnt)
	plan d1
		where t_rec->qual[d1.seq].email_address > " "
		and findstring("@",t_rec->qual[d1.seq].email_address) > 0
	with nocounter, separator=" ",format
endif

call writeLog(build2("* END Final Output *****************************************"))

#exit_script

if (reply->status_data.status = "F")
	call writeLog(build2(cnvtrectojson(reply)))
	set program_log->display_on_exit = 1
endif
call echo(t_rec->cnt)
call exitScript(null)
;call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
