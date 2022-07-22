/*********************************************************************************
Author          :	Dawn Greer, DBA
Date Written	:	10/26/2020
Program Title	:	cov_amb_schedule
Source File     :	cov_amb_schedule.prg
Object Name     :	cov_amb_schedule
Directory       :	cust_script
 
Purpose         : 	Ambulatory Schedules
 
 
Mod     Date        Engineer                Comment
----    ----------- ----------------------- ---------------------------------------
001     10/26/2020  Dawn Greer, DBA         Original Release - CR 8587
002     10/27/2020  Dawn Greer, DBA         CR 7536 - Add Prompt for
                                            Appt Type and Age.  Add
                                            mobile phone. Add Age2 for
                                            less than or equal to.
003     10/30/2020  Dawn Greer, DBA         Add Appt_Type to the Summary
                                            Option.  Added a Summary of
                                            Distinct Patients Options.
004     11/06/2020  Dawn Greer, DBA         Limit the output of Any to just
                                            the CMG clinics like the prompt.
005     12/14/2020  Dawn Greer, DBA         CR 8977 - Add Prompt for Visit
                                            Reason.
006     12/18/2020  Dawn Greer, DBA         CR 9202 - Visit Reason prompt
                                            was causing some entries to be
                                            excluded.
007     01/13/2021  Dawn Greer, DBA         CR 9319 - Appts without an
                                            encounter number missing from the
                                            report.  Changed the JOINS for
                                            encounter and encntr_alias to LEFT JOINS.
                                            Made some changes to documentation and
                                            code case (made table alias and field names lowercase).
008     02/04/2021  Dawn Greer, DBA         Hid code values from Prompts.
009     02/12/2021  Dawn Greer, DBA         CR 9527 - Add CMRN to the output.
010     02/25/2021  Dawn Greer, DBA         CR 9679 - Set defaults to prompts that didn't have one.
011     11/04/2021  Dawn Greer, DBA         CR 11549 - Added code to exclude insurances with 
                                            end_effective_dt_tm earlier than today. 
************************************************************************************/
drop program cov_amb_schedule go
create program cov_amb_schedule
 
prompt
	"Output to File/Printer/MINE" = "MINE"                                       ;* Enter or select the printer or file name to se
	, "Select Facility" = 0
	, "Select Resource" = VALUE(0.0           )
	, "Select Appt Status" = VALUE(0.0           )
	, "Select Appt Type" = VALUE(0.0           )
	, "Select Appt Reason" = VALUE("Any                                     ")
	, "Age Greater Than Equal To" = 0
	, "Age Less Than Equal To" = 150
	, "Select Appt Begin Date" = "SYSDATE"
	, "Seelct Appt End Date" = "SYSDATE"
	, "Select Summary or Detail" = 0
 
with OUTDEV, FAC, RES, APPTSTATUS, APPTTYPE, VISITREASON, AGE, AGE2, BDATE, EDATE, SUMDET
 
FREE RECORD a
RECORD a
(
	1	rec_cnt		=	i4
	1	qual[*]
		2	patient 		=	c100
		2	dob				=	c10
		2   age_as_of_dos   =   i4		;002
		2	home_phone		=	c15
		2	mobile_phone 	=	c15		;002
		2	insurance		=	c50
		2   cmrn            =   c20    ;009
		2	fin				=	c20
		2	appt_date		=	c25
		2	appt_status		=   c50
		2 	appt_type		=	c50
		2	appt_reminder	=	c50
		2	visit_reason	=	c100
		2	resource		=	c100
		2	facility		=	c100
)
 
 
FREE RECORD totals
RECORD totals
(
	1 rec_cnt = i4
	1 qual[*]
		2 facility 		= c100
		2 resource 		= c100
		2 appt_type     = c50
		2 appt_status 	= c25
		2 total_counts	= i4
)
 
FREE RECORD totalsd		/* Summary Distinct Patient Totals*/  ;003
RECORD totalsd
(
	1 rec_cnt = i4
	1 qual[*]
		2 facility 		= c100
		2 resource 		= c100
		2 appt_type     = c50
		2 appt_status 	= c25
		2 total_counts	= i4
)
 
DECLARE fac_opr_var = c2
DECLARE res_opr_var = c2
DECLARE app_opr_var = c2
DECLARE visit_opr_var = c2
DECLARE faclist = c2000
DECLARE facprompt = vc
DECLARE num = i4
DECLARE facitem = vc
DECLARE visitlist = c2000
DECLARE visitprompt = vc
DECLARE vnum = i4
DECLARE visititem = vc
 
/**********************************************************
Get CMG Facility Data	;004
***********************************************************/
CALL ECHO ("Get Facility Prompt Data")
 
;004 Pulling the CMG List for when Any is selected in the Prompt
SELECT DISTINCT facnum = CNVTSTRING(CV.CODE_VALUE)
FROM CODE_VALUE CV, CODE_VALUE_EXTENSION CVE
WHERE CV.CODE_VALUE = CVE.CODE_VALUE
AND CV.CODE_SET = 220
AND CV.CDF_MEANING IN ('AMBULATORY')
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
 
;Facility Prompt		;004
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
ENDIF		;004
 
;Resource Prompt
CALL ECHO ("Get Resource Prompt Data")
 
IF(SUBSTRING(1,1,REFLECT(PARAMETER(PARAMETER2($RES),0))) = "L")		;multiple options selected
	SET res_opr_var = "IN"
ELSEIF(PARAMETER(PARAMETER2($RES),1)=0.0)  ;any was selected
	SET res_opr_var = "!="
ELSE 	;single value selected
	SET res_opr_var = "="
ENDIF
 
;Appt Status Prompt
CALL ECHO ("Get Appt Status Prompt Data")
 
IF(SUBSTRING(1,1,REFLECT(PARAMETER(PARAMETER2($APPTSTATUS),0))) = "L")		;multiple options selected
	SET app_opr_var = "IN"
ELSEIF(PARAMETER(PARAMETER2($APPTSTATUS),1)=0.0)  ;any was selected
	SET app_opr_var = "!="
ELSE 	;single value selected
	SET app_opr_var = "="
ENDIF
 
;Appt Type Prompt		;002
CALL ECHO ("Get Appt Type Prompt Data")
 
IF(SUBSTRING(1,1,REFLECT(PARAMETER(PARAMETER2($APPTTYPE),0))) = "L")		;multiple options selected
	SET appttype_opr_var = "IN"
ELSEIF(PARAMETER(PARAMETER2($APPTTYPE),1)=0.0)  ;any was selected
	SET appttype_opr_var = "!="
ELSE 	;single value selected
	SET appttype_opr_var = "="
ENDIF
 
;Visit Reason ;005
;005 Pulling the CMG List for when Any is selected in the Prompt
CALL ECHO ("Get Visit Reason Prompt Data")
 
SELECT VISITDESC = CV.DISPLAY
FROM CODE_VALUE CV, CODE_VALUE_EXTENSION CVE
WHERE CV.CODE_VALUE = CVE.CODE_VALUE
AND CV.CODE_SET = 23069
AND CV.ACTIVE_IND = 1
AND CVE.FIELD_NAME = 'CMG_Visit_Reasons'
ORDER BY TRIM(CV.DISPLAY,3)
 
HEAD REPORT
	visitlist = FILLSTRING(2000,' ')
 	visitlist = '('
DETAIL
	visitlist = BUILD(BUILD(visitlist, "'", visitdesc), "', ")
 
FOOT REPORT
	visitlist = BUILD(visitlist,')')
	visitlist = REPLACE(visitlist,',','',2)
 
WITH nocounter
 
IF(SUBSTRING(1,1,REFLECT(PARAMETER(PARAMETER2($VISITREASON),0))) = "L")		;multiple options selected
	SET visitprompt = "('"
	SET vnum = CNVTINT(SUBSTRING(2,2,REFLECT(PARAMETER(PARAMETER2($VISITREASON),0))))
 	FOR (i = 1 TO vnum)
		SET visititem = PARAMETER(PARAMETER2($VISITREASON),i)
		SET visitprompt = BUILD(visitprompt,visititem)
		IF (i != vnum)
			SET visitprompt = BUILD(visitprompt, "','")
		ENDIF
	ENDFOR
	SET visitprompt = BUILD(visitprompt, "')")
	SET visitprompt = BUILD("APPT_SCH_EVENT.APPT_REASON_FREE IN ",visitprompt)
ELSEIF(SUBSTRING(1,2,REFLECT(PARAMETER(PARAMETER2($VISITREASON),0))) = "C3")  ;any was selected
	SET visitprompt = BUILD("APPT_SCH_EVENT.APPT_REASON_FREE IN ", visitlist,
		"OR NULLIND(APPT_SCH_EVENT.APPT_REASON_FREE) = 1")   ;006
	CALL ECHO(CONCAT("Visitprompt", CHAR(9), visitprompt))
ELSE 	;single value selected
	SET visititem = BUILD("'",PARAMETER(PARAMETER2($VISITREASON),1),"'")
	SET visitprompt = BUILD("APPT_SCH_EVENT.APPT_REASON_FREE = ", visititem)
ENDIF		;005
 
/**********************************************************
Get Schedule Data
***********************************************************/
CALL ECHO ("Get Schedule Data")
 
