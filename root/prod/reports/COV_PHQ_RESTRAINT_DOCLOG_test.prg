 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Saravanan
	Date Written:		May'2018
	Solution:			population Health Quality
	Source file name:  	based on :cov_phq_restraint_document_log.prg
	Object name:		based on :cov_phq_restraint_document_log
	Request#:			1045
 
	Program purpose:	      Report will show documentation log for patients with restraints.
	Executing from:		CCL/DA2/Nursing & Quality folders
  	Special Notes:          Excel file.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	--------------------	------------------------------------------
8/30/2018   Geetha Saravanan        Adding new DTA as per CR# 3181
 
******************************************************************************/
 
drop program COV_PHQ_RESTRAINT_DOCLOG_test:DBA go
create program COV_PHQ_RESTRAINT_DOCLOG_test:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Document Date/Time" = ""
	, "End Document Date/Time" = ""
	, "FacilityListBox" = 0
 
with OUTDEV, start_datetime, end_datetime, facility_list
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare initcap()            = c100
declare mrn_var              = f8 with constant(uar_get_code_by("DISPLAY", 319, 'MRN')),protect
declare fin_var              = f8 with constant(uar_get_code_by("DISPLAY", 319, 'FIN NBR')),protect
declare prsnl_var            = f8 with constant(uar_get_code_by("DISPLAY",     331, 'Primary Care Physician')),protect  ;1115.00
declare position_var         = f8 with constant(uar_get_code_by("CDF_MEANING", 88, 'PRIMARY CARE')),protect  ;19944603.00
 
declare type_var             = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Restraint Type:')),protect
declare rest_loc_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Restraint Location:')),protect
declare rest_safty_chk_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Restraint Safety Check')),protect
 
;Reason for restraint
declare rest_reson_ed_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Ed-Reason for Use of Restraint')),protect
declare rest_reson_NV_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Restraint Initiation Behavior Reason NV')),protect
declare rest_reson_pre_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Preadm Restraint Reason')),protect
declare rest_reson_LTC_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Reason for Restraint LTC')),protect
declare rest_reson_cLTC_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Reason for Considering Restraint LTC')),protect
declare rest_reson_V_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Restraint Initiation Behavior Reason V')),protect
 
 
declare activity_type_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Restraint Activity Type:')),protect
declare discon_crite_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Discontinue Criteria for Restraint')),protect
declare rest_alter_type_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Restraint Alternative Type')),protect
 
;Restraints Alternatives documented
declare rest_alt_doc_vio_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Restraint Alternatives Violent')),protect
declare rest_alt_doc_nvio_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Restraint Alternatives Non-Violent')),protect
 
;Behavior requiring Restraint
declare beha_med_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Behavior Requiring Medical Restraint')),protect
declare beha_vio_var         = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Requiring Violent Restraint')),protect
declare beha_behav_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Behavior Requiring Behavioral Restraint')),protect
 
declare rest_response_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Restraint Response to Alternatives')),protect
declare eval_status_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Evaluation of Status in Restraints:')),protect
declare rest_behav_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Restraint Behavior Description')),protect
 
declare reles_resn_var       = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Restraint Reason for Release')),protect
declare rest_reappli_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, 'Restraint Reapplied After Care/Treatment')),protect
 
