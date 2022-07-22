/***********************************************************************************************************************
  Program Name:       	bc_all_onc_dot_orders_drv
  Source File Name:   	bc_all_onc_dot_orders_drv.prg
  Program Written By: 	Stephen Kung
  Date:  			  	10-Sep-2020
  Program Purpose:      This is a driver program that is called by BC_ALL_ONC_DOT_ORDERS_LYT for the purpose of getting
                        PowerPlan and non-PowerPlan orders for downtime purposes. This is to serve as a short-term
                        downtime solution until a better system has been established (encompassing both charting
                        events, notes/documentation and orders)
************************************************************************************************************************
												*MODIFICATION HISTORY*
************************************************************************************************************************
 
Rev  Date         Jira       Programmer             Comment
---  -----------  ---------  ---------------------  --------------------------------------------------------------------
000  10-Sep-2020  CST-96425  Stephen Kung           Initial Release
 
***********************************************************************************************************************/
 
drop program bc_all_onc_dot_orders_drv:dba go
create program bc_all_onc_dot_orders_drv:dba
 
prompt
	"Output to File/Printer/MINE" = "MINE"
	, "Location Tree" = 0
	, "Begin Date" = "CURDATE"
	, "End Date" = "CURDATE"
	, "Debug Mode" = ""
 
with OUTDEV, location, begin_date, end_date, debug_mode
 
execute bc_all_all_date_routines
execute bc_all_all_std_routines
execute bc_all_location_routines ^"showUnits":["NURSEUNIT","AMBULATORY"],"maxViewLevel":"UNIT"^, $location
 
; free record outrec
record outrec (
    1 begin_dt_tm = dq8
    1 end_dt_tm = dq8
    1 debug_mode = i2
    1 inpt_location_ind = i2
    1 outpt_location_ind = i2
    1 appt_location_cd = f8
    1 pt[*]
        2 person_id = f8
        2 orig_facility = vc
        2 orig_floor = vc
        2 orig_room = vc
        2 orig_location = vc
        2 sched_appts[*]
            3 sched_appt_dt_tm = dq8
            3 sch_state_cd = f8
        2 pt_name = vc
        2 dob = dq8
        2 age = vc
        2 phn = vc
        2 mrn = vc
        2 orig_encntr_nbr = vc
        2 encntr_id = f8
        2 allergy = vc
        2 gender = vc
        2 last_height = vc
        2 last_height_dt_tm = dq8
        2 last_dosing_weight = vc
        2 last_dosing_weight_dt_tm = dq8
        2 last_weight_meas = vc
        2 last_weight_meas_dt_tm = dq8
        2 dual_modality_ind = i2
 
    1 orders[*]
        2 order_id = f8
        2 person_id = f8
        2 encntr_id = f8
        2 pathway_id = f8
        2 catalog_type_cd = f8
        2 pathway_comp_seq = i2
        2 ordered_as_mnemonic = vc
        2 start_dt_tm = dq8
        2 stop_dt_tm = dq8
        2 simplified_display_line = vc
        2 transfuse_order_comment = vc
        2 order_comment = vc
        2 prescription_ind = i2
        2 note_ind = i2
 
    1 child_orders[*]
        2 parent_order_id = f8
        2 person_id = f8
        2 orders [*]
            3 order_id = f8
            3 pathway_id = f8
            3 ordered_as_mnemonic = vc
            3 start_dt_tm = dq8
            3 stop_dt_tm = dq8
            3 simplified_display_line = vc
 
    1 pathways[*]
        2 pathway_id = f8
        2 pw_group_nbr = f8
        2 pathway_group_id = f8
        2 person_id = f8
        2 powerplan = vc
        2 phase = vc
        2 cycle = vc
 
    1 pathway_dots[*]
        2 pathway_group_id = f8
        2 person_id = f8
        2 pw_group_nbr = f8
        2 pathways[*]
            3 pathway_id = f8
            3 dot = vc
            3 start_dt_tm = dq8
)
 
set outrec->appt_location_cd = $location
set outrec->begin_dt_tm = cnvtdatetime(concat($begin_date, " 00:00:00"))
set outrec->end_dt_tm = cnvtdatetime(concat($end_date, " 23:59:59"))
 
set outrec->debug_mode = cnvtint($debug_mode)
 
/*DEBUG appointment location */
if (outrec->debug_mode = 1)
    set outrec->appt_location_cd = 2594992497.00 /*SPH 9D Inpatient */
    set outrec->begin_dt_tm = cnvtdatetime(curdate-20, 0)
    set outrec->end_dt_tm = cnvtdatetime(curdate+20, 0)
endif
/**************************************************************
; Declare Variables
**************************************************************/
declare all_allergies = vc with noconstant(" "), protect
declare order_comment = vc with noconstant(" "), protect
declare total_dose_admin = f8 with noconstant(0), protect
 
/* Helper variables*/
declare batch_init = i4 with constant(200), protect
declare batch_incr = i4 with constant(199), protect
 
declare nNum = i4 with noconstant(0), protect
declare cnt_per = i4 with noconstant(0), protect
declare cnt_path = i4 with noconstant(0), protect
declare cnt_ord = i4 with noconstant(0), protect
declare cnt_sch = i4 with noconstant(0), protect
declare cnt_dot = i4 with noconstant(0), protect
declare cnt_chi_ord = i4 with noconstant(0), protect
 
 
/* Person alias types*/
declare cv_4_mrn = f8 with constant(uar_get_code_by("MEANING", 4, "MRN")), protect
declare cv_4_phn = f8 with constant(uar_get_code_by("MEANING", 4, "NHIN")), protect
 
/* Person info types */
declare cv_355_user_defined = f8 with constant(uar_get_code_by("MEANING", 355, "USERDEFINED")), protect
 
