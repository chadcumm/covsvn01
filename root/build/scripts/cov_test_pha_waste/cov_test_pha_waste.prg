drop program cov_test_pha_waste go
create program cov_test_pha_waste 

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Order ID" = 2191870143 

with OUTDEV, ORDER_ID

free record 390055request ;rx_get_waste_misc_info
record 390055request (
  1 order_id = f8   
  1 facility_cd = f8   
)

free record 390058request ;rx_get_waste_history
record 390058request (
  1 dispense_hx_id = f8   
) 

free record 390058reply
RECORD 390058reply (
    1 order_id = f8
    1 dispense_hx_id = f8
    1 disp_event_type_cd = f8
    1 disp_event_type_display = vc
    1 disp_event_type_meaning = vc
    1 dispense_dt_tm = dq8
    1 dispense_tz = i4
    1 action_seq = i4
    1 wastelist [* ]
      2 dispense_hx_id = f8
      2 updt_dt_tm = dq8
      2 disp_event_type_cd = f8
      2 disp_event_type_display = vc
      2 disp_event_type_meaning = vc
      2 credit_disp_hx_id = f8
      2 credit_updt_dt_tm = dq8
      2 credit_disp_event_type_cd = f8
      2 credit_disp_event_type_display = vc
      2 credit_disp_event_type_meaning = vc
      2 prodlist [* ]
        3 waste_charge_prod_disp_hx_id = f8
        3 item_id = f8
        3 med_product_id = f8
        3 prod_desc = vc
        3 generic_name = vc
        3 manufacturer_name = vc
        3 drug_identifier = vc
        3 manf_item_id = f8
        3 strength = f8
        3 strength_unit_cd = f8
        3 strength_unit_display = vc
        3 volume = f8
        3 volume_unit_cd = f8
        3 volume_unit_display = vc
        3 dispense_qty = f8
        3 dispense_qty_unit_cd = f8
        3 dispense_qty_unit_display = vc
        3 wasted_qty = f8
        3 charge_qty = f8
        3 unrounded_charge_qty = f8
        3 qpd = f8
        3 cost = f8
        3 price = f8
        3 tax_amt = f8
        3 scan_flag = i2
    1 ingred_action_seq = i4
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )

free record 380017request	;rx_get_order_dispense_hx
record 380017request (
  1 order_id = f8   
) 

free record 380017reply 
record 380017reply (
   1 qual [*]
     2 action_sequence = i4
     2 disp_event_type_cd = f8
     2 reason_cd = f8
     2 doses = f8
     2 run_user_id = f8
     2 first_dose_time = dq8
     2 dispense_dt_tm = dq8
     2 fill_batch_cd = f8
     2 dispense_hx_id = f8
     2 event_total_price = f8
     2 charge_ind = i2
     2 first_dose_time_tz = i4
     2 dispense_tz = i4
     2 prod_dispense [* ]
       3 dispense_hx_id = f8
       3 ingred_sequence = i4
       3 manf_description = c100
       3 item_id = f8
       3 price_sched_id = f8
       3 charge_qty = f8
       3 prod_dispense_hx_id = f8
       3 manf_item_id = f8
       3 tnf_id = f8
       3 credit_qty = f8
       3 compound_flag = i2
     2 first_iv_seq = i4
     2 disp_loc_cd = f8
     2 future_charge_ind = i2
     2 personnel_id = f8
     2 witness_id = f8
     2 workflow_sequence_cd = f8
     2 workflow_status_cd = f8
     2 prev_workflow_status_cd = f8
     2 prev_status_chg_dt_tm = dq8
     2 prev_status_chg_user_id = f8
     2 owe_doses = f8
     2 add_owe_doses_ind = i2
     2 transfer_to_loc_cd = f8
     2 updt_dt_tm = dq8
     2 charge_credit_flag = i2
     2 admin_list [* ]
       3 rx_admin_dispense_hx_id = f8
       3 ref_rx_admin_dispense_hx_id = f8
       3 admin_dt_tm = dq8
       3 admin_tz = i4
       3 charge_flag = i2
       3 doses = f8
       3 total_price_amt = f8
       3 updt_dt_tm = dq8
       3 prod_list [* ]
         4 rx_admin_prod_dispense_hx_id = f8
         4 item_id = f8
         4 tnf_id = f8
         4 charge_qty = f8
         4 credit_qty = f8
         4 price_amt = f8
         4 tax_amt = f8
     2 run_user_name_formatted = vc
     2 personnel_name_formatted = vc
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 
set 380017request->order_id = $ORDER_ID

call echorecord(380017request)
set stat = tdbexecute(380000,380900,380017,"REC",380017request,"REC",380017reply) ;rx_get_order_dispense_hx
call echorecord(380017reply)

set 390058request->dispense_hx_id = 34925012

call echorecord(390058request)
set stat = tdbexecute(380000,380000,390058,"REC",390058request,"REC",390058reply) ;rx_get_waste_history
call echorecord(390058reply)



end 
go
