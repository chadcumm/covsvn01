/**********************************************************************************
Author		 	:	Mike Layman
Date Written 	:	07/06/18
Program Title	:	Test Count Report
Source File	 	:	cov_gl_test_count_drvr.prg
Object Name		:	cov_gl_test_count_drvr
Directory	 	:  	cust_script
DVD version  	:  	2017.11.1.81
HNA version  	:   01Oct2012
CCL version  	:   8.8.3
Purpose      	:	This script will serve as a driver script
					for a layout report. This will select any
					tests that were posted for
					the parameters that are passed to the
					program in the prompts.
 
Tables Read  	:
Tables
Updated      	:
Include		 	:
Files
Shell        	:
Scripts
Executing
Application  	:
Special Notes	:
Usage        	:
 
*********************************************************************
                MODIFICATION CONTROL LOG
*********************************************************************
 
 Mod   Date        Engineer          Comment
 ----  ----------- ---------------- ---------------------------
 
 
*************************************************************************************/
drop program cov_gl_test_count_drvr go
create program cov_gl_test_count_drvr
 
prompt
	"Output to File/Printer/MINE" = "MINE"             ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 3144499.00
	, "Select Ordering Laboratory" = 2553879881.00
	, "Select Performing Laboratory" = 2553879881.00
	, "Select Instrument" = 0
	, "Select Test" = 0
	, "Select Encounter Type" = 0
	, "Select Begin Date/time" = "SYSDATE"
	, "Select End Date/Time" = "SYSDATE"
 
with OUTDEV, Facility, ordlab, perflab, Instrument, test, enctype, begdate, enddate
 
execute reportrtl
%i cust_script:cov_gl_test_count_drvr.dvl
set d0 = InitializeReport(0)
 
 
 
/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
**************************************************************/
 
FREE RECORD tests
RECORD tests
(
1	rec_cnt		=	i4
1	instbench	=	vc
1	qual[*]
	2	testname	=	vc
	2	dtacd		=	f8
)
 
 
 
 
;FREE RECORD a
RECORD a
(
1	rec_cnt		=	i4
1	facility	=	vc
1	qual[*]
	2	DTAname		=	vc
	2	DTAcd		=	f8
	2	tcnt	=	i4
	2	tqual[*]
		3	resultid	=	f8
		3	orderid		=	f8
		3	containerid		=	f8
		3	coll_listid		=	f8
1	ordcnt		=	i4
1	oqual[*]
	2	ordname			=	vc
	2	orderid			=	f8
	2	catalogcd		=	f8
	2	totalcnt		=	i4
	2	ordlab			=	vc
	2	perflab			=	vc
	2	instrument		=	vc
	2	containerid		=	f8
	2	orgid			=	f8
	2	encntrid		=	f8
	2	perflabcd		=	f8
	2	ordlabcd		=	f8
 
 
)
 
FREE RECORD labtotals
RECORD labtotals
(
1	rec_cnt		=	i4
1	qual[*]
	2	ordlab	=	vc
	2	tottests	=	i4
	2	perfcnt	=	i4
	2	plabqual[*]
		3	perflab	=	vc
		3	tottests =	i4
		3	instcnt	=	i4
		3	instqual[*]
			4	instrument	=	vc
			4	tottests	=	i4
			4	testcnt		=	i4
			4	testqual[*]
				5	testname	=	vc
				5	tottestcnt	=	i4
 
 
)
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
DECLARE perflabsql = vc WITH NOCONSTANT(FILLSTRING(500, ' ')), PROTECT
DECLARE instrumentsql = vc WITH NOCONSTANT(FILLSTRING(500, ' ')), PROTECT
DECLARE testsql = vc WITH NOCONSTANT(FILLSTRING(500, ' ')), PROTECT
DECLARE enctypesql = vc WITH NOCONSTANT(FILLSTRING(500, ' ')), PROTECT
DECLARE genlab = f8 WITH NOCONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',106,'GENERALLAB')), PROTECT
DECLARE bb = f8 WITH NOCONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',106,'BLOODBANK')), PROTECT
DECLARE micro = f8 WITH NOCONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',106,'MICRO')), PROTECT
DECLARE completed = f8 WITH NOCONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 14281,'COMPLETED')), PROTECT
DECLARE preliminary = f8 WITH NOCONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 14281,'PRELIMINARY')), PROTECT
DECLARE final = f8 WITH NOCONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 14281,'FINAL')), PROTECT
;DECLARE ordlab = vc WITH NOCONSTANT(FILLSTRING(30,' ')), PROTECT
;DECLARE perflab = vc WITH NOCONSTANT(FILLSTRING(30,' ')), PROTECT
;DECLARE instrument = vc WITH NOCONSTANT(FILLSTRING(30,' ')), PROTECT
;DECLARE test = vc WITH NOCONSTANT(FILLSTRING(30,' ')), PROTECT
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
;Set up parsers
if ($perflab = 1) ;all
 
	SET perflabsql = 'sr.location_cd > 0.0'
 
