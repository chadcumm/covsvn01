/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:		        Dan Herren / Chad Cummings
	Date Written:		November 2020
	Solution:			Womens Health
	Source file name:	cov_wh_BirthLogBookExtract.prg
	Object name:		cov_wh_BirthLogBookExtract
 
	Program purpose:
 
	Executing from:		CCL
 
 	Special Notes:		Complete rewrite. Original version was copied/modified
						from "PCM_BIRTH_LOG_BOOK_EXTRACT.prg".
						Backed-up "cov_wh_BirthLogBookExtract" on 11-1-2020
						to Subversion.
 
/*****************************************************************************
  	GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
  	Rev#	Mod Date    Developer               Comment
  	----	----------	--------------------	------------------------------
  	001		11-2020     Dan Herren              CR8455 (Rewrite)
  	002		02-2021     Dan Herren              CR9510
 	003		05-2021		Dan Herren				CR10240
 
******************************************************************************/
 
drop program cov_wh_BirthLogBookExtract :dba GO
create program cov_wh_BirthLogBookExtract :dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date/Time" = "04-JAN-2019"
	, "End Date/Time" = "04-JAN-2019"
	, "Facility" = VALUE(0.0           )
 
with OUTDEV, START_DATETIME_PMPT, END_DATETIME_PMPT, FACILITY_PMPT
 
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
 
;free record ids
record ids (
  	1 enctrs [*]
		2 encntr_id						= f8
		2 baby[*]
		 3 label_name					= vc
)
 
