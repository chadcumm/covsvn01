 
drop program cov_all_prompt_test:DBA go
create program cov_all_prompt_test:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Select Clinic" = 0 

with OUTDEV, start_datetime, end_datetime, clinic
 

declare opr_clinic_var    = vc with noconstant("")
 
;Set clinic variable
if(substring(1,1,reflect(parameter(parameter2($clinic),0))) = "L");multiple values were selected
	set opr_clinic_var = "in"
elseif(parameter(parameter2($clinic),1)= 0.0) ;all[*] values were selected
	set opr_clinic_var = "!="
else								  ;a single value was selected
	set opr_clinic_var = "="
endif
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/


select into $outdev

org.organization_id, org.org_name

from organization org

plan org where operator(org.organization_id, opr_clinic_var, $clinic)
	and org.active_ind = 1
	
order by org.org_name	
 
with nocounter, separator=" ", format 
 

end go
 
 
 
 
