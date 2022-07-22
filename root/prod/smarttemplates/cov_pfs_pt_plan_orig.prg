DROP PROGRAM cov_pfs_pt_plan_orig :dba GO
CREATE PROGRAM cov_pfs_pt_plan_orig :dba
 SET rhead = concat ("{\rtf1\ansi \deff0{\fonttbl{\f0\fswiss MS Sans Serif;}" ,
  "}{\colortbl;\red0\green0\blue0;\red255\green255\blue255;}\deftab1134" )
 SET reol = "\par "
 SET rtab = "\tab "
 SET wr = "\plain \f0 \fs18 \cb2 "
 SET wb = "\plain \f0 \fs18 \b \cb2 "
 SET hi = "\pard\fi-2340\li2340 "
 SET rtfeof = "}"
 DECLARE auth = f8 WITH constant (uar_get_code_by ("MEANING" ,8 ,"AUTH" ) ) ,protect
 DECLARE modified = f8 WITH constant (uar_get_code_by ("MEANING" ,8 ,"MODIFIED" ) ) ,protect
 DECLARE altered = f8 WITH constant (uar_get_code_by ("MEANING" ,8 ,"ALTERED" ) ) ,protect
 DECLARE ocfcomp = f8 WITH constant (uar_get_code_by ("MEANING" ,120 ,"OCFCOMP" ) ) ,protect
 DECLARE frequency = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!7645" ) )
 DECLARE duration = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!7644" ) )
 DECLARE treatment = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!7641" ) )
 DECLARE frequency_new = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!14300" ) )
 DECLARE duration_new = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!14301" ) )
 DECLARE treatment_new = f8 WITH public ,constant (uar_get_code_by_cki ("CKI.EC!14302" ) )
 DECLARE freq = f8 WITH public ,constant (1.00 )
 DECLARE dur = f8 WITH public ,constant (2.00 )
 DECLARE treat = f8 WITH public ,constant (3.00 )
 DECLARE freq_disp = vc WITH public ,noconstant (" " )
 DECLARE dur_disp = vc WITH public ,noconstant (" " )
 DECLARE treat_disp = vc WITH public ,noconstant (" " )
 DECLARE dpersonid = f8 WITH noconstant (0.0 )
 SELECT INTO "NL:"
  e.person_id
  FROM (encounter e )
  WHERE (e.encntr_id = request->visit[1 ].encntr_id )
  AND (e.active_ind = 1 )
  AND (e.end_effective_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
  DETAIL
   dpersonid = e.person_id
  WITH nocounter
 ;end select
 SELECT INTO "nl:"
  prfm_dt_tm = trim (format (cnvtdatetime (ce.event_end_dt_tm ) ,cclfmt->shortdatetime ) ) ,
  units = uar_get_code_display (ce.result_units_cd ) ,
  ce_event_cd =
  IF ((ce.event_cd IN (frequency ,
  frequency_new ) ) ) freq
  ELSEIF ((ce.event_cd IN (duration ,
  duration_new ) ) ) dur
  ELSEIF ((ce.event_cd IN (treatment ,
  treatment_new ) ) ) treat
  ENDIF
  FROM (clinical_event ce ),
   (prsnl p )
  PLAN (ce
   WHERE (ce.person_id = dpersonid )
   AND ((ce.encntr_id + 0 ) = request->visit[1 ].encntr_id )
   AND (ce.event_cd IN (frequency ,
   duration ,
   treatment ,
   frequency_new ,
   duration_new ,
   treatment_new ) )
   AND ((ce.result_status_cd + 0 ) IN (auth ,
   modified ,
   altered ) )
   AND (ce.event_tag != "Date\Time Correction" )
   AND (ce.valid_until_dt_tm > cnvtdatetime (curdate ,curtime3 ) )
   AND (ce.event_end_dt_tm >= cnvtdatetime ((curdate - 42 ) ,curtime3 ) ) )
   JOIN (p
   WHERE (p.person_id = ce.verified_prsnl_id ) )
  ORDER BY ce_event_cd ,
   ce.event_end_dt_tm DESC
  HEAD ce_event_cd
   CASE (ce_event_cd )
    OF freq :
     IF ((ce.result_status_cd IN (modified ,
     altered ) ) ) freq_disp = concat (wb ,"Treatment Frequency:  " ,wr ,trim (ce.result_val ) ,
       " (modified)  " ,wb ," Performed By: " ,wr ,trim (p.name_full_formatted ) ,"  " ,concat (trim
        (format (cnvtdatetime (ce.event_end_dt_tm ) ,"@SHORTDATE4YR" ) ) ," " ,trim (format (
          cnvtdatetime (ce.event_end_dt_tm ) ,"@TIMENOSECONDS" ) ) ) )
     ELSE freq_disp = concat (wb ,"Treatment Frequency:  " ,wr ,trim (ce.result_val ) ,
       " (modified)  " ,wb ," Performed By: " ,wr ,trim (p.name_full_formatted ) ,"  " ,concat (trim
        (format (cnvtdatetime (ce.event_end_dt_tm ) ,"@SHORTDATE4YR" ) ) ," " ,trim (format (
          cnvtdatetime (ce.event_end_dt_tm ) ,"@TIMENOSECONDS" ) ) ) )
     ENDIF
     ,
     CALL echo (build ("value of FREQ field" ,freq_disp ) )
    OF dur :
     IF ((ce.result_status_cd IN (modified ,
     altered ) ) ) dur_disp = concat (wb ,"Treatment Duration:  " ,wr ,trim (ce.result_val ) ,
       " (modified)  " ,wb ," Performed By: " ,wr ,trim (p.name_full_formatted ) ,"  " ,concat (trim
        (format (cnvtdatetime (ce.event_end_dt_tm ) ,"@SHORTDATE4YR" ) ) ," " ,trim (format (
          cnvtdatetime (ce.event_end_dt_tm ) ,"@TIMENOSECONDS" ) ) ) )
     ELSE dur_disp = concat (wb ,"Treatment Duration: " ,wr ,trim (ce.result_val ) ,wb ,
       " Performed By: " ,wr ,trim (p.name_full_formatted ) ,"  " ,concat (trim (format (
          cnvtdatetime (ce.event_end_dt_tm ) ,"@SHORTDATE4YR" ) ) ," " ,trim (format (cnvtdatetime (
           ce.event_end_dt_tm ) ,"@TIMENOSECONDS" ) ) ) )
     ENDIF
     ,
     CALL echo (build ("value of DT field DUR" ,dur_disp ) )
    OF treat :
     IF ((ce.result_status_cd IN (modified ,
     altered ) ) ) treat_disp = concat (wb ,"Planned Treatments:  " ,wr ,trim (ce.result_val ) ,
       " (modified)  " ,wb ," Performed By: " ,wr ,trim (p.name_full_formatted ) ,"  " ,concat (trim
        (format (cnvtdatetime (ce.event_end_dt_tm ) ,"@SHORTDATE4YR" ) ) ," " ,trim (format (
          cnvtdatetime (ce.event_end_dt_tm ) ,"@TIMENOSECONDS" ) ) ) )
     ELSE treat_disp = concat (wb ,"Planned Treatments: " ,wr ,trim (ce.result_val ) ,wb ,
       " Performed By: " ,wr ,trim (p.name_full_formatted ) ,"  " ,concat (trim (format (
          cnvtdatetime (ce.event_end_dt_tm ) ,"@SHORTDATE4YR" ) ) ," " ,trim (format (cnvtdatetime (
           ce.event_end_dt_tm ) ,"@TIMENOSECONDS" ) ) ) )
     ENDIF
     ,
     CALL echo (build ("value of DT field TREAT" ,treat_disp ) )
   ENDCASE
  WITH nocounter
 ;end select
 IF ((curqual = 0 ) )
  SET reply->text = concat (reply->text ,rhead ,wr ,"No qualifying data available" ,reol )
  GO TO exit_script
 ENDIF
 SET reply->text = concat (reply->text ,rhead )
 IF ((freq_disp > " " ) )
  SET reply->text = concat (reply->text ,freq_disp ,reol )
 ENDIF
 IF ((dur_disp > " " ) )
  SET reply->text = concat (reply->text ,dur_disp ,reol )
 ENDIF
 IF ((treat_disp > " " ) )
  SET reply->text = concat (reply->text ,treat_disp ,reol )
 ENDIF
#exit_script
 SET reply->text = concat (reply->text ,rtfeof )
 SET script_version = "010 04/27/2012 LB015443"
END GO
