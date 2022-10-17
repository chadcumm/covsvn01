/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		01/17/2019
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_Cancelled_Accts_Docs.prg
	Object name:		cov_sm_Cancelled_Accts_Docs
	Request #:			4034, 8518, 10839, 12391, 12613
 
	Program purpose:	Lists cancelled accounts with documentation.
 
	Executing from:		CCL
 
 	Special Notes:		Exported data is used by external process.
 
 						Output file: cancel_acct_doc.csv
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	01/21/2019	Todd A. Blanchard		Adjusted table joins for efficiency.
002	09/09/2020	Todd A. Blanchard		Adjusted criteria to filter out TOG when
 										cancelled and without documents or notes.
003	02/16/2022	Todd A. Blanchard		Added encounter flex history data to query.
										Adjusted criteria to filter on encounter flex
										history transaction data.
004	03/17/2022	Todd A. Blanchard		Added logic to export data.
005	04/07/2022	Todd A. Blanchard		Added medical service data.
										Adjusted logic to exclude cancelled encounters
										that are rescheduled.
006	04/18/2022	Todd A. Blanchard		Adjusted criteria to filter on encounter flex
										history transaction data.
										Added prior and post visit type data.
										Added indicator for coding summary document.
										Added logic for future scheduled appointments.
										Added future scheduled appointment date/time.
 
******************************************************************************/
 
drop program cov_sm_Cancelled_Accts_Docs:DBA go
create program cov_sm_Cancelled_Accts_Docs:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Output To File" = 0                   ;* Output to file 

with OUTDEV, start_datetime, end_datetime, output_file
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare start_datetime				= dq8 with noconstant(cnvtlookbehind("8, d", cnvtdatetime(curdate, 000000))) ;004
declare end_datetime				= dq8 with noconstant(cnvtlookahead("1, d", cnvtdatetime(curdate, 235959))) ;004
declare cmrn_var					= f8 with constant(uar_get_code_by("MEANING", 4, "CMRN"))
declare mrn_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "MRN"))
declare fin_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare dict_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 25, "DICT"))
declare otg_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 25, "OTG"))
declare canceluponreview_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "CANCELUPONREVIEW"))
declare codingsummary_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "CODINGSUMMARY")) ;006
declare emergency_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 321, "EMERGENCY")) ;006
declare confirmed_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 14233, "CONFIRMED")) ;006
declare num							= i4 with noconstant(0)
declare num2						= i4 with noconstant(0)
declare num3						= i4 with noconstant(0) ;006
declare numx						= i4 with noconstant(0)

;004
declare file_var					= vc with constant("cancel_acct_doc.csv")
 
declare temppath_var				= vc with constant(build("cer_temp:", file_var))
declare temppath2_var				= vc with constant(build("$cer_temp/", file_var))
 
declare filepath_var				= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
															 "_cust/to_client_site/RevenueCycle/Scheduling/", file_var))
 
declare output_var					= vc with noconstant("")
 
declare cmd							= vc with noconstant("")
declare len							= i4 with noconstant(0)
declare stat						= i4 with noconstant(0)
 
 
; define output value ;004
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set output_var = value(temppath_var)
else
	set output_var = value($OUTDEV)
endif
	
	
;004
if (validate(request->batch_selection) != 1)
	set start_datetime = cnvtdatetime($start_datetime)
	set end_datetime = cnvtdatetime($end_datetime)
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/

;002
record tog (
	1	cnt							= i4
	1	list[*]
		2	code_value				= f8
)

;003
record enc_flex ( 
	1	cnt							= i4
	1	list[*]
		2	encntr_id				= f8
		2	person_id				= f8 ;005
		2	encntr_class_cd			= f8 ;006
		2	encntr_type_cd			= f8 ;006
		2	transaction_dt_tm		= dq8
		2	has_coding_summary		= i2 ;006
)

;006
record enc_flex_before ( 
	1	cnt							= i4
	1	list[*]
		2	encntr_id				= f8
		2	person_id				= f8
		2	encntr_class_cd			= f8 ;006
		2	encntr_type_cd			= f8
		2	transaction_dt_tm		= dq8
)

;005
record enc_flex_after ( 
	1	cnt							= i4
	1	list[*]
		2	encntr_id				= f8
		2	person_id				= f8
		2	fin						= c20 ;006
		2	encntr_class_cd			= f8 ;006
		2	encntr_type_cd			= f8 ;006
		2	transaction_dt_tm		= dq8
)

