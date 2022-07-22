;==========================================
; Covenant Health Information Technology
; Knoxville, Tennessee
;
; Dan Herren
; Code-Value Table Lookup
;==========================================
 
drop program cov_code_value_lookup go
create program cov_code_value_lookup
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Code Set" = 0
	, "Code Value" = 0
	, "Display Value" = ""
	, "Display Key Value" = ""
	, "Description Value" = ""
	, "CDF Meaning Value" = ""
	, "CKI Value" = ""
	, "Concept CKI Value" = ""
	;<<hidden>>"Clear Prompts" = 0
 
with OUTDEV, CODE_SET_PMPT, CODE_VALUE_PMPT, DISPLAY_PMPT, DISPLAY_KEY_PMPT,
	DESCRIPTION_PMPT, CDF_MEANING_PMPT, CKI_PMPT, CONCEPT_CKI_PMPT
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare CODE_SET_VAR 	= vc with protect, noconstant("")
declare CODE_VALUE_VAR	= vc with protect, noconstant("")
declare DISPLAY_VAR		= vc with protect, noconstant("")
declare DISPLAY_KEY_VAR	= vc with protect, noconstant("")
declare DISPLAY_VAR		= vc with protect, noconstant("")
declare DESCRIPTION_VAR	= vc with protect, noconstant("")
declare CDF_MEANING_VAR	= vc with protect, noconstant("")
declare CKI_VAR			= vc with protect, noconstant("")
declare CONCEPT_CKI_VAR	= vc with protect, noconstant("")
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
	if ($CODE_SET_PMPT = null)
		set CODE_SET_VAR = "1=1"
	else
		set CODE_SET_VAR = build2("cv.code_set = ", $CODE_SET_PMPT)
	endif
 
	if ($CODE_VALUE_PMPT = null)
		set CODE_VALUE_VAR = "1=1"
	else
		set CODE_VALUE_VAR = build2("cv.code_value = ", $CODE_VALUE_PMPT)
	endif
 
	if ($DISPLAY_PMPT = null)
		set DISPLAY_VAR = "1=1"
	else
		set DISPLAY_VAR = build2("cnvtupper(cv.display) = '", $DISPLAY_PMPT, "'")
	endif
 
	if ($DISPLAY_KEY_PMPT = null)
		set DISPLAY_KEY_VAR = "1=1"
	else
		set DISPLAY_KEY_VAR = build2("cnvtupper(cv.display_key) = '", $DISPLAY_KEY_PMPT, "'")
	endif
 
	if ($DESCRIPTION_PMPT = null)
		set DESCRIPTION_VAR = "1=1"
	else
		set DESCRIPTION_VAR = build2("cnvtupper(cv.description) = '", $DESCRIPTION_PMPT, "'")
	endif
 
	if ($CDF_MEANING_PMPT = null)
		set CDF_MEANING_VAR = "1=1"
	else
		set CDF_MEANING_VAR = build2("cnvtupper(cv.cdf_meaning) = '", $CDF_MEANING_PMPT, "'")
	endif
 
	if ($CKI_PMPT = null)
		set CKI_VAR = "1=1"
	else
		set CKI_VAR = build2("cnvtupper(cv.cki) = '", $CKI_PMPT, "'")
	endif
 
	if ($CONCEPT_CKI_PMPT = null)
		set CONCEPT_CKI_VAR = "1=1"
	else
		set CONCEPT_CKI_VAR = build2("cnvtupper(cv.concept_cki) = '", $CONCEPT_CKI_PMPT, "'")
	endif
 
select into $OUTDEV
 
	 code_set      	= cv.code_set
	,code_set_name 	= cvs.display
	,code_value    	= cv.code_value
	,display       	= cv.display
	,display_key   	= cv.display_key
	,description   	= cv.description
	,cdf_meaning   	= cv.cdf_meaning
 	,cki           	= cv.cki
	,concept_cki	= cv.concept_cki
 
from CODE_VALUE cv
 
	,(inner join CODE_VALUE_SET cvs on cvs.code_set = cv.code_set)
 
where 1=1
	and parser(CODE_SET_VAR)
	and parser(CODE_VALUE_VAR)
	and parser(DISPLAY_VAR)
	and parser(DISPLAY_KEY_VAR)
	and parser(DESCRIPTION_VAR)
	and parser(CDF_MEANING_VAR)
	and parser(CKI_VAR)
	and parser(CONCEPT_CKI_VAR)
 
order by cv.code_set, cv.display, cv.code_value
 
with time=15, nocounter, separator = " ", format
 
end
go
 
 
 
 
