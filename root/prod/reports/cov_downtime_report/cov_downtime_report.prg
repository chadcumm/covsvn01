/***********************************************************
Author 			:	Dawn Greer, DBA
Date Written	:	12/11/2020
Program Title	:	cov_downtime_report
Source File		:	cov_downtime_report.prg
Object Name		:	cov_downtime_report
Directory		:	cust_script
 
Purpose			: 	Downtime Report
Notes: 			:   This is a driver program for two Layout builders
					(cov_downtime_schedule and cov_downtime_patinfo)
 
Mod		Date		Engineer				Comment
----    ----------- ----------------------- ---------------------------
001     12/31/2020  Dawn Greer, DBA         Renamed program
											from cov_amb_downtime_patinfo
											to cov_amb_downtime_report
002     01/29/2021  Dawn Greer, DBA         Changed the Facility list to
                                            include Facility sites instead
                                            of just CMG.  Rename report from
                                            cov_amb_downtime_report to
                                            cov_downtime_report.  Renamed the
                                            Layout Builders as well.
*************************************************************************/
drop program cov_downtime_report go
create program cov_downtime_report
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Select Facility" = 0
 
with OUTDEV, FAC
 
;FREE RECORD a
RECORD a
(
	1	rec_cnt		=	i4
	1	qual[*]
		2	person_id       =   f8
		2   patient 		=	c100
		2	dob				=	c10
		2   age_as_of_dos   =   i4
		2	home_phone		=	c15
		2	mobile_phone 	=	c15
		2   person_addr     =   c50
		2   person_city     =   c50
		2   person_state    =   c2
		2   person_zip      =   c10
		2	insurance		=	c50
		2	fin				=	c20
		2	appt_date_time	=	c25
		2   appt_date_only  =   c25
		2   appt_date       =   c25
		2   appt_duration   =   i4
		2	appt_status		=   c50
		2 	appt_type		=	c50
		2	appt_reminder	=	c50
		2	visit_reason	=	c100
		2	resource		=	c100
		2	facility		=	c100
		2   rpt_date        =   c25
		2   nkallergies     =   c120
		2   allergies_cnt   =   i4
		2   allergies_qual[*]
			3  allergy_id   =   f8
			3  substance    =   c50
			3  allergy_cat  =   c30
			3  reactions    =   c100
			3  severity     =   c50
			3  allergy_type =   c50
			3  allergy_status = c10
			3  reviewed_dt  =   c25
		2   med_cnt         =   i4
		2   med_qual[*]
			3  order_id     =   f8
			3  location     =   c100
			3  mnemonic     =   c200
			3  long_desc    =   c200
			3  order_details =  c500
			3  order_status =   c25
			3  enc_type     =   c100
		2   prob_cnt        =   i4
		2   prob_qual[*]
			3  problem_id   =   f8
			3  problem      =   c200
			3  prob_code    =   c50
			3  onset_dt     =   c25
			3  beg_eff_dt   =   c25
			3  end_eff_dt   =   c25
		2   recommend_cnt   =   i4
		2   recommend_qual[*]
			3  recommend_id =   f8
			3  recommend_cat =  c100
			3  recommend    =   c100
			3  priority     =   c25
			3  frequency    =   c25
			3  due_date     =   c25
)
 
DECLARE fac_opr_var = c2
DECLARE faclist = c2000
DECLARE facprompt = vc
DECLARE num = i4
DECLARE facitem = vc
DECLARE cnt = i4 WITH PROTECT
DECLARE startdate			= F8
DECLARE enddate				= F8
 
 
SET startdate = CNVTDATETIME(CURDATE,0)
SET enddate = CNVTDATETIME(CURDATE+4,235959)
 
/**********************************************************
Get CMG Facility Data
***********************************************************/
 
;Pulling the CMG List for when Any is selected in the Prompt
SELECT facnum = CNVTSTRING(CV.CODE_VALUE)
FROM CODE_VALUE CV, CODE_VALUE_EXTENSION CVE
WHERE OUTERJOIN(CV.CODE_VALUE) = CVE.CODE_VALUE
AND CV.CODE_SET = 220
AND CV.CDF_MEANING = 'AMBULATORY'
AND CV.ACTIVE_IND = 1
AND CVE.FIELD_NAME = OUTERJOIN('CMG Reporting')
ORDER BY TRIM(CV.DESCRIPTION,3)
 
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
IF(SUBSTRING(1,1,REFLECT(PARAMETER(PARAMETER2($FAC),0))) = "L")		;multiple options selected
	SET fac_opr_var = "IN"
	SET facprompt = '('
	SET num = CNVTINT(SUBSTRING(2,2,REFLECT(PARAMETER(PARAMETER2($FAC),0))))
 
	FOR (i = 1 TO num)
		SET facitem = CNVTSTRING(PARAMETER(PARAMETER2($FAC),i))
		SET facprompt = BUILD(facprompt,facitem)
		IF (i != num)
			SET facprompt = BUILD(facprompt, ",")
		ENDIF
	ENDFOR
	SET facprompt = BUILD(facprompt, ")")
	SET facprompt = BUILD("CV_APPT_RES_ALL_LOC_COV.CODE_VALUE IN ",facprompt)
 
ELSEIF(PARAMETER(PARAMETER2($FAC),1)=0.0)  ;any was selected
	SET fac_opr_var = "IN"
	SET facprompt = BUILD("CV_APPT_RES_ALL_LOC_COV.CODE_VALUE IN ", faclist)
