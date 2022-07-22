/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Saravanan
	Date Written:		June 2018
	Solution:			Population Health Quality
	Source file name:  	cov_phq_contsubsta_cosign.prg
	Object name:		cov_phq_contsubsta_cosign
	Request#:			1190
 
	Program purpose:	      Controlled Substance Supevising providers sign off audit report
	Executing from:		CCL/DA2/Ambulatory Folder
  	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	    Developer			     Comment
--------------  --------------------	------------------------------------------
001 10/01/2018  Dawn Greer, DBA         Changed the location prompt to the practice
                                        prompt and fixed it to pull other values 
                                        than just Clinton Family Physicians.
                                        Removed initcap() function because it was 
                                        causing errors in the code.
******************************************************************************/
 
drop program cov_phq_contsubsta_cosign:DBA go
create program cov_phq_contsubsta_cosign:DBA
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Practice" = 0   ;001 - changed to Practice
	, "Start Admit Date/Time" = "SYSDATE"
	, "End Admit Date/Time" = "SYSDATE" 

with OUTDEV, practice, start_datetime, end_datetime   ;001 - change location to practice
 
;*****************************************************************************************************************
declare fin_var              = f8 with constant(uar_get_code_by("DISPLAY", 319, 'FINNBR')),protect
                                               ;001 - changed to FINNBR from FIN NBR
declare hlth_pln_var         = vc
declare op_practice_var		 = c2 with noconstant("")   ;001 - added op_practice_var
;*****************************************************************************************************************

;001 - Added for the practice prompt
; define operator for $practice
if (substring(1, 1, reflect(parameter(parameter2($practice), 0))) = "L") ; multiple values selected
    set op_practice_var = "IN"
elseif (parameter(parameter2($practice), 1) = 0.0) ; any selected
    set op_practice_var = "!="
else ; single value selected
    set op_practice_var = "="
endif
 
Record cosign(
 	1 prlist[*]
		2 practice      = vc	;001 - changed name to practice instead of location
		2 personid      = f8
		2 encntrid      = f8
		2 pat_name      = vc
		2 fin           = vc
		2 reg_dt        = vc
		2 created_by    = vc
		2 midlevel_id   = f8
		2 midlevel_name = vc
		2 cont_sub_flag = i4
		2 health_plan_string = vc
 		2 orders[*]
 			3 orderid          = f8
 			3 med_name         = vc
 			3 order_dt_tm      = vc
 			3 sign_off_req     = vc
 			3 phys_sign_off    = vc
 			3 contrld_substa   = vc
 			3 signoff_req_dt   = vc
			3 supervising_phys = vc
 			3 medicare         = vc
			3 medicare_phys    = vc
    )
 
Record plist(
	1 reccnt = i4
	1 pat[*]
		2 practice = vc		;001 - changed name to practice instead of location
		2 midlevel_provider = vc
		2 fin = vc
		2 admit_dt_tm = vc
		2 patient_name = vc
		2 Insurance = vc
		2 fin_created_by = vc
		2 sign_off_requested = vc
		2 date_tm_requested = vc
		2 phys_signoff = vc
		2 Controlled_sunstance = vc
		2 supervising_phys = vc
)

;001 - Added for the pratice prompt
/**************************************************************/
; select practice prompt data
select into "NL:"
from
	ORGANIZATION org
where
	org.organization_id = $practice
 
;**************************************************************
 
;Get Orders
select distinct into "NL:" ;$outdev
 
practice_name = i.org_name		;001 - Changed to Org Name aka Practice Name
, midlevel_prsnl = pr.name_full_formatted    ;001 - removed initcap
, pat_nam = i.name_full_formatted			 ;001 - removed initcap
, fin = i.alias
, fin_created_by = pr2.name_full_formatted   ;001 - removed initcap
, regdt = format(i.reg_dt_tm, "mm/dd/yyyy hh:mm;;d")
, o.encntr_id
, o.person_id
, o.order_id
, provider_id = pr.person_id
, med = o.hna_order_mnemonic   ;001 - removed initcap
, order_dt = format(oa.action_dt_tm, "mm/dd/yyyy hh:mm;;d")
;, hlth_plan = hp.plan_name   ;001 - removed initcap in case this ever was uncommented
, Signoff_Requested = if(o.need_doctor_cosign_ind = 1) 'Yes' else 'No' endif
, Physician_Signoff = if(orv.reviewed_status_flag = 1) 'Yes' else 'No' endif
, Controlled_Sub = if(cnvtint(mn.csa_schedule) > 0) 'Yes' else 'No' endif
, Date_Time_Requested = if(o.need_doctor_cosign_ind = 1) format(oa.action_dt_tm, "mm/dd/yyyy hh:mm;;d") else ' ' endif
, Supervising_phy = pr1.name_full_formatted    ;001 - removed initcap
 
