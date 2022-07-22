/*
**********************************************************************************************************************************
Copyright Notice:  (c) 1983 Laboratory Information Systems & Technology, Inc.
Revision:          (c) 1984-2011 Cerner Corporation
 
 Cerner (R) Proprietary Rights Notice:  All rights reserved.  This material contains the valuable properties and trade secrets of
 Cerner Corporation of Kansas City, Missouri, United States of America (Cerner), embodying substantial creative efforts and
 confidential information, ideas and expressions, no part of which may be reproduced or transmitted in any form or by any means,
 or retained in any storage or retrieval system without the express written permission of Cerner.
 
 Cerner is a registered mark of Cerner Corporation.
**********************************************************************************************************************************
 
Date Written:       6/4/2012
Source file name:   ccps_script_logging.inc
Object name:        not a stand alone prg.  Must be used as an include file
 
Based on cr_script_logging.inc by Clinical Reporting, tailored to needs of Centers Custom CCL Team
 
Pre-Conditions: For logging to happen, the object name including this
            file will need to be setup and turned on in the
            CCPS_SCRIPT_LOGGING_SETUP prompt control, or command line
            override constants have been set inside program or before using
            "execute" on the object name
 
Instructions:   For debugging through Millennium applications, create
            instance of the object you are interested in debugging
            in CCPS_SCRIPT_LOGGING_SETUP prompt control program in Explorer
            Menu.
 
            Building object in CCPS_SCRIPT_LOGGING_SETUP program:
 
            1)  Run CCLPROT on CCPS_SCRIPT_LOGGING_SETUP in domain to see if this object has been included
            2)  If it has not, find CCPS_SCRIPT_LOGGING_SETUP program in subversion, import into the domain being sure to import
                prompts and include
            3)  If this program does not exist in Explorer Menu, add it to your folder of choice
            4)  Select this program in Explorer Menu
            5)  Double click "<< Double Click to Add New >>"
            6)  Focus will change to the program selection text box.  Enter object name or use the search button to search for
                one.
            7)  Select a debug Method (None / File / Message View).  None essentially turns logging off, and the
                other destinations define where messages (debug and error) will be sent.
            8)  If desired, enter a file name for capturing messages to a file.  If no file is entered, <OBJECT NAME>_dbg.dat
                will be used by default if file method of debugging is set sometime in the future.
            9)  If desired, modify the inactive date.  This date is set to two days in the future initially but can be set to
                a date further in the future as well.  At midnight of the date specified, logging will turn off for your
                script.
            10) If desired, set advanced options by clicking the advanced check box.
            11) Click "Add To/Update List" button to save changes to the control.
            12) Click "Execute" button in the lower right corner.  Your changes have now been saved to the database.  The
                "Refresh" button will repaint the program controls box.
 
            Follow the basic process above for editing or removing items.  The "Remove" button works the same way as the
            "Add To/Update List" button and you must click "Execute" for your changes to save.  Clicking "Refresh" is a good
            way to reset the form if you would just like to return to settings since the last time execute was clicked.
 
            Logging How To's:
 
            Via CCPS_SCRIPT_LOGGING_SETUP:
 
                "Turning off" logging:
                - In CCPS_SCRIPT_LOGGING_SETUP program, set Debug Method to None, click Add To/Update List
                  and click Execute Button
 
                -------------------------------------------------------------------------------------------------
 
                Logging to a file:
                - In CCPS_SCRIPT_LOGGING_SETUP program, set Debug Method to File, click Add To/Update List
                  and click Execute Button.
                - If no file name is specified, <object name>_dbg.dat
                  will be used by default
 
                -------------------------------------------------------------------------------------------------
 
                Logging to Message View:
                - In CCPS_SCRIPT_LOGGING_SETUP program, set Debug Method to Message View, click Add To/Update List
                  and click Execute Button.
                - Messages will log at the level specified in the second parameter of the logMsg subroutine.
                  If no level is specified, CCPS_LOG_AUDIT is used.
                - The various log levels are below, along with guidelines for their use:
 
                    CCPS_LOG_ERROR   (0):  Should be used in your program to throw an error when a condition occurs
                                      that would classify your script as not functioning correctly
                                      Example: Code set extension not defined, then log message as an error because
                                      this is a build error and the script will not perform at all until it's addressed.
                                      ** BE CAUTIOUS WITH CCPS_LOG_ERROR AS THESE MESSAGES WILL ALWAYS BE LOGGED EVEN IF YOUR
                                      SCRIPT IS NOT SETUP IN THE CCPS_SCRIPT_LOGGING_SETUP TOOL.
                    CCPS_LOG_AUDIT   (2):  Should be used to write a message giving more info to the developer/user about what is
                                      happenning at run-time
 
                    CCPS_LOG_ERROR and CCPS_LOG_AUDIT write messages to the system file in MsgView,
                    the file opened by default when running msgview from the backend.
 
                     Other Tricks:  To search for messages in msgview, use the search command:
 
                        search -flag "*<pattern>*"
 
                        Useful flags:
                            data  -> Search using words in your message with a specific pattern
                            event -> Search for messages using your object name
                        Examples:
                            Search for messages written that contain "FIN # =":
                                search -data "*FIN # =*"
                            Search for messages written by the script CERN_EMPL_XR_RPT:
                                search -event "CERN_EMPL_XR_RPT"
 
                  -------------------------------------------------------------------------------------------------
 
                  Logging to the listing:
                  - In CCPS_SCRIPT_LOGGING_SETUP program, set Debug Method to Listing, click Add To/Update List
                    and click Execute Button.
                  - Execute your script in DV Dev and view the listing.
 
                  -------------------------------------------------------------------------------------------------
 
            Via DV Dev or the backend CCL command line:
 
                Use the following constants to direct logging commands
                appropriately for your session only
 
                CCPS_DEBUG:
                    0           ==> Turns off debugging.  Will disable all
                                    logging commands.
                    1           ==> Directs all debugging statements and errors to the
                                    CCPS_FILE file.  CCPS_FILE is set to
                                    <object_name>_dbg.dat by default.
                    2           ==> Directs all debugging statements and errors to Message View
                    3           ==> Directs all debugging statments and errors to the listing.
 
                CCPS_FILE (Optional, is implicitly set to <object_name>_dbg.dat. Use with CCPS_DEBUG = 1)
                                ==> VC variable storing the file name you are interested
                                    in logging to.
 
                CCPS_REC_FORMAT (Optional, is implicitly set to 0 (JSON) by default)
                    0           ==> Sets record structure format to JSON
                    1           ==> Sets record structure format to XML
                    2           ==> Sets record structure format to the listing format
 
                CCPS_SUPPRESS_REC (Optional, is implicitly set to 0 (false) by default
                    0           ==> Does not suppress the logRecord function
                    1           ==> Suppresses all logRecord function calls
 
                CCPS_SUPPRESS_MSG (Optional, is implicitly set to 0 (false) by default
                    0           ==> Does not suppress the logMsg function
                    1           ==> Suppresses all logMsg function calls
 
**********************************************************************************************************************************
MODIFICATION CONTROL LOG
**********************************************************************************************************************************
Mod Date     Engineer             Comment
--- -------- -------------------- ------------------------------------------------------------------------------------------------
000 06/04/12 JP016332             Initial Development
001 09/11/12 ML011047             SCINT-367: Added the %#endif directive to prevent the subroutines from
                                             being declared multiple times when compiled
002 01/02/14 JP016332             Changed delimiters from ":" to "*" in query insert/update string so that a colon
                                  could be used in user input, such as in setting a file name logical (ie cust_script:)
003 07/21/15 md8090               Read value of CCPS_FILE var to set logging to a custom file name
004 01/19/17 ML011047             Added an initial value to the constant and noconstant declare options to prevent
                                  CCL-I-30 - Invalid with option (CONSTANT / NOCONSTANT) encountered in this command
**********************************************************************************************************************************
END OF ALL MODCONTROL BLOCKS
*/
 
