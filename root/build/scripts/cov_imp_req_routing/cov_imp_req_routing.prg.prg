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
 
     Source File Name:       bed_imp_req_routing.prg
 
     Product:                Bedrock
     Product Team:           Bedrock
     HNA Version:            500
     CCL Version:            8.0
 
     Program Purpose:
 
 
     Tables Read:            dcp_output_route, dcp_flex_printer,
                             dcp_flex_rtg
 
     Tables Updated:         dcp_output_route, dcp_flex_printer,
                             dcp_flex_rtg
 
     Special Notes:
 
***************************************************************************
*                      GENERATED MODIFICATION CONTROL LOG                 *
***************************************************************************
*                                                                         *
* Feature   Date      Engineer       Comment                              *
* ------- ----------  -------------- ------------------------------------ *
*  119516 12/04/2006  Marcus Wirsig  Initial Release                      *
**************************************************************************/
drop program cov_imp_req_routing:dba go
create program cov_imp_req_routing:dba
 
 
;Error checking / logging subroutines
%i cust_script:bed_error_subroutines.inc
 
 
/*
record requestin
(
  1 list_0[*]
    2 route_type = vc
    2 route_name = vc
    2 facility = vc
    2 patient_type = vc
    2 sub_activity_type = vc
    2 patient_location = vc
    2 printer_name = vc
    2 num_of_copies = vc
)
 
*/
 
 
; items being written to tables
if (validate(build->output_routes) = 0)
  free record build
  record build
  (
    1 output_route_cnt = i4
    1 output_routes[*]
      2 route_id = f8
      2 route_desc = vc
      2 route_type = vc
      2 route_type_flag = i2
      2 action_flag = i2
      2 error_msg = vc
      2 status_flag = i2
      2 param_cnt = i4
      2 param1_cd = f8
      2 param1_disp = vc
      2 param2_cd = f8
      2 param2_disp = vc
      2 param3_cd = f8
      2 param3_disp = vc
      2 flex_rtg_cnt = i4
      2 flex_rtgs[*]
        3 rtg_id = f8
        3 action_flag = i2
        3 error_msg = vc
        3 status_flag = i2
        3 value1_cd = f8
        3 value1_disp = vc
        3 value1_disp_orig = vc
        3 value2_cd = f8
        3 value2_disp = vc
        3 value2_disp_orig = vc
        3 value3_cd = f8
        3 value3_disp = vc
        3 value3_disp_orig = vc
        3 flex_printer_id = f8
        3 printer_name = vc
        3 num_of_copies = i4
  )
endif
 
 
;Flattened, unique list of parameters and values
free record id_values
record id_values
(
;parameters
  1 facility_cnt = i4
  1 facility[*]
    2 facility_disp = vc
    2 facility_cd = f8
  1 pattype_cnt = i4
  1 pattype[*]
    2 pattype_disp = vc
    2 pattype_cd = f8
  1 subtype_cnt = i4
  1 subtype[*]
    2 subtype_disp = vc
    2 subtype_cd = f8
  1 patloc_cnt = i4
  1 patloc[*]
    2 patloc_disp = vc
    2 patloc_cd = f8
 
;parameter values
  1 v_facility_cnt = i4
  1 v_facility[*]
    2 v_facility_disp = vc
    2 v_facility_cd = f8
  1 v_pattype_cnt = i4
  1 v_pattype[*]
    2 v_pattype_disp = vc
    2 v_pattype_cd = f8
  1 v_subtype_cnt = i4
  1 v_subtype[*]
    2 v_subtype_disp = vc
    2 v_subtype_cd = f8
  1 v_patloc_cnt = i4
  1 v_patloc[*]
    2 v_patloc_disp = vc
    2 v_patloc_cd = f8
)
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
;Subroutines
declare FailRow(a_idx = i4, l_idx = i4, error_msg = vc) = null
declare GenErrorMsg(error_msg1 = vc, error_msg2 = vc) = vc
declare CheckStatus(check_action = i2) = null
 
 
;Marks the given output_route or flex_rtg item as a failure and logs the error message.
subroutine FailRow(a_idx, l_idx, error_msg)
    declare l_cnt = i4 with private, noconstant(0)
 
    if (a_idx > 0)
        set build->output_routes[a_idx].action_flag = FAIL_ACTION
 
        if (l_idx <= 0)
            set build->output_routes[a_idx].error_msg = GenErrorMsg(build->output_routes[a_idx].error_msg, error_msg)
 
            ;Mark all children as failed, but do not set the error message (only applies to parent)
            for (l_cnt = 1 to build->output_routes[a_idx].flex_rtg_cnt)
                set build->output_routes[a_idx].flex_rtgs[l_cnt].action_flag = FAIL_ACTION
            endfor
        else
            set build->output_routes[a_idx].flex_rtgs[l_idx].action_flag = FAIL_ACTION
 
            set build->output_routes[a_idx].flex_rtgs[l_idx].error_msg =
                GenErrorMsg(build->output_routes[a_idx].flex_rtgs[l_idx].error_msg, error_msg)
        endif
    endif
end
 
 
;Builds multiple error messages into one depending on what is passed in.
subroutine GenErrorMsg(error_msg1, error_msg2)
    declare cat_error_msg = vc with private, noconstant("")
 
    if (textlen(trim(error_msg2, 3)) > 0)
        if (textlen(trim(error_msg1, 3)) > 0)
            set cat_error_msg = concat(error_msg1, " | ", error_msg2)
        else
            set cat_error_msg = error_msg2
        endif
    endif
 
    return (cat_error_msg)
end
 
 
 
;Checks the status of each item after an insert or update
subroutine CheckStatus(check_action)
    declare a_idx = i4 with private, noconstant(0)
    declare l_idx = i4 with private, noconstant(0)
    declare l_cnt = i4 with private, noconstant(0)
 
    if (check_action in (INSERT_ACTION, UPDATE_ACTION))
        ;Check the status of each item that was inserted / updated.
        for (a_idx = 1 to build->output_route_cnt)
            ;If the item was already marked as a fail, then it wasn't inserted / updated.
            if (build->output_routes[a_idx].action_flag != FAIL_ACTION)
                set l_idx = 0
                set l_idx = locateval(l_cnt, l_idx + 1, build->output_routes[a_idx].flex_rtg_cnt,
                                      0, build->output_routes[a_idx].flex_rtgs[l_cnt].status_flag,
                                      check_action, build->output_routes[a_idx].flex_rtgs[l_cnt].action_flag)
                while (l_idx > 0)
                    call FailRow(a_idx, l_idx, concat("Failed ",
                                 evaluate(build->output_routes[a_idx].flex_rtgs[l_idx].action_flag,
                                 INSERT_ACTION, "inserting", UPDATE_ACTION, "updating"), " relationship in the database."))
 
                    set l_idx = locateval(l_cnt, l_idx + 1, build->output_routes[a_idx].flex_rtg_cnt,
                                          0, build->output_routes[a_idx].flex_rtgs[l_cnt].status_flag,
                                          check_action, build->output_routes[a_idx].flex_rtgs[l_cnt].action_flag)
                endwhile
            endif
        endfor
    endif
