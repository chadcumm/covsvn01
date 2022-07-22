drop program ccummin4_test:group1 go
create program ccummin4_test:group1
 
prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "Facility" = ""
	, "Department" = ""
	, "Start Date" = ""
	, "End Date" = "" 

with OUTDEV, facility, department, start_datetime, end_datetime
 
set stat = 0
 
end
go
