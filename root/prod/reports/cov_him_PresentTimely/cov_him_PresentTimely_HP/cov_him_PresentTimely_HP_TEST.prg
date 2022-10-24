/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		12/10/2020
	Solution:			Revenue Cycle - HIM
	Source file name:	cov_him_PresentTimely_HP.prg
	Object name:		cov_him_PresentTimely_HP
	Request #:			8332, 8720, 11087, 12728
 
	Program purpose:	Lists data for presence and timeliness of 
						history and physical report.
 
	Executing from:		CCL
 
 	Special Notes:		Report Type:
 							1 - IP/OB
 							2 - Day Surgery/OP Bed
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
001	10/29/2021	Todd A. Blanchard		Added prompt for facility.
										Added medical service columns.
002	03/04/2022	Todd A. Blanchard		Corrected issue with empty record structure.
003	05/03/2022	Todd A. Blanchard		Adjusted logic for timeliness rules.
										Added WQM documents.
 
******************************************************************************/
 
drop program cov_him_PresentTimely_HP_TEST:dba go
create program cov_him_PresentTimely_HP_TEST:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Facility" = VALUE(0.0            )
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Report Type" = 1 

with OUTDEV, facility, start_datetime, end_datetime, report_type
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare inerror_var					= f8 with constant(uar_get_code_by("MEANING", 8, "INERROR")), protect
declare anticipated_var				= f8 with constant(uar_get_code_by("MEANING", 8, "ANTICIPATED")), protect
declare sign_action_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 21, "SIGN")), protect
declare perform_action_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 21, "PERFORM")), protect
declare root_var					= f8 with constant(uar_get_code_by("MEANING", 24, "ROOT")), protect
declare child_var					= f8 with constant(uar_get_code_by("MEANING", 24, "CHILD")), protect
declare otg_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 25, "OTG")), protect
declare mdoc_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 53, "MDOC")), protect
declare doc_var						= f8 with constant(uar_get_code_by("DISPLAYKEY", 53, "DOC")), protect
declare date_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 53, "DATE")), protect
declare daysurgery_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "DAYSURGERY")), protect
declare inpatient_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "INPATIENT")), protect
declare observation_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "OBSERVATION")), protect
declare outpatientinabed_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "OUTPATIENTINABED")), protect
declare scheduled_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 71, "SCHEDULED")), protect
declare histphys_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "HISTORYANDPHYSICAL")), protect
declare histphysupd_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "HISTORYANDPHYSICALUPDATE")), protect
declare patient_in_holding_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "SNHOLDINGCTMPATIENTINHOLDING")), protect
declare covenant_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 73, "COVENANT")), protect ;001
declare psoadmittoinpatient_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 200, "PSOADMITTOINPATIENT")), protect
declare psoobservation_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 200, "PSOOBSERVATION")), protect
declare adjpsoadmittoinpatient_var	= f8 with constant(uar_get_code_by("DISPLAYKEY", 200, "ADJUSTMENTPSOADMITTOINPATIENT")), protect
declare adjpsoobservation_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 200, "ADJUSTMENTPSOOBSERVATION")), protect
declare eddecisiontoadmit_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 200, "EDDECISIONTOADMIT")), protect
declare admitphysician_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 333, "ADMITTINGPHYSICIAN")), protect
declare undefined_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 29520, "UNDEFINED")), protect
declare provider_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 254571, "PROVIDER")), protect

declare op_facility_var				= vc with noconstant(fillstring(2, " ")) ;001
declare op_encntr_type_var			= vc with noconstant("1 = 1"), protect
declare num							= i4 with noconstant(0), protect
 
; define operator for $facility ;001
if (substring(1, 1, reflect(parameter(parameter2($facility), 0))) = "L") ; multiple values selected
    set op_facility_var = "IN"
elseif (parameter(parameter2($facility), 1) = 0.0) ; any selected
    set op_facility_var = "!="
else ; single value selected
    set op_facility_var = "="
endif
 
; define encounter type filter
if ($report_type = 1)
	set op_encntr_type_var = "e.encntr_type_cd in (inpatient_var, observation_var)"
 
elseif ($report_type = 2)
	set op_encntr_type_var = "e.encntr_type_cd in (daysurgery_var, outpatientinabed_var)"

endif


/**************************************************************
; DVDev Start Coding
**************************************************************/

