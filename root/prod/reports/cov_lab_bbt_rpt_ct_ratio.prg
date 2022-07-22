 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha
	Date Written:		June 2019
	Solution:			Lab/Quality
	Source file name:	      cov_lab_bbt_rpt_ct_ratio.prg
	Object name:		cov_lab_bbt_rpt_ct_ratio
	Request#:			1048
	Program purpose:
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
DROP PROGRAM cov_lab_bbt_rpt_ct_ratio :dba GO
CREATE PROGRAM cov_lab_bbt_rpt_ct_ratio :dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
 
with OUTDEV, start_datetime, end_datetime
 
Version 2 
;------------------------------------------------------
	;Modified new version - 2
;------------------------------------------------------
declare assigned_var   = f8 with constant(uar_get_code_by("DISPLAY", 1610, 'Assigned')),product
declare dispensed_var  = f8 with constant(uar_get_code_by("DISPLAY", 1610, 'Dispensed')),product
declare crossmatch_var = f8 with constant(uar_get_code_by("DISPLAY", 1610, 'Crossmatched')),product
declare transfused_var = f8 with constant(uar_get_code_by("DISPLAY", 1610, 'Transfused')),product
;declare cnt = i4 with noconstant(0)
 
RECORD output(
   1 list[*]
     2 productid = f8
     2 product_eventid = f8
     2 product_type = vc
     2 product_category = vc
     2 owner_area = vc
     2 inventory_area = vc
     2 med_service = vc
     2 order_provider_name = vc
     2 bb_result_id = f8
     2 crossmatch_cnt = i4
     2 crossmatch_tot = i4
     2 transfuse_cnt = i4
     2 transfuse_tot = i4
     2 assigned_cnt = i4
     2 assigned_tot = i4
     2 dispense_cnt = i4
     2 dispense_tot = i4
     2 crossmatched_ratio = f8
     2 assigned_ratio = f8
 )
 
;------------------------------------------------------------------------------------------------------------------
;Qualification - Crossmatch
 
select into 'nl:'
 
p.product_id, pe.product_event_id, pe.bb_result_id
, owner_area_disp = uar_get_code_display(p.cur_owner_area_cd)
, inventory_area_disp = uar_get_code_display(p.cur_inv_area_cd)
, product_disp = uar_get_code_display(p.product_cd)
, product_cat_disp = uar_get_code_display(p.product_cat_cd)
, physician = trim(pr.name_full_formatted)
, medical_service = uar_get_code_display(e.med_service_cd)
 
from crossmatch cm
    ,product_event pe
    ,product p
    ,orders o
    ,prsnl pr
    ,encounter e
 
plan pe where pe.event_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and pe.event_type_cd = crossmatch_var
 
join cm where cm.product_id = pe.product_id
	and cm.product_event_id = pe.product_event_id
	;where cm.crossmatch_exp_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
 
join p where p.product_id = pe.product_id
    and p.cur_owner_area_cd = 2555140621.00 ;PWMC BB Owner Area
    and p.cur_inv_area_cd = 2555140629.00 ;PWMC BB Inv Area
 
join o where o.order_id = pe.order_id
 
join e where e.encntr_id = o.encntr_id
 
join pr where pr.person_id = o.last_update_provider_id
 
order by pe.product_id, pe.product_event_id
 
Head report
	cnt = 0
	cm_tot = 0
	call alterlist(output->list, 10)
 
Head pe.product_event_id
	cnt += 1
	call alterlist(output->list, cnt)
	output->list[cnt].productid = pe.product_id
	output->list[cnt].product_eventid = pe.product_event_id
	output->list[cnt].owner_area = owner_area_disp
	output->list[cnt].inventory_area = inventory_area_disp
	output->list[cnt].product_type = product_disp
	output->list[cnt].product_category = product_cat_disp
 	output->list[cnt].med_service = medical_service
 	output->list[cnt].crossmatch_cnt = 1
 	output->list[cnt].order_provider_name = trim(pr.name_full_formatted)
 
with nocounter
 
;-------------------------------------------------------------------------------------------------------------
;Qualification - Transfused
 
