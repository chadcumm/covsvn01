drop program cov_CPM_pat_inactivate_issue:dba go
create program cov_CPM_pat_inactivate_issue:dba
/********************************************************************
   Program: cov_CPM_pat_inactivate_issue
   Folder: CUST_SCRIPT
   Owner: Covenant
   Author: Dawn Greer, DBA
 
   Original CR: 3267
 
   Purpose: The CPM application has a defect and will create new
   person records without CMRNs.  These persons are then being used
   and causing duplicate patients.  This script will inactivate
   the person record so that they cannot be used.  Subquery created
   by Todd Blanchard.
 
   Schedule: Ran Daily at 11:30 am Eastern
 
Modifications:
10/15/2018 - Dawn Greer, DBA 	Formatted the query.  Added look up
                                to see if a referral was associated
                                with the person.  Removed the Time = 30
                                from the with options as it was causing
                                issue in the ops job.
11/19/2018 - Dawn Greer, DBA    JOB was failing.  Fixed issue with the
                                last parenthesis being in the wrong
                                place
12/04/2018 - Dawn Greer, DBA    Update PRSNL_ID to the Scripting ID
                                for me
09/22/2021 - Dawn Greer, DBA    CR 11261 - Added code to exclude patient's 
                                that have an encounter from being inactivated.                                
**********************************************************************/
UPDATE INTO PERSON PP SET PP.ACTIVE_IND = 0, PP.ACTIVE_STATUS_CD = 192.00, PP.ACTIVE_STATUS_PRSNL_ID = 17496723.00,
PP.END_EFFECTIVE_DT_TM = CNVTDATETIME(CURDATE,CURTIME3), PP.UPDT_APPLCTX = 0, PP.UPDT_CNT=PP.UPDT_CNT + 1,
PP.UPDT_ID = 17496723.00, PP.UPDT_DT_TM = CNVTDATETIME(CURDATE,CURTIME3)
WHERE pp.person_id = (SELECT DISTINCT p.person_id FROM PERSON   p
,(left JOIN PERSON_ALIAS pa ON (pa.person_id = p.person_id AND pa.person_alias_type_cd = 2.00 AND pa.active_ind = 1))
,(left JOIN PRSNL per ON (per.person_id = p.person_id AND per.person_id > 1.00))
,(left JOIN ENCOUNTER e ON (e.person_id = p.person_id AND e.active_ind = 1))
,(left JOIN ENCNTR_ALIAS ea ON (ea.encntr_id = e.encntr_id AND ea.encntr_alias_type_cd = 1077.00 AND ea.active_ind = 1))
,(left JOIN CLINICAL_EVENT ce ON (ce.person_id = p.person_id AND (ce.event_class_cd IN (SELECT cv.code_value FROM CODE_VALUE cv
WHERE cv.code_set = 53 AND cv.display_key LIKE "*DOC*"
OR ce.event_cd IN(SELECT cv.code_value FROM CODE_VALUE cv WHERE cv.code_set=72 AND cv.display_key IN ("*NOTE","*NOTES"))))))
,(left JOIN CE_BLOB_RESULT cebr ON (cebr.event_id = ce.event_id AND cebr.storage_cd IN (650264.00)))
,(left JOIN ORDERS o ON (o.encntr_id = e.encntr_id AND o.active_ind = 1))
,(left JOIN SCH_APPT sa ON (sa.person_id = p.person_id AND sa.role_meaning = "PATIENT" AND sa.active_ind = 1))
,(left JOIN SCH_EVENT se ON (se.sch_event_id = sa.sch_event_id AND se.active_ind = 1))
,(left JOIN SCH_EVENT_ATTACH sea ON (sea.sch_event_id = se.sch_event_id AND sea.active_ind = 1))
,(left JOIN ORDERS o2 ON (o2.order_id = sea.order_id AND o2.active_ind = 1))
,(left JOIN REFERRAL rf ON (p.person_id = rf.person_id AND rf.active_ind = 1))
WHERE p.active_ind = 1
AND  p.person_type_cd != 900
AND p.name_last_key NOT IN ("CERNER", "SYSTEM")
AND p.name_last_key NOT IN ("TT*", "FF*", "ZZ*")
AND pa.person_alias_id IS NULL
AND per.person_id IS NULL
AND (ce.event_id IS NULL AND cebr.event_id IS NULL)
AND (o.order_id IS NULL AND o2.order_id IS NULL)
AND (sa.sch_appt_id IS NULL)
AND (rf.person_Id IS NULL)
AND (e.encntr_id IS NULL))	;CR 11261
WITH MAXCOMMIT = 1000
COMMIT
END
GO
