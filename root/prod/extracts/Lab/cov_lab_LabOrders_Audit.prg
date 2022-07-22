/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		05/08/2019
	Solution:			PathNet General Laboratory
	Source file name:	cov_lab_LabOrders_Audit.prg
	Object name:		cov_lab_LabOrders_Audit
	Request #:			4631
 
	Program purpose:	Lists active lab orders on:
							- scheduled encounters
							- clinic encounters
 
	Executing from:		CCL
 
 	Special Notes:		Output files (file_type):
 							0 = lab_orders_scheduled.txt
 							1 = lab_orders_clinic.txt
 							2 = lab_orders_clinic_monthly.txt
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 	07/10/2019	Todd A. Blanchard		Changed page numbering to reset for
 										each facility.
 										Changed report headers to get report
 										name dynamically.
 	07/12/2019	Todd A. Blanchard		Changed definition of filepath variables.
 
******************************************************************************/
 
drop program cov_lab_LabOrders_Audit:DBA go
create program cov_lab_LabOrders_Audit:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date" = "SYSDATE"               ;* Previous Day
	, "End Date" = "SYSDATE"                 ;* Previous Day
	, "File Type" = 0                        ;* File type: scheduled or clinic
	, "Output To File" = 0                   ;* Output to file
 
with OUTDEV, start_datetime, end_datetime, file_type, output_file
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare start_datetime			= dq8 with noconstant(cnvtlookbehind("1,D", cnvtdatetime(curdate, 000000)))
declare end_datetime			= dq8 with noconstant(cnvtlookbehind("1,D", cnvtdatetime(curdate, 235959)))
declare fin_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare scheduled_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "SCHEDULED"))
declare clinic_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "CLINIC"))
declare legacydata_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "LEGACYDATA"))
declare phonemessage_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "PHONEMESSAGE"))
declare resultsonly_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "RESULTSONLY"))
declare laboratory_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 6000, "LABORATORY"))
declare canceled_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "CANCELED"))
declare order_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "ORDER"))
declare covenant_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 73, "COVENANT"))
 
declare novalue					= vc with constant("Not Available")
declare num						= i4 with noconstant(0)
declare crlf					= vc with constant(build(char(13), char(10)))
 
declare file_sch_var			= vc with constant("lab_orders_scheduled.txt")
declare file_clin_var			= vc with constant(build("lab_orders_clinic", evaluate2(if ($file_type = 2) "_monthly" endif), ".txt"))
 
declare temppath_var			= vc with constant("cer_temp:")
declare temppath_sch_var		= vc with constant(build(temppath_var, file_sch_var))
declare temppath_clin_var		= vc with constant(build(temppath_var, file_clin_var))
 
declare temppath2_var			= vc with constant("$cer_temp/")
declare temppath2_sch_var		= vc with constant(build(temppath2_var, file_sch_var))
declare temppath2_clin_var		= vc with constant(build(temppath2_var, file_clin_var))
 
declare filepath_var			= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
														 "_cust/to_client_site/ClinicalAncillary/Lab/"))
													 
declare filepath_sch_var		= vc with constant(build(filepath_var, file_sch_var)) 
declare filepath_clin_var		= vc with constant(build(filepath_var, file_clin_var))
 
declare output_sch_var			= vc with noconstant("")
declare output_clin_var			= vc with noconstant("")
 
declare cmd						= vc with noconstant("")
declare len						= i4 with noconstant(0)
declare stat					= i4 with noconstant(0)
 
 
 
; define start and end date values
if (validate(request->batch_selection) != 1)
	set start_datetime = cnvtdatetime($start_datetime)
	set end_datetime = cnvtdatetime($end_datetime)
else
	if ($file_type = 2)
		set start_datetime = cnvtdatetime(datetimefind(cnvtlookbehind("1,M"), "M", "B", "B"))
		set end_datetime = cnvtdatetime(datetimefind(cnvtlookbehind("1,M"), "M", "E", "E"))
	endif
endif
 
 
; define output value
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set output_sch_var = value(temppath_sch_var)
	set output_clin_var = value(temppath_clin_var)
else
	set output_sch_var = value($OUTDEV)
	set output_clin_var = value($OUTDEV)
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
 