select into $outdev **** orders not availabe so couldn't pull provider info. *****
 
i.product_id, i.product_event_id, i.bb_result_id
, owner_area_disp = uar_get_code_display(i.cur_owner_area_cd)
, inventory_area_disp = uar_get_code_display(i.cur_inv_area_cd)
, product_disp = uar_get_code_display(i.product_cd)
, product_cat_disp = uar_get_code_display(i.product_cat_cd)
, physician = trim(pr.name_full_formatted)
, medical_service = uar_get_code_display(e.med_service_cd)
 
from product_event pe
, orders o
, prsnl pr
, encounter e
, (
  (select distinct pe.product_id, pe.product_event_id, pe.bb_result_id, p.cur_inv_area_cd, p.cur_owner_area_cd
  	, p.product_cd, p.product_cat_cd
	from product_event pe, product p
 	where pe.product_id = p.product_id
      and pe.event_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
      and p.cur_owner_area_cd = 2555140621.00 ;PWMC BB Owner Area
      and p.cur_inv_area_cd = 2555140629.00 ;PWMC BB Inv Area
	and pe.event_type_cd = transfused_var
 	and pe.active_ind = 1
 	with sqltype('f8','f8','f8','f8','f8','f8','f8')
	)i
)
 
plan i
 
join pe where pe.product_id = i.product_id
	and pe.order_id != 0
 
join o where o.order_id = pe.order_id
 
join e where e.encntr_id = o.encntr_id
 
join pr where pr.person_id = o.last_update_provider_id
	and o.last_update_provider_id != 0
 
order by pe.product_id, pe.product_event_id
 
Head pe.product_event_id
	cnt += 1
	call alterlist(output->list, cnt)
	output->list[cnt].productid = pe.product_id
	output->list[cnt].product_eventid = pe.product_event_id
	output->list[cnt].owner_area = owner_area_disp
	output->list[cnt].inventory_area = inventory_area_disp
	output->list[cnt].product_type = product_disp
	output->list[cnt].product_category = product_cat_disp
 	output->list[cnt].med_service = medical_service
 	output->list[cnt].transfuse_cnt = 1
 	output->list[cnt].order_provider_name = trim(pr.name_full_formatted)
 
with nocounter
 
call echorecord(output)
 
end go

;********************************************************************************************************
;********************************************************************************************************
Version 1
;------------------------------------------------------
	;Modified new version - 1
