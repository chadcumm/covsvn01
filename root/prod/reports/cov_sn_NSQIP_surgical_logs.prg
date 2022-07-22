 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Saravanan
	Date Written:		OCT'2018
	Solution:			Surginet
	Source file name:  	cov_sn_NSQIP_surgical_logs.prg
	Object name:		cov_sn_NSQIP_surgical_logs
	Request#:			3409
 
	Program purpose:	      Surgery logs will be used for NSQIP (national Surgery Quality improvement Program)
	Executing from:		CCL/DA2/Quality folder
  	Special Notes:          Excel file.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_sn_NSQIP_surgical_logs go
create program cov_sn_NSQIP_surgical_logs
 
prompt 
	"Output to File/Printer/MINE" = "MINE"    ;* Enter or select the printer or file name to send this report to.
	, "Start Surgery Date/Time" = "SYSDATE"
	, "End Surgery Date/Time" = "SYSDATE"
	;<<hidden>>"Choose Facility" = 0
	, "Surgery Location" = 0 

with OUTDEV, start_datetime, end_datetime, surgery_locations
 
/* 
Previous Facility Prompt

select
  facility_name = uar_get_code_description(l.location_cd), l.organization_id
from location l
where l.location_type_cd = 783.00
and l.active_ind = 1
and (l.location_cd in(2552503635.00, 21250403.00,2552503653.00,2552503639.00,2552503613.00,2552503645.00,2552503649.00)
                    or l.organization_id = 3234060.00)
order by facility_name
*/ 
 
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare initcap() = c100
declare opr_surg_var = vc with noconstant(fillstring(1000," "))
 
/* for Any(*) option - not working with cascading prompts
; Set Facility Variable
if(substring(1,1,reflect(parameter(parameter2($surgery_locations),0))) = "L") ;multiple locations were selected
	set opr_surg_var = "in"
	elseif(parameter(parameter2($surgery_locations),1) = 0.0) ;all (any) locations were selected
		set opr_surg_var = "!="
	else ;a single value was selected
		set opr_surg_var = "="
endif
 
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
Record logs(
	1 plist[*]
		2 facility = vc
		2 surg_location = vc
		2 personid = f8
		2 encounterid = f8
		2 fin = vc
		2 mrn = vc
		2 dob = vc
		2 patient_name = vc
		2 surgery_dt = vc
		2 surgeon_name = vc
		2 procedure = vc
)
 
;***************************************************************
 
;Patient and Surgery details
select into 'nl:'
 
  fac = uar_get_code_display(e.loc_facility_cd)
   , e.person_id, e.encntr_id
   , fin = ea.alias
   , mrn = ea1.alias
   , birth_dt = format(p.birth_dt_tm, "mm/dd/yyyy")
   , pat_name = p.name_full_formatted
   , surgery_date = format(sc.surg_start_dt_tm, "mm/dd/yyyy")
   , Surgeon = pr.name_full_formatted
   , proc = uar_get_code_display(scp.surg_proc_cd)
   , surg_area = uar_get_code_display(sc.surg_area_cd)
 
from
     encounter e
     , encntr_alias ea
     , encntr_alias ea1
     , surgical_case sc
     , surg_case_procedure scp
     , person p
     , prsnl pr
 
 
plan sc where sc.surg_area_cd = $surgery_locations
	;operator(sc.surg_area_cd, opr_surg_var, $surgery_locations)
	and sc.surg_start_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and sc.active_ind = 1
 
join scp where scp.surg_case_id = sc.surg_case_id
	and scp.proc_complete_qty = 1
	and scp.active_ind = 1
	and scp.primary_proc_ind = 1
 
join e where e.person_id = sc.person_id
	and e.encntr_id = sc.encntr_id
	and e.active_ind = 1
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077 ;fin
	and ea.active_ind = 1
 
join ea1 where ea1.encntr_id = e.encntr_id
	and ea1.encntr_alias_type_cd = 1079 ;mrn
	and ea1.active_ind = 1
 
join p where p.person_id = sc.person_id
 
join pr where pr.person_id = scp.primary_surgeon_id
 
order by fac, e.person_id, e.encntr_id, fin, mrn, birth_dt, pat_name,surgery_date, Surgeon, proc
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT, time = 120;, MAXREC = 10000
 
 
Head report
 	cnt = 0
	call alterlist(logs->plist, 100)
 
Head e.encntr_id
 	cnt = cnt + 1
	call alterlist(logs->plist, cnt)
 
 	logs->plist[cnt].facility = fac
 	logs->plist[cnt].surg_location = surg_area
 	logs->plist[cnt].personid = e.person_id
 	logs->plist[cnt].encounterid = e.encntr_id
 	logs->plist[cnt].fin = fin
 	logs->plist[cnt].mrn = mrn
 	logs->plist[cnt].dob = birth_dt
 	logs->plist[cnt].patient_name = pat_name
 	logs->plist[cnt].surgery_dt = surgery_date
 	logs->plist[cnt].surgeon_name = surgeon
 	logs->plist[cnt].procedure = proc
 
Foot Report
	call alterlist(logs->plist, cnt)
 
with nocounter
 
 
SELECT into value($outdev)
 
	PATIENT_LOCATION = SUBSTRING(1, 30, LOGS->plist[D1.SEQ].facility)
	, SURGERY_LOCATION = SUBSTRING(1, 100, LOGS->plist[D1.SEQ].surg_location)
	, FIN = SUBSTRING(1, 30, LOGS->plist[D1.SEQ].fin)
	, MRN = SUBSTRING(1, 30, LOGS->plist[D1.SEQ].mrn)
	, DOB = SUBSTRING(1, 30, LOGS->plist[D1.SEQ].dob)
	, PATIENT_NAME = SUBSTRING(1, 50, LOGS->plist[D1.SEQ].patient_name)
	, SURGERY_DT = SUBSTRING(1, 30, LOGS->plist[D1.SEQ].surgery_dt)
	, SURGEON_NAME = SUBSTRING(1, 50, LOGS->plist[D1.SEQ].surgeon_name)
	, PROCEDURE = SUBSTRING(1, 300, LOGS->plist[D1.SEQ].procedure)
 
FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(LOGS->plist, 5)))
 
PLAN D1
 
order by PATIENT_LOCATION,SURGERY_LOCATION, SURGERY_DT
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
end
go
 
 
 
