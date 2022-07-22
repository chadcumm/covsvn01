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
        Object name:            cov_mm_item_inactivate

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
	"Output to File/Printer/MINE" = "MINE"
	, "Filename" = "cov_mm_item_inactivate.csv"     ;* Name of file in CCLUSERDIR
	, "Test Mode [ (N)o, (Y)es - Default ]" = "Y"

with OUTDEV, FILENAME, TEST_MODE


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
	1 filename_no_path	= vc
	1 cnt				= i4
	1 error_msg			= vc
	1 error_ind			= i2
	1 surgery_loc_cd	= f8
	1 pou_loc_cd		= f8
	1 inactive_cd		= f8
	1 active_cd			= f8
	1 identifier_type_cd = f8
	1 object_type_cd	= f8
	1 test_mode			= i2
	1 qual[*]
	 2 error_status		= vc
	 2 row				= vc
	 2 item_alias 		= vc
	 2 description		= vc
	 2 item_description	= vc
	 2 updated_desc		= vc
	 2 item_id			= f8
	 2 pref_card_ind	= i2
	 2 updt_cnt			= i4
	 2 surgery_loc_flag	= i2
	 2 surgery_loc[*]
	  3 location_cd		= f8
	  3 location_disp 	= vc
	  3 updt_status		= c1
	 2 pou_loc_flag		= i2
	 2 pou_loc[*]
	  3 location_cd		= f8
	  3 location_disp	= vc
	  3 updt_status		= c1
	 2 identifier_cnt	= i2
	 2 identifiers[*]
	  3 identifier_id	= f8
	  3 primary_ind		= i2
	  3 type_mean		= vc
	  3 value			= vc
	  3 type_cd			= f8
	  3 updt_cnt		= i2
	 2 step_id			= i2
	 2 step_cnt			= i2
	 2 step_log[*]
	  3 step_title 		= vc
	  3 step_message	= vc
	  3 step_status		= c1
	1 audit_cnt			= i2
	1 audit[*]
	 2 title			= vc
	 2 found_ind		= i2
	)
endif

%i cust_script:cov_mm_item_inactivate_req.inc

set t_rec->filename 		= concat("ccluserdir:",$FILENAME)
set t_rec->filename_no_path = $FILENAME

call addEmailLog("chad.cummings@covhlth.com")

select into "nl:"
from
	code_value cv
plan cv
	where cv.code_set		= 220
	and	  cv.active_ind 	= 1
	and   cv.cdf_meaning 	= "INVVIEW"
	and	  cv.display		in("Point of Use","Surgery")
order by
	 cv.code_value
	,cv.begin_effective_dt_tm desc
head cv.code_value
	case (cv.display)
		of "Surgery": 		t_rec->surgery_loc_cd	= cv.code_value
		of "Point of Use":	t_rec->pou_loc_cd		= cv.code_value
	endcase
with nocounter

set t_rec->inactive_cd 				= uar_get_code_by("MEANING",48,"INACTIVE")
set t_rec->active_cd 				= uar_get_code_by("MEANING",48,"ACTIVE")
set t_rec->identifier_type_cd		= value(uar_get_code_by("MEANING",11000,"ITEM_NBR"))
set t_rec->object_type_cd			= value(uar_get_code_by("MEANING",11001,"ITEM_MASTER"))

set t_rec->test_mode = 1

if ($TEST_MODE = "N")
	set t_rec->test_mode = 0
endif

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

	set t_rec->qual[i].step_cnt		= (t_rec->qual[i].step_cnt + 1)
	set stat = alterlist(t_rec->qual[i].step_log,t_rec->qual[i].step_cnt)
	set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_title 		= "ROW_PARSE"
	set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_message 		= "File row was split properly"
	set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_status		= "S"
endfor

call writeLog(build2("* END   Splitting Input ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Item IDs (2) *******************************"))
/*
select into "nl:"
from
	 object_identifier_index oii
	,(dummyt d1 with seq = value(t_rec->cnt))
plan d1
join oii
	where 	oii.value_key 				= t_rec->qual[d1.seq].item_alias
	and	  	oii.identifier_type_cd		= t_rec->identifier_type_cd ;value(uar_get_code_by("MEANING",11000,"ITEM_NBR"))
	and		oii.object_type_cd			= t_rec->object_type_cd ;value(uar_get_code_by("MEANING",11001,"ITEM_MASTER"))
	and	    oii.active_ind 				= 1
order by
	oii.object_id
head oii.object_id
	t_rec->qual[d1.seq].item_id			= oii.object_id
	t_rec->qual[d1.seq].step_id			= 2
with nocounter
*/

