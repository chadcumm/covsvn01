/***********************************************************
Author 			:	Mike Layman
Date Written	:	10/31/2017
Program Title	:	Laboratory Order Count Grid View
Source File		:	cov_gl_test_count_grid.prg
Object Name		:	cov_gl_test_count_grid
Directory		:	cust_script
DVD Version		:	2017.07.1.81
HNA Version		:	2015.01
CCL Version		:	8.8.3
Purpose			: 	This program is designed to display all lab
					orders for the passed in parameters.
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
002     01/27/2021  Dawn Greer, DBA         CR 6941 Combining
                                            cov_gl_test_count_drvr.prg
                                            and cov_gl_test_count_grid.prg.
003     04/21/2021  Dawn Greer, DBA         Published in PROD
 
************************************************************/
drop program cov_gl_test_count_grid go
create program cov_gl_test_count_grid
 
prompt 
	"Output to File/Printer/MINE" = "MINE"          ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 0
	, "Select Nursing Unit" = VALUE(0)
	, "Select Test" = VALUE(0)
	, "Container Type" = VALUE(0)
	, "Ordering Provider" = VALUE(0             )
	, "Consulting Provider" = VALUE(0)
	, "Select Encounter Type" = VALUE(0)
	, "Select Begin Order Date" = "SYSDATE"         ;* Please choose the date the test was performed, not ordered.
	, "Seelct End Order Date" = "SYSDATE"           ;* Please choose the date the test was performed, not ordered.
	, "Select Summary or Detail" = 0 

with OUTDEV, facility, unit, test, containertype, prov, consultprov, enctype, bdate, 
	edate, sumdet
 
/**************************************************************
	RECORD STRUCTURES
**************************************************************/
 
FREE RECORD a
RECORD a
(
	1	rec_cnt	=	i4
	1	qual[*]
		2	personid	=	f8
		2	encntrid	=	f8
		2	facility	=	c50
		2	name		=	c100
		2	fin			=	c20
		2   enctype     =   c50
		2	loc			=	c100
	 	2 	orderid		=	f8
		2   ordering_prov   =   c100
		2   consulting_prov = c100
		2	ordername	=	c100
		2 	orderdate	=	c20
		2	accnbr		=	vc
		2	perfdttm	=	c20
		2   container_type = c100
		2   catalogcd   =   f8
		2   totalcnt    =   i4
		2   ordlab 		=   c50
		2   perflab     =   c50
		2   instrument  =   c50
		2   containerid =   f8
		2   orgid       =   f8
		2   ordlabcd    =   f8
		2	perflabcd   =   f8
)
 
FREE RECORD totals
RECORD totals
(
	1	rec_cnt	=	i4
	1   new_rec_cnt = i4
	1	totaltestcnt	=	i4
	1	qual[*]
		2   facility    =   c50
		2   ordering_prov = c100
		2   consulting_prov = c100
		2	ordername	=	c100
		2   container_type = c100
		2   ordlab      =   c50
		2   perflab     =   c50
		2   instrument  =   c50
		2	ordcnt		=	i4
)
 
FREE RECORD prompts
RECORD prompts
(
	1	rec_cnt	=	i4
	1   p_facility = c300
	1   p_unit = c1000
	1   p_test = c1000
	1   p_order_prov = c100
	1   p_consult_prov = c100
	1   p_container_type = c100
	1	p_enctype = c100
	1   p_bdate = vc
	1   p_edate = vc
	1   p_sumdet = c20
)
 
/**************************************************************
; VARIABLES
**************************************************************/
DECLARE idx = i4 WITH NOCONSTANT(0), PROTECT
DECLARE testsql = vc WITH NOCONSTANT(FILLSTRING(500, ' ')), PROTECT
;Facility Prompt
DECLARE faclist = vc
DECLARE facprompt = vc
DECLARE facitem = vc
DECLARE facnamelist = vc
DECLARE facnameitem = vc
;Unit Prompt
DECLARE unitlist = vc
DECLARE unitprompt = vc
DECLARE unititem = vc
DECLARE unitnamelist = vc
DECLARE unitnameitem = vc
DECLARE unitnameprmpt = vc
;Test Prompt
DECLARE testlist = vc
DECLARE testprompt = vc
DECLARE testitem = vc
DECLARE testnamelist = vc
;Container Type Prompt
DECLARE containertypelist = vc
DECLARE containertypeprompt = vc
DECLARE containertypeitem = vc
DECLARE containertypenamelist = vc
DECLARE containertypenameprmpt = vc
;Provider Prompt
DECLARE provlist = vc
DECLARE provprompt = vc
DECLARE provnum = i4
DECLARE provitem = vc
DECLARE provnamelist = vc
DECLARE provnameprmpt = vc
;Consulting Provider Prompt
DECLARE consultprovlist = vc
DECLARE consultprovprompt = vc
DECLARE consultprovnum = i4
DECLARE consultprovitem = vc
DECLARE consultprovnamelist = vc
DECLARE consultprovnameprmpt = vc
;Enc Type Prompt
DECLARE enctypelist = vc
DECLARE enctypeprompt = vc
DECLARE enctypeitem = vc
DECLARE enctypenamelist = vc
DECLARE enctypenameprmpt = vc
 
/**************************************************************
; Prompts
**************************************************************/
/**************************************************************
; Facility Prompt
**************************************************************/
CALL ECHO ("Facility Prompt")
 
