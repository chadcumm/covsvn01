/*****************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
******************************************************************************
	Author:				Dan Herren
	Date Written:		July 2019
	Solution:			Pharmacy
	Source file name:  	cov_pha_AntidoteUsage.prg
	Object name:		cov_pha_AntidoteUsage
	Layout file name:   cov_pha_AntidoteUsage_lb
	CR#:				3373
 
	Program purpose:	Usage report for pharmacy antidote meds.
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
 
drop program cov_pha_AntidoteUsage:DBA go
create program cov_pha_AntidoteUsage:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Report or Grid" = 0
	, "Facility" = 0
	, "Nurse Unit" = 0
 
with OUTDEV, RPT_GRID_PMPT, FACILITY_PMPT
 
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
Record med (
	1 rec_cnt				= i4
	1 username				= vc
	1 list[*]
		2 fac_abbr      	= vc
		2 fac_desc      	= vc
		2 nurse_unit    	= vc
		2 pat_name			= vc
		2 fin           	= vc
		2 order_status		= vc
		2 admin_start_dt	= dq8
		2 admin_stop_dt		= dq8
		2 performed_dt		= dq8
		2 given_dt			= dq8
		2 order_dt			= dq8
		2 medication		= vc
		2 med_details		= vc
		2 dosage			= vc
		2 dosage_unit		= vc
		2 dosage_route		= vc
		2 frequency			= vc
		2 prn				= vc
		2 od_start_dt		= dq8
		2 od_stop_dt		= dq8
		2 provider			= vc
		2 position			= vc
		2 admit_type		= vc
		2 encntr_type		= vc
		2 event_type		= vc
		2 action_sequence	= i4
		2 encntr_id			= f8
		2 event_id			= f8
		2 orig_order_id		= f8
		2 order_id			= f8
)
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/       ; prn reason code-set 4005
declare username           		= vc with protect
declare initcap()          		= c100
declare num				   		= i4 with noconstant(0)
;
;--CLINICAL_EVENT EVENT_CD--
;declare DEXTROSE_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"DEXTROSE50INWATER")),protect
;declare FLUMAZENIL_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"FLUMAZENIL")),protect
;declare GLUCAGON_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"GLUCAGON")),protect
;declare NALOXONE_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"NALOXONE")),protect
;declare PHYTONADIONE_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"PHYTONADIONE")),protect
;declare PROTAMINE_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"PROTAMINE")),protect
;declare ACETYLCYSTEINE_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"ACETYLCYSTEINE")),protect
;declare IDARUCIZUMAB_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"IDARUCIZUMAB")),protect
;declare DIPHENHYDRAMINE_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"DIPHENHYDRAMINE")),protect
;declare BENADRYLANDMAALOX_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"BENADRYLANDMAALOX")),protect
;declare HYDROCORTISONE_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"HYDROCORTISONE")),protect
;declare METHYLPREDNISOLONE_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"METHYLPREDNISOLONE")),protect
;declare SODIUM_POLY_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",72,"SODIUMPOLYSTYRENESULFONATE")),protect
;
;--ORDER CATALOG_CD--
declare DEXTROSE_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",200,"DEXTROSE50INWATER")),protect
declare FLUMAZENIL_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",200,"FLUMAZENIL")),protect
declare GLUCAGON_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",200,"GLUCAGON")),protect
declare NALOXONE_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",200,"NALOXONE")),protect
declare PHYTONADIONE_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",200,"PHYTONADIONE")),protect
declare PROTAMINE_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",200,"PROTAMINE")),protect
declare ACETYLCYSTEINE_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",200,"ACETYLCYSTEINE")),protect
declare DIPHENHYDRAMINE_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",200,"DIPHENHYDRAMINE")),protect
declare SODIUM_POLY_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",200,"SODIUMPOLYSTYRENESULFONATE")),protect
declare ANTIINHIBITOR_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",200,"ANTIINHIBITORCOAGULANTCOMPLEX")),protect
declare DESMOPRESSIN_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",200,"DESMOPRESSIN")),protect
declare GLUCOSE_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY",200,"GLUCOSE")),protect
declare HYALURONIDASE_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",200,"HYALURONIDASE")),protect
declare IDARUCIZUMAB_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",200,"IDARUCIZUMAB")),protect
declare PHENTOLAMINE_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",200,"PHENTOLAMINE")),protect
declare PROTHROMBIN_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",200,"PROTHROMBINCOMPLEX")),protect
declare SODIUMZIRCONIUM_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",200,"SODIUMZIRCONIUMCYCLOSILICATE")),protect
declare TERBUTALINE_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",200,"TERBUTALINE")),protect
;declare BENADRYLANDMAALOX_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY",200,"BENADRYLANDMAALOX")),protect
;declare HYDROCORTISONE_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",200,"HYDROCORTISONE")),protect
;declare METHYLPREDNISOLONE_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY",200,"METHYLPREDNISOLONE")),protect
;
declare STRENGTHDOSE_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",16449,"STRENGTHDOSE")),protect
declare STRENGTHDOSEUNIT_VAR	= f8 with constant(uar_get_code_by("DISPLAYKEY",16449,"STRENGTH DOSE UNIT")),protect
declare RXROUTE_VAR				= f8 with constant(uar_get_code_by("DISPLAYKEY",16449,"ROUTE OF ADMINISTRATION")),protect
declare FREQUENCY_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",16449,"FREQUENCY")),protect
declare REQSTARTDTTM_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",16449,"REQUESTEDSTARTDATETIME")),protect
declare STOPDTTM_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",16449,"STOPDATETIME")),protect
;
declare FIN_VAR            		= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR")),protect
declare ADMINISTERED_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",4000040,"ADMINISTERED")),protect
declare PHA_TYPE_VAR			= f8 with constant(uar_get_code_by("DISPLAYKEY",6000,"PHARMACY")),protect
;
declare OPR_FAC_VAR		   		= vc with noconstant(fillstring(1000," "))
declare OPR_NRU_VAR		   		= vc with noconstant(fillstring(1000," "))
 
 
/**************************************************************
; DVDev START CODING
**************************************************************/
;GET USERNAME FOR REPORT
select into "NL:"
from
	prsnl p