SELECT DISTINCT
  Patient = pat.name_full_formatted
  ,DOB = FORMAT(CNVTDATETIMEUTC(pat.birth_dt_tm,1),"MM/DD/YYYY;;d")
  ,AGE_AS_OF_DOS = FLOOR((DATETIMEDIFF(appt_sch_res_appt_all.beg_dt_tm, pat.birth_dt_tm)/365))	;002
  ,Home_Phone = EVALUATE2(IF (SIZE(TRIM(hphone.phone_num,3)) = 10)
  		CONCAT("(",SUBSTRING(1,3,hphone.phone_num),")",SUBSTRING(4,3,hphone.phone_num),"-",SUBSTRING(7,4,hphone.phone_num))
  		ELSE " " ENDIF)
  ,Mobile_Phone = EVALUATE2(IF (SIZE(TRIM(mphone.phone_num,3)) = 10)
  		CONCAT("(",SUBSTRING(1,3,mphone.phone_num),")",SUBSTRING(4,3,mphone.phone_num),"-",SUBSTRING(7,4,mphone.phone_num))
  		ELSE " " ENDIF)  ;002
  ,Insurance = TRIM(ins.org_name,3)
  ,CMRN = TRIM(cmrn.alias,3)
  ,FIN = TRIM(ea.alias,3)
  ,Appt_Date = FORMAT(appt_sch_res_appt_all.beg_dt_tm, "MM/DD/YYYY hh:mm:ss")
  ,Appt_Status = UAR_GET_CODE_DISPLAY(appt_sch_event.sch_state_cd)
  ,Appt_Type = UAR_GET_CODE_DISPLAY(appt_sch_event.appt_type_cd)
  ,Appt_Reminder = sch_event_detail.oe_field_display_value
  ,Visit_Reason = appt_sch_event.appt_reason_free
  ,Resource = appt_res_res_cd_all.description
  ,Facility = cv_appt_res_all_loc_cov.description
FROM PERSON pat
  , (LEFT JOIN PHONE hphone ON (pat.person_id = hphone.parent_entity_id
  		AND hphone.parent_entity_name = 'PERSON'
  		AND hphone.active_ind = 1
  		AND hphone.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  		AND hphone.phone_type_cd = 170 /*Home Phone*/
  		AND hphone.phone_type_seq = 1
  		AND hphone.phone_num_key != ' '
  	))
  , (LEFT JOIN PHONE mphone ON (pat.person_id = mphone.parent_entity_id	;002
  		AND mphone.parent_entity_name = 'PERSON'
  		AND mphone.active_ind = 1
  		AND mphone.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  		AND mphone.phone_type_cd = 4149712.00 /*Mobile Phone*/
  		AND mphone.phone_type_seq = 1
  		AND mphone.phone_num_key != ' '
  	))
  , (INNER JOIN SCH_APPT appt_sch_appt ON (appt_sch_appt.person_id = pat.person_id
  		AND appt_sch_appt.role_meaning = "PATIENT"
  		AND appt_sch_appt.state_meaning != "RESCHEDULED"
  	))
  , (LEFT JOIN ENCOUNTER enc ON (appt_sch_appt.encntr_id=enc.encntr_id		;007
  		AND enc.active_ind = 1
  	))
  , (LEFT JOIN ENCNTR_ALIAS ea ON (ea.encntr_id=enc.encntr_id			;007
		AND ea.active_ind = 1
		AND ea.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND ea.encntr_alias_type_cd = 1077  /*FIN NBR*/
	))
  , (LEFT JOIN PERSON_ALIAS cmrn ON (pat.person_id = cmrn.person_id		;009
  		AND cmrn.active_ind = 1
  		AND cmrn.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  		AND cmrn.person_alias_type_cd = 2 /*CMRN*/
  	))
  , (LEFT JOIN ENCNTR_PLAN_RELTN epr ON (enc.encntr_id = epr.encntr_id	;007
  		AND epr.priority_seq = 1
  		AND epr.active_ind = 1
  		AND epr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3) ;011
		AND epr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)	;011
  	))
  , (LEFT JOIN ORGANIZATION ins ON (ins.organization_id = epr.organization_id 	;007
  	))
  , (INNER JOIN SCH_EVENT appt_sch_event ON (appt_sch_event.sch_event_id = appt_sch_appt.sch_event_id
    ))
  , (LEFT JOIN SCH_EVENT_DETAIL sch_event_detail ON (sch_event_detail.sch_event_id = appt_sch_event.sch_event_id
  		AND sch_event_detail.oe_field_id = 23372832 /*Patient Reminder*/
  		AND sch_event_detail.version_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  	))
  , (LEFT JOIN SCH_APPT appt_sch_res_appt_all ON (appt_sch_res_appt_all.sch_event_id = appt_sch_event.sch_event_id
  	))
  , (LEFT JOIN SCH_RESOURCE appt_sch_resource_all ON (appt_sch_res_appt_all.resource_cd = appt_sch_resource_all.resource_cd
    ))
  , (LEFT JOIN CODE_VALUE appt_res_res_cd_all ON (appt_sch_resource_all.resource_cd = appt_res_res_cd_all.code_value
  		AND appt_res_res_cd_all.code_set = 14231
  	))
  , (LEFT JOIN CODE_VALUE cv_appt_res_all_loc_cov ON (appt_sch_res_appt_all.appt_location_cd = cv_appt_res_all_loc_cov.code_value
  		AND cv_appt_res_all_loc_cov.code_set = 220
		AND cv_appt_res_all_loc_cov.cdf_meaning IN ("AMBULATORY")
	))
  , (LEFT JOIN CODE_VALUE_EXTENSION cve ON (cv_appt_res_all_loc_cov.code_value = cve.code_value
		AND cve.field_name = 'CMG Reporting'
    ))
WHERE pat.active_ind = 1
AND PARSER(facprompt)
AND OPERATOR(appt_res_res_cd_all.code_value, res_opr_var, $RES)
AND OPERATOR(appt_sch_event.sch_state_cd, app_opr_var, $APPTSTATUS)
AND OPERATOR(appt_sch_event.appt_type_cd, appttype_opr_var, $APPTTYPE)	;002
AND PARSER(visitprompt) ;005
AND FLOOR((DATETIMEDIFF(appt_sch_res_appt_all.beg_dt_tm, pat.birth_dt_tm)/365)) >= $AGE	;002
AND FLOOR((DATETIMEDIFF(appt_sch_res_appt_all.beg_dt_tm, pat.birth_dt_tm)/365)) <= $AGE2	;002
AND appt_sch_resource_all.mnemonic_key IS NOT NULL
AND appt_sch_resource_all.mnemonic_key != ' '
AND appt_sch_res_appt_all.slot_state_cd IN (0,9541)
AND pat.name_last_key NOT IN ('FFFFPEDS','FFFFAMB','FFFFPNRC','FFFFOP','FFFFED','FFFFIP','FFFFWH','FFFFTEST','FFFFREVCYCLE',
	'FFFFPHARM','ZZGLOVER','ZZTEST','ZZWICK','ZZBOGUS','ZZZZTESTPW','ZZZREGRESSION','ZZZZBHTEST','ZZZNEUROPW','ZZZFLMCRAD',
	'ZZZFSRRAD','ZZZTESTONE','ZZZAMB','ZZZPWRAD','ZZTOPTEST','ZZZ','ZZZRMCRAD','ZZZZTESTPBH','ZZMDDONOTUSE','ZZZMPITESTP',
	'ZZZRADTEST','ZZZFSRGO','ZZZFSWRAD','ZZZTESTIP','ZZZTEST','ZZELLMER','ZZZMPITESTBL','ZZZZTESTPOC','ZZZZZZTEST','ZZZTESTOP',
	'TTTTTEST','TTTTGENLAB','TTTT','TTTTMAYO','TTTTPHARMTEST','TTTTESTFSV','TTTTONC','TTTTESTCATHLAB','TTURNER','TTEST',
	'TTTTHUDLOW','TTTTTESTFN','TTTTCAMCAPTEST',	'TTTTMDI','TTBACKLOADING','TTTTESTPRVL','TTTTMMC','TTTTQUEST','TTHOMASON',
	'TTTTPRINTER','TTTTEST')
AND appt_sch_res_appt_all.beg_dt_tm BETWEEN CNVTDATETIME($bdate) AND CNVTDATETIME($edate)
 
HEAD REPORT
	cnt = 0
	CALL alterlist(a->qual, 10)
 
DETAIL
	cnt = cnt + 1
	IF (mod(cnt,10) = 1 OR cnt = 1)
		stat = alterlist(a->qual, cnt + 9)
	ENDIF
 
	a->qual[cnt].patient 		= 	patient
	a->qual[cnt].dob			= 	FORMAT(dob, "MM/DD/YYYY")
	a->qual[cnt].age_as_of_dos  =   AGE_AS_OF_DOS		;002
	a->qual[cnt].home_phone	 	=	home_phone
	a->qual[cnt].mobile_phone	=	mobile_phone		;002
	a->qual[cnt].insurance		=	insurance
	a->qual[cnt].cmrn           =   cmrn			;009
	a->qual[cnt].fin			= 	fin
	a->qual[cnt].appt_date		=	appt_date,
	a->qual[cnt].appt_status	=	appt_status
	a->qual[cnt].appt_type		=	appt_type
	a->qual[cnt].appt_reminder	=	appt_reminder
	a->qual[cnt].visit_reason	=	visit_reason
	a->qual[cnt].resource		=	resource
	a->qual[cnt].facility		=	facility
 
