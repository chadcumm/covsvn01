/*****************************************************************************
 *  Covenant Health Information Technology
 *  Knoxville, Tennessee
 *****************************************************************************
 
    Author:            Dan Herren
    Date Written:      August 2017
    Soluation:         Anatomic Pathology
    Source file name:  cov_ant_FluidAnalysis.prg
    Object name:       cov_ant_FluidAnalysis
    Layout Builder:    cov_ant_FluidAnalysis_LB
    CR #:              19
 
    Program purpose:   Identify patients in a given time interval who
                       have pleural or ascites (paracentesis) body fluid
                       evaluation in general clinical lab hematology
                       department (cell count and differential) and
                       cytology within 3 days of hematology sample.
 
    Executing from:    CCL.
 
    Special Notes:
 
 ******************************************************************************
 *  GENERATED MODIFICATION CONTROL LOG
 ******************************************************************************
 *
 *  Mod Date     Developer             Comment
 *  -----------  --------------------  ----------------------------------------
 *
 ******************************************************************************/
 
drop program cov_ant_FluidAnalysis go
create program cov_ant_FluidAnalysis
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Select a Facility" = 0
	, "Enter a Start Date" = "SYSDATE"
	, "Enter a Ending Date" = "SYSDATE"
 
with OUTDEV, FACILITY_PMPT, STARTDATE_PMPT, ENDDATE_PMPT
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
;free record pcase
record pcase
(
1 recordcnt	      = i4
1 username        = c15
1 facility        = c50   ;facility name
1 startdate       = c25
1 enddate         = c25
1 list[*]
	2 encntr_id   = f8	  ;encounter id
	2 order_id    = f8    ;order id
	2 person_id   = f8    ;person id
	2 fin_nbr	  = c15   ;fin number
	2 pat_name    = c50   ;patient name
	2 room        = c20   ;room
	2 specimen	  = c50   ;specimen
	2 case_number = c15   ;case number
	2 lab_order   = c50   ;lab order
	2 order_dt    = dq8   ;order date
	2 collect_dt  = dq8   ;collect date
)
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare FIN_VAR           			= f8 with constant(uar_get_code_by("MEANING",319,"FIN NBR")),protect
 
declare ASCITICFL_SPECIMEN_VAR      = f8 with Constant(uar_get_code_by("DISPLAYKEY",1306,"ASCITICFL")),protect ;314193.00
declare PLEURALFL_SPECIMEN_VAR      = f8 with Constant(uar_get_code_by("DISPLAYKEY",1306,"PLEURALFL")),protect ;314172.00
;declare CSFFL_SPECIMEN_VAR         = f8 with Constant(uar_get_code_by("DISPLAYKEY",1306,"CSF")),protect
 
declare ASCITESFL_SPECIMENTYPE_VAR  = f8 with Constant(uar_get_code_by("DISPLAYKEY",2052,"ASCITES FL")),protect ;312558.00
declare PLEURALFL_SPECIMENTYPE_VAR  = f8 with Constant(uar_get_code_by("DISPLAYKEY",2052,"PLEURAL FL")),protect ;312633.00
;declare CSF_SPECIMENTYPE_VAR       = f8 with Constant(uar_get_code_by("DISPLAYKEY",2052,"CSF")),protect
 
declare CELLCOUNTWDIFFBODYFLUID_VAR = f8 with Constant(uar_get_code_by("DISPLAYKEY",200,"CELLCOUNTWDIFFBODYFLUID")),protect
declare FLOWCYTOMETRYREPORT_VAR     = f8 with Constant(uar_get_code_by("DISPLAYKEY",200,"FLOWCYTOMETRYREPORT")),protect
declare NONGYNPATHOLOGYREPORT_VAR   = f8 with Constant(uar_get_code_by("DISPLAYKEY",200,"NONGYNPATHOLOGYREPORT")),protect
 																			;2921450.00  ;2552610363.00   ;269451869.00
declare initcap() = c100
declare username  = vc with protect
 
 
/**************************************************************
; Prompts and  Username
**************************************************************/
set pcase->facility  = uar_get_code_description($FACILITY_PMPT)
set pcase->startdate = $STARTDATE_PMPT
set pcase->enddate   = $ENDDATE_PMPT
 
select into "NL:"
from
	prsnl p
where p.person_id = reqinfo->updt_id
detail
	pcase->username = p.username
