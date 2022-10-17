 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Jul'20
	Solution:
	Source file name:		cov_rule_TroubleShoot.prg
	Object name:		cov_rule_TroubleShoot
	Request#:			AdHoc
	Program purpose:	      Troubleshoot Rule issues
	Executing from:
 	Special Notes:
 
;********************************************************************************/
 
drop program cov_rule_TroubleShoot:DBA go
create program cov_rule_TroubleShoot:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
;------------------------------------------------------------------
 
 select * from person pr 
 ;where pr.person_id = 744111
 where pr.name_full_formatted = 'TTTTMAYO, FSRTEST'

select e.encntr_id, e.reg_dt_tm from encounter e
where e.person_id =    16432316.00
 
;------------------------------------------------------------------
			;VTE ADVISOR ALERT
;------------------------------------------------------------------
;Modules by name
select * from eks_module em
where cnvtupper(em.module_name) = '*VTE*'
and em.active_flag = 'A'
and em.maint_validation = 'PRODUCTION'
order by em.module_name
 
;Alerts detail by Module
select ema.module_name, emad.*
from eks_module_audit ema, eks_module_audit_det emad
where ema.rec_id = emad.module_audit_id
;and( cnvtupper(ema.module_name) = 'COV_VTE_SCRATCHPAD' OR cnvtupper(ema.module_name) = 'COV_VTE_OC_24HOUR_ADMIT')
;and emad.encntr_id = 116742562
and cnvtupper(emad.logging) = '*VTE*'
and emad.template_type = 'A'
and emad.updt_dt_tm >= sysdate
order by emad.updt_dt_tm
 
 
;------------------------------------------------------------------
			;SEPSIS ADVISOR ALERT
;------------------------------------------------------------------
 
;Rules with name 'Sepsis'
select ema.*
from eks_module em, eks_module_audit ema
where ema.module_name = em.module_name
and cnvtupper(em.module_name) = '*SEPSIS*'
and em.active_flag = 'A'
order by em.module_name
 
 
;Alerts detail by encntr_id
select ema.module_name, emad.*
from eks_module_audit ema, eks_module_audit_det emad
where ema.rec_id = emad.module_audit_id
and emad.encntr_id =   120288454.00
and cnvtupper(emad.logging) = '*SEVERE SEPSIS IP ALERT*'
and emad.template_type = 'A'
order by emad.updt_dt_tm
 
select ema.module_name, emad.*
from eks_module_audit ema, eks_module_audit_det emad
where ema.rec_id = emad.module_audit_id
and emad.encntr_id = 120139544.00
and ema.module_name = 'SEPSIS_ADVSR_LAUNCH'
order by emad.updt_dt_tm
 
select ema.module_name, emad.*
from eks_module_audit ema, eks_module_audit_det emad
where ema.rec_id = emad.module_audit_id
and emad.encntr_id = 125359334
and ema.module_name = 'COV_DSCH_MEDREC_TSK'
order by ema.module_name, emad.updt_dt_tm desc
 
 
;-----------------------------------------------------------------------------------
;Rule Activity for an encounter
select
	rule = ema.module_name
	, when_it_fired = ema.updt_dt_tm "@SHORTDATETIME"
	, how_long = datetimediff(ema.end_dt_tm, ema.begin_dt_tm, 5)
	, template = emad.template_name
	, mesg = substring(1,80,emad.logging)
	, encounter_id = emad.encntr_id
	, order_id = emad.order_id
	, person_id = emad.person_id
	, emad.accession_id
 
from	eks_module_audit ema, eks_module_audit_det emad
 
plan ema
where cnvtupper(ema.module_name) = 'COV_VTE_OC_24HOUR_ADMIT' ; replace with a rule name to see one specifically.
  and ema.conclude    = 2   ; 2 = action performed, change to "!= 2" to see others
 ; and ema.updt_dt_tm  > cnvtdatetime("28-JUN-2011 00:00:00") ;if you need a time restriction
														     ; or use between
 
join emad
where emad.module_audit_id = ema.rec_id
  and emad.module_audit_id = (select emad2.module_audit_id
  						  	    from eks_module_audit_det emad2
  						       where emad2.module_audit_id = emad.module_audit_id)
  						         ;and emad2.encntr_id = #####) ;replace ##### with encntr_id
 
order by ema.updt_dt_tm desc, ema.rec_id, emad.template_number
 
with time = 60
 
 
;Find the rule based on an alert
select ema.module_name, emad.*
from eks_module_audit ema, eks_module_audit_det emad
where ema.rec_id = emad.module_audit_id
;and emad.encntr_id =   120288454.00
and cnvtupper(emad.logging) = '*VTE ALERT*'
and emad.template_type = 'A'
order by emad.updt_dt_tm
 
;------------------------------------------------------------------------------------------------------------------
 
