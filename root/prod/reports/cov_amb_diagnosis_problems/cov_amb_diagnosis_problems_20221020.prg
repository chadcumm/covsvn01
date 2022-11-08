/*********************************************************************************
Author          :	Dawn Greer, DBA
Date Written	:	05/28/2021
Program Title	:	cov_amb_diagnosis_problems
Source File     :	cov_amb_diagnosis_problems.prg
Object Name     :	cov_amb_diagnosis_problems
Directory       :	cust_script
 
Purpose         : 	Ambulatory Diagnosis and Problems
 
 
Mod     Date        Engineer                Comment
----    ----------- ----------------------- ---------------------------------------
001     05/28/2021  Dawn Greer, DBA         Original Release - CR 6334
002     10/19/2022  Steve Czubek            CR 13738 rewrite for performance,
                                            and eprpr.priority_seq in (1, 0)
************************************************************************************/
drop program cov_amb_diagnosis_problems go
create program cov_amb_diagnosis_problems
 
prompt
	"Output to File/Printer/MINE" = "MINE"        ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 0
	, "Select Provider" = VALUE(0.0           )
	, "Select Appt Begin Date" = "SYSDATE"
	, "Seelct Appt End Date" = "SYSDATE"
	, "Select Summary or Detail" = 0
 
with OUTDEV, FAC, PROV, BDATE, EDATE, SUMDET
 
FREE RECORD a
RECORD a
(
	1	rec_cnt		=	i4
	1	qual[*]
	    2 encntr_id = f8
	    2 person_id = f8
		2	facility		=	vc
		2	provider		=	vc
		2	patient 		=	vc
		2	dob				=	c10
		2	insurance		=	c50
		2   cmrn            =   c20
		2	fin				=	c20
		2   enc_date        =   c25
		2   diag_prob_code  =   c300
		2   diag_prob_desc  =   c500
		2   thisvisit       =   c20
		2   chronic         =   c20
		2   priority        = 	i4
)
 
 
FREE RECORD rpt_data
RECORD rpt_data
(
	1	rec_cnt		=	i4
	1	qual[*]
	    2 encntr_id = f8
	    2 person_id = f8
		2	facility		=	vc
		2	provider		=	vc
		2	patient 		=	vc
		2	dob				=	c10
		2	insurance		=	c50
		2   cmrn            =   c20
		2	fin				=	c20
		2   enc_date        =   c25
		2   diag_prob_code  =   c300
		2   diag_prob_desc  =   c500
		2   thisvisit       =   c20
		2   chronic         =   c20
		2   priority        = 	i4
)
 
 
FREE RECORD totals
RECORD totals
(
	1 rec_cnt = i4
	1 new_rec_cnt = i4
	1 totaldiagcnt = i4
	1 qual[*]
		2 facility 		= c300
		2 provider 		= c300
		2 diag_prob_code = c300
		2 diag_prob_desc = c500
		2 total_counts	= i4
)
 
 
FREE RECORD prompts
RECORD prompts
(
	1	rec_cnt	=	i4
	1   p_facility = c300
	1   p_provider = c300
	1   p_bdate = vc
	1   p_edate = vc
	1   p_sumdet = c20
)
 
DECLARE fac_opr_var = c2
DECLARE prov_opr_var = c2
DECLARE facnamelist = vc with protect, noconstant(" ")
DECLARE facprompt = vc with protect, noconstant(" ")
DECLARE num = i4
DECLARE facitem = vc with protect, noconstant(" ")
DECLARE provlist = c6000
DECLARE provnamelist = c6000
DECLARE provprompt = vc with protect, noconstant(" ")
DECLARE prov_num = i4
DECLARE provitem = vc with protect, noconstant(" ")
declare faclist = vc with protect, noconstant(" ")
declare cnt = i4 with protect, noconstant(0)
declare r_cnt = i4 with protect, noconstant(0)
declare idx = i4 with protect, noconstant(0)
declare idx2 = i4 with protect, noconstant(0)
declare idx3 = i4 with protect, noconstant(0)
declare idx4 = i4 with protect, noconstant(0)
declare add_ind = i4 with protect, noconstant(0)
declare start = i4 with protect, noconstant(0)
declare pos = i4 with protect, noconstant(0)
declare pos2 = i4 with protect, noconstant(0)
declare s_cnt = i4 with protect, noconstant(0)
/**********************************************************
Get CMG Facility Data
***********************************************************/
CALL ECHO ("Get Facility Prompt Data")
 
