 
DROP PROGRAM 2_cov_him_mak_defic_by_phys GO
CREATE PROGRAM 2_cov_him_mak_defic_by_phys
 
/*****************************************************************************
 
        Source file name:       1_cov_him_mak_defic_by_phys.prg
        Object name:            1_cov_him_mak_defic_by_phys
 
        Program purpose:        This was copied from the standard
                                him_mak_defic_by_phys_det_lyt report.  The output
                                format was changed so it can be easily imported
                                into Excel.
 
 
        Executing from:         explorermenu
                                ,reporting portal
 
******************************************************************************/
 
 
;*****************************************************************************
;    *                      GENERATED MODIFICATION CONTROL LOG               *
;    *************************************************************************
;    *                                                                       *
;    *Mod Date     Engineer     Comment                                      *
;    *--- -------- ------------ -------------------------------------------- *
;    *001 8/15/18  AJF           Initial Release                   			 *
;    *002 8/20/18  AJF			 Added personnel position code and Star ID   *
;*****************************************************************************
 
 prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Facility(ies)" = 0
 
with OUTDEV, ORGANIZATIONS
 EXECUTE reportrtl
 IF ((validate (i18nuar_def ,999 ) = 999 ) )
  CALL echo ("Declaring i18nuar_def" )
  DECLARE i18nuar_def = i2 WITH persist
  SET i18nuar_def = 1
  DECLARE uar_i18nlocalizationinit ((p1 = i4 ) ,(p2 = vc ) ,(p3 = vc ) ,(p4 = f8 ) ) = i4 WITH
  persist
  DECLARE uar_i18ngetmessage ((p1 = i4 ) ,(p2 = vc ) ,(p3 = vc ) ) = vc WITH persist
  DECLARE uar_i18nbuildmessage () = vc WITH persist
  DECLARE uar_i18ngethijridate ((imonth = i2 (val ) ) ,(iday = i2 (val ) ) ,(iyear = i2 (val ) ) ,(
   sdateformattype = vc (ref ) ) ) = c50 WITH image_axp = "shri18nuar" ,image_aix =
  "libi18n_locale.a(libi18n_locale.o)" ,uar = "uar_i18nGetHijriDate" ,persist
  DECLARE uar_i18nbuildfullformatname ((sfirst = vc (ref ) ) ,(slast = vc (ref ) ) ,(smiddle = vc (
    ref ) ) ,(sdegree = vc (ref ) ) ,(stitle = vc (ref ) ) ,(sprefix = vc (ref ) ) ,(ssuffix = vc (
    ref ) ) ,(sinitials = vc (ref ) ) ,(soriginal = vc (ref ) ) ) = c250 WITH image_axp =
  "shri18nuar" ,image_aix = "libi18n_locale.a(libi18n_locale.o)" ,uar = "i18nBuildFullFormatName" ,
  persist
  DECLARE uar_i18ngetarabictime ((ctime = vc (ref ) ) ) = c20 WITH image_axp = "shri18nuar" ,
  image_aix = "libi18n_locale.a(libi18n_locale.o)" ,uar = "i18n_GetArabicTime" ,persist
 ENDIF
 DECLARE fillqualwithfacilitynames ((organizations = vc (ref ) ) ) = null WITH protect
 DECLARE himgetnamesforcodevalues ((data = vc (ref ) ) ) = null WITH protect
 DECLARE himgetnamesfromtable ((data = vc (ref ) ) ,(tablename = vc ) ,(name = vc ) ,(id = vc ) ) =
 null WITH protect
 DECLARE getdatafromprompt ((parameternumber = i1 ) ,(data = vc (ref ) ) ) = null WITH protect
 DECLARE himrendernodatareport ((datasize = i4 ) ,(outputdevice = vc ) ) = i1 WITH protect
 DECLARE i1multifacilitylogicind = i1 WITH noconstant (0 ) ,protect
 DECLARE i2multifacilitylogicind = i2 WITH noconstant (0 ) ,protect
 DECLARE f8daterangeadd = f8 WITH constant (0.99998842592592592592592592592593 ) ,protect
 DECLARE i18nallfacilities = vc WITH noconstant ("" ) ,protect
 SET i18nhandlehim = 0
 SET lretval = uar_i18nlocalizationinit (i18nhandlehim ,curprog ,"" ,curcclrev )
 SET i18nallfacilities = uar_i18ngetmessage (i18nhandlehim ,"HIM_PRMPT_KEY_0" ,"All Facilities" )
 SELECT INTO "nl:"
  FROM (him_system_params h )
  WHERE (h.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
  AND (h.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime3 ) )
  AND (h.active_ind = 1 )
  HEAD REPORT
   i2multifacilitylogicind = h.facility_logic_ind
  DETAIL
   row + 0
  WITH nocounter
 ;end select
   CALL echo(build("i2multifacilitylogicind",i2multifacilitylogicind,char(0)))
 IF ((i2multifacilitylogicind != 0 ) )
  SET i1multifacilitylogicind = 1
 ELSE
  SELECT INTO "nl:"
   sec_ind = cnvtint (d.info_number )
   FROM (dm_info d )
   WHERE (d.info_domain = "SECURITY" )
   AND (d.info_name = "SEC_ORG_RELTN" )
   DETAIL
    i1multifacilitylogicind = sec_ind
   WITH nocounter
  ;end select
  IF ((i1multifacilitylogicind != 0 ) )
   SET i1multifacilitylogicind = 1
  ENDIF
 ENDIF
 SUBROUTINE  getdatafromprompt (parameternumber ,data )
  SET inputnum = parameternumber
  SET ctype = reflect (parameter (inputnum ,0 ) )
  SET parnum = 0
  SET nstop = cnvtint (substring (2 ,19 ,ctype ) )
  IF ((nstop > 0 ) )
   CASE (substring (1 ,1 ,ctype ) )
    OF "C" :
     SET vcparameterdata = parameter (inputnum ,parnum )
     IF ((vcparameterdata != "" ) )
      SET stat = alterlist (data->qual ,1 )
      SET data->qual[1 ].item_name = vcparameterdata
     ENDIF
    OF "F" :
     SET f8parameterdata = parameter (inputnum ,parnum )
     IF ((f8parameterdata != 0 ) )
      SET stat = alterlist (data->qual ,1 )
      SET data->qual[1 ].item_id = f8parameterdata
     ENDIF
    OF "I" :
     SET i4parameterdata = parameter (inputnum ,parnum )
     IF ((i4parameterdata != 0 ) )
      SET stat = alterlist (data->qual ,1 )
      SET data->qual[1 ].item_id = i4parameterdata
     ENDIF
    OF "L" :
     SET stat = alterlist (data->qual ,nstop )
     WHILE ((parnum < nstop ) )
      SET parnum = (parnum + 1 )
      SET data->qual[parnum ].item_id = parameter (inputnum ,parnum )
     ENDWHILE
    ELSE
     SET nothing = null
   ENDCASE
  ENDIF
 END ;Subroutine
 SUBROUTINE  fillqualwithfacilitynames (organizations )
  CALL himgetnamesfromtable (organizations ,"organization" ,"org_name" ,"organization_id" )
 END ;Subroutine
 SUBROUTINE  himgetnamesforcodevalues (data )
  FOR (index = 1 TO size (data->qual ,5 ) )
   SET data->qual[index ].item_name = uar_get_code_display (data->qual[index ].item_id )
  ENDFOR
 END ;Subroutine
 SUBROUTINE  himgetnamesfromtable (data ,tablename ,name ,id )
  DECLARE i4datacount = i4 WITH noconstant (size (data->qual ,5 ) ) ,protect
  DECLARE i4dataindex = i4 WITH noconstant (0 ) ,protect
  CALL parser (build2 ('select into "nl:"' ," DATA_NAME = substring(1,200,d." ,name ,")" ,
    ",DATA_ID = d." ,id ," " ," from " ,tablename ," d " ," where " ,
    "expand(i4DataIndex, 1, i4DataCount," ,"d." ,id ,", data->qual[i4DataIndex].item_id)" ,
    " order DATA_NAME, DATA_ID " ," head report " ,"		i4DataIndex = 0 " ," head DATA_ID " ,
    " i4DataIndex = i4DataIndex + 1 " ," data->qual[i4DataIndex].item_name = DATA_NAME " ,
    " data->qual[i4DataIndex].item_id = DATA_ID " ," detail row+0 with noCounter go" ) )
 END ;Subroutine
 SUBROUTINE  himrendernodatareport (datasize ,outputdevice )
  IF ((datasize = 0 ) )
   EXECUTE reportrtl
   SELECT INTO  $OUTDEV
    FROM (dual d )
    HEAD REPORT
     col 0 ,
     "No data found."
    WITH nocounter
   ;end select
   RETURN (1 )
  ELSE
   RETURN (0 )
  ENDIF
 END ;Subroutine
 DECLARE crlf = c2 WITH constant (concat (char (13 ) ,char (10 ) ) ) ,protect
 DECLARE space = c1 WITH constant (char (9 ) ) ,protect
 DECLARE him_program_name = vc WITH constant (request->program_name ) ,protect
 DECLARE him_window = i1 WITH constant (1 ) ,protect
 DECLARE him_render_params = vc WITH constant (
  IF (findstring ("," ,request->params ) ) build ("mine" ,substring (findstring ("," ,request->params
       ) ,textlen (request->params ) ,replace (request->params ,'"' ,"^" ,0 ) ) )
  ELSE "mine"
  ENDIF
  ) ,protect
 DECLARE him_prompt = i1 WITH constant (0 ) ,protect
 DECLARE him_dash = i1 WITH constant (1 ) ,protect
 DECLARE vctodaydatetime = vc WITH noconstant ("" ) ,protect
 DECLARE vcuser = vc WITH noconstant ("                " ) ,protect
 DECLARE i18ndateprinted = vc WITH noconstant ("" ) ,protect
 DECLARE i18nuserprinted = vc WITH noconstant ("" ) ,protect
 DECLARE i18npromptsfilters = vc WITH noconstant ("" ) ,protect
 DECLARE i18nfacilities = vc WITH noconstant ("" ) ,protect
 DECLARE i18ndaterange = vc WITH noconstant ("" ) ,protect
 DECLARE i18nto = vc WITH noconstant ("" ) ,protect
 DECLARE i18nfrom = vc WITH noconstant ("" ) ,protect
 DECLARE i18nrequestlocation = vc WITH noconstant ("" ) ,protect
 DECLARE makelistofqualitemnames ((data = vc (ref ) ) ,(default = vc ) ) = vc WITH protect
 DECLARE getdaterangedisplay ((dates = vc (ref ) ) ,(type = i1 ) ) = vc WITH protect
 DECLARE cnvtminstodayshoursmins ((mins = i4 ) ) = vc WITH protect
 EXECUTE reportrtl
 SET vctodaydatetime = format (cnvtdatetime (curdate ,curtime3 ) ,"@SHORTDATETIME;;Q" )
 SET i18ndateprinted = uar_i18ngetmessage (i18nhandlehim ,"HIM_LYT_KEY_0" ,"Date Printed:" )
 SET i18nuserprinted = uar_i18ngetmessage (i18nhandlehim ,"HIM_LYT_KEY_1" ,"User Who Printed:" )
 SET i18npromptsfilters = uar_i18ngetmessage (i18nhandlehim ,"HIM_LYT_KEY_2" ,"Prompts/Filters:" )
 SET i18nfacilities = uar_i18ngetmessage (i18nhandlehim ,"HIM_LYT_KEY_3" ,"Facility(ies):" )
 SET i18ndaterange = uar_i18ngetmessage (i18nhandlehim ,"HIM_LYT_KEY_4" ,"Date Range:" )
 SET i18nfrom = uar_i18ngetmessage (i18nhandlehim ,"HIM_LYT_KEY_5" ,"From" )
 SET i18nto = uar_i18ngetmessage (i18nhandlehim ,"HIM_LYT_KEY_6" ,"To" )
 SET i18nrequestlocation = uar_i18ngetmessage (i18nhandlehim ,"HIM_LYT_KEY_7" ,
  "Requesting Location:" )
 SELECT INTO "nl:"
  FROM (prsnl p )
  WHERE (p.person_id = reqinfo->updt_id )
  AND (p.active_ind = 1 )
  DETAIL
   vcuser = p.name_full_formatted
  WITH nocounter ,maxqual (p ,1 )
 ;end select
 SUBROUTINE  getdaterangedisplay (dates ,type )
  DECLARE vcfilterdaterange = vc WITH noconstant ("" ) ,private
  CASE (type )
   OF him_prompt :
    IF ((cnvtdate (dates->beginning_date ) > 0 )
    AND (cnvtdate (dates->ending_date ) > 0 ) )
     SET vcfilterdaterange = build2 (i18nfrom ," " ,format (dates->beginning_date ,"@SHORTDATE;;Q" )
      ," " ," " ,i18nto ," " ,format (dates->ending_date ,"@SHORTDATE;;Q" ) )
    ELSE
     SET vcfilterdaterange = uar_i18ngetmessage (i18nhandlehim ,"NORANGE1" ,"No Range" )
    ENDIF
   OF him_dash :
    IF ((cnvtdate (dates->beginning_date ) > 0 )
    AND (cnvtdate (dates->ending_date ) > 0 ) )
     SET vcfilterdaterange = build2 (format (dates->beginning_date ,"@SHORTDATE;;Q" ) ," -  " ,
      format (dates->ending_date ,"@SHORTDATE;;Q" ) )
    ELSE
     SET vcfilterdaterange = uar_i18ngetmessage (i18nhandlehim ,"NORANGE2" ,"NO RANGE" )
    ENDIF
   ELSE
    SET vcfilterdaterange = uar_i18ngetmessage (i18nhandlehim ,"NODATESFOUND" ,"No Dates Found" )
  ENDCASE
  RETURN (vcfilterdaterange )
 END ;Subroutine
 SUBROUTINE  cnvtminstodayshoursmins (mins )
  DECLARE hours = i4 WITH noconstant (0 ) ,protect
  DECLARE days = i4 WITH noconstant (0 ) ,protect
  DECLARE vctime = vc WITH noconstant ("" ) ,protect
  SET days = (mins / (60 * 24 ) )
  IF ((days < 1 ) )
   SET mins = mod (mins ,(60 * 24 ) )
   SET hours = (mins / 60 )
   SET mins = mod (mins ,60 )
   SET vctime = build2 (format (hours ,"##;P0" ) ," hrs " ,format (mins ,"##;P0" ) ," mins" )
  ELSE
   SET vctime = build2 (days ," days " )
  ENDIF
  RETURN (vctime )
 END ;Subroutine
 SUBROUTINE  makelistofqualitemnames (data ,default )
  DECLARE i4linecount = i4 WITH noconstant (1 ) ,protect
  DECLARE i4qualcount = i4 WITH noconstant (size (data->qual ,5 ) ) ,protect
  DECLARE i4count = i4 WITH noconstant (1 ) ,protect
  DECLARE list = vc WITH noconstant (" " ) ,protect
  IF ((i4qualcount = 0 ) )
   SET list = default
  ELSE
   FOR (i4count = 1 TO i4qualcount )
    IF ((i4count = i4qualcount ) )
     IF ((size (trim (data->qual[i4count ].item_name ,3 ) ) > 0 ) )
      SET list = build2 (list ,trim (data->qual[i4count ].item_name ,3 ) )
     ENDIF
    ELSE
     IF ((size (trim (data->qual[i4count ].item_name ,3 ) ) > 0 ) )
      SET list = build2 (list ,trim (data->qual[i4count ].item_name ,3 ) ,"; " )
     ENDIF
    ENDIF
   ENDFOR
  ENDIF
  RETURN (list )
 END ;Subroutine
 FREE RECORD organizations
 RECORD organizations (
   1 qual [* ]
     2 item_id = f8
     2 item_name = vc
 )
 FREE RECORD physicians
 RECORD physicians (
   1 qual [* ]
     2 item_id = f8
     2 item_name = vc
 )
 FREE RECORD data
 RECORD data (
   1 qual [* ]
     2 patient_name = vc
     2 patient_id = f8
     2 patient_type_cd = f8
     2 organization_name = vc
     2 organization_id = f8
     2 mrn = vc
     2 fin = vc
     2 physician_name = vc
     2 physician_id = f8
     2 encntr_id = f8
     2 chart_alloc_dt_tm = dq8
     2 chart_age = i4
     2 disch_dt_tm = dq8
     2 location = vc
     2 patient_abs_birth_dt_tm = dq8
     2 patient_active_ind = i2
     2 patient_active_status_cd = f8
     2 patient_active_status_dt_tm = dq8
     2 patient_active_status_prsnl_id = f8
     2 patient_archive_env_id = f8
     2 patient_archive_status_cd = f8
     2 patient_archive_status_dt_tm = dq8
     2 patient_autopsy_cd = f8
     2 patient_beg_effective_dt_tm = dq8
     2 patient_birth_dt_cd = f8
     2 patient_birth_dt_tm = dq8
     2 patient_birth_prec_flag = i2
     2 patient_birth_tz = i4
     2 patient_cause_of_death = vc
     2 patient_cause_of_death_cd = f8
     2 patient_citizenship_cd = f8
     2 patient_conception_dt_tm = dq8
     2 patient_confid_level_cd = f8
     2 patient_contributor_system_cd = f8
     2 patient_create_dt_tm = dq8
     2 patient_create_prsnl_id = f8
     2 patient_data_status_cd = f8
     2 patient_data_status_dt_tm = dq8
     2 patient_data_status_prsnl_id = f8
     2 patient_deceased_cd = f8
     2 patient_deceased_dt_tm = dq8
     2 patient_deceased_source_cd = f8
     2 patient_end_effective_dt_tm = dq8
     2 patient_ethnic_grp_cd = f8
     2 patient_ft_entity_id = f8
     2 patient_ft_entity_name = c32
     2 patient_language_cd = f8
     2 patient_language_dialect_cd = f8
     2 patient_last_accessed_dt_tm = dq8
     2 patient_last_encntr_dt_tm = dq8
     2 patient_marital_type_cd = f8
     2 patient_military_base_location = vc
     2 patient_military_rank_cd = f8
     2 patient_military_service_cd = f8
     2 patient_mother_maiden_name = vc
     2 patient_name_first = vc
     2 patient_name_first_key = vc
     2 patient_name_first_key_nls = vc
     2 patient_name_first_phonetic = c8
     2 patient_name_first_synonym_id = f8
     2 patient_name_full_formatted = vc
     2 patient_name_last = vc
     2 patient_name_last_key = vc
     2 patient_name_last_key_nls = vc
     2 patient_name_last_phonetic = c8
     2 patient_name_middle = vc
     2 patient_name_middle_key = vc
     2 patient_name_middle_key_nls = vc
     2 patient_name_phonetic = c8
     2 patient_nationality_cd = f8
     2 patient_next_restore_dt_tm = dq8
     2 patient_person_id = f8
     2 patient_person_type_cd = f8
     2 patient_race_cd = f8
     2 patient_religion_cd = f8
     2 patient_sex_age_change_ind = i2
     2 patient_sex_cd = f8
     2 patient_species_cd = f8
     2 patient_updt_dt_tm = dq8
     2 patient_updt_id = f8
     2 patient_updt_task = i4
     2 patient_vet_military_status_cd = f8
     2 patient_vip_cd = f8
     2 physician_active_ind = i2
     2 physician_active_status_cd = f8
     2 physician_active_status_dt_tm = dq8
     2 physician_active_status_prsnl_id = f8
     2 physician_beg_effective_dt_tm = dq8
     2 physician_contributor_system_cd = f8
     2 physician_create_dt_tm = dq8
     2 physician_create_prsnl_id = f8
     2 physician_data_status_cd = f8
     2 physician_data_status_dt_tm = dq8
     2 physician_data_status_prsnl_id = f8
     2 physician_email = vc
     2 physician_end_effective_dt_tm = dq8
     2 physician_ft_entity_id = f8
     2 physician_ft_entity_name = c32
     2 physician_name_first = vc
     2 physician_name_first_key = vc
     2 physician_name_first_key_nls = vc
     2 physician_name_full_formatted = vc
     2 physician_name_last = vc
     2 physician_name_last_key = vc
     2 physician_name_last_key_nls = vc
     2 physician_password = vc
     2 physician_person_id = f8
     2 physician_physician_ind = i2
     2 physician_physician_status_cd = f8
     2 physician_position_cd = f8
     2 physician_prim_assign_loc_cd = f8
     2 physician_prsnl_type_cd = f8
     2 physician_updt_dt_tm = dq8
     2 physician_updt_id = f8
     2 physician_updt_task = i4
     2 physician_username = vc
     2 physician_star_id = vc
     2 encntr_accommodation_cd = f8
     2 encntr_accommodation_reason_cd = f8
     2 encntr_accommodation_request_cd = f8
     2 encntr_accomp_by_cd = f8
     2 encntr_active_ind = i2
     2 encntr_active_status_cd = f8
     2 encntr_active_status_dt_tm = dq8
     2 encntr_active_status_prsnl_id = f8
     2 encntr_admit_mode_cd = f8
     2 encntr_admit_src_cd = f8
     2 encntr_admit_type_cd = f8
     2 encntr_admit_with_medication_cd = f8
     2 encntr_alc_decomp_dt_tm = dq8
     2 encntr_alc_reason_cd = f8
     2 encntr_alt_lvl_care_cd = f8
     2 encntr_alt_lvl_care_dt_tm = dq8
     2 encntr_ambulatory_cond_cd = f8
     2 encntr_archive_dt_tm_act = dq8
     2 encntr_archive_dt_tm_est = dq8
     2 encntr_arrive_dt_tm = dq8
     2 encntr_assign_to_loc_dt_tm = dq8
     2 encntr_bbd_procedure_cd = f8
     2 encntr_beg_effective_dt_tm = dq8
     2 encntr_chart_complete_dt_tm = dq8
     2 encntr_confid_level_cd = f8
     2 encntr_contract_status_cd = f8
     2 encntr_contributor_system_cd = f8
     2 encntr_courtesy_cd = f8
     2 encntr_create_dt_tm = dq8
     2 encntr_create_prsnl_id = f8
     2 encntr_data_status_cd = f8
     2 encntr_data_status_dt_tm = dq8
     2 encntr_data_status_prsnl_id = f8
     2 encntr_depart_dt_tm = dq8
     2 encntr_diet_type_cd = f8
     2 encntr_disch_disposition_cd = f8
     2 encntr_disch_dt_tm = dq8
     2 encntr_disch_to_loctn_cd = f8
     2 encntr_doc_rcvd_dt_tm = dq8
     2 encntr_encntr_class_cd = f8
     2 encntr_encntr_complete_dt_tm = dq8
     2 encntr_encntr_financial_id = f8
     2 encntr_encntr_id = f8
     2 encntr_encntr_status_cd = f8
     2 encntr_encntr_type_cd = f8
     2 encntr_encntr_type_class_cd = f8
     2 encntr_end_effective_dt_tm = dq8
     2 encntr_est_arrive_dt_tm = dq8
     2 encntr_est_depart_dt_tm = dq8
     2 encntr_est_length_of_stay = i4
     2 encntr_financial_class_cd = f8
     2 encntr_guarantor_type_cd = f8
     2 encntr_info_given_by = c100
     2 encntr_inpatient_admit_dt_tm = dq8
     2 encntr_isolation_cd = f8
     2 encntr_location_cd = f8
     2 encntr_loc_bed_cd = f8
     2 encntr_loc_building_cd = f8
     2 encntr_loc_facility_cd = f8
     2 encntr_loc_nurse_unit_cd = f8
     2 encntr_loc_room_cd = f8
     2 encntr_loc_temp_cd = f8
     2 encntr_med_service_cd = f8
     2 encntr_mental_category_cd = f8
     2 encntr_mental_health_dt_tm = dq8
     2 encntr_organization_id = f8
     2 encntr_parent_ret_criteria_id = f8
     2 encntr_patient_classification_cd = f8
     2 encntr_pa_current_status_cd = f8
     2 encntr_pa_current_status_dt_tm = dq8
     2 encntr_person_id = f8
     2 encntr_placement_auth_prsnl_id = f8
     2 encntr_preadmit_testing_cd = f8
     2 encntr_pre_reg_dt_tm = dq8
     2 encntr_pre_reg_prsnl_id = f8
     2 encntr_program_service_cd = f8
     2 encntr_psychiatric_status_cd = f8
     2 encntr_purge_dt_tm_act = dq8
     2 encntr_purge_dt_tm_est = dq8
     2 encntr_readmit_cd = f8
     2 encntr_reason_for_visit = vc
     2 encntr_referral_rcvd_dt_tm = dq8
     2 encntr_referring_comment = vc
     2 encntr_refer_facility_cd = f8
     2 encntr_region_cd = f8
     2 encntr_reg_dt_tm = dq8
     2 encntr_reg_prsnl_id = f8
     2 encntr_result_accumulation_dt_tm = dq8
     2 encntr_safekeeping_cd = f8
     2 encntr_security_access_cd = f8
     2 encntr_service_category_cd = f8
     2 encntr_sitter_required_cd = f8
     2 encntr_specialty_unit_cd = f8
     2 encntr_trauma_cd = f8
     2 encntr_trauma_dt_tm = dq8
     2 encntr_triage_cd = f8
     2 encntr_triage_dt_tm = dq8
     2 encntr_updt_dt_tm = dq8
     2 encntr_updt_id = f8
     2 encntr_updt_task = i4
     2 encntr_valuables_cd = f8
     2 encntr_vip_cd = f8
     2 encntr_visitor_status_cd = f8
     2 encntr_zero_balance_dt_tm = dq8
     2 encntr_mrn_active_ind = i2
     2 encntr_mrn_active_status_cd = f8
     2 encntr_mrn_active_status_dt_tm = dq8
     2 encntr_mrn_active_status_prsnl_id = f8
     2 encntr_mrn_alias = vc
     2 encntr_mrn_alias_pool_cd = f8
     2 encntr_mrn_assign_authority_sys_cd = f8
     2 encntr_mrn_beg_effective_dt_tm = dq8
     2 encntr_mrn_check_digit = i4
     2 encntr_mrn_check_digit_method_cd = f8
     2 encntr_mrn_contributor_system_cd = f8
     2 encntr_mrn_data_status_cd = f8
     2 encntr_mrn_data_status_dt_tm = dq8
     2 encntr_mrn_data_status_prsnl_id = f8
     2 encntr_mrn_encntr_alias_id = f8
     2 encntr_mrn_encntr_alias_type_cd = f8
     2 encntr_mrn_encntr_id = f8
     2 encntr_mrn_end_effective_dt_tm = dq8
     2 encntr_mrn_updt_dt_tm = dq8
     2 encntr_mrn_updt_id = f8
     2 encntr_mrn_updt_task = i4
     2 encntr_fin_active_ind = i2
     2 encntr_fin_active_status_cd = f8
     2 encntr_fin_active_status_dt_tm = dq8
     2 encntr_fin_active_status_prsnl_id = f8
     2 encntr_fin_alias = vc
     2 encntr_fin_alias_pool_cd = f8
     2 encntr_fin_assign_authority_sys_cd = f8
     2 encntr_fin_beg_effective_dt_tm = dq8
     2 encntr_fin_check_digit = i4
     2 encntr_fin_check_digit_method_cd = f8
     2 encntr_fin_contributor_system_cd = f8
     2 encntr_fin_data_status_cd = f8
     2 encntr_fin_data_status_dt_tm = dq8
     2 encntr_fin_data_status_prsnl_id = f8
     2 encntr_fin_encntr_alias_id = f8
     2 encntr_fin_encntr_alias_type_cd = f8
     2 encntr_fin_encntr_id = f8
     2 encntr_fin_end_effective_dt_tm = dq8
     2 encntr_fin_updt_dt_tm = dq8
     2 encntr_fin_updt_id = f8
     2 encntr_fin_updt_task = i4
     2 him_visit_abstract_complete_ind = i2
     2 him_visit_active_ind = i2
     2 him_visit_active_status_cd = f8
     2 him_visit_active_status_dt_tm = dq8
     2 him_visit_active_status_prsnl_id = f8
     2 him_visit_allocation_dt_flag = i2
     2 him_visit_allocation_dt_modifier = i4
     2 him_visit_allocation_dt_tm = dq8
     2 him_visit_beg_effective_dt_tm = dq8
     2 him_visit_chart_process_id = f8
     2 him_visit_chart_status_cd = f8
     2 him_visit_chart_status_dt_tm = dq8
     2 him_visit_encntr_id = f8
     2 him_visit_end_effective_dt_tm = dq8
     2 him_visit_person_id = f8
     2 him_visit_updt_dt_tm = dq8
     2 him_visit_updt_id = f8
     2 him_visit_updt_task = i4
     2 org_active_ind = i2
     2 org_active_status_cd = f8
     2 org_active_status_dt_tm = dq8
     2 org_active_status_prsnl_id = f8
     2 org_beg_effective_dt_tm = dq8
     2 org_contributor_source_cd = f8
     2 org_contributor_system_cd = f8
     2 org_data_status_cd = f8
     2 org_data_status_dt_tm = dq8
     2 org_data_status_prsnl_id = f8
     2 org_end_effective_dt_tm = dq8
     2 org_federal_tax_id_nbr = vc
     2 org_ft_entity_id = f8
     2 org_ft_entity_name = c32
     2 org_organization_id = f8
     2 org_org_class_cd = f8
     2 org_org_name = vc
     2 org_org_name_key = vc
     2 org_org_name_key_nls = vc
     2 org_org_status_cd = f8
     2 org_updt_dt_tm = dq8
     2 org_updt_id = f8
     2 org_updt_task = i4
     2 defic_qual [* ]
       3 deficiency_name = vc
       3 status = vc
       3 alloc_dt_tm = dq8
       3 defic_age = f8 ;i4
       3 event_id = f8
       3 order_id = f8
       3 action_sequence = i4
       3 deficiency_flag = i2
       3 otg_id = i2
       3 scanning_prsnl = vc
       3 scanning_prsnl_id = f8
       3 doc_qual [* ]
         4 him_event_action_type_cd = f8
         4 him_event_action_status_cd = f8
         4 him_event_allocation_dt_tm = dq8
         4 him_event_beg_effective_dt_tm = dq8
         4 him_event_completed_dt_tm = dq8
         4 him_event_encntr_id = f8
         4 him_event_end_effective_dt_tm = dq8
         4 him_event_event_cd = f8
         4 him_event_event_id = f8
         4 him_event_him_event_allocation_id = f8
         4 him_event_prsnl_id = f8
         4 him_event_request_dt_tm = dq8
         4 him_event_updt_dt_tm = dq8
         4 him_event_updt_id = f8
         4 him_event_updt_task = f8
         4 him_event_active_status_cd = f8
         4 him_event_active_dt_tm = dq8
         4 him_event_active_ind = i2
         4 him_event_active_status_cd = f8
         4 him_event_active_status_prsnl_id = f8
         4 him_event_active_status_dt_tm = dq8
       3 order_qual [* ]
         4 orders_active_ind = i4
         4 orders_active_status_cd = f8
         4 orders_active_status_dt_tm = dq8
         4 orders_active_status_prsnl_id = f8
         4 orders_activity_type_cd = f8
         4 orders_ad_hoc_order_flag = i4
         4 orders_catalog_cd = f8
         4 orders_catalog_type_cd = f8
         4 orders_cki = vc
         4 orders_clinical_display_line = vc
         4 orders_comment_type_mask = i4
         4 orders_constant_ind = i4
         4 orders_contributor_system_cd = f8
         4 orders_cs_flag = i4
         4 orders_cs_order_id = f8
         4 orders_current_start_dt_tm = dq8
         4 orders_current_start_tz = i4
         4 orders_dcp_clin_cat_cd = f8
         4 orders_dept_misc_line = vc
         4 orders_dept_status_cd = f8
         4 orders_discontinue_effective_dt_tm = dq8
         4 orders_discontinue_effective_tz = i4
         4 orders_discontinue_ind = i4
         4 orders_discontinue_type_cd = f8
         4 orders_encntr_financial_id = f8
         4 orders_encntr_id = f8
         4 orders_eso_new_order_ind = i4
         4 orders_frequency_id = f8
         4 orders_freq_type_flag = i4
         4 orders_group_order_flag = i4
         4 orders_group_order_id = f8
         4 orders_hide_flag = i4
         4 orders_hna_order_mnemonic = vc
         4 orders_incomplete_order_ind = i4
         4 orders_ingredient_ind = i4
         4 orders_interest_dt_tm = dq8
         4 orders_interval_ind = i4
         4 orders_iv_ind = i4
         4 orders_last_action_sequence = i4
         4 orders_last_core_action_sequence = i4
         4 orders_last_ingred_action_sequence = i4
         4 orders_last_update_provider_id = f8
         4 orders_link_nbr = f8
         4 orders_link_order_flag = i4
         4 orders_link_order_id = f8
         4 orders_link_type_flag = i4
         4 orders_med_order_type_cd = f8
         4 orders_modified_start_dt_tm = dq8
         4 orders_need_doctor_cosign_ind = i4
         4 orders_need_nurse_review_ind = i4
         4 orders_need_physician_validate_ind = i4
         4 orders_need_rx_verify_ind = i4
         4 orders_oe_format_id = f8
         4 orders_orderable_type_flag = i4
         4 orders_ordered_as_mnemonic = vc
         4 orders_order_comment_ind = i4
         4 orders_order_detail_display_line = vc
         4 orders_order_id = f8
         4 orders_order_mnemonic = vc
         4 orders_order_status_cd = f8
         4 orders_orig_order_convs_seq = i4
         4 orders_orig_order_dt_tm = dq8
         4 orders_orig_order_tz = i4
         4 orders_orig_ord_as_flag = i4
         4 orders_override_flag = i4
         4 orders_pathway_catalog_id = f8
         4 orders_person_id = f8
         4 orders_prn_ind = i4
         4 orders_product_id = f8
         4 orders_projected_stop_dt_tm = dq8
         4 orders_projected_stop_tz = i4
         4 orders_ref_text_mask = i4
         4 orders_remaining_dose_cnt = i4
         4 orders_resume_effective_dt_tm = dq8
         4 orders_resume_effective_tz = i4
         4 orders_resume_ind = i4
         4 orders_rx_mask = i4
         4 orders_sch_state_cd = f8
         4 orders_soft_stop_dt_tm = dq8
         4 orders_soft_stop_tz = i4
         4 orders_status_dt_tm = dq8
         4 orders_status_prsnl_id = f8
         4 orders_stop_type_cd = f8
         4 orders_suspend_effective_dt_tm = dq8
         4 orders_suspend_effective_tz = i4
         4 orders_suspend_ind = i4
         4 orders_synonym_id = f8
         4 orders_template_core_action_sequence = i4
         4 orders_template_order_flag = i4
         4 orders_template_order_id = f8
         4 orders_updt_dt_tm = dq8
         4 orders_updt_id = f8
         4 orders_updt_task = i4
         4 orders_valid_dose_dt_tm = dq8
         4 order_review_action_sequence = i4
         4 order_review_dept_cd = f8
         4 order_review_digital_signature_ident = vc
         4 order_review_location_cd = f8
         4 order_review_order_id = f8
         4 order_review_provider_id = f8
         4 order_review_proxy_personnel_id = f8
         4 order_review_proxy_reason_cd = f8
         4 order_review_reject_reason_cd = f8
         4 order_review_reviewed_status_flag = i2
         4 order_review_review_dt_tm = dq8
         4 order_review_review_personnel_id = f8
         4 order_review_review_reqd_ind = i2
         4 order_review_review_sequence = i4
         4 order_review_review_type_flag = i2
         4 order_review_review_tz = i4
         4 order_review_updt_dt_tm = dq8
         4 order_review_updt_id = f8
         4 order_review_updt_task = i4
         4 order_notif_action_sequence = i4
         4 order_notif_caused_by_flag = i2
         4 order_notif_from_prsnl_id = f8
         4 order_notif_notification_comment = vc
         4 order_notif_notification_dt_tm = dq8
         4 order_notif_notification_reason_cd = f8
         4 order_notif_notification_status_flag = i2
         4 order_notif_notification_type_flag = i2
         4 order_notif_notification_tz = i4
         4 order_notif_order_id = f8
         4 order_notif_order_notification_id = f8
         4 order_notif_parent_order_notification_id = f8
         4 order_notif_status_change_dt_tm = dq8
         4 order_notif_status_change_tz = i4
         4 order_notif_to_prsnl_id = f8
         4 order_notif_updt_dt_tm = dq8
         4 order_notif_updt_id = f8
         4 order_notif_updt_task = i4
   1 max_defic_qual_count = i4
 )
 IF (i1multifacilitylogicind )
  CALL getdatafromprompt (2 ,organizations )
  CALL himgetnamesfromtable (organizations ,"organization" ,"org_name" ,"organization_id" )
 ENDIF
 CALL getdatafromprompt (3 ,physicians )
 CALL himgetnamesfromtable (physicians ,"prsnl" ,"name_full_formatted" ,"person_id" )
 EXECUTE him_mak_defic_by_phys_driver
 IF (himrendernodatareport (size (data->qual ,5 ) , $OUTDEV ) )
  RETURN
 ENDIF
 
