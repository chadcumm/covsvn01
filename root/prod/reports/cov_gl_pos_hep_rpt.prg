/**********************************************************************************
Author		 	:	Mike Layman
Date Written 	:	06/27/18
Program Title	:	Positive Hepatitis Report
Source File	 	:	cov_gl_pos_hep_rpt.prg
Object Name		:	cov_gl_pos_hep_rpt
Directory	 	:  	cust_script
DVD version  	:  	2017.11.1.81
HNA version  	:   01Oct2012
CCL version  	:   8.8.3
Purpose      	:
 
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
drop program cov_gl_pos_hep_rpt go
create program cov_gl_pos_hep_rpt
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 0
	, "Select Begin Date/time" = "SYSDATE"
	, "Select End Date/Time" = "SYSDATE"
 
with OUTDEV, Facility, begdate, enddate
 
 
 
/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
**************************************************************/
FREE RECORD tests
RECORD tests
(
1	rec_cnt	=	i4
1	qual[*]
	2	catalogcd	=	f8
	2	desc		=	vc
	2	task_cnt	=	i4
	2	taskqual[*]
		3	task_assay_cd = f8
		3	taskname	  = vc
 
)
 
;FREE RECORD a
RECORD a
(
1	rec_cnt 	=	 i4
1	qual[*]
	2	personid	=	f8
	2	encntrid	=	f8
	2	orderid		=	f8
	2	name		=	vc
	2	mrn			=	vc
	2	fin			=	vc
	2	unit		=	vc
	2	room		=	vc
	2	bed			=	vc
	2	dob			=	vc
	2	ordsite		=	vc
	2	ordaddr1	=	vc
	2	ordaddr2	=	vc
	2	ordcitystzip=	vc
	2	perfsite	=	vc
	2	peraddr1	=	vc
	2	peraddr2	=	vc
	2	percitystzip=	vc
	2	ordphys		=	vc
	2	ordcnt		=	i4
	2	ordqual[*]
		3	orderid	=	f8
		3	ordname	=	vc
		3	orddttm	=	vc
		3	rescnt	=	i4
		3	resqual[*]
			4	eventid		=	f8
			4	taskassaycd	=	f8
			4	eventcd		=	f8
			4	result		=	vc
			4	refrng		=	vc
			4	normalcd	=	f8
			4	normalval	=	vc
			4	perfdttm	=	vc
			4	accessnbr	=	vc
			4	colldttm	=	vc
			4	test		=	vc
			4	method		=	vc
			4	analyte		=	vc
		3	labrescnt		=	i4
		3	labqual[*]
			4	resultid	=	f8
			4	taskassaycd	=	f8
			4	result		=	vc
			4	refrng		=	vc
			4	normalcd	=	f8
			4	normalval	=	vc
			4	perfdttm	=	vc
			4	accessnbr	=	vc
			4	colldttm	=	vc
			4	test		=	vc
			4	method		=	vc
			4	analyte		=	vc
			4	containerid	=	f8
			4	refrngfacid	=	f8
			4	servrsrccd	=	f8
			4	servrsrs	=	vc
			4	translistid	=	f8
			4	colllistid	=	f8
			4	restype		=	vc
 
 
 
)
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
DECLARE alpharesp = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',289,'ALPHA')), PROTECT
DECLARE numresp	  = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 289, 'NUMERIC')), PROTECT
DECLARE mrn		  = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',4,'MRN')), PROTECT
DECLARE fin		  = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',319,'FINNBR')), PROTECT
DECLARE ordercd	  = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6003,'ORDER')), PROTECT
DECLARE businesscd= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',212,'BUSINESS')), PROTECT
DECLARE normalcd  = f8 WITH CONSTANT(UAR_GET_CODE_BY('DESCRIPTION',1902,'Normal')), PROTECT
DECLARE authVerCd = F8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',1901,'VERIFIED')), PROTECT
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
;echo cv's
CALL ECHO(BUILD('alpharesp :', alpharesp))
CALL ECHO(BUILD('numresp :', numresp))
CALL ECHO(BUILD('mrn :', mrn))
CALL ECHO(BUILD('fin :', fin))
CALL ECHO(BUILD('businesscd :', businesscd))
CALL ECHO(BUILD('normalcd :', normalcd))
;Get Hepatitis Orders
 