;002
record enc (
	1	p_start_datetime			= vc
	1	p_end_datetime				= vc
 
	1	cnt							= i4
	1	list[*]
		2	encntr_id				= f8
		2	encntr_class_cd			= f8 ;006
		2	encntr_type_cd			= f8
		2	med_service_cd			= f8 ;005
		2	location_cd				= f8
		2	reg_dt_tm				= dq8
		2	disch_dt_tm				= dq8 ;003
		2	person_id				= f8
		2	patient_name			= c100
		2	birth_dt_tm				= dq8
		2	birth_tz				= i4
		2	cmrn					= c20
		2	mrn						= c20
		2	fin						= c20
		2	has_docs_or_notes		= i2
		2	has_orders				= i2
		2	has_appts				= i2
		2	appt_dt_tm				= dq8 ;006
		
;		2	is_excluded				= i2 ;006
;		2	excluding_fin			= c20 ;006
		2	has_coding_summary		= i2 ;006
)


/**************************************************************/
; populate tog record structure with code value data ;002
select into "NL:"
from 
	CODE_VALUE cv
where 
	cv.code_set = 220 
	and cv.cdf_meaning in ("FACILITY", "AMBULATORY")
	and cv.display_key in ("*TOG*")
	and cv.active_ind = 1
 
 
; populate record structure
head report
	cnt = 0
	
detail
	cnt = cnt + 1
	
	call alterlist(tog->list, cnt)
	
	tog->cnt					= cnt	
	tog->list[cnt].code_value	= cv.code_value
	
with nocounter, time = 120

;call echorecord(tog)
 
 
/**************************************************************/
; populate enc record structure with prompt data ;002
set enc->p_start_datetime = format(cnvtdatetime(start_datetime), "mm/dd/yyyy hh:mm;;q")
set enc->p_end_datetime = format(cnvtdatetime(end_datetime), "mm/dd/yyyy hh:mm;;q")
 
 
/**************************************************************/
; select encounter flex history data for cancelled encounters ;003
select distinct into "NL:" 
from
	ENCNTR_FLEX_HIST efh
	
	;006
	, (left join CLINICAL_EVENT ce on ce.encntr_id = efh.encntr_id
		and ce.event_cd = codingsummary_var)
 
where
	efh.encntr_type_cd = canceluponreview_var
	and efh.transaction_dt_tm between cnvtdatetime(start_datetime) and cnvtdatetime(end_datetime)
	and efh.transaction_dt_tm = (
		select min(efh2.transaction_dt_tm)
		from
			ENCNTR_FLEX_HIST efh2
		where
			efh2.encntr_id = efh.encntr_id
			and efh2.encntr_type_cd = efh.encntr_type_cd
	)
	
;	and efh.person_id in (15742078) ; TODO: TESTING
order by
	efh.encntr_id
	, efh.transaction_dt_tm
 
 
; populate record structure
head report
	cnt = 0
	
head efh.encntr_id ;006
	cnt = cnt + 1
	
	call alterlist(enc_flex->list, cnt)
	
	enc_flex->cnt								= cnt
	enc_flex->list[cnt].encntr_id				= efh.encntr_id
	enc_flex->list[cnt].person_id				= efh.person_id ;005
	enc_flex->list[cnt].encntr_class_cd			= efh.encntr_class_cd ;006
	enc_flex->list[cnt].encntr_type_cd			= efh.encntr_type_cd ;006
	enc_flex->list[cnt].transaction_dt_tm		= efh.transaction_dt_tm
	enc_flex->list[cnt].has_coding_summary		= if (ce.event_id > 0.0) 1 else 0 endif ;006
	
with nocounter, time = 120

call echorecord(enc_flex)

;go to exitscript
 
 
/**************************************************************/
; select previous encounter flex history data for cancelled encounters ;006
select into "NL:" 
from
	ENCNTR_FLEX_HIST efh
	
	, (dummyt d1 with seq = value(enc_flex->cnt))
	
plan d1

join efh 
where 1 = 1
;	and efh.person_id = enc_flex->list[d1.seq].person_id ;006
	and efh.encntr_id = enc_flex->list[d1.seq].encntr_id
	and efh.encntr_type_cd not in (canceluponreview_var, 0.0)
	and efh.transaction_dt_tm < cnvtdatetime(enc_flex->list[d1.seq].transaction_dt_tm)
	
;	and efh.person_id in (15742078) ; TODO: TESTING
	
order by
	efh.person_id
	, efh.transaction_dt_tm desc
	, efh.encntr_id
 
 
; populate record structure
head report
	cnt = 0
	