free record hpdata
record hpdata (
	1 cnt							= i4
	1 qual [*]
		2 event_id					= f8
		2 event_cd					= f8
		2 event_class_cd			= f8
		2 encntr_id					= f8
		2 encntr_type_cd			= f8
		2 med_service_cd			= f8 ;001
		2 person_id					= f8
		2 arrive_dt_tm				= dq8 ;003
		2 reg_dt_tm					= dq8
		2 admit_physician_id		= f8
		2 performed_dt_tm			= dq8
		2 performed_prsnl_id		= f8
		2 result_status_cd			= f8
		2 result_dt_tm				= dq8
		2 entry_mode_cd				= f8
		2 storage_cd				= f8

		2 upd_cnt						= i4
		2 updates [*]
			3 upd_event_id				= f8
			3 upd_event_cd				= f8
			3 upd_event_class_cd		= f8
			3 upd_performed_dt_tm		= dq8
			3 upd_performed_prsnl_id	= f8
			3 upd_performed_by			= c100
			3 upd_result_status_cd		= f8
			3 upd_result_dt_tm			= dq8
			3 upd_entry_mode_cd			= f8
			3 upd_storage_cd			= f8
		
		; pso order - first
		2 pso_order_id					= f8
		2 pso_catalog_cd				= f8
		2 pso_oe_field_dt_tm_value		= dq8
		
		; pso order - most recent
		2 pso_last_order_id					= f8
		2 pso_last_catalog_cd				= f8
		2 pso_last_oe_field_dt_tm_value		= dq8
		
;		; ed order
;		2 ed_order_id				= f8
;		2 ed_catalog_cd				= f8
;		2 ed_oe_field_dt_tm_value	= dq8
		
		; patient in holding
		2 patient_in_holding_dt_tm	= dq8
	
		2 surg_case_id				= f8
		2 surgeon_prsnl_id			= f8
		2 surgeon					= c100
		2 surg_start_dt_tm			= dq8
		
		; indicators for compliance logic
		2 is_anticipated				= i2
		2 is_scanned					= i2
		
		2 admit_dt_tm					= dq8
		2 hp_dt_tm						= dq8
		2 hpupd_dt_tm					= dq8
		
		2 has_surgery					= i2
		
		2 hp_within_30days_admit		= i2
		2 hp_within_24hours_admit		= i2
		2 hp_prior_to_admit				= i2
		2 hp_after_admit				= i2
		2 hp_prior_to_surgery			= i2
		
		2 is_hpupd_required				= i2
		2 has_hpupd						= i2
		2 hpupd_within_24hours_admit	= i2
		2 hpupd_after_admit				= i2
		2 hpupd_prior_to_surgery		= i2
		
		2 is_hp_timely					= i2
		2 is_hpupd_timely				= i2
		
		2 is_hp_compliant				= i2
		2 is_hp_surgery_compliant		= i2
		2 is_hp_surgery_na				= i2
		
		2 is_compliant					= i2
)
with persistscript
 
 
/**************************************************************/ 
; select history and physical data
select into "nl:"
from
	CLINICAL_EVENT ce
 
	, (inner join CE_EVENT_PRSNL cep on cep.event_id = ce.event_id
		and cep.action_type_cd = perform_action_var
		and cep.valid_until_dt_tm >= cnvtdatetime(curdate, curtime))
		
	, (inner join CLINICAL_EVENT ce2 on ce2.encntr_id = ce.encntr_id
		and ce2.parent_event_id = ce.parent_event_id
		and ce2.event_cd = histphys_var
		and ce2.event_class_cd = doc_var
		and ce2.event_reltn_cd = child_var
		and ce2.result_status_cd != inerror_var
		and ce2.valid_until_dt_tm > cnvtdatetime(curdate, curtime))
	
	, (left join CE_BLOB_RESULT cbr on cbr.event_id = ce2.event_id
		and cbr.storage_cd = otg_var
		and cbr.valid_until_dt_tm > cnvtdatetime(curdate, curtime))
	
	, (inner join ENCOUNTER e on e.encntr_id = ce.encntr_id
		and operator(e.organization_id, op_facility_var, $facility) ;001	
		and parser(op_encntr_type_var)
		and e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
		and e.active_ind = 1)
		
	, (left join ENCNTR_PRSNL_RELTN epr on epr.encntr_id = e.encntr_id
		and epr.encntr_prsnl_r_cd = admitphysician_var
		and epr.active_ind = 1)
		
	, (inner join PERSON p on p.person_id = e.person_id
		and p.name_last_key not in ("ZZZ*")
		and p.active_ind = 1)

where
	ce.event_cd = histphys_var
	and ce.event_class_cd = mdoc_var
	and ce.event_reltn_cd = root_var
	and ce.result_status_cd != inerror_var
	and ce.valid_until_dt_tm > cnvtdatetime(curdate, curtime)
	
order by
	ce.encntr_id
	, ce.performed_dt_tm
	, ce.event_end_dt_tm
	 	 
; populate record structure
head report
	cnt = 0
	
head ce.encntr_id
	cnt = cnt + 1
	
	call alterlist(hpdata->qual, cnt)
	
	hpdata->cnt 								= cnt
	hpdata->qual[cnt].event_id					= ce.event_id
	hpdata->qual[cnt].event_cd					= ce.event_cd
	hpdata->qual[cnt].event_class_cd			= ce.event_class_cd
	hpdata->qual[cnt].encntr_id					= ce.encntr_id
	hpdata->qual[cnt].encntr_type_cd			= e.encntr_type_cd
	hpdata->qual[cnt].med_service_cd			= e.med_service_cd ;001
	hpdata->qual[cnt].person_id					= ce.person_id
	hpdata->qual[cnt].arrive_dt_tm				= e.arrive_dt_tm ;003
	hpdata->qual[cnt].reg_dt_tm					= e.reg_dt_tm
	hpdata->qual[cnt].admit_physician_id		= epr.prsnl_person_id
	hpdata->qual[cnt].performed_dt_tm			= ce.performed_dt_tm
	hpdata->qual[cnt].performed_prsnl_id		= ce.performed_prsnl_id
	hpdata->qual[cnt].result_status_cd			= ce.result_status_cd
	hpdata->qual[cnt].result_dt_tm				= ce.event_end_dt_tm
	hpdata->qual[cnt].entry_mode_cd				= ce2.entry_mode_cd
	hpdata->qual[cnt].storage_cd				= cbr.storage_cd
	
	; indicators
	hpdata->qual[cnt].is_anticipated = evaluate(hpdata->qual[cnt].result_status_cd, anticipated_var, 1, 0)
	
	hpdata->qual[cnt].is_scanned = evaluate(hpdata->qual[cnt].storage_cd, 0.0, 0, 1)
	
	if ($report_type = 1) ;003
		hpdata->qual[cnt].admit_dt_tm = hpdata->qual[cnt].arrive_dt_tm ;003
	else
		hpdata->qual[cnt].admit_dt_tm = hpdata->qual[cnt].reg_dt_tm
	endif
	
	if (hpdata->qual[cnt].is_scanned)
		hpdata->qual[cnt].hp_dt_tm = hpdata->qual[cnt].result_dt_tm
	else
		hpdata->qual[cnt].hp_dt_tm = hpdata->qual[cnt].performed_dt_tm
	endif
	
