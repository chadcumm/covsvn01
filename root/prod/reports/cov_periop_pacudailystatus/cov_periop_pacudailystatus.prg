/**************************************************************************************
 *  Covenant Health Information Technology
 *  Knoxville, Tennessee
 **************************************************************************************
 
    Author:            Dan Herren
    Date Written:      February 2018
    Soluation:         Infection Control / SurgiNet
    Source file name:  cov_periop_PACUDailyStatus.prg
    Object name:       cov_periop_PACUDailyStatus
 	CR #:			   517
 
    Program purpose:   Creates extract for Strada upload.
 
    				   File goes to the AStream folder -
    				   \\chstn_astream_prod.cernerasp.com\middle_fs\to_client_site\
						p0665\ClinicalNursing\InfectionControl\PAExports
 
    				   Filename: PacuDailyStatus.txt
 
    Executing from:    CCL.
 
    Special Notes:
 
 ***************************************************************************************
 *  GENERATED MODIFICATION CONTROL LOG
 ***************************************************************************************
 *
 *  Mod Date      	Developer       Comment
 *  ---	-------   	---------------	--------------------------------------------------
 *  001	12/2018		Dan Herren      Fix periop reference nbr.
 *  002 02/2019		Dan Herren	   	Assign account code to PW boulevard surg center.
 *	003	09/2020		Dan Herren	   	CR 8539; Omit L&D cases.
 *  004 06/2022		Dan Herren		Surgical Case Number extended extra 2 spaces.
 *
 ***************************************************************************************/
 
drop program cov_periop_PACUDailyStatus go
create program cov_periop_PACUDailyStatus
 
prompt
	"Output to File/Printer/MINE" = "MINE"             ;* Enter or select the printer or file name to send this report to.
;	, "CHECK-IN DATE RANGE" = "24-MAY-2018 00:00:00"
;	, "" = "06-JUN-2018 23:59:00"
 
with OUTDEV  ;, STARTDATE_PMPT, ENDDATE_PMPT
;with OUTDEV, FACILITY_PMPT, STARTDATE, ENDDATE
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
;free record enc
record enc
(
1 prompt_startdate       = f8
1 prompt_enddate         = f8
1 list [*]
;---PERSON
	2 person_id          = f8   ;pid
	2 pat_name		     = c35  ;pat_name
	2 cmrn		         = vc   ;community mrn
	2 mrn		         = vc   ;facility mrn
 
 
;---ENCOUNTER
	2 encntr_id          = f8   ;eid
	2 fac_abbr 	         = c10  ;facility abbr
	2 fac_unit           = c25  ;facility unit
	2 fin		         = vc   ;encounter fin
 
;---CASE
	2 surg_case_id       = f8   ;surgical case id
	2 surg_case_nbr		 = c18	;surgical case number ;004
	2 case_start_dt		 = f8   ;case start date
	2 case_stop_dt		 = f8	;case end date
 
;---PERIOPERATIVE
	2 fac_comp			 = c10 	;facility company number
	2 fac_dept			 = c10 	;facility department number
	2 pacu_min			 = f8	;pacu minutes
	2 pacu_in_min		 = f8	;pacu in time
	2 pacu_out_min		 = f8   ;pacu out (discharge) time
)
 
record output (
	1 temp = vc
	1 locator = vc
	1 filename = vc
	1 directory = vc
)
 
set output->directory = "/cerner/w_custom/p0665_cust/to_client_site/ClinicalNursing/Surgery/PAExports/"
set output->filename   = "pacudailystatus"
;;set output->filename   = "djhtestpacufile"
 
