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
drop program COV_1ST_CASE_START_TIMES_RPT go
create program COV_1ST_CASE_START_TIMES_RPT
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Surgical Area" = 0
	, "Select Surgeon" = 1
	, "Select Staff Assigned to case" = 1
	, "Select Begin Date/Time" = "SYSDATE"
	, "Select End Date/Time" = "SYSDATE"
 
with OUTDEV, surgarea, surgeon, staff, begdate, enddate
 
 
 
/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
**************************************************************/
;FREE RECORD a
RECORD a
(
1	rec_cnt				=	i4
1	surgarea			=	vc
1	total		=	i4
1	percontime	=	vc
1	ontime		=	i4
1	appttotal 	=	i4
1	qual[*]
	2	dept			=	vc
	2	roomcnt			=	i4
	2	roomqual[*]
		3	room		=	vc
		3	rm_rsrc_cd 	=   f8
		3 	apptcnt		=	i4
 
		3	apptqual[*]
			4	apptid		=	f8
			4	periopdocid	=	f8
			4	personid	=	f8
			4	encntrid	=	f8
			4	schapptdttm	=	vc
			4	apptdttm	=	f8
			4	ptinrmdttm	=	vc
			4	surgeon		=	vc
			4	diff		=	i4
			4	role_meaning	=	vc
			4	state_meaning	=	vc
			4	slot_meaning	=	vc
			4	bookingid		=	f8
			4	scheventid		=	f8
			4   surgcaseid		=	f8
			4	eventid			=	f8
			4	printflg		=	i2
			4	surgflg			=	i2
			4	staffflg		=	i2
			4	ontimestart		=	C2
			4	ptname			=	vc
			4	mrn				=	vc
			4	fin				=	vc
			4	sex				=	vc
			4	age				=	vc
			4	delayreason		=	vc
			4	surgeon			=	vc
			4	casenumber		=	vc
			4	addtnlprsnl		=	vc
			4	caseprsnlcnt	=	i4
			4	caseprsnlqual[*]
				5	prsnlid		=	f8
				5	name		=	vc
				5	role		=	vc
				5	eventid		=	f8
 
 
)
 
 
FREE RECORD periopdoc
RECORD periopdoc
(
1	rec_cnt = i4
1	qual[*]
	2	code_value	=	f8
	2	desc		=	vc
	2	disp		=	vc
 
)
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
DECLARE parseDtTm(strdateval = vc) = vc
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
DECLARE snptinroom = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 72, 'SNCTMPATIENTINROOMTIME')), PROTECT
DECLARE ptinroomdttm = vc WITH NOCONSTANT(FILLSTRING(25,' ')), PROTECT
DECLARE yr	=	c4 WITH NOCONSTANT(FILLSTRING(4, ' ')), PROTECT
DECLARE mm	=	c2 WITH NOCONSTANT(FILLSTRING(2,' ')), PROTECT
DECLARE dy	=	c2 WITH NOCONSTANT(FILLSTRING(2,' ')), PROTECT
DECLARE tm	=	c4 WITH NOCONSTANT(FILLSTRING(4, ' ')), PROTECT
DECLARE mrn = 	f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',4,'MRN'))
DECLARE fin = 	f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',319,'FINNBR'))
DECLARE delayrsn = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 72,'SNDELDELAYREASON'))
DECLARE frmbldfrm = f8 WITH CONSTANT(UAR_GET_CODE_BY('DESCRIPTION', 72, 'SN - Case Times'))
DECLARE evntrltncd  = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',24,'R')), PROTECT
DECLARE caseattcd	= f8 WITH CONSTANT(UAR_GET_CODE_BY('DESCRIPTION',72, 'SN - Case Attendance')), PROTECT
DECLARE caseattendee= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72, 'SNCATCASEATTENDEE')), PROTECT
DECLARE caserole= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72, 'SNCATROLEPERFORMED')), PROTECT
DECLARE surgsql = vc WITH NOCONSTANT(FILLSTRING(500,' ')), PROTECT
DECLARE staffsql = vc WITH NOCONSTANT(FILLSTRING(500,' ')), PROTECT
DECLARE surgfilter = i2 WITH NOCONSTANT(0), PROTECT
DECLARE stafffilter = i2 WITH NOCONSTANT(0), PROTECT
DECLARE idx	=	i4 WITH NOCONSTANT(0), PROTECT
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
 
