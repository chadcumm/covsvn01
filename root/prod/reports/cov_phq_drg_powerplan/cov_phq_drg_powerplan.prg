/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
	Author:			Geetha Paramasivam
	Date Written:		Nov'2022
	Solution:			Quality
	Source file name:	      cov_phq_drg_powerplan.prg
	Object name:		cov_phq_drg_powerplan
	Request#:			
	Program purpose:		
	Executing from:		DA2
 	Special Notes:		Detail and summary
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			Comment
----------	--------------------	----------------------------------------------------------------------------
11/11/22    Geetha    CR#	Detail report Initial release

****************************************************************************************************************/
 
drop program cov_phq_drg_powerplan:dba go
create program cov_phq_drg_powerplan:dba

prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Order Date/Time" = "SYSDATE"
	, "End Order Date/Time" = "SYSDATE"
	, "Select Facility" = 0
	, "Report Type" = 1
	, "Position Type" = 0 

with OUTDEV, start_datetime, end_datetime, acute_facility_list, repo_type, 
	pos_type



/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/

declare opr_fac_var = vc with noconstant(' ')
declare opr_pos_var = vc with noconstant(' ')

;Facility variable
if(substring(1,1,reflect(parameter(parameter2($acute_facility_list),0))) = "l");multiple values were selected
	set opr_fac_var = "in"
elseif(parameter(parameter2($acute_facility_list),1)= 0.0)	;all[*] values were selected
	set opr_fac_var = "!="
else									;a single value was selected
	set opr_fac_var = "="
endif


;Position variable
if(substring(1,1,reflect(parameter(parameter2($pos_type),0))) = "l");multiple values were selected
	set opr_pos_var = "in"
elseif(parameter(parameter2($pos_type),1)= 0.0)	;all[*] values were selected
	set opr_pos_var = "!="
else									;a single value was selected
	set opr_pos_var = "="
endif


/**************************************************************
; DVDev Start Coding
**************************************************************/

Record pat(
	1 rec_cnt = i4
	1 plist[*]
		2 facility = vc
		2 fin = vc
		2 personid = f8
		2 encntrid = f8
		2 pat_name = vc
		2 olist[*]
			3 drg_cd = vc
			3 drg_des = vc
			3 nomen_id = f8
			3 powerplan_name = vc
			3 orderdt = vc
			3 orderid = f8
			3 order_nemon = vc
			3 order_pr_id = f8
			3 order_supervising_pr_id = f8
			3 pr_name = vc
			3 pr_position = vc
	)

;--------------------------------------------------------------------------------------------------------
;Patient population

select into $outdev
d.encntr_id, drg = n.source_identifier, drg_description = n.source_string
, powerplan = p.description, p.order_dt_tm ';;q', o.pathway_catalog_id
, o.order_id, o.orig_order_dt_tm ';;q', o.order_mnemonic, oa.order_provider_id;, pr.name_full_formatted, pr.position_cd

from  encounter e
	, nomenclature n
	, drg d
	, pathway p 
	, orders o
	, order_action oa
	, prsnl pr

plan e where operator(e.loc_facility_cd, opr_fac_var, $acute_facility_list)
	and e.active_ind = 1

join d where d.encntr_id = e.encntr_id
	;and d.active_ind = 1
	;and d.encntr_id = 131827296.00

