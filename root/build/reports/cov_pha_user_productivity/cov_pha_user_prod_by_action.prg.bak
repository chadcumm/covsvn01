/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		03/30/2020
	Solution:			Perioperative
	Source file name:	cov_pha_user_productivity_v4.prg
	Object name:		cov_pha_user_productivity_v4
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	03/30/2020  Chad Cummings			Initial Release
******************************************************************************/
 
drop program cov_pha_user_prod_by_action go
create program cov_pha_user_prod_by_action
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 0
	, "Select Begin Date/Time" = "SYSDATE"
	, "Select End Date/Time" = "SYSDATE"
	, "Pharmacist" = 0
	;<<hidden>>"Search" = ""
	;<<hidden>>"Delete" = "" 

with OUTDEV, facility, begdate, enddate, NEW_PROVIDER

call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))

if (not(validate(reply,0)))
record  reply
(
	1 text = vc
	1 status_data
	 2 status = c1
	 2 subeventstatus[1]
	  3 operationname = c15
	  3 operationstatus = c1
	  3 targetobjectname = c15
	  3 targetobjectvalue = c100
)
endif

call set_codevalues(null)
call check_ops(null)

free set t_rec
record t_rec
(
	1 cnt					= i2
	1 code_values
	 2 cancelcd				= f8 
	 2 pharmordcd			= f8
	 2 fin					= f8 
	 2 ordacttype			= f8 
	 2 dcacttype			= f8 
	 2 facoper				= vc 
	 2 modacttype			= f8 
	 2 pharmposcd			= f8 
	 2 pharmt1poscd			= f8
	 2 pharmt2poscd			= f8
	 2 pharmt3poscd			= f8
	 2 pharmmgmntcd			= f8
	 2 ITPharmnetcd			= f8
	 2 techAddrCd			= f8
	1 files
	 2 filename				= vc
	 2 filename2			= vc
	 2 cer_temp				= vc
	1 dates
	 2 bdate				= dq8
	 2 edate				= dq8
)

declare new_provider_var	 	= vc with noconstant(" ")
declare new_provider_id			= f8 with noconstant(0.0)
declare facility_cd 			= f8 with noconstant(1.0)
declare facility_var 			= vc with noconstant(" ")
 
set t_rec->code_values.pharmordcd	=	UAR_GET_CODE_BY('DISPLAYKEY',106,'PHARMACY')
set t_rec->code_values.cancelcd		=	UAR_GET_CODE_BY('DISPLAYKEY',6004,'CANCELED')
set t_rec->code_values.fin			=	UAR_GET_CODE_BY('DISPLAYKEY',319,'FINNBR')
set t_rec->code_values.ordacttype	=	UAR_GET_CODE_BY('DISPLAYKEY',6003,'ORDER')
set t_rec->code_values.dcacttype	=	UAR_GET_CODE_BY('DISPLAYKEY',6003,'DISCONTINUE')
set t_rec->code_values.facoper		=	FILLSTRING(2,' ')
set t_rec->code_values.modacttype	=	UAR_GET_CODE_BY('DISPLAYKEY',6003,'MODIFY')
set t_rec->code_values.pharmposcd	=	UAR_GET_CODE_BY('DISPLAYKEY',88,'PHARMNETPHARMACIST')
set t_rec->code_values.pharmt1poscd	=	UAR_GET_CODE_BY('DISPLAYKEY',88,'PHARMNETTECHNICIAN1')
set t_rec->code_values.pharmt2poscd	=	UAR_GET_CODE_BY('DISPLAYKEY',88,'PHARMNETTECHNICIAN2')
set t_rec->code_values.pharmt3poscd	=	UAR_GET_CODE_BY('DISPLAYKEY',88,'PHARMNETTECHNICIAN3')
set t_rec->code_values.pharmmgmntcd	=   UAR_GET_CODE_BY('DISPLAYKEY',88,'PHARMNETMANAGEMENT')
set t_rec->code_values.ITPharmnetcd	=	UAR_GET_CODE_BY('DISPLAYKEY',88,'ITPHARMNET')
set t_rec->code_values.techAddrCd	=	UAR_GET_CODE_BY('DISPLAYKEY',212,'TECHNICAL')

