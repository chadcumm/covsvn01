/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		09/17/2021
	Solution:			Revenue Cycle - HIM
	Source file name:	cov_him_FaceToFace_Note.prg
	Object name:		cov_him_FaceToFace_Note
	Request #:			10041
 
	Program purpose:	Lists data for presence and timeliness of 
						progress notes for inpatient rehab accounts.
 
	Executing from:		CCL
 
 	Special Notes:		Report Type:
 							0 - By FIN
 							1 - By Facility
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program cov_him_FaceToFace_Note_TEST:dba go
create program cov_him_FaceToFace_Note_TEST:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Report Type" = 1
	, "FIN" = ""
	, "Facility" = VALUE(0.0            )
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE" 

with OUTDEV, report_type, fin, facility, start_datetime, end_datetime
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare anticipated_var				= f8 with constant(uar_get_code_by("MEANING", 8, "ANTICIPATED")), protect
declare inerror_var					= f8 with constant(uar_get_code_by("MEANING", 8, "INERROR")), protect
declare inprogress_var				= f8 with constant(uar_get_code_by("MEANING", 8, "IN PROGRESS")), protect
declare sign_action_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 21, "SIGN")), protect
declare perform_action_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 21, "PERFORM")), protect
declare root_var					= f8 with constant(uar_get_code_by("MEANING", 24, "ROOT")), protect
declare child_var					= f8 with constant(uar_get_code_by("MEANING", 24, "CHILD")), protect
declare otg_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 25, "OTG")), protect
declare mdoc_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 53, "MDOC")), protect
declare doc_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 53, "DOC")), protect
declare date_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 53, "DATE")), protect
declare rehab_inpatient_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "REHABINPATIENT")), protect
declare rehab_consult_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "REHABMEDICINECONSULTATION")), protect
declare pmr_progress_note_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "PMRPROGRESSNOTEFACETOFACEENCOUNT")), protect
declare fin_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR")), protect

declare fin_sql						= vc with noconstant("1 = 1")
declare reg_dt_tm_sql				= vc with noconstant("1 = 1")
declare op_facility_var				= vc with noconstant(fillstring(2, " "))
declare num							= i4 with noconstant(0), protect


; define sql for fin
if ($report_type = 0)
	if (trim($fin, 3) > "")
		set fin_sql = build2("ea.alias = '", $fin, "'")
	else
		select into $OUTDEV
			msg = "Please enter a FIN value."
			
		from dummyt
		
		detail
			col 0 msg
			
		with nocounter
		
		go to exitscript
	endif
else
	set reg_dt_tm_sql = build2("e.reg_dt_tm between cnvtdatetime('", $start_datetime, "') and cnvtdatetime('", $end_datetime, "')")
endif

call echo(build2("fin_sql: ", fin_sql))
call echo(build2("reg_dt_tm_sql: ", reg_dt_tm_sql))
 
 
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

free record data
record data (
	1 cnt						= i4
	1 qual [*]
		2 encntr_id				= f8
		2 encntr_type_cd		= f8
		2 person_id				= f8
		2 admit_dt_tm			= dq8
		2 disch_dt_tm			= dq8
		2 total_days			= i4
		2 organization_id		= f8
		
		2 consult_cnt					= i4
		2 consult [*]
			3 event_id					= f8
			3 event_cd					= f8
			3 event_class_cd			= f8
			3 event_title_text			= c100
			3 performed_prsnl_id		= f8
			3 performed_by				= c100
			3 result_status_cd			= f8
			3 result_dt_tm				= dq8
			3 result_tz					= i4		
		
		2 progress_cnt					= i4
		2 progress [*]
			3 event_id					= f8
			3 event_cd					= f8
			3 event_class_cd			= f8
			3 event_title_text			= c100
			3 performed_prsnl_id		= f8
			3 performed_by				= c100
			3 result_status_cd			= f8
			3 result_dt_tm				= dq8
			3 result_tz					= i4		
		
		; indicators for compliance logic		
		2 is_compliant			= i2
)
 
 
/**************************************************************/ 
; select consult note data
select into "nl:"
from 
	ENCOUNTER e
	
	, (inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = fin_var
		and ea.active_ind = 1
		and parser(fin_sql))
		
	, (left join CLINICAL_EVENT ce on ce.encntr_id = e.encntr_id
		and ce.event_class_cd in (mdoc_var)
		and ce.event_cd in (rehab_consult_var)
		and ce.result_status_cd not in (anticipated_var, inerror_var, inprogress_var)
		and ce.valid_until_dt_tm > cnvtdatetime(curdate, curtime3)
		)
		
	, (left join PRSNL per on per.person_id = ce.performed_prsnl_id
		and per.active_ind = 1)
	
