/*************************************************************************************************
	Covenant Health Information Technology
	Knoxville, Tennessee
**************************************************************************************************
	Author:				Dan Herren
	Date Written:		December 2021
	Solution:
	Source file name:  	cov_idn_rx_new_order_rpt.prg
	Object name:		cov_idn_rx_new_order_rpt
	CR#:
 
	Program purpose:	Tranlated from Cerner's "idn_rx_new_order_rpt.prg"
	Executing from:		CCL
  	Special Notes:
 
**************************************************************************************************
*  	GENERATED MODIFICATION CONTROL LOG
*
*  	Revision #   Mod Date    Developer             Comment
*  	-----------  ----------  --------------------  -----------------------------------------------
*	001			 Dec 2021	 Dan Herren			   CR 11788
*
*
**************************************************************************************************/
 
DROP PROGRAM cov_idn_rx_new_order_rpt :dba GO
CREATE PROGRAM cov_idn_rx_new_order_rpt :dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"
	, "From date/time" = "SYSDATE"
	, "To date/time" = "SYSDATE"
	, "Select facility" = VALUE("*                                       ")
	, "Select unit" = VALUE("*                                       ")
	, "Medication search (primary/generic)" = ""
	, "Action user search (last name)" = "" 

with OUTDEV, FROMDTTM, TODTTM, FACILITY, UNIT, MED_STR, USER_QUAL
 
DECLARE rpt_begin_dt_tm	= dq8
DECLARE rpt_end_dt_tm 	= dq8
DECLARE fac_cnt 		= i4
DECLARE med_qual_str 	= vc
DECLARE user_qual_str 	= vc
 
SET rpt_begin_dt_tm	= cnvtdatetime($FROMDTTM)
SET rpt_end_dt_tm 	= cnvtdatetime($TODTTM)
SET med_qual_str 	= cnvtupper(trim($MED_STR))
SET user_qual_str 	= cnvtupper(trim($USER_QUAL))
SET cpharm 			= uar_get_code_by("MEANING" ,6000 ,"PHARMACY")
SET cpharmact 		= uar_get_code_by("MEANING" ,106 ,"PHARMACY")
SET cfin 			= uar_get_code_by("MEANING" ,319 ,"FIN NBR")
SET cprimary 		= uar_get_code_by("MEANING" ,6011 ,"PRIMARY")
 

FREE RECORD fac
RECORD fac (
	1 fac [*]
    	2 facility_cd = f8
 	)
 
SELECT DISTINCT INTO "nl:"
  	 cv.code_value
  	,cv.display
FROM PRSNL_ORG_RELTN por
	,LOCATION loc
   	,CODE_VALUE cv
PLAN por
	WHERE por.person_id = reqinfo->updt_id
		AND por.person_id > 0
   		AND por.active_ind = 1
   		AND por.organization_id > 0
   		AND por.end_effective_dt_tm > cnvtdatetime(sysdate)
JOIN loc
	WHERE loc.organization_id = por.organization_id
		AND loc.patcare_node_ind = 1
JOIN cv
	WHERE cv.code_value = loc.location_cd
		AND cv.code_set = 220
		AND cv.active_ind = 1
		AND cv.cdf_meaning = "FACILITY"
ORDER BY cv.display_key
 
HEAD REPORT
   	cnt = 0
 
DETAIL
   	cnt +=1 
   	stat = alterlist(fac->fac, cnt) 
   	fac->fac[cnt].facility_cd = cv.code_value
 
WITH nocounter
 ;end select
 

FREE RECORD ord
RECORD ord (
   	1 ord [*]
    	2 order_id = f8
    	2 encntr_loc_hist_id = f8
 	)
 
SELECT INTO "nl:"
FROM ORDERS o
  	,ORDER_ACTION oa
    ,PRSNL pr
    ,ORDER_INGREDIENT oi
    ,ORDER_CATALOG_SYNONYM ocs
    ,ENCOUNTER e
    ,CODE_VALUE cv
    ,ENCNTR_LOC_HIST elh
    ,CODE_VALUE cv2

PLAN o
	WHERE o.activity_type_cd = cpharmact
   		AND o.orig_order_dt_tm >= cnvtdatetime(rpt_begin_dt_tm)
   		AND o.orig_order_dt_tm <= cnvtdatetime(rpt_end_dt_tm)
   		AND o.orig_ord_as_flag = 0
   		AND o.template_order_id = 0
JOIN oa
   	WHERE oa.order_id = o.order_id
   		AND oa.action_sequence = 1
JOIN pr
   	WHERE pr.person_id = oa.action_personnel_id
   		AND pr.name_last_key = patstring(build("*" ,user_qual_str ,"*"))
JOIN oi
   	WHERE oi.order_id = o.order_id
   		AND oi.action_sequence = 1
JOIN ocs
   	WHERE ocs.catalog_cd = oi.catalog_cd
   		AND ocs.mnemonic_type_cd = cprimary
   		AND cnvtupper(ocs.mnemonic) = patstring(build("*" ,med_qual_str ,"*"))
JOIN e
   	WHERE e.encntr_id = o.encntr_id
JOIN cv
   	WHERE cv.code_value = e.loc_facility_cd
   		AND cv.display IN ($FACILITY)
   		AND expand(fac_cnt ,1 ,size (fac->fac ,5) ,cv.code_value ,fac->fac[fac_cnt].facility_cd)
