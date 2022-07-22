 
/*****************************************************************************
        Source file name:       cov_pc_info_sheet.prg
        Object name:            cov_pc_info_sheet
 
        Executing from:         PowerChart
/*************************************************************************************************
*                           GENERATED MODIFICATION CONTROL LOG
**************************************************************************************************
*                                                                                                 *
* Feature  Mod Date       Engineer      Comment                                                   *
* -------  --- ---------- ---------- -------------------------------------------------------------*
* 418528   000 03/20/18   ARG			initital dev for CR 1261
*              05/21/18   ARG	        live
*		   001 08/15/18	  PDH			modified to pull patient PIN # interfaced from STAR.
*
************************* END OF ALL MODCONTROL BLOCKS *******************************************/
 
drop program 	cov_pc_info_sheet2:dba go
create program 	cov_pc_info_sheet2:dba
 
prompt
    "Output to File/Printer/MINE" = "MINE"
with outdev
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare USERDEFINED_CD = f8 with Constant(uar_get_code_by("DISPLAYKEY",355,"USERDEFINED")),protect
declare VETERAN_CD = f8 with Constant(uar_get_code_by("DISPLAYKEY",356,"VETERAN")),protect
declare MRN_CD = f8 with Constant(uar_get_code_by("MEANING",319,"MRN")),protect
declare PLANOFCARE_CD = f8 with Constant(uar_get_code_by("MEANING",356,"PLANOFCARE")),protect
declare EMC_CD = f8 with Constant(uar_get_code_by("MEANING",351,"EMC")),protect
declare STARTINPAT_CD = f8 with Constant(uar_get_code_by("MEANING",4002773,"STARTINPAT")),protect
declare STARTOBS_CD = f8 with Constant(uar_get_code_by("MEANING",4002773,"STARTOBS")),protect
declare OUTPATINBED_CD = f8 with Constant(uar_get_code_by("MEANING",4002773,"OUTPATINBED")),protect
declare CELLPAGERNUMBER_CD = f8 with Constant(uar_get_code_by("DISPLAYKEY",100071,"CELLPAGERNUMBER")),protect
declare HOMEPHONENUMBER_CD = f8 with Constant(uar_get_code_by("DISPLAYKEY",100071,"HOMEPHONENUMBER")),protect
declare ALTERNATEPHONENUMBER_CD = f8 with Constant(uar_get_code_by("DISPLAYKEY",100071,"ALTERNATEPHONENUMBER")),protect
declare ALTERNATE_CD = f8 with Constant(uar_get_code_by("MEANING",43,"ALTERNATE")),protect
declare PAGERPERSONAL_CD = f8 with Constant(uar_get_code_by("MEANING",43,"PAGER PERS")),protect
declare PREFPHONE_CD = f8 with Constant(uar_get_code_by("MEANING",356,"PREFPHONE")),protect
declare ADDR_INFO_CD = f8 with Constant(uar_get_code_by("MEANING",356,"ADDR_INFO")),protect
declare OBSERVATION_CD = f8 with Constant(uar_get_code_by("DISPLAYKEY",71,"OBSERVATION")),protect
declare PAGERPERS_CD = f8 with Constant(uar_get_code_by("MEANING",43,"PAGER PERS")),protect
declare business = f8 with constant(uar_get_code_by("MEANING", 43, "BUSINESS")), protect
declare home_cd = f8 with constant(uar_get_code_by("MEANING", 43, "HOME")), protect
declare mobile_cd = f8 with constant(uar_get_code_by("MEANING", 43, "MOBILE")), protect
declare nok = f8 with constant(uar_get_code_by("MEANING", 351, "NOK")), protect
declare guar = f8 with constant(uar_get_code_by("MEANING", 351, "DEFGUAR")), protect
declare final = f8 with constant(uar_get_code_by("MEANING", 17, "FINAL")), protect
declare admit = f8 with constant(uar_get_code_by("MEANING", 17, "ADMIT")), protect
declare fin = f8 with constant(uar_get_code_by("MEANING", 319, "FIN NBR")), protect
declare ssn_pool = f8 with constant(uar_get_code_by("DISPLAYKEY", 263, "SSN")), protect
declare mrn_pool = f8 with constant(uar_get_code_by("DISPLAYKEY", 263, "MRN")), protect
declare ssn = f8 with constant(uar_get_code_by("MEANING", 4, "SSN")), protect
declare mrn = f8 with constant(uar_get_code_by("MEANING", 4, "MRN")), protect
declare attenddoc = f8 with constant(uar_get_code_by("MEANING", 333, "ATTENDDOC")), protect
declare admitdoc = f8 with constant(uar_get_code_by("MEANING", 333, "ADMITDOC")), protect
declare pcp = f8 with constant(uar_get_code_by("MEANING", 331, "PCP")), protect
declare ethnicity = f8 with Constant(27.0),Protect
declare race = f8 with Constant(282.0),Protect
declare process_alert = f8 with Constant(19350.0),Protect
declare diesease_alert = f8 with Constant(19349.0),Protect
declare INSURED_CD = f8 with Constant(uar_get_code_by("MEANING",351,"INSURED")),protect
declare PT_PIN = f8 with constant(uar_get_code_by("MEANING",356, "PATIENT PIN")), protect	;001
set rhead = "{\rtf1\ansi\ansicpg1252\deff0\deflang1033{\fonttbl{\f0\fnil\fcharset0 Calibri;}}{\colortbl ;\red192\green192\blue192;}"
set f8 = "\plain \f0 \fs16 "
set f8bu = "\plain \f0 \fs16 \ul \b \cb2 "
set f8b = "\plain \f0 \fs16 \b \cb2 "
set f10 = "\plain \f0 \fs20 "
set hl = "\highlight1 "
set nhl = "\highlight0 "
set reol = "\par "
set reop = "\pard "
set rtab = "\tab "
set rmk1 = "\tx100\tx2080\tx5700\tx5860\tx8020\tx10180 "
set rmk2 = "\tx100\tx4420\tx5140\tx10180 "
set rmk3 = "\tx100\tx3700\tx7300\tx10180 "
set rmk4 = "\tx100\tx2980\tx5860\tx8020\tx10180 "
set rmk5 = "\tx100\tx1500\tx3000\tx4500\tx6000\tx8000\tx10180"
set rmk6 = "\tx100\tx2080\tx5700\tx5860\tx8020\tx9180\tx10180"
set rmk7 = "\tx100\tx2080\tx4200\tx7860\tx8020\tx9000"
set rtfeof = "}"
record list(
    1 person_id = f8
    1 name = vc
    1 addr = vc
    1 city_st_zip = vc
    1 prfred_contact = f8
    1 mobile = vc
    1 ssnum = vc
    1 dob = vc
    1 mrn = vc
    1 pcp = vc
    1 pcp_phone = vc
    1 age = vc
    1 sex = vc
    1 birth_sex = vc
    1 marital = vc
    1 race = vc
    1 religion = vc
    1 ethnicity = vc
    1 fin_class = vc
    1 cause_death = vc
    1 rfv = vc
    1 encntr_id = f8
    1 reg_dt = vc
    1 inpatient_admit_dt = vc
    1 observation_start_dt = vc
    1 observation_end_dt = vc
    1 observation_flag=i4
    1 outpatient_bed_dt = vc
    1 disch_dt = vc
    1 med_svc = vc
    1 pt_type = vc
    1 fin = vc
    1 admit_md = vc
    1 attend_md = vc
    1 adm_diag = vc
    1 final_diag = vc
    1 veteran_status=vc
    1 process_alert=vc
    1 diesease_alert=vc
    1 plan_of_care=vc
    1 pt_pin = vc	;001
    1 phone[*]
       2 phone_type_cd=f8
       2 phone_type=vc
       2 phone=vc
    1 plans[*]
        2 id = vc
        2 desc = vc
        2 company = vc
        2 name = vc
        2 ssn = vc
        2 group_num = vc
        2 dob = vc
        2 effective = vc
        2 relation = vc
    1 nok[1]
        2 name = vc
        2 addr = vc
        2 city_st_zip = vc
        2 phone = vc
        2 mobile = vc
        2 relation = vc
    1 emc[1]
        2 name = vc
        2 addr = vc
        2 city_st_zip = vc
        2 phone = vc
        2 mobile = vc
        2 relation = vc
    1 guar[1]
        2 name = vc
        2 addr = vc
        2 city_st_zip = vc
        2 phone = vc
        2 mobile = vc
        2 relation = vc
        2 employer = vc
        2 e_addr = vc
        2 e_city_st_zip = vc
        2 e_phone = vc
    1 surg[*]
        2 procedure = vc
)
 
 
;use this here to test a specific encntr_id
 
