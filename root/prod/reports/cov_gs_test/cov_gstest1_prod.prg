drop program cov_gstest1_prod go
create program cov_gstest1_prod
 
 
;****************************************************************************
;This file mainly contains some of CCL AdHoc's
;****************************************************************************
 
;---------------------------------------------------------------------------------------------------------------------
 
select fin = ea.alias, ce.encntr_id, ce.event_cd, ce.event_class_cd
, event = uar_get_code_display(ce.event_cd), ce.result_val, event_end_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, ce.event_id, ce.event_tag, ce.event_title_text
, ce.ce_dynamic_label_id, ce.valid_until_dt_tm, ce.result_status_cd, normalcy = uar_get_code_display(ce.normalcy_cd)
, ce.entry_mode_cd, ce.event_title_text, ce.event_tag, verify_dt = format(ce.verified_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, perform_dt = format(ce.performed_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, performed_by = pr.name_full_formatted, pr.position_cd, verified_by = pr1.name_full_formatted
, ce.event_id, ce.parent_event_id, ce.result_status_cd, ce.order_id
, e.person_id, fac = uar_get_code_display(e.loc_facility_cd)
, event_start_dt  = format(ce.event_start_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, ce.view_level, ce.publish_flag, ce.contributor_system_cd, ce.performed_prsnl_id, ce.verified_prsnl_id
 
from clinical_event ce, encntr_alias ea, prsnl pr, prsnl pr1, encounter e
 
where ce.encntr_id = ea.encntr_id
and e.encntr_id = ce.encntr_id
and ea.encntr_alias_type_cd = 1077
and ea.active_ind = 1
and ce.performed_prsnl_id = pr.person_id
and ce.verified_prsnl_id = pr1.person_id
and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
;and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
and ce.encntr_id = 131102430.00
;and ea.alias = '2300056040' ;'5222901296' - scheduling Selena on 8/16/22
;and ce.event_cd =     415132.00
;and ce.person_id =    16193220.00
;and ce.event_id = 3574908627.00
;and ce.ce_dynamic_label_id = 3554642936
order by ce.event_end_dt_tm desc
 
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d");,uar_code(d,1)
 
;and ce.event_cd in(34439957, 24604416)
;and ce.ce_dynamic_label_id in(11219940744.00, 11219968729.00,11220775967.00)
;order by ce.ce_dynamic_label_id
;and ce.order_id =  3847825403.00
;and ce.person_id =    15283188.00
;and ce.event_end_dt_tm between cnvtdatetimE("01-JAN-2020 00:00:00") AND cnvtdatetimE("28-MAR-2021 23:59:00")
;and ce.event_cd =   23931154.00
 
 
;and ce.event_title_text != 'IVPARENT'
;and ce.view_level = 1
;and ce.publish_flag = 1
;and ce.event_tag_set_flag = 1
 
;, result_status = uar_get_code_display(ce.result_status_cd)
;, note = uar_get_code_display(ce.entry_mode_cd), ce.entry_mode_cd
;, ce.parent_event_id, ce.ce_dynamic_label_id
;, result_val_dt = format(cnvtdatetime(cnvtdate2(substring(3,8,ce.result_val),"YYYYMMDD")
;				,cnvtint(substring(11,6,ce.result_val))),"MM/dd/yyyy hh:mm;;d")
;, ce.*
 
 
 
;with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
 
;with nocounter, separator=" ", format
 
;with format(date,";;q"),uar_code(d,1)
 
;,age_years = build2(piece(trim(cnvtage(p.birth_dt_tm), 3), ' ', 1, "#UNDEF"),'Years')
 
 
select ce.encntr_id, ce.event_cd
, event = uar_get_code_display(ce.event_cd), ce.result_val, event_end_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, ce.event_tag, ce.event_title_text
, ce.ce_dynamic_label_id, ce.valid_until_dt_tm, ce.result_status_cd, normalcy = uar_get_code_display(ce.normalcy_cd)
, ce.entry_mode_cd, ce.event_title_text, ce.event_tag, verify_dt = format(ce.verified_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, perform_dt = format(ce.performed_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, ce.event_id, ce.parent_event_id, ce.result_status_cd, ce.order_id
, event_start_dt  = format(ce.event_start_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, ce.view_level, ce.publish_flag, ce.contributor_system_cd, ce.performed_prsnl_id, ce.verified_prsnl_id, ce.*
 
from clinical_event ce
where ce.encntr_id =   128655117
 
ZZZTEST, DEVGRP ENC = 128655117
;--------------------------------------------------------------------------------------
;Patient Location and Type History
select elh.encntr_id, elh.loc_nurse_unit_cd, elh.encntr_type_cd;, nu_des = uar_get_code_description(elh.loc_nurse_unit_cd)
, elh.beg_effective_dt_tm, elh.end_effective_dt_tm, elh.loc_bed_cd, elh.loc_room_cd, elh.active_ind
, elh.arrive_dt_tm, elh.depart_dt_tm, elh.*
from encntr_loc_hist elh, encntr_alias ea
where elh.encntr_id = ea.encntr_id and ea.encntr_alias_type_cd = 1077 
and elh.active_ind = 1
;and elh.encntr_id = 129982728.00
and ea.alias = '5218602728'
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
 
;Patient Type history via pm_transaction
select pt.n_loc_facility_cd, pt.n_loc_nurse_unit_cd, pt.n_fin_nbr, pt.n_encntr_id
, pt.n_encntr_type_cd, pt.activity_dt_tm, pt.n_encntr_status_cd, pt.n_est_arrive_dt_tm, pt.n_est_depart_dt_tm
from pm_transaction pt where pt.n_fin_nbr = '2112600498'
order by pt.n_fin_nbr, pt.activity_dt_tm
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
 
;--------------------------------------------------------------------------------------------------------
select * from encntr_alias ea where ea.alias = '5214602354'
 
select * from prsnl pr where pr.person_id = 20468866.00
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
 
;Patient Location History
select elh.loc_nurse_unit_cd,nu = uar_get_code_display(elh.loc_nurse_unit_cd), nu_des = uar_get_code_description(elh.loc_nurse_unit_cd)
,bed = uar_get_code_display(elh.loc_bed_cd), room = uar_get_code_display(elh.loc_room_cd), elh.active_ind
,beg_dt = elh.beg_effective_dt_tm  "@SHORTDATETIME", end_dt = elh.end_effective_dt_tm  "@SHORTDATETIME" , elh.*
from encntr_loc_hist elh, encntr_alias ea
where elh.encntr_id = ea.encntr_id
and ea.active_ind = 1
and ea.encntr_alias_type_cd = 1077
and elh.active_ind = 1
;and ea.alias = '2131800440'
and elh.encntr_id = 128935237
 
 
select elh.encntr_id, elh.encntr_loc_hist_id, unit = trim(uar_get_code_display(elh.loc_nurse_unit_cd))
, beg = elh.beg_effective_dt_tm ';;q' ,enddt =  elh.end_effective_dt_tm ';;q', elh.*
from encntr_loc_hist elh where elh.encntr_loc_hist_id = 1193914542.00
and elh.active_ind = 1
 
;Encounter Type History
select etype = uar_get_code_display(pt.n_encntr_type_cd), pt.n_est_arrive_dt_tm ';;q', pt.n_est_depart_dt_tm ';;q'
,pt.activity_dt_tm ';;q', pt.updt_dt_tm ';;q', pt.*
from pm_transaction pt
where pt.n_fin_nbr = '2115900637'
;where pt.n_encntr_id =   124823383.00
order by pt.activity_dt_tm

;--------------------------------------------------------------------------------------------------------------
;PAtient admit in 8 hrs

select e.encntr_id, ea.alias
from encounter e, encntr_alias ea
where e.loc_facility_cd = 2552503645.00 ;PW
	and e.reg_dt_tm between cnvtdatetime("29-MAR-2022 00:00:00") and cnvtdatetime("29-MAR-2022 23:59:00")
	and e.encntr_type_cd in(309308.00);, 309310.00,309312.00);Inpatient, Emergency
	and e.encntr_id != 0.0
	and e.disch_dt_tm is null
	and ea.encntr_id = e.encntr_id
	and ea.encntr_alias_type_cd = 1077
with nocounter, separator=" ", format, time = 300 ; uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180
 
;--------------------------------------------------------------------------------------------------------------

 
select * from prsnl pr where pr.person_id = 20468866.00
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
 
 
select cdr.result_dt_tm ';;q' from ce_date_result cdr where cdr.event_id =  3684841622.00
 
select tt = datetimepart(cnvtdatetime("20-Jun-2016 13:45:00"),1) from dummyt
 
select tt = format(cnvtdatetime("20-Jun-2016 13:45:00"), 'mm/dd hh:mm;;d') from dummyt
 
 
select * from orders o where o.encntr_id =   125172412.00   and o.catalog_cd = 3713507.00
 
select * from order_detail od where od.order_id =  4524427239.00
 
select * from clinical_event ce where ce.order_id =  4524427239.00
 
select loc = uar_get_code_display(e.loc_nurse_unit_cd) from encounter e where e.encntr_id =   125616621.00
 
select * from ce_med_result cmr where cmr.event_id =  3666464890.00
 
select * from immunization_modifier im where im.person_id =    20541667.00
 
;---------------------------------------------------------------------------------------------------------------------
;Find a max eventid
select max(ce1.event_id) from clinical_event ce1
where ce1.encntr_id =   117183818.00
and ce1.event_cd = 2563735305.00
and ce1.result_status_cd in (25,34,35)
and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00")
group by ce1.encntr_id, ce1.event_cd
 
;---------------------------------------------------------------------------------------------------------------------
;ICD, Nomenclature, Diagnoses
select d.encntr_id, diag_type = uar_get_code_display(d.diag_type_cd),icd = uar_get_code_display(n.source_vocabulary_cd)
, d.diag_type_cd, d.clinical_diag_priority, d.diagnosis_display, n.source_string, d.active_ind
, n.source_identifier
from diagnosis d, nomenclature n
where n.nomenclature_id = d.nomenclature_id
and d.encntr_id =   123140858.00
;and n.source_vocabulary_cd = 19350056.00	;ICD-10-CM
 
select * from encntr_alias ea where ea.alias = '2300578928';'2300212092'
 
select * from diagnosis d where d.encntr_id =   123140858.00
 
select * from encounter e where e.encntr_id =  123140858.00
 
select * from problem d where d.person_id =    16318591.00
 
;----------------------------------------------------------------------------------------------------------------------
;Nurse Unit Prompt based on facility_accn_prefix_cd
select distinct
nurse_unit = trim(uar_get_code_display(nu.location_cd))
,unit_desc = trim(uar_get_code_description(nu.location_cd))
,nurse_unit_cd = nu.location_cd
from nurse_unit nu, location l
where l.location_cd = nu.loc_facility_cd
and l.facility_accn_prefix_cd = $acute_facilities
and nu.active_status_cd = 188
and nu.active_ind = 1
and nu.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
and nu.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
order by nurse_unit
;----------------------------------------------------------------------------------------------------------------------
;Identify  CMG clinicas - It's called an Org_Set and the name of the Org Set is called CMG for Reporting.
 
SELECT
                O.ACTIVE_IND
                , O.NAME
                , ORG.ACTIVE_IND
                , ORG.ORG_NAME
FROM
                ORG_SET   O
                , ORG_SET_ORG_R   OS
                , ORGANIZATION   ORG
 
WHERE o.org_set_id = os.org_set_id
AND os.organization_id = org.organization_Id
AND os.active_ind = 1
AND o.name LIKE '*CMG*'
 
WITH MAXREC = 1000, NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
 
;----------------------------------------------------------------------------------------------------------------------
;Nurse Unit Prompt based on loc_facility_cd
select distinct
nurse_unit = trim(uar_get_code_display(nu.location_cd))
,unit_desc = trim(uar_get_code_description(nu.location_cd))
,nurse_unit_cd = nu.location_cd
from nurse_unit nu, location l
where l.location_cd = nu.loc_facility_cd
and l.location_cd = 2552503645.00;PW ;$facility_list
and nu.active_status_cd = 188
and nu.active_ind = 1
and nu.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
and nu.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
order nurse_unit
 
;----------------------------------------------------------------------------------------------------------------------
 
;CCL report Audit - to see anything hanging out there
;*** Recycle all CPM servers in Olympus if reports are hanging ***
select p.name_full_formatted,p.username,cra.begin_dt_tm ";;q", cra.end_dt_tm ";;q",cra.status,cra.object_name,*
from ccl_report_audit cra, prsnl p
where cra.begin_dt_tm >= cnvtdatetime(curdate,0)
and(cra.object_name in( "LH_SEP_ALERT_REPORT_CUST*", "COV_PHQ_RESTRAINT_DOCUMENT_LOG*")
	OR cra.object_type in("DAREPORT","DAQUERY"))
and p.person_id = cra.updt_id
order by cra.begin_dt_tm desc
 
;----------------------------------------------------------------------------------------------------------------------
;Find admission history forms
SELECT
	CV1.CODE_VALUE,
	CV1.DISPLAY,
	CV1.CDF_MEANING,
	CV1.DESCRIPTION,
	CV1.DISPLAY_KEY,
	CV1.CKI
FROM CODE_VALUE CV1
 
WHERE CV1.CODE_SET =  72 AND CV1.ACTIVE_IND = 1
;and cnvtlower(cV1.DISPLAY) = '*history*form'
WITH  FORMAT, TIME = 60
 
;------------------------------------------------------------------------------------------------------------------------
;All Nurse units - all acute hospitals only
SELECT
	CV1.CODE_VALUE
	,CV1.DISPLAY
	,CV1.CDF_MEANING
	,CV1.DESCRIPTION
;	,CV1.DISPLAY_KEY
;	,CV1.CKI
;	,CV1.DEFINITION
 FROM CODE_VALUE CV1
 
WHERE CV1.CODE_SET =  220 AND CV1.ACTIVE_IND = 1
AND CV1.CDF_MEANING = 'NURSEUNIT'
ORDER BY CV1.DISPLAY
 
;------------------------------------------------------------------------------------------------------------------------
;Acute facilities prompt based on facility_accn_prefix_cd
select
    cv1.code_value
    ,cv1.display
    ,cv1.description
from code_value cv1
where cv1.code_set =  2062 and cv1.active_ind = 1
and cv1.display != cnvtstring(99)
order by cv1.description
 
;------------------------------------------------------------------------------------------------------------------------
;All Cov Facilities
 
select cv.code_value, cv.display
from  code_value  cv
where cv.code_set = 220
and cv.cdf_meaning = 'FACILITY'
and cv.active_ind = 1
order by  cv.display
 
;------------------------------------------------------------------------------------------------------------------------
 
select cv.code_value, cv.display, facility_prefix = uar_get_code_display(l.facility_accn_prefix_cd), g.*
from  code_value  cv, location l, organization g
where cv.code_set = 220
and cv.cdf_meaning = 'FACILITY'
and cv.active_ind = 1
and l.location_cd = cv.code_value
and g.organization_id = l.organization_id
order by  cv.display
 
;----------------------------------------------------------------------------------------------------------
;Facility
 
select
    cv1.code_value
    ,cv1.display
    ,cv1.description
from code_value cv1
where cv1.code_set =  2062 and cv1.active_ind = 1
and cv1.display != cnvtstring(99)
order by cv1.description
 
;----------------------------------------------------------------------------------------------------------
;Nurse Unit
select distinct
nurse_unit = trim(uar_get_code_display(nu.location_cd))
,unit_desc = trim(uar_get_code_description(nu.location_cd))
,nurse_unit_cd = nu.location_cd, nu.beg_effective_dt_tm "@SHORTDATETIME"
from nurse_unit nu, location l
where l.location_cd = nu.loc_facility_cd
and l.facility_accn_prefix_cd =  2554055109.00 ;	02	PWMC ;$acute_facilities
and nu.active_status_cd = 188
and nu.active_ind = 1
and nu.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
and nu.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
order by nu.beg_effective_dt_tm desc
;order nurse_unit
 
 
;------------------------------------------------------------------------------
;LOS with curdate
los = build2(datetimediff(cnvtdatetime(curdate,curtime3), e.reg_dt_tm), 'Days')
 
;------------------------------------------------------------------------------
;Patient Location History
select nu = uar_get_code_display(elh.loc_nurse_unit_cd), nu_des = uar_get_code_description(elh.loc_nurse_unit_cd)
,bed = uar_get_code_display(elh.loc_bed_cd), room = uar_get_code_display(elh.loc_room_cd)
,BEG = elh.beg_effective_dt_tm  "@SHORTDATETIME", ed = elh.end_effective_dt_tm  "@SHORTDATETIME" , elh.*
from encntr_loc_hist elh where elh.encntr_id =    123770838.00
and elh.active_ind = 1
 
select * from encntr_alias ea where ea.alias = '2027600208'
;-------------------------------------------------------------------------------------
;Get encounters in a date range
select e.encntr_id, e.loc_facility_cd, e.loc_nurse_unit_cd, type = uar_get_code_display(e.encntr_type_cd) , e.encntr_type_cd
,LOC = uar_get_code_display(e.location_cd)
from encounter e
where e.encntr_id = 116716222
 
where e.loc_facility_cd = 2553765603.00
and e.disch_dt_tm between cnvtdatetime("20-SEP-2020 00:00:00") and cnvtdatetime("30-SEP-2020 23:59:00")
 
;--------------------------------------------------------------------------------------------
;Get encounter details
select ea.alias,e.encntr_id, e.person_id, fac = uar_get_code_display(e.loc_facility_cd)
, loc = uar_get_code_display(e.location_cd),e.loc_nurse_unit_cd, p.birth_dt_tm ';;q'
, age = cnvtage(p.birth_dt_tm, e. reg_dt_tm,0), p.name_full_formatted
, nu = uar_get_code_display(e.loc_nurse_unit_cd) ,enc_type = uar_get_code_display(e.encntr_type_cd)
, e.location_cd, e.loc_facility_cd, e.encntr_type_cd, e.reg_dt_tm "@SHORTDATETIME", e.disch_dt_tm "@SHORTDATETIME"
from encounter e, encntr_alias ea, person p
where e.encntr_id = ea.encntr_id
and p.person_id = e.person_id
;and e.encntr_id = 120970764.00
and ea.alias ='2003400064'
and ea.encntr_alias_type_cd = 1077
 
;------------------------------------------------------------------------------------------------
 
 
select ce.encntr_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm ';;q', ce.order_id
from clinical_event ce
where ce.event_cd in(3348558931.00,3348561753.00)
and ce.event_end_dt_tm between cnvtdatetime("23-NOV-2020 00:00:00") and cnvtdatetime("20-JAN-2021 23:59:00")
order by ce.encntr_id, ce.event_end_dt_tm
with nocounter, separator=" ", format, time = 180
 
  121990463.00
 
;--------------------------------------------------------------------------------
 
select PR.name_full_formatted, pr.username, pos = uar_get_code_display(pr.position_cd), pr.*
from prsnl pr ;where pr.person_id = 16468478.00
;where pr.username = 'SJones4'
where cnvtupper(pr.name_last) = 'COLLIER'
 
MONDAY, SHARON N RN	SMONDAY	Nurse - Supervisor	   16720049.00
HANKINS, HEATHER	HHANKINS	IT - PowerChart	   17789909.00
 
or position_var = 'Nurse - Supervisor' or position_var = 'IT - PowerChart'
 
 
select PR.name_full_formatted, pr.username, pos = uar_get_code_display(pr.position_cd)
from prsnl pr where pr.position_cd = 3266274081.00 ;Quality Manager
 
 
select * from person p where p.person_id in (14521639.00,16468478.00)
 
select alias_type = uar_get_code_display(pa.prsnl_alias_type_cd), pool = uar_get_code_display(pa.alias_pool_cd),  pa.*
from	prsnl_alias pa where pa.person_id = 16468671.00
 
select info_tyep = uar_get_code_display(pa.info_type_cd), pa.*
from	prsnl_info pa where pa.person_id = 16468671.00
 
select * from clinical_event ce where ce.person_id = 16468671.00
 
 
where e.person_id = 16468671.00
 
DAY, BRENDA G RN	BDAY	LTC - Nurse Supervisor	   16468671.00
 
Brenda Day on 9north Transitional Care
 
For LCMC, their employee contract name is FSSNH Covid. For FSR, their contract name is: FSR TCU Nursing Home
 
Prsnl table-person_id
16468478.00	BUCKNER, REBECCA SUE
16468671.00	DAY, BRENDA G	LTC - Nurse Supervisor
 
Encounter table-person_id
   14521639.00	BUCKNER, REBECCA S
   15616973.00	CARPENTER, JON C
   19683998.00	DAY, BRENDA
 
 
select * from person p where p.person_id in (14521639.00,19683998.00,15616973.00)
 
;PRSNL SSN
select p.name_full_formatted,alias_type = uar_get_code_display(pa.prsnl_alias_type_cd), pa.alias
,alias_sub_type = uar_get_code_display(pa.prsnl_alias_sub_type_cd), pa.*
from prsnl_alias pa, person p
where pa.person_id = p.person_id
and pa.person_id in (16468478.00,16468671.00)
order by pa.person_id
 
select pa.person_id, alias_type = uar_get_code_display(pa.prsnl_alias_type_cd), pa.alias
from  prsnl_alias pa
where pa.person_id = (select p.person_id
		from person p, prsnl pr, code_value cv1
		where cv1.code_set =  88 and cv1.active_ind = 1
		and cnvtupper(cv1.display) = 'LTC*'
		and p.name_full_formatted != 'UA*'
		and p.name_full_formatted != 'Cerner Test*'
		and p.name_full_formatted != 'SOVERA*'
		and p.active_ind = 1
		and pr.position_cd = cv1.code_value
		and pr.active_ind = 1
		and p.person_id = pr.person_id)
order by pa.alias
 
 
;Patient SSN
select p.name_full_formatted,alias_type = uar_get_code_display(pa.person_alias_type_cd), pa.alias
,pool = uar_get_code_display(pa.alias_pool_cd)
,alias_sub_type = uar_get_code_display(pa.person_alias_sub_type_cd), pa.*
from person_alias pa, person p
where pa.person_id = p.person_id
and pa.person_id in (14521639.00,19683998.00,15616973.00)
order by pa.person_id
 
;Patient Location History
select loc = uar_get_code_display(elh.loc_building_cd)
,BEG = elh.beg_effective_dt_tm  "@SHORTDATETIME", ed = elh.end_effective_dt_tm  "@SHORTDATETIME" , elh.*
from encntr_loc_hist elh where elh.encntr_id in(121669835.00,  121670231.00)
and elh.active_ind = 1
 
 
;Charge
select ord_loc = uar_get_code_display(c.perf_loc_cd),c.*
from charge c where c.encntr_id in(121669835.00,  121670231.00)
 
 
 
 
 
 
select PR.name_full_formatted, pr.username, pos = uar_get_code_display(pr.position_cd), pr.*
from prsnl pr ;where pr.person_id in (19683998.00,14521639.00,16468478.00,15616973.00)
where cnvtupper(pr.name_last) = 'CALLOWAY';, JENNIFER
 
select * from encntr_alias ef where ef.encntr_id in (121669835.00, 121670231.00)
 
select ef.encntr_id, ef.prsnl_person_id
, reltn = uar_get_code_display(ef.encntr_prsnl_r_cd), etype = uar_get_code_display(ef.encntr_type_cd)
from encntr_prsnl_reltn ef where ef.encntr_id in (121669835.00, 121670231.00)
 
select ef.encntr_id, ef.*
from encntr_location ef where ef.encntr_id in (121669835.00, 121670231.00)
 
select * from encntr_type_params ep where ep.encntr_type_cd =  2555137099.00
 
select * from orders o where o.order_id =  3689131747.00
 
select * from long_text lt where lt.long_text_id in( 1063170047.00, 1063213581.00)
 
select tt = format(CNVTLOOKBEHIND("3,M"),'mm/dd/yy hh:mm:ss;;d') from dummyt
 
select * from person p where p.person_id in(14499390.00,15501045.00)
 
 
  2554148457.00
 2554138251.00
 
 
SELECT
	CV1.CODE_VALUE
	,CV1.DISPLAY
	,CV1.CDF_MEANING
	,CV1.DESCRIPTION
	,CV1.DISPLAY_KEY
	,CV1.CKI
	,CV1.DEFINITION
 FROM CODE_VALUE CV1
 
WHERE CV1.CODE_SET =  88 AND CV1.ACTIVE_IND = 1
and cnvtupper(CV1.DISPLAY) = 'LTC*'
WITH  FORMAT, TIME = 60
 
 
select p.person_id,p.name_full_formatted, pos = uar_get_code_display(pr.position_cd), p.birth_dt_tm, p.abs_birth_dt_tm
from person p, prsnl pr, code_value cv1
where cv1.code_set =  88 and cv1.active_ind = 1
and cnvtupper(cv1.display) = 'LTC*'
and p.name_full_formatted != 'UA*'
and p.name_full_formatted != 'Cerner Test*'
and p.name_full_formatted != 'SOVERA*'
and pr.position_cd = cv1.code_value
and p.person_id = pr.person_id
 
 
select ;p.person_id,p.name_full_formatted, p.birth_dt_tm
pr.person_id, pos = uar_get_code_display(pr.position_cd), pr.name_full_formatted
,alias_pool = uar_get_code_display(pa.alias_pool_cd), pa.alias, alias_type = uar_get_code_display(pa.prsnl_alias_type_cd)
from ;person p,
 prsnl pr, code_value cv1, prsnl_alias pa
where cv1.code_set =  88 and cv1.active_ind = 1
and cnvtupper(cv1.display) = 'LTC*'
;and p.name_full_formatted != 'UA*'
;and p.name_full_formatted != 'Cerner Test*'
;and p.name_full_formatted != 'SOVERA*'
and pr.position_cd = cv1.code_value
and pa.person_id = pr.person_id
order by pr.person_id
 
 
select ;p.person_id,p.name_full_formatted, p.birth_dt_tm
pr.person_id, pos = uar_get_code_display(pr.position_cd), pr.name_full_formatted
,alias_pool = uar_get_code_display(pa.alias_pool_cd), pa.alias, alias_type = uar_get_code_display(pa.prsnl_alias_type_cd)
from ;person p,
 prsnl pr, code_value cv1, prsnl_alias pa
where cv1.code_set =  88 and cv1.active_ind = 1
and cnvtupper(cv1.display) = 'LTC*'
;and p.name_full_formatted != 'UA*'
;and p.name_full_formatted != 'Cerner Test*'
;and p.name_full_formatted != 'SOVERA*'
and pr.position_cd = cv1.code_value
and pa.person_id = pr.person_id
order by pr.person_id
 
 
 
select * from person_alias pa where pa.person_id =     16497407.00
 
select * from prsnl_info pa where pa.person_id =     16497407.00
 
select * from person p where p.person_id = 16497407.00
 
 
 
select * from person_alias pa where pa.person_id =     16497407.00
 
select * from prsnl_info pa where pa.person_id =     16497407.00
 
select * from person p where p.person_id = 16497407.00
 
 
select e.encntr_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm ';;q'
from encounter e, clinical_event ce
where ce.encntr_id = ce.encntr_id
and e.encntr_type_cd =  2555137099.00	;Contract
and e.reg_dt_tm between cnvtdatetime("01-NOV-2020 00:00:00") and cnvtdatetime("10-NOV-2020 23:59:00")
and (trim(ce.result_val) = 'Presumptive Positive' or trim(ce.result_val) = 'Positive'
		or trim(ce.result_val) = 'Presumptive Pos' or trim(ce.result_val) = 'Detected')
 
 
 
;--------------------------------------------------------------------------------
 
;PRSNL location
select
 p.name_full_formatted, p.username, loc = os.name
,pos = uar_get_code_display(p.position_cd)
 
from
	 prsnl p
      ,org_set_prsnl_r o
      ,org_set os
 
plan p where p.active_ind = 1
	;and p.person_id = reqinfo->updt_id
	;and cnvtlower(p.username) = 'jofferma' ;BDAY' Offermann, Jessica S
 
join o where o.prsnl_id = p.person_id
	and o.active_ind = 1
	and cnvtdatetime(curdate, curtime3) between o.beg_effective_dt_tm and o.end_effective_dt_tm
 
join os where os.org_set_id = o.org_set_id
	and os.active_ind = 1
	and cnvtdatetime(curdate, curtime3) between os.beg_effective_dt_tm and os.end_effective_dt_tm
 
with time = 120
 
;-----------------------------------------------------------------------------------
 
 
select
                o.active_ind
                , o.name
                , org.active_ind
                , org.org_name
from
                org_set   o
                , org_set_org_r   os
                , organization   org
 
WHERE o.org_set_id = os.org_set_id
AND os.organization_id = org.organization_Id
AND os.active_ind = 1
AND o.name LIKE '*CMG*'
 
WITH MAXREC = 1000, NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
select distinct
 org.organization_id ,org.org_name
 
from
   org_set o
   ,org_set_org_r os
   ,organization org
 
where o.org_set_id = os.org_set_id
and os.organization_id = org.organization_id
and os.active_ind = 1
and org.active_ind = 1
and o.name like '*CMG*'
order by org.org_name
 
;98 out of 107 from above CMG locations are scanning meds as per April's list (Dec'20)
;========================================================================================================
 
;Influenza
select e.encntr_id, e.person_id, e.reg_dt_tm ';;q';, contract_name = org.org_name
, e.encntr_type_cd, encounter_type = uar_get_code_display(e.encntr_type_cd), ce.result_val
from encounter e, clinical_event ce
where e.encntr_type_cd =  2555137099.00 ;Contract
and e.active_ind = 1
and e.reg_dt_tm between cnvtdatetime("01-AUG-2020 00:00:00") and cnvtdatetime("15-DEC-2020 23:59:00")
and ce.encntr_id = e.encntr_id
and ce.event_cd =     2820755.00 ;vacin_admin_inact_var
with nocounter, separator=" ", format, time = 180
 
;LTC Staff
select pr.person_id,pr.name_full_formatted, pos = uar_get_code_display(pr.position_cd)
from prsnl pr, code_value cv1
where cv1.code_set =  88 and cv1.active_ind = 1
and cnvtupper(cv1.display) = 'LTC*'
and pr.name_full_formatted != 'UA*'
and pr.name_full_formatted != 'Cerner Test*'
and pr.name_full_formatted != 'SOVERA*'
and pr.position_cd = cv1.code_value
with nocounter, separator=" ", format, time = 180
 
 
 
select cvs.*
from code_value_set cvs
plan cvs where cvs.definition = "COVCUSTOM"
order by cvs.display
 
;-------------------------------------------------------
;Influenza
select * from      100496
 
 3579001597.00 ;Influenza code value from code_set 100496
 
 select * from CODE_VALUE_GROUP cvg where cvg.parent_code_value = 3579001597.00
 
 ;Results from the tests
 select cvg.parent_code_value, cv1.code_value, cv1.display
 from CODE_VALUE_GROUP cvg , code_value cv1
 where cvg.parent_code_value = 3579001597.00
 and cv1.code_value = cvg.child_code_value
 and cv1.code_set = 72
 
    2556633411.00
   2556648193.00
   2560379627.00
   2560379669.00
   3110316829.00
   3110318071.00
;----------------------------------------------------------------------
 
SELECT
    E.ENCNTR_ID
    , E.REG_DT_TM
    , E.PERSON_ID
    , P.NAME_FULL_FORMATTED
FROM
    ENCOUNTER   E
    , PRSNL   P
PLAN e WHERE E.REG_DT_TM BETWEEN CNVTLOOKBEHIND("5,D") AND CNVTDATETIME(CURDATE, curtime3)
JOIN p WHERE P.PERSON_ID = E.PERSON_ID
WITH NOCOUNTER, SEPARATOR=" ", FORMAT, time = 30
 
 
select pr.person_id, pos = uar_get_code_display(pr.position_cd), pr.name_full_formatted
from prsnl pr, code_value cv1, encounter e
where cv1.code_set =  88 and cv1.active_ind = 1
and cnvtupper(cv1.display) = 'LTC*'
;and p.name_full_formatted != 'UA*'
;and p.name_full_formatted != 'Cerner Test*'
;and p.name_full_formatted != 'SOVERA*'
and pr.position_cd = cv1.code_value
and pr.person_id = e.person_id
and e.reg_dt_tm >= cnvtdatetime("01-OCT-2020 00:00:00")
order by pr.person_id
with nocounter, separator=" ", format, time = 180
 
select pr.person_id, pos = uar_get_code_display(pr.position_cd), pr.name_full_formatted
from prsnl pr, code_value cv1
where cv1.code_set =  88 and cv1.active_ind = 1
and cnvtupper(cv1.display) = 'LTC*'
and pr.name_full_formatted != 'UA*'
and pr.name_full_formatted != 'Cerner Test*'
and pr.name_full_formatted != 'SOVERA*'
and pr.position_cd = cv1.code_value
order by pr.person_id
with nocounter, separator=" ", format, time = 180
 
 
select * from person_alias pa where pa.person_id =     16497407.00
 
select * from prsnl pr where pr.person_id =    15631617.00
 
select * from person p where p.person_id =     11903978.00
 
select distinct e.encntr_id, etype = uar_get_code_display(e.encntr_type_cd),e.encntr_type_cd, e.reg_dt_tm ';;q'
,fac = uar_get_code_display(e.loc_facility_cd),loc = uar_get_code_display(e.location_cd), e.location_cd
from encounter e
where e.person_id = 19528210.00
 
select distinct e.encntr_id, dispo = uar_get_code_display(e.disch_disposition_cd), p.person_id
, etype = uar_get_code_display(e.encntr_type_cd),e.encntr_type_cd, e.reg_dt_tm ';;q', e.disch_dt_tm ';;q'
,fac = uar_get_code_display(e.loc_facility_cd),loc = uar_get_code_display(e.location_cd), e.location_cd
from encounter e, person p
where e.person_id = p.person_id
;and p.person_id = 14479147
and e.encntr_id = 122536861.00
order by e.disch_dt_tm desc
 
 
select o.order_mnemonic, o.orig_order_dt_tm from orders o where o.person_id = 15348539.00
 
select * from orders o where o.order_id =  3783323463.00
 
 
 
    2552513857.00  2552513857.00
 
select distinct
nurse_unit = trim(uar_get_code_display(nu.location_cd))
,unit_desc = trim(uar_get_code_description(nu.location_cd))
,nurse_unit_cd = nu.location_cd
from nurse_unit nu, location l
where l.location_cd = nu.loc_facility_cd
and l.location_cd = 2552503653.00;$facility_list
and nu.active_status_cd = 188
and nu.active_ind = 1
and nu.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
and nu.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
order nurse_unit
 
 
select draw = c.drawn_dt_tm ';;q', c.* from container c where c.container_id =   313417982.00
 
select ce.encntr_id, event = uar_get_code_display(ce.event_cd), ce.result_val
, event_end_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, event_start_dt  = format(ce.event_start_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, perform_dt = format(ce.performed_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, verify_dt = format(ce.verified_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, ce.event_tag, ce.event_title_text
from clinical_event ce where ce.order_id =  3843411267.00
 
 
select ce.encntr_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm ';;q', ce.order_id
from clinical_event ce
where ce.event_cd in( 2556633411.00, 2556648193.00,2560379627.00,2560379669.00,3110316829.00,3110318071.00);Influenza
;3358526621.00 ;SARS-CoV-2
;in(3348558931.00,3348561753.00)
and ce.event_end_dt_tm between cnvtdatetime("01-AUG-2020 00:00:00") and cnvtdatetime("20-JAN-2021 23:59:00")
order by ce.encntr_id, ce.event_end_dt_tm
with nocounter, separator=" ", format, time = 180
 
 
select * from orders o where o.order_id =  3777572469.00
 
 
	select tt = datetimediff(cnvtdatetime("01-JAN-2021 12:00:00"),cnvtdatetime("01-JAN-2021 09:00:00"),3)
		from dummyt
 
 
 
 select into $outdev
 e.encntr_id, fin = ea.alias, e.reg_dt_tm ';;q', location = uar_get_code_display(e.loc_facility_cd)
from 	encounter e
	,encntr_alias ea
plan e where ;operator(e.loc_facility_cd, op_ltc_facility_var, $ltc_facility)
	e.loc_facility_cd in(2553765707.00, 2553765371.00) ;FSR TCU, LCMC Nsg Home
	and e.active_ind = 1
	and (e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime))
	;and (e.reg_dt_tm between cnvtdatetime(start_date_var) and cnvtdatetime(end_date_var)) ;to schedule
join ea where ea.encntr_id = e.encntr_id
	and ea.active_ind = 1
	and ea.encntr_alias_type_cd = 1077
 
 
     638675.00	Still a Patient 30
     Lori's example - 2000103490
 
,((
 
select distinct e.person_id, e.encntr_id, e.reg_dt_tm ';;q', e.active_ind
	,etype = uar_get_code_display(e.encntr_type_cd), dispo = uar_get_code_display(e.disch_disposition_cd)
	,erank = rank() over(partition by e.person_id order by e.reg_dt_tm desc)
	from person p, encounter e
	where e.person_id = (select e1.person_id from encounter e1 where e1.encntr_id =   117832452.00)
	and p.person_id = e.person_id
	and e.disch_dt_tm != null
	order by erank
 
	with sqltype("f8", "f8", "dq8", "i4") )i
 )
 
plan i where i.erank = 1
 
 
select e.person_id, e.encntr_id, e.reg_dt_tm ';;q', e.active_ind
	,etype = uar_get_code_display(e.encntr_type_cd), dispo = uar_get_code_display(e.disch_disposition_cd)
	;,erank = rank() over(partition by e.person_id order by e.reg_dt_tm desc)
	from person p, encounter e
	where e.person_id = 14499390.00
	and p.person_id = e.person_id
	order by e.reg_dt_tm desc
	;and e.disch_dt_tm != null
 
 
select  e.person_id, e.encntr_id, e.reg_dt_tm ';;q', e.active_ind	,etype = uar_get_code_display(e.encntr_type_cd)
, dispo = uar_get_code_display(e.disch_disposition_cd)
from encounter e
where e.encntr_id =     122512968.00
 
 
where e.person_id = 16327390.00
order by e.reg_dt_tm desc
 
 
select * from encntr_alias ea where ea.alias = '2033603385'
 
   14479147.00
 
 
 
SELECT cv1.code_value,CV1.DISPLAY, CV1.DESCRIPTION, CV1.CDF_MEANING
from   CODE_VALUE   CV1
WHERE CV1.DISPLAY like 'PB*' ;change to match what you are looking for
AND   CV1.ACTIVE_IND = 1
AND   CV1.CODE_SET = 220
AND   CV1.CDF_MEANING IN ('BUILDING', 'FACILITY','NURSEUNIT', 'AMBULATORY')
 
 2553766251.00	PBB BCG	PBB BLOUNT CLINIC
 2553766283.00	PBLH KCG	PBLH KNOX CLINIC
 2553766299.00	PBL LCG	PBL LOUDON CLINIC
 2553766315.00	PBS SOG	PBS SEVIER CLINIC
 
 select * from organization o where o.organization_id = 2553766251.00
 
select * from
 
 
SELECT cv1.code_value,cv1.display, cv1.description, cv1.cdf_meaning
from   CODE_VALUE   CV1
WHERE CV1.DISPLAY like 'PB*' ;change to match what you are looking for
AND   CV1.ACTIVE_IND = 1
AND   CV1.CODE_SET = 220
AND   CV1.CDF_MEANING IN ('BUILDING', 'FACILITY','NURSEUNIT', 'AMBULATORY')
 
 
;*************************************************************************************************
 
 
 
 
select distinct
c_catalog_disp = uar_get_code_display(c.catalog_cd)
, admin_date = ce.admin_end_dt_tm ;format(ce.admin_end_dt_tm, "@shortdate;;q")
, injection_site = uar_get_code_display(ce.admin_site_cd) ;uhs
, lot_number = trim(ce.substance_lot_number) ;uhs
, manufacturer = uar_get_code_display(ce.substance_manufacturer_cd) ;uhs
;, expiration_date = format(ce.substance_exp_dt_tm, "@shortdate;;q") ;uhs
, vac_info_sheet = uar_get_code_display(i.vis_cd) ;uhs
, vis_publish_date = i.vis_dt_tm ; format(i.vis_dt_tm, "@shortdate;;q") ;uhs
 
from
	clinical_event c
	, ce_med_result ce
	, immunization_modifier i
 
plan c where c.person_id = 16193220.00
	and c.event_class_cd = 228 ;immunizations for uhs
	and c.order_id > 0 ;shows it was documented on the mar
	and c.event_end_dt_tm<= cnvtdatetime ( curdate, curtime3 )
	and c.valid_until_dt_tm>= cnvtdatetime ( curdate, curtime3 )
	and c.record_status_cd= 188 ;active_cd
 
join ce where ce.event_id = c.event_id
 
join i where i.person_id = c.person_id ;outerjoin(c.person_id) ;uhs
	and i.event_id = c.event_id
 
order by c.encntr_id, c_catalog_disp,ce.admin_end_dt_tm desc
 
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
 
 
select * from immunization_modifier im where im.person_id = 16193220.00
order by im.updt_dt_tm
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
 
 
2126902726
 
 309308.00 ;Inpatient
	     309312.00	Observation
   19962820.00	Outpatient in a Bed
 
 
select e.encntr_id, e.person_id
from encounter e where e.loc_facility_cd = 2552503613 ;$facility_list
	and e.disch_dt_tm between cnvtdatetime("29-SEP-2021 00:00:00") and cnvtdatetime("29-SEP-2021 23:59:00")
	and e.disch_dt_tm is not null
	and e.encntr_type_cd in(309308.00, 309312.00, 2555137051.00);Inpatient, Observation, Behavioral Health
	and e.encntr_id != 0.0
 
 
select e.encntr_id, e.person_id, ce.event_cd, tt = uar_get_code_display(ce.event_cd), ce.result_val
from encounter e, clinical_event ce
where e.loc_facility_cd = 2552503613
	and e.reg_dt_tm between cnvtdatetime("01-JUN-2021 00:00:00") and cnvtdatetime("30-JUN-2021 23:59:00")
	and e.encntr_type_cd in(309308.00, 309310.00,309312.00);Inpatient, Emergency
	and e.encntr_id != 0.0
	and ce.encntr_id = e.encntr_id
	;AND CE.event_cd = 21911751.00
 	and cnvtlower(ce.result_val) = '*team activation*'
with nocounter, separator=" ", format, time = 300 ; uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180
 
 
   21911751.00	D-Rapid Response Team Activation
   19820946.00	Provider Notification Reason
 
 
 
 select into 'nl:'
 from clinical_event c
 where c.encntr_id = trigger_encntrid
 and c.person_id = trigger_personid
 and c.event_cd = value(uar_get_code_by("DISPLAY", 72, "D-VTE Override Recommendation Reason"))
 and c.result_val = 'Primary service to address prophylaxis orders'
 and c.performed_prsnl_id = reqinfo->updt_id
 
 head report 
 	log_retval =0
 	log_message = 'Override Reason of Primary Service to Address Not Found'
 
 detail 
 	log_retval = 100
 	log_misc1 = format(c.event_end_dt_tm, 'dd-mmm-yyyy hh:mm:ss;;q')
 	log_message = concat( 'Override Reason of Primary Service to Address Found from ', log_misc1)
 
 with nullreport go
 
 
 
select cv1.code_value, cv1.display
from code_value cv1
where cv1.code_set =  72 and cv1.active_ind = 1
and cnvtlower(cv1.display) = '*team*'
;and cnvtlower(cv1.display) = 'emergency team*'
with  format, time = 60
 
 
 
 select e.encntr_id
from encounter e, health_plan hp
where e.loc_facility_cd = 2552503613
	and e.reg_dt_tm between cnvtdatetime("01-JUN-2021 00:00:00") and cnvtdatetime("30-JUN-2021 23:59:00")
	and e.encntr_type_cd in(309308.00, 309310.00,309312.00);Inpatient, Emergency
	and e.encntr_id != 0.0
	and ce.encntr_id = e.encntr_id
	;AND CE.event_cd = 21911751.00
 	and cnvtlower(ce.result_val) = '*team activation*'
with nocounter, separator=" ", format, time = 300 ; uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180
 
 
 
 
 
select distinct
    nurse_unit = uar_get_code_display(nu.location_cd)
   ,nurse_unit_cd = nu.location_cd
 
from nurse_unit nu
 
where nu.loc_facility_cd = 2552503645.00 ;PW
and nu.active_status_cd = 188 ;Active
           and nu.active_ind = 1
           and nu.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           and nu.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
order nurse_unit
 
 
select * from coding c where c.encntr_id =     124081362.00
with nocounter, separator=" ", format, time = 300 , uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
 
select * from coding_hist ch where ch.encntr_id =     124081362.00
with nocounter, separator=" ", format, time = 300 , uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
 
select * from omf_coding_st omf where omf.encntr_id =     124081362.00
with nocounter, separator=" ", format, time = 300 , uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
 
 
select * from diagnosis d where d.encntr_id = 125087558.00
with nocounter, separator=" ", format, time = 300 , uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
 
select * from nomenclature n where
and n.source_vocabulary_cd = value(uar_get_code_by("MEANING",400,"CPT4"))
with nocounter, separator=" ", format, time = 300 , uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
 
 
select n.nomenclature_id, n.source_vocabulary_cd, n.source_identifier, n.source_string
,d.diag_priority, d.diag_type_cd, d.contributor_system_cd, d.parent_entity_name, d.updt_dt_tm
from diagnosis d , nomenclature n
where d.encntr_id = 125087558.00
and n.nomenclature_id = d.nomenclature_id
and n.source_vocabulary_cd = 1222.00
 
 
select * from clinical_event ce where ce.encntr_id = 127457071.00
with nocounter, separator=" ", format, time = 300 , uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
 
 
ALIAS	ENCNTR_ID
2123000081	  124970785.00
 
cov_phq_bcma_leapfrog_compl
 
 
select c.encntr_id
, principle_type = uar_get_code_display(n.principle_type_cd)
, source_vocabulary = uar_get_code_display(n.source_vocabulary_cd)
, n.source_string, n.source_identifier
 
from coding c,procedure p, nomenclature n
 
plan c where c.encntr_id = 124970785.00
	and c.active_ind = 1
 
join p where p.encntr_id = c.encntr_id
	and p.active_ind = 1
 
join n where n.nomenclature_id = p.nomenclature_id
	;and n.source_vocabulary_cd = value(uar_get_code_by("MEANING",400,"CPT4"))
 
 
select c.encntr_id, cpt4_cd = cm.field6
;, c.charge_item_id, c.updt_dt_tm, c.item_price
, principle_type = uar_get_code_display(n.principle_type_cd)
, source_vocabulary = uar_get_code_display(n.source_vocabulary_cd)
, n.source_string, n.string_identifier, vocab_axis = uar_get_code_display(n.vocab_axis_cd)
 
from charge c,charge_mod cm,nomenclature n
 
plan c where c.encntr_id = 124970785.00
	;and c.active_ind = 1
 
join cm where cm.charge_item_id = c.charge_item_id
	;and cm.active_ind = 1
 
join n where n.nomenclature_id = cm.nomen_id
	;and n.source_vocabulary_cd = value(uar_get_code_by("MEANING",400,"CPT4"))
 
 
 
select cv1.code_value,cv1.display
from code_value cv1
where cv1.code_set =  333
	and cv1.display = 'Nurse*'
	and cv1.active_ind = 1
with  format, time = 60
 
 
 
SELECT * FROM ENCNTR_ALIAS EA WHERE EA.alias = '5203200826'
 
   128213503.00
 
 
select ea.alias
from encntr_alias ea
where ea.encntr_alias_type_cd = 1077


select  
	h.plan_name, h.active_ind, h.beg_effective_dt_tm, h.end_effective_dt_tm
	,h.health_plan_id, epr.encntr_id, epr.person_id, epr.priority_seq
from	health_plan h, encntr_plan_reltn epr, encntr_alias ea
 
plan epr where epr.encntr_id = 128213503.00
	and epr.priority_seq = 1
 
join h where h.health_plan_id = epr.health_plan_id
	and (cnvtupper(h.plan_name) = "BLUECARE" or cnvtupper(h.plan_name) = "TENNCARE*")
	and (cnvtupper(h.plan_name) != "BLUECARE PLUS")
	and h.active_ind = 1
 


 
select ; distinct into 'nl:'
 
	h.plan_name, h.active_ind, h.beg_effective_dt_tm, h.end_effective_dt_tm
	,h.health_plan_id, epr.encntr_id, epr.person_id, epr.priority_seq
from
	health_plan h, encntr_plan_reltn epr
 
plan epr where epr.encntr_id = 128213503.00
	and epr.priority_seq = 1
 
join h where h.health_plan_id = epr.health_plan_id
	and (cnvtupper(h.plan_name) = "BLUECARE" or cnvtupper(h.plan_name) = "TENNCARE*")
	and (cnvtupper(h.plan_name) != "BLUECARE PLUS")
	and h.active_ind = 1
 
 
 
select distinct
 
	h.plan_name, h.active_ind, h.beg_effective_dt_tm, h.end_effective_dt_tm
	,h.health_plan_id, epr.encntr_id, epr.person_id, epr.priority_seq, h.*
from
	health_plan h, encntr_plan_reltn epr
 
plan epr where epr.encntr_id = 128213503.00 ;15692110.00
	and epr.priority_seq = 1
 
join h where h.health_plan_id = epr.health_plan_id
	and h.active_ind = 1
 
order by h.health_plan_id
 
with nocounter, separator=" ", format, time = 300 , uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
 
 
select * from clinical_event ce where ce.encntr_id = 127914641.00
 
select o.orig_order_dt_tm, o.order_status_cd, o.status_dt_tm, o.order_mnemonic, o.order_detail_display_line,o.*
from orders o where o.encntr_id = 127914641.00
and o.order_mnemonic = 'Resuscitation Status/Medical Interventions'
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
 
select oa.order_id, oa.order_status_cd, oa.action_dt_tm, oa.clinical_display_line, oa.*
from order_action oa where oa.order_id in(5476234121.00,  5306543871.00, 5486560515.00)
order by oa.order_id
 
select * from order_detail od where od.order_id = 5476234121.00
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
 
 
 
ALIAS		ENCNTR_ID			PERSON_ID	FAC	LOC
5203200826	  128213503.00	   15692110.00	LCMC	LCMC LAB
 
 
 
select
h.plan_name, h.active_ind, h.beg_effective_dt_tm, h.end_effective_dt_tm
,h.health_plan_id, epr.encntr_id, epr.person_id, priority = epr.priority_seq, h.*, epr.*
from
	health_plan h, encntr_plan_reltn epr
 
plan epr where epr.encntr_id = 128213503.00
	and epr.priority_seq = 2
	and epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
 
 
join h where h.health_plan_id = epr.health_plan_id
	;and (cnvtupper(h.plan_name) = "BLUECARE" or cnvtupper(h.plan_name) = "TENNCARE*")
	;and (cnvtupper(h.plan_name) != "BLUECARE PLUS")
	and h.active_ind = 1
 
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
 
 
select distinct;(Deal breaker)
h.health_plan_id,h.plan_name, h.active_ind, h.beg_effective_dt_tm, h.end_effective_dt_tm
,h.health_plan_id, epr.encntr_id, epr.person_id, priority = epr.priority_seq, epr2.person_reltn_type_cd, h.*
 
 
from	health_plan h, encntr_plan_reltn epr, authorization au, encntr_person_reltn epr2, auth_detail ad, encounter e
;, person p
 
plan epr where epr.encntr_id = 128213503.00
	and epr.active_ind = 1
	and epr.priority_seq = 1
	and epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
 
join e where e.encntr_id = epr.encntr_id
 
join h where h.health_plan_id = epr.health_plan_id
	and h.active_ind = 1
 
join au where au.encntr_id = outerjoin(epr.encntr_id)
	and au.health_plan_id = outerjoin(epr.health_plan_id)
	and au.auth_type_cd = outerjoin(9769.00) ;Authorization
 
join ad where ad.authorization_id = outerjoin(au.authorization_id)
	and ad.active_ind = outerjoin(1)
	and ad.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
	and ad.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
 
join epr2 where epr2.encntr_id = outerjoin(epr.encntr_id)
	and epr2.person_reltn_type_cd = outerjoin(1158);Insured
	and epr2.active_ind = outerjoin(1)
	and epr2.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
	and epr2.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
 
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
 
 
 
 
 
select * from encntr_person_reltn epr where epr.encntr_id = 128213503.00
 
;select * from encntr_info au where au.encntr_id = 128213503.00
 
select * from person_alias pa where pa.person_id =       15692110.00
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
 
 
select * from long_text t where t.long_text_id =  1590123976.00
 
select e.encntr_id, e.person_id, e.loc_facility_cd,e.loc_nurse_unit_cd, e.reg_dt_tm, e.disch_dt_tm
,e.encntr_type_cd
from encounter e where e.loc_facility_cd =  2552552449.00
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120, maxrow = 10000
 
 
select * from person p where p.name_first = 'DEVGRP'
 
select * from encounter e where e.person_id =    21385680.00
 
 
cov_phq_bcma_lfrog_score_lb 
 
 QM Reason VTE Prophylaxis Not Given 2020 - Custom
 
 
select * from prsnl pr where pr.username = 'RHILL5' 
 
;Get powerform name
select * from dcp_forms_ref dfr
where dfr.description = 'QM Reason VTE Prphylaxis*'; Not Given 2020 - Custom'
order by dfr.updt_dt_tm desc
 
 
select * from dcp_forms_ref dfr
order by dfr.updt_dt_tm desc
 
 
select ea.alias, ea.* from encntr_alias ea 
where textlen(ea.alias) > 10
and ea.encntr_alias_type_cd = 1077
and ea.updt_dt_tm between cnvtdatetime("01-APR-2022 00:00:00") and cnvtdatetime("14-APR-2022 23:59:00")
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180;, maxrow = 5000

----------------------------------------------------------------------------------------------------------------------------------
;Neonatal
select ;distinct into $outdev
 
ce.encntr_id, e.loc_nurse_unit_cd, ce.event_cd, event = uar_get_code_display(ce.event_cd), ce.event_tag, ce.result_val
, ce.event_end_dt_tm, ce.event_id
 
from encounter e
	,clinical_event ce
 
plan e where e.loc_facility_cd = 2552503639.00 ;$acute_facility_list
	and e.active_ind = 1
 
join ce where ce.encntr_id = e.encntr_id
	and ce.person_id = e.person_id
	and ce.event_end_dt_tm between cnvtdatetime("01-APR-2022 00:00:00") and cnvtdatetime("19-APR-2022 23:59:00")
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.view_level = 1
      and ce.publish_flag = 1
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
      ;and ce.event_cd in(21910890.00, 2564760537.00)
	and ce.event_cd in(value(uar_get_code_by("DISPLAY", 72, 'Resuscitation Outcome')),
				 value(uar_get_code_by('DISPLAY', 72, 'Paper Code Blue Record on Chart')) )
	
	;resuci_outcome_var, paper_codeblu_var)
 
order by ce.encntr_id, ce.event_cd, ce.event_end_dt_tm, ce.event_id

with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180;, maxrow = 5000



select cv.code_value, cv.cdf_meaning, cv.display
from code_value cv
where cv.code_set = 220
and cv.cdf_meaning = 'NURSEUNIT'
and cv.display = '*TEMP*'
and cv.active_ind = 1



cov_phq_leapcpoe_scor_inpat.prg

cov_phq_leapcpoe_scor_no_temp.prg


select cv.code_value, cv.display
from code_value cv
where cv.code_set = 6006
and cv.code_value in(2560,2561,2562,2576706321, 2553560097, 2553560089, 20094437.00,54416801.00)



select e.encntr_id, e.loc_facility_cd, e.loc_nurse_unit_cd, o.ordered_as_mnemonic
,od.oe_field_id, od.oe_field_meaning, od.oe_field_display_value, od.order_id, od.updt_dt_tm
from order_detail od, orders o, encounter e 
where o.order_id = od.order_id
and e.encntr_id = o.encntr_id 
and cnvtupper(od.oe_field_meaning) = 'PATOWNMED'
and od.oe_field_id = 663784.00
and cnvtupper(od.oe_field_display_value) = 'YES'
and od.updt_dt_tm between cnvtdatetime("25-APR-2022 00:00:00") and cnvtdatetime("30-APR-2022 23:59:00")
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1)


select od.* 
from order_detail od
where od.order_id = 5603602241.00
order by od.parent_action_sequence

select od.* 
from order_detail od
where od.order_id =  5803827565
and cnvtupper(od.oe_field_meaning) = 'PATOWNMED'
and od.oe_field_id = 663784.00
and cnvtupper(od.oe_field_display_value) = 'YES'

select * from orders o where o.order_id = 5803827565


select o.ordered_as_mnemonic, o.* from orders o
where o.order_id =  5603602241.00
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1)


select o.ordered_as_mnemonic, o.order_id, o.template_order_id, o.* from orders o
where o.encntr_id = 129017666
order by o.ordered_as_mnemonic
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1)

select * from orders o where o.template_order_id =  5603602241.00

select o.ordered_as_mnemonic, o.order_id, o.template_order_id, oa.action_dt_tm, oa.*
from orders o, order_action oa
where o.template_order_id =  5881295689
and oa.order_id = o.order_id
and oa.action_sequence = 1
order by oa.action_dt_tm
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1)



select * from order_action oa
where oa.order_id =  5881295689
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1)

