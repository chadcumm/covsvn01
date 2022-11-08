 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha
	Date Written:		Feb'2019
	Solution:			Quality/Nursing
	Source file name:  	cov_phq_suicide_risk_assment.prg
	Object name:		cov_phq_suicide_risk_assment
	CR#:				4428
 	Program purpose:		Quality - Columbia Suicide Severity Rating Scale Screen or CSSRS.
					used for Joint Commission Review
	Executing from:		CCL/DA2
  	Special Notes:		Auto set program do drive facility prompt
 
*****************************************************************************************************************
*  GENERATED MODIFICATION CONTROL LOG
*
*  Revision #   Mod Date    Developer             Comment
*  -----------  ----------  -----------  -------------------------------------------------------------------------
*  CR#5594     09/19/19    Geetha   Change the report to look at "Active" LOOK BACCK BEYOND date range for orders
						 so the pts with suicide precautions will show up.
						 Also request from Lori to hide child "Precaution Suicide" orders.
 
   CR#7063     02/13/20    Geetha	 Prevent Behavioral Health reports from being ran by non BH employees
   						 Also, we don't want Parkwest BH to see Morristown's BH units and vise versa.
   
   CR#7852     06/02/20    Geetha   Change to pull the newer CSSRS DTAs and change column headins based on DTA name.  
   
   CR#13041    11/01/22    Geetha   CMC added						 
	   						 
*******************************************************************************************************************/
 
drop program cov_phq_suicide_risk_assment:DBA go
create program cov_phq_suicide_risk_assment:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Select Facility" = 0
 
with OUTDEV, start_datetime, end_datetime, facility
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare initcap() = c100
declare cnt = i4 with noconstant(0)
 
declare cssrs1_ip_dead_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "IP CSSRS Wish to be Dead")),protect
declare cssrs2_ip_suicide_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, "IP CSSRS Suicidal Thoughts")),protect
declare cssrs6_ip_screen_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "IP CSSRS Screen Suicide Behavior")),protect
declare suicide_re_assess_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, "Suicide Re-assessment")),protect
declare safety_chklist_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Safety Checklist")),protect
declare room_search_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Room Search")),protect
declare suicide_precaution_var = f8 with constant(uar_get_code_by("DISPLAY", 200, "Precaution Suicide")),protect
 
;Old CSSRS DTA's
;declare q1_past_dead_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, "Past Month Wish to be Dead")),protect
;declare q2_past_suicide_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Past Month Suicidal Thoughts")),protect
;declare q6_cssrs_screen_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Columbia Screen Suicide Behavior")),protect


/**************************************************************
; DVDev Start Coding
**************************************************************/
 
Record suici(
	1 rec_cnt = i4
	1 plist[*]
		2 facility = vc
		2 nurse_unit = vc
		2 room = vc
		2 bed = vc
		2 personid = f8
		2 encounterid = f8
		2 fin = vc
		2 patient_name = vc
		2 pat_type = vc
		2 admit_dt = vc
		2 ssrss_screen_date = vc
		2 safety_checklist = vc
		2 safety_checklist_dt = vc
		2 room_search = vc
		2 room_search_dt = vc
		2 safety_checklist_completed = vc
		2 precaution_charted = vc
		2 precaution_charted_dt = vc
		2 cssrs1_response = vc
		2 cssrs2_response = vc
		2 cssrs6_response = vc
		2 suicide_re_assess = vc
		2 suicide_re_assess_dt = vc
		2 phys_placed_preca_order = vc
)
 
;-----------------------------------------------------------------------------------------------------------------------------
;Clinical events from Power Form
 
select into 'nl:'
 
Facility = uar_get_code_display(e.loc_facility_cd)
, nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd)
, e.person_id, e.encntr_id, pat_type = uar_get_code_display(e.encntr_type_cd)
, event = uar_get_code_display(ce.event_cd), ce.event_cd
, ce.result_val
, event_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
 
from
	encounter e
	,clinical_event ce
 
plan e where e.loc_facility_cd = $facility
	and e.active_ind = 1
	and e.encntr_type_cd in(309308.00, 309312.00, 19962820.00, 309310.00, 2555137051.00)
				;Inpatient, Observation, Outpat in a bed, Emergency, Behavioral Health
 
join ce where ce.person_id = e.person_id
	and ce.encntr_id = e.encntr_id
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
      and ce.view_level = 1
      and ce.publish_flag = 1 ;active
      and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
      and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth (Verified), Modified
 	and ce.event_cd in(cssrs1_ip_dead_var,cssrs2_ip_suicide_var,cssrs6_ip_screen_var)
 	and cnvtlower(ce.result_val) = '*yes'
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
			where ce1.encntr_id = ce.encntr_id and ce1.event_cd = ce.event_cd
			and ce1.result_status_cd in(23,25,34,35)
			group by ce1.encntr_id)
 
