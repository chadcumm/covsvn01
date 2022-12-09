/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha
	Date Written:		May'2018
	Solution:			population Health Quality
	Source file name:  	cov_phq_restraint_expired_pat.prg
	Object name:		cov_phq_restraint_expired_pat
	Request#:			1047
	Program purpose:	      Report will show patients who had history of restraints and expired during hospital stay
	Executing from:		CCL/DA2/Nursing
  	Special Notes:		R2W Setup
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
CR     Mod Date	Developer			     Comment
----------------------------------------------------------------------------------------------------------------------
6653	11/04/2019  Geetha     Change the report look into the discharge date and pull the patient
				  	if there is a deceased flag regardless of deceased date
13041  11/01/22   Geetha     CMC added
13949  11/16/22   Geetha     Ops job setup to R2W except BH locations
 
**********************************************************************************************************************/
 
drop program cov_phq_restraint_expired_pat:dba go
create program cov_phq_restraint_expired_pat:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"      ;* Enter or select the printer or file name to send this report to.
	, "Start Discharge Date/Time" = "SYSDATE"
	, "End Discharge Date/Time" = "SYSDATE"
	, "Select Facility" = 0
 
with OUTDEV, start_datetime, end_datetime, facility_list
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare initcap()            = c100
declare mrn_var              = f8 with constant(uar_get_code_by("DISPLAY", 319, "MRN")),protect
declare fin_var              = f8 with constant(uar_get_code_by("DISPLAY", 319, "FIN NBR")),protect
declare death_dt_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "Date/Time of Death")),protect
declare prsnl_var            = f8 with constant(uar_get_code_by("DISPLAY",     331, 'Primary Care Physician')),protect  ;1115.00
declare position_var         = f8 with constant(uar_get_code_by("CDF_MEANING", 88 , 'PRIMARY CARE')),protect  ;19944603.00
declare deceased_var         = f8 with constant(uar_get_code_by("DISPLAY", 268, "Yes")),protect
 
declare ucnt = i4 with noconstant(0)
declare pcnt = i4 with noconstant(0)
declare idx = i4 with noconstant(0)
declare opr_fac_var = vc with noconstant('')
 
;Facility variable
if(substring(1,1,reflect(parameter(parameter2($facility_list),0))) = "l");multiple values were selected
	set opr_fac_var = "in"
elseif(parameter(parameter2($facility_list),1)= 0.0)	;all[*] values were selected
	set opr_fac_var = "!="
else									;a single value was selected
	set opr_fac_var = "="
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
RECORD expired_log(
	1 list[*]
		2 facility                   = f8
		2 facility_name              = vc
		2 ulist[*]
			3 nurse_unit_cd          = f8
			3 nurse_unit_name        = vc
			3 plist[*]
				4 person_id          = f8
				4 encounter_id       = f8
				4 name               = vc
				4 mrn                = vc
				4 fin                = vc
				4 dob                = vc
				4 admit_date         = vc
				4 dish_date          = vc
				4 admit_dx           = vc
				4 status             = vc
				4 expire_date        = vc
				4 death_chart_dt     = vc
				4 last_rest_chart    = vc
				4 hrs_24             = vc
				4 one_week           = vc
				4 md_attend          = vc
				4 md_admit           = vc
		)
 
 
RECORD facility(
	1 rec_cnt =	i4
	1 flist[*]
		2 facility_cd   =	f8
		2 facility_desc =	vc
)
 
;-----------------------------------------------------------------------------------------------------------------
 
;Get facilities
select into $outdev
  facility_name = uar_get_code_display(l.location_cd), l.location_cd
from location l
where operator(l.location_cd, opr_fac_var, $facility_list)
and l.location_type_cd = 783.00
and l.active_ind = 1
and l.location_cd in(2552503635.00, 21250403.00,2552503653.00,2552503639.00,2552503613.00,2552503645.00,2552503649.00
				,2552503657.00 ,2553765707.00 ,2553765627.00 ,2553765571.00, 2553765371.00
				,2553765579.00, 2553765475.00, 2553765531.00)
  ;2553765579.00, 2553765475.00, 2553765531.00 	;BH patients shouldn't pull for all[*] prompt and R2W as well
 ;PBH, MHHS Behavioral Health, PW Senior Behavioral Health
 
order by facility_name
 
Head report
	cnt = 0
Detail
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
 		stat = alterlist(facility->flist, cnt + 9)
 	endif
 
	facility->flist[cnt].facility_cd	= l.location_cd
	facility->flist[cnt].facility_desc	= facility_name
	facility->rec_cnt		      	= cnt
 
Foot report
	stat = alterlist(facility->flist, cnt)
 
With nocounter
 
 
;with nocounter, separator=" ", format
;go to exitscript
 
;---------------------------------------------------------------------------------------------------------
;Get all expired on Restraint patients
select distinct into 'nl:'
 
  e.loc_facility_cd
