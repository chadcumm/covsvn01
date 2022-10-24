/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		10/20/2022
	Solution:			Revenue Cycle - Scheduling Management
	Source file name:	cov_sm_Lirio_Mammo_Extract.prg
	Object name:		cov_sm_Lirio_Mammo_Extract
	Request #:			13718
 
	Program purpose:	Lists patients that qualify for mammography screenings.
 
	Executing from:		CCL
 
 	Special Notes:		Extract files will be used by vendor for targeted marketing.
 	
 						Files:
 							- contacts
 							- eligibility
 							- scheduling
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program cov_sm_Lirio_Mammo_Extract:DBA go
create program cov_sm_Lirio_Mammo_Extract:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility" = VALUE(0.0)
	, "Output To File" = 0                   ;* Output to file 

with OUTDEV, facility, output_file
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare min_age					= i4 with constant(40)
declare max_age					= i4 with constant(75)

declare start_year				= i4 with constant(datetimepart(cnvtagedatetime(max_age, 0, 0, 0), 1))
declare end_year				= i4 with constant(datetimepart(cnvtagedatetime(min_age, 0, 0, 0), 1))

declare cmrn_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 4, "COMMUNITYMEDICALRECORDNUMBER"))
declare phone_home_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 43, "HOME"))
declare phone_mobile_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 43, "MOBILE"))
declare female_birth_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 56, "FEMALE"))
declare female_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 57, "FEMALE"))
declare addr_home_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 212, "HOME"))
declare addr_email_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 212, "EMAIL"))
declare current_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 213, "CURRENT"))
declare yes_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 268, "YES"))
declare no_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 268, "NO"))
declare npi_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 320, "NATIONALPROVIDERIDENTIFIER"))
declare pcp_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 331, "PRIMARYCAREPHYSICIAN"))
declare employer_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 338, "EMPLOYER"))

declare order_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 6003, "ORDER"))
declare attach_type_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 16110, "ORDER"))
declare physician_order_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "PHYSICIANORDER"))
declare outside_order_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "OUTSIDEORDER"))

declare op_facility_var			= c2 with noconstant("")
declare num						= i4 with noconstant(0)
declare crlf					= vc with constant(build(char(13), char(10)))
 
declare file0_var				= vc with constant("?.csv")
declare file1_var				= vc with constant("?.csv")
declare file2_var				= vc with constant("?.csv")
declare file_var				= vc with constant("")
 
declare temppath_var			= vc with constant(build("cer_temp:", file_var))
declare temppath2_var			= vc with constant(build("$cer_temp/", file_var))
 
declare filepath_var			= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
														 "_cust/to_client_site/RevenueCycle/Scheduling/LirioExtracts/", file_var))
declare output_var				= vc with noconstant("")
 
declare cmd						= vc with noconstant("")
declare len						= i4 with noconstant(0)
declare stat					= i4 with noconstant(0)
 
 
; define output value
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set output_var = value(temppath_var)
else
	set output_var = value($OUTDEV)
endif
 
 
; define operator for $facility
if (substring(1, 1, reflect(parameter(parameter2($facility), 0))) = "L") ; multiple values selected
    set op_facility_var = "IN"
elseif (parameter(parameter2($facility), 1) = 0.0) ; any selected
    set op_facility_var = "!="
else ; single value selected
    set op_facility_var = "="
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
free record patient_data
record patient_data (
	1 p_min_age				= i4
	1 p_max_age				= i4
	1 p_start_year			= i4
	1 p_end_year			= i4
 
	1 cnt					= i4
	1 list[*] 
		2 person_id			= f8
		2 name_prefix		= c20
		2 name_first		= c50
		2 name_last			= c50
		2 name_suffix		= c20
		2 dob				= dq8
		2 dob_tz			= i4
		2 deceased			= i2
		2 birth_sex			= c12
		2 gender			= c12
		2 language			= c40
		
		2 cmrn				= c20
		
		2 email				= c100
		2 mobile_phone		= c10
		2 street_addr		= c100
		2 street_addr2		= c100
		2 city				= c100
		2 state				= c20
		2 zipcode			= c25
		
		2 employer			= c100
		2 title				= c100
		2 marital_status	= c40
		2 race				= c40
		2 religion			= c40
		
		2 channel_pref		= c40
		2 pcp_npi			= c20
		2 portal_username	= c20
		2 optout_ind		= i2
		2 rltn_ind			= c40
		2 consent_ind		= i2
		2 crm_id			= c10
)
 
 
/**************************************************************/
; populate record structure with prompt data
set patient_data->p_min_age		= min_age
set patient_data->p_max_age		= max_age
set patient_data->p_start_year	= start_year
set patient_data->p_end_year	= end_year


