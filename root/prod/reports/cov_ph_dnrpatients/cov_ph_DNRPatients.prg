/*****************************************************************************
 *  Covenant Health Information Technology
 *  Knoxville, Tennessee
 *****************************************************************************
 
    Author:            Dan Herren
    Date Written:      May 2018
    Soluation:         Population Health - Quality
    Source file name:  cov_ph_DNRPatients.prg
    Object name:       cov_ph_DNRPatients
    Layout Builder:    n/a
    CR #:              517
 
    Program purpose:   File extract that selects patients with a DNR
    				   Orderable status for State Data submission.
    				   Runs every Monday for the previous Monday thru Sunday.
 
    Executing from:    CCL.
 
    Special Notes:
 
 ******************************************************************************
 *  GENERATED MODIFICATION CONTROL LOG
 ******************************************************************************
 *
 *  Mod Date     Developer             Comment
 *  -----------  --------------------  ----------------------------------------
 *
 ******************************************************************************/
 
drop program 	cov_ph_DNRPatients go
create program 	cov_ph_DNRPatients
 
prompt
	"Output to File/Printer/MINE" = "MINE"
 
with OUTDEV
 
/**************************************************************
; DVDev DECLARED SUBROUTINES
**************************************************************/
 
/**************************************************************
; DVDev RECORD STRUCTURE
**************************************************************/
;free record dnr
record dnr
(
1 ords [*]
	2 facility 	 = vc ;c50   ;facility name
	2 fin_nbr    = vc ;c20   ;fin number
	2 pat_name   = vc ;c50   ;patient name
	2 dnr_status = vc ;c100  ;dnr status
	2 order_date = vc ;c20   ;order date
	2 order_id   = f8    ;order id
	2 encntr_id  = f8	 ;encounter id
	2 person_id  = f8    ;person id
)
 
record output (
	1 temp = vc
	1 locator = vc
	1 filename = vc
	1 directory = vc
)
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare RESUSCITATION_STATUS_VAR  = f8 with Constant(uar_get_code_by("DISPLAYKEY",16449,"RESUSCITATIONSTATUS")),protect
declare DNR_COMFORT_MEASURE_VAR   = f8 with Constant(uar_get_code_by("DISPLAYKEY",254914,"DNRNOCPRCOMFORTMEASURES")),protect
declare DNR_LIMITED_ADDINTERV_VAR = f8 with Constant(uar_get_code_by
	("DISPLAYKEY",254914,"DNRNOCPRLIMITEDADDITNLINTERVENTION")),protect
;
declare ORD_ORDERED_VAR    = f8 with Constant(uar_get_code_by("DISPLAYKEY",6004,"ORDERED")),protect
declare ORD_INPROCESS_VAR  = f8 with Constant(uar_get_code_by("DISPLAYKEY",6004,"INPROCESS")),protect
declare ORD_COMPLETED_VAR  = f8 with Constant(uar_get_code_by("DISPLAYKEY",6004,"COMPLETED")),protect
declare ORD_PAT_CARE_VAR   = f8 with Constant(uar_get_code_by("DISPLAYKEY",6000,"PATIENTCARE")),protect
declare ORD_CODESTATUS_VAR = f8 with Constant(uar_get_code_by("MEANING",200,"CODESTATUS")),protect
declare DECEASED_NO_VAR    = f8 with Constant(uar_get_code_by("DISPLAYKEY",268,"NO")),protect
declare FIN_VAR            = f8 with Constant(uar_get_code_by("MEANING",319,"FIN NBR")),protect
;
;Runs every Monday for the previous Monday thru Sunday.
declare START_DATE = dq8
declare END_DATE   = dq8
declare OUTPUTFILE = c300 with noconstant("")
 
;sets date range to previous Monday thru Sunday (when ran on Monday)
set START_DATE = cnvtlookbehind("7,D")
set START_DATE = datetimefind(START_DATE,"W","B","B")
set START_DATE = cnvtlookahead("1,D",START_DATE)
set END_DATE   = datetimefind(START_DATE,"W","E","E")
set END_DATE   = cnvtlookahead("1,D",END_DATE)
 
;call echo(format(cnvtdatetime(START_DATE),"mm/dd/yyyy HH:mm;;d"))
;call echo(format(cnvtdatetime(END_DATE),"mm/dd/yyyy HH:mm;;d"))
;go to exitscript
 
