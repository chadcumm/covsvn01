/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		May 2021
	Solution:			Quality
	Source file name:	      cov_phq_mrsa_hist_load.prg
	Object name:		cov_phq_mrsa_hist_load
	Request#:			9964
	Program purpose:	      MRSA/CHG Project
	Executing from:		DA2/Ops
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	-------------------------------------------------------------------------------------------------------*/
 
 
drop program cov_phq_mrsa_hist_load_cpy:dba go
create program cov_phq_mrsa_hist_load_cpy:dba
 
prompt
	"Output to File/Printer/MINe" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Task Start Date/Time" = "SYSDATE"
	, "Task End Date/Time" = "SYSDATE"
	, "Select Facility" = 0
	, "Screen Display" = 1
 
with OUTDEV, start_datetime, end_datetime, acute_facility_list, to_file
 
 
/**************************************************************
; Variable Declaration
**************************************************************/
 
declare initcap()     = c100
declare opr_nu_var    = vc with noconstant("")
declare num  = i4 with noconstant(0)
declare problem_list = vc with noconstant('')
declare diagnosis_list = vc with noconstant('')
declare s_date_var = dq8
declare e_date_var = dq8
 
set s_date_var = datetimetrunc(cnvtdatetime($start_datetime), "dd")
set e_date_var = datetimetrunc(cnvtdatetime($end_datetime), "dd")
 
 
declare urinary_cath_var     = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Urinary Catheter Activity:'))), protect
declare urinary_site_var     = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Urinary Catheter Insertion Site:'))),protect
declare sn_urinary_cath_var  = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'SN - Cath - Urinary Catheter'))),protect
declare sn_cath_var 	     = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'SN - Cath - Inserted'))),protect
declare sn_cath_type_var     = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'SN - Cath - Device Type'))),protect
declare sn_cath_time_var     = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'SN - Cath - Time In'))),protect
declare foley_indication_var = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Urinary Catheter Indications:'))), protect
declare foley_type_var       = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Urinary Catheter Type:'))), protect
declare central_line_var     = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Central Line Activity.'))), protect
declare central_site_var     = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Central Line Insertion Site:'))), protect
declare chg_treat_var        = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Chlorohexidine treatment'))), protect
declare cvl_indication_var   = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Central Line Indication.'))), protect
declare cvl_type_var         = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Central Line Access Type'))), protect
declare chg_task_var         = vc with constant('Perform Chlorhexidine Treatment'), protect
declare max_disch_dt_var = dq8
declare fecnt = i4 with noconstant(0)
declare flcnt = i4 with noconstant(0)
 
;-------------------------------------------------------------------------------------------------------
;Set nurse unit variable
/*
if(substring(1,1,reflect(parameter(parameter2($nurse_unit),0))) = "L");multiple values were selected
	set opr_nu_var = "in"
elseif(parameter(parameter2($nurse_unit),1)= 0.0) ;all[*] values were selected
	set opr_nu_var = "!="
else								  ;a single value was selected
	set opr_nu_var = "="
endif*/
 
;-------------------------------------------------------------------------------------------------------
 
;************* OPS SETUP ******************
declare output_orders = vc
declare cmd  = vc with noconstant("")
declare len  = i4 with noconstant(0)
declare stat = i4 with noconstant(0)
declare iOpsInd      = i2 WITH NOCONSTANT(0), PROTECT
 
;test ----------
;declare filename_var  = vc with constant('cer_temp:cov_test.txt'), protect
;declare ccl_filepath_var = vc WITH constant('$cer_temp/cov_test.txt'), PROTECT
;---------------*/
 
declare filename_var = vc WITH constant('cer_temp:cov_phq_mrsa_feed.txt'), PROTECT
declare ccl_filepath_var = vc WITH constant('$cer_temp/cov_phq_mrsa_feed.txt'), PROTECT
declare astream_filepath_var = vc with constant("/cerner/w_custom/p0665_cust/to_client_site/Quality/Mrsa_Feed")
 
;request from Ops?
if(validate(request->batch_selection) = 1)
 	set iOpsInd = 1
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
 /*
Record unit(
	1 list[*]
		2 nu_unit = vc
		2 nu_descrpt = vc
		2 nu_cd = f8
		2 cdf_mean = vc
)
 
;Store the selected units
select into $outdev
nurse_unit = trim(uar_get_code_display(nu.location_cd)),unit_desc = trim(uar_get_code_description(nu.location_cd))
,nurse_unit_cd = nu.location_cd, cv1.cdf_meaning
 
from nurse_unit nu
	,code_value cv1
 
plan nu where nu.loc_facility_cd = $acute_facility_list
	and operator(nu.location_cd, opr_nu_var, $nurse_unit)
	and nu.active_status_cd = 188
	and nu.active_ind = 1
	and nu.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and nu.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
 
join cv1 where nu.location_cd = cv1.code_value
	and cv1.code_set = 220
	and cv1.cdf_meaning = 'NURSEUNIT'
 
order nu.location_cd
 
Head report
	ncnt = 0
Head nu.location_cd
	ncnt += 1
	call alterlist(unit->list, ncnt)
Detail
	unit->list[ncnt].nu_unit = nurse_unit
	unit->list[ncnt].nu_descrpt = unit_desc
	unit->list[ncnt].nu_cd = nu.location_cd
	unit->list[ncnt].cdf_mean = cv1.cdf_meaning
with nocounter
 
call echorecord(unit)
 */
 
;------------------------------------------------------------------------------------------------------
Record pat(
	1 rec_cnt = i4
	1 min_date = dq8
	1 max_disch_date = dq8
	1 days_between = i4
	1 plist[*]
		2 facility = vc
		2 unit = vc
		2 fin = vc
		2 pat_name = vc
		2 pat_type = vc
		2 encntrid = f8
		2 personid = f8
		2 admitdt = dq8
		2 dischdt = vc
		2 allergy_doc = vc
		2 allergy_doc_dt = vc
		2 allergy_begdt = vc
		2 allergy_enddt = vc
		2 events[*]
			3 activity_day = dq8
			3 final_output_indicator = vc
			3 tsk_dt = vc
			3 tsk_status = vc
			3 tsk_not_done_doc = vc
			3 tsk_not_done_doc_dt = vc
			3 chlor_treatment = vc
			3 chg_complete_dt = vc
			3 chg_not_done_doc = vc
			3 chg_not_done_doc_dt = vc
			3 1st_shift_tsk_dt = vc
			3 1st_shift_tsk_status = vc
			3 2nd_shift_tsk_dt = vc
			3 2nd_shift_tsk_status = vc
			3 lines[*]	
				4 eventid = f8		
				4 cvl_action = vc
				4 cvl_beg_dt = vc
				4 cvl_end_dt = vc
				4 cvl_indcat = vc
				4 cvl_indcat_dt = vc
				4 cvl_typ = vc
				4 foley_indcat = vc
				4 foley_indcat_dt = vc
				4 foley_action = vc
				4 foley_beg_dt = vc
				4 foley_end_dt = vc
				4 foley_typ = vc
	 		)
 
;------------------------ Helpers ---------------------------------------------------
Record cvl_labl(
	1 list[*]
		2 encntrid = f8
		2 cvl_eventcd = f8
		2 cvl[*]
			3 cl_lbl_id = f8
			3 cl_lbl_min_eventid = f8
			3 cl_action = vc
			3 cl_dt = dq8
			3 cl_type = vc
			3 cl_type_dt = dq8
			3 cl_days = vc
			3 cl_ind_dt = dq8
			3 cl_indicat = vc
			3 cl_discon_dt = dq8
	)
 
Record fol_labl(
	1 list[*]
		2 encntrid = f8
		2 fl_cnt = i4
		2 fol[*]
			;3 fl_cnt = i4
			3 fl_lbl_id = f8
			3 fl_eventcd = f8
			3 fl_lbl_min_eventid = f8
			3 fl_parent_eventid = f8
			3 fl_action = vc
			3 fl_dt = dq8
			3 fl_type = vc
			3 fl_type_dt = dq8
			3 fl_days = vc
			3 fl_indicat = vc
			3 fl_ind_dt = dq8
			3 fl_discon_dt = dq8
	)
 
 
;----------------------------------------------------------------------------------------------
;Dates Calculation
 
