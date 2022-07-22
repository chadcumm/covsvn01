drop program cov_gstest1 go
create program cov_gstest1
 
prompt
	"Output to File/Printer/MINe" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
;****************************************************************************
;This file mainly contains some of CCL AdHoc's
;****************************************************************************
 
;---------------------------------------------------------------------------------------------------------------------
 
select fin = ea.alias, ce.encntr_id, ce.event_cd
, event = uar_get_code_display(ce.event_cd), ce.result_val, event_end_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, ce.ce_dynamic_label_id, ce.valid_until_dt_tm, ce.result_status_cd, normalcy = uar_get_code_display(ce.normalcy_cd)
, ce.event_title_text, ce.event_tag, verify_dt = format(ce.verified_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, perform_dt = format(ce.performed_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, performed_by = pr.name_full_formatted, verified_by = pr1.name_full_formatted
, ce.event_id, ce.parent_event_id, ce.result_status_cd, ce.order_id
, e.person_id, fac = uar_get_code_display(e.loc_facility_cd), e.loc_facility_cd
, event_start_dt  = format(ce.event_start_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, ce.view_level, ce.publish_flag
 
from clinical_event ce, encntr_alias ea, prsnl pr, prsnl pr1, encounter e
 
where ce.encntr_id = ea.encntr_id
and e.encntr_id = ce.encntr_id
and ea.encntr_alias_type_cd = 1077
and ea.active_ind = 1
and ce.performed_prsnl_id = pr.person_id
and ce.verified_prsnl_id = pr1.person_id
and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
;and ce.encntr_id =   125399773.00
and ea.alias = '2108400021'
;and ce.event_id = 3686938696.00
;and ce.ce_dynamic_label_id =      11367714587.00
order by event_end_dt asc
 
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
 
 
;--------------------------------------------------------------------------------------
;Patient Location and Type History
select elh.encntr_id, elh.loc_nurse_unit_cd, elh.encntr_type_cd;, nu_des = uar_get_code_description(elh.loc_nurse_unit_cd)
, elh.beg_effective_dt_tm, elh.end_effective_dt_tm, elh.loc_bed_cd, elh.loc_room_cd, elh.active_ind, elh.*
from encntr_loc_hist elh where elh.encntr_id =    125532321.00
and elh.active_ind = 1
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
 
;Patient Type history via pm_transaction
select pt.n_loc_facility_cd, pt.n_loc_nurse_unit_cd, pt.n_fin_nbr, pt.n_encntr_id
, pt.n_encntr_type_cd, pt.activity_dt_tm, pt.n_encntr_status_cd, pt.n_est_arrive_dt_tm, pt.n_est_depart_dt_tm
from pm_transaction pt where pt.n_fin_nbr in('2120400869','2120300502') 
order by pt.n_fin_nbr, pt.activity_dt_tm
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
 
;--------------------------------------------------------------------------------------------------------
select * from encntr_alias ea where ea.alias = '2116102215'
 
;Patient Location History
select elh.loc_nurse_unit_cd,nu = uar_get_code_display(elh.loc_nurse_unit_cd), nu_des = uar_get_code_description(elh.loc_nurse_unit_cd)
,bed = uar_get_code_display(elh.loc_bed_cd), room = uar_get_code_display(elh.loc_room_cd), elh.active_ind
,BEG = elh.beg_effective_dt_tm  "@SHORTDATETIME", ed = elh.end_effective_dt_tm  "@SHORTDATETIME" , elh.*
from encntr_loc_hist elh, encntr_alias ea
where elh.encntr_id = ea.encntr_id
and ea.active_ind = 1
and ea.encntr_alias_type_cd = 1077
and elh.active_ind = 1
and ea.alias = '2115900637'
;and elh.encntr_id =   124844677.00
 
 
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
 
select cdr.result_dt_tm ';;q' from ce_date_result cdr where cdr.event_id =  3684841622.00
 
select tt = datetimepart(cnvtdatetime("20-Jun-2016 13:45:00"),1) from dummyt
 
select * from orders o where o.encntr_id =   125172412.00   and o.catalog_cd = 3713507.00
 
select * from order_detail od where od.order_id =  4524427239.00

select * from clinical_event ce where ce.order_id =  4524427239.00
 
select * from encounter e where e.encntr_id =   124127041

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
and l.location_cd = 2552503645.00;$facility_list
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
	and p.username = 'BDAY'
 
join o where o.prsnl_id = p.person_id
	and o.active_ind = 1
	and cnvtdatetime(curdate, curtime3) between o.beg_effective_dt_tm and o.end_effective_dt_tm
 
join os where os.org_set_id = o.org_set_id
	and os.active_ind = 1
	and cnvtdatetime(curdate, curtime3) between os.beg_effective_dt_tm and os.end_effective_dt_tm
 
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
 
select dg.encntr_id, dg.diagnosis_display, n.source_identifier
from
	 encounter e
	, diagnosis dg
	, nomenclature n
 
plan e where  e.loc_facility_cd = 21250403.00
	and e.disch_dt_tm between cnvtdatetime("10-DEC-2020 00:00:00") and cnvtdatetime("30-JAN-2021 23:59:00")
	and e.encntr_type_cd in(309310.00, 309308.00, 309312.00, 19962820.00);ED, Inpatient, Observation, Outpatient in a Bed
	and e.active_ind = 1
	and e.encntr_id != 0.00
	and e.disch_dt_tm is not null
 
join dg where dg.encntr_id = e.encntr_id
	and dg.active_ind = 1
	and dg.active_status_cd = 188
	and dg.diagnosis_display != ''
 
join n where n.nomenclature_id = dg.nomenclature_id
	;and n.source_vocabulary_cd = 19350056.00 ;ICD-10-CM
	and n.active_ind = 1
	and n.end_effective_dt_tm > sysdate
	and n.active_status_cd = 188
	and n.source_identifier in ('A02.1', 'A22.7', 'A26.7', 'A32.7', 'A40.0', 'A40.1', 'A40.3', 'A40.8', 'A40.9', 'A41.01', 'A41.02',
					'A41.1', 'A41.2', 'A41.3', 'A41.4', 'A41.50', 'A41.51', 'A41.52', 'A41.53', 'A41.59', 'A41.8', 'A41.81',
					'A41.89', 'A41.9', 'A42.7', 'A54.86', 'R65.20', 'R65.21','B37.7')
 
order by e.person_id, e.encntr_id
 
 
 
SELECT distinct n.short_string, n.source_string, n.source_identifier
FROM nomenclature n
	;and n.source_vocabulary_cd = 19350056.00 ;ICD-10-CM
	where n.active_ind = 1
	;and n.end_effective_dt_tm > sysdate
	and n.active_status_cd = 188
	and n.source_identifier in('A41.50', 'B37.7')
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT, maxrow = 10000, time = 240
 
 
	in ('A02.1', 'A22.7', 'A26.7', 'A32.7', 'A40.0', 'A40.1', 'A40.3', 'A40.8', 'A40.9', 'A41.01', 'A41.02',
					'A41.1', 'A41.2', 'A41.3', 'A41.4', 'A41.50', 'A41.51', 'A41.52', 'A41.53', 'A41.59', 'A41.8', 'A41.81',
					'A41.89', 'A41.9', 'A42.7', 'A54.86', 'R65.20', 'R65.21','B37.7')
 
 
 
;BCMA ----------------------------------------------------------------------------------------------------------------------------
 
select ce.event_id, med = uar_get_code_display(ce.event_cd), ce.event_end_dt_tm ';;q', ce.result_status_cd
, mae.beg_dt_tm, , medication_scanned = if(mae.positive_med_ident_ind = 1) 'Y' else 'N' endif
, wristband_scanned = if(mae.positive_patient_ident_ind = 1) 'Y' else 'N' endif
 
from clinical_event ce, med_admin_event mae
where ce.encntr_id =   121558928.00
and ce.event_id = mae.event_id
 
 
 
 INSERT INTO DM_INFO DI
SET DI.INFO_DOMAIN_ID = 0.0
  , DI.INFO_DOMAIN = 'MUSE_FUNCTIONAL'
  , DI.INFO_NAME = 'MUSE_IGNORE_EPR_END_EFFECTIVE'
 
select * from DM_INFO DI
where
   DI.INFO_DOMAIN = 'MUSE_FUNCTIONAL'
  and DI.INFO_NAME = 'MUSE_IGNORE_EPR_END_EFFECTIVE'
 
 
 
 
select uar_get_code_display(l.location_cd), l.* from nurse_unit l where l.loc_facility_cd = 2552552449
 
 
select cv1.code_value, cv1.display, cv1.description
from code_value cv1
where cv1.code_set =  2062
and cv1.active_ind = 1
and cv1.display != cnvtstring(99)
union(select cv2.code_value, cv2.display, cv2.description
	from code_value cv2
	where cv2.code_set = 220
	and cv2.code_value = 2552552449.00
	and cv2.active_ind = 1
)
order by 3
 
 
select distinct
nurse_unit = trim(uar_get_code_display(nu.location_cd))
,unit_desc = trim(uar_get_code_description(nu.location_cd))
,nurse_unit_cd = nu.location_cd
from nurse_unit nu, location l
where l.location_cd = nu.loc_facility_cd
and (l.facility_accn_prefix_cd = $acute_facilities or (l.location_cd = 2552552449.00))
and nu.active_status_cd = 188
and nu.active_ind = 1
and nu.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
and nu.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
order nurse_unit
 
 2552552449.00	COV CORP HOSP
, RDBUNION
 
select * from encntr_alias ea where ea.alias = '2102702588'
select * from encounter e where e.encntr_id =   122840833.00
 
 
SELECT
    facility = UAR_GET_CODE_DISPLAY(l.location_cd),l.organization_id
FROM location l
WHERE l.location_type_cd = 783.00
AND l.location_cd IN (   21250403.00,
 2552503613.00,
 2552503635.00,
 2552503649.00,
 2552503653.00,
 2552503657.00,
 2552503639.00,
 2552503645.00,
   29797179.00,
 2553765531.00,
 2553765627
 ,2553765707
 ,2553765371,
 2553765579.00,
2553765571
)
AND l.active_ind = 1
 
ORDER BY facility
 
 
select distinct
nurse_unit = trim(uar_get_code_display(nu.location_cd))
,unit_desc = trim(uar_get_code_description(nu.location_cd))
,nurse_unit_cd = nu.location_cd
from nurse_unit nu, location l
where l.location_cd = nu.location_cd
and l.organization_id =      3144501.00
and nu.active_status_cd = 188
and nu.active_ind = 1
and nu.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
and nu.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
order nurse_unit
 
select parent_folder=e1.item_desc,description=e2.item_desc,programname=e2.item_name
from EXPLORER_MENU e1, EXPLORER_MENU e2
WHERE e1.menu_id=outerjoin(e2.menu_parent_id)
AND e2.active_ind=1
AND e1.active_ind=outerjoin(1)
AND e2.item_type="P" AND CNVTLOWER(e2.item_desc)="*orders*"
ORDER BY e1.item_desc, e2.item_desc
with maxrec=1000, time=100
 
 
 
 
When trying to determine if a position has access to a specific Discern Explorer / CCL program,
you may need to evaluate if that program lives in an Explorer Menu Report folder,
and if application group security is applied to that folder. You would also need to find the DA2 folders
where that report lives (DA_REPORT, DA_FOLDER_REPORT_RETLN, DA_FOLDER) and then evaluate if a position or
group has Read access granted to that folder (DA_GROUP_SECURITY).
 
 
select df.da_folder_id, df.da_folder_name, df.parent_folder_id, uar_get_code_display(df.folder_type_cd)
,folder_type = uar_get_code_display(df.folder_type_cd)
from da_folder df
 
 
    4338704.00	      3396072.00	eMeasures 2020
 
select * from da_folder_report_reltn dfqr where dfqr.da_folder_id = 4338704.00
 
     4338706.00
    4338709.00
    4338711.00
    4338713.00
    4338715.00
 
select dr.da_report_id, owner_group = uar_get_code_display(dr.owner_group_cd),dr.report_name
from da_report dr where dr.da_report_id in(4338706.00,4338709.00,4338711.00,4338713.00,4338715.00)
 
select * from DA_TABLE_RELTN
 
select dgs.parent_entity_id, dgs.parent_entity_name, security_group = uar_get_code_display(dgs.security_group_cd)
, security_assignment = uar_get_code_display(dgs.security_assignment_cd)
from DA_TABLE_RELTN dtr, da_group_security dgs
where dgs.parent_entity_id = dtr.parent_entity_id
 
select dgs.parent_entity_id, dgs.parent_entity_name, dgs.prsnl_id,pr.name_full_formatted
, pos = uar_get_code_display(pr.position_cd),security_assignment = uar_get_code_display(dgs.security_assignment_cd)
from DA_TABLE_RELTN dtr, da_user_security dgs, prsnl pr
where pr.person_id = dgs.prsnl_id
and dgs.parent_entity_id = dtr.parent_entity_id
 
select group = uar_get_code_display(dgur.group_cd),pr.name_full_formatted, pos = uar_get_code_display(pr.position_cd)
from da_group_user_reltn dgur, prsnl pr
where pr.person_id = dgur.prsnl_id
 
select distinct
     ID = f.da_folder_id
    ,FOLDER = f.da_folder_name
from DA_FOLDER f
    ,(inner join DA_GROUP_SECURITY gs on gs.parent_entity_id = f.da_folder_id ;.parent_folder_id
        and gs.parent_entity_name = "DA_FOLDER")
where f.da_folder_id > 0
    and gs.active_ind = 1
    and f.public_ind = 1
order by f.da_folder_name
 
 
select * from encntr_alias ea where ea.alias in('2107802326','2107801570')
 
select * from person pr where pr.name_full_formatted = 'AMANN, DANIEL COOP
 
select * from encounter e where e.person_id =    20446654.00
 
select ce.encntr_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm ';;q'
,ce.verified_dt_tm ';;q', normalcy = uar_get_code_display(ce.normalcy_cd)
,ce.event_id, cea_eid = cea.event_id
from clinical_event ce
, (left join ce_event_action cea on cea.encntr_id = ce.encntr_id and cea.event_id = ce.event_id)
plan ce where ce.encntr_id = 123770838
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
join cea
 
 
select distinct cea.encntr_id, event = uar_get_code_display(cea.event_cd)
, normalcy = uar_get_code_display(cea.normalcy_cd),cea.event_id, cea.updt_dt_tm ';;q', cea.result_status_cd
from ce_event_action cea
where cea.encntr_id = 123770838
 
 
select * from ce_event_action cea where cea.encntr_id = 123770838
;cea.event_id in(3322655561.00,  3322665799.00)
 
select ce.encntr_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm ';;q'
,fac = uar_get_code_display(e.loc_facility_cd)
from clinical_event ce, encounter e
where e.encntr_id = ce.encntr_id
and ce.event_cd =   21910883.00
order by e.loc_facility_cd, ce.event_end_dt_tm
with nocounter, seperator = ' ', format, maxrow = 1000, time = 180
 
 
 
    21910883.00	Date, Time of Cardiopulmonary Arrest
 
 
select distinct
nurse_unit = trim(uar_get_code_description(nu.location_cd))
,nurse_unit_cd = nu.location_cd
from nurse_unit nu, location l
where l.location_cd = nu.location_cd
and l.organization_id = 675844.00; $facility
and nu.active_status_cd = 188
and nu.active_ind = 1
and nu.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
and nu.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
order nurse_unit
 
;------------------------------------------------------------------------
;Med Rec
 
select
 
Facility = uar_get_code_display(e.loc_facility_cd)
, fin = ea.alias, e.encntr_id
, pat_name = p.name_full_formatted
, order_dt = format(o.orig_order_dt_tm, 'mm/dd/yyyy hh:mm;;q')
, med = o.ordered_as_mnemonic
, status = uar_get_code_display(o.order_status_cd)
, o.order_id
 
from
	encounter e
	, orders o
	;, order_action oa
	, encntr_alias ea
	;, encntr_alias ea1
	, person p
	;, prsnl pr
	;, prsnl pr1
 
plan ea where ea.alias = '2108402905'
	and ea.active_ind = 1
	and ea.encntr_alias_type_cd = 1077
 
join e where e.encntr_id = ea.encntr_id
	and e.active_ind = 1
	and e.encntr_id != 0
 
join o where o.encntr_id = e.encntr_id ;grab all rx orders regardless of order status
	;and o.orig_order_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and o.orig_ord_as_flag = 1 ;Prescription/Discharge Order
	and o.active_ind = 1
	and o.activity_type_cd = 705.00 ;Pharmacy
 
/*join oa where oa.order_id = o.order_id
	and oa.action_sequence = o.last_action_sequence
 
join ea1 where ea1.encntr_id = e.encntr_id
	and ea1.active_ind = 1
	and ea1.encntr_alias_type_cd = 1079*/
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
/*join pr where pr.person_id = oa.order_provider_id
	and pr.active_ind = 1
 
join pr1 where pr1.person_id = outerjoin(oa.supervising_provider_id)
	and pr1.active_ind = outerjoin(1)*/
 
order by facility, fin, order_dt, o.order_id
 
 
 
select * from order_compliance oc where oc.encntr_id =   123695080.00
 
 
CONVERT_AUDIT_TRANSACTION CAT
,  CONVERT_AUDIT_SYNONYM  CAS
 
;Comfort Care
SELECT
 ce.encntr_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_cd
, ce.event_title_text, ce.event_tag
, event_end_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
from clinical_event ce
where ce.event_end_dt_tm between cnvtdatetimE("01-JAN-2021 00:00:00") AND cnvtdatetimE("30-JAN-2021 23:59:00")
and ce.event_cd in( 3107692509.00, 3107692533.00, 3107692653.00, 3107692581.00, 3107692557.00, 3107692603.00, 3107692629.00)
 
 
 
;-------------------------------------------------------------------------------------------
;Power Plan query for Kristy ramage
 
select * from orders o where o.encntr_id =   118741070.00
 
select o.order_mnemonic, o.updt_dt_tm ';;q', o.* from orders o where o.person_id = 18214848.00
order by o.updt_dt_tm, o.order_mnemonic
 
select op.order_mnemonic, op.created_dt_tm ';;q', op.updt_dt_tm ';;q', op.*
from order_proposal op where op.person_id = 18214848.00
order by op.updt_dt_tm, op.order_mnemonic
 
 
select
 fin = ea.alias ,pw.encntr_id, pw.person_id, apc.pathway_id
 , ocs.mnemonic , pw.order_dt_tm ';;q' ,powerplan_status = uar_get_code_display(pw.pw_status_cd)
 , action_type = uar_get_code_display(pa.action_type_cd)
 ,component_status = uar_get_code_display(apc.comp_status_cd)
 ,component_type = uar_get_code_display(apc.comp_type_cd), apc.parent_entity_name
 , category = uar_get_code_display(apc.dcp_clin_cat_cd)
 ;, pw.pathway_id , apc.included_ind, apc.parent_entity_name
 ;, catatlog = uar_get_code_display(ocs.catalog_cd)
 ;, dcp = uar_get_code_display(apc.dcp_clin_cat_cd)
 
from
 pathway pw
 , pathway_action pa
 , act_pw_comp apc
 , order_catalog_synonym ocs
 , encntr_alias ea
 /*, order_sentence_detail osd*/
 
plan pw
where pw.person_id = 18214848.00
;where pw.encntr_id =   118741070.00
and pw.active_ind = 1
and pw.order_dt_tm > cnvtdatetime('03-MAY-2021 15:00:00.00')
;and pw.pw_status_cd in (
; value(uar_get_code_by("meaning", 16769, "PLANPROPOSE"))
; , value(uar_get_code_by("meaning", 16769, "PLANNED"))
;)
 
join pa where pw.pathway_id = pa.pathway_id
 
join ea where ea.encntr_id = pw.encntr_id
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
;join dfr where dfr.dcp_form_instance_id = pw.comp_forms_ref_id
;	and dfr.active_ind = 1
 
join apc
where apc.pathway_id = pw.pathway_id
;and apc.ref_prnt_ent_name = "ORDER_CATALOG_SYNONYM"
;and apc.dcp_clin_cat_cd = value(uar_get_code_by("meaning", 16389, "MEDICATIONS"))
;and apc.parent_entity_name in ("PROPOSAL", "ORDERS")
and apc.active_ind = 1
;and apc.included_ind = 1 /*Order is included in PowerPlan*/
 
join ocs
where ocs.synonym_id = apc.ref_prnt_ent_id
;and ocs.catalog_type_cd = value(uar_get_code_by("meaning", 6000, "PHARMACY"))
and ocs.active_ind = 1
 
order by pw.person_id, pw.encntr_id
 
;------------------------------------------------------------------------------------
 
 
SELECT
  PLAN_NAME=P.DESCRIPTION
  ,PHASE_DESC=PCA2.DESCRIPTION
FROM
  PATHWAY_CATALOG   P
  , PW_CAT_RELTN   PCR
  , PATHWAY_CATALOG   PCA2
 
  WHERE P.ACTIVE_IND=1
  AND P.REF_OWNER_PERSON_ID=0
  AND P.TYPE_MEAN != "PHASE"
  AND P.BEG_EFFECTIVE_DT_TM < CNVTDATETIME(SYSDATE) ;PRODUCTION PLANS ONLY
  AND PCR.pw_cat_s_id= OUTERJOIN (P.pathway_catalog_id)
  AND PCR.type_mean= OUTERJOIN ("GROUP")
  AND PCA2.pathway_catalog_id=  OUTERJOIN (PCR.pw_cat_t_id)
 
 
 
select * from dcp_forms_ref dfr
 
select * from pathway_catalog pc
 
 
      10745.00	Activated
      10746.00	Canceled
      10747.00	Excluded
      10748.00	Included
     674357.00	Failed Create
    3542934.00	Unavailable
   18650561.00	Moved
    4370689.00	Skipped
 
;------------------------------------------------------------------------------------------
 
select p.person_id,p.username,p.name_full_formatted,position_disp = uar_get_code_display(P.position_cd)
,p_active_status_disp = uar_get_code_display(p.active_status_cd)
,datetimediff(cnvtdatetime(curdate,curtime3),p.create_dt_tm)
,p.create_dt_tm, p.end_effective_dt_tm
 
from prsnl p
where not exists
	(select pp.prsnl_id from person_prsnl_activity pp
		where p.person_id = pp.prsnl_id)
		and cnvtupper(p.username) = "KRAMAGE"
		and datetimediff(cnvtdatetime(curdate,curtime3),p.create_dt_tm) > 180
 
with format (date,"mm/dd/yyyy hh:mm;;")
 
 
 
select * from prsnl pr where cnvtupper(pr.username) = "KRAMAGE"
 
   12735791.00
select * from person_prsnl_activity pp where pp.prsnl_id = 12735791.00 and pp.person_id = 18214848.00
 
 
 
select o.encntr_id, o.order_id, o.order_mnemonic, o.projected_stop_dt_tm ';;q',o.order_detail_display_line
 
from orders o
where  o.catalog_cd =     4180632.00 ; o.encntr_id =   124138913.00 ;trans->plist[d.seq].encntrid
	and o.active_ind = 1
	and o.order_id = (select max(o1.order_id) from orders o1
			 where o1.encntr_id = o.encntr_id and o1.catalog_cd = o.catalog_cd)
	and o.active_status_cd = 188
	and o.order_status_cd = 2550.00 ;Ordered
	and o.current_start_dt_tm <= sysdate
;	and (o.projected_stop_dt_tm > sysdate or o.projected_stop_dt_tm is null)
 
order by o.encntr_id, o.projected_stop_dt_tm desc
 
with nocounter, format, separator = "", maxrow = 10000
 
 
 select max(e.encntr_id) from encounter e where e.person_id = 17795464.00
 
 ENCNTR_ID	REG_DT_TM
  113259881.00	27-FEB-2019 01:59:00.00
  124117850.00	10-MAY-2021 09:55:00.00
 
 
 
;------------------------------------------------------------------------------------------------------
;Critical value report
 
 select * from encntr_alias ea where ea.alias = '2112301580'
 
 
 2112301580
 
select ;into $outdev
e.encntr_id, o.order_id, c.container_id, c.drawn_dt_tm ';;q',TASK_ASSAY = uar_get_code_display(r.task_assay_cd)
,crit = uar_get_code_description(pe.critical_cd), pe.critical_cd, pe.perform_dt_tm ';;q' ,r.result_id;, r.event_id
 
from
	 result r,
	 perform_result pe,
	 orders o,
	 accession_order_r aor,
	 accession a,
	 container c,
	 encounter e,
 	 person p
 
 
plan pe where pe.perform_dt_tm between cnvtdatetime('04-MAY-2021 00:00:00') and cnvtdatetime('04-MAY-2021 08:45:00')
	and pe.critical_cd in (1739.00, 1740.00)
	and pe.result_status_cd = 1738.00	;Verified
 
join r where pe.result_id = r.result_id
 
join c where outerjoin(pe.container_id) = c.container_id
 
join o where r.order_id = o.order_id
 
join e where e.encntr_id = o.encntr_id
	and e.encntr_id =    124263013.00
	;and e.loc_facility_cd = faccd
	and e.active_ind = 1
 
join aor where o.order_id = aor.order_id
 
join a where aor.accession_id = a.accession_id
 
join p where e.person_id = p.person_id
	and p.active_ind = 1
 
order by e.encntr_id, r.result_id
 
;------------------------------------------------------------------------------------------------------
 
 
 
select ce.* from clinical_event ce, prsnl pr
where ce.verified_prsnl_id = pr.person_id
and ce.encntr_id = 124117850 ; trigger_encntrid
;and ce.person_id = trigger_personid
and ce.event_cd = 2570739395.00
and ce.result_status_cd = 25
and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce.encntr_id = ce1.encntr_id group by ce1.encntr_id, ce1.event_cd)
 
 2570739395.00	BH Treatment Review Committee
 
 
select distinct
nurse_unit = trim(uar_get_code_display(nu.location_cd))
,unit_desc = trim(uar_get_code_description(nu.location_cd))
,nurse_unit_cd = nu.location_cd
from nurse_unit nu
where nu.loc_facility_cd = $acute_facility_list
and nu.active_status_cd = 188 ;Active
and nu.active_ind = 1
and nu.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
and nu.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
order nurse_unit
 
 
select distinct
nurse_unit = trim(uar_get_code_display(nu.location_cd))
,unit_desc = trim(uar_get_code_description(nu.location_cd))
,nurse_unit_cd = nu.location_cd, cv1.cdf_meaning
from nurse_unit nu, code_value cv1
where nu.loc_facility_cd = 2552503645.00;$acute_facility_list
and nu.location_cd = cv1.code_value
and cv1.code_set = 220
and cv1.cdf_meaning = 'NURSEUNIT'
and nu.active_status_cd = 188
and nu.active_ind = 1
and nu.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
and nu.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
order nurse_unit
 
 
SELECT into 'nl:'
 
FROM location l
WHERE l.organization_id = CNVTREAL($facility)
AND l.location_type_cd = 783.00
AND l.active_ind = 1
 
DETAIL
	faccd = l.location_cd
 	a->facility = UAR_GET_CODE_DISPLAY(l.location_cd)
WITH nocounter
 
 
select tt = cnvtage(p.birth_dt_tm, cnvtdatetime(pat->plist[d.seq].admitdt),0)
from person p where p.person_id = 15283188.00
 
 
 
SELECT
    facility = UAR_GET_CODE_DISPLAY(l.location_cd),
    l.organization_id
 
FROM location l
WHERE l.location_type_cd = 783.00
AND l.location_cd IN (   21250403.00,
 2552503613.00,
 2552503635.00,
 2552503649.00,
 2552503653.00,
 2552503657.00,
 2552503639.00,
 2552503645.00,
   29797179.00,
 2553765531.00,
 2553765627
 ,2553765707
 ,2553765371,
 2553765579.00,
2553765571
)
AND l.active_ind = 1
 
ORDER BY facility
 
 
select cv1.code_value, cv1.cdf_meaning, cv1.display, cv1.description
from code_value cv1
where cv1.code_set = 220
and cv1.cdf_meaning = 'NURSEUNIT'
and cv1.display = '* EB'
order by cv1.display
 
 
 
 
 
Geetha, can we fire it if they stay in a day surgery pt type but hit a floor?
May just exclude The Periop areas? Just thinking? I worry about ortho pts.
 
 
select distinct e.encntr_id, nu = uar_get_code_display(elh.loc_nurse_unit_cd);, elh.beg_effective_dt_tm ';;q', elh.end_effective_dt_tm ';;q'
from encounter e, encntr_loc_hist elh
where e.encntr_type_cd = 309311.00	;Day Surgery
and elh.encntr_id = e.encntr_id
and e.reg_dt_tm between cnvtdatetime('01-JUN-2021 00:00:00') and cnvtdatetime('01-JUN-2021 23:59:00')
and e.disch_dt_tm is null
 
 
select distinct e.encntr_id, nu = uar_get_code_display(elh.loc_nurse_unit_cd),cv1.cdf_meaning
from encounter e, encntr_loc_hist elh, code_value cv1
where e.encntr_type_cd = 309311.00	;Day Surgery
and elh.encntr_id = e.encntr_id and cv1.code_value = elh.loc_nurse_unit_cd
and e.reg_dt_tm between cnvtdatetime('01-JUN-2021 00:00:00') and cnvtdatetime('01-JUN-2021 23:59:00')
and e.disch_dt_tm is null
and cv1.code_set = 220
and cv1.cdf_meaning = 'NURSEUNIT'
and cv1.display not in(
"FLMC TEMP OR DAY SURG"
,"FLMC TEMP INTR"
,"FLMC TEMP PACU"
,"FLMC TEMP ENDO INTRA"
,"FLMC TEMP ENDO PREP"
,"FLMC GILAB"
,"FLMC ODS"
,"FLMC SUR"
,"FSR TEMP OR DAY SURG"
,"FSR TEMP ENDO CAM"
,"FSR TEMP OR INTRA"
,"FSR TEMP HOLD"
,"FSR TEMP OR PACU"
,"FSR TEMP ENDO PREPO"
,"FSR TEMP INTRA CAM"
,"FSR TEMP ENDO INTRA"
,"FSR GILAB"
,"FSR ODS"
,"FSR OUTPATIENT GI LAB (CAM)"
,"FSR SUR"
,"LCMC TEMP OR DAY SURG"
,"LCMC TEMP INTRA"
,"LCMC TEMP HOLD"
,"LCMC TEMP PACU"
,"LCMC TEMP ENDO"
,"LCMC ODS"
,"LCMC SUR"
,"MHA TEMP OR DAY SUR"
,"MHA TEMP INTRA"
,"MHA ASC"
,"MMC TEMP OR DAY SURG"
,"MMC TEMP OR HOLDING"
,"MMC TEMP OR INTRA"
,"MMC TEMP OR PACU"
,"MMC TEMP ENDO PREPOST"
,"MMC TEMP ENDO INTRA"
,"MMC GILAB"
,"MMC ODS"
,"MMC SUR"
,"MHHS TEMP OR DAY SUR"
,"MHHS TEMP OR INTR"
,"MHHS TEMP OR PACU"
,"MHHS TEMP ENDO INTRA"
,"MHHS GILAB"
,"MHHS ODS"
,"MHHS SUR"
,"PW TEMP BSP INT"
,"PW TEMP BSP PAC"
,"PW TEMP BSP PRE"
,"PW TEMP BSP RCL"
,"PW TEMP OR SDS"
,"PW TEMP INTRA"
,"PW TEMP HOLDING"
,"PW TEMP PACU"
,"PW TEMP END INT"
,"PW TEMP END PRE"
,"PW BSC"
,"PW GILAB"
,"PW ASP"
,"PW SUR"
,"RMC TEMP OR DAY SURG"
,"RMC TEMP OR INTRA"
,"RMC TEMP OR HOLDING"
,"RMC TEMP OR PACU"
,"RMC TEMP ENDO INTRA"
,"RMC GILAB"
,"RMC ODS"
,"RMC SUR")
 
 
 
select cv1.code_value, cv1.display, cv1.cdf_meaning
from code_value cv1
where cv1.code_set = 220
;and cv1.cdf_meaning = 'NURSEUNIT'
and cv1.display in(
"FLMC TEMP OR DAY SURG"
,"FLMC TEMP INTR"
,"FLMC TEMP PACU"
,"FLMC TEMP ENDO INTRA"
,"FLMC TEMP ENDO PREP"
,"FLMC GILAB"
,"FLMC ODS"
,"FLMC SUR"
,"FSR TEMP OR DAY SURG"
,"FSR TEMP ENDO CAM"
,"FSR TEMP OR INTRA"
,"FSR TEMP HOLD"
,"FSR TEMP OR PACU"
,"FSR TEMP ENDO PREPO"
,"FSR TEMP INTRA CAM"
,"FSR TEMP ENDO INTRA"
,"FSR GILAB"
,"FSR ODS"
,"FSR OUTPATIENT GI LAB (CAM)"
,"FSR SUR"
,"LCMC TEMP OR DAY SURG"
,"LCMC TEMP INTRA"
,"LCMC TEMP HOLD"
,"LCMC TEMP PACU"
,"LCMC TEMP ENDO"
,"LCMC ODS"
,"LCMC SUR"
,"MHA TEMP OR DAY SUR"
,"MHA TEMP INTRA"
,"MHA ASC"
,"MMC TEMP OR DAY SURG"
,"MMC TEMP OR HOLDING"
,"MMC TEMP OR INTRA"
,"MMC TEMP OR PACU"
,"MMC TEMP ENDO PREPOST"
,"MMC TEMP ENDO INTRA"
,"MMC GILAB"
,"MMC ODS"
,"MMC SUR"
,"MHHS TEMP OR DAY SUR"
,"MHHS TEMP OR INTR"
,"MHHS TEMP OR PACU"
,"MHHS TEMP ENDO INTRA"
,"MHHS GILAB"
,"MHHS ODS"
,"MHHS SUR"
,"PW TEMP BSP INT"
,"PW TEMP BSP PAC"
,"PW TEMP BSP PRE"
,"PW TEMP BSP RCL"
,"PW TEMP OR SDS"
,"PW TEMP INTRA"
,"PW TEMP HOLDING"
,"PW TEMP PACU"
,"PW TEMP END INT"
,"PW TEMP END PRE"
,"PW BSC"
,"PW GILAB"
,"PW ASP"
,"PW SUR"
,"RMC TEMP OR DAY SURG"
,"RMC TEMP OR INTRA"
,"RMC TEMP OR HOLDING"
,"RMC TEMP OR PACU"
,"RMC TEMP ENDO INTRA"
,"RMC GILAB"
,"RMC ODS"
,"RMC SUR")
 
 
;-------------------------------------------------------------------------------------------------------------------
;MRSA tasking
 
select * from encntr_alias ea where ea.alias = '2115200374' ;'2113900320'
2115200374
 
 
select * from  task_activity ta where ta.task_id = 3445845833

;Successfully added Perform Chlorhexidine Treatment. Task ID - 3445845833.0. (0.04s)
 
select * from task_activity ta where ta.encntr_id =    125221801.00
 
 
select * from order_task ot where ot.reference_task_id =     3851969985.00
 
select * from clinical_event ce where ce.event_id = 3530630117
 
;Patient Location and Type History
select elh.encntr_id, elh.loc_nurse_unit_cd, elh.encntr_type_cd;, nu_des = uar_get_code_description(elh.loc_nurse_unit_cd)
, elh.beg_effective_dt_tm, elh.end_effective_dt_tm, elh.loc_bed_cd, elh.loc_room_cd, elh.active_ind, elh.*
from encntr_loc_hist elh where elh.encntr_id = 125273789.00
and elh.active_ind = 1
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
 
 
select
ta.encntr_id, ta.task_create_dt_tm ';;q',task_status = uar_get_code_display(ta.task_status_cd)
,tasK_reason = uar_get_code_display(ta.task_status_reason_cd), task_loc = uar_get_code_display(ta.location_cd)
,ta.task_id, ta.reference_task_id, datepart = datetimetrunc(ta.task_create_dt_tm, "dd")
;, ot.task_description

 
from  task_activity ta;	, order_task ot
 
plan ta where ta.encntr_id =   125502321.00
	and ta.active_ind = 1
 
join ot where ot.reference_task_id = ta.reference_task_id
	and ot.task_description = "Perform Chlorhexidine Treatment"
	and ot.active_ind = 1
 
order by ta.encntr_id, ta.task_id 


       3787.00	Task Charted as Not Done

 
;7PM Task 
select into "nl:"
from
	task_activity ta, order_task ot
plan  ta
	where ta.encntr_id = @ENCOUNTERID:2
	and (ta.task_status_cd = value(uar_get_code_by("DISPLAY", 79, "Overdue"))
		or ta.task_status_reason_cd = value(uar_get_code_by("DISPLAY", 14024, "Task Charted as Not Done"))
		)	
	and ta.active_ind = 1
join ot
	where ot.reference_task_id = ta.reference_task_id
	and ot.task_description = "Perform Chlorhexidine Treatment"
	and DATETIMECMP(cnvtdatetime(curdate, curtime), ta.task_create_dt_tm) = 0
	and ot.active_ind = 1
head report
	log_message = "No Overdue task Found Today"
	log_retval = 0
detail
	log_message = "Overdue Task Found Today"
	log_retval = 100
with nocounter, nullreport go
 
 
 
 
 
 
 
 
 
;Duplicate Task?
select; into "nl:"
ta.encntr_id, ta.task_create_dt_tm ';;q', ot.task_description,task_status = uar_get_code_display(ta.task_status_cd)
, task_loc = uar_get_code_display(ta.location_cd),ta.task_id, ta.reference_task_id
from
	task_activity ta, order_task ot
plan  ta
	where ta.encntr_id = 124697625;  @ENCOUNTERID:2
	and ta.active_ind = 1
	/*and ta.task_status_cd in(value(uar_get_code_by("DISPLAY", 79, "Complete")),
					 value(uar_get_code_by("DISPLAY", 79, "InProcess")),
					 value(uar_get_code_by("DISPLAY", 79, "Opened")),
					 value(uar_get_code_by("DISPLAY", 79, "Overdue")),
					 value(uar_get_code_by("DISPLAY", 79, "Pending")))*/
join ot
	where ot.reference_task_id = ta.reference_task_id
	and ot.task_description = "Perform Chlorhexidine Treatment"
	;and DATETIMECMP(cnvtdatetime(curdate, curtime), ta.task_create_dt_tm)  = 0
	and ot.active_ind = 1
 
head report
	log_message = "No Existing Task"
	log_retval = 0
detail
	log_message = "Existing Task Found"
	log_retval = 100
with nocounter, nullreport go
 
 
 
;Patient Location History
select nu = uar_get_code_display(elh.loc_nurse_unit_cd), nu_des = uar_get_code_description(elh.loc_nurse_unit_cd)
,bed = uar_get_code_display(elh.loc_bed_cd), room = uar_get_code_display(elh.loc_room_cd), elh.active_ind
,BEG = elh.beg_effective_dt_tm  "@SHORTDATETIME", ed = elh.end_effective_dt_tm  "@SHORTDATETIME" , elh.*
from encntr_loc_hist elh where elh.encntr_id = 125221801.00
and elh.active_ind = 1
 
;Patient Type history
select pt.n_loc_facility_cd, pt.n_loc_nurse_unit_cd, pt.n_fin_nbr, pt.n_encntr_id
, pt.n_encntr_type_cd, pt.activity_dt_tm, pt.n_encntr_status_cd 
from pm_transaction pt where pt.n_fin_nbr = '2120300502' 
order by pt.activity_dt_tm
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")
 
 
 
select * from orders o where o.encntr_id = 124702208  ;124724776
 
select o.order_mnemonic, o.orig_order_dt_tm ';;q' , o.order_detail_display_line, o.updt_dt_tm ';;q', o.template_order_flag, o.template_order_id
from orders o where o.encntr_id =   124578864.00  and o.catalog_cd = 2780685.00
order by o.updt_dt_tm
 
;------------------------------------------------------------------------------------------
 
;CHG tasking after go live
 
select distinct
 
e.encntr_id, e.reg_dt_tm ';;q', e.disch_dt_tm ';;q'
 
from encounter e, encntr_loc_hist elh
 
plan e where e.loc_facility_cd = 2552503645.00
	and e.active_ind = 1
	and e.encntr_type_cd in(309308.00, 309312.00,19962820.00);Inpatient,Observation,Outpatient in a Bed
	and e.reg_dt_tm <= cnvtdatetime('01-JUN-2021 11:00:00')
	and e.disch_dt_tm is null
 
join elh where elh.encntr_id = e.encntr_id
	and elh.active_ind = 1
 
 
order by e.encntr_id;, elh.beg_effective_dt_tm
 
;--------------------------------------------------------------------------------------------
;Amanda sent via ticket
select
	 ea.alias
	,p.name_full_formatted
	,o.order_mnemonic
	,o.order_status_cd
	,e.arrive_dt_tm
	,e.reg_dt_tm
	,e.disch_dt_tm
	,datetimediff(cnvtdatetime(curdate,curtime3),e.reg_dt_tm,3)
from
	 encounter e
	,orders o
	,person p
	,encntr_alias ea
plan o
	where o.catalog_cd = 3816796437
	and   o.order_status_cd = 2550.00
join e
	where e.encntr_id = o.encntr_id
	and   e.encntr_status_cd !=         856.00;discharged
join p
	where p.person_id = e.person_id
join ea
	where ea.encntr_id = e.encntr_id
	and   ea.active_ind = 1
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
with format(date,";;q"),uar_code(d,1)
 
;--------------------------------------------------------------------------------------------
 
 select * from code_value cv1
 where cv1.code_set = 220
 and cv1.active_ind = 1
 and cv1.code_value in(21250403, 2552503649, 2552503653, 2552503613, 2552503645, 2552503657, 2553765291, 2552503639, 2552503635)
 
 
select * from code_value cv1
 where cv1.code_set = 71
 and cv1.active_ind = 1
 and cv1.code_value in(22282402, 2555137075, 2555137115, 309311, 2555137123, 309309, 19962820)
 ;Outpatient,Day Surgery,Outpatient in a Bed,Clinic,Cardiac Diagnostics,Cheyenne Outpatient Clinic,Diagnostic Center Outpatient
 
;and cv1.code_value in(309308, 2555267433, 2555137267, 2555137309)
 
 
 
 
select distinct
    nurse_unit = uar_get_code_display(nu.location_cd)
    ,desc = uar_get_code_description(nu.location_cd)
   ,nurse_unit_cd = nu.location_cd
 
from nurse_unit nu
 
where nu.loc_facility_cd = 2552503645.00 ;PW ;$facility_list
and nu.active_status_cd = 188 ;Active
           and nu.active_ind = 1
           and nu.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           and nu.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
order nurse_unit
 
 
 
select ce.encntr_id, ce.event_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm ';;q'
from clinical_event ce
plan ce where ce.encntr_id = 124463318
	and ce.event_cd =    24604416.00
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
	and cnvtlower(ce.result_val) != "straight/intermittent"
	and cnvtlower(ce.result_val) in('present on admission','present on admission.','uc present on admission','insert',
		'inserted','inserted in surgery/procedure','uc inserted in surgery/procedure','cl access port') 
	and not exists (select ce1.encntr_id from clinical_event ce1
				where(ce1.encntr_id = ce.encntr_id 
				and ce1.event_cd = ce.event_cd
				and cnvtlower(ce1.result_val) = "discontinued"))

 124463318
 
 
 
 select o.template_order_id, o.order_id, o.order_mnemonic,o.ordered_as_mnemonic, o.clinical_display_line,o.dept_misc_line 
 from orders o where o.order_id = 4438667703.00
 
 o.encntr_id =   124852673.00
 and o.catalog_cd = 3816796437.00
 
 select o.encntr_id, o.catalog_cd,o.template_order_id,o.order_status_cd,o.orig_order_dt_tm, o.* from orders o where O.order_id =     4438667703.00
 with format(date,"dd-mmm-yyyy"),uar_code(d)
 
 
 select ocs.order_sentence_id, ocs.* from order_catalog_synonym ocs where ocs.catalog_cd =  3816796437.00
 
 select os.order_sentence_display_line,os.* from order_sentence os where os.parent_entity_id in(3816796449.00, 3816796447.00)
 
 select * from order_sentence_detail osd where osd.order_sentence_id in( 3816796449.00, 3816796447.00)

 
 select * from order_detail o where O.order_id =  4439627771
 
 
select * from code_value cv1 where cv1.code_value in(2553777719.00, 3816796437.00)
 
 
select distinct ;into $outdev
ocs.catalog_cd,ocs.mnemonic,oef.oe_format_name,ocs.order_sentence_id,os.order_sentence_id,os.order_sentence_display_line,
os.parent_entity_name,os.parent_entity_id

from order_entry_format oef,order_sentence os,order_catalog_synonym ocs

where  oef.oe_format_id > 0
;and ocs.catalog_cd = 3816796437.00 
AND OS.parent_entity_id = ocs.synonym_id
and os.parent_entity_name = "ORDER_CATALOG_SYNONYM"
and oef.oe_format_id = os.oe_format_id
and os.parent_entity2_id = 0
and ocs.active_ind = 1
order by ocs.catalog_cd
with nocounter, separator=" ", format, maxrow = 1000 
 
 
 
select o.encntr_id, o.orig_order_dt_tm ';;q', o.ordered_as_mnemonic, o.order_id, o.catalog_cd, o.order_status_cd
from orders o ;where o.order_id = 4433980329
where o.encntr_id = 124858275
	;and o.order_status_cd = 2550.00 ;Ordered
	and o.order_id = (select distinct o2.template_order_id from orders o2
			where o2.encntr_id = 124852673.00 ; o.encntr_id
			and o2.catalog_cd in(2553777719.00, 3816796437.00)
			and o2.active_ind = 1)
with format(date,"dd-mmm-yyyy"),uar_code(d)
 
 
select * from order_detail od where od.order_id in(4439375969.00, 4439375993.00)

4433980329.00, 4441952963.00, 4441952975.00, 4409818541.00) order by od.order_id
 
 
 
 2553777719.00 Clostridium difficile GDH/Toxin+
 3816796437.00 C.Diff Day 1-3 Screening

 
SELECT cv1.code_value, cv1.display,cv1.description
FROM CODE_VALUE CV1
WHERE CV1.CODE_SET =  200 AND CV1.ACTIVE_IND = 1 
and cnvtlower(cv1.display) in('clostridium difficile gdh/toxin+','c.diff day 1-3 screening');'*lactate*'
WITH  FORMAT, TIME = 60


SELECT cv1.code_value, cv1.display,cv1.description
FROM CODE_VALUE CV1
WHERE CV1.CODE_SET = 72 AND CV1.ACTIVE_IND = 1 
and cnvtlower(cv1.display) = '*sars-cov-2 (covid-19)*'; mRNA-1273 vaccine
WITH  FORMAT, TIME = 60

Covid Vaccination Last Action + Administered 


select ce.encntr_id, ce.person_id, ce.event_cd, ce.result_val 
from clinical_event ce
where ce.event_cd =  3652349339.00
with format(date,"dd-mmm-yyyy"),uar_code(d),time = 60, maxrow = 1000



select * from order_detail od where od.order_id =   4487344637
and od.oe_field_display_value = 'DNR*'


select d.encntr_id,d.diagnosis_display, typ = uar_get_code_display(d.diag_type_cd),rank = uar_get_code_display(d.ranking_cd), n.*
from diagnosis d, nomenclature n 
where n.nomenclature_id = d.nomenclature_id
and d.encntr_id =   124595885.00;   15222379.00


;-------------------------------------------------------------------------
;Q2 Turn

select distinct fin = ea.alias, ce.event_cd, ce.result_val, ce.event_end_dt_tm
;, ce.valid_until_dt_tm, ce.result_status_cd, ce.event_title_text, ce.event_tag
from clinical_event ce, encntr_alias ea
where ce.encntr_id = ea.encntr_id
and ea.encntr_alias_type_cd = 1077
and ea.active_ind = 1
and ce.event_cd =  2565739663.00 ;N-Utilize Sitter Services
;32015945.00 ;Patient Positioning
and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
and ce.event_end_dt_tm between cnvtdatetimE("01-JUN-2020 00:00:00") AND cnvtdatetimE("15-JUN-2021 23:59:00")
order by FIN, ce.event_end_dt_tm
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180

;and ce.encntr_id =  124954658.00
and ea.alias = '2117101293'
order by event_end_dt asc
;'------------------------------------------------------------------------------



select hr = cnvtlookahead("24, H", cnvtdatetime(curdate, curtime)) ';;q'
;diff = datetimediff(cnvtdatetime(curdate, curtime), cnvtdatetimE("06-JUL-2021 12:00:00"),3) 
From dummyt d
where datetimediff(cnvtdatetime(curdate, curtime), cnvtdatetimE("06-JUL-2021 12:00:00"), 3) <= 24.00


select o.encntr_id, o.catalog_cd, orderable = uar_get_code_display(o.catalog_cd), o.orig_order_dt_tm
, diff = datetimediff(cnvtdatetime(curdate, curtime), cnvtdatetimE("05-JUL-2021 16:00:00"))
from 	orders o
where o.encntr_id =   125174282.00
	and o.catalog_cd in(2552493947.00, 271709609.00)
	and o.active_ind = 1
	and (datetimediff(cnvtdatetime(curdate, curtime), cnvtdatetimE("05-JUL-2021 16:00:00")) <= 1)


 2552493947.00	Severe Sepsis IP Alert
  271709609.00	Sepsis Advisor

;---------------------------------------------------------------------------------------
select distinct
    nurse_unit = uar_get_code_display(nu.location_cd)
    ,desc = uar_get_code_description(nu.location_cd)
   ,nurse_unit_cd = nu.location_cd
  
from nurse_unit nu
 
where nu.loc_facility_cd = 2552503645
and nu.active_status_cd = 188 ;Active
           and nu.active_ind = 1
         	



select distinct
nurse_unit = trim(uar_get_code_display(nu.location_cd))
,unit_desc = trim(uar_get_code_description(nu.location_cd))
,nurse_unit_cd = nu.location_cd
from nurse_unit nu, code_value cv1
where nu.loc_facility_cd = $acute_facility_list
and nu.location_cd = cv1.code_value
and cv1.code_set = 220
and cv1.cdf_meaning = 'NURSEUNIT'
and nu.active_status_cd = 188 
and nu.active_ind = 1
and nu.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
and nu.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
order nurse_unit


select distinct
    nurse_unit = uar_get_code_display(nu.location_cd)
    ,desc = uar_get_code_description(nu.location_cd)
   ,nurse_unit_cd = nu.location_cd
  
from nurse_unit nu
 
where nu.loc_facility_cd = 2552503645 ;$facility_list 
and nu.active_status_cd = 188 ;Active
           and nu.active_ind = 1
           and nu.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
           and nu.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
order nurse_unit


--------------------------------------------------------------------------------------------------------

select
 
fac = trim(uar_get_code_display(e.loc_facility_cd))
,e.encntr_id, nunit = uar_get_code_display(elh.loc_nurse_unit_cd)
 ,beg_dt = elh.beg_effective_dt_tm ';;q', end_dt = elh.end_effective_dt_tm ';;q'

from   encounter e
	, encntr_loc_hist elh
	;, (dummyt d with seq = value(size(unit->list, 5)))
	
plan e where e.loc_facility_cd = 2552503645;$acute_facility_list
	and e.active_ind = 1
	and e.encntr_type_cd in(309308.00, 309312.00,19962820.00);Inpatient,Observation,Outpatient in a Bed
	and e.disch_dt_tm is null
 
join elh where elh.encntr_id = e.encntr_id
	and elh.beg_effective_dt_tm between cnvtdatetime("12-JUL-2021 00:00:00") and cnvtdatetime("12-JUL-2021 23:59:00")
	and elh.active_ind = 1
	and elh.loc_nurse_unit_cd =  2552510409.00




select trunc_date = format(datetimetrunc(cnvtdatetime("02-Apr-2008 10:55:29"), "hh"), 'hh ;;q')
from dummyt


;CVL and Foley
select ce.encntr_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm ';;q'
	,cvl_days_rs = cnvtstring(DATETIMECMP(cnvtdatetime(curdate, curtime), ce.event_end_dt_tm) ) , ce.ce_dynamic_label_id
from clinical_event ce where ce.encntr_id = 124900179.00  ;  125172412.00
		and ce.event_cd  = 24604416.00;   34439957.00 ;in(urinary_cath_var, central_line_var)
		and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
		and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
		and cnvtlower(ce.result_val) != "straight/intermittent"
		and cnvtlower(ce.result_val) in('present on admission','present on admission.','uc present on admission','insert',
			'inserted','inserted in surgery/procedure', 'inserted in surgery/procedure.', 'sn - cath - inserted',
			'uc inserted in surgery/procedure','cl access port', 'assessment') 
	and not exists (select ce2.encntr_id from clinical_event ce2
				where(ce2.encntr_id = ce.encntr_id
				and ce2.event_cd = ce.event_cd
				and ce2.ce_dynamic_label_id = ce.ce_dynamic_label_id
				and cnvtlower(ce2.result_val) = "discontinued"))

order by ce.encntr_id, ce.event_cd, ce.ce_dynamic_label_id, ce.event_end_dt_tm		
		
		
		/*and ce.event_id = (select min(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
					and ce1.event_cd = ce.event_cd
					and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
					and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
					and cnvtlower(ce.result_val) != "straight/intermittent"
					and cnvtlower(ce.result_val) in('present on admission','present on admission.','uc present on admission','insert',
						'inserted','inserted in surgery/procedure', 'inserted in surgery/procedure.', 'sn - cath - inserted',
						'uc inserted in surgery/procedure','cl access port', 'assessment') 
					group by ce1.encntr_id, ce1.event_cd, ce1.ce_dynamic_label_id)*/



;CDiff
select o.encntr_id, o.orig_order_dt_tm, o.ordered_as_mnemonic, o.order_id, o.catalog_cd, o.order_status_cd
from orders o
 where o.encntr_id =   125181457.00 ;pat->plist[d.seq].encntrid
	;and o.order_status_cd = 2550.00 ;Ordered
	and o.order_id = (select distinct o2.template_order_id from orders o2
			where o2.encntr_id = o.encntr_id
			and o2.catalog_cd in(2553777719, 3816796437);(cdiff_toxin_var, cdiff_var)
			and o2.active_ind = 1)

select * from order_action oa where oa.order_id =  4525999637.00


 2553777719.00	Clostridium difficile GDH/Toxin+
 3816796437.00	C.Diff Day 1-3 Screening


;Foley and CVL
select ce.encntr_id, ce.event_id, event = uar_get_code_display(ce.event_cd), ce.result_val, ce.event_end_dt_tm ';;q'
from clinical_event ce
where ce.encntr_id = 124303211;pat->plist[d.seq].encntrid
	and ce.ce_dynamic_label_id = 11304594755 ;pat->plist[d.seq].cvl_dyn_labelid
	and ce.event_cd in(24604402.00)
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1 where ce1.encntr_id = ce.encntr_id
					and ce1.event_cd = ce.event_cd
					and ce1.ce_dynamic_label_id = ce.ce_dynamic_label_id
					and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
					and ce1.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
					group by ce1.encntr_id, ce1.event_cd, ce1.ce_dynamic_label_id)
 