set t_rec->files.cer_temp = build("/cerner/d_",cnvtlower(trim(curdomain)),"/temp/")
set t_rec->files.filename = cnvtlower(BUILD('cer_temp:','V4_CovHlth_PR_Rx_Stats_',FORMAT(curdate,'yyyymmdd;;q'),'.txt'))
set t_rec->files.filename2 = cnvtlower(BUILD('cer_temp:','V4_CovHlth_Detail_Rx_Stats_',FORMAT(curdate,'yyyymmdd;;q'),'.txt'))

call writeLog(build2("-->Setting up Pharmacist"))
if ($NEW_PROVIDER = 0)
	set new_provider_var = "1=1"
else
	set new_provider_id = $NEW_PROVIDER
	set new_provider_var = "orr.review_personnel_id =new_provider_id" 
endif 

call writeLog(build2("-->Setting up Facility"))
IF (SUBSTRING(1,1,reflect(parameter(parameter2($facility),0)))="L")
	SET t_rec->code_values.facoper = "IN"
ELSEIF (parameter(parameter2($facility),1) = 1.0)
	SET t_rec->code_values.facoper = "!="
ELSE
	SET t_rec->code_values.facoper = "="
ENDIF

call writeLog(build2("-->Setting up Ops"))
if (program_log->run_from_ops = 1)
	SET t_rec->dates.bdate = datetimefind(CNVTDATETIME(CURDATE-1, 0),'D','B','B')
	SET t_rec->dates.edate = datetimefind(CNVTDATETIME(CURDATE-1, 0),'D','B','E')
else
	SET t_rec->dates.bdate = CNVTDATETIME($begdate)
	SET t_rec->dates.edate = CNVTDATETIME($enddate)
endif
 
call addEmailLog("chad.cummings@covhlth.com")

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))
 
free record or_rec
record or_rec
(
	1 cnt				= i4
	1 qual[*]
	 2 order_id			= f8
	 2 review_seq		= i4
	 2 action_seq		= i4
	 2 review_prsnl_id	= f8

) 
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
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Main Order Query ***********************************"))

select into 'nl:'
from 
	 orders o
	,encounter e
	,person p
	,encntr_alias ea
plan o
	where o.orig_order_dt_tm BETWEEN CNVTDATETIME(t_rec->dates.bdate) AND CNVTDATETIME(t_rec->dates.edate)
	AND o.activity_type_cd = t_rec->code_values.pharmordcd
	AND o.order_status_cd != t_rec->code_values.cancelcd
	AND o.template_order_id = 0.0
	;AND o.orig_ord_as_flag IN (0,1)
JOIN e
	WHERE o.encntr_id = e.encntr_id
	AND operator(e.organization_id,t_rec->code_values.facoper,$facility)
	AND e.active_ind = 1
JOIN p
	WHERE e.person_id = p.person_id
	AND p.active_ind = 1
	and   p.name_last_key not in(
									 "ZZZTEST"
									,"TTTEST"
									,"TTTTEST"
									,"TTTTMAYO"
									,"TTTTTEST"
									,"FFFFOP"
									,"TTTTGENLAB"
									,"TTTTQUEST"			
								)
JOIN ea
	WHERE e.encntr_id = ea.encntr_id
	AND ea.encntr_alias_type_cd = t_rec->code_values.fin
	AND ea.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")
	AND ea.active_ind = 1
ORDER BY 
	 e.encntr_id
	,o.order_id
HEAD REPORT
	cnt = 0
 	;a->facility = UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
HEAD e.encntr_id
	cnt = cnt + 1
	if (mod(cnt,10000) = 1 or cnt = 1)
		stat = alterlist(a->qual, cnt + 9999)
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
	if (MOD(ocnt,100) = 1 or ocnt = 1)
		stat = alterlist(a->qual[cnt].ordqual, ocnt + 99)
	endif
	a->qual[cnt].ordqual[ocnt].orderid		=	o.order_id
	a->qual[cnt].ordqual[ocnt].ordname		=	TRIM(o.hna_order_mnemonic)
	a->qual[cnt].ordqual[ocnt].ordsts		=	UAR_GET_CODE_DISPLAY(o.order_status_cd)
	a->qual[cnt].ordqual[ocnt].orddttm		= 	FORMAT(o.orig_order_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].ordqual[ocnt].prsnlid		=	o.updt_id
	a->qual[cnt].ordqual[ocnt].orddetails	=	REPLACE(REPLACE(TRIM(o.order_detail_display_line),CHAR(13)," "),CHAR(10)," ") ;002
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

