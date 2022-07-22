/***********************PROGRAM NOTES*************************
        Source file name:       cov_ops_jobs.PRG
        Object name:            cov_ops_jobs
        Request #:              N/A
 
        Product:                Ops View Monitor
        Product Team:           Operations
 
        Program purpose:        Display Ops Jobs
 
        Tables read:            person p                                                                                  
					            ops_control_group ocg                                                                                  
					            ops_task ot                                                                           
								ops_task ot2
								ops_day_of_month dom
								ops_day_of_week dow
								ops_week_of_month wom
								ops_month_of_year moy
								ops_job oj
								ops_job_step ojs
 
        Tables updated:         N/A
 
        Executing from:         DA2/Reporting Portal
 
        Special Notes:          Revision of cov_ops_jobs
 
*****************************************************************************/
/***********************Change Log*******************************************
VERSION DATE        ENGINEER            COMMENT
-------	---------   ----------------    -------------------------------------
001		11/8/2018 	Dawn Greer, DBA		Created
*****************************************************************************/
 
drop program cov_ops_jobs:dba go
create program cov_ops_jobs:dba
 
DECLARE temppath_var = vc with noconstant("cer_temp:")
DECLARE temppath2_var = vc with noconstant("$cer_temp/")
 
DECLARE file_var = vc with noconstant("covopsjobs_")
DECLARE filepath_var = vc with noconstant ("")
DECLARE output_var = vc with noconstant ("")
 
DECLARE cmd = vc with noconstant("")
DECLARE len = i4 with noconstant(0)
DECLARE stat = i4 with noconstant(0)
 
