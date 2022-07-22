/***********************************************************
Author 			:	Todd A. Blanchard
Date Written	:	09/17/2018
Program Title	:	XR Facesheet
Source File		:	cov_ccps_drv_post_doc.prg
Object Name		:	cov_ccps_drv_post_doc
Directory		:	cust_script
DVD Version		:	2017.07.1.81
HNA Version		:	2015.01
CCL Version		:	8.8.3
Purpose			: 	Adds additional data fields to suppliment the standard
					pm_drv_post_doc's "post_doc_rec" record structure
Tables Read		:	encntr_plan_reltn, encntr_person_reltn, person,
					health_plan, person_person_reltn, person_patient
Tables Updated	:	NA
Include File	:	NA
Shell Scripts	:	NA
Executing App	:	CCL
Special Notes	:	This program is a translated copy of the original
					Cerner script - ccps_drv_post_doc. CR 3279
					requested that Ethnicity be added to the
					Patient Information section.
Usage			:	cov_ccps_drv_post_doc go
Mod		Date		Engineer				Comment
----    ----------- ----------------------- ---------------------------
001		09/17/2018	Todd A. Blanchard		CR 3279
002		08/02/2019	Todd A. Blanchard		CR 5349
003		08/30/2019	Todd A. Blanchard		Applied break fix for age calculation due to null discharge dates.
004		11/20/2019	Todd A. Blanchard		Applied break fix for missing health plan group/policy numbers.
005		02/24/2020	Todd A. Blanchard		Applied break fix for dob calculation due to timezone offset.
006		04/30/2020	Todd A. Blanchard		Added logic for observation data.
007		12/18/2020	Todd A. Blanchard		Added logic for unmasked SSN data.
008		04/16/2021	Todd A. Blanchard		Added logic for dob data.
009		08/05/2021	Todd A. Blanchard		Added logic for policy number data.
 
************************************************************/
 
drop   program cov_ccps_drv_post_doc:dba go
create program cov_ccps_drv_post_doc:dba
 
 
set post_doc_rec->extended_api_flag = 1
 
;>> Call the standard PM Post Doc driver <<
execute pm_drv_post_doc
 
;IF(bDebug)
;    call echorecord(post_doc_rec)
;ENDIF
 
 
/********************************************************************************
*   Begin Custom Driver Script                                                  *
********************************************************************************/
declare INSURED_CD      = f8 with constant(uar_get_code_by("MEANING",351,"INSURED")),protect
declare dNOKCd          = f8 with constant(uar_get_code_by("MEANING",351,"NOK")),protect
declare dEMCCd          = f8 with constant(uar_get_code_by("MEANING",351,"EMC")),protect
declare dGuarantorCd    = f8 with constant(uar_get_code_by("MEANING",351,"DEFGUAR")),protect
declare ADDR_HOME_CD    = f8 with constant(uar_get_code_by("MEANING",212,"HOME")),protect
declare ADDR_BUS_CD     = f8 with constant(uar_get_code_by("MEANING",212,"BUSINESS")),protect
declare dSub01PPRId     = f8 with noconstant(0.0),protect
declare dSub01EPRId     = f8 with noconstant(0.0),protect
declare dSub02PPRId     = f8 with noconstant(0.0),protect
declare dSub02EPRId     = f8 with noconstant(0.0),protect
declare dSub03PPRId     = f8 with noconstant(0.0),protect
declare dSub03EPRId     = f8 with noconstant(0.0),protect
declare EVENT_TYPE_CD	= f8 with constant(uar_get_code_by("MEANING",4002773,"STARTOBS")),protect ;006
declare ssn_var 		= f8 with noconstant(uar_get_code_by("DISPLAYKEY", 4, "SSN")) ,protect ;007
 
declare ageCalcMode		= i2 with noconstant(0),protect ;002
 
declare getAge(birth_dt_tm = dq8, birth_tz = i4) = vc ;002 ;005
 
 
;002
; set age calculation mode (0 - standard, 1 - based on discharge date)
if (post_doc_rec->disch_dt_tm > 0) ;003
	if ((post_doc_rec->disch_dt_tm between cnvtdatetime("01-JAN-1900 000000") and cnvtdatetime("01-JAN-2000 000000"))
		or (post_doc_rec->disch_dt_tm > sysdate))
 
		set ageCalcMode = 0
	else
		set ageCalcMode = 1
	endif