FOOT REPORT
	stat = alterlist(a->qual, cnt )
	a->rec_cnt = cnt
WITH nocounter
 
/*********************************************************************
	Summary
**********************************************************************/
/*Appt Status Totals*/
CALL ECHO("Appt Status Totals Summary")
SELECT
	Facility = cv_appt_res_all_loc_cov.description
	,Resource = appt_res_res_cd_all.description
    ,Appt_Type = UAR_GET_CODE_DISPLAY(appt_sch_event.appt_type_cd)
	,Appt_Status = UAR_GET_CODE_DISPLAY(appt_sch_event.sch_state_cd)
	,Total_Counts = COUNT(*)
FROM PERSON pat
  , (LEFT JOIN PHONE hphone ON (pat.person_id = hphone.parent_entity_id
  		AND hphone.parent_entity_name = 'PERSON'
  		AND hphone.active_ind = 1
  		AND hphone.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  		AND hphone.phone_type_cd = 170 /*Home Phone*/
  		AND hphone.phone_type_seq = 1
  		AND hphone.phone_num_key != ' '
  	))
  , (LEFT JOIN PHONE mphone ON (pat.person_id = mphone.parent_entity_id	;002
  		AND mphone.parent_entity_name = 'PERSON'
  		AND mphone.active_ind = 1
  		AND mphone.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  		AND mphone.phone_type_cd = 4149712.00 /*Mobile Phone*/
  		AND mphone.phone_type_seq = 1
  		AND mphone.phone_num_key != ' '
  	))
  , (INNER JOIN SCH_APPT appt_sch_appt ON (appt_sch_appt.person_id = pat.person_id
  		AND appt_sch_appt.role_meaning = "PATIENT"
  		AND appt_sch_appt.state_meaning != "RESCHEDULED"
  	))
  , (INNER JOIN SCH_EVENT appt_sch_event ON (appt_sch_event.sch_event_id = appt_sch_appt.sch_event_id
    ))
  , (LEFT JOIN SCH_EVENT_DETAIL sch_event_detail ON (sch_event_detail.sch_event_id = appt_sch_event.sch_event_id
  		AND sch_event_detail.oe_field_id = 23372832 /*Patient Reminder*/
  		AND sch_event_detail.version_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  	))
  , (LEFT JOIN SCH_APPT appt_sch_res_appt_all ON (appt_sch_res_appt_all.sch_event_id = appt_sch_event.sch_event_id
  	))
  , (LEFT JOIN SCH_RESOURCE appt_sch_resource_all ON (appt_sch_res_appt_all.resource_cd = appt_sch_resource_all.resource_cd
    ))
  , (LEFT JOIN CODE_VALUE appt_res_res_cd_all ON (appt_sch_resource_all.resource_cd = appt_res_res_cd_all.code_value
  		AND appt_res_res_cd_all.code_set = 14231
  	))
  , (LEFT JOIN CODE_VALUE cv_appt_res_all_loc_cov ON (appt_sch_res_appt_all.appt_location_cd = cv_appt_res_all_loc_cov.code_value
  		AND cv_appt_res_all_loc_cov.code_set = 220
		AND cv_appt_res_all_loc_cov.cdf_meaning IN ("AMBULATORY")
	))
  , (LEFT JOIN CODE_VALUE_EXTENSION cve ON (cv_appt_res_all_loc_cov.code_value = cve.code_value
		AND cve.field_name = 'CMG Reporting'
    ))
WHERE pat.active_ind = 1
AND PARSER(facprompt)
AND OPERATOR(appt_res_res_cd_all.code_value, res_opr_var, $RES)
AND OPERATOR(appt_sch_event.sch_state_cd, app_opr_var, $APPTSTATUS)
AND OPERATOR(appt_sch_event.appt_type_cd, appttype_opr_var, $APPTTYPE)	;002
AND PARSER(visitprompt) ;005
AND FLOOR((DATETIMEDIFF(appt_sch_res_appt_all.beg_dt_tm, pat.birth_dt_tm)/365)) >= $AGE	;002
AND FLOOR((DATETIMEDIFF(appt_sch_res_appt_all.beg_dt_tm, pat.birth_dt_tm)/365)) <= $AGE2	;002
AND appt_sch_resource_all.mnemonic_key IS NOT NULL
AND appt_sch_resource_all.mnemonic_key != ' '
AND appt_sch_res_appt_all.slot_state_cd IN (0,9541)
AND pat.name_last_key NOT IN ('FFFFPEDS','FFFFAMB','FFFFPNRC','FFFFOP','FFFFED','FFFFIP','FFFFWH','FFFFTEST','FFFFREVCYCLE',
	'FFFFPHARM','ZZGLOVER','ZZTEST','ZZWICK','ZZBOGUS','ZZZZTESTPW','ZZZREGRESSION','ZZZZBHTEST','ZZZNEUROPW','ZZZFLMCRAD',
	'ZZZFSRRAD','ZZZTESTONE','ZZZAMB','ZZZPWRAD','ZZTOPTEST','ZZZ','ZZZRMCRAD','ZZZZTESTPBH','ZZMDDONOTUSE','ZZZMPITESTP',
	'ZZZRADTEST','ZZZFSRGO','ZZZFSWRAD','ZZZTESTIP','ZZZTEST','ZZELLMER','ZZZMPITESTBL','ZZZZTESTPOC','ZZZZZZTEST','ZZZTESTOP',
	'TTTTTEST','TTTTGENLAB','TTTT','TTTTMAYO','TTTTPHARMTEST','TTTTESTFSV','TTTTONC','TTTTESTCATHLAB','TTURNER','TTEST',
	'TTTTHUDLOW','TTTTTESTFN','TTTTCAMCAPTEST',	'TTTTMDI','TTBACKLOADING','TTTTESTPRVL','TTTTMMC','TTTTQUEST','TTHOMASON',
	'TTTTPRINTER','TTTTEST')
AND appt_sch_res_appt_all.beg_dt_tm BETWEEN CNVTDATETIME($bdate) AND CNVTDATETIME($edate)
GROUP BY cv_appt_res_all_loc_cov.description, appt_res_res_cd_all.description, appt_sch_event.appt_type_cd,
appt_sch_event.sch_state_cd
 
HEAD REPORT
	cnt = 0
	CALL alterlist(totals->qual, 10)
 
DETAIL
	cnt = cnt + 1
	IF (mod(cnt,10) = 1 OR cnt = 1)
		stat = alterlist(totals->qual, cnt + 9)
	ENDIF
 
	totals->qual[cnt].facility 		= 	facility
	totals->qual[cnt].resource		= 	resource
	totals->qual[cnt].appt_type     =   appt_type
	totals->qual[cnt].appt_status 	=	appt_status
	totals->qual[cnt].total_counts	=	total_counts
 
FOOT REPORT
	stat = alterlist(totals->qual, cnt)
	totals->rec_cnt	= cnt
WITH nocounter
 
/*Appt Type Totals*/	;003
CALL ECHO("Appt Type Totals Summary")
SELECT
	Facility = cv_appt_res_all_loc_cov.description
	,Resource = appt_res_res_cd_all.description
    ,Appt_Type = UAR_GET_CODE_DISPLAY(appt_sch_event.appt_type_cd)
	,Total_Counts = COUNT(*)
FROM PERSON pat
  , (LEFT JOIN PHONE hphone ON (pat.person_id = hphone.parent_entity_id
  		AND hphone.parent_entity_name = 'PERSON'
  		AND hphone.active_ind = 1
  		AND hphone.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  		AND hphone.phone_type_cd = 170 /*Home Phone*/
  		AND hphone.phone_type_seq = 1
  		AND hphone.phone_num_key != ' '
  	))
  , (LEFT JOIN PHONE mphone ON (pat.person_id = mphone.parent_entity_id	;002
  		AND mphone.parent_entity_name = 'PERSON'
  		AND mphone.active_ind = 1
  		AND mphone.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  		AND mphone.phone_type_cd = 4149712.00 /*Mobile Phone*/
  		AND mphone.phone_type_seq = 1
  		AND mphone.phone_num_key != ' '
  	))
  , (INNER JOIN SCH_APPT appt_sch_appt ON (appt_sch_appt.person_id = pat.person_id
  		AND appt_sch_appt.role_meaning = "PATIENT"
  		AND appt_sch_appt.state_meaning != "RESCHEDULED"
  	))
  , (INNER JOIN SCH_EVENT appt_sch_event ON (appt_sch_event.sch_event_id = appt_sch_appt.sch_event_id
    ))
  , (LEFT JOIN SCH_EVENT_DETAIL sch_event_detail ON (sch_event_detail.sch_event_id = appt_sch_event.sch_event_id
  		AND sch_event_detail.oe_field_id = 23372832 /*Patient Reminder*/
  		AND sch_event_detail.version_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  	))
  , (LEFT JOIN SCH_APPT appt_sch_res_appt_all ON (appt_sch_res_appt_all.sch_event_id = appt_sch_event.sch_event_id
  	))
  , (LEFT JOIN SCH_RESOURCE appt_sch_resource_all ON (appt_sch_res_appt_all.resource_cd = appt_sch_resource_all.resource_cd
    ))
  , (LEFT JOIN CODE_VALUE appt_res_res_cd_all ON (appt_sch_resource_all.resource_cd = appt_res_res_cd_all.code_value
  		AND appt_res_res_cd_all.code_set = 14231
  	))
  , (LEFT JOIN CODE_VALUE cv_appt_res_all_loc_cov ON (appt_sch_res_appt_all.appt_location_cd = cv_appt_res_all_loc_cov.code_value
  		AND cv_appt_res_all_loc_cov.code_set = 220
		AND cv_appt_res_all_loc_cov.cdf_meaning IN ("AMBULATORY")
	))
  , (LEFT JOIN CODE_VALUE_EXTENSION cve ON (cv_appt_res_all_loc_cov.code_value = cve.code_value
		AND cve.field_name = 'CMG Reporting'
    ))
