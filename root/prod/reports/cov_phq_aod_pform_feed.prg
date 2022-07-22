/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Mar'2021
	Solution:			All
	Source file name:	      cov_phq_aod_pform_feed.prg
	Object name:		cov_phq_aod_pform_feed
	Request#:			7123
	Program purpose:	      AOD
	Executing from:		Ops
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
 
drop program cov_phq_aod_pform_feed:dba go
create program cov_phq_aod_pform_feed:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Screen Display" = 1 

with OUTDEV, start_datetime, end_datetime, to_file
 
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare home_ph_var = i4 with constant(uar_get_code_by('DISPLAY', 43, 'Home')), protect
declare mobile_ph_var = i4 with constant(uar_get_code_by('DISPLAY', 43, 'MOBILE')), protect
declare cmrn_alias_pool_var  	 = f8 with constant(uar_get_code_by("DISPLAY", 263, "CMRN")),protect
declare cmrn_var             	 = f8 with constant(uar_get_code_by("DISPLAY", 4, "Community Medical Record Number")),protect
 
;AOD Charting DTA
declare aod_form_var          = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Accounting for Disclosures Form')), protect
declare doc_sent_var          = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Documents Sent')), protect
declare purpose_var           = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Purpose of Disclosure')), protect
declare disclo_info_var       = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Disclosure Information')), protect
declare method_contact_var    = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Method of Contact (Disclosure)')), protect
declare disclo_policy_var     = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Acct of Disclosure Requestor Per Policy')), protect
declare agency_contacted_var  = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Agency Contacted')), protect
declare delay_act_var         = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Delay in Accounting?')), protect
declare reportable_cond_var   = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Reportable Condition')), protect
declare disclo_contact_dt_var = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Date and Time of Contact (Disclosure)')), protect
declare disclo_company_var    = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Requestor Agency/Company (Disclosure)')), protect
declare address_var           = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Address')), protect
declare requestr_name_var     = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Requestor Name (Disclosure)')), protect
declare contact_name_var      = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Contact Name (Disclosure)')), protect
declare disclo_date_var       = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Disclosure Date')), protect
declare aod_other_person_var  = f8 with constant(uar_get_code_by('DISPLAY', 72, 'AOD Other Person')), protect
declare case_management_var   = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Case Management (disclosure) AOD')), protect
declare delay_acct_doc_var    = f8 with constant(uar_get_code_by('DISPLAY', 72, 'Delay in Accounting Written Document')), protect
declare acct_suspend_var      = f8 with constant(uar_get_code_by('DISPLAY', 72, 'End Date for Suspending of Accounting')), protect
declare aod_delay_rele_var    = f8 with constant(uar_get_code_by('DISPLAY', 72, 'AOD Delayed Release date calc')), protect
 
 
 
;************* OPS SETUP ******************
declare aod_output = vc
declare cmd  = vc with noconstant("")
declare len  = i4 with noconstant(0)
declare stat = i4 with noconstant(0)
declare iOpsInd = i2 with noconstant(0), protect
 
;test ----------
;declare filename_var  = vc with constant('cer_temp:cov_aod_pform_tst1.txt'), protect
;declare ccl_filepath_var = vc WITH constant('$cer_temp/cov_aod_pform_tst1.txt'), PROTECT
;---------------*/
 
 
declare filename_var = vc WITH constant('cer_temp:cov_aod_pform_data.txt'), PROTECT
declare ccl_filepath_var = vc WITH constant('$cer_temp/cov_aod_pform_data.txt'), PROTECT
declare astream_filepath_var = vc with constant("/cerner/w_custom/p0665_cust/to_client_site/Quality/")
 
;request from Ops?
if(validate(request->batch_selection) = 1)
 	set iOpsInd = 1
endif
 
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
Record aod(
	1 plist[*]
		2 facility = vc ;mnemonic
		2 fin = vc
		2 mrn = vc
		2 cmrn = vc
		2 personid = f8
		2 encntrid = f8
		2 pat_name = vc
 		2 pat_first_name = vc
 		2 pat_middle_name = vc
 		2 pat_last_name = vc
 		2 pat_add1 = vc
 		2 pat_add2 = vc
 		2 pat_city = vc
 		2 pat_state = vc
 		2 pat_zip = vc
 		2 pat_phone1 = vc
 		2 pat_phone2 = vc
 		2 pat_dob = vc
 		2 admit_dt = vc
 		2 dish_dt = vc
 		2 ecare_user = vc
 		2 report_condition = vc
 		2 contact_dt = vc
 		2 aod_other_person = vc
 		2 doc_sent = vc
 		2 purpose = vc
 		2 disclo_info = vc
 		2 disclo_dt = vc
 		2 contact_method = vc
 		2 acct_disclo_policy = vc
 		2 requestr_company = vc
 		2 requestr_name = vc
 		2 contact_agency = vc
 		2 agency_addr = vc
 		2 name_contact = vc
 		2 acct_delay = vc
 		2 acct_delay_doc = vc
 		2 acct_suspend_end_dt = vc
 		2 aod_delay_rele_dt = vc
 		2 case_mgmnt_aod = vc
	)
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
;Patient pool
 
