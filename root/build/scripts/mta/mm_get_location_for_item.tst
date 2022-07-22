

record REQUEST (
  1 qual [*]
    2 item_id = f8
  1 root_loc_cd = f8
  1 get_ic_ind = i2
  1 get_st_ind = i2
  1 get_ac_ind = i2
  1 get_qh_ind = i2
  1 get_qr_ind = i2
  1 get_parents_ind = i2
) go

set stat = alterlist(request->qual,1) go
set request->qual[1].item_id = 78510983 go
set request->root_loc_cd = 667024 go
set request->get_ic_ind = 1 go
set debug_on = 1 go

execute mm_get_location_for_item go
