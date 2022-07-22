/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		JUN'2021
	Solution:			Quality
	Source file name:	      cov_chg_before_livepat.prg
	Object name:		cov_chg_before_livepat
	Request#:
	Program purpose:	      CHG Project - gather before go live patients
	Executing from:		DA2/Ops
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	-------------------------------------------------------------------------------------------------------*/
 
 
drop program cov_chg_before_livepat:dba go
create program cov_chg_before_livepat:dba
 
prompt 
	"Output to File/Printer/MINe" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 0
	, "Report Type" = 2 

with OUTDEV, acute_facility_list, repo_type
 
 
/**************************************************************
; Variable Declaration
**************************************************************/
 
declare chg_task_var   = vc with constant('Perform Chlorhexidine Treatment'), protect
declare opr_fac_var    = vc with noconstant("")
 
;Set facility variable
if(substring(1,1,reflect(parameter(parameter2($acute_facility_list),0))) = "L");multiple values were selected
	set opr_fac_var = "in"
elseif(parameter(parameter2($acute_facility_list),1)= 0.0) ;all[*] values were selected
	set opr_fac_var = "!="
else								  ;a single value was selected
	set opr_fac_var = "="
endif
 
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
 
Record pat(
	1 rec_cnt = i4
	1 plist[*]
		2 facility = vc
		2 unit = vc
		2 unit_desc = vc
		2 fin = vc
		2 age = vc
		2 pat_name = vc
		2 pat_type = vc
		2 encntrid = f8
		2 patientid = f8
		2 orderid = f8
		2 admitdt = dq8
		2 dischdt = vc
		2 task_fired = vc
)
 
 
;------------------------------------------------------------------------------------------
;Patient admit before CHG go live
 
select into $outdev
 
e.encntr_id, e.reg_dt_tm ';;q', e.disch_dt_tm ';;q'
 
from encounter e
	, encntr_loc_hist elh
	, code_value cv1
 
plan e where operator(e.loc_facility_cd, opr_fac_var, $acute_facility_list)
	;e.loc_facility_cd = $acute_facility_list ;2552503645.00
	and e.active_ind = 1
	and e.encntr_type_cd in(309308.00, 309312.00,19962820.00);Inpatient,Observation,Outpatient in a Bed
	and e.reg_dt_tm >= cnvtdatetime('01-JAN-2021 00:00:00')
	;and e.reg_dt_tm between cnvtdatetime('01-JAN-2021 00:00:00') and cnvtdatetime('01-JUN-2021 11:30:00')
	and e.disch_dt_tm is null
 
join elh where elh.encntr_id = e.encntr_id
	and elh.active_ind = 1
 
join cv1 where cv1.code_value = elh.loc_nurse_unit_cd
	and cv1.code_set = 220
	and cv1.active_ind = 1
	and cv1.cdf_meaning = 'NURSEUNIT'
 
order by e.encntr_id
 
Head report
	cnt = 0
Head e.encntr_id
	cnt += 1
	pat->rec_cnt = cnt
	call alterlist(pat->plist, cnt)
Detail
	pat->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	pat->plist[cnt].admitdt = e.reg_dt_tm
	pat->plist[cnt].pat_type = uar_get_code_display(e.encntr_type_cd)
	pat->plist[cnt].encntrid = e.encntr_id
	pat->plist[cnt].patientid = e.person_id
	pat->plist[cnt].unit = uar_get_code_display(elh.loc_nurse_unit_cd)
	pat->plist[cnt].unit_desc = cv1.description
 
with nocounter
 
IF(pat->rec_cnt > 0)
 
;-----------------------------------------------------------------------------------------
;CHg task fired?
 
select into $outdev
 
ta.encntr_id, task_status = uar_get_code_display(ta.task_status_cd), task_loc = uar_get_code_display(ta.location_cd)
,ta.task_create_dt_tm ';;q', ot.task_description
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, task_activity ta
	, order_task ot
 
plan d
 
join ta where ta.encntr_id = pat->plist[d.seq].encntrid
	and ta.active_ind = 1
 
join ot where ot.reference_task_id = ta.reference_task_id
	and ot.task_description = "Perform Chlorhexidine Treatment"
	and ot.active_ind = 1
 
order by ta.encntr_id
 
Head ta.encntr_id
	idx = 0
	icnt = 0
	task_list = fillstring(1000," ")
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,ta.encntr_id ,pat->plist[icnt].encntrid)
	pat->plist[idx].task_fired = 'Yes'
with nocounter
 
;------------------------------------------------------------------------------------------
;Demographic
 
select into $outdev
 
from (dummyt d with seq = value(size(pat->plist, 5)))
	, person p
	, encntr_alias ea
 
plan d
 
join p where p.person_id = pat->plist[d.seq].patientid
	and p.active_ind = 1
 
join ea where ea.encntr_id = pat->plist[d.seq].encntrid
	and ea.active_ind = 1
	and ea.encntr_alias_type_cd = 1077
 
order by ea.encntr_id
 
Head ea.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(pat->plist,5) ,ea.encntr_id ,pat->plist[icnt].encntrid)
	if(idx > 0)
		pat->plist[idx].pat_name = p.name_full_formatted
		pat->plist[idx].fin = trim(ea.alias)
	endif
 
with nocounter
 
call echorecord(pat)
 
;------------------------------------------------------------------------------------------------------------------
 
if($repo_type = 1)
 
select into $outdev
	facility = substring(1, 30, pat->plist[d1.seq].facility)
	, nurse_unit = substring(1, 30, pat->plist[d1.seq].unit)
	, unit_description = trim(substring(1, 100, pat->plist[d1.seq].unit_desc))
	, fin = substring(1, 30, pat->plist[d1.seq].fin)
	, patient_name = substring(1, 30, pat->plist[d1.seq].pat_name)
	, patient_type = substring(1, 30, pat->plist[d1.seq].pat_type)
	, admit_date = format(pat->plist[d1.seq].admitdt, 'mm/dd/yy hh:mm:ss ;;d')
	, chg_task_fired = substring(1, 3, pat->plist[d1.seq].task_fired)
 
from
	(dummyt   d1  with seq = size(pat->plist, 5))
 
plan d1 where substring(1, 3, pat->plist[d1.seq].task_fired)!= 'Yes'
	and pat->plist[d1.seq].admitdt <= cnvtdatetime('01-JUN-2021 00:00:00')
 
order by facility, nurse_unit
 
with nocounter, separator=" ", format
 
else
 
select into $outdev
	facility = substring(1, 30, pat->plist[d1.seq].facility)
	, nurse_unit = substring(1, 30, pat->plist[d1.seq].unit)
	, unit_description = trim(substring(1, 100, pat->plist[d1.seq].unit_desc))
	, fin = substring(1, 30, pat->plist[d1.seq].fin)
	, patient_name = substring(1, 30, pat->plist[d1.seq].pat_name)
	, patient_type = substring(1, 30, pat->plist[d1.seq].pat_type)
	, admit_date = format(pat->plist[d1.seq].admitdt, 'mm/dd/yy hh:mm:ss ;;d')
	, chg_task_fired = substring(1, 3, pat->plist[d1.seq].task_fired)
 
from
	(dummyt   d1  with seq = size(pat->plist, 5))
 
plan d1 where substring(1, 3, pat->plist[d1.seq].task_fired)!= 'Yes'
	and pat->plist[d1.seq].admitdt > cnvtdatetime('01-JUN-2021 00:00:00')
 
order by facility, nurse_unit
 
with nocounter, separator=" ", format
 
 
endif
 
ENDIF ;rec_cnt
 
#exitscript
 
end
go
 
