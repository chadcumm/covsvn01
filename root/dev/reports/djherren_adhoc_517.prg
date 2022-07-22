;djherren_adhoc_517.prg
;****************************************
; NHSN DENOMINATOR FILE - MAIN SELECT
;****************************************
select distinct
;---PERSON
	 person_id   	    = e.person_id
	,pat_name    	    = p.name_full_formatted
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
	,outpatient  	    = max(evaluate2(if(e.encntr_type_cd = 309309) "Y" else "N" endif)) over(partition by e.encntr_id) ;OUTPATIENT_VAR
 
;---CASE
	,anesth_id	        = ar.sa_anesthesia_record_id
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
	,asa_class_test     = evaluate2(if(textlen(cv.display) > 0) cv.display else uar_get_code_display(sc.asa_class_cd) endif)
	,wound_class	    = sc.wound_class_cd
	,gen_anesth		    = evaluate2(if(scp.anesth_type_cd = 19971308) "Y" else "N" endif) ;ANESTH_TYPE_VAR
 
;---PERIOPERATIVE
	,primary_surgeon_id = scp.primary_surgeon_id
	,surgeon 	   	    = pl.name_full_formatted
	,rec_ver_dt_tm      = pd.rec_ver_dt_tm
 
from
	 SURG_CASE_PROCEDURE	 scp
	,SURGICAL_CASE		 	 sc
	,SA_ANESTHESIA_RECORD    ar
	,SA_CASE_ATTRIBUTE	     ca
 	,CODE_VALUE				 cv
	,PERIOPERATIVE_DOCUMENT  pd
	,ENCOUNTER 				 e
	,PERSON              	 p
	,PRSNL               	 pl
 
plan scp
	where scp.proc_start_dt_tm between cnvtdatetime("04-OCT-2018 00:00:00") and cnvtdatetime("29-OCT-2018 23:23:59")
		and scp.active_ind = 1
 
join sc
	where sc.surg_case_id = scp.surg_case_id
		and sc.active_ind = 1
		and nullind(sc.surg_stop_dt_tm) = 0 ;not null
 		and sc.curr_case_status_cd != 667861 ;CASE_CANCELED_VAR
; 		and sc.surg_case_id =    80766211.00
		and sc.surg_case_nbr_formatted = "MMCEN-2018-1163"
 
join ar
	where ar.surgical_case_id = outerjoin(sc.surg_case_id)
		and ar.active_ind = outerjoin(1)
 
join ca
	where ca.sa_anesthesia_record_id = outerjoin(ar.sa_anesthesia_record_id)
		and ca.active_ind = outerjoin(1)
		and ca.case_attribute_type_cd = outerjoin(4056666) ;ASACLASS
 
join cv
	where cv.code_value = outerjoin(cnvtreal(ca.case_attribute_value_txt))
		and cv.active_ind = outerjoin(1)
 
join pd
	where pd.surg_case_id = scp.surg_case_id
 		and pd.doc_term_dt_tm = null
 
join e
	where e.encntr_id = sc.encntr_id
;		and operator(e.loc_facility_cd, OPR_FAC_VAR, $FACILITY_PMPT)
		and	e.loc_facility_cd in (
			2553765291.00,  2552503657.00, 2552503635.00, 21250403.00, 2552503653.00,
			2552503639.00, 2552503613.00, 2552503645.00, 2552503649.00
			)
;		and e.active_ind = 1
;		and e.end_effective_dt_tm >= sysdate
 
join p
	where p.person_id = e.person_id
		and p.person_id = sc.person_id
;		and p.active_ind = 1
;		and p.end_effective_dt_tm >= sysdate
 
join pl
	where pl.person_id = outerjoin(scp.primary_surgeon_id)
		and pl.physician_ind = outerjoin(1)
		and pl.end_effective_dt_tm >= outerjoin(sysdate)
 
order by asa_class_anes, asa_class, pat_name, person_id, encntr_id, surg_case_id, proc_primary desc