where
	e.encntr_id > 0.0
;	and e.encntr_id in (126187459.00, 125020815.00, 126187015.00) ; TODO: TEST
	and operator(e.organization_id, op_facility_var, $facility)
	and e.encntr_type_cd = rehab_inpatient_var
	and parser(reg_dt_tm_sql)
	and e.active_ind = 1
	
order by
	e.encntr_id
	, ce.event_end_dt_tm
	, ce.event_id
	 	 
; populate record structure
head report
	cnt = 0
	
head e.encntr_id
	cnt = cnt + 1
	ccnt = 0
	
	call alterlist(data->qual, cnt)
	
	data->cnt 							= cnt
	data->qual[cnt].encntr_id			= e.encntr_id
	data->qual[cnt].encntr_type_cd		= e.encntr_type_cd
	data->qual[cnt].person_id			= e.person_id
	data->qual[cnt].admit_dt_tm			= e.reg_dt_tm
	data->qual[cnt].disch_dt_tm			= e.disch_dt_tm
	
	data->qual[cnt].total_days = 	
		if (e.disch_dt_tm > 0.0) 
			round(datetimediff(e.disch_dt_tm, e.reg_dt_tm, 1), 0) + 1
		else 
			round(datetimediff(cnvtdatetime(curdate, curtime), e.reg_dt_tm, 1), 0) + 1
		endif
	
	data->qual[cnt].organization_id		= e.organization_id
	
head ce.event_id
	ccnt = ccnt + 1
	
	call alterlist(data->qual[cnt].consult, ccnt)
	
	data->qual[cnt].consult_cnt 							= ccnt
	data->qual[cnt].consult[ccnt].event_id					= ce.event_id
	data->qual[cnt].consult[ccnt].event_cd					= ce.event_cd
	data->qual[cnt].consult[ccnt].event_class_cd			= ce.event_class_cd
	data->qual[cnt].consult[ccnt].event_title_text			= ce.event_title_text
	data->qual[cnt].consult[ccnt].performed_prsnl_id		= ce.performed_prsnl_id
	data->qual[cnt].consult[ccnt].performed_by				= per.name_full_formatted
	data->qual[cnt].consult[ccnt].result_status_cd			= ce.result_status_cd
	data->qual[cnt].consult[ccnt].result_dt_tm				= ce.event_end_dt_tm
	data->qual[cnt].consult[ccnt].result_tz					= ce.event_end_tz
	
with nocounter, time = 180

;call echorecord(data)
;
;go to exitscript
 
 
/**************************************************************/ 
; select progress note data
select into "nl:"
from 
	ENCOUNTER e
	
	, (inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = fin_var
		and ea.active_ind = 1
		and parser(fin_sql))
		
	, (left join CLINICAL_EVENT ce on ce.encntr_id = e.encntr_id
		and ce.event_class_cd in (mdoc_var)
		and ce.event_cd in (pmr_progress_note_var)
		and ce.result_status_cd not in (anticipated_var, inerror_var, inprogress_var)
		and ce.valid_until_dt_tm > cnvtdatetime(curdate, curtime3)
		)
		
	, (left join PRSNL per on per.person_id = ce.performed_prsnl_id
		and per.active_ind = 1)
	
