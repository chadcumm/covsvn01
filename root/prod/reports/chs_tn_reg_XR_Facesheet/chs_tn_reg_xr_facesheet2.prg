/***********************************************************
Author 			:	Todd A. Blanchard
Date Written	:	09/14/2018
Program Title	:	XR Facesheet
Source File		:	chs_tn_reg_xr_facesheet2.prg
Object Name		:	chs_tn_reg_xr_facesheet2
Directory		:	cust_script
DVD Version		:
HNA Version		:
CCL Version		:
Purpose			: 	This program is a translated copy of the original
					custom script - chs_tn_reg_xr_facesheet2.
 
					CR 3279	requested that Ethnicity be added.
					CR 7472 requested that Observation Dt/Tm be corrected.
Tables Read		:
Tables Updated	:	NA
Include File	:	NA
Shell Scripts	:	NA
Executing App	:	PowerChart
Special Notes	:
Usage			:	chs_tn_reg_xr_facesheet2 go
Mod		Date		Engineer				Comment
----    ----------- ----------------------- ---------------------------
001		09/14/2018	Todd A. Blanchard		CR 3279
002		08/02/2019	Todd A. Blanchard		CR 5349
003		08/30/2019	Todd A. Blanchard		Applied break fix for age calculation due to null discharge dates.
004		11/20/2019	Todd A. Blanchard		Applied break fix for missing health plan group/policy numbers.
005		01/27/2020	Todd A. Blanchard		Applied break fix to remove hardcoded value 'Eric'.
006		02/24/2020	Todd A. Blanchard		Applied break fix for dob calculation due to timezone offset.
007		04/30/2020	Todd A. Blanchard		Added logic for observation data.
 
************************************************************/
 
