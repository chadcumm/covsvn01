/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Saravanan
	Date Written:		June 2018
	Solution:			Population Health Quality
	Source file name:  	cov_phq_contsubsta_detail.prg
	Object name:		cov_phq_contsubsta_detail
	Request#:			1189
 
	Program purpose:	      Controlled Substance Audit detail report
	Executing from:		CCL/DA2/Ambulatory Folder
  	Special Notes:          Excel import
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
 
drop program cov_phq_contsubsta_detail:DBA go
create program cov_phq_contsubsta_detail:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Location" = 2553455457.00
	, "Start Admit Date/Time" = "SYSDATE"
	, "End Admit Date/Time" = "SYSDATE" 

with OUTDEV, location, start_datetime, end_datetime
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare initcap()            = c100
declare qty_var              = vc with constant('DISPENSEQTY')
declare refill_var           = vc with constant('NBRREFILLS')
declare duration_var         = vc with constant('DURATION')
declare duration_unit_var    = vc with constant('DURATIONUNIT')
declare stop_var             = vc with constant('STOPDTTM')
declare start_var            = vc with constant('REQSTARTDTTM')
declare prn_var              = vc with constant('PRNREASON')
declare strth_dose_var       = vc with constant('STRENGTHDOSE')
declare strth_dose_unit_var  = vc with constant('STRENGTHDOSEUNIT')
declare rxroute_var          = vc with constant('RXROUTE')
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
Record audit(
	1 reccnt    = i4
	1 plist[*]
		2 location  = vc
		2 provider_id    = f8
		2 provider_name  = vc
		2 provider_dea   = vc
		2 patientid      = f8
		2 encntrid       = f8
		2 pat_name       = vc
		2 pat_dob        = vc
		2 zip            = vc
		2 orders[*]
			3 cur_start_dt   = dq8
			3 proj_stop_dt   = dq8
			3 medication     = vc
			3 orderid        = f8
			3 quantity       = vc
			3 refill         = vc
			3 strnth_dose    = vc
			3 strnth_unit    = vc
			3 strnth_rxroute = vc
			3 start_dt       = dq8
			3 stop_dt        = dq8
			3 duration       = vc
			3 duration_unit  = vc
			3 pain_contract  = vc
	)
 
;Get Patients with active controlled substance
select distinct into "NL:" ;$outdev
 
  e.location_cd
, pr.name_full_formatted
, o.person_id
, o.order_id
, o.hna_order_mnemonic
, current_start_dt = format(o.current_start_dt_tm, "mm/dd/yyyy hh:mm;;d")
, loc = uar_get_code_description(e.location_cd)
, provider = initcap(pr.name_full_formatted)
, pat_name = p.name_full_formatted
, dob = format(p.birth_dt_tm, "mm/dd/yyyy;;d")
, zip = a.zipcode
, dea = pra.alias
 
from
	 encounter e
	, order_action oa
	, orders o
	, mltm_ndc_main_drug_code mn
	, prsnl pr
	, prsnl_alias pra
	, person p
	, address a
 
plan e where e.location_cd = $location
	and e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.active_ind = 1
	
 join o where o.person_id = e.person_id
	and o.encntr_id = e.encntr_id
	and o.active_ind = 1
	and o.activity_type_cd = 705.00 ;Pharmacy
	and o.dcp_clin_cat_cd = 10577 ;Medication
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
 
join p where p.person_id = e.person_id
	and p.active_ind = 1
 
join pra where pra.person_id = outerjoin(pr.person_id)
	and pra.alias_pool_cd = outerjoin(683987.00) ;DEA
 
join a where p.person_id = a.parent_entity_id
	and a.parent_entity_name = "PERSON"
	and a.address_type_cd = 756   ;Home
	and a.active_ind = 1
 
order by e.location_cd, pr.name_full_formatted, o.person_id, o.order_id
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT, maxtime = 120
 
 
;Load into Record Structure
Head report
	cnt = 0
	ocnt = 0
	call alterlist(audit->plist, 10)
 
Head o.person_id
 
	cnt = cnt + 1
	call alterlist(audit->plist, cnt)
 
	audit->reccnt = cnt
	audit->plist[cnt].location = loc
	audit->plist[cnt].provider_id = pr.person_id
	audit->plist[cnt].provider_name = replace(provider, ",", " ",0)
	audit->plist[cnt].provider_dea = dea
	audit->plist[cnt].patientid = o.person_id
	audit->plist[cnt].pat_name = pat_name
	audit->plist[cnt].pat_dob = dob
	audit->plist[cnt].zip = zip
 
	ocnt = 0
 
Detail
 
	ocnt = ocnt + 1
	call alterlist(audit->plist[cnt].orders, ocnt)
 
	audit->plist[cnt].orders[ocnt].cur_start_dt = evaluate(o.current_start_dt_tm, null, oa.order_dt_tm, o.current_start_dt_tm)
	audit->plist[cnt].orders[ocnt].proj_stop_dt = evaluate(o.projected_stop_dt_tm, null, sysdate, o.projected_stop_dt_tm)
	audit->plist[cnt].orders[ocnt].medication = trim(o.hna_order_mnemonic)
	audit->plist[cnt].orders[ocnt].orderid = o.order_id
 