else
	SET perflabsql = BUILD('sr.location_cd = ', $perflab)
 
endif
 
if ($instrument = 1)
	SET instrumentsql = 'orl.service_resource_cd > 0.0'
else
	SET instrumentsql = BUILD('orl.service_resource_cd = ', $instrument)
 
endif
 
if ($test = 1)
 
	SET testsql = 'o.catalog_cd > 0.0'
 
 
else
 
	SET testsql = BUILD('o.catalog_cd = ', $test)
 
endif
 
if ($enctype = 1)
	SET enctypesql = 'e.encntr_type_cd > 0.0'
else
	SET enctypesql = BUILD('e.encntr_type_cd = ', $enctype)
endif
 
 
;Get all tests for requested resource
SELECT into 'nl:'
	dta = UAR_GET_CODE_DISPLAY(apr.task_assay_cd)
FROM assay_processing_r apr
 
WHERE apr.service_resource_cd = $instrument
AND apr.active_ind = 1
 
ORDER BY dta
 
HEAD REPORT
	cnt = 0
	tests->instbench	=	UAR_GET_CODE_DISPLAY($instrument)
DETAIL
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(tests->qual, cnt + 9)
 
	endif
	tests->qual[cnt].testname	=	dta
	tests->qual[cnt].dtacd		=	apr.task_assay_cd
	tests->rec_cnt				=	cnt
FOOT REPORT
	stat = alterlist(tests->qual, cnt)
 
WITH nocounter
 
;CALL ECHORECORD(tests)
 
SELECT into 'nl:'
 
FROM location l
WHERE l.organization_id = $facility
AND l.location_type_cd = 783.00
AND l.active_ind = 1
 
DETAIL
 
	a->facility = UAR_GET_CODE_DISPLAY(l.location_cd)
WITH nocounter
 
 
;Get Orders
 
SELECT into 'nl:'
 
FROM orders o,
	 encounter e,
	 orc_resource_list orl,
	 service_resource sr,
	 location l
 
PLAN o
WHERE o.orig_order_dt_tm BETWEEN CNVTDATETIME($begdate)
AND CNVTDATETIME($enddate)
AND parser(testsql) ;o.catalog_cd
AND O.activity_type_cd IN (genlab, bb, micro)
AND O.dept_status_cd iN (completed, preliminary, final)
JOIN e
WHERE o.encntr_id = e.encntr_id
AND e.organization_id = $Facility
AND PARSER(enctypesql)
JOIN orl
WHERE o.catalog_cd = orl.catalog_cd
AND PARSER(instrumentsql)
JOIN sr
WHERE orl.service_resource_cd = sr.service_resource_cd
AND sr.activity_type_cd IN (genlab, bb, micro)
JOIN l
WHERE sr.location_cd = l.location_cd
AND PARSER(perflabsql)
 
ORDER BY o.catalog_cd, o.order_id
 
HEAD REPORT
	cnt = 0
 