DROP PROGRAM chs_tn_reg_xr_facesheet2:DBA GO
CREATE PROGRAM chs_tn_reg_xr_facesheet2:DBA
 PROMPT
  "Output to File/Printer/MINE" = "MINE" ,
  "Person ID" = "0.0" ,
  "Encounter ID" = "0.0" ,
  "Scheduling Event ID" = "0.0" ,
  "Scheduling ID" = "0.0"
  WITH outdev ,dperson_id ,dencntr_id ,dsch_event_id ,dschedule_id
 EXECUTE reportrtl
 SET bdrvstructcreated = false
 IF ((validate (post_doc_rec->struct_created ,- (9 ) ) != - (9 ) ) )
  IF ((post_doc_rec->struct_created = true ) )
   SET bdrvstructcreated = true
  ENDIF
 ENDIF
 IF ((bdrvstructcreated != true ) )
  FREE RECORD post_doc_rec
  RECORD post_doc_rec (
    1 person_id = f8
    1 encntr_id = f8
    1 org_id = f8
    1 bstruct_loaded = i2
    1 currentdate = vc
    1 currentdatetime = vc
    1 current_dt_tm = dq8
    1 patient_title = vc
    1 patient_prefix = vc
    1 patient_fullname = vc
    1 patient_firstname = vc
    1 patient_middlename = vc
    1 patient_lastname = vc
    1 patient_prev_title = vc
    1 patient_prev_prefix = vc
    1 patient_prev_fullname = vc
    1 patient_prev_firstname = vc
    1 patient_prev_middlename = vc
    1 patient_prev_lastname = vc
    1 patient_mrn = vc
    1 patient_ssn = vc
    1 patient_dob = vc
    1 patient_birth_dt_tm = dq8
    1 patient_birth_tz = i4
    1 patient_age = vc
    1 patient_sex = vc
    1 patient_homeaddr1 = vc
    1 patient_homeaddr2 = vc
    1 patient_homeaddr3 = vc
    1 patient_homeaddr4 = vc
    1 patient_zip = vc
    1 patient_city = vc
    1 patient_state = vc
    1 patient_country = vc
    1 patient_homephone = vc
    1 patient_livingwill = vc
    1 patient_race = vc
    1 patient_religion = vc
    1 servicecategory = vc
    1 medicalservice = vc
    1 accommodation = vc
    1 accommodationreason = vc
    1 requestedaccommodation = vc
    1 accompby = vc
    1 admitmode = vc
    1 admitsrc = vc
    1 admittype = vc
    1 admitwithmeds = vc
    1 alcdecompdate = vc
    1 alcdecomp_dt_tm = dq8
    1 alcreason = vc
    1 altlevelcare = vc
    1 altlevelcaredate = vc
    1 altlevelcare_dt_tm = dq8
    1 altresultdest = vc
    1 ambulatorycondition = vc
    1 arrivedate = vc
    1 arrive_dt_tm = dq8
    1 assigntolocdate = vc
    1 assigntoloc_dt_tm = dq8
    1 bbdprocedure = vc
    1 chartcompletedate = vc
    1 chartcomplete_dt_tm = dq8
    1 contractstatus = vc
    1 courtesy = vc
    1 createdate = vc
    1 create_dt_tm = dq8
    1 departdate = vc
    1 depart_dt_tm = dq8
    1 diettype = vc
    1 dischdisposition = vc
    1 dischdate = vc
    1 disch_dt_tm = dq8
    1 dischtoloc = vc
    1 docrcvddate = vc
    1 docrcvd_dt_tm = dq8
    1 encntrstatus = vc
    1 encntrtype = vc
    1 encntrtypeclass = vc
    1 estarrivedate = vc
    1 estarrive_dt_tm = dq8
    1 estdepartdate = vc
    1 estdepart_dt_tm = dq8
    1 encntrcreateprsnl = vc
    1 estlengthofstay = vc
    1 financialclass = vc
    1 guarantortype = vc
    1 inpatientadmitdate = vc
    1 inpatientadmit_dt_tm = dq8
    1 isolation = vc
    1 location = vc
    1 bed = vc
    1 building = vc
    1 facility = vc
    1 nurseunit = vc
    1 room = vc
    1 templocation = vc
    1 mentalcategory = vc
    1 mentalhealth = vc
    1 mentalhealthdate = vc
    1 mentalhealth_dt_tm = dq8
    1 patientclass = vc
    1 programservice = vc
    1 psychiatricstatus = vc
    1 readmit = vc
    1 reasonforvisit = vc
    1 referralrcvddate = vc
    1 referralrcvd_dt_tm = dq8
    1 referringcomment = vc
    1 referfacility = vc
    1 region = vc
    1 regdate = vc
    1 reg_dt_tm = dq8
    1 safekeeping = vc
    1 specialtyunit = vc
    1 trauma = vc
    1 traumadate = vc
    1 trauma_dt_tm = dq8
    1 triage = vc
    1 triagedate = vc
    1 triage_dt_tm = dq8
    1 valuable = vc
    1 vip = vc
    1 visitorstatus = vc
    1 zerobalancedate = vc
    1 zerobalance_dt_tm = dq8
    1 orgname = vc
    1 orgaddr1 = vc
    1 orgaddr2 = vc
    1 orgaddr3 = vc
    1 orgaddr4 = vc
    1 orgcity = vc
    1 orgstate = vc
    1 orgzip = vc
    1 orgcountry = vc
    1 orgphone = vc
    1 orgtrustname = vc
    1 guardian_id = f8
    1 guardian_fullname = vc
    1 guardian_title = vc
    1 guardian_prefix = vc
    1 guardian_firstname = vc
    1 guardian_lastname = vc
    1 guardian_namefullformatted = vc
    1 guardian_birth_dt_tm = dq8
    1 guardian_birth_tz = i4
    1 guardian_marital = vc
    1 guarantor_id = f8
    1 guarantor_fullname = vc
    1 guarantor_title = vc
    1 guarantor_prefix = vc
    1 guarantor_firstname = vc
    1 guarantor_lastname = vc
    1 guarantor_namefullformatted = vc
    1 nok_id = f8
    1 nok_fullname = vc
    1 nok_title = vc
    1 nok_prefix = vc
    1 nok_firstname = vc
    1 nok_lastname = vc
    1 nok_namefullformatted = vc
    1 nok_birth_dt_tm = dq8
    1 nok_birth_tz = i4
    1 nok_marital = vc
    1 emc_id = f8
    1 emc_fullname = vc
    1 emc_title = vc
    1 emc_prefix = vc
    1 emc_firstname = vc
    1 emc_lastname = vc
    1 emc_namefullformatted = vc
    1 emc_birth_dt_tm = dq8
    1 emc_birth_tz = i4
    1 emc_marital = vc
    1 emc_home_addr1 = vc
    1 emc_home_addr2 = vc
    1 emc_home_addr3 = vc
    1 emc_home_addr4 = vc
    1 emc_home_city = vc
    1 emc_home_state = vc
    1 emc_home_zip = vc
    1 emc_home_country = vc
    1 pcpdoc_id = f8
    1 pcp_title = vc
    1 pcp_fullname = vc
    1 pcp_firstname = vc
    1 pcp_lastname = vc
    1 pcp_namefullformatted = vc
    1 pcp_addr1 = vc
    1 pcp_addr2 = vc
    1 pcp_addr3 = vc
    1 pcp_addr4 = vc
    1 pcp_city = vc
    1 pcp_state = vc
    1 pcp_zip = vc
    1 pcp_country = vc
    1 pcp_phone = vc
    1 pcp_dmg_addr_cd = f8
    1 pcp_dmg_addr1 = vc
    1 pcp_dmg_addr2 = vc
    1 pcp_dmg_addr3 = vc
    1 pcp_dmg_addr4 = vc
    1 pcp_dmg_city = vc
    1 pcp_dmg_state = vc
    1 pcp_dmg_zip = vc
    1 pcp_dmg_country = vc
    1 pcp_dmg_phone_cd = f8
    1 pcp_dmg_phone = vc
    1 familydoc_id = f8
    1 familydoc_title = vc
    1 familydoc_fullname = vc
    1 familydoc_firstname = vc
    1 familydoc_lastname = vc
    1 familydoc_namefullformatted = vc
    1 familydoc_addr1 = vc
    1 familydoc_addr2 = vc
    1 familydoc_addr3 = vc
    1 familydoc_addr4 = vc
    1 familydoc_city = vc
    1 familydoc_state = vc
    1 familydoc_zip = vc
    1 familydoc_country = vc
    1 familydoc_phone = vc
    1 family_dmg_addr_cd = f8
    1 family_dmg_addr1 = vc
    1 family_dmg_addr2 = vc
    1 family_dmg_addr3 = vc
    1 family_dmg_addr4 = vc
    1 family_dmg_city = vc
    1 family_dmg_state = vc
    1 family_dmg_zip = vc
    1 family_dmg_country = vc
    1 family_dmg_phone_cd = f8
    1 family_dmg_phone = vc
    1 attenddoc_id = f8
    1 attenddoc_title = vc
    1 attenddoc_fullname = vc
    1 attenddoc_firstname = vc
    1 attenddoc_lastname = vc
    1 attenddoc_namefullformatted = vc
    1 attenddoc_addr1 = vc
    1 attenddoc_addr2 = vc
    1 attenddoc_addr3 = vc
    1 attenddoc_addr4 = vc
    1 attenddoc_city = vc
    1 attenddoc_state = vc
    1 attenddoc_zip = vc
    1 attenddoc_country = vc
    1 attenddoc_phone = vc
    1 attenddoc_npi = vc
    1 attend_dmg_addr_cd = f8
    1 attend_dmg_addr1 = vc
    1 attend_dmg_addr2 = vc
    1 attend_dmg_addr3 = vc
    1 attend_dmg_addr4 = vc
    1 attend_dmg_city = vc
    1 attend_dmg_state = vc
    1 attend_dmg_zip = vc
    1 attend_dmg_country = vc
    1 attend_dmg_phone_cd = f8
    1 attend_dmg_phone = vc
    1 referdoc_id = f8
    1 referdoc_title = vc
    1 referdoc_fullname = vc
    1 referdoc_firstname = vc
    1 referdoc_lastname = vc
    1 referdoc_namefullformatted = vc
    1 referdoc_addr1 = vc
    1 referdoc_addr2 = vc
    1 referdoc_addr3 = vc
    1 referdoc_addr4 = vc
    1 referdoc_city = vc
    1 referdoc_state = vc
    1 referdoc_zip = vc
    1 referdoc_country = vc
    1 referdoc_phone = vc
    1 refer_dmg_addr_cd = f8
    1 refer_dmg_addr1 = vc
    1 refer_dmg_addr2 = vc
    1 refer_dmg_addr3 = vc
    1 refer_dmg_addr4 = vc
    1 refer_dmg_city = vc
    1 refer_dmg_state = vc
    1 refer_dmg_zip = vc
    1 refer_dmg_country = vc
    1 refer_dmg_phone_cd = f8
    1 refer_dmg_phone = vc
    1 locationname = vc
    1 locationaddr1 = vc
    1 locationaddr2 = vc
    1 locationaddr3 = vc
    1 locationaddr4 = vc
    1 locationcity = vc
    1 locationstate = vc
    1 locationzip = vc
    1 locationcountry = vc
    1 nuphone = vc
    1 wlaccommodation = vc
    1 wladmittype = vc
    1 wlestlengthprocedure = vc
    1 wlestarrivedate = vc
    1 wlautobloodind = vc
    1 wlcommentsredsch = vc
    1 wldeclinestatus = vc
    1 wldelaystatus = vc
    1 wldeclinestatusdate = vc
    1 wldeclinestatus_dt_tm = dq8
    1 wldelaystatusdate = vc
    1 wldelaystatus_dt_tm = dq8
    1 wlfinclass = vc
    1 wlfinclassdate = vc
    1 wlfinclass_dt_tm = dq8
    1 wllocation = vc
    1 wlfacility = vc
    1 wlbuilding = vc
    1 wlnurseunit = vc
    1 wlroom = vc
    1 wlbed = vc
    1 wlmedicalservice = vc
    1 wlothermedcondition = vc
    1 wlplannedadmitdate = vc
    1 wlplannedadmit_dt_tm = dq8
    1 planned_procedure_cd = f8
    1 wlplanprocedure = vc
    1 wlplanproceduredate = vc
    1 wlplanprocedure_dt_tm = dq8
    1 wlpreadmitattendind = vc
    1 wlpreadmitclinapptdate = vc
    1 wlpreadmitclinappt_dt_tm = dq8
    1 wlprovadmitdate = vc
    1 wlprovadmit_dt_tm = dq8
    1 wlreasonforchange = vc
    1 wlreasonforremovalcd = vc
    1 wlreasonforremoval = vc
    1 wlrecommenddate = vc
    1 wlrecommend_dt_tm = dq8
    1 wlremovaldate = vc
    1 wlremoval_dt_tm = dq8
    1 wlrequestedloc = vc
    1 wlurgency = vc
    1 wlurgencydate = vc
    1 wlurgency_dt_tm = dq8
    1 wlstandby = vc
    1 wlstatusreviewdate = vc
    1 wlstatusreview_dt_tm = dq8
    1 wlstatusreview = vc
    1 wlstatus = vc
    1 wlstatusdate = vc
    1 wlstatus_dt_tm = dq8
    1 wlpendnotifydate = vc
    1 wlpendnotify_dt_tm = dq8
    1 wlpendacceptdate = vc
    1 wlpendaccept_dt_tm = dq8
    1 wlpendplacepriority = vc
    1 wlpendplaceprioritydate = vc
    1 wlpendplacepriority_dt_tm = dq8
    1 wladmitcategory = vc
    1 wladmitbooking = vc
    1 wlmanagement = vc
    1 wlstatusenddate = vc
    1 wlstatusend_dt_tm = dq8
    1 wlreferralsource = vc
    1 wlservicetyperequested = vc
    1 wlfunctionaldef = vc
    1 wlfunctionaldefcause = vc
    1 wlsupraservicerequest = vc
    1 wlcommissionerref = vc
    1 wlappt = vc
    1 wlreferral_type = vc
    1 wlreferralreason = vc
    1 wlattendance = vc
    1 wlreferraldate = vc
    1 wlreferral_dt_tm = dq8
    1 wlattenddocclinicalservice = vc
    1 wlcontractstatus = vc
    1 wlestadmitdate = vc
    1 wlestadmit_dt_tm = dq8
    1 wlplannedops = vc
    1 wllastdnadate = vc
    1 wllastdna_dt_tm = dq8
    1 wladmitofferoutcome = vc
    1 wladmitguardate = vc
    1 wladmitguar_dt_tm = dq8
    1 wladmitdecisiondate = vc
    1 wladmitdecision_dt_tm = dq8
    1 wlprevprovadmitdate = vc
    1 wlprevprovadmit_dt_tm = dq8
    1 wloperation = vc
    1 wlanesthetic = vc
    1 wlsuspendeddays = vc
    1 wlwaitingstartdate = vc
    1 wlwaitingstart_dt_tm = dq8
    1 wlwaitingenddate = vc
    1 wlwaitingend_dt_tm = dq8
    1 wladjwaitingstartdate = vc
    1 wladjwaitingstart_dt_tm = dq8
    1 wlappttype = vc
    1 wlapptsynonym = vc
    1 wlresource = vc
    1 wlrequesteddate = vc
    1 wlrequested_dt_tm = dq8
    1 wlscheduledate = vc
    1 wlschedule_dt_tm = dq8
    1 wlapptlocation = vc
    1 wlorigrequestrvcdate = vc
    1 wlorigrequestrvc_dt_tm = dq8
    1 comment_long_text_id = f8
    1 wlcomment = vc
    1 expectedwaittime = vc
    1 sch_event_id = f8
    1 schedule_id = f8
    1 schedule_seq = i4
    1 appt_location_cd = f8
    1 resource_cd = f8
    1 apptbegdate = vc
    1 apptbeg_dt_tm = dq8
    1 apptenddate = vc
    1 apptend_dt_tm = dq8
    1 apptduration = vc
    1 appt_type_cd = f8
    1 appttypedisplay = vc
    1 appttypedesc = vc
    1 apptdatetime = vc
    1 apptday = vc
    1 prevapptdatetime = vc
    1 prevappt_dt_tm = dq8
    1 apptdesc = vc
    1 apptresourcemnem = vc
    1 apptresourcedesc = vc
    1 procedure = vc
    1 preparations = vc
    1 directions = vc
    1 nuname = vc
    1 nuphone = vc
    1 contactdetails = vc
    1 apptfacilityname = vc
    1 apptfacilityaddr1 = vc
    1 apptfacilityaddr2 = vc
    1 apptfacilityaddr3 = vc
    1 apptfacilityaddr4 = vc
    1 apptfacilitycity = vc
    1 apptfacilitystate = vc
    1 apptfacilityzip = vc
    1 apptfacilitycountry = vc
    1 apptlocationname = vc
    1 apptlocationaddr1 = vc
    1 apptlocationaddr2 = vc
    1 apptlocationaddr3 = vc
    1 apptlocationaddr4 = vc
    1 apptlocationcity = vc
    1 apptlocationstate = vc
    1 apptlocationzip = vc
    1 apptlocationcountry = vc
    1 apptlocationphone = vc
    1 patient_fin = vc
    1 unformatted_fin = vc
    1 apptfacilityphone = vc
    1 patient_corraddr1 = vc
    1 patient_corraddr2 = vc
    1 patient_corraddr3 = vc
    1 patient_corraddr4 = vc
    1 patient_corrzip = vc
    1 patient_corrcity = vc
    1 patient_corrstate = vc
    1 patient_corrcountry = vc
    1 unformatted_mrn = vc
    1 ubrn = vc
    1 apptbegtime = vc
    1 apptlocationext = vc
    1 apptlocbusaddr1 = vc
    1 apptlocbusaddr2 = vc
    1 apptlocbusaddr3 = vc
    1 apptlocbusaddr4 = vc
    1 apptlocbuscity = vc
    1 apptlocbusstate = vc
    1 apptlocbuszip = vc
    1 apptlocbuscountry = vc
    1 apptlocbusphone = vc
    1 apptlocbusext = vc
    1 apptlocsecbusaddr1 = vc
    1 apptlocsecbusaddr2 = vc
    1 apptlocsecbusaddr3 = vc
    1 apptlocsecbusaddr4 = vc
    1 apptlocsecbuscity = vc
    1 apptlocsecbusstate = vc
    1 apptlocsecbuszip = vc
    1 apptlocsecbuscountry = vc
    1 apptlocsecbusphone = vc
    1 apptlocsecbusext = vc
    1 apptbuildingaddr1 = vc
    1 apptbuildingaddr2 = vc
    1 apptbuildingaddr3 = vc
    1 apptbuildingaddr4 = vc
    1 apptbuildingcity = vc
    1 apptbuildingstate = vc
    1 apptbuildingzip = vc
    1 apptbuildingcountry = vc
    1 apptbldbusaddr1 = vc
    1 apptbldbusaddr2 = vc
    1 apptbldbusaddr3 = vc
    1 apptbldbusaddr4 = vc
    1 apptbldbuscity = vc
    1 apptbldbusstate = vc
    1 apptbldbuszip = vc
    1 apptbldbuscountry = vc
    1 apptbldbusphone = vc
    1 apptbldbusext = vc
    1 apptbldsecbusaddr1 = vc
    1 apptbldsecbusaddr2 = vc
    1 apptbldsecbusaddr3 = vc
    1 apptbldsecbusaddr4 = vc
    1 apptbldsecbuscity = vc
    1 apptbldsecbusstate = vc
    1 apptbldsecbuszip = vc
    1 apptbldsecbuscountry = vc
    1 apptbldsecbusphone = vc
    1 apptbldsecbusext = vc
    1 struct_created = i2
    1 extended_api_flag = i2
    1 appt_visit_reason = vc
    1 patient_marital_type = vc
    1 patient_bus_phone = vc
    1 patient_bus_phone_ext = vc
    1 patient_mobile_phone = vc
    1 patient_home_email = vc
    1 pat_employer_name = vc
    1 pat_employer_status = vc
    1 pat_employer_occ = vc
    1 pat_employer_addr1 = vc
    1 pat_employer_addr2 = vc
    1 pat_employer_addr3 = vc
    1 pat_employer_addr4 = vc
    1 pat_employer_city = vc
    1 pat_employer_state = vc
    1 pat_employer_zip = vc
    1 pat_employer_country = vc
    1 pat_employerphone = vc
    1 guardian_personreltn = vc
    1 guardian_home_phone = vc
    1 guardian_mobile_phone = vc
    1 guardian_bus_phone = vc
    1 guardian_bus_phone_ext = vc
    1 guarantor_sex = vc
    1 guarantor_dob = vc
    1 guarantor_birth_dt_tm = dq8
    1 guarantor_birth_tz = i4
    1 guarantor_ssn = vc
    1 guarantor_org_name = vc
    1 guarantor_addr1 = vc
    1 guarantor_addr2 = vc
    1 guarantor_addr3 = vc
    1 guarantor_addr4 = vc
    1 guarantor_city = vc
    1 guarantor_state = vc
    1 guarantor_zip = vc
    1 guarantor_country = vc
    1 guarantor_personreltn = vc
    1 guarantor_home_phone = vc
    1 guarantor_mobile_phone = vc
    1 guarantor_bus_phone = vc
    1 guarantor_bus_phone_ext = vc
    1 guarantor_home_email = vc
    1 guarantor_employer_name = vc
    1 guarantor_employer_status = vc
    1 guarantor_employer_occ = vc
    1 guarantor_employer_addr1 = vc
    1 guarantor_employer_addr2 = vc
    1 guarantor_employer_addr3 = vc
    1 guarantor_employer_addr4 = vc
    1 guarantor_employer_city = vc
    1 guarantor_employer_state = vc
    1 guarantor_employer_zip = vc
    1 guarantor_employer_country = vc
    1 guarantor_employerphone = vc
    1 guarantor_marital = vc
    1 guarantor02_id = f8
    1 guarantor02_sex = vc
    1 guarantor02_dob = vc
    1 guarantor02_birth_dt_tm = dq8
    1 guarantor02_birth_tz = i4
    1 guarantor02_ssn = vc
    1 guarantor02_org_name = vc
    1 guarantor02_addr1 = vc
    1 guarantor02_addr2 = vc
    1 guarantor02_addr3 = vc
    1 guarantor02_addr4 = vc
    1 guarantor02_city = vc
    1 guarantor02_state = vc
    1 guarantor02_zip = vc
    1 guarantor02_country = vc
    1 guarantor02_fullname = vc
    1 guarantor02_namefullformatted = vc
    1 guarantor02_title = vc
    1 guarantor02_prefix = vc
    1 guarantor02_firstname = vc
    1 guarantor02_lastname = vc
    1 guarantor02_personreltn = vc
    1 guarantor02_home_phone = vc
    1 guarantor02_mobile_phone = vc
    1 guarantor02_home_email = vc
    1 guarantor02_bus_phone = vc
    1 guarantor02_bus_phone_ext = vc
    1 guarantor02_employer_name = vc
    1 guarantor02_employer_status = vc
    1 guarantor02_employer_occ = vc
    1 guarantor02_employer_addr1 = vc
    1 guarantor02_employer_addr2 = vc
    1 guarantor02_employer_addr3 = vc
    1 guarantor02_employer_addr4 = vc
    1 guarantor02_employer_city = vc
    1 guarantor02_employer_state = vc
    1 guarantor02_employer_zip = vc
    1 guarantor02_employer_country = vc
    1 guarantor02_employerphone = vc
    1 guarantor02_marital = vc
    1 nok_personreltn = vc
    1 nok_home_phone = vc
    1 nok_mobile_phone = vc
    1 nok_bus_phone = vc
    1 nok_bus_phone_ext = vc
    1 nok_home_addr1 = vc
    1 nok_home_addr2 = vc
    1 nok_home_addr3 = vc
    1 nok_home_addr4 = vc
    1 nok_home_city = vc
    1 nok_home_state = vc
    1 nok_home_zip = vc
    1 nok_home_country = vc
    1 emc_personreltn = vc
    1 emc_home_phone = vc
    1 emc_mobile_phone = vc
    1 emc_bus_phone = vc
    1 emc_bus_phone_ext = vc
    1 sub01_fullname = vc
    1 sub01_title = vc
    1 sub01_prefix = vc
    1 sub01_firstname = vc
    1 sub01_middlename = vc
    1 sub01_lastname = vc
    1 sub01_personreltn = vc
    1 sub01_sex = vc
    1 sub01_dob = vc
    1 sub01_birth_dt_tm = dq8
    1 sub01_birth_tz = i4
    1 sub01_home_phone = vc
    1 sub01_mobile_phone = vc
    1 sub01_bus_phone = vc
    1 sub01_bus_phone_ext = vc
    1 sub01_addr1 = vc
    1 sub01_addr2 = vc
    1 sub01_addr3 = vc
    1 sub01_addr4 = vc
    1 sub01_city = vc
    1 sub01_state = vc
    1 sub01_zip = vc
    1 sub01_country = vc
    1 sub01_employer_name = vc
    1 sub01_hp_name = vc
    1 sub01_hp_carrier_name = vc
    1 sub01_hp_beg_date = vc
    1 sub01_hp_beg_dt_tm = dq8
    1 sub01_hp_end_date = vc
    1 sub01_policy_nbr = vc
    1 sub01_group_nbr = vc
    1 sub01_group_name = vc
    1 sub01_hp_copay = vc
    1 sub01_name_on_card = vc
    1 sub01_hp_contact_name = vc
    1 sub01_hp_contact_phone = vc
    1 sub01_hp_contact_phone_ext = vc
    1 sub01_carrier_addr1 = vc
    1 sub01_carrier_addr2 = vc
    1 sub01_carrier_addr3 = vc
    1 sub01_carrier_addr4 = vc
    1 sub01_carrier_city = vc
    1 sub01_carrier_state = vc
    1 sub01_carrier_zip = vc
    1 sub01_carrier_country = vc
    1 sub01_id = f8
    1 sub01_hp_member_nbr = vc
    1 sub01_hp_subs_member_nbr = vc
    1 sub01_hp_addr1 = vc
    1 sub01_hp_addr2 = vc
    1 sub01_hp_addr3 = vc
    1 sub01_hp_addr4 = vc
    1 sub01_hp_city = vc
    1 sub01_hp_state = vc
    1 sub01_hp_zip = vc
    1 sub01_hp_country = vc
    1 sub01_hp_verify_phone = vc
    1 sub01_hp_auth01_authno = vc
    1 sub01_hp_auth01_authphone = vc
    1 sub01_employer_status = vc
    1 sub01_employer_occ = vc
    1 sub01_employer_addr1 = vc
    1 sub01_employer_addr2 = vc
    1 sub01_employer_addr3 = vc
    1 sub01_employer_addr4 = vc
    1 sub01_employer_city = vc
    1 sub01_employer_state = vc
    1 sub01_employer_zip = vc
    1 sub01_employer_country = vc
    1 sub01_employerphone = vc
    1 sub01_encntr_plan_reltn_id = f8
    1 sub02_fullname = vc
    1 sub02_title = vc
    1 sub02_prefix = vc
    1 sub02_firstname = vc
    1 sub02_middlename = vc
    1 sub02_lastname = vc
    1 sub02_personreltn = vc
    1 sub02_sex = vc
    1 sub02_dob = vc
    1 sub02_birth_dt_tm = dq8
    1 sub02_birth_tz = i4
    1 sub02_home_phone = vc
    1 sub02_mobile_phone = vc
    1 sub02_bus_phone = vc
    1 sub02_bus_phone_ext = vc
    1 sub02_addr1 = vc
    1 sub02_addr2 = vc
    1 sub02_addr3 = vc
    1 sub02_addr4 = vc
    1 sub02_city = vc
    1 sub02_state = vc
    1 sub02_zip = vc
    1 sub02_country = vc
    1 sub02_employer_name = vc
    1 sub02_hp_name = vc
    1 sub02_hp_carrier_name = vc
    1 sub02_hp_beg_date = vc
    1 sub02_hp_beg_dt_tm = dq8
    1 sub02_hp_end_date = vc
    1 sub02_policy_nbr = vc
    1 sub02_group_nbr = vc
    1 sub02_group_name = vc
    1 sub02_hp_copay = vc
    1 sub02_name_on_card = vc
    1 sub02_hp_contact_name = vc
    1 sub02_hp_contact_phone = vc
    1 sub02_hp_contact_phone_ext = vc
    1 sub02_carrier_addr1 = vc
    1 sub02_carrier_addr2 = vc
    1 sub02_carrier_addr3 = vc
    1 sub02_carrier_addr4 = vc
    1 sub02_carrier_city = vc
    1 sub02_carrier_state = vc
    1 sub02_carrier_zip = vc
    1 sub02_carrier_country = vc
    1 sub02_id = f8
    1 sub02_hp_member_nbr = vc
    1 sub02_hp_subs_member_nbr = vc
    1 sub02_hp_addr1 = vc
    1 sub02_hp_addr2 = vc
    1 sub02_hp_addr3 = vc
    1 sub02_hp_addr4 = vc
    1 sub02_hp_city = vc
    1 sub02_hp_state = vc
    1 sub02_hp_zip = vc
    1 sub02_hp_country = vc
    1 sub02_hp_verify_phone = vc
    1 sub02_hp_auth01_authno = vc
    1 sub02_hp_auth01_authphone = vc
    1 sub02_employer_status = vc
    1 sub02_employer_occ = vc
    1 sub02_employer_addr1 = vc
    1 sub02_employer_addr2 = vc
    1 sub02_employer_addr3 = vc
    1 sub02_employer_addr4 = vc
    1 sub02_employer_city = vc
    1 sub02_employer_state = vc
    1 sub02_employer_zip = vc
    1 sub02_employer_country = vc
    1 sub02_employerphone = vc
    1 sub02_encntr_plan_reltn_id = f8
    1 sub03_fullname = vc
    1 sub03_title = vc
    1 sub03_prefix = vc
    1 sub03_firstname = vc
    1 sub03_middlename = vc
    1 sub03_lastname = vc
    1 sub03_personreltn = vc
    1 sub03_sex = vc
    1 sub03_dob = vc
    1 sub03_birth_dt_tm = dq8
    1 sub03_birth_tz = i4
    1 sub03_home_phone = vc
    1 sub03_mobile_phone = vc
    1 sub03_bus_phone = vc
    1 sub03_bus_phone_ext = vc
    1 sub03_addr1 = vc
    1 sub03_addr2 = vc
    1 sub03_addr3 = vc
    1 sub03_addr4 = vc
    1 sub03_city = vc
    1 sub03_state = vc
    1 sub03_zip = vc
    1 sub03_country = vc
    1 sub03_employer_name = vc
    1 sub03_hp_name = vc
    1 sub03_hp_carrier_name = vc
    1 sub03_hp_beg_date = vc
    1 sub03_hp_beg_dt_tm = dq8
    1 sub03_hp_end_date = vc
    1 sub03_policy_nbr = vc
    1 sub03_group_nbr = vc
    1 sub03_group_name = vc
    1 sub03_hp_copay = vc
    1 sub03_name_on_card = vc
    1 sub03_hp_contact_name = vc
    1 sub03_hp_contact_phone = vc
    1 sub03_hp_contact_phone_ext = vc
    1 sub03_carrier_addr1 = vc
    1 sub03_carrier_addr2 = vc
    1 sub03_carrier_addr3 = vc
    1 sub03_carrier_addr4 = vc
    1 sub03_carrier_city = vc
    1 sub03_carrier_state = vc
    1 sub03_carrier_zip = vc
    1 sub03_carrier_country = vc
    1 sub03_id = f8
    1 sub03_hp_member_nbr = vc
    1 sub03_hp_subs_member_nbr = vc
    1 sub03_hp_addr1 = vc
    1 sub03_hp_addr2 = vc
    1 sub03_hp_addr3 = vc
    1 sub03_hp_addr4 = vc
    1 sub03_hp_city = vc
    1 sub03_hp_state = vc
    1 sub03_hp_zip = vc
    1 sub03_hp_country = vc
    1 sub03_hp_verify_phone = vc
    1 sub03_hp_auth01_authno = vc
    1 sub03_hp_auth01_authphone = vc
    1 sub03_employer_status = vc
    1 sub03_employer_occ = vc
    1 sub03_employer_addr1 = vc
    1 sub03_employer_addr2 = vc
    1 sub03_employer_addr3 = vc
    1 sub03_employer_addr4 = vc
    1 sub03_employer_city = vc
    1 sub03_employer_state = vc
    1 sub03_employer_zip = vc
    1 sub03_employer_country = vc
    1 sub03_employerphone = vc
    1 sub03_encntr_plan_reltn_id = f8
    1 sub01_name_on_card_last = vc
    1 sub01_name_on_card_first = vc
    1 sub01_name_on_card_middle = vc
    1 sub01_name_on_card_suffix = vc
    1 sub02_name_on_card_last = vc
    1 sub02_name_on_card_first = vc
    1 sub02_name_on_card_middle = vc
    1 sub02_name_on_card_suffix = vc
    1 sub03_name_on_card_last = vc
    1 sub03_name_on_card_first = vc
    1 sub03_name_on_card_middle = vc
    1 sub03_name_on_card_suffix = vc
    1 patient_namefullformatted = vc
    1 patient_vip_status = vc
    1 accident01_dt_tm = dq8
    1 accident01_accident = vc
    1 regprsnl_id = f8
    1 regprsnl_title = vc
    1 regprsnl_fullname = vc
    1 regprsnl_firstname = vc
    1 regprsnl_lastname = vc
    1 regprsnl_namefullformatted = vc
    1 admitdoc_id = f8
    1 admitdoc_title = vc
    1 admitdoc_fullname = vc
    1 admitdoc_firstname = vc
    1 admitdoc_lastname = vc
    1 admitdoc_namefullformatted = vc
    1 admitdoc_addr1 = vc
    1 admitdoc_addr2 = vc
    1 admitdoc_addr3 = vc
    1 admitdoc_addr4 = vc
    1 admitdoc_city = vc
    1 admitdoc_state = vc
    1 admitdoc_zip = vc
    1 admitdoc_country = vc
    1 admitdoc_phone = vc
    1 admitdoc_npi = vc
    1 encntr_facilitytaxid = vc
    1 encntr_facilitynpi = vc
    1 patient_dxcode = vc
    1 dxcode_description = vc
    1 placeofservice = vc
    1 facilityphone = vc
    1 facilityaddr1 = vc
    1 facilityaddr2 = vc
    1 facilityaddr3 = vc
    1 facilityaddr4 = vc
    1 facilitycity = vc
    1 facilitystate = vc
    1 facilityzip = vc
    1 facilitycountry = vc
  )
 ENDIF
 IF ((validate (temp_post_doc_rec_input->person_id ,- (999 ) ) != - (999 ) ) )
  IF ((temp_post_doc_rec_input->person_id < 0 ) )
   SET post_doc_rec->person_id = cnvtreal (trim ( $DPERSON_ID ,3 ) )
  ELSE
   SET post_doc_rec->person_id = temp_post_doc_rec_input->person_id
  ENDIF
 ELSE
  SET post_doc_rec->person_id = cnvtreal (trim ( $DPERSON_ID ,3 ) )
 ENDIF
 IF ((validate (temp_post_doc_rec_input->encntr_id ,- (999 ) ) != - (999 ) ) )
  IF ((temp_post_doc_rec_input->encntr_id < 0 ) )
   SET post_doc_rec->encntr_id = cnvtreal (trim ( $DENCNTR_ID ,3 ) )
  ELSE
   SET post_doc_rec->encntr_id = temp_post_doc_rec_input->encntr_id
  ENDIF
 ELSE
  SET post_doc_rec->encntr_id = cnvtreal (trim ( $DENCNTR_ID ,3 ) )
 ENDIF
 IF ((validate (temp_post_doc_rec_input->sch_event_id ,- (999 ) ) != - (999 ) ) )
  IF ((temp_post_doc_rec_input->sch_event_id < 0 ) )
   SET post_doc_rec->sch_event_id = cnvtreal (trim ( $DSCH_EVENT_ID ,3 ) )
  ELSE
   SET post_doc_rec->sch_event_id = temp_post_doc_rec_input->sch_event_id
  ENDIF
 ELSE
  SET post_doc_rec->sch_event_id = cnvtreal (trim ( $DSCH_EVENT_ID ,3 ) )
 ENDIF
 IF ((validate (temp_post_doc_rec_input->schedule_id ,- (999 ) ) != - (999 ) ) )
  IF ((temp_post_doc_rec_input->schedule_id < 0 ) )
   SET post_doc_rec->schedule_id = cnvtreal (trim ( $DSCHEDULE_ID ,3 ) )
  ELSE
   SET post_doc_rec->schedule_id = temp_post_doc_rec_input->schedule_id
  ENDIF
 ELSE
  SET post_doc_rec->schedule_id = cnvtreal (trim ( $DSCHEDULE_ID ,3 ) )
 ENDIF
 
 ;002
 ; EXECUTE ccps_drv_post_doc
 EXECUTE cov_ccps_drv_post_doc
 ;
 
 
 /**************************************************************/
 ;006
 ; overwrite record structure with dob data
 declare dob		= dq8 with noconstant ;007
 declare dob_tz		= i4 with noconstant(0) ;007
 
 ; patient
 set dob = post_doc_rec->patient_birth_dt_tm
 set dob_tz = post_doc_rec->patient_birth_tz
 set post_doc_rec->patient_birth_dt_tm = cnvtdatetimeutc(datetimezone(dob, dob_tz), 1)
  
 ; nok
 set dob = post_doc_rec->nok_birth_dt_tm
 set dob_tz = post_doc_rec->nok_birth_tz
 set post_doc_rec->nok_birth_dt_tm = cnvtdatetimeutc(datetimezone(dob, dob_tz), 1)
 
 ; emc
 set dob = post_doc_rec->emc_birth_dt_tm
 set dob_tz = post_doc_rec->emc_birth_tz
 set post_doc_rec->emc_birth_dt_tm = cnvtdatetimeutc(datetimezone(dob, dob_tz), 1)
 
 ; guarantor
 set dob = post_doc_rec->guarantor_birth_dt_tm
 set dob_tz = post_doc_rec->guarantor_birth_tz
 set post_doc_rec->guarantor_birth_dt_tm = cnvtdatetimeutc(datetimezone(dob, dob_tz), 1)
 
 ; sub01
 set dob = post_doc_rec->sub01_birth_dt_tm
 set dob_tz = post_doc_rec->sub01_birth_tz
 set post_doc_rec->sub01_birth_dt_tm = cnvtdatetimeutc(datetimezone(dob, dob_tz), 1)
 
 ; sub02
 set dob = post_doc_rec->sub02_birth_dt_tm
 set dob_tz = post_doc_rec->sub02_birth_tz
 set post_doc_rec->sub02_birth_dt_tm = cnvtdatetimeutc(datetimezone(dob, dob_tz), 1)
 
 ; sub03
 set dob = post_doc_rec->sub03_birth_dt_tm
 set dob_tz = post_doc_rec->sub03_birth_tz
 set post_doc_rec->sub03_birth_dt_tm = cnvtdatetimeutc(datetimezone(dob, dob_tz), 1)
  
 
 /**************************************************************/
 ;002
 ; overwrite record structure with patient age data
 set post_doc_rec->patient_age = evaluate2(
	if (post_doc_rec->disch_dt_tm > 0) ;003
		if ((post_doc_rec->disch_dt_tm between cnvtdatetime("01-JAN-1900 000000") and cnvtdatetime("01-JAN-2000 000000"))
			or (post_doc_rec->disch_dt_tm > sysdate))
 
			cnvtage(post_doc_rec->patient_birth_dt_tm)
		else
			cnvtage(post_doc_rec->patient_birth_dt_tm, post_doc_rec->disch_dt_tm, 0)
		endif
	else
		cnvtage(post_doc_rec->patient_birth_dt_tm)
	endif
	)
 