WHERE pat.active_ind = 1
AND PARSER(facprompt)
AND OPERATOR(appt_res_res_cd_all.code_value, res_opr_var, $RES)
AND OPERATOR(appt_sch_event.sch_state_cd, app_opr_var, $APPTSTATUS)
AND OPERATOR(appt_sch_event.appt_type_cd, appttype_opr_var, $APPTTYPE)	;002
AND PARSER(visitprompt) ;005
AND FLOOR((DATETIMEDIFF(appt_sch_res_appt_all.beg_dt_tm, pat.birth_dt_tm)/365)) >= $AGE	;002
AND FLOOR((DATETIMEDIFF(appt_sch_res_appt_all.beg_dt_tm, pat.birth_dt_tm)/365)) <= $AGE2	;002
AND appt_sch_resource_all.mnemonic_key IS NOT NULL
AND appt_sch_resource_all.mnemonic_key != ' '
AND appt_sch_res_appt_all.slot_state_cd IN (0,9541)
AND pat.name_last_key NOT IN ('FFFFPEDS','FFFFAMB','FFFFPNRC','FFFFOP','FFFFED','FFFFIP','FFFFWH','FFFFTEST','FFFFREVCYCLE',
	'FFFFPHARM','ZZGLOVER','ZZTEST','ZZWICK','ZZBOGUS','ZZZZTESTPW','ZZZREGRESSION','ZZZZBHTEST','ZZZNEUROPW','ZZZFLMCRAD',
	'ZZZFSRRAD','ZZZTESTONE','ZZZAMB','ZZZPWRAD','ZZTOPTEST','ZZZ','ZZZRMCRAD','ZZZZTESTPBH','ZZMDDONOTUSE','ZZZMPITESTP',
	'ZZZRADTEST','ZZZFSRGO','ZZZFSWRAD','ZZZTESTIP','ZZZTEST','ZZELLMER','ZZZMPITESTBL','ZZZZTESTPOC','ZZZZZZTEST','ZZZTESTOP',
	'TTTTTEST','TTTTGENLAB','TTTT','TTTTMAYO','TTTTPHARMTEST','TTTTESTFSV','TTTTONC','TTTTESTCATHLAB','TTURNER','TTEST',
	'TTTTHUDLOW','TTTTTESTFN','TTTTCAMCAPTEST',	'TTTTMDI','TTBACKLOADING','TTTTESTPRVL','TTTTMMC','TTTTQUEST','TTHOMASON',
	'TTTTPRINTER','TTTTEST')
AND appt_sch_res_appt_all.beg_dt_tm BETWEEN CNVTDATETIME($bdate) AND CNVTDATETIME($edate)
GROUP BY cv_appt_res_all_loc_cov.description, appt_res_res_cd_all.description, appt_sch_event.appt_type_cd
 
HEAD REPORT
	cnt = totals->rec_cnt
 
 	IF(mod(cnt,10)> 0)
   		CALL alterlist(totals->qual, cnt + (10-mod(cnt,10)))
	ENDIF
 
DETAIL
	cnt = cnt + 1
	IF (mod(cnt,10) = 1 OR cnt = 1)
		stat = alterlist(totals->qual, cnt + 9)
	ENDIF
 
	totals->qual[cnt].facility 		= 	facility
	totals->qual[cnt].resource		= 	resource
	totals->qual[cnt].appt_type     =   appt_type
	totals->qual[cnt].appt_status 	=	"Totals"
	totals->qual[cnt].total_counts	=	total_counts
 
FOOT REPORT
	stat = alterlist(totals->qual, cnt)
	totals->rec_cnt	= cnt
WITH nocounter
 
/* Resource Totals */
CALL ECHO("Resource Totals Summary")
SELECT
	Facility = cv_appt_res_all_loc_cov.description
	,Resource = appt_res_res_cd_all.description
	,Total_Counts = COUNT(*)
FROM PERSON pat
  , (LEFT JOIN PHONE hphone ON (pat.person_id = hphone.parent_entity_id
  		AND hphone.parent_entity_name = 'PERSON'
  		AND hphone.active_ind = 1
  		AND hphone.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  		AND hphone.phone_type_cd = 170 /*Home Phone*/
  		AND hphone.phone_type_seq = 1
  		AND hphone.phone_num_key != ' '
  	))
  , (LEFT JOIN PHONE mphone ON (pat.person_id = mphone.parent_entity_id	;002
  		AND mphone.parent_entity_name = 'PERSON'
  		AND mphone.active_ind = 1
  		AND mphone.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  		AND mphone.phone_type_cd = 4149712.00 /*Mobile Phone*/
  		AND mphone.phone_type_seq = 1
  		AND mphone.phone_num_key != ' '
  	))
  , (INNER JOIN SCH_APPT appt_sch_appt ON (appt_sch_appt.person_id = pat.person_id
  		AND appt_sch_appt.role_meaning = "PATIENT"
  		AND appt_sch_appt.state_meaning != "RESCHEDULED"
  	))
  , (INNER JOIN SCH_EVENT appt_sch_event ON (appt_sch_event.sch_event_id = appt_sch_appt.sch_event_id
    ))
  , (LEFT JOIN SCH_EVENT_DETAIL sch_event_detail ON (sch_event_detail.sch_event_id = appt_sch_event.sch_event_id
  		AND sch_event_detail.oe_field_id = 23372832 /*Patient Reminder*/
  		AND sch_event_detail.version_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  	))
  , (LEFT JOIN SCH_APPT appt_sch_res_appt_all ON (appt_sch_res_appt_all.sch_event_id = appt_sch_event.sch_event_id
  	))
  , (LEFT JOIN SCH_RESOURCE appt_sch_resource_all ON (appt_sch_res_appt_all.resource_cd = appt_sch_resource_all.resource_cd
    ))
  , (LEFT JOIN CODE_VALUE appt_res_res_cd_all ON (appt_sch_resource_all.resource_cd = appt_res_res_cd_all.code_value
  		AND appt_res_res_cd_all.code_set = 14231
  	))
  , (LEFT JOIN CODE_VALUE cv_appt_res_all_loc_cov ON (appt_sch_res_appt_all.appt_location_cd = cv_appt_res_all_loc_cov.code_value
  		AND cv_appt_res_all_loc_cov.code_set = 220
		AND cv_appt_res_all_loc_cov.cdf_meaning IN ("AMBULATORY")
	))
  , (LEFT JOIN CODE_VALUE_EXTENSION cve ON (cv_appt_res_all_loc_cov.code_value = cve.code_value
		AND cve.field_name = 'CMG Reporting'
    ))
WHERE pat.active_ind = 1
AND PARSER(facprompt)
AND OPERATOR(appt_res_res_cd_all.code_value, res_opr_var, $RES)
AND OPERATOR(appt_sch_event.sch_state_cd, app_opr_var, $APPTSTATUS)
AND OPERATOR(appt_sch_event.appt_type_cd, appttype_opr_var, $APPTTYPE)	;002
AND PARSER(visitprompt) ;005
AND FLOOR((DATETIMEDIFF(appt_sch_res_appt_all.beg_dt_tm, pat.birth_dt_tm)/365)) >= $AGE	;002
AND FLOOR((DATETIMEDIFF(appt_sch_res_appt_all.beg_dt_tm, pat.birth_dt_tm)/365)) <= $AGE2	;002
AND appt_sch_resource_all.mnemonic_key IS NOT NULL
AND appt_sch_resource_all.mnemonic_key != ' '
AND appt_sch_res_appt_all.slot_state_cd IN (0,9541)
AND pat.name_last_key NOT IN ('FFFFPEDS','FFFFAMB','FFFFPNRC','FFFFOP','FFFFED','FFFFIP','FFFFWH','FFFFTEST','FFFFREVCYCLE',
	'FFFFPHARM','ZZGLOVER','ZZTEST','ZZWICK','ZZBOGUS','ZZZZTESTPW','ZZZREGRESSION','ZZZZBHTEST','ZZZNEUROPW','ZZZFLMCRAD',
	'ZZZFSRRAD','ZZZTESTONE','ZZZAMB','ZZZPWRAD','ZZTOPTEST','ZZZ','ZZZRMCRAD','ZZZZTESTPBH','ZZMDDONOTUSE','ZZZMPITESTP',
	'ZZZRADTEST','ZZZFSRGO','ZZZFSWRAD','ZZZTESTIP','ZZZTEST','ZZELLMER','ZZZMPITESTBL','ZZZZTESTPOC','ZZZZZZTEST','ZZZTESTOP',
	'TTTTTEST','TTTTGENLAB','TTTT','TTTTMAYO','TTTTPHARMTEST','TTTTESTFSV','TTTTONC','TTTTESTCATHLAB','TTURNER','TTEST',
	'TTTTHUDLOW','TTTTTESTFN','TTTTCAMCAPTEST',	'TTTTMDI','TTBACKLOADING','TTTTESTPRVL','TTTTMMC','TTTTQUEST','TTHOMASON',
	'TTTTPRINTER','TTTTEST')