where p.person_id = reqinfo->updt_id
detail
	med->username = p.username
with nocounter
 
 
;SET FACILITY PROMPT VARIABLE
if(substring(1,1,reflect(parameter(parameter2($FACILITY_PMPT),0))) = "L")	;multiple values were selected
	set OPR_FAC_VAR = "in"
elseif(parameter(parameter2($FACILITY_PMPT),1)= 0.0)						;all (any) values were selected
	set OPR_FAC_VAR = "!="
else																		;a single value was selected
	set OPR_FAC_VAR = "="
endif
 
 
;SET NURSE UNIT PROMPT VARIABLE
;if(substring(1,1,reflect(parameter(parameter2($NURSE_UNIT_PMPT),0))) = "L")	;multiple values were selected
;	set OPR_NRU_VAR = "in"
;elseif(parameter(parameter2($NURSE_UNIT_PMPT),1)= 0.0)							;all (any) values were selected
;	set OPR_NRU_VAR = "!="
;else																			;a single value was selected
;	set OPR_NRU_VAR = "="
;endif
 
;====================================================
;MAIN SELECT FOR DATA
;====================================================
select distinct into "NL:"
	 fac_abbr 		= uar_get_code_display(e.loc_facility_cd)
	,fac_desc		= uar_get_code_description(e.loc_facility_cd)
	,nurse_unit 	= uar_get_code_display(e.loc_nurse_unit_cd)
	,pat_name		= initcap(p.name_full_formatted)
	,fin			= ea.alias
	,order_status	= uar_get_code_display(o.order_status_cd)
;	,order_dt		= o.current_start_dt_tm "@SHORTDATETIME"
	,order_dt		= o.orig_order_dt_tm "@SHORTDATETIME"