for (i = 1 to t_rec->cnt)
	call writeLog(build2("**Calling 900060_request for ",trim(cnvtstring(t_rec->qual[i].item_alias)),":",
			trim(cnvtstring(t_rec->qual[i].item_id))))
	set stat = initrec(900060_request)
	set stat = initrec(900060_reply)
	set cnt  = 0
	set 900060_request->maxrec									= 1
	set 900060_request->search_type_flag 						= 0
	set 900060_request->start_value		 						= t_rec->qual[i].item_alias
	set stat = alterlist(900060_request->obj_type_qual,1)
	set 900060_request->obj_type_qual[1].obj_type_cd 			= t_rec->object_type_cd
	set 900060_request->obj_type_qual[1].obj_type_mean 			= "ITEM_MASTER"
	set stat = alterlist(900060_request->filter_qual,1)
	set 900060_request->filter_qual[1].identifier_type_mean 	= "ITEM_NBR"
	set 900060_request->filter_qual[1].identifier_type_cd 		= t_rec->identifier_type_cd
	set stat = alterlist(900060_request->active_status_qual,1)
	set 900060_request->active_status_qual[1].active_status_cd  = t_rec->active_cd

	set stat = tdbexecute(900055, 900060, 900060, "REC", 900060_request, "REC", 900060_reply)
	call writeLog(build2("--->900060_reply->status_data.status=",900060_reply->status_data.status))
	if (900060_reply->status_data.status = "S")
		if (size(900060_reply->qual,5) > 1)
			set t_rec->qual[i].step_cnt		= (t_rec->qual[i].step_cnt + 1)
			set stat = alterlist(t_rec->qual[i].step_log,t_rec->qual[i].step_cnt)
			set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_title 		= "ITEM_ID"
			set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_message 		= "More than one ITEM_ID for identifier found"
			set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_status		= "F"
		elseif (size(900060_reply->qual,5) < 1)
			set t_rec->qual[i].step_cnt		= (t_rec->qual[i].step_cnt + 1)
			set stat = alterlist(t_rec->qual[i].step_log,t_rec->qual[i].step_cnt)
			set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_title 		= "ITEM_ID"
			set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_message 		= "No ITEM_ID for identifier found"
			set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_status		= "F"
		else
			set t_rec->qual[i].item_id			= 900060_reply->qual[1].item_id
			set t_rec->qual[i].item_description = 900060_reply->qual[1].description
			set t_rec->qual[i].step_id			= 2
			set t_rec->qual[i].step_cnt		= (t_rec->qual[i].step_cnt + 1)
			set stat = alterlist(t_rec->qual[i].step_log,t_rec->qual[i].step_cnt)
			set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_title 		= "ITEM_ID"
			set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_message 		= "ITEM_ID Found"
			set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_status		= "S"
		endif

	elseif (900060_reply->status_data.status = "Z")
		set t_rec->qual[i].step_cnt		= (t_rec->qual[i].step_cnt + 1)
		set stat = alterlist(t_rec->qual[i].step_log,t_rec->qual[i].step_cnt)
		set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_title 		= "ITEM_ID"
		set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_message 		= "No ITEM_ID for identifier found"
		set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_status		= "F"
	else
		set t_rec->qual[i].step_cnt		= (t_rec->qual[i].step_cnt + 1)
		set stat = alterlist(t_rec->qual[i].step_log,t_rec->qual[i].step_cnt)
		set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_title 		= "ITEM_ID"
		set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_message 		= "No ITEM_ID for identifier found"
		set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_status		= "F"
	endif
endfor

call writeLog(build2("* END   FInding Item IDs ***********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Checking Pref Cards (2b) ***************************"))

for (i = 1 to t_rec->cnt)
	if (t_rec->qual[i].item_id > 0.0)
		select into "nl:"
		from
			 item_master im
			,pref_card_pick_list ccpl
			,preference_card sc
			,package_type pt
		plan im
			where im.item_id = t_rec->qual[i].item_id
		join ccpl
			where ccpl.item_id = im.item_id
			and   ccpl.active_ind = 1
		join sc
			where sc.pref_card_id = ccpl.pref_card_id
		join pt
			where pt.item_id = im.item_id
			and   pt.base_package_type_ind = 1
		order by im.item_id,sc.surg_area_cd
		head report
			cnt = 0
			disp_line = ""
		head im.item_id
			cnt = 0
			disp_line = ""
		head sc.surg_area_cd
			disp_line = trim(concat(disp_line,trim(uar_get_code_display(sc.surg_area_cd)),";"))
		detail
			cnt = (cnt + 1)
		foot report
			if (cnt = 0)
				t_rec->qual[i].step_cnt		= (t_rec->qual[i].step_cnt + 1)
				stat = alterlist(t_rec->qual[i].step_log,t_rec->qual[i].step_cnt)
				t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_title 		= "PREF_CARD"
				t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_message 		= "Item not found on Preference Card"
				t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_status		= "S"
			else
				t_rec->qual[i].pref_card_ind = 1
				t_rec->qual[i].step_cnt		= (t_rec->qual[i].step_cnt + 1)
				stat = alterlist(t_rec->qual[i].step_log,t_rec->qual[i].step_cnt)
				t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_title 		= "PREF_CARD"
				t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_message 		= concat("Item found on Preference Cards:",
					;trim(cnvtstring(cnt)))
					trim(disp_line))
				t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_status		= "F"
			endif
		with nocounter,nullreport
	endif	
