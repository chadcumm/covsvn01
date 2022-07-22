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
 
        Source file name:       cov_orders_by_comm_type.prg
        Object name:			cov_orders_by_comm_type
 
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
 
drop program cov_orders_by_comm_type:dba go
create program cov_orders_by_comm_type:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Beginning Date and Time" = "SYSDATE"
	, "Ending Date and Time" = "SYSDATE" 

with OUTDEV, BEG_DT_TM, END_DT_TM
 
 
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


free set t_rec
record t_rec
(
	1 cnt			= i4
	1 qual[*]
	 2 active_ind				= i2	
	 2 encntr_id				= f8
	 2 person_id				= f8
	 2 order_id					= f8
	 2 orig_order_dt_tm			= f8
	 2 communication_type_cd	= f8
	 2 catalog_type_cd			= f8
	 2 activity_type_cd			= f8
	 2 ord_phys_id				= f8
	 2 order_status_cd			= f8
)


call addEmailLog("chad.cummings@covhlth.com") 


call writeLog(build2("* START Finding Orders  ************************************"))

select into "nl:"
from
	orders o
plan o
	where o.orig_order_dt_tm >= cnvtdatetime("01-JAN-2019")
	and   o.active_ind 		= 1
	and   o.order_status_cd	!= code_values->cv.cs_6004.canceled_cd
order by
	o.order_id
head report
	t_rec->cnt = 0
head o.order_id
	t_rec->cnt = (t_rec->cnt + 1)
	if(mod(t_rec->cnt,100) = 1)
		stat = alterlist(t_rec->qual, t_rec->cnt +99)
	endif
	t_rec->qual[t_rec->cnt].order_id			= o.order_id
	t_rec->qual[t_rec->cnt].person_id			= o.person_id
	t_rec->qual[t_rec->cnt].encntr_id			= o.encntr_id
	t_rec->qual[t_rec->cnt].orig_order_dt_tm	= o.orig_order_dt_tm
foot report
	stat = alterlist(t_rec->qual,t_rec->cnt)
	call writeLog(build2("->Found Order Count:",t_rec->cnt))
with nocounter

call writeLog(build2("* END   Finding Orders  ************************************"))
 
call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))
 
#exit_script
call exitScript(null)
;call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)
 
 
end
go
 
