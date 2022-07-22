drop program cov_rules_audit:dba go
create program cov_rules_audit:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
 
SELECT ;INTO $OUTDEV
qryRuleName = SUBSTRING(1,26,EM.MODULE_NAME)
, qryLastUpdatePrsnl = SUBSTRING(1,20,P.NAME_FULL_FORMATTED)
, qryLastUpdateDateTime = EM.UPDT_DT_TM
    /* Had to remove Spaces, Newline, and EOTs, then substring to display */
, qryEvokingEvent = SUBSTRING(1, FINDSTRING(" ",SUBSTRING(1, 20,
replace(replace(replace(substring(1, 20, EM7.EKM_INFO),char(10)," ",0),char(13), " ",0),char(4), " ",0)),1,0),
SUBSTRING(1, 20,
replace(replace(replace(substring(1, 20, EM7.EKM_INFO),char(10)," ",0),char(13), " ",0),char(4), " ",0)))
, qryStatus = SUBSTRING(1,10,EM.MAINT_VALIDATION)
, qryBegTime = EM.MAINT_DUR_BEGIN_DT_TM "@SHORTDATETIME"
, qryEndTime = EM.MAINT_DUR_END_DT_TM "@SHORTDATETIME"
, qryInstitution = SUBSTRING(1,20,EM.MAINT_INSTITUTION)
, qryAuthor = SUBSTRING(1,20,EM.MAINT_AUTHOR)
, qrySpecialist = EM.MAINT_SPECIALIST
, qryPurpose = replace(replace(substring(1, 200, EM1.EKM_INFO),char(10)," ",0),char(13), " ",0)
, qryExplanation = replace(replace(substring(1, 200, EM2.EKM_INFO),char(10)," ",0),char(13), " ",0)
, qryKeywords = replace(replace(substring(1, 200, EM3.EKM_INFO),char(10)," ",0),char(13), " ",0)
, qryCitations = replace(replace(substring(1, 200, EM4.EKM_INFO),char(10)," ",0),char(13), " ",0)
, qryQuery = replace(replace(substring(1, 200, EM10.EKM_INFO),char(10)," ",0),char(13), " ",0)
, qryImpact = replace(replace(substring(1, 200, EM11.EKM_INFO),char(10)," ",0),char(13), " ",0)
; , em1.ekm_info
; , em2.ekm_info
; , em3.ekm_info
; , em4.ekm_info
; , em11.ekm_info
; , em10.ekm_info
, em7.ekm_info
FROM
EKS_MODULE   EM
, EKS_MODULESTORAGE   EM1
, EKS_MODULESTORAGE   EM2
, EKS_MODULESTORAGE   EM3
, EKS_MODULESTORAGE   EM4
, EKS_MODULESTORAGE   EM11
, EKS_MODULESTORAGE   EM10
, EKS_MODULESTORAGE   EM7
, PRSNL   P
PLAN EM
WHERE EM.MODULE_NAME = "*" ; REPLACE WITH PREFIX IF YOU HAVE ONE
  AND EM.VERSION = (SELECT
  MAX(E2.VERSION)
  FROM
  EKS_MODULE E2
  WHERE E2.MODULE_NAME = EM.MODULE_NAME)
; AND EM.UPDT_DT_TM        > CNVTDATETIME("18-MAY-2011 00:00:00") ;Rules edited after certain date
  AND EM.MAINT_VALIDATION IN
;  ("EXPIRED"       ;Edit statuses as needed
;                              , "EXAMPLE"
                             ("PRODUCTION"
;                              , "TESTING")
;                              , "RESEARCH")
)
;  AND EM.MAINT_DUR_BEGIN_DT_TM > SYSDATE   ;Use for looking for implicitly Expired rules
;   OR EM.MAINT_DUR_END_DT_TM   < SYSDATE   ;Use for looking for implicitly Expired rules
AND EM.MAINT_DUR_END_DT_TM > SYSDATE
JOIN EM1
WHERE EM1.MODULE_NAME = EM.MODULE_NAME
  AND EM1.VERSION = EM.VERSION
  AND EM1.DATA_TYPE = 1
  AND EM1.DATA_SEQ = 1
JOIN EM2
WHERE EM2.MODULE_NAME = EM1.MODULE_NAME
  AND EM2.DATA_SEQ = EM1.DATA_SEQ
  AND EM2.DATA_TYPE = 2
  AND EM2.VERSION = EM1.VERSION
JOIN EM3
WHERE EM3.MODULE_NAME = EM.MODULE_NAME
  AND EM3.DATA_SEQ = EM1.DATA_SEQ
  AND EM3.DATA_TYPE = 3
  AND EM3.VERSION = EM1.VERSION
JOIN EM4
WHERE EM4.MODULE_NAME = EM1.MODULE_NAME
  AND EM4.DATA_SEQ = EM1.DATA_SEQ
  AND EM4.DATA_TYPE = 4
  AND EM4.VERSION = EM1.VERSION
JOIN EM11
WHERE EM11.MODULE_NAME = EM.MODULE_NAME
AND EM11.DATA_SEQ = EM1.DATA_SEQ
AND EM11.DATA_TYPE = 11
AND EM11.VERSION = EM1.VERSION
JOIN EM10
WHERE EM10.MODULE_NAME = EM1.MODULE_NAME
  AND EM10.DATA_SEQ = EM1.DATA_SEQ
  AND EM10.DATA_TYPE = 10
  AND EM10.VERSION = EM1.VERSION
JOIN EM7
WHERE EM7.MODULE_NAME = EM1.MODULE_NAME
AND EM7.DATA_SEQ = EM1.DATA_SEQ
AND EM7.DATA_TYPE = 9
AND EM7.VERSION = EM1.VERSION
; and em7.ekm_info = "*Creat*"
JOIN P
WHERE P.PERSON_ID = EM.UPDT_ID
ORDER BY
EM.MODULE_NAME
 
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT, time = 120;, MAXREC = 10000
 
end
go
 
