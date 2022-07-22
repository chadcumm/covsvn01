/***********************Change Log*************************
VERSION  DATE       ENGINEER            COMMENT
-------	 -------    -----------         ------------------------
1.0		5/2/2018	Ryan Gotsche		Initial Release
**************************************************************/
 
/***********************PROGRAM NOTES*************************
Description - Updates supply charges to have CDM description.
 
Tables Read: BILL_ITEM_MODIFIER, BILL_ITEM
 
Tables Updated: BILL_ITEM_MODIFIER
**************************************************************/
drop program idn_ops_cs_supply_cdm_desc go
create program idn_ops_cs_supply_cdm_desc
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare 48_INACTIVE = f8 with Constant(uar_get_code_by_cki("CKI.CODEVALUE!2670")),protect
declare 48_ACTIVE = f8 with Constant(uar_get_code_by_cki("CKI.CODEVALUE!2669")),protect
 
;Record for missing charges
record Missing_cs_desc (
  1 Qual [*]
    2 bill_item_id = f8)
 
declare countloop = i4
declare count = i4
declare maxcount = i4
 
set count = 0
set countloop = 0
set maxcount = 0
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
;Find Missing Descriptions
Select into "nl:"
from bill_item_modifier m
where m.active_ind = 1
and m.active_status_cd = 48_ACTIVE
and m.updt_dt_tm > cnvtlookbehind("3,d")
and m.key7 = " "
and (m.key6 = "MM*"
or m.key6 = "PR*"
or m.key6 = "OR*")
 
head report
  stat = alterlist(Missing_cs_desc->Qual, 100)
detail
  count = count + 1
 	if(mod(count,100) = 1 and count != 1)
    stat = alterlist(Missing_cs_desc->qual[count],count + 99)
 	endif
  		Missing_cs_desc->qual[count]->bill_item_id = m.bill_item_id
 
foot report
  stat = alterlist(Missing_cs_desc->qual,count)
with nocounter
 
Set maxcount = count
set count = 0
 
While (countloop < maxcount) ; perform update
set countloop = countloop + 1
set count = count + 1
 
;Update Description of Missing Supplies
 
update into bill_item_modifier b
set b.key7 = (select i.ext_description from bill_item i where b.bill_item_id = i.bill_item_id),
updt_task = 99999,
updt_dt_tm = cnvtdatetime(curdate,curtime3),
updt_id = 12397986.00, ;MSCM Contributor System
updt_cnt = updt_cnt+1
where b.active_ind = 1
and b.active_status_cd = 48_ACTIVE
and (b.key6 = "MM*"
or b.key6 = "PR*"
or b.key6 = "OR*")
and b.key7 = " "
and b.bill_item_id = Missing_cs_desc->qual[count]->bill_item_id
 
ENDWHILE
 
COMMIT
END
GO