SELECT into 'nl:'
 
FROM code_value cv,
	 profile_task_r p
PLAN cv
WHERE cv.code_set = 200
AND cv.display_key IN (
'HEPATITISAANTIBODYIGG',
'HEPATITISAANTIBODYIGM',
'HEPATITISBCOREANTIBODYIGMACUTE',
'HEPATITISBEANTIGEN',
'HEPATITISBPROFILEAMB',
'HEPATITISBSURFACEABQUANTITATIVEA',
'HEPATITISBSURFACEANTIBODY',
'HEPATITISBSURFACEANTIGEN',
'HEPATITISBVIRUSDNAQUANTITATIVE',
'HEPATITISBPRENATALPROFXAMB',
'HEPATITISCANTIBODY',
'HEPATITISCANTIBODYWREFLEXHCVABVER',
'HEPATITISCGENOTYPE',
'HEPATITISCVIRUSQUALWREFLEXTOQUANT',
'HEPATITISCVIRUSRTPCRQUANTITATIVE',
'HEPATITISCVIRUSQUANTBYPCRWREFLEX',
'HEPATITISCHRONICPANEL',
'HEPATITISCHRONICVIRALPANEL',
'HEPATITISAIGMANTIBODY',
'HEPATITISATOTALANTIBODY',
'HEPATITISBDNAQUANT',
'HEPATITISBSURFACEAGEIA',
'HEPATITISBEAGEIA',
'HEPATITISBEANTIBODY',
'HEPATITISCABTEST',
'HEPATITISCPROBERVRSTRNSC',
'HEPATITISCREVRSTRNSCRPJ',
'HEPATITISDELTAAGEIA',
'HEPATITISDELTAAGENTANTBDY'
)
AND cv.active_ind = 1
JOIN p
WHERE OUTERJOIN(cv.code_value) = p.catalog_cd
;AND p.active_ind = 1
 
HEAD REPORT
	cnt = 0
HEAD p.catalog_cd
 
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(tests->qual, cnt + 9)
 
	endif
 
	tests->qual[cnt].catalogcd = cv.code_value
	tests->qual[cnt].desc = cv.display
	tests->rec_cnt = cnt
	tcnt = 0
 
DETAIL
	IF (p.active_ind = 1)
	tcnt = tcnt + 1
	if (mod(tcnt,10) = 1 or tcnt = 1)
 
		stat = alterlist(tests->qual[cnt].taskqual, tcnt + 9)
 
	endif
	tests->qual[cnt].taskqual[tcnt].task_assay_cd	=	p.task_assay_cd
	tests->qual[cnt].taskqual[tcnt].taskname		=	UAR_GET_CODE_DISPLAY(p.task_assay_cd)
	tests->qual[cnt].task_cnt						=	tcnt
	endif
FOOT p.catalog_cd
	stat = alterlist(tests->qual[cnt].taskqual, tcnt)
 
 
FOOT REPORT
 
	STAT = ALTERLIST(tests->qual, cnt )
WITH nocounter
 
 
SELECT into 'nl:'
 
FROM (dummyt d with seq = tests->rec_cnt),
	 orders o,
	 encounter e,
	 person p,
	 clinical_event ce
 
PLAN d
JOIN o
WHERE tests->qual[d.seq].catalogcd = o.catalog_cd
;AND o.orig_order_dt_tm BETWEEN CNVTDATETIME($begdate)
;AND CNVTDATETIME($enddate)
JOIN e
WHERE o.encntr_id = e.encntr_id
AND e.loc_facility_cd = $facility
AND e.active_ind = 1
JOIN p
WHERE e.person_id = p.person_id
AND p.active_ind = 1
JOIN ce
WHERE o.order_id = ce.order_id
AND ce.valid_until_dt_tm = CNVTDATETIME("31-DEC-2100 0")
 
HEAD REPORT
	cnt = 0