ELSE 	;single value selected
	SET fac_opr_var = "="
	SET facitem = CNVTSTRING(PARAMETER(PARAMETER2($FAC),1))
	SET facprompt = BUILD("CV_APPT_RES_ALL_LOC_COV.CODE_VALUE = ", facitem)
ENDIF
 
/**********************************************************
Get Schedule Data
***********************************************************/
CALL ECHO ("Get Schedule Data")
 
SELECT INTO "NL:"
	FIN = TRIM(EA.ALIAS,3)
FROM PERSON PAT
  , (LEFT JOIN PHONE HPHONE ON (PAT.PERSON_ID = HPHONE.PARENT_ENTITY_ID
  		AND HPHONE.PARENT_ENTITY_NAME = 'PERSON'
  		AND HPHONE.ACTIVE_IND = 1
  		AND HPHONE.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE,CURTIME3)
  		AND HPHONE.PHONE_TYPE_CD = 170 /*Home Phone*/
  		AND HPHONE.PHONE_TYPE_SEQ = 1
  		AND HPHONE.PHONE_NUM_KEY != ' '
  	))
  , (LEFT JOIN PHONE MPHONE ON (PAT.PERSON_ID = MPHONE.PARENT_ENTITY_ID
  		AND MPHONE.PARENT_ENTITY_NAME = 'PERSON'
  		AND MPHONE.ACTIVE_IND = 1
  		AND MPHONE.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE,CURTIME3)
  		AND MPHONE.PHONE_TYPE_CD = 4149712.00 /*Mobile Phone*/
  		AND MPHONE.PHONE_TYPE_SEQ = 1
  		AND MPHONE.PHONE_NUM_KEY != ' '
  	))
  , (LEFT JOIN ADDRESS PATADDR ON (PAT.PERSON_ID = PATADDR.PARENT_ENTITY_ID
  		AND PATADDR.PARENT_ENTITY_NAME = 'PERSON'
  		AND PATADDR.ACTIVE_IND = 1
  		AND PATADDR.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE,CURTIME3)
  		AND PATADDR.ADDRESS_TYPE_CD = 756.00 /*Home Addr*/
  		AND PATADDR.ADDRESS_TYPE_SEQ = 1
  		AND PATADDR.STREET_ADDR != ' '
	))
  , (INNER JOIN ENCOUNTER ENC ON (ENC.PERSON_ID=PAT.PERSON_ID
  		AND ENC.ACTIVE_IND = 1
  	))
  , (INNER JOIN ENCNTR_ALIAS EA ON (EA.ENCNTR_ID=ENC.ENCNTR_ID
		AND EA.ACTIVE_IND = 1
		AND EA.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE,CURTIME3)
		AND EA.ENCNTR_ALIAS_TYPE_CD = 1077  /*FIN NBR*/
	))
  , (LEFT JOIN ENCNTR_PLAN_RELTN ENCNTR_PLAN_RELTN2 ON (ENC.ENCNTR_ID=ENCNTR_PLAN_RELTN2.ENCNTR_ID
  		AND ENCNTR_PLAN_RELTN2.PRIORITY_SEQ = 1
  		AND ENCNTR_PLAN_RELTN2.ACTIVE_IND = 1
  	))
  , (LEFT JOIN ORGANIZATION ORGANIZATION_PRIM ON (ORGANIZATION_PRIM.ORGANIZATION_ID=ENCNTR_PLAN_RELTN2.ORGANIZATION_ID
  	))
  , (INNER JOIN SCH_APPT APPT_SCH_APPT ON (APPT_SCH_APPT.ENCNTR_ID=ENC.ENCNTR_ID
  		AND APPT_SCH_APPT.ROLE_MEANING = "PATIENT"
  		AND APPT_SCH_APPT.STATE_MEANING != "RESCHEDULED"
  	))
  , (INNER JOIN SCH_EVENT APPT_SCH_EVENT ON (APPT_SCH_EVENT.SCH_EVENT_ID=APPT_SCH_APPT.SCH_EVENT_ID
    ))
  , (LEFT JOIN SCH_EVENT_DETAIL SCH_EVENT_DETAIL ON (SCH_EVENT_DETAIL.SCH_EVENT_ID = APPT_SCH_EVENT.SCH_EVENT_ID
  		AND SCH_EVENT_DETAIL.OE_FIELD_ID = 23372832 /*Patient Reminder*/
  		AND SCH_EVENT_DETAIL.VERSION_DT_TM > CNVTDATETIME(CURDATE,CURTIME3)
  	))
  , (LEFT JOIN SCH_APPT APPT_SCH_RES_APPT_ALL ON (APPT_SCH_RES_APPT_ALL.SCH_EVENT_ID = APPT_SCH_EVENT.SCH_EVENT_ID
  	))
  , (LEFT JOIN SCH_RESOURCE APPT_SCH_RESOURCE_ALL ON (APPT_SCH_RES_APPT_ALL.RESOURCE_CD=APPT_SCH_RESOURCE_ALL.RESOURCE_CD
    ))
  , (LEFT JOIN CODE_VALUE APPT_RES_RES_CD_ALL ON (APPT_SCH_RESOURCE_ALL.RESOURCE_CD=APPT_RES_RES_CD_ALL.CODE_VALUE
  		AND APPT_RES_RES_CD_ALL.CODE_SET = 14231
  	))
  , (LEFT JOIN CODE_VALUE CV_APPT_RES_ALL_LOC_COV ON (APPT_SCH_RES_APPT_ALL.APPT_LOCATION_CD=CV_APPT_RES_ALL_LOC_COV.CODE_VALUE
  		AND CV_APPT_RES_ALL_LOC_COV.CODE_SET = 220
		AND CV_APPT_RES_ALL_LOC_COV.CDF_MEANING IN ("AMBULATORY")
	))
  , (LEFT JOIN CODE_VALUE_EXTENSION CVE ON (CV_APPT_RES_ALL_LOC_COV.CODE_VALUE = CVE.CODE_VALUE
		AND CVE.FIELD_NAME = 'CMG Reporting'
    ))