with nocounter, time = 180

call echo(">>>select history and physical data")
;call echorecord(hpdata)
 
 
/**************************************************************/ 
; select wqm history and physical data ;003
select into "nl:"
from
	CDI_TRANS_LOG ctl
	
	, (inner join CLINICAL_EVENT ce on ce.event_id = ctl.event_id
		and ce.event_cd = histphys_var
		and ce.event_class_cd = doc_var
		and ce.event_reltn_cd = child_var
		and ce.result_status_cd != inerror_var
		and ce.valid_until_dt_tm > cnvtdatetime(curdate, curtime))
		
	, (inner join CLINICAL_EVENT ce2 on ce2.encntr_id = ce.encntr_id
		and ce2.parent_event_id = ce.parent_event_id
		and ce2.event_cd = histphys_var
		and ce2.event_class_cd = mdoc_var
		and ce2.event_reltn_cd = root_var
		and ce2.result_status_cd != inerror_var
		and ce2.valid_until_dt_tm > cnvtdatetime(curdate, curtime))
;	
	, (left join CE_BLOB_RESULT cbr on cbr.event_id = ce2.event_id
		and cbr.storage_cd = otg_var
		and cbr.valid_until_dt_tm > cnvtdatetime(curdate, curtime))
	
	, (inner join ENCOUNTER e on e.encntr_id = ctl.encntr_id
		and operator(e.organization_id, op_facility_var, $facility)	
		and parser(op_encntr_type_var)
		and e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
		and e.active_ind = 1)
		
	, (left join ENCNTR_PRSNL_RELTN epr on epr.encntr_id = e.encntr_id
		and epr.encntr_prsnl_r_cd = admitphysician_var
		and epr.active_ind = 1)
		
	, (inner join PERSON p on p.person_id = e.person_id
		and p.name_last_key not in ("ZZZ*")
		and p.active_ind = 1)

where
	ctl.active_ind = 1
	
order by
	ctl.encntr_id
	, ctl.event_id
;	, ce.performed_dt_tm
;	, ce.event_end_dt_tm
	 	 
; populate record structure
head report
	cnt = hpdata->cnt
	
head ctl.encntr_id
	cnt = cnt + 1
	
	call alterlist(hpdata->qual, cnt)
	
	hpdata->cnt 								= cnt
	hpdata->qual[cnt].event_id					= ce.event_id
	hpdata->qual[cnt].event_cd					= ce.event_cd
	hpdata->qual[cnt].event_class_cd			= ce.event_class_cd
	hpdata->qual[cnt].encntr_id					= ce.encntr_id
	hpdata->qual[cnt].encntr_type_cd			= e.encntr_type_cd
	hpdata->qual[cnt].med_service_cd			= e.med_service_cd
	hpdata->qual[cnt].person_id					= ce.person_id
	hpdata->qual[cnt].arrive_dt_tm				= e.arrive_dt_tm
	hpdata->qual[cnt].reg_dt_tm					= e.reg_dt_tm
	hpdata->qual[cnt].admit_physician_id		= epr.prsnl_person_id
	hpdata->qual[cnt].performed_dt_tm			= ce.performed_dt_tm
	hpdata->qual[cnt].performed_prsnl_id		= ce.performed_prsnl_id
	hpdata->qual[cnt].result_status_cd			= ce.result_status_cd
	hpdata->qual[cnt].result_dt_tm				= ce.event_end_dt_tm
	hpdata->qual[cnt].entry_mode_cd				= ce2.entry_mode_cd
	hpdata->qual[cnt].storage_cd				= cbr.storage_cd
	
	; indicators
	hpdata->qual[cnt].is_anticipated = evaluate(hpdata->qual[cnt].result_status_cd, anticipated_var, 1, 0)
	
	hpdata->qual[cnt].is_scanned = evaluate(hpdata->qual[cnt].storage_cd, 0.0, 0, 1)
	
	if ($report_type = 1)
		hpdata->qual[cnt].admit_dt_tm = hpdata->qual[cnt].arrive_dt_tm
	else
		hpdata->qual[cnt].admit_dt_tm = hpdata->qual[cnt].reg_dt_tm
	endif
	
	if ((hpdata->qual[cnt].is_scanned) or (ce2.entry_mode_cd = undefined_var))
		hpdata->qual[cnt].hp_dt_tm = hpdata->qual[cnt].result_dt_tm
	else
		hpdata->qual[cnt].hp_dt_tm = hpdata->qual[cnt].performed_dt_tm
	endif
	
with nocounter, time = 180

call echo(">>>select wqm history and physical data")
;call echorecord(hpdata)

;go to exitscript
 

