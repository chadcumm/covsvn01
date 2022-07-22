/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		08/08/2018
	Solution:			Perioperative
	Source file name:	cov_peri_AnesAccounts.prg
	Object name:		cov_peri_AnesAccounts
	Request #:			
 
	Program purpose:	Basic anesthesia data for Anesthesia third-party billers.
 
	Executing from:		CCL
 
 	Special Notes:		
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	---------------------------------------
 
******************************************************************************/
 
drop program cov_peri_AnesAccounts:DBA go
create program cov_peri_AnesAccounts:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility" = 0.0
	, "Start Date" = "SYSDATE"
	, "Stop Date" = "SYSDATE"
 
with OUTDEV, facility, start_datetime, stop_datetime
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
declare wrap(data = vc) 		= vc
declare wrap2(data = vc) 		= vc
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare ssn_var 				= f8 with constant(uar_get_code_by("DISPLAYKEY", 4, "SSN"))
declare facility_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 222, "FACILITYS"))
declare finnbr_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare mrn_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "MRN"))
declare prsnl_anes_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 254571, "ANESTHESIOLOGISTOFRECORD"))
declare num						= i4 with noconstant(0)
declare maxper					= i4 with noconstant(0)
 
declare filepath_var			= vc with noconstant("")
declare output_var				= vc with noconstant("")

declare header_main				= vc
declare header_personnel		= vc

declare output_main				= vc
declare output_personnel		= vc

declare op_facility_var			= c2 with noconstant("")
 
 
; define operator for $facility
if (substring(1, 1, reflect(parameter(parameter2($facility), 0))) = "L") ; multiple values selected
    set op_facility_var = "IN"
elseif (parameter(parameter2($facility), 1) = 0.0) ; any selected
    set op_facility_var = "!="
else ; single value selected
    set op_facility_var = "="
endif
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
record main (
	1 p_facility						= vc
	1 p_fac								= vc
	1 p_start_datetime					= vc
	1 p_stop_datetime					= vc
 
	1 main_cnt							= i4
	1 list[*]
		; surgical case
		2 surg_case_id					= f8
		2 surg_case_nbr					= vc
 
	 	; patient
	 	2 person_id						= f8
		2 patient_name					= vc
		2 patient_ssn					= vc
		2 patient_dob					= vc
		2 patient_age					= vc
		2 patient_gender				= vc
		2 patient_fin					= vc
		2 patient_mrn					= vc
 
		; encounter
		2 encntr_id						= f8
 
		; facility/surgery
		2 facility						= vc
		2 facility_name					= vc		
 
		; anesthesia
		2 sa_anesthesia_record_id		= f8
 
		; personnel
		2 per_cnt						= i4
		2 personnel[*]
			3 person_id					= f8
			3 name_full_formatted		= vc
)
 
 
/**************************************************************/
; populate main record structure with prompt data
set main->p_facility = evaluate(op_facility_var, "IN", "Multiple", "!=", "Any (*)", "=", uar_get_code_description($facility))
set main->p_fac = evaluate(op_facility_var, "IN", "Multiple", "!=", "Any (*)", "=", uar_get_code_display($facility))
set main->p_start_datetime = format(cnvtdate2($start_datetime, "dd-mmm-yyyy hh:mm"), "mm/dd/yyyy;;d")
set main->p_stop_datetime = format(cnvtdate2($stop_datetime, "dd-mmm-yyyy hh:mm"), "mm/dd/yyyy;;d")
 
; build file name
;set filepath_var = build("cer_temp:Cov_AnesBillingSummary_", sched_fac->p_fac, ".csv")
;
;if (validate(request->batch_selection) = 1)
;	set output_var = value(filepath_var)
;else
	set output_var = value($OUTDEV)
;endif
 
 
/**************************************************************/
; select surgery/anesthesia data
select into "NL:"
from
	; surgical case
	SURGICAL_CASE sc
 
 	; patient
	, (inner join PERSON p on p.person_id = sc.person_id)
 
	, (left join PERSON_ALIAS pa on pa.person_id = p.person_id
		and pa.person_alias_type_cd = ssn_var)
 
	; encounter
	, (inner join ENCOUNTER e on e.encntr_id = sc.encntr_id)
 
	, (left join ENCNTR_ALIAS eaf on eaf.encntr_id = e.encntr_id
		and eaf.encntr_alias_type_cd = finnbr_var)
 
	, (left join ENCNTR_ALIAS eam on eam.encntr_id = e.encntr_id
		and eam.encntr_alias_type_cd = mrn_var)
 
	; facility
	, (inner join LOCATION l on l.location_cd = e.loc_facility_cd
		and l.location_type_cd = facility_var
		and operator(l.location_cd, op_facility_var, $facility))
 
	, (inner join ORGANIZATION lo on lo.organization_id = l.organization_id)
 
	; surgery/anesthesia 
	, (inner join SA_ANESTHESIA_RECORD sar on sar.surgical_case_id = sc.surg_case_id
		and sar.active_ind = 1
		and sar.event_id > 0.0) ; 0.0 = finalized
 
	, (inner join SA_ANESTHESIA_REC_STATUS sars on sars.sa_anesthesia_record_id = sar.sa_anesthesia_record_id
		and sars.active_ind = 1
		and sars.status_type_flag = 0) ; 0 = finalized
 
where
	sc.surg_start_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($stop_datetime)
	and sc.surg_stop_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($stop_datetime)
 
order by
	sc.surg_case_nbr_formatted
 
 
