/*****************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
******************************************************************************
	Author:				Dan Herren
	Date Written:		March 2019
	Solution:			Infection Control
	Source file name:  	cov_ic_CdiffDocumention.prg
	Object name:		cov_ic_CdiffDocumention
	Layout file name:   cov_ic_CdiffDocumention_LB
	CR#:				1938
 
	Program purpose:	Patient's documentation for CDiff.
	Executing from:		CCL
  	Special Notes:
 
******************************************************************************
*  	GENERATED MODIFICATION CONTROL LOG
*
*  	Revision #   Mod Date    Developer             Comment
*  	-----------  ----------  --------------------  ---------------------------
*
*
******************************************************************************/
 
drop program cov_ic_CdiffDocumention go
create program cov_ic_CdiffDocumention
 
prompt
	"Output to File/Printer/MINE" = "MINE"        ;* Enter or select the printer or file name to send this report to.
	, "Facility" = 21250403.00
	, "Nurse Unit" = VALUE(0.00, 2552519611.00)
	, "Orders" = 0
	, "Stool Screen" = 0
 
with OUTDEV, FACILITY_PMPT, NURSE_UNIT_PMPT, ORDERS_ONLY_PMPT, STOOL_SCR_ONLY
 
 
/**************************************************************
; DVDev DECLARED RECORD STRUCTURES
**************************************************************/
;free record a
record a
(
1 	username        			= vc
1	rec_cnt 					= i4
1	list[*]
	2	facility				= vc
	2	nurse_unit				= vc
	2	room					= vc
	2	bed						= vc
	2	room_bed				= vc
	2	pat_name				= vc
	2	mrn						= vc
	2	fin						= vc
	2	dob						= dq8
	2	age						= vc
	2	arrive_dt				= dq8
	2	bedded_dt				= dq8
	2	stool_screen			= vc
	2	encntr_id				= f8
	2	person_id				= f8
;--
	2   order_cnt				= i4
	2	ordlist[*]
		3 order_id				= f8
		3 order_name			= c60
		3 order_status 			= vc
		3 specimen_collect		= vc
		3 specimen_collect_dt 	= dq8
;--
	2	event_cnt				= i4
	2 	eventlist[*]
		3 event_id  			= f8
		3 event_cd				= f8
		3 event_end_dt 			= dq8
		3 isol_act   			= vc
		3 isol_type   			= vc
		3 isol_type_dt			= dq8
		3 cdiff_interp 			= vc
		3 cdiff_interp_dt		= dq8
		3 cdiff_naat			= vc
		3 cdiff_naat_dt			= dq8
		3 stool_desc			= vc
		3 stool_desc_dt			= dq8
		3 stool_cnt				= vc
		3 stool_cnt_dt			= dq8
)
 
