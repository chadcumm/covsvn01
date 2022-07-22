drop program requisition_manager_test go
create program requisition_manager_test
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "FIN" = "1909400009"
	, "Org (0) or Chart (1) Level" = 0
	, "F or I Drive" = "I"
 
with OUTDEV, FIN, LEVEL, Drive
 
free record t_rec
record t_rec
(
	1 encntr_id = f8
	1 person_id = f8
	1 static_content = vc
	1 prsnl_id = f8
	1 positioncode = f8
	1 pprcode = f8
	1 executableincontext = vc
	1 devicelocation = vc
	1 staticcontentlocation = vc
	1 debugind = i2
	1 prompts
	 2 org
	  3 f_drive = vc
	  3 i_drive = vc
	 2 chart
	  3 f_drive = vc
	  3 i_drive = vc
	 2 level = i2
	 2 drive = c1
) with protect
 
/*amb_cust_task_driver
  "Output to File/Printer/MINE" = "MINE" ,
  "Patient ID:" = 0.00 ,
  "Encounter ID:" = 0.00 ,
  "Personnel ID:" = 0.00 ,
  "Provider Position Code:" = 0.00 ,
  "Patient Provider Relationship Code:" = 0.00 ,
  "Executable in Context:" = "" ,
  "Device Location:" = "" ,
  "Static Content Location:" = "" ,
  "Debug Indicator:" = 0
  WITH outdev ,patientid ,encounterid ,personnelid ,positioncode ,pprcode ,executableincontext ,
  devicelocation ,staticcontentlocation ,debugind
  */
set t_rec->prompts.level = $LEVEL
set t_rec->prompts.drive = substring(1,1,$DRIVE)
set t_rec->prompts.chart.i_drive = "I:\\WININTEL\\static_content\\custom_mpage_content\\requisition_manager_chart"
set t_rec->prompts.chart.f_drive = "F:\\Users\\chadcummings\\Documents\\phsa_cd\\requisition_manager"
set t_rec->prompts.org.i_drive = "I:\\WININTEL\\static_content\\custom_mpage_content\\requisition_manager"
set t_rec->prompts.org.f_drive = "F:\\Users\\chadcummings\\Documents\\phsa_cd\\requisition_manager_chart"
set t_rec->prsnl_id = reqinfo->updt_id
set t_rec->pprcode = 681274
set t_rec->executableincontext = "powerchart.exe"
 
if (t_rec->prompts.level = 1)
	if (t_rec->prompts.drive = "F")
		set t_rec->static_content = t_rec->prompts.chart.f_drive
	else
		set t_rec->static_content = t_rec->prompts.chart.i_drive
	endif
else
	if (t_rec->prompts.drive = "F")
		set t_rec->static_content = t_rec->prompts.org.f_drive
	else
		set t_rec->static_content = t_rec->prompts.org.I_drive
	endif
endif
 
set t_rec->debugind = 73
 
select into "nl:"
from prsnl p where p.person_id = t_rec->prsnl_id
detail
	t_rec->positioncode = p.position_cd
with nocounter
select into "nl:"
from encntr_Alias ea
	,encounter e
	,person p
plan ea
	where ea.alias = $FIN
join e
	where e.encntr_id = ea.encntr_id
join p
	where p.person_id = e.person_id
detail
	t_rec->encntr_id = e.encntr_id
	t_rec->person_id = e.person_id
with nocounter
 
call echorecord(t_rec)
if (t_rec->prompts.level = 1)
 execute amb_cust_task_driver
	 $OUTDEV
	,t_rec->person_id
	,t_rec->encntr_id
	,t_rec->prsnl_id
	,t_rec->positioncode
	,t_rec->pprcode
	,t_rec->executableincontext
	,t_rec->devicelocation
	,t_rec->static_content
	,t_rec->debugind
else
	execute mp_requisition_manager
	$OUTDEV
	,t_rec->prsnl_id
	,t_rec->positioncode
	,t_rec->executableincontext
	,t_rec->devicelocation
	,t_rec->static_content
	,t_rec->debugind
endif
end go
