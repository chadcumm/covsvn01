/*~BB~************************************************************************
  *                                                                      *
  *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
  *                              Technology, Inc.                        *
  *       Revision      (c) 1984-2003 Cerner Corporation                 *
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
/*****************************************************************************
 
        Source file name:       ESO_GET_CE_SELECTION.PRG
        Object name:            ESO_GET_CE_SELECTION
        Request #:              1210254
 
        Product:                ESO
        Product Team:           Open Port
        HNA Version:            500
        CCL Version:            4.0
 
        Program purpose:        Suppress Outbound Clinical Events
 
        Tables read:            Clinical_Event
 
        Tables updated:         none
 
        Executing from:         FSI CQM Server (SCP Entry 252)
 
        Special Notes:          none
 
******************************************************************************/
;~DB~*************************************************************************
;    *                      GENERATED MODIFICATION CONTROL LOG               *
;    *************************************************************************
;    *                                                                       *
;    *Mod Date     Engineer             Comment                              *
;    *--- -------- -------------------- ------------------------------------ *
;     000 01/01/98 Steven Baranowski    Initial Write                        *
;     001 12/10/98 Steven Baranowski    Add CQM Downtime Support             *
;     002 12/12/98 Steven Baranowski    Add RadEventEnsure Support           *
;     003 12/15/98 Steven Baranowski    General clean-up and commenting      *
;     004 01/27/99 Steven Baranowski    Fix stype type-o for AP              *
;     005 08/31/99 Steven Baranowski    Add Generic MDOC Processing          *
;     006 09/08/99 Steven Baranowski    Add ALTERED result_status_cd support *
;     007 11/22/99 Wayne Aulner         Fix call echo statemet               *
;     008 02/22/00 Steven Baranowski    Add support for new AP identification*
;     009 07/25/01 Wayne Aulner         Fix call echo statement              *
;     010 09/28/01 Lance Hoover         Add IQHealth Results support         *
;     011 07/21/03 James Grosser        Add PowerForm support                *
;     012 12/01/03 Jason Siess          Add PowerNotes support               *
;     013 03/01/04 Nathan Deam          Add support for RadNet remove exam   *
;     014 03/12/04 Nathan Deam          Add support for immunizations        *
;     015 05/25/04 Alan Basa            Corrections to Powernotes            *
;     016 05/20/05 Steve Schultes       53184 Added ability to suppress      *
;                                       reject exams for radiology           *
;     017 09/02/05 Brad Arndt           59277 Added bloodbank                *
;     018 12/03/07 jl013876             146686 Added Helix support           *
;     019 Anantha krishna               Changed genlab_ind to micro_ind in   *
;                                       micro event logic                    *
;     020 05/04/09 rb012716             193396 - IView Results                *
;     021 10/25/11 jg8253               310682 - ce/doc/doc suppression correction *
;     022 08/03/12 SG019842             331635 - CE/IVIEW correction and HLA support *
;     023 11/10/12 RS016484             346228 - Enhancement to support DYNDOC triggers *
;     024 01/19/15 SG019842             424837 - XHTML Doc inbound support (passthrough)
;     025 09/25/15 C11617               469011 - DOD   *
;     026 03/30/16 SG019842             483835 - DoD Lab Network              *
;     027 01/31/17 GP033277             Turn on results and documents
;     028 05/22/17 KS7383				Turn on IVIEW results                *
;     029 02/09/20 CCUMMIN4				Turn on inerror documents                *
;     030 02/09/20 CCUMMIN4				Attempted Powerform ENTRY mode             *
;~DE~*************************************************************************
;~END~ ******************  END OF ALL MODCONTROL BLOCKS  *********************
 
drop program ESO_GET_CE_SELECTION go
create program ESO_GET_CE_SELECTION
 
call echo("<===== ESO_GET_CE_SELECTION Begin =====>")        ;; 026
call echo("MOD:026")
 
/********************************************************************************************
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 
SECTION 1.
 
THE FOLLOWING REQUEST RECORD SHOULD BE DEFINED IN TDB.  PERFORM A
"SHOW ESO_GET_CE_SELECTION" IN TDB TO VERFIY THIS REQUEST STRUCTURE IS IN SYNC
 
 
record request
{
   class                 [String: Variable]            **  CQM_FSIESO_QUE.class                         **
   stype                 [String: Variable]            **  CQM_FSIESO_QUE.type                          **
   subtype               [String: Variable]            **  CQM_FSIESO_QUE.subtype                       **
   subtype_detail        [String: Variable]            **  CQM_FSIESO_QUE.subtype_detail                **
   event_id              [Double]                      **  CLINICAL_EVENT.event_id                      **
   valid_from_dt_tm      [Date]                        **  CLINICAL_EVENT.valid_from_dt_tm              **
   event_cd              [Double]                      **  CLINICAL_EVENT.event_cd                      **
   result_status_cd      [Double]                      **  CLINICAL_EVENT.result_status_cd              **
   contributor_system_cd [Double]                      **  CLINICAL_EVENT.contributor_system_cd         **
   reference_nbr         [String: Variable]            **  CLINICAL_EVENT.reference_nbr                 **
   result_set_id         [Double]                      **  CLINICAL_EVENT.result_set_id                 ** ;020
}
 
---------------------------------------------------------------------------------------------
********************************************************************************************/
 
 
/********************************************************************************************
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 
SECTION 2.
 
DEFINE LOCAL VARIABLE THAT CAN BE USED IN THE CUSTOM SCRIPTING AT THE BOTTOM OF THIS FILE
 
---------------------------------------------------------------------------------------------
********************************************************************************************/
 
set event_disp = fillstring(40," ")                    /* DISPLAY VALUE FOR CLINICAL_EVENT.event_cd     */
set result_status_cdm = fillstring(12," ")             /* CDF MEANING FOR CE.result_status_cd           */
set contributor_system_disp = fillstring(40," ")       /* DISPLAY VALUE FOR CE.contributor_system_cd    */
set result_set_status_cdm = fillstring(12," ")   ;;022
 
