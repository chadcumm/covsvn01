 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha
	Date Written:		Oct'2019
	Solution:			Quality
	Source file name:	      cov_phq_disch_diagnosis.prg
	Object name:		cov_phq_disch_diagnosis
	Request#:			6617
	Program purpose:	      Inpatient discharge diagnosis
	Executing from:		DA2
 	Special Notes:          Joint Commision visit helper
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_phq_disch_diagnosis:dba go
create program cov_phq_disch_diagnosis:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"      ;* Enter or select the printer or file name to send this report to.
	, "Start Discharge Date/Time" = "SYSDATE"
	, "End  Discharge  Date/Time" = "SYSDATE"
	, "Acute Facility List" = 0
 
with OUTDEV, start_datetime, end_datetime, acute_facility_list
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
Record pat(
	1 list[*]
		2 facility = vc
		2 fin = vc
		2 pat_name = vc
		2 encntrid = f8
		2 personid = f8
		2 pat_type = vc
		2 admit_dt = vc
		2 disch_dt = vc
		2 disch_dispo = vc
		2 diagnoses = vc ;construct all
)
 
;-----------------------------------------------------------------------------------------------------------------------
;Get all Discharged Inpatients
select into 'nl:'
 
from
	encounter e
	, encntr_alias ea
	, person p
 
plan e where e.loc_facility_cd = $acute_facility_list
	and e.disch_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.active_ind = 1
	and e.disch_dt_tm is not null
 	and e.encntr_type_cd in(309310.00, 309308.00, 309312.00, 19962820.00);ED, Inpatient, Observation, Outpatient in a Bed
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
order by e.encntr_id
 
Head report
	cnt = 0
Head e.encntr_id
	cnt += 1
 	call alterlist(pat->list, cnt)
Detail
 	pat->list[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	pat->list[cnt].fin = ea.alias
	pat->list[cnt].pat_name = p.name_full_formatted
	pat->list[cnt].personid = e.person_id
	pat->list[cnt].encntrid = e.encntr_id
	pat->list[cnt].admit_dt = format(e.reg_dt_tm, 'mm/dd/yyyy hh:mm;;q')
 	pat->list[cnt].disch_dt = format(e.disch_dt_tm, 'mm/dd/yyyy hh:mm;;q')
	pat->list[cnt].disch_dispo = uar_get_code_display(e.disch_disposition_cd)
	pat->list[cnt].pat_type = uar_get_code_display(e.encntr_type_cd)
 
with nocounter
 
;----------------------------------------------------------------------------------------------------
;Get diagnoses
select into 'nl:'
 
fin = pat->list[d.seq].fin, dg.encntr_id
, dg.diagnosis_display, dg_dt1 = format(dg.diag_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
 
from	(dummyt d with seq = size(pat->list , 5))
	, diagnosis dg
 
plan d
 
join dg where dg.encntr_id = pat->list[d.seq].encntrid
	and dg.active_ind = 1
	;and dg.clinical_diag_priority != 0
	and (dg.beg_effective_dt_tm <= sysdate and dg.end_effective_dt_tm >= sysdate)
	and dg.beg_effective_dt_tm = (select max(dg1.beg_effective_dt_tm) from diagnosis dg1 where dg1.encntr_id = dg.encntr_id
			and dg1.diagnosis_display = dg.diagnosis_display
			group by dg1.diagnosis_display)
 
order by dg.encntr_id, dg.clinical_diag_priority asc
 
Head dg.encntr_id
	cnt = 0
	ocnt = 0
 	idx = 0
      idx = locateval(cnt ,1 ,size(pat->list,5) ,dg.encntr_id ,pat->list[cnt].encntrid)
      dg_list_var = fillstring(1000," ")
Detail
	if(idx > 0)
		dg_list_var = build2(trim(dg_list_var),trim(dg.diagnosis_display),',')
	endif
Foot dg.encntr_id
	pat->list[idx].diagnoses = replace(trim(dg_list_var),",","",2)
 
with nocounter
 
call echorecord(pat)
 
;----------------------------------------------------------------------------------------------------------------------------
;Final output display
select into $outdev
 
	facility = trim(substring(1, 5, pat->list[d1.seq].facility))
	, fin = trim(substring(1, 10, pat->list[d1.seq].fin))
	, patient_name = trim(substring(1, 50, pat->list[d1.seq].pat_name))
	, patient_type = trim(substring(1, 30, pat->list[d1.seq].pat_type))
	, admit_dt = substring(1, 20, pat->list[d1.seq].admit_dt)
	, disch_dt = substring(1, 20, pat->list[d1.seq].disch_dt)
	, disch_disposition = trim(substring(1, 100, pat->list[d1.seq].disch_dispo))
	, diagnoses = trim(substring(1, 1000, pat->list[d1.seq].diagnoses))
 
from 	(dummyt   d1  with seq = size(pat->list, 5))
 
plan d1
 
with nocounter, separator=" ", format
 
 
end
go
 
