drop program cov_pso_bh_review_audit go
create program cov_pso_bh_review_audit

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to. 

with OUTDEV


free set t_rec
record t_rec
(
	1 order_cat_cnt = i2
	1 order_cat[*]
	 2 catalog_cd = f8
	1 encntr_cnt = i2
	1 encntr_qual[*]
	 2 order_id = f8
	 2 encntr_id = f8
)

select into "nl:"
from
	order_catalog oc
plan oc
	where oc.description in(
								 "PSO Admit to Senior Behavioral Health"
								,"PSO Admit to Inpatient Rehab"
								,"PSO Admit to Skilled Nursing Facility"
								,"Behavioral Health 30 Day Readmit"
								,"Behavioral Health 30 Day Readmit Involuntary"   
								,"Behavioral Health Emergency Admit"
								,"Behavioral Health Voluntary Admit"
							)
	and oc.active_ind = 1
detail 
	t_rec->order_cat_cnt = (t_rec->order_cat_cnt + 1)
	stat = alterlist(t_rec->order_cat,t_rec->order_cat_cnt)
	t_rec->order_cat[t_rec->order_cat_cnt].catalog_cd = oc.catalog_cd
with nocounter


call echorecord(t_rec)

end go

