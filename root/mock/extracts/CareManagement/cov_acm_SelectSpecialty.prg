/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		06/27/2019
	Solution:			Revenue Cycle - Acute Care Management
	Source file name:	cov_acm_SelectSpecialty.prg
	Object name:		cov_acm_SelectSpecialty
	Request #:			4985, 12220
 
	Program purpose:	Provides a list of patients with a specified length of stay.
						Includes the amount of time in critical care units as well as
						step down beds.
 
	Executing from:		CCL
 
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	02/15/2022	Todd A. Blanchard		Changed qualifying timeframe from five
										to four days. 
******************************************************************************/
 
drop program cov_acm_SelectSpecialty:DBA go
create program cov_acm_SelectSpecialty:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Output To File" = 0                   ;* Output to file

with OUTDEV, output_file
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare fin_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare attendingphysician_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 333, "ATTENDINGPHYSICIAN"))
declare inpatient_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "INPATIENT"))
declare observation_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "OBSERVATION"))
declare outpatientinabed_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "OUTPATIENTINABED"))
declare snfinpatient_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "SNFINPATIENT"))
declare intermediate_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 10, "INTERMEDIATE"))
declare intermedcoronary_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 10, "INTERMEDCORONARY"))
declare intensivecare_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 10, "INTENSIVECARE"))
declare intensivecareobs_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 10, "INTENSIVECAREOBS"))
declare covenant_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 73, "COVENANT"))
declare start_datetime				= dq8 with constant(cnvtdatetime(cnvtlookbehind("4,D"))) ;001
declare critical_care_var			= vc with constant("Critical Care")
declare step_down_var				= vc with constant("Step Down")
declare num							= i4 with noconstant(0)
 
declare file_var					= vc with constant("select_specialty.asc")
 
declare temppath_var				= vc with constant(build("cer_temp:", file_var))
declare temppath2_var				= vc with constant(build("$cer_temp/", file_var))
 
declare filepath_var				= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
															 "_cust/to_client_site/RevenueCycle/R2W/EnterpriseEcare/", file_var))
 
declare output_var					= vc with noconstant("")
 
declare cmd							= vc with noconstant("")
declare len							= i4 with noconstant(0)
declare stat						= i4 with noconstant(0)
 
 
; define output value
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set output_var = value(temppath_var)
else
	set output_var = value($OUTDEV)
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
record select_specialty (
	1	cnt								= i4
	1	list[*]
		2	encntr_id					= f8
		2	facility					= c40
		2	facility_desc				= c60
		2	facility_alias				= c100
		2	person_id					= f8
		2	patient_name				= c100
		2	dob							= dq8
		2	dob_tz						= i4
		2	fin							= c200
		2	room_nbr					= c40
		2	reason_for_visit			= c255
 
		2	attending_phys				= c100
		2	primary_payer				= c100
		2	secondary_payer				= c100
 
		2	reg_dt_tm					= dq8
		2	los							= f8
)
 
record encntr (
	1	cnt								= i4
	1	list[*]
		2	encntr_id					= f8
		2	acccnt						= i4
		2	acclist[*]
			3	accommodation_cd		= f8
			3	accommodation			= c40
			3	assign_to_loc_dt_tm		= dq8
)
 
record encntr_detail (
	1	cnt								= i4
	1	list[*]
		2	encntr_id					= f8
 
		2	from_accommodation_cd		= f8
		2	from_accommodation			= c40
		2	from_assign_to_loc_dt_tm	= dq8
		2	from_rowid					= i4
 
		2	to_accommodation_cd			= f8
		2	to_accommodation			= c40
		2	to_assign_to_loc_dt_tm		= dq8
		2	to_rowid					= i4
 
		2	total_time					= f8
)
 
record encntr_total (
	1	cnt								= i4
	1	list[*]
		2	encntr_id					= f8
		2	accommodation				= c20
		2	total_time					= f8
)
 
