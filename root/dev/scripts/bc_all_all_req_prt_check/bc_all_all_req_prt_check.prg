;***********************************************************************************************************************
;Source Code File: BC_ALL_ALL_REQ_PRT_CHECK.PRG
;Original Author:  Barry Wong
;Date Written:     May 2018
;
;Comments: Include File contains standard subroutines which determines if a requisition is to be printed based on:
;
;          1. Order status (ensure no duplicates using DISPLAY_KEY)
;          2. Deparment order status (ensure no duplicates using DISPLAY_KEY)
;          3. Request source (Autoprint or Reprint)
;
;             Note: Autoprint can have a system personnel id of 0.00, 1.00, 2.00 or 3.00
;
;
;***********************************************************************************************************************
;												*MODIFICATION HISTORY*
;***********************************************************************************************************************
;
;Rev  Date         Jira       Programmer             Comment
;---  -----------  ---------  ---------------------  -------------------------------------------------------------------
;000  03-May-2018             Barry Wong             Initial build
;001  19-Jul-2018  CST-multi  Barry Wong             Removed order action logic from sREQ_MIFutureReq
;002  11-Oct-2018  CST-34866  Barry Wong             Modified sREQ_TransmedOrd to allow Cancelled and Discontinue order
;                                                    Added sREQ_Pass_TMO_Print_Chk
;003  12-Oct-2018  CST-34868  Barry Wong             Modified sREQ_TMIVIgOrd to allow Cancelled and Discontinue order
;004  03-Apr-2019  CST-42715  Barry Wong             Added sTissueBlockOrder
;005  13-Jun-2019  CST-47372  Barry Wong             Added sREQ_PatPassMed
;006  19-Aug-2019  CST-52549  Barry Wong             Added sREQ_VenousSampleReq
;007  12-SEP-2019  CST-50746  Barry Wong             Added sREQ_PulmonaryFnReq
;008  18-SEP-2019  CST-50948  Barry Wong             Added sREQ_BoneMarrow
;009  18-OCT-2019  CST-50948  Jeremy Gunn            Modified cv200_BMAspirateAndBiopsy
;010  25-OCT-2019  CST-50746  Jeremy Gunn            Reworked sREQ_PulmonaryFnReq
;011  28-Nov-2019  CST-64020  Barry Wong             Added InProcess / Collected logic for Lab
;012  18-Dec-2019  CST-62536  Barry Wong             Added sREQ_DeceaseNote
;013  21-Jan-2020  CST-62536  Barry Wong             Modified sREQ_DeceaseNote to allow only order status of "Ordered"
;014  05-Feb-2020  CST-68962  Barry Wong             Refined reprint criteria for sREQ_ECGReq
;015  20-May-2020  CST-8968   Barry Wong             Added sREQ_AmbReferral
;016  29-May-2020  CST-83593  Barry Wong             Added sCard_Watermark, sCard_PrevStatus
;017  27-Jul-2020  CST-52530  Jeremy Gunn            Added sREQ_TransfusneoReq
;018  30-Jul-2020  CST-92435  Barry Wong             Added sREQ_AcuteDietOrder
;019  05-Aug-2020  CST-91478  Barry Wong             Added sREQ_GetLabResult
;020  01-Sep-2020  CST-97756  Barry Wong             Modified sREQ_AmbReferral to allow printing for Ordered/Ordered
;021  04-Sep-2020  CST-91478  Barry Wong             Modified sREQ_GetLabResult to include the units in the results
;                                                    string. Added logic to pull the Completed date time.
;022  11-Sep-2020  CST-92435  Barry Wong             Modified sREQ_AcuteDietOrder to not print the Cancelled or
;                                                    Discontinued requisition for Oral Diet requisition and for Send Meal
;                                                    and Additional Diet Information (Diet Communication) orders
;023  25-Sep-2020  CST-52530  Jeremy Gunn            Reworked trigger logic for sREQ_TransfusneoReq
;***********************************************************************************************************************
 
drop program bc_all_all_req_prt_check go
create program bc_all_all_req_prt_check
 
;==============================================================
; DVDev DECLARED VARIABLES
;==============================================================
 
; Order Action (Codeset 6003)
declare cv6003_Order           = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 6003, "ORDER" )), persistscript  ;019
declare cv6003_Complete        = f8 with protect, constant(uar_get_code_by("MEANING",    6003, "COMPLETE" )), persistscript  ;021
declare cv6003_Cancel          = f8 with protect, constant(uar_get_code_by("MEANING", 6003, "CANCEL" ) ) , persistscript ;023
declare cv6003_Discontinue     = f8 with protect, constant(uar_get_code_by("MEANING", 6003, "DISCONTINUE" ) ), persistscript ;023
declare cv6003_Activate        = f8 with protect, constant(uar_get_code_by("MEANING", 6003, "ACTIVATE" ) ), persistscript ;023
 
 
; Order Statuses (Codeset 6004)
declare cvOS_Canceled          = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 6004, "CANCELED" )), persistscript
declare cvOS_Completed         = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 6004, "COMPLETED" )), persistscript
declare cvOS_Voided            = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 6004, "VOIDED" )), persistscript
declare cvOS_Discontinued      = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 6004, "DISCONTINUED" )), persistscript
declare cvOS_Future            = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 6004, "FUTURE" )), persistscript
declare cvOS_InComplete        = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 6004, "INCOMPLETE" )), persistscript
declare cvOS_InProcess         = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 6004, "INPROCESS" )), persistscript
declare cvOS_OnHoldMedStudent  = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 6004, "ONHOLDMEDSTUDENT" )), persistscript
declare cvOS_Ordered           = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 6004, "ORDERED" )), persistscript
declare cvOS_PendingReview     = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 6004, "PENDINGREVIEW" )), persistscript
declare cvOS_Suspended         = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 6004, "SUSPENDED" )), persistscript
declare cvOS_Unscheduled       = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 6004, "UNSCHEDULED" )), persistscript
declare cvOS_TranferCanceled   = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 6004, "TRANSFERCANCELED" )), persistscript
declare cvOS_PendingComplete   = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 6004, "PENDINGCOMPLETE" )), persistscript
declare cvOS_VoidedWithResults = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 6004, "VOIDEDWITHRESULTS" )), persistscript
 
