drop program cov_call_url go
create program cov_call_url
prompt

	"Output to File/Printer/MINE" = "MINE",
	"URL:" ="" ,
	"AuthString:" ="" ,
	"dateString:" ="" ,
	"msgString: " ="",
	"userString: " =""
with outdev, URL, authString, dateString, msgString, user

declare callPost(uri_put = vc, response = vc(REF))=NULL with Public

;General Variables
declare stat = i4 with protect
declare size = i4 with protect
declare requestBody = vc with protect
declare pos = i4 with protect
declare actual = i4 with protect
declare uri = vc with protect
declare uri_comp = vc with protect
declare uri_put = vc with protect
declare response = vc with protect
declare _CRLF = vc with persistscript, CONSTANT( build2(char(13),char(10)) )
declare msg = vc with protect
declare source = vc with noConstant("")
declare target = vc with noConstant("")
declare cnt = i4 with noConstant(0)
declare i = i4 with noConstant(0)
declare index = i4 with noConstant(0)
declare os_flag = vc with noConstant("")
declare buf_cclisam = vc
declare idx_file = vc with protect, noConstant("")
declare idx_pos = i4 with protect, noConstant(0)
declare COMPONENT_FILE = vc with noconstant
declare HEALTH_SYSTEM_SOURCE_ID = vc with protect
set requestBody = "REQUEST BODY"
declare dic_var = vc with noConstant("")
declare response = vc with noConstant("")
declare auth_str = vc with protect, noConstant("")
declare date_str = vc with protect, noConstant("")
declare user_str = vc with protect, noConstant("")
declare return_value = vc with public,noconstant("")

set uri_put = $URL
call echo(uri_put)
execute srvuri

set return_value =  callPost(uri_put, response)

call echo(return_value)


SUBROUTINE callPost(uri_put, response)

  ;srvuri variables
  declare hUri_put = i4 with protect
  declare hReq_put = i4 with protect
  declare hBuf_put = i4 with protect
  declare hResp_put = i4 with protect
  declare hResp_Props_put = i4 with protect
  declare hProps_put = i4 with protect
  declare customHeaderProp_put = i4 with protect
  declare pos_put = i4 with protect
  declare buf = c8192 with protect
  declare hBuf = i4 with protect

  set hUri_put = uar_SRV_GetURIParts (value(uri_put))
  set hReq_put = uar_SRV_CreateWebRequest (hUri_put)
  set hProps_put = uar_SRV_CreatePropList ()
  set customHeaderProp_put = uar_SRV_CreatePropList ()
  set hBuf_put = uar_SRV_CreateMemoryBuffer (3, 0, 0, 0, 0, 0) ;3 = SRV_ACCESS_READ_WRITE
  set stat = uar_SRV_SetBufferPos (hBuf_put, 0, 0, pos_put)
  set stat = uar_SRV_WriteBuffer(hBuf_put, msg, size(msg), actual)
  set stat = uar_SRV_SetPropString(hProps_put,"method","get")
  ;set stat = uar_SRV_SetPropString(hProps_put,"accept", "application/json")
  set stat = uar_SRV_SetPropString(hProps_put,"contenttype", "application/json")
  ;set stat = uar_SRV_SetPropString(hProps_put,"useragent", "Mozilla/5.0")

  ;set stat = uar_SRV_setPropString(hProps_put, "encoding", "gzip,deflate,sdch")
  set stat = uar_SRV_SetPropString(customHeaderProp_put,"Authorization", nullterm(auth_str))
  set stat = uar_SRV_SetPropHandle(hProps_put,"customHeaders",customHeaderProp_put,1)
  set stat = uar_SRV_SetPropHandle(hProps_put,"reqBuffer",hBuf_put,1)
  set stat = uar_SRV_SetWebRequestProps (hReq_put, hProps_put)
  set hResp_put = uar_SRV_GetWebResponse (hReq_put, hBuf_put)

  IF(hResp_put = 0)
  	set response = concat(response, "Invalid handle returned, failure")
  	call echo ("invalid handle")
  ENDIF
  set hResp_Props_put = uar_SRV_GetWebResponseProps (hResp_put)
  set response = concat(response,"GetWebResponseProps Put: ", build(hResp_Props_put))
  call echo(response)
  set stat = uar_SRV_GetMemoryBufferSize (hBuf_put, 0)
   ; Reset buffer position to beginning
  set stat = uar_SRV_SetBufferPos (hBuf_put, 0, 0, pos)
   ; Read first 8k
  set stat = uar_SRV_ReadBuffer (hBuf_put, buf, 100, actual)
 
  set response = buf
  ;call echo(response)
  free record camm_mmf
  record camm_mmf (
   1 status = vc
    1 timestamp = dq8
  )
 set camm_mmf->status = response
 set camm_mmf->timestamp = cnvtdatetime(CURDATE,CURTIME)

  call echoxml(camm_mmf,"cammlogservice",1)
  set stat = uar_SRV_CloseHandle (hUri_put)
  set stat = uar_SRV_CloseHandle (hReq_put)
  set stat = uar_SRV_CloseHandle (hProps_put)
  set stat = uar_SRV_CloseHandle (hBuf_put)
  set stat = uar_SRV_CloseHandle (hResp_Props_put)
  set stat = uar_SRV_CloseHandle (hResp_put)
  
  return (response)
END; callPost
 

end go