/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           Perioperative
  Source file name:   cov_freetext_allergy_rpt.prg
  Object name:        cov_freetext_allergy_rpt
  Request #:

  Program purpose:

  Executing from:     CCL

  Special Notes:      Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   03/01/2019  Chad Cummings
******************************************************************************/
drop program cov_freetext_allergy_rpt:dba go
create program cov_freetext_allergy_rpt:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Email" = "" 

with OUTDEV, EMAIL


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
	1 cnt			= i4
	1 qual[*]
	 2 allergy_id			= f8
	 2 encntr_id    		= f8
	 2 person_id    		= f8
	 2 prsnl_id				= f8
	 2 prsnl_name			= vc
	 2 loc_facility_cd 		= f8
	 2 loc_nurse_unit_cd 	= f8
	 2 freetext_allergy 	= vc
	 2 created_dt_tm		= dq8
	 2 status_cd	 		= f8
)

if ($EMAIL > " ")
	call addEmailLog($EMAIL)
endif

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("* START Find Freetext Allergy ************************************"))
select into "nl:"
from
	 allergy a
	,encounter e
	,prsnl p
plan a
	where a.substance_nom_id in(0.0)
	and   a.reaction_status_cd in(
									 code_values->cv.cs_12025.active_cd
									,code_values->cv.cs_12025.proposed_cd
									,code_values->cv.cs_12025.resolved_cd
										
									)
	and   a.active_ind = 1
join e
	where e.encntr_id = a.encntr_id
	and   e.active_ind = 1
join p
	where p.person_id 	= a.orig_prsnl_id
head report
	t_rec->cnt = 0
detail
	t_rec->cnt = (t_rec->cnt + 1)
	stat = alterlist(t_rec->qual,t_rec->cnt)
	t_rec->qual[t_rec->cnt].allergy_id				= a.allergy_id
	t_rec->qual[t_rec->cnt].encntr_id				= e.encntr_id
	t_rec->qual[t_rec->cnt].loc_facility_cd			= e.loc_facility_cd
	t_rec->qual[t_rec->cnt].loc_nurse_unit_cd		= e.loc_nurse_unit_cd
	t_rec->qual[t_rec->cnt].person_id				= e.person_id
	t_rec->qual[t_rec->cnt].prsnl_id				= a.orig_prsnl_id
	t_rec->qual[t_rec->cnt].prsnl_name				= p.name_full_formatted
	t_rec->qual[t_rec->cnt].freetext_allergy		= replace(a.substance_ftdesc,char(10)," ")
	t_rec->qual[t_rec->cnt].freetext_allergy		= replace(t_rec->qual[t_rec->cnt].freetext_allergy,char(13)," ")
	t_rec->qual[t_rec->cnt].freetext_allergy		= replace(t_rec->qual[t_rec->cnt].freetext_allergy,char(44)," ")
	t_rec->qual[t_rec->cnt].created_dt_tm			= a.created_dt_tm
	t_rec->qual[t_rec->cnt].status_cd				= a.reaction_status_cd
with nocounter
call writeLog(build2("* END   Find Freetext Allergy ************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Generating Audit ***********************************"))

set audit_header = build(
							 char(34),^Facility^			,char(34),char(44)
							,char(34),^Unit^				,char(34),char(44)
							,char(34),^Personnel^			,char(34),char(44)
							,char(34),^Freetext Allergy^	,char(34),char(44)
							,char(34),^Status^				,char(34),char(44)
							,char(34),^Created Date/Time^	,char(34),char(44)
							,char(34),^Allergy ID^			,char(34)
						)
call writeAudit(audit_header)

for (i=1 to t_rec->cnt)
	set audit_line = ""
	set audit_line = build(	
						 	 char(34),	trim(uar_get_code_display(t_rec->qual[i].loc_facility_cd))		,char(34),char(44)
							,char(34),	trim(uar_get_code_display(t_rec->qual[i].loc_nurse_unit_cd))	,char(34),char(44)
							,char(34),	trim(t_rec->qual[i].prsnl_name)									,char(34),char(44)
							,char(34),	trim(t_rec->qual[i].freetext_allergy)							,char(34),char(44)
							,char(34),	trim(uar_get_code_display(t_rec->qual[i].status_cd))			,char(34),char(44)
							,char(34),	trim(format(t_rec->qual[i].created_dt_tm,";;q"))				,char(34),char(44)
							,char(34),	trim(cnvtstring(t_rec->qual[i].allergy_id))						,char(34)
							)
	
	call writeAudit(audit_line)
endfor

call writeLog(build2("* END   Generating Auit  ***********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Generating Output **********************************"))
select into $OUTDEV
	 facility=substring(1,30,uar_get_code_display(t_rec->qual[d.seq].loc_facility_cd))
	,unit = substring(1,30,uar_get_code_display(t_rec->qual[d.seq].loc_nurse_unit_cd))
	,prsnl_name = substring(1,50,p.name_full_formatted)
	,allergy = substring(1,100,t_rec->qual[d.seq].freetext_allergy)
	,status = uar_get_code_display(t_rec->qual[d.seq].status_cd)
	,created_dt_tm = format(t_rec->qual[d.seq].created_dt_tm,";;q")
	,t_rec->qual[d.seq].allergy_id
	,sort_dt_tm = t_rec->qual[d.seq].created_dt_tm
from
	(dummyt d with seq=t_rec->cnt)
	,prsnl p
plan d
join p
	where p.person_id = t_rec->qual[d.seq].prsnl_id
order by
	 facility
	,p.name_full_formatted
	,sort_dt_tm
with nocounter, format, seperator = " "

call writeLog(build2("* END   Generating Output **********************************"))
call writeLog(build2("************************************************************"))

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