;check cv's
CALL ECHO(BUILD('snptinroom :', snptinroom))
CALL ECHO(BUILD('mrn :', mrn))
CALL ECHO(BUILD('fin :', fin))
CALL ECHO(BUILD('frmbldfrm :', frmbldfrm))
CALL ECHO(BUILD('evntrltncd :', evntrltncd))
CALL ECHO(BUILD('caseattcd :', caseattcd))
CALL ECHO(BUILD('caseattendee :', caseattendee))
CALL ECHO(BUILD('caserole :', caserole))
 
 
 
;Get Intraop Document cv's
 
SELECT into 'nl:'
 
FROM code_value cv
WHERE cv.code_set = 14258
AND cv.display in ('*IntraOp*','*IntraProc*')
AND cv.active_ind = 1
 
HEAD REPORT
	cnt = 0
 
DETAIL
	cnt = cnt + 1
	if (mod(cnt,10 ) = 1 or cnt = 1)
 
		stat = alterlist(periopdoc->qual, cnt + 9)
 
	endif
	periopdoc->qual[cnt].code_value	=	cv.code_value
	periopdoc->qual[cnt].desc	=	TRIM(cv.description)
	periopdoc->qual[cnt].disp	=	TRIM(cv.display)
	periopdoc->rec_cnt			=	cnt
 
FOOT REPORT
	stat = alterlist(periopdoc->qual, cnt)
WITH nocounter
 
;CALL ECHORECORD(periopdoc)
;GO TO exitscript
 
 
;SET UP filters
 
 
 
 
if (CNVTINT($surgeon) IN(0,1))
	SET surgsql = 'a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].caseprsnlqual[d4.seq].prsnlid > 0.0'
	SET surgfilter = 1
else
	SET surgsql = BUILD('a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].caseprsnlqual[d4.seq].prsnlid = ', $surgeon)
 
endif
 
if (CNVTINT($staff) IN (0, 1)) ; 0 option is needed for testing since all surgical area staff is not built yet.
	SET staffsql = 'a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].caseprsnlqual[d4.seq].prsnlid > 0.0'
	SET stafffilter = 1
else
 
	SET staffsql = BUILD('a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].caseprsnlqual[d4.seq].prsnlid = ', $staff)
endif
 
 
 
 
SELECT into 'nl:'
 
FROM resource_group srg,
	 resource_group sg2
 
PLAN srg
WHERE srg.parent_service_resource_cd = $surgarea
AND srg.active_ind = 1
JOIN sg2
WHERE srg.child_service_resource_cd = sg2.parent_service_resource_cd
AND sg2.active_ind = 1
 
HEAD REPORT
	cnt = 0
	a->surgarea = UAR_GET_CODE_DISPLAY(srg.parent_service_resource_cd)
HEAD srg.child_service_resource_cd
 
	cnt = cnt + 1
 
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(a->qual, cnt + 9)
 
	endif
 
	a->qual[cnt].dept = UAR_GET_CODE_DISPLAY(srg.child_service_resource_cd)
	a->rec_cnt			=	cnt
	rmcnt = 0
DETAIL
	rmcnt = rmcnt + 1
	if (mod(rmcnt,10) = 1 or rmcnt = 1)
 
		stat = alterlist(a->qual[cnt].roomqual, rmcnt + 9)
 
	endif
	a->qual[cnt].roomqual[rmcnt].rm_rsrc_cd = sg2.child_service_resource_cd
	a->qual[cnt].roomqual[rmcnt].room		= UAR_GET_CODE_DISPLAY(sg2.child_service_resource_cd)
	a->qual[cnt].roomcnt					= rmcnt
 
 
FOOT srg.child_service_resource_cd
	stat = alterlist(a->qual[cnt].roomqual, rmcnt)
 
FOOT REPORT
	stat = alterlist(a->qual, cnt)
 
 
WITH NOCOUNTER
 
