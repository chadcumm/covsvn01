/*************************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
**************************************************************************************************
	Author:				Dan Herren
	Date Written:		December 2021
	Solution:
	Source file name:  	cov_peri_implanthistory.prg
	Object name:		cov_peri_implanthistory
	CR#:				11680
 
	Program purpose:
	Executing from:		CCL
  	Special Notes:
 
**************************************************************************************************
*  	GENERATED MODIFICATION CONTROL LOG
*
*  	Revision #   Mod Date    Developer             Comment
*  	-----------  ----------  --------------------  -----------------------------------------------
*
*
**************************************************************************************************/
 
drop   program cov_peri_implanthistory:DBA go
create program cov_peri_implanthistory:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"        ;* Enter or select the printer or file name to send this report to.
	, "Begin Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Select Facility" = VALUE(0.00          )
	, "Manufacturer search (*)" = ""              ;* (*) WILDCARD
	, "Mfr Catalog Number search (*)" = ""        ;* (*) WILDCARD
	, "Item number search (*)" = ""               ;* (*) WILDCARD
	, "Lot number search (*)" = ""                ;* (*) WILDCARD
	, "Serial number search (*)" = ""             ;* (*) WILDCARD
	;<<hidden>>"Reset Prompts" = ""
 
with OUTDEV, START_DATETIME_PMPT, END_DATETIME_PMPT, FACILITY_PMPT,
	MANUFACTURER_PMPT, CATALOG_NBR_PMPT, ITEM_NBR_PMPT, LOT_NBR_PMPT, SERIAL_NBR_PMPT
 
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
Record rec (
	1 username          				= vc
	1 startdate         				= vc
	1 enddate          	 				= vc
	1 encntr_cnt						= i4
	1 list[*]
		2 encounter_table				= vc
		2 facility      				= vc
		2 nurse_unit					= vc
		2 patient_name      			= vc
		2 fin           				= vc
 
;IMPLANT_HISTORY
		2 implant_history_table			= vc
		2 implant_data_source			= vc
		2 implant_type					= vc
		2 biological_imp_src			= vc
		2 non_biological_imp_type		= vc
		2 item_number					= vc
		2 item_description				= vc
		2 implant_item_ft				= vc
		2 body_site						= vc
		2 donor_number_txt				= vc
		2 implanted_facility			= vc
		2 implanted_facility_ft			= vc
		2 implanted_dt_tm				= dq8
		2 explant_dt_tm					= dq8
		2 explant_reason				= vc
		2 udi_txt						= vc
		2 lot_number					= vc
		2 serial_number					= vc
		2 manufactured_dt_tm			= dq8
		2 manufacturer					= vc
		2 manufacturer_ft				= vc
		2 manufacturer_model_nbr_txt	= vc
		2 mr_classification				= vc
		2 procedure						= vc
		2 procedure_ft					= vc
		2 implanted_quantity			= i4
		2 updt_dt_tm					= dq8
		2 expiration_dt_tm				= dq8
		2 gmdn_pt_name					= vc
		2 catalog_number				= vc
 
;SURGICAL_CASE
		2 surg_case_nbr					= vc
		2 surgical_case_table			= vc
		2 surgical_area					= vc
		2 surgeon_prsnl					= vc
		2 anesth_prsnl					= vc
		2 anesth_prsnl_id				= f8
		2 surg_op_loc					= vc
		2 surgeon_specialty				= vc
		2 wound_class					= vc
		2 surg_start_dt_tm				= dq8
		2 surg_stop_dt_tm				= dq8
		2 surg_start_day				= i4
		2 surg_start_hour				= i4
		2 surg_start_month				= i4
		2 surg_complete_qty				= i4
		2 surg_dur_min					= i4
		2 curr_case_status				= vc
		2 curr_case_status_dt_tm		= dq8
 
;SURG_CASE_PROCEDURE
		2 surg_case_procedure_table		= vc
		2 proc_text						= vc
;
		2 encntr_type					= vc
		2 encntr_id						= f8
		2 person_id						= f8
		2 implant_history_id			= f8
)
 
 
 
