

drop program cov_flu_vac_active_patient_aud go
create program cov_flu_vac_active_patient_aud

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to. 

with OUTDEV

select distinct into $OUTDEV
     ea.alias
    ,e.encntr_id
    ,e.person_id
    ,facility=uar_get_code_display(e.loc_facility_cd)
    ,building=uar_get_code_display(e.loc_building_cd)
    ,unit=uar_get_code_display(e.loc_nurse_unit_cd)
    ,room=uar_get_code_display(e.loc_room_cd)
    ,bed=uar_get_code_display(e.loc_bed_cd)
    ,encntr_type=uar_get_code_display(e.encntr_type_cd)
    ,encntr_type_class=uar_get_code_display(e.encntr_type_class_cd)
    ,encntr_status=uar_get_code_display(e.encntr_status_cd)
    ,e.reg_dt_tm ";;q"
    ,e.disch_dt_tm ";;q"
    ,patient_name=p.name_full_formatted
    ,adult_patient_history=ce.event_title_text
    ,ce.result_val
    ,adult_history_dt_tm=ce.event_end_dt_tm ";;q"
    ,vaccine=o.order_mnemonic
    ,vaccine_status=uar_get_code_display(o.order_status_cd)
    ,vaccine_order_dt_tm=o.orig_order_dt_tm ";;q"
    ,discharge=o1.order_mnemonic
    ,discharge_status=uar_get_code_display(o1.order_status_cd)
    ,discharge_order_dt_tm=o1.orig_order_dt_tm ";;q"
from
     encntr_domain ed
    ,encounter e
    ,person p
    ,clinical_event ce
    ,encntr_alias ea
    ,orders o
    ,orders o1
    ,dummyt d1
    ,dummyt d2
plan ed
    where   ed.end_effective_dt_tm = cnvtdatetime("31-DEC-2100 00:00:00.00")  
    ;and 	ed.encntr_id			=     111457753                 
    and     ed.active_ind           = 1
join e
    where   e.encntr_id             = ed.encntr_id
    ;and     e.active_ind            = 1
join p
    where   p.person_id             = e.person_id
    ;and     p.active_ind            = 1
join ea
    where   ea.encntr_id            = e.encntr_id
    and     ea.beg_effective_dt_tm  <= cnvtdatetime(curdate,curtime3)
    and     ea.end_effective_dt_tm  >= cnvtdatetime(curdate,curtime3)
    and     ea.active_ind           = 1
    and     ea.encntr_alias_type_cd = 1077; FIN
join o

                    where   o.encntr_id = e.encntr_id
                    and     o.person_id = e.person_id
                    and     o.orig_ord_as_flag = 0
                    and     o.catalog_cd in(
                                             2760930.00 ;influenza virus vaccine, inactivated
                                            ,2760946.00 ;influenza virus vaccine, live 
                                            )
                    and     o.order_status_cd in(
                                                    0.0
                                                   ;,2542.00    ;Canceled
                                                  ; ,2543.00     ;Completed
                                                   ;,2544.00    ;Voided
                                                   ;,2545.00    ;Discontinued
                                                   ;,2546.00    ;Future
                                                   ;,2547.00    ;Incomplete
                                                   ;,2548.00    ;InProcess
                                                   ;,2549.00    ;On Hold, Med Student
                                                   ,2550.00     ;Ordered
                                                 ;,643466.00    ;Pending Complete
                                                   ;,2551.00    ;Pending Review
                                                   ;,2552.00    ;Suspended
                                                 ;,614538.00    ;Transfer/Canceled
                                                   ;,2553.00    ;Unscheduled
                                                 ;,643467.00    ;Voided With Results
                                                )
                                           
join d1
join ce
    where   ce.person_id            = p.person_id
    and     ce.event_cd             = 2555026041.00 ;Influenza Vaccine Indicated
    and		ce.task_assay_cd		= 2555026049
    and     ce.encntr_id            = e.encntr_id
	and     ce.valid_from_dt_tm		<= cnvtdatetime(curdate,curtime3)
    and     ce.valid_until_dt_tm	>= cnvtdatetime(curdate,curtime3)
    and     ce.result_status_cd 	not in(  
  											   ;,      23.00	;Active
											   ;,      34.00	;Modified
											   ;,      24.00	;Anticipated
											   ;,      25.00	;Auth (Verified)
											   ;,      26.00	;Canceled
											   ;,  614349.00	;Transcribed (corrected)
											   ;,      27.00	;Dictated
											           28.00	;In Error
											   ;,      32.00	;In Lab
											   ;,      33.00	;In Progress
											   ,      29.00	;In Error
											   ,      30.00	;In Error
											   ,      31.00	;In Error
											   ;,      35.00	;Modified
											   ;,      36.00	;Not Done
											   ;,  654643.00	;REJECTED
											   ;,      37.00	;Superseded
											   ;,      38.00	;Transcribed
											   ;,     39.00	;Unauth
											   ;,      40.00	;? Unknown
											   ;,41460865.00	;Transcribed
											
  											)
join d2
join o1

                    where   o1.encntr_id = e.encntr_id
                    and     o1.person_id = e.person_id
                    and     o1.catalog_cd in(
                                                 3224545.00	;Discharge Patient
 
                                            )       
                    and     o1.order_status_cd in(
                                                    0.0
                                                   ;,2542.00    ;Canceled
                                                   ,2543.00     ;Completed
                                                   ;,2544.00    ;Voided
                                                   ;,2545.00    ;Discontinued
                                                   ;,2546.00    ;Future
                                                   ;,2547.00    ;Incomplete
                                                   ;,2548.00    ;InProcess
                                                   ;,2549.00    ;On Hold, Med Student
                                                   ,2550.00     ;Ordered
                                                 ;,643466.00    ;Pending Complete
                                                   ;,2551.00    ;Pending Review
                                                   ;,2552.00    ;Suspended
                                                 ;,614538.00    ;Transfer/Canceled
                                                   ;,2553.00    ;Unscheduled
                                                 ;,643467.00    ;Voided With Results
                                                )         

order by
     facility
    ,encntr_type_class
    ,unit
    ,room
    ,e.reg_dt_tm
with time=60,outerjoin = d1, outerjoin = d2, separator = " ",format

end
go
