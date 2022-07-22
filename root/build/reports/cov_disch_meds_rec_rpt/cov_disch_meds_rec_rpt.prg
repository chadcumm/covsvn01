drop program cov_disch_meds_rec_rpt go
create program cov_disch_meds_rec_rpt

prompt 
	"Output to File/Printer/MINE" = "MINE"          ;* Enter or select the printer or file name to send this report to.
	, "Discharge Start Date and Time" = "SYSDATE"
	, "Discharge End Date and Time" = "SYSDATE"
	, "FIN" = "" 

with OUTDEV, DISCH_START_DT_TM, DISCH_END_DT_TM, FIN

call echo(build("loading script:",curprog	))
set nologvar = 0	;do not create log = 1		, create log = 0
set noaudvar = 0	;do not create audit = 1	, create audit = 0
%i ccluserdir:cov_custom_ccl_common.inc

call writeLog(build2("************************************************************"))
call writeLog(build2("* START Custom Section  ************************************"))

if (not(validate(reply,0)))
record  reply
(
	1 text = vc
	1 status_data
	 2 status = c1
	 2 subeventstatus[1]
	  3 operationname = c15
	  3 operationstatus = c1
	  3 targetobjectname = c15
	  3 targetobjectvalue = c100
)
endif

set reply->status_data.status = "F"

call set_maxvarlen(268435456)
call set_codevalues(null)
call check_ops(null)

