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
drop program cov_gl_qc_grid go
create program cov_gl_qc_grid
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Begin Date" = "SYSDATE"
	, "Select End Date" = "SYSDATE"
	, "Select Performing Site" = 0
	, "Select Service Resource" = 0
	, "Select Task Assay" = 0
	, "Select Lot Nbr" = 0
	, "Summary Or Detail" = 0 

with OUTDEV, bdate, edate, perflab, sr, dta, lotnbr, summdet
 
 
FREE RECORD a
RECORD a
(
1	rec_cnt		=	i4
1	facility	=	vc
1	qual[*]
	2	serv_resrc	=	vc
	2	srv_rsrc_cd	=	f8
	2	qc_cnt		=	i4
	2	qcqual[*]
		3	controlid	=	f8
		3	taskassaycd	=	f8
		3	taskname	=	vc
		3	lotnbr		=	vc
		3	startdttm	=	vc
		3	enddttm		=	vc
		3	qcname		=	vc
		3	qclvl		=	vc
		3	sd			=	f8
		3	2sd			=	vc
		3	mean		=	f8
		3 	cv			=	vc
		3	perfdttm	=	vc
		3	alpharesult	=	vc
		3   numresult	=	f8
		3	resultid	=	f8
	2	summ_cnt		=	i4
	2	summ_qual[*]
		3	count		=	i4
		3	lotnbr		=	vc
		3	assayname	=	vc
		3	qcname		=	vc
		3	qclevel		=	vc
		3	begindttm	=	vc
		3	expiredttm	=	vc
		3	mean		=	f8
		3	sd			=	f8
		3	2sd			=	f8
		3	cv			=	vc
 
 
)
 
 
FREE RECORD summary
RECORD summary
(
1	summ_cnt		=	i4
1	facility		=	vc
1	summ_qual[*]
		2	count		=	i4
		2	lotnbr		=	vc
		2	assayname	=	vc
		2	qcname		=	vc
		2	servrsrc	=	vc
		2	qclevel		=	vc
		2	begindttm	=	vc
		2	expiredttm	=	vc
		2	mean		=	f8
		2	sd			=	f8
		2	2sd			=	f8
		2	cv			=	vc
		2	restotal	=	f8
		2	sqmean		=	f8
		2	summofsquares = f8
		2	summ_rqual[*]
			3	result	=	f8
			3	squarres	=	f8
			3	resultid	=	f8
			3	scnt		=	i4
 
 
)
 
/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
DECLARE oprtn(paramnum = i2) = c2
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
DECLARE plabop = c2 WITH NOCONSTANT(FILLSTRING(2,' ')), PROTECT
DECLARE srvrsrcop = c2 WITH NOCONSTANT(FILLSTRING(2,' ')), PROTECT
DECLARE opvar = c2 	WITH NOCONSTANT(FILLSTRING(2,' ')), PROTECT
DECLARE taskassayop = c2 WITH NOCONSTANT(FILLSTRING(2,' ')), PROTECT
DECLARE lotnbrop = c2 WITH NOCONSTANT(FILLSTRING(2,' ')), PROTECT

/**************************************************************
; DVDev Start Coding
**************************************************************/
 
;setup prompts for any option
SET plabop = oprtn(parameter2($perflab))
SET srvrsrcop = oprtn(parameter2($sr))
SET taskassayop = oprtn(parameter2($dta))
SET lotnbrop = oprtn(parameter2($lotnbr))
call echo(build('PLABOP :', plabop))
call echo(build('srvrsrcop :', srvrsrcop))
 
 
 
SELECT into 'nl:'
 
	qclevel = UAR_GET_CODE_DISPLAY(cm.control_type_cd),
	assay = UAR_GET_CODE_DISPLAY(qr.task_assay_cd)
 
FROM service_resource sr, qc_result qr,
	 control_material cm, control_lot cl
PLAN sr
WHERE operator(sr.location_cd,plabop,$perflab)
AND operator(sr.service_resource_cd,srvrsrcop, $sr)
AND sr.service_resource_type_cd IN (823.00,827.00)
JOIN qr
WHERE sr.service_resource_cd = qr.service_resource_cd
AND qr.perform_dt_tm BETWEEN CNVTDATETIME($bdate)
AND CNVTDATETIME($edate)
AND operator(qr.task_assay_cd,taskassayop, $dta)
JOIN cm
WHERE qr.control_id = cm.control_id
JOIN cl
WHERE cm.control_id = cl.control_id
AND operator(cl.control_id,lotnbrop,$lotnbr)
 
ORDER BY sr.service_resource_cd, cm.description, assay, qclevel
HEAD REPORT
	cnt = 0
 	a->facility	=	UAR_GET_CODE_DISPLAY($perflab)
HEAD sr.service_resource_cd
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		STAT = ALTERLIST(a->qual, cnt + 9)
 
	endif
	a->qual[cnt].serv_resrc	=	uar_get_code_display(sr.service_resource_cd)
	a->qual[cnt].srv_rsrc_cd = 	sr.service_resource_cd
	a->rec_cnt				=	cnt
 
	qcnt = 0
 
