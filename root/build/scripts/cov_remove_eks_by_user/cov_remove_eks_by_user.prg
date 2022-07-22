/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		06/22/2020
	Solution:				
	Source file name:	 	cov_remove_eks_by_user.prg
	Object name:		   	cov_remove_eks_by_user
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	06/22/2020  Chad Cummings			Initial Deployment
******************************************************************************/
drop program cov_remove_eks_by_user go
create program cov_remove_eks_by_user

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "USERNAME" = "" 

with OUTDEV, USERNAME

if ($USERNAME = " ")
	go to exit_script
endif

free record 3051002request	;EKS.Delete
record 3051002request (
  1 event_id = f8   
  1 location = vc  
) 

free record t_rec
record t_rec
(
	1 username = vc
	1 prsnl_id = f8
	1 cnt = i2
	1 qual[*]
	 2 notification_id = f8
) with protect

set t_rec->username = $USERNAME

select into "nl:"
from
	prsnl p
plan p
	where p.username = t_rec->username
detail
	t_rec->prsnl_id = p.person_id
with nocounter

if (t_rec->prsnl_id = 0)
	go to exit_script
endif

select into "nl:"
from 
	 eks_notifications en 
	,eks_notify_persn_r enpr
	,prsnl p
	,eks_notification_blob_r enbr
	,long_blob lb
plan en
join enpr
	where enpr.notification_id = en.notification_id
join p
	where p.person_id = enpr.person_id
	and   p.person_id = t_rec->prsnl_id
join enbr
	where enbr.notification_id = en.notification_id
join lb
	where lb.long_blob_id = enbr.long_blob_id
order by
	en.notification_id
head report
	i = 0
	pass = 0
head en.notification_id
	pass = 0
	pass = findstring("Invalid Ordering Provider and Communication Type",lb.long_blob)
foot en.notification_id
 if (pass > 0)
	i = (i + 1)
	stat = alterlist(t_rec->qual,i)
	t_rec->qual[i].notification_id = en.notification_id
 endif
foot report
	t_rec->cnt = i
with format(date,";;q"),uar_code(d),nocounter

for (i=1 to t_rec->cnt)
	set stat = initrec(3051002request)
	free record 3051002reply
	set 3051002request->event_id = t_rec->qual[i].notification_id
	set 3051002request->location = t_rec->username
	;call echorecord(3051002request)
	set stat = tdbexecute(3071000,3071000,3051002,"REC",3051002request,"REC",3051002reply) 
	call echorecord(3051002reply)
	update into eks_notify_persn_r set read_ind = 2 where notification_id = t_rec->qual[i].notification_id
	delete from eks_notifications where notification_id = t_rec->qual[i].notification_id
	commit
endfor

#exit_script

call echorecord(t_rec)

end
go
