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
drop program cov_rt_o2_rpt go
create program cov_rt_o2_rpt

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 0
	, "Select Begin Date/Time" = "SYSDATE"
	, "Select End Date" = "SYSDATE" 

with OUTDEV, facility, begDate, endDate




/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
**************************************************************/
;FREE RECORD a
RECORD a
(
1	rec_cnt	=	i4
1	qual[*]
	2	personid	=	f8
	2	encntrid	=	f8
	2	name		=	vc
	2	unit		=	vc
	2	room		=	vc
	2	bed			=	vc
	2	loc			=	vc
	2	ordcnt		=	i4
	2	ordqual[*]
		3	orderid	=	f8
		3	ordname	=	vc
		3	ordres	=	vc
		3	perfdttm = vc
		3	spo2	=	vc
		3	o2therapy	= VC
		

)

/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/

/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
DECLARE o2therrt = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',200,'OXYGENTHERAPYPERRT')), PROTECT
DECLARE o2thernsg = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',200,'OXYGENTHERAPYPERNSG')), PROTECT 
DECLARE ordered	=	f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6004,'ORDERED')), PROTECT
DECLARE completed	=	f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6004,'COMPLETED')), PROTECT
DECLARE spo2	=	f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'SPO2')), PROTECT
DECLARE o2ther	=	f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 72,'OXYGENTHERAPY')), PROTECT

/**************************************************************
; DVDev Start Coding
**************************************************************/


CALL ECHO(BUILD('o2therrt :', o2therrt))
CALL ECHO(BUILD('o2thernsg :', o2thernsg))
CALL ECHO(BUILD('ordered :', ordered))
CALL ECHO(BUILD('spo2 :', spo2))
CALL ECHO(BUILD('o2ther :', o2ther))

SELECT into 'nl:'
	
	loc = CONCAT(UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd), ' ',
	UAR_GET_CODE_DISPLAY(e.loc_room_cd), '/', UAR_GET_CODE_DISPLAY(e.loc_bed_cd))
	
FROM orders o,
	 encounter e,
	 person p
PLAN o
WHERE o.catalog_cd IN (o2therrt, o2thernsg)
AND o.orig_order_dt_tm BETWEEN CNVTDATETIME($begdate)
AND CNVTDATETIME($enddate)
AND O.order_status_cd = ordered ;completed ;
JOIN e
WHERE o.encntr_id = e.encntr_id
AND e.loc_facility_cd = $facility
AND e.active_ind = 1
JOIN p
WHERE e.person_id = p.person_id
AND p.active_ind = 1
ORDER BY loc, o.orig_order_dt_tm DESC
HEAD REPORT
	cnt = 0 
HEAD o.encntr_id
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
	
		stat = alterlist(a->qual, cnt + 9)
	
	endif
	a->qual[cnt].personid	=	p.person_id
	a->qual[cnt].encntrid	=	e.encntr_id
	a->qual[cnt].name		=	TRIM(p.name_full_formatted)
	a->qual[cnt].unit		=	UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
	a->qual[cnt].room		=	UAR_GET_CODE_DISPLAY(e.loc_room_cd)
	a->qual[cnt].bed		=	UAR_GET_CODE_DISPLAY(e.loc_bed_cd)
	a->qual[cnt].loc		=	CONCAT(a->qual[cnt].unit, ' ', a->qual[cnt].room, '/',
								a->qual[cnt].bed)
	a->rec_cnt				=	cnt
	ocnt = 0
HEAD o.order_id
	ocnt = ocnt + 1
	if (mod(ocnt,10) = 1 or ocnt = 1)
	
		stat = alterlist(a->qual[cnt].ordqual, ocnt + 9)
	
	endif
	
	a->qual[cnt].ordqual[ocnt].orderid	=	o.order_id
	a->qual[cnt].ordqual[ocnt].ordname	=	TRIM(o.hna_order_mnemonic)
	
	a->qual[cnt].ordcnt					=	ocnt

FOOT o.encntr_id
	
	stat = alterlist(a->qual[cnt].ordqual, ocnt)
FOOT REPORT
	stat = alterlist(a->qual, cnt)
	
		
WITH nocounter


SELECT into 'nl:'

FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 clinical_event ce
	 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].ordcnt)
JOIN d2
JOIN ce
WHERE a->qual[d.seq].ordqual[d2.seq].orderid = ce.order_id
AND ce.event_cd IN (spo2,o2ther)
AND ce.valid_until_dt_tm = CNVTDATETIME("31-DEC-2100 0")

DETAIL
	
	CASE (ce.event_cd)
	
		OF (spo2):
		
			a->qual[d.seq].ordqual[d2.seq].spo2 = TRIM(ce.result_val)
		
		OF (o2ther):
			
			a->qual[d.seq].ordqual[d2.seq].o2therapy = TRIM(ce.result_val)
		
			
	ENDCASE
	
	a->qual[d.seq].ordqual[d2.seq].perfdttm = FORMAT(ce.performed_dt_tm, "mm/dd/yyyy hh:mm;;q")

WITH nocounter	


CALL ECHORECORD(a)
GO TO exitscript


/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
#exitscript
end
go
