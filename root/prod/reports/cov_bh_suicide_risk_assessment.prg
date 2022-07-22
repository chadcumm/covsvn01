 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Paramasivam
	Date Written:		Apr'2020
	Solution:			Behavioral Health
	Source file name:  	cov_bh_suicide_risk_assment.prg
	Object name:		cov_bh_suicide_risk_assment
	CR#:				7375
	Program purpose:		BH - Columbia Suicide Severity Rating Scale Screen or CSSRS
	Executing from:		CCL/DA2
  	Special Notes:		used for Joint Commission Review; Autoset prompt
 
*****************************************************************************************************************
*  GENERATED MODIFICATION CONTROL LOG
*
*  Revision #   Mod Date    Developer             Comment
*  -----------  ----------  -----------  -------------------------------------------------------------------------
*******************************************************************************************************************/
 
drop program cov_bh_suicide_risk_assessment:DBA go
create program cov_bh_suicide_risk_assessment:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Select Facility" = 0
 
with OUTDEV, start_datetime, end_datetime, facility
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare initcap() = c100
declare cnt = i4 with noconstant(0)
declare num = i4 with noconstant(0)

declare q1_p_dead_child_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "CSSRS Past Month Wish to be Dead Child")),protect
declare q2_p_suicide_child_var = f8 with constant(uar_get_code_by("DISPLAY", 72, "CSSRS Past Month Suicidal Thoughts Child")),protect
declare q6_cs_screen_child_var = f8 with constant(uar_get_code_by("DISPLAY", 72, "CSSRS SV Document Suicide Behavior Child")),protect

declare q1_past_dead_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, "Past Month Wish to be Dead")),protect
declare q2_past_suicide_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Past Month Suicidal Thoughts")),protect
declare q6_cssrs_screen_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Columbia Screen Suicide Behavior")),protect
declare suicide_re_assess_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, "Suicide Re-assessment")),protect
declare safety_chklist_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "Safety Checklist")),protect
declare room_search_var        = f8 with constant(uar_get_code_by("DISPLAY", 72, "Room Search")),protect
declare assessed_Risk_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "Assessed Risk")),protect
declare suicide_ipoc_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, "BH Self-Harm/Suicide IPOC")),protect
declare suicide_precaution_var = f8 with constant(uar_get_code_by("DISPLAY", 200,"Precaution Suicide")),protect
declare bh_suicide_preca_var   = f8 with constant(uar_get_code_by("DISPLAY", 200,"BH Precaution Suicide")),protect
 
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
		2 age = vc
		2 pat_type = vc
		2 admit_dt = dq8
		2 disch_dt = vc
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
		2 cssrs1_child_response = vc
		2 cssrs2_child_response = vc
		2 cssrs6_child_response = vc
		2 suicide_re_assess = vc
		2 suicide_re_assess_dt = vc
		2 phys_placed_preca_order = vc
		2 assessed_risk = vc
		2 suicide_ipoc = vc
)
 
;-----------------------------------------------------------------------------------------------------------------------------
;Basic qualification - by encounter location
select into 'nl:'
 
;, beg = elh.beg_effective_dt_tm  "@SHORTDATETIME", ed = elh.end_effective_dt_tm  "@SHORTDATETIME"
;, e.person_id, e.encntr_id, pat_type = uar_get_code_display(e.encntr_type_cd), e.encntr_type_cd
 
from	encounter e
	, encntr_loc_hist elh
 
plan e where e.loc_facility_cd = $facility
	and e.active_ind = 1
 	and e.encntr_type_cd not in(2555137107.00, 2555137373.00,309309.00);Cancel Upon Review,Pre Admission, Outpatient
 
join elh where elh.encntr_id = e.encntr_id
	and (elh.beg_effective_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	or elh.end_effective_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime))
	and elh.active_ind = 1
 
order by e.encntr_id
 
Head report
	tmp = 0
Head e.encntr_id
 	cnt += 1
 	suici->rec_cnt = cnt
 	call alterlist(suici->plist, cnt)
	suici->plist[cnt].encounterid = e.encntr_id
 
with nocounter
 
;-----------------------------------------------------------------------------------------------------------------------------
;Basic qualification - by admit or discharge
select into 'nl:'
 
from	encounter e
 
plan e where e.loc_facility_cd = $facility
	and (e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	or  e.disch_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime))
	and e.active_ind = 1
 	and e.encntr_type_cd not in(2555137107.00, 2555137373.00,309309.00);Cancel Upon Review,Pre Admission, Outpatient
 
