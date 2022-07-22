/*****************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
******************************************************************************************
	Author:				Dan Herren
	Date Written:		August 2021
	Solution:
	Source file name:	cov_report_folder_executes.prg
	Object name:		cov_report_folder_executes
	CR#:				6469
 
	Program purpose:	List Users who ran reports from the 'Surgery Schedule' folder
						within the date-range selected.
	Executing from:		CCL
 
 
******************************************************************************************
*  	GENERATED MODIFICATION CONTROL LOG
*
*  	Revision #   Mod Date    Developer             Comment
*  	-----------  ----------  --------------------  ---------------------------------------
*
*
******************************************************************************************/
 
drop   program cov_report_folder_executes:DBA go
create program cov_report_folder_executes:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
 
with OUTDEV, START_DATETIME_PMPT, END_DATETIME_PMPT, FOLDER_PMPT
 
 
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
		2 folder_name       = vc
		2 report_type      	= vc
		2 report_name      	= vc
		2 report_file_name	= vc
		2 prompt_selections	= vc
		2 position			= vc
		2 user				= vc
		2 username			= vc
		2 run_dt			= dq8
		2 application		= vc
		2 report_event_id	= f8
)
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare SURG_SCH_FOLDER_VAR	= vc with noconstant("596406")
;
declare OPR_FOLDER_VAR		= vc with noconstant(fillstring(1000," "))
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
 
; SET DATES VARIABLES TO RECORD STRUCTURE
set rec->startdate = format(START_DATETIME_VAR, "mm/dd/yyyy;;q")
set rec->enddate   = format(END_DATETIME_VAR, "mm/dd/yyyy;;q")
 
;**************************************************************
; SET FACILITY PROMPT VARIABLE
;**************************************************************
if(substring(1,1,reflect(parameter(parameter2($FOLDER_PMPT),0))) = "L")		;multiple values were selected
	set OPR_FOLDER_VAR = "in"
elseif(parameter(parameter2($FOLDER_PMPT),1)= 0.00)							;all (any) values were selected
	set OPR_FOLDER_VAR = "!="
else																		;a single value was selected
	set OPR_FOLDER_VAR = "="
endif
 
 
;==============================================================================
; MAIN DATA SELECT
;==============================================================================
call echo(build("*** MAIN DATA SELECT ***"))
select into "NL:"
	 folder_name 		= f.da_folder_name
	,report_type 		=
		if(cra.object_type = "BOREPORT") "PowerInsight"
			elseif (cra.object_type = "REPORT") "CCL Report"
			elseif (cra.object_type = "CCLREPORT") "CCL Report"
			elseif (cra.object_type = "DAREPORT") "DA2 Report"
			elseif (cra.object_type = "QUERY") "QUERY"
			elseif (cra.object_type = "PDF") "PDF"
			elseif (cra.object_type = "OPSREPORT") "OPSREPORT"
			elseif (cra.object_type = "DADOCUMENT") "DADOCUMENT"
			elseif (cra.object_type = "PRINTREPORT") "PRINTREPORT"
			elseif (cra.object_type = "DADATACUBE") "DADATACUBE"
			elseif (cra.object_type = "EXPORTREPORT") "EXPORTREPORT"
			elseif (cra.object_type = "REQUEST") "REQUEST"
			elseif (cra.object_type = "HTML") "HTML"
			else "Other" ;uar_get_code_display(r.report_type_cd)
		endif
	,report_name 		= if(frr.report_alias_name = null) r.report_name else frr.report_alias_name endif
	,report_file_name	= r.report_name
	,prompt_selections	= cra.object_params
	,position 			= uar_get_code_display(pl.position_cd)
	,user 				= pl.name_full_formatted
	,username 			= cnvtlower(pl.username)
	,run_dt 			= cra.updt_dt_tm
	,application 		= a.description
	,report_event_id	= cra.report_event_id
 
from CCL_REPORT_AUDIT cra
 
	,(inner join APPLICATION a on a.application_number = cra.application_nbr
		and a.active_ind = 1)
 
	,(inner join DA_REPORT r on cnvtupper(cra.object_name) = cnvtupper(r.report_name) ;cra.object_name = r.report_name)
		and r.active_ind = 1)
 
	,(inner join DA_FOLDER_REPORT_RELTN frr on frr.da_report_id = r.da_report_id)
 
	,(inner join DA_FOLDER f on f.da_folder_id = frr.da_folder_id
;		and operator(f.da_folder_id, OPR_FOLDER_VAR, $FOLDER_PMPT)
		and f.da_folder_id = SURG_SCH_FOLDER_VAR ;596406 Surgery Schedule Folder
		and f.public_ind = 1)
 
	,(inner join PRSNL pl on pl.person_id = cra.updt_id
		and pl.active_ind = 1)
 
where cra.object_type in ("CCLREPORT", "BOREPORT", "DAREPORT") ;, "REPORT", "QUERY", "PDF")
	and cra.updt_dt_tm between cnvtdatetime(START_DATETIME_VAR) and cnvtdatetime(END_DATETIME_VAR)
;	and cra.object_name in ("COV_WH_*")   ;report name
;	and pl.name_last_key = "HERREN"
 
order by report_event_id
 
head report
	cnt = 0
 
detail
	cnt = cnt + 1
 
	if (mod(cnt,10) = 1 or cnt = 10)
		stat = alterlist(rec->list,cnt + 9)
	endif
 
 	rec->rec_cnt = cnt
 
	rec->list[cnt].folder_name			= folder_name
	rec->list[cnt].report_type			= report_type
	rec->list[cnt].report_name     		= report_name
	rec->list[cnt].report_file_name		= report_file_name
	rec->list[cnt].prompt_selections	= prompt_selections
	rec->list[cnt].position				= position
	rec->list[cnt].user					= user
	rec->list[cnt].username				= username
	rec->list[cnt].run_dt				= run_dt
	rec->list[cnt].application			= application
	rec->list[cnt].report_event_id		= report_event_id
 
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
 
	select distinct into value($OUTDEV)
 
		 folder_name		= substring(1,50,rec->list[d.seq].folder_name)
		,report_type		= substring(1,30,rec->list[d.seq].report_type)
		,report_name	   	= substring(1,50,rec->list[d.seq].report_name)
;		,report_file_name	= substring(1,50,rec->list[d.seq].report_file_name)
;		,prompt_selections	= substring(1,99,rec->list[d.seq].prompt_selections)
		,user_position		= substring(1,50,rec->list[d.seq].position)
		,user_fullname		= substring(1,30,rec->list[d.seq].user)
		,username			= substring(1,30,rec->list[d.seq].username)
		,run_datetime		= format(rec->list[d.seq].run_dt, "mm/dd/yyyy hh:mm;;q")
;		,application		= substring(1,50,rec->list[d.seq].application)
;		,report_event_id    = rec->list[d.seq].report_event_id
;		,exe_username 		= rec->exe_username
;		,exe_position 		= rec->exe_position
;		,exe_position_cd 	= rec->exe_position_cd
 
	from
		 (DUMMYT d  with seq = value(size(rec->list,5)))
 
	plan d
 
	order by folder_name, report_type, report_name, user_position, user_fullname, run_datetime desc;;, rec->list[d.seq].report_event_id
 
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
 
