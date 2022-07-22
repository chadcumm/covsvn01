/*~BB~************************************************************************
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
  ~BE~***********************************************************************/

/***********************************************************************************

        Source file name:       cov_eks_add_antic_doc_core.prg
        Object name:            cov_eks_add_antic_doc_core

        Product:                ProFile
        Product Team:
        HNA Version:            500
        CCL Version:            8.0

        Program purpose:        Creates an anticipated document based
                                 on a patient event
        Tables read:            code_value, task_activity
        Tables updated:         None
        Special Notes:          Taken completely from Him_eks_add_antic_document
                                Executed from Him_eks_add_antic_document, and Him_eks_add_doc_order
                                which are called from the him_add_antic_document and
                                him_add_antic_docs_provider eks action templates.
                                DOCUMENT_NAME, TAG_COLOR_IND,and DEFICIENT_PERSONNEL
                                are parameters from the rule templates.
                                RetVal is the value returned to the rule templates.
                                Makes the assumption that ACTION_PRSNL_ID and PERFORM_PRSNL_ID were already
                                populated in the calling scripts.
************************************************************************************/

;~DB~***********************************************************************************
;    *                      GENERATED MODIFICATION CONTROL LOG                         *
;    ***********************************************************************************
;    *                                                                                 *
;    *Feature Date       Engineer      Comment                                         *
;    *------- ---------- -------------  ---------------------------------------------- *
;    *  28485 08/22/2005 SM8093         Initial Release - taken from Him_eks_add_antic_document
;       28485A                          Throughout - replaced person_id and encntr_id with
;                                       personid and encntrid to avoid possible confusion on single table queries
;                                         CR 1-453210041
;      ccummin4                         added check against performing physician
;~DE~***********************************************************************************
drop program cov_eks_add_antic_doc_core go
create program cov_eks_add_antic_doc_core

CALL ECHO("INSIDE cov_eks_add_antic_doc_core")
%i cclsource:eks_tell_ekscommon.inc
%I CCLSOURCE:EKS_RPRQ1000012.INC

/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
;Variables for creating the anticipated document
Declare DOCUMENT_DISPLAY      = vc With Public, NoConstant("")
Declare ALREADY_EXISTS        = i2 With Public, NoConstant(0)
Declare Find_Pos              = i2 With Public, NoConstant(0)
;28485 Declare PERFORMED_PRSNL_ID    = f8 With Public, NoConstant(0.0)
;28485 Declare ACTION_PRSNL_ID       = f8 With Public, NoConstant(0.0)
Declare ACTION_STATUS_CD      = f8 With Public, NoConstant(0.0)
Declare ACTION_TYPE_CD        = f8 With Public, NoConstant(0.0)
Declare CONTRIBUTOR_SYSTEM_CD = f8 With Public, NoConstant(0.0)
Declare DOCUMENT_CD           = f8 With Public, NoConstant(0.0)
Declare EVENT_CLASS_CD        = f8 With Public, NoConstant(0.0)
Declare EVENT_RELTN_CD        = f8 With Public, NoConstant(0.0)
Declare FORMAT_CD             = f8 With Public, NoConstant(0.0)
Declare RECORD_STATUS_CD      = f8 With Public, NoConstant(0.0)
Declare RESULT_STATUS_CD      = f8 With Public, NoConstant(0.0)
Declare STORAGE_CD            = f8 With Public, NoConstant(0.0)
Declare SUCCESSION_TYPE_CD    = f8 With Public, NoConstant(0.0)

;Variable for determining deficient prsnl
Declare DeficientPrsnl        = vc With Public, NoConstant("")
Declare DeficientPrsnlCd      = f8 With Public, NoConstant(0.0)

;Variables for assigning tag color
Declare PUBLISH_IND           = i2 With Public, NoConstant(0)
Declare TAG_COMMON_IND        = i2 With Public, NoConstant(0)
Declare TAG_IND               = i2 With Public, NoConstant(0)
Declare logmsg                = vc With Public, NoConstant("")
declare eksinx                = i4 with public, noconstant(0) ;28485

