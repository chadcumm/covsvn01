/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			    Steve Czubek
	Date Written:		October 2022
	Solution:
	Source file name:  	cov_bb_trans_ord_phy.prg
	Object name:		cov_bb_trans_ord_phy
	Request#:
 
	Program purpose:	Transfusion report showing the physician entered in the dispense dialog
	Executing from:		CCL
  	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	--------------------	------------------------------------------
10/12/22    Steve Czubek      		CR 12900 initial release
10/13/22    Steve Czubek          added person_id to the patient dispense join
******************************************************************************/
drop program cov_bb_trans_ord_phy:dba go
create program cov_bb_trans_ord_phy:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Transfusion Begin Date" = "CURDATE"
	, "Transfusion End Date" = "CURDATE"
	, "Facility" = 0
	, "Sort by" = ""
 
with OUTDEV, beg_dt, end_dt, facility, sort_by
 
 
 
free record rpt_data
record rpt_data
(
    1 qual[*]
        2 Patient_Name = vc
        2 FIN = vc
        2 Product_Number = vc
        2 Product_Type = vc
        2 Transfused_Date_Time = vc
        2 Ordering_Provider = vc
)
 
%i cust_script:SC_CPS_GET_PROMPT_LIST.inc
declare fac_parser = vc with protect, noconstant("1=1")
set fac_parser = GetPromptList(parameter2($facility), "e.loc_facility_cd")
 
 
declare TRANSFUSECCPFRESHFROZENPLASMA = f8 with protect,
        constant(uar_get_code_by("DISPLAYKEY", 200, "TRANSFUSECCPFRESHFROZENPLASMA"))
declare TRANSFUSECRYOPRECIPITATEBLOODPRODUCT = f8 with protect,
        constant(uar_get_code_by("DISPLAYKEY", 200, "TRANSFUSECRYOPRECIPITATEBLOODPRODUCT"))
declare TRANSFUSECRYOPRECIPITATEPRODUCT = f8 with protect,
        constant(uar_get_code_by("DISPLAYKEY", 200, "TRANSFUSECRYOPRECIPITATEPRODUCT"))
declare TRANSFUSEFRESHFROZENPLASMA = f8 with protect,
        constant(uar_get_code_by("DISPLAYKEY", 200, "TRANSFUSEFRESHFROZENPLASMA"))
declare TRANSFUSEFRESHFROZENPLASMAPRODUCTPE = f8 with protect,
        constant(uar_get_code_by("DISPLAYKEY", 200, "TRANSFUSEFRESHFROZENPLASMAPRODUCTPE"))
declare TRANSFUSEPLATELETBLOODPRODUCTPEDIATR = f8 with protect,
        constant(uar_get_code_by("DISPLAYKEY", 200, "TRANSFUSEPLATELETBLOODPRODUCTPEDIATR"))
declare TRANSFUSEPLATELETPRODUCT = f8 with protect,
        constant(uar_get_code_by("DISPLAYKEY", 200, "TRANSFUSEPLATELETPRODUCT"))
declare TRANSFUSEREDBLOODCELLS = f8 with protect,
        constant(uar_get_code_by("DISPLAYKEY", 200, "TRANSFUSEREDBLOODCELLS"))
declare TRANSFUSEREDBLOODCELLSPEDIATRIC = f8 with protect,
        constant(uar_get_code_by("DISPLAYKEY", 200, "TRANSFUSEREDBLOODCELLSPEDIATRIC"))
declare cnt = i4 with protect, noconstant(0)
 
if ($sort_by in ("Patient Name", "Ordering Provider"))
select into "nl:"
    pe.product_id
    ,trans_date = format(pe.event_dt_tm, ";;q")
    ,sort_var = if ($sort_by = "Patient Name")
    				p.name_full_formatted
    			elseif ($sort_by = "Ordering Provider")
    				ps.name_full_formatted
    			else
    				p.name_full_formatted
    			endif
from
    product_event pe
    ,encounter e
    ,product pr
    ,patient_dispense pd
    ,prsnl ps
    ,person p
    ,encntr_alias ea
plan pe
    where pe.event_dt_tm between cnvtdatetime(concat($beg_dt, " 00:00"))
    and cnvtdatetime(concat($end_dt, " 23:59:59"))
    and pe.event_type_cd = value(uar_get_code_by("DISPLAYKEY", 1610, "TRANSFUSED"))