record rec (
	1 rec_cnt							= i4
	1 ce_cnt							= i4
	1 username          				= vc
	1 startdate         				= vc
	1 enddate          	 				= vc
	1 preg_history						= i4
	1 mother[*]
		2 facility_abbr      			= vc
		2 facility_desc					= vc
		2 mother_name      				= vc
		2 mother_name_hist				= vc
		2 mother_name_hist_type			= vc
		2 mother_admit_dt				= dq8
		2 mother_discharge_dt			= dq8
		2 mother_fin           			= vc
		2 mother_mrn           			= vc
		2 mother_cmrn           		= vc
		2 mother_race					= vc
		2 mother_age					= dq8
		2 gravida						= vc
		2 parafullterm					= vc
		2 parapreterm					= vc
		2 gest_age						= i4
		2 ega_days						= i4
		2 ega							= vc
		2 edd							= dq8
		2 diagnosis						= vc
		2 aborh							= vc
		2 anesthesia_type				= vc
		2 uc_mon						= vc
		2 mother_to						= vc
		2 mother_to_dt					= dq8
		2 laceration_performed			= vc
		2 laceration_degree				= vc
		2 laceration					= vc
		2 laceration_location			= vc
		2 episiotomy_transcribe			= vc
		2 episiotomy_degree				= vc
		2 episiotomy_location			= vc
		2 episiotomy					= vc
		2 previous_cs					= vc
		2 cs_indications				= vc
		2 induction_method				= vc
		2 augmentation_method 			= vc
		2 presenting_part				= vc
		2 tobacco_use					= vc
		2 tobacco_amt					= vc
		2 tobacco_dt					= dq8
		2 risk_factors					= vc
		2 estimated_blood_loss			= vc
		2 measured_blood_loss			= i4 ;002
		2 transcribed_blood_type		= vc
		2 labor_onset_dt				= dq8
		2 labor_room					= vc
		2 postpartum_room				= vc
		2 hospital_pediatrician			= vc
		2 followup_pediatrician			= vc
		2 nitrous_used					= vc
		2 preg_risk_factors 			= vc
		2 preg_start_dt					= dq8
		2 preg_end_dt					= dq8
		2 event_dt						= dq8
		2 person_id						= f8
		2 encntr_id						= f8
		2 pregnancy_id					= f8
		2 diagnosis_id					= f8
		2 event_id						= f8
		2 baby[*]
			3 label_name				= vc
			3 birth_dt					= dq8
			3 delivery_type				= vc
			3 rom_dt					= dq8
			3 rom_type					= vc
			3 amniotic_fluid			= vc
			3 placenta_delivery_dt		= dq8
			3 maternal_delivery_comp	= vc
			3 newborn_birth_sex			= vc
			3 birth_weight				= vc
			3 baby_fin					= vc
			3 baby_mrn					= vc
			3 baby_band_num				= vc
			3 neo_outcome				= vc
			3 neo_complications			= vc
			3 apgar_1min				= vc
			3 apgar_5min				= vc
			3 apgar_10min				= vc
			3 apgar_15min				= vc
			3 apgar_20min				= vc
			3 cord_blood_banking		= vc
			3 cord_blood_ph				= vc
			3 newborn_to				= vc
			3 feeding_type_newborn		= vc
			3 fhr_mon					= vc
			3 rom_to_delivery_hrs		= vc
			3 Length_Labor_2nd_Stage	= vc
			3 Length_Labor_3rd_Stage	= vc
			3 delivery_provider			= vc
			3 assistant_physician_1		= vc
			3 assistant_physician_2		= vc
			3 attending_physician		= vc
	      	3 delivery_rn_1 			= vc
	      	3 delivery_rn_2 			= vc
			3 nursery_baby_nurse		= vc ;003
			3 anesth_attending			= vc
			3 anesthetist				= vc
			3 resuscitation_rn_1		= vc
 			3 person_id					= f8
			3 event_id					= f8
)
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare ACTIVE_VAR         			= f8 with constant(uar_get_code_by("DISPLAYKEY",    48,"ACTIVE")),protect
declare PLACE_HOLDER_VAR   			= f8 with constant(uar_get_code_by("DISPLAYKEY",    53,"PLACEHOLDER")),protect
declare FIN_TYPE_VAR        		= f8 with constant(uar_get_code_by("DISPLAYKEY",   319,"FINNBR")),protect
declare MRN_TYPE_VAR        		= f8 with constant(uar_get_code_by("DISPLAYKEY",   319,"MRN")),protect
declare CMRN_TYPE_VAR       		= f8 with constant(uar_get_code_by("DISPLAYKEY",   263,"CMRN")),protect
declare PMRN_TYPE_VAR       		= f8 with constant(uar_get_code_by("DISPLAYKEY",     4,"MRN")),protect
declare MOTHER_VAR       			= f8 with constant(uar_get_code_by("DISPLAYKEY",    40,"MOTHER")),protect
declare PREV_NAME_TYPE_VAR 			= f8 with constant(uar_get_code_by("DISPLAYKEY",   213,"PREVIOUS")),protect
declare FAMILY_MEMBER_VAR  			= f8 with constant(uar_get_code_by("DISPLAYKEY",   351,"FAMILYMEMBER")),protect
declare NEWBORN_RELATION_TYPE_VAR   = f8 with constant(uar_get_code_by("DISPLAYKEY",385571,"NEWBORN")),protect
declare NEWBORN_ENCNTR_TYPE_VAR		= f8 with constant(uar_get_code_by("DISPLAYKEY",    71,"NEWBORN")),protect
;
declare G_CD_VAR 					= f8 with constant(uar_get_code_by_cki("CKI.CODEVALUE!6123")),protect
declare KG_CD_VAR					= f8 with constant(uar_get_code_by_cki("CKI.CODEVALUE!2751")),protect
declare LB_CD_VAR 					= f8 with constant(uar_get_code_by_cki("CKI.CODEVALUE!2746")),protect
;
declare DATETIME_BIRTH_VAR			= f8 with constant(uar_get_code_by("DISPLAY",72,"Date, Time of Birth:")),protect
declare GRAVIDA_VAR					= f8 with constant(uar_get_code_by("DISPLAY",72,"Gravida")),protect
declare PARAFULLTERM_VAR			= f8 with constant(uar_get_code_by("DISPLAY",72,"Para Full Term")),protect
declare PARAPRETERM_VAR				= f8 with constant(uar_get_code_by("DISPLAY",72,"Para Premature")),protect
declare DELIVERYTYPE_VAR			= f8 with constant(uar_get_code_by("DISPLAY",72,"Delivery Type:")),protect
declare INDUCTIONMETHOD_VAR			= f8 with constant(uar_get_code_by("DISPLAY",72,"Induction Methods:")),protect
declare AUGMENTATIONMETHOD_VAR		= f8 with constant(uar_get_code_by("DISPLAY",72,"Augmentation Methods:")),protect
declare PREVIOUS_CS_VAR 			= f8 with constant(uar_get_code_by("DISPLAY",72,"Previous Cesarean Delivery")),protect
declare CS_INDICATIONS_VAR 			= f8 with constant(uar_get_code_by("DISPLAY",72,"Reason for C-Section:")),protect
declare ROM_DT_VAR 					= f8 with constant(uar_get_code_by("DISPLAY",72,"ROM Date, Time:")),protect
declare ROM_TYPE_VAR 				= f8 with constant(uar_get_code_by("DISPLAY",72,"Membrane Status:")),protect
declare AMNIOTIC_FLUID_VAR 			= f8 with constant(uar_get_code_by("DISPLAY",72,"Amniotic Fluid Color/Description:")),protect
declare ANESTHESIA_TYPE_VAR 		= f8 with constant(uar_get_code_by("DISPLAY",72,"Delivery Anesthesia:")), protect
declare PRESENTING_PART_VAR 		= f8 with constant(uar_get_code_by("DISPLAY",72,"Presenting Part")), protect
declare LACER_PERFORMED_VAR			= f8 with constant(uar_get_code_by("DISPLAY",72,"Laceration Performed")),protect
declare LACER_DEGREE_VAR			= f8 with constant(uar_get_code_by("DISPLAY",72,"Laceration Degree Transcribed")),protect
declare LACER_LOCATION_VAR 			= f8 with constant(uar_get_code_by("DISPLAY",72,"Laceration Location Transcribed")),protect
declare EPIS_TRANSCRIBED_VAR 		= f8 with constant(uar_get_code_by("DISPLAY",72,"Episiotomy Transcribed")),protect
declare EPIS_DEGREE_VAR				= f8 with constant(uar_get_code_by("DISPLAY",72,"Episiotomy Degree Transcribed")),protect
declare EPIS_LOCATION_VAR 			= f8 with constant(uar_get_code_by("DISPLAY",72,"Episiotomy Location Transcribed")),protect
declare PLACENTA_DELIVERY_DT_VAR	= f8 with constant(uar_get_code_by("DISPLAY",72,"Placenta Delivery Date, Time:")),protect
declare ESTIMATED_BLOOD_LOSS_VAR	= f8 with constant(uar_get_code_by("DISPLAY",72,"Delivery EBL")),protect
declare MEASURED_BLOOD_LOSS_VAR		= f8 with constant(uar_get_code_by("DISPLAY",72,"Measured Blood Loss")),protect ;002
declare ABORH_VAR					= f8 with constant(uar_get_code_by("DISPLAY",72,"ABORh")),protect
declare MATERNAL_DEL_COMP_VAR		= f8 with constant(uar_get_code_by("DISPLAY",72,"Maternal Delivery Complications:")),protect
declare MOTHER_TO_VAR				= f8 with constant(uar_get_code_by("DISPLAY",72,"Transfer To/From")),protect
declare GENDER_VAR					= f8 with constant(uar_get_code_by("DISPLAY",72,"Birth Sex")),protect
declare BIRTH_WEIGHT_VAR			= f8 with constant(uar_get_code_by("DISPLAY",72,"Birth Weight:")),protect
declare NEO_OUTCOME_VAR				= f8 with constant(uar_get_code_by("DISPLAY",72,"Neonate Outcome:")),protect
declare NEO_COMPLICATIONS_VAR		= f8 with constant(uar_get_code_by("DISPLAY",72,"Neonate Complications:")),protect
declare RISK_FACTORS_VAR			= f8 with constant(uar_get_code_by("DISPLAY",72,"Risk Factors:")),protect
declare APGAR_SCORE_1_MINUTE_VAR	= f8 with constant(uar_get_code_by("DISPLAY",72,"Apgar Score 1 Minute:")),protect
declare APGAR_SCORE_5_MINUTE_VAR	= f8 with constant(uar_get_code_by("DISPLAY",72,"Apgar Score 5 Minute:")),protect
declare APGAR_SCORE_10_MINUTE_VAR	= f8 with constant(uar_get_code_by("DISPLAY",72,"Apgar Score 10 Minute:")),protect
declare APGAR_SCORE_15_MINUTE_VAR	= f8 with constant(uar_get_code_by("DISPLAY",72,"Apgar Score 15 Minute:")),protect
declare APGAR_SCORE_20_MINUTE_VAR	= f8 with constant(uar_get_code_by("DISPLAY",72,"Apgar Score 20 Minute:")),protect
declare CORD_BLOOD_BANKING_VAR		= f8 with constant(uar_get_code_by("DISPLAY",72,"Cord Blood Banking:")),protect
declare CORD_BLOOD_PH_VAR			= f8 with constant(uar_get_code_by("DISPLAY",72,"Cord Blood pH Drawn:")),protect
declare BABY_BAND_NUM_VAR			= f8 with constant(uar_get_code_by("DISPLAY",72,"ID Band Number:")),protect
declare FEEDING_TYPE_NEWBORN_VAR	= f8 with constant(uar_get_code_by("DISPLAY",72,"Feeding Type Newborn")),protect
declare NEWBORN_TO_VAR				= f8 with constant(uar_get_code_by("DISPLAY",72,"Transferred To:")),protect
declare FHR_MON_VAR					= f8 with constant(uar_get_code_by("DISPLAY",72,"FHR Monitoring Method:")),protect
declare UC_MON_VAR					= f8 with constant(uar_get_code_by("DISPLAY",72,"Uterine Contraction Monitoring Method")),protect
declare LABOR_ONSET_DT_VAR			= f8 with constant(uar_get_code_by("DISPLAY",72,"Labor Onset, Date, Time:")),protect
declare ROM_TO_DEL_HRS_VAR			= f8 with constant(uar_get_code_by("DISPLAY",72,"ROM to Delivery Hours Calc:")),protect
declare LENGTH_LABOR_2ND_STAGE_VAR	= f8 with constant(uar_get_code_by("DISPLAY",72,"Length of Labor, 2nd Stage Hrs Calc:")),protect
declare LENGTH_LABOR_3RD_STAGE_VAR	= f8 with constant(uar_get_code_by("DISPLAY",72,"Length of Labor, 3rd Stage:")),protect
declare DELIVERY_PROVIDER_VAR		= f8 with constant(uar_get_code_by("DISPLAY",72,"Delivery Physician:")),protect
declare ASSISTANT_PHYSICIAN_1_VAR	= f8 with constant(uar_get_code_by("DISPLAY",72,"Assistant Physician #1:")),protect
declare ASSISTANT_PHYSICIAN_2_VAR	= f8 with constant(uar_get_code_by("DISPLAY",72,"Assistant Physician #2:")),protect
declare ATTENDING_PHYSICIAN_VAR		= f8 with constant(uar_get_code_by("DISPLAY",72,"Attending Physician:")),protect
declare DELIVERY_RN_1_VAR			= f8 with constant(uar_get_code_by("DISPLAY",72,"Delivery RN #1:")),protect
declare DELIVERY_RN_2_VAR			= f8 with constant(uar_get_code_by("DISPLAY",72,"Delivery RN #2:")),protect
declare NURSERY_BABY_NURSE_VAR		= f8 with constant(uar_get_code_by("DISPLAY",72,"Nursery/Baby Nurse:")),protect ;003
declare ANESTH_ATTENDING_VAR		= f8 with constant(uar_get_code_by("DISPLAY",72,"Anesthesiologist Attending Delivery:")),protect
declare ANESTHETIST_VAR 			= f8 with constant(uar_get_code_by("DISPLAY",72,"Anesthetist/ CRNA:")),protect
declare HOSPITAL_PEDIATRICIAN_VAR 	= f8 with constant(uar_get_code_by("DISPLAY",72,"Pediatrician Selected")),protect
declare FOLLOWUP_PEDIATRICIAN_VAR	= f8 with constant(uar_get_code_by("DISPLAY",72,"Pediatrician After Discharge:")),protect
declare RESUSCITATION_RN_1_VAR		= f8 with constant(uar_get_code_by("DISPLAY",72,"Resuscitation RN #1:")),protect
declare NITROUS_OXIDE_ACTIVITY_VAR	= f8 with constant(uar_get_code_by("DISPLAY",72,"Nitrous Oxide Activity")), protect
declare RF_ANTI_CUR_PREG_VAR 		= f8 with constant(uar_get_code_by("DISPLAY",72,"Risk Factors, Antepartum Current Preg")),protect
declare TOBACCO_LAST_USE_VAR		= f8 with constant(uar_get_code_by("DISPLAY",72,"Tobacco Last Use")),protect
declare TOBACCO_USE_PER_DAY_VAR		= f8 with constant(uar_get_code_by("DISPLAY",72,"Cigarette Use Packs/Day")),protect ;type
declare TOBACCO_USE_VAR				= f8 with constant(uar_get_code_by("DISPLAY",14003,"SHX Tobacco use")),protect
declare TOBACCO_AMOUNT_PER_DAY_VAR 	= f8 with constant(uar_get_code_by("DISPLAY",14003,"SHX Tobacco amount per day")),protect
declare TOBACCO_CD_VAR				= f8 with constant(uar_get_code_by("DISPLAY",4002165,"Tobacco")),protect
declare SHX_ACTIVE_VAR				= f8 with constant(uar_get_code_by("DISPLAY",4002172,"Active")),protect
;
declare AUTH_VAR   					= f8 with constant(uar_get_code_by("DESCRIPTION", 8,"Auth (Verified)")),protect
declare MODIFIED_VAR 				= f8 with constant(uar_get_code_by("DESCRIPTION", 8,"Modified/Amended/Corrected")),protect
declare ALTERED_VAR   				= f8 with constant(uar_get_code_by("DESCRIPTION", 8,"Modified/Amended/Cor")),protect
declare TRANS_BLOOD_TYPE_VAR		= f8 with constant(uar_get_code_by("DESCRIPTION",72,"Blood Type, Transcribed")), protect
;
declare SHX_CODE_SET_VAR 			= i4 with protect, constant(14003)
declare HX_TOB_USE_PARSER 			= vc with protect, noconstant("")
declare HX_TOB_AMT_PARSER 			= vc with protect, noconstant("")
declare HX_TOB_PARSER 				= vc with protect, noconstant("")
declare OPR_FAC_VAR		   			= vc with noconstant(fillstring(1000," "))
;
declare username           			= vc with protect
declare initcap()          			= c100
declare	diag_var					= vc
;
declare num							= i4 with noconstant(0)
declare idx							= i4 with noconstant(0)
;
declare SPD 						= i4 with protect, noconstant(280) ;standard pregnancy duration in days
;
declare actual_size  				= i4 WITH public
declare expand_size  				= i4 WITH public, constant(200)
declare expand_total 				= i4 WITH public
declare expand_start 				= i4 WITH public
declare expand_stop  				= i4 WITH public
declare expand_num   				= i4 WITH public
 
 
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
if (($2 in ("*curdate*")))
	declare _dq8 = dq8 with noconstant ,private
  	declare _parse = vc with constant (concat ("set _dq8 = cnvtdatetime(" , $2 ,", 0) go")) ,private
  	call parser (_parse)
  	declare START_DATETIME_VAR = vc with protect ,constant (format (_dq8 ,"dd-mmm-yyyy;;d"))