SELECT facnum = CNVTSTRING(l.organization_id)
FROM location l
WHERE l.location_type_cd = 783.00 /*Facility*/
AND l.location_cd IN (2552503657.00 /*CMC*/,
    29797179.00 /*COVPTC*/,
    2552503635.00 /*FLMC*/,
    21250403.00 /*FSR*/,
    2553765571.00 /*FSR Pat Neal*/,
    2553765627.00 /*FSR Select Spec*/,
    2553765707.00 /*FSR TCU*/,
    2552503653.00 /*LCMC*/,
    2553765371.00 /*LCMC Nsg Home*/,
    2552503639.00 /*MHHS*/,
    2552503613.00 /*MMC*/,
    2553765579.00 /*PBH Peninsula*/,
    2552503645.00 /*PW*/,
    2552503649.00 /*RMC*/
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
 
IF(SUBSTRING(1,1,REFLECT(PARAMETER(PARAMETER2($facility),0))) = "L")		;multiple options selected
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
	SET facprompt = CONCAT("e.organization_id IN ",facprompt)
 
ELSEIF(PARAMETER(PARAMETER2($facility),1)=0.0)  ;any was selected
	SET facprompt = CONCAT("e.organization_id IN ",faclist)
 
ELSE 	;single value selected
	SET facitem = CNVTSTRING(PARAMETER(PARAMETER2($facility),1))
	SET facprompt = CONCAT("e.organization_id = ", facitem)
 
ENDIF
 
; Get Facility prompt data selected
SELECT facnum = CNVTSTRING(e.organization_id)
,facname = UAR_GET_CODE_DISPLAY(e.location_cd)
FROM location e
WHERE e.location_type_cd = 783.00 /*Facility*/
AND e.location_cd IN (2552503657.00 /*CMC*/,
    29797179.00 /*COVPTC*/,
    2552503635.00 /*FLMC*/,
    21250403.00 /*FSR*/,
    2553765571.00 /*FSR Pat Neal*/,
    2553765627.00 /*FSR Select Spec*/,
    2553765707.00 /*FSR TCU*/,
    2552503653.00 /*LCMC*/,
    2553765371.00 /*LCMC Nsg Home*/,
    2552503639.00 /*MHHS*/,
    2552503613.00 /*MMC*/,
    2553765579.00 /*PBH Peninsula*/,
    2552503645.00 /*PW*/,
    2552503649.00 /*RMC*/
    )
AND e.active_ind = 1
AND parser(facprompt)
ORDER BY facname
 
HEAD REPORT
	facnamelist = FILLSTRING(2000,' ')
 
DETAIL
	facnamelist = BUILD(BUILD(facnamelist, facname), ', ')
 
FOOT REPORT
	facnamelist = REPLACE(facnamelist,',','',2)
	prompts->p_facility = EVALUATE2(IF(PARAMETER(PARAMETER2($facility),1) = 0.0) "Facilities: All"
		ELSEIF (SUBSTRING(1,1,REFLECT(parameter(parameter2($facility),0))) = "L") CONCAT("Facilities: ",TRIM(facnamelist,3))
		ELSE CONCAT("Facilities: ",TRIM(facname,3)) ENDIF)
	prompts->rec_cnt = 1
 
WITH nocounter
 
/**************************************************************
; Unit Prompts
**************************************************************/
CALL ECHO ("Unit Prompt")
 
SELECT unit = CNVTSTRING(e.location_cd)
FROM location e
WHERE parser(facprompt)
AND e.location_type_cd IN (772 /*Ambulatory*/,794 /*Nurse Unit*/)
AND e.active_ind = 1
 
HEAD REPORT
	unitlist = FILLSTRING(2000,' ')
 	unitlist = '('
 
DETAIL
	unitlist = BUILD(BUILD(unitlist, unit), ', ')
 
FOOT REPORT
	unitlist = BUILD(unitlist,')')
	unitlist = REPLACE(unitlist,',','',2)
 
WITH nocounter
 
IF(SUBSTRING(1,1,REFLECT(PARAMETER(PARAMETER2($unit),0))) = "L")		;multiple options selected
	SET unitprompt = '('
	SET num = CNVTINT(SUBSTRING(2,2,REFLECT(PARAMETER(PARAMETER2($unit),0))))
 
	FOR (i = 1 TO num)
		SET unititem = CNVTSTRING(PARAMETER(PARAMETER2($unit),i))
		SET unitprompt = BUILD(unitprompt,unititem)
		IF (i != num)
			SET unitprompt = BUILD(unitprompt, ",")
		ENDIF
	ENDFOR
	SET unitprompt = BUILD(unitprompt, ")")
 	SET unitnameprmpt = CONCAT("e.location_cd IN ", unitprompt)
	SET unitprompt = CONCAT("e.loc_nurse_unit_cd IN ",unitprompt)
 
ELSEIF(PARAMETER(PARAMETER2($unit),1)=0.0)  ;any was selected
	SET unitprompt = CONCAT("e.loc_nurse_unit_cd IN ",unitlist)
 	SET unitnameprmpt = CONCAT("e.location_cd IN ", unitlist)
 
ELSE 	;single value selected
	SET unititem = CNVTSTRING(PARAMETER(PARAMETER2($unit),1))
	SET unitprompt = CONCAT("e.loc_nurse_unit_cd = ", unititem)
	SET unitnameprmpt = CONCAT("e.location_cd = ", unititem)
 
ENDIF
 
; Get Unit prompt data selected
SELECT unit = CNVTSTRING(e.location_cd),
unitname = UAR_GET_CODE_DISPLAY(e.location_cd)
FROM location e
WHERE parser(facprompt)
AND parser(unitnameprmpt)
AND e.location_type_cd IN (772 /*Ambulatory*/,794 /*Nurse Unit*/)
AND e.active_ind = 1
ORDER BY unitname
 
HEAD REPORT
	unitnamelist = FILLSTRING(2000,' ')
 
DETAIL
	unitnamelist = BUILD(BUILD(unitnamelist, unitname), ', ')
 
FOOT REPORT
	unitnamelist = REPLACE(unitnamelist,',','',2)
	prompts->p_unit = EVALUATE2(IF(PARAMETER(PARAMETER2($unit),1) = 0.0) "Nurse Units: All"
		ELSEIF (SUBSTRING(1,1,REFLECT(parameter(parameter2($unit),0))) = "L") CONCAT("Nurse Units: ",TRIM(unitnamelist,3))
		ELSE CONCAT("Nurse Unit: ",TRIM(unitname,3)) ENDIF)
 
WITH nocounter
 
/**************************************************************
; Test Name Prompt
**************************************************************/
CALL ECHO ("Test Name Prompt")
 
SELECT DISTINCT Test_Name = oc.primary_mnemonic
,CATALOG_CD = oc.catalog_cd
FROM order_catalog oc
WHERE oc.catalog_type_cd = 2513.00 /*Laboratory*/
AND oc.activity_type_cd IN (674.00 /*Blood Bank*/,692.00 /*General Lab*/,696.00 /*Micro*/)
AND oc.active_ind = 1
ORDER BY CNVTUPPER(oc.primary_mnemonic)
 
HEAD REPORT
	testlist = FILLSTRING(2000,' ')
 	testlist = '('
 
DETAIL
	testlist = BUILD(BUILD(testlist, catalog_cd), ', ')
 
FOOT REPORT
	testlist = BUILD(testlist,')')
	testlist = REPLACE(testlist,',','',2)
 
WITH nocounter
 
IF(SUBSTRING(1,1,REFLECT(PARAMETER(PARAMETER2($test),0))) = "L")		;multiple options selected
	SET testprompt = '('
	SET num = CNVTINT(SUBSTRING(2,2,REFLECT(PARAMETER(PARAMETER2($test),0))))
 
	FOR (i = 1 TO num)
		SET testitem = CNVTSTRING(PARAMETER(PARAMETER2($test),i))
		SET testprompt = BUILD(testprompt,testitem)
		IF (i != num)
			SET testprompt = BUILD(testprompt, ",")
		ENDIF
	ENDFOR
	SET testprompt = BUILD(testprompt, ")")
	SET testprompt = CONCAT("oc.catalog_cd IN ",testprompt)
 
ELSEIF(PARAMETER(PARAMETER2($test),1)=0)  ;any was selected
	SET testprompt = BUILD2('oc.catalog_cd > 0')
 
ELSE 	;single value selected
	SET testitem = CNVTSTRING(PARAMETER(PARAMETER2($test),1))
	SET testprompt = CONCAT("oc.catalog_cd = ", testitem)
ENDIF
 
; Get Test name prompt data selected
SELECT DISTINCT Test_Name = oc.primary_mnemonic
,CATALOG_CD = oc.catalog_cd
FROM order_catalog oc
WHERE oc.catalog_type_cd = 2513.00 /*Laboratory*/
AND oc.activity_type_cd IN (674.00 /*Blood Bank*/,692.00 /*General Lab*/,696.00 /*Micro*/)
AND oc.active_ind = 1
AND parser(testprompt)
ORDER BY CNVTUPPER(oc.primary_mnemonic)
 
HEAD REPORT
	testamelist = FILLSTRING(2000,' ')
 
DETAIL
	testnamelist = BUILD(BUILD(testnamelist, test_name), ', ')
 
FOOT REPORT
	testnamelist = REPLACE(testnamelist,',','',2)
	IF (PARAMETER(PARAMETER2($test),1) = 0)
		prompts->p_test = "Tests: All"
	ELSEIF (SUBSTRING(1,1,REFLECT(PARAMETER(PARAMETER2($test),0))) = "L")
		prompts->p_test = CONCAT("Tests: ",TRIM(testnamelist,3))
	ELSE prompts->p_test = CONCAT("Test: ",TRIM(test_name,3))
	ENDIF
 
WITH nocounter
 
/**************************************************************
; Container Type Prompt
**************************************************************/
CALL ECHO ("Container Type Prompt")
 
SELECT containertypenum = CNVTSTRING(CV1.CODE_VALUE)
FROM CODE_VALUE CV1
WHERE CV1.CODE_SET =  2051
AND CV1.ACTIVE_IND = 1
AND CV1.CODE_VALUE NOT IN (2644873053 /*Blank*/)
 
HEAD REPORT
	containertypelist = FILLSTRING(2000,' ')
 	containertypelist = '('
 
DETAIL
	containertypelist = BUILD(BUILD(containertypelist, containertypenum), ', ')
 
FOOT REPORT
	containertypelist = BUILD(containertypelist,')')
	containertypelist = REPLACE(containertypelist,',','',2)
 
WITH nocounter
 
IF(SUBSTRING(1,1,REFLECT(PARAMETER(PARAMETER2($containertype),0))) = "L")		;multiple options selected
	SET containertypeprompt = '('
	SET num = CNVTINT(SUBSTRING(2,2,REFLECT(PARAMETER(PARAMETER2($containertype),0))))
 
	FOR (i = 1 TO num)
		SET containertypeitem = CNVTSTRING(PARAMETER(PARAMETER2($containertype),i))
		SET containertypeprompt = BUILD(containertypeprompt,containertypeitem)
		IF (i != num)
			SET containertypeprompt = BUILD(containertypeprompt, ",")
		ENDIF
	ENDFOR
	SET containertypeprompt = BUILD(containertypeprompt, ")")
	SET containertypenameprmpt = CONCAT("cv.code_value IN ", containertypeprompt)
	SET containertypeprompt = CONCAT("c.spec_cntnr_cd IN ",containertypeprompt)
 
ELSEIF(PARAMETER(PARAMETER2($containertype),1) = 0)  ;any was selected
	SET containertypeprompt = CONCAT("c.spec_cntnr_cd IN ", containertypelist)
	SET containertypenameprmpt = CONCAT("cv.code_value IN ", containertypelist)
ELSE 	;single value selected
	SET containertypeitem = CNVTSTRING(PARAMETER(PARAMETER2($containertype),1))
	SET containertypeprompt = BUILD("c.spec_cntnr_cd = ", containertypeitem)
	SET containertypenameprmpt = CONCAT("cv.code_value = ", containertypeitem)
ENDIF
 
; Get Container Type name prompt data selected
SELECT containertype = UAR_GET_CODE_DISPLAY(cv.code_value)
FROM code_value cv
WHERE cv.code_set = 2051
AND cv.active_ind = 1
AND parser(containertypenameprmpt)
ORDER BY containertype
 
HEAD REPORT
	containertypenamelist = FILLSTRING(2000,' ')
 
DETAIL
	containertypenamelist = BUILD(BUILD(containertypenamelist, containertype), ', ')
 
FOOT REPORT
	containertypenamelist = REPLACE(containertypenamelist,',','',2)
 
	IF (PARAMETER(PARAMETER2($containertype),1) = 0)
		prompts->p_container_type = "Container Types: All"
	ELSEIF (SUBSTRING(1,1,REFLECT(parameter(parameter2($containertype),0))) = "L")
		prompts->p_container_type = CONCAT("Container Types: ",TRIM(containertypenamelist,3))
	ELSE prompts->p_container_type = CONCAT("Container Type: ",TRIM(containertype,3))
	ENDIF
WITH nocounter
 
/**************************************************************
; Provider Prompt
**************************************************************/
CALL ECHO("Provider Prompt")
 
IF(SUBSTRING(1,1,REFLECT(PARAMETER(PARAMETER2($PROV),0))) = "L")		;multiple options selected
	SET provprompt = '('
	SET num = CNVTINT(SUBSTRING(2,2,REFLECT(PARAMETER(PARAMETER2($PROV),0))))
 
	FOR (i = 1 TO num)
		SET provitem = CNVTSTRING(PARAMETER(PARAMETER2($PROV),i))
		SET provprompt = BUILD(provprompt,provitem)
		IF (i != num)
			SET provprompt = BUILD(provprompt, ",")
		ENDIF
	ENDFOR
	SET provprompt = BUILD(provprompt, ")")
	SET provnameprmpt = BUILD("pr.person_id IN ",provprompt)
	SET provprompt = BUILD("oa.order_provider_id IN ",provprompt)
 
 
ELSEIF(PARAMETER(PARAMETER2($PROV),1)=0.0)  ;any was selected
	SET provprompt = BUILD("oa.order_provider_id > 0")
	SET provnameprmpt = BUILD("pr.person_id > 0")
ELSE 	;single value selected
	SET provitem = CNVTSTRING(PARAMETER(PARAMETER2($PROV),1))
	SET provprompt = BUILD("oa.order_provider_id = ", provitem)
	SET provnameprmpt = BUILD("pr.person_id = ", provitem)
ENDIF
 
; Get Provider name prompt data selected
SELECT PROVIDER = pr.name_full_formatted
    ,PROV_ID = pr.person_id
FROM PRSNL   pr
WHERE pr.physician_ind = 1
AND pr.active_ind = 1
AND pr.end_effective_dt_tm >= CNVTDATETIME(CURDATE,CURTIME3)
AND pr.position_cd !=  242360261.00 /*View Only*/
AND pr.data_status_cd = 25.00 /*Auth*/
AND parser(provnameprmpt)
ORDER BY pr.name_last_key, pr.name_first_key
 
HEAD REPORT
	provnamelist = FILLSTRING(2000,' ')
 
DETAIL
	provnamelist = BUILD(BUILD(provnamelist, provider), ', ')
 
FOOT REPORT
	provnamelist = REPLACE(provnamelist,',','',2)
 
	IF (PARAMETER(PARAMETER2($prov),1) = 0)
		prompts->p_order_prov = "Providers: All"
	ELSEIF (SUBSTRING(1,1,REFLECT(parameter(parameter2($PROV),0))) = "L")
		prompts->p_order_prov = CONCAT("Providers: ",TRIM(provnamelist,3))
	ELSE prompts->p_order_prov = CONCAT("Provider: ",TRIM(provider,3))
	ENDIF
 
WITH nocounter
 
/**************************************************************
; Consulting Provider Prompt
**************************************************************/
CALL ECHO("Consulting Provider Prompt")
 
IF(SUBSTRING(1,1,REFLECT(PARAMETER(PARAMETER2($consultprov),0))) = "L")		;multiple options selected
	SET consultprovprompt = '('
	SET num = CNVTINT(SUBSTRING(2,2,REFLECT(PARAMETER(PARAMETER2($consultprov),0))))
 
	FOR (i = 1 TO num)
		SET consultprovitem = CNVTSTRING(PARAMETER(PARAMETER2($consultprov),i))
		SET consultprovprompt = BUILD(consultprovprompt,consultprovitem)
		IF (i != num)
			SET consultprovprompt = BUILD(consultprovprompt, ",")
		ENDIF
	ENDFOR
	SET consultprovprompt = BUILD(consultprovprompt, ")")
	SET consultprovnameprmpt = BUILD("pr.person_id IN ",consultprovprompt)
	SET consultprovprompt = BUILD("consultprov.person_id IN ",consultprovprompt)
ELSEIF(PARAMETER(PARAMETER2($consultprov),1)=0)  ;any was selected
	SET consultprovprompt = BUILD("consultprov.person_id > 0 OR NULLIND(consultprov.person_id) = 1")
	SET consultprovnameprmpt = BUILD("pr.person_id > 0")
ELSE 	;single value selected
	SET consultprovitem = CNVTSTRING(PARAMETER(PARAMETER2($consultprov),1))
	SET consultprovprompt = BUILD("consultprov.person_id = ", consultprovitem)
	SET consultprovnameprmpt = BUILD("pr.person_id = ", consultprovitem)
ENDIF
 
; Get Consulting Provider name prompt data selected
SELECT PROVIDER = pr.name_full_formatted
    ,PROV_ID = pr.person_id
FROM PRSNL   pr
WHERE pr.physician_ind = 1
AND pr.active_ind = 1
AND pr.end_effective_dt_tm >= CNVTDATETIME(CURDATE,CURTIME3)
AND pr.position_cd !=  242360261.00 /*View Only*/
AND pr.data_status_cd = 25.00 /*Auth*/
AND parser(consultprovnameprmpt)
ORDER BY pr.name_last_key, pr.name_first_key
 
HEAD REPORT
	consultprovnamelist = FILLSTRING(2000,' ')
 
DETAIL
	consultprovnamelist = BUILD(BUILD(consultprovnamelist, provider), ', ')
 
FOOT REPORT
	consultprovnamelist = REPLACE(consultprovnamelist,',','',2)
 
	IF (PARAMETER(PARAMETER2($consultprov),1) = 0)
		prompts->p_consult_prov = "Providers: All"
	ELSEIF (SUBSTRING(1,1,REFLECT(parameter(parameter2($consultprov),0))) = "L")
		prompts->p_order_prov = CONCAT("Providers: ",TRIM(consultprovnamelist,3))
	ELSE prompts->p_consult_prov = CONCAT("Provider: ",TRIM(provider,3))
	ENDIF
 
WITH nocounter
 
/**************************************************************
; Enc Type Prompt
**************************************************************/
CALL ECHO ("Enc Type Prompt")
 
SELECT enctypenum = CNVTSTRING(CV1.CODE_VALUE)
FROM CODE_VALUE CV1
WHERE CV1.CODE_SET =  71
AND CV1.ACTIVE_IND = 1
 
HEAD REPORT
	enctypelist = FILLSTRING(2000,' ')
 	enctypelist = '('
 
DETAIL
	enctypelist = BUILD(BUILD(enctypelist, enctypenum), ', ')
 
FOOT REPORT
	enctypelist = BUILD(enctypelist,')')
	enctypelist = REPLACE(enctypelist,',','',2)
 
WITH nocounter
 
IF(SUBSTRING(1,1,REFLECT(PARAMETER(PARAMETER2($enctype),0))) = "L")		;multiple options selected
	SET enctypeprompt = '('
	SET num = CNVTINT(SUBSTRING(2,2,REFLECT(PARAMETER(PARAMETER2($enctype),0))))
 
	FOR (i = 1 TO num)
		SET enctypeitem = CNVTSTRING(PARAMETER(PARAMETER2($enctype),i))
		SET enctypeprompt = BUILD(enctypeprompt,enctypeitem)
		IF (i != num)
			SET enctypeprompt = BUILD(enctypeprompt, ",")
		ENDIF
	ENDFOR
	SET enctypeprompt = BUILD(enctypeprompt, ")")
	SET enctypenameprmpt = CONCAT("cv.code_value IN ", enctypeprompt)
	SET enctypeprompt = CONCAT("e.encntr_type_cd IN ",enctypeprompt)
 
ELSEIF(PARAMETER(PARAMETER2($enctype),1) = 0)  ;any was selected
	SET enctypeprompt = CONCAT("e.encntr_type_cd IN ",enctypelist)
	SET enctypenameprmpt = CONCAT("cv.code_value IN ", enctypelist)
 
ELSE 	;single value selected
	SET enctypeitem = CNVTSTRING(PARAMETER(PARAMETER2($enctype),1))
	SET enctypeprompt = BUILD("e.encntr_type_cd = ", enctypeitem)
	SET enctypenameprmpt = CONCAT("cv.code_value = ", enctypeitem)
ENDIF
 
 
; Get Enc Type name prompt data selected
SELECT enctype = UAR_GET_CODE_DISPLAY(cv.code_value),
    cv.code_value
FROM code_value cv
WHERE cv.code_set = 71
AND cv.active_ind = 1
AND parser(enctypenameprmpt)
ORDER BY enctype
 
HEAD REPORT
	enctypenamelist = FILLSTRING(2000,' ')
 
DETAIL
	enctypenamelist = BUILD(BUILD(enctypenamelist, enctype), ', ')
 
FOOT REPORT
	enctypenamelist = REPLACE(enctypenamelist,',','',2)
 
	IF (PARAMETER(PARAMETER2($enctype),1) = 0)
		prompts->p_enctype = "Enc Types: All"
	ELSEIF (SUBSTRING(1,1,REFLECT(parameter(parameter2($enctype),0))) = "L")
		prompts->p_enctype = CONCAT("Enc Types: ",TRIM(enctypenamelist,3))
	ELSE prompts->p_enctype = CONCAT("Enc Type: ",TRIM(Enctype,3))
	ENDIF
 
WITH nocounter
 
/**************************************************************
; Other Prompts
**************************************************************/
 
SELECT INTO "NL:"
FROM DUMMYT d
 
HEAD REPORT
	prompts->p_bdate = CONCAT("Begin: ", FORMAT(CNVTDATE2($bdate, "dd-mmm-yyyy hh:mm:ss"), "MM/DD/YYYY;;d"), " 00:00")
	prompts->p_edate = CONCAT("End: ", FORMAT(CNVTDATE2($edate, "dd-mmm-yyyy hh:mm:ss"), "MM/DD/YYYY;;d"), " 23:59")
	prompts->p_sumdet = CONCAT("Type: ", EVALUATE(CNVTSTRING($sumdet), "0", "Summary", "1", "Detail"))
WITH nocounter
 
 
/**************************************************************
; Order Data
**************************************************************/
CALL ECHO ("Orders Data")
 
SELECT INTO 'nl:'
FROM order_catalog oc
	,(INNER JOIN orders o ON (oc.catalog_cd = o.catalog_cd
		AND o.activity_type_cd IN (692 /*Gen Lab*/, 674 /*Blood Bank*/, 696 /*Micro*/)
		AND o.dept_status_cd IN (9312 /*Completed*/, 9329 /*Preliminary*/, 9321 /*Final*/)
		AND o.orig_order_dt_tm BETWEEN CNVTDATETIME($bdate)
			AND CNVTDATETIME($edate)
		))
	,(INNER JOIN order_action oa ON (o.order_id = oa.order_id
		AND oa.action_type_cd = 2534.00 /*order*/
		AND parser(provprompt)
		))
	,(INNER JOIN prsnl ord_prov ON (oa.order_provider_id = ord_prov.person_id
		))
	,(INNER JOIN encounter e ON (o.encntr_id = e.encntr_id
		AND parser(facprompt)
		AND parser(unitprompt)
		AND parser(enctypeprompt)
		AND e.active_ind = 1
		))
	,(INNER JOIN encntr_alias fin ON (e.encntr_id = fin.encntr_id
		AND fin.encntr_alias_type_cd = 1077 /*Fin*/
		))
	,(INNER JOIN person pat ON (e.person_id = pat.person_id
		AND pat.active_ind = 1
		))
	,(LEFT JOIN accession_order_r aor ON (o.order_id = aor.order_id
		AND aor.primary_flag = 0
		))
	,(LEFT JOIN order_container_r ocr ON (o.order_id = ocr.order_id
		))
	,(LEFT JOIN container c ON (ocr.container_id = c.container_id
		AND parser(containertypeprompt)
		))
	,(LEFT JOIN order_detail od ON (o.order_id = od.order_id
		AND od.oe_field_id =  12581.00 /*Consulting Physician*/
		))
	,(LEFT JOIN prsnl consultprov ON (od.oe_field_value = consultprov.person_id
		AND consultprov.physician_ind = 1
		))
WHERE parser(testprompt)
AND parser(consultprovprompt)
ORDER BY TRIM(UAR_GET_CODE_DISPLAY(e.loc_facility_cd),3),TRIM(ord_prov.name_full_formatted,3),
TRIM(UAR_GET_CODE_DISPLAY(o.catalog_cd),3)
 
HEAD REPORT
	cnt = 0
 
HEAD o.order_id
	cnt = cnt + 1
 
	IF (mod(cnt,10) = 1 OR cnt = 1)
		stat = alterlist(a->qual, cnt + 9)
 	ENDIF
 
	a->qual[cnt].orderid 	= 	o.order_id
	a->qual[cnt].orderdate	= 	TRIM(FORMAT(o.orig_order_dt_tm, "mm/dd/yyyy hh:mm;;q"),3)
	a->qual[cnt].ordername	= 	TRIM(UAR_GET_CODE_DISPLAY(o.catalog_cd),3)
	a->qual[cnt].catalogcd  =   o.catalog_cd
	a->qual[cnt].ordering_prov = TRIM(ord_prov.name_full_formatted,3)
	a->qual[cnt].consulting_prov = EVALUATE2(IF (consultprov.person_id = 0) "<No Consulting Provider>"
			ELSE TRIM(consultprov.name_full_formatted,3) ENDIF)
	a->qual[cnt].personid	=	pat.person_id
	a->qual[cnt].encntrid	=	e.encntr_id
	a->qual[cnt].fin		= 	TRIM(fin.alias,3)
	a->qual[cnt].enctype    =   TRIM(UAR_GET_CODE_DISPLAY(e.encntr_type_cd),3)
	a->qual[cnt].name		=	TRIM(pat.name_full_formatted,3)
	a->qual[cnt].facility 	=	TRIM(UAR_GET_CODE_DISPLAY(e.loc_facility_cd),3)
	a->qual[cnt].loc		=	TRIM(CONCAT(TRIM(UAR_GET_CODE_DISPLAY(e.loc_nurse_unit_cd),3), ' ',
	TRIM(UAR_GET_CODE_DISPLAY(e.loc_room_cd),3), ' ', TRIM(UAR_GET_CODE_DISPLAY(e.loc_bed_cd),3)),3)
	a->qual[cnt].accnbr 	=	TRIM(CNVTACC(aor.accession),3)
 
FOOT REPORT
 	a->rec_cnt = cnt
 	CALL alterlist(a->qual, cnt)
 
WITH nocounter
 
IF (a->rec_cnt > 0)	; If no data skip to end
	/**************************************************************
	; Order Lab Data
	**************************************************************/
	CALL ECHO ("Order Lab Data")
 
	SELECT INTO 'nl:'
	FROM (dummyt d WITH seq = VALUE(SIZE(a->qual,5)))
	,order_container_r ocr
	,container c
	,collection_list cl
	,order_serv_res_container osrc
	,code_value_extension cve
	PLAN d
	JOIN ocr WHERE (a->qual[d.seq].orderid = ocr.order_id
		AND a->qual[d.seq].catalogcd = ocr.catalog_cd
		AND ocr.collection_status_flag NOT IN (7))
	JOIN c WHERE (ocr.container_id = c.container_id
		AND c.parent_container_id = 0)
	JOIN cl WHERE (c.collection_list_id = cl.collection_list_id)
	JOIN osrc WHERE (ocr.order_id = osrc.order_id
		AND c.container_id = osrc.container_id)
	JOIN cve WHERE ((osrc.current_location_cd = cve.code_value
		OR osrc.location_cd = cve.code_value)
		AND cve.field_name = 'Lab Reporting'
		AND cve.code_set = 220)
 
	HEAD ocr.order_id
		cnt = 0
		idx = 0
		idx = LOCATEVAL(cnt,1,SIZE(a->qual,5),ocr.order_id, a->qual[cnt].orderid)
 
	FOOT ocr.order_id
		a->qual[idx].containerid = c.container_id
		a->qual[idx].container_type = TRIM(UAR_GET_CODE_DISPLAY(c.spec_cntnr_cd),3)
		a->qual[idx].ordlab = TRIM(cve.field_value,3)
 
	WITH nocounter
 
	/**************************************************************
	; Performed Lab Data
	**************************************************************/
	CALL ECHO ("Performed Lab Data")
 
	SELECT INTO 'nl:'
	FROM (dummyt d WITH seq = VALUE(SIZE(a->qual,5)))
	, result r
	, perform_result pr
	, service_resource sr
	PLAN d
	JOIN r WHERE (a->qual[d.seq].orderid = r.order_id
		AND a->qual[d.seq].catalogcd = r.catalog_cd)
	JOIN pr WHERE (r.result_id = pr.result_id)
	JOIN sr WHERE (pr.service_resource_cd = sr.service_resource_cd)
 
	HEAD r.order_id
		cnt = 0
		idx = 0
		idx = LOCATEVAL(cnt,1,SIZE(a->qual,5),r.order_id, a->qual[cnt].orderid)
 
	FOOT r.order_id
		a->qual[idx].perfdttm = TRIM(FORMAT(pr.perform_dt_tm, "mm/dd/yyyy hh:mm;;q"),3)
		a->qual[idx].perflab = TRIM(UAR_GET_CODE_DISPLAY(sr.location_cd),3)
		a->qual[idx].instrument = TRIM(UAR_GET_CODE_DISPLAY(pr.service_resource_cd),3)
 
	WITH nocounter
 
	/**************************************************************
	; Totals Data
	**************************************************************/
 
	/**************************************************************
	; Instrument Totals
	**************************************************************/
	CALL ECHO ("Instrument Totals ")
 
	SELECT DISTINCT INTO 'nl:'
	Facility = a->qual[d.seq].facility
	,Ordering_Provider = a->qual[d.seq].ordering_prov
	,Consulting_Provider = a->qual[d.seq].consulting_prov
	,Order_Name = a->qual[d.seq].ordername
	,Container_Type = a->qual[d.seq].container_type
	,Order_Lab = a->qual[d.seq].ordlab
	,Performed_Lab = a->qual[d.seq].perflab
	,Instrument = a->qual[d.seq].instrument
	FROM (dummyt d WITH seq = VALUE(SIZE(a->qual,5)))
	PLAN d
	ORDER BY Facility, Ordering_Provider, Consulting_Provider, Order_Name, Container_Type,
		Order_Lab, Performed_Lab, Instrument
 
	HEAD REPORT
		cnt = 0
	 	totalscnt = 0
	 	newreccnt = 0
 
	DETAIL
		cnt = cnt + 1
 
		stat = alterlist(totals->qual, cnt)
 
		totals->qual[cnt].facility = facility
		totals->qual[cnt].ordering_prov	= Ordering_Provider
		totals->qual[cnt].consulting_prov = Consulting_Provider
		totals->qual[cnt].ordername	= Order_Name
		totals->qual[cnt].container_type = Container_Type
		totals->qual[cnt].ordlab = Order_Lab
		totals->qual[cnt].perflab = Performed_Lab
		totals->qual[cnt].instrument = Instrument
 
	FOOT REPORT
	 	totals->rec_cnt = cnt
		totals->new_rec_cnt = cnt + 1
	 	CALL alterlist(totals->qual, cnt)
 
	 	fac1 = fillstring(50,' ')
		fac2 = fillstring(50,' ')
		ordprov1 = fillstring(50,' ')
		ordprov2 = fillstring(50,' ')
		consultprov1 = fillstring(50,' ')
		consultprov2 = fillstring(50,' ')
		ord1 = fillstring(50,' ')
		ord2 = fillstring(50,' ')
		container1 = fillstring(50,' ')
		container12 = fillstring(50,' ')
		ordlab1 = fillstring(50,' ')
		ordlab2 = fillstring(50,' ')
		perflab1 = fillstring(50,' ')
		perflab2 = fillstring(50,' ')
		inst1 = fillstring(50,' ')
		inst2 = fillstring(50,' ')
 
		FOR (tcnt = 1 TO totals->rec_cnt)
			FOR (scnt = 1 TO a->rec_cnt)
				fac1 = TRIM(totals->qual[tcnt].facility,3)
				ordprov1 = TRIM(totals->qual[tcnt].ordering_prov,3)
				consultprov1 = TRIM(totals->qual[tcnt].consulting_prov,3)
				ord1 = TRIM(totals->qual[tcnt].ordername,3)
				container1 = TRIM(totals->qual[tcnt].container_type,3)
				ordlab1 = TRIM(totals->qual[tcnt].ordlab,3)
				perflab1 = TRIM(totals->qual[tcnt].perflab,3)
				inst1 = TRIM(totals->qual[tcnt].instrument,3)
 
				fac2 = TRIM(a->qual[scnt].facility,3)
				ordprov2 = TRIM(a->qual[scnt].ordering_prov,3)
				consultprov2 = TRIM(a->qual[scnt].consulting_prov,3)
				ord2 = TRIM(a->qual[scnt].ordername,3)
				container2 = TRIM(a->qual[scnt].container_type,3)
				ordlab2 = TRIM(a->qual[scnt].ordlab,3)
				perflab2 = TRIM(a->qual[scnt].perflab,3)
				inst2 = TRIM(a->qual[scnt].instrument,3)
 
				IF (fac1 = fac2 AND ordprov1 = ordprov2 AND consultprov1 = consultprov2
					AND ord1 = ord2	AND container1 = container2
					AND ordlab1 = ordlab2 AND perflab1 = perflab2
					AND inst1 = inst2)
					totals->qual[tcnt].ordcnt = totals->qual[tcnt].ordcnt + 1
				ENDIF
			ENDFOR
		ENDFOR
 
		totals->totaltestcnt = a->rec_cnt
		totals->new_rec_cnt = totals->rec_cnt
	WITH nocounter
 
	/**************************************************************
	; Performed Lab Totals
	**************************************************************/
	CALL ECHO ("Performed Lab Totals")
 
	SELECT DISTINCT INTO 'nl:'
	Facility = a->qual[d.seq].facility
	,Ordering_Provider = a->qual[d.seq].ordering_prov
	,Consulting_Provider = a->qual[d.seq].consulting_prov
	,Order_Name = a->qual[d.seq].ordername
	,Container_Type = a->qual[d.seq].container_type
	,Order_Lab = a->qual[d.seq].ordlab
	,Performed_Lab = a->qual[d.seq].perflab
	FROM (dummyt d WITH seq = VALUE(SIZE(a->qual,5)))
	PLAN d
	ORDER BY Facility, Ordering_Provider, Consulting_Provider, Order_Name, Container_Type,
		Order_Lab, Performed_Lab
 
	HEAD REPORT
		cnt = totals->rec_cnt
 
	DETAIL
		cnt = cnt + 1
 
		stat = alterlist(totals->qual, cnt)
 
		totals->qual[cnt].facility = facility
		totals->qual[cnt].ordering_prov	= Ordering_Provider
		totals->qual[cnt].consulting_prov = Consulting_Provider
		totals->qual[cnt].ordername	= Order_Name
		totals->qual[cnt].container_type = Container_Type
		totals->qual[cnt].ordlab = Order_Lab
		totals->qual[cnt].perflab = Performed_Lab
		totals->qual[cnt].instrument = "z Totals"
 
	FOOT REPORT
	 	totals->rec_cnt = cnt
		newreccnt = totals->new_rec_cnt + 1
	 	CALL alterlist(totals->qual, cnt)
 
	 	fac1 = fillstring(50,' ')
		fac2 = fillstring(50,' ')
		ordprov1 = fillstring(50,' ')
		ordprov2 = fillstring(50,' ')
		consultprov1 = fillstring(50,' ')
		consultprov2 = fillstring(50,' ')
		ord1 = fillstring(50,' ')
		ord2 = fillstring(50,' ')
		container1 = fillstring(50,' ')
		container12 = fillstring(50,' ')
		ordlab1 = fillstring(50,' ')
		ordlab2 = fillstring(50,' ')
		perflab1 = fillstring(50,' ')
		perflab2 = fillstring(50,' ')
 
		FOR (tcnt = newreccnt TO totals->rec_cnt)
			FOR (scnt = 1 TO a->rec_cnt)
				fac1 = TRIM(totals->qual[tcnt].facility,3)
				ordprov1 = TRIM(totals->qual[tcnt].ordering_prov,3)
				consultprov1 = TRIM(totals->qual[tcnt].consulting_prov,3)
				ord1 = TRIM(totals->qual[tcnt].ordername,3)
				container1 = TRIM(totals->qual[tcnt].container_type,3)
				ordlab1 = TRIM(totals->qual[tcnt].ordlab,3)
				perflab1 = TRIM(totals->qual[tcnt].perflab,3)
 
				fac2 = TRIM(a->qual[scnt].facility,3)
				ordprov2 = TRIM(a->qual[scnt].ordering_prov,3)
				consultprov2 = TRIM(a->qual[scnt].consulting_prov,3)
				ord2 = TRIM(a->qual[scnt].ordername,3)
				container2 = TRIM(a->qual[scnt].container_type,3)
				ordlab2 = TRIM(a->qual[scnt].ordlab,3)
				perflab2 = TRIM(a->qual[scnt].perflab,3)
 
				IF (fac1 = fac2 AND ordprov1 = ordprov2 AND consultprov1 = consultprov2
					AND ord1 = ord2	AND container1 = container2
					AND ordlab1 = ordlab2 AND perflab1 = perflab2)
					totals->qual[tcnt].ordcnt = totals->qual[tcnt].ordcnt + 1
				ENDIF
			ENDFOR
		ENDFOR
 
		totals->new_rec_cnt = totals->rec_cnt
	WITH nocounter
 
	/**************************************************************
	; Ordering Lab Totals
	**************************************************************/
	CALL ECHO ("Ordering Lab Totals")
 
	SELECT DISTINCT INTO 'nl:'
	Facility = a->qual[d.seq].facility
	,Ordering_Provider = a->qual[d.seq].ordering_prov
	,Consulting_Provider = a->qual[d.seq].consulting_prov
	,Order_Name = a->qual[d.seq].ordername
	,Container_Type = a->qual[d.seq].container_type
	,Order_Lab = a->qual[d.seq].ordlab
	FROM (dummyt d WITH seq = VALUE(SIZE(a->qual,5)))
	PLAN d
	ORDER BY Facility, Ordering_Provider, Consulting_Provider, Order_Name, Container_Type,
		Order_Lab
 
	HEAD REPORT
		cnt = totals->rec_cnt
 
	DETAIL
		cnt = cnt + 1
 
		stat = alterlist(totals->qual, cnt)
 
		totals->qual[cnt].facility = facility
		totals->qual[cnt].ordering_prov	= Ordering_Provider
		totals->qual[cnt].consulting_prov = Consulting_Provider
		totals->qual[cnt].ordername	= Order_Name
		totals->qual[cnt].container_type = Container_Type
		totals->qual[cnt].ordlab = Order_Lab
		totals->qual[cnt].perflab = "z Totals"
		totals->qual[cnt].instrument = "z Totals"
 
	FOOT REPORT
	 	totals->rec_cnt = cnt
		newreccnt = totals->new_rec_cnt + 1
	 	CALL alterlist(totals->qual, cnt)
 
	 	fac1 = fillstring(50,' ')
		fac2 = fillstring(50,' ')
		ordprov1 = fillstring(50,' ')
		ordprov2 = fillstring(50,' ')
		consultprov1 = fillstring(50,' ')
		consultprov2 = fillstring(50,' ')
		ord1 = fillstring(50,' ')
		ord2 = fillstring(50,' ')
		container1 = fillstring(50,' ')
		container12 = fillstring(50,' ')
		ordlab1 = fillstring(50,' ')
		ordlab2 = fillstring(50,' ')
 
		FOR (tcnt = newreccnt TO totals->rec_cnt)
			FOR (scnt = 1 TO a->rec_cnt)
				fac1 = TRIM(totals->qual[tcnt].facility,3)
				ordprov1 = TRIM(totals->qual[tcnt].ordering_prov,3)
				consultprov1 = TRIM(totals->qual[tcnt].consulting_prov,3)
				ord1 = TRIM(totals->qual[tcnt].ordername,3)
				container1 = TRIM(totals->qual[tcnt].container_type,3)
				ordlab1 = TRIM(totals->qual[tcnt].ordlab,3)
 
				fac2 = TRIM(a->qual[scnt].facility,3)
				ordprov2 = TRIM(a->qual[scnt].ordering_prov,3)
				consultprov2 = TRIM(a->qual[scnt].consulting_prov,3)
				ord2 = TRIM(a->qual[scnt].ordername,3)
				container2 = TRIM(a->qual[scnt].container_type,3)
				ordlab2 = TRIM(a->qual[scnt].ordlab,3)
 
				IF (fac1 = fac2 AND ordprov1 = ordprov2 AND consultprov1 = consultprov2
					AND ord1 = ord2	AND container1 = container2
					AND ordlab1 = ordlab2)
					totals->qual[tcnt].ordcnt = totals->qual[tcnt].ordcnt + 1
				ENDIF
			ENDFOR
		ENDFOR
 
		totals->new_rec_cnt = totals->rec_cnt
	WITH nocounter
 
	/**************************************************************
	; Container Type Totals
	**************************************************************/
	CALL ECHO ("Container Type Totals")
 
	SELECT DISTINCT INTO 'nl:'
	Facility = a->qual[d.seq].facility
	,Ordering_Provider = a->qual[d.seq].ordering_prov
	,Consulting_Provider = a->qual[d.seq].consulting_prov
	,Order_Name = a->qual[d.seq].ordername
	,Container_Type = a->qual[d.seq].container_type
	FROM (dummyt d WITH seq = VALUE(SIZE(a->qual,5)))
	PLAN d
	ORDER BY Facility, Ordering_Provider, Consulting_Provider, Order_Name, Container_Type
 
	HEAD REPORT
		cnt = totals->rec_cnt
 
	DETAIL
		cnt = cnt + 1
 
		stat = alterlist(totals->qual, cnt)
 
		totals->qual[cnt].facility = facility
		totals->qual[cnt].ordering_prov	= Ordering_Provider
		totals->qual[cnt].consulting_prov = Consulting_Provider
		totals->qual[cnt].ordername	= Order_Name
		totals->qual[cnt].container_type = Container_Type
		totals->qual[cnt].ordlab = "z Totals"
		totals->qual[cnt].perflab = "z Totals"
		totals->qual[cnt].instrument = "z Totals"
 
	FOOT REPORT
	 	totals->rec_cnt = cnt
		newreccnt = totals->new_rec_cnt + 1
	 	CALL alterlist(totals->qual, cnt)
 
	 	fac1 = fillstring(50,' ')
		fac2 = fillstring(50,' ')
		ordprov1 = fillstring(50,' ')
		ordprov2 = fillstring(50,' ')
		consultprov1 = fillstring(50,' ')
		consultprov2 = fillstring(50,' ')
		ord1 = fillstring(50,' ')
		ord2 = fillstring(50,' ')
		container1 = fillstring(50,' ')
		container12 = fillstring(50,' ')
 
		FOR (tcnt = newreccnt TO totals->rec_cnt)
			FOR (scnt = 1 TO a->rec_cnt)
				fac1 = TRIM(totals->qual[tcnt].facility,3)
				ordprov1 = TRIM(totals->qual[tcnt].ordering_prov,3)
				consultprov1 = TRIM(totals->qual[tcnt].consulting_prov,3)
				ord1 = TRIM(totals->qual[tcnt].ordername,3)
				container1 = TRIM(totals->qual[tcnt].container_type,3)
 
				fac2 = TRIM(a->qual[scnt].facility,3)
				ordprov2 = TRIM(a->qual[scnt].ordering_prov,3)
				consultprov2 = TRIM(a->qual[scnt].consulting_prov,3)
				ord2 = TRIM(a->qual[scnt].ordername,3)
				container2 = TRIM(a->qual[scnt].container_type,3)
 
				IF (fac1 = fac2 AND ordprov1 = ordprov2 AND consultprov1 = consultprov2
					AND ord1 = ord2	AND container1 = container2)
					totals->qual[tcnt].ordcnt = totals->qual[tcnt].ordcnt + 1
				ENDIF
			ENDFOR
		ENDFOR
 
		totals->new_rec_cnt = totals->rec_cnt
	WITH nocounter
 
	/**************************************************************
	; Order Name Totals
	**************************************************************/
	CALL ECHO ("Order Name Totals")
 
	SELECT DISTINCT INTO 'nl:'
	Facility = a->qual[d.seq].facility
	,Ordering_Provider = a->qual[d.seq].ordering_prov
	,Consulting_Provider = a->qual[d.seq].consulting_prov
	,Order_Name = a->qual[d.seq].ordername
	FROM (dummyt d WITH seq = VALUE(SIZE(a->qual,5)))
	PLAN d
	ORDER BY Facility, Ordering_Provider, Consulting_Provider, Order_Name
 
	HEAD REPORT
		cnt = totals->rec_cnt
 
	DETAIL
		cnt = cnt + 1
 
		stat = alterlist(totals->qual, cnt)
 
		totals->qual[cnt].facility = facility
		totals->qual[cnt].ordering_prov	= Ordering_Provider
		totals->qual[cnt].consulting_prov = Consulting_Provider
		totals->qual[cnt].ordername	= Order_Name
		totals->qual[cnt].container_type = "z Totals"
		totals->qual[cnt].ordlab = "z Totals"
		totals->qual[cnt].perflab = "z Totals"
		totals->qual[cnt].instrument = "z Totals"
 
	FOOT REPORT
	 	totals->rec_cnt = cnt
		newreccnt = totals->new_rec_cnt + 1
	 	CALL alterlist(totals->qual, cnt)
 
	 	fac1 = fillstring(50,' ')
		fac2 = fillstring(50,' ')
		ordprov1 = fillstring(50,' ')
		ordprov2 = fillstring(50,' ')
		consultprov1 = fillstring(50,' ')
		consultprov2 = fillstring(50,' ')
		ord1 = fillstring(50,' ')
		ord2 = fillstring(50,' ')
 
		FOR (tcnt = newreccnt TO totals->rec_cnt)
			FOR (scnt = 1 TO a->rec_cnt)
				fac1 = TRIM(totals->qual[tcnt].facility,3)
				ordprov1 = TRIM(totals->qual[tcnt].ordering_prov,3)
				consultprov1 = TRIM(totals->qual[tcnt].consulting_prov,3)
				ord1 = TRIM(totals->qual[tcnt].ordername,3)
 
				fac2 = TRIM(a->qual[scnt].facility,3)
				ordprov2 = TRIM(a->qual[scnt].ordering_prov,3)
				consultprov2 = TRIM(a->qual[scnt].consulting_prov,3)
				ord2 = TRIM(a->qual[scnt].ordername,3)
 
				IF (fac1 = fac2 AND ordprov1 = ordprov2 AND consultprov1 = consultprov2
					AND ord1 = ord2)
					totals->qual[tcnt].ordcnt = totals->qual[tcnt].ordcnt + 1
				ENDIF
			ENDFOR
		ENDFOR
 
		totals->new_rec_cnt = totals->rec_cnt
	WITH nocounter
 
	/**************************************************************
	; Consulting Provider Totals
	**************************************************************/
	CALL ECHO ("Consulting Type Totals")
 
	SELECT DISTINCT INTO 'nl:'
	Facility = a->qual[d.seq].facility
	,Ordering_Provider = a->qual[d.seq].ordering_prov
	,Consulting_Provider = a->qual[d.seq].consulting_prov
	FROM (dummyt d WITH seq = VALUE(SIZE(a->qual,5)))
	PLAN d
	ORDER BY Facility, Ordering_Provider, Consulting_Provider
 
	HEAD REPORT
		cnt = totals->rec_cnt
 
	DETAIL
		cnt = cnt + 1
 
		stat = alterlist(totals->qual, cnt)
 
		totals->qual[cnt].facility = facility
		totals->qual[cnt].ordering_prov	= Ordering_Provider
		totals->qual[cnt].consulting_prov = Consulting_Provider
		totals->qual[cnt].ordername	= "z Totals"
		totals->qual[cnt].container_type = "z Totals"
		totals->qual[cnt].ordlab = "z Totals"
		totals->qual[cnt].perflab = "z Totals"
		totals->qual[cnt].instrument = "z Totals"
 
	FOOT REPORT
	 	totals->rec_cnt = cnt
		newreccnt = totals->new_rec_cnt + 1
	 	CALL alterlist(totals->qual, cnt)
 
	 	fac1 = fillstring(50,' ')
		fac2 = fillstring(50,' ')
		ordprov1 = fillstring(50,' ')
		ordprov2 = fillstring(50,' ')
		consultprov1 = fillstring(50,' ')
		consultprov2 = fillstring(50,' ')
 
		FOR (tcnt = newreccnt TO totals->rec_cnt)
			FOR (scnt = 1 TO a->rec_cnt)
				fac1 = TRIM(totals->qual[tcnt].facility,3)
				ordprov1 = TRIM(totals->qual[tcnt].ordering_prov,3)
				consultprov1 = TRIM(totals->qual[tcnt].consulting_prov,3)
 
				fac2 = TRIM(a->qual[scnt].facility,3)
				ordprov2 = TRIM(a->qual[scnt].ordering_prov,3)
				consultprov2 = TRIM(a->qual[scnt].consulting_prov,3)
 
				IF (fac1 = fac2 AND ordprov1 = ordprov2 AND consultprov1 = consultprov2)
					totals->qual[tcnt].ordcnt = totals->qual[tcnt].ordcnt + 1
				ENDIF
			ENDFOR
		ENDFOR
 
		totals->new_rec_cnt = totals->rec_cnt
	WITH nocounter
 
	/**************************************************************
	; Ordering Provider Totals
	**************************************************************/
	CALL ECHO ("Ordering Provider Totals")
 
	SELECT DISTINCT INTO 'nl:'
	Facility = a->qual[d.seq].facility
	,Ordering_Provider = a->qual[d.seq].ordering_prov
	FROM (dummyt d WITH seq = VALUE(SIZE(a->qual,5)))
	PLAN d
	ORDER BY Facility, Ordering_Provider
 
	HEAD REPORT
		cnt = totals->rec_cnt
 
	DETAIL
		cnt = cnt + 1
 
		stat = alterlist(totals->qual, cnt)
 
		totals->qual[cnt].facility = facility
		totals->qual[cnt].ordering_prov	= Ordering_Provider
		totals->qual[cnt].consulting_prov = "z Totals"
		totals->qual[cnt].ordername	= "z Totals"
		totals->qual[cnt].container_type = "z Totals"
		totals->qual[cnt].ordlab = "z Totals"
		totals->qual[cnt].perflab = "z Totals"
		totals->qual[cnt].instrument = "z Totals"
 
	FOOT REPORT
	 	totals->rec_cnt = cnt
		newreccnt = totals->new_rec_cnt + 1
	 	CALL alterlist(totals->qual, cnt)
 
	 	fac1 = fillstring(50,' ')
		fac2 = fillstring(50,' ')
		ordprov1 = fillstring(50,' ')
		ordprov2 = fillstring(50,' ')
 
		FOR (tcnt = newreccnt TO totals->rec_cnt)
			FOR (scnt = 1 TO a->rec_cnt)
				fac1 = TRIM(totals->qual[tcnt].facility,3)
				ordprov1 = TRIM(totals->qual[tcnt].ordering_prov,3)
 
				fac2 = TRIM(a->qual[scnt].facility,3)
				ordprov2 = TRIM(a->qual[scnt].ordering_prov,3)
 
				IF (fac1 = fac2 AND ordprov1 = ordprov2)
					totals->qual[tcnt].ordcnt = totals->qual[tcnt].ordcnt + 1
				ENDIF
			ENDFOR
		ENDFOR
 
		totals->new_rec_cnt = totals->rec_cnt
	WITH nocounter
 
 
	/**************************************************************
	; Facility Totals
	**************************************************************/
	CALL ECHO ("Facility Totals")
 
	SELECT DISTINCT INTO 'nl:'
	Facility = a->qual[d.seq].facility
	FROM (dummyt d WITH seq = VALUE(SIZE(a->qual,5)))
	PLAN d
	ORDER BY Facility
 
	HEAD REPORT
		cnt = totals->rec_cnt
 
	DETAIL
		cnt = cnt + 1
 
		stat = alterlist(totals->qual, cnt)
 
		totals->qual[cnt].facility = facility
		totals->qual[cnt].ordering_prov	= "z Totals"
		totals->qual[cnt].consulting_prov = "z Totals"
		totals->qual[cnt].ordername	= "z Totals"
		totals->qual[cnt].container_type = "z Totals"
		totals->qual[cnt].ordlab = "z Totals"
		totals->qual[cnt].perflab = "z Totals"
		totals->qual[cnt].instrument = "z Totals"
 
	FOOT REPORT
	 	totals->rec_cnt = cnt
		newreccnt = totals->new_rec_cnt + 1
	 	CALL alterlist(totals->qual, cnt)
 
	 	fac1 = fillstring(50,' ')
		fac2 = fillstring(50,' ')
 
		FOR (tcnt = newreccnt TO totals->rec_cnt)
			FOR (scnt = 1 TO a->rec_cnt)
				fac1 = TRIM(totals->qual[tcnt].facility,3)
 
				fac2 = TRIM(a->qual[scnt].facility,3)
 
				IF (fac1 = fac2)
					totals->qual[tcnt].ordcnt = totals->qual[tcnt].ordcnt + 1
				ENDIF
			ENDFOR
		ENDFOR
 
		totals->new_rec_cnt = totals->rec_cnt
	WITH nocounter
 
	/**************************************************************
	; Report Totals
	**************************************************************/
	CALL ECHO ("Report Totals")
 
	SELECT DISTINCT INTO 'nl:'
	Report_Totals = "Report Totals"
	FROM (dummyt d WITH seq = VALUE(SIZE(a->qual,5)))
	PLAN d
	ORDER BY Report_Totals
 
	HEAD REPORT
		cnt = totals->rec_cnt
 
	DETAIL
		cnt = cnt + 1
 		stat = alterlist(totals->qual, cnt)
 
		totals->qual[cnt].facility = "Report Totals"
		totals->qual[cnt].ordering_prov	= "z Totals"
		totals->qual[cnt].consulting_prov = "z Totals"
		totals->qual[cnt].ordername	= "z Totals"
		totals->qual[cnt].container_type = "z Totals"
		totals->qual[cnt].ordlab = "z Totals"
		totals->qual[cnt].perflab = "z Totals"
		totals->qual[cnt].instrument = "z Totals"
 
	FOOT REPORT
	 	totals->rec_cnt = cnt
		newreccnt = totals->new_rec_cnt + 1
	 	CALL alterlist(totals->qual, cnt)
 
		totals->qual[cnt].ordcnt = a->rec_cnt
 
		totals->new_rec_cnt = totals->rec_cnt
	WITH nocounter
 
 
ENDIF
/*********************************************************************
	Output Record Structure (Summary/Detail)
*********************************************************************/
CALL ECHO ("Displaying Data")
 
IF (a->rec_cnt > 0)
	IF($sumdet = 0)	;Summary
 
		SELECT INTO $outdev
			Facility = totals->qual[d.seq].facility,
			Ordering_Provider = totals->qual[d.seq].ordering_prov,
			Consulting_Provider = totals->qual[d.seq].consulting_prov,
			Order_Name = totals->qual[d.seq].ordername,
			Container_Type = totals->qual[d.seq].container_type,
			Ordering_Lab = totals->qual[d.seq].ordlab,
			Performed_Lab = totals->qual[d.seq].perflab,
			Instrument = totals->qual[d.seq].instrument,
			Order_Count = totals->qual[d.seq].ordcnt,
			Prompts = BUILD("Prompt Values: ",
						TRIM(prompts->p_facility,3), " | ",
						TRIM(prompts->p_unit,3), " | ",
						TRIM(prompts->p_test,3), " | ",
						TRIM(prompts->p_container_type,3), " | ",
						TRIM(prompts->p_order_prov,3), " | ",
						TRIM(prompts->p_consult_prov,3), " | ",
						TRIM(prompts->p_enctype,3), " | ",
						TRIM(prompts->p_bdate,3), " | ",
						TRIM(prompts->p_edate,3), " | ",
						TRIM(prompts->p_sumdet,3))
		FROM (dummyt d with seq = totals->rec_cnt)
		ORDER BY Facility, Ordering_Provider, Consulting_Provider, Order_Name, Container_Type,
			Ordering_Lab, Performed_Lab, Instrument
		WITH nocounter, format, separator = ' '
 
	ELSE	;detail
 
		SELECT INTO $outdev
			Facility = a->qual[d.seq].facility,
			Patient_Name = a->qual[d.seq].name,
			FIN = a->qual[d.seq].fin,
			Enc_Type = a->qual[d.seq].enctype,
			Order_ID = a->qual[d.seq].orderid,
			Accession_Nbr = a->qual[d.seq].accnbr,
			Current_Pt_Loc = a->qual[d.seq].loc,
			Consulting_Provider = a->qual[d.seq].consulting_prov,
			Ordering_Provider = a->qual[d.seq].ordering_prov,
			Order_Name = a->qual[d.seq].ordername,
			Container_Type = a->qual[d.seq].container_type,
			Order_Date = a->qual[d.seq].orderdate,
			Order_Lab = a->qual[d.seq].ordlab,
			Performed_Date = a->qual[d.seq].perfdttm,
			Performed_Lab = a->qual[d.seq].perflab,
			Instrument = a->qual[d.seq].instrument,
			Prompts = BUILD("Prompt Values: ",
						TRIM(prompts->p_facility,3), " | ",
						TRIM(prompts->p_unit,3), " | ",
						TRIM(prompts->p_test,3), " | ",
						TRIM(prompts->p_container_type,3), " | ",
						TRIM(prompts->p_order_prov,3), " | ",
						TRIM(prompts->p_consult_prov,3), " | ",
						TRIM(prompts->p_enctype,3), " | ",
						TRIM(prompts->p_bdate,3), " | ",
						TRIM(prompts->p_edate,3), " | ",
						TRIM(prompts->p_sumdet,3))
		FROM (dummyt d with seq = a->rec_cnt)
		ORDER BY Facility, Ordering_Provider, Consulting_Provider, Order_Name, Container_Type,
			Order_Lab, Performed_Lab, Instrument, Patient_Name
		WITH nocounter, format, separator = ' '
 
	ENDIF
ELSE	;No Data Show Prompts
		SELECT INTO $outdev
			Message = "No data for the prompt values",
			Facility_Prompt = prompts->p_facility,
			Nurse_Unit_Prompt = prompts->p_unit,
			Test_Prompt = prompts->p_test,
			Container_Prompt = prompts->p_container_type,
			Order_Provider_Prompt = prompts->p_order_prov,
			Consulting_Provider_Prompt = prompts->p_consult_prov,
			Enc_Type_Prompt = prompts->p_enctype,
			Begin_Date_Prompt = prompts->p_bdate,
			End_Date_Prompt = prompts->p_edate,
			Summary_or_Detail_Prompt = prompts->p_sumdet
		FROM (dummyt d with seq = prompts->rec_cnt)
		WITH nocounter, format, separator = ' '
ENDIF
 
;CALL ECHORECORD(a)
;CALL ECHORECORD(totals)
CALL ECHORECORD(prompts)
 
#exitscript
END
GO