order by  e.encntr_id
 
Head e.encntr_id
	loc = 0
 	edx = 0
 	edx = locateval(loc,1,size(suici->plist,5), e.encntr_id, suici->plist[loc].encounterid)
	if(edx = 0) ;add new row
		cnt += 1
		suici->rec_cnt = cnt
		call alterlist(suici->plist, cnt)
		suici->plist[cnt].encounterid = e.encntr_id
	endif
with nocounter
 
;-----------------------------------------------------------------------------------------------------------------------------
;Basic qualification - by charted date
select into 'nl:'
 
from 	encounter e
	,clinical_event ce
 
plan e where e.loc_facility_cd = $facility
	and e.active_ind = 1
 	and e.encntr_type_cd not in(2555137107.00, 2555137373.00,309309.00);Cancel Upon Review,Pre Admission, Outpatient
 
join ce where ce.encntr_id = e.encntr_id
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and (ce.event_end_dt_tm <= e.disch_dt_tm or e.disch_dt_tm is null)
 
order by ce.encntr_id
 
Head ce.encntr_id
	loc = 0
 	edx = 0
 	edx = locateval(loc,1,size(suici->plist,5), ce.encntr_id, suici->plist[loc].encounterid)
	if(edx = 0) ;add new row
		cnt += 1
		suici->rec_cnt = cnt
		call alterlist(suici->plist, cnt)
		suici->plist[cnt].encounterid = ce.encntr_id
	endif
with nocounter
 
;------------------------------------------------------------------------------------------------------------
;Location & pat details
select into 'nl:'
 
facility = uar_get_code_display(e.loc_facility_cd)
, nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd)
, e.person_id, e.encntr_id, pat_type = uar_get_code_display(e.encntr_type_cd)
 
from encounter e, person p
 
plan e where expand(num, 1, suici->rec_cnt, e.encntr_id, suici->plist[num].encounterid)

join p where p.person_id = e.person_id
	and p.active_ind = 1
 
order by e.encntr_id
 
Head e.encntr_id
	loc = 0
 	edx = 0
 	edx = locateval(loc,1,size(suici->plist,5), e.encntr_id, suici->plist[loc].encounterid)
	if(edx != 0)
		suici->plist[edx].facility = uar_get_code_display(e.loc_facility_cd)
		suici->plist[edx].nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd)
		suici->plist[edx].personid = e.person_id
		suici->plist[edx].room = uar_get_code_display(e.loc_room_cd)
		suici->plist[edx].bed = uar_get_code_display(e.loc_bed_cd)
		suici->plist[edx].admit_dt = e.reg_dt_tm;format(e.reg_dt_tm, 'mm/dd/yyyy hh:mm;;q')
		suici->plist[edx].disch_dt = format(e.disch_dt_tm, 'mm/dd/yyyy hh:mm;;q')
		suici->plist[edx].pat_type = pat_type
		suici->plist[edx].age = substring(1,3,cnvtage(p.birth_dt_tm, e.reg_dt_tm, 0))
	endif
 
with nocounter, expand = 1
 
;------------------------------------------------------------------------------------------------------------------------
;Assessed Risk clinical events
select into 'nl:'
ce.encntr_id, event = uar_get_code_display(ce.event_cd), ce.event_cd, ce.result_val
, event_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, rank_ord = rank() over(partition by ce.encntr_id order by ce.encntr_id, ce.event_id asc)
 
from 	clinical_event ce
 
plan ce where expand(num ,1 ,suici->rec_cnt, ce.encntr_id ,suici->plist[num].encounterid)
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
      and ce.view_level = 1
      and ce.publish_flag = 1 ;active
      and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
      and ce.result_status_cd in (23.00, 34.00, 25.00, 35.00)
 	and ce.event_cd = 31580383.00 ;assessed_risk_var
 
order by ce.encntr_id, rank_ord
 
Head ce.encntr_id
	ass_risk = fillstring(500," ")
	loc = 0
 	edx = 0
 	edx = locateval(loc,1,size(suici->plist,5), ce.encntr_id, suici->plist[loc].encounterid)
Detail
	ass_risk = build2(trim(ass_risk),'[',trim(ce.result_val),'-'
   		, format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;q') ,']',',')
 
	/*Last two charted values(LCV)
	if(rank_ord = 1.00 or rank_ord = 2.00)
	   ass_risk = build2(trim(ass_risk),'[',trim(ce.result_val),'-'
	   		, format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;q') ,']',',')
	endif*/
 