AND appt_sch_res_appt_all.beg_dt_tm BETWEEN CNVTDATETIME($bdate) AND CNVTDATETIME($edate)
GROUP BY cv_appt_res_all_loc_cov.description, appt_res_res_cd_all.description
 
HEAD REPORT
	cnt = totals->rec_cnt
 
 	IF(mod(cnt,10)> 0)
   		CALL alterlist(totals->qual, cnt + (10-mod(cnt,10)))
	ENDIF
 
DETAIL
	cnt = cnt + 1
	IF (mod(cnt,10) = 1 OR cnt = 1)
		stat = alterlist(totals->qual, cnt + 9)
	ENDIF
 
	totals->qual[cnt].facility 		= 	facility
	totals->qual[cnt].resource		= 	resource
	totals->qual[cnt].appt_type     =   "zzzTotals"
	totals->qual[cnt].appt_status 	=	"Resource Totals"
	totals->qual[cnt].total_counts	=	total_counts
 
FOOT REPORT
	stat = alterlist(totals->qual, cnt)
	totals->rec_cnt	= cnt
WITH nocounter
 
/* Facility Totals */
CALL ECHO("Facility Totals Summary")
SELECT
	Facility = cv_appt_res_all_loc_cov.description
	,Total_Counts = COUNT(*)
FROM PERSON pat
  , (LEFT JOIN PHONE hphone ON (pat.person_id = hphone.parent_entity_id
  		AND hphone.parent_entity_name = 'PERSON'
  		AND hphone.active_ind = 1
  		AND hphone.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  		AND hphone.phone_type_cd = 170 /*Home Phone*/
  		AND hphone.phone_type_seq = 1
  		AND hphone.phone_num_key != ' '
  	))
  , (LEFT JOIN PHONE mphone ON (pat.person_id = mphone.parent_entity_id	;002
  		AND mphone.parent_entity_name = 'PERSON'
  		AND mphone.active_ind = 1
  		AND mphone.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  		AND mphone.phone_type_cd = 4149712.00 /*Mobile Phone*/
  		AND mphone.phone_type_seq = 1
  		AND mphone.phone_num_key != ' '
  	))
  , (INNER JOIN SCH_APPT appt_sch_appt ON (appt_sch_appt.person_id = pat.person_id
  		AND appt_sch_appt.role_meaning = "PATIENT"
  		AND appt_sch_appt.state_meaning != "RESCHEDULED"
  	))
  , (INNER JOIN SCH_EVENT appt_sch_event ON (appt_sch_event.sch_event_id = appt_sch_appt.sch_event_id
    ))
  , (LEFT JOIN SCH_EVENT_DETAIL sch_event_detail ON (sch_event_detail.sch_event_id = appt_sch_event.sch_event_id
  		AND sch_event_detail.oe_field_id = 23372832 /*Patient Reminder*/
  		AND sch_event_detail.version_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  	))
  , (LEFT JOIN SCH_APPT appt_sch_res_appt_all ON (appt_sch_res_appt_all.sch_event_id = appt_sch_event.sch_event_id
  	))
  , (LEFT JOIN SCH_RESOURCE appt_sch_resource_all ON (appt_sch_res_appt_all.resource_cd = appt_sch_resource_all.resource_cd
    ))
  , (LEFT JOIN CODE_VALUE appt_res_res_cd_all ON (appt_sch_resource_all.resource_cd = appt_res_res_cd_all.code_value
  		AND appt_res_res_cd_all.code_set = 14231
  	))
  , (LEFT JOIN CODE_VALUE cv_appt_res_all_loc_cov ON (appt_sch_res_appt_all.appt_location_cd = cv_appt_res_all_loc_cov.code_value
  		AND cv_appt_res_all_loc_cov.code_set = 220
		AND cv_appt_res_all_loc_cov.cdf_meaning IN ("AMBULATORY")
	))
  , (LEFT JOIN CODE_VALUE_EXTENSION cve ON (cv_appt_res_all_loc_cov.code_value = cve.code_value
		AND cve.field_name = 'CMG Reporting'
    ))
WHERE pat.active_ind = 1
AND PARSER(facprompt)
AND OPERATOR(appt_res_res_cd_all.code_value, res_opr_var, $RES)
AND OPERATOR(appt_sch_event.sch_state_cd, app_opr_var, $APPTSTATUS)
AND OPERATOR(appt_sch_event.appt_type_cd, appttype_opr_var, $APPTTYPE)	;002
AND PARSER(visitprompt) ;005
AND FLOOR((DATETIMEDIFF(appt_sch_res_appt_all.beg_dt_tm, pat.birth_dt_tm)/365)) >= $AGE	;002
AND FLOOR((DATETIMEDIFF(appt_sch_res_appt_all.beg_dt_tm, pat.birth_dt_tm)/365)) <= $AGE2	;002
AND appt_sch_resource_all.mnemonic_key IS NOT NULL
AND appt_sch_resource_all.mnemonic_key != ' '
AND appt_sch_res_appt_all.slot_state_cd IN (0,9541)
AND pat.name_last_key NOT IN ('FFFFPEDS','FFFFAMB','FFFFPNRC','FFFFOP','FFFFED','FFFFIP','FFFFWH','FFFFTEST','FFFFREVCYCLE',
	'FFFFPHARM','ZZGLOVER','ZZTEST','ZZWICK','ZZBOGUS','ZZZZTESTPW','ZZZREGRESSION','ZZZZBHTEST','ZZZNEUROPW','ZZZFLMCRAD',
	'ZZZFSRRAD','ZZZTESTONE','ZZZAMB','ZZZPWRAD','ZZTOPTEST','ZZZ','ZZZRMCRAD','ZZZZTESTPBH','ZZMDDONOTUSE','ZZZMPITESTP',
	'ZZZRADTEST','ZZZFSRGO','ZZZFSWRAD','ZZZTESTIP','ZZZTEST','ZZELLMER','ZZZMPITESTBL','ZZZZTESTPOC','ZZZZZZTEST','ZZZTESTOP',
	'TTTTTEST','TTTTGENLAB','TTTT','TTTTMAYO','TTTTPHARMTEST','TTTTESTFSV','TTTTONC','TTTTESTCATHLAB','TTURNER','TTEST',
	'TTTTHUDLOW','TTTTTESTFN','TTTTCAMCAPTEST',	'TTTTMDI','TTBACKLOADING','TTTTESTPRVL','TTTTMMC','TTTTQUEST','TTHOMASON',
	'TTTTPRINTER','TTTTEST')
AND appt_sch_res_appt_all.beg_dt_tm BETWEEN CNVTDATETIME($bdate) AND CNVTDATETIME($edate)
GROUP BY cv_appt_res_all_loc_cov.description
 
HEAD REPORT
	cnt = totals->rec_cnt
	IF(mod(cnt,10)> 0)
   		CALL alterlist(totals->qual, cnt + (10-mod(cnt,10)))
	ENDIF
 
DETAIL
	cnt = cnt + 1
	IF (mod(cnt,10) = 1 OR cnt = 1)
		stat = alterlist(totals->qual, cnt + 9)
	ENDIF
 
	totals->qual[cnt].facility 		= 	facility
	totals->qual[cnt].resource		= 	"zzzTotals"
	totals->qual[cnt].appt_type     =   "zzzTotals"
	totals->qual[cnt].appt_status 	=	"Facility Totals"
	totals->qual[cnt].total_counts	=	total_counts
 
FOOT REPORT
	stat = alterlist(totals->qual, cnt)
	totals->rec_cnt	= cnt
WITH nocounter
 
/*********************************************************************
	Summary Distinct Patients	;003
**********************************************************************/
/*Appt Status Totals*/
CALL ECHO("Appt Status Distinct Totals Summary")
SELECT
	Facility = cv_appt_res_all_loc_cov.description
	,Resource = appt_res_res_cd_all.description
    ,Appt_Type = UAR_GET_CODE_DISPLAY(appt_sch_event.appt_type_cd)
	,Appt_Status = UAR_GET_CODE_DISPLAY(appt_sch_event.sch_state_cd)
	,Total_Counts = COUNT(DISTINCT pat.person_id)
