 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Paramasivam
	Date Written:		Mar'2020
	Solution:			Quality
	Source file name:  	cov_phq_mobile_transport_adhoc.prg
	Object name:		cov_phq_mobile_transport_adhoc
	Request#:			7259
 	Program purpose:	      CCL for Mobile Transport App
	Executing from:		Mark Maples will utilize this code in his mobile app script
  	Special Notes:		Delimitted with | 
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	-----------------------------------------------------------------
08/31/21    Geetha   CR# 10946 - adjust the ccl to show only bed alarm response instead of the whole free text
 
******************************************************************************/
 
drop program cov_phq_mobile_transport_adhoc:dba go
create program cov_phq_mobile_transport_adhoc:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "FIN" = ""
	, "Facility" = 0
 
with OUTDEV, fin, facility
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare resucite_var    = f8 with constant(uar_get_code_by('DESCRIPTION', 200,'Resuscitation Status/Medical Interventions')), protect
declare telemetry_var   = f8 with constant(uar_get_code_by('DESCRIPTION', 200,'PSO Admit to Inpatient')), protect
 
declare ambu_assist_var = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Ambulation Assistance')), protect
declare iv_var          = f8 with constant(uar_get_code_by('DISPLAY', 72, 'IV Order Detail')), protect
declare oxygen_var      = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Oxygen Order Detail')), protect
declare transport_var   = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Transport Mode Order Detail')), protect
declare isolation_var   = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Isolation Precautions')), protect
declare mental_stat_var = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Fall Intervention Mental Status')), protect
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
Record trans(
	1 plist[*]
		2 facility = f8
		2 fin = vc
		2 encntrid = f8
		2 personid = f8
		2 patient_name = vc
		2 admit_nu = vc
		2 admit_room = vc
		2 dob = vc
		2 age = vc
		2 sex = vc
		2 current_nu = vc
		2 current_room = vc
		2 current_bed = vc
		2 resuci_det = vc
		2 telemitry_info = vc
		2 fall_alarm = vc
		2 isolation_precaution = vc
		2 transport_mode = vc
		2 iv = vc
		2 oxygen = vc
		2 ambulation = vc
		2 fall = vc
)
 
;------------------------------------------------------------------------------------------------
;Get demographic
 
select into $outdev
  fin = ea.alias, e.encntr_id, age_years = trim(cnvtage(p.birth_dt_tm), 3)
 
from
  encounter e,
  encntr_alias ea,
  person p
 
where e.loc_facility_cd = $facility
  and e.active_ind = 1
  and e.disch_dt_tm is null
 
  and ea.encntr_id = e.encntr_id
  and ea.alias = $fin
  and ea.encntr_alias_type_cd = 1077
  and ea.active_ind = 1
 
  and p.person_id = e.person_id
  and p.active_ind = 1
 
order by e.encntr_id
 
Head report
	cnt = 0
Head e.encntr_id
	cnt += 1
	call alterlist(trans->plist, cnt)
	trans->plist[cnt].facility = e.loc_facility_cd
	trans->plist[cnt].fin = trim(ea.alias)
	trans->plist[cnt].personid = e.person_id
	trans->plist[cnt].encntrid = e.encntr_id
	trans->plist[cnt].patient_name = trim(p.name_full_formatted)
	trans->plist[cnt].age = age_years
	trans->plist[cnt].dob = format(p.birth_dt_tm, 'mm/dd/yy;;d')
	trans->plist[cnt].sex = uar_get_code_display(p.sex_cd)
	trans->plist[cnt].admit_nu = trim(uar_get_code_display(e.loc_nurse_unit_cd))
	trans->plist[cnt].admit_room = build2(trim(uar_get_code_display(e.loc_room_cd)), '-'
		,trim(uar_get_code_display(e.loc_bed_cd)))
 
with nocounter
 
;-------------------------------------------------------------------------------------------------
;Get current/active Nurse unit and room
select into 'nl:'
 
elh.encntr_id, elh.loc_nurse_unit_cd, elh.loc_room_cd
 
from (dummyt d with seq = size(trans->plist, 5))
	,encntr_loc_hist elh
 
plan d
 
