/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Mar'2019
	Solution:			Quality/Lab
	Source file name:	      cov_phq_critical_result_note.prg
	Object name:		cov_phq_critical_result_note
	Request#:			1070
	Program purpose:	      Critical results notification report
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_gstest go
create program cov_gstest
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Facility " = 0
	, "Select Begin Date/time" = "SYSDATE"
	, "Select End Date/Time" = "SYSDATE"
 
with OUTDEV, Facility, begdate, enddate
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare numcrit    = f8 with noconstant(uar_get_code_by('MEANING',1902, 'CRITICAL')), protect
declare alpcrit    = f8 with noconstant(uar_get_code_by('MEANING',1902, 'ALP_CRITICAL')), protect
declare critflag   = f8 with constant(UAR_GET_CODE_BY('DISPLAYKEY',52, 'CRIT')), protect
declare authvercd  = f8 with constant(UAR_GET_CODE_BY('DISPLAYKEY',8,'AUTHVERIFIED')), protect
declare modifiedcd = f8 with constant(UAR_GET_CODE_BY('MEANING',8,'MODIFIED')), protect
declare alteredcd  = f8 with constant(UAR_GET_CODE_BY('MEANING', 8, 'ALTERED')), protect
declare mrn		 = f8 with constant(UAR_GET_CODE_BY('DISPLAYKEY',4,'MRN')), protect
declare fin		 = f8 with constant(UAR_GET_CODE_BY('DISPLAYKEY',319,'FINNBR')), protect
declare faccd	 = f8 with noconstant(0.0), protect
declare aliascd	 = f8 with noconstant(0.0), protect
declare iOpsInd    = i2 with noconstant(0), protect
declare bdate	 = f8 with noconstant(0.0), protect
declare edate	 = f8 with noconstant(0.0), protect
declare chbdate	 = vc with noconstant(FILLSTRING(20,' ')), protect
declare chedate    = vc with noconstant(FILLSTRING(20,' ')), protect
declare provnote   = f8 with constant(UAR_GET_CODE_BY('DISPLAYKEY', 72,'PROVIDERNOTIFICATION')), protect
 
;Notification DTA's
;Some of the DTA have spelling mistake so using code value
declare prsnl_notify_var      = f8 with constant(2929619891.00) ;Crit Value Provider Notified
declare call_reason_var       = f8 with constant(2929638751.00) ;Crit Value No Call Reason
declare prsnl_name_var        = f8 with constant(2929643525.00) ;Crit Value Name of Provider Notified
declare prsnl_notify_dt_var   = f8 with constant(2929645665.00) ;Crit Value D/T Provider Notified
declare prsnl_response_dt_var = f8 with constant(2929647031.00) ;Crit Value D/T Provider Reposnse
declare test_value_notify_var = f8 with constant(2929648609.00) ;Crit Value Test Notified
declare prsnl_req_invent_var  = f8 with constant(2929654243.00) ;Crit Value Provider Req Intervention
declare prsnl_no_response_var = f8 with constant(2929657431.00) ;Crit Value No Provider Response
 
/**************************************************************
; RECORD STRUCTURE
**************************************************************/
 
RECORD a(
1	rec_cnt  = i4
1	facility = vc
1	qual[*]
	2	personid = f8
	2	encntrid = f8
	2	name	   = vc
	2	mrn	   = vc
	2	fin	   = vc
	2	unit	   = vc
	2	room	   = vc
	2	bed	   = vc
	2	loc	   = vc
	2	resdttm  = f8
	2	labcnt   = i4
	2	labqual[*]
		3	eventid      = f8
		3	eventcd	 = f8
		3	orderid	 = f8
		3	eventname	 = vc
		3	result	 = vc
		3	units		 = vc
		3	flag		 = vc
		3     flag_cd      = f8
		3	accnbr	 = vc
		3	drawndttm	 = vc
		3	verdttm	 = vc
		3	verprsnlid	 = f8
		3	verdatetm	 = f8
		3	verprsnl	 = vc
		3	prevresult	 = vc
		3	prevresdttm	 = vc
		3	rescomm	 = vc
		3	rescommdt	 = f8
		3	rescommdttm	 = vc
		3	Instrument	 = vc
		3	resultid	 = f8
		3	nurscomm	 = vc
		3	nurscommdt	 = f8
		3	nurscommdttm = vc
		3	labtat	 = i4
		3	nursetat	 = i4
)
 