17052042	5881295689	1


select cv.* from code_value 
where cv.code_set = 220
;and cv.cdf_meaning = 'NURSEUNIT'
and cv.display in(
	'MMC 2W', 'MMC 3E', 'MMC 3W', 'MMC 4W', 'MMC 5W', 'MMC Stepdown',	'MMC CCU', 'MMC CVU', 'MMC ICU', 'MMC FBC', 'FSR 2N',
	'FSR 3N', 'FSR 3W', 'FSR 5N', 'FSR 5W', 'FSR 6E', 'FSR 6N', 'FSR 6W', 'FSR 7N', 'FSR 8N', 'FSR CV ICU', 'FSR CV SD',
	'FSR  ICU', 'FSR IMC', 'FSR NEURO', 'FSR LD', 'PW 2M', 'PW 3C', 'PW 3M', 'PW 3R', 'PW 4M', 'PW 4R', 'PW C1', 'PW C2',
	'PW CB', 'MHHS 2S', 'MHHS 3S', 'MHHS 4S', 'MHHS CCU', 'MHHS IMC', 'MHHS LD', 'LCMC 3M', 'LCMC 3S', 'LCMC ICU', 'LCMC IMC',
	'LCMC OB', 'FLMC CCU', 'FLMC MSU', 'RMC 2N', 'RMC ICU')