;------------------------------------------------------
 
 
 SET sline = fillstring (125 ,"-" )
 
 DECLARE crossmatch_event_cd = f8
 DECLARE dispense_event_cd = f8
 DECLARE transfuse_event_cd = f8
 DECLARE assigned_event_cd = f8
 DECLARE prod_xm_cnt = f8
 DECLARE prod_disp_cnt = f8
 DECLARE prod_xm_trans_cnt = f8
 DECLARE prod_perc = f8
 DECLARE default_start_date = dq8 WITH constant (cnvtdatetime ("01-JAN-1900 00:00:00.00" ) )
 DECLARE owner_disp = vc WITH noconstant (" " ), protected
 DECLARE inventory_disp = vc WITH noconstant (" " ), protected
 DECLARE dtbegin = dq8 WITH noconstant (cnvtdatetime (default_start_date ) )
 DECLARE dtend = dq8 WITH noconstant (cnvtdatetime (default_start_date ) )
 DECLARE dtcur = dq8 WITH noconstant (cnvtdatetime (curdate ,curtime3 ) )
 DECLARE serrmsg = c132 WITH noconstant (fillstring (132 ," " ) )
 DECLARE ierrcode = i4 WITH noconstant (error (serrmsg ,1 ) )
 DECLARE istatusblkcnt = i4 WITH noconstant (0 )
 DECLARE istat = i2 WITH noconstant (0 )
 DECLARE all = vc WITH constant ("All" )
 DECLARE cur_owner_area_disp = c40 WITH noconstant (" " ), protected
 DECLARE provider_disp = c40 WITH noconstant (" " ), protected
 DECLARE cur_inv_area_disp = c40 WITH noconstant (" " ), protected
 DECLARE dm_domain = vc WITH constant ("PATHNET_BBT" )
 DECLARE dm_name = vc WITH noconstant ("LAST_CT_REPORT_DT_TM" )
 DECLARE prod_cnt = i4 WITH noconstant (0 )
 
 SET stat = uar_get_meaning_by_codeset (1610 ,"3" ,1 ,crossmatch_event_cd )
 SET stat = uar_get_meaning_by_codeset (1610 ,"4" ,1 ,dispense_event_cd )
 SET stat = uar_get_meaning_by_codeset (1610 ,"7" ,1 ,transfuse_event_cd )
 SET stat = uar_get_meaning_by_codeset (1610 ,"1" ,1 ,assigned_event_cd )
 
 DECLARE check_facility_cd ((script_name = vc ) ) = null
 DECLARE check_exception_type_cd ((script_name = vc ) ) = null
 
 SET prod_cnt = 0
 
 RECORD output(
   1 list[*]
     2 product_id = f8
     2 product_cd = f8
     2 product_disp = vc
     2 product_cat_cd = f8
     2 product_cat_disp = vc
     2 order_provider_id = f8
     2 order_provider_name = vc
     2 bb_result_id = f8
     2 xm_cnt = i4
     2 units_crossmatched = i4
     2 units_transfused = i4
     2 units_assigned = i4
     2 owner_area_disp = vc
     2 inv_area_disp = vc
     2 med_service = vc
     2 ct_ratio = f8
     2 asign_ratio = f8
 )
 
 RECORD xm (
   1 prod_qual [* ]
     2 product_id = f8
     2 product_cd = f8
     2 product_disp = vc
     2 product_cat_cd = f8
     2 product_cat_disp = vc
     2 order_provider_id = f8
     2 order_provider_name = vc
     2 bb_result_id = f8
     2 xm_cnt = i4
     2 transfuse_cnt = i4
     2 assign_cnt = i4
     2 owner_area_disp = vc
     2 inv_area_disp = vc
     2 med_service_cd = f8
 )
 
;------------------------------------------------------------------------------------------------------------------
;Qualification - Crossmatch
 
select into 'nl:'
 
owner_area = uar_get_code_display(p.cur_owner_area_cd)
, inventory_area = uar_get_code_display(p.cur_inv_area_cd)
, product_category = uar_get_code_display(p.product_cat_cd)
, physician = trim(pl.name_full_formatted)
, medical_service = uar_get_code_display(en.med_service_cd)
 
from (crossmatch xm ),
    (product_event pe ),
    (product p ),
    (orders o ),
    (prsnl pl ),
    (product_event pe_alt ),
    (encounter en )
 
plan xm where xm.crossmatch_exp_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
 
join pe where pe.product_event_id = xm.product_event_id
 
join p where p.product_id = pe.product_id
    and p.cur_owner_area_cd =  2555140621.00 ;PWMC BB Owner Area
  	;OR request->cur_owner_area_cd = 0.0
   ; AND (((request->cur_inv_area_cd > 0.0 )
    and p.cur_inv_area_cd = 2555140629.00 ;PWMC BB Inv Area    ;) ) OR ((request->cur_inv_area_cd = 0.0 ) )) )
 
join o where o.order_id = pe.order_id
    ;AND (((request->provider_id > 0.0 )
    ;and o.last_update_provider_id = request->provider_id ;) ) OR ((request->provider_id = 0.0 ) )) )
 
join pl where pl.person_id = o.last_update_provider_id
 
join pe_alt where pe_alt.bb_result_id = pe.bb_result_id
    and pe_alt.event_type_cd = crossmatch_event_cd
 
join en where en.encntr_id = o.encntr_id
 
order by pe.bb_result_id, pe_alt.product_id, pe_alt.product_event_id DESC
 
Head report
    xm_found = 0,
    first_product_cd = 0.0
Head pe.bb_result_id
    xm_found = 0 ,first_product_id = pe_alt.product_id
