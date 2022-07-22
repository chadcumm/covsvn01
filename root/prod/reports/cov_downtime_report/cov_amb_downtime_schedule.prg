/***********************************************************
Author 			:	Dawn Greer, DBA
Date Written	:	12/08/2020
Program Title	:	cov_amb_downtime_schedule
Source File		:	cov_amb_downtime_schedule.prg
Object Name		:	cov_amb_downtime_schedule
Directory		:	cust_script
 
Purpose			: 	Ambulatory Downtime Schedules
Notes: 			:   Copied from cov_amb_schedule
 
Mod		Date		Engineer				Comment
----    ----------- ----------------------- ---------------------------
 
*************************************************************************/
drop program cov_amb_downtime_schedule go
create program cov_amb_downtime_schedule
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Select Facility" = 0
 
with OUTDEV, FAC
 
;FREE RECORD a
RECORD a
(
	1	rec_cnt		=	i4
	1	qual[*]
		2	patient 		=	c100
		2	dob				=	c10
		2   age_as_of_dos   =   i4
		2	home_phone		=	c15
		2	mobile_phone 	=	c15
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
		2   rpt_date        =   vc
)
 
DECLARE fac_opr_var = c2
DECLARE faclist = c2000
DECLARE facprompt = vc
DECLARE num = i4
DECLARE facitem = vc
DECLARE cnt = i4 WITH PROTECT
DECLARE startdate			= F8
DECLARE enddate				= F8
 
 
SET startdate = CNVTDATETIME(CURDATE-1,0)
SET enddate = CNVTDATETIME(CURDATE-1,235959)
 
 
/**********************************************************
Get CMG Facility Data
***********************************************************/
 
;Pulling the CMG List for when Any is selected in the Prompt
SELECT facnum = CNVTSTRING(CV.CODE_VALUE)
FROM CODE_VALUE CV, CODE_VALUE_EXTENSION CVE
WHERE CV.CODE_VALUE = CVE.CODE_VALUE
AND CV.CODE_SET = 220
AND CV.CDF_MEANING = 'AMBULATORY'
AND CV.ACTIVE_IND = 1
AND CVE.FIELD_NAME = 'CMG Reporting'
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
	FIN = TRIM(ENCNTR_ALIAS.ALIAS,3)
