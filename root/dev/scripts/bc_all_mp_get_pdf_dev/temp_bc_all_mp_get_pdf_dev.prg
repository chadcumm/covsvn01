/*****************************************************************************
******************************************************************************

  Author:             Chad Cummings
  Date Written:       03/01/2019
  Solution:           
  Source file name:   bc_all_mp_get_pdf.prg
  Object name:        bc_all_mp_get_pdf
  Request #:

  Program purpose:

  Executing from:     

  Special Notes:       

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod   Mod Date    Developer              Comment
---   ----------  --------------------  --------------------------------------
001   10/01/2019  Chad Cummings			Initial Release
002   10/14/2020  Chad Cummings			Removed ORDERED as a valid status
003   10/15/2020  Chad Cummings			changed sorting to correct document date
******************************************************************************/
 
drop program bc_all_mp_get_pdf_dev:dba go
create program bc_all_mp_get_pdf_dev:dba
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "personId" = ""
	, "encntrId" = ""
 
with OUTDEV, personId, encntrId
 
 
execute bc_all_all_date_routines

free record 3011001Request
record 3011001Request (
  1 Module_Dir = vc  
  1 Module_Name = vc  
  1 bAsBlob = i2   
) 

free record 3011001Reply
record 3011001Reply (
    1 info_line [* ]
      2 new_line = vc
    1 data_blob = gvc
    1 data_blob_size = i4
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  )
   
record response (
	1 data[*]
		2 event_id					= f8
		2 clinical_event_id			= f8
		2 parent_event_id			= f8
		2 event_title_txt			= vc
		2 comment_txt				= vc
		2 ordering_provider			= vc
		2 service_dt_tm_txt			= vc
		2 requested_start_dt_tm_txt = vc
		2 reference_nbr				= vc
		2 status					= vc
		2 url						= vc	
		
)

free record t_rec
record t_rec
(
	1 cnt							= i2
	1 data[*]
		2 event_id					= f8
		2 clinical_event_id			= f8
		2 parent_event_id			= f8
		2 event_title_txt			= vc
		2 comment_txt				= vc
		2 ordering_provider			= vc
		2 service_dt_tm_txt			= vc
		2 service_dt_tm				= dq8
		2 requested_start_dt_tm_txt = vc
		2 requested_start_dt_tm		= dq8
		2 reference_nbr				= vc
		2 status					= vc
		2 url						= vc	
		2 valid_doc_ind				= i2
		2 multiple_order_dates_ind	= i2
		2 order_cnt					= i2
		2 order_qual[*]
		 3 order_id					= f8
		 3 order_status_cd			= f8
		 3 requisition_format_cd	= f8
		 3 requested_start_dt_tm	= dq8
)

declare html_output = vc with noconstant(" ")

set 3011001Request->Module_Dir = "ccluserdir:"
set 3011001Request->Module_Name = "print_to_pdf_comp.html"
set 3011001Request->bAsBlob = 1

execute eks_get_source with replace ("REQUEST" ,3011001Request ) , replace ("REPLY" ,3011001Reply )

if (3011001Reply->status_data.status = "S")
	set html_output = 3011001Reply->data_blob
else
	set html_output = "<html><body>Error with getting html source</body></html>"
endif

select into "nl:"
from
	 clinical_event ce
	,clinical_event pe
	,encounter e
	,ce_blob_result ceb
	,prsnl p
plan e
	where e.encntr_id = $encntrId
join ce
	where ce.person_id = e.person_id
	and   ce.encntr_id = e.encntr_id
;	and   ce.event_cd = value(uar_get_code_by("DISPLAY",72,"Print to PDF Requisition"))
	and   ce.event_cd = value(uar_get_code_by("DISPLAY",72,"Print to PDF Req"))
	and	  ce.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ;003 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
									 ;003 ,value(uar_get_code_by("MEANING",8,"INERROR"))
								)
	
	and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   ce.event_tag        != "Date\Time Correction"
join pe
	where pe.event_id = ce.parent_event_id
	and	  pe.result_status_cd in(
									  value(uar_get_code_by("MEANING",8,"AUTH"))
									 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
									 ;003 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
									 ;003 ,value(uar_get_code_by("MEANING",8,"INERROR"))
								)
	
	and   pe.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
	and   pe.event_tag        != "Date\Time Correction"
join ceb
	where ceb.event_id = ce.event_id
    and   ceb.valid_until_dt_tm >= cnvtdatetime(curdate,curtime3)
join p
	where p.person_id = ce.verified_prsnl_id
order by
	;003 ce.event_end_dt_tm desc
	 pe.event_end_dt_tm desc ;003
	,ce.event_end_dt_tm ;003
	,ce.clinical_event_id
	