; Department Statuses (Codeset 14281)
declare cvDS_Canceled             = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "CANCELED" )), persistscript
declare cvDS_Collected            = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "COLLECTED" )), persistscript
declare cvDS_Completed            = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "COMPLETED" )), persistscript
declare cvDS_Deleted              = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "DELETED" )), persistscript
declare cvDS_Discontinued         = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "DISCONTINUED" )), persistscript
declare cvDS_Dispatched           = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "DISPATCHED" )), persistscript
declare cvDS_ExamCompleted        = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "EXAMCOMPLETED" )), persistscript
declare cvDS_ExamOrdered          = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "EXAMORDERED" )), persistscript
declare cvDS_ExamRemoved          = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "EXAMREMOVED" )), persistscript
declare cvDS_LabActivityDeleted   = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "LABACTIVITYDELETED" )), persistscript
declare cvDS_LabResultsDeleted    = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "LABRESULTSDELETED" )), persistscript
declare cvDS_OnHold               = f8 with protect, constant(uar_get_code_by("MEANING",    14281, "ONHOLD" )), persistscript
declare cvDS_Ordered              = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "ORDERED" )), persistscript
declare cvDS_ResultPreliminary    = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "RESULTPRELIMINARY" )), persistscript
declare cvDS_LabScheduled         = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "LABSCHEDULED" )), persistscript
declare cvDS_Stain                = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "STAIN" )), persistscript
declare cvDS_Susceptibility       = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "SUSCEPTIBILITY" )), persistscript
declare cvDS_Received             = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "RECEIVED" )), persistscript
declare cvDS_Initiated            = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "INITIATED" )), persistscript
declare cvDS_ResultPartial        = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "RESULTPARTIAL" )), persistscript
declare cvDS_ExamReplaced         = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "EXAMREPLACED" )), persistscript
declare cvDS_ExamStarted          = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "EXAMSTARTED" )), persistscript
declare cvDS_Final                = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "FINAL" )), persistscript
declare cvDS_PendingCollection    = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "PENDINGCOLLECTION" )), persistscript
declare cvDS_SeeMpagesAndChartlet = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "SEEMPAGESANDCHARTLET" )), persistscript
declare cvDS_PartialFill          = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "PARTIALFILL" )), persistscript
declare cvDS_Refill               = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "REFILL" )), persistscript
declare cvDS_Historical           = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "HISTORICAL" )), persistscript
declare cvDS_OnFile               = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "ONFILE" )), persistscript
declare cvDS_RxOnHold             = f8 with protect, constant(uar_get_code_by("MEANING",    14281, "RXONHOLD" )), persistscript
declare cvDS_TransferOut          = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "TRANSFEROUT" )), persistscript
declare cvDS_RxHistoryIncomplete  = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "RXHISTORYINCOMPLETE" )), persistscript
declare cvDS_CVScheduled          = f8 with protect, constant(uar_get_code_by("MEANING",    14281, "CVSCHEDULED" )), persistscript
declare cvDS_Arrived              = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "ARRIVED" )), persistscript
declare cvDS_ProcedureInProcess   = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "PROCEDUREINPROCESS" )), persistscript
declare cvDS_ProcedureCompleted   = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "PROCEDURECOMPLETED" )), persistscript
declare cvDS_Verified             = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "VERIFIED" )), persistscript
declare cvDS_Unsigned             = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "UNSIGNED" )), persistscript
declare cvDS_Signed               = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "SIGNED" )), persistscript
declare cvDS_EDReview             = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 14281, "EDREVIEW" )), persistscript
 
; Orders
declare cvRBC_Order_Type          = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 200, "REDBLOODCELLTRANSFUSION" )), persistscript
declare cv200_AdditionalDietInformation = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 200, "ADDITIONALDIETINFORMATION" )), persistscript  ;022
declare cv200_SendMeal           = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 200, "SENDMEAL" )), persistscript   ;022
 
; Miscellaneous Variables
declare vReqOrderStatus = f8 with persistscript
declare vReqDeptStatus  = f8 with persistscript
 
;==============================================================
; DVDev DECLARED SUBROUTINES
;==============================================================
; Lab
declare sREQ_PrevDeptStatusExist(pOrderID = f8, pPrevStatus = f8, pCurrStatus = f8 ) = i2 with copy, persist
declare sREQ_BloodGasReq(pOrderID = f8, pPrintPrsnlID = f8 ) = i2 with copy, persist
declare sREQ_CordBloodReq(pOrderID = f8, pPrintPrsnlID = f8 ) = i2 with copy, persist
declare sREQ_TransmedOrd(pOrderID = f8, pPrintPrsnlID = f8 ) = i2 with copy, persist
declare sREQ_TransmedReq(pOrderID = f8, pPrintPrsnlID = f8 ) = i2 with copy, persist
declare sREQ_TranscondReq(pOrderID = f8, pPrintPrsnlID = f8 ) = i2 with copy, persist
declare sREQ_TMIVIgReq(pOrderID = f8, pPrintPrsnlID = f8 ) = i2 with copy, persist
declare sREQ_PathoSurgReq(pOrderID = f8, pPrintPrsnlID = f8 ) = i2 with copy, persist
declare sREQ_PathoOralgReq(pOrderID = f8, pPrintPrsnlID = f8 ) = i2 with copy, persist
declare sREQ_OutpatientReq(pOrderID = f8, pPrintPrsnlID = f8 ) = i2 with copy, persist
declare sREQ_TMIVIgOrd(pOrderID = f8, pPrintPrsnlID = f8 ) = i2 with copy, persist
declare sREQ_Pass_TMO_Print_Chk(pOrderID = f8, pPrintPrsnlID = f8, pPrinter = vc ) = i2 with copy, persist   ;002
declare sREQ_VenousSampleReq(pOrderID = f8, pPrintPrsnlID = f8 ) = i2 with copy, persist  ;006
declare sTissueBlockOrder(pOrderStatus = f8, pDeptStatus = f8 ) = i2 with copy, persist
declare sREQ_BoneMarrow(pOrderStatus = f8, pDeptStatus = f8 ) = i2 with copy, persist
declare sREQ_GetLabResult(pPersonID = f8, pOrderID = f8, pLabCode = f8 ) = vc with copy, persist  ;019
; Cardiology
declare sREQ_ECGReq(pOrderID = f8, pPrintPrsnlID = f8 ) = i2 with copy, persist
declare sREQ_CardFutReq(pOrderID = f8, pPrintPrsnlID = f8 ) = i2 with copy, persist
declare sCard_Watermark(pOrderID = f8 ) = i2 with copy, persist    ;016
declare sCard_PrevStatus(pOrderID = f8 ) = i2 with copy, persist   ;016
; MI
declare sREQ_MIFutureReq(pOrderID = f8, pPrintPrsnlID = f8 ) = i2 with copy, persist
; Acute Care
declare sREQ_PatPassMed(pOrderID = f8, pPrintPrsnlID = f8 ) = i2 with copy, persist
declare sREQ_AcuteDietOrder(pRqstRecd = vc(REF), pOrderRecd = vc(REF) ) = i2 with copy, persist
; Ambulatory
declare sREQ_PulmonaryFnReq(pOrderID = f8, pPrintPrsnlID = f8 ) = i2 with copy, persist
declare sREQ_AmbReferral(pOrderID = f8, pPrintPrsnlID = f8 ) = i2 with copy, persist
;Registration
declare sREQ_DeceaseNote(pOrderID = f8, pPrintPrsnlID = f8 ) = i2 with copy, persist
declare sREQ_TransfusneoReq(pOrderID = f8, pPrintPrsnlID = f8 ) = i2 with copy, persist ;017
 