record t_rec
(
	1 prompts
	 2 outdev = vc
	 2 disch_start_dt_tm = vc
	 2 disch_end_dt_tm = vc
	 2 fin = vc
	1 start_dt_tm = dq8
	1 end_dt_tm = dq8
	1 output_var = vc
	1 output_filename = vc
	1 log_filename = vc
	1 encntr_where = vc
	1 encntr_prompt_id = f8
	1 encntr_cnt = i4
	1 encntr_qual[*]
	 2 encntr_id = f8
	 2 person_id = f8
	 2 fin = vc
	 2 cmrn = vc
	 2 name_full_formatted = vc
	 2 facility = vc
	 2 unit = vc
	 2 processed_ind = i2
	 2 order_recon_qual[*]   
      3 order_recon_id 			= f8
  	  3 recon_type_flag 		= i2
      3 performed_dt_tm		 	= dq8
  	  3 performed_tz 			= i4   
  	  3 performed_prsnl_id 		= f8
  	  3 performed_person_name 	= vc
  	  3 recon_status_cd 		= f8
  	  3 next_loc_cd 			= f8
 	  3 cross_encntr_ind 		= i2
  	  3 updt_applctx 			= f8
      3 order_recon_detail_list[*]
	   4 order_nbr=f8   
	   4 order_mnemonic=vc
	   4 clinical_display_line=vc
	   4 continue_order_ind= i2 
	   4 recon_order_action_mean=vc
	   4 simplified_display_line=vc
	   4 order_provider_id=f8 
	   4 order_action_date_time=dq8 
	   4 order_action_tz= i4 
	   4 formatted_prsnl_name=vc
	   4 recon_note_txt=vc
	   4 cross_encounter_ind= i2 
	   4 orig_ord_as = vc
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

declare i = i4 with noconstant(0), protect
declare j = i4 with noconstant(0), protect
declare k = i4 with noconstant(0), protect
declare pos = i4 with noconstant(0), protect
declare cnt = i4 with noconstant(0), protect

set t_rec->prompts.outdev = $OUTDEV
set t_rec->prompts.disch_start_dt_tm  = $DISCH_START_DT_TM
set t_rec->prompts.disch_end_dt_tm = $DISCH_END_DT_TM
set t_rec->prompts.fin = $FIN

set t_rec->start_dt_tm = cnvtdatetime(t_rec->prompts.disch_start_dt_tm)
set t_rec->end_dt_tm = cnvtdatetime(t_rec->prompts.disch_end_dt_tm)

if (program_log->run_from_ops = 0)
	if (t_rec->prompts.outdev = "OPS")
		set program_log->run_from_ops = 1
		set program_log->display_on_exit = 0
	endif
endif

set t_rec->output_filename = concat(	 trim(cnvtlower(curdomain))
										,"_"
										,trim(cnvtlower(curprog))
										,"_"
										,trim(format(sysdate,"yyyymmdd_hhmmss;;d")),".csv")
set t_rec->log_filename = concat(	 trim(cnvtlower(curdomain))
										,"_"
										,trim(cnvtlower(curprog))
										,"_"
										,trim(format(sysdate,"yyyymmdd_hhmmss;;d")),".dat")

if (program_log->run_from_ops = 0)
	set t_rec->output_var = t_rec->prompts.outdev
else	;run from ops
	set t_rec->output_var = concat("cclscratch:",trim(t_rec->output_filename))
endif

if (t_rec->prompts.fin > " ")
	select into "nl:"
	from encntr_alias ea where ea.alias = t_rec->prompts.fin
	detail
	 	t_rec->encntr_prompt_id = ea.encntr_id
	with nocounter
	if (t_rec->encntr_prompt_id > 0.0)
		set t_rec->encntr_where = build2(" e.encntr_id = ",trim(cnvtstring(t_rec->encntr_prompt_id)))
	else
		go to exit_script
	endif
else
	set t_rec->encntr_where = " 1=1"
endif

call echo(build2("t_rec->encntr_where=",t_rec->encntr_where))
call echo(build2("t_rec->encntr_prompt_idv=",t_rec->encntr_prompt_id))

select into "nl:"
from
	encounter e
plan e
	where e.disch_dt_tm between cnvtdatetime(t_rec->start_dt_tm) and cnvtdatetime(t_rec->end_dt_tm)
	and parser(t_rec->encntr_where)
order by
	e.encntr_id
head report
	cnt = 0
detail
	cnt = (cnt + 1)
	stat = alterlist(t_rec->encntr_qual,cnt)
	t_rec->encntr_qual[cnt].encntr_id = e.encntr_id
	t_rec->encntr_qual[cnt].person_id = e.person_id
foot report
	t_rec->encntr_cnt = cnt
with nocounter

if (t_rec->encntr_cnt <= 0)
	go to exit_script
endif

for (i=1 to t_rec->encntr_cnt)
	set stat = initrec(500700_request)
	free record 500700_reply
	set stat = alterlist(500700_request->recon_type_list,1)
	set 500700_request->recon_type_list[1].recon_type = 3
	set 500700_request->person_id = t_rec->encntr_qual[i].person_id
	set stat = alterlist(500700_request->encntr_list,1)
	set 500700_request->encntr_list[1].encntr_id = t_rec->encntr_qual[i].encntr_id
	
	set stat = tdbexecute(600005,500195,500700,"REC",500700_request,"REC",500700_reply)
	set t_rec->encntr_qual[i].processed_ind = 1
	if (validate(500700_reply))
		set cnt = 0
		set t_rec->encntr_qual[i].processed_ind = 2
		for (j=1 to size(500700_reply->encntr_list,5))
			if (500700_reply->encntr_list[j].order_recon_id > 0.0)
				set cnt = (cnt + 1)
				set stat = alterlist(t_rec->encntr_qual[i].order_recon_qual,cnt)
				set t_rec->encntr_qual[i].order_recon_qual[cnt].order_recon_id = 500700_reply->encntr_list[j].order_recon_id
				set t_rec->encntr_qual[i].order_recon_qual[cnt].cross_encntr_ind = 500700_reply->encntr_list[j].cross_encntr_ind
				set t_rec->encntr_qual[i].order_recon_qual[cnt].next_loc_cd = 500700_reply->encntr_list[j].next_loc_cd
				set t_rec->encntr_qual[i].order_recon_qual[cnt].performed_dt_tm = 500700_reply->encntr_list[j].performed_dt_tm
				set t_rec->encntr_qual[i].order_recon_qual[cnt].performed_person_name = 500700_reply->encntr_list[j].performed_person_name
				set t_rec->encntr_qual[i].order_recon_qual[cnt].performed_prsnl_id = 500700_reply->encntr_list[j].performed_prsnl_id
				set t_rec->encntr_qual[i].order_recon_qual[cnt].performed_tz = 500700_reply->encntr_list[j].performed_tz
				set t_rec->encntr_qual[i].order_recon_qual[cnt].recon_status_cd = 500700_reply->encntr_list[j].recon_status_cd
				set t_rec->encntr_qual[i].order_recon_qual[cnt].recon_type_flag = 500700_reply->encntr_list[j].recon_type_flag
				set t_rec->encntr_qual[i].order_recon_qual[cnt].updt_applctx = 500700_reply->encntr_list[j].updt_applctx
			endif
		endfor
	endif
endfor


for (i=1 to t_rec->encntr_cnt)
	for (j=1 to size(t_rec->encntr_qual[i].order_recon_qual,5))
	 if (t_rec->encntr_qual[i].order_recon_qual[j].order_recon_id > 0.0)
		set stat = initrec(500703_request)
		free record 500703_reply
		set stat = alterlist(500703_request->order_recon_qual,j)
		set 500703_request->order_recon_qual[j].order_recon_id = t_rec->encntr_qual[i].order_recon_qual[j].order_recon_id
		set stat = tdbexecute(600005,500195,500703,"REC",500703_request,"REC",500703_reply)
		;call echorecord(500703_reply)
		for (k=1 to size(500703_reply->order_recon_qual,5))
		 if (500703_reply->order_recon_qual[k].order_recon_id = t_rec->encntr_qual[i].order_recon_qual[j].order_recon_id )
		  for (pos=1 to size(500703_reply->order_recon_qual[k].order_recon_detail_list,5))
			
			set stat = alterlist(t_rec->encntr_qual[i].order_recon_qual[j].order_recon_detail_list,pos)
			
			set t_rec->encntr_qual[i].order_recon_qual[j].order_recon_detail_list[pos].clinical_display_line =
				500703_reply->order_recon_qual[k].order_recon_detail_list[pos].clinical_display_line
			set t_rec->encntr_qual[i].order_recon_qual[j].order_recon_detail_list[pos].continue_order_ind =
				500703_reply->order_recon_qual[k].order_recon_detail_list[pos].continue_order_ind
			set t_rec->encntr_qual[i].order_recon_qual[j].order_recon_detail_list[pos].cross_encounter_ind =
				500703_reply->order_recon_qual[k].order_recon_detail_list[pos].cross_encounter_ind
			set t_rec->encntr_qual[i].order_recon_qual[j].order_recon_detail_list[pos].formatted_prsnl_name =
				500703_reply->order_recon_qual[k].order_recon_detail_list[pos].formatted_prsnl_name
			set t_rec->encntr_qual[i].order_recon_qual[j].order_recon_detail_list[pos].order_action_date_time =
				500703_reply->order_recon_qual[k].order_recon_detail_list[pos].order_action_date_time
			set t_rec->encntr_qual[i].order_recon_qual[j].order_recon_detail_list[pos].order_action_tz =
				500703_reply->order_recon_qual[k].order_recon_detail_list[pos].order_action_tz
			set t_rec->encntr_qual[i].order_recon_qual[j].order_recon_detail_list[pos].order_mnemonic =
				500703_reply->order_recon_qual[k].order_recon_detail_list[pos].order_mnemonic
			set t_rec->encntr_qual[i].order_recon_qual[j].order_recon_detail_list[pos].order_nbr =
				500703_reply->order_recon_qual[k].order_recon_detail_list[pos].order_nbr
			set t_rec->encntr_qual[i].order_recon_qual[j].order_recon_detail_list[pos].order_provider_id =
				500703_reply->order_recon_qual[k].order_recon_detail_list[pos].order_provider_id
			set t_rec->encntr_qual[i].order_recon_qual[j].order_recon_detail_list[pos].recon_note_txt =
				500703_reply->order_recon_qual[k].order_recon_detail_list[pos].recon_note_txt
			set t_rec->encntr_qual[i].order_recon_qual[j].order_recon_detail_list[pos].recon_order_action_mean = 
				500703_reply->order_recon_qual[k].order_recon_detail_list[pos].recon_order_action_mean
			set t_rec->encntr_qual[i].order_recon_qual[j].order_recon_detail_list[pos].simplified_display_line = 
				500703_reply->order_recon_qual[k].order_recon_detail_list[pos].simplified_display_line
		   endfor
		  endif
		endfor
	 endif
	endfor
endfor


select into "nl:"
from
	 (dummyt d1 with seq = size(t_rec->encntr_qual,5))
	,encntr_alias ea
	,person p
	,encounter e
plan d1
join e
	where e.encntr_id = t_rec->encntr_qual[d1.seq].encntr_id
join p
	where p.person_id = e.person_id
join ea
	where ea.encntr_id = e.encntr_id
	and   ea.active_ind = 1
	and   ea.encntr_alias_type_cd = value(uar_get_code_by("MEANING",319,"FIN NBR"))
	and   cnvtdatetime(curdate,curtime3) between ea.beg_effective_dt_tm and ea.end_effective_dt_tm
head report
	stat = 0
detail
	t_rec->encntr_qual[d1.seq].name_full_formatted	= p.name_full_formatted
	t_rec->encntr_qual[d1.seq].facility				= uar_get_code_display(e.loc_facility_cd)	
	t_rec->encntr_qual[d1.seq].unit					= uar_get_code_display(e.loc_nurse_unit_cd)
	t_rec->encntr_qual[d1.seq].fin					= cnvtalias(ea.alias,ea.alias_pool_cd)
foot report
	stat = 0
with nocounter

select into "nl:"
from
	 (dummyt d1 with seq = size(t_rec->encntr_qual,5))
	,(dummyt d2)
	,(dummyt d3)
	,orders o
plan d1
	where maxrec(d2,size(t_rec->encntr_qual[d1.seq].order_recon_qual,5))
join d2
	where maxrec(d3,size(t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].order_recon_detail_list,5))
