 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Mar'2020
	Solution:			Quality
	Source file name:	      cov_phq_non_print_aod_feed.prg
	Object name:		cov_phq_non_print_aod_feed
	Request#:			7123
	Program purpose:	      Accounting for Disclosure - Health Department Report - non print
	Executing from:		Ops
 	Special Notes:
 
***************************************************************************************************************
  GENERATED MODIFICATION CONTROL LOG
***************************************************************************************************************
 
 CR#	  Mod Date	 Developer			Comment
------  ---------  -----------  ---------------------------------------------------------------------------------
 
****************************************************************************************************************/
 
 
drop program cov_phq_non_print_aod_feed:dba go
create program cov_phq_non_print_aod_feed:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"     ;* Enter or select the printer or file name to send this report to.
	, "Start Document Date/Time" = "SYSDATE"
	, "End Document Date/Time" = "SYSDATE"
 
with OUTDEV, start_datetime, end_datetime
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare agency_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Agency Contacted")), protect
declare contact_dt_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Date and Time of Contact (Disclosure)")), protect
declare rep_condition_var = f8 with constant(uar_get_code_by("DISPLAY", 72, "Reportable Condition")), protect
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
Record acc(
	1 plist[*]
		2 facility = vc
		2 nurse_unit = vc
		2 fin = vc
		2 mrn = vc
		2 encntrid = f8
		2 personid = f8
		2 patient_name = vc
		2 birh_dt = vc
		2 regdt = dq8
		2 age = vc
		2 admit_dt = vc
		2 elist[*]
			3 document_dt = vc
			3 agency = vc
			3 condition = vc
			3 contact_dt = vc
	)
 
 
;-----------------------------------------------------------------------------------------------
;Get clinical events from Light house tables
select into $outdev
re.encntr_id, re.event_id, re.event_type_flag, re.discontinue_dt_tm "@SHORTDATETIME"
, event = uar_get_code_display(re.event_cd), re.event_dt_tm "@SHORTDATETIME"
,re.result_display
 
from
	lh_cnt_ic_rpt_event re
	, lh_cnt_ic_patient_pop pp
	, encounter e
 
plan re where re.event_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and re.active_ind = 1
	and re.event_cd in(agency_var, contact_dt_var, rep_condition_var)
 
join pp where pp.encntr_id = re.encntr_id
	and pp.active_ind = 1
 
join e where e.encntr_id = re.encntr_id
	and e.encntr_id != 0.00
 
with nocounter, separator=" ", format