set list->encntr_id = request->visit[1].encntr_id
  ; 98676546.00
 
 
 
select into "NL:"
FROM
	encounter   e
	, encntr_alias   ea
	, person   p
	, person_alias   pa
	, address   a
	, encntr_alias   ea1
 
plan e where e.encntr_id = list->encntr_id
join ea where ea.encntr_id = e.encntr_id
    and ea.active_ind = 1
    and ea.encntr_alias_type_cd = fin
    and ea.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
join ea1 where ea1.encntr_id = e.encntr_id
    and ea1.active_ind = 1
    and ea1.encntr_alias_type_cd = MRN_CD
    and ea1.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
join p where e.person_id = p.person_id
join a where e.person_id = a.parent_entity_id
    and a.parent_entity_name = "PERSON"
    and a.active_ind = 1
    and a.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
    and a.address_type_seq = 1
join pa where pa.person_id = outerjoin(e.person_id)
    and pa.active_ind = outerjoin(1)
    and pa.person_alias_type_cd =outerjoin(ssn)
    and pa.alias_pool_cd =outerjoin(ssn_pool)
    and pa.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime))
 
ORDER BY
	e.person_id
 
head e.person_id
    list->reg_dt = format(e.reg_dt_tm, "@SHORTDATETIMENOSEC")
    list->inpatient_admit_dt = format(e.inpatient_admit_dt_tm, "@SHORTDATETIMENOSEC")
     list->disch_dt = format(e.disch_dt_tm, "@SHORTDATETIMENOSEC")
     list->med_svc = uar_get_code_display(e.med_service_cd)
     list->pt_type = uar_get_code_display(e.encntr_type_cd)
     list->fin = cnvtalias(ea.alias, ea.alias_pool_cd)
     list->fin_class = uar_get_code_display(e.financial_class_cd)
     list->name = p.name_full_formatted
     list->dob = format(p.birth_dt_tm, "MM/DD/YYYY")
     list->age = concat(substring(1, 1, uar_get_code_display(p.sex_cd)), " / ", cnvtage(p.birth_dt_tm))
     list->cause_death = p.cause_of_death
     list->person_id = e.person_id
     list->observation_flag=0
     list->religion = uar_get_code_display(p.religion_cd)
     list->marital = uar_get_code_display(p.marital_type_cd)
     list->addr = concat(trim(a.street_addr), " ", trim(a.street_addr2))
     list->city_st_zip = concat(trim(a.city), " ", trim(a.state), ", ", trim(a.zipcode))
     list->rfv = e.reason_for_visit
     list->mrn = cnvtalias(ea1.alias, ea1.alias_pool_cd)
     list->ssnum = format(pa.alias, "###-##-####")
 
