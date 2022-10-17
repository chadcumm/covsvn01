drop program cov_gstest1_Mock go
create program cov_gstest1_Mock
 
prompt
	"Output to File/Printer/MINe" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
;****************************************************************************
;This file mainly contains some of CCL AdHoc's
;****************************************************************************
 
;---------------------------------------------------------------------------------------------------------------------
 
select fin = ea.alias, ce.encntr_id, ce.event_cd
, event = uar_get_code_display(ce.event_cd), ce.result_val, event_end_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
,verify_dt = format(ce.verified_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d'), ce.result_status_cd
, ce.event_title_text, ce.event_tag 
, perform_dt = format(ce.performed_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, performed_by = pr.name_full_formatted, verified_by = pr1.name_full_formatted
, ce.event_id, ce.parent_event_id, ce.result_status_cd, ce.order_id
, e.person_id, fac = uar_get_code_display(e.loc_facility_cd), e.loc_facility_cd
, event_start_dt  = format(ce.event_start_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, ce.view_level, ce.publish_flag,normalcy = uar_get_code_display(ce.normalcy_cd), ce.ce_dynamic_label_id, ce.valid_until_dt_tm
, ce.* 
from clinical_event ce, encntr_alias ea, prsnl pr, prsnl pr1, encounter e
 
where ce.encntr_id = ea.encntr_id
and e.encntr_id = ce.encntr_id
and ea.encntr_alias_type_cd = 1077
and ea.active_ind = 1
and ce.performed_prsnl_id = pr.person_id
and ce.verified_prsnl_id = pr1.person_id
and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
;and ce.encntr_id = 130143712                
;and ce.person_id =    18862688.00
and ea.alias = '2125900109'
;and ce.event_id = 3686938696.00
;and ce.ce_dynamic_label_id =      11367714587.00
order by ce.verified_dt_tm desc
 
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
 
 
select ce.event_cd, ce.result_val, ce.event_end_dt_tm,ce.verified_prsnl_id, ce.*
 from clinical_event ce where ce.encntr_id = 129183724                
 order by ce.event_end_dt_tm desc
 with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180
 
;--------------------------------------------------------------------------------------
;Test Physcians in Mock
 
select PR.name_full_formatted, PR.username from prsnl pr where cnvtupper(pr.username) = 'PHYS*' ;'PHYSHOSP' ;    4122622.00

Cerner Test, Physician - Orthopaedic Surgery Cerner	PHYSORTHO
Cerner Test, Physician - Hospitalist Cerner		PHYSHOSP
Cerner Test, Physician - Neurology Cerner			PHYSNEURO
Cerner Test, Physician - Intensivist Cerner		PHYSINTENS
Cerner Test, Physician - Cardiovascular Cerner		PHYSCARDIO
Cerner Test, Physician - Women's Health Cerner		PHYSOBGYN
Cerner Test, Physician - Primary Care Cerner		PHYSPCP

In Powerchart.exe - IT.NBABAN , Cerner 
;--------------------------------------------------------------------------------------
;Get active Inpatients
select E.encntr_id, e.reg_dt_tm, e.disch_dt_tm, ea.alias, p.name_full_formatted, e.encntr_type_cd
, et = uar_get_code_display(e.encntr_type_cd)
from encounter e, encntr_alias ea, person p
where e.reg_dt_tm > cnvtdatetime('10-FEB-2022 00:00:00')
and e.encntr_type_cd = 309308.00 ;Inpatient
and e.encntr_id = ea.encntr_id
and ea.encntr_alias_type_cd = 1077
and p.person_id = e.person_id
AND E.disch_dt_tm is null
 
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
;Social History
 
select * from shx_activity sa where sa.person_id =    20759885.00
 
 
 
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
 


select PR.name_full_formatted, pr.username, pos = uar_get_code_display(pr.position_cd), pr.*
from prsnl pr 
where pr.position_cd

; 'Nurse - Supervisor' or position_var = 'IT - PowerChart'
 
 
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
 
select tt = format(CNVTLOOKBEHIND("72,H"),'mm/dd/yy hh:mm:ss;;d') from dummyt
 
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
 
 
;Get powerform name
select * from dcp_forms_ref dfr
where dfr.description = 'QM Reason VTE Prphylaxis Not Given 2020 - Custom'
 
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
 
 
select * from  task_activity ta where ta.task_id = 125359334
 
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
 
****************************************************************************************************************
;Stroke Rule
 
select into "nl:"
from
	clinical_event ce
plan ce
	where ce.encntr_id = @ENCOUNTERID:2
	and ce.event_cd =  value(uar_get_code_by("DISPLAY",72,"Discharge Summary"))
	and ce.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
	and ce.event_tag != "Date\Time Correction"
	and datetimecmp(cnvtdatetime(curdate, curtime), ce.verified_dt_tm)  = 0
	and ce.result_status_cd = value(uar_get_code_by("MEANING",8,"AUTH"))
 	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
 			where ce1.encntr_id = ce.encntr_id
	 		and ce1.event_cd = ce.event_cd
			group by ce1.encntr_id,ce1.event_cd)
head report
	log_message = "Discharge Summary Not Found"
	log_retval = 0
detail
	log_message = concat("Discharge Summary Found - ",format(ce.event_end_dt_tm,";;q"))
	log_retval = 100
with nocounter, nullreport go
 
;----------------------------------------------------------------------------------------------------------------
select * from orders o where o.encntr_id =  125379942
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120
 
select * from pat_ed_doc_activity pa where pa.pat_ed_doc_id = 201697445
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120
 
 
select * from cr_report_request cr where cr.encntr_id = 125379942
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120
 
select * from cr_printed_sections cre where cre.report_request_id = 201697455.00
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120
 
select * from cr_report_section rp where rp.section_id =  2967573503.00
 
    2967573503.00
    2985400871.00
    3327088817.00
 
 
select * from clinical_event ce where ce.event_id =   3653561309.00
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120
 
;----------------------------------------------------------------------------------------------
select crr.encntr_id, crr.report_request_id, crr.request_dt_tm, crr.request_prsnl_id
, cps.section_id, crs.section_name, cps.updt_dt_tm
 
from cr_report_request crr
	,cr_printed_sections cps
	,cr_report_section crs
 
plan crr where crr.encntr_id = 125379942
	and crr.report_status_cd = 4055346.00 ;Report Distributed
 
join cps where cps.report_request_id = crr.report_request_id
	/*and cps.updt_dt_tm = (select max(cps1.updt_dt_tm) from cr_printed_sections cps1
			where cps1.report_request_id = cps.report_request_id
			group by)*/
 
join crs where crs.section_id = cps.section_id
	and crs.active_ind = 1
	and crs.end_effective_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00")
	and crs.section_name = 'SINGLE DOC - Discharge Documentation'
 
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120
 
;----------------------------------------------------------------------------------------------
 
 
 ALIAS	ENCNTR_ID	PERSON_ID
2126300148	  125379942.00	   20757908.00
 
 
report_request_id  parent_request_id
      201697455.00          201697455.00
 
 
 
 
 select e.encntr_id, e.person_id, e.disch_dt_tm, e.disch_disposition_cd
, pe.signed_dt_tm, pe.pat_ed_domain_cd, pe.event_id, pe.status_cd
, pa.instruction_name, pa.print_ind, pa.pat_ed_domain_cd, pa.pat_ed_doc_id
, pr.name_full_formatted, ce.*
 
from encounter e
     , clinical_event ce
     , pat_ed_document pe
     , pat_ed_doc_activity pa
     , prsnl pr
 
plan e where e.encntr_id = 125379942.00
	;e.encntr_type_cd = 309308.00 ;Inpatient
	;and e.loc_facility_cd = 2552503645.00 ;PW
	;and e.disch_dt_tm between cnvtdatetime("06-OCT-2021 00:00:00") and cnvtdatetime("06-OCT-2021 23:59:00")
 
join ce where ce.encntr_id = e.encntr_id
	and ce.event_cd = 2820586.00	;Discharge Instructions
 
join pe where pe.encntr_id = e.encntr_id
    and pe.status_cd in(25.00) ; auth verified
    ;and pe.active_ind = 1
   ; and pe.pat_ed_domain_cd = 637886.00 ;discharge
    and pe.event_id = (select max(pe1.event_id)from  pat_ed_document pe1
                    where pe1.encntr_id = pe.encntr_id
                     and  pe1.pat_ed_document_id = pe.pat_ed_document_id
                     group by pe1.encntr_id, pe1.pat_ed_document_id )
 
join pa where pa.pat_ed_doc_id = pe.pat_ed_document_id
	;and pa.active_ind = 1
 
join pr where pr.person_id = pe.signed_id
	and pr.active_ind = 1
 
order by pe.encntr_id
 
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120
 
 
 
;Printed
select
 e.encntr_id, e.person_id, ce.event_cd, ce.event_end_dt_tm
 
from encounter e
     , clinical_event ce
 
plan e where e.encntr_id = 125379942 ;trigger_encntrid
	and e.active_ind = 1
 
join ce where ce.encntr_id = e.encntr_id
	and ce.event_cd = value(uar_get_code_by("DISPLAY", 72, "Discharge Instructions"))
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
					where ce1.encntr_id = ce.encntr_id
					and ce1.event_cd = ce.event_cd
					and ce1.result_status_cd in (23.00, 34.00, 25.00, 35.00)
					and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00")
					group by ce1.encntr_id, ce1.event_cd)
 
 
;----------------------------------------------------------------------------------------------------------
;Discharge Summary
 
select
 e.encntr_id, e.person_id, ce.event_cd, ce.event_end_dt_tm ';;q', ce.event_id, ce.result_status_cd
 
from encounter e
     , clinical_event ce
     , prsnl pr
 
plan e where e.encntr_id = 125379942 ;trigger_encntrid
	and e.active_ind = 1
 
join ce where ce.encntr_id = e.encntr_id
	and ce.event_cd = value(uar_get_code_by("DISPLAY", 72, "Discharge Summary"))
	;and ce.result_status_cd in (23.00, 34.00, 25.00, 35.00)
	;and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00")
	and ce.event_id = (select max(ce1.event_id) from clinical_event ce1
					where ce1.encntr_id = ce.encntr_id
					and ce1.event_cd = ce.event_cd
					and ce1.result_status_cd in (23.00, 34.00, 25.00, 35.00)
					and ce1.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00")
					group by ce1.encntr_id, ce1.event_cd)
 
join pr where pr.person_id = ce.performed_prsnl_id
	and pr.physician_ind = 1
	and pr.active_ind = 1
 
 
;--------------------------------------------------------------------------------------------------------------------
;Discharge Med rec
 
select ore.encntr_id, ore.recon_type_flag, ore.performed_dt_tm, ore.recon_status_cd
, o.order_id, o.order_mnemonic
;, pr.name_full_formatted
 
from order_recon ore, order_recon_detail ord, orders o
 
plan ore where ore.encntr_id = 125379942 ;trigger_encntrid
	and ore.recon_type_flag = 3
 
join ord where ord.order_recon_id = ore.order_recon_id
 
join o where o.order_id = ord.order_nbr
	;and o.order_status_cd in
	and o.active_ind = 1
 
/*join pr where pr.person_id = ore.performed_prsnl_id
	;and pr.physician_ind = 1
	and pr.active_ind = 1*/
 
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120
 
;--------------------------------------------------------------------------------------------------------------------
 
select * from person p where p.name_full_formatted = 'TTTTMAYO, FSRTEST'
 
select * from person p where p.person_id = 20755830.00
 
  125359334.00	   20755830.00
 
select * from encounter e where e.person_id =    16432316.00
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120
 
 
select * from orders o where o.encntr_id =   125391453.00
ORDER BY O.orig_order_dt_tm DESC
 
select * from order_detail od where od.order_id =  4617517277.00
 
 
select  from encounter e where e.encntr_id = 125359334.00
 
 
 
select
 
	h.plan_name, h.active_ind, h.beg_effective_dt_tm, h.end_effective_dt_tm
	,h.health_plan_id, epr.encntr_id, epr.person_id, epr.priority_seq
from
	health_plan h, encntr_plan_reltn epr
 
plan epr where epr.encntr_id = 125359334.00
	and epr.priority_seq = 1
 
join h where h.health_plan_id = epr.health_plan_id
 
	and (cnvtupper(h.plan_name) = "BLUECARE" or cnvtupper(h.plan_name) = "TENNCARE*")
	and (cnvtupper(h.plan_name) != "BLUECARE PLUS")
	and h.active_ind = 1
 
 
;---------------------------------------------------------------------------
;Active relationship 2126300148   125379942.00	   20757908.00
 
select epr.encntr_prsnl_r_cd, epr.expire_dt_tm, pr.name_full_formatted, pr.position_cd, pr.username
from encntr_prsnl_reltn epr, prsnl pr
 
plan epr where epr.encntr_id = 125379942.00
	and epr.expire_dt_tm = null
	and epr.active_ind = 1
	and epr.encntr_prsnl_r_cd in(
		 value(uar_get_code_by("DISPLAY", 333, "Database Coordinator"))
		,value(uar_get_code_by("DISPLAY", 333, "Chart Review"))
		,value(uar_get_code_by("DISPLAY", 333, "Chart Review/Audit"))
		,value(uar_get_code_by("DISPLAY", 333, "ED Charge Nurse"))
		,value(uar_get_code_by("DISPLAY", 333, "ED Nurse"))
		,value(uar_get_code_by("DISPLAY", 333, "Graduate Nurse"))
		,value(uar_get_code_by("DISPLAY", 333, "Imaging Nurse"))
		,value(uar_get_code_by("DISPLAY", 333, "Long Term Care Nurse"))
		,value(uar_get_code_by("DISPLAY", 333, "Nurse Practitioner"))
		,value(uar_get_code_by("DISPLAY", 333, "Oncology RN"))
		,value(uar_get_code_by("DISPLAY", 333, "OR Management"))
		,value(uar_get_code_by("DISPLAY", 333, "Registered Nurse"))
		,value(uar_get_code_by("DISPLAY", 333, "RN Surgical Services"))
		,value(uar_get_code_by("DISPLAY", 333, "RN Team Lead"))
		,value(uar_get_code_by("DISPLAY", 333, "Secondary Nurse"))
		,value(uar_get_code_by("DISPLAY", 333, "Specialty Nurse"))
		,value(uar_get_code_by("DISPLAY", 333, "Student Nurse"))
		,value(uar_get_code_by("DISPLAY", 333, "Vascular Nurse"))
		,value(uar_get_code_by("DISPLAY", 333, "Wound Care Nurse")) )
 
join pr where pr.person_id = epr.prsnl_person_id
	and pr.active_ind = 1
 
order by epr.active_status_dt_tm
 
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120
 
 
 
select cv1.code_value,cv1.display
from code_value cv1
where cv1.code_set =  88 ;333
	and cv1.display = '*Nurse*'
	and cv1.active_ind = 1
order by cv1.display
 
with  format, time = 60
 
;-------------------------------------------------------------------------------------------------------------------
 
 
select ore.performed_dt_tm ';;q';into 'nl:'
from order_recon ore
plan ore where ore.encntr_id = 125338265.00;125460662       ; trigger_encntrid
	and ore.order_recon_id = (select max(ore1.order_recon_id) from order_recon ore1
		where ore1.encntr_id = ore.encntr_id
		and ore1.recon_type_flag = 3
		/*and ore1.performed_dt_tm <= sysdate*/
		group by ore1.encntr_id)
	and ( format(ore.performed_dt_tm,'mm/dd/yyyy') = format(cnvtdate(sysdate),'mm/dd/yyyy;;q') )
order by ore.order_recon_id
 
Head report
	log_retval =0
 	log_misc1 = ' '
	log_message = concat( 'Discharge Meds Not Found', log_misc1)
Detail
 	log_retval = 100
 	log_misc1 = format(ore.performed_dt_tm, 'dd-mmm-yyyy hh:mm:ss;;q')
 	log_message = concat( 'Discharge Meds Modified on ', log_misc1)
 
 
 
 
 
select ore.performed_dt_tm ';;q'
from order_recon ore
plan ore where ore.encntr_id = 125460656       ;  125454830.00;trigger_encntrid
	and ore.order_recon_id = (select max(ore1.order_recon_id) from order_recon ore1
		where ore1.encntr_id = ore.encntr_id
		and ore.recon_type_flag = 3
		and ore.performed_dt_tm  > cnvtlookbehind("01,M")
		group by ore1.encntr_id)
 
order by ore.performed_dt_tm
 
Head report
	log_retval =0
 	log_misc1 = ' '
	log_message = concat( 'Discharge Meds Not Found ', log_misc1)
Detail
 	log_retval = 100
 	log_misc1 = format(ore.performed_dt_tm, 'dd-mmm-yyyy hh:mm:ss;;q')
 	log_message = concat( 'Discharge Meds Modified on ', log_misc1)
 
 
 
 
 
 
 
 
 
 
 
 select * from prsnl pr where pr.username = 'GSARAVAN'
 
 select ac.start_dt_tm ';;q', ac.* from application_context ac where ac.person_id =    12428721.00 order by ac.start_dt_tm desc
 
 
select * from eks_alert_esc_hist eh where  eh.encntr_id = 125379942.00 order by eh.updt_dt_tm desc
 
select * from  eks_alert_recipient rp where rp.alert_id =     3648276.00
 
 
select * from eks_alert_esc_hist eh, eks_alert_recipient rp
where  eh.encntr_id = 125379942.00
and rp.alert_id = eh.alert_id
order by eh.updt_dt_tm desc
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120
 
 
 
select * from eks_alert_esc_hist eh where  eh.encntr_id = 125379942.00 order by eh.updt_dt_tm desc
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120
 
 
select * from eks_notify_dest ed where ed.read_person_id = 12428721.00
 
select * from eks_notify_loc_r where location = 'GSARAVAN'
 
 
select * from eks_notify_persn_r ed
;where ed.person_id = 12428721.00
order by ed.updt_dt_tm
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120
 
	     4231657.00	   12428721.00	       2	12-13-2021 11:20:00	          1.00	    3071000	          1	 1298747764.00
	     4231659.00	   12428721.00	       2	12-13-2021 11:20:00	          1.00	    3071000	          1	 1298747764.00
	     4231661.00	   12428721.00	       2	12-13-2021 13:36:00	          1.00	    3071000	          1	 1298749294.00
	     4231663.00	   12428721.00	       2	12-13-2021 13:36:00	          1.00	    3071000	          1	 1298749294.00
	     4231665.00	   12428721.00	       0	12-13-2021 13:36:00	          1.00	    3071000	          1	 1298752749.00
	     4231667.00	   12428721.00	       0	12-13-2021 13:36:00	          1.00	    3071000	          1	 1298752749.00
 
 
with maxrow = 1000
 
 
 
 
select * from prsnl pr where pr.person_id in(   12735933.00,   12428721.00)
 
 
select eh.alert_id,eh.updt_dt_tm, eh.*
from eks_alert_esc_hist eh where  eh.encntr_id =  125457611.00; 125459312.00 ;BHSEIGHTMEDREC
order by eh.alert_id desc ;,eh.updt_dt_tm desc
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120
 
 
select eh.alert_id,eh.updt_dt_tm, eh.*
from eks_alert_esc_hist eh ;where  eh.encntr_id = 125454902;125379942.00
where eh.subject_text = '*Discharge Medication Alert*'; - Test'; Nursing'
;and eh.parent_entity_id != 0
and eh.parent_entity_name != ' '
;and eh.send_dt_tm >= cnvtdatetime("15-NOV-2021 00:00:00")
order by eh.alert_id desc
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120
 
 
 
select ce.* from clinical_event ce where ce.encntr_id = 124898613
	and ce.event_cd = value(uar_get_code_by("DISPLAY", 72, "Discharge Summary"))
	;in(disch_instruction_var, disch_summary_var)
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
	and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00)
 
 
