/***********************************************************
Author 			:	Mike Layman
Date Written	:	12/12/2018
Program Title	:	General Lab Transfer TAT Report
Source File		:	cov_gl_test_trf_tat_rpt.prg
Object Name		:	cov_gl_test_trf_tat_rpt
Directory		:	cust_script
DVD Version		:	2017.07.1.81
HNA Version		:	2015.01
CCL Version		:	8.8.3
Purpose			: 	This program will display the tests that have been
					transferred between facilities and the TAT's between
					those sites.
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
drop program cov_gl_test_trf_tat_rpt go
create program cov_gl_test_trf_tat_rpt

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Transfer From Location" = 0
	, "Transfer To Location" = 0
	, "Begin Date" = "SYSDATE"
	, "End Date" = "SYSDATE" 

with OUTDEV, trfrom, trto, bdate, edate

 
 
 
 
/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
**************************************************************/
FREE RECORD a
RECORD a
(
1	rec_cnt =	 i4
1	qual[*]
	2	containerid		=	f8
	2	colllistid		=	f8
	2	transferlistid	=	f8
	2	orderid			=	f8
	2	resultid		=	f8
	2	accnbr			=	vc
	2	fromloc			=	vc
	2	toloc			=	vc
	2	fromorgid		=	f8
	2	toorgid			=	f8
	2	colllistdttm	=	vc
	2	orddttm			=	f8
	2	colldttm		=	f8
	2	recv1dttm		=	f8
	2	recv2dttm		=	f8
	2	trfdttm			=	f8
	2	perfdttm		=	f8
	2	colldatetime	=	vc
	2	orderdatetime	=	vc
	2	recv1datetime	=	vc
	2	recv2datetime	=	vc
	2	perfdatetime	=	vc
	2	trfdatetime		=	vc
	2	personid		=	f8
	2	encntrid		=	f8
	2	name			=	vc
	2	mrn				=	vc
	2	fin				=	vc
	2	unit			=	vc
	2	room			=	vc
	2	bed				=	vc
	2	ordname			=	vc
 
)
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
DECLARE cancelcd = f8 with constant(uar_get_code_by('displaykey',6004,'CANCELED')), PROTECT
DECLARE recdcd	 = f8 with constant(uar_get_code_by('DISPLAYKEY',2061,'RECEIVED')), PROTECT
DECLARE intrancd = f8 with constant(uar_get_code_by('DISPLAYKEY',2061,'INTRANSIT')), PROTECT
DECLARE fin		 = f8 with constant(uar_get_code_by('DISPLAYKEY',319,'FINNBR')), PROTECT
DECLARE mrn		 = f8 with constant(uar_get_code_by('DISPLAYKEY',4,'MRN')), PROTECT
 
/**************************************************************
; DVDev Start Coding
**************************************************************/




 
SELECT into 'nl:'

FROM collection_list cl,
	 collection_list_container clc,
	 container c,
	 order_container_r ocr,
	 orders o,
	 encounter e,
	 person p,
	 encntr_alias ea
	 
	 
	 

PLAN cl
WHERE cl.from_location_cd = $trfrom
AND cl.to_location_cd = $trto
AND cl.collection_list_dt_tm BETWEEN CNVTDATETIME($bdate)
AND CNVTDATETIME($edate)
AND cl.list_type_flag = 2
AND cl.transfer_list_status_flag = 2
JOIN clc
WHERE cl.collection_list_id = clc.collection_list_id
JOIN c 
WHERE clc.container_id = c.container_id
JOIN ocr
WHERE c.container_id = ocr.container_id
JOIN o
WHERE ocr.order_id = o.order_id
AND o.order_status_cd != cancelcd
JOIN e
WHERE o.encntr_id = e.encntr_id
AND e.active_ind = 1
JOIN p
WHERE e.person_id = p.person_id
ANd p.active_ind = 1
JOIN ea
WHERE e.encntr_id = ea.encntr_id
AND ea.encntr_alias_type_cd = fin
AND ea.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")



HEAD REPORT

	cnt = 0
	