WITH nocounter
;, format, separator = " ", check
;end select
 
 
;birth_sex vs admin_sex
select into "NL:"
;select into value ($outdev)
FROM
	  person   per
	, person_patient   p
 
 
plan 	per where per.person_id = list->person_id
join 	p
where 	per.person_id = p.person_id
 
head p.person_id
	list->sex 		= uar_get_code_display (per.sex_cd)
	list->birth_sex = uar_get_code_display (p.birth_sex_cd)
WITH nocounter
;, format, separator = " ", check
;end select
 
 
 
 
select into "nl:"
;select into value ($outdev)
 
from person_info pi
plan pi where pi.person_id=list->person_id
	and pi.info_sub_type_cd=ADDR_INFO_CD
	and pi.active_ind=1
	and pi.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
	and pi.value_cd!=0
order pi.person_id
head pi.person_id
	list->addr=trim(uar_get_code_display(pi.value_cd))
	list->city_st_zip=" "
 
with nocounter
;, format, separator = " ", check
 
 
select into "nl:"
;SELECT INTO value ($outdev)
FROM
	phone   p
 
plan p where p.parent_entity_id = list->person_id
	and p.parent_entity_name="PERSON"
	and p.active_ind=1
	and p.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
	and p.phone_type_seq=1
head report
	cnt=0
detail
	 cnt=cnt+1
	 stat=alterlist(list->phone,cnt)
	 list->phone[cnt]->phone=format(p.phone_num, "(###)###-####")
	 if(p.phone_type_cd= PAGERPERS_CD)
		 list->phone[cnt]->phone_type="Cell/Pager Number"
	 else
	 	list->phone[cnt]->phone_type=uar_get_code_display(p.phone_type_cd)
	 endif
	 list->phone[cnt]->phone_type_cd=p.phone_type_cd
foot report
cnt=0
 
WITH nocounter
;, format, separator = " ", check
 
 
SELECT INTO "nl:"
;SELECT INTO value ($outdev)
FROM
	person_code_value_r   p
 
plan p where p.person_id=list->person_id
	and p.code_set in (ethnicity,race,process_alert,diesease_alert )
	and p.active_ind=1
	and p.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
 
ORDER BY
	p.code_set
	, p.code_value
 
detail
	case(p.code_set)
	of ethnicity: list->ethnicity=concat(list->ethnicity, trim(uar_get_code_display(p.code_value)), ", ")
	of race: list->race=concat(list->race, trim(uar_get_code_display(p.code_value)), ", ")
	of process_alert: list->process_alert=concat(list->process_alert, trim(uar_get_code_display(p.code_value)), ", ")
	of diesease_alert: list->diesease_alert=concat(list->diesease_alert, trim(uar_get_code_display(p.code_value)), ", ")
	endcase
foot report
	list->ethnicity=replace(list->ethnicity,",","",	2)
	list->race=replace(list->race,",","",	2)
	list->process_alert=replace(list->process_alert,",","",	2)
	list->diesease_alert=replace(list->diesease_alert,",","",	2)
 
