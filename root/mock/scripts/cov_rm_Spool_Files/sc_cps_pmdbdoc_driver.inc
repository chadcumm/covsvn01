;******************************************************************************
;*                                                                            *
;*  Copyright Notice:  (c) 1983 Laboratory Information Systems &              *
;*                              Technology, Inc.                              *
;*       Revision      (c) 1984-2008 Cerner Corporation                       *
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
;     Source file name:       sc_cps_pmdbdoc_driver.inc
;
;     Product:                Discern Explorer
;     Product Team:           Solutions Center Custom Discern Team
;     HNA Version:
;     CCL Version:
;
;     Program purpose:        Subroutines used in sc_cps_pmdbdoc_driver
;
;     Tables read:            prsnl, person_name
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
; 197239  15-AUG-2008  CH014093   Initial Design
;******************************************************************************
 
;**************************************************************
; DECLARED SUBROUTINES
;**************************************************************
declare GetNamesForRecord(rec=vc, person_id=f8, lookup_type=i2) = null with Public
 
;**************************************************************
; DEFINED SUBROUTINES
;**************************************************************
 
;********************************************************************************
; Get Names For Record
;********************************************************************************
; Description: Populates a given piece of the record structure with the PERSON
;              or PRSNL names as provided.
;
; Inputs: rec [vc] - represents the position of the record to be updated
;         person_id [f8] - unique id of person who's names are to be loaded
;         lookup_type [i2] - 0 = PERSON, 1 = PRSNL
;********************************************************************************
declare GET_NAMES_PERSON = i2 with Constant(0),Public
declare GET_NAMES_PRSNL = i2 with Constant(1),Public
subroutine GetNamesForRecord(rec, person_id, lookup_type)
    free record commands
    record commands(
        1 qual_cnt = i4
        1 qual[*]
            2 command = vc
    )
 
    declare CURRENT_NAME_CD = f8 with Constant(uar_get_code_by("MEANING",213,"CURRENT")),protect
 
    select
        if (lookup_type = 1)
            FROM prsnl p, person_name n
        else
            FROM person p, person_name n
        endif
    into "nl:"
    plan p
    where p.person_id = person_id
 
    join n
    where n.person_id = outerjoin(p.person_id)
      and n.name_type_cd = outerjoin(CURRENT_NAME_CD)
      and n.active_ind = outerjoin(1)
      and n.beg_effective_dt_tm <= outerjoin(SYSDATE)
      and n.end_effective_dt_tm >  outerjoin(SYSDATE)
 
    order by p.updt_dt_tm, n.updt_dt_tm
 
    head report
        stat = alterlist(commands->qual, 10)
        i = 0
    foot p.person_id
        i = i + 1
        commands->qual[i].command = build2('set ', rec, '.name_full_formatted = "', trim(p.name_full_formatted), '"')
 
        i = i + 1
        commands->qual[i].command = build2('set ', rec, '.name_first = "', trim(p.name_first), '"')
 
        ;i = i + 1
        ;commands->qual[i].command = build2('set ', rec, '.name_first_key = "', trim(p.name_first_key), '"')
 
        i = i + 1
        commands->qual[i].command = build2('set ', rec, '.name_last = "', trim(p.name_last), '"')
 
        ;i = i + 1
        ;commands->qual[i].command = build2('set ', rec, '.name_last_key = "', trim(p.name_last_key), '"')
 
 
	i = i + 1
        commands->qual[i].command = build2('set ', rec, '.name_middle = "', trim(n.name_middle), '"')
    foot report
        stat = alterlist(commands->qual, i)
        commands->qual_cnt = i
    with nocounter
 
    ;call echorecord(commands)
    for(i = 1 to commands->qual_cnt)
        call parser(build(commands->qual[i].command, " go"))
        ;set parser_str = build2(parser_str, " ", commands->qual[i].command, " go", char(10), char(13))
    endfor
 
    ;call echo(parser_str)
    ;call parser(parser_str)
 
end ;subroutine GetNames
 
 
 
subroutine GetNameFF(field, person_id, lookup_type)
    free record commands
    record commands(
        1 qual_cnt = i4
        1 qual[*]
            2 command = vc
    )
 
    declare CURRENT_NAME_CD = f8 with Constant(uar_get_code_by("MEANING",213,"CURRENT")),protect
 
    select
        if (lookup_type = 1)
            FROM prsnl p, person_name n
        else
            FROM person p, person_name n
        endif
    into "nl:"
    plan p
    where p.person_id = person_id
 
    join n
    where n.person_id = outerjoin(p.person_id)
      and n.name_type_cd = outerjoin(CURRENT_NAME_CD)
      and n.active_ind = outerjoin(1)
      and n.beg_effective_dt_tm <= outerjoin(SYSDATE)
      and n.end_effective_dt_tm >  outerjoin(SYSDATE)
 
    order by p.updt_dt_tm, n.updt_dt_tm
 
    head report
        stat = alterlist(commands->qual, 10)
        i = 0
    foot p.person_id
        i = i + 1
        commands->qual[i].command = build2('set ', field, ' = "', trim(p.name_full_formatted), '"')
 
 
    foot report
        stat = alterlist(commands->qual, i)
        commands->qual_cnt = i
    with nocounter
 
    ;call echorecord(commands)
    for(i = 1 to commands->qual_cnt)
        call parser(build(commands->qual[i].command, " go"))
        ;set parser_str = build2(parser_str, " ", commands->qual[i].command, " go", char(10), char(13))
    endfor
 
    ;call echo(parser_str)
    ;call parser(parser_str)
 