;==============================================================
; DVDev DEFINED SUBROUTINES
;==============================================================
subroutine sREQ_PrevDeptStatusExist(pOrderID, pPrevStatus, pCurrStatus )
  declare sDept_Status_Ind = i2 with protect
  set sDept_Status_Ind = 0
 
  select into "nl:"
         sDeptStatus = oa.dept_status_cd
    from orders o,
         order_action oa
   where o.order_id = pOrderID
     and oa.order_id = o.order_id
     and oa.dept_status_cd = pPrevStatus
 
  detail
    if (o.dept_status_cd = pCurrStatus )
      sDept_Status_Ind = 1
    endif
 
  with nocounter, time=10
  return(sDept_Status_Ind )
end
;--------------------------------------------------------------
 
subroutine sREQ_BloodGasReq(pOrderID, pPrintPrsnlID )
  declare sPrint_Requisition = i2 with protect
  set sPrint_Requisition = 0
 
  select into "nl:"
         sOrderStatus = o.order_status_cd
       , sDeptStatus = o.dept_status_cd
    from orders o
   where o.order_id = pOrderID
 
  detail
    if (
        (sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_Ordered ) or
        (sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_PendingCollection ) or
        (sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_Collected ) or
        (sOrderStatus = cvOS_InProcess and sDeptStatus = cvDS_Received and pPrintPrsnlID > 5.00 ) or
        (sOrderStatus = cvOS_InProcess and sDeptStatus = cvDS_Collected and pPrintPrsnlID > 5.00 ) or  ;011
        (sOrderStatus = cvOS_InProcess and sDeptStatus = cvDS_ResultPartial and pPrintPrsnlID > 5.00 )
       )
      sPrint_Requisition = 1
    endif
 
  with nocounter, time=10
  return(sPrint_Requisition )
end
;--------------------------------------------------------------
 
subroutine sREQ_CordBloodReq(pOrderID, pPrintPrsnlID )
  declare sPrint_Requisition = i2 with protect
  set sPrint_Requisition = 0
 
  select into "nl:"
         sOrderStatus = o.order_status_cd
       , sDeptStatus = o.dept_status_cd
    from orders o
   where o.order_id = pOrderID
 
  detail
    if (
        (sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_Ordered ) or
        (sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_PendingCollection ) or
        (sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_Collected ) or
        (sOrderStatus = cvOS_InProcess and sDeptStatus = cvDS_Received and pPrintPrsnlID > 5.00 ) or
        (sOrderStatus = cvOS_InProcess and sDeptStatus = cvDS_Collected and pPrintPrsnlID > 5.00 ) or  ;011
        (sOrderStatus = cvOS_InProcess and sDeptStatus = cvDS_ResultPartial and pPrintPrsnlID > 5.00 )
       )
      sPrint_Requisition = 1
    endif
 
  with nocounter, time=10
  return(sPrint_Requisition )
end
;--------------------------------------------------------------
 
subroutine sREQ_TransmedOrd(pOrderID, pPrintPrsnlID )
  declare sPrint_Requisition = i2 with protect
  set sPrint_Requisition = 0
 
  select into "nl:"
         sOrderStatus = o.order_status_cd
       , sDeptStatus = o.dept_status_cd
    from orders o
   where o.order_id = pOrderID
 
  detail
    if (
        (sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_Ordered ) or
        (sOrderStatus = cvOS_InProcess and sDeptStatus = cvDS_Received and pPrintPrsnlID > 5.00 ) or
        (sOrderStatus = cvOS_InProcess and sDeptStatus = cvDS_SeeMpagesAndChartlet and o.catalog_cd not = cvRBC_Order_Type and pPrintPrsnlID > 5.00 ) or
        (sOrderStatus = cvOS_InProcess and sDeptStatus = cvDS_ResultPartial and o.catalog_cd = cvRBC_Order_Type and pPrintPrsnlID > 5.00 ) or
        (sOrderStatus = cvOS_Canceled and sDeptStatus = cvDS_Canceled ) or       ;002
        (sOrderStatus = cvOS_Discontinued and sDeptStatus = cvDS_Discontinued )  ;002
       )
      sPrint_Requisition = 1
    endif
 
  with nocounter, time=10
  return(sPrint_Requisition )
end
;--------------------------------------------------------------
 
