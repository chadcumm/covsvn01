/*********************************************************************************************
*                                                                                            *
**********************************************************************************************
 
        Source file name:   cov_plan_pp_med_rec.prg
        Object name:        cov_plan_pp_med_rec
 
        Product:
        Product Team:
 
        Program purpose:
 
        Tables read:
 
        Tables updated:     n/a
 
        Executing from:     EKS_EXEC_CCL_L Template
 
        Special Notes:
 
 
**********************************************************************************************
*                      GENERATED MODIFICATION CONTROL LOG
**********************************************************************************************
*
* Mod Date          Feature     Engineer        Comment
* --- ----------    -------     -------------   ----------------------------------------------
* 000 08/22/2018                CCUMMIN4        Initial Creation, combined x and y
* 001 09/04/2018				CCUMMIN4		Added qualification for temp location
* 002 09/12/2018				CCUMMIN4		Add indicator for powerplan qualify section
* 003 09/12/2018				CCUMMIN4		Updated to exclude careplans with no orders included
* 004 09/12/2018				CCUMMIN4		Only qualify for Medical type powerplans
*********************************************************************************************/
drop program cov_plan_pp_med_rec:dba go
create program cov_plan_pp_med_rec:dba
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
free record planpowerplan
record planpowerplan(
1 plan_cnt          = i4
1 qual[*]
    2 plannedid 	 = f8
	2 planname		 = vc
	2 planneddttm	 = vc
	2 plantype       = vc
)
 
 
free record t_rec
record t_rec
(
	1 cv
	 2 cs_222
	  3 nurse_unit_cd			= f8
	 2 cs_333
	  3 attdoc_cd				= f8
	 2 cs_16750								;003
	  3 order_cd				= f8		;003
	 2 cs_16769
	  3 planned_status_cd		= f8
	 2 cs_16789								;003
	  3 included_cd				= f8		;003
	 2 cs_30183								;004
	  3 medical_cd				= f8		;004
	 2 cs_4002695
	  3 pendcomp_cd				= f8
	  3 pendpart_cd				= f8
	  3 notstarted_cd			= f8
	  3 partial_cd				= f8
	  3 complete_cd				= f8
	1 loc_qual_cnt				= i2
	1 loc_qual[*]
	 2 location_cd				= f8
	 2 display					= vc
	1 patient
	 2 encntr_id				= f8
	 2 person_id 				= f8
	 2 template_id				= f8
 	1 qual
	 2 medrecqual				= i2
	 2 physind					= i2
	 2 medrec_retval			= i2
	 2 medrec_misc1				= vc
	 2 medrec_qual				= i2
	 2 maxplans					= i2
	 2 maxmins					= i2
	 2 t_flag					= i4
	 2 t2_flag					= i4
	 2 t3_flag 					= i2
	 2 powerplan_retval			= i2
	 2 powerplan_misc1			= vc
	 2 powerplan_misc2			= vc
	 2 log_filename				= vc
	 2 log_message				= vc
	 2 log_time					= dq8
	 2 errcode					= i4
	 2 errmsg					= vc
	 2 retval					= i2
	 2 log_misc1				= vc
	 2 log_misc2				= vc
	1 planpowerplan
	 2 plan_cnt          		= i2
	 2 qual[*]
      3 plannedid 	 			= f8
	  3 planname		 		= vc
	  3 planneddttm	 			= vc
	  3 plantype       			= vc
	  3 powerplan_qual			= i2 ;002
)
 
declare cnt 								= i2 with noconstant(0)
 
set retval 									= -1
set log_message 							= build2("Error in ", curprog)
set log_misc1 								= fillstring(25,' ')
 
set t_rec->cv.cs_222.nurse_unit_cd			= uar_get_code_by('MEANING',	222,		'NURSEUNIT')
 
set t_rec->cv.cs_333.attdoc_cd				= uar_get_code_by('DISPLAYKEY',	333,		'ATTENDINGPHYSICIAN')
 
set t_rec->cv.cs_16750.order_cd				= uar_get_code_by("MEANING",	16750,		"ORDER CREATE")	;003
 
set t_rec->cv.cs_16769.planned_status_cd	= uar_get_code_by("MEANING",	16769,		"PLANNED")
 
set t_rec->cv.cs_16789.included_cd			= uar_get_code_by("MEANING",	16789,		"INCLUDED")		;003
 
