;//ipfactory/FT_SourceCode/;Solution_Test/script/MPages Platform Development/mp_script_logging.inc/mp_script_logging.inc
;Turn on black mode
;Turn on line numbers.
/*~BB~************************************************************************
      *                                                                      *
      *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
      *                              Technology, Inc.                        *
      *       Revision      (c) 1984-1999 Cerner Corporation                 *
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
 
        Source file name:       chs_tn_mp_script_logging.inc
        Object name:            NONE
        Request #:              NONE
 
        Product:                Discern ABU Services
        Product Team:
        HNA Version:            500
        CCL Version:            4.0
 
        Program purpose:        This include file is a wrapper around both
                                script logging functionality and the CCL
                                Error() function.
                                Based on cr_script_logging.inc
 
        Tables read:            None
 
        Tables updated:         None
 
        Executing from:
 
        Special Notes:          This include file should be included first in
                                any script.
 
                                In addition, the following line should be added
                                to the end of your script:
                                ------> call uar_SysDestroyHandle(hSys) <------
                                *******************************
                                  UPDATE - 06/03/2003 - CERKYP
                                    As of this date, the uar_SysDetroyHandle is
                                    no longer required.  It does not have to be
                                    removed as hSys is still defined, it is just
                                    not valued, so the call does nothing.
                                *******************************
 
                                LOG_MESSAGE should be called as follows:
                                   LOG_MESSAGE(formatted message, log level)
 
                                ERROR_MESSAGE should be called as follows:
                                   ERROR_MESSAGE(log_status_block_ind)
 
******************************************************************************/
 
 
;~DB~************************************************************************
;    *                      GENERATED MODIFICATION CONTROL LOG              *
;    ************************************************************************
;    *                                                                      *
;    *Mod Date     Engineer             Comment                             *
;    *--- -------- -------------------- ----------------------------------- *
;     000 08/20/99 Chris Heil           Initial Release                     *
;     001 08/27/99 Chris Heil           Add override to log message         *
;     002 08/30/99 Chris Heil           Change CCL errors to be warning     *
;     003 08/31/99 Chris Heil           Add flag for logging to status block*
;     004 09/02/99 Chris Heil           Change sText to sLogText            *
;     005 09/02/99 Chris Heil           Validate on character not number    *
;     006 10/14/99 Chris Heil           Alter instead of alterlist on       *
;                                       subeventstatus array                *
;     007 11/15/01 Rob Peterson         Add subroutine for to fill out      *
;                                       subeventstatus structure            *
;     008 06/26/02 Gary Runde           Declare variables with protect so   *
;                                       child and parent can use this       *
;     009 07/19/02 Kevin Power          Fix POPULATE_SUBEVENTSTATUS         *
;                                       Bring up to standards               *
;                                       Updated CHECK_LOG_LEVEL             *
;                                       Code clean up                       *
;     010 05/29/03 Kevin Power          Added logic to check DM_INFO table  *
;                                       Fix POPULATE_SUBEVENTSTATUS to use  *
;                                         default empty first item.         *
;                                       Moved logging to use msgrtl.        *
;     011 08/25/03 Brent Bossi          Initial release for Clinical Reprt  *
;     012 09/26/09 Greg Howdeshell      Initial release for Discern ABU     *
;     013 12/16/09 Greg Howdeshell      Added ERROR_AND_ZERO_CHECK_REC and  *
;                                       POPULATE_SUBEVENTSTATUS_REC to      *
;                                       accomidate the status block being   *
;                                       outside the reply record            *
;~DE~************************************************************************
 
;~END~ ******************  END OF ALL MODCONTROL BLOCKS  ********************
 
/***********************************************************************
 *   Parameter Variables                                               *
 ***********************************************************************/
  declare log_program_name  = vc with protect, noconstant("")
  declare log_override_ind  = i2 with protect, noconstant(0)
 
/***********************************************************************
 *   Initialize Parameters                                             *
 ***********************************************************************/
  set log_program_name = CURPROG
  set log_override_ind = 0
 
/***********************************************************************
 *   Initialize Constants                                              *
 ***********************************************************************/
  declare LOG_LEVEL_ERROR   = i2 with protect, noconstant(0)
  declare LOG_LEVEL_WARNING = i2 with protect, noconstant(1)
  declare LOG_LEVEL_AUDIT   = i2 with protect, noconstant(2)
  declare LOG_LEVEL_INFO    = i2 with protect, noconstant(3)
  declare LOG_LEVEL_DEBUG   = i2 with protect, noconstant(4)
 
