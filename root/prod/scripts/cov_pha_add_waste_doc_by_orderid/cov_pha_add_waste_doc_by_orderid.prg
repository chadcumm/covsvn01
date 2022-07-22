/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		01/20/2020
	Solution:			Perioperative
	Source file name:	cov_pha_add_waste_doc_by_orderid.prg
	Object name:		cov_pha_add_waste_doc_by_order
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
000 	01/20/2020  Chad Cummings			Initial Release
001		02/12/2020  Chad Cummings			Moved DM_INFO date setting to exit_script
002		02/19/2020  Chad Cummings			changed to updt_dt_tm for dispense_hx
003		02/19/2020  Chad Cummings			updated to use order_id
******************************************************************************/

drop program cov_pha_add_waste_doc_by_order:dba go
create program cov_pha_add_waste_doc_by_order:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "ORDER_ID" = 0 	;003

with OUTDEV, order_id ;003


call echo(build("loading script:",curprog))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section 001 *********************************"))

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

free set 390051request 
record 390051request (
  1 dispense_hx_id = f8   
) 

/*free set 390051reply 
record 390051reply (
    1 order_id = f8
    1 dispense_hx_id = f8
    1 action_seq = i4
    1 prodlist [* ]
      2 prod_dispense_hx_id = f8
      2 item_id = f8
      2 med_product_id = f8
      2 prod_desc = vc
      2 generic_name = vc
      2 ingred_sequence = i4
      2 manufacturer_name = vc
      2 drug_identifier = vc
      2 manf_item_id = f8
      2 strength = f8
      2 strength_unit_cd = f8
      2 strength_unit_display = vc
      2 volume = f8
      2 volume_unit_cd = f8
      2 volume_unit_display = vc
      2 dispense_qty = f8
      2 dispense_qty_unit_cd = f8
      2 dispense_qty_unit_display = vc
      2 cms_waste_billing_unit_amt = f8
      2 charge_qty = f8
      2 available_waste_qty = f8
      2 available_waste_charge_qty = f8
      2 wasted_qty = f8
      2 qpd = f8
      2 unrounded_qpd = f8
      2 charge_dose_mismatch_ind = i2
    1 charge_on_sched_admin_ind = i2
    1 first_admin_dt_tm = dq8
    1 ingred_action_seq = i4
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) 
*/
  
free record document_request 
free record document_reply 
 
record document_request
(
   1 personId = f8
   1 encounterId = f8
   1 documentType_key = vc ;  code set 72 display_key
   1 title = vc
   1 service_dt_tm = dq8
   1 notetext = vc
   1 noteformat = vc ; code set 23 cdf_meaning
   1 personnel[3]
     2 id = f8
     2 action = vc     ; code set 21 cdf_meaning
     2 status = vc     ; code set 103 cdf_meanings
   1 mediaObjects[*]
     2 display = vc
     2 identifier = vc
   1 mediaObjectGroups[*]
     2 identifier = vc
   1 publishAsNote = i2
   1 debug = i2
)
 
record document_reply (
	1 parentEventId = f8
%i cclsource:status_block.inc
)
 
free set t_rec
record t_rec
(
	1 cv
	 2 waste_charge_cd	= f8
	1 dates
	 2 start_dt_tm		= dq8
	 2 end_dt_tm		= dq8
	1 prompt_order_id	= f8	;003
	1 document_key		= vc
	1 dminfo
	 2 info_domain		= vc
	 2 info_name		= vc
	1 cnt				= i4
	1 qual[*]
	 2 dispense_hx_id		= f8
	 2 waste_dispense_hx_id	= f8
	 2 encntr_id			= f8
	 2 person_id			= f8
	 2 event_id				= f8
	 2 waste_qty			= f8
	 2 prsnl_id				= f8
	 2 order_id				= f8
	 2 status				= i2
)

call addEmailLog("chad.cummings@covhlth.com")

set t_rec->document_key = "PHARMACYWASTAGTEXT"

set t_rec->prompt_order_id = $ORDER_ID	;003

set t_rec->dminfo.info_domain	= "COV_PHA_OPS"
set t_rec->dminfo.info_name		= concat(trim(cnvtupper(curprog)),":","start_dt_tm")

set t_rec->cv.waste_charge_cd = value(uar_get_code_by("MEANING",4032,"WASTECHARGE"))

;start 003
if (t_rec->prompt_order_id <= 0.0)
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "MISSING ORDER ID"
	go to exit_script
endif
;end 003

if (t_rec->cv.waste_charge_cd <= 0.0)
	set reply->status_data.status = "F"
	set reply->status_data.subeventstatus.operationname = "Waste Charge Error"
	go to exit_script
endif

call writeLog(build2("* END   Custom Section  ************************************"))
call writeLog(build2("************************************************************"))

call writeLog(build2("* START Get Date Range ******************************"))

set t_rec->dates.start_dt_tm = get_dminfo_date(t_rec->dminfo.info_domain,t_rec->dminfo.info_name)

if (t_rec->dates.start_dt_tm = 0.0)
	call writeLog(build2("->No start date and time found, setting to go live date"))
	set t_rec->dates.start_dt_tm = cnvtdatetime("12-FEB-2020 00:00:00")
endif

set t_rec->dates.end_dt_tm = cnvtdatetime(curdate,curtime3)

call writeLog(build2("* END   Get Date Range ******************************"))

call writeLog(build2("* START Finding Events ******************************"))

select into "nl:"
from
	dispense_hx dh 
plan dh 
	where dh.disp_event_type_cd = t_rec->cv.waste_charge_cd