declare tmp_reason           = vc
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
Record restraint(
	1 reccnt = i4
	1 plist[*]
		2 facility        = f8
		2 personid        = f8
		2 encntrid        = f8
		2 fin             = vc
		2 mrn             = vc
		2 pat_name        = vc
		2 admit_date      = vc
		2 unit            = vc
		2 room            = vc
		2 bed             = vc
		2 rest_type       = vc
		2 rest_loc        = vc
		2 rest_safty      = vc
		2 rest_reson_ed   = vc
		2 rest_reson_NV   = vc
		2 rest_reson_pre  = vc
		2 rest_reson_LTC  = vc
		2 rest_reson_cLTC = vc
		2 rest_reson_V    = vc
		2 rest_reason     = vc
		2 activity_type   = vc
		2 discontinue_dt  = vc
		2 discon_crite    = vc
		2 rest_alter_type = vc
		2 rest_alt_doc_vio   = vc
		2 rest_alt_doc_nvio  = vc
		2 rest_alt_doc    = vc
		2 beha_med        = vc
		2 beha_violent    = vc
		2 beha_behav      = vc
		2 rest_response   = vc
		2 eval_status     = vc
		2 rest_eval_dt    = vc
		2 nurse_documenting = vc
		2 rest_behav_status = vc
		2 reles_reason    = vc
		2 rest_reappli    = vc
		/*2 orders[*]
			3 orderid           = f8
			3 rest_ord_type     = vc ; tele,verbal,md
			3 rest_ord_dt       = vc
			3 rest_ord_day      = vc
			3 rest_ord_unit     = vc
			3 rest_ord_md       = vc
			3 rest_plan_ord     = vc
			3 rest_req_start_dt = vc
			3 special_inst      = vc
			3 rest_ord_entered  = vc
			3 unit_documenting  = vc*/
)
 
;----------------------------------------------------------------------------------------------------------------- 
select into "nl:"
 
 e.person_id
, e.encntr_id
, Facility = uar_get_code_display(e.loc_facility_cd)
, FIN = ea.alias
, MRN = ea1.alias
, Patient_Name = initcap(p.name_full_formatted)
, Admit_dt = format(e.reg_dt_tm,"MM/DD/YYYY;;D")
, unit = uar_get_code_display(e.loc_nurse_unit_cd)
, room = uar_get_code_display(e.loc_room_cd)
, bed = uar_get_code_display(e.loc_bed_cd)
 
 
from
 
 encounter e
 , encntr_alias ea
 , encntr_alias ea1
 , person p
 , prsnl pr5
 
,( ( select distinct ce.person_id, ce.encntr_id,ce.event_cd, ce.result_val, ce.event_end_dt_tm, ce.performed_prsnl_id
	    ,ce.verified_dt_tm, ce.verified_prsnl_id
	    ,ordext = dense_rank() over (partition by ce.encntr_id,ce.event_cd order by ce.event_end_dt_tm desc)
 	from clinical_event ce, encounter e
	where ce.encntr_id = e.encntr_id
	and e.loc_facility_cd = $facility_list
      and e.encntr_id != 0
 	and ce.result_status_cd in(25,34,35)
	and ce.valid_until_dt_tm > sysdate
	and ce.valid_from_dt_tm <= sysdate
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and ce.event_cd in(
		rest_reson_ed_var,rest_reson_NV_var,rest_reson_pre_var,rest_reson_LTC_var,rest_reson_cLTC_var,rest_reson_V_var,
		activity_type_var, discon_crite_var, rest_alter_type_var, rest_alt_doc_vio_var, rest_alt_doc_nvio_var,
		rest_response_var, beha_med_var, beha_vio_var, beha_behav_var, rest_response_var, eval_status_var,rest_behav_var,
		reles_resn_var, rest_reappli_var,type_var, rest_loc_var, rest_safty_chk_var)
	with sqltype("f8", "f8", "f8", "VC", "dq8", "f8","dq8", "f8", "i4")
 	)i2
 )
 
plan i2 where i2.ordext = 1
 
join e where e.person_id = i2.person_id
	and e.encntr_id = i2.encntr_id
      and e.encntr_id != 0
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = fin_var
	and ea.active_ind = 1
 
join ea1 where ea1.encntr_id = e.encntr_id
	and ea1.encntr_alias_type_cd = mrn_var
	and ea1.active_ind = 1
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
join pr5 where pr5.person_id = i2.verified_prsnl_id
	and pr5.active_ind = 1
 
order by e.encntr_id
 
Head report
cnt = 0
call alterlist(restraint->plist, 10)
 
Head e.encntr_id
	tmp_reason = ''
	cnt = cnt + 1
 	restraint->reccnt = cnt
	call alterlist(restraint->plist, cnt)
