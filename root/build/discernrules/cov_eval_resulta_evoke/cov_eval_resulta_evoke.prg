 
 
DROP PROGRAM cov_eval_resulta_evoke:dba GO
CREATE PROGRAM cov_eval_resulta_evoke:dba
 
%i cclsource:eks_tell_ekscommon.inc
 
CALL	echo
		(
			concat
			(
				format
				(
					curdate
					,"dd-mmm-yyyy;;d"
				)
				," "
				,format
				(
					curtime3
					,"hh:mm:ss.cc;3;m"
				)
				,"  *******  Beginning of Program shx_eval_resulta_evoke  *********"
			)
		)
 
DECLARE RETURN_TRUE						= i4	WITH	protect,	constant(100)
DECLARE RETURN_FALSE					= i4	WITH	protect,	constant(0)
DECLARE RETURN_FAILURE					= i4	WITH	protect,	constant(-1)
DECLARE find_index						= i4	WITH	protect,	noconstant(0)
DECLARE social_history_question_size	= i4	WITH	protect,	noconstant(0)
DECLARE social_history_question_count	= i4	WITH	protect,	noconstant(0)
DECLARE value1_size						= i4	WITH	protect,	noconstant(0)
DECLARE value1_count					= i4	WITH	protect,	noconstant(0)
DECLARE activity_size					= i4	WITH	protect,	noconstant(0)
DECLARE activity_count					= i4	WITH	protect,	noconstant(0)
DECLARE response_size					= i4	WITH	protect,	noconstant(0)
DECLARE response_count					= i4	WITH	protect,	noconstant(0)
DECLARE alpha_response_size				= i4	WITH	protect,	noconstant(0)
DECLARE alpha_response_count			= i4	WITH	protect,	noconstant(0)
DECLARE found_value						= i2	WITH	protect,	noconstant(0)
DECLARE task_assay_cd					= f8	WITH	protect,	noconstant(0.0)
DECLARE nomenclature_id					= f8	WITH	protect,	noconstant(0.0)
DECLARE sMsg							= vc
 
SET retval = RETURN_FALSE
 
;*********************************************************************************************************************************
;* BEGIN - Validate SOCIAL_HISTORY_QUESTION parameter
;*********************************************************************************************************************************
RECORD SOCIAL_HISTORY_QUESTIONlist
(
	1 cnt = i4
	1 qual[*]
		2 value = vc
		2 display = vc
)
 
SET orig_param = SOCIAL_HISTORY_QUESTION
 
EXECUTE eks_t_parse_list
	WITH replace(reply, SOCIAL_HISTORY_QUESTIONlist)
 
FREE SET orig_param
 
SET social_history_question_count	= 0
SET social_history_question_size	= SOCIAL_HISTORY_QUESTIONlist->cnt
 
IF (social_history_question_size < 1)
	SET sMsg = "Required variable, SOCIAL_HISTORY_QUESTION, does not exist"
	GO TO end_of_program
ENDIF
;*********************************************************************************************************************************
;* END - Validate SOCIAL_HISTORY_QUESTION parameter
;*********************************************************************************************************************************
 
 
;*********************************************************************************************************************************
;* BEGIN - Validate EVALUATION parameter
;*********************************************************************************************************************************
IF (validate(EVALUATION) = 0)
	SET sMsg = "Required variable, EVALUATION, does not exist"
	GO TO end_of_program
ENDIF
;*********************************************************************************************************************************
;* END - Validate EVALUATION parameter
;*********************************************************************************************************************************
 
 
;*********************************************************************************************************************************
;* BEGIN - Validate VALUE1 parameter
;*********************************************************************************************************************************
RECORD VALUE1list
(
	1 cnt = i4
	1 qual[*]
		2 value = vc
		2 display = vc
)
 
SET orig_param = VALUE1
 
EXECUTE eks_t_parse_list
	WITH replace(reply, VALUE1list)
 
FREE SET orig_param
 
SET value1_count	= 0
SET value1_size		= VALUE1list->cnt
 
IF (VALUE1list->cnt < 1)
	SET sMsg = "Required variable, VALUE1, does not exist"
	GO TO end_of_program
