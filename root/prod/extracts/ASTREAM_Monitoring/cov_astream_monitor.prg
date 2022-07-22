/***********************PROGRAM NOTES*************************
        Source file name:       cov_astream_monitor.PRG
        Object name:            cov_astream_monitor
        Request #:              10005
 
        Product:                ASTREAM Monitor
        Product Team:
 
        Program purpose:        Create a file and have it transfer to ASTREAM to
                                track issues with ASTREAM
 
 
        Executing from:         Operations Job
        Control Group: 	        Reporting_FTP
        Job Name:               COV ASTREAM Monitoring
        Job Schedule:           Daily every 10 min from 00:00 - 23:59
 
        Special Notes:
 
*****************************************************************************/
/***********************Change Log*******************************************
VERSION DATE        ENGINEER            COMMENT
-------	---------   ----------------    -------------------------------------
001		04/07/2021	Dawn Greer, DBA		Created
 
*****************************************************************************/
drop program cov_astream_monitor:dba go
create program cov_astream_monitor:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"
with OUTDEV
 
record output (
	1 rec_cnt = i4
	1 temp = vc
	1 locator = vc
	1 filename = vc
	1 directory = vc
	1 file_message = vc
)
 
DECLARE Message = vc
DECLARE output_rec = vc with noconstant("")
DECLARE output_var = vc with noconstant("")
DECLARE temppath_var = vc WITH noconstant("/cerner/d_p0665/temp")	;Temp Save location $cer_temp
 
SET output->directory = "/cerner/w_custom/p0665_cust/to_client_site/Extracts/aStreamMonitoring/"	;Astream Dir
SET output->filename   = CONCAT("astreamjobs",FORMAT(CURDATE, "MM-DD-YYYY;;d_"),"_",FORMAT(CURTIME, "hhmm;;m"),".txt")	;filename
 
;Message for the file.
SET Message = CONCAT("This is a test file to test ASTREAM transfers.",CHAR(13),CHAR(10))
SET	Message = CONCAT(Message, "Now is the time for all good men to come to the aid of their country.", CHAR(13), CHAR(10))
SET	Message = CONCAT(Message, "She sells seashells by the sea shore.",CHAR(13),CHAR(10))
SET Message = CONCAT(Message, "The quick brown fox jumps over the lazy dog.", CHAR(13),CHAR(10))
SET	Message = CONCAT(Message, "Now is the time for all good women to come to the aid of their country")
 
SET output->file_message = Message
SET output->rec_cnt = 1
 
SET output_var = BUILD(temppath_var, output->filename)
 
;Output Data to file
SELECT INTO VALUE(output_var)
FROM (DUMMYT dt with seq = output->rec_cnt)
 
DETAIL
	output_rec = output->file_message
	col 0 output_rec
	row + 1
WITH nocounter, maxcol = 32000, format=stream, formfeed = none
 
;Move file to Astream
SET  statx = 0
SET  output->temp = CONCAT("mv ",temppath_var, output->filename," ",output->directory,output->filename)
CALL dcl( output->temp ,size(output->temp  ), statx)
 
#exitscript
END
GO