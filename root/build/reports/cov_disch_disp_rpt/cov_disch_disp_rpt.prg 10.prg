/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:					Chad Cummings
	Date Written:		   	03/01/2019
	Solution:			   	
	Source file name:	 	cov_disch_disp_rpt.prg
	Object name:		   	cov_disch_disp_rpt
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

drop program cov_disch_disp_rpt:dba go
create program cov_disch_disp_rpt:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Beginning Discharge Date and Time" = "SYSDATE"
	, "Ending Discharge Date and Time" = "SYSDATE"
	, "Facility" = 0 

with OUTDEV, BEG_DISCH_DT_TM, END_DISCH_DT_TM, FACILITY


call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 1	;do not create audit = 1	, create audit = 0
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
	1 beg_disch_dt_tm	= dq8
	1 end_disch_dt_tm	= dq8
	1 org_cnt			= i4
	1 org_qual[*]
	 2 org_id		= f8
	 2 ord_desc		= vc
	1 cnt			= i4
	1 qual[*]
	 2 encntr_id	= f8
)

call addEmailLog("chad.cummings@covhlth.com")

set t_rec->beg_disch_dt_tm = cnvtdatetime($BEG_DISCH_DT_TM)
set t_rec->end_disch_dt_tm = cnvtdatetime($END_DISCH_DT_TM)

call writeLog(build2("-->t_rec->beg_disch_dt_tm = ",format(t_rec->beg_disch_dt_tm,";;q")))
call writeLog(build2("-->t_rec->end_disch_dt_tm = ",format(t_rec->end_disch_dt_tm,";;q")))

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("* START Adding Organizations   ************************************"))
select into "nl:"
from
     prsnl per
    ,prsnl_org_reltn por
    ,location l
    ,organization org
where
    per.person_id 			= reqinfo->updt_id
    and per.active_ind 		= 1
    and por.person_id 		= per.person_id
    and l.organization_id 	= por.organization_id
    and l.location_type_cd 	= code_values->cv.cs_222.facilitys_cd
    and org.organization_id = l.organization_id    
    and org.org_class_cd 	= code_values->cv.cs_396.org_cd
    and org.organization_id = $FACILITY
order by
     cnvtupper(org.org_name)
    ,org.organization_id 
head org.organization_id	
	t_rec->org_cnt = (t_rec->org_cnt + 1)
	stat = alterlist(t_rec->org_qual,t_rec->org_cnt)
	call writeLog(build2("-->Adding ",trim(cnvtstring(org.organization_id)),":",trim(org.org_name)))
	t_rec->org_qual[t_rec->org_cnt].org_id		= org.organization_id
	t_rec->org_qual[t_rec->org_cnt].ord_desc 	= org.org_name 
with nocounter

if (t_rec->org_cnt <= 0)
	call writeLog(build2("!! ERROR: NO FACILITIES QUALIFIED !!"))
	go to exit_script
endif    
call writeLog(build2("* END   Adding Organizations   ************************************"))

call writeLog(build2("* START Finding Encounters   ************************************"))

select into "nl:"
from
	encounter e
plan e
	where expand(i,1,t_rec->org_cnt,e.organization_id,t_rec->org_qual[i].org_id)
	and   e.disch_dt_tm between cnvtdatetime(t_rec->beg_disch_dt_tm) and cnvtdatetime(t_rec->end_disch_dt_tm)
	and   e.active_ind = 1
order by
	e.encntr_id
head e.encntr_id
	t_rec->cnt = (t_rec->cnt + 1)
	if ( mod(t_rec->cnt,1000) = 1)
		stat = alterlist(t_rec->qual,t_rec->cnt + 999)
	endif	
	t_rec->qual[t_rec->cnt].encntr_id = e.encntr_id
	call writeLog(build2("-->Adding t_rec->qual[",trim(cnvtstring(t_rec->cnt)),"].encntrid=",trim(cnvtstring(e.encntr_id))))  
with nocounter
call writeLog(build2("* END   Finding Encounters   ************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   ************************************"))
call writeLog(build2("* END   Custom   ************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
