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
 0001  6/29/2020   Dawn Greer, DBA  For the Get Orders query made some tables
                                    be a left join so that orders that do not have
                                    results will show up.
 0002  6/30/2020   Dawn Greer, DBA  If no records found then just display a blank report
*************************************************************************************/
drop program cov_gl_test_count_drvr go
create program cov_gl_test_count_drvr
 
prompt
	"Output to File/Printer/MINE" = "MINE"             ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 3144499.00
	, "Select Ordering Laboratory" = 2553879881.00
	, "Select Performing Laboratory" = 2553879881.00
	, "Select Laboratory Department" = 0
	, "Select Test" = 0
	, "Select Encounter Type" = 0
	, "Select Begin Date/time" = "SYSDATE"
	, "Select End Date/Time" = "SYSDATE"
 
with OUTDEV, Facility, ordlab, perflab, actsubtype, test, enctype, begdate, enddate
 
execute reportrtl
%i cust_script:cov_gl_test_count_drvr.dvl
set d0 = InitializeReport(0)
 
/**************************************************************
; DECLARED RECORD STRUCTURES
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
; DVDev DECLARED VARIABLES
**************************************************************/
DECLARE perflabsql = vc WITH NOCONSTANT(FILLSTRING(500, ' ')), PROTECT
DECLARE instrumentsql = vc WITH NOCONSTANT(FILLSTRING(500, ' ')), PROTECT
DECLARE testsql = vc WITH NOCONSTANT(FILLSTRING(500, ' ')), PROTECT
DECLARE enctypesql = vc WITH NOCONSTANT(FILLSTRING(500, ' ')), PROTECT
DECLARE actsubtypesql = vc WITH NOCONSTANT(FILLSTRING(500, ' ')), PROTECT
DECLARE genlab = f8 WITH NOCONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',106,'GENERALLAB')), PROTECT
DECLARE bb = f8 WITH NOCONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',106,'BLOODBANK')), PROTECT
DECLARE micro = f8 WITH NOCONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',106,'MICRO')), PROTECT
DECLARE completed = f8 WITH NOCONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 14281,'COMPLETED')), PROTECT
DECLARE preliminary = f8 WITH NOCONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 14281,'PRELIMINARY')), PROTECT
DECLARE final = f8 WITH NOCONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 14281,'FINAL')), PROTECT
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
;Set up parsers
IF ($perflab = 1) ;all
	SET perflabsql = 'sr.location_cd > 0.0'
ELSE
	SET perflabsql = BUILD('sr.location_cd = ', $perflab)
ENDIF
 
IF ($actsubtype = 1)
	SET actsubtypesql = BUILD('oc.activity_subtype_cd IN (',2499.00,',', 2500.00,',',
	2501.00,',', 2507.00,',',2510.00,',',22789842.00,',', 2553776215.00,')')
ELSE
	SET actsubtypesql = BUILD('oc.activity_subtype_cd = ',$actsubtype)
ENDIF
 
IF ($test = 1)
	SET testsql = BUILD2('oc.catalog_cd > ',0.0,' AND ',actsubtypesql)
ELSE
	SET testsql = BUILD('oc.catalog_cd = ', $test)
ENDIF
 
IF ($enctype = 1)
	SET enctypesql = 'e.encntr_type_cd > 0.0'
ELSE
	SET enctypesql = BUILD('e.encntr_type_cd = ', $enctype)
ENDIF
 
CALL ECHO(BUILD2('actsubtypsql :', CHAR(9), actsubtypesql))
CALL ECHO(BUILD2('testsql :', CHAR(9), testsql))
CALL ECHO(BUILD2('enctypesql :', CHAR(9), enctypesql))
CALL ECHO(BUILD2('perflabsql :', CHAR(9), perflabsql))
 
/*********************************************************************
		Get Location
*********************************************************************/
SELECT INTO 'nl:'
FROM location l
WHERE l.organization_id = $facility
AND l.location_type_cd = 783.00
AND l.active_ind = 1
 
DETAIL
 	a->facility = UAR_GET_CODE_DISPLAY(l.location_cd)