call writeLog(build2("* END   Main Order Query ***********************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Order Review Query *********************************"))
;order review verify action
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
	AND pr.position_cd IN (
							 t_rec->code_values.pharmposcd
							,t_rec->code_values.pharmmgmntcd
						  )
	and parser(new_provider_var)
 
ORDER BY 
	orv.action_sequence DESC
HEAD orv.order_id
	stat = 0
head pr.person_id
	stat = 0	;NEED TO UNCOMMENT TO REDUCE TO ONE ORDER PER PHARMACIST
detail			;NEED TO UNCOMMENT TO REDUCE TO ONE ORDER PER PHARMACIST 
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
		CASE(a->qual[d.seq].facility)
			OF ('FLMC'):
				a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].Company = '28'
			OF ('FSR'):
				a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].Company = '20'
			OF ('FSR INF Oridge'):
				a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].Company = '20'
			OF ('FSR Pat Neal'):
				a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].Company = '20'
			OF ('FSR TCU'):
				a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].Company = '20'
			OF ('LCMC'):
				a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].Company = '26'
			OF ('LCMC Blount INF'):
				a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].Company = '26'
			OF ('LCMC Dwtn INF'):
				a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].Company = '26'
			OF ('LCMC Sevier INF'):
				a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].Company = '26'
			OF ('LCMC West INF'):
				a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].Company = '26'
			OF ('MHHS'):
				a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].Company = '25'
			OF ('MHHS ASC'):
				a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].Company = '25'
			OF ('MHHS Behav Hlth'):
				a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].Company = '25'
			OF ('MHHS MRDC'):
				a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].Company = '25'
			OF ('MMC'):
				a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].Company = '24'
			OF ('MMC Cheyenne'):
				a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].Company = '24'
			OF ('PW'):
				a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].Company = '22'
			OF ('PW Senior Behav'):
				a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].Company = '22'
			OF ('PBH Peninsula'):
				a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].Company = '65'
			OF ('RMC'):
				a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].Company = '27'
			ELSE
				a->qual[d.seq].ordqual[d2.seq].ordactnqual[cnt].Company = '00'
			endcase
	 	endif
WITH nocounter
 
call writeLog(build2("* END   Main Order Review Query ****************************"))
call writeLog(build2("************************************************************"))
 
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
 
 
 
 
 
	totals->qual[cnt].Activity_Code = t_rec->code_values.pharmordcd
	totals->qual[cnt].Date_Of_Service = FORMAT(curdate - 1,"MM/DD/YYYY;;D")
	totals->qual[cnt].IP_Value	=	CNVTSTRING(ip_val)
	totals->qual[cnt].OP_Value	=	CNVTSTRING(op_val)
	totals->qual[cnt].Total_Value = CNVTSTRING(tot_val)
	totals->qual[cnt].Weight	=	"1"
	totals->rec_cnt		=	cnt
 
WITH nocounter
 
call echorecord(totals)

 
 
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

if (program_log->run_from_ops = 1)
	go to ops
else
	go to em
endif


#em
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Display Report **************************************"))

SELECT into value($outdev)
	facility 	= substring(1,100,a->qual[d.seq].facility),
	Company 	= substring(1,100,a->qual[d.seq].ordqual[d2.seq].ordactnqual[d3.seq].Company),
	name 		= substring(1,100,a->qual[d.seq].name),
	fin  		= substring(1,100,a->qual[d.seq].fin),
	orderName 	= substring(1,100,a->qual[d.seq].ordqual[d2.seq].ordname),
	orderdate 	= substring(1,100,a->qual[d.seq].ordqual[d2.seq].orddttm),
	orderid		= a->qual[d.seq].ordqual[d2.seq].orderid,
	ordertype 	= a->qual[d.seq].ordqual[d2.seq].ordertype,
	enctype 	= substring(1,100,a->qual[d.seq].enctype),
	encclass 	= substring(1,100,a->qual[d.seq].encclass),
	pattype 	= substring(1,100,a->qual[d.seq].pattype),
	acttype	 	= substring(1,100,a->qual[d.seq].ordqual[d2.seq].ordactnqual[d3.seq].ordaction),
	actdttm 	= substring(1,100,a->qual[d.seq].ordqual[d2.seq].ordactnqual[d3.seq].oadttm),
	ordstatus 	= substring(1,100,a->qual[d.seq].ordqual[d2.seq].ordsts),
	orddetails 	= substring(1,100,a->qual[d.seq].ordqual[d2.seq].orddetails),
	username 	= substring(1,100,a->qual[d.seq].ordqual[d2.seq].ordactnqual[D3.SEQ].oaprsnl),
	position 	= substring(1,100,a->qual[d.seq].ordqual[d2.seq].ordactnqual[d3.seq].position),
	verify_ind 	= a->qual[d.seq].ordqual[d2.seq].ordactnqual[d3.seq].verify_ind
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
call writeLog(build2("* END Display Report **************************************"))
call writeLog(build2("************************************************************"))