with nocounter
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
select distinct into "NL:"
 	 encntr_id 		= e.encntr_id
 	,order_id		= ord.order_id
	,person_id 		= p.person_id
	,fin_nbr		= ea.alias
	,pat_name  		= initcap(p.name_full_formatted)
	,room      		= uar_get_code_display(e.loc_room_cd)
	,specimen	 	= uar_get_code_display(cs.specimen_cd)
	,case_number	= cnvtacc(pc.accession_nbr)
	,lab_order   	= uar_get_code_display(ord.catalog_cd)
	,order_dt    	= ord.current_start_dt_tm
	,collect_dt  	= pc.case_collect_dt_tm
 
from
	 ORDERS                     ord
	,ENCOUNTER                  e
 	,ENCNTR_ALIAS				ea
	,PERSON                     p
	,PATHOLOGY_CASE             pc
	,CASE_SPECIMEN              cs
	,COLLECTION_INFO_QUALIFIERS ciq
	,PRSNL_ORG_RELTN            por
 
plan ord where ord.orig_order_dt_tm between cnvtdatetime($STARTDATE_PMPT) and cnvtdatetime($ENDDATE_PMPT)
	and ord.catalog_cd in (CELLCOUNTWDIFFBODYFLUID_VAR, FLOWCYTOMETRYREPORT_VAR, NONGYNPATHOLOGYREPORT_VAR)
 
join e where e.encntr_id = ord.encntr_id
	and e.loc_facility_cd = $FACILITY_PMPT
; 	and e.end_effective_dt_tm >= sysdate
 
join ea
	where ea.encntr_id = outerjoin(e.encntr_id)
		and ea.encntr_alias_type_cd = outerjoin(FIN_VAR)
		and ea.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime))
 
join p where p.person_id = e.person_id
	and p.person_id = ord.person_id
	and p.active_ind = 1
	and p.end_effective_dt_tm >= sysdate
 
join pc where pc.encntr_id = e.encntr_id
	and pc.person_id = p.person_id
	and abs(datetimediff(pc.case_collect_dt_tm, ord.current_start_dt_tm)) <= 2
 
join cs where cs.case_id = pc.case_id
	and cs.specimen_cd in (ASCITICFL_SPECIMEN_VAR, PLEURALFL_SPECIMEN_VAR)
 
join ciq where ciq.catalog_cd = ord.catalog_cd
	and ciq.specimen_type_cd in (ASCITESFL_SPECIMENTYPE_VAR, PLEURALFL_SPECIMENTYPE_VAR)
 
join por where por.person_id = reqinfo->updt_id
	and por.active_ind = 1
 	and por.end_effective_dt_tm >= sysdate
 
head report
	cnt = 0
 
head e.encntr_id
	call alterlist(pcase->list, cnt)
 
detail
	cnt = cnt + 1
	stat = alterlist(pcase->list,cnt)
 
 	pcase->list[cnt].encntr_id    = encntr_id
 	pcase->list[cnt].order_id     = order_id
	pcase->list[cnt].person_id    = person_id
	pcase->list[cnt].fin_nbr	  = fin_nbr
	pcase->list[cnt].pat_name     = pat_name
	pcase->list[cnt].room         = room
	pcase->list[cnt].specimen	  = specimen
	pcase->list[cnt].case_number  = case_number
	pcase->list[cnt].lab_order    = lab_order
	pcase->list[cnt].order_dt     = order_dt
	pcase->list[cnt].collect_dt   = collect_dt
 
 	pcase->recordcnt = cnt
 
with nocounter, format, check, separator = " ", nullreport
 
;call echorecord(pcase)
;go to exitscript
 
/****************************
; REPORT OUTPUT
****************************/
select into value ($OUTDEV)
	 facility       = pcase->facility
	,encntr_id      = pcase->list[d.seq].encntr_id
	,order_id       = pcase->list[d.seq].order_id
	,person_id      = pcase->list[d.seq].person_id
	,fin_nbr		= pcase->list[d.seq].fin_nbr
	,pat_name       = pcase->list[d.seq].pat_name
	,room           = pcase->list[d.seq].room
	,specimen       = pcase->list[d.seq].specimen
	,case_number    = pcase->list[d.seq].case_number
	,lab_order      = pcase->list[d.seq].lab_order
	,order_dt       = format(pcase->list[d.seq].order_dt, "mm/dd/yy hh:mm;;d")
	,collect_dt     = format(pcase->list[d.seq].collect_dt, "mm/dd/yy hh:mm;;d")
	,pmpt_startdate = pcase->startdate
	,pmpt_enddate   = pcase->enddate
	,recordcnt      = pcase->recordcnt
	,username       = pcase->username
 
from
	(dummyt d  with seq = value(size(pcase->list,5)))
 
plan d
 
order by
	 facility
	,room
	,pat_name
	,order_dt
	,lab_order
	,order_id
	,encntr_id
	,person_id
 
with nocounter, format, check, separator = " "
;
;#exitscript
 
end
go
 
 
