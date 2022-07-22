/*************************************************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
**************************************************************************************************************
 
	Author:				William Hulse, SR Programmer/Dawn Greer, DBA
	Date Written:		12/19/2018
	Solution:			Ambulatory Open Items Note Export
	Source file name:	cov_amb_open_item_note_extract.prg
	Object name:		cov_amb_open_item_note_extract
	Request #:			XXXX
 
	Program purpose:	Extract Ambulatory Open Items Notes to compare to
	                    NextGen Charges Report.
 
	Executing from:		CCL
 
 	Special Notes:
 
 						Output files:
 							cov_amb_open_items_notes_extract.csv
 
**************************************************************************************************************
  GENERATED MODIFICATION CONTROL LOG
**************************************************************************************************************
 
 	Mod        Date	         Developer				  Comment
 	------     ---------  	 --------------------	  --------------------------------------
    001        01/07/2019    William Hulse            Adding 3 new columns Appt_State, UpDatedDate, UpDatedBy.
    002        01/17/2019    Dawn Greer, DBA          Changed Clinical Event join to get the max update date.
    003        01/29/2019    William Hulse            Changed look back date from 1 to 14 days per request.
    004        04/22/2020    Dawn Greer, DBA          CR 7376 - Adding Schedule Comments
    005        04/22/2020    Dawn Greer, DBA          CR 6761 - • Need to change the Note field filter from
                                                              NOTE to Office * Note
                                                          • Add Procedure Note Type
                                                          • Add Consultation Note Type
                                                          • Exclude InError Notes
                                                          • Another query to pull Nurse Visit enc type and
                                                              the Nurse Note with that visit
                                                          • See if we can pull something that shows the Device
                                                              Check document was scanned into the chart.
                                                          • Add Field to show the Note as Preliminary/Final
                                                              which shows up in the document.
    006        04/22/2020   Dawn Greer, DBA           Fixed extra line feeds, Added criteria to exclude TEST
                                                      patients
    007        04/23/2020   Dawn Greer, DBA           Re-work Comments to fix duplicate entries pulling.
    008        04/24/2020   Dawn Greer, DBA           Fixed issue with pulling multiple providers and CMRN pulling
                                                      duplicates.  Added Event Type (Event_Tag).
    009        04/27/2020   Dawn Greer, DBA           Added time portion to DOS.  Added Appt Location.
    010        04/28/2020   Dawn Greer, DBA           Take out returns/line feed from Note Field.
    011        05/14/2021   Dawn Greer, DBA           CR 10373 - Remove Pipe Symbol from Note Field
    012        06/15/2021   Dawn Greer, DBA           CR 9914 - Add Diagnosis and CPT from Cerner to the extract
    013        06/18/2021   Dawn Greer, DBA           CR 9914 - Added to pull HCPCS codes too.
 
**************************************************************************************************************/
DROP PROGRAM cov_amb_open_note_extract:DBA GO
CREATE PROGRAM cov_amb_open_note_extract:DBA
 
PROMPT
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	,"Output To File" = 0
 
WITH OUTDEV, output_file
 
/*****************************************************************************
  Declared Variables
******************************************************************************/
DECLARE crlf				= vc WITH constant(build(char(13),char(10)))
DECLARE cr                  = vc WITH constant(char(13))
DECLARE cov_comma			= vc WITH constant(char(44))
DECLARE cov_quote      		= vc WITH constant(char(34))
DECLARE COV_PIPE			= vc WITH constant(char(124))
 
DECLARE file_var			= vc WITH noconstant("cov_amb_open_note_extract_")
DECLARE cur_date_var  		= vc WITH noconstant(build(YEAR(curdate),FORMAT(MONTH(curdate),"##;P0"),FORMAT(DAY(curdate),"##;P0")))
DECLARE filepath_var		= vc WITH noconstant("")
DECLARE temppath_var  		= vc WITH noconstant("cer_temp:")
declare temppath2_var		= vc with noconstant("$cer_temp/")
DECLARE output_var			= vc WITH noconstant("")
DECLARE output_rec  		= vc with noconstant("")
 
declare cmd					= vc with noconstant("")
declare len					= i4 with noconstant(0)
declare stat				= i4 with noconstant(0)
 
/*****************************************************************************
  Record Structure
******************************************************************************/
 
