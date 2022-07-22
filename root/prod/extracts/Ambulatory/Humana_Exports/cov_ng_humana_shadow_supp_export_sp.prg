ALTER PROCEDURE cov_ng_humana_shadow_supp_export_sp    
----------------------------------------------------------------------------------------------------------                                                                       
---                                                                        
--- Name: cov_ng_humana_shadow_supp_export_sp (was cov_humana_claim_recon_sp)                  
---                                                                        
--- Customer: Covenant                                                                        
--- Created by: Dawn Greer, DBA                                                                       
--- Date: 6/3/2020 (original 11/30/2018)                  
---                                                                        
--- Purpose: To pull Diagnosis from Claim data to send to Humana so they can reconcile with their system.                                
---                                                                        
--- Database Server: NGSQL02DB                                   
--- Databases Used: NGPROD, Cov_NextGen_Integration                                                                       
--- File Share for Export: \\ngfs01\nextgenroot\Humana_Extracts                                
---                                                                      
--- Modifications:                                                                      
---  12/03/2018 - DG - Updated the values for the Claim_type, encounter_id, place_of treatment,                               
---    and group_id per e-mail from vendor.  Renamed mbr_hnum to mbr_h per vendor e-mail.                              
---  12/05/2018 - DG - Changed the place of treatment to 11 for Office per vendor documentation                              
---  12/19/2018 - DG - Added Medicare Humana, Medicare Humana Choice PPO, Medicare Humana Gold,                             
---  Medicare Humana PFFS, Medicare Humana TRS to the Payer List. Changed criteria to                            
---     look at the claim_detail.service_from_date instead of the claim.create_timestamp                            
---  01/15/2019 - DG - Changed the field names for GROUP_ID (to GROUPER_ID), DOS_TO (to DOS_THRU)                         
---  and FACILITY (to FACILITY_NAME).  Updated the GROUP_NAME to be CMG-COVENANT                        
---  09/09/2019 - DG - Running for 1/1/2019 - 8/31/2019 23:59:59                      
---  05/28/2020 - DG - Created in NGPROD                    
---  06/03/2020 - DG - Renamed to cov_humana_shadow_supp_extract_sp from cov_humana_claim_recon_sp                  
---       Added FIN_NBR to REV_CODE field.                  
---  06/04/2020 - DG - Removed the FIN_NBR from the REV_CODE Field and added it as a new field at the end.                
---    Changed the process to pull 24 Diagnosis from Encounter_Diags instead of the Claims.          
---  07/06/2020 - DG - Setup to run for 21-15 days back (Monday-Sunday) from today (2-3 weeks ago)      
---  08/25/2020 - DG - Removed the dash from the TAX ID          
---  08/31/2020 - DG - Added ISNULL to fields that didn't have it already.   
---  09/01/2020 - DG - Changed the procedure name to cov_ng_humana_shadow_supp_export_sp from  
---  cov_ng_humana_shadow_supplemental_extract_sp   
---  01/05/2021 - DG - Fixed issue with person_payer and setup to run monthly for the previous month.
-----------------------------------------------------------------------------------------------------------                                                                 
AS                                                          
DECLARE @StartDate DATETIME, @EndDate DATETIME             
                                                       
SET @StartDate = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0)   --Last Month First Day
SET @EndDate = DATEADD(ms, -2, DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, 0))  -- Last_Month Last Day
        