where
	expand(num, 1, data->cnt, e.encntr_id, data->qual[num].encntr_id)
	
order by
	e.encntr_id
	, ce.event_end_dt_tm
	, ce.event_id
	 	 
; populate record structure
head e.encntr_id
	numx = 0
	idx = 0
	pcnt = 0
	
	idx = locateval(numx, 1, data->cnt, e.encntr_id, data->qual[numx].encntr_id)
	
head ce.event_id
	pcnt = pcnt + 1
	
	call alterlist(data->qual[idx].progress, pcnt)
	
	data->qual[idx].progress_cnt							= pcnt
	data->qual[idx].progress[pcnt].event_id					= ce.event_id
	data->qual[idx].progress[pcnt].event_cd					= ce.event_cd
	data->qual[idx].progress[pcnt].event_class_cd			= ce.event_class_cd
	data->qual[idx].progress[pcnt].event_title_text			= ce.event_title_text
	data->qual[idx].progress[pcnt].performed_prsnl_id		= ce.performed_prsnl_id
	data->qual[idx].progress[pcnt].performed_by				= per.name_full_formatted
	data->qual[idx].progress[pcnt].result_status_cd			= ce.result_status_cd
	data->qual[idx].progress[pcnt].result_dt_tm				= ce.event_end_dt_tm
	data->qual[idx].progress[pcnt].result_tz				= ce.event_end_tz
	
with nocounter, time = 180

;call echorecord(data)
;
;go to exitscript
 
 
/**************************************************************/ 
; select indicator data
select into "nl:"
	person_id			= data->qual[d1.seq].person_id
	, encntr_id			= data->qual[d1.seq].encntr_id
	, total_days		= data->qual[d1.seq].total_days
	
from
	(dummyt d1 with seq = value(data->cnt))
	, (dummyt d2 with seq = 1)
	, (dummyt d3 with seq = 1)
	
plan d1
where
	maxrec(d2, data->qual[d1.seq].consult_cnt)
	and maxrec(d3, data->qual[d1.seq].progress_cnt)

join d2
join d3
	
order by
	data->qual[d1.seq].person_id
	, data->qual[d1.seq].encntr_id
	, data->qual[d1.seq].consult[d2.seq].result_dt_tm
	, data->qual[d1.seq].progress[d3.seq].result_dt_tm

; populate record structure
head person_id
	null

foot encntr_id
	total_sets = floor(total_days / 7)
	days_remaining = (total_days - (total_sets * 7))
	total_notes = 0
	isvalid = 0
	
	call echo("")
	call echo(build2("total_days: ", total_days))
	call echo(build2("total_sets: ", total_sets))
	call echo(build2("days_remaining: ", days_remaining))
	call echo("-----")

	for (i = 1 to total_days)
		call echo(build2("i: ", i))
		
		day_dt = cnvtdate(datetimeadd(data->qual[d1.seq].admit_dt_tm, i - 1))
		
		call echo(build2("day_dt: ", format(day_dt, ";;d")))
		
		if (data->qual[d1.seq].consult_cnt > 0)
			for (j = 1 to data->qual[d1.seq].consult_cnt)		
				consult_result_dt = cnvtdate(data->qual[d1.seq].consult[j].result_dt_tm)
	
				if (day_dt = consult_result_dt)
					total_notes += 1
				endif
			endfor
		endif
		
		if (data->qual[d1.seq].progress_cnt > 0)
			for (k = 1 to data->qual[d1.seq].progress_cnt)
				progress_result_dt = cnvtdate(data->qual[d1.seq].progress[k].result_dt_tm)
	
				if (day_dt = progress_result_dt)
					total_notes += 1
				endif
			endfor
		endif
		
		call echo(build2("total_notes: ", total_notes))
				
		if (total_sets > 0)
			if (mod(i, 7) = 0)				
				if (total_notes >= 3)
					isvalid = 1
				else
					isvalid = 0
					
					i = total_days
				
					call echo("exit for loop")
				endif
				
				total_notes = 0
			endif
		else
			isvalid = 1
		endif
	
		call echo(build2("isvalid: ", isvalid))
		call echo("-----")
	endfor
	
	if ((days_remaining > 0) and isvalid)
		if (days_remaining = 3)
			if (total_notes >= 1) isvalid = 1 else isvalid = 0 endif
						
		elseif (days_remaining in (4, 5))
			if (total_notes >= 1) isvalid = 1 else isvalid = 0 endif
						
		elseif (days_remaining = 6)
			if (total_notes >= 2) isvalid = 1 else isvalid = 0 endif
						
		else
			isvalid = 1
					
		endif
	endif
	
	call echo(build2("isvalid final: ", isvalid))
	call echo("-----")
	call echo("")
	
