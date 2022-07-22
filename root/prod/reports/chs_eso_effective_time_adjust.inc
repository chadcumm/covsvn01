 
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
 
          Source file name:   ESO_EFFECTIVE_TIME_ADJUST.INC
          Object name:        n/a
          Request #:          n/a
 
          Product:            ESO
          Product Team:       System Integration
          HNA Version:        V500
          CCL Version:
 
          Program purpose:    This file determines the effective date time offset to be used
                              to handle discepancies between the current date and time of
                              different nodes.
 
          Tables read:
 
          Tables updated:
 
          Executing from:
 
          Special Notes:
 
 ***********************************************************************
 *                  GENERATED MODIFICATION CONTROL LOG                 *
 ***********************************************************************
 *                                                                     *
 *Mod Date     Engineer             Comment                            *
 *--- -------- -------------------- -----------------------------------*
  000 10/24/08 Luke Hendricks       188540 - Initial Release
 ******************  END OF ALL MODCONTROL BLOCKS  ********************/
 
 
%#ifndef ESO_EFFECTIVE_TIME_ADJUST
%#def ESO_EFFECTIVE_TIME_ADJUST
 
call echo("<===== ESO_EFFECTIVE_TIME_ADJUST.INC  START =====>")
 
call echo("MOD:000")
 
%i ccluserdir:chs_tn_eso_get_code.inc
 
 
if(not(validate(g_dEsoEffTmAdj)))
 
   declare dEsoEffTmAdjTmp = f8 with protect, noconstant(0.0)
 
   declare dEsoEffectiveTimeAdjustCd = f8 with protect, constant(eso_get_meaning_by_codeset( 14874, "ESOEFFTMADJ"))
 
   declare dEsoContribDefault = f8 with protect, constant( eso_get_meaning_by_codeset(89, "ESODEFAULT"))
 
   select into "nl:"
       op.contributor_system_cd,
       op.process_type_cd,
       op.null_string
 
   from outbound_field_processing op
   where op.contributor_system_cd = dEsoContribDefault and
         op.process_type_cd = dEsoEffectiveTimeAdjustCd
 
   detail
 
         dEsoEffTmAdjTmp = 100 * cnvtreal(op.null_string)
 
   with nocounter
 
   declare g_dEsoEffTmAdj = f8 with persist, constant (dEsoEffTmAdjTmp)
 
endif
 
%#endif
 
 
 