else
	set ageCalcMode = 0
endif
;
 
 
record addl_rec
(
    1 FacilityDesc = vc    ;Pulls the Description, rather than the Display (post_doc_rec->Facility)
    1 Patient_Disease_Alert = vc
    1 Observation_dt_tm = dq8 ;006

	1 Patient_DOB = dq8 ;008
    1 Patient_Age = vc ;007
    1 Patient_SSN = vc ;007 
    1 Ethnicity = vc ;001
 
    1 Guarantor_Religion = vc
    1 Guarantor_DOB = dq8 ;008
    1 Guarantor_Age = vc ;002
 
    1 NOK_Sex = vc
    1 NOK_DOB = dq8 ;008
    1 NOK_Age = vc ;002
 
    1 EMC_Sex = vc
    1 EMC_DOB = dq8 ;008
    1 EMC_Age = vc ;002
 
    1 Sub01_plan_reltn_id = f8
    1 Sub01_FIN_Class = vc
    1 Sub01_Group_Name = vc
    1 Sub01_Addr = vc
    1 Sub01_City = vc
    1 Sub01_State = vc
    1 Sub01_Zip = vc
    1 Sub01_HP_Group_Nbr = vc ;004
    1 Sub01_HP_Subs_Member_Nbr = vc ;009
    1 Sub01_HP_Member_Nbr = vc ;004
    1 Sub01_HP_Auth01_AuthCon = vc
    1 Sub01_DOB = dq8 ;008
    1 Sub01_Age = vc ;002
 
    1 Sub02_plan_reltn_id = f8
    1 Sub02_FIN_Class = vc
    1 Sub02_Group_Name = vc
    1 Sub02_Addr = vc
    1 Sub02_City = vc
    1 Sub02_State = vc
    1 Sub02_Zip = vc
    1 Sub02_HP_Group_Nbr = vc ;004
    1 Sub02_HP_Subs_Member_Nbr = vc ;009
    1 Sub02_HP_Member_Nbr = vc ;004
    1 Sub02_HP_Auth01_AuthCon = vc
    1 Sub02_DOB = dq8 ;008
    1 Sub02_Age = vc ;002
 
    1 Sub03_plan_reltn_id = f8
    1 Sub03_Group_Name = vc
    1 Sub03_FIN_Class = vc
    1 Sub03_Addr = vc
    1 Sub03_City = vc
    1 Sub03_State = vc
    1 Sub03_Zip = vc
    1 Sub03_HP_Group_Nbr = vc ;004
    1 Sub03_HP_Subs_Member_Nbr = vc ;009
    1 Sub03_HP_Member_Nbr = vc ;004
    1 Sub03_HP_Auth01_AuthCon = vc
    1 Sub03_DOB = dq8 ;008
    1 Sub03_Age = vc ;002
 
    1 printed_by = vc
    1 last_prsnl_updt_dt_tm = dq8
    1 last_prsnl_updt_name = vc
) with persistscript
 
 
;002 ;005
subroutine (getAge(birth_dt_tm = dq8(value), birth_tz = i4(value)) = vc)
	declare age = vc with noconstant(" ")
 
	if (ageCalcMode = 0)
		set age = cnvtage(cnvtdatetimeutc(datetimezone(birth_dt_tm, birth_tz), 1))
	else
		set age = cnvtage(cnvtdatetimeutc(datetimezone(birth_dt_tm, birth_tz), 1), post_doc_rec->disch_dt_tm, 0)
	endif
 
	return (age)
end
;
 
 
/*********************************************************************************
 *    Query for Patient Demographics                                             *
 *********************************************************************************/
SELECT INTO "NL:" ;001
FROM
    person p
PLAN p
    where p.person_id              = post_doc_rec->person_id
      and p.active_ind             = 1
      and p.beg_effective_dt_tm    <= cnvtdatetime(curdate, curtime3)
      and p.end_effective_dt_tm    >  cnvtdatetime(curdate, curtime3)
 
