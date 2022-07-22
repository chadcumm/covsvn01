/*****************************************************
Author		 :  Michael Layman
Date Written :  4/24/18
Program Title:  Audit Summary Token
Source File	 :  cov_fn_audit_summ_tkn.prg
Object Name	 :	cov_fn_audit_summ_tkn
Directory	 :	cust_script
DVD version  :	2017.11.1.81
HNA version  :	2017
CCL version  :	8.2.3
Purpose      :  This program is a custom token for
				the summary Audit page.
 
Tables Read  :  encouner, person, orders, clinical_event
Tables
Updated      :	NA
Include Files:  NA
Executing
Application  :	FirstNet Depart Process
Special Notes: 	Launched from the Depart Process icon in FirstNet.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Mod #        By           Date           Purpose
*****************************************************/
 
 
 
 
drop program cov_fn_audit_summ_tkn go
create program cov_fn_audit_summ_tkn
 
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
FREE RECORD a
RECORD a
(
1	rec_cnt 	=	i4
1	facility 	=	vc
1	orgid		=	f8
1	facaddr1	=	vc
1	facaddr2	=	vc
1	faccity		=	vc
1	facstate	=	vc
1	faczip		=	vc
1	qual[*]
	2	personid	=	f8
	2	encntrid	=	f8
	2	name		=	vc
	2	mrn			=	vc
	2	fin			=	vc
	2	unit		=	vc
	2	room		=	vc
	2	bed			=	vc
	2	sex			=	vc
	2	age			=	vc
	2	diagnosis	=	vc
	2	dob			=	vc
	2	pcp			=	vc
	2	race		=	vc
	2	ethnicity	=	vc
	2	address1	=	vc
	2	address2	=	vc
	2	city		=	vc
	2	state		=	vc
	2	zip			=	vc
	2	homephone	=	vc
	2	cellphone	=	vc
	2	workphone	=	vc
	2	language	=	vc
	2	healthplan	=	vc
	2	lynxModeArr	=	vc
	2	chiefcomp	=	vc
	2	rfv			=	vc
	2	prearrfrmcnt	=	i2
	2	prearrfrmqual[*]
		3	formid		=	f8
		3	formdt		=	vc
		3	formname	=	vc
		3	frmrescnt	=	i4
		3	frmresqual[*]
			4	eventid	=	f8
			4	eventcd	=	f8
			4	eventnm	=	vc
			4	result	=	vc
			4	verdttm	=	vc
	2	rnassmntcnt		=	i2
	2	rnassmntqual[*]
		3	eventid	=	f8
		3	eventcd	=	f8
		3	eventnm	=	vc
		3	result	=	vc
		3	perfdt	=	vc
	2	medcnt			=	i2
	2	medqual[*]
		3	orderid		=	f8
		3	ordname		=	vc
		3	orddetails	=	vc
		3	route		=	vc
		3	freq		=	vc
		3	freqid		=	f8
		3	admindttm	=	vc
		3	medtype		=	vc
	2	fctordcnt		=	i2
	2	fctordqual[*]
		3	orderid		=	f8
		3	ordname		=	vc
		3	orddetails	=	vc
		3	orddttm		=	vc
	2	probcnt			=	i2
	2	probqual[*]
		3	problem_id	=	f8
		3	problem		=	vc
		3	onsetdttm	=	vc
	2	diagcnt			=	i2
	2	diagqual[*]
		3	diag_id		=	f8
		3	diagnosis	=	vc
		3	diagtype	=	vc
		3	actdttm		=	vc
 	2	dispfrmcnt	=	i2
	2	dispfrmqual[*]
		3	formid		=	f8
		3	formdt		=	vc
		3	formname	=	vc
		3	frmrescnt	=	i4
		3	frmresqual[*]
			4	eventid	=	f8
			4	eventcd	=	f8
			4	eventnm	=	vc
			4	result	=	vc
			4	verdttm	=	vc
)
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
DECLARE encntrid = f8 WITH NOCONSTANT(0.0), PROTECT
DECLARE mrnaliascd = f8 WITH NOCONSTANT(0.0), PROTECT
DECLARE mrnfac = vc WITH NOCONSTANT(FILLSTRING(15,' ')), PROTECT
DECLARE homeaddrcd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',212,'HOME')), PROTECT
DECLARE homephcd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',43,'HOME')), PROTECT
DECLARE busphcd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',43,'BUSINESS')), PROTECT
DECLARE mobphcd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',43,'MOBILE')), PROTECT
DECLARE pcpcd   = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',331,'PRIMARYCAREPHYSICIAN')), PROTECT
DECLARE lnxmodearrcd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'LYNXMODEOFARRIVAL')), PROTECT
DECLARE chiefcompcd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'CHIEFCOMPLAINT')), PROTECT
DECLARE edAdultTriageFrmId = f8 WITH CONSTANT(9643303.00), PROTECT
DECLARE edChildTriageFrmId = f8 WITH CONSTANT(10183303.00), PROTECT
DECLARE priEventId = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 18189,'PRIMARYEVENTID')), PROTECT
DECLARE workviewcd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',29520,'WORKINGVIEW')), PROTECT
DECLARE powerformscd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',29520,'POWERFORMS')), PROTECT
DECLARE dcpgenericcd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'DCPGENERICCODE')), PROTECT
DECLARE pharmcattypecd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6000,'PHARMACY')), PROTECT
DECLARE labcattypecd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6000,'LABORATORY')), PROTECT
DECLARE radcattypecd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6000,'RADIOLOGY')), PROTECT
DECLARE eddispdocfrm = f8 WITH CONSTANT(16226815.00), PROTECT
DECLARE clinevt		= f8 WITH NOCONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',18189,'PRIMARYEVENTID')), PROTECT
;Define HTML tags
DECLARE htmlhdr = vc WITH CONSTANT('<html><body>')
DECLARE endhtml = vc WITH CONSTANT('</body></html>')
DECLARE div = VC with CONSTANT('<div ')
DECLARE tblhdr          = vc   with constant("<table border = 0 cellspacing = 0 cellpadding =0>")
DECLARE tblFtr          = vc   with constant("</table>")
DECLARE htmlTitle       =   vc with constant("<title>Cerner Medications Token Page</title>")
DECLARE htmlTblRowStart =   vc with constant("<tr>")
DECLARE htmlTblHdrStart =   vc with constant(BUILD("<th width=",450," valign=top align=center>"))
DECLARE htmlTblHdrEnd   =   vc with constant("</th>")
DECLARE htmlColWidth    =   vc with noconstant("250"), protect
DECLARE htmlColStart    =   vc with noconstant(CONCAT("<td width=",htmlColWidth," valign=top align=center>"))
DECLARE htmlColRes      =   vc with noconstant(CONCAT("<td width=350"," valign=top align=center>"))
DECLARE htmlColPrint    =   vc with constant("<td width=72 valign=top align=center >"), protect
DECLARE htmlColMedName  =   vc with constant("<td width=130 valign=top align=center >"), protect
DECLARE htmlColMedDet   =   vc with constant("<td width=250 valign=top align=center >"), protect
DECLARE htmlbgColYel    =   vc with constant(" bgcolor='#CCCCCC' >"), protect
DECLARE htmlbgColGrey   =   vc with constant(" bgcolor='#FFFF00' >"), protect
DECLARE htmlTblRowEnd   =   vc with constant("</tr>")
DECLARE htmlColEnd      =   vc with constant("</td>")
DECLARE htmlFtr         =   vc with constant("</table></body></html>")
DECLARE htmlText        =   vc with noconstant(fillstring(32000,' '))
DECLARE CrLf            =   vc with constant(CONCAT(CHAR(10),CHAR(13)))
DECLARE vHtmlColor      =   vc with noconstant(fillstring(255," ")), protect
DECLARE htmlFooter      =   vc with constant(CONCAT("</table><table><tr><td width=452>",
                            "<p><b> <span style='font-family:Arial;font-size:8.0pt;'>"))
