drop program cov_active_pso_review go
create program cov_active_pso_review

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to. 

with OUTDEV

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
	1 order_cat_cnt = i2
	1 order_cat[*]
	 2 catalog_cd = f8
	1 encntr_cnt = i2
	1 encntr_qual[*]
	 2 order_id = f8
	 2 encntr_id = f8
	 2 notification_id = f8
	 2 order_description = vc
	 2 facility = vc
	 2 unit = vc
	 2 alias = vc
	 2 reg_dt_tm = dq8
	 2 disch_dt_tm = dq8
	 2 encntr_status = vc
	 2 primary_hp = vc
	 2 secondary_hp = vc
	 2 patient_name = vc
	 2 orig_order_dt_tm = dq8
	 2 birth_dt_tm = dq8
	 2 order_status = vc
	 2 order_action_prsnl = vc
	 2 order_action_position  =vc
	 2 order_action_dt_tm = dq8
	 2 order_communication_type = vc
	 2 ordering_provider = vc
	 2 ordering_position = vc
	 2 cosigned_requested = vc
	 2 cosigned_position = vc
	 2 cosign_dt_tm = dq8
	 2 cosign_status = vc
	 
)


select into "nl:"
from
	order_catalog oc
plan oc
	where oc.catalog_cd in(
	
	 2597237427.0	;PSO Admit to Senior Behavioral Health
	,41013987.0		;Behavioral Health Emergency Admit
	,2552704073.0	;Behavioral Health Voluntary Admit
	,2552704129.0	;Behavioral Health 30 Day Readmit
	,2604739533.0	;Adjustment PSO Admit to PBH
	,2601118453.0	;Adjustment PSO for Senior Behavioral Health
	,2629135923.0	;Behavioral Health 30 Day Readmit Involuntary
	,2629135547.0	;Behavioral Health 30 Day Readmit Voluntary^
	,2562785073.0	;Adjustment PSO Admit to Inpatient
	,4180632.00		;PSO Admit to Inpatient
							)
	and oc.active_ind = 1
detail 
	t_rec->order_cat_cnt = (t_rec->order_cat_cnt + 1)
	stat = alterlist(t_rec->order_cat,t_rec->order_cat_cnt)
	t_rec->order_cat[t_rec->order_cat_cnt].catalog_cd = oc.catalog_cd
	call writeLog(build2("-->description=",trim(oc.description)))
	call writeLog(build2("-->catalog_cd=",trim(cnvtstring(oc.catalog_cd))))
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
plan o
	where expand(i,1,t_rec->order_cat_cnt,o.catalog_cd,t_rec->order_cat[i].catalog_cd)
	and   o.order_status_cd = code_values->cv.cs_6004.ordered_cd
join oa
	where oa.order_id = o.order_id
	and   oa.action_type_cd = code_values->cv.cs_6003.order_cd
join p
	where p.person_id = o.person_id
	and   p.name_last_key != "ZZZTEST"
	and   p.name_last_key != "TTTTEST"
join e
	where e.encntr_id = o.encntr_id
	and   e.encntr_type_cd in(
			 309308.00		;INPATIENT
			,2555137051	;BEHAVIORALHEALTH
			,2555137131	;HOSPITALADOLESCENTPSYCH
			,2555137035	;HOSPITALADULTPSYCH
			,2555137139	;HOSPITALDETOX
			,2555137179	;HOSPITALLATENCY
	
		)
join ea
	where ea.encntr_id = e.encntr_id
	and   ea.encntr_alias_type_cd = code_values->cv.cs_319.fin_nbr_cd
	and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	and   ea.active_ind = 1
order by
	 facility
	,unit
	,ea.alias
	,e.encntr_id
	,o.orig_order_dt_tm desc
	,o.order_id
head e.encntr_id
	call writeLog(build2("-->alias=",trim(ea.alias)))
	call writeLog(build2("-->encntr_id=",trim(cnvtstring(e.encntr_id))))
	t_rec->encntr_cnt = (t_rec->encntr_cnt + 1)
	stat = alterlist(t_rec->encntr_qual,t_rec->encntr_cnt)
	t_rec->encntr_qual[t_rec->encntr_cnt].order_id = o.order_id
	t_rec->encntr_qual[t_rec->encntr_cnt].encntr_id = e.encntr_id
	t_rec->encntr_qual[t_rec->encntr_cnt].birth_dt_tm = p.birth_dt_tm
	t_rec->encntr_qual[t_rec->encntr_cnt].disch_dt_tm = e.disch_dt_tm
	t_rec->encntr_qual[t_rec->encntr_cnt].reg_dt_tm = e.reg_dt_tm
	t_rec->encntr_qual[t_rec->encntr_cnt].encntr_status = uar_Get_code_display(e.encntr_type_cd)
	t_rec->encntr_qual[t_rec->encntr_cnt].facility = uar_get_code_display(e.loc_facility_cd)
	t_rec->encntr_qual[t_rec->encntr_cnt].unit = uar_get_code_display(e.loc_nurse_unit_cd)
	t_rec->encntr_qual[t_rec->encntr_cnt].order_action_dt_tm = oa.action_dt_tm
	t_rec->encntr_qual[t_rec->encntr_cnt].order_communication_type = uar_Get_code_display(oa.communication_type_cd)
	t_rec->encntr_qual[t_rec->encntr_cnt].order_description = o.order_mnemonic
	t_rec->encntr_qual[t_rec->encntr_cnt].order_status = uar_get_code_display(o.order_status_cd)
	t_rec->encntr_qual[t_rec->encntr_cnt].orig_order_dt_tm = o.orig_order_dt_tm
	t_rec->encntr_qual[t_rec->encntr_cnt].patient_name = p.name_full_formatted
	t_rec->encntr_qual[t_rec->encntr_cnt].alias = ea.alias
