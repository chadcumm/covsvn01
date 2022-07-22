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

free set t_rec
record t_rec
(
	1 cnt			= i4
	1 filename_a      = vc
	1 filename_b    = vc
	1 filename_c = vc
	1 audit_cnt = i4
	1 audit[*]
	 2 section = vc
	 2 title = vc
	 2 alias = vc
	 2 misc = vc
)

set t_rec->filename_a = concat(	 "cclscratch:"
								,trim(cnvtlower(curprog))
								,"_"
								,trim(cnvtstring(reqinfo->updt_req))
								,"_"
								,trim(format(sysdate,"yyyy_mm_dd_hh_mm_ss;;d")),".dat")
call echojson(t_rec, t_rec->filename_a , 0) 

call log_message(concat(cnvtlower(curprog)," debug start execution..."), 0)

if (validate(reqinfo))
	call log_message(concat(cnvtrectojson(reqinfo)), 0)
	call echojson(reqinfo, t_rec->filename_a , 1) 
endif
if (validate(request))
	call log_message(concat(cnvtrectojson(request)), 0)
	call echojson(request, t_rec->filename_a , 1) 
endif

if (validate(requestin))
	call log_message(concat(cnvtrectojson(requestin)), 0)
	call echojson(requestin, t_rec->filename_a , 1) 
endif

call log_message(concat(cnvtrectojson(reqinfo)), 0)
if (validate(reply))
	call log_message(concat(cnvtrectojson(reply)), 0)
endif
call log_message(concat(cnvtlower(curprog)," debug finish execution..."), 0)
#exit_script
call log_message(concat(cnvtlower(curprog)," exit..."), 0)

end go
