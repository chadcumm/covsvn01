1)translate lh_wh_riskfactor_eval go
;*** Generated by TRANSLATE, verify before re-including (Debug:N,Optimize:N,DiffEnd:N,Rdb:N) ***
DROP PROGRAM lh_wh_riskfactor_eval GO
CREATE PROGRAM lh_wh_riskfactor_eval
 SET retval = - (1 )
 SELECT INTO "nl:"
  c.event_id ,
  c.clinical_event_id ,
  cr.descriptor ,
  n.source_identifier ,
  n.source_string
  FROM (clinical_event c ),
   (ce_coded_result cr ),
   (nomenclature n )
  PLAN (c
   WHERE (c.person_id = link_personid )
   AND (c.encntr_id = link_encntrid ) )
   JOIN (cr
   WHERE (cr.event_id = c.event_id )
   AND (cr.valid_until_dt_tm >= cnvtdatetime (curdate ,curtime ) ) )
   JOIN (n
   WHERE (n.nomenclature_id = cr.nomenclature_id )
   AND (n.source_string =  $1 )
   AND (n.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime ) )
   AND (n.active_ind = 1 ) )
  WITH nocounter
 ;end select
 IF ((curqual > 0 ) )
  SET retval = 100
 ELSE
  SET retval = 0
 ENDIF
END GO
1)

200826:114819 lh_wh_riskfactor_eval.prg              Cost 0.00 Cpu 0.00 Ela 0.00 Dio   0 O0M0R0 P1R0