HEAD e.encntr_id
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(a->qual, cnt + 9)
 
	endif
	a->qual[cnt].encntrid	=	o.encntr_id
	a->qual[cnt].personid	=	o.person_id
	a->qual[cnt].orderid	= 	o.order_id
	a->qual[cnt].name		=	TRIM(p.name_full_formatted)
	a->qual[cnt].unit		=	UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
	a->qual[cnt].room		=	UAR_GET_CODE_DISPLAY(e.loc_room_cd)
	a->qual[cnt].bed		=	UAR_GET_CODE_DISPLAY(e.loc_bed_cd)
	a->qual[cnt].dob		=	FORMAT(p.birth_dt_tm, "mm/dd/yyyy;;d")
	a->rec_cnt				=	cnt
 
	ocnt = 0
HEAD o.order_id
	ocnt = ocnt + 1
	if (mod(ocnt,10) = 1 or ocnt = 1)
 
		stat = alterlist(a->qual[cnt].ordqual, ocnt + 9)
 
	endif
	a->qual[cnt].ordqual[ocnt].orddttm	=	FORMAT(o.orig_order_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].ordqual[ocnt].orderid	=	o.order_id
	a->qual[cnt].ordqual[ocnt].ordname	=	TRIM(o.hna_order_mnemonic)
	a->qual[cnt].ordcnt					=	ocnt
	rcnt = 0
DETAIL
	rcnt = rcnt + 1
	if (mod(rcnt,10) = 1 or rcnt = 1)
 
		stat = alterlist(a->qual[cnt].ordqual[ocnt].resqual, rcnt + 9)
 
	endif
	a->qual[cnt].ordqual[ocnt].resqual[rcnt].accessnbr	= CNVTACC(ce.accession_nbr)
	a->qual[cnt].ordqual[ocnt].resqual[rcnt].eventcd	= ce.event_cd
	a->qual[cnt].ordqual[ocnt].resqual[rcnt].eventid	= ce.event_id
	a->qual[cnt].ordqual[ocnt].resqual[rcnt].normalcd	= ce.normalcy_cd
	a->qual[cnt].ordqual[ocnt].resqual[rcnt].normalval	= UAR_GET_CODE_DISPLAY(ce.normalcy_cd)
	a->qual[cnt].ordqual[ocnt].resqual[rcnt].perfdttm	= FORMAT(ce.performed_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].ordqual[ocnt].resqual[rcnt].result		= TRIM(ce.result_val)
	a->qual[cnt].ordqual[ocnt].resqual[rcnt].taskassaycd= ce.task_assay_cd
	a->qual[cnt].ordqual[ocnt].resqual[rcnt].analyte	= UAR_GET_CODE_DISPLAY(ce.task_assay_cd)
	a->qual[cnt].ordqual[ocnt].rescnt					=	rcnt
 
FOOT o.order_id
	stat = alterlist(a->qual[cnt].ordqual[ocnt].resqual, rcnt)
FOOT e.encntr_id
	stat = alterlist(a->qual[cnt].ordqual, ocnt)
 
FOOT REPORT
	stat = alterlist(a->qual, cnt )
 
 
 
WITH nocounter
 
;Get MRN/FIN
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 encntr_alias ea,
	 person_alias pa
 
PLAN d
JOIN ea
WHERE a->qual[d.seq].encntrid	=	ea.encntr_id
AND ea.encntr_alias_type_cd		=	fin
AND ea.end_effective_dt_tm		=	CNVTDATETIME("31-DEC-2100 0")
JOIN pa
WHERE a->qual[d.seq].personid	=	pa.person_id
AND pa.person_alias_type_cd		=	mrn
AND pa.end_effective_dt_tm		=	CNVTDATETIME("31-DEC-2100 0")
 
DETAIL
 
	a->qual[d.seq].fin	=	TRIM(ea.alias)
	a->qual[d.seq].mrn	=	TRIM(pa.alias)
 
 
 
WITH nocounter
 
;Get Ordering Physician
 
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 order_action oa,
	 prsnl pr
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].ordcnt)
JOIN d2
JOIN oa
WHERE a->qual[d.seq].ordqual[d2.seq].orderid	=	oa.order_id
AND oa.action_type_cd							=	ordercd
JOIN pr
WHERE oa.order_provider_id						=	pr.person_id
AND pr.active_ind 								=	1
 
DETAIL
 
	a->qual[d.seq].ordphys						=	TRIM(pr.name_full_formatted)
 
