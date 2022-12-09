 
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
;Modules by name
 
select * from eks_module em
;where cnvtupper(em.module_name) = '*MED*'
where cnvtupper(em.module_name) = 'VTE*'
;and em.active_flag = 'A'
;and em.maint_validation = 'PRODUCTION'
order by em.module_name
 
 
select ema.*
from eks_module em, eks_module_audit ema
where ema.module_name = em.module_name
and cnvtupper(em.module_name) = 'COV_IC_MISC_COVID_TASK'
and em.active_flag = 'A'
order by em.module_name
 
;------------------------------------------------------------------
 
;Alerts detail by encntr_id
select ema.module_name, emad.*
from eks_module_audit ema, eks_module_audit_det emad
where ema.rec_id = emad.module_audit_id
and emad.encntr_id =     131195898.00
;and cnvtupper(emad.logging) = '*SEVERE SEPSIS IP ALERT*'
and cnvtupper(ema.module_name) = 'COV_GL_AMERIGROUP_INSU'
;and emad.template_type = 'A'
order by emad.updt_dt_tm
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"),uar_code(d,1)
 
select ema.module_name, emad.updt_dt_tm ';;q', emad.*
from eks_module_audit ema, eks_module_audit_det emad
where ema.rec_id = emad.module_audit_id
and emad.encntr_id = 123770838.00
and cnvtupper(ema.module_name) = 'COV_IC_MISC_COVID_TASK'
order by emad.module_audit_id,emad.template_number  ;emad.updt_dt_tm
 
select ema.updt_dt_tm ';;q', ema.module_name, emad.*
from eks_module_audit ema, eks_module_audit_det emad
where ema.rec_id = emad.module_audit_id
and emad.encntr_id =   129618469.00
and ema.module_name = 'COV_LH_STK_ANTITH_DSCHMED'
and emad.template_type = 'A'
order by ema.module_name, emad.updt_dt_tm
 
 
 
select ema.module_name, emad.template_alias, emad.template_name, emad.template_return
, EMAD.logging, EMAD.updt_dt_tm ';;q', emad.*
from eks_module_audit ema, eks_module_audit_det emad
where ema.rec_id = emad.module_audit_id
and emad.encntr_id = 132572468
and ema.module_name = 'COV_GL_BLUECARE_INSU'
order by ema.module_name, emad.updt_dt_tm desc
 
 
select ema.module_name, emad.*
from eks_module_audit ema, eks_module_audit_det emad
where ema.rec_id = emad.module_audit_id
;and emad.encntr_id = 128655117
and ema.module_name = 'COV_LH_STK_STATIN_DSCHMED'
and ema.updt_dt_tm >= cnvtdatetime('25-OCT-2022 00:00:00')
order by ema.module_name, emad.updt_dt_tm desc
 

select 
 emad.encntr_id,ema.module_name,emad.template_name,emad.template_alias, emad.template_return, emad.template_number
, emad.template_type, ema.begin_dt_tm ';;Q', emad.logging, ema.*, emad.*
from eks_module_audit ema, eks_module_audit_det emad
where ema.rec_id = emad.module_audit_id
and emad.encntr_id =   125489997
and ema.module_name in('COV_SZ_SCHREG_INTERP', 'COV_SZ_INTERP_REMINDER')
;and ema.updt_dt_tm >= cnvtdatetime('09-NOV-2022 00:00:00')
order by ema.module_name, emad.updt_dt_tm desc


select emad.encntr_id,emad.template_name,emad.template_alias, emad.template_return, emad.template_number, emad.updt_dt_tm
, emad.template_type, emad.logging
from eks_module_audit_det emad where emad.encntr_id =   125489997
order by emad.updt_dt_tm
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), uar_code(d,1);, time = 360;, maxrow = 10000

 
;-----------------------------------------------------------------------------------

;Format the logging  

select fin = ea.alias, patient_name = p.name_full_formatted
, user_received_alert = pr.name_full_formatted, alert_dt = ema.begin_dt_tm ';;q'
, ema.module_name, emad.logging ;,emad.template_name,emad.template_alias, emad.template_number, emad.template_return
;,emad.encntr_id,ema.module_name,emad.template_name,emad.template_alias, emad.template_return, emad.template_number
;, emad.template_type, ema.begin_dt_tm, emad.logging, ema.*, emad.*
from eks_module_audit_det emad, eks_module_audit ema , encntr_alias ea, prsnl pr, person p
where emad.module_audit_id = ema.rec_id
and ea.encntr_id = emad.encntr_id 
and ea.encntr_alias_type_cd = 1077
and pr.person_id = emad.updt_id
and p.person_id = emad.person_id
;and emad.encntr_id = 131990841.00
and ema.module_name = 'LH_STK_ANTICOA_DSCHMED_14'
and emad.template_number = 8 
and emad.template_return = 100
and ema.updt_dt_tm >= cnvtdatetime('01-AUG-2022 00:00:00')
order by ema.begin_dt_tm
;order by emad.updt_dt_tm, emad.template_number asc
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), uar_code(d,1);, time = 360;, maxrow = 10000



