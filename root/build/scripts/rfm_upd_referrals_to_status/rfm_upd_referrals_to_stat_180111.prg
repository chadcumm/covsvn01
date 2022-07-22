/**************************************************************************************
					rfm_upd_referrals_to_stat_180111.prg
 
AUTHOR:		Chris Timko (Chris.Timko@cerner.com)
 
COMMENTS:  	*	Read referral IDs from a supplied .csv file
			* 	Update fields of the passed in referrals to the status provided.
				*	referral_status_cd
				*	updt_dt_tm
				*	updt_task
			*	Add a new row to the REFERRAL_HIST table.
 
REQUIRES:   * Referral Management is in use at client site.
 
CALLS:      * Nothing
 
CALLED-BY:  * Nothing.  Manually run script.

************************************************************************************/
drop program rfm_upd_referrals_to_stat_180111:dba go
create program rfm_upd_referrals_to_stat_180111:dba

prompt
	"Output to File/Printer/MINE" = "MINE"
	, "CSV file path (absolute): " = ""
	, "CDF Meaning of status to update to: " = ""
 
with OUTDEV, CSVPATH, UPDATECDFMEANING

/**************************************************************
    DECLARED VARIABLES
**************************************************************/
free set _NEWSTATUSCD
declare _NEWSTATUSCD		= f8 with global, constant(UAR_GET_CODE_BY("MEANING", 4002978, nullterm($UPDATECDFMEANING)))

/**************************************************************
    DECLARED CONSTANTS
**************************************************************/
free set _RS_GROW_SIZE
declare _RS_GROW_SIZE   	= i2 with persistscript, CONSTANT ( 10 )

/**************************************************************
    DECLARED RECORD STRUCTURES
**************************************************************/
free set referrals_to_update
record referrals_to_update(
	1 referral_cnt		= i4
	1 referrals[*]
		2 referral_id 	= f8
) with persistscript

free set referrals_failures_select
record referrals_failures_select(
	1 referral_cnt		= i4
	1 referrals[*]
		2 referral_id 	= f8
) with persistscript

free set referrals_failures_update
record referrals_failures_update(
	1 referral_cnt		= i4
	1 referrals[*]
		2 referral_id 	= f8
) with persistscript

free set referrals_failures_insert
record referrals_failures_insert(
	1 referral_cnt		= i4
	1 referrals[*]
		2 referral_id 	= f8
) with persistscript

/**************************************************************
    DECLARED SUBROUTINES
**************************************************************/
declare GetReferrals( null ) = null with protect, copy
declare UpdateReferrals( null ) = null with protect, copy

/**************************************************************
    DEFINED SUBROUTINES
**************************************************************/
subroutine GetReferrals( null )
	declare iReferralCount		= i4 with noconstant(0)
	declare input_file_name 	= gvc with noconstant("")
	
	set input_file_name = trim($CSVPATH)
	call echo(build("File Name: ", input_file_name))
	set stat = findfile(value(input_file_name))
	
	if (stat = 1)
		free set input_file_loc
		set logical = input_file_loc value(input_file_name)
		
		free define rtl3
		define rtl3 is "input_file_loc"
		
		select into "nl:"
			r.line
		from
			rtl3t r
		head report
			iReferralCount = 0
			stat = alterlist ( referrals_to_update->referrals, _RS_GROW_SIZE )
		detail 		
			bBreak = 0
			iLineCount = 1
			while(bBreak != 1)
				sValue = trim(piece(r.line, ",", iLineCount, "notfound"))
				
				if(sValue = "notfound")
					bBreak = 1
		  		else 
		  			if ( mod( iReferralCount, _RS_GROW_SIZE ) = 1 )
				   		stat = alterlist ( referrals_to_update->referrals, iReferralCount + _RS_GROW_SIZE )
					endif	
				
					iReferralCount = iReferralCount + 1
					referrals_to_update->referrals[iReferralCount]->referral_id = cnvtreal(sValue)
				endif
				
				iLineCount = iLineCount + 1	
			endwhile				
		with nocounter	
				
		set stat = alterlist ( referrals_to_update->referrals, iReferralCount)
		set referrals_to_update->referral_cnt = iReferralCount
	else
		call echo("file not found")
	endif 
end

