drop program cov_mp_get_patinfo:dba go
create program cov_mp_get_patinfo:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Patient ID:" = 0.00
	, "Encounter ID:" = 0.00
	, "Personnel ID:" = 0.00
	, "HTML File Name:" = ""
	, "HTML Backend Location:" = ""
	, "Provider Position Code:" = 0.00
	, "Patient Provider Relationship Code:" = 0.00
	, "Debug Indicator:" = 0 

with OUTDEV, PATIENTID, ENCOUNTERID, PERSONNELID, HTMLFILENAME, BACKENDLOC, 
	POSITIONCODE, PPRCODE, DEBUGIND
 
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

declare replyString = vc with noconstant(" ")
declare i = i2 with noconstant(0)

set patinfo->status = "F"
 
/* INCLUDES **************************************************************************************/
 
call GetEncounterInfo(null)
call FormatResults(null)
;set _MEMORY_REPLY_STRING = cnvtrectojson(patinfo)
set _MEMORY_REPLY_STRING = replyString
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
	patinfo->qual[cnt].encntr_id	 	= e.encntr_id
	patinfo->qual[cnt].arrive_dt_tm		= e.arrive_dt_tm
	patinfo->qual[cnt].inpatient_dt_tm	= e.inpatient_admit_dt_tm
	patinfo->qual[cnt].reg_dt_tm		= e.reg_dt_tm
foot report
	patinfo->status = "S"
with nocounter

if (curqual = 0)
	set patinfo->status = "Z"
endif
end


subroutine FormatResults(null)

set replyString = build("<table>")

for (i = 1 to size(patinfo->qual,5))
	if (patinfo->qual[i].encntr_id > 0.0)
		set replyString = build("<tr><td><b>Arrive DT/TM</b></td><td>",format(patinfo->qual[i].arrive_dt_tm,";;q"),"</td></tr>")
	endif
endfor

set replyString = build(replyString,"</table>")
call echo(build2("replyString=",replyString))
end
 
#exit_script
 
end
go