;Get room appointments
SELECT into 'nl:'
 
 
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 sch_appt sa,
	; sch_appt sa2,
	 surgical_case sc
;	 person p,
;	 person_alias pa,
;	 encntr_alias ea
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].roomcnt)
JOIN d2
JOIN sa
WHERE a->qual[d.seq].roomqual[d2.seq].rm_rsrc_cd = sa.service_resource_cd
AND sa.beg_dt_tm BETWEEN CNVTDATETIME($begdate)
AND CNVTDATETIME($enddate)
AND sa.role_meaning = 'SURGOP'
AND sa.state_meaning in ('CHECKED IN', 'CONFIRMED')
JOIN sc
WHERE sa.sch_event_id = sc.sch_event_id
AND sc.active_ind =1
;JOIN sa2
;WHERE sa.sch_event_id = sa2.sch_event_id
;AND sa2.role_meaning = 'PATIENT'
;AND sa2.state_meaning in ('CHECKED IN', 'CONFIRMED')
;JOIN p
;WHERE sa2.person_id = p.person_id
;AND p.active_ind = 1
;JOIN pa
;WHERE p.person_id = pa.person_id
;AND pa.person_alias_type_cd = mrn
;AND pa.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")
;JOIN ea
;WHERE sa2.encntr_id = ea.encntr_id
;AND ea.encntr_alias_type_cd = fin
;AND ea.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")
 
;ORDER BY sa2.beg_dt_tm DESC
 
HEAD sa.service_resource_cd
	cnt = 0
 
;HEAD sa2.beg_dt_tm
HEAD sa.sch_appt_id
;DETAIL
 
	cnt = cnt + 1
 
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(a->qual[d.seq].roomqual[d2.seq].apptqual, cnt + 9)
 
	endif
 
	a->qual[d.seq].roomqual[d2.seq].apptqual[cnt].apptid	=	sa.sch_appt_id
;	a->qual[d.seq].roomqual[d2.seq].apptqual[cnt].encntrid	=	sa2.encntr_id
;	a->qual[d.seq].roomqual[d2.seq].apptqual[cnt].personid	=	sa2.person_id
	a->qual[d.seq].roomqual[d2.seq].apptqual[cnt].schapptdttm = FORMAT(sa.beg_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[d.seq].roomqual[d2.seq].apptqual[cnt].apptdttm 	= sa.beg_dt_tm
	a->qual[d.seq].roomqual[d2.seq].apptqual[cnt].role_meaning = sa.role_meaning
;	a->qual[d.seq].roomqual[d2.seq].apptqual[cnt].state_meaning = sa2.state_meaning
	a->qual[d.seq].roomqual[d2.seq].apptqual[cnt].slot_meaning	= sa.slot_state_meaning
	a->qual[d.seq].roomqual[d2.seq].apptqual[cnt].bookingid		= sa.booking_id
	a->qual[d.seq].roomqual[d2.seq].apptqual[cnt].scheventid	= sa.sch_event_id
;	a->qual[d.seq].roomqual[d2.seq].apptqual[cnt].ptname		= TRIM(p.name_full_formatted)
;	a->qual[d.seq].roomqual[d2.seq].apptqual[cnt].mrn			= TRIM(pa.alias)
;	a->qual[d.seq].roomqual[d2.seq].apptqual[cnt].fin			= TRIM(ea.alias)
;	a->qual[d.seq].roomqual[d2.seq].apptqual[cnt].age			= CNVTAGE(p.birth_dt_tm)
;	a->qual[d.seq].roomqual[d2.seq].apptqual[cnt].sex			= UAR_GET_CODE_DISPLAY(p.sex_cd)
 
	a->qual[d.seq].roomqual[d2.seq].apptcnt					=	cnt
 
FOOT sa.service_resource_cd
 	;a->appttotal = a->appttotal + a->qual[d.seq].roomqual[d2.seq].apptcnt
	stat = alterlist(a->qual[d.seq].roomqual[d2.seq].apptqual, cnt)
 
WITH nocounter
 
 
;CALL ECHORECORD(A)
;GO TO EXITSCRIPT
 
;Get pt appointment info
 
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 (dummyt d3 with seq = 1),
	 sch_appt sa,
	 person p,
	 person_alias pa,
	 encntr_alias ea
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].roomcnt)
JOIN d2
WHERE MAXREC(d3,a->qual[d.seq].roomqual[d2.seq].apptcnt)
JOIN d3
JOIN sa
WHERE a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].scheventid = sa.sch_event_id
AND sa.role_meaning = 'PATIENT'
AND sa.state_meaning in ('CHECKED IN', 'CONFIRMED')
JOIN p
WHERE sa.person_id = p.person_id
AND p.active_ind = 1
JOIN pa
WHERE OUTERJOIN(p.person_id) = pa.person_id
AND  OUTERJOIN(MRN) = pa.person_alias_type_cd
AND OUTERJOIN(CNVTDATETIME("31-DEC-2100 0")) = pa.end_effective_dt_tm
JOIN ea
WHERE OUTERJOIN(sa.encntr_id) = ea.encntr_id
AND OUTERJOIN(fin) = ea.encntr_alias_type_cd
AND OUTERJOIN(CNVTDATETIME("31-DEC-2100 0")) = ea.end_effective_dt_tm
 