WHERE PAT.ACTIVE_IND = 1
AND PARSER(facprompt)
AND appt_res_res_cd_all.code_value != 3677065551 /*Excluding FCS COVID19 Vaccine Resource*/
AND APPT_SCH_RESOURCE_ALL.MNEMONIC_KEY IS NOT NULL
AND APPT_SCH_RESOURCE_ALL.MNEMONIC_KEY != ' '
AND APPT_SCH_RES_APPT_ALL.SLOT_STATE_CD IN (0,9541)
AND PAT.NAME_LAST_KEY NOT IN ('FFFFPEDS','FFFFAMB','FFFFPNRC','FFFFOP','FFFFED','FFFFIP','FFFFWH','FFFFTEST','FFFFREVCYCLE',
	'FFFFPHARM','ZZGLOVER','ZZTEST','ZZWICK','ZZBOGUS','ZZZZTESTPW','ZZZREGRESSION','ZZZZBHTEST','ZZZNEUROPW','ZZZFLMCRAD',
	'ZZZFSRRAD', 'ZZZTESTONE','ZZZAMB','ZZZPWRAD','ZZTOPTEST','ZZZ','ZZZRMCRAD','ZZZZTESTPBH','ZZMDDONOTUSE','ZZZMPITESTP',
	'ZZZRADTEST','ZZZFSRGO','ZZZFSWRAD','ZZZTESTIP','ZZZTEST','ZZELLMER','ZZZMPITESTBL','ZZZZTESTPOC','ZZZZZZTEST','ZZZTESTOP',
	'TTTTTEST','TTTTGENLAB','TTTT','TTTTMAYO','TTTTPHARMTEST','TTTTESTFSV','TTTTONC','TTTTESTCATHLAB','TTURNER','TTEST',
	'TTTTHUDLOW','TTTTTESTFN','TTTTCAMCAPTEST','TTTTMDI','TTBACKLOADING','TTTTESTPRVL','TTTTMMC','TTTTQUEST','TTHOMASON',
	'TTTTPRINTER','TTTTEST')
AND APPT_SCH_RES_APPT_ALL.BEG_DT_TM BETWEEN CNVTDATETIME(startdate) AND CNVTDATETIME(enddate)
ORDER BY TRIM(CV_APPT_RES_ALL_LOC_COV.DESCRIPTION,3), TRIM(APPT_RES_RES_CD_ALL.DESCRIPTION,3), APPT_SCH_RES_APPT_ALL.BEG_DT_TM
 
HEAD REPORT
	cnt = 0
	CALL alterlist(a->qual, 10)
 
DETAIL
	cnt = cnt + 1
	IF (mod(cnt,10) = 1 OR cnt = 1)
		stat = alterlist(a->qual, cnt + 9)
	ENDIF
 
	a->qual[cnt].person_id      =   PAT.PERSON_ID
	a->qual[cnt].patient 		= 	TRIM(PAT.NAME_FULL_FORMATTED,3)
	a->qual[cnt].dob			= 	FORMAT(CNVTDATETIMEUTC(PAT.BIRTH_DT_TM,1),"MM/DD/YYYY;;d")
	a->qual[cnt].age_as_of_dos  =   FLOOR((DATETIMEDIFF(APPT_SCH_RES_APPT_ALL.BEG_DT_TM, PAT.BIRTH_DT_TM)/365))
	a->qual[cnt].home_phone	 	=	EVALUATE2(IF (SIZE(TRIM(HPHONE.PHONE_NUM,3)) = 10)
  		CONCAT("(",SUBSTRING(1,3,HPHONE.PHONE_NUM),") ",SUBSTRING(4,3,HPHONE.PHONE_NUM),"-",SUBSTRING(7,4,HPHONE.PHONE_NUM))
  		ELSE " " ENDIF)
	a->qual[cnt].mobile_phone	=	EVALUATE2(IF (SIZE(TRIM(MPHONE.PHONE_NUM,3)) = 10)
  		CONCAT("(",SUBSTRING(1,3,MPHONE.PHONE_NUM),") ",SUBSTRING(4,3,MPHONE.PHONE_NUM),"-",SUBSTRING(7,4,MPHONE.PHONE_NUM))
  		ELSE " " ENDIF)
	a->qual[cnt].person_addr    =   TRIM(PATADDR.STREET_ADDR,3)
	a->qual[cnt].person_city    =   TRIM(PATADDR.CITY,3)
	a->qual[cnt].person_state   =   TRIM(PATADDR.STATE,3)
	a->qual[cnt].person_zip     =   TRIM(SUBSTRING(1,5, PATADDR.ZIPCODE),3)
	a->qual[cnt].insurance		=	TRIM(ORGANIZATION_PRIM.ORG_NAME,3)
	a->qual[cnt].fin			= 	TRIM(EA.ALIAS,3)
	a->qual[cnt].appt_date_time	=	CNVTUPPER(FORMAT(APPT_SCH_RES_APPT_ALL.BEG_DT_TM, "hh:mm;;S"))
	a->qual[cnt].appt_date_only	=	FORMAT(APPT_SCH_RES_APPT_ALL.BEG_DT_TM, "MM/DD/YYYY")
	a->qual[cnt].appt_date	    =	FORMAT(APPT_SCH_RES_APPT_ALL.BEG_DT_TM, "MM/DD/YYYY hh:mm:ss")
	a->qual[cnt].appt_duration  =   CNVTINT(DATETIMEDIFF(APPT_SCH_RES_APPT_ALL.END_DT_TM,APPT_SCH_RES_APPT_ALL.BEG_DT_TM,4))
	a->qual[cnt].appt_status	=	UAR_GET_CODE_DISPLAY(APPT_SCH_EVENT.SCH_STATE_CD)
	a->qual[cnt].appt_type		=	UAR_GET_CODE_DISPLAY(APPT_SCH_EVENT.APPT_TYPE_CD)
	a->qual[cnt].appt_reminder	=	TRIM(SCH_EVENT_DETAIL.OE_FIELD_DISPLAY_VALUE,3)
	a->qual[cnt].visit_reason	=	TRIM(APPT_SCH_EVENT.APPT_REASON_FREE,3)
	a->qual[cnt].resource		=	TRIM(APPT_RES_RES_CD_ALL.DESCRIPTION,3)
	a->qual[cnt].facility		=	TRIM(CV_APPT_RES_ALL_LOC_COV.DESCRIPTION,3)
 	a->qual[cnt].rpt_date       =   FORMAT(CNVTDATETIME(CURDATE,CURTIME3), "MM/DD/YYYY hh:mm:ss;;q")
 
