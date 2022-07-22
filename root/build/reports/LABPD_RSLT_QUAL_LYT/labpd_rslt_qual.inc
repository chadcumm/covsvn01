record  lab_records  (
  1  qual     =  i4
  1  sort_var = vc
  1  rec [*]
; pt demographics
    2  age          = c20
    2  dob          = dq8
    2  location     = c40
    2  mrn          = vc
    2  patient_name = c26
    2  person_id    = f8
    2  ssn          = c11
; date and times
    2  coll_dt_tm     = dq8
    2  comp_dt_tm     = dq8
    2  inlab_dt_tm    = dq8
    2  order_dt_tm    = dq8
    2  verified_dt_tm = dq8
; order demographics
    2  accession      = c20
    2  catalog_cd     = f8
    2  order_doc      = c26
    2  order_doc_id   = f8
    2  order_id       = f8
    2  order_loc      = f8
    2  order_loc_name = c20
    2  priority       = c20
    2  spec_type      = c20
    2  test           = c30
; result demographics
    2  dta_cd              = f8
    2  comment             = vc
    2  loinc_cd            = c12
    2  interp              = vc
    2  normal_lo           = vc
    2  normal_hi           = vc
    2  result_status       = vc
    2  result_display      = vc
    2  result_flg          = vc
    2  result_sort         = f8
    2  result_val          = vc
    2  result_id           = f8
    2  service_resource    = c20
    2  service_resource_cd = f8
    2  units               = vc
    2  verified_by         = c26
    2  results_qual        = i4
)
record  locations  (
  1  qual  =  i4
  1  rec [*]
    2  loc_name  =  c20 )
 

