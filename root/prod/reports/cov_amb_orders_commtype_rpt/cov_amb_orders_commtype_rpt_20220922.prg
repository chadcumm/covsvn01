/*********************************************************************************
Author          :	Dawn Greer, DBA
Date Written	:	08/19/2022
Program Title	:	cov_amb_orders_commtype_rpt
Source File     :	cov_amb_orders_commtype_rpt.prg
Object Name     :	cov_amb_orders_commtype_rpt
Directory       :	cust_script
 
Purpose         : 	Ambulatory All Orders and Communication Type Report
 
 
Mod     Date        Engineer                Comment
----    ----------- ----------------------- ---------------------------------------
001     08/19/2022  Dawn Greer, DBA         Original Release - CR 12723
************************************************************************************/
drop program cov_amb_orders_commtype_rpt go
create program cov_amb_orders_commtype_rpt
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Facility:" = VALUE(0.0)
	, "Order Start Date:" = "SYSDATE"
	, "Order End Date" = "SYSDATE"
	, "Order By vs Ordering Provider" = "diff"
 
with OUTDEV, FAC, BDATE, EDATE, ALLDIFF
 
FREE RECORD ord_data
RECORD ord_data
(
	1 rec_cnt = I4
	1 p_facility = C4000
	1 p_alldiff = C50
	1 p_start_date = VC
	1 p_end_date = VC
	1 list[*]
	  2 Facility = C100
	  2 Ordering_Provider = C100
	  2 Patient = C100
	  2 DOB = C10
	  2 CMRN = C20
	  2 FIN = C20
	  2 Order_ID = F8
	  2 Order_Name = C100
	  2 Order_Type = C50
	  2 Order_Date = C50
	  2 Ordered_By = C100
	  2 Order_Status = C50
	  2 Order_Action = C50
	  2 Communication_Type = C50
	  2 Order_Proposal_Status = C50
	  2 Proposal_Communication_Type = C50
)
 
/**************************************************************
; DECLARED VARIABLES
**************************************************************/
DECLARE faclist = C8000
DECLARE facprompt = C8000
DECLARE num = I4
DECLARE facitem = VC
DECLARE provprompt = C50
 
/**********************************************************
Get CMG Facility Data
***********************************************************/
CALL ECHO ("Get Facility Prompt Data")
 
SELECT DISTINCT facnum = CNVTSTRING(org.organization_id)
FROM organization org, organization_alias oa
WHERE org.organization_id = oa.organization_id
AND org.active_ind = 1
AND org.end_effective_dt_tm >= CNVTDATETIME(CURDATE,CURTIME3)
AND org.data_status_cd = 25.00 /*Auth*/
AND oa.active_ind = 1
AND oa.end_effective_dt_tm >= CNVTDATETIME(CURDATE,CURTIME3)
AND oa.org_alias_type_cd = 1130.00 /*Encounter organization Alias*/
ORDER BY CNVTUPPER(TRIM(org.org_name,3))
 
HEAD REPORT
	faclist = FILLSTRING(8000,' ')
 	faclist = '('
DETAIL
	faclist = BUILD(BUILD(faclist, facnum), ', ')
 
FOOT REPORT
	faclist = BUILD(faclist,')')
	faclist = REPLACE(faclist,',','',2)
 
WITH nocounter
 
;Facility Prompt
IF(SUBSTRING(1,1,REFLECT(PARAMETER(PARAMETER2($FAC),0))) = "L")		;multiple options selected
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
	SET facprompt = BUILD("org.organization_id IN ",facprompt)
 
ELSEIF(PARAMETER(PARAMETER2($FAC),1)= 0.00)  ;any was selected
	SET facprompt = BUILD("org.organization_id IN ", faclist)
ELSE 	;single value selected
	SET facitem = CNVTSTRING(PARAMETER(PARAMETER2($FAC),1))
	SET facprompt = BUILD("org.organization_id = ", facitem)
ENDIF
 