RECORD output(
	1 username          		= vc
	1 rec_cnt					= i4
	1 list[*]
		2 facility      		= vc
		2 nurse_unit    		= vc
		2 room		    		= vc
		2 bed           		= vc
		2 room_bed				= vc
		2 pat_name      		= vc
		2 fin           		= vc
		2 dob					= dq8
		2 age					= vc
		2 arrive_dt				= dq8
		2 bedded_dt				= dq8
		2 stool_screen			= vc
		2 order_info			= vc
		2 order_exist			= vc
		2 order_name			= vc
		2 order_status 			= vc
		2 specimen_info			= vc
		2 specimen_collect		= vc
		2 specimen_collect_dt	= dq8
		2 isol_type     		= vc
		2 isol_type_dt     		= dq8
		2 cdiff_result 			= vc
		2 cdiff_interp_dt		= dq8
		2 cdiff_naat			= vc
		2 cdiff_naat_dt			= dq8
		2 stool_info			= vc
		2 stool_desc			= vc
		2 stool_desc_dt			= dq8
		2 stool_cnt				= vc
		2 stool_cnt_dt			= dq8
		2 event_end_dt 			= dq8
		2 order_id				= f8
		2 encntr_id				= f8
		2 event_id  			= f8
)
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare FIN_VAR	  			= f8 with constant(uar_get_code_by('DISPLAYKEY',319,  'FINNBR')), protect
declare MRN_VAR	  			= f8 with constant(uar_get_code_by('DISPLAYKEY',319,  'MRN')), protect
declare POWERFORM_VAR	  	= f8 with constant(uar_get_code_by('DISPLAYKEY',29520,'POWERFORMS')), protect
declare EMERGENCY_MED_VAR  	= f8 with constant(uar_get_code_by('DISPLAYKEY',34,   'EMERGENCYMEDICINE')), protect
declare ENCTYPE_INP_VAR	  	= f8 with constant(uar_get_code_by('DISPLAYKEY',71,   'INPATIENT')), protect
declare ENCTYPE_OBS_VAR	  	= f8 with constant(uar_get_code_by('DISPLAYKEY',71,   'OBSERVATION')), protect
declare ORD_ORDERED_VAR		= f8 with constant(uar_get_code_by('DISPLAYKEY',6004, 'ORDERED')), protect
declare ORD_COMPLETED_VAR	= f8 with constant(uar_get_code_by('DISPLAYKEY',6004, 'COMPLETED')), protect
declare CDIFFGDHTOXCD_VAR 	= f8 with constant(uar_get_code_by('DISPLAYKEY',200,  'CLOSTRIDIUMDIFFICILEGDHTOXIN')), protect
declare CDIFFMOLECCD_VAR	= f8 with constant(uar_get_code_by('DISPLAYKEY',200,  'CLOSTRIDIUMDIFFICILEMOLECULAR')), protect
declare ISOL_ACTIVITY_VAR  	= f8 with constant(uar_get_code_by('DISPLAYKEY',72,   'ISOLATIONACTIVITY')),protect
declare ISOL_TYPE_VAR  	  	= f8 with constant(uar_get_code_by('DISPLAYKEY',72,   'ISOLATIONTYPE')),protect
declare CDIFF_INTERP_VAR	= f8 with constant(uar_get_code_by('DISPLAYKEY',72,   'CDIFFICILEINTERP')), protect
declare CDIFF_NAAT_VAR		= f8 with constant(uar_get_code_by('DISPLAYKEY',72,   'CDIFFICILENAAT')), protect
declare STOOL_DESC_VAR  	= f8 with constant(uar_get_code_by("DISPLAYKEY",72,   'STOOLDESCRIPTION')),protect
declare STOOL_CNT_VAR  	  	= f8 with constant(uar_get_code_by("DISPLAYKEY",72,   'STOOLCOUNT')),protect
declare	STOOL_SCR_VAR		= f8 with noconstant(0)
 
;
declare DOS_COLLECTED_VAR  	= f8 with constant(uar_get_code_by("DISPLAYKEY",14281, 'COLLECTED')),protect
declare DOS_COMPLETED_VAR  	= f8 with constant(uar_get_code_by("DISPLAYKEY",14281, 'COMPLETED')),protect
declare DOS_INTRANSIT_VAR  	= f8 with constant(uar_get_code_by("DISPLAYKEY",14281, 'INTRANSIT')),protect
declare DOS_INLAB_VAR  		= f8 with constant(uar_get_code_by("DISPLAYKEY",14281, 'INLAB')),protect
;
declare OPR_FAC_VAR		   	= vc with noconstant(fillstring(1000," "))
declare OPR_NRU_VAR		   	= vc with noconstant(fillstring(1000," "))
;
declare username           	= vc with protect
declare initcap()          	= c100
declare	cnt					= i4 with noconstant(0)
declare idx				   	= i4 with noconstant(0)
 
set STOOL_SCR_VAR 			= 2559940279
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
;GET USERNAME FOR REPORT
select into "NL:"
from
	prsnl p
where p.person_id = reqinfo->updt_id
detail
	a->username = p.username
