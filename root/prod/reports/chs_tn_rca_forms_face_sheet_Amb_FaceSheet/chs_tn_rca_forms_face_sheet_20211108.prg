drop program chs_tn_rca_forms_face_sheet:dba go
create program chs_tn_rca_forms_face_sheet:dba
 
/************************************************************************
 *                                                                      *
 *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
 *                              Technology, Inc.                        *
 *       Revision      (c) 1984-1995 Cerner Corporation                 *
 *                                                                      *
 *  Cerner (R) Proprietary Rights Notice:  All rights reserved.         *
 *  This material contains the valuable properties and trade secrets of *
 *  Cerner Corporation of Kansas City, Missouri, United States of       *
 *  America (Cerner), embodying substantial creative efforts and        *
 *  confidential information, ideas and expressions, no part of which   *
 *  may be reproduced or transmitted in any form or by any means, or    *
 *  retained in any storage or retrieval system without the express     *
 *  written permission of Cerner.                                       *
 *                                                                      *
 *  Cerner is a registered mark of Cerner Corporation.                  *
 *                                                                      *
 ************************************************************************
          Source file name:   rca_forms_face_sheet
          Object name:        chs_tn_rca_forms_face_sheet
          Program purpose:    RCA Face Sheet
          Executing from:     PMPostDoc Logic
 
 ***********************************************************************
 *                  GENERATED MODIFICATION CONTROL LOG                 *
 ***********************************************************************
 
  Mod      Date         Engineer              Comment
  ------   ----------   -------------         ------------------------------
  001      04/20/2018   RS043142              Initial Version
  002      07/18/2018   Dawn Greer, DBA Cov   Add Resource/rend provider
                                              from encounter
  003      03/19/2019   Dawn Greer, DBA Cov   Add Gender, Reason for Visit
                                              Appt Comments, Location, and
                                              Health Plan
  004      10/15/2019   Dawn Greer, DBA Cov   CR 6221 (old CR 4700) Adding
                                              time to the Appt Date
  005      10/15/2019   Dawn Greer, DBA Cov   CR 6221 (old CR 4700) Adding
                                              Financial Responsibility
  006      03/02/2021   Dawn Greer, DBA Cov   CR 9702 Truncate Comment to
                                              100 characters
  007      11/03/2021   Dawn Greer, DBA Cov   CR 11521 Change Rendering Provider
                                              to the Resource.  Added the
                                              correct Rendering Provider
                                              back under the Resource.
  008      11/04/2021   Dawn Greer, DBA Cov   CR 11521 - Problem with provider
                                              not showing on some Appointments.
                                              Changed criteria to include where the
                                              slot state is zero or active.
  009      11/08/2021   Dawn Greer, DBA Cov   CR 11521 - Problem with provider
                                              not showing on some Appointments.
                                              Added criteria for the Patient appt
                                              and the resource appt.                                              
 ***************************************************************************
 
 
 ******************  END OF ALL MODCONTROL BLOCKS  ********************/
 
PROMPT
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "person_id" = "0.0"                    ;* enter the person id
	, "encntr_id" = "0.0"                    ;* enter the encntr id
	, "sch_event_id" = "0.0"                 ;* enter the sch event id
	, "schedule_id" = "0.0"                  ;* enter the schedule id
 
WITH OUTDEV, dPERSON_ID, dENCNTR_ID, dSCH_EVENT_ID, dSCHEDULE_ID
 
 
IF (validate(last_mod, "NOMOD2") = "NOMOD2")
   DECLARE last_mod = c6 WITH noconstant(" "), private
ENDIF
 
RECORD addl_rec
(
   1 person_id     = f8
   1 cmrn          = vc
   1 dos           = vc
   1 comment       = vc     ;003
   1 visitreason   = vc     ;003
   1 fin_resp_amt  = vc     ;005
   1 resource      = vc     ;006
   1 rend_prov     = vc     ;006
)
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
DECLARE FmtTruncate(iLength = i4, sText = vc, bCapsInd =i2) = vc WITH protect
 
