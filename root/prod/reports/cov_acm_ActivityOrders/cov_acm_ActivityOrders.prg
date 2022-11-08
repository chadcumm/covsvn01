/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		08/14/2020
	Solution:			Revenue Cycle - Acute Care Management
	Source file name:	cov_acm_ActivityOrders.prg
	Object name:		cov_acm_ActivityOrders
	Request #:			6520
 
	Program purpose:	Lists patients and their activity orders.
 
	Executing from:		CCL
 
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	11/03/2022	Todd A. Blanchard		Added Cumberland Medical Center to prompt.
 
******************************************************************************/
 
drop program cov_acm_ActivityOrders:DBA go
create program cov_acm_ActivityOrders:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility" = 0
	, "Nurse Unit" = 0
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE" 

with OUTDEV, facility, nurse_unit, start_datetime, end_datetime
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare mrn_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "MRN"))
declare fin_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare patient_activity_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 106, "PATIENTACTIVITY"))
declare activity_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 16389, "ACTIVITY"))
declare inpatient_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "INPATIENT"))
declare observation_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "OBSERVATION"))
declare outpatientinabed_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "OUTPATIENTINABED"))
declare discharged_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 261, "DISCHARGED"))
declare order_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "ORDER"))
declare nurseunits_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 222, "NURSEUNITS"))
declare dta_ambqual_var			= f8 with constant(1908507.00)

declare op_facility_var			= c2 with noconstant("")
declare op_nurseunit_var		= c2 with noconstant("")

declare num						= i4 with noconstant(0)
 
 
; define operator for $facility
if (substring(1, 1, reflect(parameter(parameter2($facility), 0))) = "L") ; multiple values selected
    set op_facility_var = "IN"
elseif (parameter(parameter2($facility), 1) = 0.0) ; any selected
    set op_facility_var = "!="
else ; single value selected
    set op_facility_var = "="
endif
 
; define operator for $nurse unit
if (substring(1, 1, reflect(parameter(parameter2($nurse_unit), 0))) = "L") ; multiple values selected
    set op_nurseunit_var = "IN"
elseif (parameter(parameter2($nurse_unit), 1) = 0.0) ; any selected
    set op_nurseunit_var = "!="
else ; single value selected
    set op_nurseunit_var = "="
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
record activity_data (
	1	p_facility			= vc
	1	p_nurseunit			= vc
	1	p_startdate			= vc
	1	p_enddate			= vc
 
	1	cnt					= i4
	1	list[*]
		2	encntr_id		= f8
		2	encntr_type		= c40
		2	encntr_status	= c40
		2	fin				= c20
		2	reg_dt_tm		= dq8
		2	disch_dt_tm		= dq8
		
		2	person_id		= f8
		2	patient_name	= c100
		2	dob				= dq8
		2	dob_tz			= i4
		
		2	loc_cnt					= i4
		2	loc_hist[*]
			3	encntr_loc_hist_id	= f8
			3	facility			= c40
			3	nurse_unit			= c40
			3	room				= c40
			3	bed					= c40
			3	activity_dt_tm		= dq8
		
		2	order_cnt				= i4
		2	orders[*]
			3	order_id			= f8
			3	order_mnemonic		= c100
			3	order_dt_tm			= dq8
			3	order_status		= c40
			3	ordering_physician	= c100
		
		2	dta_cnt					= i4
		2	dtas[*]
			3	event_id			= f8
			3	mnemonic			= c50
			3	result_val			= c255
			3	performed_dt_tm		= dq8
			3	performed_prsnl		= c100
)
 
/**************************************************************/
; set prompt data
set activity_data->p_facility	= cnvtstring($facility)
set activity_data->p_nurseunit	= cnvtstring($nurse_unit)
set activity_data->p_startdate	= $start_datetime
set activity_data->p_enddate	= $end_datetime
 
 
/**************************************************************/
; select encounter data
select into "NL:" 
from
	ENCOUNTER e
		
	, (inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = fin_var
		and ea.end_effective_dt_tm > sysdate
		and ea.active_ind = 1)
		
	, (inner join PERSON p on p.person_id = e.person_id
		and p.active_ind = 1)

where
	e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.encntr_type_cd in (inpatient_var, observation_var, outpatientinabed_var)
	and e.encntr_status_cd not in (discharged_var)
	and operator(e.loc_facility_cd, op_facility_var, $facility)
;	and operator(e.loc_nurse_unit_cd, op_nurseunit_var, $nurse_unit)
	and e.loc_bed_cd > 0.0
	and e.active_ind = 1
		
order by
	e.encntr_id
 
 
; populate activity_data record structure
head report
	cnt = 0
 
