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
	 2 observation_dt_Tm	= dq8
	 2 op_in_bed_dt_tm		= dq8
	 2 arrive_dt_tm			= dq8
	 2 disch_dt_Tm			= dq8
	 2 pcp_ft_ind			= i2
	 2 attend_ft_ind		= i2
	 2 ref_ft_ind			= i2
	 2 admit_ft_ind			= i2
	 2 pcp_name_first		= vc
	 2 attending_name_first	= vc
	 2 referring_name_first	= vc
	 2 admitting_name_first	= vc
	 2 pcp_name_last		= vc
	 2 attending_name_last	= vc
	 2 referring_name_last	= vc
	 2 admitting_name_last	= vc
	 2 patient_pin			= vc
	 2 sexual_orientation	= vc
	 2 sex					= vc
	 2 birth_sex			= vc
	1 encntr_info_cnt = i2
	1 encntr_info[*]
	 2 value = vc
	 2 label = vc
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

set patinfo->status = "F"
 
/* INCLUDES **************************************************************************************/
 
call GetEncounterInfo(null)
if (patinfo->status = "S")
	call GetEncounterUserDefinedInfo(null)
	call GetEncounterEvent(null)
	call GetPersonPatient(null)
	call GetPPR(null)
	call GetEPR(null)
endif

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
		patinto->qual[cnt].disch_dt_tm		= e.disch_dt_tm
	foot report
		patinfo->status = "S"
	with nocounter
	
	if (curqual = 0)
		set patinfo->status = "Z"
	endif
end

subroutine GetEPR(null)
select into "NL:"
FROM
	  person   per
	, encntr_prsnl_reltn   ppr
	, prsnl p1
	, prsnl_alias pa
	, encounter e
	,(dummyt d2)
	,(dummyt d1 with seq = size(patinfo->qual,5))
plan d1
join e
	where e.encntr_id = patinfo->qual[d1.seq].encntr_id
join per
	where per.person_id = e.person_id
join ppr
	where 	ppr.encntr_id = e.encntr_id
	and     ppr.active_ind = 1
	and     ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and     ppr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
join p1
	where 	p1.person_id = ppr.prsnl_person_id
	and     p1.active_ind  =1
join d2
join pa
	where 	pa.person_id = p1.person_id
	and     pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and		pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	and     pa.active_ind = 1
	and     pa.prsnl_alias_type_cd = value(uar_get_code_by("MEANING",320,"DOCNBR"))
	and     pa.alias != "UNPHY"
order by
	 ppr.encntr_prsnl_r_cd
	,p1.beg_effective_dt_tm desc
	,per.person_id
head per.person_id	
	null
head ppr.encntr_prsnl_r_cd
	call echo(uar_get_code_meaning(ppr.encntr_prsnl_r_cd))
	case (uar_get_code_meaning(ppr.encntr_prsnl_r_cd))
		of "ATTENDING": patinfo->qual[1].pcp_name_first = p1.name_first
				  		patinfo->qual[1].pcp_name_last = p1.name_last
				  		patinfo->qual[1].pcp_ft_ind = 1
	    of "REFERDOC":  patinfo->qual[1].referring_name_first = p1.name_first
				  		patinfo->qual[1].referring_name_last = p1.name_last
				  		patinfo->qual[1].ref_ft_ind = 1
		of "ADMITDOC":  patinfo->qual[1].admitting_name_first = p1.name_first
				  		patinfo->qual[1].admitting_name_last = p1.name_last
				  		patinfo->qual[1].admit_ft_ind = 1
	endcase
with nocounter
end


subroutine GetPPR(null)

select into "NL:"
FROM
	  person   per
	, person_prsnl_reltn   ppr
	, prsnl p1
	, prsnl_alias pa
	, encounter e
	,(dummyt d1 with seq = size(patinfo->qual,5))
plan d1
join e
	where e.encntr_id = patinfo->qual[d1.seq].encntr_id
join per
	where per.person_id = e.person_id
join ppr
	where 	ppr.person_id = per.person_id
	and     ppr.active_ind = 1
	and     ppr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and     ppr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
join p1
	where 	p1.person_id = ppr.prsnl_person_id
	and     p1.active_ind  =1
join pa
	where 	pa.person_id = p1.person_id
	and     pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and		pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	and     pa.active_ind = 1
	and     pa.prsnl_alias_type_cd = value(uar_get_code_by("MEANING",320,"DOCNBR"))
	and     pa.alias != "UNPHY"