%#ifndef CCPS_SCRIPT_LOGGING
%#def CCPS_SCRIPT_LOGGING
 
/***********************************************************************
 *   Subroutine Definitions                                            *
 ***********************************************************************/
 
; Main API
declare logMsg(MyMsg = vc, MsgLvl = i2(value,2))                            = null
declare logRecord(MyRecStruct = vc(ref))                                    = null
declare finalizeMsgs(outdest = vc(value,""), recSizeZFlag = i4(value,1))    = null
declare catchErrors(MyMsg = vc)                                             = i2
declare getReply(null)                                                      = vc
declare getErrorCount(null)                                                 = i4
declare getCodeWithCheck(type = vc, code_set = i4(value,0), expression = vc(value,"")
                         , MsgLvl = i2(value,2))                          = f8
 
; Supporting subroutines
declare setReply(myStat = vc)                                               = null
declare populateSubEventStatus(ErrorCnt = i4(value),
                            OperationName = vc (value),
                            OperationStatus = vc (value),
                            TargetObjectName = vc (value),
                            TargetObjectValue = vc (value))                 = i2
declare writeMlgMsg(msg = vc, lvl = i2)                                     = null
 
/***********************************************************************
 *   Variable/Constant Definitions                                     *
 ***********************************************************************/
 
; For record structure format
declare CCPS_JSON                  = i2 with protect, constant(0)
declare CCPS_XML                   = i2 with protect, constant(1)
declare CCPS_REC_LISTING           = i2 with protect, constant(2)
 
