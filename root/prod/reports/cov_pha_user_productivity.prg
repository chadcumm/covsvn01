/***********************************************************
Author 			:	Mike Layman
Date Written	:	12/18/2017
Program Title	:	Covenant Pharmacy Orders User Productivity Report
Source File		:	cov_pha_user_productivity.prg
Object Name		:	cov_pha_user_productivity
Directory		:	cust_script
DVD Version		:	2017.07.1.81
HNA Version		:	2015.01
CCL Version		:	8.8.3
Purpose			: 	This program is designed to display results for
					pharmacy orders and the order actions performed
					by pharmacists.
Tables Read		:	person, encounter, encntr_alias, person_alias,
					clinical_event, orders, order_action
Tables Updated	:	NA
Include File	:	NA
Shell Scripts	:	NA
Executing App	:	Reporting Portal
Special Notes	:
Usage			:	cov_example_rpt "mine", 555555.00, 222222.00 go
Mod		Date		Engineer				Comment
----    ----------- ----------------------- ---------------------------
001		10/31/2017	Mike Layman				Original Release
		03/18/2019  Geetha Saravanan		Excluding corp facility, test users/patients and It pharmnet users.
 
************************************************************/
drop program cov_pha_user_productivity go
create program cov_pha_user_productivity
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 0
	, "Select Begin Date/Time" = "SYSDATE"
	, "Select End Date/Time" = "SYSDATE"
 
with OUTDEV, facility, begdate, enddate
 
 
 
 
 
/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
**************************************************************/
FREE RECORD a
RECORD a
(
1	rec_cnt 	=	i4
1	facility	=	vc
1	totordcnt	=	i4
1	totphaactcnt 	=	i4
1	totactncnt		=	i4
1	qual[*]
	2	facility	=	vc
	2	company 	=	vc
	2	personid	=	f8
	2	encntrid	=	f8
	2	name		=	vc
	2	fin			=	vc
	2	mrn			=	vc
	2	unit		=	vc
	2	room		=	vc
	2	bed			=	vc
	2	enctype		=	vc
	2	encclass	=	vc
	2	pattype		=	c1
	2	ord_cnt		=	i4
	2	ordqual[*]
		3	orderid	=	f8
		3	ordname	=	vc
		3	ordsts	=	vc
		3	orddttm = vc
		3	orddetails = vc
		3	prsnlid	=	f8
		3	prsnl	=	vc
		3	ordertype = vc
		3	ordactncnt	=	i4
		3	ordactnqual[*]
			4	ordaction	=	vc
			4	oaprsnl		=	vc
			4	oaprsnlid	=	f8
			4	position	=	vc
			4	oadttm		=	vc
			4	printflg	=	i2
			4	verify_ind 	= 	i2
			4	Company		=	vc
 
 
 
)
 
FREE RECORD totals
RECORD totals
(
1	rec_cnt		=	i4
1	qual[*]
	2	Company			=	vc
	2	Department		=	vc
	2	Activity_Code	=	f8
	2	Date_Of_Service	=	vc
	2	Weight			=	vc
	2	IP_Value		=	vc
	2	OP_Value		=	vc
	2	Total_Value		=	vc
)
 
