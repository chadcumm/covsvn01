DROP PROGRAM cov_oar_order_notif_cleanup :dba GO
CREATE PROGRAM cov_oar_order_notif_cleanup :dba
 DECLARE program_version = vc WITH private ,constant ("001" )
 SET modify = predeclare
 DECLARE tracerbegin ((programname = vc ) ,(version = vc ) ) = null
 SUBROUTINE  tracerbegin (programname ,version )
  CALL echo ("BEGIN" ,0 )
  CALL printnameversion (programname ,version )
 END ;Subroutine
 DECLARE tracerend ((programname = vc ) ,(version = vc ) ) = null
 SUBROUTINE  tracerend (programname ,version )
  CALL echo ("END" ,0 )
  CALL printnameversion (programname ,version )
 END ;Subroutine
 DECLARE printnameversion ((programname = vc ) ,(version = vc ) ) = null
 SUBROUTINE  printnameversion (programname ,version )
  CALL echo (build (" [" ,programname ,"]" ) ,0 )
  CALL echo (" v" ,0 )
  CALL echo (version ,0 )
  CALL echo (" @" ,0 )
  CALL echo (format (cnvtdatetime (curdate ,curtime3 ) ,";;q" ) )
 END ;Subroutine
 DECLARE checkerrors ((programname = vc ) ) = i1
 SUBROUTINE  checkerrors (programname )
  DECLARE errormessage = vc WITH private ,noconstant ("" )
  DECLARE numberoferrors = i4 WITH private ,noconstant (0 )
  DECLARE errorcode = i1 WITH private ,noconstant (error (errormessage ,0 ) )
  IF ((errorcode > 0 ) )
   CALL echo ("" )
   CALL echo (build ("Errors encountered while running program [" ,programname ,"]" ) )
   SET reply->status_data.status = "F"
   WHILE ((errorcode != 0 )
   AND (numberoferrors < 20 ) )
    SET numberoferrors = (numberoferrors + 1 )
    CALL echo (errormessage )
    CALL addsubeventstatus (programname ,"F" ,"CCL ERROR" ,errormessage )
    SET errorcode = error (errormessage ,0 )
   ENDWHILE
  ENDIF
  IF ((numberoferrors > 0 ) )
   RETURN (true )
  ELSE
   RETURN (false )
  ENDIF
 END ;Subroutine
 DECLARE addsubeventstatus ((operationname = vc ) ,(operationstatus = c1 ) ,(targetobjectname = vc )
  ,(targetobjectvalue = vc ) ) = null
 SUBROUTINE  addsubeventstatus (operationname ,operationstatus ,targetobjectname ,targetobjectvalue )
  DECLARE stataddsubevent = i4 WITH private ,noconstant (0 )
  DECLARE subeventstatussize = i4 WITH private ,noconstant (size (reply->status_data.subeventstatus ,
    5 ) )
  IF ((((size (trim (reply->status_data.subeventstatus[subeventstatussize ].operationname ) ,1 ) > 0
  ) ) OR ((((size (trim (reply->status_data.subeventstatus[subeventstatussize ].operationstatus ) ,1
   ) > 0 ) ) OR ((((size (trim (reply->status_data.subeventstatus[subeventstatussize ].
    targetobjectname ) ,1 ) > 0 ) ) OR ((size (trim (reply->status_data.subeventstatus[
    subeventstatussize ].targetobjectvalue ) ,1 ) > 0 ) )) )) )) )
   SET subeventstatussize = (subeventstatussize + 1 )
   SET stataddsubevent = alter (reply->status_data.subeventstatus ,subeventstatussize )
  ENDIF
  SET reply->status_data.subeventstatus[subeventstatussize ].operationname = substring (0 ,25 ,
   operationname )
  SET reply->status_data.subeventstatus[subeventstatussize ].operationstatus = operationstatus
  SET reply->status_data.subeventstatus[subeventstatussize ].targetobjectname = substring (0 ,25 ,
   targetobjectname )
  SET reply->status_data.subeventstatus[subeventstatussize ].targetobjectvalue = targetobjectvalue
 END ;Subroutine
 CALL tracerbegin ("oar_cosign_order_notif_cleanup" ,program_version )
 DECLARE echo_error_and_exit_script ((error_message = vc ) ) = null WITH protect
 DECLARE delete_tracking_record_from_dm_info ((dummypara = null ) ) = null WITH protect
 DECLARE is_rollback_segment_error ((error_msg = vc ) ) = i2 WITH protect
 DECLARE cleanup_mode_default = i2 WITH protect ,constant (1 )
 DECLARE cleanup_mode_range = i2 WITH protect ,constant (2 )
 DECLARE cleanup_mode_personnel = i2 WITH protect ,constant (3 )
 DECLARE notification_status_pending = i2 WITH protect ,constant (1 )
 DECLARE notification_status_no_longer_needed = i2 WITH protect ,constant (6 )
 DECLARE notification_type_cosign = i2 WITH protect ,constant (2 )
 DECLARE running_mode = i2 WITH protect ,noconstant (cleanup_mode_default )
 DECLARE target_prsnl_id = f8 WITH protect ,noconstant (0.0 )
 DECLARE first_parameter = f8 WITH protect ,noconstant (0.0 )
 DECLARE second_parameter = f8 WITH protect ,noconstant (0.0 )
 DECLARE max_order_notification_id = f8 WITH protect ,noconstant (0.0 )
 DECLARE min_order_notification_id = f8 WITH protect ,noconstant (0.0 )
 IF ((reflect (parameter (1 ,0 ) ) > " " ) )
  SET first_parameter = cnvtreal (parameter (1 ,0 ) )
  IF ((first_parameter < 1.0 ) )
   CALL echo_error_and_exit_script ("All parameter(s) must be greater than 0." )
  ENDIF
 ENDIF
 IF ((reflect (parameter (2 ,0 ) ) > " " ) )
  SET second_parameter = cnvtreal (parameter (2 ,0 ) )
  IF ((second_parameter < 1.0 ) )
   CALL echo_error_and_exit_script ("All parameter(s) must be greater than 0." )
  ENDIF
 ENDIF
 IF ((first_parameter >= 1.0 )
 AND (second_parameter >= 1.0 ) )
  SET running_mode = cleanup_mode_range
  SET target_prsnl_id = 0.0
  IF ((first_parameter > second_parameter ) )
   CALL echo_error_and_exit_script ("Min notification cannot be greater than max notification id." )
  ENDIF
  SET min_order_notification_id = first_parameter
  SET max_order_notification_id = second_parameter
 ELSEIF ((first_parameter >= 1.0 ) )
  SET running_mode = cleanup_mode_personnel
  SET target_prsnl_id = first_parameter
 ENDIF
 IF ((((running_mode = cleanup_mode_default ) ) OR ((running_mode = cleanup_mode_personnel ) )) )
  SELECT INTO "NL:"
   min_val = min (ordn.order_notification_id )
   FROM (order_notification ordn )
   WHERE (ordn.to_prsnl_id = target_prsnl_id )
   AND (ordn.notification_type_flag = notification_type_cosign )
   AND (ordn.notification_status_flag = notification_status_pending )
   AND ((ordn.to_prsnl_group_id + 0.0 ) = 0.0 )
   AND ((ordn.order_notification_id + 0.0 ) > 0.0 )
   DETAIL
    min_order_notification_id = min_val
   WITH nocounter
  ;end select
  IF ((min_order_notification_id < 1.0 ) )
   CALL echo (
    "No qualified pending cosign notification exists on table: ORDER_NOTIFICATION. Cleanup finished."
    )
   GO TO exit_script
  ENDIF
  SELECT INTO "NL:"
   max_val = max (ordn.order_notification_id )
   FROM (order_notification ordn )
   WHERE (ordn.to_prsnl_id = target_prsnl_id )
   AND (ordn.notification_type_flag = notification_type_cosign )
   AND (ordn.notification_status_flag = notification_status_pending )
   AND ((ordn.to_prsnl_group_id + 0.0 ) = 0.0 )
   AND ((ordn.order_notification_id + 0.0 ) > 0.0 )
   DETAIL
    max_order_notification_id = max_val
   WITH nocounter
  ;end select
 ENDIF
 DECLARE dm_info_domain_name = vc WITH protect ,constant ("NEXUS_ORDERS" )
 DECLARE dm_info_name = vc WITH protect ,constant ("OAR_COSIGN_ORDER_NOTIF_CLEANUP_DEFAULT_MODE" )
 IF ((running_mode = cleanup_mode_default ) )
  DECLARE dm_max_notification_id = f8 WITH protect ,noconstant (0.0 )
  SELECT INTO "NL:"
   dm.info_number
   FROM (dm_info dm )
   WHERE (dm.info_domain = dm_info_domain_name )
   AND (dm.info_name = dm_info_name )
   DETAIL
    dm_max_notification_id = dm.info_number
   WITH nocounter
  ;end select
  IF ((curqual = 0 ) )
   INSERT FROM (dm_info dm )
    SET dm.info_domain = dm_info_domain_name ,
     dm.info_name = dm_info_name ,
     dm.info_number = max_order_notification_id ,
     dm.updt_id = reqinfo->updt_id ,
     dm.updt_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
     dm.updt_cnt = 0 ,
     dm.updt_task = reqinfo->updt_task ,
     dm.updt_applctx = reqinfo->updt_applctx
    WITH nocounter
   ;end insert
  ELSE
   IF ((dm_max_notification_id < min_order_notification_id ) )
    CALL delete_tracking_record_from_dm_info (null )
    CALL echo (
     "The tracked progress on dm_info is corrupted, need to re-run this script to recalculate the clean-up range"
     )
    GO TO exit_script
   ELSE
    SET max_order_notification_id = dm_max_notification_id
    CALL echo (
     "There is a tracking record on dm_info, the script will use the record as start point of clean-up operation"
     )
   ENDIF
  ENDIF
 ENDIF
 DECLARE range_recalculated_ind = i2 WITH protect ,noconstant (0 )
 DECLARE batch_size = f8 WITH protect ,noconstant (200000.0 )
 DECLARE max_range_notification_id = f8 WITH protect ,noconstant (max_order_notification_id )
 DECLARE min_range_notification_id = f8 WITH protect ,noconstant ((max_order_notification_id -
  batch_size ) )
 DECLARE batch_size_recalculated = i2 WITH protect ,constant (1 )
 DECLARE batch_size_not_change = i2 WITH protect ,constant (0 )
 IF ((min_range_notification_id < min_order_notification_id ) )
  SET min_range_notification_id = min_order_notification_id
 ENDIF
 DECLARE cleanup_workload = f8 WITH protect ,constant (((max_order_notification_id -
  min_order_notification_id ) + 1.0 ) )
 DECLARE cleanup_progress = i4 WITH protect ,noconstant (0 )
 WHILE ((max_range_notification_id >= min_order_notification_id ) )
 call echo(build2("max_range_notification_id = ",max_range_notification_id))
  call echo(build2("min_order_notification_id = ",min_order_notification_id))
  UPDATE FROM (order_notification ordn )
   SET ordn.notification_status_flag = notification_status_no_longer_needed ,
    ordn.updt_id = reqinfo->updt_id ,
    ordn.updt_cnt = (ordn.updt_cnt + 1 ) ,
    ordn.updt_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
    ordn.updt_task = reqinfo->updt_task ,
    ordn.updt_applctx = reqinfo->updt_applctx
   WHERE (ordn.order_notification_id >= min_range_notification_id )
   AND (ordn.order_notification_id <= max_range_notification_id )
   ;removed requirement for to_prsnl_id AND ((ordn.to_prsnl_id + 0.0 ) = target_prsnl_id )
   AND ((ordn.notification_type_flag + 0 ) = notification_type_cosign )
   AND ((ordn.notification_status_flag + 0 ) = notification_status_pending )
   AND ((ordn.to_prsnl_group_id + 0.0 ) = 0.0 )
   WITH nocounter
  ;end update
  DECLARE error_msg_updt_order_notification = c132 WITH protect ,noconstant ("" )
  IF ((error (error_msg_updt_order_notification ,0 ) != 0 ) )
   ROLLBACK
   IF ((is_rollback_segment_error (error_msg_updt_order_notification ) = 1 ) )
    IF ((batch_size > 2000 ) )
     SET batch_size = ceil ((batch_size / 2 ) )
     SET range_recalculated_ind = batch_size_recalculated
    ELSE
     CALL echo_error_and_exit_script (
      "Update failed because cannot recover from rollback segment error." )
    ENDIF
   ELSE
    CALL echo_error_and_exit_script ("Update failed because of database or system error." )
   ENDIF
  ENDIF
  IF ((range_recalculated_ind = batch_size_recalculated ) )
   SET min_range_notification_id = (max_range_notification_id - batch_size )
   SET range_recalculated_ind = batch_size_not_change
  ELSE
   SET max_range_notification_id = (min_range_notification_id - 1 )
   SET min_range_notification_id = (max_range_notification_id - batch_size )
   SET cleanup_progress = (((max_order_notification_id - max_range_notification_id ) /
   cleanup_workload ) * 100 )
   CALL echo (concat (build ("-> Processed " ,cleanup_progress ) ,
     "% of qualified doctor cosign notifications" ) )
   IF ((running_mode = cleanup_mode_default ) )
    UPDATE FROM (dm_info dm )
     SET dm.info_number = max_range_notification_id ,
      dm.updt_id = reqinfo->updt_id ,
      dm.updt_dt_tm = cnvtdatetime (curdate ,curtime3 ) ,
      dm.updt_cnt = (dm.updt_cnt + 1 ) ,
      dm.updt_task = reqinfo->updt_task ,
      dm.updt_applctx = reqinfo->updt_applctx
     WHERE (dm.info_domain = dm_info_domain_name )
     AND (dm.info_name = dm_info_name )
    ;end update
    DECLARE error_msg_updt_dm_info = c132 WITH protect ,noconstant ("" )
    IF ((error (error_msg_updt_dm_info ,0 ) != 0 ) )
     CALL echo_error_and_exit_script ("Update tracking information failed on table: DM_INFO." )
    ENDIF
   ENDIF
   COMMIT
  ENDIF
 ENDWHILE
 IF ((running_mode = cleanup_mode_default ) )
  CALL delete_tracking_record_from_dm_info (null )
 ENDIF
 SUBROUTINE  delete_tracking_record_from_dm_info (dummypara )
  DELETE FROM (dm_info dm )
   WHERE (dm.info_domain = dm_info_domain_name )
   AND (dm.info_name = dm_info_name )
  ;end delete
  COMMIT
 END ;Subroutine
 SUBROUTINE  echo_error_and_exit_script (error_message )
  CALL echo (build ("-> Exit script due to: " ,error_message ) )
  GO TO exit_script
 END ;Subroutine
 SUBROUTINE  is_rollback_segment_error (error_msg )
  IF ((((findstring ("ORA-01555" ,error_msg ) != 0 ) ) OR ((((findstring ("ORA-01650" ,error_msg )
  != 0 ) ) OR ((((findstring ("ORA-01562" ,error_msg ) != 0 ) ) OR ((((findstring ("ORA-30036" ,
   error_msg ) != 0 ) ) OR ((((findstring ("ORA-30027" ,error_msg ) != 0 ) ) OR ((findstring (
   "ORA-01581" ,error_msg ) != 0 ) )) )) )) )) )) )
   RETURN (1 )
  ENDIF
  RETURN (0 )
 END ;Subroutine
 CALL echo ("Cleanup finished, now exiting script" )
#exit_script
END GO
