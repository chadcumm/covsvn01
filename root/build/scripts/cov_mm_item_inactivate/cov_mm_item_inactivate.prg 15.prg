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
	1 error_msg			= vc
	1 error_ind			= i2
	1 qual[*]
	 2 row				= vc
	 2 step_id			= i2
	 2 item_alias 		= vc
	 2 description		= vc
	 2 item_id			= f8
	 2 surgery_loc_flag	= i2
	 2 surgery_loc[*]
	  3 location_cd		= f8
	 2 pou_loc_flag		= i2
	 2 pou_loc[*]
	  3 location_cd		= f8
	)
endif

record 900005_request (
  1 qual [*]
    2 item_id = f8
  1 root_loc_cd = f8
  1 get_ic_ind = i2
  1 get_st_ind = i2
  1 get_ac_ind = i2
  1 get_qh_ind = i2
  1 get_qr_ind = i2
  1 get_parents_ind = i2
) 

free record 900005_reply
record 900005_reply (
  1 qual [*]  
    2 item_id = f8   
    2 loc_qual [*]  
      3 location_cd = f8   
      3 location_disp = c40   
      3 location_desc = c60   
      3 location_mean = c12   
      3 relationship_type_cd = f8   
      3 relationship_type_disp = c40   
      3 relationship_type_desc = c60   
      3 relationship_type_mean = c12   
      3 parent_qual [*]  
        4 location_cd = f8   
        4 location_disp = c40   
        4 location_desc = c60   
        4 location_mean = c12   
      3 full_path = vc   
      3 short_full_path = vc   
      3 locator_path = vc   
      3 short_locator_path = vc   
  1 status_data   
    2 status = c1   
    2 subeventstatus [1]  
      3 operationname = c25   
      3 operationstatus = c1   
      3 targetobjectname = c25   
      3 targetobjectvalue = vc   
)

 



set t_rec->filename = "ccluserdir:cov_mm_item_inactivate.csv"

call addEmailLog("chad.cummings@covhlth.com")

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Reading In File (0) ********************************"))

call writeLog(build2("** t_rec->filename = ",t_rec->filename))
set ffrec->file_name = t_rec->filename
set ffrec->file_buf = "r" 
set stat = cclio("OPEN",ffrec)
set ffrec->file_buf = notrim(fillstring(300," "))
if (ffrec->file_desc != 0)
	set stat = 1
	while (stat > 0)
		set stat = cclio("GETS",ffrec)
		if (stat > 0)
			set pos = findstring(char(0),ffrec->file_buf)
			set pos = evaluate(pos,0,size(ffrec->file_buf),pos)
			if (substring(1,pos,trim(ffrec->file_buf)) > " ")
				set t_rec->cnt = (t_rec->cnt + 1)
				set stat = alterlist(t_rec->qual,t_rec->cnt)
				set t_rec->qual[t_rec->cnt].row = substring(1,pos,trim(ffrec->file_buf))
				call writeLog(build2("--->buf=",trim(ffrec->file_buf),"<---"))
			endif
		endif
       endwhile
       set stat = cclio("close",ffrec)
endif

call writeLog(build2("* END   Reading In File ************************************"))
call writeLog(build2("************************************************************"))

if (t_rec->cnt = 0)
	set t_rec->error_ind 	= 1
	set t_rec->error_msg	= build2("Records or Incorrect File Format in ",t_rec->filename)
 	go to exit_script
endif

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Splitting Input (1) ********************************"))

for (i = 1 to t_rec->cnt)
	set t_rec->qual[i].item_alias 	= piece(t_rec->qual[i].row,",",1,"MISSING",2)
	set t_rec->qual[i].description 	= piece(t_rec->qual[i].row,",",2,"MISSING",2)
	set t_rec->qual[i].step_id		= 1
endfor

call writeLog(build2("* END   Splitting Input ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Item IDs (2) *******************************"))

select into "nl:"
from 
	 object_identifier_index oii
	,(dummyt d1 with seq = value(t_rec->cnt))
plan d1
join oii
	where 	oii.value_key 				= t_rec->qual[d1.seq].item_alias
	and	  	oii.identifier_type_cd		= value(uar_get_code_by("MEANING",11000,"ITEM_NBR"))
	and		oii.object_type_cd			= value(uar_get_code_by("MEANING",11001,"ITEM_MASTER"))
	and	    oii.active_ind 				= 1
order by
	oii.object_id
head oii.object_id
	t_rec->qual[d1.seq].item_id			= oii.object_id
	t_rec->qual[d1.seq].step_id			= 2
with nocounter

call writeLog(build2("* END   FInding Item IDs ***********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Surgery Locations (3) **********************"))

for (i = 1 to t_rec->cnt)
	if (t_rec->qual[i].item_id > 0.0)
		set stat = initrec(900005_request)
		set stat = initrec(900005_reply)
		
		set stat = tdbexecute(900000, 900128, 900005, "REC", 900005_request, "REC", 900005_reply)
	endif
endfor

call writeLog(build2("* END   Finding Surgery Locations **************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Splitting Input ************************************"))
call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

#exit_script

if (t_rec->error_ind = 1)
	call writeLog(build2("ERROR:", t_rec->error_msg))
endif

call exitScript(null)
call echorecord(t_rec)
call echorecord(code_values)
call echorecord(program_log)


end
go