subroutine UpdateReferrals ( null )
	declare bFound = i2 with noconstant(0)

	declare selectFailure = i4 with noconstant(0)
	set stat = alterlist ( referrals_failures_select->referrals, _RS_GROW_SIZE )
	
	declare updateFailure = i4 with noconstant(0)
	set stat = alterlist ( referrals_failures_update->referrals, _RS_GROW_SIZE )
	
	declare insertFailure = i4 with noconstant(0)
	set stat = alterlist ( referrals_failures_insert->referrals, _RS_GROW_SIZE )
	
	set sErrMsg = fillstring(132, " ")
	set iErrCode = error(sErrMsg,1)	

	for(iLoop = 1 to referrals_to_update->referral_cnt)
		set bFound = 0
		
		;Ensure that the referral exists in the REFERRAL table.
		select into "nl"
			r.referral_id
		from 
			referral r
		plan r
			where r.referral_id = referrals_to_update->referrals[iLoop]->referral_id
		detail
			bFound = 1
		with nocounter

		set iErrCode = error(sErrMsg,1)
		if(iErrCode > 0 or bFound != 1)	
	  		if ( mod( selectFailure, _RS_GROW_SIZE ) = 1 )
		   		set stat = alterlist ( referrals_failures_select->referrals, selectFailure + _RS_GROW_SIZE )
			endif	
		
			set selectFailure = selectFailure + 1
			set referrals_failures_select->referrals[selectFailure]->referral_id = referrals_to_update->referrals[iLoop]->referral_id
		else
			; Update the referral status, updt dttm, and updt task on REFERRAL
			update into 
				REFERRAL r
			set 
				r.updt_dt_tm = cnvtdatetime(curdate, curtime3),
				r.updt_task	= 0166981,
				r.updt_cnt = r.updt_cnt + 1,
				r.updt_id = 0,
				r.referral_status_cd = _NEWSTATUSCD,
				r.referral_substatus_cd = 0
			plan r
				where r.referral_id = referrals_to_update->referrals[iLoop]->referral_id
			with nocounter
			
			set iErrCode = error(sErrMsg,1)
			if (iErrCode > 0)
		  		if ( mod( updateFailure, _RS_GROW_SIZE ) = 1 )
			   		set stat = alterlist ( referrals_failures_update->referrals, updateFailure + _RS_GROW_SIZE )
				endif	
				
				set updateFailure = updateFailure + 1	
				set referrals_failures_update->referrals[updateFailure]->referral_id = referrals_to_update->referrals[iLoop]->referral_id
				
				rollback
			else	
				;Insert into the REFERRAL_HIST table
				INSERT INTO REFERRAL_HIST rh
				(
					rh.REFERRAL_HIST_ID, rh.REFERRAL_ID, rh.ADMIT_BOOKING_TYPE_CD, rh.INSTRUCTIONS_TO_STAFF_TEXT_ID, 
					rh.INTENDED_BOOKING_TYPE_CD, rh.LAST_PERFORMED_ACTION_CD, rh.LAST_PERFORMED_ACTION_DT_TM, 
					rh.MEDICAL_SERVICE_CD, rh.PERSON_ID, rh.REFER_FROM_ORGANIZATION_ID, rh.REFER_FROM_PROVIDER_ID, 
					rh.REFER_TO_ORGANIZATION_ID, rh.REFER_TO_PROVIDER_ID, rh.REFERRAL_CATEGORY_CD, rh.REFERRAL_PRIORITY_CD, 
					rh.REFERRAL_REASON_TEXT_ID, rh.REFERRAL_RECEIVED_DT_TM, rh.REFERRAL_SOURCE_CD, rh.REFERRAL_WRITTEN_DT_TM, 
					rh.RESPONSIBLE_PROVIDER_ID, rh.SERVICE_CATEGORY_CD, rh.STAND_BY_CD, rh.SUSPECTED_CANCER_TYPE_CD, 
					rh.TREATMENT_COMPLETED_DT_TM, rh.TREATMENT_TO_DATE_TEXT_ID, rh.WAITLIST_REMOVAL_DT_TM, rh.WAIT_STATUS_CD, 
					rh.CREATE_SYSTEM_CD, rh.CREATE_DT_TM,rh.ACTIVE_IND, rh.ACTIVE_STATUS_DT_TM, rh.ACTIVE_STATUS_PRSNL_ID,
					rh.ACTIVE_STATUS_CD, rh.UPDT_ID, rh.UPDT_DT_TM, rh.UPDT_TASK, rh.UPDT_APPLCTX, rh.UPDT_CNT, rh.SERVICE_TYPE_REQUESTED_CD, 
					rh.EXTERNAL_SCHEDULED_DT_TM, rh.SERVICE_BY_DT_TM, rh.REQUESTED_START_DT_TM, rh.OUTBOUND_ASSIGNED_PRSNL_ID, 
					rh.INBOUND_ASSIGNED_PRSNL_ID, rh.OUTBOUND_ENCNTR_ID, rh.ORDER_ID, rh.REFERRAL_STATUS_CD, rh.REFER_FROM_PRACTICE_SITE_ID, 
					rh.REFER_TO_PRACTICE_SITE_ID, rh.REFERRAL_ORIG_RECEIVED_DT_TM, rh.AUTHORIZATION_CODE_TXT, rh.REFER_FROM_LOC_CD,
					rh.REFERRAL_SUBSTATUS_CD
				)
				( 
					SELECT
						cnvtreal(seq(referral_seq,nextval)), r.REFERRAL_ID, r.ADMIT_BOOKING_TYPE_CD, r.INSTRUCTIONS_TO_STAFF_TEXT_ID, 
						r.INTENDED_BOOKING_TYPE_CD, r.LAST_PERFORMED_ACTION_CD, r.LAST_PERFORMED_ACTION_DT_TM, r.MEDICAL_SERVICE_CD, 
						r.PERSON_ID, r.REFER_FROM_ORGANIZATION_ID, r.REFER_FROM_PROVIDER_ID, r.REFER_TO_ORGANIZATION_ID, r.REFER_TO_PROVIDER_ID, 
						r.REFERRAL_CATEGORY_CD, r.REFERRAL_PRIORITY_CD, r.REFERRAL_REASON_TEXT_ID, r.REFERRAL_RECEIVED_DT_TM, r.REFERRAL_SOURCE_CD, 
						r.REFERRAL_WRITTEN_DT_TM, r.RESPONSIBLE_PROVIDER_ID, r.SERVICE_CATEGORY_CD, r.STAND_BY_CD, r.SUSPECTED_CANCER_TYPE_CD, 
						r.TREATMENT_COMPLETED_DT_TM, r.TREATMENT_TO_DATE_TEXT_ID, r.WAITLIST_REMOVAL_DT_TM, r.WAIT_STATUS_CD, r.CREATE_SYSTEM_CD, 
						r.CREATE_DT_TM, r.ACTIVE_IND, r.ACTIVE_STATUS_DT_TM, r.ACTIVE_STATUS_PRSNL_ID, r.ACTIVE_STATUS_CD, r.UPDT_ID, 
						r.UPDT_DT_TM, r.UPDT_TASK, r.UPDT_APPLCTX, r.UPDT_CNT, r.SERVICE_TYPE_REQUESTED_CD, r.EXTERNAL_SCHEDULED_DT_TM, 
						r.SERVICE_BY_DT_TM, r.REQUESTED_START_DT_TM, r.OUTBOUND_ASSIGNED_PRSNL_ID, r.INBOUND_ASSIGNED_PRSNL_ID, r.OUTBOUND_ENCNTR_ID, 
						r.ORDER_ID, r.REFERRAL_STATUS_CD, r.REFER_FROM_PRACTICE_SITE_ID, r.REFER_TO_PRACTICE_SITE_ID, r.REFERRAL_ORIG_RECEIVED_DT_TM, 
						r.AUTHORIZATION_CODE_TXT, r.REFER_FROM_LOC_CD,r.REFERRAL_SUBSTATUS_CD
					FROM
						referral r
					WHERE 
						r.referral_id = referrals_to_update->referrals[iLoop]->referral_id
				)
				with nocounter
			  			

				
				set iErrCode = error(sErrMsg,1)
				if (iErrCode > 0)
		  			if ( mod( insertFailure, _RS_GROW_SIZE ) = 1 )
			   			set stat = alterlist ( referrals_failures_insert->referrals, insertFailure + _RS_GROW_SIZE )
					endif	
			
					set insertFailure = insertFailure + 1
					set referrals_failures_insert->referrals[insertFailure]->referral_id = referrals_to_update->referrals[iLoop]->referral_id
					
					rollback
				else								
					commit
				endif
			endif
		endif
	endfor
	
	set stat = alterlist ( referrals_failures_select->referrals, selectFailure)
	set referrals_failures_select->referral_cnt = selectFailure	
		
	set stat = alterlist ( referrals_failures_update->referrals, updateFailure)
	set referrals_failures_update->referral_cnt = updateFailure	
		
	set stat = alterlist ( referrals_failures_insert->referrals, insertFailure)
	set referrals_failures_insert->referral_cnt = insertFailure	
