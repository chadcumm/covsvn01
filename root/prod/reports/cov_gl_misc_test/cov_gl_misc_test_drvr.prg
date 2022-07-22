/***********************************************************
Author 			:	Mike Layman
Date Written	:	10/31/2017
Program Title	:	Miscellaneous Send Out Lab Driver
Source File		:	cov_gl_misc_test_drvr.prg
Object Name		:	cov_gl_misc_test_drvr
Directory		:	cust_script
DVD Version		:	2017.07.1.81
HNA Version		:	2015.01
CCL Version		:	8.8.3
Purpose			: 	This program is designed to display the
					miscellaneous lab send out tests that are
					sent to Mayo, Quest and other Reference labs.
Tables Read		:	person, encounter, encntr_alias, person_alias,
					orders, order_action, order_detail
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
drop program cov_gl_misc_test_drvr go
create program cov_gl_misc_test_drvr
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 0
	, "Seelct Begin Date" = "SYSDATE"
	, "Select End Date" = "SYSDATE"
 
with OUTDEV, facility, begdate, enddate
 
 
 
/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
**************************************************************/
;FREE RECORD a
RECORD a
(
1	rec_cnt	=	i4
1	qual[*]
	2	personid			=	f8
	2	encntrid			=	f8
	2	name				=	vc
	2	mrn					=	vc
	2	fin					=	vc
	2	ordcnt				=	i4
	2	ordqual[*]
			3	orderid		=	f8
			3	accnbr		=	vc
			3	accnid		=	f8
			3	ordname		=	vc
			3	orddttm		=	vc
			3	colldttm	=	vc
			3	labtest		=	vc
			3	comments	=	vc
			3	ordcommcnt	=	i4
			3	ordcommqual[*]
			4	longtextid	=	f8
			4	comment		=	vc
)
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
DECLARE mrn = F8 with CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',4,'MRN')), PROTECT
DECLARE fin = F8 with CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',319,'FINNBR')), PROTECT
DECLARE miscMayo = F8 with CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',200,'MISCELLANEOUSLABTESTMAYO')), PROTECT
DECLARE miscQuest = F8 with CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',200,'MISCELLANEOUSLABTESTQUEST')), PROTECT
DECLARE miscOther = F8 with CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',200,'MISCELLANEOUSLABTESTOTHER')), PROTECT
DECLARE cancel = F8 with CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6004,'CANCELED')), PROTECT
DECLARE aliascd	=	f8 WITH NOCONSTANT(0.0), PROTECT
DECLARE collected = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',2061,'COLLECTED')), PROTECT
DECLARE iOpsInd = i2 WITH NOCONSTANT(0), PROTECT
DECLARE bdate	 = f8 WITH NOCONSTANT(0.0), PROTECT
DECLARE edate	 = f8 WITH NOCONSTANT(0.0), PROTECT
DECLARE chbdate	 = vc WITH NOCONSTANT(FILLSTRING(20,' ')), PROTECT
DECLARE chedate  = vc WITH NOCONSTANT(FILLSTRING(20,' ')), PROTECT
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
;check cv's
CALL ECHO(BUILD('mrn :', mrn))
CALL ECHO(BUILD('fin :', fin))
CALL ECHO(BUILD('miscMayo :', miscMayo))
CALL ECHO(BUILD('miscQuest :', miscQuest))
CALL ECHO(BUILD('miscOther :', miscOther))
CALL ECHO(BUILD('collected :', collected))
 
 
 
;ops setup
if (VALIDATE(request->batch_selection) = 1)
 
	SET iOpsInd = 1
 
	SET bdate = DATETIMEFIND(CNVTDATETIME(CURDATE-1, 0),'D','B','B')
	SET edate = CNVTDATETIME(CURDATE-1,2359)
 
	SET chbdate = FORMAT(CNVTDATETIME(bdate),"mm/dd/yyyy hh:mm;;q")
	SET chedate = FORMAT(CNVTDATETIME(edate),"mm/dd/yyyy hh:mm;;q")
 
	;SET sqlparser = 'c.service_dt_tm BETWEEN CNVTDATETIME(bdate) AND CNVTDATETIME(edate)'
 
 
else
 
	SET bdate = CNVTDATETIME($begdate)
	SET edate = CNVTDATETIME($enddate)
	SET chbdate = FORMAT(CNVTDATETIME(bdate),"mm/dd/yyyy hh:mm;;q")
	SET chedate = FORMAT(CNVTDATETIME(edate),"mm/dd/yyyy hh:mm;;q")
	;SET sqlparser = 'c.service_dt_tm BETWEEN CNVTDATETIME(bdate) AND CNVTDATETIME(edate)'
 
endif
 
CALL ECHO(BUILD('bdate :', bdate))
CALL ECHO(BUILD('edate :', edate))
CALL ECHO(BUILD('chbdate :', chbdate))
CALL ECHO(BUILD('chedate :', chedate))
 
 
SELECT into 'nl:'
 
FROM code_value cv
WHERE cv.code_set = 263
AND cv.display = 'STAR MRN -*'
 
DETAIL
 
	if (cv.display = BUILD2('STAR MRN - ',UAR_GET_CODE_DISPLAY($facility))
		OR cv.display = 'STAR MRN - PBH')
 
		aliascd = cv.code_value
 
	endif
WITH nocounter
 
CALL ECHO(BUILD('aliascd :', aliascd))
 