FROM PERSON pat
  , (LEFT JOIN PHONE hphone ON (pat.person_id = hphone.parent_entity_id
  		AND hphone.parent_entity_name = 'PERSON'
  		AND hphone.active_ind = 1
  		AND hphone.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  		AND hphone.phone_type_cd = 170 /*Home Phone*/
  		AND hphone.phone_type_seq = 1
  		AND hphone.phone_num_key != ' '
  	))
  , (LEFT JOIN PHONE mphone ON (pat.person_id = mphone.parent_entity_id	;002
  		AND mphone.parent_entity_name = 'PERSON'
  		AND mphone.active_ind = 1
  		AND mphone.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  		AND mphone.phone_type_cd = 4149712.00 /*Mobile Phone*/
  		AND mphone.phone_type_seq = 1
  		AND mphone.phone_num_key != ' '
  	))
  , (INNER JOIN SCH_APPT appt_sch_appt ON (appt_sch_appt.person_id = pat.person_id
  		AND appt_sch_appt.role_meaning = "PATIENT"
  		AND appt_sch_appt.state_meaning != "RESCHEDULED"
  	))
  , (INNER JOIN SCH_EVENT appt_sch_event ON (appt_sch_event.sch_event_id = appt_sch_appt.sch_event_id
    ))
  , (LEFT JOIN SCH_EVENT_DETAIL sch_event_detail ON (sch_event_detail.sch_event_id = appt_sch_event.sch_event_id
  		AND sch_event_detail.oe_field_id = 23372832 /*Patient Reminder*/
  		AND sch_event_detail.version_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  	))
  , (LEFT JOIN SCH_APPT appt_sch_res_appt_all ON (appt_sch_res_appt_all.sch_event_id = appt_sch_event.sch_event_id
  	))
  , (LEFT JOIN SCH_RESOURCE appt_sch_resource_all ON (appt_sch_res_appt_all.resource_cd = appt_sch_resource_all.resource_cd
    ))
  , (LEFT JOIN CODE_VALUE appt_res_res_cd_all ON (appt_sch_resource_all.resource_cd = appt_res_res_cd_all.code_value
  		AND appt_res_res_cd_all.code_set = 14231
  	))
  , (LEFT JOIN CODE_VALUE cv_appt_res_all_loc_cov ON (appt_sch_res_appt_all.appt_location_cd = cv_appt_res_all_loc_cov.code_value
  		AND cv_appt_res_all_loc_cov.code_set = 220
		AND cv_appt_res_all_loc_cov.cdf_meaning IN ("AMBULATORY")
	))
  , (LEFT JOIN CODE_VALUE_EXTENSION cve ON (cv_appt_res_all_loc_cov.code_value = cve.code_value
		AND cve.field_name = 'CMG Reporting'
    ))
WHERE pat.active_ind = 1
AND PARSER(facprompt)
AND OPERATOR(appt_res_res_cd_all.code_value, res_opr_var, $RES)
AND OPERATOR(appt_sch_event.sch_state_cd, app_opr_var, $APPTSTATUS)
AND OPERATOR(appt_sch_event.appt_type_cd, appttype_opr_var, $APPTTYPE)	;002
AND PARSER(visitprompt) ;005
AND FLOOR((DATETIMEDIFF(appt_sch_res_appt_all.beg_dt_tm, pat.birth_dt_tm)/365)) >= $AGE	;002
AND FLOOR((DATETIMEDIFF(appt_sch_res_appt_all.beg_dt_tm, pat.birth_dt_tm)/365)) <= $AGE2	;002
AND appt_sch_resource_all.mnemonic_key IS NOT NULL
AND appt_sch_resource_all.mnemonic_key != ' '
AND appt_sch_res_appt_all.slot_state_cd IN (0,9541)
AND pat.name_last_key NOT IN ('FFFFPEDS','FFFFAMB','FFFFPNRC','FFFFOP','FFFFED','FFFFIP','FFFFWH','FFFFTEST','FFFFREVCYCLE',
	'FFFFPHARM','ZZGLOVER','ZZTEST','ZZWICK','ZZBOGUS','ZZZZTESTPW','ZZZREGRESSION','ZZZZBHTEST','ZZZNEUROPW','ZZZFLMCRAD',
	'ZZZFSRRAD','ZZZTESTONE','ZZZAMB','ZZZPWRAD','ZZTOPTEST','ZZZ','ZZZRMCRAD','ZZZZTESTPBH','ZZMDDONOTUSE','ZZZMPITESTP',
	'ZZZRADTEST','ZZZFSRGO','ZZZFSWRAD','ZZZTESTIP','ZZZTEST','ZZELLMER','ZZZMPITESTBL','ZZZZTESTPOC','ZZZZZZTEST','ZZZTESTOP',
	'TTTTTEST','TTTTGENLAB','TTTT','TTTTMAYO','TTTTPHARMTEST','TTTTESTFSV','TTTTONC','TTTTESTCATHLAB','TTURNER','TTEST',
	'TTTTHUDLOW','TTTTTESTFN','TTTTCAMCAPTEST',	'TTTTMDI','TTBACKLOADING','TTTTESTPRVL','TTTTMMC','TTTTQUEST','TTHOMASON',
	'TTTTPRINTER','TTTTEST')
AND appt_sch_res_appt_all.beg_dt_tm BETWEEN CNVTDATETIME($bdate) AND CNVTDATETIME($edate)
GROUP BY cv_appt_res_all_loc_cov.description, appt_res_res_cd_all.description, appt_sch_event.appt_type_cd,
appt_sch_event.sch_state_cd
 
HEAD REPORT
	cnt = 0
	CALL alterlist(totalsd->qual, 10)
 
DETAIL
	cnt = cnt + 1
	IF (mod(cnt,10) = 1 OR cnt = 1)
		stat = alterlist(totalsd->qual, cnt + 9)
	ENDIF
 
	totalsd->qual[cnt].facility 	= 	facility
	totalsd->qual[cnt].resource		= 	resource
	totalsd->qual[cnt].appt_type    =   appt_type
	totalsd->qual[cnt].appt_status 	=	appt_status
	totalsd->qual[cnt].total_counts	=	total_counts
 
FOOT REPORT
	stat = alterlist(totalsd->qual, cnt)
	totalsd->rec_cnt	= cnt
WITH nocounter
 
/*Appt Type Totals*/
CALL ECHO("Appt Type Distinct Totals Summary")
SELECT
	Facility = cv_appt_res_all_loc_cov.description
	,Resource = appt_res_res_cd_all.description
    ,Appt_Type = UAR_GET_CODE_DISPLAY(appt_sch_event.appt_type_cd)
	,Total_Counts = COUNT(DISTINCT pat.person_id)
FROM PERSON pat
  , (LEFT JOIN PHONE hphone ON (pat.person_id = hphone.parent_entity_id
  		AND hphone.parent_entity_name = 'PERSON'
  		AND hphone.active_ind = 1
  		AND hphone.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  		AND hphone.phone_type_cd = 170 /*Home Phone*/
  		AND hphone.phone_type_seq = 1
  		AND hphone.phone_num_key != ' '
  	))
  , (LEFT JOIN PHONE mphone ON (pat.person_id = mphone.parent_entity_id	;002
  		AND mphone.parent_entity_name = 'PERSON'
  		AND mphone.active_ind = 1
  		AND mphone.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  		AND mphone.phone_type_cd = 4149712.00 /*Mobile Phone*/
  		AND mphone.phone_type_seq = 1
  		AND mphone.phone_num_key != ' '
  	))
  , (INNER JOIN SCH_APPT appt_sch_appt ON (appt_sch_appt.person_id = pat.person_id
  		AND appt_sch_appt.role_meaning = "PATIENT"
  		AND appt_sch_appt.state_meaning != "RESCHEDULED"
  	))
  , (INNER JOIN SCH_EVENT appt_sch_event ON (appt_sch_event.sch_event_id = appt_sch_appt.sch_event_id
    ))
  , (LEFT JOIN SCH_EVENT_DETAIL sch_event_detail ON (sch_event_detail.sch_event_id = appt_sch_event.sch_event_id
  		AND sch_event_detail.oe_field_id = 23372832 /*Patient Reminder*/
  		AND sch_event_detail.version_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  	))
  , (LEFT JOIN SCH_APPT appt_sch_res_appt_all ON (appt_sch_res_appt_all.sch_event_id = appt_sch_event.sch_event_id
  	))
  , (LEFT JOIN SCH_RESOURCE appt_sch_resource_all ON (appt_sch_res_appt_all.resource_cd = appt_sch_resource_all.resource_cd
    ))
  , (LEFT JOIN CODE_VALUE appt_res_res_cd_all ON (appt_sch_resource_all.resource_cd = appt_res_res_cd_all.code_value
  		AND appt_res_res_cd_all.code_set = 14231
  	))
  , (LEFT JOIN CODE_VALUE cv_appt_res_all_loc_cov ON (appt_sch_res_appt_all.appt_location_cd = cv_appt_res_all_loc_cov.code_value
  		AND cv_appt_res_all_loc_cov.code_set = 220
		AND cv_appt_res_all_loc_cov.cdf_meaning IN ("AMBULATORY")
	))
  , (LEFT JOIN CODE_VALUE_EXTENSION cve ON (cv_appt_res_all_loc_cov.code_value = cve.code_value
		AND cve.field_name = 'CMG Reporting'
    ))
