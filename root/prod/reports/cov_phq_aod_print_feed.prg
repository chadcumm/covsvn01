 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:			Geetha Paramasivam
	Date Written:		03/13/2020
	Solution:			Quality
	Source file name:	      cov_phq_aod_print_feed.prg
	Object name:		cov_phq_aod_print_feed
	Request #:			7129
 	Program purpose:		Accounting of disclosure(AOD) - by using Report Request Tool
	Executing from:		CCL
 	Special Notes:		Part of AOD feed - one of the script and data source.
 					Running from DA2 and Ops - cov_phq_aod_print_feed_ops.prg
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod	Mod Date	Developer				Comment
---	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program cov_phq_aod_print_feed:dba go
create program cov_phq_aod_print_feed:dba
 
prompt
	"Output to File/Printer/MINe" = "MINE"    ;* Enter or select the printer or file name to send this report to.
	, "Start Request Date/Time" = "SYSDATE"
	, "End Request Date/Time" = "SYSDATE"
	, "Screen Display" = 1
 
with OUTDEV, start_datetime, end_datetime, to_file
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare home_ph_var = i4 with constant(uar_get_code_by('DISPLAY', 43, 'Home')), protect
declare mobile_ph_var = i4 with constant(uar_get_code_by('DISPLAY', 43, 'MOBILE')), protect
declare cmrn_alias_pool_var  	 = f8 with constant(uar_get_code_by("DISPLAY", 263, "CMRN")),protect
declare cmrn_var             	 = f8 with constant(uar_get_code_by("DISPLAY", 4, "Community Medical Record Number")),protect
 
 
;************* OPS SETUP ******************
declare aod_output = vc
declare cmd  = vc with noconstant("")
declare len  = i4 with noconstant(0)
declare stat = i4 with noconstant(0)
declare iOpsInd = i2 with noconstant(0), protect
 
;test ----------
;declare filename_var  = vc with constant('cer_temp:cov_aod_test1.txt'), protect
;declare ccl_filepath_var = vc WITH constant('$cer_temp/cov_aod_test1.txt'), PROTECT
;---------------*/
 
 
declare filename_var = vc WITH constant('cer_temp:cov_phq_aod_data.txt'), PROTECT
declare ccl_filepath_var = vc WITH constant('$cer_temp/cov_phq_aod_data.txt'), PROTECT
declare astream_filepath_var = vc with constant("/cerner/w_custom/p0665_cust/to_client_site/Quality/")
 
;request from Ops?
if(validate(request->batch_selection) = 1)
 	set iOpsInd = 1
endif
 
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
Record aod(
	1 plist[*]
		2 facility = vc
		2 personid = f8
		2 encntrid = f8
 		2 pat_name = vc
 		2 pat_name_first = vc
 		2 pat_name_middle = vc
 		2 pat_name_last = vc
 		2 pat_post_name = vc
  		2 pat_add1 = vc
 		2 pat_add2 = vc
 		2 pat_city = vc
 		2 pat_state = vc
 		2 pat_zip = vc
 		2 pat_phone1 = vc
 		2 pat_phone2 = vc
 		2 pat_primary_no = vc
 		2 pat_secondary_no = vc
 		2 pat_other_no = vc
 		2 pat_dob = vc
 		2 beg_service = vc
 		2 end_service = vc
  		2 fin = vc
 		2 mrn = vc
 		2 cmrn = vc
 		2 provider_reltn = vc
 		2 request_name = vc
 		2 receive_name = vc
 		2 tmp_request_name = vc
 		2 tmp_receive_name = vc
		2 request_section = vc
		2 rendered_section = vc
		2 request_dt = vc
		2 request_id = f8
		2 req_prsnl_id = f8
 		2 req_first_name = vc
 		2 req_middle_name = vc
 		2 req_last_name = vc
 		2 req_post_name = vc
 		2 req_company = vc
 		2 req_add1 = vc
 		2 req_add2 = vc
 		2 req_city = vc
 		2 req_state = vc
 		2 req_zip = vc
 		2 req_phone1 = vc
 		2 req_phone2 = vc
		2 request_status = vc
		2 request_type = vc
		2 requestor_type = vc
		2 recv_prsnl_id = f8
 		2 recv_first_name = vc
 		2 recv_middle_name = vc
 		2 recv_last_name = vc
 		2 recv_post_name = vc
 		2 recv_company = vc
 		2 recv_add1 = vc
 		2 recv_add2 = vc
 		2 recv_city = vc
 		2 recv_state = vc
 		2 recv_zip = vc
 		2 recv_phone1 = vc
 		2 recv_phone2 = vc
 		2 Disc_method_id = i4
		2 result_status = vc
		2 file_extension = vc
		2 output_dest_code = f8
		2 output_device = vc
		2 output_type = vc
		2 device_type = vc
		2 device_description = vc
		2 fax_no = vc
		2 purpose = vc
		2 total_pages = i4
		2 scope = vc
		2 destination = vc
		2 dest_type = vc
		2 comments = vc
		2 authorization = vc
		2 templat_id = f8
		2 report_template = vc
		2 distribut_id = f8
		2 distribution_name = vc
		2 cur_date_tm = vc
		2 rel_first_name = vc
		2 rel_middle_name = vc
		2 rel_last_name = vc
	)
 
