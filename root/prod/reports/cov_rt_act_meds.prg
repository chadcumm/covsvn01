/*****************************************************
Author		 :  Michael Layman
Date Written :  4/26/18
Program Title:  Respiratory Therapy Active Medications
Source File	 :  cov_rt_act_meds.prg
Object Name	 :	cov_rt_act_meds
Directory	 :	cust_script
DVD version  :	2017.11.1.81
HNA version  :	2017
CCL version  :	8.2.3
Purpose      :  This program will produce a report
				that will display active scheduled
				medications for the respiratory therapy
				department.
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
 
drop program cov_rt_act_meds go
create program cov_rt_act_meds
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 0 

with OUTDEV, facility
 
 
 
 
/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
**************************************************************/
;FREE RECORD a
IF (VALIDATE(a) = 0)
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
	2	encdspind	=	i2
	2	ordqual[*]
		3	orderid		=	f8
		3	ordername	=	vc
		3	dose		=	vc
		3	freq		=	vc
		3	scheddttm	=	vc
		3	scheddatetm	=	f8
		3	orddttm		=	vc
		3	drugcategory = 	vc
		3	freqid		=	f8
		3	tempordid	=	f8
 		3	rtmeddspind	=	i2
 		3	dispcategory = vc
 
 
)
endif
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
DECLARE rtact 	= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',106,'RESPIRATORY')), PROTECT
DECLARE orddept = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',14281,'ORDERED')), PROTECT
DECLARE ordsts	= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',6004,'ORDERED')), PROTECT
DECLARE ip		= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',71,'INPATIENT')), PROTECT
DECLARE obs		= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',71,'OBSERVATION')), PROTECT
DECLARE ed		= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',71,'EMERGENCY')), PROTECT
DECLARE bh		= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 71,'BEHAVIORALHEALTH')), PROTECT
DECLARE rhip	= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',71,'REHABINPATIENT')), PROTECT
DECLARE snfip	= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 71,'SNFINPATIENT')), PROTECT
DECLARE opinabed= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 71, 'OUTPATIENTINABED')), PROTECT
DECLARE mrn		= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',4,'MRN')), PROTECT
DECLARE fin		= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',319,'FINNBR')), PROTECT
DECLARE phact	= f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',106,'PHARMACY')), PROTECT
DECLARE sqlstr	= vc WITH NOCONSTANT(FILLSTRING(1000,' ')), PROTECT
DECLARE iOpsInd = i2 WITH NOCONSTANT(0), PROTECT
DECLARE bdate	 = f8 WITH NOCONSTANT(0.0), PROTECT
DECLARE edate	 = f8 WITH NOCONSTANT(0.0), PROTECT
DECLARE chbdate	 = vc WITH NOCONSTANT(FILLSTRING(20,' ')), PROTECT
DECLARE chedate  = vc WITH NOCONSTANT(FILLSTRING(20,' ')), PROTECT
DECLARE sqlparser = vc WITH NOCONSTANT(FILLSTRING(255,' ')), PROTECT
DECLARE filename = vc WITH CONSTANT(CONCAT('cer_temp:',TRIM(CNVTLOWER(UAR_GET_CODE_DISPLAY($facility))),'_rt_meds.pdf')), PROTECT
 
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
 
 
;ops setup
if (VALIDATE(request->batch_selection) = 1)
 
	SET iOpsInd = 1
 
;	SET bdate = DATETIMEFIND(CNVTDATETIME(CURDATE-1, 0),'D','B','B')
;	SET edate = DATETIMEFIND(CNVTDATETIME(CURDATE-1,0),'D','B','E')
;
;	SET chbdate = FORMAT(CNVTDATETIME(bdate),"mm/dd/yyyy hh:mm;;q")
;	SET chedate = FORMAT(CNVTDATETIME(edate),"mm/dd/yyyy hh:mm;;q")
;
;	SET sqlparser = 'c.service_dt_tm BETWEEN CNVTDATETIME(bdate) AND CNVTDATETIME(edate)'
 
 
;else
 
;	SET bdate = CNVTDATETIME($begdate)
;	SET edate = CNVTDATETIME($enddate)
;	SET chbdate = FORMAT(CNVTDATETIME(bdate),"mm/dd/yyyy hh:mm;;q")
;	SET chedate = FORMAT(CNVTDATETIME(edate),"mm/dd/yyyy hh:mm;;q")
;	SET sqlparser = 'c.service_dt_tm BETWEEN CNVTDATETIME(bdate) AND CNVTDATETIME(edate)'
 
endif
 
