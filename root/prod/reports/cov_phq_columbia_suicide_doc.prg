 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Paramasivam
	Date Written:		Dec'2019
	Solution:			Quality/ED
	Source file name:  	cov_phq_columbia_suicide_doc.prg
	Object name:		cov_phq_columbia_suicide_doc.prg
	CR#:				6779
	Program purpose:		Quality - Columbia Suicide Severity Rating Scale Screen or CSSRS
	Executing from:		CCL/DA2
  	Special Notes:		used for ED & BH patients optimization
 
******************************************************************************
*  GENERATED MODIFICATION CONTROL LOG
*
*  Revision #   Mod Date    Developer             Comment
*  -----------  ----------  -----------  ----------------------------
   CR# 8372     08-14-20    Geetha P     New list of DTA's for ED
 
************************************************************************************************************************************/
 
drop program cov_phq_columbia_suicide_doc:DBA go
create program cov_phq_columbia_suicide_doc:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Start Discharge Date/Time" = "SYSDATE"
	, "End Discharge Date/Time" = "SYSDATE"
	, "Select Facility" = 0
 
with OUTDEV, start_datetime, end_datetime, facility_list
 
 
/***************************************************************************************************************
; DVDev DECLARED VARIABLES
****************************************************************************************************************/
 
declare initcap() = c100
declare cnt = i4 with noconstant(0)
 
declare doc_suicide_scrn_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Document Suicide Screening")),protect
declare wish_tobe_dead_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "IP CSSRS Wish to be Dead")),protect
declare suicidal_thoughts_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, "IP CSSRS Suicidal Thoughts")),protect
declare idea_w_method_var 	 = f8 with constant(uar_get_code_by("DISPLAY", 72, "IP CSSRS Idea w-Method No Intent")),protect
declare idea_w_intent_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "IP CSSRS Idea w-Intent No Plan")),protect
declare suicide_intent_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "IP CSSRS Suicide Intent w-Plan")),protect
declare screen_suici_beha_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, "IP CSSRS Screen Suicide Behavior")),protect
declare suici_scrn_time_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "IP CSSRS Suicide Screen Timeframe")),protect
declare cssrs_yes_var          = f8 with constant(uar_get_code_by("DISPLAY", 72, "IP CSSRS Yes")),protect
 
declare suicide_re_assess_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, "Suicide Re-assessment")),protect
declare safety_chklist_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Safety Checklist")),protect
declare room_search_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Room Search")),protect
declare suicide_precaution_var = f8 with constant(uar_get_code_by("DISPLAY", 200, "Precaution Suicide")),protect
 
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
		2 dish_dt = vc
		2 ssrss_screen_date = vc
		2 safety_checklist = vc
		2 safety_checklist_dt = vc
		2 room_search = vc
		2 room_search_dt = vc
		2 safety_checklist_completed = vc
		2 precaution_charted = vc
		2 precaution_charted_dt = vc
		2 doc_suicide_scrn = vc
		2 wish_tobe_dead = vc
		2 suicidal_thoughts = vc
		2 idea_w_method = vc
		2 idea_w_intent = vc
		2 suicide_intent = vc
		2 screen_suici_beha = vc
		2 suici_scrn_time = vc
		2 cssrs_yes = vc
		2 suicide_re_assess = vc
		2 suicide_re_assess_dt = vc
		2 phys_placed_preca_order = vc
		2 discharge_disposition = vc
		2 trackingboard_disposition = vc
)
 
 
;-----------------------------------------------------------------------------------------------------------------------------
;Clinical events from Power Form
 
select into $outdev
 
Facility = uar_get_code_display(e.loc_facility_cd)
, nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd)
, e.person_id, e.encntr_id, pat_type = uar_get_code_display(e.encntr_type_cd)
, event = uar_get_code_display(ce.event_cd), ce.event_cd
, ce.result_val
, event_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
 
from
	encounter e
	,clinical_event ce
 
plan e where e.loc_facility_cd = $facility_list
	and e.disch_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.encntr_type_cd in(309310.00, 2555137277.00);Emergency, Quick ED Registration  
	and e.active_ind = 1
 
join ce where ce.person_id = e.person_id
	and ce.encntr_id = e.encntr_id
      and ce.view_level = 1
      and ce.publish_flag = 1 ;active
      and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
      and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth (Verified), Modified
 	and ce.event_cd in(doc_suicide_scrn_var,wish_tobe_dead_var,suicidal_thoughts_var,idea_w_method_var,
		idea_w_intent_var,suicide_intent_var,screen_suici_beha_var,suici_scrn_time_var,cssrs_yes_var)
 	;and cnvtlower(ce.result_val) = '*yes'
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
			where ce1.encntr_id = ce.encntr_id and ce1.event_cd = ce.event_cd
			and ce1.result_status_cd in(23,25,34,35)
			group by ce1.encntr_id, ce1.event_cd)
 
order by e.loc_facility_cd, e.loc_nurse_unit_cd, e.encntr_id
 
