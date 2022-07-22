/*~BB~************************************************************************
      *                                                                      *
      *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
      *                              Technology, Inc.                        *
      *       Revision      (c) 1984-2015 Cerner Corporation                 *
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
 
        Source file name:       ctp_dyn_doc_query_results.prg
        Object name:            ctp_dyn_doc_query_results
 
        Product Team:           Automation
 
        Program purpose:        Micro intpretation query results
 
        Executing from:         ExplorerMenu
 
*/
;~DB~************************************************************************
;    *                      GENERATED MODIFICATION CONTROL LOG              *
;    ************************************************************************
;    *                                                                      *
;    *Mod Date     Engineer             Comment                             *
;    *--- -------- -------------------- ----------------------------------- *
;     000 2/05/16  TB029829             Initial Release                     *
;~DE~************************************************************************
 
drop program ctp_dyn_doc_query_results:dba go
create program ctp_dyn_doc_query_results:dba
 
prompt
  "Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
/************
** Records **
************/
record grid(
    1 row_cnt = i4
    1 row[*]
        2 col_cnt = i4
        2 col[*]
            3 txt = vc
) with protect
 
record file(
    1 file_desc = i4
    1 file_name = vc
    1 file_buf = vc
    1 file_dir = i4
    1 file_offset = i4
) with protect
 
/****************
** Subroutines **
****************/
declare addValueTxt(r = i4, c = i4, txt = vc) = NULL with protect
declare addValueReal(r = i4, c = i4, real = f8) = NULL with protect
declare addValueInt(r = i4, c = i4, int = i4) = NULL with protect
 