from
;Inline
(  (select o.org_name, ea.alias, e.encntr_id, e.person_id, p.name_full_formatted, e.reg_prsnl_id, e.reg_dt_tm
		;001 - change the first column from e.location_cd to o.org_name for Practice name
	from encounter e, person p, encntr_alias ea, organization o   ;001 - Added organization table
	where e.encntr_id = ea.encntr_id
	and p.person_id = e.person_id
	and e.organization_id = o.organization_id		;001 - linking the ogranization table to the encounter table
	AND e.organization_id = $practice				;001 - practice prompt
	and e.reg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and e.active_ind = 1
	and p.active_ind = 1
	and ea.encntr_alias_type_cd = 1077.00 ; fin_var   ;001 - FIN_VAR was causing an error changed it to the code
	and ea.active_ind = 1
      with sqltype("vc", "vc", "f8", "f8", "vc", "f8", "dq8")   ;001 - Change the first type from "F8" to "vc"
   )i
)
, orders o
, order_action oa
, mltm_ndc_main_drug_code mn
, order_review orv
, prsnl pr
, prsnl pr1
, prsnl pr2
 
plan i
 
join o where o.person_id = i.person_id
	and o.encntr_id = i.encntr_id
	and o.active_ind = 1
	and o.activity_type_cd = 705.00 ;Pharmacy
	and o.dcp_clin_cat_cd = 10577 ;Medication
	and o.template_order_id = 0.00
	and o.orig_ord_as_flag not in(2,3) ;exclude home, patient own meds
 
join oa where oa.order_id = o.order_id
	and oa.action_type_cd = 2534.00 ;Order
	and oa.action_sequence = o.last_action_sequence
 
join mn where mn.drug_identifier = outerjoin(substring(9,6,o.cki))
	and cnvtint(mn.csa_schedule) > outerjoin(0) ;controlled substance
 
join orv where orv.order_id = outerjoin(o.order_id)
	and orv.action_sequence = outerjoin(o.last_action_sequence)
	and orv.proxy_reason_cd = outerjoin(10496.00) ;Document to Sign
	and orv.reviewed_status_flag = outerjoin(1) ;accepted
 
join pr where pr.person_id = oa.order_provider_id
	and pr.physician_ind = 1
	and pr.position_cd in(637903.00, 644372.00, 4044213.00, 215456819.00) ;Nurse Practitioner, Physician Assistant, Crna
	and pr.beg_effective_dt_tm <= sysdate
	and pr.end_effective_dt_tm > sysdate
	and pr.active_ind = 1
 
join pr1 where pr1.person_id = outerjoin(oa.supervising_provider_id)
	and pr1.active_ind = outerjoin(1)
 
join pr2 where pr2.person_id = outerjoin(i.reg_prsnl_id)
	and pr2.active_ind = outerjoin(1)
 
order by pr.name_full_formatted, o.person_id, o.encntr_id, o.order_id
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT, maxtime = 120
 
;Load into Record Structure
Head report
	cnt = 0
	call alterlist(cosign->prlist, 100)
 
Head pr.name_full_formatted
	ordcnt = 0
 
Head o.encntr_id
	ocnt = 0
	pcnt = 0
	tmp = 0
	cnt = cnt + 1
	call alterlist(cosign->prlist, cnt)
 
	cosign->prlist[cnt].practice      = practice_name ;001 - changed to the practice name
	cosign->prlist[cnt].personid      = o.person_id
	cosign->prlist[cnt].encntrid      = o.encntr_id
	cosign->prlist[cnt].pat_name      = pat_nam
	cosign->prlist[cnt].reg_dt        = regdt
	cosign->prlist[cnt].fin           = fin
	cosign->prlist[cnt].created_by    = fin_created_by
	cosign->prlist[cnt].midlevel_id   = pr.person_id
	cosign->prlist[cnt].midlevel_name = midlevel_prsnl
	if (Controlled_Sub = 'Yes')
		cosign->prlist[cnt].cont_sub_flag = 1
	endif
 	hlth_pln_var = fillstring(100," ")
 