set t_rec->cv.cs_30183.medical_cd			= uar_get_code_by('DISPLAYKEY', 30183, 		'MEDICAL')		;004
 
set t_rec->cv.cs_4002695.complete_cd		= uar_get_code_by('DISPLAYKEY', 4002695, 	'COMPLETE')
set t_rec->cv.cs_4002695.notstarted_cd		= uar_get_code_by('DISPLAYKEY',	4002695,	'NOTSTARTED')
set t_rec->cv.cs_4002695.partial_cd			= uar_get_code_by('DISPLAYKEY', 4002695, 	'PARTIAL')
set t_rec->cv.cs_4002695.pendcomp_cd		= uar_get_code_by('DISPLAYKEY',	4002695,	'PENDINGCOMPLETE')
set t_rec->cv.cs_4002695.pendpart_cd		= uar_get_code_by('DISPLAYKEY',	4002695,	'PENDINGPARTIAL')
 
set t_rec->patient.encntr_id 				= link_encntrid
set t_rec->patient.person_id				= link_personid
set t_rec->patient.template_id				= link_template
set t_rec->qual.maxplans					= 4
set t_rec->qual.log_filename				= build("cer_temp:",cnvtlower(curprog), "_logging_",
                                                                           format(curdate, "MMDDYYYY;;D"), ".dat")
set t_rec->planpowerplan.plan_cnt			= 0
 
set t_rec->qual.maxmins						= 480; 480	;8 hours * 60 mins = 480 minutes
 
if	(t_rec->patient.template_id <= 0.0)
  set t_rec->qual.log_misc1 = "Missing required OPT_LINK parameter check to make sure template is linked"
  go to exit_script
endif
 
if	(t_rec->patient.person_id <= 0.0)
  set t_rec->qual.log_misc1 = "Missing person_id check linked logic template"
  go to exit_script
endif
 
if	(t_rec->patient.encntr_id <= 0.0)
    set t_rec->qual.log_misc1 ="Missing encounter_id check linked logic template"
    go to exit_script
endif
 
 
 
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
/************ Get TEMP Locations to indicate patient has been in surgery   *************/
select into "nl:"
	 cv.code_value
	,cv.display
from
	 location l
	,code_value cv
plan cv
	where cv.code_set 				= 220
	and   cv.active_ind				= 1
	and   cv.display 				= "*TEMP*"
join l
	where l.location_cd 			= cv.code_value
	and   l.location_type_cd		= t_rec->cv.cs_222.nurse_unit_cd
order by
	cv.display
head report
	cnt = 0
head cv.code_value
	cnt = (cnt + 1)
	stat = alterlist(t_rec->loc_qual,cnt)
	t_rec->loc_qual[cnt].location_cd	= cv.code_value
	t_rec->loc_qual[cnt].display		= cv.display
foot report
	t_rec->loc_qual_cnt = cnt
with nocounter
 
if (t_rec->loc_qual_cnt > 0)
	select into "nl:"
	from
		encntr_loc_hist elh
	plan elh
		where elh.encntr_id			= t_rec->patient.encntr_id
		and   elh.active_ind		= 1
		and	  expand(
					     cnt
						,1
						,t_rec->loc_qual_cnt
						,elh.loc_nurse_unit_cd
						,t_rec->loc_qual[cnt].location_cd
					)
	order by
		 elh.activity_dt_tm
		,elh.loc_nurse_unit_cd
	head report
		cnt 	= 0
		diff 	= 0
	head elh.loc_nurse_unit_cd
		cnt 	= (cnt + 1)
	foot elh.loc_nurse_unit_cd
		if (elh.end_effective_dt_tm > cnvtdatetime(curdate,curtime3))
			diff = 0
		else
			diff 	= datetimediff(cnvtdatetime(curdate,curtime3),elh.end_effective_dt_tm,4)
		endif
 
		call echo(build2("loc:",uar_get_code_display(elh.loc_nurse_unit_cd)))
		call echo(build2("diff:",diff))
 
		if (diff <= t_rec->qual.maxmins)
			 t_rec->qual.t3_flag = 1
		endif
	with nocounter
endif
 