SELECT DISTINCT              
'CMG_COVENANT' AS GROUP_NAME,                                
'' AS GROUPER_ID,                                
REPLACE(ISNULL(c.phys_tax_id,''),'-','') BP_TAX_ID,                                
ISNULL(c.emc_phys_id,'') AS BP_NPI_ID,                                
UPPER(pp.policy_nbr) AS MBR_H,                                
REPLACE(c.patient_last_name,',','') AS MBR_LAST_NAME,                                
REPLACE(c.patient_first_name,',','') AS MBR_FIRST_NAME,                                
CONVERT(VARCHAR(10), CAST(c.patient_birthdate AS DATE),101) AS MBR_DOB,                             
ISNULL(c.patient_sex,'') AS MBR_GENDER,                                
'' AS MBR_HIC_NBR,                                
ISNULL(REPLACE(REPLACE(cd.line_charges,'$',''),',',''),'') AS CHARGE_AMT,                                
ISNULL(REPLACE(REPLACE(cd.pat_paid_amt,'$',''),',',''),'') AS PAID_AMT,                                
ISNULL(REPLACE(REPLACE(cd.allowed_amt,'$',''),',',''),'') AS ALLOW_AMT,                                
'' AS TYPE_OF_BILL,                                
'11' AS PLACE_OF_TREATMENT,                                
ISNULL(c.patient_control_nbr,'') AS ENCOUNTER_ID,                                
CONVERT(VARCHAR(10), CAST(cd.service_from_date AS DATE),101) AS DOS_FROM,                                
CONVERT(VARCHAR(10), CAST(cd.service_to_date AS DATE),101) AS DOS_THRU,                                
ISNULL(REPLACE(Pivot1.[1],'.',''),'') AS ICD_PRIMARY_CODE,                                
ISNULL(REPLACE(Pivot1.[1],'.',''),'') AS ICD_CODE1,                                
ISNULL(REPLACE(Pivot1.[2],'.',''),'') AS ICD_CODE2,                                
ISNULL(REPLACE(Pivot1.[3],'.',''),'') AS ICD_CODE3,                                
ISNULL(REPLACE(Pivot1.[4],'.',''),'') AS ICD_CODE4,                                
ISNULL(REPLACE(Pivot1.[5],'.',''),'') AS ICD_CODE5,                                
ISNULL(REPLACE(Pivot1.[6],'.',''),'') AS ICD_CODE6,                                
ISNULL(REPLACE(Pivot1.[7],'.',''),'') AS ICD_CODE7,                                
ISNULL(REPLACE(Pivot1.[8],'.',''),'') AS ICD_CODE8,                                
ISNULL(REPLACE(Pivot1.[9],'.',''),'') AS ICD_CODE9,                                
ISNULL(REPLACE(Pivot1.[10],'.',''),'') AS ICD_CODE10,                                
ISNULL(REPLACE(Pivot1.[11],'.',''),'') AS ICD_CODE11,                                
ISNULL(REPLACE(Pivot1.[12],'.',''),'') AS ICD_CODE12,                                
ISNULL(REPLACE(Pivot1.[13],'.',''),'') AS ICD_CODE13,                                
ISNULL(REPLACE(Pivot1.[14],'.',''),'') AS ICD_CODE14,                                
ISNULL(REPLACE(Pivot1.[15],'.',''),'') AS ICD_CODE15,                                
ISNULL(REPLACE(Pivot1.[16],'.',''),'') AS ICD_CODE16,                               
ISNULL(REPLACE(Pivot1.[17],'.',''),'') AS ICD_CODE17,                                
ISNULL(REPLACE(Pivot1.[18],'.',''),'') AS ICD_CODE18,                                
ISNULL(REPLACE(Pivot1.[19],'.',''),'') AS ICD_CODE19,                                
ISNULL(REPLACE(Pivot1.[20],'.',''),'') AS ICD_CODE20,                                
ISNULL(REPLACE(Pivot1.[21],'.',''),'') AS ICD_CODE21,                                
ISNULL(REPLACE(Pivot1.[22],'.',''),'') AS ICD_CODE22,                                
ISNULL(REPLACE(Pivot1.[23],'.',''),'') AS ICD_CODE23,                                
ISNULL(REPLACE(Pivot1.[24],'.',''),'') AS ICD_CODE24,                                
'P' AS CLAIM_TYPE,                                
UPPER(cd.hcpcs_procedure_code) AS HCPCS_CPT_CD,                                
ISNULL(cd.hcpcs_modifier_1,'') AS CPT_MODIFIER_A,                                
ISNULL(cd.hcpcs_modifier_2,'') AS CPT_MODIFIER_B,         
'' AS REV_CODE,                                
ISNULL(cd.rendering_provider_nbr,'') AS PROV_NPI,                                
REPLACE(ISNULL(c.phys_tax_id,''),'-','') AS PROV_TAX_ID,                              
REPLACE(c.phys_last_name,',','') AS PROV_LAST_NAME,                                
REPLACE(c.phys_first_name,',','') AS PROV_FIRST_NAME,                                
REPLACE(c.facility_lab_name,',','') AS FACILITY_NAME,                                
'MER' AS LOB_CD,                
LTRIM(RTRIM(iex.external_rec_id)) AS FIN_NBR                         
FROM (SELECT diag.Enc_Id, diag.Diag_Code, Diag_Order            
 FROM (SELECT ed.enc_id AS Enc_id,                 
 ed.icd9cm_code_id AS Diag_Code,                
 ROW_NUMBER() OVER(PARTITION BY ed.enc_id ORDER BY ed.enc_id, ed.seq_nbr) AS Diag_Order            
 FROM NGPROD..encounter_diags ed                
 ) diag            
WHERE diag.diag_order <= 24            
) AS diag_list                
PIVOT                
(MAX(diag_code) FOR diag_order IN ([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12],[13],[14],[15],[16],[17],[18],[19],[20],[21],[22],[23],[24])             
) AS Pivot1                
JOIN NGPROD..claims c (NOLOCK) ON c.enc_id = Pivot1.enc_id                             
JOIN NGPROD..claim_detail cd (NOLOCK) ON c.claim_id = cd.claim_id                  
JOIN NGPROD..person_payer pp (NOLOCK) ON c.payer_id = pp.payer_id AND c.person_id = pp.person_id   
	AND pp.delete_ind = 'N'     
