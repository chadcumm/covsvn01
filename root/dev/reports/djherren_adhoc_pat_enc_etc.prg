
;*****************************************************
; PATIENT LOOKUP
;*****************************************************
SELECT DISTINCT
	 bed = uar_get_code_display(e.loc_facility_cd)
	,pname = p.name_full_formatted
	,pid	= p.person_id
	,fin  = decode (ea.seq,  cnvtalias(ea.alias, ea.alias_pool_cd), '')
	,mrn  = decode (ea2.seq, cnvtalias(ea2.alias, ea2.alias_pool_cd), '')
	,cmrn = decode (pa.seq,  cnvtalias(pa.alias, pa.alias_pool_cd), '')
	,eid = e.encntr_id
	,EncounterVisit_type = uar_get_code_display(e.encntr_type_cd)
	,admit = FORMAT(e.arrive_dt_tm,"MM/DD/YYYY HH:24;;D")
	,dc = e.disch_dt_tm
	,unit = uar_get_code_display(e.loc_nurse_unit_cd)
	,room = uar_get_code_display(e.loc_room_cd)
	,bed = uar_get_code_display(e.loc_bed_cd)
FROM
	 PERSON         p
	,ENCOUNTER      e
	,ENCNTR_ALIAS   ea  ;fin,
	,ENCNTR_ALIAS   ea2 ;mrn
	,PERSON_ALIAS   pa  ;cmrn
 
PLAN p
 
JOIN e
	WHERE OUTERJOIN(p.person_id) = e.person_id
;		and e.person_id = 15813204
		AND e.active_ind = 1
        AND e.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
        AND e.encntr_id in (   112009711.00);=    111274957
 
JOIN ea
    WHERE ea.encntr_id = outerJOIN(e.encntr_id)
    	AND ea.encntr_alias_type_cd = outerJOIN(1077)   ;1077, 1079
		AND ea.end_effective_dt_tm > outerJOIN(cnvtdatetime(curdate, curtime))
;		AND ea.alias in (
;"1825702353"
;)
 
JOIN ea2
    WHERE ea2.encntr_id = outerJOIN(e.encntr_id)
		AND ea2.encntr_alias_type_cd = outerJOIN(1079)   ;1077, 1079
		AND ea2.end_effective_dt_tm > outerJOIN(cnvtdatetime(curdate, curtime))
 
JOIN pa
	WHERE pa.person_id = outerJOIN(e.person_id)
		AND pa.person_alias_type_cd = outerJOIN(2)    ;2
		AND pa.end_effective_dt_tm > outerJOIN(cnvtdatetime(curdate, curtime))
;		AND pa.alias = "1285569"
 
ORDER BY
	e.arrive_dt_tm desc
 
;********************
; ENCOUNTER HISTORY
;********************
SELECT
	 t.TRANSACTION_DT_TM "@SHORTDATETIME"
	,T_ENCNTR_TYPE_DISP = UAR_GET_CODE_DISPLAY(T.ENCNTR_TYPE_CD)
	,t.ACTIVE_STATUS_DT_TM "@SHORTDATETIME"
	,t.UPDT_DT_TM "@SHORTDATETIME"
	,t.encntr_loc_hist_id
	,medical_service = UAR_GET_CODE_DISPLAY(T.med_service_cd)
	,t.*
 
FROM
	ENCNTR_LOC_HIST t
 
where t.encntr_id =   112009711.00
 
order by t.encntr_loc_hist_id desc
 
 
;*****************************************************
; CODE VALUE LOOKUP
;*****************************************************
 
SELECT
	 code_set      = cv.code_set
	,code_set_name = cvs.display
	,code_value    = cv.code_value
	,cdf_meaning   = cv.cdf_meaning
	,display       = cv.display
	,display_key   = cv.display_key
	,description   = cv.description
 	,cki           = cv.cki
 
FROM
	 CODE_VALUE     cv
	,CODE_VALUE_SET cvs
 
WHERE cvs.code_set = cv.code_set
	AND cv.active_ind = 1
;	AND cv.code_set =               356
;	AND cv.code_value =     2552503657
;	AND cnvtupper(cv.cdf_meaning) = "DIET"
;;	AND cnvtupper(cv.display) = "DIET"
	AND cnvtupper(cv.display_key) = "*4N*"
;	AND cnvtlower(cv.description) in ("*cytolo*")
;	AND cv.cki = "CKI.CODEVALUE!4101498946"
 
ORDER BY
	 cv.code_set
	,cv.display
 
WITH FORMAT, SEPARATOR = " ", TIME = 30


;*****************************************************
;GET UAR INFORMATION
;*****************************************************
SELECT
	uar_get_code_by("DISPLAY_KEY",200,"EDDECISIONTODISCHARGE")
	,uar_get_code_by("DISPLAY_KEY",200,"EDDECISIONTOADMIT")
	,uar_get_code_by("DISPLAY_KEY",106,"TUBEFEEDING")
	,uar_get_code_by("MEANING",14281,"ORDERED")
	,uar_get_code_by("MEANING",48,"ACTIVE")
	,path_tissue_req	=	UAR_GET_CODE_BY("DISPLAYKEY",200,"PATHOLOGYTISSUEREQUEST")
	,surg_tissue_req	=	UAR_GET_CODE_BY("DISPLAYKEY",200,"SURGICALPATHOLOGYREPORT")
	,pre_op	=	UAR_GET_CODE_BY("DISPLAYKEY",17,"PREOPDIAGNOSIS")
	,post_op	=	UAR_GET_CODE_BY("DISPLAYKEY",17,"POSTOPDIAGNOSIS")
FROM
	dummyt
WITH MAXREC = 100
 

