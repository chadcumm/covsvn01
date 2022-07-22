 
DROP PROGRAM cov_prmpt_fac_m:DBA GO
CREATE PROGRAM cov_prmpt_fac_m:dba
 
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
 with OUTDEV
 
 
execute ccl_prompt_api_dataset "autoset"
 
;declare facility_cd = f8 with constant(uar_get_code_by("MEANING", 222, "FACILITY"))
;declare building_cd = f8 with constant(uar_get_code_by("MEANING", 222, "BUILDING"))
;declare nurse_unit_cd = f8 with constant(uar_get_code_by("MEANING", 222, "NURSEUNIT"))
 
select distinct  into "nl:"
;select distinct into value ($outdev)
 
 disp=uar_get_code_display(cv.code_value)
,desc=uar_get_code_description(cv.code_value)
,cd=cv.code_value
;,alias = cvo.alias
 
FROM
	CODE_VALUE_OUTBOUND   CVO
	, CODE_VALUE CV
 
PLAN CVO
WHERE CVO.code_set = 220
AND CVO.ALIAS_TYPE_MEANING in ( "FACILITY", "AMBULATORY")
AND CVO.contributor_source_cd =         2552933345.00
 
and
 
(
(cvo.code_value in
; 7/18 update per Shelly's spredsheet
(	2553454721	 ;	Clinton Family Physicians
,	2553454745	 ;	Crossville Medical Group
,	2553454753	 ;	Crossville Medical Group - Fairfield Glade
,	2558809797	 ;	Crossville Medical Group - OBGYN
,	2553454761	 ;	Crossville Medical Group - Walk-in
,	2553454785	 ;	Cumberland Orthopedics
,	2553455137	 ;	Family Clinic of Oak Ridge
,	2553455209	 ;	Kingston Family Practice
,	2553455233	 ;	Lake City Family Medicine
,	2555127713	 ;	MMC HEALTHWORKS
,	2555127729	 ;	MMC LAKE CITY INTERNAL MEDICINE
,	2562474733	 ;	MMCC Healthworks Rad
,	2553455249	 ;	McNeeley Family Physicians
,	2553455297	 ;	Oak Ridge Surgeons, PC
,	2553455305	 ;	Oliver Springs Family Physicians
,	2553454985	 ;	Urology Specialists of East Tennessee Alcoa
,	2553455953	 ;	Urology Specialists of East Tennessee Regional
 
;ADDED 8/21
, 2568267787     ;     Hookman Cardiology FAC
, 2568268993	 ;     Hookman Cardiology-Claiborne FAC
, 2568269229	 ;     Hookman Cardiology AMB
, 2568269335     ;     Hookman Cardiology-Claiborne AMB
 
))
 
 
Or (substring(1,1,CVO.alias) IN ("B", "F", "P"))
 
or (SUBSTRING(1,3,CVO.ALIAS) in ("EDB", "EDF", "EDP"))
 
 )
 
 
 
JOIN CV
WHERE CV.code_value = CVO.code_value
 
 
order uar_get_code_display(cv.code_value)
 
 
HEAD REPORT
	stat = MakeDataSet(2)
DETAIL
	stat = WriteRecord(0)
FOOT REPORT
	stat = CloseDataSet(0)
 
WITH nocounter, REPORTHELP, CHECK
;, format, separator = " "
 
END
 
GO