Record dt(
	1 min_date = dq8
	1 max_disch_date = dq8
	1 days_between = i4
	1 list[*]
		2 event_days = dq8
	1 elist[*]
		2 encntrid = f8
)
 
select into $outdev
 
min_dt = $start_datetime, max_disch_dt = max(e.disch_dt_tm)';;q'
 
from encounter e
 
plan e where e.loc_facility_cd = $acute_facility_list
	and e.reg_dt_tm between cnvtdatetime($start_datetime) AND cnvtdatetime($end_datetime)
	and e.encntr_type_cd in(309308.00, 309312.00,19962820.00);Inpatient,Observation,Outpatient in a Bed
	and e.active_ind = 1
	and e.disch_dt_tm != null
	and e.encntr_status_cd = 856.00 ;Discharged
 
order by e.disch_dt_tm
 
 
Head Report
	days = datetimecmp(max_disch_dt, cnvtdatetime($start_datetime)) + 1
	dt->days_between = days
	dt->min_date = cnvtdatetime($start_datetime)
	dt->max_disch_date = max_disch_dt
	/*call alterlist(dt->list, days)
	dcnt = 1, cnt = 1
	dt->list[dcnt].event_days = datetimetrunc(cnvtdatetime($start_datetime), "dd")
	dcnt += 1
	while(dcnt <= days)
		dt->list[dcnt].event_days = datetimeadd(cnvtdatetime($start_datetime), cnt)
		dcnt += 1
		cnt += 1
	endwhile*/
 
with nocounter
 
 
set max_disch_dt_var = dt->max_disch_date
 
;call echorecord(dt)
 
 
;-----------------------------------------------------------------------------------------------
;Patient population - nurse unit assigned for a given date range
 
select into $outdev
 
e.encntr_id, e.encntr_type_cd, e.reg_dt_tm, e.arrive_dt_tm, elh.encntr_type_cd
 
from 	encounter e
	, encntr_loc_hist elh
 
plan e where e.loc_facility_cd = $acute_facility_list
	and e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.encntr_type_cd in(309308.00, 309312.00,19962820.00);Inpatient,Observation,Outpatient in a Bed
	and e.active_ind = 1
	and e.disch_dt_tm != null
	and e.encntr_status_cd = 856.00 ;Discharged
 
join elh where elh.encntr_id = e.encntr_id
	and elh.active_ind = 1
 
order by e.encntr_id
 
Head report
	days = datetimecmp(max_disch_dt_var, cnvtdatetime($start_datetime)) + 1
	pat->days_between = days
	pat->min_date = cnvtdatetime($start_datetime)
	pat->max_disch_date = max_disch_dt_var
	cnt = 0
Head e.encntr_id
	cnt += 1
	pat->rec_cnt = cnt
	call alterlist(pat->plist, cnt)
Detail
	pat->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	pat->plist[cnt].admitdt = e.reg_dt_tm
	pat->plist[cnt].dischdt = format(e.disch_dt_tm, 'mm/dd/yy hh:mm ;;q')
	pat->plist[cnt].pat_type = uar_get_code_display(e.encntr_type_cd)
	pat->plist[cnt].encntrid = e.encntr_id
	pat->plist[cnt].personid = e.person_id
	;Days
	dcnt = 1, tcnt = 1
	call alterlist(pat->plist[cnt].events, days)
	pat->plist[cnt].events[dcnt].activity_day = datetimetrunc(cnvtdatetime($start_datetime), "dd")
	if(  (datetimetrunc(e.reg_dt_tm, "dd")) = (datetimetrunc(cnvtdatetime($start_datetime), "dd")))
		;call echo(build2('Outside... = ',e.encntr_id, e.reg_dt_tm))
		pat->plist[cnt].events[dcnt].final_output_indicator = 'Final'
	endif
	dcnt += 1
	while(dcnt <= days)
		pat->plist[cnt].events[dcnt].activity_day = datetimeadd(cnvtdatetime($start_datetime), tcnt)
		if((datetimetrunc(e.reg_dt_tm, "dd")) = cnvtdatetime(pat->plist[cnt].events[dcnt].activity_day))
			;call echo(build2('while loop.... = ', e.encntr_id, e.reg_dt_tm))
			pat->plist[cnt].events[dcnt].final_output_indicator = 'Final'
		endif
		dcnt += 1
		tcnt += 1
	endwhile
 
with nocounter
 
IF(pat->rec_cnt > 0)
 
;------------------------------------------------------------------------------------------
 
;Demographic
 
select into $outdev
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, person p
	, encntr_alias ea
 
plan d
 
join p where p.person_id = pat->plist[d.seq].personid
	and p.active_ind = 1
 
join ea where ea.encntr_id = pat->plist[d.seq].encntrid
	and ea.active_ind = 1
	and ea.encntr_alias_type_cd = 1077
 
order by ea.encntr_id
 
Head ea.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,ea.encntr_id ,pat->plist[icnt].encntrid)
	if(idx > 0)
		pat->plist[idx].pat_name = p.name_full_formatted
		pat->plist[idx].fin = trim(ea.alias)
	endif
 
with nocounter
 
;------------------------------------------------------------------------------------------------------------------
;allergy documentation
 
select into $outdev
 
a.encntr_id, a.beg_effective_dt_tm ';;q', a.end_effective_dt_tm ';;q', n.source_string
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, allergy a
	, nomenclature n
 
plan d
 
join a where a.person_id = pat->plist[d.seq].personid
	and a.active_ind = 1
 
join n where n.nomenclature_id = a.substance_nom_id
	and n.active_ind = 1
	and cnvtlower(n.source_string) in('chlorhexidine topical', 'chlorhexidine gluconate')
	and cnvtlower(n.source_identifier) = 'd01231'
 
order by a.person_id, a.encntr_id
 
Head a.person_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5),a.person_id ,pat->plist[icnt].personid)
	while(idx > 0)
		pat->plist[idx].allergy_doc = trim(n.source_string)
		pat->plist[idx].allergy_doc_dt = format(a.created_dt_tm, 'mm/dd/yy hh:mm ;;q')
		pat->plist[idx].allergy_begdt = format(a.beg_effective_dt_tm, 'mm/dd/yy hh:mm ;;q')
		pat->plist[idx].allergy_enddt = format(a.end_effective_dt_tm, 'mm/dd/yy hh:mm ;;q')
	      idx = locateval(icnt,(idx+1) ,size(pat->plist,5),a.person_id ,pat->plist[icnt].personid)
	endwhile
 
with nocounter
 
;------------------------------------------------------------------------------------------------------------------
 
;chlorhexidine treatment
 
select into $outdev
ce.encntr_id, ce.event_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm ';;q'
, datepart = format(datetimetrunc(ce.event_end_dt_tm, "dd"), 'mm/dd/yy ;;q')
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, clinical_event ce
 
plan d
 
join ce where ce.encntr_id = pat->plist[d.seq].encntrid
	;and ce.event_end_dt_tm >= cnvtdatetime(pat->plist[d.seq].admitdt)
	and ce.event_cd =  chg_treat_var
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_tag != "Date\Time Correction"
 	/*and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
					and ce1.event_cd = ce.event_cd
					;and ce1.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
					and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
					and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
					group by ce1.encntr_id, ce1.event_cd)*/
 
order by ce.encntr_id, ce.event_id
 
Head ce.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,ce.encntr_id ,pat->plist[icnt].encntrid)
      ecnt = 0
Head ce.event_id
	dpart= datetimetrunc(ce.event_end_dt_tm, "dd")
	idt = 0
	idcnt = 0
      idt = locateval(idcnt ,1 ,size(pat->plist[idx].events,5), dpart, pat->plist[idx].events[idcnt].activity_day)
	     	pat->plist[idx].events[idt].chlor_treatment = trim(ce.result_val)
     		pat->plist[idx].events[idt].chg_complete_dt = format(ce.event_end_dt_tm, 'mm/dd/yy hh:mm ;;q')
 
with nocounter
 
;------------------------------------------------------------------------------------------------------------------
;Task information
 
select into $outdev
 
ta.encntr_id, task_status = uar_get_code_display(ta.task_status_cd), task_loc = uar_get_code_display(ta.location_cd)
,ta.task_create_dt_tm ';;q', ot.task_description, task_day = datetimetrunc(ta.task_create_dt_tm, "dd")
,datepart = format(datetimetrunc(ta.task_create_dt_tm, "dd"), 'mm/dd/yy ;;q')
, hour = datetimetrunc(ta.task_create_dt_tm, "hh") ';;q'
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, task_activity ta
	, order_task ot
 
