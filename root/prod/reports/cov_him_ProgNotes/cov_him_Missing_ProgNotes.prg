/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		09/29/2020
	Solution:			Revenue Cycle - HIM
	Source file name:	cov_him_Missing_ProgNotes.prg
	Object name:		cov_him_Missing_ProgNotes
	Request #:			8330
 
	Program purpose:	Lists data for TJC requirements to determine
						completion of progress notes.
 
	Executing from:		CCL
 
 	Special Notes:		Calls cov_him_PresentTimely_HP to get H&P data.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program cov_him_Missing_ProgNotes:dba go
create program cov_him_Missing_ProgNotes:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility" = VALUE(0.0            )
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE" 

with OUTDEV, facility, start_datetime, end_datetime

 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare inerror_var					= f8 with constant(uar_get_code_by("MEANING", 8, "INERROR")), protect
declare sign_action_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 21, "SIGN")), protect
declare perform_action_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 21, "PERFORM")), protect
declare root_var					= f8 with constant(uar_get_code_by("MEANING", 24, "ROOT")), protect
declare child_var					= f8 with constant(uar_get_code_by("MEANING", 24, "CHILD")), protect
declare otg_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 25, "OTG")), protect
declare mdoc_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 53, "MDOC")), protect
declare doc_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 53, "DOC")), protect
declare inpatient_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "INPATIENT")), protect
declare observation_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "OBSERVATION")), protect
declare dischargesummary_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "DISCHARGESUMMARY")), protect

declare progressnotes_var		= f8 with constant(uar_get_code_by("DISPLAY_KEY", 93, "PROGRESSNOTES")), protect
declare orgdoc_var				= f8 with constant(uar_get_code_by("DISPLAY_KEY", 320, "ORGANIZATIONDOCTOR")), protect

;declare admitphysician_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 333, "ADMITTINGPHYSICIAN")), protect
declare provider_var				= f8 with constant(uar_get_code_by("DISPLAY_KEY", 254571, "PROVIDER")), protect
;
declare op_facility_var				= vc with noconstant(fillstring(100, " ")), protect
declare num							= i4 with noconstant(0), protect
 
; define operator for $facility
if (substring(1, 1, reflect(parameter(parameter2($facility), 0))) = "L") ; multiple values selected
    set op_facility_var = "IN"
elseif (parameter(parameter2($facility), 1) = 0.0) ; any selected
    set op_facility_var = "!="
else ; single value selected
    set op_facility_var = "="
endif


/**************************************************************
; DVDev Start Coding
**************************************************************/

free record prognoteeventdata
record prognoteeventdata (
	1 cnt							= i4
	1 qual [*]
		2 event_cd					= f8
)

free record prognotedata
record prognotedata (
	1 cnt							= i4
	1 qual [*]
		2 encntr_id					= f8
		2 encntr_type_cd			= f8
		2 person_id					= f8
		2 reg_dt_tm					= dq8
		2 disch_dt_tm				= dq8
		2 los_days					= f8
		2 los_hours					= f8
		
		; progress note
		2 prognote_cnt				= i4
		2 prognote [*]
			3 event_id				= f8
			3 event_cd				= f8
			3 event_class_cd		= f8
			3 performed_dt_tm		= dq8
			3 performed_prsnl_id	= f8
			3 performed_by			= c100
			3 result_dt_tm			= dq8
					
			3 is_missing			= i2
			3 is_late				= i2
			3 is_compliant			= i2
			
		; discharge summary
		2 dchgsum_cnt				= i4
		2 dchgsum [*]
			3 event_id				= f8
			3 event_cd				= f8
			3 event_class_cd		= f8
			3 performed_dt_tm		= dq8
			3 performed_prsnl_id	= f8
			3 performed_by			= c100
			3 result_dt_tm			= dq8
		
		; indicators for compliance logic
		2 has_prognote				= i2
		2 has_prognote_lastday		= i2
		2 has_dchgsum				= i2
		
		2 is_compliant				= i2
)


/**************************************************************/ 
; select progress note event set data
select into "nl:"	
from 
	V500_EVENT_SET_EXPLODE vese
	
where 
	vese.event_set_cd = progressnotes_var 
	 
; populate record structure
head report
	cnt = 0
 
detail
	cnt += 1
	
	call alterlist(prognoteeventdata->qual, cnt)
 
	prognoteeventdata->cnt						= cnt
	prognoteeventdata->qual[cnt].event_cd		= vese.event_cd

with nocounter, time = 60