set genlab_event_ind = 0
set micro_event_ind = 0
set rad_event_ind = 0
set ap_event_ind = 0
set mdoc_event_ind = 0                                 /* 005 */
set doc_event_ind = 0                                  ;012
set powerform_event_ind = 0                            ;;011
set immun_event_ind = 0                                ;014
set bloodbank_spr_event_ind = 0                        ;017
 
set helix_event_ind         = 0                        /* ENABLE HELIX EVENTS */  ;018
 
set iview_task_complete_event_ind = 0                  /* IView Results */ ;020
set hlatyping_event_ind = 0                            /* HLATyping results */ ;022
 
set dyndoc_event_ind = 0      ;023
set xhtml_event_ind = 0       ;;024
 
set export_event_ind = 0      ;025
 
set discrete_event_ind = 0    ;025
 
set grp_completed_event_ind = 0   ;;026
 
/********************************************************************************************
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 
SECTION 3.
 
PERFORM UAR CODE CALLS TO GET CDF_MEANING AND DISPLAY STRINGS FOR CODE_VALUE PARAMETERS
 
---------------------------------------------------------------------------------------------
********************************************************************************************/
 
set event_disp = uar_get_code_display(request->event_cd)
set result_status_cdm = uar_get_code_meaning(request->result_status_cd)
set contributor_system_disp = uar_get_code_display(request->contributor_system_cd)
 
 
/********************************************************************************************
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 
SECTION 4.
 
PERFORM CALL ECHO STATEMENTS FOR DEBUGGING
 
---------------------------------------------------------------------------------------------
********************************************************************************************/
 
call echo("*****************************************")
call echo(concat("class = ",request->class))
call echo(concat("stype = ",request->stype))
call echo(concat("subtype = ",request->subtype))
call echo(concat("subtype_detail = ",request->subtype_detail))
call echo(concat("event_id = ",cnvtstring(request->event_id)))
call echo(concat("event_cd = ",cnvtstring(request->event_cd),
                 " = ", event_disp))
call echo(concat("result_status_cd = ",cnvtstring(request->result_status_cd),
                 " = ", result_status_cdm))
call echo(concat("contributor_system_cd = ",cnvtstring(request->contributor_system_cd),
                 " = ", contributor_system_disp))
call echo(concat("reference_nbr = ",request->reference_nbr))
call echo(concat("result_set_id = ",cnvtstring(request->result_set_id))) ;020
 
 
 
/********************************************************************************************
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 
SECTION 5.
 
PERFORM SELECT ON CLINICAL EVENT TABLE FOR MISSING REQUIRED ELEMENTS
 
---------------------------------------------------------------------------------------------
********************************************************************************************/
 
if( (request->event_id > 0 ) AND ( ( trim(request->reference_nbr) = "" ) OR (request->result_status_cd = 0) ) )
   select into "nl:"
          ce.event_cd,
          ce.result_status_cd,
          ce.contributor_system_cd,
          ce.reference_nbr
     from clinical_event ce
    where ce.event_id = request->event_id
      and ce.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")
   detail
       if( request->result_status_cd = 0 )
          request->result_status_cd = ce.result_status_cd
          result_status_cdm =  uar_get_code_meaning(request->result_status_cd)
       endif
       if( trim(request->reference_nbr) = "" )
          request->reference_nbr = ce.reference_nbr
       endif
       if( request->event_cd = 0 )
          request->event_cd = ce.event_cd
          event_disp =  uar_get_code_display(request->event_cd)
       endif
       if( request->contributor_system_cd = 0 )
          request->contributor_system_cd = ce.contributor_system_cd
          contributor_system_disp =  uar_get_code_display(request->contributor_system_cd)
       endif
 
   with nocounter
 
   if(curqual = 0 )
     call echo("!!! SELECT ON CE TABLE FAILED !!!")
   endif
 
   call echo("*** SELECT FROM CE TABLE ***")
   call echo(concat("event_cd = ",cnvtstring(request->event_cd),
                    " = ", event_disp))
   call echo(concat("result_status_cd = ",cnvtstring(request->result_status_cd),
                    " = ", result_status_cdm))
   call echo(concat("contributor_system_cd = ",cnvtstring(request->contributor_system_cd),
                    " = ", contributor_system_disp))
   call echo(concat("reference_nbr = ",request->reference_nbr))
 
endif
 
 
/********************************************************************************************
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 
SECTION 6.
 
DEFINE THE REPLY HANDLE
 
The reply->status_data->status should have the following values:
 
 "S" means that order event is not suppress and that the CQM Server should be sent the event
 "Z" means to suppress the order event and the CQM Server should not be contacted
 "F" means that the script actually failed for some unknown or critical reason
 
---------------------------------------------------------------------------------------------
********************************************************************************************/
 
if( NOT validate(reply,0) )  /* 001 */
  free record reply
  record reply
  (
/* %i cclsource:status_block.inc */
  1 status_data
    2 status = c1
    2 subeventstatus[1]
      3 OperationName = c25
      3 OperationStatus = c1
      3 TargetObjectName = c25
      3 TargetObjectValue = vc
  )
endif
 
set reply->status_data->status = "S"
 
 
 
/********************************************************************************************
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 
SECTION 7.
 
DEFINE LOCAL VARIABLE THAT IDENTIFIED INTERFACE TYPES THAT ARE ENABLED AT THE SITE
(this should match interfaces configured through the ESO_INIT_OUTBOUND script)
 
 
A value of 0 (zero) means that the interface is not enabled
A value of 1 or >0 means the interface is enabled
 
---------------------------------------------------------------------------------------------
********************************************************************************************/
 
 
set ce_genlab_ind = 1                                  /* ENABLE GEN LAB RESULT INTERFACE               */
set ce_micro_ind  = 1                                  /* ENABLE MICRO RESULT INTERFACE                 */
set ce_rad_ind    = 1                                  /* ENABLE RAD RESULT INTERFACE                   */
set ce_ap_ind     = 1                                  /* ENABLE AP RESULT INTERFACE                    */
set ce_mdoc_ind   = 1                                  /* ENABLE GENERIC MDOC INTERFACE 005             */
set ce_doc_ind    = 1                                  /* ENABLE GENERIC DOC INFERFACE                  */  ;012
set ce_immun_ind  = 1                                  /* ENABLE DISCRETE IMMUNIZATION INTERFACE        */  ;014
 