/**************************************************************
; Include files
**************************************************************/
 
%i ccluserdir:chs_tn_pm_drv_post_doc.inc
%i ccluserdir:chs_tn_pm_hl7_formatting.inc
 
   EXECUTE PM_DRV_POST_DOC  ;chs_tn_pm_drv_post_doc
 
%i ccluserdir:chs_tn_pm_format_subs.inc
 
/**************************************************************
; Declared variables
**************************************************************/
DECLARE 4_CMRN_CD             = f8  WITH protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2621"))
 
/**************************************************************
; CMRN
**************************************************************/
SELECT INTO "nl:"
 
FROM person_alias pa
    WHERE pa.PERSON_ID = post_doc_rec->person_id
    AND pa.person_alias_type_cd = 4_CMRN_CD
    AND pa.ACTIVE_IND = 1
    AND pa.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
    AND pa.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
ORDER BY pa.PERSON_ID
 
HEAD pa.person_id
 
    addl_rec->person_id = pa.person_id
    addl_rec->cmrn      = trim(pa.alias, 3)
 
FOOT pa.person_id
 null
 
WITH nocounter
 
/**************************************************************
; Date Of Service
**************************************************************/
 
SELECT INTO "nl:"
FROM sch_appt sa
,(INNER JOIN sch_appt sr ON (sa.sch_event_id = sr.sch_event_id     ;006
	AND sr.role_meaning IN ("RESOURCE","DEFRESROLE")	;006 ;009
	AND sr.slot_state_cd IN (0,9541)  ;008
	))
, (LEFT JOIN encntr_prsnl_reltn ep ON (sa.encntr_id = ep.encntr_id
	AND ep.encntr_prsnl_r_cd IN (1116 /*Admitting*/,1119 /*Attending*/,681283 /*NP*/,681284/*PA*/)
	AND ep.priority_seq = 1
	AND ep.active_ind = 1
	AND ep.data_status_cd = 25.00 /* Auth Verified */  ;0003
	AND ep.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND ep.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	))
, (LEFT JOIN person prov ON (prov.person_id = prsnl_person_id
	))
WHERE sa.PERSON_ID          = post_doc_rec->person_id
AND sa.ENCNTR_ID            = post_doc_rec->encntr_id
AND sa.role_meaning       = "PATIENT"
AND sa.slot_state_cd IN (0,9541)  ;009
AND sa.state_meaning IN ("CHECKED IN", "CHECKED OUT", "CONFIRMED", "NOSHOW")
AND sa.active_ind         = 1
AND sa.version_dt_tm      = CNVTDATETIME("31-DEC-2100 00:00:00.00")
 
ORDER BY sa.ENCNTR_ID, sa.beg_dt_tm desc
 
HEAD sa.ENCNTR_ID
 
    addl_rec->dos = BUILD(FORMAT(sa.beg_dt_tm, "MM/DD/YYYY"), FORMAT(sa.beg_dt_tm, " hh:mm;;S"));004
    addl_rec->resource = TRIM(UAR_GET_CODE_DISPLAY(sr.resource_cd),3)    ;006
    addl_rec->rend_prov = TRIM(prov.name_full_formatted,3)   ;006
 
FOOT sa.ENCNTR_ID
null
 
WITH nocounter
 
/**************************************************************
; Comment/Reason for Visit	;003
**************************************************************/
 
SELECT INTO "nl:"
 
FROM sch_appt sa,
	sch_event_comm sec,
	long_text lt,
	sch_event se
 
PLAN sa
    WHERE sa.PERSON_ID = post_doc_rec->person_id
    AND sa.ENCNTR_ID = post_doc_rec->encntr_id
    AND sa.role_meaning = "PATIENT"
    AND sa.state_meaning IN ("CHECKED IN", "CHECKED OUT", "CONFIRMED", "NOSHOW")
    AND sa.active_ind = 1
    AND sa.version_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
