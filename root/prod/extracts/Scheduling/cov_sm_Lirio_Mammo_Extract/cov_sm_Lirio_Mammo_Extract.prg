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
 							- lirio_contacts.csv
 							- lirio_eligibility.csv
 							- lirio_scheduling.csv
 
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
	, "Output To File" = 0                   ;* Output to file 

with OUTDEV, output_file
 
 
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
declare start_datetime			= dq8 with constant(datetimefind(cnvtlookbehind("1,Y", cnvtdatetime(curdate, curtime)),'Y','B','B'))

declare cmrn_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 4, "COMMUNITYMEDICALRECORDNUMBER"))
declare in_error_var			= f8 with constant(uar_get_code_by("MEANING", 8, "IN ERROR"))
declare inerrnomut_var			= f8 with constant(uar_get_code_by("MEANING", 8, "INERRNOMUT"))
declare inerrnoview_var			= f8 with constant(uar_get_code_by("MEANING", 8, "INERRNOVIEW"))
declare inerror_var				= f8 with constant(uar_get_code_by("MEANING", 8, "INERROR"))
declare root_var				= f8 with constant(uar_get_code_by("MEANING", 24, "ROOT"))
declare phone_home_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 43, "HOME"))
declare phone_mobile_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 43, "MOBILE"))
declare female_birth_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 56, "FEMALE"))
declare female_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 57, "FEMALE"))
declare physician_order_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "PHYSICIANORDER"))
declare outside_order_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 72, "OUTSIDEORDER"))
declare radiology_esh_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 93, "RADIOLOGY"))
declare mammography_esh_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 93, "MAMMOGRAPHY"))
declare patviewrad_esh_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 93, "PATIENTVIEWABLERADIOLOGY"))
declare addr_home_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 212, "HOME"))
declare addr_email_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 212, "EMAIL"))
declare current_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 213, "CURRENT"))
declare yes_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 268, "YES"))
declare no_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 268, "NO"))
declare npi_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 320, "NATIONALPROVIDERIDENTIFIER"))
declare pcp_var					= f8 with constant(uar_get_code_by("DISPLAYKEY", 331, "PRIMARYCAREPHYSICIAN"))
declare employer_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 338, "EMPLOYER"))
declare fc_bluecross_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 354, "BLUECROSS"))
declare pt_bluecross_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 367, "BLUECROSS"))
declare radiology_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 6000, "RADIOLOGY"))
declare ordered_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "ORDERED"))
declare future_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "FUTURE"))
declare completed_var			= f8 with constant(uar_get_code_by("DISPLAYKEY", 6004, "COMPLETED"))

declare num						= i4 with noconstant(0)
declare crlf					= vc with constant(build(char(13), char(10)))
 
declare file0_var				= vc with constant("lirio_contacts.csv")
declare file1_var				= vc with constant("lirio_eligibility.csv")
declare file2_var				= vc with constant("lirio_scheduling.csv")
declare file_var				= vc with constant(file0_var)
 
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
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
free record patient_data
record patient_data (
	1 p_min_age					= i4
	1 p_max_age					= i4
	1 p_start_year				= i4
	1 p_end_year				= i4
	1 p_start_datetime			= dq8
 
	1 cnt						= i4
	1 list[*] 
		2 person_id				= f8
		2 name_prefix			= c20
		2 name_first			= c50
		2 name_last				= c50
		2 name_suffix			= c20
		2 dob					= dq8
		2 dob_tz				= i4
		2 deceased				= i2
		2 birth_sex				= c12
		2 gender				= c12
		2 language				= c40
		
		2 cmrn					= c20
		
		2 email					= c100
		2 mobile_phone			= c10
		2 street_addr			= c100
		2 street_addr2			= c100
		2 city					= c100
		2 state					= c20
		2 zipcode				= c25
		
		2 employer				= c100
		2 title					= c100
		2 marital_status		= c40
		2 race					= c40
		2 religion				= c40
		
		2 channel_pref			= c40
		2 pcp_npi				= c20
		2 portal_username		= c20
		2 optout_ind			= i2
		2 rltn_ind				= c40
		2 consent_ind			= i2
		2 crm_id				= c10
		
		; exclusions
		2 has_order				= i2
		2 has_doc				= i2
)
 
 
/**************************************************************/
; populate record structure with prompt data
set patient_data->p_min_age				= min_age
set patient_data->p_max_age				= max_age
set patient_data->p_start_year			= start_year
set patient_data->p_end_year			= end_year
set patient_data->p_start_datetime		= start_datetime


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
		
	, (inner join PERSON_PLAN_RELTN ppr on ppr.person_id = p.person_id
		and ppr.health_plan_id in (
			select hp.health_plan_id
			from 
				HEALTH_PLAN hp
			where
				hp.plan_name_key in ("BLUE*CROSS*EXCHANGE*", "BLUE*CROSS*NETWORK*")
				and hp.plan_type_cd = pt_bluecross_var
				and hp.financial_class_cd = fc_bluecross_var
				and hp.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
				and hp.active_ind = 1
		)
		and ppr.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
		and ppr.active_ind = 1)
		
