 
 
drop program cov_gstest5:dba go
create program cov_gstest5:dba
 
prompt 
	"Output to File/Printer/MINe" = "MINE"   ;* Enter or select the printer or file name to send this report to. 

with OUTDEV
 
;====================================================================================================
;Primary or Secondary Insurance finding

select distinct into $outdev
h.*
from authorization au
	,auth_detail ad
	,encntr_plan_reltn epr
	;,person_person_reltn ppr
	,encntr_person_reltn epr2
	,health_plan h
	;,address a2
	;,phone ph2
	;,person_alias pa
	;,person p
	;,encntr_info ei ;;encounter notes
	;,long_text lt ;;encounter notes
	,encounter e
	;,dummyt d

plan epr where epr.encntr_id = 128213503.00
	and epr.active_ind = 1
	and epr.priority_seq = 1;Primary ;2 Secondary
	and epr.beg_effective_dt_tm <= cnvtdatetime(curdate,curtime3)
	and epr.end_effective_dt_tm >= cnvtdatetime(curdate,curtime3)

join e where e.encntr_id = epr.encntr_id

join au where au.encntr_id = outerjoin(epr.encntr_id)
	and au.health_plan_id = outerjoin(epr.health_plan_id)
	and au.auth_type_cd = outerjoin(9769.00) ;Authorization

join ad where ad.authorization_id = outerjoin(au.authorization_id)
	and ad.active_ind = outerjoin(1)
	and ad.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
	and ad.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))

join h where h.health_plan_id = outerjoin(epr.health_plan_id)
	and h.active_ind = outerjoin(1)
	and h.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
	and h.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))

join epr2 where epr2.encntr_id = outerjoin(epr.encntr_id)
	and epr2.PERSON_RELTN_TYPE_CD = outerjoin(1158)
	and epr2.active_ind = outerjoin(1)
	and epr2.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
	and epr2.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
/*
join p where p.person_id = outerjoin(epr2.related_person_id)
	and p.active_ind = outerjoin(1)

join pa where pa.person_id = outerjoin(p.person_id)
	and pa.person_alias_type_cd = outerjoin(18)
	and pa.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
	and pa.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
	and pa.active_ind = outerjoin(1)

/*
join a2 where a2.parent_entity_id = outerjoin(epr.person_plan_reltn_id) ;outerjoin(h.health_plan_id)
	and a2.parent_entity_name = outerjoin("PERSON_PLAN_RELTN") ;outerjoin("HEALTH_PLAN")
	and a2.address_type_cd = outerjoin(754.00) ;Business
	and a2.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
	and a2.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
	and a2.active_ind = outerjoin(1)

join ph2 where ph2.parent_entity_id = outerjoin(epr.person_plan_reltn_id) ;outerjoin(h.health_plan_id)
	and ph2.parent_entity_name = outerjoin("PERSON_PLAN_RELTN") ;outerjoin("HEALTH_PLAN")
	and ph2.phone_type_cd = outerjoin(163.00);Business
	and ph2.beg_effective_dt_tm <= outerjoin(cnvtdatetime(curdate,curtime3))
	and ph2.end_effective_dt_tm >= outerjoin(cnvtdatetime(curdate,curtime3))
	and ph2.active_ind = outerjoin(1)

;;insurance notes

/*join ei where ei.encntr_id = outerjoin(epr.encntr_id)
	and ei.info_type_cd = outerjoin(1169.00);	Comment
	and ei.active_ind = outerjoin(1)

join lt where lt.long_text_id = outerjoin(ei.long_text_id)
	and lt.active_ind = outerjoin(1)

join d */

;order by

with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d")



#exitscript
 
end
go
 