JOIN sec
	WHERE sa.sch_event_id = sec.sch_event_id
	AND sec.active_ind = 1
	AND sec.version_dt_tm  = cnvtdatetime("31-DEC-2100 00:00:00.00")
JOIN lt
	WHERE sec.text_id = lt.long_text_id
	AND lt.active_ind = 1
JOIN se
	WHERE se.sch_event_id = sa.sch_event_id
	AND se.active_ind = 1
	AND se.version_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
ORDER BY sa.ENCNTR_ID, sa.beg_dt_tm desc
 
HEAD sa.ENCNTR_ID
 
	;006 - Limiting comment to 100 characters
	IF (SIZE(TRIM(lt.long_text,3)) > 75)
	    addl_rec->comment = CONCAT("Comment truncated..",
	    	SUBSTRING(1,75,REPLACE(REPLACE(TRIM(lt.long_text,3),CHAR(13),""),CHAR(10),"")))
	ELSE
		addl_rec->comment      = TRIM(lt.long_text,3)
	ENDIF
 
    addl_rec->visitreason  = TRIM(se.appt_reason_free,3)
 
FOOT sa.ENCNTR_ID
null
 
WITH nocounter
 
  ; Barcode
  SET REG_DIO   = "{LPI/8}{CPI/12}{FONT/8}"
 
  ;Facesheet Header
  SET sFacTitle = "Ambulatory Face Sheet"
  SET sEXTBold = "{B}  Ext: {ENDB}"
 
 
  ;Patients FIN
  SET sFIN = FmtTruncate(25,post_doc_rec->patient_fin,0)
 
  ;Patient Demographics Info
  SET sPatName     = FmtTruncate(75,post_doc_rec->Patient_FullName,0)
  SET sCmrn        = FmtTruncate(15,addl_rec->cmrn ,0)
  SET sDos         = FmtTruncate(20,addl_rec->dos, 0)
  SET sResource    = FmtTruncate(35,addl_rec->resource,0)		;002 ;006
  SET sRend_Prov   = FmtTruncate(35,addl_rec->rend_prov,0)   ;006
 
  IF (validate(post_doc_rec->Patient_birth_tz, -99) != -99 AND curutc)
     SET sPatDOB = format(cnvtdatetimeutc(datetimezone(post_doc_rec->Patient_birth_dt_tm,
                      post_doc_rec->Patient_birth_tz),1),"MM/DD/YYYY;;D")
  ELSE
     SET sPatDOB = format(post_doc_rec->Patient_birth_dt_tm,"MM/DD/YYYY;;D")
  ENDIF
 
  SET sSub01PayerName   = FmtTruncate(40,post_doc_rec->Sub01_HP_Carrier_Name,0)
  SET sSub01HPName   	= FmtTruncate(40,post_doc_rec->sub01_hp_name,0) ;003
  SET sSub02PayerName   = FmtTruncate(50,post_doc_rec->Sub02_HP_Carrier_Name,0)
  SET sSub02HPName   	= FmtTruncate(40,post_doc_rec->sub02_hp_name,0) ;003
  SET sSub03PayerName   = FmtTruncate(50,post_doc_rec->sub03_hp_carrier_name,0)
  SET sSub03HPName   	= FmtTruncate(40,post_doc_rec->sub03_hp_name,0) ;003
  SET sDollar = "$"
  SET sBreak =
"_______________________________________________________________________________________________________________________________"
 
  SET sFacility = ""
  SET iPadChars = (textlen(sFacTitle) - textlen(sFacTitle)) / 2
 
 