call echorecord(post_doc_rec)

 
 /**************************************************************/
 
 DECLARE _createfonts (dummy ) = null WITH protect
 DECLARE _createpens (dummy ) = null WITH protect
 DECLARE query1 (dummy ) = null WITH protect
 DECLARE pagebreak (dummy ) = null WITH protect
 DECLARE finalizereport ((ssendreport = vc ) ) = null WITH protect
 DECLARE facilityheader ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE facilityheaderabs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE patientinformation ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE patientinformationabs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE guarantorinformation ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE guarantorinformationabs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH
 protect
 DECLARE contactinformation ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE contactinformationabs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE ins1 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE ins1abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE ins2 ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE ins2abs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE visitinfo ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE visitinfoabs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE footer ((ncalc = i2 ) ) = f8 WITH protect
 DECLARE footerabs ((ncalc = i2 ) ,(offsetx = f8 ) ,(offsety = f8 ) ) = f8 WITH protect
 DECLARE initializereport (dummy ) = null WITH protect
 DECLARE _hreport = i4 WITH noconstant (0 ) ,protect
 DECLARE _yoffset = f8 WITH noconstant (0.0 ) ,protect
 DECLARE _xoffset = f8 WITH noconstant (0.0 ) ,protect
 DECLARE rpt_render = i2 WITH constant (0 ) ,protect
 DECLARE _crlf = vc WITH constant (concat (char (13 ) ,char (10 ) ) ) ,protect
 DECLARE rpt_calcheight = i2 WITH constant (1 ) ,protect
 DECLARE _yshift = f8 WITH noconstant (0.0 ) ,protect
 DECLARE _xshift = f8 WITH noconstant (0.0 ) ,protect
 DECLARE _sendto = vc WITH noconstant ( $OUTDEV ) ,protect
 DECLARE _rpterr = i2 WITH noconstant (0 ) ,protect
 DECLARE _rptstat = i2 WITH noconstant (0 ) ,protect
 DECLARE _oldfont = i4 WITH noconstant (0 ) ,protect
 DECLARE _oldpen = i4 WITH noconstant (0 ) ,protect
 DECLARE _dummyfont = i4 WITH noconstant (0 ) ,protect
 DECLARE _dummypen = i4 WITH noconstant (0 ) ,protect
 DECLARE _fdrawheight = f8 WITH noconstant (0.0 ) ,protect
 DECLARE _rptpage = i4 WITH noconstant (0 ) ,protect
 DECLARE _diotype = i2 WITH noconstant (8 ) ,protect
 DECLARE _outputtype = i2 WITH noconstant (rpt_pdf ) ,protect
 DECLARE _helvetica14b0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _helvetica10b0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _helvetica200 = i4 WITH noconstant (0 ) ,protect
 DECLARE _times100 = i4 WITH noconstant (0 ) ,protect
 DECLARE _helvetica140 = i4 WITH noconstant (0 ) ,protect
 DECLARE _helvetica100 = i4 WITH noconstant (0 ) ,protect
 DECLARE _helvetica160 = i4 WITH noconstant (0 ) ,protect
 DECLARE _helvetica10biu0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _pen13s0c0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _pen30s0c0 = i4 WITH noconstant (0 ) ,protect
 DECLARE _pen14s0c0 = i4 WITH noconstant (0 ) ,protect
 DECLARE dd_printer_name = vc WITH noconstant (" " ) ,protect
 SUBROUTINE  query1 (dummy )
  SELECT INTO  $OUTDEV
   FROM (dummyt d1 )
   PLAN (d1 )
   HEAD REPORT
    _fenddetail = (rptreport->m_pageheight - rptreport->m_marginbottom ) ,
    _fenddetail = (_fenddetail - footer (rpt_calcheight ) )
   HEAD PAGE
    IF ((curpage > 1 ) ) dummy_val = pagebreak (0 )
    ENDIF
   DETAIL
    _fdrawheight = facilityheader (rpt_calcheight ) ,
    IF ((_fdrawheight > 0 ) )
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight +
      patientinformation (rpt_calcheight ) )
     ENDIF
     ,
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight +
      guarantorinformation (rpt_calcheight ) )
     ENDIF
     ,
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight +
      contactinformation (rpt_calcheight ) )
     ENDIF
     ,
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + ins1 (
       rpt_calcheight ) )
     ENDIF
     ,
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + ins2 (
       rpt_calcheight ) )
     ENDIF
     ,
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + visitinfo (
       rpt_calcheight ) )
     ENDIF
    ENDIF
    ,
    IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
     BREAK
    ENDIF
    ,dummy_val = facilityheader (rpt_render ) ,
    _fdrawheight = patientinformation (rpt_calcheight ) ,
    IF ((_fdrawheight > 0 ) )
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight +
      guarantorinformation (rpt_calcheight ) )
     ENDIF
     ,
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight +
      contactinformation (rpt_calcheight ) )
     ENDIF
     ,
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + ins1 (
       rpt_calcheight ) )
     ENDIF
     ,
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + ins2 (
       rpt_calcheight ) )
     ENDIF
     ,
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + visitinfo (
       rpt_calcheight ) )
     ENDIF
    ENDIF
    ,
    IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
     BREAK
    ENDIF
    ,dummy_val = patientinformation (rpt_render ) ,
    _fdrawheight = guarantorinformation (rpt_calcheight ) ,
    IF ((_fdrawheight > 0 ) )
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight +
      contactinformation (rpt_calcheight ) )
     ENDIF
     ,
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + ins1 (
       rpt_calcheight ) )
     ENDIF
     ,
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + ins2 (
       rpt_calcheight ) )
     ENDIF
     ,
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + visitinfo (
       rpt_calcheight ) )
     ENDIF
    ENDIF
    ,
    IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
     BREAK
    ENDIF
    ,dummy_val = guarantorinformation (rpt_render ) ,
    _fdrawheight = contactinformation (rpt_calcheight ) ,
    IF ((_fdrawheight > 0 ) )
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + ins1 (
       rpt_calcheight ) )
     ENDIF
     ,
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + ins2 (
       rpt_calcheight ) )
     ENDIF
     ,
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + visitinfo (
       rpt_calcheight ) )
     ENDIF
    ENDIF
    ,
    IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
     BREAK
    ENDIF
    ,dummy_val = contactinformation (rpt_render ) ,
    _fdrawheight = ins1 (rpt_calcheight ) ,
    IF ((_fdrawheight > 0 ) )
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + ins2 (
       rpt_calcheight ) )
     ENDIF
     ,
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + visitinfo (
       rpt_calcheight ) )
     ENDIF
    ENDIF
    ,
    IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
     BREAK
    ENDIF
    ,dummy_val = ins1 (rpt_render ) ,
    _fdrawheight = ins2 (rpt_calcheight ) ,
    IF ((_fdrawheight > 0 ) )
     IF ((_fenddetail >= (_yoffset + _fdrawheight ) ) ) _fdrawheight = (_fdrawheight + visitinfo (
       rpt_calcheight ) )
     ENDIF
    ENDIF
    ,
    IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
     BREAK
    ENDIF
    ,dummy_val = ins2 (rpt_render ) ,
    _fdrawheight = visitinfo (rpt_calcheight ) ,
    IF (((_yoffset + _fdrawheight ) > _fenddetail ) )
     BREAK
    ENDIF
    ,dummy_val = visitinfo (rpt_render )
   FOOT PAGE
    _yhold = _yoffset ,
    _yoffset = _fenddetail ,
    dummy_val = footer (rpt_render ) ,
    _yoffset = _yhold
   WITH nocounter ,separator = " " ,format
  ;end select
 END ;Subroutine
 SUBROUTINE  pagebreak (dummy )
  SET _rptpage = uar_rptendpage (_hreport )
  SET _rptpage = uar_rptstartpage (_hreport )
  SET _yoffset = rptreport->m_margintop
 END ;Subroutine
 SUBROUTINE  finalizereport (ssendreport )
  SET _rptpage = uar_rptendpage (_hreport )
  SET _rptstat = uar_rptendreport (_hreport )
  DECLARE sfilename = vc WITH noconstant (trim (ssendreport ) ) ,private
  DECLARE bprint = i2 WITH noconstant (0 ) ,private
  IF ((textlen (sfilename ) > 0 ) )
   SET bprint = checkqueue (sfilename )
   IF (bprint )
    EXECUTE cpm_create_file_name "RPT" ,
    "PS"
    SET sfilename = cpm_cfn_info->file_name_path
   ENDIF
  ENDIF
  SET _rptstat = uar_rptprinttofile (_hreport ,nullterm (sfilename ) )
  IF (bprint )
   SET spool value (sfilename ) value (ssendreport ) WITH deleted
  ENDIF
  DECLARE _errorfound = i2 WITH noconstant (0 ) ,protect
  DECLARE _errcnt = i2 WITH noconstant (0 ) ,protect
  SET _errorfound = uar_rptfirsterror (_hreport ,rpterror )
  WHILE ((_errorfound = rpt_errorfound )
  AND (_errcnt < 512 ) )
   SET _errcnt = (_errcnt + 1 )
   SET stat = alterlist (rpterrors->errors ,_errcnt )
   SET rpterrors->errors[_errcnt ].m_severity = rpterror->m_severity
   SET rpterrors->errors[_errcnt ].m_text = rpterror->m_text
   SET rpterrors->errors[_errcnt ].m_source = rpterror->m_source
   SET _errorfound = uar_rptnexterror (_hreport ,rpterror )
  ENDWHILE
  SET _rptstat = uar_rptdestroyreport (_hreport )
 END ;Subroutine
 SUBROUTINE  facilityheader (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = facilityheaderabs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  facilityheaderabs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (0.340000 ) ,private
  DECLARE __orgname = vc WITH noconstant (build2 (post_doc_rec->orgname ,char (0 ) ) ) ,protect
  DECLARE __busaddress = vc WITH noconstant (build2 (post_doc_rec->orgaddr1 ,char (0 ) ) ) ,protect
  DECLARE __buscity = vc WITH noconstant (build2 (concat (post_doc_rec->orgcity ,", " ,post_doc_rec->
     orgstate ,"   " ,post_doc_rec->orgzip ) ,char (0 ) ) ) ,protect
  DECLARE __busphone = vc WITH noconstant (build2 (post_doc_rec->orgphone ,char (0 ) ) ) ,protect
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.075 )
   SET rptsd->m_width = 3.625
   SET rptsd->m_height = 0.344
   SET _oldfont = uar_rptsetfont (_hreport ,_helvetica160 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__orgname )
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 3.825 )
   SET rptsd->m_width = 2.500
   SET rptsd->m_height = 0.198
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica100 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__busaddress )
   SET rptsd->m_y = (offsety + 0.146 )
   SET rptsd->m_x = (offsetx + 3.825 )
   SET rptsd->m_width = 3.875
   SET rptsd->m_height = 0.198
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__buscity )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 6.450 )
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = 0.208
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__busphone )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  patientinformation (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = patientinformationabs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  patientinformationabs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (1.220000 ) ,private
  DECLARE __personname = vc WITH noconstant (build2 (post_doc_rec->patient_fullname ,char (0 ) ) ) ,
  protect
  DECLARE __homeaddress = vc WITH noconstant (build2 (post_doc_rec->patient_homeaddr1 ,char (0 ) ) )
  ,protect
  DECLARE __citystatezip = vc WITH noconstant (build2 (concat (post_doc_rec->patient_city ,", " ,
     post_doc_rec->patient_state ,"   " ,post_doc_rec->patient_zip ) ,char (0 ) ) ) ,protect
  DECLARE __homephone = vc WITH noconstant (build2 (post_doc_rec->patient_homephone ,char (0 ) ) ) ,
  protect
  DECLARE __sex = vc WITH noconstant (build2 (post_doc_rec->patient_sex ,char (0 ) ) ) ,protect
  DECLARE __birthdttm = vc WITH noconstant (build2 (format (post_doc_rec->patient_birth_dt_tm ,
     "MM/DD/YYYY;;D" ) ,char (0 ) ) ) ,protect
  ;002
  IF ((post_doc_rec->patient_birth_dt_tm > 0.0 ) )
;   DECLARE __age = vc WITH noconstant (build2 (cnvtage (post_doc_rec->patient_birth_dt_tm ) ,char (0
;      ) ) ) ,protect
   DECLARE __age = vc WITH noconstant (build2 (post_doc_rec->patient_age ,char (0
      ) ) ) ,protect
  ;
  ENDIF
  DECLARE __religion = vc WITH noconstant (build2 (post_doc_rec->patient_religion ,char (0 ) ) ) ,
  protect
  DECLARE __ssn = vc WITH noconstant (build2 (post_doc_rec->patient_ssn ,char (0 ) ) ) ,protect
  DECLARE __employerphone = vc WITH noconstant (build2 (post_doc_rec->pat_employerphone ,char (0 ) )
   ) ,protect
  DECLARE __employername = vc WITH noconstant (build2 (post_doc_rec->pat_employer_name ,char (0 ) )
   ) ,protect
  DECLARE __race = vc WITH noconstant (build2 (post_doc_rec->patient_race ,char (0 ) ) ) ,protect
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.240 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 0.979
   SET rptsd->m_height = 0.188
   SET _oldfont = uar_rptsetfont (_hreport ,_helvetica10b0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Patient Name:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.396 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.031
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Home Address:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.240 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 0.385
   SET rptsd->m_height = 0.208
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Sex:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.396 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.208
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("DOB:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.563 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.208
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Age:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.719 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 0.854
   SET rptsd->m_height = 0.208
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Religion:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.719 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 0.948
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Home Phone:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.875 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Employer Name:" ,char (0 ) ) )
   SET rptsd->m_flags = 20
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 2.950 )
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = 0.260
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica14b0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Patient Information" ,char (0 ) )
    )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen30s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.200 ) ,(offsety + 0.131 ) ,(offsetx + 3.013 ) ,
    (offsety + 0.131 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 4.888 ) ,(offsety + 0.135 ) ,(offsetx + 7.701 ) ,
    (offsety + 0.135 ) )
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety + 0.875 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 0.521
   SET rptsd->m_height = 0.208
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica10b0 )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("SSN:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 1.042 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Employer Phone:" ,char (0 ) ) )
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 0.240 )
   SET rptsd->m_x = (offsetx + 1.294 )
   SET rptsd->m_width = 2.844
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica100 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__personname )
   SET rptsd->m_y = (offsety + 0.396 )
   SET rptsd->m_x = (offsetx + 1.294 )
   SET rptsd->m_width = 2.844
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__homeaddress )
   SET rptsd->m_y = (offsety + 0.563 )
   SET rptsd->m_x = (offsetx + 1.294 )
   SET rptsd->m_width = 2.844
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__citystatezip )
   SET rptsd->m_y = (offsety + 0.719 )
   SET rptsd->m_x = (offsetx + 1.294 )
   SET rptsd->m_width = 2.844
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__homephone )
   SET rptsd->m_y = (offsety + 0.240 )
   SET rptsd->m_x = (offsetx + 4.700 )
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = 0.208
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__sex )
   SET rptsd->m_y = (offsety + 0.396 )
   SET rptsd->m_x = (offsetx + 4.700 )
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = 0.208
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__birthdttm )
   SET rptsd->m_y = (offsety + 0.563 )
   SET rptsd->m_x = (offsetx + 4.700 )
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = 0.208
   IF ((post_doc_rec->patient_birth_dt_tm > 0.0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__age )
   ENDIF
   SET rptsd->m_y = (offsety + 0.719 )
   SET rptsd->m_x = (offsetx + 4.950 )
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = 0.208
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__religion )
   SET rptsd->m_y = (offsety + 0.875 )
   SET rptsd->m_x = (offsetx + 4.700 )
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = 0.208
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__ssn )
   SET rptsd->m_y = (offsety + 1.042 )
   SET rptsd->m_x = (offsetx + 1.388 )
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__employerphone )
   SET rptsd->m_y = (offsety + 0.875 )
   SET rptsd->m_x = (offsetx + 1.388 )
   SET rptsd->m_width = 2.813
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__employername )
   SET rptsd->m_y = (offsety + 1.042 )
   SET rptsd->m_x = (offsetx + 4.700 )
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__race )
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety + 1.042 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 0.583
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica10b0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Race:" ,char (0 ) ) )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  guarantorinformation (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = guarantorinformationabs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  guarantorinformationabs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (1.380000 ) ,private
  DECLARE __guarantorname = vc WITH noconstant (build2 (post_doc_rec->guarantor_namefullformatted ,
    char (0 ) ) ) ,protect
  DECLARE __guarantorreltn = vc WITH noconstant (build2 (post_doc_rec->guarantor_personreltn ,char (
     0 ) ) ) ,protect
  DECLARE __guarsex = vc WITH noconstant (build2 (post_doc_rec->guarantor_sex ,char (0 ) ) ) ,
  protect
  DECLARE __guarbirthdttm = vc WITH noconstant (build2 (format (post_doc_rec->guarantor_birth_dt_tm ,
     "MM/DD/YYYY;;D" ) ,char (0 ) ) ) ,protect
  ;002
  IF ((post_doc_rec->guarantor_birth_dt_tm > 0.0 ) )
