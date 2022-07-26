/***********************Change Log*************************
VERSION  DATE       ENGINEER            COMMENT
-------	 -------    -----------         ------------------------
0.1		1/9/2018	Ryan Gotsche		Initial Dev
1.0		2/6/2018	Ryan Gotsche		Release
2.0		5/1/2018	Ryan Gotsche		Updated queries to pull more relevant information
3.0		6/20/2018	Ryan Gotsche		Added Document Type Event Class Audit
**************************************************************/
 
/***********************PROGRAM NOTES*************************
Description - Program will query the following types of information
	in the client domain.
		1. PowerNote
		2. Dynamic Documentation
		3. PowerForms
		4. iView (Bands)
		5. Clinical Documents
**************************************************************/
drop program idn_aud_him_ehrdoc go
create program idn_aud_him_ehrdoc
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Please select your audit" = 0
 
with OUTDEV, AUDIT_VAR
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare ACTIVE_VAR = f8 with Constant(uar_get_code_by_cki("CKI.CODEVALUE!2669")),protect
declare 15749_DOC_VAR = f8 with Constant(uar_get_code_by_cki("CKI.CODEVALUE!13763")),protect
declare 14409_EP_VAR = f8 with Constant(uar_get_code_by_cki("CKI.CODEVALUE!11707")),protect
declare AUDIT_VAR = i4 with noconstant(0)
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
SET AUDIT_VAR = $AUDIT_VAR
IF(AUDIT_VAR = 1)
GO TO PN_AUD
ELSEIF (AUDIT_VAR = 2)
GO TO DD_AUD
ELSEIF(AUDIT_VAR = 3)
GO TO PF_AUD
ELSEIF(AUDIT_VAR = 4)
GO TO IVIEW_AUD
ELSEIF(AUDIT_VAR = 5)
GO TO CLIN_DOC
ELSEIF(AUDIT_VAR = 6)
GO TO PF_AUD_ALL
ELSEIF(AUDIT_VAR = 7)
GO TO POS_NT_RELTN
ELSEIF(AUDIT_VAR = 8)
GO TO CLIN_DOC_CLASS
ENDIF
 
;PowerNotes
#PN_AUD
SELECT DISTINCT INTO $OUTDEV
	DOMAIN = CURRDBNAME
	,NOTE_TYPE = NT.NOTE_TYPE_DESCRIPTION
 
FROM
	NOTE_TYPE_SCR_PATTERN_RELTN   PNT
	, NOTE_TYPE   NT
PLAN PNT WHERE PNT.NOTE_TYPE_SCR_PATTERN_RELTN_ID > 0
 
JOIN NT WHERE NT.NOTE_TYPE_ID = PNT.NOTE_TYPE_ID
AND NT.EVENT_CD IN (SELECT EVENT_CD FROM V500_EVENT_CODE)
ORDER BY
	NT.NOTE_TYPE_DESCRIPTION
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
GO TO EXIT_PROGRAM
/*
SELECT DISTINCT INTO $OUTDEV
	DOMAIN = CURRDBNAME
	, PN_DISPLAY=S.display
	, PN_DEFINITION=S.DEFINITION
	, PN_ACTIVE_IND = s.active_ind
 
FROM
	SCD_STORY SS,
	SCD_STORY_PATTERN SSP,
	SCR_PATTERN   S
PLAN SS
WHERE SS.story_type_cd = 15749_DOC_VAR
join ssp
where ssp.scd_story_id = ss.scd_story_id
join s
where s.scr_pattern_id = ssp.scr_pattern_id
and s.pattern_type_cd = 14409_EP_VAR
and s.active_status_cd = ACTIVE_VAR
 
ORDER BY
	S.DISPLAY_KEY
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
GO TO EXIT_PROGRAM
*/
;Dynamic Documents
#DD_AUD
SELECT INTO $OUTDEV
	DOMAIN = CURRDBNAME
	, DYNDOC_NAME=D.DESCRIPTION_TXT
	, CUSTOM_CONTENT= IF(D.SOURCE_TXT = "cernerbasiccontent")"No"
		ELSE"Yes"
		ENDIF
FROM
	DD_REF_TEMPLATE   D
 
WHERE D.ACTIVE_IND = 1
AND D.DD_REF_TEMPLATE_ID !=0
ORDER BY D.DESCRIPTION_TXT
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
GO TO EXIT_PROGRAM
 