; populate main record structure with surgery/anesthesia data
head report
	cnt = 0
 
	call alterlist(main->list, 100)
 
head sc.surg_case_id
	cnt = cnt + 1
 
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(main->list, cnt + 9)
	endif
 
	; surgical case
	main->list[cnt].surg_case_id = sc.surg_case_id
	main->list[cnt].surg_case_nbr = sc.surg_case_nbr_formatted
 
 	; patient
	main->list[cnt].person_id = p.person_id
	main->list[cnt].patient_name = p.name_full_formatted
	main->list[cnt].patient_ssn = pa.alias
	main->list[cnt].patient_dob = format(p.birth_dt_tm, "mm/dd/yy")
	main->list[cnt].patient_age = cnvtage(p.birth_dt_tm)
	main->list[cnt].patient_gender = uar_get_code_display(p.sex_cd)
	main->list[cnt].patient_fin = eaf.alias
	main->list[cnt].patient_mrn = build(
		main->list[cnt].facility
		, substring(textlen(trim(eam.alias, 3)) + 1, 10, build("0000000000", eam.alias))
	)
 
	; encounter
	main->list[cnt].encntr_id = e.encntr_id
 
	; facility/surgery
	main->list[cnt].facility = uar_get_code_display(l.location_cd)
	main->list[cnt].facility_name = lo.org_name
 
	; anesthesia
	main->list[cnt].sa_anesthesia_record_id = sar.sa_anesthesia_record_id
 
foot report
	main->main_cnt = cnt
 
	call alterlist(main->list, cnt)
 
with time = 30, nocounter
 
 
/**************************************************************/
; select personnel data
select into "NL:"
from
	SA_PRSNL_ACTIVITY spa
 
	, (inner join PRSNL per on per.person_id = spa.prsnl_id
		and per.active_ind = 1)
 
where expand(num, 1, size(main->list, 5), spa.sa_anesthesia_record_id, main->list[num].sa_anesthesia_record_id)
	and spa.prsnl_activity_type_cd = prsnl_anes_var
	and spa.active_ind = 1
 
order by
	spa.sa_anesthesia_record_id
	, per.name_full_formatted
 
 
; populate main record structure with personnel data
head spa.sa_anesthesia_record_id
	numx = 0
	idx = 0
	cnt = 0
 
	idx = locateval(numx, 1, size(main->list, 5), spa.sa_anesthesia_record_id, main->list[numx].sa_anesthesia_record_id)
 
	if (idx > 0)
		call alterlist(main->list[idx].personnel, 10)
	endif
 
detail
	if (idx > 0)
		cnt = cnt + 1
 
		if (mod(cnt, 10) = 1 and cnt > 10)
			call alterlist(main->list[idx].personnel, cnt + 9)
		endif
 
		main->list[idx].personnel[cnt].person_id = per.person_id
		main->list[idx].personnel[cnt].name_full_formatted = per.name_full_formatted
	endif
 
foot spa.sa_anesthesia_record_id
	main->list[idx].per_cnt = cnt
 
	call alterlist(main->list[idx].personnel, cnt)
 
with time = 30, nocounter, expand = 1
 
 
/**************************************************************/
; build output
if (main->main_cnt > 0)
	; select main record structure data
	select into value(output_var)
	from
		(DUMMYT dt with seq = main->main_cnt)
	order by
		dt.seq
 
	; build output
	head report
		header_main = ""
		
		header_main = build( 
			; facility/surgery
			wrap2("FACILITY")
			, wrap2("FACILITY_NAME")
			
			; surgical case
			, wrap2("SURG_CASE_NBR")
 
	 		; patient
			, wrap2("PATIENT_NAME")
			, wrap2("FIN")
			
			; personnel
			, wrap2("ANESTHESIOLOGIST")
		)
 
		; personnel - additional
		num = main->main_cnt
		maxper = 0
		
		for(i = 1 to num)
			if (main->list[i].per_cnt > maxper)
				maxper = main->list[i].per_cnt
			endif
		endfor
				
		if (maxper > 1)
			for(i = 2 to maxper)
				header_main = build(
					header_main
					, wrap2(build("ANESTHESIOLOGIST_", i))
				)
			endfor
		endif				
 
		header_main = replace(header_main, ",", "", 2)
		
		col 0 header_main
		row + 1
		
	head dt.seq 
		; personnel
		output_personnel = ""
		num = main->list[dt.seq].per_cnt
 
		for(i = 1 to num)			
			output_personnel = build(
				output_personnel
				, wrap2(main->list[dt.seq].personnel[i].name_full_formatted)
			)
		endfor
 
		if (output_personnel = "")		
			output_personnel = wrap2("")
		endif
 
		; main
		output_main = ""
		
		output_main = build( 
			; facility/surgery
			wrap2(main->list[dt.seq].facility)
			, wrap2(main->list[dt.seq].facility_name)
			
			; surgical case
			, wrap2(main->list[dt.seq].surg_case_nbr)
 
	 		; patient
			, wrap2(main->list[dt.seq].patient_name)
			, wrap2(main->list[dt.seq].patient_fin)
 
			; personnel
			, trim(output_personnel, 3)
		)
 
		output_main = replace(output_main, ",", "", 2)
 
	foot dt.seq
		col 0 output_main
		row + 1
 
	with time = 30, nocounter, maxcol = 32000, format = stream, formfeed = none
endif
 
 
call echo(build2("filepath_var = ", filepath_var))
call echorecord(main)
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
%i cust_script:cov_CommonLibrary.inc
 
 
end
go
 