/***Insert Output  here***/
 
;included for testing purposes
/*
EXECUTE reportrtl
   SELECT INTO  $OUTDEV
    FROM (dual d )
    HEAD REPORT
     col 0 ,
     "No data found."
    WITH nocounter
*/
 
declare age_days = f8
declare star_pool_cd = f8 with protect, constant(uar_get_code_by("DISPLAY",263,"STAR Doctor Number"))
declare prsnl_alias_type_cd = f8 with protect, constant(uar_get_code_by("DISPLAY",320,"ORGANIZATION DOCTOR"))
declare dOTG = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 25, "OTG"))
declare dDOC = f8 with protect, constant(uar_get_code_by("DISPLAYKEY", 53, "DOC"))
 
 SELECT INTO "nl:"
      pa.alias
 from (dummyt d with seq = value(size(data->qual,5)))
       ,prsnl_alias pa
 plan (d where (d.seq > 0))
 join (pa where pa.person_id = outerjoin(data->qual[d.seq]->physician_person_id)
      and pa.active_ind = outerjoin(1)
      and pa.alias_pool_cd = outerjoin(star_pool_cd)
      and pa.prsnl_alias_type_cd = outerjoin(prsnl_alias_type_cd)
      and pa.beg_effective_dt_tm < outerjoin(cnvtdatetime(curdate,curtime3))
      and pa.end_effective_dt_tm > outerjoin(cnvtdatetime(curdate,curtime3)))
 DETAIL
   data->qual[d.seq]->physician_star_id = pa.alias
 WITH nocounter
 ;end select
 
 
