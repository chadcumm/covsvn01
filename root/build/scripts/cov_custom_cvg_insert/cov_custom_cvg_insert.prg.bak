/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		03/30/2020
	Solution:			
	Source file name:	cov_custom_cvg_insert.prg
	Object name:		cov_custom_cvg_insert
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

drop program cov_custom_cvg_insert:dba go
create program cov_custom_cvg_insert:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "PARENT_CODE_VALUE" = 0
	, "CHILD_CODE_VALUE" = 0 

with OUTDEV, PARENT_CODE_VALUE, CHILD_CODE_VALUE

/*
 <appid>4170105</appid>
       <taskid>4170150</taskid>
       <stepid>4171653</stepid>
       <cpmprocess>0</cpmprocess>
       <origstepid>4171653</origstepid>
       <deststepid>4171653</deststepid>
    </input>
    <properties>
       <propList>
          <propName>Crm.LogLevel</propName>
          <propValue>4</propValue>
       </propList>
       <propList>
          <propName>Cpm.RequestName</propName>
          <propValue>core_get_cd_value_group_by_cd</propValue>

 <appid>4170105</appid>
       <taskid>4170151</taskid>
       <stepid>4171659</stepid>
       <cpmprocess>0</cpmprocess>
       <origstepid>4171659</origstepid>
       <deststepid>4171659</deststepid>
    </input>
    <properties>
       <propList>
          <propName>Crm.LogLevel</propName>
          <propValue>4</propValue>
       </propList>
       <propList>
          <propName>Cpm.RequestName</propName>
          <propValue>core_ens_cd_value_group</propValue>


    <cd_value_grp_list>
       <action_type_flag>1</action_type_flag>
       <child_code_value>3153187983</child_code_value>
       <code_set>100522</code_set>
       <collation_seq>0</collation_seq>
       <parent_code_value>3153187933</parent_code_value>
    </cd_value_grp_list>

*/

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

free record 4171653req
record 4171653req (
  1 code_value = f8   
) 

free record 4171659req
record 4171659req (
  1 cd_value_grp_list [*]   
    2 action_type_flag = i2   
    2 child_code_value = f8   
    2 code_set = i4   
    2 collation_seq = i4   
    2 parent_code_value = f8   
) 


set reply->status_data.status = "F"

call set_codevalues(null)
call check_ops(null)

free set t_rec
record t_rec
(
	1 cnt					= i4
	1 parent_code_set		= i4
	1 parent_code_value		= f8
	1 parent_display		= vc
	1 parent_description	= vc
	1 parent_definition		= vc
	1 child_code_set		= i4
	1 child_code_value		= f8
	1 child_display			= vc
	1 child_description		= vc
	1 child_definition		= vc
)

set t_rec->parent_code_value = 	$PARENT_CODE_VALUE
set t_rec->child_code_value = 	$CHILD_CODE_VALUE

if (t_rec->parent_code_value <= 0)
	set reply->status_data.status = "Z"
	set reply->status_data.subeventstatus.operationname = "PARENT_CODE_VALUE"
	set reply->status_data.subeventstatus.operationstatus = "Z"
	set reply->status_data.subeventstatus.targetobjectname = "PARENT_CODE_VALUE"
	set reply->status_data.subeventstatus.targetobjectvalue = "Value from prompt is empty"
	go to exit_script
endif

if (t_rec->child_code_value <= 0)
	set reply->status_data.status = "Z"
	set reply->status_data.subeventstatus.operationname = "CHILD_CODE_VALUE"
	set reply->status_data.subeventstatus.operationstatus = "Z"
	set reply->status_data.subeventstatus.targetobjectname = "CHILD_CODE_VALUE"
	set reply->status_data.subeventstatus.targetobjectvalue = "Value from prompt is empty"
	go to exit_script
endif



;call addEmailLog("chad.cummings@covhlth.com")

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Getting Code Value   *******************************"))
select into "nl:"
from
	 code_value cv
plan cv
	where cv.code_value = t_rec->parent_code_value
order by
	cv.code_value
head report
	row +0
