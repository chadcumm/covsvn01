/*****************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
******************************************************************************************
	Author:				Dan Herren
	Date Written:
	Solution:
	Source file name:	cov_PhysTrack_Order_Build.prg
	Object name:		cov_PhysTrack_Order_Build
	CR#:
 
	Program purpose:
	Executing from:		CCL
 
******************************************************************************************
*  	GENERATED MODIFICATION CONTROL LOG
*
*  	Revision #   Mod Date    Developer             Comment
*  	-----------  ----------  --------------------  ---------------------------------------
*
*
******************************************************************************************/
 
drop   program cov_PhysTrack_Order_Build:DBA go
create program cov_PhysTrack_Order_Build:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Catalog Type" = 0.0
	, "Activity Type" = VALUE(0.00            )
	, "Virtual View" = VALUE(0.00          )
	, "Orderable Name" = ""                       ;* ( Use * for wildcard )
	, "" = 2 

with OUTDEV, CATALOG_TYPE_PMPT, ACTIVITY_TYPE_PMPT, VIRTUAL_VIEW_PMPT, 
	ORDER_NAME_PMPT, HIDE_FLAG_PMPT
 
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
Record rec (
	1 rec_cnt					= i4
	1 username					= vc
	1 startdate					= vc
	1 enddate					= vc
	1 list[*]
		2 catalog_type			= vc
		2 activity_type			= vc
		2 subactivity_type		= vc
		2 primary_mnemonic		= vc
		2 active_flag			= i2
		2 hide_flag				= i2
		2 virtual_view			= vc
)
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
; PROMPT VARIABLES
declare	OPR_CAT_TYPE_VAR	= vc with noconstant(fillstring(1000," "))
declare	OPR_ACT_TYPE_VAR	= vc with noconstant(fillstring(1000," "))
declare	OPR_VV_VAR			= vc with noconstant(fillstring(1000," "))
declare OPR_HIDE_FLAG_VAR	= vc with noconstant(fillstring(1000," "))
 
; VIRTUAL VIEW FACILITIES
;declare CMC_VAR             = f8 with constant(uar_get_code_by("DISPLAYKEY",220, "CMC")),protect
;declare COVCORPHOSP_VAR     = f8 with constant(uar_get_code_by("DISPLAYKEY",220, "COVCORPHOSP")),protect
;declare FLMC_VAR            = f8 with constant(uar_get_code_by("DISPLAYKEY",220, "FLMC")),protect
;declare FSR_VAR             = f8 with constant(uar_get_code_by("DISPLAYKEY",220, "FSR")),protect
;declare FSRPATNEAL_VAR      = f8 with constant(uar_get_code_by("DISPLAYKEY",220, "FSRPATNEAL")),protect
;declare FSRTCU_VAR          = f8 with constant(uar_get_code_by("DISPLAYKEY",220, "FSRTCU")),protect
;declare LCMC_VAR            = f8 with constant(uar_get_code_by("DISPLAYKEY",220, "LCMC")),protect
;declare LCMCNSGHOME_VAR     = f8 with constant(uar_get_code_by("DISPLAYKEY",220, "LCMCNSGHOME")),protect
;declare MHHS_VAR            = f8 with constant(uar_get_code_by("DISPLAYKEY",220, "MHHS")),protect
;declare MHHSASC_VAR         = f8 with constant(uar_get_code_by("DISPLAYKEY",220, "MHHSASC")),protect
;declare MHHSBEHAVHLTH_VAR   = f8 with constant(uar_get_code_by("DISPLAYKEY",220, "MHHSBEHAVHLTH")),protect
;declare MMC_VAR             = f8 with constant(uar_get_code_by("DISPLAYKEY",220, "MMC")),protect
;declare PW_VAR            	 = f8 with constant(uar_get_code_by("DISPLAYKEY",220, "PW")),protect
;declare PWSENIORBEHAV_VAR   = f8 with constant(uar_get_code_by("DISPLAYKEY",220, "PWSENIORBEHAV")),protect
;declare RMC_VAR             = f8 with constant(uar_get_code_by("DISPLAYKEY",220, "RMC")),protect
 
; MISC VARIABLES
declare username           		= vc with protect
;
 
/**************************************************************
; DVDev START CODING
**************************************************************/
; GET USERNAME FOR REPORT
select into "NL:"
from
	prsnl p