/* Person info sub-types */
declare cv_356_dual_modal = f8 with constant(uar_get_code_by("MEANING", 356, "DUAL MODALIT")), protect
 
/* Encounter alias types*/
declare cv_319_fin = f8 with constant(uar_get_code_by("MEANING", 319, "FIN NBR")), protect
 
/* Encounter class types */
declare cv_69_inpatient_class = f8 with constant(uar_get_code_by("MEANING", 69, "INPATIENT")), protect
 
/* Event codes */
declare cv_72_height_length_meas = f8 with constant(uar_get_code_by("DISPLAY_KEY", 72, "HEIGHTLENGTHMEASURED")), protect
declare cv_72_weight_dosing = f8 with constant(uar_get_code_by("DISPLAY_KEY", 72, "WEIGHTDOSING")), protect
declare cv_72_weight_measured = f8 with constant(uar_get_code_by("DISPLAY_KEY", 72, "WEIGHTMEASURED")), protect
 
/* Order action codes */
declare cv_6003_order = f8 with constant(uar_get_code_by("MEANING", 6003, "ORDER")), protect
 
/* Order status codes*/
declare cv_6004_ordered = f8 with constant(uar_get_code_by("MEANING", 6004, "ORDERED")), protect
declare cv_6004_future = f8 with constant(uar_get_code_by("MEANING", 6004, "FUTURE")), protect
declare cv_6004_inprogress = f8 with constant(uar_get_code_by("MEANING", 6004, "INPROGRESS")), protect
declare cv_6004_suspended = f8 with constant(uar_get_code_by("MEANING", 6004, "SUSPENDED")), protect
 
/* Order comments codes*/
declare cv_14_ord_comment = f8 with constant(uar_get_code_by("MEANING", 14, "ORD COMMENT")), protect
 
/* Scheduling appt role codes */
declare cv_14250_patient = f8 with constant(uar_get_code_by("MEANING", 14250, "PATIENT")), protect
 
/* Scheduling state codes */
declare cv_14233_resched = f8 with constant(uar_get_code_by("MEANING", 14233, "RESCHEDULED")), protect
declare cv_14233_canceled = f8 with constant(uar_get_code_by("MEANING", 14233, "CANCELED")), protect
 
/* Order catalog codes */
declare cv_200_condition_rbc_transf =
    f8 with constant(uar_get_code_by("DISPLAY_KEY", 200, "CONDITIONALREDBLOODCELLTRANSFUSION")), protect
 
/* Order entry formats and fields / details for Transfusions*/
declare cv_16449_condition1operator =
    f8 with constant(uar_get_code_by("DISPLAY_KEY", 16449, "CONDITION1OPERATOR")), protect
declare cv_16449_condition1value =
    f8 with constant(uar_get_code_by("DISPLAY_KEY", 16449, "CONDITION1VALUE")), protect
declare cv_16449_condition1action =
    f8 with constant(uar_get_code_by("DISPLAY_KEY", 16449, "CONDITION1ACTION")), protect
declare cv_16449_condition2aoperator =
    f8 with constant(uar_get_code_by("DISPLAY_KEY", 16449, "CONDITION2AOPERATOR")), protect
declare cv_16449_condition2avalue =
    f8 with constant(uar_get_code_by("DISPLAY_KEY", 16449, "CONDITION2AVALUE")), protect
declare cv_16449_condition2boperator =
    f8 with constant(uar_get_code_by("DISPLAY_KEY", 16449, "CONDITION2BOPERATOR")), protect
declare cv_16449_condition2bvalue =
    f8 with constant(uar_get_code_by("DISPLAY_KEY", 16449, "CONDITION2BVALUE")), protect
declare cv_16449_condition2action =
    f8 with constant(uar_get_code_by("DISPLAY_KEY", 16449, "CONDITION2ACTION")), protect
declare cv_16449_condition3aoperator =
    f8 with constant(uar_get_code_by("DISPLAY_KEY", 16449, "CONDITION3AOPERATOR")), protect
declare cv_16449_condition3avalue =
    f8 with constant(uar_get_code_by("DISPLAY_KEY", 16449, "CONDITION3AVALUE")), protect
declare cv_16449_condition3boperator =
    f8 with constant(uar_get_code_by("DISPLAY_KEY", 16449, "CONDITION3BOPERATOR")), protect
declare cv_16449_condition3bvalue =
    f8 with constant(uar_get_code_by("DISPLAY_KEY", 16449, "CONDITION3BVALUE")), protect
declare cv_16449_condition3action =
    f8 with constant(uar_get_code_by("DISPLAY_KEY", 16449, "CONDITION3ACTION")), protect
declare cv_16449_collectionpriority =
    f8 with constant(uar_get_code_by("DISPLAY_KEY", 16449, "COLLECTIONPRIORITY")), protect
declare cv_16449_routeofadministration =
    f8 with constant(uar_get_code_by("DISPLAY_KEY", 16449, "ROUTEOFADMINISTRATION")), protect
declare cv_16449_tmlschedule =
    f8 with constant(uar_get_code_by("DISPLAY_KEY", 16449, "TMLSCHEDULE")), protect
declare cv_16449_specialbloodproductneeds =
    f8 with constant(uar_get_code_by("DISPLAY_KEY", 16449, "SPECIALBLOODPRODUCTNEEDS")), protect
declare cv_16449_specialinstructionsbblab =
    f8 with constant(uar_get_code_by("DISPLAY_KEY", 16449, "SPECIALINSTRUCTIONSBBLAB")), protect
declare cv_16449_specialinstructionsbbrn =
    f8 with constant(uar_get_code_by("DISPLAY_KEY", 16449, "SPECIALINSTRUCTIONSBBRN")), protect
 
 
