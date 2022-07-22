/***********************************************************
Author 			:	Mike Layman
Date Written	:	02/15/2018
Program Title	:	Covenant External Transfer User Defined Token
Source File		:	cov_ext_trf_tkn.prg
Object Name		:	cov_ext_trf_tkn
Directory		:	cust_script
DVD Version		:	2017.07.1.81
HNA Version		:	2015.01
CCL Version		:	8.8.3
Purpose			: 	This program is designed to demonstrate several
					principles for using the CCL language. CR575
Tables Read		:	person, encounter, encntr_alias, person_alias,
					clinical_event, orders, order_action
Tables Updated	:	NA
Include File	:	NA
Shell Scripts	:	NA
Executing App	:	Explorer Menu
Special Notes	:	This script must be included, it must be referenced in
                	the clinical html template for each facility and uploaded
                	using the trackingdbtool. The script servers 51,52 and 80
                	must be cycled.
Usage			:	cov_example_rpt "mine", 555555.00, 222222.00 go
Mod		Date		Engineer				Comment
----    ----------- ----------------------- ---------------------------
001		10/31/2017	Mike Layman				Original Release


$LastChangedBy::							$:
$LastChangedDate::							$:
$LastChangedRevision::						$:




************************************************************/
drop program cov_ext_trf_tkn go
create program cov_ext_trf_tkn


/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
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
	2	physfrmcnt		=	i4
	2	physfrmqual[*]
		3	diagnosis 			=	vc
		3	ptcond				=	vc
		3	ptcond2				=	vc
		3	trfreason			=	vc
		3	hospaccfac			=	vc
		3	hospaccprv			=	vc
		3	hospaccdttm			=	vc
		3	hospacctrfrisk		=	vc
		3	hospacctrfbenefits	=	vc
		3	provsignature		=	vc
		3	formdttm			=	vc
		3   hilvlcare			=	vc

	2	nrsfrmcnt		=	i4
	2	nrsfrmqual[*]
		3	transportmode		=	vc
		3	supptrtmnttrf		=	vc
		3	transsrvccont		=	vc
		3 	transprovsig		=	vc
		3	transprovdttm		=	vc
		3	nrsgrptcallto		=	vc
		3	nrsgrptdttm			=	vc
		3	nrsgrptcallmobsrvc	=	vc
		3	nrgrptmobsrvcrep	=	vc
		3	dcvitalstemp		=	vc
		3	dcvitalssysbp		=	vc
		3	dcvitalsdiabp		=	vc
		3	dcvitalsbp			=	vc
		3	dcvitalspulse		=	vc
		3	dcvitalsresprate	=	vc
		3	dcvitalspainscore	=	vc
		3	accdocsentvia		=	vc
		3	accrecsent			=	vc
		3	accdocpertmr		=	vc
		3	accdoclab			=	vc
		3	accdocekg			=	vc
		3	accdoctrfform		=	vc
		3	accdoccourtord		=	vc
		3	accdocadvdir		=	vc
		3	accdoccertofneed	=	vc
		3	accdocother			=	vc
		3	ptconstotrf			=	vc
		3	ptcommnosigneed		=	vc
		3	provsignature		=	vc
		3	formdttm			=	vc
		3	numpainscore		=	vc
		3	numaccpainscore		=	vc
		3	facpainscore		=	vc
		3	facaccpainscore		=	vc
		3	emto2support		=	vc
		3	emtinsupport		=	vc
		3	emtivsupport		=	vc
		3	emtcasupport		=	vc
		3	spo2				=	vc
		3	o2flowrate			=	vc
		3	o2therapy			=	vc
		3	hilvlcare			=	vc

)

/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/