Foot ce.encntr_id
	suici->plist[edx].assessed_risk = replace(trim(ass_risk),",","",2)
 
with nocounter ,expand = 1
 
;----------------------------------------------------------------------------------------------------------
;CSSRS Clinical events from Power Form
 
select into 'nl:'
ce.encntr_id, event = uar_get_code_display(ce.event_cd), ce.event_cd, ce.result_val
, event_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
 
from	clinical_event ce
 
plan ce where expand(num ,1 ,suici->rec_cnt, ce.encntr_id ,suici->plist[num].encounterid)
      and ce.view_level = 1
      and ce.publish_flag = 1 ;active
      and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
      and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth (Verified), Modified
 	and ce.event_cd in(q1_past_dead_var, q2_past_suicide_var, q6_cssrs_screen_var,
 					q1_p_dead_child_var,q2_p_suicide_child_var,q6_cs_screen_child_var)
 	and cnvtlower(ce.result_val) = '*yes'
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
			where ce1.encntr_id = ce.encntr_id and ce1.event_cd = ce.event_cd
			and ce1.result_status_cd in(23,25,34,35)
			group by ce1.encntr_id)
 
order by ce.encntr_id
 
Head ce.encntr_id
	loc = 0
 	edx = 0
 	edx = locateval(loc,1,size(suici->plist,5), ce.encntr_id, suici->plist[loc].encounterid)
Detail
	suici->plist[edx].ssrss_screen_date = build2('Yes (',event_dt, ')' )
	case(ce.event_cd)
		of q1_past_dead_var:
			suici->plist[edx].cssrs1_response = ce.result_val
		of q2_past_suicide_var:
			suici->plist[edx].cssrs2_response = ce.result_val
		of q6_cssrs_screen_var:
			suici->plist[edx].cssrs6_response = ce.result_val
		of q1_p_dead_child_var:
			suici->plist[edx].cssrs1_child_response = ce.result_val
		of q2_p_suicide_child_var:
			suici->plist[edx].cssrs2_child_response = ce.result_val
		of q6_cs_screen_child_var:	
			suici->plist[edx].cssrs6_child_response = ce.result_val			
	endcase
 
with nocounter, expand = 1
 
;-----------------------------------------------------------------------------------------------------------------
;Get Order qualification
select into 'nl:'
 
o.encntr_id, o.order_id, o.ordered_as_mnemonic
, ord_dt = format(o.orig_order_dt_tm, 'mm/dd/yyyy hh:mm;;q')
 
from	orders o
 
plan o where expand(num ,1 ,suici->rec_cnt, o.encntr_id ,suici->plist[num].encounterid)
	and o.active_ind = 1
	and o.template_order_id = 0.00
	and o.catalog_cd in(suicide_precaution_var, bh_suicide_preca_var)
 
order by o.encntr_id, o.catalog_cd, o.orig_order_dt_tm
 
Head o.encntr_id
	preca_order = fillstring(500," ")
	loc = 0
 	edx = 0
 	edx = locateval(loc,1,size(suici->plist,5), o.encntr_id, suici->plist[loc].encounterid)
Detail
	preca_order = build2(trim(preca_order),'[','Yes (', ord_dt, ')' ,']',',')
 
Foot o.encntr_id
 	suici->plist[edx].phys_placed_preca_order = replace(trim(preca_order),",","",2)
 
with nocounter, expand = 1
 
;------------------------------------------------------------------------------------------------------------------
;Get Demographic
select into 'nl:'
 
from encounter e
	,encntr_alias ea
	,person p
 
plan e where expand(num ,1 ,suici->rec_cnt, e.encntr_id ,suici->plist[num].encounterid)
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077 ;FIN
	and ea.active_ind = 1
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
order by p.person_id, ea.encntr_id
 
Head e.encntr_id
      cnt = 0
	idx = locateval(cnt,1,size(suici->plist,5), e.encntr_id, suici->plist[cnt].encounterid)
Detail
	suici->plist[idx].fin = ea.alias
	suici->plist[idx].patient_name = p.name_full_formatted
 
with nocounter, expand = 1
 
;------------------------------------------------------------------------------------------------------------------
;Get Safety docs and reassessment
Select into 'nl:'
 
ce.encntr_id, ce.result_val, event = uar_get_code_display(ce.event_cd)
 
from	clinical_event ce
 
