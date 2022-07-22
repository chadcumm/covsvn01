drop program op_celr_mobj_driver go
create program op_celr_mobj_driver
;;;
/*
 *  ---------------------------------------------------------------------------------------------
 *  Script Name:  celr_mobj_driver
 *  Description:  Driver Script for celr_mobj_oru_out
 *  Type:  Open Engine Modify Object Script
 *  ---------------------------------------------------------------------------------------------
 *  Author:  CERNER
 *  Domain:
 *  Creation Date:
 *  ---------------------------------------------------------------------------------------------
 */

call echo(build("start script:",trim("op_celr_mobj_driver"),char(0) ))
call echo(build(">declare",char(0) ))
declare encntr = i4
declare clia_nbr = vc
declare org_name = vc
declare get_double_value(string_meaning) = i4
call echo(build("<declare",char(0) ))
 
call echo(build(">encntr=",trim(cnvtstring(encntr)),char(0) ))
set encntr = cnvtreal(get_double_value("encntr_id"))
call echo(build(">encntr=",trim(cnvtstring(encntr)),char(0) ))
 
/***************************************
BEGIN CUSTOM CODE SECTION (ORU v2.5 TDB)
***************************************/
 
 
/***************************************
       END CUSTOM CODE SECTION
***************************************/
 
call echo(build(">celr_mobj_oru_out start",char(0) ))
execute cov_celr_mobj_oru_out
call echo(build("<celr_mobj_oru_out start",char(0) ))
 
/* Get CLIA Number */
/*
call echo(build(">Get CLIA Number start",char(0) ))
select into "nl:"
from
  order_serv_res_container oc,
  service_resource sr,
  resource_group rg,
  code_value cv
plan oc where
  oc.order_id = cnvtreal(oen_reply->PERSON_GROUP [1]->RES_ORU_GROUP [1]->OBR->placer_ord_nbr [1]->entity_id)
join rg where
  rg.child_service_resource_cd = oc.service_resource_cd
join sr where
  sr.service_resource_cd = rg.parent_service_resource_cd
  and sr.active_ind = 1
join cv where
  cv.code_value = sr.service_resource_cd
detail
  clia_nbr = sr.clia_number_txt
with nocounter, maxrec = 1
call echo(build("<Get CLIA Number start",char(0) ))
*/


/* Get Org_name via encounter_id */
call echo(build(">Get Org_name via encounter_id",char(0) ))
/*

select into "nl:"
from
            encounter   e
            , organization   o
plan e where e.encntr_id =    encntr
join o where o.organization_id = e.organization_id
detail
    org_name = o.org_name
with nocounter, maxrec = 1
call echo(build("<Get Org_name via encounter_id",char(0) ))
*/
 
call echo(build(">org_name=",trim(org_name),char(0) ))
call echo(build(">clia_nbr=",trim(clia_nbr),char(0) ))
 
call echo(build(">Setting OEN_REPLY",char(0) ))
Set oen_reply->CONTROL_GROUP [1]->MSH [1]->sending_facility->name_id = trim(org_name)
Set oen_reply->CONTROL_GROUP [1]->MSH [1]->sending_facility->univ_id = trim(clia_nbr)
Set oen_reply->CONTROL_GROUP [1]->MSH [1]->sending_facility->univ_id_type = "CLIA"
call echo(build(">oen_reply->CONTROL_GROUP [1]->MSH [1]->sending_facility->name_id=",
	trim(oen_reply->CONTROL_GROUP [1]->MSH [1]->sending_facility->name_id),char(0) ))
call echo(build(">oen_reply->CONTROL_GROUP [1]->MSH [1]->sending_facility->univ_id=",
	trim(oen_reply->CONTROL_GROUP [1]->MSH [1]->sending_facility->univ_id),char(0) ))
call echo(build(">oen_reply->CONTROL_GROUP [1]->MSH [1]->sending_facility->univ_id_type=",
	trim(oen_reply->CONTROL_GROUP [1]->MSH [1]->sending_facility->univ_id_type),char(0) ))
call echo(build("<Setting OEN_REPLY",char(0) ))
 
;*********************************
;** GET_DOUBLE_VALUE Subroutine **
;*********************************
subroutine get_double_value (string_meaning)
  call echo(build("->get_double_value:",trim(string_meaning),char(0) ))
  declare eso_idx = i4
  declare list_size = i4
  set eso_idx = 0
  set list_size = 0
  set stat2 = (validate (oen_reply->cerner, "nocernerarea"))
  if (stat2 = "nocernerarea")
    return ("")
  else
    set eso_idx = 0
    set list_size = 0
    set list_size = size (oen_reply->cerner->doubleList, 5)
    if(list_size > 0)
      set eso_x = 1
      for (eso_x = eso_x to list_size)
        if(oen_reply->cerner->doubleList[eso_x]->strMeaning = string_meaning)
          set eso_idx = eso_x
        endif
      endfor
    endif
    if(eso_idx > 0)
      return (oen_reply->cerner->doubleList[eso_idx]->dVal)
    else
      return (0)
    endif
  endif
  call echo(build("<-get_double_value:",trim(string_meaning),char(0) ))
end  ;get_double_value
;;;
set filename = build("cclscratch:",cnvtlower(trim(curprog))
										,"_",format(cnvtdatetime(curdate, curtime3)
										,"yyyy_mm_dd_hh_mm_ss;;d")
										,".log"
										)
call echojson(oen_reply,filename)
call echo(build("end script:",trim(curprog),char(0) ))
end go
