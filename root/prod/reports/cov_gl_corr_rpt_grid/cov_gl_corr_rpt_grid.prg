/***********************************************************
Author 			:	Mike Layman
Date Written	:	03/12/2019
Program Title	:	COV GL Corrected Report
Source File		:	cov_gl_corr_rpt_grid.prg
Object Name		:	cov_gl_corr_rpt_grid
Directory		:	cust_script
DVD Version		:	2018.07.1.70
HNA Version		:	02Jun18
CCL Version		:	8.14.1
Purpose			: 	This program will select any tests that have been
					corrected, along with some patient demographics and
					test comments.
Tables Read		:	person, encounter, encntr_alias, person_alias,
					result, perform_result, result_comment,
					long_text, orders, container, container_event,
					container_accession
Tables Updated	:	NA
Include File	:	NA
Shell Scripts	:	NA
Executing App	:	Explorer Menu
Special Notes	:
Usage			:	cov_example_rpt "mine", 555555.00, 222222.00 go
Mod		Date		Engineer				Comment
----    ----------- ----------------------- ---------------------------
001		10/31/2017	Mike Layman				Original Release
002     09/08/2020  Dawn Greer, DBA         CR 8404 - Add Order Location
                                            and Collected personnel
 
 
$LastChangedBy::							$:
$LastChangedDate::							$:
$LastChangedRevision::						$:
 
 
 
 
************************************************************/
drop program cov_gl_corr_rpt_grid go
create program cov_gl_corr_rpt_grid
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 0
	, "Select the Begin Date" = "SYSDATE"
	, "Select the End Date" = "SYSDATE"
 
with OUTDEV, facility, bdate, edate
 
 
 
 
/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
**************************************************************/
 
 
FREE RECORD a
RECORD a
(
1	rec_cnt 	=	i4
1	qual[*]
	2	personid	=	f8
	2	encntrid	=	f8
	2	orderid		=	f8
	2	ordname		=	vc
	2	name		=	vc
	2	mrn			=	vc
	2	fin			=	vc
	2	testname	=	vc
	2	colldttm	=	vc
	2	collprsnl	=	vc
	2	accession	=	vc
	2	orderphys	=	vc
	2	verprsnlid	=	f8
	2	verprsnl	=	vc
	2	completedttm=	vc
	2	comments	=	vc
	2	viewflg		=	i2
	2	result		=	vc
	2	resultid	=	f8
	2   facility    =   vc
	2   ord_loc     =   vc
 
 
)
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
DECLARE corrected = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 1901, 'CORRECTED')), PROTECT
DECLARE collected = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 2061, 'COLLECTED')), PROTECT
DECLARE alpha = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 289, 'ALPHA')), PROTECT
DECLARE numeric = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 289, 'NUMERIC')), PROTECT
DECLARE datetime = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 289, 'DATEANDTIME')), PROTECT
DECLARE freetext = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 289, 'FREETEXT')), PROTECT
DECLARE mrn = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',4,'MRN')), PROTECT
DECLARE fin = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',319, 'FINNBR')), PROTECT
DECLARE rescomm = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',14,'RESULTCOMMENT')), PROTECT
DECLARE rescomments = vc with noconstant(fillstring(500,' ')), PROTECT
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
SELECT into 'nl:'
 
FROM perform_result pr,
	 result r,
	 container_event ce,
	 container_accession ca,
	 accession a,
	 orders o,
	 encounter e,
	 person p,
	 prsnl pl,
	 prsnl colpr,		;002
	 organization org,   ;002
	 order_action oa
 
 
PLAN pr
WHERE pr.perform_dt_tm BETWEEN CNVTDATETIME($bdate)
AND CNVTDATETIME($edate)
AND pr.result_status_cd = corrected
JOIN r
WHERE pr.result_id = r.result_id
JOIN ce
WHERE pr.container_id = ce.container_id
AND ce.event_type_cd = collected
JOIN colpr		;002
WHERE ce.drawn_id = colpr.person_id	;002
JOIN ca
WHERE ce.container_id = ca.container_id
JOIN a
WHERE ca.accession_id = a.accession_id
JOIN o
WHERE r.order_id = o.order_id
AND o.active_ind = 1
JOIN oa
WHERE o.order_id = oa.order_id
AND oa.action_type_cd = 2534.00 /*Order*/
JOIN e
WHERE o.encntr_id = e.encntr_id
AND e.organization_id = $facility
AND e.active_ind = 1
JOIN org 
WHERE e.organization_id = org.organization_id
JOIN p
WHERE e.person_id = p.person_id
AND p.active_ind = 1
JOIN pl
WHERE pr.perform_personnel_id = pl.person_id
 
 
HEAD REPORT
 
	cnt = 0
 