head e.encntr_id
	cnt = cnt + 1
 
	call alterlist(activity_data->list, cnt)
 
	activity_data->cnt							= cnt 
	activity_data->list[cnt].encntr_id			= e.encntr_id
	activity_data->list[cnt].encntr_type		= uar_get_code_display(e.encntr_type_cd)
	activity_data->list[cnt].encntr_status		= uar_get_code_display(e.encntr_status_cd)
	activity_data->list[cnt].fin				= ea.alias
	activity_data->list[cnt].reg_dt_tm			= e.reg_dt_tm
	activity_data->list[cnt].disch_dt_tm		= e.disch_dt_tm
	
	activity_data->list[cnt].person_id			= p.person_id
	activity_data->list[cnt].patient_name		= p.name_full_formatted
	activity_data->list[cnt].dob				= p.birth_dt_tm
	activity_data->list[cnt].dob_tz				= p.birth_tz
 
WITH nocounter, time = 120
 
 
/**************************************************************/
; select location history data
select into "NL:" 
from
	ENCNTR_LOC_HIST elh
	
	, (inner join LOCATION l on l.location_cd = elh.loc_nurse_unit_cd
		and l.location_type_cd = nurseunits_var
		and l.active_ind = 1)

where
	expand(num, 1, activity_data->cnt, elh.encntr_id, activity_data->list[num].encntr_id)
	and operator(elh.loc_nurse_unit_cd, op_nurseunit_var, $nurse_unit)
	and elh.active_ind = 1
		
order by
	elh.encntr_id
	, elh.encntr_loc_hist_id
 
 
; populate activity_data record structure
head elh.encntr_id
	numx = 0
	idx = 0
	lcnt = 0
 
	idx = locateval(numx, 1, activity_data->cnt, elh.encntr_id, activity_data->list[numx].encntr_id)
	
detail
	lcnt = lcnt + 1
 
	call alterlist(activity_data->list[idx].loc_hist, lcnt)
	
	activity_data->list[idx].loc_cnt							= lcnt 
	activity_data->list[idx].loc_hist[lcnt].encntr_loc_hist_id	= elh.encntr_loc_hist_id
	activity_data->list[idx].loc_hist[lcnt].facility			= uar_get_code_display(elh.loc_facility_cd)
	
	activity_data->list[idx].loc_hist[lcnt].nurse_unit			= 
		replace(replace(uar_get_code_display(elh.loc_nurse_unit_cd), char(13), ""), char(10), "")
			
	activity_data->list[idx].loc_hist[lcnt].room				= uar_get_code_display(elh.loc_room_cd)
	activity_data->list[idx].loc_hist[lcnt].bed					= uar_get_code_display(elh.loc_bed_cd)
	activity_data->list[idx].loc_hist[lcnt].activity_dt_tm		= elh.activity_dt_tm
 
WITH nocounter, expand = 1, time = 120

;call echorecord(activity_data)
 
 
/**************************************************************/
; select activity orders data
select distinct into "NL:" 
from
	ORDERS o
 
	, (inner join ORDER_ACTION oa on oa.order_id = o.order_id
		and oa.action_type_cd = order_var
		and oa.action_sequence > 0)
 
	, (inner join PRSNL per_oa on per_oa.person_id = oa.order_provider_id
		and per_oa.active_ind = 1)

where
	expand(num, 1, activity_data->cnt, o.encntr_id, activity_data->list[num].encntr_id)	
	and o.activity_type_cd = patient_activity_var
	and o.dcp_clin_cat_cd = activity_var
	and o.template_order_id = 0.0
	and o.active_ind = 1
		
order by
	o.encntr_id
;	, o.order_id
	, o.current_start_dt_tm
	, o.order_mnemonic
	, 0
 
 
; populate activity_data record structure
head o.encntr_id
	numx = 0
	idx = 0
	ocnt = 0
 
	idx = locateval(numx, 1, activity_data->cnt, o.encntr_id, activity_data->list[numx].encntr_id)

detail
	ocnt = ocnt + 1
 
	call alterlist(activity_data->list[idx].orders, ocnt)
	
	activity_data->list[idx].order_cnt							= ocnt 
	activity_data->list[idx].orders[ocnt].order_id				= o.order_id
	activity_data->list[idx].orders[ocnt].order_dt_tm			= o.current_start_dt_tm
	activity_data->list[idx].orders[ocnt].order_mnemonic		= o.order_mnemonic	
	activity_data->list[idx].orders[ocnt].order_status			= uar_get_code_display(o.order_status_cd)
	activity_data->list[idx].orders[ocnt].ordering_physician	= trim(per_oa.name_full_formatted, 3)
 
WITH nocounter, expand = 1, time = 120