with nocounter
 
 
/**************************************************************
; SET PROMPTS FOR ANY(*) OPTIONS
**************************************************************/
;SET FACILITY PROMPT VARIABLE
if(substring(1,1,reflect(parameter(parameter2($FACILITY_PMPT),0))) = "L")	;multiple values were selected
	set OPR_FAC_VAR = "in"
elseif(parameter(parameter2($FACILITY_PMPT),1) = 0.0)						;all (any) values were selected
	set OPR_FAC_VAR = "!="
else																		;a single value was selected
	set OPR_FAC_VAR = "="
endif
 
 
;SET NURSE UNIT PROMPT VARIABLE
if(substring(1,1,reflect(parameter(parameter2($NURSE_UNIT_PMPT),0))) = "L")	;multiple values were selected
	set OPR_NRU_VAR = "in"
elseif(parameter(parameter2($NURSE_UNIT_PMPT),1) = 0.0)						;all (any) values were selected
	set OPR_NRU_VAR = "!="
else																		;a single value was selected
	set OPR_NRU_VAR = "="
endif
 
 
/**************************************************************
; MAIN SELECTION
**************************************************************/
select into 'nl:'
	 facility      	= uar_get_code_description(e.loc_facility_cd)
	,nurse_unit    	= uar_get_code_display(e.loc_nurse_unit_cd)
	,room			= trim(uar_get_code_display(e.loc_room_cd),3)
	,bed			= trim(uar_get_code_display(e.loc_bed_cd),3)
	,room_bed     	= build2(trim(uar_get_code_display(e.loc_room_cd),3),
						evaluate2(if(e.loc_room_cd = 0) "" else "-" endif), uar_get_code_display(e.loc_bed_cd))
	,pat_name      	= initcap(p.name_full_formatted)
	,fin           	= ea.alias
	,mrn           	= ea2.alias
	,dob			= p.birth_dt_tm
	,age			= cnvtage(p.birth_dt_tm)
	,arrive_dt		= e.arrive_dt_tm
	,encntr_id  	= e.encntr_id
	,person_id		= e.person_id
 
from ENCNTR_DOMAIN ed
 
	,(inner join ENCOUNTER e on e.encntr_id = ed.encntr_id
		and e.end_effective_dt_tm > sysdate
		and e.active_ind = 1
		and e.loc_bed_cd > 0.00
	)
 
	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = FIN_VAR ;1077
		and ea.end_effective_dt_tm > sysdate
		and ea.active_ind = 1
;		and ea.alias = "1909501545"  ; testing patients
	)
 
	,(inner join ENCNTR_ALIAS ea2 on ea2.encntr_id = e.encntr_id
		and ea2.encntr_alias_type_cd = MRN_VAR  ;1079
		and ea2.end_effective_dt_tm > sysdate
		and ea2.active_ind = 1
	)
 
	,(inner join PERSON p on p.person_id = e.person_id
		and p.active_ind = 1
	)
 
where operator(ed.loc_facility_cd, OPR_FAC_VAR, $FACILITY_PMPT)
	and operator(ed.loc_nurse_unit_cd, OPR_NRU_VAR, $NURSE_UNIT_PMPT)
	and ed.end_effective_dt_tm > sysdate
	and ed.active_ind = 1
	and ed.loc_bed_cd > 0.00
 
order by pat_name, nurse_unit, encntr_id
 
head report
	cnt = 0
	stat = alterlist(a->list, 100)
 
head encntr_id
	cnt = cnt + 1
 
	if (mod(cnt,10) = 1 or cnt = 1)
		stat = alterlist(a->list, cnt + 9)
	endif
 
	a->list[cnt].facility		= facility
	a->list[cnt].nurse_unit		= nurse_unit
	a->list[cnt].room			= room
	a->list[cnt].bed			= bed
	a->list[cnt].room_bed		= room_bed
	a->list[cnt].pat_name		= pat_name
	a->list[cnt].fin			= fin
	a->list[cnt].mrn			= mrn
	a->list[cnt].dob			= dob
	a->list[cnt].age			= age
	a->list[cnt].arrive_dt		= arrive_dt
	a->list[cnt].encntr_id		= encntr_id
	a->list[cnt].person_id		= person_id
	a->rec_cnt					= cnt
 