RECORD amb_notes (
	1 output_cnt 				= i4
	1 list[*]
		2 provider				= vc		;Provider
		2 enc_date				= vc 		;Enc Date/DOS
		2 patient			 	= vc		;Patient
		2 dob				  	= vc		;Patient Date of Birth
		2 cmrn			     	= vc        ;Patient CMRN (Corporate Number)
		2 fin				 	= vc		;Enc FIN NBR
		2 appt_type		   		= vc		;Appointment Type
		2 enc_type			   	= vc		;Enc Type
		2 appt_state            = vc        ;Appoint Status 001
		2 appt_location         = vc        ;Appt Location ;009
		2 sch_comment           = vc        ;Sch Comment 004
		2 sch_event_id          = f8        ;Sch_event_id ;007
		2 enc_status			= vc		;Enc Status
		2 facility				= vc		;Facility
		2 note					= vc		;Note
		2 updateddate           = vc        ;UpDated Date 001
		2 updatedby             = vc        ;Updated By 001
		2 long_text_id          = f8        ;Long_text_id ;007
		2 note_status           = vc        ;Final/Preliminary ;005
		2 note_type             = vc        ;Event_Tag aka Event Type  ;008
		2 diagnosis             = vc        ;List of Diagnosis ;012
		2 cptcode               = vc        ;List of CPT Codes  ;012
		2 encntr_id             = f8        ;Encntr_id ;012
)
 
;  Set astream path
SET filepath_var = "/cerner/w_custom/p0665_cust/to_client_site/ClinicalAncillary/Ambulatory/AmbOrgNotes/"
SET file_var = cnvtlower(build(file_var,cur_date_var,".csv"))
SET filepath_var = build(filepath_var, file_var)
SET temppath_var = build(temppath_var, file_var)
SET temppath2_var = build(temppath2_var, file_var)
 
IF (validate(request->batch_selection) = 1 or $output_file = 1)
	SET output_var = value(temppath_var)
ELSE
	SET output_var = value($OUTDEV)
ENDIF
 
/********************************************************************************
	Get the Data
*********************************************************************************/
SELECT DISTINCT
	PROVIDER = TRIM(PR.NAME_FULL_FORMATTED,3)
	, ENC_DATE = FORMAT(E.REG_DT_TM, 'MM/DD/YYYY hh:mm:ss')   ;009
	, PATIENT = TRIM(P.NAME_FULL_FORMATTED,3)
	, DOB = FORMAT(CNVTDATETIMEUTC(P.BIRTH_DT_TM, 1) ,"MM/DD/YYYY;;d")
	, CMRN = PA.ALIAS
	, FIN = EA.ALIAS
	, APPT_TYPE = UAR_GET_CODE_DESCRIPTION(SE.APPT_TYPE_CD)
    , SCH_EVENT_ID = S.SCH_EVENT_ID  ;007
    , APPT_LOCATION = UAR_GET_CODE_DESCRIPTION(S.APPT_LOCATION_CD)  ;009
	, ENC_TYPE = UAR_GET_CODE_DISPLAY(E.ENCNTR_TYPE_CD)
	, APPT_STATE = UAR_GET_CODE_DESCRIPTION(S.SCH_STATE_CD) ;001
	, ENC_STATUS = UAR_GET_CODE_DISPLAY(E.ENCNTR_STATUS_CD)
	, FACILITY = UAR_GET_CODE_DESCRIPTION(E.LOC_FACILITY_CD)