order by cv.display


select * from code_value cv
where cv.code_value in(19468404,20094437,681544,54416801,2576706321,2553560097,2560,2553560089,2561,2562)
and cv.code_set = 6006

;o.template_order_id, o.order_id,o.* from orders o

select o.order_id, o.orig_order_dt_tm ';;q', oa.action_dt_tm ';;q', o.active_status_dt_tm, o.updt_dt_tm, o.updt_cnt
, o.updt_applctx, o.updt_task
,com_type = uar_get_code_display(oa.communication_type_cd), oa.action_sequence, unit = uar_get_code_display(elh.loc_nurse_unit_cd)
from orders o, order_action oa , encntr_loc_hist elh
where oa.order_id = o.order_id
and elh.encntr_id = o.encntr_id
and o.orig_order_dt_tm between elh.beg_effective_dt_tm and elh.end_effective_dt_tm
and elh.active_ind = 1
and oa.action_sequence = 1
and oa.order_id in( 5870667073.00
 
 
 
select cv.code_value, cv.display
from code_value cv
where cv.code_set = 200
and cv.code_value in (2552703197,47583263 ,165382375, 2561119727 ,165382565 ,165382675 ,165382689 ,2553018573, 
     165382661 , 165382589 , 2554793611 ,165382707 ,165382727 ,21267059 ,21267063 ,21267067 , 2549885359 , 2575842575 ,
     2575843071 , 2575842529 , 25469175 ,2557642447 ,2561931299 , 2575805731 ,2561930481 , 2557648183 , 2561955475 ,
     25471495 ,25471519 , 24591363 , 2549886971 , 2575841511 , 2575960697 , 25473521 , 2549888743 , 2552610353 , 2563538799 ,
     25463731 , 2563394971 ,2575841071 ,165375843 ,165376027 ,21266999 , 2579380153 ,165381811 , 108665841 ,108649991 ,
     108635085 , 34998213 ,2578713535 , 2557870887 ,2557870909 , 2575842903 , 2557731363 , 2560158023 ,24300177 ,24300189 ,
     24300186 ,24300168 , 24300192 ,24300216 ,24300198 ,2549890863 ,44933843 ,24300195 , 25474617 ,2557727517 , 2557648751 ,
     161252229 ,2557666171 ,24592231 ,2554793823 ,56622607 ,2557728325 ,257079695 ,2557618729 ,257618317 ,165381905 ,
     165381929 , 165381947 , 165381967,2553018583 ,2553018603 ,2553018323 ) 


ov_phq_process_metrics





Record pat(
	1 rec_cnt = i4
	1 list[*]
		2 facility = vc
		2 fin = vc
		2 encntrid = f8
		2 personid = f8
		2 pm1_ext_rx_queried = vc
		2 pm1_whom = vc
		2 pm1_postn = vc
		2 pm1_time_comp = vc
		2 pm1_comp_before_meddoc = vc
 
)
 
;Process Metric: 1) Y/N External Rx queried? If so, by whom/position/time completed/completed before meds were documented? 