end
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
;Constants
declare INPUT_CNT     = i4 with protect, constant(size(requestin->list_0, 5))
declare DUMMYT_WHERE  = vc with protect, constant("initarray(exp_start, evaluate(d.seq, 1, 1, exp_start + EXP_SIZE))")
declare EXP_BASE      = vc with protect, constant("expand(exp_idx, exp_start, exp_start + (EXP_SIZE - 1),")
declare EXP_SIZE      = i4 with protect, constant(25) ;The size of each expand loop
declare FAIL_ACTION   = i2 with protect, constant(-1)
declare INSERT_ACTION = i2 with protect, constant(1)
declare UPDATE_ACTION = i2 with protect, constant(2)
declare BEGIN_DATE    = q8 with protect, constant(cnvtdatetime(curdate, curtime3))
declare LOG_FILE      = vc with protect, constant("ccluserdir:bed_req_routing.log")
 
 
;Variables
declare insert_flag  = i2 with protect, noconstant(0)
declare exp_idx      = i4 with protect, noconstant(0)  ;Index used for expand's & loop counters
declare exp_start    = i4 with protect, noconstant(1)  ;Where to start the expand
declare par_idx      = i4 with protect, noconstant(0)  ;Index to the parameter/value list structure
declare loop_cnt     = i4 with protect, noconstant(0)  ;Generic loop counter
declare new_nbr      = f8 with noconstant(0.0) ;used to hold sequence ids
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
;Check the insert flag to know whether this is audit or insert mode
if (validate(tempreq) > 0)
    if (cnvtupper(trim(tempreq->insert_ind, 3)) = "Y")
        set insert_flag = 1
    endif
endif
 
 
;Read in the data from the requestin structure and load it in the local structures
select into "nl:"
    route_type_disp = cnvtupper(cnvtalphanum(substring(1, 100, requestin->list_0[d.seq].route_type))),
    route_name_disp = trim(substring(1, 100, requestin->list_0[d.seq].route_name),3),
    facility_disp = cnvtupper(cnvtalphanum(substring(1, 100, requestin->list_0[d.seq].facility))),
    patient_type_disp = cnvtupper(cnvtalphanum(substring(1, 100, requestin->list_0[d.seq].patient_type))),
    sub_activity_type_disp = cnvtupper(cnvtalphanum(substring(1, 100, requestin->list_0[d.seq].sub_activity_type))),
    patient_location_disp = cnvtupper(cnvtalphanum(substring(1, 100, requestin->list_0[d.seq].patient_location))),
    printer_name_disp  = cnvtupper(cnvtalphanum(substring(1, 100, requestin->list_0[d.seq].printer_name))),
    num_of_copies  = cnvtint(requestin->list_0[d.seq].num_of_copies)
from (dummyt d with seq = value(INPUT_CNT))
order route_name_disp
head route_name_disp
    build->output_route_cnt = build->output_route_cnt + 1
    if (mod(build->output_route_cnt, EXP_SIZE) = 1)
        stat = alterlist(build->output_routes, build->output_route_cnt + EXP_SIZE - 1)
    endif
 
    build->output_routes[build->output_route_cnt].route_desc = route_name_disp
    build->output_routes[build->output_route_cnt].route_type = route_type_disp
 
   ;Based on the routing type, set param_cnt
    if (route_type_disp = "RAD")
        build->output_routes[build->output_route_cnt].param_cnt = 3
    else
        build->output_routes[build->output_route_cnt].param_cnt = 1
    endif
 