FROM ENCOUNTER   E
	, (INNER JOIN PERSON P ON (E.PERSON_ID = P.PERSON_ID AND E.ACTIVE_IND = 1))
	, (INNER JOIN ENCNTR_ALIAS EA ON (E.ENCNTR_ID = EA.ENCNTR_ID AND EA.ACTIVE_IND = 1
		AND EA.ENCNTR_ALIAS_TYPE_CD = 1077.00))	;Using Code 1077 = FIN NBR
	, (INNER JOIN SCH_APPT S ON (E.ENCNTR_ID = S.ENCNTR_ID AND E.PERSON_ID = S.PERSON_ID
		AND S.ROLE_MEANING = 'PATIENT'
		AND S.STATE_MEANING != 'RESCHEDULED'))
	, (INNER JOIN SCH_EVENT SE ON (S.SCH_EVENT_ID = SE.SCH_EVENT_ID))
	, (INNER JOIN PERSON_ALIAS PA ON (P.PERSON_ID = PA.PERSON_ID AND PA.ACTIVE_IND = 1
		AND PA.PERSON_ALIAS_TYPE_CD = 2.00			;Using Code 2.00 = CMRN
		AND PA.END_EFFECTIVE_DT_TM >= CNVTDATETIME(CURDATE,CURTIME3)))	;008
	, (INNER JOIN ENCNTR_PRSNL_RELTN EP ON (E.ENCNTR_ID = EP.ENCNTR_ID AND EP.ACTIVE_IND = 1
		AND EP.ENCNTR_PRSNL_R_CD IN (1119.00 /*Attending*/, 681283.00 /*Nurse Practitioner*/, 681284.00 /*Physician Assistant*/)
		AND EP.END_EFFECTIVE_DT_TM >= CNVTDATETIME(CURDATE,CURTIME3)   ;008
		AND EP.DATA_STATUS_CD = 25.00 /* Auth */))  ;008
	, (INNER JOIN PRSNL PR ON (EP.PRSNL_PERSON_ID = PR.PERSON_ID))
WHERE E.ENCNTR_TYPE_CD IN (22282402.00 /* Clinic*/, 2554389963.00 /*Phone Message*/, 2560523697.00/*Results Only*/)
AND P.NAME_LAST_KEY NOT IN ('ZZZTEST','FFFFPEDS','FFFFAMB','FFFFPNRC','FFFFOP','FFFFED','FFFFIP','FFFFWH','FFFFTEST','FFFFREVCYCLE'
,'FFFFPHARM','ZZGLOVER','ZZTEST','ZZWICK','ZZBOGUS','ZZZZTESTPW','ZZZREGRESSION','ZZZZBHTEST','ZZZNEUROPW','ZZZFLMCRAD','ZZZFSRRAD'
,'ZZZTESTONE','ZZZAMB','ZZZPWRAD','ZZTOPTEST','ZZZ','ZZZRMCRAD','ZZZZTESTPBH','ZZMDDONOTUSE','ZZZMPITESTP','ZZZRADTEST','ZZZFSRGO'
,'ZZZFSWRAD','ZZZTESTIP','ZZZTEST','ZZELLMER','ZZZMPITESTBL','ZZZZTESTPOC','ZZZZZZTEST','ZZZTESTOP','TTTTTEST','TTTTGENLAB','TTTT'
,'TTTTMAYO','TTTTPHARMTEST','TTTTESTFSV','TTTTONC','TTTTESTCATHLAB','TTURNER','TTEST','TTTTHUDLOW','TTTTTESTFN','TTTTCAMCAPTEST'
,'TTTTMDI','TTBACKLOADING','TTTTESTPRVL','TTTTMMC','TTTTQUEST','TTHOMASON','TTTTPRINTER','TTTTEST')
AND E.REG_DT_TM BETWEEN CNVTDATETIME(CURDATE-14,0) AND CNVTDATETIME(CURDATE-1,235959);003
 
 
/****************************************************************************
	Populate Record structure
*****************************************************************************/
HEAD REPORT
	cnt = 0
	CALL alterlist(amb_notes->list, 100)
 
DETAIL
	cnt = cnt + 1
 
    comment = " "
 
	IF(mod(cnt,10) = 1 AND cnt > 100)
		CALL alterlist(amb_notes->list, cnt + 9)
	ENDIF
 
	amb_notes->list[cnt].provider = provider
	amb_notes->list[cnt].enc_date = enc_date
	amb_notes->list[cnt].patient = patient
	amb_notes->list[cnt].dob = dob
	amb_notes->list[cnt].cmrn = cmrn
	amb_notes->list[cnt].fin = fin
	amb_notes->list[cnt].appt_type = appt_type
	amb_notes->list[cnt].enc_type = enc_type
	amb_notes->list[cnt].appt_state = appt_state ;001
	amb_notes->list[cnt].sch_event_id = sch_event_id   ;007
	amb_notes->list[cnt].appt_location = appt_location    ;009
	amb_notes->list[cnt].enc_status = enc_status
	amb_notes->list[cnt].facility = facility
	amb_notes->list[cnt].encntr_id = e.encntr_id ;012
 
 
FOOT REPORT
 	amb_notes->output_cnt = cnt
 	CALL alterlist(amb_notes->list, cnt)
 
WITH nocounter
 