/**************************************************************/
; select patient data
select into "NL:"
from
	PERSON p
	
	, (left join PERSON_NAME pn on pn.person_id = p.person_id
		and pn.name_type_cd = current_var
		and pn.active_ind = 1)
	
	, (inner join PERSON_PATIENT pp on pp.person_id = p.person_id
		and pp.birth_sex_cd = female_birth_var
		and pp.active_ind = 1)
	
	, (inner join PERSON_ALIAS pa on pa.person_id = p.person_id
		and pa.person_alias_type_cd = cmrn_var
		and pa.active_ind = 1)
	
	, (inner join ADDRESS a on a.parent_entity_id = p.person_id
		and a.parent_entity_name = "PERSON"
		and a.address_type_cd = addr_home_var
		and a.zipcode_key in (
			"37772", "37902", "37909", "37916", "37919", "37921",
			"37922", "37923", "37931", "37932", "37934"
		)
		and a.active_ind = 1)
		
where
	year(p.birth_dt_tm) between start_year and end_year
	and p.deceased_cd in (no_var, 0.0)
	and p.active_ind = 1
	
order by
	p.person_id
	

; populate patient_data record structure
head report
	cnt = 0
 
	call alterlist(patient_data->list, 100)
 
head p.person_id
	cnt = cnt + 1
 
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(patient_data->list, cnt + 9)
	endif
 
	patient_data->cnt							= cnt
	patient_data->list[cnt].person_id			= p.person_id
	patient_data->list[cnt].name_prefix			= pn.name_prefix
	patient_data->list[cnt].name_first			= p.name_first
	patient_data->list[cnt].name_last			= p.name_last
	patient_data->list[cnt].name_suffix			= pn.name_suffix
	patient_data->list[cnt].dob					= p.birth_dt_tm
	patient_data->list[cnt].dob_tz				= p.birth_tz
	patient_data->list[cnt].deceased			= evaluate(p.deceased_cd, yes_var, 1, 0)
	patient_data->list[cnt].birth_sex			= uar_get_code_display(pp.birth_sex_cd)
	patient_data->list[cnt].gender				= uar_get_code_display(p.sex_cd)
	patient_data->list[cnt].language			= uar_get_code_display(p.language_cd)
	
	patient_data->list[cnt].cmrn				= cnvtalias(pa.alias, pa.alias_pool_cd)
	
	patient_data->list[cnt].street_addr			= a.street_addr
	patient_data->list[cnt].street_addr2		= a.street_addr2
	patient_data->list[cnt].city				= a.city
	patient_data->list[cnt].state				= a.state
	patient_data->list[cnt].zipcode				= a.zipcode
	
	patient_data->list[cnt].marital_status		= uar_get_code_display(p.marital_type_cd)
	patient_data->list[cnt].race				= uar_get_code_display(p.race_cd)
	patient_data->list[cnt].religion			= uar_get_code_display(p.religion_cd)
 
foot report
	call alterlist(patient_data->list, cnt)
 
with nocounter, time = 300
 
 
/**************************************************************/
; select email data
select into "NL:"
from
	ADDRESS a
	
where
	expand(num, 1, patient_data->cnt, a.parent_entity_id, patient_data->list[num].person_id)
	and a.parent_entity_name = "PERSON"
	and a.address_type_cd = addr_email_var
	and a.street_addr in ("*@*.*")
	and a.active_ind = 1

order by
	a.parent_entity_id
	

; populate patient_data record structure
head a.parent_entity_id
	idx = 0
	numx = 0
	
	idx = locateval(num, 1, patient_data->cnt, a.parent_entity_id, patient_data->list[num].person_id)

