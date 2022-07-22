/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		03/30/2020
	Solution:			
	Source file name:	cov_celr_mobj_oru_out.prg
	Object name:		cov_celr_mobj_oru_out
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Copied from celr_mobj_oru_out, called from OP_CELR_MORG_DRIVER
 	
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	03/30/2020  Chad Cummings			Initial Release
001     07/23/2020  Chad Cummings 			Hard Coded version for testing
******************************************************************************/
DROP PROGRAM cov_celr_mobj_oru_out :dba GO
CREATE PROGRAM cov_celr_mobj_oru_out :dba
 
 SET current_program = curprog
 EXECUTE oencpm_msglog build ("Starting-" ,current_program ,char (0 ) )
 
 FREE SET messg_type
 IF (validate (oen_reply->control_group[1 ].msh[1 ].message_type.messg_type ) )
  SET messg_type = oen_reply->control_group[1 ].msh[1 ].message_type.messg_type
 ELSE
  SET messg_type = ""
 ENDIF
 
 FREE SET messg_trigger
 IF (validate (oen_reply->control_group[1 ].msh[1 ].message_type.messg_trigger ) )
  SET messg_trigger = oen_reply->control_group[1 ].msh[1 ].message_type.messg_trigger
 ELSE
  SET messg_trigger = ""
 ENDIF
 
 FREE SET version_id
 IF (validate (oen_reply->control_group[1 ].msh[1 ].version.version_id ) )
  SET version_id = oen_reply->control_group[1 ].msh[1 ].version.version_id
 ELSE
  SET version_id = "2.5.1" ;001
 ENDIF
 
 IF ((((messg_type != "ORU" ) ) OR ((((messg_trigger != "R01" ) ) OR ((version_id != "2.5.1" ) )) )))
  EXECUTE oencpm_msglog build("Non-ORU R01 transaction being ignored:" ,messg_type ,"-" , messg_trigger ,"-" ,version_id,char(0))
  SET oenstatus->ignore = 1
  GO TO exit_script
 ENDIF
 

%i cust_script:cov_getfipscode.inc
 
 DECLARE org_name_id = vc WITH protect
 DECLARE org_univ_id = vc WITH protect
 DECLARE org_univ_id_type = vc WITH protect
 DECLARE cur_order_id = f8 WITH protect
 DECLARE parent_order_id = f8 WITH protect
 DECLARE obx_4_routine_arg = i4 WITH noconstant (0 ) ,protect
 DECLARE pos = i4 WITH protect
 DECLARE idx = i4 WITH protect
 DECLARE tmp_str1 = vc WITH protect
 DECLARE tmp_str2 = vc WITH protect
 DECLARE tmp_id1 = f8 WITH protect
 DECLARE cnt1 = i4 WITH protect
 DECLARE nok_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,351 ,"NOK" ) ) ,protect
 DECLARE guardian_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,351 ,"GUARDIAN" ) ) ,protect
 DECLARE employer_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,338 ,"EMPLOYER" ) ) ,protect
 DECLARE current_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,213 ,"CURRENT" ) ) ,protect
 DECLARE home_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,212 ,"HOME" ) ) ,protect
 DECLARE email_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,23056 ,"MAILTO" ) ) ,protect
 DECLARE tel_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,23056 ,"TEL" ) ) ,protect
 DECLARE alternate_phone_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,43 ,"ALTERNATE" ) ) , protect
 DECLARE business_phone_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,43 ,"BUSINESS" ) ) , protect
 DECLARE pager_bus_phone_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,43 ,"PAGER BUS" ) ) , protect
 DECLARE business_address_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,212 ,"BUSINESS" ) ) , protect
 DECLARE high_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,52 ,"HIGH" ) ) ,protect
 DECLARE abnormal_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,52 ,"ABNORMAL" ) ) ,protect
 DECLARE critical_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,52 ,"CRITICAL" ) ) ,protect
 DECLARE verify_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,21 ,"VERIFY" ) ) ,protect
 DECLARE modify_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,21 ,"MODIFY" ) ) ,protect
 DECLARE prsnl_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,213 ,"PRSNL" ) ) ,protect
 DECLARE loinc_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,73 ,"LOINC" ) ) ,protect
 DECLARE hl7v2_cd = f8 WITH constant (uar_get_code_by ("MEANING" ,73 ,"HL7V2" ) ) ,protect
 DECLARE micinterp_cd = f8 WITH constant (uar_get_code_by ("DISPLAYKEY" ,1004 ,"MIC INTERP" ) ) , protect
 
%i cust_script:cov_celr_mobj_oru_out_sub.inc
 
 DECLARE queue_id = f8
 SET queue_id = cnvtreal (get_double_value ("queue_id" ) )
 EXECUTE oencpm_msglog build ("queue_id-" ,queue_id ,char (0 ) )
 
 DECLARE trigger_id = f8
 SET trigger_id = cnvtreal (get_double_value ("trigger_id" ) )
 EXECUTE oencpm_msglog build ("trigger_id-" ,trigger_id ,char (0 ) )
 
 DECLARE prim_cont_source_cd = f8
 SET prim_cont_source_cd = cnvtreal (get_double_value ("contributor_source_cd" ) )
 EXECUTE oencpm_msglog build ("prim_cont_source_cd-" ,prim_cont_source_cd ,char (0 ) )
 
 DECLARE person_id = f8
 SET person_id = cnvtreal (get_double_value ("person_id" ) )
 EXECUTE oencpm_msglog build ("person_id-" ,person_id ,char (0 ) )

 DECLARE encntr_id = f8
 SET encntr_id = cnvtreal (get_double_value ("encntr_id" ) )
 EXECUTE oencpm_msglog build ("encntr_id-" ,encntr_id ,char (0 ) )
 
 DECLARE organization_id = f8
 SET organization_id = cnvtreal (get_double_value ("organization_id" ) )
 EXECUTE oencpm_msglog build ("organization_id-" ,organization_id ,char (0 ) )

 DECLARE cqm_class = vc
 SET cqm_class = get_string_value ("cqm_class" )
 EXECUTE oencpm_msglog build ("cqm_class-" ,cqm_class ,char (0 ) )
 
 DECLARE cqm_type = vc
 SET cqm_type = get_string_value ("cqm_type" )
 EXECUTE oencpm_msglog build ("cqm_type-" ,cqm_type ,char (0 ) )
 
 DECLARE cqm_subtype = vc
 SET cqm_subtype = get_string_value ("cqm_subtype" )
 EXECUTE oencpm_msglog build ("cqm_subtype-" ,cqm_subtype ,char (0 ) )
 
 FREE RECORD data
 RECORD data (
   1 qual [* ]
     2 routine_argument = vc
 )
 
 EXECUTE oencpm_msglog build ("** START Finding ESO Routine Arguments" ,char (0 ) )
 SELECT INTO "nl:"
  FROM (cqm_fsieso_tr_1 cft ),
   (eso_trigger et ),
   (eso_trig_routine_r etr )
  PLAN (cft
   WHERE (cft.trigger_id = trigger_id )
   AND (cft.queue_id = queue_id )
   AND (cft.active_ind = 1 ) )
   JOIN (et
   WHERE (et.trigger_id = cft.eso_trigger_id )
   AND (et.active_ind = 1 ) )
   JOIN (etr
   WHERE (etr.trigger_id = et.trigger_id )
   AND (etr.routine_args != null )
   AND (etr.routine_args > " " )
   AND (etr.active_ind = 1 ) )
  HEAD REPORT
   cnt1 = 0 ,
   idx = 1
  DETAIL
   tmp_str1 = "" ,
   idx = 1 ,
   WHILE ((tmp_str1 != "<NOT FOUND>" ) )
    tmp_str1 = piece (etr.routine_args ,";" ,idx ,"<NOT FOUND>" ) ,
    IF ((tmp_str1 != "<NOT FOUND>" ) ) cnt1 = (cnt1 + 1 ) ,stat = alterlist (data->qual ,cnt1 ) ,data
     ->qual[cnt1 ].routine_argument = tmp_str1
    ENDIF
    ,idx = (idx + 1 )
   ENDWHILE
  WITH nocounter
 EXECUTE oencpm_msglog build ("** END  Finding ESO Routine Arguments" ,char (0 ) )



 EXECUTE oencpm_msglog build ("**START Finding obx_4_routine_arg" ,char (0 ) )
 FOR (loop1 = 1 TO size (data->qual ,5 ) )
  IF ((findstring ("OBX_4=" ,data->qual[loop1 ].routine_argument ) > 0 ) )
   SET obx_4_routine_arg = cnvtint (substring (7 ,1 ,data->qual[loop1 ].routine_argument ) )
  ENDIF
 ENDFOR
 EXECUTE oencpm_msglog build ("**END   Finding obx_4_routine_arg" ,char (0 ) )
 
 SET oen_reply->control_group[1 ].msh[1 ].sending_application.name_id 				= "HealthSentry"
 SET oen_reply->control_group[1 ].msh[1 ].sending_application.univ_id 				= "2.16.840.1.113883.3.13.2.2.1"
 SET oen_reply->control_group[1 ].msh[1 ].sending_application.univ_id_type 			= "ISO"
 SET oen_reply->control_group[1 ].msh[1 ].receiving_application.name_id 			= "CDPH CA REDIE"
 SET oen_reply->control_group[1 ].msh[1 ].receiving_application.univ_id 			= "2.16.840.1.114222.4.3.3.10.1.1"
 SET oen_reply->control_group[1 ].msh[1 ].receiving_application.univ_id_type 		= "ISO"
 SET oen_reply->control_group[1 ].msh[1 ].receiving_facility.name_id 				= "CDPH_CID"
 SET oen_reply->control_group[1 ].msh[1 ].receiving_facility.univ_id 				= "2.16.840.1.114222.4.1.214104"
 SET oen_reply->control_group[1 ].msh[1 ].receiving_facility.univ_id_type 			= "ISO"
 SET oen_reply->control_group[1 ].msh[1 ].conform_statment[1 ].name_id 				= "HL7"
 SET oen_reply->control_group[1 ].msh[1 ].conform_statment[1 ].conform_statement_id = "PHLabReport-Ack"
 SET oen_reply->control_group[1 ].msh[1 ].conform_statment[1 ].univ_id 				= "2.16.840.1.113883.9.11"
 
 SET stat = alterlist (oen_reply->control_group[1 ].sft ,1 )
 SET oen_reply->control_group[1 ].sft[1 ].vendor_org.org_name 						= "Cerner Corporation"
 SET oen_reply->control_group[1 ].sft[1 ].vendor_org.org_name_type_cd 				= "D"
 SET oen_reply->control_group[1 ].sft[1 ].vendor_org.assign_authority.name_id 		= "HealthSentry"
 SET oen_reply->control_group[1 ].sft[1 ].vendor_org.assign_authority.univ_id 		= "2.16.840.1.113883.3.13.2.2.1"
 SET oen_reply->control_group[1 ].sft[1 ].vendor_org.assign_authority.univ_id_type 	= "ISO"
 SET oen_reply->control_group[1 ].sft[1 ].vendor_org.type_cd 						= "XX"
 SET oen_reply->control_group[1 ].sft[1 ].vendor_org.organization_id 				= "2168401113883313221"
 SET oen_reply->control_group[1 ].sft[1 ].version_or_release 						= "20101001"
 SET oen_reply->control_group[1 ].sft[1 ].product_name 								= "HealthSentry"
 SET oen_reply->control_group[1 ].sft[1 ].binary_id 								= "0100100001010011"
 SET oen_reply->control_group[1 ].sft[1 ].product_info 								= "HealthSentry"
 SET oen_reply->control_group[1 ].sft[1 ].install_date 								= "201010010800-0500"


