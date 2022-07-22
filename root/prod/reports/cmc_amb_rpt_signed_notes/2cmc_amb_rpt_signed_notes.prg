DROP PROGRAM cmc_amb_rpt_signed_notes :dba GO
CREATE PROGRAM cmc_amb_rpt_signed_notes :dba
 PROMPT
  "Output to File/Printer/MINE" = "MINE" ,
  "Start Date" = "SYSDATE" ,
  "End Date" = "SYSDATE" ,
  "Position" = 0 ,
  "Provider" = 0
  WITH outdev ,start_datetime ,end_datetime ,prsnl_position ,provider
 DECLARE op_provider_var = vc WITH noconstant (" " )
 DECLARE num = i4 WITH noconstant (0 )
 DECLARE cnt = i4 WITH noconstant (0 )
 DECLARE anesthesia_var = f8 WITH constant (uar_get_code_by ("DISPLAY" ,29520 ,"Anesthesia" ) ) ,
 protect
 DECLARE cardiology_var = f8 WITH constant (uar_get_code_by ("DISPLAY" ,29520 ,"Cardiology" ) ) ,
 protect
 DECLARE dyn_doc_var = f8 WITH constant (uar_get_code_by ("DISPLAY" ,29520 ,"Dynamic Documentation"
   ) ) ,protect
 DECLARE msg_center_var = f8 WITH constant (uar_get_code_by ("DISPLAY" ,29520 ,"Message Center" ) ) ,
 protect
 DECLARE powernote_var = f8 WITH constant (uar_get_code_by ("DISPLAY" ,29520 ,"PowerNote" ) ) ,
 protect
 DECLARE ed_powernote_var = f8 WITH constant (uar_get_code_by ("DISPLAY" ,29520 ,"PowerNote ED" ) ) ,
 protect
 DECLARE esi_var = f8 WITH constant (uar_get_code_by ("DISPLAY" ,29520 ,"ESI" ) ) ,protect
 IF ((substring (1 ,1 ,reflect (parameter (parameter2 ( $PROVIDER ) ,0 ) ) ) = "L" ) )
  SET op_provider_var = "IN"
 ELSEIF ((parameter (parameter2 ( $PROVIDER ) ,1 ) = 0.0 ) )
  SET op_provider_var = "!="
 ELSE
  SET op_provider_var = "="
 ENDIF
 RECORD note (
   1 note_cnt = i4
   1 list [* ]
     2 fin = vc
     2 patient_name = vc
     2 personid = f8
     2 encntrid = f8
     2 facility = vc
     2 reg_dt = vc
     2 note_type = vc
     2 result_status = vc
     2 result_dt = vc
     2 performed_dt = vc
     2 verified_dt = vc
     2 note_template = vc
     2 signed_by = vc
     2 signed_by_position = vc
     2 performed_pr_id = f8
     2 verified_pr_id = f8
     2 performed_pr_name = vc
     2 verified_pr_name = vc
 )
 SELECT INTO  $OUTDEV
  ce.encntr_id ,
  note_typ = trim (uar_get_code_display (ce.event_cd ) ) ,
  result_stat = trim (uar_get_code_display (ce.result_status_cd ) ) ,
  resul_dt = ce.event_end_dt_tm "@SHORTDATETIME" ,
  sign_by = trim (pr.name_full_formatted ) ,
  peform_dt = ce.performed_dt_tm "@SHORTDATETIME" ,
  verifi_dt = ce.verified_dt_tm "@SHORTDATETIME" ,
  note_temp = trim (uar_get_code_display (ce.entry_mode_cd ) ) ,
  signed_by_pos = trim (uar_get_code_display (pr.position_cd ) )
  FROM (clinical_event ce ),
   (ce_event_prsnl cep ),
   (prsnl pr ),
   (prsnl pr1 ),
   (prsnl pr2 )
  PLAN (ce
   WHERE (ce.event_end_dt_tm BETWEEN cnvtdatetime ( $START_DATETIME ) AND cnvtdatetime (
     $END_DATETIME ) )
   AND (ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" ) )
   AND (ce.entry_mode_cd IN (anesthesia_var ,
   cardiology_var ,
   dyn_doc_var ,
   msg_center_var ,
   powernote_var ,
   ed_powernote_var ) ) )
   JOIN (cep
   WHERE (cep.event_id = ce.event_id )
   AND operator (cep.action_prsnl_id ,op_provider_var , $PROVIDER )
   AND (cep.action_type_cd = 107.00 )
   AND (cep.action_status_cd = 653.00 ) )
   JOIN (pr
   WHERE (pr.person_id = cep.action_prsnl_id )
   AND (pr.active_ind = 1 )
   AND (pr.position_cd =  $PRSNL_POSITION ) )
   JOIN (pr1
   WHERE (pr1.person_id = Outerjoin(ce.performed_prsnl_id ))
   AND (pr1.active_ind = Outerjoin(1 )) )
   JOIN (pr2
   WHERE (pr2.person_id = Outerjoin(ce.verified_prsnl_id ))
   AND (pr1.active_ind = Outerjoin(1 )) )
  ORDER BY ce.person_id ,
   ce.encntr_id ,
   ce.event_id
  HEAD REPORT
   cnt = 0
  HEAD ce.event_id
   cnt +=1 ,
   CALL alterlist (note->list ,cnt ) ,note->note_cnt = cnt
  DETAIL
   note->list[cnt ].personid = ce.person_id ,
   note->list[cnt ].encntrid = ce.encntr_id ,
   note->list[cnt ].note_template = note_temp ,
   note->list[cnt ].note_type = note_typ ,
   note->list[cnt ].performed_dt = format (ce.performed_dt_tm ,"mm/dd/yyyy hh:mm:ss;;d" ) ,
   note->list[cnt ].performed_pr_id = ce.performed_prsnl_id ,
   note->list[cnt ].result_dt = format (ce.event_end_dt_tm ,"mm/dd/yyyy hh:mm:ss;;d" ) ,
   note->list[cnt ].result_status = result_stat ,
   note->list[cnt ].signed_by = sign_by ,
   note->list[cnt ].signed_by_position = signed_by_pos ,
   note->list[cnt ].verified_dt = format (ce.verified_dt_tm ,"mm/dd/yyyy hh:mm:ss;;d" ) ,
   note->list[cnt ].verified_pr_id = ce.verified_prsnl_id ,
   note->list[cnt ].performed_pr_name = trim (pr1.name_full_formatted ) ,
   note->list[cnt ].verified_pr_name = trim (pr2.name_full_formatted )
  WITH nocounter
 ;end select
 SELECT INTO  $OUTDEV
  ce.encntr_id ,
  note_typ = trim (uar_get_code_display (ce.event_cd ) ) ,
  ce.event_id ,
  result_stat = trim (uar_get_code_display (ce.result_status_cd ) ) ,
  ce.view_level ,
  ce.result_status_cd ,
  resul_dt = ce.event_end_dt_tm "@SHORTDATETIME" ,
  peform_dt = ce.performed_dt_tm "@SHORTDATETIME" ,
  ce.performed_prsnl_id ,
  note_temp = trim (uar_get_code_display (ce.entry_mode_cd ) ) ,
  ce.contributor_system_cd ,
  sign_by = trim (pr.name_full_formatted ) ,
  signed_by_pos = trim (uar_get_code_display (pr.position_cd ) )
  FROM (clinical_event ce ),
   (prsnl pr )
  PLAN (ce
   WHERE (ce.event_end_dt_tm BETWEEN cnvtdatetime ( $START_DATETIME ) AND cnvtdatetime (
     $END_DATETIME ) )
   AND (ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" ) )
   AND (ce.view_level = 1 )
   AND (ce.entry_mode_cd = esi_var )
   AND (ce.contributor_system_cd = 3854142281.00 )
   AND operator (ce.performed_prsnl_id ,op_provider_var , $PROVIDER ) )
   JOIN (pr
   WHERE (pr.person_id = ce.performed_prsnl_id )
   AND (pr.active_ind = 1 )
   AND (pr.position_cd =  $PRSNL_POSITION ) )
  ORDER BY ce.person_id ,
   ce.encntr_id ,
   ce.event_id
  HEAD ce.event_id
   cnt +=1 ,
   CALL alterlist (note->list ,cnt ) ,note->note_cnt = cnt
  DETAIL
   note->list[cnt ].personid = ce.person_id ,
   note->list[cnt ].encntrid = ce.encntr_id ,
   note->list[cnt ].note_template = note_temp ,
   note->list[cnt ].note_type = note_typ ,
   note->list[cnt ].performed_dt = format (ce.performed_dt_tm ,"mm/dd/yyyy hh:mm:ss;;d" ) ,
   note->list[cnt ].performed_pr_id = ce.performed_prsnl_id ,
   note->list[cnt ].result_dt = format (ce.event_end_dt_tm ,"mm/dd/yyyy hh:mm:ss;;d" ) ,
   note->list[cnt ].result_status = result_stat ,
   note->list[cnt ].signed_by = sign_by ,
   note->list[cnt ].signed_by_position = signed_by_pos ,
   note->list[cnt ].performed_pr_name = trim (pr.name_full_formatted )
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  FROM (encounter e ),
   (encntr_alias ea ),
   (person p )
  PLAN (e
   WHERE expand (num ,1 ,note->note_cnt ,e.encntr_id ,note->list[num ].encntrid )
   AND (e.active_ind = 1 ) )
   JOIN (ea
   WHERE (ea.encntr_id = e.encntr_id )
   AND (ea.active_ind = 1 ) )
   JOIN (p
   WHERE (p.person_id = e.person_id )
   AND (p.active_ind = 1 ) )
  ORDER BY e.encntr_id
  HEAD e.encntr_id
   loc = 0 ,edx = 0 ,edx = locateval (loc ,1 ,note->note_cnt ,e.encntr_id ,note->list[loc ].encntrid
    ) ,
   WHILE ((edx > 0 ) )
   note->list[edx].facility = uar_get_code_display(e.loc_facility_cd),
    note->list[edx ].fin = trim (ea.alias ) ,note->list[edx ].patient_name = trim (p
     .name_full_formatted ) ,note->list[edx ].reg_dt = format (e.reg_dt_tm ,"mm/dd/yyyy hh:mm:ss;;d"
     ) ,edx = locateval (loc ,(edx + 1 ) ,note->note_cnt ,e.encntr_id ,note->list[loc ].encntrid )
   ENDWHILE
  WITH nocounter ,expand = 1
 ;end select
 SELECT INTO  $OUTDEV
 facility = trim(substring(1, 50, note->list[d1.seq].facility)),
  fin = trim (substring (1 ,30 ,note->list[d1.seq ].fin ) ) ,
  patient_name = trim (substring (1 ,50 ,note->list[d1.seq ].patient_name ) ) ,
  registration_dt = trim (substring (1 ,30 ,note->list[d1.seq ].reg_dt ) ) ,
  note_type = trim (substring (1 ,100 ,note->list[d1.seq ].note_type ) ) ,
  result_status = trim (substring (1 ,30 ,note->list[d1.seq ].result_status ) ) ,
  signed_by = trim (substring (1 ,50 ,note->list[d1.seq ].signed_by ) ) ,
  result_dt = trim (substring (1 ,30 ,note->list[d1.seq ].result_dt ) ) ,
  performed_by = trim (substring (1 ,50 ,note->list[d1.seq ].performed_pr_name ) ) ,
  performed_dt = trim (substring (1 ,30 ,note->list[d1.seq ].performed_dt ) ) ,
  verified_by = trim (substring (1 ,50 ,note->list[d1.seq ].verified_pr_name ) ) ,
  verified_dt = trim (substring (1 ,30 ,note->list[d1.seq ].verified_dt ) ) ,
  note_template = trim (substring (1 ,100 ,note->list[d1.seq ].note_template ) ) ,
  signed_by_position = trim (substring (1 ,100 ,note->list[d1.seq ].signed_by_position ) )
  FROM (dummyt d1 WITH seq = size (note->list ,5 ) )
  PLAN (d1 )
  ORDER BY fin ,
   result_dt
  with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,maxcol=32000,format
 ;end select
#exitscript
END GO
