/*****************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
******************************************************************************************
	Author:				Dan Herren
	Date Written:		August 2021
	Solution:			Pharmacy
	Source file name:  	cov_pha_Clozapine_Extract.prg
	Object name:		cov_pha_Clozapine_Extract
	CR#:				10799
 
	Program purpose:	Peninsula Clinic's outpatient eprescribing of clozapine extract.
	Executing from:		CCL
  	Special Notes:
 
******************************************************************************************
*  	GENERATED MODIFICATION CONTROL LOG
*
*  	Revision #   Mod Date    Developer             Comment
*  	-----------  ----------  --------------------  ---------------------------------------
*
*
******************************************************************************************/
 
drop   program cov_pha_Clozapine_Extract:DBA go
create program cov_pha_Clozapine_Extract:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"     ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = ""
	, "End Date/Time" = "SYSDATE"
	, "Facility" = VALUE(0.0)
	, "Order Status" = VALUE(0.0           )
	, "Output To File" = 0
 
with OUTDEV, START_DATETIME_PMPT, END_DATETIME_PMPT, FACILITY_PMPT,
	ORD_STATUS_PMPT, OUTPUT_FILE
 
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
Record rec (
	1 rec_cnt				= i4
	1 username          	= vc
	1 startdate         	= vc
	1 enddate          	 	= vc
	1 list[*]
		2 facility      	= vc
		2 patient_name      = vc
		2 fin           	= vc
		2 birth_dt			= dq8
		2 medication		= vc
		2 mnemonic			= vc
		2 order_dt			= dq8
		2 prescribe_dt		= dq8
		2 order_provider	= vc
		2 order_status		= vc
		2 pharmacy_name		= vc
		2 pharmacy_phone	= vc
		2 encntr_id			= f8
		2 order_id			= f8
)
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare ACTIVE_VAR         	= f8 with constant(uar_get_code_by("DISPLAYKEY",  48, "ACTIVE")),protect
declare FIN_TYPE_VAR        = f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR")),protect
declare CLOZAPINE_VAR       = f8 with constant(uar_get_code_by("DISPLAYKEY", 200, "CLOZAPINE")),protect
declare ORDER_VAR       	= f8 with constant(uar_get_code_by("DISPLAYKEY",6003, "ORDER")),protect
;
declare ORD_ORDERED_VAR   	= f8 with constant(uar_get_code_by("DISPLAYKEY",6004, "ORDERED")),protect
declare ORD_COMPLETED_VAR   = f8 with constant(uar_get_code_by("DISPLAYKEY",6004, "COMPLETED")),protect
;
declare ENC_TYPE_BLOUNT_VAR = f8 with constant(uar_get_code_by("DISPLAYKEY",  71, "BLOUNTCLINICSERIES")),protect
declare ENC_TYPE_KNOX_VAR 	= f8 with constant(uar_get_code_by("DISPLAYKEY",  71, "KNOXCLINICSERIES")),protect
declare ENC_TYPE_LOUDON_VAR = f8 with constant(uar_get_code_by("DISPLAYKEY",  71, "LOUDONCLINICSERIES")),protect
declare ENC_TYPE_SEVIER_VAR = f8 with constant(uar_get_code_by("DISPLAYKEY",  71, "SEVIERCLINICSERIES")),protect
;
declare LOC_BLOUNT_VAR 		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "PBBBCG")),protect
declare LOC_LOUDON_VAR 		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "PBLLCG")),protect
declare LOC_KNOX_VAR 		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "PBLHKCG")),protect
declare LOC_SEVIER_VAR 		= f8 with constant(uar_get_code_by("DISPLAYKEY", 220, "PBSSOG")),protect
;
declare OPR_FAC_VAR		   	= vc with noconstant(fillstring(1000," "))
declare OPR_ORDSTATUS_VAR  	= vc with noconstant(fillstring(1000," "))
declare username           	= vc with protect
declare initcap()          	= c100
;
declare	START_DATETIME_VAR	= f8
declare END_DATETIME_VAR	= f8
 
