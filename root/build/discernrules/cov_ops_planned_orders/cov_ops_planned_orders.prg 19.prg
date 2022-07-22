/*~BB~************************************************************************
      *                                                                      *
      *  Copyright Notice:  (c) 1983 Laboratory Information Systems &        *
      *                              Technology, Inc.                        *
      *       Revision      (c) 1984-2005 Cerner Corporation                 *
      *                                                                      *
      *  Cerner (R) Proprietary Rights Notice:  All rights reserved.         *
      *  This material contains the valuable properties and trade secrets of *
      *  Cerner Corporation of Kansas City, Missouri, United States of       *
      *  America (Cerner), embodying substantial creative efforts and        *
      *  confidential information, ideas and expressions, no part of which   *
      *  may be reproduced or transmitted in any form or by any means, or    *
      *  retained in any storage or retrieval system without the express     *
      *  written permission of Cerner.                                       *
      *                                                                      *
      *  Cerner is a registered mark of Cerner Corporation.                  *
      *                                                                      *
  ~BE~***********************************************************************/
 
/*****************************************************************************
 
        Source file name:       cov_ops_planned_orders.prg
        Object name:			cov_ops_planned_orders
 
        Product:
        Product Team:
        HNA Version:
        CCL Version:
 
        Program purpose:
 
        Tables read:
 
 
        Tables updated:         -
 
******************************************************************************/
 
 
;~DB~************************************************************************
;    *    GENERATED MODIFICATION CONTROL LOG              *
;    ****************************************************************************
;    *                                                                         *
;    *Mod Date       Engineeer          Comment                                *
;    *--- ---------- ------------------ -----------------------------------    *
;     000 18-10-22  							initial release			       *
;    																           *
;~DE~***************************************************************************
 
 
;~END~ ******************  END OF ALL MODCONTROL BLOCKS  ********************
 
drop program cov_ops_planned_orders:dba go
create program cov_ops_planned_orders:dba

prompt 
	"Unit Name" = "" 

with UNIT_NAME
 
 
call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
set debug_ind = 1	;do not debug = 0			, debug mode = 1
%i ccluserdir:cov_custom_ccl_common.inc
 
call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))
 
if (not(validate(reply,0)))
	record  reply
	(
		1 text = vc
		1 status_data
		 2 status = c1
		 2 subeventstatus[1]
		  3 operationname = c15
		  3 operationstatus = c1
		  3 targetobjectname = c15
		  3 targetobjectvalue = c100
	)
	set reply->status_data.status = "F"
endif
 
call set_codevalues(null)
call check_ops(null)

%i cclsource:eks_rprq3091001.inc
%i cclsource:eks_run3091001.inc


free set t_rec
record t_rec
(
	1 qual_cnt				= i2
	1 found_ind				= i2
	1 medical_duration		= i2
	1 critical_duration		= i2
	1 compare_dt_tm			= dq8
	1 qual[*]
	 2 encntr_id			= f8
	 2 person_id			= f8
	 2 orders_cnt			= i2
	 2 send_ind				= i2
	 2 orders[*]
	  3 pathway_id			= f8
	  3 order_dt_tm			= f8
	  3 description			= vc
	  3 level_ind			= i2
	  3 age					= i2
	1 plan_cnt 				= i2
	1 plan_qual[*]
	 2 pathway_catalog_id	= f8
	 2 description  		= vc
	 2 level_ind			= i2 ;0 - medical, 1 - critical
	
)
;call addEmailLog("chad.cummings@covhlth.com") 

;001 per Jennifer this reference to medical and critical plans is not needed.  All power plans should be referenced now
call writeLog(build2("* START Finding PowerPlans **********************************"))

select into "nl:"
from 
	pathway_catalog pc