/* END DECLARE VARIABLES *************************************************************************/
 
 
/**************************************************************
; Main Logic of the program
**************************************************************/
call evaluate_location_cd_type(null)
if (outrec->outpt_location_ind = 1)
    call load_patient_ids_from_sched(null)
elseif (outrec->inpt_location_ind = 1)
    call load_patient_ids_from_inpatient_unit(null)
    ; call print_output_rec_to_screen(null)
    ; go to end_report
endif
call load_orders_by_pt(null)
call load_powerplan_note_components(null)
call populate_conditional_tm_orders(null)
call load_child_orders_by_pt(null)
call load_powerplans_by_pt(null)
call load_powerplan_dots_by_pt(null)
call load_pt_dual_modality_ind(null)
call load_pt_identifiers(null)
call load_encntr_identifiers(null)
call load_patient_allergies(null)
call get_last_charted_event(null)
call print_output_rec_to_screen(null)
 
go to end_report
 
 
/**************************************************************
; Subroutines
**************************************************************/
subroutine evaluate_location_cd_type(null)
    select into "nl:"
    from code_value cv
    plan cv where cv.code_value = outrec->appt_location_cd
    detail
        if (cv.cdf_meaning = "AMBULATORY")
            outrec->outpt_location_ind = 1
        elseif (cv.cdf_meaning = "NURSEUNIT")
            outrec->inpt_location_ind = 1
        endif
    with nocounter, separator=" ", format
end
 
 
subroutine load_patient_ids_from_inpatient_unit(null)
    select into "nl:"
    from encntr_domain ed
        , encounter e
        , person p
    plan ed where ed.loc_nurse_unit_cd = outrec->appt_location_cd
        and ed.active_ind = 1
        and parser(HideTestPatients("ed.person_id"))
    join e where e.encntr_id = ed.encntr_id
        and e.disch_dt_tm is null
        and e.active_ind = 1
        and e.end_effective_dt_tm > sysdate
        and e.encntr_type_class_cd = cv_69_inpatient_class
    join p where p.person_id = e.person_id
    order by e.person_id
 
    head report
        cnt_per = 0
        stat = alterlist(outrec->pt, batch_init)
    head e.person_id
        cnt_per = cnt_per + 1
        if (mod(cnt_per, batch_init) = 1 and cnt_per > batch_init)
            stat = alterlist(outrec->pt, cnt_per + batch_incr)
        endif
 
        outrec->pt[cnt_per]->person_id          = e.person_id
        outrec->pt[cnt_per]->encntr_id          = e.encntr_id
 
        stat = alterlist(outrec->pt[cnt_per]->sched_appts, 1)
        outrec->pt[cnt_per]->sched_appts[1]->sched_appt_dt_tm = e.reg_dt_tm
        outrec->pt[cnt_per]->sched_appts[1]->sch_state_cd = cv_69_inpatient_class
 
    foot e.person_id
        null
 
    foot report
        stat = alterlist(outrec->pt, cnt_per)
 
    with nocounter, separator=" ", format
end
 
 
subroutine load_patient_ids_from_sched(null)
    select into "nl:"
    from sch_appt sa
    plan sa where sa.beg_dt_tm  between cnvtdatetime(outrec->begin_dt_tm) and cnvtdatetime(outrec->end_dt_tm)
        and sa.appt_location_cd     =   outrec->appt_location_cd
        and sa.sch_state_cd      not in (cv_14233_resched
                                        , cv_14233_canceled)
        and sa.sch_role_cd          =   cv_14250_patient
        and sa.sch_event_id        !=   0
        and sa.active_ind           =   1
        and parser(HideTestPatients("sa.person_id"))
        /*DEBUG person_id */
        ; and p.person_id = 20691191
 
    order by sa.person_id
 
    head report
        cnt_per = 0
        stat = alterlist(outrec->pt, batch_init)
    head sa.person_id
        cnt_per = cnt_per + 1
        if (mod(cnt_per, batch_init) = 1 and cnt_per > batch_init)
            stat = alterlist(outrec->pt, cnt_per + batch_incr)
        endif
 
        outrec->pt[cnt_per]->person_id          = sa.person_id
        outrec->pt[cnt_per]->encntr_id          = sa.encntr_id
 
        cnt_sch = 0
        stat = alterlist(outrec->pt[cnt_per]->sched_appts, batch_init)
 
    ; head sa.beg_dt_tm
    detail
        cnt_sch = cnt_sch + 1
        if (mod(cnt_sch, batch_init) = 1 and cnt_sch > batch_init)
            stat = alterlist(outrec->pt[cnt_per]->sched_appts, cnt_sch + batch_incr)
        endif
 
        outrec->pt[cnt_per]->sched_appts[cnt_sch]->sched_appt_dt_tm   = sa.beg_dt_tm
        outrec->pt[cnt_per]->sched_appts[cnt_sch]->sch_state_cd       = sa.sch_state_cd
 
    ; foot sa.beg_dt_tm
    ;     null
 
    foot sa.person_id
        stat = alterlist(outrec->pt[cnt_per]->sched_appts, cnt_sch)
 
    foot report
        stat = alterlist(outrec->pt, cnt_per)
 
    with nocounter, separator=" ", format
 
