/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************

	Author:				Chad Cummings
	Date Written:		06/01/2020
	Solution:			
	Source file name:	cov_pcs_add_covid_aoe.prg
	Object name:		cov_pcs_add_covid_aoe
	Request #:

	Program purpose:

	Executing from:		CCL

 	Special Notes:		Called by ccl program(s).

******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************

Mod 	Mod Date	  Developer				      Comment
--- 	----------	--------------------	--------------------------------------
001 	06/01/2020	  Chad Cummings
******************************************************************************/
DROP PROGRAM cov_cust_col_dev_two :dba GO
CREATE PROGRAM cov_cust_col_dev_two	 :dba

/***********************************************************************************************************************************
* Record Structures                                                                                                                *
***********************************************************************************************************************************/
/* The reply record
/* The request record is passed in as a JSON object, and converted to a persistscript record. It contains a patient list and the 
link types for the popover view */
/*
record reply (
  1 person[*]
    2 person_id = f8
    2 encntr_id = f8
    2 ppr_cd = f8
    2 count = i4
    2 icon = vc
    2 contents[*]
      3 primary = vc
      3 secondary = vc
      3 link_type = vc
      3 link_params = vc
%i cclsource:status_block.inc
) with protect
*/

free record t_rec
record t_rec (
	1 cnt = i2
	1 prsnl_id = f8
	1 debug_ind = i2
	1 icon_1 = vc 
	1 lookback_hours = i2
	1 person[*]
	    2 person_id = f8
	    2 encntr_id = f8
	    2 ppr_cd = f8
	    2 count = i4
	    2 icon = vc
	    2 contents_cnt = i2
	    2 last_chart_access_dt_tm = dq8
	    2 contents[*]
	      3 completed_dt_tm = dq8
	      3 status_dt_tm = dq8
	      3 event_id = f8
	      3 order_id = f8
	      3 primary = vc
	      3 secondary = vc
	      3 link_type = vc
	      3 link_params = vc
	      3 valid_ind = i2
	      3 dept_status_cd = f8
	
)
 
/***********************************************************************************************************************************
* Subroutines                                                                                                                      *
***********************************************************************************************************************************/
declare PUBLIC::Main(null) = null with private
declare PUBLIC::TemporaryResults(null) = null with protect 
declare PUBLIC::DetermineDocLinks(null) = null with protect 
declare PUBLIC::DetermineChartAccess(null) = null with protect 
declare PUBLIC::FinalizeResults(null) = null with protect 

;call echojson(request,"ccjson.json",1)

/***********************************************************************************************************************************
* Main PROGRAM *********************************************************************************************************************
***********************************************************************************************************************************/
set t_rec->debug_ind = 0
call Main(null)
 
/***********************************************************************************************************************************
* Main                                                                                                                             *
***********************************************************************************************************************************/
/**
Main subroutine.
@param null
@returns null
*/
subroutine PUBLIC::Main(null)
  call TemporaryResults(null)
  call DetermineDocLinks(null)
  call DetermineChartAccess(null)
  call FinalizeResults(null)
  set reply->status_data.status = "S"
end ; Main

/***********************************************************************************************************************************
* DetermineDocLinks                                                                                                      *
***********************************************************************************************************************************/
/**
Determine the number of Auth (Verified) clinical event documents for each encounter.
@param null
@returns null
*/

subroutine PUBLIC::TemporaryResults(null)
	set t_rec->prsnl_id = reqinfo->updt_id
	set t_rec->icon_1 = "images/IPPV.png"
	set t_rec->lookback_hours = 48
	for (i=1 to size(reply->person, 5))
		set t_rec->cnt = i
		set stat = alterlist(t_rec->person,t_rec->cnt)
		set t_rec->person[t_rec->cnt].count			= reply->person[i].count
		set t_rec->person[t_rec->cnt].encntr_id		= reply->person[i].encntr_id
		set t_rec->person[t_rec->cnt].icon			= reply->person[i].icon
		set t_rec->person[t_rec->cnt].person_id		= reply->person[i].person_id
		set t_rec->person[t_rec->cnt].ppr_cd		= reply->person[i].ppr_cd
	endfor
end	;TemporaryResults