select ce.encntr_id, ce.event_cd, ce.result_val
from clinical_event ce
where ce.event_end_dt_tm between cnvtdatetime("01-MAY-2022 00:00:00") and cnvtdatetime("15-MAY-2022 23:59:00")
and cnvtlower(ce.result_val) = 'code blue activation'
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1)


select pa.encntr_id, pa.alert_source, pa.alert_txt, pa.passive_alert_id 
from passive_alert pa 
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000

select e.encntr_status_cd from encounter e where e.encntr_id = 130072601.00


select * from orders o where o.encntr_id =  130072601.00

ALIAS	ENCNTR_ID
5217300422	  130072601.00

;Addmission Medrec
select * from order_recon ore 
where ore.encntr_id =   129535221.00 
and ore.recon_type_flag = 1 ;admission
order by ore.order_recon_id




CODE_VALUE		DISPLAY		CDF_MEANING	DESCRIPTION
 2562751601.00	MHA Endoscopy	ANCILSURG	MHA Endoscopy
 2696158491.00	MHA FLOORSTOCK	PHARM	MHA FLOORSTOCK
 2562751547.00	MHA Main OR	ANCILSURG	MHA Main OR
 2562751623.00	MHA Non Surgical	ANCILSURG	MHA Non Surgical
 2562751677.00	MHA Preadmission Testing	ANCILSURG	MHA Preadmission Testing
 2570759713.00	MHA TEMP INTR	NURSEUNIT	MHA TEMP INTRA
 2570759089.00	MHA TEMP OR DAY SUR	NURSEUNIT	MHA TEMP OR DAY SURG
 2553766075.00	MHAS ASC	AMBULATORY	MHA AMBULATORY SURGERY CENTER
 
 2553766075.00		MHA AMBULATORY SURGERY CENTER
 
 2553766075.00		MHA Ambulatory Surgery Center
 
 
 
 
 
  
