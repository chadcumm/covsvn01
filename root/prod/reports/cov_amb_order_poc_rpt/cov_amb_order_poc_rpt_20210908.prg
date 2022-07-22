/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Dawn Greer
	Date Written:		09/03/2021
	Solution:			Ambulatory
	Source file name:	cov_amb_order_poc_rpt.prg
	Object name:		cov_amb_order_poc_rpt
	Request #:
 
	Program purpose:	Display POC Ambulatory Orders.
 
	Executing from:		CCL
 
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod  Date       Developer				Comment
---- ----------	--------------------	--------------------------------------
 001 09/03/2021 Dawn Greer, DBA         CR XXXX - Created
******************************************************************************/
 
drop program cov_amb_order_poc_rpt:DBA go
create program cov_amb_order_poc_rpt:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"      ;* Enter or select the printer or file name to send this report to.
	, "Facility:" = VALUE(0.0            )
	, "Provider(s)" = VALUE(0.0           )
	, "Order Status" = VALUE(0.0)
	, "Order Start Date  (Start)" = "SYSDATE"
	, "Order Start Date (End)" = "SYSDATE"
 
with OUTDEV, facility, provider, ord_status, start_date, end_date
 
 
/**************************************************************
; Variables/Record Structure
**************************************************************/
 
DECLARE num					= i4 WITH noconstant(0)
DECLARE novalue				= vc WITH constant("Not Available")
DECLARE op_facility_var		= c2 WITH noconstant("")
DECLARE op_provider_var		= c2 WITH noconstant("")
 
DECLARE faclist 			= c8000
DECLARE facprompt           = c8000
DECLARE facitem 			= vc
DECLARE provlist 			= c10000
DECLARE provprompt          = c10000
DECLARE provitem 			= vc
 
DECLARE ord_status_list		= c200
DECLARE ord_status_prompt   = c200
DECLARE ord_status_prompt2  = c200
DECLARE ord_status_item 	= vc
DECLARE op_ordstatus_var	= vc WITH noconstant("")
 
RECORD poc_orders (
	1 p_facility = c100
	1 p_provider = c100
	1 p_order_status = c200
	1 p_start_date = vc
	1 p_end_date = vc
 
	1	poc_cnt = i4
	1	list[*]
		2 Facility = c100
		2 Provider = c100
		2 Person_ID = f8
		2 Patient = c100
		2 DOB = c10
		2 DOS = c20
		2 FIN = c200
		2 Insurance = c200
		2 Order_ID = f8
		2 Order_Name = c200
		2 Order_Date = c20
		2 Order_Communication_Type = c50
		2 Order_Catalog_Name = c40
		2 Order_Status = c50
		2 Order_Diag = c300
		2 Cancel_Reason = c50
		2 Order_Auth = c50
		2 Perform_Location = c50
		2 Sch_Location = c50
		2 Order_Comment_Spec_Instr = c300
		2 Schedule_Date = c20
		2 Reason_For_Exam = c100
		2 Endorsed_By = C150
		2 Endorsed_Date = c20
		2 Encntr_id = F8
)
 
/**********************************************************
	Facility Prompt
***********************************************************/
CALL ECHO("Facility Prompt")
 
; define operator for $facility
SELECT DISTINCT facnum = org.organization_id
	, facility_name = org.org_name
FROM organization org
	, org_set_org_r oso
WHERE org.organization_id = oso.organization_id
AND org.active_ind = 1
AND oso.org_set_id IN (3875838.00 /*CMG*/,0.00 /*No Org Set*/)
ORDER BY org.org_name
 
HEAD REPORT
	faclist = FILLSTRING(2000,' ')
	faclist = '('
 
DETAIL
	faclist = BUILD(BUILD(faclist, facnum),', ')
 
FOOT REPORT
	faclist = BUILD(faclist,')')
	faclist = REPLACE(faclist,',','',2)
 
WITH nocounter
 
IF (substring(1, 1, reflect(parameter(parameter2($facility), 0))) = "L") ; multiple values selected
    SET op_facility_var = "IN"
    SET facprompt = '('
 
    SET num = CNVTINT(SUBSTRING(2,2,REFLECT(PARAMETER(PARAMETER2($facility),0))))
 
    FOR (i = 1 TO num)
    	SET facitem = CNVTSTRING(PARAMETER(PARAMETER2($facility),i))
       	SET facprompt = BUILD(facprompt,facitem)
    	IF (i != num)
    		SET facprompt = BUILD(facprompt, ",")
    	ENDIF
    ENDFOR
    SET facprompt = BUILD(facprompt, ")")
    SET facprompt = CONCAT("org.organization_id IN ", facprompt)
 
