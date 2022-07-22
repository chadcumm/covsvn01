
drop program cov_check_patient_pop_url_tst go
create program cov_check_patient_pop_url_tst

set debug_ind = 1 
set link_encntrid = 106417540 
set link_personid = 15167250 

execute cov_check_patient_pop_url "fnPopulationGroupShowAlert" 

for (ii = 1 to 100)
	call cov_check_patient_pop_url ;^fnPopulationGroupShowAlert^
	
endfor

end
go