JOIN elh
	WHERE elh.encntr_id = e.encntr_id
   		AND elh.beg_effective_dt_tm < o.orig_order_dt_tm
   		AND elh.end_effective_dt_tm > o.orig_order_dt_tm
   		AND elh.active_ind = 1
JOIN cv2
   	WHERE cv2.code_value = elh.loc_nurse_unit_cd
   		AND cv2.display IN ($UNIT)

ORDER BY o.order_id
   	,elh.beg_effective_dt_tm DESC
 
HEAD REPORT
   cnt = 0
 
HEAD o.order_id
   	cnt = cnt + 1 
	stat = alterlist(ord->ord ,cnt)  

	ord->ord[cnt].order_id = o.order_id,ord->ord[cnt].encntr_loc_hist_id = elh.encntr_loc_hist_id
 
WITH nullreport
 ;end select
 

FREE RECORD fin
RECORD fin (
   	1 fin [*]
     	2 encntr_id = f8
     	2 fin_nbr = vc
 	)
 
SELECT INTO "nl:"
FROM (DUMMYT d WITH seq = value(size(ord->ord ,5)))
  	,ORDERS o
   	,DUMMYT d2
   	,ENCNTR_ALIAS ea

PLAN d
JOIN o
   	WHERE o.order_id = ord->ord[d.seq].order_id
JOIN d2
JOIN ea
   	WHERE ea.encntr_id = o.encntr_id
   		AND ea.encntr_alias_type_cd = cfin
   		AND ea.active_ind = 1
   		AND (ea.beg_effective_dt_tm < cnvtdatetime(sysdate) 
   		AND ea.end_effective_dt_tm > cnvtdatetime(sysdate))

ORDER BY o.encntr_id
   	,ea.updt_dt_tm DESC
 
HEAD REPORT
   	cnt = 0
 
HEAD o.encntr_id
   	cnt = cnt + 1 
	stat = alterlist(fin->fin,cnt) 
	
	fin->fin[cnt].encntr_id = o.encntr_id ,fin->fin[cnt].fin_nbr = trim(ea.alias)
 
WITH outerjoin = d2
 ;end select
 

SELECT INTO $OUTDEV
  	 fin = substring(1,30,fin->fin[d2.seq].fin_nbr)
  	,patient_name = substring(1,50,p.name_full_formatted)
  	,entry_dt_tm = format(o.orig_order_dt_tm ,"@SHORTDATETIME")
  	,current_status = uar_get_code_display(o.order_status_cd)
  	,order_display =
  		IF ((o.iv_ind = 1))
   			IF ((trim (o.ordered_as_mnemonic) > " ")) 
				trim (o.ordered_as_mnemonic)
   			ELSE 
				trim (o.hna_order_mnemonic)
   			ENDIF
  		ELSE
   			IF ((trim (o.ordered_as_mnemonic) > " ")
   				AND (trim (o.ordered_as_mnemonic) != trim (o.hna_order_mnemonic))) concat (trim (o
      				.hna_order_mnemonic) ," (" ,trim (o.ordered_as_mnemonic) ,")")
   			ELSE 
				trim (o.hna_order_mnemonic)
   			ENDIF
  		ENDIF
	,order_details = substring(1,255,o.clinical_display_line)
  	,entered_by = pr.name_full_formatted
  	,position = uar_get_code_display(pr.position_cd)
  	,current_unit = uar_get_code_display(e.loc_nurse_unit_cd)
  	,current_room = uar_get_code_display(e.loc_room_cd)
  	,current_bed = uar_get_code_display(e.loc_bed_cd)
  	,order_unit = uar_get_code_display(elh.loc_nurse_unit_cd)
  	,order_room = uar_get_code_display(elh.loc_room_cd)
  	,order_bed = uar_get_code_display(elh.loc_bed_cd)
  	,powerplan = check(pc.description)
	,ord_comment = substring(1,3000,replace(replace(lt.long_text, char(13), " ", 0), char(10), " ", 0)) ;001
  	,o.order_id

FROM (DUMMYT d WITH seq = value(size(ord->ord ,5)))
   	,ORDERS o
   	,(DUMMYT d2 WITH seq = value(size(fin->fin ,5)))
   	,ENCOUNTER e
   	,PERSON p
   	,ORDER_ACTION oa
   	,PRSNL pr
  	,ENCNTR_LOC_HIST elh
   	,DUMMYT d3
   	,PATHWAY_CATALOG pc
   	,ORDER_COMMENT oc ;001
   	,LONG_TEXT lt ;001

PLAN d
JOIN o
	WHERE o.order_id = ord->ord[d.seq].order_id
JOIN d2
   	WHERE o.encntr_id = fin->fin[d2.seq].encntr_id
JOIN p
   	WHERE o.person_id = p.person_id
JOIN oa
   	WHERE oa.order_id = o.order_id
   		AND oa.action_sequence = 1
JOIN pr
   	WHERE pr.person_id = oa.action_personnel_id
JOIN e
   	WHERE e.encntr_id = o.encntr_id 
JOIN elh
   	WHERE elh.encntr_loc_hist_id = ord->ord[d.seq].encntr_loc_hist_id 
JOIN d3
JOIN pc
  	WHERE pc.pathway_catalog_id = o.pathway_catalog_id 
JOIN oc ;001
   	WHERE oc.order_id = outerjoin(o.order_id) ;001
JOIN lt ;001
   	WHERE lt.long_text_id = outerjoin(oc.long_text_id) ;001

ORDER BY o.orig_order_dt_tm
   	,order_display
   	,order_details

WITH outerjoin = d3 ,format ,separator = " "
 ;end select
END GO