;go to exitscript
 
/**************************************************************
; DVDev START CODING
**************************************************************/
;GET USERNAME FOR REPORT
select into "NL:"
from
	prsnl p
where p.person_id = reqinfo->updt_id
detail
	rec->username = p.username
with nocounter
 
 
;**************************************************************
; SET DATE-RANGE VARIABLES
;**************************************************************
if (validate(request->batch_selection) = 1 or $OUTPUT_FILE = 1)
	;=== PREVIOUS MONTH ===
	set START_DATETIME_VAR 	= datetimefind(cnvtlookbehind("1,M"),"M","B","B")
	set END_DATETIME_VAR 	= datetimefind(cnvtlookbehind("1,M"),"M","E","E")
 
	;=== SET FOR TESTING OPS-JOB EXTRACT RUN ===
;	set START_DATETIME_VAR = CNVTDATETIME("15-JUL-2021 00:00")
;	set END_DATETIME_VAR   = CNVTDATETIME("31-JUL-2021 23:59")
else
	set START_DATETIME_VAR = cnvtdatetime($START_DATETIME_PMPT)
	set END_DATETIME_VAR   = cnvtdatetime($END_DATETIME_PMPT)
endif
 
 
; SET DATE VARIABLES FOR *****  MANUAL TESTING  *****
;set START_DATETIME_VAR = CNVTDATETIME("01-JUL-2021 00:00")
;set END_DATETIME_VAR   = CNVTDATETIME("31-JUL-2021 23:59")
 
 
; SET DATES VARIABLES TO RECORD STRUCTURE
set rec->startdate = format(START_DATETIME_VAR, "mm/dd/yyyy;;q")
set rec->enddate   = format(END_DATETIME_VAR, "mm/dd/yyyy;;q")
 
 
;**************************************************************
; SET DATA-FILE VARIABLES
;**************************************************************
declare filename_var	= vc with constant(build2("clozapinemonthly_", format(END_DATETIME_VAR, "yyyymm;;q"), ".csv"))
;;declare filename_var	= vc with constant(build2("djhtest", ".csv"))
 
declare dirname1_var	= vc with constant(build("cer_temp:",  filename_var))
declare dirname2_var	= vc with constant(build("$cer_temp/", filename_var))
 
;--PRODUCTION ASTREAM--
declare filepath_var	= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
													"_cust/to_client_site/ClinicalAncillary/Pharmacy/Med_Alerts/", filename_var))
 
;--DEVELOPMENT FILE PATH FOR TESTING-
;;declare filepath_var	= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
;;													"_cust/to_client_site/CernerCCL/", filename_var))
 
;-----------------------------
; DECLARE OUTPUT VALUES
;-----------------------------
declare output_var		= vc with noconstant("")
declare cmd				= vc with noconstant("")
declare len				= i4 with noconstant(0)
declare stat			= i4 with noconstant(0)
 
;-----------------------------
; DEFINE OUTPUT VALUE
;-----------------------------
if (validate(request->batch_selection) = 1 or $OUTPUT_FILE = 1)
	set output_var = value(dirname1_var)   ;OPS JOB
else
	set output_var = value($OUTDEV)        ;DISPLAY TO SCREEN
endif
 
; SET FACILITY PROMPT VARIABLE
if(substring(1,1,reflect(parameter(parameter2($FACILITY_PMPT),0))) = "L")		;multiple values were selected
	set OPR_FAC_VAR = "in"
elseif(parameter(parameter2($FACILITY_PMPT),1)= 0.00)							;all (any) values were selected
	set OPR_FAC_VAR = "!="
else																			;a single value was selected
	set OPR_FAC_VAR = "="
endif
 
 
; SET ORDER STATUS PROMPT VARIABLE
if(substring(1,1,reflect(parameter(parameter2($ORD_STATUS_PMPT),0))) = "L")		;multiple values were selected
	set OPR_ORDSTATUS_VAR = "in"
