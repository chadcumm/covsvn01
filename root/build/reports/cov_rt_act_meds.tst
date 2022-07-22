 
FREE RECORD a go
RECORD a
(
1	rec_cnt			=	i4
1	facility		=	vc
1	qual[*]
	2	personid	=	f8
	2	encntrid	=	f8
	2	name		=	vc
	2	mrn			=	vc
	2	fin			=	vc
	2	unit		=	vc
	2	room		=	vc
	2	bed			=	vc
	2	loc			=	vc
	2	ordcnt		=	i4
	2	ordqual[*]
		3	orderid	=	f8
		3	ordername	=	vc
		3	dose		=	vc
		3	freq		=	vc
		3	scheddttm	=	vc
		3	scheddatetm	=	f8
		3	orddttm		=	vc
		3	drugcategory = 	vc
		3	freqid		=	f8
 
 
 
) go
 
 
cov_rt_act_meds "mine", 2552503613.00 , 4 go
 
 
 
