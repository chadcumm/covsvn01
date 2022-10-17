/***********************************************************
Author 			:	Mike Layman
Date Written	:	01/03/2019
Program Title	:	Pathnet Cancellation Report
Source File		:	cov_gl_cancel_rpt.prg
Object Name		:	cov_gl_cancel_rpt
Directory		:	cust_script
DVD Version		:	2017.07.1.81
HNA Version		:	2015.01
CCL Version		:	8.8.3
Purpose			: 	This program will display all laboratory orders
					that were cancelled, and the reasons they were
					cancelled.
Tables Read		:	person, encounter, encntr_alias, person_alias,
					orders, order_action, container, container_event
Tables Updated	:	NA
Include File	:	NA
Shell Scripts	:	NA
Executing App	:	Reporting Portal
Special Notes	:
Usage			:
Mod		Date		Engineer				Comment
----    ----------- ----------------------- ---------------------------
001		01/03/2019	Mike Layman				Original Release
 
 
$LastChangedBy::							$:
$LastChangedDate::							$:
$LastChangedRevision::						$:
 
 
 
 
************************************************************/
drop program cov_gl_cancel_rpt go
create program cov_gl_cancel_rpt
 
prompt
	"Output to File/Printer/MINE" = "MINE"                  ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 0
	, "Select Nursing Unit" = VALUE(1.0)
	, "Select Ordering Physician" = VALUE(1.0           )
	, "Select Cancel Reason" = VALUE(1.0           )
	, "Select the Begin Date" = "SYSDATE"
	, "Select the End Date" = "SYSDATE"
 
with OUTDEV, facility, unit, ordphys, cancelrsn, bdate, edate
 
 
 
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
	2	name		=	vc
	2	mrn			=	vc
	2	fin			=	vc
	2	testname	=	vc
	2	colldttm	=	vc
	2	collprsnl	=	vc
	2	accession	=	vc
	2	canceldttm	=	vc
	2	cancelprsnl	=	vc
	2	cancelrsn	=	vc
	2	orderphys	=	vc
	2	viewflg		=	i2
 
 
)
 
 
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
DECLARE cancelcd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 6004, 'CANCELED')), PROTECT
DECLARE dcancelcd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',14281,'CANCELED')), PROTECT
DECLARE actcancelcd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6003,'CANCEL')), PROTECT
DECLARE ordercd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6003,'ORDER')), PROTECT
DECLARE genlabcd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 106, 'GENERALLAB')), PROTECT
DECLARE microcd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 106, 'MICRO')), PROTECT
DECLARE bbcd = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 106, 'BLOODBANK')), PROTECT
DECLARE expsz			=	i4 with constant(200), PROTECT
DECLARE expstart 		= 	i4 with noconstant(1), PROTECT
DECLARE expstop			= 	i4 with noconstant(200), PROTECT
DECLARE actsz			=	i4 with noconstant(0), PROTECT
DECLARE exptot			=	i4 with noconstant(0), PROTECT
DECLARE indx			=	i4 with noconstant(0), PROTECT
DECLARE unitop			=	vc WITH NOCONSTANT(FILLSTRING(2,' ')), PROTECT
DECLARE physop			=	vc WITH NOCONSTANT(FILLSTRING(2,' ')), PROTECT
DECLARE cancelrsnop		=	vc WITH NOCONSTANT(FILLSTRING(2,' ')), PROTECT
DECLARE sortkey 		=	VC WITH NOCONSTANT(fillstring(25,' ')), PROTECT
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
CALL ECHO(BUILD('cancelcd :',cancelcd))
CALL ECHO(BUILD('dcancelcd :',dcancelcd))
CALL ECHO(BUILD('genlabcd :',genlabcd))
CALL ECHO(BUILD('microcd :',microcd))
CALL ECHO(BUILD('bbcd :',bbcd))
CALL ECHO(BUILD('actcancelcd :',actcancelcd))
CALL ECHO(BUILD('ordercd :',ordercd))
 
;prompt set up
;unit
IF (SUBSTRING(1,1,reflect(parameter(parameter2($unit),0)))="L")
 
	SET unitop = "IN"
ELSEIF (parameter(parameter2($unit),1) = 1.0)
	SET unitop = "!="
ELSE
	SET unitop = "="
ENDIF
 
;ordering physician
IF (SUBSTRING(1,1,reflect(parameter(parameter2($ordphys),0)))="L")
 
	SET physop = "IN"
ELSEIF (parameter(parameter2($ordphys),1) = 1.0)
	SET physop = "!="
ELSE
	SET physop = "="
ENDIF
 
;cancel reason
IF (SUBSTRING(1,1,reflect(parameter(parameter2($cancelrsn),0)))="L")
 
	SET cancelrsnop = "IN"
