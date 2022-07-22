
DROP PROGRAM bed_aud_pref_maint :dba GO
CREATE PROGRAM bed_aud_pref_maint :dba
 IF (NOT (validate (request ,0 ) ) )
  RECORD request (
    1 program_name = vc
    1 skip_volume_check_ind = i2
    1 output_filename = vc
    1 pvc_name = vc
    1 pvc_value = vc
    1 level_flag = i2
  )
 ENDIF
 IF (NOT (validate (reply ,0 ) ) )
  RECORD reply (
    1 collist [* ]
      2 header_text = vc
      2 data_type = i2
      2 hide_ind = i2
    1 rowlist [* ]
      2 celllist [* ]
        3 date_value = dq8
        3 nbr_value = i4
        3 double_value = f8
        3 string_value = vc
        3 display_flag = i2
    1 high_volume_flag = i2
    1 output_filename = vc
    1 run_status_flag = i2
    1 statlist [* ]
      2 statistic_meaning = vc
      2 status_flag = i2
      2 qualifying_items = i4
      2 total_items = i4
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
 ENDIF
 RECORD temp (
   1 pref_list [* ]
     2 nvp_id = f8
     2 pref_id = f8
     2 pvc_name = vc
     2 pvc_value = vc
     2 application_number = i4
     2 application_name = vc
     2 position_cd = f8
     2 position_name = vc
     2 position_active = i2
     2 person_id = f8
     2 person_name = vc
     2 person_active = i2
     2 level = vc
     2 parent = vc
     2 search_detail_pref = i2
 )
 RECORD nvps (
   1 prefs [* ]
     2 nvp_id = f8
     2 parent_entity_id = f8
     2 parent_entity_name = vc
     2 pvc_name = vc
     2 pvc_value = vc
     2 sequence = i4
 )
 DECLARE error_flag = vc
 SET error_flag = "N"
 SET reply->status_data.status = "F"
 SET nvpcnt = 0
 SET tcnt = 0
 DECLARE pvcvalueparse = vc
 SET pvcvalueparse = build ("cnvtupper(nvp.pvc_name) = cnvtupper('" ,trim (request->pvc_name ) ,"')"
  )
 IF ((request->pvc_value > " " ) )
  SET pvcvalueparse = build (pvcvalueparse ," and nvp.pvc_value = '" ,trim (request->pvc_value ) ,
   "'" )
 ENDIF
 SELECT INTO "nl:"
  FROM (name_value_prefs nvp )
  PLAN (nvp
   WHERE parser (pvcvalueparse ) )
  DETAIL
   nvpcnt = (nvpcnt + 1 ) ,
   stat = alterlist (nvps->prefs ,nvpcnt ) ,
   nvps->prefs[nvpcnt ].nvp_id = nvp.name_value_prefs_id ,
   nvps->prefs[nvpcnt ].parent_entity_id = nvp.parent_entity_id ,
   nvps->prefs[nvpcnt ].parent_entity_name = nvp.parent_entity_name ,
   nvps->prefs[nvpcnt ].pvc_name = nvp.pvc_name ,
   nvps->prefs[nvpcnt ].pvc_value = nvp.pvc_value ,
   nvps->prefs[nvpcnt ].sequence = nvp.sequence
  WITH nocounter
 ;end select
 IF ((nvpcnt = 0 ) )
  GO TO exit_script
 ENDIF
 DECLARE levelparse = vc
 SET levelparse = "p.application_number > 0"
 IF ((request->level_flag = 1 ) )
  SET levelparse = build2 (levelparse ," and p.position_cd = 0 and p.prsnl_id = 0" )
 ELSEIF ((request->level_flag = 2 ) )
  SET levelparse = build2 (levelparse ," and p.position_cd > 0 and p.prsnl_id = 0" )
 ELSEIF ((request->level_flag = 3 ) )
  SET levelparse = build2 (levelparse ," and p.position_cd = 0 and p.prsnl_id > 0" )
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d WITH seq = nvpcnt ),
   (app_prefs p )
  PLAN (d
   WHERE (nvps->prefs[d.seq ].parent_entity_name = "APP_PREFS" ) )
   JOIN (p
   WHERE (p.app_prefs_id = nvps->prefs[d.seq ].parent_entity_id )
   AND parser (levelparse ) )
  DETAIL
   tcnt = (tcnt + 1 ) ,
   stat = alterlist (temp->pref_list ,tcnt ) ,
   temp->pref_list[tcnt ].nvp_id = nvps->prefs[d.seq ].nvp_id ,
   temp->pref_list[tcnt ].pref_id = p.app_prefs_id ,
   temp->pref_list[tcnt ].pvc_value = nvps->prefs[d.seq ].pvc_value ,
   temp->pref_list[tcnt ].application_number = p.application_number ,
   temp->pref_list[tcnt ].position_cd = p.position_cd ,
   temp->pref_list[tcnt ].person_id = p.prsnl_id ,
   temp->pref_list[tcnt ].pvc_name = nvps->prefs[d.seq ].pvc_name
  WITH nocounter
 ;end select
 DECLARE parent_string = vc
 SELECT INTO "nl:"
  FROM (dummyt d WITH seq = nvpcnt ),
   (view_prefs p ),
   (name_value_prefs nvp ),
   (view_prefs p2 ),
   (name_value_prefs nvp2 )
  PLAN (d
   WHERE (nvps->prefs[d.seq ].parent_entity_name = "VIEW_PREFS" ) )
   JOIN (p
   WHERE (p.view_prefs_id = nvps->prefs[d.seq ].parent_entity_id )
   AND parser (levelparse ) )
   JOIN (nvp
   WHERE (nvp.parent_entity_id = p.view_prefs_id )
   AND (nvp.pvc_name = "VIEW_CAPTION" ) )
   JOIN (p2
   WHERE (p2.view_name = outerjoin (p.frame_type ) )
   AND (p2.application_number = outerjoin (p.application_number ) )
   AND (p2.position_cd = outerjoin (p.position_cd ) )
   AND (p2.prsnl_id = outerjoin (p.prsnl_id ) ) )
   JOIN (nvp2
   WHERE (nvp2.parent_entity_id = outerjoin (p2.view_prefs_id ) )
   AND (nvp2.pvc_name = outerjoin ("VIEW_CAPTION" ) ) )
  DETAIL
   tcnt = (tcnt + 1 ) ,
   stat = alterlist (temp->pref_list ,tcnt ) ,
   temp->pref_list[tcnt ].nvp_id = nvps->prefs[d.seq ].nvp_id ,
   temp->pref_list[tcnt ].pref_id = p.view_prefs_id ,
   temp->pref_list[tcnt ].pvc_value = nvps->prefs[d.seq ].pvc_value ,
   temp->pref_list[tcnt ].application_number = p.application_number ,
   temp->pref_list[tcnt ].position_cd = p.position_cd ,
   temp->pref_list[tcnt ].person_id = p.prsnl_id ,
   temp->pref_list[tcnt ].pvc_name = nvps->prefs[d.seq ].pvc_name ,
   temp->pref_list[tcnt ].level = build2 (trim (p.view_name ) ," | " ,trim (nvp.pvc_value ) ) ,
   parent_string = p.frame_type ,
   IF ((trim (nvp2.pvc_value ) > " " ) ) parent_string = build2 (trim (p.frame_type ) ," | " ,trim (
      nvp2.pvc_value ) )
   ENDIF
   ,temp->pref_list[tcnt ].parent = parent_string
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d WITH seq = nvpcnt ),
   (view_comp_prefs p ),
   (view_prefs v ),
   (name_value_prefs nvp )
  PLAN (d
   WHERE (nvps->prefs[d.seq ].parent_entity_name = "VIEW_COMP_PREFS" ) )
   JOIN (p
   WHERE (p.view_comp_prefs_id = nvps->prefs[d.seq ].parent_entity_id )
   AND parser (levelparse ) )
   JOIN (v
   WHERE (v.view_name = outerjoin (p.view_name ) )
   AND (v.application_number = outerjoin (p.application_number ) )
   AND (v.position_cd = outerjoin (p.position_cd ) )
   AND (v.prsnl_id = outerjoin (p.prsnl_id ) )
   AND (v.view_seq = outerjoin (p.view_seq ) ) )
   JOIN (nvp
   WHERE (nvp.parent_entity_id = outerjoin (v.view_prefs_id ) )
   AND (nvp.pvc_name = outerjoin ("VIEW_CAPTION" ) ) )
  DETAIL
   tcnt = (tcnt + 1 ) ,
   stat = alterlist (temp->pref_list ,tcnt ) ,
   temp->pref_list[tcnt ].nvp_id = nvps->prefs[d.seq ].nvp_id ,
   temp->pref_list[tcnt ].pref_id = p.view_comp_prefs_id ,
   temp->pref_list[tcnt ].pvc_value = nvps->prefs[d.seq ].pvc_value ,
   temp->pref_list[tcnt ].application_number = p.application_number ,
   temp->pref_list[tcnt ].position_cd = p.position_cd ,
   temp->pref_list[tcnt ].person_id = p.prsnl_id ,
   temp->pref_list[tcnt ].pvc_name = nvps->prefs[d.seq ].pvc_name ,
   temp->pref_list[tcnt ].level = p.comp_name ,
   temp->pref_list[tcnt ].parent = build2 (trim (p.view_name ) ," | " ,trim (nvp.pvc_value ) )
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d WITH seq = nvpcnt ),
   (detail_prefs p ),
   (prsnl prsnl )
  PLAN (d
   WHERE (nvps->prefs[d.seq ].parent_entity_name = "DETAIL_PREFS" ) )
   JOIN (p
   WHERE (p.detail_prefs_id = nvps->prefs[d.seq ].parent_entity_id )
   AND parser (levelparse ) )
   JOIN (prsnl
   WHERE (prsnl.person_id = outerjoin (p.prsnl_id ) ) )
  ORDER BY d.seq ,
   p.position_cd ,
   p.prsnl_id
  HEAD d.seq
   tcnt = (tcnt + 1 ) ,stat = alterlist (temp->pref_list ,tcnt ) ,temp->pref_list[tcnt ].nvp_id =
   nvps->prefs[d.seq ].nvp_id ,temp->pref_list[tcnt ].pref_id = p.detail_prefs_id ,temp->pref_list[
   tcnt ].pvc_name = nvps->prefs[d.seq ].pvc_name ,temp->pref_list[tcnt ].pvc_value = nvps->prefs[d
   .seq ].pvc_value ,temp->pref_list[tcnt ].application_number = p.application_number ,
   IF ((prsnl.person_id > 0 ) ) temp->pref_list[tcnt ].position_cd = prsnl.position_cd
   ELSE temp->pref_list[tcnt ].position_cd = p.position_cd
   ENDIF
   ,temp->pref_list[tcnt ].person_id = p.prsnl_id ,temp->pref_list[tcnt ].level = p.comp_name ,temp->
   pref_list[tcnt ].parent = p.view_name ,temp->pref_list[tcnt ].search_detail_pref = 1
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d WITH seq = tcnt ),
   (detail_prefs prefs ),
   (view_prefs v ),
   (name_value_prefs nvp )
  PLAN (d
   WHERE (temp->pref_list[d.seq ].search_detail_pref = 1 )
   AND (temp->pref_list[d.seq ].person_id > 0 ) )
   JOIN (prefs
   WHERE (prefs.detail_prefs_id = temp->pref_list[d.seq ].pref_id ) )
   JOIN (v
   WHERE (v.view_name = prefs.view_name )
   AND (v.application_number = prefs.application_number )
   AND (v.position_cd = temp->pref_list[d.seq ].position_cd )
   AND (v.prsnl_id = prefs.prsnl_id )
   AND (v.view_seq = prefs.view_seq ) )
   JOIN (nvp
   WHERE (nvp.parent_entity_id = v.view_prefs_id )
   AND (nvp.pvc_name = "VIEW_CAPTION" ) )
  DETAIL
   temp->pref_list[d.seq ].search_detail_pref = 0 ,
   IF ((trim (nvp.pvc_value ) > " " ) ) temp->pref_list[d.seq ].parent = build2 (trim (prefs
      .view_name ) ," | " ,trim (nvp.pvc_value ) )
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d WITH seq = tcnt ),
   (detail_prefs prefs ),
   (view_prefs v ),
   (name_value_prefs nvp )
  PLAN (d
   WHERE (temp->pref_list[d.seq ].search_detail_pref = 1 )
   AND (temp->pref_list[d.seq ].position_cd > 0 ) )
   JOIN (prefs
   WHERE (prefs.detail_prefs_id = temp->pref_list[d.seq ].pref_id ) )
   JOIN (v
   WHERE (v.view_name = prefs.view_name )
   AND (v.application_number = prefs.application_number )
   AND (v.position_cd = temp->pref_list[d.seq ].position_cd )
   AND (v.prsnl_id = 0 )
   AND (v.view_seq = prefs.view_seq ) )
   JOIN (nvp
   WHERE (nvp.parent_entity_id = v.view_prefs_id )
   AND (nvp.pvc_name = "VIEW_CAPTION" ) )
  DETAIL
   temp->pref_list[d.seq ].search_detail_pref = 0 ,
   IF ((trim (nvp.pvc_value ) > " " ) ) temp->pref_list[d.seq ].parent = build2 (trim (prefs
      .view_name ) ," | " ,trim (nvp.pvc_value ) )
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d WITH seq = tcnt ),
   (detail_prefs prefs ),
   (view_prefs v ),
   (name_value_prefs nvp )
  PLAN (d
   WHERE (temp->pref_list[d.seq ].search_detail_pref = 1 ) )
   JOIN (prefs
   WHERE (prefs.detail_prefs_id = temp->pref_list[d.seq ].pref_id ) )
   JOIN (v
   WHERE (v.view_name = prefs.view_name )
   AND (v.application_number = prefs.application_number )
   AND (v.position_cd = 0 )
   AND (v.prsnl_id = 0 )
   AND (v.view_seq = prefs.view_seq ) )
   JOIN (nvp
   WHERE (nvp.parent_entity_id = v.view_prefs_id )
   AND (nvp.pvc_name = "VIEW_CAPTION" ) )
  DETAIL
   temp->pref_list[d.seq ].search_detail_pref = 0 ,
   IF ((trim (nvp.pvc_value ) > " " ) ) temp->pref_list[d.seq ].parent = build2 (trim (prefs
      .view_name ) ," | " ,trim (nvp.pvc_value ) )
   ENDIF
  WITH nocounter
 ;end select
 IF ((tcnt = 0 ) )
  GO TO exit_script
 ENDIF
 SELECT INTO "nl:"
  FROM (dummyt d WITH seq = tcnt ),
   (code_value position ),
   (prsnl person )
  PLAN (d
   WHERE (temp->pref_list[d.seq ].person_id > 0 ) )
   JOIN (person
   WHERE (person.person_id = temp->pref_list[d.seq ].person_id ) )
   JOIN (position
   WHERE (position.code_value = person.position_cd ) )
  DETAIL
   temp->pref_list[d.seq ].position_name = position.display ,
   temp->pref_list[d.seq ].position_active = position.active_ind ,
   temp->pref_list[d.seq ].person_name = person.name_full_formatted ,
   temp->pref_list[d.seq ].person_active = person.active_ind
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d WITH seq = tcnt ),
   (code_value position )
  PLAN (d
   WHERE (temp->pref_list[d.seq ].position_cd > 0 ) )
   JOIN (position
   WHERE (position.code_value = temp->pref_list[d.seq ].position_cd ) )
  DETAIL
   temp->pref_list[d.seq ].position_name = position.display ,
   temp->pref_list[d.seq ].position_active = position.active_ind
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d WITH seq = tcnt ),
   (br_name_value b ),
   (dummyt d2 )
  PLAN (d )
   JOIN (b
   WHERE (b.br_nv_key1 = "APPLICATION_NAME" ) )
   JOIN (d2
   WHERE (cnvtreal (trim (b.br_name ) ) = temp->pref_list[d.seq ].application_number ) )
  HEAD d.seq
   temp->pref_list[d.seq ].application_name = b.br_value ,
   IF ((temp->pref_list[d.seq ].level = "" ) ) temp->pref_list[d.seq ].level = b.br_value
   ENDIF
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (dummyt d WITH seq = tcnt ),
   (application a )
  PLAN (d
   WHERE (temp->pref_list[d.seq ].application_name = "" ) )
   JOIN (a
   WHERE (a.application_number = temp->pref_list[d.seq ].application_number ) )
  HEAD d.seq
   temp->pref_list[d.seq ].application_name = a.description ,
   IF ((temp->pref_list[d.seq ].level = "" ) ) temp->pref_list[d.seq ].level = a.description
   ENDIF
  WITH nocounter ,skipbedrock = 1
 ;end select
 SET total_col = 7
 SET stat = alterlist (reply->collist ,total_col )
 SET reply->collist[1 ].header_text = "Application"
 SET reply->collist[1 ].data_type = 1
 SET reply->collist[1 ].hide_ind = 0
 SET reply->collist[2 ].header_text = "Position"
 SET reply->collist[2 ].data_type = 1
 SET reply->collist[2 ].hide_ind = 0
 SET reply->collist[3 ].header_text = "Personnel"
 SET reply->collist[3 ].data_type = 1
 SET reply->collist[3 ].hide_ind = 0
 SET reply->collist[4 ].header_text = "PVC Name"
 SET reply->collist[4 ].data_type = 1
 SET reply->collist[4 ].hide_ind = 0
 SET reply->collist[5 ].header_text = "PVC Value"
 SET reply->collist[5 ].data_type = 1
 SET reply->collist[5 ].hide_ind = 0
 SET reply->collist[6 ].header_text = "Preference Level"
 SET reply->collist[6 ].data_type = 1
 SET reply->collist[6 ].hide_ind = 0
 SET reply->collist[7 ].header_text = "Parent Level"
 SET reply->collist[7 ].data_type = 1
 SET reply->collist[7 ].hide_ind = 0
 SET rowcnt = 0
 SELECT INTO "nl:"
  an = substring (0 ,32 ,temp->pref_list[d.seq ].application_name ) ,
  posn = substring (0 ,32 ,temp->pref_list[d.seq ].position_name ) ,
  pern = substring (0 ,32 ,temp->pref_list[d.seq ].person_name ) ,
  value = substring (0 ,128 ,temp->pref_list[d.seq ].person_name ) ,
  level = substring (0 ,64 ,temp->pref_list[d.seq ].person_name ) ,
  parent = substring (0 ,64 ,temp->pref_list[d.seq ].person_name )
  FROM (dummyt d WITH seq = tcnt )
  ORDER BY an ,
   posn ,
   pern ,
   value ,
   level ,
   parent
  DETAIL
   IF ((((temp->pref_list[d.seq ].position_cd IN (0 ,
   null ) ) ) OR ((temp->pref_list[d.seq ].position_active = 1 ) )) )
    IF ((((temp->pref_list[d.seq ].person_id IN (0 ,
    null ) ) ) OR ((temp->pref_list[d.seq ].person_active = 1 ) )) ) rowcnt = (rowcnt + 1 ) ,stat =
     alterlist (reply->rowlist ,rowcnt ) ,stat = alterlist (reply->rowlist[rowcnt ].celllist ,7 ) ,
     reply->rowlist[rowcnt ].celllist[1 ].string_value = temp->pref_list[d.seq ].application_name ,
     reply->rowlist[rowcnt ].celllist[2 ].string_value = temp->pref_list[d.seq ].position_name ,reply
     ->rowlist[rowcnt ].celllist[3 ].string_value = temp->pref_list[d.seq ].person_name ,reply->
     rowlist[rowcnt ].celllist[4 ].string_value = temp->pref_list[d.seq ].pvc_name ,reply->rowlist[
     rowcnt ].celllist[5 ].string_value = temp->pref_list[d.seq ].pvc_value ,reply->rowlist[rowcnt ].
     celllist[6 ].string_value = temp->pref_list[d.seq ].level ,reply->rowlist[rowcnt ].celllist[7 ].
     string_value = temp->pref_list[d.seq ].parent
    ENDIF
   ENDIF
  WITH nocounter
 ;end select
 IF ((request->skip_volume_check_ind = 0 ) )
  CALL echo (build ("Row_cnt: " ,rowcnt ) )
  IF ((rowcnt > 30000 ) )
   SET reply->high_volume_flag = 2
   SET stat = alterlist (reply->rowlist ,0 )
   GO TO exit_script
  ELSEIF ((rowcnt > 20000 ) )
   SET reply->high_volume_flag = 1
   SET stat = alterlist (reply->rowlist ,0 )
   GO TO exit_script
  ENDIF
 ENDIF
#exit_script
 SET reply->status_data.status = "S"
 IF ((reply->high_volume_flag IN (1 ,
 2 ) ) )
  SET reply->output_filename = build ("pref_maint_audit.csv" )
 ENDIF
 IF ((request->output_filename > " " ) )
  EXECUTE bed_rpt_file
 ENDIF
END GO

