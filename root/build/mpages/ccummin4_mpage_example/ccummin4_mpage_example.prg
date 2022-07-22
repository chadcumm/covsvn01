drop program ccummin4_mpage_example go
create program ccummin4_mpage_example

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to. 

with OUTDEV

free record 3011001Request
record 3011001Request (
  1 Module_Dir = vc  
  1 Module_Name = vc  
  1 bAsBlob = i2   
) 

free record 3011001Reply
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
  )

free record 3011002Request
record 3011002Request (
  1 source_dir = vc  
  1 source_filename = vc  
  1 nbrlines = i4   
  1 line [*]   
    2 lineData = vc  
  1 OverFlowPage [*]   
    2 ofr_qual [*]   
      3 ofr_line = vc  
  1 IsBlob = c1   
  1 document_size = i4   
  1 document = gvc   
) 

free record 3011002Reply
record 3011002Reply (
   1 info_line [* ]
     2 new_line = vc
   1 status_data
     2 status = c1
     2 subeventstatus [1 ]
       3 operationname = c25
       3 operationstatus = c1
       3 targetobjectname = c25
       3 targetobjectvalue = vc
 )
 
 
declare html_output = vc with noconstant(" ")

set 3011001Request->Module_Dir = "ccluserdir:"
set 3011001Request->Module_Name = "new_window.html"
set 3011001Request->bAsBlob = 1

execute eks_get_source with replace ("REQUEST" ,3011001Request ) , replace ("REPLY" ,3011001Reply )

if (3011001Reply->status_data.status = "S")
	set html_output = 3011001Reply->data_blob
else
	set html_output = "<html><body>Error with getting html source</body></html>"
endif

set html_output = replace(html_output,"_COMMUNICATIONTYPE_","THIS ORDER IS GOOD")

set 3011002Request->source_dir = $OUTDEV
set 3011002Request->IsBlob = "1"
set 3011002Request->document = html_output
set 3011002Request->document_size = size(3011002Request->document)

execute eks_put_source with replace ("REQUEST" ,3011002Request ) , replace ("REPLY" ,3011002Reply )

call echorecord(3011001Reply)

end
go