;/**************************************************************/
;; select order data - ed ;003
;if (hpdata->cnt > 0) ;002
;	select into "nl:"
;	from
;		ORDERS o
;			
;		, (inner join ORDER_DETAIL od on od.order_id = o.order_id
;			and od.oe_field_meaning in ("REQSTARTDTTM", "INPTADMDTETME")
;			and od.detail_sequence = (
;				select 
;					min(detail_sequence)
;				from ORDER_DETAIL 
;				where 
;					order_id = od.order_id
;					and oe_field_meaning in ("REQSTARTDTTM", "INPTADMDTETME")
;				group by 
;					order_id
;			))
;			
;		, (dummyt d1 with seq = value(hpdata->cnt))
;		
;	plan d1
;	
;	join o
;	join od
;		
;	where
;		o.encntr_id = hpdata->qual[d1.seq].encntr_id
;		and o.catalog_cd in (eddecisiontoadmit_var)
;		and o.active_ind = 1
;		
;	order by
;		o.encntr_id
;		, o.order_id
;		
;	; populate record structure	
;	head o.encntr_id
;		hpdata->qual[d1.seq].ed_order_id				= o.order_id
;		hpdata->qual[d1.seq].ed_catalog_cd				= o.catalog_cd
;		hpdata->qual[d1.seq].ed_oe_field_dt_tm_value	= od.oe_field_dt_tm_value
;			
;		; perform indicators
;		if ($report_type = 1)
;			hpdata->qual[d1.seq].admit_dt_tm = hpdata->qual[d1.seq].ed_oe_field_dt_tm_value
;		endif
;			
;	with nocounter, time = 180
;endif
;
;call echorecord(hpdata)
 
 
/**************************************************************/
; select order data - first order - observation only - pso
if (hpdata->cnt > 0) ;002
	select into "nl:"
	from
		ORDERS o
			
		, (inner join ORDER_DETAIL od on od.order_id = o.order_id
			and od.oe_field_meaning in ("REQSTARTDTTM", "INPTADMDTETME")
			and od.detail_sequence = (
				select 
					min(detail_sequence)
				from ORDER_DETAIL 
				where 
					order_id = od.order_id
					and oe_field_meaning in ("REQSTARTDTTM", "INPTADMDTETME")
				group by 
					order_id
			))
			
		, (dummyt d1 with seq = value(hpdata->cnt))
		
	plan d1
	
	join o
	join od
		
	where
		o.encntr_id = hpdata->qual[d1.seq].encntr_id
		and o.catalog_cd in (
			psoobservation_var;, psoadmittoinpatient_var, ;003
			;adjpsoobservation_var, adjpsoadmittoinpatient_var ;003
		)
		and o.active_ind = 1
		
	order by
		o.encntr_id
		, o.order_id
		
	; populate record structure	
	head o.encntr_id
;		if (o.catalog_cd = psoobservation_var) ;003
			hpdata->qual[d1.seq].pso_order_id					= o.order_id ;003
			hpdata->qual[d1.seq].pso_catalog_cd					= o.catalog_cd ;003
			hpdata->qual[d1.seq].pso_oe_field_dt_tm_value		= od.oe_field_dt_tm_value ;003
			
;			; perform indicators ;003
;			if ($report_type = 1)
;				hpdata->qual[d1.seq].admit_dt_tm = hpdata->qual[d1.seq].oe_field_dt_tm_value
;			endif
;		endif ;003
		
	with nocounter, time = 180
endif

call echo(">>>select order data - first order - observation only - pso")
;call echorecord(hpdata)
 
 
/**************************************************************/
; select order data - most recent order - pso
if (hpdata->cnt > 0) ;002
	select into "nl:"
	from
		ORDERS o
			
		, (inner join ORDER_DETAIL od on od.order_id = o.order_id
			and od.oe_field_meaning in ("REQSTARTDTTM", "INPTADMDTETME")
			and od.detail_sequence = (
				select 
					min(detail_sequence)
				from ORDER_DETAIL 
				where 
					order_id = od.order_id
					and oe_field_meaning in ("REQSTARTDTTM", "INPTADMDTETME")
				group by 
					order_id
			))
			
		, (dummyt d1 with seq = value(hpdata->cnt))
		
	plan d1
	
	join o
	join od
		
	where
		o.encntr_id = hpdata->qual[d1.seq].encntr_id
		and o.catalog_cd in (
			psoobservation_var, psoadmittoinpatient_var,
			adjpsoobservation_var, adjpsoadmittoinpatient_var
		)
		and o.active_ind = 1
		
	order by
		o.encntr_id
		, o.order_id desc
		
	; populate record structure
	head o.encntr_id
		hpdata->qual[d1.seq].pso_last_order_id					= o.order_id ;003
		hpdata->qual[d1.seq].pso_last_catalog_cd				= o.catalog_cd ;003
		hpdata->qual[d1.seq].pso_last_oe_field_dt_tm_value		= od.oe_field_dt_tm_value ;003
		
;		; perform indicators ;003
;		if ($report_type = 1)
;			hpdata->qual[d1.seq].admit_dt_tm = hpdata->qual[d1.seq].oe_field_dt_tm_value
;		endif
		
	with nocounter, time = 180
endif

call echo(">>>select order data - most recent order - pso")
;call echorecord(hpdata)
 
 
/**************************************************************/ 
; select patient in holding data
if (hpdata->cnt > 0) ;002
	select into "nl:"
	from
		CLINICAL_EVENT ce
			
		, (inner join CE_DATE_RESULT cdr on cdr.event_id = ce.event_id
			and cdr.valid_until_dt_tm >= cnvtdatetime(curdate, curtime))
			
		, (dummyt d1 with seq = value(hpdata->cnt))
		
	plan d1
	
	join ce
	join cdr
	
	where
		ce.encntr_id = hpdata->qual[d1.seq].encntr_id
		and ce.event_cd = patient_in_holding_var
		and ce.event_class_cd = date_var
		and ce.event_reltn_cd = child_var
		and ce.result_status_cd != inerror_var
		and ce.valid_until_dt_tm > cnvtdatetime(curdate, curtime)
		
	order by
		ce.encntr_id
		, ce.event_id
		 	 
	; populate record structure
	detail
		hpdata->qual[d1.seq].patient_in_holding_dt_tm = cdr.result_dt_tm
			
