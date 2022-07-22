drop program cov_AMB_Pat_balance_zero:dba go
create program cov_AMB_Pat_balance_zero:dba
/********************************************************************
   Program: cov_AMB_Pat_balance_zero
   Folder: CUST_SCRIPT
   Owner: Covenant
   Author: Dawn Greer, DBA
 
   Original CR: 2899
 
   Purpose: The NextGen Patient Balance Import doesn't clear out the
          balances when they are paid and the clinics are collecting
          money on balances that are zero.  This program will run
          as step 1 to clear out the balances before loading the new
          file for patient balances from NextGen.
 
   Schedule: Runs Daily at 4:30 am
   Ops Job: NextGen Patient Balance Import
 
Modifications:
 
**********************************************************************/
UPDATE INTO LONG_TEXT L SET L.LONG_TEXT = "0.00", L.UPDT_APPLCTX = 0, L.UPDT_CNT=L.UPDT_CNT + 1,
L.UPDT_ID = 17496723.00, L.UPDT_DT_TM = CNVTDATETIME(CURDATE,CURTIME3)
WHERE L.LONG_TEXT_ID = (SELECT DISTINCT p.LONG_TEXT_ID
FROM PERSON_INFO P, LONG_TEXT   L
WHERE P.INFO_TYPE_CD =        1170.00   ; User Defined
AND P.INFO_SUB_TYPE_CD =  2559215669.00  ; Patient Balance
AND P.ACTIVE_IND = 1		;Active Person Info record
AND P.LONG_TEXT_ID = L.LONG_TEXT_ID
AND L.ACTIVE_IND = 1)		;Active Long Text record
WITH MAXCOMMIT = 1000
COMMIT
END
GO
 