endfor

call writeLog(build2("* END   Checking Pref Cards ********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Surgery Locations (3) **********************"))

for (i = 1 to t_rec->cnt)
	if ((t_rec->qual[i].item_id > 0.0) and (t_rec->qual[i].pref_card_ind = 0))
		set stat = initrec(900005_request)
		set stat = initrec(900005_reply)
		set cnt  = 0

		set stat = alterlist(900005_request->qual,1)
		set 900005_request->qual[1].item_id 	= t_rec->qual[i].item_id
		set 900005_request->root_loc_cd 		= t_rec->surgery_loc_cd
		set 900005_request->get_ic_ind			= 1
		call writeLog(build2("**Calling 900005_request for ",trim(cnvtstring(t_rec->qual[i].item_alias)),":",
			trim(cnvtstring(t_rec->qual[i].item_id))))
		set stat = tdbexecute(900000, 900128, 900005, "REC", 900005_request, "REC", 900005_reply)

		call writeLog(build2("--->900005_reply->status_data.status=",900005_reply->status_data.status))
		if (900005_reply->status_data.status = "S")

			for (j = 1 to size(900005_reply->qual,5))
				call writeLog(build2("--->900005_reply->qual[",trim(cnvtstring(j)),"].item_id=",
									  trim(cnvtstring(900005_reply->qual[j].item_id))))
				for (k = 1 to size(900005_reply->qual[j].loc_qual,5))
					call writeLog(build2("--->900005_reply->qual[",trim(cnvtstring(j)),"].loc_qual[",
										  trim(cnvtstring(k)),"].location_cd=",900005_reply->qual[j].loc_qual[k].location_cd,":",
										  900005_reply->qual[j].loc_qual[k].location_disp))
					set cnt = (cnt + 1)
					set stat = alterlist(t_rec->qual[i].surgery_loc,cnt)
					set t_rec->qual[i].surgery_loc[cnt].location_cd 	= 900005_reply->qual[j].loc_qual[k].location_cd
					set t_rec->qual[i].surgery_loc[cnt].location_disp 	= 900005_reply->qual[j].loc_qual[k].location_disp
				endfor
			endfor
			set t_rec->qual[i].surgery_loc_flag = 2; locations found
			set t_rec->qual[i].step_id	= 3
			set t_rec->qual[i].step_cnt		= (t_rec->qual[i].step_cnt + 1)
			set stat = alterlist(t_rec->qual[i].step_log,t_rec->qual[i].step_cnt)
			set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_title 		= "SURG_LOC"
			set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_message
				= concat("Surgery Locations Found:",cnvtstring(size(t_rec->qual[i].surgery_loc,5)))
			set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_status		= "S"
		elseif (900005_reply->status_data.status = "Z")
			set t_rec->qual[i].surgery_loc_flag = 1; none found
			set t_rec->qual[i].step_cnt		= (t_rec->qual[i].step_cnt + 1)
			set stat = alterlist(t_rec->qual[i].step_log,t_rec->qual[i].step_cnt)
			set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_title 		= "SURG_LOC"
			set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_message 		= "No Surgery Locations Found"
			set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_status		= "Z"
		endif
	endif
endfor

call writeLog(build2("* END   Finding Surgery Locations **************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding POU Locations (4) **************************"))