; For dm_info.info_domain field
declare CCPS_INFO_DOMAIN           = vc with protect, constant("CCPS_SCRIPT_LOGGING")
 
; For logging statements/errors destination
declare CCPS_NONE_IND              = i2 with protect, constant(0)
declare CCPS_FILE_IND              = i2 with protect, constant(1)
declare CCPS_MSGVIEW_IND           = i2 with protect, constant(2)
declare CCPS_LISTING_IND           = i2 with protect, constant(3)
 
; For 2nd parameter in logMsg subroutine, describing level of message written to msgview
declare CCPS_LOG_ERROR             = i2 with protect, constant(0)
declare CCPS_LOG_AUDIT             = i2 with protect, constant(2)
declare CCPS_ERROR_DISP            = vc with protect, noconstant("ERROR")
declare CCPS_AUDIT_DISP            = vc with protect, noconstant("AUDIT")
 
declare CCPS_DELIM1                = vc with protect, noconstant("*")
declare CCPS_DELIM2                = vc with protect, noconstant(";")
 
declare PREV_CCPS_DELIM1           = vc with protect, noconstant(":")
declare PREV_CCPS_DELIM2           = vc with protect, noconstant(";")
 
declare ccps_sErrMsg               = vc with protect, noconstant(fillString(132," "))
declare ccps_iErrCode              = i4 with protect, noconstant(Error(ccps_sErrMsg, 1))
 
execute msgrtl
 
/***********************************************************************
 *   Record Structures                                                 *
 ***********************************************************************/
 
; Record strcuture to hold values configured in the setup tool/command line
 
if (not validate(debug_values))
    record debug_values
    (
        1 log_program_name     = vc
        1 log_file_dest        = vc
        1 inactive_dt_tm       = vc
        1 log_level            = i2
        1 log_level_override   = i2
        1 logging_on           = i2
        1 rec_format           = i2
        1 suppress_rec         = i2
        1 suppress_msg         = i2
        1 debug_method         = i4
    ) with protect
 
    set debug_values->logging_on        = FALSE
    set debug_values->log_program_name  = CURPROG
endif
 
; Record structure to store all log messages
 
if (not validate(ccps_log))
    record ccps_log
    (
    1 ecnt                    = i4
    1 cnt                     = i4
    1 qual[*]
        2 msg                 = vc
        2 msg_type_id         = i4
        2 msg_type_display    = vc
    ) with protect
endif
 
; Supporting record structure for CCLIO commands
 
if (not validate(frec))
    record frec
    (
    1 file_desc         = i4
    1 file_offset       = i4
    1 file_dir          = i4
    1 file_name         = vc
    1 file_buf          = vc
    ) with protect
endif
 
; If reply is already defined, do not redefine it
if (not validate(reply))
    record reply
    (
%i cclsource:status_block.inc
     ) with protect
endif
 
; Set reply status to false until success is confirmed.
; Use finalizeMsgs($OUTDEV) at the end of your script and the reply status will
; aurtomatically be set to success for you if no errors occurred, or "Z" if you
; pass your record structure size to it
call setReply("F")
 
/***************************************************************************
 * Select from dm_info to see if object exists and get other logging info  *
 ***************************************************************************/
 
select into "nl:"
from
    dm_info dm
plan dm
    where dm.info_domain = CCPS_INFO_DOMAIN
    and dm.info_name = debug_values->log_program_name
    ; Inactive dt/tm has not been reached
    and dm.info_date >= cnvtdatetime(curdate,curtime3)
 
order dm.info_name
 