/********************************************************************************
	Get Note Data	;012
*********************************************************************************/
CALL ECHO("Get Note Data")
 
SELECT DISTINCT
	NOTE = REPLACE(REPLACE(REPLACE(C.EVENT_TITLE_TEXT,CHAR(13),' '),CHAR(10),' '),'|',' ')  ;010 ;011
	, UPDATEDDATE = FORMAT(C.UPDT_DT_TM, 'MM/DD/YYYY HH:MM:SS') ;001
    , UPDATEDBY = TRIM(P.NAME_FULL_FORMATTED,3) ;001
    , NOTE_STATUS = EVALUATE2(IF (C.RESULT_STATUS_CD = 25.00) "FINAL" ELSEIF (c.event_cd != 0.00) "PRELIMINARY" ELSE "" ENDIF) ;005
    , NOTE_TYPE = C.EVENT_TAG
FROM (dummyt D WITH seq = VALUE(SIZE(amb_notes->list,5)))
	, CLINICAL_EVENT C
	, CODE_VALUE CV_EVENT_CODE
	, PRSNL P
PLAN D
JOIN C WHERE c.encntr_id = amb_notes->list[d.seq].encntr_Id
	AND C.EVENT_RELTN_CD = 135.00 /* Root */
	AND C.RESULT_STATUS_CD NOT IN (28 /*In Error*/, 29 /*In Error*/, 30 /*In Error*/, 31 /*In Error*/)  ;005
	AND C.UPDT_DT_TM = (SELECT MAX(C1.UPDT_DT_TM)  ;002
		FROM CLINICAL_EVENT C1 WHERE C1.EVENT_ID = C.EVENT_ID	;002
		GROUP BY C1.EVENT_ID)  ;002
JOIN CV_EVENT_CODE WHERE C.EVENT_CD = CV_EVENT_CODE.CODE_VALUE
	AND CV_EVENT_CODE.CODE_SET = 72
	AND CV_EVENT_CODE.ACTIVE_IND = 1
	AND (CV_EVENT_CODE.DISPLAY_KEY LIKE '*OFFICE*NOTE*'   ;005
		OR CV_EVENT_CODE.DISPLAY_KEY LIKE '*PROCEDURE*NOTE*'   ;005
		OR CV_EVENT_CODE.DISPLAY_KEY LIKE '*CONSULTATION*NOTE*'   ;005
		OR CV_EVENT_CODE.DISPLAY_KEY LIKE '*DEVICE*CHECK*'  ;005
		OR CV_EVENT_CODE.DISPLAY_KEY LIKE '*NURSE*NOTE*')	;005
JOIN P WHERE C.UPDT_ID = P.PERSON_ID
 
/****************************************************************************
	Populate Record structure - Note Data   ;012
*****************************************************************************/
DETAIL
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(amb_notes->list,5),c.encntr_id, amb_notes->list[cnt].encntr_id)
 
 	IF (idx != 0)
		amb_notes->list[idx].note = note
		amb_notes->list[idx].updateddate = updateddate ;001
		amb_notes->list[idx].updatedby = updatedby ;001
		amb_notes->list[idx].note_status = note_status  ;005
		amb_notes->list[idx].note_type = note_type  ;008
	ENDIF
 
WITH nocounter
 
/********************************************************************************
	Get the Data - Schedule Comment ID ;004  ;007
*********************************************************************************/
SELECT DISTINCT
    SEC.TEXT_ID
FROM (dummyt d WITH seq = VALUE(SIZE(amb_notes->list,5)))
	, SCH_EVENT_COMM SEC
PLAN D
JOIN SEC WHERE SEC.SCH_EVENT_ID = amb_notes->list[d.seq].sch_event_id
	AND SEC.TEXT_TYPE_MEANING = 'COMMENT'
	AND SEC.TEXT_ID = (SELECT MAX(S.TEXT_ID) FROM SCH_EVENT_COMM S
		WHERE SEC.SCH_EVENT_ID = S.SCH_EVENT_ID
		AND S.TEXT_TYPE_MEANING = 'COMMENT')
 
/****************************************************************************
	Populate Record structure - Schedule Comment ID  ;004  ;007
*****************************************************************************/
DETAIL
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(amb_notes->list,5),sec.sch_event_id, amb_notes->list[cnt].sch_event_id)
 
 	IF (idx != 0)
		amb_notes->list[idx].long_text_id = sec.text_id
	ENDIF
 