else
 	declare START_DATETIME_VAR = vc with protect ,constant ($2)
endif
 
if (($3 in ("*curdate*")))
  	declare _dq8 = dq8 with noconstant ,private
  	declare _parse2 = vc with constant (concat ("set _dq8 = cnvtdatetime(" , $3 ,", 235959) go")) ,private
  	call parser (_parse2)
  	declare END_DATETIME_VAR = vc with protect ,constant (format (_dq8 ,"dd-mmm-yyyy hh:mm;;q"))
else
  	declare END_DATETIME_VAR = vc with protect ,constant (concat (trim ($3) ," 23:59:59"))
endif
 
 
;; SET DATE VARIABLES FOR *****  MANUAL TESTING  *****
;set START_DATETIME_VAR = cnvtdatetime("26-FEB-2019 00:00:00")
;set END_DATETIME_VAR   = cnvtdatetime("26-FEB-2019 23:59:59")
 
 
; SET DATES VARIABLES TO RECORD STRUCTURE
set rec->startdate = START_DATETIME_VAR
set rec->enddate   = START_DATETIME_VAR
 
 
;SET FACILITY VARIABLE
if(substring(1,1,reflect(parameter(parameter2($FACILITY_PMPT),0))) = "L")	;multiple values were selected
	set OPR_FAC_VAR = "in"
elseif(parameter(parameter2($FACILITY_PMPT),1)= 0.0)						;all (any) values were selected
	set OPR_FAC_VAR = "!="
else																		;a single value was selected
	set OPR_FAC_VAR = "="
endif
 
 
;==============================================================================
; GET ENCOUNTER ID'S FOR PROMPTED BIRTH-DATE DATE RANGE
;==============================================================================
call echo(build("*** GET ENCOUNTER ID'S FOR SELECTED BIRTH-DATE DATE RANGE ***"))
select distinct into "NL:"
 
from ENCOUNTER e
 
	,(inner join CLINICAL_EVENT ce on ce.encntr_id = e.encntr_id
		and ce.event_cd = DATETIME_BIRTH_VAR ;17022094.00
		and ce.result_status_cd in (AUTH_VAR, MODIFIED_VAR, ALTERED_VAR) ;25,34,35
		and ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3))
 
	,(inner join CE_DATE_RESULT cdr on cdr.event_id = ce.event_id
   		and (cdr.result_dt_tm >= cnvtdatetime(START_DATETIME_VAR) and cdr.result_dt_tm <= cnvtdatetime(END_DATETIME_VAR))
		and cdr.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3))
 
	,(inner join CE_DYNAMIC_LABEL cdl on cdl.ce_dynamic_label_id = ce.ce_dynamic_label_id
		and cdl.ce_dynamic_label_id > 0.0)
 
where operator(e.loc_facility_cd, OPR_FAC_VAR, $FACILITY_PMPT)
;	and e.person_id in (   15199492.00,   15138797.00,    20286282.00)
	and e.active_ind = 1
 
order by e.encntr_id, cdl.label_name
 
head report
	cnt = 0
	baby_cnt = 0
 
head e.encntr_id
	baby_cnt = 0
	cnt = cnt + 1
 
  	if (mod(cnt,10) = 1 or cnt = 1)
 		stat = alterlist(ids->enctrs, cnt + 9)
 	endif
 
 	ids->enctrs[cnt].encntr_id = e.encntr_id
 
head cdl.label_name
	baby_cnt = baby_cnt + 1
 
	stat = alterlist(ids->enctrs[cnt].baby,baby_cnt)
 
	ids->enctrs[cnt].baby[baby_cnt].label_name = cdl.label_name
 
foot report
	stat = alterlist(ids->enctrs, cnt)
	rec->rec_cnt = cnt
 
with nocounter
 
call echorecord(ids)
;go to exitscript
 
 
;==============================================================================
; MOTHER DATA SELECT
;==============================================================================
call echo(build("*** MOTHER DATA SELECT ***"))
select distinct into "NL:"
	 facility_abbr			= uar_get_code_display(e.loc_facility_cd)
	,facility_desc			= uar_get_code_description(e.loc_facility_cd)
	,mother_name 			= p.name_full_formatted
	,mother_name_hist		= pn.name_full
	,mother_name_hist_type	= uar_get_code_display(pnh.name_type_cd)
	,mother_age 			= p.birth_dt_tm
	,mother_race 			= uar_get_code_display(p.race_cd)
	,mother_admit_dt		= e.reg_dt_tm
	,mother_discharge_dt	= e.disch_dt_tm
	,person_id				= p.person_id
	,encntr_id				= e.encntr_id
	,pregnancy_id			= pi.pregnancy_id
 
from ENCOUNTER e
 
	,(inner join PERSON p on p.person_id = e.person_id
;		and p.person_id =  16367351 ;   14565902.00;   15521678.00
		and p.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
		and p.active_ind = 1)
 
	,(left join PERSON_NAME_HIST pnh on pnh.person_id = p.person_id
;;;		and pnh.name_type_cd = PREV_NAME_TYPE_VAR ;771
;;		and ((e.reg_dt_tm between pnh.beg_effective_dt_tm and pnh.end_effective_dt_tm))
		and pnh.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
		and pnh.active_ind = 1)
 
	,(left join PERSON_NAME pn on pn.person_name_id = pnh.person_name_id
		and pn.end_effective_dt_tm > cnvtdatetime(curdate, curtime3)
		and pn.active_ind = 1)
 
	,(inner join CLINICAL_EVENT ce on ce.encntr_id = e.encntr_id and ce.person_id = e.person_id
		and ce.result_status_cd in (AUTH_VAR, MODIFIED_VAR, ALTERED_VAR) ;25,34,35
		and ce.event_tag != "Date\Time Correction"
		and ce.event_cd in (
			ABORH_VAR, ANESTHESIA_TYPE_VAR, UC_MON_VAR, MOTHER_TO_VAR, LACER_PERFORMED_VAR, LACER_DEGREE_VAR,
			LACER_LOCATION_VAR, EPIS_TRANSCRIBED_VAR, EPIS_DEGREE_VAR, EPIS_LOCATION_VAR, PREVIOUS_CS_VAR,
			CS_INDICATIONS_VAR, INDUCTIONMETHOD_VAR, AUGMENTATIONMETHOD_VAR, ESTIMATED_BLOOD_LOSS_VAR,
			LABOR_ONSET_DT_VAR, TRANS_BLOOD_TYPE_VAR, DATETIME_BIRTH_VAR, DELIVERYTYPE_VAR, ROM_DT_VAR, ROM_TYPE_VAR,
			AMNIOTIC_FLUID_VAR, PRESENTING_PART_VAR, PLACENTA_DELIVERY_DT_VAR, TRANS_BLOOD_TYPE_VAR, MATERNAL_DEL_COMP_VAR,
			GENDER_VAR, BIRTH_WEIGHT_VAR, NEO_OUTCOME_VAR, NEO_COMPLICATIONS_VAR, RISK_FACTORS_VAR, APGAR_SCORE_1_MINUTE_VAR,
			APGAR_SCORE_5_MINUTE_VAR, APGAR_SCORE_10_MINUTE_VAR, APGAR_SCORE_15_MINUTE_VAR, APGAR_SCORE_20_MINUTE_VAR,
			NEWBORN_TO_VAR, FHR_MON_VAR, ROM_TO_DEL_HRS_VAR, LENGTH_LABOR_2ND_STAGE_VAR, LENGTH_LABOR_3RD_STAGE_VAR,
			NITROUS_OXIDE_ACTIVITY_VAR, DELIVERY_PROVIDER_VAR, ASSISTANT_PHYSICIAN_1_VAR, ASSISTANT_PHYSICIAN_2_VAR,
			ATTENDING_PHYSICIAN_VAR, DELIVERY_RN_1_VAR, DELIVERY_RN_2_VAR, ANESTH_ATTENDING_VAR, ANESTHETIST_VAR,
			HOSPITAL_PEDIATRICIAN_VAR, FOLLOWUP_PEDIATRICIAN_VAR, RESUSCITATION_RN_1_VAR )
		and ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3))
 
	,(left join CE_DATE_RESULT cdr on cdr.event_id = ce.event_id
		and cdr.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3))
 
	,(inner join PROBLEM pb on pb.person_id = ce.person_id
		and pb.problem_type_flag = 2 ;pregnancy
		and pb.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
		and pb.active_ind = 1)
 
	,(inner join PREGNANCY_INSTANCE pi on pi.person_id = pb.person_id
		and pi.problem_id = pb.problem_id
;		and ((cdr.result_dt_tm between pi.preg_start_dt_tm and pi.preg_end_dt_tm))
		and ((e.reg_dt_tm between pi.preg_start_dt_tm and pi.preg_end_dt_tm))
		and p.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
		and pi.active_ind = 1)
 
where expand (num, 1, size(ids->enctrs, 5), e.encntr_id, ids->enctrs[num].encntr_id)
	and e.end_effective_dt_tm > cnvtdatetime(curdate,curtime3)
	and e.active_ind = 1
 
order by e.encntr_id, ce.event_id
 
head report
	cnt = 0
 
