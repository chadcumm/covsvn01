/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		   	03/01/2019
	Solution:			Ambulatory
	Source file name:	 	cov_tog_prov_doc_audit.prg
	Object name:		   	cov_tog_prov_doc_audit
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	03/01/2019  Chad Cummings
******************************************************************************/

drop program cov_tog_prov_doc_audit:dba go
create program cov_tog_prov_doc_audit:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Physician" = 0
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE" 

with OUTDEV, loc_phys, start_datetime, end_datetime


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
	1 start_dt_tm		= dq8
	1 end_dt_tm			= dq8
	1 app_loc_cnt		= i2
	1 app_loc[*]
	 2 app_location_cd 	= f8
	 2 description 		= vc
	1 res_cnt			= i2
	1 res_list[*]
	 2 resource_cd		= f8
	 2 prsnl_id			= f8
	 2 provider_name	= vc
	 2 resource_name	= vc
	1 doc_cnt			= i2
	1 doc_list[*]
	 2 event_cd			= f8
	 2 display			= vc
	1 cnt 				= i2
	1 qual[*]
	 2 sch_event_id		= f8
	 2 appt_location_cd = f8
	 2 appt_dt_tm		= dq8
	 2 resource_cd		= f8
	 2 encntr_id		= f8
	 2 person_id		= f8
	 2 prsnl_id			= f8
	 2 fin				= vc
	 2 patient_name		= vc
	 2 note_cnt			= i2
	 2 note_list[*]
	  3 event_id		= f8
	  3 event_cd		= f8
	  3 event_date		= dq8
	  3 result_status_cd=f8
	 2 note_1_disp		= vc
	 2 note_1_dt_tm		= dq8
	 2 note_1_status	= vc
	 2 note_2_disp		= vc
	 2 note_2_dt_tm		= dq8
	 2 note_2_status	= vc
	 2 note_3_disp		= vc
	 2 note_3_dt_tm		= dq8
	 2 note_3_status	= vc	 
)

;call addEmailLog("chad.cummings@covhlth.com")

set t_rec->start_dt_tm 		= cnvtdatetime($start_datetime)
set t_rec->end_dt_tm		= cnvtdatetime($end_datetime)

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("* START Adding Appointment Location   **********************"))

select into "nl:"
	description = uar_get_code_display(sl.location_cd)
from
	sch_location sl
plan sl
	;where sl.location_cd 			= $loc_clinic
	where sl.location_cd			in(
										  2553766363.00	;TOG - Blount
										 ,2553766379.00	;TOG - Downtown
										 ;         0.00	;TOG - Harriman
										 ,2553766395.00	;TOG - Lenoir City
										 ,2553766411.00	;TOG - MHHS
										 ,2555024953.00	;TOG - Oak Ridge
										 ,2553766443.00	;TOG - Sevier
										 ,2553766459.00	;TOG - West
										)
	and   sl.active_ind 			= 1
	and   sl.beg_effective_dt_tm	<= cnvtdatetime(curdate,curtime3)
	and   sl.end_effective_dt_tm	>= cnvtdatetime(curdate,curtime3)
order by
	 description
	,sl.location_cd
head report
	t_rec->app_loc_cnt = 0
head sl.location_cd	
	t_rec->app_loc_cnt = (t_rec->app_loc_cnt + 1)
	stat = alterlist(t_rec->app_loc,t_rec->app_loc_cnt)
	t_rec->app_loc[t_rec->app_loc_cnt].app_location_cd 		= sl.location_cd
	t_rec->app_loc[t_rec->app_loc_cnt].description			= uar_get_code_display(sl.location_cd)
with nocounter

call writeLog(build2("* END   Adding Appointment Location   **********************"))
call writeLog(build2("* START Adding Appointment Resource   **********************"))

select into "nl:"
from
	sch_resource sr
	,prsnl p
plan sr
	where sr.resource_cd 			= $loc_phys
	and   sr.active_ind 			= 1
	and   sr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
join p
	where p.person_id 				= sr.person_id
order by
	 sr.description
	,sr.resource_cd
head report
	t_rec->res_cnt = 0
