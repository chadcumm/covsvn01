/***********************************************************************************
Author 			:	Mike Layman
Date Written	:	10/31/2017
Program Title	:	Miscellaneous Send Out Lab Driver
Source File		:	cov_gl_misc_test_drvr.prg
Object Name		:	cov_gl_misc_test_drvr
Directory		:	cust_script
DVD Version		:	2017.07.1.81
HNA Version		:	2015.01
CCL Version		:	8.8.3
Purpose			: 	This program is designed to display the
					miscellaneous lab send out tests that are
					sent to Mayo, Quest and other Reference labs.
Tables Read		:	person, encounter, encntr_alias, person_alias,
					orders, order_action, order_detail
Tables Updated	:	NA
Include File	:	NA
Shell Scripts	:	NA
Executing App	:	Explorer Menu
Special Notes	:
Usage			:	cov_gl_misc_test_drvr "mine", 555555.00, 222222.00 go


Mod		Date		Engineer				Comment
----    ----------- ----------------------- ----------------------------------------
001		10/31/2017	Mike Layman				Original Release
002     06/01/2020  Dawn Greer, DBA         CR 7854 1) Change criteria from
                                               original order date to
                                               collection date
                                            2) Remove MRN criteria
                                            3) If no row return, create a
                                            blank report.
                                            4) Added documentation
003     01/19/2021  Dawn Greer, DBA     	CR 9346 1) Added Facilities to the
                                            facility prompt.  Changed the
                                            facility prompt to allow more
                                            than one selection at a time.
                          					2) Added code values with documentation
                          					to replace variables
004     07/28/2021  Dawn Greer, DBA         CR 9117 - Add Ordering Physician 
************************************************************************************/
drop program cov_gl_misc_test_drvr go
create program cov_gl_misc_test_drvr
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 0
	, "Seelct Begin Date" = "SYSDATE"
	, "Select End Date" = "SYSDATE"
 
with OUTDEV, facility, begdate, enddate
 
/* Decalre Record Structure and Variables */	;002
;FREE RECORD a
RECORD a
(
1	rec_cnt	=	i4
1	qual[*]
	2	personid			=	f8
	2	encntrid			=	f8
	2	name				=	vc
	2	fin					=	vc
	2	ordcnt				=	i4
	2   facility            =   vc
	2	ordqual[*]
			3	orderid		=	f8
			3	accnbr		=	vc
			3	accnid		=	f8
			3	ordname		=	vc
			3	orddttm		=	vc
			3	colldttm	=	vc
			3	labtest		=	vc
			3	comments	=	vc
			3   ordprov     =   vc	;004
			3	ordcommcnt	=	i4
			3	ordcommqual[*]
				4	longtextid	=	f8
				4	comment		=	vc
)
 
DECLARE iOpsInd = i2 WITH NOCONSTANT(0), PROTECT
DECLARE bdate	 = f8 WITH NOCONSTANT(0.0), PROTECT
DECLARE edate	 = f8 WITH NOCONSTANT(0.0), PROTECT
DECLARE chbdate	 = vc WITH NOCONSTANT(FILLSTRING(20,' ')), PROTECT
DECLARE chedate  = vc WITH NOCONSTANT(FILLSTRING(20,' ')), PROTECT
DECLARE bdatechar = vc  ;002
DECLARE btimechar = vc  ;002
DECLARE edatechar = vc  ;002
DECLARE etimechar = vc  ;002
DECLARE fac_opr_var = c2
DECLARE faclist = c2000
DECLARE facprompt = vc
DECLARE num = i4
DECLARE facitem = vc
 
/* Start Code */		;002
;ops setup
IF (VALIDATE(request->batch_selection) = 1)
 
	SET iOpsInd = 1
 
	SET bdate = DATETIMEFIND(CNVTDATETIME(CURDATE-1, 0),'D','B','B')
	SET edate = CNVTDATETIME(CURDATE-1,2359)
 
	SET chbdate = FORMAT(CNVTDATETIME(bdate),"mm/dd/yyyy hh:mm;;q")
	SET chedate = FORMAT(CNVTDATETIME(edate),"mm/dd/yyyy hh:mm;;q")
 
ELSE
 
	SET bdate = CNVTDATETIME($begdate)
	SET edate = CNVTDATETIME($enddate)
	SET chbdate = FORMAT(CNVTDATETIME(bdate),"mm/dd/yyyy hh:mm;;q")
	SET chedate = FORMAT(CNVTDATETIME(edate),"mm/dd/yyyy hh:mm;;q")
 
	SET bdatechar = SUBSTRING(1,11,$begdate)	;002
	SET btimechar = SUBSTRING(13,5,$begdate)	;002
	SET edatechar = SUBSTRING(1,11,$enddate)	;002
	SET etimechar = SUBSTRING(13,5,$enddate)	;002
 
ENDIF
 
;003 /*Facility Prompt Changes*/
/**********************************************************
Get CMG Facility Data
***********************************************************/
 
