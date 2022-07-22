/*****************************************************************************
 *  Covenant Health Information Technology
 *  Knoxville, Tennessee
 *****************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		06/18/2019
	Solution:			Revenue Cycle - HIM
	Source file name:	cov_him_CDICodingQuery.prg
	Object name:		cov_him_CDICodingQuery
	Request #:			4317, 6746, 9350
 
	Program purpose:	Select data for CDI Coding Query Reminders.
 
	Executing from:		CCL
 
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	08/20/2019	Todd A. Blanchard		Revised queries for more accurate results.
002	12/18/2019	Todd A. Blanchard		Restructured CCL.
003	01/16/2020	Todd A. Blanchard		Revised reminder query.
004	01/27/2020	Todd A. Blanchard		Revised encounter query.
005	01/30/2020	Todd A. Blanchard		Added code value outbound data to derive status values.
006	01/31/2020	Todd A. Blanchard		Added addendum data for reminders.
007	02/03/2020	Todd A. Blanchard		Revised reminder query.
008	01/25/2021	Todd A. Blanchard		Added logic and columns for forwarded indicator and forwarded to.
 
******************************************************************************/
 
drop program cov_him_CDICodingQuery_TEST go
create program cov_him_CDICodingQuery_TEST
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility" = 0
	, "Discharge Start Date" = "SYSDATE"
	, "Discharge End Date" = "SYSDATE"
 
with OUTDEV, facility, start_datetime, end_datetime
 
/**************************************************************
; DVDev declareD SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev declareD VARIABLES
**************************************************************/
 
declare fin_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare sign_action_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 21, "SIGN"))
declare perform_action_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 21, "PERFORM"))
declare cdi_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "CDICODINGQUERY"))
declare reminder_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "REMINDERS"))
declare mdoc_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 53, "MDOC"))
declare doc_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 53, "DOC"))
declare attachment_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 53, "ATTACHMENT"))
declare discharge_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 17, "DISCHARGE"))
declare covenant_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 73, "COVENANT"))
declare root_var				= f8 with constant(uar_get_code_by("MEANING", 24, "ROOT"))
declare child_var				= f8 with constant(uar_get_code_by("MEANING", 24, "CHILD"))

declare c_desc_var				= vc with constant("Concurrent")
declare d_desc_var				= vc with constant("Discharge")
 
declare compcd					= f8 with constant(uar_get_code_by("DISPLAYKEY", 120, "OCFCOMPRESSION"))
declare num						= i4 with noconstant(0)
declare crlf 					= vc with constant(concat(char(13), char(10)))
 
declare op_facility_var			= vc with noconstant(fillstring(100, " "))
 
 
; define operator for $facility
if (substring(1, 1, reflect(parameter(parameter2($facility), 0))) = "L") ; multiple values selected
    set op_facility_var = "IN"
elseif (parameter(parameter2($facility), 1) = 0.0) ; any selected
    set op_facility_var = "!="
else ; single value selected
    set op_facility_var = "="
endif
 
/*************************************************************
; DVDev Start Coding
**************************************************************/
 
record cdi (
	1 startdate 				= vc
	1 enddate   				= vc
 
	1 cnt						= i4
	1 list[*]
		2 encntr_id				= f8
		2 person_id				= f8
		2 patient_name			= c100
		2 fin					= c20
		2 facility				= c60
		2 nurseunit				= c40
		2 dx					= c400
		2 disch_dt_tm			= dq8
 
		;002
		2 nrcnt						= i4
		2 nrlist[*]
			; note/reminder
			3 parent_event_id		= f8
			3 event_id				= f8
			3 event_title			= c100
			3 event_cd				= f8
			3 event_type			= c40
			3 action_type			= c40
			3 action_by				= c100
			3 action_date			= dq8
			3 action_desc			= c10
			
			3 result_status			= c40
			
			3 forward_ind			= c1	;008
			3 forward_to			= c100	;008
 
			; addendum
			3 addendum				= c1024
			3 addendum_by			= c100
			3 addendum_date			= dq8
			3 addendum_desc			= c10
 
			; addendum data
			3 eid					= f8
			3 blob_seq_num			= i4
			3 blob_length			= i4
			3 valid_from_dt_tm		= dq8
			3 valid_until_dt_tm		= dq8
			3 updt_dt_tm			= dq8
)
 