join e
	where e.encntr_id = pe.encntr_id
	and parser(fac_parser)
join pr
	where pr.product_id = pe.product_id
join pd
	where pd.product_id = pe.product_id
join ps
	where ps.person_id = pd.dispense_prov_id
join p
	where p.person_id = pe.person_id
join ea
	where ea.encntr_id = pe.encntr_id
	and ea.active_ind = 1
	and ea.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
	and ea.encntr_alias_type_cd = value(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
order
	sort_var
	,pe.product_event_id
head report
	cnt = 0
 
head pe.product_event_id
	if (mod(cnt, 10) = 0)
		stat = alterlist(rpt_data->qual, cnt + 10)
	endif
	cnt = cnt + 1
	rpt_data->qual[cnt].Patient_Name = p.name_full_formatted
	rpt_data->qual[cnt].FIN = ea.alias
	rpt_data->qual[cnt].Product_Number = pr.product_nbr
	rpt_data->qual[cnt].Product_Type = uar_get_code_display(pr.product_cd)
	rpt_data->qual[cnt].Transfused_Date_Time = format(pe.event_dt_tm, "MM-DD-YYYY HH:MM")
	rpt_data->qual[cnt].Ordering_Provider = ps.name_full_formatted
foot report
	stat = alterlist(rpt_data->qual, cnt)
with nocounter
endif
 
if ($sort_by in ("Date"))
select into "nl:"
    pe.product_id
from
    product_event pe
    ,encounter e
    ,product pr
    ,patient_dispense pd
    ,prsnl ps
    ,person p
    ,encntr_alias ea
plan pe
    where pe.event_dt_tm between cnvtdatetime(concat($beg_dt, " 00:00"))
    and cnvtdatetime(concat($end_dt, " 23:59:59"))
    and pe.event_type_cd = value(uar_get_code_by("DISPLAYKEY", 1610, "TRANSFUSED"))
join e
	where e.encntr_id = pe.encntr_id
	and parser(fac_parser)
join pr
	where pr.product_id = pe.product_id
join pd
	where pd.product_id = pe.product_id
	and pd.person_id = pe.person_id
join ps
	where ps.person_id = pd.dispense_prov_id
join p
	where p.person_id = pe.person_id
join ea
	where ea.encntr_id = pe.encntr_id
	and ea.active_ind = 1
	and ea.end_effective_dt_tm > cnvtdatetime(curdate, curtime)
	and ea.encntr_alias_type_cd = value(uar_get_code_by("DISPLAYKEY", 319, "FINNBR"))
order
	pe.event_dt_tm
	,pe.product_event_id
head report
	cnt = 0
 
head pe.product_event_id
	if (mod(cnt, 10) = 0)
		stat = alterlist(rpt_data->qual, cnt + 10)
	endif
	cnt = cnt + 1
	rpt_data->qual[cnt].Patient_Name = p.name_full_formatted
	rpt_data->qual[cnt].FIN = ea.alias
	rpt_data->qual[cnt].Product_Number = pr.product_nbr
	rpt_data->qual[cnt].Product_Type = uar_get_code_display(pr.product_cd)
	rpt_data->qual[cnt].Transfused_Date_Time = format(pe.event_dt_tm, "MM-DD-YYYY HH:MM")
	rpt_data->qual[cnt].Ordering_Provider = ps.name_full_formatted
foot report
	stat = alterlist(rpt_data->qual, cnt)
with nocounter
endif
 
select into $outdev
Patient_Name = substring(1, 30, rpt_data->qual[d.seq].Patient_Name ),
FIN = substring(1, 30, rpt_data->qual[d.seq].FIN ),
Product_Number = substring(1, 30, rpt_data->qual[d.seq].Product_Number ),
Product_Type = substring(1, 30, rpt_data->qual[d.seq].Product_Type ),
Transfused_Date_Time = substring(1, 30, rpt_data->qual[d.seq].Transfused_Date_Time ),
Ordering_Provider = substring(1, 30, rpt_data->qual[d.seq].Ordering_Provider )
 
from
	(dummyt d with seq = size(rpt_data->qual, 5))
plan d
order
	d.seq
with format, separator = " "
 
;select
;    cv.*
;from
;    code_value cv where cv.display_key = "TRANSFUSE*"
;    and cv.active_ind = 1
;    and cv.code_set = 200
 
 
 
 
end
go