DETAIL
    addl_rec->Patient_DOB = cnvtdatetimeutc(datetimezone(p.birth_dt_tm, p.birth_tz), 1) ;008
    addl_rec->Patient_Age = trim(getAge(p.birth_dt_tm, p.birth_tz)) ;007
    addl_rec->Ethnicity = trim(uar_get_code_display(p.ethnic_grp_cd), 3)
 
WITH nocounter
 
 
/*********************************************************************************
 *    Query for Patient SSN                                                      *
 *********************************************************************************/
SELECT INTO "NL:" ;007
FROM
 	person_alias pa
PLAN pa
    where pa.person_id             = post_doc_rec->person_id
      and pa.person_alias_type_cd  = ssn_var
      and pa.active_ind            = 1
      and pa.beg_effective_dt_tm   <= cnvtdatetime(curdate, curtime3)
      and pa.end_effective_dt_tm   >  cnvtdatetime(curdate, curtime3)
 
DETAIL
 	addl_rec->Patient_SSN = cnvtalias(pa.alias, pa.alias_pool_cd, 4)
 
WITH nocounter
 
/*********************************************************************************
 *    Query for Patient Disease Alert                                            *
 *********************************************************************************/
SELECT INTO "NL:"
FROM
    person_patient pp
PLAN pp
    where pp.person_id              = post_doc_rec->person_id
      and pp.active_ind             = 1
      and pp.beg_effective_dt_tm   <= cnvtdatetime(curdate, curtime3)
      and pp.end_effective_dt_tm   >  cnvtdatetime(curdate, curtime3)
 
DETAIL
    addl_rec->Patient_Disease_Alert = uar_get_code_display(pp.disease_alert_cd)
 
WITH nocounter
 
/*********************************************************************************
 *    Query for Patient relationship details                                     *
 *********************************************************************************/
SELECT INTO "NL:"
FROM
    person_person_reltn ppr,
    person p
PLAN ppr
    where ppr.person_id             = post_doc_rec->person_id
      and ppr.active_ind            = 1
      and ppr.beg_effective_dt_tm  <= cnvtdatetime(curdate, curtime3)
      and ppr.end_effective_dt_tm  >  cnvtdatetime(curdate, curtime3)
JOIN p
    where p.person_id               = ppr.related_person_id
      and p.active_ind              = 1
      and p.beg_effective_dt_tm    <= cnvtdatetime(curdate, curtime3)
      and p.end_effective_dt_tm    >  cnvtdatetime(curdate, curtime3)
ORDER BY
    ppr.person_reltn_type_cd,
    ppr.priority_seq,
    ppr.internal_seq,
    cnvtdatetime(ppr.beg_effective_dt_tm),
    cnvtdatetime(ppr.end_effective_dt_tm)
HEAD ppr.person_reltn_type_cd
    IF (ppr.person_reltn_type_cd = dNOKCd)
        addl_rec->NOK_Sex = trim(uar_get_code_display(p.sex_cd),3)
        addl_rec->NOK_DOB = cnvtdatetimeutc(datetimezone(p.birth_dt_tm, p.birth_tz), 1) ;008
        addl_rec->NOK_Age = trim(getAge(p.birth_dt_tm, p.birth_tz)) ;002 ;005
 
    ELSEIF (ppr.person_reltn_type_cd = dEMCCd)
        addl_rec->EMC_Sex = trim(uar_get_code_display(p.sex_cd),3)
        addl_rec->EMC_DOB = cnvtdatetimeutc(datetimezone(p.birth_dt_tm, p.birth_tz), 1) ;008
        addl_rec->EMC_Age = trim(getAge(p.birth_dt_tm, p.birth_tz)) ;002 ;005
 
    ELSEIF (ppr.person_reltn_type_cd = dGuarantorCd) ; and ppr.priority_seq = 1) ;002
        addl_rec->Guarantor_Religion = trim(uar_get_code_display(p.religion_cd),3)
        addl_rec->Guarantor_DOB = cnvtdatetimeutc(datetimezone(p.birth_dt_tm, p.birth_tz), 1) ;008
        addl_rec->Guarantor_Age = trim(getAge(p.birth_dt_tm, p.birth_tz)) ;002 ;005
 
    ENDIF
 
WITH nocounter
 
/*********************************************************************************
 *    Query for Patient encounter details, last update personnel                 *
 *********************************************************************************/
