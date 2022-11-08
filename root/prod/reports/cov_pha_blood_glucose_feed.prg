 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Paramasivam
	Date Written:		Jan'2020
	Solution:			Pharmacy
	Source file name:  	cov_pha_blood_glucose_feed.prg
	Object name:		cov_pha_blood_glucose_feed
	Request#:			7042
	Program purpose:	      Glucose feed set up to Strata
	Executing from:		Ops
  	Special Notes:          Based on cov_pha_bloodglucose_heparin.prg but feed set up only for Glucose
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer		Comment
------------------------------------------------------------------------------
11/02/22   Geetha     CR#13889  Add Glucose Lvl to the feed
 
******************************************************************************/
 
drop program cov_pha_blood_glucose_feed:dba go
create program cov_pha_blood_glucose_feed:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
 
with OUTDEV, start_datetime, end_datetime
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare fin_var 	 = f8 with constant(uar_get_code_by("MEANING",319,"FIN NBR")),protect
declare cmrn_var   = f8 with constant(uar_get_code_by("MEANING",4,"CMRN")),protect
declare mrn_var    = f8 with constant(uar_get_code_by("MEANING",319,"MRN")),protect
 

declare glucose_poc_var    = f8 with constant(value(uar_get_code_by("DISPLAY", 72,"Glucose POC"))),protect
declare glucose_art_var    = f8 with constant(value(uar_get_code_by("DISPLAY", 72,"Glucose Art"))),protect
declare blood_glucose_var  = f8 with constant(value(uar_get_code_by("DISPLAY", 72,"Blood Glucose"))),protect
declare glucose_lvl_var    = f8 with constant(value(uar_get_code_by("DISPLAY", 72,"Glucose Lvl"))),protect  
declare ptt_var            = f8 with constant(value(uar_get_code_by("DISPLAY", 72,"Partial Thromboplastin Time"))),protect

declare lab_parser_var = vc
declare result_parser_var = vc
 
;Ops setup
declare output_orders = vc
declare cmd  = vc with noconstant("")
declare len  = i4 with noconstant(0)
declare stat = i4 with noconstant(0)
declare iOpsInd      = i2 WITH NOCONSTANT(0), PROTECT
 
;declare filename_var = vc WITH constant('cer_temp:pha_gluco_test.txt'), PROTECT
;declare ccl_filepath_var = vc WITH constant('$cer_temp/pha_gluco_test.txt'), PROTECT
 
declare filename_var = vc WITH constant('cer_temp:pha_glucose_measure.txt'), PROTECT
declare ccl_filepath_var = vc WITH constant('$cer_temp/pha_glucose_measure.txt'), PROTECT
declare astream_filepath_var = vc with noconstant("/cerner/w_custom/p0665_cust/to_client_site/ClinicalAncillary/Pharmacy/PAExports/")
 
;request from Ops?
if(validate(request->batch_selection) = 1)
 	set iOpsInd = 1
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
Record gluco(
	1 elist[*]
		2 facility = vc
		2 fin = vc
		2 mrn = vc
		2 cmrn = vc
		2 patient_name = vc
		2 measure_name = vc
		2 result_value = vc
		2 result_unit = vc
		2 result_dt = vc
		2 verified_dt = vc
		2 event_id = f8
)
 
;------------------------------------------------------------------------------------------------------
;Get patient population for Glucose
 
select into $outdev
 
facility = uar_get_code_display(e.loc_facility_cd)
, fin = ea.alias
, e.person_id
, e.encntr_id
, mrn = ea1.alias
, cmrn = pa.alias
, pat_name = trim(p.name_full_formatted)
, ce.event_cd, event = uar_get_code_display(ce.event_cd)
, res_val = cnvtint(ce.result_val)
, unit = uar_get_code_display(ce.result_units_cd)
, result_status = uar_get_code_display(ce.result_status_cd)
, verifi_dt  = format(ce.verified_dt_tm, "mm/dd/yyyy hh:mm;;d")
, ce.event_id
 
from
 
 encounter e
 
 ,(left join encntr_alias ea on ea.encntr_id = e.encntr_id
 		and ea.encntr_alias_type_cd = fin_var
 		and ea.active_ind = 1
 		and ea.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
 )
 ,(left join encntr_alias ea1 on ea1.encntr_id = e.encntr_id
 		and ea1.encntr_alias_type_cd = mrn_var
 		and ea1.active_ind = 1
 		and ea1.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
 )
 ,(left join person_alias pa on pa.person_id = e.person_id
 		and pa.person_alias_type_cd = cmrn_var
 		and pa.active_ind = 1
 		and pa.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
 )
 
, clinical_event ce
, person p
 
plan e where e.loc_facility_cd in(2552503645.00, 2552503635.00, 21250403.00,2552503653.00,2552503639.00
						,2552503613.00,2552503649.00, 2552503657.00)
	and e.encntr_type_cd = 309308.00 ;Inpatient
	and e.disch_dt_tm is null
	and e.active_ind = 1
 