where
	year(p.birth_dt_tm) between start_year and end_year
	and p.deceased_cd in (no_var, 0.0)
	and p.active_ind = 1
	
;	and p.person_id = 15678757.00 ; TODO: TESTING
	
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


;call echorecord(patient_data)
;go to exitscript
 
 
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
	
	idx = locateval(num, 1, patient_data->cnt, a.parent_entity_id, patient_data->list[num].person_id)

detail
	patient_data->list[idx].email = a.street_addr

with nocounter, expand = 1, time = 300


;call echorecord(patient_data)
;go to exitscript
 
 
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
	
	idx = locateval(num, 1, patient_data->cnt, p.person_id, patient_data->list[num].person_id)

detail
	patient_data->list[idx].mobile_phone = evaluate(textlen(ph.phone_num_key), 10, ph.phone_num_key, ph2.phone_num_key)

with nocounter, expand = 1, time = 300


;call echorecord(patient_data)
;go to exitscript
 
 
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
	
	idx = locateval(num, 1, patient_data->cnt, por.person_id, patient_data->list[num].person_id)

detail
	patient_data->list[idx].employer		= por.ft_org_name
	patient_data->list[idx].title			= por.empl_title

with nocounter, expand = 1, time = 300


;call echorecord(patient_data)
;go to exitscript


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
	
	idx = locateval(num, 1, patient_data->cnt, ppr.person_id, patient_data->list[num].person_id)

detail
	patient_data->list[idx].pcp_npi = pera.alias

with nocounter, expand = 1, time = 300


;call echorecord(patient_data)
;go to exitscript


/**************************************************************/
; select exclusion data - orders
select into "NL:"
from
	ORDERS o 
 
where
	expand(num, 1, patient_data->cnt, o.person_id, patient_data->list[num].person_id)	
	and o.catalog_type_cd = radiology_var
	and o.catalog_cd in (
		select cv.code_value
		from 
			CODE_VALUE cv
		where
			cv.code_set = 200
			and cv.display_key in ("MGDIGSCREENMAMMO*", "MGDIGDIAGMAMMO*")			
			and cv.active_ind = 1
	)
	and o.order_status_cd in (ordered_var, future_var, completed_var)
	and o.current_start_dt_tm >= cnvtdatetime(start_datetime)
	and o.active_ind = 1
 
order by
	o.person_id
 
 
; populate patient_data record structure	
head o.person_id
	idx = 0
 
	idx = locateval(num, 1, patient_data->cnt, o.person_id, patient_data->list[num].person_id)
	
detail
	patient_data->list[idx].has_order = 1
 
with nocounter, expand = 1, time = 900


;call echorecord(patient_data)
;go to exitscript


;/**************************************************************/
;; select scanned order data
;select into "NL:"
;from
;	CLINICAL_EVENT ce
;	
;	, (dummyt d1 with seq = value(patient_data->cnt))
;
;plan d1
;
;join ce
;where
;	ce.encntr_id = patient_data->list[d1.seq].encntr_id
;	and ce.person_id = patient_data->list[d1.seq].person_id
;	and ce.event_cd in (
;		physician_order_var, outside_order_var
;	)
; 
; 
;; populate tat_data record structure
;detail
;	patient_data->list[d1.seq].has_scanned_order = 1
;	
;with nocounter, time = 900


;call echorecord(patient_data)
;go to exitscript


/**************************************************************/
; select exclusion data - documents
select into "NL:"
from
	CLINICAL_EVENT ce
	
where	
	expand(num, 1, patient_data->cnt, ce.person_id, patient_data->list[num].person_id)
	and ce.encntr_id > 0.0
	and ce.event_reltn_cd = root_var
	and ce.event_cd in (
		select vec.event_cd
		from 
			V500_EVENT_SET_CANON vescn
				
			, (inner join V500_EVENT_SET_CODE vesc on vesc.event_set_cd = vescn.event_set_cd
				and vesc.event_set_name_key in ("*MAMMO*"))
		 
			, (inner join V500_EVENT_SET_EXPLODE vese on vese.event_set_cd = vesc.event_set_cd)
		 
			, (inner join V500_EVENT_CODE vec on vec.event_cd = vese.event_cd)
			
		where
			vescn.parent_event_set_cd in (radiology_esh_var, mammography_esh_var, patviewrad_esh_var)
	)
	and ce.result_status_cd not in (in_error_var, inerrnomut_var, inerrnoview_var, inerror_var)
	and ce.performed_dt_tm >= cnvtdatetime(start_datetime)
	and ce.valid_until_dt_tm > cnvtdatetime(curdate, curtime)