;call echorecord(prognoteeventdata)

;go to exitscript
 
 
/**************************************************************/ 
; select history and physical data for IP/OB
execute cov_him_PresentTimely_HP $OUTDEV, $facility, $start_datetime, $end_datetime, 1

;TODO: For use when new H&P goes live.
;execute cov_him_PresentTimely_HP $OUTDEV, 0.0, $start_datetime, $end_datetime, 1

;go to exitscript

 
/**************************************************************/ 
; select progress note data
select into "nl:"	
from
	CLINICAL_EVENT ce
 
	, (inner join CE_EVENT_PRSNL cep on cep.event_id = ce.event_id
		and cep.action_type_cd = perform_action_var
		and cep.valid_until_dt_tm >= sysdate)
		
	, (inner join CLINICAL_EVENT ce2 on ce2.encntr_id = ce.encntr_id
		and ce2.parent_event_id = ce.parent_event_id
		and expand(num, 1, prognoteeventdata->cnt, ce2.event_cd, prognoteeventdata->qual[num].event_cd)
		and ce2.event_class_cd = doc_var
		and ce2.event_reltn_cd = child_var
		;and ce2.performed_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
		and ce2.result_status_cd != inerror_var
		and ce2.valid_until_dt_tm > sysdate)
	
	, (left join CE_BLOB_RESULT cbr on cbr.event_id = ce2.event_id
		and cbr.storage_cd = otg_var
		and cbr.valid_until_dt_tm > sysdate)
		
	, (inner join PRSNL per on per.person_id = ce.performed_prsnl_id
		and per.active_ind = 1)
	
	; limit progress notes to providers
	, (inner join PRSNL_ALIAS pera on pera.person_id = per.person_id
		and pera.prsnl_alias_type_cd = orgdoc_var
		and pera.end_effective_dt_tm > sysdate
		and pera.active_ind = 1)
	
	, (inner join ENCOUNTER e on e.encntr_id = ce.encntr_id)
		
	, (dummyt d1 with seq = value(hpdata->cnt))
	
plan d1

join ce
join cep
join ce2
join cbr
join per
join pera
join e

where
	ce.encntr_id = hpdata->qual[d1.seq].encntr_id
	and expand(num, 1, prognoteeventdata->cnt, ce.event_cd, prognoteeventdata->qual[num].event_cd)
	and ce.event_class_cd = mdoc_var
	and ce.event_reltn_cd = root_var
	;and ce.performed_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and ce.result_status_cd != inerror_var
	and ce.valid_until_dt_tm > sysdate
	
	; TODO: TESTING
;	and ce.encntr_id = (
;		select ea.encntr_id;, ea.beg_effective_dt_tm
;		from ENCNTR_ALIAS ea
;		where ea.alias in ("2107501796", "2107602761", "2110801365")
;	)
	
order by
	ce.encntr_id
	, ce.performed_dt_tm
	, ce.event_end_dt_tm
	 	 
; populate record structure	
head report
	cnt = 0
	
head ce.encntr_id
	pcnt = 0
	
	cnt += 1
	
	call alterlist(prognotedata->qual, cnt)	
	
	prognotedata->cnt							= cnt
	prognotedata->qual[cnt].encntr_id			= ce.encntr_id
	prognotedata->qual[cnt].encntr_type_cd		= hpdata->qual[d1.seq].encntr_type_cd
	prognotedata->qual[cnt].person_id			= ce.person_id
	prognotedata->qual[cnt].reg_dt_tm			= e.reg_dt_tm
	prognotedata->qual[cnt].disch_dt_tm			= e.disch_dt_tm

	if ((e.disch_dt_tm > sysdate) or (e.disch_dt_tm is null))
		prognotedata->qual[cnt].los_days		= datetimediff(sysdate, e.reg_dt_tm)
		prognotedata->qual[cnt].los_hours		= datetimediff(sysdate, e.reg_dt_tm, 3)
	else
		prognotedata->qual[cnt].los_days		= datetimediff(e.disch_dt_tm, e.reg_dt_tm)
		prognotedata->qual[cnt].los_hours		= datetimediff(e.disch_dt_tm, e.reg_dt_tm, 3)
	endif

	prognotedata->qual[cnt].is_compliant = 1
	