/*
;Feed related - as per Larry's spread sheet
Record aod(
	1 plist[*]
		2 facility = vc ;mnemonic
		2 personid = f8
		2 encntrid = f8
 		2 pat_first_name = vc
 		2 pat_middle_name = vc
 		2 pat_last_name = vc
 		2 pat_post_name = vc
 		2 pat_add1 = vc
 		2 pat_add2 = vc
 		2 pat_city = vc
 		2 pat_state = vc
 		2 pat_zip = vc
 		2 pat_phone1 = vc
 		2 pat_phone2 = vc
 		2 pat_dob = vc
 		2 pat_primary_fin = vc ;fin
 		2 pat_secondary_mrn = vc ;mrn
 		2 pat_other_number = vc
 		2 pat_begin_service = vc
 		2 pat_end_service = vc
 		2 req_first_name = vc
 		2 req_middle_name = vc
 		2 req_last_name = vc
 		2 req_post_name = vc
 		2 req_company = vc
 		2 req_add1 = vc
 		2 req_add2 = vc
 		2 req_city = vc
 		2 req_state = vc
 		2 req_zip = vc
 		2 req_phone1 = vc
 		2 req_phone2 = vc
 		2 disc_first_name = vc
 		2 disc_middle_name = vc
 		2 disc_last_name = vc
 		2 disc_post_name = vc
 		2 disc_company = vc
 		2 disc_add1 = vc
 		2 disc_add2 = vc
 		2 disc_city = vc
 		2 disc_state = vc
 		2 disc_zip = vc
 		2 disc_phone1 = vc
 		2 disc_phone2 = vc
 		2 req_dt = vc
 		2 disc_dt = vc
 		2 rel_first_name = vc
 		2 rel_middle_name = vc
 		2 rel_last_name = vc
 		2 rel_reason = vc
 		2 disc_method_id = i4
 		2 rel_dt = vc
 		2 corp_number = vc
)*/
 
;--------------------------------------------------------------------------------------------------------------
;Get qualified docs
select into 'nl:'
	 cr.person_id, cr.encntr_id,cr.report_request_id, cr.request_dt_tm "@SHORTDATETIME"
	, req_type = if(cr.request_type_flag = 0.00)'No Meaning - Default'
         			elseif(cr.request_type_flag = 1.00)'AdHoc'
          			elseif(cr.request_type_flag = 2.00)'Auto-Expedite'
          			elseif(cr.request_type_flag = 3.00)'Manual Expedite'
          			elseif(cr.request_type_flag = 4.00)'Distribution'
			      elseif(cr.request_type_flag = 5.00)'Xencntr'
          			elseif(cr.request_type_flag = 8.00)'MRP'
          			endif
	, file_ext = trim(substring(findstring(".", cr.file_name) + 1, textlen(cr.file_name), cr.file_name))
 
	, rslt_status = if(cr.result_status_flag = 0.00)'Unknown'
          			elseif(cr.result_status_flag = 1.00)'All Statuses'
          			elseif(cr.result_status_flag = 2.00)'Verified and Pending'
          			elseif(cr.result_status_flag = 3.00)'Verified Only'
          			endif
	, scope = if(cr.scope_flag = 0.00)'No Value - Default'
		          elseif(cr.scope_flag = 1.00)'Person Level'
		          elseif(cr.scope_flag = 2.00)'Encounter Level'
		          elseif(cr.scope_flag = 4.00)'Accession Level'
		          elseif(cr.scope_flag = 5.00)'Cross-Encounter Level'
		          elseif(cr.scope_flag = 6.00)'Event Level'
			    endif
	, cr.total_pages_nbr
	, requestr_type =  if(cr.request_type_flag = 0.00)'Unknown'
				elseif(cr.request_type_flag = 1.00)'Person'
				elseif(cr.request_type_flag = 2.00)'Organization'
          			elseif(cr.request_type_flag = 3.00)'Free Text'
          			endif
 
	, destination_type = if(cr.destination_type_flag = 0.00)'Unknown'
				elseif(cr.destination_type_flag = 1.00)'Person'
				elseif(cr.destination_type_flag = 2.00)'Organization'
          			elseif(cr.destination_type_flag = 3.00)'Free Text'
          			endif
	, distribution_type = uar_get_code_display(cr.dist_run_type_cd)
	, fax_ph = build2(trim(rd.area_code), trim(rd.exchange), trim(rd.phone_suffix))
 
	;, destination = cr.destination_value_txt
	;, cr.file_name
	;, adhoc_fax_phone_number = cr.dms_adhoc_fax_number_txt
	;, fax_dt = cr.dms_fax_distribute_dt_tm "@SHORTDATETIME"
	;, output_content_type = uar_get_code_display(cr.output_content_type_cd)
	;, content_type_text = cr.output_content_type_str
	;, output_destination = uar_get_code_display(cr.output_dest_cd)
	;, cr.processing_time
	;, distribution_dt = cr.dist_run_dt_tm "@SHORTDATETIME"
	/*, disk_type = if(cr.disk_type_flag = 0.00)'N/A'
	          	elseif(cr.disk_type_flag = 1.00)'CD'
            	elseif(cr.disk_type_flag = 2.00)'DVD'
            	endif*/
 