; Get Facility prompt data selected
SELECT DISTINCT facname = TRIM(org.org_name)
, facnum = CNVTSTRING(org.organization_id)
FROM organization org, organization_alias oa, org_set_org_r osor, org_set os
WHERE org.organization_id = oa.organization_id
AND org.organization_id = osor.organization_id
AND osor.active_ind = 1
AND osor.org_set_id = os.org_set_id
AND os.name LIKE '*CMG*'
AND org.active_ind = 1
AND org.end_effective_dt_tm >= CNVTDATETIME(CURDATE,CURTIME3)
AND org.data_status_cd = 25.00 /*Auth*/
AND oa.active_ind = 1
AND oa.end_effective_dt_tm >= CNVTDATETIME(CURDATE,CURTIME3)
AND oa.org_alias_type_cd = 1130.00 /*Encounter organization Alias*/
AND PARSER(facprompt)
ORDER BY CNVTUPPER(TRIM(org.org_name,3))
 
HEAD REPORT
	facnamelist = FILLSTRING(8000,' ')
 
DETAIL
	facnamelist = BUILD(BUILD(facnamelist, facname), ', ')
 
FOOT REPORT
	facnamelist = REPLACE(facnamelist,',','',2)
	ord_data->p_facility = EVALUATE2(IF(PARAMETER(PARAMETER2($FAC),1) = 0.0) "Facilities: All"
		ELSEIF (SUBSTRING(1,1,REFLECT(parameter(parameter2($FAC),0))) = "L") CONCAT("Facilities: ",TRIM(facnamelist,3))
		ELSE CONCAT("Facilities: ",TRIM(facname,3)) ENDIF)
 
WITH nocounter
 
/***************************************************************
	Get Ordered By vs Ordering Provider
****************************************************************/
CALL ECHO ("Get Ordered By vs Ordering Provider")
 
SELECT INTO "NL:"
FROM DUMMYT d
 
FOOT REPORT
	provprompt = EVALUATE2(IF($alldiff = 'diff') "ord_by.physician_ind IN (0)"
		ELSE "ord_by.physician_ind IN (0,1)" ENDIF)
 
	ord_data->p_alldiff = EVALUATE2(IF($alldiff = 'diff') "Show only non Providers"
			ELSE "Show all (Providers and non Providers)" ENDIF)
WITH nocounter
 
CALL ECHO ("Get the Other Prompts")
/**************************************************************
; Other Prompts
**************************************************************/
 
SELECT INTO "NL:"
FROM DUMMYT d
 
HEAD REPORT
	ord_data->p_start_date = CONCAT(FORMAT(CNVTDATE2($bdate, "dd-mmm-yyyy hh:mm:ss"), "MM/DD/YYYY;;d"), " 00:00")
	ord_data->p_end_date = CONCAT(FORMAT(CNVTDATE2($edate, "dd-mmm-yyyy hh:mm:ss"), "MM/DD/YYYY;;d"), " 23:59")
WITH nocounter
 
/**********************************************************
Get Order Data
***********************************************************/
CALL ECHO ("Get Order Data")
 
SELECT
Facility = UAR_GET_CODE_DESCRIPTION(enc.loc_facility_cd)
,Patient = TRIM(pat.name_full_formatted,3)
,DOB = FORMAT(CNVTDATETIMEUTC(pat.birth_dt_tm,1),"MM/DD/YYYY;;d")
,CMRN = TRIM(cmrn.alias,3)
,FIN = TRIM(ea.alias,3)
,Order_id = ord.order_id
,Order_Name = TRIM(ord.ordered_as_mnemonic,3)
,Order_Type = UAR_GET_CODE_DISPLAY(ord.catalog_type_cd)
,Order_Date = DATETIMEZONEFORMAT(ord.current_start_dt_tm, ord.current_start_tz,"MM/DD/YYYY hh:mm ZZZ")
,Ordering_Provider = TRIM(ord_prov.name_full_formatted,3)
,Ordered_By = TRIM(ord_by.name_full_formatted,3)
,Order_Status = UAR_GET_CODE_DISPLAY(ord.order_status_cd)
,Order_Action = UAR_GET_CODE_DISPLAY(oa_order.action_type_cd)
,Communication_Type = UAR_GET_CODE_DISPLAY(oa_order.communication_type_cd)
,Order_Proposal_Status = UAR_GET_CODE_DISPLAY(op.proposal_status_cd)
,Proposal_Communication_Type = UAR_GET_CODE_DISPLAY(op.communication_type_cd)
FROM person pat
,(INNER JOIN encounter enc ON (enc.person_id = pat.person_id
	AND enc.encntr_type_cd IN (22282402 /*Clinic*/,2554389963/*Phone Message*/,
		2560523697/*Results Only*/)
	AND enc.active_ind = 1))