join n where n.nomenclature_id = d.nomenclature_id
	and n.source_identifier in("57" ,"73" ,"74" ,"87" ,"88" ,"89" ,"90"  ,"102" ,"103" 
		,"149" ,"176" ,"177" ,"178" ,"179" ,"190" ,"191" ,"192" ,"193" ,"194" ,"195" ,"196" ,"197" ,"198" ,"202" 
		,"203" ,"204" ,"205" ,"206" ,"291" ,"292" ,"293" ,"294" ,"295" ,"305" ,"312" ,"370" ,"373" ,"387" ,"390" 
		,"391" ,"392" ,"394" ,"395" ,"440" ,"552" ,"556" ,"557" ,"558" ,"594" ,"596" ,"602" ,"603" ,"605" ,"606" 
		,"607" ,"607" ,"639" ,"675" ,"689" ,"690" ,"694" ,"695" ,"696" ,"698" ,"699" ,"700" ,"727" ,"728" ,"809" 
		,"810" ,"864" ,"865" ,"866" ,"867" ,"868" ,"869" ,"871" ,"872" ,"023" ,"024" ,"025" ,"037" ,"059" ,"060" 
		,"061" ,"062" ,"063" ,"064" ,"065" ,"066" ,"069" ,"070" ,"100" ,"163" ,"164" ,"165"	,"166" ,"167" ,"168" 
		,"180" ,"181" ,"188" ,"189" ,"207" ,"208" ,"216" ,"217" ,"218" ,"219" ,"220" ,"222" ,"224" ,"225" ,"226" 
		,"232" ,"233" ,"234" ,"235" ,"236" ,"237" ,"242" ,"243" ,"246" ,"248" ,"250" ,"252" ,"253" ,"260" ,"264" 
		,"280" ,"283" ,"286" ,"299" ,"302" ,"304" ,"308" ,"309" ,"313" ,"326" ,"327" ,"329" ,"330" ,"331" ,"337" 
		,"354" ,"356" ,"357" ,"368" ,"369" ,"371" ,"372" ,"374" ,"375","377"  ,"378" ,"380" ,"381" ,"386" ,"388" 
		,"389" ,"393" ,"417" ,"418" ,"419" ,"432" ,"435" ,"436" ,"438" ,"439" ,"441" ,"442" ,"444" ,"459" ,"460" 
		,"463" ,"464" ,"466" ,"467" ,"469" ,"480" ,"481" ,"485" ,"490" ,"493" ,"515" ,"535" ,"536" ,"539" ,"540" 
		,"542" ,"543" ,"545" ,"546" ,"551" ,"562" ,"573" ,"574" ,"575" ,"576" ,"577" ,"579" ,"592" ,"593" ,"595" 
		,"604" ,"623" ,"628" ,"629" ,"637" ,"638" ,"640" ,"643" ,"644" ,"653" ,"654" ,"656" ,"657" ,"668" ,"673" 
		,"674" ,"692" ,"693" ,"707" ,"744" ,"749" ,"813" ,"840" ,"841" ,"853" ,"857" ,"862" ,"863" ,"870" ,"917" 
		,"919" ,"947" ,"948" ,"974" ,"975" ,"976" ,"977" ,"981" ,"982" ,"987" ,"988") 
	;and n.active_ind = 1
	
join p where p.encntr_id = d.encntr_id
	and p.order_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and p.active_ind = 1

join o where o.encntr_id = p.encntr_id
	and o.active_ind = 1
	and o.pathway_catalog_id = p.pathway_catalog_id

join oa where oa.order_id = o.order_id
	and oa.action_type_cd = 2534.00 ;Order
	
join pr where (pr.person_id = oa.order_provider_id or pr.person_id = oa.supervising_provider_id)
	and operator(pr.position_cd, opr_pos_var, $pos_type)

order by e.loc_facility_cd, d.encntr_id, p.pathway_catalog_id

Head report
	cnt = 0
Head e.encntr_id
	ocnt = 0
	cnt += 1
	pat->rec_cnt = cnt
	if (mod(cnt,10) = 1 or cnt = 1)
		stat = alterlist(pat->plist, cnt + 9)
	endif
	pat->plist[cnt].facility = uar_get_code_display(e.loc_facility_cd)		
	pat->plist[cnt].encntrid = e.encntr_id
	pat->plist[cnt].personid = e.person_id

Head p.pathway_catalog_id
	ocnt += 1	
	if (mod(ocnt,10) = 1 or ocnt = 1)
		stat = alterlist(pat->plist[cnt].olist, ocnt + 9)
	endif
	pat->plist[cnt].olist[ocnt].drg_cd = n.source_identifier
	pat->plist[cnt].olist[ocnt].drg_des = n.source_string
	pat->plist[cnt].olist[ocnt].nomen_id = n.nomenclature_id
	pat->plist[cnt].olist[ocnt].powerplan_name = p.description
	pat->plist[cnt].olist[ocnt].orderid = o.order_id
	pat->plist[cnt].olist[ocnt].order_nemon = o.order_mnemonic
	pat->plist[cnt].olist[ocnt].orderdt = format(p.order_dt_tm, 'mm/dd/yy hh:mm:ss ;;q')
	pat->plist[cnt].olist[ocnt].pr_name = pr.name_full_formatted
	pat->plist[cnt].olist[ocnt].pr_position = uar_get_code_display(pr.position_cd)
	if(oa.order_provider_id != null)
		pat->plist[cnt].olist[ocnt].order_pr_id =	oa.order_provider_id
	else	
		pat->plist[cnt].olist[ocnt].order_pr_id = oa.supervising_provider_id	
		pat->plist[cnt].olist[ocnt].order_supervising_pr_id = oa.supervising_provider_id
	endif	
