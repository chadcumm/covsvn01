/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				     Chad Cummings
	Date Written:		   03/01/2019
	Solution:			     Perioperative
	Source file name:	 cov_inp_cert_alert_audit.prg
	Object name:		   cov_inp_cert_alert_audit
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	03/01/2019  Chad Cummings
******************************************************************************/
drop program cov_inp_cert_alert_audit go
create program cov_inp_cert_alert_audit

prompt 
	"Output to File/Printer/MINE" = "MINE"    ;* Enter or select the printer or file name to send this report to.
	, "Evoking Action" = 0
	, "Beginning Date and Time" = "SYSDATE" 

with OUTDEV, EVOKE_ACTION, BEG_DT_TM

if ($EVOKE_ACTION = 0)
		select into $OUTDEV
	     rule=substring(1,30,ede.dlg_name)
	    ,alert_dt_tm = format(ede.dlg_dt_tm, ";;q")
	    ,provider_name=substring(1,30,pr.name_full_formatted)
	    ,facility=trim(uar_Get_code_display(e.loc_facility_cd))
	    ,unit=trim(uar_get_code_Display(e.loc_nurse_unit_cd))
	    ,fin=trim(ea.alias)
	    ,patient=substring(1,30,p.name_full_formatted)
	from
	     eks_dlg_event ede
	    ,prsnl pr
	    ,encntr_alias ea
	    ,encounter e
	    ,person p
	plan ede
	where ede.dlg_dt_tm >= cnvtdatetime($BEG_DT_TM) and ede.dlg_name = "PSO_EKM!PSO_INPT_CERTIFICATION*"
	join p
	    where p.person_id = ede.person_id
	join e
	    where e.encntr_id = ede.encntr_id
	join pr
	    where pr.person_id = ede.dlg_prsnl_id
	join ea
	    where ea.encntr_id = e.encntr_id
	    and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	    and   ea.active_ind = 1
	    and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	    and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	order by
	     pr.name_full_formatted
	    ,facility
	    ,ede.dlg_dt_tm
	with nocounter,format,seperator = " "
elseif ($EVOKE_ACTION = 2)
	select into $OUTDEV
	     rule=substring(1,30,ede.dlg_name)
	     ,alert_dt_tm = format(ede.dlg_dt_tm, ";;q")
	    ,provider_name=substring(1,30,pr.name_full_formatted)
	    ,facility=trim(uar_Get_code_display(e.loc_facility_cd))
	    ,unit=trim(uar_get_code_Display(e.loc_nurse_unit_cd))
	    ,fin=trim(ea.alias)
	    ,patient=substring(1,30,p.name_full_formatted)
	from
	     eks_dlg_event ede
	    ,prsnl pr
	    ,encntr_alias ea
	    ,encounter e
	    ,person p
	plan ede
	where ede.dlg_dt_tm >= cnvtdatetime($BEG_DT_TM) and ede.dlg_name = "PSO_EKM!PSO_INPT_RECERT_CHECK_2"
	join p
	    where p.person_id = ede.person_id
	join e
	    where e.encntr_id = ede.encntr_id
	join pr
	    where pr.person_id = ede.dlg_prsnl_id
	join ea
	    where ea.encntr_id = e.encntr_id
	    and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	    and   ea.active_ind = 1
	    and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	    and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	order by
	     pr.name_full_formatted
	    ,facility
	    ,ede.dlg_dt_tm
	with nocounter,format,seperator = " "
elseif ($EVOKE_ACTION = 1)
	select into $OUTDEV
	     rule=substring(1,30,ede.dlg_name)
	    ,alert_dt_tm = format(ede.dlg_dt_tm, ";;q")
	    ,provider_name=substring(1,30,pr.name_full_formatted)
	    ,facility=trim(uar_Get_code_display(e.loc_facility_cd))
	    ,unit=trim(uar_get_code_Display(e.loc_nurse_unit_cd))
	    ,fin=trim(ea.alias)
	    ,patient=substring(1,30,p.name_full_formatted)
	from
	     eks_dlg_event ede
	    ,prsnl pr
	    ,encntr_alias ea
	    ,encounter e
	    ,person p
	plan ede
	where ede.dlg_dt_tm >= cnvtdatetime($BEG_DT_TM) and ede.dlg_name = "PSO_EKM!PSO_INPT_CERT_CHECK*"
	join p
	    where p.person_id = ede.person_id
	join e
	    where e.encntr_id = ede.encntr_id
	join pr
	    where pr.person_id = ede.dlg_prsnl_id
	join ea
	    where ea.encntr_id = e.encntr_id
	    and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	    and   ea.active_ind = 1
	    and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	    and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	order by
	     pr.name_full_formatted
	    ,facility
	    ,ede.dlg_dt_tm
	with nocounter,format,seperator = " "
endif

#exit_script


end go