order by e.loc_facility_cd, e.loc_nurse_unit_cd, e.encntr_id
 
Head report
 	;cnt = 0
	call alterlist(suici->plist, 100)
 
Head e.encntr_id
 	cnt += 1
 	suici->rec_cnt = cnt
	call alterlist(suici->plist, cnt)
 
Detail
	suici->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	suici->plist[cnt].nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd)
	suici->plist[cnt].personid = e.person_id
	suici->plist[cnt].encounterid = e.encntr_id
	suici->plist[cnt].room = uar_get_code_display(e.loc_room_cd)
	suici->plist[cnt].bed = uar_get_code_display(e.loc_bed_cd)
	suici->plist[cnt].admit_dt = format(e.reg_dt_tm, 'mm/dd/yyyy hh:mm;;q')
	suici->plist[cnt].pat_type = pat_type
	suici->plist[cnt].ssrss_screen_date = build2('Yes (',event_dt, ')' )
	case(ce.event_cd)
		of cssrs1_ip_dead_var:
			suici->plist[cnt].cssrs1_response = ce.result_val
		of cssrs2_ip_suicide_var:
			suici->plist[cnt].cssrs2_response = ce.result_val
		of cssrs6_ip_screen_var:
			suici->plist[cnt].cssrs6_response = ce.result_val
	endcase
	
Foot e.encntr_id
	call alterlist(suici->plist, cnt)
 
with nocounter
 
;-----------------------------------------------------------------------------------------------------------------
;Get Order qualification
select into 'nl:'
 
o.encntr_id, o.order_id, o.ordered_as_mnemonic
, ord_dt = format(o.orig_order_dt_tm, 'mm/dd/yyyy hh:mm;;q')
 
from
	encounter e
	,orders o
 
plan e where e.loc_facility_cd = $facility
	and e.active_ind = 1
	and e.encntr_type_cd in(309308.00, 309312.00, 19962820.00, 309310.00, 2555137051.00)
			;Inpatient, Observation, Outpat in a bed, Emergency, Behavioral Health
 
join o where o.person_id = e.person_id
	and o.encntr_id = e.encntr_id
	and o.template_order_id = 0.00
	and (o.orig_order_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
		or o.order_status_cd = 2550) ;ordered - active orders
	and o.active_ind = 1
	and o.catalog_cd = suicide_precaution_var
 
order by e.person_id, e.encntr_id, o.order_id
 
;Append rows into the Suici record structure if it not in their already OR update order info if encounter exists.
Head e.encntr_id
	loc = 0
 	edx = 0
 	edx = locateval(loc,1,size(suici->plist,5), e.encntr_id, suici->plist[loc].encounterid)
Detail
	if(edx = 0) ;add new row
		cnt += 1
		suici->rec_cnt = cnt
		call alterlist(suici->plist, cnt)
 
		suici->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
		suici->plist[cnt].nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd)
		suici->plist[cnt].personid = e.person_id
		suici->plist[cnt].encounterid = e.encntr_id
		suici->plist[cnt].room = uar_get_code_display(e.loc_room_cd)
		suici->plist[cnt].bed = uar_get_code_display(e.loc_bed_cd)
		suici->plist[cnt].admit_dt = format(e.reg_dt_tm, 'mm/dd/yyyy hh:mm;;q')
		suici->plist[cnt].pat_type = uar_get_code_display(e.encntr_type_cd)
		suici->plist[cnt].phys_placed_preca_order = build2('Yes (', ord_dt, ')' )
	else
	 	suici->plist[edx].phys_placed_preca_order = build2('Yes (', ord_dt, ')' )
	endif
 
Foot e.encntr_id
	if(edx = 0)
 		call alterlist(suici->plist, cnt)
 	endif
 
with nocounter
 
;------------------------------------------------------------------------------------------------------------------
;Get Demographic
select into 'nl:'
 
from
	(dummyt d with seq = value(size(suici->plist, 5)))
	,encntr_alias ea
	,person p
 
plan d
 
join ea where ea.encntr_id = suici->plist[d.seq].encounterid
	and ea.encntr_alias_type_cd = 1077 ;FIN
	and ea.active_ind = 1
 
join p where p.person_id = suici->plist[d.seq].personid
	and p.active_ind = 1
 
order by p.person_id, ea.encntr_id
 
 
Head ea.encntr_id
      cnt = 0
	idx = locateval(cnt,1,size(suici->plist,5), ea.encntr_id, suici->plist[cnt].encounterid)
Detail
	suici->plist[idx].fin = ea.alias
	suici->plist[idx].patient_name = p.name_full_formatted
 
with nocounter
 
;------------------------------------------------------------------------------------------------------------------
;Get Safety docs and reassessment
Select into 'nl:'
 
ce.encntr_id, ce.result_val, event = uar_get_code_display(ce.event_cd)
,pat_name =  suici->plist[d.seq].patient_name
 