ELSEIF(PARAMETER(PARAMETER2($facility),1) = 0.0)	;any was selected
	SET op_facility_var = "!="
	SET facprompt = BUILD("org.organization_id != 0 ")
ELSE	;single value selected
	SET op_facility_var = "="
	SET facitem = CNVTSTRING(PARAMETER(PARAMETER2($facility),1))
	SET facprompt = BUILD("org.organization_id = ", facitem)
ENDIF
 
; select facility prompt data
SELECT DISTINCT facnum = org.organization_id
	, facility_name = org.org_name
FROM organization org
	, org_set_org_r oso
WHERE org.organization_id = oso.organization_id
AND org.active_ind = 1
AND oso.org_set_id IN (3875838.00 /*CMG*/,0.00 /*No Org Set*/)
AND PARSER(facprompt)
ORDER BY org.org_name
 
; populate pat_meds record structure with facility prompt data
HEAD REPORT
	poc_orders->p_facility = evaluate(op_facility_var, "IN", "Multiple", "!=", "Any (*)", "=", org.org_name)
WITH nocounter
 
CALL ECHO(CONCAT("Facility Prompt: ", facprompt))
 
/**********************************************************
	Provider Prompt
***********************************************************/
CALL ECHO ("Provider Prompt")
 
SELECT prov_num = prov.person_id
, prov_name = prov.name_full_formatted
FROM practice_site ps
, (INNER JOIN prsnl_reltn pr ON (pr.parent_entity_id = ps.practice_site_id
	AND pr.parent_entity_name = 'PRACTICE_SITE'
	AND pr.active_ind = 1
	))
, (INNER JOIN practice_site_type_reltn pstr ON (ps.practice_site_id = pstr.practice_site_id
	AND pstr.practice_site_type_cd = 2557996085.00 /*Employed*/
	))
, (INNER JOIN prsnl prov ON (prov.person_id = pr.person_id
	))
, (INNER JOIN organization org ON (ps.organization_id = org.organization_id
	))
, (INNER JOIN org_set_org_r osor ON (org.organization_id = osor.organization_id
	AND osor.active_ind = 1
	AND osor.org_set_id IN (3875838.00 /*CMG*/,0.00 /*No Org Set*/)
	))
WHERE PARSER(facprompt)
ORDER BY prov.name_full_formatted
 
HEAD REPORT
	provlist = FILLSTRING(2000,' ')
 	provlist = '('
 
DETAIL
	provlist = BUILD(BUILD(provlist, prov_num), ', ')
 
FOOT REPORT
	provlist = BUILD(provlist,')')
	provlist = REPLACE(provlist,',','',2)
 
WITH nocounter
 
;Provider Prompt
IF(SUBSTRING(1,1,REFLECT(PARAMETER(PARAMETER2($provider),0))) = "L")		;multiple options selected
	SET op_provider_var = "IN"
	SET provprompt = '('
	SET num = CNVTINT(SUBSTRING(2,2,REFLECT(PARAMETER(PARAMETER2($provider),0))))
 
	FOR (i = 1 TO num)
		SET provitem = CNVTSTRING(PARAMETER(PARAMETER2($provider),i))
		SET provprompt = BUILD(provprompt,provitem)
		IF (i != num)
			SET provprompt = BUILD(provprompt, ",")
		ENDIF
	ENDFOR
	SET provprompt = BUILD(provprompt, ")")
	SET provprompt = BUILD("prov.person_id IN ",provprompt)
 
ELSEIF(PARAMETER(PARAMETER2($provider),1) = 0.0)  ;any was selected
	SET op_provider_var = "!="
	SET provprompt = BUILD("prov.person_id != 0.00 ")
ELSE 	;single value selected
	SET op_provider_var = "="
	SET provitem = CNVTSTRING(PARAMETER(PARAMETER2($provider),1))
	SET provprompt = BUILD("prov.person_id = ", provitem)
ENDIF
 
; select provider prompt data
SELECT prov_num = prov.person_id
, prov_name = prov.name_full_formatted
FROM practice_site ps
, (INNER JOIN prsnl_reltn pr ON (pr.parent_entity_id = ps.practice_site_id
	AND pr.parent_entity_name = 'PRACTICE_SITE'
	AND pr.active_ind = 1
	))
, (INNER JOIN practice_site_type_reltn pstr ON (ps.practice_site_id = pstr.practice_site_id
	AND pstr.practice_site_type_cd = 2557996085.00 /*Employed*/
	))
, (INNER JOIN prsnl prov ON (prov.person_id = pr.person_id
	))
, (INNER JOIN organization org ON (ps.organization_id = org.organization_id
	))