;**************************************************************
; DVDev DECLARED VARIABLES
;**************************************************************
declare FIN_VAR           	= f8 with constant(uar_get_code_by("MEANING",319,"FIN NBR")),protect
declare CMRN_VAR          	= f8 with constant(uar_get_code_by("MEANING",4,"CMRN")),protect
declare MRN_VAR           	= f8 with constant(uar_get_code_by("MEANING",4,"MRN")),protect
;
declare FSRLD_VAR 			= f8 with constant(uar_get_code_by("DISPLAY_KEY",221,"FSRLABORANDDELIVERY")),protect
declare LCMLD_VAR 			= f8 with constant(uar_get_code_by("DISPLAY_KEY",221,"LCMCLABORANDDELIVERY")),protect
declare MHHLD_VAR 			= f8 with constant(uar_get_code_by("DISPLAY_KEY",221,"MHHSLABORANDDELIVERY")),protect
declare MMCLD_VAR 			= f8 with constant(uar_get_code_by("DISPLAY_KEY",221,"MMCLABORANDDELIVERY")),protect
declare PWMLD_VAR 			= f8 with constant(uar_get_code_by("DISPLAY_KEY",221,"PWMCLABORANDDELIVERY")),protect
;
declare CASE_CANCELED_VAR 	= f8 with constant(uar_get_code_by("DISPLAY_KEY",10030,"CASECANCELLED")),protect
declare PACU_IN_VAR       	= f8 with constant(uar_get_code_by("DISPLAY_KEY",72,"SNPACUICTMINPACUI")),protect   ;3017191
declare PACU_DISCHRG_VAR  	= f8 with constant(uar_get_code_by("DISPLAY_KEY",72,"SNPACUICTMDISCHARGEFROMPACUI")),protect ;3017190
declare EVENT_CHILD_VAR   	= f8 with constant(uar_get_code_by("MEANING",24,"CHILD")),protect
declare FACCOMP_VAR       	= vc with noconstant(fillstring(2," "))
declare FACDEPT_VAR       	= vc with noconstant(fillstring(6," "))
declare PACUIN_DT_VAR     	= dq8
declare PACUOUT_DT_VAR    	= dq8
;
declare initcap()		  	= c100
;
;Runs for the previous 14 days.
declare START_DATE = f8
declare END_DATE   = f8
declare OUTPUTFILE = c1000 with noconstant("")
 
set START_DATE = cnvtlookbehind("15,D")
set START_DATE = datetimefind(START_DATE,"D","B","B")
set START_DATE = cnvtlookahead("1,D",START_DATE)
set END_DATE   = cnvtlookahead("14,D",START_DATE)
set END_DATE   = cnvtlookbehind("1,SEC", END_DATE)
 
 
;FOR MANUAL EXTRACT RUN
;;set START_DATE = CNVTDATETIME("10-MAY-2021 00:00:00")  ;$STARTDATE_PMPT  30-OCT-2018
;;set END_DATE   = CNVTDATETIME("31-MAY-2021 23:23:59")  ;$ENDDATE_PMPT
 
;**************************************************************
; DVDev START CODE
;**************************************************************
set enc->prompt_startdate = START_DATE
set enc->prompt_enddate   = END_DATE
 
 
;================================================
; SELECT SURGICAL ENCOUNTERS BY PROCEDURE
;================================================
select distinct into "NL:"
;select distinct into value ($outdev)
 
;---PERSON
	 person_id      = e.person_id
	,pat_name       = initcap(p.name_full_formatted)
 
;---ENCOUNTER
	,encntr_id      = e.encntr_id
	,fac_abbr       = uar_get_code_display(e.loc_facility_cd)
	,fac_unit       = uar_get_code_display(e.loc_nurse_unit_cd)
 
;---CASE
	,surg_case_id   = sc.surg_case_id
	,surg_case_nbr 	= sc.surg_case_nbr_formatted
	,case_start_dt  = sc.surg_start_dt_tm
	,case_stop_dt   = sc.surg_stop_dt_tm
 
from
	 SURGICAL_CASE		 	sc
	,SURG_CASE_PROCEDURE	scp
	,PERIOPERATIVE_DOCUMENT pd
	,ENCOUNTER 				e
	,PERSON              	p
 
plan sc
	where sc.sched_start_dt_tm between cnvtdatetime(START_DATE) and cnvtdatetime(END_DATE)
		and sc.active_ind = 1
;		and nullind(sc.surg_stop_dt_tm) = 0 ;not null
 		and sc.curr_case_status_cd != CASE_CANCELED_VAR  ;667861.00
		and sc.surg_case_nbr_locn_cd not in (FSRLD_VAR, LCMLD_VAR, MHHLD_VAR, MMCLD_VAR, PWMLD_VAR) ;003
;;				32216067, 2552926545, 2557462433, 2554024337, 2557228471
 
join scp
	where scp.surg_case_id = outerjoin(sc.surg_case_id )
		and scp.active_ind = outerjoin(1)
