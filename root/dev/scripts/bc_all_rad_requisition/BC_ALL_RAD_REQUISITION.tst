free record request go
record request (
			  1 person_id = f8
			  1 print_prsnl_id = f8
			  1 cnt = i2
			  1 order_qual[*]
			    2 order_id = f8
			    2 encntr_id = f8
			    2 conversation_id = f8
			    2 order_dttm = c11
			  1 printer_name = c50
			  1 pdf_name = c50
			  1 requisition_script = vc
			  1 execute_statement = vc
			  1 find_file_stat = i2
) go

set request->person_id = 20589132 go
set request->print_prsnl_id = 1 go
set request->printer_name = "1cmctest.ps" go
set stat = alterlist(request->order_qual,1) go
set request->order_qual[1].ORDER_ID = 631266571 go
set request->order_qual[1].ENCNTR_ID = 110424074 go
set request->order_qual[1].CONVERSATION_ID = 1 go
set request->order_qual[1].order_dttm = "26-OCT-2020" go

execute MIREQUISITN go