;		; perform indicators ;003
;		if ($report_type = 1)
;			hpdata->qual[d1.seq].admit_dt_tm = hpdata->qual[d1.seq].patient_in_holding_dt_tm
;		endif
		
	with nocounter, time = 180
endif

call echo(">>>select patient in holding data")
;call echorecord(hpdata)
 
 
/**************************************************************/ 
; select surgery data
if (hpdata->cnt > 0) ;002
	select into "nl:"
		sc.surg_case_id	
		, sc.encntr_id
		, sc.surgeon_prsnl_id
		, per.name_full_formatted
		, surg_start_dt_tm = min(sc.surg_start_dt_tm)
		
	from
		SURGICAL_CASE sc
		
		, (left join PRSNL per on sc.surgeon_prsnl_id = per.person_id
			and per.active_ind = 1)
			
		, (dummyt d1 with seq = value(hpdata->cnt))
		
	plan d1
	
	join sc
	join per
			
	where
		sc.encntr_id = hpdata->qual[d1.seq].encntr_id
		and sc.surg_start_dt_tm > cnvtdatetime("01-JAN-1970 000000")
		and sc.active_ind = 1
		
	group by
		sc.surg_case_id
		, sc.encntr_id
		, sc.surgeon_prsnl_id
		, per.name_full_formatted
		
	;order by
	;	sc.encntr_id
		
	; populate record structure
	detail
		hpdata->qual[d1.seq].surg_case_id		= sc.surg_case_id
		hpdata->qual[d1.seq].surg_start_dt_tm	= surg_start_dt_tm
		hpdata->qual[d1.seq].surgeon_prsnl_id	= sc.surgeon_prsnl_id
		hpdata->qual[d1.seq].surgeon			= per.name_full_formatted
		
		; indicators
		hpdata->qual[d1.seq].has_surgery = evaluate(sc.surg_case_id, 0.0, 0, 1)
		
		if (hpdata->qual[d1.seq].has_surgery) 
			if (hpdata->qual[d1.seq].hp_dt_tm <= hpdata->qual[d1.seq].surg_start_dt_tm) 
				hpdata->qual[d1.seq].hp_prior_to_surgery = 1 
			endif
		endif
		
	with nocounter, time = 180
endif

call echo(">>>select surgery data")
;call echorecord(hpdata)
 
 
/**************************************************************/ 
; select indicator data
if (hpdata->cnt > 0) ;002
	select into "nl:"
	from
		(dummyt d1 with seq = value(hpdata->cnt))
		
	plan d1
	
	; populate record structure
	detail
		;003		
		if ($report_type = 1)
			if ((hpdata->qual[d1.seq].patient_in_holding_dt_tm > 0) and 
				(hpdata->qual[d1.seq].patient_in_holding_dt_tm < hpdata->qual[d1.seq].admit_dt_tm))
				hpdata->qual[d1.seq].admit_dt_tm = hpdata->qual[d1.seq].patient_in_holding_dt_tm		
			endif
			
			if ((hpdata->qual[d1.seq].pso_oe_field_dt_tm_value > 0) and
				(hpdata->qual[d1.seq].pso_oe_field_dt_tm_value < hpdata->qual[d1.seq].admit_dt_tm))
				hpdata->qual[d1.seq].admit_dt_tm = hpdata->qual[d1.seq].pso_oe_field_dt_tm_value
			else
				if ((hpdata->qual[d1.seq].pso_last_oe_field_dt_tm_value > 0) and
					(hpdata->qual[d1.seq].pso_last_oe_field_dt_tm_value < hpdata->qual[d1.seq].admit_dt_tm))
					hpdata->qual[d1.seq].admit_dt_tm = hpdata->qual[d1.seq].pso_last_oe_field_dt_tm_value
				endif
			endif
		endif
	
		if (datetimediff(hpdata->qual[d1.seq].hp_dt_tm,	hpdata->qual[d1.seq].admit_dt_tm, 1) <= 30) 
			hpdata->qual[d1.seq].hp_within_30days_admit = 1 
		endif
		
		if (datetimediff(hpdata->qual[d1.seq].hp_dt_tm, hpdata->qual[d1.seq].admit_dt_tm, 3) <= 24) 
			hpdata->qual[d1.seq].hp_within_24hours_admit = 1 
		endif
						 
		if (hpdata->qual[d1.seq].hp_dt_tm < hpdata->qual[d1.seq].admit_dt_tm) 
			hpdata->qual[d1.seq].hp_prior_to_admit = 1 
		endif
						 
		if (hpdata->qual[d1.seq].hp_dt_tm >= hpdata->qual[d1.seq].admit_dt_tm) 
			hpdata->qual[d1.seq].hp_after_admit = 1 
		endif
		
	with nocounter, time = 180
endif

