free set 390051request go
record 390051request (
  1 dispense_hx_id = f8   
) go

free set 390051reply go
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
  ) go

set 390051request->dispense_hx_id = 18811251 go
call echorecord(390051request) go
set stat = tdbexecute(390000,380000,390051,"REC",390051request,"REC",390051reply) go ;rx_get_waste_prod_disp_hx
call echorecord(390051reply) go