head cv.code_value
	t_rec->parent_code_set	= cv.code_set
	t_rec->parent_definition	= cv.definition
	t_rec->parent_description = cv.description
	t_rec->parent_display = cv.display
with nocounter

select into "nl:"
from
	 code_value cv
plan cv
	where cv.code_value = t_rec->child_code_value
order by
	cv.code_value
head report
	row +0
head cv.code_value
	t_rec->child_code_set	= cv.code_set
	t_rec->child_definition	= cv.definition
	t_rec->child_description = cv.description
	t_rec->child_display = cv.display
with nocounter

call writeLog(build2("* END   Getting Code Value *********************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Getting Code Grouping   *******************************"))

set stat = initrec(4171653req)
set 4171653req->code_value = t_rec->parent_code_value
set stat = tdbexecute(4170105,4170150,4171653,"REC",4171653req,"REC",4171653rep)
if  (4171653rep->status_data.status = "F")
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "4171653req"
	set reply->status_data.subeventstatus.operationstatus = "Z"
	set reply->status_data.subeventstatus.targetobjectname = "4171653req"
	set reply->status_data.subeventstatus.targetobjectvalue = "Code Value group check failed"
	go to exit_script
endif
call echorecord(4171653rep)
set stat = initrec(4171659req)
set j = 0
/*
if (4171653rep->status_data.status = "S")
	for (i=1 to size(4171653rep->cd_value_grp_list,5))
		set stat = alterlist(4171659req->cd_value_grp_list,i)
		set 4171659req->cd_value_grp_list[i].action_type_flag = 1
		set 4171659req->cd_value_grp_list[i].child_code_value = 4171653rep->cd_value_grp_list[i].child_code_value
		set 4171659req->cd_value_grp_list[i].code_set = 4171653rep->cd_value_grp_list[i].code_set
		set 4171659req->cd_value_grp_list[i].collation_seq = 4171653rep->cd_value_grp_list[i].collation_seq
		set 4171659req->cd_value_grp_list[i].parent_code_value = t_rec->parent_code_value
		set j = i
		call echo(build("i=",i))
	endfor
	call echo("exiting loop with record")
	call echorecord(4171659req)
endif

set j = size(4171653rep->cd_value_grp_list,5)
*/
set j = (j + 1)
call echo(build("j=",j))
set stat = alterlist(4171659req->cd_value_grp_list,j)
set 4171659req->cd_value_grp_list[j].action_type_flag = 1
set 4171659req->cd_value_grp_list[j].child_code_value = t_rec->child_code_value
set 4171659req->cd_value_grp_list[j].code_set = t_rec->child_code_set
set 4171659req->cd_value_grp_list[j].collation_seq = 0
set 4171659req->cd_value_grp_list[j].parent_code_value = t_rec->parent_code_value
call echo("adding new record")
call echorecord(4171659req)
set stat = tdbexecute(4170105,4170151,4171659,"REC",4171659req,"REC",4171659rep)
call echorecord(4171659rep)
/*
    <cd_value_grp_list>
       <action_type_flag>1</action_type_flag>
       <child_code_value>3153187983</child_code_value>
       <code_set>100522</code_set>
       <collation_seq>0</collation_seq>
       <parent_code_value>3153187933</parent_code_value>
    </cd_value_grp_list>

RECORD reply (
   1 cd_value_grp_list [* ]
     2 child_code_value = f8
     2 code_set = i4
     2 collation_seq = i4
     2 display = c40
     2 description = vc
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 */


/*
else
	set reply->status_data.status = "Z"
	set reply->status_data.subeventstatus.operationname = "FIELD_VALUE"
	set reply->status_data.subeventstatus.operationstatus = "Z"
	set reply->status_data.subeventstatus.targetobjectname = "FIELD_VALUE"
	set reply->status_data.subeventstatus.targetobjectvalue = "Value already exists"
	go to exit_script
endif
*/
call writeLog(build2("* END   Getting Code Value *********************************"))
call writeLog(build2("************************************************************"))

set reply->status_data.status = "S"

#exit_script
call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
