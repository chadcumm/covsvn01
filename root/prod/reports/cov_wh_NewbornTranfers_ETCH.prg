/*****************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
******************************************************************************************
	Author:				Dan Herren
	Date Written:		January 2021
	Solution:			Womens Health
	Source file name:	cov_wh_NewbornTranfers_ETCH.prg
	Object name:		cov_wh_NewbornTranfers_ETCH
	CR#:				9079
 
	Program purpose:
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
 
drop program cov_wh_NewbornTranfers_ETCH:dba go
create program cov_wh_NewbornTranfers_ETCH:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Report or Grid" = 0
	, "Start Date" = "SYSDATE"
	, "End Date" = "SYSDATE"
	, "Facility" = VALUE(0.0           )
 
with OUTDEV, RPT_GRID_PMPT, STARTDATE_PMPT, ENDDATE_PMPT, FACILITY_PMPT
 
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
Record rec (
	1 username          		= vc
	1 startdate         		= vc
	1 enddate          	 		= vc
	1 encntr_cnt				= i4
	1 list[*]
		2 facility      		= vc
		2 mother_name			= vc
		2 newborn_name      	= vc
		2 age					= vc
		2 fin           		= vc
		2 mrn           		= vc
		2 cmrn					= vc
		2 admit_dt				= dq8
		2 medication			= vc
		2 dischg_dt				= dq8
		2 dischg_dispo			= vc
		2 dosage				= vc
		2 administered_dt		= dq8
		2 event_id				= f8
		2 encntr_id				= f8
		2 person_id				= f8
)
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare FIN_TYPE_VAR        		= f8 with constant(uar_get_code_by("DISPLAYKEY",319,"FINNBR")),protect
declare MRN_TYPE_VAR        		= f8 with constant(uar_get_code_by("DISPLAYKEY",319,"MRN")),protect
declare CMRN_TYPE_VAR       		= f8 with constant(uar_get_code_by("DISPLAYKEY",  4,"COMMUNITYMEDICALRECORDNUMBER")),protect
declare TRANS_CHILDRENS_HOSP_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY", 19,"TRANSFERTOCHILDRENSHOSPITAL05")),protect
declare CHILD_RELTN_VAR 			= f8 with constant(uar_get_code_by("DISPLAYKEY", 24,"C")),protect
declare CHILD_PERSON_RELTN_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY", 40,"CHILD")),protect
declare NEWBORN_ENCNTR_TYPE_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY", 71,"NEWBORN")),protect
declare GLUCOSE_VAR					= f8 with constant(uar_get_code_by("DISPLAYKEY", 72,"GLUCOSE")),protect
declare MEDICATION_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY", 53,"MED")),protect
declare IMMUNIZATION_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY", 53,"IMMUNIZATION")),protect
declare ADMINISTERED_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",4000040,"ADMINISTERED")),protect
;
declare OPR_FAC_VAR		   			= vc with noconstant(fillstring(1000," "))
;
declare username           			= vc with protect
declare initcap()          			= c100
;
declare num							= i4 with noconstant(0)
declare idx							= i4 with noconstant(0)
 
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
 
 
; SET DATE PROMPTS TO DATE VARIABLES
;if (($3 in ("*curdate*")))
;	declare _dq8 = dq8 with noconstant ,private
;  	declare _parse = vc with constant (concat("set _dq8 = cnvtdatetime(" , $3 ,", 0) go")) ,private
;  	call parser(_parse)
;  	declare START_DATETIME_VAR = vc with protect ,constant (format(_dq8 ,"dd-mmm-yyyy;;d"))
;else
; 	declare START_DATETIME_VAR = vc with protect ,constant ($3)
;endif
;
;if (($4 in ("*curdate*")))
;  	declare _dq8 = dq8 with noconstant ,private
;  	declare _parse2 = vc with constant (concat("set _dq8 = cnvtdatetime(" , $4 ,", 235959) go")) ,private
;  	call parser(_parse2)
;  	declare END_DATETIME_VAR = vc with protect ,constant (format(_dq8 ,"dd-mmm-yyyy hh:mm;;q"))
;else
;  	declare END_DATETIME_VAR = vc with protect ,constant (concat(trim ($4) ," 23:59:59"))
;endif
 
 
set START_DATETIME_VAR = $STARTDATE_PMPT
set END_DATETIME_VAR   = $ENDDATE_PMPT
 
 
; SET DATE VARIABLES FOR *****  MANUAL TESTING  *****
;set START_DATETIME_VAR = cnvtdatetime("01-DEC-2020 0")
;set END_DATETIME_VAR   = cnvtdatetime("15-JAN-2021 23:59")
 
 
; SET DATES VARIABLES TO RECORD STRUCTURE
set rec->startdate = format(cnvtdatetime(START_DATETIME_VAR), "mm/dd/yyyy;;q")
set rec->enddate   = format(cnvtdatetime(END_DATETIME_VAR), "mm/dd/yyyy;;q")
 
 
;SET FACILITY VARIABLE
if(substring(1,1,reflect(parameter(parameter2($FACILITY_PMPT),0))) = "L")	;multiple values were selected
	set OPR_FAC_VAR = "in"
elseif(parameter(parameter2($FACILITY_PMPT),1) = 0.0)						;all (any) values were selected
	set OPR_FAC_VAR = "!="
else																		;a single value was selected
	set OPR_FAC_VAR = "="
endif
 
 
;==============================================================================
; MAIN DATA SELECT
;==============================================================================
;call echo(build("*** MAIN DATA SELECT ***"))
 
select into "NL:"
 
from ENCOUNTER e
 
; 	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
;		and ea.encntr_alias_type_cd = FIN_TYPE_VAR   ;1077
;		and ea.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
;	and ea.alias = "2034601213"
;		and ea.active_ind = 1)
 
	,(left join CLINICAL_EVENT ce on ce.encntr_id = e.encntr_id
	    and ce.event_class_cd in (MEDICATION_VAR, IMMUNIZATION_VAR) ;228, 232)
		and ce.event_cd = GLUCOSE_VAR ;2797876
	    and ce.event_reltn_cd = CHILD_RELTN_VAR  ;132
	    and ce.result_status_cd in (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth (Verified), Modified
		and ce.valid_until_dt_tm > cnvtdatetime(curdate,curtime3))
 
	,(left join ORDERS o on o.encntr_id = ce.encntr_id
		and o.synonym_id = 2759046 ;glucose 40% Oral Gel 37.5 g
		and o.active_ind = 1)
 
	,(inner join PERSON p on p.person_id = e.person_id
		and p.active_ind = 1)
 
	,(inner join PERSON_PERSON_RELTN ppr on ppr.related_person_id = p.person_id
		and ppr.person_reltn_cd = CHILD_PERSON_RELTN_VAR ;670847
		and ppr.active_ind = 1)
 
	,(inner join PERSON p2 on p2.person_id = ppr.person_id
		and p2.active_ind = 1)
 
where operator(e.loc_facility_cd, OPR_FAC_VAR, $FACILITY_PMPT)
	and (e.reg_dt_tm between cnvtdatetime(START_DATETIME_VAR) and cnvtdatetime(END_DATETIME_VAR))
	and e.disch_disposition_cd = TRANS_CHILDRENS_HOSP_VAR  ;4510195
	and e.encntr_type_cd = NEWBORN_ENCNTR_TYPE_VAR  ;2555267433
	and e.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
	and e.active_ind = 1
 
order by e.encntr_id, ce.event_id, o.order_id
 
head report
	cnt  = 0
	ecnt = 0
 
	call alterlist(rec->list, 10)
 
detail
	cnt = cnt + 1
 
	if(mod(cnt, 10) = 1 and cnt > 10)
		call alterlist(rec->list, cnt + 9)
	endif
 
 	rec->encntr_cnt = cnt
 
	rec->list[cnt].facility  		= uar_get_code_display(e.loc_facility_cd)
	rec->list[cnt].mother_name     	= p2.name_full_formatted
	rec->list[cnt].newborn_name     = p.name_full_formatted
	rec->list[cnt].age		     	= cnvtage(p.birth_dt_tm)
	rec->list[cnt].admit_dt			= e.reg_dt_tm
	rec->list[cnt].dischg_dt		= e.disch_dt_tm
	rec->list[cnt].dischg_dispo		= uar_get_code_display(e.disch_disposition_cd)
	rec->list[cnt].dosage			= ce.event_tag
	rec->list[cnt].administered_dt	= ce.event_end_dt_tm
 	rec->list[cnt].medication		= o.order_mnemonic
 	rec->list[cnt].encntr_id		= e.encntr_id
 	rec->list[cnt].person_id		= p.person_id
 	rec->list[cnt].event_id			= ce.event_id
 
foot report
	stat = alterlist(rec->list, cnt)
 
with nocounter, separator=" ", format, time=120
 
;call echorecord(rec)
;go to exitscript
 
 
;============================================================================
; GET PERSON & ENCOUNTER ALIAS'S: FIN, MRN, CMRN
;============================================================================
call echo(build("*** GET PERSON & ENCOUNTER ALIAS'S DATA ***"))
select into "NL:"
 
from ENCOUNTER e
 
	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = FIN_TYPE_VAR   ;1077
		and ea.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
		and ea.active_ind = 1)
 
	,(inner join ENCNTR_ALIAS ea2 on ea2.encntr_id = e.encntr_id
		and ea2.encntr_alias_type_cd = MRN_TYPE_VAR   ;1079
		and ea2.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
		and ea2.active_ind = 1)
 
	,(left join PERSON_ALIAS pa on pa.person_id = e.person_id
		and pa.person_alias_type_cd = CMRN_TYPE_VAR    ;263
		and pa.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
		and pa.active_ind = 1)
 
where expand(num, 1, size(rec->list, 5), e.encntr_id, rec->list[num].encntr_id)
	and e.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
	and e.active_ind = 1
 
detail
	numx = 0
	idx  = 0
 
	idx = locateval(numx, 1, size(rec->list,5), e.encntr_id, rec->list[numx].encntr_id)
 
	while (idx > 0)
		rec->list[idx].fin  = ea.alias	;fin
		rec->list[idx].mrn  = ea2.alias	;mrn
		rec->list[idx].cmrn = pa.alias	;cmrn
 
		idx = locateval(numx, idx+1, size(rec->list,5), e.encntr_id, rec->list[numx].encntr_id)
	endwhile
 
with nocounter, expand = 1
 
;call echorecord(rec)
;go to exitscript
 
 
;============================================================================
; REPORT OUTPUT
;============================================================================
if (rec->encntr_cnt > 0)
 
	select distinct into value ($OUTDEV)
		 facility      			= rec->list[d.seq].facility
		,mother_name	   		= substring(1,50,trim(rec->list[d.seq].mother_name))
		,newborn_name	   		= substring(1,50,trim(rec->list[d.seq].newborn_name))
;		,age					= rec->list[d.seq].age
		,newborn_fin		   	= rec->list[d.seq].fin
		,newborn_mrn			= rec->list[d.seq].mrn
;		,cmrn					= rec->list[d.seq].cmrn
		,admit_dt				= format(rec->list[d.seq].admit_dt, "mm/dd/yyyy hh:mm;;q")
		,discharge_dt			= format(rec->list[d.seq].dischg_dt, "mm/dd/yyyy hh:mm;;q")
;		,discharge_dispo		= substring(1,50,trim(rec->list[d.seq].dischg_dispo))
;		,medication				= substring(1,50,trim(rec->list[d.seq].medication))
;		,dosage					= format(rec->list[d.seq].events[d2.seq].dosage,";R")
		,glugel_adm_dt			= format(rec->list[d.seq].administered_dt, "mm/dd/yyyy hh:mm;;q")
;		,prompt_date_range		= concat(rec->startdate," to ",rec->enddate)
;		,username      			= rec->username
;		,encntr_id     			= rec->list[d.seq].encntr_id
;		,person_id				= rec->list[d.seq].person_id
;		,order_id				= rec->list[d.seq].order_id
;		,event_id				= rec->list[d.seq].event_id
;		,encntr_cnt	   			= rec->encntr_cnt
 
	from (DUMMYT d  with seq = value(size(rec->list,5)))
 
	plan d
 
	order by facility, rec->list[d.seq].admit_dt desc, newborn_name, glugel_adm_dt ;, rec->list[d.seq].event_id
 
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
 
 