JOIN NGPROD..patient_encounter pe (NOLOCK) ON pe.enc_id = c.enc_id                     
JOIN NGPROD..intrf_enc_xref iex (NOLOCK) ON pe.enc_id = iex.internal_rec_id  AND iex.external_system_id = '61'                               
WHERE c.claim_payer_name IN ('Medicare Humana Gold','Medicare Humana Advantage','Medicare Humana Gold Plus HMO',                            
'Medicare Humana','Medicare Humana Choice PPO','Medicare Humana Gold','Medicare Humana PFFS','Medicare Humana TRS')                            
AND CAST(cd.service_from_date AS DATE) >= @StartDate                                
AND CAST(cd.service_from_date AS DATE) < @EndDate                 
UNION                
SELECT DISTINCT                
'CMG_COVENANT' AS GROUP_NAME,                                
'' AS GROUPER_ID,                                
REPLACE(ISNULL(c.phys_tax_id,''),'-','') BP_TAX_ID,                                
ISNULL(c.emc_phys_id,'') AS BP_NPI_ID,                                
UPPER(pp.policy_nbr) AS MBR_H,                                
REPLACE(c.patient_last_name,',','') AS MBR_LAST_NAME,                                
REPLACE(c.patient_first_name,',','') AS MBR_FIRST_NAME,                                
CONVERT(VARCHAR(10), CAST(c.patient_birthdate AS DATE),101) AS MBR_DOB,                                
ISNULL(c.patient_sex,'') AS MBR_GENDER,                                
'' AS MBR_HIC_NBR,                                
ISNULL(REPLACE(REPLACE(cd.line_charges,'$',''),',',''),'') AS CHARGE_AMT,                                
ISNULL(REPLACE(REPLACE(cd.pat_paid_amt,'$',''),',',''),'') AS PAID_AMT,                                
ISNULL(REPLACE(REPLACE(cd.allowed_amt,'$',''),',',''),'') AS ALLOW_AMT,                                
'' AS TYPE_OF_BILL,                                
'11' AS PLACE_OF_TREATMENT,                                
ISNULL(c.patient_control_nbr,'') AS ENCOUNTER_ID,                                
CONVERT(VARCHAR(10), CAST(cd.service_from_date AS DATE),101) AS DOS_FROM,                                
CONVERT(VARCHAR(10), CAST(cd.service_to_date AS DATE),101) AS DOS_THRU,                                
ISNULL(REPLACE(Pivot1.[25],'.',''),'') AS ICD_PRIMARY_CODE,                                
ISNULL(REPLACE(Pivot1.[25],'.',''),'') AS ICD_CODE1,                                
ISNULL(REPLACE(Pivot1.[26],'.',''),'') AS ICD_CODE2,                                
ISNULL(REPLACE(Pivot1.[27],'.',''),'') AS ICD_CODE3,                                
ISNULL(REPLACE(Pivot1.[28],'.',''),'') AS ICD_CODE4,                                
ISNULL(REPLACE(Pivot1.[29],'.',''),'') AS ICD_CODE5,                                
ISNULL(REPLACE(Pivot1.[30],'.',''),'') AS ICD_CODE6,                                
ISNULL(REPLACE(Pivot1.[31],'.',''),'') AS ICD_CODE7,               
ISNULL(REPLACE(Pivot1.[32],'.',''),'') AS ICD_CODE8,                                
ISNULL(REPLACE(Pivot1.[33],'.',''),'') AS ICD_CODE9,                                
ISNULL(REPLACE(Pivot1.[34],'.',''),'') AS ICD_CODE10,                                
ISNULL(REPLACE(Pivot1.[35],'.',''),'') AS ICD_CODE11,                                
ISNULL(REPLACE(Pivot1.[36],'.',''),'') AS ICD_CODE12,                                
ISNULL(REPLACE(Pivot1.[37],'.',''),'') AS ICD_CODE13,                                
ISNULL(REPLACE(Pivot1.[38],'.',''),'') AS ICD_CODE14,                                
ISNULL(REPLACE(Pivot1.[39],'.',''),'') AS ICD_CODE15,                                
ISNULL(REPLACE(Pivot1.[40],'.',''),'') AS ICD_CODE16,                               
ISNULL(REPLACE(Pivot1.[41],'.',''),'') AS ICD_CODE17,                                
ISNULL(REPLACE(Pivot1.[42],'.',''),'') AS ICD_CODE18,                                
ISNULL(REPLACE(Pivot1.[43],'.',''),'') AS ICD_CODE19,                                
ISNULL(REPLACE(Pivot1.[44],'.',''),'') AS ICD_CODE20,                                
ISNULL(REPLACE(Pivot1.[45],'.',''),'') AS ICD_CODE21,                                
ISNULL(REPLACE(Pivot1.[46],'.',''),'') AS ICD_CODE22,                                
ISNULL(REPLACE(Pivot1.[47],'.',''),'') AS ICD_CODE23,                                
ISNULL(REPLACE(Pivot1.[48],'.',''),'') AS ICD_CODE24,                                
'P' AS CLAIM_TYPE,                                
UPPER(cd.hcpcs_procedure_code) AS HCPCS_CPT_CD,                                
ISNULL(cd.hcpcs_modifier_1,'') AS CPT_MODIFIER_A,                                
ISNULL(cd.hcpcs_modifier_2,'') AS CPT_MODIFIER_B,                                
'' AS REV_CODE,                                
ISNULL(cd.rendering_provider_nbr,'') AS PROV_NPI,                                
REPLACE(ISNULL(c.phys_tax_id,''),'-','') AS PROV_TAX_ID,                                
REPLACE(c.phys_last_name,',','') AS PROV_LAST_NAME,                                
REPLACE(c.phys_first_name,',','') AS PROV_FIRST_NAME,                                
REPLACE(c.facility_lab_name,',','') AS FACILITY_NAME,                                
'MER' AS LOB_CD,                
LTRIM(RTRIM(iex.external_rec_id)) AS FIN_NBR                         
FROM (SELECT diag.Enc_Id, diag.Diag_Code, Diag_Order            
 FROM (SELECT ed.enc_id AS Enc_id,                
 ed.icd9cm_code_id AS Diag_Code,                
 ROW_NUMBER() OVER(PARTITION BY ed.enc_id ORDER BY ed.enc_id, ed.seq_nbr) AS Diag_Order            
 FROM NGPROD..encounter_diags ed                
 ) diag            
WHERE diag.diag_order >= 25 AND diag.diag_order <= 48            
) AS diag_list                
PIVOT                
(MAX(diag_code) FOR diag_order IN ([25],[26],[27],[28],[29],[30],[31],[32],[33],[34],[35],[36],[37],[38],[39],[40],[41],[42],[43],[44],[45],[46],[47],[48])                
) AS Pivot1                
JOIN NGPROD..claims c (NOLOCK) ON c.enc_id = Pivot1.enc_id                             
JOIN NGPROD..claim_detail cd (NOLOCK) ON c.claim_id = cd.claim_id                  
JOIN NGPROD..person_payer pp (NOLOCK) ON c.payer_id = pp.payer_id AND c.person_id = pp.person_id   
	AND pp.delete_ind = 'N'     
JOIN NGPROD..patient_encounter pe (NOLOCK) ON pe.enc_id = c.enc_id                     
JOIN NGPROD..intrf_enc_xref iex (NOLOCK) ON pe.enc_id = iex.internal_rec_id  AND iex.external_system_id = '61'                               
WHERE c.claim_payer_name IN ('Medicare Humana Gold','Medicare Humana Advantage','Medicare Humana Gold Plus HMO',                            
'Medicare Humana','Medicare Humana Choice PPO','Medicare Humana Gold','Medicare Humana PFFS','Medicare Humana TRS')                            
AND CAST(cd.service_from_date AS DATE) >= @StartDate                                
AND CAST(cd.service_from_date AS DATE) < @EndDate                 
ORDER BY MBR_LAST_NAME, MBR_FIRST_NAME, ENCOUNTER_ID,HCPCS_CPT_CD 