Record output (
	1 username          				= vc
	1 startdate         				= vc
	1 enddate          	 				= vc
	1 encntr_cnt						= i4
	1 list[*]
		2 encounter_table				= vc
		2 facility      				= vc
		2 nurse_unit					= vc
		2 patient_name      			= vc
		2 fin           				= vc
 
;IMPLANT_HISTORY
		2 implant_history_table			= vc
		2 implant_data_source			= vc
		2 implant_type					= vc
		2 biological_imp_src			= vc
		2 non_biological_imp_type		= vc
		2 item_number					= vc
		2 item_description				= vc
		2 implant_item_ft				= vc
		2 body_site						= vc
		2 donor_number_txt				= vc
		2 implanted_facility			= vc
		2 implanted_facility_ft			= vc
		2 implanted_dt_tm				= dq8
		2 explant_dt_tm					= dq8
		2 explant_reason				= vc
		2 udi_txt						= vc
		2 lot_number					= vc
		2 serial_number					= vc
		2 manufactured_dt_tm			= dq8
		2 manufacturer					= vc
		2 manufacturer_ft				= vc
		2 manufacturer_model_nbr_txt	= vc
		2 mr_classification				= vc
		2 procedure						= vc
		2 procedure_ft					= vc
		2 implanted_quantity			= i4
		2 updt_dt_tm					= dq8
		2 expiration_dt_tm				= dq8
		2 gmdn_pt_name					= vc
		2 catalog_number				= vc
 
;SURGICAL_CASE
		2 surg_case_nbr					= vc
		2 surgical_case_table			= vc
		2 surgical_area					= vc
		2 surgeon_prsnl					= vc
		2 anesth_prsnl					= vc
		2 anesth_prsnl_id				= f8
		2 surg_op_loc					= vc
		2 surgeon_specialty				= vc
		2 wound_class					= vc
		2 surg_start_dt_tm				= dq8
		2 surg_stop_dt_tm				= dq8
		2 surg_start_day				= i4
		2 surg_start_hour				= i4
		2 surg_start_month				= i4
		2 surg_complete_qty				= i4
		2 surg_dur_min					= i4
		2 curr_case_status				= vc
		2 curr_case_status_dt_tm		= dq8
 
;SURG_CASE_PROCEDURE
		2 surg_case_procedure_table		= vc
		2 proc_text						= vc
;
		2 encntr_type					= vc
		2 encntr_id						= f8
		2 person_id						= f8
		2 implant_history_id			= f8
)
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare FIN_TYPE_VAR        	= f8 with constant(uar_get_code_by("DISPLAYKEY",  319, "FINNBR")),protect
;
declare OPR_FAC_VAR		   		= vc with noconstant(fillstring(1000," "))
declare OPR_CAT_NBR_VAR			= vc with noconstant(fillstring(1000," "))
declare OPR_ITEM_NBR_VAR		= vc with noconstant(fillstring(1000," "))
declare OPR_MANUFACTURER_VAR	= vc with noconstant(fillstring(1000," "))
declare OPR_LOT_NBR_VAR			= vc with noconstant(fillstring(1000," "))
declare OPR_SERIAL_NBR_VAR		= vc with noconstant(fillstring(1000," "))
;
declare username           		= vc with protect
declare initcap()          		= c100
;
declare num						= i4 with noconstant(0)
declare idx						= i4 with noconstant(0)
;
declare	START_DATETIME_VAR		= f8
declare END_DATETIME_VAR		= f8
 
 
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
 
 
; SET DATE PROMPTS TO DATE VARIABLES
set START_DATETIME_VAR = cnvtdatetime($START_DATETIME_PMPT)
set END_DATETIME_VAR   = cnvtdatetime($END_DATETIME_PMPT)
 
 
; SET DATE VARIABLES FOR *****  MANUAL TESTING  *****
;set START_DATETIME_VAR = cnvtdatetime("01-DEC-2021 00:00:00")
;set END_DATETIME_VAR   = cnvtdatetime("01-DEC-2021 23:59:59")
 
 
; SET DATES VARIABLES TO RECORD STRUCTURE
set rec->startdate = format(START_DATETIME_VAR, "mm/dd/yyyy;;q")
set rec->enddate   = format(END_DATETIME_VAR, "mm/dd/yyyy;;q")
 
 
;SET FACILITY VARIABLE
if(substring(1,1,reflect(parameter(parameter2($FACILITY_PMPT),0))) = "L")	;multiple values were selected
	set OPR_FAC_VAR = "in"
elseif(parameter(parameter2($FACILITY_PMPT),1)= 0.0)						;all (any) values were selected
	set OPR_FAC_VAR = "!="
else																		;a single value was selected
	set OPR_FAC_VAR = "="