subroutine PUBLIC::FinalizeResults(null)
	declare cnt = i4 with protect, noconstant(0)
	for (i=1 to t_rec->cnt)
		for (k=1 to t_rec->person[i].contents_cnt)
			if ((t_rec->person[i].contents[k].valid_ind = 0) and 
				(t_rec->person[i].contents[k].dept_status_cd = uar_get_code_by("MEANING",14281,"COMPLETED")))
				
				if (t_rec->person[i].contents[k].completed_dt_tm < cnvtlookbehind(build(t_rec->lookback_hours ,",H")))
					set t_rec->person[i].contents[k].valid_ind = 1
				endif	
				
				if (t_rec->person[i].last_chart_access_dt_tm > t_rec->person[i].contents[k].completed_dt_tm)
					set t_rec->person[i].contents[k].valid_ind = 1
				endif
			endif
		endfor
	endfor
	call echorecord(t_rec)
	for (i=1 to t_rec->cnt)
		for (j=1 to size(reply->person,5))
			if (t_rec->person[i].person_id = reply->person[j].person_id)
				set cnt = 0
				for (k=1 to t_rec->person[i].contents_cnt)
					if (t_rec->person[i].contents[k].valid_ind = 0)
						set cnt = (cnt + 1)
						set stat = alterlist(reply->person[j].contents,cnt)
						set reply->person[j].contents[cnt].link_params	= build(t_rec->person[i].contents[k].event_id)
						set reply->person[j].contents[cnt].link_type	= t_rec->person[i].contents[k].link_type
						set reply->person[j].contents[cnt].primary		= t_rec->person[i].contents[k].primary
						set reply->person[j].contents[cnt].secondary	= t_rec->person[i].contents[k].secondary
						if (t_rec->person[i].contents[k].event_id = 0.0)
							set reply->person[j].contents[cnt].link_type = ""
						endif		
						if (t_rec->debug_ind)
							set reply->person[j].contents[cnt].secondary		= concat( reply->person[j].contents[cnt].secondary
																					 ," debug_last_chart_access:"
																					 ,format(t_rec->person[i].last_chart_access_dt_tm,";;q")
																					 )
						endif

					endif
				endfor
			endif
		endfor
	endfor
	;call echorecord(reply)
end	;TemporaryResults

subroutine PUBLIC::DetermineChartAccess(null)
for (i=1 to t_rec->cnt)
	select into "nl:"
	from
		 person_prsnl_activity ppa
		,prsnl p
	plan p
		where p.person_id = t_rec->prsnl_id
	join ppa
		where ppa.prsnl_id = p.person_id
		and   ppa.person_id = t_rec->person[i].person_id
	order by
		ppa.person_id
		,ppa.ppa_last_dt_tm desc
	head report
		null
	head ppa.person_id
		t_rec->person[i].last_chart_access_dt_tm = ppa.ppa_last_dt_tm
	foot report
		null
	with nocounter
 
endfor
end ;DetermineChartAccess