WITH nocounter
;, format, separator = " ", check
 
 
SELECT INTO "nl:"
;SELECT INTO value ($outdev)
 
FROM
	encntr_loc_hist   e
 
where e.encntr_id=list->encntr_id
	and e.active_ind=1
	and e.encntr_type_cd=OBSERVATION_CD
 
ORDER BY
	e.encntr_id
 
head e.encntr_id
list->observation_flag=1
 
WITH nocounter
;, format, separator = " ", check
 
 
SELECT INTO "nl:"
;SELECT INTO value ($outdev)
FROM
	patient_event   pe
 
plan pe where pe.encntr_id  = list->encntr_id
	and pe.event_type_cd in (STARTOBS_CD,OUTPATINBED_CD,STARTINPAT_CD)
	and pe.active_ind=1
 
ORDER BY
	pe.event_type_cd
	, pe.transaction_dt_tm   DESC
 
head pe.event_type_cd
	case(pe.event_type_cd)
		of STARTOBS_CD : if(list->observation_flag=1)
							list->observation_start_dt = format(pe.event_dt_tm, "@SHORTDATETIMENOSEC")
						 endif
		of STARTINPAT_CD : if(list->observation_flag=1)
							list->observation_end_dt = format(pe.event_dt_tm, "@SHORTDATETIMENOSEC")
						 endif
		of OUTPATINBED_CD : list->outpatient_bed_dt = format(pe.event_dt_tm, "@SHORTDATETIMENOSEC")
	 endcase
 
WITH nocounter
;, format, separator = " ", check
 
 
SELECT INTO "nl:"
;SELECT INTO value ($outdev)
    phone = if(cnvtint(ph.phone_num) > 0)
        format(ph.phone_num, "(###)###-####")
    else
        " "
    endif
from person_prsnl_reltn ppr
    ,prsnl pr
    ,phone ph
plan ppr where ppr.person_id = list->person_id
    and ppr.active_ind = 1
    and ppr.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
    and ppr.person_prsnl_r_cd = pcp
join pr where ppr.prsnl_person_id = pr.person_id
join ph where ph.parent_entity_id = outerjoin(ppr.prsnl_person_id)
    and ph.active_ind = outerjoin(1)
    and ph.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime))
    and ph.phone_type_seq = outerjoin(1)
    and ph.phone_type_cd = outerjoin(business)
detail
     list->pcp = pr.name_full_formatted
     list->pcp_phone = phone
 
WITH nocounter
;, format, separator = " ", check
;end select
 
SELECT INTO "nl:"
;SELECT INTO value ($outdev)
    role = epr.encntr_prsnl_r_cd
from encntr_prsnl_reltn epr
    ,prsnl pr
plan epr where epr.encntr_id = list->encntr_id
    and epr.active_ind = 1
    and epr.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
    and epr.encntr_prsnl_r_cd in (admitdoc, attenddoc)
join pr where epr.prsnl_person_id = pr.person_id
order
    role
head role
    if(role = admitdoc)
        list->admit_md = pr.name_full_formatted
    elseif(role = attenddoc)
        list->attend_md = pr.name_full_formatted
    endif
WITH nocounter
;, format, separator = " ", check
;;end select
 
 
 
select into "NL:"
    diag_type = d.diag_type_cd
from diagnosis d
    ,nomenclature n
plan d where d.encntr_id = list->encntr_id
    and d.diag_type_cd in (admit, final)
    and d.active_ind = 1
join n where d.nomenclature_id = n.nomenclature_id
order
    diag_type
head diag_type
    if(diag_type = admit)
        list->adm_diag = substring(1, 60, concat(trim(n.source_identifier), " ", trim(n.source_string)))
    elseif(diag_type = final)
        list->final_diag = substring(1, 60, concat(trim(n.source_identifier), " ", trim(n.source_string)))
    endif
with nocounter
 
;end select
 
select into "NL:"
    rel_type = epr.person_reltn_type_cd
    ,phone = if(cnvtint(ph.phone_num) > 0)
        concat("Home: ", format(ph.phone_num, "(###)###-####"))
    else
        " "
    endif
    ,mobile = if(cnvtint(mobile.phone_num) > 0)
        concat("Cell/Pager Number: ", format(mobile.phone_num, "(###)###-####"))
    else
        " "
    endif
    ,city_st_zip = if(a.city > "")
        concat(trim(a.city), " ", trim(a.state), ", ", trim(a.zipcode))
    else
        " "
    endif
from encntr_person_reltn epr
    ,person p
    ,address a
    ,phone ph
    ,phone mobile
plan epr where epr.encntr_id = list->encntr_id
    and epr.person_reltn_type_cd in (nok, guar,emc_cd)
    and epr.active_ind = 1
    and epr.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
