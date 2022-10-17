/*********************************************************************************
Author          :	Dawn Greer, DBA
Date Written	:	09/22/2022
Program Title	:	cov_amb_schedule_gfe
Source File     :	cov_amb_schedule_gfe.prg
Object Name     :	cov_amb_schedule_gfe
Directory       :	cust_script
 
Purpose         : 	Ambulatory Schedules for Good Faith Estimate
 
 
Mod     Date        Engineer                Comment
----    ----------- ----------------------- ---------------------------------------
001     09/22/2022  Dawn Greer, DBA         Original Release - CR 12661

************************************************************************************/
drop program cov_amb_schedule_gfe go
create program cov_amb_schedule_gfe
 
prompt 
	"Output to File/Printer/MINE" = "MINE"        ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 0
	, "Select Resource" = VALUE(0.0           ) 

with OUTDEV, FAC, RES
 
FREE RECORD a
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
		2   cmrn            =   c20    
		2	fin				=	c20
		2	appt_date		=	c25
		2   sch_date        =   c25
		2	appt_status		=   c50
		2 	appt_type		=	c50
		2	appt_reminder	=	c50
		2	visit_reason	=	c100
		2   comments        =   c200
		2	resource		=	c100
		2	facility		=	c100
)
 
DECLARE fac_opr_var = c2
DECLARE res_opr_var = c2
DECLARE faclist = c2000
DECLARE facprompt = vc
DECLARE num = i4
DECLARE facitem = vc
 
/**********************************************************
Get CMG Facility Data	
***********************************************************/
CALL ECHO ("Get Facility Prompt Data")
 
;Pulling the CMG List for when Any is selected in the Prompt
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
Get CMG Resource Data
***********************************************************/
CALL ECHO ("Get Resource Prompt Data")
 
IF(SUBSTRING(1,1,REFLECT(PARAMETER(PARAMETER2($RES),0))) = "L")		;multiple options selected
	SET res_opr_var = "IN"
ELSEIF(PARAMETER(PARAMETER2($RES),1)=0.0)  ;any was selected
	SET res_opr_var = "!="
ELSE 	;single value selected
	SET res_opr_var = "="
ENDIF
 
 
/**********************************************************
Get Schedule Data
***********************************************************/
CALL ECHO ("Get Schedule Data")
 
SELECT 
Patient = TRIM(pat.name_full_formatted,3)
,DOB = FORMAT(CNVTDATETIMEUTC(pat.birth_dt_tm,1),"MM/DD/YYYY;;d")
,AGE_AS_OF_DOS = FLOOR((DATETIMEDIFF(appt_sch_res_appt_all.beg_dt_tm, pat.birth_dt_tm)/365))	
,Home_Phone = EVALUATE2(IF (SIZE(TRIM(hphone.phone_num,3)) = 10)
	CONCAT("(",SUBSTRING(1,3,hphone.phone_num),")",SUBSTRING(4,3,hphone.phone_num),"-",SUBSTRING(7,4,hphone.phone_num))
	ELSE " " ENDIF)
,Mobile_Phone = EVALUATE2(IF (SIZE(TRIM(mphone.phone_num,3)) = 10)
	CONCAT("(",SUBSTRING(1,3,mphone.phone_num),")",SUBSTRING(4,3,mphone.phone_num),"-",SUBSTRING(7,4,mphone.phone_num))
	ELSE " " ENDIF)  