fin = ea.alias, e.encntr_id, n.nomenclature_id, n.source_vocabulary_cd, n.source_identifier, n.source_string
,d.diag_priority, d.diag_type_cd, d.contributor_system_cd, d.parent_entity_name, d.updt_dt_tm, e.loc_nurse_unit_cd
 
from encounter e
	,diagnosis d
	,nomenclature n
	,coding c
	,encntr_alias ea
 
plan e ;where e.loc_facility_cd = $acute_facility_list
	;and operator(e.loc_nurse_unit_cd, opr_nu_var, $nurse_unit)
	where e.disch_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	; and e.encntr_id = 124970785.00 ;125087558.00
	and e.active_ind = 1
 
join c where c.encntr_id = e.encntr_id
	and c.active_ind = 1
 
join d where d.encntr_id = c.encntr_id
	and d.contributor_system_cd = c.contributor_system_cd
	;and d.diag_priority = 1
	;and d.diag_type_cd = 89.00 ;Final
	and d.active_ind = 1
 
join n where n.nomenclature_id = d.nomenclature_id
	;and n.source_vocabulary_cd in(19350056.00,1222.00);ICD-10-CM, HCPCS
 	and n.active_ind = 1
 
join ea where ea.encntr_id = d.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
order by e.encntr_id, n.source_vocabulary_cd, d.diag_priority

 
 
 select txt = textlen('Stayed, Other: awaiting donor')
 , str = findstring("Other:" ,'Stayed, Other: awaiting donor')
 ,ft = trim(substring((findstring("Other:" , 'Stayed, Other: awaiting donor') + 7) ,textlen('Stayed, Other: awaiting donor') ,
 					'Stayed, Other: awaiting donor'))
 , coma = substring(1, 8 , 'Stayed, Other: awaiting donor') 
 
 ; ,textlen('Stayed, Other: awaiting donor') ,
 ;					'Stayed, Other: awaiting donor')					
 from dummyt
 
 
 
 textlen('Stayed on current unit, Other: awaiting donor services and family prefrence')
 
 trim(substring(( findstring("!" ,o.cki) + 1 ) ,textlen(o.cki) ,o.cki))
 
 trim(substring(( findstring("!" ,o.cki) + 1 ) ,textlen(o.cki) ,o.cki))
 
 
 select tt = substring(1, (findstring("Other:", ce.result_val) -3), ce.result_val)
 from clinical_event ce where ce.encntr_id =   130090550.00
 and ce.event_cd =    21910897.00
 
 
     2680509.00	        236.00	Cooling Measures

