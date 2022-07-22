/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Saravanan
	Date Written:		June 2018
	Solution:			Population Health Quality
	Source file name:  	cov_phq_teamHealth_ed.prg
	Object name:		cov_phq_teamHealth_ed
	Request#:			1875
 
	Program purpose:	      Teamhealth ED Throughput Report
	Executing from:		CCL/DA2
  	Special Notes:		Excel Import
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_phq_teamHealth_ed:DBA go
create program cov_phq_teamHealth_ed:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"     ;* Enter or select the printer or file name to send this report to.
	, "Start Check-IN Date/Time" = "SYSDATE"
	, "End Check-IN Date/Time" = "SYSDATE"
	, "Choose Facility" = 2552503613.00
 
with OUTDEV, start_datetime, end_datetime, facility
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare fac_var     = vc with noconstant(' ')
declare initcap()   = c100
declare fin_var     = f8 with constant(uar_get_code_by("DISPLAY", 319, "FIN NBR")),protect
declare ed_dsch_var = f8 with constant(uar_get_code_by("DISPLAY", 72, "ED Discharged to")),protect
 
;Get Tracking group
declare FLMC_trackgroup_var   = f8 with constant(uar_get_code_by("DISPLAY_KEY",16370,"FLMCEDTRACKINGGROUP")),protect
declare FSR_trackgroup_var    = f8 with constant(uar_get_code_by("DISPLAY_KEY",16370,"FSREDTRACKINGGROUP")),protect
declare LCMC_trackgroup_var   = f8 with constant(uar_get_code_by("DISPLAY_KEY",16370,"LCMCEDTRACKINGGROUP")),protect
declare MHHS_trackgroup_var   = f8 with constant(uar_get_code_by("DISPLAY_KEY",16370,"MHHSEDTRACKINGGROUP")),protect
declare MMC_trackgroup_var    = f8 with constant(uar_get_code_by("DISPLAY_KEY",16370,"MMCEDTRACKINGGROUP")),protect
declare PWMC_trackgroup_var   = f8 with constant(uar_get_code_by("DISPLAY_KEY",16370,"PWMCEDTRACKINGGROUP")),protect
declare RMC_trackgroup_var    = f8 with constant(uar_get_code_by("DISPLAY_KEY",16370,"RMCEDTRACKINGGROUP")),protect
 
;Code value for all facilities (to use in case statement)
declare FLMC_var      = f8 with constant(2552503635.00)
declare FSR_var       = f8 with constant(21250403.00)
declare LCMC_var      = f8 with constant(2552503653.00)
declare MHHS_var      = f8 with constant(2552503639.00)
declare MMC_var       = f8 with constant(2552503613.00)
declare PWMC_var      = f8 with constant(2552503645.00)
declare RMC_var       = f8 with constant(2552503649.00)
 
;Set Tracking group for each facility
case ($facility)
	of  FLMC_var  : set fac_var = build2("tc.tracking_group_cd = ", FLMC_trackgroup_var)
	of  FSR_var   : set fac_var = build2("tc.tracking_group_cd = ", FSR_trackgroup_var)
	of  LCMC_var  : set fac_var = build2("tc.tracking_group_cd = ", LCMC_trackgroup_var)
	of  MHHS_var  : set fac_var = build2("tc.tracking_group_cd = ", MHHS_trackgroup_var)
	of  MMC_var   : set fac_var = build2("tc.tracking_group_cd = ", MMC_trackgroup_var)
	of  PWMC_var  : set fac_var = build2("tc.tracking_group_cd = ", PWMC_trackgroup_var)
	of  RMC_var   : set fac_var = build2("tc.tracking_group_cd = ", RMC_trackgroup_var)
 
	else            set fac_var = build2("tc.tracking_group_cd = ", "")
endcase
 
declare tr_group_cd_var = f8
 
set tr_group_cd_var = cnvtreal(substring(25, textlen(fac_var), fac_var))
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
Record edpat(
	1 plist[*]
		2 facility        = vc
		2 patientid       = f8
		2 encntrid        = f8
		2 pat_name        = vc
		2 fin             = vc
		2 checkin_dt      = vc
		2 seen_dt         = vc
		2 check_out_dt    = vc
		2 discharge_to       = vc
		2 los                = f8
		2 check_out_dispo_cd = f8
		2 check_out_dispo_text    = vc
		2 disch_diag         = vc
)
 
 
select distinct into "NL:"
 
  location	 = uar_get_code_display(e.loc_facility_cd)
, e.person_id
, e.encntr_id
, fin = ea.alias
, pat_name    = initcap(p.name_full_formatted)
, checkin = format(tc.checkin_dt_tm, "mm/dd/yyyy hh:mm;;d")
, md_seen_dt = format(fe.md_assess_start_evt_dt_tm, "mm/dd/yyyy hh:mm;;d")
, check_out = format(tc.checkout_dt_tm, "mm/dd/yyyy hh:mm;;d")
;, departure = format(e.disch_dt_tm, "mm/dd/yyyy hh:mm;;d")
, los_hrs	  = datetimediff(tc.checkout_dt_tm, tc.checkin_dt_tm,3)
 
;, dispo_cd = e.disch_disposition_cd
;, dispo_text  = uar_get_code_description(e.disch_disposition_cd)
 
