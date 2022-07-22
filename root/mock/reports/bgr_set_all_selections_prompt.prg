drop program bgr_set_all_selections_prompt go
create program bgr_set_all_selections_prompt

prompt 
	"Output to File/Printer/MINE " = "MINE"   ;* Enter or select the printer or file name to send this report to.
	;<<hidden>>"All ElectroLytes" = "No"
	, "Choose orders" = 0 

with OUTDEV, Ords_List

SELECT INTO $outdev
	O_CATALOG_DISP = UAR_GET_CODE_DISPLAY(O.CATALOG_CD)
	, O.ORIG_ORDER_DT_TM

FROM
	ORDERS   O

WHERE O.ORIG_ORDER_DT_TM BETWEEN CNVTLOOKBEHIND("1,D") AND CNVTDATETIME(CURDATE, curtime3)
	AND O.CATALOG_CD = $Ords_list

WITH MAXREC = 1000, format, separator = " ",time = 30
end
go