Detail
    IF ((xm_found = 0 ) AND (pe_alt.product_id = first_product_id ) )
      IF ((p.product_id = pe_alt.product_id ) )
         IF ((xm.product_event_id = pe_alt.product_event_id ))
         	xm_found = 1, prod_cnt = (prod_cnt + 1)
         	,IF((size(xm->prod_qual ,5 ) < prod_cnt ))
         		stat = alterlist (xm->prod_qual ,(prod_cnt + 10))
       	ENDIF
       	,xm->prod_qual[prod_cnt ].product_id = p.product_id
       	,xm->prod_qual[prod_cnt ].product_cd = p.product_cd
       	,xm->prod_qual[prod_cnt ].product_disp = uar_get_code_display (p.product_cd )
	       	/*,IF((request->debug_ind = 1 ) ) xm->prod_qual[prod_cnt ].product_disp =
	       		build (p.product_nbr,"_" ,pe.product_event_id )
	       	ELSE xm->prod_qual[prod_cnt ].product_disp = uar_get_code_display (p.product_cd )
	       	ENDIF*/
	       ,xm->prod_qual[prod_cnt ].bb_result_id = pe.bb_result_id
	       ,xm->prod_qual[prod_cnt ].order_provider_id = o.last_update_provider_id
	       ,xm->prod_qual[prod_cnt ].order_provider_name = trim (pl.name_full_formatted )
	       ,xm->prod_qual[prod_cnt ].product_cat_cd = p.product_cat_cd
	       ,xm->prod_qual[prod_cnt ].product_cat_disp = uar_get_code_display (p.product_cat_cd )
	       ,xm->prod_qual[prod_cnt ].xm_cnt = 1
	       ,xm->prod_qual[prod_cnt ].owner_area_disp = uar_get_code_display (p.cur_owner_area_cd )
	       ,xm->prod_qual[prod_cnt ].inv_area_disp = uar_get_code_display(p.cur_inv_area_cd )
	       ,xm->prod_qual[prod_cnt ].med_service_cd = en.med_service_cd
	   ENDIF
      ENDIF
    ENDIF
FOOT REPORT
    stat = alterlist (xm->prod_qual ,prod_cnt),
    row + 1
 
WITH nocounter
 
;----------------------------------------------------------------------------------------------
;Qualification - Transfusion
 
set idx1 = 0
select into "nl:"
 
from (dummyt d1 WITH seq = value (prod_cnt ) ),
    (product_event pe_xm ),
    (product_event pe_disp ),
    (product_event pe_tx )
 
plan d1
 
join pe_xm where pe_xm.bb_result_id = xm->prod_qual[d1.seq ].bb_result_id
    and pe_xm.event_type_cd = crossmatch_event_cd
 
join pe_disp where pe_disp.related_product_event_id = pe_xm.product_event_id
    and pe_disp.event_type_cd = dispense_event_cd
 
join pe_tx where pe_tx.related_product_event_id = pe_disp.product_event_id
    and pe_tx.event_type_cd = transfuse_event_cd
    and pe_tx.active_ind = 1
 
order by pe_xm.bb_result_id
 
Head pe_xm.bb_result_id
    IF ((pe_tx.product_event_id != 0 ) )
    	  xm->prod_qual[d1.seq ].transfuse_cnt = 1
    ENDIF
 
with nocounter
 
;----------------------------------------------------------------------------------------------
 
;Qualification - Assigned
 
select into 'nl:'
	pe.bb_result_id, pe.encntr_id, pe.order_id
	, event_type = uar_get_code_display(pe.event_type_cd)
	, product_category = uar_get_code_display(p.product_cat_cd)
	, product_type = uar_get_code_display(p.product_cd)
	, pe.product_event_id, pe.product_id
	, event_dt = format(pe.event_dt_tm, 'mm/dd/yyyy hh:mm;;q')
 
from product_event pe
	,product p
	,encounter e
 
plan pe where pe.event_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
 
join p where p.product_id = pe.product_id
	and pe.event_type_cd = 1429.00 ;assigned
	and p.cur_owner_area_cd =  2555140621.00 ;PWMC BB Owner Area
	and p.cur_inv_area_cd = 2555140629.00 ;PWMC BB Inv Area
	and p.active_ind = 1
 
