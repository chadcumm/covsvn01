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

        Source file name:       cov_rad_extract_sl.prg
        Object name:			cov_rad_extract_sl

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

drop program cov_rad_extract_sl:dba go
create program cov_rad_extract_sl:dba

prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.

with OUTDEV


call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 1	;do not create audit = 1	, create audit = 0
set debug_ind = 1	;enable debug mode = 1		, turn of debug mode = 0
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
endif

call set_codevalues(null)
call check_ops(null)

free record frece
record frece
	(
     1 file_desc = i4
     1 file_offset = i4
     1 file_dir = i4
     1 file_name = vc
     1 file_buf = vc
)

free set t_rec
record t_rec
(
	1 cnt									= i4
	1 files
	 2 file_path							= vc
     2 filename								= vc
	1 qual[*]
		2 person_id							= f8	;
		2 encntr_id							= f8	;
		2 order_id							= f8	;
		2 catalog_cd						= f8	;
		2 loc_facility_cd					= f8	;
		2 accession_nbr						= vc	;
		2 facility 							= vc	;
		2 department 						= vc	;
		2 modality 							= vc	;?
		2 exam_status 						= vc	;
		2 patient_name 						= vc	;
		2 account_number 					= vc	;
		2 check_in_type 					= vc
		2 location 							= vc
		2 request_order_dt_tm 				= dq8	;
		2 ordering_provider 				= vc	;
		2 check_in_nbr 						= vc
		2 check_in_dt_tm 					= dq8	;
		2 exam_code 						= vc	;
		2 exam_code_mod						= vc	;
		2 exam_name 						= vc	;
		2 exam_start_dt_tm 					= dq8	;
		2 exam_stop_dt_tm 					= dq8	;
		2 films_prepared_dt_tm 				= dq8
		2 technician 						= vc
		2 read_start_dt_tm 					= dq8
		2 read_stop_dt_tm 					= dq8
		2 priority 							= vc	;
		2 report_completed_dt_tm 			= dq8	;
		2 reporting_physician 				= vc
		2 performing_physician_nbr 			= vc
		2 performing_physician_name 		= vc
		2 performing_physician_specialty 	= vc
		2 patient_type 						= vc	;
		2 prelim_report_deliver_dt_tm 		= dq8
)


call addEmailLog("chad.cummings@covhlth.com")

call writeLog(build2("* START Finding Exams   ************************************"))

select into "nl:"
from
	 omf_radmgmt_order_st oros
	,person p
	,encounter e
	,order_radiology ord
	,orders o
	,rad_exam re
	,rad_exam_prsnl rep
	,prsnl p1
	,prsnl p2
plan oros
	where	oros.final_dt_tm 	is not NULL
	and     oros.updt_dt_tm		>= cnvtdatetime(curdate-100,0)
join o
	where	o.order_id 			= oros.order_id
join p
	where	p.person_id 		= o.person_id
join e
	where	e.encntr_id			= o.encntr_id
join ord
	where	ord.order_id 		= o.order_id
join p1
	where	p1.person_id		= ord.order_physician_id
join re
	where	re.order_id			= o.order_id
join rep
	where	rep.rad_exam_id		= re.rad_exam_id
	and		rep.action_type_cd	= code_values->cv.cs_14123.completed_cd
join p2
	where p2.person_id			= rep.exam_prsnl_id
head report
	cnt = 0
head oros.order_id
	cnt = (cnt + 1)
	if (mod(cnt,1000) = 1)
		stat = alterlist(t_rec->qual, cnt + 999)
    endif
    t_rec->qual[cnt].order_id				= oros.order_id
    t_rec->qual[cnt].person_id				= o.person_id
    t_rec->qual[cnt].encntr_id				= o.encntr_id
    t_rec->qual[cnt].catalog_cd				= o.catalog_cd
    t_rec->qual[cnt].patient_name			= p.name_full_formatted
    t_rec->qual[cnt].department				= uar_get_code_display(oros.perf_dept_cd)
    t_rec->qual[cnt].exam_name				= uar_get_code_display(ord.catalog_cd)
    t_rec->qual[cnt].loc_facility_cd		= e.loc_facility_cd
    t_rec->qual[cnt].facility				= uar_get_code_display(e.loc_facility_cd)
    t_rec->qual[cnt].ordering_provider		= p.name_full_formatted
    t_rec->qual[cnt].request_order_dt_tm	= oros.request_dt_tm
    t_rec->qual[cnt].exam_status			= uar_get_code_display(ord.exam_status_cd)
    t_rec->qual[cnt].modality				= uar_get_code_display(oros.section_cd)
    t_rec->qual[cnt].exam_stop_dt_tm		= oros.exam_complete_dt_tm
    t_rec->qual[cnt].exam_start_dt_tm		= oros.start_dt_tm
    t_rec->qual[cnt].priority				= uar_get_code_display(oros.priority_cd)
    t_rec->qual[cnt].patient_type			= uar_get_code_display(e.encntr_type_cd)
    t_rec->qual[cnt].accession_nbr			= oros.accession_nbr
    t_rec->qual[cnt].technician				= p2.name_full_formatted
    ;t_rec->qual[cnt]