head e.encntr_id
	cnt = cnt + 1
 
 	stat = alterlist(rec->mother, cnt)
 
	rec->mother[cnt].facility_abbr			= facility_abbr
	rec->mother[cnt].facility_desc			= facility_desc
	rec->mother[cnt].mother_name      		= mother_name
	rec->mother[cnt].mother_name_hist  		= mother_name_hist
	rec->mother[cnt].mother_name_hist_type	= mother_name_hist_type
	rec->mother[cnt].mother_admit_dt		= mother_admit_dt
	rec->mother[cnt].mother_discharge_dt	= mother_discharge_dt
	rec->mother[cnt].mother_race			= mother_race
	rec->mother[cnt].mother_age				= mother_age
	rec->mother[cnt].person_id				= person_id
 	rec->mother[cnt].encntr_id	 			= encntr_id
	rec->mother[cnt].pregnancy_id			= pregnancy_id
 
head ce.event_id
	case (ce.event_cd)
		of ABORH_VAR					: rec->mother[cnt].aborh					= ce.result_val
		of ANESTHESIA_TYPE_VAR			: rec->mother[cnt].anesthesia_type			= ce.result_val
		of UC_MON_VAR					: rec->mother[cnt].uc_mon					= ce.result_val
		of MOTHER_TO_VAR				: rec->mother[cnt].mother_to				= ce.result_val,
										  rec->mother[cnt].mother_to_dt				= ce.event_end_dt_tm
		of LACER_PERFORMED_VAR			: rec->mother[cnt].laceration_performed		= ce.result_val
		of LACER_DEGREE_VAR				: rec->mother[cnt].laceration_degree		= ce.result_val
		of LACER_LOCATION_VAR			: rec->mother[cnt].laceration_location		= ce.result_val
		of EPIS_TRANSCRIBED_VAR			: rec->mother[cnt].episiotomy_transcribe	= ce.result_val
		of EPIS_DEGREE_VAR				: rec->mother[cnt].episiotomy_degree		= ce.result_val
		of EPIS_LOCATION_VAR			: rec->mother[cnt].episiotomy_location		= ce.result_val
		of PREVIOUS_CS_VAR				: rec->mother[cnt].previous_cs				= ce.result_val
		of CS_INDICATIONS_VAR			: rec->mother[cnt].cs_indications			= ce.result_val
		of INDUCTIONMETHOD_VAR			: rec->mother[cnt].induction_method			= ce.result_val
		of AUGMENTATIONMETHOD_VAR		: rec->mother[cnt].augmentation_method		= ce.result_val
		of PRESENTING_PART_VAR			: rec->mother[cnt].presenting_part			= ce.result_val
		of RISK_FACTORS_VAR				: rec->mother[cnt].risk_factors				= ce.result_val
		of ESTIMATED_BLOOD_LOSS_VAR		: rec->mother[cnt].estimated_blood_loss		= ce.result_val
		of TRANS_BLOOD_TYPE_VAR			: rec->mother[cnt].transcribed_blood_type	= ce.result_val
		of LABOR_ONSET_DT_VAR			: rec->mother[cnt].labor_onset_dt			= cdr.result_dt_tm
		of HOSPITAL_PEDIATRICIAN_VAR	: rec->mother[cnt].hospital_pediatrician	= ce.result_val
		of FOLLOWUP_PEDIATRICIAN_VAR	: rec->mother[cnt].followup_pediatrician	= ce.result_val
		of NITROUS_OXIDE_ACTIVITY_VAR	: rec->mother[cnt].nitrous_used				= ce.result_val
	endcase
 
	rec->mother[cnt].laceration = concat(rec->mother[cnt].laceration_performed, " ", rec->mother[cnt].laceration_degree, " ",
			rec->mother[cnt].laceration_location)
 
	rec->mother[cnt].episiotomy = concat(rec->mother[cnt].episiotomy_transcribe, " ", rec->mother[cnt].episiotomy_degree, " ",
			rec->mother[cnt].episiotomy_location)
 
foot report
	stat = alterlist(rec->mother, cnt)
 
with nocounter, expand = 1, time=300
 
;call echorecord(rec)
;go to exitscript
 
 
;==============================================================================
; GROUP THE LABEL-NAME FOR BABY OR BABIES
;==============================================================================
select into "nl:"
	 encntr_id 	= rec->mother[d3.seq].encntr_id
	,baby_label	= ids->enctrs[d1.seq].baby[d2.seq].label_name
 
from
	 (DUMMYT d1 with seq=size(ids->enctrs,5))
	,(DUMMYT d2)
	,(DUMMYT d3 with seq=size(rec->mother,5))
 
plan d1 where maxrec(d2,size(ids->enctrs[d1.seq].baby,5))
 
join d2
 
join d3 where ids->enctrs[d1.seq].encntr_id = rec->mother[d3.seq].encntr_id
 
order by encntr_id, baby_label
 
head report
	baby_cnt = 0
 
head encntr_id
	baby_cnt = 0
 
head baby_label
	baby_cnt = baby_cnt + 1
 
	stat = alterlist(rec->mother[d3.seq].baby,baby_cnt)
 
	rec->mother[d3.seq].baby[d2.seq].label_name = baby_label
 
foot report
	row+1
 
with nocounter
 
;===============
select into "nl:"
	 ce.encntr_id
	,cdl.label_name
	,ce.event_cd
 
from
	 (DUMMYT d1 with seq=size(rec->mother,5))
	,(DUMMYT d2)
	,(DUMMYT d3)
	,CLINICAL_EVENT ce
	,CE_DYNAMIC_LABEL cdl
	,CE_DATE_RESULT cdr
 
plan d1
	where maxrec(d2,size(rec->mother[d1.seq].baby,5))
 
join d2
 
join ce where ce.encntr_id = rec->mother[d1.seq].encntr_id
	and ce.result_status_cd in (AUTH_VAR, MODIFIED_VAR, ALTERED_VAR) ;25,34,35
	and ce.event_tag != "Date\Time Correction"
	and ce.ce_dynamic_label_id > 0.0
	and ce.event_cd in (
		DATETIME_BIRTH_VAR, DELIVERYTYPE_VAR, ROM_DT_VAR, ROM_TYPE_VAR, AMNIOTIC_FLUID_VAR,
		PLACENTA_DELIVERY_DT_VAR, MATERNAL_DEL_COMP_VAR, GENDER_VAR, BIRTH_WEIGHT_VAR, NEO_OUTCOME_VAR,
		NEO_COMPLICATIONS_VAR, APGAR_SCORE_1_MINUTE_VAR, APGAR_SCORE_5_MINUTE_VAR, APGAR_SCORE_10_MINUTE_VAR,
		APGAR_SCORE_15_MINUTE_VAR, APGAR_SCORE_20_MINUTE_VAR, CORD_BLOOD_BANKING_VAR, CORD_BLOOD_PH_VAR,
		BABY_BAND_NUM_VAR, NEWBORN_TO_VAR, FHR_MON_VAR, ROM_TO_DEL_HRS_VAR, LENGTH_LABOR_2ND_STAGE_VAR,
		LENGTH_LABOR_3RD_STAGE_VAR, DELIVERY_PROVIDER_VAR, ASSISTANT_PHYSICIAN_1_VAR, ASSISTANT_PHYSICIAN_2_VAR,
		ATTENDING_PHYSICIAN_VAR, DELIVERY_RN_1_VAR, DELIVERY_RN_2_VAR, NURSERY_BABY_NURSE_VAR, ANESTH_ATTENDING_VAR,
		ANESTHETIST_VAR, RESUSCITATION_RN_1_VAR )  ;003
	and ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3)
 
join cdl where cdl.ce_dynamic_label_id = ce.ce_dynamic_label_id
	and cdl.label_name = rec->mother[d1.seq].baby[d2.seq].label_name
 
join d3
 
join cdr where cdr.event_id = ce.event_id
	and cdr.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3)
 
order by
	 ce.encntr_id, cdl.label_name, ce.event_id
 
head report
	row +1
 
head ce.encntr_id
	row +1
 
head cdl.label_name
	row +1
 
