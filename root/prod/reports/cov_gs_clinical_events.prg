/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Mar'2021
	Solution:
	Source file name:	      cov_gs_clinical_events.prg
	Object name:		cov_gs_clinical_events
	Request#:
	Program purpose:	      AdHoc
	Executing from:
 	Special Notes:
 
******************************************************************************/

drop program cov_gs_clinical_events:dba go
create program cov_gs_clinical_events:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Encounter Id" = 0
	, "Alias" = ""
	, "Person Id" = 0 

with OUTDEV, enc_id, alias_prt, person_id_prt



/**************************************************************
; DVDev Start Coding
**************************************************************/

select into $outdev

 ce.encntr_id, ce.event_cd, ce.order_id
, event = uar_get_code_display(ce.event_cd), ce.result_val
, ce.event_title_text, ce.event_tag
, event_end_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, event_start_dt  = format(ce.event_start_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, perform_dt = format(ce.performed_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, performed_by = pr.name_full_formatted
, verify_dt = format(ce.verified_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, verified_by = pr1.name_full_formatted
, valid_until = format(ce.valid_until_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, ce.event_id, ce.result_status_cd, ce.view_level, ce.publish_flag
, e.person_id, fac = uar_get_code_display(e.loc_facility_cd), e.loc_facility_cd
, fin = trim(ea.alias) 

;, result_status = uar_get_code_display(ce.result_status_cd)
;, note = uar_get_code_display(ce.entry_mode_cd), ce.entry_mode_cd
;, ce.parent_event_id, ce.ce_dynamic_label_id
;, result_val_dt = format(cnvtdatetime(cnvtdate2(substring(3,8,ce.result_val),"YYYYMMDD")
;				,cnvtint(substring(11,6,ce.result_val))),"MM/dd/yyyy hh:mm;;d")
;, ce.*
 
from clinical_event ce, encntr_alias ea, prsnl pr, prsnl pr1, encounter e
 
where ce.encntr_id = ea.encntr_id
and e.encntr_id = ce.encntr_id
and ea.encntr_alias_type_cd = 1077
and ea.active_ind = 1
and ce.performed_prsnl_id = pr.person_id
and ce.verified_prsnl_id = pr1.person_id
and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
;and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)

and (ea.alias = $alias_prt or ce.encntr_id = $enc_id or ce.person_id = $person_id_prt)

;and ce.event_end_dt_tm between cnvtdatetimE($begdate) AND cnvtdatetimE($enddate)
;and ce.order_id =  3847825403.00
;and ce.event_cd =    16806092.00
order by event_end_dt asc
 
with nocounter, separator=" ", format 

;and ce.order_id =   2512452703.00
;and ce.person_id = 14694437.00
;and ce.encntr_id = 118578564.00
;and ce.event_id = 237238771.00
;and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth (Verified), Modified
;and ce.event_title_text != 'IVPARENT'
;and ce.view_level = 1
;and ce.publish_flag = 1
;and ce.event_tag_set_flag = 1
;and ce.performed_dt_tm between cnvtdatetime("25-FEB-2020 00:00:00") and cnvtdatetime("28-FEB-2020 23:59:00")
 
 
end
go