, (INNER JOIN org_set_org_r osor ON (org.organization_id = osor.organization_id
	AND osor.active_ind = 1
	AND osor.org_set_id IN (3875838.00 /*CMG*/,0.00 /*No Org Set*/)
	))
WHERE PARSER(facprompt)
AND PARSER(provprompt)
ORDER BY prov.name_full_formatted
 
; populate pat_meds record structure with provider prompt data
HEAD REPORT
	poc_orders->p_provider = EVALUATE(op_provider_var, "IN", "Multiple", "!=", "Any (*)", "=", prov.name_full_formatted)
WITH nocounter
 
CALL ECHO(CONCAT("Provider Prompt: ", provprompt))
 
/**********************************************************
	Order Status Prompt
***********************************************************/
CALL ECHO ("Order Status Prompt")
 
SELECT order_status_cd = cv1.code_value,
	order_status = cv1.display
FROM code_value cv1
WHERE cv1.CODE_SET = 6004 AND cv1.active_ind = 1
ORDER BY cv1.display
 
HEAD REPORT
	ord_status_list = FILLSTRING(2000,' ')
 	ord_status_list = '('
 
DETAIL
	ord_status_list = BUILD(BUILD(ord_status_list, cv1.code_value), ', ')
 
FOOT REPORT
	ord_status_list = BUILD(ord_status_list,')')
	ord_status_list = REPLACE(ord_status_list,',','',2)
 
WITH nocounter
 
;Order Status Prompt
IF(SUBSTRING(1,1,REFLECT(PARAMETER(PARAMETER2($ord_status),0))) = "L")		;multiple options selected
	SET op_ordstatus_var = "IN"
	SET ord_status_prompt = '('
	SET num = CNVTINT(SUBSTRING(2,2,REFLECT(PARAMETER(PARAMETER2($ord_status),0))))
 
	FOR (i = 1 TO num)
		SET ord_status_item = CNVTSTRING(PARAMETER(PARAMETER2($ord_status),i))
		SET ord_status_prompt = BUILD(ord_status_prompt,ord_status_item)
		IF (i != num)
			SET ord_status_prompt = BUILD(ord_status_prompt, ",")
		ENDIF
	ENDFOR
 
 	SET ord_status_prompt = BUILD(ord_status_prompt, ")")
	SET ord_status_prompt = CONCAT("ord.order_status_cd IN ",ord_status_prompt)
	SET ord_status_prompt2 = REPLACE(ord_status_prompt,"ord.order_status_cd IN ","cv1.code_value IN ")
 
ELSEIF(PARAMETER(PARAMETER2($ord_status),1)= 0.0)  ;any was selected
	SET op_ordstatus_var = "!="
	SET ord_status_prompt = CONCAT("ord.order_status_cd != 0.00 ")
	SET ord_status_prompt2 = REPLACE(ord_status_prompt,"ord.order_status_cd != 0.00 ","cv1.code_value != 0.00 ")
ELSE 	;single value selected
	SET op_ordstatus_var = "="
	SET ord_status_item = CNVTSTRING(PARAMETER(PARAMETER2($ord_status),1))
	SET ord_status_prompt = CONCAT("ord.order_status_cd = ", ord_status_item)
	SET ord_status_prompt2 = REPLACE(ord_status_prompt,"ord.order_status_cd = ","cv1.code_value = ")
ENDIF
 
; select order_status prompt data
SELECT order_status_cd = cv1.code_value,
	order_status = cv1.display
FROM code_value cv1
WHERE cv1.CODE_SET = 6004 AND cv1.active_ind = 1
AND PARSER(ord_status_prompt2)
ORDER BY cv1.display
 
; populate pat_meds record structure with provider prompt data
HEAD REPORT
	poc_orders->p_order_status = EVALUATE(op_ordstatus_var, "IN", "Multiple", "!=", "Any (*)", "=", cv1.display)
WITH nocounter
 
/**********************************************************
	Set Other Prompt Values
***********************************************************/
CALL ECHO("Set Other Prompt Values")
 
SELECT INTO "NL:"
FROM dummyt
 
HEAD REPORT
	poc_orders->p_start_date = FORMAT(CNVTDATE2($start_date, "dd-mmm-yyyy hh:mm"), "mm/dd/yyyy;;d")
	poc_orders->p_end_date = FORMAT(CNVTDATE2($end_date, "dd-mmm-yyyy hh:mm"), "mm/dd/yyyy;;d")
WITH nocounter
 
/**************************************************************
; Amb POC Orders Data
**************************************************************/
CALL ECHO("Amb POC Orders Data")
 