elseif(parameter(parameter2($ORD_STATUS_PMPT),1)= 0.00)							;all (any) values were selected
	set OPR_ORDSTATUS_VAR = "!="
else																			;a single value was selected
	set OPR_ORDSTATUS_VAR = "="
endif
 
 
;==============================================================================
; MAIN DATA SELECT
;==============================================================================
call echo(build("*** MAIN DATA SELECT ***"))
select into "NL:"
	 facility			= uar_get_code_display(e.location_cd)
	,patient_name		= p.name_full_formatted
	,fin				= ea.alias
	,birth_dt			= p.birth_dt_tm
	,medication			= uar_get_code_display(o.catalog_cd)
	,mnemonic			= ocs.mnemonic
	,order_dt			= o.orig_order_dt_tm
	,prescribe_dt		= od1.oe_field_dt_tm_value
	,order_provider		= pl.name_full_formatted
	,order_status		= uar_get_code_display(o.order_status_cd)
	,pharmacy_name		= od2.oe_field_display_value
;	,pharmacy_phone		= od2.oe_field_display_value
	,encntr_id			= e.encntr_id
	,order_id			= o.order_id
;	,event				= uar_get_code_display(ce.event_cd)
;	,event_dt			= ce.event_end_dt_tm
;	,o.*
;	,ce.*
 
from ENCOUNTER e
 
	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = 1077 ;FIN_TYPE_VAR   ;1077
		and ea.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
		and ea.active_ind = 1)
 
	,(inner join ORDERS o on o.encntr_id = e.encntr_id
;	 	and o.order_id =   4584285129
		and o.catalog_cd = CLOZAPINE_VAR ;2754222
		and operator(o.order_status_cd, OPR_ORDSTATUS_VAR, $ORD_STATUS_PMPT)
;		and o.order_status_cd not in (       2545.00)
		and o.orig_order_dt_tm between cnvtdatetime(START_DATETIME_VAR) and cnvtdatetime(END_DATETIME_VAR)
;		and o.orig_order_dt_tm between cnvtdatetime("01-JAN-2021 00:00:00") and cnvtdatetime("05-JUL-2021 23:23:59")
		and o.active_ind = 1)
 
	,(inner join ORDER_ACTION oa on oa.order_id = o.order_id
        and oa.action_type_cd = ORDER_VAR ;2534.00
        and oa.action_sequence > 0)
 
	,(inner join ORDER_DETAIL od1 on od1.order_id = o.order_id
		and od1.oe_field_meaning = "REQSTARTDTTM")
 
	,(left join ORDER_DETAIL od2 on od2.order_id = o.order_id
		and od2.oe_field_meaning = "ROUTINGPHARMACYNAME")
 
	,(inner join ORDER_CATALOG_SYNONYM ocs on ocs.synonym_id = o.synonym_id ;ocs.catalog_cd = o.catalog_cd
		and ocs.active_ind = 1)
 
