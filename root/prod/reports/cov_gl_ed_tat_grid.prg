/***********************************************************
Author 			:	Mike Layman
Date Written	:	10/31/2017
Program Title	:	CCL Example Report
Source File		:	cov_example_rpt.prg
Object Name		:	cov_example_rpt
Directory		:	cust_script
DVD Version		:	2017.07.1.81
HNA Version		:	2015.01
CCL Version		:	8.8.3
Purpose			: 	This program is designed to demonstrate several
					principles for using the CCL language.
Tables Read		:	person, encounter, encntr_alias, person_alias,
					clinical_event, orders, order_action
Tables Updated	:	NA
Include File	:	NA
Shell Scripts	:	NA
Executing App	:	Explorer Menu
Special Notes	:
Usage			:	cov_example_rpt "mine", 555555.00, 222222.00 go
Mod		Date		Engineer				Comment
----    ----------- ----------------------- ---------------------------
001		10/31/2017	Mike Layman				Original Release
 
 
$LastChangedBy::							$:
$LastChangedDate::							$:
$LastChangedRevision::						$:
 
 
 
 
************************************************************/
drop program cov_gl_ed_tat_grid go
create program cov_gl_ed_tat_grid
 
prompt
	"Output to File/Printer/MINE" = "MINE"             ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 0
	, "Select Nursing Unit" = VALUE(1.0           )
	, "Select Test" = VALUE(1.0           )
	, "Select Test Priority" = VALUE(1.0           )
	, "Select Begin Date" = "SYSDATE"                  ;* Collected Date/Time is used for this parameter.
	, "Select End Date" = "SYSDATE"                    ;* Collected Date/Time is used for this parameter.
 
with OUTDEV, facility, unit, test, priority, bdate, edate
 
 
 
/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
**************************************************************/
FREE RECORD a
RECORD a
(
1	rec_cnt		=	i4
1	facility	=	vc
1	qual[*]
	2	personid		=	f8
	2	encntrid		=	f8
	2	orderid			=	f8
	2	name			=	vc
	2	containerid		=	f8
	2	facility		=	vc
	2	unit			=	vc
	2	room			=	vc
	2	bed				=	vc
	2	ordername		=	vc
	2	orderdttm		=	vc
	2	orderdatetm		=	f8
	2	drawndttm		=	vc
	2	drawndatetm		=	f8
	2	receiveddttm	=	vc
	2	receiveddatetm	=	f8
	2	perfdttm		=	vc
	2	perfdatetm		=	f8
	2	completedttm	=	vc
	2	completedatetm	=	f8
	2	elhbegeffdttm	=	vc
	2	elhendeffdttm	=	vc
	2	priority		=	vc
	2	accessionnbr	=	vc
	2	fin				=	vc
	2	receivedby		=	vc
	2	receivedid		=	f8
	2	perflocation	=	vc
	2	resourcecd		=	f8
	2	ordtocolltat	=	i4
	2	colltorecdtat	=	i4
	2	recdcomptat		=	i4
	2	completedby		=	vc
	2	completedid		=	f8
	2	collectedby		=	vc
	2	collectedid		=	f8
	2	printflg		=	i2
 
)
 
FREE RECORD cplogins
RECORD cplogins
(
 
1	rec_cnt	=	i4
1	qual[*]
	2	display		=	vc
	2	codevalue	=	f8
)
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
DECLARE drawncd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 2061, 'COLLECTED')), PROTECT
DECLARE receivedcd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 2061, 'RECEIVED')), PROTECT
DECLARE cancelcd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6004,'CANCELED')), PROTECT
DECLARE unitop = vc WITH NOCONSTANT(FILLSTRING(2,' ')), PROTECT
DECLARE testop = vc WITH NOCONSTANT(FILLSTRING(2,' ')), PROTECT
DECLARE priorityop = vc WITH NOCONSTANT(FILLSTRING(2,' ')), PROTECT
DECLARE idx = i4 WITH NOCONSTANT(0), PROTECT
DECLARE fin = f8 WITH NOCONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',319,'FINNBR')), PROTECT
DECLARE ed = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',71, 'EMERGENCY')), PROTECT
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
 
;cv's
CALL ECHO(BUILD('DRAWNCD :', drawncd))
CALL ECHO(BUILD('receivedcd :', receivedcd))
CALL ECHO(BUILD('cancelcd :', cancelcd))
 
 
;setup for prompts
 
;unit
IF (SUBSTRING(1,1,reflect(parameter(parameter2($unit),0)))="L")
 
	SET unitop = "IN"
ELSEIF (parameter(parameter2($unit),1) = 1.0)
	SET unitop = "!="
ELSE
	SET unitop = "="
ENDIF
 
call echo(build2("unitop :", unitop,' ', $unit))
;test
IF (SUBSTRING(1,1,reflect(parameter(parameter2($test),0)))="L")
 
	SET testop = "IN"
ELSEIF (parameter(parameter2($test),1) = 1.0)
	SET testop = "!="
ELSE
	SET testop = "="
ENDIF
call echo(build("testop :", testop,' ', $test))
 