detail
    build->output_routes[build->output_route_cnt].flex_rtg_cnt =
        build->output_routes[build->output_route_cnt].flex_rtg_cnt + 1
 
    if (mod(build->output_routes[build->output_route_cnt].flex_rtg_cnt, 10) = 1)
        stat = alterlist(build->output_routes[build->output_route_cnt].flex_rtgs,
                         build->output_routes[build->output_route_cnt].flex_rtg_cnt + 9)
    endif
 
    ;grab and store the printer name and number of copies
    build->output_routes[build->output_route_cnt].flex_rtgs[build->output_routes[build->output_route_cnt].flex_rtg_cnt]
            .printer_name = printer_name_disp
    build->output_routes[build->output_route_cnt].flex_rtgs[build->output_routes[build->output_route_cnt].flex_rtg_cnt]
            .num_of_copies = num_of_copies
 
 
    if (route_type_disp = "RAD")
 
        build->output_routes[build->output_route_cnt].param1_disp = "PATIENTFACILITY"
        build->output_routes[build->output_route_cnt].param2_disp = "PATIENTTYPE"
        build->output_routes[build->output_route_cnt].param3_disp = "ACTIVITYSUBTYPE"
 
 
        build->output_routes[build->output_route_cnt].flex_rtgs[build->output_routes[build->output_route_cnt].flex_rtg_cnt]
            .value1_disp = facility_disp
        build->output_routes[build->output_route_cnt].flex_rtgs[build->output_routes[build->output_route_cnt].flex_rtg_cnt]
            .value2_disp = patient_type_disp
        build->output_routes[build->output_route_cnt].flex_rtgs[build->output_routes[build->output_route_cnt].flex_rtg_cnt]
            .value3_disp = sub_activity_type_disp
 
        build->output_routes[build->output_route_cnt].flex_rtgs[build->output_routes[build->output_route_cnt].flex_rtg_cnt]
            .value1_disp_orig = requestin->list_0[d.seq].facility
        build->output_routes[build->output_route_cnt].flex_rtgs[build->output_routes[build->output_route_cnt].flex_rtg_cnt]
            .value2_disp_orig = requestin->list_0[d.seq].patient_type
        build->output_routes[build->output_route_cnt].flex_rtgs[build->output_routes[build->output_route_cnt].flex_rtg_cnt]
            .value3_disp_orig = requestin->list_0[d.seq].sub_activity_type
 
 
        ;add the Radiology parameters to the unique list if they're not already there
        ;facility disp
        par_idx = 0
        if (id_values->facility_cnt > 0)
            par_idx = locateval(par_idx, 1, id_values->facility_cnt, "PATIENTFACILITY", id_values->facility[par_idx].facility_disp)
        endif
 
        if (par_idx = 0)
            id_values->facility_cnt = id_values->facility_cnt + 1
            if (mod(id_values->facility_cnt, EXP_SIZE) = 1)
                stat = alterlist(id_values->facility, id_values->facility_cnt + EXP_SIZE - 1)
            endif
            id_values->facility[id_values->facility_cnt].facility_disp = "PATIENTFACILITY"
        endif
 
        ;pattype disp
        par_idx = 0
        if (id_values->pattype_cnt > 0)
            par_idx = locateval(par_idx, 1, id_values->pattype_cnt, "PATIENTTYPE", id_values->pattype[par_idx].pattype_disp)
        endif
        if (par_idx = 0)
            id_values->pattype_cnt = id_values->pattype_cnt + 1
            if (mod(id_values->pattype_cnt, EXP_SIZE) = 1)
                stat = alterlist(id_values->pattype, id_values->pattype_cnt + EXP_SIZE - 1)
            endif
            id_values->pattype[id_values->pattype_cnt].pattype_disp = "PATIENTTYPE"
        endif
 
        ;subtype disp
        par_idx = 0
        if (id_values->subtype_cnt > 0)
            par_idx = locateval(par_idx, 1, id_values->subtype_cnt, "ACTIVITYSUBTYPE",
                      id_values->subtype[par_idx].subtype_disp)
        endif
        if (par_idx = 0)
            id_values->subtype_cnt = id_values->subtype_cnt + 1
            if (mod(id_values->subtype_cnt, EXP_SIZE) = 1)
                stat = alterlist(id_values->subtype, id_values->subtype_cnt + EXP_SIZE - 1)
            endif
            id_values->subtype[id_values->subtype_cnt].subtype_disp = "ACTIVITYSUBTYPE"
        endif
 
 
        ;v_facility disp
        par_idx = 0
        if (id_values->v_facility_cnt > 0)
            par_idx = locateval(par_idx, 1, id_values->v_facility_cnt, facility_disp,
                      id_values->v_facility[par_idx].v_facility_disp)
        endif
        if (par_idx = 0)
            id_values->v_facility_cnt = id_values->v_facility_cnt + 1
            if (mod(id_values->v_facility_cnt, EXP_SIZE) = 1)
                stat = alterlist(id_values->v_facility, id_values->v_facility_cnt + EXP_SIZE - 1)
            endif
            id_values->v_facility[id_values->v_facility_cnt].v_facility_disp = facility_disp
        endif
 
        ;v_pattype disp
        par_idx = 0
        if (id_values->v_pattype_cnt > 0)
            par_idx = locateval(par_idx, 1, id_values->v_pattype_cnt, patient_type_disp,
                      id_values->v_pattype[par_idx].v_pattype_disp)
        endif
        if (par_idx = 0)
            id_values->v_pattype_cnt = id_values->v_pattype_cnt + 1
            if (mod(id_values->v_pattype_cnt, EXP_SIZE) = 1)
                stat = alterlist(id_values->v_pattype, id_values->v_pattype_cnt + EXP_SIZE - 1)
            endif
            id_values->v_pattype[id_values->v_pattype_cnt].v_pattype_disp = patient_type_disp
        endif
 
        ;v_subtype disp
        par_idx = 0
        if (id_values->v_subtype_cnt > 0)
            par_idx = locateval(par_idx, 1, id_values->v_subtype_cnt, sub_activity_type_disp,
                      id_values->v_subtype[par_idx].v_subtype_disp)
        endif
        if (par_idx = 0)
            id_values->v_subtype_cnt = id_values->v_subtype_cnt + 1
            if (mod(id_values->v_subtype_cnt, EXP_SIZE) = 1)
                stat = alterlist(id_values->v_subtype, id_values->v_subtype_cnt + EXP_SIZE - 1)
            endif
            id_values->v_subtype[id_values->v_subtype_cnt].v_subtype_disp = sub_activity_type_disp
        endif
 
    elseif(route_type_disp = "TRANSPORT")
 
        build->output_routes[build->output_route_cnt].param1_disp = "PATIENTFACILITY"
 
        build->output_routes[build->output_route_cnt].flex_rtgs[build->output_routes[build->output_route_cnt].flex_rtg_cnt]
            .value1_disp = facility_disp
 
        build->output_routes[build->output_route_cnt].flex_rtgs[build->output_routes[build->output_route_cnt].flex_rtg_cnt]
            .value1_disp_orig = requestin->list_0[d.seq].facility
 
        ;add the Transport parameter to the unique list if it's not already there
        ;facility disp
        par_idx = 0
        if (id_values->facility_cnt > 0)
            par_idx = locateval(par_idx, 1, id_values->facility_cnt, "PATIENTFACILITY",
                      id_values->facility[par_idx].facility_disp)
        endif
        if (par_idx = 0)
            id_values->facility_cnt = id_values->facility_cnt + 1
            if (mod(id_values->facility_cnt, EXP_SIZE) = 1)
                stat = alterlist(id_values->facility, id_values->facility_cnt + EXP_SIZE - 1)
            endif
            id_values->facility[id_values->facility_cnt].facility_disp = "PATIENTFACILITY"
        endif
 
        ;v_facility disp
        par_idx = 0
        if (id_values->v_facility_cnt > 0)
            par_idx = locateval(par_idx, 1, id_values->v_facility_cnt, facility_disp,
                      id_values->v_facility[par_idx].v_facility_disp)
        endif
        if (par_idx = 0)
            id_values->v_facility_cnt = id_values->v_facility_cnt + 1
            if (mod(id_values->v_facility_cnt, EXP_SIZE) = 1)
                stat = alterlist(id_values->v_facility, id_values->v_facility_cnt + EXP_SIZE - 1)
            endif
            id_values->v_facility[id_values->v_facility_cnt].v_facility_disp = facility_disp
        endif
 
    else
 
        build->output_routes[build->output_route_cnt].param1_disp = "PATIENTLOCATION"
 
        build->output_routes[build->output_route_cnt].flex_rtgs[build->output_routes[build->output_route_cnt].flex_rtg_cnt]
            .value1_disp = patient_location_disp
 
        build->output_routes[build->output_route_cnt].flex_rtgs[build->output_routes[build->output_route_cnt].flex_rtg_cnt]
            .value1_disp_orig = requestin->list_0[d.seq].patient_location
 
        ;add the Laboratory parameter to the unique list if it's not already there
        ;patloc disp
        par_idx = 0
        if (id_values->patloc_cnt > 0)
            par_idx = locateval(par_idx, 1, id_values->patloc_cnt, "PATIENTLOCATION",
                      id_values->patloc[par_idx].patloc_disp)
        endif
        if (par_idx = 0)
            id_values->patloc_cnt = id_values->patloc_cnt + 1
            if (mod(id_values->patloc_cnt, EXP_SIZE) = 1)
                stat = alterlist(id_values->patloc, id_values->patloc_cnt + EXP_SIZE - 1)
            endif
            id_values->patloc[id_values->patloc_cnt].patloc_disp = "PATIENTLOCATION"
        endif
 
        ;v_patloc disp
        par_idx = 0
        if (id_values->v_patloc_cnt > 0)
            par_idx = locateval(par_idx, 1, id_values->v_patloc_cnt, patient_location_disp,
                      id_values->v_patloc[par_idx].v_patloc_disp)
        endif
        if (par_idx = 0)
            id_values->v_patloc_cnt = id_values->v_patloc_cnt + 1
            if (mod(id_values->v_patloc_cnt, EXP_SIZE) = 1)
                stat = alterlist(id_values->v_patloc, id_values->v_patloc_cnt + EXP_SIZE - 1)
            endif
            id_values->v_patloc[id_values->v_patloc_cnt].v_patloc_disp = patient_location_disp
        endif
    endif ;    if (route_type_disp = "RAD")
 
foot route_name_disp
    stat = alterlist(build->output_routes[build->output_route_cnt].flex_rtgs,
           build->output_routes[build->output_route_cnt].flex_rtg_cnt)
 
