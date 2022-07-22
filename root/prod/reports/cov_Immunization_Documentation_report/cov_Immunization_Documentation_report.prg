/*************************************************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
**************************************************************************************************************
 
	Author:				William Hulse, SR Programmer
	Date Written:		02/14/2019
	Solution:			Immunization Doc Rpt
	Source file name:	cov_Immunization_Doc_rpt.prg
	Object name:		XXXX
	Request #:			CR1027
 
	Program purpose:	To allow users to view given immunization information for state reporting.
 
	Executing from:		CCL
 
 	Special Notes:      This will be used as a report in the Reporting Portal.
 
**************************************************************************************************************
  GENERATED MODIFICATION CONTROL LOG
**************************************************************************************************************
 
 	Mod        Date	         Developer				  Comment
 	------     ---------  	 --------------------	  --------------------------------------
    001        01/24/2019    William Hulse            Created Package.
    002 	   03/20/2019    Chad Cummings			  Added Funding Source
**************************************************************************************************************/
DROP PROGRAM cov_Immunization_Doc_rpt:DBA GO
CREATE PROGRAM cov_Immunization_Doc_rpt:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "StartDate" = "SYSDATE"
	, "EndDate" = "SYSDATE"
	, "Facility" = 0
 
with OUTDEV, StartDate, EndDate, Facility
 
SELECT INTO $OUTDEV
	Facility = O.ORG_NAME
	, FacilityStreetAddress = A.STREET_ADDR
	, FacilityCity = A.CITY
	, FacilityState = A.STATE
	, FacilityZip = A.ZIPCODE
	, OrderingProviderName = PRS.NAME_FULL_FORMATTED
	, PatientLastName = P.NAME_LAST
	, PatientFirstName = P.NAME_FIRST
	, EncounterDate = E.REG_DT_TM "MM/dd/yyyy hh:mm:ss;3;d"
	, EncounterFIN = EA.ALIAS
	, OrderStatus = UAR_GET_CODE_DISPLAY(OA.ORDER_STATUS_CD)
	, Vaccine = UAR_GET_CODE_DISPLAY(VES.EVENT_CD)
	, VaccinesForChildrenStatus = UAR_GET_CODE_DISPLAY(I.VFC_STATUS_CD)
	, FundingSource = uar_get_code_display(i.funding_source_cd) ;002
	, Dose = CM.ADMIN_DOSAGE
	, Unit = UAR_GET_CODE_DISPLAY(CM.DOSAGE_UNIT_CD)
	, Route = UAR_GET_CODE_DISPLAY(CM.ADMIN_ROUTE_CD)
	, Site = UAR_GET_CODE_DISPLAY(CM.ADMIN_SITE_CD)
	, Manufacturer = UAR_GET_CODE_DISPLAY(CM.SUBSTANCE_MANUFACTURER_CD)
	, LotNumber = CM.SUBSTANCE_LOT_NUMBER
	, ExpirationDate = CM.SUBSTANCE_EXP_DT_TM "MM/dd/yyyy"
	, PerformedBy = PR.NAME_FULL_FORMATTED
	, PerformedDate = C.PERFORMED_DT_TM "MM/dd/yyyy"
	, PerformedTime = C.PERFORMED_DT_TM "@TIMEWITHSECONDS"
	, ConsentStatus = UAR_GET_CODE_DISPLAY(PC.STATUS_CD)
	, VISPublished = UAR_GET_CODE_DISPLAY(I.VIS_CD)
	, VISGiven = I.VIS_PROVIDED_ON_DT_TM "MM/dd/yyyy"
	;, EducationOn = ""
	;, EducationBy = ""
	;, EducationDate = ""
 
FROM
	V500_EVENT_SET_CODE   V
	, (INNER JOIN V500_EVENT_SET_CANON VE ON (V.event_set_cd = VE.parent_event_set_cd))
	, (INNER JOIN V500_EVENT_SET_EXPLODE VES ON (VE.event_set_cd = VES.event_set_cd))
	, (INNER JOIN CLINICAL_EVENT C ON (VES.EVENT_CD = C.EVENT_CD AND C.result_status_cd IN(25.00 /*auth*/, 34.00 /*altered*/,
35.00
/*modified*/)))
	, (INNER JOIN ENCOUNTER E ON (E.encntr_id = C.encntr_id AND E.person_id = C.person_id AND E.active_ind = 1 ))
	, (INNER JOIN ORGANIZATION O ON (E.organization_id = O.organization_id AND E.active_ind = 1 AND O.active_ind = 1))
	, (INNER JOIN PERSON P ON (P.person_id = C.person_id))
	, (INNER JOIN ENCNTR_ALIAS EA ON (E.ENCNTR_ID = EA.ENCNTR_ID AND EA.ACTIVE_IND = 1
		AND EA.ENCNTR_ALIAS_TYPE_CD = 1077.00))
	, (INNER JOIN PRSNL PR ON (C.PERFORMED_PRSNL_ID = PR.PERSON_ID))
	, (INNER JOIN ORDERS ORD ON (E.ENCNTR_ID = ORD.ENCNTR_ID AND C.ORDER_ID = ORD.ORDER_ID))
	, (INNER JOIN ORDER_ACTION OA ON (ORD.ORDER_ID = OA.ORDER_ID AND OA.ACTION_SEQUENCE = 2))
	, (INNER JOIN PRSNL PRS ON (OA.ORDER_PROVIDER_ID = PRS.PERSON_ID))
	, (LEFT JOIN ADDRESS A ON (O.ORGANIZATION_ID = A.PARENT_ENTITY_ID AND A.ADDRESS_TYPE_CD = 754.00))
	, (INNER JOIN CE_MED_RESULT CM ON (C.EVENT_ID = CM.EVENT_ID))
	, (INNER JOIN IMMUNIZATION_MODIFIER I ON (C.EVENT_ID = I.EVENT_ID))
	, (LEFT JOIN PPR_CONSENT_STATUS PC ON (E.ENCNTR_ID = PC.ENCNTR_ID AND PC.CONSENT_TYPE_CD = 23287812.00))
 
WHERE V.event_set_name = "Immunizations"
AND O.ORGANIZATION_ID = $Facility
AND C.EVENT_END_DT_TM BETWEEN CNVTDATETIME($StartDate) AND CNVTDATETIME($EndDate)
 
ORDER BY
	Facility
	, OrderingProviderName
	, PatientLastName
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
END
GO
