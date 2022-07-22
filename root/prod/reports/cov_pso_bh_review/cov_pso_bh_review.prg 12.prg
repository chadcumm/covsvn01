drop program cov_pso_bh_review go
create program cov_pso_bh_review

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to. 

with OUTDEV



select into $OUTDEV
	 order_description = trim(oc.description)
	,facility=trim(uar_Get_code_display(e.loc_facility_cd))
	,unit=trim(uar_get_code_display(e.loc_nurse_unit_cd))
	,ea.alias
	,reg_dt_tm = trim(format(e.reg_dt_tm,"yyyymmdd hh:mm:ss;;q"))
	,disch_dt_tm = trim(format(e.disch_dt_tm,"yyyymmdd hh:mm:ss;;q"))
	,encntr_status = trim(uar_Get_code_display(e.encntr_status_cd))
	,financial_class = trim(uar_get_code_display(e.financial_class_cd))
	,hp.plan_name
	,hp2.plan_name
	,p.name_full_formatted
	,o.orig_order_dt_tm ";;q"
	,birth_dt = trim(format(p.birth_dt_tm,"mm/dd/yyyy;;d"))
	,order_status = trim(uar_get_code_display(o.order_status_cd))
	,order_act_prsnl =trim( p3.name_full_formatted)
	,order_act_position = trim(uar_get_code_display(p3.position_cd))
	,order_act_dt_tm = trim(format(oa.action_dt_tm,"yyyymmdd hh:mm:ss;;q"))
	,order_comm_type = trim(uar_get_code_display(oa.communication_type_cd))
	,ordering_provider = p1.name_full_formatted
	,ordering_position = uar_get_code_display(p1.position_cd)
	,cosigned_requested = p2.name_full_formatted
	,cosigned_position = uar_get_code_display(p2.position_cd)
	,cosign_dt_tm = trim(format(onn.status_change_dt_tm, "yyyymmdd hh:mm:ss;;q"))
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
	,order_catalog oc
	,encounter e
	,encntr_alias ea
	,person p
	,order_action oa
	,order_notification onn
	,prsnl p1
	,prsnl p2
	,prsnl p3
	,encntr_plan_reltn epr
    ,health_plan hp
	,encntr_plan_reltn epr2
    ,health_plan hp2
	,(dummyt d1)
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
	and   oc.active_ind = 1
join o
	where o.catalog_cd = oc.catalog_cd
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
join epr
    where epr.encntr_id = e.encntr_id
    and   epr.active_ind = 1
    and   epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    and   epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    and   epr.priority_seq in(1)
join hp
    where hp.health_plan_id = epr.health_plan_id
    and   hp.active_ind = 1
    and   hp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    and   hp.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
join d1
join onn
	where onn.order_id = o.order_id
	and   onn.notification_type_flag = 2
join p1
	where p1.person_id = oa.order_provider_id
join p2
	where p2.person_id = onn.to_prsnl_id
join epr2
    where epr2.encntr_id = e.encntr_id
    and   epr2.active_ind = 1
    and   epr2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    and   epr2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    and   epr2.priority_seq in(3)
join hp2
    where hp2.health_plan_id = epr.health_plan_id
    and   hp2.active_ind = 1
    and   hp2.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    and   hp2.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
order by
	 facility
	,unit
	,ea.alias
	,o.orig_order_dt_tm
	,o.order_id
with outerjoin = d1, format, seperator = " ",nocounter
end 
go
