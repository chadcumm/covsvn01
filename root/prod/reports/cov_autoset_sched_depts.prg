 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Paramasivam
	Date Written:		May'2020
	Solution:			Quality
	Source file name:  	cov_autoset_sched_depts.prg
	Object name:		cov_autoset_sched_depts
	CR#:				7550
	Program purpose:		Supporting AUTOSET CCL for cov_sn_surgery_covid_dashboard.prg
	Executing from:		CCL
  	Special Notes:		Used to get departments for acute locations
 
******************************************************************************
*  GENERATED MODIFICATION CONTROL LOG
*
******************************************************************************/
 
 
;*******************************************************************************
 
drop program cov_autoset_sched_depts:dba go
create program cov_autoset_sched_depts:dba
 
prompt
	"acute_facility_list" = 0.0
 
with acute_facility_list
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare op_facility_var = vc with noconstant("")
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
;create the AutoSet subroutines
execute ccl_prompt_api_dataset "autoset"
 
;--------------------------------------------------------------------------------------------
 
; Define operator for $acute_facility_list
if (substring(1, 1, reflect(parameter(parameter2($acute_facility_list), 0))) = "L") ; multiple values selected
    set op_facility_var = "IN"
elseif (parameter(parameter2($acute_facility_list), 1) = 0.0) ; any selected
    set op_facility_var = "!="
else ; single value selected
    set op_facility_var = "="
endif
 
;-------------------------------------------------------------------------------------------------

Record book(
	1 fac_cnt = i4
	1 fac[*]
		2 facility = vc
		2 facility_cd = f8
		2 appt_bookid = f8
)

;-------------------------------------------------------------------------------------------------

;Load all prompt facilities & book ids in the RC
select into 'nl:'
  facility_name = uar_get_displaykey(l.location_cd), l.location_cd
 
from location l
where l.location_type_cd = 783.00
and operator(l.location_cd, op_facility_var, $acute_facility_list)
and l.active_ind = 1
and l.location_cd in(2552503635.00, 21250403.00,2552503653.00,2552503639.00,2552503613.00,2552503645.00,2552503649.00)
 
order by l.location_cd

Head report
	cnt = 0
Head l.location_cd
	cnt += 1
	call alterlist(book->fac, cnt)
	book->fac_cnt = cnt
	book->fac[cnt].facility = facility_name
	book->fac[cnt].facility_cd = l.location_cd
	book->fac[cnt].appt_bookid = evaluate(l.location_cd,
		2552503635.00,	1644560.00,	; Fort Loudoun Medical Center
		21250403.00,	1651507.00,	; Fort Sanders Regional Medical Center
		2552503653.00,	1618674.00,	; LeConte Medical Center
		2552503613.00,	1639290.00,	; Methodist Medical Center
		2552503639.00,	1657840.00,	; Morristown-Hamblen Hospital Association
		2552503645.00,	1644785.00,	; Parkwest Medical Center
		2552503649.00,	1639334.00,	; Roane Medical Center
		2553765283.00,	1639316.00,	; MMC Cheyenne Outpatient Diagnostic Center
		2553765579.00,	1644848.00,	; Peninsula Behavioral Health
		2553765363.00,	1666627.00,	; FSR West Diagnostic Center
		2553765491.00,	1657868.00	; MHHS Regional Diagnostic Center
	)	
	
with nocounter

;--------------------------------------------------------------------------------------------
;Select Departments
select distinct into 'nl:'
 
    Department = sab2.mnemonic, sab2.appt_book_id, facility = book->fac[d.seq].facility
 
from (dummyt d with seq = value(size(book->fac,5)))
    , sch_appt_book sab
    , sch_book_list sbl
    , sch_appt_book sab2
    , sch_book_list sbl2
 
plan d
 
join sab where sab.appt_book_id = book->fac[d.seq].appt_bookid
;where operator(sab.appt_book_id, op_facility_var, $acute_facility_list)

join sbl where sbl.appt_book_id = sab.appt_book_id
    
join sab2 where sab2.appt_book_id = sbl.child_appt_book_id
    and sab2.appt_book_id not in (1639442.00, 1644773.00)

join sbl2 where sbl2.appt_book_id = sab2.appt_book_id
 
order by Department ;sbl.seq_nbr
 
Head report
	stat = MakeDataSet(10)
Detail
	stat = WriteRecord(0)
Foot report
	stat = CloseDataSet(0)
 
with ReportHelp, Check
 
 
#exitscript
;--------------------------------------------------------------------------------------------
 
end go
 
 
 
 
 