head ce.event_id
	case (ce.event_cd)
		of DATETIME_BIRTH_VAR			: rec->mother[d1.seq].baby[d2.seq].birth_dt					= cdr.result_dt_tm
		of DELIVERYTYPE_VAR				: rec->mother[d1.seq].baby[d2.seq].delivery_type			= ce.result_val
		of ROM_DT_VAR					: rec->mother[d1.seq].baby[d2.seq].rom_dt					= cdr.result_dt_tm
		of ROM_TYPE_VAR					: rec->mother[d1.seq].baby[d2.seq].rom_type					= ce.result_val
		of AMNIOTIC_FLUID_VAR			: rec->mother[d1.seq].baby[d2.seq].amniotic_fluid			= ce.result_val
		of PLACENTA_DELIVERY_DT_VAR		: rec->mother[d1.seq].baby[d2.seq].placenta_delivery_dt		= cdr.result_dt_tm
		of MATERNAL_DEL_COMP_VAR		: rec->mother[d1.seq].baby[d2.seq].maternal_delivery_comp	= ce.result_val
		of GENDER_VAR					: rec->mother[d1.seq].baby[d2.seq].newborn_birth_sex			= ce.result_val
		of BIRTH_WEIGHT_VAR				: rec->mother[d1.seq].baby[d2.seq].birth_weight				=
    			if ((ce.result_units_cd = G_CD_VAR)) ce.result_val
    			elseif ((ce.result_units_cd = KG_CD_VAR)) cnvtstring ((cnvtreal (ce.result_val) * 1000))
    			elseif ((ce.result_units_cd = LB_CD_VAR)) cnvtstring ((cnvtreal (ce.result_val) * 453.59237))
    			endif
		of NEO_OUTCOME_VAR				: rec->mother[d1.seq].baby[d2.seq].neo_outcome				= ce.result_val
		of NEO_COMPLICATIONS_VAR		: rec->mother[d1.seq].baby[d2.seq].neo_complications		= ce.result_val
   		of APGAR_SCORE_1_MINUTE_VAR		: rec->mother[d1.seq].baby[d2.seq].apgar_1min				= ce.result_val
		of APGAR_SCORE_5_MINUTE_VAR		: rec->mother[d1.seq].baby[d2.seq].apgar_5min				= ce.result_val
		of APGAR_SCORE_10_MINUTE_VAR	: rec->mother[d1.seq].baby[d2.seq].apgar_10min				= ce.result_val
		of APGAR_SCORE_15_MINUTE_VAR	: rec->mother[d1.seq].baby[d2.seq].apgar_15min				= ce.result_val
		of APGAR_SCORE_20_MINUTE_VAR	: rec->mother[d1.seq].baby[d2.seq].apgar_20min				= ce.result_val
		of CORD_BLOOD_BANKING_VAR		: rec->mother[d1.seq].baby[d2.seq].cord_blood_banking		= ce.result_val
		of CORD_BLOOD_PH_VAR			: rec->mother[d1.seq].baby[d2.seq].cord_blood_ph			= ce.result_val
		of BABY_BAND_NUM_VAR			: rec->mother[d1.seq].baby[d2.seq].baby_band_num			= ce.result_val
		of NEWBORN_TO_VAR				: rec->mother[d1.seq].baby[d2.seq].newborn_to				= ce.result_val
		of FHR_MON_VAR					: rec->mother[d1.seq].baby[d2.seq].fhr_mon					= ce.result_val
		of ROM_TO_DEL_HRS_VAR			: rec->mother[d1.seq].baby[d2.seq].rom_to_delivery_hrs		= ce.result_val
		of LENGTH_LABOR_2ND_STAGE_VAR	: rec->mother[d1.seq].baby[d2.seq].Length_Labor_2nd_Stage	= ce.result_val
		of LENGTH_LABOR_3RD_STAGE_VAR	: rec->mother[d1.seq].baby[d2.seq].Length_Labor_3RD_Stage	= ce.result_val
		of DELIVERY_PROVIDER_VAR		: rec->mother[d1.seq].baby[d2.seq].delivery_provider		= ce.result_val
		of ASSISTANT_PHYSICIAN_1_VAR	: rec->mother[d1.seq].baby[d2.seq].assistant_physician_1	= ce.result_val
		of ASSISTANT_PHYSICIAN_2_VAR	: rec->mother[d1.seq].baby[d2.seq].assistant_physician_2	= ce.result_val
		of ATTENDING_PHYSICIAN_VAR		: rec->mother[d1.seq].baby[d2.seq].attending_physician		= ce.result_val
		of DELIVERY_RN_1_VAR			: rec->mother[d1.seq].baby[d2.seq].delivery_rn_1			= ce.result_val
		of DELIVERY_RN_2_VAR			: rec->mother[d1.seq].baby[d2.seq].delivery_rn_2			= ce.result_val
		of NURSERY_BABY_NURSE_VAR		: rec->mother[d1.seq].baby[d2.seq].nursery_baby_nurse		= ce.result_val ;003
		of ANESTH_ATTENDING_VAR			: rec->mother[d1.seq].baby[d2.seq].anesth_attending			= ce.result_val
		of ANESTHETIST_VAR				: rec->mother[d1.seq].baby[d2.seq].anesthetist				= ce.result_val
		of RESUSCITATION_RN_1_VAR		: rec->mother[d1.seq].baby[d2.seq].resuscitation_rn_1		= ce.result_val
	endcase
 
foot report
	row+1
 
with nocounter, outerjoin=d3, time=120
 
;call echorecord(rec)
;go to exitscript
 
 
;==============================================================================
; GET PREGNANCY DATA
;==============================================================================
call echo(build("*** GET PREGNANCY DATA ***"))
select into "nl:"
 
from PREGNANCY_INSTANCE pi
 
	,(inner join PREGNANCY_ESTIMATE pe on pe.pregnancy_id = pi.pregnancy_id
		and pe.active_ind = 1)
 
where expand(num, 1, size(rec->mother, 5), pi.pregnancy_id, rec->mother[num].pregnancy_id)
	and pi.active_ind = 1
 
detail
	idx = 0
	pos = 0
 
	pos = locateval(idx, 1, size(rec->mother,5), pi.pregnancy_id, rec->mother[idx].pregnancy_id)
 
	while (pos > 0)
		rec->mother[pos].preg_start_dt	= pi.preg_start_dt_tm
		rec->mother[pos].preg_end_dt 	= pi.preg_end_dt_tm
		rec->mother[pos].edd 			= pe.est_delivery_dt_tm
		rec->mother[pos].ega_days 		= pe.est_gest_age_days
 
		;if no triage, do not display EGA
		rec->mother[pos].ega = null
 		rec->mother[pos].gest_age = datetimediff(cnvtdatetime(rec->mother[pos].mother_admit_dt),
			datetimeadd(pe.est_delivery_dt_tm, - (SPD)))
 
		if (mod(rec->mother[pos].gest_age,7) = 0)  ;zero days
 			rec->mother[pos].ega = build2(trim(cnvtstring(rec->mother[pos].gest_age/7))," Weeks ")
		else
 			rec->mother[pos].ega = build2(trim(cnvtstring(rec->mother[pos].gest_age/7)),"W, ",
				trim(cnvtstring(mod(rec->mother[pos].gest_age,7))),"D")
		endif
 
		pos = locateval(idx, pos+1, size(rec->mother,5), pi.pregnancy_id, rec->mother[idx].pregnancy_id)
	endwhile
 
with nocounter, expand = 1
 
;call echorecord(rec)
;go to exitscript
 
 
;============================================================================
; GET MOTHER FIN, MRN, CMRN DATA
;============================================================================
call echo(build("*** GET MOTHER FIN, MRN, CMRN DATA ***"))
select into "NL:"
 
from ENCOUNTER e
 
	,(inner join ENCNTR_ALIAS ea on ea.encntr_id = e.encntr_id
		and ea.encntr_alias_type_cd = FIN_TYPE_VAR   ;1077
		and ea.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
		and ea.active_ind = 1)
 
	,(inner join ENCNTR_ALIAS ea2 on ea2.encntr_id = e.encntr_id
		and ea2.encntr_alias_type_cd = MRN_TYPE_VAR   ;1077
		and ea2.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
		and ea2.active_ind = 1)
 
	,(left join PERSON_ALIAS pa on pa.person_id = e.person_id
		and pa.person_alias_type_cd = CMRN_TYPE_VAR    ;263
		and pa.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
		and pa.active_ind = 1)
 
where expand(num, 1, size(rec->mother, 5), e.encntr_id, rec->mother[num].encntr_id)
	and e.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
	and e.active_ind = 1
 
detail
	idx = 0
	pos = 0
 
	pos = locateval(idx, 1, size(rec->mother,5), e.encntr_id, rec->mother[idx].encntr_id)
 
	while (pos > 0)
		rec->mother[pos].mother_fin  = ea.alias		;fin
		rec->mother[pos].mother_mrn  = ea2.alias	;mrn
;		rec->mother[pos].mother_cmrn = pa.alias		;cmrn
 
		pos = locateval(idx, pos+1, size(rec->mother,5), e.encntr_id, rec->mother[idx].encntr_id)
	endwhile
 
with nocounter, expand = 1
 
;call echorecord(rec)
;go to exitscript
 
 
;============================================================================
; GET BABY FIN & MRN DATA
;============================================================================
call echo(build("*** GET BABY FIN & MRN DATA ***"))
select into "nl:"
from
	 (DUMMYT d1 with seq = size(rec->mother ,5))
	,(DUMMYT d2)
	,PERSON_PERSON_RELTN ppr
	,ENCOUNTER e
	,ENCNTR_ALIAS ea
	,PERSON_ALIAS pa
	,PERSON p
 
plan d1	where maxrec(d2,size(rec->mother[d1.seq].baby,5))
 
join d2
 
join ppr where ppr.related_person_id = rec->mother[d1.seq].person_id
	and ppr.person_reltn_cd = MOTHER_VAR ;156
 
join e where e.person_id = ppr.person_id
	and e.encntr_type_cd = NEWBORN_ENCNTR_TYPE_VAR ; 2555267433
	and (e.reg_dt_tm between cnvtdatetime(rec->mother[d1.seq].preg_start_dt)
		and cnvtdatetime(rec->mother[d1.seq].preg_end_dt))
	and e.active_ind = 1
 
join ea where ea.encntr_id = outerjoin(e.encntr_id)
	and ea.encntr_alias_type_cd = outerjoin(FIN_TYPE_VAR) ;1079
 
join pa where pa.person_id = outerjoin(ppr.person_id)
	and pa.person_alias_type_cd = outerjoin(PMRN_TYPE_VAR) ;10
 
join p where p.person_id = ppr.person_id
 
order by d1.seq, d2.seq, e.encntr_id
 
head report
    bcnt = 0
 
head d1.seq
    bcnt = 0
 
head e.encntr_id
	 bcnt = bcnt + 1
 
	 if ((bcnt <= size (rec->mother[d1.seq].baby ,5)))
		rec->mother[d1.seq].baby[bcnt].baby_fin 	= ea.alias
    	rec->mother[d1.seq].baby[bcnt].baby_mrn 	= pa.alias
		rec->mother[d1.seq].baby[bcnt].person_id	= ppr.person_id
     endif
 
with nocounter
 
;call echorecord(rec)
;go to exitscript
 
 
;==============================================================================
; GET LABOR ROOM DATA
;==============================================================================
free record elh
record elh (
	1 rec [*]
		2 encntr_id = f8
        2 loc_hist [*]
        3 beg_effective_dt_tm = dq8
        3 end_effective_dt_tm = dq8
        3 loc_room_cd = f8
        3 loc_room = vc
  	)
 