/**************************************************************/
; select active lab orders on scheduled encounters data
if ($file_type = 0)
	if (validate(request->batch_selection) = 1 or $output_file = 1)
		set modify filestream
	endif
 
	select if (validate(request->batch_selection) = 1 or $output_file = 1)
		with nocounter, nullreport, pcformat (^"^, ^,^, 1), format = stream, format, landscape, compress, maxcol = 192
	else
		with nocounter, nullreport, separator = " ", format, landscape, compress, maxcol = 192
	endif
 
	distinct into value(output_sch_var)
		fin						= trim(cnvtalias(ea.alias, ea.alias_pool_cd), 3)
		, patient_name			= p.name_full_formatted
		, person_id				= p.person_id
 
		, facility				= trim(uar_get_code_display(e.loc_facility_cd), 3)
		, facility_desc			= trim(uar_get_code_description(e.loc_facility_cd), 3)
		, facility_alias		= cvo.alias
 
		, solution				= trim(uar_get_code_display(o.catalog_type_cd), 3)
		, order_desc			= trim(o.order_mnemonic, 3)
 
		, order_id				= o.order_id
		, order_dt_tm			= oa.action_dt_tm
		, order_placed_by		= per.name_full_formatted
 
		, specimen_collect_by	= od2.oe_field_display_value
 
	from
		ENCOUNTER e
 
		, (inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
			and ea.encntr_alias_type_cd = fin_var
			and ea.alias_pool_cd >= 0.0
			and ea.end_effective_dt_tm > cnvtdatetime(sysdate)
			and ea.active_ind = 1)
 
		, (inner join ORDERS o on o.encntr_id = e.encntr_id
			and o.catalog_type_cd = laboratory_var
			and o.order_status_cd != canceled_var
			and o.active_ind = 1)
 
		, (inner join ORDER_ACTION oa on oa.order_id = o.order_id
			and oa.action_type_cd = order_var
			and oa.action_dt_tm between cnvtdatetime(start_datetime) and cnvtdatetime(end_datetime))
 
		, (left join ORDER_DETAIL od on od.order_id = o.order_id
			and od.oe_field_meaning = "SPECRECDLOC")
 
		, (left join ORDER_DETAIL od2 on od2.order_id = o.order_id
			and od2.oe_field_meaning = "COLLBY"
			)
 
		, (inner join CODE_VALUE_OUTBOUND cvo on cvo.code_value = e.loc_facility_cd
			and cvo.contributor_source_cd = covenant_var)
 
		, (inner join PERSON p on p.person_id = o.person_id)
 
		, (inner join PRSNL per on per.person_id = oa.action_personnel_id)
 
	where
		e.encntr_type_cd = scheduled_var
		and e.loc_facility_cd in (
			select cv.code_value
			from CODE_VALUE cv
			where
				cv.code_set = 220
				and cv.cdf_meaning = "FACILITY"
				and cv.display_key in ("FSR", "MMC", "FLMC", "MHHS", "PW", "RMC", "LCMC")
		)
		and e.active_ind = 1
 
	order by
		facility
		, patient_name
		, person_id
		, order_id
 
	head report
		fcnt = 0
		title_size = 0
		subtitle_size = 0
		pagenum = 0
 
	head page
		if (fcnt = 0)
			row + 1
		endif
			
		pagenum = pagenum + 1
 
		col 0	"Date:"
		col 7	dt = format(sysdate, "mm/dd/yyyy;;d"), dt
		col 180	"Page:"
		col 187	pagenum "###"
		row + 1
 
		col 0	"Time:"
		col 7	tm = format(sysdate, "hh:mm:ss;;s"), tm
		row + 1
 
		col 0	"Report:"
		col 9	prog = curprog, prog
		row + 2
 
		col 0	"Facility ID:"
		col 14	facility_alias
		row + 2
 
	 	title = "Hospital Labs Completed on Scheduled Encounters"
		title_size = (100 - (size(title) / 2))
 
		col title_size		title
		row + 2
 
		col 0	"FIN"
		col 15	"PATIENT NAME"
		col 40	"FACILITY"
		col 55	"SOLUTION"
		col 68	"SPEC COLLECTED BY"
		col 90	"ORDER DATE"
		col 110	"ORDER PLACED BY"
		col 142	"ORDER DESC"
		row + 1
 
	head facility
		fcnt = fcnt + 1
 
		if (fcnt > 1)
			pagenum = 0
			break
		endif
 
	head person_id
		null
 
	detail
		if (row > 46)
			break
		endif
 
		col 0	fin
		col 15	patient_name
		col 40	fac = substring(1, 13, facility), fac
		col 55	solution
		col 68	scb = substring(1, 16, specimen_collect_by), scb
		col 90	order_dt_tm "@SHORTDATETIME"
		col 110	opb = substring(1, 30, order_placed_by), opb
		col 142	od = substring(1, 40, order_desc), od
		row + 1
 
	foot person_id
		row + 1
 
	with nocounter
 
 
	/**************************************************************/
	; copy file to AStream
	if (validate(request->batch_selection) = 1 or $output_file = 1)
		set cmd = build2("cp ", temppath2_sch_var, " ", filepath_sch_var)
		set len = size(trim(cmd))
 
		call dcl(cmd, len, stat)
		call echo(build2(cmd, " : ", stat))
	endif
endif
 
 
/**************************************************************/
; select active lab orders on clinic encounters data
if (($file_type = 1) or ($file_type = 2))
	if (validate(request->batch_selection) = 1 or $output_file = 1)
		set modify filestream
	endif
 
	select if (validate(request->batch_selection) = 1 or $output_file = 1)
		with nocounter, nullreport, pcformat (^"^, ^,^, 1), format = stream, format, landscape, compress, maxcol = 192
	else
		with nocounter, nullreport, separator = " ", format, landscape, compress, maxcol = 192
	endif
 
	distinct into value(output_clin_var)
		fin						= trim(cnvtalias(ea.alias, ea.alias_pool_cd), 3)
		, patient_name			= p.name_full_formatted
		, person_id				= p.person_id
 
		, facility				= trim(uar_get_code_display(e.loc_facility_cd), 3)
		, facility_desc			= trim(uar_get_code_description(e.loc_facility_cd), 3)
		, facility_alias		= substring(1, findstring(" ", cv.display) - 1, cv.display)
 
		, solution				= trim(uar_get_code_display(o.catalog_type_cd), 3)
		, order_desc			= trim(o.order_mnemonic, 3)
 
		, order_id				= o.order_id
		, order_dt_tm			= oa.action_dt_tm "@SHORTDATETIME"
		, order_placed_by		= per.name_full_formatted
 
		, specimen_collect_by	= od2.oe_field_display_value
 
	from
		ENCOUNTER e
 
		, (inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
			and ea.encntr_alias_type_cd = fin_var
			and ea.alias_pool_cd >= 0.0
			and ea.end_effective_dt_tm > cnvtdatetime(sysdate)
			and ea.active_ind = 1)
 
		, (inner join ORDERS o on o.encntr_id = e.encntr_id
			and o.catalog_type_cd = laboratory_var
			and o.order_status_cd != canceled_var
			and o.active_ind = 1)
 
		, (inner join ORDER_ACTION oa on oa.order_id = o.order_id
			and oa.action_type_cd = order_var
			and oa.action_dt_tm between cnvtdatetime(start_datetime) and cnvtdatetime(end_datetime))
 
		, (inner join ORDER_DETAIL od on od.order_id = o.order_id
			and od.oe_field_meaning = "SPECRECDLOC")
 
		, (left join ORDER_DETAIL od2 on od2.order_id = o.order_id
			and od2.oe_field_meaning = "COLLBY"
			)
 
		, (inner join CODE_VALUE cv on cv.code_value = od.oe_field_value)
 
		, (inner join PERSON p on p.person_id = o.person_id)
 
		, (inner join PRSNL per on per.person_id = oa.action_personnel_id)
 
	where
		e.encntr_type_cd in (clinic_var, legacydata_var, phonemessage_var, resultsonly_var)
		and e.loc_facility_cd > 0.0
		and e.active_ind = 1
 
	order by
		facility_alias
		, patient_name
		, person_id
		, order_id
 
	head report
		fcnt = 0
		title_size = 0
		subtitle_size = 0
		pagenum = 0
 
	head page
		if (fcnt = 0)
			row + 1
		endif
			
		pagenum = pagenum + 1
 
		col 0	"Date:"
		col 7	dt = format(sysdate, "mm/dd/yyyy;;d"), dt
		col 180	"Page:"
		col 187	pagenum "###"
		row + 1
 
		col 0	"Time:"
		col 7	tm = format(sysdate, "hh:mm:ss;;s"), tm
		row + 1
 
		col 0	"Report:"
		col 9	prog = curprog, prog
		row + 2
 
		col 0	"Facility ID:"
		col 14	facility_alias
		row + 2
 
	 	title = "Hospital Labs Completed on Non-Hospital Encounters"
		title_size = (100 - (size(title) / 2))
	 	subtitle = build2("Monthly: ", format(start_datetime, "mm/dd/yyyy;;d"), " to ", format(end_datetime, "mm/dd/yyyy;;d"))
	 	subtitle_size = (100 - (size(subtitle) / 2))
 
		col title_size		title
 
		if ($file_type = 2)
			row + 1
			col subtitle_size	subtitle
		endif
 
		row + 2
 
		col 0	"FIN"
		col 15	"PATIENT NAME"
		col 40	"CLINIC"
		col 55	"SOLUTION"
		col 68	"SPEC COLLECTED BY"
		col 90	"ORDER DATE"
		col 110	"ORDER PLACED BY"
		col 142	"ORDER DESC"
		row + 1
 
	head facility_alias
		fcnt = fcnt + 1
 
		if (fcnt > 1)
			pagenum = 0
			break
		endif
 
	head person_id
		null
 
	detail
		if (row > 46)
			break
		endif
 
		col 0	fin
		col 15	patient_name
		col 40	fac = substring(1, 13, facility), fac
		col 55	solution
		col 68	scb = substring(1, 16, specimen_collect_by), scb
		col 90	order_dt_tm "@SHORTDATETIME"
		col 110	opb = substring(1, 30, order_placed_by), opb
		col 142	od = substring(1, 40, order_desc), od
		row + 1
 
	foot person_id
		row + 1
 
	with nocounter
 
 
	/**************************************************************/
	; copy file to AStream
	if (validate(request->batch_selection) = 1 or $output_file = 1)
		set cmd = build2("cp ", temppath2_clin_var, " ", filepath_clin_var)
		set len = size(trim(cmd))
 
		call dcl(cmd, len, stat)
		call echo(build2(cmd, " : ", stat))
	endif
endif
 
 
;go to exitscript
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript
 
end
go
 
 
