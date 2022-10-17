/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Aug'2022
	Solution:			All
	Source file name:	      cov_phq_deaf_hoh_interp_log.prg
	Object name:		cov_phq_deaf_hoh_interp_log
	Request#:			13551
	Program purpose:	      Interpreter compliance
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/

drop program cov_phq_deaf_hoh_interp_log:dba go
create program cov_phq_deaf_hoh_interp_log:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Start Scheduled Date/Time" = "SYSDATE"
	, "End  Scheduled Date/Time" = "SYSDATE"
	, "Select Facility" = 0 

with OUTDEV, start_datetime, end_datetime, facility_list



/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/


declare sch_interp_req_var = f8 with constant(25789963.00);Sch Interpreter
declare sch_interp_typ_var = f8 with constant(3910266653.00);Sch Interpreter type

declare interp_req_tmp_var = vc with noconstant('')
declare num = i4 with noconstant(0)
declare opr_fac_var = vc with noconstant("")

;Facility variable
if(substring(1,1,reflect(parameter(parameter2($facility_list),0))) = "l");multiple values were selected
	set opr_fac_var = "in"
elseif(parameter(parameter2($facility_list),1)= 0.0)	;all[*] values were selected
	set opr_fac_var = "!="
else									;a single value was selected
	set opr_fac_var = "="
endif


Record pat(
	1 rec_cnt = i4
	1 plist[*]
		2 facility = vc
		2 unit = vc
		2 pat_name = vc
		2 fin = vc
		2 personid = f8
		2 encntrid = f8
		2 sch_appt_dt = dq8
		2 sch_interp_req = vc
		2 sch_interp_req_dt = dq8
		2 sch_interp_type = vc
		2 reg_interp_res = vc
		2 reg_interp_req_dt = dq8
		2 reg_interp_type = vc
		2 nu_interp_res = vc
		2 nu_interp_req_dt = dq8
		2 nu_interp_type = vc
		2 nu_interp_service_for = vc ;patient/companion
		2 interp_response_dt = dq8
		2 reason_no_service = vc
		2 pr_no_service_decision = vc

)		




/**************************************************************
; DVDev Start Coding
**************************************************************/

;Patient Population - scheduling

select into $outdev
sa.appt_location_cd, sa.encntr_id, sa.person_id, sed.oe_field_display_value, SA.beg_dt_tm, sa.end_dt_tm
,oef.oe_field_id, ofm.description, ofm.oe_field_meaning, ofm.oe_field_meaning_id, oef.*, sed.*

from  sch_appt sa
	, sch_event_detail sed
	, order_entry_fields oef
	, oe_field_meaning ofm

plan sa where sa.beg_dt_tm >= cnvtdatetime("01-JUL-2022 00:00:00")
	;sa.beg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	;and operator(sa.appt_location_cd, opr_fac_var, $facility_list)
	and sa.person_id =     20785859.00 ;ZZZTEST, SELENA
	and sa.active_ind = 1
	and sa.sch_state_cd = value(uar_get_code_by("DISPLAY", 14233, "Confirmed"))
	and sa.sch_role_cd = value(uar_get_code_by("DISPLAY", 14250, "Patient"))

join sed where sed.sch_event_id = sa.sch_event_id
	;and sed.oe_field_id in(25789963.00,3910266653.00) 
	and sed.oe_field_id in(sch_interp_req_var, sch_interp_typ_var)
	and((sed.oe_field_display_value = 'Yes - Deaf/HOH')
	    or(sed.oe_field_display_value = 'Video Device') or (sed.oe_field_display_value = 'Live Interpreter requested')
	    or(sed.oe_field_display_value = 'Yes With STRATUS') or (sed.oe_field_display_value = 'Yes With LIVE'))
	and sed.active_ind = 1
	
join oef where oef.oe_field_id = sed.oe_field_id
	
join ofm where ofm.oe_field_meaning_id = oef.oe_field_meaning_id

order by sa.encntr_id, sed.oe_field_id

;with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000
;go to exitscript


Head report
	cnt = 0