head report
	i =0
detail
	i = (i+1)
	t_rec->cnt = i
	stat = alterlist(t_rec->data,i)
	t_rec->data[i].event_id =   ce.event_id
	t_rec->data[i].clinical_event_id =   ce.clinical_event_id
	t_rec->data[i].parent_event_id =   ce.parent_event_id
	t_rec->data[i].event_title_txt = pe.event_title_text
	t_rec->data[i].comment_txt = ""
	t_rec->data[i].reference_nbr = pe.reference_nbr
	t_rec->data[i].ordering_provider = p.name_full_formatted
	t_rec->data[i].service_dt_tm_txt = format(pe.event_end_dt_tm,"dd-mmm-yyyy hh:mm;;q")
	t_rec->data[i].service_dt_tm = pe.event_end_dt_tm
	t_rec->data[i].status = piece(t_rec->data[i].event_title_txt,":",1,"")
	if (t_rec->data[i].status = t_rec->data[i].event_title_txt)
		t_rec->data[i].status = "Pending"
	else
		t_rec->data[i].event_title_txt = replace(t_rec->data[i].event_title_txt,concat(t_rec->data[i].status,":"),"")
	endif
	t_rec->data[i].status = cnvtcap(t_rec->data[i].status)
with format(date,";;q"),uar_code(d)

;call showError(url_test)

declare notfnd = vc with constant("<not found>")
declare order_string = vc with noconstant(" ")
declare i = i2 with noconstant(0)
declare k = i2 with noconstant(0)
declare j = i2 with noconstant(0)
declare pos = i2 with noconstant(0)
declare prev_req_dt_tm = dq8 

for (i = 1 to size(t_rec->data,5))
	set k = 1
	set order_string = piece(t_rec->data[i].reference_nbr,":",k,notfnd)
	call echo(build("order_string=",order_string))
	while (order_string != notfnd)
		set order_string = piece(t_rec->data[i].reference_nbr,":",k,notfnd)
		call echo(build2("-->inside while order_string=",order_string))
		
		set pos = locateval(j,1,t_rec->data[i].order_cnt,cnvtreal(order_string),t_rec->data[i].order_qual[j].order_id)
		call echo(build2("-->inside while pos=",pos))
		if ((pos = 0) and (cnvtreal(order_string) > 0))
			set t_rec->data[i].order_cnt = (t_rec->data[i].order_cnt + 1)
			set stat = alterlist(t_rec->data[i].order_qual,t_rec->data[i].order_cnt)
			set t_rec->data[i].order_qual[t_rec->data[i].order_cnt].order_id = cnvtreal(order_string)
		endif
		set k = (k + 1)
	endwhile
endfor

select into "nl:"
from
	 (dummyt d1 with seq=t_rec->cnt)
	,(dummyt d2)
	,(dummyt d3)
	,orders o
	,order_catalog oc
	,order_detail od
plan d1
	where maxrec(d2,t_rec->data[d1.seq].order_cnt)
join d2
join o
	where o.order_id = t_rec->data[d1.seq].order_qual[d2.seq].order_id
	and   o.order_status_cd in(
									 value(uar_get_code_by("MEANING",6004,"FUTURE"))
									;002 ,value(uar_get_code_by("MEANING",6004,"ORDERED"))
								)
join oc
	where oc.catalog_cd = o.catalog_cd
join d3
join od
	where od.order_id = o.order_id
	and   od.oe_field_meaning = "REQSTARTDTTM"
order by
	o.order_id
	,od.action_sequence
head report
	stat = 0
	call echo("inside orders query")
head o.order_id
	call echo(o.order_id)
	t_rec->data[d1.seq].order_qual[d2.seq].requested_start_dt_tm = o.current_start_dt_tm
	t_rec->data[d1.seq].order_qual[d2.seq].order_status_cd = o.order_status_cd
	t_rec->data[d1.seq].order_qual[d2.seq].requisition_format_cd = oc.requisition_format_cd
head od.action_sequence
	t_rec->data[d1.seq].order_qual[d2.seq].requested_start_dt_tm = od.oe_field_dt_tm_value
foot o.order_id
	stat = 0
foot report
	stat = 0
with nocounter,outerjoin=d3,nullreport


select into "nl:"
	 event_id=t_rec->data[d1.seq].event_id
	,order_id=t_rec->data[d1.seq].order_qual[d2.seq].order_id
	,requested_start_dt_tm =t_rec->data[d1.seq].order_qual[d2.seq].requested_start_dt_tm
from
	 (dummyt d1 with seq=t_rec->cnt)
	,(dummyt d2)
plan d1
	where maxrec(d2,t_rec->data[d1.seq].order_cnt)
