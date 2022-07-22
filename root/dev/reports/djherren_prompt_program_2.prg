drop program djherren_prompt_program_2 go
create program djherren_prompt_program_2
 
prompt 
	"Output to File/Printer/MINE" = "MINE" 

with OUTDEV
 
declare MRN_VAR      = f8 with constant(uar_get_code_by("DISPLAY", 319, "MRN")), protect
declare FIN_VAR      = f8 with constant(uar_get_code_by("DISPLAY", 319, "FIN NBR")), protect
declare PHYEXAM_VAR	 = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',72,'PHYSICALEXAMINATIONDOCUMENTATION')), PROTECT
declare COMPCD_VAR	 = f8 WITH CONSTANT(UAR_GET_CODE_BY('DISPLAYKEY',120,'OCFCOMPRESSION')), PROTECT
declare crlf         = vc WITH CONSTANT(CONCAT(CHAR(13), CHAR(10))), PROTECT
declare blobres      = vc
 

;select into value(file_name)
select into $OUTDEV
; 	 pat      = p.name_full_formatted
;  	,fin      = ea1.alias ;SUBSTRING(1, 11, ea1.alias)
;  	,mrn      = SUBSTRING(1, 11, ea2.alias)
;  	,ceblob   = cb.blob_contents
;  	,encntrid = e.encntr_id
;  	,eventid  = ce.event_id
 
from
	 ENCOUNTER e
 
  	,(inner join ENCNTR_ALIAS ea1 on ea1.encntr_id = e.encntr_id
  		and ea1.active_ind = 1
  		and ea1.encntr_alias_type_cd = FIN_VAR
  		and ea1.end_effective_dt_tm >= SYSDATE
  		and ea1.alias = "1815000015")
 
  	,(inner join CLINICAL_EVENT	ce on ce.encntr_id = e.encntr_id
;  		and ce.person_id = p.person_id
  		and ce.event_cd = PHYEXAM_VAR  ;22931585.00 
  		and ce.valid_until_dt_tm > SYSDATE
  		)
 
  	,(left join CE_BLOB cb on cb.event_id = ce.event_id
  		and cb.valid_until_dt_tm >= SYSDATE)
 
where e.active_ind = 1
	and e.end_effective_dt_tm >= SYSDATE

head report
	cnt       = 0
	blobin    = fillstring(32768,' ')
	blobsize  = 0
	blobout   = fillstring(32768,' ')
	bsize     = 0
	blobnortf = fillstring(32768,' ')
	rval      = 0
    
 	COL   0  "Physical Exam"
 	ROW + 1
 	   
detail
	blobin   = cb.blob_contents
	blobsize = size(cb.blob_contents)
 
	if (cb.compression_cd = COMPCD_VAR)
		rval    = UAR_OCF_UNCOMPRESS(blobin,blobsize,blobout,size(blobout), 0)
		rval    = UAR_RTF2(blobout,size(blobout),blobnortf,size(blobnortf),bsize,0)
		blobres = blobnortf
;		blobres = REPLACE(blobres,crlf," ")
	else
 		blobout = blobin
		rval    = UAR_RTF(blobout,size(blobout),blobnortf,size(blobnortf),bsize,0)
		blobres = TRIM(blobnortf)
;		blobres = REPLACE(blobres,crlf," ")
	endif
	
	COL   0 blobres
	ROW + 1

with nocounter, maxcol = 4000, maxrow = 100
end
go
 
 