FOOT REPORT
	stat = alterlist(a->qual, cnt )
	a->rec_cnt = cnt
WITH nocounter, separator= CHAR(9), FORMAT
 
 
/**********************************************************
Get No Known Allergies Data
***********************************************************/
CALL ECHO ("Get No Known Allergies Data")
 
IF (a->rec_cnt > 0)
	SELECT INTO "NL:"
		PAT_PERSON_ID = ALLERGY_PERSON.PERSON_ID
		, NKALLERGIES = LISTAGG(TRIM(NOM_ALLERGY.SOURCE_STRING,3),", ")
			OVER(PARTITION BY ALLERGY_PERSON.PERSON_ID ORDER BY ALLERGY_PERSON.PERSON_ID)
	FROM (dummyt d WITH seq = VALUE(SIZE(a->qual,5)))
		, ALLERGY ALLERGY_PERSON
		, NOMENCLATURE NOM_ALLERGY
	PLAN d
	JOIN ALLERGY_PERSON WHERE ALLERGY_PERSON.PERSON_ID = a->qual[d.seq].person_id
		AND ALLERGY_PERSON.ACTIVE_IND = 1
		AND ALLERGY_PERSON.ACTIVE_STATUS_CD = 188 /*Active*/
		AND ALLERGY_PERSON.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE,CURTIME3)
		AND ALLERGY_PERSON.REACTION_STATUS_CD NOT IN (3300.00 /*Cancelled*/)
	JOIN NOM_ALLERGY WHERE NOM_ALLERGY.NOMENCLATURE_ID = ALLERGY_PERSON.SUBSTANCE_NOM_ID
		AND NOM_ALLERGY.ACTIVE_IND = 1
		AND NOM_ALLERGY.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE,CURTIME3)
		AND NOM_ALLERGY.NOMENCLATURE_ID IN (960419.00 /*No Known Allergies*/,
	    57826136.00 /*No Known Environmental Allergies*/,57826131.00 /*No Known Food Allergies*/,
	     22283278.00 /*No Known Medication Allergies*/)
 
	FOOT ALLERGY_PERSON.PERSON_ID
		a->qual[d.seq].nkallergies	= NKALLERGIES
 
	WITH nocounter, separator= CHAR(9), FORMAT
ENDIF
 
/**********************************************************
Get Allergies Data
***********************************************************/
CALL ECHO ("Get Allergies Data")
 
