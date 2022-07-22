/***********************************************************
Author 			:	Dawn Greer, DBA
Date Written	:	11/10/2020
Program Title	:	cov_amb_ethin_alerts
Source File		:	cov_amb_ethin_alerts.prg
Object Name		:	cov_amb_ethin_alerts
Directory		:	cust_script
 
Purpose			: 	eTHIN alerts from the Message Center
 
 
Mod     Date        Engineer                Comment
----    ----------- ----------------------- ---------------------------
0001    11/10/2020  Dawn Greer, DBA         Original Release - CR 8863
0002    03/04/2021  Dawn Greer, DBA         CR 9724 - Add Next Appt
0003    03/05/2021  Dawn Greer, DBA         CR 9724 - Remove Task Type, Task Status,
                                            Task Location, Task Active
                                            The appt date inserted after
                                            the FIN column and be within 14 days
                                            of the Task Create Date.
                                            Add Appt Facility and Appt Reason
*************************************************************************/
drop program cov_amb_ethin_alerts go
create program cov_amb_ethin_alerts
 
prompt
	"Output to File/Printer/MINE" = "MINE"          ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = VALUE(0.0           )
	, "Seelct Task Create Begin Date" = "SYSDATE"
	, "Seelct Task Create End Date" = "SYSDATE"
	, "Clinic Data or No Encounter Data" = 0
 
with OUTDEV, FAC, BDATE, EDATE, detailnoenc
 
FREE RECORD a
RECORD a
(
	1	rec_cnt		=	i4
	1	qual[*]
		2	facility		=   c100
		2   patient 		=	c100
		2	dob				=	c10
		2	fin				=	c20
		2   sched_appt      =   c20		;0002
		2   appt_facility   =   c100	;0003
		2   appt_reason     =   c100    ;0003
		2	enc_status  	=	c25
		2	enc_type		=   c50
		2   task_create_date =  c25
		2 	task_subject 	=	c500
		2	task_id			=	f8
		2   sched_appt_date =   dq8
		2   task_cre_date   =   dq8
)
 
FREE RECORD noenc
RECORD noenc
(
	1	rec_cnt		=	i4
	1	qual[*]
		2	facility		=   c100
		2   patient 		=	c100
		2	dob				=	c10
		2	fin				=	c20
		2   sched_appt      =   c20		;0002
		2   appt_facility   =   c100	;0003
		2   appt_reason     =   c100    ;0003
		2	enc_status  	=	c25
		2	enc_type		=   c50
		2   task_create_date =  c25
		2 	task_subject 	=	c500
		2	task_id			=	f8
		2   sched_appt_date =   dq8
		2   task_cre_date   =   dq8
)
 
DECLARE fac_opr_var = c2
DECLARE faclist = c2000
DECLARE facprompt = vc
DECLARE num = i4
DECLARE facitem = vc
DECLARE temp = vc
 
/**********************************************************
Get CMG Facility Data
***********************************************************/
 
;Pulling the CMG List for when Any is selected in the Prompt
SELECT facnum = CNVTSTRING(CV.CODE_VALUE)
FROM CODE_VALUE CV, CODE_VALUE_EXTENSION CVE
WHERE CV.CODE_VALUE = CVE.CODE_VALUE
AND CV.CODE_SET = 220
AND CV.CDF_MEANING = 'FACILITY'
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
	SET facprompt = BUILD("enc.loc_facility_cd IN ",facprompt)
 
ELSEIF(PARAMETER(PARAMETER2($FAC),1)=0.0)  ;any was selected
	SET fac_opr_var = "IN"
	SET facprompt = BUILD("enc.loc_facility_cd IN ", faclist)
ELSE 	;single value selected
	SET fac_opr_var = "="
	SET facitem = CNVTSTRING(PARAMETER(PARAMETER2($FAC),1))
	SET facprompt = BUILD("enc.loc_facility_cd = ", facitem)
ENDIF
 
 
/**********************************************************
Get Clinic Data
***********************************************************/
 