for (i = 1 to t_rec->cnt)
	if ((t_rec->qual[i].item_id > 0.0) and (t_rec->qual[i].pref_card_ind = 0))
		set stat = initrec(900005_request)
		set stat = initrec(900005_reply)
		set cnt  = 0

		set stat = alterlist(900005_request->qual,1)
		set 900005_request->qual[1].item_id 	= t_rec->qual[i].item_id
		set 900005_request->root_loc_cd 		= t_rec->pou_loc_cd
		set 900005_request->get_ic_ind			= 1

		call writeLog(build2("**Calling 900005_request for ",trim(cnvtstring(t_rec->qual[i].item_alias)),":",
			trim(cnvtstring(t_rec->qual[i].item_id))))

		set stat = tdbexecute(900000, 900128, 900005, "REC", 900005_request, "REC", 900005_reply)

		call writeLog(build2("--->",900005_reply->status_data.status))
		if (900005_reply->status_data.status = "S")

			for (j = 1 to size(900005_reply->qual,5))
				call writeLog(build2("--->900005_reply->qual[",trim(cnvtstring(j)),"].item_id=",
									  trim(cnvtstring(900005_reply->qual[j].item_id))))
				for (k = 1 to size(900005_reply->qual[j].loc_qual,5))
					call writeLog(build2("--->900005_reply->qual[",trim(cnvtstring(j)),"].loc_qual[",
										  trim(cnvtstring(k)),"].location_cd=",900005_reply->qual[j].loc_qual[k].location_cd,":",
										  900005_reply->qual[j].loc_qual[k].location_disp))
					set cnt = (cnt + 1)
					set stat = alterlist(t_rec->qual[i].pou_loc,cnt)
					set t_rec->qual[i].pou_loc[cnt].location_cd 	= 900005_reply->qual[j].loc_qual[k].location_cd
					set t_rec->qual[i].pou_loc[cnt].location_disp 	= 900005_reply->qual[j].loc_qual[k].location_disp
				endfor
			endfor
			set t_rec->qual[i].step_id	= 4
			set t_rec->qual[i].pou_loc_flag = 2; locations found
			set t_rec->qual[i].step_cnt		= (t_rec->qual[i].step_cnt + 1)
			set stat = alterlist(t_rec->qual[i].step_log,t_rec->qual[i].step_cnt)
  			set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_title 		= "POU_LOC"
			set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_message
				= concat("POU Locations Found:",cnvtstring(size(t_rec->qual[i].pou_loc,5)))
			set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_status		= "S"
		elseif (900005_reply->status_data.status = "Z")
			set t_rec->qual[i].pou_loc_flag = 1; none found
			set t_rec->qual[i].step_cnt		= (t_rec->qual[i].step_cnt + 1)
			set stat = alterlist(t_rec->qual[i].step_log,t_rec->qual[i].step_cnt)
			set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_title 		= "POU_LOC"
			set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_message 		= "No POU Locations Found"
			set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_status		= "Z"
		endif
	endif
endfor

call writeLog(build2("* END   Finding POU  Locations *****************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Removing Surgery Locations (5) *********************"))
for (i = 1 to t_rec->cnt)
	if ((t_rec->qual[i].item_id > 0.0) and (t_rec->qual[i].pref_card_ind = 0))
		call writeLog(build2("****Checking Surgery Locations for ",trim(t_rec->qual[i].item_alias),":",
				trim(cnvtstring(t_rec->qual[i].item_id))))
		call writeLog(build2("--->item_id=",trim(cnvtstring(t_rec->qual[i].item_id)),":step_id=",
				trim(cnvtstring(t_rec->qual[i].step_id))))
		if ((t_rec->qual[i].item_id > 0.0) and  (t_rec->qual[i].step_id	in(3,4)))
			call writeLog(build2("----->Item passed step 3/4 ",trim(t_rec->qual[i].item_alias),":",
				trim(cnvtstring(t_rec->qual[i].item_id))))
			if ((t_rec->qual[i].surgery_loc_flag = 2) and (size(t_rec->qual[i].surgery_loc,5) > 0))
				call writeLog(build2("-------->surgery_loc_flag=",trim(cnvtstring(t_rec->qual[i].surgery_loc_flag))
					,":size(t_rec->qual[i].surgery_loc,5)=",trim(cnvtstring(size(t_rec->qual[i].surgery_loc,5)))))
				set stat = initrec(900067_request)
				set stat = initrec(900067_reply)
				set cnt  = 0

				for (j = 1 to size(t_rec->qual[i].surgery_loc,5))
					set cnt = (cnt + 1)
					set stat = alterlist(900067_request->qual,cnt)
					set 900067_request->qual[cnt].item_id 			= t_rec->qual[i].item_id
					set 900067_request->qual[cnt].ic_location_cd 	= t_rec->qual[i].surgery_loc[j].location_cd
					set 900067_request->qual[cnt].ic_dirty 			= 3
				endfor
				call writeLog(build2("****Calling 900067_request for ",trim(cnvtstring(t_rec->qual[i].item_alias)),":",
				trim(cnvtstring(t_rec->qual[i].item_id))))
				if (t_rec->test_mode = 0)
					set stat = tdbexecute(900002, 900023, 900067, "REC", 900067_request, "REC", 900067_reply)
				else
					call writeLog(build2("****TEST MODE****"))
				endif
				call writeLog(build2("---->900067_reply->status_data.status=",900067_reply->status_data.status))

				if (900067_reply->status_data.status = "S")
					set t_rec->qual[i].surgery_loc_flag = 1
					set t_rec->qual[i].step_cnt		= (t_rec->qual[i].step_cnt + 1)
					set stat = alterlist(t_rec->qual[i].step_log,t_rec->qual[i].step_cnt)
					set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_title 		= "SURG_REMOVE"
					set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_message 		= "Surgery Locations Removed"
					set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_status		= "S"
				else
					set t_rec->qual[i].surgery_loc_flag = 1
					set t_rec->qual[i].step_cnt		= (t_rec->qual[i].step_cnt + 1)
					set stat = alterlist(t_rec->qual[i].step_log,t_rec->qual[i].step_cnt)
					set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_title 		= "SURG_REMOVE"
					set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_message 		= "Surgery Location Removal FAIL"
					set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_status		= "F"
				endif
			endif
		endif
	endif
