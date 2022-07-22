/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
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
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod        Date	         Developer				  Comment
 	------     ---------  	 --------------------	  --------------------------------------
    001        01/07/2019    William Hulse            Adding 3 new columns Appt_State, UpDatedDate, UpDatedBy.
******************************************************************************/
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
DECLARE cov_comma			= vc WITH constant(char(44))
DECLARE cov_quote      		= vc WITH constant(char(34))
DECLARE cov_pipe			= vc WITH constant(char(124))
 
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
		2 enc_date				= vc 		;Enc Date
		2 patient			 	= vc		;Patient
		2 dob				  	= vc		;Patient Date of Birth
		2 cmrn			     	= vc        ;Patient CMRN (Corporate Number)
		2 fin				 	= vc		;Enc FIN NBR
		2 appt_type		   		= vc		;Appointment Type
		2 enc_type			   	= vc		;Enc Type
		2 appt_state            = vc        ;Appoint Status 001
		2 enc_status			= vc		;Enc Status
		2 facility				= vc		;Facility
		2 note					= vc		;Note
		2 updateddate           = vc        ;UpDated Date 001
		2 updatedby             = vc        ;Updated By 001
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
	PROVIDER = PR.NAME_FULL_FORMATTED
	, ENC_DATE = FORMAT(E.REG_DT_TM, 'MM/DD/YYYY')
	, PATIENT = P.NAME_FULL_FORMATTED
	, DOB = FORMAT(P.BIRTH_DT_TM, 'MM/DD/YYYY')
	, CMRN = PA.ALIAS
	, FIN = EA.ALIAS
	, APPT_TYPE = UAR_GET_CODE_DESCRIPTION(SE.APPT_TYPE_CD)
	, ENC_TYPE = UAR_GET_CODE_DISPLAY(E.ENCNTR_TYPE_CD)
	, APPT_STATE = UAR_GET_CODE_DESCRIPTION(S.SCH_STATE_CD) ;001
	, ENC_STATUS = UAR_GET_CODE_DISPLAY(E.ENCNTR_STATUS_CD)
	, FACILITY = UAR_GET_CODE_DESCRIPTION(E.LOC_FACILITY_CD)
	, NOTE = C.EVENT_TITLE_TEXT
	, UPDATEDDATE = FORMAT(C.UPDT_DT_TM, 'MM/DD/YYYY HH:MM:SS') ;001
    , UPDATEDBY = P1.NAME_FULL_FORMATTED ;001
FROM
	ENCOUNTER   E
	, (INNER JOIN PERSON P ON (E.PERSON_ID = P.PERSON_ID AND E.ACTIVE_IND = 1))
	, (INNER JOIN ENCNTR_ALIAS EA ON (E.ENCNTR_ID = EA.ENCNTR_ID AND EA.ACTIVE_IND = 1
		AND EA.ENCNTR_ALIAS_TYPE_CD = 1077.00))	;Using Code 1077 = FIN NBR
	, (INNER JOIN SCH_APPT S ON (E.ENCNTR_ID = S.ENCNTR_ID AND S.ROLE_MEANING = 'PATIENT'
		AND S.STATE_MEANING != 'RESCHEDULED'))
	, (INNER JOIN SCH_EVENT SE ON (S.SCH_EVENT_ID = SE.SCH_EVENT_ID))
	, (INNER JOIN PERSON_ALIAS PA ON (P.PERSON_ID = PA.PERSON_ID AND PA.ACTIVE_IND = 1
		AND PA.PERSON_ALIAS_TYPE_CD = 2.00))	;Using Code 2.00 = CMRN
	, (INNER JOIN ENCNTR_PRSNL_RELTN EP ON (E.ENCNTR_ID = EP.ENCNTR_ID AND EP.ACTIVE_IND = 1
		AND EP.ENCNTR_PRSNL_R_CD IN (1119.00 /*Attending*/, 681283.00 /*Nurse Practitioner*/, 681284.00 /*Physician Assistant*/)))
	, (INNER JOIN PRSNL PR ON (EP.PRSNL_PERSON_ID = PR.PERSON_ID))
	, (LEFT JOIN CLINICAL_EVENT C ON (E.ENCNTR_ID = C.ENCNTR_ID AND E.ACTIVE_IND = 1 AND E.PERSON_ID = C.PERSON_ID
		AND C.EVENT_TITLE_TEXT LIKE '*Note*'))
	, (INNER JOIN (SELECT C1.ENCNTR_ID, C1.PERSON_ID, C1.EVENT_ID, MAXDATE = MAX(C1.UPDT_DT_TM)
		FROM CLINICAL_EVENT C1 WHERE C1.EVENT_TITLE_TEXT LIKE '*Note*'
		GROUP BY C1.ENCNTR_ID, C1.PERSON_ID, C1.EVENT_ID) X ON (X.ENCNTR_ID = C.ENCNTR_ID AND X.PERSON_ID = C.PERSON_ID AND X.
		EVENT_ID = C.EVENT_ID AND X.MAXDATE = C.UPDT_DT_TM)) ;001
	, (LEFT JOIN PRSNL P1 ON (C.UPDT_ID = P1.PERSON_ID )) ;001
 
