 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:			Geetha Saravanan
	Date Written:		Dec'2017
	Solution:			Infection Control
	Source file name:	      cov_ic_LinesTubesDrains.prg
	Object name:		cov_ic_LinesTubesDrains
	Request#:			593
 
	Program purpose:	      To identify if there's any missed documentation on Lines, Tubes and Drains.
 
	Executing from:		CCL
 
 	Special Notes:
 
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_ic_LinesTubesDrains:DBA go
create program cov_ic_LinesTubesDrains:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date/Time" = ""
	, "End Date/Time" = ""
	, "Facility" = ""
 
with OUTDEV, start_datetime, end_datetime, facility_list
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare mrn_var              = f8 with constant(uar_get_code_by("DISPLAY", 319, "MRN")),protect
declare fin_var              = f8 with constant(uar_get_code_by("DISPLAY", 319, "FIN NBR")),protect
declare idx2                 = f8
 
declare arteri_iv_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Arteriovenous Access Activity:")),protect
declare arteri_type_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Arteriovenous Access Type:")),protect
declare arteri_type_var1     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Arteriovenous Access Type")),protect
	;Only need - Double Lumen Catheter, Tunneled/Permanent
declare arteri_site_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Arteriovenous Access Site:")),protect
 
declare central_line_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Central Line Activity.")),protect
declare central_type_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Central Line Access Type:")),protect
declare central_type_var1    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Central Line Access Type")),protect
declare central_lumen_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Central Line Number of Lumens:")),protect
declare central_lumen_var1   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Central Line Number of Lumens.")),protect
declare central_insert_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Central Line Insertion Site:")),protect
declare central_later_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Central IV Laterality:")),protect
declare central_later_var1   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Central IV Laterality")),protect
 
declare urin_cath_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Urinary Catheter Activity:")),protect
declare urin_insert_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Urinary Catheter Insertion Site")),protect
declare urin_insert_var1     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Urinary Catheter Insertion Site:")),protect
	; only need Urethral
declare urin_type_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Urinary Catheter Type")),protect
declare urin_type_var1       = f8 with constant(uar_get_code_by("DISPLAY", 72, "Urinary Catheter Type:")),protect
	; only need - see Tambra's email
	; do not need - Straight/Intermittent, temperature Probe
declare urin_size_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Urinary Catheter Size:")),protect
declare urin_size_var1       = f8 with constant(uar_get_code_by("DISPLAY", 72, "Urinary Catheter Size")),protect
 
;Indications
declare urin_cath_ind_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Urinary Catheter Indications:")),protect
declare urin_cath_ind_var1   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Urinary Catheter Indications")),protect
declare cent_line_ind_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Central Line Indication.")),protect
declare cent_line_ind_var1   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Central Line Indication:")),protect
 
declare initcap() = C100
 
 
;Create Record Structure to store dta-docs
;FREE RECORD docs
RECORD docs(
	1 flist[*]
		2 facility_code    = f8
		2 facility_name    = vc
		2 plist[*]
	 		3 pat_id           = vc
	 		3 pat_name         = vc
		 	3 dept_name        = vc
		 	3 room_bed         = vc
		 	3 events[*]
		 		4 event_start_dt   = dq8
		 		4 event_label_id   = f8
		 		4 event_label      = vc
		 		4 line_tube_drain  = vc
		 		4 dta_docs         = vc
		 		4 staff            = vc
		 		4 med_necessity    = vc
		 		4 event_code       = f8
		 		4 perform_dt       = dq8
		)
 
/*
;Record str. for Indication/Med necessity
RECORD med(
	1 mlist[*]
		2 facility_code    = f8
 		2 pat_id           = vc
 	 	2 event_label_id   = f8
 	 	2 event_code       = f8
 	 	2 med_necessity    = vc
 		2 event_start_dt   = dq8
	)
 
*/
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
 
;Get Lines, Tubes and drains DTA-documentation
select distinct into "NL:" ;$outdev
 
   e.loc_facility_cd
 , ea.alias
 , ce.ce_dynamic_label_id
 , cl.label_name
 , ce.event_cd
 , ce.result_val
 , ce.event_start_dt_tm
 , e.loc_nurse_unit_cd
 , e.loc_room_cd
 , e.loc_bed_cd
 , staf = initcap(pr.name_full_formatted)
 , p_name = initcap(pe.name_full_formatted)
 
 