;                            "* indicates this medication has printed in the last 36 hours.</span></b></p></td></tr></table>"))
 
DECLARE styleFac        =   vc with constant(CONCAT(
                            "<span style='font-family:Arial;font-size:16.0pt;font-weight: bold;'>"))
DECLARE styleHdr        =   vc with constant(CONCAT(
                            "<span style='font-family:Arial;font-size:12.0pt;font-weight: bold;'>"))
DECLARE styleBody       =   vc with constant("<span style='font-family:Arial;font-size:10.0pt;'>")
DECLARE styleFooter     =   vc with constant("<span style='font-family:Arial;font-size:8.0pt;'>")
DECLARE styleClose      =   vc with constant("</span>")
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
SET encntrid = request->encntr_id
 
 
CALL ECHO(BUILD('dcpgenericcd :',dcpgenericcd))
 
 
CALL ECHO('Get Facility')
SELECT inTO 'nl:'
 
FROM encounter e
 
 
PLAN e
WHERE e.encntr_id = encntrid
 
DETAIL
 
	a->orgid = e.organization_id
	a->facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
	mrnfac = BUILD2('STAR MRN - ',a->facility)
 
WITH nocounter
 
;Get MRN Alias
SELECT into 'nl:'
 
FROM code_value cv
WHERE cv.code_set = 263
AND cv.display = mrnfac
AND cv.active_ind = 1
 