Head sa.encntr_id
	cnt += 1
	if (mod(cnt,10) = 1 or cnt = 1)
		stat = alterlist(pat->plist, cnt + 9)
	endif
	pat->rec_cnt = cnt
	pat->plist[cnt].facility = uar_get_code_display(sa.appt_location_cd)
	pat->plist[cnt].encntrid = sa.encntr_id
	pat->plist[cnt].personid = sa.person_id
      pat->plist[cnt].sch_appt_dt = sa.beg_dt_tm
      interp_req_tmp_var = ' '
Head sed.oe_field_id
	case(sed.oe_field_id)
		of sch_interp_req_var:
			call echo(build2('req_var1 - oe_field_display_value = ', sed.oe_field_display_value))
			if(sed.oe_field_display_value = 'Yes - Deaf/HOH')
				interp_req_tmp_var = sed.oe_field_display_value
				call echo(build2('interp_req_tmp_var = ', interp_req_tmp_var ))
				pat->plist[cnt].sch_interp_req = sed.oe_field_display_value
				pat->plist[cnt].sch_interp_req_dt = sed.beg_effective_dt_tm
			endif
		of sch_interp_typ_var:	
			if(interp_req_tmp_var = 'Yes - Deaf/HOH')  
				call echo(build2('type_var - oe_field_display_value = ', sed.oe_field_display_value))

				if((sed.oe_field_display_value = 'Video Device') or (sed.oe_field_display_value = 'Live Interpreter requested')
				    or(sed.oe_field_display_value = 'Yes With STRATUS') or (sed.oe_field_display_value = 'Yes With LIVE'))
						pat->plist[cnt].sch_interp_type = sed.oe_field_display_value
				endif	
			endif	
	endcase
Foot report
	stat = alterlist(pat->plist, cnt)

with nocounter


call echorecord(pat)
go to exitscript

;----------------------------------------------------------------------------------------------------------------
/*
select into $outdev
e.person_id, e.encntr_id, p.name_full_formatted

from encounter e
	, person p
	;, encntr_alias ea

plan e where operator(e.loc_facility_cd, opr_fac_var, $facility_list)
	;and e.arrive_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.active_ind = 1
	
join p where p.person_id = e.person_id
	and p.active_ind = 1	
	
/*join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1	*/
	
;order by e.loc_facility_cd, e.encntr_id

;with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000
;go to exitscript

/*

Head report
	cnt = 0
Head e.encntr_id
	cnt += 1
	if (mod(cnt,10) = 1 or cnt = 1)
		stat = alterlist(pat->plist, cnt + 9)
	endif
	pat->rec_cnt = cnt
	pat->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	pat->plist[cnt].pat_name = p.name_full_formatted
	;pat->plist[cnt].fin = trim(ea.alias)
	pat->plist[cnt].encntrid = e.encntr_id
	pat->plist[cnt].personid = e.person_id
Foot report
	stat = alterlist(pat->plist, cnt)
WITH nocounter

;--------------------------------------------------------------------------------------------------------------
;Scheduling

select into $outdev
sa.encntr_id, sa.person_id, sa.appt_location_cd
,sed.oe_field_display_value, sed.beg_effective_dt_tm,sed.updt_dt_tm, sed.oe_field_id, ofm.description
from  sch_appt sa
	, sch_event_detail sed
	, oe_field_meaning ofm

plan sa where expand(num, 1,pat->rec_cnt, sa.encntr_id, pat->plist[num].encntrid)
	and sa.active_ind = 1

join sed where sed.sch_event_id = sa.sch_event_id
	and sed.oe_field_id in(sch_interp_req_var, sch_interp_typ_var)
	and sed.active_ind = 1

join ofm where ofm.oe_field_meaning_id = sed.oe_field_meaning_id

order by sa.encntr_id, sa.sch_event_id, sed.oe_field_id

with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000
go to exitscript


/*
Head sa.encntr_id
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,pat->rec_cnt ,sa.encntr_id ,pat->plist[icnt].encntrid)
      interp_tmp_var = ' '
      pat->plist[idx].sch_appt_dt = sa.beg_dt_tm
Head sed.oe_field_id
	case(sed.oe_field_id)
		of sch_interp_req_var:
			if(sed.oe_field_display_value = 'Yes - Deaf/HOH')
				interp_tmp_var = sed.oe_field_display_value
				pat->plist[idx].sch_interp_res = sed.oe_field_display_value
				pat->plist[idx].sch_interp_req_dt = sed.beg_effective_dt_tm
			endif
		of sch_interp_typ_var:	
			if(interp_tmp_var = 'Yes - Deaf/HOH')
				pat->plist[idx].sch_interp_type = sed.oe_field_display_value
			endif	
	endcase
with nocounter, expand = 1	
*/