endfor

call writeLog(build2("* END   Removing Surgery Locations *************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Removing POU Locations (6) *************************"))

for (i = 1 to t_rec->cnt)
	if ((t_rec->qual[i].item_id > 0.0) and (t_rec->qual[i].pref_card_ind = 0))
		call writeLog(build2("****Checkg Locations for ",trim(cnvtstring(t_rec->qual[i].item_alias)),":",
				trim(cnvtstring(t_rec->qual[i].item_id))))
		if ((t_rec->qual[i].item_id > 0.0) and  (t_rec->qual[i].step_id	in(3,4)))
			call writeLog(build2("***Item passed step 3/4 ",trim(cnvtstring(t_rec->qual[i].item_alias)),":",
				trim(cnvtstring(t_rec->qual[i].item_id))))
			if ((t_rec->qual[i].pou_loc_flag = 2) and (size(t_rec->qual[i].pou_loc,5) > 0))
				set stat = initrec(900067_request)
				set stat = initrec(900067_reply)
				set cnt  = 0

				for (j = 1 to size(t_rec->qual[i].pou_loc,5))
					set cnt = (cnt + 1)
					set stat = alterlist(900067_request->qual,cnt)
					set 900067_request->qual[cnt].item_id 			= t_rec->qual[i].item_id
					set 900067_request->qual[cnt].ic_location_cd 	= t_rec->qual[i].pou_loc[j].location_cd
					set 900067_request->qual[cnt].ic_dirty 			= 3
				endfor
				call writeLog(build2("****Calling 900067_request for ",trim(cnvtstring(t_rec->qual[i].item_alias)),":",
				trim(cnvtstring(t_rec->qual[i].item_id))))
				if (t_rec->test_mode = 0)
					set stat = tdbexecute(900002, 900023, 900067, "REC", 900067_request, "REC", 900067_reply)
				else
					call writeLog(build2("****TEST MODE****"))
				endif
				call writeLog(build2("---->900067_reply->status_data.status=",900067_reply->status_data.status))

				if (900067_reply->status_data.status = "S")
					set t_rec->qual[i].pou_loc_flag = 1
					set t_rec->qual[i].step_cnt		= (t_rec->qual[i].step_cnt + 1)
					set stat = alterlist(t_rec->qual[i].step_log,t_rec->qual[i].step_cnt)
					set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_title 		= "POU_REMOVE"
					set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_message 		= "POU Locations Removed"
					set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_status		= "S"
				else
					set t_rec->qual[i].step_cnt		= (t_rec->qual[i].step_cnt + 1)
					set stat = alterlist(t_rec->qual[i].step_log,t_rec->qual[i].step_cnt)
					set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_title 		= "POU_REMOVE"
					set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_message 		= "POU Location Removal Fail"
					set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_status		= "F"
				endif
			endif
		endif
	endif
endfor