Foot o.person_id
 	call alterlist(audit->plist[cnt].orders, ocnt)
 
Foot report
	call alterlist(audit->plist, cnt)
 
With nocounter
 
 
;Get order details
IF(audit->reccnt > 0)
 
select distinct into "NL:" ;$outdev
 
  odt.oe_field_display_value
, odt.oe_field_dt_tm_value  ;to get date as dq8
, odt.oe_field_meaning
, odt = odt.order_id, rc = audit->plist[d1.seq].orders[d2.seq].orderid
 
, ordext = dense_rank() over (partition by odt.order_id order by odt.action_sequence desc)
 
from
	 (dummyt d1 WITH seq = value(size(audit->plist,5)))
	,(dummyt d2 with seq = 1)
	, orders o
	,(left join order_detail odt on(odt.order_id = o.order_id
		and odt.oe_field_meaning in(qty_var, refill_var, duration_var, duration_unit_var, stop_var, start_var
		,prn_var, strth_dose_var,strth_dose_unit_var, rxroute_var)
	))
 
plan d1 where maxrec(d2, size(audit->plist[d1.seq].orders, 5))
 
join d2
 
join o where o.order_id = audit->plist[d1.seq].orders[d2.seq].orderid
 
join odt
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT, maxtime = 120
 
 
 
Head report
 	cnt = 0
 	ocnt = 0
	idx = 0
 
Head odt.order_id
 
 	idx = locateval(cnt,1,size(audit->plist->orders,5), odt.order_id, audit->plist[d1.seq].orders[d2.seq].orderid)
 
Detail
 
 	case (odt.oe_field_meaning)
 
	of qty_var:
		audit->plist[d1.seq].orders[d2.seq].quantity = odt.oe_field_display_value
	of refill_var:
		audit->plist[d1.seq].orders[d2.seq].refill = odt.oe_field_display_value
	Of strth_dose_var:
		audit->plist[d1.seq].orders[d2.seq].strnth_dose = odt.oe_field_display_value
	Of strth_dose_unit_var:
		audit->plist[d1.seq].orders[d2.seq].strnth_unit = odt.oe_field_display_value
	Of rxroute_var:
		audit->plist[d1.seq].orders[d2.seq].strnth_rxroute = odt.oe_field_display_value
	Of start_var:
		audit->plist[d1.seq].orders[d2.seq].start_dt = odt.oe_field_dt_tm_value
	Of stop_var:
		audit->plist[d1.seq].orders[d2.seq].stop_dt = odt.oe_field_dt_tm_value
	Of duration_var:
		audit->plist[d1.seq].orders[d2.seq].duration = odt.oe_field_display_value
	Of duration_unit_var:
		audit->plist[d1.seq].orders[d2.seq].duration_unit = odt.oe_field_display_value
	Of prn_var:
		audit->plist[d1.seq].orders[d2.seq].pain_contract = odt.oe_field_display_value
	endcase
 
Foot odt.order_id
 
	if(audit->plist[d1.seq].orders[d2.seq].start_dt = null)
		audit->plist[d1.seq].orders[d2.seq].start_dt = audit->plist[d1.seq].orders[d2.seq].cur_start_dt
	endif
 
	if(audit->plist[d1.seq].orders[d2.seq].stop_dt = null)
		audit->plist[d1.seq].orders[d2.seq].stop_dt = audit->plist[d1.seq].orders[d2.seq].proj_stop_dt
	endif
 
	if(audit->plist[d1.seq].orders[d2.seq].duration = '')
		audit->plist[d1.seq].orders[d2.seq].duration =
			cnvtstring(datetimediff(audit->plist[d1.seq].orders[d2.seq].stop_dt, audit->plist[d1.seq].orders[d2.seq].start_dt, 1))
	endif
 
	if(audit->plist[d1.seq].orders[d2.seq].duration_unit = '')
		audit->plist[d1.seq].orders[d2.seq].duration_unit = 'days'
	endif
 
WITH nocounter
 
 
ENDIF
 