SELECT Facility = TRIM(org.org_name,3)
,Provider = TRIM(prov.name_full_formatted,3)
,Patient = TRIM(pat.name_full_formatted,3)
,DOB = FORMAT(CNVTDATETIMEUTC(pat.birth_dt_tm,1), "MM/DD/YYYY;;d")
,DOS = FORMAT(enc.reg_dt_tm, "MM/DD/YYYY hh:mm:ss;;d")
,FIN = TRIM(ea.alias,3)
,Insurance = EVALUATE2(IF (epr.health_plan_id = 0.00) TRIM(per_ins_hp.plan_name,3)
	ELSE TRIM(enc_ins_hp.plan_name,3) ENDIF)
,Order_Communication_type = UAR_GET_CODE_DISPLAY(oa.communication_type_cd)
,Order_Name = UAR_GET_CODE_DISPLAY(ord.catalog_cd)
,Order_Date = FORMAT(ord.current_start_dt_tm, "MM/DD/YYYY hh:mm:ss;;d")
,Order_id = ord.order_id
,Order_Status = UAR_GET_CODE_DISPLAY(ord.order_status_cd)
,Encntr_Id = enc.encntr_Id
FROM ORDERS ord
, (LEFT JOIN ORDER_ACTION oa ON (oa.order_id = ord.order_id
   	AND oa.action_type_cd = 2534 /*Order*/
   	))
, (LEFT JOIN PRSNL prov ON (prov.person_id = oa.order_provider_id
	))
, (LEFT JOIN PERSON pat ON (pat.person_id = ord.person_id
	))
, (LEFT JOIN ENCOUNTER enc ON (enc.encntr_id = ord.encntr_id
	AND enc.active_ind = 1
	AND enc.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND enc.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND enc.encntr_type_cd IN (22282402 /*Clinic*/,2554389963/*Phone Message*/,
		2560523697/*Results Only*/,20058643/*Legacy Data*/)
	))
, (LEFT JOIN ENCNTR_ALIAS ea ON (ea.encntr_id = enc.encntr_id
  	AND ea.encntr_alias_type_cd = 1077 /*FIN*/
   	AND ea.active_ind = 1
   	))
, (LEFT JOIN ENCNTR_PLAN_RELTN epr ON (enc.encntr_id = epr.encntr_id
	AND epr.active_ind = 1
	AND epr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND epr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND epr.priority_seq = 1
	))
, (LEFT JOIN PERSON_PLAN_RELTN ppr ON (pat.person_id = ppr.person_id
	AND ppr.active_ind = 1
	AND ppr.beg_effective_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3)
	AND ppr.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND ppr.priority_seq = 1
	AND ppr.person_plan_r_cd = 1168.00 /*Subscriber*/
	))
, (LEFT JOIN PERSON_PLAN_PROFILE ppp ON (ppr.person_id	= ppp.person_id
	AND ppp.profile_type_cd = 23838228.00 /*Health Professional*/
	AND ppp.active_ind = 1
	))
, (LEFT JOIN HEALTH_PLAN enc_ins_hp ON (epr.health_plan_id = enc_ins_hp.health_plan_id
	))
, (LEFT JOIN HEALTH_PLAN per_ins_hp ON (ppr.health_plan_id = per_ins_hp.health_plan_id
	))
, (LEFT JOIN ORGANIZATION org ON (org.organization_id = enc.organization_id
	))
WHERE ord.catalog_type_cd = 20454826 /*POC*/
AND PARSER(facprompt)
AND PARSER(provprompt)
AND PARSER(ord_status_prompt)
AND ord.current_start_dt_tm BETWEEN CNVTDATETIME($start_date) AND CNVTDATETIME($end_date)
AND pat.name_last_key NOT IN ('FFFFPEDS','FFFFAMB','FFFFPNRC','FFFFOP','FFFFED','FFFFIP','FFFFWH','FFFFTEST','FFFFREVCYCLE',
	'FFFFPHARM','ZZGLOVER','ZZTEST','ZZWICK','ZZBOGUS','ZZZZTESTPW','ZZZREGRESSION','ZZZZBHTEST','ZZZNEUROPW','ZZZFLMCRAD',
	'ZZZFSRRAD','ZZZTESTONE','ZZZAMB','ZZZPWRAD','ZZTOPTEST','ZZZ','ZZZRMCRAD','ZZZZTESTPBH','ZZMDDONOTUSE','ZZZMPITESTP',
	'ZZZRADTEST','ZZZFSRGO','ZZZFSWRAD','ZZZTESTIP','ZZZTEST','ZZELLMER','ZZZMPITESTBL','ZZZZTESTPOC','ZZZZZZTEST','ZZZTESTOP',
	'TTTTTEST','TTTTGENLAB','TTTT','TTTTMAYO','TTTTPHARMTEST','TTTTESTFSV','TTTTONC','TTTTESTCATHLAB','TTURNER','TTEST',
	'TTTTHUDLOW','TTTTTESTFN','TTTTCAMCAPTEST',	'TTTTMDI','TTBACKLOADING','TTTTESTPRVL','TTTTMMC','TTTTQUEST','TTHOMASON',
	'TTTTPRINTER','TTTTEST')


