/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		06/30/2020
	Solution:			Perioperative
	Source file name:	cov_eks_ord_cosign.prg
	Object name:		cov_eks_ord_cosign
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s). 

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	----------------------------------
000 	06/30/2020  Chad Cummings			Initial Release
******************************************************************************/
drop program cov_eks_ord_cosign go
create program cov_eks_ord_cosign
 
prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "JSON" = "" 

with OUTDEV, JSON

/* incoming blob 
free record orderdata
record orderdata
(
	1 ordercnt = i2
	1 username = vc
	1 orderlist[*]
	 2 order_id = f8
	 2 synonym_id = f8
	1 powerplancnt = i2
	1 powerplans[*]
	 2 pathway_id = f8
)
*/
 
free record incoming_order
record incoming_order
(
	1 total 			= i2
	1 person_id			= f8
	1 encntr_id			= f8
	1 order_id			= f8
	1 pathway_id		= f8
	1 synonym			= vc
	1 conversation_id	= f8
	1 comm_type			= vc
	1 ordering_provider = vc
)

 
set _memory_reply_string = ""
 
if (validate(request->blob_in))
    if (request->blob_in > " ")
        set stat =  cnvtjsontorec(request->blob_in)
    else
        set _memory_reply_string = "request->blob_in NOT valid."
        go to exit_script
    endif
else
    set stat =  cnvtjsontorec($JSON)
endif

call echorecord(orderdata)

select into "nl:"
from
	 orders o
	,order_action oa
	,prsnl pr
	,(dummyt d1 with seq=orderdata->ordercnt)
plan d1
join o
	where o.order_id = orderdata->orderlist[d1.seq].order_id
join oa
	where oa.order_id = o.order_id
	and   oa.action_type_cd in(value(uar_get_code_by("MEANING",6003,"ORDER")))
join pr
	where pr.person_id = oa.order_provider_id
head report
	row +0
	i = 0
detail
	i = (i + 1)
	incoming_order->person_id = o.person_id
	incoming_order->conversation_id = oa.order_conversation_id
	incoming_order->comm_type = trim(uar_get_code_display(oa.communication_type_cd))
	incoming_order->ordering_provider = concat(trim(pr.name_full_formatted), " (",trim(uar_get_code_display(pr.position_cd)),")")
	if ((i > 1) and (i < orderdata->ordercnt))
		incoming_order->synonym = build2(incoming_order->synonym,", ")
	elseif (i = orderdata->ordercnt)
		incoming_order->synonym = build2(incoming_order->synonym," ")
	endif
	incoming_order->synonym = build2(incoming_order->synonym,trim(o.ordered_as_mnemonic))
foot report
	incoming_order->total = i
with nocounter

/*
select into "nl:"
from
	 pathway p
	,(dummyt d1 with seq=orderdata->powerplancnt)
plan d1
join p
	where p.pathway_id = orderdata->powerplans[d1.seq].pathway_id
head report
	row +0
	i = incoming_order->total
detail
	i = (i + 1)
	incoming_order->person_id = p.person_id
	;incoming_order->conversation_id = oa.order_conversation_id
	;incoming_order->comm_type = trim(uar_get_code_display(oa.communication_type_cd))
	;incoming_order->ordering_provider = concat(trim(pr.name_full_formatted), " (",trim(uar_get_code_display(pr.position_cd)),")")
	if ((i > 1) and (i < orderdata->ordercnt))
		incoming_order->synonym = build2(incoming_order->synonym,", ")
	elseif (i = orderdata->ordercnt)
		incoming_order->synonym = build2(incoming_order->synonym,", ")
		incoming_order->synonym = build2(incoming_order->synonym," ")
	endif
	incoming_order->synonym = build2(incoming_order->synonym,trim(p.description))
foot report
	row +0
with nocounter
*/
call echorecord(incoming_order)
set _memory_reply_string = cnvtrectojson(incoming_order)
call echo(_memory_reply_string)
#exit_script
end go
 
