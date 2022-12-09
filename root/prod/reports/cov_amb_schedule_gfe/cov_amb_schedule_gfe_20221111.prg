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
002     10/12/2022  Dawn Greer, DBA         CR 12661 - Remove limitation of looking for
                                            gfe in the comments.
003     11/10/2022  Dawn Greer, DBA         CR 13799 - Added code to pull person level
                                            insurance.  Added code to exclude old
                                            comments
004     11/11/2022  Dawn Greer, DBA         CR 13799 - The Ops job is taking 2 min.  Changed
                                            the code to add another copy of the organization table
                                            to pull the Insurance from the person level.  Renamed
                                            the organization table for the Encounter Level Insurance.
                                            In the assigning a value to the record structure, I 
                                            check to see if the encounter level insurance has a char size
                                            that is greater than 0 then display the encounter level insurance
                                            otherwise display the person level insurance.
************************************************************************************/
drop program cov_amb_schedule_gfe go
create program cov_amb_schedule_gfe
 
prompt
	"Output to File/Printer/MINE" = "MINE"        ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = VALUE(0.0           )
	, "Select Resource" = VALUE(0.0           )
	, "Appt Create Start Date" = "SYSDATE"
	, "Appt Create End Date" = "SYSDATE"
	, "DO NOT USE:" = ""
 
with OUTDEV, FAC, RES, SDATE, EDATE, LOCCODE
 
FREE RECORD a
RECORD a
(
	1 rec_cnt = i4
	1 p_facility = c100
	1 p_resource = c100
	1 p_startdate = vc
	1 p_enddate = vc
	1 qual[*]
	  2 patient = c100
	  2 dob	= c10
	  2 age_as_of_dos = i4
	  2 home_phone = c15
	  2 mobile_phone = c15
	  2 insurance = c100
	  2 cmrn = c20
	  2 fin = c20
	  2 appt_date = c25
	  2 sch_date = c25
	  2 appt_status = c50
	  2 appt_type = c50
	  2 appt_reminder = c50
	  2 visit_reason = c100
	  2 comments = c200
	  2 resource = c100
	  2 facility = c100
)
 
DECLARE faclist = c2000
DECLARE facprompt = vc
DECLARE num = i4
DECLARE facitem = vc
DECLARE reslist = c2000
DECLARE resprompt = vc
DECLARE rnum = i4
DECLARE resitem = vc
 
DECLARE cov_comma			= vc WITH constant(char(44))
DECLARE cov_pipe = vc WITH constant(CHAR(124))
DECLARE file_name		 	= vc WITH noconstant("")
DECLARE file_var			= vc WITH noconstant("_cov_amb_schedule_gfe_")
DECLARE cur_date_var  		= vc WITH noconstant(build(YEAR(CURDATE-1),
								FORMAT(MONTH(CURDATE-1),"##;P0"),FORMAT(DAY(CURDATE-1),"##;P0")))
DECLARE filepath_var		= vc WITH noconstant("")
DECLARE temppath_var  		= vc WITH noconstant("/cerner/d_p0665/temp/")
DECLARE output_var			= vc WITH noconstant("")
DECLARE output_rec  		= vc with noconstant("")
 
declare cmd					= vc with noconstant("")
declare len					= i4 with noconstant(0)
declare stat				= i4 with noconstant(0)
 
 
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
ORDER BY CNVTUPPER(TRIM(CV.DESCRIPTION,3))
 
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
	SET facprompt = BUILD("CV_APPT_RES_ALL_LOC_COV.CODE_VALUE IN ", faclist)
ELSE 	;single value selected
	SET facitem = CNVTSTRING(PARAMETER(PARAMETER2($FAC),1))
	SET facprompt = BUILD("CV_APPT_RES_ALL_LOC_COV.CODE_VALUE = ", facitem)
ENDIF
 
; Get Facility prompt data selected
SELECT DISTINCT facnum = CNVTSTRING(CV_APPT_RES_ALL_LOC_COV.CODE_VALUE),
facname = TRIM(CV_APPT_RES_ALL_LOC_COV.DESCRIPTION)
FROM CODE_VALUE CV_APPT_RES_ALL_LOC_COV, CODE_VALUE_EXTENSION CVE
WHERE CV_APPT_RES_ALL_LOC_COV.CODE_VALUE = CVE.CODE_VALUE
AND CV_APPT_RES_ALL_LOC_COV.CODE_SET = 220
AND CV_APPT_RES_ALL_LOC_COV.CDF_MEANING IN ('AMBULATORY')
AND CV_APPT_RES_ALL_LOC_COV.ACTIVE_IND = 1
AND CVE.FIELD_NAME = 'CMG Reporting'
AND PARSER(facprompt)
ORDER BY CNVTUPPER(TRIM(CV_APPT_RES_ALL_LOC_COV.DESCRIPTION,3))
 