call echo(">>>select indicator data")
;call echorecord(hpdata)
 
 
/**************************************************************/ 
; select history and physical update data
if (hpdata->cnt > 0) ;002
	select distinct into "nl:"
	from
		CLINICAL_EVENT ce
	 
		, (inner join CE_EVENT_PRSNL cep on cep.event_id = ce.event_id
			and cep.action_type_cd = perform_action_var
			and cep.valid_until_dt_tm >= cnvtdatetime(curdate, curtime))
		
		, (left join CE_BLOB_RESULT cbr on cbr.event_id = ce.event_id
			and cbr.storage_cd = otg_var
			and cbr.valid_until_dt_tm > cnvtdatetime(curdate, curtime))
			
		, (inner join PRSNL per on per.person_id = ce.performed_prsnl_id
			and per.active_ind = 1)
			
		, (dummyt d1 with seq = value(hpdata->cnt))
		
	plan d1
	
	join ce
	join cep
	join cbr
	join per
	
	where
		ce.encntr_id = hpdata->qual[d1.seq].encntr_id
		and ce.event_cd = histphysupd_var
		and ce.event_class_cd = doc_var
		and ce.event_reltn_cd = child_var
		and ce.result_status_cd != inerror_var
		and ce.valid_until_dt_tm > cnvtdatetime(curdate, curtime)
		
	order by
		ce.encntr_id
		, ce.event_id
		 	 
	; populate record structure
	head ce.encntr_id
		upd_cnt = 0
	
	detail
		upd_cnt += 1
		
		call alterlist(hpdata->qual[d1.seq].updates, upd_cnt)
		
		hpdata->qual[d1.seq].upd_cnt									= upd_cnt
		hpdata->qual[d1.seq].updates[upd_cnt].upd_event_id				= ce.event_id
		hpdata->qual[d1.seq].updates[upd_cnt].upd_event_cd				= ce.event_cd
		hpdata->qual[d1.seq].updates[upd_cnt].upd_event_class_cd		= ce.event_class_cd
		hpdata->qual[d1.seq].updates[upd_cnt].upd_performed_dt_tm		= ce.performed_dt_tm
		hpdata->qual[d1.seq].updates[upd_cnt].upd_performed_prsnl_id	= ce.performed_prsnl_id
		hpdata->qual[d1.seq].updates[upd_cnt].upd_performed_by			= per.name_full_formatted
		hpdata->qual[d1.seq].updates[upd_cnt].upd_result_status_cd		= ce.result_status_cd
		hpdata->qual[d1.seq].updates[upd_cnt].upd_result_dt_tm			= ce.event_end_dt_tm
		hpdata->qual[d1.seq].updates[upd_cnt].upd_entry_mode_cd			= ce.entry_mode_cd
		hpdata->qual[d1.seq].updates[upd_cnt].upd_storage_cd			= cbr.storage_cd
		
		; indicators
		hpdata->qual[d1.seq].hpupd_dt_tm = hpdata->qual[d1.seq].updates[upd_cnt].upd_performed_dt_tm
		
		if (hpdata->qual[d1.seq].hp_within_30days_admit and hpdata->qual[d1.seq].hp_prior_to_admit) 
			hpdata->qual[d1.seq].is_hpupd_required = 1 
		endif
		
		if (not hpdata->qual[d1.seq].hpupd_within_24hours_admit)
			if (datetimediff(hpdata->qual[d1.seq].hpupd_dt_tm, hpdata->qual[d1.seq].admit_dt_tm, 3) <= 24)
				hpdata->qual[d1.seq].hpupd_within_24hours_admit = 1 
			endif
		endif
		
		if (not hpdata->qual[d1.seq].hpupd_prior_to_surgery)
			if (hpdata->qual[d1.seq].has_surgery and hpdata->qual[d1.seq].is_hpupd_required)
				if (hpdata->qual[d1.seq].hpupd_dt_tm <= hpdata->qual[d1.seq].surg_start_dt_tm)				
					hpdata->qual[d1.seq].hpupd_prior_to_surgery = 1 
				endif
			endif
		endif
						 
		if (hpdata->qual[d1.seq].hpupd_dt_tm >= hpdata->qual[d1.seq].admit_dt_tm) 
			hpdata->qual[d1.seq].hpupd_after_admit = 1 
		endif
		
		if (hpdata->qual[d1.seq].is_hpupd_required)
			if (hpdata->qual[d1.seq].hpupd_after_admit and hpdata->qual[d1.seq].hpupd_within_24hours_admit)
				hpdata->qual[d1.seq].is_hpupd_timely = 1 
			endif
		endif
		
	foot ce.encntr_id
		hpdata->qual[d1.seq].has_hpupd = evaluate(upd_cnt, 0, 0, 1)
		
	with nocounter, time = 180
endif

call echo(">>>select history and physical update data")
;call echorecord(hpdata)


/**************************************************************/ 
; select wqm history and physical update data ;003
if (hpdata->cnt > 0)
	select distinct into "nl:"
	from
		CDI_TRANS_LOG ctl
		
		, (inner join CLINICAL_EVENT ce on ce.event_id = ctl.event_id
			and ce.event_cd = histphysupd_var
			and ce.event_class_cd = doc_var
			and ce.event_reltn_cd = child_var
			and ce.result_status_cd != inerror_var
			and ce.valid_until_dt_tm > cnvtdatetime(curdate, curtime))

		, (left join CE_BLOB_RESULT cbr on cbr.event_id = ce.event_id
			and cbr.storage_cd = otg_var
			and cbr.valid_until_dt_tm > cnvtdatetime(curdate, curtime))
				
		, (inner join PRSNL per on per.person_id = ce.performed_prsnl_id
			and per.active_ind = 1)
				
		, (dummyt d1 with seq = value(hpdata->cnt))

	plan d1
	
	join ctl
	join ce
	join cbr
	join per
	
	where
		ctl.encntr_id = hpdata->qual[d1.seq].encntr_id
		and ctl.active_ind = 1
	
	order by
		ctl.encntr_id
		, ctl.event_id
		 	 
	; populate record structure
	head ctl.encntr_id
		upd_cnt = hpdata->qual[d1.seq].upd_cnt
	
	detail
		upd_cnt += 1
		
		call alterlist(hpdata->qual[d1.seq].updates, upd_cnt)
		
		hpdata->qual[d1.seq].upd_cnt									= upd_cnt
		hpdata->qual[d1.seq].updates[upd_cnt].upd_event_id				= ce.event_id
		hpdata->qual[d1.seq].updates[upd_cnt].upd_event_cd				= ce.event_cd
		hpdata->qual[d1.seq].updates[upd_cnt].upd_event_class_cd		= ce.event_class_cd
		hpdata->qual[d1.seq].updates[upd_cnt].upd_performed_dt_tm		= ce.performed_dt_tm
		hpdata->qual[d1.seq].updates[upd_cnt].upd_performed_prsnl_id	= ce.performed_prsnl_id
		hpdata->qual[d1.seq].updates[upd_cnt].upd_performed_by			= per.name_full_formatted
		hpdata->qual[d1.seq].updates[upd_cnt].upd_result_status_cd		= ce.result_status_cd
		hpdata->qual[d1.seq].updates[upd_cnt].upd_result_dt_tm			= ce.event_end_dt_tm
		hpdata->qual[d1.seq].updates[upd_cnt].upd_entry_mode_cd			= ce.entry_mode_cd
		hpdata->qual[d1.seq].updates[upd_cnt].upd_storage_cd			= cbr.storage_cd
		
		; indicators