;Sherri
ALIAS		ENCNTR_ID			PERSON_ID	FAC
5135000039	  125457611.00	   20768264.00	PW Senior Behav
 
ALIAS		ENCNTR_ID
5135000039	  125457611.00  ZZZTEST, BHSEVENMEDREC
 
;Crystal's
ALIAS		ENCNTR_ID			PERSON_ID	FAC
5134300038  125454902
 
select * from person pr where pr.person_id = 744111
 pr.name_full_formatted = 'ZZZTEST, BHEIGHTMEDREC'
 
select * from encounter e where e.person_id =    20768393.00
 
ENCNTR_ID
  125454830.00
  125454836.00
  125454854.00
  125454860.00
 
 
 
 
 
 
select ore.encntr_id, ore.order_recon_id, ore.recon_status_cd, ore.recon_type_flag, ore.performed_dt_tm,ore.performed_prsnl_id
from order_recon ore
where ore.encntr_id = 125454902 ;125457611.00;trigger_encntrid
and ore.recon_type_flag = 3
order by ore.order_recon_id
 
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 120
 
select log_misc1 = piece("12345|67|dsdfh","|",1, "NotFOund") from dummyt
 
 
select log_misc1 = piece("    3664703.00|17-DEC-2021 11:24:14" , "|" , 1, "NOTFOUND")  from dummyt
 