head dm.info_name
    entity_cnt = 0
    component_cnt = 0
 
    entity = trim(piece(dm.info_char,",",entity_cnt+1,"Not Found"),3)
    component = fillstring(4000," ") ; 4000 is the size of the oracle table field
 
    ; Assign values from table into debug_values record structure
    while (component != "Not Found")
        component_cnt   = component_cnt + 1
 
        if (findstring(CCPS_DELIM2, entity, 1) = 0) ; the current delimiter is not found, use old one for backwards compatibility
            component       = trim(piece(entity,PREV_CCPS_DELIM2,component_cnt,"Not Found"),3)
            component_head  = trim(piece(cnvtlower(component),PREV_CCPS_DELIM1,1,"Not Found"),3)
            component_value = trim(piece(component,PREV_CCPS_DELIM1,2,"Not Found"),3)
        else
            component       = trim(piece(entity,CCPS_DELIM2,component_cnt,"Not Found"),3)
            component_head  = trim(piece(cnvtlower(component),CCPS_DELIM1,1,"Not Found"),3)
            component_value = trim(piece(component,CCPS_DELIM1,2,"Not Found"),3)
        endif
 
        ; This section of code is populated from data from the CCPS_SCRIPT_LOGGING_SETUP script
        ; The javascript in the prompts of CCPS_SCRIPT_LOGGING_SETUP are where values are defined
        ; for writing to the dm_info rows
        ; If component head changes here, it must also be changed in the javascript of the
        ; CCPS_SCRIPT_LOGGING_SETUP program prompts
        case (component_head)
            of "program":
                debug_values->log_program_name = component_value
            of "debug_method":
                if (component_value = "None")
                    debug_values->debug_method = CCPS_NONE_IND
                elseif (component_value = "File")
                    debug_values->debug_method = CCPS_FILE_IND
                elseif (component_value = "Message View")
                    debug_values->debug_method = CCPS_MSGVIEW_IND
                elseif (component_value = "Listing")
                    debug_values->debug_method = CCPS_LISTING_IND
                endif
            of "file_name":
                debug_values->log_file_dest     = component_value
            of "inactive_dt_tm":
                debug_values->inactive_dt_tm    = component_value
            of "rec_type":
                debug_values->rec_format        = cnvtint(component_value)
            of "suppress_rec":
                debug_values->suppress_rec      = cnvtint(component_value)
            of "suppress_msg":
                debug_values->suppress_msg      = cnvtint(component_value)
        endcase
    endwhile
 
    if (debug_values->debug_method != CCPS_NONE_IND)
        debug_values->logging_on = TRUE
    else
        debug_values->logging_on = FALSE
    endif
 
foot dm.info_name
    NULL
 
with nocounter
 
/***************************************************************************
 * Define command line override variable and populate record structures    *
 ***************************************************************************/
 
; The user is running from DV Dev or the backend
if (validate(CCPS_DEBUG))
    if (not validate(CCPS_FILE))
        set debug_values->log_file_dest = build(debug_values->log_program_name,"_DBG.dat")
    else
    	set debug_values->log_file_dest = CCPS_FILE
    endif
 
    if (not validate(CCPS_REC_FORMAT))
        if (CCPS_DEBUG != CCPS_LISTING_IND)
            set debug_values->rec_format = CCPS_JSON
        else
            set debug_values->rec_format = CCPS_REC_LISTING
        endif
    else
        if (CCPS_REC_FORMAT = CCPS_XML)
            set debug_values->rec_format = CCPS_XML
        elseif (CCPS_REC_FORMAT = CCPS_JSON)
            set debug_values->rec_format = CCPS_JSON
        else
            set debug_values->rec_format = CCPS_REC_LISTING
        endif
    endif
 
    if (not validate(CCPS_SUPPRESS_REC))
        set debug_values->suppress_rec = FALSE
    else
        if (CCPS_SUPPRESS_REC = TRUE)
            set debug_values->suppress_rec = TRUE
        else
            set debug_values->suppress_rec = FALSE
        endif
    endif
 
    if (not validate(CCPS_SUPPRESS_MSG))
        set debug_values->suppress_msg = FALSE
    else
        if (CCPS_SUPPRESS_MSG = TRUE)
            set debug_values->suppress_msg = TRUE
        else
            set debug_values->suppress_msg = FALSE
        endif
    endif
 
    case (CCPS_DEBUG)
        of CCPS_NONE_IND:
            set debug_values->debug_method = CCPS_NONE_IND
            set debug_values->logging_on = FALSE
        of CCPS_FILE_IND:
            set debug_values->debug_method = CCPS_FILE_IND
            set debug_values->logging_on = TRUE
        of CCPS_MSGVIEW_IND:
            set debug_values->debug_method = CCPS_MSGVIEW_IND
            set debug_values->logging_on = TRUE
        of CCPS_LISTING_IND:
            set debug_values->debug_method = CCPS_LISTING_IND
            set debug_values->logging_on = TRUE
    endcase
endif ; end validate(CCPS_DEBUG)
 
; Write notifications on the status of logging
if (debug_values->logging_on)
    call echo ("****************************")
    call echo ("*** Logging is turned ON ***")
    call echo ("****************************")
 
    case (debug_values->debug_method)
        of CCPS_FILE_IND:
            call echo (build("*** Will write to file: ", debug_values->log_file_dest, "***"))
        of CCPS_MSGVIEW_IND:
            call echo ("*****************************")
            call echo ("*** Will write to MsgView ***")
            call echo ("*****************************")
        of CCPS_LISTING_IND:
            call echo ("*********************************")
            call echo ("*** Will write to the listing ***")
            call echo ("*********************************")
    endcase
 
    if (debug_values->suppress_rec = TRUE)
        call echo ("****************************")
        call echo ("***  Suppress Rec is ON  ***")
        call echo ("****************************")
    endif
 
    if (debug_values->suppress_msg = TRUE)
        call echo ("****************************")
        call echo ("***  Suppress Msg is ON  ***")
        call echo ("****************************")
    endif