WITH nocounter
 
 
;Get Lab Results
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 result r,
	 perform_result pr
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].ordcnt)
JOIN d2
JOIN r
WHERE a->qual[d.seq].ordqual[d2.seq].orderid	=	r.order_id
JOIN pr
WHERE r.result_id = pr.result_id
AND pr.result_status_cd = authVerCd
HEAD r.order_id
 
	cnt = 0
DETAIL
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(a->qual[d.seq].ordqual[d2.seq].labqual, cnt + 9)
 
	endif
	a->qual[d.seq].ordqual[d2.seq].labqual[cnt].resultid	= r.result_id
	a->qual[d.seq].ordqual[d2.seq].labqual[cnt].containerid	= pr.container_id
	a->qual[d.seq].ordqual[d2.seq].labqual[cnt].taskassaycd	= r.task_assay_cd
 
	if (pr.result_type_cd = alpharesp)
		a->qual[d.seq].ordqual[d2.seq].labqual[cnt].result		= pr.result_value_alpha
	else
		a->qual[d.seq].ordqual[d2.seq].labqual[cnt].result		= CNVTSTRING(pr.result_value_numeric)
	endif
	a->qual[d.seq].ordqual[d2.seq].labqual[cnt].method	= UAR_GET_CODE_DISPLAY(pr.service_resource_cd)
	a->qual[d.seq].ordqual[d2.seq].labqual[cnt].refrngfacid	=	pr.reference_range_factor_id
	a->qual[d.seq].ordqual[d2.seq].labqual[cnt].servrsrccd	=	pr.service_resource_cd
	a->qual[d.seq].ordqual[d2.seq].labqual[cnt].servrsrs	=	UAR_GET_CODE_DISPLAY(pr.service_resource_cd)
	a->qual[d.seq].ordqual[d2.seq].labqual[cnt].normalcd	=	pr.normal_cd
	a->qual[d.seq].ordqual[d2.seq].labqual[cnt].normalval	=	UAR_GET_CODE_DISPLAY(pr.normal_cd)
	a->qual[d.seq].ordqual[d2.seq].labqual[cnt].perfdttm	=	FORMAT(pr.perform_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[d.seq].ordqual[d2.seq].labqual[cnt].analyte		=	UAR_gET_CODE_DISPLAY(r.task_assay_cd)
	a->qual[d.seq].ordqual[d2.seq].labqual[cnt].restype		=	UAR_GET_CODE_DISPLAY(pr.result_type_cd)
	a->qual[d.seq].ordqual[d2.seq].labrescnt				=	cnt
FOOT r.order_id
	stat = alterlist(a->qual[d.seq].ordqual[d2.seq].labqual, cnt)
 
WITH NOCOUNTER
 
 
;Get container info
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 (dummyt  d3 with seq = 1),
	 container c,
	 container_accession ca
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].ordcnt)
JOIN d2
WHERE MAXREC(d3, a->qual[d.seq].ordqual[d2.seq].labrescnt)
JOIN d3
JOIN c
WHERE a->qual[d.seq].ordqual[d2.seq].labqual[d3.seq].containerid = c.container_id
JOIN ca
WHERE c.container_id = ca.container_id
 
DETAIL
 
	a->qual[d.seq].ordqual[d2.seq].labqual[d3.seq].accessnbr	=	CNVTACC(ca.accession)
	a->qual[d.seq].ordqual[d2.seq].labqual[d3.seq].colldttm		=	FORMAT(c.drawn_dt_tm, "mm/dd/yyyy hh:mm;;q")
 	a->qual[d.seq].ordqual[d2.seq].labqual[d3.seq].colllistid		=	c.collection_list_id
 	a->qual[d.seq].ordqual[d2.seq].labqual[d3.seq].translistid		=	c.transfer_list_id
 
 
 
 
WITH nocounter
 
;Get Performing Location
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 (dummyt d3 with seq = 1),
	 service_resource sr,
	 address a
 
 