;Pulling the Facility List for when Any is selected in the Prompt
SELECT
    facnum = CNVTSTRING(l.location_cd)
FROM location l
WHERE l.location_type_cd = 783.00 /*Facility*/
AND l.location_cd IN ( 2552503657 /*CMC*/,29797179 /*COVPTC*/,
	2552503635 /*FLMC*/,21250403 /*FSR*/,
	2553765363 /*FSR FSW Diagn*/,2553765571 /*FSR Pat Neal*/,
	2553765627 /*FSR Select Spec*/,2553765707 /*FSR TCU*/,
	2552503653 /*LCMC*/,2553765435 /*LCMC Breast Ctr*/,
	2553765427 /*LCMC Card Rehab*/,2553765387 /*LCMC Dwtn INF*/,
	2553765371 /*LCMC Nsg Home*/,2553765411 /*LCMC Sevier INF*/,
	2553765419 /*LCMC West INF*/,2552503639 /*MHHS*/,
	2553765467 /*MHHS ASC*/,2553765475 /*MHHS Behav Hlth*/,
	2553765491 /*MHHS MRDC*/,2552503613	/*MMC*/,
	2553765283 /*MMC Cheyenne*/,2555024801 /*MMC Endo*/,
	2553765603 /*PBH Lighthouse*/,2553765579 /*PBH Peninsula*/,
	2552503645 /*PW*/,2553765507 /*PW Breast Ctr*/,
	2554143643 /*PW Plaza Diag*/,2553765539	/*PW Sleep Center*/,
	2552503649 /*RMC*/
)
AND l.active_ind = 1
 
HEAD REPORT
	faclist = FILLSTRING(2000,' ')
 	faclist = '('
DETAIL
	faclist = BUILD(BUILD(faclist, facnum), ', ')
 
FOOT REPORT
	faclist = BUILD(faclist,')')
	faclist = REPLACE(faclist,',','',2)
 
WITH nocounter
 
;Facility Prompt
IF(SUBSTRING(1,1,REFLECT(PARAMETER(PARAMETER2($facility),0))) = "L")		;multiple options selected
	SET fac_opr_var = "IN"
	SET facprompt = '('
	SET num = CNVTINT(SUBSTRING(2,2,REFLECT(PARAMETER(PARAMETER2($facility),0))))
 
	FOR (i = 1 TO num)
		SET facitem = CNVTSTRING(PARAMETER(PARAMETER2($facility),i))
		SET facprompt = BUILD(facprompt,facitem)
		IF (i != num)
			SET facprompt = BUILD(facprompt, ",")
		ENDIF
	ENDFOR
	SET facprompt = BUILD(facprompt, ")")
	SET facprompt = BUILD("e.loc_facility_cd IN ",facprompt)
 
ELSEIF(PARAMETER(PARAMETER2($facility),1)=0.0)  ;any was selected
	SET fac_opr_var = "IN"
	SET facprompt = BUILD("e.loc_facility_cd IN ", faclist)
ELSE 	;single value selected
	SET fac_opr_var = "="
	SET facitem = CNVTSTRING(PARAMETER(PARAMETER2($facility),1))
	SET facprompt = BUILD("e.loc_facility_cd = ", facitem)
ENDIF
;003 /*Facility Prompt changes*/
 
CALL ECHO(facprompt)
 
/* Get Misc Tests Collected */   ;002
 
SELECT INTO 'nl:'
FROM orders o,
	 encounter e,
	 person p,
	 encntr_alias ea,
	 accession_order_r aor,
	 container_accession ca,	;002
	 container_event ce,	 	;002
	 order_action oa, 	;004
	 prsnl prov   ;004
PLAN o WHERE o.catalog_cd IN (31717349.00 /*Misc Lab Test Mayo*/,2553894063.00/*Misc Lab Test Quest*/, ;003
		2597523557.00 /*Misc Lab Test Other*/) ;003
	AND o.order_status_cd != 2542.00 /*Canceled*/  ;003
JOIN e WHERE o.encntr_id = e.encntr_id
	AND PARSER(facprompt)	;003
	AND e.active_ind = 1
JOIN p WHERE e.person_id = p.person_id
	AND p.active_ind = 1
JOIN ea WHERE e.encntr_id = ea.encntr_id
	AND ea.encntr_alias_type_cd = 1077 /*Fin*/
	AND ea.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 0")
JOIN aor WHERE o.order_id = aor.order_id
JOIN ca	WHERE aor.accession_id = ca.accession_id		;002
JOIN ce WHERE ca.container_id = ce.container_id			;002
	AND ce.event_type_cd = 1794.00 /*Collected*/		;002 ;003
	AND ce.drawn_dt_tm BETWEEN CNVTDATETIME(bdate) AND CNVTDATETIME(edate)
JOIN oa WHERE o.order_id = oa.order_id	;004
	AND oa.action_type_cd = 2534.00 /*Order*/	;004
JOIN prov WHERE oa.order_provider_id = prov.person_id	;004

HEAD REPORT
	cnt = 0
 
