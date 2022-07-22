drop program cov_ed_pager_test go

create program cov_ed_pager_test



record EKSOPSRequest (

   1 expert_trigger	= vc

   1 qual[*]

	2 person_id	= f8

	2 sex_cd	= f8

	2 birth_dt_tm	= dq8

	2 encntr_id	= f8

	2 accession_id	= f8

	2 order_id	= f8

	2 data[*]

	     3 vc_var		= vc

	     3 double_var	= f8

	     3 long_var		= i4

	     3 short_var	= i2

)



%i cclsource:eks_rprq3091001.inc



select into "NL:"

	e.encntr_id,

	e.person_id,

	e.reg_dt_tm,

	p.birth_dt_tm,

	p.sex_cd

from

	person p,

	encounter e



plan e where e.encntr_id = 110461982                                

join p where p.person_id= e.person_id

head report

	cnt = 0

	EKSOPSRequest->expert_trigger = "CCUMMIN4_TEST_PAGE"

detail

	cnt = cnt +1

	if(mod(cnt,100) = 1)

		stat = alterlist(EKSOPSRequest->qual, cnt +99)

	endif

	EKSOPSRequest->qual[cnt].person_id = p.person_id

	EKSOPSRequest->qual[cnt].sex_cd  = p.sex_cd

	EKSOPSRequest->qual[cnt].birth_dt_tm  = p.birth_dt_tm

	EKSOPSRequest->qual[cnt].encntr_id  = e.encntr_id

	call echo(e.encntr_id)

foot report

	 stat = alterlist(EKSOPSRequest->qual, cnt)

with nocounter



call echorecord(EKSOPSRequest)

/*

Use the following commands to create and call the sub-routine that sends

the data in the EKSOPSRequest to the Expert Servers.

*/



%i cclsource:eks_run3091001.inc

set dparam = 0

call srvRequest(dparam)



end go


