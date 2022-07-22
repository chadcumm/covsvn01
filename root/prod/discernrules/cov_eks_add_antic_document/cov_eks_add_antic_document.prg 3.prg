drop program cov_eks_add_antic_document:dba go
create program cov_eks_add_antic_document:dba

set trace rdbplan
call echo("INSIDE cov_eks_add_antic_document")
%i cclsource:eks_tell_ekscommon.inc
%I CCLSOURCE:EKS_RPRQ1000012.INC

/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

;Variables for creating the anticipated document
declare performed_prsnl_id    = f8 with public, noconstant(0.0)
declare action_prsnl_id       = f8 with public, noconstant(0.0)

;Variable for determining deficient prsnl
declare DeficientPrsnl        = vc with public, noconstant("")
declare DeficientPrsnlCd      = f8 with public, noconstant(0.0)
declare eksinx                = i4 with public, noconstant(0) ;28485
declare disch_order_cd		  = f8 with public, noconstant(0.0)
declare order_action_cd     = f8 with public, noconstant(0.0)

declare logmsg                = vc with public, noconstant("")

;/**************************************************************
;; DVDev Start Coding
;**************************************************************/
set eksinx   = eks_common->event_repeat_index ;28485
set PERSONID = event->qual[eksinx].person_id ;28485A
set ENCNTRID = event->qual[eksinx].encntr_id ;28485A

call echo(build("PERSONID: ", PersonId))
call echo(build("ENCNTRID: ", EncntrId))

/*** CREATE A NEW ANTICIPATED DOCUMENT ***/
;Limit the prsnl to the desired parameter - attending/admitting
call echo(build("DEFICIENT PERSONNEL = ", DEFICIENT_PERSONNEL))
if (DEFICIENT_PERSONNEL = "DISCHDOC")
  set DeficientPrsnl = "ATTENDDOC"
  set DeficientPrsnlCd = uar_get_code_by("MEANING",333,"ATTENDDOC")
elseif (DEFICIENT_PERSONNEL = "ADMITDOC")
  set DeficientPrsnl = "ADMITDOC"
  set DeficientPrsnlCd = uar_get_code_by("MEANING",333,"ADMITDOC")
  call ECHO("FINDING ADMITTING")
else
  set DeficientPrsnl = "ATTENDDOC"
  set DeficientPrsnlCd = uar_get_code_by("MEANING",333,"ATTENDDOC")
  call echo("FINDING ATTENDING")
endif
if (DEFICIENT_PERSONNEL = "DISCHDOC")
	set disch_order_cd = uar_get_code_by("DISPLAY",200,"1Discharge Patient")
  if (disch_order_cd <= 0.0)
    set logmsg = "Unable to find Discharge Order build"
    set EKSData->tQual[tCurIndex].qual[CurIndex].logging = logmsg
    return (0)
  endif
  set order_action_cd = uar_get_code_by("MEANING",6003,"ORDER")
  if (order_action_cd <= 0.0)
    set logmsg = "Unable to find order action cd of ORDER"
    set EKSData->tQual[tCurIndex].qual[CurIndex].logging = logmsg
    return (0)
  endif
  select into "nl:"
  from 
    orders o
    ,order_action oa
  plan o
    where o.encntr_id = EncntrId
    and   o.person_id = PersonId
    and   o.catalog_cd = disch_order_cd
    and   o.order_status_cd in(
          ;2542.00	;Canceled
          2543.00	;Completed
          ;2544.00	;Voided
          ;2545.00	;Discontinued
          ;2546.00	;Future
          ,2547.00	;Incomplete
          ,2548.00	;InProcess
          ,2549.00	;On Hold, Med Student
          ,2550.00	;Ordered
          ,643466.00	;Pending Complete
          ,2551.00	;Pending Review
          ;2552.00	;Suspended
          ;614538.00	;Transfer/Canceled
          ;2553.00	;Unscheduled
          ;643467.00	;Voided With Results
          )
  join oa
    where oa.order_id = o.ORDER_ID
    and   oa.action_type_cd = order_action_cd
  order by
    o.orig_order_dt_tm desc
   ,oa.action_dt_tm desc
   ,o.Encntr_id
  head o.Encntr_id
    performed_prsnl_id = oa.ordering_provider_id
    action_prsnl_id = oa.ordering_provider_id
  with nocounter
endif

if ((DEFICIENT_PERSONNEL != "DISCHDOC") or (performed_prsnl_id = 0.0))
	select into "nl:"
	from Encntr_Prsnl_Reltn EPR
	plan EPR
		  where EPR.Encntr_Prsnl_R_Cd = DeficientPrsnlCd
	    and EPR.Encntr_Id = ENCNTRID ;28485A
	    and EPR.Active_Ind = 1
	    and EPR.Beg_Effective_Dt_Tm <= cnvtdatetime(curdate,curtime3) ;123858
	    and EPR.End_Effective_Dt_Tm > cnvtdatetime(curdate,curtime3) ;123858
	    and EPR.internal_seq = 0 ;123858
	order by cnvtdatetime(epr.updt_dt_tm) desc ;123858
	detail
	  performed_prsnl_id = EPR.Prsnl_Person_Id
	  action_prsnl_id = EPR.Prsnl_Person_Id
	with NoCounter  
endif

  	
  if (performed_prsnl_id = 0.0)
    if (DEFICIENT_PERSONNEL = "DISCHDOC")
      call echo(build("Unable to find discharging physician for encntr_id = ", EncntrId))
      set logmsg = "Unable to find discharging doctor."
	  elseif (DeficientPrsnl = "ADMITDOC")
      call echo(build("Unable to find admitting physician for encntr_id = ", EncntrId))
      set logmsg = "Unable to find admitting doctor."
    else
      call echo(build("Unable to find attending physician for encntr_id = ", EncntrId))
      set logmsg = "Unable to find attending doctor."
    endif

    if ((tCurIndex > 0) and (CurIndex > 0))
      set EKSData->tQual[tCurIndex].qual[CurIndex].logging = logmsg
    endif
    return (0)
  endif

if (DeficientPrsnl = "ADMITDOC")
  call echo(build("ADMITTING FOUND : PRSNL_ID :", performed_prsnl_id))
else
  if (DEFICIENT_PERSONNEL = "DISCHDOC")
  	call echo(build("DISCHDOC FOUND : PRSNL_ID :", performed_prsnl_id))
  else
  	call echo(build("ATTENDING FOUND : PRSNL_ID :", performed_prsnl_id))
  endif
endif

execute him_eks_add_antic_doc_core

set logmsg = "Finished with Him_add_antic_document script."
call echo(logmsg,4,0)
return (100)

end
go


