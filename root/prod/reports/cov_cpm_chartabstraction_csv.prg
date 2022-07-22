/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:			Geetha Saravanan
	Date Written:		June 2018
	Solution:			Cerner Practice Management
	Source file name:	      cov_cpm_ChartAbstraction_csv.prg
	Object name:		cov_cpm_ChartAbstraction_csv
 
	Request#:			1396
	Program purpose:	      To get patients have been added to a schedule that need to have chart abstraction completed.
 
	Executing from:		Reporting Portal
 
 	Special Notes:          Excel format
 
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
10/29/2018  Dawn Greer, DBA         Changed the Clinic Prompt query to pull
                                    all clinics
10/30/2018  Dawn Greer, DBA         Changed the Clinic Prompt back to the original
                                    query but removed the criteria to pick 
                                    certain clinics.                                      
******************************************************************************/
 
 
drop program cov_cpm_chartabstraction_csv:dba go
create program cov_cpm_chartabstraction_csv:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Choose Clinics" = 0
 
with OUTDEV, start_datetime, end_datetime, clinic_list
 
 
/**************************************************************
; SUBROUTINES
**************************************************************/
;%i cust_script:cov_CommonLibrary.inc
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
;declare alias_poolcd_var     = f8 with constant(get_AliasPoolCode($facility)), protect
;declare facility_name_var    = vc with constant(uar_get_code_description($facility)),protect
declare mrn_var              = f8 with constant(uar_get_code_by("DISPLAY", 319, "MRN")),protect
declare fin_var              = f8 with constant(uar_get_code_by("DISPLAY", 319, "FIN NBR")),protect
declare initcap()            = c100
 
declare cerner_mrn_var = f8 with constant(uar_get_code_by("DISPLAY_KEY", 263, 'CERNERMRN')),protect  ;2554138271.00
declare prsnl_var      = f8 with constant(uar_get_code_by("DISPLAY",     331, 'Primary Care Physician')),protect  ;1115.00
declare position_var   = f8 with constant(uar_get_code_by("CDF_MEANING", 88 , 'PRIMARY CARE')),protect  ;19944603.00
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
RECORD appt(
	1 plist[*]
		2 clinic      = vc
		2 pat_name    = vc
		2 pat_dob     = dq8
		2 pat_mrn     = vc
		2 app_type    = vc
		2 app_dt      = dq8
		2 appt_resource  = vc
		2 pat_comment = vc
		2 status = vc
)
 
 
select distinct into value($outdev)
 
Clinic = uar_get_code_display(sa.appt_location_cd)
,Pat_Name = initcap(p.name_full_formatted)
,DOB = p.birth_dt_tm
,MRN = pa.alias
,Appt_Type = uar_get_code_display(se.appt_type_cd)
;,Appt_dt_tm = sa.beg_dt_tm
,Appt_dt_tm = format(sa.beg_dt_tm, "mm/dd/yyyy hh:mm ;;d")
,resource = uar_get_code_display(sa1.resource_cd);phys and lab resource
,Status = sa.state_meaning
,comment = replace(replace(replace(l2.long_text, char(13), " " ,0), char(10), " ",0), char(45),'',0)
; get ride of carriage return, line feed and '-' in the comment
,Person_id = sa.person_id
,Appt_id = sa.sch_appt_id
 
from
	  person p
	, person_alias pa
	, encntr_prsnl_reltn epr
	, person_info pi
	, long_text l2
	, sch_appt sa
	, sch_appt sa1
	, sch_event se
	, dummyt d ;to avoid clob data type - runtime issue
 
plan sa where sa.appt_location_cd = $clinic_list
	and sa.beg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and cnvtupper(sa.role_meaning) = 'PATIENT'
	and sa.sch_state_cd in(4538.00, 4536.00, 4537.00,4054213.00, 4541.00)
	and sa.active_ind = 1
 