detail
	pcnt += 1
	
	call alterlist(prognotedata->qual[cnt].prognote, pcnt)
	
	prognotedata->qual[cnt].prognote_cnt						= pcnt
	prognotedata->qual[cnt].prognote[pcnt].event_id				= ce.event_id
	prognotedata->qual[cnt].prognote[pcnt].event_cd				= ce.event_cd
	prognotedata->qual[cnt].prognote[pcnt].event_class_cd		= ce.event_class_cd
	prognotedata->qual[cnt].prognote[pcnt].performed_dt_tm		= ce.performed_dt_tm
	prognotedata->qual[cnt].prognote[pcnt].performed_prsnl_id	= ce.performed_prsnl_id
	prognotedata->qual[cnt].prognote[pcnt].performed_by			= per.name_full_formatted
	prognotedata->qual[cnt].prognote[pcnt].result_dt_tm			= ce.event_end_dt_tm
	
	prognotedata->qual[cnt].prognote[pcnt].is_compliant = 1
		
	; indicators
	if (datetimediff(ce.performed_dt_tm, ce.event_end_dt_tm, 3) >= 24)
		prognotedata->qual[cnt].prognote[pcnt].is_late = 1
		prognotedata->qual[cnt].prognote[pcnt].is_compliant = 0
		prognotedata->qual[cnt].is_compliant = 0
	endif
	
	; check for missing documents
	diff_prev = 0
	
	if (pcnt = 1)
		diff_prev = datetimediff(datetimetrunc(ce.performed_dt_tm, "dd"), 
			datetimetrunc(hpdata->qual[d1.seq].hp_dt_tm, "dd"))
	else
		diff_prev = datetimediff(datetimetrunc(ce.performed_dt_tm, "dd"), 
			datetimetrunc(prognotedata->qual[cnt].prognote[pcnt - 1].performed_dt_tm, "dd"))
	endif
	
	if (diff_prev > 1)
		for (i = 1 to diff_prev - 1)
			pcnt += 1
			
			call alterlist(prognotedata->qual[cnt].prognote, pcnt)
			
			prognotedata->qual[cnt].prognote_cnt						= pcnt
			prognotedata->qual[cnt].prognote[pcnt].event_id				= ce.event_id
			prognotedata->qual[cnt].prognote[pcnt].performed_dt_tm		= datetimeadd(datetimetrunc(ce.performed_dt_tm, "dd"), -i)
						
			prognotedata->qual[cnt].prognote[pcnt].is_missing = 1
			prognotedata->qual[cnt].prognote[pcnt].is_late = 1
			prognotedata->qual[cnt].prognote[pcnt].is_compliant = 0
			prognotedata->qual[cnt].is_compliant = 0
		endfor
	endif
	
	if (datetimediff(datetimetrunc(e.disch_dt_tm, "dd"), datetimetrunc(ce.performed_dt_tm, "dd"), 3) = 0)
		prognotedata->qual[cnt].has_prognote_lastday = 1
	endif

foot ce.encntr_id
	prognotedata->qual[cnt].has_prognote = evaluate(pcnt, 0, 0, 1)
	
	if (prognotedata->qual[cnt].has_prognote)
		if (prognotedata->qual[cnt].los_hours < 48)
			if (not prognotedata->qual[cnt].has_prognote_lastday)
				prognotedata->qual[cnt].is_compliant = 0
			endif
		endif
	endif
	
with nocounter, expand = 1, time = 60
	

;call echorecord(prognotedata)

;go to exitscript

 
/**************************************************************/ 
; select discharge summary data
select into "nl:"	
from
	CLINICAL_EVENT ce
 
	, (inner join CE_EVENT_PRSNL cep on cep.event_id = ce.event_id
		and cep.action_type_cd = perform_action_var
		and cep.valid_until_dt_tm >= sysdate)
		
	, (inner join PRSNL per on per.person_id = ce.performed_prsnl_id
		and per.active_ind = 1)
	
	, (inner join ENCOUNTER e on e.encntr_id = ce.encntr_id)
		
	, (dummyt d1 with seq = value(hpdata->cnt))
	
plan d1

join ce
join cep
join per
join e

where
	ce.encntr_id = hpdata->qual[d1.seq].encntr_id
	and ce.event_cd = dischargesummary_var		
	and ce.event_class_cd = mdoc_var
	and ce.event_reltn_cd = root_var
	;and ce.performed_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and ce.result_status_cd != inerror_var
	and ce.valid_until_dt_tm > sysdate
	
	; TODO: TESTING
;	and ce.encntr_id = (
;		select ea.encntr_id;, ea.beg_effective_dt_tm
;		from ENCNTR_ALIAS ea
;		where ea.alias in ("2107501796", "2107602761", "2110801365")
;	)
	
