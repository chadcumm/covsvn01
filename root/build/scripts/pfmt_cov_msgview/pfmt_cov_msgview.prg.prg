drop program pfmt_cov_msgview:dba go
create program pfmt_cov_msgview:dba

/*~BB~************************************************************************
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
  ~BE~***********************************************************************/

/****************************************************************************
        Source file name:       pfmt_cov_msgview.prg
        Object name:            pfmt_cov_msgview
        Request #:
        Product:
        Product Team:           
        HNA Version:
        CCL Version:

        Program purpose:

        Tables read:
        Tables updated:
        Executing from:		600312 - pts_add_prsnl_reltn
        					600313 - pts_chg_prsnl_reltn
        					101305 - PM_ENS_ENCNTR_PRSNL_RELTN
        					        					        				

        Special Notes:

****************************************************************************/

;~DB~************************************************************************
;    *                      GENERATED MODIFICATION CONTROL LOG              *
;    ************************************************************************
;    *                                                                      *
;    *Mod Date     Engineer             Comment                             *
;    *--- -------- -------------------- ----------------------------------- *
;     *000 05/2008     			 Initial Release                    *
;~DE~************************************************************************

;~END~ ******************  END OF ALL MODCONTROL BLOCKS  ********************

%i ccluserdir:cov_script_logging.inc  
call log_message(concat(cnvtlower(curprog)," debug start execution..."), log_level_debug)

call log_message(concat(cnvtlower(curprog)," debug finish execution..."), log_level_debug)
#exit_script
call log_message(concat(cnvtlower(curprog)," exit..."), log_level_debug)

end go
