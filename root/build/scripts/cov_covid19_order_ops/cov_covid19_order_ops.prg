/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		03/30/2020
	Solution:			
	Source file name:	cov_covid19_order_ops.prg
	Object name:		cov_covid19_order_ops
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
001     08/13/2020  Chad Cummings			Removed discharge requirement per Amb team
******************************************************************************/

drop program cov_covid19_order_ops:dba go
create program cov_covid19_order_ops:dba

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

set reply->status_data.status = "F"

call set_codevalues(null)
call check_ops(null)

free set t_rec
record t_rec
(
	1 cnt				= i4
	1 order_cat_cnt		= i2
	1 order_cat_qual[*]
	 2 catalog_cd		= f8
	 2 description		= vc
	1 order_cnt			= i2
	1 order_qual[*]
	 2 order_id			= f8
	 2 encntr_id		= f8
	 2 loc_facility_cd	= f8
	 2 facility			= vc
	 2 fin				= vc
	 2 orig_order_dt_tm	= dq8
	 2 disch_dt_tm		= dq8
	 2 reg_dt_tm		= dq8 ;001
	 2 status 			= c1
)

call addEmailLog("chad.cummings@covhlth.com")

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Order Catalog ******************************"))
select into "nl:"
from
	order_catalog oc
plan oc
	where oc.active_ind = 1
	and   oc.description = "COVID 19 POC Lab 87635"
order by
	 oc.description
	,oc.catalog_cd
head oc.catalog_cd
	t_rec->order_cat_cnt = (t_rec->order_cat_cnt + 1)
	stat = alterlist(t_rec->order_cat_qual,t_rec->order_cat_cnt)
	t_rec->order_cat_qual[t_rec->order_cat_cnt].catalog_cd = oc.catalog_cd
	t_rec->order_cat_qual[t_rec->order_cat_cnt].description = oc.description
with nocounter

if (t_rec->order_cat_cnt = 0)
	set program_log->display_on_exit = 1
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "ORDER_CATALOG"
	set reply->status_data.subeventstatus.operationstatus = "F"
	set reply->status_data.subeventstatus.targetobjectname = "ORDER_CATALOG"
	set reply->status_data.subeventstatus.targetobjectvalue = "No order catalog data was found"
	go to exit_script
endif

call writeLog(build2("* END   Finding Order Catalog ******************************"))
call writeLog(build2("************************************************************"))



call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Orders *************************************"))

select into "nl:"
from
	  orders o
	 ,task_activity ta
	 ,encounter e
	 ,encntr_alias ea
	 ,(dummyt d1 with seq=t_rec->order_cat_cnt)
plan d1
join o
	where o.catalog_cd = t_rec->order_cat_qual[d1.seq].catalog_cd
	and   o.order_status_cd = value(uar_get_code_by("MEANING",6004,"ORDERED"))
join ta
	where ta.order_id = o.order_id
	and   ta.task_status_cd = value(uar_get_code_by("MEANING",79,"COMPLETE"))
	and   ta.task_status_reason_cd = value(uar_get_code_by("MEANING",14024,"DCP_CHART"))
join e
	where e.encntr_id = o.encntr_id
	;001 and   e.encntr_status_cd = value(uar_get_code_by("MEANING",261,"DISCHARGED"))
join ea
	where ea.encntr_id = e.encntr_id
	and   ea.active_ind = 1
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
order by
	o.order_id
head report
	row +0
head o.order_id
	t_rec->order_cnt = (t_rec->order_cnt +1)
	stat = alterlist(t_rec->order_qual,t_rec->order_cnt)
	t_rec->order_qual[t_rec->order_cnt].disch_dt_tm = e.disch_dt_tm
	t_rec->order_qual[t_rec->order_cnt].reg_dt_tm = e.reg_dt_tm ;001
	t_rec->order_qual[t_rec->order_cnt].encntr_id = e.encntr_id
	t_rec->order_qual[t_rec->order_cnt].facility = uar_get_code_display(e.loc_facility_cd)
	t_rec->order_qual[t_rec->order_cnt].fin = cnvtalias(ea.alias,ea.alias_pool_cd)
	t_rec->order_qual[t_rec->order_cnt].loc_facility_cd = e.loc_facility_cd
	t_rec->order_qual[t_rec->order_cnt].order_id = o.order_id
	t_rec->order_qual[t_rec->order_cnt].orig_order_dt_tm = o.orig_order_dt_tm
foot report
	row +0
with nocounter

if (t_rec->order_cnt = 0)
	set program_log->display_on_exit = 1
	set reply->status_data.status = "Z"
	set reply->status_data.subeventstatus.operationname = "ORDERS"
	set reply->status_data.subeventstatus.operationstatus = "Z"
	set reply->status_data.subeventstatus.targetobjectname = "ORDERS"
	set reply->status_data.subeventstatus.targetobjectvalue = "No orders data was found"
	go to exit_script
endif

call writeLog(build2("* END   Finding Orders *************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Inserting ORDER_OPS ********************************"))

for (i=1 to t_rec->order_cnt)
	call writeLog(build2("->adding order_id=",trim(cnvtstring(t_rec->order_qual[i].order_id))))
	insert into order_ops o 
	set  
		 o.order_id = t_rec->order_qual[i].order_id
		,o.ops_flag = 2       
	with nocounter 
	
	if (curqual = 1)
		call writeLog(build2("-->success"))
		set t_rec->order_qual[i].status = "S"
		commit
		;rollback
	else
		call writeLog(build2("-->error"))
		set t_rec->order_qual[i].status = "F"
		rollback
	endif
	 
endfor

call writeLog(build2("* END   Inserting ORDER_OPS ********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))

set audit_header = concat(
								^"Facility"^		,^,^,
								^"FIN"^				,^,^,
								^"Reg DT/TM"^		,^,^, ;001
								^"Discharge DT/TM"^	,^,^,
								^"Order DT/TM"^		,^,^,
								^"ORDER_ID"^		,^,^,
								^"Status"^			,^,^
						)

call writeAudit(audit_header)

for (i=1 to t_rec->order_cnt)
	set audit_line = ""
	set audit_line = concat(
								^"^,trim(t_rec->order_qual[i].facility),^"^,^,^,
								^"^,trim(t_rec->order_qual[i].fin),^"^,^,^,
								^"^,trim(format(t_rec->order_qual[i].reg_dt_tm,";;q")),^"^,^,^, ;001
								^"^,trim(format(t_rec->order_qual[i].disch_dt_tm,";;q")),^"^,^,^,
								^"^,trim(format(t_rec->order_qual[i].orig_order_dt_tm,";;q")),^"^,^,^,
								^"^,trim(cnvtstring(t_rec->order_qual[i].order_id)),^"^,^,^,
								^"^,trim(t_rec->order_qual[i].status),^"^,^,^
							)
	call writeAudit(audit_line)				
endfor

call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))
call echojson(t_rec,program_log->files.filename_log , 1) 

set reply->status_data.status = "S"
set reply->status_data.subeventstatus.operationname = "ORDERS"
set reply->status_data.subeventstatus.operationstatus = "S"
set reply->status_data.subeventstatus.targetobjectname = "ORDERS"
set reply->status_data.subeventstatus.targetobjectvalue = concat(trim(cnvtstring(t_rec->order_cnt))," orders processed")
	
call writeLog(build2("* END   Custom   *******************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