DECLARE parseDate(result = vc) = null
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
DECLARE exttrfphysfrm = f8 WITH CONSTANT(188263647.00), PROTECT
DECLARE exttrfnrsfrm = f8 WITH CONSTANT(171312805.00), PROTECT
DECLARE encntrid	= f8 WITH NOCONSTANT(0.0), PROTECT
DECLARE clinevt		= f8 WITH NOCONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',18189,'PRIMARYEVENTID')), PROTECT
;Physician Form codes
DECLARE ptcond				= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'EMTALAPATIENTCONDITION')), PROTECT
DECLARE ptcond2				= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'PATIENTCONDITIONDISPOSITION')), PROTECT
DECLARE trfreason			= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'EMTALAREASONFORTRANSFER')), PROTECT
DECLARE hospaccfac			= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'EMTALAHOSPITALACCEPTANCEFACILITY')), PROTECT
DECLARE hospaccprv			= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'EMTALAHOSPITALACCEPTANCEPROVIDER')), PROTECT
DECLARE hospaccdttm			= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'EMTALAHOSPITALACCEPTANCEDATETIME')), PROTECT
DECLARE hospacctrfrisk		= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'EMTALARISKOFTRANSFER')), PROTECT
DECLARE hospacctrfbenefits	= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'EMTALABENEFITSOFTRANSFERBENEFITS')), PROTECT
;Nursing Form Codes
DECLARE transportmode		= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'EMTALAMODEOFTRANSPORT')), PROTECT
DECLARE supptrtmntdurtrans	= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'EMTALASUPPORTIVETREATMENTDURINGTRANS')), PROTECT
DECLARE transsrvccont		= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'EMTALATRANSPORTATIONSERVICECONTACTED')), PROTECT
DECLARE transsrvcontby		= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'EMTALATRANSPORTSERVICECONTACTEDBY')), PROTECT
DECLARE transsrvconttime	= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'EMTALATRANSPORTSERVICECONTACTEDTIME')), PROTECT
DECLARE rptcalledto			= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'EMTALAREPORTCALLEDTONAMETITLE')), PROTECT
DECLARE rptcalleddttm		= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'EMTALAREPORTCALLEDTODATETIME')), PROTECT
DECLARE rptcallbymobrep		= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'EMTALAREPORTCALLEDBYMOBILECRISISRE')), PROTECT
DECLARE mobrepname			= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'EMTALAMOBILECRISISREPRESENTATIVENAME')), PROTECT
DECLARE temptmpart			= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'TEMPERATURETEMPORALARTERY')), PROTECT
DECLARE temptymp			= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'TEMPERATURETYMPANIC')), PROTECT
DECLARE temporal			= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'TEMPERATUREORAL')), PROTECT
DECLARE temprectal			= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'TEMPERATURERECTAL')), PROTECT
DECLARE tempaxillary		= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'TEMPERATUREAXILLARY')), PROTECT
DECLARE systbp				= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'SYSTOLICBLOODPRESSURE')), PROTECT
DECLARE diastbp				= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'DIASTOLICBLOODPRESSURE')), PROTECT
DECLARE pulse				= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'PERIPHERALPULSERATE')), PROTECT
DECLARE resprate			= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'RESPIRATORYRATE')), PROTECT
DECLARE accdocsentvia		= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'EMTALAACCOMPANYINGDOCSENTVIA')), PROTECT
DECLARE recordssent			= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'EMTALARECORDSSENT')), PROTECT
DECLARE commtrans			= F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'EMTALACOMMITTEDTRANSFER')), PROTECT
DECLARE chDate				= VC WITH NOCONSTANT(FILLSTRING(15,' ')), PROTECT
DECLARE busaddrtypecd		= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',212,'BUSINESS')), PROTECT
;adding painscores
DECLARE painscore			= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 72,'NUMERICRATINGPAINSCORE')), PROTECT
DECLARE accpainscore		= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 72, 'NUMERICPAINACCEPTABLEINTENSITYSCORE')), PROTECT
DECLARE facpainscore		= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 72, 'FACESPAINSCORERATING')), PROTECT
DECLARE accfacpainscore		= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 72, 'FACESACCEPTABLEINTENSITYSCORE')), PROTECT
;adding freetext fields
DECLARE emtsuppo2cd			= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'EMTALASUPPORTIVETREATMENTO2FREETEXT')), PROTECT
DECLARE emtsuppincd			= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'EMTALASUPPORTIVETREATMENTINTFREETEXT')), PROTECT
DECLARE emtsuppivcd			= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'EMTALASUPPORTIVETREATMENTIVFREETEXT')), PROTECT
DECLARE emtsuppcacd			= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'EMTALASUPPORTIVETREATMENTCARDIACMONITOR')), PROTECT
;adding O2 fields
DECLARE spo2cd				= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAY', 72,'SpO2')), PROTECT
DECLARE o2flowratecd		= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAY', 72,'Oxygen Flow Rate')), PROTECT
DECLARE o2therapycd			= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 72, 'OXYGENTHERAPY')), PROTECT
;adding Emtala Higher Level of Care
DECLARE emthilvlcare	= 	f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 72,'EMTALAHIGHERLEVELOFCARE')), PROTECT
DECLARE DIAG_DISCH_VAR		 = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",17,"DISCHARGE")),PROTECT
DECLARE CC_VAR				 = F8 WITH CONSTANT(UAR_GET_CODE_BY("DISPLAY_KEY",17,"REASONFORVISIT")),PROTECT	;cheif complaint


;Define HTML tags
DECLARE htmlhdr = vc WITH CONSTANT('<html><body>')
DECLARE endhtml = vc WITH CONSTANT('</body></html>')
DECLARE div = VC with CONSTANT('<div ')
DECLARE tblhdr          = vc   with constant("<table border = 0 cellspacing = 0 cellpadding =0>")
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

SET encntrid = request->encntr_id ;  103996511.00 ;  ;   ;  ;98650785.00 ; ;replace with request->visit[1].encntrid
/**************************************************************
; DVDev Start Coding
**************************************************************/

;check cv's
CALL ECHO(BUILD('CLINEVT :',clinevt))
CALL ECHO(BUILD('ptcond :',ptcond))
CALL ECHO(BUILD('ptcond2 :',ptcond2))
CALL ECHO(BUILD('trfreason :',trfreason))
CALL ECHO(BUILD('hospaccfac :',hospaccfac))
CALL ECHO(BUILD('hospaccprv :',hospaccprv))
CALL ECHO(BUILD('hospaccdttm :',hospaccdttm))
CALL ECHO(BUILD('hospacctrfrisk :',hospacctrfrisk))
CALL ECHO(BUILD('hospacctrfbenefits :',hospacctrfbenefits))

