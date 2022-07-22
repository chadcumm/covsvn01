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
 
 
drop program cov_prmpt_exam go
create program cov_prmpt_exam

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Start Date/Time" = "SYSDATE"
	, "Select End Date" = "SYSDATE"
	, "Select Facility" = 3144499.00
	, "Select Unit" = 0 

with OUTDEV, startdate, enddate, facility, unit


DECLARE emergcd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 71, 'EMERGENCY')), PROTECT
DECLARE woundcd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DESCRIPTION', 72, 'Dressing-Incision/Wound #1')), PROTECT  



 
FREE RECORD a
RECORD a
(
1	rec_cnt		=	i4
1	qual[*]
	2	personid	=	f8
	2	encntrid	=	f8
	2	name		=	vc
	2	mrn			=	vc
	2	fin			=	vc
	2	age			=	vc
	2	unit		=	vc
	2	frmcnt		=	i4
	2	frmqual[*]
		3	dcp_frms_act_id	=	f8
		3	frmname	=	vc
		3	formdttm	=	vc
		3	eventid		=	f8
		3	resultcnt	=	i4
		3	resultqual[*]
			4 section	= vc
			4 result  =	vc
			4 eventid = f8
			4 perfdttm = vc
			4 eventtitle = vc
 
 
)

;CHECK CV'S
CALL ECHO(BUILD('emergency cd :', emergcd))
CALL ECHO(BUILD('wound cd :', woundcd)) 
CALL ECHO ('Main Query Select')
SELECT into 'nl:'
 
 
FROM encounter e,
	 person p,
	 encntr_alias ea,
	 person_alias pa
 
PLAN e
WHERE e.encntr_type_cd =      309310.00 ;emergency
AND e.reg_dt_tm BETWEEN CNVTDATETIME($startdate)
AND CNVTDATETIME($enddate)
AND e.loc_nurse_unit_cd = $unit
AND e.active_ind = 1
JOIN p
WHERE e.person_id = p.person_id
AND p.active_ind = 1
JOIN ea
WHERE e.encntr_id = ea.encntr_id
AND ea.encntr_alias_type_cd = 1077.00
JOIN pa
WHERE p.person_id = pa.person_id
AND pa.person_alias_type_cd = 2.00
AND pa.active_ind = 1
AND pa.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")
 
 
ORDER BY p.name_full_formatted
 
HEAD REPORT
	cnt = 0
DETAIL
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(a->qual, cnt + 9)
 
	endif
	a->qual[cnt].personid	=	p.person_id
	a->qual[cnt].encntrid	=	e.encntr_id
	a->qual[cnt].name		=	TRIM(p.name_full_formatted)
	a->qual[cnt].mrn		=	TRIM(pa.alias)
	a->qual[cnt].fin		=	TRIM(ea.alias)
	a->qual[cnt].age		=	CNVTAGE(p.birth_dt_tm)
	a->qual[cnt].unit		=	UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
	a->rec_cnt				=	cnt
FOOT REPORT
	stat = alterlist(a->qual, cnt)
WITH nocounter
 
 
;CALL ECHORECORD(a)
;GO TO exitscript
;
 
CALL ECHO('Get Forms')
SELECT into 'nl:'
 
FROM (dummyt  d with seq = a->rec_cnt),
	 dcp_forms_activity dfa,
	 dcp_forms_activity_comp dfac
 
PLAN d
JOIN dfa
WHERE a->qual[d.seq].encntrid = dfa.encntr_id
AND dfa.form_dt_tm >= CNVTDATETIME($startdate)
JOIN dfac
WHERE dfa.dcp_forms_activity_id = dfac.dcp_forms_activity_id
AND dfac.component_cd = 10891.00
HEAD dfa.encntr_id
	cnt = 0
DETAIL
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(a->qual[d.seq].frmqual, cnt + 9)
 
	endif
 
	a->qual[d.seq].frmqual[cnt].dcp_frms_act_id	=	dfa.dcp_forms_activity_id
	a->qual[d.seq].frmqual[cnt].frmname			= dfa.description
	a->qual[d.seq].frmqual[cnt].formdttm		= FORMAT(dfa.form_dt_tm,"mm/dd/yyyy hh:mm;;q")
	a->qual[d.seq].frmqual[cnt].eventid			= dfac.parent_entity_id
	a->qual[d.seq].frmcnt				=	cnt
 
FOOT dfa.encntr_id
	stat = alterlist(a->qual[d.seq].frmqual, cnt)
 
WITH nocounter
 
;CALL ECHORECORD(a)
;GO TO exitscript
 
CALL ECHO('Get Form Results')
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 clinical_event ce,
	 clinical_event ce2
 
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].frmcnt)
JOIN d2
JOIN ce
WHERE a->qual[d.seq].frmqual[d2.seq].eventid = ce.parent_event_id
AND ce.event_reltn_cd = 132.00
AND ce.result_status_cd = 25.00
AND ce.valid_until_dt_tm = CNVTDATETIME("31-dec-2100 0")
JOIN ce2
WHERE ce.event_id = ce2.parent_event_id
 
 
HEAD ce.parent_event_id
 
	cnt = 0
 
DETAIL
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
		stat = alterlist(a->qual[d.seq].frmqual[d2.seq].resultqual, cnt + 9)
	endif
	a->qual[d.seq].frmqual[d2.seq].resultqual[cnt].section = TRIM(ce.event_title_text)
	a->qual[d.seq].frmqual[d2.seq].resultqual[cnt].result = TRIM(ce2.result_val)
	a->qual[d.seq].frmqual[d2.seq].resultqual[cnt].eventid = ce2.event_id
	a->qual[d.seq].frmqual[d2.seq].resultqual[cnt].perfdttm = FORMAT(ce2.performed_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[d.seq].frmqual[d2.seq].resultqual[cnt].eventtitle = TRIM(ce2.event_title_text)
FOOT ce.parent_event_id
	stat = alterlist(a->qual[d.seq].frmqual[d2.seq].resultqual, cnt)
 
WITH nocounter
 
CALL ECHORECORD(a)
GO TO exitscript
 
 
 
#exitscript
 
 
end
go