/**************************************************************/
; set prompt data
 
 
/**************************************************************/
; select encounter data
select into "NL:"
from
	ENCOUNTER e
 
	, (inner join CODE_VALUE_OUTBOUND cvo on cvo.code_value = e.loc_facility_cd
		and cvo.contributor_source_cd = covenant_var)
 
	, (inner join ENCNTR_ALIAS eaf on eaf.encntr_id = e.encntr_id
		and eaf.encntr_alias_type_cd = fin_var
		and eaf.end_effective_dt_tm > sysdate
		and eaf.active_ind = 1)
 
	, (inner join PERSON p on p.person_id = e.person_id
		and p.name_last_key not in ("ZZZ*", "TTT*"))
 
  	; primary plan
	, (left join ENCNTR_PLAN_RELTN epr on epr.encntr_id = e.encntr_id
		and epr.priority_seq = 1
		and epr.beg_effective_dt_tm <= sysdate
		and epr.end_effective_dt_tm > sysdate
		and epr.active_ind = 1)
 
	, (left join HEALTH_PLAN hp on hp.health_plan_id = epr.health_plan_id
		and hp.beg_effective_dt_tm <= sysdate
		and hp.end_effective_dt_tm > sysdate
		and hp.active_ind = 1)
 
  	; secondary plan
	, (left join ENCNTR_PLAN_RELTN epr2 on epr2.encntr_id = e.encntr_id
		and epr2.priority_seq = 2
		and epr2.beg_effective_dt_tm <= sysdate
		and epr2.end_effective_dt_tm > sysdate
		and epr2.active_ind = 1)
 
	, (left join HEALTH_PLAN hp2 on hp2.health_plan_id = epr2.health_plan_id
		and hp2.beg_effective_dt_tm <= sysdate
		and hp2.end_effective_dt_tm > sysdate
		and hp2.active_ind = 1)
 
	; personnel
	, (left join ENCNTR_PRSNL_RELTN eper on eper.encntr_id = e.encntr_id
		and eper.encntr_prsnl_r_cd = attendingphysician_var
		and eper.end_effective_dt_tm > sysdate
		and eper.active_ind = 1)
 
	, (left join PRSNL per_eper on per_eper.person_id = eper.prsnl_person_id)
 
where
	1 = 1
	and e.loc_facility_cd in (
		select cv.code_value
		from CODE_VALUE cv
		where
			cv.code_set = 220
			and cv.cdf_meaning = "FACILITY"
			and cv.display_key in ("FSR", "MMC", "FLMC", "MHHS", "PW", "RMC", "LCMC")
	)
	and e.loc_room_cd > 0.0
	and e.encntr_type_cd in (inpatient_var)
	and	e.reg_dt_tm <= cnvtdatetime(start_datetime)
	and	e.disch_dt_tm is null
	and	e.active_ind = 1
 
order by
	e.encntr_id
	, p.person_id
 
 
; populate record structure
head report
	cnt = 0
 
	call alterlist(select_specialty->list, 100)
 
detail
	cnt = cnt + 1
 
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(select_specialty->list, cnt + 9)
	endif
 
	select_specialty->cnt = cnt
	select_specialty->list[cnt].encntr_id				= e.encntr_id
	select_specialty->list[cnt].facility				= uar_get_code_display(e.loc_facility_cd)
	select_specialty->list[cnt].facility_desc			= uar_get_code_description(e.loc_facility_cd)
	select_specialty->list[cnt].facility_alias			= cvo.alias
	select_specialty->list[cnt].person_id				= p.person_id
	select_specialty->list[cnt].patient_name			= p.name_full_formatted
	select_specialty->list[cnt].dob						= p.birth_dt_tm
	select_specialty->list[cnt].dob_tz					= p.birth_tz
	select_specialty->list[cnt].fin						= eaf.alias
	select_specialty->list[cnt].room_nbr				= uar_get_code_display(e.loc_room_cd)
	select_specialty->list[cnt].reason_for_visit		= e.reason_for_visit
 
	select_specialty->list[cnt].attending_phys			= per_eper.name_full_formatted
	select_specialty->list[cnt].primary_payer			= hp.plan_name
	select_specialty->list[cnt].secondary_payer			= hp2.plan_name
 
	select_specialty->list[cnt].reg_dt_tm				= e.reg_dt_tm
	select_specialty->list[cnt].los						= datetimediff(sysdate, e.reg_dt_tm)
 
