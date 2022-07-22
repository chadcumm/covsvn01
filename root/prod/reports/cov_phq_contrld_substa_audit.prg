/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Saravanan
	Date Written:		June 2018
	Solution:			Population Health Quality
	Source file name:  	cov_phq_contrld_substa_audit.prg
	Object name:		cov_phq_contrld_substa_audit
	Request#:			1190
 
	Program purpose:	      Controlled Substance Audit report
	Executing from:		CCL/DA2/Ambulatory folder
  	Special Notes: 
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_phq_contrld_substa_audit:DBA go
create program cov_phq_contrld_substa_audit:DBA
 
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Location" = 2553455457.00
	, "Start Reg Date/Time" = "SYSDATE"
	, "End Reg Date/Time" = "SYSDATE" 

with OUTDEV, location, start_datetime, end_datetime
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare initcap() = c100
declare diff = f8 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
Record audit(
	1 reccnt    = i4
	1 location  = vc
	1 plist[*]
		2 provider_id    = f8
		2 provider_name  = vc
		2 patid          = f8
		2 order_dt       = vc
		2 diff           = f8
		2 patid_90days   = i4
	)
 
;Get Patients with active controlled substance
select into "NL:";$outdev
 
e.location_cd, pr.name_full_formatted, o.person_id

, loc = uar_get_code_description(e.location_cd)
, o.encntr_id, e.reg_dt_tm
, order_dt = format(oa.order_dt_tm, "mm/dd/yyyy hh:mm:ss;;d")
;, diff_days = datetimediff(sysdate, oa.order_dt_tm,1)
, o.hna_order_mnemonic
, position = uar_get_code_display(pr.position_cd)


from
	 encounter e
	, order_action oa
	, orders o
	, mltm_ndc_main_drug_code mn
	, prsnl pr
 
plan e where e.location_cd = $location
	and e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.active_ind = 1
 
join o where o.person_id = e.person_id
	and o.encntr_id = e.encntr_id
	and o.active_ind = 1
	and o.activity_type_cd = 705.00 ;Pharmacy
	and o.template_order_id = 0.00
	and o.orig_ord_as_flag not in(2,3) ;exclude home, patient own meds
 
join oa where oa.order_id = o.order_id
	and oa.action_type_cd = 2534.00 ;Order
	and oa.action_sequence = o.last_action_sequence
 
join mn where mn.drug_identifier = substring(9,6,o.cki)
	and cnvtint(mn.csa_schedule) > 0 ;controlled substance
 
join pr where pr.person_id = oa.order_provider_id
	and pr.physician_ind = 1
	and pr.beg_effective_dt_tm <= sysdate
	and pr.end_effective_dt_tm > sysdate
	and pr.active_ind = 1
 
order by e.location_cd, pr.name_full_formatted, o.person_id
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT, maxtime = 120
 
 
Head report
	cnt = 0
	call alterlist(audit->plist, 10)
 
Head o.person_id
	cnt = cnt + 1
	audit->reccnt = cnt
	audit->location = uar_get_code_display(e.location_cd)
	call alterlist(audit->plist, cnt)
 
Detail
	diff = datetimediff(sysdate, oa.order_dt_tm,1)
	audit->plist[cnt].provider_id = pr.person_id
	audit->plist[cnt].provider_name = pr.name_full_formatted 
	audit->plist[cnt].patid = o.person_id
	audit->plist[cnt].order_dt = format(oa.order_dt_tm, "mm/dd/yyyy hh:mm:ss;;d") 
	audit->plist[cnt].diff = diff
	if(diff >= 90)
		audit->plist[cnt].patid_90days = 1
	else
		audit->plist[cnt].patid_90days = 0
	endif
 
Foot report
	call alterlist(audit->plist, cnt)
 
With nocounter
 
call echorecord(audit)

end go

 
/***** NOT USED *********************
;Get data from the record structure - excel import
SELECT into value($outdev)
	  location      =  audit->location
	, provider_name = AUDIT->plist[D1.SEQ].provider_name
	, patient_id    = AUDIT->plist[D1.SEQ].patid
	, pat90days     = audit->plist[d1.seq].patid_90days
	, diff          = audit->plist[d1.seq].diff
FROM
	(DUMMYT D1 WITH SEQ = VALUE(SIZE(AUDIT->plist, 5)))
 
PLAN D1
 
ORDER BY location, provider_name
 
HEAD REPORT
	line_var      = FILLSTRING(100,"=")
	line_thin_var = FILLSTRING(100,"-")
	today_var     = FORMAT(CURDATE, "MM/DD/YYYY;;D")
	now_var       = FORMAT(CURTIME, "HH:MM:SS;;S")
 
	row 1
	col 20 "Controlled Substance Audit Report"
	row +1
	col 20 "Facility : ", location
	row +1
	col 20 "Report Date/Time :"
	col +1 today_var, " ", now_var
	;col 20 "Date Range: "
	;col +1 $start_datetime
	;col +2 "To: "
	;col +1 $end_datetime
	row +1
	col  0 line_var
	row +1
 
HEAD PAGE
	col 0  "Provider Name"
	col +1 '|'
	col +1 "Total Patients"
	col +1 '|'
	col +1 "Over 90 days"
	col +1 '|'
	col +1 "Percentage"
	row +1
	col  0 line_var
 
HEAD provider_name
	row +1
 
FOOT provider_name
	col 0 provider_name
	col +1 '|'
	col +3 count(patient_id) ;total patients
	col +1 '|'
	col +3 sum(pat90days)  ;patients over 90 days
	col +1 '|'
	col +1 (sum(pat90days) / count(patient_id))* 100.0 "####.##%"
 
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT
*/
 

 
 
 