;if (size(program_log->email,5) = 0)	
	go to exit_script
;endif

#ops

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Ops Report **************************************"))
call writeLog(build2(t_rec->files.filename2))

SELECT into value(t_rec->files.filename2)
	facility 	= substring(1,100,a->qual[d.seq].facility),
	Company 	= substring(1,100,a->qual[d.seq].ordqual[d2.seq].ordactnqual[d3.seq].Company),
	name 		= substring(1,100,a->qual[d.seq].name),
	fin  		= substring(1,100,a->qual[d.seq].fin),
	orderName 	= substring(1,100,a->qual[d.seq].ordqual[d2.seq].ordname),
	orderdate 	= substring(1,100,a->qual[d.seq].ordqual[d2.seq].orddttm),
	orderid		= a->qual[d.seq].ordqual[d2.seq].orderid,
	ordertype 	= a->qual[d.seq].ordqual[d2.seq].ordertype,
	enctype 	= substring(1,100,a->qual[d.seq].enctype),
	encclass 	= substring(1,100,a->qual[d.seq].encclass),
	pattype 	= substring(1,100,a->qual[d.seq].pattype),
	acttype	 	= substring(1,100,a->qual[d.seq].ordqual[d2.seq].ordactnqual[d3.seq].ordaction),
	actdttm 	= substring(1,100,a->qual[d.seq].ordqual[d2.seq].ordactnqual[d3.seq].oadttm),
	ordstatus 	= substring(1,100,a->qual[d.seq].ordqual[d2.seq].ordsts),
	orddetails 	= substring(1,100,a->qual[d.seq].ordqual[d2.seq].orddetails),
	username 	= substring(1,100,a->qual[d.seq].ordqual[d2.seq].ordactnqual[D3.SEQ].oaprsnl),
	position 	= substring(1,100,a->qual[d.seq].ordqual[d2.seq].ordactnqual[d3.seq].position),
	verify_ind 	= a->qual[d.seq].ordqual[d2.seq].ordactnqual[d3.seq].verify_ind
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
WITH nocounter, format, separator = ','

;call addAttachment(t_rec->files.cer_temp,trim(replace(t_rec->files.filename2,"cer_temp:","")))

call writeLog(build2("* END Ops Report **************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Ops File *******************************************"))
SET MODIFY FILESTREAM
call writeLog(build2(t_rec->files.filename2))
SELECT into VALUE(t_rec->files.filename)
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

call addAttachment(t_rec->files.cer_temp,trim(replace(t_rec->files.filename,"cer_temp:","")))

call writeLog(build2("* END   Ops File *******************************************"))
call writeLog(build2("************************************************************"))

go to exit_script

#exit_script
if (validate(t_rec))
	call writeLog(build2(cnvtrectojson(t_rec))) 
endif
if (validate(request))
	call writeLog(build2(cnvtrectojson(request))) 
endif
if (validate(reqinfo))
	call writeLog(build2(cnvtrectojson(reqinfo))) 
endif
if (validate(reply))
	call writeLog(build2(cnvtrectojson(reply))) 
endif
if (validate(program_log))
	call writeLog(build2(cnvtrectojson(program_log)))
endif
call exitScript(null)
call echorecord(t_rec)
;call echorecord(a)
;call echorecord(strata)
;call echorecord(code_values)
;call echorecord(program_log)
 
end
go