;priority
IF (SUBSTRING(1,1,reflect(parameter(parameter2($priority),0)))="L")
 
	SET priorityop = "IN"
ELSEIF (parameter(parameter2($priority),1) = 1.0)
	SET priorityop = "!="
ELSE
	SET priorityop = "="
ENDIF
 
 
call echo(build("priorityop :", priorityop,' ', $priority))
 
 
;Get cp login locations
 
SELECT into 'nl:'
 
FROM code_value cv
WHERE cv.code_set = 220
AND cv.cdf_meaning = 'CSLOGIN'
AND cv.active_ind = 1
 
HEAD REPORT
 
	cnt = 0
 
DETAIL
IF (FINDSTRING("CP",cv.display,1)> 0)
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(cplogins->qual, cnt + 9)
 
	endif
	cplogins->qual[cnt].codevalue	=	cv.code_value
	cplogins->qual[cnt].display		=	cv.display
	cplogins->rec_cnt				=	cnt
 
ENDIF
 
FOOT REPORT
	stat = alterlist(cplogins->qual, cnt)
 
WITH nocounter
 
CALL ECHORECORD(cplogins)
 
SELECT into 'nl:'
 
FROM container_event ce,
	 container c,
	 container_accession ca,
	 order_container_r ocr,
	 orders o,
	 encntr_loc_hist elh,
	 encounter e,
	 person p,
	 result r,
	 perform_result pr,
	 order_laboratory ol,
	 prsnl pl,
	 prsnl pl2
 
PLAN ce
WHERE ce.drawn_dt_tm BETWEEN CNVTDATETIME($bdate)
AND CNVTDATETIME($edate)
AND ce.event_type_cd = drawncd
JOIN c
WHERE ce.container_id = c.container_id
JOIN ca
WHERE c.container_id = ca.container_id
JOIN ocr
WHERE c.container_id = ocr.container_id
;AND ocr.catalog_cd = $ordername
JOIN o
WHERE ocr.order_id = o.order_id
AND operator(o.catalog_cd,testop,$test)
AND o.order_status_cd != cancelcd
JOIN elh
WHERE o.encntr_id = elh.encntr_id
AND operator(elh.loc_nurse_unit_cd,unitop,$unit)
;AND elh.loc_nurse_unit_cd = $unit ;2553912779.00
AND o.orig_order_dt_tm BETWEEN elh.beg_effective_dt_tm
AND elh.end_effective_dt_tm
AND elh.active_ind = 1
JOIN e
WHERE elh.encntr_id = e.encntr_id
AND e.organization_id = $facility
AND e.active_ind = 1
JOIN p
WHERE e.person_id = p.person_id
JOIN r
WHERE o.order_id = r.order_id
JOIN pr
WHERE r.result_id = pr.result_id
JOIN ol
WHERE o.order_id = ol.order_id
AND operator(ol.report_priority_cd,priorityop,$priority)
JOIN pl
WHERE pr.perform_personnel_id = pl.person_id
JOIN pl2
WHERE ce.drawn_id = pl2.person_id
 
ORDER BY o.order_id
 
HEAD REPORT
 
 
	cnt = 0
 	emerg = fillstring(20,' ')
HEAD o.order_id
 
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(a->qual, cnt + 9)
 
	endif
	a->qual[cnt].personid = p.person_id
	a->qual[cnt].encntrid = e.encntr_id
	a->qual[cnt].containerid = c.container_id
	a->qual[cnt].orderid = o.order_id
	a->qual[cnt].facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
	a->qual[cnt].ordername = TRIM(o.hna_order_mnemonic)
	a->qual[cnt].unit = UAR_GET_CODE_DISPLAY(elh.loc_nurse_unit_cd)
	a->qual[cnt].room = UAR_GET_CODE_DISPLAY(elh.loc_room_cd)
	a->qual[cnt].bed = UAR_GET_CODE_DISPLAY(elh.loc_bed_cd)
	a->qual[cnt].orderdttm = FORMAT(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].orderdatetm = o.orig_order_dt_tm
	a->qual[cnt].drawndttm = FORMAT(ce.drawn_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].drawndatetm = ce.drawn_dt_tm
	;a->qual[cnt].receiveddttm = FORMAT(ce.event_dt_tm, "mm/dd/yyyy hh:mm;;q")
	;a->qual[cnt].receiveddatetm = ce.received_dt_tm
	a->qual[cnt].name = TRIM(p.name_full_formatted)
	a->qual[cnt].perfdttm = FORMAT(pr.perform_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].perfdatetm = pr.perform_dt_tm
	a->qual[cnt].completedttm = FORMAT(pr.updt_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].completedatetm = pr.updt_dt_tm
	a->qual[cnt].elhbegeffdttm = FORMAT(elh.beg_effective_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].elhendeffdttm = FORMAT(elh.end_effective_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].priority = UAR_GET_CODE_DISPLAY(ol.report_priority_cd)
	a->qual[cnt].accessionnbr = 	cnvtacc(ca.accession)
	a->qual[cnt].resourcecd = pr.service_resource_cd
	a->qual[cnt].completedid = pl.person_id
	a->qual[cnt].completedby = TRIM(pl.name_full_formatted)
	a->qual[cnt].collectedid = pl2.person_id
	a->qual[cnt].collectedby = TRIM(pl2.name_full_formatted)
	emerg = CNVTUPPER(UAR_GET_CODE_DESCRIPTION(elh.loc_nurse_unit_cd))
	call echo(build('emerg :', emerg))
	;ed location check enc type
	if (FINDSTRING('EMERGENCY',emerg,1)> 0)
 
		if (elh.encntr_type_cd = ed)
			a->qual[cnt].printflg = 1
		endif
	else
		;if inpatient only, needs to be included
		a->qual[cnt].printflg = 1
 
	endif
	a->rec_cnt = cnt
 
