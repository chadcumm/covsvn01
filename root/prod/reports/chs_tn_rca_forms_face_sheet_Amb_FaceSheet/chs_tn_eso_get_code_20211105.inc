 
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
 
        Source file name:       ESO_GET_CODE.INC
        Object name:            n/a
        Request #:              n/a
 
        Product:                ESO
        Product Team:           System Integration
        HNA Version:            500
        CCL Version:            7.9
 
        Program purpose:        This file defines subroutines used to
                                get code value displays and meanings
                                through the uar call and if necessary
                                a select on the CODE_VALUE table.
 
        Tables read:            CODE_VALUE
 
        Tables updated:         n/a
 
        Executing from:         FSI_SRVESO
 
        Special Notes:          Do not call these subroutines from
                                within a select statement.
 
 ***************************************************************************************
 *                       GENERATED MODIFICATION CONTROL LOG                            *
 ***************************************************************************************
 *                                                                                     *
 *Mod Date     Engineer        Feature Comment                                         *
 *--- -------- -------------   ------- ------------------------------------------------*
  000 09/15/99 Eric Martin             Initial write                                   *
  001 12/07/99 Eric Martin             Add eso_get_meaning_by_codeset                  *
  002 09/08/00 Wayne Aulner            Added "x_"                                      *
  003 09/21/00 Eric Martin             Force meaning to be c12 in                      *
                                        eso_get_meaning_by_codeset                     *
  004 03/22/04 Alan Basa       41127   Add eso_get_code_set                            *
  005 08/15/02 Wayne Aulner            Trim both leading and trailing spaces           *
                                        and add a nullterm for uar call. Add           *
                                        ifndef and def statements.                     *
  006 04/22/05 Alan Basa       62692   Added a validate around the uar calls           *
                                        in case the script is called from a readme.    *
  007 12/22/05 Brad Arndt      71162   Added new routine eso_get_alias_or_display      *
  008 05/11/12 Luke Hendricks  302067  Moved eso_format_phone_cd to eso_hl7_formatting *
 ***************************************************************************************
 
 ******************  END OF ALL MODCONTROL BLOCKS  ********************/
 
%#ifndef ESO_GET_CODE                   ;; 005
%#def ESO_GET_CODE                      ;; 005
 
 
call echo("<===== ESO_GET_CODE.INC Begin =====>")   ;; 005
call echo( "MOD:008" )                  ;; 008
 
 
 
 
/*------------------------------------------------------------------------------*/
 
declare eso_get_code_meaning( code ) = c12
declare eso_get_code_display( code ) = c40
declare eso_get_meaning_by_codeset( x_code_set , x_meaning ) = f8   ;; 001, 002
declare eso_get_code_set( code )     = i4       ;;004
declare eso_get_alias_or_display( code , contrib_src_cd ) = vc      ;;007
 
/*------------------------------------------------------------------------------*/
 
subroutine eso_get_code_meaning( code )
 
        call echo( "Entering eso_get_code_meaning subroutine" )
 
        call echo( build( "    code=" , code ) )
 
        free set t_meaning
        declare t_meaning = c12
        set t_meaning = fillstring( 12 , " " )
 
        if ( code > 0 )
 
            if(validate(readme_data, 0))       ;;006 +
 
                call echo( "    A Readme is calling this script" )
 
                call echo( "    selecting rows from code_value table" )
 
                select into "nl:"
                    cv.*
                from
                     code_value cv
                where ( ( cv.code_value = code ) and
                      ( cv.begin_effective_dt_tm < cnvtdatetime( curdate , curtime3 ) ) and
                      ( cv.end_effective_dt_tm > cnvtdatetime( curdate , curtime3 ) ) and
                      ( cv.active_ind = 1 ) )
                detail
                       t_meaning = cv.cdf_meaning
                with maxqual( cv , 1 )
 
                if ( curqual < 1 )
 
                      call echo( "    no rows qualified on code_value table" )
 
                endif
 
            else                               ;;006 -
 
                    set t_meaning = uar_get_code_meaning( cnvtreal( code ) )
 
                    if ( trim( t_meaning ) = "" )
 
                        call echo( "    uar_get_code_meaning failed" )
 
                        call echo( "    selecting row from code_value table" )
 
                        select into "nl:"
                            cv.*
                        from
                            code_value cv
                        where ( ( cv.code_value = code ) and
                                ( cv.begin_effective_dt_tm < cnvtdatetime( curdate , curtime3 ) ) and
                                ( cv.end_effective_dt_tm > cnvtdatetime( curdate , curtime3 ) ) and
                                ( cv.active_ind = 1 ) )
                        detail
                            t_meaning = cv.cdf_meaning
                        with maxqual( cv , 1 )
 
                        if ( curqual < 1 )
 
                            call echo( "    no rows qualified on code_value table" )
 
                        endif
 
                    endif
 
            endif                              ;;006
 
        endif
 
        call echo( build( "    t_meaning=" , t_meaning ) )
 
        call echo( "Exiting eso_get_code_meaning subroutine" )
 
        return( trim( t_meaning, 3 ) )      ;; 005
 
