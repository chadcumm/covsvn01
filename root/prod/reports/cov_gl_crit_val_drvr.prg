/**********************************************************************************
Author		 	:	Mike Layman
Date Written 	:	07/03/18
Program Title	:	Critical Value Report
Source File	 	:	cov_gl_crit_val_drvr.prg
Object Name		:	cov_gl_crit_val_drvr
Directory	 	:  	cust_script
DVD version  	:  	2017.11.1.81
HNA version  	:   01Oct2012
CCL version  	:   8.8.3
Purpose      	:	This script will serve as a driver script
					for a layout report. This will select any
					critical lab values that were posted for
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
drop program cov_gl_crit_val_drvr go
create program cov_gl_crit_val_drvr
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 0
	, "Select Begin Date/time" = "SYSDATE"
	, "Select End Date/Time" = "SYSDATE" 

with OUTDEV, Facility, begdate, enddate
 
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
;FREE RECORD a
RECORD a
(
1	rec_cnt	=	i4
1	facility	=	vc
1	qual[*]
	2	personid	=	f8
	2	encntrid	=	f8
	2	name		=	vc
	2	mrn			=	vc
	2	fin			=	vc
	2	unit		=	vc
	2	room		=	vc
	2	bed			=	vc
	2	loc			=	vc
	2	labcnt		=	i4
	2	labqual[*]
		3	eventid		=	f8
		3	eventcd		=	f8
		3	eventname	=	vc
		3	result		=	vc
		3	units		=	vc
		3	flag		=	vc
		3	accnbr		=	vc
		3	drawndttm	=	vc
		3	verdttm		=	vc
		3	verdatetm	=	f8
		3	verprsnl	=	vc
		3	prevresult	=	vc
		3	prevresdttm	=	vc
		3	rescomm		=	vc
		3	Instrument	=	vc
		3	resultid	=	f8
)
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
DECLARE critflag = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',52, 'CRIT')), PROTECT
DECLARE authvercd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',8,'AUTHVERIFIED')), PROTECT
DECLARE modifiedcd = f8 WITH CONSTANT(UAR_GET_CODE_BY('MEANING',8,'MODIFIED')), PROTECT
DECLARE alteredcd = f8 WITH CONSTANT(UAR_GET_CODE_BY('MEANING', 8, 'ALTERED')), PROTECT
DECLARE mrn		=	f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',4,'MRN')), PROTECT
DECLARE fin		=	f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',319,'FINNBR')), PROTECT
DECLARE faccd	=	f8 WITH NOCONSTANT(0.0), PROTECT
DECLARE aliascd	=	f8 WITH NOCONSTANT(0.0), PROTECT
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
CALL ECHO(BUILD('critflag :', critflag))
CALL ECHO(BUILD('authvercd :', authvercd))
CALL ECHO(BUILD('modifiedcd :', modifiedcd))
CALL ECHO(BUILD('alteredcd :', alteredcd))
 
 
 
SELECT into 'nl:'
 
FROM location l
WHERE l.organization_id = $facility
AND l.location_type_cd = 783.00
AND l.active_ind = 1
 
DETAIL
 
	faccd = l.location_cd
 	a->facility = UAR_GET_CODE_DISPLAY(faccd)
WITH nocounter
 
 
SELECT into 'nl:'
 
FROM code_value cv
WHERE cv.code_set = 263
AND cv.display = 'STAR MRN -*'
 
DETAIL
 
	if (cv.display = BUILD2('STAR MRN - ',UAR_GET_CODE_DISPLAY(faccd)))
 
		aliascd = cv.code_value
 
	endif
WITH nocounter
 
 
CALL ECHO(BUILD('aliascd :', aliascd))
CALL ECHO(BUILD('faccd :', faccd))
 
 
;Find critical results
SELECT into 'nl:'
 
FROM clinical_event ce,
	 result r,
	 perform_result pe,
	 container c,
	 encounter e,
	 person p,
	 encntr_alias ea,
	 person_alias pa,
	 prsnl pr
 
PLAN ce
WHERE ce.performed_dt_tm BETWEEN CNVTDATETIME($begdate)
AND CNVTDATETIME($enddate)
AND ce.normalcy_cd = critflag
AND ce.result_status_cd IN (authvercd, modifiedcd, alteredcd)
AND ce.valid_until_dt_tm = CNVTDATETIME("31-DEC-2100 0")
JOIN r
WHERE ce.order_id = r.order_id
AND ce.task_assay_cd = r.task_assay_cd
JOIN pe
WHERE r.result_id = pe.result_id
;AND pe.service_resource_cd = $Instrument
JOIN c
WHERE OUTERJOIN(pe.container_id) = c.container_id
JOIN e
WHERE ce.encntr_id = e.encntr_id
AND e.loc_facility_cd = faccd
AND e.active_ind = 1
JOIN p
WHERE e.person_id = p.person_id
AND p.active_ind = 1
JOIN ea
WHERE e.encntr_id = ea.encntr_id
AND ea.encntr_alias_type_cd = fin
AND ea.active_ind = 1
AND ea.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")
JOIN pa
WHERE p.person_id = pa.person_id
AND pa.person_alias_type_cd = mrn
AND pa.alias_pool_cd = aliascd
AND pa.active_ind = 1
AND pa.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")
JOIN pr
WHERE ce.verified_prsnl_id = pr.person_id
AND pr.active_ind = 1
 
HEAD REPORT
 
	cnt = 0
 
HEAD e.encntr_id
 
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(a->qual, cnt + 9)
 
	endif
	a->qual[cnt].encntrid	=	e.encntr_id
	a->qual[cnt].personid	=	p.person_id
	a->qual[cnt].name		=	TRIM(p.name_full_formatted)
	a->qual[cnt].mrn		=	TRIM(pa.alias)
	a->qual[cnt].fin		=	TRIM(ea.alias)
	a->qual[cnt].unit		=	UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
	a->qual[cnt].room		=	UAR_GET_CODE_DISPLAY(e.loc_room_cd)
	a->qual[cnt].bed		=	UAR_GET_CODE_DISPLAY(e.loc_bed_cd)
	a->qual[cnt].loc		=	BUILD2(a->qual[cnt].unit,' ', a->qual[cnt].room,
								' / ',a->qual[cnt].bed)
	a->rec_cnt				=	cnt
	rcnt = 0
DETAIL
	rcnt = rcnt + 1
	if (mod(rcnt,10) = 1 or rcnt = 1)
 
		stat = alterlist(a->qual[cnt].labqual, rcnt + 9)
 
	endif
	a->qual[cnt].labqual[rcnt].accnbr	=	CNVTACC(ce.accession_nbr)
	a->qual[cnt].labqual[rcnt].eventcd	=	ce.event_cd
	a->qual[cnt].labqual[rcnt].eventid	=	ce.event_id
	a->qual[cnt].labqual[rcnt].eventname=	UAR_GET_CODE_DISPLAY(ce.event_cd)
	a->qual[cnt].labqual[rcnt].flag		=	UAR_GET_CODE_DISPLAY(ce.normalcy_cd)
	a->qual[cnt].labqual[rcnt].result	=	TRIM(ce.result_val)
	a->qual[cnt].labqual[rcnt].units	=	UAR_GET_CODE_DISPLAY(ce.result_units_cd)
	a->qual[cnt].labqual[rcnt].verdttm	=	FORMAT(ce.verified_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].labqual[rcnt].verdatetm=	ce.verified_dt_tm
	a->qual[cnt].labqual[rcnt].verprsnl	=	TRIM(pr.name_full_formatted)
	a->qual[cnt].labqual[rcnt].Instrument = UAR_GET_CODE_DISPLAY(pe.service_resource_cd)
	a->qual[cnt].labqual[rcnt].resultid	=	r.result_id
	a->qual[cnt].labqual[rcnt].drawndttm =	FORMAT(c.drawn_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].labcnt					=	rcnt
FOOT e.encntr_id
	stat = alterlist(a->qual[cnt].labqual, rcnt)
FOOT REPORT
	stat = alterlist(a->qual, cnt)
 
 
WITH nocounter
 
;Get previous results
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 clinical_event ce
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].labcnt)
JOIN d2
JOIN ce
WHERE A->qual[d.seq].personid = ce.person_id
AND a->qual[d.seq].labqual[d2.seq].eventcd = ce.event_cd
AND a->qual[d.seq].encntrid	=	ce.encntr_id
AND ce.performed_dt_tm < CNVTDATETIME(a->qual[d.seq].labqual[d2.seq].verdatetm)
 
 
HEAD ce.encntr_id
	prevresfnd = 0
 
DETAIL
 
	if (prevresfnd = 0)
		a->qual[d.seq].labqual[d2.seq].prevresult	=	ce.result_val
		a->qual[d.seq].labqual[d2.seq].prevresdttm	=	FORMAT(ce.performed_dt_tm, "mm/dd/yyyy hh:mm;;q")
	endif
 
	prevresfnd = 1
 
 
WITH nocounter
 
;Get Result Comments
 
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 result_comment rc,
	 long_text lt
 
PLAN d
WHERE MAXREC(d2,a->qual[d.seq].labcnt)
JOIN d2
JOIN rc
WHERE a->qual[d.seq].labqual[d2.seq].resultid = rc.result_id
JOIN lt
WHERE rc.long_text_id = lt.long_text_id
 
DETAIL
 
	a->qual[d.seq].labqual[d2.seq].rescomm = REPLACE(TRIM(lt.long_text),CONCAT(CHAR(13),CHAR(10)),' ')
 	
 	
 
 
WITH NOCOUNTER
 
 
CALL ECHORECORD(a)
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
#exitscript
 
end
go
 