from
	(dummyt d with seq = value(size(suici->plist, 5)))
	,clinical_event ce
 
plan d
 
join ce where ce.person_id = suici->plist[d.seq].personid
	and ce.encntr_id = suici->plist[d.seq].encounterid
	and ce.event_cd in(suicide_re_assess_var,safety_chklist_var, room_search_var)
      and ce.view_level = 1
      and ce.publish_flag = 1 ;active
      and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
      and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth (Verified), Modified
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
			where ce1.encntr_id = ce.encntr_id and ce1.event_cd = ce.event_cd
			and ce1.result_status_cd in(23,25,34,35)
			group by ce1.encntr_id)
 
order by ce.person_id, ce.encntr_id, ce.event_cd
 
Head ce.encntr_id
      cnt = 0
	idx = locateval(cnt,1,size(suici->plist,5), ce.encntr_id, suici->plist[cnt].encounterid)
 
Detail
	case(ce.event_cd)
		of suicide_re_assess_var:
			suici->plist[idx].suicide_re_assess = ce.result_val
			suici->plist[idx].suicide_re_assess_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;q')
		of safety_chklist_var:
			suici->plist[idx].safety_checklist = ce.result_val
			suici->plist[idx].safety_checklist_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;q')
		of room_search_var:
			suici->plist[idx].room_search = ce.result_val
			suici->plist[idx].room_search_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;q')
	endcase
 
Foot ce.encntr_id
 
	suici->plist[idx].safety_checklist_completed =
		if(suici->plist[idx].safety_checklist != '') 'Yes'
		elseif(suici->plist[idx].room_search != '') 'Yes'
		endif
 
	suici->plist[idx].precaution_charted_dt =
		if(suici->plist[idx].safety_checklist_dt != '') suici->plist[idx].safety_checklist_dt
		elseif(suici->plist[idx].room_search_dt != '') suici->plist[idx].room_search_dt
		endif
 
	suici->plist[idx].precaution_charted = build2(suici->plist[idx].safety_checklist, ' ', suici->plist[idx].room_search)
 
with nocounter
 
;call echorecord(suici)
 
;------------------------------------------------------------------------------------------------------------------
 
SELECT DISTINCT INTO VALUE($OUTDEV)
 
	FACILITY = SUBSTRING(1, 30, SUICI->plist[D1.SEQ].facility)
	, NURSE_UNIT = SUBSTRING(1, 30, SUICI->plist[D1.SEQ].nurse_unit)
	, ROOM = SUBSTRING(1, 30, SUICI->plist[D1.SEQ].room)
	, BED = SUBSTRING(1, 30, SUICI->plist[D1.SEQ].bed)
	, FIN = SUBSTRING(1, 30, SUICI->plist[D1.SEQ].fin)
	, PATIENT_NAME = SUBSTRING(1, 50, SUICI->plist[D1.SEQ].patient_name)
	, PATIENT_TYPE = SUBSTRING(1, 30, SUICI->plist[D1.SEQ].pat_type)
	, ADMIT_DATE = SUBSTRING(1, 30, SUICI->plist[D1.SEQ].admit_dt)
	, SSRSS_SCREEN_DATE = SUBSTRING(1, 30, SUICI->plist[D1.SEQ].ssrss_screen_date)
	;, SAFETY_CHECKLIST_COMPLETED = SUBSTRING(1, 30, SUICI->plist[D1.SEQ].safety_checklist_completed)
	;, SUICIDE_PRECAUTIONS_CHARTED = SUBSTRING(1, 500, SUICI->plist[D1.SEQ].precaution_charted)
	;, SUICIDE_PRECAUTIONS_CHARTED_DATE = SUBSTRING(1, 30, SUICI->plist[D1.SEQ].precaution_charted_dt)
	, PRECAUTION_ORDER_PLACED = SUBSTRING(1, 30, SUICI->plist[D1.SEQ].phys_placed_preca_order)
	, Wish_to_be_dead = SUBSTRING(1, 50, SUICI->plist[D1.SEQ].cssrs1_response)
	, Suicidal_thoughts = SUBSTRING(1, 50, SUICI->plist[D1.SEQ].cssrs2_response)
	, Suicide_behavior = SUBSTRING(1, 50, SUICI->plist[D1.SEQ].cssrs6_response)
	, SUICIDE_RE_ASSESSMENT = SUBSTRING(1, 100, SUICI->plist[D1.SEQ].suicide_re_assess)
	, RE_ASSESSMENT_DATE = SUBSTRING(1, 30, SUICI->plist[D1.SEQ].suicide_re_assess_dt)
 
FROM
	(DUMMYT   D1  WITH SEQ = SIZE(SUICI->plist, 5))
 
PLAN D1
 
ORDER BY FACILITY, NURSE_UNIT, FIN, PATIENT_NAME
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
end
go
 
 
 