subroutine sREQ_TransmedReq(pOrderID, pPrintPrsnlID )
  declare sPrint_Requisition = i2 with protect
  set sPrint_Requisition = 0
 
  select into "nl:"
         sOrderStatus = o.order_status_cd
       , sDeptStatus = o.dept_status_cd
    from orders o
   where o.order_id = pOrderID
 
  detail
    if (
        (sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_Ordered ) or
        (sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_PendingCollection ) or
        (sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_Collected ) or
        (sOrderStatus = cvOS_InProcess and sDeptStatus = cvDS_Received and pPrintPrsnlID > 5.00 ) or
        (sOrderStatus = cvOS_InProcess and sDeptStatus = cvDS_ResultPartial and pPrintPrsnlID > 5.00 ) or
        (sOrderStatus = cvOS_InProcess and sDeptStatus = cvDS_Collected and pPrintPrsnlID > 5.00 ) or  ;011
        (sOrderStatus = cvOS_Future and sDeptStatus = cvDS_OnHold and pPrintPrsnlID > 5.00 )
       )
      sPrint_Requisition = 1
    endif
 
  with nocounter, time=10
  return(sPrint_Requisition )
end
;--------------------------------------------------------------
 
subroutine sREQ_TranscondReq(pOrderID, pPrintPrsnlID )
  declare sPrint_Requisition = i2 with protect
  set sPrint_Requisition = 0
 
  select into "nl:"
         sOrderStatus = o.order_status_cd
       , sDeptStatus = o.dept_status_cd
    from orders o
   where o.order_id = pOrderID
 
  detail
    if (
        (sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_Ordered and pPrintPrsnlID > 5.00 ) or
        (sOrderStatus = cvOS_Completed and sDeptStatus = cvDS_Completed and pPrintPrsnlID > 5.00 )
       )
      sPrint_Requisition = 1
    endif
 
  with nocounter, time=10
  return(sPrint_Requisition )
end
;--------------------------------------------------------------
 
subroutine sREQ_TMIVIgReq(pOrderID, pPrintPrsnlID )
  declare sPrint_Requisition = i2 with protect
  set sPrint_Requisition = 0
 
  select into "nl:"
         sOrderStatus = o.order_status_cd
       , sDeptStatus = o.dept_status_cd
    from orders o
   where o.order_id = pOrderID
 
  detail
    if (
        (sOrderStatus = cvOS_Completed and sDeptStatus = cvDS_Completed )
       )
      sPrint_Requisition = 1
    endif
 
  with nocounter, time=10
  return(sPrint_Requisition )
end
;--------------------------------------------------------------
 
subroutine sREQ_PathoSurgReq(pOrderID, pPrintPrsnlID )
  declare sPrint_Requisition = i2 with protect
  set sPrint_Requisition = 0
 
  select into "nl:"
         sOrderStatus = o.order_status_cd
       , sDeptStatus = o.dept_status_cd
    from orders o
   where o.order_id = pOrderID
 
  detail
    if (
        (sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_Ordered ) or
        (sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_Collected ) or
        (sOrderStatus = cvOS_InProcess and sDeptStatus = cvDS_Collected and pPrintPrsnlID > 5.00 ) or  ;011
        (sOrderStatus = cvOS_InProcess and sDeptStatus = cvDS_Received and pPrintPrsnlID > 5.00 )
       )
      sPrint_Requisition = 1
    endif
 
  with nocounter, time=10
  return(sPrint_Requisition )
end
;--------------------------------------------------------------
 
subroutine sREQ_PathoOralgReq(pOrderID, pPrintPrsnlID )
  declare sPrint_Requisition = i2 with protect
  set sPrint_Requisition = 0
 
  select into "nl:"
         sOrderStatus = o.order_status_cd
       , sDeptStatus = o.dept_status_cd
    from orders o
   where o.order_id = pOrderID
 
  detail
    if (
        (sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_Ordered ) or
        (sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_Collected ) or
        (sOrderStatus = cvOS_InProcess and sDeptStatus = cvDS_Collected and pPrintPrsnlID > 5.00 ) or  ;011
        (sOrderStatus = cvOS_InProcess and sDeptStatus = cvDS_Received and pPrintPrsnlID > 5.00 )
       )
      sPrint_Requisition = 1
    endif
 
  with nocounter, time=10
  return(sPrint_Requisition )
end
;--------------------------------------------------------------
 
subroutine sREQ_OutpatientReq(pOrderID, pPrintPrsnlID )
  declare sPrint_Requisition = i2 with protect
  set sPrint_Requisition = 0
 
  select into "nl:"
         sOrderStatus = o.order_status_cd
       , sDeptStatus = o.dept_status_cd
    from orders o
   where o.order_id = pOrderID
 
  detail
    if (
        (sOrderStatus = cvOS_Future and sDeptStatus = cvDS_OnHold ) or
        (sOrderStatus = cvOS_Future and sDeptStatus = 0.00 )
       )
      sPrint_Requisition = 1
    endif
 
  with nocounter, time=10
  return(sPrint_Requisition )
end
;--------------------------------------------------------------
 
subroutine sREQ_TMIVIgOrd(pOrderID, pPrintPrsnlID )
  declare sPrint_Requisition = i2 with protect
  set sPrint_Requisition = 0
 
  select into "nl:"
         sOrderStatus = o.order_status_cd
       , sDeptStatus = o.dept_status_cd
    from orders o
   where o.order_id = pOrderID
 
  detail
    if (
        (sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_Ordered ) or
        (sOrderStatus = cvOS_InProcess and sDeptStatus = cvDS_Received and pPrintPrsnlID > 5.00 ) or
        (sOrderStatus = cvOS_InProcess and sDeptStatus = cvDS_SeeMpagesAndChartlet and pPrintPrsnlID > 5.00 ) or
        (sOrderStatus = cvOS_Canceled and sDeptStatus = cvDS_Canceled ) or       ;003
        (sOrderStatus = cvOS_Discontinued and sDeptStatus = cvDS_Discontinued )  ;003
       )
      sPrint_Requisition = 1
    endif
 
  with nocounter, time=10
  return(sPrint_Requisition )
end
;--------------------------------------------------------------
 