join p where epr.related_person_id = p.person_id
join a where a.parent_entity_id = outerjoin(epr.related_person_id)
    and a.active_ind = outerjoin(1)
    and a.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime))
    and a.address_type_seq = outerjoin(1)
    and a.parent_entity_name = outerjoin("PERSON")
join ph where ph.parent_entity_id = outerjoin(epr.related_person_id)
    and ph.active_ind = outerjoin(1)
    and ph.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime))
    and ph.phone_type_seq = outerjoin(1)
    and ph.phone_type_cd = outerjoin(home_cd)
    and ph.parent_entity_name = outerjoin("PERSON")
join mobile where mobile.parent_entity_id = outerjoin(epr.related_person_id)
    and mobile.active_ind = outerjoin(1)
    and mobile.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime))
    and mobile.phone_type_seq = outerjoin(1)
    and mobile.phone_type_cd = outerjoin(PAGERPERS_CD)
    and mobile.parent_entity_name = outerjoin("PERSON")
order
    rel_type
head rel_type
    if(rel_type = nok)
        list->nok[1].name = p.name_full_formatted
         list->nok[1].addr = concat(trim(a.street_addr), " ", trim(a.street_addr2))
         list->nok[1].city_st_zip = city_st_zip
         list->nok[1].phone = phone
         list->nok[1].mobile = mobile
         if(epr.related_person_reltn_cd!=0)
        	 list->nok[1].relation = uar_get_code_display(epr.related_person_reltn_cd)
        	else
        		list->nok[1].relation = uar_get_code_display(epr.person_reltn_cd)
        endif
         if(list->nok[1].relation > "")
            list->nok[1].name = concat(list->nok[1].name, "  (", list->nok[1].relation, ")")
        endif
    elseif(rel_type = guar)
        list->guar[1].name = p.name_full_formatted
         list->guar[1].addr = concat(trim(a.street_addr), " ", trim(a.street_addr2))
         list->guar[1].city_st_zip = city_st_zip
         list->guar[1].phone = phone
         list->guar[1].mobile = mobile
         list->guar[1].relation = uar_get_code_display(epr.person_reltn_cd)
         if(list->guar[1].relation > "")
            list->guar[1].name = concat(list->guar[1].name, "  (", list->guar[1].relation, ")")
        endif
     elseif(rel_type=emc_cd)
     	list->emc[1].name = p.name_full_formatted
         list->emc[1].addr = concat(trim(a.street_addr), " ", trim(a.street_addr2))
         list->emc[1].city_st_zip = city_st_zip
         list->emc[1].phone = phone
         list->emc[1].mobile = mobile
         list->emc[1].relation = uar_get_code_display(epr.person_reltn_cd)
         if(list->emc[1].relation > "")
            list->emc[1].name = concat(list->emc[1].name, "  (", list->emc[1].relation, ")")
        endif
 
    endif
with nocounter
 
;end select
 
select into "NL:"
    ep.priority_seq
    ,desc = hp.plan_name
    ,id = if(trim(ep.subs_member_nbr) > "")
        ep.subs_member_nbr
    else
        ep.member_nbr
    endif
    ,group_num = ep.group_nbr
    ,effective = concat(format(ep.health_card_issue_dt_tm, "@SHORTDATE"), " - ", format(ep.health_card_expiry_dt_tm, "@SHORTDATE"))
    ,name = p.name_full_formatted
    ,dob = format(p.birth_dt_tm, "@SHORTDATE")
    ,relation = uar_get_code_display(epr.person_reltn_cd)
from encntr_plan_reltn ep
    ,health_plan hp
    ,encntr_person_reltn epr
    ,person p
plan ep where ep.encntr_id = list->encntr_id
    and ep.active_ind = 1
    and ep.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
join hp where hp.health_plan_id = ep.health_plan_id
join epr where epr.encntr_id = ep.encntr_id
    and epr.active_ind = 1
    and epr.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
    and epr.person_reltn_type_cd = INSURED_CD
    and epr.related_person_id = ep.person_id
join p where p.person_id = epr.related_person_id
order
    ep.priority_seq
head report
    cnt = 0
head ep.priority_seq
    cnt = cnt + 1
     stat = alterlist(list->plans, cnt)
     list->plans[cnt].desc = hp.plan_name
     list->plans[cnt].id = id
     list->plans[cnt].group_num = ep.group_nbr
     list->plans[cnt].effective = concat(format(ep.health_card_issue_dt_tm, "@SHORTDATE"), " - ",
     								format(ep.health_card_expiry_dt_tm, "@SHORTDATE"))
     list->plans[cnt].name = p.name_full_formatted
     list->plans[cnt].dob = format(p.birth_dt_tm, "@SHORTDATE")
     list->plans[cnt].relation = uar_get_code_display(epr.person_reltn_cd)
with nocounter
 
;end select
 
select into "NL:"
    procedure = uar_get_code_display(scp.surg_proc_cd)