endif
 
; SET MANUFACTURER CATALOG NUMBER PROMPT VARIABLE
if ($CATALOG_NBR_PMPT = NULL)
	set OPR_CAT_NBR_VAR = "1=1"
else
	set OPR_CAT_NBR_VAR = build2('cnvtupper(rec->list[dt.seq].catalog_number) = "', cnvtupper($CATALOG_NBR_PMPT), '"')
endif
 
; SET ITEM NUMBER PROMPT VARIABLE
if ($ITEM_NBR_PMPT = NULL)
	set OPR_ITEM_NBR_VAR = "1=1"
else
	set OPR_ITEM_NBR_VAR = build2('cnvtupper(rec->list[dt.seq].item_number) = "', cnvtupper($ITEM_NBR_PMPT), '"')
endif
 
; SET LOT NUMBER PROMPT VARIABLE
if ($LOT_NBR_PMPT = NULL)
	set OPR_LOT_NBR_VAR = "1=1"
else
	set OPR_LOT_NBR_VAR = build2('cnvtupper(ih.lot_number_txt) = "', cnvtupper($LOT_NBR_PMPT), '"')
endif
 
; SET SERIAL NUMBER PROMPT VARIABLE
if ($SERIAL_NBR_PMPT = NULL)
	set OPR_SERIAL_NBR_VAR = "1=1"
else
	set OPR_SERIAL_NBR_VAR = build2('cnvtupper(ih.serial_number_txt) = "', cnvtupper($SERIAL_NBR_PMPT), '"')
endif
 
; SET MANUFACTURER_CD AND MANUFACTURER_FT PROMPT VARIABLE  (one prompt search for both fields)
if ($MANUFACTURER_PMPT = NULL)
	set OPR_MANUFACTURER_VAR = "1=1"
else
	set OPR_MANUFACTURER_VAR = build2('((cnvtupper(ih.manufacturer_ft) = "', cnvtupper($MANUFACTURER_PMPT), '")',
		' or (cnvtupper(cv.display) = "', cnvtupper($MANUFACTURER_PMPT), '"))')
endif
 
call echo(build2("******* ", OPR_MANUFACTURER_VAR))
;go to #exitscript
 
 
;==============================================================================
; MAIN DATA SELECT
;==============================================================================
call echo(build("*** MAIN DATA SELECT ***"))
 
select into "NL:"
from ENCOUNTER e
 
	,(inner join IMPLANT_HISTORY ih on ih.encntr_id = e.encntr_id
		and (ih.implanted_dt_tm between cnvtdatetime(START_DATETIME_VAR) AND cnvtdatetime(END_DATETIME_VAR))
		and parser(OPR_LOT_NBR_VAR)
		and parser(OPR_SERIAL_NBR_VAR)
		and ih.active_ind = 1)
 
	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
;		and ea.alias = "2133500025"
		and ea.encntr_alias_type_cd = FIN_TYPE_VAR ;1077
		and ea.end_effective_dt_tm > cnvtdatetime(curdate, curtime3) ;cnvtdatetime("31-DEC-2100 0")
		and ea.active_ind = 1)
 
	,(inner join ENCNTR_LOC_HIST elh on elh.encntr_id = e.encntr_id
			and (ih.implanted_dt_tm between elh.beg_effective_dt_tm and elh.end_effective_dt_tm)
     		and elh.active_ind = 1)
 
	,(inner join PERSON p on p.person_id = e.person_id
		and p.active_ind = 1)
 
	,(left join SN_IMPLANT_LOG_ST sils on sils.item_id = ih.implant_item_id) ;CATALOG NUMBER
 
	,(left join MM_OMF_ITEM_MASTER moim on moim.item_master_id = ih.implant_item_id ;ITEM NUMBER
		and moim.active_ind = 1)
 
	,(left join SURG_CASE_PROCEDURE scp on scp.surg_case_proc_id = ih.surg_case_proc_id
		and scp.active_ind = 1)
 
	,(left join SURGICAL_CASE sc on sc.surg_case_id = scp.surg_case_id
		and sc.person_id = e.person_id
		and sc.active_ind = 1)
 
	,(left join PRSNL pl on pl.person_id = scp.primary_surgeon_id)
 
	,(left join PRSNL pl2 on pl2.person_id = sc.anesth_prsnl_id)
 
	,(left join PRSNL_GROUP pg on pg.prsnl_group_id = sc.surg_specialty_id
		and pg.active_ind = 1)
 
	,(inner join CODE_VALUE cv on cv.code_value = ih.manufacturer_cd
		and parser(OPR_MANUFACTURER_VAR))
 