foot report
	stat = alterlist(a->list, cnt)
 
with nocounter
 
 
;=================================
; GET BEDDING DATE FOR ENCOUNTER
;=================================
select into 'nl:'
	bedded_dt = max(elh.transaction_dt_tm) keep (dense_rank first order by elh.transaction_dt_tm) over (partition by elh.encntr_id)
 
from ENCNTR_LOC_HIST elh
 
where expand(idx, 1, size(a->list,5), elh.encntr_id, a->list[idx].encntr_id)
	and elh.encntr_type_cd in (ENCTYPE_INP_VAR, ENCTYPE_OBS_VAR) ;309308, 309312
	and elh.med_service_cd != EMERGENCY_MED_VAR ;313004
 
order by elh.encntr_id, elh.transaction_dt_tm
 
head report
	idx = 0
 
head elh.encntr_id
	idx = locateval(cnt, 1, size(a->list, 5), elh.encntr_id, a->list[cnt].encntr_id)
 
	a->list[idx].bedded_dt = bedded_dt
 
with nocounter, expand = 1
 
 
;===========================
; GET ORDERS FOR ENCOUNTER
;===========================
select into 'nl:'
 
from ORDERS o
 
	,(left join ORDER_DETAIL od on od.order_id = o.order_id
		and od.oe_field_meaning = "REQSTARTDTTM"
	)
 
where expand(idx, 1, size(a->list,5), o.encntr_id, a->list[idx].encntr_id)
	and o.catalog_cd in (CDIFFGDHTOXCD_VAR, CDIFFMOLECCD_VAR) ; 2553777719.00, 2553777729.00
	and o.order_status_cd in (ORD_ORDERED_VAR, ORD_COMPLETED_VAR) ;2550, 2543
 
order by o.encntr_id, o.order_id
 
head report
	idx = 0
	stat = alterlist(a->list[idx].ordlist, 100)
 
head o.encntr_id
	ocnt = 0
 
head o.order_id
	idx = locateval(cnt, 1, size(a->list, 5), o.encntr_id, a->list[cnt].encntr_id)
 	ocnt = ocnt + 1
 
 	if (mod(ocnt,10) = 1 or ocnt = 1)
 		stat = alterlist(a->list[idx].ordlist, ocnt + 9)
 	endif
 
	a->list[idx].ordlist[ocnt].order_id				= o.order_id
	a->list[idx].ordlist[ocnt].order_name 			= o.hna_order_mnemonic
	a->list[idx].ordlist[ocnt].order_status 		= uar_get_code_display(o.order_status_cd)
	a->list[idx].order_cnt 							= ocnt
 
	a->list[idx].ordlist[ocnt].specimen_collect		= evaluate2(
			if(o.dept_status_cd in (DOS_COLLECTED_VAR,DOS_COMPLETED_VAR,DOS_INTRANSIT_VAR,DOS_INLAB_VAR))
				"Yes" else "No"
			endif)
 
	a->list[idx].ordlist[ocnt].specimen_collect_dt	= evaluate2(
			if(o.dept_status_cd in (DOS_COLLECTED_VAR,DOS_COMPLETED_VAR,DOS_INTRANSIT_VAR,DOS_INLAB_VAR))
				od.oe_field_dt_tm_value
			endif)
 
foot o.encntr_id
	stat = alterlist(a->list[idx].ordlist, ocnt)
 
with nocounter, expand = 1
 
 
;============================================================================
; GET EVENTS FOR ENCOUNTER
;============================================================================
select into 'nl:'
 
from CLINICAL_EVENT ce
 