select distinct into $outdev
 
 ce.encntr_id, ce.event_cd, ce.order_id
, event = uar_get_code_display(ce.event_cd), ce.result_val
, event_end_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, ce.event_title_text, ce.event_tag
, ce.event_id, ce.event_cd, ce.result_status_cd
, ce.view_level, ce.publish_flag
, e.person_id, fac = uar_get_code_display(e.loc_facility_cd), e.loc_facility_cd
 
from clinical_event ce
	, (left join ce_date_result cdr on cdr.event_id = ce.event_id)
	, encounter e
	, prsnl pr
 
plan ce where ce.event_end_dt_tm between cnvtdatetime($start_datetime) AND cnvtdatetime($end_datetime)
	and ce.event_cd in(aod_form_var,doc_sent_var,purpose_var,disclo_info_var,method_contact_var,disclo_policy_var,
		agency_contacted_var,delay_act_var,reportable_cond_var,disclo_contact_dt_var,disclo_company_var,
		address_var,requestr_name_var,contact_name_var,disclo_date_var,aod_other_person_var,case_management_var,
		delay_acct_doc_var,acct_suspend_var,aod_delay_rele_var)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd in(34.00, 25.00, 35.00)
 
join cdr
 
join e where e.encntr_id = ce.encntr_id
	and e.active_ind = 1
 
join pr where ce.verified_prsnl_id = pr.person_id
 
order by ce.encntr_id, ce.event_cd
 
;with nocounter, separator=" ", format, time = 240
;go to exitscript
 
 
Head report
	cnt = 0
Head ce.encntr_id
	cnt += 1
	call alterlist(aod->plist, cnt)
	aod->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)
	aod->plist[cnt].personid = ce.person_id
	aod->plist[cnt].encntrid = ce.encntr_id
	aod->plist[cnt].admit_dt = format(e.reg_dt_tm, 'mm/dd/yyyy hh:mm:ss ;;q')
	aod->plist[cnt].dish_dt = format(e.disch_dt_tm, 'mm/dd/yyyy hh:mm:ss ;;q')
	aod->plist[cnt].ecare_user = trim(pr.name_full_formatted)
Detail
	case(ce.event_cd)
		of reportable_cond_var:
			aod->plist[cnt].report_condition = trim(ce.result_val)
		of disclo_contact_dt_var:
			aod->plist[cnt].contact_dt = format(cdr.result_dt_tm, 'mm/dd/yyyy hh:mm:ss ;;q')
			;aod->plist[cnt].contact_dt = trim(ce.result_val)
		of aod_other_person_var:
			aod->plist[cnt].aod_other_person = trim(ce.result_val)
		of doc_sent_var:
			aod->plist[cnt].doc_sent = trim(ce.result_val)
		of purpose_var:
			aod->plist[cnt].purpose = trim(ce.result_val)
		of disclo_info_var:
			aod->plist[cnt].disclo_info = trim(ce.result_val)
		of method_contact_var:
			aod->plist[cnt].contact_method = trim(ce.result_val)
		of disclo_policy_var:
			aod->plist[cnt].acct_disclo_policy = trim(ce.result_val)
		of disclo_company_var:
			aod->plist[cnt].requestr_company = trim(ce.result_val)
		of requestr_name_var:
			aod->plist[cnt].requestr_name = trim(ce.result_val)
		of agency_contacted_var:
			aod->plist[cnt].contact_agency = trim(ce.result_val)
		of address_var:
			aod->plist[cnt].agency_addr = replace(ce.result_val, concat(char(13),char(10)), " ",0)
		of contact_name_var:
			aod->plist[cnt].name_contact = trim(ce.result_val)
		of delay_act_var:
			aod->plist[cnt].acct_delay = trim(ce.result_val)
		of delay_acct_doc_var:
			aod->plist[cnt].acct_delay_doc = trim(ce.result_val)
		of acct_suspend_var:
			aod->plist[cnt].acct_suspend_end_dt = trim(ce.result_val)
		of aod_delay_rele_var:
			aod->plist[cnt].aod_delay_rele_dt = trim(ce.result_val)
		of case_management_var:
			aod->plist[cnt].case_mgmnt_aod = trim(ce.result_val)
		of disclo_date_var:
			aod->plist[cnt].disclo_dt = trim(ce.result_val)
	endcase
 
