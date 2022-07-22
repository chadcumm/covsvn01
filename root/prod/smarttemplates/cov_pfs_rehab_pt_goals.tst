 
FREE RECORD REQUEST GO
RECORD REQUEST
(
1	VISIT[*]
	2	ENCNTR_ID	=	F8
1	PERSON_ID	=	F8
 
 
) GO
 
FREE RECORD REPLY GO
 
RECORD REPLY
(
1	TEXT	=	VC
 
) GO
 
SET STAT = ALTERLIST(request->visit, 1) go
 
SET request->visit[1].encntr_id =   103998742.00 go
 
cov_pfs_rehab_pt_goals go
 
 
