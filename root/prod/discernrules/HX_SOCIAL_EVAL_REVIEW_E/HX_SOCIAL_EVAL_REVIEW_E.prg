subroutine HX_SOCIAL_EVAL_REVIEW_E ( SOCIAL_HISTORY_QUESTION, EVALUATION, VALUE1 )
/******************************************************************************
The following lines of code handle template parameters that have List box 
control types and /or hidden values.  The record structure name should be the
parameter name with "list" tacked to the end of it.  The variable "orig_param" 
is the variable that the program EKS_T_PARSE_LIST will parse.Set it equal to the
parameter being parsed.  Then execute EKS_T_PARSE_LIST and it will fill out the 
record structure below.  Use this as a template for any of these type parameters 
after the initial saving of the template.;Parse PARAM1 parameter into value and 
display values  
record PARAM1list
(
    1 cnt = i4 ; the number of values parsed out of param1
    1 qual[*]
        2 value = vc  ; the value to be used for comparison in the template
        2 display = vc ; the display value for comparison value
)
set orig_param = PARAM1
execute eks_t_parse_list
               with replace(reply, PARAM1list)
free set orig_param

****************************************************************************/
	set retval = 0
	set stat = 0
	set tName = "HX_SOCIAL_EVAL_REVIEW_E"
	execute cov_eval_resulta_evoke
	return(retval)
end