foot report
	t_rec->cnt = cnt
	stat = alterlist(t_rec->qual,t_rec->cnt)
with nocounter

call writeLog(build2("* END   Finding Exams   ************************************"))

call writeLog(build2("* START Getting Account Numbers ****************************"))
select into "nl:"
from
	 encntr_alias ea
	,(dummyt d1 with seq = t_rec->cnt)
plan d1
join ea
	where	ea.encntr_id				= t_rec->qual[d1.seq].encntr_id
	and 	ea.beg_effective_dt_tm		<= cnvtdatetime(curdate,curtime3)
	and		ea.end_effective_dt_tm		>= cnvtdatetime(curdate,curtime3)
	and 	ea.encntr_alias_type_cd		= code_values->cv.cs_319.fin_nbr_cd
	and		ea.active_ind 				= 1
order by
	 ea.encntr_id
	,ea.beg_effective_dt_tm desc
head report
	cnt = 0
detail
	t_rec->qual[d1.seq].account_number	= ea.alias
with nocounter
call writeLog(build2("* END   Getting Account Numbers ****************************"))

call writeLog(build2("* START Getting Scheduling Data ****************************"))
select into "nl:"
from
	 sch_event se
	,sch_event_attach sea
	,sch_event_action sen
	,(dummyt d1 with seq = t_rec->cnt)
plan d1
join sea
	where	sea.order_id 				= t_rec->qual[d1.seq].order_id
	and     sea.active_ind				= 1
join se
	where	se.sch_event_id				= sea.sch_event_id
	and     se.active_ind				= 1
join sen
	where	sen.sch_event_id			= se.sch_event_id
	and 	sen.action_dt_tm	is not 	NULL
	and		sen.sch_action_cd			= code_values->cv.cs_14232.checkin_cd
	and		sen.active_ind				= 1
head report
	cnt = 0
detail
	t_rec->qual[d1.seq].check_in_dt_tm	= sen.action_dt_tm
with nocounter
call writeLog(build2("* END   Getting Scheduling Data ****************************"))

call writeLog(build2("* START Getting Rad Report Data ****************************"))
select into "nl:"
from
	 rad_report rr
	,rad_report_prsnl rrp
	,order_radiology ord
	,prsnl p1
	,(dummyt d1 with seq = t_rec->cnt)
plan d1
join ord
	where	ord.order_id				= t_rec->qual[d1.seq].order_id
join rr
	where 	rr.order_id					= ord.parent_order_id
join rrp
	where rrp.rad_report_id				= rr.rad_report_id
	and   rrp.prsnl_relation_flag		= 2
join p1
	where p1.person_id					= rrp.report_prsnl_id
head report
	cnt = 0
detail
	t_rec->qual[d1.seq].report_completed_dt_tm	= rr.posted_final_dt_tm
	t_rec->qual[d1.seq].reporting_physician		= p1.name_full_formatted
with nocounter
call writeLog(build2("* END   Getting Rad Report Data ****************************"))

call writeLog(build2("* START Getting CPT Data        ****************************"))

select into "nl:"
from
	 charge c
	,charge_mod cm
	,bill_item bi
	,(dummyt d1 with seq = t_rec->cnt)
plan d1
join c
	where	c.order_id				= t_rec->qual[d1.seq].order_id
join bi
	where	bi.bill_item_id			= c.bill_item_id
	and		bi.ext_child_reference_id > 0
join cm
	where 	cm.charge_item_id 		= c.charge_item_id
	and 	cm.field1_id in(
							 		 code_values->cv.cs_14002.cpt_cd
									,code_values->cv.cs_14002.cpt_modifier_cd
							)
	and 	not cm.field6 			= NULL
  	and 	cm.active_ind 			= 1
  	and 	cm.end_effective_dt_tm 	>= cnvtdatetime(curdate, curtime3)