where p.person_id = reqinfo->updt_id
detail
	rec->username = p.username
with nocounter
 
 
; SET CATALOG TYPE PROMPT VARIABLE
if(substring(1,1,reflect(parameter(parameter2($CATALOG_TYPE_PMPT),0))) = "L")	;multiple values were selected
	set OPR_CAT_TYPE_VAR = "in"
elseif(parameter(parameter2($CATALOG_TYPE_PMPT),1)= 0.00)						;all (any) values were selected
	set OPR_CAT_TYPE_VAR = "!="
else																			;a single value was selected
	set OPR_CAT_TYPE_VAR = "="
endif
 
; SET ACTIVITY TYPE PROMPT VARIABLE
if(substring(1,1,reflect(parameter(parameter2($ACTIVITY_TYPE_PMPT),0))) = "L")	;multiple values were selected
	set OPR_ACT_TYPE_VAR = "in"
elseif(parameter(parameter2($ACTIVITY_TYPE_PMPT),1)= 0.00)						;all (any) values were selected
	set OPR_ACT_TYPE_VAR = "!="
else																			;a single value was selected
	set OPR_ACT_TYPE_VAR = "="
endif
 
; SET VIRTUAL VIEW PROMPT VARIABLE
if(substring(1,1,reflect(parameter(parameter2($VIRTUAL_VIEW_PMPT),0))) = "L")	;multiple values were selected
	set OPR_VV_VAR = "in"
elseif(parameter(parameter2($VIRTUAL_VIEW_PMPT),1)= 0.00)						;all (any) values were selected
	set OPR_VV_VAR = "!="
else																			;a single value was selected
	set OPR_VV_VAR = "="
endif
 
; SET HIDDEN FLAG PROMPT VARIABLE
if(parameter(parameter2($HIDE_FLAG_PMPT),1) = 1)								;hidden values were selected
	set OPR_HIDE_FLAG_VAR = "="
elseif(parameter(parameter2($HIDE_FLAG_PMPT),1)= 0)								;non hidden values were selected
	set OPR_HIDE_FLAG_VAR = "="
else																			;both value was selected
	set OPR_HIDE_FLAG_VAR = "!="
endif
 
; SET ORDER NAME PROMPT VARIABLE
if ($ORDER_NAME_PMPT = null)
	set OPR_ORDER_NAME_VAR = "cnvtupper(oc.primary_mnemonic) != null"
else
;	set OPR_ORDER_NAME_VAR = build2('cnvtupper(oc.primary_mnemonic) = "*', $ORDER_NAME_PMPT, '*"')
	set OPR_ORDER_NAME_VAR = build2('cnvtupper(oc.primary_mnemonic) = "', $ORDER_NAME_PMPT, '"')
;	set OPR_ACT_TYPE_VAR = "!="
endif
 
 
;====================================================
;MAIN SELECT FOR DATA
;====================================================
if ($VIRTUAL_VIEW_PMPT = 0.00)
 
	select into "NL:"
	from ORDER_CATALOG oc
 
		,(inner join ORDER_CATALOG_SYNONYM ocs on ocs.catalog_cd = oc.catalog_cd
			and operator(ocs.hide_flag, OPR_HIDE_FLAG_VAR, $HIDE_FLAG_PMPT))
 
		,(left join OCS_FACILITY_R ofr on ofr.synonym_id = ocs.synonym_id
			and ofr.facility_cd in (
					select distinct
						cv_code = cv.code_value
					from CODE_VALUE cv
					where cv.code_set = 220
						and cv.code_value in (2552503657,2552552449,2552503635,21250403,
							2553765571,2553765707,2552503653,2553765371,2552503639,2553765467,
							2553765475,2552503613,2552503645,2553765531,2552503649)))
 
	where oc.catalog_cd > 0
		and operator(oc.catalog_type_cd, OPR_CAT_TYPE_VAR, $CATALOG_TYPE_PMPT)
		and operator(oc.activity_type_cd, OPR_ACT_TYPE_VAR, $ACTIVITY_TYPE_PMPT)
		and cnvtlower(oc.primary_mnemonic) != "zz*"
		and parser(OPR_ORDER_NAME_VAR)
 
	order by oc.catalog_type_cd, ocs.activity_type_cd
 
	head report
		cnt  = 0
 
		call alterlist(rec->list, 10)
 
	detail
 
		cnt = cnt + 1
 
		call alterlist(rec->list, cnt)
 
	 	rec->rec_cnt = cnt
 
		rec->list[cnt].catalog_type		= uar_get_code_display(oc.catalog_type_cd)
		rec->list[cnt].activity_type	= uar_get_code_display(oc.activity_type_cd)
		rec->list[cnt].subactivity_type	= uar_get_code_display(ocs.activity_subtype_cd)
		rec->list[cnt].primary_mnemonic	= oc.primary_mnemonic
		rec->list[cnt].active_flag		= oc.active_ind
		rec->list[cnt].hide_flag		= ocs.hide_flag
		rec->list[cnt].virtual_view		= uar_get_code_display(ofr.facility_cd)
 
	foot report
		stat = alterlist(rec->list, cnt)
 
	with nocounter
 
