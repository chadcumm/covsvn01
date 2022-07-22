/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Paramasivam
	Date Written:		May'2020
	Solution:			Quality/Ambulatory
	Source file name:  	cov_amb_rpt_signed_notes.prg
	Object name:		cov_amb_rpt_signed_notes
	CR#:				As per Lori's request
	Program purpose:		Pull all signed notes into the report
	Executing from:		CCL/DA2
  	Special Notes:
 
*****************************************************************************************************************
*  GENERATED MODIFICATION CONTROL LOG
*
*  Revision #   Mod Date    Developer             Comment
*  -----------  ----------  -----------  -------------------------------------------------------------------------

   CR# 10945    08/09/21    Geetha   Include Tele-ICU cold fed notes
   							Chad	 Added facility and output as CSV
*******************************************************************************************************************/
 
drop program cmc_amb_rpt_signed_notes:DBA go
create program cmc_amb_rpt_signed_notes:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Position" = 0
	, "Provider" = 0
 
with OUTDEV, start_datetime, end_datetime, prsnl_position, provider
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare op_provider_var  = vc with noconstant(' ')
declare num = i4 with noconstant(0)
declare cnt = i4 with noconstant(0)

declare anesthesia_var   = f8 with constant(uar_get_code_by("DISPLAY", 29520, "Anesthesia")),protect
declare cardiology_var   = f8 with constant(uar_get_code_by("DISPLAY", 29520, "Cardiology")),protect
declare dyn_doc_var      = f8 with constant(uar_get_code_by("DISPLAY", 29520, "Dynamic Documentation")),protect
declare msg_center_var   = f8 with constant(uar_get_code_by("DISPLAY", 29520, "Message Center")),protect
declare powernote_var    = f8 with constant(uar_get_code_by("DISPLAY", 29520, "PowerNote")),protect
declare ed_powernote_var = f8 with constant(uar_get_code_by("DISPLAY", 29520, "PowerNote ED")),protect
declare esi_var          = f8 with constant(uar_get_code_by("DISPLAY", 29520, "ESI")),protect ;Tele ICU/Electronically signed
 
 
; Define operator for $Provider
if (substring(1, 1, reflect(parameter(parameter2($provider), 0))) = "L") ; multiple values selected
    set op_provider_var = "IN"
elseif (parameter(parameter2($provider), 1) = 0.0) ; any selected
    set op_provider_var = "!="
else ; single value selected
    set op_provider_var = "="
endif
 
/**************************************************************
; CCL CODE HERE
**************************************************************/
 
Record note(
	1 note_cnt = i4
	1 list[*]
		2 fin = vc
		2 patient_name = vc
		2 personid = f8
		2 encntrid = f8
		2 facility = vc
		2 reg_dt = vc
		2 note_type = vc
		2 result_status = vc
		2 result_dt = vc
		2 performed_dt = vc
		2 verified_dt = vc
		2 note_template = vc
		2 signed_by = vc
		2 signed_by_position = vc
		2 performed_pr_id = f8
		2 verified_pr_id = f8
		2 performed_pr_name = vc
		2 verified_pr_name = vc
 
)
 
;---------------------------------------------------------------------------------------------------------------

;Get signed notes

select into $outdev
ce.encntr_id, note_typ = trim(uar_get_code_display(ce.event_cd))
, result_stat = trim(uar_get_code_display(ce.result_status_cd))
, resul_dt = ce.event_end_dt_tm "@SHORTDATETIME"
, sign_by = trim(pr.name_full_formatted)
, peform_dt = ce.performed_dt_tm "@SHORTDATETIME"
, verifi_dt = ce.verified_dt_tm "@SHORTDATETIME"
, note_temp = trim(uar_get_code_display(ce.entry_mode_cd))
, signed_by_pos = trim(uar_get_code_display(pr.position_cd))
 
from  clinical_event ce
	,ce_event_prsnl cep
	,prsnl pr
	,prsnl pr1
	,prsnl pr2
 
plan ce where ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	;Need to get all ce.result_status_cd with date below
	and ce.valid_until_dt_tm = cnvtdatetime('31-DEC-2100 00:00:00')
	and ce.entry_mode_cd in(anesthesia_var,cardiology_var,dyn_doc_var,msg_center_var,powernote_var,ed_powernote_var)
 
join cep where cep.event_id = ce.event_id
	and operator(cep.action_prsnl_id, op_provider_var, $provider)
	and cep.action_type_cd = 107.00 ;Sign
	and cep.action_status_cd = 653.00 ;Completed
 
join pr where pr.person_id = cep.action_prsnl_id
	and pr.active_ind = 1
	and pr.position_cd = $prsnl_position
 
join pr1 where pr1.person_id = outerjoin(ce.performed_prsnl_id)
	and pr1.active_ind = outerjoin(1)
 
join pr2 where pr2.person_id = outerjoin(ce.verified_prsnl_id)
	and pr1.active_ind = outerjoin(1)
 
order by ce.person_id, ce.encntr_id, ce.event_id
 
Head report
	cnt = 0
Head ce.event_id
	cnt += 1
	call alterlist(note->list, cnt)
	note->note_cnt = cnt