DETAIL
 
	mrnaliascd = cv.code_value
 
WITH nocounter
 
CALL ECHO(BUILD('mrnfac :', mrnfac))
CALL ECHO(BUILD('mrnaliascd :', mrnaliascd))
;GO TO exitscript
 
 
 
CALL ECHO('Pt Info Query')
SELECT into 'nl:'
 
FROM encounter e,
	 person p ,
	 encntr_alias ea,
	 person_alias pa
 
PLAN e
WHERE e.encntr_id = encntrid
AND e.active_ind = 1
JOIN p
WHERE e.person_id = p.person_id
AND p.active_ind = 1
JOIN ea
WHERE e.encntr_id = ea.encntr_id
AND ea.encntr_alias_type_cd = 1077.00
AND ea.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")
AND ea.active_ind = 1
JOIN pa
WHERE p.person_id = pa.person_id
AND pa.person_alias_type_cd = 10.00
AND pa.alias_pool_cd = mrnaliascd
AND pa.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")
AND pa.active_ind = 1
 
HEAD REPORT
	cnt = 0
 
	a->facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
	a->orgid	=	e.organization_id
DETAIL
	cnt = cnt + 1
	stat = alterlist(a->qual, cnt)
 
	a->qual[cnt].personid	=	p.person_id
	a->qual[cnt].encntrid	=	e.encntr_id
	a->qual[cnt].name		=	TRIM(p.name_full_formatted)
	a->qual[cnt].unit		=	UAR_gET_cODE_DISPLAY(e.loc_nurse_unit_cd)
	a->qual[cnt].room		=	UAR_get_cODE_DISPLAY(e.loc_room_cd)
	a->qual[cnt].bed		=	UAR_GET_CODE_DISPLAY(e.loc_bed_cd)
	a->qual[cnt].mrn		=	TRIM(pa.alias)
	a->qual[cnt].fin		=	TRIM(ea.alias)
	a->qual[cnt].age		=	CNVTAGE(p.birth_dt_tm)
	a->qual[cnt].sex		=	UAR_gET_CODE_DISPLAY(p.sex_cd)
	a->qual[cnt].rfv		=	TRIM(e.reason_for_visit)
	a->qual[cnt].race		=	UAR_GET_CODE_DISPLAY(p.race_cd)
	a->qual[cnt].ethnicity	=	UAR_GET_CODE_DISPLAY(p.ethnic_grp_cd)
	a->qual[cnt].language	=	UAR_GET_CODE_DISPLAY(p.language_cd)
	a->qual[cnt].dob		=	FORMAT(p.birth_dt_tm,"mm/dd/yyyy;;d")
	a->rec_cnt				=	cnt
 
 
WITH nocounter
 
;address
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 address a
 
PLAN d
JOIN a
WHERE a->qual[d.seq].personid = a.parent_entity_id
AND a.parent_entity_name = 'PERSON'
AND a.address_type_cd = homeaddrcd
AND a.active_ind = 1
 
DETAIL
 
	a->qual[d.seq].address1 = a.street_addr
	a->qual[d.seq].address2 = a.street_addr2
	a->qual[d.seq].city		= TRIM(a.city)
	A->qual[d.seq].state	= TRIM(a.state)
	a->qual[d.seq].zip		= TRIM(a.zipcode)
 
 
WITH nocounter
 
;phone
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 phone p
 
PLAN d
JOIN p
WHERE a->qual[d.seq].personid = p.parent_entity_id
AND p.parent_entity_name = 'PERSON'
AND p.phone_type_cd IN (homephcd, busphcd, mobphcd)
AND p.active_ind = 1
 