with nocounter
 
;-----------------------------------------------------------------------------------------------
;Patient Demographic
 
select into $outdev
 
p.person_id, ph.phone_num, ph.phone_type_cd
 
from (dummyt d with seq = value(size(aod->plist, 5)))
	, encntr_alias ea
	, encntr_alias ea1
	, person p
	, person_alias pa
 
plan d
 
join ea where ea.encntr_id = aod->plist[d.seq].encntrid
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
join ea1 where ea1.encntr_id = aod->plist[d.seq].encntrid
	and ea1.encntr_alias_type_cd = 1079
	and ea1.active_ind = 1
 
join p where p.person_id = aod->plist[d.seq].personid
	and p.active_ind = 1
 
join pa where outerjoin(p.person_id) = pa.person_id
	 and pa.alias_pool_cd = outerjoin(cmrn_alias_pool_var)
	 and pa.person_alias_type_cd = outerjoin(cmrn_var)
	 and pa.active_ind = outerjoin(1)
 
 
order by ea.encntr_id
 
Head ea.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(aod->plist,5) ,ea.encntr_id ,aod->plist[icnt].encntrid)
 
    while(idx > 0)
    	    aod->plist[idx].fin = trim(ea.alias)
    	    aod->plist[idx].mrn = trim(ea1.alias)
    	    aod->plist[idx].cmrn = trim(pa.alias)
     	    aod->plist[idx].pat_name = trim(p.name_full_formatted)
    	    aod->plist[idx].pat_dob = format(p.birth_dt_tm, 'mm/dd/yyyy;;d')
    	    aod->plist[idx].pat_first_name = trim(p.name_first)
    	    aod->plist[idx].pat_middle_name = trim(p.name_middle)
    	    aod->plist[idx].pat_last_name = trim(p.name_last)
	    idx = locateval(icnt,(idx+1) ,size(aod->plist,5) ,ea.encntr_id ,aod->plist[icnt].encntrid)
    endwhile
 
with nocounter
 
;-----------------------------------------------------------------------------------------------------------
;Patient Address
select into $outdev
 
pid = aod->plist[d.seq].personid,  name = aod->plist[d.seq].pat_name
, a.street_addr, a.street_addr2, a.city, a.state, a.zipcode
 
from (dummyt d with seq = value(size(aod->plist, 5)))
	,address a
	, person p
	, (left join phone ph on ph.parent_entity_id = p.person_id
		and ph.active_ind = 1
		and ph.parent_entity_name = 'PERSON'
		and ph.phone_type_cd in(home_ph_var, mobile_ph_var))
 
plan d
 
join p where p.person_id = aod->plist[d.seq].personid
	and p.active_ind = 1
 
join ph
 
join a where a.parent_entity_id  = p.person_id
	and cnvtlower(a.parent_entity_name) = "person"
      and a.address_type_cd = 756.00 ;Home
 
order by p.person_id
 
Head pid
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(aod->plist,5), p.person_id ,aod->plist[icnt].personid)
 
    while(idx > 0)
    	    aod->plist[idx].pat_add1 = a.street_addr
    	    aod->plist[idx].pat_add2 = a.street_addr2
    	    aod->plist[idx].pat_city = a.city
    	    aod->plist[idx].pat_state = a.state
    	    aod->plist[idx].pat_zip = a.zipcode
     	    case(ph.phone_type_cd)
    	    	of home_ph_var:
    	    		aod->plist[idx].pat_phone1 = ph.phone_num
    	    	of mobile_ph_var:
    	    		aod->plist[idx].pat_phone2 = ph.phone_num
    	    endcase
 
	    idx = locateval(icnt,(idx+1) ,size(aod->plist,5),p.person_id ,aod->plist[icnt].personid)
    endwhile
 
with nocounter
 
call echorecord(aod)
 
;----------------------------------------------------------------------------------------------------
 
/********************************************************************************
				OUTPUT /FEED SECTION
*********************************************************************************/
 
/************** Ops Job *****************/
 