;PowerForms
#PF_AUD
SELECT INTO $OUTDEV DOMAIN = CURRDBNAME,D.DESCRIPTION,COUNT(*)
FROM DCP_FORMS_ACTIVITY D, PERSON P
PLAN D
WHERE D.FORM_STATUS_CD = VALUE(UAR_GET_CODE_BY("MEANING",8,"AUTH"))
AND D.BEG_ACTIVITY_DT_TM > CNVTLOOKBEHIND("30,D")
JOIN P
WHERE P.person_id = d.person_id
and p.name_last_key != "ZZ*"
and p.name_last_key != "TTTT*"
and p.name_last_key != "FFFF*"
and p.name_last_key != "FF*"
GROUP BY D.DCP_FORMS_REF_ID,D.DESCRIPTION
ORDER BY D.DESCRIPTION
WITH TIME=60,NOCOUNTER, SEPARATOR=" ", FORMAT
GO TO EXIT_PROGRAM
 
;iView Bands
#IVIEW_AUD
SELECT DISTINCT INTO $OUTDEV
;	POS = if(findstring("^",P.VALUE,1,1)>0) uar_get_code_display(cnvtreal(substring(0,findstring("^",p.value,1,1)-1,p.value)))
;elseif(cnvtint(p.value)>0) uar_get_code_display(cnvtreal(p.value)) else "" endif
;	, LOC = if(findstring("^",P.VALUE,1,1)>0) uar_get_code_display(cnvtreal(substring(findstring("^",p.value,0,1)+1,100,p.value)
;)) else "" endif ;
;,CHECK=p.value ,
DOMAIN = CURRDBNAME,BAND_NAME=PV.value_upper ;, PV.VALUE , Pv.Entry_id , p.updt_dt_tm
 
FROM
	prefdir_value   pv
	, PREFDIR_GROUP   P
	, PREFDIR_ENTRY   PE
 
where pv.ENTRY_ID = P.ENTRY_ID  and p.entry_id =pe.entry_id  and p.value not in("component", "powerdoc", "system", "reference",
"Powerdoc")
and pv.entry_id in (select entry_id from prefdir_entry where VALUE = "documentsettypes" )
 
ORDER BY
	pv.value_upper
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT, time = 120
GO TO EXIT_PROGRAM
 
;Clinical Documents
#CLIN_DOC
SELECT DISTINCT INTO $OUTDEV
	DOMAIN = CURRDBNAME