plan d
 
join ta where ta.encntr_id = pat->plist[d.seq].encntrid
	;and ta.task_create_dt_tm >= cnvtdatetime(pat->plist[d.seq].admitdt)
	and ta.active_ind = 1
 
join ot where ot.reference_task_id = ta.reference_task_id
	and ot.task_description = "Perform Chlorhexidine Treatment"
	and ot.active_ind = 1
 
order by ta.encntr_id, ta.task_id, task_day
 
Head ta.encntr_id
	idx = 0
	icnt = 0
	task_list = fillstring(1000," ")
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,ta.encntr_id ,pat->plist[icnt].encntrid)
      tcnt = 0
Head task_day
	idt = 0
	idcnt = 0
      idt = locateval(idcnt ,1 ,size(pat->plist[idx].events,5), task_day, pat->plist[idx].events[idcnt].activity_day)
 
Head ta.task_id
      trunc_date = cnvtint(format(datetimetrunc(ta.task_create_dt_tm, "hh"), 'hh ;;q'))
      if(trunc_date < 19)
            pat->plist[idx].events[idt].1st_shift_tsk_dt = format(ta.task_create_dt_tm, 'mm/dd/yy hh:mm ;;q')
		pat->plist[idx].events[idt].1st_shift_tsk_status = uar_get_code_display(ta.task_status_cd)
	else
           	pat->plist[idx].events[idt].2nd_shift_tsk_dt = format(ta.task_create_dt_tm, 'mm/dd/yy hh:mm ;;q')
		pat->plist[idx].events[idt].2nd_shift_tsk_status = uar_get_code_display(ta.task_status_cd)
	endif
 
with nocounter
 
 
;------------------------------------------------------------------------------------------------------------------
;Task Not done reason
 
select into $outdev
ce.encntr_id, ce.event_title_text, ce.result_val
, datepart = format(datetimetrunc(ce.event_end_dt_tm, "dd"), 'mm/dd/yy ;;q')
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, clinical_event ce
 
plan d
 
join ce where ce.encntr_id = pat->plist[d.seq].encntrid
	;and ce.event_end_dt_tm >= cnvtdatetime(pat->plist[d.seq].admitdt)
	and trim(ce.event_title_text) = chg_task_var
	and ce.event_tag != "Date\Time Correction"
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	/*and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
					where ce1.encntr_id = ce.encntr_id
					and ce1.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
					and ce1.event_title_text = ce.event_title_text
					and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
					group by ce1.encntr_id, ce1.event_title_text)*/
 
order by ce.encntr_id, ce.event_id
 
Head ce.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,ce.encntr_id ,pat->plist[icnt].encntrid)
Head ce.event_id
      dpart= datetimetrunc(ce.event_end_dt_tm, "dd")
	idt = 0
	idcnt = 0
      idt = locateval(idcnt ,1 ,size(pat->plist[idx].events,5), dpart, pat->plist[idx].events[idcnt].activity_day)
      pat->plist[idx].events[idt].tsk_not_done_doc = trim(ce.result_val)
	pat->plist[idx].events[idt].tsk_not_done_doc_dt = format(ce.event_end_dt_tm, 'mm/dd/yy hh:mm ;;q')
 
with nocounter
 
;------------------------------------------------------------------------------------------------------------------
;Chg treatment Not Done Reason
 
select into $outdev
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, clinical_event ce
 
plan d
 
join ce where ce.encntr_id = pat->plist[d.seq].encntrid
	;and ce.event_end_dt_tm >= cnvtdatetime(pat->plist[d.seq].admitdt)
	and ce.event_cd = value(uar_get_code_by("DISPLAY", 72, "Chlorhexidine treatment"))
	and ce.result_val in("Not done due to patient allergy, Patient refused" , "Not done due to patient allergy" , "Patient refused")
	and ce.result_status_cd in (34.00, 25.00, 35.00)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.event_tag != "Date\Time Correction"
	/*and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
					where ce1.encntr_id = ce.encntr_id
					and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
					and ce.result_status_cd in (34.00, 25.00, 35.00)
					and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
					and ce1.event_cd = ce.event_cd
					group by ce1.encntr_id, ce1.event_cd)*/
 
order by ce.encntr_id, ce.event_id
 
Head ce.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,ce.encntr_id ,pat->plist[icnt].encntrid)
Head ce.event_id
      dpart= datetimetrunc(ce.event_end_dt_tm, "dd")
	idt = 0
	idcnt = 0
      idt = locateval(idcnt ,1 ,size(pat->plist[idx].events,5), dpart, pat->plist[idx].events[idcnt].activity_day)
	pat->plist[idx].events[idt].chg_not_done_doc = trim(ce.result_val)
	pat->plist[idx].events[idt].chg_not_done_doc_dt = format(ce.event_end_dt_tm, 'mm/dd/yy hh:mm ;;q')
 
with nocounter
 
 
;----------------------------------------------------------------------------------------------------------------
;CVL Start...
 
select into $outdev
ce.encntr_id, ce.event_id, event = uar_get_code_display(ce.event_cd), ce.result_val
, ce.event_end_dt_tm ';;q', ce.ce_dynamic_label_id
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, clinical_event ce
 
plan d
 
join ce where ce.encntr_id = pat->plist[d.seq].encntrid
	and ce.event_cd = central_line_var
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_tag != "Date\Time Correction"
	and cnvtlower(ce.result_val) in('present on admission','present on admission.','insert',
		'inserted','inserted in surgery/procedure', 'inserted in surgery/procedure.',
		'cl access port', 'assessment','cl assessment')
 
order by ce.encntr_id, ce.event_cd, ce.ce_dynamic_label_id, ce.event_end_dt_tm
 
Head report
	ecnt = 0
Head ce.encntr_id
	ecnt += 1
	call alterlist(cvl_labl->list, ecnt)
	cvl_labl->list[ecnt].encntrid = ce.encntr_id
	cvl_labl->list[ecnt].cvl_eventcd = ce.event_cd
	lcnt = 0
Head ce.ce_dynamic_label_id
	lcnt += 1
	call alterlist(cvl_labl->list[ecnt].cvl, lcnt)
	cvl_labl->list[ecnt].cvl[lcnt].cl_lbl_id = ce.ce_dynamic_label_id
 
with nocounter
 
;-------------------------------------------------------------------------------------------------------------
;Calculate cvl days
 
select into $outdev
ce.encntr_id, ce.event_id, event = uar_get_code_display(ce.event_cd), cvl_action = ce.result_val, ce.event_end_dt_tm ';;q'
,cvldays = cnvtstring(DATETIMECMP(cnvtdatetime(curdate, curtime), ce.event_end_dt_tm) ), ce.ce_dynamic_label_id
 
from 	(dummyt   d1  with seq = size(cvl_labl->list, 5))
	, (dummyt   d2  with seq = 1)
	, clinical_event ce
 
plan d1 where maxrec(d2, size(cvl_labl->list[d1.seq].cvl, 5))
join d2
 
join ce where ce.encntr_id = cvl_labl->list[d1.seq].encntrid
	and cvl_labl->list[d1.seq].cvl[d2.seq].cl_lbl_id > 0.0
	and ce.ce_dynamic_label_id = cvl_labl->list[d1.seq].cvl[d2.seq].cl_lbl_id
	and ce.event_cd = cvl_labl->list[d1.seq].cvl_eventcd
	and ce.event_id = (select min(ce1.event_id) from clinical_event ce1
				where ce1.encntr_id = ce.encntr_id
				and ce1.event_cd = ce.event_cd
				and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
				and ce1.event_tag != "Date\Time Correction"
				and ce1.ce_dynamic_label_id = ce.ce_dynamic_label_id
				and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
				group by ce1.encntr_id, ce1.event_cd, ce1.ce_dynamic_label_id)
 
order by ce.encntr_id, ce.event_cd, ce.ce_dynamic_label_id, ce.event_id
 
