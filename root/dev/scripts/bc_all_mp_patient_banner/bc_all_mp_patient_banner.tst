
free record request go
record request
(
	1 blob_in = vc
) go

set request->blob_in = ~{"PATIENTDATA":{"PERSON_ID":20589246.000000,"ENCNTR_ID":110424148.000000}}~ go
execute bc_all_mp_patient_banner "MINE" go