Detail
 	restraint->plist[cnt].facility = e.loc_facility_cd
 	restraint->plist[cnt].personid = e.person_id
 	restraint->plist[cnt].encntrid = e.encntr_id
	restraint->plist[cnt].fin = fin
	restraint->plist[cnt].mrn = mrn
	restraint->plist[cnt].pat_name = patient_name
	restraint->plist[cnt].admit_date = admit_dt
	restraint->plist[cnt].unit = unit
	restraint->plist[cnt].room = room
	restraint->plist[cnt].bed = bed
 
 	case (i2.event_cd)
 
		of type_var:
			restraint->plist[cnt].rest_type         = trim(i2.result_val)
		Of rest_loc_var:
			restraint->plist[cnt].rest_loc          = trim(i2.result_val)
		OF rest_safty_chk_var:
			restraint->plist[cnt].rest_safty        = trim(i2.result_val)
		Of rest_reson_ed_var:
			restraint->plist[cnt].rest_reson_ed     = trim(i2.result_val)
		Of rest_reson_NV_var:
			restraint->plist[cnt].rest_reson_NV     = trim(i2.result_val)
		Of rest_reson_pre_var:
			restraint->plist[cnt].rest_reson_pre    = trim(i2.result_val)
		Of rest_reson_LTC_var:
			restraint->plist[cnt].rest_reson_LTC    = trim(i2.result_val)
		Of rest_reson_cLTC_var:
			restraint->plist[cnt].rest_reson_cLTC   = trim(i2.result_val)
		Of rest_reson_V_var:
			restraint->plist[cnt].rest_reson_V      = trim(i2.result_val)
		Of activity_type_var:
			restraint->plist[cnt].activity_type     = trim(i2.result_val)
		Of discon_crite_var:
			restraint->plist[cnt].discon_crite      = trim(i2.result_val)
		Of rest_alter_type_var:
			restraint->plist[cnt].rest_alter_type   = trim(i2.result_val)
		Of rest_alt_doc_vio_var:
			restraint->plist[cnt].rest_alt_doc_vio  = trim(i2.result_val)
		Of rest_alt_doc_nvio_var:
			restraint->plist[cnt].rest_alt_doc_nvio = trim(i2.result_val)
		Of beha_med_var:
			restraint->plist[cnt].beha_med          = trim(i2.result_val)
		Of beha_vio_var:
			restraint->plist[cnt].beha_violent      = trim(i2.result_val)
		Of beha_behav_var:
			restraint->plist[cnt].beha_behav        = trim(i2.result_val)
		Of rest_response_var:
			restraint->plist[cnt].rest_response     = trim(i2.result_val)
		Of eval_status_var:
			restraint->plist[cnt].eval_status       = trim(i2.result_val)
			restraint->plist[cnt].rest_eval_dt      = format(i2.verified_dt_tm, "MM/DD/YYYY HH:MM;;D")
			restraint->plist[cnt].nurse_documenting = trim(pr5.name_full_formatted)
		Of rest_behav_var:
			restraint->plist[cnt].rest_behav_status = trim(i2.result_val)
		Of reles_resn_var:
			restraint->plist[cnt].reles_reason      = trim(i2.result_val)
		Of rest_reappli_var:
			restraint->plist[cnt].rest_reappli      = trim(i2.result_val)
	endcase
 