ELSEIF (parameter(parameter2($cancelrsn),1) = 1.0)
	SET cancelrsnop = "!="
ELSE
	SET cancelrsnop = "="
ENDIF
 
;SortKey
;SET inum = 0
;DECLARE par = vc
;IF (SUBSTRING(1,1,reflect(parameter(parameter2($sortkey),0)))="L")
;
;	SET inum = 1
;
;	WHILE (inum>0)
;		SET par = REFLECT(PARAMETER(PARAMETER2($sortkey),inum))
;
;		IF(par = " ")
;
;
;			SET inum = 0
;		ELSE
;
;			SET sortkey = CONCAT(sortkey,CNVTSTRING(PARAMETER(PARAMETER2($SORTKEY),inum)))
;
;			SET inum = inum + 1
;		ENDIF
;
;
;	ENDWHILE
;
;
;ENDIF
;
;CALL ECHO(BUILD('SORTKEY :', sortkey))
;GO TO exitscript
 
;Get Cancelled orders
CALL ECHO('Getting Cancelled Orders')
SELECT into 'nl:'
 
FROM orders o,
	 encounter e,
	 person p,
	 accession_order_r aor,
	 order_action oa,
	 prsnl pr
 
 
PLAN o
WHERE o.activity_type_cd IN (genlabcd, microcd, bbcd)
AND o.dept_status_cd = dcancelcd
AND o.orig_order_dt_tm BETWEEN CNVTDATETIME($bdate)
AND CNVTDATETIME($edate)
JOIN e
WHERE o.encntr_id = e.encntr_id
AND e.organization_id = $facility
AND operator(e.loc_nurse_unit_cd,unitop,$unit)
AND e.active_ind = 1
JOIN p
WHERE e.person_id = p.person_id
AND p.active_ind = 1
JOIN aor
WHERE o.order_id = aor.order_id
JOIN oa
WHERE o.order_id = oa.order_id
AND oa.action_type_cd = ordercd
AND operator(OA.order_provider_id,physop,$ordphys)
JOIN pr
WHERE oa.order_provider_id = pr.person_id
 
HEAD REPORT
 
	cnt = 0
 
DETAIL
 
	cnt = cnt + 1
	if (mod (cnt,10) = 1 or cnt = 1)
		stat = alterlist(a->qual, cnt + 9)
	endif
 
	a->qual[cnt].personid	=	p.person_id
	a->qual[cnt].encntrid	=	e.encntr_id
	a->qual[cnt].name		=	TRIM(p.name_full_formatted)
	a->qual[cnt].testname	=	UAR_GET_CODE_DISPLAY(o.catalog_cd)
	a->qual[cnt].accession	=	CNVTACC(aor.accession)
	a->qual[cnt].orderid	=	o.order_id
	a->qual[cnt].orderphys  = 	TRIM(pr.name_full_formatted)
	a->rec_cnt				=	cnt
 
FOOT REPORT
	stat = alterlist(a->qual, cnt)
 
WITH nocounter
 
 
;CALL ECHORECORD(a)
;GO TO exitscript
 
;set up expand
SET actsz = a->rec_cnt
SET exptot = actsz + (expsz - mod(actsz,expsz))
 
call echo(BUILD('actsz :', actsz))
call echo(BUILD('expsz :', expsz))
call echo (BUILD('exptot :', exptot))
 
SET stat = alterlist(a->qual, exptot)
 
FOR (idx = actsz+1 to exptot)
 
	SET a->qual[idx].orderid = a->qual[actsz].orderid
 
ENDFOR
 
 
;Get Cancelled Order Action Personnel Info
CALL ECHO('Get Cancel Action Personnel Info')
SELECT into 'nl:'
 
FROM (dummyt d with seq = exptot/expsz),
	 order_action oa,
	 prsnl pr
 
 
PLAN d
WHERE assign(expstart,evaluate(d.seq,1,1,expstart+expsz))
and assign(expstop,expstart+(expsz-1))
JOIN oa
WHERE EXPAND(indx,expstart,expstop,oa.order_id,a->qual[indx].orderid)
AND oa.action_type_cd = actcancelcd
JOIN pr
WHERE oa.action_personnel_id = pr.person_id
 
HEAD REPORT
 
	;stat = alterlist(a->qual, actsz)
	pos = 0
	idx = 0
HEAD oa.order_id
 
	pos = locateval(idx,1,a->rec_cnt,oa.order_id,a->qual[idx].orderid)
;
DETAIL
	a->qual[pos].cancelprsnl = TRIM(pr.name_full_formatted)
	a->qual[pos].canceldttm  = FORMAT(oa.action_dt_tm, "mm/dd/yyyy hh:mm;;q")
 