plan pc
	where pc.description_key in(
									"CARD NSTEMI AND DEFINITE UNSTABLE ANGINA ADMISSION",
									"CARD PRE CATH LAB/CARDIAC PROCEDURE INPATIENT",
									"CARD PRE IMPLANT/EP PROCEDURE INPATIENT PHASED",
									"CARD PRE-TAVR CTA PHASED",
									"CARD TEE / CARDIOVERSION AT BEDSIDE",
									"CARD TEE / CARDIOVERSION IN CARDIAC DIAGNOSTICS ONLY",
									"CARD TEE / CARDIOVERSION IN CATH LAB",
									"CC AUTOMATED PRONING ORDERS",
									"CC GENERAL ICU ADMISSION",
									"CC HYPOTHERMIA ADMISSION PHASED",
									"CRITICAL CARE DRIPS - SEDATIVES AND ANALGESICS",
									"CVSURG CARDIAC SURGERY FROM ED/FLOOR",
									"CVSURG ESOPHAGEAL SURGERY FROM ED/FLOOR",
									"CVSURG THORACIC SURGERY FROM ED/FLOOR",
									"ENT ADMIT",
									"ENT SURGERY FROM ED/FLOOR",
									"GI LAB PROCEDURE INPATIENT",
									"GYN ADMIT",
									"GYN SURGERY FROM ED/FLOOR",
									"HOS ABDOMINAL PAIN ADMISSION",
									"HOS ATRIAL FIBRILLATION/CARDIOVERSION",
									"HOS CHEST PAIN ADMISSION",
									"HOS COPD ADMISSION",
									"HOS DELIRIUM ENCEPHALOPATHY ADMISSION",
									"HOS DKA ADMISSION PHASED",
									"HOS DRUG OR TOXIC SUBSTANCE OVERDOSE ADMISSION",
									"HOS GENERAL ADMISSION",
									"HOS GI BLEED ADMISSION",
									"HOS HEART FAILURE ADMISSION",
									"HOS HYPERTENSION ADMISSION",
									"HOS PANCREATITIS ACUTE ADMISSION",
									"HOS PNEUMONIA ADMISSION",
									"HOS SEVERE SEPSIS ADMISSION WITH ADVISOR",
									"HOS SKIN/SOFT TISSUE INFECTION ADMISSION",
									"HOS SYNCOPE ADMISSION",
									"HOS UTI ADMISSION",
									"HOS VTE (PE/DVT) ADMISSION",
									"INSULIN DRIP ORDERS",
									"IVR PROCEDURE ORDERS",
									"NEPH CAPD MANUAL PERITONEAL DIALYSIS",
									"NEPH CCPD CYCLER PERITONEAL DIALYSIS",
									"NEPH CONTINUOUS RENAL REPLACEMENT THERAPY (CRRT)",
									"NEPH HEMODIALYSIS",
									"NEPH NEPHROLOGY ADMISSION",
									"NEPH PLASMAPHERESIS / PLASMA EXCHANGE (TPE)",
									"NEURO CEREBRAL VASOSPASM",
									"NEURO INTRACEREBRAL HEMORRHAGE (ICH) ADMISSION",
									"NEURO ISCHEMIC STROKE ADMISSION",
									"NEURO SUBARACHNOID HEMORRHAGE (SAH) ADMISSION",
									"NEURO TPA PHASED",
									"NS CRANIAL SURGERY FROM ED/FLOOR",
									"NS SPINE SURGERY FROM ED/FLOOR",
									"OB ANTEPARTUM ADMISSION",
									"OB CESAREAN DELIVERY",
									"OB LABOR AND DELIVERY ADMISSION",
									"ONC ONCOLOGY ADMISSION",
									"ONC ONCOLOGY ADMISSION SHORT",
									"ORTHO LOWER EXTREMITY SURGERY FROM ED/FLOOR",
									"ORTHO POD FOOT/ANKLE SURGERY FROM ED/FLOOR",
									"ORTHO SPINE SURGERY FROM ED/FLOOR",
									"ORTHO TOTAL JOINT SURGERY FROM ED/FLOOR",
									"ORTHO UPPER EXTREMITY SURGERY FROM ED/FLOOR",
									"PAL PALLIATIVE CARE / HOSPICE COMFORT ORDERS",
									"PED GENERAL MEDICINE ADMISSION",
									"PLAS SURGERY FROM ED/FLOOR",
									"SURG GEN ADMIT",
									"SURG GEN SURGERY FROM ED/FLOOR",
									"URO SURGERY FROM ED/FLOOR",
									"URO UROLOGY ADMISSION",
									"VASCS GENERAL ADMIT",
									"VASCS VASCULAR SURGERY FROM ED/FLOOR"
							)
	and pc.active_ind 			= 1
	and pc.beg_effective_dt_tm 	<= cnvtdatetime(curdate,curtime3)
	and pc.end_effective_dt_tm  >= cnvtdatetime(curdate,curtime3)
order by
	pc.pathway_catalog_id
head report
	cnt = 0