;		hpdata->qual[d1.seq].hpupd_dt_tm = hpdata->qual[d1.seq].updates[upd_cnt].upd_performed_dt_tm
	
		if (ce.entry_mode_cd = undefined_var)
			hpdata->qual[d1.seq].hpupd_dt_tm  = hpdata->qual[d1.seq].updates[upd_cnt].upd_result_dt_tm
		else
			hpdata->qual[d1.seq].hpupd_dt_tm  = hpdata->qual[d1.seq].updates[upd_cnt].upd_performed_dt_tm
		endif
		
		if (hpdata->qual[d1.seq].hp_within_30days_admit and hpdata->qual[d1.seq].hp_prior_to_admit) 
			hpdata->qual[d1.seq].is_hpupd_required = 1 
		endif
		
		if (not hpdata->qual[d1.seq].hpupd_within_24hours_admit)
			if (datetimediff(hpdata->qual[d1.seq].hpupd_dt_tm, hpdata->qual[d1.seq].admit_dt_tm, 3) <= 24)
				hpdata->qual[d1.seq].hpupd_within_24hours_admit = 1 
			endif
		endif
		
		if (not hpdata->qual[d1.seq].hpupd_prior_to_surgery)
			if (hpdata->qual[d1.seq].has_surgery and hpdata->qual[d1.seq].is_hpupd_required)
				if (hpdata->qual[d1.seq].hpupd_dt_tm <= hpdata->qual[d1.seq].surg_start_dt_tm)				
					hpdata->qual[d1.seq].hpupd_prior_to_surgery = 1 
				endif
			endif
		endif
						 
		if (hpdata->qual[d1.seq].hpupd_dt_tm >= hpdata->qual[d1.seq].admit_dt_tm) 
			hpdata->qual[d1.seq].hpupd_after_admit = 1 
		endif
		
		if (hpdata->qual[d1.seq].is_hpupd_required)
			if (hpdata->qual[d1.seq].hpupd_after_admit and hpdata->qual[d1.seq].hpupd_within_24hours_admit)
				hpdata->qual[d1.seq].is_hpupd_timely = 1 
			endif
		endif
		
	foot ctl.encntr_id
		hpdata->qual[d1.seq].has_hpupd = evaluate(upd_cnt, 0, 0, 1)

	with nocounter, time = 180
endif

call echo(">>>select wqm history and physical update data")
;call echorecord(hpdata)
 
 
/**************************************************************/ 
; select indicator data
if (hpdata->cnt > 0) ;002
	select into "nl:"
	from
		(dummyt d1 with seq = value(hpdata->cnt))
		
	plan d1
	
	; populate record structure
	detail
		if (hpdata->qual[d1.seq].has_surgery)
			if (hpdata->qual[d1.seq].hp_prior_to_surgery or hpdata->qual[d1.seq].hpupd_prior_to_surgery) 
				hpdata->qual[d1.seq].is_hp_surgery_compliant = 1
			endif
		else
			hpdata->qual[d1.seq].is_hp_surgery_na = 1
		endif
		
		if (not hpdata->qual[d1.seq].hp_prior_to_admit and not hpdata->qual[d1.seq].is_hpupd_required)
			if (hpdata->qual[d1.seq].hp_after_admit and hpdata->qual[d1.seq].hp_within_24hours_admit) 
				hpdata->qual[d1.seq].is_hp_timely = 1
			endif
		endif
		
		if (hpdata->qual[d1.seq].is_hp_timely or hpdata->qual[d1.seq].is_hpupd_timely) 
			hpdata->qual[d1.seq].is_hp_compliant = 1
		endif
	
		if (not hpdata->qual[d1.seq].is_anticipated)
			if (hpdata->qual[d1.seq].is_hp_compliant)
				if (hpdata->qual[d1.seq].is_hp_surgery_na or hpdata->qual[d1.seq].is_hp_surgery_compliant) 
					hpdata->qual[d1.seq].is_compliant = 1
				endif
			endif
		endif
		
	with nocounter, time = 180
endif

call echo(">>>select indicator data")
call echorecord(hpdata)
 
 
/**************************************************************/ 
; select data
select distinct into value($OUTDEV)
	patient_name			= p.name_full_formatted
	, fin					= ea.alias