foot report
	call alterlist(select_specialty->list, cnt)
 
with nocounter, time = 120
 
 
;call echorecord(select_specialty)
 
 
/**************************************************************/
; select encounter accommodation data
select distinct into "NL:"
from
	ENCNTR_FLEX_HIST efh
 
where
	expand(num, 1, select_specialty->cnt, efh.encntr_id, select_specialty->list[num].encntr_id)
	and efh.accommodation_cd > 0.0
	and efh.end_effective_dt_tm > sysdate
	and efh.active_ind = 1
 
order by
	efh.encntr_id
	, efh.assign_to_loc_dt_tm
	, uar_get_code_display(efh.accommodation_cd)
 
; populate record structure
head report
	cnt = 0
 
	call alterlist(encntr->list, 100)
 
head efh.encntr_id
	acccnt = 0
 
	cnt = cnt + 1
 
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(encntr->list, cnt + 9)
	endif
 
	encntr->cnt = cnt
	encntr->list[cnt].encntr_id = efh.encntr_id
 
detail
	acccnt = acccnt + 1
 
	call alterlist(encntr->list[cnt].acclist, acccnt)
 
	encntr->list[cnt].acccnt = acccnt
	encntr->list[cnt].acclist[acccnt].accommodation_cd		= efh.accommodation_cd
	encntr->list[cnt].acclist[acccnt].accommodation			= uar_get_code_display(efh.accommodation_cd)
	encntr->list[cnt].acclist[acccnt].assign_to_loc_dt_tm	= efh.assign_to_loc_dt_tm
 
foot report
	call alterlist(encntr->list, cnt)
 
with nocounter, expand = 1, time = 120
 
 
;call echorecord(encntr)
 
 
/**************************************************************/
; select encounter accommodation details data
if (encntr->cnt > 0)
	select into "NL:"
		encntr_id					= encntr->list[d1.seq].encntr_id
 
		, from_accommodation_cd		= encntr->list[d1.seq].acclist[d2.seq].accommodation_cd
		, from_accommodation		= encntr->list[d1.seq].acclist[d2.seq].accommodation
		, from_assign_to_loc_dt_tm	= encntr->list[d1.seq].acclist[d2.seq].assign_to_loc_dt_tm
		, from_rowid				= d2.seq
 
		, to_accommodation_cd		= evaluate2(
										if ((d2.seq = encntr->list[d1.seq].acccnt) and (d3.seq = d2.seq))
											0.0
										else
											encntr->list[d1.seq].acclist[d3.seq].accommodation_cd
										endif
										)
 
		, to_accommodation			= evaluate2(
										if ((d2.seq = encntr->list[d1.seq].acccnt) and (d3.seq = d2.seq))
											""
										else
											encntr->list[d1.seq].acclist[d3.seq].accommodation
										endif
										)
 
		, to_assign_to_loc_dt_tm	= evaluate2(
										if ((d2.seq = encntr->list[d1.seq].acccnt) and (d3.seq = d2.seq))
											sysdate
										else
											encntr->list[d1.seq].acclist[d3.seq].assign_to_loc_dt_tm
										endif
										)
 
		, to_rowid					= d3.seq
 
		, total_time				= datetimediff(evaluate2(
										if ((d2.seq = encntr->list[d1.seq].acccnt) and (d3.seq = d2.seq))
											sysdate
										else
											encntr->list[d1.seq].acclist[d3.seq].assign_to_loc_dt_tm
										endif
										),
										encntr->list[d1.seq].acclist[d2.seq].assign_to_loc_dt_tm)
 
	from
		(dummyt d1 with seq = encntr->cnt)
 
		, (dummyt d2 with seq = 1)
 
		, (dummyt d3 with seq = 1)
 
	plan d1 where maxrec(d2, encntr->list[d1.seq].acccnt)
 
	join d2 where maxrec(d3, encntr->list[d1.seq].acccnt)
 
	join d3 where (d3.seq = (d2.seq + 1))
		or (d2.seq = encntr->list[d1.seq].acccnt
			and d3.seq = encntr->list[d1.seq].acccnt)
 
	order by
		encntr_id
		, d2.seq
		, d3.seq
 
 
	; populate record structure
	head report
		cnt = 0
 
		call alterlist(encntr_detail->list, 100)
 
	detail
		cnt = cnt + 1
 
		if(mod(cnt, 10) = 1 and cnt > 100)
			call alterlist(encntr_detail->list, cnt + 9)
		endif
 
		encntr_detail->cnt = cnt
		encntr_detail->list[cnt].encntr_id					= encntr_id
		encntr_detail->list[cnt].from_accommodation_cd		= from_accommodation_cd
		encntr_detail->list[cnt].from_accommodation			= from_accommodation
		encntr_detail->list[cnt].from_assign_to_loc_dt_tm	= from_assign_to_loc_dt_tm
		encntr_detail->list[cnt].from_rowid					= from_rowid
		encntr_detail->list[cnt].to_accommodation_cd		= to_accommodation_cd
		encntr_detail->list[cnt].to_accommodation			= to_accommodation
		encntr_detail->list[cnt].to_assign_to_loc_dt_tm		= to_assign_to_loc_dt_tm
		encntr_detail->list[cnt].to_rowid					= to_rowid
		encntr_detail->list[cnt].total_time					= total_time
 
	foot report
		call alterlist(encntr_detail->list, cnt)
 
	with nocounter, expand = 1, time = 60
