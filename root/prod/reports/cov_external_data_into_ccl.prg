/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Jun'2019
	Solution:			Pharmacy
	Source file name:	      cov_external_data_into_ccl.prg
	Object name:		cov_external_data_into_ccl
	Request#:			5188
	Program purpose:	      Update to Scorecard - Antibiotics extract. Adding Ordering physician to the existing data and going
					forward.
	Executing from:		Ops
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_external_data_into_ccl:DBA go
create program cov_external_data_into_ccl:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
with OUTDEV
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
set modify maxvarlen 5000000
 
declare star_var    = f8 with constant(uar_get_code_by("DISPLAY", 263, 'STAR Doctor Number')), protect
declare org_doc_var = f8 with constant(uar_get_code_by("DISPLAY", 320, 'ORGANIZATION DOCTOR')), protect
declare num	        = i4 with noconstant(0)
declare output_orders = vc
declare filename_var  = vc with constant('cer_temp:cov_pha_phys_update_mis.txt'), protect
 
;Ops setup
declare cmd  = vc with noconstant("")
declare len  = i4 with noconstant(0)
declare stat = i4 with noconstant(0)
declare iOpsInd      = i2 WITH NOCONSTANT(0), PROTECT
 
/*
declare filename_var = vc WITH noconstant(CONCAT('cer_temp:',TRIM(cnvtlower(uar_get_displaykey($facility_list))),'\
			_pha_scorecard_medadmin.txt')), PROTECT
declare ccl_filepath_var = vc WITH noconstant(CONCAT('$cer_temp/',TRIM(cnvtlower(uar_get_displaykey($facility_list))),'\
_pha_scorecard_medadmin.txt')), PROTECT
declare astream_filepath_var = vc with noconstant("/cerner/w_custom/p0665_cust/to_client_site/ClinicalAncillary/Pharmacy/PAExports/")
*/
 
;request from Ops?
if(validate(request->batch_selection) = 1)
 	set iOpsInd = 1
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
free record frec
record frec (
	1 file_desc		= i4
	1 file_offset	= i4
	1 file_dir		= i4
	1 file_name		= vc
	1 file_buf		= vc
)
 
free record orders
record orders(
	1 rec_cnt = i4
	1 olist[*]
		2 fin = vc
		2 orderid = f8
		2 ord_phys_number = vc
)
 
; input file
set frec->file_name = "/cerner/cmsftp/Pharm_order_list.csv"
 
; read-only mode
set frec->file_buf = "r"
 
 
/**************************************************************/
; load file for Ordering Physician update
 
; open file
set stat = CCLIO("OPEN", frec)
;call echo(build('Stat = ', stat))
 
; define file buffer for records
set frec->file_buf = notrim(fillstring(200, " "))
 
; validate file handle
if (frec->file_desc != 0)
	set stat = 1
	set rownum = 0
	set cnt = 0
 
	while (stat > 0)
		; get line from file
		set stat = CCLIO("GETS", frec)
 
		if (stat > 0)
			set rownum = rownum + 1
 
			if (rownum = 1)
				; skip header row
				null
			else
				set cnt = cnt + 1
 				call alterlist(orders->olist, cnt)
 
				;get elements
				set pos1 = findstring(",", frec->file_buf, 1)
				set pos2 = findstring(",", frec->file_buf, pos1+1)
	 			set orders->olist[cnt].fin = substring(1, (pos1 - 1), frec->file_buf)
	 			set orders->olist[cnt].orderid = cnvtreal(substring((pos1+1), 10, frec->file_buf))
	 			;set orders->olist[cnt].orderid = cnvtreal(substring((pos1+1), (pos2 - (pos1+1)), frec->file_buf))
				set orders->rec_cnt = cnt
				set pos1 = 0
				set pos2 = 0
			endif
		endif
	endwhile
 
endif
 
; close file
set stat = CCLIO("CLOSE", frec)
 
call echorecord(frec)
call echorecord(orders)
 
/**************************************************************/
 
select into 'nl:'
 
	fin = orders->olist[d1.seq].fin
	, orderid = orders->olist[d1.seq].orderid ;, oa.order_provider_id
	;, alias_pool = uar_get_code_display(pa.alias_pool_cd)
	;, alias_type = uar_get_code_display(pa.prsnl_alias_type_cd)
	, ordering_phys_name = pr.name_full_formatted
	, ordering_phys_number = trim(pa.alias,3)
from
	(dummyt d1 with seq = size(orders->olist, 5))
	, order_action oa
	, encntr_alias ea
	, prsnl pr
	, prsnl_alias pa
 
plan d1
 
join oa where oa.order_id = orders->olist[d1.seq].orderid
	and oa.action_sequence = 1
 
join ea where ea.alias = orders->olist[d1.seq].fin
	and ea.encntr_alias_type_cd = 1077
 
join pr where pr.person_id = outerjoin(oa.order_provider_id)
 
join pa where pa.person_id = outerjoin(pr.person_id)
	and pa.alias_pool_cd = outerjoin(star_var)
	and pa.prsnl_alias_type_cd = outerjoin(org_doc_var)
 
order by oa.order_id

;with nocounter, separator=" ", format

Head oa.order_id
	idx = 0
	cnt = 0
      idx = locateval(cnt ,1, orders->rec_cnt ,oa.order_id ,orders->olist[cnt].orderid)
    while(idx > 0)
	     orders->olist[idx].ord_phys_number = ordering_phys_number
	     idx = locateval(cnt,(idx+1), orders->rec_cnt ,oa.order_id ,orders->olist[cnt].orderid)
    endwhile
 
with nocounter
 
call echorecord(orders)
 
;----------------------------------------------------------------------------------------------
; Set up the feed
;if(iOpsInd = 1) ;Ops
  ;if($to_file = 0)  ;To File
 
   Select into value(filename_var)
 
	from (dummyt d WITH seq = value(size(orders->olist,5)))
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
			,wrap3(cnvtstring(orders->olist[d.seq].fin))
			,wrap3(cnvtstring(orders->olist[d.seq].orderid))
			,wrap3(cnvtstring(orders->olist[d.seq].ord_phys_number)) )
 
 		output_orders = trim(output_orders, 3)
 
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
 
 
 
 
#exitscript
 
end
go
 