order by
	 d1.seq
	,cm.charge_item_id
	,cm.charge_mod_id
	,cm.field1_id
	,cm.field6
detail
	;call writeLog(build2("charge_mod_id=",cnvtstring(cm.charge_mod_id)))
	if (cm.field1_id = code_values->cv.cs_14002.cpt_cd)
		t_rec->qual[d1.seq].exam_code 	= trim(cm.field6,3)
	elseif(cm.field1_id = code_values->cv.cs_14002.cpt_modifier_cd)
		t_rec->qual[d1.seq].exam_code_mod = trim(cm.field6,3)
	endif
with nocounter

call writeLog(build2("* END   Getting CPT Data        ****************************"))

call writeLog(build2("* START Generating File         ****************************"))

;set t_rec->files.file_path = build("/cerner/d_",cnvtlower(trim(curdomain)),"/cclscratch/")
set t_rec->files.file_path = "/cerner/w_custom/p0665_cust/to_client_site/ClinicalAncillary/Radiology/Extracts/ServiceLine/"
set t_rec->files.filename = build(
										 t_rec->files.file_path
										,cnvtlower(trim(curdomain))
										,"_",cnvtlower(trim(curprog))
										,"_",format(cnvtdatetime(curdate, curtime3)
										,"yyyy_mm_dd_hh_mm_ss;;d")
										,".dat"
										)
call writeLog(build2("-->Creating file:",t_rec->files.filename))
set frece->file_name = t_rec->files.filename
set frece->file_buf = "w"
set stat = cclio("OPEN",frece)

call writeLog(build2("---->Adding Header Row"))
set disp_line = build2(
										^"FACILITY"^
							,char(44),	^"DEPARTMENT"^
							,char(44),	^"STUDY GROUP (MODALITY)"^
							,char(44),	^"EXAM STATUS"^
							,char(44),	^"PATIENT NAME"^
							,char(44),	^"PAT ACCT NBR"^
							,char(44),	^"CHECK IN TYPE"^
							,char(44),	^"LOCATION"^
							,char(44),	^"REQUEST/ORDER DATE"^
							,char(44),	^"REQUEST/ORDER TIME"^
							,char(44),	^"ORDERING PROVIDER"^
							,char(44),	^"CHECK IN NBR"^
							,char(44),	^"CHECK IN DATE"^
							,char(44),	^"CHECK IN TIME"^
							,char(44),	^"EXAM CODE"^
							,char(44),	^"EXAM NAME"^
							,char(44),	^"EXAM START DATE"^
							,char(44),	^"EXAM START TIME"^
							,char(44),	^"EXAM STOP DATE"^
							,char(44),	^"EXAM STOP TIME"^
							,char(44),	^"FILMS PREPARED/READY DATE"^
							,char(44),	^"FILMS PREPARED/READY TIME"^
							,char(44),	^"TECHNICIAN"^
							,char(44),	^"READ START DATE"^
							,char(44),	^"READ START TIME"^
							,char(44),	^"READ STOP DATE"^
							,char(44),	^"READ STOP TIME"^
							,char(44),	^"PRIORITY"^
							,char(44),	^"REPORT COMPLETE DATE"^
							,char(44),	^"REPORT COMPLETE TIME"^
							,char(44),	^"REPORTING PHYSICIAN"^
							,char(44),	^"PERF_PHYS_NBR"^
							,char(44),	^"PERF_PHYS_NAME"^
							,char(44),	^"PERF_PHYS_SPECIALTY"^
							,char(44),	^"PAT TYPE"^
							,char(44),	^"PRELIMINARY REPORT DELIVERED DATE"^
							,char(44),	^"PRELIMINARY REPORT DELIVERED TIME"^
							,char(13),char(10))

set frece->file_buf = disp_line

call writeLog(build2("------>Row Data:",frece->file_buf))
set stat = cclio("WRITE", frece)

