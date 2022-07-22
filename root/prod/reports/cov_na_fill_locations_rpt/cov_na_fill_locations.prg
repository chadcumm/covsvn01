SELECT 
                  P.PREF_CARD_ID
                , PROCNAME = (O.DESCRIPTION)
                , PROVIDER = (PR.NAME_FULL_FORMATTED)
                , ItemDescript = (OII.VALUE)
                , ItemNumber = (OI.VALUE)
                , OPEN = (PC.REQUEST_OPEN_QTY)
                , HOLD = (PC.REQUEST_HOLD_QTY)
                , P_ACTIVE_STATUS_DESC = UAR_GET_CODE_DESCRIPTION(P.ACTIVE_STATUS_CD)                
                , DOMAIN = (CURDOMAIN)
                , RUNDATE = (CURDATE) "@SHORTDATE"              
                , PREFCARD_Active_Tm = (P.ACTIVE_STATUS_DT_TM)
                , PrefCard_PickList_Updated = (PC.UPDT_DT_TM) "@SHORTDATETIME"
                , PREFCARD_PICKLIST_UPDATED_BY = (PER.NAME_FULL_FORMATTED)
                , P_SURG_AREA_DISP = UAR_GET_CODE_DISPLAY(P.SURG_AREA_CD)     
               , ORG2.ORG_NAME
	, O2.ACTIVE_IND
	, O_OBJECT_TYPE_DISP = UAR_GET_CODE_DISPLAY(O2.OBJECT_TYPE_CD)
	, DESCRIPTION = (OI2.VALUE)
	
	, L_LOCATION_DISP = UAR_GET_CODE_DISPLAY(L2.LOCATION_CD)
	
	, L_LOCATION_TYPE_DISP = UAR_GET_CODE_DISPLAY(L2.LOCATION_TYPE_CD)          
                , P.ACTIVE_IND
FROM
                PREFERENCE_CARD   P
                , ORDER_CATALOG   O
                , DUMMYT   D2
                , PRSNL   PR
                , PRSNL_GROUP   PG
                , PREF_CARD_PICK_LIST   PC
                , DUMMYT   D1
                , OBJECT_IDENTIFIER_INDEX   OII
                , PRSNL   PRS
                , OBJECT_IDENTIFIER_INDEX   OI
                , PERSON   PE
                , PERSON   PER
                , OBJECT_IDENTIFIER_INDEX   OIIB
                , CLASS_NODE   C
                ,	OBJECT_IDENTIFIER_INDEX   O2
	, OBJECT_IDENTIFIER_INDEX   OI2
	, LOCATION   L2
	, ORGANIZATION   ORG2
	;, DUMMYT   D2

;
PLAN P ;
WHERE P.SURG_AREA_CD IN (

2552926529;     LCMC Main OR
,2552926545;     LCMC Labor and Delivery
,2552926567;     LCMC Endoscopy
)
and P.ACTIVE_IND = 1

JOIN O WHERE O.CATALOG_CD = P.CATALOG_CD
JOIN D1
JOIN PR WHERE PR.PERSON_ID = P.PRSNL_ID
JOIN PG WHERE outerjoin (PG.PRSNL_GROUP_ID) = P.SURG_SPECIALTY_ID

JOIN PC WHERE PC.PREF_CARD_ID = P.PREF_CARD_ID
  ;AND P.ACTIVE_IND = 1
JOIN OII WHERE OII.OBJECT_ID = PC.ITEM_ID 
  AND (oii.generic_object = 0) 
 ;AND oii.object_type_cd =        3119.00 Instrument Master        3117.00   Equipment Master ***Check supply***
  AND OII.IDENTIFIER_TYPE_CD =       3097.00;      Description  ;3109.00 Short Description
  
  ;ANd oii.active_ind = 1
  ;AND oii.value like "*RX *" ;<<<-----------------------------------------------------------
   ; or oii.value like "*INACT*"
   
JOIN OI WHERE OI.OBJECT_ID = PC.ITEM_ID 
  AND (oi.generic_object = 0) 
  AND OI.OBJECT_ID = PC.ITEM_ID 
  AND OI.IDENTIFIER_TYPE_CD =   3101; Item Number
    ;and oi.active_ind = 0

JOIN D2
JOIN PRS WHERE PRS.PERSON_ID = OII.UPDT_ID ; item descrption
JOIN PE WHERE PE.PERSON_ID = OI.UPDT_ID ; item number
JOIN PER WHERE PER.PERSON_ID = PC.UPDT_ID
;
JOIN OIIB WHERE OIIB.OBJECT_ID = PC.ITEM_ID 
;
AND OIIB.IDENTIFIER_TYPE_CD =   3110;               System Number
;
JOIN C WHERE C.CLASS_NODE_ID = outerjoin(OIIB.GENERIC_OBJECT)
and  C.CLASS_NODE_ID >0 
; =2562191017;  NON-CLASSIFIED
join o2
	where o2.value = oi.value
 and o2.OBJECT_TYPE_CD IN (
3117.00;	Equipment Master
,3119.00;	Item Master
,3125.00;	Vendor Item
  )
 JOIN L2 WHERE L2.LOCATION_CD = o2.rel_parent_entity_iD
  
   and l2.location_type_cd =         788.00 ; Locations
   or l2.location_type_cd = 0
   and l2.location_type_cd =         818.00 ; Surgery Fill Locations; adding this removes the blank org and blank inv loc row



JOIN ORG2 WHERE outerjoin(ORG2.ORGANIZATION_ID) =  L2.ORGANIZATION_ID
JOIN OI2 WHERE outerjoin(OI2.PARENT_ENTITY_ID) = O2.OBJECT_ID
 AND OI2.IDENTIFIER_TYPE_CD = 3097.00;
ORDER BY
                P_SURG_AREA_DISP
                , O.DESCRIPTION
                , PR.NAME_FULL_FORMATTED
                , OII.VALUE
go
