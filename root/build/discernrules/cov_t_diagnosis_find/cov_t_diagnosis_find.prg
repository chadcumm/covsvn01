 
DROP PROGRAM cov_t_diagnosis_find :dba GO
CREATE PROGRAM cov_t_diagnosis_find :dba
 SET rev_inc = "708"
 SET ininc = "eks_tell_ekscommon"
 SET ttemp = trim (eks_common->cur_module_name )
 SET eksmodule = trim (ttemp )
 FREE SET ttemp
 SET ttemp = trim (eks_common->event_name )
 SET eksevent = ttemp
 SET eksrequest = eks_common->request_number
 FREE SET ttemp
 DECLARE tcurindex = i4
 DECLARE tinx = i4
 SET tcurindex = 1
 SET tinx = 1
 SET evoke_inx = 1
 SET data_inx = 2
 SET logic_inx = 3
 SET action_inx = 4
 IF (NOT ((validate (eksdata->tqual ,"Y" ) = "Y" )
 AND (validate (eksdata->tqual ,"Z" ) = "Z" ) ) )
  FREE SET templatetype
  IF ((conclude > 0 ) )
   SET templatetype = "ACTION"
   SET basecurindex = (logiccnt + evokecnt )
   SET tcurindex = 4
  ELSE
   SET templatetype = "LOGIC"
   SET basecurindex = evokecnt
   SET tcurindex = 3
  ENDIF
  SET cbinx = curindex
  SET tinx = logic_inx
 ELSE
  SET templatetype = "EVOKE"
  SET curindex = 0
  SET tcurindex = 0
  SET tinx = 0
 ENDIF
 CALL echo (concat ("****  " ,format (curdate ,"dd-mmm-yyyy;;d" ) ," " ,format (curtime3 ,
    "hh:mm:ss.cc;3;m" ) ,"     Module:  " ,trim (eksmodule ) ,"  ****" ) ,1 ,0 )
 IF ((validate (tname ,"Y" ) = "Y" )
 AND (validate (tname ,"Z" ) = "Z" ) )
  IF ((templatetype != "EVOKE" ) )
   CALL echo (concat ("****  EKM Beginning of " ,trim (templatetype ) ," Template(" ,build (curindex
      ) ,")           Event:  " ,trim (eksevent ) ,"         Request number:  " ,cnvtstring (
      eksrequest ) ) ,1 ,10 )
  ELSE
   CALL echo (concat ("****  EKM Beginning an Evoke Template" ,"           Event:  " ,trim (eksevent
      ) ,"         Request number:  " ,cnvtstring (eksrequest ) ) ,1 ,10 )
  ENDIF
 ELSE
  IF ((templatetype != "EVOKE" ) )
   CALL echo (concat ("****  EKM Beginning of " ,trim (templatetype ) ," Template(" ,build (curindex
      ) ,"):  " ,trim (tname ) ,"       Event:  " ,trim (eksevent ) ,"         Request number:  " ,
     cnvtstring (eksrequest ) ) ,1 ,10 )
  ELSE
   CALL echo (concat ("****  EKM Beginning Evoke Template:  " ,trim (tname ) ,"       Event:  " ,
     trim (eksevent ) ,"         Request number:  " ,cnvtstring (eksrequest ) ) ,1 ,10 )
  ENDIF
 ENDIF
 RECORD nomendata (
   1 stop_ind = i2
   1 match_cnt = i4
   1 all_matches_ind = i2
   1 hierarchy_ind = i2
   1 ignore_concepts_ind = i2
   1 cross_patient_ind = i2
   1 cross_vocabs_cnt = i4
   1 cross_vocabs [* ]
     2 vocab_cd = f8
   1 nomen_cnt = i4
   1 nomen_qual [* ]
     2 nomenclature_id = f8
     2 misc_id = f8
     2 misc_instance_id = f8
     2 ccki = vc
     2 match_ind = i2
     2 req_index = i4
 )
 DECLARE tempstarttime = f8
 SET tempstarttime = curtime3
 DECLARE validatenewparameter () = null
 CALL echo (concat (format (curdate ,"dd-mmm-yyyy;;d" ) ," " ,format (curtime3 ,"hh:mm:ss.cc;3;m" ) ,
   "  *******    Beginning of Program EKS_T_DIAGNOSIS_FIND     *********" ) ,1 ,0 )
 DECLARE pt_dpersonid = f8 WITH protect ,noconstant (0.0 )
 DECLARE pt_dencntrid = f8 WITH protect ,noconstant (0.0 )
 DECLARE pt_daccessionid = f8 WITH protect ,noconstant (0.0 )
 DECLARE pt_dorderid = f8 WITH protect ,noconstant (0.0 )
 SET pt_dpersonid = event->qual[eks_common->event_repeat_index ].person_id
 SET pt_dencntrid = event->qual[eks_common->event_repeat_index ].encntr_id
 SET pt_daccessionid = event->qual[eks_common->event_repeat_index ].accession_id
 SET pt_dorderid = event->qual[eks_common->event_repeat_index ].order_id
 CALL echo (concat ("Triggering by " ,trim (tname ) ," in " ,trim (eks_common->event_name ) ) ,1 ,0
  )
 DECLARE msg = vc
 DECLARE i = i4 WITH protect
 DECLARE stop_search_pos = i4 WITH protect
 SET stop_search_pos = 0
 CALL echo (concat (format (curdate ,"dd-mmm-yyyy;;d" ) ," " ,format (curtime3 ,"hh:mm:ss.cc;3;m" ) ,
   "... Checking existence and validity of template parameters ..." ) ,1 ,0 )
 DECLARE pt_bdiagnosis_ind = i2 WITH protect ,noconstant (0 )
 CALL echo ("Parameter - OPT_DIAGNOSIS" )
 RECORD opt_diagnosislist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
 )
 IF ((validate (opt_diagnosis ,"Z" ) = "Z" )
 AND (validate (opt_diagnosis ,"Y" ) = "Y" ) )
  SET msg = "parameter OPT_DIAGNOSIS does not exist."
  SET retval = - (1 )
  GO TO endprogram
 ELSE
  SET orig_param = opt_diagnosis
  EXECUTE eks_t_parse_list WITH replace (reply ,opt_diagnosislist )
  FREE SET orig_param
  IF ((opt_diagnosislist->cnt <= 0 ) )
   SET pt_bdiagnosis_ind = 0
   CALL echo ("template is running without parameter OPT_DIAGNOSIS specified." )
  ELSE
   SET pt_bdiagnosis_ind = 1
  ENDIF
 ENDIF
 CALL echo (concat ("pt_bDiagnosis_Ind: " ,build (pt_bdiagnosis_ind ) ) )
 DECLARE pv_itemp = i4 WITH private ,noconstant (0 )
 DECLARE pt_bqualifier_ind = i2 WITH protect ,noconstant (0 )
 CALL echo ("parameter - OPT_QUALIFIER" )
 RECORD opt_qualifierlist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
     2 value_f8 = f8
 )
 IF ((validate (opt_qualifier ,"Z" ) = "Z" )
 AND (validate (opt_qualfier ,"Y" ) = "Y" ) )
  SET msg = "parameter OPT_QUALIFIER does not exist."
  SET retval = - (1 )
  GO TO endprogram
 ELSE
  SET orig_param = opt_qualifier
  EXECUTE eks_t_parse_list WITH replace (reply ,opt_qualifierlist )
  FREE SET orig_param
  IF ((opt_qualifierlist->cnt <= 0 ) )
   SET pt_bqualifier_ind = 0
   CALL echo ("template is running without parameter OPT_QUALIFIER specified." )
  ELSE
   SET pt_bqualifier_ind = 1
   FOR (pv_itemp = 1 TO opt_qualifierlist->cnt )
    IF ((isnumeric (opt_qualifierlist->qual[pv_itemp ].value ) = 0 ) )
     IF ((cnvtlower (trim (opt_qualifierlist->qual[pv_itemp ].value ) ) = "*not specified" ) )
      SET opt_qualifierlist->qual[pv_itemp ].value = "0"
      CALL echo (" change hidden value to 0 for *not specified." )
     ELSEIF ((cnvtlower (trim (opt_qualifierlist->qual[pv_itemp ].value ) ) =
     "*Stop search after first match" ) )
      SET stop_search_pos = pv_itemp
     ENDIF
    ELSE
     SET opt_qualifierlist->qual[pv_itemp ].value_f8 = cnvtreal (opt_qualifierlist->qual[pv_itemp ].
      value )
    ENDIF
   ENDFOR
   IF ((stop_search_pos > 0 ) )
    CALL echo (concat ("STOP SEARCH indicator found in the item " ,build (stop_search_pos ) ,
      ". Removing it from the list of qualifiers." ) )
    SET opt_qualifierlist->cnt = (opt_qualifierlist->cnt - 1 )
    SET stat = alterlist (opt_qualifierlist->qual ,opt_qualifierlist->cnt ,(stop_search_pos - 1 ) )
   ENDIF
   CALL echorecord (opt_qualifierlist )
  ENDIF
 ENDIF
 CALL echo (concat ("pt_bQualifier_Ind: " ,build (pt_bqualifier_ind ) ) )
 DECLARE pt_bconfirmation_ind = i2 WITH protect ,noconstant (0 )
 CALL echo ("parameter - OPT_CONFIRMATION" )
 RECORD opt_confirmationlist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
     2 value_f8 = f8
 )
 IF ((validate (opt_confirmation ,"Z" ) = "Z" )
 AND (validate (opt_confirmation ,"Y" ) = "Y" ) )
  SET msg = "parameter OPT_CONFIRMATION does not exist."
  SET retval = - (1 )
  GO TO endprogram
 ELSE
  SET orig_param = opt_confirmation
  EXECUTE eks_t_parse_list WITH replace (reply ,opt_confirmationlist )
  FREE SET orig_param
  IF ((opt_confirmationlist->cnt <= 0 ) )
   SET pt_bconfirmation_ind = 0
   CALL echo ("template is running without parameter OPT_CONFIRMATION specified." )
  ELSE
   SET pt_bconfirmation_ind = 1
   FOR (pv_itemp = 1 TO opt_confirmationlist->cnt )
    IF ((isnumeric (opt_confirmationlist->qual[pv_itemp ].value ) = 0 ) )
     IF ((cnvtlower (trim (opt_confirmationlist->qual[pv_itemp ].value ) ) = "*not specified" ) )
      SET opt_confirmationlist->qual[pv_itemp ].value = "0"
      CALL echo (" change hidden value to 0 for *not specified." )
     ENDIF
    ELSE
     SET opt_confirmationlist->qual[pv_itemp ].value_f8 = cnvtreal (opt_confirmationlist->qual[
      pv_itemp ].value )
    ENDIF
   ENDFOR
  ENDIF
 ENDIF
 CALL echo (concat ("pt_bConfirmation_Ind: " ,build (pt_bconfirmation_ind ) ) )
 DECLARE pt_bclassification_ind = i2 WITH protect ,noconstant (0 )
 CALL echo ("Parameter - OPT_CLASSIFICATION" )
 RECORD opt_classificationlist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
     2 value_f8 = f8
 )
 IF ((validate (opt_classification ,"Z" ) = "Z" )
 AND (validate (opt_classification ,"Y" ) = "Y" ) )
  SET msg = "parameter OPT_CLASSIFICATION does not exist"
  SET retval = - (1 )
  GO TO endprogram
 ELSE
  SET orig_param = opt_classification
  EXECUTE eks_t_parse_list WITH replace (reply ,opt_classificationlist )
  FREE SET orig_param
  IF ((opt_classificationlist->cnt <= 0 ) )
   SET pt_bclassification_ind = 0
   CALL echo ("template is running without parameter OPT_CLASSIFICATION specified" )
  ELSE
   SET pt_bclassification_ind = 1
   FOR (pv_itemp = 1 TO opt_classificationlist->cnt )
    IF ((isnumeric (opt_classificationlist->qual[pv_itemp ].value ) = 0 ) )
     IF ((cnvtlower (trim (opt_classificationlist->qual[pv_itemp ].value ) ) = "*not specified" ) )
      SET opt_classificationlist->qual[pv_itemp ].value = "0"
      CALL echo (" change hidden value to 0 for *not specified." )
     ENDIF
    ELSE
     SET opt_classificationlist->qual[pv_itemp ].value_f8 = cnvtreal (opt_classificationlist->qual[
      pv_itemp ].value )
    ENDIF
   ENDFOR
  ENDIF
 ENDIF
 CALL echo (concat ("pt_bClassification_Ind: " ,build (pt_bclassification_ind ) ) )
 DECLARE pt_bclinicalservice_ind = i2 WITH protect ,noconstant (0 )
 CALL echo ("parameter - OPT_CLINICAL_SERVICE" )
 RECORD opt_clinical_servicelist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
     2 value_f8 = f8
 )
 IF ((validate (opt_clinical_service ,"Z" ) = "Z" )
 AND (validate (opt_clinical_service ,"Y" ) = "Y" ) )
  SET msg = "parameter OPT_CLINICAL_SERVICE does not exist."
  SET retval = - (1 )
  GO TO endprogram
 ELSE
  SET orig_param = opt_clinical_service
  EXECUTE eks_t_parse_list WITH replace (reply ,opt_clinical_servicelist )
  FREE SET orig_param
  IF ((opt_clinical_servicelist->cnt <= 0 ) )
   SET pt_bclinicalservice_ind = 0
   CALL echo ("template is running without parameter OPT_CLINICAL_SERVICE" )
  ELSE
   SET pt_bclinicalservice_ind = 1
   FOR (pv_itemp = 1 TO opt_clinical_servicelist->cnt )
    IF ((isnumeric (opt_clinical_servicelist->qual[pv_itemp ].value ) = 0 ) )
     IF ((cnvtlower (trim (opt_clinical_servicelist->qual[pv_itemp ].value ) ) = "*not specified" )
     )
      SET opt_clinical_servicelist->qual[pv_itemp ].value = "0"
      CALL echo (" change hidden value to 0 for *not specified." )
     ENDIF
    ELSE
     SET opt_clinical_servicelist->qual[pv_itemp ].value_f8 = cnvtreal (opt_clinical_servicelist->
      qual[pv_itemp ].value )
    ENDIF
   ENDFOR
  ENDIF
 ENDIF
 CALL echo (concat ("pt_bClinicalService_Ind: " ,build (pt_bclinicalservice_ind ) ) )
 DECLARE pt_bdxtype_ind = i2 WITH protect ,noconstant (0 )
 CALL echo ("parameter - OPT_DX_TYPE" )
 RECORD opt_dx_typelist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
     2 value_f8 = f8
 )
 IF ((validate (opt_dx_type ,"Z" ) = "Z" )
 AND (validate (opt_dx_type ,"Y" ) = "Y" ) )
  SET msg = "parameter OPT_DX_TYPE does not exist."
  SET retval = - (1 )
  GO TO endprogram
 ELSE
  SET orig_param = opt_dx_type
  EXECUTE eks_t_parse_list WITH replace (reply ,opt_dx_typelist )
  FREE SET orig_param
  IF ((opt_dx_typelist->cnt <= 0 ) )
   SET pt_bdxtype_ind = 0
   CALL echo ("template is  running without parameter OPT_DX_TYPE" )
  ELSE
   SET pt_bdxtype_ind = 1
   FOR (pv_itemp = 1 TO opt_dx_typelist->cnt )
    IF ((isnumeric (opt_dx_typelist->qual[pv_itemp ].value ) = 0 ) )
     IF ((cnvtlower (trim (opt_dx_typelist->qual[pv_itemp ].value ) ) = "*not specified" ) )
      SET opt_dx_typelist->qual[pv_itemp ].value = "0"
      CALL echo (" change hidden value to 0 for *not specified." )
     ENDIF
    ELSE
     SET opt_dx_typelist->qual[pv_itemp ].value_f8 = cnvtreal (opt_dx_typelist->qual[pv_itemp ].value
       )
    ENDIF
   ENDFOR
  ENDIF
 ENDIF
 CALL echo (concat ("pt_bDxType_Ind: " ,build (pt_bdxtype_ind ) ) )
 DECLARE pt_bseverityclass_ind = i2 WITH protect ,noconstant (0 )
 CALL echo ("parameter - OPT_SEVERITY_CLASS" )
 RECORD opt_severity_classlist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
     2 value_f8 = f8
 )
 IF ((validate (opt_severity_class ,"Z" ) = "Z" )
 AND (validate (opt_severity_class ,"Y" ) = "Y" ) )
  SET msg = "parameter OPT_SEVERITY_CLASS does not exist."
  SET retval = - (1 )
  GO TO endprogram
 ELSE
  SET orig_param = opt_severity_class
  EXECUTE eks_t_parse_list WITH replace (reply ,opt_severity_classlist )
  FREE SET orig_param
  IF ((opt_severity_classlist->cnt <= 0 ) )
   SET pt_bseverityclass_ind = 0
   CALL echo ("template is running without parameter OPT_SEVERITY_CLASS specified" )
  ELSE
   SET pt_bseverityclass_ind = 1
   FOR (pv_itemp = 1 TO opt_severity_classlist->cnt )
    IF ((isnumeric (opt_severity_classlist->qual[pv_itemp ].value ) = 0 ) )
     IF ((cnvtlower (trim (opt_severity_classlist->qual[pv_itemp ].value ) ) = "*not specified" ) )
      SET opt_severity_classlist->qual[pv_itemp ].value = "0"
      CALL echo (" change hidden value to 0 for *not specified." )
     ENDIF
    ELSE
     SET opt_severity_classlist->qual[pv_itemp ].value_f8 = cnvtreal (opt_severity_classlist->qual[
      pv_itemp ].value )
    ENDIF
   ENDFOR
  ENDIF
 ENDIF
 CALL echo (concat ("pt_bSeverityClass_Ind: " ,build (pt_bseverityclass_ind ) ) )
 DECLARE pt_bseverity_ind = i2 WITH protect ,noconstant (0 )
 CALL echo ("parameter - OPT_SEVERITY" )
 RECORD opt_severitylist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
     2 value_f8 = f8
 )
 IF ((validate (opt_severity ,"Z" ) = "Z" )
 AND (validate (opt_severity ,"Y" ) = "Y" ) )
  SET msg = "parameter OPT_SEVERITY does not exist."
  SET retval = - (1 )
  GO TO endprogram
 ELSE
  SET orig_param = opt_severity
  EXECUTE eks_t_parse_list WITH replace (reply ,opt_severitylist )
  FREE SET orig_param
  IF ((opt_severitylist->cnt <= 0 ) )
   SET pt_bseverity_ind = 0
   CALL echo ("template is running without parameter OPT_SEVERITY specified" )
  ELSE
   SET pt_bseverity_ind = 1
   FOR (pv_itemp = 1 TO opt_severitylist->cnt )
    IF ((isnumeric (opt_severitylist->qual[pv_itemp ].value ) = 0 ) )
     IF ((cnvtlower (trim (opt_severitylist->qual[pv_itemp ].value ) ) = "*not specified" ) )
      SET opt_severitylist->qual[pv_itemp ].value = "0"
      CALL echo (" change hidden value to 0 for *not specified." )
     ENDIF
    ELSE
     SET opt_severitylist->qual[pv_itemp ].value_f8 = cnvtreal (opt_severitylist->qual[pv_itemp ].
      value )
    ENDIF
   ENDFOR
  ENDIF
 ENDIF
 CALL echo (concat ("pt_bSeverity_Ind:  " ,build (pt_bseverity_ind ) ) )
 DECLARE pt_bcontributorsystem_ind = i2 WITH protect ,noconstant (0 )
 CALL echo ("parameter - OPT_CONTRIBUTOR_SYSTEM" )
 RECORD opt_contributor_systemlist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
     2 value_f8 = f8
 )
 IF ((validate (opt_contributor_system ,"Z" ) = "Z" )
 AND (validate (opt_contributor_system ,"Y" ) = "Y" ) )
  SET msg = "parameter OPT_CONTRIBUTOR_SYSTEM does not exist."
  SET retval = - (1 )
  GO TO endprogram
 ELSE
  SET orig_param = opt_contributor_system
  EXECUTE eks_t_parse_list WITH replace (reply ,opt_contributor_systemlist )
  FREE SET orig_param
  IF ((opt_contributor_systemlist->cnt <= 0 ) )
   SET pt_bcontributorsystem_ind = 0
   CALL echo ("template is running without parameter OPT_CONTRIBUTOR_SYSTEM specified" )
  ELSE
   SET pt_bcontributorsystem_ind = 1
   FOR (pv_itemp = 1 TO opt_contributor_systemlist->cnt )
    IF ((isnumeric (opt_contributor_systemlist->qual[pv_itemp ].value ) = 0 ) )
     IF ((cnvtlower (trim (opt_contributor_systemlist->qual[pv_itemp ].value ) ) = "*not specified"
     ) )
      SET opt_contributor_systemlist->qual[pv_itemp ].value = "0"
      CALL echo (" change hidden value to 0 for *not specified." )
     ENDIF
    ELSE
     SET opt_contributor_systemlist->qual[pv_itemp ].value_f8 = cnvtreal (opt_contributor_systemlist
      ->qual[pv_itemp ].value )
    ENDIF
   ENDFOR
  ENDIF
 ENDIF
 CALL echo (concat ("pt_bContributorSystem_Ind: " ,build (pt_bcontributorsystem_ind ) ) )
 DECLARE pt_brank_ind = i2 WITH protect ,noconstant (0 )
 CALL echo ("parameter OPT_RANK" )
 RECORD opt_ranklist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
     2 value_f8 = f8
 )
 IF ((((validate (opt_rank ,"Z" ) = "Z" ) ) OR ((validate (opt_rank ,"Y" ) = "Y" ) )) )
  SET msg = "parameter OPT_RANK does not exist."
  SET retval = - (1 )
  GO TO endprogram
 ELSE
  SET orig_param = opt_rank
  EXECUTE eks_t_parse_list WITH replace (reply ,opt_ranklist )
  FREE SET orig_param
  IF ((opt_ranklist->cnt <= 0 ) )
   SET pt_brank_ind = 0
   CALL echo ("template is running without parameter OPT_RANK specified" )
  ELSE
   SET pt_brank_ind = 1
   FOR (pv_itemp = 1 TO opt_ranklist->cnt )
    IF ((isnumeric (opt_ranklist->qual[pv_itemp ].value ) = 0 ) )
     IF ((cnvtlower (trim (opt_ranklist->qual[pv_itemp ].value ) ) = "*not specified" ) )
      SET opt_ranklist->qual[pv_itemp ].value = "0"
      CALL echo (" change hidden value to 0 for *not specified." )
     ENDIF
    ELSE
     SET opt_ranklist->qual[pv_itemp ].value_f8 = cnvtreal (opt_ranklist->qual[pv_itemp ].value )
    ENDIF
   ENDFOR
  ENDIF
 ENDIF
 CALL echo (concat ("pt_bRank_Ind: " ,build (pt_brank_ind ) ) )
 DECLARE pt_bcertainty_ind = i2 WITH protect ,noconstant (0 )
 CALL echo ("parameter - OPT_CERTAINTY" )
 RECORD opt_certaintylist (
   1 cnt = i4
   1 qual [* ]
     2 value = vc
     2 display = vc
     2 value_f8 = f8
 )
 IF ((((validate (opt_certainty ,"Z" ) = "Z" ) ) OR ((validate (opt_certainty ,"Y" ) = "Y" ) )) )
  SET msg = "parameter OPT_CERTAINTY does not exist."
  SET retval = - (1 )
  GO TO endprogram
 ELSE
  SET orig_param = opt_certainty
  EXECUTE eks_t_parse_list WITH replace (reply ,opt_certaintylist )
  FREE SET orig_param
  IF ((opt_certaintylist->cnt <= 0 ) )
   SET pt_bcertainty_ind = 0
   CALL echo ("template is running without parameter OPT_CERTAINTY specified" )
  ELSE
   SET pt_bcertainty_ind = 1
   FOR (pv_itemp = 1 TO opt_certaintylist->cnt )
    IF ((isnumeric (opt_certaintylist->qual[pv_itemp ].value ) = 0 ) )
     IF ((cnvtlower (trim (opt_certaintylist->qual[pv_itemp ].value ) ) = "*not specified" ) )
      SET opt_certaintylist->qual[pv_itemp ].value = "0"
      CALL echo (" change hidden value to 0 for *not specified." )
     ENDIF
    ELSE
     SET opt_certaintylist->qual[pv_itemp ].value_f8 = cnvtreal (opt_certaintylist->qual[pv_itemp ].
      value )
    ENDIF
   ENDFOR
  ENDIF
 ENDIF
 CALL echo (concat ("pt_bCertainty_Ind: " ,build (pt_bcertainty_ind ) ) )
 DECLARE pt_blink_ind = i2 WITH protect ,noconstant (0 )
 DECLARE pv_ilink = i4 WITH protect ,noconstant (0 )
 IF ((((validate (opt_link ,"Z" ) = "Z" ) ) OR ((validate (opt_link ,"Y" ) = "Y" ) )) )
  SET msg = "OPT_LINK variable does not exist"
  SET retval = - (1 )
  GO TO endprogram
 ELSE
  IF ((isnumeric (trim (opt_link ) ) = 0 ) )
   SET pt_blink_ind = 0
   CALL echo ("template is running without parameter OPT_LINK" )
  ELSE
   SET pt_blink_ind = 1
   SET pv_ilink = cnvtint (opt_link )
   SET pt_dpersonid = eksdata->tqual[tinx ].qual[pv_ilink ].person_id
   SET pt_dencntrid = eksdata->tqual[tinx ].qual[pv_ilink ].encntr_id
   IF ((pt_dencntrid = 0 ) )
    SET retval = - (1 )
    SET msg = "OPT_LINK is not empty, but linked encounter id is 0"
    GO TO endprogram
   ENDIF
   SET pt_daccessionid = eksdata->tqual[tinx ].qual[pv_ilink ].accession_id
   SET pt_dorderid = eksdata->tqual[tinx ].qual[pv_ilink ].order_id
  ENDIF
 ENDIF
 CALL echo (concat ("pt_bLink_Ind: " ,build (pt_blink_ind ) ,"   pv_iLink: " ,build (pv_ilink ) ) )
 CALL echo (concat (" pt_dPersonId: " ,build (pt_dpersonid ) ) )
 CALL echo (concat (" pt_dEncntrId: " ,build (pt_dencntrid ) ) )
 CALL echo (concat (" pt_dAccessionId: " ,build (pt_daccessionid ) ) )
 CALL echo (concat (" pt_dOrderId: " ,build (pt_dorderid ) ) )
 IF ((pt_bdiagnosis_ind = 0 )
 AND (pt_bqualifier_ind = 0 )
 AND (pt_bconfirmation_ind = 0 )
 AND (pt_bclassification_ind = 0 )
 AND (pt_bclinicalservice_ind = 0 )
 AND (pt_bdxtype_ind = 0 )
 AND (pt_bseverityclass_ind = 0 )
 AND (pt_bseverity_ind = 0 )
 AND (pt_bcontributorsystem_ind = 0 )
 AND (pt_brank_ind = 0 )
 AND (pt_bcertainty_ind = 0 )
 AND (pt_blink_ind = 0 ) )
  SET msg = "At least one of parameters need to be filled. "
  SET retval = - (1 )
  GO TO endprogram
 ENDIF
 CALL echo (concat (format (curdate ,"dd-mmm-yyyy;;d" ) ," " ,format (curtime3 ,"hh:mm:ss.cc;3;m" ) ,
   "... End of Checking existence and validity of template parameters ..." ) ,1 ,0 )
 DECLARE pt_iqualifier = i4 WITH protect ,noconstant (0 )
 DECLARE pt_iconfirmation = i4 WITH protect ,noconstant (0 )
 DECLARE pt_iclassification = i4 WITH protect ,noconstant (0 )
 DECLARE pt_iclinicalservice = i4 WITH protect ,noconstant (0 )
 DECLARE pt_idxtype = i4 WITH protect ,noconstant (0 )
 DECLARE pt_iseverityclass = i4 WITH protect ,noconstant (0 )
 DECLARE pt_iseverity = i4 WITH protect ,noconstant (0 )
 DECLARE pt_icontributorsystem = i4 WITH protect ,noconstant (0 )
 DECLARE pt_irank = i4 WITH protect ,noconstant (0 )
 DECLARE pt_icertainty = i4 WITH protect ,noconstant (0 )
 SELECT
  IF ((pt_blink_ind = 0 ) )
   FROM (diagnosis ds )
   PLAN (ds
    WHERE (ds.person_id = pt_dpersonid )
    AND (ds.active_ind = 1 )
    AND (cnvtdatetime (curdate ,curtime3 ) BETWEEN ds.beg_effective_dt_tm AND ds.end_effective_dt_tm
    )
    AND ((expand (pt_iqualifier ,1 ,opt_qualifierlist->cnt ,ds.conditional_qual_cd ,opt_qualifierlist
     ->qual[pt_iqualifier ].value_f8 )
    AND (pt_bqualifier_ind = 1 ) ) OR ((pt_bqualifier_ind = 0 ) ))
    AND ((expand (pt_iconfirmation ,1 ,opt_confirmationlist->cnt ,ds.confirmation_status_cd ,
     opt_confirmationlist->qual[pt_iconfirmation ].value_f8 )
    AND (pt_bconfirmation_ind = 1 ) ) OR ((pt_bconfirmation_ind = 0 ) ))
    AND ((expand (pt_iclassification ,1 ,opt_classificationlist->cnt ,ds.classification_cd ,
     opt_classificationlist->qual[pt_iclassification ].value_f8 )
    AND (pt_bclassification_ind = 1 ) ) OR ((pt_bclassification_ind = 0 ) ))
    AND ((expand (pt_iclinicalservice ,1 ,opt_clinical_servicelist->cnt ,ds.clinical_service_cd ,
     opt_clinical_servicelist->qual[pt_iclinicalservice ].value_f8 )
    AND (pt_bclinicalservice_ind = 1 ) ) OR ((pt_bclinicalservice_ind = 0 ) ))
    AND ((expand (pt_idxtype ,1 ,opt_dx_typelist->cnt ,ds.diag_type_cd ,opt_dx_typelist->qual[
     pt_idxtype ].value_f8 )
    AND (pt_bdxtype_ind = 1 ) ) OR ((pt_bdxtype_ind = 0 ) ))
    AND ((expand (pt_iseverityclass ,1 ,opt_severity_classlist->cnt ,ds.severity_class_cd ,
     opt_severity_classlist->qual[pt_iseverityclass ].value_f8 )
    AND (pt_bseverityclass_ind = 1 ) ) OR ((pt_bseverityclass_ind = 0 ) ))
    AND ((expand (pt_iseverity ,1 ,opt_severitylist->cnt ,ds.severity_cd ,opt_severitylist->qual[
     pt_iseverity ].value_f8 )
    AND (pt_bseverity_ind = 1 ) ) OR ((pt_bseverity_ind = 0 ) ))
    AND ((expand (pt_icontributorsystem ,1 ,opt_contributor_systemlist->cnt ,ds
     .contributor_system_cd ,opt_contributor_systemlist->qual[pt_icontributorsystem ].value_f8 )
    AND (pt_bcontributorsystem_ind = 1 ) ) OR ((pt_bcontributorsystem_ind = 0 ) ))
    AND ((expand (pt_irank ,1 ,opt_ranklist->cnt ,ds.ranking_cd ,opt_ranklist->qual[pt_irank ].
     value_f8 )
    AND (pt_brank_ind = 1 ) ) OR ((pt_brank_ind = 0 ) ))
    AND ((expand (pt_icertainty ,1 ,opt_certaintylist->cnt ,ds.certainty_cd ,opt_certaintylist->qual[
     pt_icertainty ].value_f8 )
    AND (pt_bcertainty_ind = 1 ) ) OR ((pt_bcertainty_ind = 0 ) )) )
  ELSE
   FROM (diagnosis ds )
   PLAN (ds
    WHERE ((ds.person_id + 0 ) = pt_dpersonid )
    AND (ds.encntr_id = pt_dencntrid )
    AND (ds.active_ind = 1 )
    AND (cnvtdatetime (curdate ,curtime3 ) BETWEEN ds.beg_effective_dt_tm AND ds.end_effective_dt_tm
    )
    AND ((expand (pt_iqualifier ,1 ,opt_qualifierlist->cnt ,ds.conditional_qual_cd ,opt_qualifierlist
     ->qual[pt_iqualifier ].value_f8 )
    AND (pt_bqualifier_ind = 1 ) ) OR ((pt_bqualifier_ind = 0 ) ))
    AND ((expand (pt_iconfirmation ,1 ,opt_confirmationlist->cnt ,ds.confirmation_status_cd ,
     opt_confirmationlist->qual[pt_iconfirmation ].value_f8 )
    AND (pt_bconfirmation_ind = 1 ) ) OR ((pt_bconfirmation_ind = 0 ) ))
    AND ((expand (pt_iclassification ,1 ,opt_classificationlist->cnt ,ds.classification_cd ,
     opt_classificationlist->qual[pt_iclassification ].value_f8 )
    AND (pt_bclassification_ind = 1 ) ) OR ((pt_bclassification_ind = 0 ) ))
    AND ((expand (pt_iclinicalservice ,1 ,opt_clinical_servicelist->cnt ,ds.clinical_service_cd ,
     opt_clinical_servicelist->qual[pt_iclinicalservice ].value_f8 )
    AND (pt_bclinicalservice_ind = 1 ) ) OR ((pt_bclinicalservice_ind = 0 ) ))
    AND ((expand (pt_idxtype ,1 ,opt_dx_typelist->cnt ,ds.diag_type_cd ,opt_dx_typelist->qual[
     pt_idxtype ].value_f8 )
    AND (pt_bdxtype_ind = 1 ) ) OR ((pt_bdxtype_ind = 0 ) ))
    AND ((expand (pt_iseverityclass ,1 ,opt_severity_classlist->cnt ,ds.severity_class_cd ,
     opt_severity_classlist->qual[pt_iseverityclass ].value_f8 )
    AND (pt_bseverityclass_ind = 1 ) ) OR ((pt_bseverityclass_ind = 0 ) ))
    AND ((expand (pt_iseverity ,1 ,opt_severitylist->cnt ,ds.severity_cd ,opt_severitylist->qual[
     pt_iseverity ].value_f8 )
    AND (pt_bseverity_ind = 1 ) ) OR ((pt_bseverity_ind = 0 ) ))
    AND ((expand (pt_icontributorsystem ,1 ,opt_contributor_systemlist->cnt ,ds
     .contributor_system_cd ,opt_contributor_systemlist->qual[pt_icontributorsystem ].value_f8 )
    AND (pt_bcontributorsystem_ind = 1 ) ) OR ((pt_bcontributorsystem_ind = 0 ) ))
    AND ((expand (pt_irank ,1 ,opt_ranklist->cnt ,ds.ranking_cd ,opt_ranklist->qual[pt_irank ].
     value_f8 )
    AND (pt_brank_ind = 1 ) ) OR ((pt_brank_ind = 0 ) ))
    AND ((expand (pt_icertainty ,1 ,opt_certaintylist->cnt ,ds.certainty_cd ,opt_certaintylist->qual[
     pt_icertainty ].value_f8 )
    AND (pt_bcertainty_ind = 1 ) ) OR ((pt_bcertainty_ind = 0 ) )) )
  ENDIF
  ORDER BY ds.diagnosis_id
  HEAD REPORT
   nomendata->nomen_cnt = 0 ,
   nomendata->stop_ind = 0 ,
   nomendata->match_cnt = 0
  DETAIL
   nomendata->nomen_cnt = (nomendata->nomen_cnt + 1 ) ,
   stat = alterlist (nomendata->nomen_qual ,nomendata->nomen_cnt ) ,
   nomendata->nomen_qual[nomendata->nomen_cnt ].nomenclature_id = ds.originating_nomenclature_id ,
   nomendata->nomen_qual[nomendata->nomen_cnt ].misc_id = ds.diagnosis_id ,
   nomendata->nomen_qual[nomendata->nomen_cnt ].misc_instance_id = ds.diagnosis_group ,
   nomendata->nomen_qual[nomendata->nomen_cnt ].ccki = "" ,
   IF ((opt_diagnosislist->cnt > 0 ) ) nomendata->nomen_qual[nomendata->nomen_cnt ].match_ind = 0
   ELSE nomendata->nomen_qual[nomendata->nomen_cnt ].match_ind = 1 ,nomendata->match_cnt = (nomendata
    ->match_cnt + 1 )
   ENDIF
  WITH nocounter
 ;end select
 IF ((nomendata->nomen_cnt > 0 ) )
  CALL echo (concat ("Found " ,trim (cnvtstring (nomendata->nomen_cnt ) ) ,
    " diagnosis in Diagnosis table " ," that match the criteria." ) )
  IF ((opt_diagnosislist->cnt > 0 ) )
   IF ((stop_search_pos > 0 ) )
    SET nomendata->stop_ind = 1
    CALL echo ("Calling eks_t_nomenclature_check from a logic template using EVOKE search mode!" )
   ENDIF
   CALL validatenewparameter (0 )
   EXECUTE eks_t_nomenclature_check WITH replace (ruledata ,opt_diagnosislist )
  ENDIF
  IF ((nomendata->match_cnt > 0 ) )
   SET retval = 100
   SET msg = concat ("Found " ,trim (cnvtstring (nomendata->match_cnt ) ) ,
    " diagnosis matching specified criteria." )
  ELSE
   SET retval = 0
   SET msg = "No diagnosis found matching specified criteria."
  ENDIF
 ELSE
  SET retval = 0
  SET msg = "No qualifying diagnosis found in Diagnosis table."
 ENDIF
 SUBROUTINE  validatenewparameter (_null )
  CALL echo (".... in ValidateNewParameter ...." )
  RECORD opt_cross_vocabslist (
    1 cnt = i4
    1 qual [* ]
      2 value = vc
      2 display = vc
  )
  IF ((validate (opt_cross_vocabs ,"Z" ) = "Z" )
  AND (validate (opt_cross_vocabs ,"Y" ) = "Y" ) )
   CALL echo ("Parameter OPT_CROSS_VOCABS does not exist!" )
   SET nomendata->cross_vocabs_cnt = 0
  ELSEIF ((((trim (opt_cross_vocabs ) < " " ) ) OR ((trim (opt_cross_vocabs ) = "<undefined>" ) )) )
   CALL echo ("Optional parameter OPT_CROSS_VOCABS is not defined." )
   SET nomendata->cross_vocabs_cnt = 0
  ELSE
   CALL echo ("Checking OPT_CROSS_VOCABS." )
   SET orig_param = opt_cross_vocabs
   EXECUTE eks_t_parse_list WITH replace (reply ,opt_cross_vocabslist )
   FREE SET orig_param
   IF ((opt_cross_vocabslist->cnt <= 0 ) )
    CALL echo ("No entries in the parameter OPT_CROSS_VOCABS. Ignore." )
    SET nomendata->cross_vocabs_cnt = 0
   ELSEIF ((opt_cross_vocabslist->cnt = 1 ) )
    IF ((cnvtupper (trim (opt_cross_vocabslist->qual[1 ].display ,3 ) ) = "*ALL" ) )
     SET nomendata->cross_vocabs_cnt = 0
    ELSEIF ((cnvtupper (trim (opt_cross_vocabslist->qual[1 ].display ,3 ) ) = "*NONE" ) )
     SET nomendata->cross_vocabs_cnt = - (1 )
    ELSE
     SET nomendata->cross_vocabs_cnt = 1
     SET stat = alterlist (nomendata->cross_vocabs ,nomendata->cross_vocabs_cnt )
     SET nomendata->cross_vocabs[nomendata->cross_vocabs_cnt ].vocab_cd = cnvtreal (
      opt_cross_vocabslist->qual[1 ].value )
    ENDIF
   ELSE
    SET nomendata->cross_vocabs_cnt = opt_cross_vocabslist->cnt
    SET stat = alterlist (nomendata->cross_vocabs ,nomendata->cross_vocabs_cnt )
    SET i = 0
    FOR (i = 1 TO opt_cross_vocabslist->cnt )
     IF ((trim (opt_cross_vocabslist->qual[i ].value ) IN ("*ALL" ,
     "*NONE" ) ) )
      SET retval = 0
      SET msg = concat ("one of the OPT_CORSS_VOCABS options is " ,trim (opt_cross_vocabslist->qual[
        i ].display ) ,", so only ONE option is allowed." )
      GO TO endprogram
     ELSE
      SET nomendata->cross_vocabs[i ].vocab_cd = cnvtreal (opt_cross_vocabslist->qual[i ].value )
     ENDIF
    ENDFOR
   ENDIF
  ENDIF
  CALL echo (concat ("nomendata->cross_vocabs_cnt: " ,build (nomendata->cross_vocabs_cnt ) ) )
  IF ((validate (opt_person_activity ,"Z" ) = "Z" )
  AND (validate (opt_person_activity ,"Y" ) = "Y" ) )
   CALL echo ("Parameter OPT_PERSON_ACTIVITY does not exist!" )
   SET nomendata->cross_patient_ind = 1
  ELSEIF ((((trim (opt_person_activity ) < " " ) ) OR ((trim (opt_person_activity ) = "<undefined>"
  ) )) )
   CALL echo ("Optional parameter OPT_PERSON_ACTIVITY is not defined." )
   SET nomendata->cross_patient_ind = 1
  ELSE
   CALL echo (concat ("optional parameter OPT_PERSON_ACTIVITY: " ,build (opt_person_activity ) ) )
   IF ((cnvtupper (trim (opt_person_activity ) ) = "INCLUDING" ) )
    SET nomendata->cross_patient_ind = 1
   ELSEIF ((cnvtupper (trim (opt_person_activity ) ) = "EXCLUDING" ) )
    SET nomendata->cross_patient_ind = 0
   ELSE
    SET retval = 0
    SET msg = concat ("invalid option found - " ,trim (opt_person_activity ) )
    GO TO endprogram
   ENDIF
  ENDIF
  CALL echo (concat ("nomendata->cross_patient_ind: " ,build (nomendata->cross_patient_ind ) ) )
  IF ((validate (opt_vocab_hierarchy ,"Z" ) = "Z" )
  AND (validate (opt_vocab_hierarchy ,"Y" ) = "Y" ) )
   CALL echo ("Parameter OPT_VOCAB_HIERARCHY does not exist!" )
   SET nomendata->hierarchy_ind = 1
  ELSEIF ((((trim (opt_vocab_hierarchy ) < " " ) ) OR ((trim (opt_vocab_hierarchy ) = "<undefined>"
  ) )) )
   CALL echo ("Optional parameter OPT_VOCAB_HIERARCHY is not defined." )
   SET nomendata->hierarchy_ind = 1
  ELSE
   CALL echo (concat ("optional parameter OPT_VOCAB_HIERARCHY: " ,build (opt_vocab_hierarchy ) ) )
   IF ((cnvtupper (trim (opt_vocab_hierarchy ) ) = "INCLUDE" ) )
    SET nomendata->hierarchy_ind = 1
   ELSEIF ((cnvtupper (trim (opt_vocab_hierarchy ) ) = "EXCLUDE" ) )
    SET nomendata->hierarchy_ind = 0
   ELSE
    SET retval = 0
    SET msg = concat ("invalid option found - " ,trim (opt_vocab_hierarchy ) )
    GO TO endprogram
   ENDIF
  ENDIF
  CALL echo (concat ("nomendata->hierarchy_ind: " ,build (nomendata->hierarchy_ind ) ) )
  IF ((validate (opt_ignore_concepts ,"Z" ) = "Z" )
  AND (validate (opt_ignore_concepts ,"Y" ) = "Y" ) )
   CALL echo ("Parameter OPT_IGNORE_CONCEPTS does not exist!" )
   SET nomendata->ignore_concepts_ind = 0
  ELSEIF ((((trim (opt_ignore_concepts ) < " " ) ) OR ((trim (opt_ignore_concepts ) = "<undefined>"
  ) )) )
   CALL echo ("Optional parameter OPT_VOCAB_HIERARCHY is not defined." )
   SET nomendata->ignore_concepts_ind = 0
  ELSE
   CALL echo (concat ("optional parameter OPT_IGNORE_CONCEPTS: " ,build (opt_ignore_concepts ) ) )
   IF ((cnvtupper (trim (opt_ignore_concepts ) ) = "YES" ) )
    SET nomendata->ignore_concepts_ind = 1
   ELSEIF ((cnvtupper (trim (opt_ignore_concepts ) ) = "NO" ) )
    SET nomendata->ignore_concepts_ind = 0
   ELSE
    SET retval = 0
    SET msg = concat ("invalid option found - " ,trim (opt_ignore_concepts ) )
    GO TO endprogram
   ENDIF
  ENDIF
  CALL echo (concat ("nomendata->ignore_concepts_ind: " ,build (nomendata->ignore_concepts_ind ) ) )
  IF ((validate (opt_match_all ,"Z" ) = "Z" )
  AND (validate (opt_match_all ,"Y" ) = "Y" ) )
   CALL echo ("Parameter OPT_MATCH_ALL does not exist!" )
   SET nomendata->all_matches_ind = 1
  ELSEIF ((((trim (opt_match_all ) < " " ) ) OR ((trim (opt_match_all ) = "<undefined>" ) )) )
   CALL echo ("Optional parameter OPT_MATCH_ALL is not defined." )
   SET nomendata->all_matches_ind = 1
  ELSE
   CALL echo (concat ("optional parameter OPT_MATCH_ALL: " ,build (opt_match_all ) ) )
   IF ((cnvtupper (trim (opt_match_all ) ) = "YES" ) )
    SET nomendata->all_matches_ind = 1
   ELSEIF ((cnvtupper (trim (opt_match_all ) ) = "NO" ) )
    SET nomendata->all_matches_ind = 0
   ELSE
    SET retval = 0
    SET msg = concat ("invalid option found - " ,trim (opt_match_all ) )
    GO TO endprogram
   ENDIF
  ENDIF
  CALL echo (concat ("nomendata->all_matches_ind: " ,build (nomendata->all_matches_ind ) ) )
 END ;Subroutine