set dm_archive_ind      = 0                            /* ENABLE DATA MANAGEMENT ARCHIVE INTERFACE      */
set ce_powerform_ind    = 1                            /* ENABLE POWERFORMS INTERFACE                   */  ;;011 ;030
set ce_bloodbank_spr_ind = 0                           /* ENABLE BLOODBANK INTERFACE                    */  ;017
set ce_helix_ind         = 0                           /* ENABLE HELIX INTERFACE                        */  ;018
set ce_iview_task_complete_ind = 1                     /* ENABLE IVIEW RESULTS                          */  ;020  ;28
set ce_hlatyping_ind = 0                               /* ENABLE HLATyping results                      */  ;022
 
set ce_dyndoc_ind = 1	                               /* ENABLE MDOC DYNAMIC DOCUMENT INTERFACE        */  ;023
set ce_xhtml_ind = 0                                   /* ENABLE MODC XHTML DOCUMENT INTERFACE          */  ;024
set ce_export_ind = 0	                               /* ENABLE EXPORT CE INTERFACES        */  ;025
set ce_grp_completed_ind = 0                           /* ENABLE LAB-HOLD COMPLETED RESULT INTERFACE    */  ;026
/********************************************************************************************
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 
SECTION 8.
 
FOR THE INTERFACE TYPES THAT ARE ENABLED IN SECTION 7.  IDENTIFY THE RESULT STATUS LEVELS THAT ENABLED.
 
A value of 0 (zero) means that the result status level is not eligible for suppression (ie. the event
                           will always go through ESO)
A value of 1 or >0 means the result status level is eligible for suppression
 
---------------------------------------------------------------------------------------------
********************************************************************************************/
 
set ce_genlab_prelim_ind    = 0                  /* ENABLE GEN LAB PRELIMINARY EVENTS             */
set ce_genlab_final_ind     = 0                  /* ENABLE GEN LAB FINAL EVENTS                   */
set ce_genlab_inerror_ind   = 0 ;029                  /* ENABLE GEN LAB IN-ERROR EVENTS (DO NOT SEND)  */
set ce_genlab_corrected_ind = 0                  /* ENABLE GEN LAB CORRECTED EVENTS               */
 
set ce_micro_prelim_ind    = 0                   /* ENABLE MICRO PRELIMINARY EVENTS               */
set ce_micro_final_ind     = 0                   /* ENABLE MICRO FINAL EVENTS                     */
set ce_micro_inerror_ind   = 0 ;029                   /* ENABLE MICRO IN-ERROR EVENTS (DO NOT SEND)    */
set ce_micro_corrected_ind = 0                   /* ENABLE MICRO CORRECTED EVENTS                 */
 
set ce_rad_prelim_ind    = 0                     /* ENABLE RAD PRELIMINARY EVENTS                 */
set ce_rad_final_ind     = 0                     /* ENABLE RAD FINAL EVENTS                       */
set ce_rad_inerror_ind   = 0 ;029                    /* ENABLE RAD IN-ERROR EVENTS (DO NOT SEND)      */
set ce_rad_corrected_ind = 0                     /* ENABLE RAD CORRECTED EVENTS                   */
set ce_rad_remove_ind    = 0                     /* ENABLE RAD REMOVE EXAM EVENTS                 */ ;013
set ce_rad_reject_ind    = 0                     /* ENABLE RAD REJECT EXAM EVENTS                 */ ;; 016
 
set ce_ap_prelim_ind    = 0                      /* ENABLE AP PRELIMINARY EVENTS                  */
set ce_ap_final_ind     = 0                      /* ENABLE AP FINAL EVENTS                        */
set ce_ap_inerror_ind   = 0 ;029                      /* ENABLE AP IN-ERROR EVENTS (DO NOT SEND)       */
set ce_ap_corrected_ind = 0                      /* ENABLE AP CORRECTED EVENTS                    */
set ce_ap_snomed_ind    = 0                      /* ENABLE AP SNOMED EVENTS - 008                 */
 
set ce_mdoc_prelim_ind    = 0                      /* ENABLE MDOC PRELIMINARY EVENTS          005 */
set ce_mdoc_trans_ind     = 0                      /* ENABLE MDOC TRANSCRIBED EVENTS          005 */
set ce_mdoc_final_ind     = 0                      /* ENABLE MDOC FINAL EVENTS                005 */
set ce_mdoc_inerror_ind   = 0 ;029                      /* ENABLE MDOC IN-ERROR EVENTS (DO NOT SEND)   */
set ce_mdoc_corrected_ind = 0                      /* ENABLE MDOC CORRECTED EVENTS            005 */
 
;; 011+
set ce_powerform_prelim_ind    = 0                   /* ENABLE POWERFORM PRELIMINARY EVENTS               */
set ce_powerform_final_ind     = 0                   /* ENABLE POWERFORM FINAL EVENTS                     */
set ce_powerform_inerror_ind   = 0 ;029                   /* ENABLE POWERFORM IN-ERROR EVENTS (DO NOT SEND)    */
set ce_powerform_corrected_ind = 0                   /* ENABLE POWERFORM CORRECTED EVENTS                 */
;; 011-
 
;012 Start
set ce_doc_prelim_ind    = 0                      /* ENABLE DOC PRELIMINARY EVENTS            */
set ce_doc_trans_ind     = 0                      /* ENABLE DOC TRANSCRIBED EVENTS            */
set ce_doc_final_ind     = 0                      /* ENABLE DOC FINAL EVENTS                  */
set ce_doc_inerror_ind   = 0 ;029                      /* ENABLE DOC IN-ERROR EVENTS (DO NOT SEND) */
set ce_doc_corrected_ind = 0                      /* ENABLE DOC CORRECTED EVENTS              */
;012 End
 
