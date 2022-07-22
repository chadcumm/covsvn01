set debug_ind = 1 go
execute ndsc_create_session "MINE","https://cerner-test-cdsapi.careselect.org/"
	, "sandCovenantHealth", "tr283orgCov", "CS_LOG_COV2" 
go
