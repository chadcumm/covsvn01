/*********************************************************************************
Author          :	Steve Czubek
Date Written	:	10/19/2022
Program Title	:	Cov – Amb Home Health Hospice Referral
Source File     :	cov_amb_home_hospice_referral.prg
Object Name     :	cov_home_hospice_referral
Directory       :	cust_script
 
Purpose         : 	Referrals to home health hospice
 
 
Mod     Date        Engineer                Comment
----    ----------- ----------------------- ---------------------------------------
001     10/19/2022  Steve Czubek            CR 7266 convert from Business Objects to CCL and improve performance.
002     10/20/2022  Dawn Greer, DBA         CR 7266 - Renamed from cov_home_hospice_referral to
                                            cov_amb_home_hospice_referral
 
************************************************************************************/
drop program cov_amb_home_hospice_referral go
create program cov_amb_home_hospice_referral
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Begin Date" = "CURDATE"
	, "End Date" = "CURDATE"
	, "Facility" = 0
	, "Provider" = 0
 
with OUTDEV, beg_dt, end_dt, facility, provider
 
%i cust_script:SC_CPS_GET_PROMPT_LIST.inc
declare fac_parser = vc with protect, noconstant("1=1")
if (not(IsPromptEmpty(parameter2($facility))))
set fac_parser = GetPromptList(parameter2($facility), "e.loc_facility_cd")
endif
declare prov_parser = vc with protect, noconstant("1=1")
if (not(IsPromptEmpty(parameter2($provider))))
set fac_parser = GetPromptList(parameter2($provider), "epr.prsnl_person_id")
endif
 
free record rpt_data
record rpt_data
(
    1 qual[*]
        2 Facility = vc
        2 FIN = vc
        2 REG_DT_TM = vc
        2 BIRTH_DT_TM = vc
        2 NAME_FULL_FORMATTED = vc
        2 DECEASED_DT_TM = vc
        2 DECEASED = vc
        2 Insurance = vc
        2 event = vc
        2 result_date = vc
        2 start_date = vc
        2 performed_date_time = vc
        2 performed_prsnl = vc
        2 verified_dt_tm = vc
        2 verfied_prsnl = vc
        2 Attending = vc
)
 
declare cnt = i4 with protect, noconstant(0)
declare FINNBR = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare ATTENDINGPHYSICIAN = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 333, "ATTENDINGPHYSICIAN"))
declare AUTHVERIFIED = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 8, "AUTHVERIFIED"))
 
SELECT into "nl:"
FROM
  encounter e
  ,code_value cv
  ,encntr_alias ea
  ,person p
  ,encntr_prsnl_reltn epr
  ,encntr_plan_reltn ehpr
  ,organization o
  ,prsnl ps
  ,clinical_event ce
  ,prsnl ps_perf
  ,prsnl ps_ver
 
plan ce
    where ce.event_cd in (2579928215, 2579928171, 2579928547, 2579928231, 2579928391, 2579928413, 2570024765, 2845234353)
    and ce.valid_until_dt_tm > cnvtdatetime(curdate, curtime)
    and ce.result_status_cd in (AUTHVERIFIED)
    and ce.event_end_dt_tm between cnvtdatetime(concat($beg_dt, " 00:00"))
    and cnvtdatetime(concat($end_dt, " 23:59"))
    and ce.view_level = 1
join e
    where e.encntr_id = ce.encntr_id
    and parser(fac_parser)
    and e.active_ind = 1
join cv
    where cv.code_value = e.loc_facility_cd
join ea
     where ea.encntr_id = e.encntr_id
     and ea.active_ind = 1
     and ea.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
     and ea.encntr_alias_type_cd = FINNBR
join p
    where p.person_id = e.person_id
join epr
    where epr.encntr_id = outerjoin(e.encntr_id)
    and epr.encntr_prsnl_r_cd = outerjoin(ATTENDINGPHYSICIAN)
    and epr.active_ind = outerjoin(1)
    and epr.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime))
    and parser(prov_parser)
join ps
    where ps.person_id = outerjoin(epr.prsnl_person_id)
 