SELECT "NL:"		;0003
FROM task_activity ta
	, (LEFT JOIN encounter enc ON (ta.encntr_id = enc.encntr_id
		AND enc.encntr_type_cd IN ( 2554389963.00,   22282402.00)))
	, (LEFT JOIN encntr_alias ea ON (enc.encntr_id = ea.encntr_id
		AND ea.encntr_alias_type_cd = 1077 /*FIN*/))
	, (LEFT JOIN person pat ON (ta.person_id = pat.person_id))
	, (LEFT JOIN (SELECT sar.beg_dt_tm, sap.person_id, sar.appt_location_cd,		;0002
				se.appt_reason_free,	;0003
				row_num = ROW_NUMBER() OVER(PARTITION BY sap.person_id ORDER BY sar.beg_dt_tm)
				FROM sch_appt sap, sch_appt sar, sch_event se
				WHERE sap.sch_event_id = sar.sch_event_id
				AND sap.sch_event_id = se.sch_event_id
				AND sar.sch_event_id = se.sch_event_id
				AND sap.role_meaning = "PATIENT"
				AND sap.state_MEANING != "RESCHEDULED"
				AND sar.role_meaning = "RESOURCE"
				AND sar.beg_dt_tm >= CNVTDATETIME(CURDATE,0)
				AND se.sch_state_cd = 4538.00 /*CONFIRMED*/
				WITH SQLTYPE(DATATYPE(beg_dt_tm, "DQ8")
				,DATATYPE(person_id, "F8")
				,DATATYPE(appt_location_cd, "F8")
				,DATATYPE(appt_reason_free, "VC")		;0003
				,DATATYPE(row_num,"i4"))
		) sch ON pat.person_id = sch.person_id AND enc.location_cd = sch.appt_location_cd AND sch.row_num = 1)
WHERE ta.task_type_cd = 21712273.00 /*Secure Messages*/
AND ta.msg_subject LIKE 'Pt Alert*'
AND NULLIND(enc.encntr_type_cd) IN (1,0)
AND PARSER(facprompt)
AND pat.NAME_LAST_KEY NOT IN ('FFFFPEDS','FFFFAMB','FFFFPNRC','FFFFOP','FFFFED','FFFFIP','FFFFWH','FFFFTEST','FFFFREVCYCLE',
	'FFFFPHARM','ZZGLOVER','ZZTEST','ZZWICK','ZZBOGUS','ZZZZTESTPW','ZZZREGRESSION','ZZZZBHTEST','ZZZNEUROPW','ZZZFLMCRAD','ZZZFSRRAD',
	'ZZZTESTONE','ZZZAMB','ZZZPWRAD','ZZTOPTEST','ZZZ','ZZZRMCRAD','ZZZZTESTPBH','ZZMDDONOTUSE','ZZZMPITESTP','ZZZRADTEST','ZZZFSRGO',
	'ZZZFSWRAD','ZZZTESTIP','ZZZTEST','ZZELLMER','ZZZMPITESTBL','ZZZZTESTPOC','ZZZZZZTEST','ZZZTESTOP','TTTTTEST','TTTTGENLAB','TTTT',
	'TTTTMAYO','TTTTPHARMTEST','TTTTESTFSV','TTTTONC','TTTTESTCATHLAB','TTURNER','TTEST','TTTTHUDLOW','TTTTTESTFN','TTTTCAMCAPTEST',
	'TTTTMDI','TTBACKLOADING','TTTTESTPRVL','TTTTMMC','TTTTQUEST','TTHOMASON','TTTTPRINTER','TTTTEST')
AND ta.task_create_dt_tm BETWEEN CNVTDATETIME($bdate) AND CNVTDATETIME($edate)
 
HEAD REPORT
	cnt = 0
	CALL alterlist(a->qual, 10)
 
DETAIL
	cnt = cnt + 1
	IF (mod(cnt,10) = 1 OR cnt = 1)
		stat = alterlist(a->qual, cnt + 9)
	ENDIF
 
	a->qual[cnt].facility		=	UAR_GET_CODE_DESCRIPTION(enc.loc_facility_cd)
	a->qual[cnt].patient 		= 	pat.name_full_formatted
	a->qual[cnt].dob			= 	FORMAT(CNVTDATETIMEUTC(pat.birth_dt_tm,1),"MM/DD/YYYY;;d")
	a->qual[cnt].fin			= 	ea.alias
	a->qual[cnt].sched_appt     =   FORMAT(sch.beg_dt_tm, "MM/DD/YYYY hh:mm;;q")		;0002	;0003
	a->qual[cnt].appt_reason    =   TRIM(sch.appt_reason_free,3) 		;0003
	a->qual[cnt].appt_facility  =   UAR_GET_CODE_DESCRIPTION(sch.appt_location_cd) 	;0003
	a->qual[cnt].enc_status		=	UAR_GET_CODE_DISPLAY(enc.encntr_status_cd)
	a->qual[cnt].enc_type		=	UAR_GET_CODE_DISPLAY(enc.encntr_type_cd)
	a->qual[cnt].task_create_date = FORMAT(ta.task_create_dt_tm, "MM/DD/YYYY hh:mm:ss")	;0003
	a->qual[cnt].task_subject	=	ta.msg_subject
	a->qual[cnt].task_id		=   ta.task_id
	a->qual[cnt].sched_appt_date =  sch.beg_dt_tm
	a->qual[cnt].task_cre_date   =  ta.task_create_dt_tm

 
FOOT REPORT
	stat = alterlist(a->qual, cnt )
	a->rec_cnt = cnt