;002	and   dh.dispense_dt_tm >= cnvtdatetime(t_rec->dates.start_dt_tm)
;002	and   dh.dispense_dt_tm <= cnvtdatetime(t_rec->dates.end_dt_tm)
;003	and   dh.updt_dt_tm > cnvtdatetime(t_rec->dates.start_dt_tm)			;002
;003	and   dh.updt_dt_tm <= cnvtdatetime(t_rec->dates.end_dt_tm)				;002
	and   dh.order_id = t_rec->prompt_order_id									;003
order by
	dh.dispense_hx_id
head report
	cnt = 0
head dh.dispense_hx_id
	cnt = (cnt + 1)
	stat = alterlist(t_rec->qual,cnt)
	t_rec->qual[cnt].dispense_hx_id 		= dh.dispense_hx_id
	t_rec->qual[cnt].waste_dispense_hx_id	= dh.waste_dispense_hx_id
	t_rec->qual[cnt].prsnl_id				= dh.run_user_id
	t_rec->qual[cnt].order_id				= dh.order_id
foot report
	t_rec->cnt = cnt
with nocounter

if (t_rec->cnt = 0)
	set reply->status_data.status = "Z"
	go to exit_script
endif

call writeLog(build2("* END   Finding Events ******************************"))

call writeLog(build2("* START Finding Waste Info ************************** v2"))

for (i = 1 to t_rec->cnt)
	set stat = initrec(390051request)
	;003 set stat = initrec(390051reply)
	set 390051request->dispense_hx_id = t_rec->qual[i].dispense_hx_id ;003 t_rec->qual[i].waste_dispense_hx_id ;003 
	call writeLog(build2(cnvtrectojson(390051request)))
	set stat = tdbexecute(390000,380000,390058,"REC",390051request,"REC",390051reply) ;rx_get_waste_prod_disp_hx
	call writeLog(build2(cnvtrectojson(390051reply)))
	
	if (390051reply->status_data.status = "S")
		set t_rec->qual[i].status = 1
		if (size(390051reply->wastelist,5) > 0)
			for (j=1 to size(390051reply->wastelist,5))
				if (size(390051reply->wastelist[j].prodlist,5) > 0)
					for (k=1 to size(390051reply->wastelist[j].prodlist,5))					
						set t_rec->qual[i].waste_qty = 390051reply->wastelist[j].prodlist[k].wasted_qty
						set t_rec->qual[i].status = 2
					endfor
				endif
			endfor
		endif
	endif
endfor

call writeLog(build2("* END   Finding Waste Info **************************"))


call writeLog(build2("* START Finding Encounter ***************************"))

select into "nl:"
from
	orders o
	,(dummyt d1 with seq=t_rec->cnt)
plan d1
join o
	where o.order_id = t_rec->qual[d1.seq].order_id
order by
	o.order_id
detail
	t_rec->qual[d1.seq].encntr_id = o.encntr_id
	t_rec->qual[d1.seq].person_id = o.person_id
with nocounter

call writeLog(build2("* END   Finding Encounter ****************************"))

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom   ************************************"))

for (i = 1 to t_rec->cnt)
	set stat = initrec(document_request)
	set stat = initrec(document_reply)
	set document_request->service_dt_tm			= cnvtdatetime(curdate,curtime3)
	set document_request->documenttype_key 		= t_rec->document_key
	set document_request->personId 				= t_rec->qual[i].person_id
	set document_request->encounterId 			= t_rec->qual[i].encntr_id
	set document_request->title 				= nullterm('Pharmacy Wastage')
	set document_request->notetext 				= nullterm(build2("Waste Quantity: ",trim(cnvtstring(t_rec->qual[i].waste_qty,10,4))," EA"))
	set document_request->noteformat 			= '' 
	set document_request->personnel[1]->id 		= t_rec->qual[i].prsnl_id
	set document_request->personnel[1]->action 	= 'PERFORM'  
	set document_request->personnel[1]->status 	= 'COMPLETED'  
	set document_request->personnel[2]->id 		= t_rec->qual[i].prsnl_id
	set document_request->personnel[2]->action 	= 'SIGN' 
	set document_request->personnel[2]->status 	= 'COMPLETED'  
	set document_request->personnel[3]->id 		= t_rec->qual[i].prsnl_id
	set document_request->personnel[3]->action 	= 'VERIFY' 
	set document_request->personnel[3]->status 	= 'COMPLETED'  

	set document_request->publishAsNote=0 
	set document_request->debug=1 
	
	if ( (t_rec->qual[i].status = 2) and (t_rec->qual[i].encntr_id > 0.0) )
		call writeLog(build2(^execute mmf_publish_ce with replace("REQUEST", "DOCUMENT_REQUEST"), replace("REPLY", "DOCUMENT_REPLY")^))
		call writeLog(build2(cnvtrectojson(document_request)))
		execute mmf_publish_ce with replace("REQUEST", "DOCUMENT_REQUEST"), replace("REPLY", "DOCUMENT_REPLY")
		call writeLog(build2(cnvtrectojson(document_reply)))
		set t_rec->qual[i].event_id = document_reply->parentEventId
	endif

endfor

set reply->status_data.status = "S"

call writeLog(build2("* END   Custom   ************************************"))
call writeLog(build2("************************************************************"))


#exit_script
;001 start
if (reply->status_data.status in("Z","S"))
	call writeLog(build2("* START Set Date Range ************************************"))
	call set_dminfo_date(t_rec->dminfo.info_domain,t_rec->dminfo.info_name,t_rec->dates.end_dt_tm)
	call writeLog(build2("* END Set Date Range ************************************v1"))
endif
;001 end

call writeLog(build2(cnvtrectojson(t_rec))) 

call exitScript(null)
call echorecord(t_rec)
;call echorecord(code_values)
call echorecord(program_log)


end
go