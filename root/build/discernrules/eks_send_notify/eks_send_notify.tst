;execute eks_send_notify "MINE","CCUMMIN4","N","HTML TEST","@FILE:[cov_eks_alert_template.html]",1 go

free record 3011001Request go
record 3011001Request (
  1 Module_Dir = vc  
  1 Module_Name = vc  
  1 bAsBlob = i2   
) go

free record 3011001Reply go
record 3011001Reply (
    1 info_line [* ]
      2 new_line = vc
    1 data_blob = gvc
    1 data_blob_size = i4
    1 status_data
      2 status = c1
      2 subeventstatus [1 ]
        3 operationname = c25
        3 operationstatus = c1
        3 targetobjectname = c25
        3 targetobjectvalue = vc
  ) go
  
free record 3051004Request go
record 3051004Request (
  1 MsgText = vc  
  1 Priority = i4   
  1 TypeFlag = i4   
  1 Subject = vc  
  1 MsgClass = vc  
  1 MsgSubClass = vc  
  1 Location = vc  
  1 UserName = vc  
) go

declare html_output = vc with noconstant(" ") go

set 3011001Request->Module_Dir = "ccluserdir:" go
set 3011001Request->Module_Name = "simple.html" go
set 3011001Request->bAsBlob = 1 go

execute eks_get_source with replace ("REQUEST" ,3011001Request ) , replace ("REPLY" ,3011001Reply ) go

set html_output = 3011001Reply->data_blob go

;set 3051004Request->MsgText = "@file:[simple.html]" go
set 3051004Request->MsgText = 3011001Reply->data_blob go
set 3051004Request->Priority = 100 go
set 3051004Request->TypeFlag = 0 go
set 3051004Request->Subject = "Invalid Ordering Provider and Communication Type" go
set 3051004Request->MsgClass = "APPLICATION" go
set 3051004Request->MsgSubClass = "DISCERN" go
set 3051004Request->Location = "REPLY" go
set 3051004Request->UserName = "ccummin4" go
;set 3051004Request->UserName = "UA.JHARGIS" go
;set 3051004Request->UserName = "dkitzmil" go
;set 3051004Request->UserName = "nursern" go

set stat = tdbexecute(3030000,3036100,3051004,"REC",3051004Request,"REC",3051004Reply) go

call echorecord(3051004Request) go
call echorecord(3051004Reply) go