call writeLog(build2("* END   Removing POU Locations *****************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Identifiers (7) ****************************"))
for (i = 1 to t_rec->cnt)
	if ((t_rec->qual[i].item_id > 0.0) and (t_rec->qual[i].pref_card_ind = 0))
		set stat = initrec(900128_request)
		set stat = initrec(900128_reply)
		set cnt = 0

		set stat = alterlist(900128_request->qual,1)
		set 900128_request->qual[1].item_id 			= t_rec->qual[i].item_id
		set 900128_request->qual[1].get_all_ids_ind 	= 1

		call writeLog(build2("****Calling 900112_request for ",trim(cnvtstring(t_rec->qual[i].item_alias)),":",
			trim(cnvtstring(t_rec->qual[i].item_id))))
		set stat = tdbexecute(900055, 900128, 900128, "REC", 900128_request, "REC", 900128_reply)
		call writeLog(build2("---->900128_reply->status_data.status=",900128_reply->status_data.status))
		if (900128_reply->status_data.status = "S")
			set t_rec->qual[i].step_id = 7
		    set t_rec->qual[i].step_cnt		= (t_rec->qual[i].step_cnt + 1)
		    set stat = alterlist(t_rec->qual[i].step_log,t_rec->qual[i].step_cnt)
		    set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_title 		= "IDENTIFY"
		    set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_message 		= "Descriptions Found for this Item"
		    set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_status		= "S"
			for (j = 1 to size(900128_reply->qual,5))
				for (k = 1 to size(900128_reply->qual[j].id_qual,5))
					if (900128_reply->qual[j].id_qual[k].id_type_mean in("DESC_SHORT","DESC","DESC_CLINIC"))
						set t_rec->qual[i].identifier_cnt = (t_rec->qual[i].identifier_cnt + 1)
						set stat = alterlist(t_rec->qual[i].identifiers,t_rec->qual[i].identifier_cnt)
						set t_rec->qual[i].identifiers[t_rec->qual[i].identifier_cnt].identifier_id
							= 900128_reply->qual[j].id_qual[k].identifier_id
						set t_rec->qual[i].identifiers[t_rec->qual[i].identifier_cnt].primary_ind
							= 900128_reply->qual[j].id_qual[k].primary_ind
						set t_rec->qual[i].identifiers[t_rec->qual[i].identifier_cnt].type_cd
							= 900128_reply->qual[j].id_qual[k].id_type_cd
						set t_rec->qual[i].identifiers[t_rec->qual[i].identifier_cnt].type_mean
							= 900128_reply->qual[j].id_qual[k].id_type_mean
						set t_rec->qual[i].identifiers[t_rec->qual[i].identifier_cnt].value
							= 900128_reply->qual[j].id_qual[k].value
						set t_rec->qual[i].identifiers[t_rec->qual[i].identifier_cnt].updt_cnt
							= 900128_reply->qual[j].id_qual[k].updt_cnt
					endif
				endfor
			endfor
		else
      		set t_rec->qual[i].step_cnt		= (t_rec->qual[i].step_cnt + 1)
      		set stat = alterlist(t_rec->qual[i].step_log,t_rec->qual[i].step_cnt)
      		set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_title 		= "IDENTIFY"
      		set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_message 		= "No Descriptions Found for Item"
      		set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_status		= "F"
    	endif
	endif
endfor
call writeLog(build2("* END   Finding Identifiers ********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Update Counters (6) ********************************"))

select into "nl:"
from
	 item_definition i
	,(dummyt d1 with seq = value(t_rec->cnt))
plan d1
	where	t_rec->qual[d1.seq].pou_loc_flag 		= 1
	and     t_rec->qual[d1.seq].surgery_loc_flag	= 1
  	and   	t_rec->qual[d1.seq].item_id 			> 0.0
  	and     t_rec->qual[d1.seq].pref_card_ind 		= 0
join i
	where 	i.item_id 					= t_rec->qual[d1.seq].item_id
	and     i.active_ind				= 1
order by
	i.item_id
head i.item_id
	t_rec->qual[d1.seq].updt_cnt		= i.updt_cnt
	t_rec->qual[d1.seq].step_id			= 6
with nocounter

call writeLog(build2("* END   Update Counters ************************************"))
call writeLog(build2("************************************************************"))


call writeLog(build2("************************************************************"))
call writeLog(build2("* START Updating Descriptions (8) **************************"))

