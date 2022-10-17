/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:			Geetha Paramasivam
	Date Written:		Mar'22
	Solution:			Powerchart
	Source file name:	      cov_tn_pso_order_req.prg
	Object name:		cov_tn_pso_order_req
	Request#:			11530
 	Program purpose:	      PSO column in Dynamic Patient List
 	Executing from:		Bedrock
  	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
------------------------------------------------------------------------------
				Initial release by Cerner
				
03/09/22    Geetha      CR#11530 - Icon added to the missing PSO 
******************************************************************************/
 
 
drop program cov_tn_pso_order_req :dba go
create program cov_tn_pso_order_req :dba
 
;-------------------------------------------------------------------------------------------------------------------------------- 
 
declare public::main (null ) = null with private
declare public::determinepsoorder (null ) = null with protect
 
declare person_cnt = i4 with protect ,constant (size (reply->person ,5 ) )
declare current_date_time = dq8 with protect ,constant (cnvtdatetime (sysdate ) )
declare exp_idx = i4 with protect ,noconstant (0 )
declare loc_idx = i4 with protect ,noconstant (0 )
declare icon_path = vc with protect, constant ("images/alert.gif")
declare inpatient = f8 with protect ,constant (uar_get_code_by ("DISPLAY_KEY" ,200 ,"PSOADMITTOINPATIENT " ) )
declare observation = f8 with protect ,constant (uar_get_code_by ("DISPLAY_KEY" ,200 ,"PSOOBSERVATION" ) )
declare outpatient_in_bed = f8 with protect ,constant (uar_get_code_by ("DISPLAY_KEY" ,200 ,"PSOOUTPATIENTINABED" ) )
declare outpatient_for_proc_services = f8 with protect ,constant (uar_get_code_by ("DISPLAY_KEY",200 ,"PSOOUTPATIENTFORPROCEDUREORSERVICE" ) )

declare inpat_var   = f8 with constant(uar_get_code_by("DISPLAY", 71, "Inpatient")),protect
declare obs_var     = f8 with constant(uar_get_code_by("DISPLAY", 71, "Observation")),protect
declare outpat_var  = f8 with constant(uar_get_code_by("DISPLAY", 71, "Outpatient in a Bed")),protect
declare complete_var  = f8 with constant(uar_get_code_by("DISPLAY", 6004, "Completed")),protect
declare order_var     = f8 with constant(uar_get_code_by("DISPLAY", 6004, "Ordered")),protect

;-------------------------------------------------------------------------------------------------------------------------------- 
 
 call main (null )
 
 subroutine  public::main (null )
 	call determinepsoorder (null )
 	call creatalert (null )
 	set reply->status_data.status = "S"
 END ;Subroutine
 
 
subroutine  public::determinepsoorder (null )
 
  	select into "nl:"
  	from orders o
 
  	plan (o where (o.catalog_cd in (inpatient,observation,outpatient_in_bed,outpatient_for_proc_services ) )
    		and (o.active_ind = 1 )
    		and o.order_status_cd in(complete_var, order_var)
    		and (o.orig_order_dt_tm between cnvtlookbehind ("1,y" ) and cnvtdatetime (current_date_time ) )
    		and expand (exp_idx ,1 ,person_cnt ,o.encntr_id ,reply->person[exp_idx ].encntr_id ) )

   	order by o.person_id, o.updt_dt_tm desc, o.order_id desc
 
   	head report
    		person_idx = 0
   	head o.encntr_id
    		person_idx = locateval (loc_idx ,1 ,person_cnt ,o.encntr_id ,reply->person[loc_idx ].encntr_id )
    		,stat = alterlist (reply->person[person_idx ].contents ,1 ) ,
    		if ((o.catalog_cd = inpatient ) ) reply->person[person_idx ].contents.primary = "IP"
    		  elseif ((o.catalog_cd = observation ) ) reply->person[person_idx ].contents.primary = "OBS"
    		  elseif ((o.catalog_cd = outpatient_in_bed ) ) reply->person[person_idx ].contents.primary = "OP Bed"
    		  elseif ((o.catalog_cd = outpatient_for_proc_services ) ) reply->person[person_idx ].contents.primary = "OP Proc"
    		endif
    	foot o.encntr_id
    		null
   	with nocounter