foot report
 
    ;Pad the lists to use the expand function
    for (loop_cnt = build->output_route_cnt + 1 to size(build->output_routes, 5))
        build->output_routes[loop_cnt].param1_disp = build->output_routes[build->output_route_cnt].param1_disp
        build->output_routes[loop_cnt].param2_disp = build->output_routes[build->output_route_cnt].param2_disp
        build->output_routes[loop_cnt].param3_disp = build->output_routes[build->output_route_cnt].param3_disp
    endfor
 
    for (loop_cnt = id_values->facility_cnt + 1 to size(id_values->facility, 5))
        id_values->facility[loop_cnt].facility_disp = id_values->facility[id_values->facility_cnt].facility_disp
    endfor
 
    for (loop_cnt = id_values->pattype_cnt + 1 to size(id_values->pattype, 5))
        id_values->pattype[loop_cnt].pattype_disp = id_values->pattype[id_values->pattype_cnt].pattype_disp
    endfor
 
    for (loop_cnt = id_values->subtype_cnt + 1 to size(id_values->subtype, 5))
        id_values->subtype[loop_cnt].subtype_disp = id_values->subtype[id_values->subtype_cnt].subtype_disp
    endfor
 
    for (loop_cnt = id_values->patloc_cnt + 1 to size(id_values->patloc, 5))
        id_values->patloc[loop_cnt].patloc_disp = id_values->patloc[id_values->patloc_cnt].patloc_disp
    endfor
 
    for (loop_cnt = id_values->v_facility_cnt + 1 to size(id_values->v_facility, 5))
        id_values->v_facility[loop_cnt].v_facility_disp = id_values->v_facility[id_values->v_facility_cnt].v_facility_disp
    endfor
 
    for (loop_cnt = id_values->v_pattype_cnt + 1 to size(id_values->v_pattype, 5))
        id_values->v_pattype[loop_cnt].v_pattype_disp = id_values->v_pattype[id_values->v_pattype_cnt].v_pattype_disp
    endfor
 
    for (loop_cnt = id_values->v_subtype_cnt + 1 to size(id_values->v_subtype, 5))
        id_values->v_subtype[loop_cnt].v_subtype_disp = id_values->v_subtype[id_values->v_subtype_cnt].v_subtype_disp
    endfor
 
    for (loop_cnt = id_values->v_patloc_cnt + 1 to size(id_values->v_patloc, 5))
        id_values->v_patloc[loop_cnt].v_patloc_disp = id_values->v_patloc[id_values->v_patloc_cnt].v_patloc_disp
    endfor
 
with nocounter
 
;Check for errors in the query
if (CheckError(FAILURE, "SELECT", FAILURE, "DATA LOAD") > 0)
    go to EXIT_SCRIPT
endif
 
;Query to get all the facility_cd's
if (id_values->facility_cnt > 0)
    set exp_start = 1
    select into "nl:"
    from (dummyt d with seq = value(1 + ((size(id_values->facility, 5) - 1) / EXP_SIZE))),
         code_value c
    plan d where parser(DUMMYT_WHERE)
    join c where parser(concat(EXP_BASE, "c.display_key, id_values->facility[exp_idx].facility_disp)"))
             and c.code_set = 6007
             and c.active_ind = 1
             and c.begin_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
             and c.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3)
    detail
        par_idx = locateval(par_idx, 1, id_values->facility_cnt, c.display_key, id_values->facility[par_idx].facility_disp)
        if (par_idx > 0)
            id_values->facility[par_idx].facility_cd = c.code_value
        endif
 
    foot report
        stat = alterlist(id_values->facility, id_values->facility_cnt)
    with nocounter
endif
 
;Check for errors in the query
if (CheckError(FAILURE, "SELECT", FAILURE, "FACILITY_CD LOOKUP") > 0)
    go to EXIT_SCRIPT
endif
 
;Query to get all the pattype_cd's
if (id_values->pattype_cnt > 0)
    set exp_start = 1
    select into "nl:"
    from (dummyt d with seq = value(1 + ((size(id_values->pattype, 5) - 1) / EXP_SIZE))),
         code_value c
    plan d where parser(DUMMYT_WHERE)
    join c where parser(concat(EXP_BASE, "c.display_key, id_values->pattype[exp_idx].pattype_disp)"))
             and c.code_set = 6007
             and c.active_ind = 1
             and c.begin_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
             and c.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3)
    detail
        par_idx = locateval(par_idx, 1, id_values->pattype_cnt, c.display_key, id_values->pattype[par_idx].pattype_disp)
        if (par_idx > 0)
            id_values->pattype[par_idx].pattype_cd = c.code_value
        endif
 
    foot report
        stat = alterlist(id_values->pattype, id_values->pattype_cnt)
    with nocounter
endif
 
;Check for errors in the query
if (CheckError(FAILURE, "SELECT", FAILURE, "PATTYPE_CD LOOKUP") > 0)
    go to EXIT_SCRIPT
endif
 
;Query to get all the subtype_cd's
if (id_values->subtype_cnt > 0)
    set exp_start = 1
    select into "nl:"
    from (dummyt d with seq = value(1 + ((size(id_values->subtype, 5) - 1) / EXP_SIZE))),
         code_value c
    plan d where parser(DUMMYT_WHERE)
    join c where parser(concat(EXP_BASE, "c.display_key, id_values->subtype[exp_idx].subtype_disp)"))
             and c.code_set = 6007
             and c.active_ind = 1
             and c.begin_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
             and c.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3)
    detail
        par_idx = locateval(par_idx, 1, id_values->subtype_cnt, c.display_key, id_values->subtype[par_idx].subtype_disp)
        if (par_idx > 0)
            id_values->subtype[par_idx].subtype_cd = c.code_value
        endif
 
    foot report
        stat = alterlist(id_values->subtype, id_values->subtype_cnt)
    with nocounter
endif
 
;Check for errors in the query
if (CheckError(FAILURE, "SELECT", FAILURE, "SUBTYPE_CD LOOKUP") > 0)
    go to EXIT_SCRIPT
endif
 
;Query to get all the patloc_cd's
if (id_values->patloc_cnt > 0)
    set exp_start = 1
    select into "nl:"
    from (dummyt d with seq = value(1 + ((size(id_values->patloc, 5) - 1) / EXP_SIZE))),
         code_value c
    plan d where parser(DUMMYT_WHERE)
    join c where parser(concat(EXP_BASE, "c.display_key, id_values->patloc[exp_idx].patloc_disp)"))
             and c.code_set = 6007
             and c.active_ind = 1
             and c.begin_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
             and c.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3)
    detail
        par_idx = locateval(par_idx, 1, id_values->patloc_cnt, c.display_key, id_values->patloc[par_idx].patloc_disp)
        if (par_idx > 0)
            id_values->patloc[par_idx].patloc_cd = c.code_value
        endif
 
    foot report
        stat = alterlist(id_values->patloc, id_values->patloc_cnt)
    with nocounter
endif
 
;Check for errors in the query
if (CheckError(FAILURE, "SELECT", FAILURE, "PATLOC_CD LOOKUP") > 0)
    go to EXIT_SCRIPT
endif
 
;Query to get all the v_facility_cd's
if (id_values->v_facility_cnt > 0)
    set exp_start = 1
    select into "nl:"
    from (dummyt d with seq = value(1 + ((size(id_values->v_facility, 5) - 1) / EXP_SIZE))),
         code_value c
    plan d where parser(DUMMYT_WHERE)
    join c where parser(concat(EXP_BASE, "c.display_key, id_values->v_facility[exp_idx].v_facility_disp)"))
             and c.code_set = 220
             and c.cdf_meaning = "FACILITY"
             and c.active_ind = 1
             and c.begin_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
             and c.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3)
    detail
        par_idx = locateval(par_idx, 1, id_values->v_facility_cnt, c.display_key, id_values->v_facility[par_idx].v_facility_disp)
        if (par_idx > 0)
            id_values->v_facility[par_idx].v_facility_cd = c.code_value
        endif
 
    foot report
        stat = alterlist(id_values->v_facility, id_values->v_facility_cnt)
    with nocounter
endif
 
;Check for errors in the query
if (CheckError(FAILURE, "SELECT", FAILURE, "V_FACILITY_CD LOOKUP") > 0)
    go to EXIT_SCRIPT