from
	cr_report_request cr
	, (left join output_dest od on od.output_dest_cd = cr.output_dest_cd)
	, (left join device d on d.device_cd = od.device_cd)
	, (left join remote_device rd on rd.device_cd = od.device_cd)
	, (left join prsnl pr on pr.person_id = cr.provider_prsnl_id)
	, (left join chart_distribution cd on cd.distribution_id = cr.distribution_id)
	, (left join cr_report_template rt on rt.report_template_id = cr.template_id)
 
plan cr where cr.request_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and cr.release_reason_cd in(24380310.00,28648237.00,28648017.00, 28648023.00,24380306.00,3054708113.00,
			24380312.00,24380314.00,4469.00,24380304.00,24380320.00,24380318.00,24380308.00,24604405.00)
			   ;28648057.00	Work Related Illness or Injury to Employ
			   ;19999838.00	Workers' Compensation
 
join od
join d
join rd
join pr
join cd
join rt
 
order by cr.person_id, cr.encntr_id, cr.report_request_id
 
Head report
	cnt = 0
Head cr.report_request_id
	cnt += 1
	call alterlist(aod->plist, cnt)
Detail
	aod->plist[cnt].personid = cr.person_id
	aod->plist[cnt].encntrid = cr.encntr_id
	aod->plist[cnt].purpose = uar_get_code_display(cr.release_reason_cd)
	aod->plist[cnt].comments = cr.release_comment
	aod->plist[cnt].request_dt = format(cr.request_dt_tm, 'mm/dd/yy hh:mm;;q')
	aod->plist[cnt].request_id = cr.report_request_id
	aod->plist[cnt].tmp_request_name = trim(pr.name_full_formatted)
	aod->plist[cnt].tmp_receive_name = trim(pr.name_full_formatted)
	aod->plist[cnt].req_prsnl_id = cr.request_prsnl_id
	aod->plist[cnt].recv_prsnl_id = cr.provider_prsnl_id
 	aod->plist[cnt].request_status = uar_get_code_display(cr.report_status_cd)
	aod->plist[cnt].request_type = req_type
	aod->plist[cnt].result_status = rslt_status
	aod->plist[cnt].requestor_type = trim(requestr_type)
	aod->plist[cnt].provider_reltn = trim(uar_get_code_display(cr.provider_reltn_cd))
	aod->plist[cnt].file_extension = file_ext
	aod->plist[cnt].output_type = if(cr.output_content_type_cd != 0.00)
				trim(uar_get_code_display(cr.output_content_type_cd)) else file_ext endif
	aod->plist[cnt].output_dest_code = cr.output_dest_cd
	aod->plist[cnt].output_device = if(trim(fax_ph) != '') build2(trim(od.name),'(',trim(fax_ph),')') else trim(od.name) endif
		;build2(trim(od.name),'(', trim(rd.area_code),trim(rd.exchange), trim(rd.phone_suffix),')')
	aod->plist[cnt].device_type = trim(uar_get_code_display(d.device_type_cd))
	aod->plist[cnt].destination = trim(cr.destination_value_txt)
	aod->plist[cnt].dest_type = trim(destination_type)
	aod->plist[cnt].distribut_id = cr.distribution_id
	aod->plist[cnt].distribution_name = trim(cd.dist_descr)
	aod->plist[cnt].templat_id = cr.template_id
	aod->plist[cnt].report_template = trim(rt.template_name)
 	aod->plist[cnt].total_pages = cr.total_pages_nbr
 	aod->plist[cnt].scope = scope
 
	;aod->plist[cnt].device_description = trim(d.description)
	;aod->plist[cnt].fax_no = trim(cr.dms_adhoc_fax_number_txt)
	;aod->plist[cnt].authorization
 
with nocounter
 
;-----------------------------------------------------------------------------------------------------------
;Encounter info
select into 'nl:'
 
from (dummyt d with seq = value(size(aod->plist, 5)))
	, encounter e
 
