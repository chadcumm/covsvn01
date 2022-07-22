/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Jun'2019
	Solution:			Pharmacy
	Source file name:	      cov_pha_scorecard_phys_updt.prg
	Object name:		cov_pha_scorecard_phys_updt
	Request#:			5188
	Program purpose:	      Update to Scorecard - Antibiotics extract. Adding Ordering physician to the existing data.
	Executing from:		Ops
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
DROP PROGRAM cov_pha_scorecard_phys_updt :dba GO
CREATE PROGRAM cov_pha_scorecard_phys_updt :dba
 
prompt
	"Output to File/Printer/MINe" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
 
with OUTDEV, start_datetime, end_datetime
 
 
declare star_var         = f8 with constant(uar_get_code_by("DISPLAY", 263, 'STAR Doctor Number')), protect
declare org_doc_var      = f8 with constant(uar_get_code_by("DISPLAY", 320, 'ORGANIZATION DOCTOR')), protect
declare output_orders    = vc
declare filename_var     = vc with constant('cer_temp:cov_pha_phys_update_may15.txt'), protect
 
 /***
;Ops setup
declare cmd  = vc with noconstant("")
declare len  = i4 with noconstant(0)
declare stat = i4 with noconstant(0)
declare iOpsInd      = i2 WITH NOCONSTANT(0), PROTECT
declare filename_var = vc WITH noconstant(CONCAT('cer_temp:',TRIM(cnvtlower(uar_get_displaykey($facility_list))),'\
			_pha_scorecard_medadmin.txt')), PROTECT
declare ccl_filepath_var = vc WITH noconstant(CONCAT('$cer_temp/',TRIM(cnvtlower(uar_get_displaykey($facility_list))),'\
_pha_scorecard_medadmin.txt')), PROTECT
declare astream_filepath_var = vc with noconstant("/cerner/w_custom/p0665_cust/to_client_site/ClinicalAncillary/Pharmacy/PAExports/")
 
;request from Ops?
if(validate(request->batch_selection) = 1)
 	set iOpsInd = 1
endif
***/
 
/***************************************************************************
	RECORD STRUCTURE
***************************************************************************/
Record med_admin(
	1 med_rec_cnt = i4
	1 mlist[*]
		2 fin = vc
		2 personid = f8
		2 encntrid = f8
		2 orderid = f8
		2 orig_orderid = f8
		2 template_ord_id = f8
		2 template_ord_flag = i4
		2 event_id = f8
		2 ordering_phys_name = vc
		2 ordering_phys_number = vc
)
 
/***************************************************************************
	DVDEV SOURCE CODE
***************************************************************************/
;Med administration - Clinical events
 
select into 'nl:'
 ce.encntr_id
, ce.order_id
, ce.event_id
, class = uar_get_code_display(ce.event_class_cd)
, event_reltn = uar_get_code_description(ce.event_reltn_cd)
, med_admin_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm;;q')
, Medication = ce.event_title_text
, med_admin_status = uar_get_code_display(mae.event_type_cd)
, admin_dose = cmr.admin_dosage
, admin_dose_unit = uar_get_code_display(cmr.dosage_unit_cd)
, admin_route = uar_get_code_display(cmr.admin_route_cd)
, cmr.synonym_id
 
from
 
  encounter e
 , clinical_event ce
 , med_admin_event mae
 , ce_med_result cmr
 , orders o
 
plan e where e.loc_facility_cd in(2552503635.00, 21250403.00,2552503653.00,2552503639.00,2552503613.00,2553765579.00,2552503645.00,2552503649.00)
	and e.encntr_id != 0.00
 
join ce where ce.person_id = e.person_id
	and ce.encntr_id = e.encntr_id
	and ce.event_end_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
      and ce.view_level = 1 ;active
      and ce.publish_flag = 1 ;active
      and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
      and ce.task_assay_cd = 0
      and ce.event_reltn_cd = 132 ;child
      and ce.catalog_cd != 29285845.00 ;premix
      and ce.event_title_text != "IVPARENT"
      and ce.result_status_cd IN (23.00, 34.00, 25.00, 35.00) ;Active, Modified, Auth (Verified), Modified
      and ce.event_class_cd in(228, 232) ;Immunization, MED
 
join mae where mae.order_id = outerjoin(ce.order_id)
 
join cmr where cmr.event_id = outerjoin(ce.event_id)
    and cmr.event_id != outerjoin(0.0)
    and cmr.valid_until_dt_tm = outerjoin(cnvtdatetime ("31-DEC-2100 00:00:00" ))
    and cmr.synonym_id != outerjoin(0.0)
    and not (cmr.iv_event_cd IN (736.00, 738.00)) ;rate change, waste
 
join o where o.order_id = ce.order_id
 
order by e.loc_facility_cd, ce.encntr_id, ce.order_id, ce.parent_event_id, ce.event_id
 
;with nocounter, separator=" ", format
 
Head report
	mcnt = 0
	call alterlist(med_admin->mlist, 100)
 