endif
 
;Query to get all the v_pattype_cd's
if (id_values->v_pattype_cnt > 0)
    set exp_start = 1
    select into "nl:"
    from (dummyt d with seq = value(1 + ((size(id_values->v_pattype, 5) - 1) / EXP_SIZE))),
         code_value c
    plan d where parser(DUMMYT_WHERE)
    join c where parser(concat(EXP_BASE, "c.display_key, id_values->v_pattype[exp_idx].v_pattype_disp)"))
             and c.code_set = 71
             and c.active_ind = 1
             and c.begin_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
             and c.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3)
    detail
        par_idx = locateval(par_idx, 1, id_values->v_pattype_cnt, c.display_key, id_values->v_pattype[par_idx].v_pattype_disp)
        if (par_idx > 0)
            id_values->v_pattype[par_idx].v_pattype_cd = c.code_value
        endif
 
    foot report
        stat = alterlist(id_values->v_pattype, id_values->v_pattype_cnt)
    with nocounter
endif
 
;Check for errors in the query
if (CheckError(FAILURE, "SELECT", FAILURE, "V_PATTYPE_CD LOOKUP") > 0)
    go to EXIT_SCRIPT
endif
 
;Query to get all the v_subtype_cd's
if (id_values->v_subtype_cnt > 0)
    set exp_start = 1
    select into "nl:"
    from (dummyt d with seq = value(1 + ((size(id_values->v_subtype, 5) - 1) / EXP_SIZE))),
         code_value c
    plan d where parser(DUMMYT_WHERE)
    join c where parser(concat(EXP_BASE, "c.display_key, id_values->v_subtype[exp_idx].v_subtype_disp)"))
             and c.code_set = 5801
             and c.active_ind = 1
             and c.begin_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
             and c.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3)
    detail
        par_idx = locateval(par_idx, 1, id_values->v_subtype_cnt, c.display_key, id_values->v_subtype[par_idx].v_subtype_disp)
        if (par_idx > 0)
            id_values->v_subtype[par_idx].v_subtype_cd = c.code_value
        endif
 
    foot report
        stat = alterlist(id_values->v_subtype, id_values->v_subtype_cnt)
    with nocounter
endif
 
;Check for errors in the query
if (CheckError(FAILURE, "SELECT", FAILURE, "V_SUBTYPE_CD LOOKUP") > 0)
    go to EXIT_SCRIPT
endif
 
;Query to get all the v_patloc_cd's
if (id_values->v_patloc_cnt > 0)
    set exp_start = 1
    select into "nl:"
    from (dummyt d with seq = value(1 + ((size(id_values->v_patloc, 5) - 1) / EXP_SIZE))),
         code_value c
    plan d where parser(DUMMYT_WHERE)
    join c where parser(concat(EXP_BASE, "c.display_key, id_values->v_patloc[exp_idx].v_patloc_disp)"))
             and c.code_set = 220
             and c.active_ind = 1
             and c.begin_effective_dt_tm <= cnvtdatetime(curdate, curtime3)
             and c.end_effective_dt_tm >= cnvtdatetime(curdate, curtime3)
    detail
        par_idx = locateval(par_idx, 1, id_values->v_patloc_cnt, c.display_key, id_values->v_patloc[par_idx].v_patloc_disp)
        if (par_idx > 0)
            id_values->v_patloc[par_idx].v_patloc_cd = c.code_value
        endif
 
    foot report
        stat = alterlist(id_values->v_patloc, id_values->v_patloc_cnt)
    with nocounter
endif
 
;Check for errors in the query
if (CheckError(FAILURE, "SELECT", FAILURE, "V_PATLOC_CD LOOKUP") > 0)
    go to EXIT_SCRIPT
endif
 