IF (a->rec_cnt > 0)
 
	SELECT DISTINCT INTO "NL:"
		ALLERGY_PERSON_ID = ALLERGY_PERSON.PERSON_ID
		,SUBSTANCE = EVALUATE2(IF (SIZE(TRIM(NOM_ALLERGY.SOURCE_STRING,3)) != 0)
			TRIM(CNVTUPPER(NOM_ALLERGY.SOURCE_STRING),3) ELSE TRIM(CNVTUPPER(ALLERGY_PERSON.SUBSTANCE_FTDESC),3) ENDIF)
		,SUBSTANCE_SORT = CNVTUPPER(EVALUATE2(IF (SIZE(TRIM(NOM_ALLERGY.SOURCE_STRING,3)) != 0)
			TRIM(CNVTUPPER(NOM_ALLERGY.SOURCE_STRING),3) ELSE TRIM(CNVTUPPER(ALLERGY_PERSON.SUBSTANCE_FTDESC),3) ENDIF))
		,ALLERGY_CAT = UAR_GET_CODE_DISPLAY(ALLERGY_PERSON.SUBSTANCE_TYPE_CD)
		,REACTIONS = LISTAGG(TRIM(NOM_REACTION.SOURCE_STRING,3),", ")
			OVER(PARTITION BY ALLERGY_PERSON.PERSON_ID, ALLERGY_PERSON.ALLERGY_ID
			ORDER BY ALLERGY_PERSON.PERSON_ID, REACTION_PERSON.ALLERGY_ID, NOM_REACTION.SOURCE_STRING)
		,FT_REACTIONS = LISTAGG(TRIM(REACTION_PERSON.REACTION_FTDESC,3),", ")
			OVER(PARTITION BY ALLERGY_PERSON.PERSON_ID, REACTION_PERSON.ALLERGY_ID
			ORDER BY ALLERGY_PERSON.PERSON_ID, REACTION_PERSON.ALLERGY_ID, REACTION_PERSON.REACTION_FTDESC)
		,SEVERITY = UAR_GET_CODE_DISPLAY(ALLERGY_PERSON.SEVERITY_CD)
		,ALLERGY_TYPE = UAR_GET_CODE_DISPLAY(ALLERGY_PERSON.REACTION_CLASS_CD)
		,ALLERGY_STATUS = UAR_GET_CODE_DISPLAY(ALLERGY_PERSON.REACTION_STATUS_CD)
		,REVIEWED_DT = CONCAT(FORMAT(ALLERGY_PERSON.REVIEWED_DT_TM, "MM/DD/YYYY"), " ",
				CNVTUPPER(FORMAT(ALLERGY_PERSON.REVIEWED_DT_TM, "hh:mm;;S")))
	FROM (dummyt d WITH seq = VALUE(SIZE(a->qual,5)))
		, ALLERGY ALLERGY_PERSON
		, NOMENCLATURE NOM_ALLERGY
		, REACTION REACTION_PERSON
		, NOMENCLATURE NOM_REACTION
	PLAN d
	JOIN ALLERGY_PERSON WHERE ALLERGY_PERSON.PERSON_ID = a->qual[d.seq].person_id
		AND ALLERGY_PERSON.ACTIVE_IND = 1
		AND ALLERGY_PERSON.ACTIVE_STATUS_CD = 188 /*Active*/
		AND ALLERGY_PERSON.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE,CURTIME3)
		AND ALLERGY_PERSON.REACTION_STATUS_CD NOT IN (3300.00 /*Cancelled*/)
	JOIN NOM_ALLERGY WHERE NOM_ALLERGY.NOMENCLATURE_ID = ALLERGY_PERSON.SUBSTANCE_NOM_ID
		AND NOM_ALLERGY.ACTIVE_IND = 1
		AND NOM_ALLERGY.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE,CURTIME3)
		AND NOM_ALLERGY.NOMENCLATURE_ID NOT IN (960419.00 /*No Known Allergies*/,
	    57826136.00 /*No Known Environmental Allergies*/,57826131.00 /*No Known Food Allergies*/,
	     22283278.00 /*No Known Medication Allergies*/)
	JOIN REACTION_PERSON WHERE REACTION_PERSON.ALLERGY_ID = OUTERJOIN(ALLERGY_PERSON.ALLERGY_ID)
		AND REACTION_PERSON.ACTIVE_IND = OUTERJOIN(1)
		AND REACTION_PERSON.ACTIVE_STATUS_CD = OUTERJOIN(188 /*Active*/)
		AND REACTION_PERSON.END_EFFECTIVE_DT_TM > OUTERJOIN(CNVTDATETIME(CURDATE,CURTIME3))
	JOIN NOM_REACTION WHERE OUTERJOIN(REACTION_PERSON.REACTION_NOM_ID) = NOM_REACTION.NOMENCLATURE_ID
	ORDER BY ALLERGY_PERSON.PERSON_ID,SUBSTANCE_SORT
 
	HEAD ALLERGY_PERSON.PERSON_ID
		cnt = 0
		idx = 0
		subcnt = 0
		idx = LOCATEVAL(cnt,1,SIZE(a->qual,5),ALLERGY_PERSON.PERSON_ID, a->qual[cnt].person_id)
 
	HEAD ALLERGY_PERSON.ALLERGY_ID
		subcnt = subcnt + 1
 
		IF (mod(subcnt,10)>0)
			CALL ALTERLIST(a->qual[idx].allergies_qual, subcnt + (10-mod(subcnt,10)))
		ENDIF
 
	FOOT ALLERGY_PERSON.ALLERGY_ID
 
		IF (mod(subcnt,10) = 1)
			CALL ALTERLIST(a->qual[idx].allergies_qual, subcnt + 9)
		ENDIF
 
	 	a->qual[idx].allergies_qual[subcnt].allergy_id = ALLERGY_PERSON.ALLERGY_ID
		a->qual[idx].allergies_qual[subcnt].substance =	EVALUATE2(IF (SIZE(TRIM(NOM_ALLERGY.SOURCE_STRING,3)) != 0)
			TRIM(NOM_ALLERGY.SOURCE_STRING,3) ELSE TRIM(ALLERGY_PERSON.SUBSTANCE_FTDESC,3) ENDIF)
		a->qual[idx].allergies_qual[subcnt].allergy_cat = UAR_GET_CODE_DISPLAY(ALLERGY_PERSON.SUBSTANCE_TYPE_CD)
		a->qual[idx].allergies_qual[subcnt].reactions = EVALUATE2(IF (SIZE(TRIM(REACTIONS,3)) != 0) TRIM(REACTIONS,3)
			ELSE TRIM(FT_REACTIONS,3) ENDIF)
		a->qual[idx].allergies_qual[subcnt].severity = UAR_GET_CODE_DISPLAY(ALLERGY_PERSON.SEVERITY_CD)
		a->qual[idx].allergies_qual[subcnt].allergy_type = UAR_GET_CODE_DISPLAY(ALLERGY_PERSON.REACTION_CLASS_CD)
		a->qual[idx].allergies_qual[subcnt].allergy_status = UAR_GET_CODE_DISPLAY(ALLERGY_PERSON.REACTION_STATUS_CD)
		a->qual[idx].allergies_qual[subcnt].reviewed_dt = CONCAT(FORMAT(ALLERGY_PERSON.REVIEWED_DT_TM, "MM/DD/YYYY"), " ",
				CNVTUPPER(FORMAT(ALLERGY_PERSON.REVIEWED_DT_TM, "hh:mm;;S")))
 
	FOOT ALLERGY_PERSON.PERSON_ID
 
		a->qual[idx].allergies_cnt = subcnt
		CALL ALTERLIST(a->qual[idx].allergies_qual, subcnt)
 
		idx = LOCATEVAL(cnt,(idx+1), SIZE(a->qual,5),ALLERGY_PERSON.PERSON_ID, a->qual[cnt].person_id)
		subcnt = 0
 
	WITH nocounter, separator= CHAR(9), FORMAT