select ce.encntr_id, ce.result_val
from clinical_event ce 
where ce.event_end_dt_tm between cnvtdatetime("01-MAY-2022 00:00:00") and cnvtdatetime("15-MAY-2022 23:59:00")
and ce.event_cd = 2680509.00
and cnvtlower(ce.result_val) = 'therapeutic cooling device*'
or cnvtlower(ce.result_val) = '*therapeutic hypothermia'
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000

 
5222703238	  131195898.00	   15043179.00
 
======================== AMERIGROUP ========================================================= 
 
select
	org.org_name,h.plan_name, epr.encntr_id,epr.updt_dt_tm
	, h.active_ind, h.beg_effective_dt_tm, h.end_effective_dt_tm
	,h.health_plan_id, epr.person_id, epr.priority_seq, epr.*
 
from	encntr_plan_reltn epr, health_plan h, org_plan_reltn o, organization org
 
plan epr where epr.person_id = 15043179.00
	;epr.encntr_id = encntrid
	and epr.priority_seq = 1
	and epr.active_ind = 1
 
join h where h.health_plan_id = epr.health_plan_id
	and h.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
	and h.active_ind = 1
 
join o where o.health_plan_id = h.health_plan_id
	and o.org_plan_reltn_cd = 1200.00
	and o.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
	and o.active_ind = 1
 
