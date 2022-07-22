/***********************************************************
Author 			:	Mike Layman
Date Written	:	03/20/2018
Program Title	:	Radiology PACS Extract
Source File		:	cov_rad_pacs_xtrct.prg
Object Name		:	cov_rad_pacs_xtrct
Directory		:	cust_script
DVD Version		:	2017.11.1.81
HNA Version		:	2015.01
CCL Version		:	8.8.3
Purpose			: 	This program will create a daily extract for the results
					coming from PACS that will be used by RevCycle for financial
					updates.
Tables Read		:	order_radiology, encoutner, person, encntr_alias, person_alias
Tables Updated	:	NA
Include File	:	NA
Shell Scripts	:	NA
Executing App	:	Explorer Menu
Special Notes	:
Usage			:	cov_rad_pacs_xtrct "mine" go
Mod		Date		Engineer				Comment
----    ----------- ----------------------- ---------------------------
001		03/20/2018	Mike Layman				Original Release
 
 
$LastChangedBy::							$:
$LastChangedDate::							$:
$LastChangedRevision::						$:
 
 
 
 
************************************************************/
drop program cov_rad_pacs_xtrct go
create program cov_rad_pacs_xtrct
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Begin Date/Time" = "SYSDATE"
	, "Select End Date/Time" = "SYSDATE"
 
with OUTDEV, begdate, enddate
 
 
/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
**************************************************************/
FREE RECORD a
RECORD a
(
1	rec_cnt		=	i4
1	qual[*]
	2	personid		=	f8
	2	encntrid		=	f8
	2	name			=	vc
	2	mrn				=	vc
	2	fin				=	vc
	2	accessionnbr	=	vc
	2	orderid			=	f8
	2	examname		=	vc
	2	hostname		=	vc
 
 
)
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
DECLARE xrcompletests = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',14192,'COMPLETED')), PROTECT
DECLARE mrn = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',4,'COMMUNITYMEDICALRECORDNUMBER')), PROTECT
DECLARE fin = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',319,'FINNBR')), PROTECT
DECLARE authver = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 8,'AUTHVERIFIED')), PROTECT
DECLARE hostname = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAY_KEY', 72, 'HOSTNAME')), PROTECT
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
 
;check cv's
CALL ECHO(BUILD('xrcompletests :', xrcompletests))
CALL ECHO(BUILD('mrn :', mrn))
CALL ECHO(BUILD('fin :', fin))
CALL ECHO(BUILD('authver :', authver))
CALL ECHO(BUILD('hostname :', hostname))
SELECT into 'nl:'
 
FROM order_radiology orad,
	 encounter e,
	 person p,
	 encntr_alias ea,
	 person_alias pa,
	 clinical_event ce
 
PLAN orad
WHERE orad.request_dt_tm BETWEEN CNVTDATETIME($begdate)
AND CNVTDATETIME($enddate)
AND orad.exam_status_cd = xrcompletests
JOIN e
WHERE orad.encntr_id = e.encntr_id
AND e.active_ind = 1
JOIN p
WHERE e.person_id = p.person_id
AND p.active_ind = 1
JOIN ea
WHERE e.encntr_id = ea.encntr_id
AND ea.encntr_alias_type_cd = fin
AND ea.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")
JOIN pa
WHERE p.person_id = pa.person_id
AND pa.person_alias_type_cd = mrn
JOIN ce
WHERE orad.person_id = ce.person_id
AND ce.event_cd = hostname
AND orad.encntr_id = ce.encntr_id
;AND ce.result_status_cd = authver
AND orad.accession = ce.accession_nbr
AND ce.valid_until_dt_tm = CNVTDATETIME("31-DEC-2100 0")
 
 
 
HEAD REPORT
	cnt = 0
 
DETAIL
 
	cnt = cnt + 1
	IF (mod(cnt,10) = 1 OR cnt = 1)
 
		stat = alterlist(a->qual, cnt + 9)
 
	ENDIF
	a->qual[cnt].personid		=	p.person_id
	a->qual[cnt].encntrid		=	e.encntr_id
	a->qual[cnt].name			=	TRIM(p.name_full_formatted)
	a->qual[cnt].mrn			=	TRIM(pa.alias)
	a->qual[cnt].fin			=	trim(ea.alias)
	a->qual[cnt].accessionnbr 	= 	CNVTACC(orad.accession)
	a->qual[cnt].examname		=	UAR_GET_CODE_DISPLAY(orad.catalog_cd)
	a->qual[cnt].orderid		=	orad.order_id
	a->qual[cnt].hostname		=	TRIM(ce.result_val)
 
	a->rec_cnt					=	cnt
 
 
FOOT REPORT
 
	stat = alterlist(a->qual, cnt)
 
WITH nocounter
 
 
 
 
SELECT into VALUE($outdev)
 
	name	=	CONCAT(a->qual[d.seq].name,'                          '),
	mrn		=	CONCAT(a->qual[d.seq].mrn,'                 '),
	fin		=	CONCAT(a->qual[d.seq].fin,'                 '),
	accessionnbr = CONCAT(a->qual[d.seq].accessionnbr,'                 '),
	examname	 = CONCAT(a->qual[d.seq].examname, '                '),
	hostname	 = CONCAT(a->qual[d.seq].hostname, '                ')
 
 
FROM (dummyt d with seq = a->rec_cnt)
 
ORDER BY name, accessionnbr
 
WITH nocounter, format, separator = ' '
 
CALL ECHORECORD(a)
GO TO exitscript
 
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
#exitscript
 
end
go