where expand(idx, 1, size(a->list,5), ce.encntr_id, a->list[idx].encntr_id)
	and (ce.event_end_dt_tm between cnvtlookbehind("48,H") and cnvtdatetime(curdate, curtime))
;	and ce.event_end_dt_tm between cnvtdatetime("14-MAR-2019 00:00:00") and cnvtdatetime("08-APR-2019 23:23:59")
	and ce.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 0")
	and ce.event_cd in (ISOL_TYPE_VAR, CDIFF_INTERP_VAR, CDIFF_NAAT_VAR, STOOL_DESC_VAR, STOOL_CNT_VAR)
;							(160794427, 2556642521, 2556636803, 703858, 710242)
 
order by ce.encntr_id, ce.event_end_dt_tm desc
 
head report
	idx = 0
	stat = alterlist(a->list[idx].eventlist, 100)
 
head ce.encntr_id
	idx = locateval(cnt, 1, size(a->list, 5), ce.encntr_id, a->list[cnt].encntr_id)
	ecnt = 0
 
head ce.event_id
 	ecnt = ecnt + 1
 
 	if (mod(ecnt,10) = 1 or ecnt = 1)
 		stat = alterlist(a->list[idx].eventlist, ecnt + 9)
 	endif
 
detail
	a->list[idx].eventlist[ecnt].event_id		= ce.event_id
	a->list[idx].eventlist[ecnt].event_cd		= ce.event_cd
	a->list[idx].eventlist[ecnt].event_end_dt	= ce.event_end_dt_tm
	a->list[idx].event_cnt 						= ecnt
 
	case (ce.event_cd)
		of (ISOL_TYPE_VAR):
				a->list[idx].eventlist[ecnt].isol_type 			= evaluate2(if(size(trim(ce.result_val,3)) > 0)
																	trim(ce.result_val,3) else ce.event_tag endif)
				a->list[idx].eventlist[ecnt].isol_type_dt		= ce.event_end_dt_tm
 
		of (CDIFF_INTERP_VAR):
				a->list[idx].eventlist[ecnt].cdiff_interp 		= evaluate2(if(size(trim(ce.result_val,3)) > 0)
																	trim(ce.result_val,3) else ce.event_tag endif)
				a->list[idx].eventlist[ecnt].cdiff_interp_dt	= ce.event_end_dt_tm
 
		of (CDIFF_NAAT_VAR):
				a->list[idx].eventlist[ecnt].cdiff_naat 		= evaluate2(if(size(trim(ce.result_val,3)) > 0)
																	trim(ce.result_val,3) else ce.event_tag endif)
				a->list[idx].eventlist[ecnt].cdiff_naat_dt		= ce.event_end_dt_tm
 
		of (STOOL_DESC_VAR):
				a->list[idx].eventlist[ecnt].stool_desc 		= evaluate2(if(size(trim(ce.result_val,3)) > 0)
																	trim(ce.result_val,3) else ce.event_tag endif)
				a->list[idx].eventlist[ecnt].stool_desc_dt		= ce.event_end_dt_tm
 
		of (STOOL_CNT_VAR):
				a->list[idx].eventlist[ecnt].stool_cnt 			= evaluate2(if(size(trim(ce.result_val,3)) > 0)
																	trim(ce.result_val,3) else ce.event_tag endif)
				a->list[idx].eventlist[ecnt].stool_cnt_dt		= ce.event_end_dt_tm
	endcase
 
foot ce.encntr_id
	stat = alterlist(a->list[idx].eventlist, ecnt)
 
with nocounter, expand = 1
 
 
;============================================================================
; GET STOOL-SCREEN FOR ENCOUNTER
;============================================================================
select into 'nl:'
 	stool_screen = max(ce.result_val) keep (dense_rank first order by ce.performed_dt_tm desc) over (partition by ce.encntr_id)
 
from CLINICAL_EVENT ce
 
where expand(idx, 1, size(a->list,5), ce.encntr_id, a->list[idx].encntr_id)
	and ce.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 0")
	and ce.event_cd = STOOL_SCR_VAR
	and ce.entry_mode_cd = POWERFORM_VAR
 