;Should never fall in here - checking just for safety - 28485
If (validate(PERFORMED_PRSNL_ID) = 0 OR validate(ACTION_PRSNL_ID) = 0)
    Set logmsg = build("Personnel not defined. Cannot create clinical event.")
    If (tCurIndex > 0 and CurIndex > 0)
      Set EKSData->tQual[tCurIndex].qual[CurIndex].logging = logmsg
    Endif
    call echo(logmsg, 1,4)
    Return (0)
Endif

if (validate(orderid) = 0)
    declare orderid = f8 with protect, noconstant(0.0)
    call echo("orderid not defined, declaring orderid = 0",1,4)
else
    call echo(build("orderid :", orderid),1,4)
endif


;Find the contributor system cd by meaning
Set CONTRIBUTOR_SYSTEM_CD = uar_get_code_by("MEANING",89,"POWERCHART")
If (CONTRIBUTOR_SYSTEM_CD = 0.0)
  SELECT into "nl:"
   FROM Code_Value C
   WHERE C.Code_Set = 89
     And C.Active_Ind = 1
     And C.Cdf_Meaning = "POWERCHART"
   Detail
     CONTRIBUTOR_SYSTEM_CD = C.Code_Value
   With NoCounter
Endif

;Find the event class cd by meaning
Set EVENT_CLASS_CD = uar_get_code_by("MEANING",53,"MDOC")
If (EVENT_CLASS_CD = 0.0)
  SELECT into "nl:"
    FROM Code_Value C
   WHERE C.Code_Set = 53
     And C.Active_Ind = 1
     And C.Cdf_Meaning = "MDOC"
   Detail
     EVENT_CLASS_CD = C.Code_Value
   With NoCounter
Endif

;Find the event relation cd by meaning
Set EVENT_RELTN_CD = uar_get_code_by("MEANING",24,"ROOT")
If (EVENT_RELTN_CD = 0.0)
  SELECT into "nl:"
   FROM Code_Value C
   WHERE C.Code_Set = 24
      And C.Active_Ind = 1
      And C.Cdf_Meaning = "ROOT"
   Detail
     EVENT_RELTN_CD = C.Code_Value
   With NoCounter
Endif

;Find the record status cd by meaning
Set RECORD_STATUS_CD = uar_get_code_by("MEANING",48,"ACTIVE")
If (RECORD_STATUS_CD = 0.0)
  SELECT into "nl:"
    FROM Code_Value C
   WHERE C.Code_Set = 48
     And C.Active_Ind = 1
     And C.Cdf_Meaning = "ACTIVE"
   Detail
     RECORD_STATUS_CD = C.Code_Value
   With NoCounter
Endif

;Find the result status cd by meaning
Set RESULT_STATUS_CD = uar_get_code_by("MEANING",8,"ANTICIPATED")
If (RESULT_STATUS_CD = 0.0)
  SELECT into "nl:"
   FROM Code_Value C
   WHERE C.Code_Set = 8
     And C.Active_Ind = 1
     And C.Cdf_Meaning = "ANTICIPATED"
   Detail
     RESULT_STATUS_CD = C.Code_Value
   With NoCounter
Endif

;Find the action status cd by meaning
Set ACTION_STATUS_CD = uar_get_code_by("MEANING",103,"REQUESTED")
If (ACTION_STATUS_CD = 0.0)
  SELECT into "nl:"
    FROM Code_Value C
   WHERE C.Code_Set = 103
     And C.Active_Ind = 1
     And C.Cdf_Meaning = "REQUESTED"
   Detail
     ACTION_STATUS_CD = C.Code_Value
   With NoCounter
Endif

;Find the action type cd by meaning
Set ACTION_TYPE_CD = uar_get_code_by("MEANING",21,"PERFORM")
If (ACTION_TYPE_CD = 0.0)
  SELECT into "nl:"
    FROM Code_Value C
   WHERE C.Code_Set = 21
     And C.Active_Ind = 1
     And C.Cdf_Meaning = "PERFORM"
   Detail
     ACTION_TYPE_CD = c.code_value
   With NoCounter
Endif

;Find the succession type cd by meaning
Set SUCCESSION_TYPE_CD = uar_get_code_by("MEANING",63,"CUM")
If (SUCCESSION_TYPE_CD = 0.0)
  SELECT into "nl:"
   FROM Code_Value C
   WHERE C.Code_Set = 63
      And C.Active_Ind = 1
      And C.Cdf_Meaning = "CUM"
   Detail
     SUCCESSION_TYPE_CD = C.Code_Value
   With NoCounter
