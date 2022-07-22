/********************************************************************
   Program: cov_mpage_svc_user_status
   Folder: CUST_SCRIPT
   Owner: Covenant
   Author: Dawn Greer, DBA /Mark Maples
 
   Original CR:
 
   Purpose: Process to inactivate/activate/check status of personal
            records.
 
   Schedule: Ad hoc through web app
 
Modifications:
	12/10/2019 - MM - Added strOutput variable to output to Web App
	12/11/2019 - DG - Added Comments and cleaned up the code
**********************************************************************/
drop program cov_mpage_svc_user_status:dba go
create program cov_mpage_svc_user_status:dba
 
PROMPT
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	,"User Name"  = "myusername"
	,"Action" = "ReturnUserStatus"
WITH OUTDEV, usr, covaction
 
DECLARE strOutput = VC			;Output String for Web App
 
SET strOutput = "XXXXXXXXXXXXXXXXXXXX"
 
DECLARE Toggle_Status = VC
 
RECORD user_status (				;Record structure for User Data
	1 usr_cnt 			= i2
	1 usr_list[*]
  2 username 		= vc
  2 full_name		= vc
  2 active_ind	= i2
  2 active_status	= vc
  2 active_status_cd = f8
)
 
CALL ECHO ("Running Query")
CALL ECHO (BUILD2("User:   ", $usr))
CALL ECHO (BUILD2("Action to Take: ", $covaction))
 
SELECT INTO 'NL:'								;Query to pull User Data
  FULL_NAME = p.name_full_formatted,
  USERNAME = p.username,
  ACTIVE_IND = p.active_ind,
  ACTIVE_STATUS = UAR_GET_CODE_DISPLAY(p.active_status_cd),
  ACTIVE_STATUS_CD = p.active_status_cd
FROM
  prsnl p
WHERE
  p.username = $usr
 
;Populating Record Structure
HEAD REPORT
 
cnt = 0
CALL alterlist(user_status->usr_list, 10)
 
DETAIL
 	cnt = cnt + 1
	CALL alterlist(user_status->usr_list, cnt)
 
	user_status->usr_list[cnt].username = username
	user_status->usr_list[cnt].full_name = full_name
	user_status->usr_list[cnt].active_ind = active_ind
	user_status->usr_list[cnt].active_status = active_status
	user_status->usr_list[cnt].active_status_cd = active_status_cd
 
FOOT REPORT
 
	CALL alterlist(user_status->usr_list, cnt)
	user_status->usr_cnt = cnt
 
WITH nocounter, format, noheading, separator="|"
 
SET my_cnt = user_status->usr_cnt
 
IF (my_cnt = 0)
  CALL ECHO ("USER NOT FOUND")
  SET strOutput = "USER NOT FOUND"			;Output - No User Found
ELSE
  CALL ECHO ("User Found")
  SET strOutput = "USER FOUND"
	IF ($covaction = "ReturnUserStatus")
		CALL ECHO (BUILD2("Status of user ", user_status->usr_list[my_cnt].username, " is ",
			user_status->usr_list[my_cnt].active_status))
    	SET strOutput = BUILD2("USER ", CNVTUPPER(user_status->usr_list[my_cnt].active_status))		;Output - User Status
	ELSE IF ($covaction = "ToggleUserStatus")
  		SET Toggle_Status = EVALUATE(user_status->usr_list[my_cnt].active_status,'Active','Inactive',
  			'Inactive','Active', 'No Change')
  		CALL ECHO (BUILD2("Toggle user status  ", user_status->usr_list[my_cnt].username, " from ",
  			user_status->usr_list[my_cnt].active_status, " to ", Toggle_Status))
  		SET strOutput = BUILD2("USER ", CNVTUPPER(user_status->usr_list[my_cnt].active_status))		;Output - Current Status
 
  		IF (Toggle_Status = 'Inactive')
  			CALL ECHO ("Updating to Inactive")
  			UPDATE INTO PRSNL p				;Update to Inactive
  			SET p.active_ind = 0,
    			p.active_status_cd = 192.00 /*INACTIVE*/,
    			p.active_status_prsnl_id = 17755335.00 /*COVENANT, WEBSERVICE*/,
    			p.active_status_dt_tm = CNVTDATETIME(CURDATE,CURTIME3),
    			p.end_effective_dt_tm = CNVTDATETIME(CURDATE,CURTIME3),
    			p.updt_id = 17755335.00 /*COVENANT, WEBSERVICE*/,
    			p.updt_cnt = p.updt_cnt+1,
    			p.updt_dt_tm = CNVTDATETIME(CURDATE,CURTIME3),
    			p.updt_applctx = 0,
    			p.updt_task = 0
  			WHERE p.username = $usr
  			  AND p.active_status_cd = 188.00  /*Active*/		;Current User status has to be Active to Inactivate.
  			WITH MAXCOMMIT = 1000
  			COMMIT
  			SET strOutput = "USER INACTIVATED"			;Output - User Inactivated
  		ELSE IF (Toggle_Status = 'Active')
  			CALL ECHO ("Updating to Active")
  				UPDATE INTO PRSNL P				;Update to Active
  				SET p.active_ind = 1,
    				p.active_status_cd = 188.00 /*ACTIVE*/,
    				p.active_status_prsnl_id = 17755335.00 /*COVENANT, WEBSERVICE*/,
    				p.active_status_dt_tm = CNVTDATETIME(CURDATE,CURTIME3),
    				p.end_effective_dt_tm = CNVTDATETIME("31-DEC-2100 00:00:00"),
    				p.updt_id = 17755335.00 /*COVENANT, WEBSERVICE*/,
    				p.updt_cnt = p.updt_cnt+1,
    				p.updt_dt_tm = CNVTDATETIME(CURDATE,CURTIME3),
    				p.updt_applctx = 0,
    				p.updt_task = 0
  				WHERE p.username = $usr
  				  AND p.active_status_cd = 192.00 /*Inactive*/		;Current User status has to be Inactive to Activate
  				WITH MAXCOMMIT = 1000
  				COMMIT
  				SET strOutput = "USER ACTIVATED"		;Output - User Activated
  			ELSE
  				CALL ECHO ("Nothing Updated")
  				SET strOutput = "NOTHING UPDATED"		;Output - Nothing Updated
  			ENDIF
  		ENDIF
  	ELSE
  	  CALL ECHO ("INVALID ACTION")
  	  SET strOutput = "INVALID ACTION"			;Output - Invalid action passed to program
  	ENDIF
	ENDIF
ENDIF
 
SET _memory_reply_string = strOutput		;Output data for Web App
 
END
GO
 