WHERE pat.active_ind = 1
AND PARSER(facprompt)
AND OPERATOR(appt_res_res_cd_all.code_value, res_opr_var, $RES)
AND OPERATOR(appt_sch_event.sch_state_cd, app_opr_var, $APPTSTATUS)
AND OPERATOR(appt_sch_event.appt_type_cd, appttype_opr_var, $APPTTYPE)	;002
AND PARSER(visitprompt) ;005
AND FLOOR((DATETIMEDIFF(appt_sch_res_appt_all.beg_dt_tm, pat.birth_dt_tm)/365)) >= $AGE	;002
AND FLOOR((DATETIMEDIFF(appt_sch_res_appt_all.beg_dt_tm, pat.birth_dt_tm)/365)) <= $AGE2	;002
AND appt_sch_resource_all.mnemonic_key IS NOT NULL
AND appt_sch_resource_all.mnemonic_key != ' '
AND appt_sch_res_appt_all.slot_state_cd IN (0,9541)
AND pat.name_last_key NOT IN ('FFFFPEDS','FFFFAMB','FFFFPNRC','FFFFOP','FFFFED','FFFFIP','FFFFWH','FFFFTEST','FFFFREVCYCLE',
	'FFFFPHARM','ZZGLOVER','ZZTEST','ZZWICK','ZZBOGUS','ZZZZTESTPW','ZZZREGRESSION','ZZZZBHTEST','ZZZNEUROPW','ZZZFLMCRAD',
	'ZZZFSRRAD','ZZZTESTONE','ZZZAMB','ZZZPWRAD','ZZTOPTEST','ZZZ','ZZZRMCRAD','ZZZZTESTPBH','ZZMDDONOTUSE','ZZZMPITESTP',
	'ZZZRADTEST','ZZZFSRGO','ZZZFSWRAD','ZZZTESTIP','ZZZTEST','ZZELLMER','ZZZMPITESTBL','ZZZZTESTPOC','ZZZZZZTEST','ZZZTESTOP',
	'TTTTTEST','TTTTGENLAB','TTTT','TTTTMAYO','TTTTPHARMTEST','TTTTESTFSV','TTTTONC','TTTTESTCATHLAB','TTURNER','TTEST',
	'TTTTHUDLOW','TTTTTESTFN','TTTTCAMCAPTEST',	'TTTTMDI','TTBACKLOADING','TTTTESTPRVL','TTTTMMC','TTTTQUEST','TTHOMASON',
	'TTTTPRINTER','TTTTEST')
AND appt_sch_res_appt_all.beg_dt_tm BETWEEN CNVTDATETIME($bdate) AND CNVTDATETIME($edate)
GROUP BY cv_appt_res_all_loc_cov.description, appt_res_res_cd_all.description, appt_sch_event.appt_type_cd
 
HEAD REPORT
	cnt = totalsd->rec_cnt
 
 	IF(mod(cnt,10)> 0)
   		CALL alterlist(totalsd->qual, cnt + (10-mod(cnt,10)))
	ENDIF
 
DETAIL
	cnt = cnt + 1
	IF (mod(cnt,10) = 1 OR cnt = 1)
		stat = alterlist(totalsd->qual, cnt + 9)
	ENDIF
 
	totalsd->qual[cnt].facility 	= 	facility
	totalsd->qual[cnt].resource		= 	resource
	totalsd->qual[cnt].appt_type    =   appt_type
	totalsd->qual[cnt].appt_status 	=	"Totals"
	totalsd->qual[cnt].total_counts	=	total_counts
 
FOOT REPORT
	stat = alterlist(totalsd->qual, cnt)
	totalsd->rec_cnt	= cnt
WITH nocounter
 
/* Resource Totals */
CALL ECHO("Resource Distinct Totals Summary")
SELECT
	Facility = cv_appt_res_all_loc_cov.description
	,Resource = appt_res_res_cd_all.description
	,Total_Counts = COUNT(DISTINCT pat.person_id)
FROM PERSON pat
  , (LEFT JOIN PHONE hphone ON (pat.person_id = hphone.parent_entity_id
  		AND hphone.parent_entity_name = 'PERSON'
  		AND hphone.active_ind = 1
  		AND hphone.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  		AND hphone.phone_type_cd = 170 /*Home Phone*/
  		AND hphone.phone_type_seq = 1
  		AND hphone.phone_num_key != ' '
  	))
  , (LEFT JOIN PHONE mphone ON (pat.person_id = mphone.parent_entity_id	;002
  		AND mphone.parent_entity_name = 'PERSON'
  		AND mphone.active_ind = 1
  		AND mphone.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  		AND mphone.phone_type_cd = 4149712.00 /*Mobile Phone*/
  		AND mphone.phone_type_seq = 1
  		AND mphone.phone_num_key != ' '
  	))
  , (INNER JOIN SCH_APPT appt_sch_appt ON (appt_sch_appt.person_id = pat.person_id
  		AND appt_sch_appt.role_meaning = "PATIENT"
  		AND appt_sch_appt.state_meaning != "RESCHEDULED"
  	))
  , (INNER JOIN SCH_EVENT appt_sch_event ON (appt_sch_event.sch_event_id = appt_sch_appt.sch_event_id
    ))
  , (LEFT JOIN SCH_EVENT_DETAIL sch_event_detail ON (sch_event_detail.sch_event_id = appt_sch_event.sch_event_id
  		AND sch_event_detail.oe_field_id = 23372832 /*Patient Reminder*/
  		AND sch_event_detail.version_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  	))
  , (LEFT JOIN SCH_APPT appt_sch_res_appt_all ON (appt_sch_res_appt_all.sch_event_id = appt_sch_event.sch_event_id
  	))
  , (LEFT JOIN SCH_RESOURCE appt_sch_resource_all ON (appt_sch_res_appt_all.resource_cd = appt_sch_resource_all.resource_cd
    ))
  , (LEFT JOIN CODE_VALUE appt_res_res_cd_all ON (appt_sch_resource_all.resource_cd = appt_res_res_cd_all.code_value
  		AND appt_res_res_cd_all.code_set = 14231
  	))
  , (LEFT JOIN CODE_VALUE cv_appt_res_all_loc_cov ON (appt_sch_res_appt_all.appt_location_cd = cv_appt_res_all_loc_cov.code_value
  		AND cv_appt_res_all_loc_cov.code_set = 220
		AND cv_appt_res_all_loc_cov.cdf_meaning IN ("AMBULATORY")
	))
  , (LEFT JOIN CODE_VALUE_EXTENSION cve ON (cv_appt_res_all_loc_cov.code_value = cve.code_value
		AND cve.field_name = 'CMG Reporting'
    ))
WHERE pat.active_ind = 1
AND PARSER(facprompt)
AND OPERATOR(appt_res_res_cd_all.code_value, res_opr_var, $RES)
AND OPERATOR(appt_sch_event.sch_state_cd, app_opr_var, $APPTSTATUS)
AND OPERATOR(appt_sch_event.appt_type_cd, appttype_opr_var, $APPTTYPE)	;002
AND PARSER(visitprompt) ;005
AND FLOOR((DATETIMEDIFF(appt_sch_res_appt_all.beg_dt_tm, pat.birth_dt_tm)/365)) >= $AGE	;002
AND FLOOR((DATETIMEDIFF(appt_sch_res_appt_all.beg_dt_tm, pat.birth_dt_tm)/365)) <= $AGE2	;002
AND appt_sch_resource_all.mnemonic_key IS NOT NULL
AND appt_sch_resource_all.mnemonic_key != ' '
AND appt_sch_res_appt_all.slot_state_cd IN (0,9541)
AND pat.name_last_key NOT IN ('FFFFPEDS','FFFFAMB','FFFFPNRC','FFFFOP','FFFFED','FFFFIP','FFFFWH','FFFFTEST','FFFFREVCYCLE',
	'FFFFPHARM','ZZGLOVER','ZZTEST','ZZWICK','ZZBOGUS','ZZZZTESTPW','ZZZREGRESSION','ZZZZBHTEST','ZZZNEUROPW','ZZZFLMCRAD',
	'ZZZFSRRAD','ZZZTESTONE','ZZZAMB','ZZZPWRAD','ZZTOPTEST','ZZZ','ZZZRMCRAD','ZZZZTESTPBH','ZZMDDONOTUSE','ZZZMPITESTP',
	'ZZZRADTEST','ZZZFSRGO','ZZZFSWRAD','ZZZTESTIP','ZZZTEST','ZZELLMER','ZZZMPITESTBL','ZZZZTESTPOC','ZZZZZZTEST','ZZZTESTOP',
	'TTTTTEST','TTTTGENLAB','TTTT','TTTTMAYO','TTTTPHARMTEST','TTTTESTFSV','TTTTONC','TTTTESTCATHLAB','TTURNER','TTEST',
	'TTTTHUDLOW','TTTTTESTFN','TTTTCAMCAPTEST',	'TTTTMDI','TTBACKLOADING','TTTTESTPRVL','TTTTMMC','TTTTQUEST','TTHOMASON',
	'TTTTPRINTER','TTTTEST')
AND appt_sch_res_appt_all.beg_dt_tm BETWEEN CNVTDATETIME($bdate) AND CNVTDATETIME($edate)
GROUP BY cv_appt_res_all_loc_cov.description, appt_res_res_cd_all.description
 
 
HEAD REPORT
	cnt = totalsd->rec_cnt
 
 	IF(mod(cnt,10)> 0)
   		CALL alterlist(totalsd->qual, cnt + (10-mod(cnt,10)))
	ENDIF
 
DETAIL
	cnt = cnt + 1
	IF (mod(cnt,10) = 1 OR cnt = 1)
		stat = alterlist(totalsd->qual, cnt + 9)
	ENDIF
 
	totalsd->qual[cnt].facility 	= 	facility
	totalsd->qual[cnt].resource		= 	resource
	totalsd->qual[cnt].appt_type    =   "zzzTotals"
	totalsd->qual[cnt].appt_status 	=	"Resource Totals"
	totalsd->qual[cnt].total_counts	=	total_counts
 