record ops_jobs (
   1 job_id = F8
   1 job_name = vc
   1 job_active = i2
   1 job_beg_effective_dt_tm = dq8
   1 job_end_effective_dt_tm = dq8
   1 job_update_user = vc100
   1 job_update_dt_tm = dq8
   1 tasks[*]
   		2 task_id = F8
   		2 task_active = i2
   		2 task_beg_effective_dt_tm = dq8
   		2 task_end_effective_dt_tm = dq8
   		2 task_autostart = i2
   		2 task_enable = i2
   		2 task_type = vc
   		2 frequency = vc
   		2 time_frequency = vc
   		2 job_template = vc
   		2 task_update_user = vc100
   		2 task_update_dt_tm = dq8
   		2 steps[*]
   			3 step_id = F8
 
 
SET outputdir = logical("cer_temp")
SET filename = concat("covopsjobs",format(curdate, "yyyymmdd;;d"), ".txt")
SET astream = "/cerner/w_custom/p0665_cust/to_client_site/IT/OpsJobs/"
SET outfile = concat("cer_temp:covopsjobs" ,  format(curdate, "yyyymmdd;;d"),".txt")
 
SELECT INTO "NL:"
 
CONTROL_GROUP_ENABLED = ocg.enable_ind
, TASK_ACTIVE = ot.active_ind
, TASK_ENABLED = ot.enable_ind
, TASK_AUTOSTART = ot.autostart_ind
, NODE = ocg.host                                                                                            
, CONTROL_GROUP = ocg.name                                                                                    
, CONTROL_GROUP_SERVER_NUM = OCG.server_number                                                                    
, JOB_GROUP_NAME = ot2.job_grp_name                                                                                               
, Start_Time = IF (ot.task_type < 2                                                                                              
            and ((mod (cnvtmin (ot.beg_effective_dt_tm ) ,1440 ) >= 0 )                                                     
            AND (mod (cnvtmin (ot.beg_effective_dt_tm ) ,1440 ) <= 1439 ) ))                                                
            format (ot.beg_effective_dt_tm ,"hh:mm;;m") endif                                                               
, Job_Name = if (textlen (trim (ot.job_grp_name) ) > 0) ot.job_grp_name else oj.name endif                               
, JOB_ID = oj.OPS_JOB_ID
, TASK_ID = ot.ops_task_Id
, TASK_TYPE = if (ot.task_type = 0) "Job Group" elseif                                                                     
            (ot.task_type = 1) "Stand Alone Job" elseif                                                               
            (ot.task_type = 2) "Job in a Job Group" endif                                                             
            ; Task_Type Values: 0 = job group, 1 = stand alone job, 2 = job in a job group                                    
, FREQUENCY = IF (ot.frequency_type = 1 ) "Runs one time" ELSEIF                                                         
                                                                                                
       (ot.frequency_type = 2 and ot.day_interval = 1 ) "Runs daily" ELSEIF                                                  
            (ot.frequency_type = 2 and ot.day_interval > 1)                                          
            concat ("Runs every " ,trim (cnvtstring (ot.day_interval ) ) , " days" ) ELSEIF                               
                                                                                              
       (ot.frequency_type = 3 and ot.day_interval = 1 )                                                              
            concat ("Runs every week on " ,                                                 
            evaluate(dow.day_of_week, 1,"Sun", 2,"Mon", 3,"Tue", 4,"Wed", 5,"Thu", 6,"Fri", 7,"Sat") ) ELSEIF                
 
       (ot.frequency_type = 3 and ot.day_interval > 1 )                                                             
            concat ("Run every " ,trim (cnvtstring (ot.day_interval ) ) , " weeks on " ,                                       
            evaluate(dow.day_of_week, 1,"Sun", 2,"Mon", 3,"Tue", 4,"Wed", 5,"Thu", 6,"Fri", 7,"Sat") ) ELSEIF                  
                                                                                                
       (ot.frequency_type = 4 and dom.day_of_month = 32 )                                                                 
            concat ("Runs Last day " ," of " ,                                                 
            evaluate(moy.month_of_year, 0,"All Months", 1,"Jan", 2,"Feb", 3,"Mar", 4,"Apr", 5,"May",                  
                   6,"Jun", 7,"Jul", 8,"Aug", 9,"Sep", 10,"Oct", 11,"Nov", 12,"Dec") ) ELSEIF                       
 
       (ot.frequency_type = 4 and dom.day_of_month != 32 )                                                                
            concat ("Runs day " ,trim (cnvtstring(dom.day_of_month)) ," of " ,                                                 
            evaluate(moy.month_of_year, 0,"All Months", 1,"Jan", 2,"Feb", 3,"Mar", 4,"Apr", 5,"May",                           
                  6,"Jun", 7,"Jul", 8,"Aug", 9,"Sep", 10,"Oct", 11,"Nov", 12,"Dec") ) ELSEIF                       
                                                                                                
       (ot.frequency_type = 5)                                                             
            concat ("Runs the ", evaluate(wom.week_of_month, 1,"1st", 2,"2nd", 3,"3rd", 4,"4th", 5,"Last"), " ",          
            evaluate(dow.day_of_week, 1,"Sun", 2,"Mon", 3,"Tue", 4,"Wed", 5,"Thu", 6,"Fri", 7,"Sat"),                        
            evaluate(moy.month_of_year, 0,"All Months", 1,"Jan", 2,"Feb", 3,"Mar", 4,"Apr", 5,"May",                     
                  6,"Jun", 7,"Jul", 8,"Aug", 9,"Sep", 10,"Oct", 11,"Nov", 12,"Dec") ) ENDIF  
, TIME_FREQUENCY = IF (ot.task_type = 2 and ot.time_ind in (0,1)) " " ELSEIF                                
       (ot.task_type != 2 and ot.TIME_IND = 0) "Once " ELSEIF                            
            ; Time_Ind Values: 0 = once, 1 = many times during one day                                         
                                                                                               
       (ot.task_type != 2 and ot.time_ind = 1 and ot.TIME_INTERVAL_IND = 0)                                                    
         CONCAT ("Recurs every ",trim (cnvtstring (ot.time_interval) ), " ", "Minutes", " ending at ",                     
                 format (ot.end_effective_dt_tm ,"hh:mm;;m")) ELSEIF                    
       (ot.task_type != 2 and ot.time_ind = 1 and ot.time_interval_ind = 1)        
         CONCAT ("Recurs every ",trim (cnvtstring (ot.time_interval) ) , " ", "Hours", " ending at ",              
         format (ot.end_effective_dt_tm ,"hh:mm;;m" ) ) ENDIF                  
, Job_Template = oj.name                                                                                              
, OSP_BATCH = osp.batch_selection                                                                                           
, STEP_INFO = CONCAT (format (ojs.step_number, "###;P0"), "  ",                                     
                        trim (ojs.step_name), " - ", "#",                                                        
                        trim (cnvtstring (ojs.request_number)))                                                               
, STEP_BATCH = ojs.batch_selection                                                                                            
, OUTPUT_DIST = ojs.output_dist                                                                                    
, OUTPUT_DIST_IND = ojs.output_dist_ind                                                                                           
, TASK_BEGIN_DATE = ot.beg_effective_dt_tm                                                                                     
, TASK_UPDATE_DATE = ot.updt_dt_tm                                                                                      
, TASK_UPDATE_PERSON = p.name_full_formatted   
, JOB_BEGIN_DATE = oj.beg_effective_dt_tm
                                                                                  
;,ot.ops_job_id                                                                                      
;, ot.ops_task_id                                                                                    
;, ot.parent_id                                                                                        
                                                                                               
FROM                                                                                      
            person p                                                                                  
            , ops_control_group   ocg                                                                                  
            , ops_task   ot                                                                           
            , (LEFT JOIN ops_task     ot2 ON (ot.parent_id = ot2.ops_task_id and OT.ops_job_id !=0.0))                 
            , (LEFT JOIN ops_day_of_month   dom ON (ot.ops_task_id = dom.ops_task_id))                                   
            , (LEFT JOIN ops_day_of_week     dow ON (ot.ops_task_id = dow.ops_task_id))                           
            , (LEFT JOIN ops_week_of_month wom ON (ot.ops_task_id = wom.ops_task_id))                             
            , (LEFT JOIN ops_month_of_year  moy ON (ot.ops_task_id = moy.ops_task_id))                                    
            , (LEFT JOIN ops_job   oj ON (ot.ops_job_id = oj.ops_job_id))                                            
            , (LEFT JOIN ops_job_step   ojs ON (ot.ops_job_id = ojs.ops_job_id))                                   
            , (LEFT JOIN ops_schedule_param                                                                        
            osp ON (ot.ops_task_id = osp.ops_task_id and osp.ops_job_step_id = ojs.ops_job_step_id))                    
                                                                                               
PLAN ot                                                                                               
WHERE ot.enable_ind = 1 and ot.active_ind = 1 ;and ot.end_date_ind = 0                                                     
                                                                                               
JOIN P where                                                                                       
ot.updt_id = p.person_id                                                                                   
                                                                                               
                                                                                               
JOIN ocg WHERE ocg.ops_control_grp_id = ot.ops_control_grp_id                                                         
                                                                                               
JOIN ot2                                                                                              
JOIN dom                                                                                            
JOIN dow                                                                                             
JOIN wom                                                                                            
JOIN moy                                                                                             
JOIN oj                                                                                    
JOIN ojs                                                                                               
JOIN osp  
ORDER BY ocg.host DESC
     
HEAD REPORT
	stat = MakeDataSet(100)
 
DETAIL
	stat = WriteRecord(0)
 
FOOT REPORT
	stat = CloseDataSet(0)
 
;CALL ECHO(stat)
 
WITH NOCOUNTER, CHECK, REPORTHELP, FORMAT (date, "MM/DD/YYYY HH:mm:ss;;D");, SEPARATOR = "|"
;WITH PCFORMAT ("", value(char(9)) ,0,1), FORMAT (date, "MM/DD/YYYY HH:mm:ss;;D")
;set statx = 0
;set  outfile  = concat("cp $cer_temp/", filename," ",astream, filename)
;call echo (outfile)
;call dcl( outfile, size(outfile), statx)
                                                                                  
END GO