SELECT INTO "NL:"
FROM
    encounter e
    ,prsnl p
PLAN e
    where e.encntr_id = post_doc_rec->encntr_id
JOIN p
    where p.person_id = e.updt_id
DETAIL
    addl_rec->FacilityDesc = uar_get_code_description(e.loc_facility_cd)
    addl_rec->last_prsnl_updt_dt_tm = e.updt_dt_tm
    addl_rec->last_prsnl_updt_name = p.name_full_formatted
 
WITH nocounter
 

/*********************************************************************************
 *    Query for Patient event details                                            *
 *********************************************************************************/
;006
SELECT INTO "NL:"
	event_dt_tm = max(pe.event_dt_tm) over(partition by pe.encntr_id)
FROM
    patient_event pe
PLAN pe
    where pe.encntr_id = post_doc_rec->encntr_id
	and pe.event_type_cd = EVENT_TYPE_CD
DETAIL
    addl_rec->Observation_dt_tm = event_dt_tm
 
WITH nocounter
 
 
/*********************************************************************************
 *    Get Encounter Financial Class, Insurers Address                            *
 *********************************************************************************/
SELECT INTO "NL:"
 
FROM
    encntr_plan_reltn  r
    ,encntr_person_reltn  epr
    ,person  p
    ,health_plan  hp
    ,address  a
PLAN r
    where r.encntr_id               = post_doc_rec->encntr_id
      and r.active_ind              = 1
      and r.beg_effective_dt_tm    <= cnvtdatetime(curdate, curtime3)
      and r.end_effective_dt_tm    >  cnvtdatetime(curdate, curtime3)
JOIN epr
    where epr.encntr_id             = r.encntr_id
      and epr.related_person_id     = r.person_id
      and epr.person_reltn_type_cd  = INSURED_CD
      and epr.active_ind            = 1
      and epr.beg_effective_dt_tm  <= cnvtdatetime(curdate, curtime3)
      and epr.end_effective_dt_tm  >  cnvtdatetime(curdate, curtime3)
JOIN p
    where p.person_id   = epr.related_person_id
      and p.active_ind  = 1
JOIN hp
    where hp.health_plan_id = r.health_plan_id
JOIN a
    where a.parent_entity_id        = r.encntr_plan_reltn_id
      and a.parent_entity_name      = "ENCNTR_PLAN_RELTN"
      and a.address_type_cd         = ADDR_BUS_CD
      and a.active_ind              = 1
      and a.beg_effective_dt_tm    <= cnvtdatetime(curdate, curtime3)
      and a.end_effective_dt_tm    >  cnvtdatetime(curdate, curtime3)
 
ORDER BY
    r.priority_seq,
    cnvtdatetime(r.beg_effective_dt_tm) desc,
    epr.priority_seq,
    epr.internal_seq,
    cnvtdatetime(epr.beg_effective_dt_tm) desc,
    cnvtdatetime(epr.end_effective_dt_tm) desc
    ,a.address_type_seq
    ,cnvtdatetime(a.beg_effective_dt_tm) desc
    ,cnvtdatetime(a.end_effective_dt_tm) desc
 