order by ce.encntr_id, ce.event_cd


select * from med_admin_event cmr where cmr.event_id =   3669893183.00

select * from ce_med_result cmr where cmr.event_id in(3669893179.00, 3669893183.00)

 


select * from orders o where o.encntr_id =   123399111.00

select * from encntr_alias ea where ea.encntr_id =   125154807.00

;TOC OPS
;-----------------------------------------------------------------------------------------------------
;Vaccine

select distinct
ce.encntr_id,
immunization_disp = uar_get_code_display(ce.event_cd),

date_added = format(ce.event_start_dt_tm, "MM/DD/YYYY HH:MM;;d"),

admin_date = format(cemr.valid_from_dt_tm, "MM/DD/YYYY HH:MM;;d"),

result_status = uar_get_code_display(ce.result_status_cd),

dose_number = ce.clinical_seq,

dose = cemr.admin_dosage,

dose_unit = uar_get_code_display(cemr.dosage_unit_cd),

route = uar_get_code_display(cemr.admin_route_cd),

site = uar_get_code_display(cemr.admin_site_cd),

manufacturer = uar_get_code_display(cemr.substance_manufacturer_cd),

lot_number = cemr.substance_lot_number,

exp_date = format(cemr.substance_exp_dt_tm, "MM/DD/YYYY HH:MM;;d"),

