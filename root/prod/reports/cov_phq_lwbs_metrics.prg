/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Saravanan
	Date Written:		Sep' 2018
	Solution:			Population Health Quality
	Source file name:  	cov_phq_lwbs_metrics.prg
	Object name:		cov_phq_lwbs_metrics
	Request#:			2212
 
	Program purpose:	      Left Without Being Seen - Quality Measure report
	Executing from:		CCL/DA2/Quality
  	Special Notes:          (V 2.0 spec)
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_phq_lwbs_metrics:DBA go
create program cov_phq_lwbs_metrics:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Facility" = 2552503613
 
with OUTDEV, start_datetime, end_datetime, facility
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
SET MODIFY MAXNESTLEV 100
 
declare lwbs_var = f8 with constant(uar_get_code_by("DISPLAY_KEY",19,"LEFTWITHOUTBEINGSEEN07")),protect
declare fac_var  = vc with noconstant(' ')
declare ed_dsch_var = f8 with constant(uar_get_code_by("DISPLAY", 72, "ED Discharged to")),protect
 
;Get Tracking group
declare FLMC_trackgroup_var   = f8 with constant(uar_get_code_by("DISPLAY_KEY",16370,"FLMCEDTRACKINGGROUP")),protect
declare FSR_trackgroup_var    = f8 with constant(uar_get_code_by("DISPLAY_KEY",16370,"FSREDTRACKINGGROUP")),protect
declare LCMC_trackgroup_var   = f8 with constant(uar_get_code_by("DISPLAY_KEY",16370,"LCMCEDTRACKINGGROUP")),protect
declare MHHS_trackgroup_var   = f8 with constant(uar_get_code_by("DISPLAY_KEY",16370,"MHHSEDTRACKINGGROUP")),protect
declare MMC_trackgroup_var    = f8 with constant(uar_get_code_by("DISPLAY_KEY",16370,"MMCEDTRACKINGGROUP")),protect
declare PWMC_trackgroup_var   = f8 with constant(uar_get_code_by("DISPLAY_KEY",16370,"PWMCEDTRACKINGGROUP")),protect
declare RMC_trackgroup_var    = f8 with constant(uar_get_code_by("DISPLAY_KEY",16370,"RMCEDTRACKINGGROUP")),protect
 
;Code value for all facilities
declare FLMC_var      = f8 with constant(2552503635.00)
declare FSR_var       = f8 with constant(21250403.00)
declare LCMC_var      = f8 with constant(2552503653.00)
declare MHHS_var      = f8 with constant(2552503639.00)
declare MMC_var       = f8 with constant(2552503613.00)
declare PWMC_var      = f8 with constant(2552503645.00)
declare RMC_var       = f8 with constant(2552503649.00)
 
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
 
/*
declare start_qtr = vc
declare end_qtr = vc
 
 ;Build start & end dates **** not used
case($quarter)
	of 'q1' : set start_qtr =  build2(char(34),'01-JAN-',trim(cnvtstring($year_prmt)),' 00:00:00', char(34))
	 	    set end_qtr   =  build2(char(34),'31-MAR-',trim(cnvtstring($year_prmt)),' 23:59:00', char(34))
	of 'q2' : set start_qtr =  build2(char(34),'01-APR-',trim(cnvtstring($year_prmt)),' 00:00:00', char(34))
		    set end_qtr   =  build2(char(34),'30-JUN-',trim(cnvtstring($year_prmt)),' 23:59:00', char(34))
	of 'q3' : set start_qtr =  build2(char(34),'01-JUL-',trim(cnvtstring($year_prmt)),' 00:00:00', char(34))
		    set end_qtr   =  build2(char(34),'30-SEP-',trim(cnvtstring($year_prmt)),' 23:59:00', char(34))
	of 'q4' : set start_qtr =  build2(char(34),'01-OCT-',trim(cnvtstring($year_prmt)),' 00:00:00', char(34))
	          set end_qtr   =  build2(char(34),'30-DEC-',trim(cnvtstring($year_prmt)),' 23:59:00', char(34))
endcase
*/
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
Record lwbs(
	1 plist[*]
		2 facility_cd     = f8
		2 facility        = vc
		2 ed_group        = vc
		2 encntrid        = f8
		2 age             = vc
		2 adult_flag      = i4
		2 pedi_flag       = i4
		2 lwbs_flag       = i4
		2 chkout_dispo_cd = f8
		2 disposition     = vc
		2 nomen_id        = f8
		2 discharge_to    = vc
		2 triage_flag     = i4
		2 mmc_lws_tot     = i4
)
 
 
Record metrics(
	1 list[*]
		2 facility_cd           = f8
		2 facility              = vc
		2 total_patients        = i4
		2 adlt_denominator      = i4
		2 pedi_denominator      = i4
		2 lwbs_adlt_numarator   = i4
		2 lwbs_pedi_numarator   = i4
		2 lwbs_adlt_rate        = f8
		2 lwbs_pedi_rate        = f8
		2 lwt_adlt_numarator    = i4
		2 lwt_pedi_numarator    = i4
		2 lwt_adlt_rate         = f8
		2 lwt_pedi_rate         = f8
		2 lwbs_rate             = f8
		2 lwt_rate              = f8
)
 
