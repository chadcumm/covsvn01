drop program cov_sys_dt_tm go
create program cov_sys_dt_tm
 
SELECT
	P.NAME_FULL_FORMATTED
	, P.BIRTH_DT_TM
 
FROM
	PERSON   P
 
WITH MAXREC = 1
END
GO