Head ce.ce_dynamic_label_id
	cvl_labl->list[d1.seq].cvl[d2.seq].cl_lbl_min_eventid = ce.event_id
	cvl_labl->list[d1.seq].cvl[d2.seq].cl_action = trim(ce.result_val)
	cvl_labl->list[d1.seq].cvl[d2.seq].cl_dt = ce.event_end_dt_tm
	cvl_labl->list[d1.seq].cvl[d2.seq].cl_days = cnvtstring(DATETIMECMP(cnvtdatetime(curdate, curtime), ce.event_end_dt_tm) )
 
with nocounter
 
;------------------------------------------------------------------------------------------------------------------
;Cvl indication & type
 
select into $outdev
 
ce.encntr_id, ce.event_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm ';;q', ce.ce_dynamic_label_id
 
from 	(dummyt   d1  with seq = size(cvl_labl->list, 5))
	, (dummyt   d2  with seq = 1)
	, clinical_event ce
 
plan d1 where maxrec(d2, size(cvl_labl->list[d1.seq].cvl, 5))
join d2
 
join ce where ce.encntr_id = cvl_labl->list[d1.seq].encntrid
	and cvl_labl->list[d1.seq].cvl[d2.seq].cl_lbl_id > 0.0
	and ce.ce_dynamic_label_id = cvl_labl->list[d1.seq].cvl[d2.seq].cl_lbl_id
	and ce.event_cd in(cvl_indication_var, cvl_type_var)
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
					and ce1.event_cd = ce.event_cd
					and ce1.ce_dynamic_label_id = ce.ce_dynamic_label_id
					and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
					and ce1.event_tag != "Date\Time Correction"
					and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
					group by ce1.encntr_id, ce1.event_cd, ce1.ce_dynamic_label_id)
 
order by ce.encntr_id, ce.ce_dynamic_label_id, ce.event_cd
 
Head ce.ce_dynamic_label_id
	tt = 0
Head ce.event_cd
	case(ce.event_cd)
      	of cvl_indication_var:
      		cvl_labl->list[d1.seq].cvl[d2.seq].cl_indicat = trim(ce.result_val)
      		cvl_labl->list[d1.seq].cvl[d2.seq].cl_ind_dt = ce.event_end_dt_tm
		of cvl_type_var:
			cvl_labl->list[d1.seq].cvl[d2.seq].cl_type = trim(ce.result_val)
			cvl_labl->list[d1.seq].cvl[d2.seq].cl_type_dt = ce.event_end_dt_tm
	endcase
 
with nocounter
 
;-------------------------------------------------------------------------------------------------------------
;Cvl discontinue...
 
select into $outdev
 
from 	(dummyt   d1  with seq = size(cvl_labl->list, 5))
	, (dummyt   d2  with seq = 1)
	, clinical_event ce
 
plan d1 where maxrec(d2, size(cvl_labl->list[d1.seq].cvl, 5))
join d2
 
join ce where ce.encntr_id = cvl_labl->list[d1.seq].encntrid
	and cvl_labl->list[d1.seq].cvl[d2.seq].cl_lbl_id > 0.0
	and ce.ce_dynamic_label_id = cvl_labl->list[d1.seq].cvl[d2.seq].cl_lbl_id
	and ce.event_cd = cvl_labl->list[d1.seq].cvl_eventcd
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_tag != "Date\Time Correction"
	and ce.result_val = "Discontinued"
 
order by ce.encntr_id, ce.event_cd, ce.ce_dynamic_label_id, ce.event_id
 
Head ce.ce_dynamic_label_id
	cvl_labl->list[d1.seq].cvl[d2.seq].cl_discon_dt = ce.event_end_dt_tm
 
with nocounter
 
;-------------------------------------------------------------------------------------------------------------
;Move CVL data to Master RS
 /*
;Action
select into $outdev
 
enc = cvl_labl->list[d1.seq].encntrid, beg_dt = cvl_labl->list[d1.seq].cvl[d2.seq].cl_dt
 
from 	(dummyt   d1  with seq = size(cvl_labl->list, 5))
	, (dummyt   d2  with seq = 1)
 
plan d1 where maxrec(d2, size(cvl_labl->list[d1.seq].cvl, 5))
join d2 where cnvtlower(cvl_labl->list[d1.seq].cvl[d2.seq].cl_type)!= "straight/intermittent"
 
order by enc, beg_dt
 
Head enc
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,enc ,pat->plist[icnt].encntrid)
      lcnt = 0
Head beg_dt
	dpart= datetimetrunc(cnvtdatetime(cvl_labl->list[d1.seq].cvl[d2.seq].cl_dt), "dd")
	idt = 0
	idcnt = 0
      idt = locateval(idcnt ,1 ,size(pat->plist[idx].events,5), dpart, pat->plist[idx].events[idcnt].activity_day)
	pat->plist[idx].events[idt].cvl_action = cvl_labl->list[d1.seq].cvl[d2.seq].cl_action
	pat->plist[idx].events[idt].cvl_beg_dt = format(cvl_labl->list[d1.seq].cvl[d2.seq].cl_dt, 'mm/dd/yyyy hh:mm:ss ;;q')
with nocounter
 
;-----------------------------------------------------
;Indication
select into $outdev
 
enc = cvl_labl->list[d1.seq].encntrid, beg_dt = cvl_labl->list[d1.seq].cvl[d2.seq].cl_ind_dt
 
from 	(dummyt   d1  with seq = size(cvl_labl->list, 5))
	, (dummyt   d2  with seq = 1)
 
plan d1 where maxrec(d2, size(cvl_labl->list[d1.seq].cvl, 5))
join d2 where cnvtlower(cvl_labl->list[d1.seq].cvl[d2.seq].cl_type)!= "straight/intermittent"
 
order by enc, beg_dt
 
Head enc
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,enc ,pat->plist[icnt].encntrid)
      lcnt = 0
Head beg_dt
	dpart= datetimetrunc(cnvtdatetime(cvl_labl->list[d1.seq].cvl[d2.seq].cl_ind_dt), "dd")
	;call echo(build('dpart = ',dpart))
	idt = 0
	idcnt = 0
      idt = locateval(idcnt ,1 ,size(pat->plist[idx].events,5), dpart, pat->plist[idx].events[idcnt].activity_day)
	pat->plist[idx].events[idt].cvl_indcat = cvl_labl->list[d1.seq].cvl[d2.seq].cl_indicat
	pat->plist[idx].events[idt].cvl_indcat_dt = format(cvl_labl->list[d1.seq].cvl[d2.seq].cl_ind_dt, 'mm/dd/yyyy hh:mm:ss ;;q')
with nocounter
 
;-----------------------------------------------------
;Type
select into $outdev
 
enc = cvl_labl->list[d1.seq].encntrid, beg_dt = cvl_labl->list[d1.seq].cvl[d2.seq].cl_type_dt
 
from 	(dummyt   d1  with seq = size(cvl_labl->list, 5))
	, (dummyt   d2  with seq = 1)
 
plan d1 where maxrec(d2, size(cvl_labl->list[d1.seq].cvl, 5))
join d2 where cnvtlower(cvl_labl->list[d1.seq].cvl[d2.seq].cl_type)!= "straight/intermittent"
 
order by enc, beg_dt
 
Head enc
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,enc ,pat->plist[icnt].encntrid)
      lcnt = 0
Head beg_dt
	dpart= datetimetrunc(cnvtdatetime(cvl_labl->list[d1.seq].cvl[d2.seq].cl_type_dt), "dd")
	idt = 0
	idcnt = 0
      idt = locateval(idcnt ,1 ,size(pat->plist[idx].events,5), dpart, pat->plist[idx].events[idcnt].activity_day)
	pat->plist[idx].events[idt].cvl_typ = cvl_labl->list[d1.seq].cvl[d2.seq].cl_type
with nocounter
 
;-----------------------------------------------------
;Discontinue
select into $outdev
 
enc = cvl_labl->list[d1.seq].encntrid, beg_dt = cvl_labl->list[d1.seq].cvl[d2.seq].cl_discon_dt
 
from 	(dummyt   d1  with seq = size(cvl_labl->list, 5))
	, (dummyt   d2  with seq = 1)
 
plan d1 where maxrec(d2, size(cvl_labl->list[d1.seq].cvl, 5))
join d2 where cnvtlower(cvl_labl->list[d1.seq].cvl[d2.seq].cl_type)!= "straight/intermittent"
 
order by enc, beg_dt
 
Head enc
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,enc ,pat->plist[icnt].encntrid)
      lcnt = 0
Head beg_dt
	dpart= datetimetrunc(cnvtdatetime(cvl_labl->list[d1.seq].cvl[d2.seq].cl_discon_dt), "dd")
	idt = 0
	idcnt = 0
      idt = locateval(idcnt ,1 ,size(pat->plist[idx].events,5), dpart, pat->plist[idx].events[idcnt].activity_day)
	pat->plist[idx].events[idt].cvl_end_dt = format(cvl_labl->list[d1.seq].cvl[d2.seq].cl_discon_dt, 'mm/dd/yyyy hh:mm:ss ;;q')
with nocounter
 */