Foot e.encntr_id
	stat = alterlist(pat->plist[cnt].olist, ocnt)
Foot report
	stst = alterlist(pat->plist, cnt)
with nocounter

;------------------------------------------------------------------------------------------------------------
/*
;Ordering Provider
select into 'nl:'
pr_id = pat->plist[d1.seq].olist[d2.seq].order_pr_id
,ord_id = pat->plist[d1.seq].olist[d2.seq].orderid

from
	(dummyt   d1  with seq = size(pat->plist, 5))
	, (dummyt   d2  with seq = 1)
	, prsnl pr

plan d1 where maxrec(d2, size(pat->plist[d1.seq].olist, 5))
join d2

join pr where pr.person_id = pat->plist[d1.seq].olist[d2.seq].order_pr_id

order by ord_id

Head ord_id
	idx = 0
	icnt = 0
      idx = locateval(icnt ,1 ,pat->rec_cnt ,ord_id ,pat->plist[d1.seq].olist[icnt].orderid)
       if(idx > 0)
       	pat->plist[d1.seq].olist[idx].pr_name = pr.name_full_formatted
       	pat->plist[d1.seq].olist[idx].pr_position = uar_get_code_display(pr.position_cd)
    	endif
With nocounter
*/

;------------------------------------------------------------------------------------------------------------
;Demographic
 
select into 'nl:'
 
from  (dummyt d WITH seq = value(size(pat->plist,5)))
	, encntr_alias ea
	, person p
 
plan d
 
join ea where ea.encntr_id = pat->plist[d.seq].encntrid
	and ea.encntr_alias_type_cd = 1077
	and ea.active_ind = 1
 
join p where p.person_id = pat->plist[d.seq].personid
	and p.active_ind = 1
 
order by ea.encntr_id
 
Head ea.encntr_id
	idx = 0
	cnt = 0
      idx = locateval(cnt ,1 ,pat->rec_cnt ,ea.encntr_id ,pat->plist[cnt].encntrid)
       if(idx > 0)
       	pat->plist[idx].fin = ea.alias
		pat->plist[idx].pat_name = p.name_full_formatted
    	endif
 
Foot ea.encntr_id
    null
 
With nocounter

;------------------------------------------------------------------------------------------------------------
	
call echorecord(pat)

;------------------------------------------------------------------------------------------------------------

select into $outdev
	facility = substring(1, 30, pat->plist[d1.seq].facility)
	, fin = substring(1, 30, pat->plist[d1.seq].fin)
	;, encntrid = pat->plist[d1.seq].encntrid
	, patient_name = substring(1, 50, pat->plist[d1.seq].pat_name)
	, drg_code = substring(1, 30, pat->plist[d1.seq].olist[d2.seq].drg_cd)
	, drg_description = substring(1, 300, pat->plist[d1.seq].olist[d2.seq].drg_des)
	, powerplan = substring(1, 300, pat->plist[d1.seq].olist[d2.seq].powerplan_name)
	, orderdt = substring(1, 30, pat->plist[d1.seq].olist[d2.seq].orderdt)
	, orderid = pat->plist[d1.seq].olist[d2.seq].orderid
	, order_nemonic = substring(1, 300, pat->plist[d1.seq].olist[d2.seq].order_nemon)
	;, pr_id = pat->plist[d1.seq].olist[d2.seq].order_pr_id
	;, super_pr_id = pat->plist[d1.seq].olist[d2.seq].order_supervising_pr_id
	, provider_name = substring(1, 80, pat->plist[d1.seq].olist[d2.seq].pr_name)
	, provider_position = substring(1, 100, pat->plist[d1.seq].olist[d2.seq].pr_position)

from
	(dummyt   d1  with seq = size(pat->plist, 5))
	, (dummyt   d2  with seq = 1)

plan d1 where maxrec(d2, size(pat->plist[d1.seq].olist, 5))
join d2

order by facility, fin

with nocounter, separator=" ", format


#exitscript

end
go




;with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180;, maxrows = 10000