ENDIF
 
/**********************************************************
Get Medication Data
***********************************************************/
CALL ECHO ("Get Medication Data")
 
IF (a->rec_cnt > 0)
 
	SELECT DISTINCT INTO "NL:"
		MED_PERSON_ID = ORD.PERSON_ID
		, LOCATION = UAR_GET_CODE_DESCRIPTION(ENC.LOC_FACILITY_CD)
		, MNEMONIC = TRIM(ORD.ORDERED_AS_MNEMONIC,3)
		, LONG_DESC = TRIM(OC.DESCRIPTION,3)
		, LONG_SORT = CNVTUPPER(TRIM(OC.DESCRIPTION,3))
		, ORDER_DETAILS =  TRIM(ORD.CLINICAL_DISPLAY_LINE,3)
		, ORDER_STATUS = EVALUATE2(IF (ORD.ORDER_STATUS_CD = 2550.00 /*Ordered*/ AND ORD.ORIG_ORD_AS_FLAG IN (1,5))
		"Prescribed" ELSEIF (ORD.ORDER_STATUS_CD = 2550.00 /*Ordered*/ AND ORD.ORIG_ORD_AS_FLAG IN (2,3))
		"Documented" ELSE UAR_GET_CODE_DISPLAY(ORD.ORDER_STATUS_CD) ENDIF)
		, ENC_TYPE = UAR_GET_CODE_DISPLAY(ENC.ENCNTR_TYPE_CD)
	FROM (dummyt d WITH seq = VALUE(SIZE(a->qual,5)))
		, ORDERS ORD
		, ORDER_CATALOG OC
		, ENCOUNTER ENC
	PLAN d
	JOIN ORD WHERE ORD.PERSON_ID = a->qual[d.seq].person_id
		AND ORD.CATALOG_TYPE_CD = 2516.00 /*Pharmacy*/
		AND ORD.PRODUCT_ID >= 0
		AND ORD.ORDERED_AS_MNEMONIC NOT LIKE 'Alert to Pharmacy*'
		AND ORD.ORDERED_AS_MNEMONIC NOT LIKE 'Consult to Pharmacy*'
		AND ORD.ORDER_STATUS_CD IN (2550.00 /*Ordered*/)
		AND ORD.ACTIVE_IND = 1
	JOIN OC WHERE OC.CATALOG_CD = ORD.CATALOG_CD
	JOIN ENC WHERE ORD.ENCNTR_ID = ENC.ENCNTR_ID
		AND ORD.PERSON_ID = ENC.PERSON_ID
		AND ENC.ACTIVE_IND = 1
	ORDER BY MED_PERSON_ID, LONG_SORT, ORD.ORDERED_AS_MNEMONIC
 
	HEAD ORD.PERSON_ID
		cnt = 0
		idx = 0
		subcnt = 0
		idx = LOCATEVAL(cnt,1,SIZE(a->qual,5),ORD.PERSON_ID, a->qual[cnt].person_id)
 
	HEAD ORD.ORDER_ID
		subcnt = subcnt + 1
 
		IF (mod(subcnt,10)>0)
			CALL ALTERLIST(a->qual[idx].med_qual, subcnt + (10-mod(subcnt,10)))
		ENDIF
 
	FOOT ORD.ORDER_ID
 
		IF (mod(subcnt,10) = 1)
			CALL ALTERLIST(a->qual[idx].med_qual, subcnt + 9)
		ENDIF
 
	 	a->qual[idx].med_qual[subcnt].order_id = ORD.ORDER_ID
	 	a->qual[idx].med_qual[subcnt].location = LOCATION
		a->qual[idx].med_qual[subcnt].mnemonic = MNEMONIC
		a->qual[idx].med_qual[subcnt].long_desc = LONG_DESC
		a->qual[idx].med_qual[subcnt].order_details = ORDER_DETAILS
		a->qual[idx].med_qual[subcnt].order_status = ORDER_STATUS
		a->qual[idx].med_qual[subcnt].enc_type = ENC_TYPE
 
	FOOT ORD.PERSON_ID
 
		a->qual[idx].med_cnt = subcnt
		CALL ALTERLIST(a->qual[idx].med_qual, subcnt)
 
		idx = LOCATEVAL(cnt,(idx+1), SIZE(a->qual,5),ORD.PERSON_ID, a->qual[cnt].person_id)
		subcnt = 0
 
	WITH nocounter, separator= CHAR(9), FORMAT
ENDIF
 
/**********************************************************
Get Problem Data
***********************************************************/
CALL ECHO ("Get Problem Data")
 
