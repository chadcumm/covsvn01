;001 - 09/25/2018 - ccummin4 - added order logic

DROP PROGRAM cov_cust_col_renewal_req :dba GO
CREATE PROGRAM cov_cust_col_renewal_req :dba
 DECLARE PUBLIC::main (null ) = null WITH private
 DECLARE PUBLIC::determinerenewalrequest (null ) = null WITH protect
 CALL main (null )
 SUBROUTINE  PUBLIC::main (null )
  CALL determinerenewalrequest (null )
  SET reply->status_data.status = "S"
 END ;Subroutine
 SUBROUTINE  PUBLIC::determinerenewalrequest (null )
  DECLARE initiate_str 					= vc WITH protect 	,constant ("RESTRAINT INITIATE NON-VIOLENT" )
  DECLARE renewal_str 					= vc WITH protect 	,constant ("RESTRAINT RENEWAL NON-VIOLENT" )
  DECLARE person_cnt 					= i4 WITH protect 	,constant (size (reply->person ,5 ) )
  DECLARE current_date_time 			= dq8 WITH protect 	,constant (cnvtdatetime (curdate ,curtime3 ) )
  DECLARE beg_time_period				= dq8 with protect	,noconstant (0.0)	;001
  DECLARE end_time_period				= dq8 with protect	,noconstant (0.0)	;001
  DECLARE exp_idx 						= i4 WITH protect 	,noconstant (0 )
  DECLARE enc_idx 						= i4 WITH protect 	,noconstant (0 )  ;001
  DECLARE loc_idx 						= i4 WITH protect 	,noconstant (0 )
  DECLARE pnrc_renew 					= f8 WITH protect 	,noconstant (0.0) ;001
  DECLARE rest_renew 					= f8 WITH protect 	,noconstant (0.0) ;001
  DECLARE rest_monitor 					= f8 WITH protect 	,noconstant (0.0) ;001
  DECLARE rest_init						= f8 WITH protect 	,noconstant (0.0) ;001
  DECLARE order_dt_check				= dq8 with protect	,noconstant (0.0)	;001
  DECLARE initiated_cd 					= f8 WITH protect 	,constant (uar_get_code_by ("MEANING" ,16769 ,"INITIATED" ))
  DECLARE completed_cd	 				= f8 WITH protect 	,constant (uar_get_code_by ("MEANING" ,16769 ,"COMPLETED" ))
  DECLARE order_comp_cd	 				= f8 WITH protect 	,constant (uar_get_code_by ("MEANING" ,6004  ,"COMPLETED" ))		;001
  DECLARE order_order_cd	 			= f8 WITH protect 	,constant (uar_get_code_by ("MEANING" ,6004  ,"ORDERED" ))			;001
  DECLARE order_cancel_cd	 			= f8 WITH protect 	,constant (uar_get_code_by ("MEANING" ,6004  ,"CANCELED" ))			;001
  DECLARE order_dc_cd		 			= f8 WITH protect 	,constant (uar_get_code_by ("MEANING" ,6004  ,"DISCONTINUED" ))		;001
  DECLARE order_void_cd		 			= f8 WITH protect 	,constant (uar_get_code_by ("MEANING" ,6004  ,"DELETED" ))			;001
  DECLARE auth_cd						= f8 WITH protect 	,constant (uar_get_code_by ("MEANING" ,8  	 ,"AUTH" ))				;001
  DECLARE modified_cd					= f8 WITH protect 	,constant (uar_get_code_by ("MEANING" ,8  	 ,"MODIFIED" ))			;001
  DECLARE altered_cd					= f8 WITH protect 	,constant (uar_get_code_by ("MEANING" ,8  	 ,"ALTERED" ))			;001
  DECLARE restraint_nurse_doc			= f8 with protect,	constant (uar_get_code_by("DISPLAY",72,"Restraint Activity Type:"))
  DECLARE care_plan_type_mean 			= vc WITH protect	,constant ("CAREPLAN" )
  DECLARE renewal_status_icon 			= vc WITH protect 	,constant ("images/renewal.png" )
  DECLARE other_renewal_status_icon 	= vc WITH protect 	,constant ("images/renewal2.png" )	;001
  DECLARE time_unit						= i2 WITH protect 	,noconstant (4) ;1=days,2=weeks,3=hours,4=minutes,5=seconds	;001
  DECLARE lookback						= vc WITH protect 	,noconstant ("36,H") ;HUN[SEC] S[EC] MIN H[OUR] D[AY] W[EEK] M[ONTH] Y[EAR].	;001
  DECLARE dmode							= i2 WITH protect	,noconstant (0)	;debug mode for echo
  
  /* start 001 */
  
  IF ((((reqdata->loglevel >= 4 ) ) OR ((validate (debug_ind ,0 ) > 0 ) )) )
  	set dmode = 1
  ENDIF
	/*
	"D"  Return begin or end of day
	"W"  Return week begin or end day
	"M"  Return month begin or end day
	"Q"  Return quarter begin or end day
	"Y"  Return year begin or end day
	"C"  Return century begin or end day
	
	"B"	 Find beginning
	"E"  Find ending
	
	"B"  Begin time of day
	"E"  End time of day
	"P"  Preserve time of day
	*/
  ;Yesterday all day
  set beg_time_period    = datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'B', 'B')
  set end_time_period    = datetimefind(cnvtlookbehind("1,D",cnvtdatetime(curdate,curtime3)), 'D', 'E', 'E')
  ;Today all day
  set beg_time_period    = datetimefind(cnvtdatetime(curdate,curtime3), 'D', 'B', 'B')
  set end_time_period    = datetimefind(cnvtdatetime(curdate,curtime3), 'D', 'E', 'E')

  if (dmode = 1)
  	call echo(build2(^beg_time_period: 		^,format(cnvtdatetime(beg_time_period),";;q" 	)))
  	call echo(build2(^end_time_period: 		^,format(cnvtdatetime(end_time_period),";;q" 	)))
  endif
  
  select into "nl:"
  from 
  	order_catalog oc
  plan oc 
  	where oc.primary_mnemonic in(
									"PNRC Restraint Renewal Non-Violent"
									,"Restraint Renewal Non-Violent"
									,"Restraint Initiate Non-Violent"
									,"Restraint Monitoring every 2 hours"
								)
	and oc.active_ind = 1
  order by
	 oc.primary_mnemonic
	,oc.updt_dt_tm desc
  head oc.primary_mnemonic
  	case (oc.primary_mnemonic)
  		of "Restraint Renewal Non-Violent": 		rest_renew 		= oc.catalog_cd
  		of "PNRC Restraint Renewal Non-Violent":	pnrc_renew	 	= oc.catalog_cd
  		of "Restraint Initiate Non-Violent":		rest_init 		= oc.catalog_cd
  		of "Restraint Monitoring every 2 hours":	rest_monitor 	= oc.catalog_cd
  	endcase
  with nocounter
  
  if (dmode = 1)
	call echo(build2(^"Restraint Renewal Non-Violent": 		^,rest_renew 	)) 
	call echo(build2(^"PNRC Restraint Renewal Non-Violent":	^,pnrc_renew	)) 
	call echo(build2(^"Restraint Initiate Non-Violent":		^,rest_init 	)) 
	call echo(build2(^"Restraint Monitoring every 2 hours":	^,rest_monitor	))   
  endif
  /* end 001 */
  
  /* start 001 
  SELECT INTO "nl:"
   FROM (pathway_catalog pc ),
    (pathway p )
   PLAN (pc
    WHERE (pc.description_key IN (renewal_str ,
    initiate_str ) )
    AND (pc.type_mean = care_plan_type_mean ) )
    JOIN (p
    WHERE (p.pathway_catalog_id = pc.pathway_catalog_id )
    AND expand (exp_idx ,1 ,person_cnt ,p.person_id ,reply->person[exp_idx ].person_id )
    AND (p.pw_status_cd IN (initiated_cd ,
    completed_cd ) )
    AND (p.end_effective_dt_tm BETWEEN cnvtlookbehind (lookback ) AND cnvtdatetime (current_date_time
     ) ) )
   ORDER BY p.person_id ,
    p.end_effective_dt_tm DESC
   HEAD REPORT
    person_idx = 0 ,
    no_of_hours = 0
   HEAD p.person_id
    person_idx = locateval (loc_idx ,1 ,person_cnt ,p.person_id ,reply->person[loc_idx ].person_id )
    ,no_of_hours = datetimediff (current_date_time ,cnvtdatetime (p.order_dt_tm ) ,time_unit ) ,stat =
    alterlist (reply->person[person_idx ].contents ,1 ) ,
    IF ((no_of_hours >= 12 )
    AND (no_of_hours < 30 ) ) 
    	reply->person[person_idx ].icon = renewal_status_icon
    	 IF ((((reqdata->loglevel >= 4 ) ) OR ((validate (debug_ind ,0 ) > 0 ) )) )
  			call echo(build2("p.person_id=",p.person_id))
 		ENDIF
    ELSE 
    	reply->person[person_idx ].icon = " "
    ENDIF
   FOOT  p.person_id
    null
   WITH nocounter
   
   /* end 001 */
   
   /* start 001 */
   SELECT INTO "nl:"
   	 o.person_id
   	,o.catalog_cd
    ,sort_time = 	if (o.order_status_cd = order_dc_cd)
    					o.status_dt_tm
    				else
    					o.orig_order_dt_tm
    				endif	
   FROM 
   	orders o
   ,clinical_event ce
   ,pathway_catalog pc
   ,dummyt d1
   PLAN o 
   	where 	expand(
	   					 exp_idx
	   					,1
	   					,person_cnt
	   					,o.person_id
	   					,reply->person[exp_idx].person_id
   					)
   	and 	expand(
	   					 enc_idx
	   					,1
	   					,person_cnt
	   					,o.encntr_id
	   					,reply->person[enc_idx].encntr_id
   					)
    and 	o.catalog_cd in(
    							 	 pnrc_renew 
									,rest_renew	
									,rest_init 	
									,rest_monitor

    						)
    and		o.order_status_cd	in(
    									 order_order_cd
    									,order_comp_cd
    									,order_dc_cd
    									,order_void_cd
    									,order_cancel_cd
    								)
   join pc
   	where	pc.pathway_catalog_id = o.pathway_catalog_id
   join d1
   join ce
    where 	ce.person_id = o.person_id
    and		ce.encntr_id = o.encntr_id
    and   	ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and		ce.event_cd = restraint_nurse_doc
	and     ce.result_status_cd in(auth_cd,modified_cd,altered_cd)
   ORDER BY 
   	 o.person_id
   	,sort_time
   	,ce.valid_from_dt_tm 
   HEAD REPORT
    	 person_idx		= 0
    	,no_of_hours 	= 0
   HEAD o.person_id
   		 person_idx		= 0
    	,no_of_hours 	= 0
 		person_idx 		= locateval(
     									 loc_idx
     									,1 
     									,person_cnt 
     									,o.person_id 
     									,reply->person[loc_idx].person_id 
     								)
   ;HEAD sort_status
   ;	 if (dmode = 1) call echo(build2(^HEAD sort_status=^,cnvtstring(sort_status))) endif
   ;HEAD o.catalog_cd
   ;	 if (dmode = 1) call echo(build2(^HEAD o.catalog_cd=^,cnvtstring(o.catalog_cd),^:^,uar_get_code_display(o.catalog_cd))) endif
   ;	 if (dmode = 1) call echo(build2(^---- o.order_id=^,cnvtstring(o.order_id))) endif
   detail
    if (o.order_status_cd not in(order_dc_cd,order_void_cd,order_cancel_cd))	;not discontinued
    /*  001    	no_of_hours 		= datetimediff(
	    									 current_date_time
	    									,cnvtdatetime(o.orig_order_dt_tm )
	    									,time_unit
    										) 
    										
	*/
     	stat 				= alterlist(reply->person[person_idx ].contents ,1 )
    	if (o.orig_order_dt_tm between 
    								cnvtdatetime(beg_time_period)
    						and
    								cnvtdatetime(end_time_period)
    						)
    		reply->person[person_idx ].icon = " "
    	else
    		reply->person[person_idx ].icon = renewal_status_icon
    		order_dt_check = o.orig_order_dt_tm
		endif
	elseif (	(o.order_status_cd in(order_dc_cd,order_void_cd,order_comp_cd,order_cancel_cd)) and 
				(o.catalog_cd = rest_monitor) and 
				(pc.description_key ="RESTRAINT INITIATE NON-VIOLENT")
			) ;dc res mon q 2 hours
		reply->person[person_idx ].icon = " "
    endif


    /* start 001
    IF ((no_of_hours >= 12 ) AND (no_of_hours < 30 ) )
     if (reply->person[person_idx ].icon = " ")
     	reply->person[person_idx ].icon = other_renewal_status_icon
     endif
    ELSE 
     ;reply->person[person_idx ].icon = " "
     stat = 0
    ENDIF
    /* end 001 */
    
    
   FOOT  o.person_id
    if (order_dt_check < ce.valid_from_dt_tm)
    	call echo("override with nurse doc")
    	reply->person[person_idx ].icon = " "
    endif
   WITH nocounter, outerjoin = d1
   /* end 001 */
   
  ;end select
 END ;Subroutine
#exit_script
 IF ((((reqdata->loglevel >= 4 ) ) OR ((validate (debug_ind ,0 ) > 0 ) )) )
  CALL echorecord (reply )
 ENDIF
END GO
