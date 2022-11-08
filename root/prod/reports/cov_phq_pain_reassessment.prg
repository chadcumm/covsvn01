 /*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Paramasivam
	Date Written:		JAN'2019
	Solution:			Population Health
	Source file name:  	cov_phq_pain_reassessment.prg
	Object name:		cov_phq_pain_reassessment
	Request#:			1201
 
	Program purpose:	      Test from 2hrs to 4Hrs
	Executing from:		CCL/DA2/Quality folder
  	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer		     Comment
----------	---------------- ------------------------------------------
10-01-19    Geetha      CR# 6384  - Add new DTA and increase assessment time greater than 2 hours to 4 hours
01-14-20    Geetha      CR# 6849  - Add PNRC and PW, MHHS psych locations
08/09/21    Geetha	CR# 10849 - Add 2 new DTAs to the report
08/09/21    Geetha	CR# 10775 - Add Peninsula BH to the prompt
11/01/22    Geetha      CR# 13041 - CMC added
******************************************************************************/
 
drop program cov_phq_pain_reassessment:DBA go
create program cov_phq_pain_reassessment:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	;<<hidden>>"Select Facility" = 0
	, "Select Nurse Unit" = 0 

with OUTDEV, start_datetime, end_datetime, nurse_unit
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare initcap() = c100
declare numeric_scale_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Numeric Rating Pain Scale")),protect
declare faces_scale_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "FACES Pain Scale Rating")),protect
declare cpot_scale_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "CPOT Total Score")),protect
declare flacc_scale_var     = f8 with constant(uar_get_code_by("DISPLAY", 72, "FLACC Score")),protect
declare nips_scale_var      = f8 with constant(uar_get_code_by("DISPLAY", 72, "NIPS Pain Assessment Score")),protect
declare med_effective_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Medication Effective")),protect
declare pain_present_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Pain Present")),protect
declare pre_med_pain_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Pre-Medication Pain Score")),protect
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
Record pain(
	1 pain_rec_cnt = i4
	1 plist[*]
		2 facility = vc
		2 nurse_unit = vc
		2 personid = f8
		2 encounterid = f8
		2 fin = vc
		2 patient_name = vc
		2 enc_rec_cnt = i4
		2 olist[*]
			3 enc = f8
			3 orderid = f8
			3 order_priority = i4
			3 medication_name = vc
			3 date_prn_med_given = dq8
			3 time_prn_med_given = vc
			3 admin_ord = i4
			3 pain_event = vc
			3 date_pain_score = dq8
			3 date_next_pain_score = dq8
			3 time_next_pain_score = vc
			3 pain_score = vc
			3 prn_reason = vc
			3 score_ord = i4
			3 diff_medgiven_painscale = f8
			3 diff_flag = vc
	)
 
 
;*********************************************************************************************************
;PRN Qualification
select into 'nl:'
 
e.encntr_id, i2.Medication, med_given_dt = format(i2.med_admin_dt, 'mm/dd/yyyy hh:mm;;q'), i2.admin_ord
, score_dt = format(i3.pain_event_end_dt, 'mm/dd/yyyy hh:mm;;q'), i3.score_ord
, event = uar_get_code_display(i3.event_cd)
 
from
 
 encounter e
 ,encntr_alias ea
 ,person p
 
,(	(select distinct e.person_id, e.encntr_id, nurse_unit = e.loc_nurse_unit_cd
		  , med_admin_dt = ce.event_end_dt_tm, od.oe_field_display_value
		  , Medication = ce.event_title_text, o.order_id, o.hna_order_mnemonic
		  , admin_ord = dense_rank() over (partition by ce.encntr_id order by ce.event_end_dt_tm asc)
 
		from encounter e, clinical_event ce, orders o, order_detail od
		where e.loc_nurse_unit_cd = $nurse_unit
		and e.active_ind = 1
		and o.person_id = e.person_id
		and o.encntr_id = e.encntr_id
		and o.prn_ind = 1 ;PRN med
		and o.active_ind = 1
		and ce.person_id = o.person_id
		and ce.encntr_id = o.encntr_id
		and ce.order_id = o.order_id
		and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	      and ce.view_level = 1
	      and ce.publish_flag = 1 ;active
	      and ce.event_class_cd in(232) ;MED
	      and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	      and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth (Verified), Modified
	      and od.order_id = o.order_id
	      and od.action_sequence = o.last_action_sequence
	      and od.oe_field_meaning = 'PRNREASON'
	      and cnvtlower(od.oe_field_display_value) = '*pain*'
 
	with sqltype('f8','f8','f8','dq8', 'vc', 'vc','f8','vc','i4')) i2
)
 