join d2
	;where t_rec->data[d1.seq].order_qual[d2.seq].order_status_cd = value(uar_get_code_by("MEANING",6004,"FUTURE"))
	where t_rec->data[d1.seq].order_qual[d2.seq].order_status_cd > 0.0
order by
	 event_id
	,requested_start_dt_tm
	,order_id
head report
	call echo("determining earliest requested start date and time")
	multiple_order_dates_ind = 0
head event_id
	multiple_order_dates_ind = 0
	call echo(build("event=",t_rec->data[d1.seq].event_id))
	prev_req_dt_tm = t_rec->data[d1.seq].order_qual[d2.seq].requested_start_dt_tm
	call echo(build("->first=",format(t_rec->data[d1.seq].order_qual[d2.seq].requested_start_dt_tm,";;q")))
	t_rec->data[d1.seq].requested_start_dt_tm = t_rec->data[d1.seq].order_qual[d2.seq].requested_start_dt_tm
head order_id
	call echo(build("->order_id=",order_id))
detail
	call echo(build("-->this=",format(t_rec->data[d1.seq].order_qual[d2.seq].requested_start_dt_tm,";;q")))
	call echo(build("-->prev_req_dt_tm=",format(t_rec->data[d1.seq].order_qual[d2.seq].requested_start_dt_tm,";;q")))
foot order_id
	if (t_rec->data[d1.seq].order_qual[d2.seq].order_status_cd = uar_get_code_by("MEANING",6004,"FUTURE"))
		if (prev_req_dt_tm != t_rec->data[d1.seq].order_qual[d2.seq].requested_start_dt_tm)
			multiple_order_dates_ind = 1
			call echo(build("--->multiple_order_dates_ind=",multiple_order_dates_ind))
		endif
		prev_req_dt_tm = t_rec->data[d1.seq].order_qual[d2.seq].requested_start_dt_tm
	endif
foot event_id
	t_rec->data[d1.seq].multiple_order_dates_ind = multiple_order_dates_ind
with nocounter

for (i=1 to t_rec->cnt)
	for (j=1 to t_rec->data[i].order_cnt)
		if (t_rec->data[i].order_qual[j].order_status_cd = uar_get_code_by("MEANING",6004,"FUTURE"))
			set t_rec->data[i].valid_doc_ind = 1
		endif
		if (t_rec->data[i].order_qual[j].order_status_cd = uar_get_code_by("MEANING",6004,"ORDERED"))
			if (t_rec->data[i].order_qual[j].requisition_format_cd = uar_get_code_by("MEANING",6002,"AMBREFERREQ"))
				set t_rec->data[i].valid_doc_ind = 1
			endif
		endif
	endfor
endfor

set i = 0
for (j=1 to t_rec->cnt)
 if (t_rec->data[j].valid_doc_ind = 1)
	set i = (i + 1)
	set stat = alterlist(response->data,i)
	set response->data[i].event_id 			=   t_rec->data[j].event_id
	set response->data[i].clinical_event_id 	=	t_rec->data[j].clinical_event_id
	set response->data[i].parent_event_id 		=	t_rec->data[j].parent_event_id
	set response->data[i].event_title_txt 		=	t_rec->data[j].event_title_txt
	set response->data[i].comment_txt 			= 	t_rec->data[j].comment_txt
	set response->data[i].reference_nbr 		= 	t_rec->data[j].reference_nbr
	set response->data[i].ordering_provider 	= 	t_rec->data[j].ordering_provider
	set response->data[i].service_dt_tm_txt 	= 	t_rec->data[j].service_dt_tm_txt
	set response->data[i].requested_start_dt_tm_txt = 	sCST_DATE(t_rec->data[j].requested_start_dt_tm)
	if (t_rec->data[j].multiple_order_dates_ind = 1)
		set response->data[i].requested_start_dt_tm_txt = CONCAT(response->data[i].requested_start_dt_tm_txt,"*")
	endif
	set response->data[i].status 				= 	t_rec->data[j].status
 endif
endfor

;SET _Memory_Reply_String = cnvtrectojson(response, 4, 1)


set html_output = replace(html_output,~@MESSAGE:[RESULTDATA]~,cnvtrectojson(response))
set _Memory_Reply_String = html_output

call echo(_Memory_Reply_String)
call echorecord(response)
call echorecord(t_Rec)

 
SUBROUTINE showError(sMsg)	;used to show errors to the end user
 
 	set t_rec->error_ind = 1
 	set t_rec->error_msg = sMsg
 
	SELECT INTO $OUTDEV
		MSG = sMsg
	FROM DUMMYT
	WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
END ;showError
 
#END_REPORT
 
end go
