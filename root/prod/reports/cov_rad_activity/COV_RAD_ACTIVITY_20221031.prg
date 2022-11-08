/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
     Author:              Steve Czubek
     Date Written:        10/4/2022
     Solution:            Pharmacy
     Source file name:    cov_rad_activity.prg
     Object name:         cov_rad_activity
     Request #:
     Program purpose:     A report showing rad report activity
     Executing from:      CCL
     Special Notes:
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
     Mod Date   Developer                  Comment
    ---------- -------------------- --------------------------------------
    10/04/2022 Steve Czubek         CR 10599 initial release
    10/20/2022 Steve Czubek         corrected some of the prompts
******************************************************************************/
 
drop program cov_rad_activity:dba go
create program cov_rad_activity:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility" = 0
	, "Nurse Unit" = 0
	, "Encounter Class" = 0
	, "Priority" = 0
	, "Exam Status" = 0
	, "Modality" = 0
	, "Exam Name" = 0
	, "Start Date Begin" = "CURDATE"
	, "Start Date End" = "CURDATE"
 
with OUTDEV, facility, nurse_unit, encntr_class, priority, exam_status, modality,
	exam_name, exam_beg_dt, exam_end_date
 
 
%i cust_script:sc_cps_get_prompt_list.inc
free record rpt_data
record rpt_data
(
    1 qual[*]
        2 Facility = vc
        2 Nurse_Unit  = vc
        2 Patient_Name = vc
        2 FIN = vc
        2 Accession = vc
        2 Encounter_Class_Type = vc
        2 Priority = vc
        2 Ordering_Physician = vc
        2 Exam_Name = vc
        2 Exam_Request_Date_Time = vc
        2 Exam_Status = vc
        2 ora_start_date_time = vc
        2 Exam_Begin_Date_Time = vc
        2 Exam_End_Date_Time = vc
        2 Report_Final_Date_Time = vc
        2 Report_Status = vc
        2 Radiologist = vc
        2 Technologist = vc
)
 
declare cnt = i4 with protect, noconstant(0)
declare FINNBR = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
 
declare facility_parser = vc with protect, noconstant("1=1")
set facility_parser = GetPromptList(parameter2($facility), "e.organization_id")
 
declare unit_parser = vc with protect, noconstant("1=1")
set unit_parser = GetPromptList(parameter2($nurse_unit), "e.loc_nurse_unit_cd")
 
declare encntr_class_parser = vc with protect, noconstant("1=1")
set encntr_class_parser = GetPromptList(parameter2($encntr_class), "e.encntr_class_cd")
 
declare priority_parser = vc with protect, noconstant("1=1")
set priority_parser = GetPromptList(parameter2($priority), "ora.priority_cd")
 
declare status_parser = vc with protect, noconstant("1=1")
set status_parser = GetPromptList(parameter2($exam_status), "ora.exam_status_cd")
 
declare modality_parser = vc with protect, noconstant("1=1")
set modality_parser = GetPromptList(parameter2($modality), "oc.activity_subtype_cd")
 
declare exam_parser = vc with protect, noconstant("1=1")
if (IsPromptEmpty(parameter2($exam_name)) = 0)
    set exam_parser = GetPromptList(parameter2($exam_name), "ora.catalog_cd")
endif
 
 
 
free record my_rec
record my_rec
(
    1 text = vc
)
set my_rec->text = exam_parser
call echoxml(my_rec, "cer_temp:sc6809_rec.dat")
 
 
select
    facility = uar_get_code_display(e.loc_facility_cd)
from
    rad_exam re
    ,order_radiology ora
    ,order_catalog oc
    ,prsnl ps_ord
    ,prsnl ps_t
    ,prsnl ps_r
    ,rad_report rr
    ,rad_report_prsnl rrp
    ,omf_radtech_order_st omf
    ,person p
    ,encounter e
    ,encntr_alias ea
plan ora
    where ora.start_dt_tm between cnvtdatetime(concat($exam_beg_dt, " 00:00"))
    and cnvtdatetime(concat($exam_end_date, " 23:59"))
    and parser(priority_parser)
    and parser(exam_parser)
    and parser(status_parser)
join oc
    where oc.catalog_cd = ora.catalog_cd
    and parser(modality_parser)
join ps_ord
    where ps_ord.person_id = ora.order_physician_id
join e
    where e.encntr_id = ora.encntr_id
    and parser(facility_parser)
    and parser(unit_parser)
    and parser(encntr_class_parser)
join p
    where p.person_id = e.person_id
join ea
    where ea.encntr_id = e.encntr_id
    and ea.active_ind = 1
    and ea.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
    and ea.encntr_alias_type_cd = FINNBR