DETAIL
 
	a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].encntrid	=	sa.encntr_id
	a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].personid	=	sa.person_id
	a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].state_meaning = sa.state_meaning
	a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].state_meaning = sa.state_meaning
	a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].ptname		= TRIM(p.name_full_formatted)
	a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].mrn			= TRIM(pa.alias)
	a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].fin			= TRIM(ea.alias)
	a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].age			= CNVTAGE(p.birth_dt_tm)
	a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].sex			= UAR_GET_CODE_DISPLAY(p.sex_cd)
 
WITH nocounter
 
 
;Get Surgical Case Info
 
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 (dummyt d3 with seq = 1),
	 surgical_case sc,
	 perioperative_document pd;,
;	 clinical_event ce,
;	 clinical_event ce2
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].roomcnt)
JOIN d2
WHERE MAXREC(d3, a->qual[d.seq].roomqual[d2.seq].apptcnt)
JOIN d3
JOIN sc
WHERE A->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].scheventid = sc.sch_event_id
AND sc.active_ind = 1
JOIN pd
WHERE outerjoin(sc.surg_case_id) = pd.surg_case_id
AND expand(idx,1,periopdoc->rec_cnt,pd.doc_type_cd,periopdoc->qual[idx].code_value)
;AND sc.surg_case_id > 0
;JOIN ce
;WHERE a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].personid = ce.person_id
;AND ce.event_cd = frmbldfrm ;snptinroom
;;AND ce.event_end_dt_tm BETWEEN CNVTDATETIME(a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].apptdttm)
;;AND CNVTLOOKAHEAD('24 H',a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].apptdttm)
;AND sc.encntr_id = ce.encntr_id
;AND OPERATOR(ce.reference_nbr,'LIKE',CONCAT(TRIM(CNVTSTRING(pd.periop_doc_id,3)),'SN%'))
;AND ce.event_reltn_cd = evntrltncd
;JOIN ce2
;WHERE ce.event_id = ce2.parent_event_id
;AND ce2.event_cd = snptinroom
;AND ce2.valid_until_dt_tm = CNVTDATETIME("31-DEC-2100 0")
 
HEAD sc.surg_case_id  ;ce.event_id
	ptinroom = 0
	appttime = 0
 
DETAIL
	a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].periopdocid = pd.periop_doc_id
	a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].surgcaseid = sc.surg_case_id
	;a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].eventid = ce2.event_id
	a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].casenumber = sc.surg_case_nbr_formatted
	;CALL parseDtTm(ce2.result_val)
	;ptinroomdttm = parseDtTm(ce.result_val)
	;a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].ptinrmdttm = ptinroomdttm;TRIM(ce.result_val)
 
 