,(INNER JOIN organization org ON (enc.organization_id = org.organization_id))
,(INNER JOIN encntr_alias ea ON (ea.encntr_id = enc.encntr_id
	AND ea.active_ind = 1
	AND ea.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND ea.encntr_alias_type_cd = 1077  /*FIN NBR*/))
,(INNER JOIN person_alias cmrn ON (pat.person_id = cmrn.person_id
 	AND cmrn.active_ind = 1
 	AND cmrn.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
 	AND cmrn.person_alias_type_cd = 2 /*CMRN*/))
,(INNER JOIN orders ord ON (pat.person_id = ord.person_id
	AND enc.encntr_id = ord.encntr_id
	AND ord.orig_ord_as_flag NOT IN (2 /*Recorded / Home Meds*/)))
,(INNER JOIN order_action oa_order ON (oa_order.order_id = ord.order_id
	AND oa_order.action_type_cd IN (2524 /*Activate*/, 2533 /*Modify*/, 2534 /*Order*/)))
,(INNER JOIN prsnl ord_prov ON (oa_order.order_provider_id = ord_prov.person_id))
,(INNER JOIN prsnl ord_by ON (oa_order.action_personnel_id = ord_by.person_id
	AND PARSER (provprompt)))
,(LEFT JOIN order_proposal op ON (op.order_id = ord.order_id))
WHERE pat.active_ind = 1
AND pat.name_last_key NOT IN ('FFFFPEDS','FFFFAMB','FFFFPNRC','FFFFOP','FFFFED','FFFFIP','FFFFWH','FFFFTEST','FFFFREVCYCLE',
	'FFFFPHARM','ZZGLOVER','ZZTEST','ZZWICK','ZZBOGUS','ZZZZTESTPW','ZZZREGRESSION','ZZZZBHTEST','ZZZNEUROPW','ZZZFLMCRAD',
	'ZZZFSRRAD','ZZZTESTONE','ZZZAMB','ZZZPWRAD','ZZTOPTEST','ZZZ','ZZZRMCRAD','ZZZZTESTPBH','ZZMDDONOTUSE','ZZZMPITESTP',
	'ZZZRADTEST','ZZZFSRGO','ZZZFSWRAD','ZZZTESTIP','ZZZTEST','ZZELLMER','ZZZMPITESTBL','ZZZZTESTPOC','ZZZZZZTEST','ZZZTESTOP',
	'TTTTTEST','TTTTGENLAB','TTTT','TTTTMAYO','TTTTPHARMTEST','TTTTESTFSV','TTTTONC','TTTTESTCATHLAB','TTURNER','TTEST',
	'TTTTHUDLOW','TTTTTESTFN','TTTTCAMCAPTEST',	'TTTTMDI','TTBACKLOADING','TTTTESTPRVL','TTTTMMC','TTTTQUEST','TTHOMASON',
	'TTTTPRINTER','TTTTEST')
AND ord.current_start_dt_tm BETWEEN CNVTDATETIME($BDATE) AND CNVTDATETIME($EDATE)
AND PARSER(facprompt)
ORDER BY Facility, Patient, Ordering_Provider, ord.order_id, oa_order.action_sequence
 