head sr.resource_cd
	t_rec->res_cnt = (t_rec->res_cnt + 1)
	stat = alterlist(t_rec->res_list,t_rec->res_cnt)
	t_rec->res_list[t_rec->res_cnt].resource_cd			= sr.resource_cd
	t_rec->res_list[t_rec->res_cnt].prsnl_id 			= sr.person_id
	t_rec->res_list[t_rec->res_cnt].provider_name		= p.name_full_formatted
	t_rec->res_list[t_rec->res_cnt].resource_name		= sr.description
with nocounter

call writeLog(build2("* END   Adding Appointment Resource   **********************"))


call writeLog(build2("* START Document Types   **********************"))
select into "nl:"
from 
	code_value cv
plan cv
	where cv.code_set 	= 72
	and   cv.display in(
							 "Oncology Office Visit Follow Up"
							,"Oncology Office Visit New/Consult"
							,"Oncology New/Consult Note"
						)
	and  cv.active_ind 	= 1
	and  cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and  cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
order by
	 cv.display
	,cv.begin_effective_dt_tm desc
	,cv.code_value
head report
	t_rec->doc_cnt = 0
head cv.code_value
	t_rec->doc_cnt = (t_rec->doc_cnt + 1)
	stat = alterlist(t_rec->doc_list,t_rec->doc_cnt)
	t_rec->doc_list[t_rec->doc_cnt].event_cd = cv.code_value
	t_rec->doc_list[t_rec->doc_cnt].display = cv.display
with nocounter

call writeLog(build2("* END   Document Types   **********************"))

call writeLog(build2("* START Finding Appointments   *****************************"))

select into "nl:"
from
	 sch_appt sa
	,sch_appt sap
plan sa
	where expand(i,1,t_rec->app_loc_cnt,sa.appt_location_cd,t_rec->app_loc[i].app_location_cd)
	and   sa.beg_dt_tm between cnvtdatetime(t_rec->start_dt_tm) and cnvtdatetime(t_rec->end_dt_tm)
	and   expand(j,1,t_rec->res_cnt,sa.resource_cd,t_rec->res_list[j].resource_cd)
	and   sa.role_meaning != "PATIENT"
	and   sa.sch_state_cd in(
									 code_values->cv.cs_14233.checked_out_cd
									,code_values->cv.cs_14233.checked_in_cd
									,code_values->cv.cs_14233.finalized_cd
									,code_values->cv.cs_14233.complete_cd
								)
join sap
	where sap.sch_event_id = sa.sch_event_id
	and   sap.role_meaning = "PATIENT"
	and   sap.encntr_id > 0.0
order by
	 sa.beg_dt_tm
	,sa.sch_event_id
head report
	t_rec->cnt = 0
head sa.sch_event_id
	t_rec->cnt = (t_rec->cnt + 1)
	if (mod(t_rec->cnt,100) = 1)
		stat = alterlist(t_rec->qual, (t_rec->cnt + 99))
	endif
	t_rec->qual[t_rec->cnt].sch_event_id 		= sa.sch_event_id
	t_rec->qual[t_rec->cnt].resource_cd 		= sa.resource_cd
	t_rec->qual[t_rec->cnt].appt_location_cd	= sa.appt_location_cd
	t_rec->qual[t_rec->cnt].encntr_id			= sap.encntr_id
	t_rec->qual[t_rec->cnt].person_id			= sap.person_id
	t_rec->qual[t_rec->cnt].appt_dt_tm			= sa.beg_dt_tm
	
	idx = locateval(k,1,t_rec->res_cnt,sa.resource_cd,t_rec->res_list[k].resource_cd)
	if (idx > 0)
		t_rec->qual[t_rec->cnt].prsnl_id = t_rec->res_list[idx].prsnl_id
	endif
	
foot report
	stat = alterlist(t_rec->qual,t_rec->cnt)
with nocounter


call writeLog(build2("* END   Finding Appointments   *****************************"))


call writeLog(build2("* START Finding Documents ************************************"))

select into "nl:"
from
		 clinical_event ce
		,(dummyt d1 with seq = t_rec->cnt)
plan d1
	where t_rec->qual[d1.seq].encntr_id > 0.0