else
    call echo ("*****************************")
    call echo ("*** Logging is turned OFF ***")
    call echo ("*****************************")
endif ; end debug_values->logging_on
 
/*******************************************************************
 * Subroutines                                                     *
 *******************************************************************/
 
/***********************************************************************
 *  Subroutine logMsg                                                  *
 *  This subroutine logs a message to the set destination, with        *
 *  the designated error type.                                         *
 *                                                                     *
 *  @param MyMsg      -   The log message                              *
 *  @param MsgLvl     -   Sets the type of message.                    *
 *                        (pass CCPS_LOG_ERROR / CCPS_LOG_AUDIT)       *
 *                        (Optional - CCPS_LOG_AUDIT by default        *
 ***********************************************************************/
subroutine logMsg(MyMsg, MsgLvl)
 
    declare seek_retval     = i4 with private, noconstant(0)
    declare filelen         = i4 with private, noconstant(0)
    declare write_stat      = i2 with private, noconstant(0)
    declare iMsgLvl         = i2 with private, noconstant(0)
    declare sMsgLvl         = vc with private, noconstant("")
    declare sLogText        = vc with private, noconstant("")
    declare start_char      = i4 with private, noconstant(0)
 
    set iMsgLvl = MsgLvl
    set sLogText = MyMsg
 
    if (debug_values->suppress_msg = FALSE or (debug_values->suppress_msg = TRUE and MsgLvl = CCPS_LOG_ERROR))
 
        ; write error to gloabal log record structure
        if (iMsgLvl = CCPS_LOG_ERROR or debug_values->logging_on = TRUE)
            set ccps_log->cnt = ccps_log->cnt+ 1
            if (MsgLvl = CCPS_LOG_ERROR)
                set ccps_log->ecnt = ccps_log->ecnt + 1
            endif
            ; write to log message record structure
            set stat = alterlist(ccps_log->qual, ccps_log->cnt)
            set ccps_log->qual[ccps_log->cnt].msg = trim(MyMsg,3)
            set ccps_log->qual[ccps_log->cnt].msg_type_id = MsgLvl
            if (MsgLvl = CCPS_LOG_ERROR)
                set ccps_log->qual[ccps_log->cnt].msg_type_display = CCPS_ERROR_DISP
            else
                set ccps_log->qual[ccps_log->cnt].msg_type_display = CCPS_AUDIT_DISP
            endif
        endif
 
        ; Define display pointing out logging type that will appear in the file,
        ; if file file is chosen for method
        case (iMsgLvl)
            of CCPS_LOG_ERROR:
                set sMsgLvl = "Error"
            of CCPS_LOG_AUDIT:
                set sMsgLvl = "Audit"
        endcase
 
        ; if message is an error, write to message view and populate reply
        if (iMsgLvl = CCPS_LOG_ERROR)
 
            ; write error to msgview
            call writeMlgMsg(sLogText, iMsgLvl)
 
            ; populate subeventstatus in reply
            call populateSubEventStatus
                    (ccps_log->ecnt, CCPS_ERROR_DISP, "F", build(curprog) , trim(MyMsg,3))
 
        endif
 
        ; If logging is on, determine where to write the message
        if (debug_values->logging_on = TRUE)
 
            if (debug_values->debug_method = CCPS_MSGVIEW_IND and MsgLvl != CCPS_LOG_ERROR)
                ; write to message view and add to log record structure
                call writeMlgMsg(sLogText, iMsgLvl)
 
            elseif (debug_values->debug_method = CCPS_FILE_IND)
                ; set file to append / create if it doesn't exist and write message to file stream
                set frec->file_name = debug_values->log_file_dest
                set frec->file_buf = "ab"
                set stat = cclio("OPEN",frec)
                set frec->file_dir = 2
                set seek_retval = cclio("SEEK",frec)
                set filelen = cclio("TELL",frec)
                set frec->file_offset = filelen
                set frec->file_buf =
                    build2(
                        format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy hh:mm:ss;;d"),
                        fillstring(5," "),
                        "{",sMsgLvl,"}",
                        fillstring(5," "),
                        MyMsg,
                        char(13),char(10)
                        )
                set write_stat = cclio("WRITE",frec)
                set stat = cclio("CLOSE",frec)
 
             elseif (debug_values->debug_method = CCPS_LISTING_IND)
                ; echo out message display line to the listing
                call echo
                    (
                     build2
                        ("*** ",
                        format(cnvtdatetime(curdate,curtime3),"mm/dd/yyyy hh:mm:ss;;d")
                        ,fillstring(5," ")
                        ,"{",sMsgLvl,"}"
                        ,fillstring(5," ")
                        ,MyMsg)
                        )
             endif ;end debug_values->debug_method = CCPS_MSGVIEW_IND and MsgLvl != CCPS_LOG_ERROR
        endif ;end debug_values->logging_on = TRUE
    endif ;end debug_values->suppress_msg = FALSE or (debug_values->suppress_msg = TRUE and MsgLvl = CCPS_LOG_ERROR)