/*
select distinct d.encntr_id, drg = n.source_identifier, drg_description = n.source_string
, powerplan = p.description, p.order_dt_tm ';;q', o.pathway_catalog_id
, o.order_id, o.orig_order_dt_tm ';;q', o.order_mnemonic, oa.order_provider_id, pr.name_full_formatted, pr.position_cd
from nomenclature n, drg d, pathway p ,orders o, order_action oa, prsnl pr
where n.source_identifier in('57','73','74','87','88','89','90','102','103','149','176','177','178','179')
and d.nomenclature_id = n.nomenclature_id 
and d.create_dt_tm between cnvtdatetime('01-NOV-2022 00:00:00') and cnvtdatetime('10-NOV-2022 00:00:00')
and d.encntr_id = 131827296.00
and p.encntr_id = d.encntr_id
and o.encntr_id = p.encntr_id
and o.pathway_catalog_id = p.pathway_catalog_id
and oa.order_id = o.order_id
and (pr.person_id = oa.order_provider_id or pr.person_id = oa.supervising_provider_id)

;order by d.encntr_id
with nocounter, separator=" ", format, uar_code(d,1), format(date,"mm-dd-yyyy hh:mm:ss;;d"), time = 180;, maxrows = 10000


("57" ,"73" ,"74" ,"87" ,"88" ,"89" ,"90" ,"102" ,"103" ,"149" ,"176" ,"177" ,"178" ,"179" ,"190" ,"191" ,"192" ,"193" ,"194" ,"195" 
,"196" ,"197" ,"198" ,"202" ,"203" ,"204" ,"205" ,"206" ,"291" ,"292" ,"293" ,"294" ,"295" ,"305" ,"312" ,"370" ,"373" ,"387" ,"390" 
,"391" ,"392" ,"394" ,"395" ,"440" ,"552" ,"556" ,"557" ,"558" ,"594" ,"596" ,"602" ,"603" ,"605" ,"606" ,"607" ,"607" ,"639" ,"675" 
,"689" ,"690" ,"694" ,"695" ,"696" ,"698" ,"699" ,"700" ,"727" ,"728" ,"809" ,"810" ,"864" ,"865" ,"866" ,"867" ,"868" ,"869" ,"871" 
,"872" ,"023" ,"024" ,"025" ,"037" ,"059" ,"060" ,"061" ,"062" ,"063" ,"064" ,"065" ,"066" ,"069" ,"070" ,"100" ,"163" ,"164" ,"165" 
,"166" ,"167" ,"168" ,"180" ,"181" ,"188" ,"189" ,"207" ,"208" ,"216" ,"217" ,"218" ,"219" ,"220" ,"222" ,"224" ,"225" ,"226" ,"232" 
,"233" ,"234" ,"235" ,"236" ,"237" ,"242" ,"243" ,"246" ,"248" ,"250" ,"252" ,"253" ,"260" ,"264" ,"280" ,"283" ,"286" ,"299" ,"302" 
,"304" ,"308" ,"309" ,"313" ,"326" ,"327" ,"329" ,"330" ,"331" ,"337" ,"354" ,"356" ,"357" ,"368" ,"369" ,"371" ,"372" ,"374" ,"375" 
,"377" ,"378" ,"380" ,"381" ,"386" ,"388" ,"389" ,"393" ,"417" ,"418" ,"419" ,"432" ,"435" ,"436" ,"438" ,"439" ,"441" ,"442" ,"444" 
,"459" ,"460" ,"463" ,"464" ,"466" ,"467" ,"469" ,"480" ,"481" ,"485" ,"490" ,"493" ,"515" ,"535" ,"536" ,"539" ,"540" ,"542" ,"543" 
,"545" ,"546" ,"551" ,"562" ,"573" ,"574" ,"575" ,"576" ,"577" ,"579" ,"592" ,"593" ,"595" ,"604" ,"623" ,"628" ,"629" ,"637" ,"638" 
,"640" ,"643" ,"644" ,"653" ,"654" ,"656" ,"657" ,"668" ,"673" ,"674" ,"692" ,"693" ,"707" ,"744" ,"749" ,"813" ,"840" ,"841" ,"853" 
,"857" ,"862" ,"863" ,"870" ,"917" ,"919" ,"947" ,"948" ,"974" ,"975" ,"976" ,"977" ,"981" ,"982" ,"987" ,"988") 

*/


/*
5227101826	  131827296.00



select distinct cv1.code_value, cv1.display
from code_value cv1, prsnl pr
where pr.position_cd = cv1.code_value
and cv1.code_set = 88
and cv1.active_ind = 1
and pr.physician_ind = 1
order by cv1.display