join org where org.organization_id = o.organization_id
	and org.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
	;and org.org_name = 'Amerigroup'
	and org.active_ind = 1
  
order by epr.person_id, epr.encntr_id 
 
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1)

--------------------------------------------------------------------------------------
;PREVIOUS ENCOUNTER
select 
  org.org_name, h.plan_name, h.active_ind, h.beg_effective_dt_tm, epr_actine_ind = epr.active_ind
, h.end_effective_dt_tm, h.health_plan_id, epr.encntr_id, epr.person_id, epr.updt_dt_tm, i.erank
 
from	encntr_plan_reltn epr, health_plan h, org_plan_reltn o, organization org
 
,((	select distinct e.person_id, e.encntr_id, e.reg_dt_tm
	,erank = rank() over(partition by e.person_id order by e.reg_dt_tm desc)
	from person p, encounter e
	where e.person_id = (select e1.person_id from encounter e1 where e1.encntr_id = 131195898.00)
	and p.person_id = e.person_id
	and e.disch_dt_tm != null
	with sqltype("f8", "f8", "dq8", "i4") )i
 )
 
plan i where i.erank = 2;1
 
join epr where epr.encntr_id = i.encntr_id
	;epr.person_id = i.person_id
	and epr.priority_seq = 1
	and epr.active_ind = 1
 