;--------------------------------------------------------------------------------------------------------------

;Nursing
select into $outdev
ce.encntr_id, ce.event_id, ce.result_val, ce.event_id, ce.parent_event_id, ce.verified_dt_tm ';;q'
,ce2.parent_event_id, ce2.result_val, ce2.verified_dt_tm ';;q'

from clinical_event ce2
, clinical_event ce
, (left join clinical_event ce3 on ce3.encntr_id = ce.encntr_id
	and ce3.parent_event_id = ce.parent_event_id
	and ce3.event_cd = value(uar_get_code_by("DISPLAY", 72, "Interpreter Services for:"));patient/companion	
	and ce3.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce3.result_status_cd IN (23.00, 34.00, 25.00, 35.00))

plan ce where expand(num, 1,pat->rec_cnt, ce.encntr_id, pat->plist[num].encntrid)
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
		where ce1.encntr_id = ce.encntr_id
		and ce1.event_cd = value(uar_get_code_by("DISPLAY", 72, "Requested Communication Tools"))
		and ( 
			( (ce1.result_val = 'Video interpretation') or (ce1.result_val = '*Video interpretation')
				or (ce1.result_val = '*Video interpretation*') or (ce1.result_val = 'Video interpretation*') 
			)
		    OR((ce1.result_val = 'In-person interpretation') or (ce1.result_val = '*In-person interpretation')
		    		or (ce1.result_val = '*In-person interpretation*') or (ce1.result_val = 'In-person interpretation*')
		    	)	
		    OR((ce1.result_val = 'Telephone interpretation') or (ce1.result_val = '*Telephone interpretation')
		    		or (ce1.result_val = '*Telephone interpretation*') or (ce1.result_val = 'Telephone interpretation*')
		    	)
		    )		
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
		and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
		group by ce1.encntr_id, ce1.event_cd)
	
join ce2 where ce2.encntr_id = ce.encntr_id
	and ce2.parent_event_id = ce.parent_event_id
	and ce2.event_cd = value(uar_get_code_by("DISPLAY", 72, "Lang/Communication/Education Barriers"))
	and ((ce2.result_val  = 'Deaf') or (ce2.result_val  = '*Deaf') or (ce2.result_val  = 'Deaf*') or (ce2.result_val  = '*Deaf*'))
	and ce2.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce2.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	
join ce3
	
order by ce.encntr_id, ce.parent_event_id, ce.verified_dt_tm desc	

Head ce.encntr_id
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,pat->rec_cnt ,ce.encntr_id ,pat->plist[icnt].encntrid)
Head ce.parent_event_id
	pat->plist[idx].nu_interp_res = ce2.result_val
	pat->plist[idx].nu_interp_req_dt = ce.event_end_dt_tm
	pat->plist[idx].nu_interp_type = ce.result_val
	pat->plist[idx].nu_interp_service_for = ce3.result_val ;patient/companion
with nocounter, expand = 1	

;go to exitscript
;--------------------------------------------------------------------------------------------------------------
;Interpreter Service Provided
;Lori to get with Debi - charted time or service begin time (not in build yet)

select into $outdev
ce.encntr_id, ce.event_id, ce.result_val, ce.parent_event_id, ce.verified_dt_tm ';;q'

from clinical_event ce

plan ce where expand(num, 1,pat->rec_cnt, ce.encntr_id, pat->plist[num].encntrid)
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
		where ce1.encntr_id = ce.encntr_id
		and ce1.event_cd = value(uar_get_code_by("DISPLAY", 72, "Interpreter Services")) ;document & test - geetha
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
		and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
		group by ce1.encntr_id, ce1.event_cd)

order by ce.encntr_id, ce.parent_event_id, ce.verified_dt_tm desc	