;if(validate(request->batch_selection) = 1)
;
;	;SCHEDULED PROCESS
;	declare filePath   = vc with noconstant("")
;	declare fileName   = vc  with noconstant("")
;;	set     filePath   = "/nfs/middle_fs/to_client_site/p0665/RevenueCycle/PopulationHealth/PAExports/"
;	set     filePath   = "cer_temp:"
;	set     fileName   = build("dnr_",format(cnvtdatetime(curdate,curtime),"yyyymmdd;;d"),".txt.cerner")
;	set     OUTPUTFILE = concat(filePath, fileName)
;
;set output->filename = concat(filePath, fileName)
;
;;	call echo(BUILD("dSTART=",START_DATE))
;;	call echo(BUILD("dEND  =",END_DATE))
;;	call echo(BUILD("cSTART=",format(START_DATE,"mm/dd/yyyy HH:mm;;q")))
;;	call echo(BUILD("cEND  =",format(END_DATE,"mm/dd/yyyy HH:mm;;q")))
;
;else
;
; 	;MANUAL PROCESS
;	declare filePath   = vc with noconstant("")
;	declare fileName   = vc with noconstant("")
;	set     filePath   = ""
;	set     fileName   = build("dnr_",format(cnvtdatetime(curdate,curtime),"yyyymmdd;;d"),".csv")
;;	set     OUTPUTFILE = concat(filePath, fileName)
;	set     OUTPUTFILE = $OUTDEV ; ;concat(trim(filePath), trim(fileName))
;
;endif
 
 
set output->directory = "/cerner/w_custom/p0665_cust/to_client_site/RevenueCycle/PopulationHealth/PAExports/DNR/"
set output->filename   = concat("dnr_",format(cnvtdatetime(curdate,curtime),"yyyymmdd;;d"))
;set output->filename  = "djhtestfile"
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
select into "NL:"
;select into value ($outdev)
	 fac         = uar_get_code_display(e.loc_facility_cd)
	,fin_nbr     = cnvtalias(ea.alias,  ea.alias_pool_cd)
;	,pat_name  	 = p.name_full_formatted
;	,dnr_status  = uar_get_code_display(od.oe_field_value)
;	,order_date  = format(ord.orig_order_dt_tm,"mm/dd/yyyy HH:mm;;d")
; 	,order_id	 = ord.order_id
; 	,encntr_id 	 = e.encntr_id
;	,person_id   = p.person_id
 
from
	 ENCNTR_DOMAIN  ed
	,ORDERS         ord
	,ORDER_DETAIL	od
	,ENCOUNTER      e
 	,ENCNTR_ALIAS   ea
	,PERSON         p
 
plan ed
	where ed.end_effective_dt_tm > cnvtdatetime(START_DATE)
		and ed.loc_facility_cd =
        	(select cv1.code_value
             from code_value cv1
             where cv1.code_set = 220
             	and cv1.cdf_meaning = "FACILITY"
             	and cv1.active_ind = 1
			)
		and ed.loc_building_cd =
            (select cv1.code_value
             from code_value cv1
             where cv1.code_set = 220
             	and cv1.cdf_meaning = "BUILDING"
             	and cv1.active_ind = 1
             )
		and ed.loc_nurse_unit_cd =
            (select cv1.code_value
             from code_value cv1
             where cv1.code_set = 220
             	and cv1.cdf_meaning in ("AMBULATORY", "NURSEUNIT")
             	and cv1.active_ind = 1
             )
;		and ed.loc_room_cd > 0
		and ed.beg_effective_dt_tm < cnvtdatetime(END_DATE)
 
join ord
	where ord.person_id = ed.person_id
		and ord.catalog_cd = ORD_CODESTATUS_VAR  ;2958523.00
		and ord.encntr_id = ed.encntr_id
		and ord.clin_relevant_updt_dt_tm between cnvtdatetime(START_DATE) and cnvtdatetime(END_DATE)
		and ord.order_status_cd in (ORD_ORDERED_VAR, ORD_INPROCESS_VAR, ORD_COMPLETED_VAR) ;2550,2548,2543
;;		and ord.catalog_type_cd = ORD_PAT_CARE_VAR ;2515
 