order by ce.encntr_id, ce.event_end_dt_tm desc
 
head report
	idx  = 0
 
head ce.encntr_id
	idx = locateval(cnt, 1, size(a->list, 5), ce.encntr_id, a->list[cnt].encntr_id)
 
	a->list[idx].stool_screen = stool_screen
 
with nocounter, expand = 1
 
 
;============================================================================
; COPY TO OUTPUT RECORD STRUCTURE
;============================================================================
set cnt = 0
 
;PATIENTS
for (pcnt = 1 to a->rec_cnt)
	set flag = 0
	set cnt = cnt + 1
	set stat = alterlist(output->list, cnt)
 
	set output->list[cnt].facility		= a->list[pcnt].facility
	set output->list[cnt].nurse_unit	= a->list[pcnt].nurse_unit
	set output->list[cnt].room			= a->list[pcnt].room
	set output->list[cnt].bed			= a->list[pcnt].bed
	set output->list[cnt].room_bed		= a->list[pcnt].room_bed
	set output->list[cnt].pat_name 		= a->list[pcnt].pat_name
	set output->list[cnt].fin			= a->list[pcnt].fin
	set output->list[cnt].dob			= a->list[pcnt].dob
	set output->list[cnt].age			= a->list[pcnt].age
	set output->list[cnt].arrive_dt		= a->list[pcnt].arrive_dt
	set output->list[cnt].bedded_dt		= a->list[pcnt].bedded_dt
	set output->list[cnt].stool_screen 	= a->list[pcnt].stool_screen
	set output->list[cnt].encntr_id		= a->list[pcnt].encntr_id
 
	set output->username				= a->username
	set output->rec_cnt					= cnt
 
	set output->list[cnt].order_exist 	= "No"
 
	;ORDERS
	for (ordcnt = 1 to a->list[cnt].order_cnt)
		if (a->list[pcnt].ordlist[ordcnt].order_id > 0.0)
			set output->list[cnt].order_exist 			= "Yes"
 
			set output->list[cnt].order_info =
				build2(output->list[cnt].order_info,
					trim(a->list[pcnt].ordlist[ordcnt].order_name,3), char(10),char(13),
					trim(a->list[pcnt].ordlist[ordcnt].order_status,3), char(10),char(13))
 
			set output->list[cnt].specimen_info =
				build2(output->list[cnt].specimen_info,
					trim(a->list[pcnt].ordlist[ordcnt].specimen_collect,3), char(10),char(13),
					format(a->list[pcnt].ordlist[ordcnt].specimen_collect_dt, "mm/dd/yy hh:mm;;q"), char(10),char(13))
		endif
	endfor
 
	;CLINICAL EVENTS
	for (cecnt = 1 to a->list[cnt].event_cnt)
		if (a->list[pcnt].eventlist[cecnt].event_id > 0.0)
 
 			;ISOLATION TYPE
			if (a->list[pcnt].eventlist[cecnt].event_cd = ISOL_TYPE_VAR)
				set output->list[cnt].isol_type	=
					build2(output->list[cnt].isol_type,
						a->list[pcnt].eventlist[cecnt].isol_type, value(char(10),char(13)))
;						if(size(a->list[pcnt].eventlist[cecnt].isol_type) > 0) value(char(10),char(13)) endif)
			endif
 
 			;CDIFF INTERP
			if (a->list[pcnt].eventlist[cecnt].event_cd = CDIFF_INTERP_VAR)
				set output->list[cnt].cdiff_result =
					build2(output->list[cnt].cdiff_result,
						a->list[pcnt].eventlist[cecnt].cdiff_interp, value(char(10),char(13)))