join e where e.encntr_id = pe.encntr_id
 
order by e.encntr_id, pe.product_id, pe.product_event_id
 
Head e.encntr_id
	num = 0
	par = 0
      idx = 0
	idx = locateval(cnt,1,size(output->list,5), e.encntr_id, output->list[num].encntrid)
 
Detail
	if(idx > 0)
		par = idx
	else
		cnt += 1
		par = cnt
	endif
 	call alterlist(output->list, par)
		output->list[cnt].owner_area_disp =	uar_get_code_display (p.cur_owner_area_cd)
		output->list[cnt].inv_area_disp = uar_get_code_display(p.cur_inv_area_cd )
		output->list[cnt].med_service = uar_get_code_display(e.med_service_cd)
		output->list[cnt].product_cat_disp = uar_get_code_display(p.product_cat_cd)
		output->list[cnt].product_disp = uar_get_code_display(p.product_cd)
		output->list[cnt].product_id = p.product_id
		output->list[cnt].units_assigned = 1
 
	      /*IF ((prod_xm_trans_cnt = 0 ) ) prod_perc = prod_xm_cnt
	     	ELSE prod_perc = (prod_xm_cnt / prod_xm_trans_cnt )
	      ENDIF
	      output->list[cnt].ct_ratio = prod_perc
	      output->list[cnt].order_provider_name = prev_provider_disp*/
 
with nocounter
 
call echorecord(output)
 
;----------------------------------------------------------------------------------------------------------------------
 
 ;DECLARE generatereport () = i2
 ;SUBROUTINE  generatereport (null )
  DECLARE res_count = i4 WITH noconstant (0 )
  DECLARE sfilename = vc WITH noconstant ("" )
  SET formatdtcur = format (dtcur ,"DD-MMM-YYYY HH:MM:SS;;D" )
  SET formatdtbegin = format (dtbegin ,"DD-MMM-YYYY HH:MM:SS;;D" )
  SET formatdtend = format (dtend ,"DD-MMM-YYYY HH:MM:SS;;D" )
  ;SET logical d value (trim (logical ("CER_PRINT" ) ) )
  ;SET sfilename = concat ("d:bbt_rpt_ct_ratio" ,format (dtcur ,"YYMMDDHHMMSSCC;;d" ) ,".xml" )
  ;SET reply->file_name = concat ("cer_print:bbt_rpt_ct_ratio" ,format (dtcur ,"YYMMDDHHMMSSCC;;d" ) ,
  ; ".xml" )
 
SET res_count = prod_cnt
 
select into 'nl:'
   provider_name = xm->prod_qual[d1.seq].order_provider_name
   ,provider_id = xm->prod_qual[d1.seq].order_provider_id
   ,prod_disp = xm->prod_qual[d1.seq].product_disp
   ,product_cat_disp = trim(xm->prod_qual[d1.seq].product_cat_disp)
   ,prod_id = xm->prod_qual[d1.seq].product_id
   ,owner_area_disp = trim(xm->prod_qual[d1.seq].owner_area_disp)
   ,inv_area_disp = trim(xm->prod_qual[d1.seq].inv_area_disp)
   ,med_service = trim(uar_get_code_display(xm->prod_qual[d1.seq].med_service_cd))
 
from (dummyt d1 with seq = value(prod_cnt ))
plan (d1)
 
order by provider_name, provider_id, prod_disp, med_service
 
Head report
    cnt = 0
    call alterlist(output->list, 10)
 
    prev_med_serv_cd = xm->prod_qual[d1.seq ].med_service_cd ,
    prev_inv_area_disp = inv_area_disp ,
    prev_provider_disp = provider_name ,
    prev_prod_disp = prod_disp ,
    prev_prod_id = prod_id ,
    prev_med_service_disp = med_service ,
    prev_owner_area_disp = owner_area_disp ,
    prev_product_cat_disp = product_cat_disp ,
    prod_xm_cnt = 0 ,
    prod_xm_trans_cnt = 0 ,
    prod_perc = 0.0
 