DETAIL
 
	CASE (p.phone_type_cd)
 
		OF (homephcd):
 
			a->qual[d.seq].homephone = CNVTPHONE(p.phone_num,P.phone_format_cd)
 
		OF (busphcd):
 
			a->qual[d.seq].workphone = CNVTPHONE(p.phone_num,P.phone_format_cd)
 
		OF (mobphcd):
 
			a->qual[d.seq].cellphone = CNVTPHONE(p.phone_num,P.phone_format_cd)
 
	ENDCASE
 
 
 
WITH nocounter
 
 
;get pcp
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 person_prsnl_reltn ppr,
	 prsnl pr
 
PLAN d
JOIN ppr
WHERE a->qual[d.seq].encntrid = ppr.person_id
AND ppr.person_prsnl_r_cd 	  =  pcpcd
AND ppr.active_ind = 1
JOIN pr
WHERE ppr.prsnl_person_id = pr.person_id
AND pr.active_ind = 1
 
 
DETAIL
 
	A->qual[d.seq].pcp = TRIM(pr.name_full_formatted)
 
 
WITH nocounter
 
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 encntr_plan_reltn epr,
	 health_plan hp
 
PLAN d
JOIN epr
WHERE a->qual[d.seq].encntrid = epr.encntr_id
AND epr.active_ind = 1
JOIN hp
WHERE epr.health_plan_id = hp.health_plan_id
AND hp.active_ind = 1
 
DETAIL
 
	a->qual[d.seq].healthplan = TRIM(hp.plan_name)
 
 
WITH nocounter
 
;Lynx Mode of Arrival/Chief Complaint
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 clinical_event ce
 
PLAN d
JOIN ce
WHERE a->qual[d.seq].personid = ce.person_id
AND ce.event_cd IN (lnxmodearrcd, chiefcompcd)
AND a->qual[d.seq].encntrid = ce.encntr_id
AND ce.valid_until_dt_tm = CNVTDATETIME("31-DEC-2100 0")
 
DETAIL
	CASE (ce.event_cd)
		OF (lnxmodearrcd):
			a->qual[d.seq].lynxModeArr = TRIM(ce.result_val)
		OF (chiefcompcd):
			a->qual[d.seq].chiefcomp = TRIM(ce.result_val)
	ENDCASE
WITH nocounter
 
;Get Pre-Hospital Arrival info
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 dcp_forms_activity dfa,
	 dcp_forms_activity_comp dfac,
	 clinical_event ce,
	 clinical_event ce2
PLAN d
JOIN dfa
WHERE a->qual[d.seq].encntrid = dfa.encntr_id
AND dfa.dcp_forms_ref_id IN (edAdultTriageFrmId, edChildTriageFrmId)
AND dfa.active_ind = 1
JOIN dfac
WHERE dfa.dcp_forms_activity_id = dfac.dcp_forms_activity_id
AND dfac.component_cd = priEventId
JOIN ce
WHERE dfac.parent_entity_id = ce.parent_event_id
AND ce.event_title_text ='Pre-arrival Interventions'
AND ce.valid_until_dt_tm = CNVTDATETIME("31-DEC-2100 0")
join ce2
WHERE ce.event_id = ce2.parent_event_id
AND ce2.valid_until_dt_tm = CNVTDATETIME("31-DEC-2100 0")
 
HEAD REPORT
	cnt = 0
 