;if (t_rec->qual.t3_flag > 0)
	/************ Get Single Phase and Multiphase Powerplan in a planned state *************/
	select into "nl:"
	from
		pathway pa
		,act_pw_comp apc ;003
	plan pa
		where 	pa.encntr_id 		= t_rec->patient.encntr_id
		and 	pa.person_id 		= t_rec->patient.person_id
		and 	pa.pw_status_cd 	= t_rec->cv.cs_16769.planned_status_cd
		and		pa.pathway_type_cd	= t_rec->cv.cs_30183.medical_cd				;004
		and 	pa.active_ind 		= 1
		and 	pa.type_mean 		in(
										 "CAREPLAN"
										,"PHASE"
										)
	join apc																	;003
		where	apc.pathway_id		= outerjoin(pa.pathway_id)					;003
		and		apc.comp_type_cd	= outerjoin(t_rec->cv.cs_16750.order_cd)	;003
		and     apc.comp_status_cd	= outerjoin(t_rec->cv.cs_16789.included_cd) ;003
	order by
		 pa.type_mean
		,pa.status_dt_tm
		,pa.pathway_id		;003
	head report
		row_cnt = 0
	;003 detail
	head pa.pathway_id		;003
	    ;003 if (pa.type_mean = "CAREPLAN")
	   	if ((pa.type_mean = "CAREPLAN") and (apc.comp_status_cd = t_rec->cv.cs_16789.included_cd))	;003
	        row_cnt = (row_cnt + 1)
	        stat = alterlist(t_rec->planpowerplan->qual, row_cnt)
	        t_rec->planpowerplan->qual[row_cnt].plannedid      = pa.pathway_id
	        t_rec->planpowerplan->qual[row_cnt].planname       = pa.description
	        t_rec->planpowerplan->qual[row_cnt].planneddttm    = format(pa.status_dt_tm, "mm/dd/yyyy HH:MM:SS;;d")
	        t_rec->planpowerplan->qual[row_cnt].plantype       = "SINGLE"
	        t_rec->planpowerplan->qual[row_cnt].powerplan_qual = 1
	    endif
	    if ((pa.type_mean = "PHASE") and (t_rec->qual.t3_flag > 0))
	        if (cnvtupper(pa.description) in(
	                            				 "ACUTE CARE FLOOR"
	                            				,"ADMISSION ORDERS"
	                            				,"POST CATH LAB PROCEDURE ORDERS"
	                            				,"POST DIALYSIS FLOOR ORDERS"
	                            				,"POST EXTUBATION"
	                            				,"POST PLASMAPHERESIS FLOOR ORDERS"
	                            				,"POST PROCEDURE"
	                            				,"POST PROCEDURE ORDERS"
	                            				,"POSTOPERATIVE"
	                            				,"POST-PROCEDURE"
	                            				,"TPA INITIATED / POST INFUSION"
	                            				))
	            row_cnt = row_cnt + 1
	        	stat = alterlist(t_rec->planpowerplan->qual, row_cnt)
	        	t_rec->planpowerplan->qual[row_cnt].plannedid      = pa.pathway_id
	        	t_rec->planpowerplan->qual[row_cnt].planname       = pa.description
	        	t_rec->planpowerplan->qual[row_cnt].planneddttm    = format(pa.status_dt_tm, "mm/dd/yyyy HH:MM:SS;;d")
	        	t_rec->planpowerplan->qual[row_cnt].plantype       = "MULTIPHASE"
	        	t_rec->planpowerplan->qual[row_cnt].powerplan_qual = 2
	        endif
	    endif
	    if ((pa.type_mean = "PHASE") and (t_rec->qual.t3_flag = 0))
	        if (cnvtupper(pa.description) in(
	                            				 "ADMISSION ORDERS"
	                            				,"TPA INITIATED / POST INFUSION"
	                            				,"POST C-SECTION"
	                            				))
	            row_cnt = row_cnt + 1
	        	stat = alterlist(t_rec->planpowerplan->qual, row_cnt)
	        	t_rec->planpowerplan->qual[row_cnt].plannedid      = pa.pathway_id
	        	t_rec->planpowerplan->qual[row_cnt].planname       = pa.description
	        	t_rec->planpowerplan->qual[row_cnt].planneddttm    = format(pa.status_dt_tm, "mm/dd/yyyy HH:MM:SS;;d")
	        	t_rec->planpowerplan->qual[row_cnt].plantype       = "MULTIPHASE"
	        	t_rec->planpowerplan->qual[row_cnt].powerplan_qual = 3
	        endif
	    endif
	foot report
		t_rec->planpowerplan.plan_cnt = row_cnt
	with nocounter, time = 30