head efh.encntr_id		
	cnt = cnt + 1
	
	call alterlist(enc_flex_before->list, cnt)
	
	enc_flex_before->cnt								= cnt
	enc_flex_before->list[cnt].encntr_id				= efh.encntr_id
	enc_flex_before->list[cnt].person_id				= efh.person_id
	enc_flex_before->list[cnt].encntr_class_cd			= efh.encntr_class_cd
	enc_flex_before->list[cnt].encntr_type_cd			= efh.encntr_type_cd
	enc_flex_before->list[cnt].transaction_dt_tm		= efh.transaction_dt_tm
	
with nocounter, time = 120

call echorecord(enc_flex_before)

;go to exitscript
 
 
/**************************************************************/
; select encounter flex history data for rescheduled encounters ;005
select into "NL:" 
from
	ENCNTR_FLEX_HIST efh
 
 	;006
	, (left join ENCNTR_ALIAS eaf on eaf.encntr_id = efh.encntr_id
		and eaf.encntr_alias_type_cd = fin_var
		and eaf.active_ind = 1)
	
	, (dummyt d1 with seq = value(enc_flex->cnt))
	
plan d1

join efh 
where 1 = 1
;	and efh.person_id = enc_flex->list[d1.seq].person_id ;006
	and efh.encntr_id = enc_flex->list[d1.seq].encntr_id
	and efh.encntr_type_cd = canceluponreview_var
	
;	and efh.person_id in (15742078) ; TODO: TESTING
	
join eaf ;006
	
order by
	efh.person_id
	, efh.transaction_dt_tm desc ;006
	, efh.encntr_id
 
 
; populate record structure
head report
	cnt = 0
	
head efh.encntr_id ;006
	cnt = cnt + 1
	
	call alterlist(enc_flex_after->list, cnt)
	
	enc_flex_after->cnt									= cnt
	enc_flex_after->list[cnt].encntr_id					= efh.encntr_id
	enc_flex_after->list[cnt].person_id					= efh.person_id
	enc_flex_after->list[cnt].fin						= cnvtalias(eaf.alias, eaf.alias_pool_cd) ;006
	enc_flex_after->list[cnt].encntr_class_cd			= efh.encntr_class_cd ;006
	enc_flex_after->list[cnt].encntr_type_cd			= efh.encntr_type_cd ;006
	enc_flex_after->list[cnt].transaction_dt_tm			= efh.transaction_dt_tm
	
with nocounter, time = 120

call echorecord(enc_flex_after)

;go to exitscript
 
 
/**************************************************************/
; select encounter data ;002
select into "NL:" 
from
	ENCOUNTER e
 
	, (left join ENCNTR_ALIAS eaf on eaf.encntr_id = e.encntr_id
		and eaf.encntr_alias_type_cd = fin_var
		and eaf.active_ind = 1)
 
	, (left join ENCNTR_ALIAS eam on eam.encntr_id = e.encntr_id
		and eam.encntr_alias_type_cd = mrn_var
		and eam.active_ind = 1)
 
	, (inner join PERSON p on p.person_id = e.person_id
		and p.active_ind = 1)
 
	, (left join PERSON_ALIAS pa on pa.person_id = p.person_id
		and pa.person_alias_type_cd = cmrn_var
		and pa.active_ind = 1)
 
 	; docs and notes
	, (left join CLINICAL_EVENT ce on ce.encntr_id = e.encntr_id
		and ce.event_id = ce.parent_event_id
		and (
			ce.event_class_cd in (
				select
					cv.code_value
				from
					CODE_VALUE cv
				where
					cv.code_set = 53
					and cv.display_key like "*DOC*" ; all documents
			)
			or ce.event_cd in (
				select
					cv.code_value
				from
					CODE_VALUE cv
				where
					cv.code_set = 72
					and cv.display_key like "*NOTE*" ; all notes
					; exclusions
					and cv.display_key not like "*NOTEC*"
					and cv.display_key not like "*NOTED*"
					and cv.display_key not like "*NOTER*"
					and cv.display_key not like "*NOTET*"
			)
		))
 
	, (left join CE_BLOB_RESULT cebr on cebr.event_id = ce.event_id
		and cebr.storage_cd in (otg_var, dict_var))
 
 	; orders
	, (left join ORDERS o on o.encntr_id = e.encntr_id
		and o.active_ind = 1)
 
	; scheduled orders
	, (left join SCH_APPT sa on sa.person_id = p.person_id
		and sa.role_meaning = "PATIENT"
		and sa.sch_state_cd = confirmed_var ;006
		and sa.beg_dt_tm > cnvtdatetime(curdate, curtime) ;006
		and sa.active_ind = 1)
 
	, (left join SCH_EVENT se on se.sch_event_id = sa.sch_event_id
		and se.active_ind = 1)
 
	, (left join SCH_EVENT_ATTACH sea on sea.sch_event_id = se.sch_event_id
		and sea.active_ind = 1)
 
	, (left join ORDERS o2 on o2.order_id = sea.order_id
		and o2.active_ind = 1)
 
