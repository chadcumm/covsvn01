 
 
FREE RECORD REQUEST GO
RECORD REQUEST
(
1	BATCH_SELECTION = VC
) GO
 
set REQUEST->BATCH_SELECTION = "Testing Ops" go
 
;cov_rt_charges "mine", 2552503613.00, "18-jun-2018 00:00", "18-jun-2018 23:59" go
 
;cov_pend_tasks_rt_pt_ot_sp "mine",2552503613.00, 636078.00,"01-jun-2018 00:00", "01-jun-2018 23:59" go
cov_pend_tasks_ops go