detail
	patient_data->list[idx].email = a.street_addr	

with nocounter, expand = 1, time = 300
 
 
/**************************************************************/
; select phone data
select into "NL:"
from
	PERSON p
	
	, (left join PHONE ph on ph.parent_entity_id = p.person_id
		and ph.parent_entity_name = "PERSON"
		and ph.phone_type_cd = phone_mobile_var
		and ph.phone_num_key not in (
			"0000000000", "1111111111", "2222222222", "3333333333",
			"4444444444", "5555555555", "6666666666", "7777777777",
			"8888888888", "9999999999", "1234567890"
		)
		and isnumeric(ph.phone_num_key) = 1
		and ph.active_ind = 1)
	
	, (left join PHONE ph2 on ph2.parent_entity_id = p.person_id
		and ph2.parent_entity_name = "PERSON"
		and ph2.phone_type_cd = phone_home_var
		and ph2.phone_num_key not in (
			"0000000000", "1111111111", "2222222222", "3333333333",
			"4444444444", "5555555555", "6666666666", "7777777777",
			"8888888888", "9999999999", "1234567890"
		)
		and isnumeric(ph2.phone_num_key) = 1
		and ph2.active_ind = 1)
	
where
	expand(num, 1, patient_data->cnt, p.person_id, patient_data->list[num].person_id)

order by
	p.person_id
	

; populate patient_data record structure
head p.person_id
	idx = 0
	numx = 0
	
	idx = locateval(num, 1, patient_data->cnt, p.person_id, patient_data->list[num].person_id)

detail
	patient_data->list[idx].mobile_phone = evaluate(textlen(ph.phone_num_key), 10, ph.phone_num_key, ph2.phone_num_key)

with nocounter, expand = 1, time = 300
 
 
/**************************************************************/
; select employer data
select into "NL:"
from
	PERSON_ORG_RELTN por
	
where
	expand(num, 1, patient_data->cnt, por.person_id, patient_data->list[num].person_id)
	and por.person_org_reltn_cd = employer_var
	and por.empl_status_cd > 0.0
	and por.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
	and por.active_ind = 1

order by
	por.person_id
	

; populate patient_data record structure
head por.person_id
	idx = 0
	numx = 0
	
	idx = locateval(num, 1, patient_data->cnt, por.person_id, patient_data->list[num].person_id)

detail
	patient_data->list[idx].employer		= por.ft_org_name
	patient_data->list[idx].title			= por.empl_title

with nocounter, expand = 1, time = 300


/**************************************************************/
; select pcp data
select into "NL:"
from
	PERSON_PRSNL_RELTN ppr
	
	, (inner join PRSNL per on per.person_id = ppr.prsnl_person_id
		and per.active_ind = 1)
	
	, (left join PRSNL_ALIAS pera on pera.person_id = per.person_id
		and pera.prsnl_alias_type_cd = npi_var
		and pera.active_ind = 1)
		
where
	expand(num, 1, patient_data->cnt, ppr.person_id, patient_data->list[num].person_id)
	and ppr.person_prsnl_r_cd = pcp_var
	and ppr.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
	and ppr.active_ind = 1

order by
	ppr.person_id
	

; populate patient_data record structure
head ppr.person_id
	idx = 0
	numx = 0
	
	idx = locateval(num, 1, patient_data->cnt, ppr.person_id, patient_data->list[num].person_id)

detail
	patient_data->list[idx].pcp_npi = pera.alias

with nocounter, expand = 1, time = 300


call echorecord(patient_data)
go to exitscript



;	patient_data->list[cnt].channel_pref		= ""
;	patient_data->list[cnt].portal_username		= ""
;	patient_data->list[cnt].optout_ind			= 0
;	patient_data->list[cnt].rltn_ind			= ""
;	patient_data->list[cnt].consent_ind			= 0
;	patient_data->list[cnt].crm_id				= ""

 
 