;-------------------------------------------------------------------------------------------------------------
;Foley Start...
 
select into $outdev
ce.encntr_id, ce.event_id, event = uar_get_code_display(ce.event_cd), ce.result_val
, ce.event_end_dt_tm ';;q', ce.ce_dynamic_label_id
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, clinical_event ce
 
plan d
 
join ce where ce.encntr_id = pat->plist[d.seq].encntrid
	and ce.event_cd = urinary_cath_var
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and cnvtlower(ce.result_val) in('present on admission','present on admission.','uc present on admission','insert',
		'inserted','inserted in surgery/procedure', 'inserted in surgery/procedure.', 'sn - cath - inserted',
		'uc inserted in surgery/procedure', 'assessment')
	/*and not exists (select ce2.encntr_id from clinical_event ce2
			where(ce2.encntr_id = ce.encntr_id
			and ce2.event_cd = ce.event_cd
			and ce2.ce_dynamic_label_id = ce.ce_dynamic_label_id
			and cnvtlower(ce2.result_val) = "discontinued"))*/
 
order by ce.encntr_id, ce.event_cd, ce.ce_dynamic_label_id, ce.event_end_dt_tm
 
with nocounter, separator=" ", format, time = 120

go to exitscript
 
 
/* 
Head report
	fecnt = 0
Head ce.encntr_id
	fecnt += 1
	call alterlist(fol_labl->list, fecnt)
	fol_labl->list[fecnt].encntrid = ce.encntr_id
	flcnt = 0
Head ce.ce_dynamic_label_id
	flcnt += 1
	call alterlist(fol_labl->list[fecnt].fol, flcnt)
	fol_labl->list[fecnt].fol[flcnt].fl_lbl_id = ce.ce_dynamic_label_id
	fol_labl->list[fecnt].fol[flcnt].fl_eventcd = ce.event_cd

Foot ce.encntr_id
	fol_labl->list[fecnt].fl_cnt = flcnt
 
with nocounter
 */
;--------------------------------------------------------------------------------------------------------------------------------
;Surginet Foley
 
select into $outdev
ce.encntr_id, ce.event_id, event = uar_get_code_display(ce.event_cd), ce.result_val
, ce.event_end_dt_tm ';;q', ce.ce_dynamic_label_id
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, clinical_event ce
 
plan d
 
join ce where ce.encntr_id = pat->plist[d.seq].encntrid
	and ce.event_cd in(sn_urinary_cath_var, sn_cath_var, sn_cath_type_var)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_tag != "Date\Time Correction"
 
order by ce.encntr_id, ce.parent_event_id, ce.event_cd

Head ce.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(fol_labl->list,5), ce.encntr_id ,fol_labl->list[icnt].encntrid)
      if(idx > 0)
      	fecnt = idx
		flcnt = fol_labl->list[idx].fl_cnt
	else
		flcnt = 0, fecnt += 1
		call alterlist(fol_labl->list, fecnt)
		fol_labl->list[fecnt].encntrid = ce.encntr_id
	endif
 
Head ce.parent_event_id
	flcnt += 1
	call alterlist(fol_labl->list[fecnt].fol, flcnt)
Head ce.event_cd
	case(ce.event_cd)
		of sn_urinary_cath_var: ;either one of cath below(overright)
			fol_labl->list[fecnt].fol[flcnt].fl_action = uar_get_code_display(ce.event_cd)
			fol_labl->list[fecnt].fol[flcnt].fl_lbl_min_eventid = ce.event_id
			fol_labl->list[fecnt].fol[flcnt].fl_eventcd = ce.event_cd
			fol_labl->list[fecnt].fol[flcnt].fl_parent_eventid = ce.parent_event_id
			fol_labl->list[fecnt].fol[flcnt].fl_dt = ce.event_end_dt_tm
		of sn_cath_var:
			fol_labl->list[fecnt].fol[flcnt].fl_action = uar_get_code_display(ce.event_cd)
			fol_labl->list[fecnt].fol[flcnt].fl_lbl_min_eventid = ce.event_id
			fol_labl->list[fecnt].fol[flcnt].fl_eventcd = ce.event_cd
			fol_labl->list[fecnt].fol[flcnt].fl_parent_eventid = ce.parent_event_id
			fol_labl->list[fecnt].fol[flcnt].fl_dt = ce.event_end_dt_tm
		of sn_cath_type_var:	
			fol_labl->list[fecnt].fol[flcnt].fl_type = trim(ce.result_val)
	endcase
 
Foot ce.encntr_id
	fol_labl->list[fecnt].fl_cnt = flcnt

with nocounter

;---------------------------------------------------------------------------------------------------
;Get CE date (overright the event_dt_tm if ce dat available)
 
select into $outdev
 
from 	(dummyt   d1  with seq = size(fol_labl->list, 5))
	, (dummyt   d2  with seq = 1)
	, clinical_event ce
	, ce_date_result cdr
 
plan d1 where maxrec(d2, size(fol_labl->list[d1.seq].fol, 5))
join d2
 
join ce where ce.parent_event_id = fol_labl->list[d1.seq].fol[d2.seq].fl_parent_eventid
	and ce.event_cd = sn_cath_time_var
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_tag != "Date\Time Correction"
 
join cdr where cdr.event_id = ce.event_id
 
order by ce.parent_event_id, ce.event_id
 
Head ce.parent_event_id
	fol_labl->list[d1.seq].fol[d2.seq].fl_dt = cdr.result_dt_tm
 
with nocounter

 
;-----------------------------------------------------------------------------------------------------------------------------
;Calculate Foley days
 
select into $outdev
ce.encntr_id, ce.event_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm ';;q'
,foleydays = cnvtstring(DATETIMECMP(cnvtdatetime(curdate, curtime), ce.event_end_dt_tm) ), ce.ce_dynamic_label_id
 
from 	(dummyt   d1  with seq = size(fol_labl->list, 5))
	, (dummyt   d2  with seq = 1)
	, clinical_event ce
 
plan d1 where maxrec(d2, size(fol_labl->list[d1.seq].fol, 5))
join d2 where fol_labl->list[d1.seq].fol[d2.seq].fl_lbl_id > 0.0
 
join ce where ce.encntr_id = fol_labl->list[d1.seq].encntrid
	and fol_labl->list[d1.seq].fol[d2.seq].fl_lbl_id > 0.0
	and ce.ce_dynamic_label_id = fol_labl->list[d1.seq].fol[d2.seq].fl_lbl_id
	and ce.event_cd = fol_labl->list[d1.seq].fol[d2.seq].fl_eventcd
	and ce.event_id = (select min(ce1.event_id) from clinical_event ce1
				where ce1.encntr_id = ce.encntr_id
				and ce1.event_cd = ce.event_cd
				and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
				and ce1.event_tag != "Date\Time Correction"
				and ce1.ce_dynamic_label_id = ce.ce_dynamic_label_id
				and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
				group by ce1.encntr_id, ce1.event_cd, ce1.ce_dynamic_label_id)
 
order by ce.encntr_id, ce.event_cd, ce.ce_dynamic_label_id, ce.event_id

Head ce.ce_dynamic_label_id
	fol_labl->list[d1.seq].fol[d2.seq].fl_lbl_min_eventid = ce.event_id
	fol_labl->list[d1.seq].fol[d2.seq].fl_action = trim(ce.result_val)
	fol_labl->list[d1.seq].fol[d2.seq].fl_dt = ce.event_end_dt_tm
	fol_labl->list[d1.seq].fol[d2.seq].fl_days = cnvtstring(DATETIMECMP(cnvtdatetime(curdate, curtime), ce.event_end_dt_tm) )
 
with nocounter

