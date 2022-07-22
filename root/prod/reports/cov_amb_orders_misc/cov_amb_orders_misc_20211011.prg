/*********************************************************************************
Author          :	Dawn Greer, DBA
Date Written	:	10/08/2021
Program Title	:	cov_amb_orders_misc
Source File     :	cov_amb_orders_misc.prg
Object Name     :	cov_amb_orders_misc
Directory       :	cust_script
 
Purpose         : 	Ambulatory Orders Miscellaneous
 
 
Mod     Date        Engineer                Comment
----    ----------- ----------------------- ---------------------------------------
001     10/08/2021  Dawn Greer, DBA         Original Release - CR XXXX
 
************************************************************************************/
drop program cov_amb_orders_misc go
create program cov_amb_orders_misc
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Select Facility" = 0
	, "Select Appt Begin Date" = "SYSDATE"
	, "Seelct Appt End Date" = "SYSDATE"
 
with OUTDEV, FAC, BDATE, EDATE
 
FREE RECORD a
RECORD a
(
	1	rec_cnt		=	i4
	1	qual[*]
		2	patient 		= c100
		2	dob				= c10
		2   cmrn            = c20
		2	fin				= c20
		2	order_id        = f8
		2	order_status	= c20
		2 	order_name		= c100
		2   clinical_display_line = c300
		2	order_date    	= c20
		2   endorsed_by     = c100
		2   endorsed_date   = c20
		2   endorsed_action = c20
		2	facility		= c100
)
 
DECLARE fac_opr_var = c2
DECLARE faclist = c2000
DECLARE facprompt = vc
DECLARE num = i4
DECLARE facitem = vc
 
/**********************************************************
Get CMG Facility Data
***********************************************************/
CALL ECHO ("Get Facility Prompt Data")
 
;004 Pulling the CMG List for when Any is selected in the Prompt
SELECT DISTINCT facnum = CNVTSTRING(CV.CODE_VALUE)
FROM CODE_VALUE CV, CODE_VALUE_EXTENSION CVE
WHERE CV.CODE_VALUE = CVE.CODE_VALUE
AND CV.CODE_SET = 220
AND CV.CDF_MEANING IN ('FACILITY')
AND CV.ACTIVE_IND = 1
AND CVE.FIELD_NAME = 'CMG Reporting'
ORDER BY TRIM(CV.DESCRIPTION,3)
 
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
	SET facprompt = BUILD("enc.loc_facility_cd IN ",facprompt)
 
ELSEIF(PARAMETER(PARAMETER2($FAC),1)=0.0)  ;any was selected
	SET fac_opr_var = "IN"
	SET facprompt = BUILD("enc.loc_facility_cd IN ", faclist)
ELSE 	;single value selected
	SET fac_opr_var = "="
	SET facitem = CNVTSTRING(PARAMETER(PARAMETER2($FAC),1))
	SET facprompt = BUILD("enc.loc_facility_cd = ", facitem)
ENDIF
 
 
/**********************************************************
Get Order Data
***********************************************************/
CALL ECHO ("Get Order Data")
 
SELECT DISTINCT
  Patient = TRIM(pat.name_full_formatted,3)
  ,DOB = FORMAT(CNVTDATETIMEUTC(pat.birth_dt_tm,1),"MM/DD/YYYY;;d")
  ,CMRN = TRIM(cmrn.alias,3)
  ,FIN = TRIM(ea.alias,3)
  ,Facility = TRIM(org.org_name,3)
  ,Order_id = ord.order_id
  ,Order_Status = UAR_GET_CODE_DISPLAY(ord.order_status_cd)
  ,Order_name = TRIM(oc.description,3)
  ,Clinical_display_line = TRIM(ord.clinical_display_line,3)
  ,Order_date = FORMAT(ord.current_start_dt_tm, "MM/DD/YYYY hh:mm:ss;;d")
  ,Endorsed_by = TRIM(ce_pr.name_full_formatted,3)
  ,Endorsed_Date = FORMAT(cep.action_dt_tm, "MM/DD/YYYY hh:mm:ss;;d")
  ,Endorsed_Action = UAR_GET_CODE_DISPLAY(cep.action_status_cd)
FROM orders ord
,(INNER JOIN order_catalog oc ON (ord.catalog_cd = oc.catalog_cd
	))
,(INNER JOIN ENCOUNTER enc ON (ord.encntr_id = enc.encntr_id
	AND enc.active_ind = 1
  	))
,(INNER JOIN ORGANIZATION org ON (enc.organization_id = org.organization_id
	))
,(INNER JOIN ENCNTR_ALIAS ea ON (ea.encntr_id = enc.encntr_id
	AND ea.active_ind = 1
	AND ea.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
	AND ea.encntr_alias_type_cd = 1077  /*FIN NBR*/
	))