, LEVEL_0_DISP = UAR_GET_CODE_DISPLAY(VESC0.EVENT_SET_CD)
, LEVEL_1_DISP = UAR_GET_CODE_DISPLAY(VESC1.EVENT_SET_CD)
, LEVEL_2_DISP = UAR_GET_CODE_DISPLAY(VESC2.EVENT_SET_CD)
, LEVEL_3_DISP = UAR_GET_CODE_DISPLAY(VESC3.EVENT_SET_CD)
, PRIMITIVE_ES = IF (VESC1.EVENT_SET_CD=0)UAR_GET_CODE_DISPLAY(VESC0.EVENT_SET_CD) 
ELSEIF (VESC2.EVENT_SET_CD=0)UAR_GET_CODE_DISPLAY(VESC1.EVENT_SET_CD)
ELSEIF(VESC3.EVENT_SET_CD=0)UAR_GET_CODE_DISPLAY(VESC2.EVENT_SET_CD)
ELSEIF (VESC4.EVENT_SET_CD=0)UAR_GET_CODE_DISPLAY(VESC3.EVENT_SET_CD)
ENDIF 
, EVENT_CODE = 
IF(V0.EVENT_CD != 0)UAR_GET_CODE_DISPLAY(V0.EVENT_CD)
ELSEIF(V.EVENT_CD != 0)UAR_GET_CODE_DISPLAY(V.EVENT_CD)
ELSEIF(V2.EVENT_CD != 0)UAR_GET_CODE_DISPLAY(V2.EVENT_CD)
ELSEIF(V3.EVENT_CD != 0)UAR_GET_CODE_DISPLAY(V3.EVENT_CD)
ENDIF
/*, CLINICAL_NOTE_IND = 
IF(NT0.DATA_STATUS_IND = 1 OR NT.DATA_STATUS_IND = 1 OR NT2.DATA_STATUS_IND = 1 OR NT3.DATA_STATUS_IND = 1) "X"
ELSE " "
ENDIF
, POWERNOTE_IND = 
IF(VEC0.EVENT_ADD_ACCESS_IND = 1
	OR VEC.EVENT_ADD_ACCESS_IND = 1
	OR VEC2.EVENT_ADD_ACCESS_IND = 1
	OR VEC3.EVENT_ADD_ACCESS_IND = 1) "X"
ELSE " "
ENDIF */
, CDI_ALIAS = 
IF(V0.EVENT_CD > 0)CVA0.ALIAS
ELSEIF(V.EVENT_CD > 0)CVA.ALIAS
ELSEIF(V2.EVENT_CD > 0)CVA2.ALIAS
ELSEIF(V3.EVENT_CD > 0)CVA3.ALIAS
ENDIF
FROM
V500_EVENT_SET_CANON VESC0
, V500_EVENT_SET_CANON VESC1
, V500_EVENT_SET_CANON VESC2
, V500_EVENT_SET_CANON VESC3
, V500_EVENT_SET_CANON VESC4
, V500_EVENT_SET_EXPLODE V0
, V500_EVENT_SET_EXPLODE V
, V500_EVENT_SET_EXPLODE V2
, V500_EVENT_SET_EXPLODE V3
, NOTE_TYPE NT0
, NOTE_TYPE NT
, NOTE_TYPE NT2
, NOTE_TYPE NT3
, V500_EVENT_CODE VEC0
, V500_EVENT_CODE VEC
, V500_EVENT_CODE VEC2
, V500_EVENT_CODE VEC3
, CODE_VALUE_ALIAS CVA0
, CODE_VALUE_ALIAS CVA
, CODE_VALUE_ALIAS CVA2
, CODE_VALUE_ALIAS CVA3
PLAN VESC0
WHERE VESC0.EVENT_SET_CD = VALUE(UAR_GET_CODE_BY("DISPLAYKEY",93,"CLINICALDOCUMENTS"))
JOIN VESC1
WHERE VESC1.PARENT_EVENT_SET_CD = VESC0.EVENT_SET_CD
JOIN VESC2
WHERE VESC2.PARENT_EVENT_SET_CD = OUTERJOIN(VESC1.EVENT_SET_CD)
JOIN VESC3
WHERE VESC3.PARENT_EVENT_SET_CD = OUTERJOIN(VESC2.EVENT_SET_CD)
JOIN VESC4
WHERE VESC4.PARENT_EVENT_SET_CD = OUTERJOIN(VESC3.EVENT_SET_CD)
JOIN V0
WHERE OUTERJOIN(VESC1.EVENT_SET_CD) = V0.EVENT_SET_CD
AND V0.EVENT_SET_LEVEL = OUTERJOIN(0)
JOIN NT0
WHERE NT0.EVENT_CD = OUTERJOIN(V0.EVENT_CD)
AND NT0.DATA_STATUS_IND = OUTERJOIN(1)
JOIN VEC0
WHERE VEC0.EVENT_CD = OUTERJOIN(V0.EVENT_CD)
AND VEC0.EVENT_ADD_ACCESS_IND = OUTERJOIN(1)
JOIN CVA0 
WHERE OUTERJOIN(v0.event_cd) = CVA0.CODE_VALUE
AND CVA0.CONTRIBUTOR_SOURCE_CD = OUTERJOIN(VALUE(UAR_GET_CODE_BY("DISPLAYKEY",73,"CDI")))
JOIN V
WHERE OUTERJOIN(VESC2.EVENT_SET_CD) = V.EVENT_SET_CD
AND V.EVENT_SET_LEVEL = OUTERJOIN(0)
JOIN NT
WHERE NT.EVENT_CD = OUTERJOIN(V.EVENT_CD)
AND NT.DATA_STATUS_IND = OUTERJOIN(1)
JOIN VEC
WHERE VEC.EVENT_CD = OUTERJOIN(V.EVENT_CD)
AND VEC.EVENT_ADD_ACCESS_IND = OUTERJOIN(1)
JOIN CVA 
WHERE OUTERJOIN(v.event_cd) = CVA.CODE_VALUE
AND CVA.CONTRIBUTOR_SOURCE_CD = OUTERJOIN(VALUE(UAR_GET_CODE_BY("DISPLAYKEY",73,"CDI")))
JOIN V2
WHERE OUTERJOIN(VESC3.EVENT_SET_CD) = V2.EVENT_SET_CD
AND V2.EVENT_SET_LEVEL = OUTERJOIN(0)
JOIN NT2
WHERE NT2.EVENT_CD = OUTERJOIN(V2.EVENT_CD)
AND NT2.DATA_STATUS_IND = OUTERJOIN(1)
JOIN VEC2
WHERE VEC2.EVENT_CD = OUTERJOIN(V2.EVENT_CD)
AND VEC2.EVENT_ADD_ACCESS_IND = OUTERJOIN(1)
JOIN CVA2 
WHERE OUTERJOIN(v2.event_cd) = CVA2.CODE_VALUE
AND CVA2.CONTRIBUTOR_SOURCE_CD = OUTERJOIN(VALUE(UAR_GET_CODE_BY("DISPLAYKEY",73,"CDI")))
JOIN V3
WHERE OUTERJOIN(VESC4.EVENT_SET_CD) = V3.EVENT_SET_CD
AND V3.EVENT_SET_LEVEL = OUTERJOIN(0)
JOIN NT3
WHERE NT3.EVENT_CD = OUTERJOIN(V3.EVENT_CD)
AND NT3.DATA_STATUS_IND = OUTERJOIN(1)
JOIN VEC3
WHERE VEC3.EVENT_CD = OUTERJOIN(V3.EVENT_CD)
AND VEC3.EVENT_ADD_ACCESS_IND = OUTERJOIN(1)
JOIN CVA3 
WHERE OUTERJOIN(v3.event_cd) = CVA3.CODE_VALUE
AND CVA3.CONTRIBUTOR_SOURCE_CD = OUTERJOIN(VALUE(UAR_GET_CODE_BY("DISPLAYKEY",73,"CDI")))
ORDER BY
VESC1.EVENT_SET_COLLATING_SEQ
, VESC2.EVENT_SET_COLLATING_SEQ
, VESC3.EVENT_SET_COLLATING_SEQ
, VESC4.EVENT_SET_COLLATING_SEQ
, V0.EVENT_CD
, V.EVENT_CD
, V2.EVENT_CD
, V3.EVENT_CD
WITH NOCOUNTER, SEPARATOR=" ", FORMAT, time = 120
GO TO EXIT_PROGRAM
 