from surgical_case sc
    ,surg_case_procedure scp
plan sc where sc.encntr_id = list->encntr_id
    and sc.active_ind = 1
join scp where sc.surg_case_id = scp.surg_case_id
    and scp.active_ind = 1
    and scp.proc_complete_qty = 1
order
    procedure
head report
    cnt = 0
head procedure
    cnt = cnt + 1
     stat = alterlist(list->surg, cnt)
     list->surg[cnt].procedure = uar_get_code_display(scp.surg_proc_cd)
with nocounter
 
 
 
 
SELECT INTO "nl:"
	PI_VALUE_DISP = UAR_GET_CODE_DISPLAY(PI.VALUE_CD)
 
FROM
	person_info   pi
 
plan pi where pi.person_id=list->person_id
	and pi.active_ind=1
	and pi.end_effective_dt_tm > cnvtdatetime(curdate,curtime)
	and pi.info_type_cd=USERDEFINED_CD
	and pi.info_sub_type_cd in (VETERAN_CD,PLANOFCARE_CD,PREFPHONE_CD)
 
ORDER BY
	pi.person_id
	,pi.info_sub_type_cd
 
head pi.info_sub_type_cd
	if(pi.info_sub_type_cd = VETERAN_CD)
		 list->veteran_status=PI_VALUE_DISP
	elseif(pi.info_sub_type_cd =PLANOFCARE_CD)
		list->plan_of_care =  PI_VALUE_DISP
	elseif(pi.info_sub_type_cd = PREFPHONE_CD)
		list->prfred_contact=pi.value_cd
	endif
with nocounter
 
;call echorecord (list)
 
 
;**************************************		;001
;pull in the patient PIN number entered		;001
;in STAR and interfaced to eCARE			;001
;**************************************		;001
SELECT INTO "NL:"							;001
FROM										;001
	 encounter e							;001
	,encntr_info ei							;001
	,long_text lt							;001
PLAN e										;001
	WHERE e.encntr_id = list->encntr_id		;001
JOIN ei										;001
	WHERE e.encntr_id = ei.encntr_id		;001
		AND ei.info_sub_type_cd = pt_pin	;001
JOIN lt										;001
	WHERE ei.long_text_id = lt.long_text_id	;001
		AND TEXTLEN(lt.long_text) > 1		;001
ORDER BY									;001
	e.encntr_id								;001
HEAD e.encntr_id							;001
    list->pt_pin = lt.long_text				;001
 
 
 
