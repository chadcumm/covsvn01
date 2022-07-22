/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Nov'2020
	Solution:			INA/IC
	Source file name:	      cov_ic_diagnosis_problems.prg
	Object name:		cov_ic_diagnosis_problems
	Request#:			8788
	Program purpose:	      Inpatient diagnosis and problems
	Executing from:		DA2
 	Special Notes:          Rule helper to identify diag/dx
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 

drop program cov_ic_diagnosis_problems:DBA go
create program cov_ic_diagnosis_problems:DBA

prompt 
	"Output to File/Printer/MINE" = "MINE"      ;* Enter or select the printer or file name to send this report to.
	, "Start Discharge Date/Time" = "SYSDATE"
	, "End  Discharge  Date/Time" = "SYSDATE"
	, "Acute Facility List" = 0
	, "Report Type" = "1" 

with OUTDEV, start_datetime, end_datetime, acute_facility_list, repo_type

 
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
		2 problems = vc ;construct all
)
 
;-----------------------------------------------------------------------------------------------------------------------
;Get all Inpatients
select into 'nl:'
 
from
	encounter e
	, encntr_alias ea
	, person p
 
plan e where e.loc_facility_cd = $acute_facility_list
	and e.disch_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.active_ind = 1
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
if($repo_type = '2')

;Get diagnoses
select into $outdev
 
fin = pat->list[d.seq].fin, dg.nomenclature_id
,diagnosis = trim(dg.diagnosis_display)
 
from	(dummyt d with seq = size(pat->list , 5))
	, diagnosis dg
 
plan d
 
join dg where dg.encntr_id = pat->list[d.seq].encntrid
	and dg.active_ind = 1
	and (dg.beg_effective_dt_tm <= sysdate and dg.end_effective_dt_tm >= sysdate)
 
order by fin
 
with nocounter, separator=" ", format
 
/*Head dg.encntr_id
	cnt = 0
	ocnt = 0
 	idx = 0
      idx = locateval(cnt ,1 ,size(pat->list,5) ,dg.encntr_id ,pat->list[cnt].encntrid)
      dg_list_var = fillstring(3000," ")
Detail
	if(idx > 0)
		dg_list_var = build2(trim(dg_list_var),trim(dg.diagnosis_display),',')
	endif
Foot dg.encntr_id
	pat->list[idx].diagnoses = replace(trim(dg_list_var),",","",2)
 
with nocounter*/
 
;call echorecord(pat)

;-------------------------------------------------------------------------------------------------- 
else ;$repo_type = '1'

;Get Problems
select into $outdev
 
fin = pat->list[d.seq].fin;, enc = pat->list[d.seq].encntrid
,pm.nomenclature_id, problem = trim(pm.annotated_display)
 
from	(dummyt d with seq = size(pat->list , 5))
	,problem pm

plan d
 
join pm where pm.person_id = pat->list[d.seq].personid
	and pm.active_ind = 1
 
order by pm.person_id, fin

with nocounter, separator=" ", format

endif ;repo_type

/*
 
Head pm.person_id
	tt = 0
Head enc	
	cnt = 0
	ocnt = 0
 	idx = 0
      idx = locateval(cnt ,1 ,size(pat->list,5) ,enc ,pat->list[cnt].encntrid)
      dg_list_var = fillstring(3000," ")
Detail
	if(idx > 0)
		dg_list_var = build2(trim(dg_list_var),trim(pm.annotated_display),',')
	endif
Foot enc
	pat->list[idx].problems = replace(trim(dg_list_var),",","",2)
 
with nocounter

endif ;repo_type */

;----------------------------------------------------------------------------------------------------------------------------
/*
;Final output display

if($repo_type = 2)

select into $outdev
 	facility = trim(substring(1, 5, pat->list[d1.seq].facility))
	, fin = trim(substring(1, 10, pat->list[d1.seq].fin))
	, patient_type = trim(substring(1, 30, pat->list[d1.seq].pat_type))
	, diagnoses_list = trim(substring(1, 3000, pat->list[d1.seq].diagnoses))
 
from 	(dummyt   d1  with seq = size(pat->list, 5))
 
plan d1
 
with nocounter, separator=" ", format

else 

select into $outdev
 	facility = trim(substring(1, 5, pat->list[d1.seq].facility))
	, fin = trim(substring(1, 10, pat->list[d1.seq].fin))
	, patient_type = trim(substring(1, 30, pat->list[d1.seq].pat_type))
	, problem_list = trim(substring(1, 3000, pat->list[d1.seq].problems))
 
from 	(dummyt   d1  with seq = size(pat->list, 5))
 
plan d1
 
with nocounter, separator=" ", format

endif 
 */
end
go
 