end
 
 
subroutine load_orders_by_pt(null)
    select into "nl:"
    from orders o
        , act_pw_comp apc
        , order_comment oc
        , long_text lt
    plan o where
        (
            /*Start time is within the time frame */
            o.current_start_dt_tm between cnvtdatetime(outrec->begin_dt_tm)
            and cnvtdatetime(outrec->end_dt_tm)
 
            or
 
            /*Child orders whose start times are within the time frame */
            exists (
                select 1
                from orders o2
                where o2.current_start_dt_tm between cnvtdatetime(outrec->begin_dt_tm)
                    and cnvtdatetime(outrec->end_dt_tm)
                    and o2.protocol_order_id = o.order_id
            )
 
            or
 
            /*Non-DOT orders that have already fired a task and the task is due
            within the time frame*/
            exists (
                select 1
                from orders o2
                where o2.current_start_dt_tm between cnvtdatetime(outrec->begin_dt_tm)
                    and cnvtdatetime(outrec->end_dt_tm)
                    and o2.template_order_id = o.order_id
            )
 
            or
 
            /*Non-DOT orders that are continuous infusions or other unscheduled
            orders whose start time is any time before the time frame (this is
            because continuous infusions and unscheduled orders don't fire off
            tasks */
            (
                o.freq_type_flag = 5
                and o.current_start_dt_tm < cnvtdatetime(outrec->begin_dt_tm)
            )
 
        )
        and o.product_id = 0
        and expand(nNum, 1, size(outrec->pt, 5),
            o.person_id, outrec->pt[nNum]->person_id)
        and (expand(nNum, 1, size(outrec->pt, 5),
            o.encntr_id, outrec->pt[nNum]->encntr_id)
            or o.encntr_id = 0)
        and o.order_status_cd in (
            cv_6004_ordered
            , cv_6004_future
            , cv_6004_inprogress
            , cv_6004_suspended
        )
        and o.orig_ord_as_flag in (0, 1, 5)
        and o.template_order_flag not in (
              2 /* Order instances */
            , 3 /* Non-medication tasks */
            , 4 /* Medication tasks */
        )
        and o.protocol_order_id = 0 /*Parent orders only*/
    join oc where oc.order_id = outerjoin(o.order_id)
        and oc.action_sequence = outerjoin(1)
        and oc.comment_type_cd = outerjoin(cv_14_ord_comment)
    join lt where lt.long_text_id = outerjoin(oc.long_text_id)
        and lt.active_ind = outerjoin(1)
    join apc where apc.parent_entity_id = outerjoin(o.order_id)
        and apc.parent_entity_name = outerjoin("ORDERS")
        and apc.active_ind = outerjoin(1)
        and apc.included_ind = outerjoin(1)
 
    order by o.person_id
        , apc.pathway_id
        , apc.sequence
 
    head report
        cnt_ord = 0
        stat = alterlist(outrec->orders, batch_init)
    detail
        cnt_ord = cnt_ord + 1
        if (mod(cnt_ord, batch_init) = 1 and cnt_ord > batch_init)
            stat = alterlist(outrec->orders, cnt_ord + batch_incr)
        endif
 
        outrec->orders[cnt_ord].order_id = o.order_id
        outrec->orders[cnt_ord].person_id = o.person_id
        outrec->orders[cnt_ord].encntr_id = o.encntr_id
        outrec->orders[cnt_ord].pathway_id = apc.pathway_id
        outrec->orders[cnt_ord].catalog_type_cd = o.catalog_type_cd
        outrec->orders[cnt_ord].pathway_comp_seq = apc.sequence
        if (outrec->debug_mode = 1)
            outrec->orders[cnt_ord].ordered_as_mnemonic =
                concat("{order_id:", trim(cnvtstring(o.order_id)), "} ", o.ordered_as_mnemonic)
        else
            outrec->orders[cnt_ord].ordered_as_mnemonic = o.ordered_as_mnemonic
        endif
        outrec->orders[cnt_ord].start_dt_tm = o.current_start_dt_tm
        outrec->orders[cnt_ord].stop_dt_tm = o.projected_stop_dt_tm
        outrec->orders[cnt_ord].simplified_display_line =
            if(textlen(trim(o.simplified_display_line)) > 1) o.simplified_display_line
            else o.clinical_display_line
            endif
        outrec->orders[cnt_ord].order_comment = substring(1, 255, lt.long_text)
 
        if (o.orig_ord_as_flag = 1)
            outrec->orders[cnt_ord].prescription_ind = 1
        else
            outrec->orders[cnt_ord].prescription_ind = 0
        endif
 
        outrec->orders[cnt_ord].note_ind = 0
 
    foot report
        stat = alterlist(outrec->orders, cnt_ord)
end
 
 
subroutine load_powerplan_note_components(null)
    select into "nl:"
    from pathway pw
        , act_pw_comp apc
        , long_text lt
    plan pw where expand(nNum, 1, size(outrec->orders, 5),
        pw.pathway_id, outrec->orders[nNum]->pathway_id)
        and pw.pathway_id != 0
    join apc where apc.pathway_id = pw.pathway_id
        and apc.active_ind = 1
        and apc.parent_entity_name = "LONG TEXT"
    join lt where lt.long_text_id = apc.parent_entity_id
        and lt.active_ind = 1
    order by pw.person_id
        , pw.pathway_id
        , apc.sequence
 
    head report
        cnt_ord = size(outrec->orders, 5)
        stat = alterlist(outrec->orders, cnt_ord + batch_init)
 
    detail
        cnt_ord = cnt_ord + 1
        if (mod(cnt_ord, batch_init) = 1 and cnt_ord > batch_init)
            stat = alterlist(outrec->orders, cnt_ord + batch_incr)
        endif
 
        outrec->orders[cnt_ord].order_id = 0
        outrec->orders[cnt_ord].person_id = pw.person_id
        outrec->orders[cnt_ord].pathway_id = apc.pathway_id
        outrec->orders[cnt_ord].pathway_comp_seq = apc.sequence
        outrec->orders[cnt_ord].ordered_as_mnemonic = "Note"
        outrec->orders[cnt_ord].transfuse_order_comment = substring(0, 255, lt.long_text)
        outrec->orders[cnt_ord].prescription_ind = 0
        outrec->orders[cnt_ord].note_ind = 1
 
    foot report
        stat = alterlist(outrec->orders, cnt_ord)
 