;   DECLARE __guarage = vc WITH noconstant (build2 (cnvtage (post_doc_rec->guarantor_birth_dt_tm ) ,
;     char (0 ) ) ) ,protect
   DECLARE __guarage = vc WITH noconstant (build2 (addl_rec->guarantor_age ,
     char (0 ) ) ) ,protect
  ENDIF
  ;
  DECLARE __guarreligion = vc WITH noconstant (build2 (addl_rec->guarantor_religion ,char (0 ) ) ) ,
  protect
  DECLARE __guarantoraddress = vc WITH noconstant (build2 (post_doc_rec->guarantor_addr1 ,char (0 )
    ) ) ,protect
  DECLARE __guarcitystatezip = vc WITH noconstant (build2 (concat (post_doc_rec->guarantor_city ,
     ", " ,post_doc_rec->guarantor_state ,"   " ,post_doc_rec->guarantor_zip ) ,char (0 ) ) ) ,
  protect
  DECLARE __guarssn = vc WITH noconstant (build2 (post_doc_rec->guarantor_ssn ,char (0 ) ) ) ,
  protect
  DECLARE __guarphone = vc WITH noconstant (build2 (post_doc_rec->guarantor_home_phone ,char (0 ) )
   ) ,protect
  DECLARE __guaremplphone = vc WITH noconstant (build2 (post_doc_rec->guarantor_employerphone ,char (
     0 ) ) ) ,protect
  DECLARE __guaremplname = vc WITH noconstant (build2 (post_doc_rec->guarantor_employer_name ,char (
     0 ) ) ) ,protect
  DECLARE __guarmarital = vc WITH noconstant (build2 (post_doc_rec->guarantor_marital ,char (0 ) ) )
  ,protect
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 20
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 2.700 )
   SET rptsd->m_width = 2.500
   SET rptsd->m_height = 0.271
   SET _oldfont = uar_rptsetfont (_hreport ,_helvetica14b0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Guarantor Information" ,char (0 )
     ) )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen30s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 5.075 ) ,(offsety + 0.156 ) ,(offsetx + 7.700 ) ,
    (offsety + 0.156 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.200 ) ,(offsety + 0.131 ) ,(offsetx + 2.825 ) ,
    (offsety + 0.131 ) )
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety + 0.240 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.406
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica10b0 )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Guarantor Name:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.563 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.125
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Billing Address:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.875 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.177
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Billing Phone:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 1.042 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Employer Name:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.396 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.583
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Patient's Reltn:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 1.198 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Employer Phone:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.240 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 0.385
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Sex:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.396 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("DOB:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.563 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Age:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.719 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 0.854
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Religion:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.875 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 0.521
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("SSN:" ,char (0 ) ) )
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 0.240 )
   SET rptsd->m_x = (offsetx + 1.388 )
   SET rptsd->m_width = 2.813
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica100 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__guarantorname )
   SET rptsd->m_y = (offsety + 0.396 )
   SET rptsd->m_x = (offsetx + 1.388 )
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__guarantorreltn )
   SET rptsd->m_y = (offsety + 0.240 )
   SET rptsd->m_x = (offsetx + 4.700 )
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__guarsex )
   SET rptsd->m_y = (offsety + 0.396 )
   SET rptsd->m_x = (offsetx + 4.700 )
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__guarbirthdttm )
   SET rptsd->m_y = (offsety + 0.563 )
   SET rptsd->m_x = (offsetx + 4.700 )
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = 0.188
   IF ((post_doc_rec->guarantor_birth_dt_tm > 0.0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__guarage )
   ENDIF
   SET rptsd->m_y = (offsety + 0.719 )
   SET rptsd->m_x = (offsetx + 4.950 )
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__guarreligion )
   SET rptsd->m_y = (offsety + 0.563 )
   SET rptsd->m_x = (offsetx + 1.388 )
   SET rptsd->m_width = 2.813
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__guarantoraddress )
   SET rptsd->m_y = (offsety + 0.719 )
   SET rptsd->m_x = (offsetx + 1.388 )
   SET rptsd->m_width = 2.823
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__guarcitystatezip )
   SET rptsd->m_y = (offsety + 0.875 )
   SET rptsd->m_x = (offsetx + 4.700 )
   SET rptsd->m_width = 3.000
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__guarssn )
   SET rptsd->m_y = (offsety + 0.875 )
   SET rptsd->m_x = (offsetx + 1.388 )
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__guarphone )
   SET rptsd->m_y = (offsety + 1.198 )
   SET rptsd->m_x = (offsetx + 1.388 )
   SET rptsd->m_width = 2.740
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__guaremplphone )
   SET rptsd->m_y = (offsety + 1.042 )
   SET rptsd->m_x = (offsetx + 1.388 )
   SET rptsd->m_width = 2.833
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__guaremplname )
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety + 1.042 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 1.156
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica10b0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Marital Status:" ,char (0 ) ) )
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 1.042 )
   SET rptsd->m_x = (offsetx + 5.325 )
   SET rptsd->m_width = 2.375
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica100 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__guarmarital )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  contactinformation (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = contactinformationabs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  contactinformationabs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (1.000000 ) ,private
  DECLARE __emcname = vc WITH noconstant (build2 (post_doc_rec->emc_fullname ,char (0 ) ) ) ,protect
  DECLARE __emcreltn = vc WITH noconstant (build2 (post_doc_rec->emc_personreltn ,char (0 ) ) ) ,
  protect
  DECLARE __emcsex = vc WITH noconstant (build2 (addl_rec->emc_sex ,char (0 ) ) ) ,protect
  DECLARE __nokname = vc WITH noconstant (build2 (post_doc_rec->nok_fullname ,char (0 ) ) ) ,protect
  DECLARE __noksex = vc WITH noconstant (build2 (addl_rec->nok_sex ,char (0 ) ) ) ,protect
  DECLARE __nokreltn = vc WITH noconstant (build2 (post_doc_rec->nok_personreltn ,char (0 ) ) ) ,
  protect
  DECLARE __nokphone = vc WITH noconstant (build2 (post_doc_rec->nok_home_phone ,char (0 ) ) ) ,
  protect
  DECLARE __emcphone = vc WITH noconstant (build2 (post_doc_rec->emc_home_phone ,char (0 ) ) ) ,
  protect
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 20
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 2.950 )
   SET rptsd->m_width = 2.000
   SET rptsd->m_height = 0.271
   SET _oldfont = uar_rptsetfont (_hreport ,_helvetica14b0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Contact Information" ,char (0 ) )
    )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen30s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 4.950 ) ,(offsety + 0.156 ) ,(offsetx + 7.700 ) ,
    (offsety + 0.156 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.200 ) ,(offsety + 0.131 ) ,(offsetx + 2.950 ) ,
    (offsety + 0.131 ) )
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety + 0.344 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.406
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica10b0 )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Contact Name:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.583
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Patient's Reltn:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.823 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 0.948
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Home Phone:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.656 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 0.385
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Sex:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.198 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.604
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica10biu0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Emergency Contact" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.344 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 1.406
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica10b0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Contact Name:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 1.583
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Patient's Reltn:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.823 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 0.948
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Home Phone:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.656 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 0.385
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Sex:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.198 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 1.604
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica10biu0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Next of Kin" ,char (0 ) ) )
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 0.344 )
   SET rptsd->m_x = (offsetx + 1.304 )
   SET rptsd->m_width = 2.833
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica100 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__emcname )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 1.304 )
   SET rptsd->m_width = 2.833
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__emcreltn )
   SET rptsd->m_y = (offsety + 0.656 )
   SET rptsd->m_x = (offsetx + 0.690 )
   SET rptsd->m_width = 3.448
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__emcsex )
   SET rptsd->m_y = (offsety + 0.344 )
   SET rptsd->m_x = (offsetx + 5.346 )
   SET rptsd->m_width = 2.354
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__nokname )
   SET rptsd->m_y = (offsety + 0.656 )
   SET rptsd->m_x = (offsetx + 4.721 )
   SET rptsd->m_width = 2.979
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__noksex )
   SET rptsd->m_y = (offsety + 0.500 )
   SET rptsd->m_x = (offsetx + 5.346 )
   SET rptsd->m_width = 2.354
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__nokreltn )
   SET rptsd->m_y = (offsety + 0.823 )
   SET rptsd->m_x = (offsetx + 5.263 )
   SET rptsd->m_width = 2.438
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__nokphone )
   SET rptsd->m_y = (offsety + 0.823 )
   SET rptsd->m_x = (offsetx + 1.169 )
   SET rptsd->m_width = 2.969
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__emcphone )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  ins1 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = ins1abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  ins1abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (1.700000 ) ,private
  DECLARE __sub1name = vc WITH noconstant (build2 (post_doc_rec->sub01_fullname ,char (0 ) ) ) ,
  protect
  DECLARE __sub1reltn = vc WITH noconstant (build2 (post_doc_rec->sub01_personreltn ,char (0 ) ) ) ,
  protect
  DECLARE __sub1sex = vc WITH noconstant (build2 (post_doc_rec->sub01_sex ,char (0 ) ) ) ,protect
  DECLARE __sub1birthdttm = vc WITH noconstant (build2 (format (post_doc_rec->sub01_birth_dt_tm ,
     "MM/DD/YYYY;;D" ) ,char (0 ) ) ) ,protect
  ;002
  IF ((post_doc_rec->sub01_birth_dt_tm > 0.0 ) )