;Pulling the CMG List for when Any is selected in the Prompt
SELECT facnum = CNVTSTRING(cvfac.CODE_VALUE)
FROM CODE_VALUE cvfac, CODE_VALUE_EXTENSION CVE
WHERE cvfac.CODE_VALUE = CVE.CODE_VALUE
AND cvfac.CODE_SET = 220
AND cvfac.ACTIVE_IND = 1
AND cvfac.CDF_MEANING = 'FACILITY'
AND CVE.FIELD_NAME = 'CMG Reporting'
 
HEAD REPORT
	faclist = FILLSTRING(2000,' ')
 	faclist = '('
DETAIL
	faclist = BUILD(BUILD(faclist, facnum), ', ')
 
FOOT REPORT
	faclist = BUILD(faclist,')')
	faclist = REPLACE(faclist,',','',2)
 
WITH nocounter
 
 
 
;Facility Prompt
IF(SUBSTRING(1,1,REFLECT(PARAMETER(PARAMETER2($FAC),0))) = "L")		;multiple options selected
	SET fac_opr_var = "IN"
	SET facprompt = '('
	SET num = CNVTINT(SUBSTRING(2,2,REFLECT(PARAMETER(PARAMETER2($FAC),0))))
 
	FOR (i = 1 TO num)
		SET facitem = CNVTSTRING(PARAMETER(PARAMETER2($FAC),i))
		SET facprompt = BUILD(facprompt,facitem)
		IF (i != num)
			SET facprompt = BUILD(facprompt, ",")
		ENDIF
	ENDFOR
	SET facprompt = BUILD(facprompt, ")")
	SET facprompt = BUILD("cvfac.code_value IN ",facprompt)
 
ELSEIF(PARAMETER(PARAMETER2($FAC),1)=0.0)  ;any was selected
	SET fac_opr_var = "IN"
	SET facprompt = "1=1";BUILD("cvfac.code_value IN ", faclist)
ELSE 	;single value selected
	SET fac_opr_var = "="
	SET facitem = CNVTSTRING(PARAMETER(PARAMETER2($FAC),1))
	SET facprompt = BUILD("cvfac.code_value = ", facitem)
ENDIF
 
; Get Facility prompt data selected
SELECT facname = TRIM(cvfac.description),
facnum = CNVTSTRING(cvfac.CODE_VALUE)
FROM CODE_VALUE cvfac, CODE_VALUE_EXTENSION CVE
WHERE cvfac.CODE_VALUE = CVE.CODE_VALUE
AND cvfac.CODE_SET = 220
AND cvfac.ACTIVE_IND = 1
AND cvfac.CDF_MEANING = 'FACILITY'
AND CVE.FIELD_NAME = 'CMG Reporting'
AND PARSER(facprompt)
 
 
HEAD REPORT
	facnamelist = FILLSTRING(2000,' ')
 
DETAIL
	facnamelist = BUILD(BUILD(facnamelist, facname), ', ')
 
FOOT REPORT
	facnamelist = REPLACE(facnamelist,',','',2)
	prompts->p_facility = EVALUATE2(IF(PARAMETER(PARAMETER2($FAC),1) = 0.0) "Facilities: All"
		ELSEIF (SUBSTRING(1,1,REFLECT(parameter(parameter2($FAC),0))) = "L") CONCAT("Facilities: ",TRIM(facnamelist,3))
		ELSE CONCAT("Facilities: ",TRIM(facname,3)) ENDIF)
	prompts->rec_cnt = 1
 
WITH nocounter
 
/**********************************************************
Get Provider Data
***********************************************************/
CALL ECHO ("Get Provider Prompt Data")
 
SELECT provnum = CNVTINT(prov.person_id)
FROM PRSNL prov
WHERE prov.physician_ind = 1
AND prov.active_ind = 1
AND prov.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
AND prov.data_status_cd = 25.00 /*Auth*/
 