where operator(e.loc_facility_cd, OPR_FAC_VAR, $FACILITY_PMPT)
	;	and e.loc_facility_cd =  2553765467.00 ;2552503645 ;2552503645 ; 21250403
		and e.active_ind = 1
 
order by e.encntr_id, ih.implant_history_id
 
head report
	cnt = 0
 
head ih.implant_history_id
	cnt = cnt + 1
 
	stat = alterlist(rec->list,cnt)
 
 	rec->encntr_cnt = cnt
 
	rec->list[cnt].encounter_table				= "***** ENCOUNTER DATA --->"
	rec->list[cnt].facility      				= uar_get_code_display(e.loc_facility_cd)
	rec->list[cnt].nurse_unit					= uar_get_code_display(elh.loc_nurse_unit_cd)
	rec->list[cnt].patient_name    				= p.name_full_formatted
	rec->list[cnt].fin							= ea.alias
	rec->list[cnt].encntr_type					= uar_get_code_display(e.encntr_type_cd)
;
	rec->list[cnt].implant_history_table		= "***** IMPLANT HISTORY DATA --->"
	rec->list[cnt].implant_data_source			= uar_get_code_display(ih.implant_data_source_cd)
	rec->list[cnt].implant_type					= uar_get_code_display(ih.implant_type_cd)
	rec->list[cnt].biological_imp_src			= uar_get_code_display(ih.biological_imp_src_cd)
	rec->list[cnt].non_biological_imp_type		= uar_get_code_display(ih.non_biological_imp_type_cd)
	rec->list[cnt].catalog_number				= sils.catalog_number
	rec->list[cnt].item_number					= moim.stock_nbr
	rec->list[cnt].item_description				= moim.description
	rec->list[cnt].implant_item_ft				= replace(replace(ih.implant_item_ft, char(13), " ", 0), char(10), " ", 0)
	rec->list[cnt].body_site					= uar_get_code_display(ih.body_site_cd)
	rec->list[cnt].donor_number_txt				= replace(replace(ih.donor_number_txt, char(13), " ", 0), char(10), " ", 0)
	rec->list[cnt].implanted_facility			= uar_get_code_display(ih.implanted_facility_cd)
	rec->list[cnt].implanted_facility_ft		= replace(replace(ih.implanted_facility_ft, char(13), " ", 0), char(10), " ", 0)
	rec->list[cnt].implanted_dt_tm				= ih.implanted_dt_tm
	rec->list[cnt].explant_dt_tm				= ih.explant_dt_tm
	rec->list[cnt].explant_reason				= uar_get_code_display(ih.explant_reason_cd)
	rec->list[cnt].udi_txt						= replace(replace(ih.udi_txt, char(13), " ", 0), char(10), " ", 0)
	rec->list[cnt].lot_number					= replace(replace(ih.lot_number_txt, char(13), " ", 0), char(10), " ", 0)
	rec->list[cnt].serial_number				= replace(replace(ih.serial_number_txt, char(13), " ", 0), char(10), " ", 0)
	rec->list[cnt].manufactured_dt_tm			= ih.manufactured_dt_tm
	rec->list[cnt].manufacturer					= uar_get_code_display(ih.manufacturer_cd)
	rec->list[cnt].manufacturer_ft				= replace(replace(ih.manufacturer_ft, char(13), " ", 0), char(10), " ", 0)
	rec->list[cnt].manufacturer_model_nbr_txt	= replace(replace(ih.manufacturer_model_nbr_txt, char(13), " ", 0), char(10), " ", 0)
	rec->list[cnt].mr_classification			= uar_get_code_display(ih.mr_classification_cd)
	rec->list[cnt].procedure					= uar_get_code_display(ih.procedure_cd)
	rec->list[cnt].procedure_ft					= replace(replace(ih.procedure_ft, char(13), " ", 0), char(10), " ", 0)
	rec->list[cnt].implanted_quantity			= ih.implanted_quantity
	rec->list[cnt].updt_dt_tm					= ih.updt_dt_tm
	rec->list[cnt].expiration_dt_tm				= ih.expiration_dt_tm
	rec->list[cnt].gmdn_pt_name					= ih.gmdn_pt_name