end
 
 
subroutine populate_conditional_tm_orders(null)
    select into "nl:"
        order_id = o.order_id
    from orders o
        , order_detail od
        , order_entry_format oef
    plan o where expand(nNum, 1, size(outrec->orders, 5),
            o.order_id, outrec->orders[nNum]->order_id)
    join oef where oef.oe_format_id = o.oe_format_id
        and oef.action_type_cd = cv_6003_order
        and cnvtupper(oef.oe_format_name) like "*LAB*PRODUCT*CONDITIONAL*"
    join od where od.order_id = o.order_id
        and od.oe_field_id in (
              cv_16449_condition1operator
            , cv_16449_condition1value
            , cv_16449_condition1action
            , cv_16449_condition2aoperator
            , cv_16449_condition2avalue
            , cv_16449_condition2boperator
            , cv_16449_condition2bvalue
            , cv_16449_condition2action
            , cv_16449_condition3aoperator
            , cv_16449_condition3avalue
            , cv_16449_condition3boperator
            , cv_16449_condition3bvalue
            , cv_16449_condition3action
            , cv_16449_collectionpriority
            , cv_16449_routeofadministration
            , cv_16449_tmlschedule
            , cv_16449_specialbloodproductneeds
            , cv_16449_specialinstructionsbblab
            , cv_16449_specialinstructionsbbrn
        )
    order by o.order_id
        , od.detail_sequence
    head o.order_id
        pos_ord = locateval(nNum, 1, size(outrec->orders, 5),
            o.order_id, outrec->orders[nNum]->order_id)
        order_comment = " "
    detail
        case (od.oe_field_id)
            of cv_16449_condition1operator :
                order_comment = concat(order_comment, "Cond. 1:If hemoglobin is ", od.oe_field_display_value)
            of cv_16449_condition1value :
                order_comment = concat(order_comment, " ", trim(od.oe_field_display_value), " (g/L), then transfuse")
            of cv_16449_condition1action :
                order_comment = concat(order_comment, " ", trim(od.oe_field_display_value), " units ")
            of cv_16449_condition2aoperator :
                order_comment = concat(order_comment, ", Cond. 2:If hemoglobin is ", od.oe_field_display_value)
            of cv_16449_condition2avalue :
                order_comment = concat(order_comment, " ", trim(od.oe_field_display_value), " (g/L)")
            of cv_16449_condition2boperator :
                order_comment = concat(order_comment, " and ", od.oe_field_display_value)
            of cv_16449_condition2bvalue :
                order_comment = concat(order_comment, " ", trim(od.oe_field_display_value), " (g/L), then tranfuse")
            of cv_16449_condition2action :
                order_comment = concat(order_comment, " ", trim(od.oe_field_display_value), " units")
            of cv_16449_condition3aoperator :
                order_comment = concat(order_comment, ", Cond. 3:If hemoglobin is ", od.oe_field_display_value)
            of cv_16449_condition3avalue :
                order_comment = concat(order_comment, " ", trim(od.oe_field_display_value), " (g/L)")
            of cv_16449_condition3boperator :
                order_comment = concat(order_comment, " and ", od.oe_field_display_value)
            of cv_16449_condition3bvalue :
                order_comment = concat(order_comment, " ", trim(od.oe_field_display_value), " (g/L), then tranfus ")
            of cv_16449_condition3action :
                order_comment = concat(order_comment, " ", trim(od.oe_field_display_value), " units")
            of cv_16449_collectionpriority :
                order_comment = concat(order_comment, ", ", trim(od.oe_field_display_value))
            of cv_16449_routeofadministration :
                order_comment = concat(order_comment, ", ", trim(od.oe_field_display_value))
            of cv_16449_tmlschedule :
                order_comment = concat(order_comment, ", Administer each over:", trim(od.oe_field_display_value))
            of cv_16449_specialbloodproductneeds :
                order_comment = concat(order_comment, ", ", od.oe_field_display_value)
            of cv_16449_specialinstructionsbblab :
                order_comment = concat(order_comment, ", Lab instr:", trim(od.oe_field_display_value))
            of cv_16449_specialinstructionsbbrn :
                order_comment = concat(order_comment, ", RN instr:", trim(od.oe_field_display_value))
            endcase
    foot o.order_id
        if (pos_ord > 0)
            outrec->orders[pos_ord]->transfuse_order_comment = order_comment
            outrec->orders[pos_ord]->simplified_display_line = " "
        endif