from encounter e, encntr_alias ea, person pe, clinical_event ce, ce_dynamic_label cl, prsnl pr
 
plan e where e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.loc_facility_cd = $facility_list
	and e.active_ind = 1
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = fin_var
	and ea.active_ind = 1
	;and ea.alias = "1727200017"
 
join pe where pe.person_id = e.person_id
	and pe.active_ind = 1
 
join ce where ce.encntr_id = e.encntr_id
	and ce.event_cd in (
		arteri_iv_var, arteri_type_var, arteri_type_var1, arteri_site_var, central_line_var, central_type_var,
		central_type_var1, central_lumen_var, central_lumen_var1, central_insert_var, central_later_var, central_later_var1,
		urin_cath_var, urin_insert_var, urin_insert_var1, urin_type_var, urin_type_var1, urin_size_var, urin_size_var1
		,urin_cath_ind_var, urin_cath_ind_var1, cent_line_ind_var, cent_line_ind_var1
		)
 	and ce.result_val not in( "AV Fistula", "AV Shunt, external", "AV graft", "Suprapubic", "Other", "Straight/Intermittent",
		"temperature Probe" )
 
join cl where cl.ce_dynamic_label_id = ce.ce_dynamic_label_id
 
join pr where pr.person_id = outerjoin(ce.performed_prsnl_id)
 
order by e.loc_facility_cd, ea.alias, ce.ce_dynamic_label_id, ce.event_start_dt_tm, ce.event_cd
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
 
;Populate dta docs in the Record Structure
head report
 
 	fcnt = 0
	call alterlist(docs->flist, 10)
 
head e.loc_facility_cd ;facility
 	fcnt = fcnt + 1
	if(mod(fcnt, 10) = 1 and fcnt > 100)
		call alterlist(docs->flist, fcnt+9)
	endif
 
	docs->flist[fcnt].facility_code = e.loc_facility_cd
	docs->flist[fcnt].facility_name = uar_get_code_description(e.loc_facility_cd)
 
	pcnt = 0
 
head ea.alias ; patients
	pcnt = pcnt + 1
	call alterlist(docs->flist[fcnt].plist, pcnt)
 
	docs->flist[fcnt].plist[pcnt].pat_id    = trim(ea.alias)
	docs->flist[fcnt].plist[pcnt].pat_name  = trim(p_name);trim(pe.name_full_formatted)
	docs->flist[fcnt].plist[pcnt].dept_name = trim(uar_get_code_display(e.loc_nurse_unit_cd))
	docs->flist[fcnt].plist[pcnt].room_bed  = concat(trim(uar_get_code_display(e.loc_room_cd)),' - ',
								trim(uar_get_code_display(e.loc_bed_cd)))
	ecnt = 0
 
detail ;events
	ecnt = ecnt + 1
	call alterlist(docs->flist[fcnt].plist[pcnt].events, ecnt)
 
 	docs->flist[fcnt].plist[pcnt].events[ecnt].event_start_dt     = ce.event_start_dt_tm
 	docs->flist[fcnt].plist[pcnt].events[ecnt].event_label_id     = ce.ce_dynamic_label_id
 	docs->flist[fcnt].plist[pcnt].events[ecnt].event_label        = trim(cl.label_name)
 	docs->flist[fcnt].plist[pcnt].events[ecnt].line_tube_drain    = trim(uar_get_code_display(ce.event_cd))
 	docs->flist[fcnt].plist[pcnt].events[ecnt].dta_docs           = trim(ce.result_val)
 	docs->flist[fcnt].plist[pcnt].events[ecnt].staff              = trim(staf) ;trim(pr.name_full_formatted);trim(pr.name_last)
 	docs->flist[fcnt].plist[pcnt].events[ecnt].med_necessity      = " "
 	docs->flist[fcnt].plist[pcnt].events[ecnt].event_code         = ce.event_cd
	docs->flist[fcnt].plist[pcnt].events[ecnt].perform_dt         = ce.performed_dt_tm
 
foot ea.alias
 	call alterlist(docs->flist[fcnt].plist[pcnt].events, ecnt)
 
foot report
 	call alterlist(docs->flist, fcnt)
 
with nocounter
 
;call echojson(docs,"rec.out", 0)
;call echorecord(docs)
 
 
end
go
 
 
 