subroutine sREQ_Pass_TMO_Print_Chk(pOrderID, pPrintPrsnlID, pPrinter )
  declare sPrint_Requisition = i2 with protect
  declare route_description = vc
 
  set route_description = "CCL - TMS Lab Printers"
 
  if (pPrintPrsnlID > 5.00 )
    ; No check needed for reprinting as the printer is user selected
    set sPrint_Requisition = 1
  else
    ; Default: Cancelled and Discontinued orders always print to
    ;          both printers so no additional check is needed
    select into "nl:"
           sOrderStatus = o.order_status_cd
      from orders   o
     where o.order_id = pOrderID
 
    detail
      if (sOrderStatus = cvOS_Canceled or sOrderStatus = cvOS_Discontinued  )
        sPrint_Requisition = 1
      else
        sPrint_Requisition = 0
      endif
    with nocounter, time=10
 
    ; Check if printer passed in the request is a lab printer if
    ; the order is not Canceled or Discontinued. Printing is turned
    ; on if the printer is in the Lab printer special route
    if (sPrint_Requisition = 0 )
      select into "nl:"
             printer_name = dfp.printer_name
        from dcp_output_route   dor
           , dcp_flex_rtg   dfr
           , dcp_flex_printer   dfp
       where dor.route_description = route_description
         and dfr.dcp_output_route_id = dor.dcp_output_route_id
         and dfp.dcp_output_route_id = dor.dcp_output_route_id
         and dfp.dcp_flex_rtg_id = dfr.dcp_flex_rtg_id
         and cnvtupper(dfp.printer_name ) = cnvtupper(pPrinter )
 
      detail
        sPrint_Requisition = 1
      with nocounter, time=10
    endif
  endif
 
  return(sPrint_Requisition )
end
 
;--------------------------------------------------------------
 
subroutine sREQ_ECGReq(pOrderID, pPrintPrsnlID )
  declare sPrint_Requisition = i2 with protect
  set sPrint_Requisition = 0
 
  select into "nl:"
         sOrderStatus = o.order_status_cd
       , sDeptStatus = o.dept_status_cd
    from orders o
   where o.order_id = pOrderID
 
  detail
    if (
;014        (sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_Ordered and pPrintPrsnlID < 5.00 ) or
;014        (sOrderStatus = cvOS_Future and sDeptStatus = cvDS_OnHold and pPrintPrsnlID < 5.00 ) or
;014        (sOrderStatus = cvOS_Ordered and pPrintPrsnlID > 5.00 ) or
;014        (sOrderStatus = cvOS_Future and pPrintPrsnlID > 5.00 )
        (sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_Ordered ) or  ;014
        (sOrderStatus = cvOS_Future and sDeptStatus = cvDS_OnHold )       ;014
       )
      sPrint_Requisition = 1
    endif
 
  with nocounter, time=10
  return(sPrint_Requisition )
end
;--------------------------------------------------------------
 
subroutine sREQ_CardFutReq(pOrderID, pPrintPrsnlID )
  declare sPrint_Requisition = i2 with protect
  set sPrint_Requisition = 0
 
  select into "nl:"
         sOrderStatus = o.order_status_cd
       , sDeptStatus = o.dept_status_cd
    from orders o
   where o.order_id = pOrderID
 
  detail
    if (
        (sOrderStatus = cvOS_Future and sDeptStatus = cvDS_OnHold and pPrintPrsnlID < 5.00 )
       )
      sPrint_Requisition = 1
    endif
 
  with nocounter, time=10
  return(sPrint_Requisition )
end
;--------------------------------------------------------------
 
subroutine sCard_Watermark(pOrderID )
  declare sWatermark_Type = i2 with protect
  set sWatermark_Type = 0
 
  select into "nl:"
         sOrderStatus = o.order_status_cd
    from orders o
   where o.order_id = pOrderID
 
  detail
    if (sOrderStatus = cvOS_Canceled )
      sWatermark_Type = 1
    elseif (sOrderStatus = cvOS_Discontinued )
      sWatermark_Type = 2
    elseif (sOrderStatus = cvOS_Voided )
      sWatermark_Type = 3
    else
      sWatermark_Type = 0
    endif
 
  with nocounter, time=10
  return(sWatermark_Type )
end
;--------------------------------------------------------------
 
subroutine sCard_PrevStatus(pOrderID )
  declare iCheckPrevStatus = i2 with protect, noconstant(0)
  declare iFuture_Status = i2 with protect, noconstant(0)
  declare iStatus_Count = i2 with protect, noconstant(0)
 
  ; Get current status
  select into "nl:"
         sOrderStatus = o.order_status_cd
    from orders o
   where o.order_id = pOrderID
 
  detail
    if (sOrderStatus = cvOS_Canceled or
        sOrderStatus = cvOS_Discontinued or
        sOrderStatus = cvOS_Voided )
      iCheckPrevStatus = 1
    endif
  with nocounter
 
  ; Look for previous status if required
  if (iCheckPrevStatus = 1 )
    select into "nl:"
           StatusDttm = oa.action_dt_tm,
           sOrderStatus = oa.order_status_cd
      from order_action oa
     where oa.order_id = pOrderID
 
    order by oa.action_dt_tm desc
 
    detail
      iStatus_Count = iStatus_Count + 1
      if (iStatus_Count = 2)
        if (sOrderStatus = cvOS_Future )
          iFuture_Status = 1
        endif
      endif
  endif
 
;  ; Look for initial status if required
;  if (iCheckFirstStatus = 1 )
;    select into "nl:"
;           StatusDttm = oa.action_dt_tm,
;           sOrderStatus = oa.order_status_cd
;      from order_action oa
;     where oa.order_id = pOrderID
;
;    order by oa.action_dt_tm
;
;    head oa.order_id
;      if (sOrderStatus = cvOS_Future )
;        iFuture_Status = 1
;      endif
;    with nocounter
;  endif
  return(iFuture_Status )
end
;--------------------------------------------------------------
 