CALL ECHO(BUILD('bdate :', bdate))
CALL ECHO(BUILD('edate :', edate))
CALL ECHO(BUILD('chbdate :', chbdate))
CALL ECHO(BUILD('chedate :', chedate))
CALL ECHO(BUILD('sqlparser :', sqlparser))
 
 
;set up date parser
;CASE ($optShiftDay)
;
;	OF (1):
;
;		SET sqlstr = CONCAT('o.current_start_dt_tm BETWEEN CNVTDATETIME(CURDATE,0700)',
;		' AND CNVTDATETIME(CURDATE,1500)')
;
;	OF (2):
;		SET sqlstr = CONCAT('o.current_start_dt_tm BETWEEN CNVTDATETIME(CURDATE,1500)',
;		' AND CNVTDATETIME(CURDATE,2300)')
;
;	OF (3):
;
;		SET sqlstr = CONCAT('o.current_start_dt_tm BETWEEN CNVTDATETIME(CURDATE,2300)',
;		' AND CNVTDATETIME(CURDATE+1,0700)')
;
;	OF (4):
;		SET sqlstr = CONCAT('o.current_start_dt_tm BETWEEN CNVTDATETIME(CURDATE,0)',
;		' AND CNVTDATETIME(CURDATE, 2359)')
;
;ENDCASE
 
;CALL ECHO(BUILD('sqlstr :', sqlstr))
;GO TO exitscript
 
SELECT into 'nl:'
 
FROM orders o,
	 encounter e,
	 person p,
	 encntr_alias ea,
	 person_alias pa;,
	; mltm_category_drug_xref mcdx,
	; mltm_drug_categories mdc
 
 
PLAN o
WHERE o.activity_type_cd = phact
AND o.dept_status_cd = orddept
;AND o.current_start_dt_tm BETWEEN CNVTLOOKBEHIND("4 H", CNVTDATETIME(CURDATE, CURTIME3))
;AND CNVTLOOKAHEAD("20 H", CNVTDATETIME(CURDATE, CURTIME3))
;parser(sqlstr)
AND o.order_status_cd = ordsts
AND o.active_ind = 1
AND o.template_order_id = 0.00
AND o.orig_ord_as_flag IN (0, 1)
AND o.prn_ind != 1
;AND o.template_order_flag = 0
JOIN e
WHERE o.encntr_id = e.encntr_id
AND e.encntr_type_cd IN (ip,  obs, ed, bh,opinabed, rhip, snfip)
AND e.loc_facility_cd = $facility
AND e.disch_dt_tm IS NULL
AND e.active_ind = 1
JOIN p
WHERE e.person_id = p.person_id
AND p.active_ind = 1
JOIN ea
WHERE E.encntr_id = ea.encntr_id
AND ea.encntr_alias_type_cd = fin
AND ea.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")
JOIN pa
WHERE P.person_id = pa.person_id
AND pa.person_alias_type_cd = mrn
AND pa.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")
;JOIN mcdx
;WHERE mcdx.drug_identifier = SUBSTRING(9,6,o.cki)
;JOIN mdc
;WHERE mcdx.multum_category_id = mdc.multum_category_id
;AND mdc.category_name IN ('respiratory agents',
;'miscellaneous respiratory agents',
;'respiratory inhalant products',
;'upper respiratory combinations',
;'adrenergic bronchodilators'
;)
 
ORDER BY e.encntr_id, o.order_id
 
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
HEAD o.order_id ;DETAIL
	ocnt = ocnt + 1
	if (mod(ocnt, 10 ) = 1 or ocnt = 1)
 
		stat = alterlist(a->qual[cnt].ordqual, ocnt + 9)
 
	endif
 
	a->qual[cnt].ordqual[ocnt].orderid		=	o.order_id
	a->qual[cnt].ordqual[ocnt].ordername 	= UAR_GET_CODE_DISPLAY(o.catalog_cd)
	a->qual[cnt].ordqual[ocnt].orddttm		= FORMAT(o.orig_order_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].ordqual[ocnt].scheddttm	= FORMAT(o.current_start_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].ordqual[ocnt].scheddatetm	= o.current_start_dt_tm
	;a->qual[cnt].ordqual[ocnt].drugcategory = mdc.category_name
	a->qual[cnt].ordqual[ocnt].tempordid	= o.template_order_id
	a->qual[cnt].ordcnt						= ocnt
FOOT e.encntr_id
	stat = alterlist(a->qual[cnt].ordqual, ocnt)
 
FOOT REPORT
	stat = alterlist(a->qual, cnt)
 
WITH nocounter
 