WITH nocounter
 
 
;Get clin events
SELECT into 'nl:'
 
	surgcaseid = a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].surgcaseid
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 (dummyt d3 with seq = 1),
	 clinical_event ce,
	 clinical_event ce2
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].roomcnt)
JOIN d2
WHERE MAXREC(d3, a->qual[d.seq].roomqual[d2.seq].apptcnt)
JOIN d3
JOIN ce
WHERE a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].personid = ce.person_id
AND ce.event_cd = frmbldfrm ;snptinroom
;AND ce.event_end_dt_tm BETWEEN CNVTDATETIME(a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].apptdttm)
;AND CNVTLOOKAHEAD('24 H',a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].apptdttm)
AND a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].encntrid = ce.encntr_id
AND OPERATOR(ce.reference_nbr,'LIKE',CONCAT(TRIM(CNVTSTRING
(a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].periopdocid,3)),'SN%'))
AND ce.event_reltn_cd = evntrltncd
JOIN ce2
WHERE ce.event_id = ce2.parent_event_id
AND ce2.event_cd = snptinroom
AND ce2.valid_until_dt_tm = CNVTDATETIME("31-DEC-2100 0")
 
 
HEAD surgcaseid
	ptinroom = 0
	appttime = 0
 
DETAIL
	CALL parseDtTm(ce2.result_val)
	;ptinroomdttm = parseDtTm(ce.result_val)
	a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].ptinrmdttm = ptinroomdttm;TRIM(ce.result_val)
	a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].eventid = ce2.event_id
 
 
WITH nocounter
;CALL ECHORECORD(A)
;GO TO EXITSCRIPT
 
 
;;Check first case vs pt in room time.
;SELECT into 'nl:'
;
;	caseid = a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].surgcaseid
;
;FROM (dummyt d with seq = a->rec_cnt),
;	 (dummyt d2 with seq = 1),
;	 (dummyt d3 with seq = 1)
;
;PLAN d
;WHERE MAXREC(d2, a->qual[d.seq].roomcnt)
;JOIN d2
;WHERE MAXREC(d3, a->qual[d.seq].roomqual[d2.seq].apptcnt)
;JOIN d3
;
;HEAD caseid
;	appttime = 0
;	inroomtime = 0
; 	apptdate = 0.0
; 	1stcaseflg = 0
;
;DETAIL
;	 appttime = CNVTTIME(cnvtdatetime(a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].apptdttm))
; 	 if (apptdate != a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].apptdttm)
;
; 	 	1stcaseflg = 0
;
; 	 endif
;
;	 if (appttime BETWEEN 0630 AND 0800 AND (apptdate = 0.0 OR apptdate !=
;	 a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].apptdttm))
; 		if (1stcaseflg = 0)
;		 	a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].printflg = 1
;		 	;a->total = a->total + 1
;
;
;	 		1stcaseflg = 1
;
;		 	if (a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].ptinrmdttm > ' ')
; 				a->total = a->total + 1
;		 		inroomtime = CNVTMIN(cnvtint(
;			 	SUBSTRING(12,4,a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].ptinrmdttm)))
;
;		 		appttime = CNVTMIN(appttime)
;		 		call echo(build('appttime :', appttime))
;	 			CALL ECHO(BUILD('inroomtime :', inroomtime))
;			 	a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].diff = inroomtime - appttime
;
;			 	if (a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].diff <= 5)
;			 		a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].ontimestart = 'Y'
;			 		a->ontime = a->ontime + 1
;			 	else
;
;			 		a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].ontimestart = 'N'
;
;			 	endif
;			 else
;			 	a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].ontimestart= 'NA'
;		 	endif
;		 endif
;	 endif
;
; 	apptdate = a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].apptdttm
;
;WITH nocounter
 
;DELAY REASONS
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 (dummyt d3 with seq = 1),
	 clinical_event ce
	PLAN d
WHERE MAXREC(d2, a->qual[d.seq].roomcnt)
JOIN d2
WHERE MAXREC(d3, a->qual[d.seq].roomqual[d2.seq].apptcnt)
JOIN d3
join ce
WHERE a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].personid = ce.person_id
AND ce.event_cd = delayrsn
AND a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].encntrid = ce.encntr_id
AND ce.valid_until_dt_tm = CNVTDATETIME("31-DEC-2100 0")
 
 
 
DETAIL
 
	A->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].delayreason = TRIM(ce.result_val)
 