join elh where elh.encntr_id = trans->plist[d.seq].encntrid
	and elh.active_ind = 1
	and elh.active_status_cd = 188
	and (elh.beg_effective_dt_tm <= sysdate and elh.end_effective_dt_tm >= sysdate)
 
order by elh.encntr_id
 
Head elh.encntr_id
	trans->plist[d.seq].current_nu = uar_get_code_display(elh.loc_nurse_unit_cd)
	trans->plist[d.seq].current_room = if(elh.loc_room_cd != 0) uar_get_code_display(elh.loc_room_cd) else ' ' endif
	trans->plist[d.seq].current_bed = if(elh.loc_bed_cd != 0) uar_get_code_display(elh.loc_bed_cd) else ' ' endif
 
with nocounter
 
;-----------------------------------------------------------------------------------------------------
;Get clinical events
select into 'nl:'
 
ce.encntr_id, ce.event_cd, event = uar_get_code_display(ce.event_cd)
, ce.result_val, ce.event_tag, ce.event_title_text
 
from (dummyt d with seq = size(trans->plist, 5))
	,clinical_event ce
 
plan d
 
join ce where ce.encntr_id = trans->plist[d.seq].encntrid
	and ce.event_cd in(ambu_assist_var, iv_var, oxygen_var,transport_var, isolation_var)
	and ce.event_id = (select min(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
		and ce1.event_cd = ce.event_cd
		and ce1.result_status_cd in (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth (Verified), Modified
		group by ce1.encntr_id, ce1.event_cd)
 
order by ce.encntr_id
 
Head ce.encntr_id
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,size(trans->plist,5), ce.encntr_id ,trans->plist[icnt].encntrid)
 
Detail
	case(ce.event_cd)
		of ambu_assist_var:
			trans->plist[idx].ambulation = trim(ce.result_val)
		of iv_var:
			trans->plist[idx].iv = if(trim(ce.result_val) = '1') 'Yes' elseif(trim(ce.result_val) = '0')'No' else ' ' endif
		of oxygen_var:
			trans->plist[idx].oxygen = if(trim(ce.result_val) = '1') 'Yes' elseif(trim(ce.result_val) = '0')'No' else ' ' endif
		of transport_var:
			trans->plist[idx].transport_mode = trim(ce.result_val)
		of isolation_var:
			trans->plist[idx].isolation_precaution = trim(ce.result_val)
	endcase
 
with nocounter
 
;-----------------------------------------------------------------------------------------------------
;Bed alarm
select into 'nl:'
 
from (dummyt d with seq = size(trans->plist, 5))
	,clinical_event ce
 
plan d
 
join ce where ce.encntr_id = trans->plist[d.seq].encntrid
	and ce.event_cd = mental_stat_var
	and ce.result_status_cd in (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth (Verified), Modified
 
order by ce.encntr_id
 
Head ce.encntr_id
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,size(trans->plist,5), ce.encntr_id ,trans->plist[icnt].encntrid)
	if(idx > 0) 
		if( (cnvtlower(trim(ce.result_val)) = '*bed alarm*')or (cnvtlower(trim(ce.result_val)) = '*chair alarm*')
			or (cnvtlower(trim(ce.result_val)) = '*bed alarm/chair alarm*') )
			trans->plist[idx].fall_alarm = 'Bed alarm/chair alarm'
		endif
	endif
 
with nocounter
 
;-----------------------------------------------------------------------------------------------------
;Resucitation Orders
select into 'nl:'
 
from 	(dummyt d with seq = size(trans->plist, 5))
	, orders o
	, order_action oa
 
plan d
 
join o where o.encntr_id = trans->plist[d.seq].encntrid
	and o.active_ind = 1
	and o.catalog_cd = resucite_var
	and o.order_id = (select max(o1.order_id) from orders o1
			 where o1.encntr_id = o.encntr_id and o1.catalog_cd = o.catalog_cd)
	and o.active_status_cd = 188
	and o.order_status_cd = 2550.00 ;Ordered
	and o.current_start_dt_tm <= sysdate
	and (o.projected_stop_dt_tm > sysdate or o.projected_stop_dt_tm is null)
 
join oa where oa.order_id = o.order_id
	and oa.action_sequence = o.last_action_sequence
 
order by o.encntr_id, o.order_id
 
Head o.encntr_id
	length = textlen(trim(o.order_detail_display_line))
	trans->plist[d.seq].resuci_det = trim(substring(23, length, o.order_detail_display_line))
 
with nocounter
 
;-----------------------------------------------------------------------------------------
;PSO Inpatient Orders
select into $outdev
 
from 	(dummyt d with seq = size(trans->plist, 5))
	, orders o
	, order_action oa
 
plan d
 
join o where o.encntr_id = trans->plist[d.seq].encntrid
	and o.active_ind = 1
	and o.catalog_cd = telemetry_var
	and o.order_id = (select max(o1.order_id) from orders o1
			 where o1.encntr_id = o.encntr_id and o1.catalog_cd = o.catalog_cd)
	and o.active_status_cd = 188
	and o.order_status_cd = 2550.00 ;Ordered
	and o.current_start_dt_tm <= sysdate
 
join oa where oa.order_id = o.order_id
	and oa.action_sequence = o.last_action_sequence
 
order by o.encntr_id
 
Head o.encntr_id
	length = textlen(trim(o.order_detail_display_line))
	trans->plist[d.seq].telemitry_info = trim(substring(1, length, o.order_detail_display_line))
	;trans->plist[d.seq].telemitry_info = trim(substring(23, length, o.order_detail_display_line))
 
with nocounter
 
;--------------------------------------------------------------------------------------------------
;Fall Risk Interventions
select into 'nl:'
 
from
	(dummyt d with seq = size(trans->plist, 5))
	, problem p
 
plan d
 
join p where p.person_id = trans->plist[d.seq].personid
	and p.problem_id = (select max(p1.problem_id) from problem p1
			where p1.person_id = p.person_id
			and p1.active_ind = 1
			and cnvtlower(p1.annotated_display) = '*fall*'
			and (p1.beg_effective_dt_tm <= sysdate and p1.end_effective_dt_tm >= sysdate)
			group by p1.person_id)
 
order by p.person_id, p.problem_id
 
Head p.person_id
 
	trans->plist[d.seq].fall = trim(p.annotated_display)
 
with nocounter
 
 
;---------------------------------------------------------------------------------------
;Final output
select into $outdev
	facility = uar_get_code_description(trans->plist[d1.seq].facility)
	, fin = trim(substring(1, 10, trans->plist[d1.seq].fin))
	, patient_name = trim(substring(1, 50, trans->plist[d1.seq].patient_name))
	, dob = trim(substring(1, 20, trans->plist[d1.seq].dob))
	, age = trim(substring(1, 10, trans->plist[d1.seq].age))
	, sex = trim(substring(1, 10, trans->plist[d1.seq].sex))
	, location = if(trim(substring(1, 30, trans->plist[d1.seq].current_nu)) != ' ')
				trim(substring(1, 30, trans->plist[d1.seq].current_nu))
			else
				trim(substring(1, 30, trans->plist[d1.seq].admit_nu))
			endif
	, room = if(trim(substring(1, 30, trans->plist[d1.seq].current_room)) != ' ')
				build2(trim(substring(1, 30, trans->plist[d1.seq].current_room))
				,'-',trim(substring(1, 30, trans->plist[d1.seq].current_bed)))
		   else
		   		trim(substring(1, 30, trans->plist[d1.seq].admit_room))
		   endif
 
	, code_status = trim(substring(1, 100, trans->plist[d1.seq].resuci_det))
	, isolation_precautions = trim(substring(1, 100, trans->plist[d1.seq].isolation_precaution))
	, method_of_transport = trim(substring(1, 100, trans->plist[d1.seq].transport_mode))
	, iv_status = trim(substring(1, 15, trans->plist[d1.seq].iv))
	, oxygen_status = trim(substring(1, 15, trans->plist[d1.seq].oxygen))
	, ambulation = trim(substring(1, 100, trans->plist[d1.seq].ambulation))
	, fall_risk_status = trim(substring(1, 100, trans->plist[d1.seq].fall))
	, telemitry = trim(substring(1, 100, trans->plist[d1.seq].telemitry_info))
	, bed_alarm = trim(substring(1, 100, trans->plist[d1.seq].fall_alarm))
 
from
	(dummyt   d1  with seq = size(trans->plist, 5))
 
plan d1
 
with nocounter, format, separator = "|", noheading, time = 60
 
#exitscript
 
end
go
 
 