/****************************************************************************
	Populate Record structure with Amb POC Orders Data
*****************************************************************************/
HEAD REPORT
	cnt = 0
 
	CALL ALTERLIST(poc_orders->list, 100)
 
HEAD ord.order_id
	cnt = cnt + 1
 
	IF(mod(cnt, 10) = 1 AND cnt > 100)
		CALL ALTERLIST(poc_orders->list, cnt + 9)
	ENDIF
 
	poc_orders->poc_cnt = cnt
 
	poc_orders->list[cnt].Facility = Facility
	poc_orders->list[cnt].Provider = Provider
	poc_orders->list[cnt].Patient = Patient
	poc_orders->list[cnt].DOB = DOB
	poc_orders->list[cnt].DOS = DOS
	poc_orders->list[cnt].FIN = FIN
	poc_orders->list[cnt].Insurance = Insurance
	poc_orders->list[cnt].Order_Communication_type = Order_Communication_type
	poc_orders->list[cnt].Order_Name = Order_Name
	poc_orders->list[cnt].Order_Date = Order_Date
	poc_orders->list[cnt].Order_id = Order_id
	poc_orders->list[cnt].Order_Status = Order_Status
	poc_orders->list[cnt].Encntr_id = Encntr_id
 
FOOT REPORT
	CALL ALTERLIST(poc_orders->list, cnt)
 
WITH nocounter, separator=" ", format
 
IF (poc_orders->poc_cnt > 0) ;No Records - Skip to the end
 
/**************************************************************
 Get Order Diag Data
**************************************************************/
CALL ECHO("Order Diag Data")

SELECT DISTINCT INTO "NL:"
	Order_Diag = LISTAGG(CONCAT(diag.diagnosis_display, "(",nom_diag.source_identifier, ")"), "; ")
             OVER(PARTITION BY diag.encntr_id, ner.parent_entity_id ORDER BY diag.clinical_diag_priority, diag.diagnosis_display)
FROM (dummyt d WITH seq = VALUE(SIZE(poc_orders->list,5)))
	,diagnosis diag
	,nomen_entity_reltn ner
	,nomenclature nom_diag
PLAN d
JOIN diag WHERE diag.encntr_id = poc_orders->list[d.seq].encntr_id
	AND diag.active_ind = 1
JOIN ner WHERE ner.parent_entity_id = poc_orders->list[d.seq].order_id
	AND ner.encntr_id = diag.encntr_id
	AND ner.nomenclature_id = diag.nomenclature_id
	AND ner.active_ind = 1
	AND ner.reltn_type_cd = 639177.00 /*Diagnosis to Order*/
JOIN nom_diag WHERE ner.nomenclature_id = nom_diag.nomenclature_id
ORDER BY ner.parent_entity_id, Order_Diag


/****************************************************************************
	Populate Record structure with Order Diag Data
*****************************************************************************/

HEAD ner.parent_entity_id
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(poc_orders->list,5),ner.parent_entity_id, poc_orders->list[cnt].order_id)

FOOT ner.parent_entity_id

	poc_orders->list[cnt].Order_Diag = Order_Diag

	idx = LOCATEVAL(cnt,1,SIZE(poc_orders->list,5),ner.parent_entity_id, poc_orders->list[cnt].order_id)
WITH nocounter


/**************************************************************
 Get Order Diag Data - Order Detail
**************************************************************/
CALL ECHO("Order Diag Data - Order Detail")

SELECT DISTINCT INTO "NL:"
	Order_Diag = LISTAGG(CONCAT(TRIM(od_diag.oe_field_display_value,3), "(",nom_diag.source_identifier, ")"), "; ")
             OVER(PARTITION BY od_diag.order_id ORDER BY od_diag.oe_field_display_value)
FROM (dummyt d WITH seq = VALUE(SIZE(poc_orders->list,5)))
	,order_detail od_diag
	,nomenclature nom_diag
PLAN d
JOIN od_diag WHERE od_diag.order_id = poc_orders->list[d.seq].order_id
	AND od_diag.oe_field_meaning_id = 20.00 /*ICD9*/