select log_misc1 = piece("    3664703.00|17-DEC-2021 11:24:14|", "|" , 2, "NOTFOUND",3) from dummyt go
 
 
 select log_misc1 = piece("    3664703.00|17-DEC-2021 11:24:14" , "|" , 2, "NOTFOUND") go
 
 tt = substring(1,6, '20768264|'),
 
 set log_misc1 = piece("@MISC:{ccl}" , "|" , 1, "NOTFOUND")go
 
 WH    125338265.00
 
=============================== AMERIGROUP =============================================================================== 
select 
	epr.encntr_id, org.org_name,h.plan_name, h.active_ind, h.beg_effective_dt_tm, h.end_effective_dt_tm
	,e.encntr_type_cd,h.health_plan_id, epr.encntr_id, epr.person_id, epr.priority_seq
 
from	encntr_plan_reltn epr, health_plan h, org_plan_reltn o, organization org, encounter e
 
plan h where h.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
	and h.active_ind = 1
 
join epr where epr.health_plan_id = h.health_plan_id
	and epr.priority_seq = 1
 
join e where e.encntr_id = epr.encntr_id
	and not(e.encntr_type_cd in(309308.00,309310.00,309312.00,19962820.00))
 
join o where o.health_plan_id = h.health_plan_id
	and o.org_plan_reltn_cd = 1200.00
	and o.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
	and o.active_ind = 1
 
join org where org.organization_id = o.organization_id
	and org.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
	and org.org_name = 'Amerigroup'
	and org.active_ind = 1
	
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180
 
======================================================================================================================  
 
 select E.encntr_id, E.loc_facility_cd, ea.alias, e.reg_dt_tm
 from encounter e, ENCNTR_ALIAS EA
 where e.reg_dt_tm between cnvtdatetime('24-JAN-2022 00:00:00') and cnvtdatetime('24-JAN-2022 23:59:59')
 and e.disch_dt_tm is null
 and e.encntr_id = ea.encntr_id
 and ea.encntr_alias_type_cd = 1077
 with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180
 
 
;--------------------------------------------------------------
 
;Alerts detail by Module
 
select ema.module_name, stri = replace(emad.logging, "'","",0) , emad.*
from eks_module_audit ema, eks_module_audit_det emad
where ema.rec_id = emad.module_audit_id
and cnvtupper(ema.module_name) = 'COV_VTE_SCRATCHPAD'
and emad.encntr_id =   125464700.00
and emad.template_type = 'A'
 
 
;and cnvtupper(emad.logging) = '*VTE*'
;and emad.logging = 'Log action with name*'
and replace(emad.logging, "'","",0) = 'VTE SCRATCHPAD'
 
 
and emad.updt_dt_tm >= sysdate
order by emad.updt_dt_tm
 
 
 Log action with name -'VTE SCRATCHPAD'(0.00s)
 
  findpos = findstring ( "" "", reason_for_visit )
 
 replace(trim(admission_form),",","",2)
 
 
 select tt = replace('Log action with name', "'", "" ,2) from dummyt d
 
 
 
 select ce.event_cd, ce.result_val, ce.event_end_dt_tm, ce.*
 from clinical_event ce where ce.encntr_id = 125359334
 order by ce.event_end_dt_tm desc
 with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180
 
 
 

     309308.00	Inpatient
     309312.00	Observation
   19962820.00	Outpatient in a Bed
     309309.00	Outpatient
     309310.00	Emergency

 
 
 
 
select * from person p where p.name_full_formatted = '*MEDREC*'
 
 
   20768264.00
 
 Reg VTE Reason Not Received vF	Medical Reason-Mechanical	01/26/2022 14:15:00
 
 
select * from prsnl pr where pr.username = 'GSARAVAN' ;'KSHIRLEY';'IT.NBABAN'
 
;IT.NBABAN'
PERSON_ID   12402065.00
 