HEAD p.person_id
	cnt = cnt + 1
	IF (mod(cnt,10) = 1 OR cnt = 1)
 
		stat = alterlist(a->qual, cnt + 9)
 
	ENDIF
	a->qual[cnt].personid	=	p.person_id
	a->qual[cnt].encntrid	=	e.encntr_id
	a->qual[cnt].name		=	TRIM(p.name_full_formatted)
	a->qual[cnt].fin		=	TRIM(ea.alias)
	a->qual[cnt].facility   =   UAR_GET_CODE_DISPLAY(e.loc_facility_cd)
	a->rec_cnt				=	cnt
	ocnt = 0
 
HEAD o.order_id
 
	ocnt = ocnt + 1
	IF (mod(ocnt,10) = 1 OR ocnt = 1)
 
		stat = alterlist(a->qual[cnt].ordqual, ocnt + 9)
 
	ENDIF
	a->qual[cnt].ordqual[ocnt].orderid	=	o.order_id
	a->qual[cnt].ordqual[ocnt].orddttm 	=	FORMAT(O.orig_order_dt_tm, "mm/dd/yyyy hh:mm;;q")
	a->qual[cnt].ordqual[ocnt].ordname	=	TRIM(o.hna_order_mnemonic)
	a->qual[cnt].ordqual[ocnt].accnbr   =   CNVTACC(aor.accession)
	a->qual[cnt].ordqual[ocnt].accnid	=	aor.accession_id
    a->qual[cnt].ordqual[ocnt].colldttm =   FORMAT(ce.drawn_dt_tm, "mm/dd/yyyy hh:mm;;q")	;002
    a->qual[cnt].ordqual[ocnt].ordprov  =   TRIM(prov.name_full_formatted,3)	;004
	a->qual[cnt].ordcnt					=	ocnt
 
FOOT p.person_id
 
	stat = alterlist(a->qual[cnt].ordqual, ocnt)
 
 
FOOT REPORT
	stat = alterlist(a->qual, cnt)
 
WITH nocounter
 
IF (a->rec_cnt != 0)
 
	/*Get Tab Tests Names */  ;002
	SELECT INTO 'nl:'
 
	FROM (dummyt d WITH seq = a->rec_cnt),
		 (dummyt d2 WITH seq = 1),
		 order_detail od
 
	PLAN d
	WHERE MAXREC(d2, a->qual[d.seq].ordcnt)
	JOIN d2
	JOIN od
	WHERE a->qual[d.seq].ordqual[d2.seq].orderid = od.order_id
	AND od.oe_field_id = 274145197.00
 
 
	HEAD od.order_id
		a->qual[d.seq].ordqual[d2.seq].labtest = TRIM(od.oe_field_display_value)
 
 
	WITH nocounter
 
	/* Get Order Comments */  ;002
	SELECT INTO 'nl:'
 
	FROM (dummyt d WITH seq = a->rec_cnt),
		 (dummyt d2 WITH seq = 1),
		 order_comment oc,
		 long_text lt
 
	PLAN d
	WHERE MAXREC(d2, a->qual[d.seq].ordcnt)
	JOIN d2
	JOIN oc
	WHERE a->qual[d.seq].ordqual[d2.seq].orderid = oc.order_id
	JOIN lt
	WHERE oc.long_text_id = lt.long_text_id
 
	HEAD oc.order_id
 
		cnt = 0
 
	HEAD lt.long_text_id
		cnt = cnt + 1
		IF (mod(cnt,10) = 1 OR cnt = 1)
 
			stat = alterlist(a->qual[d.seq].ordqual[d2.seq].ordcommqual, cnt + 9)
 
		ENDIF
 
		a->qual[d.seq].ordqual[d2.seq].ordcommqual[cnt].longtextid	=	lt.long_text_id
		a->qual[d.seq].ordqual[d2.seq].ordcommqual[cnt].comment		=   TRIM(lt.long_text)
		a->qual[d.seq].ordqual[d2.seq].ordcommcnt	=	cnt
 
	FOOT oc.order_id
		FOR (mcnt = 1 TO a->qual[d.seq].ordqual[d2.seq].ordcommcnt)
 
 
			IF (mcnt = a->qual[d.seq].ordqual[d2.seq].ordcommcnt)
				a->qual[d.seq].ordqual[d2.seq].comments = BUILD2(a->qual[d.seq].ordqual[d2.seq].comments,
				a->qual[d.seq].ordqual[d2.seq].ordcommqual[mcnt].comment)
			ELSE
				a->qual[d.seq].ordqual[d2.seq].comments = BUILD2(a->qual[d.seq].ordqual[d2.seq].comments,
				a->qual[d.seq].ordqual[d2.seq].ordcommqual[mcnt].comment,', ')
			ENDIF
 
		ENDFOR
 
 
		stat = alterlist(a->qual[d.seq].ordqual[d2.seq].ordcommqual, cnt)
 
	WITH nocounter
ENDIF
 
CALL ECHORECORD(a)
GO TO exitscript
 
#exitscript
 
END
GO