HEAD REPORT
	facnamelist = FILLSTRING(2000,' ')
 
DETAIL
	facnamelist = BUILD(BUILD(facnamelist, facname), ', ')
 
FOOT REPORT
	facnamelist = REPLACE(facnamelist,',','',2)
	a->p_facility = EVALUATE2(IF(PARAMETER(PARAMETER2($FAC),1) = 0.0) "Facilities: All"
		ELSEIF (SUBSTRING(1,1,REFLECT(parameter(parameter2($FAC),0))) = "L") CONCAT("Facilities: ",TRIM(facnamelist,3))
		ELSE CONCAT("Facility: ",TRIM(facname,3)) ENDIF)
 
WITH nocounter
 
/**********************************************************
Get CMG Resource Data
***********************************************************/
CALL ECHO ("Get Resource Prompt Data")
 
SELECT resname = TRIM(CV.DESCRIPTION,3),
resnum = CV.CODE_VALUE
FROM CODE_VALUE CV
WHERE CV.CODE_SET = 14231
AND CV.ACTIVE_IND = 1
ORDER BY TRIM(CV.DESCRIPTION,3)
 
HEAD REPORT
	reslist = FILLSTRING(4000,' ')
 	reslist = '('
 
DETAIL
	reslist = BUILD(BUILD(reslist, resnum), ', ')
 
FOOT REPORT
	reslist = BUILD(reslist,')')
	reslist = REPLACE(reslist,',','',2)
 
WITH nocounter
 
;Resource Prompt
IF(SUBSTRING(1,1,REFLECT(PARAMETER(PARAMETER2($RES),0))) = "L")		;multiple options selected
	SET resprompt = '('
	SET rnum = CNVTINT(SUBSTRING(2,2,REFLECT(PARAMETER(PARAMETER2($RES),0))))
 
	FOR (i = 1 TO rnum)
		SET resitem = CNVTSTRING(PARAMETER(PARAMETER2($RES),i))
		SET resprompt = BUILD(resprompt,resitem)
		IF (i != rnum)
			SET resprompt = BUILD(resprompt, ",")
		ENDIF
	ENDFOR
	SET resprompt = BUILD(resprompt, ")")
	SET resprompt = BUILD("APPT_RES_RES_CD_ALL.CODE_VALUE IN ",resprompt)
 
ELSEIF(PARAMETER(PARAMETER2($RES),1)=0.0)  ;any was selected
	SET resprompt = BUILD("APPT_RES_RES_CD_ALL.CODE_VALUE != 0.0 ")
ELSE 	;single value selected
	SET resitem = CNVTSTRING(PARAMETER(PARAMETER2($RES),1))
	SET resprompt = BUILD("APPT_RES_RES_CD_ALL.CODE_VALUE = ", resitem)
ENDIF
 
; Get Resource prompt data selected
SELECT resname = TRIM(APPT_RES_RES_CD_ALL.DESCRIPTION,3),
resnum = APPT_RES_RES_CD_ALL.CODE_VALUE
FROM CODE_VALUE APPT_RES_RES_CD_ALL
WHERE APPT_RES_RES_CD_ALL.CODE_SET = 14231
AND APPT_RES_RES_CD_ALL.ACTIVE_IND = 1
AND PARSER(resprompt)
ORDER BY CNVTUPPER(TRIM(APPT_RES_RES_CD_ALL.DESCRIPTION,3))
 
HEAD REPORT
	resnamelist = FILLSTRING(2000,' ')
 
DETAIL
	resnamelist = BUILD(BUILD(resnamelist, resname), ', ')
 
FOOT REPORT
	resnamelist = REPLACE(resnamelist,',','',2)
	a->p_resource = EVALUATE2(IF(PARAMETER(PARAMETER2($RES),1) = 0.0) "Resources: All"
		ELSEIF (SUBSTRING(1,1,REFLECT(parameter(parameter2($RES),0))) = "L") CONCAT("Resources: ",TRIM(resnamelist,3))
		ELSE CONCAT("Resource: ",TRIM(resname,3)) ENDIF)
 
WITH nocounter
 
CALL ECHO ("Get the Other Prompts")
/**************************************************************
; Other Prompts
**************************************************************/
 
SELECT INTO "NL:"
FROM DUMMYT d
 
