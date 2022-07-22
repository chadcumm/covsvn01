/*****************************************************************************
  Covenant Health Information Technology
  Knoxville, Tennessee
******************************************************************************
 	Author:			Geetha Saravanan
	Date Written:		Aug'2018
	Solution:			Ambulatory
	Source file name:  	cov_phq_ambulatory_serviceItem.prg
	Object name:		cov_phq_ambulatory_serviceItem
	Request#:			1192
 
	Program purpose:	      PAFs / AWE report that shows the number by payer that have not been scheduled,
					are scheduled to be completed / charged by payer.
 
	Executing from:		DA2/Ambulatory folder
  	Special Notes:
 
******************************************************************************
  GENERATED MODIFICATION CONTROL LOG
******************************************************************************
 
Mod Date	Developer			     Comment
----------	--------------------	------------------------------------------
 
******************************************************************************/
 
drop program cov_phq_ambulatory_serviceItem:dba go
create program cov_phq_ambulatory_serviceItem:dba
 
prompt 
	"Output to File/Printer/MINE" = "MINE"   ;* Enter or select the printer or file name to send this report to.
	, "Start Date/Time" = "SYSDATE"
	, "End Date/Time" = "SYSDATE" 

with OUTDEV, start_datetime, end_datetime
 
 
/**************************************************************
; DVDev DECLARED VARIABLES
**************************************************************/
declare initcap()      = c100
declare mrn_var        = f8 with constant(uar_get_code_by("DISPLAY", 319, "MRN")),protect
declare fin_var        = f8 with constant(uar_get_code_by("DISPLAY", 319, "FIN NBR")),protect
 
declare cerner_mrn_var = f8 with constant(uar_get_code_by("DISPLAY_KEY", 263, 'CERNERMRN')),protect  ;2554138271.00
declare prsnl_var      = f8 with constant(uar_get_code_by("DISPLAY",     331, 'Primary Care Physician')),protect  ;1115.00
declare position_var   = f8 with constant(uar_get_code_by("CDF_MEANING", 88 , 'PRIMARY CARE')),protect  ;19944603.00
 
 
/**************************************************************
; DVDev Start Coding
**************************************************************/
 
8/7/18 - good to go as of now. But no patients showing up as per CPT code.
	Need few test aptients to see Charge and diagnosis details. 
  
 
select distinct into $outdev
 
  clinic = uar_get_code_display(sa.appt_location_cd)
, provider = uar_get_code_display(sa1.resource_cd);phys and lab resource
, date_of_service = format(sa.beg_dt_tm, 'mm/dd/yyyy hh:mm ;;d')
, encounter = sa.encntr_id
, payer_name = ''
, Pat_name = initcap(p.name_full_formatted)
, dob = p.birth_dt_tm
, c.charge_description
, c.charge_event_id
, c.gross_price
, c.discount_amount
, diagnosis = n.source_string
, code = uar_get_code_display(n.source_vocabulary_cd)
 
 
from

  sch_appt sa
, sch_appt sa1
, sch_event se
, person p
, diagnosis dg
, nomenclature n
, charge c

