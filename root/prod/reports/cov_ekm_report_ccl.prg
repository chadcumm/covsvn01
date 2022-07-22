 
drop program cov_ekm_report_ccl:DBA go
create program cov_ekm_report_ccl:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"
 
with OUTDEV
 
;****** The EKS_MONITOR reads from the EKS_MODULE_AUDIT and EKS_MODULE_AUDIT_DET tables. **************
 
select distinct ;into $outdev
 
     e.module_name
    , ed1.encntr_id
    ,e.begin_dt_tm ";;q"
    ,e.end_dt_tm ";;q"
    ,p.name_full_formatted
    ,facility=uar_get_code_display(en.loc_facility_cd)
    ,encntr_type=uar_get_code_display(en.encntr_type_cd)
    ,ed1.template_type
    ,ed1.logging
 
from
 
     eks_module_audit e
    ,eks_module_audit_temp em
    ,eks_module_audit_det ed1
    ,eks_module_audit_det ed2
    ,person p
    ;,accession a
    ,encounter en
 
plan e where e.module_name = "COV_GL_BLUECARE_INSU" ;'COV_OC_INFLUENZA_DC_ORDER'
    ;and e.begin_dt_tm >= cnvtdatetime(curdate-1,0)
    and e.begin_dt_tm between cnvtdatetime("01-OCT-2018 00:00:00") and cnvtdatetime("01-OCT-2018 23:59:00")
 
join em where em.module_name = e.module_name
 
join ed1 where   ed1.module_audit_id = e.rec_id
    and ed1.template_number = em.template_num
    ;and ed1.template_type   = "A"
    ;and ed1.logging         = "*8655971701@usamobility.net*"
    ;and ed1.logging         = "Sent*"
 
join ed2 where   ed2.module_audit_id = ed1.module_audit_id
    ;and ed2.template_type   = "L"
 
join p where   p.person_id = ed2.person_id
 
join en where en.encntr_id = ed2.encntr_id
 
order by e.begin_dt_tm
 
 
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT, time = 120;, MAXREC = 10000
 
end go
 
 
;*************************************************************************************************************
;Find Open chart alert
select ea.alias, e.encntr_id, ede.dlg_event_id, ede.dlg_name, dlg_dt = format(ede.dlg_dt_tm,'mm/dd/yyyy hh:mm;;q')
	, ede.dlg_prsnl_id, pr.name_full_formatted, patient = p.name_full_formatted, ede.active_ind, ede.active_status_cd
from eks_dlg_event ede, prsnl pr, encounter e, person p, encntr_alias ea
where ede.dlg_prsnl_id = pr.person_id
and ede.encntr_id = e.encntr_id
and p.person_id = e.person_id
and ea.encntr_id = e.encntr_id and ea.encntr_alias_type_cd = 1077
and e.loc_facility_cd = 2552503613
and e.reg_dt_tm between cnvtdatetime("01-OCT-2018 00:00:00") and cnvtdatetime("10-OCT-2018 23:59:00")
and ede.dlg_name = 'COV_EKM!COV_OC_INFLUENZA_DC_ORDER'
;and ede.person_id = 15474039
order by dlg_dt
 
;*************************************************************************************************************
 
;Find Pager alert
select distinct mad.module_audit_id, ema.rec_id, mad.logging
	, person_id = max(mad.person_id)
	, encntr_id = max(mad.encntr_id)
	, update_dt = format(mad.updt_dt_tm, 'mm/dd/yyyy hh:mm;;q')
	, begin_dt = format(ema.begin_dt_tm, 'mm/dd/yyyy hh:mm;;q')
	, module = ema.module_name
from eks_module_audit_det mad, eks_module_audit ema
where mad.module_audit_id = ema.rec_id
and CNVTUPPER(ema.module_name) = 'COV_CE_INFLUENZA_DC_ORDER'
and mad.logging = '*DC without Influenza*'
;and mad.encntr_id = 111738459
group by mad.module_audit_id, ema.rec_id, mad.logging
order by mad.updt_dt_tm
 
;----------------------------------------------------
 
; Find Pager Alert - helper
 
select * from eks_module where CNVTUPPER(module_name) = 'COV_CE_INFLUENZA_DC_ORDER'
 
select beg = format(ema.begin_dt_tm,'mm/dd/yyyy hh:mm;;q'),ema.*
from eks_module_audit ema where CNVTUPPER(ema.module_name) = 'COV_CE_INFLUENZA_DC_ORDER'
and ema.rec_id = 91217460.00
 
select mad.*, udt = format(mad.updt_dt_tm, 'mm/dd/yyyy hh:mm;;q')
from eks_module_audit_det mad
where mad.encntr_id = 110431830
;where mad.person_id = 14808179
;and mad.template_type = 'A'
order by updt_dt_tm
 
select * from eks_module_audit where rec_id =  24281387 ;rec_id = module_audit_id
  
select * from eks_module_audit_det where module_audit_id = 24281387
; rec_id = 91217460.00 - eks_module_audit
 
 
select * from eks_module_audit_det where encntr_id =   111509188.00
 
select * from eks_module_audit where cnvtUPPER(module_name) = 'COV_GL_BLUECARE_INSU'
 
select * from eks_module_audit_temp where cnvtUPPER(module_name) = 'COV_CE_INFLUENZA_DC_ORDER'
 
select * from eks_modulestorage where cnvtUPPER(module_name) = 'COV_CE_INFLUENZA_DC_ORDER'
 
;Alert
select e.loc_facility_cd from encounter e where e.encntr_id = 111608250 ;15474039 -pid
 
select * from eks_alert_esc_hist where encntr_id = 111738459
 
select * from eks_alert_escalation where encntr_id = 111738459
 
select * from eks_alert_recipient where cnvtupper(recipient_name) = '*PELEHACH*'
 
select * from eks_dlg_event where encntr_id = 111738459
 
select * from eks_dlg_evt_answer_r where dlg_event_id =    13115183.00
 
select * from encounter where person_id = 14808179
 
 
 
 
 
 
 
 
