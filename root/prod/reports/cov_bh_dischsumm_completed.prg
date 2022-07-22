/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Paramasivam
	Date Written:		Oct'2020
	Solution:			BH
	Source file name:  	cov_bh_dischsumm_completed.prg
	Object name:		cov_bh_dischsumm_completed
	Request#:			
 
	Program purpose:	      Request from Peninsula for compliance
	Executing from:		CCL/DA2/BH folder
  	Special Notes:          Excel file.
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer	     Comment
----------	-----------	------------------------------------------

******************************************************************************/


drop program cov_bh_dischsumm_completed:dba go
create program cov_bh_dischsumm_completed:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"       ;* Enter or select the printer or file name to send this report to.
	, "Start Discharged Date/Time" = "SYSDATE"
	, "End Discharged Date/Time" = "SYSDATE" 

with OUTDEV, start_datetime, end_datetime



/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/


/**************************************************************
; DVDev Start Coding
**************************************************************/

select distinct into $outdev

fin = trim(ea.alias), patient_type = trim(uar_get_code_display(e.encntr_type_cd)), e.disch_dt_tm  "@SHORTDATETIME" 
,location = trim(uar_get_code_display(e.loc_facility_cd)), document_type = trim(uar_get_code_display(ce.event_cd))
, document_dt = ce.performed_dt_tm "@SHORTDATETIME" , Physician = trim(pr.name_full_formatted)
;, cv1.code_value,e.encntr_id, e.loc_facility_cd;, ce.performed_prsnl_id, ce.verified_prsnl_id

from encounter e 
	,clinical_event ce
	,prsnl pr
	,encntr_alias ea
	
plan e where e.loc_facility_cd in(2553765579.00,2553765587.00,2553765603.00,2553765611.00,2553765619.00)
	and e.disch_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)

join ce where ce.encntr_id = e.encntr_id
      and ce.view_level = 1
      and ce.publish_flag = 1 ;active
      and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
      and ce.result_status_cd in (23.00, 34.00, 25.00, 35.00)
 	and ce.event_cd = 2820588.00 ;Discharge Summary

join pr where pr.person_id = ce.performed_prsnl_id
 	and ce.performed_prsnl_id in(12408625.00, 12410364.00, 12412351.00, 12413353.00, 12414623.00, 12408800.00)
 	and pr.active_ind = 1
	;or ce.verified_prsnl_id in(12408625.00, 12410364.00, 12412351.00, 12413353.00, 12414623.00))

join ea where ea.encntr_id = e.encntr_id
	and ea.active_ind = 1
	and ea.encntr_alias_type_cd = 1077

with nocounter, separator=" ", format;, time = 300

;-----------------------------------------------------------------------------------------------------------

end go



/*
select distinct into $outdev

fin = trim(ea.alias), patient_type = trim(uar_get_code_display(e.encntr_type_cd)), e.disch_dt_tm  "@SHORTDATETIME" 
,location = trim(uar_get_code_display(e.loc_facility_cd)), document_type = trim(cv1.display)
, document_dt = ce.performed_dt_tm "@SHORTDATETIME" , Physician = trim(pr.name_full_formatted)
;, cv1.code_value,e.encntr_id, e.loc_facility_cd;, ce.performed_prsnl_id, ce.verified_prsnl_id

from encounter e 
	,clinical_event ce
	,code_value cv1
	,prsnl pr
	,encntr_alias ea
	
plan cv1 where cv1.code_set =  72 
	and cv1.active_ind = 1 
	and cnvtlower(cv1.display) = '*discharge summary*'

join ce where ce.event_cd = cv1.code_value
      and ce.view_level = 1
      and ce.publish_flag = 1 ;active
      and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
      and ce.result_status_cd in (23.00, 34.00, 25.00, 35.00)
 	;and ce.event_cd = 2820588.00 ;Discharge Summary

join e where e.encntr_id = ce.encntr_id
	and e.loc_facility_cd IN(2553765579.00,2553765587.00,2553765603.00,2553765611.00,2553765619.00)
	and e.disch_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)

join pr where pr.person_id = ce.performed_prsnl_id
 	and ce.performed_prsnl_id in(12408625.00, 12410364.00, 12412351.00, 12413353.00, 12414623.00, 12408800.00)
 	and pr.active_ind = 1
	;or ce.verified_prsnl_id in(12408625.00, 12410364.00, 12412351.00, 12413353.00, 12414623.00))

join ea where ea.encntr_id = e.encntr_id
	and ea.active_ind = 1
	and ea.encntr_alias_type_cd = 1077

with nocounter, separator=" ", format, time = 300


end
go





/***********************************************

Requesting a report indicating the compliance rate (percentage) for Discharge Summaries completed 
within 30 days for the following physicians in 2019:
 
Dr. Reggie Raman
Dr. Donna McKenzie
Dr. Shyam Vuyyuru
Dr. Mujeeb Khan
Dr. Surendra Sharma

12408625.00	KHAN, MUJEEB HASAN MD
12410364.00	MCKENZIE, DONNA GAIL MD
12412351.00	RAMAN, RAJENDRA T MD
12413353.00	SHARMA, SURENDRA KUMAR MD
12414623.00	VUYYURU, SHYAMSUNDER PRASA MD
12408800.00	KUPFNER, JOHN GREGORY MD