HEAD o.catalog_cd ;DETAIL
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(a->oqual, cnt + 9)
 
	endif
 	a->oqual[cnt].catalogcd	=	o.catalog_cd
 	a->oqual[cnt].orderid	=	o.order_id
 	a->oqual[cnt].ordname	=	TRIM(o.hna_order_mnemonic)
 	a->oqual[cnt].instrument= 	UAR_GET_CODE_DISPLAY(sr.service_resource_cd)
 	a->oqual[cnt].perflab	=	UAR_GET_CODE_DISPLAY(sr.location_cd)
 	a->oqual[cnt].perflabcd = 	sr.location_cd
 	a->oqual[cnt].orgid		=	$facility
 	a->oqual[cnt].encntrid	=	e.encntr_id
 	a->ordcnt 				=	cnt
HEAD o.order_id
	a->oqual[cnt].totalcnt = a->oqual[cnt].totalcnt + 1
 
FOOT REPORT
 
	stat = alterlist(a->oqual, cnt)
 
 
WITH nocounter
 
 
;Get Ordering Lab Info
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->ordcnt),
	 ;location l
	 order_container_r ocr ,
	 container c,
	 collection_list cl
 
PLAN d
;JOIN l
;WHERE
;a->oqual[d.seq].orgid = l.organization_id
;AND l.location_type_cd = 791.00
;AND l.active_ind = 1
JOIN ocr
WHERE a->oqual[d.seq].orderid = ocr.order_id
JOIN c
WHERE ocr.container_id = c.container_id
JOIN cl
WHERE outerjoin(c.collection_list_id) = cl.collection_list_id
 
DETAIL
	a->oqual[d.seq].containerid = c.container_id
	IF (c.collection_list_id > 0.0)
 
		a->oqual[d.seq].ordlab =  UAR_GET_CODE_DISPLAY(cl.from_location_cd)
		a->oqual[d.seq].ordlabcd = cl.from_location_cd
 
	ELSE
 
		a->oqual[d.seq].ordlab = UAR_GET_CODE_DISPLAY(c.current_location_cd)
		a->oqual[d.seq].ordlabcd = c.current_location_cd
 
	ENDIF
 
 	;a->oqual[d.seq].ordlab = UAR_GET_CODE_DISPLAY(l.location_cd)
 
WITH nocounter
 
 
;Get actual lab name instead of the service resource for the ordering lab
SELECT into 'nl:'
 
FROM location l
WHERE l.location_type_cd = 791.00
AND l.active_ind = 1
 
HEAD REPORT
	lpos = 0
 
DETAIL
 
	FOR (cnt = 1 to a->ordcnt)
		lpos = findstring('Laboratory',UAR_GET_CODE_DISPLAY(l.location_cd),1)
		IF (a->facility = substring(1,lpos-1,UAR_GET_CODE_DISPLAY(l.location_cd)))
 
			a->oqual[cnt].ordlab = UAR_GET_CODE_DISPLAY(l.location_cd)
 
		ENDIF
 
 
	ENDFOR
 
 
 
WITH nocounter
 
 
 
;Get lab totals
 
SELECT INTO 'NL:'
	ordlab = CONCAT(a->oqual[d.seq].ordlab,'                        '),
	perflab = CONCAT(a->oqual[d.seq].perflab,'                        '),
	instrument = CONCAT(a->oqual[d.seq].instrument,'                    '),
	test = CONCAT(a->oqual[d.seq].ordname,'                                          ')
 
FROM (dummyt d with seq = a->ordcnt)
 
ORDER BY ordlab, perflab, instrument, test
 
 
HEAD REPORT
	cnt = 0
HEAD ordlab
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(labtotals->qual, cnt + 9)
 
	endif
	labtotals->qual[cnt].ordlab	=	ordlab
	labtotals->rec_cnt			=	cnt
	pcnt	=	0
HEAD perflab
	pcnt = pcnt + 1
	if (mod(pcnt,10) = 1 or pcnt = 1)
 
		stat = alterlist(labtotals->qual[cnt].plabqual, pcnt + 9)
 
	endif
	labtotals->qual[cnt].plabqual[pcnt].perflab = perflab
	labtotals->qual[cnt].perfcnt		=	pcnt
	icnt	=	0