select into "nl:" ;$OUTDEV
from (dummyt d with seq = value(size(data->qual,5))),
     (dummyt ddefic with seq = value(data->max_defic_qual_count)),
     ce_blob_result cbr
plan (d where (d.seq > 0))
join (ddefic where (ddefic.seq <= size(data->qual[d.seq].defic_qual,5)))
join cbr where
    cbr.event_id = data->qual[d.seq]->defic_qual[ddefic.seq].event_id and
    cbr.storage_cd = dOTG and
    cbr.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
detail
	data->qual[d.seq]->defic_qual[ddefic.seq].otg_id = 1
with nocounter
call echo(build("dOTG=",dOTG))
 
select into "nl:" ;$OUTDEV
from (dummyt d with seq = value(size(data->qual,5))),
     (dummyt ddefic with seq = value(data->max_defic_qual_count)),
     ce_event_prsnl cbr,
     prsnl p
plan (d where (d.seq > 0))
join (ddefic where (ddefic.seq <= size(data->qual[d.seq].defic_qual,5)))
join cbr where
    cbr.event_id = data->qual[d.seq]->defic_qual[ddefic.seq].event_id and
    cbr.action_type_cd = value(uar_get_code_by("MEANING",21,"TRANSCRIBE"))
join p
	where p.person_id = cbr.action_prsnl_id
