drop program dup_hp_r_cleanup_all:dba go
create program dup_hp_r_cleanup_all:dba
 
/****************************************************************************
 *                                                                          *
 *  Copyright Noties:  (c) 1983 Laboratory Information Systems &            *
 *                              Technology, Inc.                            *
 *       Revision      (c) 1984-1997 Cerner Corporation                     *
 *                                                                          *
 *  Cerner (R) Proprietary Rights Noties:  All rights reserved.             *
 *  This material contains the valuable properties and trade secrets of     *
 *  Cerner Corporation of Kansas City, Missouri, United States of           *
 *  America (Cerner), embodying substantial creative efforts and            *
 *  confidential information, ideas and expressions, no part of which       *
 *  may be reproduesd or transmitted in any form or by any means, or        *
 *  retained in any storage or retrieval system without the express         *
 *  written permission of Cerner.                                           *
 *                                                                          *
 *  Cerner is a registered mark of Cerner Corporation.                      *
 *                                                                          *
 *                                                                          *
 ****************************************************************************
 
          Date Written:       06/05/2018
          Soures file name:   dup_hp_r_cleanup_all.prg
          Object name:        dup_hp_r_cleanup_all
          Request #:

 
          Program purpose:    Cleanup for Duplicate Person_plan_reltn for RevenueCycle.exe
 
          Tables read:        person_plan_reltn
          Tables updated:     person_plan_reltn
 
 ***********************************************************************
 *                  GENERATED MODIFICATION CONTROL LOG                 *
 ***********************************************************************
 *                                                                     *
 *  Mod    Date     Engineer             Comment                       *
 *-------  -------- -------------------- ------------------------------*
     00   06/11/2018 Jesse Jacobsen       Initial release
     01	  07/05/2018 Jesse Jacobsen       Removal of Effective qualification
     02   07/06/2018 Jesse Jacobsen       Check against other removed plans
 ***********************************************************************
 ******************  END OF ALL MODCONTROL BLOCKS  ********************/

/***********************************************************************************
Initialize
************************************************************************************/

  if (validate(bDebugMe, -9) = -9)
     declare bDebugMe = i2 with noconstant(FALSE)
  endif
 
  ;Variables
  declare lCnt              = i4 with noconstant(0)
  declare lTotal            = i4 with noconstant(0)
  ;Get Subscriber code value
	declare dSubscriberCd = f8 with noconstant(0.0),protect
	set stat = uar_get_meaning_by_codeset(353, "SUBSCRIBER", 1, dSubscriberCd)
  set inactive = uar_get_code_by("MEANING",48,"INACTIVE")
 
if(bDebugMe = TRUE)
  call echo(build("Subscriber Code = ", dSubscriberCd))
  call echo(build("Inactive Code = ", inactive))
endif

 ;Record structure for data
  free record recData
  record recData
  ( 1 person_plan_reltn[*]
      2 ppr1_id = f8
      2 ppr1_updt_cnt = f8
      2 ppr2_id = f8
      2 ppr2_beg_dt_tm = dq8
      2 ppr2_end_dt_tm = dq8
      2 ppr3_id = f8
      2 keep_beg_dt_tm = dq8
      2 person_id = f8
  )


/*BEGIN: person_plan_reltn***********************************/
set lCnt = 0

select into "nl:"
	ppr1.person_plan_reltn_id
from 
  person_plan_reltn ppr1, 
  person_plan_reltn ppr2,
  health_plan hp,
  organization o
plan hp where hp.active_ind = 1
  and hp.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
  and hp.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
join ppr1 where hp.health_plan_id = ppr1.health_plan_id
  and ppr1.subscriber_person_id = 0.00
  and ppr1.person_plan_r_cd = dSubscriberCd
  and ppr1.active_ind = 1
/* For individual Patient testing */
; and ppr1.person_id = 7635102.00

/* Mod 01 - Removal of effective qualification to prevent further Illegal Argument Errors
;  and ppr1.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
;  and ppr1.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
*/
join ppr2 where ppr2.person_id = ppr1.person_id
  and ppr2.health_plan_id = ppr1.health_plan_id
  and ppr2.sponsor_person_org_reltn_id = ppr1.sponsor_person_org_reltn_id
  and ppr2.person_plan_reltn_id != ppr1.person_plan_reltn_id
/*Mod 02 - Need to check against other duplicates in case they try to readd from elligible plans
;  and ppr2.subscriber_person_id = ppr1.person_id
*/
  and ppr2.person_plan_r_cd = dSubscriberCd
  and ppr2.active_ind = 1
join o where o.organization_id = ppr1.organization_id
  and o.active_ind = 1
  and o.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
  and o.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
