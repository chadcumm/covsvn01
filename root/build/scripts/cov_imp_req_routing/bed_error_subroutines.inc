/***********************************************************************
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
 
     Source File Name:       bed_error_subroutines.inc
 
     Product:                Bedrock
     Product Team:           Bedrock
     HNA Version:            500
     CCL Version:            8.2.5
 
     Program Purpose:        Check for and capture any CCL errors and
                             display them to the specified output.
 
     Tables Read:            None
 
     Tables Updated:         None
 
     Special Notes:          Copy of ukr_error_subroutines.inc from
                             the UK Programme Reporting team.
 
***************************************************************************
*                      GENERATED MODIFICATION CONTROL LOG                 *
***************************************************************************
*                                                                         *
* Feature   Date      Engineer       Comment                              *
* ------- ----------  -------------- -------------------------------------*
*  111766 10/23/2006  Matt Duncan    Initial Release                      *
**************************************************************************/
 
if (validate(BED_ERROR_SUBROUTINES) != 0)
    go to BED_ERROR_SUBROUTINES_EXIT
endif
 
 
;Constants
declare BED_ERROR_SUBROUTINES = i2 with public, constant(1)  ;Used to tell if this file has already been included.
declare MAX_ERRORS = i4 with public, constant(20) ;The maximum number of errors to capture.
declare FAILURE    = c1 with public, constant("F")   ;Script failure
declare NO_DATA    = c1 with public, constant("Z")   ;No data returned/present
declare WARNING    = c1 with public, constant("W")   ;Script warning
 
 
;Record to hold error information
free record errors
record errors
(
  1 error_ind = i2
  1 error_cnt = i4
%i cclsource:status_block.inc
)
 
 
;Subroutines
declare CheckError(s_status = c1, s_op_name = vc, s_op_status = c1, s_target_obj_name = vc) = i2
declare AddErrorMsg(s_status = c1, s_op_name = vc, s_op_status = c1, s_target_obj_name = vc, s_target_obj_value = vc) = null
declare ShowErrors(s_output = vc) = null
 
 
;Variables
declare ms_err_msg = vc with private, noconstant("")
 
 
;Initialize the CCL error queue
set stat = error(ms_err_msg, 1)
 
;Free the temp variable used to initialize the queue
free set ms_err_msg
 
 
;Check for CCL errors and add each to subeventstatus
;params:  Items to match structure members of the status block to use in case of an error.
;return:  1 => Error(s) found
;         0 => No errors
subroutine CheckError(s_status, s_op_name, s_op_status, s_target_obj_name)
    declare s_err_msg  = vc with private, noconstant("")
    declare l_err_code = i4 with private, noconstant(0)
    declare l_err_cnt  = i4 with private, noconstant(0)
 
    ;Check for any CCL errors
    set l_err_code = error(s_err_msg, 0)
 
    ;Loop until all errors are retrieved or MAX_ERRORS is exceeded. This is to avoid
    ;an infinite loop that can result if there are errors in these CCL error subroutines
    ;since this will continue processing as long as CCL errors are being generated.
    while (l_err_code > 0 and l_err_cnt < MAX_ERRORS)
        ;Set the error_ind flag to show at least one error was caught
        set errors->error_ind = 1
 
        ;Increment the l_err_cnt to avoid an infinite-loop
        set l_err_cnt = l_err_cnt + 1
 
        ;Add error to subeventstatus
        call AddErrorMsg(s_status, s_op_name, s_op_status, s_target_obj_name, s_err_msg)
 
        ;Check for next CCL error
        set l_err_code = error(s_err_msg, 0)
    endwhile
 
    return (errors->error_ind)
end  ;subroutine CheckError
 
 
;Add the given information to the status block
;params:  Items to match structure members of the status block
;return:  None
subroutine AddErrorMsg(s_status, s_op_name, s_op_status, s_target_obj_name, s_target_obj_value)
 
    ;Increment the global error_cnt to indicate an error was found
    set errors->error_cnt = errors->error_cnt + 1
 
    ;Make sure the statuses are in uppercase, ie: "F", "Z", etc
    set s_status = cnvtupper(trim(substring(1, 1, s_status), 3))
    set s_op_status = cnvtupper(trim(substring(1, 1, s_op_status), 3))
 
    ;Update overall error status if the current status is specified (s_status)
    ;and the existing status (errors->status_data->status) is not failure.
    if (textlen(s_status) > 0 and errors->status_data->status != FAILURE)
        set errors->status_data->status = s_status
    endif
 
    ;Make sure the error_ind is set if the overall status is failure
    if (errors->status_data->status = FAILURE)
        set errors->error_ind = 1
    endif
 
    ;Display a message if this was marked as a failure error at either level.
    if (s_status = FAILURE or s_op_status = FAILURE)
        call echo(concat("SCRIPT FAILURE - ", trim(s_target_obj_value, 3)))
    endif
 
    ;Make sure the subeventstatus is big enough
    if (size(errors->status_data->subeventstatus, 5) < MAX_ERRORS)
        set stat = alter(errors->status_data->subeventstatus, MAX_ERRORS)
    endif
 
    ;Populate subeventstatus
    set errors->status_data->subeventstatus[errors->error_cnt].operationname     = trim(substring(1, 25, s_op_name), 3)
    set errors->status_data->subeventstatus[errors->error_cnt].operationstatus   = s_op_status
    set errors->status_data->subeventstatus[errors->error_cnt].targetobjectname  = trim(substring(1, 25, s_target_obj_name), 3)
    set errors->status_data->subeventstatus[errors->error_cnt].targetobjectvalue = trim(s_target_obj_value, 3)
 
end  ;subroutine AddErrorMsg
 
 
;Output the errors to the destination specified in s_output
;params:  s_output => where to print the output, ie: File/Printer/MINE
;return:  None
subroutine ShowErrors(s_output)
    declare s_output_dest = vc with protect, noconstant(cnvtupper(trim(s_output, 3)))
 
    ;If no errors were caught, don't show anything
    if (errors->error_cnt > 0)
        ;Resize the subeventstatus list to remove any blank items
        set stat = alter(errors->status_data->subeventstatus, errors->error_cnt)
 
        ;If no output specified, or MINE is used,
        ;set the output to NOFORMS to show on the screen
        if (textlen(s_output_dest) = 0 or s_output_dest = "MINE")
            set s_output_dest = "NOFORMS"
        endif
 
        ;Display a blank line if outputting to the screen.
        if (s_output_dest = "NOFORMS")
            call echo("")
        endif
 
        ;Display the errors to s_output_dest, the first line is a header showing the overall
        ;script status (errors->status_data->status) and the program name that is executing.
        select into value(s_output_dest)
            operation_name      = evaluate(d.seq, 1, "ERROR LOG",
                                                     errors->status_data->subeventstatus[d.seq - 1].operationname),
            target_object_name  = evaluate(d.seq, 1, "ERROR LOG",
                                                     errors->status_data->subeventstatus[d.seq - 1].targetobjectname),
            status              = evaluate(d.seq, 1, errors->status_data->status,
                                                     errors->status_data->subeventstatus[d.seq - 1].operationstatus),
            error_message       = trim(substring(1, 100, evaluate(d.seq, 1,
                                      concat("SCRIPT ERROR LOG FOR: ", trim(curprog, 3)),
                                      errors->status_data->subeventstatus[d.seq - 1].targetobjectvalue)))
        from (dummyt d with seq = value(errors->error_cnt + 1))
        plan d
        with nocounter, format, separator = " "
    endif
 
end  ;subroutine ShowErrors
 
 
#BED_ERROR_SUBROUTINES_EXIT
 