/*
;Get Indications/Medical necessity and store them in the record str.
select distinct into "NL:" ;$outdev
 
   e.loc_facility_cd
 , ea.alias
 , ce.ce_dynamic_label_id
 , ce.event_cd
 , ce.result_val
 , ce.event_start_dt_tm
 
 
from encounter e, encntr_alias ea, person pe, clinical_event ce, ce_dynamic_label cl, prsnl pr
 
plan e where e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.loc_facility_cd = $facility_list
	and e.active_ind = 1
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = fin_var
	and ea.active_ind = 1
	;and ea.alias = "1727200017"
 
join pe where pe.person_id = e.person_id
	and pe.active_ind = 1
 
join ce where ce.encntr_id = e.encntr_id
	and ce.event_cd in (urin_cath_ind_var, urin_cath_ind_var1, cent_line_ind_var, cent_line_ind_var1)
 
join cl where cl.ce_dynamic_label_id = ce.ce_dynamic_label_id
 
join pr where pr.person_id = outerjoin(ce.performed_prsnl_id)
 
order by e.loc_facility_cd, ea.alias, ce.ce_dynamic_label_id, ce.event_start_dt_tm, ce.event_cd
 
 
Head Report
mcnt = 0
 
detail
	mcnt = mcnt + 1
	call alterlist(med->mlist, mcnt)
 
	med->mlist[mcnt].facility_code      = e.loc_facility_cd
	med->mlist[mcnt].pat_id             = ea.alias
	med->mlist[mcnt].event_label_id     = ce.ce_dynamic_label_id
 	med->mlist[mcnt].event_code         = ce.event_cd
 	med->mlist[mcnt].med_necessity      = ce.result_val
 	med->mlist[mcnt].event_start_dt     = ce.event_start_dt_tm
 
foot report
 	call alterlist(med->mlist, mcnt)
 
with nocounter
 
;call echojson(docs,"rec.out", 0)
;call echorecord(med)
 
*/
 
 
 
 
 
