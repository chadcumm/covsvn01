/***********************Change Log*************************
VERSION  DATE       ENGINEER            COMMENT
-------	 -------    -----------         ------------------------
0.1		3/28/2018	Ryan Gotsche		Initial Development
1.0		4/3/2018	Jeremy Moore		Release
1.1		6/5/2018	Chad Cummings		Added CareSelect Logic
1.2		6/12/2018	Chad Cummings		Added RFE Check
**************************************************************/
 
/***********************PROGRAM NOTES*************************
Pre-Processing script used on Radiology orders to copy the diagnosis
	assigned to the orderable to the "Reason for Exam" order
	entry field.
 
Tables Read: Not applicable
 
Tables Updated: Not applicable
**************************************************************/
drop program idn_preprocess_oef_rad_rfe:dba go
create program idn_preprocess_oef_rad_rfe:dba
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare RFE_FIELD_ID = f8 with Protect, Constant(uar_get_code_by("DISPLAYKEY",16449,"REASON FOR EXAM"))
declare DIG_FIELD_ID = f8 with Protect, Constant(uar_get_code_by("DISPLAYKEY",16449,"ICD9CODE"))
declare CS_FIELD_ID = f8 with protect, constant(uar_get_code_by("DISPLAYKEY",16449,"CARESELECTDSN")) ;1.1
 
/*   
record request   
(    
     1 encntrid              = f8   
     1 personid              = f8   
     1 synonymid             = f8   
     1 catalogcd             = f8   
     1 orderid               = f8   
     1 detaillist[*]   
       2 oefieldid           = f8   
       2 oefieldvalue        = f8   
       2 oefielddisplayvalue = vc   
       2 oefielddttmvalue    = dq8   
       2 oefieldmeaningid    = f8   
       2 valuerequiredind    = i2   
)  
*/
 
RECORD REPLY (
 1 ORDERCHANGEFLAG = I2
  1 ORDERID = F8
  1 DETAILLIST [*]
    2 OEFIELDID = F8
    2 OEFIELDVALUE = F8
    2 OEFIELDDISPLAYVALUE = VC
    2 OEFIELDDTTMVALUE = DQ8
    2 OEFIELDMEANINGID = F8
    2 VALUEREQUIREDIND = I2
  1 STATUS_DATA
    2 STATUS = C1
   2 SUBEVENTSTATUS [1]
      3 SOURCEOBJECTNAME = C15
      3 SOURCEOBJECTQUAL = I4
      3 SOURCEOBJECTVALUE = C50
      3 OPERATIONNAME = C15
      3 OPERATIONSTATUS = C1
      3 TARGETOBJECTNAME = C15
      3 TARGETOBJECTVALUE = C50
)
 
set cnt = size(request->detaillist,5)
set reply_cnt = 0
declare temp_display_value = vc
declare temp_value = f8
 
call log_error(request)

;1.1 Checking for CaseSelect DSN
for (y = 1 to cnt)
	if (request->detaillist[y].oefieldid = CS_FIELD_ID)
		if (request->detaillist[y].oefielddisplayvalue > " ")
			set cnt = 0
		endif
	endif
endfor
;end 1.1
 
;find ICD Values
for (y = 1 to cnt)
if (request->detaillist[y].oefieldid = DIG_FIELD_ID)
 
    set temp_value = request->detaillist[y].oefieldvalue
    set temp_display_value = request->detaillist[y].oefielddisplayvalue
    set y = cnt
endif
endfor
 
 
;Populate Reason for Exam
for (x = 1 to cnt)
if (request->detaillist[x].oefieldid = RFE_FIELD_ID)
 
    set reply_cnt = reply_cnt + 1
 
        set stat = alterlist(reply->detaillist, reply_cnt)
        set reply->detaillist[reply_cnt]->oefieldid = RFE_FIELD_ID
        set reply->detaillist[reply_cnt]->oefieldvalue = temp_value
        set reply->detaillist[reply_cnt]->oefielddisplayvalue = build(temp_display_value)
        set reply->detaillist[reply_cnt]->oefieldmeaningid = request->detaillist[x]->oefieldmeaningid
        if(reply_cnt = 1)
               set reply->orderchangeflag = 1
               set reply->orderid = request->orderid
        endif
endif
endfor
 
set reply->status_data->status = "S"
call echorecord(reply)
 
end
go
 
 
 
