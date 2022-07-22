/*~BB~************************************************************************
      *                                                                      *
      *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
      *                              Technology, Inc.                        *
      *       Revision      (c) 1984-2005 Cerner Corporation                 *
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

/*****************************************************************************

        Source file name:       cov_mm_item_inactivate.prg
        Object name:			cov_mm_item_inactivate

        Product:
        Product Team:
        HNA Version:
        CCL Version:

        Program purpose:

        Tables read:


        Tables updated:         -

******************************************************************************/


;~DB~************************************************************************
;    *    GENERATED MODIFICATION CONTROL LOG              *
;    ****************************************************************************
;    *                                                                         *
;    *Mod Date       Engineeer          Comment                                *
;    *--- ---------- ------------------ -----------------------------------    *
;     000 18-10-22  							initial release			       *
;    																           *
;~DE~***************************************************************************


;~END~ ******************  END OF ALL MODCONTROL BLOCKS  ********************

drop program cov_mm_item_inactivate:dba go
create program cov_mm_item_inactivate:dba

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.

with OUTDEV


call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))

if (not(validate(reply,0)))
record  reply
(
	1 text = vc
	1 status_data
	 2 status = c1
	 2 subeventstatus[1]
	  3 operationname = c15
	  3 operationstatus = c1
	  3 targetobjectname = c15
	  3 targetobjectvalue = c100
)
endif

call set_codevalues(null)
call check_ops(null)

if (not validate(ffrec))
    record ffrec
    (
    1 file_desc         = i4
    1 file_offset       = i4
    1 file_dir          = i4
    1 file_name         = vc
    1 file_buf          = vc
    ) with protect
endif

if (not validate(t_rec))
	record t_rec
	(
	1 filename			= vc
	1 cnt				= i4
	1 qual[*]
	 2 row				= vc
	 2 item_alias 		= vc
	 2 description		= vc
	 2 item_id			= f8
	)
endif

set t_rec->filename = "ccluserdir:cov_mm_item_inactivate.csv"
;open a file named ccl_test.dat with read access
set ffrec->file_name = t_rec->filename
set ffrec->file_buf = "r" /* file_buf values are case sensitive so lowercase r is used */
set stat = cclio("OPEN",ffrec)
;allocate buffer for desired read size
set ffrec->file_buf = notrim(fillstring(300," "))
if (ffrec->file_desc != 0)
	set stat = 1
	while (stat > 0)
		;read the file one record at a time
		set stat = cclio("GETS",ffrec)
		if (stat > 0)
			set pos = findstring(char(0),ffrec->file_buf)
			;call echo(build2("pos=",pos))
			set pos = evaluate(pos,0,size(ffrec->file_buf),pos)
			;call echo(build2("pos=",pos))
			;call echo(substring(1,pos,trim(ffrec->file_buf)))
			if (substring(1,pos,trim(ffrec->file_buf)) > " ")
				set t_rec->cnt = (t_rec->cnt + 1)
				set stat = alterlist(t_rec->qual,t_rec->cnt)
				set t_rec->qual[t_rec->cnt].row = substring(1,pos,trim(ffrec->file_buf))
            else
				call echo(build2("buf=",ffrec->file_buf,"<---"))
			endif
		endif
       endwhile
        ;close the file
       set stat = cclio("close",ffrec)
endif

if (t_rec->cnt = 0)
 go to exit_script
endif


call addEmailLog("chad.cummings@covhlth.com")

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call exitScript(null)
call echorecord(t_rec)
call echorecord(code_values)
call echorecord(program_log)


end
go
