/*****************************************************************************
 *  Covenant Health Information Technology
 *  Knoxville, Tennessee
 *****************************************************************************
 
    Author:            Dan Herren
    Date Written:      March 2018
    Soluation:         Perioperative / SurgiNet
    Source file name:  cov_peri_PhysicanTurnover.prg
    Object name:       cov_peri_PhysicanTurnover
    Request #:
 	CR #:			   1369
 
    Program purpose:   Procedure turnover based on pat-in/out to next in.
 
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
 
drop program cov_peri_PhysicianTurnover go
create program cov_peri_PhysicianTurnover
 
prompt
	"Output to File/Printer/MINE" = "MINE"             ;* Enter or select the printer or file name to send this report to.
	, "FACILITY" = VALUE(0.0)
	, "CHECK-IN DATE RANGE" = "01-JAN-2018 00:00:00"
	, "" = "SYSDATE"
 
with OUTDEV, FACILITY_PMPT, STARTDATE_PMPT, ENDDATE_PMPT
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
;free record enc
record enc
(
1 prompt_startdate       = vc
1 prompt_enddate         = vc
1 list [*]
;---PERSON
	2 person_id          = f8    ;pid
	2 pat_name		     = c35   ;pat_name
 
;---CASE
	2 surg_case_id		 = f8	 ;surg_case_id
	2 surg_case_proc_id  = f8	 ;surg case procedure id
	2 surg_case_nbr		 = c25    ;surg case number
	2 pat_start_dt	     = f8    ;patient start date
	2 pat_stop_dt        = f8    ;patient stop date
	2 case_start_dt		 = f8    ;case start date
	2 case_stop_dt		 = f8	 ;case stop date
	2 turnover_min		 = i4	 ;turnover minutes
	2 case_dur           = i4    ;case duration
	2 proc_abbr          = c50   ;procedure abbreviation
 
;---ENCOUNTER
	2 encntr_id          = f8    ;eid
	2 fac_name           = c30	 ;facility name
	2 fac_abbr 	         = c10   ;facility abbr
	2 fac_unit           = c25   ;facility unit
	2 fac_room			 = c25	 ;facility room
	2 fin		         = c25   ;encounter fin
 
;---PERIOPERATIVE
	2 primary_surgeon_id = f8	 ;primary surgeon id
	2 surgeon            = c35   ;surgeon
	2 crna				 = c35	 ;crna
	2 circ				 = c35   ;circ
)
 
;**************************************************************
; DVDev DECLARED VARIABLES
;**************************************************************
declare CLMC_VAR		  = f8 with constant(uar_get_code_by("DISPLAY_KEY",220,"CLMC")),protect	  ;2553765291
declare CMC_VAR			  = f8 with constant(uar_get_code_by("DISPLAY_KEY",220,"CMC")),protect	  ;2552503661
declare FLMC_VAR		  = f8 with constant(uar_get_code_by("DISPLAY_KEY",220,"FLMC")),protect   ;2552503635
declare FSR_VAR			  = f8 with constant(uar_get_code_by("DISPLAY_KEY",220,"FSR")),protect    ;  21250403
declare LCMC_VAR		  = f8 with constant(uar_get_code_by("DISPLAY_KEY",220,"LCMC")),protect   ;2552503653
declare MHHS_VAR		  = f8 with constant(uar_get_code_by("DISPLAY_KEY",220,"MHHS")),protect   ;2552503639
declare MMC_VAR			  = f8 with constant(uar_get_code_by("DISPLAY_KEY",220,"MMC")),protect    ;2552503613
declare PWMC_VAR		  = f8 with constant(uar_get_code_by("DISPLAY_KEY",220,"PW")),protect     ;2552503645
declare RMC_VAR			  = f8 with constant(uar_get_code_by("DISPLAY_KEY",220,"RMC")),protect    ;2552503649
;
declare FIN_VAR           = f8 with constant(uar_get_code_by("MEANING",319,"FIN NBR")),protect	  ;3061.00
declare CRNA_VAR		  = f8 with constant(uar_get_code_by("DISPLAYKEY",10170,"CRNA")),protect  ;3064.00
declare CIRC_VAR		  = f8 with constant(uar_get_code_by("DISPLAYKEY",10170,"NURSECIRCULATOR")),protect
;
declare FACILITY_VAR      = vc with noconstant(fillstring(1000," "))
declare OPR_FAC_VAR		  = vc with noconstant(fillstring(1000," "))
 
declare initcap()		  = c100
 
;**************************************************************
; DVDev START CODE
;**************************************************************
set enc->prompt_startdate = substring(1,11,$STARTDATE_PMPT)
set enc->prompt_enddate   = substring(1,11,$ENDDATE_PMPT)
 
; set facility variable
if(substring(1,1,reflect(parameter(parameter2($FACILITY_PMPT),0))) = "L")  ;multiple dispositions were selected
	set OPR_FAC_VAR = "in"
	elseif(parameter(parameter2($FACILITY_PMPT),1)= 0.0) ;all (any) dispositions were selected
		set OPR_FAC_VAR = "!="
	else 							;a single value was selected
	set OPR_FAC_VAR = "="
endif
 
;================================================
; SELECT SURGICAL ENCOUNTERS BY PROCEDURE
;================================================
select distinct into "NL:"
;select distinct into value ($outdev)
 
;---PERSON
	 person_id   	    = e.person_id
	,pat_name    	    = initcap(p.name_full_formatted)
 
;---CASE
	,surg_case_id	    = scp.surg_case_id
 	,surg_case_proc_id  = scp.surg_case_proc_id
	,surg_case_nbr 		= sc.surg_case_nbr_formatted
	,pat_start_dt       = ct1.case_time_dt_tm
	,pat_stop_dt	    = ct2.case_time_dt_tm
	,case_start_dt	    = sc.surg_start_dt_tm
	,case_stop_dt	    = sc.surg_stop_dt_tm
	,case_dur     	    = datetimediff(sc.surg_stop_dt_tm, sc.surg_start_dt_tm,4)
	,proc_abbr   	    = uar_get_code_display(scp.surg_proc_cd)
 
;---ENCOUNTER
	,encntr_id   	    = e.encntr_id
	,fac_name	   	    = uar_get_code_description(e.loc_facility_cd)
	,fac_abbr    	    = uar_get_code_display(e.loc_facility_cd)
	,fac_unit    	    = uar_get_code_display(e.loc_nurse_unit_cd)
 	,fac_room			= uar_get_code_display(e.loc_room_cd)
 
;---PERIOPERATIVE
	,primary_surgeon_id = scp.primary_surgeon_id
	,surgeon 	   	    = initcap(pl1.name_full_formatted)
	,crna				= pl2.name_last   ;pl2.name_full_formatted
	,circ				= pl3.name_last
;	,ca_role_perf_cd 	= ca.role_perf_cd
 
from
	 SURG_CASE_PROCEDURE scp
	,SURGICAL_CASE		 sc
	,CASE_TIMES	         ct1
	,CASE_TIMES	         ct2
	,CASE_ATTENDANCE	 ca1
	,CASE_ATTENDANCE	 ca2
	,ENCOUNTER 			 e
;	,CLINICAL_EVENT	     ce
	,PERSON              p
	,PRSNL               pl1
	,PRSNL	             pl2
	,PRSNL	             pl3
 
plan scp
	where scp.proc_start_dt_tm between cnvtdatetime($STARTDATE_PMPT) and cnvtdatetime($ENDDATE_PMPT)
		and scp.active_ind = 1
;		and scp.end_effective_dt_tm >= sysdate
 
join sc
	where sc.surg_case_id = scp.surg_case_id
		and sc.active_ind = 1
 
join ct1
	where ct1.surg_case_id = scp.surg_case_id
		and ct1.active_ind = 1
;		and ct1.end_effective_dt_tm >= sysdate
		and ct1.task_assay_cd = 667192 ;patient-in
 
join ct2
	where ct2.surg_case_id = scp.surg_case_id
		and ct2.active_ind = 1
;		and ct2.end_effective_dt_tm >= sysdate
		and ct2.task_assay_cd = 667193 ;patient-out
 
join ca1
	where ca1.surg_case_id = outerjoin(sc.surg_case_id)
		and ca1.active_ind = outerjoin(1)
		and ca1.role_perf_cd = outerjoin(CRNA_VAR)  ;CRNA 3064.00
;		and ca1.end_effective_dt_tm >= sysdate
 
join ca2
	where ca2.surg_case_id = outerjoin(sc.surg_case_id)
		and ca2.active_ind = outerjoin(1)
		and ca2.role_perf_cd = outerjoin(CIRC_VAR)  ;CIRCULATOR 3061.00
;		and ca.end_effective_dt_tm >= sysdate
 
join e
	where e.encntr_id = sc.encntr_id
		and operator(e.loc_facility_cd, OPR_FAC_VAR, $FACILITY_PMPT)
		and	e.loc_facility_cd in (
			2553765291.00,  2552503657.00, 2552503635.00, 21250403.00, 2552503653.00,
			2552503639.00, 2552503613.00, 2552503645.00, 2552503649.00
			)
		and e.active_ind = 1
		and e.end_effective_dt_tm >= sysdate
 
;join ce
;	where ce.encntr_id = e.encntr_id
 
join p
	where p.person_id = e.person_id
		and p.person_id = sc.person_id
		and p.active_ind = 1
		and p.end_effective_dt_tm >= sysdate
 
join pl1
	where pl1.person_id = outerjoin(scp.primary_surgeon_id)
		and pl1.physician_ind = 1
		and pl1.end_effective_dt_tm >= sysdate
 
join pl2
	where pl2.person_id = outerjoin(ca1.case_attendee_id)  ;CRNA
		and pl2.active_ind = outerjoin(1)
 
join pl3
	where pl3.person_id = outerjoin(ca2.case_attendee_id)  ;CIRCULATOR
		and pl3.active_ind = outerjoin(1)
 
order by person_id, encntr_id, surg_case_id
 
head report
	cnt = 0
 
detail
	cnt = cnt + 1
	stat = alterlist(enc->list,cnt)
 
;---PERSON
	enc->list[cnt].person_id 	      = p.person_id
	enc->list[cnt].pat_name    	      = pat_name
 
;---CASE
	enc->list[cnt].surg_case_id       = surg_case_id
	enc->list[cnt].surg_case_proc_id  = surg_case_proc_id
	enc->list[cnt].surg_case_nbr	  = surg_case_nbr
	enc->list[cnt].pat_start_dt       = pat_start_dt
	enc->list[cnt].pat_stop_dt 	      = pat_stop_dt
	enc->list[cnt].case_start_dt      = case_start_dt
	enc->list[cnt].case_stop_dt 	  = case_stop_dt
	enc->list[cnt].case_dur           = case_dur
	enc->list[cnt].proc_abbr   	      = proc_abbr
 
;---ENCOUNTER
 	enc->list[cnt].encntr_id  	      = e.encntr_id
 	enc->list[cnt].fac_name	   	      = fac_name
	enc->list[cnt].fac_abbr    	      = fac_abbr
	enc->list[cnt].fac_unit    	      = fac_unit
	enc->list[cnt].fac_room			  = fac_room
 
;---PERIOPERATIVE
	enc->list[cnt].primary_surgeon_id = primary_surgeon_id
	enc->list[cnt].surgeon 	   	      = surgeon
	enc->list[cnt].crna				  = crna
	enc->list[cnt].circ     		  = circ
 
with nocounter
 
 
;============================================================================
; SELECT ENCOUNTER ALIAS: FIN
;============================================================================
select into "NL:"
	 fin  = decode (ea.seq,  cnvtalias(ea.alias, ea.alias_pool_cd), '')
 
from
 	(DUMMYT        	dt with seq = value(size(enc->LIST,5)))
 	,ENCOUNTER	   	e
 	,ENCNTR_ALIAS	ea 	;fin
 
plan dt
 
join e
	where e.encntr_id = enc->list[dt.seq].encntr_id
		and e.active_ind = 1
		and e.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 0")
 
join ea
	where ea.encntr_id = outerjoin(e.encntr_id)
		and ea.encntr_alias_type_cd = outerjoin(FIN_VAR)   ;1077
		and ea.end_effective_dt_tm = outerjoin(cnvtdatetime("31-DEC-2100 0"))
 
order dt.seq ,ea.encntr_id
 
head dt.seq
	 enc->list[dt.seq].fin  = fin
 
with nocounter
 
;============================
; REPORT OUTPUT
;============================
select into value ($OUTDEV)
 
	 date				= format(enc->list[dt.seq].case_start_dt, "mm/dd/yyyy;;d")
 	,room				= enc->list[dt.seq].fac_unit
	,acct				= enc->list[dt.seq].fin
	,physician			= enc->list[dt.seq].surgeon
	,procedure			= enc->list[dt.seq].proc_abbr
	,p_sta			    = format(enc->list[dt.seq].pat_start_dt, "hh:mm;;d")
	,p_stp			    = format(enc->list[dt.seq].pat_stop_dt, "hh:mm;;d")
	,c_sta			    = format(enc->list[dt.seq].case_start_dt, "hh:mm;;d")
	,c_stp			    = format(enc->list[dt.seq].case_stop_dt, "hh:mm;;d")
	,turn				= 0
	,crna				= enc->list[dt.seq].crna
	,circ				= enc->list[dt.seq].circ
 
;	,encntr_id   	    = enc->list[dt.seq].encntr_id
;	,fac_name    	    = enc->list[dt.seq].fac_name
;	,fac_abbr    	    = enc->list[dt.seq].fac_abbr
;	,fac_unit    	    = enc->list[dt.seq].fac_unit
;	,fac_room			= enc->list[dt.seq].fac_room
;	,fin	      	    = enc->list[dt.seq].fin
;
;
;	,surg_case_id	    = enc->list[dt.seq].surg_case_id
;	,surg_case_proc_id  = enc->list[dt.seq].surg_case_proc_id
;	,surg_case_nbr		= enc->list[dt.seq].surg_case_nbr
;	,pat_start_dt	    = format(enc->list[dt.seq].pat_start_dt, "mm/dd/yyyy hh:mm;;d")
;	,pat_stop_dt	    = format(enc->list[dt.seq].pat_stop_dt, "mm/dd/yyyy hh:mm;;d")
;	,case_start_dt	    = format(enc->list[dt.seq].case_start_dt, "mm/dd/yyyy hh:mm;;d")
;	,case_stop_dt	    = format(enc->list[dt.seq].case_stop_dt, "mm/dd/yyyy hh:mm;;d")
;	,case_dur     	    = enc->list[dt.seq].case_dur
;	,proc_abbr   	    = enc->list[dt.seq].proc_abbr
;
;
;	,primary_surgeon_id = enc->list[dt.seq].primary_surgeon_id
;	,surgeon			= enc->list[dt.seq].surgeon
;	,prompt_startdate   = enc->prompt_startdate
;	,prompt_enddate     = enc->prompt_enddate
;
;
;	,person_id     	    = enc->list[dt.seq].person_id
	,pat_name    	    = enc->list[dt.seq].pat_name
 
from
	(dummyt dt with seq = value(size(enc->list,5)))
 
;order by fac_unit, pat_name, proc_dt, surgeon
order by date, room, physician, p_sta, c_sta, procedure
 
with nocounter, format, check, separator = " ", nullreport
 
#exitscript
end
go
 
 