Detail
	ocnt = ocnt + 1
	call alterlist(cosign->prlist[cnt].orders, ocnt)
	cosign->prlist[cnt].orders[ocnt].orderid = o.order_id
	cosign->prlist[cnt].orders[ocnt].med_name = med
	cosign->prlist[cnt].orders[ocnt].order_dt_tm = order_dt
	cosign->prlist[cnt].orders[ocnt].sign_off_req = Signoff_Requested
	cosign->prlist[cnt].orders[ocnt].phys_sign_off = Physician_Signoff
	cosign->prlist[cnt].orders[ocnt].contrld_substa = Controlled_Sub
	cosign->prlist[cnt].orders[ocnt].signoff_req_dt = Date_Time_Requested
	cosign->prlist[cnt].orders[ocnt].supervising_phys = Supervising_phy
	cosign->prlist[cnt].orders[ocnt].medicare = ''
	cosign->prlist[cnt].orders[ocnt].medicare_phys = ''
 
Foot o.encntr_id
 	call alterlist(cosign->prlist[cnt].orders, ocnt)
 
Foot report
	call alterlist(cosign->prlist, cnt)
 
with nocounter
 

;Get Health plan
select distinct into "NL:" ;$outdev

ep.encntr_id, hp.health_plan_id, hp.plan_name

from 
	(dummyt d with seq = value(size(cosign->prlist, 5)))
	,encntr_plan_reltn ep
	,health_plan hp

plan d

join ep where ep.encntr_id = cosign->prlist[d.seq].encntrid
	and ep.active_ind = 1
	and ep.data_status_cd = 25
	and ep.active_status_cd = 188
	and ep.beg_effective_dt_tm <= sysdate
	and ep.end_effective_dt_tm > sysdate

join hp where hp.health_plan_id = ep.health_plan_id
	and hp.active_ind = 1
	and hp.beg_effective_dt_tm <= sysdate
	and hp.end_effective_dt_tm > sysdate

order by ep.encntr_id, hp.health_plan_id, hp.plan_name

;WITH NOCOUNTER, SEPARATOR=" ", FORMAT

Head report
	cnt = 0
	idx = 0
 
Head ep.encntr_id
	
 	idx = locateval(cnt,1,size(cosign->prlist,5),ep.encntr_id, cosign->prlist[cnt].encntrid)
	plan_string = fillstring(300," ")
 
Detail
	plan_string = build(plan_string, trim(hp.plan_name), ',')

Foot ep.encntr_id
	cosign->prlist[idx].health_plan_string = build2(replace(trim(plan_string),",","",2))

With nocounter

call echorecord(cosign)
 
;----------------------------------------------------------------------------------------------------
 
; Get from record structure and load into another record structure to have a consolidated data
; controled substance with 'Yes'
SELECT DISTINCT INTO 'NL:' ;VALUE($OUTDEV)
	PRAC = SUBSTRING(1, 50, COSIGN->prlist[D1.SEQ].practice)		;001 - changed name to prac from loc 
			;001 - and changed record field name to practice instead of location
	, MID_PROVIDER = SUBSTRING(1, 50, COSIGN->prlist[D1.SEQ].midlevel_name)
	, FIN = SUBSTRING(1, 20, COSIGN->prlist[D1.SEQ].fin)
	, FIN_DT_TM = SUBSTRING(1, 15, COSIGN->prlist[D1.SEQ].reg_dt)
	, CREATED_BY = SUBSTRING(1, 50, COSIGN->prlist[D1.SEQ].created_by)
	, PAT_NAME = SUBSTRING(1, 100, COSIGN->prlist[D1.SEQ].pat_name)
	, HLTH_PLAN = SUBSTRING(1, 200, COSIGN->prlist[D1.SEQ].health_plan_string)
	, SIGNOFF_REQ = SUBSTRING(1, 30, COSIGN->prlist[D1.SEQ].orders[D2.SEQ].sign_off_req)
	, PHYS_SIGNOFF = SUBSTRING(1, 30, COSIGN->prlist[D1.SEQ].orders[D2.SEQ].phys_sign_off)
	, CONT_SUB = SUBSTRING(1, 30, COSIGN->prlist[D1.SEQ].orders[D2.SEQ].contrld_substa)
	, REQ_DT_TM = SUBSTRING(1, 30, COSIGN->prlist[D1.SEQ].orders[D2.SEQ].signoff_req_dt)
	, SUPER_PHYS = SUBSTRING(1, 50, COSIGN->prlist[D1.SEQ].orders[D2.SEQ].supervising_phys)
 
FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(COSIGN->prlist, 5)))
	, (DUMMYT   D2  WITH SEQ = 1)
	;, (DUMMYT   D3  WITH SEQ = 1)
 
PLAN D1 WHERE MAXREC(D2, SIZE(COSIGN->prlist[D1.SEQ].orders, 5))
	;AND MAXREC(D3, SIZE(COSIGN->prlist[D1.SEQ].hplan, 5))
 
JOIN D2 where cosign->prlist[d1.seq].cont_sub_flag = 1
	and COSIGN->prlist[D1.SEQ].orders[D2.SEQ].contrld_substa = 'Yes'
 
;JOIN D3
 
ORDER BY
	PRAC   ;001 - Changed from LOC to PRAC
	, MID_PROVIDER
	, FIN
 
Head report
	cnt = 0
	call alterlist(plist->pat, 100)
 
Head fin
	cnt = cnt + 1
	plist->reccnt = cnt
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(plist->pat, cnt+9)
	endif
 
	plist->pat[cnt].practice = PRAC   ;001 - changed name to prac from loc 
				;001 - and changed record field name to practice instead of location
	plist->pat[cnt].midlevel_provider = mid_provider
	plist->pat[cnt].fin = fin
	plist->pat[cnt].admit_dt_tm = fin_dt_tm
	plist->pat[cnt].patient_name = pat_name
	plist->pat[cnt].Insurance = hlth_plan
	plist->pat[cnt].fin_created_by = created_by
	plist->pat[cnt].sign_off_requested = signoff_req
	plist->pat[cnt].date_tm_requested = req_dt_tm
	plist->pat[cnt].phys_signoff = phys_signoff
	plist->pat[cnt].Controlled_sunstance = cont_sub
	plist->pat[cnt].supervising_phys = super_phys
 
Foot report
	call alterlist(plist->pat, cnt)
 
WITH nocounter

 
; controled substance with 'No'
SELECT DISTINCT INTO 'NL:';VALUE($OUTDEV)
 
     PRAC = SUBSTRING(1, 50, COSIGN->prlist[D1.SEQ].practice);001 - changed name to prac from loc 
				;001 - and changed record field name to practice instead of location
	, MID_PROVIDER = SUBSTRING(1, 50, COSIGN->prlist[D1.SEQ].midlevel_name)
	, FIN = SUBSTRING(1, 20, COSIGN->prlist[D1.SEQ].fin)
	, FIN_DT_TM = SUBSTRING(1, 15, COSIGN->prlist[D1.SEQ].reg_dt)
	, CREATED_BY = SUBSTRING(1, 50, COSIGN->prlist[D1.SEQ].created_by)
	, PAT_NAME = SUBSTRING(1, 100, COSIGN->prlist[D1.SEQ].pat_name)
	, HLTH_PLAN = SUBSTRING(1, 200, COSIGN->prlist[D1.SEQ].health_plan_string)
	, SIGNOFF_REQ = SUBSTRING(1, 30, COSIGN->prlist[D1.SEQ].orders[D2.SEQ].sign_off_req)
	, PHYS_SIGNOFF = SUBSTRING(1, 30, COSIGN->prlist[D1.SEQ].orders[D2.SEQ].phys_sign_off)
	, CONT_SUB = SUBSTRING(1, 30, COSIGN->prlist[D1.SEQ].orders[D2.SEQ].contrld_substa)
	, REQ_DT_TM = SUBSTRING(1, 30, COSIGN->prlist[D1.SEQ].orders[D2.SEQ].signoff_req_dt)
	, SUPER_PHYS = SUBSTRING(1, 50, COSIGN->prlist[D1.SEQ].orders[D2.SEQ].supervising_phys)
 
