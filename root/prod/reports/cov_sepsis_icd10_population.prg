/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Saravanan
	Date Written:		Sep'2019
	Solution:			Quality
	Source file name:	      cov_sepsis_icd10_population.prg
	Object name:		cov_sepsis_icd10_population
	Request#:			5551
	Program purpose:	      Sepsis analysis - as per Dr.Halford's request
	Executing from:		DA2
 	Special Notes:          Volume by facility for the given timeframe
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
02/24/21    Geetha    CR# 8678 - add an ICD code 'B37.7' 
******************************************************************************/
 
drop program cov_sepsis_icd10_population:dba go
create program cov_sepsis_icd10_population:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"      ;* Enter or select the printer or file name to send this report to.
	, "Start Discharge Date/Time" = "SYSDATE"
	, "End  Discharge  Date/Time" = "SYSDATE" 

with OUTDEV, start_datetime, end_datetime
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
RECORD sepsis(
	1 flist[*]
		2 facility = vc
		2 volume = i4
)
 
RECORD sepsis1(
	1 med_rec_cnt = i4
	1 plist[*]
		2 facility = f8
		2 encntrid = f8
		2 personid = f8
		2 fin = vc
		2 mrn = vc
		2 orderid = f8
		2 order_mnemonic = vc
		2 provider_dignosis = vc
		2 diagnosis_dt = dq8
)
 
 
;-------------------------------------------------------------------------------------------------------------------------------
;Qualification - sepsis find via Provider Diagnosis - ICD-10 base
 
select into 'nl:'
 
dg.encntr_id
, dg.diagnosis_display, ICD10 = n.source_identifier
, dg.diag_dt_tm "@SHORTDATETIME"
;, n.source_vocabulary_cd
 
from
	 encounter e
	, diagnosis dg
	, nomenclature n
 
plan e where e.loc_facility_cd in(2552503635.00, 21250403.00,2552503653.00,2552503639.00,2552503613.00,2552503645.00,2552503649.00) ;no pbh
	;and e.disch_dt_tm between cnvtdatetime("01-JAN-2019 00:00:00") and cnvtdatetime("30-JUN-2019 23:59:00")
	;first time used this date range for Dr.Halford
	and e.disch_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.encntr_type_cd in(309310.00, 309308.00, 309312.00, 19962820.00);ED, Inpatient, Observation, Outpatient in a Bed
	and e.active_ind = 1
	and e.encntr_id != 0.00
	and e.disch_dt_tm is not null
 
join dg where dg.encntr_id = e.encntr_id
	and dg.active_ind = 1
	and dg.active_status_cd = 188
	and dg.diagnosis_display != ''
 
join n where n.nomenclature_id = dg.nomenclature_id
	and n.active_ind = 1
	and n.end_effective_dt_tm > sysdate
	and n.active_status_cd = 188
	and n.source_identifier in ('A02.1', 'A22.7', 'A26.7', 'A32.7', 'A40.0', 'A40.1', 'A40.3', 'A40.8', 'A40.9', 'A41.01', 'A41.02',
					'A41.1', 'A41.2', 'A41.3', 'A41.4', 'A41.50', 'A41.51', 'A41.52', 'A41.53', 'A41.59', 'A41.8', 'A41.81',
					'A41.89', 'A41.9', 'A42.7', 'A54.86', 'R65.20', 'R65.21','B37.7')
 
order by e.loc_facility_cd, e.encntr_id
 
Head report
	fcnt = 0
 
Head e.loc_facility_cd
	fcnt += 1
	vol = 0
	call alterlist(sepsis->flist, fcnt)
	sepsis->flist[fcnt].facility = uar_get_code_display(e.loc_facility_cd)
 
Head e.encntr_id
	vol += 1
 
Foot e.loc_facility_cd
		sepsis->flist[fcnt].volume = vol
 
with nocounter
 
;-------------------------------------------------------------------------------------------------
 
SELECT INTO $OUTDEV
 
	FACILITY = SUBSTRING(1, 30, SEPSIS->flist[D1.SEQ].facility)
	,VOLUME = SEPSIS->flist[D1.SEQ].volume
 
FROM
	(DUMMYT   D1  WITH SEQ = SIZE(SEPSIS->flist, 5))
 
PLAN D1
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
end go
 
 
 
 
 
 
 
 
 
 
 
 
 
 