join re
    where re.order_id = ora.order_id
join rr
    where rr.order_id = outerjoin(ora.order_id)
join rrp
    where rrp.rad_report_id = outerjoin(rr.rad_report_id)
    and rrp.prsnl_relation_flag = outerjoin(2)
join ps_r
    where ps_r.person_id = outerjoin(rrp.report_prsnl_id)
join omf
    where omf.order_id = outerjoin(ora.order_id )
join ps_t
    where ps_t.person_id = outerjoin(omf.technologist_id)
order
    facility
    ,re.sched_req_dt_tm
    ,ora.accession_id
head report
    cnt = 0
head ora.accession_id
    if (mod(cnt, 100) = 0)
        stat = alterlist(rpt_data->qual, cnt + 100)
    endif
    cnt = cnt + 1
    rpt_data->qual[cnt].Facility = uar_get_code_display(e.loc_facility_cd)
    rpt_data->qual[cnt].Nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd)
    rpt_data->qual[cnt].Patient_Name = p.name_full_formatted
    rpt_data->qual[cnt].FIN = ea.alias
    rpt_data->qual[cnt].Accession = cnvtacc(ora.accession)
    rpt_data->qual[cnt].Encounter_Class_Type = uar_get_code_display(e.encntr_type_class_cd)
    rpt_data->qual[cnt].Priority = uar_get_code_display(ora.priority_cd)
    rpt_data->qual[cnt].Ordering_Physician = ps_ord.name_full_formatted
    rpt_data->qual[cnt].Exam_Name = uar_get_code_display(ora.catalog_cd)
    rpt_data->qual[cnt].Exam_Request_Date_Time = format(re.sched_req_dt_tm, "MM-DD-YYYY HH:MM")
    rpt_data->qual[cnt].Exam_Status = uar_get_code_display(ora.exam_status_cd)
    rpt_data->qual[cnt].ora_start_date_time = format(ora.start_dt_tm, "MM-DD-YYYY HH:MM")
    rpt_data->qual[cnt].Exam_Begin_Date_Time = format(re.starting_dt_tm, "MM-DD-YYYY HH:MM")
    rpt_data->qual[cnt].Exam_End_Date_Time = format(re.complete_dt_tm, "MM-DD-YYYY HH:MM")
    rpt_data->qual[cnt].Report_Final_Date_Time = format(rr.final_dt_tm, "MM-DD-YYYY HH:MM")
    rpt_data->qual[cnt].Report_Status = uar_get_code_display(ora.report_status_cd)
    rpt_data->qual[cnt].Radiologist = ps_r.name_full_formatted
    rpt_data->qual[cnt].Technologist = ps_t.name_full_formatted
foot report
    stat = alterlist(rpt_data->qual, cnt)
with nocounter
 
select into $outdev
Facility = substring(1, 30, rpt_data->qual[d.seq].Facility ),
Nurse_Unit = substring(1, 30, rpt_data->qual[d.seq].Nurse_unit),
Patient_Name = substring(1, 30, rpt_data->qual[d.seq].Patient_Name ),
FIN = substring(1, 30, rpt_data->qual[d.seq].FIN ),
Accession = substring(1, 30, rpt_data->qual[d.seq].Accession ),
Encounter_Class_Type = substring(1, 30, rpt_data->qual[d.seq].Encounter_Class_Type ),
Priority = substring(1, 30, rpt_data->qual[d.seq].Priority ),
Ordering_Physician = substring(1, 30, rpt_data->qual[d.seq].Ordering_Physician ),
Exam_Name = substring(1, 100, rpt_data->qual[d.seq].Exam_Name ),
Requested_Date_Time = substring(1, 30, rpt_data->qual[d.seq].Exam_Request_Date_Time ),
Exam_Status = substring(1, 30, rpt_data->qual[d.seq].Exam_Status ),
ora_start_date_time = substring(1, 30, rpt_data->qual[d.seq].ora_start_date_time ),
Begin_Date_Time = substring(1, 30, rpt_data->qual[d.seq].Exam_Begin_Date_Time ),
End_Date_Time = substring(1, 30, rpt_data->qual[d.seq].Exam_End_Date_Time ),
Report_Final_Date_Time = substring(1, 30, rpt_data->qual[d.seq].Report_Final_Date_Time ),
Report_Status = substring(1, 30, rpt_data->qual[d.seq].Report_Status ),
Radiologist = substring(1, 30, rpt_data->qual[d.seq].Radiologist),
Technologist = substring(1, 40, rpt_data->qual[d.seq].Technologist )
from
    (Dummyt d with seq = size(rpt_data->qual, 5))
plan d
order
    d.seq
with format, separator = " "
 
#exit_script
end
go
 