;endif
/******** Build Output XML *********/
if	(t_rec->planpowerplan.plan_cnt > 0)
 
	set t_rec->qual.powerplan_retval	= 100
 
    ;--------------- Single ------------------
    for (x = 1 to size(t_rec->planpowerplan.qual,5))
        if (t_rec->planpowerplan.qual[x].plantype = "SINGLE")
            set t_rec->qual.t_flag			= 1
            set t_rec->qual.powerplan_misc1	= concat(
            									 t_rec->qual.powerplan_misc1
                                                ,t_rec->planpowerplan.qual[x].planname,       ", "
                                                ,t_rec->planpowerplan.qual[x].planneddttm,    ". "
                                                )
        endif
    endfor
 
    ;--------------- Multiphase ------------------
    for (z = 1 to size(t_rec->planpowerplan.qual,5))
        if (t_rec->planpowerplan.qual[z].plantype = "MULTIPHASE")
            set t_rec->qual.t2_flag			= 1
            set t_rec->qual.powerplan_misc2 = concat(
            									 t_rec->qual.powerplan_misc2
            									,t_rec->planpowerplan.qual[z]->planname,       ", "
                                                ,t_rec->planpowerplan.qual[z]->planneddttm,    ". "
                                                )
        endif
    endfor
endif
 
;check if triggering position is physician and if they are attending.
select into 'nl:'
from
	 encounter e
	,prsnl pr
	,encntr_prsnl_reltn epr
plan e
	where 	e.encntr_id		= t_rec->patient.encntr_id
	and		e.active_ind	= 1
join epr
	where	epr.encntr_id			= e.encntr_id
	and		epr.encntr_prsnl_r_cd	=	t_rec->cv.cs_333.attdoc_cd
	and		epr.beg_effective_dt_tm	<= cnvtdatetime(curdate,curtime3)
	and		epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)
join pr
	where	pr.person_id		= epr.prsnl_person_id
	and		pr.person_id		= reqinfo->updt_id
	and		pr.physician_ind	= 1
	and		pr.active_ind		= 1
detail
	t_rec->qual.medrecqual = 1
with nocounter
 
;check for nonphysician
select into "nl:"
from
	prsnl p
plan p
	where 	p.person_id		= reqinfo->updt_id
	and		p.active_ind 	= 1
detail
	t_rec->qual.physind = p.physician_ind
with nocounter
 
;if the prsnl is the attending doctor or is not a physician
if ((t_rec->qual.medrecqual = 1) or (t_rec->qual.physind = 0))
	;check  med rec status
 
	select into "nl:"
	from
		order_recon orec
	plan orec
		where	orec.encntr_id			= t_rec->patient.encntr_id
		;and		orec.recon_type_flag	in(1,2,3) ;1 admission, 2 transfer, 3 discharge
		 and		orec.recon_type_flag	in(1) ;1 admission
	order by
		 orec.performed_dt_tm desc
		,orec.order_recon_id
		,orec.encntr_id
	head report
		cnt 	= 0
		compsts	= 0
 	;head orec.performed_dt_tm
 	;head orec.order_recon_id
 	head orec.encntr_id
 		call echo(build('orec.recon_id :', orec.order_recon_id))
 		cnt = (cnt + 1)
 		if (orec.recon_type_flag = 3) 															; IF discharge med rec
		 	if (orec.recon_status_cd in( t_rec->cv.cs_4002695.pendcomp_cd							; IF pending complete
		 								,t_rec->cv.cs_4002695.notstarted_cd							; or not started
		 								,t_rec->cv.cs_4002695.partial_cd							; or partial
		 								,t_rec->cv.cs_4002695.pendpart_cd							; or pending partial
		 								))
 
 				t_rec->qual.medrec_retval 		= 100												; display alert
 				t_rec->qual.medrec_misc1		= cnvtstring(orec.recon_type_flag)
 				t_rec->qual.medrec_qual			= 1
 			elseif (orec.recon_status_cd = t_rec->cv.cs_4002695.complete_cd AND cnt = 1)			; IF this is the most recent
 				compsts 						= 1													; and completed
 				t_rec->qual.medrec_qual			= 2
 			endif																					; suppress alert
 
		elseif (orec.recon_type_flag in (1,2))													; IF admission or transfer med rec
 			if (t_rec->qual.medrecqual = 1) ;attending physician									; IF attending physicin
 				if (orec.recon_status_cd in( t_rec->cv.cs_4002695.pendcomp_cd						; this logic not used in current rule
		 									,t_rec->cv.cs_4002695.notstarted_cd
		 									,t_rec->cv.cs_4002695.partial_cd
		 									,t_rec->cv.cs_4002695.pendpart_cd
		 								))
 
 					t_rec->qual.medrec_retval 	= 100
 					t_rec->qual.medrec_misc1	= cnvtstring(orec.recon_type_flag)
 					t_rec->qual.medrec_qual		= 3
 				elseif (orec.recon_status_cd = t_rec->cv.cs_4002695.complete_cd AND cnt = 1)
 					compsts 					= 1
 					t_rec->qual.medrec_qual		= 4
 				endif
 			elseif (t_rec->qual.medrecqual = 0 AND t_rec->qual.physind = 0) 						; IF not a physician
	 			if (orec.recon_status_cd in( t_rec->cv.cs_4002695.pendcomp_cd							; IF pending complete
		 	   	; per rthacker@CovHlth.com  ,t_rec->cv.cs_4002695.partial_cd							; or partial
		 	   	,t_rec->cv.cs_4002695.pendpart_cd			;per rthacker@CovHlth.com
		 								))
 
				t_rec->qual.medrec_retval	= 100
				t_rec->qual.medrec_misc1	= cnvtstring(orec.recon_type_flag)						; display alert
				t_rec->qual.medrec_qual		= 5
				elseif (orec.recon_status_cd = t_rec->cv.cs_4002695.complete_cd AND cnt = 1)
					compsts 				= 1
					t_rec->qual.medrec_qual	= 6
				endif
			endif
		endif
	foot report
		if (compsts = 1)
			call echo(build('foot report compsts :', compsts))
			t_rec->qual.medrec_retval	= 0
			t_rec->qual.medrec_misc1 	= cnvtstring(orec.recon_type_flag)
		endif
	with nocounter