subroutine PUBLIC::DetermineDocLinks(null)
  declare person_cnt = i4 with protect, constant(t_rec->cnt) 
  declare exp_idx = i4 with protect, noconstant(0)
  declare loc_idx = i4 with protect, noconstant(0)
  declare cnt = i4 with protect, noconstant(0)
  declare pt_idx = i4 with protect, noconstant(0)
 
	select into "nl:"
	from
		 orders o
		,clinical_event ce
		,(dummyt d1)
	plan o
		where expand(exp_idx, 1, person_cnt, o.encntr_id, t_rec->person[exp_idx].encntr_id)
		and   o.catalog_type_cd in(value(uar_get_code_by("MEANING",6000,"RADIOLOGY")))
		and   o.dept_status_cd in(
									 value(uar_get_code_by("MEANING",14281,"COMPLETED"))
									,value(uar_get_code_by("MEANING",14281,"RADCOMPLETED")))
	join d1
	join ce
		where ce.order_id = o.order_id
		and   ce.valid_from_dt_tm <= cnvtdatetime(curdate,curtime3)
		and   ce.event_class_cd in(value(uar_get_code_by("MEANING", 53, "DOC")))
		and	  ce.result_status_cd in(
										  value(uar_get_code_by("MEANING",8,"AUTH"))
										 ,value(uar_get_code_by("MEANING",8,"MODIFIED"))
										 ,value(uar_get_code_by("MEANING",8,"ALTERED"))
									)
		and   ce.valid_until_dt_tm >= cnvtdatetime(curdate, curtime3)
		and   ce.event_tag        != "Date\Time Correction"
	order by ce.encntr_id
    head report
      person_idx = 0
    head ce.encntr_id
      cnt = 0
    detail
    person_idx = locateval(loc_idx, 1, person_cnt, o.encntr_id, t_rec->person[loc_idx].encntr_id)
      ; Since the same visit could have multiple occurrences in the Worklist, loop through the visit list to look for duplicates.
      while (person_idx > 0)
        cnt = size(t_rec->person[person_idx].contents,5)
          cnt = cnt + 1
          call alterlist(t_rec->person[person_idx].contents, cnt)
          t_rec->person[person_idx].contents[cnt].primary = concat(
          															 trim(o.order_mnemonic)
          															," ("
          															,trim(uar_get_code_display(o.dept_status_cd))
          															,")"
          															)
          															
          
          t_rec->person[person_idx].contents[cnt].link_type = 'RV'
          t_rec->person[person_idx].contents[cnt].link_params = build(ce.event_id)
          t_rec->person[person_idx].contents[cnt].order_id = o.order_id
          t_rec->person[person_idx].contents[cnt].dept_status_cd = o.dept_status_cd
          t_rec->person[person_idx].contents[cnt].event_id = ce.event_id
          if (o.dept_status_cd in(value(uar_get_code_by("MEANING",14281,"COMPLETED"))))
          	t_rec->person[person_idx].contents[cnt].completed_dt_tm = o.status_dt_tm
          endif
          t_rec->person[person_idx].contents[cnt].status_dt_tm = o.status_dt_tm
        t_rec->person[person_idx].count = cnt    
        t_rec->person[person_idx].contents_cnt = cnt
        person_idx = locateval(loc_idx, person_idx + 1, person_cnt, ce.encntr_id, t_rec->person[loc_idx].encntr_id)
      endwhile
	with format(date,";;q"),uar_code(d),outerjoin=d1

if (t_rec->cnt = 0)
	go to exit_script
endif

for (i=1 to t_rec->cnt)
 for (j=1 to t_rec->person[i].contents_cnt)
	select into "nl:"
		sort = 	if (oa.dept_status_cd = uar_get_code_by("MEANING",14281,"RADORDERED"))
					1
				elseif (oa.dept_status_cd = uar_get_code_by("MEANING",14281,"RADCOMPLETED"))
					2
				elseif (oa.dept_status_cd = uar_get_code_by("MEANING",14281,"COMPLETED"))
					3
				else
					99
				endif
	from
		 orders o
		,order_action oa
	plan o
		where o.order_id = t_rec->person[i].contents[j].order_id
	join oa
		where oa.order_id = o.order_id
		and   oa.dept_status_cd in(
										; value(uar_get_code_by("MEANING",14281,"RADORDERED"))
										 value(uar_get_code_by("MEANING",14281,"COMPLETED"))
										,value(uar_get_code_by("MEANING",14281,"RADCOMPLETED"))
									)
	order by
		 o.order_id
		,sort
		,oa.dept_status_cd
		,oa.action_sequence desc
	head report
		cnt = 0
	head o.order_id	
		cnt = 0
	head oa.dept_status_cd
		cnt = (cnt + 1)
		if (cnt > 1)
			t_rec->person[i].contents[j].secondary = concat(t_rec->person[i].contents[j].secondary,char(13),char(10))
		endif
		t_rec->person[i].contents[j].secondary = concat(					 t_rec->person[i].contents[j].secondary
																			,format(oa.action_dt_tm,"dd-mmm-yy hh:mm;;q")
																			," ["
																			,trim(cnvtlower(uar_get_code_display(oa.dept_status_cd)))
																			,"]"
																		)
	with nocounter
  endfor
 endfor
 
 
end ; DetermineDocLinks

/***********************************************************************************************************************************
* EXIT PROGRAM *********************************************************************************************************************
***********************************************************************************************************************************/
#EXIT_SCRIPT
 
if (reqdata->loglevel >= 4 or VALIDATE(debug_ind, 0) > 0)
  call echorecord(reply)
endif

end
go