join od
	where od.order_id = ord.order_id
		and od.oe_field_meaning = "RESUSCITATIONSTATUS"
		and od.oe_field_value in (DNR_COMFORT_MEASURE_VAR, DNR_LIMITED_ADDINTERV_VAR ) ;681226  76689869
 
join e
	where e.encntr_id = ord.encntr_id
		and	e.loc_facility_cd in (
			2553765291.00,  2552503657.00, 2552503635.00, 21250403.00, 2552503653.00,
			2552503639.00, 2552503613.00, 2552503645.00, 2552503649.00
			)
		and e.active_ind = 1
 		and e.end_effective_dt_tm >= sysdate
 
join ea
	where ea.encntr_id = outerjoin(e.encntr_id)
		and ea.encntr_alias_type_cd = FIN_VAR ;1077.00
		and ea.end_effective_dt_tm >= sysdate
 
join p
	where p.person_id = e.person_id
		and p.person_id = ord.person_id
		and p.deceased_cd = DECEASED_NO_VAR ;684730
		and p.active_ind = 1
		and p.end_effective_dt_tm >= sysdate
 
head report
	cnt = 0
 
detail
	cnt = cnt + 1
	stat = alterlist(dnr->ords,cnt)
 
	dnr->ords[cnt].facility   = fac
	dnr->ords[cnt].fin_nbr    = fin_nbr
;	dnr->ords[cnt].pat_name   = pat_name
;	dnr->ords[cnt].dnr_status = dnr_status
;	dnr->ords[cnt].order_date = order_date
; 	dnr->ords[cnt].order_id   = order_id
; 	dnr->ords[cnt].encntr_id  = encntr_id
;	dnr->ords[cnt].person_id  = person_id
 
with nocounter
;, format, check, separator = " "
 
;call echorecord(dnr)
;go to exitscript
 
 
;============================
; REPORT OUTPUT
;============================
; 12 length line + 2 for \r\n
declare disp_line = c14 with noconstant(fillstring(102, ' ')), protect
; static sized columns
declare col1 = c1  with noconstant(fillstring(1, ' ')), protect
declare sep  = c1  with noconstant(fillstring(1, '|')), protect
declare col3 = c10 with noconstant(fillstring(10, ' ')), protect
 
record frec (
    1 file_desc = i4
    1 file_offset = i4
    1 file_dir = i4
    1 file_name = vc
    1 file_buf = vc
)
 
set frec->file_name = concat(trim(output->filename,3), ".txt.cerner")
set frec->file_buf = "w"
set stat = cclio("OPEN", frec)
 
;select distinct into value($outdev)
select distinct into "nl:"
	fac	= trim(replace(evaluate2(   ;set the McKesson Star facility code.
 	if 	(dnr->ords[d.seq].facility in ("CMC", "CLMC")) ""
 	elseif	(dnr->ords[d.seq].facility = "FLMC")"L"
 	elseif	(dnr->ords[d.seq].facility = "FSR") "F"
 	elseif	(dnr->ords[d.seq].facility = "LCMC")"S"
 	elseif	(dnr->ords[d.seq].facility = "MHHS")"M"
 	elseif	(dnr->ords[d.seq].facility = "MMC") "B"
 	elseif	(dnr->ords[d.seq].facility = "PBH") "G"
 	elseif	(dnr->ords[d.seq].facility = "PW") "P"
 	elseif	(dnr->ords[d.seq].facility = "RMC") "R" endif	) , char(0),""),3)
	,fin_nbr = trim(replace(dnr->ords[d.seq].fin_nbr,char(0),""),3)
 
from
	(DUMMYT d with seq = value(size(dnr->ords,5)))
 
order by
	 fac
	,fin_nbr
 
head d.seq
	output->temp = ""
	disp_line = fillstring(15,' ')
    col1 	  = fillstring(1, ' ')
    sep  	  = fillstring(1,'|')
    col2 	  = fillstring(10, ' ')
 
detail
; 	output only facility and fin number
	col1 = substring(1,1,trim(fac,3))
	col2 = substring(1,10,trim(fin_nbr,3))
	disp_line = concat(col1,sep,col2,char(13),char(10))
	frec->file_buf = disp_line
	stat = cclio ("PUTS", frec)
 
 
