/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Saravanan
	Date Written:		May'2018
	Solution:			population Health Quality
	Source file name:  	cov_phq_expired_patients.prg
	Object name:		cov_phq_expired_patients.prg
	Request#:			5592
	Program purpose:	      Report will show expired patients during hospital stay
	Executing from:		CCL/DA2/Nursing
  	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	-----------------------------------------------------------------------------------------------------
01-09-20    Geetha    CR#6922 - Change Organ_Bank_Notify_Dt and Medical Examiner_Notify-DT from documentation 
							date to DTA responses.
06-26-20    Geetha    CR#7800 -  Add DOA(death on arrival) column and arrival Date
***************************************************************************************************************/
 
drop program cov_phq_expired_patients go
create program cov_phq_expired_patients
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Select Facility" = 0
 
with OUTDEV, start_datetime, end_datetime, facility_list
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare initcap()            = c100
declare mrn_var              = f8 with constant(uar_get_code_by("DISPLAY", 319, "MRN")),protect
declare fin_var              = f8 with constant(uar_get_code_by("DISPLAY", 319, "FIN NBR")),protect
declare prsnl_var            = f8 with constant(uar_get_code_by("DISPLAY", 331, 'Primary Care Physician')),protect  ;1115.00
declare deceased_var         = f8 with constant(uar_get_code_by("DISPLAY", 268, "Yes")),protect
declare position_var         = f8 with constant(uar_get_code_by("CDF_MEANING", 88 , 'PRIMARY CARE')),protect  ;19944603.00
 
declare dead_arrive_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Dead on Arrival")),protect
declare death_dt_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, "Date/Time of Death")),protect
declare autopsy_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "Autopsy")),protect
declare organ_bank_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, "Organ Bank Member Notified of Death")),protect
declare med_autopsy_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Medical Examiner Autopsy")),protect
declare funeral_home_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Name of Funeral Home")),protect
declare body_trans_dept_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, "Body Transported")),protect
declare body_left_tm_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Date/Time Body Left Department")),protect
declare coroner_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "Name of ME Notified of Death")),protect
declare med_examiner_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Date/Time ME Notified of Death")),protect
;declare coroner_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "Date and Time Coroner's Office Notified")),protect
;declare med_examiner_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Notifications of Death")),protect
 
declare ucnt = i4 with noconstant(0)
declare pcnt = i4 with noconstant(0)
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
RECORD expired_log(
	1 plist[*]
		2 facility_name      = vc
		2 nurse_unit_name    = vc
		2 person_id          = f8
		2 encounter_id       = f8
		2 name               = vc
		2 mrn                = vc
		2 fin                = vc
		2 dob                = vc
		2 admit_date         = vc
		2 arrival_dt         = vc
		2 dish_date          = vc
		2 admit_dx           = vc
		2 status             = vc
		2 expire_date        = vc
		2 death_chart_dt     = vc
		2 dead_on_arrival    = vc
		2 autopsy_requested  = vc
		2 md_attend          = vc
		2 md_admit           = vc
		2 dispo_cd           = vc
		2 organ_bank_notify  = vc
		2 med_exam_notify    = vc
		2 funeral_home       = vc
		2 body_transported   = vc
		2 body_left_dt_tm    = vc
		2 coroner_notify     = vc
		2 med_autopsy        = vc
)
 
;**************************************************************************************************
;Get all deceased patients
select into 'nl:'
 
  facility = uar_get_code_display(e.loc_facility_cd)
, Nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd)
, pat_name = initcap(p.name_full_formatted)
, mrn =  ea1.alias
, fin = ea.alias
, dob = format(p.birth_dt_tm,"MM/DD/YYYY")
, admit_dt = format(e.reg_dt_tm,"MM/DD/YYYY HH:MM:SS")
, disch_dt = format(e.disch_dt_tm,"MM/DD/YYYY HH:MM:SS")
, status = evaluate(p.deceased_cd, deceased_var, "E", 0, "");684729.00
, expire_dt = format(p.deceased_dt_tm,"MM/DD/YYYY")
, attend_md = initcap(pr.name_full_formatted)
, admit_md = initcap(pr1.name_full_formatted)
, admit_dx = trim(e.reason_for_visit);trim(d.diagnosis_display)
 