IF (a->rec_cnt > 0)
 
	SELECT INTO "NL:"
		PROB_PERSON_ID = PROB.PERSON_ID
		, PROBLEM = TRIM(PROB.ANNOTATED_DISPLAY,3)
		, PROB_CODE = TRIM(NOM_PROB.SOURCE_IDENTIFIER,3)
		, ONSET_DATE = EVALUATE2(IF (PROB.ONSET_DT_TM = NULL) " "
			ELSE CONCAT(FORMAT(PROB.ONSET_DT_TM, "MM/DD/YYYY"), " ",
				CNVTUPPER(FORMAT(PROB.ONSET_DT_TM, "hh:mm;;S"))) ENDIF)
		, BEG_EFF =  CONCAT(FORMAT(PROB.BEG_EFFECTIVE_DT_TM, "MM/DD/YYYY"), " ",
				CNVTUPPER(FORMAT(PROB.BEG_EFFECTIVE_DT_TM, "hh:mm;;S")))
		, END_EFF = CONCAT(FORMAT(PROB.END_EFFECTIVE_DT_TM, "MM/DD/YYYY"), " ",
				CNVTUPPER(FORMAT(PROB.END_EFFECTIVE_DT_TM, "hh:mm;;S")))
	FROM (dummyt d WITH seq = VALUE(SIZE(a->qual,5)))
		, PROBLEM PROB
		, NOMENCLATURE NOM_PROB
	PLAN d
	JOIN PROB WHERE PROB.PERSON_ID = a->qual[d.seq].person_id
		AND PROB.ACTIVE_IND = 1
		AND PROB.CANCEL_REASON_CD = 0.00
		AND PROB.LIFE_CYCLE_STATUS_CD = 3301.00 /*ACTIVE*/
	JOIN NOM_PROB WHERE PROB.NOMENCLATURE_ID = NOM_PROB.NOMENCLATURE_ID
	ORDER BY PROB_PERSON_ID, ONSET_DATE, PROBLEM, PROB.PROBLEM_ID
 
	HEAD PROB.PERSON_ID
		cnt = 0
		idx = 0
		subcnt = 0
		idx = LOCATEVAL(cnt,1,SIZE(a->qual,5),PROB.PERSON_ID, a->qual[cnt].person_id)
 
	HEAD PROB.PROBLEM_ID
		subcnt = subcnt + 1
 
		IF (mod(subcnt,10)>0)
			CALL ALTERLIST(a->qual[idx].prob_qual, subcnt + (10-mod(subcnt,10)))
		ENDIF
 
	FOOT PROB.PROBLEM_ID
 
		IF (mod(subcnt,10) = 1)
			CALL ALTERLIST(a->qual[idx].prob_qual, subcnt + 9)
		ENDIF
 
	 	a->qual[idx].prob_qual[subcnt].problem_id = PROB.PROBLEM_ID
	 	a->qual[idx].prob_qual[subcnt].problem = PROBLEM
		a->qual[idx].prob_qual[subcnt].prob_code = PROBLEM
		a->qual[idx].prob_qual[subcnt].onset_dt = EVALUATE2(IF (PROB.ONSET_DT_TM = NULL) " "
			ELSE CONCAT(FORMAT(PROB.ONSET_DT_TM, "MM/DD/YYYY"), " ",
				CNVTUPPER(FORMAT(PROB.ONSET_DT_TM, "hh:mm;;S"))) ENDIF)
		a->qual[idx].prob_qual[subcnt].beg_eff_dt = CONCAT(FORMAT(PROB.BEG_EFFECTIVE_DT_TM, "MM/DD/YYYY"), " ",
				CNVTUPPER(FORMAT(PROB.BEG_EFFECTIVE_DT_TM, "hh:mm;;S")))
		a->qual[idx].prob_qual[subcnt].end_eff_dt = CONCAT(FORMAT(PROB.END_EFFECTIVE_DT_TM, "MM/DD/YYYY"), " ",
				CNVTUPPER(FORMAT(PROB.END_EFFECTIVE_DT_TM, "hh:mm;;S")))
 
	FOOT PROB.PERSON_ID
 
		a->qual[idx].prob_cnt = subcnt
		CALL ALTERLIST(a->qual[idx].prob_qual, subcnt)
 
		idx = LOCATEVAL(cnt,(idx+1), SIZE(a->qual,5),PROB.PERSON_ID, a->qual[cnt].person_id)
		subcnt = 0
 
	WITH nocounter, separator= CHAR(9), FORMAT
ENDIF
 
/**********************************************************
Get Recommendations Data
***********************************************************/
CALL ECHO ("Get Recommendations Data")
 
