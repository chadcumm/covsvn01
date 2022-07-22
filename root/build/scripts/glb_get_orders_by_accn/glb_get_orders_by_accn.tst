free record 250070request go
record 250070request     (
         1  accession                    = c20
         1  instr_service_resource_cd    = f8
         1  resource_security_ind        = i2
         1  interface_flag               = i2
         1  include_av_codes_ind         = i2
      ) go
set 250070request->accession					= "000012020268000026" go
;set 250070request->accession					= "000012020269000017" go
set 250070request->accession					= "000012020268000027" go
set 250070request->instr_service_resource_cd	= 0 go
set 250070request->resource_security_ind		= 1 go
set 250070request->interface_flag				= 0 go
set 250070request->include_av_codes_ind			= 0 go
set stat = tdbexecute(250008,250007,250070,"REC",250070request,"REC",250070reply) go
call echorecord(250070reply) go
