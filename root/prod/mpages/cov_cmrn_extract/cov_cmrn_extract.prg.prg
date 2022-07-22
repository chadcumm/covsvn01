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

        Source file name:       cov_cmrn_extract.prg
        Object name:			cov_cmrn_extract

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

drop program cov_cmrn_extract:dba go
create program cov_cmrn_extract:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Format" = "0" 

with OUTDEV, OUTFMT


call echo(build("loading script:",curprog))
set nologvar = 1	;do not create log = 1		, create log = 0
set noaudvar = 1	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))

set _MEMORY_REPLY_STRING = "<html><body>script executed, nothing returned</body></html>"
set output_format = $OUTFMT

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

free set t_rec
record t_rec

(
  1 cnt			= i4
  1 qual[*]
   2 person_id = f8
   2 name_last = vc
   2 name_first = vc
   2 name_middle = vc
   2 birth_dt_tm = dq8
   2 cmrn = vc

)


select into "nl;"
from
  person_alias pa
  ,person p
plan pa
  where pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3) 
  and pa.alias_pool_cd =   2554138243.00
join p
  where p.person_id = pa.person_id
  and   p.active_ind = 1
head report
  cnt = 0
  stat = alterlist(t_rec->qual,3000000)
detail
  cnt = (cnt + 1)
  t_rec->qual[cnt].person_id = p.person_id
  t_rec->qual[cnt].name_first = p.name_first
  t_rec->qual[cnt].name_last = p.name_last
  t_rec->qual[cnt].name_middle = p.name_middle
  t_rec->qual[cnt].birth_dt_tm = p.birth_dt_tm
  t_rec->qual[cnt].cmrn = pa.alias
foot report
  stat = alterlist(t_rec->qual,cnt)
  t_rec->cnt = cnt
with nocounter

call addEmailLog("chad.cummings@covhlth.com")

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

if (output_format = "1")
	set _MEMORY_REPLY_STRING = cnvtrectojson(t_rec)
elseif (output_format = "2")
	set _MEMORY_REPLY_STRING = cnvtrectoxml(t_rec)
else
	select into $OUTDEV
		 alias 		= t_rec->qual[d1.seq].cmrn
		,last_name 	= t_rec->qual[d1.seq].name_last
		,first_name = t_rec->qual[d1.seq].name_first
		,middle_name= t_rec->qual[d1.seq].name_middle
		,birth_dt	= format(t_rec->qual[d1.seq].birth_dt_tm,"mm/dd/yy;;d")
		,person_id	= cnvtstring(t_rec->qual[d1.seq].person_id) 
	from
		(dummyt d1 with seq = t_rec->cnt)
	plan d1
	with format,separator= " "
endif


#exit_script
call exitScript(null)
call echorecord(t_rec)
call echorecord(code_values)
call echorecord(program_log)


end
go