with nocounter


select into "nl:"
from
	(dummyt d1 with seq=t_rec->encntr_cnt)
	,encntr_plan_reltn epr
	,health_plan hp
plan d1
join epr
    where epr.encntr_id = t_rec->encntr_qual[d1.seq].encntr_id
    and   epr.active_ind = 1
    and   epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    and   epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    and   epr.priority_seq in(1,2)
join hp
    where hp.health_plan_id = epr.health_plan_id
    and   hp.active_ind = 1
    and   hp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
    and   hp.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
    and   hp.financial_class_cd = value(uar_get_code_by("MEANING",354,"MEDICARE"))
order by
	 epr.encntr_id
	,epr.priority_seq
	,epr.beg_effective_dt_tm desc
head epr.encntr_id
	call writeLog(build2("->encntr_id=",trim(cnvtstring(epr.encntr_id))))
head epr.priority_seq
	call writeLog(build2("--->priority_seq=",trim(cnvtstring(epr.priority_seq))))
	case (epr.priority_seq)
		of 1: t_rec->encntr_qual[d1.seq].primary_hp = hp.plan_name
		of 2: t_rec->encntr_qual[d1.seq].secondary_hp = hp.plan_name
	endcase	
foot epr.encntr_id
	call writeLog(build2("----->primary=",trim(t_rec->encntr_qual[d1.seq].primary_hp)))
	call writeLog(build2("----->secondary=",trim(t_rec->encntr_qual[d1.seq].secondary_hp)))
with nocounter