;		and scp.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
 
join pd
	where pd.surg_case_id = scp.surg_case_id
 		and pd.doc_term_dt_tm = null
 
join e
	where e.encntr_id = sc.encntr_id
		and	e.loc_facility_cd in (
			2553765291.00,  2552503657.00, 2552503635.00, 21250403.00, 2552503653.00,
			2552503639.00, 2552503613.00, 2552503645.00, 2552503649.00
			)
		and e.active_ind = 1
		and e.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
 
join p
	where p.person_id = e.person_id
		and p.person_id = sc.person_id
		and p.active_ind = 1
		and p.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
 
order by person_id, encntr_id, surg_case_id
 
head report
	cnt = 0
 
;head e.encntr_id
detail
	cnt = cnt + 1
	stat = alterlist(enc->list,cnt)
 
;---PERSON
	enc->list[cnt].person_id 	  = p.person_id
	enc->list[cnt].pat_name    	  = pat_name
 
;---ENCOUNTER
 	enc->list[cnt].encntr_id  	  = e.encntr_id
	enc->list[cnt].fac_abbr    	  = fac_abbr
	enc->list[cnt].fac_unit    	  = fac_unit
 
;---CASE
	enc->list[cnt].surg_case_id   = surg_case_id
	enc->list[cnt].surg_case_nbr  = surg_case_nbr
	enc->list[cnt].case_start_dt  = case_start_dt
	enc->list[cnt].case_stop_dt   = case_stop_dt
 
with nocounter
 
 
;============================================================================
; SELECT PERSON & ENCOUNTER ALIAS'S: CMRN, MRN, FIN, SSN
;============================================================================
select into "NL:"
;	 fin  = decode (ea.seq,  cnvtalias(ea.alias, ea.alias_pool_cd), '')
; 	,mrn  = decode (ea2.seq, cnvtalias(ea2.alias, ea2.alias_pool_cd), '')
; 	,cmrn = decode (pa.seq,  cnvtalias(pa.alias, pa.alias_pool_cd), '')
 
from
 	(DUMMYT        	dt with seq = value(size(enc->LIST,5)))
 	,ENCOUNTER	   	e
 	,ENCNTR_ALIAS	ea 	;fin,
 	,ENCNTR_ALIAS   ea2 ;mrn
 	,PERSON_ALIAS   pa	;cmrn
 
plan dt
 
join e
	where e.encntr_id = enc->list[dt.seq].encntr_id
		and e.active_ind = 1
		and e.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
 
join ea
	where ea.encntr_id = outerjoin(e.encntr_id)
		and ea.encntr_alias_type_cd = outerjoin(FIN_VAR)   ;1077
		and ea.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime))
 
join ea2
	where ea2.encntr_id = outerjoin(e.encntr_id)
		and ea2.encntr_alias_type_cd = outerjoin(MRN_VAR)   ;1079
		and ea2.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime))
 
join pa
	where pa.person_id = outerjoin(e.person_id)
		and pa.person_alias_type_cd = outerjoin(CMRN_VAR)    ;2
		and pa.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime))
 
detail
	enc->list[dt.seq].fin  = ea.alias                                ;fin
	enc->list[dt.seq].mrn  = cnvtalias(ea2.alias, ea2.alias_pool_cd) ;mrn
	enc->list[dt.seq].cmrn = pa.alias                                ;cmrn
 
with nocounter
 
;go to exitscript
 
;============================================================================
; SELECT PERIOPERATIVE VALUES
;============================================================================
select into "NL:"
;select into value ($OUTDEV)
	 fac_code      = uar_get_code_display(en.loc_facility_cd)
	,fac_unit      = uar_get_code_display(en.loc_nurse_unit_cd)
    ,result_dt     = cd.result_dt_tm
    ,updt_cnt      = cd.updt_cnt
    ,updt_dttm     = cd.updt_dt_tm
    ,surg_case_id  = sc.surg_case_id
    ,event_cd      = ce.event_cd
 
from
	(DUMMYT 	            dt with seq = value (size (enc->list,5)))
    ,CLINICAL_EVENT         ce
	,SURGICAL_CASE          sc
    ,ENCOUNTER              en
    ,PERIOPERATIVE_DOCUMENT pd
    ,CE_DATE_RESULT         cd
 