;	,(left join ENCNTR_LOC_HIST elh on elh.encntr_id = e.encntr_id
;		and (o.orig_order_dt_tm between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
;		and elh.active_ind = 1)
 
	,(inner join PERSON p on p.person_id = e.person_id
		and p.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
		and p.active_ind = 1)
 
	,(left join PRSNL pl on pl.person_id = oa.order_provider_id
		and pl.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
		and pl.active_ind = 1)
 
where operator(e.location_cd, OPR_FAC_VAR, $FACILITY_PMPT)
	and e.location_cd in (LOC_BLOUNT_VAR, LOC_LOUDON_VAR, LOC_KNOX_VAR, LOC_SEVIER_VAR) ;2553766251, 2553766299, 2553766283, 2553766315
;	and e.encntr_type_cd in (ENC_TYPE_BLOUNT_VAR, ENC_TYPE_KNOX_VAR, ENC_TYPE_LOUDON_VAR, ENC_TYPE_SEVIER_VAR)
	and e.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
	and e.active_ind = 1
 
order by facility, patient_name, order_dt desc, o.order_id ;,event_dt desc, ce.event_id
 
head report
	cnt = 0
 
detail
	cnt = cnt + 1
 
	if (mod(cnt,10) = 1 or cnt = 10)
		stat = alterlist(rec->list,cnt + 9)
	endif
 
 	rec->rec_cnt = cnt
 
	rec->list[cnt].facility			= facility
	rec->list[cnt].patient_name     = patient_name
	rec->list[cnt].fin				= fin
	rec->list[cnt].birth_dt			= birth_dt
	rec->list[cnt].medication		= medication
	rec->list[cnt].mnemonic			= mnemonic
	rec->list[cnt].order_dt			= order_dt
	rec->list[cnt].prescribe_dt		= prescribe_dt
	rec->list[cnt].order_provider	= order_provider
	rec->list[cnt].order_status		= order_status
	rec->list[cnt].pharmacy_name	= pharmacy_name
;	rec->list[cnt].pharmacy_phone	= pharmacy_phone
 	rec->list[cnt].encntr_id	 	= encntr_id
 	rec->list[cnt].order_id			= order_id
 
foot report
	stat = alterlist(rec->list, cnt)
 
with nocounter
 
;call echorecord(rec)
;go to exitscript
 
 
;============================
; REPORT OUTPUT
;============================
call echo("*** GENERATING OUTPUT  ***")
 
if (rec->rec_cnt > 0)
 
	if (validate(request->batch_selection) = 1 or $OUTPUT_FILE = 1)
		set modify filestream
	endif
 
	select
		if (validate(request->batch_selection) = 1 or $OUTPUT_FILE = 1)
			with nocounter, pcformat (^"^, ^,^, 1,0), format, format=stream, formfeed=none  ;no padding
		else
			with nocounter, separator = " ", format
		endif
 
	distinct into value(output_var)
 
		 facility_clinic	= substring(1,30,rec->list[d.seq].facility)
		,patient_name	   	= substring(1,50,rec->list[d.seq].patient_name)
		,fin		   		= rec->list[d.seq].fin
		,birth_date			= format(rec->list[d.seq].birth_dt, "mm/dd/yyyy;;q")
;		,medication			= substring(1,30,rec->list[d.seq].medication)
		,medication			= substring(1,30,rec->list[d.seq].mnemonic)
;		,order_dt			= format(rec->list[d.seq].order_dt, "mm/dd/yyyy hh:mm;;q")
		,prescribe_date		= format(rec->list[d.seq].prescribe_dt, "mm/dd/yyyy hh:mm;;q")
		,order_provider		= substring(1,30,rec->list[d.seq].order_provider)
		,order_status		= substring(1,30,rec->list[d.seq].order_status)
		,pharmacy_name		= substring(1,50,rec->list[d.seq].pharmacy_name)
;		,pharmacy_phone		= rec->list[d.seq].pharmacy_phone
;		,encntr_id     		= rec->list[d.seq].encntr_id
		,order_id     		= rec->list[d.seq].order_id
 
	from
		 (DUMMYT d  with seq = value(size(rec->list,5)))
 
	plan d
 
	order by facility_clinic, patient_name, rec->list[d.seq].order_dt desc, fin;, rec->list[d.seq].encntr_id, rec->list[d.seq].order_id
 
	with nocounter, format, check, separator = " "
 
	;==============================
	; COPY FILE TO AStream
	;==============================
	if (validate(request->batch_selection) = 1 or $OUTPUT_FILE = 1)
		set cmd = build2("cp ", dirname2_var, " ", filepath_var)
		set len = size(trim(cmd))
 
		call dcl(cmd, len, stat)
		call echo(build2(cmd, " : ", stat))
	endif
 
	;;call echo("**************************************************")
	;;call echo(build2("*** Directory/File name: ", dirname2_var))
	;;call echo("**************************************************")
 
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
 