#MAIN
  SELECT INTO value($1)
   FROM dummyt d
    PLAN d
 
   DETAIL
 
    ;Initialization for document-specific vars
    CUR_ROW    = 80
    NEXT_LINE  = 20
 
    ;Title
    CALL PRINT(CALCPOS(225+(iPadChars * 3), 50)) "{CPI/8}{FONT/8}{B}", sFacTitle, "{ENDB}"
 
    ROW + 1
    CUR_ROW = CUR_ROW + (NEXT_LINE * 2.5)
 
    ;Patient Info Header
    CALL PRINT(CALCPOS(80, 120)) "{CPI/12}{FONT/8}{B}{U}Patient Information{ENDB}{ENDU}"
 
    ROW + 1
 
    ;Patient Name
    CALL PRINT(CALCPOS(80, 160)) "{B}Patient:{ENDB}"
    CALL PRINT(CALCPOS(116, 160)) "", sPatName
 
     ;barcode
    CALL PRINT(CALCPOS(390, 160)) "{LPI/14}{CPI/8}{BCR/300}{FONT/28/7}"
 	CALL print(concat("*","AC",sFIN,"*")),REG_DIO,row+1
 
    ROW + 1
 
    ;Patient DOB
    CALL PRINT(CALCPOS(80, 180)) "{B}Date of Birth:{ENDB}"
    CALL PRINT(CALCPOS(143, 180)) "", sPatDOB
 
    ROW + 1
 
    ;Patient Gender  ;003
    CALL PRINT(CALCPOS(80, 200)) "{B}Gender:{ENDB}"
    CALL PRINT(CALCPOS(117, 200)) "", post_doc_rec->patient_sex
 
    ROW + 1
 
    ;CMRN
    CALL PRINT(CALCPOS(80, 220)) "{B}CMRN:{ENDB}"
    CALL PRINT(CALCPOS(113, 220)) "", sCmrn
 
    ROW + 1
 
    ;Date of Service
    CALL PRINT(CALCPOS(80, 240)) "{B}Date of Service:{ENDB}"
    CALL PRINT(CALCPOS(155, 240)) "", sDos
 
    ROW + 1
 
    ;Resource  ;006
    CALL PRINT(CALCPOS(80, 260)) "{B}Resource:{ENDB}"
    CALL PRINT(CALCPOS(130, 260)) "", sResource
 
    ROW + 1
 
    ;Location ;003
    CALL PRINT(CALCPOS(350, 260)) "{B}Location:{ENDB}"
    CALL PRINT(CALCPOS(400, 260)) "", post_doc_rec->Location
 
    ROW + 1
 
    ;Rend_Prov  ;006
    CALL PRINT(CALCPOS(80, 280)) "{B}Rendering Provider:{ENDB}"
    CALL PRINT(CALCPOS(178, 280)) "", sRend_Prov
 
    ROW + 1
 
    ;Appointment Reason ;003
    CALL PRINT(CALCPOS(80, 300)) "{B}Visit Reason:{ENDB}"
    CALL PRINT(CALCPOS(145, 300)) "", addl_rec->visitreason
 
    ROW + 1
 
    ;Appointment Comment;003
    CALL PRINT(CALCPOS(80, 320)) "{B}Comment:{ENDB}"
    CALL PRINT(CALCPOS(132, 320)) "", addl_rec->comment
 
    ROW + 1
 
    CALL PRINT(CALCPOS(10, 340))"", sBreak
 
    ROW + 1
 
    ;Primary Insurance Header
    CALL PRINT(CALCPOS(80, 360)) "{B}{U}Primary Insurance{ENDB}{ENDU}"
 
    ROW + 1
 
    ;Primary Payer Name
    CALL PRINT(CALCPOS(80, 380)) "{B}Payer Name:{ENDB}"
    CALL PRINT(CALCPOS(140, 380)) "", sSub01PayerName
 
    ROW + 1
 
    ;Primary HP Name	;003
    CALL PRINT(CALCPOS(80, 400)) "{B}Health Plan Name:{ENDB}"
    CALL PRINT(CALCPOS(170, 400)) "", sSub01HPName
 
    ROW + 1
 
    ;005 ;Primary HP Financial Responsibility
    CALL PRINT(CALCPOS(80, 420)) "{B}Financial Responsibility: {ENDB}"
    CALL PRINT(CALCPOS(200, 420)) "", addl_rec->fin_resp_amt
 
 	ROW + 1
 
    CALL PRINT(CALCPOS(10, 425))"", sBreak		;005
 
    ROW + 1
 
    ;Secondary Insurance Header
    CALL PRINT(CALCPOS(80, 445)) "{B}{U}Secondary Insurance{ENDB}{ENDU}"		;005
 
    ROW + 1
 
    ;Secondary Payer Name
    CALL PRINT(CALCPOS(80, 465)) "{B}Payer Name:{ENDB}"
    CALL PRINT(CALCPOS(140, 465)) "", sSub02PayerName
 
    ROW + 1
 
    ;Secondary HP Name
    CALL PRINT(CALCPOS(80, 485)) "{B}Health Plan Name:{ENDB}"
    CALL PRINT(CALCPOS(170, 485)) "", sSub02HPName
 
    ROW + 1
 
     CALL PRINT(CALCPOS(10, 490))"", sBreak
 
    ROW + 1
 
    ;Tertiary Insurance Header
    CALL PRINT(CALCPOS(80, 510)) "{B}{U}Tertiary Insurance{ENDB}{ENDU}"
 
    ROW + 1
 
    ;Tertiary Payer Name
    CALL PRINT(CALCPOS(80, 530)) "{B}Payer Name:{ENDB}"
    CALL PRINT(CALCPOS(140, 530)) "", sSub03PayerName
 
    ROW + 1
 
    ;Tertiary HP Name
    CALL PRINT(CALCPOS(80, 550)) "{B}Health Plan Name:{ENDB}"
    CALL PRINT(CALCPOS(170, 550)) "", sSub03HPName
 
    ROW + 1
 
 
    CALL PRINT(CALCPOS(10, 555))"", sBreak
 
    ROW + 1
 
    CALL PRINT(CALCPOS(90, 610)) "",
    "{B} All orders should be entered in eCare and not written on the Ambulatory Face Sheet{endb}"
 
    ROW + 1
 
 