HEAD REPORT
	provlist = FILLSTRING(2000,' ')
 	provlist = '('
DETAIL
	provlist = BUILD(BUILD(provlist, provnum), ', ')
 
FOOT REPORT
	provlist = BUILD(provlist,')')
	provlist = REPLACE(provlist,',','',2)
 
WITH nocounter
 
;Provider Prompt
IF(SUBSTRING(1,1,REFLECT(PARAMETER(PARAMETER2($PROV),0))) = "L")		;multiple options selected
	SET provprompt = '('
	SET prov_num = CNVTINT(SUBSTRING(2,2,REFLECT(PARAMETER(PARAMETER2($PROV),0))))
 
	FOR (i = 1 TO prov_num)
		SET provitem = CNVTSTRING(PARAMETER(PARAMETER2($PROV),i))
		SET provprompt = BUILD(provprompt,provitem)
		IF (i != prov_num)
			SET provprompt = BUILD(provprompt, ", ")
		ENDIF
	ENDFOR
	SET provprompt = BUILD(provprompt, ")")
	SET provprompt = BUILD("prov.person_id IN ",provprompt)
 
ELSEIF(PARAMETER(PARAMETER2($PROV),1)=0.0)  ;any was selected
	SET provprompt = "1=1"
 
ELSE 	;single value selected
	SET provitem = CNVTSTRING(PARAMETER(PARAMETER2($PROV),1))
	SET provprompt = BUILD("prov.person_id = ", provitem)
 
ENDIF
 
; Get Provider prompt data selected
SELECT provname = TRIM(prov.name_full_formatted,3),
provnum = prov.person_id
FROM PRSNL prov
WHERE prov.physician_ind = 1
AND prov.active_ind = 1
AND prov.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
AND prov.data_status_cd = 25.00 /*Auth*/
AND PARSER(provprompt)
ORDER BY provname
 
HEAD REPORT
	provnamelist = FILLSTRING(2000,' ')
 
DETAIL
	provnamelist = BUILD(BUILD(provnamelist, provname), ', ')
 
FOOT REPORT
	provnamelist = REPLACE(provnamelist,',','',2)
	prompts->p_provider = EVALUATE2(IF(PARAMETER(PARAMETER2($PROV),1) = 0.0) "Providers: All"
		ELSEIF (SUBSTRING(1,1,REFLECT(parameter(parameter2($PROV),0))) = "L") CONCAT("Providers: ",TRIM(provnamelist,3))
		ELSE CONCAT("Providers: ",TRIM(provname,3)) ENDIF)
 
WITH nocounter
 
/**************************************************************
; Other Prompts
**************************************************************/
 
SELECT INTO "NL:"
FROM DUMMYT d
 
HEAD REPORT
	prompts->p_bdate = CONCAT("Begin: ", FORMAT(CNVTDATE2($bdate, "dd-mmm-yyyy hh:mm:ss"), "MM/DD/YYYY;;d"), " 00:00")
	prompts->p_edate = CONCAT("End: ", FORMAT(CNVTDATE2($edate, "dd-mmm-yyyy hh:mm:ss"), "MM/DD/YYYY;;d"), " 23:59")
	prompts->p_sumdet = CONCAT("Type: ", EVALUATE(CNVTSTRING($sumdet), "0", "Summary", "1", "Detail"))
WITH nocounter
 
/**********************************************************
Get Encounters and Demographics for visits
***********************************************************/
CALL ECHO ("Get Diagnosis Data - This Visit/Chronic")
 
 
SELECT into "nl:"
  Patient = pat.name_full_formatted
  ,DOB = FORMAT(CNVTDATETIMEUTC(pat.birth_dt_tm,1),"MM/DD/YYYY;;d")
  ,Insurance = TRIM(ins.org_name,3)
  ,FIN = TRIM(ea.alias,3)
  ,Enc_Date = FORMAT(enc.reg_dt_tm, "MM/DD/YYYY hh:mm")
  ,Provider = TRIM(prov.name_full_formatted,3)
  ,Facility = uar_get_code_display(enc.loc_facility_cd)
  ,This_Visit_Flag = 'This Visit'
  ,Chronic_Flag = 'Chronic'