/***********************************************************************
 *   Initialize Logging and Error() Function                           *
 ***********************************************************************/
  declare hSys     = i4 with protect, noconstant(0)
  declare SysStat  = i4 with protect, noconstant(0)
  declare sErrMsg  = c132 with protect, noconstant(" ")
  declare iErrCode = i4 with protect, noconstant(Error(sErrMsg, 1))
 
  declare CRSL_MSG_DEFAULT = i4 with protect, noconstant(0)
  declare CRSL_MSG_LEVEL   = i4 with protect, noconstant(0)
 
  execute msgrtl
  set CRSL_MSG_DEFAULT = uar_MsgDefHandle ()
  set CRSL_MSG_LEVEL   = uar_MsgGetLevel (CRSL_MSG_DEFAULT)
 
/************************************************************************
 *   Initialize other variables.  These were moved here since a declare *
 *   statement cannot be used within a subroutine called from within    *
 *   detail clauses (as these subroutines are).                         *
 ***********************************************************************/
  declare lCRSLSubEventCnt       = i4 with protect, noconstant(0)
  declare iCRSLLoggingStat       = i2 with protect, noconstant(0)
  declare lCRSLSubEventSize      = i4 with protect, noconstant(0)
  declare iCRSLLogLvlOverrideInd = i2 with protect, noconstant(0)
  declare sCRSLLogText           = vc with protect, noconstant("")
  declare sCRSLLogEvent          = vc with protect, noconstant("")
  declare iCRSLHoldLogLevel      = i2 with protect, noconstant(0)
  declare iCRSLErrorOccured      = i2 with protect, noconstant(0)
  declare lCRSLUarMsgwriteStat   = i4 with protect, noconstant(0)
 
/***********************************************************************
 *   Read the DM_INFO table for the program name.  This will eliminate *
 *   the need for scripts to read for a DM_INFO row to turn on script  *
 *   logging override.                                                 *
 *   Simply setup the DM_INFO row as follows to turn on logging:       *
 *     INFO_DOMAIN = "PATHNET SCRIPT LOGGING"                          *
 *     INFO_NAME   = ccl program name in all uppercase                 *
 *     INFO_CHAR   = "L"                                               *
 ***********************************************************************/
  declare CRSL_INFO_DOMAIN    = vc with protect, constant("DISCERNABU SCRIPT LOGGING")
  declare CRSL_LOGGING_ON     = c1 with protect, constant("L")
 
if(LOGICAL("MP_LOGGING_ALL") > " " OR LOGICAL(concat("MP_LOGGING_", log_program_name)) > " ")
	set log_override_ind = 1
endif
 
 
DECLARE LOG_MESSAGE(LogMsg=VC,LogLvl=I4) = NULL
/***********************************************************************
 *   LOG_MESSAGE routine is called to write out a log message to       *
 *   msgview.  The log message and message level should be passed in   *
 *   the corresponding parameters.  The routine will use the string    *
 *   stored in log_program_name as the script.  It will also override  *
 *   the log level passed in if the log_override_ind is set to 1.      *
 ***********************************************************************/
subroutine LOG_MESSAGE(LogMsg, LogLvl)
 
  ; Initialize override flag
  set iCRSLLogLvlOverrideInd = 0
 
  ; Build log message in form "{{Script::ScriptName}} Log Message"
  set sCRSLLogText = ""
  set sCRSLLogEvent = ""
  set sCRSLLogText = CONCAT("{{Script::", VALUE(log_program_name), "}} ", LogMsg)
 
  ; Determine the appropriate log level at which to write message
  if (log_override_ind = 0)
    set iCRSLHoldLogLevel = LogLvl               ; write using passed in log level
  else
    if (CRSL_MSG_LEVEL < LogLvl)
      set iCRSLHoldLogLevel = CRSL_MSG_LEVEL  ; write using server log level (override)
      set iCRSLLogLvlOverrideInd = 1
    else
      set iCRSLHoldLogLevel = LogLvl             ; write using passed in log level
    endif
  endif
 
  ; Write log message using appropriate log level
  if (iCRSLLogLvlOverrideInd = 1)
    set sCRSLLogEvent = "Script_Override"
  else
    case (iCRSLHoldLogLevel)
      of LOG_LEVEL_ERROR:
         set sCRSLLogEvent = "Script_Error"
      of LOG_LEVEL_WARNING:
         set sCRSLLogEvent = "Script_Warning"
      of LOG_LEVEL_AUDIT:
         set sCRSLLogEvent = "Script_Audit"
      of LOG_LEVEL_INFO:
         set sCRSLLogEvent = "Script_Info"
      of LOG_LEVEL_DEBUG:
         set sCRSLLogEvent = "Script_Debug"
    endcase
  endif
 
  set lCRSLUarMsgwriteStat =
    uar_MsgWrite(CRSL_MSG_DEFAULT, 0, nullterm(sCRSLLogEvent), iCRSLHoldLogLevel, nullterm(sCRSLLogText))
    call echo(LogMsg)
 
