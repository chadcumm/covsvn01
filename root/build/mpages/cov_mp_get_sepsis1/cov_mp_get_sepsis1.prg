drop program cov_mp_get_sepsis1:dba go
create program cov_mp_get_sepsis1:dba
 
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
	1 status_text = vc
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
declare i_start = vc with noconstant("")
declare i_end = vc with noconstant("")

set patinfo->status = "S"
set patinfo->status_text = "Data for MPage Successfully Collected"
 
call FormatResults(null)
;set _MEMORY_REPLY_STRING = cnvtrectojson(patinfo)
set _MEMORY_REPLY_STRING = replyString
call echo(_Memory_Reply_String)

subroutine FormatResults(null)
	set replyString = build("<table>")
	set replyString = build(replyString,"<tr><td>",trim(patinfo->status_text),"</td></tr>")
	set replyString = build(replyString,"</table>")
	set replyString = build(replyString,^<div class="mpageui-Table-body">^)
set replyString = build(replyString,^<div class="mpageui-Table-sectionContainer">^)
set replyString = build(replyString,^<header class="mpageui-Table-sectionHeader closed">^)

set replyString = build(replyString,^<svg viewBox="0 0 48 48" draggable="false" focusable="false" class="mpageui-SvgIcon mpageui-\
SvgIcon-Collapsed mpageui-SvgIcon--small">^)
set replyString = build(replyString,^<path d="M12,0l24,24L12,48V0z" data-svg-id="caretRight"></path></svg>^)
set replyString = build(replyString,^<svg viewBox="0 0 48 48" draggable="false" focusable="false" class="mpageui-SvgIcon mpageui-\
SvgIcon-Cancel">^)
set replyString = build(replyString,^<path d="M24,0A24,24,0,1,0,48,24,23.94,23.94,0,0,0,24,0ZM5.5,24A18.52,18.52,0,0,1,24,5.5,18.\
05,18.05,0,0,1,34.9,9.1L9.2,35A18.43,18.43,0,0,1,5.5,24ZM24,42.5a18.05,18.05,0,0,1-10.9-3.6L38.8,13A18.42,18.42,0,0,1,24,42.5Z\
"></path></svg>^)