WITH nocounter
 
/**********************************************************
Get No Encounter Data
***********************************************************/
 
SELECT "NL:"		;0003
FROM task_activity ta
	, (LEFT JOIN encounter enc ON (ta.encntr_id = enc.encntr_id
		AND enc.encntr_type_cd IN ( 2554389963.00,   22282402.00)))
	, (LEFT JOIN encntr_alias ea ON (enc.encntr_id = ea.encntr_id
		AND ea.encntr_alias_type_cd = 1077 /*FIN*/))
	, (LEFT JOIN person pat ON (ta.person_id = pat.person_id))
	, (LEFT JOIN (SELECT sar.beg_dt_tm, sap.person_id, sar.appt_location_cd,
				se.appt_reason_free,	;0003
				row_num = ROW_NUMBER() OVER(PARTITION BY sap.person_id ORDER BY sar.beg_dt_tm)	;0002
				FROM sch_appt sap, sch_appt sar, sch_event se
				WHERE sap.sch_event_id = sar.sch_event_id
				AND sap.sch_event_id = se.sch_event_id
				AND sar.sch_event_id = se.sch_event_id
				AND sap.role_meaning = "PATIENT"
				AND sap.state_MEANING != "RESCHEDULED"
				AND sar.role_meaning = "RESOURCE"
				AND sar.beg_dt_tm >= CNVTDATETIME(CURDATE,0)
				AND se.sch_state_cd = 4538.00 /*CONFIRMED*/
				WITH SQLTYPE(DATATYPE(beg_dt_tm, "DQ8")
				,DATATYPE(person_id, "F8")
				,DATATYPE(appt_location_cd, "F8")
				,DATATTYPE(appt_reason_Free, "VC")		;0003
				,DATATYPE(row_num,"i4"))
		) sch ON pat.person_id = sch.person_id AND sch.row_num = 1)
WHERE ta.task_type_cd = 21712273.00 /*Secure Messages*/
AND ta.msg_subject LIKE 'Pt Alert*'
AND NULLIND(enc.encntr_type_cd) = 1
AND pat.NAME_LAST_KEY NOT IN ('FFFFPEDS','FFFFAMB','FFFFPNRC','FFFFOP','FFFFED','FFFFIP','FFFFWH','FFFFTEST','FFFFREVCYCLE',
	'FFFFPHARM','ZZGLOVER','ZZTEST','ZZWICK','ZZBOGUS','ZZZZTESTPW','ZZZREGRESSION','ZZZZBHTEST','ZZZNEUROPW','ZZZFLMCRAD','ZZZFSRRAD',
	'ZZZTESTONE','ZZZAMB','ZZZPWRAD','ZZTOPTEST','ZZZ','ZZZRMCRAD','ZZZZTESTPBH','ZZMDDONOTUSE','ZZZMPITESTP','ZZZRADTEST','ZZZFSRGO',
	'ZZZFSWRAD','ZZZTESTIP','ZZZTEST','ZZELLMER','ZZZMPITESTBL','ZZZZTESTPOC','ZZZZZZTEST','ZZZTESTOP','TTTTTEST','TTTTGENLAB','TTTT',
	'TTTTMAYO','TTTTPHARMTEST','TTTTESTFSV','TTTTONC','TTTTESTCATHLAB','TTURNER','TTEST','TTTTHUDLOW','TTTTTESTFN','TTTTCAMCAPTEST',
	'TTTTMDI','TTBACKLOADING','TTTTESTPRVL','TTTTMMC','TTTTQUEST','TTHOMASON','TTTTPRINTER','TTTTEST')
AND ta.task_create_dt_tm BETWEEN CNVTDATETIME($bdate) AND CNVTDATETIME($edate)
 
HEAD REPORT
	cnt = 0
	CALL alterlist(noenc->qual, 10)
 
DETAIL
	cnt = cnt + 1
	IF (mod(cnt,10) = 1 OR cnt = 1)
		stat = alterlist(noenc->qual, cnt + 9)
	ENDIF
 
	noenc->qual[cnt].facility		=	UAR_GET_CODE_DESCRIPTION(enc.loc_facility_cd)
	noenc->qual[cnt].patient 		= 	pat.name_full_formatted
	noenc->qual[cnt].dob			= 	FORMAT(CNVTDATETIMEUTC(pat.birth_dt_tm,1),"MM/DD/YYYY;;d")
	noenc->qual[cnt].fin			= 	ea.alias
	noenc->qual[cnt].sched_appt     = 	FORMAT(sch.beg_dt_tm, "MM/DD/YYYY hh:mm;;q")	;0002	;0003
	noenc->qual[cnt].appt_reason	=   sch.appt_reason_free	;0003
	noenc->qual[cnt].appt_facility  =   UAR_GET_CODE_DESCRIPTION(sch.appt_location_cd) ;0003
	noenc->qual[cnt].enc_status		=	UAR_GET_CODE_DISPLAY(enc.encntr_status_cd)
	noenc->qual[cnt].enc_type		=	UAR_GET_CODE_DISPLAY(enc.encntr_type_cd)
	noenc->qual[cnt].task_create_date = FORMAT(ta.task_create_dt_tm, "MM/DD/YYYY hh:mm:ss")		;0003
	noenc->qual[cnt].task_subject	=	ta.msg_subject
	noenc->qual[cnt].task_id		=   ta.task_id
	noenc->qual[cnt].sched_appt_date =  sch.beg_dt_tm
	noenc->qual[cnt].task_cre_date   =  ta.task_create_dt_tm
 
