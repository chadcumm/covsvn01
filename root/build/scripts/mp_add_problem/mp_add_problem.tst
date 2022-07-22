declare OUTDEV = vc with protect, constant(^MINE^) go 
declare PERSONID = f8 with protect, constant(16799260) go
declare PERSONNELID = f8 with protect, constant(   16908168.00) go
declare ENCNTRID = f8 with protect, constant(110765501) go
declare POSCD = f8 with protect, constant(441.0) go
declare PPRCD = f8 with protect, constant(1119.0) go
declare ORIGNOMENID = f8 with protect, constant(13246904.0) go
declare LIFECYCLESTATUSFLAG = i2 with protect, constant(1) go
declare BRCONFIGIND = i2 with protect, constant(1) go
;declare ADDTYPECD = f8 with protect, constant(3305.0) go
declare CLASSCD = f8 with protect, constant(     674232.0) go
declare SUCCESS_STATUS = vc with protect, constant(^"STATUS":"S"^) go
declare PROBNOMENID = f8 with protect, noconstant(0.0 )go 
declare PROBID = f8 with protect, noconstant(0.0) go 

declare _Memory_Reply_String = vc with protect, noconstant("") go

select * from code_value cv where cv.code_value = 3305 go

execute mp_add_problem OUTDEV, PERSONID, ENCNTRID, PERSONNELID, POSCD, PPRCD, PROBNOMENID, ORIGNOMENID, LIFECYCLESTATUSFLAG,
 	 BRCONFIGIND, ADDTYPECD, CLASSCD go

call echo( _Memory_Reply_String) go