;
	rec->list[cnt].surgical_case_table			= "***** SURGICAL CASE DATA --->"
	rec->list[cnt].surg_case_nbr				= sc.surg_case_nbr_formatted
	rec->list[cnt].surgical_area				= uar_get_code_display(sc.surg_area_cd)
	rec->list[cnt].surgeon_prsnl				= pl.name_full_formatted
	rec->list[cnt].surgeon_specialty			= pg.prsnl_group_name
	rec->list[cnt].anesth_prsnl					= pl2.name_full_formatted
	rec->list[cnt].surg_op_loc					= uar_get_code_display(sc.surg_op_loc_cd)
	rec->list[cnt].wound_class					= uar_get_code_display(sc.wound_class_cd)
	rec->list[cnt].surg_start_dt_tm				= sc.surg_start_dt_tm
	rec->list[cnt].surg_stop_dt_tm				= sc.surg_stop_dt_tm
	rec->list[cnt].surg_start_day				= sc.surg_start_day
	rec->list[cnt].surg_start_hour				= sc.surg_start_hour
	rec->list[cnt].surg_start_month				= sc.surg_start_month
	rec->list[cnt].surg_complete_qty			= sc.surg_complete_qty
	rec->list[cnt].surg_dur_min					= sc.surg_dur_min
	rec->list[cnt].curr_case_status				= uar_get_code_display(sc.curr_case_status_cd)
	rec->list[cnt].curr_case_status_dt_tm		= sc.curr_case_status_dt_tm
;
	rec->list[cnt].surg_case_procedure_table	= "***** SURG CASE PROCEDURE DATA --->"
	rec->list[cnt].proc_text					= replace(replace(scp.proc_text, char(13), " ", 0), char(10), " ", 0)
;
 	rec->list[cnt].encntr_id	 				= e.encntr_id
 	rec->list[cnt].person_id					= p.person_id
 	rec->list[cnt].implant_history_id			= ih.implant_history_id
 
foot report
	stat = alterlist(rec->list, cnt)
 
with nocounter
 
call echorecord(rec)
;go to exitscript
 
 
;==================================================================================
; COPY DATA FROM REC->LIST TO OUTPUT->LIST AND USING USER PROMPT SELECTION(S)
;==================================================================================
call echo(build("*** COPY DATA FROM REC->LIST TO OUTPUT->LIST ***"))
 
select
from (DUMMYT dt with seq = rec->encntr_cnt)
 
where parser(OPR_CAT_NBR_VAR)
	and parser(OPR_ITEM_NBR_VAR)
 
head report
	null
 
detail
	stat = movereclist(rec->list, output->list, dt.seq, size(output->list,5), 1, true)
 
foot report
	output->encntr_cnt = size(output->list,5)
 
with nocounter
 
