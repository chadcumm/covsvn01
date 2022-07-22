drop program 2_cs_inactive_tier_assoc go
create program 2_cs_inactive_tier_assoc
 
 
prompt
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
 
 
with OUTDEV
 
 
;free set dup_bop go	001
record dup_bop (
1 cnt = i4
1 org[*]
2 org_id = f8
 
2 tier_col = f8
) ;go	001
 
 
select into "nl:"
bop.organization_id, bop.bill_org_type_cd, count(*)
 
from bill_org_payor bop
 
group by bop.organization_id, bop.bill_org_type_cd
 
having count(*) > 1
 
detail
	dup_bop->cnt = dup_bop->cnt + 1
	stat = alterlist(dup_bop->org, dup_bop->cnt)
	dup_bop->org[dup_bop->cnt]->org_id = bop.organization_id
	dup_bop->org[dup_bop->cnt]->tier_col = bop.bill_org_type_cd
;go
 
 
select into $OUTDEV
bop.org_payor_id,o.org_name,o.active_ind,TIER_COLUMN = uar_get_code_display(bop.bill_org_type_cd),TIER_GROUP = uar_get_code_display(bop.bill_org_type_id)
from bill_org_payor bop, organization o, (dummyt d with seq=value(dup_bop->cnt))
plan d
join bop where bop.organization_id = dup_bop->org[d.seq]->org_id
and bop.bill_org_type_cd = dup_bop->org[d.seq]->tier_col
 
join o where o.organization_id = bop.organization_id
order by o.org_name, bop.bill_org_type_cd, bop.bill_org_type_id
;with format
 
end;001
go
 