for (i = 1 to t_rec->cnt)
	if ((t_rec->qual[i].item_id > 0.0) and (t_rec->qual[i].identifier_cnt > 0))
		set stat = initrec(900128_request)
		set stat = initrec(900128_reply)
		set cnt = 0

		set 900112_request->total_ids_to_chg = t_rec->qual[i].identifier_cnt
		set stat = alterlist(900112_request->chg_id_qual,t_rec->qual[i].identifier_cnt)
		for (j = 1 to t_rec->qual[i].identifier_cnt)
			set 900112_request->chg_id_qual[j].identifier_id = t_rec->qual[i].identifiers[j].identifier_id
			set 900112_request->chg_id_qual[j].primary_ind = t_rec->qual[i].identifiers[j].primary_ind
			set 900112_request->chg_id_qual[j].updt_cnt = t_rec->qual[i].identifiers[j].updt_cnt
			set 900112_request->chg_id_qual[j].value = concat("INACTIVE-",t_rec->qual[i].identifiers[j].value)
			set 900112_request->chg_id_qual[j].object_id = t_rec->qual[i].item_id

			call writeLog(build2("****Calling 900112_request for ",trim(cnvtstring(t_rec->qual[i].item_alias)),":",
				trim(cnvtstring(t_rec->qual[i].item_id))))
			if (t_rec->test_mode = 0)
				set stat = tdbexecute(900055, 900127, 900112, "REC", 900112_request, "REC", 900112_reply)
			else
				call writeLog(build2("****TEST MODE****"))
			endif
			call writeLog(build2("---->900112_reply->status_data.status=",900112_reply->status_data.status))
			if (900112_reply->status_data.status = "S")
				set t_rec->qual[i].step_id = 8
        set t_rec->qual[i].step_cnt		= (t_rec->qual[i].step_cnt + 1)
        set stat = alterlist(t_rec->qual[i].step_log,t_rec->qual[i].step_cnt)
        set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_title 		= "DESC_UPDT"
        set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_message 		= "Descriptions where successfully updated"
        set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_status		= "S"
      else
        set t_rec->qual[i].step_cnt		= (t_rec->qual[i].step_cnt + 1)
        set stat = alterlist(t_rec->qual[i].step_log,t_rec->qual[i].step_cnt)
        set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_title 		= "DESC_UPDT"
        set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_message 		= "Error reported with updating descriptions"
        set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_status		= "F"
      endif
		endfor
	endif
endfor
call writeLog(build2("* END   Updating Descriptions ******************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Finding Updated Descriptipons (8) ******************"))
for (i = 1 to t_rec->cnt)
	if ((t_rec->qual[i].item_id > 0.0) and (t_rec->qual[i].pref_card_ind = 0))
		set stat = initrec(900128_request)
		set stat = initrec(900128_reply)
		set cnt = 0

		set stat = alterlist(900128_request->qual,1)
		set 900128_request->qual[1].item_id 			= t_rec->qual[i].item_id
		set 900128_request->qual[1].get_all_ids_ind 	= 1

		call writeLog(build2("****Calling 900112_request for ",trim(cnvtstring(t_rec->qual[i].item_alias)),":",
			trim(cnvtstring(t_rec->qual[i].item_id))))
		set stat = tdbexecute(900055, 900128, 900128, "REC", 900128_request, "REC", 900128_reply)
		call writeLog(build2("---->900128_reply->status_data.status=",900128_reply->status_data.status))
		if (900128_reply->status_data.status = "S")
			for (j = 1 to size(900128_reply->qual,5))
				for (k = 1 to size(900128_reply->qual[j].id_qual,5))
					if (900128_reply->qual[j].id_qual[k].id_type_mean in("DESC"))
						set t_rec->qual[i].updated_desc= 900128_reply->qual[j].id_qual[k].value
					endif
				endfor
			endfor
			set t_rec->qual[i].step_id = 9
	      	set t_rec->qual[i].step_cnt		= (t_rec->qual[i].step_cnt + 1)
	      	set stat = alterlist(t_rec->qual[i].step_log,t_rec->qual[i].step_cnt)
	      	set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_title 		= "DESC_UPDT1"
	      	set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_message 		= t_rec->qual[i].updated_desc
	      	set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_status		= "S"
			
		else
      		set t_rec->qual[i].step_cnt		= (t_rec->qual[i].step_cnt + 1)
      		set stat = alterlist(t_rec->qual[i].step_log,t_rec->qual[i].step_cnt)
      		set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_title 		= "DESC_UPDT1"
      		set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_message 		= "No Updated Descriptions Found for Item"
      		set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_status		= "F"
    	endif
	endif
endfor
call writeLog(build2("* END   Finding Updated Descriptions ***********************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Inactivating Items (9) *****************************"))