;						if(size(a->list[pcnt].eventlist[cecnt].cdiff_naat) > 0) value(char(10),char(13)) endif)
			endif
 
 			;CDIFF NAAT
			if (a->list[pcnt].eventlist[cecnt].event_cd = CDIFF_NAAT_VAR)
				set output->list[cnt].cdiff_result =
					build2(output->list[cnt].cdiff_result,
						a->list[pcnt].eventlist[cecnt].cdiff_naat, value(char(10),char(13)))
;						if(size(a->list[pcnt].eventlist[cecnt].cdiff_interp) > 0) value(char(10),char(13)) endif)
			endif
 
			;STOOL DESC
			if (a->list[pcnt].eventlist[cecnt].event_cd = STOOL_DESC_VAR)
				set output->list[cnt].stool_info =
					build2(output->list[cnt].stool_info,
						format(a->list[pcnt].eventlist[cecnt].stool_desc_dt, "mm/dd/yyyy hh:mm;;q"), " | ",
						a->list[pcnt].eventlist[cecnt].stool_desc, char(10),char(13))
			endif
 
			;STOOL COUNT
			if (a->list[pcnt].eventlist[cecnt].event_cd = STOOL_CNT_VAR)
				set output->list[cnt].stool_info =
					build2(output->list[cnt].stool_info,
						format(a->list[pcnt].eventlist[cecnt].stool_cnt_dt, "mm/dd/yyyy hh:mm;;q"), " | ",
						a->list[pcnt].eventlist[cecnt].stool_cnt, char(10),char(13))
			endif
 
			set output->list[cnt].event_end_dt = a->list[pcnt].eventlist[cecnt].event_end_dt
 
;			if(size(output->list[cnt].isol_type) = 0)
;				set output->list[cnt].isol_type = "n/a"
;			endif
;
;			if(size(output->list[cnt].cdiff_result) = 0)
;				set output->list[cnt].cdiff_result = "n/a"
;			endif
		endif
	endfor
 
endfor
 
 
;============================================================================
; REPORT OUTPUT
;============================================================================
if ($ORDERS_ONLY_PMPT = 1 and $STOOL_SCR_ONLY = 1)
 
	select distinct into value ($OUTDEV)
		 facility      	= output->list[d.seq].facility
		,nurse_unit    	= output->list[d.seq].nurse_unit
		,room_bed	   	= output->list[d.seq].room_bed
		,pat_name	   	= output->list[d.seq].pat_name
		,fin		   	= output->list[d.seq].fin
		,dob	     	= format(output->list[d.seq].dob, "mm/dd/yyyy;;q")
		,age			= output->list[d.seq].age
		,arrive_dt	 	= format(output->list[d.seq].arrive_dt, "mm/dd/yyyy hh:mm;;q")
		,bedded_dt	 	= format(output->list[d.seq].bedded_dt, "mm/dd/yyyy hh:mm;;q")
		,order_exist	= output->list[d.seq].order_exist
		,order_info		= output->list[d.seq].order_info
		,specimen_info	= output->list[d.seq].specimen_info
		,isol_type		= output->list[d.seq].isol_type
		,cdiff_result 	= trim(output->list[d.seq].cdiff_result,3)
		,stool_info		= output->list[d.seq].stool_info
		,stool_screen	= output->list[d.seq].stool_screen
	from
		 (DUMMYT d with seq = value(size(output->list,5)))
	where output->list[d.seq].order_exist = "Yes" and output->list[d.seq].stool_screen = "Yes"
	order by nurse_unit, room_bed, pat_name
	with nocounter, format, check, separator = " "
 