FROM
    PERSON pat
    ,ENCOUNTER enc
    ,ENCNTR_ALIAS ea
    ,CODE_VALUE cvfac
    ,CODE_VALUE_EXTENSION cvfaccve
    ,ENCNTR_PRSNL_RELTN eprpr
    ,PRSNL prov
    ,ENCNTR_PLAN_RELTN epr
    ,ORGANIZATION ins
plan enc
    where enc.reg_dt_tm BETWEEN CNVTDATETIME($bdate) AND CNVTDATETIME($edate)
    and enc.active_ind = 1
join pat
    where pat.person_id = enc.person_id
AND pat.name_last_key NOT IN ('FFFFPEDS','FFFFAMB','FFFFPNRC','FFFFOP','FFFFED','FFFFIP','FFFFWH','FFFFTEST','FFFFREVCYCLE',
	'FFFFPHARM','ZZGLOVER','ZZTEST','ZZWICK','ZZBOGUS','ZZZZTESTPW','ZZZREGRESSION','ZZZZBHTEST','ZZZNEUROPW','ZZZFLMCRAD',
	'ZZZFSRRAD','ZZZTESTONE','ZZZAMB','ZZZPWRAD','ZZTOPTEST','ZZZ','ZZZRMCRAD','ZZZZTESTPBH','ZZMDDONOTUSE','ZZZMPITESTP',
	'ZZZRADTEST','ZZZFSRGO','ZZZFSWRAD','ZZZTESTIP','ZZZTEST','ZZELLMER','ZZZMPITESTBL','ZZZZTESTPOC','ZZZZZZTEST','ZZZTESTOP',
	'TTTTTEST','TTTTGENLAB','TTTT','TTTTMAYO','TTTTPHARMTEST','TTTTESTFSV','TTTTONC','TTTTESTCATHLAB','TTURNER','TTEST',
	'TTTTHUDLOW','TTTTTESTFN','TTTTCAMCAPTEST',	'TTTTMDI','TTBACKLOADING','TTTTESTPRVL','TTTTMMC','TTTTQUEST','TTHOMASON',
	'TTTTPRINTER','TTTTEST')
JOIN ea
    where ea.encntr_id = enc.encntr_id
    AND ea.active_ind = 1
    AND ea.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND ea.encntr_alias_type_cd = 1077  /*FIN NBR*/
JOIN cvfac
    where cvfac.code_value = enc.loc_facility_cd
    AND PARSER(facprompt)
  		AND cvfac.code_set = 220
		AND cvfac.cdf_meaning = "FACILITY"
  		AND cvfac.active_ind = 1
JOIN cvfaccve
    where cvfaccve.code_value = cvfac.code_value
  	AND cvfaccve.field_name = "CMG Reporting"
 
JOIN eprpr
    where enc.encntr_id = eprpr.encntr_id
		AND eprpr.priority_seq in (1, 0)
		AND eprpr.encntr_prsnl_r_cd IN (1116 /*Admitting*/,1119 /*Attending*/,681283 /*NP*/,681284/*PA*/)
		AND eprpr.active_ind = 1
		AND eprpr.data_status_cd = 25.00 /* Auth Verified */
		AND eprpr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
		AND eprpr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
 
 
JOIN prov
    where prov.person_id = eprpr.prsnl_person_id
		AND prov.physician_ind = 1
		AND prov.active_ind = 1
		AND prov.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
		AND prov.data_status_cd = 25.00 /*Auth*/
		AND PARSER(provprompt)
JOIN epr
    where epr.encntr_id = outerjoin(enc.encntr_id)
  	AND epr.priority_seq = outerjoin(1)
  	AND epr.active_ind = outerjoin(1)
JOIN ins
    where ins.organization_id = outerjoin(epr.organization_id)
  	AND ins.active_ind = outerjoin(1)
order
    enc.encntr_id
 
HEAD REPORT
	cnt = 0
 