JOIN nom_diag WHERE od_diag.oe_field_value = nom_diag.nomenclature_id
ORDER BY od_diag.order_id, Order_Diag

/****************************************************************************
	Populate Record structure with Order Diag Data - Order Detail
*****************************************************************************/

HEAD od_diag.order_id
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(poc_orders->list,5),od_diag.order_id, poc_orders->list[cnt].order_id)

FOOT od_diag.order_id

	IF (SIZE(TRIM(poc_orders->list[cnt].Order_Diag,3)) = 0) poc_orders->list[cnt].Order_Diag = Order_Diag ENDIF

	idx = LOCATEVAL(cnt,1,SIZE(poc_orders->list,5),od_diag.order_id, poc_orders->list[cnt].order_id)
WITH nocounter
 
/**************************************************************
 Get Order Cancel Data
**************************************************************/
CALL ECHO("Order Cancel Data")
 
SELECT DISTINCT INTO "NL:"
	Cancel_Reason = TRIM(od_cancel.oe_field_display_value,3)
FROM (dummyt d WITH seq = VALUE(SIZE(poc_orders->list,5)))
	,order_detail od_cancel
PLAN d
JOIN od_cancel WHERE od_cancel.order_id = poc_orders->list[d.seq].order_id
	AND od_cancel.oe_field_meaning_id = 1105.00 /*Cancelreason*/
	AND od_cancel.oe_field_id = 12664.00 /*CANCELREASON*/
 
/****************************************************************************
	Populate Record structure with Order Cancel Data
*****************************************************************************/
 
HEAD od_cancel.order_id
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(poc_orders->list,5),od_cancel.order_id, poc_orders->list[cnt].order_id)
 
FOOT od_cancel.order_id
 
	poc_orders->list[cnt].Cancel_Reason = Cancel_Reason
 
	idx = LOCATEVAL(cnt,1,SIZE(poc_orders->list,5),od_cancel.order_id, poc_orders->list[cnt].order_id)
WITH nocounter
 
/**************************************************************
 Get Order Auth Data
**************************************************************/
CALL ECHO("Order Auth Data")
 
SELECT DISTINCT INTO "NL:"
	Order_Auth = TRIM(od_auth.oe_field_display_value,3)
FROM (dummyt d WITH seq = VALUE(SIZE(poc_orders->list,5)))
	,order_detail od_auth
PLAN d
JOIN od_auth WHERE od_auth.order_id = poc_orders->list[d.seq].order_id
	AND od_auth.oe_field_Meaning_Id = 124 /*Order Auth*/
 
/****************************************************************************
	Populate Record structure with Order Auth Data
*****************************************************************************/
 
HEAD od_auth.order_id
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(poc_orders->list,5),od_auth.order_id, poc_orders->list[cnt].order_id)
 
FOOT od_auth.order_id
 
	poc_orders->list[cnt].Order_Auth = Order_Auth
 
	idx = LOCATEVAL(cnt,1,SIZE(poc_orders->list,5),od_auth.order_id, poc_orders->list[cnt].order_id)
WITH nocounter
 
/**************************************************************
 Get Order Perform Location Data
**************************************************************/
CALL ECHO("Order Perform Location Data")
 
SELECT DISTINCT INTO "NL:"
	Perform_Location = TRIM(od_perform_loc.oe_field_display_value,3)
FROM (dummyt d WITH seq = VALUE(SIZE(poc_orders->list,5)))
	,order_detail od_perform_loc
PLAN d
JOIN od_perform_loc WHERE od_perform_loc.order_id = poc_orders->list[d.seq].order_id
	AND od_perform_loc.oe_field_meaning_id = 18 /*Perform Loc*/
 
/****************************************************************************
	Populate Record structure with Order Perform Location Data
*****************************************************************************/
 
HEAD od_perform_loc.order_id
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(poc_orders->list,5),od_perform_loc.order_id, poc_orders->list[cnt].order_id)
 
FOOT od_perform_loc.order_id
 
	poc_orders->list[cnt].Perform_Location = Perform_Location
 
	idx = LOCATEVAL(cnt,1,SIZE(poc_orders->list,5),od_perform_loc.order_id, poc_orders->list[cnt].order_id)
WITH nocounter
 
/**************************************************************
 Get Order Sch Location Data
**************************************************************/
CALL ECHO("Order Sch Location Data")
 
SELECT DISTINCT INTO "NL:"
	Sch_Location = TRIM(od_sch_loc.oe_field_display_value,3)
FROM (dummyt d WITH seq = VALUE(SIZE(poc_orders->list,5)))
	,order_detail od_sch_loc