set actual_size = size (rec->mother ,5)
set expand_total = (actual_size + (expand_size - mod (actual_size ,expand_size)))
set expand_start = 1
set expand_stop = 200
set expand_num = 0
set stat = alterlist (rec->mother ,expand_total)
 
for (idx = (actual_size + 1) to expand_total)
	set rec->mother[idx].encntr_id = rec->mother[actual_size].encntr_id
endfor
 
select into "nl:"
 	room = uar_get_code_display(eh.loc_room_cd)
 
from ENCNTR_LOC_HIST eh,
  	 (DUMMYT d with seq = value ((expand_total / expand_size)))
 
plan d where assign(expand_start ,evaluate (d.seq ,1 ,1 ,(expand_start + expand_size)))
  	and assign (expand_stop ,(expand_start + (expand_size - 1)))
 
join eh where expand(expand_num ,expand_start ,expand_stop ,eh.encntr_id ,rec->mother[expand_num].encntr_id)
    and eh.active_ind = 1
 
order by eh.encntr_id ,eh.beg_effective_dt_tm
 
head report
	stat = alterlist(rec->mother, actual_size)
    d_cnt = 0
    locv_cnt = 0
 
head eh.encntr_id
   	d_cnt = d_cnt + 1
 
   	if (d_cnt > size (elh->rec,5))
		stat = alterlist (elh->rec, (d_cnt + 9))
	endif
 
   	elh->rec[d_cnt].encntr_id = eh.encntr_id, locv_cnt = 0
 
detail
   	locv_cnt = locv_cnt + 1
 
   	stat = alterlist(elh->rec[d_cnt].loc_hist, locv_cnt)
 
   	elh->rec[d_cnt].loc_hist[locv_cnt].beg_effective_dt_tm	= eh.beg_effective_dt_tm
   	elh->rec[d_cnt].loc_hist[locv_cnt].end_effective_dt_tm 	= eh.end_effective_dt_tm
   	elh->rec[d_cnt].loc_hist[locv_cnt].loc_room_cd 			= eh.loc_room_cd
   	elh->rec[d_cnt].loc_hist[locv_cnt].loc_room 			= room
 
foot report
   	stat = alterlist (elh->rec,d_cnt)
with nocounter
 
for (bl_cnt = 1 to size (rec->mother,5))
    for (elh_cnt = 1 to size (elh->rec,5))
     	if ((rec->mother[bl_cnt].encntr_id = elh->rec[elh_cnt].encntr_id))
      		for (locv_cnt = 1 to size (elh->rec[elh_cnt].loc_hist,5))
       			if ((rec->mother[bl_cnt].baby[1].birth_dt between elh->rec[elh_cnt].loc_hist[locv_cnt].beg_effective_dt_tm
       				and elh->rec[elh_cnt].loc_hist[locv_cnt].end_effective_dt_tm))
        				set rec->mother[bl_cnt].labor_room = elh->rec[elh_cnt].loc_hist[locv_cnt].loc_room
        				set rec->mother[bl_cnt].postpartum_room = elh->rec[elh_cnt].loc_hist[locv_cnt ].loc_room
       			endif
       			if ((rec->mother[bl_cnt].mother_to_dt between elh->rec[elh_cnt].loc_hist[locv_cnt].beg_effective_dt_tm
       				and elh->rec[elh_cnt].loc_hist[locv_cnt].end_effective_dt_tm))
        				set rec->mother[bl_cnt].postpartum_room = elh->rec[elh_cnt].loc_hist[locv_cnt ].loc_room
       			endif
      		endfor
     	endif
    endfor
endfor
 
;call echorecord(elh)
;go to exitscript
 
 
;==============================================================================
; GET GRAVIDA, PARAFULLTERM, PARAPRETERM DATA
;==============================================================================
call echo(build("*** GET GRAVIDA, PARAFULLTERM, PARAPRETERM DATA ***"))
select into "nl:"
	result_val = max(ce.result_val) keep (dense_rank first order by ce.event_end_dt_tm desc) over (partition by ce.person_id)
 
from CLINICAL_EVENT ce
 
where expand(num, 1, size(rec->mother, 5), ce.person_id, rec->mother[num].person_id)
	and ce.event_cd in (GRAVIDA_VAR, PARAFULLTERM_VAR, PARAPRETERM_VAR)
	and ce.result_status_cd in (AUTH_VAR, MODIFIED_VAR, ALTERED_VAR) ;25,34,35
	and ce.valid_until_dt_tm > cnvtdatetime (curdate,curtime3)
 
detail
	idx = 0
	pos = 0
 
	pos = locateval(idx, 1, size(rec->mother,5), ce.person_id, rec->mother[idx].person_id)
 
	while (pos > 0)
		case (ce.event_cd)
			of GRAVIDA_VAR		: rec->mother[pos].gravida		= ce.result_val
			of PARAFULLTERM_VAR	: rec->mother[pos].parafullterm	= ce.result_val
			of PARAPRETERM_VAR	: rec->mother[pos].parapreterm	= ce.result_val
	 	endcase
 
		pos = locateval(idx, pos+1, size(rec->mother,5), ce.person_id, rec->mother[idx].person_id)
	endwhile
 
with nocounter, expand = 1
 
;call echorecord(rec)
;go to exitscript
 
 
;==============================================================================
; GET DIAGNOSIS DATA
;==============================================================================
call echo(build("*** GET DIAGNOSIS DATA ***"))
select into "nl:"
   		diag =
   			IF ((size (trim (d.diagnosis_display)) > 1))
				trim (d.diagnosis_display)
   			ELSEIF ((size (trim (d.diag_ftdesc)) > 1))
				trim (d.diag_ftdesc)
   			ELSE
				trim (n.source_string)
   			ENDIF
from DIAGNOSIS d
 
	,(inner join NOMENCLATURE n on n.nomenclature_id = d.nomenclature_id
		and n.active_ind = 1)
 
where expand(num, 1, size(rec->mother, 5), d.encntr_id, rec->mother[num].encntr_id)
	and d.active_ind = 1
 
detail
	idx = 0
	pos = 0
 
	pos = locateval(idx, 1, size(rec->mother,5), d.encntr_id, rec->mother[idx].encntr_id)
 
	while (pos > 0)
 
    	if ((rec->mother[pos].diagnosis > " "))
			rec->mother[pos].diagnosis = concat(rec->mother[pos].diagnosis, "; " , trim(diag))
    	else
			rec->mother[pos].diagnosis = trim(diag)
    	endif
 
		pos = locateval(idx, pos+1, size(rec->mother,5), d.encntr_id, rec->mother[idx].encntr_id)
	endwhile
 
with nocounter, expand = 1
 
;call echorecord(rec)
;go to exitscript
 
 
;==============================================================================
; GET FEEDING TYPE NEWBORN DATA
;==============================================================================
call echo(build("*** GET FEEDING TYPE DATA ***"))
select into "nl:"
from CLINICAL_EVENT ce
	,(DUMMYT d1 with seq = size(rec->mother, 5))
	,(DUMMYT d2 with seq = 1)
 
plan d1 where maxrec (d2, size(rec->mother[d1.seq].baby, 5))
 
join d2
 
join ce where ce.person_id = rec->mother[d1.seq].baby[d2.seq].person_id
	and ce.event_cd = FEEDING_TYPE_NEWBORN_VAR ;832540
	and ce.valid_until_dt_tm > cnvtdatetime (curdate,curtime3)
	and ce.result_status_cd in (AUTH_VAR, MODIFIED_VAR, ALTERED_VAR) ;25,34,35
 
order by d1.seq, d2.seq, ce.event_end_dt_tm
 
detail
	rec->mother[d1.seq].baby[d2.seq].feeding_type_newborn = ce.result_val
 
with nocounter
 
;call echorecord(rec)
;go to exitscript
 
 
;begin ;002
;==============================================================================
; GET MEASURE BLOOD LOSS (MBL) DATA
;==============================================================================
call echo(build("*** GET MEASURE BLOOD LOSS (MBL) DATA ***"))
select into "nl:"
from CLINICAL_EVENT ce
 
where expand(num, 1, size(rec->mother, 5), ce.encntr_id, rec->mother[num].encntr_id)
	and ce.event_cd = MEASURED_BLOOD_LOSS_VAR ;29968793.00
	and ce.result_status_cd in (AUTH_VAR, MODIFIED_VAR, ALTERED_VAR) ;25,34,35
	and ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3)
 
detail
	idx = 0
	pos = 0
 
	pos = locateval(idx, 1, size(rec->mother,5), ce.encntr_id, rec->mother[idx].encntr_id)
 
	while (pos > 0)
 
		rec->mother[pos].measured_blood_loss = (rec->mother[pos].measured_blood_loss + cnvtint(ce.result_val))
 
		pos = locateval(idx, pos+1, size(rec->mother,5), ce.encntr_id, rec->mother[idx].encntr_id)
	endwhile
 
with nocounter, expand = 1
 
;call echorecord(rec)
;go to exitscript
;end 002
 
 
;==============================================================================
; GET TOBACCO SOCIAL HISTORY DATA
;==============================================================================
call echo(build("*** GET TOBACCO SOCIAL HISTORY DATA ***"))
select into "nl:"
   	ecode = trim(cnvtstring(cv.code_value))
 
from CODE_VALUE cv
 
where cv.code_value IN (TOBACCO_USE_VAR,TOBACCO_AMOUNT_PER_DAY_VAR) ;275233115, 55511811
   	and cv.code_set = SHX_CODE_SET_VAR
 
order by cv.code_value, cv.code_set
 