CALL ECHO(BUILD('transportmode :',transportmode))
CALL ECHO(BUILD('supptrtmntdurtrans :',supptrtmntdurtrans))
CALL ECHO(BUILD('transsrvccont :',transsrvccont))
CALL ECHO(BUILD('transsrvcontby :',transsrvcontby))
CALL ECHO(BUILD('transsrvconttime :',transsrvconttime))
CALL ECHO(BUILD('rptcalledto :',rptcalledto))
CALL ECHO(BUILD('rptcalleddttm :',rptcalleddttm))
CALL ECHO(BUILD('rptcallbymobrep :',rptcallbymobrep))
CALL ECHO(BUILD('mobrepname :',mobrepname))
CALL ECHO(BUILD('temptmpart :',temptmpart))
CALL ECHO(BUILD('temptymp :',temptymp))
CALL ECHO(BUILD('temporal :',temporal))
CALL ECHO(BUILD('temprectal :',temprectal))
CALL ECHO(BUILD('tempaxillary :',tempaxillary))
CALL ECHO(BUILD('systbp :',systbp))
CALL ECHO(BUILD('diastbp :',diastbp))
CALL ECHO(BUILD('pulse :',pulse))
CALL ECHO(BUILD('resprate :',resprate))
CALL ECHO(BUILD('accdocsentvia :',accdocsentvia))
CALL ECHO(BUILD('recordssent :',recordssent))
CALL ECHO(BUILD('commtrans :',commtrans))
CALL ECHO(BUILD('painscore :',painscore))
CALL ECHO(BUILD('accpainscore :',accpainscore))
CALL ECHO(BUILD('facpainscore :',facpainscore))
CALL ECHO(BUILD('accfacpainscore :',accfacpainscore))
CALL ECHO(BUILD('emtsuppo2cd :',emtsuppo2cd))
CALL ECHO(BUILD('emtsuppincd :',emtsuppincd))
CALL ECHO(BUILD('emtsuppivcd :',emtsuppivcd))
CALL ECHO(BUILD('emtsuppcacd :',emtsuppcacd))
CALL ECHO(BUILD('spo2cd :',spo2cd))
CALL ECHO(BUILD('o2flowratecd :',o2flowratecd))
CALL ECHO(BUILD('o2therapycd :',o2therapycd))

CALL ECHO('Pt Info Query')
SELECT into 'nl:'

FROM encounter e,
	 person p ,
	 encntr_alias ea
	; person_alias pa

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
;JOIN pa
;WHERE p.person_id = pa.person_id
;AND pa.person_alias_type_cd = 10.00
;AND pa.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")
;AND pa.active_ind = 1

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
	;a->qual[cnt].mrn		=	TRIM(pa.alias)
	a->qual[cnt].fin		=	TRIM(ea.alias)
	a->qual[cnt].age		=	CNVTAGE(p.birth_dt_tm)
	a->qual[cnt].sex		=	UAR_gET_CODE_DISPLAY(p.sex_cd)
	a->qual[cnt].diagnosis	=	TRIM(e.reason_for_visit)
	a->rec_cnt				=	cnt


WITH nocounter

SELECT INTO 'NL:'
;SELECT INTO VALUE ($OUTDEV)
	  dtcode	=	d.diag_type_cd
	, dx		=	n.source_string
;	, DX		= MAX(n.source_string) KEEP (DENSE_RANK FIRST ORDER BY d.diagnosis_id ASC) OVER (PARTITION BY d.encntr_id)	;004
FROM
	(dummyt d1 with seq = a->rec_cnt)
	,diagnosis    d
	,nomenclature n
PLAN d1
join d
	WHERE
			d.encntr_id = a->qual[d1.seq].encntrid
		AND d.active_ind = 1
		AND d.diag_type_cd IN (DIAG_DISCH_VAR,cc_var)

JOIN n
	WHERE
			d.nomenclature_id = n.nomenclature_id
		AND n.active_ind = 1

ORDER BY
	 d.encntr_id
 	,d.diagnosis_id desc
head report
	cnt = 0
DETAIL
 	cnt = (cnt + 1)
	case (dtcode)
		of DIAG_DISCH_VAR :
												if (cnt = 1) a->qual[d1.seq].diagnosis  = dx
												else
													a->qual[d1.seq].diagnosis = concat(a->qual[d1.seq].diagnosis, " ", dx)
												endif

		of cc_var		  : ED->LIST[dt.seq].cc_dx	   = dx
	endcase

WITH nocounter

;CALL ECHORECORD(a)
;GO TO exitscript

CALL ECHO('Physician External Form Data')

SELECT into 'nl:'

FROM (dummyt d with seq = a->rec_cnt),
	 dcp_forms_activity dfa,
	 dcp_forms_activity_comp dfac,
	 clinical_event ce,
	 clinical_event ce2,
	 prsnl pr

PLAN d
JOIN dfa
WHERE a->qual[d.seq].encntrid = dfa.encntr_id
AND dfa.dcp_forms_ref_id = exttrfphysfrm
JOIN dfac
WHERE dfa.dcp_forms_activity_id = dfac.dcp_forms_activity_id
AND dfac.component_cd	=	clinevt
JOIN ce
WHERE dfac.parent_entity_id = ce.parent_event_id
AND ce.valid_until_dt_tm = CNVTDATETIME("31-DEC-2100 0")
JOIN ce2
WHERE ce.event_id = ce2.parent_event_id
AND ce2.valid_until_dt_tm = CNVTDATETIME("31-DEC-2100 0")
JOIN pr
WHERE dfa.updt_id =pr.person_id
HEAD REPORT
	cnt = 0
 	cnt = cnt + 1