head enc.encntr_id
	IF (mod(cnt,100) = 0)
		stat = alterlist(a->qual, cnt + 100)
	ENDIF
    cnt = cnt + 1
    a->qual[cnt].person_id      =   enc.person_id
    a->qual[cnt].encntr_id      =   enc.encntr_id
	a->qual[cnt].patient 		= 	patient
	a->qual[cnt].dob			= 	FORMAT(dob, "MM/DD/YYYY")
	a->qual[cnt].insurance		=	insurance
	a->qual[cnt].fin			= 	fin
	a->qual[cnt].enc_date       =   enc_date
	a->qual[cnt].provider		=	TRIM(prov.name_full_formatted,3)
	a->qual[cnt].facility		=	uar_get_code_display(enc.loc_facility_cd)
 
FOOT REPORT
	stat = alterlist(a->qual, cnt )
WITH orahintcbo("index(enc xie5encounter)")
 
 
/**********************************************************
Get Diagnosis Data - This Visit/Chronic and non-Chronic
***********************************************************/
 
select into "nl:"
from
    DIAGNOSIS diag
    ,NOMENCLATURE nom
    ,PROBLEM prob
plan diag
    where expand(idx, 1, size(a->qual, 5), diag.encntr_id, a->qual[idx].encntr_id)
  	AND diag.active_ind = 1
  	and diag.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
JOIN nom
    where nom.nomenclature_id = diag.nomenclature_id
  	AND nom.active_ind = 1
JOIN prob
    where prob.originating_nomenclature_id = outerjoin(diag.originating_nomenclature_id)
  	AND prob.person_id = outerjoin(diag.person_id)
  	and prob.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime))
  	and prob.active_ind = outerjoin(1)
order
    diag.diagnosis_id
head diag.diagnosis_id
 
	IF (mod(r_cnt,100) = 0)
		stat = alterlist(rpt_data->qual, r_cnt + 100)
	ENDIF
    r_cnt = r_cnt + 1
    ;;; each encntr_id in a->qual is unique
    pos = locateval(idx, 1, size(a->qual, 5), diag.encntr_id, a->qual[idx].encntr_id)
    rpt_data->qual[r_cnt].encntr_id = a->qual[pos].encntr_id
    rpt_data->qual[r_cnt].person_id = a->qual[pos].person_id
	rpt_data->qual[r_cnt].patient = a->qual[pos].patient
	rpt_data->qual[r_cnt].dob = a->qual[pos].dob
	rpt_data->qual[r_cnt].insurance = a->qual[pos].insurance
	rpt_data->qual[r_cnt].fin = a->qual[pos].fin
	rpt_data->qual[r_cnt].enc_date = a->qual[pos].enc_date
	rpt_data->qual[r_cnt].provider = a->qual[pos].provider
	rpt_data->qual[r_cnt].facility = a->qual[pos].facility
	rpt_data->qual[r_cnt].diag_prob_code =
	               CONCAT(TRIM(nom.source_identifier,3), '(', TRIM(UAR_GET_CODE_DISPLAY(nom.source_vocabulary_cd),3),')')
	rpt_data->qual[r_cnt].diag_prob_desc =  TRIM(diag.diagnosis_display,3)
	rpt_data->qual[r_cnt].thisvisit = "This Visit"
 
if (prob.problem_id > 0)
	rpt_data->qual[r_cnt].chronic = "Chronic"
else
    rpt_data->qual[r_cnt].chronic = ""
endif
	rpt_data->qual[r_cnt].priority       =   diag.clinical_diag_priority
 
WITH expand = 2
 
/**********************************************************
Get Problem Data - Chronic
***********************************************************/
 
select into "nl:"
from
    DIAGNOSIS diag
    ,NOMENCLATURE nom
    ,PROBLEM prob
plan prob
    where expand(idx, 1, size(a->qual, 5), prob.person_id, a->qual[idx].person_id)
  	and prob.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
  	and prob.active_ind = 1
  	AND prob.cancel_reason_cd = 0.00
JOIN nom
    where nom.nomenclature_id = prob.nomenclature_id
  	AND nom.active_ind = 1
JOIN diag
    where diag.originating_nomenclature_id = prob.originating_nomenclature_id
    and diag.person_id = prob.person_id
  	AND diag.active_ind = 1
  	and diag.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
order
    prob.problem_id
    ,diag.encntr_id
head prob.problem_id
    add_ind = 1
