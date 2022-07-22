/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Aug' 2019
	Solution:			Behavior Health
	Source file name:	      cov_bh_substance_abuse.prg
	Object name:		cov_bh_substance_abuse
	Request#:			5002
	Program purpose:	      Substance Abuse Report
	Executing from:		DA2
 	Special Notes:          Only for Psych locations
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_bh_substance_abuse:dba go
create program cov_bh_substance_abuse:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Select Location" = 0
 
with OUTDEV, start_datetime, end_datetime, org_list
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare ciwa_score_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "CIWA-Ar Total Score")),protect
declare ciwa_result_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "CIWA-Ar Result")),protect
declare cows_score_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "COWS Score")),protect
declare audit_score_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "AUDIT Score")),protect
declare audit_c_score_var = f8 with constant(uar_get_code_by("DISPLAY", 72, "BEH Audit C Scoring Tool")),protect
declare audit_alcohol_var = f8 with constant(uar_get_code_by("DISPLAY", 72, "AUDIT Alcohol Use Disorders Test")),protect
 
Record substa(
	1 rec_cnt = i4
	1 plist[*]
		2 fcility = vc
		2 pat_name = vc
		2 fin = vc
		2 mrn = vc
		2 age = vc
		2 ciwa_tot_score = vc
		2 ciwa_ar_result = vc
		2 cows_score = vc   
		2 audit_score = vc  
		2 audit_c_score = vc
		2 audit_alcohol = vc
	) 
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
select into $outdev
 
e.encntr_id, ea.alias, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_tag
 
from    encounter e
	, clinical_event ce
	, encntr_alias ea
	, encntr_alias ea1
	, person p
 
plan e where e.organization_id = $org_list
	and e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.encntr_id != 0.00
	and e.active_ind = 1
 
join ce where ce.encntr_id = e.encntr_id
	and ce.person_id = e.person_id
	and ce.event_cd in(ciwa_score_var, ciwa_result_var, cows_score_var, audit_score_var, audit_c_score_var,audit_alcohol_var)
	and ce.view_level = 1
	and ce.publish_flag = 1 ;active
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth (Verified), Modified

join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1

join ea1 where ea1.encntr_id = e.encntr_id
	and ea1.encntr_alias_type_cd = 1079
	and ea1.active_ind = 1

join p where p.person_id = e.person_id
	and p.active_ind = 1
 
order by p.name_full_formatted, e.encntr_id

Head report
	cnt = 0
Head p.name_full_formatted	
	cnt += 1
	call alterlist(substa->plist, cnt)
	substa->rec_cnt = cnt
Detail
	substa->plist[cnt].fcility = trim(uar_get_code_display(e.loc_facility_cd))
	substa->plist[cnt].pat_name = trim(p.name_full_formatted)
	substa->plist[cnt].fin = trim(ea.alias)
	substa->plist[cnt].mrn = trim(ea1.alias)
	substa->plist[cnt].age = cnvtage(p.birth_dt_tm)
	
	case(ce.event_cd)
		of ciwa_score_var:
			substa->plist[cnt].ciwa_tot_score = trim(ce.result_val)
		of ciwa_result_var:
			substa->plist[cnt].ciwa_ar_result = trim(ce.result_val)  
		of cows_score_var:
			substa->plist[cnt].cows_score = trim(ce.result_val)   
		of audit_score_var:
			substa->plist[cnt].audit_score = trim(ce.result_val)  
		of audit_c_score_var:
			substa->plist[cnt].audit_c_score = trim(ce.result_val)
		of audit_alcohol_var:	
			substa->plist[cnt].audit_alcohol = trim(ce.result_val)
	endcase
	
Foot p.name_full_formatted
	call alterlist(substa->plist, cnt)

with nocounter

call echorecord(substa)
 
;-------------------------------------------------------------------------------------------------
SELECT INTO $OUTDEV

	FCILITY = SUBSTRING(1, 30, SUBSTA->plist[D1.SEQ].fcility)
	, PATIENT_NAME = SUBSTRING(1, 50, SUBSTA->plist[D1.SEQ].pat_name)
	, FIN = SUBSTRING(1, 30, SUBSTA->plist[D1.SEQ].fin)
	, MRN = SUBSTRING(1, 30, SUBSTA->plist[D1.SEQ].mrn)
	, AGE = SUBSTRING(1, 30, SUBSTA->plist[D1.SEQ].age)
	, CIWA_TOTAL_SCORE = SUBSTRING(1, 30, SUBSTA->plist[D1.SEQ].ciwa_tot_score)
	, CIWA_AR_RESULT = SUBSTRING(1, 30, SUBSTA->plist[D1.SEQ].ciwa_ar_result)
	, COWS_SCORE = SUBSTRING(1, 30, SUBSTA->plist[D1.SEQ].cows_score)
	, AUDIT_SCORE = SUBSTRING(1, 30, SUBSTA->plist[D1.SEQ].audit_score)
	, AUDIT_C_SCORE = SUBSTRING(1, 30, SUBSTA->plist[D1.SEQ].audit_c_score)
	;, AUDIT_ALCOHOL = SUBSTRING(1, 30, SUBSTA->plist[D1.SEQ].audit_alcohol)

FROM
	(DUMMYT   D1  WITH SEQ = SIZE(SUBSTA->plist, 5))

PLAN D1

ORDER BY PATIENT_NAME

WITH NOCOUNTER, SEPARATOR=" ", FORMAT



 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 
 

/*
Prompt Query for all Psych locations
 
select organization_id, location = trim(org_name) from  organization o
where o.organization_id in(3234074.00, 3234061.00, 3234068.00, 3234076.00, 3234077.00, 3234075.00, 3234079.00, 3234078.00)
order by o.org_name
*/


  /*
   20441754.00	CIWA-Ar Total Score
   20441761.00	CIWA-Ar Result
   23378669.00	COWS Score
   2552461133.00	AUDIT Score
   40212051.00	BEH Audit C Scoring Tool
   2556992431.00	AUDIT Alcohol Use Disorders Test
*/
 