plan dt
 
join sc
	where sc.surg_case_id = enc->list[dt.seq].surg_case_id
		and sc.active_ind = 1
 
join pd
	where pd.surg_case_id = sc.surg_case_id
;		and pd.periop_doc_id = cnvtreal(trim(substring(1,9,ce.reference_nbr),3))
 		and pd.doc_term_dt_tm = null
 
join ce
	where ce.encntr_id = enc->list[dt.seq].encntr_id
	   	and ce.event_cd in (PACU_IN_VAR, PACU_DISCHRG_VAR)  ;3017191, 3017190
		and ce.reference_nbr = "*SN*"
		and ce.event_reltn_cd = EVENT_CHILD_VAR ;132
		and ce.view_level = 1
		and ce.valid_until_dt_tm > cnvtdatetime(curdate, curtime3)
		AND OPERATOR(ce.reference_nbr,'LIKE',CONCAT(TRIM(CNVTSTRING(pd.periop_doc_id,3)),'SN%')) ;001
 
join en
	where en.encntr_id = sc.encntr_id
       	and en.active_ind = 1
		and en.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
 
join cd
	where cd.event_id = ce.event_id
 
order by dt.seq, surg_case_id, event_cd, updt_dttm desc
;order by dt.seq ,fac_code, surg_case_id, event_cd, updt_cnt, updt_dttm
 
head dt.seq
	case (fac_code)
		of "FSR"  	  : FACCOMP_VAR = "20", FACDEPT_VAR = "652000" ;21250403
		of "PW"   	  : FACCOMP_VAR = "22", FACDEPT_VAR = "652000" ;2552503645
		of "MMC"  	  : FACCOMP_VAR = "24", FACDEPT_VAR = "652000" ;2552503613
		of "MHHS" 	  : FACCOMP_VAR = "25", FACDEPT_VAR = "652000" ;2552503639
		of "LCMC" 	  : FACCOMP_VAR = "26", FACDEPT_VAR = "650000" ;2552503653
		of "RMC"  	  : FACCOMP_VAR = "27", FACDEPT_VAR = "650000" ;2552503649
		of "FLMC" 	  : FACCOMP_VAR = "28", FACDEPT_VAR = "650000" ;2552503635
		else            FACCOMP_VAR = "0" , FACDEPT_VAR = "0"
	endcase
 
 	PACUIN_DT_VAR  = null
 	PACUOUT_DT_VAR = null
 
head surg_case_id
	null
 
head event_cd
	null
 
head en.encntr_id
;;detail
;;BEGIN ;002
 	if (fac_unit = "PW TEMP BSP*")
		enc->list[dt.seq].fac_dept = "459300" ;BOULEVARD SURGERY CENTER
	else
		enc->list[dt.seq].fac_dept = FACDEPT_VAR
 	endif
;;END ;002
 
	if (ce.event_cd = PACU_IN_VAR)       ;3017191
	    PACUIN_DT_VAR = cd.result_dt_tm
	else
		PACUOUT_DT_VAR = cd.result_dt_tm  ;3017190
	endif
 
;;	if (ce.event_cd = PACU_IN_VAR)       ;3017191
;;	    PACUIN_DT_VAR = cd.result_dt_tm
;;	endif
;;
;;	if (ce.event_cd = PACU_DISCHRG_VAR)  ;3017190
;;		PACUOUT_DT_VAR = cd.result_dt_tm
;;	endif
 
	enc->list[dt.seq].fac_comp      = FACCOMP_VAR
;	enc->list[dt.seq].fac_dept      = FACDEPT_VAR   ;002
	enc->list[dt.seq].pacu_in_min   = PACUIN_DT_VAR
	enc->list[dt.seq].pacu_out_min  = PACUOUT_DT_VAR
	enc->list[dt.seq].pacu_min      = datetimediff(PACUOUT_DT_VAR, PACUIN_DT_VAR, 4)
 
with nocounter
 