end
 
/*------------------------------------------------------------------------------*/
 
subroutine eso_get_code_display( code )
 
        call echo( "Entering eso_get_code_display subroutine" )
 
        call echo( build( "    code=" , code ) )
 
        free set t_display
        declare t_display = c40
        set t_display = fillstring( 40 , " " )
 
        if ( code > 0 )
 
 
            if(validate(readme_data, 0))       ;;006 +
 
                call echo( "   A Readme is calling this script" )
 
                call echo( "   Selecting rows from code_value table" )
 
                select into "nl:"
                    cv.*
                from
                    code_value cv
                where ( ( cv.code_value = code ) and
                        ( cv.begin_effective_dt_tm < cnvtdatetime( curdate , curtime3 ) ) and
                        ( cv.end_effective_dt_tm > cnvtdatetime( curdate , curtime3 ) ) and
                        ( cv.active_ind = 1 ) )
                detail
                    t_display = cv.display
                with maxqual( cv , 1 )
 
                if ( curqual < 1 )
 
                    call echo( "    no rows qualified on code_value table" )
 
                endif
 
            else                               ;;006 -
 
                set t_display = uar_get_code_display( cnvtreal( code ) )
 
                if ( trim( t_display ) = "" )
 
                    call echo( "    uar_get_code_display failed" )
 
                    call echo( "    selecting row from code_value table" )
 
                    select into "nl:"
                        cv.*
                    from
                        code_value cv
                    where ( ( cv.code_value = code ) and
                            ( cv.begin_effective_dt_tm < cnvtdatetime( curdate , curtime3 ) ) and
                            ( cv.end_effective_dt_tm > cnvtdatetime( curdate , curtime3 ) ) and
                            ( cv.active_ind = 1 ) )
                    detail
                        t_display = cv.display
                    with maxqual( cv , 1 )
 
                    if ( curqual < 1 )
 
                        call echo( "    no rows qualified on code_value table" )
 
                    endif
 
                endif
 
            endif                              ;;006
 
 
        endif
 
        call echo( build( "    t_display=" , t_display ) )
 
        call echo( "Exiting eso_get_code_display subroutine" )
 
        return( trim( t_display, 3 ) )          ;; 005
 
end
 
/*------------------------------------------------------------------------------*/
 
/* 001, 002 */
 
subroutine eso_get_meaning_by_codeset( x_code_set , x_meaning )
 
        call echo( "Entering eso_get_meaning_by_codeset subroutine" )
 
        call echo( build( "    code_set=" , x_code_set ) )
        call echo( build( "    meaning=" , x_meaning ) )
 
        free set t_code
        declare t_code = f8
        set t_code = 0.0
 
        if ( ( x_code_set > 0 ) and ( trim( x_meaning ) > "" ) )
 
            ;; 003
            free set t_meaning
            declare t_meaning = c12
            set t_meaning = fillstring( 12 , " " )
            set t_meaning = x_meaning
 
            free set t_rc
 
            if(validate(readme_data, 0))       ;;006 +
 
                call echo( "   A Readme is calling this script" )
 
                call echo( "   Selecting rows from code_value table" )
 
                select into "nl:"
                    cv.*
                from
                    code_value cv
                where ( ( cv.code_set = x_code_set ) and
                        ( cv.cdf_meaning = trim( x_meaning ) ) and
                        ( cv.begin_effective_dt_tm < cnvtdatetime( curdate , curtime3 ) ) and
                        ( cv.end_effective_dt_tm > cnvtdatetime( curdate , curtime3 ) ) and
                        ( cv.active_ind = 1 ) )
                detail
                    t_code = cv.code_value
                with maxqual( cv , 1 )
 
                if ( curqual < 1 )
 
                    call echo( "    no rows qualified on code_value table" )
 
                endif
 
 
            else                               ;;006 -
 
                ;; 003
                ;;set t_rc = uar_get_meaning_by_codeset( cnvtint( x_code_set ) , x_meaning , 1 , t_code )
                set t_rc = uar_get_meaning_by_codeset( cnvtint( x_code_set ) , nullterm(t_meaning) , 1 , t_code )   ;; 005
 
                if ( t_code <= 0 )
 
                        call echo( "    uar_get_meaning_by_codeset failed" )
 
                        call echo( "    selecting row from code_value table" )
 
                        select into "nl:"
                            cv.*
                        from
                            code_value cv
                        where ( ( cv.code_set = x_code_set ) and
                                ( cv.cdf_meaning = trim( x_meaning ) ) and
                                ( cv.begin_effective_dt_tm < cnvtdatetime( curdate , curtime3 ) ) and
                                ( cv.end_effective_dt_tm > cnvtdatetime( curdate , curtime3 ) ) and
                                ( cv.active_ind = 1 ) )
                        detail
                            t_code = cv.code_value
                        with maxqual( cv , 1 )
 
                        if ( curqual < 1 )
 
                            call echo( "    no rows qualified on code_value table" )
 
                        endif
 
                endif
 
            endif                              ;;006
 
        endif
 
        call echo( build( "    t_code=" , t_code ) )
 
        call echo( "Exiting eso_get_meaning_by_codeset subroutine" )
 
        return( t_code )
 