, p.person_id
, e.loc_nurse_unit_cd
, pat_name = initcap(p.name_full_formatted)
, mrn =  ea1.alias
, fin = ea.alias
, dob = format(p.birth_dt_tm,"MM/DD/YYYY")
, admit_dt = format(e.reg_dt_tm,"MM/DD/YYYY HH:MM:SS")
, disch_dt = format(e.disch_dt_tm,"MM/DD/YYYY HH:MM:SS")
, admit_dx = trim(e.reason_for_visit)
, status = evaluate(p.deceased_cd, deceased_var, "E", 0, "")
;, expire_dt = format(p.deceased_dt_tm,"MM/DD/YYYY")
, expire_dt = format(e.disch_dt_tm,"MM/DD/YYYY") ;CR#6653
, death_chart_dt = format(cnvtdatetime(cnvtdate2(substring(3,8,ce.result_val),"YYYYMMDD")
	,cnvtint(substring(11,6,ce.result_val))),"MM/dd/yyyy hh:mm;;d")
, last_restraint_chart = format(i.verify_dt,"MM/DD/YYYY HH:MM:SS;;D")
, hrs_24 = DATETIMEDIFF(cd.result_dt_tm, i.verify_dt, 3);Local
, one_week = DATETIMEDIFF(cd.result_dt_tm, i.verify_dt, 2);Local
, attend_md = initcap(pr.name_full_formatted)
, admit_md = initcap(pr1.name_full_formatted)
 
from
 	encounter e
 	, person p
 	, encntr_alias ea
 	, encntr_alias ea1
	, encntr_prsnl_reltn epr
	, encntr_prsnl_reltn epr1
	, prsnl pr
	, prsnl pr1
	, clinical_event ce
	, ce_date_result cd
,(
	(select ce.person_id, ce.encntr_id, verify_dt = max(ce.verified_dt_tm)
		from clinical_event ce, encounter e, person p, code_value cv
		where ce.person_id = e.person_id and ce.encntr_id = e.encntr_id
		and p.person_id = e.person_id
		and ce.event_cd = cv.code_value and cv.code_set = 72
		and cv.display = "*Restraint*"
		and ce.result_status_cd in(25, 34, 35)
		;and e.loc_facility_cd = $facility_list
		and expand(idx,1,size(facility->flist, 5), e.loc_facility_cd , facility->flist[idx].facility_cd)
		and e.disch_disposition_cd in(638666.00, 2554369135) ;expired, expired(hospice claims only) 41
		and e.data_status_cd in(25, 35)
		and e.reg_dt_tm <= sysdate
		and e.active_ind = 1
		and p.deceased_cd = 684729.00;deceased_var
      	;and p.deceased_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
      	and e.disch_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
      	and p.active_ind = 1
	  group by ce.person_id, ce.encntr_id
	  with sqltype("f8","f8","dq8")
 
	)i
)
 
plan i
 
join e where e.person_id = i.person_id
	and expand(idx,1,size(facility->flist, 5), e.loc_facility_cd , facility->flist[idx].facility_cd)
	and e.disch_disposition_cd in(638666.00, 2554369135) ;expired, expired(hospice claims only) 41
 
join ce where ce.person_id = outerjoin(i.person_id)
	and ce.encntr_id = outerjoin(i.encntr_id)
	and ce.event_cd = outerjoin(718579.00) ;death_dt_var
	and ce.valid_until_dt_tm = outerjoin(cnvtdatetime ("31-DEC-2100 00:00:00"))
 
join cd where cd.event_id = outerjoin(ce.event_id)
	and cd.valid_until_dt_tm = outerjoin(cnvtdatetime ("31-DEC-2100 00:00:00"))
 
join p where p.person_id = e.person_id
	and p.deceased_cd = deceased_var
      and p.active_ind = 1
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = fin_var
	and ea.active_ind = 1
 
join ea1 where ea1.encntr_id = e.encntr_id
	and ea1.encntr_alias_type_cd = mrn_var
	and ea1.active_ind = 1
 
join epr where epr.encntr_id = outerjoin(e.encntr_id)
       and epr.active_ind = outerjoin(1)
       and epr.encntr_prsnl_r_cd = outerjoin(1119.00) ;attending Phys
       and epr.end_effective_dt_tm > sysdate
 
join pr where pr.person_id = outerjoin(epr.prsnl_person_id)
         and pr.active_ind = outerjoin(1)
 
join epr1 where epr1.encntr_id = outerjoin(e.encntr_id)
       and epr1.active_ind = outerjoin(1)
       and epr1.encntr_prsnl_r_cd = outerjoin(1116.00) ;admitting Phys
       and epr1.end_effective_dt_tm > sysdate
 
join pr1 where pr1.person_id = outerjoin(epr1.prsnl_person_id)
         and pr1.active_ind = outerjoin(1)
 
 
order by e.loc_facility_cd, e.loc_nurse_unit_cd, p.person_id
 
