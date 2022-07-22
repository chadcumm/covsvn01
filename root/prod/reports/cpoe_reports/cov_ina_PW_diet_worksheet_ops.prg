select into "cer_temp:cpoe_up_to_0930_2019_a.csv"
 
;fin = i.alias
communication_type = trim(uar_get_code_display(i.communication_type_cd))
;,patient_name = trim(i.name_full_formatted)
;,order_type = trim(uar_get_code_display(i.med_order_type_cd))
;,order_status = trim(uar_get_code_display(i.order_status_cd))
;,i.action_sequence
;,action_type = trim(uar_get_code_display(i.action_type_cd))
;,action_dt = format(i.action_dt_tm, 'mm/dd/yyyy hh:mm;;q')
;,communication_type = trim(uar_get_code_display(i.communication_type_cd))
;,i.denominator
;,i.numerator
,order_dt = format(i.orig_order_dt_tm, 'yyyymm;;q')
;,order_mnemonic = trim(i.order_mnemonic), i.order_id
;,admit_dt = format(i.reg_dt_tm, 'mm/dd/yyyy hh:mm;;q')
;,disch_dt = format(i.disch_dt_tm, 'mm/dd/yyyy hh:mm;;q')
,patient_type = trim(uar_get_code_display(i.encntr_type_cd))
,facility=trim(uar_get_code_display(i.loc_facility_cd))
,provider=trim(i.order_provider)
,i.order_provider_id
,count(i.order_id)
;,nurse_unit=trim(uar_get_code_display(i.loc_nurse_unit_cd))
from(
(select distinct
    ea.alias,
    p.name_full_formatted,
    e.reg_dt_tm,
    e.disch_dt_tm,
    e.encntr_type_cd,
    o.order_id,
    e.encntr_id,
    e.person_id
    ,o.med_order_type_cd,
    oa.order_status_cd,
    oa.action_sequence,
    oa.action_type_cd,
    oa.action_dt_tm,
    oa.communication_type_cd
    ,o.orig_order_dt_tm,
    o.order_mnemonic
    , denominator = 1
    , numerator = evaluate2(
        if(oa.communication_type_cd     = 2560) 0 ;Telephone Read Back/Verified Cosign
        elseif(oa.communication_type_cd = 2561) 0 ;Verbal Read Back/Verified Cosign
        elseif(oa.communication_type_cd = 2562) 1 ;Direct
        elseif(oa.communication_type_cd = 54416801) 0   ;Written Paper Order/Fax No Cosign
        elseif(oa.communication_type_cd = 2576706321) 0 ;Per Nutrition Policy No Cosign
        elseif(oa.communication_type_cd = 2553560097) 0 ;Per Protocol No Cosign
        elseif(oa.communication_type_cd = 2553560089) 1 ;Standing Order Cosign
        else 0 endif)
    ,e.loc_facility_cd
    ,e.loc_nurse_unit_cd
    ;,p1.name_full_formatted
    ;,p1.position_cd
    ,order_provider=p2.name_full_formatted
    ,order_provider_id=p2.person_id
    ;,p2.position_cd
 
    from encounter e, orders o, order_action oa, encntr_alias ea, person p,prsnl p1,prsnl p2
    where e.loc_facility_cd > 0.0
 
 
    /*
    and e.encntr_type_cd in(
 
    309310  ;Emergency
    ,309311 ;Day Surgery
    ;309313 ;Preadmit
    ,309308 ;Inpatient
    ,309312 ;Observation
    ,19962820   ;Outpatient in a Bed
 
    )
    */
 
 
 
    and e.active_ind = 1
    and e.encntr_id != 0.00
    and o.encntr_id = e.encntr_id
    and o.active_ind = 1
    ;and o.orig_order_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
    ;and o.orig_order_dt_tm between cnvtdatetime("01-OCT-2018 00:00:00") and cnvtdatetime("01-JAN-2019 00:00:00")
    ;and o.orig_order_dt_tm between cnvtdatetime("01-JUL-2018 00:00:00") and cnvtdatetime("01-OCT-2018 00:00:00")
    and o.orig_order_dt_tm between cnvtdatetime("01-AUG-2019 00:00:00") and cnvtdatetime("30-SEP-2019 23:59:00")
   ; and o.template_order_flag in(0,1,5)
    and  o.orderable_type_flag != 6
  /*  and o.catalog_cd not in(
    2552703197, 47583263, 165382375, 2561119727, 165382565, 165382675, 165382689, 2553018573, 2553018583
    , 2553018603, 2553018323, 165382661,
    165382589, 2554793611, 165382707, 165382727, 21267059, 21267063, 21267067, 2549885359, 2575842575
    , 2575843071, 2575842529, 25469175,
    2557642447, 2561931299, 2575805731, 2561930481, 2557648183, 2561955475, 25471495, 25471519
    , 24591363, 2549886971, 2575841511, 2575960697,
    25473521, 2549888743, 2552610353, 2563538799, 25463731, 2563394971, 2575841071, 165375843
    , 165376027,21266999, 2579380153,
    165381811, 108665841, 108649991, 108635085, 34998213, 2578713535, 2557870887, 2557870909
    , 2575842903, 2557731363, 2560158023, 24300177,
    24300189, 24300186, 24300168,   24300192, 24300216
    , 24300198, 2549890863, 44933843, 24300195, 25474617, 2557727517, 2557648751, 161252229,
    2557666171, 24592231, 2554793823
    , 56622607, 2557728325, 257079695, 2557618729, 257618317, 165381905, 165381929, 165381947, 165381967)
    */
 
    and oa.order_id = o.order_id
    and oa.action_sequence = 1
    and oa.communication_type_cd in(
          2560.00   ;Telephone Read Back/Verified Cosign
       ,2561.00 ;Verbal Read Back/Verified Cosign
      , 2562.00 ;Direct
;     ,681544.00    ;No Cosign Required ***normally not included
;   ,19468404.00    ;Cosign Required ***normally not included
;   ,20094437.00    ;Initiate Planned Orders No Cosign ***normally not included
   ,54416801.00 ;Written Paper Order/Fax No Cosign
 ,2553560089.00 ;Standing Order Cosign
; ,2553560097.00    ;Per Protocol No Cosign ***normally not included
; ,2576706321.00    ;Per Nutrition Policy No Cosign ***normally not included
    )
 
    ;and oa.template_order_flag in (0,1,5)
    ;and oa.order_provider_id = 16481650 ;Flanders
    and ea.encntr_id = e.encntr_id
    and ea.encntr_alias_type_cd = 1077
    and ea.active_ind = 1
    and p.person_id = e.person_id
    and p.active_ind = 1
    and p1.person_id = oa.action_personnel_id
    and p2.person_id = oa.order_provider_id
    with sqltype('vc','vc','dq8','dq8','f8','f8','f8','f8','f8','f8','i2'
    ,'f8','dq8','f8','dq8','vc','i2','i2','f8','f8','vc','f8')
    )i
)
 
group by i.loc_facility_cd,format(i.orig_order_dt_tm, 'yyyymm;;q')
,i.encntr_type_cd,i.communication_type_cd,i.order_provider,i.order_provider_id
order by i.loc_facility_cd,format(i.orig_order_dt_tm, 'yyyymm;;q')
,i.encntr_type_cd,i.communication_type_cd,i.order_provider,i.order_provider_id
 
with counter, format = pcformat, separator = ",", format go