,Insurance = TRIM(ins.org_name,3)
,CMRN = TRIM(cmrn.alias,3)
,FIN = TRIM(ea.alias,3)
,Appt_Date = FORMAT(appt_sch_res_appt_all.beg_dt_tm, "MM/DD/YYYY hh:mm:ss")
,Sch_Date = FORMAT(sea.action_dt_tm, "MM/DD/YYYY hh:mm:ss")
,Appt_Status = UAR_GET_CODE_DISPLAY(appt_sch_event.sch_state_cd)
,Appt_Type = UAR_GET_CODE_DISPLAY(appt_sch_event.appt_type_cd)
,Appt_Reminder = TRIM(sch_event_detail.oe_field_display_value,3)
,Visit_Reason = TRIM(appt_sch_event.appt_reason_free,3)
;,Comments = ''
,Resource = TRIM(appt_res_res_cd_all.description,3)
,Facility = TRIM(cv_appt_res_all_loc_cov.description,3)
FROM PERSON pat
,(LEFT JOIN PHONE hphone ON (pat.person_id = hphone.parent_entity_id
	AND hphone.parent_entity_name = 'PERSON'
	AND hphone.active_ind = 1
	AND hphone.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND hphone.phone_type_cd = 170 /*Home Phone*/
	AND hphone.phone_type_seq = 1
	AND hphone.phone_num_key != ' '
  ))
,(LEFT JOIN PHONE mphone ON (pat.person_id = mphone.parent_entity_id	
 	AND mphone.parent_entity_name = 'PERSON'
 	AND mphone.active_ind = 1
 	AND mphone.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
 	AND mphone.phone_type_cd = 4149712.00 /*Mobile Phone*/
 	AND mphone.phone_type_seq = 1
 	AND mphone.phone_num_key != ' '
  ))
,(INNER JOIN SCH_APPT appt_sch_appt ON (appt_sch_appt.person_id = pat.person_id
 	AND appt_sch_appt.role_meaning = "PATIENT"
 	AND appt_sch_appt.state_meaning != "RESCHEDULED"
  ))
,(LEFT JOIN ENCOUNTER enc ON (appt_sch_appt.encntr_id = enc.encntr_id		
 	AND enc.active_ind = 1
  ))
,(LEFT JOIN ENCNTR_ALIAS ea ON (ea.encntr_id = enc.encntr_id			
	AND ea.active_ind = 1
	AND ea.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND ea.encntr_alias_type_cd = 1077  /*FIN NBR*/
  ))
,(LEFT JOIN PERSON_ALIAS cmrn ON (pat.person_id = cmrn.person_id		
  	AND cmrn.active_ind = 1
  	AND cmrn.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  	AND cmrn.person_alias_type_cd = 2 /*CMRN*/
  ))
,(LEFT JOIN ENCNTR_PLAN_RELTN epr ON (enc.encntr_id = epr.encntr_id	
 	AND epr.priority_seq = 1
 	AND epr.active_ind = 1
 	AND epr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3) 
	AND epr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)	
  ))
,(LEFT JOIN ORGANIZATION ins ON (ins.organization_id = epr.organization_id 	
  ))
,(INNER JOIN SCH_EVENT appt_sch_event ON (appt_sch_event.sch_event_id = appt_sch_appt.sch_event_id
  ))
,(INNER JOIN SCH_EVENT_ACTION sea ON (sea.sch_event_id = appt_sch_event.sch_event_id
	AND sea.sch_action_cd = 4521.00 /*Comfirm*/
	AND sea.action_dt_tm IN (SELECT MAX(s.action_dt_tm) FROM sch_event_action s WHERE s.sch_event_id = sea.sch_event_id)
  ))    
,(LEFT JOIN SCH_EVENT_DETAIL sch_event_detail ON (sch_event_detail.sch_event_id = appt_sch_event.sch_event_id
 	AND sch_event_detail.oe_field_id = 23372832 /*Patient Reminder*/
 	AND sch_event_detail.version_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  ))
,(LEFT JOIN SCH_EVENT_COMM sec ON (appt_sch_event.sch_event_id = sec.sch_event_id
	AND sec.text_type_cd = 10344.00 /*Scheduling Comment*/
  ))  
,(LEFT JOIN LONG_TEXT lt ON (lt.long_text_id = sec.text_id
  ))  
,(LEFT JOIN SCH_APPT appt_sch_res_appt_all ON (appt_sch_res_appt_all.sch_event_id = appt_sch_event.sch_event_id
  ))
,(LEFT JOIN SCH_RESOURCE appt_sch_resource_all ON (appt_sch_res_appt_all.resource_cd = appt_sch_resource_all.resource_cd
  ))