endif
 
;call echorecord(encntr_detail)
 
 
/**************************************************************/
; select encounter accommodation totals data
if (encntr_detail->cnt > 0)
	select into "NL:"
		encntr_id					= encntr_detail->list[d1.seq].encntr_id
		, from_accommodation		= evaluate2(
										if (encntr_detail->list[d1.seq].from_accommodation_cd in (intensivecare_var, intensivecareobs_var))
											critical_care_var
										elseif (encntr_detail->list[d1.seq].from_accommodation_cd in (intermediate_var, intermedcoronary_var))
											step_down_var
										endif
										)
		, total_time				= encntr_detail->list[d1.seq].total_time
 
	from
		(dummyt d1 with seq = encntr_detail->cnt)
 
	plan d1
	where encntr_detail->list[d1.seq].from_accommodation_cd in (
		intensivecare_var, intensivecareobs_var, intermediate_var, intermedcoronary_var
		)
 
	order by
		encntr_id
		, from_accommodation
 
	; populate record structure
	head report
		cnt = 0
 
	head encntr_id
		has_cc = 0
		has_sd = 0
 
	foot from_accommodation
		cnt = cnt + 1
 
		call alterlist(encntr_total->list, cnt)
 
		if (from_accommodation = critical_care_var)
			has_cc = 1
		elseif (from_accommodation = step_down_var)
			has_sd = 1
		endif
 
		encntr_total->cnt = cnt
		encntr_total->list[cnt].encntr_id = encntr_id
		encntr_total->list[cnt].accommodation = from_accommodation
 
		total = sum(total_time)
 
		encntr_total->list[cnt].total_time = total
 
	foot encntr_id
		; add missing record for critical care
		if (has_cc = 0)
			cnt = cnt + 1
 
			call alterlist(encntr_total->list, cnt)
 
			encntr_total->cnt = cnt
			encntr_total->list[cnt].encntr_id = encntr_id
			encntr_total->list[cnt].accommodation = critical_care_var
			encntr_total->list[cnt].total_time = 0.0
		endif
 
		; add missing record for step down
		if (has_sd = 0)
			cnt = cnt + 1
 
			call alterlist(encntr_total->list, cnt)
 
			encntr_total->cnt = cnt
			encntr_total->list[cnt].encntr_id = encntr_id
			encntr_total->list[cnt].accommodation = step_down_var
			encntr_total->list[cnt].total_time = 0.0
		endif
 
	foot report
		call alterlist(encntr_total->list, cnt)
 
		; check for missing encounter records
		for (i = 1 to select_specialty->cnt)
			found = locateval(num, 1, cnt, select_specialty->list[i].encntr_id, encntr_total->list[num].encntr_id)
 
			if (found = 0)
				; add missing record for critical care
				cnt = cnt + 1
 
				call alterlist(encntr_total->list, cnt)
 
				encntr_total->cnt = cnt
				encntr_total->list[cnt].encntr_id = select_specialty->list[i].encntr_id
				encntr_total->list[cnt].accommodation = critical_care_var
				encntr_total->list[cnt].total_time = 0.0
 
				; add missing record for step down
				cnt = cnt + 1
 
				call alterlist(encntr_total->list, cnt)
 
				encntr_total->cnt = cnt
				encntr_total->list[cnt].encntr_id = select_specialty->list[i].encntr_id
				encntr_total->list[cnt].accommodation = step_down_var
				encntr_total->list[cnt].total_time = 0.0
			endif
		endfor
 
	with nocounter, time = 60