;Kim
PERSON_ID   12736302.00
 
 
select ac.*
from application_context ac
where ac.person_id =    12428721.00 ;12402065.00 ;12736302.00
order by ac.updt_dt_tm desc
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180
 
 
 
 
select ac.*
from application_context ac
plan ac where ac.person_id = 12736302.00 ;12402065.00 ;12321981 ;16505162.00 ;reqinfo->updt_id
and ac.start_dt_tm = (select max(ac1.start_dt_tm) from application_context ac1
				where ac1.person_id = ac.person_id
				and cnvtlower(ac1.application_image) = 'powerchart'
 				and datetimecmp(cnvtdatetime(curdate, curtime), ac1.start_dt_tm)  = 0
				and ac1.end_dt_tm is null)
head report
	log_message = "Current Powerchart Session Not Found"
	log_misc1 = ' '
	log_retval = 0
detail
	log_message = build2("Current Powerchart Session Found on " ,format(ac.start_dt_tm,";;q"))
	log_misc1 = format(ac.start_dt_tm, 'dd-mmm-yyyy hh:mm:ss;;q')
	log_retval = 100
with nocounter, nullreport go
 
 
task_activity ta
 
 
select * from person p where p.name_full_formatted = 'ZZZTEST, VTETESTINGFOUR'
 
 
select * from encounter e where e.person_id =     20773971.00
 
select * from eks_alert_esc_hist eh
;where eh.encntr_id = 125359334 ;124898613
where eh.alert_id = 3861889
order by eh.updt_dt_tm desc
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180
 
 
125359334
 
select ore.*
from order_recon ore
plan ore where ore.encntr_id = 125359334
	and ore.recon_type_flag = 3
	/*and ore.order_recon_id = (select max(ore1.order_recon_id) from order_recon ore1
		where ore1.encntr_id = ore.encntr_id
		and ore1.recon_type_flag = 3
		/*and ore1.performed_dt_tm <= sysdate
		group by ore1.encntr_id)*/
	and ( format(ore.performed_dt_tm,'mm/dd/yyyy') = format(cnvtdate(sysdate),'mm/dd/yyyy;;q') )
order by ore.order_recon_id
 
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180
 
 
Head report
	log_retval =0
 	log_misc1 = ' '
	log_message = concat( 'Discharge Meds Not Found', log_misc1)
Detail
 	log_retval = 100
 	log_misc1 = format(ore.performed_dt_tm, 'dd-mmm-yyyy hh:mm:ss;;q')
 	log_message = concat( 'Discharge Meds Modified on ', log_misc1)
 
 
 
select ;into 'nl:'
eh.encntr_id, eh.send_dt_tm, eh.alert_id, eh.updt_dt_tm
from eks_alert_esc_hist eh
plan eh where eh.encntr_id = 125359334 ;trigger_encntrid
	and eh.updt_dt_tm between cnvtlookbehind("3,m") and cnvtdatetime(curdate,curtime3)
	and eh.msg_type_cd = value(uar_get_code_by("DISPLAY", 30420, "Notify"))
	and eh.subject_text = '*Discharge Medication Alert - Case Management'
	and eh.alert_source IN('COV_DSCH_MEDREC_TSK', 'COV_DSCH_MEDREC_TSK_REMIN')
order by eh.encntr_id, eh.alert_id
 
Head report
	log_message = "No Alerts found"
	log_retval = 0
	log_misc1 = ' '
Detail
 	log_retval = 100
 	log_misc1 = 'Case Management Alert'
 	log_message = concat( 'Alert Found - ', log_misc1, eh.alert_id)
with nocounter, nullreport go
 
 
 
 
 
select ede.alert_id, ede.send_dt_tm, ede.ack_by_dt_tm, ede.ack_by_id,ede.*
from eks_alert_esc_hist ede where ede.encntr_id = 125359334
order by alert_id desc
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180
 
 
select * from eks_notifications en where en.notification_id = 4245665.00
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180;, maxrow = 1000
 
select * from eks_notify_persn_r enp where enp.person_id = 12428721.00
order by enp.updt_dt_tm desc
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180;, maxrow = 1000
 
select * from eks_notification_blob_r enp where enp.notification_id = 4245665.00
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180;, maxrow = 1000
 
select * from eks_notify_dest ed where ed.person_id = 12428721
 
select *
from eks_notifications t, eks_notify_persn_r l, long_blob m
plan l where l.person_id = 12428721.00 ;l12735933.00
;and l.read_ind != 2
join t where t.notification_id = l.notification_id
join m where m.parent_entity_name= "EKS_NOTIFICATIONS"
and m.parent_entity_id=t.notification_id
and t.updt_dt_tm >= cnvtdatetime('21-FEB-2022 00:00:00')
order by t.updt_dt_tm desc
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180;, maxrow = 1000
 
 
select en.*,enp.*
from eks_notify_persn_r enp, eks_notifications en
where en.notification_id = enp.notification_id
and enp.person_id = 12428721.00
and en.updt_dt_tm >= cnvtdatetime('21-FEB-2022 00:00:00')
order by enp.updt_dt_tm desc
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180;, maxrow = 1000
 
 
 
select * from orders o where o.synonym_id =  21851071.00
 
select * from order_catalog_synonym ocs where ocs.synonym_id =  21851071.00
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, maxrow = 1000
 
select E.encntr_id, e.reg_dt_tm, e.disch_dt_tm, ea.alias, p.name_full_formatted, e.encntr_type_cd
, et = uar_get_code_display(e.encntr_type_cd)
from encounter e, encntr_alias ea, person p
where e.reg_dt_tm > cnvtdatetime('10-FEB-2022 00:00:00')
and e.encntr_type_cd = 309308.00 ;Inpatient
and e.encntr_id = ea.encntr_id
and ea.encntr_alias_type_cd = 1077
and p.person_id = e.person_id
AND E.disch_dt_tm is null
 
 
Cerner Test, Physician - Hospitalist Cerner 
 
select PR.name_full_formatted, PR.username, pr.person_id 
from prsnl pr where cnvtupper(pr.username) = 'PHYS*' ;'PHYSHOSP' ;    4122622.00

	Cerner Test, Physician - Orthopaedic Surgery Cerner	PHYSORTHO	    4122619.00
	Cerner Test, Physician - Hospitalist Cerner	PHYSHOSP	    4122622.00
	Cerner Test, Physician - Neurology Cerner	PHYSNEURO	    4122623.00
	Cerner Test, Physician - Intensivist Cerner	PHYSINTENS	    4122616.00
	Cerner Test, Physician - Cardiovascular Cerner	PHYSCARDIO	    4122625.00
	Cerner Test, Physician - Women's Health Cerner	PHYSOBGYN	    4122630.00
	Cerner Test, Physician - Primary Care Cerner	PHYSPCP	     593923.00

 
select * from dcp_patient_list dpl where dpl.patient_list_id = 8402164.00
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180;, maxrow = 1000
 
 
select * from dcp_patient_list dpl where dpl.owner_prsnl_id =  4122622.00
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180;, maxrow = 1000
 
 
select * from dcp_custom_columns dpl where dpl.prsnl_id =  4122622.00
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180;, maxrow = 1000
 
 
select * from dcp_pl_query_value dql where dql.patient_list_id =      8402164.00
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180;, maxrow = 1000
 
     8440263.00
 
ry dcp_patient_list, where owner_prsnl_id = <user's person_id>.
 
select ac.*
from application_context ac
;where ac.person_id = 4122619.00
where ac.username = 'PHYSINTENS'
and cnvtlower(ac.application_image) = 'powerchart'
;and datetimecmp(cnvtdatetime(curdate, curtime), ac.start_dt_tm)  = 0
and ac.start_dt_tm >= cnvtdatetime('04-MAR-2022 00:00:00')
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180;, maxrow = 1000


and ac.start_dt_tm = (select max(ac1.start_dt_tm) from application_context ac1
				where ac1.person_id = ac.person_id
				and cnvtlower(ac1.application_image) = 'powerchart'
 				and datetimecmp(cnvtdatetime(curdate, curtime), ac1.start_dt_tm)  = 0
				and ac1.end_dt_tm is null)
 
 
 
select e.encntr_id, e.encntr_type_cd, o.orig_order_dt_tm, o.catalog_cd
from encounter e
	,(left join orders o on o.encntr_id = e.encntr_id
		and o.catalog_cd in (4180632.00, 2561438541.00,23493301.00,4180634.00) 
		and o.active_ind = 1 )

plan e where e.reg_dt_tm >= cnvtdatetime('01-FEB-2022 00:00:00')
	and e.encntr_type_cd in(309308.00,309312.00, 19962820.00)