call echorecord(audit)
 
 
SELECT DISTINCT INTO value($OUTDEV)
	LOCATION = SUBSTRING(1, 50, AUDIT->plist[D1.SEQ].location)
	, PROVIDER_NAME = SUBSTRING(1, 50, AUDIT->plist[D1.SEQ].provider_name)
	, PATIENT_NAME = SUBSTRING(1, 50, AUDIT->plist[D1.SEQ].pat_name)
	, PATIENT_DOB = SUBSTRING(1, 20, AUDIT->plist[D1.SEQ].pat_dob)
	, ZIP = SUBSTRING(1, 15, AUDIT->plist[D1.SEQ].zip)
	, MEDICATION = SUBSTRING(1, 200, AUDIT->plist[D1.SEQ].orders[D2.SEQ].medication)
	, DEA = SUBSTRING(1, 15, AUDIT->plist[D1.SEQ].provider_dea)
	, QUANTITY = SUBSTRING(1, 10, AUDIT->plist[D1.SEQ].orders[D2.SEQ].quantity)
	, REFILL = SUBSTRING(1, 10, AUDIT->plist[D1.SEQ].orders[D2.SEQ].refill)
	, SIG = BUILD(SUBSTRING(1, 5, AUDIT->plist[D1.SEQ].orders[D2.SEQ].strnth_dose),' '
		, SUBSTRING(1, 5, AUDIT->plist[D1.SEQ].orders[D2.SEQ].strnth_unit))
	, START_DT = FORMAT(AUDIT->plist[D1.SEQ].orders[D2.SEQ].start_dt,"mm/dd/yyyy hh:mm;;d")
	, STOP_DT = FORMAT(AUDIT->plist[D1.SEQ].orders[D2.SEQ].stop_dt,"mm/dd/yyyy hh:mm;;d")
	, DURATION = build(SUBSTRING(1, 5, AUDIT->plist[D1.SEQ].orders[D2.SEQ].duration)
			, SUBSTRING(1, 10, AUDIT->plist[D1.SEQ].orders[D2.SEQ].duration_unit))
	, ORDERS_PAIN_CONTRACT = SUBSTRING(1, 100, AUDIT->plist[D1.SEQ].orders[D2.SEQ].pain_contract)
	;, ORDERS_ORDERID = AUDIT->plist[D1.SEQ].orders[D2.SEQ].orderid

FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(AUDIT->plist, 5)))
	, (DUMMYT   D2  WITH SEQ = 1)

PLAN D1 WHERE MAXREC(D2, SIZE(AUDIT->plist[D1.SEQ].orders, 5))
JOIN D2

ORDER BY
	LOCATION
	, PROVIDER_NAME
	, PATIENT_NAME
	, START_DT

WITH NOCOUNTER, SEPARATOR=" ", FORMAT, SKIPREPORT = 1

END GO
 
 
/**** OLD Not USED ****
SELECT DISTINCT INTO value($OUTDEV)
	LOCATION = SUBSTRING(1, 100, AUDIT->location)
	, PROVIDER_NAME = SUBSTRING(1, 50, AUDIT->plist[D1.SEQ].provider_name)
	, PAT_DOB = SUBSTRING(1, 15, AUDIT->plist[D1.SEQ].pat_dob)
	, ZIP = SUBSTRING(1, 10, AUDIT->plist[D1.SEQ].zip)
	, MEDICATION = SUBSTRING(1, 100, AUDIT->plist[D1.SEQ].medication)
	, DEA = SUBSTRING(1, 10, AUDIT->plist[D1.SEQ].provider_dea)
	, QUANTITY = SUBSTRING(1, 5, AUDIT->plist[D1.SEQ].quantity)
	, REFILL = SUBSTRING(1, 5, AUDIT->plist[D1.SEQ].refill)
	, SIG = BUILD(SUBSTRING(1, 5, AUDIT->plist[D1.SEQ].strnth_dose),' '
		, SUBSTRING(1, 5, AUDIT->plist[D1.SEQ].strnth_unit))
	, START_DT = format(AUDIT->plist[D1.SEQ].start_dt,"mm/dd/yyyy hh:mm;;d")
	, STOP_DT  = format(AUDIT->plist[D1.SEQ].stop_dt,"mm/dd/yyyy hh:mm;;d")
	, DURATION = build(SUBSTRING(1, 5, AUDIT->plist[D1.SEQ].duration), SUBSTRING(1, 10, AUDIT->plist[D1.SEQ].duration_unit))
	, PAIN_CONTRACT = SUBSTRING(1, 100, AUDIT->plist[D1.SEQ].pain_contract)
 
FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(AUDIT->plist, 5)))
 
PLAN D1
 
ORDER BY LOCATION, PROVIDER_NAME, PAT_DOB
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT, SKIPREPORT = 1
*/
 

 
/***** NOT USED ***************
HEAD REPORT
	line_var      = FILLSTRING(100,"=")
	line_thin_var = FILLSTRING(100,"-")
	today_date_var     = FORMAT(CURDATE, "MM/DD/YYYY;;D")
	now_time_var       = FORMAT(CURTIME, "HH:MM:SS;;S")
 
	row 1
	col 20 "Controlled Substance Audit Detail Report"
	row +1
	col 20 "Facility : ", location
	row +1
	col 20 "Report Date/Time :"
	col +1 today_date_var, " ", now_time_var
	;col 20 "Date Range: "
	;col +1 $start_datetime
	;col +2 "To: "
	;col +1 $end_datetime
	row +1
	col  0 line_var
	row +1
 
HEAD PAGE
	col 0  "Provider: ", provider_name
	row +1
	col  0 line_var
 
	row +1
	col 0 "Patient DOB"
	col +1 '|'
	col +1 "Zipcode"
	col +1 '|'
	col +1 "Medication"
	row +1
	col  0 line_var
 
;HEAD provider_name
;	row +1
 
;FOOT provider_name
	;col 0 provider_name
	;col +1 '|'
 
*/
 
 
 
 
 
 
 
 
 
 
 
 