plan d
 
join e where e.encntr_id = aod->plist[d.seq].encntrid
 
order by e.encntr_id
 
Head e.encntr_id
	aod->plist[d.seq].facility = uar_get_code_display(e.loc_facility_cd)
 	aod->plist[d.seq].beg_service = format(e.reg_dt_tm, 'mm/dd/yy hh:mm;;q')
 	aod->plist[d.seq].end_service = format(e.disch_dt_tm, 'mm/dd/yy hh:mm;;q')
with nocounter
 
;-----------------------------------------------------------------------------------------------------------
;Get request & receiving prsnl/org info
select into $outdev
 
req_id = aod->plist[d.seq].request_id
 
from (dummyt d with seq = value(size(aod->plist, 5)))
	, person p
	, person p1
 
plan d
 
join p where p.person_id = aod->plist[d.seq].req_prsnl_id
	and p.active_ind = 1
 
join p1 where p1.person_id = outerjoin(aod->plist[d.seq].recv_prsnl_id)
	and p1.active_ind = 1
 
order by req_id
 
Head req_id
 
	aod->plist[d.seq].req_first_name = trim(p.name_first)
	aod->plist[d.seq].req_middle_name = trim(p.name_middle)
	aod->plist[d.seq].req_last_name = trim(p.name_last)
	aod->plist[d.seq].request_name = trim(p.name_full_formatted)
	aod->plist[d.seq].recv_first_name = trim(p.name_first)
	aod->plist[d.seq].recv_middle_name = trim(p.name_middle)
	aod->plist[d.seq].recv_last_name = trim(p.name_last)
	aod->plist[d.seq].receive_name = trim(p1.name_full_formatted)
 
with nocounter
 
;-----------------------------------------------------------------------------------------------------------
;Requesting Prsnl Address
select into $outdev
 
prid = aod->plist[d.seq].req_prsnl_id,  name = aod->plist[d.seq].request_name
, a.street_addr, a.street_addr2, a.city, a.state, a.zipcode, ph.phone_num
 
from (dummyt d with seq = value(size(aod->plist, 5)))
	,address a
	,prsnl p
	,(left join phone ph on ph.parent_entity_id = p.person_id
		and ph.active_ind = 1
		and ph.parent_entity_name = 'PERSON'
		and ph.phone_type_cd = 163.00) ;Business
 
plan d
 
join p where p.person_id = aod->plist[d.seq].req_prsnl_id
	and p.active_ind = 1
 
join ph
 
join a where a.parent_entity_id  = p.person_id
	and cnvtlower(a.parent_entity_name) = "person"
      and a.address_type_cd = 754.00 ;Business
      and a.active_ind = 1
      and a.address_type_seq = (select min(a1.address_type_seq) from address a1
			where a1.parent_entity_id = a.parent_entity_id
			and a1.address_type_cd = 754.00 ;Business
			and cnvtlower(a.parent_entity_name) = "person"
			and a1.active_ind = 1
			and cnvtdatetime(curdate, curtime3) between a1.beg_effective_dt_tm and a1.end_effective_dt_tm
			group by a1.parent_entity_id)
 
order by p.person_id
 
Head p.person_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(aod->plist,5), p.person_id ,aod->plist[icnt].req_prsnl_id)
 
    while(idx > 0)
    	    aod->plist[idx].req_add1 = a.street_addr
    	    aod->plist[idx].req_add2 = a.street_addr2
    	    aod->plist[idx].req_city = a.city
    	    aod->plist[idx].req_state = a.state
    	    aod->plist[idx].req_zip = a.zipcode
	    aod->plist[idx].req_phone1 = ph.phone_num
	    idx = locateval(icnt,(idx+1) ,size(aod->plist,5),p.person_id ,aod->plist[icnt].req_prsnl_id)
    endwhile
 
with nocounter
 
;-----------------------------------------------------------------------------------------------------------
;Receving Prsnl Address
select into $outdev
 
prid = aod->plist[d.seq].recv_prsnl_id,  name = aod->plist[d.seq].receive_name
, a.street_addr, a.street_addr2, a.city, a.state, a.zipcode, ph.phone_num
 
from (dummyt d with seq = value(size(aod->plist, 5)))
	,address a
	,prsnl p
	,(left join phone ph on ph.parent_entity_id = p.person_id
		and ph.active_ind = 1
		and ph.parent_entity_name = 'PERSON'
		and ph.phone_type_cd = 163.00) ;Business
 
plan d
 
join p where p.person_id = aod->plist[d.seq].recv_prsnl_id
	and p.active_ind = 1
 
join ph
 