select distinct into 'nl:' ;value($outdev)
 
tc.tracking_group_cd
, e.person_id
, e.encntr_id
, age_val = cnvtage(p.birth_dt_tm, e.reg_dt_tm, 0)
, tc.checkin_dt_tm
, tc.checkout_dt_tm
, group	  = uar_get_code_display(tc.tracking_group_cd)
, pat_name    = p.name_full_formatted
, los_hrs	  = datetimediff(tc.checkout_dt_tm, tc.checkin_dt_tm,3)
, encntr_type = uar_get_code_display(e.encntr_type_cd)
, dispo_cond  = uar_get_code_description(e.disch_disposition_cd)
 
from
	  tracking_checkin tc
	, tracking_item ti
	, person p
 	, encounter e
 
plan tc where tc.checkin_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and parser(fac_var)
	and tc.active_ind = 1
      /* where tc.checkin_dt_tm between cnvtdatetime(start_qtr) and cnvtdatetime(end_qtr)
	and tc.tracking_group_cd in(MMC_trackgroup_var, RMC_trackgroup_var
		,FLMC_trackgroup_var, FSR_trackgroup_var, LCMC_trackgroup_var, MHHS_trackgroup_var, PWMC_trackgroup_var)*/
 
join ti where ti.tracking_id = tc.tracking_id
	and ti.encntr_id != 0.00
	and ti.active_ind = 1
 
join p where p.person_id = ti.person_id
	and p.end_effective_dt_tm >= sysdate
 
join e where e.person_id = p.person_id
	and e.encntr_id = ti.encntr_id
	and e.encntr_id != 0.00
	and e.end_effective_dt_tm >= sysdate
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT, TIME = 120
 
 
 
Head report
 
cnt = 0
call alterlist(lwbs->plist, 10)
 
Detail
 	cnt = cnt + 1
	call alterlist(lwbs->plist, cnt)
 
	case (tc.tracking_group_cd)
		of FLMC_trackgroup_var : lwbs->plist[cnt].facility_cd = FLMC_var
						 lwbs->plist[cnt].facility     = 'FLMC'
		of FSR_trackgroup_var  : lwbs->plist[cnt].facility_cd = FSR_var
					       lwbs->plist[cnt].facility     = 'FSR'
		of LCMC_trackgroup_var : lwbs->plist[cnt].facility_cd = LCMC_var
					       lwbs->plist[cnt].facility     = 'LCMC'
		of MHHS_trackgroup_var : lwbs->plist[cnt].facility_cd = MHHS_var
		                         lwbs->plist[cnt].facility     = 'MHHS'
		of MMC_trackgroup_var  : lwbs->plist[cnt].facility_cd = MMC_var
					       lwbs->plist[cnt].facility     = 'MMC'
		of PWMC_trackgroup_var : lwbs->plist[cnt].facility_cd = PWMC_var
						 lwbs->plist[cnt].facility     = 'PWMC'
		of RMC_trackgroup_var  : lwbs->plist[cnt].facility_cd = RMC_var
						 lwbs->plist[cnt].facility    = 'RMC'
		else 				 lwbs->plist[cnt].facility_cd = 0
						 lwbs->plist[cnt].facility    = ''
	endcase
 
 	lwbs->plist[cnt].ed_group        = group
	lwbs->plist[cnt].encntrid        = e.encntr_id
	lwbs->plist[cnt].age             = age_val
	lwbs->plist[cnt].chkout_dispo_cd = e.disch_disposition_cd
	lwbs->plist[cnt].disposition     = dispo_cond
 
 	if(datetimediff(e.reg_dt_tm, p.birth_dt_tm) >= 6574);18 years * 365.25 days in a year = 6574.5 days
 		lwbs->plist[cnt].adult_flag = 1
 	else
 		lwbs->plist[cnt].pedi_flag = 1
	endif
 
	/*if(e.disch_disposition_cd = 19945000.00)
		lwbs->plist[cnt].lwbs_flag = 1
	else
		lwbs->plist[cnt].lwbs_flag = 0
	endif*/
 