;call ECHORECORD(enc)
;go to exitscript
;============================
; REPORT OUTPUT
;============================
	declare disp_line = c1000 with noconstant(fillstring(1000, ' ')), protect
 
	; static sized headers
	declare sep   = c1  with noconstant(fillstring(1, '|' )), protect  ;pipe
	declare hdr1  = c35 with noconstant(fillstring(35, ' ')), protect  ;pat_name
	declare hdr2  = c15 with noconstant(fillstring(15, ' ')), protect  ;fin
	declare hdr3  = c10 with noconstant(fillstring(10, ' ')), protect  ;fac_abbr
	declare hdr4  = c25 with noconstant(fillstring(25, ' ')), protect  ;fac_unit
	declare hdr5  = c16 with noconstant(fillstring(16, ' ')), protect  ;case_start_dt
	declare hdr6  = c15 with noconstant(fillstring(18, ' ')), protect  ;surg_case_nbr ;004
	declare hdr7  = c10 with noconstant(fillstring(10, ' ')), protect  ;fac_comp
	declare hdr8  = c10 with noconstant(fillstring(10, ' ')), protect  ;fac_dept
	declare hdr9  = c10 with noconstant(fillstring(10, ' ')), protect  ;pacu_min
	declare hdr10 = c16 with noconstant(fillstring(16, ' ')), protect  ;pacu_in_min
	declare hdr11 = c16 with noconstant(fillstring(16, ' ')), protect  ;pacu_out_min
	declare hdr12 = c16 with noconstant(fillstring(16, ' ')), protect  ;prompt_startdate
	declare hdr13 = c16 with noconstant(fillstring(16, ' ')), protect  ;prompt_enddate
;
;	declare hdr14 = c16 with noconstant(fillstring(16, ' ')), protect  ;case_stop_dt
;	declare hdr15 = c10 with noconstant(fillstring(10, ' ')), protect  ;cmrn
;	declare hdr16 = c15 with noconstant(fillstring(15, ' ')), protect  ;mrn
 
 
	; static sized columns
;	declare sep   = c1  with noconstant(fillstring(1, '|' )), protect  ;pipe
	declare col1  = c35 with noconstant(fillstring(35, ' ')), protect  ;pat_name
	declare col2  = c15 with noconstant(fillstring(15, ' ')), protect  ;fin
	declare col3  = c10 with noconstant(fillstring(10, ' ')), protect  ;fac_abbr
	declare col4  = c25 with noconstant(fillstring(25, ' ')), protect  ;fac_unit
	declare col5  = c16 with noconstant(fillstring(16, ' ')), protect  ;case_start_dt
	declare col6  = c15 with noconstant(fillstring(18, ' ')), protect  ;surg_case_nbr  ;004
	declare col7  = c10 with noconstant(fillstring(10, ' ')), protect  ;fac_comp
	declare col8  = c10 with noconstant(fillstring(10, ' ')), protect  ;fac_dept
	declare col9  = c10 with noconstant(fillstring(10, ' ')), protect  ;pacu_min
	declare col10 = c16 with noconstant(fillstring(16, ' ')), protect  ;pacu_in_min
	declare col11 = c16 with noconstant(fillstring(16, ' ')), protect  ;pacu_out_min
	declare col12 = c16 with noconstant(fillstring(16, ' ')), protect  ;prompt_startdate
	declare col13 = c16 with noconstant(fillstring(16, ' ')), protect  ;prompt_enddate
;
;	declare col14 = c16 with noconstant(fillstring(16, ' ')), protect  ;case_stop_dt
;	declare col15 = c10 with noconstant(fillstring(10, ' ')), protect  ;cmrn
;	declare col16 = c15 with noconstant(fillstring(15, ' ')), protect  ;mrn
 
	record frec (
	    1 file_desc = i4
	    1 file_offset = i4
	    1 file_dir = i4
	    1 file_name = vc
	    1 file_buf = vc
	)
 
	set frec->file_name = concat(trim(output->filename,3), ".txt")
	set frec->file_buf = "w"
	set stat = cclio("OPEN", frec)
 
 	select into "NL:"