join o	
	
order by o.person_id, o.updt_dt_tm desc, o.order_id desc
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180;, maxrow = 1000  	
  	
  	
  	
  	
select o.orig_order_dt_tm, o.catalog_cd, e.encntr_id, e.reg_dt_tm, e.encntr_type_cd
from orders o, encounter e
plan o where o.catalog_cd in (4180632.00, 2561438541.00,23493301.00,4180634.00) 
  		;(inpatient,observation,outpatient_in_bed,outpatient_for_proc_services ) )
    		and o.active_ind = 1 
    		and o.orig_order_dt_tm >= cnvtdatetime('01-FEB-2022 00:00:00')
    		;and o.orig_order_dt_tm between cnvtlookbehind ("1,y" ) and cnvtdatetime (current_date_time ) )
    		;and expand (exp_idx ,1 ,person_cnt ,o.encntr_id ,reply->person[exp_idx ].encntr_id ) )
join e where e.encntr_id = o.encntr_id
    		
order by o.person_id, o.updt_dt_tm desc, o.order_id desc
   	
  with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180;, maxrow = 1000
 	
   	
 4180632.00		PSO Admit to Inpatient
 2561438541.00	PSO Observation
 23493301.00	PSO Outpatient in a Bed
 4180634.00		PSO Outpatient for Procedure or Service

   	
select o.encntr_id from orders o where o.catalog_cd = 4180634.00
and o.orig_order_dt_tm >= cnvtdatetime('01-FEB-2022 00:00:00')
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180;, maxrow = 1000
  
  
  
125359334
   	
select * from  encounter e where e.encntr_id =   125229617.00
   	

select * ;into "nl:"
from dm_info d
where d.info_domain = "INS"
and d.info_name = "CONTENT_SERVICE_URL"   	

   	
select ore.recon_status_cd, ore.* from order_recon ore
where ore.encntr_id =   125467523.00 ;  125467523.00 ;125359334
;and ore.recon_type_flag = 3
order by ore.updt_dt_tm desc



select fin = ea.alias, p.name_full_formatted, elh.loc_nurse_unit_cd, e.depart_dt_tm, o.catalog_cd, o.order_status_cd, o.updt_dt_tm
from encntr_loc_hist elh, encounter e, orders o, encntr_alias ea, person p
where e.encntr_id = elh.encntr_id
and e.disch_dt_tm is null
;and elh.loc_nurse_unit_cd IN(2552512729.00, 2552503897.00)
and o.encntr_id = e.encntr_id
and o.catalog_cd in(4180632.00, 2561438541.00,23493301.00,4180634.00)
and ea.encntr_id = e.encntr_id
and ea.encntr_alias_type_cd = 1077
and ea.alias = '2118501117'
and p.person_id = e.person_id
order by ea.alias, o.updt_dt_tm
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180;, maxrow = 1000  	


2552512729.00	LCMC 3S
2552503897.00	LCMC 3M


select o.*
from orders o, encntr_alias ea
where ea.alias = '2118700958';'2118902170'
and ea.encntr_id = o.encntr_id
and o.catalog_cd in(4180632.00, 2561438541.00,23493301.00,4180634.00)
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180;, maxrow = 1000  	

br_datamart_filter f ),
      (br_datamart_filter f2 ),
      (br_datamart_value v2

select * from br_datamart_filter f

select * from br_datamart_category bdc
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180;, maxrow = 1000  	


select ore.encntr_id, ore.recon_type_flag, ore.recon_status_cd
from order_recon ore
plan ore where ore.encntr_id = 125467523.00
	and ore.recon_type_flag = 3	
	and ore.recon_status_cd != value(uar_get_code_by("DISPLAY", 4002695,"Complete"))



ALIAS		ENCNTR_ID		PERSON_ID
5206300011	  125467523.00	   20777901.00




select into "nl:"
from order_recon ore
plan ore where ore.encntr_id = trigger_encntrid
	and ore.recon_type_flag = 3	
	and ore.recon_status_cd != value(uar_get_code_by("DISPLAY", 4002695,"Complete"))
									 
Head report
	log_retval = 0
	log_message = build2("Discharge Medrec Completed", log_retval)
Detail
	log_retval = 100
	log_message = build2( "Discharge Medrec Not Completed Yet", log_retval)


==============================================================================================
;Smart Zone Alert

select * ; pa.encntr_id, pa.alert_source, pa.alert_txt, pa.passive_alert_id, pa.alert_txt, pa.updt_dt_tm
from passive_alert pa 
;where pa.alert_source = 'COV_SZ_CODE_BLUE_ALERT'
where pa.person_id =    22376109.00
;where pa.encntr_id = 130141712
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000



select * from passive_alert_position pap where pap.passive_alert_id =       1587634.00
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000


      9032493.00
      9034493.00
      9030493.00


select pa.encntr_id, pa.alert_source, pa.alert_txt, pa.passive_alert_id, pa.updt_dt_tm
from passive_alert pa 
where pa.updt_dt_tm >= cnvtdatetime('28-MAY-2021 00:00:00')
and pa.alert_source = 'COV_SZ_CODE_BLUE_ALERT'
;and pa.alert_txt = 
order by pa.updt_dt_tm desc
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000

select pa.encntr_id, pa.alert_source, pa.alert_txt, pa.passive_alert_id, pa.updt_dt_tm
from passive_alert pa 
where pa.encntr_id = 125484071  
and pa.alert_source = 'COV_SZ_INTERP_REMINDER*'
and pa.alert_txt = '*Interpreter needed'
order by pa.updt_dt_tm desc
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000



select pa.encntr_id, pa.alert_source, pa.alert_txt, pa.passive_alert_id, pa.updt_dt_tm
from passive_alert pa 
where pa.updt_dt_tm >= cnvtdatetime('01-JAN-2021 00:00:00')
;and pa.alert_source = 'COV_SZ_INTERP_REQ'
and cnvtlower(pa.alert_txt) = '*interpre*'
order by pa.updt_dt_tm desc
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000

select fin = ea.alias, pa.encntr_id, pa.person_id,pa.alert_source, pa.alert_txt, pa.passive_alert_id, pa.updt_dt_tm
from passive_alert pa, encntr_alias ea
where pa.updt_dt_tm >= cnvtdatetime('01-JAN-2021 00:00:00')
and ea.encntr_id = pa.encntr_id
and ea.encntr_alias_type_cd = 1077
;and pa.alert_source = 'COV_SZ_INTERP_REQ'
and cnvtlower(pa.alert_txt) = '*interpre*'
order by pa.updt_dt_tm desc
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000




select * 
from passive_alert_action paa
where paa.passive_alert_id in(257456.00,257454.00)

;where paa.updt_dt_tm >= cnvtdatetime('28-JUN-2022 00:00:00')
order by paa.updt_dt_tm desc
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000


select * from passive_alert_position pap
where pap.passive_alert_id = 255358.00
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000



select pa.encntr_id, pa.alert_txt, paa.* 
from passive_alert_action paa, passive_alert pa 
where pa.passive_alert_id = paa.passive_alert_id
and paa.updt_dt_tm >= cnvtdatetime('28-JUN-2022 00:00:00')
order by paa.updt_dt_tm desc
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000


select DIFF = DATETIMEDIFF(cnvtdatetime(curdate,curtime3), cnvtdatetime('29-JUN-2022 00:00:00') ,3)from dummyt

select trunc_date = datetimetrunc(cnvtdatetime("02-Apr-2008 10:55:29"), "dd") ';;q' from dummyt

select trunc_date = datetimetrunc(cnvtdatetime("02-Apr-2008 10:55:29"), "dd") ';;q' 
, today_dt = datetimetrunc(cnvtdatetime(curdate,curtime3), "dd") ';;q' 
from dummyt



;RULE SETUP
select * ; pa.encntr_id, pa.alert_source, pa.alert_txt, pa.passive_alert_id, pa.alert_txt, pa.updt_dt_tm
from passive_alert pa 
;where pa.alert_source = 'COV_SZ_CODE_BLUE_ALERT'
where pa.person_id =    22376109.00
;where pa.encntr_id = 130141712
and pa.active_ind = 1
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000



select * from passive_alert_position pap where pap.passive_alert_id =       1587634.00
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000


select * 
from passive_alert_action paa
where paa.passive_alert_id in(9032493.00,9034493.00,9030493.00)
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000



select *
from passive_alert pa
where pa.passive_alert_id = 9034493.00
;and pa.active_ind = 1
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000

      


==============================================================================================

;Interpreter

select pp.interp_required_cd, pp.interp_type_cd, pp.* 
from person_patient pp 
where pp.person_id =      15208438.00; 15556719.00
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1);, maxrow = 10000   