join se where se.sch_event_id = outerjoin(sa.sch_event_id)
	and se.active_ind = outerjoin(1)
 
join sa1 where sa1.sch_event_id = outerjoin(se.sch_event_id)
	and cnvtupper(sa1.role_meaning) = outerjoin('RESOURCE')
	and sa1.active_ind = outerjoin(1)
 
join p where p.person_id = outerjoin(sa.person_id)
	and p.active_ind = outerjoin(1)
 
join pa where pa.person_id = outerjoin(p.person_id)
	and pa.alias_pool_cd = outerjoin(cerner_mrn_var) ; 2554138271.00
	and pa.active_ind = outerjoin(1)
 
join pi where pi.person_id = outerjoin(p.person_id)
	and pi.info_type_cd = outerjoin(1169)
	and pi.active_ind = outerjoin(1)
 
join l2 where l2.long_text_id = outerjoin(pi.long_text_id)
	and l2.active_ind = outerjoin(1)
 
join epr where epr.encntr_id = outerjoin(sa.encntr_id)
       and epr.active_ind = outerjoin(1)
       and epr.encntr_prsnl_r_cd = outerjoin(1119.00) ;Attending Phys
 
join d
 
order by sa.appt_location_cd, sa.beg_dt_tm, p.person_id, sa.sch_appt_id, p.name_full_formatted, sa.state_meaning
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT, MAXTIME = 120
 
 
 