;   DECLARE __sub1age = vc WITH noconstant (build2 (cnvtage (post_doc_rec->sub01_birth_dt_tm ) ,char (
;      0 ) ) ) ,protect
   DECLARE __sub1age = vc WITH noconstant (build2 (addl_rec->sub01_age ,char (
      0 ) ) ) ,protect
  ENDIF
  ;
  DECLARE __hp1 = vc WITH noconstant (build2 (post_doc_rec->sub01_hp_name ,char (0 ) ) ) ,protect
  DECLARE __hp1address = vc WITH noconstant (build2 (addl_rec->sub01_addr ,char (0 ) ) ) ,protect
  IF ((textlen (addl_rec->sub01_city ) > 0 )
  AND (textlen (addl_rec->sub01_state ) > 0 )
  AND (textlen (addl_rec->sub01_zip ) > 0 ) )
   DECLARE __hp1citystatezip = vc WITH noconstant (build2 (concat (addl_rec->sub01_city ,", " ,
      addl_rec->sub01_state ,"   " ,addl_rec->sub01_zip ) ,char (0 ) ) ) ,protect
  ENDIF
  ;004
  ;DECLARE __hp1policynum = vc WITH noconstant (build2 (post_doc_rec->sub01_hp_subs_member_nbr ,char (
  ;   0 ) ) ) ,protect
  ;DECLARE __hp1groupnbr = vc WITH noconstant (build2 (post_doc_rec->sub01_group_nbr ,char (0 ) ) ) ,
  ;protect
  DECLARE __hp1policynum = vc WITH noconstant (build2 (addl_rec->Sub01_HP_Member_Nbr ,char (
     0 ) ) ) ,protect
  DECLARE __hp1groupnbr = vc WITH noconstant (build2 (addl_rec->Sub01_HP_Group_Nbr ,char (0 ) ) ) ,
  protect
  ;
  DECLARE __hp1auth1num = vc WITH noconstant (build2 (post_doc_rec->sub01_hp_auth01_authno ,char (0
     ) ) ) ,protect
  DECLARE __hp1auth1contact = vc WITH noconstant (build2 (addl_rec->sub01_hp_auth01_authcon ,char (0
     ) ) ) ,protect
  DECLARE __hp1finclass = vc WITH noconstant (build2 (addl_rec->sub01_fin_class ,char (0 ) ) ) ,
  protect
  DECLARE __sub1emplphone = vc WITH noconstant (build2 (post_doc_rec->sub01_employerphone ,char (0 )
    ) ) ,protect
  DECLARE __hp1auth1phone = vc WITH noconstant (build2 (post_doc_rec->sub01_hp_auth01_authphone ,
    char (0 ) ) ) ,protect
  DECLARE __hp1phone = vc WITH noconstant (build2 (post_doc_rec->sub01_hp_contact_phone ,char (0 ) )
   ) ,protect
  DECLARE __sub1emplname = vc WITH noconstant (build2 (post_doc_rec->sub01_employer_name ,char (0 )
    ) ) ,protect
  DECLARE __hp1groupname = vc WITH noconstant (build2 (addl_rec->sub01_group_name ,char (0 ) ) ) ,
  protect
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 20
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 2.700 )
   SET rptsd->m_width = 2.500
   SET rptsd->m_height = 0.271
   SET _oldfont = uar_rptsetfont (_hreport ,_helvetica14b0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Primary Insurance" ,char (0 ) ) )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen30s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 4.888 ) ,(offsety + 0.156 ) ,(offsetx + 7.701 ) ,
    (offsety + 0.156 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.200 ) ,(offsety + 0.131 ) ,(offsetx + 3.013 ) ,
    (offsety + 0.131 ) )
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety + 0.240 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.406
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica10b0 )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Subscriber Name:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.396 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.583
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Patient's Reltn:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.563 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 0.385
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Sex:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.719 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("DOB:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 1.042 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Employer Name:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 1.198 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Employer Phone:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.240 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 2.156
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Insurance Name:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 1.042 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 1.729
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Group Number:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.396 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 1.396
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Claim Address:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.719 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 1.208
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Insurance Phone:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.875 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Policy Number:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 1.198 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 1.583
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Authorization Number:" ,char (0 )
     ) )
   SET rptsd->m_y = (offsety + 1.365 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 1.583
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Authorization Phone:" ,char (0 )
     ) )
   SET rptsd->m_y = (offsety + 0.875 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Age:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 1.521 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Authorization Contact:" ,char (0
      ) ) )
   SET rptsd->m_y = (offsety + 1.365 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Financial Class:" ,char (0 ) ) )
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 0.240 )
   SET rptsd->m_x = (offsetx + 1.450 )
   SET rptsd->m_width = 2.771
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica100 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__sub1name )
   SET rptsd->m_y = (offsety + 0.396 )
   SET rptsd->m_x = (offsetx + 1.450 )
   SET rptsd->m_width = 2.729
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__sub1reltn )
   SET rptsd->m_y = (offsety + 0.563 )
   SET rptsd->m_x = (offsetx + 0.638 )
   SET rptsd->m_width = 2.333
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__sub1sex )
   SET rptsd->m_y = (offsety + 0.719 )
   SET rptsd->m_x = (offsetx + 0.638 )
   SET rptsd->m_width = 2.583
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__sub1birthdttm )
   SET rptsd->m_y = (offsety + 0.875 )
   SET rptsd->m_x = (offsetx + 0.638 )
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = 0.188
   IF ((post_doc_rec->sub01_birth_dt_tm > 0.0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__sub1age )
   ENDIF
   SET rptsd->m_y = (offsety + 0.240 )
   SET rptsd->m_x = (offsetx + 5.513 )
   SET rptsd->m_width = 2.188
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__hp1 )
   SET rptsd->m_y = (offsety + 0.396 )
   SET rptsd->m_x = (offsetx + 5.513 )
   SET rptsd->m_width = 2.188
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__hp1address )
   SET rptsd->m_y = (offsety + 0.563 )
   SET rptsd->m_x = (offsetx + 5.513 )
   SET rptsd->m_width = 2.188
   SET rptsd->m_height = 0.188
   IF ((textlen (addl_rec->sub01_city ) > 0 )
   AND (textlen (addl_rec->sub01_state ) > 0 )
   AND (textlen (addl_rec->sub01_zip ) > 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__hp1citystatezip )
   ENDIF
   SET rptsd->m_y = (offsety + 0.875 )
   SET rptsd->m_x = (offsetx + 5.388 )
   SET rptsd->m_width = 2.313
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__hp1policynum )
   SET rptsd->m_y = (offsety + 1.042 )
   SET rptsd->m_x = (offsetx + 5.388 )
   SET rptsd->m_width = 2.313
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__hp1groupnbr )
   SET rptsd->m_y = (offsety + 1.198 )
   SET rptsd->m_x = (offsetx + 5.825 )
   SET rptsd->m_width = 2.063
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__hp1auth1num )
   SET rptsd->m_y = (offsety + 1.521 )
   SET rptsd->m_x = (offsetx + 5.825 )
   SET rptsd->m_width = 2.063
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__hp1auth1contact )
   SET rptsd->m_y = (offsety + 1.365 )
   SET rptsd->m_x = (offsetx + 1.325 )
   SET rptsd->m_width = 2.813
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__hp1finclass )
   SET rptsd->m_y = (offsety + 1.198 )
   SET rptsd->m_x = (offsetx + 1.388 )
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__sub1emplphone )
   SET rptsd->m_y = (offsety + 1.365 )
   SET rptsd->m_x = (offsetx + 5.825 )
   SET rptsd->m_width = 2.063
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__hp1auth1phone )
   SET rptsd->m_y = (offsety + 0.719 )
   SET rptsd->m_x = (offsetx + 5.513 )
   SET rptsd->m_width = 2.188
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__hp1phone )
   SET rptsd->m_y = (offsety + 1.042 )
   SET rptsd->m_x = (offsetx + 1.388 )
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__sub1emplname )
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety + 1.521 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.052
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica10b0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Group Name:" ,char (0 ) ) )
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 1.521 )
   SET rptsd->m_x = (offsetx + 1.325 )
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica100 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__hp1groupname )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  ins2 (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = ins2abs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  ins2abs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (1.700000 ) ,private
  DECLARE __sub2name = vc WITH noconstant (build2 (post_doc_rec->sub02_fullname ,char (0 ) ) ) ,
  protect
  DECLARE __sub2reltn = vc WITH noconstant (build2 (post_doc_rec->sub02_personreltn ,char (0 ) ) ) ,
  protect
  DECLARE __sub2sex = vc WITH noconstant (build2 (post_doc_rec->sub02_sex ,char (0 ) ) ) ,protect
  DECLARE __sub2birthdttm = vc WITH noconstant (build2 (format (post_doc_rec->sub02_birth_dt_tm ,
     "MM/DD/YYYY;;D" ) ,char (0 ) ) ) ,protect
  ;002
  IF ((post_doc_rec->sub02_birth_dt_tm > 0.0 ) )
;   DECLARE __sub2age = vc WITH noconstant (build2 (cnvtage (post_doc_rec->sub02_birth_dt_tm ) ,char (
;      0 ) ) ) ,protect
   DECLARE __sub2age = vc WITH noconstant (build2 (addl_rec->sub02_age ,char (
      0 ) ) ) ,protect
  ENDIF
  ;
  DECLARE __hp2finclass = vc WITH noconstant (build2 (addl_rec->sub02_fin_class ,char (0 ) ) ) ,
  protect
  DECLARE __hp2name = vc WITH noconstant (build2 (post_doc_rec->sub02_hp_name ,char (0 ) ) ) ,
  protect
  DECLARE __hp2address = vc WITH noconstant (build2 (addl_rec->sub02_addr ,char (0 ) ) ) ,protect
  IF ((textlen (addl_rec->sub02_city ) > 0 )
  AND (textlen (addl_rec->sub02_state ) > 0 )
  AND (textlen (addl_rec->sub02_zip ) > 0 ) )
   DECLARE __hp2citystzip = vc WITH noconstant (build2 (concat (addl_rec->sub02_city ,", " ,addl_rec
      ->sub02_state ,"   " ,addl_rec->sub02_zip ) ,char (0 ) ) ) ,protect
  ENDIF
  ;004
  ;DECLARE __hp2policynum = vc WITH noconstant (build2 (post_doc_rec->sub02_hp_subs_member_nbr ,char (
  ;   0 ) ) ) ,protect
  ;DECLARE __hp2groupnum = vc WITH noconstant (build2 (post_doc_rec->sub02_group_nbr ,char (0 ) ) ) ,
  ;protect
  DECLARE __hp2policynum = vc WITH noconstant (build2 (addl_rec->Sub02_HP_Member_Nbr ,char (
     0 ) ) ) ,protect
  DECLARE __hp2groupnum = vc WITH noconstant (build2 (addl_rec->Sub02_HP_Group_Nbr ,char (0 ) ) ) ,
  protect
  ;
  DECLARE __hp2auth1num = vc WITH noconstant (build2 (post_doc_rec->sub02_hp_auth01_authno ,char (0
     ) ) ) ,protect
  DECLARE __hp2auth1contact = vc WITH noconstant (build2 (addl_rec->sub02_hp_auth01_authcon ,char (0
     ) ) ) ,protect
  DECLARE __sub2emplphone = vc WITH noconstant (build2 (post_doc_rec->sub02_employerphone ,char (0 )
    ) ) ,protect
  DECLARE __hp2phone = vc WITH noconstant (build2 (post_doc_rec->sub02_hp_contact_phone ,char (0 ) )
   ) ,protect
  DECLARE __hp2auth1phone = vc WITH noconstant (build2 (post_doc_rec->sub02_hp_auth01_authphone ,
    char (0 ) ) ) ,protect
  DECLARE __sub2emplname = vc WITH noconstant (build2 (post_doc_rec->sub02_employer_name ,char (0 )
    ) ) ,protect
  DECLARE __hp2groupname = vc WITH noconstant (build2 (addl_rec->sub02_group_name ,char (0 ) ) ) ,
  protect
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 20
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 2.700 )
   SET rptsd->m_width = 2.500
   SET rptsd->m_height = 0.271
   SET _oldfont = uar_rptsetfont (_hreport ,_helvetica14b0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Secondary Insurance" ,char (0 ) )
    )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen30s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 5.013 ) ,(offsety + 0.135 ) ,(offsetx + 7.701 ) ,
    (offsety + 0.135 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.200 ) ,(offsety + 0.131 ) ,(offsetx + 2.888 ) ,
    (offsety + 0.131 ) )
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety + 0.240 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.406
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica10b0 )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Subscriber Name:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.396 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.583
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Patient's Reltn:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.563 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 0.385
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Sex:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.719 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("DOB:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 1.042 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.188
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Employer Name:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 1.198 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Employer Phone:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.240 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 2.156
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Insurance Name:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 1.042 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 1.729
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Group Number:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.396 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 1.396
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Claim Address:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.719 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 1.208
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Insurance Phone:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.875 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Policy Number:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 1.198 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 1.583
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Authorization Number:" ,char (0 )
     ) )
   SET rptsd->m_y = (offsety + 1.365 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 1.583
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Authorization Phone:" ,char (0 )
     ) )
   SET rptsd->m_y = (offsety + 0.875 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 0.375
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Age:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 1.521 )
   SET rptsd->m_x = (offsetx + 4.263 )
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Authorization Contact:" ,char (0
      ) ) )
   SET rptsd->m_y = (offsety + 1.365 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.500
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Financial Class:" ,char (0 ) ) )
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 0.240 )
   SET rptsd->m_x = (offsetx + 1.450 )
   SET rptsd->m_width = 2.688
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica100 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__sub2name )
   SET rptsd->m_y = (offsety + 0.396 )
   SET rptsd->m_x = (offsetx + 1.450 )
   SET rptsd->m_width = 2.688
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__sub2reltn )
   SET rptsd->m_y = (offsety + 0.563 )
   SET rptsd->m_x = (offsetx + 0.700 )
   SET rptsd->m_width = 3.438
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__sub2sex )
   SET rptsd->m_y = (offsety + 0.719 )
   SET rptsd->m_x = (offsetx + 0.700 )
   SET rptsd->m_width = 3.438
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__sub2birthdttm )
   SET rptsd->m_y = (offsety + 0.875 )
   SET rptsd->m_x = (offsetx + 0.700 )
   SET rptsd->m_width = 3.438
   SET rptsd->m_height = 0.188
   IF ((post_doc_rec->sub02_birth_dt_tm > 0.0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__sub2age )
   ENDIF
   SET rptsd->m_y = (offsety + 1.365 )
   SET rptsd->m_x = (offsetx + 1.325 )
   SET rptsd->m_width = 2.813
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__hp2finclass )
   SET rptsd->m_y = (offsety + 0.240 )
   SET rptsd->m_x = (offsetx + 5.513 )
   SET rptsd->m_width = 2.188
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__hp2name )
   SET rptsd->m_y = (offsety + 0.396 )
   SET rptsd->m_x = (offsetx + 5.513 )
   SET rptsd->m_width = 2.188
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__hp2address )
   SET rptsd->m_y = (offsety + 0.563 )
   SET rptsd->m_x = (offsetx + 5.513 )
   SET rptsd->m_width = 2.188
   SET rptsd->m_height = 0.188
   IF ((textlen (addl_rec->sub02_city ) > 0 )
   AND (textlen (addl_rec->sub02_state ) > 0 )
   AND (textlen (addl_rec->sub02_zip ) > 0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__hp2citystzip )
   ENDIF
   SET rptsd->m_y = (offsety + 0.875 )
   SET rptsd->m_x = (offsetx + 5.388 )
   SET rptsd->m_width = 2.313
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__hp2policynum )
   SET rptsd->m_y = (offsety + 1.042 )
   SET rptsd->m_x = (offsetx + 5.388 )
   SET rptsd->m_width = 2.313
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__hp2groupnum )
   SET rptsd->m_y = (offsety + 1.198 )
   SET rptsd->m_x = (offsetx + 5.825 )
   SET rptsd->m_width = 2.063
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__hp2auth1num )
   SET rptsd->m_y = (offsety + 1.521 )
   SET rptsd->m_x = (offsetx + 5.825 )
   SET rptsd->m_width = 2.073
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__hp2auth1contact )
   SET rptsd->m_y = (offsety + 1.198 )
   SET rptsd->m_x = (offsetx + 1.388 )
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__sub2emplphone )
   SET rptsd->m_y = (offsety + 0.719 )
   SET rptsd->m_x = (offsetx + 5.513 )
   SET rptsd->m_width = 2.188
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__hp2phone )
   SET rptsd->m_y = (offsety + 1.365 )
   SET rptsd->m_x = (offsetx + 5.825 )
   SET rptsd->m_width = 2.063
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__hp2auth1phone )
   SET rptsd->m_y = (offsety + 1.042 )
   SET rptsd->m_x = (offsetx + 1.388 )
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__sub2emplname )
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety + 1.521 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.323
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica10b0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Group Name:" ,char (0 ) ) )
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 1.521 )
   SET rptsd->m_x = (offsetx + 1.325 )
   SET rptsd->m_width = 2.750
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica100 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__hp2groupname )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  visitinfo (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = visitinfoabs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  visitinfoabs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (1.380000 ) ,private
  DECLARE __regdttm = vc WITH noconstant (build2 (format (post_doc_rec->reg_dt_tm ,
     "MM/DD/YYYY HH:MM;;D" ) ,char (0 ) ) ) ,protect
  DECLARE __estarrivedttm = vc WITH noconstant (build2 (format (post_doc_rec->estarrive_dt_tm ,
     "MM/DD/YYYY HH:MM;;D" ) ,char (0 ) ) ) ,protect
  DECLARE __inpatientadmitdttm = vc WITH noconstant (build2 (format (post_doc_rec->
     inpatientadmit_dt_tm ,"MM/DD/YYYY HH:MM;;d" ) ,char (0 ) ) ) ,protect
  DECLARE __dischdttm = vc WITH noconstant (build2 (format (post_doc_rec->disch_dt_tm ,
     "MM/DD/YYYY HH:MM;;D" ) ,char (0 ) ) ) ,protect
  DECLARE __vip = vc WITH noconstant (build2 (post_doc_rec->vip ,char (0 ) ) ) ,protect
  DECLARE __reasonforvisit = vc WITH noconstant (build2 (post_doc_rec->reasonforvisit ,char (0 ) ) )
  ,protect
  DECLARE __encntrtype = vc WITH noconstant (build2 (post_doc_rec->encntrtype ,char (0 ) ) ) ,
  protect
  DECLARE __medservice = vc WITH noconstant (build2 (post_doc_rec->medicalservice ,char (0 ) ) ) ,
  protect
  DECLARE __nurseunit = vc WITH noconstant (build2 (post_doc_rec->nurseunit ,char (0 ) ) ) ,protect
  DECLARE __roombed = vc WITH noconstant (build2 (concat (post_doc_rec->room ," / " ,post_doc_rec->
     bed ) ,char (0 ) ) ) ,protect
  DECLARE __isolation = vc WITH noconstant (build2 (post_doc_rec->isolation ,char (0 ) ) ) ,protect
  DECLARE __admittype = vc WITH noconstant (build2 (post_doc_rec->admittype ,char (0 ) ) ) ,protect
  DECLARE __admitsource = vc WITH noconstant (build2 (post_doc_rec->admitsrc ,char (0 ) ) ) ,protect
  DECLARE __livingwill = vc WITH noconstant (build2 (post_doc_rec->patient_livingwill ,char (0 ) ) )
  ,protect
  DECLARE __regclerk = vc WITH noconstant (build2 (post_doc_rec->regprsnl_namefullformatted ,char (0
     ) ) ) ,protect
;007
;  IF ((post_doc_rec->assigntoloc_dt_tm > 0.0 ) )
;   DECLARE __observationdttm = vc WITH noconstant (build2 (format (post_doc_rec->assigntoloc_dt_tm ,
;      "MM/DD/YYYY HH:MM;;D" ) ,char (0 ) ) ) ,protect
;  ENDIF
  IF ((addl_rec->Observation_dt_tm > 0.0 ) )
   DECLARE __observationdttm = vc WITH noconstant (build2 (format (addl_rec->Observation_dt_tm ,
      "MM/DD/YYYY HH:MM;;D" ) ,char (0 ) ) ) ,protect
  ENDIF
;
  DECLARE __admitdoc = vc WITH noconstant (build2 (post_doc_rec->admitdoc_namefullformatted ,char (0
     ) ) ) ,protect
  DECLARE __attenddoc = vc WITH noconstant (build2 (post_doc_rec->attenddoc_namefullformatted ,char (
     0 ) ) ) ,protect
  DECLARE __pcp = vc WITH noconstant (build2 (concat (post_doc_rec->pcp_fullname ," " ,post_doc_rec->
     pcp_title ) ,char (0 ) ) ) ,protect
  DECLARE __diseasealert = vc WITH noconstant (build2 (addl_rec->patient_disease_alert ,char (0 ) )
   ) ,protect
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 20
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 2.700 )
   SET rptsd->m_width = 2.500
   SET rptsd->m_height = 0.271
   SET _oldfont = uar_rptsetfont (_hreport ,_helvetica14b0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Encounter Information" ,char (0 )
     ) )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen30s0c0 )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 5.075 ) ,(offsety + 0.135 ) ,(offsetx + 7.700 ) ,
    (offsety + 0.135 ) )
   SET _rptstat = uar_rptline (_hreport ,(offsetx + 0.200 ) ,(offsety + 0.131 ) ,(offsetx + 2.825 ) ,
    (offsety + 0.131 ) )
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety + 0.240 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.406
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica10b0 )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Reg Dt/Tm:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.396 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.729
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Est Dt of Arrival:" ,char (0 ) )
    )
   SET rptsd->m_y = (offsety + 0.563 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.875
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Inpt Adm Dt/Tm:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.719 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.875
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Disch Dt/Tm:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.875 )
   SET rptsd->m_x = (offsetx + 5.325 )
   SET rptsd->m_width = 1.219
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Admit Physician:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 1.042 )
   SET rptsd->m_x = (offsetx + 5.325 )
   SET rptsd->m_width = 1.281
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Attend Physician:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 1.198 )
   SET rptsd->m_x = (offsetx + 5.325 )
   SET rptsd->m_width = 0.406
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("PCP:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.240 )
   SET rptsd->m_x = (offsetx + 2.888 )
   SET rptsd->m_width = 1.063
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Patient Type:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.396 )
   SET rptsd->m_x = (offsetx + 2.888 )
   SET rptsd->m_width = 1.250
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Medical Service:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.240 )
   SET rptsd->m_x = (offsetx + 5.325 )
   SET rptsd->m_width = 0.906
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Admit Type:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.396 )
   SET rptsd->m_x = (offsetx + 5.325 )
   SET rptsd->m_width = 1.094
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Admit Source:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 1.198 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.406
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Admit Reason:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 1.042 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.406
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("VIP Indicator:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 1.042 )
   SET rptsd->m_x = (offsetx + 2.888 )
   SET rptsd->m_width = 1.000
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Disease Alert:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.875 )
   SET rptsd->m_x = (offsetx + 2.888 )
   SET rptsd->m_width = 0.688
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Isolation:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.563 )
   SET rptsd->m_x = (offsetx + 5.325 )
   SET rptsd->m_width = 1.406
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Advance Directive:" ,char (0 ) )
    )
   SET rptsd->m_y = (offsety + 0.563 )
   SET rptsd->m_x = (offsetx + 2.888 )
   SET rptsd->m_width = 0.719
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Location:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.719 )
   SET rptsd->m_x = (offsetx + 5.325 )
   SET rptsd->m_width = 0.781
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Reg Clerk:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.719 )
   SET rptsd->m_x = (offsetx + 2.888 )
   SET rptsd->m_width = 0.813
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Room/Bed:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.875 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 1.875
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("Observation Dt/Tm:" ,char (0 ) )
    )
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 0.240 )
   SET rptsd->m_x = (offsetx + 1.315 )
   SET rptsd->m_width = 1.573
   SET rptsd->m_height = 0.188
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica100 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__regdttm )
   SET rptsd->m_y = (offsety + 0.396 )
   SET rptsd->m_x = (offsetx + 1.315 )
   SET rptsd->m_width = 1.573
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__estarrivedttm )
   SET rptsd->m_y = (offsety + 0.563 )
   SET rptsd->m_x = (offsetx + 1.315 )
   SET rptsd->m_width = 1.573
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__inpatientadmitdttm )
   SET rptsd->m_y = (offsety + 0.719 )
   SET rptsd->m_x = (offsetx + 1.315 )
   SET rptsd->m_width = 1.573
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__dischdttm )
   SET rptsd->m_y = (offsety + 1.042 )
   SET rptsd->m_x = (offsetx + 1.242 )
   SET rptsd->m_width = 1.646
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__vip )
   SET rptsd->m_y = (offsety + 1.198 )
   SET rptsd->m_x = (offsetx + 1.221 )
   SET rptsd->m_width = 4.167
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__reasonforvisit )
   SET rptsd->m_y = (offsety + 0.240 )
   SET rptsd->m_x = (offsetx + 3.825 )
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__encntrtype )
   SET rptsd->m_y = (offsety + 0.396 )
   SET rptsd->m_x = (offsetx + 4.075 )
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__medservice )
   SET rptsd->m_y = (offsety + 0.563 )
   SET rptsd->m_x = (offsetx + 3.575 )
   SET rptsd->m_width = 1.875
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__nurseunit )
   SET rptsd->m_y = (offsety + 0.719 )
   SET rptsd->m_x = (offsetx + 3.700 )
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__roombed )
   SET rptsd->m_y = (offsety + 0.875 )
   SET rptsd->m_x = (offsetx + 3.575 )
   SET rptsd->m_width = 1.875
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__isolation )
   SET rptsd->m_y = (offsety + 0.240 )
   SET rptsd->m_x = (offsetx + 6.200 )
   SET rptsd->m_width = 1.646
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__admittype )
   SET rptsd->m_y = (offsety + 0.396 )
   SET rptsd->m_x = (offsetx + 6.325 )
   SET rptsd->m_width = 1.479
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__admitsource )
   SET rptsd->m_y = (offsety + 0.563 )
   SET rptsd->m_x = (offsetx + 6.638 )
   SET rptsd->m_width = 1.208
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__livingwill )
   SET rptsd->m_y = (offsety + 0.719 )
   SET rptsd->m_x = (offsetx + 6.075 )
   SET rptsd->m_width = 1.750
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__regclerk )
   SET rptsd->m_y = (offsety + 0.875 )
   SET rptsd->m_x = (offsetx + 1.513 )
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = 0.188
;007
;   IF ((post_doc_rec->assigntoloc_dt_tm > 0.0 ) )
;    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__observationdttm )
;   ENDIF
   IF ((addl_rec->Observation_dt_tm > 0.0 ) )
    SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__observationdttm )
   ENDIF