end ; LOG_MESSAGE subroutine
 
/***************/
 
 
DECLARE ERROR_MESSAGE(LogStatusBlockInd = i2) = i2
/***********************************************************************
 *   The ERROR_MESSAGE routine is called to check for CCL errors after *
 *   a CCL select statement.  If errors are found, this routine will   *
 *   write the error to msgview and the subeventstatus block in the    *
 *   reply record.                                                     *
 ***********************************************************************/
subroutine ERROR_MESSAGE(LogStatusBlockInd)
 
  set iCRSLErrorOccured = 0
 
  ; Check for CCL error
  set iErrCode = Error(sErrMsg, 0)
  while (iErrCode > 0)
    set iCRSLErrorOccured = 1
    if(validate(reply))
      set reply->status_data->status = "F"
    endif
 
    ; Write CCL error message to msgview
    call log_message(sErrMsg, log_level_audit)
 
    ; Write CCL errors to subeventstatus block if it exists
    if (LogStatusBlockInd = 1)
      ; write error to subeventstatus
	  if(validate(reply))  ;validate reply exists before attempting to populate subeventstatus
        call populate_subeventstatus("EXECUTE", "F", "CCL SCRIPT", sErrMsg)
	  endif
    endif
 
    ; Retrieve additional CCL errors
    set iErrCode = Error(sErrMsg, 0)
  endwhile
 
  return(iCRSLErrorOccured)
 
end ; ERROR_MESSAGE subroutine
 
 /***************/
 
DECLARE ERROR_AND_ZERO_CHECK_REC(QualNum = i4,
                             OpName = vc,
                             LogMsg = vc,
                             ErrorForceExit = i2,
                             ZeroForceExit = i2,
                             RecordData = vc (REF)) = i2
/***********************************************************************
 *   The ERROR_AND_ZERO_CHECK routine is called to check for           *
 *   CCL errors or zero rows after a CCL select statement.             *
 *   If errors are found, this routine will                            *
 *   write the error to msgview and the subeventstatus block in the    *
 *   record structure provided                                         *
 ***********************************************************************/
subroutine ERROR_AND_ZERO_CHECK_REC(QualNum, OpName, LogMsg,
                                ErrorForceExit, ZeroForceExit,RecordData)
  set iCRSLErrorOccured = 0
 
  ; Check for CCL error
  set iErrCode = Error(sErrMsg, 0)
  while (iErrCode > 0)
    set iCRSLErrorOccured = 1
 
    ; Write CCL error message to msgview
    call log_message(sErrMsg, log_level_audit)
 
    ; write error to subeventstatus
    call populate_subeventstatus_rec(OpName, "F", sErrMsg, LogMsg, RecordData)
 
    ; Retrieve additional CCL errors
    set iErrCode = Error(sErrMsg, 0)
  endwhile
 
  if (iCRSLErrorOccured = 1 and ErrorForceExit = 1)
  	set RecordData->status_data->status = "F"
    go to exit_script
  endif
 
  ; Check for Zero Returned
 
  if (QualNum = 0 and ZeroForceExit = 1)
  	set RecordData->status_data->status = "Z"
    ; write error to subeventstatus
    call populate_subeventstatus_rec(OpName, "Z", "No records qualified", LogMsg, RecordData)
    go to exit_script
  endif
 
 
  return(iCRSLErrorOccured)
end
 
 /***************/
 
DECLARE ERROR_AND_ZERO_CHECK(QualNum = i4,
                             OpName = vc,
                             LogMsg = vc,
                             ErrorForceExit = i2,
                             ZeroForceExit = i2) = i2
/***********************************************************************
 *   The ERROR_AND_ZERO_CHECK routine is called to check for           *
 *   CCL errors or zero rows after a CCL select statement.             *
 *   If errors are found, this routine will                            *
 *   write the error to msgview and the subeventstatus block in the    *
 *   reply record.                                                     *
 ***********************************************************************/
subroutine ERROR_AND_ZERO_CHECK(QualNum, OpName, LogMsg, ErrorForceExit, ZeroForceExit)
  return(ERROR_AND_ZERO_CHECK_REC(QualNum, OpName, LogMsg,ErrorForceExit, ZeroForceExit, reply))
end ; ERROR_AND_ZERO_CHECK subroutine
 
 
declare POPULATE_SUBEVENTSTATUS_REC(OperationName = vc (value),
                                OperationStatus = vc (value),
                                TargetObjectName = vc (value),
                                TargetObjectValue = vc (value),
                                RecordData = vc(REF)) = i2
 