select fin = ea.alias, patient_name = p.name_full_formatted
, user_received_alert = pr.name_full_formatted, alert_dt = ema.begin_dt_tm ';;q'
, ema.module_name;, emad.logging,emad.template_name
from eks_module_audit_det emad, eks_module_audit ema , encntr_alias ea, prsnl pr, person p
where emad.module_audit_id = ema.rec_id
and ea.encntr_id = emad.encntr_id and ea.encntr_alias_type_cd = 1077
and pr.person_id = emad.updt_id
and p.person_id = emad.person_id
;and emad.encntr_id = 131990841.00
and ema.module_name = 'LH_STK_ANTICOA_DSCHMED_14'
;and emad.template_number = 8 
;and emad.template_return = 100
and emad.template_type = 'A'
and emad.template_return = 100
and ema.updt_dt_tm >= cnvtdatetime('01-AUG-2022 00:00:00')
order by ema.begin_dt_tm
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), uar_code(d,1);, time = 360;, maxrow = 10000
 

;STATIN ALERT
select 
;fin = ea.alias, patient_name = p.name_full_formatted, 
emad.encntr_id, alert_dt = ema.begin_dt_tm ';;q'
;, user_received_alert = pr.name_full_formatted
, ema.module_name, emad.logging,emad.template_name,emad.template_alias, emad.template_return, emad.template_number, ema.*, emad.*
from eks_module_audit_det emad, eks_module_audit ema; , encntr_alias ea, prsnl pr, person p
where emad.module_audit_id = ema.rec_id
;and ea.encntr_id = emad.encntr_id and ea.encntr_alias_type_cd = 1077
;and pr.person_id = emad.updt_id
;and p.person_id = emad.person_id
;and emad.encntr_id = 132229318
and ema.module_name = 'COV_LH_STK_STATIN_DSCHMED'
and emad.template_type = 'A'
and emad.template_return = 100
;and emad.template_number = 25
;and emad.template_return = 100
and ema.updt_dt_tm >= cnvtdatetime('01-OCT-2022 00:00:00')
order by ema.module_name
;order by emad.updt_dt_tm, emad.template_number asc
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), uar_code(d,1);, time = 360;, maxrow = 10000


select 
fin = ea.alias, patient_name = p.name_full_formatted, alert_dt = ema.begin_dt_tm ';;q'
, user_received_alert = pr.name_full_formatted, ema.module_name;, emad.logging
;,emad.template_name,emad.template_alias, emad.template_return, emad.template_number, ema.*, emad.*
from eks_module_audit_det emad, eks_module_audit ema , encntr_alias ea, prsnl pr, person p
where emad.module_audit_id = ema.rec_id
and ea.encntr_id = emad.encntr_id and ea.encntr_alias_type_cd = 1077
and pr.person_id = emad.updt_id
and p.person_id = emad.person_id
;and emad.encntr_id = 132229318
and ema.module_name = 'COV_LH_STK_STATIN_DSCHMED'
and emad.template_type = 'A'
and emad.template_return = 100
and ema.updt_dt_tm >= cnvtdatetime('01-AUG-2022 00:00:00')
order by ema.begin_dt_tm
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), uar_code(d,1);, time = 360;, maxrow = 10000


;-------------------------------------------------------------------------------------

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
where cnvtupper(ema.module_name) = "COV_IC_MISC_COVID_TASK" ; replace with a rule name to see one specifically.
  and ema.conclude    = 2   ; 2 = action performed, change to "!= 2" to see others
 ; and ema.updt_dt_tm  > cnvtdatetime("28-JUN-2011 00:00:00") ;if you need a time restriction
														     ; or use between
 
join emad
where emad.module_audit_id = ema.rec_id
and emad.encntr_id = 123770838
  and emad.module_audit_id = (select emad2.module_audit_id
  						  	    from eks_module_audit_det emad2
  						       where emad2.module_audit_id = emad.module_audit_id)
  						         ;and emad2.encntr_id = #####) ;replace ##### with encntr_id
 
order by ema.updt_dt_tm desc, ema.rec_id, emad.template_number
 
with time = 60
 
 