where
	expand(num, 1, enc_flex->cnt, e.encntr_id, enc_flex->list[num].encntr_id) ;003
;	and (
;		; exclude where rescheduled
;		not expand(num2, 1, enc_flex_after->cnt, e.person_id, enc_flex_after->list[num2].person_id) ;005
;		;006
;		or (
;			; include where rescheduled and previously ED
;			expand(num2, 1, enc_flex_after->cnt, e.person_id, enc_flex_after->list[num2].person_id)
;			and expand(num3, 1, enc_flex_before->cnt, e.person_id, enc_flex_before->list[num3].person_id,
;													  emergency_var, enc_flex_before->list[num3].encntr_class_cd)
;		)
;	)
;	; exclude where rescheduled and has coding summary ;006
;	and not expand(num2, 1, enc_flex_after->cnt, e.person_id, enc_flex_after->list[num2].person_id,
;												 1, enc_flex_after->list[num2].has_coding_summary)
	and e.encntr_type_cd = canceluponreview_var
	and e.active_ind = 1
	
;	and e.person_id in (15742078) ; TODO: TESTING
 
order by
	e.encntr_id ;003
	, sa.beg_dt_tm ;006
 
 
; populate record structure
head report
	cnt = 0
	
head e.encntr_id
	idx = 0
	numx = 0
	keep = 0
	
	; determine if TOG
	idx = locateval(numx, 1, tog->cnt, e.location_cd, tog->list[numx].code_value)

	if (idx > 0)
		; determine if has docs or notes
		if ((ce.event_id > 0.0) or (cebr.event_id > 0.0))
			keep = 1
		endif
	else
		keep = 1
	endif
	
	;006
;	; determine if will be excluded
;	idx = 0
;	is_excluded = 0
;	excluding_fin = fillstring(20, "")
;	
;;	idx = locateval(numx, 1, enc_flex_after->cnt, e.person_id, enc_flex_after->list[numx].person_id)
;	idx = locateval(numx, 1, enc_flex_after->cnt, e.encntr_id, enc_flex_after->list[numx].encntr_id) ;006
;			
;	if (idx > 0)
;		is_excluded = 1
;		excluding_fin = enc_flex_after->list[idx].fin
;	endif
	
	;006
	; determine if has coding summary
	idx = 0
	has_coding_summary = 0
	
;	idx = locateval(numx, 1, enc_flex->cnt, e.person_id, enc_flex->list[numx].person_id)
	idx = locateval(numx, 1, enc_flex->cnt, e.encntr_id, enc_flex->list[numx].encntr_id) ;006
			
	if (idx > 0)
		has_coding_summary = enc_flex->list[idx].has_coding_summary
	endif
	
	; determine if qualifies
	if (keep = 1)
		cnt = cnt + 1
		
		call alterlist(enc->list, cnt)
		
		enc->cnt								= cnt	
		enc->list[cnt].encntr_id				= e.encntr_id	
		enc->list[cnt].encntr_class_cd			= e.encntr_class_cd ;006
		enc->list[cnt].encntr_type_cd			= e.encntr_type_cd
		enc->list[cnt].med_service_cd			= e.med_service_cd ;005
		enc->list[cnt].location_cd	 			= e.location_cd
		enc->list[cnt].reg_dt_tm				= e.reg_dt_tm
		enc->list[cnt].disch_dt_tm				= e.disch_dt_tm
		enc->list[cnt].patient_name				= p.name_full_formatted
		enc->list[cnt].person_id				= p.person_id
		enc->list[cnt].birth_dt_tm				= p.birth_dt_tm
		enc->list[cnt].birth_tz					= p.birth_tz
		enc->list[cnt].cmrn						= cnvtalias(pa.alias, pa.alias_pool_cd)
		enc->list[cnt].mrn						= cnvtalias(eam.alias, eam.alias_pool_cd)
		enc->list[cnt].fin						= cnvtalias(eaf.alias, eaf.alias_pool_cd)
		enc->list[cnt].has_docs_or_notes		= if ((ce.event_id > 0.0) or (cebr.event_id > 0.0)) 1 else 0 endif
		enc->list[cnt].has_orders				= if ((o.order_id > 0.0) or (o2.order_id > 0.0)) 1 else 0 endif
		enc->list[cnt].has_appts				= if (sa.sch_appt_id > 0.0) 1 else 0 endif
		enc->list[cnt].appt_dt_tm				= sa.beg_dt_tm ;006
		