,( (
	select cv.description, cv.code_value
        from code_value cv
        where cv.code_set = 220
        and cv.active_ind = 1
        and cv.cdf_meaning = 'AMBULATORY'
        and cv.display_key in(
            'CAETATHENS','CAETDECATUR','CAETLENOIR','CAETONEIDA','CAETPARKWEST','CAETTAVR','CTRREPRODMED',
            'CLAIBMEDASSOC','CLINTONFAMILY','NEUROHOSPITAL','CONVENIENTCARE','CROSSVILLE','CROSSFAIRFIELD','CROSSOBGYN','CROSSWALKIN',
            'CUMBNEUROLOGY','CUMBNEUROSURG','CUMBORTHO','CUMBSPEC310','CUMBSPEC350','ETORTHOPEDICS','ETUROLOGY','FAMCLINOAK',
            'FAMILYCARE1300','FAMILYCARE1320','FAMILYCAREWALK','FTLOUDOUNPC', 'FSNEUROSURMOR','FSNEUROSURREG',
            'GREATSMOKIES','HAMBLENPRIMARY','HAMBPULMORRIS','HAMBPULTAZE','HAMBUROLOGY','HAMBUROLTAZE','HEALTHWORKSLAB','HEALTHWORKSRAD',
            'CLAIBPRIMARY','INTMEDASSOC','INTMEDWEST','JTV','KINGSTONFAMILY','KINGSTONFAMILY','KNOXHRTCENTER','KNOXHRTGROUP','KNOXHRTHARR',
            'KNOXHRTJEFFCT','KNOXHRTMORRIS','KNOXHRTOR','KNOXHRTSEVIER','KNOXHRTSEYM','KNOXHRTTAZE','LAKECITY','LAKEWAYORTHO',
            'LECONTECARDIO','LECONTEPULMON','LECONTESURG','LENOIRMEDICAL','MCNEELEYFAMILY','MEDASSCCARTER','MORRISFAMILY','MTNVIEW'
            ,'NEWHORIZON','ORGASTRO','ORINFECTIOUS','ORSURGEONS','OLIVERSPRINGS','PROMPTSOUTH','ROANECOUNTY','ROANEPULMONARY','ROANESLEEP',
            'ROANESURGGRP','JOEYROQUE','SEVIERCOUNTYWELLNESS','SMG','SMGSOUTH','SURGICALASSOC',
            'MIRIAMTEDDER','TNBRAINKNOX','TNBRAINALCOA','TNBRAINSEVIER','TNBRAINWEST','TOPSIDEPHYS','UROSPETREG','UROSPETALCOA',
            'WESTLAKESURG','HOOKMANCARD', 'HOOKMANCARDC','FAMILYCLINIC', 'SEVIERWELLNESS', 'LAKEWAY', 'TNBRAINWEST', 
            'TOPSIDE', 'ALCOAURO', 'REGIONALURO', 'ETCVSKNOX', 'ETCVSOAKRIDGE', 'ETCVSREGIONAL', 'INTERNALMEDA', 'INTERNALMEDW',
            'KNOXDIGESTCON', 'SMOKYMTN'
            )
        order by cv.description     
        with sqltype('vc', 'f8')
   )i	
)
	
plan i	
 
join sa where sa.appt_location_cd = i.code_value
	and sa.beg_dt_tm between cnvtdatetime($start_datetime) and cnvtdatetime($end_datetime)
	and cnvtupper(sa.role_meaning) = 'PATIENT'
	and sa.active_ind = 1
	and sa.sch_state_cd in(4538.00, 4536.00, 4537.00,4054213.00, 4541.00)
		;Confirmed, Checked In, Checked Out, Complete, Finalized
 
join se where se.sch_event_id = outerjoin(sa.sch_event_id)
	and se.active_ind = outerjoin(1)
 
join sa1 where sa1.sch_event_id = outerjoin(se.sch_event_id)
	and cnvtupper(sa1.role_meaning) = outerjoin('RESOURCE')
	and sa1.active_ind = outerjoin(1)
 
join p where p.person_id = outerjoin(sa.person_id)
	and p.active_ind = outerjoin(1)
 
join dg where dg.encntr_id = sa.encntr_id
	and dg.active_ind = 1
 
join n where n.nomenclature_id = dg.nomenclature_id
	and n.source_vocabulary_cd = value(uar_get_code_by('DISPLAY',400, 'CPT4'))
	and n.source_string = 'PT-FOCUSED HLTH RISK ASSMT'
	and n.source_identifier = '96160'
	and n.active_ind = 1
	
join c where c.encntr_id = sa.encntr_id
	and c.active_ind = 1	
 
WITH NOCOUNTER, SEPARATOR=" ", FORMAT, TIME = 120;, maxrec = 1000
 
end
go
 
 
 
 
/*
 
select * from charge where charge_description = 'PT-FOCUSED HLTH RISK ASSMT' 
 
 
*/
