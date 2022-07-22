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
	1 cnt						= i4
	1 start_dt_tm				= dq8
	1 end_dt_tm					= dq8
	1 qual[*]	
	 2 encntr_id				= f8
	 2 person_id				= f8
	 2 order_id					= f8
	 2 orig_order_dt_tm			= f8
	 2 communication_type_cd	= f8
	 2 catalog_type_cd			= f8
	 2 activity_type_cd			= f8
	 2 ord_phys_id				= f8
	 2 ord_action_prsnl_id		= f8
	 2 order_status_cd			= f8
	 2 loc_facility_cd			= f8
	 2 loc_nurse_unit_cd		= f8
)


call addEmailLog("chad.cummings@covhlth.com") 

set t_rec->start_dt_tm = cnvtdatetime($BEG_DT_TM)
set t_rec->end_dt_tm = cnvtdatetime($END_DT_TM)


call writeLog(build2("* START Finding Orders  ************************************"))
    
select into "nl:"
from
	encounter e
	,orders o
	,order_action oa
	,encntr_alias ea
	,person p
	,prsnl p1
	,prsnl p2
plan o
	where o.orig_order_dt_tm between cnvtdatetime(t_rec->start_dt_tm) and cnvtdatetime(t_rec->end_dt_tm)
	and   o.active_ind 		= 1
	and   o.template_order_flag in(0,1,5)
    and   o.orderable_type_flag != 6
join oa
	where oa.order_id = o.order_id
    and   oa.action_sequence = 1
    and   oa.communication_type_cd in(
          								 2560.00   	;Telephone Read Back/Verified Cosign
       									,2561.00 	;Verbal Read Back/Verified Cosign
      									,2562.00 	;Direct
										;,681544.00    ;No Cosign Required ***normally not included
										;,19468404.00    ;Cosign Required ***normally not included
										;,20094437.00    ;Initiate Planned Orders No Cosign ***normally not included
										,54416801.00 ;Written Paper Order/Fax No Cosign
										,2553560089.00 ;Standing Order Cosign
										;,2553560097.00    ;Per Protocol No Cosign ***normally not included
										;,2576706321.00    ;Per Nutrition Policy No Cosign ***normally not included
   								 	)
join e
	where  e.encntr_id = o.encntr_id
	and    e.encntr_id != 0.0
	and    e.loc_facility_cd > 0.0
join ea
	where  ea.encntr_id = e.encntr_id
	and    ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and    ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	and    ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and    ea.active_ind = 1
join p
	where  p.person_id = e.person_id
    and    p.active_ind = 1
join p1
    where  p1.person_id = oa.action_personnel_id
join p2
    where  p2.person_id = oa.order_provider_id
order by
	o.order_id
head report
	t_rec->cnt = 0
head o.order_id
	t_rec->cnt = (t_rec->cnt + 1)
	if(mod(t_rec->cnt,10000) = 1)
		stat = alterlist(t_rec->qual, t_rec->cnt +9999)
	endif
	t_rec->qual[t_rec->cnt].order_id						= o.order_id
	t_rec->qual[t_rec->cnt].person_id						= o.person_id
	t_rec->qual[t_rec->cnt].encntr_id						= o.encntr_id
	t_rec->qual[t_rec->cnt].orig_order_dt_tm				= o.orig_order_dt_tm
	t_rec->qual[t_rec->cnt].activity_type_cd				= o.activity_type_cd
	t_rec->qual[t_rec->cnt].catalog_type_cd					= o.catalog_type_cd
	t_rec->qual[t_rec->cnt].communication_type_cd			= oa.communication_type_cd
	t_rec->qual[t_rec->cnt].loc_nurse_unit_cd				= e.loc_nurse_unit_cd
	t_rec->qual[t_rec->cnt].loc_facility_cd					= e.loc_facility_cd
	
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
 