;	,admin_start_dt	= mae.beg_dt_tm "@SHORTDATETIME"
;	,admin_stop_dt	= mae.end_dt_tm "@SHORTDATETIME"
;	,performed_dt	= ce.performed_dt_tm "@SHORTDATETIME"
	,given_dt		= ce.event_end_dt_tm "@SHORTDATETIME"
	,medication 	= o.order_mnemonic
	,med_details	= o.simplified_display_line
	,dosage 		= od1.oe_field_display_value
	,dosage_unit	= od2.oe_field_display_value
	,dosage_route 	= od3.oe_field_display_value
	,frequency		= od4.oe_field_display_value
	,prn			= if(o.prn_ind = 1) "Yes" else "No" endif
	,od_start_dt	= od5.oe_field_dt_tm_value "@SHORTDATETIME"
	,od_stop_dt		= od6.oe_field_dt_tm_value "@SHORTDATETIME"
	,provider		= initcap(pl.name_full_formatted)
	,position 		= uar_get_code_display(pl.position_cd)
	,encntr_type	= uar_get_code_display(e.encntr_type_cd)
	,admit_type		= uar_get_code_display(e.admit_type_cd)
	,event_type		= uar_get_code_display(mae.event_type_cd)
	,encntr_id		= e.encntr_id
	,orig_order_id	= o.order_id
	,order_id 		= if(o.template_order_flag = 4) o.template_order_id else o.order_id endif
 
from ORDERS o
 
	,(left join ORDER_DETAIL od1 on od1.order_id = o.order_id
		and od1.oe_field_id = STRENGTHDOSE_VAR) ;12715
 
	,(left join ORDER_DETAIL od2 on od2.order_id = o.order_id
		and od2.oe_field_id = STRENGTHDOSEUNIT_VAR) ;12716)
 
	,(left join ORDER_DETAIL od3 on od3.order_id = o.order_id
		and od3.oe_field_id = RXROUTE_VAR) ;12711)
 
	,(left join ORDER_DETAIL od4 on od4.order_id = o.order_id
;		and od4.oe_field_display_value = "Once"
		and od4.oe_field_id = FREQUENCY_VAR) ;12690
 
	,(left join ORDER_DETAIL od5 on od5.order_id = o.order_id
		and od5.oe_field_id = REQSTARTDTTM_VAR) ;12620
 
	,(left join ORDER_DETAIL od6 on od6.order_id = o.order_id
		and od6.oe_field_id = STOPDTTM_VAR) ;12731
 
	,(inner join MED_ADMIN_EVENT mae on mae.order_id = o.order_id
;		and (mae.beg_dt_tm between cnvtdatetime(curdate-1, 0700) and cnvtdatetime(curdate, 0700))
		and mae.event_type_cd = ADMINISTERED_VAR)  ;4055412.00
 
	,(inner join ENCOUNTER e on e.encntr_id = o.encntr_id
		and e.loc_facility_cd = $FACILITY_PMPT
		and e.disch_dt_tm = null
		and e.encntr_id != 0.00
		and e.active_ind = 1)
 
	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = FIN_VAR ;1077
;		and ea.alias = "1921201792"
		and ea.active_ind = 1)
 
	,(inner join CLINICAL_EVENT ce on ce.encntr_id = e.encntr_id
		and ce.order_id = o.order_id
		and (ce.event_end_dt_tm between cnvtdatetime(curdate-1, 0700) and cnvtdatetime(curdate, 0700))
		and ce.valid_until_dt_tm = cnvtdatetime("31-DEC-2100 0"))
 
	,(inner join PERSON p on p.person_id = e.person_id
		and p.active_ind = 1)
 
	,(inner join PRSNL pl on pl.person_id = mae.prsnl_id
		and pl.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
		and pl.active_ind = 1)
 
where o.catalog_type_cd = PHA_TYPE_VAR ;2516
	and o.catalog_cd in (DEXTROSE_VAR, FLUMAZENIL_VAR, GLUCAGON_VAR, NALOXONE_VAR, PHYTONADIONE_VAR,
			PROTAMINE_VAR, ACETYLCYSTEINE_VAR, IDARUCIZUMAB_VAR, DIPHENHYDRAMINE_VAR, SODIUM_POLY_VAR,
			ANTIINHIBITOR_VAR, DESMOPRESSIN_VAR, GLUCOSE_VAR, HYALURONIDASE_VAR, IDARUCIZUMAB_VAR,
			PHENTOLAMINE_VAR, PROTHROMBIN_VAR, SODIUMZIRCONIUM_VAR, TERBUTALINE_VAR) ;antidotes
	and o.active_ind = 1
