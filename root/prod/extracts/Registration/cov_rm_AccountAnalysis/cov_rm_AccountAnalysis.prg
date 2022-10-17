/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 
	Author:				Todd A. Blanchard
	Date Written:		04/11/2019
	Solution:			Revenue Cycle - Registration Management
	Source file name:	cov_rm_AccountAnalysis.prg
	Object name:		cov_rm_AccountAnalysis
	Request #:			4788
 
	Program purpose:	Select data for encounter alias analysis.
 
	Executing from:		CCL
 
 	Special Notes:		Output files:
 							account_analysis.csv
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
 	Mod Date	Developer				Comment
 	----------	--------------------	--------------------------------------
 
******************************************************************************/
 
drop program cov_rm_AccountAnalysis:DBA go
create program cov_rm_AccountAnalysis:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date" = "CURDATE"
 
with OUTDEV, start_datetime
 
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
 
declare fin_var				= f8 with constant(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
declare alias_pool_var		= f8 with constant(uar_get_code_by("DISPLAYKEY", 263, "STARFIN"))
 
declare file_var			= vc with constant(build("account_analysis", ".csv"))
 
declare temppath_var		= vc with constant(build("cer_temp:", file_var))
declare temppath2_var		= vc with constant(build("$cer_temp/", file_var))
 
declare filepath_var		= vc with constant(build("/cerner/w_custom/", cnvtlower(curdomain),
								"_cust/to_client_site/RevenueCycle/Registration/",
								file_var))
 
declare start_year			= vc with constant(format(cnvtdatetime($start_datetime), "yy;;d"))
declare start_julian		= vc with constant(format(julian(cnvtdatetime($start_datetime)), "###;p0;i"))
declare julian_date			= vc with constant(build(start_year, start_julian))
 
declare cmd					= vc with noconstant("")
declare len					= i4 with noconstant(0)
declare stat				= i4 with noconstant(0)
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
/**************************************************************/
; select daily data
;set modify filestream
 
;select into value(temppath_var)
select into $OUTDEV
	ea2.julian_dt_tm
	, ea2.fin_max 
 
	, est_arrive_dt_tm = format(e.est_arrive_dt_tm, "mm/dd/yyyy;;d")
	, reg_dt_tm = format(e.reg_dt_tm, "mm/dd/yyyy;;d")
 
	, total_enc = ea2.total_fin
 
from
	ENCNTR_ALIAS ea
 
	, (inner join ENCOUNTER e on e.encntr_id = ea.encntr_id
		and e.active_ind = 1)
		
	, ((select 
			julian_dt_tm = substring(1, 5, ea.alias)
			, fin_max = max(ea.alias)
			, total_fin = count(*)		
			
		from ENCNTR_ALIAS ea
		where
			ea.encntr_alias_type_cd = fin_var 
			and ea.alias_pool_cd = alias_pool_var
			and isnumeric(ea.alias) = 1
			and substring(1, 5, ea.alias) >= julian_date
			and ea.end_effective_dt_tm > sysdate
			and ea.active_ind = 1
		group by
			substring(1, 5, ea.alias)
		with sqltype("vc", "vc", "i4")
		) ea2)
 
where
	ea.alias = ea2.fin_max
	and ea.encntr_alias_type_cd = fin_var
	and ea.alias_pool_cd = alias_pool_var
	and ea.end_effective_dt_tm > sysdate
	and ea.active_ind = 1
 
order by
	ea2.julian_dt_tm
 
;with nocounter, pcformat (^"^, ^,^, 1), format = stream, format
with nocounter, separator = " ", format, time = 120 ;, maxrec = 100
 
 
;; copy daily file to AStream
;set cmd = build2("cp ", temppath2_var, " ", filepath_var)
;set len = size(trim(cmd))
;
;call dcl(cmd, len, stat)
;call echo(build2(cmd, " : ", stat))
 
 
/**************************************************************
; DVDev DEFINED SUBROUTINES
**************************************************************/
 
end
go
 
