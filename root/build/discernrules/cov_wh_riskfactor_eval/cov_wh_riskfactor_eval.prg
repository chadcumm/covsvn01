
DROP PROGRAM cov_wh_riskfactor_eval GO
CREATE PROGRAM cov_wh_riskfactor_eval
 SET retval = - (1 )
 set log_message=concat(log_message,";",trim(cnvtstring(link_personid)))
 set log_message=concat(log_message,";",trim(cnvtstring(link_encntrid)))
 set log_message=concat(log_message,";",$1)
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
   AND (c.encntr_id = link_encntrid )
   and (c.clinical_event_id = link_clineventid ))
   JOIN (cr
   WHERE (cr.event_id = c.event_id )
   AND (cr.valid_until_dt_tm >= cnvtdatetime (curdate ,curtime ) ) )
   JOIN (n
   WHERE (n.nomenclature_id = cr.nomenclature_id )
   AND (n.source_string =  $1 )
   AND (n.end_effective_dt_tm >= cnvtdatetime (curdate ,curtime ) )
   AND (n.active_ind = 1 ) )
  detail 
   log_message=concat(log_message,";",trim(n.source_string))
  WITH nocounter
 ;end select
 IF ((curqual > 0 ) )
  SET retval = 100
 ELSE
  SET retval = 0
 ENDIF
END GO