select * from eks_module_audit_det emad where emad.encntr_id =  130141715
order by emad.updt_dt_tm desc
 
 22376109        130141715                0                0
 Log action with name -'COV_EKM!COV_SZ_INTERP_REMINDER'(0.01s)
 
select * 
from eks_module_audit_det emad 
where emad.encntr_id =  130141715
and emad.template_type = 'A'
and emad.template_name = 'EKS_LOG_ACTION_A'
and emad.logging = '*COV_SZ_INTERP_REMINDER*'
order by emad.updt_dt_tm desc
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1) 

 
;Alerts detail by Module
select ema.module_name, emad.*
from eks_module_audit ema, eks_module_audit_det emad
where ema.rec_id = emad.module_audit_id
and cnvtupper(ema.module_name) = 'COV_SZ_CODE_BLUE_ALERT'
and emad.encntr_id = 125359334
order by emad.updt_dt_tm DESC
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1) 
 
select ema.module_name, emad.*
from eks_module_audit ema, eks_module_audit_det emad
where ema.rec_id = emad.module_audit_id
and cnvtupper(ema.module_name) = 'COV_IC_MISC_COVID_TASK'
and emad.encntr_id = 116690002
and cnvtupper(emad.logging) = '*COV_IC_MISC_COVID_TASK*'
and emad.template_type = 'A'
and emad.updt_dt_tm >= sysdate
order by emad.updt_dt_tm
 
 
 
select ema.module_name, emad.*
from eks_module_audit ema, eks_module_audit_det emad
where emad.encntr_id = 125359334
and ema.rec_id = emad.module_audit_id
and cnvtupper(ema.module_name) = 'COV_DSCH_MEDREC_TSK'
order by emad.updt_dt_tm DESC
 
select ema.module_name, emad.*
from eks_module_audit ema, eks_module_audit_det emad
where emad.encntr_id = 110353215.00
and ema.rec_id = emad.module_audit_id
and cnvtupper(ema.module_name) = 'COV_GL_AMERIGROUP_INSU'
order by emad.updt_dt_tm DESC
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180
 
;Alert - EKS_MESSENGER notification
select * from eks_alert_esc_hist eh
where eh.encntr_id = 124898613
 
 
select * from eks_alert_escalation ea where ea.encntr_id = 124898613
 
select * from eks_alert_recipient ear where ear.alert_id =     3861889.00
 
;-----------------------------------------------------------------------------------------------------------------------
;Find the rule based on action template name
 
select distinct ema.module_name, emad.*
from eks_module_audit ema, eks_module_audit_det emad
where ema.rec_id = emad.module_audit_id
;and emad.encntr_id = 125348732.00
;and cnvtupper(emad.logging) = '*VTE ALERT*'
and emad.template_type = 'A'
and emad.template_name = 'EKS_MESSENGER*'
order by ema.module_name
with maxrow = 1000, time = 120
 
 
select ema.module_name, emad.*
from eks_module_audit ema, eks_module_audit_det emad
where ema.rec_id = emad.module_audit_id
and emad.encntr_id = 125348732.00
;and cnvtupper(emad.logging) = '*VTE ALERT*'
and emad.template_type = 'A'
order by emad.updt_dt_tm
with time = 120
 
select ema.*
from eks_module_audit ema
where cnvtupper(ema.module_name) = 'COV_STK*'
 
select * from eks_module_audit_det emad where emad.module_audit_id in(596907999.00, 596908003.00)
 
select ema.module_name, emad.*
from eks_module_audit ema, eks_module_audit_det emad
where ema.rec_id = emad.module_audit_id
and cnvtupper(ema.module_name) = 'COV_STK*'
and emad.encntr_id = 125348732.00
order by emad.updt_dt_tm
 
 
;------------------------------------------------------------------------------------------------------------------------
;Powerplans
select p.person_id, p.description, p.* from pathway p where p.encntr_id = 116739400
 
select * from pathway_catalog pc where pc.pathway_catalog_id =      2556773247.00
 
select * from problem p where p.person_id = 18812775
 
;Get Task activity
select task = uar_get_code_display(tc.event_cd), tc.reference_task_id,tc.*
 from task_activity tc where tc.task_id =  1644068449.00 ;1643916439;tc.encntr_id = 116734581
 
select task = uar_get_code_display(tc.event_cd), tc.reference_task_id, tc.updt_dt_tm ';;q', tc.*
 from task_activity tc where tc.encntr_id = 116734581
order by tc.updt_dt_tm desc
 
 
    18812775.00
 
select task = uar_get_code_display(tdr.task_assay_cd)
from task_discrete_r tdr where tdr.reference_task_id in(3156420737.00,3156420755.00);= 3156420737.00
 
 
select * ;task = uar_get_code_display(tdr.task_assay_cd)
from task_activity_msg_h tdr where tdr.reference_task_id = 2801476.00
 
select * from outcome_catalog tdr where tdr.reference_task_id = 2801476.00
 
select * from order_task ot where ot.reference_task_id in(3156420737.00,3156420755.00)
 
