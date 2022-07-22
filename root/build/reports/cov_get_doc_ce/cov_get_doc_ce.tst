
set thisuser = curuser go
select into "nl:"
    p.person_id 
from 
    prsnl p 
where 
    p.username = thisuser 
detail
    reqinfo->updt_id     = p.person_id
    reqinfo->position_cd = p.position_cd
go


free set request go
record request
(
   1 person_id                  = f8
   1 cpt_display_flag			= i2
   1 doc_id                     = f8
   1 mnemonic                   = c2
   1 print_ind                  = i2
   1 SURG_PROC_EVENT_CD			= f8
   1 forms[*]
     2 input_form_cd            = f8
     2 event_cd                 = f8
     2 input_form_version_nbr   = i4
     2 sup_cab_def_ind			= i2
)
go

free set reqdata go
record reqdata
(
  1 data_status_cd                      = f8
  1 contributor_system_cd               = f8
  1 active_status_cd                    = f8
) go

set reqdata->data_status_cd                     = 9999 go
set reqdata->contributor_system_cd              = 9999 go
set reqdata->active_status_cd                   = 9999 go

set request->person_id                          = 16590340 go
set request->doc_id                             = 32327365 go
set request->mnemonic                           = "SN" go
set request->print_ind                          = 0 go

/*
set cnt = 0 go
set cnt = cnt + 1 go
set stat = alterlist(request->forms, cnt) go


;CAUTERY
set request->forms[cnt].input_form_cd           = 49238517 go
set request->forms[cnt].input_form_version_nbr  = 45 go
set request->forms[cnt].event_cd                = 49238515 go
*/

select into "nl:"
    sh.segment_header_id,
    sh.input_form_cd,
    sh.input_form_ver_nbr
from segment_header sh,
     input_form_reference ifr

plan sh  where sh.periop_doc_id  = request->doc_id
join ifr where ifr.input_form_cd = sh.input_form_cd

head report
    cnt = 0

head sh.segment_header_id
	if (sh.input_form_cd = 49238515)
    cnt = cnt + 1
    stat = alterlist(request->forms, cnt)
    request->forms[cnt].input_form_cd          = sh.input_form_cd
    request->forms[cnt].input_form_version_nbr = sh.input_form_ver_nbr
    request->forms[cnt].event_cd               = ifr.event_cd
    call echo(uar_Get_code_display(request->forms[cnt].event_cd))
    call echo(request->forms[cnt].input_form_cd)
    call echo(uar_Get_code_display(request->forms[cnt].input_form_cd))
    endif

with nocounter go

;fb_get_clinical_events go
cov_get_doc_ce go