,(LEFT JOIN CODE_VALUE appt_res_res_cd_all ON (appt_sch_resource_all.resource_cd = appt_res_res_cd_all.code_value
 	AND appt_res_res_cd_all.code_set = 14231
  ))
,(LEFT JOIN CODE_VALUE cv_appt_res_all_loc_cov ON (appt_sch_res_appt_all.appt_location_cd = cv_appt_res_all_loc_cov.code_value
 	AND cv_appt_res_all_loc_cov.code_set = 220
	AND cv_appt_res_all_loc_cov.cdf_meaning IN ("AMBULATORY")
  ))
,(LEFT JOIN CODE_VALUE_EXTENSION cve ON (cv_appt_res_all_loc_cov.code_value = cve.code_value
	AND cve.field_name = 'CMG Reporting'
  ))
WHERE pat.active_ind = 1
AND PARSER(facprompt)
AND OPERATOR(appt_res_res_cd_all.code_value, res_opr_var, $RES)
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
AND appt_sch_res_appt_all.beg_dt_tm >= CNVTDATETIME(CURDATE+3,0) 
AND sea.action_dt_tm BETWEEN CNVTDATETIME(CURDATE-1,0) AND CNVTDATETIME(CURDATE-1,235959)
 
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
	a->qual[cnt].age_as_of_dos  =   AGE_AS_OF_DOS		
	a->qual[cnt].home_phone	 	=	home_phone
	a->qual[cnt].mobile_phone	=	mobile_phone		
	a->qual[cnt].insurance		=	insurance
	a->qual[cnt].cmrn           =   cmrn			
	a->qual[cnt].fin			= 	fin
	a->qual[cnt].appt_date		=	appt_date
	a->qual[cnt].sch_date       =   sch_date
	a->qual[cnt].appt_status	=	appt_status
	a->qual[cnt].appt_type		=	appt_type
	a->qual[cnt].appt_reminder	=	appt_reminder
	a->qual[cnt].visit_reason	=	visit_reason
	a->qual[cnt].comments   	=	REPLACE(REPLACE(REPLACE(REPLACE(TRIM(lt.long_text,3),CHAR(13),' '),CHAR(10),' '),
		FILLSTRING(150,' '),' '),'|',' ')
	a->qual[cnt].resource		=	resource
	a->qual[cnt].facility		=	facility
 
FOOT REPORT
	stat = alterlist(a->qual, cnt )
	a->rec_cnt = cnt
WITH nocounter
 
/***************************************************************************
	Output Detail Report 
****************************************************************************/
 
IF (a->rec_cnt > 0)
	CALL ECHO("Summary Detail Report")
 
	SELECT INTO $outdev
		Patient = a->qual[d.seq].patient,
		DOB = a->qual[d.seq].DOB,
		Age_As_of_DOS = a->qual[d.seq].age_as_of_dos,	
		Home_Phone = a->qual[d.seq].home_phone,
		Mobile_Phone = a->qual[d.seq].mobile_phone,		
		Insurance = a->qual[d.seq].insurance,
		CMRN = a->qual[d.seq].cmrn, 		
		Fin = a->qual[d.seq].fin,
		Appt_Date = a->qual[d.seq].appt_date,
		Scheduled_Date = a->qual[d.seq].sch_date,
		Appt_Status = a->qual[d.seq].appt_status,
		Appt_Type = a->qual[d.seq].appt_type,
		Appt_Reminder = a->qual[d.seq].appt_reminder,
		Visit_Reason = a->qual[d.seq].visit_reason,
		Comments = a->qual[d.seq].comments,
		Resource = a->qual[d.seq].resource,
		Facility = a->qual[d.seq].facility
	FROM (dummyt d WITH seq = a->rec_cnt)
	ORDER BY Facility, Resource, Appt_Date, Patient, Appt_Type, Appt_Status
	WITH nocounter, format, separator = ' '
ENDIF
 
CALL ECHORECORD(a)
 
GO TO exitscript
#exitscript
 
END
GO
 
 