/****************************************************************************
	Populate Record structure with Order Data
*****************************************************************************/
 
HEAD REPORT
	cnt = 0
	CALL alterlist(ord_data->list, 10)
 
DETAIL
	cnt = cnt + 1
	IF (mod(cnt,10) = 1 OR cnt = 1)
		CALL alterlist(ord_data->list, cnt + 9)
	ENDIF
 
	ord_data->list[cnt].Facility = Facility
	ord_data->list[cnt].Patient = Patient
	ord_data->list[cnt].DOB = DOB
	ord_data->list[cnt].CMRN = CMRN
	ord_data->list[cnt].FIN = FIN
	ord_data->list[cnt].Order_id = Order_id
	ord_data->list[cnt].Order_Name = Order_Name
	ord_data->list[cnt].Order_Type = Order_Type
	ord_data->list[cnt].Order_Date = Order_Date
	ord_data->list[cnt].Ordering_Provider = Ordering_Provider
	ord_data->list[cnt].Ordered_By = Ordered_By
	ord_data->list[cnt].Order_Status = Order_Status
	ord_data->list[cnt].Order_Action = Order_Action
	ord_data->list[cnt].Communication_Type = Communication_Type
	ord_data->list[cnt].Order_Proposal_Status = Order_Proposal_Status
	ord_data->list[cnt].Proposal_Communication_Type = Proposal_Communication_Type
 
FOOT REPORT
	ord_data->rec_cnt = cnt
	CALL alterlist(ord_data->list, cnt)
WITH nocounter
 
 
/***************************************************************************
	Output Report
****************************************************************************/
 
IF(ord_data->rec_cnt > 0)
 
	CALL ECHO("Output Report")
 
	SELECT INTO $outdev
	Facility = ord_data->list[d.seq].Facility,
	Patient = ord_data->list[d.seq].Patient,
	DOB = ord_data->list[d.seq].DOB,
	CMRN = ord_data->list[d.seq].CMRN,
	FIN = ord_data->list[d.seq].FIN,
	Order_id = ord_data->list[d.seq].Order_id,
	Order_Name = ord_data->list[d.seq].Order_Name,
	Order_Type = ord_data->list[d.seq].Order_Type,
	Order_Date = ord_data->list[d.seq].Order_Date,
	Ordering_Provider = ord_data->list[d.seq].Ordering_Provider,
	Ordered_By = ord_data->list[d.seq].Ordered_By,
	Order_Status = ord_data->list[d.seq].Order_Status,
	Order_Action = ord_data->list[d.seq].Order_Action,
	Communication_Type = ord_data->list[d.seq].Communication_Type,
	Order_Proposal_Status = ord_data->list[d.seq].Order_Proposal_Status,
	Proposal_Communication_Type = ord_data->list[d.seq].Proposal_Communication_Type,
	Prompt_Values = CONCAT(CONCAT(CONCAT(CONCAT("Facility = ",TRIM(ord_data->p_facility,3)),
	  "     Ordered_By_vs_Provider = ", TRIM(ord_data->p_alldiff,3)),
      "     Start Date = ",TRIM(ord_data->p_start_date,3)),
      "     End_Date = ",TRIM(ord_data->p_end_date,3))
	FROM (dummyt d WITH seq = ord_data->rec_cnt)
	ORDER BY Facility, Ordering_Provider, Patient
    WITH nocounter, format, separator = ' '
ELSE
    SELECT INTO $outdev
         Message = "No data for the prompt values",
         Facility_Prompt = ord_data->p_facility,
         Ordered_By_Vs_Provider_Prompt = ord_data->p_alldiff,
         Begin_Date_Prompt = ord_data->p_start_date,
         End_Date_Prompt = ord_data->p_end_date
    FROM (dummyt d )
    WITH nocounter, format, separator = ' '
 
ENDIF
 
;CALL ECHORECORD(ord_data)
 
GO TO exitscript
#exitscript
 
END
GO
 
 