head pc.pathway_catalog_id
	cnt = (cnt + 1)
	stat = alterlist(t_rec->plan_qual,cnt)
	t_rec->plan_qual[cnt].pathway_catalog_id = pc.pathway_catalog_id
	t_rec->plan_qual[cnt].description 		 = pc.description
foot pc.pathway_catalog_id
	if (pc.description_key in(
								"CARD NSTEMI AND DEFINITE UNSTABLE ANGINA ADMISSION",
								"CC AUTOMATED PRONING ORDERS",
								"CC GENERAL ICU ADMISSION",
								"CC HYPOTHERMIA ADMISSION PHASED",
								"CRITICAL CARE DRIPS - SEDATIVES AND ANALGESICS",
								"CVSURG CARDIAC SURGERY FROM ED/FLOOR",
								"CVSURG ESOPHAGEAL SURGERY FROM ED/FLOOR",
								"CVSURG THORACIC SURGERY FROM ED/FLOOR",
								"HOS DKA ADMISSION PHASED",
								"INSULIN DRIP ORDERS",
								"NEPH CONTINUOUS RENAL REPLACEMENT THERAPY (CRRT)",
								"NEURO CEREBRAL VASOSPASM",
								"NEURO INTRACEREBRAL HEMORRHAGE (ICH) ADMISSION",
								"NEURO ISCHEMIC STROKE ADMISSION",
								"NEURO SUBARACHNOID HEMORRHAGE (SAH) ADMISSION",
								"NEURO TPA PHASED"
							))
		t_rec->plan_qual[cnt].level_ind = 1					
	endif
	call writeLog(build2("-->Added PowerPlan["	,trim(cnvtstring(cnt)),"]:"
												,trim(pc.description),":"
												,trim(cnvtstring(pc.pathway_catalog_id)),":"
												,trim(cnvtstring(t_rec->plan_qual[cnt].level_ind))))
foot report
	t_rec->plan_cnt = cnt
with nocounter

if (t_rec->plan_cnt <= 0)
	if (program_log->run_from_ops = 1)
		set reply->ops_event = substring(1,99,build2("FAILED: No PowerPlans references found"))
	endif
	if (validate(reply->status_data.subeventstatus.operationname,0))
		set reply->status_data.subeventstatus.operationname = "Find PowerPlan"
		set reply->status_data.subeventstatus.operationstatus = "F"
		set reply->status_data.subeventstatus.targetobjectname = "PATHWAY_CATALOG"
		set reply->status_data.subeventstatus.targetobjectvalue = build2("none of the refernce powerplan build was not found")
	endif
	go to exit_script
endif

call writeLog(build2("* END  Finding PowerPlans **********************************"))

call writeLog(build2("* START Finding Location ***********************************"))

if (program_log->run_from_ops = 1)
	if (validate(parm_list))
		call writeLog(build2("->parm_list is available"))
		if (size(parm_list->p_list,5) > 0)
			call writeLog(build2("-->parm_list->p_list size is ",trim(cnvtstring(size(parm_list->p_list,5)))))
			for (j=1 to size(parm_list->p_list,5))
				call writeLog(build2("---->checking parm_list->p_list[",trim(cnvtstring(j)),"]->parm=",parm_list->p_list[j].parm))
				call AddLocationList("AMBULATORY",parm_list->p_list[j].parm)
				call AddLocationList("NURSEUNIT",parm_list->p_list[j].parm)
			endfor
		endif
	endif
elseif (program_log->run_from_eks = 1)
	set log_message = concat("program_log->run_from_eks =",program_log->run_from_eks)
	call writeLog(build2("---->checking $UNIT_NAME=",$UNIT_NAME))
	call AddLocationList("AMBULATORY",$UNIT_NAME)
	call AddLocationList("NURSEUNIT",$UNIT_NAME)
	set log_message = concat("---->checking $UNIT_NAME=",$UNIT_NAME)
endif

if (location_list->location_cnt <= 0)
	call writeLog(substring(1,99,build2("FAILED: Invalid Location Parameter Passed")))
	if (program_log->run_from_ops = 1)
		set reply->ops_event = substring(1,99,build2("FAILED: Invalid Location Parameter Passed"))
	endif
	if (validate(reply->status_data.subeventstatus.operationname,0))
		set reply->status_data.subeventstatus.operationname = "Find Location"
		set reply->status_data.subeventstatus.operationstatus = "F"
		set reply->status_data.subeventstatus.targetobjectname = "LOCATION"
	endif
	go to exit_script
endif
call writeLog(build2("* END   Finding Location ***********************************"))