end
 
 
subroutine load_child_orders_by_pt(null)
    select into "nl:"
    from orders o
        , act_pw_comp apc
    plan o where o.current_start_dt_tm between cnvtdatetime(outrec->begin_dt_tm)
            and cnvtdatetime(outrec->end_dt_tm)
        and o.product_id = 0
        and expand(nNum, 1, size(outrec->pt, 5),
            o.person_id, outrec->pt[nNum]->person_id)
        and o.order_status_cd in (
            cv_6004_ordered
            , cv_6004_future
            , cv_6004_inprogress
            , cv_6004_suspended
        )
        and o.orig_ord_as_flag in (0, 5)
        and o.template_order_flag != 4
        and o.protocol_order_id != 0 /*Child orders only*/
    join apc where apc.parent_entity_id = o.order_id
        and apc.parent_entity_name = "ORDERS"
        and apc.active_ind = 1
        and apc.included_ind = 1
 
    order by o.person_id
        , o.order_id
        , apc.pathway_id
        , apc.sequence
 
    head report
        cnt_ord = 0
        stat = alterlist(outrec->child_orders, batch_init)
 
    head o.protocol_order_id
        cnt_ord = cnt_ord + 1
        if (mod(cnt_ord, batch_init) = 1 and cnt_ord > batch_init)
            stat = alterlist(outrec->child_orders, cnt_ord + batch_incr)
        endif
 
        outrec->child_orders[cnt_ord].parent_order_id = o.protocol_order_id
        outrec->child_orders[cnt_ord].person_id = o.person_id
 
        cnt_chi_ord = 0
        stat = alterlist(outrec->child_orders[cnt_ord]->orders, batch_init)
    detail
        cnt_chi_ord = cnt_chi_ord + 1
        if (mod(cnt_chi_ord, batch_init) = 1 and cnt_chi_ord > batch_init)
            stat = alterlist(outrec->child_orders[cnt_ord]->orders, cnt_chi_ord + batch_incr)
        endif
 
        outrec->child_orders[cnt_ord]->orders[cnt_chi_ord].order_id = o.order_id
        outrec->child_orders[cnt_ord]->orders[cnt_chi_ord].pathway_id = apc.pathway_id
        outrec->child_orders[cnt_ord]->orders[cnt_chi_ord].ordered_as_mnemonic = o.ordered_as_mnemonic
        outrec->child_orders[cnt_ord]->orders[cnt_chi_ord].start_dt_tm = o.current_start_dt_tm
        outrec->child_orders[cnt_ord]->orders[cnt_chi_ord].stop_dt_tm = o.projected_stop_dt_tm
        outrec->child_orders[cnt_ord]->orders[cnt_chi_ord].simplified_display_line = o.simplified_display_line
 
    foot o.protocol_order_id
        stat = alterlist(outrec->child_orders[cnt_ord]->orders, cnt_chi_ord)
 
    foot report
        stat = alterlist(outrec->child_orders, cnt_ord)
end
 
 
subroutine load_powerplans_by_pt(null)
    select into "nl:"
    from pathway pw
    plan pw where expand(nNum, 1, size(outrec->pt, 5),
            pw.person_id, outrec->pt[nNum]->person_id)
        and pw.type_mean != "DOT"
        and (
                /*Plans/phase start between time frame */
                pw.start_dt_tm between
                cnvtdatetime(outrec->begin_dt_tm) and cnvtdatetime(outrec->end_dt_tm)
            or
                /*DOT exists within time frame */
                exists (
                    select 1
                    from pathway pw2
                    where pw2.pathway_group_id = pw.pathway_group_id
                        and pw2.type_mean = "DOT"
                        and pw2.start_dt_tm between
                        cnvtdatetime(outrec->begin_dt_tm) and cnvtdatetime(outrec->end_dt_tm)
                )
            or pw.start_dt_tm <= cnvtdatetime(outrec->begin_dt_tm)
        )
 
    order by pw.person_id
        , pw.pathway_id
 
    head report
        cnt_path = 0
        stat = alterlist(outrec->pathways, batch_init)
    head pw.person_id
        null
    detail
        cnt_path = cnt_path + 1
        if (mod(cnt_path, batch_init) = 1 and cnt_path > batch_init)
            stat = alterlist(outrec->pathways, cnt_path + batch_incr)
        endif
 
        outrec->pathways[cnt_path]->pathway_id = pw.pathway_id
        outrec->pathways[cnt_path]->pw_group_nbr = pw.pw_group_nbr
        outrec->pathways[cnt_path]->pathway_group_id = pw.pathway_group_id
        outrec->pathways[cnt_path]->person_id = pw.person_id
        if (outrec->debug_mode = 1)
            outrec->pathways[cnt_path]->powerplan =
                concat("{pw_group_nbr:", trim(cnvtstring(pw.pw_group_nbr)), "} ", pw.pw_group_desc)
            outrec->pathways[cnt_path]->phase =
                concat("{pathway_id:", trim(cnvtstring(pw.pathway_id)), "} ", pw.description)
        else
            outrec->pathways[cnt_path]->powerplan = pw.pw_group_desc
            outrec->pathways[cnt_path]->phase = pw.description
        endif
        outrec->pathways[cnt_path]->cycle =
            concat(trim(uar_get_code_display(pw.cycle_label_cd)), " ", trim(cnvtstring(pw.cycle_nbr)))
    foot pw.person_id
        cnt_path = cnt_path + 1
        if (mod(cnt_path, batch_init) = 1 and cnt_path > batch_init)
            stat = alterlist(outrec->pathways, cnt_path + batch_incr)
        endif
 
        outrec->pathways[cnt_path]->pathway_id = 0
        outrec->pathways[cnt_path]->person_id = pw.person_id
 
    foot report
 
        stat = alterlist(outrec->pathways, cnt_path)
end
 
 
subroutine load_powerplan_dots_by_pt(null)
    select into "nl:"
    from pathway pw
    plan pw where expand(nNum, 1, size(outrec->pt, 5),
            pw.person_id, outrec->pt[nNum]->person_id)
        and pw.type_mean = "DOT"
        and pw.start_dt_tm between cnvtdatetime(outrec->begin_dt_tm) and cnvtdatetime(outrec->end_dt_tm)
        and exists (
            /*Only looking for PowerPlan DOTs that contain active child orders */
            select 1
            from act_pw_comp apc
                , orders o
            where apc.pathway_id = pw.pathway_id
                and apc.parent_entity_name = "ORDERS"
                and  o.order_id = apc.parent_entity_id
                and o.order_status_cd in (
                    cv_6004_ordered
                    , cv_6004_future
                    , cv_6004_inprogress
                    , cv_6004_suspended
                )
        )
 
    order by pw.pathway_group_id
        , pw.period_nbr
        , pw.pathway_id
 
    head report
        cnt_path = 0
        stat = alterlist(outrec->pathway_dots, batch_init)
 
    head pw.pathway_group_id
        cnt_path = cnt_path + 1
        if (mod(cnt_path, batch_init) = 1 and cnt_path > batch_init)
            stat = alterlist(outrec->pathway_dots, cnt_path + batch_incr)
        endif
 
        outrec->pathway_dots[cnt_path]->pathway_group_id = pw.pathway_group_id
        outrec->pathway_dots[cnt_path]->person_id = pw.person_id
        outrec->pathway_dots[cnt_path]->pw_group_nbr = pw.pw_group_nbr
 
        cnt_dot = 0
        stat = alterlist(outrec->pathway_dots[cnt_path]->pathways, batch_init)
 
    detail
        cnt_dot = cnt_dot + 1
        if (mod(cnt_dot, batch_init) = 1 and cnt_dot > batch_init)
            stat = alterlist(outrec->pathway_dots[cnt_path]->pathways, cnt_dot + batch_incr)
        endif
 
        outrec->pathway_dots[cnt_path]->pathways[cnt_dot]->pathway_id = pw.pathway_id
        outrec->pathway_dots[cnt_path]->pathways[cnt_dot]->dot = pw.description
        outrec->pathway_dots[cnt_path]->pathways[cnt_dot]->start_dt_tm = pw.start_dt_tm
 
    foot pw.pathway_group_id
        stat = alterlist(outrec->pathway_dots[cnt_path]->pathways, cnt_dot)
 
    foot report
        stat = alterlist(outrec->pathway_dots, cnt_path)