HEAD qr.qc_result_id ;DETAIL
 
	qcnt = qcnt + 1
	if (mod(qcnt,10) = 1 or qcnt = 1)
 
		STAT = ALTERLIST(a->qual[cnt].qcqual, qcnt + 9)
 
	endif
	a->qual[cnt].qcqual[qcnt].controlid 	= qr.control_id
	a->qual[cnt].qcqual[qcnt].taskassaycd = qr.task_assay_cd
	a->qual[cnt].qcqual[qcnt].taskname 	= uar_get_code_display(qr.task_assay_cd)
	a->qual[cnt].qcqual[qcnt].perfdttm	= FORMAT(qr.perform_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].qcqual[qcnt].qcname	= cm.description
	a->qual[cnt].qcqual[qcnt].lotnbr	= cl.lot_number
	a->qual[cnt].qcqual[qcnt].qclvl		= UAR_GET_CODE_DISPLAY(cm.control_type_cd)
	a->qual[cnt].qcqual[qcnt].sd		= qr.statistical_std_dev
	a->qual[cnt].qcqual[qcnt].mean		= qr.mean
	a->qual[cnt].qcqual[qcnt].startdttm = FORMAT(cl.receive_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].qcqual[qcnt].enddttm	= FORMAT(cl.expiration_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].qcqual[qcnt].alpharesult	= qr.result_value_alpha
	a->qual[cnt].qcqual[qcnt].numresult = qr.result_value_numeric
 	a->qual[cnt].qcqual[qcnt].resultid	=	qr.qc_result_id
	a->qual[cnt].qc_cnt					=	qcnt
 
 
FOOT sr.service_resource_cd
	stat = alterlist(a->qual[cnt].qcqual, qcnt)
 
 
 
 
FOOT REPORT
	STAT = ALTERLIST(a->qual, cnt)
 
 	origqcname = fillstring(25,' ')
 	origqclvl = fillstring(25,' ')
 	origtaskname = fillstring(25,' ')
 	newqcname = fillstring(25,' ')
 	newqclvl = fillstring(25,' ')
 	newtaskname = fillstring(25,' ')
 	qcflg = 0
 	qclvlflg = 0
 	taskflg = 0
 	total = 0
 	cnt = 0
 	FOR (rcnt = 1 to a->rec_cnt)
 
 		qccnt = 0
 
 		FOR (scnt = 1 to a->qual[rcnt].qc_cnt)
 
 			newqcname = a->qual[rcnt].qcqual[scnt].qcname
 			newqclvl = a->qual[rcnt].qcqual[scnt].qclvl
 			newtaskname = a->qual[rcnt].qcqual[scnt].taskname
 
 
 
 				if (scnt = 1 OR newqcname != origqcname
 				OR newqclvl != origqclvl OR newtaskname != origtaskname)
; 					call echo(build('newqcname :', newqcname))
; 					call echo(build('newqclvl :', newqclvl))
; 					call echo(build('newtaskname :', newtaskname))
					if (qcflg = 1)
 
						summary->summ_qual[cnt].mean = (summary->summ_qual[cnt].restotal/summary->summ_qual[cnt].count)
 
						FOR (mcnt = 1 to qccnt)
 
							summary->summ_qual[cnt].summ_rqual[mcnt].squarres =
							((summary->summ_qual[cnt].summ_rqual[mcnt].result -  summary->summ_qual[cnt].mean) *
							(summary->summ_qual[cnt].summ_rqual[mcnt].result -  summary->summ_qual[cnt].mean))
							summary->summ_qual[cnt].summofsquares = summary->summ_qual[cnt].summofsquares +
							summary->summ_qual[cnt].summ_rqual[mcnt].squarres
 							
						ENDFOR
 
						summary->summ_qual[cnt].sqmean = (summary->summ_qual[cnt].summofsquares/summary->summ_qual[cnt].count)
						summary->summ_qual[cnt].sd = summary->summ_qual[cnt].sqmean**0.5
						summary->summ_qual[cnt].2sd = (2*summary->summ_qual[cnt].sd)
						summary->summ_qual[cnt].cv = BUILD2(
						TRIM(CNVTSTRING(((summary->summ_qual[cnt].sd/summary->summ_qual[cnt].mean)*100),11,2)),' %')
						summary->facility = UAR_GET_CODE_DISPLAY($perflab)
						
						qcflg = 0
 						qccnt = 0
					endif
 
					qcflg = 1
 					qcnt = 0
 					cnt = cnt + 1
 					qccnt = qccnt + 1
 					stat = alterlist(summary->summ_qual, cnt)
 
 					summary->summ_qual[cnt].count = qccnt
 					summary->summ_qual[cnt].assayname = a->qual[rcnt].qcqual[scnt].taskname
 					summary->summ_qual[cnt].qcname = a->qual[rcnt].qcqual[scnt].qcname
 					summary->summ_qual[cnt].qclevel = a->qual[rcnt].qcqual[scnt].qclvl
 					summary->summ_qual[cnt].lotnbr = a->qual[rcnt].qcqual[scnt].lotnbr
 					summary->summ_qual[cnt].servrsrc = a->qual[rcnt].serv_resrc
 					summary->summ_qual[cnt].restotal = summary->summ_qual[cnt].restotal + a->qual[rcnt].qcqual[scnt].numresult
 					summary->summ_qual[cnt].begindttm = a->qual[rcnt].qcqual[scnt].startdttm
 					summary->summ_qual[cnt].expiredttm = a->qual[rcnt].qcqual[scnt].enddttm
 					stat = alterlist(summary->summ_qual[cnt].summ_rqual, qccnt)
 					summary->summ_qual[cnt].summ_rqual[qccnt].result = a->qual[rcnt].qcqual[scnt].numresult
 					summary->summ_qual[cnt].summ_rqual[qccnt].resultid = a->qual[rcnt].qcqual[scnt].resultid
 					summary->summ_qual[cnt].summ_rqual[qccnt].scnt = scnt
 				elseif(newqcname = origqcname
 				AND newqclvl = origqclvl AND newtaskname = origtaskname)
 
 					qccnt = qccnt + 1
 					summary->summ_qual[cnt].count = qccnt
 
 					summary->summ_qual[cnt].restotal = summary->summ_qual[cnt].restotal + a->qual[rcnt].qcqual[scnt].numresult
 					stat = alterlist(summary->summ_qual[cnt].summ_rqual, qccnt)
 					summary->summ_qual[cnt].summ_rqual[qccnt].result = a->qual[rcnt].qcqual[scnt].numresult
 					summary->summ_qual[cnt].summ_rqual[qccnt].resultid = a->qual[rcnt].qcqual[scnt].resultid
 					summary->summ_qual[cnt].summ_rqual[qccnt].scnt = scnt
 					
 				
 				endif
 
