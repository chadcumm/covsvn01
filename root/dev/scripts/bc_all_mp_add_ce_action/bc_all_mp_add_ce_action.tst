
free record request go
record request
(
	1 blob_in = vc
) go

set request->blob_in = ~{"PATIENTDATA":{"PERSON_ID":20589246.000000,"ENCNTR_ID":110424148.000000}}~ go

set request->blob_in =	concat( 
		~{"RESULTDATA":{~,
		~"CLINICAL_EVENT_ID":230668007.000000,~,
		~"EVENT_ID":230668008.000000,~,
		~"CMV_URL":"http:\/\/phsacdeanp.cerncd.com\/camm\/b0783.phsa_cd.cerncd.com\/service\/mediaContent\~,
		~/{11-6a-5e-44-fc-0e-41-49-83-0f-ef-53-dd-6f-6b-15}",~,
		~"CMV_BASE":"http:\/\/phsacdeanp.cerncd.com\/camm\/b0783.phsa_cd.cerncd.com\/service\/mediaContent\/",~,
		~"IDENTIFIER":"{11-6a-5e-44-fc-0e-41-49-83-0f-ef-53-dd-6f-6b-15}"}}~) go

call echo(request->blob_in) go

execute bc_all_mp_add_ce_action "MINE" go