plan ce where expand(num ,1 ,suici->rec_cnt, ce.encntr_id ,suici->plist[num].encounterid)
	and ce.event_cd in(suicide_re_assess_var,safety_chklist_var, room_search_var)
      and ce.view_level = 1
      and ce.publish_flag = 1 ;active
      and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
      and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
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
 
with nocounter, expand = 1
 
;------------------------------------------------------------------------------------------------------------------
;Get Power Plan Info
 
Select into 'nl:'
 pw_stat = uar_get_code_display(pw.pw_status_cd), pw.status_dt_tm "@SHORTDATETIME"
,action_dt = pa.action_dt_tm "@SHORTDATETIME", pa_stat = uar_get_code_display(pa.pw_status_cd)
,action_type = uar_get_code_display(pa.action_type_cd)
 
from pathway pw, pathway_action pa
 
plan pw where expand(num ,1 ,suici->rec_cnt, pw.encntr_id ,suici->plist[num].encounterid)
	and pw.active_ind = 1
	and pw.pw_group_desc = 'BH Self-Harm/Suicide Risk IPOC'
	and pw.pathway_type_cd = 20216079.00 ;Interdisciplinary - IPOC (cdf)
 
join pa where pa.pathway_id = pw.pathway_id
	and pa.action_type_cd = 10752.00 ;Order
	and pa.pw_status_cd = 674356.00 ;Initiated
 
order by pw.encntr_id, pa.action_dt_tm
 
Head pw.encntr_id
	ipoc_stat = fillstring(500," ")
	loc = 0
 	idx = 0
	idx = locateval(loc,1,size(suici->plist,5), pw.encntr_id, suici->plist[loc].encounterid)
 
Head pa.action_dt_tm
	if(pa.action_dt_tm <= cnvtdatetime($end_datetime))
		ipoc_stat = build2(trim(ipoc_stat),'[',trim(uar_get_code_display(pa.pw_status_cd)),'-'
	   		, format(pa.action_dt_tm, 'mm/dd/yyyy hh:mm;;q') ,']',',')
	endif
Foot pw.encntr_id
	suici->plist[idx].suicide_ipoc = replace(trim(ipoc_stat),",","",2)
 
with nocounter, expand = 1
 
call echorecord(suici)
 
;------------------------------------------------------------------------------------------------------------------
 
select distinct into $outdev
 
	facility = substring(1, 30, suici->plist[d1.seq].facility)
	, nurse_unit = substring(1, 30, suici->plist[d1.seq].nurse_unit)
	, room = substring(1, 30, suici->plist[d1.seq].room)
	, bed = substring(1, 30, suici->plist[d1.seq].bed)
	, fin = substring(1, 30, suici->plist[d1.seq].fin)
	, patient_name = substring(1, 50, suici->plist[d1.seq].patient_name)
	, age = trim(substring(1, 3, suici->plist[d1.seq].age))
	, patient_type = substring(1, 30, suici->plist[d1.seq].pat_type)
	, admit_date = format(suici->plist[d1.seq].admit_dt, 'mm/dd/yyyy hh:mm;;q')
	, disch_date = substring(1, 30, suici->plist[d1.seq].disch_dt)
	, assessed_risk = substring(1, 500, suici->plist[d1.seq].assessed_risk)
	, self_harm_IPOC  = substring(1, 500, suici->plist[d1.seq].suicide_ipoc)
	, ssrss_screen_date = substring(1, 30, suici->plist[d1.seq].ssrss_screen_date)
	, precaution_order_placed = trim(substring(1, 500, suici->plist[d1.seq].phys_placed_preca_order))
	, cssrs1_response = substring(1, 50, suici->plist[d1.seq].cssrs1_response)
	, cssrs2_response = substring(1, 50, suici->plist[d1.seq].cssrs2_response)
	, cssrs6_response = substring(1, 50, suici->plist[d1.seq].cssrs6_response)
 	, child_cssrs1_response = substring(1, 50, suici->plist[d1.seq].cssrs1_child_response)
	, child_cssrs2_response = substring(1, 50, suici->plist[d1.seq].cssrs2_child_response)
	, child_cssrs6_response = substring(1, 50, suici->plist[d1.seq].cssrs6_child_response)

from
	(dummyt   d1  with seq = size(suici->plist, 5))
 
plan d1
 
order by facility, nurse_unit, admit_date, patient_name
 
with nocounter, separator=" ", format
end go
 
 
 
 