HEAD instrument
	icnt = icnt + 1
	if (mod(icnt,10) = 1 or icnt = 1)
 
		stat = alterlist(labtotals->qual[cnt].plabqual[pcnt].instqual, icnt + 9)
 
	endif
	labtotals->qual[cnt].plabqual[pcnt].instqual[icnt].instrument = instrument
	labtotals->qual[cnt].plabqual[pcnt].instcnt	=	icnt
	tcnt = 0
	prevtestname = fillstring(30,' ')
	currtestname = fillstring(30,' ')
DETAIL;HEAD test
	currtestname = test
	if (currtestname != prevtestname OR tcnt = 0)
		tcnt = tcnt + 1
 
 
 
		if (mod(tcnt,10) = 1 or tcnt = 1)
 
			stat = alterlist(labtotals->qual[cnt].plabqual[pcnt].instqual[icnt].testqual, tcnt + 9)
 
		endif
	endif
 
 
		labtotals->qual[cnt].plabqual[pcnt].instqual[icnt].testqual[tcnt].testname	=	test
		labtotals->qual[cnt].plabqual[pcnt].instqual[icnt].testqual[tcnt].tottestcnt =
		labtotals->qual[cnt].plabqual[pcnt].instqual[icnt].testqual[tcnt].tottestcnt + 1
 
		labtotals->qual[cnt].plabqual[pcnt].instqual[icnt].testcnt	=	tcnt
 
		prevtestname = test
 
FOOT instrument
	labtotals->qual[cnt].plabqual[pcnt].instqual[icnt].tottests = tcnt
	stat = alterlist(labtotals->qual[cnt].plabqual[pcnt].instqual[icnt].testqual,tcnt)
 
FOOT perflab
	FOR (cntr = 1 to icnt)
		FOR (tcnt = 1 to labtotals->qual[cnt].plabqual[pcnt].instqual[cntr].testcnt)
			labtotals->qual[cnt].plabqual[pcnt].tottests =
			labtotals->qual[cnt].plabqual[pcnt].tottests + 1
 
		ENDFOR
	ENDFOR
	;labtotals->qual[cnt].plabqual[pcnt].tottests = tcnt * icnt
	stat = alterlist(labtotals->qual[cnt].plabqual[pcnt].instqual,icnt)
FOOT ordlab
	FOR (pcntr = 1 to labtotals->qual[cnt].perfcnt)
 
		labtotals->qual[cnt].tottests = labtotals->qual[cnt].tottests + labtotals->qual[cnt].plabqual[pcntr].tottests
 
	ENDFOR
	;labtotals->qual[cnt].tottests = labtotals->qual[cnt].perfcnt * labtotals->qual[cnt].plabqual[pcnt].tottests
	stat = alterlist(labtotals->qual[cnt].plabqual,pcnt)
FOOT report
 
	stat = alterlist(labtotals->qual,cnt)
 
WITH nocounter
 
 
 
;CALL ECHORECORD(labtotals)
;GO TO exitscript
 
