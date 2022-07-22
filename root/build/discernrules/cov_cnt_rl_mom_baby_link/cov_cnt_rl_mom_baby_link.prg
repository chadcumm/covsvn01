/*********************************************************************************************
*                                                                                            *
**********************************************************************************************
 
        Source file name:   cov_cnt_rl_mom_baby_link.prg
        Object name:        cov_cnt_rl_mom_baby_link
 
        Product:
        Product Team:
 
        Program purpose:
 
        Tables read:
 
        Tables updated:     n/a
 
        Executing from:     EKS_EXEC_CCL_L Template
 
        Special Notes:
 
 
**********************************************************************************************
*                      GENERATED MODIFICATION CONTROL LOG
**********************************************************************************************
*
* Mod Date          Feature     Engineer        Comment
* --- ----------    -------     -------------   ----------------------------------------------
* 000 09/05/2018                CCUMMIN4        Initial Creation
* 001 01/04/2021                CCUMMIN4        Updated to use person_person_relationship
*********************************************************************************************/
DROP PROGRAM cov_cnt_rl_mom_baby_link  :dba GO
CREATE PROGRAM cov_cnt_rl_mom_baby_link  :dba
 DECLARE script_version = vc WITH protect ,noconstant ("002 12/14/12 cerpdj" )
 DECLARE lstat = i4 WITH protect ,noconstant (0 )
 DECLARE errmsg = c132 WITH protect ,noconstant (fillstring (132 ," " ) )
 DECLARE error_check = i2 WITH protect ,noconstant (error (errmsg ,1 ) )
 DECLARE newborncd = f8 WITH constant (uar_get_code_by_cki ("CKI.CODEVALUE!723871538" ) ) ,protect
 DECLARE gen_lab_cat_cd = f8 WITH public ,constant (uar_get_code_by ("MEANING" ,6000 ,"GENERAL LAB"
   ) )
 DECLARE aborh_cd = f8 WITH constant (uar_get_code_by_cki ("CKI.EC!8431" ) ) ,protect
 DECLARE mompersonid = f8 WITH protect ,noconstant (0 )
 DECLARE momencntrid = f8 WITH protect ,noconstant (0 )
 DECLARE momaborh = c100 WITH protect ,noconstant (fillstring (100 ," " ) )
 SET retval = - (1 )
 /* 001
 SELECT INTO "nl:"
  eer.encntr_id ,
  e.person_id
  FROM (encntr_encntr_reltn eer ),
   (encounter e )
  PLAN (eer
   WHERE (eer.related_encntr_id = link_encntrid )
   AND ((eer.encntr_reltn_type_cd + 0 ) = newborncd ) )
   JOIN (e
   WHERE (eer.encntr_id = e.encntr_id ) )
  DETAIL
   retval = 100 ,
   mompersonid = e.person_id ,
   momencntrid = e.encntr_id ,
   CALL echo (build (" Mom person id   " ,mompersonid ) ) ,
   CALL echo (build (" Mom encntr id   " ,momencntrid ) )
  WITH nocounter
  
 
  select into "nl:"
from
	 (DUMMYT d1 with seq = size(rec->mother ,5))
	,(DUMMYT d2)
	,PERSON_PERSON_RELTN ppr
	,ENCOUNTER e
	,ENCNTR_ALIAS ea
	,PERSON_ALIAS pa
	,PERSON p
 
plan d1	where maxrec(d2,size(rec->mother[d1.seq].baby,5))
 
join d2
 
join ppr where ppr.related_person_id = rec->mother[d1.seq].person_id
	and ppr.person_reltn_cd = MOTHER_VAR ;156
 
join e where e.person_id = ppr.person_id
	and e.encntr_type_cd = NEWBORN_ENCNTR_TYPE_VAR ; 2555267433
	and (e.reg_dt_tm between cnvtdatetime(rec->mother[d1.seq].preg_start_dt)
		and cnvtdatetime(rec->mother[d1.seq].preg_end_dt))
	and e.active_ind = 1
 */
 
 SELECT INTO "nl:"
  ppr.person_id
  ,p.person_id
  FROM (PERSON_PERSON_RELTN ppr ),
   (person p )
  PLAN (ppr
   WHERE (ppr.related_person_id = link_presonid )
   AND ((ppr.related_person_reltn_cd + 0 ) = 670847 ) ) ;     670847.00	Child	CHLD_RESP	Child/Insured Responsible
   JOIN (p
   WHERE (ppr.person_id = p.person_id ) )
  DETAIL
   retval = 100 ,
   mompersonid = e.person_id ,
  ;; momencntrid = e.encntr_id ,
   CALL echo (build (" Mom person id   " ,mompersonid ) ) 
  ;; CALL echo (build (" Mom encntr id   " ,momencntrid ) )
  WITH nocounter
 ;end select
 SET error_check = error (errmsg ,0 )
 IF ((error_check != 0 ) )
  SET log_misc1 = "ERROR"
  GO TO exit_script
 ENDIF
 IF ((curqual = 0 ) )
  SET retval = 0
 ENDIF
#set_return
 IF ((retval = 100 ) )
  SET log_personid = mompersonid
  SET log_encntrid = momencntrid
  SET log_misc1 = "100"
 ELSEIF ((retval = 0 ) )
  SET log_misc1 = "0"
 ELSE
  SET log_misc1 = "ERROR"
 ENDIF
 CALL echo (build ("log_misc1 ....." ,log_misc1 ) )
 CALL echo (build ("log_personid ..." ,log_personid ) )
 ;CALL echo (build ("log_enntrid ..." ,log_encntrid ) )
 CALL echo (build ("retval ........" ,retval ) )
#exit_script
 CALL echo ("Ending script....." )
END GO