/**************************************************************/
; set prompt data
set cdi->startdate = $start_datetime
set cdi->enddate = $end_datetime
 
 
/**************************************************************/
; select encounter data
select distinct into "NL:"
from
	ENCOUNTER e
 
	, (inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = fin_var
		and ea.end_effective_dt_tm > sysdate
		and ea.active_ind = 1)
 
	, (inner join PERSON p on p.person_id = e.person_id)
 
where
	operator(e.loc_facility_cd, op_facility_var, $facility)
	and e.disch_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime) 
	and e.encntr_id in (
		;004
		select ce.encntr_id
		from
			CLINICAL_EVENT ce
		where
			ce.event_cd = cdi_var
			and ce.event_class_cd = mdoc_var
			and ce.valid_until_dt_tm >= sysdate
	)
	and e.active_ind = 1
 
order by
	e.encntr_id
 
 
; populate record structure
head report
	cnt = 0
 
detail
	cnt = cnt + 1
 
	call alterlist(cdi->list, cnt)
 
	cdi->cnt						= cnt
	cdi->list[cnt].encntr_id		= e.encntr_id
	cdi->list[cnt].person_id		= e.person_id
	cdi->list[cnt].patient_name		= p.name_full_formatted
	cdi->list[cnt].fin				= ea.alias
	cdi->list[cnt].facility			= uar_get_code_description(e.loc_facility_cd)
	cdi->list[cnt].nurseunit		= uar_get_code_display(e.loc_nurse_unit_cd)
	cdi->list[cnt].disch_dt_tm		= e.disch_dt_tm
 
with nocounter
 
 
/**************************************************************/
; select note data
select distinct into "NL:"
from
	CLINICAL_EVENT ce
 
	, (inner join CE_EVENT_PRSNL cep on cep.event_id = ce.event_id
		and cep.action_type_cd = sign_action_var
		and cep.valid_until_dt_tm >= sysdate)
 
	, (inner join PRSNL per on per.person_id = ce.performed_prsnl_id)
	
	;005
	, (left join CODE_VALUE_OUTBOUND cvo on cvo.code_value = ce.result_status_cd
		and cvo.code_set = 8
		and cvo.contributor_source_cd = covenant_var)

	;005
	, (left join CODE_VALUE cv on cv.code_set = cvo.code_set
		and cv.code_value = cvo.code_value
		and cv.end_effective_dt_tm > sysdate
		and cv.active_ind = 1)
 
where
	expand(num, 1, cdi->cnt, ce.encntr_id, cdi->list[num].encntr_id)
	and ce.event_cd = cdi_var
	and ce.event_class_cd = mdoc_var
	and ce.event_reltn_cd = root_var
	and ce.valid_until_dt_tm >= sysdate
 
order by
	ce.encntr_id
	, ce.event_end_dt_tm
	, ce.event_id
 
 
; populate record structure
head ce.encntr_id
	cnt = 0
	idx = 0
 
	idx = locateval(num, 1, cdi->cnt, ce.encntr_id, cdi->list[num].encntr_id)
 
detail
	cnt = cnt + 1
 
	call alterlist(cdi->list[idx].nrlist, cnt)
 
	cdi->list[idx].nrcnt							= cnt
	cdi->list[idx].nrlist[cnt].parent_event_id		= ce.parent_event_id
	cdi->list[idx].nrlist[cnt].event_id				= ce.event_id
	cdi->list[idx].nrlist[cnt].event_title			= ce.event_title_text
	cdi->list[idx].nrlist[cnt].event_cd				= ce.event_cd
	cdi->list[idx].nrlist[cnt].event_type			= uar_get_code_display(ce.event_cd)
	cdi->list[idx].nrlist[cnt].action_type			= uar_get_code_display(cep.action_type_cd)
	cdi->list[idx].nrlist[cnt].action_by			= per.name_full_formatted
	cdi->list[idx].nrlist[cnt].action_date			= ce.event_end_dt_tm
 
	cdi->list[idx].nrlist[cnt].action_desc			= if (ce.event_end_dt_tm >= cdi->list[idx].disch_dt_tm)
														d_desc_var
													  else
													  	c_desc_var
													  endif
													  
	cdi->list[idx].nrlist[cnt].result_status		= evaluate(cvo.alias, "F", "FINAL", "PRELIMINARY") ;005
 
