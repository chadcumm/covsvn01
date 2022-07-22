execute cov_call_url 
	 ^MINE^
	,concat(
		^http://covhppmodules.covhlth.net/ColdFusionApplications/Cerner_PopulationGroupAlert/WebService.cfc^
		,^?method=fnPopulationGroupShowAlert^
		,^&strStaffUserName=mmaples^
		,^&strStaffCernerPosition=DBA^
		,^&strPatientCMRN=00997179^
	)
go
