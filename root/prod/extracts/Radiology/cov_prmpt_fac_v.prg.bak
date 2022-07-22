/*********************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
**********************************************************************************
 
	Author:				Alix Govatsos
	Date Written:		07/30/2018
	Solution:			RadNet - Radiology
	Source file name:	cov_prmpt_fac_v.prg
	Object name:		cov_prmpt_fac_v
	Request #:			
 
	Program purpose:	Provides locations for Vista Radiology facility prompt.
 
	Executing from:		CCL
 
 	Special Notes:		
 
**********************************************************************************
  GENERATED MODIFICATION CONTROL LOG
**********************************************************************************
 
 	Mod	Date		Developer				Comment
 	---	----------	--------------------	--------------------------------------
 		07/30/2018	Alix Govatsos			Initial version
 		
**********************************************************************************/
  
DROP PROGRAM cov_prmpt_fac_v:DBA GO
CREATE PROGRAM cov_prmpt_fac_v:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
 with OUTDEV
 
execute ccl_prompt_api_dataset "autoset"
 
;Vista Radiology (Regional, Loudoun, Parkwest, LeConte, Roane)
 
 
;declare facility_cd = f8 with constant(uar_get_code_by("MEANING", 222, "FACILITY"))
;declare building_cd = f8 with constant(uar_get_code_by("MEANING", 222, "BUILDING"))
;declare nurse_unit_cd = f8 with constant(uar_get_code_by("MEANING", 222, "NURSEUNIT"))
 
select distinct  into "nl:"
;select distinct into value ($outdev)
 
 disp=uar_get_code_display(cv.code_value)
,desc=uar_get_code_description(cvo.code_value)
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
(	2553028381	 ;	Cardiology Associates of East Tennessee Athens
,	2557509303	 ;	Cardiology Associates of East Tennessee Crossville
,	2553028415	 ;	Cardiology Associates of East Tennessee Decatur
,	2553028275	 ;	Cardiology Associates of East Tennessee Lenoir City
,	2557509379	 ;	Cardiology Associates of East Tennessee Oneida
,	2553028245	 ;	Cardiology Associates of East Tennessee Parkwest
,	2553454689	 ;	Cardiology Associates of East Tennessee TAVR
,	2553454817	 ;	East Tennessee Urology
,	2553455113	 ;	FamilyCare Specialists 1300
,	2553455121	 ;	FamilyCare Specialists 1320
,	2553455129	 ;	FamilyCare Specialists Walkin
,	2553455185	 ;	Internal Medicine Associates
,	2553455193	 ;	Internal Medicine West
,	2553455225	 ;	Knoxville Heart Center
,	2553454833	 ;	Knoxville Heart Group
,	2553454873	 ;	Knoxville Heart Group Harrogate
,	2553454865	 ;	Knoxville Heart Group Jeff City
,	2553454841	 ;	Knoxville Heart Group Morristown
,	2559325883	 ;	Knoxville Heart Group Oak Ridge
,	2553454849	 ;	Knoxville Heart Group Sevierville
,	2553454857	 ;	Knoxville Heart Group Seymour
,	2553454881	 ;	Knoxville Heart Group Tazewell
,	2553455345	 ;	Lakeway Orthopedic Clinic
,	2553456689	 ;	Lakeway Othopaedic Clinic
,	2553454889	 ;	LeConte Cardiology Associates
,	2553454897	 ;	LeConte Pulmonary & Critical Care Medicine
,	2553455033	 ;	Medical Associates of Carter
,	2553455265	 ;	Miriam B Tedder MD
,	2561445113	 ;	RMC MIRIAM TEDDER MD
,	2553455369	 ;	Roane County Family Practice
,	2553455057	 ;	Southern Medical Group
,	2553455065	 ;	Southern Medical Group South
,	2553454945	 ;	TN Brain and Spine Alcoa
,	2553454961	 ;	TN Brain and Spine Harriman
,	2553454937	 ;	TN Brain and Spine Knox
,	2553454953	 ;	TN Brain and Spine Sevier
,	2553454969	 ;	TN Brain and Spine West
,	2553455073	 ;	Topside Physicians
,	2553028299	 ;	West Lake Surgical Associates
))
 
 
Or (substring(1,1,CVO.alias) IN ("S", "F", "L", "P", "R"))
 
or (SUBSTRING(1,3,CVO.ALIAS) in ("EDS", "EDF", "EDL", "EDP", "EDR"))
 
 )
 
 
;F	Fort Sanders Regional Medical Center
;L	Fort Loudoun Medical Center
;P	Parkwest Medical Center
;R	Roane Medical Center
;S	LeConte Medical Center
 
 
 
JOIN CV
WHERE CV.code_value = CVO.code_value
 
 
order by desc ; uar_get_code_display(cv.code_value)
 
HEAD REPORT
	stat = MakeDataSet(2)
DETAIL
	stat = WriteRecord(0)
FOOT REPORT
	stat = CloseDataSet(0)
 
 
WITH nocounter, REPORTHELP, CHECK
;, format, separator = " "
;WITH nocounter, format, check, separator = " "
END
 
GO