;Data Validation
for (out_idx = 1 to build->output_route_cnt)
 
    if (build->output_routes[out_idx].route_type = "RAD")
 
        ;Load the param1_cd into the nested structure
        set loop_cnt = locateval(loop_cnt, 1, id_values->facility_cnt,
                                 build->output_routes[out_idx].param1_disp,
                                 id_values->facility[loop_cnt].facility_disp)
 
        ;If a param1_cd was found, populate the build structure, otherwise mark as a failure
        if (loop_cnt > 0)
            set build->output_routes[out_idx].param1_cd = id_values->facility[loop_cnt].facility_cd
        endif
 
 
        if (loop_cnt <= 0 or build->output_routes[out_idx].param1_cd <= 0)
            call FailRow(out_idx, 0, "Invalid facility display value for codeset 6007.")
        endif
 
        ;Load the param2_cd into the nested structure
        set loop_cnt = locateval(loop_cnt, 1, id_values->pattype_cnt,
                                 build->output_routes[out_idx].param2_disp,
                                 id_values->pattype[loop_cnt].pattype_disp)
 
        ;If a param2_cd was found, populate the build structure, otherwise mark as a failure
        if (loop_cnt > 0)
            set build->output_routes[out_idx].param2_cd = id_values->pattype[loop_cnt].pattype_cd
        endif
 
        if (loop_cnt <= 0 or build->output_routes[out_idx].param2_cd <= 0)
            call FailRow(out_idx, 0, "Invalid patient type display value for codeset 6007.")
        endif
 
        ;Load the param3_cd into the nested structure
        set loop_cnt = locateval(loop_cnt, 1, id_values->subtype_cnt,
                                 build->output_routes[out_idx].param3_disp,
                                 id_values->subtype[loop_cnt].subtype_disp)
 
        ;If a param3_cd was found, populate the build structure, otherwise mark as a failure
        if (loop_cnt > 0)
            set build->output_routes[out_idx].param3_cd = id_values->subtype[loop_cnt].subtype_cd
        endif
 
        if (loop_cnt <= 0 or build->output_routes[out_idx].param3_cd <= 0)
            call FailRow(out_idx, 0, "Invalid activity sub type display value for codeset 6007.")
        endif
 
    elseif (build->output_routes[out_idx].route_type = "TRANSPORT")
 
        ;Load the param1_cd into the nested structure
        set loop_cnt = locateval(loop_cnt, 1, id_values->facility_cnt,
                                 build->output_routes[out_idx].param1_disp,
                                 id_values->facility[loop_cnt].facility_disp)
 
        ;If a param1_cd was found, populate the build structure, otherwise mark as a failure
        if (loop_cnt > 0)
            set build->output_routes[out_idx].param1_cd = id_values->facility[loop_cnt].facility_cd
        endif
 
        if (loop_cnt <= 0 or build->output_routes[out_idx].param1_cd <= 0)
            call FailRow(out_idx, 0, "Invalid facility display value for codeset 6007.")
        endif
 
    else
 
        ;Load the param1_cd into the nested structure
        set loop_cnt = locateval(loop_cnt, 1, id_values->patloc_cnt,
                                 build->output_routes[out_idx].param1_disp,
                                 id_values->patloc[loop_cnt].patloc_disp)
 
        ;If a param1_cd was found, populate the build structure, otherwise mark as a failure
        if (loop_cnt > 0)
            set build->output_routes[out_idx].param1_cd = id_values->patloc[loop_cnt].patloc_cd
        endif
 
        if (loop_cnt <= 0 or build->output_routes[out_idx].param1_cd <= 0)
            call FailRow(out_idx, 0, "Invalid Patient Location display value for codeset 6007.")
        endif
 
    endif ;(build->output_routes[out_idx].route_type = "RAD")
 
 
 
    for (loc_idx = 1 to build->output_routes[out_idx].flex_rtg_cnt)
 
        if (build->output_routes[out_idx].route_type = "RAD")
            ;Load the value1_cd into the nested structure
            set loop_cnt = locateval(loop_cnt, 1, id_values->v_facility_cnt,
                                     build->output_routes[out_idx].flex_rtgs[loc_idx].value1_disp,
                                     id_values->v_facility[loop_cnt].v_facility_disp)
 
            ;If a value1_cd was found, populate the build structure, otherwise mark as a failure
            if (loop_cnt > 0)
                set build->output_routes[out_idx].flex_rtgs[loc_idx].value1_cd = id_values->v_facility[loop_cnt].v_facility_cd
            endif
 
            if (loop_cnt <= 0 or build->output_routes[out_idx].flex_rtgs[loc_idx].value1_cd <= 0)
                call FailRow(out_idx, loc_idx, "Invalid facility display value for codeset 220.")
            endif
 
 
            ;Load the value2_cd into the nested structure
            set loop_cnt = locateval(loop_cnt, 1, id_values->v_pattype_cnt,
                                     build->output_routes[out_idx].flex_rtgs[loc_idx].value2_disp,
                                     id_values->v_pattype[loop_cnt].v_pattype_disp)
 
            ;If a value2_cd was found, populate the build structure, otherwise mark as a failure
            if (loop_cnt > 0)
                set build->output_routes[out_idx].flex_rtgs[loc_idx].value2_cd = id_values->v_pattype[loop_cnt].v_pattype_cd
            endif
 
            if (loop_cnt <= 0 or build->output_routes[out_idx].flex_rtgs[loc_idx].value2_cd <= 0)
                call FailRow(out_idx, loc_idx, "Invalid patient type display value for codeset 71.")
            endif
 
 
            ;Load the value3_cd into the nested structure
            set loop_cnt = locateval(loop_cnt, 1, id_values->v_subtype_cnt,
                                     build->output_routes[out_idx].flex_rtgs[loc_idx].value3_disp,
                                     id_values->v_subtype[loop_cnt].v_subtype_disp)
 
            ;If a value3_cd was found, populate the build structure, otherwise mark as a failure
            if (loop_cnt > 0)
                set build->output_routes[out_idx].flex_rtgs[loc_idx].value3_cd = id_values->v_subtype[loop_cnt].v_subtype_cd
            endif
 
            if (loop_cnt <= 0 or build->output_routes[out_idx].flex_rtgs[loc_idx].value3_cd <= 0)
                call FailRow(out_idx, loc_idx, "Invalid activity sub type display value for codeset 5801.")
            endif
 
        elseif (build->output_routes[out_idx].route_type = "TRANSPORT")
 
            ;Load the value1_cd into the nested structure
            set loop_cnt = locateval(loop_cnt, 1, id_values->v_facility_cnt,
                                     build->output_routes[out_idx].flex_rtgs[loc_idx].value1_disp,
                                     id_values->v_facility[loop_cnt].v_facility_disp)
 
            ;If a value1_cd was found, populate the build structure, otherwise mark as a failure
            if (loop_cnt > 0)
                set build->output_routes[out_idx].flex_rtgs[loc_idx].value1_cd = id_values->v_facility[loop_cnt].v_facility_cd
            endif
 
            if (loop_cnt <= 0 or build->output_routes[out_idx].flex_rtgs[loc_idx].value1_cd <= 0)
                call FailRow(out_idx, loc_idx, "Invalid facility display value for codeset 220.")
            endif
 
        else
 
            ;Load the value1_cd into the nested structure
            set loop_cnt = locateval(loop_cnt, 1, id_values->v_patloc_cnt,
                                     build->output_routes[out_idx].flex_rtgs[loc_idx].value1_disp,
                                     id_values->v_patloc[loop_cnt].v_patloc_disp)
 
            ;If a value1_cd was found, populate the build structure, otherwise mark as a failure
            if (loop_cnt > 0)
                set build->output_routes[out_idx].flex_rtgs[loc_idx].value1_cd = id_values->v_patloc[loop_cnt].v_patloc_cd
            endif
 
            if (loop_cnt <= 0 or build->output_routes[out_idx].flex_rtgs[loc_idx].value1_cd <= 0)
                call FailRow(out_idx, loc_idx, "Invalid Patient Location display value for codeset 220.")
            endif
 
        endif ;(build->output_routes[out_idx].route_type = "RAD")
 
     endfor ;(loc_idx = 1 to build->output_routes[out_idx].flex_rtg_cnt)
 
endfor ;(out_idx = 1 to build->output_route_cnt)
 
 
 
;Query to see what which output_routes are already on the table.  Mark them for to be deleted
set exp_start = 1
select into "nl:"
from (dummyt d with seq = value(1 + ((size(build->output_routes, 5) - 1) / EXP_SIZE))),
     dcp_output_route dor
plan d where parser(DUMMYT_WHERE)
join dor where parser(concat(EXP_BASE, "dor.route_description, build->output_routes[exp_idx].route_desc)"))
 
detail
    out_idx = locateval(out_idx, 1, build->output_route_cnt, dor.route_description, build->output_routes[out_idx].route_desc)
    if (out_idx > 0)
        ;If this item was not already failed, mark it as an update to write the new output_route_id
        if (build->output_routes[out_idx].action_flag != FAIL_ACTION)
            build->output_routes[out_idx].action_flag = UPDATE_ACTION
            build->output_routes[out_idx].route_id = dor.dcp_output_route_id
        endif
    endif
 
foot report
    ;Mark any other non-error output_routes that were not found in the table as inserts
    out_idx = 0
    out_idx = locateval(exp_idx, out_idx + 1, build->output_route_cnt, 0, build->output_routes[exp_idx].action_flag)
 
    while (out_idx > 0)
        build->output_routes[out_idx].action_flag = INSERT_ACTION
        out_idx = locateval(exp_idx, out_idx + 1, build->output_route_cnt, 0, build->output_routes[exp_idx].action_flag)
    endwhile
 
    stat = alterlist(build->output_routes, build->output_route_cnt)
with nocounter, nullreport, forupdate(dor)
 
 
;Check for errors in the query
if (CheckError(FAILURE, "SELECT", FAILURE, "EXISTING DATA CHECK") > 0)
    go to EXIT_SCRIPT