order by
	ce.encntr_id
	, ce.performed_dt_tm
	, ce.event_end_dt_tm
	 	 
; populate record structure	
head ce.encntr_id
	numx = 0
	idx = 0
	dcnt = 0
		
	idx = locateval(numx, 1, prognotedata->cnt, ce.encntr_id, prognotedata->qual[numx].encntr_id)
	
detail
	if (idx > 0)
		dcnt += 1
		
		call alterlist(prognotedata->qual[idx].dchgsum, dcnt)
	
		prognotedata->qual[idx].dchgsum_cnt							= dcnt
		prognotedata->qual[idx].dchgsum[dcnt].event_id				= ce.event_id
		prognotedata->qual[idx].dchgsum[dcnt].event_cd				= ce.event_cd
		prognotedata->qual[idx].dchgsum[dcnt].event_class_cd		= ce.event_class_cd
		prognotedata->qual[idx].dchgsum[dcnt].performed_dt_tm		= ce.performed_dt_tm
		prognotedata->qual[idx].dchgsum[dcnt].performed_prsnl_id	= ce.performed_prsnl_id
		prognotedata->qual[idx].dchgsum[dcnt].performed_by			= per.name_full_formatted
		prognotedata->qual[idx].dchgsum[dcnt].result_dt_tm			= ce.event_end_dt_tm
	endif
	
foot ce.encntr_id
	prognotedata->qual[idx].has_dchgsum = evaluate(dcnt, 0, 0, 1)
	
with nocounter, expand = 1, time = 60
	

call echorecord(prognotedata)

;go to exitscript
 
 
/**************************************************************/ 
; select data
select into value($OUTDEV)
	patient_name			= p.name_full_formatted
	, fin					= ea.alias
;	, encntr_id				= prognotedata->qual[d1.seq].encntr_id
	, encntr_type			= uar_get_code_display(prognotedata->qual[d1.seq].encntr_type_cd)
	, admit_dt_tm			= prognotedata->qual[d1.seq].reg_dt_tm "mm/dd/yyyy hh:mm;;q"
	, disch_dt_tm			= prognotedata->qual[d1.seq].disch_dt_tm "mm/dd/yyyy hh:mm;;q"
;	, admitting_phys		= per2.name_full_formatted
	, los_days				= prognotedata->qual[d1.seq].los_days
	, compliant_ind			= evaluate(prognotedata->qual[d1.seq].is_compliant, 1, "Y", "N")
	
	; progress note
	, event					= uar_get_code_display(prognotedata->qual[d1.seq].prognote[d2.seq].event_cd)
	, performed_dt_tm		= prognotedata->qual[d1.seq].prognote[d2.seq].performed_dt_tm "mm/dd/yyyy hh:mm;;q"
	, performed_by			= per.name_full_formatted
	
	, has_prognote_lastday		= evaluate(prognotedata->qual[d1.seq].has_prognote_lastday, 1, "Y", "N")
	, is_missing			= evaluate(prognotedata->qual[d1.seq].prognote[d2.seq].is_missing, 1, "Y", "N")	
	, is_late				= evaluate(prognotedata->qual[d1.seq].prognote[d2.seq].is_late, 1, "Y", "N")
	, is_prognote_compliant		= evaluate(prognotedata->qual[d1.seq].prognote[d2.seq].is_compliant, 1, "Y", "N")

from
	(dummyt d1 with seq = value(prognotedata->cnt))
	, (dummyt d2 with seq = 1)
	, ENCNTR_ALIAS ea
	, PERSON p
	, PRSNL per
     
plan d1
where
	maxrec(d2, prognotedata->qual[d1.seq].prognote_cnt)

join ea
where
	ea.encntr_id = prognotedata->qual[d1.seq].encntr_id
	and ea.encntr_alias_type_cd = 1077.00 ; fin
	and ea.active_ind = 1

join p
where
	p.person_id = prognotedata->qual[d1.seq].person_id
	and p.active_ind = 1
	
join d2
	
join per
where
	per.person_id = prognotedata->qual[d1.seq].prognote[d2.seq].performed_prsnl_id
	and per.active_ind = 1

order by
	patient_name
	, prognotedata->qual[d1.seq].person_id
;	, encntr_id
	, prognotedata->qual[d1.seq].prognote[d2.seq].performed_dt_tm
	, event

with nocounter, outerjoin = d2, separator = " ", format, time = 180

 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

#exitscript

end go
 