;	and o.prn_ind = 1
 
order by fac_abbr, nurse_unit, pat_name, given_dt desc, encntr_id, order_id
 
head report
	cnt  = 0
 
detail
 	cnt = cnt + 1
 
	if (mod(cnt,10) = 1 or cnt = 10)
		stat = alterlist(med->list,cnt + 9)
	endif
 
 	med->rec_cnt = cnt
	med->list[cnt].fac_abbr     	= fac_abbr
	med->list[cnt].fac_desc     	= fac_desc
	med->list[cnt].nurse_unit   	= nurse_unit
	med->list[cnt].pat_name			= pat_name
	med->list[cnt].fin 				= fin
	med->list[cnt].order_status		= order_status
	med->list[cnt].order_dt			= order_dt
;	med->list[cnt].admin_start_dt	= admin_start_dt
;	med->list[cnt].admin_stop_dt	= admin_stop_dt
;	med->list[cnt].performed_dt		= performed_dt
	med->list[cnt].given_dt			= given_dt
	med->list[cnt].medication   	= medication
	med->list[cnt].med_details		= med_details
	med->list[cnt].dosage 			= dosage
	med->list[cnt].dosage_unit 		= dosage_unit
	med->list[cnt].dosage_route 	= dosage_route
	med->list[cnt].frequency 		= frequency
	med->list[cnt].prn				= prn
	med->list[cnt].od_start_dt 		= od_start_dt
	med->list[cnt].od_stop_dt 		= od_stop_dt
	med->list[cnt].provider			= provider
	med->list[cnt].position     	= position
	med->list[cnt].encntr_type		= encntr_type
	med->list[cnt].admit_type		= admit_type
	med->list[cnt].event_type		= event_type
	med->list[cnt].encntr_id		= encntr_id
	med->list[cnt].orig_order_id 	= orig_order_id
	med->list[cnt].order_id			= order_id
 
;	if(o.template_order_flag = 4)  ;child orders (Rx Based Instance)
;		if(o.template_order_id != 0)
;			med->list[cnt].order_id = o.template_order_id
;		endif
;	endif
 
foot report
	stat = alterlist(med->list, cnt)
 
with nocounter
;
;call echorecord(med)
;;go to exitscript
 
 
;========================================================
; GET DOSE, DOSE UNIT, DOSE ROUTE, START, STOP
;========================================================
;select distinct into "NL:"
;	 ord = max(od.oe_field_display_value) keep (dense_rank last order by od.action_sequence ASC)
;		over (partition by med->list[num].encntr_id, od.order_id, od.oe_field_id)
;
;	,dttm = max(od.oe_field_dt_tm_value) keep (dense_rank last order by od.action_sequence ASC)
;		over (partition by med->list[num].encntr_id, od.order_id, od.oe_field_id)
;
;from ORDER_DETAIL od
;
;where expand(num, 1, size(med->list, 5), od.order_id, med->list[num].order_id)
;    and od.oe_field_id in (STRENGTHDOSE_VAR, STRENGTHDOSEUNIT_VAR, RXROUTE_VAR, FREQUENCY_VAR, REQSTARTDTTM_VAR, STOPDTTM_VAR )
;
;order by od.order_id, od.oe_field_id
;
;head od.order_id
; 	cnt = 0
;	idx = 0
;	idx = locateval(cnt, 1, size(med->list,5), od.order_id, med->list[cnt].order_id)
;
;head od.oe_field_id
;	case (od.oe_field_id)
;		of STRENGTHDOSE_VAR :
;			med->list[idx].dosage = trim(ord,3)
;
;		of STRENGTHDOSEUNIT_VAR :
;			med->list[idx].dosage_unit = trim(ord,3)
;
;		of RXROUTE_VAR :
;			med->list[idx].dosage_route = trim(ord,3)
;
;	    of FREQUENCY_VAR :
;			med->list[idx].frequency = trim(ord,3)
;
;	    of REQSTARTDTTM_VAR :
;	     	med->list[idx].od_start_dt = dttm
;
;	    of STOPDTTM_VAR :
;	      	med->list[idx].od_stop_dt = dttm
;	endcase
;
;with nocounter, expand=1
 
 
;;-----------------  FREQUENCY - START -------------------
 