endif
 
 
;Skip the deletes & insert if we are in audit mode.
if (insert_flag > 0)
 
    ;Delete rows not marked as failed or an insert
    ;DCP_FLEX_PRINTER
    select into "nl:"
        dfp.dcp_output_route_id
    from (dummyt d with seq = value(build->output_route_cnt)),
         dcp_flex_printer dfp
    plan d  where build->output_routes[d.seq].action_flag = UPDATE_ACTION
    join dfp
    where build->output_routes[d.seq].route_id = dfp.dcp_output_route_id
    with nocounter, forupdate(dfp)
 
    ;Check for errors in the query
    if (CheckError(FAILURE, "SELECT", FAILURE, "DCP_FLEX_PRINTER LOCK") > 0)
        go to EXIT_SCRIPT
    endif
 
    delete from dcp_flex_printer dfp, ;where action flag is update
       (dummyt d with seq = value(build->output_route_cnt))
       set dfp.seq = 1
    plan d  where build->output_routes[d.seq].action_flag = UPDATE_ACTION
    join dfp
    where dfp.dcp_output_route_id = build->output_routes[d.seq].route_id
    with nocounter
 
    ;Check for errors in the query
    if (CheckError(FAILURE, "DELETE", FAILURE, "DCP_FLEX_PRINTER") > 0)
        go to EXIT_SCRIPT
    endif
 
    ;DCP_FLEX_RTG
    select into "nl:"
      dfr.dcp_output_route_id
    from (dummyt d with seq = value(build->output_route_cnt)),
         dcp_flex_rtg dfr
    plan d  where build->output_routes[d.seq].action_flag = UPDATE_ACTION
    join dfr
    where build->output_routes[d.seq].route_id = dfr.dcp_output_route_id
    with nocounter, forupdate(dfr)
 
    ;Check for errors in the query
    if (CheckError(FAILURE, "SELECT", FAILURE, "DCP_FLEX_RTG LOCK") > 0)
        go to EXIT_SCRIPT
    endif
 
    delete from dcp_flex_rtg dfr,
       (dummyt d with seq = value(build->output_route_cnt))
       set dfr.seq = 1
    plan d  where build->output_routes[d.seq].action_flag = UPDATE_ACTION
    join dfr
    where dfr.dcp_output_route_id = build->output_routes[d.seq].route_id
    with nocounter
 
    ;Check for errors in the query
    if (CheckError(FAILURE, "DELETE", FAILURE, "DCP_FLEX_RTG") > 0)
        go to EXIT_SCRIPT
    endif
 
    ;DCP_OUTPUT_ROUTE
    select into "nl:"
      dor.dcp_output_route_id
    from (dummyt d with seq = value(build->output_route_cnt)),
         dcp_output_route dor
    plan d  where build->output_routes[d.seq].action_flag = UPDATE_ACTION
    join dor
    where build->output_routes[d.seq].route_id = dor.dcp_output_route_id
    with nocounter, forupdate(dor)
 
    ;Check for errors in the query
    if (CheckError(FAILURE, "SELECT", FAILURE, "DCP_OUTPUT_ROUTE LOCK") > 0)
        go to EXIT_SCRIPT
    endif
 
    delete from dcp_output_route dor,
       (dummyt d with seq = value(build->output_route_cnt))
       set dor.seq = 1
    plan d  where build->output_routes[d.seq].action_flag = UPDATE_ACTION
    join dor
    where dor.dcp_output_route_id = build->output_routes[d.seq].route_id
    with nocounter
 
    ;Check for errors in the query
    if (CheckError(FAILURE, "DELETE", FAILURE, "DCP_OUTPUT_ROUTE") > 0)
        go to EXIT_SCRIPT
    endif
 
    for (out_cnt = 1 to build->output_route_cnt)
        ;set the unique ids for the insert
        select into "nl:"
            y = seq(reference_seq,nextval)
        from dual
        detail
            build->output_routes[out_cnt].route_id = cnvtreal(y)
        with nocounter
 
            ;Check for errors in the query
        if (CheckError(FAILURE, "SELECT", FAILURE, "DUAL - REFERENCE_SEQ") > 0)
            go to EXIT_SCRIPT
        endif
    endfor ;(out_cnt = 1 to build->output_route_cnt)
 
    ;Insert items marked with INSERT_ACTION
    ;DCP_OUTPUT_ROUTE
    insert into (dummyt d1 with seq = value(build->output_route_cnt)),
                dcp_output_route dor
    set dor.dcp_output_route_id = build->output_routes[d1.seq].route_id,
        dor.route_description = build->output_routes[d1.seq].route_desc,
        dor.route_type_flag = 0,
        dor.param_cnt = build->output_routes[d1.seq].param_cnt,
        dor.param1_cd = build->output_routes[d1.seq].param1_cd,
        dor.param2_cd = build->output_routes[d1.seq].param2_cd,
        dor.param3_cd = build->output_routes[d1.seq].param3_cd,
        dor.updt_dt_tm = cnvtdatetime(curdate, curtime3),
        dor.updt_applctx = reqinfo->updt_applctx,
        dor.updt_id = reqinfo->updt_id,
        dor.updt_cnt = 0,
        dor.updt_task = reqinfo->updt_task
 
    plan d1 where build->output_routes[d1.seq].action_flag != FAIL_ACTION
    join dor
    with nocounter, status(build->output_routes[d1.seq].status_flag)
 
    ;Check the status for each item
    call CheckStatus(INSERT_ACTION)
 
    ;Check for errors in the insert
    if (CheckError(FAILURE, "INSERT", FAILURE, "DCP_OUTPUT_ROUTE") > 0)
        go to EXIT_SCRIPT
    endif
 
    for (out_cnt = 1 to build->output_route_cnt)
        for (flx_cnt = 1 to build->output_routes[out_cnt].flex_rtg_cnt)
            ;set the unique ids for the insert
            select into "nl:"
                y = seq(reference_seq,nextval)
            from dual
            detail
                build->output_routes[out_cnt].flex_rtgs[flx_cnt].rtg_id = cnvtreal(y)
            with nocounter
        endfor
    endfor
 
    ;DCP_FLEX_RTG
    insert into (dummyt d1 with seq = value(build->output_route_cnt)),
                (dummyt d2 with seq = value(1)),
                dcp_flex_rtg dfr
    set dfr.dcp_flex_rtg_id = build->output_routes[d1.seq].flex_rtgs[d2.seq].rtg_id,
        dfr.dcp_output_route_id = build->output_routes[d1.seq].route_id,
        dfr.value1_cd = build->output_routes[d1.seq].flex_rtgs[d2.seq].value1_cd,
        dfr.value2_cd = build->output_routes[d1.seq].flex_rtgs[d2.seq].value2_cd,
        dfr.value3_cd = build->output_routes[d1.seq].flex_rtgs[d2.seq].value3_cd,
        dfr.updt_dt_tm = cnvtdatetime(curdate, curtime3),
        dfr.updt_applctx = reqinfo->updt_applctx,
        dfr.updt_id = reqinfo->updt_id,
        dfr.updt_cnt = 0,
        dfr.updt_task = reqinfo->updt_task
    plan d1 where build->output_routes[d1.seq].action_flag != FAIL_ACTION
              and maxrec(d2, build->output_routes[d1.seq].flex_rtg_cnt)
    join d2 where build->output_routes[d1.seq].flex_rtgs[d2.seq].action_flag != FAIL_ACTION
    join dfr
    with nocounter, status(build->output_routes[d1.seq].flex_rtgs[d2.seq].status_flag)
 
    ;Check the status for each item
    call CheckStatus(INSERT_ACTION)
 
    ;Check for errors in the insert
    if (CheckError(FAILURE, "INSERT", FAILURE, "DCP_FLEX_RTG") > 0)
        go to EXIT_SCRIPT
    endif
 
    ;DCP_FLEX_PRINTER
    insert into (dummyt d1 with seq = value(build->output_route_cnt)),
                (dummyt d2 with seq = value(1)),
                (dummyt d3 with seq = value(1)),
                dcp_flex_printer dfp
    set dfp.dcp_flex_printer_id = seq(reference_seq,nextval),
        dfp.dcp_output_route_id = build->output_routes[d1.seq].route_id,
        dfp.dcp_flex_rtg_id = build->output_routes[d1.seq].flex_rtgs[d2.seq].rtg_id,
        dfp.printer_name = build->output_routes[d1.seq].flex_rtgs[d2.seq].printer_name,
        dfp.updt_dt_tm = cnvtdatetime(curdate, curtime3),
        dfp.updt_applctx = reqinfo->updt_applctx,
        dfp.updt_id = reqinfo->updt_id,
        dfp.updt_cnt = 0,
        dfp.updt_task = reqinfo->updt_task
    plan d1 where build->output_routes[d1.seq].action_flag != FAIL_ACTION
              and maxrec(d2, build->output_routes[d1.seq].flex_rtg_cnt)
    join d2 where build->output_routes[d1.seq].flex_rtgs[d2.seq].action_flag != FAIL_ACTION
              and maxrec(d3, build->output_routes[d1.seq].flex_rtgs[d2.seq].num_of_copies)
    join d3
    join dfp
    with nocounter, status(build->output_routes[d1.seq].flex_rtgs[d2.seq].status_flag)
 
    ;Check the status for each item
    call CheckStatus(INSERT_ACTION)
 
    ;Check for errors in the insert
    if (CheckError(FAILURE, "INSERT", FAILURE, "DCP_FLEX_PRINTER") > 0)
        go to EXIT_SCRIPT
    endif
 