history_source = uar_get_code_display(ce.source_cd)

from encounter e,

clinical_event ce,

ce_med_result cemr,

v500_event_set_code esc,

v500_event_set_explode ese,

v500_event_code ec

plan esc

where esc.event_set_name like "Immunizations"

join ese

where ese.event_set_cd = esc.event_set_cd

join ec

where ec.event_cd = ese.event_cd

join ce

where ce.event_cd = ec.event_cd

;and ce.person_id = 758652

and ce.event_tag != "Date\Time Correction"

and ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3)

and ce.result_status_cd in (25, 34)

join cemr

where cemr.event_id = outerjoin(ce.event_id)

join e where e.encntr_id = ce.encntr_id
	and e.loc_facility_cd = 21250403
	and e.reg_dt_tm between cnvtdatetime("01-JUL-2021 00:00:00") and cnvtdatetime("16-JUL-2021 23:59:00")

with nocounter, separator=" ", format, time = 180

;MRSA

select
elh.encntr_id, nunit = uar_get_code_description(elh.loc_nurse_unit_cd)
 ,beg_dt = elh.beg_effective_dt_tm ';;q', end_dt = elh.end_effective_dt_tm ';;q'
 
from   encntr_loc_hist elh
 
plan elh where elh.encntr_id = 124614247.00 ;elh.loc_nurse_unit_cd = unit->list[d.seq].nu_cd
	and elh.end_effective_dt_tm between cnvtdatetime("18-JUN-2021 00:00:00") and cnvtdatetime("18-JUN-2021 23:59:00") 
	
	
	
	and( elh.beg_effective_dt_tm <= cnvtdatetime("18-JUN-2021 00:00:00") 
		and elh.end_effective_dt_tm >= cnvtdatetime("18-JUN-2021 23:59:00")


select
elh.encntr_id, nunit = uar_get_code_description(elh.loc_nurse_unit_cd)
 ,beg_dt = elh.beg_effective_dt_tm ';;q', end_dt = elh.end_effective_dt_tm ';;q', elh.*
 
from   encntr_loc_hist elh
 
plan elh where elh.encntr_id = 124614247.00 ;elh.loc_nurse_unit_cd = unit->list[d.seq].nu_cd
	and elh.beg_effective_dt_tm between cnvtdatetime("18-JUN-2021 00:00:00") and cnvtdatetime("18-JUN-2021 00:00:00") 
	and elh.end_effective_dt_tm between cnvtdatetime("18-JUN-2021 00:00:00") and cnvtdatetime("18-JUN-2021 00:00:00") 

	and elh.beg_effective_dt_tm <= cnvtdate("15-JUN-2021") 
	and elh.end_effective_dt_tm >= cnvtdate("15-JUN-2021")





	OR elh.beg_effective_dt_tm between cnvtdatetime("21-JUN-2021 00:00:00") and cnvtdatetime("21-JUL-2021 23:59:00") 
		 
	and elh.end_effective_dt_tm <= cnvtdatetime("21-JUN-2021 23:59:00")
		;OR elh.end_effective_dt_tm between cnvtdatetime("21-JUN-2021 00:00:00") and cnvtdatetime("21-JUL-2021 23:59:00")
	and elh.active_ind = 1
 
join e where e.encntr_id = elh.encntr_id;e.loc_facility_cd = $acute_facility_list
	;and e.encntr_id = elh.encntr_id
	and e.active_ind = 1
	and e.encntr_type_cd in(309308.00, 309312.00,19962820.00);Inpatient,Observation,Outpatient in a Bed
;-------------------------------------------------------------------------------


select ;md = max(e.disch_dt_tm) ';;q' 
e.encntr_id, e.reg_dt_tm ';;q', e.disch_dt_tm ';;q'
from encounter e 
where e.reg_dt_tm between cnvtdatetimE("01-JUN-2021 00:00:00") AND cnvtdatetimE("02-JUN-2021 23:59:00")
	and e.encntr_type_cd in(309308.00, 309312.00,19962820.00);Inpatient,Observation,Outpatient in a Bed
	and e.active_ind = 1
	and e.disch_dt_tm != null
	and e.encntr_status_cd = 856.00 ;Discharged
order by e.disch_dt_tm	
	
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180




select * from dcp_forms_ref dfr where cnvtlower(description) = '*qm reason vte*'


SELECT 
	CV1.CODE_VALUE
	,CV1.DISPLAY
	,CV1.CDF_MEANING
	,CV1.DESCRIPTION
	,CV1.DISPLAY_KEY
	,CV1.CKI
	,CV1.DEFINITION
 FROM CODE_VALUE CV1 

WHERE CV1.CODE_SET =  72 AND CV1.ACTIVE_IND = 1 
and cnvtlower(CV1.DISPLAY) = '*qm reason vte*'
WITH  FORMAT, TIME = 60


select * from orders o where o.encntr_id =   125348732.00


select o.catalog_cd, o.order_mnemonic, o.orig_order_dt_tm from orders o where o.encntr_id = 125359334.00

select * from person p where p.name_first = 'FLUTESTANDQMORDER' ;'DEVGRP'

select * from encounter e where e.person_id =    20751877.00 ;enc =   125348735.00   ;20755830.00 ; enc =   125359334.00

select name = p.name_full_formatted, fin = ea.alias from encntr_alias ea, person p, encounter e
where ea.encntr_id = e.encntr_id
and p.person_id = e.person_id
and ea.encntr_alias_type_cd = 1077
and e.encntr_id in(125193851)


SELECT DISTINCT
	 e.encntr_id
	,diet_val = SUBSTRING(1,4,od.oe_field_display_value)
	,diet_oid = o.order_id
FROM
	 encounter e
	,(INNER JOIN orders o ON o.encntr_id = e.encntr_id
		AND o.order_status_cd = 2550
		AND o.catalog_cd != 2553008715
	 )
	,(INNER JOIN order_detail od ON od.order_id = o.order_id
		AND od.oe_field_meaning = "DIETARYFLUIDPERMITTED"
		/*AND od.oe_field_id = 45463199*/
		AND od.action_sequence = o.last_action_sequence
	 )
	,(INNER JOIN order_entry_fields oef2 ON oef2.oe_field_id = od.oe_field_id)
WHERE
	e.encntr_id = trigger_encntrid
ORDER BY
	 e.encntr_id
	,diet_val
	,diet_oid
head report
	log_misc1  = "0"
DETAIL
	log_misc1 = BUILD(diet_val," mL")

	IF(log_misc1 = " mL") log_misc1 = "0" ENDIF
WITH nocounter, nullreport
GO