elseif ($ORDERS_ONLY_PMPT = 1 AND $STOOL_SCR_ONLY = 0)
 
	select distinct into value ($OUTDEV)
		 facility      	= output->list[d.seq].facility
		,nurse_unit    	= output->list[d.seq].nurse_unit
		,room_bed	   	= output->list[d.seq].room_bed
		,pat_name	   	= output->list[d.seq].pat_name
		,fin		   	= output->list[d.seq].fin
		,dob	     	= format(output->list[d.seq].dob, "mm/dd/yyyy;;q")
		,age			= output->list[d.seq].age
		,arrive_dt	 	= format(output->list[d.seq].arrive_dt, "mm/dd/yyyy hh:mm;;q")
		,bedded_dt	 	= format(output->list[d.seq].bedded_dt, "mm/dd/yyyy hh:mm;;q")
		,order_exist	= output->list[d.seq].order_exist
		,order_info		= output->list[d.seq].order_info
		,specimen_info	= output->list[d.seq].specimen_info
		,isol_type		= output->list[d.seq].isol_type
		,cdiff_result 	= trim(output->list[d.seq].cdiff_result,3)
		,stool_info		= output->list[d.seq].stool_info
		,stool_screen	= output->list[d.seq].stool_screen
	from
		 (DUMMYT d with seq = value(size(output->list,5)))
	where output->list[d.seq].order_exist = "Yes"
	order by nurse_unit, room_bed, pat_name
	with nocounter, format, check, separator = " "
 
elseif ($ORDERS_ONLY_PMPT = 0 AND $STOOL_SCR_ONLY = 1)
 
	select distinct into value ($OUTDEV)
		 facility      	= output->list[d.seq].facility
		,nurse_unit    	= output->list[d.seq].nurse_unit
		,room_bed	   	= output->list[d.seq].room_bed
		,pat_name	   	= output->list[d.seq].pat_name
		,fin		   	= output->list[d.seq].fin
		,dob	     	= format(output->list[d.seq].dob, "mm/dd/yyyy;;q")
		,age			= output->list[d.seq].age
		,arrive_dt	 	= format(output->list[d.seq].arrive_dt, "mm/dd/yyyy hh:mm;;q")
		,bedded_dt	 	= format(output->list[d.seq].bedded_dt, "mm/dd/yyyy hh:mm;;q")
		,order_exist	= output->list[d.seq].order_exist
		,order_info		= output->list[d.seq].order_info
		,specimen_info	= output->list[d.seq].specimen_info
		,isol_type		= output->list[d.seq].isol_type
		,cdiff_result 	= trim(output->list[d.seq].cdiff_result,3)
		,stool_info		= output->list[d.seq].stool_info
		,stool_screen	= output->list[d.seq].stool_screen
	from
		 (DUMMYT d with seq = value(size(output->list,5)))
	where output->list[d.seq].stool_screen = "Yes"
	order by nurse_unit, room_bed, pat_name
	with nocounter, format, check, separator = " "
 
elseif ($ORDERS_ONLY_PMPT = 0 AND $STOOL_SCR_ONLY = 0)
 
	select distinct into value ($OUTDEV)
		 facility      	= output->list[d.seq].facility
		,nurse_unit    	= output->list[d.seq].nurse_unit
		,room_bed	   	= output->list[d.seq].room_bed
		,pat_name	   	= output->list[d.seq].pat_name
		,fin		   	= output->list[d.seq].fin
		,dob	     	= format(output->list[d.seq].dob, "mm/dd/yyyy;;q")
		,age			= output->list[d.seq].age
		,arrive_dt	 	= format(output->list[d.seq].arrive_dt, "mm/dd/yyyy hh:mm;;q")
		,bedded_dt	 	= format(output->list[d.seq].bedded_dt, "mm/dd/yyyy hh:mm;;q")
		,order_exist	= output->list[d.seq].order_exist
		,order_info		= output->list[d.seq].order_info
		,specimen_info	= output->list[d.seq].specimen_info
		,isol_type		= output->list[d.seq].isol_type
		,cdiff_result 	= trim(output->list[d.seq].cdiff_result,3)
		,stool_info		= output->list[d.seq].stool_info
		,stool_screen	= output->list[d.seq].stool_screen
	from
		 (DUMMYT d with seq = value(size(output->list,5)))
	order by nurse_unit, room_bed, pat_name
	with nocounter, format, check, separator = " "
 
endif
 
;call echorecord(a)
;go to exitscript
 
#exitscript
end
go
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
 