order by
	ce.person_id
 
 
; populate patient_data record structure
head ce.person_id
	idx = 0
 
	idx = locateval(num, 1, patient_data->cnt, ce.person_id, patient_data->list[num].person_id)
	
detail	
	patient_data->list[idx].has_doc = 1
 
with nocounter, expand = 1, time = 900


;call echorecord(patient_data)
;go to exitscript


/**************************************************************/
; select misc data
select into "NL:"
from
	(dummyt d1 with seq = value(patient_data->cnt))
	
plan d1
 
 
; populate patient_data record structure
detail	
	patient_data->list[d1.seq].channel_pref			= "Email"
	patient_data->list[d1.seq].portal_username		= "N"
	patient_data->list[d1.seq].optout_ind			= 0
	patient_data->list[d1.seq].rltn_ind				= "Established"
	patient_data->list[d1.seq].consent_ind			= 1
	patient_data->list[d1.seq].crm_id				= " "
 
with nocounter, expand = 1, time = 300


call echorecord(patient_data)
;go to exitscript

 
/**************************************************************/
; select data
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set modify filestream
endif
 
select if (validate(request->batch_selection) = 1 or $output_file = 1)
	with nocounter, pcformat (^"^, ^,^, 1), format = stream, format, time = 300
else
	with nocounter, separator = " ", format, time = 300
endif

into value(output_var)
	unique_id					= trim(patient_data->list[d1.seq].cmrn, 3)
	, prefix					= trim(patient_data->list[d1.seq].name_prefix, 3)
	, first_name				= trim(patient_data->list[d1.seq].name_first, 3)
	, last_name					= trim(patient_data->list[d1.seq].name_last, 3)
	, suffix					= trim(patient_data->list[d1.seq].name_suffix, 3)
	, sex						= trim(patient_data->list[d1.seq].birth_sex, 3)
	, gender					= trim(patient_data->list[d1.seq].gender, 3)
	, email						= trim(patient_data->list[d1.seq].email, 3)
	, mobile_phone				= format(patient_data->list[d1.seq].mobile_phone, "###-###-####")
	
	, dob						= format(cnvtdatetimeutc(datetimezone(patient_data->list[d1.seq].dob,
									patient_data->list[d1.seq].dob_tz), 1), "yyyy-mm-dd;;d")
									
	, language					= trim(patient_data->list[d1.seq].language, 3)
	, address1					= trim(patient_data->list[d1.seq].street_addr, 3)
	, address2					= trim(patient_data->list[d1.seq].street_addr2, 3)
	, city						= trim(patient_data->list[d1.seq].city, 3)
	, state						= trim(patient_data->list[d1.seq].state, 3)
	, zip						= trim(patient_data->list[d1.seq].zipcode, 3)
	, employer					= trim(patient_data->list[d1.seq].employer, 3)
	, title						= trim(patient_data->list[d1.seq].title, 3)
	, marital_status			= trim(patient_data->list[d1.seq].marital_status, 3)
	, race						= trim(patient_data->list[d1.seq].race, 3)
	, religion					= trim(patient_data->list[d1.seq].religion, 3)	
	, channel_preference		= trim(patient_data->list[d1.seq].channel_pref, 3)
	, primary_care_provider		= trim( patient_data->list[d1.seq].pcp_npi, 3)
	, portal_username			= trim(patient_data->list[d1.seq].portal_username, 3)
	, optout_indicator			= cnvtbool(patient_data->list[d1.seq].optout_ind)
	, deceased_indicator		= cnvtbool(patient_data->list[d1.seq].deceased)
	, relationship_indicator	= trim(patient_data->list[d1.seq].rltn_ind, 3)
	, consent_indicator			= cnvtbool(patient_data->list[d1.seq].consent_ind)
	, crm_id					= trim(patient_data->list[d1.seq].crm_id, 3)
	
	; TODO: TESTING
;	, has_order					= patient_data->list[d1.seq].has_order
;	, has_doc					= patient_data->list[d1.seq].has_doc

from
	(dummyt d1 with seq = value(patient_data->cnt))
 
plan d1
where
	patient_data->list[d1.seq].has_order = 0
	and patient_data->list[d1.seq].has_doc = 0

order by
	last_name
	, first_name

with nocounter
 
 
; copy file to AStream
if (validate(request->batch_selection) = 1 or $output_file = 1)
	set cmd = build2("cp ", temppath2_var, " ", filepath_var)
	set len = size(trim(cmd))
 
	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
endif

 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
#exitscript
 
end
go
 
