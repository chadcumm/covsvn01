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
----------	-----------------------------------------------------------------
09-21-22    Geetha         Initial release as an excel format
******************************************************************************/

drop program cov_phq_deaf_hoh_interp_log:dba go
create program cov_phq_deaf_hoh_interp_log:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Start Reg Date/Time" = "SYSDATE"
	, "End  Reg Date/Time" = "SYSDATE"
	, "Select Facility" = 0 

with OUTDEV, start_datetime, end_datetime, facility_list



/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/


declare comm_assess_var = f8 with constant(value(uar_get_code_by('DISPLAY', 72, 'Communication Assessment Form'))), protect

;3911149319.00	Communication Assessment Form


declare reg_interp_req_var       = f8 with constant(23290423.00) 
declare sch_interp_req_var       = f8 with constant(25789963.00)
declare sch_bh_interp_reason_var = f8 with constant(4462417097.00)
declare sch_interp_typ_var       = f8 with constant(4462353769.00)
declare sch_bh_interp_typ_var    = f8 with constant(2562479461.00)

/* Variables based on Description
declare reg_interp_req_var       = vc with constant('Interpreter Required')
declare sch_interp_req_var       = vc with constant('Sch Interpreter')
declare sch_bh_interp_reason_var = vc with constant('Sch BH Interpreter reason')
declare sch_interp_typ_var       = vc with constant('Sch Interpreter type')
declare sch_bh_interp_typ_var    = vc with constant('Sch BH Interpreter')*/

/* oe_field_id         Codeset   Description
   23290423.00	        329	Interpreter Required
   25789963.00	     104051	Sch Interpreter
  4462417097.00	     100540	Sch BH Interpreter reason 
 4462353769.00	     100538	Sch Interpreter Type
 2562479461.00	     100360	Sch BH Interpreter ;BH Type
*/


declare interp_req_tmp_var = vc with noconstant('')
declare bh_interp_req_tmp_var = vc with noconstant('')

declare cnt = i4 with noconstant(0)
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

;---------------------------------------------------------------------

Record pat(
	1 rec_cnt = i4
	1 plist[*]
		2 facility = f8
		2 pat_name = vc
		2 fin = vc
		2 personid = f8
		2 encntrid = f8
		2 sch_appt_dt = dq8
		2 sch_eventid = f8
		2 sch_interp_req = vc
		2 sch_interp_req_dt = dq8
		2 sch_interp_type = vc
		2 reg_dt = f8
		2 reg_interp_res = vc
		2 reg_interp_required = vc
		2 reg_interp_req_dt = dq8
		2 reg_interp_type = vc
		2 nu_interp_res = vc
		2 nu_interp_req_dt = dq8
		2 nu_interp_type = vc
		2 nu_interp_service_for = vc ;patient/companion
		2 nu_interp_service_dt = dq8
		2 nu_typ_service_provided = vc
		2 reason_no_service = vc
		2 pr_no_service_decision = vc
		2 comm_assess_form = vc
)		


/**************************************************************
; DVDev Start Coding
**************************************************************/

;Patient Population - Reg

select into $outdev
e.person_id, e.encntr_id, p.name_full_formatted, e.arrive_dt_tm ';;q', e.reg_dt_tm ';;q'

from encounter e
	, person p
	, encntr_alias ea

plan e where operator(e.loc_facility_cd, opr_fac_var, $facility_list)
	and e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	;and e.arrive_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.active_ind = 1
	
join p where p.person_id = e.person_id
	and p.active_ind = 1	
	
join ea where ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1	
	
order by e.loc_facility_cd, e.encntr_id

Head report
	cnt = 0
Head e.encntr_id
	cnt += 1
	if (mod(cnt,10) = 1 or cnt = 1)
		stat = alterlist(pat->plist, cnt + 9)
	endif
	pat->rec_cnt = cnt
	pat->plist[cnt].facility = e.loc_facility_cd
	pat->plist[cnt].pat_name = p.name_full_formatted
	pat->plist[cnt].fin = trim(ea.alias)
	pat->plist[cnt].encntrid = e.encntr_id
	pat->plist[cnt].personid = e.person_id
	pat->plist[cnt].reg_dt = e.reg_dt_tm
Foot report
	stat = alterlist(pat->plist, cnt)
WITH nocounter

;-------------------------------------------------------------------------------------------------------------	
;Scheduled appt dt

select into $outdev
sa.appt_location_cd, sa.encntr_id, sa.person_id,sa.beg_dt_tm, sa.sch_event_id, sa.beg_dt_tm ';;q'

from sch_appt sa
	
plan sa where expand(num, 1, pat->rec_cnt, sa.encntr_id, pat->plist[num].encntrid)
	and sa.active_ind = 1
	and sa.sch_state_cd = value(uar_get_code_by("DISPLAY", 14233, "Confirmed"))
	and sa.sch_role_cd = value(uar_get_code_by("DISPLAY", 14250, "Patient"))

