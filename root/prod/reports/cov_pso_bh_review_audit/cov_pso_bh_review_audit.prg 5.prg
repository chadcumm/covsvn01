drop program cov_pso_bh_review_audit go
create program cov_pso_bh_review_audit

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
	1 order_cat_cnt = i2
	1 order_cat[*]
	 2 catalog_cd = f8
	1 encntr_cnt = i2
	1 encntr_qual[*]
	 2 order_id = f8
	 2 encntr_id = f8
	 2 notification_id = f8
)

select into "nl:"
from
	order_catalog oc
plan oc
	where oc.description in(
								 "PSO Admit to Senior Behavioral Health"
								,"PSO Admit to Inpatient Rehab"
								,"PSO Admit to Skilled Nursing Facility"
								,"Behavioral Health 30 Day Readmit"
								,"Behavioral Health 30 Day Readmit Involuntary"   
								,"Behavioral Health Emergency Admit"
								,"Behavioral Health Voluntary Admit"
							)
	and oc.active_ind = 1
detail 
	t_rec->order_cat_cnt = (t_rec->order_cat_cnt + 1)
	stat = alterlist(t_rec->order_cat,t_rec->order_cat_cnt)
	t_rec->order_cat[t_rec->order_cat_cnt].catalog_cd = oc.catalog_cd
with nocounter

select into "nl:"
	 facility=trim(uar_Get_code_display(e.loc_facility_cd))
	,unit=trim(uar_get_code_display(e.loc_nurse_unit_cd))

from
	 orders o
	,encounter e
	,encntr_alias ea
	,person p
	,order_action oa
	,order_notification onn
	,prsnl p1
	,prsnl p2
	,prsnl p3
	,(dummyt d1)
plan o
	where expand(i,1,t_rec->order_cat_cnt,oc.catalog_cd,t_rec->order_cat[i].catalog_cd)
join oa
	where oa.order_id = o.order_id
	and   oa.action_type_cd = value(uar_get_code_by("MEANING",6003,"ORDER"))
join p
	where p.person_id = o.person_id
join e
	where e.encntr_id = o.encntr_id
join ea
	where ea.encntr_id = e.encntr_id
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	and   ea.active_ind = 1
join p3
	where p3.person_id = oa.action_personnel_id
join d1
join onn
	where onn.order_id = o.order_id
	and   onn.notification_type_flag = 2
join p1
	where p1.person_id = oa.order_provider_id
join p2
	where p2.person_id = onn.to_prsnl_id
order by
	 facility
	,unit
	,ea.alias
	,e.encntr_id
	,o.orig_order_dt_tm
	,o.order_id
head e.encntr_id
/*
select into "nl:"
	 order_description = trim(oc.description)
	,facility=trim(uar_Get_code_display(e.loc_facility_cd))
	,unit=trim(uar_get_code_display(e.loc_nurse_unit_cd))
	,ea.alias
	,reg_dt_tm = trim(format(e.reg_dt_tm,";;q"))
	,disch_dt_tm = trim(format(e.disch_dt_tm,";;q"))
	,encntr_status = trim(uar_Get_code_display(e.encntr_status_cd))
	,financial_class = trim(uar_get_code_display(e.financial_class_cd))
	,p.name_full_formatted
	,o.orig_order_dt_tm ";;q"
	,birth_dt = trim(format(p.birth_dt_tm,"mm/dd/yyyy;;d"))
	,order_status = trim(uar_get_code_display(o.order_status_cd))
	,order_action_prsnl =trim( p3.name_full_formatted)
	,order_action_position = trim(uar_get_code_display(p3.position_cd))
	,order_action_dt_tm = oa.action_dt_tm ";;q"
	,order_communication_type = uar_get_code_display(oa.communication_type_cd)
	,ordering_provider = p1.name_full_formatted
	,ordering_position = uar_get_code_display(p1.position_cd)
	,cosigned_requested = p2.name_full_formatted
	,cosigned_position = uar_get_code_display(p2.position_cd)
	,cosign_dt_tm = onn.status_change_dt_tm ";;q"
	,cosign_status = if (onn.notification_status_flag = 2)
					     "Completed"
					 elseif(onn.notification_status_flag = 6)
					 	"No Longer Needed due to Withdraw"
					 elseif(onn.notification_status_flag = 3)
					 	"Refused"
					 elseif(onn.notification_status_flag = 1)
					 	"Pending"
					 else
					 	cnvtstring(onn.notification_status_flag)
					 endif
	,o.order_id
	,onn.order_notification_id
from
	 orders o
	,encounter e
	,encntr_alias ea
	,person p
	,order_action oa
	,order_notification onn
	,prsnl p1
	,prsnl p2
	,prsnl p3
	,(dummyt d1)
plan o
	where expand(i
join oa
	where oa.order_id = o.order_id
	and   oa.action_type_cd = value(uar_get_code_by("MEANING",6003,"ORDER"))
join p
	where p.person_id = o.person_id
join e
	where e.encntr_id = o.encntr_id
join ea
	where ea.encntr_id = e.encntr_id
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	and   ea.active_ind = 1
join p3
	where p3.person_id = oa.action_personnel_id
join d1
join onn
	where onn.order_id = o.order_id
	and   onn.notification_type_flag = 2
join p1
	where p1.person_id = oa.order_provider_id
join p2
	where p2.person_id = onn.to_prsnl_id
order by
	 facility
	,unit
	,ea.alias
	,o.orig_order_dt_tm
	,o.order_id
*/

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


call echorecord(t_rec)

end go