join a where a.parent_entity_id  = p.person_id
	and cnvtlower(a.parent_entity_name) = "person"
      and a.address_type_cd = 754.00 ;Business
      and a.active_ind = 1
      and a.address_type_seq = (select min(a1.address_type_seq) from address a1
			where a1.parent_entity_id = a.parent_entity_id
			and a1.address_type_cd = 754.00 ;Business
			and cnvtlower(a.parent_entity_name) = "person"
			and a1.active_ind = 1
			and cnvtdatetime(curdate, curtime3) between a1.beg_effective_dt_tm and a1.end_effective_dt_tm
			group by a1.parent_entity_id)
 
order by p.person_id
 
Head p.person_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(aod->plist,5), p.person_id ,aod->plist[icnt].recv_prsnl_id)
 
    while(idx > 0)
    	    aod->plist[idx].recv_add1 = a.street_addr
    	    aod->plist[idx].recv_add2 = a.street_addr2
    	    aod->plist[idx].recv_city = a.city
    	    aod->plist[idx].recv_state = a.state
    	    aod->plist[idx].recv_zip = a.zipcode
	    aod->plist[idx].recv_phone1 = ph.phone_num
	    idx = locateval(icnt,(idx+1) ,size(aod->plist,5),p.person_id ,aod->plist[icnt].recv_prsnl_id)
    endwhile
 
with nocounter
 
;----------------------------------------------------------------------------------------------------------------
/*
;Get request & receiving prsnl/org info
select into 'nl:'
 
from (dummyt d with seq = value(size(aod->plist, 5)))
	, cr_report_request_event cre
	, ce_event_prsnl cep
	, prsnl pr
	, prsnl pr1
 
plan d
 
join cre where cre.report_request_id = aod->plist[d.seq].request_id
 
join cep where cep.event_id = cre.event_id
 
join pr where pr.person_id = outerjoin(cep.action_prsnl_id)
 
join pr1 where pr1.person_id = outerjoin(cep.receiving_person_id)
 
order by cre.report_request_id
 
Head cre.report_request_id
	aod->plist[d.seq].request_name = trim(pr.name_full_formatted)
	aod->plist[d.seq].receive_name = trim(pr1.name_full_formatted)
 
with nocounter
;----------------------------------------------------------------------------------
;Assign if there is no data on prsnl above
 
select into 'nl:'
 req_id = aod->plist[d.seq].request_id
 
from (dummyt d with seq = value(size(aod->plist, 5)))
 
plan d
 
order by req_id
 
Head req_id
	aod->plist[d.seq].request_name = if(aod->plist[d.seq].request_name = '') aod->plist[d.seq].tmp_request_name endif
	aod->plist[d.seq].receive_name = if(aod->plist[d.seq].receive_name = '') aod->plist[d.seq].tmp_receive_name endif
 
with nocounter
*/
;-----------------------------------------------------------------------------------------------------------
;Patient Demographic
select into $outdev
 
p.person_id, ph.phone_num, ph.phone_type_cd
 
from (dummyt d with seq = value(size(aod->plist, 5)))
	, encntr_alias ea
	, encntr_alias ea1
	, person p
	, person_alias pa
 
plan d
 
join ea where ea.encntr_id = aod->plist[d.seq].encntrid
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
join ea1 where ea1.encntr_id = aod->plist[d.seq].encntrid
	and ea1.encntr_alias_type_cd = 1079
	and ea1.active_ind = 1
 
join p where p.person_id = aod->plist[d.seq].personid
	and p.active_ind = 1
 
join pa where outerjoin(p.person_id) = pa.person_id
	 and pa.alias_pool_cd = outerjoin(cmrn_alias_pool_var)
	 and pa.person_alias_type_cd = outerjoin(cmrn_var)
	 and pa.active_ind = outerjoin(1)
 
 
order by ea.encntr_id
 
Head ea.encntr_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(aod->plist,5) ,ea.encntr_id ,aod->plist[icnt].encntrid)
 
    while(idx > 0)
    	    aod->plist[idx].fin = trim(ea.alias)
    	    aod->plist[idx].mrn = trim(ea1.alias)
    	    aod->plist[idx].cmrn = trim(pa.alias)
    	    aod->plist[idx].pat_dob = format(p.birth_dt_tm, 'mm/dd/yyyy;;d')
    	    aod->plist[idx].pat_name = trim(p.name_full_formatted)
    	    aod->plist[idx].pat_name_first = trim(p.name_first)
    	    aod->plist[idx].pat_name_middle = trim(p.name_middle)
    	    aod->plist[idx].pat_name_last = trim(p.name_last)
	    idx = locateval(icnt,(idx+1) ,size(aod->plist,5) ,ea.encntr_id ,aod->plist[icnt].encntrid)
    endwhile
 
with nocounter
 
;-----------------------------------------------------------------------------------------------------------
;Patient Address
select into $outdev
 
pid = aod->plist[d.seq].personid,  name = aod->plist[d.seq].pat_name
, a.street_addr, a.street_addr2, a.city, a.state, a.zipcode
 