FREE RECORD strata
RECORD strata
(
1	rec_cnt 	=	i4
1	qual[*]
	2	Company			=	vc
	2	Department		=	vc
	2	Activity_Code	=	vc
	2	Date_Of_Service	=	vc
	2	Weight			=	vc
	2	IP_Value		=	vc
	2	OP_Value		=	vc
	2	Total_Value		=	vc
 
 
 
)
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
DECLARE pharmordcd	=	f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',106,'PHARMACY')), PROTECT
DECLARE cancelcd	=	f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6004,'CANCELED')), PROTECT
DECLARE fin			=	f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',319,'FINNBR')), PROTECT
DECLARE ordacttype	=	f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6003,'ORDER')), PROTECT
DECLARE dcacttype	=	f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6003,'DISCONTINUE')), PROTECT
DECLARE facoper		=	vc WITH NOCONSTANT(FILLSTRING(2,' ')), PROTECT
DECLARE modacttype	=	f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6003,'MODIFY')), PROTECT
DECLARE pharmposcd	=	f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',88,'PHARMNETPHARMACIST')), PROTECT
DECLARE pharmt1poscd	=	f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',88,'PHARMNETTECHNICIAN1')), PROTECT
DECLARE pharmt2poscd	=	f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',88,'PHARMNETTECHNICIAN2')), PROTECT
DECLARE pharmt3poscd	=	f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',88,'PHARMNETTECHNICIAN3')), PROTECT
DECLARE pharmmgmntcd	=   f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',88,'PHARMNETMANAGEMENT')), PROTECT
DECLARE ITPharmnetcd	=	f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',88,'ITPHARMNET')), PROTECT
DECLARE filename		=	vc WITH
CONSTANT(BUILD('cer_temp:','CovHlth_PR_Rx_Stats_',FORMAT(curdate,'yyyymmdd;;q'),'.txt')), PROTECT
DECLARE techAddrCd		=	f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',212,'TECHNICAL')), PROTECT
DECLARE bdate			=	f8 WITH NOCONSTANT(0.0), PROTECT
DECLARE edate			=	f8 WITH NOCONSTANT(0.0), PROTECT
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
;CV CHECK
CALL ECHO(BUILD('pharmordcd :', pharmordcd))
CALL ECHO(BUILD('cancelcd :', cancelcd))
CALL ECHO(BUILD('fin :', fin))
CALL ECHO(BUILD('filename :', filename))
CALL ECHO(BUILD('techAddrCd :', techAddrCd))
;facility setup
IF (SUBSTRING(1,1,reflect(parameter(parameter2($facility),0)))="L")
 
	SET facoper = "IN"
ELSEIF (parameter(parameter2($facility),1) = 1.0)
	SET facoper = "!="
ELSE
	SET facoper = "="
ENDIF
 
 
 
;ops setup
 
if (validate(request->batch_selection)  > 0)
 
	SET bdate = datetimefind(CNVTDATETIME(CURDATE-1, 0),'D','B','B')
	SET edate = datetimefind(CNVTDATETIME(CURDATE-1, 0),'D','B','E')
else
	SET bdate = CNVTDATETIME($begdate)
	SET edate = CNVTDATETIME($enddate)
 
endif
 
CALL ECHO(BUILD('bdate :', FORMAT(bdate,"mm/dd/yyyy hh:mm;;q")))
CALL ECHO(BUILD('edate :', FORMAT(edate,"mm/dd/yyyy hh:mm;;q")))
 
 
 
;MAIN ORDER QUERY
SELECT into 'nl:'
 
FROM orders o,
	 encounter e,
	 person p,
	 encntr_alias ea
 
PLAN o
WHERE o.orig_order_dt_tm BETWEEN CNVTDATETIME(bdate)
AND CNVTDATETIME(edate)
AND o.activity_type_cd = pharmordcd
AND o.order_status_cd != cancelcd
AND o.template_order_id = 0.0
;AND o.orig_ord_as_flag IN (0,1)
JOIN e
WHERE o.encntr_id = e.encntr_id
AND operator(e.organization_id,facoper,$facility)
AND e.active_ind = 1
JOIN p
WHERE e.person_id = p.person_id
AND p.active_ind = 1
and cnvtupper(p.name_full_formatted) != 'ZZ*'
and cnvtupper(p.name_full_formatted) != '*TEST*'
 
JOIN ea
WHERE e.encntr_id = ea.encntr_id
AND ea.encntr_alias_type_cd = fin
AND ea.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")
AND ea.active_ind = 1
 
ORDER BY e.encntr_id, o.order_id
 
HEAD REPORT
	cnt = 0
 	;a->facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