;HEAD ce2.encntr_id
DETAIL

 	;if (mod(cnt,10) = 1 or cnt = 1)

 		stat = alterlist(a->qual[d.seq].physfrmqual, cnt )

 	;endif
	CASE (ce2.event_cd)

		OF (ptcond):
			a->qual[d.seq].physfrmqual[cnt].ptcond = TRIM(ce2.result_val)

		OF (ptcond2):
			a->qual[d.seq].physfrmqual[cnt].ptcond2 = TRIM(ce2.result_val)
		OF (trfreason):
			a->qual[d.seq].physfrmqual[cnt].trfreason = TRIM(ce2.result_val)
		OF (hospaccfac):
			a->qual[d.seq].physfrmqual[cnt].hospaccfac = TRIM(ce2.result_val)
		OF (hospaccprv):
			a->qual[d.seq].physfrmqual[cnt].hospaccprv = TRIM(ce2.result_val)
		OF (hospaccdttm):
			CALL parseDate(ce2.result_val)
			a->qual[d.seq].physfrmqual[cnt].hospaccdttm = chDate;TRIM(ce2.result_val)
		OF (hospacctrfrisk):
			a->qual[d.seq].physfrmqual[cnt].hospacctrfrisk = TRIM(ce2.result_val)
		OF (hospacctrfbenefits):
			a->qual[d.seq].physfrmqual[cnt].hospacctrfbenefits = TRIM(ce2.result_val)

		OF (emthilvlcare):
 			a->qual[d.seq].physfrmqual[cnt].hilvlcare = TRIM(ce2.result_val)

	ENDCASE
	a->qual[d.seq].physfrmqual[cnt].provsignature = TRIM(pr.name_full_formatted)
	a->qual[d.seq].physfrmqual[cnt].formdttm	=	format(dfa.form_dt_tm, "mm/dd/yyyy hh:mm;;q")
 	a->qual[d.seq].physfrmcnt = cnt
FOOT REPORT
	stat = alterlist(a->qual[d.seq].physfrmqual, cnt )



WITH nocounter


CALL ECHO('Nurse External Form Data')

SELECT into 'nl:'

FROM (dummyt d with seq = a->rec_cnt),
	 dcp_forms_activity dfa,
	 dcp_forms_activity_comp dfac,
	 clinical_event ce,
	 clinical_event ce2,
	 prsnl pr

PLAN d
JOIN dfa
WHERE a->qual[d.seq].encntrid = dfa.encntr_id
AND dfa.dcp_forms_ref_id = exttrfnrsfrm
JOIN dfac
WHERE dfa.dcp_forms_activity_id = dfac.dcp_forms_activity_id
AND dfac.component_cd	=	clinevt
JOIN ce
WHERE dfac.parent_entity_id = ce.parent_event_id
AND ce.valid_until_dt_tm = CNVTDATETIME("31-DEC-2100 0")
JOIN ce2
WHERE ce.event_id = ce2.parent_event_id
AND ce2.valid_until_dt_tm = CNVTDATETIME("31-DEC-2100 0")
JOIN pr
WHERE dfa.updt_id =pr.person_id
HEAD REPORT
	cnt = 0
 	cnt = cnt + 1
