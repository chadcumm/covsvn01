/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				     Chad Cummings
	Date Written:		   03/01/2019
	Solution:			     Perioperative
	Source file name:	 cov_eks_check_bh_dx_code.prg
	Object name:		   cov_eks_check_bh_dx_code
	Request #:

	Program purpose:

	Executing from:		EKS

 	Special Notes:		Called by EKS program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	03/01/2019  Chad Cummings
******************************************************************************/

drop program cov_eks_check_bh_dx_code:dba go
create program cov_eks_check_bh_dx_code:dba


call echo(build("loading script:",curprog))

free set t_rec
record t_rec
(
  1 eks_event_name          = vc
	1 order_cnt			    = i2
  1 dx_ind                  = i2
  1 detail_ind              = i2
  1 patient
	2 encntr_id 			= f8
	2 person_id 			= f8
  1 retval 					= i2
  1 log_message 			= vc
  1 log_misc1 				= vc
  1 return_value 			= vc
  1 filename 				= vc
  1 order_qual[*]
   2 dx_cnt                 = i2
   2 dx_qual[*]
    3 dx_id                 = f8
    3 source_string         = vc
    3 source_identifier     = vc
   2 detail_cnt             = i2
   2 detail_qual[*]
    3 oe_field_id           = f8
    3 oe_field_value        = f8
    3 oe_field_display      = vc
)

set t_rec->retval							= -1
set t_rec->return_value						= "FAILED"
set t_rec->patient.encntr_id 				= link_encntrid
set t_rec->patient.person_id				= link_personid
set t_rec->filename 						= concat(
														 "cclscratch:"
														,trim(cnvtlower(curprog))
														,"_rec_"
														,trim(format(sysdate,"yyyyMMddhhmmss;;q"))
														,".dat"
													 )

if (t_rec->patient.encntr_id <= 0.0)
	set t_rec->log_message = concat("link_encntrid not found")
	go to exit_script
endif

if (t_rec->patient.person_id <= 0.0)
	set t_rec->log_message = concat("link_personid not found")
	go to exit_script
endif

set t_rec->return_value = "FALSE"

set t_rec->eks_event_name = eks_common->event_name
set t_rec->order_cnt = size(request->orderlist,5)

if (t_rec->eks_event_name = "ADDTOSCRATCHPAD")
  for (i = 1 to t_rec->order_cnt)
  	;check order associated diagnosis codes
    set stat = alterlist(t_rec->order_qual,i)
	for (j = 1 to size(request->orderlist[i]->detaillist,5))
    	if (request->orderlist[i]->detaillist[j].oefieldmeaning = "ICD9")
    		if (request->orderlist[i]->detaillist[j].oefieldvalue > 0.0)
    			set t_rec->order_qual[i].dx_cnt = (t_rec->order_qual[i].dx_cnt + 1)
    			set stat = alterlist(t_rec->order_qual[i].dx_qual,t_rec->order_qual[i].dx_cnt)
      			set t_rec->order_qual[i].dx_qual[t_rec->order_qual[i].dx_cnt].dx_id = request->orderlist[i]->detaillist[j].oefieldvalue
      			set t_rec->dx_ind = 1
    		endif
    	endif
    endfor    
    
    if (t_rec->dx_ind = 0)
	    set t_rec->order_qual[i].dx_cnt = size(request->orderlist[i]->diagnosislist,5)
	    for (j = 1 to t_rec->order_qual[i].dx_cnt)
	      set stat = alterlist(t_rec->order_qual[i].dx_qual,j)
	      set t_rec->order_qual[i].dx_qual[j].dx_id = cnvtreal(request->orderlist[i]->diagnosislist[j].dx)
	      if (t_rec->order_qual[i].dx_qual[j].dx_id > 0.0)
	        set t_rec->dx_ind = 1
	      endif
	    endfor
    endif
    
    
  endfor
elseif (t_rec->eks_event_name = "SIGNORDER")
  for (i = 1 to t_rec->order_cnt)
    set stat = alterlist(t_rec->order_qual,i)
    for (j = 1 to size(request->orderlist[i]->detaillist,5))
    	if (request->orderlist[i]->detaillist[j].oefieldmeaning = "ICD9")
    		if (request->orderlist[i]->detaillist[j].oefieldvalue > 0.0)
    			if (t_rec->order_qual[i].dx_cnt < 1) ;only pull in the first ICD9 found
	    			set t_rec->order_qual[i].dx_cnt = (t_rec->order_qual[i].dx_cnt + 1)
	    			set stat = alterlist(t_rec->order_qual[i].dx_qual,t_rec->order_qual[i].dx_cnt)
	      			set t_rec->order_qual[i].dx_qual[t_rec->order_qual[i].dx_cnt].dx_id = request->orderlist[i]->detaillist[j].oefieldvalue
	      			set t_rec->dx_ind = 1
      			endif
    		endif
    	endif
    endfor
  endfor
endif

if ((t_rec->order_cnt = 0) or (t_rec->dx_ind = 0))
	go to exit_script
endif

select into "nl:"
from
   (dummyt d1 with seq = t_rec->order_cnt)
  ,(dummyt d2 with seq = 1)
  ,nomenclature n
plan d1
  where maxrec(d2,t_rec->order_qual[d1.seq].dx_cnt)
join d2
join n
  where n.nomenclature_id = t_rec->order_qual[d1.seq].dx_qual[d2.seq].dx_id
  and   n.nomenclature_id > 0.0
order by
  n.nomenclature_id
head n.nomenclature_id
  t_rec->order_qual[d1.seq].dx_qual[d2.seq].source_string       = n.source_string
  t_rec->order_qual[d1.seq].dx_qual[d2.seq].source_identifier   = n.source_identifier
with nocounter

for (i = 1 to t_rec->order_cnt)
  for (j = 1 to t_rec->order_qual[i].dx_cnt)
    if (t_rec->order_qual[i].dx_qual[j].source_identifier not in("F*","Z*"))
      set t_rec->detail_ind = (t_rec->detail_ind + 1)
      set t_rec->log_misc1 = concat(
        trim(t_rec->order_qual[i].dx_qual[j].source_string),
        " (",trim(t_rec->order_qual[i].dx_qual[j].source_identifier),")")
    endif
  endfor
endfor

if (t_rec->detail_ind > 0)
	set t_rec->return_value = "TRUE"
endif

#exit_script

if (trim(cnvtupper(t_rec->return_value)) = "TRUE")
	set t_rec->retval = 100
elseif (trim(cnvtupper(t_rec->return_value)) = "FALSE")
	set t_rec->retval = 0
else
	set t_rec->retval = 0
endif

set t_rec->log_message = concat(
										trim(t_rec->log_message),";",
										trim(cnvtupper(t_rec->return_value)),":",
										trim(cnvtstring(t_rec->patient.person_id)),"|",
										trim(cnvtstring(t_rec->patient.encntr_id)),"|"
									)

call echojson(t_rec,t_rec->filename,1)
call echojson(request,t_rec->filename,1)
call echojson(eks_common,t_rec->filename,1)

set retval									= t_rec->retval
set log_message 							= t_rec->log_message
set log_misc1 								= t_rec->log_misc1

end
go