; 	select into value ($OUTDEV)
;	;----PERSON
		 pat_name    	    = trim(enc->list[dt.seq].pat_name,3)
		,cmrn        	    = trim(enc->list[dt.seq].cmrn,3)
		,mrn         	    = trim(enc->list[dt.seq].mrn,3)
		,fac_abbr    	    = trim(enc->list[dt.seq].fac_abbr,3)
		,fac_unit    	    = trim(enc->list[dt.seq].fac_unit,3)
		,fin	      	    = trim(enc->list[dt.seq].fin,3)
 
	;----CASE
		,surg_case_nbr		= trim(enc->list[dt.seq].surg_case_nbr,3)
		,case_start_dt	    = format(enc->list[dt.seq].case_start_dt, "mm/dd/yyyy hh:mm;;d")
		,case_stop_dt	    = format(enc->list[dt.seq].case_stop_dt, "mm/dd/yyyy hh:mm;;d")
 
	;----PERIOPERATIVE
		,fac_comp		    = trim(enc->list[dt.seq].fac_comp,3)
		,fac_dept		    = trim(enc->list[dt.seq].fac_dept,3)
		,pacu_min		    = enc->list[dt.seq].pacu_min
		,pacu_in_min		= format (enc->list[dt.seq].pacu_in_min, "mm/dd/yyyy hh:mm;;d")
		,pacu_out_min		= format (enc->list[dt.seq].pacu_out_min, "mm/dd/yyyy hh:mm;;d")
		,prompt_startdate   = format(enc->prompt_startdate, "mm/dd/yyyy hh:mm;;d")
		,prompt_enddate     = format(enc->prompt_enddate, "mm/dd/yyyy hh:mm;;d")
 
	from
	(dummyt dt with seq = value(size(enc->list,5)))
 
	;order by fac_unit, pat_name, proc_dt, admit_dt;, surgeon
	order by pat_name, surg_case_nbr
 
;with nocounter, format, check, separator = " ", memsort
;call ECHORECORD(enc)
;go to exitscript
	head report
    	hdr1  = "pat_name"
	    hdr2  = "fin"
	    hdr3  = "fac_abbr"
	    hdr4  = "fac_unit"
	    hdr5  = "casestart_dt"
	    hdr6  = "surgcase_nbr"
	    hdr7  = "fac_comp"
	    hdr8  = "fac_dept"
	    hdr9  = "pacu_min"
	    hdr10 = "pacu_in_min"
	    hdr11 = "pacu_out_min"
	    hdr12 = "prompt_startdate"
	    hdr13 = "prompt_enddate"
;
;	    hdr14 = "casestop_dt"
;    	hdr15 = "cmrn"
;		hdr16 = "mrn"
 
		disp_line = concat(hdr1,sep,hdr2,sep,hdr3,sep,hdr4,sep,hdr5,sep,hdr6,sep,hdr7,sep,hdr8,sep,hdr9,sep,hdr10,
        	sep,hdr11,sep,hdr12,sep,hdr13,char(13),char(10))
		frec->file_buf = disp_line
		stat = cclio ("PUTS", frec)
 
	head dt.seq
		output->temp = ""
 
	detail
		col1  = pat_name
		col2  = fin
		col3  = fac_abbr
		col4  = fac_unit
		col5  = case_start_dt
		col6  = surg_case_nbr
		col7  = fac_comp
		col8  = fac_dept
		col9  = cnvtstring(pacu_min)
		col10 = pacu_in_min
		col11 = pacu_out_min
		col12 = prompt_startdate
		col13 = prompt_enddate
;
;		col14 = case_stop_dt
;		col15 = trim(cmrn,3)
;		col16 = trim(mrn,3)
 
        disp_line = concat(col1,sep,col2,sep,col3,sep,col4,sep,col5,sep,col6,sep,col7,sep,col8,sep,col9,sep,col10,
        	sep,col11,sep,col12,sep,col13,sep,char(13),char(10))
		frec->file_buf = disp_line
		stat = cclio ("PUTS", frec)
 
	foot report
		frec->file_buf = "END"
		stat = cclio ("PUTS", frec)
		stat = cclio ("CLOSE",frec)
 
with nocounter, format, check, separator = " ", memsort
	;with nocounter, format, separator = " ", check, nullreport
 
set  statx = 0
set  output->temp = concat("mv $CCLUSERDIR/", output->filename,".txt ",output->directory,output->filename,".txt")
call echo (output->temp)
;call dcl( output->temp ,size(output->temp  ), statx)  ;transfers file to AStream.  Have an ops job do this now.
set  output->temp = ""
 
select into value($outdev)
	Message =  "File successfully created to Astream folders."
with format, separator = " ", check;, noheader
 
#exitscript
end
go
 
 
 