order by sa.encntr_id	

Head sa.encntr_id
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,pat->rec_cnt ,sa.encntr_id ,pat->plist[icnt].encntrid)
	if(idx > 0)
      	pat->plist[idx].sch_appt_dt = sa.beg_dt_tm
      endif	
with nocounter, expand = 1

;-------------------------------------------------------------------------------------------------------------	
;Scheduling
	
select into $outdev
sa.appt_location_cd, sa.encntr_id, sa.person_id,sa.beg_dt_tm, sa.sch_event_id, sa.beg_dt_tm ';;q'
, deaf_response = sed.oe_field_display_value, interp_type = sed1.oe_field_display_value

from sch_appt sa
	, sch_event_detail sed
	, sch_event_detail sed1
	
plan sa where expand(num, 1, pat->rec_cnt, sa.encntr_id, pat->plist[num].encntrid)
	and sa.active_ind = 1
	and sa.sch_state_cd = value(uar_get_code_by("DISPLAY", 14233, "Confirmed"))
	and sa.sch_role_cd = value(uar_get_code_by("DISPLAY", 14250, "Patient"))

join sed where sed.sch_event_id = sa.sch_event_id
	and sed.oe_field_display_value = 'Yes - Deaf/HOH'
	and sed.active_ind = 1	
	and sed.oe_field_id in(sch_interp_req_var, sch_bh_interp_reason_var)
		;and oef.description in('Sch Interpreter', 'Sch BH Interpreter reason')
		
join sed1 where sed1.sch_event_id = sed.sch_event_id
	and ((sed1.oe_field_display_value = 'Video Device') or (sed1.oe_field_display_value = 'Live Interpreter requested')
	    or(sed1.oe_field_display_value = 'Yes With STRATUS') or (sed1.oe_field_display_value = 'Yes With LIVE'))
	and sed1.active_ind = 1
	and sed1.oe_field_id in(sch_interp_typ_var, sch_bh_interp_typ_var)
		;and oef.description in('Sch Interpreter Type','Sch BH Interpreter')

order by sa.encntr_id, sed.sch_event_id, sed.oe_field_id, sed1.oe_field_id

Head sa.encntr_id
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,pat->rec_cnt ,sa.encntr_id ,pat->plist[icnt].encntrid)
      interp_req_tmp_var = ' ', bh_interp_req_tmp_var = ' '
Head sed.oe_field_id
	case(sed.oe_field_id)
		of sch_interp_req_var:
			if(sed.oe_field_display_value = 'Yes - Deaf/HOH')
				interp_req_tmp_var = sed.oe_field_display_value
				pat->plist[idx].sch_interp_req = sed.oe_field_display_value
				pat->plist[idx].sch_interp_req_dt = sed.beg_effective_dt_tm
			endif
		of sch_bh_interp_reason_var:
			if(sed.oe_field_display_value = 'Yes - Deaf/HOH')
				bh_interp_req_tmp_var = sed.oe_field_display_value
				pat->plist[idx].sch_interp_req = sed.oe_field_display_value
				pat->plist[idx].sch_interp_req_dt = sed.beg_effective_dt_tm
			endif
	endcase
Head sed1.oe_field_id
	case(sed1.oe_field_id)
		of sch_interp_typ_var:	
			if(interp_req_tmp_var = 'Yes - Deaf/HOH')  
				if((sed1.oe_field_display_value = 'Video Device')
			   		or (sed1.oe_field_display_value = 'Live Interpreter requested'))
			    		pat->plist[idx].sch_interp_type = sed1.oe_field_display_value
				endif	
			endif	
		of sch_bh_interp_typ_var:	
			if(bh_interp_req_tmp_var = 'Yes - Deaf/HOH')  
				if((sed1.oe_field_display_value = 'Yes With STRATUS') or (sed1.oe_field_display_value = 'Yes With LIVE'))
					pat->plist[idx].sch_interp_type = sed1.oe_field_display_value
				endif	
			endif	
	endcase
Foot report
	stat = alterlist(pat->plist, cnt)

with nocounter, expand = 1

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

;--------------------------------------------------------------------------------------------------------------
;Interpreter Service Provided
;Lori to get with Debi - charted time or service begin time (not in build yet)

select into $outdev
ce.encntr_id, ce.event_id, ce.result_val, ce.parent_event_id, ce.verified_dt_tm ';;q'

from clinical_event ce

plan ce where expand(num, 1,pat->rec_cnt, ce.encntr_id, pat->plist[num].encntrid)
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
		where ce1.encntr_id = ce.encntr_id
		;and ce1.event_cd = value(uar_get_code_by("DISPLAY", 72, "Interpreter Services")) ;document & test - geetha
		and ce1.event_cd = value(uar_get_code_by("DISPLAY", 72, "Interpreter Agency Name")) 
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
		and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
		group by ce1.encntr_id, ce1.event_cd)

order by ce.encntr_id, ce.parent_event_id, ce.verified_dt_tm desc	

