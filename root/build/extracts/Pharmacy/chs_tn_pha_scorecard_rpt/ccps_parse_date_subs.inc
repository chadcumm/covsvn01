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
;     Source file name:       ccps_parse_date_subs.inc
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
;         16-FEB-2018  RS049105   Added ParseDateOperations, originally from
;                                 ML011047, updated default functionality
;         19-FEB-2018  RS049105   Updated ParseDatePrompt to accept more date
;                                 formats
;******************************************************************************
 
;********************************************************************************
; Main Functionality
;********************************************************************************
 
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
subroutine (ParseDatePrompt(date_str = vc, default_date = vc, time = i4) = dq8)
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
 
;********************************************************************************
; Parse Date Operations
;********************************************************************************
; Description: Calculates a date time value based upon an interval(days, week,
;              month, quarter, or year) of a specified relative range (begin or
;              end).
;
; Inputs: pDateUnits(Required):
;              date:  the date unit to find (CURDATE, CURWEEK, CURMONTH,
;                     CURQUARTER, CURYEAR)
;              units: the number of units to look behind/ahead from the current
;                     date
;
;         pRangeMode(Optional): find the beginning or ending day of the date unit
;                              "B" Find begin
;                              "E" Find end
;                              Defaults: "B" Find begin
;
;         pTimeMode(Optional): find the beginning or ending time of the date unit
;                              "B" Begin time of day
;                              "E" End time of day
;                              "P" Preserve time of day
;                              Defualts: "B" Begin time of day
;
; Returns: [dq8] representing date and time inputs.  If pDateUnits is empty or
;          invalid the return will be CURDATE.
;
; Examples: set date = ParseDateOperations("CURQUARTER-1", "B", "B")
;           ~ returns 01-JUL-2014 00:00:00
;           set date = ParseDateOperations("CURQUARTER-1", "E", "E")
;           ~ returns 30-SEP-2014 23:59:59
;
;           execute asdf "MINE", "CURMONTH-1", "CURMONTH" go
;           set date = ParseDateOperations($BEGINDATE, "B","B")
;           ~ returns 01-JUN-2014 00:00:00
;           set date = ParseDateOperations($ENDDATE, "E", "E")
;           ~ returns 31-JUL-2014 23:59:59
;********************************************************************************
subroutine (ParseDateOperations(pDateUnits = vc, pRangeMode = vc(value,"B"), pTimeMode = vc(value,"B")) = dq8)
  declare type          = vc  with private, noconstant("")
  declare units         = i2  with private, noconstant(0)
  declare interval_type = c1  with private, noconstant("")
  declare date_mode     = c1  with private, noconstant("")
  declare return_date   = dq8 with private, noconstant(0.0)
  declare search_exp    = c1  with private, noconstant("")
 
  ;CURDATE-1, CURWEEK-2, CURMONTH-3, CURQUARTER-1, CURYEAR-1
  ;CURDATE+1, CURWEEK+2, CURMONTH+3, CURQUARTER+1, CURYEAR+1
 
  if(findstring("-", pDateUnits, 1))
    set search_exp = "-"
  elseif(findstring("+", pDateUnits, 1))
    set search_exp = "+"
  endif
 
  set type  = cnvtupper(trim(piece(pDateUnits, search_exp, 1, "CURDATE"),3)) ;CURDATE, CURWEEK, CURMONTH, CURQUARTER, CURYEAR
  set units = cnvtint(piece(pDateUnits, search_exp, 2, "0")); 1, 2, 3, 1, 1
 
  case(type)
    of "CURDATE":
      set interval_type   = "D"
      set date_mode       = "D"
    of "CURWEEK":
      set interval_type   = "W"
      set date_mode       = "W"
    of "CURMONTH":
      set interval_type   = "M"
      set date_mode       = "M"
    of "CURQUARTER":
      set interval_type   = "M"
      set date_mode       = "Q"
      set units           = units * 3 ;months in a quarter
    of "CURYEAR":
      set interval_type   = "Y"
      set date_mode       = "Y"
    else
      set interval_type   = "D"
      set date_mode       = "D"
  endcase
 
  if(search_exp = "-")
    set return_date = cnvtlookbehind(build(units, ",", interval_type), cnvtdatetime(curdate,curtime3))
  else
    set return_date = cnvtlookahead(build(units, ",", interval_type), cnvtdatetime(curdate,curtime3))
  endif
 
  set return_date = datetimefind(cnvtdatetime(return_date), date_mode, pRangeMode, pTimeMode)
 
  if(cnvtdatetime(return_date) = 0.0)
    set return_date = cnvtdatetime(curdate, curtime3)
  endif
 
  return(return_date)
