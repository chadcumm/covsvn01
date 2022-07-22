;******************************************************************************
;*                                                                            *
;*  Copyright Notice:  (c) 1983 Laboratory Information Systems &              *
;*                              Technology, Inc.                              *
;*       Revision      (c) 1984-2009 Cerner Corporation                       *
;*                                                                            *
;*  Cerner (R) Proprietary Rights Notice:  All rights reserved.               *
;*  This material contains the valuable properties and trade secrets of       *
;*  Cerner Corporation of Kansas City, Missouri, United States of             *
;*  America (Cerner), embodying substantial creative efforts and              *
;*  confidential information, ideas and expressions, no part of which         *
;*  may be reproduced or transmitted in any form or by any means, or          *
;*  retained in any storage or retrieval system without the express           *
;*  written permission of Cerner.                                             *
;*                                                                            *
;*  Cerner is a registered mark of Cerner Corporation.                        *
;*                                                                            *
;*                                                                            *
;******************************************************************************
;
;
;     Source file name:       sc_cps_parse_date_subs.inc
;
;     Product:                Discern Explorer
;     Product Team:           Solutions Center Custom Discern Team
;     HNA Version:
;     CCL Version:
;
;     Program purpose:        Subroutines used for parsing a date prompt
;
;     Tables read:            None
;
;     Tables updated:         None
;
;     Special Notes:          None
;
;******************************************************************************
;                      GENERATED MODIFICATION CONTROL LOG
;******************************************************************************
;
; Feature Date         Engineer   Comment (SR #)
; ------- -----------  ---------- ---------------------------------------------
; 200342  11-FEB-2009  CH014093   Initial Design
; 500285  19-JAN-2017  ML011047   Added an initial value to the noconstant
;                                 declare option to prevent CCL-I-30
;                                 (Invalid with option)
;******************************************************************************
 
 
;**************************************************************
; DECLARED SUBROUTINES
;**************************************************************
declare ParseDatePrompt(date_str = vc, default_date = vc, time = i4) = dq8
 
declare _EvaluateDateStr(date_str = vc) = i4
declare _ParseDate(date_str = vc) = i4
 
;********************************************************************************
; Parse a Date Prompt
;********************************************************************************
; Description: Returns a dq8 for the date string and time passed in.  If a valid
;              dq8 can not be created, the default date will be used.
;
; Inputs: date_str [vc] - A string representation of your date such as
;                         "03-JAN-2009" or "01032009".  Integer representations,
;                         such as 01032009 or CURDATE, are also handled.
;         default_date [vc] - If the date_str cannot be properly parsed into a
;                             date, the default_date will be returned.  This too
;                             should be a string or integer representation of a
;                             date.  Additionally, default_date can handle a dq8
;                             data type for more complex situations.
;         beg_end_ind [i4] - An integer representing the time in which you would
;                            like appended to your date.  Valid input can be
;                            formatted as 0, 000000, 123000 or 235959.
;
; Returns: [dq8] representing time on date_str.  If date_str is empty or invalid
;          the return will be time on default_date.
;********************************************************************************
subroutine ParseDatePrompt(date_str, default_date, time)
    declare _return_val = dq8 with noconstant(0.0),private
 
    declare _time = i4 with constant(cnvtint(time)),private
    declare _date = i4 with constant(_ParseDate(date_str)),private
 
    if (_date = 0.0)
        ;Did not parse a valid date, so set to default
        ;call echo("Setting Default")
        case (substring(1, 1, reflect(default_date)))
            of "F":
                set _return_val = cnvtdatetime(cnvtdate(default_date), _time)
            of "C":
                set _return_val = cnvtdatetime(_EvaluateDateStr(default_date), _time)
            of "I":
                set _return_val = cnvtdatetime(default_date, _time)
            else
                set _return_val = 0
        endcase
    else
        set _return_val = cnvtdatetime(_date, _time)
    endif
 
    return (_return_val)
end  ;subroutine ParseDatePrompt
 
subroutine _ParseDate(date_str)
    declare _return_val = dq8 with noconstant(0.0),private
    declare _time = i4 with constant(0),private
 
    if (isnumeric(date_str))
        ;call echo("Is numeric")
        declare _date = vc with constant(trim(cnvtstring(date_str))),private
        set _return_val = cnvtdatetime(cnvtdate(_date), _time)
 
        if (_return_val = 0.0)
            set _return_val = cnvtdatetime(cnvtint(_date), _time)
        endif
    else
        ;call echo("Is not numeric")
        declare _date = vc with constant(trim(date_str)),private
        ;call echo(build2("textlen = ", textlen(trim(_date))))
        if (textlen(trim(_date)) = 0)
            ;call echo("No Start Date Passed")
            set _return_val = 0
        else
            if (_date in ("*CURDATE*"))
                set _return_val = cnvtdatetime(_EvaluateDateStr(_date), _time)
            else
                set _return_val = cnvtdatetime(cnvtdate2(_date, "DD-MMM-YYYY"), _time)
            endif
        endif
    endif
 
    return (cnvtdate(_return_val))
end ;subroutine _ParseDate
 
subroutine _EvaluateDateStr(date_str)
    declare _dq8 = dq8 with noconstant(0.0),private
    declare _parse = vc with constant(concat("set _dq8 = cnvtdatetime(", date_str, ", 0) go")),private
    call parser(_parse)
    return (cnvtdate(_dq8))
end ;subroutine _EvaluateDateStr
 
 
 
 
 