HEAD r.priority_seq
    if (r.priority_seq = 1)
        dSub01PPRId = r.person_plan_reltn_id
        dSub01EPRId = r.encntr_plan_reltn_id
 
        addl_rec->Sub01_FIN_Class = uar_get_code_display(hp.financial_class_cd)
        addl_rec->Sub01_Group_Name = r.group_name
        addl_rec->Sub01_Addr = build2(a.street_addr)
        addl_rec->Sub01_Zip = trim(a.zipcode)
        addl_rec->Sub01_City = trim(a.city)
 
        if (a.state_cd > 0)
          addl_rec->Sub01_State = uar_get_code_display(a.state_cd)
        else
          addl_rec->Sub01_State = trim(a.state)
        endif
 
        addl_rec->Sub01_HP_Group_Nbr = r.group_nbr ;004
        addl_rec->Sub01_HP_Subs_Member_Nbr = r.subs_member_nbr ;009
        addl_rec->Sub01_HP_Member_Nbr = r.member_nbr ;004
        addl_rec->Sub01_DOB = cnvtdatetimeutc(datetimezone(p.birth_dt_tm, p.birth_tz), 1) ;008
        addl_rec->Sub01_Age = trim(getAge(p.birth_dt_tm, p.birth_tz)) ;002 ;005
 
    elseif (r.priority_seq = 2)
        dSub02PPRId = r.person_plan_reltn_id
        dSub02EPRId = r.encntr_plan_reltn_id
 
        addl_rec->Sub02_FIN_Class = uar_get_code_display(hp.financial_class_cd)
        addl_rec->Sub02_Group_Name = r.group_name
        addl_rec->Sub02_Addr = build2(a.street_addr)
        addl_rec->Sub02_Zip = trim(a.zipcode)
        addl_rec->Sub02_City = trim(a.city)
 
        if (a.state_cd > 0)
          addl_rec->Sub02_State = uar_get_code_display(a.state_cd)
        else
          addl_rec->Sub02_State = trim(a.state)
        endif
 
        addl_rec->Sub02_HP_Group_Nbr = r.group_nbr ;004
        addl_rec->Sub02_HP_Subs_Member_Nbr = r.subs_member_nbr ;009
        addl_rec->Sub02_HP_Member_Nbr = r.member_nbr ;004
        addl_rec->Sub02_DOB = cnvtdatetimeutc(datetimezone(p.birth_dt_tm, p.birth_tz), 1) ;008
        addl_rec->Sub02_Age = trim(getAge(p.birth_dt_tm, p.birth_tz)) ;002 ;005
 
    elseif (r.priority_seq = 3)
        dSub03PPRId = r.person_plan_reltn_id
        dSub03EPRId = r.encntr_plan_reltn_id
 
        addl_rec->Sub03_FIN_Class = uar_get_code_display(hp.financial_class_cd)
        addl_rec->Sub03_Group_Name = r.group_name
        addl_rec->Sub03_Addr = build2(a.street_addr)
        addl_rec->Sub03_Zip = trim(a.zipcode)
        addl_rec->Sub03_City = trim(a.city)
 
        if (a.state_cd > 0)
          addl_rec->Sub03_State = uar_get_code_display(a.state_cd)
        else
          addl_rec->Sub03_State = trim(a.state)
        endif
 
        addl_rec->Sub03_HP_Group_Nbr = r.group_nbr ;004
        addl_rec->Sub03_HP_Subs_Member_Nbr = r.subs_member_nbr ;009
        addl_rec->Sub03_HP_Member_Nbr = r.member_nbr ;004
        addl_rec->Sub03_DOB = cnvtdatetimeutc(datetimezone(p.birth_dt_tm, p.birth_tz), 1) ;008
        addl_rec->Sub03_Age = trim(getAge(p.birth_dt_tm, p.birth_tz)) ;002 ;005
    endif
 
FOOT r.priority_seq
    NULL
 
WITH nocounter
 
/*********************************************************************************
 *    Encounter financial class could not be retrieved, now try person level     *
 *********************************************************************************/
IF ((textlen(trim(addl_rec->Sub01_FIN_Class,3)) = 0)
 OR (textlen(trim(addl_rec->Sub02_FIN_Class,3)) = 0)
 OR (textlen(trim(addl_rec->Sub03_FIN_Class,3)) = 0))
 
    select into "nl:"
 
    from
        person_plan_reltn r
        , person_person_reltn ppr
        , health_plan hp
 
    plan r
        where r.person_id               = post_doc_rec->person_id
          and r.beg_effective_dt_tm    <= cnvtdatetime(curdate, curtime3)
          and r.end_effective_dt_tm    >  cnvtdatetime(curdate, curtime3)
          and r.active_ind              = 1
    join ppr
        where ppr.related_person_id     = outerjoin(r.subscriber_person_id)
          and ppr.person_reltn_type_cd  = outerjoin(INSURED_CD)
          and ppr.active_ind            = outerjoin(1)
          and ppr.beg_effective_dt_tm  <= outerjoin(cnvtdatetime(curdate, curtime3))
          and ppr.end_effective_dt_tm  >  outerjoin(cnvtdatetime(curdate, curtime3))
    join hp
        where hp.health_plan_id = outerjoin(r.health_plan_id)
 
    order by
        r.priority_seq,
        r.beg_effective_dt_tm desc,
        ppr.priority_seq,
        ppr.internal_seq,
        ppr.beg_effective_dt_tm desc,
        ppr.end_effective_dt_tm desc
 
    head r.priority_seq
        if (r.priority_seq = 1 and size(trim(addl_rec->Sub01_FIN_Class,3)) = 0)
            dSub01PPRId = r.person_plan_reltn_id
            addl_rec->Sub01_FIN_Class = uar_get_code_display(hp.financial_class_cd)
        elseif (r.priority_seq = 2 and size(trim(addl_rec->Sub02_FIN_Class,3)) = 0)
            dSub02PPRId = r.person_plan_reltn_id
            addl_rec->Sub02_FIN_Class = uar_get_code_display(hp.financial_class_cd)
        elseif (r.priority_seq = 3 and size(trim(addl_rec->Sub03_FIN_Class,3)) = 0)
            dSub03PPRId = r.person_plan_reltn_id
            addl_rec->Sub03_FIN_Class = uar_get_code_display(hp.financial_class_cd)
        endif
 
    foot r.priority_seq
        NULL
 
    with nocounter