,(	(select distinct ce.person_id, ce.encntr_id, ce.event_cd, ce.result_val
			, pain_event_end_dt = ce.event_end_dt_tm
			, score_ord = dense_rank() over (partition by ce.encntr_id order by ce.event_end_dt_tm asc)
 
		from encounter e, clinical_event ce
		where e.loc_nurse_unit_cd = $nurse_unit
		and e.active_ind = 1
		and ce.person_id = e.person_id
		and ce.encntr_id = e.encntr_id
		and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
		and ce.event_cd in(numeric_scale_var, faces_scale_var, cpot_scale_var, flacc_scale_var, nips_scale_var, med_effective_var
						,pain_present_var, pre_med_pain_var)
	      and ce.view_level = 1
	      and ce.publish_flag = 1 ;active
	      and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	      and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth(Verified), Modified
 
	with sqltype('f8','f8','f8','vc','dq8','i4')) i3
)
 
plan i3
 
join e where e.person_id = i3.person_id
	and e.encntr_id = i3.encntr_id
 
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077 ;fin
	and ea.active_ind = 1
 
join p where p.person_id = e.person_id
 
join i2 where i2.person_id = outerjoin(i3.person_id)
	and i2.encntr_id = outerjoin(i3.encntr_id)
	and i2.admin_ord = outerjoin(i3.score_ord)
 
order by e.encntr_id, score_dt
 
Head report
 	cnt = 0
	call alterlist(pain->plist, 100)
 
Head e.encntr_id
 	cnt += 1
 	pain->pain_rec_cnt = cnt
	call alterlist(pain->plist, cnt)
 
 	pain->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
 	pain->plist[cnt].nurse_unit = uar_get_code_display(e.loc_nurse_unit_cd)
 	pain->plist[cnt].personid = e.person_id
 	pain->plist[cnt].encounterid = e.encntr_id
 	pain->plist[cnt].fin = ea.alias
 	pain->plist[cnt].patient_name = p.name_full_formatted
	ocnt = 0
Detail
 	ocnt += 1
	call alterlist(pain->plist[cnt].olist, ocnt)
 
	pain->plist[cnt].olist[ocnt].order_priority = ocnt
	pain->plist[cnt].olist[ocnt].enc = e.encntr_id
	pain->plist[cnt].olist[ocnt].orderid = i2.order_id
	pain->plist[cnt].olist[ocnt].medication_name = i2.hna_order_mnemonic
 	pain->plist[cnt].olist[ocnt].date_prn_med_given = i2.med_admin_dt
 	pain->plist[cnt].olist[ocnt].time_prn_med_given = format(i2.med_admin_dt, 'hh:mm;;q')
 	pain->plist[cnt].olist[ocnt].admin_ord = i2.admin_ord
 	pain->plist[cnt].olist[ocnt].pain_event = event
 	pain->plist[cnt].olist[ocnt].date_pain_score = i3.pain_event_end_dt
 	pain->plist[cnt].olist[ocnt].prn_reason = i2.oe_field_display_value
 
Foot e.encntr_id
	pain->plist[cnt].enc_rec_cnt = ocnt
	call alterlist(pain->plist, cnt)
 
with nocounter
 
;call echorecord(pain)
 
;*********************************************************************************************************
;Find and assign 4 hrs difference
IF(pain->pain_rec_cnt > 0)
 
select into 'nl:'
 
enc = pain->plist[d1.seq].encounterid
,ord = pain->plist[d1.seq].olist[d2.seq].order_priority
 
from	(dummyt   d1  with seq = size(pain->plist, 5))
	, (dummyt   d2  with seq = 1)
 
plan d1 where maxrec(d2, size(pain->plist[d1.seq].olist, 5))
join d2
 
order by enc, ord
 