order by
	 per.person_id
	,ppr.person_prsnl_r_cd
	,p1.beg_effective_dt_tm desc
head per.person_id	
	null
head ppr.person_prsnl_r_cd
	case (uar_get_code_meaning(ppr.person_prsnl_r_cd))
		of "PCP": 		patinfo->qual[1].pcp_name_first = p1.name_first
				  		patinfo->qual[1].pcp_name_last = p1.name_last
				  		patinfo->qual[1].pcp_ft_ind = 1
	endcase
with nocounter
	
end

subroutine GetEncounterEvent(null)
select into "nl:"
from 
	patient_event e
	,(dummyt d1 with seq = size(patinfo->qual,5))
plan d1
join e
	where e.encntr_id = patinfo->qual[d1.seq].encntr_id
detail
	case (uar_get_code_display(e.event_type_cd))
		of "Outpatient In Bed":	patinfo->qual[d1.seq].op_in_bed_dt_tm = e.event_dt_tm
		of "Observation Start": patinfo->qual[d1.seq].observation_dt_Tm = e.event_dt_tm
	endcase
with nocounter


end

;birth_sex vs admin_sex
subroutine GetPersonPatient(null)
select into "NL:"
FROM
	  person   per
	, person_patient   p
	, encounter e
	,(dummyt d1 with seq = size(patinfo->qual,5))
plan d1
join e
	where e.encntr_id = patinfo->qual[d1.seq].encntr_id
join per
	where per.person_id = e.person_id
join p
	where 	per.person_id = p.person_id
head p.person_id
	patinfo->qual[d1.seq].sex 		= uar_get_code_display (per.sex_cd)
	patinfo->qual[d1.seq].birth_sex = uar_get_code_display (p.birth_sex_cd)
WITH nocounter
end

subroutine GetEncounterUserDefinedInfo(null)
select into "nl:"
from 
	encntr_info ei
	,long_text lt
plan ei
	where ei.encntr_id = criterion->encntrs[1].encntr_id
join lt
	where lt.long_text_id = ei.long_text_id
head report
	cnt = 0
detail
	patinfo->encntr_info_cnt = (patinfo->encntr_info_cnt + 1)
	stat = alterlist(patinfo->encntr_info,patinfo->encntr_info_cnt)
	patinfo->encntr_info[patinfo->encntr_info_cnt].label	 	= uar_get_code_display(ei.info_sub_type_cd)
	patinfo->encntr_info[patinfo->encntr_info_cnt].value		= lt.long_text
with nocounter

for (i = 1 to patinfo->encntr_info_cnt)
	case (patinfo->encntr_info[i].label)
		of "PCP First Name":					set patinfo->qual[1].pcp_name_first = patinfo->encntr_info[i].value
		of "PCP Last Name":						set patinfo->qual[1].pcp_name_last = patinfo->encntr_info[i].value
		of "Attending Physician First Name":	set patinfo->qual[1].attending_name_first = patinfo->encntr_info[i].value
		of "Attending Physician Last Name":		set patinfo->qual[1].attending_name_last = patinfo->encntr_info[i].value
		of "Referring Physician First Name":	set patinfo->qual[1].referring_name_first = patinfo->encntr_info[i].value
		of "Referring Physician Last Name":		set patinfo->qual[1].referring_name_last = patinfo->encntr_info[i].value
		of "Patient PIN":						set patinfo->qual[1].patient_pin = patinfo->encntr_info[i].value
		of "Sexual Orientation":				set patinfo->qual[1].sexual_orientation = patinfo->encntr_info[i].value
	endcase
endfor

end


subroutine FormatResults(null)

set replyString = build("<table>")