HEAD dfa.dcp_forms_ref_id
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(a->qual[d.seq].prearrfrmqual, cnt + 9)
 
	endif
 
	a->qual[d.seq].prearrfrmqual[cnt].formdt	=	FORMAT(dfa.form_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[d.seq].prearrfrmqual[cnt].formid	=	dfa.dcp_forms_ref_id
	a->qual[d.seq].prearrfrmqual[cnt].formname	=	dfa.description
	a->qual[d.seq].prearrfrmcnt					=	cnt
	rcnt = 0
 
DETAIL
	rcnt = rcnt + 1
	if (mod(rcnt,10) = 1 or rcnt = 1)
 
		stat = alterlist(a->qual[d.seq].prearrfrmqual[cnt].frmresqual, rcnt + 9)
 
	endif
 
	a->qual[d.seq].prearrfrmqual[cnt].frmresqual[rcnt].eventcd	=	ce2.event_cd
	a->qual[d.seq].prearrfrmqual[cnt].frmresqual[rcnt].eventid	=	ce2.event_id
	a->qual[d.seq].prearrfrmqual[cnt].frmresqual[rcnt].eventnm	=	UAR_GET_CODE_DISPLAY(ce2.event_cd)
	a->qual[d.seq].prearrfrmqual[cnt].frmresqual[rcnt].result	=	ce2.result_val
	a->qual[d.seq].prearrfrmqual[cnt].frmresqual[rcnt].verdttm	=	FORMAT(ce.verified_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[d.seq].prearrfrmqual[cnt].frmrescnt					=	rcnt
FOOT dfa.dcp_forms_ref_id
	stat = alterlist(a->qual[d.seq].prearrfrmqual[cnt].frmresqual, rcnt)
FOOT REPORT
	stat = alterlist(a->qual[d.seq].prearrfrmqual, cnt)
 
 
 
WITH nocounter
 
;iview/powerform assessments
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 clinical_event ce
 
PLAN d
JOIN ce
WHERE a->qual[d.seq].encntrid = ce.encntr_id
AND ce.entry_mode_cd IN (powerformscd,workviewcd)
AND ce.event_cd != dcpgenericcd
AND ce.valid_until_dt_tm = CNVTDATETIME("31-DEC-2100 0")
 
 
HEAD REPORT
 
	cnt = 0
 
DETAIL
 
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(a->qual[d.seq].rnassmntqual, cnt + 9)
 
	endif
	a->qual[d.seq].rnassmntqual[cnt].eventid	=	ce.event_id
	a->qual[d.seq].rnassmntqual[cnt].eventcd	=	ce.event_cd
	a->qual[d.seq].rnassmntqual[cnt].eventnm	=	UAR_GET_CODE_DISPLAY(ce.event_cd)
	a->qual[d.seq].rnassmntqual[cnt].perfdt		=	FORMAT(ce.performed_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[d.seq].rnassmntqual[cnt].result		=	TRIM(ce.result_val)
	a->qual[d.seq].rnassmntcnt					=	cnt
 
FOOT REPORT
 
	stat = alterlist(a->qual[d.seq].rnassmntqual, cnt)
 
 
 
WITH nocounter
 
 
;medications
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 orders o
 
PLAN d
JOIN o
WHERE a->qual[d.seq].encntrid = o.encntr_id
AND a->qual[d.seq].personid = o.person_id
AND o.catalog_type_cd = pharmcattypecd
AND o.template_order_id = 0.00
AND o.active_ind = 1
 
 
HEAD REPORT
 
	cnt = 0
 
DETAIL
 
	cnt = cnt + 1
	if (mod(cnt, 10) = 1 or cnt = 1)
 
		stat = alterlist(a->qual[d.seq].medqual, cnt + 9)
 
	endif
 
	a->qual[d.seq].medqual[cnt].ordname	=	UAR_GET_CODE_DISPLAY(o.catalog_cd)
	a->qual[d.seq].medqual[cnt].orderid	=	o.order_id
	a->qual[d.seq].medqual[cnt].orddetails = o.clinical_display_line
	a->qual[d.seq].medqual[cnt].medtype = if (o.prn_ind = 1)
	'PRN'
	elseif (o.sch_state_cd = 4546.00)
	'SCHEDULED'
	elseif (o.iv_ind = 1)
	'CONTINUOUS'
	elseif(o.sch_state_cd = 0)
	'UNSCHEDULED'
	endif
	a->qual[d.seq].medcnt		=	cnt
 
FOOT REPORT
 
	stat = alterlist(a->qual[d.seq].medqual, cnt)
 
 
WITH nocounter
 
 
;Orders on FCT
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 orders o
PLAN d
JOIN o
WHERE a->qual[d.seq].personid = o.person_id
AND o.catalog_type_cd IN (labcattypecd, radcattypecd)
AND a->qual[d.seq].encntrid = o.encntr_id
AND o.active_ind = 1
 
HEAD REPORT
 
	cnt = 0
 
 
DETAIL
 
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(a->qual[d.seq].fctordqual, cnt + 9)
 
	endif
	a->qual[d.seq].fctordqual[cnt].orderid	=	o.order_id
	a->qual[d.seq].fctordqual[cnt].ordname	=	TRIM(o.hna_order_mnemonic)
	a->qual[d.seq].fctordqual[cnt].orddetails	=	TRIM(o.clinical_display_line)
	a->qual[d.seq].fctordqual[cnt].orddttm	=	FORMAT(o.orig_order_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[d.seq].fctordcnt				=	cnt
 
 
FOOT REPORT
 	stat = alterlist(a->qual[d.seq].fctordqual, cnt)
 
WITH nocounter
 
;problems
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 problem p,
	 nomenclature n
 
PLAN d
JOIN p
WHERE a->qual[d.seq].personid = p.person_id
AND p.active_ind = 1
JOIN n
WHERE p.nomenclature_id = n.nomenclature_id
AND n.active_ind = 1
HEAD REPORT
 
	cnt = 0
 
 
DETAIL
 
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(a->qual[d.seq].probqual, cnt + 9)
 
	endif
 	a->qual[d.seq].probqual[cnt].problem_id	=	p.problem_id
 	a->qual[d.seq].probqual[cnt].problem	=	n.source_string
 	a->qual[d.seq].probqual[cnt].onsetdttm	=	FORMAT(p.onset_dt_tm,"mm/dd/yyyy hh:mm;;q")
 	a->qual[d.seq].probcnt					=	cnt
FOOT REPORT
	stat = alterlist(a->qual[d.seq].probqual, cnt )
 
WITH nocounter
 
;diagnoses
SELECT into 'nl:'
 
FROM (dummyt d with seq = 1),
	 diagnosis dx,
	 nomenclature n
 
PLAN d
JOIN dx
WHERE a->qual[d.seq].encntrid = dx.encntr_id
AND dx.active_ind	=	1
JOIN n
WHERE dx.nomenclature_id = n.nomenclature_id
AND n.active_ind = 1
 
HEAD REPORT
	cnt = 0
DETAIL
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(a->qual[d.seq].diagqual, cnt + 9)
 
	endif
	a->qual[d.seq].diagqual[cnt].diag_id	=	dx.diagnosis_id
	a->qual[d.seq].diagqual[cnt].diagnosis	=	n.source_string
	a->qual[d.seq].diagqual[cnt].diagtype	=	UAR_GET_CODE_DISPLAY(dx.diag_type_cd)
	a->qual[d.seq].diagqual[cnt].actdttm	=	FORMAT(dx.diag_dt_tm,"MM/DD/YYYY HH:MM;;Q")
	a->qual[d.seq].diagcnt					=	cnt
FOOT REPORT
	stat = alterlist(a->qual[d.seq].diagqual, cnt)
 
WITH nocounter
 
;ED Disposition Form
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 dcp_forms_activity dfa,
	 dcp_forms_activity_comp dfac,
	 clinical_event ce,
	 clinical_event ce2
	 
 
PLAN d
JOIN dfa
WHERE a->qual[d.seq].encntrid = dfa.encntr_id
AND dfa.dcp_forms_ref_id = eddispdocfrm
JOIN dfac
WHERE dfa.dcp_forms_activity_id = dfac.dcp_forms_activity_id
AND dfac.component_cd	=	clinevt
JOIN ce
WHERE dfac.parent_entity_id = ce.parent_event_id
AND ce.valid_until_dt_tm = CNVTDATETIME("31-DEC-2100 0")
JOIN ce2
WHERE ce.event_id = ce2.parent_event_id
;AND ce.event_title_text IN ('External Transfer Form- Nurse', 'External Transfer Form- Physician')
AND ce2.valid_until_dt_tm = CNVTDATETIME("31-DEC-2100 0")

HEAD REPORT
	cnt = 0
HEAD dfa.dcp_forms_ref_id
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(a->qual[d.seq].dispfrmqual, cnt + 9)
 
	endif
 
	a->qual[d.seq].dispfrmqual[cnt].formdt	=	FORMAT(dfa.form_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[d.seq].dispfrmqual[cnt].formid	=	dfa.dcp_forms_ref_id
	a->qual[d.seq].dispfrmqual[cnt].formname	=	dfa.description
	a->qual[d.seq].dispfrmcnt					=	cnt
	rcnt = 0
 
DETAIL
	rcnt = rcnt + 1
	if (mod(rcnt,10) = 1 or rcnt = 1)
 
		stat = alterlist(a->qual[d.seq].dispfrmqual[cnt].frmresqual, rcnt + 9)
 
	endif
 
	a->qual[d.seq].dispfrmqual[cnt].frmresqual[rcnt].eventcd	=	ce2.event_cd
	a->qual[d.seq].dispfrmqual[cnt].frmresqual[rcnt].eventid	=	ce2.event_id
	a->qual[d.seq].dispfrmqual[cnt].frmresqual[rcnt].eventnm	=	UAR_GET_CODE_DISPLAY(ce2.event_cd)
	a->qual[d.seq].dispfrmqual[cnt].frmresqual[rcnt].result	=	ce2.result_val
	a->qual[d.seq].dispfrmqual[cnt].frmresqual[rcnt].verdttm	=	FORMAT(ce.verified_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[d.seq].dispfrmqual[cnt].frmrescnt					=	rcnt
	
FOOT dfa.dcp_forms_ref_id
	stat = alterlist(a->qual[d.seq].dispfrmqual[cnt].frmresqual, rcnt)
FOOT REPORT
	stat = alterlist(a->qual[d.seq].dispfrmqual, cnt)





WITH nocounter 
call echorecord(a)
 
 
;Display Results
 
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt)
 
HEAD REPORT
	htmlText = htmlhdr
	;facility info
	;htmlText = CONCAT(htmlText,'<p align=center>',styleFac,a->facility,styleClose,'</p>')
	;htmlText = CONCAT(htmlText,'<p>',styleHdr,'FINANCIAL AUDITOR FORM',styleClose,'</p>')
 
	;encounter info
	;htmlText = CONCAT(htmlText,'<p>',styleHdr,a->qual[d.seq].name,' ', a->qual[d.seq].fin,
 	;styleClose,'</p>')
DETAIL
 
	;LYNX mode of arrival
	htmlText = CONCAT(htmlText, tblhdr, htmlTblRowStart,htmlColRes,styleBody,
	'<b>Lynx Mode Of Arrival :</b>',styleClose,htmlColEnd)
	htmlText = CONCAT(htmlText, htmlColRes, StyleBody,a->qual[d.seq].lynxModeArr,styleClose, htmlColEnd, htmlTblRowEnd,tblFtr)
 
	;Chief Complaint
	htmlText = CONCAT(htmlText, tblhdr, htmlTblRowStart,htmlColRes,styleBody,
	'<b>Chief Complaint :</b>',styleClose,htmlColEnd)
	htmlText = CONCAT(htmlText, htmlColRes, StyleBody,a->qual[d.seq].chiefcomp,styleClose, htmlColEnd, htmlTblRowEnd,tblFtr)
 
	;Pre-Arrival Treatment
 
 
	FOR (cnt = 1 TO a->qual[d.seq].prearrfrmcnt)
		htmlText = CONCAT(htmlText, styleBody,'<p><b>Pre-Arrival Treatment</b><p>',styleClose,tblHdr)
		FOR (rcnt = 1 TO a->qual[d.seq].prearrfrmqual[cnt].frmrescnt)
 
			htmlText = CONCAT(htmlText, htmlTblRowStart,htmlColRes,styleBody,
			'<b>', a->qual[d.seq].prearrfrmqual[cnt].frmresqual[rcnt].eventnm,'</b>',styleClose,htmlColEnd)
			htmlText = CONCAT(htmlText, htmlColRes,styleBody,
			a->qual[d.seq].prearrfrmqual[cnt].frmresqual[rcnt].result,styleClose,htmlColEnd,htmlTblRowEnd)
 
		ENDFOR
	ENDFOR
	htmlText = CONCAT(htmlText,tblFtr)
 
	;Nursing Assessments
	FOR (cnt = 1 TO a->qual[d.seq].rnassmntcnt)
 
		if (cnt = 1)
			htmlText = CONCAT(htmlText, styleBody,'<p><b>Nursing Assessments</b></p>',styleClose,tblHdr)
		endif
		htmlText = CONCAT(htmlText,htmlTblRowStart,htmlColRes,styleBody,'<b>',
		a->qual[d.seq].rnassmntqual[cnt].eventnm,'</b>',styleClose,htmlColEnd)
		htmlText = CONCAT(htmlText,htmlColRes,styleBody,
		a->qual[d.seq].rnassmntqual[cnt].result,styleClose,htmlColEnd,htmlTblRowEnd)
 
		if (cnt = a->qual[d.seq].rnassmntcnt)
			htmlText = CONCAT(htmlText,tblFtr)
		endif
	ENDFOR
 
 
 	;Medications
 	FOR (cnt = 1 TO a->qual[d.seq].medcnt)
 		if (cnt = 1)
 			htmlText = CONCAT(htmlText, styleBody,'<p><b>Medications</b></p>',styleClose,tblHdr)
 		endif
 
 		htmlText = CONCAT(htmlText,htmlTblRowStart,htmlColRes,styleBody,'<b>',
 		a->qual[d.seq].medqual[cnt].ordname,'</b>',styleClose,htmlColEnd)
 		htmlText = CONCAT(htmlText,htmlColRes,styleBody,'<b>',
 		a->qual[d.seq].medqual[cnt].orddetails,'</b>',styleClose,htmlColEnd,htmlTblRowEnd)
 
 		if (cnt = a->qual[d.seq].medcnt)
			htmlText = CONCAT(htmlText,tblFtr)
		endif
 
 	ENDFOR
 
 	;FCT Orders
 
 	FOR (cnt = 1 TO a->qual[d.seq].fctordcnt)
 
 		if (cnt = 1)
 			htmlText = CONCAT(htmlText, styleBody,'<p><b>FCT Orders</b></p>',styleClose,tblHdr)
 		endif
 
 		htmlText = CONCAT(htmlText, htmlTblRowStart, htmlColRes,styleBody,'<b>',
 		a->qual[d.seq].fctordqual[cnt].ordname, '</b>', styleClose, htmlColEnd)
 		htmlText = CONCAT(htmlText, htmlColRes,styleBody,
 		a->qual[d.seq].fctordqual[cnt].orddetails, styleClose, htmlColEnd,htmlTblRowEnd)
 
 		if (cnt = a->qual[d.seq].fctordcnt)
			htmlText = CONCAT(htmlText,tblFtr)
		endif
 
 	ENDFOR
 
 	;Diagnoses
 	FOR (cnt = 1 TO a->qual[d.seq].diagcnt)
 
 		if (cnt = 1)
 			htmlText = CONCAT(htmlText, styleBody,'<p><b>Diagnoses</b></p>',styleClose,tblHdr)
 		endif
 
 		htmlText = CONCAT(htmlText, htmlTblRowStart, htmlColRes,styleBody,'<b>',
 		a->qual[d.seq].diagqual[cnt].diagnosis, '</b>', styleClose, htmlColEnd)
 		htmlText = CONCAT(htmlText, htmlColRes,styleBody,
 		a->qual[d.seq].diagqual[cnt].diagtype, styleClose, htmlColEnd,htmlTblRowEnd)
 
 		if (cnt = a->qual[d.seq].diagcnt)
			htmlText = CONCAT(htmlText,tblFtr)
		endif
 
 	ENDFOR
 
 	;Problems
 	FOR (cnt = 1 TO a->qual[d.seq].probcnt)
 
 		if (cnt = 1)
 			htmlText = CONCAT(htmlText, styleBody,'<p><b>Problems</b></p>',styleClose,tblHdr)
 		endif
 
 		htmlText = CONCAT(htmlText, htmlTblRowStart, htmlColRes,styleBody,'<b>',
 		a->qual[d.seq].probqual[cnt].problem, '</b>', styleClose, htmlColEnd)
 		htmlText = CONCAT(htmlText, htmlColRes,styleBody,
 		a->qual[d.seq].probqual[cnt].onsetdttm, styleClose, htmlColEnd,htmlTblRowEnd)
 
 		if (cnt = a->qual[d.seq].diagcnt)
			htmlText = CONCAT(htmlText,tblFtr)
		endif
 
 	ENDFOR
 
 	;Disposition Form
 	FOR (cnt = 1 TO a->qual[d.seq].dispfrmcnt)
		htmlText = CONCAT(htmlText, styleBody,'<p><b>ED Disposition</b><p>',styleClose,tblHdr)
		FOR (rcnt = 1 TO a->qual[d.seq].dispfrmqual[cnt].frmrescnt)
 
			htmlText = CONCAT(htmlText, htmlTblRowStart,htmlColRes,styleBody,
			'<b>', a->qual[d.seq].dispfrmqual[cnt].frmresqual[rcnt].eventnm,'</b>',styleClose,htmlColEnd)
			htmlText = CONCAT(htmlText, htmlColRes,styleBody,
			a->qual[d.seq].dispfrmqual[cnt].frmresqual[rcnt].result,styleClose,htmlColEnd,htmlTblRowEnd)
 
		ENDFOR
		
		htmlText = CONCAT(htmlText, TblFtr)
	ENDFOR
	
FOOT REPORT
	htmlText = CONCAT(htmlText,endhtml)
 
 
 
WITH nocounter
 
CALL ECHO(htmlText)
 
SET REPLY->TEXT = htmlText
SET REPLY->FORMAT = 1
 
 
 
 
#exitscript
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 