endif  ;insert_flag > 0
 
 
#EXIT_SCRIPT
;Final check to see if any error occurred.
;This is one last catch-all just in case an error was unhandled somewhere in the script
call CheckError(FAILURE, "CCL ERROR", FAILURE, "FINAL ERROR CHECK")
 
 
;Write out the logfile
select into value(LOG_FILE)
    route_type_disp = trim(substring(1, 100, build->output_routes[d1.seq].route_type), 3),
    route_name_disp = trim(substring(1, 100, build->output_routes[d1.seq].route_desc), 3),
    value_disp = trim(substring(1, 100, build->output_routes[d1.seq].flex_rtgs[d2.seq].value1_disp_orig), 3),
    patient_type_disp = trim(substring(1, 100, build->output_routes[d1.seq].flex_rtgs[d2.seq].value2_disp_orig), 3),
    sub_activity_type_disp = trim(substring(1, 100, build->output_routes[d1.seq].flex_rtgs[d2.seq].value3_disp_orig), 3),
;    patient_location_disp = trim(substring(1, 100, build->output_routes[d1.seq].flex_rtgs[d2.seq].value4_disp_orig), 3),
    printer_name_disp  = cnvtupper(cnvtalphanum(substring(1, 100, build->output_routes[d1.seq].flex_rtgs[d2.seq].printer_name)))
from (dummyt d1 with seq = value(build->output_route_cnt)),
     (dummyt d2 with seq = value(1)),
     (dummyt d3 with seq = value(1))
plan d1 where maxrec(d2, build->output_routes[d1.seq].flex_rtg_cnt)
join d2 where maxrec(d3, build->output_routes[d1.seq].flex_rtgs[d2.seq].num_of_copies)
          and d2.seq > 0
join d3
order route_type_disp desc, route_name_disp, printer_name_disp
head report
    ;Constants for the column & data item positions
    ;Row 1
    COL_COUNT       = 0
    COL_TYPE_DISP   = COL_COUNT + 5
 
    ;Row 2
    COL_NAME_DISP    = COL_TYPE_DISP + 12
    COL_ACTION  = 110
    COL_NAME_ERROR   = COL_NAME_DISP + 5
 
    COL_PARAM1 = COL_NAME_ERROR + 15
    COL_PARAM2 = COL_PARAM1 + 15
    COL_PARAM3 = COL_PARAM2 + 15
    COL_PARAM4 = COL_PARAM3 + 15
 
    COL_PRINTER_DISP = COL_PARAM4 + 15
 
    row_cnt = 0
    action_disp = fillstring(10, "")
    LINE = fillstring(value(120), "-")
 
    ;Print the title and run date/time.
    col 0 "REQUISITION ROUTING TYPE - IMPORT"
    row + 1
 
    col 0 "LAST RUN: "
    col 11 BEGIN_DATE "@MEDIUMDATETIME"
    row + 1
    row + 1
 
    ;Print and CCL errors that were encountered.
    if (errors->error_ind > 0)
        col 0 "CCL ERRORS ENCOUNTERED!:"
        row + 1
 
        ;Print each error & CCL error message.
        for (loop_cnt = 1 to errors->error_cnt)
            col 0,  errors->status_data->subeventstatus[loop_cnt].operationname
            col 20, errors->status_data->subeventstatus[loop_cnt].targetobjectname
            row + 1
 
            col 0, errors->status_data->subeventstatus[loop_cnt].targetobjectvalue
            row + 1
        endfor
 
        row + 1
    endif
 
    ;Print the column headers.
    col COL_COUNT,     "Row"
    col COL_TYPE_DISP, "Route Type"
    row + 1
 
    col COL_NAME_DISP,  "Route Name"
    col COL_PARAM1, "Facility"
    col COL_PARAM2, "Patient Type"
    col COL_PARAM3, "Sub Act Type"
    col COL_PARAM4, "Patient Loc"
    col COL_PRINTER_DISP, "Printer"
    col COL_ACTION,    "Action"
    row + 1
 
    col 0 LINE
    row + 1
 
head route_type_disp
 
    col COL_COUNT,     row_cnt "###;r;i"
    col COL_TYPE_DISP, route_type_disp
 
head route_name_disp
  
    col COL_COUNT,    row_cnt "###;r;i"
    col COL_NAME_DISP, route_name_disp
 
    ;If there was an error message for this item, print it out on the next row
    if (textlen(trim(build->output_routes[d1.seq].error_msg, 3)) > 0)
        row + 1
        col COL_NAME_ERROR, build->output_routes[d1.seq].error_msg
    endif
 
detail
    row_cnt = row_cnt + 1
 
    action_disp = evaluate(build->output_routes[d1.seq].flex_rtgs[d2.seq].action_flag, FAIL_ACTION, "FAIL",
                          evaluate(insert_flag, 0, "VERIFIED", "UPLOADED"))
 
    col COL_COUNT,    row_cnt "###;r;i"
 
    if (build->output_routes[d1.seq].route_type = "RAD")
        col COL_PARAM1, value_disp
        col COL_PARAM2, patient_type_disp
        col COL_PARAM3, sub_activity_type_disp
    elseif (build->output_routes[d1.seq].route_type = "TRANSPORT")
        col COL_PARAM1, value_disp
    else
        col COL_PARAM4, value_disp
    endif
    col COL_PRINTER_DISP, printer_name_disp
    col COL_ACTION,   action_disp
 
    ;If there was an error message for this item, print it out on the next row
    if (textlen(trim(build->output_routes[d1.seq].flex_rtgs[d2.seq].error_msg, 3)) > 0)
        row + 1
        col COL_NAME_ERROR, build->output_routes[d1.seq].flex_rtgs[d2.seq].error_msg
    endif
 
    row + 1
 
foot route_type_disp
    col 0 LINE
    row + 1
 
foot report
    call center("---------- END OF LOG ----------", 0, 120)
 
with nocounter, format = variable, noformfeed, maxcol = 200, maxrow = 1, nullreport
 
 
;Print a message to the screen
call echo("")
call echo("******************************************************************************************")
call echo(concat("*   Upload complete, check ", LOG_FILE, " for more information.   *"))
call echo("******************************************************************************************")
call echo("")
 
end
go

