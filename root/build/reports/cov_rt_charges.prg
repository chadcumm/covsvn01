/*****************************************************
Author		 :  Michael Layman
Date Written :  4/26/18
Program Title:  Respiratory Therapy Charge Report
Source File	 :  cov_rt_charges.prg
Object Name	 :	cov_rt_charges
Directory	 :	cust_script
DVD version  :	2017.11.1.81
HNA version  :	2017
CCL version  :	8.2.3
Purpose      :  This program will produce a report
				that will display
Tables Read  :  orders, person, encounter, encntr_alias, person_alias
Tables
Updated      :	NA
Include Files:  NA
Executing
Application  :	Explorer Menu / Report Portal
Special Notes:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Mod #        By           Date           Purpose
*****************************************************/
 
drop program cov_rt_charges go
create program cov_rt_charges
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = ""
	, "Select Begin Date/Time" = "SYSDATE"
	, "Select End Date" = "SYSDATE"
 
with OUTDEV, facility, begDate, endDate
 
 
 
 
/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
**************************************************************/
FREE RECORD a
RECORD a
(
1	rec_cnt			=	i4
1	facility		=	vc
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
	2	ordcnt		=	i4
	2	ordqual[*]
		3	orderid		=	f8
		3	ordername	=	vc
		3	orddttm		=	vc
		3	drugcategory= 	vc
		3	chargeid	=	f8
		3	chrgevid	=	f8
		3	chargedesc	=	vc
		3	prsnlid		=	f8
		3	prsnl		=	vc
		3	srvcdttm	=	vc
		3	postdttm	=	vc
 
 
 
)
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
DECLARE rtact 	= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',106,'RESPIRATORY')), PROTECT
DECLARE pulmact	= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',106, 'PULMONARY')), PROTECT
DECLARE rtcattype = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6000,'RESPIRATORYTHERAPY')), PROTECT
DECLARE orddept = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',14281,'ORDERED')), PROTECT
DECLARE ordsts	= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6004,'ORDERED')), PROTECT
DECLARE ip		= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',71,'INPATIENT')), PROTECT
DECLARE mrn		= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',4,'MRN')), PROTECT
DECLARE fin		= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',319,'FINNBR')), PROTECT
DECLARE phact	= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',106,'PHARMACY')), PROTECT
DECLARE sqlstr	= vc WITH NOCONSTANT(FILLSTRING(1000,' ')), PROTECT
DECLARE debit	= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',13028,'DEBIT')), PROTECT
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
;CV CHECK
CALL ECHO(BUILD('rt act : ', rtact))
CALL ECHO(BUILD('orddept : ', orddept))
CALL ECHO(BUILD('ordsts : ', ordsts))
CALL ECHO(BUILD('ip : ', ip))
CALL ECHO(BUILD('mrn : ', mrn))
CALL ECHO(BUILD('fin : ', fin))
CALL ECHO(BUILD('phact : ', phact))
CALL ECHO(BUILD('debit : ', debit))
CALL ECHO(BUILD('pulmact : ', pulmact))
CALL ECHO(BUILD('rtcattype : ', rtcattype))
 
;CALL ECHO(BUILD('sqlstr :', sqlstr))
;GO TO exitscript
 
SELECT into 'nl:'
 
FROM
	 charge c,
	 orders o,
	 encounter e,
	 person p,
	 encntr_alias ea,
	 person_alias pa,
	 prsnl pr
 
 
PLAN c
WHERE c.service_dt_tm BETWEEN CNVTDATETIME($begdate)
AND CNVTDATETIME($enddate)
;AND c.activity_type_cd in (rtact, pulmact)
JOIN o
WHERE c.order_id = o.order_id
AND O.catalog_type_cd = rtcattype
AND o.active_ind = 1
JOIN e
WHERE o.encntr_id = e.encntr_id
;AND e.encntr_type_cd = ip
;AND e.loc_facility_cd = $facility
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
AND pa.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")
JOIN pr
WHERE c.updt_id = pr.person_id
 
HEAD REPORT
	cnt = 0
 
HEAD e.encntr_id
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(a->qual, cnt + 9)
 
	endif
	a->qual[cnt].name = TRIM(p.name_full_formatted)
	a->qual[cnt].personid	=	p.person_id
	a->qual[cnt].encntrid	=	e.encntr_id
	a->qual[cnt].mrn		=	TRIM(pa.alias)
	a->qual[cnt].fin		=	TRIM(ea.alias)
	a->qual[cnt].unit		=	UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
	a->qual[cnt].room		=	UAR_GET_CODE_DISPLAY(e.loc_room_cd)
	a->qual[cnt].bed		=	UAR_GET_CODE_DISPLAY(e.loc_bed_cd)
	a->qual[cnt].loc		=	CONCAT(a->qual[cnt].unit, ' ', a->qual[cnt].room,' ',
								a->qual[cnt].bed)
	a->facility				=	UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
	a->rec_cnt				=	cnt
	ocnt = 0
DETAIL
	ocnt = ocnt + 1
	if (mod(ocnt, 10 ) = 1 or ocnt = 1)
 
		stat = alterlist(a->qual[cnt].ordqual, ocnt + 9)
 
	endif
 
	a->qual[cnt].ordqual[ocnt].orderid	=	o.order_id
	a->qual[cnt].ordqual[ocnt].ordername = UAR_GET_CODE_DISPLAY(o.catalog_cd)
	a->qual[cnt].ordqual[ocnt].orddttm		= FORMAT(o.orig_order_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].ordqual[ocnt].chargeid		= c.charge_item_id
	a->qual[cnt].ordqual[ocnt].chargedesc	= c.charge_description
	a->qual[cnt].ordqual[ocnt].chrgevid		= c.charge_event_id
	a->qual[cnt].ordqual[ocnt].prsnlid		= pr.person_id
	a->qual[cnt].ordqual[ocnt].prsnl		= TRIM(pr.name_full_formatted)
	a->qual[cnt].ordqual[ocnt].srvcdttm		= FORMAT(c.service_dt_tm,"mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].ordqual[ocnt].postdttm		= FORMAT(c.posted_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].ordcnt						= ocnt
FOOT e.encntr_id
	stat = alterlist(a->qual[cnt].ordqual, ocnt)
 
FOOT REPORT
	stat = alterlist(a->qual, cnt)
 
WITH nocounter
 
 
 
SELECT into VALUE($OUTDEV)
	unit = CONCAT(a->qual[d.seq].unit,'                 '),
	bed = CONCAT(a->qual[d.seq].bed,'             '),
	name = concat(TRIM(a->qual[d.seq].name),'                     '),
	fin = TRIM(a->qual[d.seq].fin),
	charge = CONCAT(a->qual[d.seq].ordqual[d2.seq].chargedesc,'                     '),
	orderdttm = a->qual[d.seq].ordqual[d2.seq].orddttm,
	servicedttm = a->qual[d.seq].ordqual[d2.seq].srvcdttm,
	postdttm = a->qual[d.seq].ordqual[d2.seq].postdttm,
	personnel = CONCAT(a->qual[d.seq].ordqual[d2.seq].prsnl,'                              ')
 
 
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1)
PLAN d
WHERE MAXREC(d2,a->qual[d.seq].ordcnt)
JOIN d2
 
WITH nocounter, format, separator = ' '
 
CALL ECHORECORD(a)
;GO TO exitscript
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
 
#exitscript
 
end
go
 
