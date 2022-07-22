drop program cov_init_ops_planned_orders go
create program cov_init_ops_planned_orders

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to. 

with OUTDEV


%include cclsource:eks_rprq3091001.inc
%include cclsource:eks_run3091001.inc
 
record EKSOPSRequest (
1 expert_trigger = vc
1 qual[*]
2 person_id   = f8
2 sex_cd  = f8
2 birth_dt_tm  = dq8
2 encntr_id  = f8
2 accession_id  = f8
2 order_id  = f8
2 data[*]
3 vc_var   = vc
3 double_var   = f8
3 long_var   = i4
3 short_var   = i2
) 
 	
set stat = alterlist(EKSOPSRequest->qual,1) 

set stat = alterlist(EKSOPSRequest->qual[1].data,3) 

set EKSOPSRequest->qual[1].person_id = 2 
set EKSOPSRequest->expert_trigger = "COV_EE_OPS_PLAN_ORDERS" 
 
Set dparam = 0 
Call srvRequest(dparam) 

end go

 