subroutine sREQ_MIFutureReq(pOrderID, pPrintPrsnlID )
  declare sPrint_Requisition = i2 with protect
  set sPrint_Requisition = 0
 
  select into "nl:"
         sOrderStatus = o.order_status_cd
       , sDeptStatus = o.dept_status_cd
    from orders o
   where o.order_id = pOrderID
 
  detail
    if (
        (sOrderStatus = cvOS_Future and sDeptStatus = cvDS_OnHold )
       )
      sPrint_Requisition = 1
    endif
 
  with nocounter, time=10
 
;001 Start
;  ; Reprinting is always allowed; Autoprint allowed only if
;  ; there are no action qualifier on the order
;
;  if (sPrint_Requisition = 1 and pPrintPrsnlID < 5.00 )
;    select into "nl:"
;      from order_action   oa
;     where oa.order_id = pOrderID
;       and oa.action_qualifier_cd > 0.00
;
;    detail
;      sPrint_Requisition = 0
;
;    with nocounter, time=10
;  endif
;001 End
 
  return(sPrint_Requisition )
end
;--------------------------------------------------------------
 
subroutine sTissueBlockOrder(pOrderStatus, pDeptStatus )
  declare sInclude_Order = i21 with protect
  set sInclude_Order = 0
 
  if (
      (pOrderStatus = cvOS_Ordered and pDeptStatus = cvDS_Ordered ) or
      (pOrderStatus = cvOS_Ordered and pDeptStatus = cvDS_PendingCollection ) or
      (pOrderStatus = cvOS_Ordered and pDeptStatus = cvDS_Collected ) or
      (pOrderStatus = cvOS_InProcess and pDeptStatus = cvDS_Received ) or
      (pOrderStatus = cvOS_InProcess and pDeptStatus = cvDS_ResultPartial ) or
      (pOrderStatus = cvOS_Completed and pDeptStatus = cvDS_Completed ) or
      (pOrderStatus = cvOS_Future and pDeptStatus = cvDS_OnHold )
     )
    set sInclude_Order = 1
  endif
 
  return(sInclude_Order )
end
 
;--------------------------------------------------------------
 
subroutine sREQ_PatPassMed(pOrderID, pPrintPrsnlID )
  declare sPrint_Requisition = i2 with protect
  set sPrint_Requisition = 0
 
  select into "nl:"
         sOrderStatus = o.order_status_cd
       , sDeptStatus = o.dept_status_cd
    from orders o
   where o.order_id = pOrderID
 
  detail
    if (
        (sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_Ordered ) or
        (sOrderStatus = cvOS_Ordered and pPrintPrsnlID > 5.00 )
       )
      sPrint_Requisition = 1
    endif
 
  with nocounter, time=10
  return(sPrint_Requisition )
end
 
;--------------------------------------------------------------
 
subroutine sREQ_AcuteDietOrder(pRqstRecd, pOrderRecd )
  declare sPrint_Requisition = i2 with protect
  set sPrint_Requisition = 0
 
  if (pRqstRecd->print_prsnl_id > 5.00 )
    set sPrint_Requisition = 1
  else
    select into "nl:"
           sOrderStatus = o.order_status_cd
         , sDeptStatus = o.dept_status_cd
      from orders o
     where o.order_id = pOrderRecd->order_id
 
    detail
      if (
          (sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_Ordered ) or
;022          (sOrderStatus = cvOS_Canceled and sDeptStatus = cvDS_Canceled ) or
;002          (sOrderStatus = cvOS_Discontinued and sDeptStatus = cvDS_Discontinued )
;022 Start
          (sOrderStatus = cvOS_Canceled and sDeptStatus = cvDS_Canceled and
           o.catalog_cd not = cv200_AdditionalDietInformation and o.catalog_cd not = cv200_SendMeal and
           pOrderRecd->req_type_ind not = 1) or
 
          (sOrderStatus = cvOS_Discontinued and sDeptStatus = cvDS_Discontinued and
           o.catalog_cd not = cv200_AdditionalDietInformation and o.catalog_cd not = cv200_SendMeal and
           pOrderRecd->req_type_ind not = 1)
;022 End
         )
        sPrint_Requisition = 1
      endif
;022 Start
      ; Bypass Enteral Feeding for child orders
      if (pOrderRecd->req_type_ind = 3 and o.template_order_id > 0.00 )
        sPrint_Requisition = 0
      endif
;022 End
    with nocounter, time=10
  endif
 
  return(sPrint_Requisition )
end
 
;--------------------------------------------------------------
 
subroutine sREQ_VenousSampleReq(pOrderID, pPrintPrsnlID )
  declare sPrint_Requisition = i2 with protect
  set sPrint_Requisition = 0
 
  select into "nl:"
         sOrderStatus = o.order_status_cd
       , sDeptStatus = o.dept_status_cd
    from orders o
   where o.order_id = pOrderID
 
  detail
    if (
        (sOrderStatus = cvOS_InProcess and sDeptStatus = cvDS_Collected and pPrintPrsnlID > 5.00 ) or  ;011
        (sOrderStatus = cvOS_Ordered and (sDeptStatus = cvDS_Ordered or sDeptStatus = cvDS_Collected ) )
       )
      sPrint_Requisition = 1
    endif
 
  with nocounter, time=10
  return(sPrint_Requisition )
end
 
;--------------------------------------------------------------
 
subroutine sREQ_PulmonaryFnReq(pOrderID, pPrintPrsnlID )
  declare sPrint_Requisition = i2 with protect
  declare cv16449_PatientType = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 16449, "PATIENTTYPE"))
 
  set sPrint_Requisition = 0
 
  select into "nl:"
    from order_detail  od
   where od.order_id = pOrderID
     and od.oe_field_id = cv16449_PatientType
  order by od.action_sequence desc
 
  head od.order_id
    if (od.oe_field_display_value = "Inpatient" )
      sPrint_Requisition = 1
    endif
  with nocounter
 
  if (sPrint_Requisition = 1)
    select into "nl:"
           sOrderStatus = o.order_status_cd
         , sDeptStatus = o.dept_status_cd
      from orders o
     where o.order_id = pOrderID
 
    detail
      if (
          (sOrderStatus = cvOS_Ordered and pPrintPrsnlID < 5.00 ) or
          (sOrderStatus = cvOS_Future and pPrintPrsnlID < 5.00 ) or
          (sOrderStatus = cvOS_Canceled and pPrintPrsnlID < 5.00 ) or
          (sOrderStatus = cvOS_Discontinued and pPrintPrsnlID < 5.00 ) or
          pPrintPrsnlID > 5.00
         )
        sPrint_Requisition = 1
      endif
 
    with nocounter, time=10
  endif
  return(sPrint_Requisition )
