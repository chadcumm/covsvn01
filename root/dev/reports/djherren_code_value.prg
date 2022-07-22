;==============================================
; DISPLAY CODE_VALUE DATA BY AD-HOC
;==============================================
SELECT
	 code_set      = cv.code_set
	,code_set_name = cvs.display
	,code_value    = cv.code_value
	,cdf_meaning   = cv.cdf_meaning
	,display       = cnvtupper(cv.display)
	,display_key   = cv.display_key
	,description   = cv.description
 	,cki           = cv.cki
 
FROM
	 code_value cv
	,code_value_set cvs
 
WHERE cvs.code_set = cv.code_set
	AND cv.active_ind = 1
;	AND cv.code_set = 200 ; 4003149 ;10036
	AND cv.code_value =  2517
;	AND cv.code_value in (2558812301.00, 2561117857.00, 2561117261.00)
;	AND cv.code_value in ( 2552503657.00, 2553765291.00, 2552503635.00,   21250403.00, 2552503653.00, 2552503613.00, 2552503639.00
;	, 2552503645.00, 2552503649.00) ;FACILITIES
;	AND cnvtlower(cvs.display) = "*decease*"
;	AND cnvtlower(cv.cdf_meaning) = "*rad*"
;	AND cnvtlower(cv.display) = "*radio*"
;	AND cnvtupper(cv.display_key) = "RESUSCITATIONSTATUS" ; "NURSECIRCULATOR" ;"REASONFORVISIT" ;"ADMITTRANSFERDISCHARGE"
;	AND cnvtupper(cv.display_key) in ("CLMC","FLMC","FSR","LCMC","MMC","MHHS","PW","RMC")
;	AND cnvtlower(cv.description) in ("*medical center*")
;	AND cv.cki = "CKI.CODEVALUE!4101498946"
 
ORDER BY
	 cv.code_set
	,cnvtupper(cv.display)
 
WITH FORMAT, SEPARATOR = " ", TIME = 30
 
 
 
 
select
	 A = uar_get_code_by("DISPLAY_KEY",71,"OUTPATIENT")
	,B = uar_get_code_by("DISPLAY_KEY",72,"SNICEMERGENCYPROCEDURE")   ;uar_get_code_by("DISPLAY_KEY",3,"EMERGENCY")
	,C = uar_get_code_by("DISPLAY_KEY",72,"SNICTRAUMAPROCEDURE")      ;uar_get_code_by("DISPLAY_KEY",3,"TRAUMA")
	,D = uar_get_code_by("DISPLAY_KEY",72,"SNICLAPAROSCOPEPROCEDURE")
	,E = uar_get_code_by("DISPLAY_KEY",72,"SNDPCLOSURETECHNIQUE")
	,F = uar_get_code_by("DISPLAY_KEY",72,"HEIGHTLENGTHMEASURED")
	,G = uar_get_code_by("DISPLAY_KEY",72,"WEIGHTDOSING")
	,H = uar_get_code_by("MEANING",17,"DISCHARGE")
	,I = uar_get_code_by_CKI("CKI.CODEVALUE!4101498946")
	,J = uar_get_code_by("DISPLAY_KEY",104086,"DIABETESTYPE1")
from dummyt
