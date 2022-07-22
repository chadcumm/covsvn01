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
 *                                                                     *
 *Mod     Date          Engineer             Comment                   *
 *------ --------     -------------     ------------------------------ *
; 001     04/20/2018    RS043142           Initial Version             *
; 002     07/18/2018    Covenant-DG     Add Resource/rend provider     *
;                                       from encounter                 *
 ***********************************************************************
 
 
 ******************  END OF ALL MODCONTROL BLOCKS  ********************/
 
PROMPT
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "person_id" = "0.0"                    ;* enter the person id
	, "encntr_id" = "0.0"                    ;* enter the encntr id
	, "sch_event_id" = "0.0"                 ;* enter the sch event id
	, "schedule_id" = "0.0"                  ;* enter the schedule id
 
with OUTDEV, dPERSON_ID, dENCNTR_ID, dSCH_EVENT_ID, dSCHEDULE_ID
 
 
if (validate(last_mod, "NOMOD2") = "NOMOD2")
   declare last_mod = c6 with noconstant(" "), private
endif
 
record addl_rec
(
   1 person_id     = f8
   1 cmrn          = vc
   1 dos           = vc
   1 rend_prov     = vc     ;002
)
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
declare FmtTruncate(iLength = i4, sText = vc, bCapsInd =i2) = vc with protect
 
/**************************************************************
; Include files
**************************************************************/
 
%i ccluserdir:chs_tn_pm_drv_post_doc.inc
%i ccluserdir:chs_tn_pm_hl7_formatting.inc
 
   execute PM_DRV_POST_DOC  ;chs_tn_pm_drv_post_doc
 
%i ccluserdir:chs_tn_pm_format_subs.inc
 
/**************************************************************
; Declared variables
**************************************************************/
declare 4_CMRN_CD             = f8  with protect, constant(uar_get_code_by_cki("CKI.CODEVALUE!2621"))
 
/**************************************************************
; CMRN
**************************************************************/
select into "nl:"
 
FROM person_alias pa
    WHERE pa.PERSON_ID = post_doc_rec->person_id
    and pa.person_alias_type_cd = 4_CMRN_CD
    AND pa.ACTIVE_IND = 1
    and pa.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
    and pa.beg_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
order by pa.PERSON_ID
 
head pa.person_id
 
    addl_rec->person_id = pa.person_id
    addl_rec->cmrn      = trim(pa.alias, 3)
 
foot pa.person_id
 null
 
with nocounter
 
/**************************************************************
; Date Of Service
**************************************************************/
 
select into "nl:"
 
FROM sch_appt sa,
	encntr_prsnl_reltn ep,						;002
	person prov									;002
PLAN sa
    WHERE sa.PERSON_ID          = post_doc_rec->person_id
    and sa.ENCNTR_ID            = post_doc_rec->encntr_id
    and sa.role_meaning       = "PATIENT"
    and sa.state_meaning in ("CHECKED IN", "CHECKED OUT", "CONFIRMED", "NOSHOW")
    and sa.active_ind         = 1
    and sa.version_dt_tm      = cnvtdatetime("31-DEC-2100 00:00:00.00")
JOIN ep 										;002
	WHERE sa.encntr_id = ep.encntr_id    		;002
	AND ep.encntr_prsnl_r_cd = 1119 			;002 - Attending
JOIN prov 										;002
	WHERE ep.prsnl_person_id = prov.person_id	;002
 
order by sa.ENCNTR_ID, sa.beg_dt_tm desc
 
head sa.ENCNTR_ID
 
    addl_rec->dos      = format(sa.BEG_DT_TM,"mm/dd/yyyy;;D")
    addl_rec->rend_prov = prov.name_full_formatted    ;002
 
foot sa.ENCNTR_ID
null
 
with nocounter
 
  ; Barcode
  set REG_DIO   = "{LPI/8}{CPI/12}{FONT/8}"
 
  ;Facesheet Header
  set sFacTitle = "Ambulatory Face Sheet"
  set sEXTBold = "{B}  Ext: {ENDB}"
 
 
  ;Patients FIN
  set sFIN = FmtTruncate(25,post_doc_rec->patient_fin,0)
 
  ;Patient Demographics Info
  set sPatName     = FmtTruncate(75,post_doc_rec->Patient_FullName,0)
  set sCmrn        = FmtTruncate(15,addl_rec->cmrn ,0)
  set sDos         = FmtTruncate(15,addl_rec->dos, 0)
  set sRendProv    = FmtTruncate(35,addl_rec->rend_prov,0)		;002
 
  if (validate(post_doc_rec->Patient_birth_tz, -99) != -99 and curutc)
     set sPatDOB = format(cnvtdatetimeutc(datetimezone(post_doc_rec->Patient_birth_dt_tm,
                      post_doc_rec->Patient_birth_tz),1),"MM/DD/YYYY;;D")
  else
     set sPatDOB = format(post_doc_rec->Patient_birth_dt_tm,"MM/DD/YYYY;;D")
  endif
 
  set sSub01PayerName   = FmtTruncate(40,post_doc_rec->Sub01_HP_Carrier_Name,0)
  set sSub02PayerName   = FmtTruncate(50,post_doc_rec->Sub02_HP_Carrier_Name,0)
  set sSub03PayerName   = FmtTruncate(50,post_doc_rec->sub03_hp_carrier_name,0)
  set sBreak =