, chk_out_dispo_text  = uar_get_code_description(tc.checkout_disposition_cd)
, dch_diag = trim(fe.disch_diag)
 
from
	  tracking_checkin tc
	, tracking_item ti
 
 	, (left join fn_omf_encntr fe on fe.tracking_id = ti.tracking_id
 		and fe.tracking_group_cd = tr_group_cd_var
 		and fe.person_id = ti.person_id
		and fe.encntr_id = ti.encntr_id
		and fe.active_ind = 1)
 
	, person p
 	, encounter e
 	, encntr_alias ea
 
plan tc where tc.checkin_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and parser(fac_var) ;tc.tracking_group_cd
	and tc.active_ind = 1
	and tc.acuity_level_id != 0
 
join ti where ti.tracking_id = tc.tracking_id
	and ti.encntr_id != 0.00
	and ti.active_ind = 1
 
join fe
 
join p where p.person_id = ti.person_id
	and p.end_effective_dt_tm >= sysdate
 
join e where e.person_id = p.person_id
	and e.encntr_id = ti.encntr_id
	and e.encntr_id != 0.00
	and e.end_effective_dt_tm >= sysdate
	and e.active_ind = 1
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = fin_var
	and ea.active_ind = 1
 
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT, TIME = 120
 
;Store in record Structure
Head report
 
cnt = 0
call alterlist(edpat->plist, 10)
 
Detail
 	cnt = cnt + 1
	call alterlist(edpat->plist, cnt)
 
	edpat->plist[cnt].facility             = location
	edpat->plist[cnt].patientid            = p.person_id
	edpat->plist[cnt].encntrid             = e.encntr_id
	edpat->plist[cnt].pat_name             = pat_name
	edpat->plist[cnt].fin                  = fin
	edpat->plist[cnt].checkin_dt           = checkin
	edpat->plist[cnt].seen_dt              = md_seen_dt
	edpat->plist[cnt].check_out_dt         = check_out
	edpat->plist[cnt].los                  = los_hrs
	edpat->plist[cnt].check_out_dispo_cd   = tc.checkout_disposition_cd
	edpat->plist[cnt].check_out_dispo_text = chk_out_dispo_text
	edpat->plist[cnt].disch_diag           = dch_diag
 
foot report
	call alterlist(edpat->plist, cnt)
 
with nocounter
;call echorecord(edpat)
 
 
;Get Discharge_To details
Select distinct into 'NL:'
 
ce.encntr_id, n.source_string
, event = uar_get_code_display(ce.event_cd)
, ce.event_cd
 
from
	(dummyt d with seq = value(size(edpat->plist, 5)))
	, clinical_event ce
	, ce_coded_result ccr
	, nomenclature n
 
plan d
 
join ce where ce.encntr_id = outerjoin(edpat->plist[d.seq].encntrid)
	and ce.event_cd = ed_dsch_var
 
join ccr where ccr.event_id = ce.event_id
 
join n where n.nomenclature_id = ccr.nomenclature_id
	and n.nomenclature_id in (280701767.00, 280693162.00, 280693157.00, 9450401.00, 280701813.00,
            8544649.00, 57798433.00, 14233843.00, 280693164.00, 280693153.00, 280693168.00, 22489483.00)
            ;These are discharge_to events but not from event_cd table
 
order by ce.encntr_id
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
Head report
	cnt = 0
	idx = 0
 
Head ce.encntr_id
 
	idx = locateval(cnt,1,size(edpat->plist,5), ce.encntr_id, edpat->plist[cnt].encntrid)
Detail
	edpat->plist[idx].discharge_to = trim(n.source_string)
 
With nocounter
 
call echorecord(edpat)
 
 
;Display from record structure
SELECT INTO VALUE($OUTDEV)
	FACILITY = TRIM(SUBSTRING(1, 50, EDPAT->plist[D1.SEQ].facility))
	, PATIENT_NAME = TRIM(SUBSTRING(1, 50, EDPAT->plist[D1.SEQ].pat_name))
	, FIN = SUBSTRING(1, 10, EDPAT->plist[D1.SEQ].fin)
	, CHECK_IN_DT_TM = SUBSTRING(1, 20, EDPAT->plist[D1.SEQ].checkin_dt)
	, MD_SEEN_DT_TM = SUBSTRING(1, 20, EDPAT->plist[D1.SEQ].seen_dt)
	, CHECK_OUT_DT_TM = SUBSTRING(1, 20, EDPAT->plist[D1.SEQ].check_out_dt)
	, DISCHARGE_TO = SUBSTRING(1, 100, EDPAT->plist[D1.SEQ].discharge_to)
	, LOS_Hrs = EDPAT->plist[D1.SEQ].los
	, CHECKOUT_DISPOSITION = TRIM(SUBSTRING(1, 100, EDPAT->plist[D1.SEQ].check_out_dispo_text))
	, DISCHARGE_DIAGNOSIS = TRIM(SUBSTRING(1, 300, EDPAT->plist[D1.SEQ].disch_diag))
 
FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(EDPAT->plist, 5)))
 
PLAN D1
 
ORDER BY
	FACILITY, PATIENT_NAME, CHECK_IN_DT_TM
 
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT, SKIPREPORT = 1
 
 
end
go
 
 
 
