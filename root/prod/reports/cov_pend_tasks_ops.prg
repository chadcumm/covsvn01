/***********************************************************
Author 			:	Mike Layman
Date Written	:	06/20/18
Program Title	:	Pending Ancillary Tasks Operation Script
Source File		:	cov_pend_tasks_ops.prg
Object Name		:	cov_pend_tasks_ops
Directory		:	cust_script
DVD Version		:	2017.07.1.81
HNA Version		:	2015.01
CCL Version		:	8.8.3
Purpose			: 	This program is designed to loop through all possible
					facilities and clinical disciplines. The output files will
					then be copied to the Astream folders.
Tables Read		:	NA
Tables Updated	:	NA
Include File	:	NA
Shell Scripts	:	NA
Executing App	:	Operations
Special Notes	:
Usage			:	cov_pend_tasks_ops go
Mod		Date		Engineer				Comment
----    ----------- ----------------------- ---------------------------
001		06/20/2018	Mike Layman				Original Release
 
 
$LastChangedBy::							$:
$LastChangedDate::							$:
$LastChangedRevision::						$:
 
 
 
 
************************************************************/
drop program cov_pend_tasks_ops go
create program cov_pend_tasks_ops
 
/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
**************************************************************/
 
FREE RECORD fac
RECORD fac
(
1	rec_cnt	=	i4
1	qual[*]
	2	faccd	=	f8
	2	facdesc	=	vc
)
 
FREE RECORD dept
RECORD dept
(
1	rec_cnt 	=	i4
1	qual[*]
	2	deptcd	=	f8
	2	dept	=	vc
)
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
;DECLARE fac = vc WITH NOCONSTANT(FILLSTRING(25,' ')), PROTECT
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
;Get facilities
SELECT into 'nl:'
    facility = UAR_GET_CODE_DISPLAY(l.location_cd),
    l.location_cd
 
FROM location l
WHERE l.location_type_cd = 783.00
AND l.location_cd IN (   21250403.00,
 2552503613.00,
 2552503635.00,
 2552503649.00,
 2552503653.00,
 2552503657.00,
 2552503639.00,
 2552503645.00,
   29797179.00
)
AND l.active_ind = 1
 
ORDER BY facility
 
HEAD REPORT
	cnt = 0
DETAIL
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(fac->qual, cnt + 9)
 
	endif
	fac->qual[cnt].faccd	=	l.location_cd
	fac->qual[cnt].facdesc	=	facility
	fac->rec_cnt			=	cnt
 
FOOT REPORT
	stat = alterlist(fac->qual, cnt)
 
WITH nocounter
 
;get dept
SELECT into 'nl:'
    display = cv.display,
    code_value = cv.code_value
FROM code_value cv
WHERE cv.code_set =6000
AND cv.display_key in ('OCCUPATIONALTHERAPY',
'PHYSICALTHERAPY', 'SPEECHTHERAPY', 'RESPIRATORYTHERAPY', 'NUTRITIONSERVICES')
AND cv.active_ind = 1
ORDER BY cv.display
 
HEAD REPORT
	cnt = 0
DETAIL
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(dept->qual, cnt + 9)
 
	endif
	dept->qual[cnt].dept = display
	dept->qual[cnt].deptcd = code_value
	dept->rec_cnt		=	cnt
 
FOOT REPORT
	stat = alterlist(dept->qual, cnt)
 
WITH nocounter
 
CALL ECHORECORD(fac)
CALL ECHORECORD(dept)
 
;loop through facilities and dept.
FOR (cnt = 1 to fac->rec_cnt)
 
	FOR (dcnt = 1 to dept->rec_cnt)
 
		EXECUTE cov_pend_tasks_rt_pt_ot_sp "mine", fac->qual[cnt].faccd, dept->qual[dcnt].deptcd, "BDATE", "EDATE"
 
	ENDFOR
 
ENDFOR
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