/*
select distinct into 'NL:';$outdev
 
NAME = initcap(p.name_full_formatted)
,sa.person_id
,DOB = p.birth_dt_tm
,MRN = pa.alias
,Appt_Type = uar_get_code_display(se.appt_type_cd)
,Appt_dt_tm = sa.beg_dt_tm
,resource = uar_get_code_display(sa1.resource_cd);phys and lab resource
,Department = uar_get_code_display(sa.appt_location_cd)
,comment = replace(l2.long_text, char(45),'',0) ;get ride of all '-' in the comment
;,prsnl = if(pr.name_full_formatted != ' ') initcap(pr.name_full_formatted) else initcap(pr1.name_full_formatted) endif
,Status = sa.state_meaning
 
from
	  person p
	, person_alias pa
	, encntr_prsnl_reltn epr
	, person_info pi
	, long_text l2
	, sch_appt sa  ;patient
	, sch_appt sa1 ;resource/physician/lab
	, sch_event se
	;, sch_resource sr
	;, prsnl pr
	;, prsnl pr1
	, dummyt d ;to avoid clob data type - runtime issue
 
 
plan sa where sa.appt_location_cd = $clinic_list
	and sa.beg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and cnvtupper(sa.role_meaning) = 'PATIENT'
	;and sa.sch_state_cd in(4538.00, 4536.00, 4537.00,4054213.00, 4541.00)
	;and cnvtupper(sa.state_meaning) in('CONFIRMED','CHECKED IN','CHECKED OUT','COMPLETE','FINALIZED')
	and sa.active_ind = 1
 
join se where se.sch_event_id = outerjoin(sa.sch_event_id)
	and se.active_ind = outerjoin(1)
 
join sa1 where sa1.sch_event_id = outerjoin(se.sch_event_id)
	and cnvtupper(sa1.role_meaning) = outerjoin('RESOURCE')
	and sa1.active_ind = outerjoin(1)
 
;join sr where sr.resource_cd = outerjoin(sa1.resource_cd)
;	and sa1.active_ind = outerjoin(1)
 
join p where p.person_id = sa.person_id
	and p.active_ind = 1
 
join pa where pa.person_id = outerjoin(p.person_id)
	and pa.alias_pool_cd = outerjoin(cerner_mrn_var) ; 2554138271.00
	and pa.active_ind = outerjoin(1)
 
join pi where pi.person_id = outerjoin(p.person_id)
	and pi.info_type_cd = outerjoin(1169)
	and pi.active_ind = outerjoin(1)
 
join l2 where l2.long_text_id = outerjoin(pi.long_text_id)
	and l2.active_ind = outerjoin(1)
 
join epr where epr.encntr_id = outerjoin(sa.encntr_id)
       and epr.active_ind = outerjoin(1)
       and epr.encntr_prsnl_r_cd = outerjoin(1119.00) ;Attending Phys
 
join d
 
order by sa.appt_location_cd, pa.alias, p.name_full_formatted, sa.beg_dt_tm, l2.long_text
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT, MAXTIME = 120
 
 
;Populate appointment list into the Record Structure
Head report
cnt = 0
call alterlist(appt->plist, 10)
 
Detail
 	cnt = cnt + 1
	call alterlist(appt->plist, cnt)
 
	appt->plist[cnt].clinic = department
	appt->plist[cnt].pat_name = name
	appt->plist[cnt].pat_dob = dob
	appt->plist[cnt].pat_mrn = mrn
	appt->plist[cnt].app_type = appt_type
	appt->plist[cnt].app_dt = Appt_dt_tm
	appt->plist[cnt].appt_resource = resource
	appt->plist[cnt].status = sa.state_meaning
	appt->plist[cnt].pat_comment = replace(replace(comment, char(13), " " ,0), char(10), " ",0)
 				; get ride of carriage return and line feed in the comment
foot report
 
	call alterlist(appt->plist, cnt)
 
with nocounter
 
call echorecord(appt)
 
 
SELECT DISTINCT INTO VALUE($OUTDEV)
	CLINIC = TRIM(SUBSTRING(1, 100, APPT->plist[D1.SEQ].clinic))
	, PAT_NAME = TRIM(SUBSTRING(1, 50, APPT->plist[D1.SEQ].pat_name))
	, PAT_DOB = FORMAT(APPT->plist[D1.SEQ].pat_dob, "MM/DD/YYYY;;D")
	, PAT_MRN = SUBSTRING(1, 10, APPT->plist[D1.SEQ].pat_mrn)
	, APP_TYPE = SUBSTRING(1, 30, APPT->plist[D1.SEQ].app_type)
	, APP_DT_TM = FORMAT(APPT->plist[D1.SEQ].app_dt, "MM/DD/YYYY HH:MM;;D")
	, RESOURCE = TRIM(SUBSTRING(1, 50, APPT->plist[D1.SEQ].appt_resource))
	, STATUS = TRIM(SUBSTRING(1, 50, APPT->plist[D1.SEQ].status))
	, PAT_COMMENT = TRIM(SUBSTRING(1, 300, APPT->plist[D1.SEQ].pat_comment))
 
FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(APPT->plist, 5)))
 
PLAN D1
 
ORDER BY CLINIC, APP_DT_TM, PAT_NAME
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT, SKIPREPORT = 1, TIME = 120
 
*/
 
 
end
go
 
 
 
 
/*
 
select * from person where name_last = 'WILLIFORD' and name_first = '*JEWELL*'
 
select * from sch_appt where person_id =    16048163.00
 
****** To get the count of patients *******
select appt_location_cd, person_id, SCH_EVENT_ID, role_meaning, beg_dt_tm, sch_state_cd, state_meaning
from sch_appt where appt_location_cd =  2553456385.00
and beg_dt_tm >= cnvtdatetime("24-JUL-2018 00:00:00")
and beg_dt_tm <= cnvtdatetime("24-JUL-2018 23:59:00")
and role_meaning = 'PATIENT'
and sch_state_cd in(4538.00, 4536.00, 4537.00,4054213.00, 4541.00)
 
 
-- To Find Comment Text
select pa.alias, pa.person_id, l2.long_text
from person_alias pa, person_info pi, long_text l2
where pa.alias = "500005012"
and pi.person_id = pa.person_id
and l2.long_text_id = pi.long_text_id
and pi.info_type_cd = 1169
 
------
 
*/