WITH nocounter, noformfeed, dio = postscript, maxcol=1000
 
#END_PROGRAM
 
 
/**************************************************************
; DVDev DEFINED SUB-ROUTINES
**************************************************************/
 
SUBROUTINE FmtTruncate(iLength, sText, bCapsInd)
  DECLARE sRetText = vc WITH private
  DECLARE sStrPart = vc WITH private
  DECLARE iPos = i4 WITH private
  DECLARE iSpos = i4 WITH private
 
  IF(bCapsInd)
	  SET iPos = findstring(" ", trim(sText,3), 1, 0)
 
	  IF(iPos > 0)
		  SET iSpos = 1
 
		  WHILE(iPos > 0)
		     SET sStrPart = cnvtcap(trim(substring(iSpos,((iPos+1)-iSpos), trim(sText,3))))
		     SET sRetText = trim(concat(sRetText, " ", sStrPart),3)
		     SET iSpos = iPos + 1
	         SET iPos = findstring(" ", trim(sText,3), iSPos, 0)
	         IF(iPos = 0)
	     	     SET sRetText = trim(concat(sRetText, " ", cnvtcap(substring(iSpos, (size(sText)+1)-iSpos, trim(sText,3)))))
	         ENDIF
		  ENDWHILE
	  ELSE
	    SET sRetText = cnvtcap(sText)
	  ENDIF
  ELSE
	SET sRetText = sText
  ENDIF
 
   ;Truncate down to size
   IF(textlen(trim(sRetText,3)) > iLength)
      SET sRetText = concat(substring(1, iLength, sRetText), "...")
   ENDIF
 
   RETURN(sRetText)
END ;FmtTruncate
 
;CALL echorecord(addl_rec)
;CALL echorecord(post_doc_rec)
 
END
GO
 