join h where h.health_plan_id = epr.health_plan_id
	and h.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
	and h.active_ind = 1
 
join o where o.health_plan_id = h.health_plan_id
	and o.org_plan_reltn_cd = 1200.00
	and o.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
	and o.active_ind = 1
 
join org where org.organization_id = o.organization_id
	and org.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
	and org.org_name = 'Amerigroup'
	and org.active_ind = 1

with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1)


select * from encntr_plan_reltn epr
where epr.encntr_id = 113062810.00
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1)

========================================================================================================

;Interpreter Redesign

select ;into 'nl:'
	ce.*
 from clinical_event ce
 where ce.encntr_id =   110764270.00 ;trigger_encntrid 
 ;and ce.person_id = trigger_personid
 and ce.event_cd = value(uar_get_code_by("DISPLAY", 72, "Requested Communication Tools"))
 ;and ce.result_val in('Video interpretation', 'In-person interpretation', 'Telephone interpretation')
 and ce.result_val in('Video interpretation, In-person interpretation, Telephone interpretation')
 and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
 and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
 
 head report 
 	log_retval =0
 	log_message = 'Interpreter Request Not Found'
 
 detail 
 	log_retval = 100
 	log_misc1 = build2(trim(ce.result_val, format(ce.event_end_dt_tm, 'dd-mmm-yyyy hh:mm:ss;;q'))
 	log_message = concat( 'Interpreter Request Found on ', log_misc1)
 
 with nullreport go
 
 
----------------------------------------------------------------------      
      
select pp.interp_required_cd, pp.interp_type_cd, pp.* from person_patient pp where pp.person_id =    15556726.00     
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1);, maxrow = 10000
      
 
      
select pa.encntr_id, pa.alert_source, pa.alert_txt, pa.passive_alert_id, pa.updt_dt_tm
from passive_alert pa 
where pa.updt_dt_tm >= cnvtdatetime('01-AUG-2021 00:00:00')
and pa.alert_source = 'COV_SZ_INTERP_REQ'
;and pa.alert_txt = 
order by pa.updt_dt_tm desc
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000
      
      
select e.encntr_id, e.reg_dt_tm, e.encntr_type_cd, p.name_full_formatted, p.person_id
from person p, encounter e 
where e.person_id = p.person_id
and p.name_full_formatted = 'TTTTMAYO, FSRTEST'
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000

ENCNTR_ID	  REG_DT_TM	            ENCNTR_TYPE_DISPLAY	NAME_FULL_FORMATTED	PERSON_ID
110353215.00  04-02-2018 13:10:50	Quick Lab Registration	TTTTMAYO, FSRTEST	   16432316.00
      
      
      
      
      
      
      
      
      
      
      
      
      