foot encntr_id
	data->qual[d1.seq].is_compliant = isvalid
	
	if (data->qual[d1.seq].consult_cnt > 0)
		if (data->qual[d1.seq].consult[1].event_cd = 0.0)
			data->qual[d1.seq].is_compliant = 0
		endif
	endif
	
with nocounter, outerjoin = d1, time = 180

call echorecord(data)
 
 
/**************************************************************/ 
; select data
if (data->cnt = 0)
	select into $OUTDEV
		msg = "No output returned."
		
	from dummyt
	
	detail
		col 0 msg
		
	with nocounter
	
	go to exitscript
endif


select if ($report_type = 0)

	head report
		page_factor = ((7 * 5) + 1)
		total_pages = ceil(total_days / (page_factor * 1.0))

	head page
		col 0	"HIM"
		col 68	"Printed:"
		col 78	curdate
		col 87	curtime
		row + 2
		
		col 0	"Inpatient Rehab Face To Face Notes"
		row + 3

		col 0	"Patient Name:"		, col 20	patient_name
		row + 1
		col 0	"FIN:"				, col 20	fin
		row + 1
		col 0	"Admit Date:"		, col 20	admit_dt_tm
		row + 1
		col 0	"Discharge Date:"	, col 20	disch_dt_tm
		col 50	"Total Days:"		, col 65	total_days ";l;"
		row + 2
		col 0	"Compliant:"		, col 20	compliant_ind
		row + 3
		col 0 	"Day"
		col 7 	"Date"
		col 20 	"Note"
		col 65 	"Provider"
		row + 2
		
	foot fin		
		for (i = 1 to total_days)
			if (mod(i, page_factor) = 0) 
				break 
			endif
			
			day_dt = cnvtdate(datetimeadd(data->qual[d1.seq].admit_dt_tm, i - 1))
			
			col 0	i "###;p "
			col 7	day_dt "mm/dd/yyyy;;d"
			
			if (data->qual[d1.seq].consult_cnt > 0)
				for (j = 1 to data->qual[d1.seq].consult_cnt)
					consult_result_dt = cnvtdate(data->qual[d1.seq].consult[j].result_dt_tm)
					consult_event_title2 = trim(data->qual[d1.seq].consult[j].event_title_text, 3)
					consult_performed_by2 = trim(data->qual[d1.seq].consult[j].performed_by, 3)
		
					if (day_dt = consult_result_dt)
						col 20	consult_event_title2
						col 65	consult_performed_by2
					endif
				endfor				
			endif
			
			if (data->qual[d1.seq].progress_cnt > 0)
				for (k = 1 to data->qual[d1.seq].progress_cnt)
					progress_result_dt = cnvtdate(data->qual[d1.seq].progress[k].result_dt_tm)
					progress_event_title2 = trim(data->qual[d1.seq].progress[k].event_title_text, 3)
					progress_performed_by2 = trim(data->qual[d1.seq].progress[k].performed_by, 3)
				
					if (day_dt = progress_result_dt)
						col 20	progress_event_title2
						col 65	progress_performed_by2
					endif
				endfor
			endif
			
			if (mod(i, 7) = 0)
				row + 2
			else
				row + 1
			endif
		endfor
		
	foot page
		page_set = build2("Page: ", trim(cnvtstring(curpage)), " of ", trim(cnvtstring(total_pages)))
		
		row + 3
		col 0	curprog
		col 78	page_set
	
	with nocounter, maxcol = 264, dio = 8, diomargin = 72, time = 180