/*
select into $OUTDEV
	 order_description = trim(t_rec->encntr_qual[d1.seq].order_description )
	,facility=trim(t_rec->encntr_qual[d1.seq].facility )
	,unit=trim(t_rec->encntr_qual[d1.seq].unit )
	,alias = trim(t_rec->encntr_qual[d1.seq].alias )
	,reg_dt_tm = trim(format(t_rec->encntr_qual[d1.seq].reg_dt_tm ,";;q"))
	,disch_dt_tm = trim(format(t_rec->encntr_qual[d1.seq].disch_dt_tm ,";;q"))
	,encntr_status = trim(t_rec->encntr_qual[d1.seq].encntr_status )
	,1_hp = trim(substring(1,25,t_rec->encntr_qual[d1.seq].primary_hp ))
	,2_hp = trim(substring(1,25,t_rec->encntr_qual[d1.seq].secondary_hp ))
	,patient_name = trim(substring(1,50,t_rec->encntr_qual[d1.seq].patient_name ))
	,orig_order_dt_tm = trim(format(t_rec->encntr_qual[d1.seq].orig_order_dt_tm , ";;q"))
	,birth_dt = trim(format(t_rec->encntr_qual[d1.seq].birth_dt_tm ,"mm/dd/yyyy;;d"))
	,order_status = trim(substring(1,50,t_rec->encntr_qual[d1.seq].order_status ))
	,order_act_prsnl =trim(substring(1,50,t_rec->encntr_qual[d1.seq].order_action_prsnl  ))
	,order_act_position = trim(substring(1,50,t_rec->encntr_qual[d1.seq].order_action_position ))
	,order_act_dt_tm = trim(format(t_rec->encntr_qual[d1.seq].order_action_dt_tm , ";;q"))
	,order_comm_type = trim(t_rec->encntr_qual[d1.seq].order_communication_type )
	,ordering_provider = trim(t_rec->encntr_qual[d1.seq].ordering_provider )
	,ordering_position = trim(t_rec->encntr_qual[d1.seq].cosigned_requested )
	,cosigned_requested = trim(t_rec->encntr_qual[d1.seq].cosigned_requested )
	,cosigned_position = trim(substring(1,50,t_rec->encntr_qual[d1.seq].cosigned_position ))
	,cosign_dt_tm = trim(format( t_rec->encntr_qual[d1.seq].cosign_dt_tm ,";;q"))
	,cosign_status = trim(substring(1,50,t_rec->encntr_qual[d1.seq].cosign_status ))
	,order_id = t_rec->encntr_qual[d1.seq].order_id 
	,encntr_id = t_rec->encntr_qual[d1.seq].encntr_id 
	,order_notification_id = t_rec->encntr_qual[d1.seq].notification_id 
from
(dummyt d1 with seq=t_rec->encntr_cnt)
plan d1

order by
	 facility
	,unit
	,alias
	,orig_order_dt_tm
	,order_id
with format,seperator = " ",nocounter
*/
SELECT INTO $OUTDEV
	ENCNTR_QUAL_ORDER_ID = T_REC->encntr_qual[D1.SEQ].order_id
	, ENCNTR_QUAL_ENCNTR_ID = T_REC->encntr_qual[D1.SEQ].encntr_id
	, ENCNTR_QUAL_ORDER_DESCRIPTION = SUBSTRING(1, 30, T_REC->encntr_qual[D1.SEQ].order_description)
	, ENCNTR_QUAL_FACILITY = SUBSTRING(1, 30, T_REC->encntr_qual[D1.SEQ].facility)
	, ENCNTR_QUAL_UNIT = SUBSTRING(1, 30, T_REC->encntr_qual[D1.SEQ].unit)
	, ENCNTR_QUAL_ALIAS = SUBSTRING(1, 30, T_REC->encntr_qual[D1.SEQ].alias)
	, ENCNTR_QUAL_REG_DT_TM = format(T_REC->encntr_qual[D1.SEQ].reg_dt_tm,";;q")
	, ENCNTR_QUAL_DISCH_DT_TM =format( T_REC->encntr_qual[D1.SEQ].disch_dt_tm,";;q")
	, ENCNTR_QUAL_ENCNTR_STATUS = SUBSTRING(1, 30, T_REC->encntr_qual[D1.SEQ].encntr_status)
	, ENCNTR_QUAL_PRIMARY_HP = SUBSTRING(1, 30, T_REC->encntr_qual[D1.SEQ].primary_hp)
	, ENCNTR_QUAL_SECONDARY_HP = SUBSTRING(1, 30, T_REC->encntr_qual[D1.SEQ].secondary_hp)
	, ENCNTR_QUAL_PATIENT_NAME = SUBSTRING(1, 30, T_REC->encntr_qual[D1.SEQ].patient_name)
	, ENCNTR_QUAL_ORIG_ORDER_DT_TM =format( T_REC->encntr_qual[D1.SEQ].orig_order_dt_tm,";;q")
	, ENCNTR_QUAL_BIRTH_DT_TM = format(T_REC->encntr_qual[D1.SEQ].birth_dt_tm,";;q")
	, ENCNTR_QUAL_ORDER_STATUS = SUBSTRING(1, 30, T_REC->encntr_qual[D1.SEQ].order_status)
	, ENCNTR_QUAL_ORDER_ACTION_PRSNL = SUBSTRING(1, 30, T_REC->encntr_qual[D1.SEQ].order_action_prsnl)
	, ENCNTR_QUAL_ORDER_ACTION_POSITION = SUBSTRING(1, 30, T_REC->encntr_qual[D1.SEQ].order_action_position)
	, ENCNTR_QUAL_ORDER_ACTION_DT_TM =format( T_REC->encntr_qual[D1.SEQ].order_action_dt_tm,";;q")
	, ENCNTR_QUAL_ORDER_COMMUNICATION_TYPE = SUBSTRING(1, 30, T_REC->encntr_qual[D1.SEQ].order_communication_type)
	, ENCNTR_QUAL_ORDERING_PROVIDER = SUBSTRING(1, 30, T_REC->encntr_qual[D1.SEQ].ordering_provider)
	, ENCNTR_QUAL_ORDERING_POSITION = SUBSTRING(1, 30, T_REC->encntr_qual[D1.SEQ].ordering_position)
	, ENCNTR_QUAL_COSIGNED_REQUESTED = SUBSTRING(1, 30, T_REC->encntr_qual[D1.SEQ].cosigned_requested)
	, ENCNTR_QUAL_COSIGNED_POSITION = SUBSTRING(1, 30, T_REC->encntr_qual[D1.SEQ].cosigned_position)
	, ENCNTR_QUAL_COSIGN_DT_TM = format(T_REC->encntr_qual[D1.SEQ].cosign_dt_tm,";;q")
	, ENCNTR_QUAL_COSIGN_STATUS = SUBSTRING(1, 30, T_REC->encntr_qual[D1.SEQ].cosign_status)

FROM
	(DUMMYT   D1  WITH SEQ = SIZE(T_REC->encntr_qual, 5))

PLAN D1
	where ((T_REC->encntr_qual[D1.SEQ].primary_hp > " ") or (T_REC->encntr_qual[D1.SEQ].secondary_hp > " "))
	;and T_REC->encntr_qual[D1.SEQ].disch_dt_tm = 0.0
ORDER BY
	ENCNTR_QUAL_FACILITY
	, ENCNTR_QUAL_UNIT
	, ENCNTR_QUAL_ALIAS

WITH NOCOUNTER, SEPARATOR=" ",format, FORMAT(DATE,";;q")


call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)

end go

