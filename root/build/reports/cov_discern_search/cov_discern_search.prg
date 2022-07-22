/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		03/30/2020
	Solution:			
	Source file name:	cov_discern_search.prg
	Object name:		cov_discern_search
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

drop program cov_discern_search:dba go
create program cov_discern_search:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Search Term" = "" 

with OUTDEV, SEARCH_TERM


call echo(build("loading script:",curprog))
set nologvar = 1	;do not create log = 1		, create log = 0
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
	1 cnt					= i2
	1 search_term			= vc
	1 object_cnt			= i2
	1 object_qual[*]
	 2 objectname 			= vc
     2 objecttype 			= c1
     2 objectgroup 			= i1
)

call addEmailLog("chad.cummings@covhlth.com")

set t_rec->search_term 	= $SEARCH_TERM

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Objects ************************************"))
call writeLog(build2("** Covenant Custom Programs"))

select into "nl:"
from
	(dprotect d)
plan d
	where d.object_name = "COV*"
	and   d.object = "P"
order by
	d.object_name
head report
	call writeLog(build2("->inside dprotect custom program search"))
detail
	t_rec->object_cnt = (t_rec->object_cnt + 1)
	stat = alterlist(t_rec->object_qual,t_rec->object_cnt)
	t_rec->object_qual[t_rec->object_cnt].objectname	= d.object_name
	t_rec->object_qual[t_rec->object_cnt].objectgroup	= d.group
	t_rec->object_qual[t_rec->object_cnt].objecttype	= d.object
foot report
	call writeLog(build2("<-leaving dprotect custom program search"))
with nocounter
  
call writeLog(build2("** All Expert Modules"))

select into "nl:"
from
	(dprotect d)
plan d
	where d.object_name = "*"
	and   d.object = "E"
order by
	d.object_name
head report
	call writeLog(build2("->inside dprotect ekm search"))
detail
	t_rec->object_cnt = (t_rec->object_cnt + 1)
	stat = alterlist(t_rec->object_qual,t_rec->object_cnt)
	t_rec->object_qual[t_rec->object_cnt].objectname	= d.object_name
	t_rec->object_qual[t_rec->object_cnt].objectgroup	= d.group
	t_rec->object_qual[t_rec->object_cnt].objecttype	= d.object
foot report
	call writeLog(build2("<-leaving dprotect ekm search"))
with nocounter

call writeLog(build2("* END   Finding Objects ************************************"))
call writeLog(build2("************************************************************"))



call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call exitScript(null)
call echorecord(t_rec)
call echorecord(code_values)
call echorecord(program_log)


end
go