select ce.encntr_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm ';;q'
from clinical_event ce
where ce.event_cd in(34439957.00,24604416.00)
order by ce.encntr_id, ce.event_end_dt_tm
with nocounter, maxrec = 1000
 
 
 
task_type_cd = 2674.00	Patient Care
 
task_status_cd        	427.00	Opened
        			428.00	Overdue
        			429.00	Pending
 
    REFERENCE_TASK_ID	TASK_DESCRIPTION
    3156420737.00	    	Perform CHG Treatment on Insertion of PICC/Central Line
    3156420755.00	    	Perform Daily CHG Treatment while Foley Inserted
 
 
;===========================================================================================
;All CHG tasks fired with order
select ta.task_id, ta.order_id, o.order_mnemonic,ot.task_description, order_status = uar_get_code_display(o.order_status_cd)
, task_status = uar_get_code_display(ta.task_status_cd), ta.task_create_dt_tm ';;q'
, cnvtdatetime(curdate, curtime)';;q'
,days = DATETIMECMP(cnvtdatetime(curdate, curtime), ta.task_create_dt_tm), task_type = uar_get_code_display(ta.task_type_cd)
from task_activity ta, order_task ot, orders o
where ta.encntr_id = 116739570 ;116734581
and o.order_id = ta.order_id
and ta.reference_task_id = ot.reference_task_id
and ta.task_status_cd in(425,427,428,429)
;and ot.task_description = "Perform CHG Treatment on Insertion of PICC/Central Line"
;and DATETIMECMP(cnvtdatetime(curdate, curtime), ta.task_create_dt_tm) = 0
and ot.active_ind = 1
and ta.active_ind = 1
order by ta.task_create_dt_tm
 
 
 
;All CHG tasks fired
select ta.task_id, ta.order_id, ta.event_id, ot.task_description
, status = uar_get_code_display(ta.task_status_cd), ta.task_create_dt_tm ';;q'
, cnvtdatetime(curdate, curtime)';;q'
,days = DATETIMECMP(cnvtdatetime(curdate, curtime), ta.task_create_dt_tm), task_type = uar_get_code_display(ta.task_type_cd)
from task_activity ta, order_task ot
where ta.encntr_id = 116739570 ;116734581
and ta.reference_task_id = ot.reference_task_id
and ta.task_status_cd in(425,427,428,429)
;and ot.task_description = "Perform CHG Treatment on Insertion of PICC/Central Line"
;and DATETIMECMP(cnvtdatetime(curdate, curtime), ta.task_create_dt_tm) = 0
and ot.active_ind = 1
and ta.active_ind = 1
order by ta.task_create_dt_tm
 
 
 
;Powerplans
select p.person_id, p.description, p.* from pathway p where p.encntr_id =   116738143.00;116739400
 
select * from pathway_catalog pc where pc.pathway_catalog_id = 171986839.00     2556773247.00
 
;Problems
select * from problem p where p.person_id = 18812775
 
;Orders
select o.order_id, status = uar_get_code_display(o.order_status_cd),o.orig_order_dt_tm';;q',o.catalog_cd,o.order_mnemonic
from orders o where o.encntr_id =   116739573.00
order by o.orig_order_dt_tm
 
O.order_id = 2321127129
 
o.encntr_id = 116739570
and o.catalog_cd =  2564747205.00
 
select action_type = uar_get_code_display(oa.action_type_cd),oa.* from order_action oa where oa.order_id =  2320310643.00
 
select * from clinical_event ce where ce.order_id =  2321127143.00
 
;===================================================================================================
 
 
 
 SELECT EA.encntr_id, EA.alias FROM ENCNTR_ALIAS EA WHERE EA.alias = '2034300007'
 EA.encntr_id = 116739403
 
 
select ema.module_name, emad.logging, emad.order_id,emad.updt_dt_tm ';;q', emad.*
from eks_module_audit ema, eks_module_audit_det emad
where ema.rec_id = emad.module_audit_id
and cnvtupper(ema.module_name) = 'MED'
and emad.encntr_id = 116739570
order by emad.updt_dt_tm
 
 
 
select ema.module_name, emad.updt_dt_tm ';;q', emad.*
from eks_module_audit ema, eks_module_audit_det emad
where ema.rec_id = emad.module_audit_id
and emad.encntr_id = 125457611
and cnvtupper(ema.module_name) = 'COV_DSCH_MED_REC_TASK'
;and cnvtupper(emad.logging) = 'DISCHARGED PATIENT*'
;and emad.template_type = 'A'
order by emad.updt_dt_tm desc
 
select * from eks_notify_persn_r epr where epr.updt_dt_tm between cnvtdatetime('13-DEC-2021 00:00:00') and cnvtdatetime('13-DEC-2021 08:45:00')
WITH NOCOUNTER, TIME = 30
 
 
select pr.name_full_formatted, pr.* from prsnl pr where pr.person_id = 20582449
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