order by
	 cbr.event_id
	,cbr.action_dt_tm
head cbr.event_id
	data->qual[d.seq]->defic_qual[ddefic.seq].scanning_prsnl_id = cbr.action_prsnl_id
	data->qual[d.seq]->defic_qual[ddefic.seq].scanning_prsnl = p.name_full_formatted
with nocounter
 
 
;TRANSCRIBE 21
 
 
select into value($OUTDEV) ;$OUTDEV
   encntr_type=uar_get_code_display(data->qual[d.seq]->encntr_encntr_type_cd)
   ,age_days=(data->qual[d.seq]->defic_qual[ddefic.seq]->defic_age/24)
   ,disch_dt_tm=format(data->qual[d.seq]->disch_dt_tm,"DD-MMM-YYYY HH:MM;;Q")
   ,position_disp=trim(uar_get_code_display(data->qual[d.seq]->physician_position_cd),3)
from (dummyt d with seq = value(size(data->qual,5))),
     (dummyt ddefic with seq = value(data->max_defic_qual_count))
plan (d where (d.seq > 0))
join (ddefic where (ddefic.seq <= size(data->qual[d.seq].defic_qual,5)))
 
head report
  y = 0
  age_days_2 = 0.00
  col 0
/*
    "Location","|"
    ,"Physician","|"
    ,"Physician_Position","|"
    ,"Physicain_StarID","|"
    ,"Patient Name","|"
    ,"MRN","|"
    ,"FIN","|"
    ,"Discharge Date","|"
    ,"Deficiency","|"
    ,"Status","|"
    ,"Deficiency Age - Days","|"
    ,"Deficiency Age - Hours","|"
    ,"Encounter Type"
*/
     "Location",","
    ,"Physician",","
    ,"Physician_Position",","
    ,"Physicain_StarID",","
    ,"Patient Name",","
    ,"MRN",","
    ,"FIN",","
    ,"Discharge Date",","
    ,"Deficiency",","
    ,"Status",","
    ,"Deficiency Age - Days",","
    ,"Deficiency Age - Hours",","
    ,"Encounter Type",","
    ,"Order Notif ID",","
    ,"Physician Person ID",","
	;,"Scanned Image Indicator",","
	,"event_id",","
	,"Scanning Personnel"
  row + 1