DETAIL
 
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt =1 )
 
		stat = alterlist(a->qual, cnt + 9)
 
	endif
	a->qual[cnt].accession	=	CNVTACC(a.accession)
	a->qual[cnt].colldttm	=	FORMAT(ce.event_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].orderid	= 	r.order_id
	a->qual[cnt].ordname	=	UAR_GET_CODE_DISPLAY(r.catalog_cd)
	a->qual[cnt].testname	=	UAR_GET_CODE_DISPLAY(r.task_assay_cd)
	a->qual[cnt].verprsnlid = 	pr.perform_personnel_id
	a->qual[cnt].name		=	TRIM(p.name_full_formatted)
	a->qual[cnt].personid	=	p.person_id
	a->qual[cnt].encntrid	=	e.encntr_id
	a->qual[cnt].verprsnl	= 	TRIM(pl.name_full_formatted)
	a->qual[cnt].collprsnl	= 	TRIM(colpr.name_full_formatted)
	a->qual[cnt].facility   =   TRIM(org.org_name,3)
	a->qual[cnt].ord_loc    =   TRIM(UAR_GET_CODE_DISPLAY(oa.order_locn_cd),3)
	
	CASE (pr.result_type_cd)
 
		OF (alpha):
			a->qual[cnt].result 	=	pr.result_value_alpha
		OF (numeric):
			a->qual[cnt].result 	=	CNVTSTRING(pr.result_value_numeric,11,2)
		OF (datetime):
			a->qual[cnt].result 	=	FORMAT(pr.result_value_dt_tm,"MM/DD/YYYY HH:MM;;Q")
		OF (freetext):
			a->qual[cnt].result		=	TRIM(pr.ascii_text)
 
	ENDCASE
	a->qual[cnt].resultid 	=	r.result_id
	a->qual[cnt].completedttm = FORMAT(pr.perform_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->rec_cnt				=	cnt
 
FOOT REPORT
	stat = alterlist(a->qual, cnt)
 
 
WITH nocounter
 
;FIN/MRN
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 encntr_alias ea,
	 person_alias pa
 
PLAN d
JOIN ea
WHERE a->qual[d.seq].encntrid = ea.encntr_id
AND ea.encntr_alias_type_cd = fin
AND ea.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")
JOIN pa
WHERE a->qual[d.seq].personid = pa.person_id
AND pa.person_alias_type_cd = mrn
AND pa.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")
 
 
DETAIL
 
	a->qual[d.seq].fin = TRIM(ea.alias)
	a->qual[d.seq].mrn = TRIM(pa.alias)
 
 
WITH nocounter
 
;comments
 
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 result_comment rc,
	 long_text lt
 
PLAN d
JOIN rc
WHERE a->qual[d.seq].resultid = rc.result_id
AND rc.comment_type_cd = rescomm
JOIN lt
WHERE rc.long_text_id = lt.long_text_id
 
DETAIL
 
	a->qual[d.seq].comments = TRIM(REPLACE(lt.long_text,CONCAT(CHAR(13),CHAR(10)),' '))
	a->qual[d.seq].comments = TRIM(REPLACE(a->qual[d.seq].comments,CHAR(10),''))
 
WITH nocounter
 
 
 
SELECT into $outdev
 
	name = concat(a->qual[d.seq].name,'                                        '),
	mrn = a->qual[d.seq].mrn,
	fin = a->qual[d.seq].fin,
	Order_Location = a->qual[d.seq].ord_loc,
	collecteddatetime = CONCAT(a->qual[d.seq].colldttm,'                '),
	collected_personnel = CONCAT(a->qual[d.seq].collprsnl,'                                 '),
	accnbr = a->qual[d.seq].accession,
	test = concat(a->qual[d.seq].testname,'                            '),
	completeddatetime = CONCAT(a->qual[d.seq].completedttm,'                        '),
	perform_personnel = CONCAT(a->qual[d.seq].verprsnl,'                                   '),
	result = CONCAT(a->qual[d.seq].result,'                      '),
	rescomments = CONCAT(A->qual[d.seq].comments,'                                     ')
 
FROM (dummyt d with seq = a->rec_cnt)
 
 
WITH nocounter, format, separator = ' '
 
 
CALL ECHORECORD(a)
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go