/***************************************************************************
*   The POPULATE_SUBEVENTSTATUS_REC routine is called to fill out an entry *
*   in the subeventstatus list of a standard record.                       *
***************************************************************************/
subroutine POPULATE_SUBEVENTSTATUS_REC(OperationName, OperationStatus, TargetObjectName, TargetObjectValue, RecordData)
 
  /* Validate that status block exists */
  if (validate(RecordData->status_data->status, "-1") != "-1")
    /* get current size of subevent status */
    set lCRSLSubEventCnt = size(RecordData->status_data->subeventstatus, 5)
 
    /* If last item in array is populated, then increase the size of the array by one.
       Otherwise, assume it is an empty item in the list and use it. */
    set lCRSLSubEventSize = size(trim(RecordData->status_data->subeventstatus[lCRSLSubEventCnt].OperationName))
    set lCRSLSubEventSize = lCRSLSubEventSize +
      size(trim(RecordData->status_data->subeventstatus[lCRSLSubEventCnt].OperationStatus))
    set lCRSLSubEventSize = lCRSLSubEventSize +
      size(trim(RecordData->status_data->subeventstatus[lCRSLSubEventCnt].TargetObjectName))
    set lCRSLSubEventSize = lCRSLSubEventSize +
      size(trim(RecordData->status_data->subeventstatus[lCRSLSubEventCnt].TargetObjectValue))
 
    if (lCRSLSubEventSize > 0)
      set lCRSLSubEventCnt = lCRSLSubEventCnt + 1
      set iCRSLLoggingStat = alter(RecordData->status_data->subeventstatus, lCRSLSubEventCnt)
    endif
 
    set RecordData->status_data.subeventstatus[lCRSLSubEventCnt].OperationName =
      substring(1, 25, OperationName)
    set RecordData->status_data.subeventstatus[lCRSLSubEventCnt].OperationStatus =
      substring(1, 1, OperationStatus)
    set RecordData->status_data.subeventstatus[lCRSLSubEventCnt].TargetObjectName =
      substring(1, 25, TargetObjectName)
    set RecordData->status_data.subeventstatus[lCRSLSubEventCnt].TargetObjectValue =
      TargetObjectValue
  endif
 
end ; POPULATE_SUBEVENTSTATUS subroutine
 
/***************/
 /***************/
 
 declare POPULATE_SUBEVENTSTATUS(OperationName = vc (value),
                                OperationStatus = vc (value),
                                TargetObjectName = vc (value),
                                TargetObjectValue = vc (value)) = i2
/***********************************************************************
*   The POPULATE_SUBEVENTSTATUS routine is called to fill out an entry *
*   in the subeventstatus list of a standard reply.                    *
************************************************************************/
subroutine POPULATE_SUBEVENTSTATUS(OperationName, OperationStatus, TargetObjectName, TargetObjectValue)
  call POPULATE_SUBEVENTSTATUS_REC(OperationName, OperationStatus, TargetObjectName, TargetObjectValue, reply)
end ; POPULATE_SUBEVENTSTATUS subroutine
 
/***************/
 
declare POPULATE_SUBEVENTSTATUS_MSG(OperationName = vc (value),
                                    OperationStatus = vc (value),
                                    TargetObjectName = vc (value),
                                    TargetObjectValue = vc (value),
                                    LogLevel = i2 (value)) = i2
/***************************************************************************
*   The POPULATE_SUBEVENTSTATUS_MSG routine is called to fill out an entry *
*   in the subeventstatus list of a standard reply and to write the        *
*   TargetObjectValue argument to the message log                          *
****************************************************************************/
subroutine POPULATE_SUBEVENTSTATUS_MSG(OperationName, OperationStatus, TargetObjectName, TargetObjectValue, LogLevel)
 
  call populate_subeventstatus(OperationName, OperationStatus, TargetObjectName, TargetObjectValue)
  call log_message(TargetObjectValue, LogLevel)
 
 
end ; POPULATE_SUBEVENTSTATUS_MSG subroutine
 
/***************/
 
DECLARE CHECK_LOG_LEVEL( arg_log_level = i4 ) = i2
/****************************************************************************
*   The CHECK_LOG_LEVEL routine determines if message will be written at a  *
*   given level.                                                            *
****************************************************************************/
subroutine CHECK_LOG_LEVEL(arg_log_level)
  if( CRSL_MSG_LEVEL  >= arg_log_level
   or log_override_ind = 1)
    return (1)  ;The log_level is sufficient to log messages or override is turned on
  else
    return (0)  ;The log_level is not sufficient to log messages
  endif
 
end ; CHECK_LOG_LEVEL subroutine
;Generated by GNU enscript 1.6.4.

