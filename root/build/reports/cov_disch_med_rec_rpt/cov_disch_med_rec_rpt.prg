/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		10/01/2020
	Solution:			Perioperative
	Source file name:	cov_disch_med_rec_rpt.prg
	Object name:		cov_disch_med_rec_rpt
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	10/01/2020  Chad Cummings			Initial Release
******************************************************************************/

drop program cov_disch_med_rec_rpt:dba go
create program cov_disch_med_rec_rpt:dba

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

call set_codevalues(null)
call check_ops(null)

free set t_rec
record t_rec
(
	1 cnt			= i4
)

;call addEmailLog("chad.cummings@covhlth.com")

;REVIEW 510000 - RetrieveDischargeReconciliationReport

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   *******************************************"))

select into $OUTDEV
	 location=uar_get_code_display(e.loc_facility_cd)
	,fin=cnvtalias(ea.alias,ea.alias_pool_cd)
	,p.name_full_formatted
	,recon_performed_dt_tm=orn.performed_dt_tm
	,ord.recon_order_action_mean
	,order_type=if (o.orig_ord_as_flag = 0) "Normal Order"
				elseif (o.orig_ord_as_flag = 1) "Prescription/Discharge Order"
				elseif (o.orig_ord_as_flag = 2) "Recorded / Home Meds"
				elseif (o.orig_ord_as_flag = 3) "Patient Owns Meds"
				elseif (o.orig_ord_as_flag = 4) "Pharmacy Charge Only"
				elseif (o.orig_ord_as_flag = 5) "Satellite (Super Bill) Meds"
				endif
	,ord.order_mnemonic
	,ord.simplified_display_line
	,ordering_provider=p1.name_full_formatted
from
	 order_compliance oc
	,order_recon orn
	,order_recon_detail ord
	,orders o
	,order_action oa
	,prsnl p1
	,encounter e
	,person p
	,encntr_alias ea
plan oc
	where oc.performed_dt_tm >= cnvtdatetime(curdate,0)
	and   oc.encntr_compliance_status_flag = 0
join orn
	where orn.encntr_id = oc.encntr_id
	and   orn.recon_type_flag = 3
	;and   orn.recon_status_cd = value(uar_get_code_by("MEANING",4002695,"COMPLETE"))
join ord
	where ord.order_recon_id = orn.order_recon_id
join o
	where o.order_id = ord.order_nbr
join oa
	where oa.order_id = o.order_id
	and   oa.action_type_cd = value(uar_get_code_by("MEANING",6003,"ORDER"))
join p1
	where p1.person_id = oa.order_provider_id
join e
	where e.encntr_id = oc.encntr_id
join p
	where p.person_id = e.person_id
join ea
	where ea.encntr_id = e.encntr_id
	and   ea.active_ind = 1
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
order by
	location
	,p.name_first_synonym_id
with nocounter,format(date,";;q"),uar_code(d), separator=" ", format

call writeLog(build2("* END   Custom   *******************************************"))
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
