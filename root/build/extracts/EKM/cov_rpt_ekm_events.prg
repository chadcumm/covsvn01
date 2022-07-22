
 
 
drop program cov_rpt_ekm_events:dba go
create program cov_rpt_ekm_events:dba
 
 
  prompt
	"Output to File/Printer/MINE (MINE): " = "MINE"                                     ;* Enter or select the printer or file nam
	, "Display by (E)vent, (M)odule, or (B)oth (E):" = "E"                              ;* Select the display type
	, "Enter Module name:" = "*"                                                        ;* Enter a module name to query by
	, "Validation Type (Production), Testing, Example, Research, All:" = "PRODUCTION"   ;* Select a validation type to query by
 
with outputtype, displaytype, modulename, valtype
 
  set char_temp = char(3)
  set char_event = char(4)
  set char_actgroup = char(5)
  set slot_evoke = 7
  set slot_logic = 8
  set slot_logic_free = 81
  set slot_action = 9
  set slot_action_free = 91
 
  declare servernumber= vc
  declare loop1cnt = i4
  declare loop2cnt = i4
  set loop1cnt= 1
  set loop2cnt= 1
 
  record rec(
    1 qual[*]
      2 module_name = c30
      2 module_validation = c12
      2 module_author = vc
      2 module_dur_begin_dt_tm = dq8
      2 module_dur_end_dt_tm = dq8
      2 qual2[*]
        3 event_name = vc
        3 server_class = vc
      2 rqual[*]
        3 request_number = f8
    1 qual3[*]
        2 event_name = vc
    1 qual4[*]
        2 unused_request_number = f8
  )
  set max_events = 0
 
  set rmode = cnvtupper( substring( 1, 1, $2 ))
  if (rmode not in ("E","M","B"))
     call echo(  "Enter  (E)vent, (M)odule, or (B)oth for display type" )
     go to exit_report
  endif
 
  if ($3 not in(""," "))
   	set mname = cnvtupper($3)
  else
   	set mname = "*"
  endif
 
  if(findstring("ALL",cnvtupper($4)))
	set vType = "*"
  else
	set vType= cnvtupper($4)
  endif
 
  ;==============================================================================================
  ;build rec structure
  ;==============================================================================================
  select INTO "NL:"
  		m.module_name,
  		s.data_type,
  		s.data_seq,
  		s.ekm_info,
  		tlen = textlen(s.ekm_info),
  		m.maint_validation,
  		m.maint_author,
  		m.maint_dur_begin_dt_tm,
  		m.maint_dur_end_dt_tm
  from eks_module m,
  	   eks_modulestorage s,
  	   dprotect d
  plan d
  	where d.object = "E" and
  		  d.group = 0 and
  		  (d.object_name = patstring(mname) or mname = "\*")
  join m
    where
    	  m.MAINT_VALIDATION = PatString(vType) and							;002
    	  m.active_flag = "A" and											;002
    	  m.maint_dur_begin_dt_tm <= CNVTDATETIME(CURDATE,CURTIME3) and		;002
    	  CNVTDATETIME(CURDATE,CURTIME3) <= m.maint_dur_end_dt_tm and
    	  d.object_name = m.module_name
  join s
    where m.module_name = s.module_name and
          m.version = s.version and
          s.data_type = slot_evoke
 
  order m.module_name, s.data_type, s.data_seq
 
  head report
  	 name = fillstring(31," ")
     cnt = 0
     cnt3 = 0
 
  detail
  	 cnt = cnt+1
     stat = alterlist(rec->qual,cnt)
     rec->qual[cnt].module_name = m.module_name
 	 rec->qual[cnt].module_validation = m.maint_validation
 	 rec->qual[cnt].module_author = m.maint_author
 	 rec->qual[cnt].module_dur_begin_dt_tm = m.maint_dur_begin_dt_tm
 	 rec->qual[cnt].module_dur_end_dt_tm = m.maint_dur_end_dt_tm
 
     ; col 0, "Module: ", m.module_name
     ; row+1
     cnt2 = 0
     pos1 = 1
     pos2 = 1
     while (pos2)
       pos2 = findstring(char_event, s.ekm_info, pos1)
 
       if (pos2)
 
         event_name = substring(pos1, pos2-pos1, s.ekm_info)
 
         /*
         pos3 = pos2-pos1
         event_subname = substring( 1, 30, event_name )
         col 2, "Event: ", event_subname, ", pos1= ", pos1, ", length= ", pos3
         row+1 */
 
         cnt2 = cnt2+1
 
         stat = alterlist(rec->qual[cnt].qual2, cnt2)
         rec->qual[cnt].qual2[cnt2].event_name = event_name
         pos2 = findstring(char_event, s.ekm_info, pos2+1)
         pos1 = pos2+1
         fnd = 0
         num = 1
 
         while(num <= cnt3 and fnd = 0)
         	if (rec->qual3[num].event_name = event_name)
               fnd = 1
           	endif
           	num = num+1
         endwhile
 
         if (fnd = 0)
             cnt3 = cnt3+1
             stat = alterlist(rec->qual3,cnt3)
             rec->qual3[cnt3].event_name = event_name
         endif
       endif
     endwhile
     max_events = maxval(cnt2,max_events)
  with counter, memsort
 
;Set the server class information into the record structure
SELECT into "nl:"
	 EE.EVENT_NAME,
	 ES.server_class
FROM EKS_EVENT EE,
	 EKS_SERVER ES,
	 EKS_REQUEST ER
PLAN EE WHERE EE.EVENT_NAME > " " and EE.EVENT_NUMBER > 0
JOIN ES WHERE EE.EVENT_PRIORITY >= ES.PRIORITY_BEGIN and EE.EVENT_PRIORITY <= ES.PRIORITY_END
JOIN ER WHERE EE.EVENT_NUMBER = ER.EVENT_NUMBER AND ES.SERVER_TYPE = ER.SERVER_TYPE
ORDER EE.EVENT_NAME
DETAIL
	loop1cnt= 1
	loop2cnt= 1
	fnd= 0
 
 	loop1size = size(rec->qual, 5)
  	 while (loop1cnt <= loop1size)
  	 	loop2size = size(rec->qual[loop1cnt].qual2,5)
  	 	while (loop2cnt <= loop2size)
  	 		if(fnd = 0)
 
  	 			if (cnvtupper(trim(ee.event_name)) = cnvtupper(trim(rec->qual[loop1cnt].qual2[loop2cnt].event_name)))
  	 				if (trim(es.server_class) = "EKS_ASYNCH_01")
  	 					servernumber= "150"
  	 				elseif (trim(es.server_class) = "EKS_ASYNCH_02")
  	 					servernumber= "151"
  	 				elseif (trim(es.server_class) = "EKS_ASYNCH_03")
  	 					servernumber= "152"
  	 				elseif (trim(es.server_class) = "CPM.EKS")
  	 					servernumber= "175"
  	 				else
  	 					servernumber= " "
  	 				endif
 
  	 				rec->qual[loop1cnt].qual2[loop2cnt].server_class = concat("(Server ",
  	 					servernumber, ": ", trim(es.server_class), ")")
  	 				fnd = 1
  	 			endif
  	 		endif
 
  	 		loop2cnt= loop2cnt + 1
  	 	endwhile
 
  	 	fnd= 0
  	 	loop1cnt= loop1cnt + 1
  	 	loop2cnt= 1
  	 endwhile
 
WITH counter

#exit_report
call echojson(rec) 
end go
 
 