for (cnt = 1 to t_rec->cnt)
	set disp_line = build2(

				 ^"^,		t_rec->qual[cnt].facility											,^"^
	,char(44)	,^"^,		t_rec->qual[cnt].department											,^"^
	,char(44)	,^"^,		t_rec->qual[cnt].modality											,^"^
	,char(44)	,^"^,		t_rec->qual[cnt].exam_status										,^"^
	,char(44)	,^"^,		t_rec->qual[cnt].patient_name										,^"^
	,char(44)	,^"^,		t_rec->qual[cnt].account_number										,^"^
	,char(44)	,^"^,		t_rec->qual[cnt].check_in_type										,^"^
	,char(44)	,^"^,		t_rec->qual[cnt].location											,^"^
	,char(44)	,^"^,format(t_rec->qual[cnt].request_order_dt_tm, "mm/dd/yy;;d")				,^"^
	,char(44)	,^"^,format(t_rec->qual[cnt].request_order_dt_tm, "hh:mm:ss;;m")				,^"^
	,char(44)	,^"^,		t_rec->qual[cnt].ordering_provider									,^"^
	,char(44)	,^"^,		t_rec->qual[cnt].accession_nbr										,^"^
	,char(44)	,^"^,format(t_rec->qual[cnt].check_in_dt_tm, "mm/dd/yyyy;;d")					,^"^
	,char(44)	,^"^,format(t_rec->qual[cnt].check_in_dt_tm, "hh:mm:ss;;m")						,^"^
	,char(44)	,^"^,		t_rec->qual[cnt].exam_code											,^"^
	,char(44)	,^"^,		t_rec->qual[cnt].exam_name											,^"^
	,char(44)	,^"^,format(t_rec->qual[cnt].exam_start_dt_tm, "mm/dd/yyyy;;d")					,^"^
	,char(44)	,^"^,format(t_rec->qual[cnt].exam_start_dt_tm, "hh:mm:ss;;m")					,^"^
	,char(44)	,^"^,format(t_rec->qual[cnt].exam_stop_dt_tm, "mm/dd/yyyy;;d")					,^"^
	,char(44)	,^"^,format(t_rec->qual[cnt].exam_stop_dt_tm, "hh:mm:ss;;m")					,^"^
	,char(44)	,^"^,format(t_rec->qual[cnt].films_prepared_dt_tm, "mm/dd/yyyy;;d")				,^"^
	,char(44)	,^"^,format(t_rec->qual[cnt].films_prepared_dt_tm, "hh:mm:ss;;m")				,^"^
	,char(44)	,^"^,		t_rec->qual[cnt].technician											,^"^
	,char(44)	,^"^,format(t_rec->qual[cnt].read_start_dt_tm, "mm/dd/yyyy;;d")					,^"^
	,char(44)	,^"^,format(t_rec->qual[cnt].read_start_dt_tm, "hh:mm:ss;;m")					,^"^
	,char(44)	,^"^,format(t_rec->qual[cnt].read_stop_dt_tm, "mm/dd/yyyy;;d")					,^"^
	,char(44)	,^"^,format(t_rec->qual[cnt].read_stop_dt_tm, "hh:mm:ss;;m")					,^"^
	,char(44)	,^"^,		t_rec->qual[cnt].priority											,^"^
	,char(44)	,^"^,format(t_rec->qual[cnt].report_completed_dt_tm, "mm/dd/yyyy;;d")			,^"^
	,char(44)	,^"^,format(t_rec->qual[cnt].report_completed_dt_tm, "hh:mm:ss;;m")				,^"^
	,char(44)	,^"^,		t_rec->qual[cnt].reporting_physician								,^"^
	,char(44)	,^"^,		t_rec->qual[cnt].performing_physician_nbr							,^"^
	,char(44)	,^"^,		t_rec->qual[cnt].performing_physician_name							,^"^
	,char(44)	,^"^,		t_rec->qual[cnt].performing_physician_specialty						,^"^
	,char(44)	,^"^,		t_rec->qual[cnt].patient_type										,^"^
	,char(44)	,^"^,format(t_rec->qual[cnt].prelim_report_deliver_dt_tm, "mm/dd/yyyy;;d")		,^"^
	,char(44)	,^"^,format(t_rec->qual[cnt].prelim_report_deliver_dt_tm, "hh:mm:ss;;m")		,^"^
				,char(13),char(10))


	set frece->file_buf = disp_line
	call writeLog(build2("------>Row Data:",frece->file_buf))
	set stat = cclio("WRITE", frece)
endfor

call writeLog(build2("-->Closing file:",t_rec->files.filename))
set stat = cclio("CLOSE",frece)

call addAttachment("",t_rec->files.filename)

call writeLog(build2("* END   Generating File         ****************************"))

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

#exit_script
call exitScript(null)
;call echorecord(t_rec)
;call echorecord(code_values)
call echorecord(program_log)


end
go