join ce
	where ce.encntr_id = t_rec->qual[d1.seq].encntr_id
	and	  ce.result_status_cd in(
									  code_values->cv.cs_8.in_progress_cd
									 ,code_values->cv.cs_8.auth_cd
									 ,code_values->cv.cs_8.modified_cd
									 ,code_values->cv.cs_8.altered_cd
								)
	
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
	and   ce.view_level 		= 1
	;and   ce.result_val        >  " "
	and   expand(i,1,t_rec->doc_cnt,ce.event_cd,t_rec->doc_list[i].event_cd)
order by
	 d1.seq
	,ce.event_cd
	;,ce.result_status_cd
	,ce.event_end_dt_tm desc
head report
	call writeLog(build2("* Starting Document Search   "))
head d1.seq	
	call writeLog(build2("-->Reviewing encounter t_rec->qual[",trim(cnvtstring(d1.seq)),"].encntr_id = ",
		trim(cnvtstring(ce.encntr_id))," for documents"))
head ce.event_cd
	call writeLog(build2("---->Document Type ",trim(uar_get_code_display(ce.event_cd)),
		" (",trim(cnvtstring(ce.event_cd)),") found on: ",format(ce.event_end_dt_tm,";;q")," (",trim(cnvtstring(ce.event_id)),")"))
	call writeLog(build2("------>Document Status ",trim(uar_get_code_display(ce.result_status_cd)),
		" (",trim(cnvtstring(ce.record_status_cd)),")"))
	t_rec->qual[d1.seq].note_cnt = (t_rec->qual[d1.seq].note_cnt + 1)
	stat = alterlist(t_rec->qual[d1.seq].note_list,t_rec->qual[d1.seq].note_cnt)
	t_rec->qual[d1.seq].note_list[t_rec->qual[d1.seq].note_cnt].event_id 			= ce.event_id
	t_rec->qual[d1.seq].note_list[t_rec->qual[d1.seq].note_cnt].event_cd			= ce.event_cd
	t_rec->qual[d1.seq].note_list[t_rec->qual[d1.seq].note_cnt].event_date			= ce.event_end_dt_tm
	t_rec->qual[d1.seq].note_list[t_rec->qual[d1.seq].note_cnt].result_status_cd	= ce.result_status_cd
foot report
	call writeLog(build2("* Ending Document Search   "))
with nocounter,nullreport
call writeLog(build2("* END   Finding Documents ************************************"))

call writeLog(build2("* START Finding FIN   ************************************"))
	;call get_fin(null)
	select into "nl:"
	from
		 encntr_alias ea
		,encounter e
		,person p
		,(dummyt d1 with seq = t_rec->cnt)
	plan d1
		where t_rec->qual[d1.seq].encntr_id > 0.0
	join e 
		where e.encntr_id = t_rec->qual[d1.seq].encntr_id
	join p
		where p.person_id = e.person_id
	join ea
		where ea.encntr_id = e.encntr_id
		and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
		and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
		and   ea.active_ind = 1
		and   ea.encntr_alias_type_cd = code_values->cv.cs_319.fin_nbr_cd 
	order by
		 e.encntr_id
		,d1.seq
		,e.beg_effective_dt_tm desc
	head report
		call writeLog(build2("**STARTING get_fin"))
	;head d1.seq
	detail
		call writeLog(build2("-->Adding FIN for t_rec->qual[",trim(cnvtstring(d1.seq)),"].encntr_id = ",trim(cnvtstring(e.
		encntr_id))," as ",trim(cnvtalias(ea.alias,ea.alias_pool_cd))))
		t_rec->qual[d1.seq].fin = cnvtalias(ea.alias,ea.alias_pool_cd)
		t_rec->qual[d1.seq].patient_name = trim(p.name_full_formatted)
	foot report
		call writeLog(build2("**ENDING get_fin"))
	with nocounter,nullreport
call writeLog(build2("* END   Finding FIN   ************************************"))

call writeLog(build2("* START Formatting Data   ************************************"))

