/**************************************************************************************
  *                                                                                   *
  *  Copyright Notice:  (c) 1983 Laboratory Information Systems &                     *
  *                              Technology, Inc.                                     *
  *       Revision      (c) 1984-1997 Cerner Corporation                              *
  *                                                                                   *
  *  Cerner (R) Proprietary Rights Notice:  All rights reserved.                      *
  *  This material contains the valuable properties and trade secrets of              *
  *  Cerner Corporation of Kansas City, Missouri, United States of                    *
  *  America (Cerner), embodying substantial creative efforts and                     *
  *  confidential information, ideas and expressions, no part of which                *
  *  may be reproduced or transmitted in any form or by any means, or                 *
  *  retained in any storage or retrieval system without the express                  *
  *  written permission of Cerner.                                                    *
  *                                                                                   *
  *  Cerner is a registered mark of Cerner Corporation.                               *
  *                                                                                   *
  *************************************************************************************/
/**************************************************************************************
 
        Source file name:                   chs_tn_cust_col_renewal_req.prg
        Object name:                        chs_tn_cust_col_renewal_req
 
        Program purpose:                    Script used to gather nursing documentation information for MEDC_DE
 
        Tables read:						PATHWAY_CATALOG,
        									PATHWAY
 
        Tables updated:                     None
 
        Executing from:                     PowerChart
 
        Special Notes:
 
/***********************************************************************************************************************************
* Mod Date       Engineer  CR            Comments                                                                                  *
* --- ---------- --------  ------------  ----------------------------------------------------------------------------------------- *
* 000 08/02/2016 BP025585  1-11053620131 Initial release
* 000 01/28/2018 AD053957  1-11053620131 Renewal Column                                                                          *
***********************************************************************************************************************************/
drop program 1chs_tn_cust_col_renewal_req:dba go
create program 1chs_tn_cust_col_renewal_req:dba
 
Prompt "Output device:" = "MINE"
      ,"PersonId:" = 0.0
with OUTDEV,PERSONID
 
 
/* Renewal Custom Column worklist */
/***********************************************************************************************************************************
* Record Structures                                                                                                                *
***********************************************************************************************************************************/
/* The reply record must be declared by the consuming script, with the appropriate person details available. */
 
 
free record reply
record reply (
  1 person[*]
    2 person_id = f8
    2 encntr_id = f8
    2 ppr_cd = f8
    2 count = i4
    2 icon = vc
    2 contents[*]
      3 primary = vc
      3 secondary = vc
%i cclsource:status_block.inc
) with protect
 
/***********************************************************************************************************************************
* Subroutines                                                                                                                      *
***********************************************************************************************************************************/
declare PUBLIC::Main(null) = null with private
declare PUBLIC::DetermineRenewalRequest(null) = null with protect
/***********************************************************************************************************************************
* Main PROGRAM *********************************************************************************************************************
***********************************************************************************************************************************/
call Main(null)
/***********************************************************************************************************************************
* SUBROUTINES **********************************************************************************************************************
***********************************************************************************************************************************/
 
/***********************************************************************************************************************************
* Main                                                                                                                             *
**********************************************************************************************************************************/
 
/*
Main subroutine.
@param null
@returns null
*/
subroutine PUBLIC::Main(null)
  set stat = alterlist(reply->person,1)
  set reply->person[1].person_id= 12735239.00
  call DetermineRenewalRequest(null)
  set reply->status_data.status = "S"
end ; Main
 
/***********************************************************************************************************************************
* DetermineRenewalRequest                                                                                                          *
**********************************************************************************************************************************/
subroutine PUBLIC::DetermineRenewalRequest(null)
 
  declare PERSON_CNT = i4 with protect, constant(SIZE(reply->person, 5))
  declare NOW_DTTM = dq8 with protect, constant(CNVTDATETIME(curdate, curtime3))
  declare exp_idx = i4 with protect, noconstant(0)
  declare loc_idx = i4 with protect, noconstant(0)
  ;declare initiated_cd = f8 with protect,constant(uar_get_code_by("CDF_MEANING",674356,"INITIATED"))
  ;declare completed_cd = f8 with protect,constant(uar_get_code_by("CDF_MEANING",10740,"COMPLETED"))
 
SELECT into "nl:"
 
	FROM PATHWAY_CATALOG pc
	 	,PATHWAY p
 
	plan pc
		where PC.DESCRIPTION_KEY = "RESTRAINT INITIATE NON-VIOLENT"
	join p
		where p.pathway_catalog_id = pc.pathway_catalog_id
		and EXPAND(exp_idx, 1, PERSON_CNT, p.person_id, reply->person[exp_idx].person_id)
 
	order by p.person_id
 
	head report
      	person_idx = 0
      	no_of_hours = 0
 		;content_idx = 0
 
	head p.person_id
	  	person_idx = LOCATEVAL(loc_idx, 1, PERSON_CNT, p.person_id, reply->person[loc_idx].person_id)
	  	no_of_hours= DATETIMEDIFF(NOW_DTTM,p.order_dt_tm,3)
 
 			stat = alterlist(reply->person[person_idx].contents,1)
 
 			;if(p.pw_status_cd = initiated_cd OR completed_cd)
				if(no_of_hours> 200)
					;content_idx = content_idx + 1
					;if(MOD(content_idx,10) =1 AND content_idx + 9)
 	   					reply->person[person_idx].contents[1].primary = "Yes"
 			 		;endif
 				elseif(no_of_hours<200)
 					;if(MOD(content_idx,10) =1 AND content_idx + 9)
 					reply->person[person_idx].contents[1].primary = "No"
 					;endif
 				else
 					reply->person[person_idx].contents[1].primary = ""
    			endif
    		;else
    				;reply->person[person_idx].contents[content_idx].primary = "test2"
    		;endif
	foot p.person_id
		null
	with nocounter
end ; DetermineRenewalRequest
 
/***********************************************************************************************************************************
* EXIT PROGRAM *********************************************************************************************************************
***********************************************************************************************************************************/
#EXIT_SCRIPT
 
if (reqdata->loglevel >= 4 or VALIDATE(debug_ind, 0) > 0)
  call echorecord(reply)
endif
 
end
go
 
 