detail
  y = y + 1
  if(y > 1)
    row + 1
  endif
  col 0
    ;Location=UAR_GET_543CODE_DISPLAY(data->qual[d.seq]->encntr_loc_facility_cd),"|",
    '"',data->qual[d.seq]->org_org_name,'"',",",
    '"',data->qual[d.seq]->physician_name_full_formatted,'"',",",
    '"',position_disp,'"',",",
    '"',data->qual[d.seq]->physician_star_id,'"',",",
    '"',data->qual[d.seq]->patient_name,'"',",",
    '"',data->qual[d.seq]->mrn,'"',",",
    '"',data->qual[d.seq]->fin,'"',",",
    '"',disch_dt_tm,'"',",",
    '"',data->qual[d.seq]->defic_qual[ddefic.seq]->deficiency_name,'"',",",
    '"',data->qual[d.seq]->defic_qual[ddefic.seq]->status,'"',",",
    '"',age_days,'"',",",
    '"',data->qual[d.seq]->defic_qual[ddefic.seq]->defic_age,'"',",",
    '"',encntr_type,'"'",", ;data->qual[d.seq]->encntr_encntr_type_cd
    if (validate(data->qual[d.seq]->defic_qual[ddefic.seq]->order_qual[1]->order_notif_order_notification_id))
    order_notif_id =
    trim(cnvtstring(data->qual[d.seq]->defic_qual[ddefic.seq]->order_qual[1]->order_notif_order_notification_id),3)
    else
    order_notif_id = " "
    endif
    '"',order_notif_id,'"',",",
    prsnl_person_id = trim(cnvtstring(data->qual[d.seq]->physician_person_id),3)
    '"',prsnl_person_id,'"',",",
    scanned_ind = trim(cnvtstring(data->qual[d.seq]->defic_qual[ddefic.seq].event_id),3)
    '"',scanned_ind,'"',",",
    scanned_prsnl = trim(data->qual[d.seq]->defic_qual[ddefic.seq].scanning_prsnl,3)
    '"',scanned_prsnl,'"'
 
 
with nocounter
  ,landscape
  ,format = variable
  ,maxcol = 15000
  ;,maxrow = 1
  ,formfeed = none
  ;,append
call echorecord(data)
END GO
 