DETAIL
	
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
	
		stat = alterlist(a->qual, cnt + 9)
	
	endif
	a->qual[cnt].containerid	=	c.container_id
	a->qual[cnt].transferlistid	=	c.transfer_list_id
	a->qual[cnt].colllistid		=	cl.collection_list_id
	a->qual[cnt].colllistdttm	=	FORMAT(cl.collection_list_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].colldttm		=	c.drawn_dt_tm
	a->qual[cnt].colldatetime	=	FORMAT(c.drawn_dt_tm, "mm/dd/yyyy hh:mm;;q")
	;a->qual[cnt].recv2dttm		=	c.received_dt_tm
	;a->qual[cnt].recv2datetime	=	FORMAT(c.received_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].fromloc		=	REPLACE(UAR_GET_CODE_DISPLAY(cl.from_location_cd),char(10),'')
	a->qual[cnt].toloc			=	REPLACE(UAR_GET_CODE_DISPLAY(cl.to_location_cd),CHAR(10),'')
	a->qual[cnt].accnbr			=	cnvtacc(clc.accession)
	a->qual[cnt].orderid		=	ocr.order_id
	a->qual[cnt].ordname		=	UAR_GET_CODE_DISPLAY(ocr.catalog_cd)
	a->qual[cnt].orderdatetime	=	FORMAT(o.orig_order_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].orddttm		=	o.orig_order_dt_tm
	a->qual[cnt].personid		=	p.person_id
	a->qual[cnt].encntrid		=	e.encntr_id
	a->qual[cnt].name			=	TRIM(p.name_full_formatted)
	a->qual[cnt].fromorgid		=	e.organization_id
	a->qual[cnt].unit			=	UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
	a->qual[cnt].room			=	UAR_GET_CODE_DISPLAY(e.loc_room_cd)
	a->qual[cnt].bed			=	UAR_GET_CODE_DISPLAY(e.loc_bed_cd)
	a->qual[cnt].fin			=	TRIM(ea.alias)
	a->rec_cnt 					=	cnt
	
FOOT REPORT
	
	stat = alterlist(a->qual, cnt)

WITH nocounter	  

;Get transfer and initial received dt/tm

SELECT into 'nl:'

FROM (dummyt d with seq = a->rec_cnt),
	 container_event ce,
	 location l

PLAN d
JOIN ce
WHERE a->qual[d.seq].containerid = ce.container_id
AND ce.event_type_cd IN (recdcd, intrancd)
JOIN l
WHERE outerjoin(ce.current_location_cd) = l.location_cd	 

DETAIL
	curloc = fillstring(25,' ')
	curloc = UAR_GET_CODE_DISPLAY(ce.current_location_cd)
	loctype = 0
	
	CASE (ce.event_type_cd)
	
		OF (recdcd):
			call echo('in received cd statement')
			call echo(curloc)
			call echo(BUILD('loctype before:', loctype))
			loctype = findstring("CP Login",curloc,1)
			call echo(BUILD('loctype after:', loctype))
			IF (l.organization_id = a->qual[d.seq].fromorgid
			AND loctype > 0)
			
				A->qual[d.seq].recv1dttm = ce.event_dt_tm
				a->qual[d.seq].recv1datetime = FORMAT(ce.event_dt_tm, "mm/dd/yyyy hh:mm;;q")
			ELSEIF (l.organization_id != a->qual[d.seq].fromorgid
			AND loctype > 0)
				a->qual[d.seq].recv2dttm = ce.event_dt_tm
				a->qual[d.seq].recv2datetime = FORMAT(ce.event_dt_tm, "mm/dd/yyyy hh:mm;;q")
				
			ENDIF
		
		OF (intrancd):
			
			a->qual[d.seq].trfdttm = ce.event_dt_tm
			a->qual[d.seq].trfdatetime = FORMAT(ce.event_dt_tm,"mm/dd/yyyy hh:mm;;q")
	
	ENDCASE
	


WITH nocounter 

;Get Performed Dt/Tm

SELECT into 'nl:'

FROM (dummyt d with seq = a->rec_cnt),
	 clinical_event ce

PLAN d
JOIN ce
WHERE a->qual[d.seq].orderid = ce.order_id
AND ce.valid_until_dt_tm = CNVTDATETIME("31-DEC-2100 0")

DETAIL
	
	a->qual[d.seq].perfdatetime	=	FORMAT(ce.performed_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[d.seq].perfdttm		=	ce.performed_dt_tm


WITH nocounter		 


SELECT into ($outdev)

	name = CONCAT(a->qual[d.seq].name,'                                 '),
	ordloc = a->qual[d.seq].fromloc,
	perfloc = a->qual[d.seq].toloc,
	;mrn = a->qual[d.seq].mrn,
	fin = a->qual[d.seq].fin,
	unit = a->qual[d.seq].unit,
	room = a->qual[d.seq].room,
	bed = a->qual[d.seq].bed,
	ordername = a->qual[d.seq].ordname,
	orderdate = a->qual[d.seq].orderdatetime,
	collecteddate = a->qual[d.seq].colldatetime,
	recdinordlab = a->qual[d.seq].recv1datetime,
	transfdate = a->qual[d.seq].trfdatetime,
	recdinperflab = a->qual[d.seq].recv2datetime,
	perfdate = a->qual[d.seq].perfdatetime
	
	


FROM (dummyt d with seq = a->rec_cnt)
 

WITH nocounter, format, separator = ' '
 
CALL ECHORECORD(a)
;GO TO exitscript 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
#exitscript 
end
go