order by ppr1.person_plan_reltn_id, ppr2.end_effective_dt_tm desc
  detail
  	sGroupName1 = nullterm(ppr1.group_name)
  	sGropuName2 = nullterm(ppr2.group_name)
  	sGroupNbr1 = nullterm(ppr1.group_nbr)
  	sGropuNbr2 = nullterm(ppr2.group_nbr)  	

  	if(sGroupNbr1 = sGropuNbr2 and sGroupName1 = sGropuName2)
  		lCnt = lCnt + 1
    
        if (mod(lCnt, 100) = 1)
        	stat = alterlist(recData->person_plan_reltn, lCnt + 99)
        endif
  		
  		recData->person_plan_reltn[lCnt]->ppr1_id = ppr1.person_plan_reltn_id
  		recData->person_plan_reltn[lCnt]->ppr1_updt_cnt = ppr1.updt_cnt
  		recData->person_plan_reltn[lCnt]->ppr2_id = ppr2.person_plan_reltn_id
  		recData->person_plan_reltn[lCnt]->ppr2_beg_dt_tm = ppr2.beg_effective_dt_tm
  		recData->person_plan_reltn[lCnt]->ppr2_end_dt_tm = ppr2.end_effective_dt_tm
  	endif
with nocounter, orahintcbo("leading(hp) index(o xpkorganization)")

  set lTotal = lCnt
 
  ;Exit if no results are found
  if (lTotal = 0)
     call echo("*** No person_plan_reltn rows qualified")
     go to 9999_EXIT_PROGRAM
  endif

  ;Trim lists down
  set stat = alterlist(recData->person_plan_reltn, lTotal)

  /*BEGIN: find any active and effective member rows related to our subscriber row**************/
  for(lCnt = 1 to lTotal)
  	/*Only need to look for ones that have just been added and not removed, and don't have another effective row*/
  	if(recData->person_plan_reltn[lCnt]->ppr1_updt_cnt = 0 and
  		recData->person_plan_reltn[lCnt]->ppr2_end_dt_tm < sysdate)

  		select into "nl"
  			ppr3.person_plan_reltn_id
  		from
  			person_plan_reltn ppr1, 
  			person_plan_reltn ppr3
  		plan ppr1 
  			where ppr1.person_plan_reltn_id = recData->person_plan_reltn[lCnt]->ppr1_id
  		join ppr3
  			where ppr3.subscriber_person_id = ppr1.person_id
  			  and ppr3.health_plan_id = ppr1.health_plan_id
			  and ppr3.person_plan_r_cd != dSubscriberCd
			  and ppr3.subscriber_person_id != ppr3.person_id
			  and ppr3.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
			  and ppr3.active_ind = 1
		detail
			recData->person_plan_reltn[lCnt]->ppr3_id = ppr3.person_plan_reltn_id
			newDate = datetimeadd(cnvtdatetime(recData->person_plan_reltn[lCnt]->ppr2_end_dt_tm), 1)
			recData->person_plan_reltn[lCnt]->keep_beg_dt_tm = cnvtdatetime(cnvtdate(newDate), 0)
			if (bDebugMe)
   				call echo(build("keep_beg_dt_tm: ", 
   					format(cnvtdatetime(recData->person_plan_reltn[lCnt]->keep_beg_dt_tm), "@SHORTDATETIME")))
			endif
			recData->person_plan_reltn[lCnt]->person_id = ppr1.person_id
		with nocounter

  	endif
  endfor
  /*END: find any active and effective member rows**************/

/*END: person_plan_reltn***********************************/  

/*Update***************************************************/
for(lCnt = 1 to lTotal)
	/*Add person_id to the entries we are keeping so they are visible to end users*/
	if(recData->person_plan_reltn[lCnt]->ppr3_id > 0.00)
		update into person_plan_reltn
		set updt_id = 1,
	        updt_dt_tm = cnvtdatetime (curdate, curtime3),
	        updt_cnt = updt_cnt+1,
	        updt_task = -4961,
	        subscriber_person_id = recData->person_plan_reltn[lCnt]->person_id,
	        beg_effective_dt_tm = cnvtdatetime(recData->person_plan_reltn[lCnt]->keep_beg_dt_tm)
		where person_plan_reltn_id = recData->person_plan_reltn[lCnt]->ppr1_id

	/*Inactivate anything that doesn't have an active/effective member row*/
	else
		update into person_plan_reltn
		set updt_id = 0,
	        updt_dt_tm = cnvtdatetime (curdate, curtime3),
	        updt_cnt = updt_cnt+1,
	        updt_task = -4961,
	        active_ind = 0,
	        active_status_dt_tm = cnvtdatetime (curdate, curtime3),
	        active_status_prsnl_id = 2,
	        active_status_cd = inactive
		where person_plan_reltn_id = recData->person_plan_reltn[lCnt]->ppr1_id
	endif

	if (bDebugMe = FALSE)
        commit
    else
        rollback
    endif
endfor
/*END: Update**********************************************/

/*END Program steps****************************************/
#9999_EXIT_PROGRAM 
if (bDebugMe)
   call echo(build("Number of person_plan_reltn rows qualified: ", lTotal))
;     call echorecord(recData)
endif

/*END*/


if (validate(request->batch_selection) = 1)
	set reply->status_data.status = "S"
endif


end
go