HEAD e.encntr_id
	cnt = cnt + 1
 
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(a->qual, cnt + 9)
 
	endif
	a->qual[cnt].facility	=	UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
	a->qual[cnt].personid	=	p.person_id
	a->qual[cnt].encntrid	=	e.encntr_id
	a->qual[cnt].name		=	TRIM(p.name_full_formatted)
	a->qual[cnt].enctype	=	UAR_GET_CODE_DISPLAY(e.encntr_type_cd)
	a->qual[cnt].encclass	=	UAR_GET_CODE_DISPLAY(e.encntr_type_class_cd)
	a->qual[cnt].unit		=	UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd)
	a->qual[cnt].room		=	UAR_GET_CODE_DISPLAY(e.loc_room_cd)
	a->qual[cnt].bed		=	UAR_GET_CODE_DISPLAY(e.loc_bed_cd)
	a->qual[cnt].fin		=	TRIM(ea.alias)
 
	if (UAR_GET_CODE_DISPLAY(e.encntr_type_class_cd) IN ('Inpatient','Preadmit','Skilled Nursing'))
		a->qual[cnt].pattype = 'I'
	else
		a->qual[cnt].pattype = 'O'
	endif
 
 
	a->rec_cnt				=	cnt
	ocnt = 0
HEAD o.order_id
	ocnt = ocnt + 1
	if (MOD(ocnt,10) = 1 or ocnt = 1)
 
		stat = alterlist(a->qual[cnt].ordqual, ocnt + 9)
 
	endif
	a->qual[cnt].ordqual[ocnt].orderid		=	o.order_id
	a->qual[cnt].ordqual[ocnt].ordname		=	TRIM(o.hna_order_mnemonic)
	a->qual[cnt].ordqual[ocnt].ordsts		=	UAR_GET_CODE_DISPLAY(o.order_status_cd)
	a->qual[cnt].ordqual[ocnt].orddttm		= 	FORMAT(o.orig_order_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].ordqual[ocnt].prsnlid		=	o.updt_id
	a->qual[cnt].ordqual[ocnt].orddetails	=	TRIM(o.order_detail_display_line)
 	if (o.template_order_id > 0)
 		a->qual[cnt].ordqual[ocnt].ordertype = 'Child'
 	else
 		a->qual[cnt].ordqual[ocnt].ordertype = 'Parent'
 	endif
	a->qual[cnt].ord_cnt					=	ocnt
FOOT e.encntr_id
	a->totordcnt = a->totordcnt + a->qual[cnt].ord_cnt
	stat = alterlist(a->qual[cnt].ordqual, ocnt)
FOOT REPORT
	stat = alterlist(a->qual, cnt)
WITH nocounter
 
 
 
;Get order actions
SELECT into 'nl:'
	orderid = a->qual[d.seq].ordqual[d2.seq].orderid
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 order_action oa,
	 prsnl pr
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].ord_cnt)
JOIN d2
JOIN oa
WHERE a->qual[d.seq].ordqual[d2.seq].orderid = oa.order_id
AND oa.action_type_cd In (ordacttype,dcacttype,modacttype)
 
JOIN pr
WHERE OUTERJOIN(oa.action_personnel_id) = pr.person_id
 
HEAD orderid
	cnt = 0
DETAIL
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 
		stat = alterlist(a->qual[d.seq].ordqual[d2.seq].ordactnqual, cnt + 9)
 
	endif
	a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].ordaction = UAR_GET_CODE_DISPLAY(oa.action_type_cd)
	a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].oadttm	  = FORMAT(oa.action_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].oaprsnlid = oa.action_personnel_id
	a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].oaprsnl	  = TRIM(pr.name_full_formatted)
	a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].position  = UAR_GET_CODE_DISPLAY(pr.position_cd)
	a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].verify_ind = oa.needs_verify_ind
	;if (pr.position_cd in (pharmposcd, pharmt1poscd,pharmt2poscd,pharmt3poscd,pharmmgmntcd))
 	 if (pr.position_cd in (pharmposcd,pharmmgmntcd))
		a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].printflg	=	1
		a->totphaactcnt = a->totphaactcnt + 1
 
	endif
	a->totactncnt = a->totactncnt + 1
	a->qual[d.seq].ordqual[d2.seq].ordactncnt = cnt
 