foot report
	frec->file_buf = "END"
	stat = cclio ("PUTS", frec)
	stat = cclio ("CLOSE",frec)
 
with nocounter
, format, check, separator = " ", memsort
 
set statx = 0
set  output->temp = concat("mv $CCLUSERDIR/", output->filename,".txt.cerner ",output->directory,output->filename,".txt.cerner")
call echo (output->temp)
call dcl( output->temp ,size(output->temp  ), statx)
set output->temp = ""
 
select into value($outdev)
Message =  "Files successfully created to Astream folders."
with format, separator = " ", check;, noheader
 
;#exitscript
end
go
 
/*
;ADHOC for testing
select
	 fac         = uar_get_code_display(e.loc_facility_cd)
	,fin_nbr     = cnvtalias(ea.alias,  ea.alias_pool_cd)
	,pat_name  	 = p.name_full_formatted
	,dnr_status  = uar_get_code_display(od.oe_field_value)
	,order_date  = format(ord.orig_order_dt_tm,"mm/dd/yyyy HH:mm;;d")
 	,order_id	 = ord.order_id
 	,encntr_id 	 = e.encntr_id
	,person_id   = p.person_id
 
from
	 ENCNTR_DOMAIN  ed
	,ORDERS         ord
	,ORDER_DETAIL	od
	,ENCOUNTER      e
 	,ENCNTR_ALIAS   ea
	,PERSON         p
 
plan ed
	where ed.end_effective_dt_tm > cnvtdatetime("21-MAY-2018 00:00:00")
		and ed.loc_facility_cd =
        	(select cv1.code_value
             from code_value cv1
             where cv1.code_set = 220
             	and cv1.cdf_meaning = "FACILITY"
             	and cv1.active_ind = 1
			)
		and ed.loc_building_cd =
            (select cv1.code_value
             from code_value cv1
             where cv1.code_set = 220
             	and cv1.cdf_meaning = "BUILDING"
             	and cv1.active_ind = 1
             )
		and ed.loc_nurse_unit_cd =
            (select cv1.code_value
             from code_value cv1
             where cv1.code_set = 220
             	and cv1.cdf_meaning in ("AMBULATORY", "NURSEUNIT")
             	and cv1.active_ind = 1
             )
;		and ed.loc_room_cd > 0
		and ed.beg_effective_dt_tm < cnvtdatetime("27-MAY-2018 23:59:59")
 
join ord
	where ord.person_id = ed.person_id
		and ord.catalog_cd = 2958523.00  ;ORD_CODESTATUS_VAR  ;2958523.00
		and ord.encntr_id = ed.encntr_id
		and ord.clin_relevant_updt_dt_tm between cnvtdatetime("21-MAY-2018 00:00:00") and cnvtdatetime("27-MAY-2018 23:59:59")
		and ord.order_status_cd in (2550, 2548, 2543) ;(ORD_ORDERED_VAR, ORD_INPROCESS_VAR, ORD_COMPLETED_VAR) ;2550,2548,2543
;;		and ord.catalog_type_cd = ORD_PAT_CARE_VAR ;2515
 
join od
	where od.order_id = ord.order_id
		and od.oe_field_meaning = "RESUSCITATIONSTATUS"
		and od.oe_field_value in (681226, 76689869); (DNR_COMFORT_MEASURE_VAR, DNR_LIMITED_ADDINTERV_VAR ) ;681226  76689869
 
join e
	where e.encntr_id = ord.encntr_id
		and	e.loc_facility_cd in (
			2553765291.00,  2552503657.00, 2552503635.00, 21250403.00, 2552503653.00,
			2552503639.00, 2552503613.00, 2552503645.00, 2552503649.00
			)
		and e.active_ind = 1
 		and e.end_effective_dt_tm >= sysdate
 
join ea
	where ea.encntr_id = outerjoin(e.encntr_id)
		and ea.encntr_alias_type_cd = 1077 ;FIN_VAR ;1077.00
		and ea.end_effective_dt_tm >= sysdate
 
join p
	where p.person_id = e.person_id
		and p.person_id = ord.person_id
		and p.deceased_cd = 684730 ;DECEASED_NO_VAR ;684730
		and p.active_ind = 1
		and p.end_effective_dt_tm >= sysdate
 
order by
	 fac
	,fin_nbr
*/
