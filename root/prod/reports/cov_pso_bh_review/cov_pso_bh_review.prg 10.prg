drop program cov_pso_bh_review go
create program cov_pso_bh_review

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to. 

with OUTDEV



select into $OUTDEV
	 oc.description
	,facility=trim(uar_Get_code_display(e.loc_facility_cd))
	,unit=trim(uar_get_code_display(e.loc_nurse_unit_cd))
	,ea.alias
	,reg_dt_tm = trim(format(e.reg_dt_tm,";;q"))
	,disch_dt_tm = trim(format(e.disch_dt_tm,";;q"))
	,encntr_status = trim(uar_Get_code_display(e.encntr_status_cd))
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



	,order_catalog oc



	,encounter e



	,encntr_alias ea



	,person p



	,order_action oa



	,order_notification onn



	,prsnl p1



	,prsnl p2



	,prsnl p3



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
with outerjoin = d1, format, seperator = " ",nocounter
end 
go