with nocounter, expand = 1
 
 
/**************************************************************/
; select note action data ;008
select distinct into "NL:"
from
	CLINICAL_EVENT ce
 
	, (inner join CE_EVENT_PRSNL cep on cep.event_id = ce.event_id
		and cep.action_type_cd = sign_action_var
		and cep.action_prsnl_id > 0.0
		and cep.request_prsnl_id > 0.0
		and cep.action_prsnl_id != cep.request_prsnl_id
		and cep.valid_until_dt_tm >= sysdate)
 
	, (inner join PRSNL pera on pera.person_id = cep.action_prsnl_id)
 
	, (inner join PRSNL perr on perr.person_id = cep.request_prsnl_id)
	 
where
	expand(num, 1, cdi->cnt, ce.encntr_id, cdi->list[num].encntr_id)
	and ce.event_cd = cdi_var
	and ce.event_class_cd = mdoc_var
	and ce.event_reltn_cd = root_var
	and ce.valid_until_dt_tm >= sysdate
 
order by
	ce.encntr_id
 
 
; populate record structure
head ce.encntr_id
	cnt = 0
	idx = 0
 
	idx = locateval(num, 1, cdi->cnt, ce.encntr_id, cdi->list[num].encntr_id)
	 
	cnt = cdi->list[idx].nrcnt
	
detail
	for (i = 1 to cnt)
		if (ce.event_id = cdi->list[idx].nrlist[i].event_id
			and ce.parent_event_id = cdi->list[idx].nrlist[i].parent_event_id
			and cep.action_prsnl_id > 0.0)
		
			cdi->list[idx].nrlist[i].forward_ind = "Y"
			cdi->list[idx].nrlist[i].forward_to = pera.name_full_formatted
		endif
	endfor
 
with nocounter, expand = 1
 
 
/**************************************************************/
; select reminder data
select distinct into "NL:"
from
	CLINICAL_EVENT ce
 
	, (inner join CE_EVENT_PRSNL cep on cep.event_id = ce.event_id
		and cep.action_type_cd = perform_action_var
		and cep.valid_until_dt_tm >= sysdate)
 
	, (inner join PRSNL per on per.person_id = ce.performed_prsnl_id)
	
	;007
	, (inner join CLINICAL_EVENT ce2 on ce2.parent_event_id = ce.event_id
		and ce2.event_cd = reminder_var
		and ce2.event_class_cd = doc_var
		and ce2.event_reltn_cd = child_var
		and ce2.valid_until_dt_tm >= sysdate)
	
	;007
	, (inner join CLINICAL_EVENT ce3 on ce3.parent_event_id = ce2.event_id
		and ce3.event_cd = reminder_var
		and ce3.event_class_cd = attachment_var
		and ce3.event_reltn_cd = child_var
		and cnvtupper(ce3.event_title_text) in ("*CDI*")
		and ce3.valid_until_dt_tm >= sysdate)
 
where
	expand(num, 1, cdi->cnt, ce.encntr_id, cdi->list[num].encntr_id)
	and ce.event_cd = reminder_var
	and ce.event_class_cd = mdoc_var
	and ce.event_reltn_cd = root_var
	and cnvtupper(ce.event_title_text) in ("*REMINDER*", "*CDI*") ;003
	and ce.valid_until_dt_tm >= sysdate
 
order by
	ce.encntr_id
	, ce.event_end_dt_tm
	, ce.event_id
 
 
; populate record structure
head ce.encntr_id
	cnt = 0
	idx = 0
 
	idx = locateval(num, 1, cdi->cnt, ce.encntr_id, cdi->list[num].encntr_id)
	 
	cnt = cdi->list[idx].nrcnt
 