FREE RECORD output
RECORD output(
	1 rec_cnt = i4
	1 qual[*]
		2 Name 	   = vc
		2 personid     = f8
		2 encntrid     = f8
		2 mrn 	   = vc
		2 fin 	   = vc
		2 unit	   = vc
		2 room	   = vc
		2 bed 	   = vc
		2 location 	   = vc
		2 facility 	   = vc
		2 resultname   = vc
		2 result 	   = vc
		2 perfdttm 	   = vc
		2 commdttm 	   = vc
		2 commtime     = vc
		2 nurscommdttm = vc
		2 rescomm 	   = vc
		2 nurscomm 	   = vc
		2 labtat	   = i4
		2 nursetat 	   = i4
		2 totaltat 	   = i4
		2 accnbr	   = vc
	)
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
call echo(build('critflag :', critflag))
call echo(build('authvercd :', authvercd))
call echo(build('modifiedcd :', modifiedcd))
call echo(build('alteredcd :', alteredcd))
call echo(build('numcrit :', numcrit))
call echo(build('alpcrit :', alpcrit))
call echo(build('provnote :', provnote))
;GO TO exitscript
 
;------------------------------------------------------------------------------------------
 
SELECT into 'nl:'
 
FROM location l
WHERE l.organization_id = CNVTREAL($facility)
AND l.location_type_cd = 783.00
AND l.active_ind = 1
 
DETAIL
	faccd = l.location_cd
 	a->facility = UAR_GET_CODE_DISPLAY(l.location_cd)
WITH nocounter
 
;------------------------------------------------------------------------------------------
;Find critical results
 
select into 'nl:'
 
;e.encntr_id, o.order_id, r.result_id, r.event_id
 
from
	 result r,
	 perform_result pe,
	 orders o,
	 accession_order_r aor,
	 accession a,
	 container c,
	 encounter e,
	 person p
 
plan pe where pe.perform_dt_tm between cnvtdatetime($begdate) and cnvtdatetime($enddate)
	and pe.critical_cd in (numcrit,alpcrit)
 
join r where pe.result_id = r.result_id
 
join c where outerjoin(pe.container_id) = c.container_id
 
join o where r.order_id = o.order_id
 
join aor where o.order_id = aor.order_id
 
join a where aor.accession_id = a.accession_id
 
join e where o.encntr_id = e.encntr_id
	and e.loc_facility_cd = faccd
	and e.active_ind = 1
 
join p where e.person_id = p.person_id
	and p.active_ind = 1
 
order by e.encntr_id, r.result_id
 
;with nocounter, separator=" ", format
 
Head report
	cnt = 0
 
Head e.encntr_id
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
		stat = alterlist(a->qual, cnt + 9)
	endif
	a->qual[cnt].encntrid =	e.encntr_id
	a->qual[cnt].personid =	p.person_id
	a->qual[cnt].name	    =	trim(p.name_full_formatted)
	a->rec_cnt		    =	cnt
	rcnt = 0
 
Head r.result_id ;
	rcnt = rcnt + 1
	if (mod(rcnt,10) = 1 or rcnt = 1)
 		stat = alterlist(a->qual[cnt].labqual, rcnt + 9)
 	endif
	a->qual[cnt].labqual[rcnt].accnbr	 = cnvtacc(a.accession)
	a->qual[cnt].labqual[rcnt].orderid	 = o.order_id
	a->qual[cnt].labqual[rcnt].eventid	 = r.event_id
	a->qual[cnt].labqual[rcnt].eventname = uar_get_code_display(r.task_assay_cd)
	a->qual[cnt].labqual[rcnt].flag	 = uar_get_code_display(pe.critical_cd)
	a->qual[cnt].labqual[rcnt].flag_cd	 = pe.critical_cd
	a->qual[cnt].labqual[rcnt].result	 =
		if (pe.result_value_alpha > ' ')
			pe.result_value_alpha
		else
			cnvtstring(pe.result_value_numeric,11,2)
		endif
	a->qual[cnt].labqual[rcnt].units	  = uar_get_code_display(pe.units_cd)
	a->qual[cnt].labqual[rcnt].verdttm	  = format(pe.perform_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].labqual[rcnt].verdatetm  = pe.perform_dt_tm
	a->qual[cnt].labqual[rcnt].verprsnlid = pe.perform_personnel_id
	a->qual[cnt].labqual[rcnt].instrument = uar_get_code_display(pe.service_resource_cd)
	a->qual[cnt].labqual[rcnt].resultid	  = r.result_id
	a->qual[cnt].labqual[rcnt].drawndttm  = format(c.drawn_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].labcnt			  = rcnt
 