FOOT REPORT
	stat = alterlist(noenc->qual, cnt )
	noenc->rec_cnt = cnt
WITH nocounter
 
 
 
/***************************************************************************
	Output Report
****************************************************************************/
 
IF ($detailnoenc = 0)	;Clinic Data
	;Clinic Data Report
	SELECT INTO $outdev
		Facility = a->qual[d.seq].facility,
		Patient = a->qual[d.seq].patient,
		DOB = a->qual[d.seq].DOB,
		Fin = a->qual[d.seq].fin,
		Next_Appt = EVALUATE2(IF (FLOOR(DATETIMEDIFF(a->qual[d.seq].sched_appt_date,a->qual[d.seq].task_cre_date,1,0)) <= 14)	;0003
					a->qual[d.seq].sched_appt ELSE ' ' ENDIF),	;0002	;0003
		Appt_Reason = EVALUATE2(IF (FLOOR(DATETIMEDIFF(a->qual[d.seq].sched_appt_date,a->qual[d.seq].task_cre_date,1,0)) <= 14)	;0003
					a->qual[d.seq].appt_reason ELSE ' ' ENDIF),		;0003
		Appt_Facility = EVALUATE2(IF (FLOOR(DATETIMEDIFF(a->qual[d.seq].sched_appt_date,a->qual[d.seq].task_cre_date,1,0)) <= 14)	;0003
					a->qual[d.seq].appt_facility ELSE ' ' ENDIF),		;0003
		Enc_Status = a->qual[d.seq].enc_status,
		Enc_Type = a->qual[d.seq].enc_type,
		Task_Create_Date = a->qual[d.seq].task_create_date,	;0003
		Task_Subject = a->qual[d.seq].task_subject,
		Task_id = a->qual[d.seq].task_id
	FROM (dummyt d WITH seq = a->rec_cnt)
	ORDER BY Facility, Patient, Task_Create_Date
	WITH nocounter, format, separator = ' '
 
ELSE
	;No Encounter Report
	SELECT INTO $outdev
		Facility = noenc->qual[d.seq].facility,
		Patient = noenc->qual[d.seq].patient,
		DOB = noenc->qual[d.seq].DOB,
		Fin = noenc->qual[d.seq].fin,
		Next_Appt = EVALUATE2(IF (FLOOR(DATETIMEDIFF(noenc->qual[d.seq].sched_appt_date,		;0003
					noenc->qual[d.seq].task_cre_date,1,0)) <= 14)	;0003
					noenc->qual[d.seq].sched_appt ELSE ' ' ENDIF),	;0002	;0003
		Appt_Reason = EVALUATE2(IF (FLOOR(DATETIMEDIFF(noenc->qual[d.seq].sched_appt_date,		;0003
					noenc->qual[d.seq].task_cre_date,1,0)) <= 14)	;0003
					noenc->qual[d.seq].appt_reason ELSE ' ' ENDIF),	;0003
		Appt_Facility = EVALUATE2(IF (FLOOR(DATETIMEDIFF(noenc->qual[d.seq].sched_appt_date,		;0003
					noenc->qual[d.seq].task_cre_date,1,0)) <= 14)	;0003
					noenc->qual[d.seq].appt_facility ELSE ' ' ENDIF),	;0003
		Enc_Status = noenc->qual[d.seq].enc_status,
		Enc_Type = noenc->qual[d.seq].enc_type,
		Task_Create_Date = noenc->qual[d.seq].task_create_date,	;0003
		Task_Subject = noenc->qual[d.seq].task_subject,
		Task_id = noenc->qual[d.seq].task_id
	FROM (dummyt d WITH seq = noenc->rec_cnt)
	ORDER BY Facility, Patient, Task_Create_Date
	WITH nocounter, format, separator = ' '
ENDIF
;CALL ECHORECORD(a)
;CALL ECHORECORD(totals)
 
GO TO exitscript
#exitscript
 
END
GO
 
 