detail
	if (cnt > 0) ;003
		if (ce.event_end_dt_tm > cdi->list[idx].nrlist[1].action_date) ;003
						
			cnt = cnt + 1
		 
			call alterlist(cdi->list[idx].nrlist, cnt)
		 
			cdi->list[idx].nrcnt							= cnt
			cdi->list[idx].nrlist[cnt].parent_event_id		= ce.parent_event_id
			cdi->list[idx].nrlist[cnt].event_id				= ce.event_id
			cdi->list[idx].nrlist[cnt].event_title			= ce.event_title_text
			cdi->list[idx].nrlist[cnt].event_cd				= ce.event_cd
			cdi->list[idx].nrlist[cnt].event_type			= uar_get_code_display(ce.event_cd)
			cdi->list[idx].nrlist[cnt].action_type			= uar_get_code_display(cep.action_type_cd)
			cdi->list[idx].nrlist[cnt].action_by			= per.name_full_formatted
			cdi->list[idx].nrlist[cnt].action_date			= ce.event_end_dt_tm
		 
			cdi->list[idx].nrlist[cnt].action_desc			= if (ce.event_end_dt_tm >= cdi->list[idx].disch_dt_tm)
																d_desc_var
															  else
															  	c_desc_var
															  endif 
		endif
	endif
	
with nocounter, expand = 1
 
 
/**************************************************************/
; select addendum data
select into "nl:" 
from
	 CLINICAL_EVENT ce
 
	, (inner join CE_EVENT_PRSNL cep on cep.event_id = ce.event_id
		and cep.action_type_cd = perform_action_var
		and cep.valid_until_dt_tm >= sysdate)
 
	, (inner join PRSNL per on per.person_id = ce.performed_prsnl_id)
 
	, (inner join PERSON_NAME pn on pn.person_id = per.person_id)
 
	, (left join CE_BLOB cb on cb.event_id = ce.event_id
		and cb.valid_until_dt_tm >= sysdate)
 
where
	expand(num, 1, cdi->cnt, ce.encntr_id, cdi->list[num].encntr_id)
	and ce.event_cd in (cdi_var, reminder_var)
	and ce.event_class_cd = doc_var
	and ce.event_reltn_cd = child_var
	and ce.valid_until_dt_tm >= sysdate
 
order by
	ce.encntr_id
	, ce.event_end_dt_tm
	, ce.parent_event_id
	, ce.event_id
 
 
; populate record structure
head ce.encntr_id
	idx = 0
 
	idx = locateval(num, 1, cdi->cnt, ce.encntr_id, cdi->list[num].encntr_id)
 
head ce.event_id
	if (idx > 0)
		blobin = fillstring(32768, " ")
		blobsize = 0
		blobout = fillstring(32768, " ")
		bsize = 0
		blobnortf = fillstring(32768, " ")
		rval = 0
		ipos = 0
 
		idx2 = 0
 
		idx2 = locateval(num, 1, cdi->list[idx].nrcnt, ce.parent_event_id, cdi->list[idx].nrlist[num].event_id)
 
		if (idx2 > 0)
			cdi->list[idx].nrlist[idx2].eid			 			= ce.event_id
			cdi->list[idx].nrlist[idx2].blob_seq_num 			= cb.blob_seq_num
			cdi->list[idx].nrlist[idx2].blob_length  			= cb.blob_length
			cdi->list[idx].nrlist[idx2].valid_from_dt_tm		= cb.valid_from_dt_tm
			cdi->list[idx].nrlist[idx2].valid_until_dt_tm		= cb.valid_until_dt_tm
			cdi->list[idx].nrlist[idx2].updt_dt_tm				= cb.updt_dt_tm
 
			cdi->list[idx].nrlist[idx2].addendum_by				= per.name_full_formatted
			cdi->list[idx].nrlist[idx2].addendum_date			= ce.event_end_dt_tm
 
			cdi->list[idx].nrlist[idx2].addendum_desc			= if (ce.event_end_dt_tm >= cdi->list[idx].disch_dt_tm)
																	d_desc_var
																  else
																  	c_desc_var
																  endif
 
			blobin = cb.blob_contents
			blobsize = size(cb.blob_contents)
 
			if (cb.compression_cd = compcd)
				rval = uar_ocf_uncompress(blobin, blobsize, blobout, size(blobout), 0)
				rval = uar_rtf2(blobout, size(blobout), blobnortf, size(blobnortf), bsize,0)
 
				cdi->list[idx].nrlist[idx2].addendum = replace(blobnortf, crlf, " ")
			else
		 		blobout = blobin
				rval = uar_rtf(blobout, size(blobout), blobnortf, size(blobnortf), bsize, 0)
 
				cdi->list[idx].nrlist[idx2].addendum = replace(trim(blobnortf), crlf, " ")
			endif
 
		    blobin 		= fillstring(32768, " ")
			blobsize	= 0
			blobout		= fillstring(32768, " ")
			blobnortf	= fillstring(32768, " ")
			bsize		= 0
		endif
	endif
 