end ;subroutine GetNameFF
 
subroutine GetOrgName(field, org_id)
    free record commands
    record commands(
        1 qual_cnt = i4
        1 qual[*]
            2 command = vc
    )
 
    ;declare CURRENT_NAME_CD = f8 with Constant(uar_get_code_by("MEANING",213,"CURRENT")),protect
 
    select into "nl:"
 
    FROM organization o
 
 
    where o.organization_id = org_id
      and o.active_ind = outerjoin(1)
      and o.beg_effective_dt_tm <= outerjoin(SYSDATE)
      and o.end_effective_dt_tm >  outerjoin(SYSDATE)
 
    order by o.updt_dt_tm
 
    head report
        stat = alterlist(commands->qual, 10)
        i = 0
    foot o.organization_id
        i = i + 1
        commands->qual[i].command = build2('set ', field, ' = "', trim(o.org_name), '"')
 
 
    foot report
        stat = alterlist(commands->qual, i)
        commands->qual_cnt = i
    with nocounter
 
    ;call echorecord(commands)
    for(i = 1 to commands->qual_cnt)
        call parser(build(commands->qual[i].command, " go"))
        ;set parser_str = build2(parser_str, " ", commands->qual[i].command, " go", char(10), char(13))
    endfor
 
    ;call echo(parser_str)
    ;call parser(parser_str)
 
end ;subroutine GetOrgName
 
subroutine GetUpdtName(field, encntr_id)
    free record commands
    record commands(
        1 qual_cnt = i4
        1 qual[*]
            2 command = vc
    )
 
    ;declare CURRENT_NAME_CD = f8 with Constant(uar_get_code_by("MEANING",213,"CURRENT")),protect
 
    select into "nl:"
 
    FROM encounter e,
    prsnl pr
 
 	plan e
    where e.encntr_id = encntr_id
 
	join pr
	where pr.person_id = e.updt_id
 
 	order by e.updt_id
 
    head report
        stat = alterlist(commands->qual, 10)
        i = 0
    foot e.updt_id
        i = i + 1
        commands->qual[i].command = build2('set ', field, ' = "', trim(pr.name_full_formatted), '"')
 
 
    foot report
        stat = alterlist(commands->qual, i)
        commands->qual_cnt = i
    with nocounter
 
    ;call echorecord(commands)
    for(i = 1 to commands->qual_cnt)
        call parser(build(commands->qual[i].command, " go"))
        ;set parser_str = build2(parser_str, " ", commands->qual[i].command, " go", char(10), char(13))
    endfor
 
    ;call echo(parser_str)
    ;call parser(parser_str)
 
end ;subroutine GetUpdtName
 
subroutine GetUpdtDtTm(field, encntr_id)
	;declare reg_dt = vc
    free record commands
    record commands(
        1 qual_cnt = i4
        1 qual[*]
            2 command = vc
    )
 
    ;declare CURRENT_NAME_CD = f8 with Constant(uar_get_code_by("MEANING",213,"CURRENT")),protect
 
    select into "nl:"
 	;tmpdate = format(e.updt_dt_tm,"MM/DD/YYYY HH:MM:SS;;d")
 
    FROM encounter e
 
    where e.encntr_id = encntr_id
 
 
 
 	order by e.updt_dt_tm
 
    head report
        stat = alterlist(commands->qual, 10)
        i = 0
    foot e.updt_dt_tm
    	;reg_dt = tmpdate
        i = i + 1
        commands->qual[i].command = build2('set ', field, ' = ', e.updt_dt_tm)
 
 
    foot report
        stat = alterlist(commands->qual, i)
        commands->qual_cnt = i
    with nocounter
 
    ;call echorecord(commands)
    for(i = 1 to commands->qual_cnt)
        call parser(build(commands->qual[i].command, " go"))
        ;set parser_str = build2(parser_str, " ", commands->qual[i].command, " go", char(10), char(13))
    endfor
 
    ;call echo(parser_str)
    ;call parser(parser_str)
 
end ;subroutine GetUpdtDtTm
 
set last_mod = "sc_cps_pmdbdocs_subs.inc - 123456  30-JAN-2009  MH013952"