end ; end logMsg subroutine
 
/************************************************************************
 *  Subroutine logRecord                                                *
 *  This subroutine logs a record structure (MyRecStruct) to a          *
 *  destination.  The json record is logged by default, unless          *
 *  XML is configured otherwise.                                        *
 *  @param MyRecStruct -- the record structure passed in                *
 ************************************************************************/
subroutine logRecord(MyRecStruct)
    if (debug_values->suppress_rec = FALSE)
        declare sMsgType    = vc with private, noconstant("")
        declare write_stat  = i4 with private, noconstant(0)
 
        set sMsgType = "Audit"
 
        ; If logging is on, determine where to write the message
        if (debug_values->logging_on = TRUE)
            if (debug_values->debug_method = CCPS_FILE_IND)
                 set frec->file_name    = debug_values->log_file_dest
                 ; set file to append / create if it doesn't exist and write message to file stream
                 set frec->file_buf     = "ab" ;file open mode
                 set stat               = cclio("OPEN",frec)
                 set frec->file_dir     = 2
                 set seek_retval        = cclio("SEEK",frec)
                 set filelen            = cclio("TELL",frec)
                 set frec->file_offset  = filelen
                 set frec->file_buf     =
                                          build2(
                                                format(
                                                    cnvtdatetime(curdate,curtime3),
                                                    "mm/dd/yyyy hh:mm:ss;;d"
                                                      ),
                                                fillstring(5," "),
                                                "{",sMsgType,"}",
                                                fillstring(5," ")
                                                )
 
                 if (debug_values->rec_format = CCPS_XML)
                    call echoxml(MyRecStruct, debug_values->log_file_dest, 1)
                 elseif (debug_values->rec_format = CCPS_JSON)
                    call echojson(MyRecStruct, debug_values->log_file_dest, 1)
                 else
                    call echorecord(MyRecStruct, debug_values->log_file_dest, 1)
                 endif
 
                 set frec->file_buf = build(frec->file_buf, char(13),char(10))
                 set write_stat = cclio("WRITE",frec)
                 set stat = cclio("CLOSE",frec)
             elseif (debug_values->debug_method = CCPS_LISTING_IND)
                 call echo (
                            build2("*** ",
                                    format
                                    (
                                    cnvtdatetime(curdate,curtime3),
                                    "mm/dd/yyyy hh:mm:ss;;d"
                                    ),
                                    fillstring(5," "),
                                    "{",sMsgType,"}",
                                    fillstring(5," ")
                                  )
                            )
                 if (debug_values->rec_format = CCPS_XML)
                    call echoxml(MyRecStruct)
                 elseif (debug_values->rec_format = CCPS_JSON)
                    call echojson(MyRecStruct)
                 else
                    call echorecord (MyRecStruct)
                 endif
             endif ;end debug_values->debug_method = CCPS_FILE_IND
        endif ;end debug_values->logging_on = TRUE
    endif ;end debug_values->suppress_rec = FALSE
end ; end logRecord subroutine
 
/***********************************************************************
 *   Subroutine catchErrors                                            *
 *   The catchErrors routine is called to check for CCL errors after   *
 *   a select statement.  If errors are found, this routine will       *
 *   write the error to message view, and to the specified destination *
 *   if logging is enabled.                                            *
 *   The subeventstatus block in the reply record                      *
 *   will be updated as well.                                          *
 *   @param MyMsg   -- A message describing where the error check      *
 *                     is being performed                              *
 *   @return        -- 0:  Errors did not occur                        *
 *                     1:  Errors occurred                             *
 ***********************************************************************/
subroutine catchErrors(MyMsg)
 
    declare ccps_iErrorOccurred     = i2 with private, noconstant(0)
 
    ; Check for CCL error
    set ccps_iErrCode = Error(ccps_sErrMsg, 0)
 
    ; Loop through eror stack and write error messages. (Maximum of 50 to prevent infinite loop if errors continually occur)
    while (ccps_iErrCode > 0 and ccps_log->ecnt < 50)
        set ccps_iErrorOccurred = 1
 
        ; Write message passed in with the corresponding error (This helps user assess where error occurred)
        call logMsg(trim(build2(MyMsg, " -- ", trim(ccps_sErrMsg,3)),3), CCPS_LOG_ERROR)
 
        ; Retrieve additional CCL errors
        set ccps_iErrCode = Error(ccps_sErrMsg, 1)
    endwhile
 
    return(ccps_iErrorOccurred)
 