foot report
	call alterlist(lwbs->plist, cnt)
 
with nocounter
 
 
;Get Discharge_To details
Select distinct into 'NL:'
 
ce.encntr_id, n.source_string
, event = uar_get_code_display(ce.event_cd)
, ce.event_cd
 
from
	(dummyt d with seq = value(size(lwbs->plist, 5)))
	, clinical_event ce
	, ce_coded_result ccr
	, nomenclature n
 
plan d
 
join ce where ce.encntr_id = lwbs->plist[d.seq].encntrid
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
 
	idx = locateval(cnt,1,size(lwbs->plist,5), ce.encntr_id, lwbs->plist[cnt].encntrid)
Detail
	lwbs->plist[idx].discharge_to = trim(n.source_string)
	lwbs->plist[idx].nomen_id = n.nomenclature_id
 
	if(n.nomenclature_id = 280693164.00)
		lwbs->plist[idx].triage_flag = 1
	else
		lwbs->plist[idx].triage_flag = 0
	endif
 
	if(n.nomenclature_id = 14233843)
		lwbs->plist[idx].lwbs_flag = 1
	else
		lwbs->plist[idx].lwbs_flag = 0
	endif

With nocounter
 
;call echorecord(lwbs)
 
 
SELECT DISTINCT INTO 'NL:' ;value($outdev)
	FACILITY = SUBSTRING(1, 30, LWBS->plist[D1.SEQ].facility)
	, FACILITY_CD = LWBS->plist[D1.SEQ].facility_cd
	, ED_GROUP = SUBSTRING(1, 30, LWBS->plist[D1.SEQ].ed_group)
	, ENCNTRID = LWBS->plist[D1.SEQ].encntrid
	, age = LWBS->plist[D1.SEQ].age
	, adult_flag = LWBS->plist[D1.SEQ].adult_flag
	, pedi_flag = LWBS->plist[D1.SEQ].pedi_flag
	, lwbs_flag = LWBS->plist[D1.SEQ].lwbs_flag
	, CHKOUT_DISPO_CD = LWBS->plist[D1.SEQ].chkout_dispo_cd
	, DISPOSITION = SUBSTRING(1, 30, LWBS->plist[D1.SEQ].disposition)
	, DISCHARGE_TO = SUBSTRING(1, 30, LWBS->plist[D1.SEQ].discharge_to)
	, Nomen_id = LWBS->plist[D1.SEQ].nomen_id
	, Triage_flag = LWBS->plist[D1.SEQ].triage_flag
 
FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(LWBS->plist, 5)))
 
PLAN D1
 
ORDER BY facility_cd, ed_group, encntrid, adult_flag, pedi_flag, lwbs_flag, Triage_flag
 
;WITH NOCOUNTER , SEPARATOR=" ", FORMAT
 
 
Head report
	num = 0
	call alterlist(metrics->list, 10)
 
Head facility_cd
	itr = 0
	num = num + 1
	tot_pat = 0
	metrics->list[num].facility = facility
	metrics->list[num].facility_cd = facility_cd
 
Head encntrid
	itr = 0
	tot_pat = tot_pat + 1
 
Detail
 	itr = itr + 1
 