PLAN d
JOIN od_sch_loc WHERE od_sch_loc.order_id = poc_orders->list[d.seq].order_id
	AND od_sch_loc.oe_field_meaning_id = 2088 /*Sch Loc*/
	AND od_sch_loc.oe_field_id = 25786615 /*Sch Loc*/
 
/****************************************************************************
	Populate Record structure with Order Sch Location Data
*****************************************************************************/
 
HEAD od_sch_loc.order_id
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(poc_orders->list,5),od_sch_loc.order_id, poc_orders->list[cnt].order_id)
 
FOOT od_sch_loc.order_id
 
	poc_orders->list[cnt].Sch_Location = Sch_Location
 
	idx = LOCATEVAL(cnt,1,SIZE(poc_orders->list,5),od_sch_loc.order_id, poc_orders->list[cnt].order_id)
WITH nocounter
 
 
/**************************************************************
 Get Order Comment Data
**************************************************************/
CALL ECHO("Order Comment Data")
 
SELECT DISTINCT INTO "NL:"
 Order_Comment_Spec_Instr = TRIM(REPLACE(REPLACE(lt.long_text,CHAR(10),''),CHAR(13),''),3)
FROM (dummyt d WITH seq = VALUE(SIZE(poc_orders->list,5)))
	,order_comment oc
	,long_text lt
PLAN d
JOIN oc WHERE oc.order_id = poc_orders->list[d.seq].order_id
	AND oc.comment_type_cd = 66.00 /*Order Comment*/
JOIN lt WHERE oc.long_text_id = lt.long_text_id
 
/****************************************************************************
	Populate Record structure with Order Comment Data
*****************************************************************************/
 
HEAD oc.order_id
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(poc_orders->list,5),oc.order_id, poc_orders->list[cnt].order_id)
 
FOOT oc.order_id
 
	poc_orders->list[idx].Order_Comment_Spec_Instr = Order_Comment_Spec_Instr
 
	idx = LOCATEVAL(cnt,1,SIZE(poc_orders->list,5),oc.order_id, poc_orders->list[cnt].order_id)
WITH nocounter

/**************************************************************
 Get Order Schedule Date Data
**************************************************************/
CALL ECHO("Order Schedule Date Data")
 
SELECT DISTINCT INTO "NL:"
	Schedule_Date = TRIM(sch_date.oe_field_display_value,3)
FROM (dummyt d WITH seq = VALUE(SIZE(poc_orders->list,5)))
	,order_detail sch_date
PLAN d
JOIN sch_date WHERE sch_date.order_id = poc_orders->list[d.seq].order_id
	AND sch_date.oe_field_meaning_id = 51 /*SCHEDULE DATE*/
	AND sch_date.action_sequence = 1
 
/****************************************************************************
	Populate Record structure with Order Schedule Date Data
*****************************************************************************/
 
HEAD sch_date.order_id
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(poc_orders->list,5),sch_date.order_id, poc_orders->list[cnt].order_id)
 
FOOT sch_date.order_id
 
	poc_orders->list[cnt].Schedule_Date = Schedule_Date
 
	idx = LOCATEVAL(cnt,1,SIZE(poc_orders->list,5),sch_date.order_id, poc_orders->list[cnt].order_id)
WITH nocounter
 
 
/**************************************************************
 Get Order Reason for Exam Data
**************************************************************/
CALL ECHO("Order Reason for Exam Data")
 
SELECT DISTINCT INTO "NL:"
	Reason_for_Exam = TRIM(od_reason.oe_field_display_value,3)
FROM (dummyt d WITH seq = VALUE(SIZE(poc_orders->list,5)))
	,order_detail od_reason
PLAN d
JOIN od_reason WHERE od_reason.order_id = poc_orders->list[d.seq].order_id
	AND od_reason.oe_field_meaning_id = 1501.00 /*REASON FOR EXAM*/
	AND od_reason.action_sequence = 1
 
/****************************************************************************
	Populate Record structure with Order Reason for Exam Data
*****************************************************************************/
 
HEAD od_reason.order_id
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(poc_orders->list,5),od_reason.order_id, poc_orders->list[cnt].order_id)
 
FOOT od_reason.order_id
 
	poc_orders->list[cnt].Reason_for_Exam = Reason_for_Exam
 
	idx = LOCATEVAL(cnt,1,SIZE(poc_orders->list,5),od_reason.order_id, poc_orders->list[cnt].order_id)
WITH nocounter
 
/**************************************************************
 Get Order Endorsed By and Date Data
**************************************************************/
CALL ECHO("Order Endorsed By and Date Data")
 