head report
    hx_tob_use_cnt = 0
    hx_tob_amt_cnt = 0
    hx_tob_cnt = 0
 
detail
    hx_tob_cnt = hx_tob_cnt + 1
 
	if (hx_tob_cnt = 1)
		HX_TOB_PARSER = concat("sr.task_assay_cd in (" ,ecode)
	else
		HX_TOB_PARSER = concat(HX_TOB_PARSER,",",ecode)
	endif
 
    if (cv.code_value = TOBACCO_USE_VAR) ;275233115
		hx_tob_use_cnt = hx_tob_use_cnt + 1
     	if (hx_tob_use_cnt = 1)
			HX_TOB_USE_PARSER = concat("sr.task_assay_cd in (" ,ecode)
     	elseif (hx_tob_use_cnt > 1)
			HX_TOB_USE_PARSER = concat(HX_TOB_USE_PARSER,"," ,ecode)
     	endif
    elseif (cv.code_value = TOBACCO_AMOUNT_PER_DAY_VAR) ;55511811
		hx_tob_amt_cnt = hx_tob_amt_cnt + 1
     	if (hx_tob_amt_cnt = 1)
			HX_TOB_AMT_PARSER = concat("sr.task_assay_cd in (" ,ecode)
     	elseif (hx_tob_amt_cnt > 1)
			HX_TOB_AMT_PARSER = concat(HX_TOB_AMT_PARSER ,"," ,ecode)
     	endif
    endif
 
foot report
    if (hx_tob_use_cnt > 0)
		HX_TOB_USE_PARSER = concat(HX_TOB_USE_PARSER ,")")
    endif,
 
    if (hx_tob_amt_cnt > 0)
		HX_TOB_AMT_PARSER = concat(HX_TOB_AMT_PARSER ,")")
    endif,
 
    if (hx_tob_cnt > 0)
		HX_TOB_PARSER = concat(HX_TOB_PARSER ,")")
    endif
 
with nocounter
 
if ((HX_TOB_USE_PARSER != null) and (HX_TOB_AMT_PARSER != null) and (HX_TOB_PARSER != null))
   	select into "nl:"
    	 dta = trim(uar_get_code_description(sr.task_assay_cd))
		,sr.task_assay_cd
    	,date = format (sa.perform_dt_tm ,"@SHORTDATETIME")
    	,num_response = trim(sr.response_val)
    	,num_uom = trim (uar_get_code_display (sr.response_unit_cd))
    	,alpha_response =
    		if (sar.nomenclature_id > 0)
     			if (trim(n.mnemonic) > " ")
					trim(n.mnemonic)
     			elseif (trim (n.source_string) > " ")
					trim(n.source_string)
     			endif
    		elseif (trim(sar.other_text) > " ")
				trim(sar.other_text)
    		endif
 
    from SHX_ACTIVITY sa
		,SHX_CATEGORY_REF scr
		,SHX_RESPONSE sr
		,SHX_ALPHA_RESPONSE sar
     	,NOMENCLATURE n
     	,(DUMMYT d1 with seq = size (rec->mother ,5))
 
    plan d1
 
    join sa where sa.person_id = rec->mother[d1.seq].person_id
     	and (sa.beg_effective_dt_tm > datetimeadd(cnvtdatetime(rec->mother[d1.seq].baby[1].birth_dt), - (365)))
     	and (sa.end_effective_dt_tm > cnvtdatetime(curdate ,curtime3)
     		and sa.perform_dt_tm <= cnvtdatetime(rec->mother[d1.seq].baby[1].birth_dt))
     	and sa.active_ind = 1
     	and sa.status_cd = SHX_ACTIVE_VAR ;4374372
 
    join scr where scr.shx_category_ref_id = sa.shx_category_ref_id
     	and scr.category_cd = TOBACCO_CD_VAR  ;4374350
 
     join sr where sr.shx_activity_id = sa.shx_activity_id
     	and parser(HX_TOB_PARSER)
 
     join sar where sar.shx_response_id = outerjoin(sr.shx_response_id)
 
     join n where n.nomenclature_id = outerjoin(sar.nomenclature_id)
 
    order by d1.seq, sa.perform_dt_tm desc
 
    head report
     	report_cnt = 0
 
    head d1.seq
     	report_cnt = 0
 
    head sa.perform_dt_tm
     	report_cnt = report_cnt + 1
 
    detail
     	if (report_cnt = 1)
      		if (parser(hx_tob_use_parser))
				rec->mother[d1.seq].tobacco_use = alpha_response
      		elseif (parser(hx_tob_amt_parser))
				rec->mother[d1.seq].tobacco_amt = num_response
      		endif
     	endif
 
    foot  sa.perform_dt_tm
     	if (report_cnt = 1)
			rec->mother[d1.seq].tobacco_dt = sa.perform_dt_tm
		endif
 
		with nocounter
endif
 
;call echorecord(rec)
;go to exitscript
 
 
;==============================================================================
; GET TOBACCO CLINICAL EVENT DATA
;==============================================================================
call echo(build("*** GET TOBACCO CLINICAL EVENT DATA ***"))
declare tr_idx = i4 with noconstant(0)
 
free record tob_rsk
record tob_rsk (
    1 rec [*]
        2 code_value = f8
	)
 
if (TOBACCO_USE_PER_DAY_VAR > 0) ;tobacco type
	set stat = alterlist(tob_rsk->rec ,1)
   	set tob_rsk->rec[1].code_value = TOBACCO_USE_PER_DAY_VAR ;704749
endif
 
if (TOBACCO_LAST_USE_VAR > 0)
   	set stat = alterlist (tob_rsk->rec ,(size (tob_rsk->rec ,5) + 1))
   	set tob_rsk->rec[size(tob_rsk->rec ,5)].code_value = TOBACCO_LAST_USE_VAR ;704770
endif
 
select into "nl:"
from CODE_VALUE cv
 
plan cv where cv.code_set = 72
	and cv.code_value = RF_ANTI_CUR_PREG_VAR ;3613296
    and cv.code_value != 0
 
head report
    tr_cnt = size(tob_rsk->rec ,5)
 
detail
    tr_cnt = tr_cnt + 1
 
    stat = alterlist(tob_rsk->rec ,tr_cnt)
    tob_rsk->rec[tr_cnt].code_value = cv.code_value
 
with nocounter
 
select into "nl:"
from CLINICAL_EVENT ce
	,(DUMMYT d1 with seq = size (rec->mother ,5))
 
plan d1
 
join ce where ce.person_id = rec->mother[d1.seq].person_id
    and expand(tr_idx, 1, size(tob_rsk->rec, 5), ce.event_cd, tob_rsk->rec[tr_idx].code_value)
    and (ce.event_end_dt_tm > datetimeadd(cnvtdatetime (rec->mother[d1.seq].baby[1].birth_dt), - (365))
    and ce.event_end_dt_tm <= cnvtdatetime(rec->mother[d1.seq].baby[1].birth_dt))
    and ce.valid_until_dt_tm > cnvtdatetime(curdate ,curtime3)
 
order by d1.seq, ce.event_end_dt_tm desc
 
head report
    report_cnt = 0
 
head d1.seq
    report_cnt = 0
 
head ce.event_end_dt_tm
    report_cnt = report_cnt + 1
 
    if (not(ce.event_cd in (TOBACCO_USE_PER_DAY_VAR, TOBACCO_LAST_USE_VAR))) ;704749, 704770
		rec->mother[d1.seq].preg_risk_factors = trim(ce.result_val)
    endif
 
detail
    if (report_cnt = 1)
     	if (ce.event_end_dt_tm > cnvtdatetime (rec->mother[d1.seq].tobacco_dt))
      		if (ce.event_cd = TOBACCO_LAST_USE_VAR) ;704770
				rec->mother[d1.seq].tobacco_use = trim(ce.result_val)
      		elseif ((ce.event_cd = TOBACCO_USE_PER_DAY_VAR)) ;704749
				rec->mother[d1.seq].tobacco_amt = trim(ce.result_val)
      		endif
     	endif
    endif
 
foot ce.event_end_dt_tm
    if (report_cnt = 1)
     	if (ce.event_end_dt_tm > cnvtdatetime(rec->mother[d1.seq].tobacco_dt))
			rec->mother[d1.seq].tobacco_dt = ce.event_end_dt_tm
     	endif
    endif
 
with nocounter
 
;call echorecord(rec)
;go to exitscript
 
 
;============================
; REPORT OUTPUT
;============================
if (rec->rec_cnt > 0)
 
	select distinct into value ($OUTDEV)
;		 fac			      			= rec->mother[d.seq].facility_abbr
		 mother_name	   				= substring(1,50,rec->mother[d.seq].mother_name)