;;-----------------  FREQUENCY - END -------------------
 
call echorecord(med)
;;go to exitscript
 
 
;====================================================
; REPORT OUTPUT
;====================================================
select into value ($OUTDEV)
	 fac_abbr      	= med->list[d.seq].fac_abbr
	,fac_desc      	= substring(1,60,trim(med->list[d.seq].fac_desc,3))
	,nurse_unit    	= substring(1,40,trim(med->list[d.seq].nurse_unit,3))
	,pat_name		= substring(1,40,trim(med->list[d.seq].pat_name,3))
	,fin			= med->list[d.seq].fin
	,order_status	= med->list[d.seq].order_status
	,order_dt		= format(med->list[d.seq].order_dt, "mm/dd/yyyy hh:mm;;q")
;	,admin_start_dt	= format(med->list[d.seq].admin_start_dt, "mm/dd/yyyy hh:mm;;q")
;	,admin_stop_dt	= format(med->list[d.seq].admin_stop_dt, "mm/dd/yyyy hh:mm;;q")
;	,performed_dt	= format(med->list[d.seq].performed_dt, "mm/dd/yyyy hh:mm;;q")
	,given_dt		= format(med->list[d.seq].given_dt, "mm/dd/yyyy hh:mm;;q")
	,medication	   	= substring(1,70,med->list[d.seq].medication)
	,med_details	= substring(1,75,trim(med->list[d.seq].med_details,3))
	,dosage   		= med->list[d.seq].dosage
	,dosage_unit	= med->list[d.seq].dosage_unit
	,dosage_route 	= med->list[d.seq].dosage_route
	,frequency		= substring(1,20,med->list[d.seq].frequency)
	,prn			= med->list[d.seq].prn
	,od_start_dt   	= format(med->list[d.seq].od_start_dt, "mm/dd/yyyy hh:mm;;q")
	,od_stop_dt    	= format(med->list[d.seq].od_stop_dt, "mm/dd/yyyy hh:mm;;q")
	,provider		= substring(1,50,trim(med->list[d.seq].provider,3))
 	,position		= substring(1,60,trim(med->list[d.seq].position,3))
	,admit_type		= med->list[d.seq].admit_type
	,encntr_type	= med->list[d.seq].encntr_type
	,event_type		= med->list[d.seq].event_type
	,encntr_id     	= med->list[d.seq].encntr_id
	,orig_order_id	= med->list[d.seq].orig_order_id
	,order_id	   	= med->list[d.seq].order_id
	,username      	= med->username
	,rec_cnt		= med->rec_cnt
 
from
	(DUMMYT d with seq = value(size(med->list,5)))
 
plan d ;where prn = "Yes" and frequency = "Once"
 
order by fac_abbr, nurse_unit, pat_name, given_dt desc, encntr_id, order_id
 
with nocounter, format, check, separator = " "
 