head diag.encntr_id
    if (locateval(idx3, 1, size(a->qual, 5), diag.encntr_id, a->qual[idx3].encntr_id) > 0)
        add_ind = 0
    endif
foot prob.problem_id
    if (add_ind = 1)
 
    pos = locateval(idx4, 1, size(a->qual, 5), prob.person_id, a->qual[idx4].person_id)
	IF (mod(r_cnt,100) = 0)
		stat = alterlist(rpt_data->qual, r_cnt + 100)
	ENDIF
    r_cnt = r_cnt + 1
    rpt_data->qual[r_cnt].encntr_id = a->qual[pos].encntr_id
    rpt_data->qual[r_cnt].person_id = a->qual[pos].person_id
	rpt_data->qual[r_cnt].patient = a->qual[pos].patient
	rpt_data->qual[r_cnt].dob = a->qual[pos].dob
	rpt_data->qual[r_cnt].insurance = a->qual[pos].insurance
	rpt_data->qual[r_cnt].fin = a->qual[pos].fin
	rpt_data->qual[r_cnt].enc_date = a->qual[pos].enc_date
	rpt_data->qual[r_cnt].provider = a->qual[pos].provider
	rpt_data->qual[r_cnt].facility = a->qual[pos].facility
	rpt_data->qual[r_cnt].diag_prob_code =
	               CONCAT(TRIM(nom.source_identifier,3), '(', TRIM(UAR_GET_CODE_DISPLAY(nom.source_vocabulary_cd),3),')')
	rpt_data->qual[r_cnt].diag_prob_desc =  TRIM(prob.annotated_display,3)
	rpt_data->qual[r_cnt].thisvisit = ""
	rpt_data->qual[r_cnt].chronic = "Chronic"
	rpt_data->qual[r_cnt].priority       =   99
 
	pos2 = pos
    while (locateval(idx2, pos2 + 1, size(a->qual, 5), prob.person_id, a->qual[idx2].person_id) > 0)
    pos2 = locateval(idx2, pos2 + 1, size(a->qual, 5), prob.person_id, a->qual[idx2].person_id)
	IF (mod(r_cnt,100) = 0)
		stat = alterlist(rpt_data->qual, r_cnt + 100)
	ENDIF
    r_cnt = r_cnt + 1
    rpt_data->qual[r_cnt].encntr_id = a->qual[pos].encntr_id
    rpt_data->qual[r_cnt].person_id = a->qual[pos].person_id
	rpt_data->qual[r_cnt].patient = a->qual[pos].patient
	rpt_data->qual[r_cnt].dob = a->qual[pos].dob
	rpt_data->qual[r_cnt].insurance = a->qual[pos].insurance
	rpt_data->qual[r_cnt].fin = a->qual[pos].fin
	rpt_data->qual[r_cnt].enc_date = a->qual[pos].enc_date
	rpt_data->qual[r_cnt].provider = a->qual[pos].provider
	rpt_data->qual[r_cnt].facility = a->qual[pos].facility
	rpt_data->qual[r_cnt].diag_prob_code =
	               CONCAT(TRIM(nom.source_identifier,3), '(', TRIM(UAR_GET_CODE_DISPLAY(nom.source_vocabulary_cd),3),')')
	rpt_data->qual[r_cnt].diag_prob_desc =  TRIM(prob.annotated_display,3)
	rpt_data->qual[r_cnt].thisvisit = ""
	rpt_data->qual[r_cnt].chronic = "Chronic"
	rpt_data->qual[r_cnt].priority       =   99
	endwhile
endif
WITH expand = 2
set stat = alterlist(rpt_data->qual, r_cnt )
 
#out_put
 