Foot e.encntr_id
	a->qual[cnt].resdttm = pe.perform_dt_tm
	stat = alterlist(a->qual[cnt].labqual, rcnt)
 
Foot report
	stat = alterlist(a->qual, cnt)
 
WITH nocounter
 
;-------------------------------------------------------------------------------------------------
;Get encntr info
 
select into 'nl:'
 
from (dummyt d with seq = a->rec_cnt),
	 encntr_loc_hist elh,
	 encntr_alias ea,
	 person_alias pa
 
plan d
 
join elh where a->qual[d.seq].encntrid = elh.encntr_id
	and cnvtdatetime(a->qual[d.seq].resdttm) >= elh.beg_effective_dt_tm
	and cnvtdatetime(a->qual[d.seq].resdttm) <= elh.end_effective_dt_tm
 
join ea where elh.encntr_id = ea.encntr_id
	and ea.encntr_alias_type_cd = fin
	and ea.active_ind = 1
	and ea.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 0")
 
join pa where a->qual[d.seq].personid = pa.person_id
	and pa.person_alias_type_cd = mrn
	and pa.active_ind = 1
	and pa.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 0")
 
Detail
	a->qual[d.seq].unit = uar_get_code_display(elh.loc_nurse_unit_cd)
	a->qual[d.seq].room = uar_get_code_display(elh.loc_room_cd)
	a->qual[d.seq].bed  = uar_get_code_display(elh.loc_bed_cd)
	a->qual[d.seq].loc  = build2(a->qual[d.seq].unit,' ', a->qual[d.seq].room,' / ',a->qual[d.seq].bed)
	a->qual[d.seq].mrn  = trim(pa.alias)
	a->qual[d.seq].fin  = trim(ea.alias)
 
With nocounter
 
;----------------------------------------------------------------------------------------
;get personnel info
 
select into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	(dummyt d2 with seq = 1),
	prsnl pr
 
plan d where maxrec(d2, a->qual[d.seq].labcnt)
 
join d2
 
join pr where a->qual[d.seq].labqual[d2.seq].verprsnlid = pr.person_id
 
Detail
	a->qual[d.seq].labqual[d2.seq].verprsnl = trim(pr.name_full_formatted)
 
with nocounter
 
;------------------------------------------------------------------------------------------------
 
;Get Result Comments
select into 'nl:'
 