endif
 
 
;call echorecord(encntr_total)
 
 
/**************************************************************/
; select final data
if (select_specialty->cnt > 0)
	if (validate(request->batch_selection) != 1 and $output_file = 0)
		; output for manual run
		select into value(output_var)
			facility					= select_specialty->list[d1.seq].facility_desc
			, patient_name				= select_specialty->list[d1.seq].patient_name
 
			, dob						= format(cnvtdatetimeutc(datetimezone(select_specialty->list[d1.seq].dob,
											select_specialty->list[d1.seq].dob_tz), 1), "mm/dd/yyyy;;D")
 
			, fin						= select_specialty->list[d1.seq].fin
			, room_nbr					= select_specialty->list[d1.seq].room_nbr
			, reason_for_visit			= select_specialty->list[d1.seq].reason_for_visit
 
			, attending_phys			= select_specialty->list[d1.seq].attending_phys
			, primary_payer				= select_specialty->list[d1.seq].primary_payer
			, secondary_payer			= select_specialty->list[d1.seq].secondary_payer
 
			, reg_dt_tm					= format(select_specialty->list[d1.seq].reg_dt_tm, "mm/dd/yyyy hh:mm;;Q")
			, days_los					= select_specialty->list[d1.seq].los "###.#"
			, days_critical_care		= encntr_total->list[d2.seq].total_time "###.#"
			, days_step_down			= encntr_total->list[d3.seq].total_time "###.#"
 
		from
			(dummyt d1 with seq = select_specialty->cnt)
 
			, (dummyt d2 with seq = 1)
 
			, (dummyt d3 with seq = 1)
 
		plan d1 where maxrec(d2, encntr_total->cnt)
			and maxrec(d3, encntr_total->cnt)
 
		join d2 where encntr_total->list[d2.seq].encntr_id = select_specialty->list[d1.seq].encntr_id
			and encntr_total->list[d2.seq].accommodation = "Critical Care"
 
		join d3 where encntr_total->list[d3.seq].encntr_id = select_specialty->list[d1.seq].encntr_id
			and encntr_total->list[d3.seq].accommodation = "Step Down"
 
		order by
			facility
			, days_los
 
		with nocounter, separator = " ", format, time = 60
 
	else
		if (validate(request->batch_selection) = 1 or $output_file = 1)
			set modify filestream
		endif
 
		select if (validate(request->batch_selection) = 1 or $output_file = 1)
			with nocounter, nullreport, pcformat (^"^, ^,^, 1), format = stream, format, landscape, compress, maxcol = 192
		else
			with nocounter, nullreport, separator = " ", format, landscape, compress, maxcol = 192
		endif
 
		; output for scheduled run
		into value(output_var)
			facility					= select_specialty->list[d1.seq].facility
			, facility_desc				= format(select_specialty->list[d1.seq].facility_desc, ";C;")
			, facility_alias			= select_specialty->list[d1.seq].facility_alias
 
			, patient_name				= select_specialty->list[d1.seq].patient_name
 
			, dob						= format(cnvtdatetimeutc(datetimezone(select_specialty->list[d1.seq].dob,
											select_specialty->list[d1.seq].dob_tz), 1), "mm/dd/yyyy;;D")
 
			, fin						= select_specialty->list[d1.seq].fin
			, room_nbr					= select_specialty->list[d1.seq].room_nbr
			, reason_for_visit			= select_specialty->list[d1.seq].reason_for_visit
 
			, attending_phys			= select_specialty->list[d1.seq].attending_phys
			, primary_payer				= select_specialty->list[d1.seq].primary_payer
			, secondary_payer			= select_specialty->list[d1.seq].secondary_payer
 
			, reg_dt_tm					= format(select_specialty->list[d1.seq].reg_dt_tm, "mm/dd/yyyy hh:mm;;Q")
			, days_los					= select_specialty->list[d1.seq].los "###.#"
			, days_critical_care		= encntr_total->list[d2.seq].total_time "###.#"
			, days_step_down			= encntr_total->list[d3.seq].total_time "###.#"
 
		from
			(dummyt d1 with seq = select_specialty->cnt)
 
			, (dummyt d2 with seq = 1)
 
			, (dummyt d3 with seq = 1)
 
		plan d1 where maxrec(d2, encntr_total->cnt)
			and maxrec(d3, encntr_total->cnt)
 
		join d2 where encntr_total->list[d2.seq].encntr_id = select_specialty->list[d1.seq].encntr_id
			and encntr_total->list[d2.seq].accommodation = "Critical Care"
 
		join d3 where encntr_total->list[d3.seq].encntr_id = select_specialty->list[d1.seq].encntr_id
			and encntr_total->list[d3.seq].accommodation = "Step Down"
 
		order by
			facility
			, select_specialty->list[d1.seq].los
 
		head report
			fcnt = 0
			pagenum = 0
 
		head page
			if (fcnt = 0)
				row + 1
			endif
 
			pagenum = pagenum + 1
 
			col 0	"Date:"
			col 7	dt = format(sysdate, "mm/dd/yyyy;;D"), dt
			col 180	"Page:"
			col 187	pagenum "###"
			row + 1
 
			col 0	"Time:"
			col 7	tm = format(sysdate, "hh:mm:ss;;S"), tm
			row + 1
 
			col 0	"Report:"
			col 9	prog = curprog, prog
			row + 2
 
			col 0	"Facility ID:"
			col 14	facility_alias
			row + 2
 
		 	title = "Select Specialty Patient List"
		 	subtitle = facility_desc
 
			call center(title, 1, 192)
			row + 1
			call center(subtitle, 1, 192)
			row + 2
			 
			col 0	"PATIENT NAME"
			col 25	"DOB"
			col 38	"FIN"
			col 51	"ROOM"
			col 58	"REASON FOR VISIT"
			col 85	"ATTENDING PHYS"
			col 110	"PRIMARY PAYER"
			col 135	"REG DATE TIME"
			col 155	"LOS"
			col 163	"CRITICAL CARE"
			col 178	"STEP DOWN"
			row + 1
 
			col 110	"SECONDARY PAYER"
			col 154	"(DAYS)"
			col 166	"(DAYS)"
			col 179	"(DAYS)"
			row + 1
 
			col 0	s = fillstring(190, "-"), s
			row + 1
 
		head facility
			fcnt = fcnt + 1
 
			if (fcnt > 1)
				pagenum = 0
				break
			endif
 
		detail
			if (row > 46)
				break
			endif
 
			col 0	pn = substring(1, 23, patient_name), pn
			col 25	dob
			col 38	f = substring(1, 10, fin), f
			col 51	r = substring(1, 10, room_nbr), r
			col 58	rv = substring(1, 23, reason_for_visit), rv
			col 85	ap = substring(1, 23, attending_phys), ap
			col 110	pp = substring(1, 23, primary_payer), pp
			col 135	reg_dt_tm
			col 154	days_los
			col 166	days_critical_care
			col 179	days_step_down
 
			if (size(trim(secondary_payer, 3)) > 0)
				row + 1
				col 110	sp = substring(1, 23, secondary_payer), sp
			endif
 
			row + 2
 
		with nocounter
 
 
		/**************************************************************/
		; copy file to AStream
		if (validate(request->batch_selection) = 1 or $output_file = 1)
			set cmd = build2("cp ", temppath2_var, " ", filepath_var)
			set len = size(trim(cmd))
 
			call dcl(cmd, len, stat)
			call echo(build2(cmd, " : ", stat))
		endif
	endif
endif
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 