call writeLog(build2("* START Finding Patients ***********************************"))
select into "nl:"
from 
	 encntr_domain ed
	,pathway p
	,pathway_catalog pc
plan ed
	where	expand(i,1,location_list->location_cnt,ed.loc_nurse_unit_cd,location_list->locations[i].location_cd)
	and 	ed.active_ind 			= 1
	and 	ed.end_effective_dt_tm 	= cnvtdatetime("31-DEC-2100 00:00:00")
join p
	where 	p.encntr_id 			= ed.encntr_id
	and		p.pw_status_cd			= code_values->cv.cs_16769.planned_cd
join pc
	where	pc.pathway_catalog_id	= p.pw_cat_group_id	
	;001 and		expand(j,1,t_rec->plan_cnt,pc.pathway_catalog_id,t_rec->plan_qual[j].pathway_catalog_id)
	
order by
 	 ed.encntr_id
 	,p.order_dt_tm 
	,pc.pathway_catalog_id
head report
	t_rec->qual_cnt 	= 0
head ed.encntr_id
	t_rec->qual_cnt = (t_rec->qual_cnt + 1)
	stat = alterlist(t_rec->qual,t_rec->qual_cnt)
	t_rec->qual[t_rec->qual_cnt].encntr_id 	= ed.encntr_id
	t_rec->qual[t_rec->qual_cnt].person_id	= ed.person_id
	call writeLog(build2("-->Adding encntr_id[",trim(cnvtstring(t_rec->qual_cnt)),"]:",trim(cnvtstring(ed.encntr_id))))
head pc.pathway_catalog_id
	t_rec->found_ind = 1
	pos		= locateval(i,1,t_rec->plan_cnt,pc.pathway_catalog_id,t_rec->plan_qual[i].pathway_catalog_id)
	t_rec->qual[t_rec->qual_cnt].orders_cnt = (t_rec->qual[t_rec->qual_cnt].orders_cnt + 1)
	stat = alterlist(t_rec->qual[t_rec->qual_cnt].orders,t_rec->qual[t_rec->qual_cnt].orders_cnt)
	t_rec->qual[t_rec->qual_cnt].orders[t_rec->qual[t_rec->qual_cnt].orders_cnt].pathway_id		= p.pathway_id
	t_rec->qual[t_rec->qual_cnt].orders[t_rec->qual[t_rec->qual_cnt].orders_cnt].description	= pc.description
	;001 t_rec->qual[t_rec->qual_cnt].orders[t_rec->qual[t_rec->qual_cnt].orders_cnt].level_ind		= t_rec->plan_qual[pos].level_ind
	t_rec->qual[t_rec->qual_cnt].orders[t_rec->qual[t_rec->qual_cnt].orders_cnt].level_ind		= 0 ;001
	t_rec->qual[t_rec->qual_cnt].orders[t_rec->qual[t_rec->qual_cnt].orders_cnt].order_dt_tm	= p.order_dt_tm
	t_rec->qual[t_rec->qual_cnt].orders[t_rec->qual[t_rec->qual_cnt].orders_cnt].age			= datetimediff(
																												 cnvtdatetime(
																												 curdate,curtime3)
																												,p.order_dt_tm
																												,4)
	call writeLog(build2("---->Adding pathway_id[",trim(cnvtstring(t_rec->qual[t_rec->qual_cnt].orders_cnt)),"]:",
																							trim(cnvtstring(p.pathway_id))))
with nocounter
if (t_rec->found_ind <= 0)
	if (program_log->run_from_ops = 1)
		set reply->ops_event = substring(1,99,build2("SUCCESS (Z): Successful operation, no patients qualified"))
	endif
	if (validate(reply->status_data.subeventstatus.operationname,0))
		set reply->status_data.status = "Z"
		set reply->status_data.subeventstatus.operationname = "Find Patients"
		set reply->status_data.subeventstatus.operationstatus = "Z"
		set reply->status_data.subeventstatus.targetobjectname = "PATHWAY"
		if (program_log->run_from_eks = 1)
			set retval = 100
		endif
	endif
	go to exit_script
endif
call writeLog(build2("* END   Finding Patients ***********************************"))