WITH nocounter
 
;CALL ECHORECORD(A)
;GO TO EXITSCRIPT
 
;Personnel - Need Surgeon, Circulator and CRNA if Available.
SELECT into 'nl:'
 
	periopdocid  = a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].periopdocid
 
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 (dummyt d3 with seq = 1),
	 case_attendance ca,
	 prsnl pr
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].roomcnt)
JOIN d2
WHERE MAXREC(d3, a->qual[d.seq].roomqual[d2.seq].apptcnt)
JOIN d3
JOIN ca
WHERE a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].surgcaseid = ca.surg_case_id
AND ca.active_ind = 1
JOIN pr
WHERE ca.case_attendee_id = pr.person_id
AND pr.active_ind = 1
 
 
 
HEAD periopdocid
	cnt = 0
	parevid = 0.0
DETAIL
 
	;IF (parevid = 0.0 OR ce2.parent_event_id != parevid)
		cnt = cnt + 1
		if (mod(cnt,10) = 1 or cnt = 1)
 
			stat = alterlist(a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].caseprsnlqual, cnt + 9)
		endif
	;ENDIF
	a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].caseprsnlqual[cnt].name = TRIM(PR.name_full_formatted)
	a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].caseprsnlqual[cnt].role = uar_get_code_display(CA.role_perf_cd)
	a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].caseprsnlqual[cnt].prsnlid = pr.person_id
	a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].caseprsnlcnt = cnt
 
FOOT periopdocid
 
	stat = alterlist(a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].caseprsnlqual, cnt)
WITH NOCOUNTER
;
;CALL ECHORECORD(A)
;GO TO EXITSCRIPT
 
;Check surgeon/staff filters
if (surgfilter = 0)
	SELECT into 'nl:'
 
	FROM (dummyt d with seq = a->rec_cnt),
		 (dummyt d2 with seq = 1),
		 (dummyt d3 with seq = 1),
		 (dummyt d4 with seq = 1)
 
	PLAN d
	WHERE MAXREC(d2, a->qual[d.seq].roomcnt)
	JOIN d2
	WHERE MAXREC(d3, a->qual[d.seq].roomqual[d2.seq].apptcnt)
	JOIN d3
	WHERE MAXREC(d4, a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].caseprsnlcnt)
	JOIN d4
	WHERE PARSER(surgsql)
 
	DETAIL
 
		a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].surgflg = 1
 
	WITH nocounter
else
 	SELECT into 'nl:'
 
	FROM (dummyt d with seq = a->rec_cnt),
		 (dummyt d2 with seq = 1),
		 (dummyt d3 with seq = 1)
 
	PLAN d
	WHERE MAXREC(d2, a->qual[d.seq].roomcnt)
	JOIN d2
	WHERE MAXREC(d3, a->qual[d.seq].roomqual[d2.seq].apptcnt)
	JOIN d3
 
	DETAIL
 
		a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].surgflg = 1
 
	WITH nocounter
 
endif
 
if (stafffilter = 0)
	SELECT into 'nl:'
 
	FROM (dummyt d with seq = a->rec_cnt),
		 (dummyt d2 with seq = 1),
		 (dummyt d3 with seq = 1),
		 (dummyt d4 with seq = 1)
 
	PLAN d
	WHERE MAXREC(d2, a->qual[d.seq].roomcnt)
	JOIN d2
	WHERE MAXREC(d3, a->qual[d.seq].roomqual[d2.seq].apptcnt)
	JOIN d3
	WHERE MAXREC(d4, a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].caseprsnlcnt)
	JOIN d4
	WHERE PARSER(staffsql)
 
	DETAIL
 
		a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].staffflg = 1
 
	WITH nocounter
else
 
	SELECT into 'nl:'
 
	FROM (dummyt d with seq = a->rec_cnt),
		 (dummyt d2 with seq = 1),
		 (dummyt d3 with seq = 1)
 
	PLAN d
	WHERE MAXREC(d2, a->qual[d.seq].roomcnt)
	JOIN d2
	WHERE MAXREC(d3, a->qual[d.seq].roomqual[d2.seq].apptcnt)
	JOIN d3
 
	DETAIL
 
		a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].staffflg = 1
 
	WITH nocounter
 
 