FOOT orderid
	stat = alterlist(a->qual[d.seq].ordqual[d2.seq].ordactnqual, cnt)
 
 
WITH nocounter
 
call echo('getting order review info')
 
;order_action verify
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 order_action oa,
	 prsnl pr
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].ord_cnt)
JOIN d2
JOIN oa
WHERE a->qual[d.seq].ordqual[d2.seq].orderid = oa.order_id
AND oa.needs_verify_ind = 3
JOIN pr
WHERE oa.action_personnel_id = pr.person_id
AND pr.position_cd = pharmposcd
 
HEAD oa.order_id
	cnt = a->qual[d.seq].ordqual[d2.seq].ordactncnt
 
	cnt = cnt + 1
	stat = alterlist(A->qual[d.seq].ordqual[d2.seq].ordactnqual, cnt)
	a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].ordaction = 'Verify'
	a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].oaprsnlid = oa.action_personnel_id
	a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].oadttm = FORMAT(oa.action_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].oaprsnl =  TRIM(pr.name_full_formatted)
	a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].position = UAR_GET_CODE_DISPLAY(pr.position_cd)
	a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].printflg = 1
	a->qual[d.seq].ordqual[d2.seq].ordactncnt	=	cnt
 
WITH nocounter
 
 
;order review verify action
; check for verify action if not found in order_action table
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 order_review orv,
	 prsnl pr
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].ord_cnt)
JOIN d2
JOIN orv
WHERE a->qual[d.seq].ordqual[d2.seq].orderid = orv.order_id
AND orv.review_type_flag = 3
JOIN pr
WHERE orv.review_personnel_id = pr.person_id
AND pr.position_cd IN (pharmposcd, pharmmgmntcd)
 
ORDER BY orv.action_sequence DESC
 
HEAD orv.order_id
	vflag = 0
	FOR (icnt = 1 to a->qual[d.seq].ordqual[d2.seq].ordactncnt)
 
		IF (a->qual[d.seq].ordqual[d2.seq].ordactnqual[icnt].ordaction = "Verify")
			vflag = 1
		ENDIF
 
	ENDFOR
 
	if (vflag = 0)
		cnt = a->qual[d.seq].ordqual[d2.seq].ordactncnt
 
		cnt = cnt + 1
		stat = alterlist(a->qual[d.seq].ordqual[d2.seq].ordactnqual, cnt)
		a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].ordaction = 'Verify'
		a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].oaprsnlid = orv.review_personnel_id
		a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].oadttm = FORMAT(orv.review_dt_tm, "mm/dd/yyyy hh:mm;;q")
		a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].oaprsnl =  TRIM(pr.name_full_formatted)
		a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].position = UAR_GET_CODE_DISPLAY(pr.position_cd)
		a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].printflg = 1
		a->qual[d.seq].ordqual[d2.seq].ordactncnt	=	cnt
 	endif
WITH nocounter
 
 
;Get prsnl address info
 
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
 	 (dummyt d3 with seq = 1),
 	 address a
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].ord_cnt)
JOIN d2
WHERE MAXREC(d3, a->qual[d.seq].ordqual[d2.seq].ordactncnt)
JOIN d3
JOIN a
WHERE a->qual[d.seq].ordqual[d2.seq].ordactnqual[d3.seq].oaprsnlid = a.parent_entity_id
AND a.parent_entity_name = 'PERSON'
AND a.address_type_cd = techAddrCd
AND a.address_type_seq = 1
 
DETAIL
	a->qual[d.seq].ordqual[d2.seq].ordactnqual[d3.seq].Company = TRIM(a.street_addr4)
	a->qual[d.seq].company = TRIM(a.street_addr4)
 
WITH nocounter
 