EXECUTE oencpm_msglog build ("**START Finding Org si_oid" ,char (0 ) )
 SELECT INTO "nl"
  FROM (organization org ),
   (si_oid so )
  PLAN (org
   WHERE (org.organization_id = organization_id )
   AND (org.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
   AND (org.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
   AND (org.active_ind = 1 ) )
   JOIN (so
   WHERE (so.entity_id = outerjoin (org.organization_id ) )
   AND (so.entity_name = outerjoin ("ORGANIZATION" ) )
   AND (so.beg_effective_dt_tm <= outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
   AND (so.end_effective_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
   AND (so.active_ind = outerjoin (1 ) ) )
  HEAD REPORT
   org_name_id = org.org_name ,
   org_univ_id = so.oid_txt ,
   org_univ_id_type = "ISO"
  WITH nocounter
 EXECUTE oencpm_msglog build ("**END   Finding Org si_oid" ,char (0 ) )
 
 
 EXECUTE oencpm_msglog build ("**START Setting si_oid" ,char (0 ) )
 FOR (loop1 = 1 TO size (oen_reply->person_group[1 ].pat_group[1 ].pid.patient_id_int ,5 ) )
  IF ((textlen (trim (oen_reply->person_group[1 ].pat_group[1 ].pid.patient_id_int[loop1 ].assign_fac_id.name_id ) ) = 0 ) )
   SET oen_reply->person_group[1 ].pat_group[1 ].pid.patient_id_int[loop1 ].assign_fac_id.name_id =org_name_id
   SET oen_reply->person_group[1 ].pat_group[1 ].pid.patient_id_int[loop1 ].assign_fac_id.univ_id =org_univ_id
   SET oen_reply->person_group[1 ].pat_group[1 ].pid.patient_id_int[loop1 ].assign_fac_id.univ_id_type = org_univ_id_type
  ENDIF
 ENDFOR
 EXECUTE oencpm_msglog build ("**END  Setting si_oid" ,char (0 ) )
 
 EXECUTE oencpm_msglog build ("**START Getting Phone Information" ,char (0 ) )
 SELECT INTO "nl:"
  FROM (phone p )
  PLAN (p
   WHERE (p.parent_entity_id = oen_reply->cerner.person_info.person[1 ].person_id )
   AND (p.parent_entity_name IN ("PERSON" , "PERSON_PATIENT" ) )
   AND (p.phone_type_cd = alternate_phone_cd )
   AND (p.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
   AND (p.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
   AND (p.active_ind = 1 ) )
  ORDER BY p.parent_entity_name
  HEAD REPORT
   ph_nbr_home_idx = size (oen_reply->person_group[1 ].pat_group[1 ].pid.ph_nbr_home ,5 )
  DETAIL
   ph_nbr_home_idx = (ph_nbr_home_idx + 1 ) ,
   stat = alterlist (oen_reply->person_group[1 ].pat_group[1 ].pid.ph_nbr_home ,ph_nbr_home_idx ) ,
   IF ((p.contact_method_cd = email_cd ) ) 
	oen_reply->person_group[1 ].pat_group[1 ].pid.ph_nbr_home[ph_nbr_home_idx ].telecom_use_cd = "NET" ,
	oen_reply->person_group[1 ].pat_group[1 ].pid.ph_nbr_home[ph_nbr_home_idx ].equip_type_cd = "Internet" ,
	oen_reply->person_group[1 ].pat_group[1 ].pid.ph_nbr_home[ph_nbr_home_idx ].email_address = p.phone_num
   ELSE 
	oen_reply->person_group[1 ].pat_group[1 ].pid.ph_nbr_home[ph_nbr_home_idx ].phone_nbr = p.phone_num ,
	oen_reply->person_group[1 ].pat_group[1 ].pid.ph_nbr_home[ph_nbr_home_idx ].telecom_use_cd = build ("CD:" ,p.phone_type_cd ) ,
	oen_reply->person_group[1 ].pat_group[1 ].pid.ph_nbr_home[ph_nbr_home_idx ].equip_type_cd = "PH"
   ENDIF
   ,
   IF (isnumeric (p.extension ) ) 
	oen_reply->person_group[1 ].pat_group[1 ].pid.ph_nbr_home[ph_nbr_home_idx ].extension = p.extension
   ELSE 
	oen_reply->person_group[1 ].pat_group[1 ].pid.ph_nbr_home[ph_nbr_home_idx ].text = p.extension
   ENDIF
   ,
   IF ((textlen (trim (p.call_instruction ) ) > 0 ) )
    IF ((textlen (trim (oen_reply->person_group[1 ].pat_group[1 ].pid.ph_nbr_home[ph_nbr_home_idx ].text ) ) > 0 ) ) 
		oen_reply->person_group[1 ].pat_group[1 ].pid.ph_nbr_home[ph_nbr_home_idx ].text 
			= concat (oen_reply->person_group[1 ].pat_group[1 ].pid.ph_nbr_home[ph_nbr_home_idx ].text ,"; " ,p.call_instruction )
    ELSE 
		oen_reply->person_group[1 ].pat_group[1 ].pid.ph_nbr_home[ph_nbr_home_idx ].text = p.call_instruction
    ENDIF
   ENDIF
  WITH nocounter
 EXECUTE oencpm_msglog build ("**END   Getting Phone Information" ,char (0 ) )
 
 
 EXECUTE oencpm_msglog build ("**START Getting Encounter Information" ,char (0 ) )
 SELECT INTO "nl:"
  FROM (encounter e )
  PLAN (e
   WHERE (e.person_id = oen_reply->cerner.person_info.person[1 ].person_id )
   AND (e.organization_id > 0.00 ) )
  ORDER BY e.updt_dt_tm DESC
  HEAD REPORT
   oen_reply->person_group[1 ].pat_group[1 ].pid.last_updt_dt_tm = formatisodate(e.updt_dt_tm,datetimezonebyname(curtimezone)),
   oen_reply->person_group[1 ].pat_group[1 ].pid.last_updt_facility.name_id = org_name_id ,
   oen_reply->person_group[1 ].pat_group[1 ].pid.last_updt_facility.univ_id = org_univ_id ,
   oen_reply->person_group[1 ].pat_group[1 ].pid.last_updt_facility.univ_id_type = org_univ_id_type
  WITH nocounter
 EXECUTE oencpm_msglog build ("**END  Getting Encounter Information" ,char (0 ) )
 
 EXECUTE oencpm_msglog build ("**Resetting NTE" ,char (0 ) )
 SET stat = alterlist (oen_reply->person_group[1 ].pat_group[1 ].nte ,0 )
 
 
 
 SELECT INTO "nl:"
  FROM (person_info pi ),
   (long_text lt )
  PLAN (pi
   WHERE (pi.person_id = oen_reply->cerner.person_info.person[1 ].person_id )
   AND (pi.info_type_cd = value (uar_get_code_by_cki ("CKI.CODEVALUE!4026" ) ) )
   AND (pi.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
   AND (pi.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
   AND (pi.active_ind = 1 ) )
   JOIN (lt
   WHERE (lt.long_text_id = pi.long_text_id )
   AND (lt.long_text_id > 0.00 )
   AND (lt.active_ind = 1 ) )
  ORDER BY pi.active_status_dt_tm DESC
  HEAD REPORT
   nte_idx = size (oen_reply->person_group[1 ].pat_group[1 ].nte ,5 )
  DETAIL
   nte_idx = (nte_idx + 1 ) ,
   stat = alterlist (oen_reply->person_group[1 ].pat_group[1 ].nte ,nte_idx ) ,
   oen_reply->person_group[1 ].pat_group[1 ].nte[nte_idx ].set_id = build (nte_idx ) ,
   IF ((pi.contributor_system_cd > 0.00 ) ) oen_reply->person_group[1 ].pat_group[1 ].nte[nte_idx ].
    src_of_comment = build ("CD:" ,pi.contributor_system_cd )
   ELSE oen_reply->person_group[1 ].pat_group[1 ].nte[nte_idx ].src_of_comment = "P"
   ENDIF
   ,stat = alterlist (oen_reply->person_group[1 ].pat_group[1 ].nte[nte_idx ].comment ,1 ) ,
   oen_reply->person_group[1 ].pat_group[1 ].nte[nte_idx ].comment[1 ].comment = replace (lt
    .long_text ,concat (char (13 ) ,char (10 ) ) ,"\.br\" ) ,
   oen_reply->person_group[1 ].pat_group[1 ].nte[nte_idx ].comment_type.identifier = build ("CD:" ,pi
    .info_type_cd )
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (encntr_info ei ),
   (long_text lt )
  PLAN (ei
   WHERE (ei.encntr_id = oen_reply->cerner.person_info.person[1 ].encntr_id )
   AND (ei.info_type_cd = value (uar_get_code_by_cki ("CKI.CODEVALUE!4026" ) ) )
   AND (ei.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
   AND (ei.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
   AND (ei.active_ind = 1 ) )
   JOIN (lt
   WHERE (lt.long_text_id = ei.long_text_id )
   AND (lt.long_text_id > 0.00 )
   AND (lt.active_ind = 1 ) )
  ORDER BY ei.active_status_dt_tm DESC
  HEAD REPORT
   nte_idx = size (oen_reply->person_group[1 ].pat_group[1 ].nte ,5 )
  DETAIL
   nte_idx = (nte_idx + 1 ) ,
   stat = alterlist (oen_reply->person_group[1 ].pat_group[1 ].nte ,nte_idx ) ,
   oen_reply->person_group[1 ].pat_group[1 ].nte[nte_idx ].set_id = build (nte_idx ) ,
   IF ((ei.contributor_system_cd > 0.00 ) ) oen_reply->person_group[1 ].pat_group[1 ].nte[nte_idx ].
    src_of_comment = build ("CD:" ,ei.contributor_system_cd )
   ELSE oen_reply->person_group[1 ].pat_group[1 ].nte[nte_idx ].src_of_comment = "P"
   ENDIF
   ,stat = alterlist (oen_reply->person_group[1 ].pat_group[1 ].nte[nte_idx ].comment ,1 ) ,
   oen_reply->person_group[1 ].pat_group[1 ].nte[nte_idx ].comment[1 ].comment = replace (lt
    .long_text ,concat (char (13 ) ,char (10 ) ) ,"\.br\" ) ,
   oen_reply->person_group[1 ].pat_group[1 ].nte[nte_idx ].comment_type.identifier = build ("CD:" ,ei
    .info_type_cd )
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (person_person_reltn ppr ),
   (person p )
  PLAN (ppr
   WHERE (ppr.person_id = oen_reply->cerner.person_info.person[1 ].person_id )
   AND (ppr.person_reltn_type_cd IN (nok_cd ,
   guardian_cd ) )
   AND (ppr.person_reltn_cd > 0.00 )
   AND (ppr.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
   AND (ppr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
   AND (ppr.active_ind = 1 ) )
   JOIN (p
   WHERE (p.person_id = ppr.related_person_id )
   AND (p.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
   AND (p.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
   AND (p.active_ind = 1 ) )
  ORDER BY ppr.person_person_reltn_id
  HEAD REPORT
   nk1_idx = 0
  HEAD ppr.person_person_reltn_id
   nk1_idx = (nk1_idx + 1 ) ,stat = alterlist (oen_reply->person_group[1 ].pat_group[1 ].nk1 ,
    nk1_idx ) ,oen_reply->person_group[1 ].pat_group[1 ].nk1[nk1_idx ].set_id = build (ppr
    .related_person_id ) ,oen_reply->person_group[1 ].pat_group[1 ].nk1[nk1_idx ].relationship.
   identifier = build ("CD:" ,ppr.person_reltn_cd )
  WITH nocounter
 ;end select
 FOR (loop1 = 1 TO size (oen_reply->person_group[1 ].pat_group[1 ].nk1 ,5 ) )
  SELECT INTO "nl:"
   FROM (person_org_reltn por ),
    (organization org ),
    (si_oid so )
   PLAN (por
    WHERE (por.person_id = cnvtreal (oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].set_id )
    )
    AND (por.person_org_reltn_cd = employer_cd )
    AND (por.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (por.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (por.active_ind = 1 ) )
    JOIN (org
    WHERE (org.organization_id = por.organization_id )
    AND (org.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (org.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (org.active_ind = 1 ) )
    JOIN (so
    WHERE (so.entity_id = outerjoin (org.organization_id ) )
    AND (so.entity_name = outerjoin ("ORGANIZATION" ) )
    AND (so.beg_effective_dt_tm <= outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
    AND (so.end_effective_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
    AND (so.active_ind = outerjoin (1 ) ) )
   HEAD REPORT
    stat = alterlist (oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].org_name ,1 ) ,
    oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].org_name[1 ].org_name = org.org_name ,
    oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].org_name[1 ].org_name_type_cd = "D" ,
    oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].org_name[1 ].assign_authority.name_id = org
    .org_name ,
    oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].org_name[1 ].assign_authority.univ_id = so
    .oid_txt ,
    oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].org_name[1 ].assign_authority.univ_id_type
    = "ISO" ,
    oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].org_name[1 ].type_cd = "XX" ,
    oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].org_name[1 ].organization_id = build (org
     .organization_id )
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (person_name pn )
   PLAN (pn
    WHERE (pn.person_id = cnvtreal (oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].set_id ) )
    AND (pn.name_type_cd = current_cd )
    AND (pn.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (pn.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (pn.active_ind = 1 ) )
   HEAD REPORT
    nk_name_idx = 0 ,
    nk_contact_person_name_idx = 0
   DETAIL
    IF ((size (oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].org_name ,5 ) = 0 ) )
     nk_name_idx = (nk_name_idx + 1 ) ,stat = alterlist (oen_reply->person_group[1 ].pat_group[1 ].
      nk1[loop1 ].nk_name ,nk_name_idx ) ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].
     nk_name[nk_name_idx ].last_name.last_name = pn.name_last ,oen_reply->person_group[1 ].pat_group[
     1 ].nk1[loop1 ].nk_name[nk_name_idx ].first_name = pn.name_first ,oen_reply->person_group[1 ].
     pat_group[1 ].nk1[loop1 ].nk_name[nk_name_idx ].middle_name = pn.name_middle ,oen_reply->
     person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_name[nk_name_idx ].suffix = pn.name_suffix ,
     oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_name[nk_name_idx ].prefix = pn
     .name_prefix ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_name[nk_name_idx ].
     name_type_cd = build ("CD:" ,pn.name_type_cd ) ,oen_reply->person_group[1 ].pat_group[1 ].nk1[
     loop1 ].nk_name[nk_name_idx ].professional_suffix = pn.name_degree
    ELSE nk_contact_person_name_idx = (nk_contact_person_name_idx + 1 ) ,stat = alterlist (oen_reply
      ->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_person_name ,
      nk_contact_person_name_idx ) ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].
     nk_contact_person_name[nk_contact_person_name_idx ].last_name.last_name = pn.name_last ,
     oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_person_name[
     nk_contact_person_name_idx ].first_name = pn.name_first ,oen_reply->person_group[1 ].pat_group[
     1 ].nk1[loop1 ].nk_contact_person_name[nk_contact_person_name_idx ].middle_name = pn
     .name_middle ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_person_name[
     nk_contact_person_name_idx ].suffix = pn.name_suffix ,oen_reply->person_group[1 ].pat_group[1 ].
     nk1[loop1 ].nk_contact_person_name[nk_contact_person_name_idx ].prefix = pn.name_prefix ,
     oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_person_name[
     nk_contact_person_name_idx ].name_type_cd = build ("CD:" ,pn.name_type_cd ) ,oen_reply->
     person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_person_name[nk_contact_person_name_idx ].
     professional_suffix = pn.name_degree
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (address a )
   PLAN (a
    WHERE (a.parent_entity_id = cnvtreal (oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].
     set_id ) )
    AND (a.parent_entity_name = "PERSON" )
    AND (a.address_type_cd = home_cd )
    AND (a.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (a.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (a.active_ind = 1 ) )
   HEAD REPORT
    nk_address_idx = 0 ,
    nk_contact_address_idx = 0
   DETAIL
    IF ((size (oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].org_name ,5 ) = 0 ) )
     nk_address_idx = (nk_address_idx + 1 ) ,stat = alterlist (oen_reply->person_group[1 ].pat_group[
      1 ].nk1[loop1 ].nk_address ,nk_address_idx ) ,oen_reply->person_group[1 ].pat_group[1 ].nk1[
     loop1 ].nk_address[nk_address_idx ].street.street = a.street_addr ,oen_reply->person_group[1 ].
     pat_group[1 ].nk1[loop1 ].nk_address[nk_address_idx ].other_desig = a.street_addr2 ,oen_reply->
     person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_address[nk_address_idx ].city = a.city ,
     IF ((a.state_cd > 0.00 ) ) oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_address[
      nk_address_idx ].state_prov = build ("CD:" ,a.state_cd )
     ELSE oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_address[nk_address_idx ].
      state_prov = a.state
     ENDIF
     ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_address[nk_address_idx ].zip_code = a
     .zipcode ,
     IF ((a.country_cd > 0.00 ) ) oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_address[
      nk_address_idx ].country = build ("CD:" ,a.country_cd )
     ELSE oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_address[nk_address_idx ].country
      = a.country
     ENDIF
     ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_address[nk_address_idx ].types =
     build ("CD:" ,a.address_type_cd ) ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].
     nk_address[nk_address_idx ].other_geo_desig = a.street_addr3 ,
     IF ((a.county_cd > 0.00 ) ) oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_address[
      nk_address_idx ].county = build ("CD:" ,a.county_cd )
     ELSE oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_address[nk_address_idx ].county =
      cnvtupper (a.county )
     ENDIF
    ELSE nk_contact_address_idx = (nk_contact_address_idx + 1 ) ,stat = alterlist (oen_reply->
      person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_address ,nk_contact_address_idx ) ,
     oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_address[nk_contact_address_idx
     ].street.street = a.street_addr ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].
     nk_contact_address[nk_contact_address_idx ].other_desig = a.street_addr2 ,oen_reply->
     person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_address[nk_contact_address_idx ].city = a
     .city ,
     IF ((a.state_cd > 0.00 ) ) oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].
      nk_contact_address[nk_contact_address_idx ].state_prov = build ("CD:" ,a.state_cd )
     ELSE oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_address[
      nk_contact_address_idx ].state_prov = a.state
     ENDIF
     ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_address[
     nk_contact_address_idx ].zip_code = a.zipcode ,
     IF ((a.country_cd > 0.00 ) ) oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].
      nk_contact_address[nk_contact_address_idx ].country = build ("CD:" ,a.country_cd )
     ELSE oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_address[
      nk_contact_address_idx ].country = a.country
     ENDIF
     ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_address[
     nk_contact_address_idx ].types = build ("CD:" ,a.address_type_cd ) ,oen_reply->person_group[1 ].
     pat_group[1 ].nk1[loop1 ].nk_contact_address[nk_contact_address_idx ].other_geo_desig = a
     .street_addr3 ,
     IF ((a.county_cd > 0.00 ) ) oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].
      nk_contact_address[nk_contact_address_idx ].county = build ("CD:" ,a.county_cd )
     ELSE oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_address[
      nk_contact_address_idx ].county = cnvtupper (a.county )
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SELECT INTO "nl:"
   FROM (phone p )
   PLAN (p
    WHERE (p.parent_entity_id = cnvtreal (oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].
     set_id ) )
    AND (p.parent_entity_name IN ("PERSON" ,
    "PERSON_PATIENT" ) )
    AND (p.contact_method_cd IN (email_cd ,
    tel_cd ) )
    AND (p.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
    AND (p.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
    AND (p.active_ind = 1 ) )
   ORDER BY p.parent_entity_name
   HEAD REPORT
    ph_nbr_home_idx = 0 ,
    nk_contact_phone_idx = 0
   DETAIL
    IF ((size (oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].org_name ,5 ) = 0 ) )
     ph_nbr_home_idx = (ph_nbr_home_idx + 1 ) ,stat = alterlist (oen_reply->person_group[1 ].
      pat_group[1 ].nk1[loop1 ].ph_nbr_home ,ph_nbr_home_idx ) ,
     CASE (p.contact_method_cd )
      OF tel_cd :
       oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].ph_nbr_home[ph_nbr_home_idx ].phone_nbr
       = p.phone_num ,
       oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].ph_nbr_home[ph_nbr_home_idx ].
       telecom_use_cd = build ("CD:" ,p.phone_type_cd ) ,
       oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].ph_nbr_home[ph_nbr_home_idx ].
       equip_type_cd = "PH"
      OF email_cd :
       oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].ph_nbr_home[ph_nbr_home_idx ].
       telecom_use_cd = "NET" ,
       oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].ph_nbr_home[ph_nbr_home_idx ].
       equip_type_cd = "Internet" ,
       oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].ph_nbr_home[ph_nbr_home_idx ].
       email_address = p.phone_num
     ENDCASE
     ,
     IF (isnumeric (p.extension ) ) oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].
      ph_nbr_home[ph_nbr_home_idx ].extension = p.extension
     ELSE oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].ph_nbr_home[ph_nbr_home_idx ].text =
      p.extension
     ENDIF
     ,
     IF ((textlen (trim (p.call_instruction ) ) > 0 ) )
      IF ((textlen (trim (oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].ph_nbr_home[
        ph_nbr_home_idx ].text ) ) > 0 ) ) oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].
       ph_nbr_home[ph_nbr_home_idx ].text = concat (oen_reply->person_group[1 ].pat_group[1 ].nk1[
        loop1 ].ph_nbr_home[ph_nbr_home_idx ].text ,"; " ,p.call_instruction )
      ELSE oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].ph_nbr_home[ph_nbr_home_idx ].text
       = p.call_instruction
      ENDIF
     ENDIF
    ELSE nk_contact_phone_idx = (nk_contact_phone_idx + 1 ) ,stat = alterlist (oen_reply->
      person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_phone ,nk_contact_phone_idx ) ,
     CASE (p.contact_method_cd )
      OF tel_cd :
       oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_phone[nk_contact_phone_idx ].
       phone_nbr = p.phone_num ,
       oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_phone[nk_contact_phone_idx ].
       telecom_use_cd = build ("CD:" ,p.phone_type_cd ) ,
       oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_phone[nk_contact_phone_idx ].
       equip_type_cd = "PH"
      OF email_cd :
       oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_phone[nk_contact_phone_idx ].
       telecom_use_cd = "NET" ,
       oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_phone[nk_contact_phone_idx ].
       equip_type_cd = "Internet" ,
       oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_phone[nk_contact_phone_idx ].
       email_address = p.phone_num
     ENDCASE
     ,
     IF (isnumeric (p.extension ) ) oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].
      nk_contact_phone[nk_contact_phone_idx ].extension = p.extension
     ELSE oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_phone[
      nk_contact_phone_idx ].text = p.extension
     ENDIF
     ,
     IF ((textlen (trim (p.call_instruction ) ) > 0 ) )
      IF ((textlen (trim (oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_phone[
        nk_contact_phone_idx ].text ) ) > 0 ) ) oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ]
       .nk_contact_phone[nk_contact_phone_idx ].text = concat (oen_reply->person_group[1 ].pat_group[
        1 ].nk1[loop1 ].nk_contact_phone[nk_contact_phone_idx ].text ,"; " ,p.call_instruction )
      ELSE oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_phone[
       nk_contact_phone_idx ].text = p.call_instruction
      ENDIF
     ENDIF
    ENDIF
   WITH nocounter
  ;end select
  SET oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].set_id = build (loop1 )
 ENDFOR
 FOR (loop1 = 1 TO size (oen_reply->person_group[1 ].res_oru_group ,5 ) )
  SET pos = locateval (idx ,1 ,size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.
    filler_ord_nbr ,5 ) ,"HNAM_ORDERID" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.
   filler_ord_nbr[idx ].name_id )
  SET cur_order_id = cnvtreal (piece (oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.
    filler_ord_nbr[pos ].entity_id ,"-" ,1 ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.
    filler_ord_nbr[pos ].entity_id ) )
  IF ((cur_order_id > 0.00 ) )
   FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc ,5 ) )
    SELECT INTO "nl:"
     FROM (order_action oa ),
      (phone p )
     PLAN (oa
      WHERE (oa.order_id = cur_order_id )
      AND (oa.action_sequence = 1 ) )
      JOIN (p
      WHERE (p.parent_entity_id = oa.order_provider_id )
      AND (p.parent_entity_name = "PERSON" )
      AND (p.phone_type_cd IN (business_phone_cd ,
      pager_bus_phone_cd ) )
      AND (p.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
      AND (p.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
      AND (p.active_ind = 1 ) )
     HEAD REPORT
      callbk_ph_nbr_idx = size (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
       callbk_ph_nbr ,5 )
     DETAIL
      callbk_ph_nbr_idx = (callbk_ph_nbr_idx + 1 ) ,
      stat = alterlist (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].callbk_ph_nbr ,
       callbk_ph_nbr_idx ) ,
      oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].callbk_ph_nbr[callbk_ph_nbr_idx ]
      .phone_nbr = p.phone_num ,
      oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].callbk_ph_nbr[callbk_ph_nbr_idx ]
      .telecom_use_cd = build ("CD:" ,p.phone_type_cd ) ,
      CASE (p.phone_type_cd )
       OF business_phone_cd :
        oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].callbk_ph_nbr[
        callbk_ph_nbr_idx ].equip_type_cd = "PH"
       OF pager_bus_phone_cd :
        oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].callbk_ph_nbr[
        callbk_ph_nbr_idx ].equip_type_cd = "BP"
      ENDCASE
      ,
      IF (isnumeric (p.extension ) ) oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
       callbk_ph_nbr[callbk_ph_nbr_idx ].extension = p.extension
      ELSE oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].callbk_ph_nbr[
       callbk_ph_nbr_idx ].text = p.extension
      ENDIF
      ,
      IF ((textlen (trim (p.call_instruction ) ) > 0 ) )
       IF ((textlen (trim (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
         callbk_ph_nbr[callbk_ph_nbr_idx ].text ) ) > 0 ) ) oen_reply->person_group[1 ].
        res_oru_group[loop1 ].orc[loop2 ].callbk_ph_nbr[callbk_ph_nbr_idx ].text = concat (oen_reply
         ->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].callbk_ph_nbr[callbk_ph_nbr_idx ].text
         ,"; " ,p.call_instruction )
       ELSE oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].callbk_ph_nbr[
        callbk_ph_nbr_idx ].text = p.call_instruction
       ENDIF
      ENDIF
      ,stat = alterlist (oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.ord_callback_ph_nbr ,
       callbk_ph_nbr_idx ) ,
      oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.ord_callback_ph_nbr[callbk_ph_nbr_idx ].
      phone_nbr = p.phone_num ,
      oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.ord_callback_ph_nbr[callbk_ph_nbr_idx ].
      telecom_use_cd = build ("CD:" ,p.phone_type_cd ) ,
      CASE (p.phone_type_cd )
       OF business_phone_cd :
        oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.ord_callback_ph_nbr[callbk_ph_nbr_idx ]
        .equip_type_cd = "PH"
       OF pager_bus_phone_cd :
        oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.ord_callback_ph_nbr[callbk_ph_nbr_idx ]
        .equip_type_cd = "BP"
      ENDCASE
      ,
      IF (isnumeric (p.extension ) ) oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.
       ord_callback_ph_nbr[callbk_ph_nbr_idx ].extension = p.extension
      ELSE oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.ord_callback_ph_nbr[
       callbk_ph_nbr_idx ].text = p.extension
      ENDIF
      ,
      IF ((textlen (trim (p.call_instruction ) ) > 0 ) )
       IF ((textlen (trim (oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.ord_callback_ph_nbr[
         callbk_ph_nbr_idx ].text ) ) > 0 ) ) oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.
        ord_callback_ph_nbr[callbk_ph_nbr_idx ].text = concat (oen_reply->person_group[1 ].
         res_oru_group[loop1 ].obr.ord_callback_ph_nbr[callbk_ph_nbr_idx ].text ,"; " ,p
         .call_instruction )
       ELSE oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.ord_callback_ph_nbr[
        callbk_ph_nbr_idx ].text = p.call_instruction
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
    SELECT INTO "nl"
     FROM (encounter e ),
      (organization org ),
      (si_oid so )
     PLAN (e
      WHERE (e.encntr_id = encntr_id )
      AND (e.active_ind = 1 ) )
      JOIN (org
      WHERE (org.organization_id = e.organization_id )
      AND (org.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
      AND (org.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
      AND (org.active_ind = 1 ) )
      JOIN (so
      WHERE (so.entity_id = outerjoin (org.organization_id ) )
      AND (so.entity_name = outerjoin ("ORGANIZATION" ) )
      AND (so.beg_effective_dt_tm <= outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
      AND (so.end_effective_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
      AND (so.active_ind = outerjoin (1 ) ) )
     ORDER BY e.encntr_id
     HEAD REPORT
      orc_fac_name_idx = size (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
       ord_fac_name ,5 )
     HEAD e.encntr_id
      orc_fac_name_idx = (orc_fac_name_idx + 1 ) ,stat = alterlist (oen_reply->person_group[1 ].
       res_oru_group[loop1 ].orc[loop2 ].ord_fac_name ,orc_fac_name_idx ) ,oen_reply->person_group[1
      ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_name[orc_fac_name_idx ].org_name = build (e
       .loc_facility_cd ) ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
      ord_fac_name[orc_fac_name_idx ].org_name_type_cd = "D" ,oen_reply->person_group[1 ].
      res_oru_group[loop1 ].orc[loop2 ].ord_fac_name[orc_fac_name_idx ].assign_authority.name_id =
      org.org_name ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_name[
      orc_fac_name_idx ].assign_authority.univ_id = so.oid_txt ,oen_reply->person_group[1 ].
      res_oru_group[loop1 ].orc[loop2 ].ord_fac_name[orc_fac_name_idx ].assign_authority.univ_id_type
       = "ISO" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_name[
      orc_fac_name_idx ].type_cd = "XX" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2
      ].ord_fac_name[orc_fac_name_idx ].organization_id = build (org.organization_id )
     WITH nocounter
    ;end select
    FOR (loop3 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
     ord_fac_name ,5 ) )
     IF ((cnvtreal (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_name[loop3
      ].org_name ) > 0.00 ) )
      SELECT INTO "nl:"
       FROM (address a )
       PLAN (a
        WHERE (a.parent_entity_id = cnvtreal (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[
         loop2 ].ord_fac_name[loop3 ].org_name ) )
        AND (a.parent_entity_name = "LOCATION" )
        AND (a.address_type_cd = outerjoin (business_address_cd ) )
        AND (a.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
        AND (a.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
        AND (a.active_ind = 1 ) )
       HEAD REPORT
        orc_fac_add_idx = size (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
         ord_fac_address ,5 )
       DETAIL
        orc_fac_add_idx = (orc_fac_add_idx + 1 ) ,
        stat = alterlist (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
         ord_fac_address ,orc_fac_add_idx ) ,
        oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_address[
        orc_fac_add_idx ].street.street = a.street_addr ,
        oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_address[
        orc_fac_add_idx ].other_desig = a.street_addr2 ,
        oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_address[
        orc_fac_add_idx ].city = a.city ,
        IF ((a.state_cd > 0.00 ) ) oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
         ord_fac_address[orc_fac_add_idx ].state_prov = build ("CD:" ,a.state_cd )
        ELSE oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_address[
         orc_fac_add_idx ].state_prov = a.state
        ENDIF
        ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_address[
        orc_fac_add_idx ].zip_code = a.zipcode ,
        IF ((a.country_cd > 0.00 ) ) oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
         ord_fac_address[orc_fac_add_idx ].country = build ("CD:" ,a.country_cd )
        ELSE oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_address[
         orc_fac_add_idx ].country = a.country
        ENDIF
        ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_address[
        orc_fac_add_idx ].types = build ("CD:" ,a.address_type_cd ) ,
        oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_address[
        orc_fac_add_idx ].other_geo_desig = a.street_addr3 ,
        IF ((a.county_cd > 0.00 ) ) oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
         ord_fac_address[orc_fac_add_idx ].county = build ("CD:" ,a.county_cd )
        ELSE oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_address[
         orc_fac_add_idx ].county = cnvtupper (a.county )
        ENDIF
       WITH nocounter
      ;end select
      SELECT INTO "nl:"
       FROM (phone p )
       PLAN (p
        WHERE (p.parent_entity_id = cnvtreal (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[
         loop2 ].ord_fac_name[loop3 ].org_name ) )
        AND (p.parent_entity_name = "LOCATION" )
        AND (p.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
        AND (p.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
        AND (p.active_ind = 1 ) )
       HEAD REPORT
        ord_fac_ph_nbr_idx = 0
       DETAIL
        ord_fac_ph_nbr_idx = (ord_fac_ph_nbr_idx + 1 ) ,
        stat = alterlist (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
         ord_fac_ph_nbr ,ord_fac_ph_nbr_idx ) ,
        oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_ph_nbr[
        ord_fac_ph_nbr_idx ].phone_nbr = p.phone_num ,
        oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_ph_nbr[
        ord_fac_ph_nbr_idx ].telecom_use_cd = build ("CD:" ,p.phone_type_cd ) ,
        oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_ph_nbr[
        ord_fac_ph_nbr_idx ].equip_type_cd = "PH" ,
        IF (isnumeric (p.extension ) ) oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
         ord_fac_ph_nbr[ord_fac_ph_nbr_idx ].extension = p.extension
        ELSE oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_ph_nbr[
         ord_fac_ph_nbr_idx ].text = p.extension
        ENDIF
        ,
        IF ((textlen (trim (p.call_instruction ) ) > 0 ) )
         IF ((textlen (trim (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
           ord_fac_ph_nbr[ord_fac_ph_nbr_idx ].text ) ) > 0 ) ) oen_reply->person_group[1 ].
          res_oru_group[loop1 ].orc[loop2 ].ord_fac_ph_nbr[ord_fac_ph_nbr_idx ].text = concat (
           oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_ph_nbr[
           ord_fac_ph_nbr_idx ].text ,"; " ,p.call_instruction )
         ELSE oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_ph_nbr[
          ord_fac_ph_nbr_idx ].text = p.call_instruction
         ENDIF
        ENDIF
       WITH nocounter
      ;end select
     ENDIF
     IF (isnumeric (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_name[loop3
      ].org_name ) )
      IF ((cnvtreal (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_name[
       loop3 ].org_name ) > 0.00 ) )
       SET oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_name[loop3 ].
       org_name = trim (uar_get_code_display (cnvtreal (oen_reply->person_group[1 ].res_oru_group[
          loop1 ].orc[loop2 ].ord_fac_name[loop3 ].org_name ) ) ,3 )
      ELSE
       SET oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_name[loop3 ].
       org_name = ""
      ENDIF
     ENDIF
    ENDFOR
    SELECT INTO "nl:"
     FROM (order_action oa ),
      (address a )
     PLAN (oa
      WHERE (oa.order_id = cur_order_id ) )
      JOIN (a
      WHERE (a.parent_entity_id = oa.order_provider_id )
      AND (a.parent_entity_name = "PERSON" )
      AND (a.address_type_cd = business_address_cd )
      AND (a.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
      AND (a.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
      AND (a.active_ind = 1 ) )
     ORDER BY oa.action_sequence DESC
     HEAD REPORT
      last_action_sequence = oa.action_sequence ,
      prov_add_idx = size (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
       provider_address ,5 )
     DETAIL
      IF ((oa.action_sequence = last_action_sequence ) ) prov_add_idx = (prov_add_idx + 1 ) ,stat =
       alterlist (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].provider_address ,
        prov_add_idx ) ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
       provider_address[prov_add_idx ].street.street = a.street_addr ,oen_reply->person_group[1 ].
       res_oru_group[loop1 ].orc[loop2 ].provider_address[prov_add_idx ].other_desig = a
       .street_addr2 ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].provider_address[
       prov_add_idx ].city = a.city ,
       IF ((a.state_cd > 0.00 ) ) oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
        provider_address[prov_add_idx ].state_prov = build ("CD:" ,a.state_cd )
       ELSE oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].provider_address[
        prov_add_idx ].state_prov = a.state
       ENDIF
       ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].provider_address[prov_add_idx ]
       .zip_code = a.zipcode ,
       IF ((a.country_cd > 0.00 ) ) oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
        provider_address[prov_add_idx ].country = build ("CD:" ,a.country_cd )
       ELSE oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].provider_address[
        prov_add_idx ].country = a.country
       ENDIF
       ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].provider_address[prov_add_idx ]
       .types = build ("CD:" ,a.address_type_cd ) ,oen_reply->person_group[1 ].res_oru_group[loop1 ].
       orc[loop2 ].provider_address[prov_add_idx ].other_geo_desig = a.street_addr3 ,
       IF ((a.county_cd > 0.00 ) ) oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
        provider_address[prov_add_idx ].county = build ("CD:" ,a.county_cd )
       ELSE oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].provider_address[
        prov_add_idx ].county = cnvtupper (a.county )
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ENDFOR
   SET stat = alterlist (oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.relevant_clin_info ,0
    )
   SELECT INTO "nl:"
    FROM (order_detail od )
    PLAN (od
     WHERE (od.order_id = cur_order_id )
     AND (od.oe_field_meaning IN ("LBLCMNT" ,
     "SPECINX" ) ) )
    ORDER BY od.oe_field_meaning ,
     od.action_sequence DESC
    HEAD REPORT
     cnt1 = 0 ,
     stat = alterlist (oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.relevant_clin_info ,0 )
    HEAD od.oe_field_meaning
     cnt1 = (cnt1 + 1 ) ,
     IF ((cnt1 = 1 ) ) oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.relevant_clin_info[1 ].
      identifier = od.oe_field_display_value
     ELSE oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.relevant_clin_info[1 ].identifier =
      concat (oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.relevant_clin_info[1 ].identifier
        ,"; " ,od.oe_field_display_value )
     ENDIF
    WITH nocounter
   ;end select
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_id.identifier = ""
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_id.text = ""
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_id.coding_system = ""
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_id.alt_identifier =
   ""
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_id.alt_text = ""
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_id.alt_coding_system
   = ""
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_id.
   coding_system_version = ""
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_id.
   alt_coding_system_ver = ""
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_id.original_text = ""
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_sub_id = ""
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_result.identifier =
   ""
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_result.text = ""
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_result.coding_system
   = ""
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_result.alt_identifier
   = ""
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_result.alt_text = ""
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_result.
   alt_coding_system = ""
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_result.
   coding_system_version = ""
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_result.
   alt_coding_system_ver = ""
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_result.original_text
   = ""
   SET pos = locateval (idx ,1 ,size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.
     parent_nbr ,5 ) ,"HNAM_ORDERID" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.
    parent_nbr[idx ].filler_ord_nbr.name_id )
   SET parent_order_id = cnvtreal (oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_nbr[
    pos ].filler_ord_nbr.entity_id )
   IF ((parent_order_id > 0.00 ) )
    IF ((cqm_subtype = "MICRO" ) )
     SELECT INTO "nl:"
      FROM (clinical_event ce ),
       (ce_microbiology cm )
      PLAN (ce
       WHERE (ce.order_id = parent_order_id )
       AND (ce.view_level = 1 )
       AND (ce.valid_from_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
       AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
       JOIN (cm
       WHERE (cm.event_id = ce.event_id )
       AND (cm.valid_from_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
       AND (cm.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
      ORDER BY cm.micro_seq_nbr
      HEAD REPORT
       oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_id.identifier = build
       ("CD:" ,ce.event_cd ) ,
       oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_sub_id = build (cm
        .micro_seq_nbr ) ,
       oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_result.identifier =
       build (uar_get_code_display (cm.organism_cd ) )
      WITH nocounter
     ;end select
    ELSE
     SELECT INTO "nl:"
      FROM (clinical_event ce )
      PLAN (ce
       WHERE (ce.order_id = parent_order_id )
       AND (ce.view_level = 1 )
       AND (ce.valid_from_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
       AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
      ORDER BY ce.collating_seq
      HEAD REPORT
       obx_found = 0 ,
       cnt1 = 1 ,
       oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_id.identifier = build
       ("CD:" ,ce.event_cd ) ,
       CASE (obx_4_routine_arg )
        OF 1 :
         oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_sub_id = trim (
          format (ce.task_assay_cd ,";;i" ) ,3 )
        OF 2 :
         oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_sub_id = trim (
          format (ce.event_id ,";;i" ) ,3 )
        ELSE oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_sub_id = build (
          cnt1 )
       ENDCASE
       ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_result.identifier =
       ce.result_val
      DETAIL
       IF ((obx_found = 0 )
       AND (ce.normalcy_cd IN (high_cd ,
       abnormal_cd ,
       critical_cd ) ) ) obx_found = 1 ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.
        parent_result.obs_id.identifier = build ("CD:" ,ce.event_cd ) ,
        CASE (obx_4_routine_arg )
         OF 1 :
          oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_sub_id = trim (
           format (ce.task_assay_cd ,";;i" ) ,3 )
         OF 2 :
          oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_sub_id = trim (
           format (ce.event_id ,";;i" ) ,3 )
         ELSE oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_sub_id = build
          (cnt1 )
        ENDCASE
        ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_result.identifier =
        ce.result_val
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.reason_for_study.identifier = ""
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.reason_for_study.text = ""
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.reason_for_study.coding_system = ""
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.reason_for_study.alt_identifier = ""
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.reason_for_study.alt_text = ""
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.reason_for_study.alt_coding_system = ""
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.reason_for_study.coding_system_version
   = ""
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.reason_for_study.alt_coding_system_ver
   = ""
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.reason_for_study.original_text = ""
   SELECT INTO "nl:"
    FROM (dcp_entity_reltn der ),
     (diagnosis d ),
     (nomenclature n )
    PLAN (der
     WHERE (der.entity1_id = cur_order_id )
     AND (der.entity_reltn_mean = "ORDERS/DIAGN" )
     AND (der.active_ind = 1 ) )
     JOIN (d
     WHERE (d.diagnosis_id = der.entity2_id )
     AND (d.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
     AND (d.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
     AND (d.active_ind = 1 ) )
     JOIN (n
     WHERE (n.nomenclature_id = d.nomenclature_id )
     AND (n.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
     AND (n.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
     AND (n.active_ind = 1 ) )
    ORDER BY der.rank_sequence
    HEAD REPORT
     oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.reason_for_study.identifier = n
     .source_identifier ,
     oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.reason_for_study.text = n.source_string ,
     oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.reason_for_study.coding_system = build (
      "CD:" ,n.source_vocabulary_cd )
    WITH nocounter
   ;end select
   IF ((size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.prim_res_interp ,5 ) = 0 ) )
    SELECT INTO "nl:"
     FROM (clinical_event ce ),
      (ce_event_prsnl cep ),
      (prsnl_alias pa ),
      (person_name pn ),
      (si_oid so )
     PLAN (ce
      WHERE (ce.order_id = cur_order_id )
      AND (ce.valid_from_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
      AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
      JOIN (cep
      WHERE (cep.event_id = ce.event_id )
      AND (cep.action_type_cd IN (verify_cd ,
      modify_cd ) ) )
      JOIN (pa
      WHERE (pa.person_id = outerjoin (cep.action_prsnl_id ) )
      AND (pa.beg_effective_dt_tm <= outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
      AND (pa.end_effective_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
      AND (pa.active_ind = outerjoin (1 ) ) )
      JOIN (so
      WHERE (so.entity_id = outerjoin (pa.contributor_system_cd ) )
      AND (so.entity_name = outerjoin ("CONTRIBUTOR_SYSTEM" ) )
      AND (so.beg_effective_dt_tm <= outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
      AND (so.end_effective_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
      AND (so.active_ind = outerjoin (1 ) ) )
      JOIN (pn
      WHERE (pn.person_id = outerjoin (cep.action_prsnl_id ) )
      AND (pn.name_type_cd = outerjoin (prsnl_cd ) )
      AND (pn.beg_effective_dt_tm <= outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
      AND (pn.end_effective_dt_tm > outerjoin (cnvtdatetime (curdate ,curtime3 ) ) )
      AND (pn.active_ind = outerjoin (1 ) ) )
     HEAD REPORT
      cnt1 = 0 ,
      cnt1 = (cnt1 + 1 ) ,
      stat = alterlist (oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.prim_res_interp ,cnt1
       ) ,
      oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.prim_res_interp[cnt1 ].name.id = pa
      .alias ,
      oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.prim_res_interp[cnt1 ].name.family_name
      = pn.name_last ,
      oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.prim_res_interp[cnt1 ].name.given_name =
      pn.name_first ,
      oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.prim_res_interp[cnt1 ].name.middle_name
      = pn.name_middle ,
      oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.prim_res_interp[cnt1 ].name.suffix = pn
      .name_suffix ,
      oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.prim_res_interp[cnt1 ].name.prefix = pn
      .name_prefix ,
      oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.prim_res_interp[cnt1 ].name.degree = pn
      .name_degree ,
      IF ((pa.contributor_system_cd > 0.00 ) ) oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.
       prim_res_interp[cnt1 ].name.assign_auth_namespace_id = trim (uar_get_code_display (pa
         .contributor_system_cd ) ,3 ) ,
       IF ((so.si_oid_id > 0.00 ) ) oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.
        prim_res_interp[cnt1 ].name.assign_auth_univ_id = trim (so.oid_txt ,3 ) ,oen_reply->
        person_group[1 ].res_oru_group[loop1 ].obr.prim_res_interp[cnt1 ].name.
        assign_auth_univ_id_type = "ISO"
       ENDIF
      ENDIF
     WITH nocounter
    ;end select
   ENDIF
   FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group ,5 ) )
    SELECT INTO "nl:"
     FROM (clinical_event ce ),
      (code_value_outbound cvo1 ),
      (code_value_outbound cvo2 )
     PLAN (ce
      WHERE (ce.order_id = cur_order_id )
      AND (ce.valid_from_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
      AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
      JOIN (cvo1
      WHERE (cvo1.code_value = ce.event_cd )
      AND (cvo1.contributor_source_cd = loinc_cd )
      AND (cvo1.alias = oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
      observation_id.identifier )
      AND (((cvo1.alias_type_meaning = null ) ) OR ((((cvo1.alias_type_meaning = " " ) ) OR ((cvo1
      .alias_type_meaning = "" ) )) )) )
      JOIN (cvo2
      WHERE (cvo2.code_value = ce.normalcy_cd )
      AND (cvo2.contributor_source_cd = hl7v2_cd )
      AND (((cvo2.alias_type_meaning = null ) ) OR ((((cvo2.alias_type_meaning = " " ) ) OR ((cvo2
      .alias_type_meaning = "" ) )) )) )
     HEAD REPORT
      oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.abnormal_flag[1 ].
      abnormal_flag = build (cvo2.alias ,"^" ,uar_get_code_description (ce.normalcy_cd ) ,"^" ,
       "HL70078" )
     WITH nocounter
    ;end select
    IF ((cqm_subtype = "MICRO" ) )
     SELECT INTO "nl:"
      FROM (clinical_event ce ),
       (ce_susceptibility cs ),
       (code_value_outbound cvo1 ),
       (code_value_outbound cvo2 )
      PLAN (ce
       WHERE (ce.order_id = cur_order_id )
       AND (ce.valid_from_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
       AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
       JOIN (cs
       WHERE (cs.event_id = ce.event_id )
       AND (cs.detail_susceptibility_cd = micinterp_cd )
       AND (cs.valid_from_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
       AND (cs.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
       JOIN (cvo1
       WHERE (cvo1.code_value = cs.antibiotic_cd )
       AND (cvo1.contributor_source_cd = loinc_cd )
       AND (cvo1.alias = oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
       observation_id.identifier )
       AND (((cvo1.alias_type_meaning = null ) ) OR ((((cvo1.alias_type_meaning = " " ) ) OR ((cvo1
       .alias_type_meaning = "" ) )) )) )
       JOIN (cvo2
       WHERE (cvo2.code_value = cs.result_cd )
       AND (cvo2.contributor_source_cd = hl7v2_cd )
       AND (((cvo2.alias_type_meaning = null ) ) OR ((((cvo2.alias_type_meaning = " " ) ) OR ((cvo2
       .alias_type_meaning = "" ) )) )) )
      HEAD REPORT
       oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.abnormal_flag[1 ].
       abnormal_flag = build (cvo2.alias ,"^" ,uar_get_code_description (cs.result_cd ) ,"^" ,
        "HL70078" )
      WITH nocounter
     ;end select
    ENDIF
    SET stat = alterlist (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
     obs_method ,0 )
    SELECT INTO "nl:"
     FROM (code_value cv ),
      (code_value_outbound cvo ),
      (clinical_event ce )
     PLAN (cv
      WHERE (cv.code_set = 73 )
      AND (cv.cdf_meaning = "LOINC" )
      AND (cv.begin_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
      AND (cv.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
      AND (cv.active_ind = 1 ) )
      JOIN (cvo
      WHERE (cvo.contributor_source_cd = cv.code_value )
      AND (cvo.alias = oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
      observation_id.identifier ) )
      JOIN (ce
      WHERE (ce.order_id = cur_order_id )
      AND (ce.event_cd = cvo.code_value )
      AND (ce.resource_cd > 0.00 )
      AND (ce.valid_from_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
      AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
     HEAD REPORT
      stat = alterlist (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
       obs_method ,1 ) ,
      oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.obs_method[1 ].
      identifier = build ("CD:" ,ce.resource_cd )
     WITH nocounter
    ;end select
   ENDFOR
   SET tmp_id1 = 0.00
   SELECT INTO "nl:"
    FROM (orders o ),
     (clinical_event ce ),
     (person p ),
     (ce_specimen_coll csc )
    PLAN (o
     WHERE (o.order_id = cur_order_id ) )
     JOIN (ce
     WHERE (ce.order_id = o.order_id )
     AND (ce.event_id != ce.parent_event_id )
     AND (ce.valid_from_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
     AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
     JOIN (p
     WHERE (p.person_id = ce.person_id )
     AND (p.person_id > 0.00 ) )
     JOIN (csc
     WHERE (csc.event_id = outerjoin (ce.event_id ) ) )
    HEAD REPORT
     cnt1 = size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group ,5 ) ,
     IF ((p.birth_dt_tm > 0.00 )
     AND (((csc.collect_dt_tm > 0.00 ) ) OR ((o.current_start_dt_tm > 0.00 ) )) ) cnt1 = (cnt1 + 1 )
     ,stat = alterlist (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group ,cnt1 ) ,
      oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.set_id = build (cnt1 ) ,
      oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.value_type = "NM" ,
      oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.observation_id.
      identifier = "35659-2" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.
      observation_id.text = "Age at Specimen Collection" ,oen_reply->person_group[1 ].res_oru_group[
      loop1 ].obx_group[cnt1 ].obx.observation_id.coding_system = "LN" ,oen_reply->person_group[1 ].
      res_oru_group[loop1 ].obx_group[cnt1 ].obx.observation_id.original_text =
      "Age at Specimen Collection" ,stat = alterlist (oen_reply->person_group[1 ].res_oru_group[
       loop1 ].obx_group[cnt1 ].obx.observation_value ,1 ) ,
      IF ((csc.collect_dt_tm > 0.00 ) ) oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[
       cnt1 ].obx.observation_value[1 ].value_1 = build (datetimediff (csc.collect_dt_tm ,p
         .birth_dt_tm ,10 ) ) ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx
       .observation_dt_tm = formatisodate (csc.collect_dt_tm ,datetimezonebyname (curtimezone ) ) ,
       oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.analysis_dt_tm =
       formatisodate (csc.collect_dt_tm ,datetimezonebyname (curtimezone ) )
      ELSE oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.observation_value[
       1 ].value_1 = build (datetimediff (o.current_start_dt_tm ,p.birth_dt_tm ,10 ) ) ,oen_reply->
       person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.observation_dt_tm = formatisodate
       (o.current_start_dt_tm ,datetimezonebyname (curtimezone ) ) ,oen_reply->person_group[1 ].
       res_oru_group[loop1 ].obx_group[cnt1 ].obx.analysis_dt_tm = formatisodate (o
        .current_start_dt_tm ,datetimezonebyname (curtimezone ) )
      ENDIF
      ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.units.identifier = "a"
     ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.units.text = "Year" ,
      oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.units.coding_system =
      "UCUM" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.units.
      original_text = "Year" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.
      observation_res_status = "F" ,tmp_id1 = ce.resource_cd
     ENDIF
    WITH nocounter
   ;end select
   IF ((tmp_id1 > 0.00 ) )
    SELECT INTO "nl:"
     FROM (resource_group rg ),
      (code_value cv ),
      (service_resource sr )
     PLAN (rg
      WHERE (rg.child_service_resource_cd = tmp_id1 )
      AND (rg.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
      AND (rg.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
      AND (rg.active_ind = 1 ) )
      JOIN (cv
      WHERE (cv.code_value = rg.parent_service_resource_cd )
      AND (cv.cdf_meaning = "SUBSECTION" ) )
      JOIN (sr
      WHERE (sr.service_resource_cd = rg.parent_service_resource_cd )
      AND (sr.beg_effective_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
      AND (sr.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
      AND (sr.active_ind = 1 ) )
     HEAD REPORT
      stat = alterlist (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.
       performing_org_name ,1 ) ,
      oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.performing_org_name[1 ].
      org_name = trim (uar_get_code_description (sr.service_resource_cd ) ,3 ) ,
      IF ((textlen (trim (sr.clia_number_txt ) ) > 0 ) ) oen_reply->person_group[1 ].res_oru_group[
       loop1 ].obx_group[cnt1 ].obx.performing_org_name[1 ].assign_authority.name_id = "CLIA" ,
       oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.performing_org_name[1 ]
       .type_cd = "XX" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.
       performing_org_name[1 ].organization_id = sr.clia_number_txt
      ENDIF
      ,
      IF ((textlen (trim (sr.medical_director_name ) ) > 0 ) ) stat = alterlist (oen_reply->
        person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.perf_org_med_dir ,1 ) ,oen_reply
       ->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.perf_org_med_dir[1 ].last_name.
       last_name = sr.medical_director_name
      ENDIF
      ,tmp_id1 = sr.location_cd
     WITH nocounter
    ;end select
    IF ((tmp_id1 > 0.00 ) )
     SELECT INTO "nl:"
      FROM (address a )
      WHERE (a.parent_entity_id = tmp_id1 )
      AND (a.parent_entity_name = "LOCATION" )
      AND (a.address_type_cd = business_address_cd )
      HEAD REPORT
       stat = alterlist (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.
        performing_org_addr ,1 ) ,
       oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.performing_org_addr[1 ]
       .street.street = a.street_addr ,
       oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.performing_org_addr[1 ]
       .other_desig = a.street_addr2 ,
       oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.performing_org_addr[1 ]
       .city = a.city ,
       IF ((a.state_cd > 0.00 ) ) oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].
        obx.performing_org_addr[1 ].state_prov = build ("CD:" ,a.state_cd )
       ELSE oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.
        performing_org_addr[1 ].state_prov = a.state
       ENDIF
       ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.performing_org_addr[1
       ].zip_code = a.zipcode ,
       IF ((a.country_cd > 0.00 ) ) oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1
        ].obx.performing_org_addr[1 ].country = build ("CD:" ,a.country_cd )
       ELSE oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.
        performing_org_addr[1 ].country = a.country
       ENDIF
       ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.performing_org_addr[1
       ].types = build ("CD:" ,a.address_type_cd ) ,
       IF ((a.county_cd > 0.00 ) ) oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ]
        .obx.performing_org_addr[1 ].county = build ("CD:" ,a.county_cd )
       ELSE oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[cnt1 ].obx.
        performing_org_addr[1 ].county = cnvtupper (a.county )
       ENDIF
      WITH nocounter
     ;end select
    ENDIF
   ENDIF
   FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].specimen_group ,5 ) )
    IF ((textlen (trim (oen_reply->person_group[1 ].res_oru_group[loop1 ].specimen_group[loop2 ].spm.
      spec_col_method.identifier ) ) > 0 )
    AND (textlen (trim (oen_reply->person_group[1 ].res_oru_group[loop1 ].specimen_group[loop2 ].spm.
      spec_col_method.text ) ) = 0 ) )
     SELECT INTO "nl:"
      FROM (order_detail od ),
       (code_value_outbound cvo )
      PLAN (od
       WHERE (od.order_id = cur_order_id )
       AND (od.oe_field_meaning = "COLLMETHOD" ) )
       JOIN (cvo
       WHERE (cvo.code_value = od.oe_field_value )
       AND (cvo.contributor_source_cd = prim_cont_source_cd )
       AND (cvo.alias = oen_reply->person_group[1 ].res_oru_group[loop1 ].specimen_group[loop2 ].spm.
       spec_col_method.identifier ) )
      ORDER BY od.action_sequence DESC
      HEAD REPORT
       oen_reply->person_group[1 ].res_oru_group[loop1 ].specimen_group[loop2 ].spm.spec_col_method.
       text = trim (uar_get_code_display (od.oe_field_value ) ,3 )
      WITH nocounter
     ;end select
     IF ((textlen (trim (oen_reply->person_group[1 ].res_oru_group[loop1 ].specimen_group[loop2 ].spm
       .spec_col_method.text ) ) = 0 ) )
      SELECT INTO "nl:"
       FROM (clinical_event ce ),
        (ce_specimen_coll csc ),
        (code_value_outbound cvo )
       PLAN (ce
        WHERE (ce.order_id = cur_order_id )
        AND (ce.event_id != ce.parent_event_id )
        AND (ce.valid_from_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
        AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
        JOIN (csc
        WHERE (csc.event_id = ce.event_id ) )
        JOIN (cvo
        WHERE (cvo.code_value = csc.collect_method_cd )
        AND (cvo.contributor_source_cd = prim_cont_source_cd )
        AND (cvo.alias = oen_reply->person_group[1 ].res_oru_group[loop1 ].specimen_group[loop2 ].spm
        .spec_col_method.identifier ) )
       HEAD REPORT
        oen_reply->person_group[1 ].res_oru_group[loop1 ].specimen_group[loop2 ].spm.spec_col_method.
        text = trim (uar_get_code_display (csc.collect_method_cd ) ,3 )
       WITH nocounter
      ;end select
     ENDIF
    ENDIF
    SELECT INTO "nl:"
     FROM (clinical_event ce ),
      (ce_specimen_coll csc ),
      (container c )
     PLAN (ce
      WHERE (ce.order_id = cur_order_id )
      AND (ce.event_id != ce.parent_event_id )
      AND (ce.valid_from_dt_tm <= cnvtdatetime (curdate ,curtime3 ) )
      AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) ) )
      JOIN (csc
      WHERE (csc.event_id = ce.event_id ) )
      JOIN (c
      WHERE (c.container_id = csc.container_id )
      AND (c.specimen_id = csc.specimen_id ) )
     HEAD REPORT
      oen_reply->person_group[1 ].res_oru_group[loop1 ].specimen_group[loop2 ].spm.spec_col_amt.
      quantity = build (c.volume ) ,
      oen_reply->person_group[1 ].res_oru_group[loop1 ].specimen_group[loop2 ].spm.spec_col_amt.unit.
      identifier = build ("CD:" ,c.units_cd )
     WITH nocounter
    ;end select
   ENDFOR
  ENDIF
 ENDFOR
 FOR (loop1 = 1 TO size (oen_reply->person_group[1 ].pat_group[1 ].pid.patient_name ,5 ) )
  SET oen_reply->person_group[1 ].pat_group[1 ].pid.patient_name[loop1 ].professional_suffix =
  oen_reply->person_group[1 ].pat_group[1 ].pid.patient_name[loop1 ].degree
  SET oen_reply->person_group[1 ].pat_group[1 ].pid.patient_name[loop1 ].degree = ""
 ENDFOR
 FOR (loop1 = 1 TO size (oen_reply->person_group[1 ].pat_group[1 ].pid.ph_nbr_home ,5 ) )
  IF ((oen_reply->person_group[1 ].pat_group[1 ].pid.ph_nbr_home[loop1 ].equip_type_cd != "Internet"
  ) )
   CALL populate_xtn (oen_reply->person_group[1 ].pat_group[1 ].pid.ph_nbr_home[loop1 ].phone_nbr ,
    oen_reply->person_group[1 ].pat_group[1 ].pid.ph_nbr_home[loop1 ].country_cd ,oen_reply->
    person_group[1 ].pat_group[1 ].pid.ph_nbr_home[loop1 ].area_cd ,oen_reply->person_group[1 ].
    pat_group[1 ].pid.ph_nbr_home[loop1 ].phone_nbr_comp )
  ENDIF
 ENDFOR
 FOR (loop1 = 1 TO size (oen_reply->person_group[1 ].pat_group[1 ].pid.ph_nbr_bus ,5 ) )
  IF ((oen_reply->person_group[1 ].pat_group[1 ].pid.ph_nbr_bus[loop1 ].equip_type_cd != "Internet"
  ) )
   CALL populate_xtn (oen_reply->person_group[1 ].pat_group[1 ].pid.ph_nbr_bus[loop1 ].phone_nbr ,
    oen_reply->person_group[1 ].pat_group[1 ].pid.ph_nbr_bus[loop1 ].country_cd ,oen_reply->
    person_group[1 ].pat_group[1 ].pid.ph_nbr_bus[loop1 ].area_cd ,oen_reply->person_group[1 ].
    pat_group[1 ].pid.ph_nbr_bus[loop1 ].phone_nbr_comp )
  ENDIF
 ENDFOR
 FOR (loop1 = 1 TO size (oen_reply->person_group[1 ].pat_group[1 ].nk1 ,5 ) )
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].ph_nbr_home ,5 ) )
   IF ((oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].ph_nbr_home[loop2 ].equip_type_cd !=
   "Internet" ) )
    CALL populate_xtn (oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].ph_nbr_home[loop2 ].
     phone_nbr ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].ph_nbr_home[loop2 ].country_cd
     ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].ph_nbr_home[loop2 ].area_cd ,oen_reply->
     person_group[1 ].pat_group[1 ].nk1[loop1 ].ph_nbr_home[loop2 ].phone_nbr_comp )
   ENDIF
  ENDFOR
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_phone ,5
   ) )
   IF ((oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_phone[loop2 ].equip_type_cd
   != "Internet" ) )
    CALL populate_xtn (oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_phone[loop2 ]
     .phone_nbr ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_phone[loop2 ].
     country_cd ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_phone[loop2 ].
     area_cd ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_phone[loop2 ].
     phone_nbr_comp )
   ENDIF
  ENDFOR
 ENDFOR
 FOR (loop1 = 1 TO size (oen_reply->person_group[1 ].res_oru_group ,5 ) )
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc ,5 ) )
   FOR (loop3 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
    callbk_ph_nbr ,5 ) )
    IF ((oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].callbk_ph_nbr[loop3 ].
    equip_type_cd != "Internet" ) )
     CALL populate_xtn (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].callbk_ph_nbr[
      loop3 ].phone_nbr ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].callbk_ph_nbr[
      loop3 ].country_cd ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
      callbk_ph_nbr[loop3 ].area_cd ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
      callbk_ph_nbr[loop3 ].phone_nbr_comp )
    ENDIF
   ENDFOR
   FOR (loop3 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
    ord_fac_ph_nbr ,5 ) )
    IF ((oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_ph_nbr[loop3 ].
    equip_type_cd != "Internet" ) )
     CALL populate_xtn (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_ph_nbr[
      loop3 ].phone_nbr ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
      ord_fac_ph_nbr[loop3 ].country_cd ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2
      ].ord_fac_ph_nbr[loop3 ].area_cd ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ]
      .ord_fac_ph_nbr[loop3 ].phone_nbr_comp )
    ENDIF
   ENDFOR
  ENDFOR
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.ord_callback_ph_nbr ,
   5 ) )
   IF ((oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.ord_callback_ph_nbr[loop2 ].
   equip_type_cd != "Internet" ) )
    SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.ord_callback_ph_nbr[loop2 ].
    phone_nbr_comp = cnvtalphanum (oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.
     ord_callback_ph_nbr[loop2 ].phone_nbr ,1 )
    CALL populate_xtn (oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.ord_callback_ph_nbr[
     loop2 ].phone_nbr ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.ord_callback_ph_nbr[
     loop2 ].country_cd ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.ord_callback_ph_nbr[
     loop2 ].area_cd ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.ord_callback_ph_nbr[
     loop2 ].phone_nbr_comp )
   ENDIF
  ENDFOR
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group ,5 ) )
   IF ((textlen (trim (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
     observation_res_status ) ) = 0 ) )
    SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
    observation_res_status = oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.result_status
   ENDIF
   IF ((textlen (trim (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
     analysis_dt_tm ) ) = 0 ) )
    SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.analysis_dt_tm =
    oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_dt_tm
   ENDIF
   FOR (loop3 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
    observation_value ,5 ) )
    IF ((oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.value_type = "CE" )
    AND (findstring (":" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
     observation_value[loop3 ].value_1 ) > 0 ) )
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.value_type = "SN"
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_2 = substring (1 ,(findstring (":" ,oen_reply->person_group[1 ].res_oru_group[
       loop1 ].obx_group[loop2 ].obx.observation_value[loop3 ].value_1 ) - 1 ) ,oen_reply->
      person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[loop3 ].value_1
      )
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_3 = ":"
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_4 = substring ((findstring (":" ,oen_reply->person_group[1 ].res_oru_group[loop1 ]
       .obx_group[loop2 ].obx.observation_value[loop3 ].value_1 ) + 1 ) ,(textlen (oen_reply->
       person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[loop3 ].value_1
        ) - findstring (":" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
       observation_value[loop3 ].value_1 ) ) ,oen_reply->person_group[1 ].res_oru_group[loop1 ].
      obx_group[loop2 ].obx.observation_value[loop3 ].value_1 )
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_1 = ""
    ENDIF
    IF ((oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.value_type = "NM" )
    AND (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
    loop3 ].value_1 != cnvtalphanum (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[
     loop2 ].obx.observation_value[loop3 ].value_1 ,5 ) ) )
     SET idx = 1
     SET tmp_str1 = oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
     observation_value[loop3 ].value_1
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_1 = " "
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_2 = " "
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_3 = " "
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_4 = " "
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_5 = " "
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_6 = " "
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_7 = " "
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_8 = " "
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_9 = " "
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_10 = " "
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_11 = " "
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_12 = " "
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_13 = " "
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_14 = " "
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_15 = " "
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_16 = " "
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_17 = " "
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_18 = " "
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_19 = " "
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_20 = " "
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_21 = " "
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_22 = " "
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.value_type = "SN"
     FOR (str_loop = 1 TO textlen (tmp_str1 ) )
      IF ((isnumeric (substring (str_loop ,1 ,tmp_str1 ) ,"." ) > 0 ) )
       IF ((even (idx ) = 2 ) )
        IF ((idx = 1 )
        AND (textlen (trim (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
          observation_value[loop3 ].value_1 ) ) = 0 ) )
         SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
         observation_value[loop3 ].value_1 = "="
        ENDIF
        SET idx = (idx + 1 )
       ENDIF
       CASE (idx )
        OF 2 :
         SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
         observation_value[loop3 ].value_2 = concat (oen_reply->person_group[1 ].res_oru_group[loop1
          ].obx_group[loop2 ].obx.observation_value[loop3 ].value_2 ,substring (str_loop ,1 ,
           tmp_str1 ) )
        OF 4 :
         SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
         observation_value[loop3 ].value_4 = concat (oen_reply->person_group[1 ].res_oru_group[loop1
          ].obx_group[loop2 ].obx.observation_value[loop3 ].value_4 ,substring (str_loop ,1 ,
           tmp_str1 ) )
        OF 6 :
         SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
         observation_value[loop3 ].value_6 = concat (oen_reply->person_group[1 ].res_oru_group[loop1
          ].obx_group[loop2 ].obx.observation_value[loop3 ].value_6 ,substring (str_loop ,1 ,
           tmp_str1 ) )
        OF 8 :
         SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
         observation_value[loop3 ].value_8 = concat (oen_reply->person_group[1 ].res_oru_group[loop1
          ].obx_group[loop2 ].obx.observation_value[loop3 ].value_8 ,substring (str_loop ,1 ,
           tmp_str1 ) )
        OF 10 :
         SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
         observation_value[loop3 ].value_10 = concat (oen_reply->person_group[1 ].res_oru_group[
          loop1 ].obx_group[loop2 ].obx.observation_value[loop3 ].value_10 ,substring (str_loop ,1 ,
           tmp_str1 ) )
        OF 12 :
         SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
         observation_value[loop3 ].value_12 = concat (oen_reply->person_group[1 ].res_oru_group[
          loop1 ].obx_group[loop2 ].obx.observation_value[loop3 ].value_12 ,substring (str_loop ,1 ,
           tmp_str1 ) )
        OF 14 :
         SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
         observation_value[loop3 ].value_14 = concat (oen_reply->person_group[1 ].res_oru_group[
          loop1 ].obx_group[loop2 ].obx.observation_value[loop3 ].value_14 ,substring (str_loop ,1 ,
           tmp_str1 ) )
        OF 16 :
         SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
         observation_value[loop3 ].value_16 = concat (oen_reply->person_group[1 ].res_oru_group[
          loop1 ].obx_group[loop2 ].obx.observation_value[loop3 ].value_16 ,substring (str_loop ,1 ,
           tmp_str1 ) )
        OF 18 :
         SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
         observation_value[loop3 ].value_18 = concat (oen_reply->person_group[1 ].res_oru_group[
          loop1 ].obx_group[loop2 ].obx.observation_value[loop3 ].value_18 ,substring (str_loop ,1 ,
           tmp_str1 ) )
        OF 20 :
         SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
         observation_value[loop3 ].value_20 = concat (oen_reply->person_group[1 ].res_oru_group[
          loop1 ].obx_group[loop2 ].obx.observation_value[loop3 ].value_20 ,substring (str_loop ,1 ,
           tmp_str1 ) )
        OF 22 :
         SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
         observation_value[loop3 ].value_22 = concat (oen_reply->person_group[1 ].res_oru_group[
          loop1 ].obx_group[loop2 ].obx.observation_value[loop3 ].value_22 ,substring (str_loop ,1 ,
           tmp_str1 ) )
       ENDCASE
      ELSE
       IF ((even (idx ) = 1 ) )
        SET idx = (idx + 1 )
       ENDIF
       CASE (idx )
        OF 1 :
         SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
         observation_value[loop3 ].value_1 = concat (oen_reply->person_group[1 ].res_oru_group[loop1
          ].obx_group[loop2 ].obx.observation_value[loop3 ].value_1 ,substring (str_loop ,1 ,
           tmp_str1 ) )
        OF 3 :
         SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
         observation_value[loop3 ].value_3 = concat (oen_reply->person_group[1 ].res_oru_group[loop1
          ].obx_group[loop2 ].obx.observation_value[loop3 ].value_3 ,substring (str_loop ,1 ,
           tmp_str1 ) )
        OF 5 :
         SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
         observation_value[loop3 ].value_5 = concat (oen_reply->person_group[1 ].res_oru_group[loop1
          ].obx_group[loop2 ].obx.observation_value[loop3 ].value_5 ,substring (str_loop ,1 ,
           tmp_str1 ) )
        OF 7 :
         SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
         observation_value[loop3 ].value_7 = concat (oen_reply->person_group[1 ].res_oru_group[loop1
          ].obx_group[loop2 ].obx.observation_value[loop3 ].value_7 ,substring (str_loop ,1 ,
           tmp_str1 ) )
        OF 9 :
         SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
         observation_value[loop3 ].value_9 = concat (oen_reply->person_group[1 ].res_oru_group[loop1
          ].obx_group[loop2 ].obx.observation_value[loop3 ].value_9 ,substring (str_loop ,1 ,
           tmp_str1 ) )
        OF 11 :
         SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
         observation_value[loop3 ].value_11 = concat (oen_reply->person_group[1 ].res_oru_group[
          loop1 ].obx_group[loop2 ].obx.observation_value[loop3 ].value_11 ,substring (str_loop ,1 ,
           tmp_str1 ) )
        OF 13 :
         SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
         observation_value[loop3 ].value_13 = concat (oen_reply->person_group[1 ].res_oru_group[
          loop1 ].obx_group[loop2 ].obx.observation_value[loop3 ].value_13 ,substring (str_loop ,1 ,
           tmp_str1 ) )
        OF 15 :
         SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
         observation_value[loop3 ].value_15 = concat (oen_reply->person_group[1 ].res_oru_group[
          loop1 ].obx_group[loop2 ].obx.observation_value[loop3 ].value_15 ,substring (str_loop ,1 ,
           tmp_str1 ) )
        OF 17 :
         SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
         observation_value[loop3 ].value_17 = concat (oen_reply->person_group[1 ].res_oru_group[
          loop1 ].obx_group[loop2 ].obx.observation_value[loop3 ].value_17 ,substring (str_loop ,1 ,
           tmp_str1 ) )
        OF 19 :
         SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
         observation_value[loop3 ].value_19 = concat (oen_reply->person_group[1 ].res_oru_group[
          loop1 ].obx_group[loop2 ].obx.observation_value[loop3 ].value_19 ,substring (str_loop ,1 ,
           tmp_str1 ) )
        OF 21 :
         SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
         observation_value[loop3 ].value_21 = concat (oen_reply->person_group[1 ].res_oru_group[
          loop1 ].obx_group[loop2 ].obx.observation_value[loop3 ].value_21 ,substring (str_loop ,1 ,
           tmp_str1 ) )
       ENDCASE
      ENDIF
     ENDFOR
    ENDIF
   ENDFOR
  ENDFOR
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group ,5 ) )
   IF ((cqm_subtype = "MICRO" )
   AND (size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
    observation_value ,5 ) > 1 ) )
    FOR (loop3 = size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
     observation_value ,5 ) TO 2 BY - (1 ) )
     SET stat = movereclist (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group ,oen_reply->
      person_group[1 ].res_oru_group[loop1 ].obx_group ,loop2 ,loop2 ,1 ,true )
     SET stat = alterlist (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[(loop2 + 1 ) ]
      .obx.observation_value ,1 )
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[(loop2 + 1 ) ].obx.
     observation_value[1 ].value_1 = oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[
     loop2 ].obx.observation_value[loop3 ].value_1
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[(loop2 + 1 ) ].obx.
     observation_value[1 ].value_2 = oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[
     loop2 ].obx.observation_value[loop3 ].value_2
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[(loop2 + 1 ) ].obx.
     observation_value[1 ].value_3 = oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[
     loop2 ].obx.observation_value[loop3 ].value_3
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[(loop2 + 1 ) ].obx.
     observation_value[1 ].value_4 = oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[
     loop2 ].obx.observation_value[loop3 ].value_4
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[(loop2 + 1 ) ].obx.
     observation_value[1 ].value_5 = oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[
     loop2 ].obx.observation_value[loop3 ].value_5
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[(loop2 + 1 ) ].obx.
     observation_value[1 ].value_6 = oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[
     loop2 ].obx.observation_value[loop3 ].value_6
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[(loop2 + 1 ) ].obx.
     observation_value[1 ].value_7 = oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[
     loop2 ].obx.observation_value[loop3 ].value_7
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[(loop2 + 1 ) ].obx.
     observation_value[1 ].value_8 = oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[
     loop2 ].obx.observation_value[loop3 ].value_8
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[(loop2 + 1 ) ].obx.
     observation_value[1 ].value_9 = oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[
     loop2 ].obx.observation_value[loop3 ].value_9
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[(loop2 + 1 ) ].obx.
     observation_value[1 ].value_10 = oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[
     loop2 ].obx.observation_value[loop3 ].value_10
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[(loop2 + 1 ) ].obx.
     observation_value[1 ].value_11 = oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[
     loop2 ].obx.observation_value[loop3 ].value_11
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[(loop2 + 1 ) ].obx.
     observation_value[1 ].value_12 = oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[
     loop2 ].obx.observation_value[loop3 ].value_12
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[(loop2 + 1 ) ].obx.
     observation_value[1 ].value_13 = oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[
     loop2 ].obx.observation_value[loop3 ].value_13
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[(loop2 + 1 ) ].obx.
     observation_value[1 ].value_14 = oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[
     loop2 ].obx.observation_value[loop3 ].value_14
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[(loop2 + 1 ) ].obx.
     observation_value[1 ].value_15 = oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[
     loop2 ].obx.observation_value[loop3 ].value_15
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[(loop2 + 1 ) ].obx.
     observation_value[1 ].value_16 = oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[
     loop2 ].obx.observation_value[loop3 ].value_16
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[(loop2 + 1 ) ].obx.
     observation_value[1 ].value_17 = oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[
     loop2 ].obx.observation_value[loop3 ].value_17
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[(loop2 + 1 ) ].obx.
     observation_value[1 ].value_18 = oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[
     loop2 ].obx.observation_value[loop3 ].value_18
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[(loop2 + 1 ) ].obx.
     observation_value[1 ].value_19 = oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[
     loop2 ].obx.observation_value[loop3 ].value_19
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[(loop2 + 1 ) ].obx.
     observation_value[1 ].value_20 = oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[
     loop2 ].obx.observation_value[loop3 ].value_20
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[(loop2 + 1 ) ].obx.
     observation_value[1 ].value_21 = oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[
     loop2 ].obx.observation_value[loop3 ].value_21
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[(loop2 + 1 ) ].obx.
     observation_value[1 ].value_22 = oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[
     loop2 ].obx.observation_value[loop3 ].value_22
    ENDFOR
    SET stat = alterlist (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
     observation_value ,1 )
   ENDIF
  ENDFOR
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group ,5 ) )
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.set_id = build (loop2
    )
  ENDFOR
  SET cnt1 = 0
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group ,5 ) )
   IF ((cqm_subtype = "MICRO" )
   AND (textlen (trim (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
     observation_id.identifier ) ) = 0 )
   AND (textlen (trim (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
     observation_id.text ) ) = 0 )
   AND (textlen (trim (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
     observation_id.coding_system ) ) = 0 )
   AND (textlen (trim (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
     observation_id.alt_identifier ) ) = 0 )
   AND (textlen (trim (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
     observation_id.alt_text ) ) = 0 )
   AND (textlen (trim (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
     observation_id.alt_coding_system ) ) = 0 ) )
    SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_id.
    identifier = oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.univ_service_id[1 ].identifier
    SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_id.text
    = oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.univ_service_id[1 ].text
    SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_id.
    coding_system = oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.univ_service_id[1 ].
    coding_system
    SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_id.
    alt_identifier = oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.univ_service_id[1 ].
    alt_identifier
    SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_id.
    alt_text = oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.univ_service_id[1 ].alt_text
    SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_id.
    alt_coding_system = oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.univ_service_id[1 ].
    alt_coding_system
    SET cnt1 = (cnt1 + 1 )
    SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_sub_id =
    build (cnt1 )
   ENDIF
  ENDFOR
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].nte ,5 ) )
   IF ((cqm_subtype = "MICRO" )
   AND NOT ((oen_reply->person_group[1 ].res_oru_group[loop1 ].nte[loop2 ].src_of_comment IN ("P" ,
   "O" ,
   "L" ) ) ) )
    SET oen_reply->person_group[1 ].res_oru_group[loop1 ].nte[loop2 ].comment_type.identifier =
    oen_reply->person_group[1 ].res_oru_group[loop1 ].nte[loop2 ].src_of_comment
    SET oen_reply->person_group[1 ].res_oru_group[loop1 ].nte[loop2 ].comment_type.coding_system =
    "HL70364"
    SET oen_reply->person_group[1 ].res_oru_group[loop1 ].nte[loop2 ].src_of_comment = "P"
   ENDIF
  ENDFOR
 ENDFOR
 FREE RECORD data_field
 RECORD data_field (
   1 qual [* ]
     2 field_ident = vc
     2 source_cd = f8
     2 source_display = vc
 )

 CALL add_data_field_by_cdf ("PID-13.2" ,"HL7V2" ,"HL70201" )
 CALL add_data_field_by_cdf ("NK1-2.7" ,"HL7V2" ,"HL70200" )
 CALL add_data_field_by_cdf ("NK1-3" ,"HL7V2" ,"HL70063" )
 CALL add_data_field_by_code ("NK1-4.4" ,prim_cont_source_cd ,"State Value Set" )
 CALL add_data_field_by_cdf ("NK1-4.6" ,"HL7V2" ,"Country Value Set" )
 CALL add_data_field_by_cdf ("NK1-4.7" ,"HL7V2" ,"HL70190" )
 CALL add_data_field_by_code ("NK1-4.9" ,prim_cont_source_cd ,"PHVS_County_FIPS_6-4" )
 CALL add_data_field_by_cdf ("NK1-5.2" ,"HL7V2" ,"HL70201" )
 CALL add_data_field_by_cdf ("NK1-30.7" ,"HL7V2" ,"HL70200" )
 CALL add_data_field_by_cdf ("NK1-31.2" ,"HL7V2" ,"HL70201" )
 CALL add_data_field_by_code ("NK1-32.4" ,prim_cont_source_cd ,"State Value Set" )
 CALL add_data_field_by_cdf ("NK1-32.6" ,"HL7V2" ,"Country Value Set" )
 CALL add_data_field_by_cdf ("NK1-32.7" ,"HL7V2" ,"HL70190" )
 CALL add_data_field_by_code ("NK1-32.9" ,prim_cont_source_cd ,"PHVS_County_FIPS_6-4" )
 CALL add_data_field_by_cdf ("NTE-2" ,"HL7V2" ,"HL70105" )
 CALL add_data_field_by_code ("NTE-4" ,prim_cont_source_cd ,"HL70364" )
 CALL add_data_field_by_cdf ("ORC-14.2" ,"HL7V2" ,"HL70201" )
 CALL add_data_field_by_code ("ORC-22.4" ,prim_cont_source_cd ,"State Value Set" )
 CALL add_data_field_by_cdf ("ORC-22.6" ,"HL7V2" ,"Country Value Set" )
 CALL add_data_field_by_cdf ("ORC-22.7" ,"HL7V2" ,"HL70190" )
 CALL add_data_field_by_code ("ORC-22.9" ,prim_cont_source_cd ,"PHVS_County_FIPS_6-4" )
 CALL add_data_field_by_cdf ("ORC-23.2" ,"HL7V2" ,"HL70201" )
 CALL add_data_field_by_code ("ORC-24.4" ,prim_cont_source_cd ,"State Value Set" )
 CALL add_data_field_by_cdf ("ORC-24.6" ,"HL7V2" ,"Country Value Set" )
 CALL add_data_field_by_cdf ("ORC-24.7" ,"HL7V2" ,"HL70190" )
 CALL add_data_field_by_code ("ORC-24.9" ,prim_cont_source_cd ,"PHVS_County_FIPS_6-4" )
 CALL add_data_field_by_cdf ("OBR-17.2" ,"HL7V2" ,"HL70201" )
 CALL add_data_field_by_cdf ("OBR-26.1" ,"LOINC" ,"LN" )
 CALL add_data_field_by_code ("OBR-31.3" ,prim_cont_source_cd ,"HL70396" )
 CALL add_data_field_by_code ("OBX-17" ,prim_cont_source_cd ,"OBSMETHOD" )
 CALL add_data_field_by_code ("OBX-24.4" ,prim_cont_source_cd ,"State Value Set" )
 CALL add_data_field_by_cdf ("OBX-24.6" ,"HL7V2" ,"Country Value Set" )
 CALL add_data_field_by_cdf ("OBX-24.7" ,"HL7V2" ,"HL70190" )
 CALL add_data_field_by_code ("OBX-24.9" ,prim_cont_source_cd ,"PHVS_County_FIPS_6-4" )
 CALL add_data_field_by_cdf ("SPM-12.2" ,"UCUM" ,"UCUM" )
 EXECUTE oencpm_msglog build ("Alias fields in PID Segment" ,char (0 ) )
 FOR (loop1 = 1 TO size (oen_reply->person_group[1 ].pat_group[1 ].pid.patient_address ,5 ) )
  EXECUTE oencpm_msglog build ("Alias PID-11.9 field" ,char (0 ) )
  SET oen_reply->person_group[1 ].pat_group[1 ].pid.patient_address[loop1 ].county = getfipscode (
   oen_reply->person_group[1 ].pat_group[1 ].pid.patient_address[loop1 ].county ,oen_reply->
   person_group[1 ].pat_group[1 ].pid.patient_address[loop1 ].state_prov )
 ENDFOR
 FOR (loop1 = 1 TO size (oen_reply->person_group[1 ].pat_group[1 ].pid.ph_nbr_home ,5 ) )
  EXECUTE oencpm_msglog build ("Alias PID-13.2 field" ,char (0 ) )
  CALL populate_id ("PID-13.2" ,oen_reply->person_group[1 ].pat_group[1 ].pid.ph_nbr_home[loop1 ].
   telecom_use_cd )
 ENDFOR
 EXECUTE oencpm_msglog build ("Alias fields in NK1 Segment" ,char (0 ) )
 FOR (loop1 = 1 TO size (oen_reply->person_group[1 ].pat_group[1 ].nk1 ,5 ) )
  EXECUTE oencpm_msglog build ("Alias NK1-2.7 field" ,char (0 ) )
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_name ,5 ) )
   CALL populate_id ("NK1-2.7" ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_name[loop2 ]
    .name_type_cd )
  ENDFOR
  EXECUTE oencpm_msglog build ("Alias NK1-3 field" ,char (0 ) )
  CALL populate_cwe ("NK1-3" ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].relationship.
   identifier ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].relationship.text ,oen_reply->
   person_group[1 ].pat_group[1 ].nk1[loop1 ].relationship.coding_system )
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_address ,5 ) )
   EXECUTE oencpm_msglog build ("Alias NK1-4.4 field" ,char (0 ) )
   CALL populate_id ("NK1-4.4" ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_address[
    loop2 ].state_prov )
   EXECUTE oencpm_msglog build ("Alias NK1-4.6 field" ,char (0 ) )
   CALL populate_id ("NK1-4.6" ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_address[
    loop2 ].country )
   EXECUTE oencpm_msglog build ("Alias NK1-4.7 field" ,char (0 ) )
   CALL populate_id ("NK1-4.7" ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_address[
    loop2 ].types )
   EXECUTE oencpm_msglog build ("Alias NK1-4.9 field" ,char (0 ) )
   CALL populate_id ("NK1-4.9" ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_address[
    loop2 ].county )
   SET oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_address[loop2 ].county = getfipscode
   (oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_address[loop2 ].county ,oen_reply->
    person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_address[loop2 ].state_prov )
  ENDFOR
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].ph_nbr_home ,5 ) )
   EXECUTE oencpm_msglog build ("Alias NK1-5.2 field" ,char (0 ) )
   CALL populate_id ("NK1-5.2" ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].ph_nbr_home[
    loop2 ].telecom_use_cd )
  ENDFOR
  EXECUTE oencpm_msglog build ("Alias NK1-30.7 field" ,char (0 ) )
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].
   nk_contact_person_name ,5 ) )
   CALL populate_id ("NK1-30.7" ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].
    nk_contact_person_name[loop2 ].name_type_cd )
  ENDFOR
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_phone ,5
   ) )
   EXECUTE oencpm_msglog build ("Alias NK1-31.2 field" ,char (0 ) )
   CALL populate_id ("NK1-31.2" ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].
    nk_contact_phone[loop2 ].telecom_use_cd )
  ENDFOR
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_address ,
   5 ) )
   EXECUTE oencpm_msglog build ("Alias NK1-32.4 field" ,char (0 ) )
   CALL populate_id ("NK1-32.4" ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].
    nk_contact_address[loop2 ].state_prov )
   EXECUTE oencpm_msglog build ("Alias NK1-32.6 field" ,char (0 ) )
   CALL populate_id ("NK1-32.6" ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].
    nk_contact_address[loop2 ].country )
   EXECUTE oencpm_msglog build ("Alias NK1-32.7 field" ,char (0 ) )
   CALL populate_id ("NK1-32.7" ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].
    nk_contact_address[loop2 ].types )
   EXECUTE oencpm_msglog build ("Alias NK1-32.9 field" ,char (0 ) )
   CALL populate_id ("NK1-32.9" ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].
    nk_contact_address[loop2 ].county )
   SET oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_address[loop2 ].county =
   getfipscode (oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_address[loop2 ].
    county ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_contact_address[loop2 ].
    state_prov )
  ENDFOR
 ENDFOR
 FOR (loop1 = 1 TO size (oen_reply->person_group[1 ].pat_group[1 ].nte ,5 ) )
  EXECUTE oencpm_msglog build ("Alias NTE-2 field" ,char (0 ) )
  CALL populate_id ("NTE-2" ,oen_reply->person_group[1 ].pat_group[1 ].nte[loop1 ].src_of_comment )
  EXECUTE oencpm_msglog build ("Alias NTE-4 field" ,char (0 ) )
  CALL populate_cwe ("NTE-4" ,oen_reply->person_group[1 ].pat_group[1 ].nte[loop1 ].comment_type.
   identifier ,oen_reply->person_group[1 ].pat_group[1 ].nte[loop1 ].comment_type.text ,oen_reply->
   person_group[1 ].pat_group[1 ].nte[loop1 ].comment_type.coding_system )
 ENDFOR
 FOR (loop1 = 1 TO size (oen_reply->person_group[1 ].res_oru_group ,5 ) )
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc ,5 ) )
   FOR (loop3 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
    callbk_ph_nbr ,5 ) )
    EXECUTE oencpm_msglog build ("Alias ORC-14.2 field" ,char (0 ) )
    CALL populate_id ("ORC-14.2" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
     callbk_ph_nbr[loop3 ].telecom_use_cd )
   ENDFOR
   FOR (loop3 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
    ord_fac_address ,5 ) )
    EXECUTE oencpm_msglog build ("Alias ORC-22.4 field" ,char (0 ) )
    CALL populate_id ("ORC-22.4" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
     ord_fac_address[loop3 ].state_prov )
    EXECUTE oencpm_msglog build ("Alias ORC-22.6 field" ,char (0 ) )
    CALL populate_id ("ORC-22.6" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
     ord_fac_address[loop3 ].country )
    EXECUTE oencpm_msglog build ("Alias ORC-22.7 field" ,char (0 ) )
    CALL populate_id ("ORC-22.7" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
     ord_fac_address[loop3 ].types )
    EXECUTE oencpm_msglog build ("Alias ORC-22.9 field" ,char (0 ) )
    CALL populate_id ("ORC-22.9" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
     ord_fac_address[loop3 ].county )
    SET oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_address[loop3 ].county
    = getfipscode (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_address[
     loop3 ].county ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_address[
     loop3 ].state_prov )
   ENDFOR
   FOR (loop3 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
    ord_fac_ph_nbr ,5 ) )
    EXECUTE oencpm_msglog build ("Alias ORC-23.2 field" ,char (0 ) )
    CALL populate_id ("ORC-23.2" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
     ord_fac_ph_nbr[loop3 ].telecom_use_cd )
   ENDFOR
   FOR (loop3 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
    provider_address ,5 ) )
    EXECUTE oencpm_msglog build ("Alias ORC-24.4 field" ,char (0 ) )
    CALL populate_id ("ORC-24.4" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
     provider_address[loop3 ].state_prov )
    EXECUTE oencpm_msglog build ("Alias ORC-24.6 field" ,char (0 ) )
    CALL populate_id ("ORC-24.6" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
     provider_address[loop3 ].country )
    EXECUTE oencpm_msglog build ("Alias ORC-24.7 field" ,char (0 ) )
    CALL populate_id ("ORC-24.7" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
     provider_address[loop3 ].types )
    EXECUTE oencpm_msglog build ("Alias ORC-24.9 field" ,char (0 ) )
    CALL populate_id ("ORC-24.9" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
     provider_address[loop3 ].county )
    SET oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].provider_address[loop3 ].county
     = getfipscode (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].provider_address[
     loop3 ].county ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].provider_address[
     loop3 ].state_prov )
   ENDFOR
  ENDFOR
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.ord_callback_ph_nbr ,
   5 ) )
   EXECUTE oencpm_msglog build ("Alias OBR-17.2 field" ,char (0 ) )
   CALL populate_id ("OBR-17.2" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.
    ord_callback_ph_nbr[loop2 ].telecom_use_cd )
  ENDFOR
  EXECUTE oencpm_msglog build ("Alias OBR-26.1 field" ,char (0 ) )
  CALL populate_cwe ("OBR-26.1" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.
   obs_id.identifier ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_id.text
    ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_result.obs_id.coding_system )
  EXECUTE oencpm_msglog build ("Alias OBR-31.3 field" ,char (0 ) )
  CALL populate_id ("OBR-31.3" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.
   reason_for_study.coding_system )
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group ,5 ) )
   FOR (loop3 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
    obs_method ,5 ) )
    EXECUTE oencpm_msglog build ("Alias OBX-17 field" ,char (0 ) )
    CALL populate_cwe ("OBX-17" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].
     obx.obs_method[loop3 ].identifier ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[
     loop2 ].obx.obs_method[loop3 ].text ,oen_reply->person_group[1 ].res_oru_group[loop1 ].
     obx_group[loop2 ].obx.obs_method[loop3 ].coding_system )
   ENDFOR
   FOR (loop3 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
    performing_org_addr ,5 ) )
    EXECUTE oencpm_msglog build ("Alias OBX-24.4 field" ,char (0 ) )
    CALL populate_id ("OBX-24.4" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ]
     .obx.performing_org_addr[loop3 ].state_prov )
    EXECUTE oencpm_msglog build ("Alias OBX-24.6 field" ,char (0 ) )
    CALL populate_id ("OBX-24.6" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ]
     .obx.performing_org_addr[loop3 ].country )
    EXECUTE oencpm_msglog build ("Alias OBX-24.7 field" ,char (0 ) )
    CALL populate_id ("OBX-24.7" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ]
     .obx.performing_org_addr[loop3 ].types )
    EXECUTE oencpm_msglog build ("Alias OBX-24.9 field" ,char (0 ) )
    CALL populate_id ("OBX-24.9" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ]
     .obx.performing_org_addr[loop3 ].county )
    SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.performing_org_addr[
    loop3 ].county = getfipscode (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ]
     .obx.performing_org_addr[loop3 ].county ,oen_reply->person_group[1 ].res_oru_group[loop1 ].
     obx_group[loop2 ].obx.performing_org_addr[loop3 ].state_prov )
   ENDFOR
  ENDFOR
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].specimen_group ,5 ) )
   EXECUTE oencpm_msglog build ("Alias SPM-12.2 field" ,char (0 ) )
   CALL populate_cwe ("SPM-12.2" ,oen_reply->person_group[1 ].res_oru_group[loop1 ].specimen_group[
    loop2 ].spm.spec_col_amt.unit.identifier ,oen_reply->person_group[1 ].res_oru_group[loop1 ].
    specimen_group[loop2 ].spm.spec_col_amt.unit.text ,oen_reply->person_group[1 ].res_oru_group[
    loop1 ].specimen_group[loop2 ].spm.spec_col_amt.unit.coding_system )
  ENDFOR
 ENDFOR
 EXECUTE oencpm_msglog build ("Format Fields Section..." ,char (0 ) )
 FOR (loop1 = 1 TO size (oen_reply->person_group[1 ].pat_group[1 ].nk1 ,5 ) )
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_address ,5 ) )
   EXECUTE oencpm_msglog build ("Format NK1-4.5" ,char (0 ) )
   CALL format_zip (oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_address[loop2 ].zip_code
     ,oen_reply->person_group[1 ].pat_group[1 ].nk1[loop1 ].nk_address[loop2 ].country )
  ENDFOR
 ENDFOR
 FOR (loop1 = 1 TO size (oen_reply->person_group[1 ].res_oru_group ,5 ) )
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc ,5 ) )
   FOR (loop3 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
    ord_fac_address ,5 ) )
    EXECUTE oencpm_msglog build ("Format ORC-22.5" ,char (0 ) )
    CALL format_zip (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_address[
     loop3 ].zip_code ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_fac_address[
     loop3 ].country )
   ENDFOR
   FOR (loop3 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
    provider_address ,5 ) )
    EXECUTE oencpm_msglog build ("Format ORC-24.5" ,char (0 ) )
    CALL format_zip (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].provider_address[
     loop3 ].zip_code ,oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
     provider_address[loop3 ].country )
   ENDFOR
  ENDFOR
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group ,5 ) )
   FOR (loop3 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
    performing_org_addr ,5 ) )
    EXECUTE oencpm_msglog build ("Format OBX-24.5" ,char (0 ) )
    CALL format_zip (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
     performing_org_addr[loop3 ].zip_code ,oen_reply->person_group[1 ].res_oru_group[loop1 ].
     obx_group[loop2 ].obx.performing_org_addr[loop3 ].country )
   ENDFOR
  ENDFOR
 ENDFOR
 FOR (loop1 = 1 TO size (oen_reply->person_group[1 ].pat_group[1 ].nte ,5 ) )
  IF ((oen_reply->person_group[1 ].pat_group[1 ].nte[loop1 ].comment_type.identifier > " " )
  AND (oen_reply->person_group[1 ].pat_group[1 ].nte[loop1 ].comment_type.coding_system = "" ) )
   EXECUTE oencpm_msglog build ("Set PID-NTE-4" ,char (0 ) )
   SET oen_reply->person_group[1 ].pat_group[1 ].nte[loop1 ].comment_type.coding_system = "HL70364"
  ENDIF
 ENDFOR
 FOR (loop1 = 1 TO size (oen_reply->person_group[1 ].res_oru_group ,5 ) )
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc ,5 ) )
   FOR (loop3 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
    filler_ord_nbr ,5 ) )
    EXECUTE oencpm_msglog build ("Set ORC-3.3" ,char (0 ) )
    SET oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].filler_ord_nbr[loop3 ].univ_id
    = org_univ_id
    EXECUTE oencpm_msglog build ("Set ORC-3.4" ,char (0 ) )
    SET oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].filler_ord_nbr[loop3 ].
    univ_id_type = org_univ_id_type
   ENDFOR
   FOR (loop3 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_provider
     ,5 ) )
    IF ((textlen (trim (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_provider[
      loop3 ].assign_fac_id.name_id ) ) = 0 ) )
     EXECUTE oencpm_msglog build ("Set ORC-12.14.1" ,char (0 ) )
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_provider[loop3 ].
     assign_fac_id.name_id = org_name_id
     EXECUTE oencpm_msglog build ("Set ORC-12.14.2" ,char (0 ) )
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_provider[loop3 ].
     assign_fac_id.univ_id = org_univ_id
     EXECUTE oencpm_msglog build ("Set ORC-12.14.3" ,char (0 ) )
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].ord_provider[loop3 ].
     assign_fac_id.univ_id_type = org_univ_id_type
    ENDIF
   ENDFOR
  ENDFOR
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.filler_ord_nbr ,5 ) )
   EXECUTE oencpm_msglog build ("Set OBR-3.3" ,char (0 ) )
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.filler_ord_nbr[loop2 ].univ_id =
   org_univ_id
   EXECUTE oencpm_msglog build ("Set OBR-3.4" ,char (0 ) )
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.filler_ord_nbr[loop2 ].univ_id_type =
   org_univ_id_type
  ENDFOR
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.ord_provider ,5 ) )
   IF ((textlen (trim (oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.ord_provider[loop2 ].
     assign_fac_id.name_id ) ) = 0 ) )
    EXECUTE oencpm_msglog build ("Set OBR-16.14.1" ,char (0 ) )
    SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.ord_provider[loop2 ].assign_fac_id.
    name_id = org_name_id
    EXECUTE oencpm_msglog build ("Set OBR-16.14.2" ,char (0 ) )
    SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.ord_provider[loop2 ].assign_fac_id.
    univ_id = org_univ_id
    EXECUTE oencpm_msglog build ("Set OBR-16.14.3" ,char (0 ) )
    SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.ord_provider[loop2 ].assign_fac_id.
    univ_id_type = org_univ_id_type
   ENDIF
  ENDFOR
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_nbr ,5 ) )
   IF ((textlen (trim (oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_nbr[loop2 ].
     filler_ord_nbr.name_id ) ) > 0 ) )
    EXECUTE oencpm_msglog build ("Set OBR-29.2.3" ,char (0 ) )
    SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_nbr[loop2 ].filler_ord_nbr.
    univ_id = org_univ_id
    EXECUTE oencpm_msglog build ("Set OBR-29.2.4" ,char (0 ) )
    SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.parent_nbr[loop2 ].filler_ord_nbr.
    univ_id_type = org_univ_id_type
   ENDIF
  ENDFOR
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.prim_res_interp ,5 )
   )
   EXECUTE oencpm_msglog build ("Set OBR-32.1.9" ,char (0 ) )
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.prim_res_interp[loop2 ].name.
   assign_auth_namespace_id = org_name_id
   EXECUTE oencpm_msglog build ("Set OBR-32.1.10" ,char (0 ) )
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.prim_res_interp[loop2 ].name.
   assign_auth_univ_id = org_univ_id
   EXECUTE oencpm_msglog build ("Set OBR-32.1.11" ,char (0 ) )
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.prim_res_interp[loop2 ].name.
   assign_auth_univ_id_type = org_univ_id_type
  ENDFOR
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].nte ,5 ) )
   IF ((oen_reply->person_group[1 ].res_oru_group[loop1 ].nte[loop2 ].comment_type.identifier > " "
   )
   AND (oen_reply->person_group[1 ].res_oru_group[loop1 ].nte[loop2 ].comment_type.coding_system =
   "" ) )
    EXECUTE oencpm_msglog build ("Set OBR-NTE-4" ,char (0 ) )
    SET oen_reply->person_group[1 ].res_oru_group[loop1 ].nte[loop2 ].comment_type.coding_system =
    "HL70364"
   ENDIF
  ENDFOR
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group ,5 ) )
   FOR (loop3 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
    performing_org_name ,5 ) )
    IF ((textlen (trim (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
      performing_org_name[loop3 ].assign_authority.name_id ) ) > 0 )
    AND (textlen (trim (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
      performing_org_name[loop3 ].assign_authority.univ_id ) ) = 0 ) )
     EXECUTE oencpm_msglog build ("Set OBX-23.6.2" ,char (0 ) )
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.performing_org_name[
     loop3 ].assign_authority.univ_id = org_univ_id
    ENDIF
    IF ((textlen (trim (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
      performing_org_name[loop3 ].assign_authority.name_id ) ) > 0 )
    AND (textlen (trim (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
      performing_org_name[loop3 ].assign_authority.univ_id_type ) ) = 0 ) )
     EXECUTE oencpm_msglog build ("Set OBX-23.6.3" ,char (0 ) )
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.performing_org_name[
     loop3 ].assign_authority.univ_id_type = org_univ_id_type
    ENDIF
   ENDFOR
   FOR (loop3 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].nte ,
    5 ) )
    IF ((oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].nte[loop3 ].comment_type
    .identifier > " " )
    AND (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].nte[loop3 ].comment_type
    .coding_system = "" ) )
     EXECUTE oencpm_msglog build ("Set OBX-NTE-4" ,char (0 ) )
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].nte[loop3 ].comment_type
     .coding_system = "HL70364"
    ENDIF
   ENDFOR
  ENDFOR
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].specimen_group ,5 ) )
   EXECUTE oencpm_msglog build ("Set SPM-2.2.3" ,char (0 ) )
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].specimen_group[loop2 ].spm.spec_id.
   filler_ord_nbr.univ_id = org_univ_id
   EXECUTE oencpm_msglog build ("Set SPM-2.2.4" ,char (0 ) )
   SET oen_reply->person_group[1 ].res_oru_group[loop1 ].specimen_group[loop2 ].spm.spec_id.
   filler_ord_nbr.univ_id_type = org_univ_id_type
   IF ((((textlen (trim (oen_reply->person_group[1 ].res_oru_group[loop1 ].specimen_group[loop2 ].spm
     .spec_col_method.identifier ) ) > 0 ) ) OR ((textlen (trim (oen_reply->person_group[1 ].
     res_oru_group[loop1 ].specimen_group[loop2 ].spm.spec_col_method.text ) ) > 0 ) )) )
    EXECUTE oencpm_msglog build ("Set SPM-7.3" ,char (0 ) )
    SET oen_reply->person_group[1 ].res_oru_group[loop1 ].specimen_group[loop2 ].spm.spec_col_method.
    coding_system = "HL70488"
   ENDIF
  ENDFOR
 ENDFOR
 FOR (loop1 = 1 TO size (oen_reply->person_group[1 ].res_oru_group ,5 ) )
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc ,5 ) )
   IF ((size (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].placer_ord_nbr ,5 ) = 0
   )
   AND (size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.placer_ord_nbr ,5 ) = 0 ) )
    FOR (loop3 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
     filler_ord_nbr ,5 ) )
     SET stat = alterlist (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
      placer_ord_nbr ,size (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].
       filler_ord_nbr ,5 ) )
     EXECUTE oencpm_msglog build ("Copy ORC-3.1 to ORC-2.1" ,char (0 ) )
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].placer_ord_nbr[loop3 ].
     entity_id = oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].filler_ord_nbr[loop3 ]
     .entity_id
     EXECUTE oencpm_msglog build ("Copy ORC-3.2 to ORC-2.2" ,char (0 ) )
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].placer_ord_nbr[loop3 ].name_id
      = oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].filler_ord_nbr[loop3 ].name_id
     EXECUTE oencpm_msglog build ("Copy ORC-3.3 to ORC-2.3" ,char (0 ) )
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].placer_ord_nbr[loop3 ].univ_id
      = oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].filler_ord_nbr[loop3 ].univ_id
     EXECUTE oencpm_msglog build ("Copy ORC-3.4 to ORC-2.4" ,char (0 ) )
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].placer_ord_nbr[loop3 ].
     univ_id_type = oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].filler_ord_nbr[
     loop3 ].univ_id_type
     SET stat = alterlist (oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.placer_ord_nbr ,
      size (oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].filler_ord_nbr ,5 ) )
     EXECUTE oencpm_msglog build ("Copy OBR-3.1 to OBR-2.1" ,char (0 ) )
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.placer_ord_nbr[1 ].entity_id =
     oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].filler_ord_nbr[loop3 ].entity_id
     EXECUTE oencpm_msglog build ("Copy OBR-3.2 to OBR-2.2" ,char (0 ) )
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.placer_ord_nbr[1 ].name_id = oen_reply
     ->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].filler_ord_nbr[loop3 ].name_id
     EXECUTE oencpm_msglog build ("Copy OBR-3.3 to OBR-2.3" ,char (0 ) )
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.placer_ord_nbr[1 ].univ_id = oen_reply
     ->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].filler_ord_nbr[loop3 ].univ_id
     EXECUTE oencpm_msglog build ("Copy OBR-3.4 to OBR-2.4" ,char (0 ) )
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obr.placer_ord_nbr[1 ].univ_id_type =
     oen_reply->person_group[1 ].res_oru_group[loop1 ].orc[loop2 ].filler_ord_nbr[loop3 ].
     univ_id_type
    ENDFOR
   ENDIF
  ENDFOR
 ENDFOR
 FOR (loop1 = 1 TO size (oen_reply->person_group[1 ].pat_group[1 ].pid.patient_address ,5 ) )
  SET oen_reply->person_group[1 ].pat_group[1 ].pid.patient_address[loop1 ].county = cnvtupper (
   oen_reply->person_group[1 ].pat_group[1 ].pid.patient_address[loop1 ].county )
 ENDFOR
 EXECUTE oencpm_msglog build ("Correct PID-35.3" ,char (0 ) )
 IF ((textlen (trim (oen_reply->person_group[1 ].pat_group[1 ].pid.species_cd.identifier ) ) > 0 ) )
  SET oen_reply->person_group[1 ].pat_group[1 ].pid.species_cd.coding_system = "SCT"
 ENDIF
 FOR (loop1 = 1 TO size (oen_reply->person_group[1 ].res_oru_group ,5 ) )
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group ,5 ) )
   FOR (loop3 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.
    observation_value ,5 ) )
    EXECUTE oencpm_msglog build ("Correct OBX-5.6" ,char (0 ) )
    IF ((oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
    loop3 ].value_6 = "SCT" ) )
     SET oen_reply->person_group[1 ].res_oru_group[loop1 ].obx_group[loop2 ].obx.observation_value[
     loop3 ].value_6 = "L"
    ENDIF
   ENDFOR
  ENDFOR
  FOR (loop2 = 1 TO size (oen_reply->person_group[1 ].res_oru_group[loop1 ].specimen_group ,5 ) )
   EXECUTE oencpm_msglog build ("Correct SPM-4.6" ,char (0 ) )
   IF ((textlen (trim (oen_reply->person_group[1 ].res_oru_group[loop1 ].specimen_group[loop2 ].spm.
     spec_type.alt_coding_system ) ) > 0 ) )
    SET oen_reply->person_group[1 ].res_oru_group[loop1 ].specimen_group[loop2 ].spm.spec_type.
    alt_coding_system = "SCT"
   ENDIF
  ENDFOR
 ENDFOR
 EXECUTE oencpm_msglog build ("Remove fields that are not supported by the Federal specification" ,
  char (0 ) )
 SET oen_reply->person_group[1 ].pat_group[1 ].pid.nationality.identifier = ""
 SET oen_reply->person_group[1 ].pat_group[1 ].pid.nationality.text = ""
 SET oen_reply->person_group[1 ].pat_group[1 ].pid.nationality.coding_system = ""
 SET oen_reply->person_group[1 ].pat_group[1 ].pid.nationality.alt_identifier = ""
 SET oen_reply->person_group[1 ].pat_group[1 ].pid.nationality.alt_text = ""
 SET oen_reply->person_group[1 ].pat_group[1 ].pid.nationality.alt_coding_system = ""
 SET oen_reply->person_group[1 ].pat_group[1 ].pid.nationality.coding_system_version = ""
 SET oen_reply->person_group[1 ].pat_group[1 ].pid.nationality.alt_coding_system_ver = ""
 SET oen_reply->person_group[1 ].pat_group[1 ].pid.nationality.original_text = ""
 FOR (loop1 = 1 TO size (oen_reply->person_group[1 ].pat_group[1 ].visit_group ,5 ) )
  SET oen_reply->person_group[1 ].pat_group[1 ].visit_group[loop1 ].pv1.readmission_ind = ""
  SET stat = alterlist (oen_reply->person_group[1 ].pat_group[1 ].visit_group[loop1 ].pv1.
   ambulatory_srvc ,0 )
  SET oen_reply->person_group[1 ].pat_group[1 ].visit_group[loop1 ].pv1.vip_ind = ""
  SET oen_reply->person_group[1 ].pat_group[1 ].visit_group[loop1 ].pv1.charge_price_ind = ""
  SET oen_reply->person_group[1 ].pat_group[1 ].visit_group[loop1 ].pv1.courtesy_cd = ""
  SET oen_reply->person_group[1 ].pat_group[1 ].visit_group[loop1 ].pv1.credit_rating = ""
  SET stat = alterlist (oen_reply->person_group[1 ].pat_group[1 ].visit_group[loop1 ].pv1.contract_cd
    ,0 )
  SET stat = alterlist (oen_reply->person_group[1 ].pat_group[1 ].visit_group[loop1 ].pv1.
   contract_effective_dt ,0 )
  SET stat = alterlist (oen_reply->person_group[1 ].pat_group[1 ].visit_group[loop1 ].pv1.
   contract_amt ,0 )
  SET stat = alterlist (oen_reply->person_group[1 ].pat_group[1 ].visit_group[loop1 ].pv1.
   contract_period ,0 )
  SET oen_reply->person_group[1 ].pat_group[1 ].visit_group[loop1 ].pv1.interest_cd = ""
  SET oen_reply->person_group[1 ].pat_group[1 ].visit_group[loop1 ].pv1.xfr_to_bad_dbt_cd = ""
  IF ((oen_reply->person_group[1 ].pat_group[1 ].visit_group[loop1 ].pv1.dschg_dis = '""' ) )
   SET oen_reply->person_group[1 ].pat_group[1 ].visit_group[loop1 ].pv1.dschg_dis = ""
  ENDIF
 ENDFOR
#exit_script
 set filename = build("cclscratch:",cnvtlower(trim(curprog))
										,"_",format(cnvtdatetime(curdate, curtime3)
										,"yyyy_mm_dd_hh_mm_ss;;d")
										,".dat"
										)
call echojson(oen_reply,filename,1)
call echojson(oenstatus,filename,1)
call echojson(data,filename,1)
call echojson(data_field,filename,1)

 FREE RECORD data
 FREE RECORD data_field
 EXECUTE oencpm_msglog build ("Exiting-" ,current_program ,char (0 ) )
END GO