from
 	encounter e
 	, person p
 	, encntr_alias ea
 	, encntr_alias ea1
	, encntr_prsnl_reltn epr
	, encntr_prsnl_reltn epr1
	, prsnl pr
	, prsnl pr1
 
plan e where e.loc_facility_cd = $facility_list
	and e.disch_disposition_cd in(638666.00, 2554369135) ;expired, expired(hospice claims only) 41
	and e.data_status_cd in(25, 35)
	and e.reg_dt_tm <= sysdate
	and e.active_ind = 1
 
join p where p.person_id = e.person_id
     	and p.deceased_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
     	and p.active_ind = 1
	and p.deceased_cd = deceased_var
 
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
 
order by e.loc_facility_cd, e.loc_nurse_unit_cd, p.name_full_formatted, p.person_id
 
Head report
	pcnt = 0
Head p.person_id
	pcnt = pcnt + 1
	call alterlist(expired_log->plist, pcnt)
Detail
	expired_log->plist[pcnt].facility_name = trim(uar_get_code_display(e.loc_facility_cd))
	expired_log->plist[pcnt].nurse_unit_name = trim(uar_get_code_display(e.loc_nurse_unit_cd))
	expired_log->plist[pcnt].person_id       = p.person_id
	expired_log->plist[pcnt].encounter_id    = e.encntr_id
	expired_log->plist[pcnt].name            = pat_name
	expired_log->plist[pcnt].mrn             = mrn
	expired_log->plist[pcnt].fin             = fin
	expired_log->plist[pcnt].dob             = dob
	expired_log->plist[pcnt].admit_date      = admit_dt
	expired_log->plist[pcnt].arrival_dt      = format(e.arrive_dt_tm, 'mm/dd/yyyy hh:mm;;q')
	expired_log->plist[pcnt].dish_date       = disch_dt
	expired_log->plist[pcnt].admit_dx        = admit_dx
	expired_log->plist[pcnt].status          = status
	expired_log->plist[pcnt].expire_date     = expire_dt
	expired_log->plist[pcnt].md_attend       = attend_md
	expired_log->plist[pcnt].md_admit        = admit_md
	expired_log->plist[pcnt].dispo_cd        = trim(uar_get_code_display(e.disch_disposition_cd))
 
With nocounter
 
;------------------------------------------------------------------------------------------------
;Get Clinical events
select into $outdev

ce.encntr_id, ce.event_cd, uar_get_code_display(ce.event_cd), ce.result_val
, death_chart_dt = format(cnvtdatetime(cnvtdate2(substring(3,8,ce.result_val),"YYYYMMDD")
	,cnvtint(substring(11,6,ce.result_val))),"MM/dd/yyyy hh:mm;;d")
 
from (dummyt d1 with seq = size(expired_log->plist, 5))
	, clinical_event ce
	, ce_date_result cd
 
plan d1
 
join ce where ce.encntr_id = expired_log->plist[d1.seq].encounter_id
	and ce.person_id = expired_log->plist[d1.seq].person_id
	and ce.event_class_cd != 654645.00	;Place Holder
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00")
      and ce.result_status_cd in (25,34,35)
	and ce.event_cd in(death_dt_var, autopsy_var, organ_bank_var, funeral_home_var, dead_arrive_var
		, body_trans_dept_var, body_left_tm_var, med_autopsy_var, med_examiner_var, coroner_var)
 
     /* and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
      				and ce1.event_cd = ce.event_cd
     					and ce.event_class_cd != 654645.00	;Place Holder
					and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00")
				      and ce.result_status_cd in (25,34,35)
      				group by ce1.encntr_id, ce1.event_cd)*/
 
join cd where cd.event_id = outerjoin(ce.event_id)
	and cd.valid_until_dt_tm = outerjoin(cnvtdatetime ("31-DEC-2100 00:00:00"))
 
order by ce.encntr_id

Head ce.encntr_id
 	num = 0
 	idx = 0
	idx = locateval(num, 1, size(expired_log->plist, 5), ce.encntr_id, expired_log->plist[num].encounter_id)
