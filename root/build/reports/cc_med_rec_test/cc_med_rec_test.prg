drop program cc_med_rec_test go
create program cc_med_rec_test

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "FIN" = "" 

with OUTDEV, FIN


record t_rec
(
	1 prompts
	 2 fin = vc
)


record 500700_request (
  1 encntr_list [*]   
    2 encntr_id = f8   
  1 recon_type_list [*]   
    2 recon_type = i2  ; 1 - admission, 2 - transfer, 3 - discharge, 4 - short term leave, 5 - return from short term leave 
  1 load_most_recent_tx_ind = f8   
  1 person_id = f8   
)

record 500703_request (
  1 order_recon_id = f8   
  1 order_recon_qual [*]   
    2 order_recon_id = f8   
) 

declare i2 = i2 with noconstant(0), protect

set t_rec->prompts.fin = $FIN

set stat = alterlist(500700_request->recon_type_list,3)
set 500700_request->recon_type_list[1].recon_type = 1
set 500700_request->recon_type_list[2].recon_type = 2
set 500700_request->recon_type_list[3].recon_type = 3

select into "nl:"
from 
	 encntr_alias ea 
	,encounter e
plan ea
	where ea.alias = t_rec->prompts.fin
join e
	where e.encntr_id = ea.encntr_id
head report
	cnt = 0
detail
	cnt = (cnt + 1)
	500700_request->person_id = e.person_id
	stat = alterlist(500700_request->encntr_list,cnt)
	500700_request->encntr_list[cnt].encntr_id = ea.encntr_id
with nocounter

call echorecord(500700_request)

free record 500700_reply

set stat = tdbexecute(600005,500195,500700,"REC",500700_request,"REC",500700_reply)

if (validate(500700_reply))
	call echorecord(500700_reply)
else
	go to exit_script
endif

for (i=1 to size(500700_reply->encntr_list,5))
	set stat = alterlist(500703_request->order_recon_qual,i)
	set 500703_request->order_recon_qual[i].order_recon_id = 500700_reply->encntr_list[i].order_recon_id
endfor

if (size(500703_request->order_recon_qual,5) > 0)
	free record 500703_reply
	set stat = tdbexecute(600005,500195,500703,"REC",500703_request,"REC",500703_reply)
	if (validate(500700_reply))
		call echorecord(500703_reply)
		;call echo(cnvtrectojson(500703_reply))
	else
		go to exit_script
	endif
endif

#exit_script

end go