select pp.interp_required_cd, pp.interp_type_cd, pp.* 
from person_patient pp 
where pp.interp_required_cd = 634768.00	;Yes
;where pp.person_id =      15208438.00; 15556719.00
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000   	
	
Code set - 329
CODE_VALUE	DISPLAY
     634767.00	No
     634768.00	Yes
   	
   	
   	
;Find FIN and enc info   	
select fin = ea.alias, e.encntr_id, e.person_id, p.name_full_formatted
from person p, encounter e, encntr_alias ea 
where p.name_full_formatted = 'ZZZTEST, SELENA'   	
and e.person_id = p.person_id
and ea.encntr_id = e.encntr_id
and ea.encntr_alias_type_cd = 1077
and ea.active_ind = 1
and e.active_ind = 1
and p.active_ind = 1
   	
   	
;Find FIN and Interpreter   	
select fin = ea.alias, e.encntr_id, e.person_id, p.name_full_formatted, pp.interp_required_cd, pp.interp_type_cd, pp.updt_dt_tm
from person p, encounter e, encntr_alias ea, person_patient pp 
;WHERE p.person_id = 18862688
where p.name_full_formatted =  'ZZZTEST, CUSTDEV'
;'ZZZTEST, SELENA'  ;'ZZZTEST, OLDHARLEY' ;'ZZZTEST, RAD';'ZZZTEST, SELENA'   	
and e.person_id = p.person_id
and pp.person_id = p.person_id
and ea.encntr_id = e.encntr_id
and ea.encntr_alias_type_cd = 1077
and ea.active_ind = 1
and e.active_ind = 1
and p.active_ind = 1
order by p.updt_dt_tm desc
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000

SELECT P.*
from person p
where p.name_full_formatted =  'TEST, CUSTDEV'

select * from person_patient pp where pp.person_id = 21391781
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000

select pm.n_encntr_type_cd, pm.n_encntr_type_class_cd, pm.* 
from pm_transaction pm 
WHERE pm.n_name_formatted = 'TEST, CUSTDEV' ;Cert
;where pm.n_person_id 
;where pm.n_encntr_id = 127911711
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000

N_LANGUAGE_DISPLAY
Sign Language

21391781        127911711
;-------------------------------------------------------------------
;From Todd - scheduling
   	
There's a table named SCH_EVENT_DETAIL that contains various pieces of information for scheduled appointments.
Related to that table are two others: ORDER_ENTRY_FIELDS and OE_FIELD_MEANING.

They join like this:

"	SCH_EVENT_DETAIL sed
"	ORDER_ENTRY_FIELDS oef on oef.oe_field_id = sed.oe_field_id
"	OE_FIELD_MEANING ofm on ofm.oe_field_meaning_id = oef.oe_field_meaning_id

From there you can find info for an appointment, e.g.:

OE_FIELD_ID      CODESET  DESCRIPTION            OE_FIELD_MEANING_ID
23290423.00       329     Interpreter Required   3580.00
25789963.00       104051  Sch Interpreter        2088.00
2562479461.00     100360  Sch BH Interpreter     9000.00

OE_FIELD_MEANING_ID    OE_FIELD_MEANING     DESCRIPTION
3580.0	           SCHINTERPRETER      Interpreter Required


Once you know what info you need, you can join to the appointment table:

o	SCH_EVENT_DETAIL sed
o	SCH_APPT sa on sa.sch_event_id = sed.sch_event_id
   	
   	
select * from order_entry_fields oef where oef.oe_field_id = 25789963.00
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000

select * from oe_field_meaning ofm   	
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000


select sa.orig_beg_dt_tm, sa.orig_end_dt_tm, sa.* 
from sch_appt sa where sa.encntr_id = 125487173.00
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000

select * from sch_event sab where sab.candidate_id =   868463261.00   	
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000
   	
   	
select sa.encntr_id, sa.person_id, sed.oe_field_display_value, sed.beg_effective_dt_tm,sed.updt_dt_tm, oef.oe_field_id, ofm.description
, ofm.oe_field_meaning, ofm.oe_field_meaning_id, oef.*, sed.*
from  sch_appt sa, sch_event_detail sed, order_entry_fields oef, oe_field_meaning ofm
where sa.person_id =     20785859.00 ;ZZZTEST, SELENA
;and sa.encntr_id =   125487173.00
and sed.sch_event_id = sa.sch_event_id
and oef.oe_field_id = sed.oe_field_id
and ofm.oe_field_meaning_id = oef.oe_field_meaning_id
and sed.oe_field_id in(25789963.00,3910266653.00) ;req
and sed.beg_effective_dt_tm >= cnvtdatetime("24-AUG-2022 00:00:00")
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000


select sa.encntr_id, sa.person_id, sed.oe_field_display_value, sed.beg_effective_dt_tm,sed.updt_dt_tm, oef.oe_field_id, ofm.description
, ofm.oe_field_meaning, ofm.oe_field_meaning_id, oef.*, sed.*
from  sch_appt sa, sch_event_detail sed, order_entry_fields oef, oe_field_meaning ofm
where sa.encntr_id = 125487734.00
;where sa.person_id =     20785859.00 ;ZZZTEST, SELENA
and sed.sch_event_id = sa.sch_event_id
and oef.oe_field_id = sed.oe_field_id
and ofm.oe_field_meaning_id = oef.oe_field_meaning_id
and sed.oe_field_id in(23290423.00,25789963.00,2562479461.00, 3910266653.00) ;req
and sed.beg_effective_dt_tm >= cnvtdatetime("24-AUG-2022 00:00:00")
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000



select pm.n_encntr_type_cd, pm.n_encntr_type_class_cd, pm.* 
from pm_transaction pm 
;where pm.n_person_id = 20785859.00 ;ZZZTEST, SELENA
;where pm.n_encntr_id = 127911711
where pm.n_name_formatted = 'ZZZTEST, SELENA'
order by pm.activity_dt_tm desc
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000

'ZZZTEST, SELENA' - have multiple person_id's

   20799866.00	  125487734.00


select * from encounter e where e.encntr_id = 125487113.00

select * from encntr_alias ea where ea.encntr_id =   125487113.00


ENCNTR_ID		   PERSON_ID	OE_FIELD_DISPLAY_VALUE			BEG_EFFECTIVE_DT_TM	UPDT_DT_TM
  125486513.00	   20785859.00	No						08-17-2022 10:19:14	08-17-2022 10:19:14
  125486927.00	   20785859.00	Unknown at time of scheduling		08-24-2022 10:28:08	08-24-2022 10:28:08
  125486924.00	   20785859.00	Yes - Language other than English	08-24-2022 10:28:08	08-24-2022 10:28:08
  125486921.00	   20785859.00	Yes - Deaf/HOH				08-24-2022 10:28:08	08-24-2022 10:28:08
  125486918.00	   20785859.00	No						08-24-2022 10:28:08	08-24-2022 10:28:08

;----------------------------------------------------------------------
; FIndings for rule
;ZZZTEST, RAD
select sa.encntr_id, sa.person_id, sed.oe_field_display_value, sed.beg_effective_dt_tm,sed.updt_dt_tm
from sch_appt sa, sch_event_detail sed
where sa.encntr_id =   125486516.00
;where sa.person_id =  19914916.00 ;zzztest, rad
and sed.sch_event_id = sa.sch_event_id
and sed.oe_field_id in(23290423.00,25789963.00,2562479461.00)
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000

ENCNTR_ID	  PERSON_ID	   OE_FIELD_DISPLAY_VALUE	   BEG_EFFECTIVE_DT_TM	UPDT_DT_TM
125486516.00  19914916.00  Yes - Hard of hearing - Deaf  08-17-2022 10:21:49	08-17-2022 10:21:49


select pp.interp_required_cd, pp.interp_type_cd, pp.* 
from person_patient pp where pp.person_id = 20785859.00; 19914916.00 ;zzztest, rad
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000