SELECT DISTINCT INTO "NL:"
	Endorsed_By = TRIM(prsnl_ce_action.name_full_formatted,3)
	,Endorsed_Date = FORMAT(ce_prsnl.action_dt_tm, "MM/DD/YYYY hh:mm:ss;;d")
FROM (dummyt d WITH seq = VALUE(SIZE(poc_orders->list,5)))
	,clinical_event ce
	,ce_event_prsnl ce_prsnl
	,prsnl prsnl_ce_action
PLAN d
JOIN ce WHERE ce.order_id = poc_orders->list[d.seq].order_id
JOIN ce_prsnl WHERE ce.event_id = ce_prsnl.event_id
	AND ce_prsnl.action_type_cd = 678654.00 /*Endorse*/
JOIN prsnl_ce_action WHERE ce_prsnl.action_prsnl_id = prsnl_ce_action.person_id
 
/****************************************************************************
	Populate Record structure with Order Endorsed By and Date Data
*****************************************************************************/
 
HEAD ce.order_id
 	cnt = 0
	idx = 0
	idx = LOCATEVAL(cnt,1,SIZE(poc_orders->list,5),ce.order_id, poc_orders->list[cnt].order_id)
 
FOOT ce.order_id
 
	poc_orders->list[cnt].Endorsed_By = Endorsed_By
	poc_orders->list[cnt].Endorsed_Date = Endorsed_Date
 
	idx = LOCATEVAL(cnt,1,SIZE(poc_orders->list,5),ce.order_id, poc_orders->list[cnt].order_id)
WITH nocounter
 
ENDIF /*No Records*/
/***************************************************************************
	Output Report to Grid
****************************************************************************/
CALL ECHO("Output Report to Grid")
 
IF(poc_orders->poc_cnt > 0)
	SELECT INTO $OUTDEV
		Facility = poc_orders->list[d.seq].Facility,
		Provider = poc_orders->list[d.seq].Provider,
		Patient = poc_orders->list[d.seq].Patient,
		DOB = poc_orders->list[d.seq].DOB,
		DOS = poc_orders->list[d.seq].DOS,
		FIN = poc_orders->list[d.seq].FIN,
		Insurance = poc_orders->list[d.seq].Insurance,
		Order_Communication_type = poc_orders->list[d.seq].Order_Communication_type,
		Order_Name = poc_orders->list[d.seq].Order_Name,
		Order_Date = poc_orders->list[d.seq].Order_Date,
		Order_ID = poc_orders->list[d.seq].Order_id,
		Order_Status = poc_orders->list[d.seq].Order_Status,
		Order_Diag = poc_orders->list[d.seq].Order_Diag,
		Cancel_Reason = poc_orders->list[d.seq].Cancel_Reason,
		Order_Auth = poc_orders->list[d.seq].Order_Auth,
		Perform_Location = EVALUATE2(IF (SIZE(TRIM(poc_orders->list[d.seq].Perform_Location,3)) = 0)
			poc_orders->list[d.seq].Sch_Location ELSE poc_orders->list[d.seq].Perform_Location ENDIF),
		Order_Comment_Special_Instructions = poc_orders->list[d.seq].Order_Comment_Spec_Instr,
 		Schedule_Date = poc_orders->list[d.seq].Schedule_Date,
 		Reason_For_Exam = poc_orders->list[d.seq].Reason_For_Exam,
 		Endorsed_By = poc_orders->list[d.seq].Endorsed_By,
 		Endorsed_Date = poc_orders->list[d.seq].Endorsed_Date,
 
		Prompt_Values = CONCAT(CONCAT(CONCAT(CONCAT(CONCAT("Facility = ",TRIM(poc_orders->p_facility,3)),
			"     Provider = ",TRIM(poc_orders->p_provider,3)),
			"     Order_Status = ",TRIM(poc_orders->p_order_status,3)),
			"     Start Date = ",TRIM(poc_orders->p_start_date,3)),
			"     End_Date = ",TRIM(poc_orders->p_end_date,3))
	FROM (dummyt d WITH seq = poc_orders->poc_cnt)
	ORDER BY Facility, Provider, Patient, DOS, FIN
	WITH nocounter, format, separator = ' ', memsort
ELSE
	SELECT INTO $OUTDEV
	Message = "No data for the prompt values",
	Prompt_Facility = poc_orders->p_facility,
	Prompt_Provider = poc_orders->p_provider,
	Prompt_Order_Status = poc_orders->p_order_status,
	Prompt_Start_Date = poc_orders->p_start_date,
	Prompt_End_Date = poc_orders->p_end_date
	FROM (dummyt d)
	WITH nocounter, format, separator = ' '
ENDIF
 
CALL ECHORECORD(poc_orders)
 
END
GO
 