,(INNER JOIN PERSON pat ON (ord.person_id = pat.person_id
	AND enc.person_id = pat.person_id
	AND pat.active_ind = 1
	AND pat.name_last_key NOT IN ('FFFFPEDS','FFFFAMB','FFFFPNRC','FFFFOP','FFFFED','FFFFIP','FFFFWH','FFFFTEST','FFFFREVCYCLE',
		'FFFFPHARM','ZZGLOVER','ZZTEST','ZZWICK','ZZBOGUS','ZZZZTESTPW','ZZZREGRESSION','ZZZZBHTEST','ZZZNEUROPW','ZZZFLMCRAD',
		'ZZZFSRRAD','ZZZTESTONE','ZZZAMB','ZZZPWRAD','ZZTOPTEST','ZZZ','ZZZRMCRAD','ZZZZTESTPBH','ZZMDDONOTUSE','ZZZMPITESTP',
		'ZZZRADTEST','ZZZFSRGO','ZZZFSWRAD','ZZZTESTIP','ZZZTEST','ZZELLMER','ZZZMPITESTBL','ZZZZTESTPOC','ZZZZZZTEST','ZZZTESTOP',
		'TTTTTEST','TTTTGENLAB','TTTT','TTTTMAYO','TTTTPHARMTEST','TTTTESTFSV','TTTTONC','TTTTESTCATHLAB','TTURNER','TTEST',
		'TTTTHUDLOW','TTTTTESTFN','TTTTCAMCAPTEST',	'TTTTMDI','TTBACKLOADING','TTTTESTPRVL','TTTTMMC','TTTTQUEST','TTHOMASON',
		'TTTTPRINTER','TTTTEST')
	))
,(LEFT JOIN PERSON_ALIAS cmrn ON (pat.person_id = cmrn.person_id		;009
 	AND cmrn.active_ind = 1
 	AND cmrn.end_effective_dt_tm > CNVTDATETIME(CURDATE,CURTIME3)
 	AND cmrn.person_alias_type_cd = 2 /*CMRN*/
	))
,(LEFT JOIN CLINICAL_EVENT ce ON (ord.order_id = ce.order_id))
,(LEFT JOIN CE_EVENT_PRSNL cep ON (ce.event_id = cep.event_id
	AND cep.action_type_cd = 678654.00 /*Endorse*/))
,(LEFT JOIN PRSNL ce_pr ON (cep.action_prsnl_id = ce_pr.person_id))	
WHERE PARSER(facprompt)
AND ord.catalog_cd IN (2564251037 /*Ambulatory Misc Order*/, 3550404339 /*Miscellaneous Lab Test LabCorp*/,
	31717349 /*Miscellaneous Lab Test Mayo*/,2597523557 /*Miscellaneous Lab Test Other*/,
	2553894063 /*Miscellaneous Lab Test Quest/, 2560509609 /*Miscellaneous Lab Test Quest - Amb*/)
AND ord.current_start_dt_tm BETWEEN CNVTDATETIME($bdate) AND CNVTDATETIME($edate)
 
HEAD REPORT
	cnt = 0
	CALL alterlist(a->qual, 10)
 
DETAIL
	cnt = cnt + 1
	IF (mod(cnt,10) = 1 OR cnt = 1)
		stat = alterlist(a->qual, cnt + 9)
	ENDIF
 
	a->qual[cnt].patient = patient
	a->qual[cnt].dob = FORMAT(dob, "MM/DD/YYYY")
	a->qual[cnt].cmrn = cmrn
	a->qual[cnt].fin = fin
	a->qual[cnt].order_id = order_Id,
	a->qual[cnt].order_status = order_status
	a->qual[cnt].order_name = order_name
	a->qual[cnt].order_date = order_date
	a->qual[cnt].clinical_display_line = clinical_display_line
	a->qual[cnt].endorsed_by = endorsed_by
	a->qual[cnt].endorsed_date = endorsed_date
	a->qual[cnt].endorsed_action = endorsed_action
	a->qual[cnt].facility = facility
 
FOOT REPORT
	stat = alterlist(a->qual, cnt )
	a->rec_cnt = cnt
WITH nocounter
 
 
/***************************************************************************
	Output Report
****************************************************************************/
 
IF(a->rec_cnt >= 0)
 
	SELECT INTO $outdev
		Facility = a->qual[d.seq].facility,
		Patient = a->qual[d.seq].patient,
		DOB = a->qual[d.seq].DOB,
		CMRN = a->qual[d.seq].cmrn,
		FIN = a->qual[d.seq].fin,
		Order_id = a->qual[d.seq].order_id,
		Order_Status = a->qual[d.seq].order_status,
		Order_Name = a->qual[d.seq].Order_Name,
		Order_Date = a->qual[d.seq].Order_Date,
		Clinical_Display_Line = a->qual[d.seq].Clinical_Display_line,
		Endorsed_By = a->qual[d.seq].endorsed_by,
		Endorsed_Date = a->qual[d.seq].endorsed_date,
		Endorsed_Action = a->qual[d.seq].Endorsed_action
	FROM (dummyt d WITH seq = a->rec_cnt)
	ORDER BY Facility, Patient, Order_Date
	WITH nocounter, format, separator = ' '
ENDIF
 
CALL ECHORECORD(a)
 
GO TO exitscript
#exitscript
 
END
GO
 
 