WITH nocounter
 
 
/********************************************************************************
	Get the Data - Schedule Comment  ;007
*********************************************************************************/
SELECT DISTINCT
    LT_ID = LT.LONG_TEXT_ID
    , LT_TEXT = LT.LONG_TEXT
FROM (dummyt d WITH seq = VALUE(SIZE(amb_notes->list,5)))
	, LONG_TEXT LT
PLAN D
JOIN LT WHERE LT.LONG_TEXT_ID = amb_notes->list[d.seq].long_text_id
 
/****************************************************************************
	Populate Record structure - Schedule Comment   ;004
*****************************************************************************/
DETAIL
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(amb_notes->list,5),lt.long_text_id, amb_notes->list[cnt].long_text_id)
 
 	IF (idx != 0)
		amb_notes->list[idx].sch_comment = REPLACE(REPLACE(REPLACE(REPLACE(TRIM(LT.LONG_TEXT,3),CHAR(13),' '),CHAR(10),' '),
		FILLSTRING(150,' '),' '),'|',' ')
	ENDIF
 
WITH nocounter
 
/********************************************************************************
	Get Diagnosis Data	;012
*********************************************************************************/
CALL ECHO("Get Diagnosis Data")
 
SELECT DISTINCT
	Diag = LISTAGG(nom.source_identifier, "; ")
            OVER(PARTITION BY diag.encntr_id ORDER BY diag.clinical_diag_priority)
FROM (dummyt d WITH seq = VALUE(SIZE(amb_notes->list,5)))
	, diagnosis diag
	, nomenclature nom
PLAN d
JOIN diag WHERE diag.encntr_id = amb_notes->list[d.seq].encntr_Id
	AND diag.active_ind = 1
JOIN nom WHERE diag.nomenclature_id = nom.nomenclature_id
 
/****************************************************************************
	Populate Record structure - Diagnosis Data   ;012
*****************************************************************************/
DETAIL
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(amb_notes->list,5),diag.encntr_id, amb_notes->list[cnt].encntr_id)
 
 	IF (idx != 0)
		amb_notes->list[idx].diagnosis = diag
	ENDIF
 
WITH nocounter
 
/********************************************************************************
	Get CPT Data	;012
*********************************************************************************/
CALL ECHO("Get CPT Data")
 
SELECT DISTINCT
CPT = LISTAGG(CONCAT(SUBSTRING(1,5,TRIM(cm.field6,3)),
EVALUATE2(IF(NULLIND(cmmod.field6) = 0) CONCAT(" ", SUBSTRING(1,5,TRIM(cmmod.field6,3))) ENDIF)), "; ")
            OVER(PARTITION BY chgeve.encntr_id ORDER BY c.activity_dt_tm)
FROM (dummyt d WITH seq = VALUE(SIZE(amb_notes->list,5)))
,charge_event chgeve
,charge c
,charge_mod cm
,charge_mod cmmod
PLAN d
JOIN chgeve WHERE amb_notes->list[d.seq].encntr_id = chgeve.encntr_id
JOIN c WHERE c.charge_event_id = chgeve.charge_event_id
	AND c.active_ind = 1
JOIN cm WHERE cm.charge_item_id = c.charge_item_id
	AND cm.field1_id IN (615214.00 /*CPT4*/, 3692.00 /*CPT4 MOD*/, 2555056221.00/*CPT4 MOD*/,
		     615215.00 /*HCPCS*/)	;013
	AND NULLIND(cm.field6) = 0
	AND cm.active_ind = 1
	AND NULLVAL(cm.charge_mod_source_cd,0.00) IN (0.00, 3319225965.00 /*REFERENCE DATA*/)
	AND cm.field3_id = 0.00
JOIN cmmod WHERE cmmod.charge_item_id = OUTERJOIN(c.charge_item_id)
	AND (cmmod.field1_id = OUTERJOIN(615214.00 /*CPT4*/)
		OR cmmod.field1_id = OUTERJOIN(3692.00 /*CPT4 MOD*/)
		OR cmmod.field1_id = OUTERJOIN(2555056221.00/*CPT4 MOD*/))
	AND NULLIND(cmmod.field6) = OUTERJOIN(0)
	AND cmmod.active_ind = OUTERJOIN(1)
	AND cmmod.charge_item_id = OUTERJOIN(cm.charge_item_id)
	AND cmmod.field3_id != OUTERJOIN(0)
 