end go
 
 
/*
order by re.encntr_id, re.event_dt_tm, re.event_cd, re.event_id
 
Head report
	cnt = 0
Head re.encntr_id
	ecnt = 0
	cnt += 1
	call alterlist(acc->plist, cnt)
	acc->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	acc->plist[cnt].encntrid = re.encntr_id
	acc->plist[cnt].personid = e.person_id
	acc->plist[cnt].nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd)
	acc->plist[cnt].admit_dt = format(e.reg_dt_tm, 'mm/dd/yyyy hh:mm:ss;;q')
	acc->plist[cnt].regdt = if(e.reg_dt_tm is not null) e.reg_dt_tm else e.arrive_dt_tm endif
 
Head re.event_dt_tm
	ecnt += 1
	call alterlist(acc->plist[cnt].elist, ecnt)
	acc->plist[cnt].elist[ecnt].document_dt = format(re.event_dt_tm, 'mm/dd/yyyy hh:mm:ss;;q')
Detail
	case (re.event_cd)
		of agency_var:
			if(re.event_type_flag = 3)
				acc->plist[cnt].elist[ecnt].agency = trim(re.result_display)
			endif
		of contact_dt_var:
			if(re.event_type_flag = 4)
				acc->plist[cnt].elist[ecnt].contact_dt = trim(re.result_display)
			endif
		of rep_condition_var:
			if(re.event_type_flag = 5)
				acc->plist[cnt].elist[ecnt].condition = trim(re.result_display)
			endif
	endcase
 
with nocounter
 
;-----------------------------------------------------------------------------------------------
;Get demographic
select into 'nl:'
 
from (dummyt d with seq = value(size(acc->plist, 5)))
	,encntr_alias ea
	,encntr_alias ea1
	,person p
 
plan d
 
join ea where ea.encntr_id = acc->plist[d.seq].encntrid
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
join ea1 where ea.encntr_id = acc->plist[d.seq].encntrid
	and ea1.encntr_alias_type_cd = 1079
	and ea1.active_ind = 1
 
join p where p.person_id = acc->plist[d.seq].personid
	and p.active_ind = 1
 
order by p.person_id, ea.encntr_id
 
Head ea.encntr_id
	cnt = 0
	idx = 0
      idx = locateval(cnt ,1 ,size(acc->plist, 5) ,ea.encntr_id ,acc->plist[cnt].encntrid)
 
	if(idx > 0)
		acc->plist[idx].birh_dt = format(p.birth_dt_tm, 'mm/dd/yyyy hh:mm:ss;;q')
 		acc->plist[idx].patient_name = trim(p.name_full_formatted)
 		acc->plist[idx].fin = trim(ea.alias)
 		acc->plist[idx].mrn = trim(ea1.alias)
 		acc->plist[idx].age = build2(cnvtage(p.birth_dt_tm, acc->plist[idx].regdt,0), 'Years')
 	endif
 
with nocounter
 
call echorecord(acc)
 
;-----------------------------------------------------------------------------------------------
 
select into $outdev
	facility = trim(substring(1, 30, acc->plist[d1.seq].facility))
	, nurse_unit = substring(1, 30, acc->plist[d1.seq].nurse_unit)
	, mrn = trim(substring(1, 10, acc->plist[d1.seq].mrn))
	, fin = trim(substring(1, 10, acc->plist[d1.seq].fin))
	, patient_name = trim(substring(1, 50, acc->plist[d1.seq].patient_name))
	, birh_dt = trim(substring(1, 30, acc->plist[d1.seq].birh_dt))
	, age = trim(substring(1, 10, acc->plist[d1.seq].age))
	, admit_dt = trim(substring(1, 30, acc->plist[d1.seq].admit_dt))
	, document_dt = trim(substring(1, 30, acc->plist[d1.seq].elist[d2.seq].document_dt))
	, agency = trim(substring(1, 300, acc->plist[d1.seq].elist[d2.seq].agency))
	, condition = trim(substring(1, 300, acc->plist[d1.seq].elist[d2.seq].condition))
	, contact_dt = trim(substring(1, 30, acc->plist[d1.seq].elist[d2.seq].contact_dt))
 
from
	(dummyt   d1  with seq = size(acc->plist, 5))
	, (dummyt   d2  with seq = 1)
 
plan d1 where maxrec(d2, size(acc->plist[d1.seq].elist, 5))
join d2
 
order by facility, nurse_unit,fin, document_dt
 
with nocounter, separator=" ", format
 
end go
 

;---------------------------------------------------------------------------------------- 
;Testing piece
/*

 select
	l.active_ind
	;, l.ce_dynamic_label_id
	, l.discontinue_dt_tm
	, l.encntr_id
	, l_event_disp = uar_get_code_display(l.event_cd)
	, l.event_dt_tm
	;, l.event_id
	, l.event_type_flag
	;, l.insert_dt_tm
	;, l.last_utc_ts
	;, l.lh_cnt_ic_rpt_event_id
	, l.result_display
	;, l.rowid
	;, l.txn_id_text
	;, l.updt_applctx
	;, l.updt_cnt
	, l.updt_dt_tm
	;, l.updt_id
	;, l.updt_task
 
from
	lh_cnt_ic_rpt_event   l
 
where l.event_dt_tm >= cnvtdatetime("02-MAR-2020 00:00:00") 

;----------------------------------------------------------------------------------------