/* old prg start
 
;Get selected facilities and store them in the record structure
 
select into "NL:"
      cv1.description, cv1.code_value
from code_value cv1
where cv1.code_set =  220
	and cv1.code_value = $facility_list
  	and cv1.active_ind = 1
	and cv1.cdf_meaning = "FACILITY"
 
group by cv1.description, cv1.code_value
order by cv1.description
 
 
head report
 
 	cnt = 0
	call alterlist(docs->flist, 10)
 
head cv1.description
 	cnt = cnt + 1
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(docs->flist, cnt+9)
	endif
 
	docs->flist[cnt].facility_code = cv1.code_value
	docs->flist[cnt].facility_name = trim(cv1.description)
 
foot report
 	call alterlist(docs->flist, cnt)
 
with nocounter
 
 
;Get Patient Demographic
select distinct into "NL:" ;$outdev
 
   e.loc_facility_cd
 , ea.alias
 ;, e.loc_nurse_unit_cd
 ;, e.loc_room_cd
 ;, e.loc_bed_cd
 ;, pe.name_full_formatted
 
 
from encounter e, encntr_alias ea, person pe, clinical_event ce, ce_dynamic_label cl
 
plan e where e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.loc_facility_cd = $facility_list
	and e.active_ind = 1
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = fin_var
	and ea.active_ind = 1
	;and ea.alias = "1727200017"
 
join pe where pe.person_id = e.person_id
	and pe.active_ind = 1
 
join ce where ce.encntr_id = e.encntr_id
	and ce.event_cd in (
		arteri_iv_var, arteri_type_var, arteri_type_var1, arteri_site_var, central_line_var, central_type_var,
		central_type_var1, central_lumen_var, central_lumen_var1, central_insert_var, central_later_var, central_later_var1,
		urin_cath_var, urin_insert_var, urin_insert_var1, urin_type_var, urin_type_var1, urin_size_var, urin_size_var1
		,urin_cath_ind_var, urin_cath_ind_var1, cent_line_ind_var, cent_line_ind_var1
		)
 	and ce.result_val not in( "AV Fistula", "AV Shunt, external", "AV graft", "Suprapubic", "Other", "Straight/Intermittent",
		"temperature Probe" )
 
join cl where cl.ce_dynamic_label_id = ce.ce_dynamic_label_id
 
order by e.loc_facility_cd, ea.alias
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
 
;Populate Patient Demographic in the record structure
head e.loc_facility_cd
	numx = 0
	idx = 0
	pcnt = 0
 
	idx = locateval(numx, 1, size(docs->flist, 5), e.loc_facility_cd, docs->flist[numx].facility_code)
	if(idx > 0)
		call alterlist(docs->flist[idx].plist, 10)
	endif
 
detail
	if (idx > 0)
		pcnt = pcnt + 1
		if (mod(pcnt, 10) = 1 and pcnt > 10)
			call alterlist(docs->flist[idx].plist, pcnt+9)
		endif
		docs->flist[idx].plist[pcnt].pat_id    = trim(ea.alias)
		docs->flist[idx].plist[pcnt].pat_name  = trim(pe.name_full_formatted)
		docs->flist[idx].plist[pcnt].dept_name = trim(uar_get_code_display(e.loc_nurse_unit_cd))
		docs->flist[idx].plist[pcnt].room_bed  = concat(trim(uar_get_code_display(e.loc_room_cd)),' - ', trim(
									uar_get_code_display(e.loc_bed_cd)))
	endif
 
foot e.loc_facility_cd
 	call alterlist(docs->flist[idx].plist, pcnt)
 
with nocounter
 
;call echojson(docs,"rec.out", 0)
;call echorecord(docs)
 
 
 
;Get Lines, Tubes and drains DTA-documentation
select distinct into "NL:" ;$outdev
 
   e.loc_facility_cd
 , ea.alias
 , ce.ce_dynamic_label_id
 , cl.label_name
 , ce.event_cd
 , ce.result_val
 , ce.event_start_dt_tm
 , e.loc_nurse_unit_cd
 , e.loc_room_cd
 , e.loc_bed_cd
 , pe.name_full_formatted
 , pr.name_last
 
 
from encounter e, encntr_alias ea, person pe, clinical_event ce, ce_dynamic_label cl, prsnl pr
 
plan e where e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.loc_facility_cd = $facility_list
	and e.active_ind = 1
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = fin_var
	and ea.active_ind = 1
	;and ea.alias = "1727200017"
 
join pe where pe.person_id = e.person_id
	and pe.active_ind = 1
 
join ce where ce.encntr_id = e.encntr_id
	and ce.event_cd in (
		arteri_iv_var, arteri_type_var, arteri_type_var1, arteri_site_var, central_line_var, central_type_var,
		central_type_var1, central_lumen_var, central_lumen_var1, central_insert_var, central_later_var, central_later_var1,
		urin_cath_var, urin_insert_var, urin_insert_var1, urin_type_var, urin_type_var1, urin_size_var, urin_size_var1
		,urin_cath_ind_var, urin_cath_ind_var1, cent_line_ind_var, cent_line_ind_var1
		)
 	and ce.result_val not in( "AV Fistula", "AV Shunt, external", "AV graft", "Suprapubic", "Other", "Straight/Intermittent",
		"temperature Probe" )
 
join cl where cl.ce_dynamic_label_id = ce.ce_dynamic_label_id
 
join pr where pr.person_id = outerjoin(ce.performed_prsnl_id)
 
order by e.loc_facility_cd, ea.alias, ce.ce_dynamic_label_id, ce.event_start_dt_tm, ce.event_cd
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
 
;populate dta-docs in record structure
head  ea.alias
 
	numx1 = 0
	idx1 = 0
	ecnt = 0
 
	idx1 = locateval(numx1, 1, size(docs->flist->plist, 5), ea.alias, docs->flist->plist[numx1].pat_id)
	if(idx1 > 0)
		call alterlist(docs->flist->plist[idx1].events, 10)
	endif
 
detail
	if (idx1 > 0)
		ecnt = ecnt + 1
		if (mod(ecnt, 10) = 1 and ecnt > 10)
			call alterlist(docs->flist->plist[idx1].events, ecnt+9)
		endif
 
		call echo(build('test = ', ce.ce_dynamic_label_id))
 
 		docs->flist->plist[idx1].events[ecnt].event_start_dt     = ce.event_start_dt_tm
 		docs->flist->plist[idx1].events[ecnt].event_labelid      = ce.ce_dynamic_label_id
 		docs->flist->plist[idx1].events[ecnt].event_label        = trim(cl.label_name)
 		docs->flist->plist[idx1].events[ecnt].line_tube_drain    = trim(uar_get_code_display(ce.event_cd))
 		docs->flist->plist[idx1].events[ecnt].dta_docs           = trim(ce.result_val)
 		docs->flist->plist[idx1].events[ecnt].staff              = trim(pr.name_last)
 		docs->flist->plist[idx1].events[ecnt].med_necessity      = " "
 		docs->flist->plist[idx1].events[ecnt].event_code         = ce.event_cd
		docs->flist->plist[idx1].events[ecnt].perform_dt         = ce.performed_dt_tm
 
	endif
 
foot ea.alias
 	call alterlist(docs->flist->plist[idx1].events, ecnt)
 
with nocounter
 
call echojson(docs,"rec.out", 0)
call echorecord(docs)
;old prg end
*/
 
 
/*
;Get Lines, Tubes and drains Med necessity
 
select into "NL:" ;$outdev
 
   e.loc_facility_cd
 , ea.alias
 , ce.ce_dynamic_label_id
 , ce.event_cd
 , ce.result_val
 , ce.event_start_dt_tm
 
 
from encounter e, encntr_alias ea, clinical_event ce
 
plan e where e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.loc_facility_cd = $facility_list
	and e.active_ind = 1
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = fin_var
	and ea.active_ind = 1
	;and ea.alias = "1727200017"
 
join ce where ce.encntr_id = e.encntr_id
	and ce.event_cd in (urin_cath_ind_var, urin_cath_ind_var1, cent_line_ind_var, cent_line_ind_var1)
 
 
order by e.loc_facility_cd, ea.alias, ce.event_start_dt_tm, ce.ce_dynamic_label_id, ce.event_cd
 
 
;populate Med dta-docs in record structure
 
head report
 
 	mcnt = 0
	call alterlist(med_docs->plist, 10)
 
head e.loc_facility_cd
 	mcnt = mcnt + 1
	if(mod(mcnt, 10) = 1 and mcnt > 100)
		call alterlist(med_docs->plist, mcnt+9)
	endif
 
	med_docs->plist[mcnt].facility_code      = e.loc_facility_cd
	med_docs->plist[mcnt].pat_id             = ea.alias
	med_docs->plist[mcnt].event_label_id     = ce.ce_dynamic_label_id
 	med_docs->plist[mcnt].event_code         = ce.event_cd
 	med_docs->plist[mcnt].med_necessity      = ce.result_val
	med_docs->plist[mcnt].event_start_dt     = ce.event_start_dt_tm
 
foot report
 	call alterlist(med_docs->plist, mcnt)
 
with nocounter
 
 
call echojson(docs,"rec.out", 0)
call echorecord(docs)
 
*/
 
 
 
 
;-------------------------------------------------------------------------------------
 
 
 