ENDIF
;*********************************************************************************************************************************
;* END - Validate VALUE1 parameter
;*********************************************************************************************************************************
 
 
;*********************************************************************************************************************************
;* BEGIN - Look for parameters in the request
;*********************************************************************************************************************************
SET activity_count					= 1
SET activity_size					= size(request->activity_qual,5)
 
;*********************************************************************************************************************************
;* BEGIN - Loop through request->activity_qual
;*********************************************************************************************************************************
WHILE (activity_count <= activity_size)
	IF
	(
		request->activity_qual[activity_count].ensure_type	IN ("REVIEW")
		AND
		request->activity_qual[activity_count].type_mean	IN ("DETAIL")
	)
		SET response_size = size(request->activity_qual[activity_count].response_qual,5)
 
		IF (response_size > 0)
			;*********************************************************************************************************************
			;* BEGIN - Loop through SOCIAL_HISTORY_QUESTIONlist->qual
			;*********************************************************************************************************************
			FOR (social_history_question_count = 1 TO social_history_question_size)
				SET task_assay_cd = cnvtreal(SOCIAL_HISTORY_QUESTIONlist->qual[social_history_question_count].value)
 
				IF (task_assay_cd > 0.0)
					;*************************************************************************************************************
					;* BEGIN - Loop through request->activity_qual[].response_qual
					;*************************************************************************************************************
					SET response_count =	locateval
											(
												find_index
												,1
												,response_size
												,task_assay_cd
												,request->activity_qual[activity_count].response_qual[find_index].task_assay_cd
											)
 
					IF (response_count > 0)
						SET value1_count		= 1
						SET alpha_response_size	=	size
													(
														request->
															activity_qual[activity_count].
															response_qual[response_count].
															alpha_response_qual
														,5
													)
 
						;*********************************************************************************************************
						;* BEGIN - Loop through VALUE1list->qual
						;*********************************************************************************************************
						WHILE (value1_count <= value1_size)
							SET nomenclature_id = cnvtreal(VALUE1list->qual[value1_count].value)
 
							IF (nomenclature_id > 0.0)
								SET alpha_response_count = 	locateval
															(
																find_index
																,1
																,alpha_response_size
																,nomenclature_id
																,request->
																	activity_qual[activity_count].
																	response_qual[response_count].
																	alpha_response_qual[find_index].
																	nomenclature_id
															)
 
								IF (alpha_response_count > 0)
									SET retval = RETURN_TRUE
 
									GO TO end_of_program
								ENDIF	;IF (alpha_response_count > 0)
							ENDIF	;IF (nomenclature_id > 0.0)
 
							SET value1_count = value1_count + 1
						ENDWHILE	;WHILE (value1_count <= value1_size)
						;*********************************************************************************************************
						;* END - Loop through VALUE1list->qual
						;*********************************************************************************************************
					ENDIF	;IF (response_count > 0)
					;*************************************************************************************************************
					;* END - Loop through request->activity_qual[].response_qual
					;*************************************************************************************************************
				ENDIF	;IF (task_assay_cd > 0.0)
			ENDFOR	;FOR (social_history_question_count = 1 TO social_history_question_size)
			;*********************************************************************************************************************
			;* END - Loop through SOCIAL_HISTORY_QUESTIONlist->qual
			;*********************************************************************************************************************
		ENDIF	;IF (response_size > 0)
	ENDIF
 
	SET activity_count = activity_count + 1
ENDWHILE
;*********************************************************************************************************************************
;* END - Loop through request->activity_qual
;*********************************************************************************************************************************
;*********************************************************************************************************************************
;* END - Look for parameters in the request
;*********************************************************************************************************************************
 
 
#end_of_program
 
CALL	echo
		(
			concat
			(
				format
				(
					curdate
					,"dd-mmm-yyyy;;d"
				)
				," "
				,format
				(
					curtime3
					,"hh:mm:ss.cc;3;m"
				)
				,"  *******  End of Program cov_eval_resulta_evoke  *********"
			)
		)
 
END
GO
 
 
 
 