end
 
 
;;+ 004
/*------------------------------------------------------------------------------*/
 
subroutine eso_get_code_set( code )
 
        call echo( "Entering eso_get_code_set subroutine" )
 
        call echo( build( "    code=" , code ) )
 
        declare iCode_set  = i4 with private, noconstant(0)
 
        if ( code > 0 )
 
            if(validate(readme_data, 0))       ;;006 +
 
                call echo( "   A Readme is calling this script" )
 
                call echo( "   Selecting rowS from code_value table" )
 
                select into "nl:"
                    cv.code_set
                from
                    code_value cv
                where ( ( cv.code_value = code ) and
                        ( cv.begin_effective_dt_tm < cnvtdatetime( curdate , curtime3 ) ) and
                        ( cv.end_effective_dt_tm > cnvtdatetime( curdate , curtime3 ) ) and
                        ( cv.active_ind = 1 ) )
                detail
                    iCode_set = cv.code_set
                with maxqual( cv , 1 )
 
                if ( curqual < 1 )
 
                    call echo( "    no rows qualified on code_value table" )
 
                endif
 
 
            else                               ;;006 -
 
                set iCode_set = uar_get_code_set( cnvtreal( code ) )
 
                if (NOT( iCode_set > 0 ))
 
                    call echo( "    uar_get_code_set failed" )
 
                    call echo( "    selecting row from code_value table" )
 
                    select into "nl:"
                        cv.code_set
                    from
                        code_value cv
                    where ( ( cv.code_value = code ) and
                            ( cv.begin_effective_dt_tm < cnvtdatetime( curdate , curtime3 ) ) and
                            ( cv.end_effective_dt_tm > cnvtdatetime( curdate , curtime3 ) ) and
                            ( cv.active_ind = 1 ) )
                    detail
                        iCode_set = cv.code_set
                    with maxqual( cv , 1 )
 
                    if ( curqual < 1 )
 
                        call echo( "    no rows qualified on code_value table" )
 
                    endif
 
                endif
 
            endif                              ;;006
 
        endif
 
        call echo( build( "    Code_set=" , iCode_set ) )
 
        call echo( "Exiting eso_get_code_set subroutine" )
 
        return( iCode_set)
 
end
 
/*------------------------------------------------------------------------------*/
;; - 004
 
;;007+
subroutine eso_get_alias_or_display( code , contrib_src_cd )
 
   call echo( "Entering eso_get_alias_or_display" )
   call echo( build("   code            = ", code ) )
   call echo( build("   contrib_src_cd = ", contrib_src_cd ) )
 
   free set t_alias_or_display
   declare t_alias_or_display = vc
   set t_alias_or_display = " "
 
   if( not( code > 0.0 ) )
      return ( t_alias_or_display )
   endif
 
   if( contrib_src_cd > 0.0 )
 
     select into "nl:"
        cvo.alias
     from
        code_value_outbound cvo
     where
        cvo.code_value = code and
        cvo.contributor_source_cd = contrib_src_cd
     detail
        if ( cvo.alias > "" )
           t_alias_or_display = cvo.alias
        endif
     with nocounter
 
   endif
 
   if( size(trim(t_alias_or_display)) = 0 )
 
     call echo("Alias not found, checking code value display")
     set t_alias_or_display = eso_get_code_display( code )
 
   endif
 
   call echo( "Exiting eso_get_alias_or_display" )
 
   return (t_alias_or_display)
 
end
;;007-
 
call echo("<===== ESO_GET_CODE.INC End =====>")     ;; 005
 
%#endif                         ;; 005
 
 
 
 