from (dummyt d with seq = value(size(aod->plist, 5)))
	,address a
	, person p
	, (left join phone ph on ph.parent_entity_id = p.person_id
		and ph.active_ind = 1
		and ph.parent_entity_name = 'PERSON'
		and ph.phone_type_cd in(home_ph_var, mobile_ph_var))
 
plan d
 
join p where p.person_id = aod->plist[d.seq].personid
	and p.active_ind = 1
 
join ph
 
join a where a.parent_entity_id  = p.person_id
	and cnvtlower(a.parent_entity_name) = "person"
      and a.address_type_cd = 756.00 ;Home
 
order by p.person_id
 
Head pid
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,size(aod->plist,5), p.person_id ,aod->plist[icnt].personid)
 
    while(idx > 0)
    	    aod->plist[idx].pat_add1 = a.street_addr
    	    aod->plist[idx].pat_add2 = a.street_addr2
    	    aod->plist[idx].pat_city = a.city
    	    aod->plist[idx].pat_state = a.state
    	    aod->plist[idx].pat_zip = a.zipcode
     	    case(ph.phone_type_cd)
    	    	of home_ph_var:
    	    		aod->plist[idx].pat_phone1 = ph.phone_num
    	    	of mobile_ph_var:
    	    		aod->plist[idx].pat_phone2 = ph.phone_num
    	    endcase
 
	    idx = locateval(icnt,(idx+1) ,size(aod->plist,5),p.person_id ,aod->plist[icnt].personid)
    endwhile
 
with nocounter
 
;-----------------------------------------------------------------------------------------------------------
;Get report request section
 
select into 'nl:'
 
from (dummyt d with seq = value(size(aod->plist, 5)))
	,cr_report_request_section rrs
	,cr_report_section crs
 
plan d
 
join rrs where rrs.report_request_id = aod->plist[d.seq].request_id
 
join crs where crs.report_section_id = rrs.section_id
	and crs.end_effective_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00")
	and crs.active_ind = 1
 
order by rrs.report_request_id, crs.report_section_id
 
Head rrs.report_request_id
	sec_name = fillstring(3000," ")
Head crs.report_section_id
	 sec_name = build2(trim(sec_name),'[' ,trim(crs.section_name),']',',')
Foot rrs.report_request_id
	aod->plist[d.seq].request_section = replace(trim(sec_name),",","",2)
 
with nocounter
 
;-----------------------------------------------------------------------------------------------------------
;Get printed/rendered section name
 
select into 'nl:'
 
from (dummyt d with seq = value(size(aod->plist, 5)))
	, cr_printed_sections cps
	, cr_report_section crs
 
plan d
 
join cps where cps.report_request_id = aod->plist[d.seq].request_id
 
join crs where crs.section_id = cps.section_id
	and crs.end_effective_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00")
 
order by cps.report_request_id, crs.section_id
 
Head cps.report_request_id
	sec_name = fillstring(1000," ")
Head crs.section_id
	 sec_name = build2(trim(sec_name),'[' ,trim(crs.section_name),']',',')
Foot cps.report_request_id
	aod->plist[d.seq].rendered_section = replace(trim(sec_name),",","",2)
with nocounter
 
call echorecord(aod)
;-----------------------------------------------------------------------------------------------------------
/********************************************************************************
				OUTPUT SECTION
*********************************************************************************/
 
/************** Ops Job *****************/
 