;	, encntr_id				= hpdata->qual[d1.seq].encntr_id
	, encntr_type			= uar_get_code_display(hpdata->qual[d1.seq].encntr_type_cd)
	, med_service			= uar_get_code_display(hpdata->qual[d1.seq].med_service_cd) ;001
	, med_service_alias		= trim(cva.alias, 3) ;001
	, arrive_dt_tm			= hpdata->qual[d1.seq].arrive_dt_tm "mm/dd/yyyy hh:mm;;q" ;003
	, admit_dt_tm			= hpdata->qual[d1.seq].admit_dt_tm "mm/dd/yyyy hh:mm;;q"
	, admitting_phys		= per2.name_full_formatted
	, compliant_ind			= evaluate(hpdata->qual[d1.seq].is_compliant, 1, "Y", "N")
	
	; history and physicial
	, event					= uar_get_code_display(hpdata->qual[d1.seq].event_cd)
	, performed_dt_tm		= hpdata->qual[d1.seq].performed_dt_tm "mm/dd/yyyy hh:mm;;q"
	, performed_by			= per.name_full_formatted
	, result_status			= uar_get_code_display(hpdata->qual[d1.seq].result_status_cd)
	, result_dt_tm			= hpdata->qual[d1.seq].result_dt_tm "mm/dd/yyyy hh:mm;;q"
							  
	, entry_mode			= if (hpdata->qual[d1.seq].is_scanned)
								"Scanned Document"
							  elseif (hpdata->qual[d1.seq].entry_mode_cd = undefined_var)
							  	"WQM"
							  else
							  	uar_get_code_display(hpdata->qual[d1.seq].entry_mode_cd)
							  endif
							  								  
	; history and physicial update
	, update_event					= uar_get_code_display(hpdata->qual[d1.seq].updates[d2.seq].upd_event_cd)
	, update_performed_dt_tm		= hpdata->qual[d1.seq].updates[d2.seq].upd_performed_dt_tm "mm/dd/yyyy hh:mm;;q"
	, update_performed_by			= hpdata->qual[d1.seq].updates[d2.seq].upd_performed_by
	, update_result_status			= uar_get_code_display(hpdata->qual[d1.seq].updates[d2.seq].upd_result_status_cd)
	, update_result_dt_tm			= hpdata->qual[d1.seq].updates[d2.seq].upd_result_dt_tm "mm/dd/yyyy hh:mm;;q"
	, update_entry_mode				= uar_get_code_display(hpdata->qual[d1.seq].updates[d2.seq].upd_entry_mode_cd)
	
	; pso order ;003
	, pso_order_id				= hpdata->qual[d1.seq].pso_order_id
	, pso_catalog				= uar_get_code_display(hpdata->qual[d1.seq].pso_catalog_cd)
	, pso_order_dt_tm			= hpdata->qual[d1.seq].pso_oe_field_dt_tm_value "mm/dd/yyyy hh:mm;;q"
	
	; pso order - most recent ;003
	, pso_last_order_id			= hpdata->qual[d1.seq].pso_last_order_id
	, pso_last_catalog			= uar_get_code_display(hpdata->qual[d1.seq].pso_last_catalog_cd)
	, pso_last_order_dt_tm		= hpdata->qual[d1.seq].pso_last_oe_field_dt_tm_value "mm/dd/yyyy hh:mm;;q"
	
;	; ed order ;003
;	, ed_order_id				= hpdata->qual[d1.seq].ed_order_id
;	, ed_catalog				= uar_get_code_display(hpdata->qual[d1.seq].ed_catalog_cd)
;	, ed_order_dt_tm			= hpdata->qual[d1.seq].ed_oe_field_dt_tm_value "mm/dd/yyyy hh:mm;;q"
	
	; patient in holding
	, patient_in_holding_dt_tm		= hpdata->qual[d1.seq].patient_in_holding_dt_tm "mm/dd/yyyy hh:mm;;q"
							  
	; surgical case							  	
	, surgeon					= hpdata->qual[d1.seq].surgeon
	, surg_start_dt_tm			= hpdata->qual[d1.seq].surg_start_dt_tm "mm/dd/yyyy hh:mm;;q"
	
from
	(dummyt d1 with seq = value(hpdata->cnt))
	, ENCNTR_ALIAS ea
	, CODE_VALUE_ALIAS cva ;001
	, PERSON p
	, PRSNL per
	, PRSNL per2
	, (dummyt d2 with seq = 1)
     
plan d1
where
	maxrec(d2, hpdata->qual[d1.seq].upd_cnt)

join ea
where
	ea.encntr_id = hpdata->qual[d1.seq].encntr_id
	and ea.encntr_alias_type_cd = 1077.00 ; fin
	and ea.active_ind = 1

;001
join cva
where
	cva.code_value = outerjoin(hpdata->qual[d1.seq].med_service_cd)
	and cva.contributor_source_cd = outerjoin(covenant_var)

join p
where
	p.person_id = hpdata->qual[d1.seq].person_id
	and p.active_ind = 1
	
join per
where
	per.person_id = hpdata->qual[d1.seq].performed_prsnl_id
	and per.active_ind = 1
	
join per2
where
	per2.person_id = hpdata->qual[d1.seq].admit_physician_id
	and per2.active_ind = 1
	
join d2

order by
	patient_name
	, hpdata->qual[d1.seq].person_id
;	, encntr_id
	, hpdata->qual[d1.seq].performed_dt_tm
	, event
	, hpdata->qual[d1.seq].updates[d2.seq].upd_event_id

with nocounter, outerjoin = per, separator = " ", format, time = 180

 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/

#exitscript

end go
 