join d3 
join o
	where o.order_id = t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].order_recon_detail_list[d3.seq].order_nbr
head report
	stat = 0
detail
	if 		(o.orig_ord_as_flag = 0) 	
		t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].order_recon_detail_list[d3.seq].orig_ord_as = "Normal Order"
	elseif	(o.orig_ord_as_flag = 1)	
		t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].order_recon_detail_list[d3.seq].orig_ord_as = "Prescription/Discharge Order"
	elseif	(o.orig_ord_as_flag = 2)	
		t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].order_recon_detail_list[d3.seq].orig_ord_as = "Recorded / Home Meds"
	elseif	(o.orig_ord_as_flag = 3)	
		t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].order_recon_detail_list[d3.seq].orig_ord_as = "Patient Owns Meds"
	elseif	(o.orig_ord_as_flag = 4)	
		t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].order_recon_detail_list[d3.seq].orig_ord_as = "Pharmacy Charge Only"
	elseif	(o.orig_ord_as_flag = 5)	
		t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].order_recon_detail_list[d3.seq].orig_ord_as = "Satellite (Super Bill) Meds"
	endif
foot report
	stat = 0
with nocounter

select into "nl:"
from
	(dummyt d1 with seq = size(t_rec->encntr_qual,5))
	,person_alias pa