;CALL ECHORECORD(a)
;GO TO exitscript
;
;
;SELECT into 'nl:'
;
;FROM result r,
;	 perform_result pr,
;	 service_resource sr,
;	 container c,
;	 collection_list cl
;
;PLAN r
;WHERE r.task_assay_cd = $test
;JOIN pr
;WHERE r.result_id = pr.result_id
;AND pr.perform_dt_tm BETWEEN CNVTDATETIME($begdate)
;AND CNVTDATETIME($enddate)
;AND pr.service_resource_cd = $Instrument
;JOIN sr
;WHERE pr.service_resource_cd = sr.service_resource_cd
;AND sr.location_cd = $perflab
;JOIN c
;WHERE OUTERJOIN(pr.container_id) = c.container_id
;JOIN cl
;WHERE outerjoin(c.collection_list_id) = cl.collection_list_id
;
;HEAD REPORT
;
;	cnt = 0
;
;HEAD r.task_assay_cd
;	cnt = cnt + 1
;	if (mod(cnt,10) = 1 or cnt = 1)
;
;		stat = alterlist(a->qual, cnt + 9)
;
;	endif
;	;a->facility				=	UAR_GET_CODE_DISPLAY(0.0)
;	a->qual[cnt].DTAname	=	UAR_GET_CODE_DISPLAY(r.task_assay_cd)
;	a->qual[cnt].DTAcd		=	r.task_assay_cd
;	a->rec_cnt				=	cnt
;	tcnt					=	0
;DETAIL
;
;	if ($ordlab = $perflab)
;
;	tcnt = tcnt + 1
;	if (mod(tcnt,10) = 1 or tcnt = 1)
;
;		stat = alterlist(a->qual[cnt].tqual, tcnt + 9)
;
;	endif
;	a->qual[cnt].tqual[tcnt].resultid 	= r.result_id
;	a->qual[cnt].tqual[tcnt].orderid	= r.order_id
;	a->qual[cnt].tqual[tcnt].containerid = pr.container_id
;	a->qual[cnt].tcnt					= tcnt
;
;	else
;		if ($ordlab = cl.from_location_cd)
;			tcnt = tcnt + 1
;			if (mod(tcnt,10) = 1 or tcnt = 1)
;
;				stat = alterlist(a->qual[cnt].tqual, tcnt + 9)
;
;			endif
;			a->qual[cnt].tqual[tcnt].resultid 	= r.result_id
;			a->qual[cnt].tqual[tcnt].orderid	= r.order_id
;			a->qual[cnt].tqual[tcnt].containerid = pr.container_id
;			a->qual[cnt].tcnt					= tcnt
;
;
;		endif
;	endif
;FOOT r.task_assay_cd
;	stat = alterlist(a->qual[cnt].tqual, tcnt)
;FOOT REPORT
;	stat = alterlist(a->qual, cnt)
;WITH nocounter
 
 
SELECT into 'nl:'
 
FROM (dummyt d with seq = labtotals->rec_cnt),
	 (dummyt d2 with seq = 1),
	 (dummyt d3 with seq = 1),
	 (dummyt d4 with seq = 1)
 
PLAN d
WHERE MAXREC(d2,labtotals->qual[d.seq].perfcnt)
JOIN d2
WHERE MAXREC(d3, labtotals->qual[d.seq].plabqual[d2.seq].instcnt)
JOIN d3
WHERE MAXREC(d4, labtotals->qual[d.seq].plabqual[d2.seq].instqual[d3.seq].testcnt)
JOIN d4
 
 
HEAD REPORT
 
	d0 = HeadReportSection(Rpt_Render)
	ordlab = fillstring(30,' ')
	perflab = fillstring(30,' ')
	instrument = fillstring(30,' ')
HEAD PAGE
	
	if (curpage > 1)
 
		d0 = PageBreak(0)
 
	endif
	d0 = HeadPageSection(Rpt_Render)
DETAIL
	if (_YOffset + DetailSection(Rpt_CalcHeight) + HeadLabelSection(Rpt_CalcHeight) > 10.0)
		BREAK
	endif
 
	if (ordlab != labtotals->qual[d.seq].ordlab OR
		perflab != labtotals->qual[d.seq].plabqual[d2.seq].perflab
		OR instrument != labtotals->qual[d.seq].plabqual[d2.seq].instqual[d3.seq].instrument)
 
			d0 = HeadLabelSection(Rpt_Render)
	endif
 
	d0 = DetailSection(Rpt_Render)
	ordlab = labtotals->qual[d.seq].ordlab
	perflab = labtotals->qual[d.seq].plabqual[d2.seq].perflab
	instrument = labtotals->qual[d.seq].plabqual[d2.seq].instqual[d3.seq].instrument
 
FOOT PAGE
 	if (_yOffset < 10)
 		_yOffset = 10
 	endif
	d0 = FootPageSection(Rpt_Render)
WITH nocounter
 
 
 
SET d0 = FinalizeReport($outdev)
 
 
 
 
CALL ECHORECORD(labtotals)
GO TO exitscript
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript
 
end
go
 