;HEAD ce2.encntr_id
DETAIL

 	;if (mod(cnt,10) = 1 or cnt = 1)

 		stat = alterlist(a->qual[d.seq].nrsfrmqual, cnt )

 	;endif
	CASE (ce2.event_cd)

		OF (transportmode):
			a->qual[d.seq].nrsfrmqual[cnt].transportmode = TRIM(ce2.result_val)

		OF (supptrtmntdurtrans):
			a->qual[d.seq].nrsfrmqual[cnt].supptrtmnttrf  = TRIM(ce2.result_val)
		OF (transsrvccont):
			a->qual[d.seq].nrsfrmqual[cnt].transsrvccont = TRIM(ce2.result_val)
		OF (transsrvcontby):
			a->qual[d.seq].nrsfrmqual[cnt].transprovsig = TRIM(ce2.result_val)
		OF (transsrvconttime):
			CALL parseDate(ce2.result_val)
			a->qual[d.seq].nrsfrmqual[cnt].transprovdttm = chDate ;TRIM(ce2.result_val)
		OF (rptcalledto):
			a->qual[d.seq].nrsfrmqual[cnt].nrsgrptcallto = TRIM(ce2.result_val)
		OF (rptcalleddttm):
			CALL parseDate(ce2.result_val)
			a->qual[d.seq].nrsfrmqual[cnt].nrsgrptdttm = chDate ;TRIM(ce2.result_val)
		OF (rptcallbymobrep):
			a->qual[d.seq].nrsfrmqual[cnt].nrsgrptcallmobsrvc = TRIM(ce2.result_val)
		OF (mobrepname):
			a->qual[d.seq].nrsfrmqual[cnt].nrgrptmobsrvcrep = TRIM(ce2.result_val)
		OF (temptmpart):
			a->qual[d.seq].nrsfrmqual[cnt].dcvitalstemp = TRIM(ce2.result_val)
		OF (temptymp):
			a->qual[d.seq].nrsfrmqual[cnt].dcvitalstemp = TRIM(ce2.result_val)
		OF (temporal):
			a->qual[d.seq].nrsfrmqual[cnt].dcvitalstemp = TRIM(ce2.result_val)
		OF (temprectal):
			a->qual[d.seq].nrsfrmqual[cnt].dcvitalstemp = TRIM(ce2.result_val)
		OF (tempaxillary):
			a->qual[d.seq].nrsfrmqual[cnt].dcvitalstemp = TRIM(ce2.result_val)
		OF (systbp):
			a->qual[d.seq].nrsfrmqual[cnt].dcvitalssysbp = TRIM(ce2.result_val)
		OF (diastbp):
			a->qual[d.seq].nrsfrmqual[cnt].dcvitalsdiabp = TRIM(ce2.result_val)
		OF (pulse):
			a->qual[d.seq].nrsfrmqual[cnt].dcvitalspulse = TRIM(ce2.result_val)
		OF (resprate):
			a->qual[d.seq].nrsfrmqual[cnt].dcvitalsresprate = TRIM(ce2.result_val)
		OF (accdocsentvia):
			a->qual[d.seq].nrsfrmqual[cnt].accdocsentvia = TRIM(ce2.result_val)
		OF (recordssent):
			a->qual[d.seq].nrsfrmqual[cnt].accrecsent = TRIM(ce2.result_val)
		OF (commtrans):
			a->qual[d.seq].nrsfrmqual[cnt].ptcommnosigneed = TRIM(ce2.result_val)
		OF (painscore):
			a->qual[d.seq].nrsfrmqual[cnt].numpainscore = TRIM(ce2.result_val)
		OF (accpainscore):
			a->qual[d.seq].nrsfrmqual[cnt].numaccpainscore = TRIM(ce2.result_val)
		OF (facpainscore):
			a->qual[d.seq].nrsfrmqual[cnt].facpainscore = TRIM(ce2.result_val)
		OF (accfacpainscore):
			a->qual[d.seq].nrsfrmqual[cnt].facaccpainscore = TRIM(ce2.result_val)
		OF (emtsuppo2cd):
			a->qual[d.seq].nrsfrmqual[cnt].emto2support = TRIM(ce2.result_val)
		OF (emtsuppincd):
			a->qual[d.seq].nrsfrmqual[cnt].emtinsupport = TRIM(ce2.result_val)
		OF (emtsuppivcd):
			a->qual[d.seq].nrsfrmqual[cnt].emtivsupport = TRIM(ce2.result_val)
		OF (emtsuppcacd):
			a->qual[d.seq].nrsfrmqual[cnt].emtcasupport = TRIM(ce2.result_val)
		OF (spo2cd):
			a->qual[d.seq].nrsfrmqual[cnt].spo2 = TRIM(ce2.result_val)
		OF (o2flowratecd):
			a->qual[d.seq].nrsfrmqual[cnt].o2flowrate = TRIM(ce2.result_val)
		OF (o2therapycd):
			a->qual[d.seq].nrsfrmqual[cnt].o2therapy = TRIM(ce2.result_val)


	ENDCASE
 	a->qual[d.seq].nrsfrmqual[cnt].formdttm	= FORMAT(dfa.form_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[d.seq].nrsfrmqual[cnt].provsignature = TRIM(pr.name_full_formatted)
 	a->qual[d.seq].nrsfrmcnt				=	cnt
FOOT REPORT

	if (SIZE(a->qual[d.seq].nrsfrmqual[cnt].dcvitalssysbp)>0)
		a->qual[d.seq].nrsfrmqual[cnt].dcvitalsbp = CONCAT(a->qual[d.seq].nrsfrmqual[cnt].dcvitalssysbp,
		'/', a->qual[d.seq].nrsfrmqual[cnt].dcvitalsdiabp)
	endif
	stat = alterlist(a->qual[d.seq].nrsfrmqual, cnt )



WITH nocounter


;facility address
SELECT into 'nl:'

FROM address a
WHERE a->orgid = a.parent_entity_id
AND a.parent_entity_name = 'ORGANIZATION'
AND a.address_type_cd = busaddrtypecd

DETAIL

	a->facaddr1	=	TRIM(a.street_addr)
	a->facaddr2 =   TRIM(a.street_addr2)
	a->faccity = 	TRIM(a.city)
	a->facstate = 	TRIM(a.state)
	a->faczip = 	TRIM(a.zipcode)




WITH nocounter




;output

SELECT into 'nl:'

FROM (dummyt d with seq = a->rec_cnt)

HEAD REPORT
 	;facility name/address
	htmlText = htmlhdr
 	htmlText = CONCAT(htmlText,'<p align=center>',styleFac,a->facility,styleClose,'</p>')
 	htmlText = CONCAT(htmlText,'<p align=center>',styleFac,a->facaddr1,' ',a->facaddr2,styleClose,'</p>')
 	htmlText = CONCAT(htmlText,'<p align=center>',styleFac,a->faccity,', ', a->facstate,' ', a->faczip,
 	styleClose,'</p>')
 	;default legal text for form
 	htmlText = CONCAT(htmlText,'<p>',styleHdr,'EXTERNAL TRANSFER FORM',styleClose,'</p>')
 	htmlText = CONCAT(htmlText,'<p>',styleFooter,'This hospital is required by federal law to provide any ',
 	'presenting patient with a medical screening examination to determine whether an emergency ',
 	'medical condition exists and to provide necessary stabilizing care within its capabilities for ',
 	'emergency medical conditions ','<u>without regard to means or ability to pay.</u>',
 	' This hospital does participate in Medicare and Medicaid.',styleClose, '</p>')

 	;encounter fin/name
 	htmlText = CONCAT(htmlText,'<p>',styleHdr,a->qual[d.seq].name,' ', a->qual[d.seq].fin,
 	styleClose,'</p>')

 	vitalspscore = fillstring(100, ' ')

DETAIL
	;column1 - physician data
 	;htmlText = CONCAT(htmlText,'<p>',styleHdr,' Header Style ', styleClose,'</p>')
 	;htmlText = CONCAT(htmlText,'<p>',styleBody,' Body Style ', styleClose,'</p>')
 	;htmlText = CONCAT(htmlText,'<p>',styleFooter,' Footer Style ', styleClose,'</p>')
	htmlText = CONCAT(htmlText,tblHdr,htmlTblRowStart)

	FOR (cnt = 1 TO A->qual[d.seq].physfrmcnt)

		htmlText = CONCAT(htmlText, htmlTblHdrStart,styleHdr,"<b>Physician Documentation</b>",styleClose,htmlTblHdrEnd)
 		htmlText = CONCAT(htmlText, htmlTblHdrStart,styleHdr,"<b>Nurse Documentation</b>",styleClose,htmlTblHdrEnd,htmlTblRowEnd)

 		;physician col 1 - Pt Condition



 		htmlText = CONCAT(htmlText,htmlTblRowStart,htmlColRes,styleBody,'<b>1. Patient Condition </b>', '</br>',
 		'<b>Diagnosis : </b>', a->qual[d.seq].diagnosis,'</br>',
 		'<b>Patient Condition  : </b>',a->qual[d.seq].physfrmqual[cnt].ptcond,styleClose,htmlColEnd)

 		;Nurse Col 2 - Transport Mode
 		htmlText = CONCAT(htmlText,htmlColRes,styleBody,
 		'<b>6. Mode of Transport. </b></br>',
 		'<b>Transport Mode : </b>',a->qual[d.seq].nrsfrmqual[cnt].transportmode,'</br>',
 		'<b>Supportive Treatment :</b>',a->qual[d.seq].nrsfrmqual[cnt].supptrtmnttrf,'</br>',
 		'<b>Transportation Service Contacted : </b>',a->qual[d.seq].nrsfrmqual[cnt].transsrvccont,'</br>',
 		'<b>By : </b>', a->qual[d.seq].nrsfrmqual[cnt].transprovsig,'</br>',
 		'<b>Time : </b>',a->qual[d.seq].nrsfrmqual[cnt].transprovdttm,
 		styleClose,htmlColEnd,htmlTblRowEnd)

 		;Physician Col 1 - Reason for Transfer
 		htmlText = CONCAT(htmlText,htmlTblRowStart,htmlColRes,styleBody,
 		'<b>2. Reason for Transfer </b>','</br>',
 		'<b>Reason for Transfer : </b>',a->qual[d.seq].physfrmqual[cnt].trfreason,'</br>'
 		,'<b>Reason for Higher Level of care : </b>',a->qual[d.seq].physfrmqual[cnt].hilvlcare,styleClose,htmlColEnd)

 		;Nurse Col 2 - Nursing Report
 		htmlText = CONCAT(htmlText,htmlColRes,styleBody,
 		'<b>7. Nursing Report </b>','</br>',
 		'<b>Report called to : </b>',a->qual[d.seq].nrsfrmqual[cnt].nrsgrptcallto,'<br>',
 		'<b>Date/Time : </b>',a->qual[d.seq].nrsfrmqual[cnt].nrsgrptdttm, '</br>',
 		'<b>Report called by Mobile Service Representative : </b>',a->qual[d.seq].nrsfrmqual[cnt].nrsgrptcallmobsrvc,'</br>',
 		'<b>Mobile Service Representative : </b>',a->qual[d.seq].nrsfrmqual[cnt].nrgrptmobsrvcrep
 		,styleClose,htmlColEnd,htmlTblRowEnd)


 		;Physician Col 1 - Hospital Acceptance
 		htmlText = CONCAT(htmlText,htmlTblRowStart,htmlColRes,styleBody,
 		'<b>3. Hospital Acceptance </b>','</br>',
 		'<b>Accepting Facility : </b>',a->qual[d.seq].physfrmqual[cnt].hospaccfac,'</br>',
 		'<b>Provider : </b>', a->qual[d.seq].physfrmqual[cnt].hospaccprv,'</br>',
 		'<b>Date/Time : </b>', a->qual[d.seq].physfrmqual[cnt].hospaccdttm, '</br>',
 		   styleClose,htmlColEnd)

 		;Nurse Col 2 - Discharge Vitals

 		if (a->qual[d.seq].nrsfrmqual[cnt].numpainscore > ' ')

 			vitalspscore = a->qual[d.seq].nrsfrmqual[cnt].numpainscore

 		elseif (a->qual[d.seq].nrsfrmqual[cnt].numaccpainscore > ' ')

 			vitalspscore = a->qual[d.seq].nrsfrmqual[cnt].numaccpainscore

 		elseif (a->qual[d.seq].nrsfrmqual[cnt].facpainscore > ' ')

 			vitalspscore = a->qual[d.seq].nrsfrmqual[cnt].facpainscore

 		else
 			vitalspscore = a->qual[d.seq].nrsfrmqual[cnt].facaccpainscore

 		endif

 		htmlText = CONCAT(htmlText,htmlColRes,styleBody,
 		'<b>8. Discharge Vitals</b>','</br>',
 		'<b>BP : </b>',a->qual[d.seq].nrsfrmqual[cnt].dcvitalsbp, '</br>',
 		'<b>Pulse : </b>',a->qual[d.seq].nrsfrmqual[cnt].dcvitalspulse, ' </br>',
 		'<b>Temp : </b>', a->qual[d.seq].nrsfrmqual[cnt].dcvitalstemp, '</br>',
 		'<b>Resp Rate : </b>', a->qual[d.seq].nrsfrmqual[cnt].dcvitalsresprate,'</br>',
 		'<b>SpO2 : </b>', a->qual[d.seq].nrsfrmqual[cnt].spo2, '</br>',
 		'<b>O2 Flow : </b>', a->qual[d.seq].nrsfrmqual[cnt].o2flowrate, '</br>',
 		'<b>O2 Therapy : </b>', a->qual[d.seq].nrsfrmqual[cnt].o2therapy, '</br>',
 		'<b> Pain Score : </b>', TRIM(vitalspscore),'</br>',
 		'<b> O2 FreeText : </b>', TRIM(a->qual[d.seq].nrsfrmqual[cnt].emto2support), '</br>',
 		'<b> INT FreeText : </b>', a->qual[d.seq].nrsfrmqual[cnt].emtinsupport, '</br>',
 		'<b> IV FreeText : </b>', a->qual[d.seq].nrsfrmqual[cnt].emtivsupport, '</br>',
 		'<b> Cardiac Monitor : </b>', a->qual[d.seq].nrsfrmqual[cnt].emtcasupport,
 		styleClose,htmlColEnd,htmlTblRowEnd)

 		;Physician Col 1  - Risks of Transfer
 		htmlText = CONCAT(htmlText,htmlTblRowStart,htmlColRes,styleBody,
 		'<b>4. Risks of Transfer</b>','</br>',
 		'<b>Risks of Transfer : </b>', a->qual[d.seq].physfrmqual[cnt].hospacctrfrisk,
 		'</br>','[ ]All transfers have inherent risks of traffic delays or accidents ',
 		'during transport, inclement weather, rough terrain or air turbulence and the ',
 		'limited medical capacity of transport units which may restrict available care ',
 		'in the event of a crisis.',styleClose,htmlColEnd)


 		;Nurse Col 2 - Accompanying Documentation
 		htmlText = CONCAT(htmlText,htmlColRes,styleBody,
 		'<b>9. Accompanying Documentation </b>', '</br>',
 		'<b>Documentation Sent Via : </b>', a->qual[d.seq].nrsfrmqual[cnt].accdocsentvia,'</br>',
 		'<b>Records Sent : </b>', a->qual[d.seq].nrsfrmqual[cnt].accrecsent,
 		styleClose,htmlColEnd,htmlTblRowEnd)


 		;Physician Col 1 - Benefits of Transfer
 		htmlText = CONCAT(htmlText,htmlTblRowStart,htmlColRes,styleBody,
 		'<b>5. Benefits of Transfer </b>','</br>',
 		'<b>Benefits of Transfer : </b>',a->qual[d.seq].physfrmqual[cnt].hospacctrfbenefits,
 		'</br>','I hereby certify that I have examined the patient and based upon the ',
 		'information available to me at the time of transfer, that the medical ',
 		'benefits reasonably expected from the provision of appropriate medical care at ',
 		'another facility outweigh the risks of transfer. I certify that these risks and ',
 		'benefits have been explained to the patient or his/her representative.',
 		styleClose,htmlColEnd)

 		;Patient Consent to Transfer.
 		htmlText = CONCAT(htmlText,htmlColRes,styleBody,
 		'<b>10. Patient Consent to Transfer. </b>', '</br>',
 		'I understand the risks and benefits of my transfer.',
 		'</br>','[ ] I hereby consent to transfer to another facility. I understand that ',
 		'it is the opinion of the physician responsible for my care that the benefits of ',
 		'transfer outweigh the risks. I have been informed of the risks and benefits upon ',
 		'which this transfer is being made.</br>',
 		'[ ] I hereby REQUEST transfer to ______________________. I understand and have ',
 		'considered the hospitals responsibilities, the risks and benefits of transfer, ',
 		'and the physicians recommendation. I make this request upon my own suggestion and ',
 		'not that of the hospital, physician, or anyone associated with the hospital. The reason I ',
 		'request transfer is: __________________________.</br>',
 		'[ ] I hereby REFUSE transfer </br>', '[ ] COMMITED/No Patient Signature Required.</br>',
 		 ;'<input type="CheckBox" name = "chkboxgrp1" id = "chkboxgrp1_0"/>Option 1', '</br>',
; 		'<input type="CheckBox" name = "chkboxgrp1" value = "2" id = "chkboxgrp1_0"/>Option 2','</br>',
; 		'<input type="CheckBox" name = "chkboxgrp1" value = "3" id = "chkboxgrp1_0"/>Option 3',
 		styleClose, htmlColEnd, htmlTblRowEnd)

; 		;Physician Col 1 Elec Sig
 		htmlText = CONCAT(htmlText,htmlTblRowStart,htmlColRes,styleBody,
 		'<b> Electronic Signature </b>', '</br>',
 		'<b>Physician Signature : </b>', a->qual[d.seq].physfrmqual[cnt].provsignature,' </br>',
 		'<b> Date/Time : </b>', a->qual[d.seq].physfrmqual[cnt].formdttm,
 		styleClose,htmlColEnd)



; 		;Physician Col 1 -- Blank
; 		htmlText = CONCAT(htmlText,htmlTblRowStart,htmlColRes,styleBody
; 		,styleClose,htmlColEnd)

 		;Nurse Col 2 - Patient Signature
 		htmlText = CONCAT(htmlText,htmlColRes,styleBody,
 		'<b>Patient Signature </b>','</br>',
 		'<b>Signature of Patient </b> ______________________________','</br>',
 		'<b>Date/Time </b> ___________________________________','</br>',
 		'<b> Electronic Signature </b>','</br>',
 		'<b>Nurse Signature:</b>',a->qual[d.seq].nrsfrmqual[cnt].provsignature,'</br>',
 		'<b>Date/Time :</b>' ,a->qual[d.seq].nrsfrmqual[cnt].formdttm,
 		styleClose,htmlColEnd,htmlTblRowEnd)


;		htmlText = CONCAT(htmlText,'<p>',a->qual[d.seq].physfrmqual[cnt].ptcond,'</p>')
;		htmlText = CONCAT(htmlText,'<p>',a->qual[d.seq].physfrmqual[cnt].ptcond2,'</p>')
;		htmlText = CONCAT(htmlText,'<p>',a->qual[d.seq].physfrmqual[cnt].trfreason,'</p>')
;		htmlText = CONCAT(htmlText,'<p>',a->qual[d.seq].physfrmqual[cnt].hospaccfac,'</p>')
;		htmlText = CONCAT(htmlText,'<p>',a->qual[d.seq].physfrmqual[cnt].hospaccprv,'</p>')
;		htmlText = CONCAT(htmlText,'<p>',a->qual[d.seq].physfrmqual[cnt].hospaccdttm,'</p>')
;		htmlText = CONCAT(htmlText,'<p>',a->qual[d.seq].physfrmqual[cnt].hospacctrfrisk,'</p>')
;		htmlText = CONCAT(htmlText,'<p>',a->qual[d.seq].physfrmqual[cnt].hospacctrfbenefits,'</p>')
;		htmlText = CONCAT(htmlText,'<p>',a->qual[d.seq].physfrmqual[cnt].provsignature,'</p>')


	ENDFOR

 ;	htmlText = CONCAT(htmlText,'</div>')

	;column2 - nurse data
;	htmlText = CONCAT(htmlText,div," class='column2'>")
;	FOR (idx = 1 to a->qual[d.seq].nrsfrmcnt)
;
;		htmlText = CONCAT(htmlText,'<p>',a->qual[d.seq].nrsfrmqual[idx].transportmode,'</p>')
;		htmlText = CONCAT(htmlText,'<p>',a->qual[d.seq].nrsfrmqual[idx].supptrtmnttrf,'</p>')
;		htmlText = CONCAT(htmlText,'<p>',a->qual[d.seq].nrsfrmqual[idx].transsrvccont,'</p>')
;		htmlText = CONCAT(htmlText,'<p>',a->qual[d.seq].nrsfrmqual[idx].transprovsig,'</p>')
;		htmlText = CONCAT(htmlText,'<p>',a->qual[d.seq].nrsfrmqual[idx].transprovdttm,'</p>')
;		htmlText = CONCAT(htmlText,'<p>',a->qual[d.seq].nrsfrmqual[idx].transportmode,'</p>')
;		htmlText = CONCAT(htmlText,'<p>',a->qual[d.seq].nrsfrmqual[idx].transportmode,'</p>')
;		htmlText = CONCAT(htmlText,'<p>',a->qual[d.seq].nrsfrmqual[idx].transportmode,'</p>')
;		htmlText = CONCAT(htmlText,'<p>',a->qual[d.seq].nrsfrmqual[idx].transportmode,'</p>')
;		htmlText = CONCAT(htmlText,'<p>',a->qual[d.seq].nrsfrmqual[idx].transportmode,'</p>')
;		htmlText = CONCAT(htmlText,'<p>',a->qual[d.seq].nrsfrmqual[idx].transportmode,'</p>')
;
;
;	ENDFOR

vitalspscore = fillstring(100, ' ')

FOOT REPORT
	htmlText = CONCAT(htmlText,htmlFtr)
	;htmlText = CONCAT(htmlText, endhtml)

WITH nocounter

SET reply->text = htmlText
SET reply->format = 1

CALL ECHORECORD(a)
;GO TO exitscript
call echo(htmltext)

/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

SUBROUTINE parseDate(result)

SET yr = FILLSTRING(4,' ')
SET mm = FILLSTRING(2,' ')
SET dy = FILLSTRING(2,' ')

SET yr = SUBSTRING(3,4,result)
SET mm = SUBSTRING(7,2,result)
SET dy = SUBSTRING(9,2,result)

SET chDate = CONCAT(mm,'/',dy,'/',yr)

END ;subroutine


#exitscript

end
go