else
 
	select into "NL:"
	from ORDER_CATALOG oc
 
		,(inner join ORDER_CATALOG_SYNONYM ocs on ocs.catalog_cd = oc.catalog_cd
			and operator(ocs.hide_flag, OPR_HIDE_FLAG_VAR, $HIDE_FLAG_PMPT))
 
		,(inner join OCS_FACILITY_R ofr on ofr.synonym_id = ocs.synonym_id
			and operator(ofr.facility_cd, OPR_VV_VAR, $VIRTUAL_VIEW_PMPT)
			and ofr.facility_cd in (2552503657,2552552449,2552503635,21250403,
				2553765571,2553765707,2552503653,2553765371,2552503639,2553765467,
				2553765475,2552503613,2552503645,2553765531,2552503649))
 
	where oc.catalog_cd > 0
		and operator(oc.catalog_type_cd, OPR_CAT_TYPE_VAR, $CATALOG_TYPE_PMPT)
		and operator(oc.activity_type_cd, OPR_ACT_TYPE_VAR, $ACTIVITY_TYPE_PMPT)
		and cnvtlower(oc.primary_mnemonic) != "zz*"
		and parser(OPR_ORDER_NAME_VAR)
 
	order by oc.catalog_type_cd, ocs.activity_type_cd
 
 
	head report
		cnt  = 0
 
		call alterlist(rec->list, 10)
 
	detail
 
		cnt = cnt + 1
 
		call alterlist(rec->list, cnt)
 
	 	rec->rec_cnt = cnt
 
		rec->list[cnt].catalog_type		= uar_get_code_display(oc.catalog_type_cd)
		rec->list[cnt].activity_type	= uar_get_code_display(oc.activity_type_cd)
		rec->list[cnt].subactivity_type	= uar_get_code_display(ocs.activity_subtype_cd)
		rec->list[cnt].primary_mnemonic	= oc.primary_mnemonic
		rec->list[cnt].active_flag		= oc.active_ind
		rec->list[cnt].hide_flag		= ocs.hide_flag
		rec->list[cnt].virtual_view		= uar_get_code_display(ofr.facility_cd)
 
	foot report
		stat = alterlist(rec->list, cnt)
 
	with nocounter
 
endif
 
call echorecord(rec)
;go to exitscript
 
 
;====================================================
; REPORT OUTPUT
;====================================================
if (rec->rec_cnt > 0)
 
	select distinct into value ($OUTDEV)
		 catalog_type		= substring(1,90,rec->list[d.seq].catalog_type)
		,activity_type		= substring(1,30,rec->list[d.seq].activity_type)
		,subactivity_type	= substring(1,30,rec->list[d.seq].subactivity_type)
		,primary_mnemonic	= substring(1,90,rec->list[d.seq].primary_mnemonic)
		,active				= rec->list[d.seq].active_flag
		,hide				= rec->list[d.seq].hide_flag
		,virtual_view		= substring(1,90,rec->list[d.seq].virtual_view)
;		,username      		= rec->username
;		,rec_cnt			= rec->rec_cnt
 
	from
		 (DUMMYT d  with seq = value(size(rec->list,5)))
 
	plan d
 
	order by catalog_type, activity_type, virtual_view, primary_mnemonic, subactivity_type
 
	with nocounter, format, check, separator = " "
 
else
 
	select into $OUTDEV
	from DUMMYT d
 
	head report
		call center("No records found for parameter input.",0,150)
 
	with nocounter
 
endif
 
#exitscript
end
go
 