;Summary Data
SELECT into 'nl:'
 
	;facility=a->qual[d.seq].facility
	orderid = a->qual[d.seq].ordqual[d2.seq].orderid,
	company = CONCAT(a->qual[d.seq].ordqual[d2.seq].ordactnqual[d3.seq].Company,'  ')
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 (dummyt d3 with seq = 1)
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].ord_cnt) and a->qual[d.seq].facility != 'COV CORP HOSP'
JOIN d2
WHERE MAXREC(d3,a->qual[d.seq].ordqual[d2.seq].ordactncnt)
JOIN d3
WHERE a->qual[d.seq].ordqual[d2.seq].ordactnqual[d3.seq].printflg = 1
	and cnvtlower(a->qual[d.seq].ordqual[d2.seq].ordactnqual[d3.seq].oaprsnl) != '*test*'
	and cnvtupper(a->qual[d.seq].ordqual[d2.seq].ordactnqual[d3.seq].oaprsnl) != 'UA.*'

ORDER BY company
 
 
HEAD REPORT
	cnt = 0
HEAD company
	ip_val = 0
	op_val = 0
	tot_val = 0
 
 
HEAD orderid
;	call echo(build('company :', a->qual[d.seq].ordqual[d2.seq].ordactnqual[d3.seq].Company))
;	call echo(build('orderid :',a->qual[d.seq].ordqual[d2.seq].orderid))
;	call echo(build('printflg :', a->qual[d.seq].ordqual[d2.seq].ordactnqual[d3.seq].printflg))
	if (a->qual[d.seq].pattype = 'I')
		ip_val = ip_val + 1
	else
		op_val = op_val + 1
	endif
 
FOOT company
	tot_val = ip_val + op_val
	cnt = cnt + 1
	stat = alterlist(totals->qual,cnt)
 
	CASE(company)
 
		OF ('20'):
			totals->qual[cnt].Company = '20'
			totals->qual[cnt].Department = '720000'
 
		OF ('22'):
 
			totals->qual[cnt].Company = '22'
			totals->qual[cnt].Department = '720000'
 
		OF ('24'):
 
			totals->qual[cnt].Company = '24'
			totals->qual[cnt].Department = '720000'
 
		OF ('25'):
 
			totals->qual[cnt].Company = '25'
			totals->qual[cnt].Department = '720000'
 
		OF ('26'):
 
			totals->qual[cnt].Company = '26'
			totals->qual[cnt].Department = '720000'
 
		OF ('27'):
 
			totals->qual[cnt].Company = '27'
			totals->qual[cnt].Department = '720000'
 
		OF ('28'):
 
			totals->qual[cnt].Company = '28'
			totals->qual[cnt].Department = '720000'
 
		OF ('65'):
 
			totals->qual[cnt].Company = '65'
			totals->qual[cnt].Department = '721500'
 
 
 
	ENDCASE
 
 
 
 
 
	totals->qual[cnt].Activity_Code = pharmordcd
	totals->qual[cnt].Date_Of_Service = FORMAT(curdate - 1,"MM/DD/YYYY;;D")
	totals->qual[cnt].IP_Value	=	CNVTSTRING(ip_val)
	totals->qual[cnt].OP_Value	=	CNVTSTRING(op_val)
	totals->qual[cnt].Total_Value = CNVTSTRING(tot_val)
	totals->qual[cnt].Weight	=	"1"
	totals->rec_cnt		=	cnt
 
WITH nocounter
 