IF (size(rpt_data->qual, 5) > 0)  ; If no data skip to end
	/*********************************************************************
		Summary
	**********************************************************************/
	/*Diagnosis/Problem Totals*/
	CALL ECHO("Diagnosis/Problem Totals")
	SELECT INTO 'nl:'
		Facility = rpt_data->qual[d.seq].facility
		,Provider = rpt_data->qual[d.seq].provider
		,Diag_prob_code = rpt_data->qual[d.seq].diag_prob_code
		,Diag_prob_desc = rpt_data->qual[d.seq].Diag_prob_desc
		FROM (dummyt d WITH seq = SIZE(rpt_data->qual,5))
		PLAN d
		ORDER BY Facility, Provider, Diag_Prob_Code, Diag_Prob_Desc
 
	HEAD REPORT
        cnt = 0
	DETAIL
		if (mod(cnt, 100) = 0)
		  stat = alterlist(totals->qual, cnt + 100)
		endif
    if (cnt = 0)
        cnt = cnt + 1
        totals->qual[cnt].total_counts = totals->qual[cnt].total_counts + 1
        totals->qual[cnt].facility = rpt_data->qual[d.seq].facility
		totals->qual[cnt].provider	= rpt_data->qual[d.seq].provider
		totals->qual[cnt].diag_prob_code = rpt_data->qual[d.seq].diag_prob_code
		totals->qual[cnt].diag_prob_desc = rpt_data->qual[d.seq].Diag_prob_desc
    elseif (
        totals->qual[cnt].facility = rpt_data->qual[d.seq].facility and
		totals->qual[cnt].provider	= rpt_data->qual[d.seq].provider and
		totals->qual[cnt].diag_prob_code = rpt_data->qual[d.seq].diag_prob_code and
		totals->qual[cnt].diag_prob_desc = rpt_data->qual[d.seq].Diag_prob_desc)
		  totals->qual[cnt].total_counts = totals->qual[cnt].total_counts + 1
	else ;;; not a match
	   cnt = cnt + 1
	    totals->qual[cnt].total_counts = totals->qual[cnt].total_counts + 1
        totals->qual[cnt].facility = rpt_data->qual[d.seq].facility
		totals->qual[cnt].provider	= rpt_data->qual[d.seq].provider
		totals->qual[cnt].diag_prob_code = rpt_data->qual[d.seq].diag_prob_code
		totals->qual[cnt].diag_prob_desc = rpt_data->qual[d.seq].Diag_prob_desc
    endif
with nocounter
 
	/**************************************************************
	; Provider Totals
	**************************************************************/
	CALL ECHO ("Provider Totals")
 
	SELECT INTO 'nl:'
		Facility = rpt_data->qual[d.seq].facility
		,Provider = rpt_data->qual[d.seq].provider
		FROM (dummyt d WITH seq = VALUE(SIZE(rpt_data->qual,5)))
		PLAN d
		ORDER BY Facility, Provider
    head report
        start = cnt
	DETAIL
	   if (mod(cnt, 100) = 0)
	           stat = alterlist(totals->qual, cnt + 100)
	   endif
	   if (start = cnt)  ;; initial
		cnt = cnt + 1
		totals->qual[cnt].facility = rpt_data->qual[d.seq].facility
		totals->qual[cnt].provider	= rpt_data->qual[d.seq].provider
		totals->qual[cnt].diag_prob_code = 'z Totals'
		totals->qual[cnt].diag_prob_desc = 'z Totals'
		totals->qual[cnt].total_counts = totals->qual[cnt].total_counts + 1
		elseif ( ;; match
        totals->qual[cnt].facility = rpt_data->qual[d.seq].facility and
		totals->qual[cnt].provider	= rpt_data->qual[d.seq].provider)
		totals->qual[cnt].total_counts = totals->qual[cnt].total_counts + 1
		else ;; not a match
	    cnt = cnt + 1
        totals->qual[cnt].facility = rpt_data->qual[d.seq].facility
		totals->qual[cnt].provider	= rpt_data->qual[d.seq].provider
		totals->qual[cnt].diag_prob_code = 'z Totals'
		totals->qual[cnt].diag_prob_desc = 'z Totals'
        totals->qual[cnt].total_counts = totals->qual[cnt].total_counts + 1
        endif
	WITH nocounter
 
	/**************************************************************
	; Facility Totals
	**************************************************************/
	CALL ECHO ("Facility Totals")
 
	SELECT INTO 'nl:'
		Facility = rpt_data->qual[d.seq].facility
		FROM (dummyt d WITH seq = VALUE(SIZE(rpt_data->qual,5)))
		PLAN d
		ORDER BY Facility
    head report
        start = cnt
	DETAIL
	   if (mod(cnt, 100) = 0)
	           stat = alterlist(totals->qual, cnt + 100)
	   endif
	   if (start = cnt)  ;; initial
		cnt = cnt + 1
		totals->qual[cnt].facility = rpt_data->qual[d.seq].facility
		totals->qual[cnt].provider = 'z Totals'
		totals->qual[cnt].diag_prob_code = 'z Totals'
		totals->qual[cnt].diag_prob_desc = ''
		totals->qual[cnt].total_counts = totals->qual[cnt].total_counts + 1
	elseif (
        totals->qual[cnt].facility = rpt_data->qual[d.seq].facility)
        totals->qual[cnt].total_counts = totals->qual[cnt].total_counts + 1
    else ;; not a match
        cnt = cnt + 1
		totals->qual[cnt].facility = rpt_data->qual[d.seq].facility
		totals->qual[cnt].provider = 'z Totals'
		totals->qual[cnt].diag_prob_code = 'z Totals'
		totals->qual[cnt].diag_prob_desc = ''
        totals->qual[cnt].total_counts = totals->qual[cnt].total_counts + 1
    endif
	WITH nocounter
    set stat = alterlist(totals->qual, cnt)
