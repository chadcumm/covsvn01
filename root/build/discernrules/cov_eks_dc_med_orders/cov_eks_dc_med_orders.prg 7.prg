drop program cov_eks_dc_med_orders go
create program cov_eks_dc_med_orders

free set t_rec
record t_rec
(
	1 link_encntr_id 		= f8
	1 cnt					= i2	
	1 list[*]	
	 2 val					= f8
	 2 person_id			= f8
	 2 encntr_id			= f8
)

declare ndx = i4 
declare idx = i4 
declare pos = i4

declare rec_append( r=vc(ref), v=f8 ) = i4

subroutine rec_append( r, v )
  set r->cnt = r->cnt + 1
  set r->alloc = r->cnt
  set stat = alterlist(r->list, r->cnt )
  set r->list[r->cnt].val = v
end

; Append a list of values from a linked EKS_ORDERS_FIND_L and put them in a record
;
; normally called as ...
; set stat = OrdersFind_to_array( ord, LINK_TEMPLATE )

declare OrdersFind_to_array( r=vc(ref), tid = i4 ) = i4

subroutine OrdersFind_to_array( r, tid )
  declare i=i4 with private
  declare ocnt=i4 with private
  declare t=vc with private
  declare ord_id = f8 with private
  ;Set the Size of t_rec recordset
  ; tqual[3] = LOGIC
  ; ... qual [ tid ] = linked template

  if (size(eksdata->tqual[ 3 ]->qual[ tid ]->data , 5) >= 3)
    set ocnt = size(eksdata->tqual[3]->qual[ tid ]->data , 5)
  else
    set ocnt = 2
  endif

  ; entry 1 is junk, start with entry 2
  for ( i = 2 to ocnt  )
    set t = eksdata->tqual[3]->qual[ tid ]->data[ i ]->misc
    ;  if value ends in ".", replace with ".0"
    ; (see https://connect.ucern.com/thread/144188 )
    set t = replace( t, ".", ".0" )
    set ord_id = cnvtreal( t )
    set stat = rec_append( ord, ord_id )
    set log_message = concat("Order Find: misc = ", eksdata->tqual[3]->qual[ tid ]->data[ i ]->misc,
                                 " t= ", t,
                                 " ord_id = ",cnvtstring(ord_id))
  endfor
end

SET COUNTER1 = 0

if (validate( TRUE ) = 0)
  SET TRUE = 100
endif

SET FAIL = -1
SET RETVAL = FAIL
SET LOG_MISC1 = " "
SET LOG_MESSAGE = " "

IF ( LINK_TEMPLATE <= 0 )
  SET LOG_MESSAGE = "Template must be linked to another logic template."
  GO TO  END_RUN
ENDIF

IF ( LINK_ENCNTRID = 0 )
  SET LOG_MESSAGE = "Failed to obtain ORDER_ID from linked logic template."
  GO TO  END_RUN
ENDIF

set stat = OrdersFind_to_array( t_rec, LINK_TEMPLATE )

call echojson(eksdata, "eks_cov_eks_dc_med_orders_eksdata" , 0)

SELECT DISTINCT INTO "NL:"
   o.order_id
from orders o
plan o where expand(ndx, 1, t_rec->cnt, o.order_id, t_rec->list[ndx].val)
detail
  counter1 = counter1 + 1
  hnaordermnemonic = trim(o.hna_order_mnemonic)
  pos = locateval(idx,1,t_rec->cnt,o.order_id,t_rec->list[idx].val)
  t_rec->list[pos].encntr_id = o.encntr_id
  t_rec->list[pos].person_id = o.person_id
with nocounter

call echojson(t_rec, "eks_cov_eks_dc_med_orders_t_rec" , 0)


if ( counter1 > 0 )
  declare s9 = vc with noconstant( " ")
   ; DEBUG to dump Order IDs
  for (ndx=1 to t_rec->cnt)
    set s9 = concat(s9, "|", trim(cnvtstring(t_rec->list[ndx].val)) )
  endfor
  
  set log_message = concat( "Orders Qualified", s9)
  set retval = true
else
  set log_message = "No orders qualified"
  set retval = false
endif

#end_run
end go