call echorecord(totals)
;SELECT into 'nl:'
;
;	facility=a->qual[d.seq].facility
;
;FROM (dummyt d with seq = a->rec_cnt),
;	 (dummyt d2 with seq = 1),
;	 (dummyt d3 with seq = 1)
;
;PLAN d
;WHERE MAXREC(d2, a->qual[d.seq].ord_cnt)
;JOIN d2
;WHERE MAXREC(d3,a->qual[d.seq].ordqual[d2.seq].ordactncnt)
;JOIN d3
;WHERE a->qual[d.seq].ordqual[d2.seq].ordactnqual[d3.seq].printflg = 1
;ORDER BY facility
;
;
;HEAD REPORT
;	cnt = 0
;HEAD facility
;	ip_val = 0
;	op_val = 0
;	tot_val = 0
;
;
;DETAIL
;	if (a->qual[d.seq].pattype = 'I')
;		ip_val = ip_val + 1
;	else
;		op_val = op_val + 1
;	endif
;
;FOOT facility
;	tot_val = ip_val + op_val
;	cnt = cnt + 1
;	stat = alterlist(totals->qual,cnt)
;
;	CASE(facility)
;
;		OF ('FLMC'):
;			totals->qual[cnt].Company = '28'
;			totals->qual[cnt].Department = '720000'
;		OF ('FSR'):
;			totals->qual[cnt].Company = '20'
;			totals->qual[cnt].Department = '720000'
;		OF ('FSR INF Oridge'):
;			totals->qual[cnt].Company = '20'
;			totals->qual[cnt].Department = '720000'
;		OF ('FSR Pat Neal'):
;			totals->qual[cnt].Company = '20'
;			totals->qual[cnt].Department = '720000'
;		OF ('FSR TCU'):
;			totals->qual[cnt].Company = '20'
;			totals->qual[cnt].Department = '720000'
;		OF ('LCMC'):
;			totals->qual[cnt].Company = '26'
;			totals->qual[cnt].Department = '720000'
;		OF ('LCMC Blount INF'):
;			totals->qual[cnt].Company = '26'
;			totals->qual[cnt].Department = '720000'
;		OF ('LCMC Dwtn INF'):
;			totals->qual[cnt].Company = '26'
;			totals->qual[cnt].Department = '720000'
;		OF ('LCMC Sevier INF'):
;			totals->qual[cnt].Company = '26'
;			totals->qual[cnt].Department = '720000'
;		OF ('LCMC West INF'):
;			totals->qual[cnt].Company = '26'
;			totals->qual[cnt].Department = '720000'
;		OF ('MHHS'):
;			totals->qual[cnt].Company = '25'
;			totals->qual[cnt].Department = '720000'
;		OF ('MHHS ASC'):
;			totals->qual[cnt].Company = '25'
;			totals->qual[cnt].Department = '720000'
;		OF ('MHHS Behav Hlth'):
;			totals->qual[cnt].Company = '25'
;			totals->qual[cnt].Department = '720000'
;		OF ('MHHS MRDC'):
;			totals->qual[cnt].Company = '25'
;			totals->qual[cnt].Department = '720000'
;		OF ('MMC'):
;			totals->qual[cnt].Company = '24'
;			totals->qual[cnt].Department = '720000'
;		OF ('MMC Cheyenne'):
;			totals->qual[cnt].Company = '24'
;			totals->qual[cnt].Department = '720000'
;		OF ('PW'):
;			totals->qual[cnt].Company = '22'
;			totals->qual[cnt].Department = '720000'
;		OF ('PW Senior Behav'):
;			totals->qual[cnt].Company = '22'
;			totals->qual[cnt].Department = '720000'
;		OF ('PBH Peninsula'):
;			totals->qual[cnt].Company = '65'
;			totals->qual[cnt].Department = '721500'
;		OF ('RMC'):
;			totals->qual[cnt].Company = '27'
;			totals->qual[cnt].Department = '720000'
;	ELSE
;		totals->qual[cnt].Company = '00'
;		totals->qual[cnt].Department = '720000'
;
;
;	ENDCASE
;
;
;
;
;
;	totals->qual[cnt].Activity_Code = pharmordcd
;	totals->qual[cnt].Date_Of_Service = FORMAT(curdate - 1,"MM/DD/YYYY;;D")
;	totals->qual[cnt].IP_Value	=	CNVTSTRING(ip_val)
;	totals->qual[cnt].OP_Value	=	CNVTSTRING(op_val)
;	totals->qual[cnt].Total_Value = CNVTSTRING(tot_val)
;	totals->qual[cnt].Weight	=	"1"
;	totals->rec_cnt		=	cnt
;
;WITH nocounter
 
 
;separate ip and op values and total all facilities for extract file
SELECT into 'nl:'
 
	facility = CONCAT(totals->qual[d.seq].Company,'  ')
 
 