Endif

;Find the storage cd by meaning
Set STORAGE_CD = uar_get_code_by("MEANING",25,"UNKNOWN")
If (STORAGE_CD = 0.0)
  SELECT into "nl:"
    FROM Code_Value C
   WHERE C.Code_Set = 25
     And C.Active_Ind = 1
     And C.Cdf_Meaning = "UNKNOWN"
   Detail
     STORAGE_CD = c.code_value
   With NoCounter
Endif

;Find the format cd by meaning
Set FORMAT_CD = uar_get_code_by("MEANING",23,"NONE")
If (FORMAT_CD = 0.0)
  SELECT into "nl:"
    FROM Code_Value C
   WHERE C.Code_Set = 23
     And C.Active_Ind = 1
     And C.Cdf_Meaning = "NONE"
   Detail
     FORMAT_CD = C.Code_Value
   With NoCounter
Endif

/**************************************************************
; DVDev Start Coding
**************************************************************/
;28485A Set person_id = EKSData->tQual[1]->qual[1]->person_id
;29495A Set ENCNTR_ID = EKSData->tQual[1]->qual[1]->Encntr_Id
set eksinx   = eks_common->event_repeat_index ;28485
set personid = event->qual[eksinx].person_id ;28485A
set encntrid = event->qual[eksinx].encntr_id ;28485A


CALL ECHO(build("personid: ", personid))
CALL ECHO(build("encntrid: ", encntrid))
Call echo(build("OrderId: ", orderid)) ;28485

/**** EXTRACT ANTICIPATED DOCUMENT NAME ****/
Set DOCUMENT_DISPLAY = fillstring(80," ")
Set Find_Var = Char(6)
Set Find_Pos = findstring(Find_Var,DOCUMENT_NAME)

If (Find_Pos > 0)
  /*******************************************************************************
  The following lines of code handle template parameters that have List box
  control types and/or hidden values. The record structure name should be the
  parameter name with "list" tacked to the end of it. The variable "orig_param"
  is the variable that the program EKS_T_PARSE_LIST will parse.Set it equal to the
  parameter being parsed. Then execute EKS_T_PARSE_LIST and it will fill out the
  record structure below. Use this as a template for any of these type parameters
  after the initial saving of the template.
  ********************************************************************************/
  Record DOCUMENT_NAMElist
  (
    1 Cnt = i4        ; the number of values parsed out of param1
    1 Qual[*]
      2 value = vc    ; the value to be used for comparison in the template
      2 display = vc  ; the display value for comparison value
  )
  Set orig_param = DOCUMENT_NAME
  EXECUTE EKS_t_parse_list
    WITH Replace(Reply, DOCUMENT_NAMElist)
  FREE Set orig_param

  CALL ECHO(build("Document_Name :",DOCUMENT_NAME))
  CALL ECHO(build("Parsed Document Name :",DOCUMENT_NAMElist->Qual[1]->value))

  SELECT into "nl:"
    Doc_Disp = uar_get_code_display(H.Event_Cd)
  FROM Encounter E,
       Him_Event_Extension H
  PLAN E
    WHERE E.Encntr_Id = encntrid ;28485A encntr_id
  JOIN H
    WHERE H.Event_Cd = cnvtreal(DOCUMENT_NAMElist->Qual[1]->value)
      And H.Active_Ind = 1
      And (H.Organization_Id +0 = E.Organization_Id
       Or (H.Organization_Id +0 = 0
       And Not Exists(SELECT OE.Organization_Id
          	           FROM Org_Event_Set_Reltn OE
                       WHERE OE.Organization_Id = E.Organization_Id
                        And OE.Active_Ind = 1)))
  Head Report
    DOCUMENT_CD = H.Event_Cd
    DOCUMENT_DISPLAY = Doc_Disp
  WITH NoCounter

  CALL ECHO(build("DOCUMENT_CD= ", DOCUMENT_CD))
  CALL ECHO(build("DOCUMENT_DISPLAY= ", DOCUMENT_DISPLAY))

  If (DOCUMENT_CD = 0)
    Set logmsg = build("Document Cd is not a part of the event_set.",DOCUMENT_CD)
    If (tCurIndex > 0 and CurIndex > 0)
      Set EKSData->tQual[tCurIndex].qual[CurIndex].logging = logmsg
    Endif
    Return (0)
  Endif