FOOT oa.order_id
	pos = 0
	idx = 0
FOOT REPORT
	stat = alterlist(a->qual, actsz)
WITH nocounter
 
 
 
 
;set up expand
SET indx = 0
SET actsz = a->rec_cnt
SET exptot = actsz + (expsz - mod(actsz,expsz))
 
call echo(BUILD('actsz :', actsz))
call echo(BUILD('expsz :', expsz))
call echo (BUILD('exptot :', exptot))
 
SET stat = alterlist(a->qual, exptot)
 
FOR (idx = actsz+1 to exptot)
 
	SET a->qual[idx].orderid = a->qual[actsz].orderid
 
ENDFOR
 
;Get Collection Time
Call echo ('Get Collection Time/personnel')
 
 
SELECT into 'nl:'
 
FROM (dummyt d with seq = exptot/expsz),
	 order_container_r ocr,
	 container c,
	 prsnl pr
 
PLAN d
WHERE assign(expstart,evaluate(d.seq,1,1,expstart+expsz))
and assign(expstop,expstart+(expsz-1))
JOIN ocr
WHERE EXPAND(indx,expstart,expstop,ocr.order_id,a->qual[indx].orderid)
JOIN c
WHERE ocr.container_id = c.container_id
JOIN pr
WHERE c.drawn_id = pr.person_id
 
HEAD REPORT
	pos = 0
	idx = 0
 
HEAD ocr.order_id
	pos = locateval(idx,1,a->rec_cnt,ocr.order_id,a->qual[idx].orderid)
 
DETAIL
	a->qual[pos].colldttm = FORMAT(c.drawn_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[pos].collprsnl = TRIM(pr.name_full_formatted)
 
FOOT ocr.order_id
	pos = 0
	idx = 0
 
FOOT report
	stat = alterlist(a->qual, actsz)
 
WITH nocounter
 
 
;set up expand
SET indx = 0
SET actsz = a->rec_cnt
SET exptot = actsz + (expsz - mod(actsz,expsz))
 
call echo(BUILD('actsz :', actsz))
call echo(BUILD('expsz :', expsz))
call echo (BUILD('exptot :', exptot))
 
SET stat = alterlist(a->qual, exptot)
 
FOR (idx = actsz+1 to exptot)
 
	SET a->qual[idx].orderid = a->qual[actsz].orderid
 
ENDFOR
 
SELECT into 'nl:'
 
FROM (dummyt d with seq = exptot/expsz),
	 order_detail od
 
PLAN d
WHERE assign(expstart,evaluate(d.seq,1,1,expstart+expsz))
and assign(expstop,expstart+(expsz-1))
JOIN od
WHERE EXPAND(indx,expstart,expstop,od.order_id,a->qual[indx].orderid)
AND od.oe_field_meaning = 'CANCELREASON'
AND operator(od.oe_field_value,cancelrsnop,$cancelrsn)
 
HEAD REPORT
	pos = 0
	idx = 0
HEAD od.order_id
	pos = locateval(idx,1,a->rec_cnt,od.order_id, a->qual[idx].orderid)
 
DETAIL
	a->qual[pos].cancelrsn = TRIM(od.oe_field_display_value)
	a->qual[pos].viewflg = 1
FOOT od.order_id
	pos = 0
	idx = 0
FOOT REPORT
	stat = alterlist(a->qual, actsz)
 
 
 
	FOR (icnt = 1 to A->rec_cnt)
		if ($cancelrsn = 1.0)
 
			if (SIZE(a->qual[icnt].cancelrsn) = 0)
 
				a->qual[icnt].viewflg = 1
 
			endif
 
		endif
 
 
	ENDFOR
 
 
WITH nocounter
 
SELECT into $outdev
	TestName = CONCAT(a->qual[d.seq].testname,'                                     '),
	PatientName = CONCAT(a->qual[d.seq].name,'                                       '),
	CollectedBy = CONCAT(a->qual[d.seq].collprsnl,'                                  '),
	CollectedDateTime = CONCAT(a->qual[d.seq].colldttm,'                          '),
	CancelledDateTime = CONCAT(a->qual[d.seq].canceldttm,'                        '),
	CancelledReason = CONCAT(a->qual[d.seq].cancelrsn,'                                '),
	AccessionNbr = CONCAT(a->qual[d.seq].accession,'                                ')
 
FROM (dummyt d with seq = a->rec_cnt)
WHERE a->qual[d.seq].viewflg = 1
 
WITH nocounter, FORMAT, separator = ' '
 
 
 
 
 
 
 
 
CALL ECHORECORD(a)
GO TO exitscript
 
 
 
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
 
#exitscript
 
end
go