FROM (dummyt d with seq = totals->rec_cnt)
 
ORDER BY facility
 
HEAD REPORT
 
	cnt = 0
	origfac = fillstring(2,' ')
 
DETAIL
	if (cnt = 0  OR facility != origfac)
 
		cnt = cnt + 1
		stat = alterlist(strata->qual, cnt)
 
	endif
	strata->qual[cnt].Company = facility
	strata->qual[cnt].Department = totals->qual[d.seq].Department
	strata->qual[cnt].Date_Of_Service = totals->qual[d.seq].Date_Of_Service
	strata->qual[cnt].Weight	= totals->qual[d.seq].Weight
 
	strata->qual[cnt].IP_Value = CNVTSTRING(CNVTINT(strata->qual[cnt].IP_Value) + CNVTINT(totals->qual[d.seq].IP_Value))
	strata->qual[cnt].OP_Value = CNVTSTRING(CNVTINT(strata->qual[cnt].OP_Value) + CNVTINT(totals->qual[d.seq].OP_Value))
	strata->rec_cnt		=	cnt
 
	origfac = facility
 
 
WITH nocounter
 
;CALL ECHORECORD(totals)
;CALL ECHORECORD(strata)
;GO TO exitscript
 
 
;CALL ECHORECORD(a)
;GO TO exitscript
IF (VALIDATE(request->batch_selection)> 0)
if (request->batch_selection > ' ')
	GO TO ops
else
	GO TO em
endif
ENDIF
 
 
;Display results
#em
SELECT into value($outdev)
	facility = CONCAT(a->qual[d.seq].facility,'                     '),
	Company = concat(a->qual[d.seq].ordqual[d2.seq].ordactnqual[d3.seq].Company,'  '),
	name = CONCAT(a->qual[d.seq].name,'                                  '),
	fin  = CONCAT(a->qual[d.seq].fin,'               '),
	orderName = CONCAT(a->qual[d.seq].ordqual[d2.seq].ordname,'                                          '),
	orderdate = CONCAT(a->qual[d.seq].ordqual[d2.seq].orddttm,'                     '),
	orderid	= a->qual[d.seq].ordqual[d2.seq].orderid,
	ordertype = a->qual[d.seq].ordqual[d2.seq].ordertype,
	enctype = CONCAT(a->qual[d.seq].enctype,'                        '),
	encclass = CONCAT(a->qual[d.seq].encclass,'                        '),
	pattype = a->qual[d.seq].pattype,
	acttype	 = CONCAT(a->qual[d.seq].ordqual[d2.seq].ordactnqual[d3.seq].ordaction,'                          '),
	actdttm = CONCAT(a->qual[d.seq].ordqual[d2.seq].ordactnqual[d3.seq].oadttm,'                              '),
	ordstatus = CONCAT(a->qual[d.seq].ordqual[d2.seq].ordsts,'                       '),
	orddetails = CONCAT(a->qual[d.seq].ordqual[d2.seq].orddetails,'                                            '),
	username = CONCAT(a->qual[d.seq].ordqual[d2.seq].ordactnqual[D3.SEQ].oaprsnl,'                                    '),
	position = CONCAT(a->qual[d.seq].ordqual[d2.seq].ordactnqual[d3.seq].position,'                    '),
	verify_ind = a->qual[d.seq].ordqual[d2.seq].ordactnqual[d3.seq].verify_ind
 
 
 
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 (dummyt d3 with seq = 1)
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].ord_cnt)
JOIN d2
WHERE MAXREC(d3,a->qual[d.seq].ordqual[d2.seq].ordactncnt)
JOIN d3
WHERE a->qual[d.seq].ordqual[d2.seq].ordactnqual[d3.seq].printflg = 1
 
 
ORDER BY facility
 
 
WITH nocounter, format, separator = ' '
 
