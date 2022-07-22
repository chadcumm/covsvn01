 
/*****************************************************************************
 *  Covenant Health Information Technology
 *  Knoxville, Tennessee
 *****************************************************************************
 
    Author:            Dan Herren
 
    Program purpose:   Used to research data.
 
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
 
drop program djherren_NHSNPACU go
create program djherren_NHSNPACU
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "FACILITY" = VALUE(0.0)
	, "CHECK-IN DATE RANGE" = "SYSDATE"
	, "" = "SYSDATE"
 
with OUTDEV, FACILITY_PMPT, STARTDATE_PMPT, ENDDATE_PMPT
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
	2 pat_name		     = c50  ;pat_name
	2 sex	             = vc   ;male, female etc.
	2 birth_dt	         = f8   ;birth date
	2 age		         = vc   ;age
	2 cmrn		         = vc   ;community mrn
	2 mrn		         = vc   ;facility mrn
 
;---HEIGHT
	2 ht_clin_event_id   = f8	;height clinical event id
	2 height             = vc   ;patient height
 
;---WEIGHT
	2 wt_clin_event_id   = f8	;weight clinical event id
	2 weight             = c6   ;patient weight
	2 presurgwt			 = vc	;patient weight pre surgery
	2 postsurgwt		 = vc	;patient weight post surgery
	2 wt_cnt			 = i4
	2 wt_qual[*]
		3	weight			= c6
		3	perfdttm		= vc
		3	eventenddttm	= vc
		3	eventstartdttm	= vc
		3	case_dt_tm		= vc
		3	eventid			= f8
		3	perfdatetm		= f8
 
;---ENCOUNTER
	2 encntr_id          = f8 ;eid
	2 fac_name           = vc ;facility name
	2 fac_abbr 	         = vc ;facility abbr
	2 fac_unit           = vc ;facility unit
	2 fin		         = vc ;encounter fin
	2 admit_dt           = f8 ;admit date
	2 disch_dt           = f8 ;discharge date
	2 outpatient         = vc ;outpatient
	2 emergency          = vc ;emergency
 
;---CASE
	2 casecnt			     = i4
	2 casequal[*]
		3 surg_case_id		 = f8	 ;surg_case_id
		3 surg_case_proc_id  = f8	 ;surg case procedure id
		3 case_start_dt		 = f8    ;case start date
		3 case_stop_dt		 = f8	 ;case end date
		3 case_dur           = i4    ;case duration
		3 proc_primary       = i4    ;procedure primary indicatior
		3 proc_abbr          = c50   ;procedure abbrievation
		3 surg_case_nbr		 = c16	 ;surgical case number
		3 proc_dur_min       = i4    ;procedure duration
		3 proc_dt   	     = f8    ;procedure start date
		3 asa_class          = c12   ;asa classification
		3 asa_class_anes     = c12   ;asa classification from anesthesia
		3 wound_class        = c12   ;wound class
		3 gen_anesth         = c10   ;general anesthesia
 		3 asablob			 = c2
 		
	;---PERIOPERATIVE
		3 periop_doc_id		 = f8	 ;periop document id
		3 parent_event_id    = f8 	 ;periop parent event id
		3 primary_surgeon_id = f8	 ;primary surgeon id
		3 clin_event_id		 = f8	 ;clinical event id
		3 event_id			 = f8    ;event id
		3 perform_dt_tm	     = dq8	 ;perform_dt_tm
		3 rec_ver_dt_tm      = dq8   ;rec_ver_dt_tm
		3 trauma             = vc    ;trauma
		3 closure_tech       = vc    ;closure technique
		3 endoscope          = vc    ;endoscope
		3 surgeon            = c50   ;surgeon
)
 
record output (
	1 filename = vc
	1 directory = vc
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
declare CLMC_DOC_TYPE_VAR = f8 with constant(uar_get_code_by("DISPLAY_KEY",14258,"CLMCINTRAOPRECORDOR")),protect ;???
declare CMC_DOC_TYPE_VAR  = f8 with constant(uar_get_code_by("DISPLAY_KEY",14258,"CMCINTRAOPRECORDOR")),protect	 ;???
declare FLMC_DOC_TYPE_VAR = f8 with constant(uar_get_code_by("DISPLAY_KEY",14258,"FLMCINTRAOPRECORDOR")),protect   ;2557461883
declare FSR_DOC_TYPE_VAR  = f8 with constant(uar_get_code_by("DISPLAY_KEY",14258,"FSRINTRAOPRECORDOR")),protect    ;  25443723
declare LCMC_DOC_TYPE_VAR = f8 with constant(uar_get_code_by("DISPLAY_KEY",14258,"LCMCINTRAOPRECORDOR")),protect   ;2557462521
declare MHHS_DOC_TYPE_VAR = f8 with constant(uar_get_code_by("DISPLAY_KEY",14258,"MHHSINTRAOPRECORDOR")),protect   ;2557462301
declare MMC_DOC_TYPE_VAR  = f8 with constant(uar_get_code_by("DISPLAY_KEY",14258,"MMCINTRAOPRECORDOR")),protect    ;2555058965
declare PWMC_DOC_TYPE_VAR = f8 with constant(uar_get_code_by("DISPLAY_KEY",14258,"PWMCINTRAOPRECORDOR")),protect   ;2557462145
declare RMC_DOC_TYPE_VAR  = f8 with constant(uar_get_code_by("DISPLAY_KEY",14258,"RMCINTRAOPRECORDOR")),protect    ;2555059037
;
declare CLMC_PACU_OR_VAR  = f8 with constant(uar_get_code_by("DISPLAY_KEY",14258,"CLMCPACURECORDOR")),protect   ;???
declare CMC_PACU_OR_VAR   = f8 with constant(uar_get_code_by("DISPLAY_KEY",14258,"CMCPACURECORDOR")),protect	;???
declare FLMC_PACU_OR_VAR  = f8 with constant(uar_get_code_by("DISPLAY_KEY",14258,"FLMCPACURECORDOR")),protect   ;2557461883
declare FSR_PACU_OR_VAR   = f8 with constant(uar_get_code_by("DISPLAY_KEY",14258,"FSRPACURECORDOR")),protect    ;  25443723
declare LCMC_PACU_OR_VAR  = f8 with constant(uar_get_code_by("DISPLAY_KEY",14258,"LCMCPACURECORDOR")),protect   ;2557462521
declare MHHS_PACU_OR_VAR  = f8 with constant(uar_get_code_by("DISPLAY_KEY",14258,"MHHSPACURECORDOR")),protect   ;2557462301
declare MMC_PACU_OR_VAR   = f8 with constant(uar_get_code_by("DISPLAY_KEY",14258,"MMCPACURECORDOR")),protect    ;2555058965
declare PWMC_PACU_OR_VAR  = f8 with constant(uar_get_code_by("DISPLAY_KEY",14258,"PWMCPACURECORDOR")),protect   ;2557462145
declare RMC_PACU_OR_VAR   = f8 with constant(uar_get_code_by("DISPLAY_KEY",14258,"RMCPACURECORDOR")),protect    ;2555059037
;

DECLARE PREANESTNT_VAR = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY', 72, 'PREANESTHESIANOTE')), PROTECT
DECLARE asablob = vc with NOCONSTANT(FILLSTRING(2,' ')), PROTECT
DECLARE compcd	=	f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',120,'OCFCOMPRESSION')), PROTECT
;
declare HEIGHT_VAR   	  = f8 with constant(uar_get_code_by("DISPLAY_KEY",72,"HEIGHTLENGTHMEASURED")),protect
declare WEIGHT_VAR   	  = f8 with constant(uar_get_code_by("DISPLAY_KEY",72,"WEIGHTDOSING")),protect
declare AUTHVER_VAR 	  =	f8 with CONSTANT(UAR_GET_CODE_BY("DISPLAYKEY", 8, "AUTHVERIFIED")), protect
declare MODIFIED_VAR	  =	f8 with CONSTANT(UAR_GET_CODE_BY("MEANING", 8, "MODIFIED")), protect
declare ALTERED_VAR	      =	f8 with CONSTANT(UAR_GET_CODE_BY("MEANING", 8, "ALTERED")), protect
;
declare ANES_ATTRCASE_VAR = f8 with constant(uar_get_code_by("MEANING",4001977,"ASACLASS")),protect
declare ANESTH_TYPE_VAR	  = f8 with constant(uar_get_code_by("DISPLAY_KEY",10050,"GENERAL")),protect
declare OUTPATIENT_VAR	  = f8 with constant(uar_get_code_by("DISPLAY_KEY",71,"OUTPATIENT")),protect
declare EMERGENCY_VAR	  = f8 with constant(uar_get_code_by("DISPLAY_KEY",72,"SNICEMERGENCYPROCEDURE")),protect
declare TRAUMA_VAR   	  = f8 with constant(uar_get_code_by("DISPLAY_KEY",72,"SNICTRAUMAPROCEDURE")),protect
declare ENDOSCOPE_VAR	  = f8 with constant(uar_get_code_by("DISPLAY_KEY",72,"SNICLAPAROSCOPEPROCEDURE")),protect ;2550918925
declare CLOSURE_VAR		  = f8 with constant(uar_get_code_by("DISPLAY_KEY",72,"SNDPCLOSURETECHNIQUE")),protect
;
declare WOUND_CLEAN_VAR	  = f8 with constant(uar_get_code_by("DISPLAY_KEY",10038,"1CLEAN")),protect
declare WOUND_CLNCONT_VAR = f8 with constant(uar_get_code_by("DISPLAY_KEY",10038,"2CLEANCONTAMINATED")),protect
declare WOUND_CONTAM_VAR  = f8 with constant(uar_get_code_by("DISPLAY_KEY",10038,"3CONTAMINATED")),protect
declare WOUND_DIRTY_VAR	  = f8 with constant(uar_get_code_by("DISPLAY_KEY",10038,"4DIRTYINFECTED")),protect
declare WOUND_NOINC_VAR	  = f8 with constant(uar_get_code_by("DISPLAY_KEY",10038,"NOINCISION")),protect
;
declare FIN_VAR           = f8 with constant(uar_get_code_by("MEANING",319,"FIN NBR")),protect
declare MRN_VAR           = f8 with constant(uar_get_code_by("MEANING",319,"MRN")),protect
declare CMRN_VAR          = f8 with constant(uar_get_code_by("MEANING",4,"CMRN")),protect
;
declare DIAG_DISCH_VAR    = f8 with constant(uar_get_code_by("MEANING",17,"DISCHARGE")),protect
declare ICD10CM_VAR		  = f8 with constant(uar_get_code_by_CKI("CKI.CODEVALUE!4101498946")),protect
declare FACILITY_VAR      = vc with noconstant(fillstring(1000," "))
declare OPR_FAC_VAR		  = vc with noconstant(fillstring(1000," "))
declare OPR_DISPO_VAR	  = vc with noconstant(fillstring(1000," "))
;
declare CASE_CANCELED_VAR = f8 with constant(uar_get_code_by("DISPLAY_KEY",10030,"CASECANCELLED")),protect
declare PACU_IN_VAR       = f8 with constant(uar_get_code_by("DISPLAY_KEY",72,"SNPACUICTMINPACUI")),protect   ;3017191
declare PACU_DISCHRG_VAR  = f8 with constant(uar_get_code_by("DISPLAY_KEY",72,"SNPACUICTMDISCHARGEFROMPACUI")),protect ;3017190
declare EVENT_CHILD_VAR   = f8 with constant(uar_get_code_by("MEANING",24,"CHILD")),protect
declare FACCOMP_VAR       = vc with noconstant(fillstring(2," "))
declare FACDEPT_VAR       = vc with noconstant(fillstring(6," "))
declare PACUIN_DT_VAR     = dq8
declare PACUOUT_DT_VAR    = dq8
declare idx1 			  = i4 with protect
declare idx2 			  = i4 with protect
;
declare initcap()		  = c100
;
;RUNS FOR THE PREVIOUS 14 DAYS.
declare START_DATE = f8
declare END_DATE   = f8
declare OUTPUTFILE = c1000 with noconstant("")
 
set START_DATE = cnvtlookbehind("15,D")
set START_DATE = datetimefind(START_DATE,"D","B","B")
set START_DATE = cnvtlookahead("1,D",START_DATE)
set END_DATE   = cnvtlookahead("14,D",START_DATE)
set END_DATE   = cnvtlookbehind("1,SEC", END_DATE)
 
;FOR MANUAL EXTRACT RUN
;set START_DATE = CNVTDATETIME("22-MAY-2018 00:00:00")  ;$STARTDATE_PMPT
;set END_DATE   = CNVTDATETIME("09-OCT-2018 23:23:59")  ;$ENDDATE_PMPT
 
;set output->directory = "/cerner/w_custom/p0665_cust/to_client_site/ClinicalNursing/Surgery/PAExports/"
set output->filename   = "surgprocdaily.txt"
;set output->filename   = "djhtestfile.txt"
 
;**************************************************************
; DVDev START CODE
;**************************************************************
set enc->prompt_startdate = START_DATE
set enc->prompt_enddate   = END_DATE
 
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
select into "NL:"
;select distinct into value ($outdev)
 
;---PERSON
	 person_id   	    = e.person_id
	,pat_name    	    = initcap(p.name_full_formatted)
	,birth_dt    	    = p.birth_dt_tm
	,age 		   	    = CNVTAGE(p.birth_dt_tm)
	,sex 		   	    = evaluate2(if(uar_get_code_display(p.sex_cd)="Male") "M"
								elseif(uar_get_code_display(p.sex_cd)="Female") "F"
								else "O" endif)
 
;---ENCOUNTER
	,encntr_id   	    = e.encntr_id
	,fac_name	   	    = uar_get_code_description(e.loc_facility_cd)
	,fac_abbr    	    = uar_get_code_display(e.loc_facility_cd)
	,fac_unit    	    = uar_get_code_display(e.loc_nurse_unit_cd)
	,admit_dt    	    = e.arrive_dt_tm
	,disch_dt    	    = e.disch_dt_tm
	,outpatient  	    = max(evaluate2(if(e.encntr_type_cd = OUTPATIENT_VAR) "Y" else "N" endif)) over(partition by e.encntr_id)
 
;---CASE
	,surg_case_id	    = scp.surg_case_id
 	,surg_case_proc_id  = scp.surg_case_proc_id
	,surg_case_nbr 		= sc.surg_case_nbr_formatted
	,case_start_dt	    = sc.surg_start_dt_tm
	,case_stop_dt	    = sc.surg_stop_dt_tm
	,case_dur     	    = datetimediff(sc.surg_stop_dt_tm, sc.surg_start_dt_tm,4)
	,proc_primary		= scp.primary_proc_ind
	,proc_abbr   	    = uar_get_code_display(scp.surg_proc_cd)
	,proc_dur_min	    = scp.proc_dur_min
	,proc_dt  		    = scp.proc_start_dt_tm
	,asa_class		    = uar_get_code_display(sc.asa_class_cd)
	,asa_class_anes     = cv.display
	,wound_class	    = sc.wound_class_cd
	,gen_anesth		    = evaluate2(if(scp.anesth_type_cd = ANESTH_TYPE_VAR) "Y" else "N" endif)
 
;---PERIOPERATIVE
	,primary_surgeon_id = scp.primary_surgeon_id
	,surgeon 	   	    = initcap(pl.name_full_formatted)
	,rec_ver_dt_tm      = pd.rec_ver_dt_tm
 
from
	 SURG_CASE_PROCEDURE	scp
	,SURGICAL_CASE		 	sc
	,SA_ANESTHESIA_RECORD   ar
	,SA_CASE_ATTRIBUTE	    ca
 	,CODE_VALUE				cv
	,PERIOPERATIVE_DOCUMENT pd
	,ENCOUNTER 				e
	,PERSON              	p
	,PRSNL               	pl
 
plan scp
	where scp.proc_start_dt_tm between cnvtdatetime(START_DATE) and cnvtdatetime(END_DATE)
		and scp.active_ind = 1
 
join sc
	where sc.surg_case_id = scp.surg_case_id
		and sc.active_ind = 1
		and nullind(sc.surg_stop_dt_tm) = 0 ;not null
 		and sc.curr_case_status_cd != CASE_CANCELED_VAR
 
join ar
	where ar.surgical_case_id = outerjoin(sc.surg_case_id)
		and ar.active_ind = outerjoin(1)
 
join ca
	where ca.sa_anesthesia_record_id = outerjoin(ar.sa_anesthesia_record_id)
		and ca.active_ind = outerjoin(1)
		and ca.case_attribute_type_cd = outerjoin(ANES_ATTRCASE_VAR) ;4056666
 
join cv
	where cv.code_value = outerjoin(cnvtreal(ca.case_attribute_value_txt))
		and cv.active_ind = outerjoin(1)
 
join pd
	where pd.surg_case_id = outerjoin(scp.surg_case_id)
 		and pd.doc_term_dt_tm = outerjoin(null)
 
join e
	where e.encntr_id = sc.encntr_id
;		and operator(e.loc_facility_cd, OPR_FAC_VAR, $FACILITY_PMPT)
		and	e.loc_facility_cd in (
			2553765291.00,  2552503657.00, 2552503635.00, 21250403.00, 2552503653.00,
			2552503639.00, 2552503613.00, 2552503645.00, 2552503649.00
			)
		and e.active_ind = 1
		and e.end_effective_dt_tm >= sysdate
 
join p
	where p.person_id = e.person_id
		and p.person_id = sc.person_id
		and p.active_ind = 1
		and p.end_effective_dt_tm >= sysdate
 
join pl
	where pl.person_id = scp.primary_surgeon_id
		and pl.physician_ind = 1
		and pl.end_effective_dt_tm >= sysdate
 
order by person_id, encntr_id, surg_case_id, proc_primary desc
 
head report
	cnt = 0
 
head e.encntr_id
cnt = cnt + 1
	stat = alterlist(enc->list,cnt)
 
;---PERSON
	enc->list[cnt].person_id 	      = p.person_id
	enc->list[cnt].pat_name    	      = pat_name
	enc->list[cnt].birth_dt    	      = birth_dt
	enc->list[cnt].age 		   	      = age
	enc->list[cnt].sex 		   	      = sex
 	enc->list[cnt].weight			  = "" ;'No Weight'
 
;---ENCOUNTER
 	enc->list[cnt].encntr_id  	      = e.encntr_id
 	enc->list[cnt].fac_name	   	      = fac_name
	enc->list[cnt].fac_abbr    	      = fac_abbr
	enc->list[cnt].fac_unit    	      = fac_unit
	enc->list[cnt].admit_dt    	      = admit_dt
	enc->list[cnt].disch_dt    	      = disch_dt
	enc->list[cnt].outpatient  	      = outpatient
	dcnt  = 0
 
;detail
head surg_case_proc_id
	dcnt = dcnt + 1
	if (mod(dcnt,10) = 1 or dcnt = 1)
 		stat = alterlist(enc->list[cnt].casequal, dcnt + 9)
 	endif
 
;---CASE
	enc->list[cnt].casequal[dcnt].surg_case_id       = surg_case_id
	enc->list[cnt].casequal[dcnt].surg_case_proc_id  = surg_case_proc_id
	enc->list[cnt].casequal[dcnt].surg_case_nbr	     = surg_case_nbr
	enc->list[cnt].casequal[dcnt].case_start_dt      = case_start_dt
	enc->list[cnt].casequal[dcnt].case_stop_dt 	     = case_stop_dt
	enc->list[cnt].casequal[dcnt].case_dur           = case_dur
	enc->list[cnt].casequal[dcnt].proc_dur_min	     = proc_dur_min
	enc->list[cnt].casequal[dcnt].proc_dt  	         = proc_dt
	enc->list[cnt].casequal[dcnt].proc_primary       = proc_primary
	enc->list[cnt].casequal[dcnt].proc_abbr   	     = proc_abbr
	enc->list[cnt].casequal[dcnt].asa_class	         = asa_class
	enc->list[cnt].casequal[dcnt].asa_class_anes     = asa_class_anes
	enc->list[cnt].casequal[dcnt].gen_anesth	     = gen_anesth
	enc->list[cnt].casequal[dcnt].surg_case_nbr      = surg_case_nbr
 
;---PERIOPERATIVE
	enc->list[cnt].casequal[dcnt].primary_surgeon_id = primary_surgeon_id
	enc->list[cnt].casequal[dcnt].surgeon 	   	     = surgeon
	enc->list[cnt].casequal[dcnt].rec_ver_dt_tm      = rec_ver_dt_tm
 
	case (wound_class)
		of WOUND_NOINC_VAR   : enc->list[cnt].casequal[dcnt].wound_class = "0"
		of WOUND_CLEAN_VAR   : enc->list[cnt].casequal[dcnt].wound_class = "1"
		of WOUND_CLNCONT_VAR : enc->list[cnt].casequal[dcnt].wound_class = "2"
		of WOUND_CONTAM_VAR  : enc->list[cnt].casequal[dcnt].wound_class = "3"
		of WOUND_DIRTY_VAR   : enc->list[cnt].casequal[dcnt].wound_class = "4"
		else                   enc->list[cnt].casequal[dcnt].wound_class = ""
	endcase
 
	enc->list[cnt].casecnt		=	dcnt
foot e.encntr_id
	stat = alterlist(enc->list[cnt].casequal, dcnt)
 
with nocounter



;get blob asa result
SELECT into 'nl:'
 
FROM
	 (DUMMYT dt with seq = size(enc->list,5))
;	,(DUMMYT dt2 with seq = 1)
	,clinical_event ce
	,ce_blob cb
 
PLAN dt
;	WHERE maxrec(dt2, size(enc->list[dt.seq].casequal,5))

;JOIN dt2

JOIN ce 
	WHERE ce.person_id = enc->list[dt.seq].person_id
		AND ce.encntr_id =  enc->list[dt.seq].encntr_id
		AND ce.event_cd = PREANESTNT_VAR
		AND ce.valid_until_dt_tm = CNVTDATETIME("31-DEC-2100 0")
	
JOIN cb
	WHERE ce.event_id = cb.event_id
	AND cb.valid_until_dt_tm = CNVTDATETIME("31-DEC-2100 0")
 
HEAD REPORT
 	
	blobin = fillstring(32768,' ')
	blobsize = 0
	blobout = fillstring(32768,' ')
	bsize = 0
	blobnortf = fillstring(32768,' ')
	rval = 0
	blobres = fillstring(32768,' ')
	asapos = 0
	
DETAIL
 	
	blobin = cb.blob_contents
	blobsize = SIZE(cb.blob_contents)
	if (cb.compression_cd = compcd)
 
		rval = UAR_OCF_UNCOMPRESS(blobin,blobsize,blobout,SIZE(blobout), 0)
 
		rval = UAR_RTF2(blobout,SIZE(blobout),blobnortf,size(blobnortf),bsize,0)
 
		blobres = blobnortf
	else
 		blobout = blobin
		rval = UAR_RTF2(blobout,SIZE(blobout),blobnortf,size(blobnortf),bsize,0)
		blobres = blobnortf
	endif
 
	;find ASA string value
	asapos = findstring("ASA Classification: Class",blobres)
	if (asapos > 0)
		if (findstring("E",(substring(asapos+26,2,blobres)))> 0)
 
			asablob = SUBSTRING(asapos+26,2,blobres)
		else
			asablob = SUBSTRING(asapos+26,1,blobres)
		endif
 
	endif
 
    blobin = fillstring(32768,' ')
	blobsize = 0
	blobout = fillstring(32768,' ')
	blobnortf =fillstring(32768,' ')
	bsize = 0
 
WITH nocounter

 
;CALL ECHORECORD(enc)
;GO TO exitscript
 
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
		and ea.encntr_alias_type_cd = outerjoin(FIN_VAR)   ;1077, 1079
		and ea.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime))
 
join ea2
	where ea2.encntr_id = outerjoin(e.encntr_id)
		and ea2.encntr_alias_type_cd = outerjoin(MRN_VAR)   ;1077, 1079
		and ea2.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime))
 
join pa
	where pa.person_id = outerjoin(e.person_id)
		and pa.person_alias_type_cd = outerjoin(CMRN_VAR)    ;2
		and pa.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate, curtime))
 
detail  ;head dt.seq
	enc->list[dt.seq].fin  = ea.alias                                ;fin
	enc->list[dt.seq].mrn  = cnvtalias(ea2.alias, ea2.alias_pool_cd) ;mrn
	enc->list[dt.seq].cmrn = pa.alias                                ;cmrn
 
with nocounter
 
 
;============================================================================
; SELECT HEIGHT VALUE
;============================================================================
select distinct into "NL:"
;select distinct into value ($outdev)
 
 	 pid = enc->list[dt.seq].person_id
 	,eid = enc->list[dt.seq].encntr_id
 	,ht_clin_event_id = ce.clinical_event_id
  	,height = ce.result_val
 
from
 	(DUMMYT 		dt with seq = value (size (enc->list,5)))
   	,CLINICAL_EVENT	ce
 
plan dt
 
join ce
	where ce.person_id = enc->list[dt.seq].person_id  ;using index xie9clinical_event
		and ce.event_cd = outerjoin(HEIGHT_VAR) ;4154126
		and ce.event_end_dt_tm < sysdate
		and ce.valid_until_dt_tm >= sysdate
		and ce.encntr_id = enc->list[dt.seq].encntr_id
		and ce.result_status_cd IN (AUTHVER_VAR ,MODIFIED_VAR ,ALTERED_VAR )
 
order by dt.seq, pid, height
 
head dt.seq
	enc->list[dt.seq].ht_clin_event_id = ht_clin_event_id
 	enc->list[dt.seq].height           = height
 
with nocounter
 
 
;============================================================================
; SELECT WEIGHT VALUE
; (Preferably get the prior weight to surgery else get the post weight)
;============================================================================
select distinct into "NL:"
;select distinct into value ($outdev)
 
 	 pid = enc->list[dt.seq].person_id
 	,eid = enc->list[dt.seq].encntr_id
 	,wt_clin_event_id = ce.clinical_event_id
 	,case_id = enc->list[dt.seq].casequal[d2.seq].surg_case_id
 
from
 	(DUMMYT 		dt with seq = value (size (enc->list,5)))
 	,(dummyt d2 with seq = 1)
   	,CLINICAL_EVENT ce
 
plan dt
where MAXREC(d2, SIZE(enc->list[dt.seq].casequal,5))
join d2
 
join ce
	where ce.person_id = enc->list[dt.seq].person_id
		and ce.event_cd = WEIGHT_VAR ;4154126
		and ce.event_end_dt_tm < sysdate
		and ce.valid_until_dt_tm >= sysdate
		and ce.encntr_id = enc->list[dt.seq].encntr_id
		and ce.result_status_cd IN (AUTHVER_VAR ,MODIFIED_VAR ,ALTERED_VAR )
 
order by dt.seq, pid, ce.event_cd, ce.event_end_dt_tm desc
 
head case_id
	cnt = 0
 	wtval = 0
 
detail
	cnt = cnt + 1
	if (mod(cnt,10) = 1 or cnt = 1)
		stat = alterlist(enc->list[dt.seq].wt_qual, cnt + 9)
	endif
 
	enc->list[dt.seq].wt_qual[cnt].weight         = ce.result_val
	enc->list[dt.seq].wt_qual[cnt].perfdttm       = format(ce.performed_dt_tm, "mm/dd/yyyy hh:mm;;q")
	enc->list[dt.seq].wt_qual[cnt].eventenddttm   = format(ce.event_end_dt_tm, "mm/dd/yyyy hh:mm;;q")
	enc->list[dt.seq].wt_qual[cnt].eventstartdttm = format(ce.event_start_dt_tm, "mm/dd/yyyy hh:mm;;q")
	enc->list[dt.seq].wt_qual[cnt].case_dt_tm     =
		format(cnvtdatetime(enc->list[dt.seq].casequal[d2.seq].case_start_dt),"mm/dd/yyyy hh:mm;;q")
	enc->list[dt.seq].wt_qual[cnt].perfdatetm     = ce.performed_dt_tm
	enc->list[dt.seq].wt_qual[cnt].eventid        = ce.event_id
	enc->list[dt.seq].wt_cnt = cnt
 
foot case_id
 
	for (rcnt = 1 to enc->list[dt.seq].wt_cnt)
		if (wtval = 0)
			if (cnvtdatetime(enc->list[dt.seq].casequal[d2.seq].case_start_dt) >
					cnvtdatetime(enc->list[dt.seq].wt_qual[rcnt].perfdatetm))
				enc->list[dt.seq].presurgwt = enc->list[dt.seq].wt_qual[rcnt].weight
				enc->list[dt.seq].casequal[d2.seq].perform_dt_tm = enc->list[dt.seq].wt_qual[rcnt].perfdatetm
			elseif (cnvtdatetime(enc->list[dt.seq].casequal[d2.seq].case_start_dt) <=
					cnvtdatetime(enc->list[dt.seq].wt_qual[rcnt].perfdatetm))
				enc->list[dt.seq].postsurgwt = enc->list[dt.seq].wt_qual[rcnt].weight
				enc->list[dt.seq].casequal[d2.seq].perform_dt_tm = enc->list[dt.seq].wt_qual[rcnt].perfdatetm
	;		else
	;			enc->list[dt.seq].weight = 'No Weight'
			endif
			wtval = 1
		endif
	endfor
 
 	enc->list[dt.seq].wt_clin_event_id = wt_clin_event_id
 
	if (size(enc->list[dt.seq].presurgwt) > 0)
		enc->list[dt.seq].weight = enc->list[dt.seq].presurgwt
	elseif (size(enc->list[dt.seq].postsurgwt) > 0)
		enc->list[dt.seq].weight = enc->list[dt.seq].postsurgwt
;	else
;		enc->list[dt.seq].weight = 'No Weight'
	endif
 
	stat = alterlist(enc->list[dt.seq].wt_qual, cnt)
 
with nocounter
 
 
;============================================================================
; SELECT DOCUMENTATION BY CASE: EMERGENCY, TRAUMA, ENDOSCOPE, CLOSURE
; MATCH UP CLINICAL EVENT RECORD TO ENCNTR RECORD
;============================================================================
select distinct into "NL:"
;select distinct into value ($outdev)
	 dt.seq
	,surg_case_id 	       = sc.surg_case_id
	,periop_doc_id 		   = pd.periop_doc_id
	,parent_event_id       = ce.parent_event_id
	,event_id 		       = ce.event_id
	,ce_event_cd		   = ce.event_cd
	,ce_result_val 		   = substring(1,50,ce.result_val)
 
 
from
	 (DUMMYT 				dt with seq = value (size (enc->list,5)))
	,(DUMMYT                d2 with seq = 1)
	,CLINICAL_EVENT   	    ce
	,PERIOPERATIVE_DOCUMENT pd
	,SURGICAL_CASE   	    sc
	,SURG_CASE_PROCEDURE    scp
 
plan dt
where MAXREC(d2, SIZE(enc->list[dt.seq].casequal,5))
join d2
join ce  ; only way this join to the PD table worked was if I join to CE first, and filter the ref nbr
	where ce.encntr_id = enc->list[dt.seq].encntr_id
		and ce.reference_nbr = "*SN*"
		and ce.event_cd in (EMERGENCY_VAR, TRAUMA_VAR, ENDOSCOPE_VAR, CLOSURE_VAR)
		and ce.event_reltn_cd = EVENT_CHILD_VAR ;132
		and ce.view_level = 1
		and ce.valid_until_dt_tm > cnvtdatetime(curdate, curtime3)
 
join sc
	where sc.surg_case_id = enc->list[dt.seq].casequal[d2.seq].surg_case_id
 
join scp
	where scp.surg_case_id = sc.surg_case_id
 
join pd
	where pd.surg_case_id = scp.surg_case_id
		and pd.periop_doc_id = cnvtreal(substring(1,8,ce.reference_nbr))
		and pd.doc_type_cd in (
			CLMC_DOC_TYPE_VAR, CMC_DOC_TYPE_VAR, FLMC_DOC_TYPE_VAR, FSR_DOC_TYPE_VAR,
			LCMC_DOC_TYPE_VAR, MHHS_DOC_TYPE_VAR, MMC_DOC_TYPE_VAR, PWMC_DOC_TYPE_VAR, RMC_DOC_TYPE_VAR
			)
 
order by dt.seq, surg_case_id, periop_doc_id, parent_event_id, event_id
 
detail
	enc->list[dt.seq].casequal[d2.seq].periop_doc_id   = pd.periop_doc_id
	enc->list[dt.seq].casequal[d2.seq].parent_event_id = ce.parent_event_id
	enc->list[dt.seq].casequal[d2.seq].event_id	      = ce.event_id
 
case (ce_event_cd)
	of EMERGENCY_VAR : enc->list[dt.seq].emergency    = ce_result_val
	of TRAUMA_VAR    : enc->list[dt.seq].casequal[d2.seq].trauma       = ce_result_val
	of ENDOSCOPE_VAR : enc->list[dt.seq].casequal[d2.seq].endoscope    = ce_result_val
	of CLOSURE_VAR   : enc->list[dt.seq].casequal[d2.seq].closure_tech = ce_result_val
endcase
 
with nocounter
 
;call echorecord(enc)
;go to exitscript
 
;============================
; REPORT OUTPUT
;============================
select into value (OUTPUT->filename);($OUTDEV)
; 	select into "NL:"
;	;----PERSON
		 ;person_id     	= enc->list[dt.seq].person_id
		 pat_name    	    = CONCAT(enc->list[dt.seq].pat_name,'                                   ')
		,sex         	    = enc->list[dt.seq].sex
	 	,birth_dt    	    = format(enc->list[dt.seq].birth_dt, "mm/dd/yyyy ;;d")
		,age         	    = trim(enc->list[dt.seq].age,3)
		,cmrn        	    = trim(enc->list[dt.seq].cmrn,3)
		,mrn         	    = trim(enc->list[dt.seq].mrn,3)
 
	;----HEIGHT & WEIGHT
	;	,ht_clin_event_id   = enc->list[dt.seq].ht_clin_event_id
		,height      	    = trim(enc->list[dt.seq].height,3)
	;	,wt_clin_event_id   = enc->list[dt.seq].wt_clin_event_id
	;	,presurgwt			= concat(enc->list[dt.seq].presurgwt,'                                   ')
	;	,postsurgwt			= concat(enc->list[dt.seq].postsurgwt,'                                  ')
		,weight      	    = trim(enc->list[dt.seq].weight,3)
 
	;---temporary
	;	,wght_1 			= if(enc->list[dt.seq].perform_dt_tm <= enc->list[dt.seq].case_start_dt) "<=" else ">" endif
	;	,perform_dt_tm		= format(enc->list[dt.seq].perform_dt_tm, "mm/dd/yyyy hh:mm;;d")
	;	,case_start_dt	    = format(enc->list[dt.seq].case_start_dt, "mm/dd/yyyy hh:mm;;d")
	;	,fin	      	    = enc->list[dt.seq].fin
	;---temporary
 
	;----ENCOUNTER
	;	,encntr_id   	    = enc->list[dt.seq].encntr_id
	;	,fac_name    	    = enc->list[dt.seq].fac_name
	;	,fac_abbr    	    = enc->list[dt.seq].fac_abbr
		,fac_unit    	    = trim(enc->list[dt.seq].fac_unit,3)
		,fin	      	    = trim(enc->list[dt.seq].fin,3)
		,admit_dt    	    = format(enc->list[dt.seq].admit_dt, "mm/dd/yyyy hh:mm;;d")
		,disch_dt    	    = format(enc->list[dt.seq].disch_dt, "mm/dd/yyyy hh:mm;;d")
		,outpatient  	    = trim(enc->list[dt.seq].outpatient,3)
		,emergency   	    = evaluate2(if(trim(enc->list[dt.seq].emergency,3) = "Yes") "Y" else "N" endif)
 
	;----CASE
		,surg_case_id	    = enc->list[dt.seq].casequal[d2.seq].surg_case_id
		,surg_case_proc_id  = enc->list[dt.seq].casequal[d2.seq].surg_case_proc_id
		,surg_case_nbr		= trim(enc->list[dt.seq].casequal[d2.seq].surg_case_nbr,3)
		,case_start_dt	    = format(enc->list[dt.seq].casequal[d2.seq].case_start_dt, "mm/dd/yyyy hh:mm;;d")
		,case_stop_dt	    = format(enc->list[dt.seq].casequal[d2.seq].case_stop_dt, "mm/dd/yyyy hh:mm;;d")
	;	,perform_dt_tm		= format(enc->list[dt.seq].perform_dt_tm, "mm/dd/yyyy hh:mm;;d")
		,case_dur     	    = enc->list[dt.seq].casequal[d2.seq].case_dur
		,proc_primary       = enc->list[dt.seq].casequal[d2.seq].proc_primary
		,proc_abbr   	    = trim(enc->list[dt.seq].casequal[d2.seq].proc_abbr,3)
		,proc_dt  		    = format(enc->list[dt.seq].casequal[d2.seq].proc_dt, "mm/dd/yyyy hh:mm;;d")
		,proc_dur_min       = enc->list[dt.seq].casequal[d2.seq].proc_dur_min
;		,asa_class		    = trim(enc->list[dt.seq].asa_class,3)
		,asa_class          = trim(enc->list[dt.seq].casequal[d2.seq].asa_class_anes,3)
		,wound_class	    = trim(enc->list[dt.seq].casequal[d2.seq].wound_class,3)
		,gen_anesth		    = trim(enc->list[dt.seq].casequal[d2.seq].gen_anesth,3)
 
	;----PERIOPERATIVE
	;	,parent_event_id    = enc->list[dt.seq].parent_event_id
	;	,clin_event_id      = enc->list[dt.seq].clin_event_id
	;	,event_id		    = enc->list[dt.seq].event_id
	;	,periop_doc_id	    = enc->list[dt.seq].periop_doc_id
		,primsurg_id = enc->list[dt.seq].casequal[d2.seq].primary_surgeon_id
		,trauma		   	    = evaluate2(if(trim(enc->list[dt.seq].casequal[d2.seq].trauma,3) = "Yes") "Y" else "N" endif)
		,endoscope		    = evaluate2(if(trim(enc->list[dt.seq].casequal[d2.seq].endoscope,3) = "Yes") "Y" else "N" endif)
		,surgeon     	    = trim(enc->list[dt.seq].casequal[d2.seq].surgeon,3)
		,closure_tech	    = evaluate2(if(trim(enc->list[dt.seq].casequal[d2.seq].closure_tech,3) = "Primary") "PRI"
									elseif(trim(enc->list[dt.seq].casequal[d2.seq].closure_tech,3) = "Other") "OTH"
									elseif(trim(enc->list[dt.seq].casequal[d2.seq].closure_tech,3) = "N/A") "N/A"
									else "   " endif)
	;	,rec_ver_dt_tm      = format(enc->list[dt.seq].rec_ver_dt_tm, "mm/dd/yyyy hh:mm;;d")
		,prompt_startdate   = format(enc->prompt_startdate, "mm/dd/yyyy hh:mm;;d")
		,prompt_enddate     = format(enc->prompt_enddate, "mm/dd/yyyy hh:mm;;d")
 
from
	(dummyt dt with seq = value(size(enc->list,5)))
	, (dummyt d2 with seq = 1)
 
plan dt
where MAXREC(d2, SIZE(enc->list[dt.seq].casequal,5))
join d2
 
order by pat_name, surg_case_nbr, proc_primary desc
 
with nocounter, format, formfeed=stream, MAXCOL=2000, SEPARATOR='|'
 
;select into value($outdev)
;	Message =  "File successfully created to Astream folders."
;with format, separator = " ", check;, noheader
 
#exitscript
end
go
 
 