;		enc->list[cnt].is_excluded				= is_excluded ;006
;		enc->list[cnt].excluding_fin			= excluding_fin ;006
		enc->list[cnt].has_coding_summary		= has_coding_summary ;006
	endif
	
with nocounter, expand = 1, time = 120

call echorecord(enc)

;go to exitscript
 
 
/**************************************************************/
; select data ;002 ;004
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set modify filestream
endif
 
select if (validate(request->batch_selection) = 1 or $output_file = 1)
	with nocounter, outerjoin = d1, pcformat (^"^, ^,^, 1), format = stream, format, time = 120 ;006
else
	with nocounter, outerjoin = d1, separator = " ", format, time = 120 ;006
endif
 
distinct into value(output_var) ;006
	encntr_id				= enc->list[d1.seq].encntr_id
	, encntr_class			= trim(uar_get_code_display(enc->list[d1.seq].encntr_class_cd), 3) ;006
	, encntr_type			= trim(uar_get_code_display(enc->list[d1.seq].encntr_type_cd), 3)
	, prev_encntr_type		= trim(uar_get_code_display(enc_flex_before->list[d3.seq].encntr_type_cd), 3) ;006
	, med_service			= trim(uar_get_code_display(enc->list[d1.seq].med_service_cd), 3)
;	, location	 			= trim(uar_get_code_display(enc->list[d1.seq].location_cd), 3)
	, cancelled_dt_tm		= enc_flex->list[d2.seq].transaction_dt_tm "mm/dd/yyyy hh:mm:ss;;q" ;003
	, reg_dt_tm				= enc->list[d1.seq].reg_dt_tm "mm/dd/yyyy hh:mm:ss;;q"
	, disch_dt_tm			= enc->list[d1.seq].disch_dt_tm "mm/dd/yyyy hh:mm:ss;;q" ;003
	
	, person_id				= enc->list[d1.seq].person_id
	, patient_name			= enc->list[d1.seq].patient_name
	
	, dob					= format(cnvtdatetimeutc(datetimezone(
								enc->list[d1.seq].birth_dt_tm, enc->list[d1.seq].birth_tz), 1), "mm/dd/yyyy;;d")
	
	, cmrn						= enc->list[d1.seq].cmrn
	, mrn						= enc->list[d1.seq].mrn
	, fin						= enc->list[d1.seq].fin
	, has_docs_or_notes			= evaluate(enc->list[d1.seq].has_docs_or_notes, 1, "YES", "NO")
	, has_orders				= evaluate(enc->list[d1.seq].has_orders, 1, "YES", "NO")
	, has_appts					= evaluate(enc->list[d1.seq].has_appts, 1, "YES", "NO")
	, appt_dt_tm				= enc->list[d1.seq].appt_dt_tm "mm/dd/yyyy hh:mm:ss;;q" ;006
	
	;006
;	, is_excluded				= evaluate(enc->list[d1.seq].is_excluded, 1, "YES", "NO")
;	, excluding_fin				= trim(enc->list[d1.seq].excluding_fin, 3)
;	, has_coding_summary		= evaluate(enc->list[d1.seq].has_coding_summary, 1, "YES", "NO")
	
from
	(dummyt d1 with seq = value(enc->cnt))
	
	, (dummyt d2 with seq = value(enc_flex->cnt)) ;003
	
	, (dummyt d3 with seq = value(enc_flex_before->cnt)) ;006
	
plan d1 ;003
where enc->list[d1.seq].has_coding_summary = 0 ;006

;003
join d2
where enc_flex->list[d2.seq].encntr_id = enc->list[d1.seq].encntr_id

;006
join d3
where enc_flex_before->list[d3.seq].encntr_id = enc->list[d1.seq].encntr_id

;003
order by
	enc_flex->list[d2.seq].transaction_dt_tm
	, patient_name
	, person_id
	, encntr_id ;006
	, fin ;006
	
with nocounter, outerjoin = d1 ;006
 
 
/**************************************************************/
; copy file to AStream ;004
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set cmd = build2("cp ", temppath2_var, " ", filepath_var)
	set len = size(trim(cmd))
 
	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
endif


;go to exitscript
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript
 
end
go
 