endif
 
 
 
;Check first case vs pt in room time.
SELECT into 'nl:'
 
	caseid = a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].surgcaseid
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 (dummyt d3 with seq = 1)
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].roomcnt)
JOIN d2
WHERE MAXREC(d3, a->qual[d.seq].roomqual[d2.seq].apptcnt)
JOIN d3
 
HEAD caseid
	appttime = 0
	inroomtime = 0
 	apptdate = 0.0
 	1stcaseflg = 0
 
DETAIL
	 appttime = CNVTTIME(cnvtdatetime(a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].apptdttm))
 	 if (apptdate != a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].apptdttm)
 
 	 	1stcaseflg = 0
 
 	 endif
 
	 if (appttime BETWEEN 0630 AND 0800 AND (apptdate = 0.0 OR apptdate !=
	 a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].apptdttm))
 		if (1stcaseflg = 0)
 			if (a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].ptinrmdttm > ' ')
		 		a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].printflg = 1
		 	endif
		 	;a->total = a->total + 1
 
 
	 		1stcaseflg = 1
 
		 	if (a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].ptinrmdttm > ' '
		 		and a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].surgflg = 1
		 		AND a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].staffflg = 1)
 				a->total = a->total + 1
		 		inroomtime = CNVTMIN(cnvtint(
			 	SUBSTRING(12,4,a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].ptinrmdttm)))
 
		 		appttime = CNVTMIN(appttime)
		 		call echo(build('appttime :', appttime))
	 			CALL ECHO(BUILD('inroomtime :', inroomtime))
			 	a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].diff = inroomtime - appttime
 
			 	if (a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].diff <= 5)
			 		a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].ontimestart = 'Y'
			 		a->ontime = a->ontime + 1
			 	else
 
			 		a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].ontimestart = 'N'
 
			 	endif
			 else
			 	a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].ontimestart= 'NA'
		 	endif
		 endif
	 endif
 
 		if (a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].surgflg = 1
		 		AND a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].staffflg = 1)
 
			a->appttotal = a->appttotal + 1
 
		endif
 
 	apptdate = a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].apptdttm
 
WITH nocounter
 
;Calculate totals/ % on time
 
SET a->percontime = concat(CNVTSTRING((CNVTREAL(a->ontime)/CNVTREAL(a->total))*100,3), ' % ')
 
 
;Grid view for testing -- may need to convert to report at later date.
 
SELECT into VALUE($OUTDEV)
 
	name	=	CONCAT(a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].ptname	,'                                  '),
	room	=	CONCAT(a->qual[d.seq].roomqual[d2.seq].room,'               '),
	mrn		=	a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].mrn,
	fin		=	a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].fin,
	sex		=	CONCAT(a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].sex,'             '),
	age		=	a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].age,
	schappttime = CONCAT(a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].schapptdttm,'                        '),
	timeinroom 	= CONCAT(a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].ptinrmdttm,'                         '),
	ontimestart = a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].ontimestart,
 	delayreason = a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].delayreason
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 (dummyt d3 with seq = 1)
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].roomcnt)
JOIN d2
WHERE MAXREC(d3, a->qual[d.seq].roomqual[d2.seq].apptcnt)
JOIN d3
WHERE a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].printflg= 1
AND a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].surgflg = 1
AND a->qual[d.seq].roomqual[d2.seq].apptqual[d3.seq].staffflg = 1
 
WITH nocounter, format, separator = ' '
 
 
 
CALL ECHORECORD(A)
;GO TO exitscript
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
SUBROUTINE parseDtTm(strdateval)
	;call echo(build('strdateval :', strdateval))
	SET yr = SUBSTRING(3,4,strdateval)
	SET mm = SUBSTRING(7,2,strdateval)
	SET dy = SUBSTRING(9,2,strdateval)
	SET tm = SUBSTRING(11,4,strdateval)
 
	SET ptinroomdttm = CONCAT(mm,'/',dy,'/',yr, ' ',tm)
 
END ;subroutine
 
#exitscript
 
end
go