WITH nocounter
 
/*********************************************************************
		Get Orders
*********************************************************************/
;0001 - Changed several tables to LEFT JOINS
SELECT INTO 'nl:'
FROM order_catalog oc
	,(INNER JOIN orders o ON (oc.catalog_cd = o.catalog_cd
		AND o.activity_type_cd IN (genlab, bb, micro)
		AND o.dept_status_cd IN (completed, preliminary, final)
		AND o.orig_order_dt_tm BETWEEN CNVTDATETIME($begdate)
			AND CNVTDATETIME($enddate)
		))
	,(INNER JOIN encounter e ON (o.encntr_id = e.encntr_id
		AND e.organization_id = $Facility
		AND PARSER(enctypesql)
		))
	,(LEFT JOIN orc_resource_list orl ON (o.catalog_cd = orl.catalog_cd
		AND orl.service_resource_cd IN (SELECT sr.service_resource_cd
			FROM service_resource sr WHERE parser(perflabsql)
			AND sr.service_resource_type_cd IN(823.00, 827.00))
		))
	,(LEFT JOIN result r ON (o.order_id = r.order_id
		AND orl.catalog_cd = r.catalog_cd
		))
	,(LEFT JOIN perform_result pr ON (r.result_id = pr.result_id
		AND orl.service_resource_cd = pr.service_resource_cd
		))
	,(LEFT JOIN service_resource sr ON (pr.service_resource_cd = sr.service_resource_cd
		AND sr.activity_type_cd IN (genlab, bb, micro)
		))
	,(LEFT JOIN location l ON (sr.location_cd = l.location_cd
		AND PARSER(perflabsql)
		))
WHERE parser(testsql)
ORDER BY o.catalog_cd, o.order_id, sr.service_resource_cd
 
HEAD REPORT
	cnt = 0
  
HEAD o.order_id
	cnt = cnt + 1
	IF (mod(cnt,10) = 1 OR cnt = 1)
 		stat = alterlist(a->oqual, cnt + 9)
 	ENDIF
 
 	a->oqual[cnt].catalogcd	=	o.catalog_cd
 	a->oqual[cnt].orderid	=	o.order_id
 	a->oqual[cnt].ordname	=	TRIM(o.hna_order_mnemonic)
 	a->oqual[cnt].instrument= 	UAR_GET_CODE_DISPLAY(sr.service_resource_cd)
 	a->oqual[cnt].perflab	=	UAR_GET_CODE_DISPLAY(sr.location_cd)
 	a->oqual[cnt].perflabcd = 	sr.location_cd
 	a->oqual[cnt].orgid		=	$facility
 	a->oqual[cnt].encntrid	=	e.encntr_id
 	a->oqual[cnt].containerid = pr.container_id
 	a->ordcnt 				=	cnt
 
	a->oqual[cnt].totalcnt = a->oqual[cnt].totalcnt + 1
 
 	IF (a->oqual[cnt].ordname = '.Indices')
  		CALL ECHO(BUILD(o.order_id,'|',a->oqual[cnt].instrument))
  	ENDIF
 
FOOT REPORT
	stat = alterlist(a->oqual, cnt)
WITH nocounter

CALL ECHORECORD(a)
;0002 - No Data
IF (a->ordcnt = 0)
	GO TO reportgen
ENDIF 

/*********************************************************************
		Get any orders that are parent of a careset.
		There will be no results posted for these orders.
*********************************************************************/
SELECT INTO 'nl:'
FROM order_catalog oc,
	 orders o,
	 encounter e
PLAN oc
WHERE parser(testsql)
JOIN o
WHERE o.orig_order_dt_tm BETWEEN CNVTDATETIME($begdate)
AND CNVTDATETIME($enddate)
AND oc.catalog_cd = o.catalog_cd
AND O.activity_type_cd IN (genlab, bb, micro)
AND O.dept_status_cd IN (completed, preliminary, final)
AND o.cs_flag IN (1.00, 4.00, 16.00)
JOIN e
WHERE o.encntr_id = e.encntr_id
AND e.organization_id = $Facility
AND PARSER(enctypesql)
 