IF (a->rec_cnt > 0)
 
	SELECT INTO "NL:"
		HM_REC_PERSON_ID = HM_REC.PERSON_ID
		, REC_CATEGORY = TRIM(HES.EXPECT_SCHED_NAME,3)
		, RECOMMENDATION = TRIM(HE.EXPECT_NAME,3)
		, PRIORITY = TRIM(HESS.PRIORITY_MEANING,3)
		, FREQUENCY = CNVTSTRING(HM_REC.FREQUENCY_VAL)
		, FREQUENCY_UNIT = UAR_GET_CODE_DISPLAY(HM_REC.FREQUENCY_UNIT_CD)
		, DUE_DATE = EVALUATE2(IF (NULLIND(hm_rec.due_dt_tm) = 1)
			FORMAT(FORMAT(CNVTDATETIME(CURDATE,0),"MM/DD/YYYY hh:mm;;d"),"MM/DD/YYYY")
			ELSE FORMAT(CNVTDATETIMEUTC(HM_REC.DUE_DT_TM,4), "MM/DD/YYYY;;d") ENDIF)
	FROM (dummyt d WITH seq = VALUE(SIZE(a->qual,5)))
		, HM_RECOMMENDATION HM_REC
		, HM_RECOMMENDATION_ACTION HM_REC_ACT
		, HM_EXPECT HE
		, HM_EXPECT_SERIES HESS
		, HM_EXPECT_SCHED HES
	PLAN d
	JOIN HM_REC WHERE HM_REC.PERSON_ID = a->qual[d.seq].person_id
		AND HM_REC.status_flag NOT IN (5,6,7,8)
		AND (HM_REC.DUE_DT_TM <= CNVTDATETIME(DATETIMEFIND(CNVTLOOKAHEAD("12,M"),"M","E","E"))
			OR NULLIND(HM_REC.due_dt_tm) = 1)
	JOIN HM_REC_ACT WHERE HM_REC.RECOMMENDATION_ID = HM_REC_ACT.RECOMMENDATION_ID
		AND HM_REC_ACT.ACTION_FLAG = 14 /*Qualified*/
	JOIN HE WHERE HM_REC.EXPECT_ID = HE.EXPECT_ID
		AND HE.ACTIVE_IND = 1
	JOIN HESS WHERE HE.EXPECT_SERIES_ID = HESS.EXPECT_SERIES_ID
		AND HESS.ACTIVE_IND = 1
	JOIN HES WHERE HESS.EXPECT_SCHED_ID = HES.EXPECT_SCHED_ID
		AND HES.ACTIVE_IND = 1
	ORDER BY HM_REC.PERSON_ID, RECOMMENDATION, PRIORITY, DUE_DATE
 
	HEAD HM_REC.PERSON_ID
		cnt = 0
		idx = 0
		subcnt = 0
		idx = LOCATEVAL(cnt,1,SIZE(a->qual,5),HM_REC.PERSON_ID, a->qual[cnt].person_id)
 
	HEAD HM_REC.RECOMMENDATION_ID
		subcnt = subcnt + 1
 
		IF (mod(subcnt,10)>0)
			CALL ALTERLIST(a->qual[idx].recommend_qual, subcnt + (10-mod(subcnt,10)))
		ENDIF
 
	FOOT HM_REC.RECOMMENDATION_ID
 
		IF (mod(subcnt,10) = 1)
			CALL ALTERLIST(a->qual[idx].recommend_qual, subcnt + 9)
		ENDIF
 
	 	a->qual[idx].recommend_qual[subcnt].recommend_id = HM_REC.RECOMMENDATION_ID
	 	a->qual[idx].recommend_qual[subcnt].recommend_cat = TRIM(HES.EXPECT_SCHED_NAME,3)
		a->qual[idx].recommend_qual[subcnt].recommend = TRIM(HE.EXPECT_NAME,3)
		a->qual[idx].recommend_qual[subcnt].priority = TRIM(HESS.PRIORITY_MEANING,3)
		a->qual[idx].recommend_qual[subcnt].frequency = EVALUATE2(IF (FREQUENCY = "0") " "
			ELSE CONCAT(TRIM(FREQUENCY,3), " ", TRIM(FREQUENCY_UNIT,3)) ENDIF)
		a->qual[idx].recommend_qual[subcnt].due_date = EVALUATE2(IF (NULLIND(hm_rec.due_dt_tm) = 1)
			FORMAT(FORMAT(CNVTDATETIME(CURDATE,0),"MM/DD/YYYY hh:mm;;d"),"MM/DD/YYYY")
			ELSE FORMAT(CNVTDATETIMEUTC(HM_REC.DUE_DT_TM,2), "MM/DD/YYYY;;d") ENDIF)
 
	FOOT HM_REC.PERSON_ID
 
		a->qual[idx].recommend_cnt = subcnt
		CALL ALTERLIST(a->qual[idx].recommend_qual, subcnt)
 
		idx = LOCATEVAL(cnt,(idx+1), SIZE(a->qual,5),HM_REC.PERSON_ID, a->qual[cnt].person_id)
		subcnt = 0
 
	WITH nocounter, separator= CHAR(9), FORMAT
ENDIF
 
CALL ECHORECORD(a)
 
	SELECT INTO $outdev
		Patient = a->qual[d.seq].patient,
		Patient_ID = a->qual[d.seq].person_id,
		DOB = a->qual[d.seq].DOB,
		Age_As_of_DOS = a->qual[d.seq].age_as_of_dos,		;002
		Home_Phone = a->qual[d.seq].home_phone,
		Mobile_Phone = a->qual[d.seq].mobile_phone,		;002
		Insurance = a->qual[d.seq].insurance,
		Fin = a->qual[d.seq].fin,
		Appt_Date = a->qual[d.seq].appt_date,
		Appt_Status = a->qual[d.seq].appt_status,
		Appt_Type = a->qual[d.seq].appt_type,
		Appt_Reminder = a->qual[d.seq].appt_reminder,
		Visit_Reason = a->qual[d.seq].visit_reason,
		Resource = a->qual[d.seq].resource,
		Facility = a->qual[d.seq].facility
	FROM (dummyt d WITH seq = a->rec_cnt)
	ORDER BY Facility, Resource, Appt_Date, Patient, Appt_Type, Appt_Status
	WITH nocounter, format, separator = ' '
 
GO TO exitscript
#exitscript
 
END
GO
 
 