;------------------------------------------------------------------------------------------------------------------
;Foley indication & type
 
select into $outdev
 
ce.encntr_id, ce.event_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm ';;q', ce.ce_dynamic_label_id
 
from 	(dummyt   d1  with seq = size(fol_labl->list, 5))
	, (dummyt   d2  with seq = 1)
	, clinical_event ce
 
plan d1 where maxrec(d2, size(fol_labl->list[d1.seq].fol, 5))
join d2 where fol_labl->list[d1.seq].fol[d2.seq].fl_lbl_id > 0.0
 
join ce where ce.encntr_id = fol_labl->list[d1.seq].encntrid
	and fol_labl->list[d1.seq].fol[d2.seq].fl_lbl_id > 0.0
	and ce.ce_dynamic_label_id = fol_labl->list[d1.seq].fol[d2.seq].fl_lbl_id
	and ce.event_cd in(foley_indication_var, foley_type_var)
	and ce.event_id = (select min(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
					and ce1.event_cd = ce.event_cd
					and ce1.ce_dynamic_label_id = ce.ce_dynamic_label_id
					and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
					;and cnvtlower(ce1.result_val)!= "straight/intermittent"
					and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
					group by ce1.encntr_id, ce1.event_cd)
 
order by ce.encntr_id, ce.ce_dynamic_label_id, ce.event_cd
 
Head ce.ce_dynamic_label_id
	tt = 0
Head ce.event_cd
	case(ce.event_cd)
      	of foley_indication_var:
      		fol_labl->list[d1.seq].fol[d2.seq].fl_indicat = trim(ce.result_val)
      		fol_labl->list[d1.seq].fol[d2.seq].fl_ind_dt = ce.event_end_dt_tm
		of foley_type_var:
			fol_labl->list[d1.seq].fol[d2.seq].fl_type = trim(ce.result_val)
			fol_labl->list[d1.seq].fol[d2.seq].fl_type_dt = ce.event_end_dt_tm
	endcase
 
with nocounter
 
;---------------------------------------------------------------------------------------------------
;Foley discontinue...
 
select into $outdev
 
from 	(dummyt   d1  with seq = size(fol_labl->list, 5))
	, (dummyt   d2  with seq = 1)
	, clinical_event ce
 
plan d1 where maxrec(d2, size(fol_labl->list[d1.seq].fol, 5))
join d2 where fol_labl->list[d1.seq].fol[d2.seq].fl_lbl_id > 0.0
 
join ce where ce.encntr_id = fol_labl->list[d1.seq].encntrid
	and fol_labl->list[d1.seq].fol[d2.seq].fl_lbl_id > 0.0
	and ce.ce_dynamic_label_id = fol_labl->list[d1.seq].fol[d2.seq].fl_lbl_id
	and ce.event_cd = fol_labl->list[d1.seq].fol[d2.seq].fl_eventcd
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_tag != "Date\Time Correction"
	and ce.result_val = "Discontinued"
 
order by ce.encntr_id, ce.event_cd, ce.ce_dynamic_label_id, ce.event_id
 
Head ce.ce_dynamic_label_id
	fol_labl->list[d1.seq].fol[d2.seq].fl_discon_dt = ce.event_end_dt_tm
 
with nocounter
 
call echorecord(fol_labl) 

;----------------------------------------------------------------------------------------------------------------
;Move Foley data to Master RS
 
;Action
select into $outdev
 
enc = fol_labl->list[d1.seq].encntrid, beg_dt = fol_labl->list[d1.seq].fol[d2.seq].fl_dt ';;q'
, action = trim(substring(1,100,fol_labl->list[d1.seq].fol[d2.seq].fl_action))
, eventid = fol_labl->list[d1.seq].fol[d2.seq].fl_lbl_min_eventid
, dtpart = datetimetrunc(cnvtdatetime(fol_labl->list[d1.seq].fol[d2.seq].fl_dt), "dd")
 
from 	(dummyt   d1  with seq = size(fol_labl->list, 5))
	, (dummyt   d2  with seq = 1)
 
plan d1 where maxrec(d2, size(fol_labl->list[d1.seq].fol, 5))
join d2 where cnvtlower(fol_labl->list[d1.seq].fol[d2.seq].fl_type)!= "straight/intermittent"
 
order by enc, beg_dt, eventid 

Head enc
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,enc ,pat->plist[icnt].encntrid)
Head dtpart
      lcnt = 0
	dpart= datetimetrunc(cnvtdatetime(fol_labl->list[d1.seq].fol[d2.seq].fl_dt), "dd")
	idt = 0
	idcnt = 0
      idt = locateval(idcnt ,1 ,size(pat->plist[idx].events,5), dpart, pat->plist[idx].events[idcnt].activity_day)
Head eventid      
	lcnt += 1
	call alterlist(pat->plist[idx]->events[idt].lines, lcnt)
Detail
	pat->plist[idx].events[idt].lines[lcnt].foley_action = fol_labl->list[d1.seq].fol[d2.seq].fl_action
	pat->plist[idx].events[idt].lines[lcnt].foley_beg_dt = format(fol_labl->list[d1.seq].fol[d2.seq].fl_dt, 'mm/dd/yyyy hh:mm:ss ;;q')
	
with nocounter

;call echorecord(pat)
;go to exitscript


;-----------------------------------------------------
;Indication
/*
select into $outdev
 
enc = fol_labl->list[d1.seq].encntrid, beg_dt = fol_labl->list[d1.seq].fol[d2.seq].fl_ind_dt ';;q'
, foley_indcat = trim(substring(1,100,fol_labl->list[d1.seq].fol[d2.seq].fl_indicat))
, dtpart = datetimetrunc(cnvtdatetime(fol_labl->list[d1.seq].fol[d2.seq].fl_ind_dt), "dd")
, eventid = fol_labl->list[d1.seq].fol[d2.seq].fl_lbl_min_eventid
 
from 	(dummyt   d1  with seq = size(fol_labl->list, 5))
	, (dummyt   d2  with seq = 1)
 
plan d1 where maxrec(d2, size(fol_labl->list[d1.seq].fol, 5))
join d2 where cnvtlower(fol_labl->list[d1.seq].fol[d2.seq].fl_type)!= "straight/intermittent"
 
order by enc, beg_dt, eventid

with nocounter, separator=" ", format, time = 120

go to exitscript
 
 /*
Head enc
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,enc ,pat->plist[icnt].encntrid)
Head beg_dt
      ;lcnt = 0
	dpart= datetimetrunc(cnvtdatetime(fol_labl->list[d1.seq].fol[d2.seq].fl_ind_dt), "dd")
	idt = 0
	idcnt = 0
      idt = locateval(idcnt ,1 ,size(pat->plist[idx].events,5), dpart, pat->plist[idx].events[idcnt].activity_day)
Head eventid      
	;lcnt += 1
	;call alterlist(pat->plist[idx]->events[idt].lines, lcnt)
Detail
	pat->plist[idx].events[idt].lines[lcnt].foley_indcat = fol_labl->list[d1.seq].fol[d2.seq].fl_indicat
	pat->plist[idx].events[idt].lines[lcnt].foley_indcat_dt = format(fol_labl->list[d1.seq].fol[d2.seq].fl_ind_dt, 'mm/dd/yyyy hh:mm:ss ;;q')
with nocounter
 
 
Head enc
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,enc ,pat->plist[icnt].encntrid)
Head dtpart
      lcnt = 0
	dpart= datetimetrunc(cnvtdatetime(fol_labl->list[d1.seq].fol[d2.seq].fl_ind_dt), "dd")
	idt = 0
	idcnt = 0
      idt = locateval(idcnt ,1 ,size(pat->plist[idx].events,5), dpart, pat->plist[idx].events[idcnt].activity_day)
Head eventid      
	lcnt += 1
	call alterlist(pat->plist[idx]->events[idt].lines, lcnt)
Detail
	pat->plist[idx].events[idt].lines[lcnt].foley_indcat = fol_labl->list[d1.seq].fol[d2.seq].fl_indicat
	pat->plist[idx].events[idt].lines[lcnt].foley_indcat_dt = format(fol_labl->list[d1.seq].fol[d2.seq].fl_ind_dt, 'mm/dd/yyyy hh:mm:ss ;;q')
with nocounter */

call echorecord(pat)
go to exitscript

 
;-----------------------------------------------------
;Type
select into $outdev
 