from (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 result_comment rc,
	 long_text lt
 
plan d where maxrec(d2,a->qual[d.seq].labcnt)
 
join d2
 
join rc where a->qual[d.seq].labqual[d2.seq].resultid = rc.result_id
 
join lt where rc.long_text_id = lt.long_text_id
 
Detail
	a->qual[d.seq].labqual[d2.seq].rescomm = replace(trim(lt.long_text),concat(char(13),char(10)),' ')
 	a->qual[d.seq].labqual[d2.seq].rescommdt = rc.comment_dt_tm
 	a->qual[d.seq].labqual[d2.seq].rescommdttm = format(rc.comment_dt_tm, "mm/dd/yyyy hh:mm;;q")
 	a->qual[d.seq].labqual[d2.seq].labtat =
 	datetimediff(rc.comment_dt_tm, cnvtdatetime(a->qual[d.seq].labqual[d2.seq].verdatetm),4)
 
with nocounter
 
;------------------------------------------------------------------------------------------------
;Get Nurse Comments
 
select into 'nl:'
 
from (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 clinical_event ce
 
plan d where maxrec(d2,a->qual[d.seq].labcnt)
 
join d2
 
join ce where a->qual[d.seq].personid = ce.person_id
	and ce.event_cd = provnote
	and a->qual[d.seq].encntrid = ce.encntr_id
	and ce.performed_dt_tm between cnvtdatetime(a->qual[d.seq].labqual[d2.seq].verdatetm)
	and cnvtlookahead('2, h',cnvtdatetime(a->qual[d.seq].labqual[d2.seq].verdatetm))
	and ce.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 0")
 
Detail
	a->qual[d.seq].labqual[d2.seq].nurscomm = ce.result_val
 	a->qual[d.seq].labqual[d2.seq].rescommdt = ce.performed_dt_tm
 	a->qual[d.seq].labqual[d2.seq].rescommdttm = format(ce.performed_dt_tm, "mm/dd/yyyy hh:mm;;q")
 	a->qual[d.seq].labqual[d2.seq].nursetat =
 	datetimediff(ce.performed_dt_tm, cnvtdatetime(a->qual[d.seq].labqual[d2.seq].verdatetm),4)
 
with nocounter
;---------------------------------------------------------------------------------------------------
;build output rec
 
select into 'nl:'
 	encntrid = a->qual[d.seq].encntrid
 
from (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1)
 
plan d where maxrec(d2,a->qual[d.seq].labcnt)
 
join d2
 
Head report
	cnt = 0
 
Detail
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
		stat = alterlist(output->qual, cnt + 9)
	endif
	output->qual[cnt].Name 	      = a->qual[d.seq].name
	output->qual[cnt].personid	= a->qual[d.seq].personid
	output->qual[cnt].encntrid	= a->qual[d.seq].encntrid
	output->qual[cnt].mrn  		= a->qual[d.seq].mrn
	output->qual[cnt].fin 		= a->qual[d.seq].fin
	output->qual[cnt].unit		= a->qual[d.seq].unit
	output->qual[cnt].room		= a->qual[d.seq].room
	output->qual[cnt].bed		= a->qual[d.seq].bed
	output->qual[cnt].location	= a->qual[d.seq].loc
	output->qual[cnt].facility	= a->facility
	output->qual[cnt].resultname  = a->qual[d.seq].labqual[d2.seq].eventname
	output->qual[cnt].result	= a->qual[d.seq].labqual[d2.seq].result
	output->qual[cnt].perfdttm	= a->qual[d.seq].labqual[d2.seq].verdttm
	output->qual[cnt].commdttm	= a->qual[d.seq].labqual[d2.seq].rescommdttm
	output->qual[cnt].commtime	= format(cnvtdatetime(a->qual[d.seq].labqual[d2.seq].rescommdt),"HH:MM;;M")
	output->qual[cnt].rescomm	= replace(trim(a->qual[d.seq].labqual[d2.seq].rescomm),CHAR(10),'')
	output->qual[cnt].nurscomm	= a->qual[d.seq].labqual[d2.seq].nurscomm
	output->qual[cnt].labtat	= a->qual[d.seq].labqual[d2.seq].labtat
	output->qual[cnt].nursetat	= a->qual[d.seq].labqual[d2.seq].nursetat
	output->qual[cnt].accnbr      = a->qual[d.seq].labqual[d2.seq].accnbr
	output->rec_cnt			= cnt
 
	output->qual[cnt].nurscommdttm = a->qual[d.seq].labqual[d2.seq].nurscommdttm
	output->qual[cnt].totaltat	 =
		datetimediff(cnvtdatetime(a->qual[d.seq].labqual[d2.seq].nurscommdt),
		cnvtdatetime(a->qual[d.seq].labqual[d2.seq].rescommdt),4)
 
Foot report
	stat = alterlist(output->qual, cnt)
 
With nocounter
 
;call echorecord(output)
 
;-------------------------------------------------------------------------------------------------------------------------------------------
	;Critical value Notification - ;New CR#1070
	;Combining with critical value report(above) to get critical lab value charting.
;-------------------------------------------------------------------------------------------------------------------------------------------
 
Record chart(
	1 chart_cnt = i4
	1 plist[*]
		2 fin = vc
		2 encntrid = f8
		2 personid = f8
		2 pat_name = vc
		2 result[*]
			3 result_id = f8
			3 lab_result_name = vc
			3 lab_result_val = vc
			3 lab_crit_value_flag = vc
			3 lab_perform_dt = vc
			3 lab_result_cmnt = vc
			3 lab_result_cmnt_dt = vc
			3 prsnl_notify = vc
			3 no_call_reason = vc
			3 prsnl_name = vc
			3 prsnl_notify_dt = vc
			3 prsnl_response_dt = vc
			3 test_value_notify = vc
			3 prsnl_req_invent = vc
			3 prsnl_no_response = vc
)
 
;-------------------------------------------------------------------------
 
;Load all critical values into the Chart record structure for this CR
select into 'nl:'
 
fin_nbr = trim(substring(1,10, a->qual[d.seq].fin))
, result_id = a->qual[d.seq].labqual[d2.seq].resultid
 
from (dummyt d with seq = a->rec_cnt)
	,(dummyt d2 with seq = 1)
 
plan d where maxrec(d2,a->qual[d.seq].labcnt)
 
join d2
 
order by fin_nbr, result_id
 
Head report
	cnt = 0
	call alterlist(chart->plist, 10)
Head fin_nbr
	cnt = cnt + 1
 	chart->chart_cnt = cnt
	call alterlist(chart->plist, cnt)
	chart->plist[cnt].fin = trim(substring(1,10, a->qual[d.seq].fin))
	chart->plist[cnt].encntrid = a->qual[d.seq].encntrid
	chart->plist[cnt].personid = a->qual[d.seq].personid
	chart->plist[cnt].pat_name =  trim(substring(1,50, a->qual[d.seq].name))
	rcnt = 0
 
Head result_id
	rcnt = rcnt + 1
	call alterlist(chart->plist[cnt].result, rcnt)
	chart->plist[cnt].result[rcnt].result_id = a->qual[d.seq].labqual[d2.seq].resultid
	chart->plist[cnt].result[rcnt].lab_result_name = trim(substring(1,100,a->qual[d.seq].labqual[d2.seq].eventname))
	chart->plist[cnt].result[rcnt].lab_result_val = trim(substring(1,50,a->qual[d.seq].labqual[d2.seq].result))
	chart->plist[cnt].result[rcnt].lab_crit_value_flag = uar_get_code_description(a->qual[d.seq].labqual[d2.seq].flag_cd)
	chart->plist[cnt].result[rcnt].lab_perform_dt = trim(substring(1,25, a->qual[d.seq].labqual[d2.seq].verdttm))
	chart->plist[cnt].result[rcnt].lab_result_cmnt = trim(substring(1,200, replace(trim(a->qual[d.seq].labqual[d2.seq].rescomm),CHAR(10),'')))
	chart->plist[cnt].result[rcnt].lab_result_cmnt_dt =  trim(substring(1,25, a->qual[d.seq].labqual[d2.seq].rescommdttm))
 
with nocounter
 
;call echorecord(chart)
 
;----------------------------------------------------------------------------------------------------------------------------
;Get matching charted clinical events
select into 'nl:'
 
 fin_nbr = trim(substring(1,10, chart->plist[d1.seq].fin))
, result_id = chart->plist[d1.seq].result[d2.seq].result_id
 
/*, patient_name = trim(substring(1,50, a->qual[d.seq].name))
, critical_value_dta = trim(uar_get_code_display(i.event_cd)),i.event_cd, i.event_id
, critical_value_charted = trim(i.result_val)
, critical_value_chart_dt = format(i.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;d')
, lab_result_name = trim(substring(1,200,a->qual[d.seq].labqual[d2.seq].eventname))
, lab_result = trim(substring(1,200,a->qual[d.seq].labqual[d2.seq].result))
, lab_crit_val_flag = uar_get_code_description(a->qual[d.seq].labqual[d2.seq].flag_cd)
, lab_perm_dt = trim(substring(1,25, a->qual[d.seq].labqual[d2.seq].verdttm))
, lab_result_comment = trim(substring(1,200, replace(trim(a->qual[d.seq].labqual[d2.seq].rescomm),CHAR(10),'')))
, lab_result_comment_dt = trim(substring(1,25, a->qual[d.seq].labqual[d2.seq].rescommdttm))
*/
 
from (dummyt d1 with seq = size(chart->plist, 5))
	,(dummyt d2 with seq = 1)
	, clinical_event ce
	, ce_date_result cdr
 
plan d1 where maxrec(d2, size(chart->plist[d1.seq].result, 5))
join d2
 
join ce where ce.encntr_id = chart->plist[d1.seq].encntrid
	and ce.person_id = chart->plist[d1.seq].personid
	and ce.event_end_dt_tm between cnvtdatetime($begdate) and cnvtlookahead('1, h',cnvtdatetime($enddate))
	and ce.event_cd in(prsnl_notify_var, call_reason_var, prsnl_name_var, prsnl_notify_dt_var, prsnl_response_dt_var
			, test_value_notify_var, prsnl_req_invent_var, prsnl_no_response_var)
	;and ce.event_cd in(2929619891.00, 2929638751.00, 2929643525.00, 2929645665.00, 2929647031.00,2929648609.00, 2929654243.00, 2929657431.00)
	and ce.result_status_cd in(25,34,35)
	and ce.view_level = 1
	and ce.publish_flag = 1 ;active
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
 
join cdr where cdr.event_id = outerjoin(ce.event_id)
 
;order by fin_nbr, result_id, ce.event_cd
 
Detail
  	case (ce.event_cd)
 		of prsnl_notify_var:
			chart->plist[d1.seq].result[d2.seq].prsnl_notify = trim(ce.result_val)
		Of call_reason_var:
			chart->plist[d1.seq].result[d2.seq].no_call_reason = trim(ce.result_val)
		Of prsnl_name_var:
			chart->plist[d1.seq].result[d2.seq].prsnl_name = trim(ce.result_val)
		Of prsnl_notify_dt_var:
			chart->plist[d1.seq].result[d2.seq].prsnl_notify_dt = format(cdr.result_dt_tm, 'mm/dd/yyyy hh:mm;;d')
		Of prsnl_response_dt_var:
			chart->plist[d1.seq].result[d2.seq].prsnl_response_dt = format(cdr.result_dt_tm, 'mm/dd/yyyy hh:mm;;d')
		Of test_value_notify_var:
			chart->plist[d1.seq].result[d2.seq].test_value_notify = trim(ce.result_val)
		Of prsnl_req_invent_var:
			chart->plist[d1.seq].result[d2.seq].prsnl_req_invent = trim(ce.result_val)
		Of prsnl_no_response_var:
			chart->plist[d1.seq].result[d2.seq].prsnl_no_response = trim(ce.result_val)
	endcase
 
with nocounter
 
call echorecord(chart)
 
 
/*
;******** Old with inline table ***********
 
select into 'nl:'
 
 fin_nbr = trim(substring(1,10, a->qual[d.seq].fin))
, result_id = a->qual[d.seq].labqual[d2.seq].resultid
, patient_name = trim(substring(1,50, a->qual[d.seq].name))
, critical_value_dta = trim(uar_get_code_display(i.event_cd)),i.event_cd, i.event_id
, critical_value_charted = trim(i.result_val)
, critical_value_chart_dt = format(i.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;d')
, lab_result_name = trim(substring(1,200,a->qual[d.seq].labqual[d2.seq].eventname))
, lab_result = trim(substring(1,200,a->qual[d.seq].labqual[d2.seq].result))
, lab_crit_val_flag = uar_get_code_description(a->qual[d.seq].labqual[d2.seq].flag_cd)
, lab_perm_dt = trim(substring(1,25, a->qual[d.seq].labqual[d2.seq].verdttm))
, lab_result_comment = trim(substring(1,200, replace(trim(a->qual[d.seq].labqual[d2.seq].rescomm),CHAR(10),'')))
, lab_result_comment_dt = trim(substring(1,25, a->qual[d.seq].labqual[d2.seq].rescommdttm))
 
from (dummyt d with seq = a->rec_cnt)
,(dummyt d2 with seq = 1)
 
,((select ce.person_id, ce.encntr_id, ce.event_cd, ce.event_id, ce.performed_dt_tm, ce.event_end_dt_tm, ce.result_val
		from clinical_event ce, encounter e
		where ce.event_end_dt_tm between cnvtdatetime($begdate) and cnvtlookahead('2, h',cnvtdatetime($enddate))
		and ce.event_cd in(prsnl_notify_var, call_reason_var, prsnl_name_var, prsnl_notify_dt_var, prsnl_response_dt_var
			, test_value_notify_var, prsnl_req_invent_var, prsnl_no_response_var)
		;and ce.event_cd in(2929619891.00, 2929638751.00, 2929643525.00, 2929645665.00, 2929647031.00,2929648609.00, 2929654243.00, 2929657431.00)
		and ce.result_status_cd in(25,34,35)
		and ce.view_level = 1
		and ce.publish_flag = 1 ;active
		and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
		and e.encntr_id = ce.encntr_id
		and e.person_id = ce.person_id
		and e.loc_facility_cd = faccd
		with sqltype('f8','f8','f8','f8','dq8','dq8','vc')
	)i
)
, ce_date_result cdr
 
plan d where maxrec(d2,a->qual[d.seq].labcnt)
 
join d2
 
join i where a->qual[d.seq].personid = outerjoin(i.person_id)
	and a->qual[d.seq].encntrid = outerjoin(i.encntr_id)
	and cnvtdatetime(a->qual[d.seq].labqual[d2.seq].verdatetm) <= outerjoin(i.event_end_dt_tm)
	and cnvtlookahead('1, h',cnvtdatetime(a->qual[d.seq].labqual[d2.seq].verdatetm)) >= outerjoin(i.event_end_dt_tm)
 
join cdr where cdr.event_id = outerjoin(i.event_id)
 
order by fin_nbr, result_id, i.event_cd
 
;with nocounter, separator=" ", format, time = 180
 
Head report
	cnt = 0
	call alterlist(chart->plist, 10)
Head fin_nbr
	cnt = cnt + 1
 	chart->chart_cnt = cnt
	call alterlist(chart->plist, cnt)
	chart->plist[cnt].fin = fin_nbr
	chart->plist[cnt].pat_name = patient_name
	rcnt = 0
 
Head result_id
	rcnt = rcnt + 1
	call alterlist(chart->plist[cnt].result, rcnt)
	chart->plist[cnt].result[rcnt].result_id = result_id
	chart->plist[cnt].result[rcnt].lab_result_name = lab_result_name
	chart->plist[cnt].result[rcnt].lab_result_val = lab_result
	chart->plist[cnt].result[rcnt].lab_crit_value_flag = lab_crit_val_flag
	chart->plist[cnt].result[rcnt].lab_perform_dt = lab_perm_dt
	chart->plist[cnt].result[rcnt].lab_result_cmnt = lab_result_comment
	chart->plist[cnt].result[rcnt].lab_result_cmnt_dt = lab_result_comment_dt
 
Detail
 	case (i.event_cd)
 		of prsnl_notify_var:
			chart->plist[cnt].result[rcnt].prsnl_notify = trim(i.result_val)
		Of call_reason_var:
			chart->plist[cnt].result[rcnt].no_call_reason = trim(i.result_val)
		Of prsnl_name_var:
			chart->plist[cnt].result[rcnt].prsnl_name = trim(i.result_val)
		Of prsnl_notify_dt_var:
			chart->plist[cnt].result[rcnt].prsnl_notify_dt = format(cdr.result_dt_tm, 'mm/dd/yyyy hh:mm;;d')
		Of prsnl_response_dt_var:
			chart->plist[cnt].result[rcnt].prsnl_response_dt = format(cdr.result_dt_tm, 'mm/dd/yyyy hh:mm;;d')
		Of test_value_notify_var:
			chart->plist[cnt].result[rcnt].test_value_notify = trim(i.result_val)
		Of prsnl_req_invent_var:
			chart->plist[cnt].result[rcnt].prsnl_req_invent = trim(i.result_val)
		Of prsnl_no_response_var:
			chart->plist[cnt].result[rcnt].prsnl_no_response = trim(i.result_val)
	endcase
 
with nocounter
 
call echorecord(chart)
*/
 
;---------------------------------------------------------------------
 
SELECT INTO $OUTDEV
 
	FIN = SUBSTRING(1, 30, CHART->plist[D1.SEQ].fin)
	, PATIENT_NAME = SUBSTRING(1, 30, CHART->plist[D1.SEQ].pat_name)
	, LAB_RESULT_NAME = SUBSTRING(1, 200, CHART->plist[D1.SEQ].result[D2.SEQ].lab_result_name)
	, LAB_RESULT_VALUE = SUBSTRING(1, 100, CHART->plist[D1.SEQ].result[D2.SEQ].lab_result_val)
	, LAB_CRIT_VALUE_FLAG = SUBSTRING(1, 50, CHART->plist[D1.SEQ].result[D2.SEQ].lab_crit_value_flag)
	, LAB_PERFORM_DT = SUBSTRING(1, 30, CHART->plist[D1.SEQ].result[D2.SEQ].lab_perform_dt)
	, PROVIDER_NOTIFY = SUBSTRING(1, 100, CHART->plist[D1.SEQ].result[D2.SEQ].prsnl_notify)
	, PROVIDER_NOTIFY_DT = SUBSTRING(1, 30, CHART->plist[D1.SEQ].result[D2.SEQ].prsnl_notify_dt)
	, PROVIDER_NAME = SUBSTRING(1, 100, CHART->plist[D1.SEQ].result[D2.SEQ].prsnl_name)
	, PROVIDER_RESPONSE_DT = SUBSTRING(1, 30, CHART->plist[D1.SEQ].result[D2.SEQ].prsnl_response_dt)
	, TEST_VALUE_NOTIFY = SUBSTRING(1, 300, CHART->plist[D1.SEQ].result[D2.SEQ].test_value_notify)
	, PROVIDER_REQ_INVENT = SUBSTRING(1, 300, CHART->plist[D1.SEQ].result[D2.SEQ].prsnl_req_invent)
	, PROVIDER_NO_RESPONSE = SUBSTRING(1, 300, CHART->plist[D1.SEQ].result[D2.SEQ].prsnl_no_response)
	, NO_CALL_REASON = SUBSTRING(1, 300, CHART->plist[D1.SEQ].result[D2.SEQ].no_call_reason)
	, LAB_RESULT_COMMENT = SUBSTRING(1, 300, CHART->plist[D1.SEQ].result[D2.SEQ].lab_result_cmnt)
	, LAB_RESULT_CMNT_DT = SUBSTRING(1, 30, CHART->plist[D1.SEQ].result[D2.SEQ].lab_result_cmnt_dt)
	, RESULT_ID = CHART->plist[D1.SEQ].result[D2.SEQ].result_id
 
FROM
	(DUMMYT   D1  WITH SEQ = SIZE(CHART->plist, 5))
	, (DUMMYT   D2  WITH SEQ = 1)
 
PLAN D1 WHERE MAXREC(D2, SIZE(CHART->plist[D1.SEQ].result, 5))
JOIN D2
 
ORDER BY FIN, LAB_RESULT_NAME, LAB_RESULT_VALUE, PROVIDER_NOTIFY, PROVIDER_NOTIFY_DT, PROVIDER_NAME, PROVIDER_RESPONSE_DT
	, TEST_VALUE_NOTIFY, PROVIDER_REQ_INVENT
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
;Notification DTA's used
;------------------------------------------------------------------
 
/* 2929619891.00	Crit Value Provider Notified
 2929638751.00	Crit Value No Call Reason
 2929643525.00	Crit Value Name of Provider Notified
 2929645665.00	Crit Value D/T Provider Notified
 2929647031.00	Crit Value D/T Provider Reposnse
 2929648609.00	Crit Value Test Notified
 2929654243.00	Crit Value Provider Req Intervention
 2929657431.00	Crit Value No Provider Response
*/
 
;-------------------------------------------------------------------------------------
 
/**
#DA2Section
 
select into value($outdev)
	Name = CONCAT(output->qual[d.seq].Name,'                             '),
	mrn = output->qual[d.seq].mrn,
	fin = CONCAT(output->qual[d.seq].fin,'                   '),
	unit = CONCAT(output->qual[d.seq].unit,'                   '),
	room = output->qual[d.seq].room,
	bed = output->qual[d.seq].bed,
	location = CONCAT(output->qual[d.seq].location,'                                '),
	facility = output->qual[d.seq].facility,
	accnbr = output->qual[d.seq].accnbr,
	resultname = CONCAT(output->qual[d.seq].resultname,'                        '),
	result = CONCAT(output->qual[d.seq].result,'                     '),
	perfdttm = output->qual[d.seq].perfdttm,
	commdttm = output->qual[d.seq].commdttm,
	rescomm = CONCAT(output->qual[d.seq].rescomm,fillstring(500,' ')),
	labtat = output->qual[d.seq].labtat,
	nursecomm = output->qual[d.seq].nurscomm,
	nursecomdt = utput->qual[d.seq].nurscommdttm
 
 
from (dummyt d with seq = output->rec_cnt)
 
order by unit
 
with nocounter, format, separator = ' '
 
***/
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript
 
end
go
 
