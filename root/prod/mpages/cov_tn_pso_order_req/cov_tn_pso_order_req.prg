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
09/01/22    Geetha      CR#13415 - Icon added to the missing PSO on BH patients
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
declare inpatient_var = f8 with protect ,constant (uar_get_code_by ("DISPLAY_KEY" ,200 ,"PSOADMITTOINPATIENT " ) )
declare observation_var = f8 with protect ,constant (uar_get_code_by ("DISPLAY_KEY" ,200 ,"PSOOBSERVATION" ) )
declare outpatient_in_bed_var = f8 with protect ,constant (uar_get_code_by ("DISPLAY_KEY" ,200 ,"PSOOUTPATIENTINABED" ) )
declare outpatient_for_proc_services_var = f8 with protect ,constant (uar_get_code_by ("DISPLAY_KEY",200 ,"PSOOUTPATIENTFORPROCEDUREORSERVICE" ) )
declare bh_ed_admit_var = f8 with protect ,constant (uar_get_code_by ("DISPLAY_KEY" ,200 ,"BEHAVIORALHEALTHEMERGENCYADMIT"))
declare bh_vol_admit_var = f8 with protect ,constant (uar_get_code_by ("DISPLAY_KEY" ,200 ,"BEHAVIORALHEALTHVOLUNTARYADMIT"))
declare bh_30d_readmit_var = f8 with protect ,constant (uar_get_code_by ("DISPLAY_KEY" ,200 ,"BEHAVIORALHEALTH30DAYREADMIT"))
declare bh_30d_readmit_invol_var = f8 with protect ,constant (uar_get_code_by ("DISPLAY_KEY" ,200 ,"BEHAVIORALHEALTH30DAYREADMITINVOLUNTARY"))
declare bh_30d_readmit_vol_var = f8 with protect ,constant (uar_get_code_by ("DISPLAY_KEY" ,200 ,"BEHAVIORALHEALTH30DAYREADMITVOLUNTARY"))
declare pso_bh_admit_var = f8 with protect ,constant (uar_get_code_by ("DISPLAY_KEY" ,200 ,"PSOADMITTOSENIORBEHAVIORALHEALTH"))

declare inpat_var         = f8 with constant(uar_get_code_by("DISPLAY", 71, "Inpatient")),protect
declare obs_var        	  = f8 with constant(uar_get_code_by("DISPLAY", 71, "Observation")),protect
declare outpat_var     	  = f8 with constant(uar_get_code_by("DISPLAY", 71, "Outpatient in a Bed")),protect
declare bh_var         	  = f8 with constant(uar_get_code_by("DISPLAY", 71, "Behavioral Health")),protect
declare bh_inpat_var   	  = f8 with constant(uar_get_code_by("DISPLAY", 71, "Behavioral Inpatient Evaluation")),protect
declare bh_adol_psych_var = f8 with constant(uar_get_code_by("DISPLAY", 71, "Hospital Adolescent Psych")),protect
declare bh_adlt_psych_var = f8 with constant(uar_get_code_by("DISPLAY", 71, "Hospital Adult Psych")),protect
declare bh_detox_var      = f8 with constant(uar_get_code_by("DISPLAY", 71, "Hospital Detox")),protect
declare bh_latency_var    = f8 with constant(uar_get_code_by("DISPLAY", 71, "Hospital Latency")),protect

;declare adolescent_var = f8 with constant(uar_get_code_by("DISPLAY", 71, "Adolescent IOP")),protect
;declare adult_var      = f8 with constant(uar_get_code_by("DISPLAY", 71, "Adult IOP")),protect

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
 
  	plan (o where (o.catalog_cd in (inpatient_var, observation_var, outpatient_in_bed_var,outpatient_for_proc_services_var,
  						bh_ed_admit_var,bh_vol_admit_var,bh_30d_readmit_var,bh_30d_readmit_invol_var,
  						bh_30d_readmit_vol_var,pso_bh_admit_var ) )
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
    		if ((o.catalog_cd = inpatient_var ) ) reply->person[person_idx ].contents.primary = "IP"
    		  elseif ((o.catalog_cd = observation_var ) ) reply->person[person_idx ].contents.primary = "OBS"
    		  elseif ((o.catalog_cd = outpatient_in_bed_var ) ) reply->person[person_idx ].contents.primary = "OP Bed"
    		  elseif ((o.catalog_cd = outpatient_for_proc_services_var ) ) reply->person[person_idx ].contents.primary = "OP Proc"
    		  elseif ((o.catalog_cd = bh_ed_admit_var ) ) reply->person[person_idx ].contents.primary = "BH ED" 
		  elseif ((o.catalog_cd = bh_vol_admit_var ) ) reply->person[person_idx ].contents.primary = "BH Vol"
		  elseif ((o.catalog_cd = bh_30d_readmit_var ) ) reply->person[person_idx ].contents.primary = "BH 30D RE"
		  elseif ((o.catalog_cd = bh_30d_readmit_invol_var ) ) reply->person[person_idx ].contents.primary = "BH 30D RE Ivol"
		  elseif ((o.catalog_cd = bh_30d_readmit_vol_var ) ) reply->person[person_idx ].contents.primary = "BH 30D RE Vol" 
		  elseif ((o.catalog_cd = pso_bh_admit_var ) ) reply->person[person_idx ].contents.primary = "BH PSO" 
	    	endif
    	foot o.encntr_id
    		null
   	with nocounter
end ;subroutine
 
subroutine  public::creatalert (null )
 
  	select into "nl:"
  	from encounter e
 
  	plan e where e.encntr_type_cd in(inpat_var, obs_var, outpat_var, bh_var, bh_inpat_var,
  			bh_adol_psych_var,bh_adlt_psych_var,bh_detox_var,bh_latency_var) ;adolescent_var, adult_var
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
