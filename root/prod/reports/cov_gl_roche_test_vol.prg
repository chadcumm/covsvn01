/**********************************************************************************
Author		 	:	Mike Layman
Date Written 	:	07/06/18
Program Title	:	Test Count Report
Source File	 	:	cov_gl_roche_test_vol.prg
Object Name		:	cov_gl_roche_test_vol
Directory	 	:  	cust_script
DVD version  	:  	2017.11.1.81
HNA version  	:   01Oct2012
CCL version  	:   8.8.3
Purpose      	:	This script will serve as a driver script
					for a layout report. This will select any
					tests that were posted for
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
drop program cov_gl_roche_test_vol go
create program cov_gl_roche_test_vol
 
prompt
	"Output to File/Printer/MINE" = "MINE"             ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 3144499.00
	, "Select Ordering Laboratory" = 2553879881.00
	, "Select Performing Laboratory" = 2553879881.00
	, "Select Instrument" = 0
	, "Select Begin Date/time" = "SYSDATE"
	, "Select End Date/Time" = "SYSDATE"
 
with OUTDEV, Facility, ordlab, perflab, Instrument, begdate, enddate
 
 
 
/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
**************************************************************/
;FREE RECORD a
RECORD a
(
	1	rec_cnt 	=	i4
	1	facility	=	vc
	1	tottests	=	i4
	1	qual[*]
		2	serv_rsrc	=	f8
		2	srv_rsrc_nm	=	vc
		2	sr_testtot	=	i4
		2	test_cnt	=	i4
		2	testqual[*]
			3	DTA		=	f8
			3	testnm	=	vc
			3	testtot	=	i4
)
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
DECLARE testsql = vc WITH NOCONSTANT(FILLSTRING(500,' ')), PROTECT
DECLARE instrumentsql = vc WITH NOCONSTANT(FILLSTRING(500,' ')), PROTECT
DECLARE tests = vc WITH NOCONSTANT(FILLSTRING(500,' ')), PROTECT
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
 
;set up *any parsers
 
if ($instrument = 1)
	SET instrumentsql = BUILD('pr.service_resource_cd >', 0.00)
 
	SET testsql = BUILD('r.task_assay_cd >', 0.00)
else
	SET instrumentsql = BUILD('pr.service_resource_cd =',$instrument)
 
	SELECT
   		test = UAR_GET_CODE_DISPLAY(apr.task_assay_cd),
   		apr.task_assay_cd
 
	FROM assay_processing_r apr
	WHERE apr.service_resource_cd = $Instrument
	AND apr.active_ind = 1
	ORDER BY test
 
	HEAD REPORT
 
		tests = fillstring(500,' ')
 
	DETAIL
 
		tests = BUILD(tests,apr.task_assay_cd,',')
 
	FOOT REPORT
		pos = 0
		pos = FINDSTRING(',',tests,1,1)
		if (pos > 0)
			tests = substring(1,pos - 1,tests)
		endif
 
	WITH nocounter
	SET testsql = BUILD('r.task_assay_cd IN (',tests,')')
 
endif
 
 
;if ($test = 1)
;	SET testsql = BUILD('r.task_assay_cd > ',0.00)
;else
;	SET testsql = BUILD('r.task_assay_cd = ',$test)
;endif
 
 
CALL ECHO(BUILD('testsql :', testsql))
CALL ECHO(BUILD('instrumentsql :', instrumentsql))
;GO TO exitscript
 
 
SELECT into 'nl:'
 
FROM location l
WHERE l.organization_id = $facility
AND l.location_type_cd = 783.00
AND l.active_ind = 1
 
DETAIL
 
	a->facility = UAR_GET_CODE_DISPLAY(l.location_cd)
WITH nocounter
 
 
 
SELECT into 'nl:'
 
	dtaname = UAR_GET_CODE_DISPLAY(r.task_assay_cd)
 
FROM result r,
	 perform_result pr,
	 service_resource sr,
	 container c,
	 collection_list cl
 
PLAN pr
WHERE pr.perform_dt_tm BETWEEN CNVTDATETIME($begdate)
AND CNVTDATETIME($enddate)
AND parser(instrumentsql)
JOIN r
WHERE pr.result_id = r.result_id
AND parser(testsql) ;r.task_assay_cd = $test
JOIN sr
WHERE pr.service_resource_cd = sr.service_resource_cd
AND sr.location_cd = $perflab
JOIN c
WHERE OUTERJOIN(pr.container_id) = c.container_id
JOIN cl
WHERE outerjoin(c.collection_list_id) = cl.collection_list_id
 
ORDER BY sr.service_resource_cd, dtaname, pr.perform_dt_tm
 
HEAD REPORT
 
	cnt = 0
 
HEAD sr.service_resource_cd
 
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(a->qual, cnt + 9)
 
	endif
	a->qual[cnt].serv_rsrc		=	sr.service_resource_cd
	a->qual[cnt].srv_rsrc_nm	=	UAR_GET_CODE_DISPLAY(sr.service_resource_cd)
	a->rec_cnt					=	cnt
	tcnt 						=	0
 
	prvdta = fillstring(50,' ')
 
DETAIL
	if (prvdta != dtaname)
		tcnt = tcnt + 1
		if (mod(tcnt,10) = 1 or tcnt = 1)
 
			stat = alterlist(a->qual[cnt].testqual, tcnt + 9)
 
		endif
	endif
	a->qual[cnt].testqual[tcnt].DTA	=	r.task_assay_cd
	a->qual[cnt].testqual[tcnt].testnm	=	UAR_GET_CODE_DISPLAY(r.task_assay_cd)
	a->qual[cnt].testqual[tcnt].testtot = 	a->qual[cnt].testqual[tcnt].testtot + 1
	a->qual[cnt].test_cnt				=	tcnt
 
	prvdta = dtaname
FOOT sr.service_resource_cd
	FOR (rcnt = 1 to a->qual[cnt].test_cnt)
		a->qual[cnt].sr_testtot = a->qual[cnt].sr_testtot + a->qual[cnt].testqual[rcnt].testtot
		a->tottests = a->tottests + a->qual[cnt].testqual[rcnt].testtot
 
	ENDFOR
 
	stat = alterlist(a->qual[cnt].testqual, tcnt)
FOOT REPORT
	stat = alterlist(a->qual, cnt)
 
WITH nocounter
 
CALL ECHORECORD(A)
;GO TO exitscript
 
 
 
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
 
#exitscript
end
go
 