with nocounter, expand = 1
 
 
/**************************************************************/
; select diagnosis data
select into "NL:"
from
	DIAGNOSIS d
 
where
	expand(num, 1, cdi->cnt, d.encntr_id, cdi->list[num].encntr_id)
	and d.diag_type_cd = discharge_var
	and d.active_ind = 1
 
order by
	d.encntr_id
	, d.clinical_diag_priority
 
 
; populate record structure
head d.encntr_id
	cnt = 0
	idx = 1
	dx_out = fillstring(400, " ")
 
detail
	dx_out = build2(trim(dx_out), trim(d.diagnosis_display, 3), ";")
 
foot d.encntr_id
	while (idx > 0)
		idx = locateval(cnt, idx, cdi->cnt, d.encntr_id, cdi->list[cnt].encntr_id)
 
		if (idx > 0)
			cdi->list[idx].dx = replace(replace(dx_out, ";", "", 2), ";", "; ")
 
			idx += 1
		endif
	endwhile
 
with nocounter, expand = 1
 
 
/**************************************************************/
; select final data
select distinct into $outdev
	facility			= trim(cdi->list[d1.seq].facility, 3)
	, nurseunit			= trim(cdi->list[d1.seq].nurseunit, 3)
	, fin				= trim(cdi->list[d1.seq].fin, 3)
	, patient_name		= trim(cdi->list[d1.seq].patient_name, 3)
	, disch_dt_tm		= cdi->list[d1.seq].disch_dt_tm "mm/dd/yyyy hh:mm;;d"
 
 	, event_type		= trim(cdi->list[d1.seq].nrlist[d2.seq].event_type, 3)
 	, event_title		= trim(cdi->list[d1.seq].nrlist[d2.seq].event_title, 3) 	
 	
	, action_type		= trim(cdi->list[d1.seq].nrlist[d2.seq].action_type, 3)
	, action_by			= trim(cdi->list[d1.seq].nrlist[d2.seq].action_by, 3)
	, action_date		= cdi->list[d1.seq].nrlist[d2.seq].action_date "mm/dd/yyyy hh:mm:ss;;d"
 	, action_desc		= trim(cdi->list[d1.seq].nrlist[d2.seq].action_desc, 3)
 	
 	, status			= trim(cdi->list[d1.seq].nrlist[d2.seq].result_status, 3) ;005
 	, forward_ind		= trim(cdi->list[d1.seq].nrlist[d2.seq].forward_ind, 3) ;008
 	, forward_to		= trim(cdi->list[d1.seq].nrlist[d2.seq].forward_to, 3) ;008
 
 	;006
 	, addendum			= if (cdi->list[d1.seq].nrlist[d2.seq].event_cd = reminder_var)
 							trim(cdi->list[d1.seq].nrlist[d2.seq].addendum, 3)
 						  else
 							""
 						  endif 						  	
 		 	
 	, addendum_by		= trim(cdi->list[d1.seq].nrlist[d2.seq].addendum_by, 3)
 	, addendum_date		= cdi->list[d1.seq].nrlist[d2.seq].addendum_date "mm/dd/yyyy hh:mm:ss;;d"
 	, addendum_desc		= trim(cdi->list[d1.seq].nrlist[d2.seq].addendum_desc, 3)
 
 	, dx				= trim(cdi->list[d1.seq].dx, 3)
 	, start_date		= cdi->startdate
	, end_date			= cdi->enddate
 
from
	(dummyt d1 with seq = value(cdi->cnt))
	, (dummyt d2 with seq = 1)
 
plan d1 where maxrec(d2, cdi->list[d1.seq].nrcnt)
join d2
 
order by
	facility
	, nurseunit
	, fin
	, cdi->list[d1.seq].nrlist[d2.seq].action_date
	, cdi->list[d1.seq].nrlist[d2.seq].parent_event_id
	, cdi->list[d1.seq].nrlist[d2.seq].event_id

 
with nocounter, format, check, separator = " "
 
 
#exit_script
 
call echorecord(cdi)
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 