Else
  /** Search in the ProFile Documents Event Set for the document **/
  CALL ECHO("NO ACSII 6 FOUND")
  SELECT into "nl:"
  FROM Code_Value C,
       V500_Event_Set_Explode EX,
       Code_Value C1
  PLAN C
    WHERE C.Code_Set = 93
      And substring(1,7,C.Display_Key) = "PROFILE"
  JOIN EX
    WHERE EX.Event_Set_Cd = C.Code_Value
  JOIN C1
    WHERE EX.Event_Cd = C1.Code_Value
      And C1.Display_Key = DOCUMENT_NAME
      And C1.Active_Ind = 1
  Detail
    DOCUMENT_CD = C1.Code_Value
    DOCUMENT_DISPLAY = C1.Display
  WITH NoCounter

  CALL ECHO(build("DOCUMENT_CD=", DOCUMENT_CD))
  CALL ECHO(build("DOCUMENT_DISPLAY=", DOCUMENT_DISPLAY))

  If (DOCUMENT_CD = 0)
    Set logmsg = build("Document Cd is not a part of ProFile Documents.",DOCUMENT_CD)
    If (tCurIndex > 0 and CurIndex > 0)
      Set EKSData->tQual[tCurIndex].qual[CurIndex].logging = logmsg
    Endif
    Return (0)
  Endif
Endif
/**** DONE EXTRACTING ANTICIPATED DOCUMENT NAME ****/

/** Check to see if the document already exists **/
SELECT *
FROM Clinical_Event CE, Code_Value CV
PLAN CE
 WHERE CE.Encntr_Id = encntrid ;28485A - encntr_id
   And CE.person_id = personid ;28485A - person_id
   And CE.Event_Cd = DOCUMENT_CD
   And CE.Valid_Until_Dt_Tm = cnvtdatetime("31-DEC-2100 00:00:00")
   and ce.order_id+0 = orderid ;28485
   and ce.performed_prsnl_id = PERFORMED_PRSNL_ID ;ccummin4
JOIN CV
 WHERE CV.Code_Value = CE.Result_Status_Cd
   And cnvtupper(CV.Cdf_Meaning) != "INERROR"
   And cnvtupper(CV.Cdf_Meaning) != "INERRNOMUT"
   And cnvtupper(CV.Cdf_Meaning) != "INERRNOVIEW"
Detail
  ALREADY_EXISTS = 1
WITH NoCounter

CALL ECHO(build("ALREADY_EXISTS= ", ALREADY_EXISTS))
If (ALREADY_EXISTS = 1)
  Set logmsg =  "Anticipated document already exists."
   If (tcurindex > 0 and curindex > 0)
	Set EKSData->tQual[tCurIndex].qual[CurIndex].logging = logmsg
   Endif
   Return (0)
Endif

/*** CREATE A NEW ANTICIPATED DOCUMENT ***/


/** Populate the request to create a new clinical event **/
SELECT HP.Tag_Color_Active_Ind
  FROM Him_System_Params HP
 WHERE HP.Him_System_Params_Id > 0
Detail
   PUBLISH_IND = HP.Publish_Ind
   TAG_COMMON_IND = HP.Tag_Color_Common_Ind
   TAG_IND = HP.Tag_Color_Active_Ind
With NoCounter

Set CERequest->Clin_Event->Authentic_Flag        = 1
Set CERequest->Clin_Event->Contributor_System_Cd = CONTRIBUTOR_SYSTEM_CD
Set CERequest->Clin_Event->Encntr_Id             = encntrid ;28485A encntr_id
Set CERequest->Clin_Event->Event_Cd              = DOCUMENT_CD
Set CERequest->Clin_Event->Event_Class_Cd        = EVENT_CLASS_CD
Set CERequest->Clin_Event->Event_Reltn_Cd        = EVENT_RELTN_CD
Set CERequest->Clin_Event->Event_Start_Dt_Tm     = cnvtdatetime(curdate,curtime3)
Set CERequest->Clin_Event->Event_End_Dt_Tm       = cnvtdatetime(curdate,curtime3)
Set CERequest->Clin_Event->Event_Title_Text      = DOCUMENT_DISPLAY
Set CERequest->Clin_Event->Performed_Prsnl_Id    = PERFORMED_PRSNL_ID
Set CERequest->Clin_Event->person_id             = personid ;28485A person_id
Set CERequest->Clin_Event->Publish_Flag          = PUBLISH_IND
Set CERequest->Clin_Event->Record_Status_Cd      = RECORD_STATUS_CD
Set CERequest->Clin_Event->Result_Status_Cd      = RESULT_STATUS_CD
Set CERequest->Clin_Event->View_Level            = 1
set CERequest->clin_event.order_id               = orderid ;28485

