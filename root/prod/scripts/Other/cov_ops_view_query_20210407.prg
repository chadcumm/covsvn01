drop program cov_ops_view_query go
create program cov_ops_view_query
 
SELECT
	P.NAME_FULL_FORMATTED
	, P.BIRTH_DT_TM
 
FROM
	PERSON   P
 
WITH MAXREC = 1
 
end
go
 