select patient = p1.name_full_formatted, pp.person_id
,interpreter_request = uar_get_code_display(pp.interp_required_cd)
,contributor_system = uar_get_code_display(pp.contributor_system_cd)
,person_activated = p.name_full_formatted, format(pp.last_atd_activity_dt_tm,"mm-dd-yyyy hh:mm:ss;;d")
from person_patient pp, person p, person p1 
where pp.person_id = 20785859.00; 19914916.00 ;zzztest, rad
and p.person_id = pp.data_status_prsnl_id
and p1.person_id = pp.person_id

with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000


INTERP_REQUIRED_DISPLAY	INTERP_TYPE_DISPLAY	PERSON_ID	 UPDT_DT_TM
No		   						19914916.00	 08-17-2022 10:21:48


select * from 
;-------------------------------------------
;ZZZTEST,OLDHARLEY

select sa.encntr_id, sa.person_id, sed.oe_field_display_value, sed.beg_effective_dt_tm,sed.updt_dt_tm
from sch_appt sa, sch_event_detail sed
where sa.encntr_id =   125486519.00
;where sa.person_id =  18862688.00
and sed.sch_event_id = sa.sch_event_id
and sed.oe_field_id in(23290423.00,25789963.00,2562479461.00)
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000

ENCNTR_ID	PERSON_ID		OE_FIELD_DISPLAY_VALUE	           BEG_EFFECTIVE_DT_TM	UPDT_DT_TM
125486519.00 18862688.00	Yes - Language other than English	08-17-2022 10:23:21	08-17-2022 10:23:21


FIN		ENCNTR_ID		   PERSON_ID	NAME_FULL_FORMATTED	INTERP_REQUIRED_DISPLAY	INTERP_TYPE_DISPLAY	UPDT_DT_TM
1928801253	  116825749.00	   18862688.00	ZZZTEST, OLDHARLEY	No							08-17-2022 10:23:19
2017100005	  125328238.00	   18862688.00	ZZZTEST, OLDHARLEY	No							08-17-2022 10:23:19
1931002055	  117145238.00	   18862688.00	ZZZTEST, OLDHARLEY	No							08-17-2022 10:23:19

;---------------------------------------------------------------------------

CODE_VALUE		DISPLAY
   49244345.00	No
 3910155181.00	Yes - Hard of hearing - Deaf
 3910155191.00	Yes - Language other than English
 3910155195.00	Unknown at time of scheduling

   	
select * from order_entry_fields oef    	
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000


select * from oe_field_meaning ofm
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000


select pm.n_encntr_type_cd, pm.n_encntr_type_class_cd, pm.* 
from pm_transaction pm 
where pm.n_person_id = 20755830
;where pm.n_encntr_id =   125487113.00  ;125486519.00
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000

select pp.interp_required_cd, pp.interp_type_cd, pp.*
from PERSON_PATIENT PP where pp.person_id = 20755830
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000

select fin = ea.alias, e.encntr_id, e.person_id, e.encntr_type_cd, ce.result_val 
from encntr_alias ea, encounter e, clinical_event ce
where e.reg_dt_tm >= cnvtdatetime('01-JUN-2022 00:00:00')
and ea.encntr_id = e.encntr_id
and ea.encntr_alias_type_cd = 1077
and ce.encntr_id = e.encntr_id
and ce.event_cd = 704849.00 ;Information Given by
and ce.result_val != 'Unable to obtain'
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000


select ;pa.encntr_id, pa.alert_source, pa.alert_txt, pa.passive_alert_id, pa.updt_dt_tm
pa.person_id, pa.encntr_id, pa.passive_alert_id, pa.beg_effective_dt_tm ';;q', pa.end_effective_dt_tm ';;q', pa.alert_source
, pa.active_ind;, trunc_beg_dt = datetimetrunc(cnvtdatetime(pa.end_effective_dt_tm), "dd") ';;q' 
,pa.alert_txt, diff = datetimecmp(datetimetrunc(cnvtdatetime(curdate,curtime3), "dd"), pa.end_effective_dt_tm)
from passive_alert pa 
where pa.encntr_id = 130141715.00
and pa.alert_source = 'COV_SZ_INTERP_REMINDER*'
and pa.alert_txt = '*Interpreter needed'
order by pa.updt_dt_tm desc
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000

ENCNTR_ID	PERSON_ID
  130141715.00	   22376109.00



select o.ordered_as_mnemonic, o.encntr_id, o.person_id
from orders o 
where o.order_status_cd = 2546.00 ;Future
and o.orig_order_dt_tm >= cnvtdatetime("01-JAN-2022 00:00:00")
;and o.encntr_id != 0
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000



select o.ordered_as_mnemonic,o.order_status_cd
from orders o;, person p
;where o.person_id = o.person_id 
where o.person_id =    20768097.00
and o.order_status_cd = 2546.00 ;Future
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1);, maxrow = 10000


select * from person p where p.person_id = 20768097.00

22386109        130145712 

================== RULE TEST ================================================================================================
select ema.*, emad.*
from eks_module_audit_det emad, eks_module_audit ema 
where emad.module_audit_id = ema.rec_id
and emad.encntr_id = 130145712 
order by emad.updt_dt_tm desc
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1);, maxrow = 10000
==============================================================================================================================

select * from order_entry_fields oef where oef.description = '*Interpreter type'
where oef.oe_field_id in(23290423.00,25789963.00,2562479461.00, 3910266653.00)


select pm.n_encntr_type_cd, pm.n_encntr_type_class_cd, pm.* 
from pm_transaction pm 
where pm.n_person_id = 20785859.00 ;ZZZTEST, SELENA
;where pm.n_encntr_id = 125487173.00
;where pm.n_name_formatted = 'ZZZTEST, SELENA'
order by pm.activity_dt_tm desc
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000

select sa.orig_beg_dt_tm, sa.orig_end_dt_tm, sa.* 
from sch_appt sa where sa.encntr_id = 125487173.00
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000

select sa.appt_location_cd, sa.beg_dt_tm, sa.end_dt_tm, sed.beg_effective_dt_tm, sed.end_effective_dt_tm
,sa.encntr_id, sa.person_id, sed.oe_field_display_value, sed.beg_effective_dt_tm,sed.updt_dt_tm
, oef.oe_field_id, ofm.description, ofm.oe_field_meaning, ofm.oe_field_meaning_id, oef.*, sed.*
from  sch_appt sa, sch_event_detail sed, order_entry_fields oef, oe_field_meaning ofm
where sa.person_id =     20785859.00 ;ZZZTEST, SELENA
;and sa.encntr_id =   125487173.00
and sed.sch_event_id = sa.sch_event_id
and oef.oe_field_id = sed.oe_field_id
and ofm.oe_field_meaning_id = oef.oe_field_meaning_id
and sed.oe_field_id in(25789963.00,3910266653.00) ;req
and sed.beg_effective_dt_tm >= cnvtdatetime("24-AUG-2022 00:00:00")

with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000

 	
select 
sa.encntr_id, sa.person_id, sa.appt_location_cd
,sed.oe_field_display_value, sed.beg_effective_dt_tm,sed.updt_dt_tm, sed.oe_field_id, ofm.description
from  sch_appt sa
	, sch_event_detail sed
	, oe_field_meaning ofm

plan sa where 
	and sa.active_ind = 1

join sed where sed.sch_event_id = sa.sch_event_id
	and sed.beg_effective_dt_tm BETWEEN cnvtdatetime("01-AUG-2022 00:00:00") and cnvtdatetime("20-SEP-2022 00:00:00")
	;and sed.oe_field_id in(sch_interp_res_var, sch_interp_typ_var)
	and sed.oe_field_id in(25789963.00,3910266653.00) ;req
	and sed.active_ind = 1

join ofm where ofm.oe_field_meaning_id = sed.oe_field_meaning_id
 	
   	
   	
select sysdate ';;q',diff = datetimediff(sysdate, pa.end_effective_dt_tm,3),pa.*
from passive_alert pa , dummyt d
plan pa where pa.person_id = 22386109.00 ;trigger_personid 
	and pa.alert_txt = 'Code Blue Event On*'
	and pa.passive_alert_id = (select max(pa1.passive_alert_id) from passive_alert pa1 
			where pa1.person_id = pa.person_id
			and pa1.alert_txt = pa.alert_txt
			group by pa1.person_id)

join d where datetimediff(sysdate, pa.end_effective_dt_tm, 3) >= 0.00

with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000



select sysdate ';;q',diff = datetimediff(sysdate, pa.end_effective_dt_tm,3),pa.*
from passive_alert pa 
plan pa where pa.person_id = 22386109.00 ;trigger_personid 
	and pa.alert_txt = 'Code Blue Event On*'
	;and sysdate >= pa.end_effective_dt_tm 
	/*and pa.passive_alert_id = (select max(pa1.passive_alert_id) from passive_alert pa1 
			where pa1.person_id = pa.person_id
			and pa1.alert_txt = pa.alert_txt
			group by pa1.person_id)*/
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000