ENDIF
 
/*********************************************************************************
 *    Determine Subscribers                                                      *
 *********************************************************************************/
IF (post_doc_rec->encntr_id > 0.0)
    set addl_rec->Sub01_plan_reltn_id = dSub01EPRId
    set addl_rec->Sub02_plan_reltn_id = dSub02EPRId
    set addl_rec->Sub03_plan_reltn_id = dSub03EPRId
ELSE
    set addl_rec->Sub01_plan_reltn_id = dSub01PPRId
    set addl_rec->Sub02_plan_reltn_id = dSub02PPRId
    set addl_rec->Sub03_plan_reltn_id = dSub03PPRId
ENDIF
 
/*********************************************************************************
 *    Get Insurance Authorization Details                                        *
 *********************************************************************************/
SELECT INTO "NL:"
    ad.auth_detail_id
FROM
    encntr_plan_auth_r epa,
    authorization auth,
    auth_detail ad
PLAN epa
    where epa.encntr_plan_reltn_id in (addl_rec->Sub01_plan_reltn_id,
                                       addl_rec->Sub02_plan_reltn_id,
                                       addl_rec->Sub03_plan_reltn_id)
      and epa.encntr_plan_reltn_id+0 > 0.0
      and epa.active_ind            = 1
      and epa.beg_effective_dt_tm  <= cnvtdatetime(curdate, curtime3)
      and epa.end_effective_dt_tm  >  cnvtdatetime(curdate, curtime3)
JOIN auth
    where auth.authorization_id     = epa.authorization_id
      and auth.active_ind           = 1
JOIN ad
    where ad.authorization_id       = auth.authorization_id
      and ad.authorization_id+0     > 0.0
      and ad.active_ind             = 1
      and ad.beg_effective_dt_tm   <= cnvtdatetime(curdate, curtime3)
      and ad.end_effective_dt_tm   >  cnvtdatetime(curdate, curtime3)
ORDER BY
    auth.authorization_id,
    cnvtdatetime(auth.beg_effective_dt_tm),
    cnvtdatetime(ad.beg_effective_dt_tm)
 
HEAD epa.encntr_plan_reltn_id
    case(epa.encntr_plan_reltn_id)
      of addl_rec->Sub01_plan_reltn_id :
        addl_rec->Sub01_HP_Auth01_AuthCon = trim(ad.auth_contact,3)
      of addl_rec->Sub02_plan_reltn_id :
        addl_rec->Sub02_HP_Auth01_AuthCon = trim(ad.auth_contact,3)
      of addl_rec->Sub03_plan_reltn_id :
        addl_rec->Sub03_HP_Auth01_AuthCon = trim(ad.auth_contact,3)
    endcase
 
WITH nocounter
 
/*********************************************************************************
 *    Query for Printed By Personnel                                             *
 *********************************************************************************/
select into "nl:"
 
from prsnl p where p.person_id = reqinfo->updt_id
 
detail
    addl_rec->printed_by = p.name_full_formatted
 
with nocounter
 
/*********************************************************************************/
;IF(bDebug)
;    call echorecord(addl_rec)
;ENDIF
 
set last_mod = "003  06/22/12  MW017700"
end
go