for (i = 1 to t_rec->cnt)
	call writeLog(build2("****Checking Surgery and POU Status for ",trim(cnvtstring(t_rec->qual[i].item_alias)),":",
			trim(cnvtstring(t_rec->qual[i].item_id))))
	if ((t_rec->qual[i].pou_loc_flag = 1) and (t_rec->qual[i].surgery_loc_flag = 1) and (t_rec->qual[i].step_id >= 6)
		 and (t_rec->qual[i].pref_card_ind = 0))
		set stat = initrec(900146_request)
		set stat = initrec(900146_reply)

		set 900146_request->item_type_cd				          = value(uar_get_code_by("MEANING",11001,"ITEM_MASTER"))

		set stat = alterlist(900146_request->qual,1)
		set 900146_request->qual[1].item_id 			         = t_rec->qual[i].item_id
		set 900146_request->qual[1].active_Status_cd 	    = t_rec->inactive_cd
		set 900146_request->qual[1].updt_cnt 			        = t_rec->qual[i].updt_cnt

		call writeLog(build2("****Calling 900146_request for ",trim(cnvtstring(t_rec->qual[i].item_alias)),":",
			trim(cnvtstring(t_rec->qual[i].item_id))))
			if (t_rec->test_mode = 0)
				set stat = tdbexecute(900055, 900127, 900146, "REC", 900146_request, "REC", 900146_reply)
			else
				call writeLog(build2("****TEST MODE****"))
			endif
			call writeLog(build2("---->900146_reply->status_data.status=",900146_reply->status_data.status))
      if (900146_reply->status_data.status = "S")
        set t_rec->qual[i].step_cnt		= (t_rec->qual[i].step_cnt + 1)
        set stat = alterlist(t_rec->qual[i].step_log,t_rec->qual[i].step_cnt)
          set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_title 		= "INACTIVE"
        set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_message 		= "Item was successfully inactivated"
        set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_status		= "S"
      else
        set t_rec->qual[i].step_cnt		= (t_rec->qual[i].step_cnt + 1)
        set stat = alterlist(t_rec->qual[i].step_log,t_rec->qual[i].step_cnt)
        set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_title 		= "INACTIVE"
        set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_message 		= "Error encountered inactivating Item"
        set t_rec->qual[i].step_log[t_rec->qual[i].step_cnt].step_status		= "F"
      endif
	endif
endfor

call writeLog(build2("* END   Inactivating Items *********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Creating Audit File (10) ***************************"))


set t_rec->audit_cnt = 8
set stat = alterlist(t_rec->audit, t_rec->audit_cnt)

set t_rec->audit[1].title	= "SURG_LOC"
set t_rec->audit[2].title	= "POU_LOC"
set t_rec->audit[3].title	= "SURG_REMOVE"
set t_rec->audit[4].title	= "POU_REMOVE"
set t_rec->audit[5].title	= "IDENTIFY"
set t_rec->audit[6].title	= "DESC_UPDT1"
set t_rec->audit[7].title	= "INACTIVE"
set t_rec->audit[8].title	= "PREF_CARD"

set audit_header = concat(
                                char(34),   "ITEM_ALIAS",                 char(34),char(44),
                                char(34),   "ITEM_DESCRIPTION",           char(34),char(44),
                                char(34),   "ITEM_ID",                    char(34),char(44),
                                char(34),   "SURG_LOC",           char(34),char(44),
                                char(34),   "POU_LOC",           char(34),char(44),
                                char(34),   "SURG_REMOVE",           char(34),char(44),
                                char(34),   "POU_REMOVE",           char(34),char(44),
                                char(34),   "IDENTIFY",           char(34),char(44),
                                char(34),   "DESC_UPDT",           char(34),char(44),
                                char(34),   "INACTIVE",           char(34),char(44),
                                char(34),   "PREF_CARD",           char(34),char(44)


                          )

call writeAudit(audit_header)

for (i = 1 to t_rec->cnt)
	set audit_line = ""
	set audit_line = build2(
	 							char(34),   t_rec->qual[i].item_alias,					char(34),char(44),
                                char(34),   t_rec->qual[i].item_description,			char(34),char(44),
                                char(34),   trim(cnvtstring(t_rec->qual[i].item_id)),	char(34),char(44)
	
						)
	for (j = 1 to t_rec->audit_cnt)	
		set t_rec->audit[j].found_ind = 0				
		for (k = 1 to t_rec->qual[i].step_cnt)
			if (t_rec->qual[i].step_log[k].step_title = t_rec->audit[j].title)
				set t_rec->audit[j].found_ind = 1
				set audit_line = build2(
											audit_line,
											char(34),   t_rec->qual[i].step_log[k].step_message,	char(34),char(44)
										)
			endif
		endfor
		if (t_rec->audit[j].found_ind = 0)
			set audit_line = build2(audit_line,char(34),char(34),char(44))
		endif
	endfor
	call writeAudit(audit_line)
endfor


call writeLog(build2("* END   Creating Audit File ********************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Splitting Input ************************************"))
call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

#exit_script

if (t_rec->error_ind = 1)
	call writeLog(build2("ERROR:", t_rec->error_msg))
endif
call echojson(t_rec,"cclscratch:cov_mm_item_inactivate.dat")
call addAttachment(value(program_log->files.file_path),"cov_mm_item_inactivate.dat")
call addAttachment(value(program_log->files.ccluserdir),t_rec->filename_no_path)
call exitScript(null)
;call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)


end
go