;		 mother_name	   				= substring(1,50,if(rec->mother[d.seq].mother_name_hist_type != "Current")
;											concat(rec->mother[d.seq].mother_name, " *") else rec->mother[d.seq].mother_name endif)
;		,mother_name_hist  				= substring(1,50,rec->mother[d.seq].mother_name_hist)
;		,mother_name_hist_type			= substring(1,50,rec->mother[d.seq].mother_name_hist_type)
		,admit_dt						= format(rec->mother[d.seq].mother_admit_dt, "mm/dd/yyyy hh:mm;;q")
		,discharge_dt					= format(rec->mother[d.seq].mother_discharge_dt, "mm/dd/yyyy hh:mm;;q")
		,fin#		   					= rec->mother[d.seq].mother_fin
		,mrn_id_number					= if(rec->mother[d.seq].baby[d2.seq].baby_band_num != null)
											substring(1,20,concat(rec->mother[d.seq].mother_mrn,
												"/", rec->mother[d.seq].baby[d2.seq].baby_band_num))
											else substring(1,10,rec->mother[d.seq].mother_mrn) endif
		,race							= substring(1,50,rec->mother[d.seq].mother_race)
		,age							= substring(1,4,cnvtage(rec->mother[d.seq].mother_age))
		,gravida						= rec->mother[d.seq].gravida
		,para_full_term					= rec->mother[d.seq].parafullterm
		,para_pre_term					= rec->mother[d.seq].parapreterm
		,ega							= substring(1,50,rec->mother[d.seq].ega)
		,diagnosis						= substring(1,300,rec->mother[d.seq].diagnosis)
		,birth_dt						= format(rec->mother[d.seq].baby[d2.seq].birth_dt, "mm/dd/yyyy hh:mm;;q")
		,delivery_type					= substring(1,100,rec->mother[d.seq].baby[d2.seq].delivery_type)
		,induction_method				= substring(1,100,replace(replace(rec->mother[d.seq].induction_method,
											char(13), " ", 0), char(10), " ", 0))
		,augmentation_method			= substring(1,100,replace(replace(rec->mother[d.seq].augmentation_method,
											char(13), " ", 0), char(10), " ", 0))
		,previous_cs					= substring(1,100,replace(replace(rec->mother[d.seq].previous_cs,
											char(13), " ", 0), char(10), " ", 0))
		,cs_indications					= substring(1,100,rec->mother[d.seq].cs_indications)
		,rom_dt							= format(rec->mother[d.seq].baby[d2.seq].rom_dt, "mm/dd/yyyy hh:mm;;q")
		,rom_type						= substring(1,100,rec->mother[d.seq].baby[d2.seq].rom_type)
		,amniotic_fluid_desc			= substring(1,100,rec->mother[d.seq].baby[d2.seq].amniotic_fluid)
		,anesthesia_type				= substring(1,100,rec->mother[d.seq].anesthesia_type)
		,presenting_part				= substring(1,100,rec->mother[d.seq].presenting_part)
		,laceration						= substring(1,100,rec->mother[d.seq].laceration)
		,episiotomy						= substring(1,100,rec->mother[d.seq].episiotomy)
		,placenta_delivery_dt			= format(rec->mother[d.seq].baby[d2.seq].placenta_delivery_dt, "mm/dd/yyyy hh:mm;;q")
		,delivery_ebl					= if(rec->mother[d.seq].estimated_blood_loss != null)
											substring(1,20,concat(rec->mother[d.seq].estimated_blood_loss, " mL")) else null endif
		,total_mbl						= if(rec->mother[d.seq].measured_blood_loss != null)
											substring(1,20,concat(trim(cnvtstring(rec->mother[d.seq].measured_blood_loss)), " mL")) else null endif ;002
		,aborh_lab_resulted				= substring(1,20,rec->mother[d.seq].aborh)
		,transcribed_blood_type			= substring(1,100,rec->mother[d.seq].transcribed_blood_type)
		,risk_factors_current_pregnancy	= substring(1,255,replace(replace(rec->mother[d.seq].preg_risk_factors,
											char(13), " ", 0), char(10), " ", 0))
		,maternal_delivery_comp			= substring(1,100,replace(replace(rec->mother[d.seq].baby[d2.seq].maternal_delivery_comp,
											char(13), " ", 0), char(10), " ", 0))
		,mother_to						= substring(1,100,rec->mother[d.seq].mother_to)
		,labor_room						= substring(1,20,rec->mother[d.seq].labor_room)
		,postpartum_room				= substring(1,20,rec->mother[d.seq].postpartum_room)
		,newborn_birth_sex				= substring(1,10,rec->mother[d.seq].baby[d2.seq].newborn_birth_sex)
		,birth_weight_g					= substring(1,10,rec->mother[d.seq].baby[d2.seq].birth_weight)
		,baby_fin						= substring(1,10,rec->mother[d.seq].baby[d2.seq].baby_fin)
		,baby_mrn						= substring(1,10,rec->mother[d.seq].baby[d2.seq].baby_mrn)
		,newborn_outcome				= substring(1,255,rec->mother[d.seq].baby[d2.seq].neo_outcome)
		,newborn_complications			= substring(1,255,replace(replace(rec->mother[d.seq].baby[d2.seq].neo_complications,
											char(13), " ", 0), char(10), " ", 0))
		,risk_factors					= substring(1,100,replace(replace(rec->mother[d.seq].risk_factors,
											char(13), " ", 0), char(10), " ", 0))
		,apgar_1_min					= substring(1,10,rec->mother[d.seq].baby[d2.seq].apgar_1min)
		,apgar_5_min					= substring(1,10,rec->mother[d.seq].baby[d2.seq].apgar_5min)
		,apgar_10_min					= substring(1,10,rec->mother[d.seq].baby[d2.seq].apgar_10min)
		,apgar_15_min					= substring(1,10,rec->mother[d.seq].baby[d2.seq].apgar_15min)
		,apgar_20_min					= substring(1,10,rec->mother[d.seq].baby[d2.seq].apgar_20min)
		,cord_blood_ph_drawn			= substring(1,50,rec->mother[d.seq].baby[d2.seq].cord_blood_ph)
		,cord_blood_banking				= substring(1,50,rec->mother[d.seq].baby[d2.seq].cord_blood_banking)
		,feeding_type_newborn			= substring(1,50,rec->mother[d.seq].baby[d2.seq].feeding_type_newborn)
		,newborn_to						= substring(1,50,rec->mother[d.seq].baby[d2.seq].newborn_to)
		,fhr_mon						= substring(1,50,rec->mother[d.seq].baby[d2.seq].fhr_mon)
		,uc_mon							= substring(1,50,rec->mother[d.seq].uc_mon)
		,tobacco_use					= substring(1,100,rec->mother[d.seq].tobacco_use)
		,tobacco_amt					= substring(1,100,rec->mother[d.seq].tobacco_amt)
		,labor_onset_dt					= format(rec->mother[d.seq].labor_onset_dt, "mm/dd/yyyy hh:mm;;q")
		,rom_to_delivery_hrs			= substring(1,10,rec->mother[d.seq].baby[d2.seq].rom_to_delivery_hrs)
		,length_labor_2nd_stage_hrs		= substring(1,10,rec->mother[d.seq].baby[d2.seq].Length_Labor_2nd_Stage)
		,length_labor_3rd_stage_mins	= substring(1,10,rec->mother[d.seq].baby[d2.seq].Length_Labor_3rd_Stage)
		,nitrous_used					= if(rec->mother[d.seq].nitrous_used = "Initiated") "Yes" else "" endif
		,delivery_provider				= substring(1,50,rec->mother[d.seq].baby[d2.seq].delivery_provider)
		,assistant_physician_1			= substring(1,50,rec->mother[d.seq].baby[d2.seq].assistant_physician_1)
		,assistant_physician_2			= substring(1,50,rec->mother[d.seq].baby[d2.seq].assistant_physician_2)
		,delivery_rn_#1					= substring(1,50,rec->mother[d.seq].baby[d2.seq].delivery_rn_1)
		,delivery_rn_#2					= substring(1,50,rec->mother[d.seq].baby[d2.seq].delivery_rn_2)
		,nursery_baby_nurse				= substring(1,50,rec->mother[d.seq].baby[d2.seq].nursery_baby_nurse) ;003
		,anesthesiologist				= substring(1,50,rec->mother[d.seq].baby[d2.seq].anesth_attending)
		,anesthetist					= substring(1,50,rec->mother[d.seq].baby[d2.seq].anesthetist)
		,hospital_pediatrician			= substring(1,50,rec->mother[d.seq].hospital_pediatrician)
		,followup_pediatrician			= substring(1,50,replace(replace(rec->mother[d.seq].followup_pediatrician,
											char(13), " ", 0), char(10), " ", 0))
		,resus_rn_#1					= substring(1,50,rec->mother[d.seq].baby[d2.seq].resuscitation_rn_1)
		,facility_desc 					= substring(1,50,rec->mother[d.seq].facility_desc)
;;		,attending_physician			= substring(1,50,rec->mother[d.seq].attending_physician)  ;no data comment-out
;		,preg_start_dt					= format(rec->mother[d.seq].preg_start_dt, "mm/dd/yyyy hh:mm;;q")
;		,preg_end_dt					= format(rec->mother[d.seq].preg_end_dt, "mm/dd/yyyy hh:mm;;q")
;		,person_id						= rec->mother[d.seq].person_id
;		,baby_person_id					= rec->mother[d.seq].baby[d2.seq].person_id
;		,encntr_id     					= rec->mother[d.seq].encntr_id
;		,pregnancy_id     				= rec->mother[d.seq].pregnancy_id
;		,encntr_cnt	   					= rec->encntr_cnt
;		,username      					= rec->username
;		,startdate_pmpt					= rec->startdate
;		,enddate_pmpt  					= rec->enddate
 
	from
		 (DUMMYT d  with seq = value(size(rec->mother,5)))
		,(DUMMYT d2 with seq = 1)
 
	plan d
		where maxrec(d2, size(rec->mother[d.seq].baby,5))
 
	join d2
 
;	order by mother_name, rec->mother[d.seq].baby[d2.seq].birth_dt desc, rec->mother[d.seq].encntr_id,
;		rec->mother[d.seq].event_id, rec->mother[d.seq].baby[d2.seq].event_id, rec->mother[d.seq].baby[d2.seq].person_id
	order by rec->mother[d.seq].baby[d2.seq].birth_dt desc, mother_name, rec->mother[d.seq].encntr_id,
		rec->mother[d.seq].event_id, rec->mother[d.seq].baby[d2.seq].event_id, rec->mother[d.seq].baby[d2.seq].person_id
 
	with nocounter, format, check, separator = " ", outerjoin(d2)
 
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
 