Head ce.event_id
	 mcnt += 1
	 med_admin->med_rec_cnt = mcnt
 	call alterlist(med_admin->mlist, mcnt)
Detail
	med_admin->mlist[mcnt].personid = ce.person_id
	med_admin->mlist[mcnt].encntrid = ce.encntr_id
	med_admin->mlist[mcnt].orderid = ce.order_id
	med_admin->mlist[mcnt].orig_orderid = ce.order_id
	med_admin->mlist[mcnt].event_id = ce.event_id
	med_admin->mlist[mcnt].template_ord_flag = o.template_order_flag
	med_admin->mlist[mcnt].template_ord_id = o.template_order_id
 
	if(med_admin->mlist[mcnt].template_ord_flag = 4);child orders
		if(o.template_order_id != 0)
			med_admin->mlist[mcnt].orderid = o.template_order_id
		endif
	endif
 
Foot ce.event_id
 	call alterlist(med_admin->mlist, mcnt)
 
with nocounter
;--------------------------------------------------------------------------------------------
 
;get Patient Demographic
select into 'NL:'
 
from
	(dummyt d WITH seq = value(size(med_admin->mlist,5)))
	, encntr_alias ea
 
plan d
 
join ea where ea.encntr_id = med_admin->mlist[d.seq].encntrid
	and ea.active_ind = 1
	and ea.encntr_alias_type_cd = 1077
 
order by ea.encntr_id
 
Head ea.encntr_id
	cnt = 0
	idx = 0
      idx = locateval(cnt,1,size(med_admin->mlist,5),ea.encntr_id, med_admin->mlist[cnt].encntrid)
 
      while(idx > 0)
		med_admin->mlist[idx].fin = ea.alias
 		idx = locateval(cnt,(idx+1),size(med_admin->mlist,5),ea.encntr_id, med_admin->mlist[cnt].encntrid)
	endwhile
 
Foot ea.encntr_id
	null
 
With nocounter
 
;---------------------------------------------------------------------------------------------
;Get ordering physician details
 
select into 'nl:'
 
fin = med_admin->mlist[d.seq].fin, oa.order_id, pr.name_full_formatted, pa.alias
 
from
	(dummyt d WITH seq = value(size(med_admin->mlist,5)))
	, order_action oa
	, prsnl pr
	, prsnl_alias pa
 
plan d
 
join oa where oa.order_id = med_admin->mlist[d.seq].orderid
	and oa.action_sequence = 1
 
join pr where pr.person_id = outerjoin(oa.order_provider_id)
 
join pa where pa.person_id = outerjoin(pr.person_id)
	and pa.alias_pool_cd = outerjoin(star_var)
	and pa.prsnl_alias_type_cd = outerjoin(org_doc_var)
 
order by oa.order_id
 
;with nocounter, separator=" ", format
 
Head oa.order_id
	cnt = 0
	idx = 0
      idx = locateval(cnt,1,size(med_admin->mlist,5),oa.order_id, med_admin->mlist[cnt].orderid)
      while(idx > 0)
		med_admin->mlist[idx].ordering_phys_number = trim(pa.alias,3)
		med_admin->mlist[idx].ordering_phys_name = trim(pr.name_full_formatted)
 		idx = locateval(cnt,(idx+1),size(med_admin->mlist,5),oa.order_id, med_admin->mlist[cnt].orderid)
	endwhile
 
Foot  oa.order_id
	  null
 
with nocounter
 
call echorecord(med_admin)
 
;----------------------------------------------------------------------------------------------------------
; Set up the feed
;if(iOpsInd = 1) ;Ops
  ;if($to_file = 0)  ;To File
 
   Select into value(filename_var)
 
	from (dummyt d WITH seq = value(size(med_admin->mlist,5)))
	order by d.seq
 
	;build output
	Head report
		file_header_var = build(
			wrap3("Hospital Account Number")
			,wrap3("Prescription Number")
			,wrap3("order_phys_number") )
 
	col 0 file_header_var
	row + 1
 	Head d.seq
		output_orders = ""
		output_orders = build(output_orders
			,wrap3(cnvtstring(med_admin->mlist[d.seq].fin))
			,wrap3(cnvtstring(med_admin->mlist[d.seq].orderid))
			,wrap3(cnvtstring(med_admin->mlist[d.seq].ordering_phys_number)) )
 
 		output_orders = trim(output_orders, 3)
 		output_orders = replace(replace(output_orders ,char(13)," "),char(10)," ")
 
	 Foot d.seq
	 	col 0 output_orders
	 	row + 1
 
	with time = 30, nocounter, maxcol = 32000, format = stream, formfeed = none
 
	;Move file to Astream folder
/*** 	set cmd = build2("mv ", ccl_filepath_var, " ", astream_filepath_var)
	set len = size(trim(cmd))
 	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
 ***/
;  endif ;To File
;endif ;ops
 
 
/*****************************************************************************
	;Subroutins
/*****************************************************************************/
 
%i cust_script:cov_CommonLibrary.inc
 
 
end go
 
 
 
 