Head ce.encntr_id
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,pat->rec_cnt ,ce.encntr_id ,pat->plist[icnt].encntrid)
Head ce.parent_event_id
	pat->plist[idx].nu_typ_service_provided = ce.result_val
	pat->plist[idx].nu_interp_service_dt = ce.event_end_dt_tm
with nocounter, expand = 1

;--------------------------------------------------------------------------------------------------------------
;Registration

select into "nl:"
lang_disp = trim(uar_get_code_display(pt.n_language_cd))
, interp_required = trim(uar_get_code_display(pp.interp_required_cd))

from  pm_transaction pt
	, person_patient pp	
	
plan pt where expand(num, 1,pat->rec_cnt, pt.n_person_id, pat->plist[num].personid)
	and pt.n_language_cd = value(uar_get_code_by("DISPLAY", 36, "Sign Language"))

join pp where pp.person_id = pt.n_person_id
	and pp.interp_required_cd = value(uar_get_code_by("DISPLAY", 329, "Yes"))

order by pp.person_id

Head pp.person_id
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,pat->rec_cnt ,pt.n_person_id, pat->plist[icnt].personid)
	if(idx > 0)
		pat->plist[idx].reg_interp_res = lang_disp
		pat->plist[idx].reg_interp_required = interp_required
		pat->plist[idx].reg_interp_req_dt = pt.n_reg_dt_tm
	endif
with nocounter, expand = 1		

;--------------------------------------------------------------------------------------------------------------
;Communication Assessment Form completion

select into $outdev

from clinical_event ce

plan ce where expand(num, 1,pat->rec_cnt, ce.encntr_id, pat->plist[num].encntrid)
	and ce.event_cd = comm_assess_var
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
		where ce1.encntr_id = ce.encntr_id
		and ce1.event_cd = ce.event_cd
		and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
		and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
		group by ce1.encntr_id, ce1.event_cd)

order by ce.encntr_id

Head ce.encntr_id
	icnt = 0
	idx = 0
      idx = locateval(icnt ,1 ,pat->rec_cnt ,ce.encntr_id ,pat->plist[icnt].encntrid)
	if(idx > 0)
		pat->plist[idx].comm_assess_form = uar_get_code_display(ce.event_cd)
	endif	
with nocounter, expand = 1

;--------------------------------------------------------------------------------------------------------------

call echorecord(pat)	
	
;--------------------------------------------------------------------------------------------------------------	

select into $outdev
	facility = uar_get_code_display(pat->plist[d1.seq].facility)
	, fin = substring(1, 30, pat->plist[d1.seq].fin)
	, patient_name = substring(1, 50, pat->plist[d1.seq].pat_name)
	, encntrid = pat->plist[d1.seq].encntrid
	, scheduled_dt = pat->plist[d1.seq].sch_appt_dt ';;q'
	, sch_interpreter_response = substring(1, 100, pat->plist[d1.seq].sch_interp_req)
	, sch_interpreter_request_dt = pat->plist[d1.seq].sch_interp_req_dt ';;q'
	, sch_interpreter_type = substring(1, 30, pat->plist[d1.seq].sch_interp_type)
	, reg_dt_tm = pat->plist[d1.seq].reg_dt ';;q'
	, reg_interpreter_response = substring(1, 100, pat->plist[d1.seq].reg_interp_res)
	, reg_interpreter_req_dt = pat->plist[d1.seq].reg_interp_req_dt ';;q'
	, reg_interpreter_type = substring(1, 30, pat->plist[d1.seq].reg_interp_type)
	, nu_communication_barrier = substring(1, 100, pat->plist[d1.seq].nu_interp_res)
	, nu_requested_communication_type = substring(1, 30, pat->plist[d1.seq].nu_interp_type)
	, nu_interpreter_req_dt = pat->plist[d1.seq].nu_interp_req_dt ';;q'
	, nature_of_service_provided = pat->plist[d1.seq].nu_typ_service_provided
	, service_provided_dt = pat->plist[d1.seq].nu_interp_service_dt ';;q'
	, reason_no_service = substring(1, 1000, pat->plist[d1.seq].reason_no_service)
	, employee_decision_no_service = substring(1, 100, pat->plist[d1.seq].pr_no_service_decision)
	, form_on_chart = substring(1, 100, pat->plist[d1.seq].comm_assess_form)

from
	(dummyt   d1  with seq = size(pat->plist, 5))

plan d1 where ( trim(substring(1, 100, pat->plist[d1.seq].nu_interp_res)) != ' '
			or trim(substring(1, 100, pat->plist[d1.seq].sch_interp_req)) != ' '
			or trim(substring(1, 100, pat->plist[d1.seq].reg_interp_res)) != ' ' 
			or trim(substring(1, 100, pat->plist[d1.seq].comm_assess_form)) != ' ' )

order by facility, fin

with nocounter, separator=" ", format


#exitscript

end
go


;with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000



