/****************************************************************************
	Populate Record structure - CPT Data   ;012
*****************************************************************************/
 
DETAIL
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(amb_notes->list,5),chgeve.encntr_id, amb_notes->list[cnt].encntr_id)
 
 	IF (idx != 0)
		amb_notes->list[idx].cptcode = cpt
	ENDIF
 
WITH nocounter
/****************************************************************************
	Build Output
*****************************************************************************/
IF (amb_notes->output_cnt > 0)
 
	SELECT DISTINCT INTO VALUE(output_var)
	FROM (DUMMYT dt with seq = amb_notes->output_cnt)
	ORDER BY dt.seq
 
	HEAD REPORT
		output_rec = build("PROVIDER", COV_PIPE,
						"ENC_DATE", COV_PIPE,
						"PATIENT", COV_PIPE,
						"DOB", COV_PIPE,
						"CMRN", COV_PIPE,
						"FIN", COV_PIPE,
						"APPT_TYPE", COV_PIPE,
						"APPT_STATE", COV_PIPE, ;001
						"APPT_LOCATION", COV_PIPE,
						"SCH_COMMENT", COV_PIPE, ;004
						"ENC_TYPE", COV_PIPE,
						"ENC_STATUS", COV_PIPE,
						"FACILITY", COV_PIPE,
						"NOTE", COV_PIPE,
						"NOTE_STATUS", COV_PIPE, ;005  ;006  Remove CR  ;008
						"NOTE_TYPE", COV_PIPE, ;008
						"UPDATEDDATE", COV_PIPE, ;001
						"UPDATEDBY", COV_PIPE, ;001;004
						"DIAG_CODE", COV_PIPE,	;012
						"CPT_CODE")  ;009	;012)  ;009
		col 0 output_rec
		row + 1
 
	head dt.seq
		output_rec = ""
		output_rec = build(output_rec,
						amb_notes->list[dt.seq].PROVIDER, COV_PIPE,
						amb_notes->list[dt.seq].ENC_DATE, COV_PIPE,
						amb_notes->list[dt.seq].PATIENT, COV_PIPE,
						amb_notes->list[dt.seq].DOB, COV_PIPE,
						amb_notes->list[dt.seq].CMRN, COV_PIPE,
						amb_notes->list[dt.seq].FIN, COV_PIPE,
						amb_notes->list[dt.seq].APPT_TYPE, COV_PIPE,
						amb_notes->list[dt.seq].APPT_STATE, COV_PIPE, ;001
						amb_notes->list[dt.seq].APPT_LOCATION, COV_PIPE,
						amb_notes->list[dt.seq].SCH_COMMENT, COV_PIPE, ;004
						amb_notes->list[dt.seq].ENC_TYPE, COV_PIPE,
						amb_notes->list[dt.seq].ENC_STATUS, COV_PIPE,
						amb_notes->list[dt.seq].FACILITY, COV_PIPE,
						amb_notes->list[dt.seq].NOTE, COV_PIPE,
						amb_notes->list[dt.seq].NOTE_STATUS, COV_PIPE, ;005   ;006 Removed CR   ;008
						amb_notes->list[dt.seq].NOTE_TYPE, COV_PIPE,  ;008
						amb_notes->list[dt.seq].UPDATEDDATE, COV_PIPE, ;001
						amb_notes->list[dt.seq].UPDATEDBY, COV_PIPE, ;001;004
						amb_notes->list[dt.seq].diagnosis, COV_PIPE,
						amb_notes->list[dt.seq].cptcode)  ;009
 
		output_rec = trim(output_rec,3)
 
 	FOOT dt.seq
		col 0 output_rec
		IF (dt.seq < amb_notes->output_cnt) row + 1 ELSE row + 0 ENDIF    ;006
 
	WITH nocounter, maxcol = 32000, FORMAT=STREAM, formfeed = none, maxrow=1, NOHEADING, NOFORMFEED		;006
ENDIF
 
 
; Copy file to AStream
IF (validate(request->batch_selection) = 1 OR $output_file = 1)
	SET cmd = build2("cp ", temppath2_var, " ", filepath_var)
	SET len = size(trim(cmd))
 
	CALL dcl(cmd, len, stat)
	CALL echo(build2(cmd, " : ", stat))
ENDIF
 
CALL echorecord(amb_notes)
 
END
GO