if(iOpsInd = 1) ;Ops
  if($to_file = 0)  ;To File
 
   Select into value(filename_var)
 
	from (dummyt d WITH seq = value(size(aod->plist,5)))
	order by d.seq
 
	;build output
	Head report
		file_header_var = build(
			 wrap3("Start dt")
			,wrap3("End dt")
			,wrap3("Facility")
			,wrap3("FirstName")
			,wrap3("MiddleName")
			,wrap3("LastName")
			,wrap3("PostName")
			,wrap3("Add1")
			,wrap3("Add2")
			,wrap3("City")
			,wrap3("State")
			,wrap3("Zip")
			,wrap3("Phone1")
  			,wrap3("Phone2")
  			,wrap3("DateOfBirth")
  			,wrap3("PrimaryNumber")
  			,wrap3("SecondaryNumber")
		  	,wrap3("OtherNumber")
		  	,wrap3("BeginService")
		  	,wrap3("EndService")
		  	,wrap3("ReqFirstName")
		  	,wrap3("ReqMiddleName")
		  	,wrap3("ReqLastName")
		  	,wrap3("ReqPostName")
		  	,wrap3("ReqCompany")
		   	,wrap3("ReqAdd1")
		   	,wrap3("ReqAdd2")
		  	,wrap3("ReqCity")
		  	,wrap3("ReqState")
		  	,wrap3("ReqZip")
		  	,wrap3("ReqPhone1")
		  	,wrap3("ReqPhone2")
			,wrap3("DiscFirstName")
			,wrap3("DiscMiddleName")
			,wrap3("DiscLastName")
		  	,wrap3("DiscPostName")
		  	,wrap3("DiscCompany")
		  	,wrap3("DiscAdd1")
		  	,wrap3("DiscAdd2")
			,wrap3("DiscCity")
			,wrap3("DiscState")
			,wrap3("DiscZip")
		  	,wrap3("DiscPhone1")
		  	,wrap3("DiscPhone2")
		  	,wrap3("ReqDate")
		  	;,wrap3("DiscDate")
		  	,wrap3("RelFirstName")
		  	,wrap3("RelMiddleName")
		  	,wrap3("RelLastName")
		  	,wrap3("Reason")
			,wrap3("DisclosureMethodID")
			;,wrap3("DateStamp")
			,wrap3("CorporateNumber")
			,wrap3("RequestID")
			;,wrap3("RequestSection")
			,wrap3("ResultStatus")
			,wrap3("RequestStatus")
			,wrap3("RequestType")
			,wrap3("OutputDevice")
			,wrap3("DeviceType")
			,wrap3("OutputType")
			,wrap3("ReportTemplate")
			,wrap3("TotalPages")
			,wrap3("ReportScope")
			,wrap1("EncounterID") )
 
	col 0 file_header_var
	row + 1
 
 	Head d.seq
		aod_output = ""
		aod_output = build(aod_output
			,wrap3(format(cnvtdatetime($start_datetime), 'mm/dd/yyyy hh:mm;;q'))
			,wrap3(format(cnvtdatetime($end_datetime), 'mm/dd/yyyy hh:mm;;q'))
			,wrap3(aod->plist[d.seq].facility)
			,wrap3(aod->plist[d.seq].pat_name_first)
			,wrap3(aod->plist[d.seq].pat_name_middle)
			,wrap3(aod->plist[d.seq].pat_name_last)
			,wrap3(aod->plist[d.seq].pat_post_name)
			,wrap3(aod->plist[d.seq].pat_add1)
			,wrap3(aod->plist[d.seq].pat_add2)
			,wrap3(aod->plist[d.seq].pat_city)
			,wrap3(aod->plist[d.seq].pat_state)
			,wrap3(aod->plist[d.seq].pat_zip)
			,wrap3(aod->plist[d.seq].pat_phone1)
			,wrap3(aod->plist[d.seq].pat_phone2)
			,wrap3(aod->plist[d.seq].pat_dob)
			,wrap3(aod->plist[d.seq].pat_primary_no)
			,wrap3(aod->plist[d.seq].pat_secondary_no)
			,wrap3(aod->plist[d.seq].pat_other_no)
			,wrap3(aod->plist[d.seq].beg_service)
			,wrap3(aod->plist[d.seq].end_service)
			,wrap3(aod->plist[d.seq].req_first_name)
			,wrap3(aod->plist[d.seq].req_middle_name)
			,wrap3(aod->plist[d.seq].req_last_name)
			,wrap3(aod->plist[d.seq].req_post_name)
			,wrap3(aod->plist[d.seq].req_company)
			,wrap3(aod->plist[d.seq].req_add1)
			,wrap3(aod->plist[d.seq].req_add2)
			,wrap3(aod->plist[d.seq].req_city)
			,wrap3(aod->plist[d.seq].req_state)
			,wrap3(aod->plist[d.seq].req_zip)
			,wrap3(aod->plist[d.seq].req_phone1)
			,wrap3(aod->plist[d.seq].req_phone2)
			,wrap3(aod->plist[d.seq].recv_first_name)
			,wrap3(aod->plist[d.seq].recv_middle_name)
			,wrap3(aod->plist[d.seq].recv_last_name)
			,wrap3(aod->plist[d.seq].recv_post_name)
			,wrap3(aod->plist[d.seq].recv_company)
			,wrap3(aod->plist[d.seq].recv_add1)
			,wrap3(aod->plist[d.seq].recv_add2)
			,wrap3(aod->plist[d.seq].recv_city)
			,wrap3(aod->plist[d.seq].recv_state)
			,wrap3(aod->plist[d.seq].recv_zip)
			,wrap3(aod->plist[d.seq].recv_phone1)
			,wrap3(aod->plist[d.seq].recv_Phone2)
			,wrap3(aod->plist[d.seq].request_dt)
			,wrap3(aod->plist[d.seq].rel_first_name)
			,wrap3(aod->plist[d.seq].rel_middle_name)
  			,wrap3(aod->plist[d.seq].rel_last_name)
			,wrap3(aod->plist[d.seq].purpose)
			,wrap3(cnvtstring(aod->plist[d.seq].Disc_method_id))
			;,wrap3(aod->plist[d.seq].cur_date_tm)
			,wrap3(aod->plist[d.seq].cmrn)
			,wrap3(cnvtstring(aod->plist[d.seq].request_id))
			;,wrap3(aod->plist[d.seq].request_section)
			,wrap3(aod->plist[d.seq].result_status)
			,wrap3(aod->plist[d.seq].request_status)
			,wrap3(aod->plist[d.seq].request_type)
			,wrap3(aod->plist[d.seq].output_device)
			,wrap3(aod->plist[d.seq].device_type)
			,wrap3(aod->plist[d.seq].output_type)
			,wrap3(aod->plist[d.seq].report_template)
			,wrap3(cnvtstring(aod->plist[d.seq].total_pages))
			,wrap3(aod->plist[d.seq].scope)
			,wrap1(cnvtstring(aod->plist[d.seq].encntrid))  )
 
		aod_output = trim(aod_output, 3)
		aod_output = replace(replace(aod_output ,char(13)," "),char(10)," ")
 
	 Foot d.seq
	 	col 0 aod_output
	 	row + 1
 
	with time = 30, nocounter, maxcol = 32000, format = stream, formfeed = none;, maxrow = 0
 
	;Move file to Astream folder
  	set cmd = build2("mv ", ccl_filepath_var, " ", astream_filepath_var) ;to move only in prod
  	;set cmd = build2("cp ", ccl_filepath_var, " ", astream_filepath_var) ;to copy only for testing
	set len = size(trim(cmd))
 	call dcl(cmd, len, stat)
	call echo(build2(cmd, " : ", stat))
 
  endif ;To File