FOOT REPORT
	stat = alterlist(a->qual, cnt)
 
WITH nocounter
 
 
;Get received in lab date/time
SELECT into 'nl:'
 
	contidevdt = BUILD(ce.container_id, FORMAT(ce.event_dt_tm, "mm/dd/yyyy hh:mm;;q"))
 
FROM (dummyt d with seq = a->rec_cnt),
	 container_event ce,
	 prsnl pr
 
PLAN d
JOIN ce
WHERE a->qual[d.seq].containerid = ce.container_id
ANd ce.event_type_cd = receivedcd
AND expand(idx,1,cplogins->rec_cnt,ce.current_location_cd,cplogins->qual[idx].codevalue)
JOIN pr
where ce.received_id = pr.person_id
 
ORDER BY contidevdt, ce.event_sequence
 
 
HEAD ce.specimen_id
 
	firstlogin = 0
 
DETAIL
 
	if (SIZE(a->qual[d.seq].receiveddttm) = 0)
	a->qual[d.seq].receiveddatetm	=	ce.event_dt_tm
	a->qual[d.seq].receiveddttm 	=	FORMAT(ce.event_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[d.seq].receivedby		=	TRIM(pr.name_full_formatted)
	a->qual[d.seq].receivedid		=	pr.person_id
 	endif
 
 	;firstlogin = 1
 
WITH nocounter
 
 
;FIN
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 encntr_alias ea
 
PLAN d
JOIN ea
WHERE a->qual[d.seq].encntrid = ea.encntr_id
AND ea.encntr_alias_type_cd = fin
AND ea.end_effective_dt_tm = CNVTDATETIME("31-dec-2100 0")
 
DETAIL
 
a->qual[d.seq].fin = TRIM(ea.alias)
 
 
WITH nocounter
 
 
;performed location
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 service_resource sr,
	 organization o
 
PLAN d
JOIN sr
WHERE a->qual[d.seq].resourcecd = sr.service_resource_cd
JOIN o
WHERE sr.organization_id = o.organization_id
 
DETAIL
 
	a->qual[d.seq].perflocation = TRIM(o.org_name)
 
WITH nocounter
 
 
;tat calculations
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt)
 
 
 
DETAIL
 
	a->qual[d.seq].ordtocolltat = DATETIMEDIFF(a->qual[d.seq].drawndatetm, a->qual[d.seq].orderdatetm,4)
	a->qual[d.seq].colltorecdtat = DATETIMEDIFF(a->qual[d.seq].receiveddatetm, a->qual[d.seq].drawndatetm,4)
	a->qual[d.seq].recdcomptat = DATETIMEDIFF(a->qual[d.seq].completedatetm, a->qual[d.seq].receiveddatetm,4)
 
 
 
WITH nocounter
 
 
 
CALL ECHORECORD(a)
 
 
SELECT into VALUE($OUTDEV)
 
	TestDescription = CONCAT(a->qual[d.seq].ordername,'                  '),
	Priority = a->qual[d.seq].priority,
	FIN = a->qual[d.seq].fin,
	AccNbr = a->qual[d.seq].accessionnbr,
	OrderLocation = CONCAT(a->qual[d.seq].unit,'                '),
	OrderDateTime = a->qual[d.seq].orderdttm,
	CollectedDateTime = a->qual[d.seq].drawndttm,
	OrdToCollTAT = a->qual[d.seq].ordtocolltat,
	CollectedBy = CONCAT(a->qual[d.seq].collectedby,'                           '),
	ReceivedDateTime = a->qual[d.seq].receiveddttm,
	CollectedToReceivedTAT = a->qual[d.seq].colltorecdtat,
	ReceivedBy = CONCAT(a->qual[d.seq].receivedby,'                         '),
	PerformedDateTime = a->qual[d.seq].perfdttm,
	CompletedDateTime = a->qual[d.seq].completedttm,
	ReceivedToCompletedTAT = a->qual[d.seq].recdcomptat,
	CompletedBy = CONCAT(a->qual[d.seq].completedby ,'                              '),
	PerformingLocation = CONCAT(a->qual[d.seq].perflocation,'                        '),
	printflg = a->qual[d.seq].printflg
 
 
 
FROM (dummyt d with seq = a->rec_cnt)
WHERE a->qual[d.seq].printflg = 1
 
ORDER BY TestDescription
 
WITH nocounter, FORMAT, SEPARATOR = ' '
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