for (i = 1 to t_rec->cnt)
	if (t_rec->qual[i].note_cnt > 0)
		for (j = 1 to t_rec->qual[i].note_cnt)
			if (t_rec->qual[i].note_list[j].event_cd = t_rec->doc_list[1].event_cd)
				set t_rec->qual[i].note_1_disp 		= uar_get_code_display(t_rec->qual[i].note_list[j].event_cd)
				set t_rec->qual[i].note_1_dt_tm 	= t_rec->qual[i].note_list[j].event_date
				set t_rec->qual[i].note_1_status 	= uar_get_code_display(t_rec->qual[i].note_list[j].result_status_cd)
			elseif (t_rec->qual[i].note_list[j].event_cd = t_rec->doc_list[2].event_cd)
				set t_rec->qual[i].note_2_disp 		= uar_get_code_display(t_rec->qual[i].note_list[j].event_cd)
				set t_rec->qual[i].note_2_dt_tm 	= t_rec->qual[i].note_list[j].event_date
				set t_rec->qual[i].note_2_status 	= uar_get_code_display(t_rec->qual[i].note_list[j].result_status_cd)
			elseif (t_rec->qual[i].note_list[j].event_cd = t_rec->doc_list[3].event_cd)
				set t_rec->qual[i].note_3_disp 		= uar_get_code_display(t_rec->qual[i].note_list[j].event_cd)
				set t_rec->qual[i].note_3_dt_tm 	= t_rec->qual[i].note_list[j].event_date
				set t_rec->qual[i].note_3_status 	= uar_get_code_display(t_rec->qual[i].note_list[j].result_status_cd)
			endif
		endfor
	endif
endfor

call writeLog(build2("* END   Formatting Data   ************************************"))

call writeLog(build2("* START Generating Output   ************************************"))

select into $OUTDEV
	 p1.name_full_formatted
	,appt_location = uar_get_code_description(t_rec->qual[d1.seq].appt_location_cd)
	,appt_dt_tm = format(t_rec->qual[d1.seq].appt_dt_tm,";;q")
	,sort_dt_tm = t_rec->qual[d1.seq].appt_dt_tm
	,fin = substring(1,15,t_rec->qual[d1.seq].fin)
	,patient = trim(substring(1,60,p.name_full_formatted))
;	,document = uar_get_code_display(t_rec->qual[d1.seq].note_list[d2.seq].event_cd)
;	,status = uar_get_code_display(t_rec->qual[d1.seq].note_list[d2.seq].result_status_cd)
;	,note_dt_tm = format(t_rec->qual[d1.seq].note_list[d2.seq].event_date,";;q")
	,note_a 		= substring(1,40,t_rec->qual[d1.seq].note_1_disp)
	,note_a_dt 		= format(t_rec->qual[d1.seq].note_1_dt_tm,";;q")
	,note_a_status 	= substring(1,20,t_rec->qual[d1.seq].note_1_status)
	,note_b 		= substring(1,40,t_rec->qual[d1.seq].note_2_disp)
	,note_b_dt 		= format(t_rec->qual[d1.seq].note_2_dt_tm,";;q")
	,note_b_status 	= substring(1,20,t_rec->qual[d1.seq].note_2_status)
	,note_c 		= substring(1,40,t_rec->qual[d1.seq].note_3_disp)
	,note_c_dt 		= format(t_rec->qual[d1.seq].note_3_dt_tm,";;q")
	,note_c_status 	= substring(1,20,t_rec->qual[d1.seq].note_3_status)

from
	 (dummyt d1 with seq = t_rec->cnt)
	;,(dummyt d2 with seq = 1)
	,prsnl p1
	,encounter e
	,person p
plan d1
	;where maxrec(d2,t_rec->qual[d1.seq].note_cnt)
;join d2
join e
	where e.encntr_id = t_rec->qual[d1.seq].encntr_id
join p
	where p.person_id = e.person_id
join p1
	where p1.person_id = t_rec->qual[d1.seq].prsnl_id
order by
	 p1.name_full_formatted
	,sort_dt_tm
with nocounter,format,separator=" "

call writeLog(build2("* END   Generating Output   ************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   ************************************"))
call writeLog(build2("* END   Custom   ************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call exitScript(null)
call echorecord(t_rec)
call echorecord(code_values)
call echorecord(program_log)


end
go