end
 
;********************************************************************************
; Supporting Subroutines
;********************************************************************************
subroutine (_ParseDate(date_str = vc) = i4)
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
                set _return_val = cnvtdatetime(cnvtdate2(_date, _EvaluateDateFormat(_date)), _time)
            endif
        endif
    endif
 
    return (cnvtdate(_return_val))
end ;subroutine _ParseDate
 
subroutine (_EvaluateDateStr(date_str = vc) = i4)
    declare _dq8 = dq8 with noconstant(0.0),private
    declare _parse = vc with constant(concat("set _dq8 = cnvtdatetime(", date_str, ", 0) go")),private
    call parser(_parse)
    return (cnvtdate(_dq8))
end ;subroutine _EvaluateDateStr
 
;********************************************************************************
; Evalute Date Format
;********************************************************************************
; Description: Supporing subroutine that returns a string of the format based on
;              the date string passed in. If a two digit month and two digit day
;              are passed in, it's assumed that the order is Month then Day.
;              If nothing qualifies the default value of DD-MMM-YYYY is returned.
;
; Inputs:     date_str[vc]
;               formats: "MM-DD-YYYY"       "MM/DD/YYYY"
;                        "MMM-DD-YYYY"      "MMM/DD/YYYY"
;                        "DD-MMM-YYYY"      "DD/MMM/YYYY"
;
; Returns:    [vc] representing the format of the date variable entered.
;               default: "DD-MMM-YYYY"
;
; Examples: set date_format = _EvaluateDateFormat("12/09/1990")
;             ~ return: "MM/DD/YYYY"
;           set date_format = _EvaluateDateFormat("09/DEC/1990")
;             ~ return: "DD/MMM/YYYY"
;********************************************************************************
subroutine (_EvaluateDateFormat(date_str = vc) = vc)
    declare _format_str  = vc with protect, noconstant("DD-MMM-YYYY") ;Normal format
    declare _swap_str    = vc with protect, noconstant("")
    declare _search_exp  = vc with protect, noconstant("")
    declare _search_day  = vc with protect, noconstant("")
    declare _search_mth  = vc with protect, noconstant("")
    declare _search_pos  = i4 with protect, noconstant(0)
 
    ;Find the delimiter
    if(findstring("/",date_str,1))
        set _search_exp = "/"
        set _search_pos = findstring(_search_exp,date_str)
    elseif(findstring("-",date_str,1))
        set _search_exp = "-"
        set _search_pos = findstring(_search_exp,date_str)
    endif
 
    ;Initially assert day comes before month
    set _search_day  = trim(piece(date_str,_search_exp,1,""),3)
    set _search_mth  = trim(piece(date_str,_search_exp,2,""),3)
 
    ;Check for 3 character month first
    if(textlen(_search_day) > 2)
        set _swap_str   = _search_day
        set _search_day = _search_mth
        set _search_mth = _swap_str
    endif
 
    ;Determine format
    case(_search_pos)
        of 4: ;3 character month is first
            case(_search_exp)
                of "-":
                    set _format_str = "MMM-DD-YYYY"
                of "/":
                    set _format_str = "MMM/DD/YYYY"
            endcase
        of 3:
            if(textlen(_search_mth) > 2) ;If the month is MMM
                case(_search_exp)
                    of "-":
                        set _format_str = "DD-MMM-YYYY"
                    of "/":
                        set _format_str = "DD/MMM/YYYY"
                endcase
            else ;Assume month always comes first
            case(_search_exp)
                of "-":
                    set _format_str = "MM-DD-YYYY"
                of "/":
                    set _format_str = "MM/DD/YYYY"
                endcase
            endif
    endcase
 
    ;Return format
    return (_format_str)
end ;subroutine (_EvaluateDateFormat(date_str = vc) = vc)
 
subroutine (_EvaluateTimeStr(time_str = vc) = i4)
    declare _dq8 = dq8 with constant(cnvtdatetime(0,time_str)),private
    declare _str = vc  with constant(format(cnvtstring(cnvttime(_dq8)),"####;p0"))
    return (cnvttime2(_dq8,"HHMM"))
end ;subroutine _EvaluateTimeStr
 
 