HEAD REPORT
	a->p_startdate = CONCAT("Begin: ", FORMAT(CNVTDATETIME($sdate),"MM/DD/YYYY hh:mm:ss;;d"))
	a->p_enddate = CONCAT("End: ", FORMAT(CNVTDATETIME($edate),"MM/DD/YYYY hh:mm:ss;;d"))
 
WITH nocounter
 
 
/**********************************************************
Get Schedule Data
***********************************************************/
CALL ECHO ("Get Schedule Data")
 
SELECT INTO "NL:"
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
,(LEFT JOIN ORGANIZATION ins_epr ON (ins_epr.organization_id = epr.organization_id
  ))  
,(LEFT JOIN PERSON_PLAN_RELTN ppr ON (pat.person_id = ppr.person_id		;003
 	AND ppr.priority_seq = 1
 	AND ppr.active_ind = 1
 	AND ppr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND ppr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
  ))
,(LEFT JOIN ORGANIZATION ins_ppr ON (ins_ppr.organization_id = ppr.organization_id	;003
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
	AND sec.version_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)	;003
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
AND PARSER(resprompt)
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
AND appt_sch_res_appt_all.beg_dt_tm >= DATETIMEADD(CNVTDATETIME($sdate),3)
AND sea.action_dt_tm BETWEEN CNVTDATETIME($sdate) AND CNVTDATETIME($edate)
 
 
HEAD REPORT
	cnt = 0
	CALL alterlist(a->qual, 10)
 
DETAIL
	cnt = cnt + 1
	IF (mod(cnt,10) = 1 OR cnt = 1)
		stat = alterlist(a->qual, cnt + 9)
	ENDIF
 
	a->qual[cnt].Patient = TRIM(pat.name_full_formatted,3)
	a->qual[cnt].DOB = FORMAT(CNVTDATETIMEUTC(pat.birth_dt_tm,1),"MM/DD/YYYY;;d")
	a->qual[cnt].Age_as_of_DOS = FLOOR((DATETIMEDIFF(appt_sch_res_appt_all.beg_dt_tm, pat.birth_dt_tm)/365))
	a->qual[cnt].Home_Phone = EVALUATE2(IF (SIZE(TRIM(hphone.phone_num,3)) = 10)
		CONCAT("(",SUBSTRING(1,3,hphone.phone_num),")",SUBSTRING(4,3,hphone.phone_num),"-",SUBSTRING(7,4,hphone.phone_num))
		ELSE " " ENDIF)
	a->qual[cnt].Mobile_Phone = EVALUATE2(IF (SIZE(TRIM(mphone.phone_num,3)) = 10)
		CONCAT("(",SUBSTRING(1,3,mphone.phone_num),")",SUBSTRING(4,3,mphone.phone_num),"-",SUBSTRING(7,4,mphone.phone_num))
		ELSE " " ENDIF)
	a->qual[cnt].Insurance = EVALUATE2(IF (SIZE(TRIM(ins_epr.org_name,3)) > 0) TRIM(ins_epr.org_name,3)
		ELSE TRIM(ins_ppr.org_name,3) ENDIF)
	a->qual[cnt].CMRN = TRIM(cmrn.alias,3)
	a->qual[cnt].FIN = TRIM(ea.alias,3)
	a->qual[cnt].Appt_Date = FORMAT(appt_sch_res_appt_all.beg_dt_tm, "MM/DD/YYYY hh:mm:ss")
	a->qual[cnt].Sch_Date = FORMAT(sea.action_dt_tm, "MM/DD/YYYY hh:mm:ss")
	a->qual[cnt].Appt_Status = UAR_GET_CODE_DISPLAY(appt_sch_event.sch_state_cd)
	a->qual[cnt].Appt_Type = UAR_GET_CODE_DISPLAY(appt_sch_event.appt_type_cd)
	a->qual[cnt].Appt_Reminder = TRIM(sch_event_detail.oe_field_display_value,3)
	a->qual[cnt].Visit_Reason = TRIM(appt_sch_event.appt_reason_free,3)
	a->qual[cnt].comments =	REPLACE(REPLACE(REPLACE(REPLACE(TRIM(lt.long_text,3),CHAR(13),' '),CHAR(10),' '),
		FILLSTRING(150,' '),' '),'|',' ')
	a->qual[cnt].Resource = TRIM(appt_res_res_cd_all.description,3)
	a->qual[cnt].Facility = TRIM(cv_appt_res_all_loc_cov.description,3)
 
FOOT REPORT
	stat = alterlist(a->qual, cnt )
	a->rec_cnt = cnt
WITH nocounter
 
/***************************************************************************
	Output Detail Report
****************************************************************************/
 
IF (a->rec_cnt > 0 AND SIZE(TRIM($loccode,3)) = 0)
	CALL ECHO("Summary Detail Report")
 
	SELECT INTO $outdev
		Patient = a->qual[d.seq].patient,
		DOB = a->qual[d.seq].DOB,
		Age_As_of_DOS = a->qual[d.seq].age_as_of_dos,
		Home_Phone = a->qual[d.seq].home_phone,
		Mobile_Phone = a->qual[d.seq].mobile_phone,
		Insurance = a->qual[d.seq].insurance,
		CMRN = a->qual[d.seq].cmrn,
		FIN = a->qual[d.seq].fin,
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
 
ELSEIF (a->rec_cnt > 0 AND SIZE(TRIM($loccode,3)) > 0)
 
	;  Set astream path
	SET filepath_var = "/cerner/w_custom/p0665_cust/to_client_site/ClinicalAncillary/Ambulatory/AmbScheduleGFE/"
	;SET filepath_var = "/cerner/w_custom/p0665_cust/from_client_site/dg_folder/"
	SET file_name = $loccode
	SET file_var = CNVTLOWER(BUILD(file_name, file_var,cur_date_var,".csv"))
	SET filepath_var = BUILD(filepath_var, file_var)
	SET temppath_var = BUILD(temppath_var, file_var)
	SET output_var = temppath_var
 
CALL ECHO(CONCAT("output_var ", output_var))
 
	SELECT INTO VALUE(output_var)
	FROM (dummyt d WITH seq = a->rec_cnt)
 
 
	HEAD REPORT
		output_rec = build("Patient", cov_pipe,
						"DOB", cov_pipe,
						"Age_As_of_Dos", cov_pipe,
						"Home_Phone", cov_pipe,
						"Mobile_Phone", cov_pipe,
						"Insurance", cov_pipe,
						"CMRN", cov_pipe,
						"FIN", cov_pipe,
						"Appt_Date", cov_pipe,
						"Scheduled_Date", cov_pipe,
						"Appt_Status", cov_pipe,
						"Appt_Type", cov_pipe,
						"Appt_Reminder", cov_pipe,
						"Visit_Reason", cov_pipe,
						"Comments", cov_pipe,
						"Resource", cov_pipe,
						"Facility")
		col 0 output_rec
		row + 1
 
	head d.seq
		output_rec = ""
		output_rec = build(output_rec,
						a->qual[d.seq].Patient, cov_pipe,
						a->qual[d.seq].DOB, cov_pipe,
						a->qual[d.seq].Age_As_of_DOS, cov_pipe,
						a->qual[d.seq].Home_Phone, cov_pipe,
						a->qual[d.seq].Mobile_Phone, cov_pipe,
						a->qual[d.seq].Insurance, cov_pipe,
						a->qual[d.seq].CMRN, cov_pipe,
						a->qual[d.seq].FIN, cov_pipe,
						a->qual[d.seq].Appt_Date, cov_pipe,
						a->qual[d.seq].sch_date, cov_pipe,
						a->qual[d.seq].Appt_Status, cov_pipe,
						a->qual[d.seq].Appt_Type, cov_pipe,
						a->qual[d.seq].Appt_Reminder, cov_pipe,
						a->qual[d.seq].Visit_Reason, cov_pipe,
						a->qual[d.seq].Comments, cov_pipe,
						a->qual[d.seq].Resource, cov_pipe,
						a->qual[d.seq].Facility)
 
		output_rec = trim(output_rec,3)
 
 	FOOT d.seq
		col 0 output_rec
		IF (d.seq < a->rec_cnt) row + 1 ELSE row + 0 ENDIF    ;006
 
	WITH nocounter, maxcol = 32000, FORMAT=STREAM, formfeed = none, maxrow=1, NOHEADING, NOFORMFEED
 
	; Copy file to AStream
	SET cmd = BUILD2("mv ", temppath_var, " ", filepath_var)
	SET len = SIZE(TRIM(cmd))
 
	CALL dcl(cmd, len, stat)
	CALL ECHO(BUILD2(cmd, " : ", stat))
 
ELSE
	SELECT INTO $outdev
		Message = "No data for the prompt values",
		Facility_Prompt = a->p_facility,
		Resource_Prompt = a->p_resource,
		Begin_Date_Prompt = a->p_startdate,
		End_Date_Prompt = a->p_enddate
	FROM (dummyt d )
	WITH nocounter, format, separator = ' '
 
ENDIF
 
 
;CALL ECHORECORD(a)
 
GO TO exitscript
#exitscript
 
END
GO
 
 