;001 since the critical / medical is not applied this section will always return 0 results
call writeLog(build2("* START Critical EKSOPSRequest *****************************"))
set stat = initrec(EKSOPSRequest)
set EKSOPSRequest->expert_trigger = "COV_EE_PLANNED_ORDERS_CRITICAL" 
call writeLog(build2("->EKSOPSRequest->expert_trigger =",EKSOPSRequest->expert_trigger))
set cnt = 0
for (i=1 to t_rec->qual_cnt)
	call writeLog(build2("-->Checking ",cnvtstring(i)," of ",cnvtstring(t_rec->qual_cnt)))
	for (j=1 to t_rec->qual[i].orders_cnt)
		call writeLog(build2("---->Reviewing ",cnvtstring(j)," of ",cnvtstring(t_rec->qual[i].orders_cnt)))
		if (t_rec->qual[i].orders[j].level_ind = 1)
			call writeLog(build2("------>level_ind = ",cnvtstring(t_rec->qual[i].orders[j].level_ind)))
			call writeLog(build2("------>age       = ",cnvtstring(t_rec->qual[i].orders[j].age)))
				set cnt = (cnt + 1)
				set stat = alterlist(EKSOPSRequest->qual,cnt)
				set EKSOPSRequest->qual[cnt].person_id = t_rec->qual[i].person_id
				set EKSOPSRequest->qual[cnt].encntr_id = t_rec->qual[i].encntr_id
				set stat = alterlist(EKSOPSRequest->qual[cnt].data,3)
				set EKSOPSRequest->qual[cnt].data[1].vc_var = 	trim(cnvtstring(t_rec->qual[i].orders[j].pathway_id))
				set EKSOPSRequest->qual[cnt].data[1].double_var = t_rec->qual[i].orders[j].pathway_id
				set EKSOPSRequest->qual[cnt].data[2].vc_var = 	format(t_rec->qual[i].orders[j].order_dt_tm,";;q")
				set EKSOPSRequest->qual[cnt].data[3].vc_var = 	trim(t_rec->qual[i].orders[j].description)											
				set t_rec->qual[i].send_ind = 1
		endif
	endfor
endfor
if (size(EKSOPSRequest->qual,5) > 0)
	set dparam = 0
	call srvRequest(dparam) 
endif
call writeLog(build2("* END   Critical EKSOPSRequest ******************************"))

call writeLog(build2("* START Medical EKSOPSRequest  *****************************"))
set stat = initrec(EKSOPSRequest)
set EKSOPSRequest->expert_trigger = "COV_EE_PLANNED_ORDERS_MEDICAL"
call writeLog(build2("->EKSOPSRequest->expert_trigger =",EKSOPSRequest->expert_trigger)) 
set cnt = 0
for (i=1 to t_rec->qual_cnt)
	for (j=1 to t_rec->qual[i].orders_cnt) 
		call writeLog(build2("---->Reviewing ",cnvtstring(j)," of ",cnvtstring(t_rec->qual[i].orders_cnt)))
		if (t_rec->qual[i].orders[j].level_ind = 0)
			call writeLog(build2("------>level_ind = ",cnvtstring(t_rec->qual[i].orders[j].level_ind)))
			call writeLog(build2("------>age       = ",cnvtstring(t_rec->qual[i].orders[j].age)))
				set cnt = (cnt + 1)
				set stat = alterlist(EKSOPSRequest->qual,cnt)
				set EKSOPSRequest->qual[cnt].person_id = t_rec->qual[i].person_id
				set EKSOPSRequest->qual[cnt].encntr_id = t_rec->qual[i].encntr_id
				set stat = alterlist(EKSOPSRequest->qual[cnt].data,3)
				set EKSOPSRequest->qual[cnt].data[1].vc_var = 	trim(cnvtstring(t_rec->qual[i].orders[j].pathway_id))
				set EKSOPSRequest->qual[cnt].data[1].double_var = t_rec->qual[i].orders[j].pathway_id	
				set EKSOPSRequest->qual[cnt].data[2].vc_var = 	format(t_rec->qual[i].orders[j].order_dt_tm,";;q")
				set EKSOPSRequest->qual[cnt].data[3].vc_var = 	trim(t_rec->qual[i].orders[j].description)
				set t_rec->qual[i].send_ind = 1
				call echorecord(EKSOPSRequest)
		endif
	endfor
endfor
if (size(EKSOPSRequest->qual,5) > 0)
	set dparam = 0
	call srvRequest(dparam) 
endif
call writeLog(build2("* END   Medical EKSOPSRequest  ******************************"))