;/**************************************************************/
;; select scheduled procedures data ;006
;select into "NL:"
;from	
;	SCH_APPT sa
;	
;	, (inner join SCH_EVENT_ATTACH sea on sea.sch_event_id = sa.sch_event_id
;		and sea.attach_type_cd = attach_type_var
;		and sea.order_status_meaning not in ("CANCELED", "DISCONTINUED")
;		and sea.active_ind = 1)
;	
;;	, (left join SCH_ENTRY sen on sen.sch_event_id = sea.sch_event_id)
; 
;	, (inner join ORDERS o on o.order_id = sea.order_id
;		and o.active_ind = 1)
; 
;	, (left join ORDER_DETAIL od on od.order_id = o.order_id
;		and od.oe_field_meaning = "SCHEDAUTHNBR"
;		and od.action_sequence = (
;			select max(od12.action_sequence)
;			from ORDER_DETAIL od12 ;012
;			where 
;				od12.order_id = od.order_id
;				and od12.oe_field_meaning = "SCHEDAUTHNBR"
;			group by
;				od12.order_id
;		))
; 
;	, (left join PRSNL per_od on per_od.person_id = od.updt_id)
; 
;	, (left join ORDER_DETAIL od2 on od2.order_id = o.order_id
;		and od2.oe_field_meaning = "SURGEON1"
;		and od2.action_sequence = (
;			select max(od22.action_sequence)
;			from ORDER_DETAIL od22 ;012
;			where 
;				od22.order_id = od2.order_id
;				and od22.oe_field_meaning = "SURGEON1"
;			group by
;				od22.order_id
;		))
; 
;	, (left join ORDER_DETAIL od3 on od3.order_id = o.order_id
;		and od3.oe_field_meaning = "REQSTARTDTTM"
;		and od3.action_sequence = (
;			select max(od32.action_sequence)
;			from ORDER_DETAIL od32 ;012
;			where 
;				od32.order_id = od3.order_id
;				and od32.oe_field_meaning = "REQSTARTDTTM"
;			group by
;				od32.order_id
;		))
; 
; 	;006
;	, (left join ORDER_DETAIL od4 on od4.order_id = o.order_id
;		and od4.oe_field_meaning = "SPECINX"
;		and od4.action_sequence = (
;			select max(od42.action_sequence)
;			from ORDER_DETAIL od42 ;012
;			where 
;				od42.order_id = od4.order_id
;				and od42.oe_field_meaning = "SPECINX"
;			group by
;				od42.order_id
;		))
;				
;	, (left join OMF_RADMGMT_ORDER_ST oros on oros.order_id = o.order_id)
; 
;	, (left join ORDER_ACTION oa on oa.order_id = o.order_id
;		and oa.action_type_cd = order_var)
;		
;	, (left join ORDER_CATALOG ocat on ocat.catalog_cd = o.catalog_cd
;		and ocat.active_ind = 1)
;	
;	, (left join BILL_ITEM bi on bi.ext_parent_reference_id = ocat.catalog_cd
;		and bi.ext_parent_contributor_cd = contrib_var
;		and bi.ext_owner_cd = ocat.activity_type_cd
;		and bi.ext_child_reference_id = 0.0
;		and bi.parent_qual_cd = 1.0
;		and bi.active_ind = 1)
; 
;	, (left join BILL_ITEM_MODIFIER bim on bim.bill_item_id = bi.bill_item_id
;		and bim.bill_item_type_cd = bill_item_type_var
;		and bim.key1_id = cpt_var
;		and bim.beg_effective_dt_tm < cnvtdatetime(curdate, curtime3)
;		and bim.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
;		and bim.active_ind = 1)
;		
;	, (left join NOMENCLATURE n on n.nomenclature_id = bim.key3_id
;		and n.source_vocabulary_cd = cpt4_var
;		and n.active_ind = 1)
; 
;where
;	expand(num, 1, sched_appt->sched_cnt, sa.sch_appt_id, sched_appt->list[num].sch_appt_id,
;		sea.sch_event_id, sched_appt->list[num].sch_event_id) ;010
; 
;order by
;	sa.sch_appt_id
;	, sea.sch_event_id ;010
;	, o.order_id
; 
; 
;; populate sched_appt record structure with procedure data	
;head sa.sch_appt_id
;	cntx = 0
;	numx = 0
;	idx = 0
; 
;	idx = locateval(numx, 1, sched_appt->sched_cnt, sa.sch_appt_id, sched_appt->list[numx].sch_appt_id,
;		sea.sch_event_id, sched_appt->list[numx].sch_event_id) ;010
;	
;detail
;	cntx = cntx + 1
; 
;	call alterlist(sched_appt->list[idx].procedures, cntx)
; 
; 	sched_appt->list[idx].proc_cnt								= cntx
;	sched_appt->list[idx].procedures[cntx].order_id				= o.order_id
;	sched_appt->list[idx].procedures[cntx].order_mnemonic		= trim(o.order_mnemonic, 3)
;	sched_appt->list[idx].procedures[cntx].order_dt_tm			= o.current_start_dt_tm
;	sched_appt->list[idx].procedures[cntx].order_entered_by		= trim(od2.oe_field_display_value, 3)
;	sched_appt->list[idx].procedures[cntx].order_action_dt_tm	= oa.action_dt_tm
;	sched_appt->list[idx].procedures[cntx].order_action_type	= trim(uar_get_code_display(oa.action_type_cd), 3)
; 
; 	;006
; 	comment = fillstring(255, " ") 	
;	comment	= trim(od4.oe_field_display_value, 3)
;	comment = replace(comment, char(13), " ", 4)
;	comment = replace(comment, char(10), " ", 4)
;	comment = replace(comment, char(0), " ", 4)
;	
;	sched_appt->list[idx].procedures[cntx].order_comment 		= trim(comment, 3)
;
;	sched_appt->list[idx].procedures[cntx].request_start_dt_tm	= od3.oe_field_dt_tm_value ;006
;	sched_appt->list[idx].procedures[cntx].exam_start_dt_tm		= oros.start_dt_tm ;006
;
;	sched_appt->list[idx].procedures[cntx].prior_auth			= trim(od.oe_field_display_value, 3)
;	
;	sched_appt->list[idx].procedures[cntx].auth_entered_by		= if (size(trim(od.oe_field_display_value, 3)) > 0)
;																	per_od.name_full_formatted
;																  endif
;																  
;	sched_appt->list[idx].procedures[cntx].auth_dt_tm			= od.updt_dt_tm
;	
;;	sched_appt->list[idx].procedures[cntx].auth_tat_days		= if ((sen.earliest_dt_tm > cnvtdatetime("01-JAN-1800"))
;;																	and (sen.earliest_dt_tm < cnvtdatetime("31-DEC-2100"))
;;																	and (od.updt_dt_tm > 0))
;;																		datetimediff(od.updt_dt_tm, sen.earliest_dt_tm)
;;																	endif
;	
;	sched_appt->list[idx].procedures[cntx].cpt_cd				= trim(bim.key6, 3) ;006
;	sched_appt->list[idx].procedures[cntx].cpt_desc				= trim(n.source_string, 3) ;006
;	
;;010
;;foot sa.sch_appt_id
;;	if (cntx = 0)
;;		cntx = 1
;;	endif
;;	
;;	call alterlist(sched_appt->list[idx].procedures, cntx)
; 
;with nocounter, expand = 1, time = 1800 ;010
;
;;call echorecord(sched_appt)
;call echo(sched_appt->sched_cnt)
;
;;go to exitscript
;
;
;/**************************************************************/
;; select scanned order data ;011
;select into "NL:"
;from
;	CLINICAL_EVENT ce
;	
;	, (dummyt d1 with seq = value(sched_appt->sched_cnt))
;
;plan d1
;
;join ce
;where
;	ce.encntr_id = sched_appt->list[d1.seq].encntr_id
;	and ce.person_id = sched_appt->list[d1.seq].person_id
;	and ce.event_cd in (
;		physician_order_var, outside_order_var
;	)
; 
; 
;; populate tat_data record structure
;detail
;	sched_appt->list[d1.seq].has_scanned_order = 1
;	
;with nocounter, time = 1800
;
;;call echorecord(sched_appt)
;
;
;/**************************************************************/
;; select org set data ;011
;select into "NL:"
;	; derive cmg indicator
;	is_cmg = if (os.name like "*CMG*") 1
;		elseif (org.org_name_key like "THOMPSONONCOLOGYGROUP*") 1 
;		elseif (org.org_name_key like "FSRSLEEPDISORDERSCENTER*") 1
;		elseif (ps.practice_site_display like "Thompson Cancer*") 1
;		elseif (ps.practice_site_display like "Peninsula*Clinic*") 1
;		else 0 
;		endif
;		
;from
;	PRACTICE_SITE ps
;	
;	, (left join ORG_SET_ORG_R osor on osor.organization_id = ps.organization_id
;		and osor.active_ind = 1)
;	
;	, (left join ORG_SET os on os.org_set_id = osor.org_set_id
;		and os.active_ind = 1)
;		
;	, (left join ORGANIZATION org on org.organization_id = osor.organization_id
;		and org.active_ind = 1)
;	
;	, (dummyt d1 with seq = value(sched_appt->sched_cnt))
;
;plan d1
;
;join ps
;where
;	ps.practice_site_id = sched_appt->list[d1.seq].practice_site_id
;	
;join osor
;join os
;join org
; 
; 
;; populate record structure
;detail
;	if (is_cmg = 1)
;		sched_appt->list[d1.seq].is_cmg = is_cmg
;	endif
;	
;with nocounter, time = 1800
; 
;;call echorecord(sched_appt)
;
; 
;/**************************************************************/
;; select data
;if (validate(request->batch_selection) = 1 or $output_file = 1)
;	set modify filestream
;endif
; 
;select if (validate(request->batch_selection) = 1 or $output_file = 1)
;	with nocounter, outerjoin = d1, pcformat (^"^, ^,^, 1), format = stream, format, time = 1800 ;003 ;005 ;010
;else
;	with nocounter, outerjoin = d1, separator = " ", format, time = 1800 ;003 ;005 ;010
;endif
;
;;006
;into value(output_var)
;	person_id				= sched_appt->list[d1.seq].person_id
;	, patient_name			= sched_appt->list[d1.seq].patient_name
;	, fin					= sched_appt->list[d1.seq].fin
;	, fac					= sched_appt->list[d1.seq].facility
;	, patient_acct_nbr		= build(sched_appt->list[d1.seq].facility, sched_appt->list[d1.seq].fin)
;	
;	, dob					= format(cnvtdatetimeutc(datetimezone(sched_appt->list[d1.seq].dob,
;								sched_appt->list[d1.seq].dob_tz), 1), "mm/dd/yyyy;;d")
;	
;	, gender				= sched_appt->list[d1.seq].gender ;015	
;	, language				= sched_appt->list[d1.seq].language ;014	
;	, ssn					= sched_appt->list[d1.seq].ssn
;	, mrn					= sched_appt->list[d1.seq].mrn
;	, cmrn					= sched_appt->list[d1.seq].cmrn ;014
;	, encntr_type			= sched_appt->list[d1.seq].encntr_type
;	, encntr_status			= sched_appt->list[d1.seq].encntr_status
;	
;	, order_id				= sched_appt->list[d1.seq].procedures[d2.seq].order_id
;	, order_mnemonic		= sched_appt->list[d1.seq].procedures[d2.seq].order_mnemonic
;	, order_phy_id			= sched_appt->list[d1.seq].order_phy_id
;	, order_phy				= sched_appt->list[d1.seq].order_phy
;	, ord_phys_group		= sched_appt->list[d1.seq].ord_phys_group
;	
;	;011
;	, is_cmg				= if (trim(sched_appt->list[d1.seq].ord_phys_group, 3) > "")
;								evaluate(sched_appt->list[d1.seq].is_cmg, 1, "Y", "N")
;							  else
;							  	" "
;							  endif
;	
;	, order_entered_by		= sched_appt->list[d1.seq].procedures[d2.seq].order_entered_by
;	, order_action_dt_tm	= format(sched_appt->list[d1.seq].procedures[d2.seq].order_action_dt_tm, "mm/dd/yyyy hh:mm;;q")
;	, order_action_type		= sched_appt->list[d1.seq].procedures[d2.seq].order_action_type
;	, cpt_cd				= sched_appt->list[d1.seq].procedures[d2.seq].cpt_cd
;	, cpt_desc				= sched_appt->list[d1.seq].procedures[d2.seq].cpt_desc
;	, icd10					= sched_appt->list[d1.seq].icd10
;	, icd10_desc			= sched_appt->list[d1.seq].icd10_desc
;	, order_comment			= sched_appt->list[d1.seq].procedures[d2.seq].order_comment
;	
;	, org_name				= sched_appt->list[d1.seq].org_name
;	, health_plan			= sched_appt->list[d1.seq].health_plan
;	, schedule_id			= sched_appt->list[d1.seq].schedule_id
;	, sch_state				= sched_appt->list[d1.seq].sch_state
;	, location				= sched_appt->list[d1.seq].location
;	, resource				= sched_appt->list[d1.seq].resource
;	, appt_dt_tm			= format(sched_appt->list[d1.seq].appt_dt_tm, "mm/dd/yyyy hh:mm;;q")
;	, appt_type				= sched_appt->list[d1.seq].appt_type
;	, reason_exam			= sched_appt->list[d1.seq].reason_exam
;	, sch_action_dt_tm		= format(sched_appt->list[d1.seq].sch_action_dt_tm, "mm/dd/yyyy hh:mm;;q")
;	, sch_action_type		= sched_appt->list[d1.seq].sch_action_type
;	, sch_action_prsnl		= sched_appt->list[d1.seq].sch_action_prsnl
;	
;	, pre_reg_dt_tm			= format(sched_appt->list[d1.seq].pre_reg_dt_tm, "mm/dd/yyyy hh:mm;;q")
;	, est_arrive_dt_tm		= format(sched_appt->list[d1.seq].est_arrive_dt_tm, "mm/dd/yyyy hh:mm;;q") ;014
;	, exam_start_dt_tm		= format(sched_appt->list[d1.seq].procedures[d2.seq].exam_start_dt_tm, "mm/dd/yyyy hh:mm;;q")
;	, entry_state			= sched_appt->list[d1.seq].entry_state
;	, earliest_dt_tm		= format(sched_appt->list[d1.seq].earliest_dt_tm, "mm/dd/yyyy hh:mm;;q")
;	, request_start_dt_tm	= format(sched_appt->list[d1.seq].procedures[d2.seq].request_start_dt_tm, "mm/dd/yyyy hh:mm;;q")
;	, prior_auth			= sched_appt->list[d1.seq].procedures[d2.seq].prior_auth
;	, prior_auth_entered_by	= sched_appt->list[d1.seq].procedures[d2.seq].auth_entered_by
;	, prior_auth_dt_tm		= format(sched_appt->list[d1.seq].procedures[d2.seq].auth_dt_tm, "mm/dd/yyyy hh:mm;;q")
;	, auth_nbr				= sched_appt->list[d1.seq].auth_nbr
;	, auth_nbr_entered_by	= sched_appt->list[d1.seq].auth_nbr_entered_by
;	, has_scanned_order		= evaluate(sched_appt->list[d1.seq].has_scanned_order, 1, "Y", "N") ;011	
;	, comment				= sched_appt->list[d1.seq].comment
; 
;from
;	(dummyt d1 with seq = value(sched_appt->sched_cnt))
;	
;	, (dummyt d2 with seq = 1)
; 
;plan d1
;where
;	maxrec(d2, sched_appt->list[d1.seq].proc_cnt)
;	
;join d2
; 
;order by
;	org_name
;	, patient_name
;	, sched_appt->list[d1.seq].appt_dt_tm
;
;with nocounter, outerjoin = d1 ;010
; 
; 
;; copy file to AStream
;if (validate(request->batch_selection) = 1 or $output_file = 1)
;	set cmd = build2("cp ", temppath2_var, " ", filepath_var)
;	set len = size(trim(cmd))
; 
;	call dcl(cmd, len, stat)
;	call echo(build2(cmd, " : ", stat))
;endif
 
 
;go to exitscript
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript
 
end
go
 