end ; end catchErrors subroutine
 
/***********************************************************************
 *   Subroutine getErrorCount                                          *
 *   Gets the current number of errors found                           *
 *   @return -- Returns the count of errors                            *
 ***********************************************************************/
subroutine getErrorCount(null)
    return (ccps_log->ecnt)
end ;end getErrorCount subroutine
 
/*****************************************************************************
 *   Subroutine finalizeMsgs                                                 *
 *   The finalizeMsgs routine:                                               *
 *      - outputs errors and messages to the output destination (outdev)     *
 *        parameter                                                          *
 *      - Prints a loggging summary to the listing, if listing is chosen     *
 *      - Sets the reply status accordingly                                  *
 *                                                                           *
 *   @param outdest      --  Output destination (Optional)                   *
 *   @param recSizeZFlag --  the size of the main record structure, which    *
 *                           is used to determine whether the reply status   *
 *                           should be set to "Z" (Optional)                 *
 *****************************************************************************/
subroutine finalizeMsgs(outdest, recSizeZFlag)
 
    declare errCnt = i4 with noconstant(0), private
 
    ; Run catchErrors routine to pick up any errors not caught yet
    set stat = catchErrors("Performing final check for errors...")
 
    ; Get error count and use the count to determine the reply status.
    ; The reply status is set to "Z" if the developer sends the record size as the second parameter and the size is zero
 
    set errCnt = getErrorCount(null)
 
    ; set reply status accordingly
    if (errCnt > 0)
        call setReply("F")
    elseif (recSizeZFlag = 0)
        call setReply("Z")
    else
        call setReply("S")
    endif
 
    ; if there were errors and an output destination exists, output the errors to that destination
    if (ccps_log->ecnt > 0 and cnvtstring(outdest) != "")
        select into value(outdest)
 
        from (dummyt d with seq = ccps_log->cnt)
 
        plan d
            where ccps_log->qual[d.seq].msg_type_id = CCPS_LOG_ERROR
 
        head report
            call print(build2("*** Errors have occurred in the CCL Script.  Please contact your System Administrator ",
                               "and/or Cerner for assistance with resolving the issue. ***", char(13), char(10), char(13), char(10
                               )))
        detail
            call print(ccps_log->qual[d.seq].msg)
            row + 1
 
        foot report
            NULL
 
        with nocounter, maxcol = 500
     endif
 
     ; If listing is the debug method, output the summary with call echos
     if (debug_values->debug_method = CCPS_LISTING_IND)
         call echo ("********************************")
         call echo ("*** Printing Logging Summary ***")
         call echo ("********************************")
         call logRecord(ccps_log)
         call logRecord(reply)
     endif
 
end ;end finalizeMsgs subroutine
 
/****************************************************************************
*   Subroutine setReply                                                     *
*   The setReply routine sets the current status of the reply               *
*   @param myStat - The parameter passed in for the status to be set to     *
*****************************************************************************/
subroutine setReply(myStat)
    if (validate(reply->status_data->status) = 1)
        set reply->status_data->status = myStat
    endif
end ;end setReply subroutine
 
/****************************************************************************
*   Subroutine getReply                                                     *
*   The getReply routine gets the current status of the reply               *
*   @ return - Returns current status of reply                              *
*****************************************************************************/
subroutine getReply(null)
    if (validate(reply->status_data->status) = 1)
        return (reply->status_data->status)
    else
        return ("Z")
    endif
end ;end getReply subroutine
 
/************************************************************************************
*   Subroutine getCodeWithCheck                                                     *
*   The getCodeWithCheck subroutine checks if a uar lookup returns a code value     *
*   check for a CKI:  getCodeWithCheck("CKI.CODEVALUE!9999999")                     *
*   check for non CKI value: getCodeWithCheck("MEANING",999,"ABCDEFG")              *
*
*   @param type         - Field type from code value table                          *
*                         (DISPLAY/DISPLAYKEY/MEANING) or the CKI value             *
*   @param code_set     - Code set number. (For non cki lookup)                     *
*   @param expression   - Expression associated with the type (For non cki lookup)  *
*   @param MsgLvl       - Level at which to log a message in the case no code       *
*                         value is found (Optional - CCPS_LOG_AUDIT by default      *
*   @Return             - Code value of the uar call                                *
*************************************************************************************/
 