;
   SET rptsd->m_y = (offsety + 0.875 )
   SET rptsd->m_x = (offsetx + 6.513 )
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__admitdoc )
   SET rptsd->m_y = (offsety + 1.042 )
   SET rptsd->m_x = (offsetx + 6.513 )
   SET rptsd->m_width = 1.375
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__attenddoc )
   SET rptsd->m_y = (offsety + 1.198 )
   SET rptsd->m_x = (offsetx + 5.763 )
   SET rptsd->m_width = 2.042
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__pcp )
   SET rptsd->m_y = (offsety + 1.042 )
   SET rptsd->m_x = (offsetx + 3.825 )
   SET rptsd->m_width = 1.625
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__diseasealert )
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  footer (ncalc )
  DECLARE a1 = f8 WITH noconstant (0.0 ) ,private
  SET a1 = footerabs (ncalc ,_xoffset ,_yoffset )
  RETURN (a1 )
 END ;Subroutine
 SUBROUTINE  footerabs (ncalc ,offsetx ,offsety )
  DECLARE sectionheight = f8 WITH noconstant (1.400000 ) ,private
  DECLARE __personname = vc WITH noconstant (build2 (post_doc_rec->patient_fullname ,char (0 ) ) ) ,
  protect
  ;002
;  DECLARE __sexage = vc WITH noconstant (build2 (concat (post_doc_rec->patient_sex ," / " ,cnvtage (
;      post_doc_rec->patient_birth_dt_tm ) ) ,char (0 ) ) ) ,protect
  DECLARE __sexage = vc WITH noconstant (build2 (concat (post_doc_rec->patient_sex ," / " ,
      post_doc_rec->patient_age  ) ,char (0 ) ) ) ,protect
  ;
  DECLARE __mrn = vc WITH noconstant (build2 (post_doc_rec->patient_mrn ,char (0 ) ) ) ,protect
  DECLARE __fin = vc WITH noconstant (build2 (post_doc_rec->patient_fin ,char (0 ) ) ) ,protect
  DECLARE __printedby = vc WITH noconstant (build2 (concat ("Printed By: " ,addl_rec->printed_by ,
     " on " ,format (cnvtdatetime (curdate ,curtime ) ,"MM/DD/YYYY HH:MM;;D" ) ) ,char (0 ) ) ) ,
  protect
  DECLARE __lastupdate = vc WITH noconstant (build2 (concat ("Registration last updated by:  " ,
     addl_rec->last_prsnl_updt_name ," on  " ,format (addl_rec->last_prsnl_updt_dt_tm ,
      "MM/DD/YYYY HH:MM;;D" ) ) ,char (0 ) ) ) ,protect
  IF ((ncalc = rpt_render ) )
   SET rptsd->m_flags = 4
   SET rptsd->m_borders = rpt_sdnoborders
   SET rptsd->m_padding = rpt_sdnoborders
   SET rptsd->m_paddingwidth = 0.000
   SET rptsd->m_linespacing = rpt_single
   SET rptsd->m_rotationangle = 0
   SET rptsd->m_y = (offsety + 0.323 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.323
   SET _oldfont = uar_rptsetfont (_hreport ,_helvetica14b0 )
   SET _oldpen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("MRN:" ,char (0 ) ) )
   SET rptsd->m_y = (offsety + 0.323 )
   SET rptsd->m_x = (offsetx + 4.023 )
   SET rptsd->m_width = 0.750
   SET rptsd->m_height = 0.323
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 ("FIN:" ,char (0 ) ) )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen13s0c0 )
   SET _rptdummy = uar_rptbarcodeinit (rptbce ,rpt_code128 ,(offsetx + 0.200 ) ,(offsety + 0.604 ) )
   SET rptbce->m_recsize = 88
   SET rptbce->m_width = 1.35
   SET rptbce->m_height = 0.33
   SET rptbce->m_rotation = 0
   SET rptbce->m_ratio = 300
   SET rptbce->m_barwidth = 1
   SET rptbce->m_bscale = 1
   SET rptbce->m_bprintinterp = 0
   SET _rptstat = uar_rptbarcodeex (_hreport ,rptbce ,build2 (concat ("*" ,post_doc_rec->patient_mrn
      ,"*" ) ,char (0 ) ) )
   SET _rptdummy = uar_rptbarcodeinit (rptbce ,rpt_code128 ,(offsetx + 4.044 ) ,(offsety + 0.604 ) )
   SET rptbce->m_recsize = 88
   SET rptbce->m_width = 2.46
   SET rptbce->m_height = 0.33
   SET rptbce->m_rotation = 0
   SET rptbce->m_ratio = 300
   SET rptbce->m_barwidth = 1
   SET rptbce->m_bscale = 1
   SET rptbce->m_bprintinterp = 0
   SET _rptstat = uar_rptbarcodeex (_hreport ,rptbce ,build2 (concat ("*" ,post_doc_rec->patient_fin
      ,"*" ) ,char (0 ) ) )
   SET rptsd->m_flags = 0
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 0.200 )
   SET rptsd->m_width = 3.573
   SET rptsd->m_height = 0.396
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica200 )
   SET _dummypen = uar_rptsetpen (_hreport ,_pen14s0c0 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__personname )
   SET rptsd->m_y = (offsety + 0.000 )
   SET rptsd->m_x = (offsetx + 4.013 )
   SET rptsd->m_width = 3.688
   SET rptsd->m_height = 0.375
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__sexage )
   SET rptsd->m_y = (offsety + 0.323 )
   SET rptsd->m_x = (offsetx + 0.794 )
   SET rptsd->m_width = 2.385
   SET rptsd->m_height = 0.260
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica140 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__mrn )
   SET rptsd->m_y = (offsety + 0.323 )
   SET rptsd->m_x = (offsetx + 4.471 )
   SET rptsd->m_width = 2.354
   SET rptsd->m_height = 0.260
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__fin )
   SET rptsd->m_y = (offsety + 1.021 )
   SET rptsd->m_x = (offsetx + 0.242 )
   SET rptsd->m_width = 7.396
   SET rptsd->m_height = 0.229
   SET _dummyfont = uar_rptsetfont (_hreport ,_helvetica100 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__printedby )
   SET rptsd->m_y = (offsety + 1.219 )
   SET rptsd->m_x = (offsetx + 0.242 )
   SET rptsd->m_width = 7.396
   SET rptsd->m_height = 0.188
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,__lastupdate )
   SET rptsd->m_flags = 4
   SET rptsd->m_y = (offsety + 0.563 )
   SET rptsd->m_x = (offsetx + 2.367 )
   SET rptsd->m_width = 0.521
   SET rptsd->m_height = 0.271
   SET _dummyfont = uar_rptsetfont (_hreport ,_times100 )
   SET _fdrawheight = uar_rptstringdraw (_hreport ,rptsd ,build2 (" " ,char (0 ) ) ) ;005
   SET _yoffset = (offsety + sectionheight )
  ENDIF
  RETURN (sectionheight )
 END ;Subroutine
 SUBROUTINE  initializereport (dummy )
  SET rptreport->m_recsize = 102
  SET rptreport->m_reportname = "chs_tn_reg_xr_facesheet2"
  SET rptreport->m_pagewidth = 8.50
  SET rptreport->m_pageheight = 11.00
  SET rptreport->m_orientation = rpt_portrait
  SET rptreport->m_marginleft = 0.30
  SET rptreport->m_marginright = 0.30
  SET rptreport->m_margintop = 0.30
  SET rptreport->m_marginbottom = 0.30
  SET rptreport->m_horzprintoffset = _xshift
  SET rptreport->m_vertprintoffset = _yshift
  SET rptreport->m_dioflag = 0
  SET _yoffset = rptreport->m_margintop
  SET _xoffset = rptreport->m_marginleft
  SET _hreport = uar_rptcreatereport (rptreport ,_outputtype ,rpt_inches )
  SET _rpterr = uar_rptseterrorlevel (_hreport ,rpt_error )
  SET _rptstat = uar_rptstartreport (_hreport )
  SET _rptpage = uar_rptstartpage (_hreport )
  CALL _createfonts (0 )
  CALL _createpens (0 )
 END ;Subroutine
 SUBROUTINE  _createfonts (dummy )
  SET rptfont->m_recsize = 62
  SET rptfont->m_fontname = rpt_times
  SET rptfont->m_pointsize = 10
  SET rptfont->m_bold = rpt_off
  SET rptfont->m_italic = rpt_off
  SET rptfont->m_underline = rpt_off
  SET rptfont->m_strikethrough = rpt_off
  SET rptfont->m_rgbcolor = rpt_black
  SET _times100 = uar_rptcreatefont (_hreport ,rptfont )
  SET rptfont->m_fontname = rpt_helvetica
  SET rptfont->m_pointsize = 16
  SET _helvetica160 = uar_rptcreatefont (_hreport ,rptfont )
  SET rptfont->m_pointsize = 10
  SET _helvetica100 = uar_rptcreatefont (_hreport ,rptfont )
  SET rptfont->m_bold = rpt_on
  SET _helvetica10b0 = uar_rptcreatefont (_hreport ,rptfont )
  SET rptfont->m_pointsize = 14
  SET _helvetica14b0 = uar_rptcreatefont (_hreport ,rptfont )
  SET rptfont->m_pointsize = 10
  SET rptfont->m_italic = rpt_on
  SET rptfont->m_underline = rpt_on
  SET _helvetica10biu0 = uar_rptcreatefont (_hreport ,rptfont )
  SET rptfont->m_pointsize = 20
  SET rptfont->m_bold = rpt_off
  SET rptfont->m_italic = rpt_off
  SET rptfont->m_underline = rpt_off
  SET _helvetica200 = uar_rptcreatefont (_hreport ,rptfont )
  SET rptfont->m_pointsize = 14
  SET _helvetica140 = uar_rptcreatefont (_hreport ,rptfont )
 END ;Subroutine
 SUBROUTINE  _createpens (dummy )
  SET rptpen->m_recsize = 16
  SET rptpen->m_penwidth = 0.014
  SET rptpen->m_penstyle = 0
  SET rptpen->m_rgbcolor = rpt_black
  SET _pen14s0c0 = uar_rptcreatepen (_hreport ,rptpen )
  SET rptpen->m_penwidth = 0.030
  SET _pen30s0c0 = uar_rptcreatepen (_hreport ,rptpen )
  SET rptpen->m_penwidth = 0.014
  SET _pen13s0c0 = uar_rptcreatepen (_hreport ,rptpen )
 END ;Subroutine
 IF ((checkqueue ( $OUTDEV ) = 1 ) )
  SET _outputtype = rpt_postscript
 ELSE
  SET _outputtype = rpt_pdf
 ENDIF
 CALL initializereport (0 )
 CALL query1 (0 )
 CALL finalizereport (_sendto )
END GO
 