Foot e.encntr_id
 
	restraint->plist[cnt].rest_alt_doc = build(trim(restraint->plist[cnt].rest_alt_doc_nvio), ' '
			,trim(restraint->plist[cnt].rest_alt_doc_vio))
 
	tmp_reason = build(trim(restraint->plist[cnt].rest_reson_ed), ''
	, trim(restraint->plist[cnt].rest_reson_NV), ''
	, trim(restraint->plist[cnt].rest_reson_V), ''
	, trim(restraint->plist[cnt].rest_reson_cLTC), ''
	, trim(restraint->plist[cnt].rest_reson_LTC))
 
	for (i=1 to size(restraint->plist,5))
		if(restraint->plist[i].encntrid = restraint->plist[cnt].encntrid)
			restraint->plist[i].rest_reason = replace(tmp_reason,",","",2)
		endif
     endfor
 
     	if(restraint->plist[cnt].activity_type = 'Discontinue')
     		restraint->plist[cnt].discontinue_dt = format(i2.verified_dt_tm, "MM/DD/YYYY HH:MM;;D")
     	else
		restraint->plist[cnt].discontinue_dt = ''
	endif
 
with nocounter
;-------------------------------------------------------------------------------------------------------------

select distinct into $outdev
 
	facility = trim(uar_get_code_display(restraint->plist[d1.seq].facility))
	, location = replace(build(
		 trim(substring(1, 10, restraint->plist[d1.seq].unit)),';'
		,trim(substring(1, 10, restraint->plist[d1.seq].room)),';'
		,trim(substring(1, 10, restraint->plist[d1.seq].bed))
		), char(59), " ", 0)
 
	, fin = trim(substring(1, 10, restraint->plist[d1.seq].fin))
	, mrn = trim(substring(1, 10, restraint->plist[d1.seq].mrn))
	, patient_name = trim(substring(1, 50, restraint->plist[d1.seq].pat_name))
	, admit_date = trim(substring(1, 20, restraint->plist[d1.seq].admit_date))
	;, rest_ord_dt = trim(substring(1, 20, restraint->plist[d1.seq].orders[d2.seq].rest_ord_dt))
	;, rest_ord_day = trim(substring(1, 20, restraint->plist[d1.seq].orders[d2.seq].rest_ord_day))
	;, rest_ord_unit = trim(substring(1, 10, restraint->plist[d1.seq].orders[d2.seq].rest_ord_unit))
	;, restraint_order_md = trim(substring(1, 50, restraint->plist[d1.seq].orders[d2.seq].rest_ord_md))
	;, restraint_plan_ordered = trim(substring(1, 50, restraint->plist[d1.seq].orders[d2.seq].rest_plan_ord))
	;, rest_req_start_dt = trim(substring(1, 20, restraint->plist[d1.seq].orders[d2.seq].rest_req_start_dt))
	, restraint_type = trim(substring(1, 100, restraint->plist[d1.seq].rest_type))
	, restraint_location = trim(substring(1, 100, restraint->plist[d1.seq].rest_loc))
	, restraint_reason = trim(substring(1, 300, restraint->plist[d1.seq].rest_reason))
	;, special_instruction = trim(substring(1, 300, restraint->plist[d1.seq].orders[d2.seq].special_inst))
	;, restraint_order_type = trim(substring(1, 100, restraint->plist[d1.seq].orders[d2.seq].rest_ord_type))
	;, restraint_order_entered = trim(substring(1, 100, restraint->plist[d1.seq].orders[d2.seq].rest_ord_entered))
	, restraint_safety_check = trim(substring(1, 100, restraint->plist[d1.seq].rest_safty))
	, rest_eval_dt = trim(substring(1, 30, restraint->plist[d1.seq].rest_eval_dt))
	, nurse_documenting = trim(substring(1, 50, restraint->plist[d1.seq].nurse_documenting))
	, activity_type = trim(substring(1, 100, restraint->plist[d1.seq].activity_type))
	, discontinue_dt = trim(substring(1, 30, restraint->plist[d1.seq].discontinue_dt))
	, discontinue_criteria = trim(substring(1, 100, restraint->plist[d1.seq].discon_crite))
	, restraint_alter_type = trim(substring(1, 100, restraint->plist[d1.seq].rest_alter_type))
	, restraint_alter_document = trim(substring(1, 300, restraint->plist[d1.seq].rest_alt_doc))
	, restraint_response = trim(substring(1, 100, restraint->plist[d1.seq].rest_response))
	, behavior_require_med_rest = trim(substring(1, 100, restraint->plist[d1.seq].beha_med))
	, evaluation_status = trim(substring(1, 100, restraint->plist[d1.seq].eval_status))
	, restraint_behav_status = trim(substring(1, 100, restraint->plist[d1.seq].rest_behav_status))
	, release_reason = trim(substring(1, 100, restraint->plist[d1.seq].reles_reason))
	, restraint_reappli = trim(substring(1, 30, restraint->plist[d1.seq].rest_reappli))
 