;*****************************************************
; FACILITY PROMPT
;*****************************************************
SELECT DISTINCT
    FACILITY_NAME = O.ORG_NAME
    , L.LOCATION_CD
 
FROM
     PRSNL_ORG_RELTN p
    ,LOCATION        l
    ,ORGANIZATION    o
 
PLAN p WHERE p.person_id = reqinfo -> updt_id
	AND p.active_ind = 1
    AND p.end_effective_dt_tm > sysdate
JOIN l WHERE l.organization_id = p.organization_id
    AND l.location_type_cd = 783  ;(FACILITY)
JOIN o WHERE o.organization_id = l.organization_id
    AND o.organization_id IN (3234038,3144506,3144501,675844,3144505,3144499,3144502,3144503,3144504)
 
ORDER BY
    FACILITY_NAME
 
 
 
;*****************************************************
 
select * from clinical_event where order_id in (371619267.00,  374910933.00)
 
 
 
select ce.accession_nbr
    , substring(1,30,ord.order_mnemonic)
    , substring(1,30,ce.event_title_text)
    , ceb.event_id
    , ceb.valid_until_dt_tm
    , ceb.valid_from_dt_tm
    , ceb.blob_length
from
	orders ord,
	clinical_event ce,
	ce_blob ceb
plan ord where ord.person_id = 12736491.00
;		  and ord.order_id in (  370660979.00,  370686115.00)
join ce where ce.order_id = ord.order_id
          and ce.valid_until_dt_tm > sysdate
join ceb where ce.event_id = ceb.event_id
           and ceb.valid_until_dt_tm > sysdate
order by ce.accession_nbr, ce.collating_seq
 
 
 

;*****************************************************
; CMRN, MRN, FIN
;*****************************************************
SELECT
 	 person_id	= p.person_id
 	,encntr_id	= e.encntr_id
	,fin		= eaf.alias
	,cmrn		= pac.alias
	,mrn		= pam.alias
	,pname		= p.name_full_formatted
	,ap_order	= UAR_GET_CODE_DISPLAY(ord.catalog_cd)
	,order_dt	= ord.current_start_dt_tm
	,oid		= ord.order_id
 
FROM
	 person p
	,orders ord
	,encounter e
	,person_alias	pac
	,encntr_alias	eaf
	,person_alias	pam
 
PLAN p
 
JOIN ord WHERE p.person_id = ord.person_id
;			and ord.catalog_cd =       313046.00
 
JOIN e
	WHERE OUTERJOIN(p.person_id) = e.person_id
		AND e.encntr_id = ord.encntr_id
;	and e.encntr_id =       97732694.00
	and p.person_id in (12736491)
 
JOIN pac
	WHERE OUTERJOIN(p.person_id) = pac.person_id
		AND pac.person_alias_type_cd = OUTERJOIN(2)	;CMRN
		AND pac.active_ind = OUTERJOIN(1)
		AND pac.end_effective_dt_tm = OUTERJOIN(CNVTDATETIME("31-DEC-2100 0"))
 
JOIN eaf
	WHERE OUTERJOIN(e.encntr_id) = eaf.encntr_id
		AND eaf.encntr_alias_type_cd = OUTERJOIN(1077.00)	;FIN
;		AND eaf.alias IN ('1802200003','6587455485')
		AND eaf.end_effective_dt_tm = OUTERJOIN(CNVTDATETIME("31-DEC-2100 0"))
 
JOIN pam WHERE OUTERJOIN(p.person_id) = pam.person_id
		AND pam.person_alias_type_cd = OUTERJOIN(10.00)	;MRN
		AND pam.active_ind = OUTERJOIN(1)
		AND pam.end_effective_dt_tm = OUTERJOIN(CNVTDATETIME("31-DEC-2100 0"))
 
order by
	p.person_id
 
 
 
;***************************************************************************************************************************
;												RULES SCRIPTS / SQL's
;***************************************************************************************************************************
;*****************************************************
;	RULES search based on order comment
;*****************************************************
select distinct
	  rule = e.module_name
	, p.name_full_formatted
	, e.updt_dt_tm
from
	eks_module   e
	, eks_modulestorage   em
	, eks_modulestorage   emk
	, prsnl p
 
plan e
	where e.maint_dur_begin_dt_tm <= cnvtdatetime(curdate,curtime)
	and e.maint_dur_end_dt_tm >= cnvtdatetime(curdate,curtime)
	and e.maint_validation = "PRODUCTION"  and e.active_flag = "A"

join em 
	where em.module_name = e.module_name
	and em.data_type = 1 ;purpose field
	and em.version =   (select max(em2.version)
						from eks_modulestorage em2
						where em2.module_name = e.module_name)
						
join emk
	where emk.module_name = outerjoin(e.module_name)
	and emk.version = em.version
	and cnvtupper(emk.ekm_info) = "*BRADEN SCORE LESS THAN 12*"
 
join p	
	where p.person_id = outerjoin(e.updt_id)
 
order by
	e.module_name
 
with nocounter, separator=" ", format
 
 
;********************************
;Broken Rules Audit
;********************************
SELECT
	EM.MODULE_NAME
	,EM.MAINT_TITLE
	,EM.MAINT_VALIDATION
	,EM.MAINT_VERSION,em.updt_dt_tm, p.name_full_formatted
FROM
	EKS_MODULE EM, PRSNL P
WHERE
		EM.ACTIVE_FLAG = "A"
	AND EM.MAINT_VALIDATION IN ("PRODUCTION", "TESTING")
	AND EM.RECONCILE_FLAG = 2
	AND em.updt_id = p.person_id
 
ORDER BY
	em.module_name
GO
 