set replyString = build(replyString,^<span class="mpageui-Label">Presentation Events</span></header>^)
set replyString = build(replyString,^<div class="mpageui-Table-rowContainer mpageui-Table-rowContainer--hidden"></div></div>																																																																 ^)
set replyString = build(replyString,^<div class="mpageui-Table-sectionContainer"><header class="mpageui-Table-sectionHeader closed">                                                                                                                                                                                                                                                         ^)
set replyString = build(replyString,^<svg viewBox="0 0 48 48" draggable="false" focusable="false" class="mpageui-SvgIcon mpageui-SvgIcon-Collapsed mpageui-SvgIcon--small">                                                                                                                                                                                                                  ^)
set replyString = build(replyString,^<path d="M12,0l24,24L12,48V0z" data-svg-id="caretRight"></path></svg>                                                                                                                                                                                                                                                                                   ^)
set replyString = build(replyString,^<svg viewBox="0 0 48 48" draggable="false" focusable="false" class="mpageui-SvgIcon mpageui-SvgIcon-Cancel">                                                                                                                                                                                                                                            ^)
set replyString = build(replyString,^<path d="M24,0A24,24,0,1,0,48,24,23.94,23.94,0,0,0,24,0ZM5.5,24A18.52,18.52,0,0,1,24,5.5,18.05,18.05,0,0,1,34.9,9.1L9.2,35A18.43,18.43,0,0,1,5.5,24ZM24,42.5a18.05,18.05,0,0,1-10.9-3.6L38.8,13A18.42,18.42,0,0,1,24,42.5Z"></path></svg>                                                                                                               ^)
set replyString = build(replyString,^<span class="mpageui-Label">3 Hours of Presentation Severe Sepsis</span></header>                                                                                                                                                                                                                                    ^)
set replyString = build(replyString,^<div class="mpageui-Table-rowContainer mpageui-Table-rowContainer--hidden"></div></div><div class="mpageui-Table-sectionContainer">                                                                                                                                                                                                                     ^)
set replyString = build(replyString,^<header class="mpageui-Table-sectionHeader closed"><svg viewBox="0 0 48 48" draggable="false" focusable="false" class="mpageui-SvgIcon mpageui-SvgIcon-Collapsed mpageui-SvgIcon--small">                                                                                                                                                               ^)
set replyString = build(replyString,^<path d="M12,0l24,24L12,48V0z" data-svg-id="caretRight"></path></svg>                                                                                                                                                                                                                                                                                   ^)
set replyString = build(replyString,^<svg viewBox="0 0 48 48" draggable="false" focusable="false" class="mpageui-SvgIcon mpageui-SvgIcon-Cancel"><path d="M24,0A24,24,0,1,0,48,24,23.94,23.94,0,0,0,24,0ZM5.5,24A18.52,18.52,0,0,1,24,5.5,18.05,18.05,0,0,1,34.9,9.1L9.2,35A18.43,18.43,0,0,1,5.5,24ZM24,42.5a18.05,18.05,0,0,1-10.9-3.6L38.8,13A18.42,18.42,0,0,1,24,42.5Z"></path></svg>   ^)
set replyString = build(replyString,^<span class="mpageui-Label">6 Hours - Repeat Lactate Level Not Indicated</span></header>                                                                                                                                                                                                                              ^)
set replyString = build(replyString,^<div class="mpageui-Table-rowContainer mpageui-Table-rowContainer--hidden"></div></div><div class="mpageui-Table-sectionContainer">                                                                                                                                                                                                                     ^)
set replyString = build(replyString,^<header class="mpageui-Table-sectionHeader closed"><svg viewBox="0 0 48 48" draggable="false" focusable="false" class="mpageui-SvgIcon mpageui-SvgIcon-Collapsed mpageui-SvgIcon--small"><path d="M12,0l24,24L12,48V0z" data-svg-id="caretRight"></path></svg>                                                                                          ^)
set replyString = build(replyString,^<svg viewBox="0 0 48 48" draggable="false" focusable="false" class="mpageui-SvgIcon mpageui-SvgIcon-Cancel"><path d="M24,0A24,24,0,1,0,48,24,23.94,23.94,0,0,0,24,0ZM5.5,24A18.52,18.52,0,0,1,24,5.5,18.05,18.05,0,0,1,34.9,9.1L9.2,35A18.43,18.43,0,0,1,5.5,24ZM24,42.5a18.05,18.05,0,0,1-10.9-3.6L38.8,13A18.42,18.42,0,0,1,24,42.5Z"></path></svg>   ^)
set replyString = build(replyString,^<span class="mpageui-Label">3 Hours of Presentation Septic Shock - Septic Shock Not Identified</span></header><div class="mpageui-Table-rowContainer mpageui-Table-rowContainer--hidden"></div></div><div class="mpageui-Table-sectionContainer"><header class="mpageui-Table-sectionHeader closed">                                                ^)
set replyString = build(replyString,^<svg viewBox="0 0 48 48" draggable="false" focusable="false" class="mpageui-SvgIcon mpageui-SvgIcon-Collapsed mpageui-SvgIcon--small">                                                                                                                                                                                                                  ^)
set replyString = build(replyString,^<path d="M12,0l24,24L12,48V0z" data-svg-id="caretRight"></path></svg>                                                                                                                                                                                                                                                                                   ^)
set replyString = build(replyString,^<svg viewBox="0 0 48 48" draggable="false" focusable="false" class="mpageui-SvgIcon mpageui-SvgIcon-Cancel">                                                                                                                                                                                                                                            ^)
set replyString = build(replyString,^<path d="M24,0A24,24,0,1,0,48,24,23.94,23.94,0,0,0,24,0ZM5.5,24A18.52,18.52,0,0,1,24,5.5,18.05,18.05,0,0,1,34.9,9.1L9.2,35A18.43,18.43,0,0,1,5.5,24ZM24,42.5a18.05,18.05,0,0,1-10.9-3.6L38.8,13A18.42,18.42,0,0,1,24,42.5Z"></path>                                                                                                                     ^)
set replyString = build(replyString,^<span class="mpageui-Label">This is a custom grouping</span></header>                                                                                                                                                                                                                              ^)
call echo(build2("replyString=",replyString))
end

#exit_script

call echorecord(patinfo)

end
go