/**************
** Variables **
**************/
declare ENQ = vc with protect, constant(char(5))
declare SEP = c1 with protect, constant("|")
declare Q   = c1 with protect, constant(^"^)
declare MAX_COLUMNS = i4 with protect, constant(17) ;<= UPDATE HERE
 
declare r           = i4 with protect, noconstant(0)
declare c           = i4 with protect, noconstant(0)
declare line        = vc with protect, noconstant(" ")
declare parser_cmd  = vc with protect, noconstant(" ")
 
/********************
** Initialize Grid **
********************/
set grid->row_cnt = 1
set stat = alterlist(grid->row,1000)
set stat = alterlist(grid->row[1].col, MAX_COLUMNS)
set cur_col = 1
 
 
/************************
** Smart Details Query **
************************/
 
select into "nl:"
	Smart_Template_Name = st.category_name
	,f.filter_display
	,Filter_Setting =
		if(f.filter_display = "Encounter Retrieval Options" and v.freetext_desc = "1")
			"Current Encounter"
		elseif(f.filter_display = "Encounter Retrieval Options" and v.freetext_desc = "0")
			"All Encounters"
		elseif(f.filter_display = "Clinical Event Display Format" and v.freetext_desc = "1.00")
			"Grid With Borders"
		elseif(f.filter_display = "Clinical Event Display Format" and v.freetext_desc = "2.00")
			"Grid Without Borders"
		elseif(f.filter_display = "Clinical Event Display Format" and v.freetext_desc = "3.00")
			"Horizontal List"
		elseif(f.filter_display = "Clinical Event Display Format" and v.freetext_desc = "4.00")
			"Vertical List"
		elseif(f.filter_display = "Clinical Event Display Format")
			"Grid With Borders"
		elseif(f.filter_display = "Date Time Format" and v.freetext_desc = "1.00")
			"Date"
		elseif(f.filter_display = "Date Time Format" and v.freetext_desc = "2.00")
			"Date and Time"
		elseif(f.filter_display = "Date Time Format" and v.freetext_desc = "3.00")
			"Time Only"
		elseif(f.filter_display = "Date Time Format" and v.freetext_desc = "4.00")
			"No Date or Time"
		elseif(f.filter_display = "Date Time Format")
			"Date and Time"
		elseif(f.filter_display = "Result Retrieval Options" and v.freetext_desc = "0")
			"All Results From Selected Time Frame"
		elseif(f.filter_display = "Result Retrieval Options" and v.freetext_desc = "1")
			"Most Recent Results"
		elseif(f.filter_display = "Result Retrieval Options")
			"All Results From Selected Time Frame"
		elseif(f.filter_display = "Clinical Event #*")
			c.display
		elseif(f.filter_display = "Time Range Options")
			concat(trim(v.mpage_param_value)," ",trim(c.display))
		elseif(f.filter_display = "Clinical Event Header")
			v.freetext_desc
		elseif(f.filter_display = "Result Sorting Options" and v.freetext_desc = "2.00")
			"Sort by ESH Sequencing"
		elseif(f.filter_display = "Result Sorting Options")
			"Sort Alphabetically"
		elseif(f.filter_display = "Qualifying Date Options" and v.freetext_desc = "2.00")
			"Qualify on Clinical Range"
		elseif(f.filter_display = "Qualifying Date Options")
			"Qualify on Posting Range"
		elseif(f.filter_display = "Display Date Options" and v.freetext_desc = "2.00")
			"Display Clinical Range"
		elseif(f.filter_display = "Display Date Options")
			"Display on Posting Range"
		elseif(f.filter_display = "Clinical Event - No Result Message")
			v.freetext_desc
		elseif(f.filter_display = "Result Trending Options")
			concat(trim(v.freetext_desc)," results")
		elseif(f.filter_display = "Event Set #*Header")
			v.freetext_desc
		elseif(f.filter_display = "Event Set #*Column")
			concat(trim(v.freetext_desc)," columns")
		elseif(f.filter_display = "Order Status Options")
			c.display
		elseif(f.filter_display = "IO Count Event Sets")
			c.display
		elseif(f.filter_display = "Report Event Set")
			c.display
		elseif(f.filter_display = "Ordered By Options" and v.freetext_desc = "0")
			"Reports ordered by any user display"
		elseif(f.filter_display = "Ordered By Options" and v.freetext_desc = "1")
			"OnlyrReports ordered by user display"
		elseif(f.filter_display = "Signed By Options" and v.freetext_desc = "0")
			"Do not show signer"
		elseif(f.filter_display = "Signed By Options" and v.freetext_desc = "1")
			"Show signer"
		elseif(f.filter_display = "In Progress Options" and v.freetext_desc = "0")
			"Do not show report in progress"
		elseif(f.filter_display = "In Progress Options" and v.freetext_desc = "1")
			"Show reports in progress"
		elseif(f.filter_display = "Selection*Option")
			v.freetext_desc
		elseif(f.filter_display = "Case Sensitivity Option" and v.freetext_desc = "0")
			"Not case sensitive start/stop"
		elseif(f.filter_display = "Case Sensitivity Option" and v.freetext_desc = "1")
			"Case sensitive start/stop"
		endif
from
	code_value c
	,BR_DATAMART_FILTER   f
	,BR_DATAMART_VALUE   v
	,BR_DATAMART_CATEGORY st
plan st
	where st.category_type_flag = 1
	and st.layout_flag = 2
join f where f.br_datamart_category_id = st.br_datamart_category_id
join v where v.br_datamart_filter_id = f.br_datamart_filter_id
join c where c.code_value = v.parent_entity_id
order by st.category_mean, f.filter_seq
 
head report
 
    ;UPDATE HERE: add column headers
    grid->row[1].col[cur_col].txt = "SMART_TEMPLATE_NAME "
    grid->row[1].col[cur_col + 1].txt = "DISPLAY"
    grid->row[1].col[cur_col + 2].txt = "FILTER_SETTING"
 
    cnt = 1
 
detail
    cnt = cnt + 1
 
    if(cnt > grid->row_cnt and mod(cnt,1000) = 1)
        stat = alterlist(grid->row,cnt + 999)
    endif
 
    if(grid->row[cnt].col_cnt = 0)
        stat = alterlist(grid->row[cnt].col, MAX_COLUMNS)
        grid->row[cnt].col_cnt = MAX_COLUMNS
    endif
 
    ;UPDATE HERE
    call addValueTxt(cnt, cur_col, Smart_Template_Name )
    call addValueTxt(cnt, cur_col + 1, f.filter_display)
    call addValueTxt(cnt, cur_col + 2, Filter_Setting)
 
foot report
    if(cnt > grid->row_cnt)
        grid->row_cnt = cnt
    endif
 
    ;UPDATE HERE: update to reflect number of columns
    cur_col = cur_col + 3
with nocounter
    ,nullreport
 
 
/***********************
** XML Template Query **
***********************/
select into "nl:"
    TEMPLATE_NAME = r.description_txt,
    XML = lb.long_blob
from dd_ref_template r
    ,long_blob_reference lb
plan r where r.description_txt != ""
join lb where lb.long_blob_id = r.long_blob_ref_id
 
 
head report
 
    ;UPDATE HERE: add column headers
    grid->row[1].col[cur_col].txt = "TEMPLATE_NAME"
    grid->row[1].col[cur_col + 1].txt = "XML"
 
    cnt = 1
 
detail
    cnt = cnt + 1
 
    if(cnt > grid->row_cnt and mod(cnt,1000) = 1)
        stat = alterlist(grid->row,cnt + 999)
    endif
 
    if(grid->row[cnt].col_cnt = 0)
        stat = alterlist(grid->row[cnt].col, MAX_COLUMNS)
        grid->row[cnt].col_cnt = MAX_COLUMNS
    endif
 
    ;UPDATE HERE
    call addValueTxt(cnt, cur_col, TEMPLATE_NAME)
    call addValueTxt(cnt, cur_col + 1, check(replace(XML,"<html","<nothtml")))
 
foot report
    if(cnt > grid->row_cnt)
        grid->row_cnt = cnt
    endif
 
    ;UPDATE HERE: update to reflect number of columns
    cur_col = cur_col + 2
with nocounter
    ,nullreport
 
 
/**************
** EMR Query **
**************/
select into "nl:"
    EMR_DESC = emr.description_txt,
    EMR_UUID = emr.ref_content_instance_ident
from dd_ref_emr_content emr
where emr.description_txt != ""
 
 
 
head report
 
    ;UPDATE HERE: add column headers
    grid->row[1].col[cur_col].txt = "EMR_DESC"
    grid->row[1].col[cur_col + 1].txt = "EMR_UUID"
 
    cnt = 1
 
detail
    cnt = cnt + 1
 
    if(cnt > grid->row_cnt and mod(cnt,1000) = 1)
        stat = alterlist(grid->row,cnt + 999)
    endif
 
    if(grid->row[cnt].col_cnt = 0)
        stat = alterlist(grid->row[cnt].col, MAX_COLUMNS)
        grid->row[cnt].col_cnt = MAX_COLUMNS
    endif
 
    ;UPDATE HERE
    call addValueTxt(cnt, cur_col, EMR_DESC)
    call addValueTxt(cnt, cur_col + 1, EMR_UUID)
 
foot report
    if(cnt > grid->row_cnt)
        grid->row_cnt = cnt
    endif
 
    ;UPDATE HERE: update to reflect number of columns
    cur_col = cur_col + 2
with nocounter
    ,nullreport
 
/*************************
** Inventory Info Query **
*************************/
select into "nl:"
    SMART_NAME = c.template_name,
    SMART_CKI = c.cki
from clinical_note_template c
where c.template_name != " "
group by c.template_name, c.cki
 
 
 
head report
 
    ;UPDATE HERE: add column headers
    grid->row[1].col[cur_col].txt = "SMART_NAME"
    grid->row[1].col[cur_col + 1].txt = "SMART_CKI"
 
    cnt = 1
 
detail
    cnt = cnt + 1
 
    if(cnt > grid->row_cnt and mod(cnt,1000) = 1)
        stat = alterlist(grid->row,cnt + 999)
    endif
 
    if(grid->row[cnt].col_cnt = 0)
        stat = alterlist(grid->row[cnt].col, MAX_COLUMNS)
        grid->row[cnt].col_cnt = MAX_COLUMNS
    endif
 
    ;UPDATE HERE
    call addValueTxt(cnt, cur_col, SMART_NAME)
    call addValueTxt(cnt, cur_col + 1, SMART_CKI)
 
foot report
    if(cnt > grid->row_cnt)
        grid->row_cnt = cnt
    endif
 
    ;UPDATE HERE: update to reflect number of columns
    cur_col = cur_col + 2
with nocounter
    ,nullreport
 
 
set stat = alterlist(grid->row,grid->row_cnt)
 
/**************************
** Display Query Results **
**************************/
/* Row & Column Layout */
;call parser(concat("select into '",$OUTDEV,"'"))
;
;for(index = 1 to MAX_COLUMNS)
;    set parser_cmd = build(parser_cmd,ENQ
;            ,"col",index
;            ," = trim(substring(1,100,grid->row[d1.seq].col[",index,"].txt))")
;endfor
;
;set parser_cmd = trim(parser_cmd,2) ;remove leading white space
;set parser_cmd = replace(parser_cmd,ENQ,",") ;replace all ENQ with commas
;
;call parser(parser_cmd)
;call parser("from (dummyt d1 with seq = value(grid->row_cnt))")
;call parser("with format,noheading,separator = ' ' go")
 
/* Raw Text Layout */
set file->file_name = $OUTDEV
set file->file_buf  = "w"
set stat = cclio("OPEN", file)
 
if(stat = 1)
 
    for(r = 1 to grid->row_cnt)
        set line = " "
 
        ;for(c = 1 to grid->row[r].col_cnt) ;exclude column headers
        for(c = 1 to size(grid->row[r].col,5)) ;include column headers
            if(findstring(",",grid->row[r].col[c].txt) > 0)
                set line = build(line,ENQ,Q,grid->row[r].col[c].txt,Q)
            else
                set line = build(line,ENQ,grid->row[r].col[c].txt)
            endif
        endfor
 
        set line = trim(line,3)
 
        if(size(line) > 0)
            set line = replace(line,ENQ,SEP)
 
            set file->file_buf = build(line,char(10))
 
            set stat = cclio("WRITE", file)
 
            if(stat = 0)
                call cclexception(900, "E", "CCLIO:Could not write to the file!")
            endif
        endif
    endfor
 
else
    call cclexception(900, "E", "CCLIO:Could not open file!")
endif
 
set stat = cclio("CLOSE", file)
 
 
/*******************************************************************************/
 
subroutine addValueTxt(r, c, txt)
    set grid->row[r].col[c].txt = txt
end
 
/*******************************************************************************/
 
subroutine addValueReal(r, c, real)
    set grid->row[r].col[c].txt = cnvtstring(real,17)
end
 
/*******************************************************************************/
 
subroutine addValueInt(r, c, int)
    set grid->row[r].col[c].txt = cnvtstring(int,17)
end
 
/*******************************************************************************/
 
set last_mod = "000 02/05/16 TB029829 Initial Release"
 
end
go
 
 