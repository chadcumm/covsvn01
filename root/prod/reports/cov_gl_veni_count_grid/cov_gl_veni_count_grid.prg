/***********************************************************
Author 			:	Mike Layman
Date Written	:	10/31/2017
Program Title	:	Venipuncture Count Grid View
Source File		:	cov_gl_veni_count_grid.prg
Object Name		:	cov_gl_veni_count_grid
Directory		:	cust_script
DVD Version		:	2017.07.1.81
HNA Version		:	2015.01
CCL Version		:	8.8.3
Purpose			: 	This program will display the venipuncture count
					that was performed given the parameters that are
					passed to the program
Tables Read		:	person, encounter, encntr_alias, person_alias,
					orders, order_action, container,
					container_event
Tables Updated	:	NA
Include File	:	NA
Shell Scripts	:	NA
Executing App	:	Report Portal
Special Notes	:
Usage			:	cov_gl_veni_count "mine" go
Mod		Date		Engineer				Comment
----    ----------- ----------------------- ---------------------------
001		10/31/2017	Mike Layman				Original Release
002     09/08/2020  Dawn Greer, DBA         CR 8403 - Add Order Location
003     09/25/2020  Dawn Greer, DBA         CR 8609 - Add Order Location
                                            to Summary.  Fix missing
                                            collect/drawn time and
                                            missing order location. Add
                                            documentation, and removed
                                            commented out code.
004     09/30/2020  Dawn Greer, DBA         CR 8609 - Change Order Location
                                            to Collected Location.  Remove
                                            variables and assign values to
                                            query.
*************************************************************************/
drop program cov_gl_veni_count_grid go
create program cov_gl_veni_count_grid
 
prompt
	"Output to File/Printer/MINE " = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 0
	, "Select Begin Date" = "SYSDATE"         ;* Please choose the date the test was performed, not ordered.
	, "Seelct End Date" = "SYSDATE"           ;* Please choose the date the test was performed, not ordered.
	, "Select Summary or Detail" = 0
 
with OUTDEV, facility, bdate, edate, sumdet
 
/**************************************************************
	RECORD STRUCTURE
**************************************************************/
FREE RECORD a
RECORD a
(
	1	rec_cnt		=	i4
	1	totNbrVeni	=	i4
	1	qual[*]
		2	facility	=	vc
		2	personid	=	f8
		2	encntrid	=	f8
		2	orderid		=	f8
		2	containerid	=	f8
		2	name		=	vc
		2	accession	=	vc
		2 	colldttm	=	vc
		2	colldate	=	f8
		2	collprsnl	=	vc
		2	collprsnlid	=	f8
		2	spectype	=	vc
		2	ordname		=	vc
		2	fin			=	vc
		2	vpcountgrp	=	i4
		2   collect_loc =   vc
)
 
FREE RECORD totals		;004
RECORD totals
(
	1 rec_cnt = i4
	1 qual[*]
		2 collect_loc = vc
		2 loc_cnt = i4
)
 
/**************************************************************
; DECLARED VARIABLES
**************************************************************/
DECLARE facprsr = vc WITH NOCONSTANT(FILLSTRING(500,' ')), PROTECT
 
/*************************************************************
;combine pw facilities
**************************************************************/
IF ($facility = 3144503.00)
 
	SET facprsr = BUILD2('o.encntr_id = e.encntr_id AND ',
	'e.organization_id IN (',$facility,',',3234074.00,',',3234068.00,')')
ELSE
	SET facprsr = BUILD2('o.encntr_id = e.encntr_id AND e.organization_id = ', $facility)
ENDIF
 
CALL ECHO(build('facprsr :',facprsr))
 
/**********************************************************
Get Order Data
***********************************************************/
 
SELECT INTO 'nl:'
	drawn_dt = FORMAT(ce.drawn_dt_tm, "mm/dd/yyyy hh:mm;;q") ;For the Order By
 
FROM container_event ce,
	 container c,
	 order_container_r ocr,
	 accession_order_r aor,
	 orders o,
	 encounter e,
	 person p,
	 prsnl pr,
	 encntr_alias ea
 
PLAN ce
WHERE ce.drawn_dt_tm BETWEEN CNVTDATETIME($bdate)	;003
AND CNVTDATETIME($edate)
AND ce.event_type_cd = 1794.00 /*COLLECTED*/	;004
AND ce.collection_method_cd IN (1774.00 /*VENOUSDRAW*/, 1770.00 /*ARTERIALDRAW*/, ;004
	 2553672549.00 /*HEELSTICK*/, 1771.00 /*CAPILLARY*/)	;004
JOIN c
WHERE ce.container_id = c.container_id
AND c.specimen_type_cd = 1765.00 /*BLOOD*/	;004
JOIN ocr
WHERE c.container_id = ocr.container_id
JOIN aor
WHERE ocr.order_id = aor.order_id
JOIN o
WHERE ocr.order_id = o.order_id
JOIN e
WHERE parser(facprsr)
JOIN p
WHERE e.person_id = p.person_id
AND p.active_ind = 1
JOIN pr
WHERE ce.drawn_id = pr.person_id
JOIN ea
WHERE e.encntr_id = ea.encntr_id
AND ea.encntr_alias_type_cd = 1077 /*FIN*/	;004
AND ea.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")
ORDER BY drawn_dt
 