HEAD REPORT
	cnt = a->ordcnt
DETAIL
	cnt = cnt + 1
	stat = alterlist(a->oqual, cnt)
 
	a->oqual[cnt].catalogcd	=	o.catalog_cd
 	a->oqual[cnt].orderid	=	o.order_id
 	a->oqual[cnt].ordname	=	TRIM(o.hna_order_mnemonic)
 	a->oqual[cnt].orgid		=	$facility
 	a->oqual[cnt].encntrid	=	e.encntr_id
 	a->ordcnt 				=	cnt
WITH nocounter
 
/*********************************************************************
		;Get Ordering Lab Info
*********************************************************************/
SELECT INTO 'nl:'
FROM (dummyt d WITH seq = a->ordcnt),
	 order_container_r ocr ,
	 container c,
	 collection_list cl
PLAN d
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
WITH nocounter
 
/*********************************************************************
	Get actual lab name instead of the service resource for the ordering lab
*********************************************************************/
SELECT INTO 'nl:'
FROM location l
WHERE l.location_type_cd = 791.00
AND l.active_ind = 1
 
HEAD REPORT
	lpos = 0
 
DETAIL
	FOR (cnt = 1 TO a->ordcnt)
		lpos = findstring('Laboratory',UAR_GET_CODE_DISPLAY(l.location_cd),1)
		IF (a->facility = substring(1,lpos-1,UAR_GET_CODE_DISPLAY(l.location_cd)))
 			a->oqual[cnt].ordlab = UAR_GET_CODE_DISPLAY(l.location_cd)
 		ELSEIF (a->facility = 'PW')
 			a->oqual[cnt].ordlab = 'PWMC Laboratory'
 		ENDIF
	ENDFOR
WITH nocounter

#reportgen
 
/*********************************************************************
	Get lab totals
*********************************************************************/
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
	IF (mod(cnt,10) = 1 OR cnt = 1)
		stat = alterlist(labtotals->qual, cnt + 9)
	ENDIF
 
	labtotals->qual[cnt].ordlab	= ordlab 
	labtotals->rec_cnt = cnt
	pcnt	=	0
	 
HEAD perflab
	pcnt = pcnt + 1
	IF (mod(pcnt,10) = 1 OR pcnt = 1)
		stat = alterlist(labtotals->qual[cnt].plabqual, pcnt + 9)
	ENDIF
 
	labtotals->qual[cnt].plabqual[pcnt].perflab = perflab
	labtotals->qual[cnt].perfcnt = pcnt
	icnt	=	0
 
HEAD instrument
	icnt = icnt + 1
	IF (mod(icnt,10) = 1 OR icnt = 1)
		stat = alterlist(labtotals->qual[cnt].plabqual[pcnt].instqual, icnt + 9)
	ENDIF
 
	labtotals->qual[cnt].plabqual[pcnt].instqual[icnt].instrument = instrument
	labtotals->qual[cnt].plabqual[pcnt].instcnt	= icnt
	tcnt = 0
	prevtestname = fillstring(30,' ')
	currtestname = fillstring(30,' ')
 
DETAIL
	currtestname = test
	IF (currtestname != prevtestname OR tcnt = 0)
		tcnt = tcnt + 1
 
		IF (mod(tcnt,10) = 1 OR tcnt = 1)
 			stat = alterlist(labtotals->qual[cnt].plabqual[pcnt].instqual[icnt].testqual, tcnt + 9)
 		ENDIF
	ENDIF
 
	labtotals->qual[cnt].plabqual[pcnt].instqual[icnt].testqual[tcnt].testname = test
	labtotals->qual[cnt].plabqual[pcnt].instqual[icnt].testqual[tcnt].tottestcnt =
		labtotals->qual[cnt].plabqual[pcnt].instqual[icnt].testqual[tcnt].tottestcnt + 1
 
	labtotals->qual[cnt].plabqual[pcnt].instqual[icnt].testcnt = tcnt
 
	prevtestname = test
 