if (a->rec_cnt > 0)
;order details
 
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 order_detail od
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].ordcnt)
JOIN d2
JOIN od
WHERE a->qual[d.seq].ordqual[d2.seq].orderid = od.order_id
AND od.oe_field_meaning IN ('REQSTARTDTTM','STRENGTHDOSE','STRENGTHDOSEUNIT',
'VOLUMEDOSE', 'VOLUMEDOSEUNIT', 'FREQ', 'FREQSCHEDID', 'DISPENSECATEGORY')
 
HEAD od.order_id
 
	strength = fillstring(15,' ')
	strengthunit = fillstring(15,' ')
	vol = fillstring(15,' ')
	volunits = fillstring(15,' ')
 
 
DETAIL
	CASE (od.oe_field_meaning)
 
		OF ('REQSTARTDTTM'):
 
			a->qual[d.seq].ordqual[d2.seq].scheddttm = od.oe_field_display_value
 
		OF ('STRENGTHDOSE'):
			strength = od.oe_field_display_value
 
 
		OF ('STRENGTHDOSEUNIT'):
 
			strengthunit = od.oe_field_display_value
 
		OF ('VOLUMEDOSE'):
 
			vol  = od.oe_field_display_value
 
		OF ('VOLUMEDOSEUNIT'):
 
			volunits = od.oe_field_display_value
 
		OF ('FREQ'):
 
			a->qual[d.seq].ordqual[d2.seq].freq = od.oe_field_display_value
		OF ('FREQSCHEDID'):
 
			a->qual[d.seq].ordqual[d2.seq].freqid = od.oe_field_value
 		OF ('DISPENSECATEGORY'):
 			a->qual[d.seq].ordqual[d2.seq].dispcategory = od.oe_field_display_value
	ENDCASE
 
FOOT od.order_id
 
		IF (SIZE(TRIM(strength)) > 0 AND SIZE(TRIM(vol)) > 0)
 
			a->qual[d.seq].ordqual[d2.seq].dose = BUILD2(TRIM(strength), ' ',TRIM(strengthunit),
														  ' = ', TRIM(vol), ' ', TRIM(volunits))
		ELSE
			a->qual[d.seq].ordqual[d2.seq].dose = BUILD2(TRIM(vol), ' ', TRIM(volunits))
 
		ENDIF
 
		strength = fillstring(15,' ')
		strengthunit = fillstring(15,' ')
		vol = fillstring(15,' ')
		volunits = fillstring(15,' ')
 
 
WITH NOCOUNTER
endif
 
 
;get freq if missing from order details
SELECT into 'nl:'
 
FROM (dummyt d with seq = a->rec_cnt),
	 (dummyt d2 with seq = 1),
	 frequency_schedule fs
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].ordcnt)
JOIN d2
JOIN fs
WHERE a->qual[d.seq].ordqual[d2.seq].freqid = fs.frequency_id
AND fs.active_ind = 1
 
DETAIL
 
	if (SIZE(a->qual[d.seq].ordqual[d2.seq].freq) = 0)
 
		a->qual[d.seq].ordqual[d2.seq].freq = UAR_GET_CODE_DISPLAY(fs.frequency_cd)
 
	endif
 
WITH nocounter
 
 
;Qualify on RT Freq.
SELECT into 'nl:'
	encntrid = a->qual[d.seq].encntrid,
	orderid = a->qual[d.seq].ordqual[d2.seq].orderid
FROM (dummyt d with seq = a->rec_cnt),
	(dummyt d2 with seq = 1)
 
PLAN d
WHERE MAXREC(d2, a->qual[d.seq].ordcnt)
JOIN d2
 
DETAIL
 
	IF (substring(1,2,a->qual[d.seq].ordqual[d2.seq].freq) = 'RT')
 
		a->qual[d.seq].ordqual[d2.seq].rtmeddspind = 1
 
	ENDIF
 
 	IF (a->qual[d.seq].ordqual[d2.seq].dispcategory = 'RT COA')
 
 		a->qual[d.seq].ordqual[d2.seq].rtmeddspind = 1
 
 	ENDIF
 
	IF (a->qual[d.seq].ordqual[d2.seq].rtmeddspind = 1)
 
		a->qual[d.seq].encdspind = 1
 
	ENDIF
 
 
 
WITH nocounter
 
 
 
if (iOpsInd = 1)
 
	execute cov_rt_act_meds_btg_lyt VALUE(filename), VALUE($facility)
 
endif
 
 
CALL ECHORECORD(a)
;GO TO exitscript
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
 
#exitscript
 
end
go
 