enc = fol_labl->list[d1.seq].encntrid, beg_dt = fol_labl->list[d1.seq].fol[d2.seq].fl_type_dt
, dtpart = datetimetrunc(cnvtdatetime(fol_labl->list[d1.seq].fol[d2.seq].fl_dt), "dd")
, eventid = fol_labl->list[d1.seq].fol[d2.seq].fl_lbl_min_eventid
 
from 	(dummyt   d1  with seq = size(fol_labl->list, 5))
	, (dummyt   d2  with seq = 1)
 
plan d1 where maxrec(d2, size(fol_labl->list[d1.seq].fol, 5))
join d2 where cnvtlower(fol_labl->list[d1.seq].fol[d2.seq].fl_type)!= "straight/intermittent"
 
order by enc, beg_dt, eventid
 
Head enc
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,enc ,pat->plist[icnt].encntrid)
Head dtpart
      lcnt = 0
	dpart= datetimetrunc(cnvtdatetime(fol_labl->list[d1.seq].fol[d2.seq].fl_type_dt), "dd")
	idt = 0
	idcnt = 0
      idt = locateval(idcnt ,1 ,size(pat->plist[idx].events,5), dpart, pat->plist[idx].events[idcnt].activity_day)
Head eventid      
	lcnt += 1
	call alterlist(pat->plist[idx]->events[idt].lines, lcnt)
Detail
	pat->plist[idx].events[idt].lines[lcnt].foley_typ = fol_labl->list[d1.seq].fol[d2.seq].fl_type
with nocounter
 
;-----------------------------------------------------
;Discontinue
select into $outdev

enc = fol_labl->list[d1.seq].encntrid, beg_dt = fol_labl->list[d1.seq].fol[d2.seq].fl_discon_dt
, dtpart = datetimetrunc(cnvtdatetime(fol_labl->list[d1.seq].fol[d2.seq].fl_discon_dt), "dd")
, eventid = fol_labl->list[d1.seq].fol[d2.seq].fl_lbl_min_eventid
 
from 	(dummyt   d1  with seq = size(fol_labl->list, 5))
	, (dummyt   d2  with seq = 1)
 
plan d1 where maxrec(d2, size(fol_labl->list[d1.seq].fol, 5))
join d2 where cnvtlower(fol_labl->list[d1.seq].fol[d2.seq].fl_type)!= "straight/intermittent"
 
order by enc, beg_dt, eventid
 
Head enc
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,enc ,pat->plist[icnt].encntrid)
      lcnt = 0
Head dtpart
	dpart= datetimetrunc(cnvtdatetime(fol_labl->list[d1.seq].fol[d2.seq].fl_discon_dt), "dd")
	idt = 0
	idcnt = 0
      idt = locateval(idcnt ,1 ,size(pat->plist[idx].events,5), dpart, pat->plist[idx].events[idcnt].activity_day)
Head eventid      
	lcnt += 1
	call alterlist(pat->plist[idx]->events[idt].lines, lcnt)
Detail
	pat->plist[idx].events[idt].lines[lcnt].foley_end_dt = format(fol_labl->list[d1.seq].fol[d2.seq].fl_discon_dt, 'mm/dd/yyyy hh:mm:ss ;;q')
with nocounter 
 
;--------------------------------------------------------------------------------------------------------------------------------
 
 
;------------------------------------
call echorecord(pat)
go to exitscript
;------------------------------------
 
/************** Ops Job *****************/
 /*
;if(iOpsInd = 1) ;Ops
  if($to_file = 0)  ;To File
 
   Select into value(filename_var)
 
	from (dummyt d WITH seq = value(size(pat->plist,5)))
	order by d.seq
 
	;build output
	Head report
		file_header_var = build(
		wrap3("Start dt")
		,wrap3("End dt")
		,wrap3("facility")
		,wrap3("nurse_unit")
		,wrap3("fin")
		,wrap3("patient_name")
		,wrap3("patient_type")
		,wrap3("admit_dt")
		,wrap3("disch_dt")
		,wrap3("allergy_doc")
		,wrap3("allergy_doc_dt")
		,wrap3("allergy_beg_dt")
		,wrap3("allergy_end_dt")
		,wrap3("task_not_done_doc")
		,wrap3("task_not_done_doc_dt")
		,wrap3("cvl_action")
		,wrap3("cvl_beg_dt")
		,wrap3("cvl_end_dt")
		,wrap3("cvl_indcation")
		,wrap3("cvl_indcation_dt")
		,wrap3("cvl_type")
		,wrap3("foley_indcation")
		,wrap3("foley_indcation_dt")
		,wrap3("foley_action")
		,wrap3("foley_beg_dt")
		,wrap3("foley_end_dt")
		,wrap3("foley_type")
		,wrap3("chlorhx_treatment")
		,wrap3("chg_complete_dt")
		,wrap3("chg_not_done_doc")
		,wrap3("chg_not_done_doc_dt")
		,wrap3("1st_shift_tsk_dt")
		,wrap3("1st_shift_tsk_status")
		,wrap3("2nd_shift_tsk_dt")
		,wrap3("2nd_shift_tsk_status")
		,wrap3("person_id")
		,wrap1("encntr_id") )
 
 	col 0 file_header_var
	row + 1
 
 	Head d.seq
		output_orders = ""
		output_orders = build(output_orders
			,wrap3(format(cnvtdatetime($start_datetime), 'mm/dd/yyyy hh:mm;;q'))
			,wrap3(format(cnvtdatetime($end_datetime), 'mm/dd/yyyy hh:mm;;q'))
			,wrap3(pat->plist[d.seq].facility)
			,wrap3(pat->plist[d.seq].unit)
			,wrap3(pat->plist[d.seq].fin)
			,wrap3(pat->plist[d.seq].pat_name)
			,wrap3(pat->plist[d.seq].pat_type)
			,wrap3(format(pat->plist[d.seq].admitdt, 'mm/dd/yyyy hh:mm;;q'))
			,wrap3(pat->plist[d.seq].dischdt)
			,wrap3(pat->plist[d.seq].allergy_doc)
			,wrap3(pat->plist[d.seq].allergy_doc_dt)
			,wrap3(pat->plist[d.seq].allergy_begdt)
			,wrap3(pat->plist[d.seq].allergy_enddt)
			,wrap3(pat->plist[d.seq].tsk_not_done_doc)
			,wrap3(pat->plist[d.seq].tsk_not_done_doc_dt)
			,wrap3(pat->plist[d.seq].cvl_action)
			,wrap3(pat->plist[d.seq].cvl_beg_dt)
			,wrap3(pat->plist[d.seq].cvl_end_dt)
			,wrap3(pat->plist[d.seq].cvl_indcat)
			,wrap3(pat->plist[d.seq].cvl_indcat_dt)
			,wrap3(pat->plist[d.seq].cvl_typ)
			,wrap3(pat->plist[d.seq].foley_indcat)
			,wrap3(pat->plist[d.seq].foley_indcat_dt)
			,wrap3(pat->plist[d.seq].foley_action)
			,wrap3(pat->plist[d.seq].foley_beg_dt)
			,wrap3(pat->plist[d.seq].foley_end_dt)
			,wrap3(pat->plist[d.seq].foley_typ)
			,wrap3(pat->plist[d.seq].chlor_treatment)
			,wrap3(pat->plist[d.seq].chg_complete_dt)
			,wrap3(pat->plist[d.seq].chg_not_done_doc)
			,wrap3(pat->plist[d.seq].chg_not_done_doc_dt)
			,wrap3(pat->plist[d.seq].1st_shift_tsk_dt)
			,wrap3(pat->plist[d.seq].1st_shift_tsk_status)
			,wrap3(pat->plist[d.seq].2nd_shift_tsk_dt)
			,wrap3(pat->plist[d.seq].2nd_shift_tsk_status)
			,wrap3(cnvtstring(pat->plist[d.seq].personid))
			,wrap1(cnvtstring(pat->plist[d.seq].encntrid))  )
 
		output_orders = trim(output_orders, 3)
		output_orders = replace(replace(output_orders ,char(13)," "),char(10)," ")
 
	 Foot d.seq
	 	col 0 output_orders
	 	row + 1
 
	with time = 30, nocounter, maxcol = 32000, format = stream, formfeed = none;, maxrow = 0
 
	;Move file to Astream folder
  	set cmd = build2("mv ", ccl_filepath_var, " ", astream_filepath_var) ;to move only in prod
    	;copy file - only for testing
  	;set cmd = build2("cp ", ccl_filepath_var, " ", astream_filepath_var)
 
	set len = size(trim(cmd))
 	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
 
  endif ;To File
;endif ;ops */
 