end
 
 
subroutine load_pt_dual_modality_ind(null)
    /*This is a separate subroutine because it's the only info that is
    obtained from the person_info table, no other query touches this */
    select into "nl:"
        dual_modality = uar_get_code_display(pi.value_cd)
    from person_info pi
    plan pi where expand(nNum, 1, size(outrec->pt, 5),
            pi.person_id, outrec->pt[nNum]->person_id)
        and pi.info_type_cd = outerjoin(cv_355_user_defined)
        and pi.info_sub_type_cd = outerjoin(cv_356_dual_modal)
        and pi.active_ind = outerjoin(1)
        and pi.end_effective_dt_tm > outerjoin(sysdate)
 
    order by pi.person_id
 
    head pi.person_id
        pos_per = 0
 
        pos_per = locateval(nNum, 1, size(outrec->pt, 5),
            pi.person_id, outrec->pt[nNum]->person_id)
 
    detail
        outrec->pt[pos_per]->dual_modality_ind =
            if(cnvtupper(dual_modality) = "YES") 1
            else 0
            endif
 
    foot pi.person_id
        null
end
 
 
subroutine load_pt_identifiers(null)
    select into "nl:"
    from person p
        , person_alias pa
    plan p where expand(nNum, 1, size(outrec->pt, 5),
            p.person_id, outrec->pt[nNum]->person_id)
    join pa where pa.person_id = p.person_id
        and pa.active_ind = 1
        and pa.end_effective_dt_tm > sysdate
        and pa.person_alias_type_cd in (
            cv_4_mrn
            , cv_4_phn
        )
 
    order by p.person_id
 
    head p.person_id
        pos_per = 0
        nNum = 0
 
        pos_per = locateval(nNum, 1, size(outrec->pt, 5),
            p.person_id, outrec->pt[nNum]->person_id)
 
        if (outrec->debug_mode = 1)
            outrec->pt[pos_per]->pt_name =
                concat("{person_id:", trim(cnvtstring(p.person_id)), "} ", p.name_full_formatted)
        else
            outrec->pt[pos_per]->pt_name = p.name_full_formatted
        endif
        outrec->pt[pos_per]->dob = p.birth_dt_tm
        outrec->pt[pos_per]->age = cnvtage2(p.birth_dt_tm)
        outrec->pt[pos_per]->gender = uar_get_code_display(p.sex_cd)
 
    detail
        case(pa.person_alias_type_cd)
            of cv_4_mrn: outrec->pt[pos_per]->mrn = pa.alias
            of cv_4_phn: outrec->pt[pos_per]->phn = pa.alias
        endcase
 
    foot p.person_id
        null
 
    with nocounter, separator=" ", format
end
 
 
subroutine load_encntr_identifiers(null)
    select into "nl:"
    from encounter e
        , encntr_alias ea
    plan e where expand(nNum, 1, size(outrec->pt, 5),
            e.encntr_id, outrec->pt[nNum]->encntr_id)
    join ea where ea.encntr_id = e.encntr_id
        and ea.active_ind = 1
        and ea.end_effective_dt_tm > sysdate
        and ea.encntr_alias_type_cd = cv_319_fin
    order by e.encntr_id
 
    head e.encntr_id
        pos_per = 0
        nNum = 0
 
        pos_per = locateval(nNum, 1, size(outrec->pt, 5),
            e.encntr_id, outrec->pt[nNum]->encntr_id)
 
        outrec->pt[pos_per]->orig_encntr_nbr = ea.alias
        outrec->pt[pos_per]->orig_facility = uar_get_code_display(e.loc_facility_cd)
        outrec->pt[pos_per]->orig_floor = uar_get_code_display(e.loc_nurse_unit_cd)
        outrec->pt[pos_per]->orig_room = uar_get_code_display(e.loc_room_cd)
        outrec->pt[pos_per]->orig_location = uar_get_code_display(e.location_cd)
 
    foot e.encntr_id
        null
 
    with nocounter, separator=" ", format
end
 
 
subroutine load_patient_allergies(null)
    select into "nl:"
        a.person_id
        , allergy =
            if(a.substance_nom_id = 0) a.substance_ftdesc
            else n.source_string
            endif
    from allergy a
        , nomenclature n
    plan a where expand(nNum, 1, size(outrec->pt, 5),
            a.person_id, outrec->pt[nNum]->person_id)
        and a.active_ind = 1
        and a.end_effective_dt_tm > sysdate
        and a.cancel_dt_tm is null
    join n where n.nomenclature_id = a.substance_nom_id
 
    order by a.person_id
 
    head a.person_id
        all_allergies = " "
        initial_flag = 1
 
        pos_per = 0
 
        pos_per = locateval(nNum, 1, size(outrec->pt, 5),
            a.person_id, outrec->pt[nNum]->person_id)
 
    detail
        if (initial_flag = 1)
            all_allergies = allergy
            initial_flag = 0
        else
            all_allergies = concat(all_allergies, ", ", trim(allergy, 3))
        endif
 
    foot a.person_id
        outrec->pt[pos_per].allergy = trim(replace(all_allergies,",","",2),3)
 
    with nocounter, separator=" ", format
