drop program cov_phq_test go
create program cov_phq_test

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
	, "Facility" = 0
	, "Nurse Unit" = 0
	, "Report Type" = 0 

with OUTDEV, start_datetime, end_datetime, acute_facilities, nurse_unit, 
	repo_type

declare tt = vc 
;--------------------------------------------------------------------------------------

execute cov_phq_bcma_prsnl_detail 'NL:', value($start_datetime, $end_datetime, $acute_facilities, $nurse_unit)
	;set dash->fac[fcnt].list[1].department_cnt = sched_appt->sched_cnt

	set tt = bcma_sum->report_ran_byreport_ran_by
	
	call


/*

if($repo_type = 3);Unit total only 

select distinct into $outdev
 	nurse_unit = trim(uar_get_code_description(bcma_sum->list[d1.seq].nurse_unit_cd))
	, total_medications_given = bcma_sum->list[d1.seq].unit_tot_med_given
	, medications_scanned = bcma_sum->list[d1.seq].unit_tot_med_scan
 	, medications_scan_percent = 
 	    build2(((bcma_sum->list[d1.seq].unit_tot_med_scan / bcma_sum->list[d1.seq].unit_tot_med_given) * 100), '%')
	, wristbands_scanned = bcma_sum->list[d1.seq].unit_tot_wrist_scan
	, wristbands_scan_percent = 
	    build2(((bcma_sum->list[d1.seq].unit_tot_wrist_scan / bcma_sum->list[d1.seq].unit_tot_med_given) * 100), '%')
 
from
	(dummyt   d1  with seq = size(bcma_sum->list, 5))
 
plan d1
 
order by nurse_unit
 
with nocounter, separator=" ", format
 
elseif($repo_type = 2);PRSNL detail only 

select into $outdev
	 nurse_unit = trim(uar_get_code_description(bcma_sum->list[d1.seq].nurse_unit_cd))
	, personnel_name = trim(substring(1, 30, bcma_sum->list[d1.seq].prsnl_name))
	, role = trim(substring(1, 100, bcma_sum->list[d1.seq].prsnl_role))
	, total_medications_given = bcma_sum->list[d1.seq].pr_tot_med_given
	, medications_scanned = bcma_sum->list[d1.seq].pr_tot_med_scan
 	, medications_scan_percent = 
 	  build2(((bcma_sum->list[d1.seq].pr_tot_med_scan / bcma_sum->list[d1.seq].pr_tot_med_given) * 100), '%')
	, wristbands_scanned = bcma_sum->list[d1.seq].pr_tot_wrist_scan
	, wristbands_scan_percent = 
	  build2(((bcma_sum->list[d1.seq].pr_tot_wrist_scan / bcma_sum->list[d1.seq].pr_tot_med_given) * 100), '%')
 
from
	(dummyt   d1  with seq = size(bcma_sum->list, 5))
 
plan d1
 
order by nurse_unit
 
with nocounter, separator=" ", format

endif

*/

end
go