from
	(dummyt   d1  with seq = value(size(restraint->plist, 5)))
	;, (dummyt   d2  with seq = 1)
 
plan d1
 
;where maxrec(d2, size(restraint->plist[d1.seq].orders, 5))
;join d2
 
;order by facility, location, patient_name, rest_ord_dt, restraint_plan_ordered, restraint_type

order by facility, location, patient_name, rest_eval_dt, restraint_type
 
with nocounter, separator=" ", format


end go

;---------------------------------------------------------------------------------------------------------------------
/* 
IF(restraint->reccnt != 0)
 
;Get Orders
Select distinct into "NL:"
 
 e.loc_facility_cd
, e.person_id
, e.encntr_id
, rest_order_date = format(i.order_dt_tm, "MM/DD/YYYY HH:MM;;D")
, rest_order_day =
if(weekday(i.order_dt_tm) = 0) "Sunday"
	elseif(weekday(i.order_dt_tm) = 1) "Monday"
	elseif(weekday(i.order_dt_tm) = 2) "Tuesday"
	elseif(weekday(i.order_dt_tm) = 3) "Wednesday"
	elseif(weekday(i.order_dt_tm) = 4) "Thursday"
	elseif(weekday(i.order_dt_tm) = 5) "Friday"
	elseif(weekday(i.order_dt_tm) = 6) "Saturday"
endif
 
, order_unit  = uar_get_code_display(i.order_locn_cd)
, md_ordering = initcap(pr.name_full_formatted) ;ac.order_provider_id
, rest_plan_ordered = i.hna_order_mnemonic
, req_start_date = format(i.orig_order_dt_tm, "MM/DD/YYYY HH:MM;;D")
, special_Inst = i.order_detail_display_line
, rest_order_type = uar_get_code_display(i.communication_type_cd) ; restraint order type - tele,verbal,md
, rest_order_entered = pr1.name_full_formatted
, nurse_document = pr2.name_full_formatted
, unit_at_time_document = 'N/A'
 
 
from ;encounter e
	(dummyt d with seq = value(size(restraint->plist, 5)))
	,prsnl pr
	,prsnl pr1
	,prsnl pr2
 
  , ( (select distinct o.person_id,o.encntr_id, o.hna_order_mnemonic, o.orig_order_dt_tm
 	, o.order_detail_display_line
 	, o.updt_dt_tm, o.valid_dose_dt_tm, o.status_prsnl_id
 	, ac.order_dt_tm, ac.order_locn_cd, ac.order_provider_id, ac.supervising_provider_id, ac.communication_type_cd
 
	from orders o, order_action ac, encounter e
		where e.loc_facility_cd = $facility_list
		and o.encntr_id = e.encntr_id
		and ac.order_id = o.order_id
   		and ac.order_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
		and e.encntr_id != 0
	      and e.active_ind = 1
  		and o.hna_order_mnemonic = "*Restraint*"
  		and o.active_ind = 1
		and ac.action_sequence =
		   (select max(action_sequence) from order_action where order_id = ac.order_id group by ac.order_id)
		order by o.encntr_id
 
 		with sqltype("f8","f8","vc","dq8","vc","dq8","dq8","f8", "dq8","f8","f8","f8","f8")
     )i
 )
 
plan d
 
join i where i.encntr_id = outerjoin(restraint->plist[d.seq].encntrid)
 
join pr where pr.person_id = outerjoin(i.order_provider_id)
	and pr.active_ind = outerjoin(1)
	and pr.physician_ind = outerjoin(1)
 
join pr1 where pr1.person_id = outerjoin(i.supervising_provider_id)
	and pr1.active_ind = outerjoin(1)
 
join pr2 where pr2.person_id = outerjoin(i.status_prsnl_id)
	and pr2.active_ind = outerjoin(1)
 
order by i.encntr_id, i.order_dt_tm
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT, TIME = 120;, maxrec = 10000
 
;Load into Record structure
Head i.encntr_id
	numx = 0
	idx = 0
	ocnt = 0
	idx = locateval(numx, 1, size(restraint->plist, 5), i.encntr_id , restraint->plist[numx].encntrid)
	if(idx > 0)
		call alterlist(restraint->plist[idx].orders, 10)
	endif
 
Detail
	if (idx > 0)
		ocnt = ocnt + 1
		if (mod(ocnt, 10) = 1 and ocnt > 10)
			call alterlist(restraint->plist[idx].orders, ocnt+9)
		endif
 
 		restraint->plist[idx].orders[ocnt].rest_plan_ord = rest_plan_ordered
 		restraint->plist[idx].orders[ocnt].rest_ord_dt = rest_order_date
 		restraint->plist[idx].orders[ocnt].rest_ord_day = Rest_Order_Day
 		restraint->plist[idx].orders[ocnt].rest_ord_unit = Order_unit
 		restraint->plist[idx].orders[ocnt].rest_ord_md = md_ordering
 		restraint->plist[idx].orders[ocnt].special_inst = special_Inst
 		restraint->plist[idx].orders[ocnt].rest_ord_entered = Rest_Order_Entered
 		restraint->plist[idx].orders[ocnt].rest_ord_type = rest_order_type
 		restraint->plist[idx].orders[ocnt].rest_req_start_dt = Req_Start_Date
	endif
 
Foot report
 	call alterlist(restraint->plist[idx]->orders, ocnt)
 
WITH nocounter
;-----------------------------------------------------------------------------------------------------------
 
;select values from record structure to display as grid in reporting portal.
SELECT DISTINCT INTO VALUE($OUTDEV)
 
	FACILITY = trim(UAR_GET_CODE_DISPLAY(RESTRAINT->plist[D1.SEQ].facility))
	, LOCATION = replace(BUILD(
		 TRIM(SUBSTRING(1, 10, RESTRAINT->plist[D1.SEQ].unit)),';'
		,TRIM(SUBSTRING(1, 10, RESTRAINT->plist[D1.SEQ].room)),';'
		,TRIM(SUBSTRING(1, 10, RESTRAINT->plist[D1.SEQ].bed))
		), char(59), " ", 0)
 
	, FIN = trim(SUBSTRING(1, 10, RESTRAINT->plist[D1.SEQ].fin))
	, MRN = trim(SUBSTRING(1, 10, RESTRAINT->plist[D1.SEQ].mrn))
	, PATIENT_NAME = TRIM(SUBSTRING(1, 50, RESTRAINT->plist[D1.SEQ].pat_name))
	, ADMIT_DATE = trim(SUBSTRING(1, 20, RESTRAINT->plist[D1.SEQ].admit_date))
	, REST_ORD_DT = trim(SUBSTRING(1, 20, RESTRAINT->plist[D1.SEQ].orders[D2.SEQ].rest_ord_dt))
	, REST_ORD_DAY = trim(SUBSTRING(1, 20, RESTRAINT->plist[D1.SEQ].orders[D2.SEQ].rest_ord_day))
	, REST_ORD_UNIT = trim(SUBSTRING(1, 10, RESTRAINT->plist[D1.SEQ].orders[D2.SEQ].rest_ord_unit))
	, RESTRAINT_ORDER_MD = trim(SUBSTRING(1, 50, RESTRAINT->plist[D1.SEQ].orders[D2.SEQ].rest_ord_md))
	, RESTRAINT_PLAN_ORDERED = trim(SUBSTRING(1, 50, RESTRAINT->plist[D1.SEQ].orders[D2.SEQ].rest_plan_ord))
	, REST_REQ_START_DT = trim(SUBSTRING(1, 20, RESTRAINT->plist[D1.SEQ].orders[D2.SEQ].rest_req_start_dt))
	, RESTRAINT_TYPE = trim(SUBSTRING(1, 100, RESTRAINT->plist[D1.SEQ].rest_type))
	, RESTRAINT_LOCATION = trim(SUBSTRING(1, 100, RESTRAINT->plist[D1.SEQ].rest_loc))
	, RESTRAINT_REASON = trim(SUBSTRING(1, 300, RESTRAINT->plist[D1.SEQ].rest_reason))
	, SPECIAL_INSTRUCTION = trim(SUBSTRING(1, 300, RESTRAINT->plist[D1.SEQ].orders[D2.SEQ].special_inst))
	, RESTRAINT_ORDER_TYPE = trim(SUBSTRING(1, 100, RESTRAINT->plist[D1.SEQ].orders[D2.SEQ].rest_ord_type))
	, RESTRAINT_ORDER_ENTERED = trim(SUBSTRING(1, 100, RESTRAINT->plist[D1.SEQ].orders[D2.SEQ].rest_ord_entered))
	, RESTRAINT_SAFETY_CHECK = trim(SUBSTRING(1, 100, RESTRAINT->plist[D1.SEQ].rest_safty))
	, REST_EVAL_DT = trim(SUBSTRING(1, 30, RESTRAINT->plist[D1.SEQ].rest_eval_dt))
	, NURSE_DOCUMENTING = trim(SUBSTRING(1, 50, RESTRAINT->plist[D1.SEQ].nurse_documenting))
	, ACTIVITY_TYPE = trim(SUBSTRING(1, 100, RESTRAINT->plist[D1.SEQ].activity_type))
	, DISCONTINUE_DT = trim(SUBSTRING(1, 30, RESTRAINT->plist[D1.SEQ].discontinue_dt))
	, DISCONTINUE_CRITERIA = trim(SUBSTRING(1, 100, RESTRAINT->plist[D1.SEQ].discon_crite))
	, RESTRAINT_ALTER_TYPE = trim(SUBSTRING(1, 100, RESTRAINT->plist[D1.SEQ].rest_alter_type))
	, RESTRAINT_ALTER_DOCUMENT = trim(SUBSTRING(1, 300, RESTRAINT->plist[D1.SEQ].rest_alt_doc))
	, RESTRAINT_RESPONSE = trim(SUBSTRING(1, 100, RESTRAINT->plist[D1.SEQ].rest_response))
	, BEHAVIOR_REQUIRE_MED_REST = trim(SUBSTRING(1, 100, RESTRAINT->plist[D1.SEQ].beha_med))
	, EVALUATION_STATUS = trim(SUBSTRING(1, 100, RESTRAINT->plist[D1.SEQ].eval_status))
	, RESTRAINT_BEHAV_STATUS = trim(SUBSTRING(1, 100, RESTRAINT->plist[D1.SEQ].rest_behav_status))
	, RELEASE_REASON = trim(SUBSTRING(1, 100, RESTRAINT->plist[D1.SEQ].reles_reason))
	, RESTRAINT_REAPPLI = trim(SUBSTRING(1, 30, RESTRAINT->plist[D1.SEQ].rest_reappli))
 
FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(RESTRAINT->plist, 5)))
	, (DUMMYT   D2  WITH SEQ = 1)
 
PLAN D1
 
WHERE MAXREC(D2, SIZE(RESTRAINT->plist[D1.SEQ].orders, 5))
JOIN D2
 
ORDER BY
	FACILITY
	, LOCATION
	, PATIENT_NAME
	, REST_ORD_DT
	, RESTRAINT_PLAN_ORDERED
	, RESTRAINT_TYPE
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT, skipreport = 1
 
ENDIF
 
call echorecord(restraint)
 
 
end
go
 
 
 
 
