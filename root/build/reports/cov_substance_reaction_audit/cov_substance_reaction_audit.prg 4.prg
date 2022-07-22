/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		   	03/01/2019
	Solution:			Perioperative
	Source file name:	 	cov_substance_reaction_audit.prg
	Object name:		   	cov_substance_reaction_audit
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

drop program cov_substance_reaction_audit:dba go
create program cov_substance_reaction_audit:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Coded or Free Text" = 0 

with OUTDEV, CODED_IND


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
	1 cnt			= i4
)

call addEmailLog("chad.cummings@covhlth.com")

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   ************************************"))

select into $OUTDEV
	 n.source_string
	,count(r.reaction_id)
from
	 reaction r
	,nomenclature n
plan r
	where r.active_ind = 1
	and   r.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   r.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
join n
	where n.nomenclature_id = r.reaction_nom_id
group by
	n.source_string
order by
	1 desc
with format, seperator =" ",nocounter


call writeLog(build2("* END   Custom   ************************************"))
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