end
 
;--------------------------------------------------------------
 
subroutine sREQ_BoneMarrow(pOrderID, pPrintPrsnlID )
  declare sPrint_Requisition = i2 with protect
  declare cv200_BMAspirateAndBiopsy = f8 with protect,
              ;009 constant(uar_get_code_by("DISPLAYKEY", 200, "SCHEDULEBONEMARROWBIOPSYANDASPIRATE" ) )
              constant(uar_get_code_by("DISPLAYKEY", 200, "BONEMARROWBIOPSYANDASPIRATEPROCEDUR" ) ) ;009
 
  set sPrint_Requisition = 0
 
  select into "nl:"
         sOrderStatus = o.order_status_cd
       , sDeptStatus = o.dept_status_cd
    from orders o
   where o.order_id = pOrderID
 
  detail
    if (
        (sOrderStatus = cvOS_Future and sDeptStatus = cvDS_OnHold and o.catalog_cd = cv200_BMAspirateAndBiopsy) or
        (sOrderStatus = cvOS_Completed and o.catalog_cd not = cv200_BMAspirateAndBiopsy)
       )
      sPrint_Requisition = 1
    endif
 
  with nocounter, time=10
  return(sPrint_Requisition )
end
;--------------------------------------------------------------
 
subroutine sREQ_DeceaseNote(pOrderID, pPrintPrsnlID )
  declare sPrint_Requisition = i2 with protect
 
  set sPrint_Requisition = 0
 
  select into "nl:"
         sOrderStatus = o.order_status_cd
       , sDeptStatus = o.dept_status_cd
    from orders o
   where o.order_id = pOrderID
 
  detail
;013    if (sOrderStatus = cvOS_Completed and sDeptStatus = cvDS_Completed and pPrintPrsnlID < 5.00 )
    if (sOrderStatus = cvOS_Ordered and pPrintPrsnlID < 5.00 )   ;013
      sPrint_Requisition = 1
    endif
 
  with nocounter, time=10
  return(sPrint_Requisition )
end
 
;--------------------------------------------------------------
 
subroutine sREQ_AmbReferral(pOrderID, pPrintPrsnlID )
  declare sPrint_Requisition = i2 with protect
  declare curr_field_id = f8
  declare curr_act_seq = i4
  declare cv6003_Modify = f8 with protect, constant(uar_get_code_by("MEANING", 6003, "MODIFY" ) )
  declare cv6003_Order = f8 with protect, constant(uar_get_code_by("MEANING", 6003, "ORDER" ) )
  declare cv16449_SchedulingLocationsNonRadiology = f8 with protect,
                                                    constant(uar_get_code_by("DISPLAYKEY", 16449, "SCHEDULINGLOCATIONSNONRADIOLOGY") )
  declare cv100173_PaperReferral = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 100173, "PAPERREFERRAL" ) )
 
  set sPrint_Requisition = 0
 
  ;========================================
  ; Check if the order is a Paper Referral
  ;========================================
  select into "nl:"
  from order_detail od
  plan od
  where od.order_id = pOrderID
    and od.oe_field_id = cv16449_SchedulingLocationsNonRadiology
 
  order by od.oe_field_id,
           od.action_sequence desc
 
  head od.oe_field_id
    curr_field_id = od.oe_field_id
    curr_act_seq = od.action_sequence
 
  detail
   if (od.oe_field_id = curr_field_id and od.action_sequence = curr_act_seq )
     if (od.oe_field_value = cv100173_PaperReferral )
       sPrint_Requisition = 1
     endif
   endif
 
  with nocounter
 
  ;=============================================
  ; Perform additional checks if Paper Referral
  ;=============================================
  if (sPrint_Requisition = 1 )
    ; Reset print indicator for next print validation
    set sPrint_Requisition = 0
 
    select into "nl:"
           sOrderStatus = o.order_status_cd
         , sDeptStatus = o.dept_status_cd
         , sAction = oa.action_type_cd
      from orders o,
           order_action oa
     where o.order_id = pOrderID
       and oa.order_id = o.order_id
    order by oa.action_sequence desc
 
    head o.order_id
;020     if (sOrderStatus = cvOS_Future and sDeptStatus = cvDS_OnHold )
     if ((sOrderStatus = cvOS_Future and sDeptStatus = cvDS_OnHold ) or  ;020
         (sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_Ordered ) ) ;020
       if (pPrintPrsnlID < 5.00 )
         if (sAction = cv6003_Order or sAction = cv6003_Modify )
           ; Auto-print
           sPrint_Requisition = 1
         endif
       else
         ; Reprint
         sPrint_Requisition = 1
       endif
     endif
    with nocounter
  endif
 
  return(sPrint_Requisition )
end
 
;--------------------------------------------------------------
 