Detail
   if(idx > 0)
	case(ce.event_cd)
		of dead_arrive_var:
		 	expired_log->plist[idx].dead_on_arrival = trim(ce.result_val)
		of autopsy_var:
		 	expired_log->plist[idx].autopsy_requested = trim(ce.result_val)
		of death_dt_var:
			expired_log->plist[idx].death_chart_dt  = death_chart_dt
		of funeral_home_var:
			expired_log->plist[idx].funeral_home = replace(replace(ce.result_val, char(13), ''), char(10), '')
		of body_trans_dept_var:
			expired_log->plist[idx].body_transported = trim(ce.result_val)
		of coroner_var:
		   	expired_log->plist[idx].coroner_notify = trim(ce.result_val)
		of med_autopsy_var:
			expired_log->plist[idx].med_autopsy = trim(ce.result_val)
		of organ_bank_var:
			expired_log->plist[idx].organ_bank_notify = format(cnvtdatetime(cnvtdate2(substring(3,8,ce.result_val),"YYYYMMDD")
				,cnvtint(substring(11,6,ce.result_val))),"MM/dd/yyyy hh:mm;;d")
		of med_examiner_var:
		 	expired_log->plist[idx].med_exam_notify = format(cnvtdatetime(cnvtdate2(substring(3,8,ce.result_val),"YYYYMMDD")
				,cnvtint(substring(11,6,ce.result_val))),"MM/dd/yyyy hh:mm;;d")
		of body_left_tm_var:
		   	expired_log->plist[idx].body_left_dt_tm = format(cnvtdatetime(cnvtdate2(substring(3,8,ce.result_val),"YYYYMMDD")
				,cnvtint(substring(11,6,ce.result_val))),"MM/dd/yyyy hh:mm;;d")
	endcase
   endif
 
with nocounter
 
call echorecord(expired_log)

;-------------------------------------------------------------------------------------------------
 
select distinct into $outdev
 
	facility = trim(substring(1, 50, expired_log->plist[d1.seq].facility_name))
	, date_of_death = trim(substring(1, 30, expired_log->plist[d1.seq].expire_date))
	, nurse_unit = trim(substring(1, 50, expired_log->plist[d1.seq].nurse_unit_name))
	, fin = trim(substring(1, 30, expired_log->plist[d1.seq].fin))
	, mrn = trim(substring(1, 30, expired_log->plist[d1.seq].mrn))
	, patient_name = trim(substring(1, 50, expired_log->plist[d1.seq].name))
	, date_of_birth = trim(substring(1, 30, expired_log->plist[d1.seq].dob))
	, admit_date = trim(substring(1, 30, expired_log->plist[d1.seq].admit_date))
	, arrival_date = trim(substring(1, 30, expired_log->plist[d1.seq].arrival_dt))
	, status = trim(substring(1, 30, expired_log->plist[d1.seq].status))
	, dead_on_arrival = trim(substring(1, 30, expired_log->plist[d1.seq].dead_on_arrival))
	, death_chart_dt = trim(substring(1, 30, expired_log->plist[d1.seq].death_chart_dt))
	, discharge_dt = trim(substring(1, 30, expired_log->plist[d1.seq].dish_date))
	, disposition_code = trim(substring(1, 200, expired_log->plist[d1.seq].dispo_cd))
	, md_attending = trim(substring(1, 50, expired_log->plist[d1.seq].md_attend))
	, md_admitting = trim(substring(1, 30, expired_log->plist[d1.seq].md_admit))
	, admit_diagnosis = trim(substring(1, 300, expired_log->plist[d1.seq].admit_dx))
	, medical_examiner_coroner = trim(substring(1, 30, expired_log->plist[d1.seq].coroner_notify))
	, medical_examiner_notify_dt = trim(substring(1, 30, expired_log->plist[d1.seq].med_exam_notify))
	, Organ_bank_notify_dt = trim(substring(1, 200, expired_log->plist[d1.seq].organ_bank_notify))
	, autopsy_request = trim(substring(1, 300, expired_log->plist[d1.seq].autopsy_requested))
	, Medical_Examiner_Autopsy = trim(substring(1, 300, expired_log->plist[d1.seq].med_autopsy))
	, funeral_home_name  = trim(substring(1, 200, expired_log->plist[d1.seq].funeral_home))
	, body_transported = trim(substring(1, 30, expired_log->plist[d1.seq].body_transported))
	, body_left_department_dt = trim(substring(1, 30, expired_log->plist[d1.seq].body_left_dt_tm))
 
FROM
	(dummyt   d1  with seq = size(expired_log->plist, 5))
 
plan d1
 
order by facility, date_of_death, patient_name, fin
 
WITH nocounter, separator=" ", format, check
 
# exitscript
 
end go
 
 
 