;call echorecord(rec)
;call echorecord(output)
 
 
;============================
; REPORT OUTPUT
;============================
if (output->encntr_cnt > 0)
 
	select distinct into value ($OUTDEV)
		 patient_name  				= substring(1,50,output->list[d.seq].patient_name)
		,fin		   				= substring(1,20,output->list[d.seq].fin)
		,nurse_unit					= substring(1,50,output->list[d.seq].nurse_unit)
		,implant_type				= substring(1,50,output->list[d.seq].implant_type)
		,mfr_catalog_number			= substring(1,50,output->list[d.seq].catalog_number)
		,item_number				= substring(1,50,output->list[d.seq].item_number)
		,item_description			= substring(1,50,output->list[d.seq].item_description)
		,implant_item_ft			= substring(1,255,output->list[d.seq].implant_item_ft)
		,implant_data_source		= substring(1,50,output->list[d.seq].implant_data_source)
		,lot_number					= substring(1,255,output->list[d.seq].lot_number)
		,serial_number				= substring(1,255,output->list[d.seq].serial_number)
		,implanted_quantity			= output->list[d.seq].implanted_quantity
		,body_site					= substring(1,50,output->list[d.seq].body_site)
		,biological_imp_src			= substring(1,50,output->list[d.seq].biological_imp_src)
		,non_biological_imp_type	= substring(1,50,output->list[d.seq].non_biological_imp_type)
		,donor_number_txt			= substring(1,50,output->list[d.seq].donor_number_txt)
		,implanted_facility			= substring(1,50,output->list[d.seq].implanted_facility)
		,implanted_facility_ft		= substring(1,255,output->list[d.seq].implanted_facility_ft)
		,implanted_dt_tm			= format(output->list[d.seq].implanted_dt_tm, "mm/dd/yyyy hh:mm;;q")
		,explant_dt_tm				= format(output->list[d.seq].explant_dt_tm, "mm/dd/yyyy hh:mm;;q")
		,explant_reason				= substring(1,50,output->list[d.seq].explant_reason)
		,udi_txt					= substring(1,255,output->list[d.seq].udi_txt)
		,updt_dt_tm					= format(output->list[d.seq].updt_dt_tm, "mm/dd/yyyy hh:mm;;q")
		,expiration_dt_tm			= format(output->list[d.seq].expiration_dt_tm, "mm/dd/yyyy hh:mm;;q")
		,gmdn_pt_name				= substring(1,50,output->list[d.seq].gmdn_pt_name)
		,manufactured_dt_tm			= format(output->list[d.seq].manufactured_dt_tm, "mm/dd/yyyy hh:mm;;q")
		,manufacturer				= substring(1,50,output->list[d.seq].manufacturer)
		,manufacturer_ft			= substring(1,255,output->list[d.seq].manufacturer_ft)
		,manufacturer_model_nbr_txt	= substring(1,255,output->list[d.seq].manufacturer_model_nbr_txt)
		,mr_classification			= substring(1,50,output->list[d.seq].mr_classification)
		,facility      				= substring(1,50,output->list[d.seq].facility)
		,procedure					= substring(1,50,output->list[d.seq].procedure)
		,procedure_ft				= substring(1,255,output->list[d.seq].procedure_ft)
		,proc_text					= substring(1,255,output->list[d.seq].proc_text)
		,surg_case_nbr				= substring(1,50,output->list[d.seq].surg_case_nbr)
		,surgical_area				= substring(1,50,output->list[d.seq].surgical_area)
		,surgeon_prsnl				= substring(1,50,output->list[d.seq].surgeon_prsnl)
 
;;		,surgical_case_table		= substring(1,50,output->list[d.seq].surgical_case_table)
;;		,surgeon_specialty			= substring(1,50,output->list[d.seq].surgeon_specialty)
;;		,anesth_prsnl				= substring(1,50,output->list[d.seq].anesth_prsnl)
;;		,surg_op_loc				= substring(1,50,output->list[d.seq].surg_op_loc)
;;		,wound_class				= substring(1,50,output->list[d.seq].wound_class)
;;		,surg_start_dt_tm			= format(output->list[d.seq].surg_start_dt_tm, "mm/dd/yyyy hh:mm;;q")
;;		,surg_stop_dt_tm			= format(output->list[d.seq].surg_stop_dt_tm, "mm/dd/yyyy hh:mm;;q")
;;		,surg_start_day				= output->list[d.seq].surg_start_day
;;		,surg_start_hour			= output->list[d.seq].surg_start_hour
;;		,surg_start_month			= output->list[d.seq].surg_start_month
;;		,surg_complete_qty			= output->list[d.seq].surg_complete_qty
;;		,surg_dur_min				= output->list[d.seq].surg_dur_min
;;		,curr_case_status			= substring(1,50,output->list[d.seq].curr_case_status)
;;		,curr_case_status_dt_tm		= format(output->list[d.seq].curr_case_status_dt_tm, "mm/dd/yyyy hh:mm;;q")
;;		,surg_case_procedure_table	= substring(1,50,output->list[d.seq].surg_case_procedure_table)
;;
;;		,encntr_type				= substring(1,50,output->list[d.seq].encntr_type)
;;		,encntr_id     				= output->list[d.seq].encntr_id
;;		,person_id					= output->list[d.seq].person_id
;;		,implant_history_id			= output->list[d.seq].implant_history_id
;;		,username      				= output->username
;;		,startdate_pmpt				= output->startdate
;;		,enddate_pmpt  				= output->enddate
;;		,encntr_cnt	   				= output->encntr_cnt
;;		,implanted_dt_tm			= format(output->list[d.seq].implanted_dt_tm, "mm/dd/yyyy hh:mm;;q")
 
	from
		 (DUMMYT d  with seq = value(size(output->list,5)))
 
	plan d
 
	order by facility, nurse_unit desc, implanted_dt_tm, patient_name, output->list[d.seq].encntr_id,
		output->list[d.seq].implant_history_id
 
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
 
 