subroutine sREQ_TransfusneoReq(pOrderID, pPrintPrsnlID ) ;017/023
 
  declare sPrint_Requisition = i2 with protect
  declare cvUNITCOLLECT = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 16449, "NURSECOLLECT"))
  declare cvCOLLECTEDYN = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 16449, "COLLECTED Y/N"))
 
  declare vUNITCOLLECT = VC
  declare vCOLLECTED = VC
 
  set sPrint_Requisition = 0
  set vUNITCOLLECT = "No"
  set vCOLLECTED = "No"
 
 
  ;========================================
  ; Set Collection Flags
  ;========================================
  select into "nl:"
  from order_detail od
  plan od
  where od.order_id = pOrderID
    and od.oe_field_id in (cvUNITCOLLECT,cvCOLLECTEDYN)
 
  order by od.oe_field_id,
           od.action_sequence desc
 
  head od.oe_field_id
    curr_field_id = od.oe_field_id
    curr_act_seq = od.action_sequence
 
  detail
     if (od.oe_field_id = cvUNITCOLLECT)
       vUNITCOLLECT = substring(1,1,trim(od.oe_field_display_value,3))
     else
       vCOLLECTED = substring(1,1,trim(od.oe_field_display_value,3))
     endif
 
  with nocounter
 
 
  select into "nl:"
     sOrderStatus = o.order_status_cd,
     sDeptStatus = o.dept_status_cd,
     sOrderAction = oa.action_type_cd
 
  from
    orders o,
    order_action oa
 
  plan o
  where o.order_id = pOrderID
 
  join oa
  where oa.order_id = o.order_id
  and oa.action_sequence =
  (
    select max(oa1.action_sequence)
    from order_action oa1
    where oa1.order_id = oa.order_id
    and oa1.action_type_cd = oa.action_type_cd
  )
 
  detail
    if (pPrintPrsnlID < 5.00 )
      if
      ( ;autoprint
        (vUNITCOLLECT = "N" and vCOLLECTED = "N" and sOrderAction = cv6003_Order and sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_Ordered) or
        (vUNITCOLLECT = "N" and vCOLLECTED = "N" and sOrderAction = cv6003_Activate and sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_Ordered) or
        (vUNITCOLLECT = "N" and vCOLLECTED = "N" and sOrderAction = cv6003_Cancel and sOrderStatus = cvOS_Canceled and sDeptStatus = cvDS_Canceled) or
        (vUNITCOLLECT = "N" and vCOLLECTED = "N" and sOrderAction = cv6003_Discontinue and sOrderStatus = cvOS_Discontinued and sDeptStatus = cvDS_Discontinued) or
        (vUNITCOLLECT = "Y" and vCOLLECTED = "N" and sOrderAction = cv6003_Order and sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_PendingCollection) or
        (vUNITCOLLECT = "Y" and vCOLLECTED = "Y" and sOrderAction = cv6003_Order and sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_Collected) or
        (vUNITCOLLECT = "N" and vCOLLECTED = "Y" and sOrderAction = cv6003_Order and sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_Collected) or
        (vUNITCOLLECT = "Y" and vCOLLECTED = "N" and sOrderAction = cv6003_Cancel and sOrderStatus = cvOS_Canceled and sDeptStatus = cvDS_Canceled) or
        (vUNITCOLLECT = "Y" and vCOLLECTED = "N" and sOrderAction = cv6003_Discontinue and sOrderStatus = cvOS_Discontinued and sDeptStatus = cvDS_Discontinued)
       )
        sPrint_Requisition = 1
      endif
    else ;reprint
      if
      (
        (sOrderStatus = cvOS_Ordered and sDeptStatus = cvDS_Ordered) or
        (sOrderStatus = cvOS_Canceled and sDeptStatus = cvDS_Canceled) or
        (sOrderStatus = cvOS_Discontinued and sDeptStatus = cvDS_Discontinued)
      )
        sPrint_Requisition = 1
      endif
    endif
 
 
  with nocounter, time=10
  return(sPrint_Requisition )
end
 
;--------------------------------------------------------------
 
subroutine sREQ_GetLabResult(pPersonID, pOrderID, pLabCode )
  declare sLab_Result_String = vc with protect
  declare order_dttm = vc
  declare order_dttm_ind = i2
 
  set sLab_Result_String = "No results found"
  set order_dttm_ind = 0
 
  ;=============================================
  ; Get original TM order date
  ;=============================================
  select into "nl:"
         oa.action_dt_tm,
         oa.action_type_cd
    from order_action   oa
   where oa.order_id = pOrderID
     and oa.action_type_cd = cv6003_Order
     and oa.action_dt_tm = (select min(oa1.action_dt_tm)
                              from order_action   oa1
                             where oa1.order_id = oa.order_id
                               and oa1.action_type_cd = oa.action_type_cd )
  detail
    order_dttm = format(oa.action_dt_tm, "DD-MMM-YYYY HH:MM:SS;;q" )
    order_dttm_ind = 1
  with nocounter, time=10
 
  ;=============================================
  ; Get lab result only if order date is found
  ;=============================================
  if (order_dttm_ind = 1 )
    ;=============================================
    ; Get the most recent lab result within six
    ; months of the original order date
    ;=============================================
    select into "nl:"
           ce.result_val,
           ce.performed_dt_tm,
           ce.result_val,
           result_units = uar_get_code_display(ce.result_units_cd ),
           result_dttm = oa.action_dt_tm       ;021
      from clinical_event   ce
         , orders  o             ;021
         , order_action   oa     ;021
 
     plan ce
     where ce.person_id = pPersonID
       and ce.event_cd = pLabCode
       and ce.performed_dt_tm = (select max(ce1.performed_dt_tm )
                                   from clinical_event   ce1
                                  where ce1.person_id = ce.person_id
                                    and ce1.event_cd = ce.event_cd )
;021 Start
     join o
     where o.order_id = ce.order_id
 
     join oa
     where oa.order_id = outerjoin(o.order_id )
       and oa.action_type_cd = outerjoin(cv6003_Complete )
;021 End
 
     detail
       if (ce.performed_dt_tm >= cnvtlookbehind("6, M", cnvtdatetime(order_dttm ) ) and
           ce.performed_dt_tm <= cnvtdatetime(order_dttm ) )
;021         sLab_Result_String = concat(trim(ce.result_val, 3 ),
;021                                     trim(concat(" ", result_units ) ),
;021                                     "  (",
;021                                     format(ce.performed_dt_tm, "DD-MMM-YYYY HH:MM;;q" ), ")" )
;021 Start
         sLab_Result_String = concat(trim(ce.result_val, 3 ), trim(concat(" ", result_units ) ) )
         if (result_dttm not = null )
           sLab_Result_String = concat(trim(sLab_Result_String ), "  (", format(oa.action_dt_tm, "DD-MMM-YYYY HH:MM;;q" ), ")" )
         endif
;021 End
       endif
    with nocounter, time=10
  endif
 
  return(sLab_Result_String )
end
 
end
go
 