plan d
WHERE MAXREC(d2, a->qual[d.seq].ordcnt)
JOIN d2
WHERE MAXREC(d3, a->qual[d.seq].ordqual[d2.seq].labrescnt)
JOIN d3
JOIN sr
WHERE a->qual[d.seq].ordqual[d2.seq].labqual[d3.seq].servrsrccd = sr.service_resource_cd
JOIN a
WHERE sr.organization_id = a.parent_entity_id
AND a.parent_entity_name = 'ORGANIZATION'
AND A.address_type_cd = businesscd
 
 
DETAIL
	a->qual[d.seq].perfsite	= UAR_GET_CODE_DISPLAY(sr.location_cd)
	a->qual[d.seq].peraddr1	= TRIM(a.street_addr)
	a->qual[d.seq].peraddr2 = TRIM(a.street_addr2)
	a->qual[d.seq].percitystzip = BUILD2(TRIM(a.city),', ',TRIM(a.state),' ', TRIM(a.zipcode))
 
	if (a->qual[d.seq].ordqual[d2.seq].labqual[d3.seq].colllistid = 0.0)
 
		a->qual[d.seq].ordsite = a->qual[d.seq].perfsite
		a->qual[d.seq].ordaddr1	= a->qual[d.seq].peraddr1
		a->qual[d.seq].ordaddr2 = a->qual[d.seq].peraddr2
		a->qual[d.seq].ordcitystzip = a->qual[d.seq].percitystzip
 
 
	endif
 
WITH nocounter
 
;Get ordering location if different than performing location
 
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 (dummyt d3 with seq = 1),
	 collection_list cl,
	 location l,
	 address a
 
plan d
WHERE MAXREC(d2, a->qual[d.seq].ordcnt)
JOIN d2
WHERE MAXREC(d3, a->qual[d.seq].ordqual[d2.seq].labrescnt)
JOIN d3
JOIN cl
WHERE a->qual[d.seq].ordqual[d2.seq].labqual[d3.seq].colllistid = cl.collection_list_id
AND cl.collection_list_id > 0
AND cl.transfer_list_status_flag = 2.00 ;transferred
JOIN l
WHERE cl.from_location_cd = l.location_cd
JOIN a
WHERE l.organization_id = a.parent_entity_id
AND a.parent_entity_name = 'ORGANIZATION'
AND a.address_type_cd = businesscd
 
DETAIL
 
	a->qual[d.seq].ordsite = UAR_GET_CODE_DISPLAY(cl.from_location_cd)
	a->qual[d.seq].ordaddr1	= TRIM(a.street_addr)
	a->qual[d.seq].ordaddr2 = TRIM(a.street_addr2)
	a->qual[d.seq].ordcitystzip = BUILD2(TRIM(a.city),', ',TRIM(a.state),' ', TRIM(a.zipcode))
 
 
 
WITH nocounter
 
 
 
 
;Get Numeric Reference Ranges
 
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 (dummyt d3 with seq = 1),
	 reference_range_factor rrf
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].ordcnt)
JOIN d2
WHERE MAXREC(d3, a->qual[d.seq].ordqual[d2.seq].labrescnt)
JOIN d3
join rrf
WHERE a->qual[d.seq].ordqual[d2.seq].labqual[d3.seq].refrngfacid = rrf.reference_range_factor_id
AND a->qual[d.seq].ordqual[d2.seq].labqual[d3.seq].restype = 'Numeric'
 
DETAIL
 
	a->qual[d.seq].ordqual[d2.seq].labqual[d3.seq].refrng = BUILD2(TRIM(cnvtstring(rrf.normal_low,11,2)), ' - ',
	cnvtstring(rrf.normal_high,11,2))
 
 
 
WITH nocounter
 
;Get Alpha Normal Range
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 (dummyt d3 with seq = 1),
	 alpha_responses ar
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].ordcnt)
JOIN d2
WHERE MAXREC(d3, a->qual[d.seq].ordqual[d2.seq].labrescnt)
JOIN d3
join ar
WHERE a->qual[d.seq].ordqual[d2.seq].labqual[d3.seq].refrngfacid = ar.reference_range_factor_id
AND a->qual[d.seq].ordqual[d2.seq].labqual[d3.seq].restype = 'Alpha'
AND ar.result_process_cd = normalcd
 
DETAIL
 
	a->qual[d.seq].ordqual[d2.seq].labqual[d3.seq].refrng = ar.description
 
WITH nocounter
 
call echorecord(a)
;go to exitscript
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript
end
go
 