call writeLog(build2("* START Producing Audit File  ******************************"))
if (program_log->produce_audit = 0)
	select into "nl:"
		 facility = uar_get_code_display(e.loc_facility_cd)
		,unit = uar_get_code_display(e.loc_nurse_unit_cd)
	from
		 encounter e
		,person p
		,encntr_alias ea
		,person_alias pa
		,pathway py
		,(dummyt d1 with seq=t_rec->qual_cnt)
		,(dummyt d2 with seq=1)
		,(dummyt d3)
	plan d1
		where maxrec(d2,size(t_rec->qual[d1.seq].orders,5))
	join d2
	join e
		where e.encntr_id 		= t_rec->qual[d1.seq].encntr_id
	join p
		where p.person_id		= e.person_id
	join py
		where py.pathway_id = t_rec->qual[d1.seq].orders[d2.seq].pathway_id
	join d3
	join ea
		where ea.encntr_id		= e.encntr_id
		and   ea.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
		and   ea.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
		and   ea.encntr_alias_type_cd = code_values->cv.cs_319.fin_nbr_cd
		and   ea.active_ind 		= 1
	join pa
		where pa.person_id		= p.person_id
		and   pa.person_alias_type_cd = 10
		and   pa.active_ind = 1
		and   pa.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
		and   pa.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
	order by
		 facility
		,unit
		,p.name_last_key
		,p.name_first_key
		,e.reg_dt_tm
		,e.encntr_id
		,py.order_dt_tm
		,py.pathway_id
	head report
		cnt = 0
		str = ""
		call writeAudit(build2(
								 ^"FACILITY"^		,char(44)
								,^"UNIT"^			,char(44)
								,^"FIN"^			,char(44)
								,^"MRN"^			,char(44)
								,^"LAST NAME"^		,char(44)
								,^"FIRST NAME"^		,char(44)
								,^"MIDDLE NAME"^	,char(44)
								,^"PERSON_ID"^		,char(44)
								,^"ENCNTR_ID"^		,char(44)
								,^"PLAN NBR"^		,char(44)
								,^"PLAN LEVEL"^		,char(44)
								,^"PLAN DESC"^		,char(44)
								,^"PLAN ORDER DT"^	,char(44)
								,^"PLAN AGE (min)"^ ,char(44)
								,^"PLAN PATH ID"^	,char(44)
						))
		call writeLog(build2("-->Writing Header"))
	head e.encntr_id
		str = build2(
							 ^"^,trim(uar_get_code_display(e.loc_facility_cd)),^"^				,char(44)
							,^"^,trim(uar_get_code_display(e.loc_nurse_unit_cd)),^"^			,char(44)
							,^"^,trim(ea.alias),^"^												,char(44)
							,^"^,trim(pa.alias),^"^												,char(44)
							,^"^,trim(p.name_last),^"^											,char(44)
							,^"^,trim(p.name_first),^"^											,char(44)
							,^"^,trim(p.name_middle),^"^										,char(44)
							,^"^,trim(cnvtstring(p.person_id)),^"^								,char(44)
							,^"^,trim(cnvtstring(e.encntr_id)),^"^								,char(44)
					)
		call writeLog(build2("---->Building Encounter:",str))
	head py.pathway_id
		cnt = (cnt + 1)
		call writeAudit(build2(
							 str
							,^"^,trim(cnvtstring(cnt)),^"^												,char(44)
							,^"^,trim(cnvtstring(t_rec->qual[d1.seq].orders[d2.seq].level_ind)),^"^		,char(44)
							,^"^,trim(t_rec->qual[d1.seq].orders[d2.seq].description),^"^				,char(44)
							,^"^,trim(format(t_rec->qual[d1.seq].orders[d2.seq].order_dt_tm,";;q")),^"^	,char(44)
							,^"^,trim(cnvtstring(t_rec->qual[d1.seq].orders[d2.seq].age)),^"^			,char(44)
							,^"^,trim(cnvtstring(t_rec->qual[d1.seq].orders[d2.seq].pathway_id)),^"^	,char(44)							
						))
	foot e.encntr_id
		str = ""
		cnt = 0
	with nocounter, outerjoin = d3
else
	call writeLog(build2("->No Audit File Created"))
endif

call writeLog(build2("* END   Producing Audit File  ******************************"))

set reply->status_data->status = "S"

if (program_log->run_from_eks = 1)
	set retval = 100
endif
 
call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))
 
#exit_script
call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
;call echorecord(program_log)
;call echorecord(location_list)
;call echorecord(parm_list)

end
go
