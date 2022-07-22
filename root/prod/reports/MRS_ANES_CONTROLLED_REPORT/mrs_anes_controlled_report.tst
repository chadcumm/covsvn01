;select * from ccl_report_audit cra where cra.object_name = "MRS_ANES_CONTROLLED_REPORT" go

set trace callecho go
set trace recpersist go
set trace rdbdebug go
;set trace rdbbind go
;execute MRS_ANES_CONTROLLED_REPORT
execute COV_ANES_CONTROLLED_REPORT 
;"MINE", 2552503639.00, "20-MAY-2019 00:00:00", "20-MAY-2019 23:59:00"
"MINE", 2552503639.00, "25-JUN-2019 00:00:00", "25-JUN-2019 23:59:00"
 go