"_______________________________________________________________________________________________________________________________"
 
  set sFacility = ""
  set iPadChars = (textlen(sFacTitle) - textlen(sFacTitle)) / 2
 
 
#MAIN
  select into value($1)
   from dummyt d
    plan d
   detail
 
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
 	call print(concat("*","AC",sFIN,"*")),REG_DIO,row+1
 
    ROW + 1
 
    ;Patient DOB
    CALL PRINT(CALCPOS(80, 180)) "{B}Date of Birth:{ENDB}"
    CALL PRINT(CALCPOS(143, 180)) "", sPatDOB
 
    ROW + 1
 
    ;CMRN
    CALL PRINT(CALCPOS(80, 200)) "{B}CMRN:{ENDB}"
    CALL PRINT(CALCPOS(113, 200)) "", sCmrn
 
    ROW + 1
 
    ;Date of Service
    CALL PRINT(CALCPOS(80, 220)) "{B}Date of Service:{ENDB}"
    CALL PRINT(CALCPOS(155, 220)) "", sDos
 
    ROW + 1
 
    ;Rendering Provider  ;002
    CALL PRINT(CALCPOS(80, 240)) "{B}Rendering Provider:{ENDB}"
    CALL PRINT(CALCPOS(177, 240)) "", sRendProv
 
    ROW + 1
 
    CALL PRINT(CALCPOS(10, 245))"", sBreak
 
    ROW + 1
 
    ;Primary Insurance Header
    CALL PRINT(CALCPOS(80, 278)) "{B}{U}Primary Insurance{ENDB}{ENDU}"
 
    ROW + 1
 
    ;Primary Payer Name
    CALL PRINT(CALCPOS(80, 310)) "{B}Payer Name:{ENDB}"
    CALL PRINT(CALCPOS(140, 310)) "", sSub01PayerName
 
    ROW + 1
 
    CALL PRINT(CALCPOS(10, 345))"", sBreak
 
    ROW + 1
 
    ;Secondary Insurance Header
    CALL PRINT(CALCPOS(80, 380)) "{B}{U}Secondary Insurance{ENDB}{ENDU}"
 
    ROW + 1
 
    ;Secondary Payer Name
    CALL PRINT(CALCPOS(80, 415)) "{B}Payer Name:{ENDB}"
    CALL PRINT(CALCPOS(140, 415)) "", sSub02PayerName
 
    ROW + 1
 
     CALL PRINT(CALCPOS(10, 435))"", sBreak
 
    ROW + 1
 
    ;Tertiary Insurance Header
    CALL PRINT(CALCPOS(80, 470)) "{B}{U}Tertiary Insurance{ENDB}{ENDU}"
 
    ROW + 1
 
    ;Tertiary Payer Name
    CALL PRINT(CALCPOS(80, 500)) "{B}Payer Name:{ENDB}"
    CALL PRINT(CALCPOS(140, 500)) "", sSub03PayerName
 
    ROW + 1
 
 
    CALL PRINT(CALCPOS(10, 530))"", sBreak
 
    ROW + 1
 
    CALL PRINT(CALCPOS(90, 610)) "",
    "{B} All orders should be entered in eCare and not written on the Ambulatory Face Sheet{endb}"
 
    ROW + 1
 
 
with nocounter, noformfeed, dio = postscript, maxcol=1000
 
#END_PROGRAM
 
 
/**************************************************************
; DVDev DEFINED SUB-ROUTINES
**************************************************************/
 
SUBROUTINE FmtTruncate(iLength, sText, bCapsInd)
  declare sRetText = vc with private
  declare sStrPart = vc with private
  declare iPos = i4 with private
  declare iSpos = i4 with private
 
  if(bCapsInd)
	  set iPos = findstring(" ", trim(sText,3), 1, 0)
 
	  if(iPos > 0)
		  set iSpos = 1
 
		  while(iPos > 0)
		     set sStrPart = cnvtcap(trim(substring(iSpos,((iPos+1)-iSpos), trim(sText,3))))
		     set sRetText = trim(concat(sRetText, " ", sStrPart),3)
		     set iSpos = iPos + 1
	         set iPos = findstring(" ", trim(sText,3), iSPos, 0)
	         if(iPos = 0)
	     	     set sRetText = trim(concat(sRetText, " ", cnvtcap(substring(iSpos, (size(sText)+1)-iSpos, trim(sText,3)))))
	         endif
		  endwhile
	  else
	    set sRetText = cnvtcap(sText)
	  endif
  else
	set sRetText = sText
  endif
 
   ;Truncate down to size
   if(textlen(trim(sRetText,3)) > iLength)
      set sRetText = concat(substring(1, iLength, sRetText), "...")
   endif
 
   return(sRetText)
END ;FmtTruncate
 
call echorecord(addl_rec)
call echorecord(post_doc_rec)
 
SET last_mod = "001 04/20/2018 RS043142 CCPS-13876 Initial Version"
 
end
go
 
 