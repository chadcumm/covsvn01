; eks_tell_ekscommon
set rev_inc = "708" ;### 
set ininc = "eks_tell_ekscommon" ;###
;### LAST UPDATE: 980727 - cerpmw - no recent changes

 set ttemp  = TRIM(eks_common->cur_module_name)
 set eksmodule = trim(ttemp)
 free set ttemp
 set ttemp   = TRIM(eks_common->event_name)
 set eksevent   = ttemp

 set eksrequest = eks_common->request_number

 free set ttemp 

 declare tcurindex = i4
 declare tinx = i4

 set tcurindex = 1
 set tinx = 1

 set evoke_inx = 1
 set data_inx = 2
 set logic_inx = 3
 set action_inx = 4

; will need to change when eksdata changes maybe to remove this level
; how to tell if it is the evoke area

 if (not (validate(eksdata->tqual,"Y")="Y" and validate(eksdata->tqual,"Z")="Z"))

    free set templatetype
    if (conclude > 0)
       set templatetype = "ACTION"
       set basecurindex = logiccnt+evokecnt
       set tcurindex    = 4
    else
       set templatetype = "LOGIC"
       set basecurindex = evokecnt
       set tcurindex    = 3
    endif

    set cbinx = curindex
    set tinx = logic_inx

 else
    set templatetype = "EVOKE"
    set curindex = 0
    set tcurindex = 0
    set tinx = 0
 endif

call echo(concat("****  ",format(curdate, "dd-mmm-yyyy;;d")," ",
                 format(curtime3, "hh:mm:ss.cc;3;m"), 
	         "     Module:  ",trim(eksmodule),"  ****"),1,0)

;call echorecord(event)
 if (validate(tname,"Y")="Y" and validate(tname,"Z")="Z")
    if (templatetype != "EVOKE")
       call echo(concat("****  EKM Beginning of ",
		     trim(templatetype)," Template(",
		     build(curindex),")           Event:  ",
		     trim(eksevent),
                     "         Request number:  ",
		     cnvtstring(eksrequest)),1,10)
    else
       call echo(concat("****  EKM Beginning an Evoke Template",
		     "           Event:  ",
		     trim(eksevent),
                     "         Request number:  ",
		     cnvtstring(eksrequest)),1,10)
    endif
 else
    if (templatetype != "EVOKE")
       call echo(concat("****  EKM Beginning of ",
		     trim(templatetype)," Template(",
		     build(curindex),"):  ",trim(tname),
		     "       Event:  ",
		     trim(eksevent),
                     "         Request number:  ",
    		     cnvtstring(eksrequest)),1,10)
    else
       call echo(concat("****  EKM Beginning Evoke Template:  ",
		     trim(tname),
	    	     "       Event:  ",
		     trim(eksevent),
                     "         Request number:  ",
		     cnvtstring(eksrequest)),1,10)
    endif
 endif

; call echo("End of eks_tell_ekscommon",1,0)