HEAD REPORT
 
	cnt = 0
 
DETAIL
	cnt = cnt + 1
	IF (mod(cnt,10) = 1 OR cnt = 1)
		stat = alterlist(a->qual, cnt + 9)
	ENDIF
 
	a->qual[cnt].colldttm 	= 	FORMAT(ce.drawn_dt_tm, "mm/dd/yyyy hh:mm;;q") ;003
	a->qual[cnt].colldate	= 	ce.drawn_dt_tm		;003
	a->qual[cnt].collprsnlid=	pr.person_id
	a->qual[cnt].orderid	=	ocr.order_id
	a->qual[cnt].collect_loc =  TRIM(UAR_GET_CODE_DISPLAY(ce.current_location_cd),3)	;004
	a->qual[cnt].spectype	=	UAR_GET_CODE_DISPLAY(c.specimen_type_cd)
	a->qual[cnt].accession	=	CNVTACC(aor.accession)
	a->qual[cnt].ordname	=	UAR_GET_CODE_DISPLAY(o.catalog_cd)
	a->qual[cnt].containerid=	c.container_id
	a->qual[cnt].personid	=	o.person_id
	a->qual[cnt].encntrid	=	e.encntr_id
	a->qual[cnt].name		=	TRIM(p.name_full_formatted)
	a->qual[cnt].collprsnl	=	TRIM(pr.name_full_formatted)
	a->qual[cnt].fin		=	TRIM(ea.alias)
	a->qual[cnt].facility	=	UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
	a->rec_cnt				=	cnt
 
FOOT REPORT
	stat = alterlist(a->qual, cnt )
 
WITH nocounter
 
/*********************************************************************
;Count venipunctures
**********************************************************************/
 
SELECT INTO 'nl:'
FROM(dummyt d WITH seq = a->rec_cnt)
 
HEAD REPORT
	origcolldt = fillstring(16,' ')
	newcolldt  = fillstring(16,' ')
	origprsnl  = 0.0
	newprsnl   = 0.0
	cnt = 0
 
DETAIL
	newcolldt = a->qual[d.seq].colldttm
	newprsnl  = a->qual[d.seq].collprsnlid
	CALL ECHO(BUILD('origcolldt :', origcolldt))
	CALL ECHO(BUILD('newcolldt :', newcolldt))
 
	CALL ECHO(BUILD('origprsnl :', origprsnl))
	CALL ECHO(BUILD('newprsnl :', newprsnl))
 
	CALL ECHO(BUILD('cnt :', cnt))
 
	IF (origcolldt != newcolldt )
		IF ((origprsnl = 0.0 AND newprsnl = 0.0) OR (origprsnl != newprsnl))
			cnt = cnt + 1
		ENDIF
	ELSEIF (origcolldt = newcolldt)
		IF ((origprsnl = 0.0 AND newprsnl = 0.0) OR (origprsnl != newprsnl))
			cnt = cnt + 1
		ENDIF
	ENDIF
	a->qual[d.seq].vpcountgrp = cnt
	origcolldt = a->qual[d.seq].colldttm
	origprsnl  = a->qual[d.seq].collprsnlid
 
FOOT REPORT
	a->totNbrVeni = cnt
 
WITH nocounter
 
 
/***************************************************************************
	Output Detail Report or Summary Report
****************************************************************************/
 
IF($sumdet = 0)	;Summary Report
 
	SELECT INTO $outdev
 
		dateRange = BUILD2(FORMAT(CNVTDATETIME($bdate),"mm/dd/yyyy hh:mm;;q"), ' - ',
		FORMAT(CNVTDATETIME($edate), "mm/dd/yyyy hh:mm;;q")),
		VenipunctureTotal = a->totNbrVeni
 
	FROM (dummyt d with seq = 1)
 
	WITH nocounter, format, separator = ' '
 
ELSE		;Detail Report
	SELECT INTO $outdev
		facility = CONCAT(a->qual[d.seq].facility,'                       '),
		name = concat(a->qual[d.seq].name,'                                   '),
		fin = a->qual[d.seq].fin,
		accession = a->qual[d.seq].accession,
		ordername = concat(a->qual[d.seq].ordname,'                             '),
		collectloc = a->qual[d.seq].collect_loc,		;004
		colldate = concat(a->qual[d.seq].colldttm,'                '),
		collprsnl = concat(a->qual[d.seq].collprsnl,'                      '),
		grpcount = a->qual[d.seq].vpcountgrp
	FROM (dummyt d WITH seq = a->rec_cnt)
	WITH nocounter, format, separator = ' '
ENDIF
 
CALL ECHORECORD(a)
GO TO exitscript
#exitscript
 
END
GO