end
 
 
subroutine get_last_charted_event(null)
    select into "nl:"
    from clinical_event ce
    plan ce where expand(nNum, 1, size(outrec->pt, 5), ce.person_id, outrec->pt[nNum].person_id)
        and ce.valid_until_dt_tm > sysdate
        and ce.event_cd in (
            cv_72_height_length_meas
            , cv_72_weight_dosing
            , cv_72_weight_measured
        )
 
    order by ce.person_id
        , ce.event_cd
        , ce.event_end_dt_tm desc
 
    head ce.person_id
        pos_per = 0
        pos_per = locateval(nNum, 1, size(outrec->pt, 5), ce.person_id, outrec->pt[nNum].person_id)
 
    head ce.event_cd
        case(ce.event_cd)
            of cv_72_height_length_meas:
                outrec->pt[pos_per].last_height = concat(trim(ce.result_val), " ", uar_get_code_display(ce.result_units_cd))
                outrec->pt[pos_per].last_height_dt_tm = ce.event_end_dt_tm
            of cv_72_weight_dosing:
              outrec->pt[pos_per].last_dosing_weight = concat(trim(ce.result_val), " ", uar_get_code_display(ce.result_units_cd))
                outrec->pt[pos_per].last_dosing_weight_dt_tm = ce.event_end_dt_tm
            of cv_72_weight_measured:
                outrec->pt[pos_per].last_weight_meas = concat(trim(ce.result_val), " ", uar_get_code_display(ce.result_units_cd))
                outrec->pt[pos_per].last_weight_meas_dt_tm = ce.event_end_dt_tm
        endcase
 
    foot ce.event_cd
        x = 0
 
    foot ce.person_id
        x = 0
 
    with nocounter, separator=" ", format
end
 
 
subroutine print_output_rec_to_screen(null)
 
select into $outdev
    order_id = outrec->orders[d1.seq]->order_id
    , person_id = outrec->orders[d1.seq]->person_id
    , encntr_id = outrec->orders[d1.seq]->encntr_id
    , pathway_id = outrec->orders[d1.seq]->pathway_id
    , catalog_type_cd = outrec->orders[d1.seq]->catalog_type_cd
    , pathway_comp_seq = outrec->orders[d1.seq]->pathway_comp_seq
    , ordered_as_mnemonic = outrec->orders[d1.seq]->ordered_as_mnemonic
    , start_dt_tm = outrec->orders[d1.seq]->start_dt_tm
    , stop_dt_tm = outrec->orders[d1.seq]->stop_dt_tm
    , simplified_display_line = outrec->orders[d1.seq]->simplified_display_line
    ; , order_comment = outrec->orders[d1.seq]->order_comment
    ; , transfuse_order_comment = outrec->orders[d1.seq]->transfuse_order_comment
    ; person_id = outrec->pt[d1.seq]->person_id
    ; , orig_facility = outrec->pt[d1.seq]->orig_facility
    ; , orig_floor = outrec->pt[d1.seq]->orig_floor
    ; , orig_room = outrec->pt[d1.seq]->orig_room
    ; , orig_location = outrec->pt[d1.seq]->orig_location
    ; , sched_appts = outrec->pt[d1.seq]->sched_appts
    ; , pt_name = outrec->pt[d1.seq]->pt_name
    ; , dob = outrec->pt[d1.seq]->dob
    ; , age = outrec->pt[d1.seq]->age
    ; , phn = outrec->pt[d1.seq]->phn
    ; , mrn = outrec->pt[d1.seq]->mrn
    ; , orig_encntr_nbr = outrec->pt[d1.seq]->orig_encntr_nbr
    ; , encntr_id = outrec->pt[d1.seq]->encntr_id
    ; , allergy = outrec->pt[d1.seq]->allergy
    ; , gender = outrec->pt[d1.seq]->gender
    ; , last_height = outrec->pt[d1.seq]->last_height
    ; , last_height_dt_tm = outrec->pt[d1.seq]->last_height_dt_tm
    ; , last_dosing_weight = outrec->pt[d1.seq]->last_dosing_weight
    ; , last_dosing_weight_dt_tm = outrec->pt[d1.seq]->last_dosing_weight_dt_tm
    ; , last_weight_meas = outrec->pt[d1.seq]->last_weight_meas
    ; , last_weight_meas_dt_tm = outrec->pt[d1.seq]->last_weight_meas_dt_tm
    ; , dual_modality_ind = outrec->pt[d1.seq]->dual_modality_ind
    , powerplan = trim(substring(0, 100, outrec->pathways[d3.seq]->powerplan), 7)
	, phase = trim(substring(0, 50, outrec->pathways[d3.seq]->phase))
	, pathway_group_id = outrec->pathways[d3.seq]->pathway_group_id
from (dummyt d1 with seq = value(size(outrec->orders, 5)))
    , (dummyt d3 with seq = value(size(outrec->pathways, 5)))
; from (dummyt d1 with seq = value(size(outrec->pt, 5)))
plan d1
join d3 where
    outrec->pathways[d3.seq]->pathway_id = outrec->orders[d1.seq]->pathway_id
    and outrec->pathways[d3.seq]->person_id = outrec->orders[d1.seq]->person_id
with nocounter, separator=" ", format
end
 
 
#end_report
 
end
go