Head ce.encntr_id
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,pat->rec_cnt ,ce.encntr_id ,pat->plist[icnt].encntrid)
Head ce.parent_event_id
	pat->plist[idx].interp_response_dt = ce.event_end_dt_tm
with nocounter, expand = 1

;--------------------------------------------------------------------------------------------------------------
;Registration
/*
select into "nl:"
lang_disp = trim(uar_get_code_display(pt.n_language_cd))
from 
person_patient pp	, pm_transaction pt
plan pt where pt.n_person_id = trigger_personid
	and pt.n_language_cd = value(uar_get_code_by("DISPLAY", 36, "Sign Language"))
join pp where pp.person_id = pt.n_person_id
	and pp.interp_required_cd = value(uar_get_code_by("DISPLAY", 329, "Yes"))

*/

;--------------------------------------------------------------------------------------------------------------

call echorecord(pat)	
	
;--------------------------------------------------------------------------------------------------------------	

select into $outdev
	facility = substring(1, 30, pat->plist[d1.seq].facility)
	, fin = substring(1, 30, pat->plist[d1.seq].fin)
	, patient_name = substring(1, 50, pat->plist[d1.seq].pat_name)
	, encntrid = pat->plist[d1.seq].encntrid
	, scheduled_dt = pat->plist[d1.seq].sch_appt_dt ';;q'
	, sch_interpreter_response = substring(1, 100, pat->plist[d1.seq].sch_interp_res)
	, sch_interpreter_request_dt = pat->plist[d1.seq].sch_interp_req_dt ';;q'
	, sch_interpreter_type = substring(1, 30, pat->plist[d1.seq].sch_interp_type)
	, reg_interpreter_response = substring(1, 100, pat->plist[d1.seq].reg_interp_res)
	, reg_interpreter_req_dt = pat->plist[d1.seq].reg_interp_req_dt ';;q'
	, reg_interpreter_type = substring(1, 30, pat->plist[d1.seq].reg_interp_type)
	, nursing_interpreter_response = substring(1, 100, pat->plist[d1.seq].nu_interp_res)
	, nursing_interpreter_req_dt = pat->plist[d1.seq].nu_interp_req_dt ';;q'
	, nursing_interpreter_type = substring(1, 30, pat->plist[d1.seq].nu_interp_type)
	, interpreter_response_dt = pat->plist[d1.seq].interp_response_dt ';;q'
	, reason_no_service = substring(1, 1000, pat->plist[d1.seq].reason_no_service)
	, employee_decision_no_service = substring(1, 100, pat->plist[d1.seq].pr_no_service_decision)

from
	(dummyt   d1  with seq = size(pat->plist, 5))

plan d1 where ( trim(substring(1, 100, pat->plist[d1.seq].nu_interp_res)) != ' '
			or trim(substring(1, 100, pat->plist[d1.seq].sch_interp_res)) != ' '
			or trim(substring(1, 100, pat->plist[d1.seq].reg_interp_res)) != ' ' )


order by facility, fin

with nocounter, separator=" ", format


#exitscript

end
go


;with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000


/*


select 
e.loc_facility_cd, e.reg_dt_tm, ce1.encntr_id, ce1.result_val, ce1.event_end_dt_tm, ce1.event_cd
from clinical_event ce1, encounter e
where e.encntr_id = ce1.encntr_id
and ce1.event_end_dt_tm between cnvtdatetime("01-JUN-2022 00:00:00") AND cnvtdatetime("30-AUG-2022 23:59:00")
and ce1.event_cd in(3728458297.00, 3728426013.00)
;and ce1.event_cd = value(uar_get_code_by("DISPLAY", 72, "Lang/Communication/Education Barriers"))	
and ce1.result_val in('Deaf', 'Hearing impaired, left ear', 'Hearing impaired, right ear'
	,'Video interpretation', 'In-person interpretation', 'Telephone interpretation')
;value(uar_get_code_by("DISPLAY", 72, "Requested Communication Tools"))
;and ce1.result_val in('Video interpretation', 'In-person interpretation', 'Telephone interpretation')
and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
order by ce1.encntr_id, ce1.event_cd, ce1.verified_dt_tm desc
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1)


select * from clinical_event ce
where ce.event_id =  3654468855.00

*/

