WHERE E.ENCNTR_TYPE_CD IN (22282402.00 /* Clinic*/, 2554389963.00 /*Phone Message*/, 2560523697.00/*Results Only*/)
 
AND E.REG_DT_TM BETWEEN CNVTDATETIME(CURDATE-365,0) AND CNVTDATETIME(CURDATE-1,235959)
 
 
/****************************************************************************
	Populate Record structure
*****************************************************************************/
HEAD REPORT
	cnt = 0
	CALL alterlist(amb_notes->list, 100)
 
DETAIL
	cnt = cnt + 1
 
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
	amb_notes->list[cnt].enc_status = enc_status
	amb_notes->list[cnt].facility = facility
	amb_notes->list[cnt].note = note
	amb_notes->list[cnt].updateddate = updateddate ;001
	amb_notes->list[cnt].updatedby = updatedby ;001
 
FOOT REPORT
 	amb_notes->output_cnt = cnt
 	CALL alterlist(amb_notes->list, cnt)
 
WITH nocounter
 
/****************************************************************************
	Build Output
*****************************************************************************/
IF (amb_notes->output_cnt > 0)
 
	SELECT INTO VALUE(output_var)
	FROM (DUMMYT dt with seq = amb_notes->output_cnt)
	ORDER BY dt.seq
 
	HEAD REPORT
		output_rec = build("Provider", cov_pipe,
						"Enc_Date", cov_pipe,
						"Patient", cov_pipe,
						"DOB", cov_pipe,
						"CMRN", cov_pipe,
						"FIN", cov_pipe,
						"APPT_TYPE", cov_pipe,
						"ENC_TYPE", cov_pipe,
						"APPT_STATE", cov_pipe, ;001
						"ENC_STATUS", cov_pipe,
						"FACILITY",cov_pipe,
						"NOTE",cov_pipe,
						"UPDATEDDATE",cov_pipe, ;001
						"UPDATEDBY") ;001
		col 0 output_rec
		row + 1
 
	head dt.seq
		output_rec = ""
		output_rec = build(output_rec,
						amb_notes->list[dt.seq].Provider, cov_pipe,
						amb_notes->list[dt.seq].Enc_Date, cov_pipe,
						amb_notes->list[dt.seq].Patient, cov_pipe,
						amb_notes->list[dt.seq].DOB, cov_pipe,
						amb_notes->list[dt.seq].CMRN, cov_pipe,
						amb_notes->list[dt.seq].FIN, cov_pipe,
						amb_notes->list[dt.seq].APPT_TYPE, cov_pipe,
						amb_notes->list[dt.seq].ENC_TYPE, cov_pipe,
						amb_notes->list[dt.seq].APPT_STATE, cov_pipe, ;001
						amb_notes->list[dt.seq].ENC_STATUS, cov_pipe,
						amb_notes->list[dt.seq].FACILITY, cov_pipe,
						amb_notes->list[dt.seq].NOTE, cov_pipe,
						amb_notes->list[dt.seq].UPDATEDDATE, cov_pipe, ;001
						amb_notes->list[dt.seq].UPDATEDBY) ;001
 
		output_rec = trim(output_rec,3)
 
	FOOT dt.seq
		col 0 output_rec
		row + 1
 
	WITH nocounter, maxcol = 32000, format =stream, formfeed = none
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