;018+
set ce_helix_prelim_ind    = 0                    /* ENABLE HELIX PRELIMINARY EVENTS            */
set ce_helix_final_ind     = 0                    /* ENABLE HELIX FINAL EVENTS                  */
set ce_helix_inerror_ind   = 0 ;029                    /* ENABLE HELIX IN-ERROR EVENTS (DO NOT SEND) */
set ce_helix_corrected_ind = 0                    /* ENABLE HELIX CORRECTED EVENTS              */
;018-
;020+
set ce_iview_task_complete_new_ind       = 0        /* ENABLE IVIEW TASK COMPLETE FINAL EVENTS                  */
set ce_iview_task_complete_inerror_ind   = 0 ;029        /* ENABLE IVIEW TASK COMPLETE IN_ERROR EVENTS (DO NOT SEND) */
set ce_iview_task_complete_corrected_ind = 0        /* ENABLE IVIEW TASK COMPLETE CORRECTED EVENTS              */
 
;020-
;023+
set ce_dyndoc_prelim_ind = 0                        /* ENABLE DYNDOC PRELIMINARY EVENTS           */
set ce_dyndoc_final_ind = 0                         /* ENABLE DYNDOC TRANSCRIBED EVENTS           */
set ce_dyndoc_trans_ind = 0                         /* ENABLE DYNDOC FINAL EVENTS                 */
set ce_dyndoc_inerror_ind = 0 ;029                       /* ENABLE DYNDOC IN-ERROR EVENTS (DO NOT SEND)*/
set ce_dyndoc_corrected_ind = 0                     /* ENABLE DYNDOC CORRECTED EVENTS             */
;023-
 
;024+
set ce_xhtml_prelim_ind = 0                         /* ENABLE XHTML PRELIMINARY EVENTS            */
set ce_xhtml_final_ind = 0                          /* ENABLE XHTML TRANSCRIBED EVENTS            */
set ce_xhtml_trans_ind = 0                          /* ENABLE XHTML FINAL EVENTS                  */
set ce_xhtml_inerror_ind = 0 ;029                        /* ENABLE XHTML IN-ERROR EVENTS (DO NOT SEND) */
set ce_xhtml_corrected_ind = 0                      /* ENABLE XHTML CORRECTED EVENTS              */
;024-
 
;025+
set ce_export_prelim_ind = 0
set ce_export_final_ind = 0
set ce_export_trans_ind = 0
set ce_export_inerror_ind = 0 ;029
set ce_export_corrected_ind = 0
;025-
/********************************************************************************************
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 
SECTION 9.
 
THE FOLLOWING IS HARD_CODED LOGIC TO REACT THE SETTINGS CONFIGURED IN SECTION 7. AND SECTION 8.
DO NOT ALTER THIS LOGIC.
 
---------------------------------------------------------------------------------------------
********************************************************************************************/
 
