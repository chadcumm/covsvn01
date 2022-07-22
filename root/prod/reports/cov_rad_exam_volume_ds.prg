/***********************************************************
Author 			:	Mike Layman
Date Written	:	10/31/2017
Program Title	:	Radiology Completed Exam Volume for Modality Data Source Program
Source File		:	cov_rad_exam_volume_ds.prg
Object Name		:	cov_rad_exam_volume_ds
Directory		:	cust_script
DVD Version		:	2017.07.1.81
HNA Version		:	2015.01
CCL Version		:	8.8.3
Purpose			: 	This program will create a data source that can
					be used within DA2 to create a report for Radiology that
					includes the breakdown of completed exams by modality for
					a given facility.
Tables Read		:	person, encounter, clinical_event, orders, rad_exam
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
drop program cov_rad_exam_volume_ds go
create program cov_rad_exam_volume_ds
 
prompt
	"Facility" = 0
	, "Begin Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
 
with facility, bdate, edate
 
 
EXECUTE CCL_PROMPT_API_DATASET "autoset"
 
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
	2	orderid			=	f8
	2	ordername		=	vc
	2	modality		=	vc
	2	accession		=	vc
	2	orderdate		=	vc
	2	activatedate	=	vc
	2	completeddttm	= 	vc
 	2	startdttm		= 	vc
 	2	startdate		=	f8
 	2	finaldttm		=	vc
 	2	finaldate		=	f8
 	2	ordtostarttat	=	i4
 	2	starttocomptat	=	i4
 	2	comptofintat	=	i4
 	2	ordtofinaltat	=	i4
 	2	acttostart		=	i4
 	2	acttofinaltat	=	i4
 	2	radiologist		=	vc
 
)
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
DECLARE radacttype = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',106, 'RADIOLOGY')), PROTECT
DECLARE completed = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 6004,'COMPLETED')), PROTECT
DECLARE activated = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6003,'ACTIVATE')), PROTECT
DECLARE dptcomplt = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 14281, 'COMPLETED')), PROTECT
DECLARE dynmodsql = vc WITH NOCONSTANT(FILLSTRING(500,' ')), PROTECT
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
CALL ECHO(BUILD('radacttype :', radacttype))
CALL ECHO(BUILD('completed :', completed))
CALL ECHO(BUILD('activated :', activated))
CALL ECHO(BUILD('dptcomplt :', dptcomplt))
 
 
 
SELECT into 'nl:'
 
FROM orders o,
	 order_radiology orad,
	 ;order_action oa,
	 encounter e,
	 person p,
	 accession a,
	 rad_exam ra,
	 rad_report rr,
	 rad_report_prsnl rrp,
	 prsnl pr
 
PLAN ra
WHERE ra.complete_dt_tm BETWEEN CNVTDATETIME($bdate)
AND CNVTDATETIME($edate)
JOIN o
WHERE ra.order_id = o.order_id
;o.orig_order_dt_tm BETWEEN CNVTDATETIME($bdate)
;AND CNVTDATETIME($edate)
AND o.activity_type_cd = radacttype
AND o.dept_status_cd = dptcomplt
AND o.order_status_cd = completed
;JOIN oa
;WHERE o.order_id = oa.order_id
;AND oa.action_type_cd = activated
;AND oa.action_dt_tm BETWEEN CNVTDATETIME($bdate)
;AND CNVTDATETIME($edate)
JOIN e
WHERE o.encntr_id = e.encntr_id
AND e.loc_facility_cd = $facility
AND e.active_ind = 1
JOIN p
WHERE e.person_id = p.person_id
AND p.active_ind = 1
JOIN orad
WHERE o.order_id = orad.order_id
JOIN a
WHERE orad.accession_id = a.accession_id
JOIN rr
WHERE o.order_id = rr.order_id
JOIN rrp
WHERE rr.rad_report_id = rrp.rad_report_id
AND rrp.prsnl_relation_flag = 2
JOIN pr
WHERE rrp.report_prsnl_id = pr.person_id
 
 
ORDER BY o.order_id, ra.rad_exam_id
 
HEAD REPORT
 
	cnt = 0
 
HEAD ra.rad_exam_id
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(a->qual, cnt + 9)
 
	endif
 
	a->qual[cnt].encntrid		=	e.encntr_id
	a->qual[cnt].personid		=	p.person_id
	a->qual[cnt].accession		=	CNVTACC(orad.accession)
	a->qual[cnt].orderdate		=	FORMAT(o.orig_order_dt_tm,"mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].orderid		=	o.order_id
	a->qual[cnt].ordername		=	TRIM(o.hna_order_mnemonic)
	a->qual[cnt].modality		=	UAR_GET_CODE_DISPLAY(a.accession_format_cd)
	a->qual[cnt].completeddttm	=	FORMAT(ra.complete_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].startdttm		=	FORMAT(ra.starting_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].startdate		=	ra.starting_dt_tm
	a->qual[cnt].finaldttm		=	FORMAT(rr.final_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].finaldate		=	rr.final_dt_tm
	a->qual[cnt].ordtostarttat	= DATETIMEDIFF(ra.starting_dt_tm,o.orig_order_dt_tm,4)
	a->qual[cnt].starttocomptat	= DATETIMEDIFF(ra.complete_dt_tm,ra.starting_dt_tm,4 )
	a->qual[cnt].comptofintat	= DATETIMEDIFF(rr.final_dt_tm,ra.complete_dt_tm, 4)
	a->qual[cnt].ordtofinaltat	= DATETIMEDIFF(rr.final_dt_tm,o.orig_order_dt_tm,4 )
	a->qual[cnt].radiologist	= TRIM(pr.name_full_formatted)
	a->rec_cnt					=	cnt
 
FOOT REPORT
	stat = alterlist(a->qual, cnt )
 
WITH nocounter
 
;Get activate date for future orders
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 order_action oa
 
PLAN d
JOIN oa
WHERE a->qual[d.seq].orderid = oa.order_id
AND oa.action_type_cd = activated
 
DETAIL
 
	a->qual[d.seq].activatedate = FORMAT(oa.action_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[d.seq].acttostart		=	DATETIMEDIFF(CNVTDATETIME(a->qual[d.seq].startdate), oa.action_dt_tm,4)
	a->qual[d.seq].acttofinaltat	= DATETIMEDIFF(CNVTDATETIME(a->qual[d.seq].finaldate), oa.action_dt_tm, 4)
WITH nocounter
 
 
SELECT IF (CNVTINT(GetParameter("_PREPARE_")) = 1)
	with NOCOUNTER, REPORTHELP, CHECK, MAXREC = 1
ELSE
	WITH NOCOUNTER, REPORTHELP, CHECK
ENDIF
 
into 'nl:'
 
	accession = a->qual[d.seq].accession,
	modality = a->qual[d.seq].modality,
	ordername = a->qual[d.seq].ordername,
	orderdate = if (a->qual[d.seq].activatedate >' ')
		a->qual[d.seq].activatedate
	else
		a->qual[d.seq].orderdate
	endif,
 
	a->qual[d.seq].orderdate,
	completeddate = a->qual[d.seq].completeddttm,
	startdate = a->qual[d.seq].startdttm,
	finaldate = a->qual[d.seq].finaldttm,
	ordtostart = if (a->qual[d.seq].activatedate > ' ')
		a->qual[d.seq].acttostart
		else
		a->qual[d.seq].ordtostarttat
		endif,
 
	starttocomp = a->qual[d.seq].starttocomptat,
	comptofin = a->qual[d.seq].comptofintat,
	ordtofin = if (a->qual[d.seq].activatedate > ' ')
		a->qual[d.seq].acttofinaltat
		else
		a->qual[d.seq].ordtofinaltat
		endif,
	radiologist = a->qual[d.seq].radiologist
 
 
 
 
FROM (dummyt d with seq = a->rec_cnt)
 
HEAD REPORT
 
	stat = MakeDataSet(200)
DETAIL
	stat = WriteRecord(0)
FOOT REPORT
	stat = CloseDataSet(0)
WITH ReportHelp, Check
 
 
 
CALL ECHORECORD(a)
;GO TO exitscript
 
 
 
 
 
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
#exitscript
end
go