FOOT instrument
 
	FOR (scnt = 1 TO tcnt)
		labtotals->qual[cnt].plabqual[pcnt].instqual[icnt].tottests =
		labtotals->qual[cnt].plabqual[pcnt].instqual[icnt].tottests +
		labtotals->qual[cnt].plabqual[pcnt].instqual[icnt].testqual[scnt].tottestcnt
 
	ENDFOR
 
	stat = alterlist(labtotals->qual[cnt].plabqual[pcnt].instqual[icnt].testqual,tcnt)
 
FOOT perflab
	FOR (cntr = 1 TO icnt)
		FOR (tcnt = 1 TO labtotals->qual[cnt].plabqual[pcnt].instqual[cntr].testcnt)
			labtotals->qual[cnt].plabqual[pcnt].tottests = labtotals->qual[cnt].plabqual[pcnt].tottests +
			labtotals->qual[cnt].plabqual[pcnt].instqual[cntr].testqual[tcnt].tottestcnt
 
		ENDFOR
	ENDFOR
 
	stat = alterlist(labtotals->qual[cnt].plabqual[pcnt].instqual,icnt)
FOOT ordlab
	FOR (pcntr = 1 TO labtotals->qual[cnt].perfcnt)
		labtotals->qual[cnt].tottests = labtotals->qual[cnt].tottests + labtotals->qual[cnt].plabqual[pcntr].tottests
	ENDFOR
 
	stat = alterlist(labtotals->qual[cnt].plabqual,pcnt)
FOOT report
	stat = alterlist(labtotals->qual,cnt)
WITH nocounter

CALL ECHORECORD(labtotals)
/*********************************************************************
	Produce Report
*********************************************************************/
SELECT INTO 'nl:'
 
FROM (dummyt d WITH seq = labtotals->rec_cnt),
	 (dummyt d2 WITH seq = 1),
	 (dummyt d3 WITH seq = 1)
PLAN d
WHERE MAXREC(d2,labtotals->qual[d.seq].perfcnt)
JOIN d2
WHERE MAXREC(d3, labtotals->qual[d.seq].plabqual[d2.seq].instcnt)
JOIN d3
 
HEAD REPORT
	d0 = HeadReportSection(Rpt_Render)
	ordlab = fillstring(30,' ')
	perflab = fillstring(30,' ')
	instrument = fillstring(30,' ')
	testcount = 0
 
HEAD PAGE
	IF (curpage > 1)
		d0 = PageBreak(0)
	ENDIF
 
	d0 = HeadPageSection(Rpt_Render)
 
DETAIL
   IF (a->ordcnt > 0)
	FOR (cnt = 1 TO labtotals->qual[d.seq].plabqual[d2.seq].instqual[d3.seq].testcnt)
	IF (_YOffset + DetailSection(Rpt_CalcHeight) + HeadLabelSection(Rpt_CalcHeight) > 10.0)
		BREAK
	ENDIF
 
	IF (ordlab != labtotals->qual[d.seq].ordlab OR
		perflab != labtotals->qual[d.seq].plabqual[d2.seq].perflab
		OR instrument != labtotals->qual[d.seq].plabqual[d2.seq].instqual[d3.seq].instrument)
 			d0 = HeadLabelSection(Rpt_Render)
	ENDIF
 
 	testcount = labtotals->qual[d.seq].plabqual[d2.seq].instqual[d3.seq].testqual[cnt].tottestcnt
	d0 = DetailSection(Rpt_Render)

	ordlab = labtotals->qual[d.seq].ordlab
	perflab = labtotals->qual[d.seq].plabqual[d2.seq].perflab
	instrument = labtotals->qual[d.seq].plabqual[d2.seq].instqual[d3.seq].instrument
 	ENDFOR
   ENDIF
FOOT PAGE
 	if (_yOffset < 10)
 		_yOffset = 10
 	endif
	d0 = FootPageSection(Rpt_Render)
WITH nocounter
 
SET d0 = FinalizeReport($outdev)
 
CALL ECHORECORD(LABTOTALS)
GO TO exitscript
 
#exitscript
 
end
go
 