FOOT REPORT
	stat = alterlist(totalsd->qual, cnt)
	totalsd->rec_cnt	= cnt
WITH nocounter
 
/* Facility Totals */
CALL ECHO("Facility Distinct Totals Summary")
SELECT
	Facility = cv_appt_res_all_loc_cov.description
	,Total_Counts = COUNT(DISTINCT pat.person_id)
FROM PERSON pat
  , (LEFT JOIN PHONE hphone ON (pat.person_id = hphone.parent_entity_id
  		AND hphone.parent_entity_name = 'PERSON'
  		AND hphone.active_ind = 1
  		AND hphone.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  		AND hphone.phone_type_cd = 170 /*Home Phone*/
  		AND hphone.phone_type_seq = 1
  		AND hphone.phone_num_key != ' '
  	))
  , (LEFT JOIN PHONE mphone ON (pat.person_id = mphone.parent_entity_id	;002
  		AND mphone.parent_entity_name = 'PERSON'
  		AND mphone.active_ind = 1
  		AND mphone.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  		AND mphone.phone_type_cd = 4149712.00 /*Mobile Phone*/
  		AND mphone.phone_type_seq = 1
  		AND mphone.phone_num_key != ' '
  	))
  , (INNER JOIN SCH_APPT appt_sch_appt ON (appt_sch_appt.person_id = pat.person_id
  		AND appt_sch_appt.role_meaning = "PATIENT"
  		AND appt_sch_appt.state_meaning != "RESCHEDULED"
  	))
  , (INNER JOIN SCH_EVENT appt_sch_event ON (appt_sch_event.sch_event_id = appt_sch_appt.sch_event_id
    ))
  , (LEFT JOIN SCH_EVENT_DETAIL sch_event_detail ON (sch_event_detail.sch_event_id = appt_sch_event.sch_event_id
  		AND sch_event_detail.oe_field_id = 23372832 /*Patient Reminder*/
  		AND sch_event_detail.version_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  	))
  , (LEFT JOIN SCH_APPT appt_sch_res_appt_all ON (appt_sch_res_appt_all.sch_event_id = appt_sch_event.sch_event_id
  	))
  , (LEFT JOIN SCH_RESOURCE appt_sch_resource_all ON (appt_sch_res_appt_all.resource_cd = appt_sch_resource_all.resource_cd
    ))
  , (LEFT JOIN CODE_VALUE appt_res_res_cd_all ON (appt_sch_resource_all.resource_cd = appt_res_res_cd_all.code_value
  		AND appt_res_res_cd_all.code_set = 14231
  	))
  , (LEFT JOIN CODE_VALUE cv_appt_res_all_loc_cov ON (appt_sch_res_appt_all.appt_location_cd = cv_appt_res_all_loc_cov.code_value
  		AND cv_appt_res_all_loc_cov.code_set = 220
		AND cv_appt_res_all_loc_cov.cdf_meaning IN ("AMBULATORY")
	))
  , (LEFT JOIN CODE_VALUE_EXTENSION cve ON (cv_appt_res_all_loc_cov.code_value = cve.code_value
		AND cve.field_name = 'CMG Reporting'
    ))
WHERE pat.active_ind = 1
AND PARSER(facprompt)
AND OPERATOR(appt_res_res_cd_all.code_value, res_opr_var, $RES)
AND OPERATOR(appt_sch_event.sch_state_cd, app_opr_var, $APPTSTATUS)
AND OPERATOR(appt_sch_event.appt_type_cd, appttype_opr_var, $APPTTYPE)	;002
AND PARSER(visitprompt) ;005
AND FLOOR((DATETIMEDIFF(appt_sch_res_appt_all.beg_dt_tm, pat.birth_dt_tm)/365)) >= $AGE	;002
AND FLOOR((DATETIMEDIFF(appt_sch_res_appt_all.beg_dt_tm, pat.birth_dt_tm)/365)) <= $AGE2	;002
AND appt_sch_resource_all.mnemonic_key IS NOT NULL
AND appt_sch_resource_all.mnemonic_key != ' '
AND appt_sch_res_appt_all.slot_state_cd IN (0,9541)
AND pat.name_last_key NOT IN ('FFFFPEDS','FFFFAMB','FFFFPNRC','FFFFOP','FFFFED','FFFFIP','FFFFWH','FFFFTEST','FFFFREVCYCLE',
	'FFFFPHARM','ZZGLOVER','ZZTEST','ZZWICK','ZZBOGUS','ZZZZTESTPW','ZZZREGRESSION','ZZZZBHTEST','ZZZNEUROPW','ZZZFLMCRAD',
	'ZZZFSRRAD','ZZZTESTONE','ZZZAMB','ZZZPWRAD','ZZTOPTEST','ZZZ','ZZZRMCRAD','ZZZZTESTPBH','ZZMDDONOTUSE','ZZZMPITESTP',
	'ZZZRADTEST','ZZZFSRGO','ZZZFSWRAD','ZZZTESTIP','ZZZTEST','ZZELLMER','ZZZMPITESTBL','ZZZZTESTPOC','ZZZZZZTEST','ZZZTESTOP',
	'TTTTTEST','TTTTGENLAB','TTTT','TTTTMAYO','TTTTPHARMTEST','TTTTESTFSV','TTTTONC','TTTTESTCATHLAB','TTURNER','TTEST',
	'TTTTHUDLOW','TTTTTESTFN','TTTTCAMCAPTEST',	'TTTTMDI','TTBACKLOADING','TTTTESTPRVL','TTTTMMC','TTTTQUEST','TTHOMASON',
	'TTTTPRINTER','TTTTEST')
AND appt_sch_res_appt_all.beg_dt_tm BETWEEN CNVTDATETIME($bdate) AND CNVTDATETIME($edate)
GROUP BY cv_appt_res_all_loc_cov.description
 
 
HEAD REPORT
	cnt = totalsd->rec_cnt
	IF(mod(cnt,10)> 0)
   		CALL alterlist(totalsd->qual, cnt + (10-mod(cnt,10)))
	ENDIF
 
DETAIL
	cnt = cnt + 1
	IF (mod(cnt,10) = 1 OR cnt = 1)
		stat = alterlist(totalsd->qual, cnt + 9)
	ENDIF
 
	totalsd->qual[cnt].facility 	= 	facility
	totalsd->qual[cnt].resource		= 	"zzzTotals"
	totalsd->qual[cnt].appt_type    =   "zzzTotals"
	totalsd->qual[cnt].appt_status 	=	"Facility Totals"
	totalsd->qual[cnt].total_counts	=	total_counts
 
FOOT REPORT
	stat = alterlist(totalsd->qual, cnt)
	totalsd->rec_cnt	= cnt
WITH nocounter
 
 
/***************************************************************************
	Output Detail Report or Summary Report
****************************************************************************/
 
IF($sumdet = 0)	;Summary Report
 
	CALL ECHO("Summary Totals Report")
 
	SELECT INTO $outdev
 		dateRange = BUILD2(FORMAT(CNVTDATETIME($bdate),"mm/dd/yyyy hh:mm;;q"), ' - ',
		FORMAT(CNVTDATETIME($edate), "mm/dd/yyyy hh:mm;;q")),
		Facility = totals->qual[d.seq].facility,
		Resource = totals->qual[d.seq].resource,
		Appt_Type = totals->qual[d.seq].appt_type,
		Appt_Status = totals->qual[d.seq].appt_status,
		Totals_Counts = totals->qual[d.seq].total_counts
 	FROM (dummyt d with seq = totals->rec_cnt)
 	ORDER BY Facility, Resource, Appt_Type, Appt_Status
	WITH nocounter, format, separator = ' '
 
ELSEIF ($sumdet = 1) ;Summary Distinct Patients
 
 	CALL ECHO("Summary Distinct Totals Report")
 
	SELECT INTO $outdev
 		dateRange = BUILD2(FORMAT(CNVTDATETIME($bdate),"mm/dd/yyyy hh:mm;;q"), ' - ',
		FORMAT(CNVTDATETIME($edate), "mm/dd/yyyy hh:mm;;q"), ' - Distinct Patients'),
		Facility = totalsd->qual[d.seq].facility,
		Resource = totalsd->qual[d.seq].resource,
		Appt_Type = totalsd->qual[d.seq].appt_type,
		Appt_Status = totalsd->qual[d.seq].appt_status,
		Totals_Counts = totalsd->qual[d.seq].total_counts
 	FROM (dummyt d with seq = totalsd->rec_cnt)
 	ORDER BY Facility, Resource, Appt_Type, Appt_Status
	WITH nocounter, format, separator = ' '
 
ELSE		;Detail Report
 
	CALL ECHO("Summary Detail Report")
 
	SELECT INTO $outdev
		Patient = a->qual[d.seq].patient,
		DOB = a->qual[d.seq].DOB,
		Age_As_of_DOS = a->qual[d.seq].age_as_of_dos,		;002
		Home_Phone = a->qual[d.seq].home_phone,
		Mobile_Phone = a->qual[d.seq].mobile_phone,		;002
		Insurance = a->qual[d.seq].insurance,
		CMRN = a->qual[d.seq].cmrn, 		;009
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
ENDIF
 
CALL ECHORECORD(a)
;CALL ECHORECORD(totals)
 
GO TO exitscript
#exitscript
 
END
GO
 
 