select sysdate ';;q',diff = datetimediff(sysdate, pa.end_effective_dt_tm,3),pa.*;into 'nl:'
from passive_alert pa, dummyt d
plan pa where pa.person_id = 22386109.00 ;trigger_personid 
	and pa.alert_txt = 'Code Blue Event On*'
	and pa.passive_alert_id = (select max(pa1.passive_alert_id) from passive_alert pa1 
			where pa1.person_id = pa.person_id
			and pa1.alert_txt = pa.alert_txt
			group by pa1.person_id)

join d where datetimediff(sysdate, pa.end_effective_dt_tm, 3) >= 0.00

with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000


Head report 
 	log_retval = 0
 	log_message = 'Codeblue Alert Not expired'
Detail
	log_retval = 100
	log_misc1 = format(pa.end_effective_dt_tm, 'mm/dd/yy hh:mm;;q')
 	log_message = build2('Codeblue Alert expired - ', log_misc1)
With nocounter, nullreport go


Head report 
 	log_retval = 0
 	log_message = 'Codeblue Alert Not expired'
Detail
	log_retval = 100
	log_misc1 = format(pa.end_effective_dt_tm, 'mm/dd/yy hh:mm;;q')
 	log_message = build2('Codeblue Alert expired - ', log_misc1)
With nocounter, nullreport go   	
   	
   	
MOCK Patient for result type
 
 FIN - 2125900109

ZZZTEST, CORTEXONE   	
   	
   	
   	
 3911149319.00	Communication Assessment Form
   	
   	
select * from person p where p.name_full_formatted = 'TEST, DEVGRP'    	
   	
select * from encounter e where e.person_id =     20755830.00
   	
select ea.alias, ea.encntr_id,ea.* from encntr_alias ea 
;where ea.encntr_id =    125448108.00
where ea.alias = '4000000152';'2124600147'  ;'4000000186';'2125900109'   	
   	
select e.reg_dt_tm, e.* from encounter e 
where e.encntr_id =     125486109.00; 125486659.00; 125370996.00
   	

=======================================================================================================================
   	
;Blood Bank
=======================================================================================================================
 
select * 
from patient_dispense pd 
where pd.person_id = 20812082.00
 
 
select pe.*;, pr.*, pd.*
from patient_dispense pd, product pr, product_event pe
where pd.person_id = 20812082.00
and pr.product_id = pd.product_id 
and pe.product_id = pr.product_id 
and pe.person_id = pd.person_id
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1);, maxrow = 10000

select pe.person_id, pe.encntr_id,pe.event_dt_tm, pe.event_type_cd,pe.product_id, pe.product_event_id, pe.* 
from product_event pe, product pr 
where pe.person_id = 20812082.00
and pr.product_id = pe.product_id
and pe.active_ind = 1
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000
 
select pe.person_id, pe.encntr_id,pe.event_dt_tm, pe.event_type_cd,pe.product_id, pe.product_event_id, pe.* 
from product_event pe 
;where pe.encntr_id =   125448108.00
where pe.person_id = 20812082.00
and pe.active_ind = 1
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000
 

select pe.person_id, pe.encntr_id, pe.event_dt_tm, pe.event_type_cd,pe.product_id, pe.product_event_id;, pe.* 
from product_event pe 
;where pe.encntr_id = 125486659.00 
;where pe.person_id = 20812082.00
WHERE pe.active_ind = 1
and pe.event_dt_tm >= cnvtdatetime('01-JAN-2022 00:00:00')
order by pe.person_id, pe.event_dt_tm desc
with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000

;Products
select; - live 
pe.person_id, pe.encntr_id, pe.event_dt_tm, prod_event = uar_get_code_display(pe.event_type_cd)
,pe.product_id, pe.product_event_id;, pr.*
, productcd = uar_get_code_display(pr.product_cd), prod_catcd = uar_get_code_display(pr.product_cat_cd)
, product = build2(trim(uar_get_code_display(pr.product_cd))," ",trim(uar_get_code_display(pr.product_cat_cd)))
, abo_rh = build2(trim(uar_get_code_display(bp.cur_abo_cd))," ",trim(uar_get_code_display(bp.cur_rh_cd)))
, pr.product_nbr, bp.*

from product_event pe
	, product pr
	, blood_product   bp

plan pe where pe.person_id = 20812082.00
	and pe.active_ind = 1
	
join pr where pr.product_id = pe.product_id

join bp where bp.product_id = outerjoin(pr.product_id)

order by prod_event, pe.product_event_id

with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000


;Overview

select 
pe.person_id, pe.encntr_id, pe.event_dt_tm, prod_event = uar_get_code_display(pe.event_type_cd)
,pe.product_id, pe.product_event_id,st.*
, productcd = uar_get_code_display(pr.product_cd), prod_catcd = uar_get_code_display(pr.product_cat_cd)
, product = build2(trim(uar_get_code_display(pr.product_cd))," ",trim(uar_get_code_display(pr.product_cat_cd)))
, abo_rh = build2(trim(uar_get_code_display(bp.cur_abo_cd))," ",trim(uar_get_code_display(bp.cur_rh_cd)))
, pr.product_nbr;, bp.*

from product_event pe
	, special_testing st
	, product pr
	, blood_product   bp

plan pe where pe.person_id = 20812082.00
	and pe.active_ind = 1
	
join pr where pr.product_id = pe.product_id

join st where st.product_id = pe.product_id
	and st.active_ind = 1

join bp where bp.product_id = outerjoin(pr.product_id)

order by prod_event, pe.product_event_id

with nocounter, separator=" ", format, format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180, uar_code(d,1), maxrow = 10000






 
       1429.00	Assigned
       1433.00	Crossmatched
       1436.00	Dispensed
       1448.00	Transfused
       1439.00	In Progress

 
 select
   eventdate = format(pe.event_dt_tm, "mm/dd/yyyy hh:mm" )
, product = build2(trim(uar_get_code_display(pr.product_cd))," ",trim(uar_get_code_display(pr.product_cat_cd)))
, pr.product_nbr
, dispenselocation = uar_get_code_display(p.dispense_to_locn_cd)
, type =  build2( trim(uar_get_code_display(b.cur_abo_cd)), " ", trim(uar_get_code_display(b.cur_rh_cd)))

  from
   patient_dispense   p
   , product   pr
   , product_event   pe
   , blood_product   b

  plan p 
   where p.person_id =    20812082.00 ;  125486659.00 ;20809873.00
   ;and p.dispense_status_flag = 2; 1 ;;dispensed status (1 = dispensed, 2 = transfused)
  join pr
   where p.product_id = pr.product_id
  join pe
   where p.product_id = pe.product_id
   and p.person_id = pe.person_id
   ;and pe.event_type_cd = 909 ;906 ;;906 = dispense event (909 = transfuse event)
  join b
   where b.product_id = outerjoin(pr.product_id)
  order by pe.event_dt_tm desc, pr.product_cat_cd


;----------------------------------------------------------------------------
 select
   eventdate = format(pe.event_dt_tm, "mm/dd/yyyy hh:mm" )
, product = build2(trim(uar_get_code_display(pr.product_cd))," ",trim(uar_get_code_display(pr.product_cat_cd)))
, pr.product_nbr
, dispenselocation = uar_get_code_display(p.dispense_to_locn_cd)
, type =  build2( trim(uar_get_code_display(b.cur_abo_cd)), " ", trim(uar_get_code_display(b.cur_rh_cd)))

  from
   patient_dispense   p
   , product   pr
   , product_event   pe
   , blood_product   b


  plan p 
   where p.person_id =    20812082.00 ;  125486659.00 ;20809873.00
   ;and p.dispense_status_flag = 2; 1 ;;dispensed status (1 = dispensed, 2 = transfused)
  join pr
   where p.product_id = pr.product_id
  join pe
   where p.product_id = pe.product_id
   and p.person_id = pe.person_id
   ;and pe.event_type_cd = 909 ;906 ;;906 = dispense event (909 = transfuse event)
  join b
   where b.product_id = outerjoin(pr.product_id)
  order by pe.event_dt_tm desc, pr.product_cat_cd
   	
=======================================================================================================================
   	
   	
   	
   	
   	
   	
   	