if(iOpsInd = 1) ;Ops
  if($to_file = 0)  ;To File
 
   Select into value(filename_var)
 
	from (dummyt d WITH seq = value(size(aod->plist,5)))
	order by d.seq
 
	;build output
	Head report
		file_header_var = build(
			 wrap3("Start dt")
			,wrap3("End dt")
			,wrap3("Facility")
			,wrap3("fin")
			,wrap3("mrn")
			,wrap3("cmrn")
			,wrap3("FirstName")
			,wrap3("MiddleName")
			,wrap3("LastName")
			,wrap3("Add1")
			,wrap3("Add2")
			,wrap3("City")
			,wrap3("State")
			,wrap3("Zip")
			,wrap3("Phone1")
  			,wrap3("Phone2")
  			,wrap3("DateOfBirth")
		  	,wrap3("admitDt")
		  	,wrap3("DischargeDt")
			,wrap3("eCareUser")
			,wrap3("disclosurContactDt")
			,wrap3("aodOtherPerson")
			,wrap3("documentSent")
			,wrap3("purposeOfDisclosur")
			,wrap3("disclosurInfo")
			,wrap3("methodOfContact")
			,wrap3("acctDisclosurPolicy")
			,wrap3("requestorCompany")
			,wrap3("requestorName")
			,wrap3("agencyContact")
			,wrap3("agencyAddress")
			,wrap3("contactName")
			,wrap3("delayAccounting")
			,wrap3("delayAcctWrittenDoc")
			,wrap3("endDtSuspendacct")
			,wrap3("aodDelayedReleseDt")
			,wrap3("caseManagementAod")
			,wrap1("EncounterID") )
 
	col 0 file_header_var
	row + 1
 
 	Head d.seq
		aod_output = ""
		aod_output = build(aod_output
			,wrap3(format(cnvtdatetime($start_datetime), 'mm/dd/yyyy hh:mm;;q'))
			,wrap3(format(cnvtdatetime($end_datetime), 'mm/dd/yyyy hh:mm;;q'))
			,wrap3(aod->plist[d.seq].facility)
			,wrap3(aod->plist[d.seq].fin)
			,wrap3(aod->plist[d.seq].mrn)
			,wrap3(aod->plist[d.seq].cmrn)
			,wrap3(aod->plist[d.seq].pat_first_name)
			,wrap3(aod->plist[d.seq].pat_middle_name)
			,wrap3(aod->plist[d.seq].pat_last_name)
			,wrap3(aod->plist[d.seq].pat_add1)
			,wrap3(aod->plist[d.seq].pat_add2)
			,wrap3(aod->plist[d.seq].pat_city)
			,wrap3(aod->plist[d.seq].pat_state)
			,wrap3(aod->plist[d.seq].pat_zip)
			,wrap3(aod->plist[d.seq].pat_phone1)
			,wrap3(aod->plist[d.seq].pat_phone2)
			,wrap3(aod->plist[d.seq].pat_dob)
			,wrap3(aod->plist[d.seq].admit_dt)
			,wrap3(aod->plist[d.seq].dish_dt)
			,wrap3(aod->plist[d.seq].ecare_user)
			,wrap3(aod->plist[d.seq].contact_dt)
			,wrap3(aod->plist[d.seq].aod_other_person)
			,wrap3(aod->plist[d.seq].doc_sent)
			,wrap3(aod->plist[d.seq].purpose)
			,wrap3(aod->plist[d.seq].disclo_info)
			,wrap3(aod->plist[d.seq].contact_method)
			,wrap3(aod->plist[d.seq].acct_disclo_policy)
			,wrap3(aod->plist[d.seq].requestr_company)
			,wrap3(aod->plist[d.seq].requestr_name)
			,wrap3(aod->plist[d.seq].contact_agency)
			,wrap3(aod->plist[d.seq].agency_addr)
			,wrap3(aod->plist[d.seq].name_contact)
			,wrap3(aod->plist[d.seq].acct_delay)
			,wrap3(aod->plist[d.seq].acct_delay_doc)
			,wrap3(aod->plist[d.seq].acct_suspend_end_dt)
			,wrap3(aod->plist[d.seq].aod_delay_rele_dt)
			,wrap3(aod->plist[d.seq].case_mgmnt_aod)
			,wrap1(cnvtstring(aod->plist[d.seq].encntrid))  )
 
		aod_output = trim(aod_output, 3)
		aod_output = replace(replace(aod_output ,char(13)," "),char(10)," ")
 
	 Foot d.seq
	 	col 0 aod_output
	 	row + 1
 
	with time = 30, nocounter, maxcol = 32000, format = stream, formfeed = none;, maxrow = 0
 
	;Move file to Astream folder
  	set cmd = build2("mv ", ccl_filepath_var, " ", astream_filepath_var) ;to move only in prod
  	;set cmd = build2("cp ", ccl_filepath_var, " ", astream_filepath_var) ;to copy only for testing
	set len = size(trim(cmd))
 	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
 
  endif ;To File