;; 011+
/* PowerForm event logic */
if ( ( request->class = "CE" )          AND
     ( request->subtype = "POWERFORMS" )  AND
     ( ce_powerform_ind > 0 )  )
   set powerform_event_ind = 1
 
   if( result_status_cdm = "IN PROGRESS" AND ce_powerform_prelim_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE//GRP IN PROGRESS MESSAGE")
 
   elseif( result_status_cdm = "AUTH" AND ce_powerform_final_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE//GRP AUTH MESSAGE")
 
   elseif( result_status_cdm = "INERROR" AND ce_powerform_inerror_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE//GRP INERROR MESSAGE")
 
   elseif( ( result_status_cdm = "MODIFIED" OR result_status_cdm = "ALTERED" ) AND ce_powerform_corrected_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE//GRP MODIFIED MESSAGE")
   endif
 
endif
;; 011-
 
/* Gen Lab event logic */
if ( ( request->class = "CE" )                      AND
     ( request->subtype = "GRP")                    AND
     ( ce_genlab_ind > 0 )                    )
 
   set genlab_event_ind = 1
 
   if( result_status_cdm = "IN PROGRESS" AND ce_genlab_prelim_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE//GRP IN PROGRESS MESSAGE")
 
   elseif( result_status_cdm = "AUTH" AND ce_genlab_final_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE//GRP AUTH MESSAGE")
 
   elseif( result_status_cdm = "INERROR" AND ce_genlab_inerror_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE//GRP INERROR MESSAGE")
 
   elseif( ( result_status_cdm = "MODIFIED" OR result_status_cdm = "ALTERED" ) AND ce_genlab_corrected_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE//GRP MODIFIED MESSAGE")
   endif
endif
 
 
/* Micro event logic */
if ( ( request->class = "CE" )                      AND
     ( request->subtype = "MICRO")                  AND
     ( ce_micro_ind > 0 )                    )            ;;019
 
   set micro_event_ind = 1
 
   if( result_status_cdm = "IN PROGRESS" AND ce_micro_prelim_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE//MICRO IN PROGRESS MESSAGE")
 
   elseif( result_status_cdm = "AUTH" AND ce_micro_final_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE//MICRO AUTH MESSAGE")
 
   elseif( result_status_cdm = "INERROR" AND ce_micro_inerror_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE//MICRO INERROR MESSAGE")
 
   elseif( ( result_status_cdm = "MODIFIED" OR result_status_cdm = "ALTERED" ) AND ce_micro_corrected_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE//MICRO MODIFIED MESSAGE")
   endif
endif
 
/* radiology event logic */
if ( ( ( request->class = "CE" )
     OR ( request->class = "RADNET" )  )              AND
     ( substring(1,3,request->reference_nbr) = "RAD") AND
     ( ce_rad_ind > 0 )                         )
 
   set rad_event_ind = 1
 
   if( request->subtype = "MDOC" )
      if( result_status_cdm = "IN PROGRESS" AND ce_rad_prelim_ind > 0 )
         set reply->status_data->status = "Z"
         call echo("REJECT CE/RAD/MDOC IN PROGRESS MESSAGE")
 
      elseif( result_status_cdm = "AUTH" AND ce_rad_final_ind > 0 )
         set reply->status_data->status = "Z"
         call echo("REJECT CE/RAD/MDOC AUTH MESSAGE")
 
      elseif( result_status_cdm = "INERROR" AND ce_rad_inerror_ind > 0 )
         set reply->status_data->status = "Z"
         call echo("REJECT CE/RAD/MDOC INERROR MESSAGE")
 
      elseif( ( result_status_cdm = "MODIFIED" OR result_status_cdm = "ALTERED" ) AND ce_rad_corrected_ind > 0 )
         set reply->status_data->status = "Z"
         call echo("REJECT CE/RAD/MDOC MODIFIED MESSAGE")
 
      ;; 016 - begin
      elseif( result_status_cdm = "REJECTED" and ce_rad_reject_ind > 0 )
         set reply->status_data->status = "Z"
         call echo( "REJECT CE/RADRJCTEXAM/MDOC MESSAGE" )
      endif
      ;; 016 - end
 
   ;013 Begin
   elseif( ( request->subtype = "RAD" ) AND ( request->stype = "RADREMOVEXAM" ) )
      if ( ce_rad_remove_ind > 0 )
         set reply->status_data->status = "Z"
         call echo( "REJECT CE/RADREMOVEXAM/RAD MESSAGE" )
      endif
   ;013 End
 
   else
      set reply->status_data->status = "Z"
      call echo("REJECT CE/RAD/non-MDOC, non-RADREMOVEXAM MESSAGE or non-RADRJCTEXAM MESSAGE")   ;013
   endif
endif
 
/* AP event logic */
if ( ( request->class = "CE" )                      AND
     ( request->stype = "AP")                       AND
     ( ce_ap_ind > 0 )                        )
 
   set ap_event_ind = 1
 
   if ( request->subtype = "AP" )
 
      set reply->status_data->status = "Z"
      call echo("REJECT CE/AP/AP MESSAGE")      /* 007 */
 
   else
      if( result_status_cdm = "IN PROGRESS" AND ce_ap_prelim_ind > 0 )
         set reply->status_data->status = "Z"
         call echo("REJECT CE/AP IN PROGRESS MESSAGE")
 
      elseif( result_status_cdm = "AUTH" AND ce_ap_final_ind > 0 )
         set reply->status_data->status = "Z"
         call echo("REJECT CE/AP AUTH MESSAGE")
 
      elseif( result_status_cdm = "INERROR" AND ce_ap_inerror_ind > 0 )
         set reply->status_data->status = "Z"
         call echo("REJECT CE/AP INERROR MESSAGE")
 
      elseif( ( result_status_cdm = "MODIFIED" OR result_status_cdm = "ALTERED" ) AND ce_ap_corrected_ind > 0 )
         set reply->status_data->status = "Z"
         call echo("REJECT CE/AP MODIFIED MESSAGE")
      endif
   endif
endif
 
/* 008 - AP event logic for 2000.01 */
if ( ( request->class = "CE" )                      AND
     ( substring(1,3,request->stype) = "AP_" )      AND
     ( ce_ap_ind > 0 )                        )
 
   set ap_event_ind = 1
 
   if ( request->subtype = "AP_CASE" )
 
      set reply->status_data->status = "Z"
      call echo("REJECT CE/AP_CASE MESSAGE")
 
   else
      if( result_status_cdm = "IN PROGRESS" AND ce_ap_prelim_ind > 0 )
         set reply->status_data->status = "Z"
         call echo("REJECT CE/AP_xxx IN PROGRESS MESSAGE")
 
      elseif( result_status_cdm = "AUTH" AND ce_ap_final_ind > 0 )
         set reply->status_data->status = "Z"
         call echo("REJECT CE/AP_xxx AUTH MESSAGE")
 
      elseif( result_status_cdm = "INERROR" AND ce_ap_inerror_ind > 0 )
         set reply->status_data->status = "Z"
         call echo("REJECT CE/AP_xxx INERROR MESSAGE")
 
      elseif( ( result_status_cdm = "MODIFIED" OR result_status_cdm = "ALTERED" ) AND ce_ap_corrected_ind > 0 )
         set reply->status_data->status = "Z"
         call echo("REJECT CE/AP_xxx MODIFIED MESSAGE")
 
      elseif( trim(request->stype) = "AP_SNOMED" AND ce_ap_snomed_ind > 0 )
         set reply->status_data->status = "Z"
         call echo("REJECT CE/AP_SNOMED MODIFIED MESSAGE")
      endif
   endif
endif
 
 
/* 005 generic MDOC event logic */
if ( ( request->class = "CE" )                       AND
     ( request->stype = "MDOC")                      AND
     ( request->subtype = "MDOC")                    AND
     ( ce_mdoc_ind > 0 )                    )
 
   set mdoc_event_ind = 1
 
   if( result_status_cdm = "IN PROGRESS" AND ce_mdoc_prelim_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE/MDOC/MDOC IN PROGRESS MESSAGE")
 
   elseif( result_status_cdm = "TRANSCRIBED" AND ce_mdoc_trans_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE/MDOC/MDOC TRANSCRIBED MESSAGE")
 
   elseif( result_status_cdm = "AUTH" AND ce_mdoc_final_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE/MDOC/MDOC AUTH MESSAGE")
 
   elseif( result_status_cdm = "INERROR" AND ce_mdoc_inerror_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE/MDOC/MDOC INERROR MESSAGE")
 
   elseif( ( result_status_cdm = "MODIFIED" OR result_status_cdm = "ALTERED" ) AND ce_mdoc_corrected_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE/MDOC/MDOC MODIFIED MESSAGE")
   endif
endif
 
/* 012 PowerNotes event logic */
if ( ( request->class = "CE" )                      AND
     ( request->stype = "DOC")                      AND
     ( request->subtype = "DOC")                    AND
     ( ce_doc_ind > 0 )                    )
 
   set doc_event_ind = 1
 
/*  015 +
   if( result_status_cdm = "IN PROGRESS" AND ce_doc_prelim_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE/DOC/DOC IN PROGRESS MESSAGE")
 
   elseif( result_status_cdm = "TRANSCRIBED" AND ce_doc_trans_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE/DOC/DOC TRANSCRIBED MESSAGE")
    015 -
 */
 
   if( result_status_cdm = "AUTH" AND ce_doc_final_ind > 0 )  ;;021 changed to check ce_doc_final_ind
      set reply->status_data->status = "Z"
      call echo("REJECT CE/DOC/DOC AUTH MESSAGE")
 
   elseif( result_status_cdm = "INERROR" AND ce_doc_inerror_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE/DOC/DOC INERROR MESSAGE")
 
   elseif( ( result_status_cdm = "MODIFIED" OR result_status_cdm = "ALTERED" ) AND ce_doc_corrected_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE/DOC/DOC MODIFIED MESSAGE")
   endif
endif
 
;018+
/* Helix event logic */
if ( ( request->class = "CE" ) AND
     ( request->subtype = "UR" ) AND
     (ce_helix_ind > 0 ) )
 
   set helix_event_ind = 1
 
   if( result_status_cdm = "IN PROGRESS" AND ce_helix_prelim_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE/HELIX IN PROGRESS MESSAGE")
 
   elseif( result_status_cdm = "AUTH" AND ce_helix_final_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE/HELIX AUTH MESSAGE")
 
   elseif( result_status_cdm = "INERROR" AND ce_helix_inerror_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE/HELIX INERROR MESSAGE")
 
   elseif( ( result_status_cdm = "MODIFIED" OR result_status_cdm = "ALTERED" ) AND ce_helix_corrected_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE/HELIX MODIFIED MESSAGE")
   endif
 
endif
;018-
;023+
if ( ( request->class = "CE" ) AND
     ( request->stype = "MDOC") AND
     ( request->subtype = "DYNDOC") AND
     ( ce_dyndoc_ind > 0 ) )
     call echo("This is CE:MDOC:DYNDOC trigger")
 
   set dyndoc_event_ind = 1
 
   if( result_status_cdm = "IN PROGRESS" AND ce_dyndoc_prelim_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE/MDOC/DYNDOC IN PROGRESS MESSAGE")
 
   elseif( result_status_cdm = "TRANSCRIBED" AND ce_dyndoc_trans_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE/MDOC/DYNDOC TRANSCRIBED MESSAGE")
 
   elseif( result_status_cdm = "AUTH" AND ce_dyndoc_final_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE/MDOC/DYNDOC AUTH MESSAGE")
 
   elseif( result_status_cdm = "INERROR" AND ce_dyndoc_inerror_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE/MDOC/DYNDOC INERROR MESSAGE")
 
   elseif( ( result_status_cdm = "MODIFIED" OR result_status_cdm = "ALTERED" ) AND ce_dyndoc_corrected_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE/MDOC/DYNDOC MODIFIED MESSAGE")
   endif
endif
;023-
 
;024+
if ( ( request->class = "CE" ) AND
     ( request->stype = "MDOC") AND
     ( request->subtype = "XHTML") AND
     ( ce_xhtml_ind > 0 ) )
     call echo("This is CE:MDOC:XHTML trigger")
 
   set xhtml_event_ind = 1
 
   if( result_status_cdm = "IN PROGRESS" AND ce_xhtml_prelim_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE/MDOC/XHTML IN PROGRESS MESSAGE")
 
   elseif( result_status_cdm = "TRANSCRIBED" AND ce_xhtml_trans_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE/MDOC/XHTML TRANSCRIBED MESSAGE")
 
   elseif( result_status_cdm = "AUTH" AND ce_xhtml_final_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE/MDOC/XHTML AUTH MESSAGE")
 
   elseif( result_status_cdm = "INERROR" AND ce_xhtml_inerror_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE/MDOC/XHTML INERROR MESSAGE")
 
   elseif( ( result_status_cdm = "MODIFIED" OR result_status_cdm = "ALTERED" ) AND ce_xhtml_corrected_ind > 0 )
      set reply->status_data->status = "Z"
      call echo("REJECT CE/MDOC/XHTML MODIFIED MESSAGE")
   endif
endif
;024-
 
;020+
 
if ( ( request->class   = "CE" )    AND
	   ( request->stype   = "IVIEW" ) AND
	   ( request->subtype = "TASK_COMPLETE" ) AND
	   ( ce_iview_task_complete_ind > 0 ) )
 
	   set iview_task_complete_event_ind = 1 ;;022
 
	   if ( request->result_set_id > 0 )
 
	      select into "nl:"
	         srsor.result_set_status_cd
	      from si_result_set_order_reltn srsor
	      where srsor.result_set_id = request->result_set_id
 
	      detail
 
	         result_set_status_cdm = uar_get_code_meaning(srsor.result_set_status_cd)  ;; declare variable at top of script?
 
	      with nocounter
 
	      if( curqual = 0 )
 
	         call echo ( "RESULT_SET_STATUS_CD SELECT ON SI_RESULT_SET_ORDER_RELTN FAILED: NO ROWS RETURNED")
 
	      else
 
	         call echo ( concat ("result_set_status_cdm=", result_set_status_cdm))
 
	         if( result_set_status_cdm = "NEW" AND ce_iview_task_complete_new_ind > 0 )
 
	            set reply->status_data->status = "Z"
	            call echo ("REJECT CE/IVIEW/TASK_COMPLETE AUTH MESSAGE")
 
	         elseif( result_set_status_cdm = "INERROR" AND ce_iview_task_complete_inerror_ind > 0 )
 
	            set reply->status_data->status = "Z"
	            call echo ("REJECT CE/IVIEW/TASK_COMPLETE INERROR MESSAGE")
 
	         elseif( result_set_status_cdm = "MODIFIED" AND ce_iview_task_complete_corrected_ind > 0 )
 
	         	  set reply->status_data->status = "Z"
	         	  call echo ("REJECT CE/IVIEW/TASK_COMPLETE MODIFIED MESSAGE")
 
	         endif
 
	      endif
 
	   endif
 
endif
;020-
 
;014 Begin
/* Immunization event logic */
if ( ( request->class = "CE" ) AND
     ( request->subtype = "IMMUNIZATION" ) AND
     ( ce_immun_ind > 0 ) )
    set immun_event_ind = 1
endif
;014 End
 
 
;017+
/* Bloodbank SPR event logic */
 
if ( ( request->class = "CE" ) AND
     ( request->subtype = "BBPRODUCT" ) AND
     ( ce_bloodbank_spr_ind > 0 ) )
 
    set bloodbank_spr_event_ind = 1
 
endif
;017-
 
;;022+
if ( ( request->class = "CE" ) AND
     ( request->subtype = "HLATYPING" ) AND
     ( ce_hlatyping_ind > 0 ) )
 
    set hlatyping_event_ind = 1
 
endif
;;022-
 
;;025+
if ( request->class = "EXP_CE" )
 
    set export_event_ind = 1
 
endif
 
;; Discrete event logic
if ( ( request->class   = "CE" ) AND
	 ( request->stype   = "DISCRETE" ) )
 
	 set discrete_event_ind = 1
 
endif
;;025-
 
/* Micro event logic */
 
 
;;026+
if ( ( request->class = "CE" ) AND
     ( request->stype = "GRP") AND
     ( request->subtype = "COMPLETED" ) AND
     ( ce_grp_completed_ind = 1) )
 
    set grp_completed_event_ind = 1
 
endif
;;026-
 
if(    ( genlab_event_ind = 0 )                       AND
       ( micro_event_ind = 0 )                        AND
       ( rad_event_ind = 0 )                          AND
       ( ap_event_ind = 0 )                           AND
       ( mdoc_event_ind = 0 )                         AND       /* 005 */
       ( doc_event_ind = 0 )                          AND       ; 012 added a check for doc_event_ind
       ( powerform_event_ind = 0 )                    AND       ;; 011 added a check for powerform_event_ind
       ( immun_event_ind = 0 )                        AND       ;; 014 added check for immun_event_ind
       ( bloodbank_spr_event_ind = 0 )                AND       ;017 added check for bloodbank_spr_event_ind ;018
       ( helix_event_ind = 0 )                        AND       ;018 added check for helix_event_ind ;020
       ( iview_task_complete_event_ind = 0 )          AND       ;020 added check for IView Task Complete
       ( hlatyping_event_ind = 0 )                    AND       ;;022 added check for HLAtyping,
       ( dyndoc_event_ind = 0 )                       AND       ;;023
       ( xhtml_event_ind = 0 )                        AND       ;;024
       ( export_event_ind = 0 )                       AND       ;;025
       ( discrete_event_ind = 0 )                     AND       ;;025
       ( grp_completed_event_ind = 0 ) )                        ;;026
 
   set reply->status_data->status = "Z"
   call echo("REJECT UNKNOWN OR UNCONFIGURED EVENT")
 
endif
 
;010 begin
if( request->subtype = "GRP_PHR" or request->subtype = "MDOC_PHR")
        set reply->status_data->status = "S"
elseif (request->subtype = "AP_PHR")
        set reply->status_data->status = "Z"
        call echo("REJECT CE/AP_PHR MESSAGE")
endif
;010 end
 
 
/********************************************************************************************
+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 
SECTION 10.
 
PERFORM ALL SITE SPECIFIC CUSTOM CODING HERE
 
Use basic IF statements to check any variable condition to determime when to set the
reply->status_data->status variable to a "Z" (to suppress).  Since the
reply->status_data->status variable is default to "S", the order event is assumed to be
valid until a suppression condition below is encountered.
 
Use varibles defined in Sections 1 and 2 above in the IF statements.  DO NOT use code_value
variables in the REQUEST record as it leads to a non-portable implementation between
environment.  Instead, use the CDF MEANING or DISPLAY variable declared in Section 2 and
values fetched in SEction 6.
 
---------------------------------------------------------------------------------------------
********************************************************************************************/
 
 
;EXAMPLE 3:
;/* Suppress all event owned by the EXTERNAL_SYSTEM_DISPLAY contributor_system - */
;if ( trim(contributor_system_disp) = "EXTERNAL_SYSTEM_DISPLAY")
;   set reply->status_data->status = "Z"
;   call echo("EXTERNAL_SYSTEM_DISPLAY EVENTS SUPPRESSED")
;endif
 
;call echo(concat("ESO_GET_CE_SELECTION STATUS = ",reply->status_data->status))          ;; 009
 
;*** MOD 031 block anesthesia MDOCs
if (mdoc_event_ind > 0)
if(event_disp = "Anesthesia Record")
set reply->status_data->status = "Z"
endif
endif
 
 
IF  (TRIM(CONTRIBUTOR_SYSTEM_DISP) = "gGASTRO")
SET  REPLY -> STATUS_DATA -> STATUS  = "Z"
 CALL ECHO ("gGASTRO EVENTS SUPPRESSED")
ENDIF
 
IF  (TRIM(CONTRIBUTOR_SYSTEM_DISP) = "HISTORY")
SET  REPLY -> STATUS_DATA -> STATUS  = "Z"
 CALL ECHO ("HISTORY EVENTS SUPPRESSED")
ENDIF
 
IF  (TRIM(CONTRIBUTOR_SYSTEM_DISP) = "FUSION_RAD")
SET  REPLY -> STATUS_DATA -> STATUS  = "Z"
 CALL ECHO ("FUSION_RAD EVENTS SUPPRESSED")
ENDIF
 
;IF  (TRIM(CONTRIBUTOR_SYSTEM_DISP) = "FUSION")
;SET  REPLY -> STATUS_DATA -> STATUS  = "Z"
; CALL ECHO ("FUSION EVENTS SUPPRESSED")
;ENDIF
 
IF  (TRIM(CONTRIBUTOR_SYSTEM_DISP) = "vRAD")
SET  REPLY -> STATUS_DATA -> STATUS  = "Z"
 CALL ECHO ("vRAD EVENTS SUPPRESSED")
ENDIF
 
IF  (TRIM(CONTRIBUTOR_SYSTEM_DISP) = "MRS")
SET  REPLY -> STATUS_DATA -> STATUS  = "Z"
 CALL ECHO ("MRS EVENTS SUPPRESSED")
ENDIF
 
IF  (TRIM(CONTRIBUTOR_SYSTEM_DISP) = "VDCOR")
SET  REPLY -> STATUS_DATA -> STATUS  = "Z"
 CALL ECHO ("VDCOR EVENTS SUPPRESSED")
ENDIF
 
IF  (TRIM(CONTRIBUTOR_SYSTEM_DISP) = "CoPath")
SET  REPLY -> STATUS_DATA -> STATUS  = "Z"
 CALL ECHO ("CoPath EVENTS SUPPRESSED")
ENDIF
 
IF  (TRIM(CONTRIBUTOR_SYSTEM_DISP) = "MUSE")
SET  REPLY -> STATUS_DATA -> STATUS  = "Z"
 CALL ECHO ("MUSE EVENTS SUPPRESSED")
ENDIF
 
IF  (TRIM(CONTRIBUTOR_SYSTEM_DISP) = "MEDILINKS")
SET  REPLY -> STATUS_DATA -> STATUS  = "Z"
 CALL ECHO ("MEDILINKS EVENTS SUPPRESSED")
ENDIF
 
IF  (TRIM(CONTRIBUTOR_SYSTEM_DISP) = "PathGroup")
SET  REPLY -> STATUS_DATA -> STATUS  = "Z"
 CALL ECHO ("PathGroup EVENTS SUPPRESSED")
ENDIF
 
IF  (TRIM(CONTRIBUTOR_SYSTEM_DISP) = "Bridge")
SET  REPLY -> STATUS_DATA -> STATUS  = "Z"
 CALL ECHO ("Bridge EVENTS SUPPRESSED")
ENDIF
 
IF  (TRIM(CONTRIBUTOR_SYSTEM_DISP) = "BLOUNT")
SET  REPLY -> STATUS_DATA -> STATUS  = "Z"
 CALL ECHO ("BLOUNT EVENTS SUPPRESSED")
ENDIF
 
IF  (TRIM(CONTRIBUTOR_SYSTEM_DISP) = "LABDAQS")
SET  REPLY -> STATUS_DATA -> STATUS  = "Z"
 CALL ECHO ("LABDAQS EVENTS SUPPRESSED")
ENDIF
 
IF  (TRIM(CONTRIBUTOR_SYSTEM_DISP) = "LABDAQC")
SET  REPLY -> STATUS_DATA -> STATUS  = "Z"
 CALL ECHO ("LABDAQC EVENTS SUPPRESSED")
ENDIF
 
IF  (TRIM(CONTRIBUTOR_SYSTEM_DISP) = "SCHYULAB")
SET  REPLY -> STATUS_DATA -> STATUS  = "Z"
 CALL ECHO ("SCHYULAB EVENTS SUPPRESSED")
ENDIF
 
IF  (TRIM(CONTRIBUTOR_SYSTEM_DISP) = "FCOR")
SET  REPLY -> STATUS_DATA -> STATUS  = "Z"
 CALL ECHO ("FCOR EVENTS SUPPRESSED")
ENDIF
 
IF  (TRIM(CONTRIBUTOR_SYSTEM_DISP) = "PACS")
SET  REPLY -> STATUS_DATA -> STATUS  = "Z"
 CALL ECHO ("PACS EVENTS SUPPRESSED")
ENDIF
 
IF  (TRIM(CONTRIBUTOR_SYSTEM_DISP) = "HX_LAB_MLAB")
SET  REPLY -> STATUS_DATA -> STATUS  = "Z"
 CALL ECHO ("HX_LAB_MLAB EVENTS SUPPRESSED")
ENDIF
 
IF  (TRIM(CONTRIBUTOR_SYSTEM_DISP) = "HX_BB_MEDIWARE")
SET  REPLY -> STATUS_DATA -> STATUS  = "Z"
 CALL ECHO ("HX_BB_MEDIWARE EVENTS SUPPRESSED")
ENDIF
 
IF  (TRIM(CONTRIBUTOR_SYSTEM_DISP) = "HX_CCD_CHS_SYS")
SET  REPLY -> STATUS_DATA -> STATUS  = "Z"
 CALL ECHO ("HX_CCD_CHS_SYS EVENTS SUPPRESSED")
ENDIF
 
IF  (TRIM(CONTRIBUTOR_SYSTEM_DISP) = "HX_STAR_MDRO")
SET  REPLY -> STATUS_DATA -> STATUS  = "Z"
 CALL ECHO ("HX_STAR_MDRO EVENTS SUPPRESSED")
ENDIF
 
IF  (TRIM(CONTRIBUTOR_SYSTEM_DISP) = "MUSE_CF")
SET  REPLY -> STATUS_DATA -> STATUS  = "Z"
 CALL ECHO ("MUSE_CF EVENTS SUPPRESSED")
ENDIF

/* start 30 */
set filename = build("cclscratch:",cnvtlower(trim(curprog))
										,"_",format(cnvtdatetime(curdate, curtime3)
										,"yyyy_mm_dd_hh_mm_ss;;d")
										,".log"
										)
call echojson(request,filename)
/*end 30*/ 
end
go