join ps_perf
    where ps_perf.person_id = ce.performed_prsnl_id
join ps_ver
    where ps_ver.person_id = ce.verified_prsnl_id
join ehpr
    where ehpr.encntr_id = outerjoin(e.encntr_id)
    and ehpr.priority_seq = outerjoin(1)
    and ehpr.active_ind = outerjoin(1)
    and ehpr.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime))
join o
    where o.organization_id = outerjoin(ehpr.organization_id)
order
    ce.event_id
head report
    cnt = 0
head ce.event_id
    if (mod(cnt, 100) = 0)
        stat = alterlist(rpt_data->qual, cnt + 100)
    endif
    cnt = cnt + 1
    rpt_data->qual[cnt].Facility = cv.description
    rpt_data->qual[cnt].FIN = ea.alias
    rpt_data->qual[cnt].REG_DT_TM = format(e.reg_dt_tm, "MM-DD-YYYY HH:MM")
    rpt_data->qual[cnt].BIRTH_DT_TM = format(p.birth_dt_tm, "MM-DD-YYYY HH:MM")
    rpt_data->qual[cnt].NAME_FULL_FORMATTED = p.name_full_formatted
    rpt_data->qual[cnt].DECEASED_DT_TM = format(p.deceased_dt_tm, "MM-DD-YYYY HH:MM")
    rpt_data->qual[cnt].DECEASED = uar_get_code_display(p.deceased_cd)
    rpt_data->qual[cnt].Insurance = o.org_name
    rpt_data->qual[cnt].event = uar_get_code_display(ce.event_cd)
    rpt_data->qual[cnt].result_date = format(ce.event_end_dt_tm, "MM-DD-YYYY HH:MM")
    rpt_data->qual[cnt].start_date = format(ce.event_start_dt_tm, "MM-DD-YYYY HH:MM")
    rpt_data->qual[cnt].performed_date_time = format(ce.performed_dt_tm, "MM-DD-YYYY HH:MM")
    rpt_data->qual[cnt].performed_prsnl = ps_perf.name_full_formatted
    rpt_data->qual[cnt].verified_dt_tm = format(ce.verified_dt_tm, "MM-DD-YYYY HH:MM")
    rpt_data->qual[cnt].verfied_prsnl = ps_ver.name_full_formatted
    rpt_data->qual[cnt].Attending = ps.name_full_formatted
foot report
    stat = alterlist(rpt_data->qual, cnt)
with nocounter
 
 
select into $outdev
Facility = substring(1, 30, rpt_data->qual[d.seq].Facility ),
FIN = substring(1, 30, rpt_data->qual[d.seq].FIN ),
Reg_Date_Time = substring(1, 30, rpt_data->qual[d.seq].REG_DT_TM ),
Birth_Date_Time = substring(1, 30, rpt_data->qual[d.seq].BIRTH_DT_TM ),
Paient_Name = substring(1, 30, rpt_data->qual[d.seq].NAME_FULL_FORMATTED ),
Deceased_Date = substring(1, 30, rpt_data->qual[d.seq].DECEASED_DT_TM ),
Deceased_Ind = substring(1, 30, rpt_data->qual[d.seq].DECEASED ),
Insurance = substring(1, 30, rpt_data->qual[d.seq].Insurance ),
Clinical_Event = substring(1, 30, rpt_data->qual[d.seq].event ),
Result_Date_Time = substring(1, 30, rpt_data->qual[d.seq].result_date ),
;start = substring(1, 30, rpt_data->qual[d.seq].start_date ),
Performed_Date_Time = substring(1, 30, rpt_data->qual[d.seq].performed_date_time ),
Performed_By = substring(1, 30, rpt_data->qual[d.seq].performed_prsnl ),
Verfied_Date_Time = substring(1, 30, rpt_data->qual[d.seq].verified_dt_tm ),
Verified_By = substring(1, 30, rpt_data->qual[d.seq].verfied_prsnl ),
Attending = substring(1, 30, rpt_data->qual[d.seq].Attending )
 
from
    (dummyt d with seq = size(rpt_data->qual, 5))
plan d
with format, separator = " "
end
go
 
 
 