GO TO exitscript
 
 
 
;
;extract file
SET MODIFY FILESTREAM
#ops
SELECT into VALUE(filename)
 
FROM (dummyt d with seq = strata->rec_cnt)
 
PLAN d
 
HEAD REPORT
	crlf = CONCAT(CHAR(13))
	'Company','|',
	'Department','|',
	'Activity_Code','|',
	'Date_of_service','|',
	'Weight','|',
	'IP_Value','|',
	'OP_Value','|',
	'Total_Value',
	crlf,
	ROW + 1
 
	ACT_CODE =FILLSTRING(1,' ')
	IP_VAL = FILLSTRING(1,' ')
	OP_VAL = FILLSTRING(1,' ')
	TOTAL_VAL = FILLSTRING(1,' ')
 
 
DETAIL
	ACT_CODE = trim(CNVTSTRING(totals->qual[d.seq].Activity_Code))
 
;	IP_VAL = TRIM(CNVTSTRING(totals->qual[d.seq].IP_Value,8,0),8)
;	OP_VAL = TRIM(cnvtstring(totals->qual[d.seq].OP_Value,8,0),8)
;	TOTAL_VAL = TRIM(cnvtstring(totals->qual[d.seq].Total_Value,8,0),8)
 
 	if (CNVTINT(strata->qual[d.seq].IP_Value) > 0 and
 	CNVTINT(strata->qual[d.seq].OP_Value) > 0)
 		;IP
 		strata->qual[d.seq].Company,'|',
		strata->qual[d.seq].Department,'|',
		'400000UNIT','|',
		strata->qual[d.seq].Date_Of_Service,'|',
		strata->qual[d.seq].Weight,'|',
		strata->qual[d.seq].IP_Value,'|',
		'0','|',
		strata->qual[d.seq].IP_Value,
		crlf,
		ROW + 1
 
 		;OP
 		strata->qual[d.seq].Company,'|',
		strata->qual[d.seq].Department,'|',
		'420000UNIT','|',
		strata->qual[d.seq].Date_Of_Service,'|',
		strata->qual[d.seq].Weight,'|',
		'0','|',
		strata->qual[d.seq].OP_Value,'|',
		strata->qual[d.seq].OP_Value,
		crlf,
 
		ROW + 1
 
 
 	elseif(CNVTINT(strata->qual[d.seq].OP_Value)> 0)
 		;OP
 		strata->qual[d.seq].Company,'|',
		strata->qual[d.seq].Department,'|',
		'420000UNIT','|',
		strata->qual[d.seq].Date_Of_Service,'|',
		strata->qual[d.seq].Weight,'|',
		'0','|',
		strata->qual[d.seq].OP_Value,'|',
		strata->qual[d.seq].OP_Value,
		crlf,
		ROW + 1
 
 
 	else ;ip only
 		;IP
 		strata->qual[d.seq].Company,'|',
		strata->qual[d.seq].Department,'|',
		'400000UNIT','|',
		strata->qual[d.seq].Date_Of_Service,'|',
		strata->qual[d.seq].Weight,'|',
		strata->qual[d.seq].IP_Value,'|',
		'0','|',
		strata->qual[d.seq].IP_Value,
		crlf,
 
		ROW + 1
 
 
 	endif
 
 
 
 
 
 
	ACT_CODE =FILLSTRING(1,' ')
	IP_VAL = FILLSTRING(1,' ')
	OP_VAL = FILLSTRING(1,' ')
	TOTAL_VAL = FILLSTRING(1,' ')
 
 
 
 
 
WITH nocounter, format = STREAM
CALL ECHORECORD(a)
;GO TO exitscript
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
 
#exitscript
 
end
go