SELECT into 'nl:'
 
FROM orders o,
	 encounter e,
	 person p,
	 encntr_alias ea,
	 person_alias pa,
	 accession_order_r aor
 
PLAN o
WHERE o.orig_order_dt_tm BETWEEN CNVTDATETIME(bdate)
AND CNVTDATETIME(edate)
AND o.catalog_cd IN (miscMayo, miscQuest, miscOther)
AND o.order_status_cd != cancel
JOIN e
WHERE o.encntr_id = e.encntr_id
AND e.loc_facility_cd = $facility
AND e.active_ind = 1
JOIN p
WHERE e.person_id = p.person_id
ANd p.active_ind = 1
JOIN ea
WHERE e.encntr_id = ea.encntr_id
AND ea.encntr_alias_type_cd = fin
AND ea.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")
JOIN pa
WHERE p.person_id = pa.person_id
AND pa.person_alias_type_cd = mrn
;AND pa.alias_pool_cd = aliascd
AND pa.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")
JOIN aor
WHERE o.order_id = aor.order_id
 
HEAD REPORT
	cnt = 0
 
HEAD p.person_id
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(a->qual, cnt + 9)
 
	endif
	a->qual[cnt].personid	=	p.person_id
	a->qual[cnt].encntrid	=	e.encntr_id
	a->qual[cnt].name		=	TRIM(p.name_full_formatted)
	a->qual[cnt].mrn		=	TRIM(pa.alias)
	a->qual[cnt].fin		=	TRIM(ea.alias)
	a->rec_cnt				=	cnt
	ocnt = 0
 
HEAD o.order_id
 
	ocnt = ocnt + 1
	if (mod(ocnt,10) = 1 or ocnt = 1)
 
		stat = alterlist(a->qual[cnt].ordqual, ocnt + 9)
 
	endif
	a->qual[cnt].ordqual[ocnt].orderid	=	o.order_id
	a->qual[cnt].ordqual[ocnt].orddttm 	=	FORMAT(O.orig_order_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].ordqual[ocnt].ordname	=	TRIM(o.hna_order_mnemonic)
	a->qual[cnt].ordqual[ocnt].accnbr   =   CNVTACC(aor.accession)
	a->qual[cnt].ordqual[ocnt].accnid	=	aor.accession_id
	a->qual[cnt].ordcnt					=	ocnt
FOOT p.person_id
 
	stat = alterlist(a->qual[cnt].ordqual, ocnt)
 
 
FOOT REPORT
	stat = alterlist(a->qual, cnt)
 
 
WITH nocounter
 
;Get lab test names and comments
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 order_detail od
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].ordcnt)
JOIN d2
JOIN od
WHERE a->qual[d.seq].ordqual[d2.seq].orderid = od.order_id
AND od.oe_field_id = 274145197.00
 
 
HEAD od.order_id
	a->qual[d.seq].ordqual[d2.seq].labtest = TRIM(od.oe_field_display_value)
 
 
WITH nocounter
 
 
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 order_comment oc,
	 long_text lt
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].ordcnt)
JOIN d2
JOIN oc
WHERE a->qual[d.seq].ordqual[d2.seq].orderid = oc.order_id
JOIN lt
WHERE oc.long_text_id = lt.long_text_id
 
HEAD oc.order_id
 
	cnt = 0
 
HEAD lt.long_text_id
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(a->qual[d.seq].ordqual[d2.seq].ordcommqual, cnt + 9)
 
	endif
 
	a->qual[d.seq].ordqual[d2.seq].ordcommqual[cnt].longtextid	=	lt.long_text_id
	a->qual[d.seq].ordqual[d2.seq].ordcommqual[cnt].comment		=   TRIM(lt.long_text)
	a->qual[d.seq].ordqual[d2.seq].ordcommcnt	=	cnt
 
FOOT oc.order_id
	FOR (mcnt = 1 TO a->qual[d.seq].ordqual[d2.seq].ordcommcnt)
 
 
		if (mcnt = a->qual[d.seq].ordqual[d2.seq].ordcommcnt)
			a->qual[d.seq].ordqual[d2.seq].comments = BUILD2(a->qual[d.seq].ordqual[d2.seq].comments,
			a->qual[d.seq].ordqual[d2.seq].ordcommqual[mcnt].comment)
		else
			a->qual[d.seq].ordqual[d2.seq].comments = BUILD2(a->qual[d.seq].ordqual[d2.seq].comments,
			a->qual[d.seq].ordqual[d2.seq].ordcommqual[mcnt].comment,', ')
		endif
 
	ENDFOR
 
 
	stat = alterlist(a->qual[d.seq].ordqual[d2.seq].ordcommqual, cnt)
 
WITH nocounter
 
 
;get collection date/time
 
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 container_accession ca,
	 container_event ce
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].ordcnt)
JOIN d2
join ca
WHERE a->qual[d.seq].ordqual[d2.seq].accnid = ca.accession_id
JOIN ce
WHERE ca.container_id = ce.container_id
AND ce.event_type_cd = collected
 
detail
 
	a->qual[d.seq].ordqual[d2.seq].colldttm = FORMAT(ce.drawn_dt_tm, "mm/dd/yyyy hh:mm;;q")
 
 
WITH nocounter
 
 
 
 
 
 
 
 
CALL ECHORECORD(a)
GO TO exitscript
 
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript
 
end
go