; 				if (scnt = a->qual[rcnt].qc_cnt)
; 					CALL ECHO('IN FINAL IF STMT')
; 					summary->summ_qual[cnt].mean = (35.26/12)
;
; 				endif
 
 			origqcname = a->qual[rcnt].qcqual[scnt].qcname
 			origqclvl = a->qual[rcnt].qcqual[scnt].qclvl
 			origtaskname = a->qual[rcnt].qcqual[scnt].taskname
 			summary->summ_cnt = cnt
 
 		ENDFOR
 	ENDFOR
WITH nocounter

if ($summdet = 0)

SELECT into VALUE($OUTDEV)
	
	Laboratory = CONCAT(summary->facility,'                             '),
	ServiceResource = CONCAT(summary->summ_qual[d.seq].servrsrc,'               '),
	QCName = CONCAT(summary->summ_qual[d.seq].qcname,'                  '),
	QCLevel = CONCAT(summary->summ_qual[d.seq].qclevel,'                '),
	StartDttm = summary->summ_qual[d.seq].begindttm,
	ExpDttm = summary->summ_qual[d.seq].expiredttm,
	LotNbr = CONCAT(summary->summ_qual[d.seq].lotnbr,'                  '),
	Assay = CONCAT(summary->summ_qual[d.seq].assayname,'                  '),
	Count = SUMMARY->summ_qual[D.SEQ].count,
	Mean = summary->summ_qual[d.seq].mean,
	SD = summary->summ_qual[d.seq].sd,
	2SD = summary->summ_qual[d.seq].2sd,
	CV = summary->summ_qual[d.seq].cv
	
FROM (dummyt d with seq = summary->summ_cnt)


WITH nocounter, format, separator = ' '


else

SELECT into VALUE($OUTDEV)

	Laboratory = CONCAT(a->qual[d.seq].serv_resrc,'                        '),
	QCName = CONCAT(a->qual[d.seq].qcqual[d2.seq].qcname,'                    '),
	QCLevel = CONCAT(a->qual[d.seq].qcqual[d2.seq].qclvl,'                   '),
	LotNbr = CONCAT(a->qual[d.seq].qcqual[d2.seq].lotnbr,'                  '),
	Assay = CONCAT(a->qual[d.seq].qcqual[d2.seq].taskname,'                  '),
	Result = a->qual[d.seq].qcqual[d2.seq].numresult,
	Perfdttm = a->qual[d.seq].qcqual[d2.seq].perfdttm,
	StartDtTm = a->qual[d.seq].qcqual[d2.seq].startdttm,
	ExpDtTm = a->qual[d.seq].qcqual[d2.seq].enddttm
	
FROM (dummyt d with seq = a->rec_cnt),
	(DUMMYT D2 WITH SEQ = 1)

PLAN d
WHERE MAXREC(d2,a->qual[d.seq].qc_cnt)	
JOIN d2
	
WITH NOCOUNTER, FORMAT, SEPARATOR = ' '

endif
 
 
 
 
 
CALL ECHORECORD(summary)
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
SUBROUTINE oprtn(paramnum)
 
IF (SUBSTRING(1,1,reflect(parameter(paramnum,0)))="L")
 
	SET opvar = "IN"
ELSEIF (parameter(paramnum,1) = 1.0)
	SET opvar = "!="
ELSE
	set opvar = "="
ENDIF
	RETURN (opvar)
 
END ;subroutine
 
 
end
go