#exitscript
end
go
 
 
/*
;;-----------------  FREQUENCY - START -------------------
;;========================================================
;; GET FREQUENCY ID FOR ALL ORDERS
;;========================================================
;select distinct into 'nl:'
;	 od.order_id
;	,od.action_sequence
;	,admin_dt = med->list[num].admin_dt
;	,event_id = med->list[num].event_id
;	,od.oe_field_display_value
;
;from ORDER_DETAIL od
;
;where expand(num, 1, size(med->list, 5), od.order_id, med->list[num].orig_order_id)
;	and od.oe_field_id = 2553779337.00 ;FREQSCHEDID  12690
;
;order by od.order_id, od.oe_field_id, admin_dt
;
;head od.order_id
;	idx = 0
;	cnt = 0
;    idx = locateval(cnt, 1, size(med->list, 5), od.order_id, med->list[cnt].orig_order_id)
;
;;	med->list[idx].freq_id = od.oe_field_value
;
;    while(idx > 0)
;		med->list[idx].freq_id = od.oe_field_value
;	    idx = locateval(cnt,(idx+1), size(med->list, 5), od.order_id, med->list[cnt].orig_order_id)
;    endwhile
;;call echo(build2("freq_id = ",med->list[idx].freq_id))
;
;foot  od.order_id
;    null
;
;with nocounter ,expand = 1
;
;
;;========================================================
;; GET ACTION SEQUENCE FROM PARENT (PARENT ORDER_ID)
;;========================================================
;select distinct into 'nl:'
;	 parent = med->list[num].order_id
;	,child  = med->list[num].orig_order_id
;	,od.oe_field_display_value
;	,od.action_sequence
;
;from ORDER_DETAIL od
;
;where expand(num, 1, size(med->list, 5), od.order_id, med->list[num].order_id)
;	and od.oe_field_id = 2553779337.00 ;FREQSCHEDID 12690
;	and od.oe_field_value = med->list[num].freq_id
;
;order by parent, child, od.oe_field_value, od.action_sequence
;
;head child
;	idx = 0
;	cnt = 0
; 	idx = locateval(cnt, 1, size(med->list,5), child, med->list[cnt].orig_order_id)
;
;;	med->list[idx].action_sequence = od.action_sequence
;
;    while(idx > 0)
;		med->list[idx].action_sequence = od.action_sequence
;	    idx = locateval(cnt,(idx+1), size(med->list, 5), child, med->list[cnt].orig_order_id)
;    endwhile
;
;;call echo(build2("AS size(med->list,5) = ",size(med->list,5)))
;foot child
;    null
;
;with nocounter, expand = 1
;
;
;;========================================================
;; GET FREQUENCY FROM ORDER_DETAIL (PARENT ORDER_ID)
;;========================================================
;select distinct into 'nl:'
;	 parent_oid = med->list[num].order_id
;	,child_oid 	= med->list[num].orig_order_id
;	,action 	= med->list[num].action_sequence
;	,freq_id 	= med->list[num].freq_id
;	,od.oe_field_display_value
;
;from ORDER_DETAIL od
;
;	,(inner join ORDER_ACTION oa on oa.order_id = med->list[num].order_id
;		and oa.action_sequence = med->list[num].action_sequence)
;
;where expand(num, 1, size(med->list, 5), od.order_id, med->list[num].order_id)
;	and od.action_sequence = med->list[num].action_sequence
;	and od.oe_field_id = 12690.00 ;FREQ
;
;order by parent_oid, child_oid, od.oe_field_display_value
;
;head parent_oid
;	null
;
;head child_oid
;	idx = 0
;	cnt = 0
; 	idx = locateval(cnt, 1, size(med->list,5), child_oid, med->list[cnt].orig_order_id)
;
;;	med->list[idx].frequency = od.oe_field_display_value
;
;    while(idx > 0)
;		med->list[idx].frequency = od.oe_field_display_value
;;		med->list[idx].detail_display = trim(oa.clinical_display_line,3)
;	    idx = locateval(cnt,(idx+1), size(med->list,5), child_oid, med->list[cnt].orig_order_id)
;;call echo(build2("freq = ", med->list[idx].frequency))
;    endwhile
;
;foot  child_oid
;    null
;
;with nocounter ,expand = 1
;
;;-----------------  FREQUENCY - END -------------------
;
;;;========================================================
;;; GET FREQUENCY OF ONCE FROM ORDER_DETAIL
;;;========================================================
;select distinct into 'nl:'
;from ORDER_DETAIL od
;
;where expand(num, 1, size(med->list, 5), od.order_id, med->list[num].order_id)
;	and od.oe_field_id = 12690.00 ;FREQ
;
;order by od.order_id
;
;head od.order_id
;	idx = 0
;	cnt = 0
; 	idx = locateval(cnt, 1, size(med->list,5), od.order_id, med->list[cnt].od.order_id)
;
;    while(idx > 0)
;		med->list[idx].frequency = od.oe_field_display_value
;    endwhile
;
;foot od.order_id
;    null
;
;with nocounter ,expand = 1
;
*/