set reply->text = rhead
set reply->text = concat(reply->text, rmk1, reol)
set reply->text = concat(reply->text, f8b , hl, rtab, "PATIENT NAME", rtab, "Preferred Gender", rtab, "Birth Sex",rtab,reol)
set reply->text = concat(reply->text, f8  , nhl, rtab, list->name, rtab, list->sex, rtab, list->birth_sex, rtab,reol)
set reply->text = concat(reply->text, reol)
set reply->text = concat(reply->text, f8b , hl, rtab, "PATIENT PIN", rtab, rtab,rtab , rtab,reol)
set reply->text = concat(reply->text, f8  , nhl, rtab, list->pt_pin, rtab,  rtab, rtab,reol)
;set reply->text = concat(reply->text, reol, reop)
;set reply->text = concat(reply->text, rmk3, reol)
;SET reply->text = concat(reply->text, f8b , h1, rtab, "Patient PIN #",rtab,rtab,reol)	;001
;SET reply->text = concat(reply->text, f8,  nh1,rtab,list->pt_pin,rtab,reol)			;001
/*if(size(list->phone,5)=0)
	set reply->text = concat(reply->text, reol)
	set reply->text = concat(reply->text, f8,nhl,rtab,rtab,list->city_st_zip,reol)
else
	for(cnt=1 to size(list->phone,5))
		if(cnt=1)
			if( (list->prfred_contact = CELLPAGERNUMBER_CD and list->phone[cnt]->phone_type_cd = mobile_cd) or
				(list->prfred_contact = CELLPAGERNUMBER_CD and list->phone[cnt]->phone_type_cd = PAGERPERSONAL_CD) or
				(list->prfred_contact = HOMEPHONENUMBER_CD and list->phone[cnt]->phone_type_cd = home_cd) or
				(list->prfred_contact = ALTERNATEPHONENUMBER_CD and list->phone[cnt]->phone_type_cd=ALTERNATE_CD))
			set reply->text= concat(reply->text,rtab, concat(list->phone[cnt]->phone_type,": ",list->phone[cnt]->phone)," (Preferred)",reol)
			else
				set reply->text= concat(reply->text, rtab, concat(list->phone[cnt]->phone_type,": ",list->phone[cnt]->phone), reol)
			endif
		elseif(cnt=2)
			if( (list->prfred_contact = CELLPAGERNUMBER_CD and list->phone[cnt]->phone_type_cd = mobile_cd) or
				(list->prfred_contact = CELLPAGERNUMBER_CD and list->phone[cnt]->phone_type_cd = PAGERPERSONAL_CD) or
				(list->prfred_contact = HOMEPHONENUMBER_CD and list->phone[cnt]->phone_type_cd = home_cd) or
				(list->prfred_contact = ALTERNATEPHONENUMBER_CD and list->phone[cnt]->phone_type_cd=ALTERNATE_CD))
				set reply->text = concat(reply->text, f8, nhl, rtab, rtab,list->city_st_zip, rtab, rtab,
					concat(list->phone[cnt]->phone_type,": ",
			list->phone[cnt]->phone), " (Preferred)", reol)
			else
				set reply->text = concat(reply->text, f8, nhl, rtab ,  rtab,list->city_st_zip, rtab, rtab,
				 concat(list->phone[cnt]->phone_type,": ",
			list->phone[cnt]->phone), reol)
			endif
		else
				if( (list->prfred_contact = CELLPAGERNUMBER_CD and list->phone[cnt]->phone_type_cd = mobile_cd) or
				(list->prfred_contact = CELLPAGERNUMBER_CD and list->phone[cnt]->phone_type_cd = PAGERPERSONAL_CD) or
				(list->prfred_contact = HOMEPHONENUMBER_CD and list->phone[cnt]->phone_type_cd = home_cd) or
				(list->prfred_contact = ALTERNATEPHONENUMBER_CD and list->phone[cnt]->phone_type_cd=ALTERNATE_CD))
				set reply->text = concat(reply->text, f8, nhl, rtab, rtab, rtab, rtab, concat(list->phone[cnt]->phone_type,": ",
			list->phone[cnt]->phone), " (Preferred)", reol)
			else
				set reply->text = concat(reply->text, f8, nhl, rtab , rtab, rtab, rtab, concat(list->phone[cnt]->phone_type,": ",
			list->phone[cnt]->phone),reol)
			endif
		endif
	endfor
	if(size(list->phone,5)=1)
		set reply->text=concat(reply->text, f8, nhl, rtab, rtab, list->city_st_zip,reol)
	endif
endif
 
set reply->text = concat(reply->text, reol, reop, rmk5, reol)
 
set reply->text = concat(reply->text, f8b, hl, rtab, "REGISTRATION",rtab, "ADMIT",rtab, "DISCHARGE",rtab,
					"OBS START", rtab, "OBS END",rtab, "OP IN A BED",rtab,reol)
set reply->text = concat(reply->text, f8b, hl, rtab, "DATE/TIME",rtab,"DATE/TIME",rtab,"DATE/TIME",rtab,
					"DATE/TIME",rtab,"DATE/TIME",rtab," START DATE/TIME ",rtab,reol)
 
set reply->text = concat(reply->text, f8, nhl, rtab, list->reg_dt, rtab, list->inpatient_admit_dt, rtab,
					list->disch_dt, rtab,list->observation_start_dt, rtab, list->observation_end_dt, rtab, list->outpatient_bed_dt, reol)
set reply->text = concat(reply->text,reol ,reop, rmk6, reol)
 
set reply->text = concat(reply->text, f8b, hl, rtab, "PATIENT TYPE", rtab, "MEDICAL SERVICE", rtab, rtab ,
				 "FIN CLASS", rtab, "BIRTH DATE",rtab, "SEX/AGE", rtab,reol)
set reply->text = concat(reply->text, f8, nhl, rtab, list->pt_type, rtab, list->med_svc, rtab, rtab,
					list->fin_class, rtab, list->dob,rtab, list->age, reol)
set reply->text = concat(reply->text, reol ,reop, rmk7,  reol)
 
set reply->text = concat(reply->text, f8b, hl, rtab, " RELIGION", rtab, " RACE",rtab,  " ETHNICITY",rtab,
				"VETERAN",rtab ,"MARTIAL STATUS",reol)
set reply->text = concat(reply->text, f8, nhl, rtab, substring(1,15,list->religion,rtab,list->race),rtab,substring(1,15,list->
ethnicity),
				 rtab,list->veteran_status,rtab,list->marital,reol)
set reply->text = concat(reply->text, reol , reol)
 
set reply->text = concat(reply->text, f8b, hl, rtab, "PROCESS ALERT", rtab, rtab, "DISEASE ALERT", rtab,
				 rtab, "PLAN OF CARE" ,rtab,rtab,reol)
set reply->text = concat(reply->text, f8, nhl, rtab, list->process_alert, rtab, rtab,list->diesease_alert,rtab,
				rtab,list->plan_of_care,reol)
set reply->text = concat(reply->text, reol , reol)
 
set reply->text = concat(reply->text, f8b, hl, rtab, "ACCOUNT NO.\tab MRN\tab SSN\tab CAUSE OF DEATH", rtab, rtab, reol)
set reply->text = concat(reply->text, rmk2, f8, nhl, rtab, list->fin, rtab, list->mrn, rtab, "N/A", rtab, list->cause_death, reol)
set reply->text = concat(reply->text, reol, reop)
set reply->text = concat(reply->text, rmk2, reol)
 
set reply->text = concat(reply->text, f8b, hl, rtab, "ADMITTING DIAGNOSIS", rtab, rtab, "DISCHARGE DIAGNOSIS",  rtab, reol)
set reply->text = concat(reply->text, rmk2, f8, nhl, rtab, list->adm_diag, rtab, rtab, list->final_diag, reol)
set reply->text = concat(reply->text, reol, reop)
set reply->text = concat(reply->text, rmk2, reol)
 
set reply->text = concat(reply->text, f8b, hl, rtab, "REASON FOR VISIT", rtab, rtab, rtab,  reol)
set reply->text = concat(reply->text, f8, nhl, rtab, list->rfv, reol)
set reply->text = concat(reply->text, reol, reop)
set reply->text = concat(reply->text, rmk3, reol)
 
set reply->text = concat(reply->text, f8b, hl, rtab, "PCP PHYSICIAN", rtab, "ADMITTING PHYSICIAN", rtab,
				"ATTENDING PHYSICIAN",rtab, reol)
set reply->text = concat(reply->text, f8, nhl, rtab, list->pcp, rtab, list->admit_md, rtab, list->attend_md, reol)
set reply->text = concat(reply->text, rtab, list->pcp_phone, reol)
set reply->text = concat(reply->text, reol, reop)
set reply->text = concat(reply->text, rmk3, reol)
 
set reply->text = concat(reply->text, f8b, hl, rtab, "Emergency Contact",rtab,"Next of Kin",rtab,"Guarantor", rtab,  reol)
set reply->text = concat(reply->text, f8, nhl, rtab, list->emc[1]->name, rtab, list->nok[1].name, rtab, list->guar[1].name, reol)
set reply->text = concat(reply->text, f8, nhl, rtab, list->emc[1]->addr, rtab, list->nok[1].addr, rtab, list->guar[1].addr, reol)
set reply->text = concat(reply->text, f8, nhl, rtab, list->emc[1]->city_st_zip, rtab, list->nok[1].city_st_zip,
					 rtab, list->guar[1].city_st_zip, reol)
set reply->text = concat(reply->text, f8, nhl, rtab, list->emc[1]->phone, rtab,
	list->nok[1].phone, rtab, list->guar[1].phone, reol)
set reply->text = concat(reply->text, f8, nhl, rtab, list->emc[1]->mobile, rtab, list->nok[1].mobile, rtab,
						list->guar[1].mobile, reol)
set reply->text = concat(reply->text, reol, reop)
set reply->text = concat(reply->text, rmk4, reol)
 
 
set reply->text = concat(reply->text, f8b, hl, rtab, "INSURANCE", rtab, "POLICY HOLDER", rtab, "RELTN", rtab,
				 "POLICY NO.", rtab,reol)
for(idx = 1 to size(list->plans, 5))
	if(textlen(list->plans[idx]->relation) > 25)
    set pos=findstring(" ",substring(1,25,list->plans[idx]->relation),1,1)
    set relation=substring(1,pos,list->plans[idx]->relation)
    set reply->text = concat(reply->text, f8, nhl, rtab, cnvtstring(idx, 1, 0), ") ", list->plans[idx].desc, rtab,
    			list->plans[idx].name, rtab,relation, rtab, list->plans[idx].id, reol)
    set relation=substring(pos,textlen(list->plans[idx]->relation),list->plans[idx]->relation)
    set reply->text = concat(reply->text, f8, nhl, rtab, rtab, rtab,relation, rtab, rtab, reol)
    else
    set reply->text = concat(reply->text, f8, nhl, rtab, cnvtstring(idx, 1, 0), ") ", list->plans[idx].desc, rtab,
    			list->plans[idx].name, rtab, list->plans[idx].relation, rtab, list->plans[idx].id, reol)
    endif
 
endfor
set reply->text = concat(reply->text, reol, reop)
set reply->text = concat(reply->text, rmk2, reol)
 
 
 
set reply->text = concat(reply->text, f8b, hl, rtab, "SURGICAL PROCEDURES", rtab, rtab, rtab, reol)
for(idx = 1 to size(list->surg, 5))
    set reply->text = concat(reply->text, f8, nhl, rtab, list->surg[idx].procedure, reol)
endfor
*/
 
set reply->text = concat(reply->text, reol, reop)
;set reply->text = replace(reply->text, "{", "\{")
;set reply->text = replace(reply->text, "}", "\}")
set reply->text = concat(rhead, reply->text, rtfeof)
 
#endrpt
end go
 