FROM PERSON
  , (LEFT JOIN PHONE ON (PERSON.PERSON_ID = PHONE.PARENT_ENTITY_ID
  		AND PHONE.PARENT_ENTITY_NAME = 'PERSON'
  		AND PHONE.ACTIVE_IND = 1
  		AND PHONE.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE,CURTIME3)
  		AND PHONE.PHONE_TYPE_CD = 170 /*Home Phone*/
  		AND PHONE.PHONE_TYPE_SEQ = 1
  		AND PHONE.PHONE_NUM_KEY != ' '
  	))
  , (LEFT JOIN PHONE MPHONE ON (PERSON.PERSON_ID = MPHONE.PARENT_ENTITY_ID	;002
  		AND MPHONE.PARENT_ENTITY_NAME = 'PERSON'
  		AND MPHONE.ACTIVE_IND = 1
  		AND MPHONE.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE,CURTIME3)
  		AND MPHONE.PHONE_TYPE_CD = 4149712.00 /*Mobile Phone*/
  		AND MPHONE.PHONE_TYPE_SEQ = 1
  		AND MPHONE.PHONE_NUM_KEY != ' '
  	))
  , (INNER JOIN ENCOUNTER ON (ENCOUNTER.PERSON_ID=PERSON.PERSON_ID
  		AND ENCOUNTER.ACTIVE_IND = 1
  	))
  , (INNER JOIN ENCNTR_ALIAS ON (ENCNTR_ALIAS.ENCNTR_ID=ENCOUNTER.ENCNTR_ID
		AND ENCNTR_ALIAS.ACTIVE_IND = 1
		AND ENCNTR_ALIAS.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE,CURTIME3)
		AND ENCNTR_ALIAS.ENCNTR_ALIAS_TYPE_CD = 1077  /*FIN NBR*/
	))
  , (LEFT JOIN ENCNTR_PLAN_RELTN ENCNTR_PLAN_RELTN2 ON (ENCOUNTER.ENCNTR_ID=ENCNTR_PLAN_RELTN2.ENCNTR_ID
  		AND ENCNTR_PLAN_RELTN2.PRIORITY_SEQ = 1
  		AND ENCNTR_PLAN_RELTN2.ACTIVE_IND = 1
  	))
  , (LEFT JOIN ORGANIZATION ORGANIZATION_PRIM ON (ORGANIZATION_PRIM.ORGANIZATION_ID=ENCNTR_PLAN_RELTN2.ORGANIZATION_ID
  	))
  , (INNER JOIN SCH_APPT APPT_SCH_APPT ON (APPT_SCH_APPT.ENCNTR_ID=ENCOUNTER.ENCNTR_ID
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
WHERE PERSON.ACTIVE_IND = 1
AND PARSER(facprompt)
AND APPT_SCH_RESOURCE_ALL.MNEMONIC_KEY IS NOT NULL
AND APPT_SCH_RESOURCE_ALL.MNEMONIC_KEY != ' '
AND APPT_SCH_RES_APPT_ALL.SLOT_STATE_CD IN (0,9541)
;AND PERSON.NAME_LAST_KEY NOT IN ('FFFFPEDS','FFFFAMB','FFFFPNRC','FFFFOP','FFFFED','FFFFIP','FFFFWH','FFFFTEST','FFFFREVCYCLE',
;	'FFFFPHARM','ZZGLOVER','ZZTEST','ZZWICK','ZZBOGUS','ZZZZTESTPW','ZZZREGRESSION','ZZZZBHTEST','ZZZNEUROPW','ZZZFLMCRAD',
;	'ZZZFSRRAD','ZZZTESTONE','ZZZAMB','ZZZPWRAD','ZZTOPTEST','ZZZ','ZZZRMCRAD','ZZZZTESTPBH','ZZMDDONOTUSE','ZZZMPITESTP',
;	'ZZZRADTEST','ZZZFSRGO','ZZZFSWRAD','ZZZTESTIP','ZZZTEST','ZZELLMER','ZZZMPITESTBL','ZZZZTESTPOC','ZZZZZZTEST','ZZZTESTOP',
;	'TTTTTEST','TTTTGENLAB','TTTT','TTTTMAYO','TTTTPHARMTEST','TTTTESTFSV','TTTTONC','TTTTESTCATHLAB','TTURNER','TTEST',
;	'TTTTHUDLOW','TTTTTESTFN','TTTTCAMCAPTEST','TTTTMDI','TTBACKLOADING','TTTTESTPRVL','TTTTMMC','TTTTQUEST','TTHOMASON',
;	'TTTTPRINTER','TTTTEST')
AND APPT_SCH_RES_APPT_ALL.BEG_DT_TM BETWEEN CNVTDATETIME(startdate) AND CNVTDATETIME(enddate)
 
HEAD REPORT
	cnt = 0
	CALL alterlist(a->qual, 10)
 
DETAIL
	cnt = cnt + 1
	IF (mod(cnt,10) = 1 OR cnt = 1)
		stat = alterlist(a->qual, cnt + 9)
	ENDIF
 
	a->qual[cnt].patient 		= 	TRIM(PERSON.NAME_FULL_FORMATTED,3)
	a->qual[cnt].dob			= 	FORMAT(CNVTDATETIMEUTC(PERSON.BIRTH_DT_TM,1),"MM/DD/YYYY;;d")
	a->qual[cnt].age_as_of_dos  =   FLOOR((DATETIMEDIFF(APPT_SCH_RES_APPT_ALL.BEG_DT_TM, PERSON.BIRTH_DT_TM)/365))
	a->qual[cnt].home_phone	 	=	EVALUATE2(IF (SIZE(TRIM(PHONE.PHONE_NUM,3)) = 10)
  		CONCAT("(",SUBSTRING(1,3,PHONE.PHONE_NUM),") ",SUBSTRING(4,3,PHONE.PHONE_NUM),"-",SUBSTRING(7,4,PHONE.PHONE_NUM))
  		ELSE " " ENDIF)
	a->qual[cnt].mobile_phone	=	EVALUATE2(IF (SIZE(TRIM(MPHONE.PHONE_NUM,3)) = 10)
  		CONCAT("(",SUBSTRING(1,3,MPHONE.PHONE_NUM),") ",SUBSTRING(4,3,MPHONE.PHONE_NUM),"-",SUBSTRING(7,4,MPHONE.PHONE_NUM))
  		ELSE " " ENDIF)
	a->qual[cnt].insurance		=	TRIM(ORGANIZATION_PRIM.ORG_NAME,3)
	a->qual[cnt].fin			= 	TRIM(ENCNTR_ALIAS.ALIAS,3)
	a->qual[cnt].appt_date_time	=	CNVTUPPER(FORMAT(APPT_SCH_RES_APPT_ALL.BEG_DT_TM, "hh:mm;;S"))
	a->qual[cnt].appt_date_only	=	FORMAT(APPT_SCH_RES_APPT_ALL.BEG_DT_TM, "MM/DD/YYYY")
	a->qual[cnt].appt_date   	=	FORMAT(APPT_SCH_RES_APPT_ALL.BEG_DT_TM, "MM/DD/YYYY hh:mm")
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
 
CALL ECHORECORD(a)
 
GO TO exitscript
#exitscript
 
END
GO
 
 