Detail
    IF ((prod_xm_cnt >= 1 ) AND (((xm->prod_qual[d1.seq ].med_service_cd != prev_med_serv_cd ) )
	    	OR ((((xm->prod_qual[d1.seq].inv_area_disp != prev_inv_area_disp ) )
	    	OR ((((xm->prod_qual[d1.seq ].order_provider_name != prev_provider_disp ) )
	    	OR ((xm->prod_qual[d1.seq ].product_disp != prev_prod_disp ) )) )) )) )
 
 		cnt += 1
 		call alterlist(output->list, cnt)
		output->list[cnt].owner_area_disp =	prev_owner_area_disp
		output->list[cnt].inv_area_disp = prev_inv_area_disp
		output->list[cnt].product_cat_disp = prev_product_cat_disp
		output->list[cnt].product_disp = prev_prod_disp
		output->list[cnt].product_id = prev_prod_id
		output->list[cnt].units_crossmatched = prod_xm_cnt
		output->list[cnt].units_transfused = prod_xm_trans_cnt
		;output->list[cnt].units_assigned
 
	      IF ((prod_xm_trans_cnt = 0 ) ) prod_perc = prod_xm_cnt
	     	ELSE prod_perc = (prod_xm_cnt / prod_xm_trans_cnt )
	      ENDIF
	      output->list[cnt].ct_ratio = prod_perc
	      output->list[cnt].order_provider_name = prev_provider_disp
		output->list[cnt].med_service = prev_med_service_disp
 
	      prod_xm_cnt = 0 ,prod_xm_trans_cnt = 0 ,prod_perc = 0.00
    ENDIF
 
    ,prod_xm_cnt = (prod_xm_cnt + xm->prod_qual[d1.seq ].xm_cnt ) ,
    IF ((xm->prod_qual[d1.seq ].bb_result_id > 0)) prod_xm_trans_cnt = (prod_xm_trans_cnt + xm->prod_qual[d1.seq ].transfuse_cnt)
    ENDIF
    ,prev_owner_area_disp = owner_area_disp ,
    prev_med_serv_cd = xm->prod_qual[d1.seq ].med_service_cd ,
    prev_inv_area_disp = inv_area_disp ,
    prev_provider_disp = provider_name ,
    prev_prod_disp = prod_disp ,
    prev_prod_id = prod_id ,
    prev_product_cat_disp = product_cat_disp ,
    prev_med_service_disp = med_service
 
with nocounter
 
;----------------------------------------------------------------------------------------------
 
SELECT INTO $OUTDEV
 
	LIST_OWNER_AREA_DISP = SUBSTRING(1, 50, OUTPUT->list[D1.SEQ].owner_area_disp)
	, LIST_INV_AREA_DISP = SUBSTRING(1, 50, OUTPUT->list[D1.SEQ].inv_area_disp)
	, LIST_PRODUCT_ID = OUTPUT->list[D1.SEQ].product_id
	, LIST_PRODUCT_DISP = SUBSTRING(1, 100, OUTPUT->list[D1.SEQ].product_disp)
	, LIST_PRODUCT_CAT_DISP = SUBSTRING(1, 100, OUTPUT->list[D1.SEQ].product_cat_disp)
	, LIST_ORDER_PROVIDER_NAME = SUBSTRING(1, 50, OUTPUT->list[D1.SEQ].order_provider_name)
	, LIST_BB_RESULT_ID = OUTPUT->list[D1.SEQ].bb_result_id
	, LIST_UNITS_CROSSMATCHED = OUTPUT->list[D1.SEQ].units_crossmatched
	, LIST_UNITS_TRANSFUSED = OUTPUT->list[D1.SEQ].units_transfused
	, LIST_CT_RATIO = OUTPUT->list[D1.SEQ].ct_ratio
	, LIST_UNITS_ASSIGNED = OUTPUT->list[D1.SEQ].units_assigned
	, LIST_MED_SERVICE = SUBSTRING(1, 30, OUTPUT->list[D1.SEQ].med_service)
 
FROM
	(DUMMYT   D1  WITH SEQ = SIZE(OUTPUT->list, 5))
 
PLAN D1
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
END GO
 