FROM
	  (DUMMYT   D1  WITH SEQ = VALUE(SIZE(COSIGN->prlist, 5)))
	, (DUMMYT   D2  WITH SEQ = 1)
	;, (DUMMYT   D3  WITH SEQ = 1)
	, (DUMMYT   D4  WITH SEQ = VALUE(SIZE(plist->pat, 5)))
 
PLAN D1 WHERE MAXREC(D2, SIZE(COSIGN->prlist[D1.SEQ].orders, 5))
	;AND MAXREC(D3, SIZE(COSIGN->prlist[D1.SEQ].hplan, 5))
 
JOIN D2 where cosign->prlist[d1.seq].cont_sub_flag != 1
	and COSIGN->prlist[D1.SEQ].orders[D2.SEQ].contrld_substa = 'No'
 
;JOIN D3
 
join d4 where plist->pat[d4.seq].fin != cosign->prlist[d1.seq].fin
 
ORDER BY PRAC, MID_PROVIDER, FIN
 
;WITH NOCOUNTER, SEPARATOR=" ", FORMAT
 
 
;Load/append into Record structure
Head report
	cnt = plist->reccnt
	call alterlist(plist->pat, 100)
 
Head fin
	cnt = cnt + 1
	if(mod(cnt, 10) = 1 and cnt > 100)
		call alterlist(plist->pat, cnt+9)
	endif
 
	plist->pat[cnt].practice = PRAC ;001 - changed name to prac from loc 
				;001 - and changed record field name to practice instead of location
	plist->pat[cnt].midlevel_provider = mid_provider
	plist->pat[cnt].fin = fin
	plist->pat[cnt].admit_dt_tm = fin_dt_tm
	plist->pat[cnt].patient_name = pat_name
	plist->pat[cnt].Insurance = hlth_plan
	plist->pat[cnt].fin_created_by = created_by
	plist->pat[cnt].sign_off_requested = signoff_req
	plist->pat[cnt].date_tm_requested = req_dt_tm
	plist->pat[cnt].phys_signoff = phys_signoff
	plist->pat[cnt].Controlled_sunstance = cont_sub
	plist->pat[cnt].supervising_phys = super_phys
 
Foot report
	call alterlist(plist->pat, cnt)
 
with nocounter
 
call echorecord(plist)
 
;Final Select, excel import
 
SELECT DISTINCT INTO VALUE($OUTDEV)
 
	PRAC = SUBSTRING(1, 50, PLIST->pat[D1.SEQ].practice)  ;001 - changed name to prac from loc 
				;001 - and changed record field name to practice instead of location
	, MIDLEVEL_PROVIDER = SUBSTRING(1, 50, PLIST->pat[D1.SEQ].midlevel_provider)
	, FIN = SUBSTRING(1, 20, PLIST->pat[D1.SEQ].fin)
	, ADMIT_DT_TM = SUBSTRING(1, 20, PLIST->pat[D1.SEQ].admit_dt_tm)
	, PATIENT_NAME = SUBSTRING(1, 50, PLIST->pat[D1.SEQ].patient_name)
	, INSURANCE = SUBSTRING(1, 200, PLIST->pat[D1.SEQ].Insurance)
	, FIN_CREATED_BY = SUBSTRING(1, 50, PLIST->pat[D1.SEQ].fin_created_by)
	, CONTROLLED_SUNSTANCE = SUBSTRING(1, 10, PLIST->pat[D1.SEQ].Controlled_sunstance)
	, SIGN_OFF_REQUESTED = SUBSTRING(1, 10, PLIST->pat[D1.SEQ].sign_off_requested)
	, DATE_TM_REQUESTED = SUBSTRING(1, 20, PLIST->pat[D1.SEQ].date_tm_requested)
	, PHYSICIAN_SIGNOFF = SUBSTRING(1, 10, PLIST->pat[D1.SEQ].phys_signoff)
	, SUPERVISING_PHYSICIAN = SUBSTRING(1, 50, PLIST->pat[D1.SEQ].supervising_phys)
 
FROM
	(DUMMYT   D1  WITH SEQ = VALUE(SIZE(PLIST->pat, 5)))
 
PLAN D1
 
ORDER BY
	PRAC	;001 - change name to prac from loc
	, MIDLEVEL_PROVIDER
	, ADMIT_DT_TM
	, PATIENT_NAME
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT, SKIPREPORT = 1
 
end go
 
 
 