for (i = 1 to size(patinfo->qual,5))
	if (patinfo->qual[i].encntr_id > 0.0)
		set replyString = build(replyString,"<tr><td><b>Arrive DT/TM</b></td><td>&nbsp</td><td>",
											format(patinfo->qual[i].arrive_dt_tm,";;q"),
						"</td></tr>")
		set replyString = build(replyString,"<tr><td><b>Reg DT/TM</b></td><td>&nbsp</td><td>",
											format(patinfo->qual[i].reg_dt_tm,";;q"),
						"</td></tr>")
		if (patinfo->qual[i].inpatient_dt_tm > 0.0)
			set replyString = build(replyString,"<tr><td><b>Inpatient Admit DT/TM</b></td><td>&nbsp</td><td>",
											format(patinfo->qual[i].inpatient_dt_tm,";;q"),
						"</td></tr>")
		endif
		
		if (patinfo->qual[i].observation_dt_Tm > 0.0)
			set replyString = build(replyString,"<tr><td><b>Observation Admit DT/TM</b></td><td>&nbsp</td><td>",
											format(patinfo->qual[i].observation_dt_Tm,";;q"),
						"</td></tr>")
		endif
		
		if (patinfo->qual[i].op_in_bed_dt_tm > 0.0)
			set replyString = build(replyString,"<tr><td><b>Outpatient in a Bed DT/TM</b></td><td>&nbsp</td><td>",
											format(patinfo->qual[i].op_in_bed_dt_tm,";;q"),
						"</td></tr>")
		endif

		if (patinfo->qual[i].disch_dt_tm > 0.0)
			set replyString = build(replyString,"<tr><td><b>Discharge DT/TM</b></td><td>&nbsp</td><td>",
											format(patinfo->qual[i].disch_dt_Tm,";;q"),
						"</td></tr>")
		endif
		
		if (patinfo->qual[i].birth_sex > " ")
			set replyString = build(replyString,"<tr><td><b>Birth Sex</b></td><td>&nbsp</td><td>",
							trim(patinfo->qual[i].birth_sex),
						"</td></tr>")
		endif
	
		if (patinfo->qual[i].sex > " ")
			set replyString = build(replyString,"<tr><td><b>Preferred Gender</b></td><td>&nbsp</td><td>",
							trim(patinfo->qual[i].sex),
						"</td></tr>")
		endif
		
		if ((patinfo->qual[i].attending_name_first > " ") or (patinfo->qual[i].attending_name_last > " "))
		set i_start = "" set i_end = ""
		if (patinfo->qual[i].attend_ft_ind = 0) set i_start = "<i>" set i_end = "</i>" endif
			set replyString = build(replyString,"<tr><td><b>Attending</b></td><td>&nbsp</td><td>",i_start,
							concat(trim(patinfo->qual[i].attending_name_first)," ",trim(patinfo->qual[i].attending_name_last)),
							i_end,"</td></tr>")
		endif
		
		if ((patinfo->qual[i].admitting_name_first > " ") or (patinfo->qual[i].admitting_name_last > " "))
			set i_start = "" set i_end = ""
			if (patinfo->qual[i].admit_ft_ind = 0) set i_start = "<i>" set i_end = "</i>" endif

			set replyString = build(replyString,"<tr><td><b>Admitting</b></td><td>&nbsp</td><td>",
							concat(trim(patinfo->qual[i].admitting_name_first)," ",trim(patinfo->qual[i].admitting_name_last)),
						"</td></tr>")
		endif

		
		if ((patinfo->qual[i].referring_name_first > " ") or (patinfo->qual[i].referring_name_last > " " ))
			set i_start = "" set i_end = ""
			if (patinfo->qual[i].ref_ft_ind = 0) set i_start = "<i>" set i_end = "</i>" endif
			set replyString = build(replyString,"<tr><td><b>Referring</b></td><td>&nbsp</td><td>",i_start,
							concat(trim(patinfo->qual[i].referring_name_first)," ",trim(patinfo->qual[i].referring_name_last)),
						i_end,"</td></tr>")
		endif
		
		if ((patinfo->qual[i].pcp_name_first > " ") or (patinfo->qual[i].pcp_name_last > " " ))
			set i_start = "" set i_end = ""
			if (patinfo->qual[i].pcp_ft_ind = 0) set i_start = "<i>" set i_end = "</i>" endif
			set replyString = build(replyString,"<tr><td><b>PCP</b></td><td>&nbsp</td><td>",i_start,
						concat(trim(patinfo->qual[i].pcp_name_first)," ",trim(patinfo->qual[i].pcp_name_last)),
						i_end,"</td></tr>")
		endif
		
		if (patinfo->qual[i].patient_pin > "0")
			set replyString = build(replyString,"<tr><td><b>Patient PIN</b></td><td>&nbsp</td><td>",
											trim(patinfo->qual[i].patient_pin),
						"</td></tr>")
		endif
		
		if (patinfo->qual[i].sexual_orientation > " ")
			set replyString = build(replyString,"<tr><td><b>Orientation</b></td><td>&nbsp</td><td>",
											trim(patinfo->qual[i].sexual_orientation),
						"</td></tr>")
		endif
	endif
endfor

set replyString = build(replyString,"</table>")
call echo(build2("replyString=",replyString))
end
 
#exit_script

call echorecord(patinfo)

end
go

