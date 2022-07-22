 
/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha
	Date Written:		May'2019
	Solution:			Quality
	Source file name:	      cov_phq_leapf_cpoe_scorecard.prg
	Object name:		cov_phq_leapf_cpoe_scorecard
	Request#:			4549
	Program purpose:	      CPOE Scorecard for all facility
	Executing from:		DA2
 	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_phq_leapf_cpoe_scorecard:DBA go
create program cov_phq_leapf_cpoe_scorecard:DBA
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE"
 
with OUTDEV, start_datetime, end_datetime
 
;--------------------------------------------------------------------------------------------------
;Prompt Validation

 IF ((month (cnvtdatetime ( $START_DATETIME ) ) != month (cnvtdatetime ( $END_DATETIME ) ) ) )
  SELECT INTO  $OUTDEV
   error_message = "Date range should be in the same month, try again" ,
   start_date =  $START_DATETIME ,
   end_date =  $END_DATETIME
   FROM (dummyt )
   WITH format ,separator = " "
 ELSE ; continue with script
 
  DECLARE action_seq_var = i4 WITH noconstant (0 )
  DECLARE inpatient_var = f8 WITH constant (uar_get_code_by ("DISPLAY" ,71 ,"Inpatient" ) ) ,protect
  DECLARE initcap () = c100
  DECLARE username = vc WITH protect
  DECLARE getmonth ((imonth = i4 ) ) = null
  DECLARE month_var = vc
  DECLARE sm = i2
  DECLARE em = i2
  DECLARE mcount = i2

;--------------------------------------------------------------------------------------------------
 
  
  RECORD cpoe (
    1 report_ran_by = vc
    1 list [* ]
      2 month = i2
      2 month_name = vc
      2 facility = vc
      2 lp_neumarator = f8
      2 lp_denominator = f8
      2 lp_percent_compliance = f8
  )
  
  
  RECORD month (
    1 list [* ]
      2 imonth = i2
      2 month_name = vc
  )
  
 ;--------------------------------------------------------------------------------------------------
 
  SET sm = month (cnvtdatetime ( $START_DATETIME ) )
  SET em = month (cnvtdatetime ( $END_DATETIME ) )
  SET mcount = 0
  
  WHILE ((sm <= em ) )
   SELECT INTO "nl:"
    FROM (dummyt d )
    DETAIL
     mcount +=1 ,
     CALL alterlist (month->list ,mcount ) ,
     CASE (sm )
      OF 1 :
       month_var = "January"
      OF 2 :
       month_var = "February"
      OF 3 :
       month_var = "March"
      OF 4 :
       month_var = "April"
      OF 5 :
       month_var = "May"
      OF 6 :
       month_var = "June"
      OF 7 :
       month_var = "July"
      OF 8 :
       month_var = "August"
      OF 9 :
       month_var = "September"
      OF 10 :
       month_var = "October"
      OF 11 :
       month_var = "November"
      OF 12 :
       month_var = "December"
     ENDCASE
     ,month->list[mcount ].month_name = trim (month_var ) ,
     month->list[mcount ].imonth = sm
    WITH nocounter
      SET sm = (sm + 1 )
  ENDWHILE
  
 ;--------------------------------------------------------------------------------------------------
 
  SELECT INTO "NL:"
   FROM (prsnl p )
   WHERE (p.person_id = reqinfo->updt_id )
   DETAIL
    cpoe->report_ran_by = p.username
   WITH nocounter
   
