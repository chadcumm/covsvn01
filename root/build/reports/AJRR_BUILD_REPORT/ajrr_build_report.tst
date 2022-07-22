free record reply go
record reply (
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 ) go
 
free record internal_icd go
record internal_icd (
   1 qual [* ]
     2 icd10pcs [* ]
       3 val = vc
     2 icd10cm [* ]
       3 val = vc
     2 icd9pcs [* ]
       3 val = vc
     2 icd9cm [* ]
       3 val = vc
     2 cpt [* ]
       3 val = vc
) go

free record retrieved_data go
record retrieved_data (
   1 entries [* ]
     2 surg_case_id = f8
     2 nomenclature_id = f8
     2 hospitalname = vc
     2 hospitalnpi = vc
     2 hospitalascname = vc
     2 hospitalascnpi = vc
     2 patinstitutionid = vc
     2 patient_ssn = vc
     2 firstname = vc
     2 middlename = vc
     2 lastname = vc
     2 patbirthdate = dq8
     2 deathdate = dq8
     2 gender = f8
     2 race = f8
     2 ethnicity_hispanicorlatino = f8
     2 cityofresidence = vc
     2 stateofresidencecd = f8
     2 stateofresidence = vc
     2 zipofresidence = vc
     2 patcountry = vc
     2 patemail = vc
     2 surgeonfirstname = vc
     2 surgeonlastname = vc
     2 surgeonnpi = vc
     2 ppxdate = dq8
     2 admsndt = dq8
     2 dschrgdt = dq8
     2 pdx [* ]
       3 value = vc
     2 patbmi = vc
     2 ppx [* ]
       3 value = vc
     2 comorbidity [* ]
       3 value = vc
     2 poa [* ]
       3 value = vc
     2 anesthesiatype = vc
     2 laterality = vc
     2 surgicalapproach = vc
     2 techniquehip = vc
     2 techniqueknee = vc
     2 periarticularinjection = vc
     2 procedurestarttime = dq8
     2 procedureendtime = dq8
     2 procedureduration = i4
     2 computernavigation = vc
     2 roboticassistedsurgery = vc
     2 componentname [* ]
       3 value = vc
     2 manufacturername [* ]
       3 value = vc
     2 catalognumber [* ]
       3 value = vc
     2 lotnumber [* ]
       3 value = vc
     2 lengthofstay = vc
     2 ajrraccountid = vc
     2 ajrrlocationid = vc
     2 dischdispfieldvalue = vc
     2 asa_class = f8
     2 pat_height_cm = vc
     2 pat_weight_kg = vc
     2 pat_height_ftin = vc
     2 pat_weight_lbs = vc
) go

free record temp_data go
record temp_data (
   1 entries [* ]
     2 surg_case_id = f8
     2 computernavigation = vc
     2 roboticassistedsurgery = vc
) go

set debug_ind = 1 go 
execute ajrr_build_report
	 "MINE"
	,"01-FEB-2019"
	,"28-FEB-2019"
	,VALUE(3144503.00) ;Parkwest Medical Center
go