Detail
	note->list[cnt].personid = ce.person_id
	note->list[cnt].encntrid = ce.encntr_id
	note->list[cnt].note_template = note_temp
	note->list[cnt].note_type = note_typ
	note->list[cnt].performed_dt = format(ce.performed_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
	note->list[cnt].performed_pr_id = ce.performed_prsnl_id
	note->list[cnt].result_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
	note->list[cnt].result_status = result_stat
	note->list[cnt].signed_by = sign_by
	note->list[cnt].signed_by_position = signed_by_pos
	note->list[cnt].verified_dt = format(ce.verified_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
	note->list[cnt].verified_pr_id = ce.verified_prsnl_id
	note->list[cnt].performed_pr_name = trim(pr1.name_full_formatted)
	note->list[cnt].verified_pr_name =  trim(pr2.name_full_formatted)
 
with nocounter
 
;------------------------------------------------------------------------------------------
;Tele eICU

select into $outdev
ce.encntr_id, note_typ = trim(uar_get_code_display(ce.event_cd)), ce.event_id
, result_stat = trim(uar_get_code_display(ce.result_status_cd)), ce.view_level, ce.result_status_cd
, resul_dt = ce.event_end_dt_tm "@SHORTDATETIME"
, peform_dt = ce.performed_dt_tm "@SHORTDATETIME", ce.performed_prsnl_id
, note_temp = trim(uar_get_code_display(ce.entry_mode_cd)), ce.contributor_system_cd
, sign_by = trim(pr.name_full_formatted)
, signed_by_pos = trim(uar_get_code_display(pr.position_cd))
 
from  clinical_event ce
	,prsnl pr 
 
plan ce where ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	;Need to get all ce.result_status_cd with date below
	and ce.valid_until_dt_tm = cnvtdatetime('31-DEC-2100 00:00:00')
	and ce.view_level = 1
	and ce.entry_mode_cd = esi_var
	and ce.contributor_system_cd =  3854142281.00 ;eICU
	and operator(ce.performed_prsnl_id, op_provider_var, $provider)
 
join pr where pr.person_id = ce.performed_prsnl_id
	and pr.active_ind = 1
	and pr.position_cd = $prsnl_position

order by ce.person_id, ce.encntr_id, ce.event_id
 
Head ce.event_id
	cnt += 1
	call alterlist(note->list, cnt)
	note->note_cnt = cnt
Detail
	note->list[cnt].personid = ce.person_id
	note->list[cnt].encntrid = ce.encntr_id
	note->list[cnt].note_template = note_temp
	note->list[cnt].note_type = note_typ
	note->list[cnt].performed_dt = format(ce.performed_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
	note->list[cnt].performed_pr_id = ce.performed_prsnl_id
	note->list[cnt].result_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
	note->list[cnt].result_status = result_stat
	note->list[cnt].signed_by = sign_by
	note->list[cnt].signed_by_position = signed_by_pos
	note->list[cnt].performed_pr_name = trim(pr.name_full_formatted)

with nocounter 

;------------------------------------------------------------------------------------------

;Get Demographic
select into 'nl:'
 
from 	encounter e
	, encntr_alias ea
	, person p
 
plan e where expand(num, 1, note->note_cnt, e.encntr_id, note->list[num].encntrid)
	and e.active_ind = 1
 
join ea where ea.encntr_id = e.encntr_id
	and ea.active_ind = 1
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
order by e.encntr_id
 
Head e.encntr_id
	loc = 0
 	edx = 0
 	edx = locateval(loc, 1, note->note_cnt, e.encntr_id, note->list[loc].encntrid)
 	while(edx > 0)
		note->list[edx].fin = trim(ea.alias)
		note->list[edx].facility = uar_get_code_display(e.loc_facility_cd)
		note->list[edx].patient_name = trim(p.name_full_formatted)
		note->list[edx].reg_dt = format(e.reg_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
		edx = locateval(loc,(edx+1), note->note_cnt, e.encntr_id, note->list[loc].encntrid)
	endwhile
 
with nocounter ,expand = 1
 
;---------------------------------------------------------------------------------------
 
select into $outdev
	  facility = trim(substring(1, 50, note->list[d1.seq].facility))
	, fin = trim(substring(1, 30, note->list[d1.seq].fin))
	, patient_name = trim(substring(1, 50, note->list[d1.seq].patient_name))
	, registration_dt = trim(substring(1, 30, note->list[d1.seq].reg_dt))
	, note_type = trim(substring(1, 100, note->list[d1.seq].note_type))
	, result_status = trim(substring(1, 30, note->list[d1.seq].result_status))
	, signed_by = trim(substring(1, 50, note->list[d1.seq].signed_by))
	, result_dt = trim(substring(1, 30, note->list[d1.seq].result_dt))
	, performed_by = trim(substring(1, 50, note->list[d1.seq].performed_pr_name))
	, performed_dt = trim(substring(1, 30, note->list[d1.seq].performed_dt))
	, verified_by = trim(substring(1, 50, note->list[d1.seq].verified_pr_name))
	, verified_dt = trim(substring(1, 30, note->list[d1.seq].verified_dt))
	, note_template = trim(substring(1, 100, note->list[d1.seq].note_template))
	, signed_by_position = trim(substring(1, 100, note->list[d1.seq].signed_by_position))
 
from
	(dummyt   d1  with seq = size(note->list, 5))
 
plan d1
 
order by fin, result_dt
 
with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,maxcol=32000,format


#exitscript
 
end go
 
;with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120
;go to exitscript

 
 