endif

distinct into value($OUTDEV)
	patient_name			= trim(p.name_full_formatted, 3)
	, fin					= trim(ea.alias, 3)
;	, encntr_id				= data->qual[d1.seq].encntr_id
	, encntr_type			= trim(uar_get_code_display(data->qual[d1.seq].encntr_type_cd), 3)
	, admit_dt_tm			= data->qual[d1.seq].admit_dt_tm "mm/dd/yyyy hh:mm zzz;;q"
	, disch_dt_tm			= data->qual[d1.seq].disch_dt_tm "mm/dd/yyyy hh:mm zzz;;q"
	, total_days			= data->qual[d1.seq].total_days
	, compliant_ind			= evaluate(data->qual[d1.seq].is_compliant, 1, "Y", "N")
	
	, facility				= org.org_name
	
	; consult note
	, consult_event				= trim(uar_get_code_display(data->qual[d1.seq].consult[d2.seq].event_cd), 3)								  
	, consult_event_title		= trim(data->qual[d1.seq].consult[d2.seq].event_title_text, 3)	
	, consult_result_status		= trim(uar_get_code_display(data->qual[d1.seq].consult[d2.seq].result_status_cd), 3)
	
	, consult_result_dt_tm		= datetimezoneformat(data->qual[d1.seq].consult[d2.seq].result_dt_tm, 
													   data->qual[d1.seq].consult[d2.seq].result_tz, "mm/dd/yyyy hh:mm zzz;;q", 0)
													 
	, consult_performed_by		= trim(data->qual[d1.seq].consult[d2.seq].performed_by, 3)
	
	; progress note
	, progress_event				= trim(uar_get_code_display(data->qual[d1.seq].progress[d3.seq].event_cd), 3)									  
	, progress_event_title			= trim(data->qual[d1.seq].progress[d3.seq].event_title_text, 3)									  
	, progress_result_status		= trim(uar_get_code_display(data->qual[d1.seq].progress[d3.seq].result_status_cd), 3)
									  
	, progress_result_dt_tm			= datetimezoneformat(data->qual[d1.seq].progress[d3.seq].result_dt_tm, 
														   data->qual[d1.seq].progress[d3.seq].result_tz, "mm/dd/yyyy hh:mm zzz;;q", 0)
	
	, progress_performed_by			= trim(data->qual[d1.seq].progress[d3.seq].performed_by, 3)
	
from
	(dummyt d1 with seq = value(data->cnt))
	, ENCNTR_ALIAS ea
	, PERSON p
	, ORGANIZATION org
	, (dummyt d2 with seq = 1)
	, (dummyt d3 with seq = 1)
     
plan d1
where
	maxrec(d2, data->qual[d1.seq].consult_cnt)
	and maxrec(d3, data->qual[d1.seq].progress_cnt)

join ea
where
	ea.encntr_id = data->qual[d1.seq].encntr_id
	and ea.encntr_alias_type_cd = fin_var
	and ea.active_ind = 1

join p
where
	p.person_id = data->qual[d1.seq].person_id
	and p.active_ind = 1

join org
where
	org.organization_id = data->qual[d1.seq].organization_id
	and org.active_ind = 1
	
join d2	
join d3
	
order by
	patient_name
	, data->qual[d1.seq].person_id
	, fin	
	, data->qual[d1.seq].consult[d2.seq].result_dt_tm	  
	, consult_event	
	, data->qual[d1.seq].progress[d3.seq].result_dt_tm	
	, progress_event
	
with nocounter, outerjoin = d1, separator = " ", format, time = 180

 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

#exitscript

end go
 
