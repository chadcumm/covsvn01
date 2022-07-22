/*****************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
******************************************************************************************
	Author:				Dan Herren
	Date Written:		August 2021
	Solution:
	Source file name:	cov_peri_terminated_docs.prg
	Object name:		cov_peri_terminated_docs
	CR#:				6463
 
	Program purpose:
 
	Executing from:		CCL
 
 
******************************************************************************************
*  	GENERATED MODIFICATION CONTROL LOG
*
*  	Revision #   Mod Date    Developer             Comment
*  	-----------  ----------  --------------------  ---------------------------------------
*
*
******************************************************************************************/
 
drop   program cov_peri_terminated_docs:DBA go
create program cov_peri_terminated_docs:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Surgery Area" = 0
 
with OUTDEV, START_DATETIME_PMPT, END_DATETIME_PMPT, SURG_AREA_PMPT
 
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
Record rec (
	1 rec_cnt				= i4
	1 exe_username          = vc
	1 exe_position			= vc
	1 exe_position_cd		= f8
	1 startdate         	= vc
	1 enddate          	 	= vc
	1 list[*]
		2 surg_area			= vc
		2 scheduled_dt      = dq8
		2 case_number      	= vc
		2 doc_type      	= vc
		2 terminated_reason	= vc
		2 terminate_dt		= dq8
		2 terminated_by		= vc
		2 surg_case_id		= f8
)
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
;declare SURG_SCH_FOLDER_VAR	= vc with noconstant("596406")
;
declare OPR_SURGAREA_VAR	= vc with noconstant(fillstring(1000," "))
;
declare initcap()          	= c100
;
declare	START_DATETIME_VAR	= f8
declare END_DATETIME_VAR	= f8
 
 
/**************************************************************
; DVDev START CODING
**************************************************************/
;GET USERNAME FOR REPORT
select into "NL:"
from
	PRSNL p
where p.person_id = reqinfo->updt_id
detail
	rec->exe_username 		= p.username
	rec->exe_position 		= uar_get_code_display(p.position_cd)
	rec->exe_position_cd	= p.position_cd
with nocounter
 
 
;**************************************************************
; SET DATE-RANGE VARIABLES
;**************************************************************
set START_DATETIME_VAR = cnvtdatetime($START_DATETIME_PMPT)
set END_DATETIME_VAR   = cnvtdatetime($END_DATETIME_PMPT)
 
; SET DATE VARIABLES FOR *****  MANUAL TESTING  *****
;set START_DATETIME_VAR = CNVTDATETIME("01-JUL-2021 00:00")
;set END_DATETIME_VAR   = CNVTDATETIME("31-JUL-2021 23:59")
 
; SET DATE-RANGE VARIABLES TO RECORD STRUCTURE
set rec->startdate = format(START_DATETIME_VAR, "mm/dd/yyyy;;q")
set rec->enddate   = format(END_DATETIME_VAR, "mm/dd/yyyy;;q")
 
 
;**************************************************************
; SET FACILITY PROMPT VARIABLE
;**************************************************************
if(substring(1,1,reflect(parameter(parameter2($SURG_AREA_PMPT),0))) = "L")	;multiple values were selected
	set OPR_SURGAREA_VAR = "in"
elseif(parameter(parameter2($SURG_AREA_PMPT),1)= 0.00)						;all (any) values were selected
	set OPR_SURGAREA_VAR = "!="
else																		;a single value was selected
	set OPR_SURGAREA_VAR = "="
endif
 
 
;==============================================================================
; MAIN DATA SELECT
;==============================================================================
call echo(build("*** MAIN DATA SELECT ***"))
select
	 surg_area 			= uar_get_code_description(pd.surg_area_cd)
	,scheduled_dt 		= sc.sched_start_dt_tm
    ,case_number 		= sc.surg_case_nbr_formatted
    ,doc_type 			= uar_get_code_display(pd.doc_type_cd)
    ,terminated_reason	= uar_get_code_description(pd.doc_term_reason_cd)
    ,terminate_dt	 	= pd.doc_term_dt_tm
    ,terminated_by 		= pl.name_full_formatted
	,surg_case_id		= sc.surg_case_id
 
from SURGICAL_CASE sc
 
    ,(inner join PERIOPERATIVE_DOCUMENT pd on pd.surg_case_id = sc.surg_case_id
		and pd.doc_term_dt_tm is not null)
 
    ,(inner join PRSNL pl on pl.person_id = pd.doc_term_by_id
		and pl.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
		and pl.active_ind = 1)
 
where sc.sched_start_dt_tm between cnvtdatetime(START_DATETIME_VAR) and cnvtdatetime(END_DATETIME_VAR)
;    and sc.surg_case_nbr_formatted = "LCMOR-2018-128"
 
order by surg_case_id
 
head report
	cnt = 0
 
detail
	cnt = cnt + 1
 
	if (mod(cnt,10) = 1 or cnt = 10)
		stat = alterlist(rec->list,cnt + 9)
	endif
 
 	rec->rec_cnt = cnt
 
	rec->list[cnt].surg_area			= surg_area
	rec->list[cnt].scheduled_dt			= scheduled_dt
	rec->list[cnt].case_number			= case_number
	rec->list[cnt].doc_type     		= doc_type
	rec->list[cnt].terminated_reason	= terminated_reason
	rec->list[cnt].terminate_dt			= terminate_dt
	rec->list[cnt].terminated_by		= terminated_by
	rec->list[cnt].surg_case_id			= surg_case_id
 
foot report
	stat = alterlist(rec->list, cnt)
 
with nocounter
 
;call echorecord(rec)
;go to exitscript
 
 
;============================
; REPORT OUTPUT
;============================
call echo("*** GENERATING OUTPUT  ***")
 
if (rec->rec_cnt > 0)
 
	select into value($OUTDEV)
		 surg_area		   	= substring(1,50,rec->list[d.seq].surg_area)
		,scheduled_dt		= format(rec->list[d.seq].scheduled_dt, "mm/dd/yyyy hh:mm;;q")
		,case_number		= substring(1,20,rec->list[d.seq].case_number)
		,doc_type			= substring(1,20,rec->list[d.seq].doc_type)
		,terminated_reason	= substring(1,50,rec->list[d.seq].terminated_reason)
		,terminate_dt		= format(rec->list[d.seq].terminate_dt, "mm/dd/yyyy hh:mm;;q")
		,terminated_by		= substring(1,30,rec->list[d.seq].terminated_by)
;		,surg_case_id	    = rec->list[d.seq].surg_case_id
;		,exe_username 		= rec->exe_username
;		,exe_position 		= rec->exe_position
;		,exe_position_cd 	= rec->exe_position_cd
 
	from
		 (DUMMYT d  with seq = value(size(rec->list,5)))
 
	plan d
 
	order by surg_area, scheduled_dt desc, case_number, rec->list[d.seq].surg_case_id
 
	with nocounter, format, check, separator = " "
 
else
 
	select into $OUTDEV
	from DUMMYT d
 
	head report
		call center("No records found for parameter input.",0,150)
 
	with nocounter
 
endif
 
#exitscript
end
go
 
