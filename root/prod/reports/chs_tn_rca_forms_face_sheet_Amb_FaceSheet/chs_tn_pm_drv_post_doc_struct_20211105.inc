;281405++
/********
 
  When packaging this include file the BOM must also include SCRIPT\PMDBDocs\pm_prt_documents.prg
 
********/
;*281405--
 
  free record post_doc_rec
  record post_doc_rec
  ( 1 person_id = f8
    1 encntr_id = f8
    1 org_id = f8 ;281405
 
    1 bStruct_loaded = i2 ;281405 This should only be set from TRUE by PM_PRT_DOCUMENTS and never set to TRUE in a layout program
 
    1 CurrentDate = vc
    1 CurrentDateTime = vc
    1 Current_dt_tm = dq8  ;70552
    1 Patient_Title = vc
    1 Patient_Prefix = vc
    1 Patient_FullName = vc
    1 Patient_FirstName = vc
    1 Patient_MiddleName = vc
    1 Patient_LastName = vc
 
;281405++
    1 Patient_Prev_Title = vc
    1 Patient_Prev_Prefix = vc
    1 Patient_Prev_FullName = vc
    1 Patient_Prev_FirstName = vc
    1 Patient_Prev_MiddleName = vc
    1 Patient_Prev_LastName = vc
;281405--
 
    1 Patient_MRN = vc
    1 Patient_SSN = vc
    1 Patient_DOB = vc
    1 Patient_birth_dt_tm = dq8  ;70552
    1 Patient_birth_tz = i4  ;237888
    1 Patient_Age = vc ;168622
    1 Patient_Sex = vc
    1 Patient_HomeAddr1 = vc
    1 Patient_HomeAddr2 = vc
    1 Patient_HomeAddr3 = vc
    1 Patient_HomeAddr4 = vc
    1 Patient_Zip = vc
    1 Patient_City = vc
    1 Patient_State = vc
    1 Patient_Country = vc
    1 Patient_HomePhone = vc
    1 Patient_LivingWill = vc ;281405
    1 Patient_Race = vc ;281405
    1 Patient_Religion = vc ;281405
    ;Encounter details
    1 ServiceCategory = vc
    1 MedicalService = vc
    ;1 EncntrType = vc  ;157201
    1 Accommodation = vc
    1 AccommodationReason = vc
    1 RequestedAccommodation = vc
    1 AccompBy = vc
    1 AdmitMode = vc
    1 AdmitSrc = vc
    1 AdmitType = vc
    1 AdmitWithMeds = vc
    1 ALCDecompDate = vc
    1 ALCDecomp_dt_tm = dq8  ;70552
    1 ALCReason = vc
    1 ALTLevelCare = vc
    1 ALTLevelCareDate = vc
    1 ALTLevelCare_dt_tm = dq8   ;70552
    1 ALTResultDest = vc
    1 AmbulatoryCondition = vc
    1 ArriveDate = vc
    1 Arrive_dt_tm = dq8  ;70552
    1 AssignToLocDate = vc
    1 AssignToLoc_dt_tm = dq8  ;70552
    1 BBDProcedure = vc
    1 ChartCompleteDate = vc
    1 ChartComplete_dt_tm = dq8  ;70552
    1 ContractStatus = vc
    1 Courtesy = vc
    1 CreateDate = vc
    1 Create_dt_tm = dq8  ;70552
    1 DepartDate = vc
    1 Depart_dt_tm = dq8  ;70552
    1 DietType = vc
    1 DischDisposition = vc
    1 DischDate = vc
    1 Disch_dt_tm = dq8  ;70552
    1 DischToLoc = vc
    1 DocRcvdDate = vc
    1 DocRcvd_dt_tm = dq8  ;70552
    1 EncntrStatus = vc
    1 EncntrType = vc
    1 EncntrTypeClass = vc
    1 EstArriveDate = vc
    1 EstArrive_dt_tm = dq8  ;70552
    1 EstDepartDate = vc
    1 EstDepart_dt_tm = dq8  ;70552
    1 EncntrCreatePrsnl = vc
    1 EstLengthOfStay = vc
    1 FinancialClass = vc
    1 GuarantorType = vc
    1 InpatientAdmitDate = vc
    1 InpatientAdmit_dt_tm = dq8  ;70552
    1 Isolation = vc
    1 Location = vc
    1 Bed = vc
    1 Building = vc
    1 Facility = vc
    1 NurseUnit = vc
    1 Room = vc
    1 TempLocation = vc
    1 MentalCategory = vc
    1 MentalHealth = vc
    1 MentalHealthDate = vc
    1 MentalHealth_dt_tm = dq8  ;70552
    1 PatientClass = vc
    1 ProgramService = vc
    1 PsychiatricStatus = vc
    1 ReAdmit = vc
    1 ReasonForVisit = vc
    1 ReferralRcvdDate = vc
    1 ReferralRcvd_dt_tm = dq8  ;70552
    1 ReferringComment = vc
    1 ReferFacility = vc
    1 Region = vc
    1 RegDate = vc
    1 Reg_dt_tm = dq8  ;70552
    1 Safekeeping = vc
    1 SpecialtyUnit = vc
    1 Trauma = vc
    1 TraumaDate = vc
    1 Trauma_dt_tm = dq8  ;70552
    1 Triage = vc
    1 TriageDate = vc
    1 Triage_dt_tm = dq8  ;70552
    1 Valuable = vc
    1 VIP = vc
    1 VisitorStatus = vc
    1 ZeroBalanceDate = vc
    1 ZeroBalance_dt_tm = dq8  ;70552
    1 OrgName = vc
    1 OrgAddr1 = vc
    1 OrgAddr2 = vc
    1 OrgAddr3 = vc
    1 OrgAddr4 = vc
    1 OrgCity = vc
    1 OrgState = vc
    1 OrgZip = vc
    1 OrgCountry = vc
    1 OrgPhone = vc
    1 OrgTrustName = vc ;168622
 
    1 Guardian_Id = f8 ;281405
    1 Guardian_FullName = vc
    1 Guardian_Title = vc
    1 Guardian_Prefix = vc
    1 Guardian_FirstName = vc
    1 Guardian_LastName = vc
    1 Guardian_NameFullFormatted = vc ;281405
    1 Guardian_birth_dt_tm = dq8 ;281405
    1 Guardian_Birth_tz = i4 ;281405
    1 Guardian_Marital = vc ;281405
 
    1 Guarantor_Id = f8 ;281405
    1 Guarantor_FullName = vc
    1 Guarantor_Title = vc
    1 Guarantor_Prefix = vc
    1 Guarantor_FirstName = vc
    1 Guarantor_LastName = vc
    1 Guarantor_NameFullFormatted = vc ;281405
 
    1 NOK_Id = f8 ;281405
    1 NOK_FullName = vc
    1 NOK_Title = vc
    1 NOK_Prefix = vc
    1 NOK_FirstName = vc
    1 NOK_LastName = vc
    1 NOK_NameFullFormatted = vc ;281405
    1 NOK_birth_dt_tm = dq8 ;281405
    1 NOK_Birth_tz = i4 ;281405
    1 NOK_Marital = vc ;281405
 
    1 EMC_Id = f8 ;281405
    1 EMC_FullName = vc
    1 EMC_Title = vc
    1 EMC_Prefix = vc
    1 EMC_FirstName = vc
    1 EMC_LastName = vc
    1 EMC_NameFullFormatted = vc ;281405
    1 EMC_birth_dt_tm = dq8 ;281405
    1 EMC_Birth_tz = i4 ;281405
    1 EMC_Marital = vc ;281405
;281405++
    1 EMC_Home_Addr1 = vc
    1 EMC_Home_Addr2 = vc
    1 EMC_Home_Addr3 = vc
    1 EMC_Home_Addr4 = vc
    1 EMC_Home_City = vc
    1 EMC_Home_State = vc
    1 EMC_Home_Zip = vc
    1 EMC_Home_Country = vc
;281405--
 
    1 PCPDoc_Id = f8 ;281405
    1 PCP_Title = vc
    1 PCP_FullName = vc
    1 PCP_FirstName = vc
    1 PCP_LastName = vc
    1 PCP_NameFullFormatted = vc ;281405
    1 PCP_Addr1 = vc
    1 PCP_Addr2 = vc
    1 PCP_Addr3 = vc
    1 PCP_Addr4 = vc
    1 PCP_City = vc
    1 PCP_State = vc
    1 PCP_Zip = vc
    1 PCP_Country = vc
    1 PCP_Phone = vc
    ;+75998
    1 PCP_Dmg_Addr_cd = f8
    1 PCP_Dmg_Addr1 = vc
    1 PCP_Dmg_Addr2 = vc
    1 PCP_Dmg_Addr3 = vc
    1 PCP_Dmg_Addr4 = vc
    1 PCP_Dmg_City = vc
    1 PCP_Dmg_State = vc
    1 PCP_Dmg_Zip = vc
    1 PCP_Dmg_Country = vc
    1 PCP_Dmg_Phone_cd = f8
    1 PCP_Dmg_Phone = vc
    ;-75998
 
    1 FamilyDoc_Id = f8 ;281405
    1 FamilyDoc_Title = vc
    1 FamilyDoc_FullName = vc
    1 FamilyDoc_FirstName = vc
    1 FamilyDoc_LastName = vc
    1 FamilyDoc_NameFullFormatted = vc ;281405
    1 FamilyDoc_Addr1 = vc
    1 FamilyDoc_Addr2 = vc
    1 FamilyDoc_Addr3 = vc
    1 FamilyDoc_Addr4 = vc
    1 FamilyDoc_City = vc
    1 FamilyDoc_State = vc
    1 FamilyDoc_Zip = vc
    1 FamilyDoc_Country = vc
    1 FamilyDoc_Phone = vc
    ;+75998
    1 Family_Dmg_Addr_cd = f8
    1 Family_Dmg_Addr1 = vc
    1 Family_Dmg_Addr2 = vc
    1 Family_Dmg_Addr3 = vc
    1 Family_Dmg_Addr4 = vc
    1 Family_Dmg_City = vc
    1 Family_Dmg_State = vc
    1 Family_Dmg_Zip = vc
    1 Family_Dmg_Country = vc
    1 Family_Dmg_Phone_cd = f8
    1 Family_Dmg_Phone = vc
    ;-75998
 
    1 AttendDoc_Id = f8      ;75747
    1 AttendDoc_Title  = vc
    1 AttendDoc_FullName = vc
    1 AttendDoc_FirstName = vc
    1 AttendDoc_LastName = vc
    1 AttendDoc_NameFullFormatted =vc ;281405
    1 AttendDoc_Addr1 = vc
    1 AttendDoc_Addr2 = vc
    1 AttendDoc_Addr3 = vc
    1 AttendDoc_Addr4 = vc
    1 AttendDoc_City = vc
    1 AttendDoc_State = vc
    1 AttendDoc_Zip = vc
    1 AttendDoc_Country = vc
    1 AttendDoc_Phone = vc
    1 AttendDoc_NPI = vc ;444138
    ;+75998
    1 Attend_Dmg_Addr_cd = f8
    1 Attend_Dmg_Addr1 = vc
    1 Attend_Dmg_Addr2 = vc
    1 Attend_Dmg_Addr3 = vc
    1 Attend_Dmg_Addr4 = vc
    1 Attend_Dmg_City = vc
    1 Attend_Dmg_State = vc
    1 Attend_Dmg_Zip = vc
    1 Attend_Dmg_Country = vc
    1 Attend_Dmg_Phone_cd = f8
    1 Attend_Dmg_Phone = vc
    ;-75998
 
    1 ReferDoc_Id = f8 ;281405
    1 ReferDoc_Title  = vc
    1 ReferDoc_FullName = vc
    1 ReferDoc_FirstName = vc
    1 ReferDoc_LastName = vc
    1 ReferDoc_NameFullFormatted = vc ;281405
    1 ReferDoc_Addr1 = vc
    1 ReferDoc_Addr2 = vc
    1 ReferDoc_Addr3 = vc
    1 ReferDoc_Addr4 = vc
    1 ReferDoc_City = vc
    1 ReferDoc_State = vc
    1 ReferDoc_Zip = vc
    1 ReferDoc_Country = vc
    1 ReferDoc_Phone = vc
    ;+75998
    1 Refer_Dmg_Addr_cd = f8
    1 Refer_Dmg_Addr1 = vc
    1 Refer_Dmg_Addr2 = vc
    1 Refer_Dmg_Addr3 = vc
    1 Refer_Dmg_Addr4 = vc
    1 Refer_Dmg_City = vc
    1 Refer_Dmg_State = vc
    1 Refer_Dmg_Zip = vc
    1 Refer_Dmg_Country = vc
    1 Refer_Dmg_Phone_cd = f8
    1 Refer_Dmg_Phone = vc
    ;-75998
 
    1 LocationName = vc
    1 LocationAddr1 = vc
    1 LocationAddr2 = vc
    1 LocationAddr3 = vc
    1 LocationAddr4 = vc
    1 LocationCity = vc
    1 LocationState = vc
    1 LocationZip = vc
    1 LocationCountry = vc
    1 NUPhone = vc
 
    ;PM Wait List information
    1 WLAccommodation = vc
    1 WLAdmitType = vc
    1 WLEstLengthProcedure = vc
    1 WLEstArriveDate = vc
    1 WLAutoBloodInd = vc
    1 WLCommentsReDsch = vc
    1 WLDeclineStatus = vc
    1 WLDelayStatus = vc
    1 WLDeclineStatusDate = vc
    1 WLDeclineStatus_dt_tm = dq8  ;70552
    1 WLDelayStatusDate = vc
    1 WLDelayStatus_dt_tm = dq8  ;70552
    1 WLFinClass = vc
    1 WLFinClassDate = vc
    1 WLFinClass_dt_tm = dq8  ;70552
    1 WLLocation = vc
    1 WLFacility = vc
    1 WLBuilding = vc
    1 WLNurseUnit = vc
    1 WLRoom = vc
    1 WLBed = vc
    1 WLMedicalService = vc
    1 WLOtherMedCondition = vc
    1 WLPlannedAdmitDate = vc
    1 WLPlannedAdmit_dt_tm = dq8  ;70552
    1 planned_procedure_cd = f8
    1 WLPlanProcedure = vc
    1 WLPlanProcedureDate = vc
    1 WLPlanProcedure_dt_tm = dq8  ;70552
    1 WLPreAdmitAttendInd = vc
    1 WLPreAdmitClinApptDate = vc
    1 WLPreAdmitClinAppt_dt_tm = dq8  ;70552
    1 WLProvAdmitDate = vc
    1 WLProvAdmit_dt_tm = dq8  ;70552
    1 WLReasonForChange = vc
    1 WLReasonForRemovalCd = vc
    1 WLReasonForRemoval = vc
    1 WLRecommendDate = vc
    1 WLRecommend_dt_tm = dq8  ;70552
    1 WLRemovalDate = vc
    1 WLRemoval_dt_tm = dq8  ;70552
    1 WLRequestedLoc = vc
    1 WLUrgency = vc
    1 WLUrgencyDate = vc
    1 WLUrgency_dt_tm = dq8  ;70552
    1 WLStandBy = vc
    1 WLStatusReviewDate = vc
    1 WLStatusReview_dt_tm = dq8  ;70552
    1 WLStatusReview = vc
    1 WLStatus = vc
    1 WLStatusDate = vc
    1 WLStatus_dt_tm = dq8  ;70552
    1 WLPendNotifyDate = vc
    1 WLPendNotify_dt_tm = dq8  ;70552
    1 WLPendAcceptDate = vc
    1 WLPendAccept_dt_tm = dq8  ;70552
    1 WLPendPlacePriority = vc
    1 WLPendPlacePriorityDate = vc
    1 WLPendPlacePriority_dt_tm = dq8  ;70552
    1 WLAdmitCategory = vc
    1 WLAdmitBooking = vc
    1 WLManagement = vc
    1 WLStatusEndDate = vc
    1 WLStatusEnd_dt_tm = dq8  ;70552
    1 WLReferralSource = vc
    1 WLServiceTypeRequested = vc
    1 WLFunctionalDef = vc
    1 WLFunctionalDefCause = vc
    1 WLSupraServiceRequest = vc
    1 WLCommissionerRef = vc
    1 WLAppt = vc
    1 WLReferral_type = vc
    1 WLReferralReason = vc
    1 WLAttendance = vc
    1 WLReferralDate = vc
    1 WLReferral_dt_tm = dq8  ;70552
    1 WLAttendDocClinicalService = vc
    1 WLContractStatus = vc
    1 WLEstAdmitDate = vc
    1 WLEstAdmit_dt_tm = dq8  ;70552
    1 WLPlannedOps = vc
    1 WLLastDNADate = vc
    1 WLLastDNA_dt_tm = dq8  ;70552
    1 WLAdmitOfferOutcome = vc
    1 WLAdmitGuarDate = vc
    1 WLAdmitGuar_dt_tm = dq8  ;70552
    1 WLAdmitDecisionDate = vc
    1 WLAdmitDecision_dt_tm = dq8  ;70552
    1 WLPrevProvAdmitDate = vc
    1 WLPrevProvAdmit_dt_tm = dq8  ;70552
    1 WLOperation = vc
    1 WLAnesthetic = vc
    1 WLSuspendedDays = vc
    1 WLWaitingStartDate = vc
    1 WLWaitingStart_dt_tm = dq8  ;70552
    1 WLWaitingEndDate = vc
    1 WLWaitingEnd_dt_tm = dq8  ;70552
    1 WLAdjWaitingStartDate = vc
    1 WLAdjWaitingStart_dt_tm = dq8  ;70552
    1 WLApptType = vc
    1 WLApptSynonym = vc
    1 WLResource = vc
    1 WLRequestedDate = vc
    1 WLRequested_dt_tm = dq8  ;70552
    1 WLScheduleDate = vc
    1 WLSchedule_dt_tm = dq8  ;70552
    1 WLApptLocation = vc
    1 WLOrigRequestRvcDate = vc
    1 WLOrigRequestRvc_dt_tm = dq8  ;70552
    1 comment_long_text_id = f8
    1 WLComment= vc
    1 ExpectedWaitTime = vc
    1 sch_event_id = f8
    1 schedule_id = f8
    1 schedule_seq = i4
    1 appt_location_cd = f8
    1 resource_cd = f8
    1 ApptBegDate = vc
    1 ApptBeg_dt_tm = dq8  ;70552
    1 ApptEndDate = vc
    1 ApptEnd_dt_tm = dq8  ;70552
    1 ApptDuration = vc
    1 appt_type_cd = f8      ;75747
    1 ApptTypeDisplay = vc
    1 ApptTypeDesc = vc
    1 ApptDateTime = vc
    1 ApptDay = vc
    1 PrevApptDateTime = vc
    1 PrevAppt_dt_tm = dq8  ;75747
    1 ApptDesc = vc
    1 ApptResourceMnem = vc
    1 ApptResourceDesc = vc
    1 Procedure = vc
    1 Preparations = vc
    1 Directions = vc
    1 NUName = vc
    1 NUPhone = vc
    1 ContactDetails = vc
    1 ApptFacilityName = vc
    1 ApptFacilityAddr1 = vc
    1 ApptFacilityAddr2 = vc
    1 ApptFacilityAddr3 = vc
    1 ApptFacilityAddr4 = vc
    1 ApptFacilityCity = vc
    1 ApptFacilityState = vc
    1 ApptFacilityZip = vc
    1 ApptFacilityCountry = vc
    1 ApptLocationName = vc
    1 ApptLocationAddr1 = vc
    1 ApptLocationAddr2 = vc
    1 ApptLocationAddr3 = vc
    1 ApptLocationAddr4 = vc
    1 ApptLocationCity = vc
    1 ApptLocationState = vc
    1 ApptLocationZip = vc
    1 ApptLocationCountry = vc
    1 ApptLocationPhone = vc
    1 PATIENT_FIN = vc
    1 Unformatted_FIN = vc ;281405
    1 ApptFacilityPhone = vc  ;95020a
 
    ;+95020b
    1 Patient_CorrAddr1 = vc
    1 Patient_CorrAddr2 = vc
    1 Patient_CorrAddr3 = vc
    1 Patient_CorrAddr4 = vc
    1 Patient_CorrZip = vc
    1 Patient_CorrCity = vc
    1 Patient_CorrState = vc
    1 Patient_CorrCountry = vc
    ;+95020b
    1 Unformatted_MRN = vc ;170348
 
 
    ;174138++
    1 UBRN = vc
    1 ApptBegTime = vc
    1 ApptLocationExt = vc
 
    1 ApptLocBusAddr1 = vc
    1 ApptLocBusAddr2 = vc
    1 ApptLocBusAddr3 = vc
    1 ApptLocBusAddr4 = vc
    1 ApptLocBusCity = vc
    1 ApptLocBusState = vc
    1 ApptLocBusZip = vc
    1 ApptLocBusCountry = vc
    1 ApptLocBusPhone = vc
    1 ApptLocBusExt = vc
 
    1 ApptLocSecBusAddr1 = vc
    1 ApptLocSecBusAddr2 = vc
    1 ApptLocSecBusAddr3 = vc
    1 ApptLocSecBusAddr4 = vc
    1 ApptLocSecBusCity = vc
    1 ApptLocSecBusState = vc
    1 ApptLocSecBusZip = vc
    1 ApptLocSecBusCountry = vc
    1 ApptLocSecBusPhone = vc
    1 ApptLocSecBusExt = vc
 
    1 ApptBuildingAddr1 = vc
    1 ApptBuildingAddr2 = vc
    1 ApptBuildingAddr3 = vc
    1 ApptBuildingAddr4 = vc
    1 ApptBuildingCity = vc
    1 ApptBuildingState = vc
    1 ApptBuildingZip = vc
    1 ApptBuildingCountry = vc
 
    1 ApptBldBusAddr1 = vc
    1 ApptBldBusAddr2 = vc
    1 ApptBldBusAddr3 = vc
    1 ApptBldBusAddr4 = vc
    1 ApptBldBusCity = vc
    1 ApptBldBusState = vc
    1 ApptBldBusZip = vc
    1 ApptBldBusCountry = vc
    1 ApptBldBusPhone = vc
    1 ApptBldBusExt = vc
 
    1 ApptBldSecBusAddr1 = vc
    1 ApptBldSecBusAddr2 = vc
    1 ApptBldSecBusAddr3 = vc
    1 ApptBldSecBusAddr4 = vc
    1 ApptBldSecBusCity = vc
    1 ApptBldSecBusState = vc
    1 ApptBldSecBusZip = vc
    1 ApptBldSecBusCountry = vc
    1 ApptBldSecBusPhone = vc
    1 ApptBldSecBusExt = vc
    ;174138--
 
    ;+204768
    1 struct_created = i2
    1 extended_api_flag = i2
    1 Appt_Visit_Reason = vc
    1 Patient_Marital_Type = vc
    1 Patient_Bus_Phone = vc
    1 Patient_Bus_Phone_Ext = vc
    1 Patient_Mobile_Phone = vc
    1 Patient_Home_Email = vc
    1 Pat_Employer_Name = vc
    1 Pat_Employer_Status = vc
    1 Pat_Employer_Occ = vc
    1 Pat_Employer_Addr1 = vc
    1 Pat_Employer_Addr2 = vc
    1 Pat_Employer_Addr3 = vc
    1 Pat_Employer_Addr4 = vc
    1 Pat_Employer_City = vc
    1 Pat_Employer_State = vc
    1 Pat_Employer_Zip = vc
    1 Pat_Employer_Country = vc
    1 Pat_EmployerPhone = vc
    1 Guardian_PersonReltn = vc
    1 Guardian_Home_Phone = vc
    1 Guardian_Mobile_Phone = vc
    1 Guardian_Bus_Phone = vc
    1 Guardian_Bus_Phone_Ext = vc
 
 
    ;Guarantor fields (I left it Guarantor_* to match existing Guarantor fields)
    1 Guarantor_Sex = vc
    1 Guarantor_DOB = vc
    1 Guarantor_birth_dt_tm = dq8
    1 Guarantor_birth_tz = i4  ;237888
    1 Guarantor_SSN = vc
    1 Guarantor_Org_Name = vc
    1 Guarantor_Addr1 = vc
    1 Guarantor_Addr2 = vc
    1 Guarantor_Addr3 = vc
    1 Guarantor_Addr4 = vc
    1 Guarantor_City = vc
    1 Guarantor_State = vc
    1 Guarantor_Zip = vc
    1 Guarantor_Country = vc
    1 Guarantor_PersonReltn = vc
    1 Guarantor_Home_Phone = vc
    1 Guarantor_Mobile_Phone = vc
    1 Guarantor_Bus_Phone = vc
    1 Guarantor_Bus_Phone_Ext = vc
    1 Guarantor_Home_Email = vc
    1 Guarantor_Employer_Name = vc
    1 Guarantor_Employer_Status = vc
    1 Guarantor_Employer_Occ = vc
    1 Guarantor_Employer_Addr1 = vc
    1 Guarantor_Employer_Addr2 = vc
    1 Guarantor_Employer_Addr3 = vc
    1 Guarantor_Employer_Addr4 = vc
    1 Guarantor_Employer_City = vc
    1 Guarantor_Employer_State = vc
    1 Guarantor_Employer_Zip = vc
    1 Guarantor_Employer_Country = vc
    1 Guarantor_EmployerPhone = vc
    1 Guarantor_Marital = vc ;281405
 
    ;Secondary Guarantor
    1 Guarantor02_Id = f8 ;281405
    1 Guarantor02_Sex = vc
    1 Guarantor02_DOB = vc
    1 Guarantor02_birth_dt_tm = dq8
    1 Guarantor02_birth_tz = i4  ;237888
    1 Guarantor02_SSN = vc
    1 Guarantor02_Org_Name = vc
    1 Guarantor02_Addr1 = vc
    1 Guarantor02_Addr2 = vc
    1 Guarantor02_Addr3 = vc
    1 Guarantor02_Addr4 = vc
    1 Guarantor02_City = vc
    1 Guarantor02_State = vc
    1 Guarantor02_Zip = vc
    1 Guarantor02_Country = vc
    1 Guarantor02_FullName = vc
    1 Guarantor02_NameFullFormatted = vc ;281405
    1 Guarantor02_Title = vc
    1 Guarantor02_Prefix = vc
    1 Guarantor02_FirstName = vc
    1 Guarantor02_LastName = vc
    1 Guarantor02_PersonReltn = vc
    1 Guarantor02_Home_Phone = vc
    1 Guarantor02_Mobile_Phone = vc
    1 Guarantor02_Home_Email = vc
    1 Guarantor02_Bus_Phone = vc
    1 Guarantor02_Bus_Phone_Ext = vc
    1 Guarantor02_Employer_Name = vc
    1 Guarantor02_Employer_Status = vc
    1 Guarantor02_Employer_Occ = vc
    1 Guarantor02_Employer_Addr1 = vc
    1 Guarantor02_Employer_Addr2 = vc
    1 Guarantor02_Employer_Addr3 = vc
    1 Guarantor02_Employer_Addr4 = vc
    1 Guarantor02_Employer_City = vc
    1 Guarantor02_Employer_State = vc
    1 Guarantor02_Employer_Zip = vc
    1 Guarantor02_Employer_Country = vc
    1 Guarantor02_EmployerPhone = vc
    1 Guarantor02_Marital = vc ;281405
 
    ;Extend NOK
    1 NOK_PersonReltn = vc
    1 NOK_Home_Phone = vc
    1 NOK_Mobile_Phone = vc
    1 NOK_Bus_Phone = vc
    1 NOK_Bus_Phone_Ext = vc
    1 NOK_Home_Addr1 = vc
    1 NOK_Home_Addr2 = vc
    1 NOK_Home_Addr3 = vc
    1 NOK_Home_Addr4 = vc
    1 NOK_Home_City = vc
    1 NOK_Home_State = vc
    1 NOK_Home_Zip = vc
    1 NOK_Home_Country = vc
 
 
    ;Extend EMC
    1 EMC_PersonReltn = vc
    1 EMC_Home_Phone = vc
    1 EMC_Mobile_Phone = vc
    1 EMC_Bus_Phone = vc
    1 EMC_Bus_Phone_Ext = vc
 
    ;Subscriber01
    1 Sub01_FullName = vc
    1 Sub01_Title = vc
    1 Sub01_Prefix = vc
    1 Sub01_FirstName = vc
    1 Sub01_MiddleName = vc
    1 Sub01_LastName = vc
    1 Sub01_PersonReltn = vc
    1 Sub01_Sex = vc
    1 Sub01_DOB = vc
    1 Sub01_birth_dt_tm = dq8
    1 Sub01_birth_tz = i4  ;237888
    1 Sub01_Home_Phone = vc
    1 Sub01_Mobile_Phone = vc
    1 Sub01_Bus_Phone = vc
    1 Sub01_Bus_Phone_Ext = vc
    1 Sub01_Addr1 = vc
    1 Sub01_Addr2 = vc
    1 Sub01_Addr3 = vc
    1 Sub01_Addr4 = vc
    1 Sub01_City = vc
    1 Sub01_State = vc
    1 Sub01_Zip = vc
    1 Sub01_Country = vc
    1 Sub01_Employer_Name = vc
    1 Sub01_HP_Name = vc
    1 Sub01_HP_Carrier_Name = vc
    1 Sub01_HP_Beg_Date = vc
    1 Sub01_HP_beg_dt_tm = dq8
    1 Sub01_HP_End_Date = vc
    1 Sub01_Policy_Nbr = vc
    1 Sub01_Group_Nbr = vc
    1 Sub01_Group_Name = vc ;444138
    1 Sub01_HP_CoPay = vc
    1 Sub01_Name_on_Card = vc
    1 Sub01_HP_Contact_Name = vc
    1 Sub01_HP_Contact_Phone = vc
    1 Sub01_HP_Contact_Phone_Ext = vc  ;481975
    1 Sub01_Carrier_Addr1 = vc
    1 Sub01_Carrier_Addr2 = vc
    1 Sub01_Carrier_Addr3 = vc
    1 Sub01_Carrier_Addr4 = vc
    1 Sub01_Carrier_City = vc
    1 Sub01_Carrier_State = vc
    1 Sub01_Carrier_Zip = vc
    1 Sub01_Carrier_Country = vc
 
    1 Sub01_Id = f8 ;281405
    1 Sub01_HP_Member_Nbr = vc ;281405
    1 Sub01_HP_Subs_Member_Nbr = vc ;281405
    1 Sub01_HP_Addr1 = vc ;281405
    1 Sub01_HP_Addr2 = vc ;281405
    1 Sub01_HP_Addr3 = vc ;281405
    1 Sub01_HP_Addr4 = vc ;281405
    1 Sub01_HP_City = vc ;281405
    1 Sub01_HP_State = vc ;281405
    1 Sub01_HP_Zip = vc ;281405
    1 Sub01_HP_Country = vc ;281405
    1 Sub01_HP_Verify_Phone = vc ;281405
    1 Sub01_HP_Auth01_AuthNo = vc ;281405
    1 Sub01_HP_Auth01_AuthPhone = vc ;281405
    1 Sub01_Employer_Status = vc ;281405
    1 Sub01_Employer_Occ = vc ;281405
    1 Sub01_Employer_Addr1 = vc ;281405
    1 Sub01_Employer_Addr2 = vc ;281405
    1 Sub01_Employer_Addr3 = vc ;281405
    1 Sub01_Employer_Addr4 = vc ;281405
    1 Sub01_Employer_City = vc ;281405
    1 Sub01_Employer_State = vc ;281405
    1 Sub01_Employer_Zip = vc ;281405
    1 Sub01_Employer_Country = vc ;281405
    1 Sub01_EmployerPhone = vc ;281405
    1 Sub01_encntr_plan_reltn_id = f8 ;444138
 
    ;Subscriber02
    1 Sub02_FullName = vc
    1 Sub02_Title = vc
    1 Sub02_Prefix = vc
    1 Sub02_FirstName = vc
    1 Sub02_MiddleName = vc
    1 Sub02_LastName = vc
    1 Sub02_PersonReltn = vc
    1 Sub02_Sex = vc
    1 Sub02_DOB = vc
    1 Sub02_birth_dt_tm = dq8
    1 Sub02_birth_tz = i4  ;237888
    1 Sub02_Home_Phone = vc
    1 Sub02_Mobile_Phone = vc
    1 Sub02_Bus_Phone = vc
    1 Sub02_Bus_Phone_Ext = vc
    1 Sub02_Addr1 = vc
    1 Sub02_Addr2 = vc
    1 Sub02_Addr3 = vc
    1 Sub02_Addr4 = vc
    1 Sub02_City = vc
    1 Sub02_State = vc
    1 Sub02_Zip = vc
    1 Sub02_Country = vc
    1 Sub02_Employer_Name = vc
    1 Sub02_HP_Name = vc
    1 Sub02_HP_Carrier_Name = vc
    1 Sub02_HP_Beg_Date = vc
    1 Sub02_HP_beg_dt_tm = dq8
    1 Sub02_HP_End_Date = vc
    1 Sub02_Policy_Nbr = vc
    1 Sub02_Group_Nbr = vc
    1 Sub02_Group_Name = vc ;444138
    1 Sub02_HP_CoPay = vc
    1 Sub02_Name_on_Card = vc
    1 Sub02_HP_Contact_Name = vc
    1 Sub02_HP_Contact_Phone = vc
    1 Sub02_HP_Contact_Phone_Ext = vc  ;481975
    1 Sub02_Carrier_Addr1 = vc
    1 Sub02_Carrier_Addr2 = vc
    1 Sub02_Carrier_Addr3 = vc
    1 Sub02_Carrier_Addr4 = vc
    1 Sub02_Carrier_City = vc
    1 Sub02_Carrier_State = vc
    1 Sub02_Carrier_Zip = vc
    1 Sub02_Carrier_Country = vc
 
    1 Sub02_Id = f8 ;281405
    1 Sub02_HP_Member_Nbr = vc ;281405
    1 Sub02_HP_Subs_Member_Nbr = vc ;281405
    1 Sub02_HP_Addr1 = vc ;281405
    1 Sub02_HP_Addr2 = vc ;281405
    1 Sub02_HP_Addr3 = vc ;281405
    1 Sub02_HP_Addr4 = vc ;281405
    1 Sub02_HP_City = vc ;281405
    1 Sub02_HP_State = vc ;281405
    1 Sub02_HP_Zip = vc ;281405
    1 Sub02_HP_Country = vc ;281405
    1 Sub02_HP_Verify_Phone = vc ;281405
    1 Sub02_HP_Auth01_AuthNo = vc ;281405
    1 Sub02_HP_Auth01_AuthPhone = vc ;281405
    1 Sub02_Employer_Status = vc ;281405
    1 Sub02_Employer_Occ = vc ;281405
    1 Sub02_Employer_Addr1 = vc ;281405
    1 Sub02_Employer_Addr2 = vc ;281405
    1 Sub02_Employer_Addr3 = vc ;281405
    1 Sub02_Employer_Addr4 = vc ;281405
    1 Sub02_Employer_City = vc ;281405
    1 Sub02_Employer_State = vc ;281405
    1 Sub02_Employer_Zip = vc ;281405
    1 Sub02_Employer_Country = vc ;281405
    1 Sub02_EmployerPhone = vc ;281405
    1 Sub02_encntr_plan_reltn_id = f8 ;444138
 
     ;Subscriber03
    1 Sub03_FullName = vc
    1 Sub03_Title = vc
    1 Sub03_Prefix = vc
    1 Sub03_FirstName = vc
    1 Sub03_MiddleName = vc
    1 Sub03_LastName = vc
    1 Sub03_PersonReltn = vc
    1 Sub03_Sex = vc
    1 Sub03_DOB = vc
    1 Sub03_birth_dt_tm = dq8
    1 Sub03_birth_tz = i4  ;237888
    1 Sub03_Home_Phone = vc
    1 Sub03_Mobile_Phone = vc
    1 Sub03_Bus_Phone = vc
    1 Sub03_Bus_Phone_Ext = vc
    1 Sub03_Addr1 = vc
    1 Sub03_Addr2 = vc
    1 Sub03_Addr3 = vc
    1 Sub03_Addr4 = vc
    1 Sub03_City = vc
    1 Sub03_State = vc
    1 Sub03_Zip = vc
    1 Sub03_Country = vc
    1 Sub03_Employer_Name = vc
    1 Sub03_HP_Name = vc
    1 Sub03_HP_Carrier_Name = vc
    1 Sub03_HP_Beg_Date = vc
    1 Sub03_HP_beg_dt_tm = dq8
    1 Sub03_HP_End_Date = vc
    1 Sub03_Policy_Nbr = vc
    1 Sub03_Group_Nbr = vc
    1 Sub03_Group_Name = vc ;444138
    1 Sub03_HP_CoPay = vc
    1 Sub03_Name_on_Card = vc
    1 Sub03_HP_Contact_Name = vc
    1 Sub03_HP_Contact_Phone = vc
    1 Sub03_HP_Contact_Phone_Ext = vc  ;481975
    1 Sub03_Carrier_Addr1 = vc
    1 Sub03_Carrier_Addr2 = vc
    1 Sub03_Carrier_Addr3 = vc
    1 Sub03_Carrier_Addr4 = vc
    1 Sub03_Carrier_City = vc
    1 Sub03_Carrier_State = vc
    1 Sub03_Carrier_Zip = vc
    1 Sub03_Carrier_Country = vc
 
    1 Sub03_Id = f8 ;281405
    1 Sub03_HP_Member_Nbr = vc ;281405
    1 Sub03_HP_Subs_Member_Nbr = vc ;281405
    1 Sub03_HP_Addr1 = vc ;281405
    1 Sub03_HP_Addr2 = vc ;281405
    1 Sub03_HP_Addr3 = vc ;281405
    1 Sub03_HP_Addr4 = vc ;281405
    1 Sub03_HP_City = vc ;281405
    1 Sub03_HP_State = vc ;281405
    1 Sub03_HP_Zip = vc ;281405
    1 Sub03_HP_Country = vc ;281405
    1 Sub03_HP_Verify_Phone = vc ;281405
    1 Sub03_HP_Auth01_AuthNo = vc ;281405
    1 Sub03_HP_Auth01_AuthPhone = vc ;281405
    1 Sub03_Employer_Status = vc ;281405
    1 Sub03_Employer_Occ = vc ;281405
    1 Sub03_Employer_Addr1 = vc ;281405
    1 Sub03_Employer_Addr2 = vc ;281405
    1 Sub03_Employer_Addr3 = vc ;281405
    1 Sub03_Employer_Addr4 = vc ;281405
    1 Sub03_Employer_City = vc ;281405
    1 Sub03_Employer_State = vc ;281405
    1 Sub03_Employer_Zip = vc ;281405
    1 Sub03_Employer_Country = vc ;281405
    1 Sub03_EmployerPhone = vc ;281405
    ;-204768
    1 Sub03_encntr_plan_reltn_id = f8 ;444138
 
    ;+225678
    1 Sub01_Name_on_Card_Last = vc
    1 Sub01_Name_on_Card_First = vc
    1 Sub01_Name_on_Card_Middle = vc
    1 Sub01_Name_on_Card_Suffix = vc
 
    1 Sub02_Name_on_Card_Last = vc
    1 Sub02_Name_on_Card_First = vc
    1 Sub02_Name_on_Card_Middle = vc
    1 Sub02_Name_on_Card_Suffix = vc
 
    1 Sub03_Name_on_Card_Last = vc
    1 Sub03_Name_on_Card_First = vc
    1 Sub03_Name_on_Card_Middle = vc
    1 Sub03_Name_on_Card_Suffix = vc
    ;-225678
 
    1 Patient_NameFullFormatted = vc  ;234891
    1 Patient_VIP_Status = vc  ;234891b
 
;281405++
    1 Accident01_dt_tm = dq8
    1 Accident01_Accident = vc
 
    1 RegPrsnl_Id = f8
    1 RegPrsnl_Title = vc
    1 RegPrsnl_FullName = vc
    1 RegPrsnl_FirstName = vc
    1 RegPrsnl_LastName = vc
    1 RegPrsnl_NameFullFormatted = vc
 
    1 AdmitDoc_Id = f8
    1 AdmitDoc_Title = vc
    1 AdmitDoc_FullName = vc
    1 AdmitDoc_FirstName = vc
    1 AdmitDoc_LastName = vc
    1 AdmitDoc_NameFullFormatted = vc
    1 AdmitDoc_Addr1 = vc
    1 AdmitDoc_Addr2 = vc
    1 AdmitDoc_Addr3 = vc
    1 AdmitDoc_Addr4 = vc
    1 AdmitDoc_City = vc
    1 AdmitDoc_State = vc
    1 AdmitDoc_Zip = vc
    1 AdmitDoc_Country = vc
    1 AdmitDoc_Phone = vc
;281405--
;444138++
    1 AdmitDoc_NPI = vc
    1 Encntr_FacilityTaxID = vc
    1 Encntr_FacilityNPI = vc
    1 Patient_DxCode = vc
    1 DxCode_Description = vc
    1 PlaceOfService = vc
    1 FacilityPhone = vc
    1 FacilityAddr1 = vc
    1 FacilityAddr2 = vc
    1 FacilityAddr3 = vc
    1 FacilityAddr4 = vc
    1 FacilityCity = vc
    1 FacilityState = vc
    1 FacilityZip = vc
    1 FacilityCountry = vc
;444138--
  )
 
 