endif ;ops
 
;---------------------------------------------------------------------------------------------------------------------
 
If($to_file = 1) ;Screen Display
 
select into $outdev
	facility = trim(substring(1, 50, aod->plist[d1.seq].facility))
	, fin = trim(substring(1, 10, aod->plist[d1.seq].fin))
	, mrn = trim(substring(1, 10, aod->plist[d1.seq].mrn))
	, cmrn = trim(substring(1, 10, aod->plist[d1.seq].cmrn))
	;, patient_name = trim(substring(1, 50, aod->plist[d1.seq].pat_name))
	, patient_first_name = trim(substring(1, 50, aod->plist[d1.seq].pat_first_name))
	, patient_middle_name = trim(substring(1, 50, aod->plist[d1.seq].pat_middle_name))
	, patient_last_name = trim(substring(1, 50, aod->plist[d1.seq].pat_last_name))
	, pat_add1 = trim(substring(1, 50, aod->plist[d1.seq].pat_add1))
	, pat_add2 = trim(substring(1, 50, aod->plist[d1.seq].pat_add2))
	, pat_city = trim(substring(1, 50, aod->plist[d1.seq].pat_city))
	, pat_state = trim(substring(1, 50, aod->plist[d1.seq].pat_state))
	, pat_zip = trim(substring(1, 10, aod->plist[d1.seq].pat_zip))
	, pat_phone1 = trim(substring(1, 10, aod->plist[d1.seq].pat_phone1))
	, pat_phone2 = trim(substring(1, 10, aod->plist[d1.seq].pat_phone2))
	, patient_dob = trim(substring(1, 20, aod->plist[d1.seq].pat_dob))
	, admit_dt = trim(substring(1, 20, aod->plist[d1.seq].admit_dt))
	, discharge_dt = trim(substring(1, 20, aod->plist[d1.seq].dish_dt))
	, ecare_user = trim(substring(1, 50, aod->plist[d1.seq].ecare_user))
	;, reportable_condition = replace(trim(substring(1, 150, aod->plist[d1.seq].report_condition)),CHAR(10),'')
	, disclosure_contact_dt = trim(substring(1, 50, aod->plist[d1.seq].contact_dt))
	, aod_other_person = trim(substring(1, 50, aod->plist[d1.seq].aod_other_person))
	, document_sent = replace(trim(substring(1, 300, aod->plist[d1.seq].doc_sent)),CHAR(10),'')
	, purpose_of_disclosure = replace(trim(substring(1, 100, aod->plist[d1.seq].purpose)),CHAR(10),'')
	, disclosure_info = replace(trim(substring(1, 300, aod->plist[d1.seq].disclo_info)),concat(char(13),char(10)),' ')
	, method_of_contact = replace(trim(substring(1, 100, aod->plist[d1.seq].contact_method)),CHAR(10),'')
	, acct_disclosure_policy = trim(substring(1, 10, aod->plist[d1.seq].acct_disclo_policy))
	, requestor_company = replace(trim(substring(1, 100, aod->plist[d1.seq].requestr_company)),CHAR(10),'')
	, requestor_name = trim(substring(1, 50, aod->plist[d1.seq].requestr_name))
	, agency_contact = replace(trim(substring(1, 100, aod->plist[d1.seq].contact_agency)),CHAR(10),'')
	, agency_address = replace(trim(substring(1, 100, aod->plist[d1.seq].agency_addr)),CHAR(10),'')
	, contact_name = trim(substring(1, 50, aod->plist[d1.seq].name_contact))
	, delay_accounting = trim(substring(1, 30, aod->plist[d1.seq].acct_delay))
	, delay_acct_written_doc = replace(trim(substring(1, 100, aod->plist[d1.seq].acct_delay_doc)),CHAR(10),'')
	, end_dt_suspendin_acct = trim(substring(1, 50, aod->plist[d1.seq].acct_suspend_end_dt))
	, aod_delayed_release_dt = trim(substring(1, 30, aod->plist[d1.seq].aod_delay_rele_dt))
	, case_mgmnt_aod = replace(trim(substring(1, 100, aod->plist[d1.seq].case_mgmnt_aod)),CHAR(10),'')
 
from
	(dummyt   d1  with seq = size(aod->plist, 5))
 
plan d1
 
with nocounter, separator=" ", format
 
endif
 
/*****************************************************************************
	;SUBROUTINS
/*****************************************************************************/
 
%i cust_script:cov_CommonLibrary.inc
 
 
#exitscript
 
end go
 
 
 
 