Set stat = alterlist(CERequest->Event_Prsnl_List,1)
Set CERequest->Event_Prsnl_List[1]->Action_Dt_Tm     = cnvtdatetime(curdate,curtime3)
Set CERequest->Event_Prsnl_List[1]->Action_TZ        = CURTIMEZONESYS
Set CERequest->Event_Prsnl_List[1]->Action_Prsnl_Id  = ACTION_PRSNL_ID
Set CERequest->Event_Prsnl_List[1]->Action_Status_Cd = ACTION_STATUS_CD
Set CERequest->Event_Prsnl_List[1]->Action_Type_Cd   = ACTION_TYPE_CD
Set CERequest->Event_Prsnl_List[1]->person_id        = personid ;28485A person_id
Set CERequest->Event_Prsnl_List[1]->Request_Dt_Tm    = cnvtdatetime(curdate,curtime3)
Set CERequest->Event_Prsnl_List[1]->Request_TZ       = CURTIMEZONESYS

;call echorecord(cerequest)
%I CCLSOURCE:EKS_run1000012.inc


CALL ECHO("Back from clinical event server call")
/*** DONE CREATING A NEW ANTICIPATED DOCUMENT ***/

/*** ADD IN A TAG COLOR IF THE INPUT PARAMETER REQUIRES IT ***/
CALL ECHO(build("Tag_Color_Ind=", TAG_COLOR_IND))
CALL ECHO(build("Add Tag Color Ind:", TAG_IND))

If (TAG_COLOR_IND = "YES")
  If (TAG_IND = 1)
    FREE Record EKSTagRequest
    Record EKSTagRequest
    (
           1 Prsnl_Id               = f8
           1 person_id              = f8
           1 Encounter_Id           = f8
           1 Organization_Id        = f8
           1 Department_Cd          = f8
           1 Tag_Color_Cd           = f8
           1 Active_Status_Cd       = f8
           1 Active_Status_Dt_Tm    = dq8
           1 Active_Status_Prsnl_Id = f8
           1 Beg_Effective_Dt_Tm    = dq8.0
           1 End_Effective_Dt_Tm    = dq8.0
           1 Active_Ind             = i2
           1 Updt_Cnt               = i4
    )
    Set EKSTagRequest->Prsnl_Id  = ACTION_PRSNL_ID
    Set EKSTagRequest->person_id = personid ;28485A person_id

    Select into "nl:"
    From Encounter E
      Where E.Encntr_Id = encntrid ;28485A encntr_id

    Detail
      EKSTagRequest->Organization_Id = E.Organization_Id
    With Nocounter

    If(TAG_COMMON_IND = 1)
      ;If keeping documents across all physicians send zero
      Set EKSTagRequest->Encounter_Id = 0
    Else
      Set EKSTagRequest->Encounter_Id = encntrid ;28485A encntr_id
      Set EKSTagRequest->Organization_Id = 0
    Endif

    Set EKSTagRequest->Department_Cd = 0
    Set EKSTagRequest->Tag_Color_Cd = 0
    CALL ECHO(build("Org_Id:", EKSTagRequest->Organization_Id))
    EXECUTE HIM_ADD_TAG_COLOR_EKS
      ;Added to resolve discrepancy in record names between scripts
      WITH Replace(EKSRequest, EKSTagRequest)
    Set logmsg = "Finished with Him_eks_add_antic_doc_core script."

    FREE Record EKSTagRequest
  Endif
Endif
/*** DONE ADDING IN A TAG COLOR IF THE INPUT PARAMETER REQUIRES IT ***/

set retval = 100 ;28485
Return (retval)

end
go