join ea
join ea1
join pa
 
join ce where ce.person_id = e.person_id
	and ce.verified_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and ce.result_status_cd = 25.00 ;Auth (Verified)
	and ce.result_val != " "
	and ce.event_cd in(glucose_poc_var, glucose_art_var, glucose_lvl_var, blood_glucose_var)
	and isnumeric(ce.result_val) > 0
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
order by e.loc_facility_cd, e.encntr_id, ce.event_cd, ce.event_id
 
Head report
	cnt = 0
Head ce.event_id
	cnt += 1
	call alterlist(gluco->elist, cnt)
Detail
	gluco->elist[cnt].facility = facility
	gluco->elist[cnt].fin = fin
	gluco->elist[cnt].mrn = mrn
	gluco->elist[cnt].cmrn = cmrn
	gluco->elist[cnt].patient_name = pat_name
	gluco->elist[cnt].measure_name = event
	gluco->elist[cnt].result_value = trim(ce.result_val)
	gluco->elist[cnt].result_unit = unit
	gluco->elist[cnt].result_dt = format(ce.event_end_dt_tm, "mm/dd/yyyy hh:mm;;d")
	gluco->elist[cnt].verified_dt = verifi_dt
	gluco->elist[cnt].event_id = ce.event_id
 
with nocounter
 
;-------------------------------------------------------------------------------------------------
;Ops set up
if(iOpsInd = 1) ;Ops
 
   Select into value(filename_var)
	from (dummyt d WITH seq = value(size(gluco->elist,5)))
	order by d.seq
 
	;build output
	Head report
		file_header_var = build(
			wrap3("Start Date")
			,wrap3("End date")
			,wrap3("Facility")
			,wrap3("Account Number")
			,wrap3("mrn")
			,wrap3("cmrn")
			,wrap3("Patient Name")
			,wrap3("Measure")
			,wrap3("Result_value")
			,wrap3("Result_unit")
			,wrap3("Result_dt")
			,wrap3("Verified_dt")
			,wrap3("event_id")
			)
 
	col 0 file_header_var
	row + 1
 
	Head d.seq
		output_orders = ""
		output_orders = build(output_orders
			,wrap3(format(cnvtdatetime($start_datetime), 'mm/dd/yyyy hh:mm;;q'))
			,wrap3(format(cnvtdatetime($end_datetime), 'mm/dd/yyyy hh:mm;;q'))
			,wrap3(gluco->elist[d.seq].facility)
			,wrap3(gluco->elist[d.seq].fin)
			,wrap3(gluco->elist[d.seq].mrn)
			,wrap3(gluco->elist[d.seq].cmrn)
			,wrap3(gluco->elist[d.seq].patient_name)
			,wrap3(gluco->elist[d.seq].measure_name)
			,wrap3(gluco->elist[d.seq].result_value)
			,wrap3(gluco->elist[d.seq].result_unit)
			,wrap3(gluco->elist[d.seq].result_dt)
			,wrap3(gluco->elist[d.seq].verified_dt)
			,wrap3(cnvtstring(gluco->elist[d.seq].event_id))
			)
 
 		output_orders = trim(output_orders, 3)
 
	 Foot d.seq
	 	col 0 output_orders
	 	row + 1
 
	with time = 30, nocounter, maxcol = 32000, format = stream, formfeed = none
 
	;Move file to Astream folder
  	set cmd = build2("mv ", ccl_filepath_var, " ", astream_filepath_var)
  	;set cmd = build2("cp ", ccl_filepath_var, " ", astream_filepath_var)
	set len = size(trim(cmd))
 	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
 
endif ;ops
 
;---------------------------------------------------------------------------------------------
 
;Screen display
/*
select into $outdev
	facility = substring(1, 30, gluco->elist[d1.seq].facility)
	,fin = substring(1, 30, gluco->elist[d1.seq].fin)
	,mrn = substring(1, 30, gluco->elist[d1.seq].mrn)
	,cmrn = substring(1, 30, gluco->elist[d1.seq].cmrn)
	,patient_name = substring(1, 50, gluco->elist[d1.seq].patient_name)
	,measure = substring(1, 100, gluco->elist[d1.seq].measure_name)
	,result_value = substring(1, 30, gluco->elist[d1.seq].result_value)
	,result_unit = substring(1, 30, gluco->elist[d1.seq].result_unit)
	,result_dt = substring(1, 30, gluco->elist[d1.seq].result_dt)
	,verified_dt = substring(1, 30, gluco->elist[d1.seq].verified_dt)
	,event_id = gluco->elist[d1.seq].event_id
 
from
	(dummyt   d1  with seq = size(gluco->elist, 5))
 
plan d1
 
order by fin, event_id
 
with nocounter, separator=" ", format
*/
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
%i cust_script:cov_CommonLibrary.inc
 
#exitscript
 
end
go
 
