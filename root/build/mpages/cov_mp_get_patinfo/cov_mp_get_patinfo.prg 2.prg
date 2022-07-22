drop program cov_mp_get_patinfo:dba go
create program cov_mp_get_patinfo:dba
 
prompt
        "Output to File/Printer/MINE" = "MINE"
        ,"Patient ID:" = 0.00
        ,"Encounter ID:" = 0.00
        ,"Personnel ID:" = 0.00
        ,"HTML File Name:" = ""
        ,"HTML Backend Location:" = ""
        ,"Provider Position Code:" = 0.00
        ,"Patient Provider Relationship Code:" = 0.00
        ,"eForm Identified:" = 0.00
        ,"eForm Saved:" = 0.00
        ,"Debug Indicator:" = 0
 
with outdev, patientid, encounterid, personnelid, htmlFileName, backendLoc,
positionCode, pprCode, eformCd, eformId, debugInd
 
;"MINE","$pat_personid$","$vis_encntrid$","$usr_personid$",
;"eform_base.html", "ccluserdir:", "$USR_PositionCd$","$PAT_PPRCode$",0.0,0.0,"1"
 
/* DECLARE RECORDS *******************************************************************************/
free record criterion
record criterion
(
	1 person_id = f8
	1 encntrs[*]
		2 encntr_id = f8
	1 prsnl_id = f8
	1 executable = vc
	1 html_filename = vc
	1 backend_location = vc
	1 position_cd = f8
	1 ppr_cd = f8
	1 debug_ind = i2
	1 help_file_local_ind = i2
	1 patient_info
		2 sex_cd = f8
		2 dob = vc
	1 eform_code_value = f8
	1 eform_saved_id = f8
)

free record eform_library
record eform_library
(
	1 qual[*]
	 2 eform_code_value = f8
	 2 eform_display	= vc
)

free record patinfo
record patinfo
(
	1 status = c1
) 
set criterion->person_id = $PATIENTID
set stat = alterlist(criterion->encntrs, 1)
set criterion->encntrs[1].encntr_id = $ENCOUNTERID
set criterion->prsnl_id = $PERSONNELID
set criterion->backend_location = $BACKENDLOC
set criterion->html_filename = $HTMLFILENAME
set criterion->position_cd = $POSITIONCODE
set criterion->ppr_cd = $PPRCODE
set criterion->debug_ind = $DEBUGIND
set criterion->eform_code_value = $EFORMCD
set criterion->eform_saved_id = $EFORMID
 
/* INCLUDES **************************************************************************************/
 
 

if (criterion->person_id = 0.0)
	call GetFormListJSON(null)
	set _Memory_Reply_String = cnvtrectojson(patinfo) 
	call echo(_Memory_Reply_String)
else
	call GetFormList(null)
 	set _MEMORY_REPLY_STRING = cnvtrectojson(patinfo)
	call echo(_Memory_Reply_String)
endif

 
/* SUBROUTINES **************************************************************************************/

subroutine GetFormListJSON(null)
call echo("GetFormListJSON")
select into "nl:"
	from code_value cv
	plan cv
		where cv.code_set = 16529
		and   cv.cdf_meaning = "EFORM"
		and   cv.active_ind = 1
		and   cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
		and   cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	order by
		 cv.collation_seq
		,cv.display
		,cv.code_value
	head report
		cnt = 0
	head cv.code_value
		cnt = (cnt + 1)
		stat = alterlist(eform_library->qual,cnt)
		eform_library->qual[cnt].eform_code_value = cv.code_value
		eform_library->qual[cnt].eform_display = cv.display
	with nocounter

end ;subroutine GetFormListJSON(null) 
subroutine GetFormList(null)
call echo("GetFormList")
	select into "nl:"
	from code_value cv
	plan cv
		where cv.code_set = 16529
		and   cv.cdf_meaning = "EFORM"
		and   cv.active_ind = 1
		and   cv.begin_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
		and   cv.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	order by
		 cv.collation_seq
		,cv.display
		,cv.code_value
	head report
		stat = 0
		eform_list = build(eform_list,"<table>")
	head cv.code_value
;		eform_list = build(eform_list,"<tr><td>")
;		eform_list = build(eform_list,~<input type="button" ~)
;		eform_list = build(eform_list,~onclick="javascript:CCLLINK('mp_eforms_driver','~)
;		eform_list = build(eform_list,~^mine^~)
;		eform_list = build(eform_list,~,~,criterion->person_id)
;		eform_list = build(eform_list,~,~,criterion->encntrs[1].encntr_id)
;		eform_list = build(eform_list,~,~,criterion->prsnl_id)
;		eform_list = build(eform_list,~,^~,cv.definition,~^~)
;		eform_list = build(eform_list,~,^~,criterion->backend_location,~^~)
;		eform_list = build(eform_list,~,~,criterion->position_cd)
;		eform_list = build(eform_list,~,~,criterion->ppr_cd)
;		eform_list = build(eform_list,~,~,cv.code_value,~,0.0',0) "~)
;		eform_list = build(eform_list,~value="~,cv.display,~"/>~)
		eform_list = build(eform_list,"<tr><td>")
 
		eform_list = build(eform_list,~<a href="javascript:CCLLINK('mp_eforms_driver','~)
		eform_list = build(eform_list,~^mine^~)
		eform_list = build(eform_list,~,~,criterion->person_id)
		eform_list = build(eform_list,~,~,criterion->encntrs[1].encntr_id)
		eform_list = build(eform_list,~,~,criterion->prsnl_id)
		eform_list = build(eform_list,~,^~,cv.definition,~^~)
		eform_list = build(eform_list,~,^~,criterion->backend_location,~^~)
		eform_list = build(eform_list,~,~,criterion->position_cd)
		eform_list = build(eform_list,~,~,criterion->ppr_cd)
		eform_list = build(eform_list,~,~,cv.code_value,~,0.0',0) ">~)
		eform_list = build(eform_list,cv.display,~<a/>~)
	foot cv.code_value
		eform_list = build(eform_list,"</td></tr>")
	foot report
		if (criterion->position_cd = dba_cd)
			eform_list = build(eform_list,"<tr><td>&nbsp</td></tr>")
			eform_list = build(eform_list,"<tr><td>&nbsp</td></tr>")
			eform_list = build(eform_list,"<tr><td>")
			;eform_list = build(eform_list,~<a href="#" onClick="javascript:window.open('http://~)
			;eform_list = build(eform_list,~kvhihwsodr01/mpage-content/prdih.ih.viha.ca/custom_mpage_content/eforms/Edit.html')">~)
			eform_list = build(eform_list,~<a href="javascript:CCLLINK('mp_eform_manager','^mine^,1',0) ">~)
			eform_list = build(eform_list,~[Define eForm Layouts]</a>~)
			eform_list = build(eform_list,"</td></tr>")
		endif

	with nocounter
end
 
#exit_script
 
end
go

