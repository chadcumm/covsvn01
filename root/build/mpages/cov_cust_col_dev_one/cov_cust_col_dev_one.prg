;000 - 10/15/18 - ccummin4 - initial release

DROP PROGRAM cov_cust_col_dev_one :dba GO
CREATE PROGRAM cov_cust_col_dev_one :dba
 DECLARE PUBLIC::main (null ) = null WITH private
 DECLARE PUBLIC::determineorderrenewalrequest (null ) = null WITH protect
 CALL main (null )
 SUBROUTINE  PUBLIC::main (null )
  CALL determineorderrenewalrequest (null )
  SET reply->status_data.status = "S"
 END ;Subroutine
 SUBROUTINE  PUBLIC::determineorderrenewalrequest (null )
  DECLARE person_cnt 					= i4 WITH protect 	,constant (size (reply->person ,5 ) )
  DECLARE current_date_time 			= dq8 WITH protect 	,constant (cnvtdatetime (curdate ,curtime3 ) )
  DECLARE beg_time_period				= dq8 with protect	,noconstant (0.0)	
  DECLARE end_time_period				= dq8 with protect	,noconstant (0.0)	
  DECLARE exp_idx 						= i4 WITH protect 	,noconstant (0 )
  DECLARE enc_idx 						= i4 WITH protect 	,noconstant (0 )  
  DECLARE loc_idx 						= i4 WITH protect 	,noconstant (0 )
  DECLARE pnrc_renew 					= f8 WITH protect 	,noconstant (0.0) 
  DECLARE rest_renew 					= f8 WITH protect 	,noconstant (0.0) 
  DECLARE rest_monitor 					= f8 WITH protect 	,noconstant (0.0) 
  DECLARE rest_init						= f8 WITH protect 	,noconstant (0.0) 
  DECLARE order_dt_check				= dq8 with protect	,noconstant (0.0)	
  DECLARE order_cancel_cd	 			= f8 WITH protect 	,constant (uar_get_code_by ("MEANING" ,6004  ,"CANCELED" ))			
  DECLARE order_order_cd	 			= f8 WITH protect 	,constant (uar_get_code_by ("MEANING" ,6004  ,"ORDERED" ))
  DECLARE order_dc_cd		 			= f8 WITH protect 	,constant (uar_get_code_by ("MEANING" ,6004  ,"DISCONTINUED" ))		
  DECLARE order_void_cd		 			= f8 WITH protect 	,constant (uar_get_code_by ("MEANING" ,6004  ,"DELETED" ))			
  DECLARE auth_cd						= f8 WITH protect 	,constant (uar_get_code_by ("MEANING" ,8  	 ,"AUTH" ))				
  DECLARE modified_cd					= f8 WITH protect 	,constant (uar_get_code_by ("MEANING" ,8  	 ,"MODIFIED" ))			
  DECLARE altered_cd					= f8 WITH protect 	,constant (uar_get_code_by ("MEANING" ,8  	 ,"ALTERED" ))			
  DECLARE renewal_status_icon 			= vc WITH protect 	,constant ("images/renewal.png" )
  DECLARE other_renewal_status_icon 	= vc WITH protect 	,constant ("images/hourglass-plus-icon.png" )	
  declare json = vc with noconstant(" ")
    /*
free record reply
record reply (
  1 person[*]
    2 person_id = f8
    2 encntr_id = f8
    2 ppr_cd = f8
    2 count = i4
    2 icon = vc
    2 contents[*]
      3 primary = vc
      3 secondary = vc
%i cclsource:status_block.inc
) with protect
*/
  IF ((((reqdata->loglevel >= 4 ) ) OR ((validate (debug_ind ,0 ) > 0 ) )) )
  	set dmode = 1
  ENDIF
 


   for (person_idx = 1 to size(reply->person,5))
 	;set reply->person[person_idx ].icon = other_renewal_status_icon
 	;set reply->person[person_idx ].count = 7
 	
 	set json = build(	'{"um_request":{"encounterId":"',
 						trim(cnvtstring(reply->person[person_idx].encntr_id)),
 						'","loadCodeSetsIndicator":1}}')
 	select into "nl:"
	from drg d
	,drg_extension de
	,nomenclature n
;,drg_encntr_extension dee 
	where d.encntr_id = reply->person[person_idx].encntr_id
	and cnvtdatetime(sysdate) between d.beg_effective_dt_tm and d.end_effective_dt_tm
	and d.active_ind = 1 
	and n.nomenclature_id = d.nomenclature_id
;and cnvtdatetime(sysdate) between n.beg_effective_dt_tm and n.end_effective_dt_tm
	and n.active_ind = 1
	and de.source_identifier = n.source_identifier
	and n.source_vocabulary_cd = d.source_vocabulary_cd
	and cnvtdatetime(sysdate) between de.beg_effective_dt_tm and de.end_effective_dt_tm
	and de.active_ind = 1
 	;free record um_request 
	;set jrec = cnvtjsontorec(json)
	;execute rcm_get_utilization_mgmt "MINE", 0, "GET", json 
 	and de.source_vocabulary_cd =           4326105.00
	detail
	 	stat= alterlist(reply->person[person_idx ].contents ,1 )
	 	reply->person[person_idx ].contents[1].primary = build(trim(cnvtstring(de.gmlos))," Days")
	 	reply->person[person_idx ].contents[1].secondary = n.source_string
	with nocounter
 endfor
   
  ;end select
 END ;Subroutine
#exit_script
 IF ((((reqdata->loglevel >= 4 ) ) OR ((validate (debug_ind ,0 ) > 0 ) )) )
  CALL echorecord (reply )
 ENDIF
END GO