Foot facility_cd
	metrics->list[num].total_patients = tot_pat
 	metrics->list[num].adlt_denominator = sum(adult_flag where adult_flag = 1)
 	metrics->list[num].pedi_denominator = sum(pedi_flag where pedi_flag = 1)
 	metrics->list[num].lwbs_adlt_numarator = sum(adult_flag where adult_flag = 1 and lwbs_flag = 1)
 	metrics->list[num].lwbs_pedi_numarator = sum(pedi_flag where pedi_flag = 1 and lwbs_flag = 1)
 	metrics->list[num].lwt_adlt_numarator = sum(adult_flag where adult_flag = 1 and Triage_flag = 1)
 	metrics->list[num].lwt_pedi_numarator = sum(pedi_flag where pedi_flag = 1 and Triage_flag = 1)
 
	;lwbs_adult_rate
 	metrics->list[num].lwbs_adlt_rate =
 		(cnvtreal(metrics->list[num].lwbs_adlt_numarator) / cnvtreal(metrics->list[num].adlt_denominator)) * 100
 
	;lwbs_pediatric_rate
 	metrics->list[num].lwbs_pedi_rate =
 		(cnvtreal(metrics->list[num].lwbs_pedi_numarator) / cnvtreal(metrics->list[num].pedi_denominator)) * 100
 
 	;lwbs_rate
 	metrics->list[num].lwbs_rate =
 	((cnvtreal(metrics->list[num].lwbs_adlt_numarator) + cnvtreal(metrics->list[num].lwbs_pedi_numarator))
 	/ (cnvtreal(metrics->list[num].adlt_denominator) + cnvtreal(metrics->list[num].pedi_denominator))) * 100
 
 	;lwt_adult_rate
 	metrics->list[num].lwt_adlt_rate =
 		(cnvtreal(metrics->list[num].lwt_adlt_numarator) / cnvtreal(metrics->list[num].adlt_denominator)) * 100
 
 	;lwt_pediatric_rate
 	metrics->list[num].lwt_pedi_rate =
 		(cnvtreal(metrics->list[num].lwt_pedi_numarator) / cnvtreal(metrics->list[num].pedi_denominator)) * 100
 
 	;lwt_rate
 	metrics->list[num].lwt_rate =
 	((cnvtreal(metrics->list[num].lwt_adlt_numarator) + cnvtreal(metrics->list[num].lwt_pedi_numarator))
 	/ (cnvtreal(metrics->list[num].adlt_denominator) + cnvtreal(metrics->list[num].pedi_denominator))) * 100
 
 
Foot report
 	call alterlist(metrics->list, num)
 
with nocounter
 
 
call echorecord(metrics)
 
/*
SELECT DISTINCT INTO VALUE($OUTDEV)
	FACILITY = SUBSTRING(1, 30, METRICS->list[D1.SEQ].facility)
	, FACILITY_CD = METRICS->list[D1.SEQ].facility_cd
	, TOTAL_PATIENTS = METRICS->list[D1.SEQ].total_patients
	, ADLT_DENOMINATOR = METRICS->list[D1.SEQ].adlt_denominator
	, PEDI_DENOMINATOR = METRICS->list[D1.SEQ].pedi_denominator
	, LWBS_ADLT_NUMARATOR = METRICS->list[D1.SEQ].lwbs_adlt_numarator
	, LWBS_PEDI_NUMARATOR = METRICS->list[D1.SEQ].lwbs_pedi_numarator
	, LWT_ADLT_NUMARATOR = METRICS->list[D1.SEQ].lwt_adlt_numarator
	, LWT_PEDI_NUMARATOR = METRICS->list[D1.SEQ].lwt_pedi_numarator
	, LIST_LWBS_ADLT_RATE = METRICS->list[D1.SEQ].lwbs_adlt_rate
	, LIST_LWBS_PEDI_RATE = METRICS->list[D1.SEQ].lwbs_pedi_rate
	, LIST_LWBS_RATE = METRICS->list[D1.SEQ].lwbs_rate
	, LIST_LWT_ADLT_RATE = METRICS->list[D1.SEQ].lwt_adlt_rate
	, LIST_LWT_PEDI_RATE = METRICS->list[D1.SEQ].lwt_pedi_rate
	, LIST_LWT_RATE = METRICS->list[D1.SEQ].lwt_rate
 
FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(METRICS->list, 5)))
 
PLAN D1
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
*/
 
end
go
 
 