;with nocounter, separator=" ", format
;go to exitscript
 
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
	suici->plist[cnt].dish_dt = format(e.disch_dt_tm, 'mm/dd/yyyy hh:mm;;q')
	suici->plist[cnt].discharge_disposition = uar_get_code_display(e.disch_disposition_cd)
	suici->plist[cnt].pat_type = pat_type
	suici->plist[cnt].ssrss_screen_date = build2('Yes (',event_dt, ')' )
	case(ce.event_cd)
		of doc_suicide_scrn_var:
			suici->plist[cnt].doc_suicide_scrn = ce.result_val
		of wish_tobe_dead_var:
			suici->plist[cnt].wish_tobe_dead = ce.result_val
		of suicidal_thoughts_var:
			suici->plist[cnt].suicidal_thoughts = ce.result_val
		of idea_w_method_var:
			suici->plist[cnt].idea_w_method = ce.result_val
		of idea_w_intent_var:
			suici->plist[cnt].idea_w_intent = ce.result_val
		of suicide_intent_var:
			suici->plist[cnt].suicide_intent = ce.result_val
		of screen_suici_beha_var:
			suici->plist[cnt].screen_suici_beha = ce.result_val
		of suici_scrn_time_var:
			suici->plist[cnt].suici_scrn_time = ce.result_val
		of cssrs_yes_var:
			suici->plist[cnt].cssrs_yes = ce.result_val
	endcase
Foot e.encntr_id
	call alterlist(suici->plist, cnt)
 
with nocounter
 
;-----------------------------------------------------------------------------------------------------------------
/*
;MAY NOT NEED FOR THIS REPORT - GEETHA - 12/5/19
;Get Order qualification
select into 'nl:'
 
o.encntr_id, o.order_id, o.ordered_as_mnemonic
, ord_dt = format(o.orig_order_dt_tm, 'mm/dd/yyyy hh:mm;;q')
 
from
	encounter e
	,orders o
 
plan e where e.loc_facility_cd = $facility_list
	and e.disch_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.encntr_type_cd = 309310.00 ;Emergency
	and e.active_ind = 1
 
join o where o.person_id = e.person_id
	and o.encntr_id = e.encntr_id
	and o.template_order_id = 0.00 ;Prevent child orders
	;and (o.orig_order_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	;	or o.order_status_cd = 2550) ;ordered - active orders
	and o.active_ind = 1
	and o.catalog_cd = suicide_precaution_var
 
order by e.person_id, e.encntr_id, o.order_id
 
;append rows into the Suici record structure if it not in their already OR update order info if encounter exists.
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
		suici->plist[cnt].dish_dt = format(e.disch_dt_tm, 'mm/dd/yyyy hh:mm;;q')
		suici->plist[cnt].discharge_disposition = uar_get_code_display(e.disch_disposition_cd)
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
*/
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
;-----------------------------------------------------------------------------------------------------------------
;Get Tracking board disposition
select into 'nl:'
from
	(dummyt d with seq = value(size(suici->plist, 5)))
	, tracking_item ti
	, tracking_checkin tc
 
plan d
 
join ti where ti.encntr_id = suici->plist[d.seq].encounterid
	and ti.encntr_id != 0.00
	and ti.active_ind = 1
 
join tc where tc.tracking_id = ti.tracking_id
	and tc.active_ind = 1
 
order by ti.encntr_id
 
Head ti.encntr_id
      cnt = 0
      idx = 0
	idx = locateval(cnt,1,size(suici->plist,5), ti.encntr_id, suici->plist[cnt].encounterid)
	if(idx != 0)
 		 suici->plist[idx].trackingboard_disposition = uar_get_code_display(tc.checkout_disposition_cd)
 	endif
 
with nocounter
 
;call echorecord(suici)
 
;------------------------------------------------------------------------------------------------------------------
 
select distinct into value($outdev)
 
	facility = substring(1, 30, suici->plist[d1.seq].facility)
	, fin = trim(substring(1, 30, suici->plist[d1.seq].fin))
	, patient_name = trim(substring(1, 50, suici->plist[d1.seq].patient_name))
	, admit_date = trim(substring(1, 30, suici->plist[d1.seq].admit_dt))
	, pat_type = trim(substring(1, 50, suici->plist[d1.seq].pat_type))
	, discharge_date = trim(substring(1, 30, suici->plist[d1.seq].dish_dt))
	, ssrss_screen_date = trim(substring(1, 30, suici->plist[d1.seq].ssrss_screen_date))
	, document_sicide_screening = trim(substring(1, 100, suici->plist[d1.seq].doc_suicide_scrn))
	, wish_to_be_dead = trim(substring(1, 100, suici->plist[d1.seq].wish_tobe_dead))
	, suicidal_thoughts = trim(substring(1, 100, suici->plist[d1.seq].suicidal_thoughts))
	, idea_w_method_no_intent = trim(substring(1, 100, suici->plist[d1.seq].idea_w_method))
	, idea_w_intent_no_plan = trim(substring(1, 100, suici->plist[d1.seq].idea_w_intent))
	, suicide_intent_with_plan = trim(substring(1, 100, suici->plist[d1.seq].suicide_intent))
	, screen_suicide_behavior = trim(substring(1, 100, suici->plist[d1.seq].screen_suici_beha))
	, suicide_screen_timeframe = trim(substring(1, 100, suici->plist[d1.seq].suici_scrn_time))
	, cssrs_yes = trim(substring(1, 100, suici->plist[d1.seq].cssrs_yes))
	, discharge_disposition = trim(substring(1, 200, suici->plist[d1.seq].discharge_disposition))
	, tracking_board_disposition = trim(substring(1, 200, suici->plist[d1.seq].trackingboard_disposition))
 
	;, precaution_order_placed = substring(1, 30, suici->plist[d1.seq].phys_placed_preca_order)
	;, suicide_re_assessment = substring(1, 100, suici->plist[d1.seq].suicide_re_assess)
	;, re_assessment_date = substring(1, 30, suici->plist[d1.seq].suicide_re_assess_dt)
 
from
	(dummyt   d1  with seq = size(suici->plist, 5))
 
plan d1
 
order by facility, discharge_date, patient_name, fin
 
with nocounter, separator=" ", format
 
 
#exitscript
 
end
go
 
 
 