;---------------------------------------------------------------------------------------------------------------------
 
 
If($to_file = 1) ;Screen Display
 
select into $outdev
 
 	start_date = $start_datetime
 	, end_date = $end_datetime
	, facility = trim(substring(1, 30, pat->plist[d1.seq].facility))
	, nurse_unit = trim(substring(1, 30, pat->plist[d1.seq].unit))
	, fin = trim(substring(1, 30, pat->plist[d1.seq].fin))
	, pat_name = trim(substring(1, 50, pat->plist[d1.seq].pat_name))
	, pat_type = trim(substring(1, 30, pat->plist[d1.seq].pat_type))
	, encntrid = pat->plist[d1.seq].encntrid
	, personid = pat->plist[d1.seq].personid
	, admit_dt = format(pat->plist[d1.seq].admitdt, 'mm/dd/yy hh:mm ;;q')
	, disch_dt = trim(substring(1, 30, pat->plist[d1.seq].dischdt))
	;, final1 = trim(substring(1, 05, pat->plist[d1.seq].events[d2.seq].final_output_indicator))
	;, act_dt = format(pat->plist[d1.seq].events[d2.seq].activity_day, 'mm/dd/yy hh:mm ;;q')
 	, cvl_action = trim(substring(1, 100, pat->plist[d1.seq].events[d2.seq].cvl_action))
	, cvl_beg_dt = trim(substring(1, 30, pat->plist[d1.seq].events[d2.seq].cvl_beg_dt))
	, cvl_end_dt = trim(substring(1, 30, pat->plist[d1.seq].events[d2.seq].cvl_end_dt))
	, cvl_indcat = trim(substring(1, 100, pat->plist[d1.seq].events[d2.seq].cvl_indcat))
	, cvl_indcat_dt = trim(substring(1, 30, pat->plist[d1.seq].events[d2.seq].cvl_indcat_dt))
	, cvl_type = trim(substring(1, 100, pat->plist[d1.seq].events[d2.seq].cvl_typ))
	, foley_indcat = trim(substring(1, 100, pat->plist[d1.seq].events[d2.seq].foley_indcat))
	, foley_indcat_dt = trim(substring(1, 30, pat->plist[d1.seq].events[d2.seq].foley_indcat_dt))
	, foley_action = trim(substring(1, 100, pat->plist[d1.seq].events[d2.seq].foley_action))
	, foley_beg_dt = trim(substring(1, 30, pat->plist[d1.seq].events[d2.seq].foley_beg_dt))
	, foley_end_dt = trim(substring(1, 30, pat->plist[d1.seq].events[d2.seq].foley_end_dt))
	, foley_type = trim(substring(1, 100, pat->plist[d1.seq].events[d2.seq].foley_typ))
 	, chlorhexidine_treatment = trim(substring(1, 100, pat->plist[d1.seq].events[d2.seq].chlor_treatment))
	, chg_complete_dt = trim(substring(1, 30, pat->plist[d1.seq].events[d2.seq].chg_complete_dt))
	, chg_not_done_doc = trim(substring(1, 100, pat->plist[d1.seq].events[d2.seq].chg_not_done_doc))
	, chg_not_done_doc_dt = trim(substring(1, 30, pat->plist[d1.seq].events[d2.seq].chg_not_done_doc_dt))
	, 1st_shift_task_dt = trim(substring(1, 30, pat->plist[d1.seq].events[d2.seq].1st_shift_tsk_dt))
	, 1st_shift_task_status = trim(substring(1, 30, pat->plist[d1.seq].events[d2.seq].1st_shift_tsk_status))
	, 2nd_shift_task_dt = trim(substring(1, 30, pat->plist[d1.seq].events[d2.seq].2nd_shift_tsk_dt))
	, 2nd_shift_task_status = trim(substring(1, 30, pat->plist[d1.seq].events[d2.seq].2nd_shift_tsk_status))
	, task_not_done_doc = trim(substring(1, 100, pat->plist[d1.seq].events[d2.seq].tsk_not_done_doc))
	, task_not_done_doc_dt = trim(substring(1, 30, pat->plist[d1.seq].events[d2.seq].tsk_not_done_doc_dt))
	, allergy_doc = trim(substring(1, 50, pat->plist[d1.seq].allergy_doc))
	, allergy_doc_dt = trim(substring(1, 30, pat->plist[d1.seq].allergy_doc_dt))
	, allergy_beg_dt = trim(substring(1, 30, pat->plist[d1.seq].allergy_begdt))
	, allergy_end_dt = trim(substring(1, 30, pat->plist[d1.seq].allergy_enddt))
 
from
	(dummyt   d1  with seq = size(pat->plist, 5))
	, (dummyt   d2  with seq = 1)
 
plan d1 where maxrec(d2, size(pat->plist[d1.seq].events, 5))
join d2
where ;(trim(substring(1, 30, pat->plist[d1.seq].fin)) != ''
 
 ( trim(substring(1, 05, pat->plist[d1.seq].events[d2.seq].final_output_indicator)) != ''
 	or trim(substring(1, 100, pat->plist[d1.seq].events[d2.seq].cvl_action)) != ''
	or trim(substring(1, 30, pat->plist[d1.seq].events[d2.seq].cvl_beg_dt)) != ''
	or trim(substring(1, 100, pat->plist[d1.seq].events[d2.seq].chlor_treatment)) != ''
	or trim(substring(1, 30, pat->plist[d1.seq].events[d2.seq].cvl_end_dt)) != ''
	or trim(substring(1, 100, pat->plist[d1.seq].events[d2.seq].cvl_indcat)) != ''
	or trim(substring(1, 30, pat->plist[d1.seq].events[d2.seq].cvl_indcat_dt)) != ''
	or trim(substring(1, 100, pat->plist[d1.seq].events[d2.seq].cvl_typ)) != ''
	or trim(substring(1, 100, pat->plist[d1.seq].events[d2.seq].foley_indcat)) != ''
	or trim(substring(1, 30, pat->plist[d1.seq].events[d2.seq].foley_indcat_dt)) != ''
	or trim(substring(1, 100, pat->plist[d1.seq].events[d2.seq].foley_action)) != ''
	or trim(substring(1, 30, pat->plist[d1.seq].events[d2.seq].foley_beg_dt)) != ''
	or trim(substring(1, 30, pat->plist[d1.seq].events[d2.seq].foley_end_dt)) != ''
	or trim(substring(1, 100, pat->plist[d1.seq].events[d2.seq].foley_typ)) != ''
	or trim(substring(1, 30, pat->plist[d1.seq].events[d2.seq].chg_complete_dt)) != ''
	or trim(substring(1, 100, pat->plist[d1.seq].events[d2.seq].chg_not_done_doc)) != ''
	or trim(substring(1, 30, pat->plist[d1.seq].events[d2.seq].chg_not_done_doc_dt)) != ''
	or trim(substring(1, 30, pat->plist[d1.seq].events[d2.seq].1st_shift_tsk_dt)) != ''
	or trim(substring(1, 30, pat->plist[d1.seq].events[d2.seq].1st_shift_tsk_status)) != ''
	or trim(substring(1, 30, pat->plist[d1.seq].events[d2.seq].2nd_shift_tsk_dt)) != ''
	or trim(substring(1, 30, pat->plist[d1.seq].events[d2.seq].2nd_shift_tsk_status)) != ''
	or trim(substring(1, 100, pat->plist[d1.seq].events[d2.seq].tsk_not_done_doc)) != ''
	or trim(substring(1, 30, pat->plist[d1.seq].events[d2.seq].tsk_not_done_doc_dt)) != ''
	)
 
order by start_date, facility, fin
 
with nocounter, separator=" ", format
 
endif
 
ENDIF ;rec_cnt
 
 
#exitscript
 
/*****************************************************************************
	;Subroutins
/*****************************************************************************/
 
%i cust_script:cov_CommonLibrary.inc
 
 
end
go
 