#endprogram
 SET msg = concat (msg ,"(" ,trim (format ((maxval (0 ,(curtime3 - tempstarttime ) ) / 100.0 ) ,
    "######.##" ) ,3 ) ,"s)" )
 CALL echo (msg )
 CALL echo (concat ("curindex: " ,build (curindex ) ) )
 SET eksdata->tqual[tcurindex ].qual[curindex ].logging = msg
 DECLARE pv_itemp_cnt = i4 WITH private ,noconstant (0 )
 IF ((tcurindex > 0 )
 AND (curindex > 0 ) )
  SET eksdata->tqual[tcurindex ].qual[curindex ].person_id = pt_dpersonid
  SET eksdata->tqual[tcurindex ].qual[curindex ].encntr_id = pt_dencntrid
  SET eksdata->tqual[tcurindex ].qual[curindex ].order_id = pt_dorderid
  SET eksdata->tqual[tcurindex ].qual[curindex ].accession_id = pt_daccessionid
  SET stat = alterlist (eksdata->tqual[tcurindex ].qual[curindex ].data ,(nomendata->match_cnt + 1 )
   )
  SET eksdata->tqual[tcurindex ].qual[curindex ].cnt = nomendata->match_cnt
  SET eksdata->tqual[tcurindex ].qual[curindex ].data[1 ].misc = "<DIAGNOSIS_ID>"
  FOR (pv_itemp = 1 TO nomendata->nomen_cnt )
   IF ((nomendata->nomen_qual[pv_itemp ].match_ind > 0 ) )
    SET pv_itemp_cnt = (pv_itemp_cnt + 1 )
    SET eksdata->tqual[tcurindex ].qual[curindex ].data[(pv_itemp_cnt + 1 ) ].misc = trim (
     cnvtstring (nomendata->nomen_qual[pv_itemp ].misc_id ,25 ,1 ) )
   ENDIF
  ENDFOR
 ELSE
  IF ((retval = - (1 ) ) )
   SET retval = 0
  ENDIF
 ENDIF
 CALL echo (concat (format (curdate ,"dd-mmm-yyyy;;d" ) ," " ,format (curtime3 ,"hh:mm:ss.cc;3;m" ) ,
   "  *******    End of Program EKS_T_DIAGNOSIS_FIND     *********" ) ,1 ,0 )
END GO