ENDIf
 
/***************************************************************************
	Output Detail Report or Summary Report
****************************************************************************/
 
IF (size(rpt_data->qual, 5) > 0)
	IF($sumdet = 0)	;Summary
 
		CALL ECHO("Summary Totals Report")
		SELECT distinct INTO $outdev
	 		dateRange = BUILD2(FORMAT(CNVTDATETIME($bdate),"mm/dd/yyyy hh:mm;;q"), ' - ',
			FORMAT(CNVTDATETIME($edate), "mm/dd/yyyy hh:mm;;q")),
			Facility = totals->qual[d.seq].facility,
			Provider = totals->qual[d.seq].provider,
			Diag_Prob_Code = totals->qual[d.seq].diag_prob_code,
			Diag_Prob_Desc = totals->qual[d.seq].diag_prob_desc,
			Totals_Counts = totals->qual[d.seq].total_counts
	 	FROM (dummyt d with seq = size(totals->qual, 5))
	 	ORDER BY Facility, Provider, Diag_Prob_Desc
		WITH nocounter, format, separator = ' '
 
	ELSE		;Detail Report
 
		CALL ECHO("Detail Report")
 
		SELECT distinct INTO $outdev
			Facility = rpt_data->qual[d.seq].facility,
			Provider = rpt_data->qual[d.seq].provider,
			Patient = rpt_data->qual[d.seq].patient,
			DOB = rpt_data->qual[d.seq].DOB,
			Insurance = rpt_data->qual[d.seq].insurance,
			Fin = rpt_data->qual[d.seq].fin,
			Enc_Date = rpt_data->qual[d.seq].enc_date,
			Diag_Prob_Code = rpt_data->qual[d.seq].diag_prob_code,
			Diag_Prob_Desc = rpt_data->qual[d.seq].diag_prob_desc,
			This_Visit_Flag = rpt_data->qual[d.seq].thisvisit,
			Chronic_Flag = rpt_data->qual[d.seq].chronic,
			Priority = EVALUATE2(IF (rpt_data->qual[d.seq].priority = 99) '' ELSE CNVTSTRING(rpt_data->qual[d.seq].priority) ENDIF)
		FROM (dummyt d WITH seq = size(rpt_data->qual, 5))
		ORDER BY Facility, Provider, Patient, Enc_Date, rpt_data->qual[d.seq].priority, Diag_Prob_Desc
		WITH nocounter, format, separator = ' '
	ENDIF
ELSE	;No Data Show Prompts
		SELECT INTO $outdev
			Message = "No data for the prompt values",
			Facility_Prompt = prompts->p_facility,
			Provider_Prompt = prompts->p_provider,
			Begin_Date_Prompt = prompts->p_bdate,
			End_Date_Prompt = prompts->p_edate,
			Summary_or_Detail_Prompt = prompts->p_sumdet
		FROM (dummyt d with seq = prompts->rec_cnt)
		WITH nocounter, format, separator = ' '
ENDIF
 
#exit_script
 
END
GO
 
 
