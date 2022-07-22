drop program audit_2372_2 go
create program audit_2372_2
   
;check if running from OPs
;call echo(build("From OPs: ",validate(request->batch_selection)))
;if (validate(request->batch_selection) = 1)
;    call echo("Setting status to F")
;    set reply->status_data.status = "F"
;    set reply->ops_event = "Script should not run from OPs"
;    execute No_Run_From_OPs
;    go to EXIT_SCRIPT
;endif
   
;create record structure for ids to update
free record items
record items
(
   1 list[*]
     2 Id= f8
)
    
declare count = i4 with protect, noconstant(0)
declare iExit = i2 with protect, noconstant(0)
declare x = i4 with protect, noconstant(0)
declare TotalCnt = i4 with protect, noconstant(0)
    
while(iExit = 0)
    ;populate the record structure
    set count = 0
    set stat = alterlist(items->list,0)
    
    select into 'NL:'
    from person_person_reltn ppr,
    person p,
    code_value cv
    where p.updt_dt_tm > sysdate-90
    and (p.name_first_key = NULL
    or p.name_last_key = NULL)
    and ppr.related_person_id = p.person_id
    and ppr.active_ind = 1
    and ppr.END_EFFECTIVE_DT_TM > sysdate
    and ppr.person_reltn_type_cd = cv.code_value
    and cv.code_set = 351
    and cv.active_ind = 1
    and cv.cdf_meaning != 'FAMILYHIST'
    order by ppr.person_person_reltn_id
    Head ppr.person_person_reltn_id
        count = count+1
        if (mod(count,5000) = 1)
            stat = alterlist(items->list,count+4999)
        endif
        items->list[count]->Id = ppr.person_person_reltn_id
    with nocounter, maxrec = 5000,orahintcbo("index(ppr xif384person_person_reltn)")
    
    if(curqual = 0)
        set iExit = 1
    endif
    
    ;update the records
    for(x = 1 to count)
        update into person_person_reltn ppr1
        set ppr1.end_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        ppr1.updt_id = reqinfo->updt_id,
        ppr1.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        ppr1.updt_task = -2372,
        ppr1.updt_cnt = ppr1.updt_cnt + 1
        where ppr1.person_person_reltn_id = items->list[x]->Id
        and ppr1.person_person_reltn_id > 0
    
        set TotalCnt = TotalCnt + 1
        commit
    
        call echo(build('update count: completed ',x,'of ',count))
        call echo(build('Total Updated: ',TotalCnt))
    endfor
    call echo(build("Exit: ",iExit))
endwhile
 
set iExit = 0
 
while(iExit = 0)
    ;populate the record structure
    set count = 0
    set stat = alterlist(items->list,0)
    
    select into 'NL:'
    from encntr_person_reltn ppr,
    person p
    where p.updt_dt_tm > sysdate-90
    and (p.name_first_key IS NULL
    or p.name_last_key IS NULL)
    and ppr.related_person_id = p.person_id
    and ppr.active_ind = 1
    and ppr.END_EFFECTIVE_DT_TM > sysdate
    order by ppr.encntr_person_reltn_id
    Head ppr.encntr_person_reltn_id
        count = count+1
        if (mod(count,5000) = 1)
            stat = alterlist(items->list,count+4999)
        endif
        items->list[count]->Id = ppr.encntr_person_reltn_id
    with nocounter, maxrec = 5000, orahintcbo("index(ppr xif383encntr_person_reltn)")
    
    if(curqual = 0)
        set iExit = 1
    endif
    
    ;update the records
    for(x = 1 to count)
        update into encntr_person_reltn ppr1
        set ppr1.end_effective_dt_tm = cnvtdatetime(curdate,curtime3),
        ppr1.updt_id = reqinfo->updt_id,
        ppr1.updt_dt_tm = cnvtdatetime(curdate,curtime3),
        ppr1.updt_task = -2372,
        ppr1.updt_cnt = ppr1.updt_cnt + 1
        where ppr1.encntr_person_reltn_id = items->list[x]->Id
        and ppr1.encntr_person_reltn_id > 0
    
        set TotalCnt = TotalCnt + 1
        commit
    
        call echo(build('update count: completed ',x,'of ',count))
        call echo(build('Total Updated: ',TotalCnt))
    endfor
    call echo(build("Exit: ",iExit))
endwhile


if (validate(request->batch_selection) = 1)
	set reply->status_data.status = "S"
endif
 
 
#EXIT_SCRIPT
end go