Head enc
	enc_size = 0
 	enc_size = pain->plist[d1.seq].enc_rec_cnt
 
	if(enc_size > 0)
	  for (i=1 to enc_size)
		  if(pain->plist[d1.seq].olist[i].time_prn_med_given != '')
		    	j = 1
			while(j <= enc_size)
				if(pain->plist[d1.seq].olist[j].date_pain_score > pain->plist[d1.seq].olist[i].date_prn_med_given)
					pain->plist[d1.seq].olist[i].date_next_pain_score = pain->plist[d1.seq].olist[j].date_pain_score
					pain->plist[d1.seq].olist[i].time_next_pain_score = format(pain->plist[d1.seq].olist[j].date_pain_score,'hh:mm;;q')
					j = enc_size + 1 ;exit
				else
					j += 1 ;continue
			      endif
			endwhile
			pain->plist[d1.seq].olist[i].diff_medgiven_painscale =
			 DATETIMEDIFF(pain->plist[d1.seq].olist[i].date_next_pain_score, pain->plist[d1.seq].olist[i].date_prn_med_given,7)
 
			pain->plist[d1.seq].olist[i].diff_flag =
				if(DATETIMEDIFF(pain->plist[d1.seq].olist[i].date_next_pain_score
					, pain->plist[d1.seq].olist[i].date_prn_med_given, 3) >= 4) 'Y'
				endif
		  endif
     	  endfor
 	endif
 
with nocounter
 
call echorecord(pain)
 
 
;--------------------------------------------------------------------------------------------------------------------
 
select distinct into value($outdev)
 
	facility = substring(1, 30, pain->plist[d1.seq].facility)
	, nurse_unit = substring(1, 30, pain->plist[d1.seq].nurse_unit)
	, fin = substring(1, 30, pain->plist[d1.seq].fin)
	, patient_name = substring(1, 100, pain->plist[d1.seq].patient_name)
	;, order_priority = pain->plist[d1.seq].olist[d2.seq].order_priority
	;, medication_name = substring(1, 30, pain->plist[d1.seq].olist[d2.seq].medication_name)
	, date_prn_med_given = format(pain->plist[d1.seq].olist[d2.seq].date_prn_med_given, 'mm/dd/yyyy hh:mm;;q')
	;, time_prn_med_given = substring(1, 30, pain->plist[d1.seq].olist[d2.seq].time_prn_med_given)
	;, date_pain_score = format(pain->plist[d1.seq].olist[d2.seq].date_pain_score, 'mm/dd/yyyy hh:mm;;q')
	, date_next_pain_score = format(pain->plist[d1.seq].olist[d2.seq].date_next_pain_score, 'mm/dd/yyyy hh:mm;;q')
	;, time_next_pain_score = substring(1, 30, pain->plist[d1.seq].olist[d2.seq].time_next_pain_score)
	, time_between_medgiven_reassessment = format(pain->plist[d1.seq].olist[d2.seq].diff_medgiven_painscale, "###.##:##")
	, prn_reason = substring(1, 50, pain->plist[d1.seq].olist[d2.seq].prn_reason)
 
from
	(dummyt   d1  with seq = size(pain->plist, 5))
	, (dummyt   d2  with seq = 1)
 
plan d1 where maxrec(d2, size(pain->plist[d1.seq].olist, 5))
 
join d2 where substring(1, 1, pain->plist[d1.seq].olist[d2.seq].diff_flag) = 'Y'
 
order by
	facility
	, nurse_unit
	, patient_name
	, date_prn_med_given
	;, pain->plist[d1.seq].olist[d2.seq].order_priority
 
with nocounter, separator=" ", format
 
 
endif
 
end go
 
/*
;Nurse unit promot
 
select distinct
    nurse_unit = uar_get_code_display(nu.location_cd)
   ,nurse_unit_cd = nu.location_cd
 
from nurse_unit nu
where nu.loc_facility_cd = 2552503645.00 ;$facility_list
and nu.active_status_cd = 188 ;Active
           and nu.active_ind = 1
           and nu.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           and nu.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
order nurse_unit
 
 
 
/*   45346635.00	Numeric Rating Pain Scale
    45346729.00	FACES Pain Scale Rating
    30778783.00	CPOT Total Score
     4158628.00	FLACC Score
     712025.00	NIPS Pain Assessment Score
 
     36771227.00	referred Pain Tool
*/
 
 