plan d1	
join pa
	where pa.person_id = t_rec->encntr_qual[d1.seq].person_id
	and   pa.person_alias_type_cd = value(uar_get_code_by("MEANING",4,"CMRN"))
	and   cnvtdatetime(curdate,curtime3) between pa.beg_effective_dt_tm and pa.end_effective_dt_tm
	and   pa.active_ind = 1
detail
	t_rec->encntr_qual[d1.seq].cmrn = cnvtalias(pa.alias,pa.alias_pool_cd)
with nocounter

select 
		if (program_log->run_from_ops = 1)
			with nocounter, pcformat(^"^, ^,^, 1,0),format=stream,formfeed=none,format
		else
			with nocounter,separator = " ", format
		endif
	into value(t_rec->output_var)
	 facility 					= substring(1,50,t_rec->encntr_qual[d1.seq].facility)
	,nurse_unit 				= substring(1,50,t_rec->encntr_qual[d1.seq].unit)
	,fin						= substring(1,20,t_rec->encntr_qual[d1.seq].fin)
	,name_full_formatted		= substring(1,100,t_rec->encntr_qual[d1.seq].name_full_formatted)
	,order_recon_id				= t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].order_recon_id			
	,recon_type_flag            = t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].recon_type_flag      
	,performed_dt_tm            = format(t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].performed_dt_tm,";;q")
	,performed_prsnl_id         = t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].performed_prsnl_id   
	,performed_person_name      = substring(1,100,t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].performed_person_name)
	,recon_status_cd            = uar_get_code_display(t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].recon_status_cd      )
	,cross_encntr_ind           = t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].cross_encntr_ind     
	,order_nbr					= t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].order_recon_detail_list[d3.seq].order_nbr		
	,orig_ord_as = 	substring(1,40,t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].order_recon_detail_list[d3.seq].orig_ord_as)		
	,order_mnemonic             
		= substring(1,100,t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].order_recon_detail_list[d3.seq].order_mnemonic)
	,clinical_display_line      
		= substring(1,200,t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].order_recon_detail_list[d3.seq].clinical_display_line) 
	,simplified_display_line    
		= substring(1,100,t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].order_recon_detail_list[d3.seq].simplified_display_line) 
	,continue_order_ind         
		= t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].order_recon_detail_list[d3.seq].continue_order_ind     
	,recon_order_action_mean    
		= substring(1,50,t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].order_recon_detail_list[d3.seq].recon_order_action_mean)
	,order_provider_id          
		= t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].order_recon_detail_list[d3.seq].order_provider_id      
	,order_action_date_time     
		= format(t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].order_recon_detail_list[d3.seq].order_action_date_time ,";;q")      
	,formatted_prsnl_name       
		= substring(1,100,t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].order_recon_detail_list[d3.seq].formatted_prsnl_name)   
	,recon_note_txt             
		= substring(1,100,t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].order_recon_detail_list[d3.seq].recon_note_txt)         
from
	 (dummyt d1 with seq = size(t_rec->encntr_qual,5))
	,(dummyt d2)
	,(dummyt d3)
plan d1
	where maxrec(d2,size(t_rec->encntr_qual[d1.seq].order_recon_qual,5))
join d2
	where maxrec(d3,size(t_rec->encntr_qual[d1.seq].order_recon_qual[d2.seq].order_recon_detail_list,5))
join d3 	
with nocounter, format, separator=" ", check

if (program_log->run_from_ops = 1)
	call writeLog(build2("---->addAttachment(",replace(t_rec->output_filename,"cclscratch:",""),")"))
	execute cov_astream_file_transfer "cclscratch",replace(t_rec->output_filename,"cclscratch:",""),"","MV"
endif
	
set reply->status_data.status = "S"

#exit_script
if (program_log->run_from_ops = 1)
	call echojson(t_rec, concat("cclscratch:",t_rec->log_filename) , 1) 
	execute cov_astream_file_transfer "cclscratch",replace(t_rec->log_filename,"cclscratch:",""),"","MV"
endif
call exitScript(null)
;call echorecord(t_rec)

end go