;PowerForms
#PF_AUD_ALL
SELECT DISTINCT INTO $OUTDEV
	DOMAIN = CURRDBNAME
	, vesc.event_set_name
	, POWERFORM_TEXTUAL_EVENTCODE = UAR_GET_CODE_DISPLAY(D.TEXT_RENDITION_EVENT_CD)
	, POWERFORM_DESCRIPTION=D.DESCRIPTION
	, PowerForm_EventCode = UAR_GET_CODE_DISPLAY(D.EVENT_CD)
 	
FROM
	DCP_FORMS_REF   D,v500_event_set_code vesc,v500_event_code vec
 
WHERE D.ACTIVE_IND = 1
AND D.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE,CURTIME3)
and d.DESCRIPTION != "zz*"
and d.description != "ZZ*"
and d.event_cd !=0
and d.text_rendition_event_cd !=0
and d.event_cd in (select event_cd from v500_event_code)
and d.text_rendition_event_cd in (select event_cd from v500_event_code)
and vec.event_cd = d.text_rendition_event_cd
and vec.event_set_name = vesc.event_set_name
ORDER BY vesc.event_set_name, D.DESCRIPTION
WITH TIME=60, NOCOUNTER, SEPARATOR=" ", FORMAT
GO TO EXIT_PROGRAM
 
;Position Note Types
#POS_NT_RELTN
SELECT DISTINCT INTO $OUTDEV
	DOMAIN = CURRDBNAME
	,POSITION=UAR_GET_CODE_DISPLAY(L.ROLE_TYPE_CD)
	,NOTE_TYPE=UAR_GET_CODE_DISPLAY(N.EVENT_CD)
FROM
	CODE_VALUE C
	,NOTE_TYPE_LIST L
	,NOTE_TYPE N
PLAN C WHERE C.CODE_SET = 88
AND C.ACTIVE_IND = 1
AND C.END_EFFECTIVE_DT_TM > CNVTDATETIME(CURDATE,CURTIME3)
AND C.CDF_MEANING != "DBA"
AND C.DISPLAY != "IT*-*"
JOIN L WHERE L.ROLE_TYPE_CD = C.CODE_VALUE
JOIN N WHERE N.NOTE_TYPE_ID = L.NOTE_TYPE_ID
AND N.DATA_STATUS_IND = 1
ORDER BY
	POSITION
	,NOTE_TYPE
WITH TIME=60, NOCOUNTER, SEPARATOR=" ", FORMAT
GO TO EXIT_PROGRAM
 
;Clinical Document Event Classes
#CLIN_DOC_CLASS
SELECT DISTINCT INTO $OUTDEV
	DOMAIN = CURRDBNAME
	,NOTE_TYPE=UAR_GET_CODE_DISPLAY(N.EVENT_CD)
	, EVENT_CODE_DISP = UAR_GET_CODE_DISPLAY(VC.EVENT_CD)
	, EC_CLASS = UAR_GET_CODE_DISPLAY(VC.DEF_EVENT_CLASS_CD)
FROM
	NOTE_TYPE N
	, V500_EVENT_CODE VC
PLAN N
WHERE N.NOTE_TYPE_ID != 0
AND N.DATA_STATUS_IND = 1
JOIN VC
WHERE VC.EVENT_CD = N.EVENT_CD
AND VC.CODE_STATUS_CD = ACTIVE_VAR
 
ORDER BY
	NOTE_TYPE
	, EVENT_CODE_DISP
	,EC_CLASS
WITH TIME=60, NOCOUNTER, SEPARATOR=" ", FORMAT
GO TO EXIT_PROGRAM
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
#EXIT_PROGRAM
END
GO
 
