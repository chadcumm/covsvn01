drop program cov_eks_dc_med_orders go
create program cov_eks_dc_med_orders

free set t_rec
record t_rec
(
	1 link_encntr_id 		= f8
	1 order_cnt				= i2	
	1 order_qual[*]	
	 2 order_id				= f8
)

call echojson(eksdata, "eks_cov_eks_dc_med_orders_eksdata" , 0)

end go