;call echorecord(activity_data)
 
 
/**************************************************************/
; select clinical event data
select into "NL:" 
from
	CLINICAL_EVENT ce
	
	, (inner join DISCRETE_TASK_ASSAY dta on dta.task_assay_cd = ce.task_assay_cd
		and dta.active_ind = 1)
 
	, (inner join PRSNL per on per.person_id = ce.performed_prsnl_id
		and per.active_ind = 1)

where
	expand(num, 1, activity_data->cnt, ce.encntr_id, activity_data->list[num].encntr_id)	
	and ce.task_assay_cd = dta_ambqual_var
	and ce.valid_until_dt_tm > sysdate
	
order by
	ce.encntr_id
 
 
; populate activity_data record structure
head ce.encntr_id
	numx = 0
	idx = 0
	dcnt = 0
 
	idx = locateval(numx, 1, activity_data->cnt, ce.encntr_id, activity_data->list[numx].encntr_id)

detail
	dcnt = dcnt + 1
 
	call alterlist(activity_data->list[idx].dtas, dcnt)
	
	activity_data->list[idx].dta_cnt						= dcnt 
	activity_data->list[idx].dtas[dcnt].event_id			= ce.event_id
	activity_data->list[idx].dtas[dcnt].mnemonic			= dta.mnemonic
	activity_data->list[idx].dtas[dcnt].result_val			= ce.result_val
	activity_data->list[idx].dtas[dcnt].performed_dt_tm		= ce.performed_dt_tm
	activity_data->list[idx].dtas[dcnt].performed_prsnl		= trim(per.name_full_formatted, 3)
 
WITH nocounter, expand = 1, time = 120

call echorecord(activity_data)
 
 
/**************************************************************/
; select data
select into $OUTDEV
	patient_name			= activity_data->list[d1.seq].patient_name
;	, patient_id			= activity_data->list[d1.seq].person_id
	, dob					= format(cnvtdatetimeutc(datetimezone(activity_data->list[d1.seq].dob, 
								activity_data->list[d1.seq].dob_tz), 1), "mm/dd/yyyy;;d")
								
	, fin					= activity_data->list[d1.seq].fin
	, admit_dt_tm			= format(activity_data->list[d1.seq].reg_dt_tm, "mm/dd/yyyy hh:mm;;q")
;	, encntr_id				= activity_data->list[d1.seq].encntr_id
	, encntr_type			= activity_data->list[d1.seq].encntr_type
	, encntr_status			= activity_data->list[d1.seq].encntr_status
	
	, facility				= activity_data->list[d1.seq].loc_hist[d2.seq].facility
	, nurse_unit			= activity_data->list[d1.seq].loc_hist[d2.seq].nurse_unit
	, room					= activity_data->list[d1.seq].loc_hist[d2.seq].room
	, bed					= activity_data->list[d1.seq].loc_hist[d2.seq].bed
	, loc_hist_dt_tm		= format(activity_data->list[d1.seq].loc_hist[d2.seq].activity_dt_tm, "mm/dd/yyyy hh:mm;;q")
	
	, activity_order		= activity_data->list[d1.seq].orders[d3.seq].order_mnemonic
	, order_dt_tm			= format(activity_data->list[d1.seq].orders[d3.seq].order_dt_tm, "mm/dd/yyyy hh:mm;;q")
	, order_status			= activity_data->list[d1.seq].orders[d3.seq].order_status
	, ordering_physician	= activity_data->list[d1.seq].orders[d3.seq].ordering_physician
	
	, dta_mnemonic			= activity_data->list[d1.seq].dtas[d4.seq].mnemonic
	, performed_dt_tm		= format(activity_data->list[d1.seq].dtas[d4.seq].performed_dt_tm, "mm/dd/yyyy hh:mm;;q")
	, performed_by			= activity_data->list[d1.seq].dtas[d4.seq].performed_prsnl
	, result_val			= activity_data->list[d1.seq].dtas[d4.seq].result_val
    
from
	(dummyt d1 with seq = value(activity_data->cnt))
	, (dummyt d2 with seq = 1)
	, (dummyt d3 with seq = 1)
	, (dummyt d4 with seq = 1)
 
plan d1 
where 
	maxrec(d2, activity_data->list[d1.seq].loc_cnt)
	and maxrec(d3, activity_data->list[d1.seq].order_cnt)
	and maxrec(d4, activity_data->list[d1.seq].dta_cnt)

join d2
join d3
join d4
 
order by
	activity_data->list[d1.seq].reg_dt_tm
	, activity_data->list[d1.seq].loc_hist[d2.seq].activity_dt_tm
	, facility
	, nurse_unit
	, room
	, bed
	, patient_name
	, activity_data->list[d1.seq].person_id
	, activity_data->list[d1.seq].orders[d3.seq].order_dt_tm
	, activity_data->list[d1.seq].dtas[d4.seq].performed_dt_tm
 
with nocounter, outerjoin = d3, separator = " ", format, time = 60
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go

