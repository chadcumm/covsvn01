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



free record patinfo
record patinfo
(
	1 status = c1
	1 qual[*]
	 2 encntr_id			= f8
	 2 reg_dt_tm 			= dq8
	 2 inpatient_dt_tm		= dq8
	 2 arrive_dt_tm			= dq8
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
 
call GetEncounterInfo(null)
set _MEMORY_REPLY_STRING = cnvtrectojson(patinfo)
call echo(_Memory_Reply_String)


 
/* SUBROUTINES **************************************************************************************/

subroutine GetEncounterInfo(null)
select into "nl:"
from 
	encounter e
plan e
	where e.encntr_id = criterion->encntrs[1].encntr_id
head report
	cnt = 0
detail
	cnt = (cnt + 1)
	stat = alterlist(patinfo->qual,cnt)
	
with nocounter
end
 
#exit_script
 
end
go