;--------------------------------------------------------------------------------------------------
   
  SELECT DISTINCT INTO "nl:"
   mon = month->list[d.seq ].imonth ,
   mon_name = month->list[d.seq ].month_name ,
   fac = trim (uar_get_code_display (i.loc_facility_cd ) ) ,
   lp_numa = sum (i.numerator ) OVER(
   PARTITION BY month->list[d.seq ].imonth ,
   i.loc_facility_cd ) ,
   lp_deno = sum (i.denominator ) OVER(
   PARTITION BY month->list[d.seq ].imonth ,
   i.loc_facility_cd )
   FROM (dummyt d WITH seq = size (month->list ,5 ) ),
    (
    (
    (SELECT DISTINCT
     e.loc_facility_cd ,
     e.encntr_id ,
     e.person_id ,
     o.order_id ,
     o.orig_order_dt_tm ,
     o.order_mnemonic ,
     numerator = evaluate2 (
      IF ((oa.communication_type_cd = 2560 ) ) 1
      ELSEIF ((oa.communication_type_cd = 2561 ) ) 1
      ELSEIF ((oa.communication_type_cd = 2562 ) ) 1
      ELSEIF ((oa.communication_type_cd = 2576706321 ) ) 1
      ELSEIF ((oa.communication_type_cd = 2553560097 ) ) 1
      ELSEIF ((oa.communication_type_cd = 2553560089 ) ) 1
      ELSEIF ((oa.communication_type_cd = 20094437.00 ) ) 1
      ELSE 0
      ENDIF
      ) ,
     denominator = evaluate2 (
      IF ((oa.communication_type_cd = 2560 ) ) 1
      ELSEIF ((oa.communication_type_cd = 2561 ) ) 1
      ELSEIF ((oa.communication_type_cd = 2562 ) ) 1
      ELSEIF ((oa.communication_type_cd = 2576706321 ) ) 1
      ELSEIF ((oa.communication_type_cd = 2553560097 ) ) 1
      ELSEIF ((oa.communication_type_cd = 2553560089 ) ) 1
      ELSEIF ((oa.communication_type_cd = 20094437.00 ) ) 1
      ELSEIF ((oa.communication_type_cd = 54416801.00 ) ) 1
      ELSE 0
      ENDIF
      )
     FROM (encounter e ),
      (orders o ),
      (order_action oa )
     WHERE (e.loc_facility_cd IN (2552503635.00 ,
     21250403.00 ,
     2552503653.00 ,
     2552503639.00 ,
     2552503613.00 ,
     2553765579.00 ,
     2552503645.00 ,
     2552503649.00 ) )
     AND (e.encntr_type_cd = inpatient_var )
     AND (e.active_ind = 1 )
     AND (e.encntr_id != 0.00 )
     AND (o.encntr_id = e.encntr_id )
     AND (o.active_ind = 1 )
     AND (o.med_order_type_cd != 0.00 )
     AND (o.template_order_flag != 4 )
     AND (o.orig_order_dt_tm BETWEEN cnvtdatetime ( $START_DATETIME ) AND cnvtdatetime (
       $END_DATETIME ) )
     AND NOT ((o.catalog_cd IN (2552703197 ,
     47583263 ,
     165382375 ,
     2561119727 ,
     165382565 ,
     165382675 ,
     165382689 ,
     2553018573 ,
     2553018583 ,
     2553018603 ,
     2553018323 ,
     165382661 ,
     165382589 ,
     2554793611 ,
     165382707 ,
     165382727 ,
     21267059 ,
     21267063 ,
     21267067 ,
     2549885359 ,
     2575842575 ,
     2575843071 ,
     2575842529 ,
     25469175 ,
     2557642447 ,
     2561931299 ,
     2575805731 ,
     2561930481 ,
     2557648183 ,
     2561955475 ,
     25471495 ,
     25471519 ,
     24591363 ,
     2549886971 ,
     2575841511 ,
     2575960697 ,
     25473521 ,
     2549888743 ,
     2552610353 ,
     2563538799 ,
     25463731 ,
     2563394971 ,
     2575841071 ,
     165375843 ,
     165376027 ,
     21266999 ,
     2579380153 ,
     165381811 ,
     108665841 ,
     108649991 ,
     108635085 ,
     34998213 ,
     2578713535 ,
     2557870887 ,
     2557870909 ,
     2575842903 ,
     2557731363 ,
     2560158023 ,
     24300177 ,
     24300189 ,
     24300186 ,
     24300168 ,
     24300192 ,
     24300216 ,
     24300198 ,
     2549890863 ,
     44933843 ,
     24300195 ,
     25474617 ,
     2557727517 ,
     2557648751 ,
     161252229 ,
     2557666171 ,
     24592231 ,
     2554793823 ,
     56622607 ,
     2557728325 ,
     257079695 ,
     2557618729 ,
     257618317 ,
     165381905 ,
     165381929 ,
     165381947 ,
     165381967 ) ) )
     AND (oa.order_id = o.order_id )
     AND (oa.action_sequence = 1 )
     AND (oa.communication_type_cd IN (19468404 ,
     20094437 ,
     681544 ,
     54416801 ,
     2576706321 ,
     2553560097 ,
     2560 ,
     2553560089 ,
     2561 ,
     2562 ) )
     WITH sqltype ("f8" ,"f8" ,"f8" ,"f8" ,"dq8" ,"vc" ,"i2" ,"i2" ) ) )
    i )
    
   PLAN (d )
    JOIN (i WHERE (month (i.orig_order_dt_tm ) = month->list[d.seq ].imonth ) )
   ORDER BY mon ,    fac
   
   HEAD REPORT
    cnt = 0
   HEAD i.loc_facility_cd
    cnt +=1 ,
    CALL alterlist (cpoe->list ,cnt ) ,cpoe->list[cnt ].month = mon ,cpoe->list[cnt ].month_name =
    mon_name ,cpoe->list[cnt ].facility = fac ,cpoe->list[cnt ].lp_denominator = lp_deno ,cpoe->list[
    cnt ].lp_neumarator = lp_numa ,cpoe->list[cnt ].lp_percent_compliance = ((lp_numa * 100 ) /
    lp_deno )
   FOOT  i.loc_facility_cd
    CALL alterlist (cpoe->list ,cnt )
   WITH nocounter

;--------------------------------------------------------------------------------------------------

  CALL echorecord (cpoe )
  
;--------------------------------------------------------------------------------------------------
  
  SELECT DISTINCT INTO value ( $OUTDEV )
   month = substring (1 ,30 ,cpoe->list[d1.seq ].month_name ) ,
   facility = substring (1 ,30 ,cpoe->list[d1.seq ].facility ) ,
   numerator = cpoe->list[d1.seq ].lp_neumarator ,
   denominator = cpoe->list[d1.seq ].lp_denominator ,
   percent_compliance = build2 (cpoe->list[d1.seq ].lp_percent_compliance ," %" )
   FROM (dummyt d1 WITH seq = size (cpoe->list ,5 ) )
   PLAN (d1 )
   ORDER BY month ,    facility
   WITH nocounter ,separator = " " ,format
  
 ENDIF ;prompt validation
 
END GO 