endif
 
 
#exit_script
 
if	((t_rec->qual.medrec_retval = 0) and (t_rec->qual.powerplan_retval = 0))
	set t_rec->qual.retval 		= 0
	set t_rec->qual.log_misc1 	= "No Planned PowerPlans or needed Meds Reconciliation Needed"
elseif ((t_rec->qual.medrec_retval = 100) or (t_rec->qual.powerplan_retval = 100))
	set t_rec->qual.retval = 100
 
	if (t_rec->qual.medrec_retval = 100)
		set t_rec->qual.log_misc1 = t_rec->qual.medrec_misc1
	else
		set t_rec->qual.log_misc1 = "0"
	endif
 
	set t_rec->qual.log_misc1 = concat(t_rec->qual.log_misc1,"|")
 
	if (t_rec->qual.powerplan_retval = 100)
		set t_rec->qual.log_misc1 = concat(
											 t_rec->qual.log_misc1
											,"1|"						;indicated yes to planned PP
											,t_rec->qual.powerplan_misc1
											," "
											,t_rec->qual.powerplan_misc2
										   )
	else
		set t_rec->qual.log_misc1 = concat(
											 t_rec->qual.log_misc1
											,"0|"						;indicated no to planned PP
											)
	endif
endif
 
 
/*** Logging ***/
if(validate(EKMLOG_IND, -1) > 0) ;TRUE if Debug Mode (4) or Debug Tracing (>4)
	call echo(concat("filename: ", t_rec->qual.log_filename))
  	;write the record structures to a log file in ccluserdir for debugging
	if (validate(eksdata))
		call echorecord(eksdata, t_rec->qual.log_filename, 1)
	endif
	if (validate(reply))
		call echorecord(reply, t_rec->qual.log_filename, 1)
	endif
	set t_rec->qual.log_time 	= cnvtdatetime(curdate,curtime3)
	call echorecord(t_rec, t_rec->qual.log_filename, 1)
	call echorecord(t_rec)
endif
 
/*** Check for Errors ***/
set t_rec->qual.errcode = ERROR(t_rec->qual.errmsg,0)
if(t_rec->qual.errcode > 0)
  set t_rec->qual.log_misc1 = build2("Error: ", errmsg)
  set t_rec->qual.retval 	= -1
endif
 
set retval		= t_rec->qual.retval
set log_misc1	= t_rec->qual.log_misc1
set log_message	= log_misc1
 
call echo(build('retval : ', retval))
call echo(build('log_misc1 :', log_misc1))
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