endif ;ops
 
;---------------------------------------------------------------------------------------------------------------------
 
If($to_file = 1) ;Screen Display
 
select into $outdev
	  facility = trim(substring(1, 30, aod->plist[d1.seq].facility))
	, fin = trim(substring(1, 10, aod->plist[d1.seq].fin))
	, request_id = aod->plist[d1.seq].request_id
	;, encntrid = aod->plist[d1.seq].encntrid
	, pat_name = trim(substring(1, 50, aod->plist[d1.seq].pat_name))
	, cmrn = trim(substring(1, 10, aod->plist[d1.seq].cmrn))
	, request_name = trim(substring(1, 50, aod->plist[d1.seq].request_name))
	, receive_name = trim(substring(1, 50, aod->plist[d1.seq].receive_name))
	, provider_reltn = trim(substring(1, 50, aod->plist[d1.seq].provider_reltn))
	, request_section = if(trim(substring(1, 300, aod->plist[d1.seq].request_section)) != '')
		trim(substring(1, 300, aod->plist[d1.seq].request_section)) else 'All Sections were requested' endif
	, rendered_section = trim(substring(1, 300, aod->plist[d1.seq].rendered_section))
	, request_dt = trim(substring(1, 30, aod->plist[d1.seq].request_dt))
	, result_status = trim(substring(1, 30, aod->plist[d1.seq].result_status))
	, request_status = trim(substring(1, 30, aod->plist[d1.seq].request_status))
	, request_type = trim(substring(1, 30, aod->plist[d1.seq].request_type))
	, requestor_type = trim(substring(1, 30, aod->plist[d1.seq].requestor_type))
	;, file_extension = substring(1, 30, aod->plist[d1.seq].file_extension)
	, output_device = trim(substring(1, 300, aod->plist[d1.seq].output_device))
	, device_type = trim(substring(1, 300, aod->plist[d1.seq].device_type))
	, device_description = trim(substring(1, 300, aod->plist[d1.seq].device_description))
	, output_type = trim(substring(1, 30, aod->plist[d1.seq].output_type))
	, purpose = substring(1, 300, aod->plist[d1.seq].purpose)
	, destination = trim(substring(1, 300, aod->plist[d1.seq].destination))
	, destination_type = trim(substring(1, 300, aod->plist[d1.seq].dest_type))
	;, comments = substring(1, 300, aod->plist[d1.seq].comments)
	, distribution_name = trim(substring(1, 300, aod->plist[d1.seq].distribution_name))
	;, authorization = substring(1, 30, aod->plist[d1.seq].authorization)
	, report_template = trim(substring(1, 300, aod->plist[d1.seq].report_template))
	, total_pages = aod->plist[d1.seq].total_pages
	, scope = trim(substring(1, 300, aod->plist[d1.seq].scope))
 
from
	(dummyt   d1  with seq = size(aod->plist, 5))
 
plan d1
 
order by request_dt, fin
 
with nocounter, separator=" ", format
 
endif
 
/*****************************************************************************
	;SUBROUTINS
/*****************************************************************************/
 
%i cust_script:cov_CommonLibrary.inc
 
#exitscript
 
end go
;-----------------------------------------------------------------------------------------------------------
 
 