end ;subroutine
 
subroutine  public::creatalert (null )
 
  	select into "nl:"
  	from encounter e
 
  	plan e where e.encntr_type_cd in(inpat_var, obs_var, outpat_var)
    		and e.active_ind = 1
    		and e.encntr_status_cd = 854.00 ;Active
    		and expand (exp_idx ,1 ,person_cnt ,e.encntr_id ,reply->person[exp_idx ].encntr_id )
   	order by e.encntr_id
 
   	head report
    		person_idx = 0
   	head e.encntr_id
    		person_idx = locateval (loc_idx ,1 ,person_cnt ,e.encntr_id ,reply->person[loc_idx ].encntr_id )
    		,stat = alterlist (reply->person[person_idx ].contents ,1 ) ,
 
    		if(reply->person[person_idx].contents.primary = " ")
    			reply->person[person_idx].icon = icon_path
    			reply->person[person_idx].contents.primary = "Missing PSO"
    		endif
 
    	foot e.encntr_id
    		null
   	with nocounter
end ;subroutine
 
 
 
;========================================== Cerner copy =======================================================================================
 
 /*
 declare public::main (null ) = null with private
 declare public::determinepsoorder (null ) = null with protect
 
 call main (null )
 
 subroutine  public::main (null )
 	call determinepsoorder (null )
 	set reply->status_data.status = "S"
 END ;Subroutine
 
 subroutine  public::determinepsoorder (null )
 	declare person_cnt = i4 with protect ,constant (size (reply->person ,5 ) )
 	declare current_date_time = dq8 with protect ,constant (cnvtdatetime (sysdate ) )
 	declare exp_idx = i4 with protect ,noconstant (0 )
 	declare loc_idx = i4 with protect ,noconstant (0 )
 	declare inpatient = f8 with protect ,constant (uar_get_code_by ("DISPLAY_KEY" ,200 ,"PSOADMITTOINPATIENT " ) )
  	declare observation = f8 with protect ,constant (uar_get_code_by ("DISPLAY_KEY" ,200 ,"PSOOBSERVATION" ) )
  	declare outpatient_in_bed = f8 with protect ,constant (uar_get_code_by ("DISPLAY_KEY" ,200 ,"PSOOUTPATIENTINABED" ) )
  	declare outpatient_for_proc_services = f8 with protect ,constant (uar_get_code_by ("DISPLAY_KEY",200 ,"PSOOUTPATIENTFORPROCEDUREORSERVICE" ) )
 
  	select into "nl:"
  	from (orders o )
 
  	plan (o where (o.catalog_cd in (inpatient,observation,outpatient_in_bed,outpatient_for_proc_services ) )
    		and (o.active_ind = 1 )
    		and (o.orig_order_dt_tm between cnvtlookbehind ("1,y" ) and cnvtdatetime (current_date_time ) )
    		and expand (exp_idx ,1 ,person_cnt ,o.encntr_id ,reply->person[exp_idx ].encntr_id ) )
   	order by o.person_id, o.updt_dt_tm desc, o.order_id desc
 
   	head report
    		person_idx = 0
   	head o.encntr_id
    		person_idx = locateval (loc_idx ,1 ,person_cnt ,o.encntr_id ,reply->person[loc_idx ].encntr_id )
    		,stat = alterlist (reply->person[person_idx ].contents ,1 ) ,
    		if ((o.catalog_cd = inpatient ) ) reply->person[person_idx ].contents.primary = "IP"
    		  elseif ((o.catalog_cd = observation ) ) reply->person[person_idx ].contents.primary = "OBS"
    		  elseif ((o.catalog_cd = outpatient_in_bed ) ) reply->person[person_idx ].contents.primary = "OP Bed"
    		  elseif ((o.catalog_cd = outpatient_for_proc_services ) ) reply->person[person_idx ].contents.primary = "OP Proc"
    		endif
    	foot o.encntr_id
    		null
   	with nocounter
 end ;subroutine
 
 */
 
#exit_script
 
if ((((reqdata->loglevel >= 4 ) ) or ((validate (debug_ind ,0 ) > 0 ) )) )
  call echorecord (reply )
endif
 
end go