subroutine getCodeWithCheck(type, code_set, expression, MsgLvl)
    declare cki_flag = i2 with private, noconstant(0)
 
    if (code_set = 0) ; CKI lookup is used
        declare tmp_code_value = f8 with private, noconstant(uar_get_code_by_cki(type))
        set cki_flag = 1
    else              ; non CKI lookup is used
        declare tmp_code_value = f8 with private, noconstant(uar_get_code_by(type, code_set, expression))
    endif
 
    if (tmp_code_value <= 0)
        if (cki_flag = 0)
            call logMsg(
                build2("*** ! Code value from code set ",trim(cnvtstring(code_set),3)," with ",type," of ",expression
                , " was not found !"), MsgLvl)
        else
            call logMsg(
                build2("*** ! Code value with CKI of ", type
                , " was not found !"), MsgLvl)
        endif
 
    endif
 
    return (tmp_code_value)
 
end ;end getCodeWithCheck subroutine
 
/****************************************************************************
*   Subroutine populateSubEventStatus                                       *
*   The populateSubEventStatus routine is called to fill out an entry       *
*   in the subeventstatus list of a standard reply.                         *
*   @param ErrorCnt           -- Counter for errors                         *
*   @param OperationName      -- "ERROR"                                    *
*   @param OperationStatus    -- "S", "F" or "Z"                            *
*   @param TargetObjectName   -- Objects Name                               *
*   @param TargetObjectValue  -- Log Message                                *
*****************************************************************************/
subroutine populateSubEventStatus(ErrorCnt, OperationName, OperationStatus, TargetObjectName, TargetObjectValue)
 
    declare ccps_iSubEventCnt          = i4 with protect, noconstant(0)
    declare ccps_iSubEventSize         = i4 with protect, noconstant(0)
 
    ; If running from Operations, set the ops_event to the first error encountered.
    if (validate(reply->ops_event) = 1 and ErrorCnt = 1)
        set reply->ops_event = TargetObjectValue
    endif
 
    /* Validate that status block exists */
    if (validate(reply->status_data->status, "-1") != "-1")
        /* get current size of subevent status */
        set ccps_iSubEventCnt = size(reply->status_data->subeventstatus, 5)
 
        /* If last item in array is populated, then increase the size of the array by one.
           Otherwise, assume it is an empty item in the list and use it. */
        if (ccps_iSubEventCnt > 0)
			set ccps_iSubEventSize = size(trim(reply->status_data->subeventstatus[ccps_iSubEventCnt].OperationName))
	        set ccps_iSubEventSize = ccps_iSubEventSize +
	          size(trim(reply->status_data->subeventstatus[ccps_iSubEventCnt].OperationStatus))
	        set ccps_iSubEventSize = ccps_iSubEventSize +
	          size(trim(reply->status_data->subeventstatus[ccps_iSubEventCnt].TargetObjectName))
	        set ccps_iSubEventSize = ccps_iSubEventSize +
	          size(trim(reply->status_data->subeventstatus[ccps_iSubEventCnt].TargetObjectValue))
		endif
 
		if (ccps_iSubEventSize > 0)
            set ccps_iSubEventCnt = ccps_iSubEventCnt + 1
            set iLoggingStat = alter(reply->status_data->subeventstatus, ccps_iSubEventCnt)
        endif
 
		if (ccps_iSubEventCnt > 0)
	        set reply->status_data.subeventstatus[ccps_iSubEventCnt].OperationName =
	          substring(1, 25, OperationName)
	        set reply->status_data.subeventstatus[ccps_iSubEventCnt].OperationStatus =
	          substring(1, 1, OperationStatus)
	        set reply->status_data.subeventstatus[ccps_iSubEventCnt].TargetObjectName =
	          substring(1, 25, TargetObjectName)
	        set reply->status_data.subeventstatus[ccps_iSubEventCnt].TargetObjectValue =
	          TargetObjectValue
		endif
    endif
 
end ; end populateSubEventStatus subroutine
 
/************************************************************************************
* Subroutine writeMlgMsg()                                                          *
* The writeMlgMsg subroutine writes a string to msview view at the level specified  *
* @param msg - log message                                                          *
* @param lvl - log level                                                            *
*************************************************************************************/
 
subroutine writeMlgMsg(msg, lvl)
    declare sys_handle = i4 with noconstant(0),private
    declare sys_status = i4 with noconstant(0),private
 
    call uar_SysCreateHandle (sys_handle, sys_status)
 
    ; only log the message if we have a valid handle
    if (sys_handle > 0)
        call uar_Msgsetlevel(sys_handle, lvl)
        call uar_SysEvent(sys_handle, lvl, nullterm(debug_values->log_program_name), nullterm(msg))
        call uar_SysDestroyHandle(sys_handle)
    endif
end ;end writeMlgMsg subroutine
 
set lastmod = "004 01/19/2017 ML011047"
 
%#endif CCPS_SCRIPT_LOGGING
 

