/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Oct'2020
	Solution:			Infection Control
	Source file name:	      cov_ic_misc_covid_fever.prg
	Object name:		cov_ic_misc_covid_fever
	Request#:			CR# 8785
	Program purpose:	      MIS-C & COVID19 Alert
	Executing from:		Rule
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------	------------------------------------------
******************************************************************************/

drop program cov_ic_misc_covid_fever:dba go
create program cov_ic_misc_covid_fever:dba
 

declare temp_oral_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Temperature Oral")),protect
declare temp_tympa_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Temperature Tympanic")),protect
declare temp_rectal_var  = f8 with constant(uar_get_code_by("DISPLAY", 72, "Temperature Rectal")),protect
declare temp_axil_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Temperature Axillary")),protect
declare temp_core_var    = f8 with constant(uar_get_code_by("DISPLAY", 72, "Temperature Core	")),protect
declare temp_bladder_var = f8 with constant(uar_get_code_by("DISPLAY", 72, "Temperature Bladder")),protect
declare temp_tempo_var   = f8 with constant(uar_get_code_by("DISPLAY", 72, "Temperature Temporal Artery")),protect

declare log_message = vc with noconstant('')
set retval = 0

select into 'nl:'
ce.encntr_id, ce.event_cd, event = uar_get_code_display(ce.event_cd), ce.result_val
, event_end_dt = format(ce.event_end_dt_tm, 'mm/dd/yyyy hh:mm:ss;;d')
, minutes = datetimediff(cnvtdatetime(curdate,curtime3), ce.event_end_dt_tm ,4)

from	clinical_event ce, dummyt d2

plan ce where ce.encntr_id = trigger_encntrid ;116690002.00
	and ce.event_cd in(temp_oral_var,temp_tympa_var,temp_rectal_var,temp_axil_var,temp_core_var,temp_bladder_var,temp_tempo_var)  
	and ce.valid_until_dt_tm = cnvtdatetime ("31-DEC-2100 00:00:00" )
 	and ce.result_status_cd in (34.00, 25.00, 35.00)
	and ce.event_tag != "Date\Time Correction"

join d2 where cnvtreal(ce.result_val) >= 38.0
	
head report
	log_message = "No Temperature charting found"
	retval = 0
detail
	log_message = concat("Temperature found on ",format(ce.event_end_dt_tm,";;q"))
	retval = 100

with nocounter

call echo(build2('log_msg = ', log_message,  '--retval = ', retval))

 
end go

/*
     703526.00	Temperature Tympanic
     703530.00	Temperature Rectal
     703535.00	Temperature Axillary
   28214345.00	Temperature Core	
     703558.00	Temperature Oral
    2700535.00	Temperature Bladder
    4157752.00	Temperature Temporal Artery