/*
 
 
CODE_VALUE	DISPLAY
 
;Indications - Medical Necessity
24604402.00	Urinary Catheter Indications:
16730125.00	Urinary Catheter Indications
34439991.00	Central Line Indication.
17022202.00	Central Line Indication:
 
;Lines, Tubes and Drains events used
24602050.00	Arteriovenous Access Activity:
24601956.00	Arteriovenous Access Type:
2819493.00	Arteriovenous Access Type
	;Only need - Double Lumen Catheter, Tunneled/Permanent
24601964.00	Arteriovenous Access Site:
 
34439957	Central Line Activity.
17022232.00	Central Line Access Type:
34439585.00	Central Line Access Type
17022234.00	Central Line Number of Lumens:
34439815.00	Central Line Number of Lumens.
34439845.00	Central Line Insertion Site:
17022238.00	Central IV Laterality:
3316641.00	Central IV Laterality
 
24604416	Urinary Catheter Activity:
712522.00	Urinary Catheter Insertion Site
24603876.00	Urinary Catheter Insertion Site:
	; only need Urethral
 
712510.00	Urinary Catheter Type
24604388.00	Urinary Catheter Type:
	; only need - see Tabra's email
	; do not need - Straight/Intermittent, temperature Probe
 
24596820.00	Urinary Catheter Size:
712513.00	Urinary Catheter Size
 
 
 
 
;To display only indications
events_event_code  = 24604402.00
or
 events_event_code  = 16730125.00
or
events_event_code  = 34439991.00
or
events_event_code  = 17022202.00
 
 
;To display except indications
events_event_code  != 24604402.00
and
 events_event_code  != 16730125.00
and
events_event_code  != 34439991.00
and
events_event_code  != 17022202.00
 
 
*/