HEAD REPORT
 
	fcnt = 0
	call alterlist(expired_log->list, 10)
 
HEAD e.loc_facility_cd
 	fcnt = fcnt + 1
	if(mod(fcnt, 10) = 1 and fcnt > 100)
		call alterlist(expired_log->list, fcnt+9)
	endif
	expired_log->list[fcnt].facility      = e.loc_facility_cd
	expired_log->list[fcnt].facility_name = trim(uar_get_code_description(e.loc_facility_cd))
	ucnt = 0
 
HEAD e.loc_nurse_unit_cd
	ucnt = ucnt + 1
	call alterlist(expired_log->list[fcnt].ulist, ucnt)
 
	expired_log->list[fcnt].ulist[ucnt].nurse_unit_cd   = e.loc_nurse_unit_cd
	expired_log->list[fcnt].ulist[ucnt].nurse_unit_name = trim(uar_get_code_display(e.loc_nurse_unit_cd))
	pcnt = 0
 
DETAIL
	pcnt = pcnt + 1
	call alterlist(expired_log->list[fcnt].ulist[ucnt].plist, pcnt)
 
	expired_log->list[fcnt].ulist[ucnt].plist[pcnt].person_id       = p.person_id
	expired_log->list[fcnt].ulist[ucnt].plist[pcnt].encounter_id    = e.encntr_id
	expired_log->list[fcnt].ulist[ucnt].plist[pcnt].name            = pat_name
	expired_log->list[fcnt].ulist[ucnt].plist[pcnt].mrn             = mrn
	expired_log->list[fcnt].ulist[ucnt].plist[pcnt].fin             = fin
	expired_log->list[fcnt].ulist[ucnt].plist[pcnt].dob             = dob
	expired_log->list[fcnt].ulist[ucnt].plist[pcnt].admit_date      = admit_dt
	expired_log->list[fcnt].ulist[ucnt].plist[pcnt].dish_date       = disch_dt
	expired_log->list[fcnt].ulist[ucnt].plist[pcnt].admit_dx        = admit_dx
	expired_log->list[fcnt].ulist[ucnt].plist[pcnt].status          = status
	expired_log->list[fcnt].ulist[ucnt].plist[pcnt].expire_date     = expire_dt
	expired_log->list[fcnt].ulist[ucnt].plist[pcnt].death_chart_dt  = death_chart_dt
	expired_log->list[fcnt].ulist[ucnt].plist[pcnt].last_rest_chart = last_restraint_chart
	expired_log->list[fcnt].ulist[ucnt].plist[pcnt].hrs_24          = evaluate2(if(hrs_24 <= 24) "Yes" endif)
	expired_log->list[fcnt].ulist[ucnt].plist[pcnt].one_week        = evaluate2(if(one_week <= 1) "Yes" endif)
	expired_log->list[fcnt].ulist[ucnt].plist[pcnt].md_attend       = attend_md
	expired_log->list[fcnt].ulist[ucnt].plist[pcnt].md_admit        = admit_md
 
FOOT e.loc_nurse_unit_cd
 	call alterlist(expired_log->list[fcnt].ulist[ucnt].plist, pcnt)
 
FOOT REPORT
 	call alterlist(expired_log->list, fcnt)
 
WITH nocounter, maxtime = 120
 
;------------------------------------------------------------------------------------------------------------------
call echorecord(expired_log)
 
;------------------------------------------------------------------------------------------------------------------
 
 
 
 
#exitscript
 
end
go
 
 
/*
;----------------------------------------------------------------------------------------------------------------------
 
 
 
 
/*
, death_chart_dt = format(cd.result_dt_tm,"MM/DD/YYYY HH:MM:SS")
 
, t2 =  format(datetimeadd(cnvtdatetime(tmp.perform_dt),-240/1440.0),"MM/DD/YYYY HH:MM:SS;;D")
 
, last_restraint_chart = format(cnvtdatetimeutc(cnvtdatetime(tmp.perform_dt),2),"MM/DD/YYYY HH:MM:SS;;D")
 
;UTC
, old_hrs_24 = DATETIMEDIFF(cnvtdatetime(cd.result_dt_tm), cnvtdatetime(tmp.perform_dt), 3) ;calculate diff from death dt and last restraint date
, old_one_week = DATETIMEDIFF(cnvtdatetime(cd.result_dt_tm), cnvtdatetime(tmp.perform_dt), 2) ;calculate diff from death dt and last restraint date
 
, hrs_24 = DATETIMEDIFF(cnvtdatetime(cd.result_dt_tm), cnvtdatetime(datetimeadd(cnvtdatetime(tmp.perform_dt),-240/1440.0)), 3);Local
, one_week = DATETIMEDIFF(cnvtdatetime(cd.result_dt_tm), cnvtdatetime(datetimeadd(cnvtdatetime(tmp.perform_dt),-240/1440.0)), 2);Local
;, attend_md = initcap(d.diag_prsnl_name)
*/
 
 
 
 
 