end ; subroutine UpdateReferrals

/**************************************************************
    EXECUTED CODE
**************************************************************/
if (_NEWSTATUSCD = -1)
	call echo ("Status Code meaning provided is not defined in the codeset.")
else
	call GetReferrals( null )
	call echo(build("Number of Referrals imported from .CSV: ", referrals_to_update->referral_cnt))
	
	if( referrals_to_update->referral_cnt > 0 )
		
		call UpdateReferrals( null )
		call echo(build("Sucessfully Updated Records:", 
			referrals_to_update->referral_cnt - referrals_failures_select->referral_cnt -
			referrals_failures_update->referral_cnt - referrals_failures_insert->referral_cnt))
		
		if (referrals_failures_select->referral_cnt > 0)
			call echo(build("Number of Referrals failed to Select: ", referrals_failures_select->referral_cnt))
			call echorecord(referrals_failures_select->referrals)
		endif
		
		if(referrals_failures_update->referral_cnt > 0)
			call echo(build("Number of Referrals failed to Update: ", referrals_failures_update->referral_cnt))
			call echorecord(referrals_failures_update->referrals)
		endif
		
		if(referrals_failures_insert->referral_cnt > 0)
			call echo(build("Number of Referrals failed to Insert: ", referrals_failures_insert->referral_cnt))
			call echorecord(referrals_failures_insert->referrals)
		endif
	endif
endif
	
end
go
