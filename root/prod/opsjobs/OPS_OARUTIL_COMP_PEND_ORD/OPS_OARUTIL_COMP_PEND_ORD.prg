DROP PROGRAM OPS_OARUTIL_COMP_PEND_ORD:dba go
CREATE PROGRAM OPS_OARUTIL_COMP_PEND_ORD:dba
DECLARE SCRIPT_NAME = vc with protect, constant("OPS_OARUTIL_COMP_PEND_ORD")
DECLARE pend_comp_orders(mode=vc,mapkey=f8,mapval=i2) = i4 with map="HASH" 
DECLARE look_back_days_start = i4 with noconstant(15), protected
DECLARE look_back_days_range = i4 with noconstant(5), protected
DECLARE before_count = i4 with noconstant(0), protected
if (reflect(parameter(1,0)) > " ")
 set look_back_days_start = cnvtint(parameter(1,0))
 if (look_back_days_start < 1)
   go to exit_script
 endif
endif
if (reflect(parameter(2,0)) > " ")
 set look_back_days_range = cnvtint(parameter(2,0))
 if (look_back_days_range < 1)
   go to exit_script
 endif
endif
SELECT 
 into "nl:" 
FROM 
 ORDERS O 
WHERE 
 O.ORDER_STATUS_CD=VALUE(UAR_GET_CODE_BY("MEANING",6004,"PENDING"))
 AND O.STATUS_DT_TM BETWEEN CNVTDATETIME(curdate-look_back_days_start-look_back_days_range,0) 
 AND CNVTDATETIME(curdate-look_back_days_start,0)
 AND O.CATALOG_TYPE_CD = VALUE(UAR_GET_CODE_BY("MEANING",6000,"PHARMACY"))
ORDER BY O.ORDER_ID 
DETAIL
 stat = pend_comp_orders("A",O.ORDER_ID,1)
WITH NOCOUNTER
if (curqual > 0)
 declare mapkey = f8 
 declare mapval = i2 
 set stat = pend_comp_orders("L",1,mapkey,mapval) 
 while (stat = 1)
  EXECUTE OARUTIL_COMP_PEND_ORD mapkey, mapkey
  set stat = pend_comp_orders("N",mapkey,mapval) 
 endwhile
else
  go to exit_script
endif
set ord_updt_cnt = pend_comp_orders("C")
#exit_script
 if (look_back_days_range < 1 or look_back_days_start < 1)
  call echo("Invalid parmaters provided")
 endif
 
 if (curqual = 0)
  call echo("No orders qualify to be cleaned up")
 endif
end
go
