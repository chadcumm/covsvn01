/*Custom Scripting*/
/*Returns unique values in an array*/
$.extend({
    distinct: function (anArray) {
        var result = [];
        $.each(anArray, function (i, v) {
            if ($.inArray(v, result) == -1) result.push(v);
        });
        return result;
    }
});

//create the form launch function
pwx_form_launch = function (persId, encntrId, formId, activityId, chartMode) {
    var pwxFormObj = window.external.DiscernObjectFactory('POWERFORM');
    pwxFormObj.OpenForm(persId, encntrId, formId, activityId, chartMode);
}
//create the task launch function
pwx_task_launch = function (persId, taskId, chartMode) {
    var collection = window.external.DiscernObjectFactory("INDEXEDDOUBLECOLLECTION");  //creates indexed double collection
    var taskArr = taskId.split(',');
    for (var i = 0; i < taskArr.length; i++) {  //loops through standard javascript array to extract each taskId.
        collection.Add(taskArr[i]);  //adds each task id to the indexed double collection
    }
    var pwxTaskObj = window.external.DiscernObjectFactory("TASKDOC");
    var success = pwxTaskObj.DocumentTasks(window, persId, collection, chartMode);

    return success;
}
//create the task label print launch function
pwx_task_label_print_launch = function (persId, taskId) {
    var collection = window.external.DiscernObjectFactory("INDEXEDDOUBLECOLLECTION");  //creates indexed double collection
    var taskArr = taskId.split(',');
    for (var i = 0; i < taskArr.length; i++) {  //loops through standard javascript array to extract each taskId.
        collection.Add(taskArr[i]);  //adds each task id to the indexed double collection
    }
    var pwxTaskObj = window.external.DiscernObjectFactory("TASKDOC");
    var success = pwxTaskObj.PrintLabels(persId, collection);
    return success;
}
//create form menu function
pwx_form_menu = function (form_menu_id) {
    var element;
    if (document.getElementById && (element = document.getElementById(form_menu_id))) {
        if (document.getElementById(form_menu_id).style.display == 'block') {
            document.getElementById(form_menu_id).style.display = 'none';
        }
        else {
            document.getElementById(form_menu_id).style.display = 'block';
        }
    }
}

//set patient focus
pwx_set_patient_focus = function (persId, encntrId, personName) {
	var m_pvPatientFocusObj = window.external.DiscernObjectFactory("PVPATIENTFOCUS");
	if(m_pvPatientFocusObj && typeof ClearPatientFocus !== undefined && typeof SetPatientFocus !== undefined){
		m_pvPatientFocusObj.SetPatientFocus(persId,encntrId,personName);
	}
}
//clear patient focus
pwx_clear_patient_focus = function () {
	var m_pvPatientFocusObj = window.external.DiscernObjectFactory("PVPATIENTFOCUS");
	if(m_pvPatientFocusObj && typeof ClearPatientFocus !== undefined && typeof SetPatientFocus !== undefined){
		m_pvPatientFocusObj.ClearPatientFocus();
	}
}
pwx_get_selected = function (class_name) {
    var selectedElems = new Array(8);
    selectedElems[0] = new Array()
    selectedElems[1] = new Array()
    selectedElems[2] = new Array()
    selectedElems[3] = new Array()
    selectedElems[4] = new Array()
    selectedElems[5] = new Array()
    selectedElems[6] = new Array()
    selectedElems[7] = new Array()
    $(class_name).each(function (index) {
        selectedElems[0].length = index + 1
        selectedElems[1].length = index + 1
        selectedElems[2].length = index + 1
        selectedElems[3].length = index + 1
        selectedElems[4].length = index + 1
        selectedElems[5].length = index + 1
        selectedElems[6].length = index + 1
        selectedElems[7].length = index + 1
        selectedElems[0][index] = $(this).children('span.pwx_task_id_hidden').text() + ".0";
        selectedElems[1][index] = $(this).children('dt.pwx_task_type_ind_hidden').text()
        selectedElems[2][index] = $(this).children('dt.pwx_fcr_content_status_dt').text()
        selectedElems[3][index] = $(this).children('dt.pwx_task_canchart_hidden').text()
        selectedElems[4][index] = $(this).children('dt.pwx_person_id_hidden').text() + ".0";
        selectedElems[5][index] = $(this).children('dt.pwx_encounter_id_hidden').text() + ".0";
        selectedElems[6][index] = $(this)
        selectedElems[7][index] = $(this).children('dt.pwx_task_order_id_hidden').text() + ".0";
    });
    return selectedElems;
}
pwx_get_selected_order_id = function (class_name) {
    //var taskAr = $('.pwx_row_selected').children('.pwx_task_id_hidden').text();
    var taskObj = $(class_name).children('dt.pwx_task_order_id_hidden').map(function () { return $(this).text() + ".0"; });
    var orderAr = jQuery.makeArray(taskObj);
    return orderAr;
}
pwx_get_selected_resched_time_limit = function (class_name) {
    var resched_detailsArr = new Array(2);
    resched_detailsArr[0] = $(class_name).children('dt.pwx_task_resched_time_hidden').text();
    resched_detailsArr[1] = $(class_name).children('dt.pwx_fcr_content_schdate_dt').text();
    return resched_detailsArr;
}
pwx_get_selected_task_comment = function (class_name) {
    var task_comment = '';
    task_comment = $(class_name).children('dt.pwx_task_comment_hidden').text();
    return task_comment;
}
pwx_get_selected_unchart_data = function (class_name) {
    //var taskAr = $('.pwx_row_selected').children('.pwx_task_id_hidden').text();
    var unchartTaskArr = new Array();
    $(class_name).children('dt.pwx_fcr_content_task_dt').children('div.pwx_task_lab_container_hidden').each(function (index) {
        var ar_cnt = unchartTaskArr.length
        unchartTaskArr.length = ar_cnt + 1
        unchartTaskArr[ar_cnt] = new Array(2);
        unchartTaskArr[ar_cnt][0] = $(this).children('span.pwx_task_lab_line_text_hidden').text();
        unchartTaskArr[ar_cnt][1] = $(this).children('span.pwx_task_lab_taskid_hidden').text() + ".0";
    });
    return unchartTaskArr;
}
pwx_get_selected_unchart_not_done = function (class_name) {
    //var taskAr = $('.pwx_row_selected').children('.pwx_task_id_hidden').text();
    //var taskAr = $('.pwx_row_selected').children('.pwx_task_id_hidden').text();
    var taskObj = $(class_name).children('dt.pwx_task_lab_notchart_hidden').map(function () { return $(this).text(); });
    var unchart_not_doneAr = jQuery.makeArray(taskObj);
    return unchart_not_doneAr;
}

//function to take date/times and sort and then reload the Task
function pwx_sort_by_task_date(a, b) {
    if (a.TASK_DT_TM_NUM < b.TASK_DT_TM_NUM)
        return -1
    if (a.TASK_DT_TM_NUM > b.TASK_DT_TM_NUM)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_view_prefs(a, b) {
    if (a.VIEW_SEQ < b.VIEW_SEQ)
        return -1
    if (a.VIEW_SEQ > b.VIEW_SEQ)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_by_task(a, b) {
    var nameA = a.TASK_DISPLAY.toLowerCase(), nameB = b.TASK_DISPLAY.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_by_personname(a, b) {
    var nameA = a.PERSON_NAME.toLowerCase(), nameB = b.PERSON_NAME.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_by_visitdate(a, b) {
    if (a.VISIT_DT_TM_NUM < b.VISIT_DT_TM_NUM)
        return -1
    if (a.VISIT_DT_TM_NUM > b.VISIT_DT_TM_NUM)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_form_name(a, b) {
    var nameA = a.FORM_NAME.toLowerCase(), nameB = b.FORM_NAME.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_by_task_type(a, b) {
    var nameA = a.TASK_TYPE.toLowerCase(), nameB = b.TASK_TYPE.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_by_order_by(a, b) {
    var nameA = a.ORDERING_PROVIDER.toLowerCase(), nameB = b.ORDERING_PROVIDER.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_by_status(a, b) {
    var nameA = a.TASK_STATUS.toLowerCase(), nameB = b.TASK_STATUS.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_task_sort(pwxObj, clicked_header_id) {
    $('#pwx_frame_content').empty();
    $('#pwx_frame_content').html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
    start_pwx_timer()
    start_page_load_timer = new Date();
    json_task_start_number = 0;
    json_task_end_number = 0;
    json_task_page_start_numbersAr = [];
    task_list_curpage = 1;
    if (clicked_header_id == pwx_task_header_id) {
        if (pwx_task_sort_ind == '0') {
            var sort_ind = '1'
        }
        else {
            var sort_ind = '0'
        }
        pwxObj.TLIST.reverse()
        pwx_task_header_id = clicked_header_id
        pwx_task_sort_ind = sort_ind
        RenderTaskListContent(pwxObj);
    }
    else {
        switch (clicked_header_id) {
            case 'pwx_fcr_header_schdate_dt':
                pwxObj.TLIST.sort(pwx_sort_by_task_date)
                pwx_task_header_id = clicked_header_id
                pwx_task_sort_ind = '0'
                RenderTaskListContent(pwxObj);
                break;
            case 'pwx_fcr_header_orderby_dt':
                pwxObj.TLIST.sort(pwx_sort_by_order_by)
                pwx_task_header_id = clicked_header_id
                pwx_task_sort_ind = '0'
                RenderTaskListContent(pwxObj);
                break;
            case 'pwx_fcr_header_task_dt':
                pwxObj.TLIST.sort(pwx_sort_by_task)
                pwx_task_header_id = clicked_header_id
                pwx_task_sort_ind = '0'
                RenderTaskListContent(pwxObj);
                break;
            case 'pwx_fcr_header_personname_dt':
                pwxObj.TLIST.sort(pwx_sort_by_personname)
                pwx_task_header_id = clicked_header_id
                pwx_task_sort_ind = '0'
                RenderTaskListContent(pwxObj);
                break;
            case 'pwx_fcr_header_visitdate_dt':
                pwxObj.TLIST.sort(pwx_sort_by_visitdate)
                pwx_task_header_id = clicked_header_id
                pwx_task_sort_ind = '0'
                RenderTaskListContent(pwxObj);
                break;
            case 'pwx_fcr_header_type_dt':
                pwxObj.TLIST.sort(pwx_sort_by_task_type)
                pwx_task_header_id = clicked_header_id
                pwx_task_sort_ind = '0'
                RenderTaskListContent(pwxObj);
                break;
        }
    }
}

function pwx_isOdd(num) { return num % 2; }

function pwx_select_all(class_name) {
    $('dl.pwx_content_row').removeClass(class_name).addClass(class_name);
}
function pwx_deselect_all(class_name) {
    $('dl.pwx_content_row').removeClass(class_name);
}

function callCCLLINK(ccllinkparams) {
    window.location = "javascript:CCLLINK('pwx_rpt_driver_to_mpage','" + ccllinkparams + "',0)";
}
function pwx_toggle_person_task_type_pref_save() {
    if ($('#pwx_update_task_type_pref_dt').length > 0) {
        $('#pwx_update_task_type_pref').off('click');
        $('#pwx_clear_task_type_pref').off('click');
        $('#pwx_update_task_type_pref_dt').off('click');
        $('#pwx_task_type_update_menu').off().remove();
        $('#pwx_update_task_type_pref_dt').html("").attr("id", "pwx_new_task_types_pref_dt");
        $('#pwx_new_task_types_pref_dt').html('<span id="pwx_new_task_types_pref" title="' + amb_i18n.SAVE_TASK_TYPE_TOOLTIP + '" class="pwx-discsave-icon pwx_pointer_cursor">&nbsp;</span>');
        $('#pwx_new_task_types_pref_dt').on('click', function (event) {
            var js_criterion = JSON.parse(m_criterionJSON);
            var array_of_checked_values = $("#task_type").multiselect("getChecked").map(function () {
                return this.value;
            }).get();
            typeArr = jQuery.makeArray(array_of_checked_values);
            PWX_CCL_Request_User_Pref('amb_cust_mp_maintain_user_pref', js_criterion.CRITERION.PRSNL_ID, "PWX_MPAGE_ORG_TASK_LIST_TYPES", typeArr.join('|'), true)
            pwx_toggle_person_task_type_pref_save()
        });
    }
    else if ($('#pwx_new_task_types_pref_dt').length > 0) {
        $('#pwx_new_task_types_pref_dt').off('click').html("").attr("id", "pwx_update_task_type_pref_dt");
        var newHTML = '<span class="pwx-discsave_checkmark-icon">&nbsp;</span><span class="pwx-icon_submenu_arrow-icon">&nbsp;</span>';
        $('#pwx_update_task_type_pref_dt').html(newHTML);
        $('#pwx_update_task_type_pref_dt').after('<div id="pwx_task_type_update_menu" style="display:none;"><a class="pwx_result_link" id="pwx_update_task_type_pref">' + amb_i18n.UPDATE + '</a></br><a class="pwx_result_link" id="pwx_clear_task_type_pref">' + amb_i18n.CLEAR + '</a></div>')
        $('#pwx_task_type_update_menu').on('mouseleave', function (event) {
            $(this).css('display', 'none');
        });
        $('#pwx_update_task_type_pref_dt').on('click', function (event) {
            var dt_pos = $(this).position();
            $('#pwx_task_type_update_menu').css('top', dt_pos.top + 16).css('left', dt_pos.left + 20).css('display', 'block');
        });
        $('#pwx_update_task_type_pref').on('click', function (event) {
            var js_criterion = JSON.parse(m_criterionJSON);
            var array_of_checked_values = $("#task_type").multiselect("getChecked").map(function () {
                return this.value;
            }).get();
            typeArr = jQuery.makeArray(array_of_checked_values);
            PWX_CCL_Request_User_Pref('amb_cust_mp_maintain_user_pref', js_criterion.CRITERION.PRSNL_ID, "PWX_MPAGE_ORG_TASK_LIST_TYPES", typeArr.join('|'), true)
            $('#pwx_task_type_update_menu').css('display', 'none');
        });
        $('#pwx_clear_task_type_pref').on('click', function (event) {
            var js_criterion = JSON.parse(m_criterionJSON);
            PWX_CCL_Request_User_Pref('amb_cust_mp_maintain_user_pref', js_criterion.CRITERION.PRSNL_ID, "PWX_MPAGE_ORG_TASK_LIST_TYPES", "", true)
            $('#pwx_task_type_update_menu').css('display', 'none');
            pwx_toggle_person_task_type_pref_save()
        });
    }
}

function pwx_open_person_details(details) {
    //alert(JSON.stringify(details))
    var detailText = [];
    detailText.push('<div class="pwx_modal_person_banner"><span class="pwx_modal_person_banner_name">', details.PERSON_NAME, '</span>')
    detailText.push('<span class="pwx_modal_person_banner_details">',amb_i18n.DOB,':&nbsp;', details.DOB, '</span>')
    detailText.push('<span class="pwx_modal_person_banner_details">',amb_i18n.AGE,':&nbsp;', details.PT_AGE, '</span>')
    detailText.push('<span class="pwx_modal_person_banner_details">',amb_i18n.GENDER,':&nbsp;', details.GENDER_CD, '</span>')
    detailText.push('</div></br></br>')
    detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.MRN,':</dt><dd>', details.MRN, '</dd></dl>')
	if(details.VISIT_DT_UTC != "" && details.VISIT_DT_UTC != "TZ") {
		var visitUTCDate = new Date();
		visitUTCDate.setISO8601(details.VISIT_DT_UTC);
		detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.VISIT_DATE,':</dt><dd>', visitUTCDate.format("shortDate3"), '</dd></dl>')
	} else {
		detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.VISIT_DATE,':</dt><dd>--</dd></dl>')
	}
    detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.VISIT_LOC,':</dt><dd>', details.VISIT_LOC, '</dd></dl>')
    detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.PCP,':</dt><dd>')
    if (details.PCP == "") { detailText.push("--") }
    else { detailText.push(details.PCP) }
    detailText.push('</dd></dl>')
    if (details.PHONE.length > 0) {
        detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.PHONE_NUM,' (', details.PHONE.length, '):</dt><dd>&nbsp;</dd></dl>')
        detailText.push('<dl class="pwx_task_detail_line"><dt>&nbsp;</dt><dd class="pwx_normal_line_height pwx_extra_small_text" style="padding-left:15px;">');
        for (var cc = 0; cc < details.PHONE.length; cc++) {
            detailText.push('<span ><span class="pwx_grey">', details.PHONE[cc].PHONE_TYPE, ':</span> ', details.PHONE[cc].PHONE_NUM, '</span><br />');
        }
        detailText.push('</dd></dl>');
    }
    else {
        detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.PHONE_NUM,' (0):</dt><dd>--</dd></dl>')
    }
    if (details.DLIST.length > 0) {
        detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.VISIT_DIAG,' (', details.DLIST.length, '):</dt><dd>&nbsp;</dd></dl>')
        detailText.push('<dl class="pwx_task_detail_line"><dt>&nbsp;</dt><dd class="pwx_normal_line_height pwx_extra_small_text" style="padding-left:15px;">');
        for (var cc = 0; cc < details.DLIST.length; cc++) {
            detailText.push('<span>', details.DLIST[cc].DIAG);
            if (details.DLIST[cc].CODE != "") {
                detailText.push('<span class="pwx_grey"> (', details.DLIST[cc].CODE, ')</span>');
            }
            detailText.push('</span><br />');
        }
        detailText.push('</dd></dl>');
    }
    else {
        detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.VISIT_DIAG,' (0):</dt><dd>--</dd></dl>')
    }

    if (details.ALLERGIES.length > 0) {
        detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.ALLERGIES,' (', details.ALLERGIES.length, '):</dt><dd>&nbsp;</dd></dl>')
        detailText.push('<dl class="pwx_task_detail_line"><dt>&nbsp;</dt><dd class="pwx_normal_line_height pwx_extra_small_text" style="padding-left:15px;">');
        for (var cc = 0; cc < details.ALLERGIES.length; cc++) {
            detailText.push('<span >', details.ALLERGIES[cc].ALLERGY);
            if (details.ALLERGIES[cc].REACTION != "") {
                detailText.push(': <span class="pwx_grey">', details.ALLERGIES[cc].REACTION, '</span>');
            }
            detailText.push('</span><br />');
        }
        detailText.push('</dd></dl>');
    }
    else {
        detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.ALLERGIES,' (0):</dt><dd>--</dd></dl>')
    }
    MP_ModalDialog.deleteModalDialogObject("PatientDetailModal")
    var ptDetailModal = new ModalDialog("PatientDetailModal")
             .setHeaderTitle(amb_i18n.PATIENT_DETAILS)
             .setTopMarginPercentage(10)
             .setRightMarginPercentage(30)
             .setBottomMarginPercentage(10)
             .setLeftMarginPercentage(30)
             .setIsBodySizeFixed(true)
             .setHasGrayBackground(true)
             .setIsFooterAlwaysShown(true);
    ptDetailModal.setBodyDataFunction(
             function (modalObj) {
                 modalObj.setBodyHTML('<div class="pwx_task_detail">' + detailText.join("") + '</div>');
             });
    var closebtn = new ModalButton("addCancel");
    closebtn.setText(amb_i18n.CLOSE).setCloseOnClick(true);
    ptDetailModal.addFooterButton(closebtn)
    MP_ModalDialog.addModalDialogObject(ptDetailModal);
    MP_ModalDialog.showModalDialog("PatientDetailModal")
}

function pwx_timer_display() {
    pwx_task_count += 1;
    $('#pwx_loading_div_time').text(pwx_task_count + ' ' + amb_i18n.SEC)
}
function start_pwx_timer() {
    pwx_task_count = 0;
    pwx_task_counter = 0;
    pwx_task_counter = setInterval("pwx_timer_display()", 1000);
}

function stop_pwx_timer() {
    clearInterval(pwx_task_counter)
}
//PWX Mpage Framework
//function to call a ccl script to gather data and return the json object
function PWX_CCL_Request(program, paramAr, async, callback) {
    var info = new XMLCclRequest();
    info.onreadystatechange = function () {
        if (info.readyState == 4 && info.status == 200) {
            var jsonEval = JSON.parse(this.responseText);
            var recordData = jsonEval.RECORD_DATA;
            if (recordData.STATUS_DATA.STATUS === "S") {
                callback.call(recordData);
            }
            else {
                callback.call(recordData);
                alert(amb_i18n.STATUS + ": ", this.status, "<br />" + amb_i18n.REQUEST_TEXT + ": ", this.requestText);
            }
        }
    };
    info.open('GET', program, async);
    info.send(paramAr.join(","));
}

//render page
var pwx_task_header_id = "pwx_fcr_header_schdate_dt";
var pwx_task_sort_ind = "0";
var pwx_all_show_clicked = "0";
var pwx_task_get_type = "0";
var pwx_task_get_type_str = "All";
var pwx_global_statusArr = new Array;
var pwx_global_typeArr = new Array;
var pwx_global_orderprovArr = new Array;
var pwx_global_orderprovFiltered = 0;
var pwx_global_expanded = 0;
var pwx_current_set_location = 0;
var pwx_task_global_from_date = "0";
var pwx_task_global_to_date = "0";
var pwx_task_submenu_clicked_task_id = "0";
var pwx_task_submenu_clicked_order_id = "0";
var pwx_task_submenu_clicked_person_id = "0";
var pwx_task_submenu_clicked_task_type_ind = 0;
var pwx_task_submenu_clicked_row_elem;
var reschedule_TaskIds = '';
var start_page_load_timer = new Date();
var ccl_timer = 0;
var filterbar_timer = 0;
var delegate_event_timer = 0;
var json_task_end_number = 0;
var json_task_start_number = 0;
var json_task_page_start_numbersAr = [];
var task_list_curpage = 1;
var pwx_task_counter;
var current_from_date = '';
var current_to_date = '';
var current_location_id = 0;
var pwx_task_load_counter = 0;
//var pwxstoreddata;
function RenderPWxFrame() {
    json_task_end_number = 0;
    json_task_start_number = 0;
    json_task_page_start_numbersAr = [];
    task_list_curpage = 1;
    //gather data
    var js_criterion = JSON.parse(m_criterionJSON);
    $.contextMenu('destroy');
    $('#pwx_frame_filter_content').empty();
    //set pref
    PWX_CCL_Request_User_Pref('amb_cust_mp_maintain_user_pref', js_criterion.CRITERION.PRSNL_ID, "PWX_MPAGE_MULTI_TASK_TAB_PREF", "ORDERTASKS", true)
    //display frame header
    var headelement = document.getElementById('pwx_frame_head');
    var pwxheadHTML = [];
    pwxheadHTML.push('<div id="pwx_frame_toolbar"><dt class="pwx_list_view_radio">');
    pwxheadHTML.push('<div class="pwx_tasklist-seg-cntrl tab-layout-active" ><div id="tasklistLeft"></div><div id="tasklistCenter">',amb_i18n.ORDER_TASKS,'</div><div id="tasklistRight"></div></div>')
    if (js_criterion.CRITERION.PWX_REFLAB_LIST_DISP == 1) {
        pwxheadHTML.push('<div class="pwx_reflab-seg-cntrl" onclick="RenderPWxRefLabFrame()"><div id="refLabLeft"></div><div id="refLabCenter">',amb_i18n.REF_LAB,'</div><div id="refLabRight"></div></div>');
    }
    pwxheadHTML.push('<div id="pwx_list_total_count"><span class="pwx_grey">0 total ',amb_i18n.TOTAL_ITEMS,'</span></div></dt>');
    if (js_criterion.CRITERION.PWX_HELP_LINK != "") {
        //pwxheadHTML.push('<dt class="pwx_toolbar_task_icon" id="pwx_help_page_icon"><a href=\'javascript: CCLNEWSESSIONWINDOW("', js_criterion.CRITERION.PWX_HELP_LINK, '","_blank","left=0,top=0,width=1200,height=700,toolbar=no",0,1)\' class="pwx_no_text_decor" title="Help Page" onClick="">',
        pwxheadHTML.push('<dt class="pwx_toolbar_task_icon" id="pwx_help_page_icon"><a href=\'javascript: APPLINK(100,"', js_criterion.CRITERION.PWX_HELP_LINK, '","")\' class="pwx_no_text_decor" title="',amb_i18n.HELP_PAGE,'" onClick="">',
        '<span class="pwx-help-icon">&nbsp;</span></a></dt>');
    }
    pwxheadHTML.push('<dt class="pwx_toolbar_task_icon"><a class="pwx_no_text_decor" title="',amb_i18n.DESELECT_ALL,'" onClick="pwx_deselect_all(\'pwx_row_selected\')"> <span class="pwx-deselect_all-icon">&nbsp;</span></a></dt>');
    pwxheadHTML.push('<dt class="pwx_toolbar_task_icon"><a class="pwx_no_text_decor" title="',amb_i18n.SELECT_ALL,'" onClick="pwx_select_all(\'pwx_row_selected\')"><span class="pwx-select_all-icon">&nbsp;</span></a></dt>');
    if (js_criterion.CRITERION.LOC_PREF_FOUND == 1) {
        pwx_current_set_location = js_criterion.CRITERION.LOC_PREF_ID
        RenderDateRangeTaskList("", 'pwx_location', pwx_current_set_location);
    }
    pwxheadHTML.push('<dt id="pwx_location_list">');
    if (js_criterion.CRITERION.LOC_LIST.length > 0) {
        pwxheadHTML.push('<span class="pwx_location_list_lbl">',amb_i18n.LOCATION,': </span>');
		pwxheadHTML.push('<select id="task_location" name="task_location" style="width:300px;" data-placeholder="Choose a Location..." class="chzn-select"><option value=""></option>');
        var loc_height = 30;
        for (var i = 0; i < js_criterion.CRITERION.LOC_LIST.length; i++) {
            loc_height += 26;
            if (pwx_current_set_location == js_criterion.CRITERION.LOC_LIST[i].ORG_ID) {
                pwxheadHTML.push('<option value="', js_criterion.CRITERION.LOC_LIST[i].ORG_ID, '" selected="selected">', js_criterion.CRITERION.LOC_LIST[i].ORG_NAME, '</option>');
            }
            else {
                pwxheadHTML.push('<option value="', js_criterion.CRITERION.LOC_LIST[i].ORG_ID, '">', js_criterion.CRITERION.LOC_LIST[i].ORG_NAME, '</option>');
            }
        }
        if (loc_height > 300) { loc_height = 300; }
        pwxheadHTML.push('</select>');
    }
    else {
        pwxheadHTML.push(amb_i18n.NO_RELATED_LOC);
    }
    pwxheadHTML.push('</dt></div><div id="pwx_task_loc_update_menu" style="display:none;"><a class="pwx_result_link" id="pwx_update_task_loc_pref">',amb_i18n.UPDATE,'</a></br><a class="pwx_result_link" id="pwx_clear_task_loc_pref">',amb_i18n.CLEAR,'</a></div>');
    headelement.innerHTML = pwxheadHTML.join("");

	$('#task_location').chosen({
		no_results_text : "No results matched"
	});
    $("#task_location").on("change", function (event) {
        pwx_current_set_location = $("#task_location").val();
        RenderDateRangeTaskList("", 'pwx_location', pwx_current_set_location);
        PWX_CCL_Request_User_Pref('amb_cust_mp_maintain_user_pref', js_criterion.CRITERION.PRSNL_ID, "PWX_MPAGE_ORG_TASK_LIST_LOCS", pwx_current_set_location, true);
    });

    //display the filter bar with date pickers
    var filterelement = document.getElementById('pwx_frame_filter_content');
    //build the filter bar
    var pwxfilterbarHTML = [];
    pwxfilterbarHTML.push('<div id="pwx_frame_filter_bar"><div id="pwx_frame_filter_bar_container"><dl>');
    pwxfilterbarHTML.push('<dt id="pwx_date_picker"><label for="from"><span style="vertical-align:20%;">',amb_i18n.TASK_DATE,': </span><input type="text" id="from" name="from" class="pwx_date_box" /></label><label for="to"><span style="vertical-align:20%;"> ',amb_i18n.TO,' </span><input type="text" id="to" name="to" class="pwx_date_box" /></label></dt>');
    pwxfilterbarHTML.push('<dt id="pwx_task_status_filter"></dt>');
    pwxfilterbarHTML.push('<dt class="pwx_task_filterbar_left_icon" id="pwx_task_adv_filter_tgl"></dt>')
    pwxfilterbarHTML.push('<dt class="pwx_task_filterbar_icon" id="pwx_task_info_icon"></dt>');
    pwxfilterbarHTML.push('<dt class="pwx_task_filterbar_icon" id="pwx_task_list_refresh_icon"></dt>');
    pwxfilterbarHTML.push('<div id="pwx_frame_advanced_filters_container" style="display:none;">')
    pwxfilterbarHTML.push('<dt id="pwx_task_orderprov_filter"></dt><dt id="pwx_task_type_filter"></dt><dt class="pwx_task_adv_filterbar_left_icon pwx_pointer_cursor" id="pwx_task_type_pref_dt"></dt></div>')
    pwxfilterbarHTML.push('</dl></div>');
    pwxfilterbarHTML.push('<div id="pwx_frame_paging_bar_container" style="display:none;"><dt id="pwx_task_filterbar_page_prev" class="pwx_task_pagingbar_page_icons"></dt><dt id="pwx_task_filterbar_page_next" class="pwx_task_pagingbar_page_icons"></dt><dt id="pwx_task_pagingbar_cur_page" class="pwx_grey"></dt><dt id="pwx_task_pagingbar_load_text"></dt><dt id="pwx_task_pagingbar_load_count" class="pwx_grey"></dt></div>');
    pwxfilterbarHTML.push('<dl><dt id="pwx_frame_filter_bar_bottom_pad"></dt><dl></div>');
    filterelement.innerHTML = pwxfilterbarHTML.join("");
    //function to handle a date range entry
    function RenderDateRangeTaskList(selectedDate, dateId, locId) {
        if (dateId == 'to') {
            current_to_date = selectedDate;
            pwx_task_global_to_date = selectedDate;
            $("#from").datepicker("option", "maxDate", selectedDate);
            mindate = Date.parse(selectedDate).addDays(-31).toString("MM/dd/yyyy");
            $("#from").datepicker("option", "minDate", mindate);
            if ($("#from").val() != "" && current_from_date == '') {
                $("#from").val("")
            }
        }
        else if (dateId == 'from') {
            current_from_date = selectedDate;
            pwx_task_global_from_date = selectedDate;
            $("#to").datepicker("option", "minDate", selectedDate);
            maxdate = Date.parse(selectedDate).addDays(31).toString("MM/dd/yyyy");
            $("#to").datepicker("option", "maxDate", maxdate);
            if ($("#to").val() != "" && current_to_date == '') {
                $("#to").val("")
            }

        }
        else if (dateId == 'pwx_location') {
            current_location_id = locId;
            if ($("#from").val() != "" && current_from_date == '') {
                $("#from").val("")
            }
            if ($("#to").val() != "" && current_to_date == '') {
                $("#to").val("")
            }
        }
        if (current_from_date != '' && current_to_date != '' && current_location_id > 0) {
            //both dates and location found load list
            $('#pwx_frame_content').empty();
            $('#pwx_frame_content').html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
            pwx_current_set_location = current_location_id;
            pwx_task_global_from_date = current_from_date;
            pwx_task_global_to_date = current_to_date
            start_pwx_timer()
            var start_ccl_timer = new Date();
            var sendArr = ["^MINE^", js_criterion.CRITERION.PRSNL_ID + ".0", js_criterion.CRITERION.POSITION_CD + ".0", "^" + current_from_date + "^", "^" + current_to_date + "^", current_location_id + ".0"];
            PWX_CCL_Request("amb_cust_mp_task_by_loc_dt", sendArr, true, function () {
                pwx_global_orderprovArr = []
                current_to_date = "";
                current_from_date = "";
                $("#from, #to").datepicker("option", "maxDate", null)
                $("#from, #to").datepicker("option", "minDate", null)
                var end_ccl_timer = new Date();
                ccl_timer = (end_ccl_timer - start_ccl_timer) / 1000
                start_page_load_timer = new Date();
                if (pwx_task_load_counter == 0) {
                    this.TLIST.sort(pwx_sort_by_task_date)
                    RenderTaskList(this);
                    pwx_task_load_counter += 1;
                }
                else {
                    switch (pwx_task_header_id) {
                        case 'pwx_fcr_header_task_dt':
                            this.TLIST.sort(pwx_sort_by_task)
                            break;
                        case 'pwx_fcr_header_personname_dt':
                            this.TLIST.sort(pwx_sort_by_personname)
                            break;
                        case 'pwx_fcr_header_visitdate_dt':
                            this.TLIST.sort(pwx_sort_by_visitdate)
                            break;
                        case 'pwx_fcr_header_schdate_dt':
                            this.TLIST.sort(pwx_sort_by_task_date)
                            break;
                        case 'pwx_fcr_header_orderby_dt':
                            this.TLIST.sort(pwx_sort_by_order_by)
                            break;
                        case 'pwx_fcr_header_type_dt':
                            this.TLIST.sort(pwx_sort_by_task_type)
                            break;
                        case 'pwx_fcr_header_status_dt':
                            this.TLIST.sort(pwx_sort_by_status)
                            break;
                    }
                    if (pwx_task_sort_ind == "1") {
                        this.TLIST.reverse()
                    }
                    filterbar_timer = 0
                    json_task_start_number = 0;
                    json_task_end_number = 0;
                    json_task_page_start_numbersAr = [];
                    task_list_curpage = 1;
                    //pwxstoreddata = this;
                    RenderTaskListContent(this)
                    pwx_task_load_counter += 1;
                }
            });
        }
    }
    //set the date range datepickers
    var dates = $("#from, #to").datepicker({
        dateFormat: "mm/dd/yy",
        showOn: "focus",
        changeMonth: true,
        changeYear: true,
        onSelect: function (selectedDate) {
            RenderDateRangeTaskList(selectedDate, this.id);
            $.datepicker._hideDatepicker();
        }
    });
    //adjust heights based on screen size
    var toolbarH = $('#pwx_frame_toolbar').height() + 6;
    $('#pwx_frame_filter_bar').css('top', toolbarH + 'px');
    var filterbarH = $('#pwx_frame_filter_bar').height() + toolbarH;
    //$('#pwx_frame_content_rows_header').css('top', filterbarH + 'px');
	//var contentrowsH = filterbarH + 19;
	//$('#pwx_frame_content_rows').css('top', contentrowsH + 'px');
    $(window).on('resize', function () {
        //make sure fixed position for filter bar correct
        var toolbarH = $('#pwx_frame_toolbar').height() + 6;
        $('#pwx_frame_filter_bar').css('top', toolbarH + 'px');
        var filterbarH = $('#pwx_frame_filter_bar').height() + toolbarH;
		$('#pwx_frame_content_rows_header').css('top', filterbarH + 'px');
		var contentrowsH = filterbarH + 19;
		$('#pwx_frame_content_rows').css('top', contentrowsH + 'px');
        $('span.pwx_fcr_content_type_name_dt, span.pwx_fcr_content_type_ordname_dt, dt.pwx_fcr_content_orderby_dt').each(function (index) {
            if (this.clientWidth < this.scrollWidth) {
                var titleText = $(this).text()
                $(this).attr("title", titleText)
            }
        });
    });
    $('#pwx_task_adv_filter_tgl').on('click', function () {
        if ($('#pwx_frame_advanced_filters_container').css('display') == 'none') {
            $('#pwx_frame_advanced_filters_container').css('display', 'inline-block')
            pwx_global_expanded = 1;
            $('#pwx_task_adv_filter_tgl').attr('title', amb_i18n.HIDE_ADV_FILTERS)
            $('#pwx_task_adv_filter_tgl').html('<span class="pwx-collapse-tgl"></span>')
            var toolbarH = $('#pwx_frame_toolbar').height() + 6;
            $('#pwx_frame_filter_bar').css('top', toolbarH + 'px');
            var filterbarH = $('#pwx_frame_filter_bar').height() + toolbarH;
			$('#pwx_frame_content_rows_header').css('top', filterbarH + 'px');
			var contentrowsH = filterbarH + 19;
			$('#pwx_frame_content_rows').css('top', contentrowsH + 'px');
        }
        else {
            $('#pwx_frame_advanced_filters_container').css('display', 'none')
            pwx_global_expanded = 0;
            $('#pwx_task_adv_filter_tgl').attr('title', amb_i18n.SHOW_ADV_FILTERS)
            $('#pwx_task_adv_filter_tgl').html('<span class="pwx-expand-tgl"></span>')
            var toolbarH = $('#pwx_frame_toolbar').height() + 6;
            $('#pwx_frame_filter_bar').css('top', toolbarH + 'px');
            var filterbarH = $('#pwx_frame_filter_bar').height() + toolbarH;
			$('#pwx_frame_content_rows_header').css('top', filterbarH + 'px');
			var contentrowsH = filterbarH + 19;
			$('#pwx_frame_content_rows').css('top', contentrowsH + 'px');
        }
    })
    if (js_criterion.CRITERION.LOC_PREF_FOUND == 1) {
        if (pwx_task_global_from_date == "0" || pwx_task_global_to_date == "0") {
            var fromdate = Date.today().addDays(-7).toString("MM/dd/yyyy");
            var todate = Date.today().toString("MM/dd/yyyy");
            $('#from').datepicker("setDate", fromdate)
            RenderDateRangeTaskList(fromdate, "from");
            $('#to').datepicker("setDate", todate)
            RenderDateRangeTaskList(todate, "to");
        }
        else {	
            var fromdate = pwx_task_global_from_date;
            var todate = pwx_task_global_to_date;
            $('#from').datepicker("setDate", fromdate)
            RenderDateRangeTaskList(fromdate, "from");
            $('#to').datepicker("setDate", todate)
            RenderDateRangeTaskList(todate, "to");
        }
    }
    else {
        $('#pwx_frame_head').append('<div id="pwx-task_list_no_pref_dialog"><p class="pwx_small_text">' + amb_i18n.FIRST_LOGIN_SENT1 + '<br/>' +
        '</br></br><span class="pwx-location_pref_screen-icon"></span></br></br>' + amb_i18n.FIRST_LOGIN_SENT2 + '</p></div>')
        $("#pwx-task_list_no_pref_dialog").dialog({
            resizable: false,
            height: 400,
            width: 450,
            modal: true,
            title: '<span class="pwx-information-icon" style="vertical-align:10%"></span>&nbsp;<span class="pwx_alert" style="vertical-align:20%">' + amb_i18n.SAVE_LOC_PREF + '</span>',
            buttons: {
                "OK": function () {
                    $(this).dialog("close");
                }
            }
        });
    }
}
function RenderTaskList(pwxdata) {
	var framecontentElem =  $('#pwx_frame_content')
    framecontentElem.off()
    var start_filterbar_timer = new Date();
    var js_criterion = JSON.parse(m_criterionJSON);
    js_criterion.CRITERION.VPREF.sort(pwx_sort_view_prefs)
    var statusElem = $('#pwx_task_status_filter')
    var typeElem = $('#pwx_task_type_filter')
    var orderprovElem = $('#pwx_task_orderprov_filter')
    var statusHTML = [];
    if (pwx_global_statusArr.length > 0) {
        if (pwxdata.STATUS_LIST.length > 0) {
            statusHTML.push('<span style="vertical-align:30%;">',amb_i18n.STATUS,': </span><select id="task_status" name="task_status" multiple="multiple">');
            for (var i = 0; i < pwxdata.STATUS_LIST.length; i++) {
                var status_match = 0;
                for (var y = 0; y < pwx_global_statusArr.length; y++) {
                    if (pwx_global_statusArr[y] == pwxdata.STATUS_LIST[i].STATUS) {
                        status_match = 1;
                        break;
                    }
                }
                if (status_match == 1) {
                    statusHTML.push('<option selected="selected" value="', pwxdata.STATUS_LIST[i].STATUS, '">', pwxdata.STATUS_LIST[i].STATUS, '</option>');
                }
                else {
                    statusHTML.push('<option value="', pwxdata.STATUS_LIST[i].STATUS + '">', pwxdata.STATUS_LIST[i].STATUS, '</option>');
                }
            }
            statusHTML.push('</select>');
        }
    }
    else {
        if (pwxdata.STATUS_LIST.length > 0) {
            statusHTML.push('<span style="vertical-align:30%;">',amb_i18n.STATUS,': </span><select id="task_status" name="task_status" multiple="multiple">');
            for (var i = 0; i < pwxdata.STATUS_LIST.length; i++) {
                if (pwxdata.STATUS_LIST[i].SELECTED == 1) {
                    statusHTML.push('<option selected="selected" value="', pwxdata.STATUS_LIST[i].STATUS, '">', pwxdata.STATUS_LIST[i].STATUS, '</option>');
                }
                else {
                    statusHTML.push('<option selected="selected" value="', pwxdata.STATUS_LIST[i].STATUS, '">', pwxdata.STATUS_LIST[i].STATUS, '</option>');
                }
            }
            statusHTML.push('</select>');
        }
    }
    $(statusElem).html(statusHTML.join(""))
    var typeHTML = [];
    if (pwx_global_typeArr.length > 0) {
        if (pwxdata.TYPE_LIST.length > 0) {
            typeHTML.push('<span style="vertical-align:30%;">',amb_i18n.TYPE,': </span><select id="task_type" name="task_type" multiple="multiple">');
            for (var i = 0; i < pwxdata.TYPE_LIST.length; i++) {
                var type_match = 0;
                for (var y = 0; y < pwx_global_typeArr.length; y++) {
                    if (pwx_global_typeArr[y] == pwxdata.TYPE_LIST[i].TYPE) {
                        type_match = 1;
                        break;
                    }
                }
                if (type_match == 1) {
                    typeHTML.push('<option selected="selected" value="', pwxdata.TYPE_LIST[i].TYPE, '">', pwxdata.TYPE_LIST[i].TYPE, '</option>');
                }
                else {
                    typeHTML.push('<option value="', pwxdata.TYPE_LIST[i].TYPE, '">', pwxdata.TYPE_LIST[i].TYPE, '</option>');
                }
            }
            typeHTML.push('</select>');
        }
    }
    else {
        if (pwxdata.TYPE_LIST.length > 0) {
            typeHTML.push('<span style="vertical-align:30%;">',amb_i18n.TYPE,': </span><select id="task_type" name="task_type" multiple="multiple">');
            for (var i = 0; i < pwxdata.TYPE_LIST.length; i++) {
                if (pwxdata.TYPE_LIST[i].SELECTED == 1) {
                    typeHTML.push('<option selected="selected" value="', pwxdata.TYPE_LIST[i].TYPE, '">', pwxdata.TYPE_LIST[i].TYPE, '</option>');
                }
                else {
                    typeHTML.push('<option value="', pwxdata.TYPE_LIST[i].TYPE, '">', pwxdata.TYPE_LIST[i].TYPE, '</option>');
                }
            }
            typeHTML.push('</select></dt>');
        }
    }
    $(typeElem).html(typeHTML.join(""))
    orderprovHTML = [];
    var fullOrderProv = $.map(pwxdata.TLIST, function (n, i) {
        return pwxdata.TLIST[i].ORDERING_PROVIDER;
    });
    var uniqueOrderProv = $.distinct(fullOrderProv);
    if (pwx_global_orderprovArr.length > 0 && pwx_global_orderprovFiltered == 1) {
        if (uniqueOrderProv.length > 0) {
            orderprovHTML.push('<span style="vertical-align:30%;">',amb_i18n.ORDERING_PROV,': </span><select id="task_orderprov" name="task_orderprov" multiple="multiple">');
            for (var i = 0; i < uniqueOrderProv.length; i++) {
                var type_match = 0;
                for (var y = 0; y < pwx_global_orderprovArr.length; y++) {
                    if (pwx_global_orderprovArr[y] == uniqueOrderProv[i]) {
                        type_match = 1;
                        break;
                    }
                }
                if (type_match == 1) {
                    orderprovHTML.push('<option selected="selected" value="', uniqueOrderProv[i], '">', uniqueOrderProv[i], '</option>');
                }
                else {
                    orderprovHTML.push('<option value="', uniqueOrderProv[i], '">', uniqueOrderProv[i], '</option>');
                }
            }
            orderprovHTML.push('</select>');
        }
    }
    else {
        if (uniqueOrderProv.length > 0) {
            orderprovHTML.push('<span style="vertical-align:30%;">',amb_i18n.ORDERING_PROV,': </span><select id="task_orderprov" name="task_orderprov" multiple="multiple">');
            for (var i = 0; i < uniqueOrderProv.length; i++) {
                orderprovHTML.push('<option selected="selected" value="', uniqueOrderProv[i], '">', uniqueOrderProv[i], '</option>');
            }
            orderprovHTML.push('</select>');
        }
    }
    $(orderprovElem).html(orderprovHTML.join(""))
    if (pwxdata.TYPE_PREF_FOUND == 1) {
        $('#pwx_task_type_pref_dt').attr("id", "pwx_update_task_type_pref_dt")
        $('#pwx_update_task_type_pref_dt').html('<span class="pwx-discsave_checkmark-icon">&nbsp;</span><span class="pwx-icon_submenu_arrow-icon">&nbsp;</span>')
        $('#pwx_frame_advanced_filters_container').append('<div id="pwx_task_type_update_menu" style="display:none;"><a class="pwx_result_link" id="pwx_update_task_type_pref">' + amb_i18n.UPDATE + '</a></br><a class="pwx_result_link" id="pwx_clear_task_type_pref">' + amb_i18n.CLEAR + '</a></div>')
    }
    else {
        $('#pwx_task_type_pref_dt').attr("id", "pwx_new_task_types_pref_dt")
        $('#pwx_new_task_types_pref_dt').html('<span id="pwx_new_task_types_pref" title="' + amb_i18n.SAVE_TASK_TYPE_TOOLTIP + '" class="pwx-discsave-icon">&nbsp;</span>')
    }
    if (pwx_global_expanded == 1) {
        $('#pwx_task_adv_filter_tgl').attr('title',amb_i18n.HIDE_ADV_FILTERS)
        $('#pwx_task_adv_filter_tgl').html('<span class="pwx-collapse-tgl"></span>')
    } else {
        $('#pwx_task_adv_filter_tgl').attr('title',amb_i18n.SHOW_ADV_FILTERS)
        $('#pwx_task_adv_filter_tgl').html('<span class="pwx-expand-tgl"></span>')
    }

    if (pwxdata.TASK_INFO_TEXT != "") {
        $('#pwx_task_info_icon').html('<a class="pwx_no_text_decor" title="' + amb_i18n.TASK_LIST_INFO + '"> <span class="pwx-information-icon">&nbsp;</span></a>');
        $('#pwx_task_info_icon a').on('click', function () {
            MP_ModalDialog.deleteModalDialogObject("TaskInfoModal")
            var taskInfoModal = new ModalDialog("TaskInfoModal")
             .setHeaderTitle(amb_i18n.TASK_LIST)
             .setShowCloseIcon(true)
             .setTopMarginPercentage(20)
             .setRightMarginPercentage(35)
             .setBottomMarginPercentage(35)
             .setLeftMarginPercentage(35)
             .setIsBodySizeFixed(true)
             .setHasGrayBackground(true)
             .setIsFooterAlwaysShown(false);
            taskInfoModal.setBodyDataFunction(
             function (modalObj) {
                 modalObj.setBodyHTML('<div class="pwx_task_detail">' + pwxdata.TASK_INFO_TEXT + '</div>');
             });
            MP_ModalDialog.addModalDialogObject(taskInfoModal);
            MP_ModalDialog.showModalDialog("TaskInfoModal")
        });
    }
    $("#task_status").multiselect({
        height: "80",
        classes: "pwx_select_box",
        noneSelectedText: amb_i18n.SELECT_STATUS,
        selectedList: 2
    });
    $("#task_type").multiselect({
        height: "300",
        classes: "pwx_select_box",
        noneSelectedText: amb_i18n.SELECT_TYPE,
        selectedList: 1
    });
    $("#task_orderprov").multiselect({
        height: "300",
        minWidth: "300",
        classes: "pwx_select_box",
        noneSelectedText: amb_i18n.SELECT_PROV,
        selectedList: 1
    });
 $("#task_orderprov").multiselect({
        height: "300",
        minWidth: "300",
        classes: "pwx_select_box",
        noneSelectedText: amb_i18n.SELECT_PROV,
        selectedList: 1
    });
    $('#pwx_task_type_update_menu').on('mouseleave', function (event) {
        $(this).css('display', 'none');
    });
    $('#pwx_update_task_type_pref_dt').on('click', function (event) {
        var dt_pos = $(this).position();
        $('#pwx_task_type_update_menu').css('top', dt_pos.top + 16).css('left', dt_pos.left + 20).css('display', 'block');
    });
    $('#pwx_new_task_types_pref_dt').on('click', function (event) {
        var js_criterion = JSON.parse(m_criterionJSON);
        var array_of_checked_values = $("#task_type").multiselect("getChecked").map(function () {
            return this.value;
        }).get();
        typeArr = jQuery.makeArray(array_of_checked_values);
        PWX_CCL_Request_User_Pref('amb_cust_mp_maintain_user_pref', js_criterion.CRITERION.PRSNL_ID, "PWX_MPAGE_ORG_TASK_LIST_TYPES", typeArr.join('|'), true)
        pwx_toggle_person_task_type_pref_save()
    });
    $('#pwx_update_task_type_pref').on('click', function (event) {
        var js_criterion = JSON.parse(m_criterionJSON);
        var array_of_checked_values = $("#task_type").multiselect("getChecked").map(function () {
            return this.value;
        }).get();
        typeArr = jQuery.makeArray(array_of_checked_values);
        PWX_CCL_Request_User_Pref('amb_cust_mp_maintain_user_pref', js_criterion.CRITERION.PRSNL_ID, "PWX_MPAGE_ORG_TASK_LIST_TYPES", typeArr.join('|'), true)
        $('#pwx_task_type_update_menu').css('display', 'none');
    });
    $('#pwx_clear_task_type_pref').on('click', function (event) {
        var js_criterion = JSON.parse(m_criterionJSON);
        PWX_CCL_Request_User_Pref('amb_cust_mp_maintain_user_pref', js_criterion.CRITERION.PRSNL_ID, "PWX_MPAGE_ORG_TASK_LIST_TYPES", "", true)
        $('#pwx_task_type_update_menu').css('display', 'none');
        pwx_toggle_person_task_type_pref_save()
    });

    framecontentElem.on('click', 'span.pwx_fcr_content_type_personname_dt a', function () {
        var parentelement = $(this).parents('dt.pwx_fcr_content_person_dt')
        var parentpersonid = $(parentelement).siblings('.pwx_person_id_hidden').text()
        var parentencntridid = $(parentelement).siblings('.pwx_encounter_id_hidden').text()
        var parameter_person_launch = '/PERSONID=' + parentpersonid + ' /ENCNTRID=' + parentencntridid + ' /FIRSTTAB=^^'
        APPLINK(0, "$APP_APPNAME$", parameter_person_launch)
    });
    framecontentElem.on('mousedown', 'dl.pwx_content_row', function (e) {
        if (e.which == '3') {
            $(this).removeClass('pwx_row_selected').addClass('pwx_row_selected');
			var persId = $(this).children('dt.pwx_person_id_hidden').text();
			var encntrId = $(this).children('dt.pwx_encounter_id_hidden').text();
			var persName = $(this).children('dt.pwx_person_name_hidden').text();
			pwx_set_patient_focus (persId, encntrId, persName);
        }
        else {
            //$(this).toggleClass('pwx_row_selected');
			if($(this).hasClass('pwx_row_selected') === true) {
				$(this).removeClass('pwx_row_selected');
				pwx_clear_patient_focus();
			} else {
				$(this).addClass('pwx_row_selected');
				var persId = $(this).children('dt.pwx_person_id_hidden').text();
				var encntrId = $(this).children('dt.pwx_encounter_id_hidden').text();
				var persName = $(this).children('dt.pwx_person_name_hidden').text();
				pwx_set_patient_focus (persId, encntrId, persName);
			}
        }
    });
    //create dialogs
    //create the task note modal
    var pwxdialogHTML = []
    //create the reschedule modal
    pwxdialogHTML.push('<div id="pwx-resched-dialog-confirm"><p class="pwx_small_text"><label for="pwx_resched_dt_tm"><span style="vertical-align:30%;">',amb_i18n.RESCHEDULED_TO,': </span><input type="text" id="pwx_resched_dt_tm" name="pwx_resched_dt_tm" style="width: 125px; height:14px;" /></label></p></div>');
    $('#pwx_frame_filter_bar').after(pwxdialogHTML.join(""))

    $("#pwx-resched-dialog-confirm").dialog({
        resizable: false,
        height: 200,
        modal: true,
        autoOpen: false,
        title: amb_i18n.RESCHEDULE_TASK,
        buttons: [
            {
                text: amb_i18n.RESCHEDULE,
                id: "pwx-reschedule-btn",
                disabled: true,
                click: function () {
                    var real_date = Date.parse($("#pwx_resched_dt_tm").datetimepicker('getDate'))
                    var string_date = real_date.toString("MM/dd/yyyy HH:mm")
                    var resched_dt_tm = string_date.split(" ");
                    PWX_CCL_Request_Task_Reschedule('amb_cust_srv_task_reschedule', reschedule_TaskIds, resched_dt_tm[0], resched_dt_tm[1], false);
                    $(this).dialog("close");
                }
            },
            {
                text: amb_i18n.CANCEL,
                click: function () {
                    $(this).dialog("close");
                }
            }
        ]
    });
    $("#pwx_resched_dt_tm").datetimepicker({
        dateFormat: "mm/dd/yy",
        showOn: "focus",
        changeMonth: true,
        changeYear: true,
        showButtonPanel: true,
        ampm: true,
        timeFormat: "hh:mmtt",
        onSelect: function (dateText, inst) {
            if (dateText != "") {
                $('#pwx-reschedule-btn').button('enable')
            }
        }
    });

    //quick chart icons
    framecontentElem.on('click', 'span.pwx-med_task-icon.pwx_pointer_cursor, span.pwx-form_task-icon.pwx_pointer_cursor', function (e) {
        cur_task_id = $(this).parent('.pwx_fcr_content_type_icon_dt').siblings('span.pwx_task_id_hidden').html() + ".0";
        cur_person_id = $(this).parent('.pwx_fcr_content_type_icon_dt').siblings('dt.pwx_person_id_hidden').html() + ".0";
        var taskSuccess = pwx_task_launch(cur_person_id, cur_task_id, 'CHART');
        $(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected')
        if (taskSuccess == true) {
            var dlHeight = $(this).parents('dl.pwx_content_row').height()
            $(this).siblings('div.pwx_fcr_content_action_bar').css('backgroundColor', '#87C854').css('height', dlHeight).attr("title", amb_i18n.CHARTED_DONE_REFRESH)
        }
    });
    framecontentElem.on('click', 'span.pwx-lab_task-icon.pwx_pointer_cursor', function (e) {
        cur_task_id = $(this).parent('dt.pwx_fcr_content_type_icon_dt').siblings('span.pwx_task_id_hidden').html() + ".0";
        cur_person_id = $(this).parent('.pwx_fcr_content_type_icon_dt').siblings('dt.pwx_person_id_hidden').html() + ".0";
        var taskSuccess = pwx_task_launch(cur_person_id, cur_task_id, 'CHART');
        $(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected')
        if (taskSuccess == true) {
            var dlHeight = $(this).parents('dl.pwx_content_row').height()
            $(this).siblings('div.pwx_fcr_content_action_bar').css('backgroundColor', '#87C854').css('height', dlHeight).attr("title", amb_i18n.CHARTED_DONE_REFRESH)
            if (pwxdata.LABEL_PRINT_AUTO_OFF != "1") {
                if (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0) {
                    var taskSuccess = pwx_task_label_print_launch(cur_person_id, cur_task_id);
                }
                else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRA") {
                    var orderIdlist = $(this).parents('dl.pwx_content_row').children('dt.pwx_task_order_id_hidden').html();
                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRA_LABEL','" + ccllinkparams + "',0)";
                }
                else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRASMALL") {
                    var orderIdlist = $(this).parents('dl.pwx_content_row').children('dt.pwx_task_order_id_hidden').html();
                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRASMALL','" + ccllinkparams + "',0)";
                }
                else {
                    var orderIdlist = $(this).parents('dl.pwx_content_row').children('dt.pwx_task_order_id_hidden').html();
                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_DYMO_LABEL','" + ccllinkparams + "',0)";
                }
            }
            if (pwxdata.AUTOLOG_SPEC_IND == 1) { setTimeout(function () { PWX_CCL_Request_Specimen_Login("amb_cust_call_spec_auto_loc", cur_task_id, true) }, 1000); }
        }
    });
    framecontentElem.on('click', 'span.pwx-clip_task-icon.pwx_pointer_cursor', function (e) {
        cur_task_id = $(this).parent('dt.pwx_fcr_content_type_icon_dt').siblings('span.pwx_task_id_hidden').html() + ".0";
        cur_person_id = $(this).parent('.pwx_fcr_content_type_icon_dt').siblings('dt.pwx_person_id_hidden').html() + ".0";
        var taskSuccess = pwx_task_launch(cur_person_id, cur_task_id, 'CHART_DONE');
        $(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected')
        if (taskSuccess == true) {
            var dlHeight = $(this).parents('dl.pwx_content_row').height()
            $(this).siblings('div.pwx_fcr_content_action_bar').css('backgroundColor', '#87C854').css('height', dlHeight).attr("title", amb_i18n.CHARTED_DONE_REFRESH)
        }
    });
    //single click menus
    framecontentElem.on('click', 'span.pwx-icon_submenu_arrow-icon.pwx_task_need_chart_menu', function (event) {
        pwx_task_submenu_clicked_task_id = $(this).parent('dt.pwx_fcr_content_type_icon_dt').siblings('span.pwx_task_id_hidden').html()  + ".0";
        pwx_task_submenu_clicked_order_id = $(this).parent('dt.pwx_fcr_content_type_icon_dt').siblings('dt.pwx_task_order_id_hidden').html() + ".0";
        pwx_task_submenu_clicked_person_id = $(this).parent('dt.pwx_fcr_content_type_icon_dt').siblings('dt.pwx_person_id_hidden').html() + ".0";
        pwx_task_submenu_clicked_task_type_ind = $(this).parent('dt.pwx_fcr_content_type_icon_dt').siblings('dt.pwx_task_type_ind_hidden').html();
        pwx_task_submenu_clicked_row_elem = $(this).parents('dl.pwx_content_row')
        $(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected')
        $('#pwx_task_chart_done_menu').css('display', 'none');
        var dt_pos = $(this).position();
        var test_var = document.documentElement.offsetHeight;
        var scrolled_bottom_var = $(document).scrollTop() + test_var
        if (($(this).offset().top + 40) > scrolled_bottom_var) {
            $('#pwx_task_chart_menu').css('top', dt_pos.top - 40);
        }
        else {
            $('#pwx_task_chart_menu').css('top', dt_pos.top);
        }
        $('#pwx_task_chart_menu').css('display', 'block');
    });
    framecontentElem.on('click', 'span.pwx-icon_submenu_arrow-icon.pwx_task_need_chart_done_menu', function (event) {
        pwx_task_submenu_clicked_task_id = $(this).parent('dt.pwx_fcr_content_type_icon_dt').siblings('span.pwx_task_id_hidden').html() + ".0";
        pwx_task_submenu_clicked_order_id = $(this).parent('dt.pwx_fcr_content_type_icon_dt').siblings('dt.pwx_task_order_id_hidden').html() + ".0";
        pwx_task_submenu_clicked_person_id = $(this).parent('dt.pwx_fcr_content_type_icon_dt').siblings('dt.pwx_person_id_hidden').html() + ".0";
        pwx_task_submenu_clicked_row_elem = $(this).parents('dl.pwx_content_row')
        $(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected')
        $('#pwx_task_chart_menu').css('display', 'none');
        var dt_pos = $(this).position();
        var test_var = document.documentElement.offsetHeight;
        var scrolled_bottom_var = $(document).scrollTop() + test_var
        if (($(this).offset().top + 55) > scrolled_bottom_var) {
            $('#pwx_task_chart_done_menu').css('top', dt_pos.top - 55);
        }
        else {
            $('#pwx_task_chart_done_menu').css('top', dt_pos.top);
        }
        $('#pwx_task_chart_done_menu').css('display', 'block');
    });
    //right click menu
    $.contextMenu('destroy', 'dl.pwx_content_row');
    $.contextMenu({
        selector: 'dl.pwx_content_row',
        zIndex: '9999',
        className: 'ui-widget',
        build: function ($trigger, e) {
            $($trigger).addClass('pwx_row_selected')
            var taskInfo = pwx_get_selected('dl.pwx_row_selected');
            // alert(taskInfo[0][0] + ',' + taskInfo[1][0] + ',' + taskInfo[2][0] + ',');
            taskIdlist = taskInfo[0].join(',');
            reschedule_TaskIds = taskInfo[0][0]
            var chart_done_tasks_found = 0;
            var chart_tasks_found = 0;
            var lab_tasks_found = 0;
            var none_lab_tasks_found = 0;
            var chart_done_str = '';
            var can_not_chart_found = 0;
            for (var cc = 0; cc < taskInfo[1].length; cc++) {
                if (taskInfo[1][cc] == 0) {
                    chart_done_tasks_found = 1;
                    none_lab_tasks_found = 1;
                    chart_done_str = 'CHART_DONE';
                }
                else if (taskInfo[1][cc] == 1 || taskInfo[1][cc] == 2) {
                    chart_tasks_found = 1;
                    none_lab_tasks_found = 1;
                    chart_done_str = 'CHART';
                }
                else if (taskInfo[1][cc] == 3) {
                    lab_tasks_found = 1;
                    chart_done_tasks_found = 1;
                    chart_done_str = 'CHART_DONE';
                }
                if (taskInfo[3][cc] == 0) {
                    can_not_chart_found = 1;
                }
            }
            var uniquePersonArr = []
            uniquePersonArr = $.grep(taskInfo[4], function (v, k) {
                return $.inArray(v, taskInfo[4]) === k;
            });
            var uniqueEncounterArr = []
            uniqueEncounterArr = $.grep(taskInfo[5], function (v, k) {
                return $.inArray(v, taskInfo[5]) === k;
            });
            var ccllinkparams = '^MINE^,^' + js_criterion.CRITERION.PWX_PATIENT_SUMM_PRG + '^,' + uniquePersonArr[0] + '.0,' + uniqueEncounterArr[0] + '.0';
            var options = {
                items: {
                    "Done": { "name": amb_i18n.DONE, callback: function (key, opt) {
                        var lab_taskAr = new Array()
                        var lab_OrderAr = new Array()
                        for (var cc = 0; cc < taskInfo[0].length; cc++) {
                            var taskSuccess = pwx_task_launch(taskInfo[4][cc], taskInfo[0][cc], chart_done_str);
                            if (taskSuccess == true) {
                                var dlHeight = $(taskInfo[6][cc]).height()
                                $(taskInfo[6][cc]).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#87C854').css('height', dlHeight).attr("title", amb_i18n.CHARTED_DONE_REFRESH)
                                $(taskInfo[6][cc]).removeClass('pwx_row_selected')
                                if (taskInfo[1][cc] == 3) {
                                    lab_taskAr.push(taskInfo[0][cc])
                                    lab_OrderAr.push(taskInfo[7][cc])
                                }
                            }
                        }
                        if (lab_taskAr.length > 0) {
                            if (pwxdata.LABEL_PRINT_AUTO_OFF != "1") {
                                if (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0) {
                                    var taskSuccess = pwx_task_label_print_launch(uniquePersonArr[0], lab_taskAr.join(','));
                                }
                                else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRA") {
                                    var orderIdlist = lab_OrderAr.join(',')
                                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRA_LABEL','" + ccllinkparams + "',0)";
                                }
                                else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRASMALL") {
                                    var orderIdlist = lab_OrderAr.join(',')
                                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRASMALL','" + ccllinkparams + "',0)";
                                }
                                else {
                                    var orderIdlist = lab_OrderAr.join(',')
                                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_DYMO_LABEL','" + ccllinkparams + "',0)";
                                }
                            }
                            if (pwxdata.AUTOLOG_SPEC_IND == 1) { setTimeout(function () { PWX_CCL_Request_Specimen_Login("amb_cust_call_spec_auto_loc", lab_taskAr.join(','), true) }, 1000); }
                        }
                    }
                    },
                    "Done (with Date/Time)": { "name": amb_i18n.DONE_WITH_DATE_TIME, callback: function (key, opt) {
                        for (var cc = 0; cc < taskInfo[0].length; cc++) {
                            var taskSuccess = pwx_task_launch(taskInfo[4][cc], taskInfo[0][cc], 'CHART_DONE_DT_TM');
                            if (taskSuccess == true) {
                                $('dl.pwx_row_selected').each(function (index) {
                                    var dlHeight = $(taskInfo[6][cc]).height()
                                    $(taskInfo[6][cc]).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#87C854').css('height', dlHeight).attr("title", amb_i18n.CHARTED_DONE_REFRESH)
                                    $(taskInfo[6][cc]).removeClass('pwx_row_selected')
                                });
                            }
                        }
                    }
                    },
                    "Not Done": { "name": amb_i18n.NOT_DONE, callback: function (key, opt) {
                        for (var cc = 0; cc < taskInfo[0].length; cc++) {
                            var taskSuccess = pwx_task_launch(taskInfo[4][cc], taskInfo[0][cc], 'CHART_NOT_DONE');
                            if (taskSuccess == true) {
                                var dlHeight = $(taskInfo[6][cc]).height()
                                $(taskInfo[6][cc]).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#DF5E3E').css('height', dlHeight).attr("title", amb_i18n.CHARTED_NOT_DONE_REFRESH)
                                $(taskInfo[6][cc]).removeClass('pwx_row_selected')
                            }
                        }
                    }
                    },
                    "sep1": "---------",
                    "Unchart": { "name": amb_i18n.UNCHART, callback: function (key, opt) {
                        if (taskInfo[1][0] == 3) {
                            var unchartHTML = '<p class="pwx_small_text">';
                            var unchartArr = pwx_get_selected_unchart_data('dl.pwx_row_selected');
                            unchartHTML += amb_i18n.SELECT_UNCHART + ':';
                            for (var cc = 0; cc < unchartArr.length; cc++) {
                                unchartHTML += '<br /><input type="checkbox" checked="checked" name="pwx_unchart_tasks" value="' + unchartArr[cc][1] + '" />' + unchartArr[cc][0];
                            }
                            unchartHTML += '</p>';
                            MP_ModalDialog.deleteModalDialogObject("UnchartTaskModal")
                            var unChartTaskModal = new ModalDialog("UnchartTaskModal")
                                .setHeaderTitle(amb_i18n.UNCHART_TASK)
                                .setTopMarginPercentage(20)
                                .setRightMarginPercentage(30)
                                .setBottomMarginPercentage(20)
                                .setLeftMarginPercentage(30)
                                .setIsBodySizeFixed(true)
                                .setHasGrayBackground(true)
                                .setIsFooterAlwaysShown(true);
                            unChartTaskModal.setBodyDataFunction(
                            function (modalObj) {
                                modalObj.setBodyHTML('<div style="padding-top:10px;">' + unchartHTML + '</div>');
                            });
                            var unchartbtn = new ModalButton("UnchartTask");
                            unchartbtn.setText(amb_i18n.UNCHART).setCloseOnClick(true).setOnClickFunction(function () {
                                var taskidObj = $("input[name='pwx_unchart_tasks']:checked").map(function () { return $(this).val(); });
                                var taskAr = jQuery.makeArray(taskidObj);
                                taskIdlist = taskAr.join(',');
                                if (taskIdlist != "") {
                                    PWX_CCL_Request_Task_Unchart('amb_cust_srv_task_unchart', taskIdlist, js_criterion.CRITERION.PRSNL_ID, '', '3', false);
                                }
                            });
                            var closebtn = new ModalButton("unchartCancel");
                            closebtn.setText(amb_i18n.CANCEL).setCloseOnClick(true);
                            unChartTaskModal.addFooterButton(unchartbtn)
                            unChartTaskModal.addFooterButton(closebtn)
                            MP_ModalDialog.addModalDialogObject(unChartTaskModal);
                            MP_ModalDialog.showModalDialog("UnchartTaskModal")
                            $('input[name="pwx_unchart_tasks"]').on('change', function (event) {
                                var any_checked = 0;
                                $('input[name="pwx_unchart_tasks"]').each(function (index) {
                                    if ($(this).prop("checked") == true) {
                                        any_checked = 1;
                                    }
                                });
                                if (any_checked == 0) {
                                    unChartTaskModal.setFooterButtonDither("UnchartTask", true);
                                }
                                else {
                                    unChartTaskModal.setFooterButtonDither("UnchartTask", false);
                                }
                            });
                        }
                        else {
                            MP_ModalDialog.deleteModalDialogObject("UnchartTaskModal")
                            var unChartTaskModal = new ModalDialog("UnchartTaskModal")
                                .setHeaderTitle(amb_i18n.UNCHART_TASK)
                                .setTopMarginPercentage(20)
                                .setRightMarginPercentage(30)
                                .setBottomMarginPercentage(20)
                                .setLeftMarginPercentage(30)
                                .setIsBodySizeFixed(true)
                                .setHasGrayBackground(true)
                                .setIsFooterAlwaysShown(true);
                            unChartTaskModal.setBodyDataFunction(
                            function (modalObj) {
                                modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text"><label for="pwx_unchart_task_comment">' + amb_i18n.UNCHART_COMM + ': <br/><textarea  class="text ui-widget-content ui-corner-all" rows="5" style="width:98%" ' +
                                'id="pwx_unchart_task_comment" name="pwx_unchart_task_comment" /></textarea></label></p></div>');
                            });
                            var unchartbtn = new ModalButton("UnchartTask");
                            unchartbtn.setText(amb_i18n.UNCHART).setCloseOnClick(true).setIsDithered(true).setOnClickFunction(function () {
                                var comment_text = $('#pwx_unchart_task_comment').text()
                                PWX_CCL_Request_Task_Unchart('amb_cust_srv_task_unchart', taskIdlist, js_criterion.CRITERION.PRSNL_ID, comment_text, taskInfo[1][0], false);
                                $(this).dialog("close");
                            });
                            var closebtn = new ModalButton("unchartCancel");
                            closebtn.setText(amb_i18n.CANCEL).setCloseOnClick(true);
                            unChartTaskModal.addFooterButton(unchartbtn)
                            unChartTaskModal.addFooterButton(closebtn)
                            MP_ModalDialog.addModalDialogObject(unChartTaskModal);
                            MP_ModalDialog.showModalDialog("UnchartTaskModal")
                            $('#pwx_unchart_task_comment').on('keyup', function (event) {
                                if ($('#pwx_unchart_task_comment').text() != "") {
                                    $("#pwx-task-unchart-btn").button("enable");
                                    unChartTaskModal.setFooterButtonDither("UnchartTask", false);
                                }
                                else {
                                    $("#pwx-task-unchart-btn").button("disable");
                                    unChartTaskModal.setFooterButtonDither("UnchartTask", true);
                                }
                            })
                        }
                    }
                    },
                    "Reschedule": { "name": amb_i18n.RESCHEDULE, callback: function (key, opt) {
                        var time_check = pwx_get_selected_resched_time_limit('dl.pwx_row_selected');
                        var task_dt = Date.parse(time_check[1]);
                        if (lab_tasks_found == 0) {
                            var resched_limit_dt = task_dt.addHours(time_check[0]);
                        }
                        else {
                            var curDate = new Date()
                            var resched_limit_dt = curDate.addHours(time_check[0]);
                        }
                        $('#pwx_resched_dt_tm').val("")
                        $('#pwx-reschedule-btn').button('disable')
                        $("#pwx_resched_dt_tm").datetimepicker('option', 'minDate', new Date());
                        $("#pwx_resched_dt_tm").datetimepicker('option', 'maxDate', resched_limit_dt);
                        $("#pwx-resched-dialog-confirm").dialog('open')
                    }
                    },
                    "Task Comment": { "name": amb_i18n.TASK_COMM, callback: function (key, opt) {
                        var task_comm = pwx_get_selected_task_comment('dl.pwx_row_selected');
                        if (task_comm != "--") {
                            MP_ModalDialog.deleteModalDialogObject("TaskCommentModal")
                            var taskCommentModal = new ModalDialog("TaskCommentModal")
                                .setHeaderTitle(amb_i18n.TASK_COMM)
                                .setTopMarginPercentage(20)
                                .setRightMarginPercentage(35)
                                .setBottomMarginPercentage(20)
                                .setLeftMarginPercentage(35)
                                .setIsBodySizeFixed(true)
                                .setHasGrayBackground(true)
                                .setIsFooterAlwaysShown(true);
                            taskCommentModal.setBodyDataFunction(
                            function (modalObj) {
                                modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text"><label for="pwx_create_task_comment">' + amb_i18n.TASK_COMM + ': <br/><textarea  class="text ui-widget-content ui-corner-all" rows="5" style="width:98%" id="pwx_create_task_comment" name="pwx_create_task_comment" >' + task_comm + '</textarea></label></p></div>');
                            });
                            var removebtn = new ModalButton("RemoveTaskComment");
                            removebtn.setText(amb_i18n.REMOVE).setCloseOnClick(true).setOnClickFunction(function () {
                                $('#pwx_create_task_comment').text("");
                                var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                                orderIdlist = orderInfo.join(',');
                                PWX_CCL_Request_Task_Add_Task_Note('amb_cust_srv_task_add_comment', orderIdlist, "", false);
                            });
                            var updatebtn = new ModalButton("updateTaskComment");
                            updatebtn.setText(amb_i18n.UPDATE).setCloseOnClick(true).setOnClickFunction(function () {
                                var comment_text = $('#pwx_create_task_comment').text();
                                var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                                orderIdlist = orderInfo.join(',');
                                PWX_CCL_Request_Task_Add_Task_Note('amb_cust_srv_task_add_comment', orderIdlist, comment_text, false);
                            });
                            var closebtn = new ModalButton("commentCancel");
                            closebtn.setText(amb_i18n.CANCEL).setCloseOnClick(true);
                            taskCommentModal.addFooterButton(removebtn)
                            taskCommentModal.addFooterButton(updatebtn)
                            taskCommentModal.addFooterButton(closebtn)
                            MP_ModalDialog.addModalDialogObject(taskCommentModal);
                            MP_ModalDialog.showModalDialog("TaskCommentModal")
                        }
                        else {
                            MP_ModalDialog.deleteModalDialogObject("TaskCommentModal")
                            var taskCommentModal = new ModalDialog("TaskCommentModal")
                                .setHeaderTitle(amb_i18n.TASK_COMM)
                                .setTopMarginPercentage(20)
                                .setRightMarginPercentage(35)
                                .setBottomMarginPercentage(20)
                                .setLeftMarginPercentage(35)
                                .setIsBodySizeFixed(true)
                                .setHasGrayBackground(true)
                                .setIsFooterAlwaysShown(true);
                            taskCommentModal.setBodyDataFunction(
                            function (modalObj) {
                                modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text"><label for="pwx_create_task_comment">' + amb_i18n.TASK_COMM + ': <br/><textarea  class="text ui-widget-content ui-corner-all" rows="5" style="width:98%" id="pwx_create_task_comment" name="pwx_create_task_comment" ></textarea></label></p></div>');
                            });
                            var createbtn = new ModalButton("createTaskComment");
                            createbtn.setText(amb_i18n.CREATE).setCloseOnClick(true).setIsDithered(true).setOnClickFunction(function () {
                                var comment_text = $('#pwx_create_task_comment').text()
                                if (comment_text != "") {
                                    var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                                    orderIdlist = orderInfo.join(',');
                                    PWX_CCL_Request_Task_Add_Task_Note('amb_cust_srv_task_add_comment', orderIdlist, comment_text, false);
                                }
                            });
                            var closebtn = new ModalButton("commentCancel");
                            closebtn.setText(amb_i18n.CANCEL).setCloseOnClick(true);
                            taskCommentModal.addFooterButton(createbtn)
                            taskCommentModal.addFooterButton(closebtn)
                            MP_ModalDialog.addModalDialogObject(taskCommentModal);
                            MP_ModalDialog.showModalDialog("TaskCommentModal")
                            $('#pwx_create_task_comment').on('keyup', function (event) {
                                if ($('#pwx_create_task_comment').text() != "") {
                                    $("#pwx_create_task_comment_btn").button("enable");
                                    taskCommentModal.setFooterButtonDither("createTaskComment", false);
                                }
                                else {
                                    $("#pwx_create_task_comment_btn").button("disable");
                                    taskCommentModal.setFooterButtonDither("createTaskComment", true);
                                }
                            })
                        }
                    }
                    },
                    "sep2": "---------",
                    "Print Label(s)": { "name": amb_i18n.PRINT_LABELS, callback: function (key, opt) {
                        if (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0) {
                            var taskSuccess = pwx_task_label_print_launch(uniquePersonArr[0], taskIdlist);
                        }
                        else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRA") {
                            var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                            orderIdlist = orderInfo.join(',');
                            var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                            window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRA_LABEL','" + ccllinkparams + "',0)";
                        }
                        else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRASMALL") {
                            var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                            orderIdlist = orderInfo.join(',');
                            var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                            window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRASMALL','" + ccllinkparams + "',0)";
                        }
                        else {
                            var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                            orderIdlist = orderInfo.join(',');
                            var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                            window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_DYMO_LABEL','" + ccllinkparams + "',0)";
                        }
                        $('dl.pwx_row_selected').removeClass('pwx_row_selected')
                    }
                    },
                    "fold2": { "name": amb_i18n.PRINT_REQ,
                        //"name": "Print Requisitions&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                        "items": {
                            "Selected Requisitions": { "name": amb_i18n.SELECTED_REQ, callback: function (key, opt) {
                                if (lab_tasks_found == 1) {
                                    var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                                    orderIdlist = orderInfo.join(',');
                                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^,' + 0 + ',' + js_criterion.CRITERION.PRSNL_ID + '.0';
                                    window.location = "javascript:CCLLINK('amb_cust_mp_reflab_call_labreq','" + ccllinkparams + "',0)";
                                } else {
                                    var ccllinkparams = '^MINE^,^' + taskIdlist + '^,' + 0;
                                    window.location = "javascript:CCLLINK('amb_cust_mp_call_orderreq','" + ccllinkparams + "',0)";
                                }
                            }
                            },
                            "Visit Requisitions": { "name": amb_i18n.VISIT_REQ, callback: function (key, opt) {
                                if (lab_tasks_found == 1) {
                                    var ccllinkparams = '^MINE^,^^,' + uniqueEncounterArr[0] + ',' + js_criterion.CRITERION.PRSNL_ID + '.0';
                                    window.location = "javascript:CCLLINK('amb_cust_mp_reflab_call_labreq','" + ccllinkparams + "',0)";
                                } else {
                                    var ccllinkparams = '^MINE^,^^,' + uniqueEncounterArr[0] + '';
                                    window.location = "javascript:CCLLINK('amb_cust_mp_call_orderreq','" + ccllinkparams + "',0)";
                                }
                            }
                            }

                        }
                    },
                    "sep3": "---------",
                    //"Patient Summary": { "name": "Patient Summary", callback: function (key, opt) { callCCLLINK(ccllinkparams); } },
                    "fold1": {
                        //"name": "Chart Forms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                        "name": amb_i18n.CHART_FORMS,
                        "items": {},
                        disabled: false
                    },
                    "sep4": "---------",
                    "Select All": { "name": amb_i18n.SELECT_ALL, callback: function (key, opt) { pwx_select_all('pwx_row_selected'); } },
                    "Deselect All": { "name": amb_i18n.DESELECT_ALL, callback: function (key, opt) { pwx_deselect_all('pwx_row_selected'); } },
                    "sep5": "---------",
                    "fold3": {
                        //"name": "Chart Forms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                        "name": amb_i18n.OPEN_PT_CHART,
                        "items": {},
                        disabled: false
                    }
                }
            };
            if (uniqueEncounterArr.length > 1) {
                options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
                //options.items["Patient Summary"] = { "name": "Patient Summary", disabled: function (key, opt) { return true; } };
                //options.items["Print Requisitions"] = { "name": "Print Requisitions", disabled: function (key, opt) { return true; } };
                options.items["fold2"].items["Visit Requisitions"] = { "name": amb_i18n.VISIT_REQ, disabled: function (key, opt) { return true; } };
                options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
            }
            else {
                if (pwxdata.FORMSLIST.length > 0) {
                    for (var cc in pwxdata.FORMSLIST) {
                        options.items["fold1"].items[cc + "|forms"] = { "name": pwxdata.FORMSLIST[cc].FORM_NAME, callback: function (key, opt) { var keyArr = key.split("|"); pwx_form_launch(uniquePersonArr[0], uniqueEncounterArr[0], pwxdata.FORMSLIST[keyArr[0]].FORM_ID, 0.0, 0); } }
                    }
                    options.items["fold1"].items["Forms Menu"] = { "name": amb_i18n.ALL_FORMS, "className": "pwx_link_blue", callback: function (key, opt) { pwx_form_launch(uniquePersonArr[0], uniqueEncounterArr[0], 0.0, 0.0, 0); } }
                }
                else {
                    options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
                }
                if (js_criterion.CRITERION.VPREF.length > 0) {
                    for (var cc in js_criterion.CRITERION.VPREF) {
                        options.items["fold3"].items[cc] = { "name": js_criterion.CRITERION.VPREF[cc].VIEW_CAPTION, callback: function (key, opt) {
                            var parameter_person_launch = '/PERSONID=' + uniquePersonArr[0] + ' /ENCNTRID=' + uniqueEncounterArr[0] + ' /FIRSTTAB=^' + js_criterion.CRITERION.VPREF[key].VIEW_CAPTION + '^'
                            APPLINK(0, "$APP_APPNAME$", parameter_person_launch)
                        }
                        }
                    }
                }
                else {
                    options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
                }
            }
            if (pwxdata.ALLOW_REQ_PRINT == 1) {
                options.items["fold2"] = { "name": amb_i18n.PRINT_REQ, disabled: function (key, opt) { return true; } };
            }
            if (uniquePersonArr.length > 1) {
                options.items["fold2"] = { "name": amb_i18n.PRINT_REQ, disabled: function (key, opt) { return true; } };
            }
            if (taskInfo[0].length > 1) {
                options.items["Unchart"] = { "name": amb_i18n.UNCHART, disabled: function (key, opt) { return true; } };
                options.items["Reschedule"] = { "name": amb_i18n.RESCHEDULE, disabled: function (key, opt) { return true; } };
                options.items["Task Comment"] = { "name": amb_i18n.TASK_COMM, disabled: function (key, opt) { return true; } };
            }
            else {
                //check reschedule
                var time_check = pwx_get_selected_resched_time_limit('dl.pwx_row_selected');
                if (time_check[1] == "PRN" || time_check[0] < 1) {
                    options.items["Reschedule"] = { "name": amb_i18n.RESCHEDULE, disabled: function (key, opt) { return true; } };
                }
                else {
                    if (lab_tasks_found == 0) {
                        options.items["Print Label(s)"] = { "name": amb_i18n.PRINT_LABELS, disabled: function (key, opt) { return true; } };
                        var task_dt = Date.parse(time_check[1]);
                        var resched_limit_dt = task_dt.addHours(time_check[0]);
                        var curDate = new Date()
                        var resched_ind = resched_limit_dt.compareTo(curDate);
                        if (resched_ind != 1) {
                            options.items["Reschedule"] = { "name": amb_i18n.RESCHEDULE, disabled: function (key, opt) { return true; } };
                        }
                    }
                }
            }
            var task_status_cancel_all = 0;
            var task_status_all_complete = 1;
            var task_status_complete_present = 0;
            var task_status_active_present = 0;
            for (var cc = 0; cc < taskInfo[2].length; cc++) {
                if (taskInfo[2][cc] != "Complete") {
                    task_status_all_complete = 0;
                }
                if (taskInfo[2][cc] == "Discontinued") {
                    task_status_cancel_all = 1;
                }
                else if (taskInfo[2][cc] == "Complete") {
                    task_status_complete_present = 1;
                }
                else {
                    task_status_active_present = 1;
                }
            }
            if (task_status_cancel_all == 1 || can_not_chart_found == 1) {
                options.items["Done"] = { "name": amb_i18n.DONE, disabled: function (key, opt) { return true; } };
                options.items["Not Done"] = { "name": amb_i18n.NOT_DONE, disabled: function (key, opt) { return true; } };
                options.items["Done (with Date/Time)"] = { "name": amb_i18n.DONE_WITH_DATE_TIME, disabled: function (key, opt) { return true; } };
                options.items["Unchart"] = { "name": amb_i18n.UNCHART, disabled: function (key, opt) { return true; } };
                options.items["Reschedule"] = { "name": amb_i18n.RESCHEDULE, disabled: function (key, opt) { return true; } };
                options.items["Task Comment"] = { "name": amb_i18n.TASK_COMM, disabled: function (key, opt) { return true; } };
                options.items["Print Label(s)"] = { "name": amb_i18n.PRINT_LABELS, disabled: function (key, opt) { return true; } };

            }
            else if (task_status_all_complete == 1) {
                options.items["Done"] = { "name": amb_i18n.DONE, disabled: function (key, opt) { return true; } };
                options.items["Not Done"] = { "name": amb_i18n.NOT_DONE, disabled: function (key, opt) { return true; } };
                options.items["Done (with Date/Time)"] = { "name": amb_i18n.DONE_WITH_DATE_TIME, disabled: function (key, opt) { return true; } };
                options.items["Reschedule"] = { "name": amb_i18n.RESCHEDULE, disabled: function (key, opt) { return true; } };
                //options.items["Task Comment"] = { "name": amb_i18n.TASK_COMM, disabled: function (key, opt) { return true; } };
                if (lab_tasks_found == 1) {
                    var unchart_status = pwx_get_selected_unchart_not_done('dl.pwx_row_selected');
                    if (unchart_status[0] > 0) {
                        options.items["Unchart"] = { "name": amb_i18n.UNCHART, disabled: function (key, opt) { return true; } };
                    }
                }
                if (none_lab_tasks_found == 1) {
                    options.items["Print Label(s)"] = { "name": amb_i18n.PRINT_LABELS, disabled: function (key, opt) { return true; } };
                }
            }
            else if (task_status_all_complete == 0 && task_status_complete_present == 1) {
                options.items["Done"] = { "name": amb_i18n.DONE, disabled: function (key, opt) { return true; } };
                options.items["Not Done"] = { "name": amb_i18n.NOT_DONE, disabled: function (key, opt) { return true; } };
                options.items["Done (with Date/Time)"] = { "name": amb_i18n.DONE_WITH_DATE_TIME, disabled: function (key, opt) { return true; } };
                options.items["Unchart"] = { "name": amb_i18n.UNCHART, disabled: function (key, opt) { return true; } };
                options.items["Reschedule"] = { "name": amb_i18n.RESCHEDULE, disabled: function (key, opt) { return true; } };
                //options.items["Task Comment"] = { "name": amb_i18n.TASK_COMM, disabled: function (key, opt) { return true; } };
                options.items["Print Label(s)"] = { "name": amb_i18n.PRINT_LABELS, disabled: function (key, opt) { return true; } };
            }
            else {
                options.items["Unchart"] = { "name": amb_i18n.UNCHART, disabled: function (key, opt) { return true; } };
                if (chart_done_tasks_found == 1 && chart_tasks_found == 1) {
                    options.items["Done"] = { "name": amb_i18n.DONE, disabled: function (key, opt) { return true; } };
                    options.items["Done (with Date/Time)"] = { "name": amb_i18n.DONE_WITH_DATE_TIME, disabled: function (key, opt) { return true; } };
                    options.items["Print Label(s)"] = { "name": amb_i18n.PRINT_LABELS, disabled: function (key, opt) { return true; } };
                }
                else if (chart_done_tasks_found == 0 && chart_tasks_found == 1) {
                    options.items["Done (with Date/Time)"] = { "name": amb_i18n.DONE_WITH_DATE_TIME, disabled: function (key, opt) { return true; } };
                    options.items["Print Label(s)"] = { "name": amb_i18n.PRINT_LABELS, disabled: function (key, opt) { return true; } };
                }
                if (lab_tasks_found == 1) {
                    options.items["Done (with Date/Time)"] = { "name": amb_i18n.DONE_WITH_DATE_TIME, disabled: function (key, opt) { return true; } };
                    options.items["Task Comment"] = { "name": amb_i18n.TASK_COMM, disabled: function (key, opt) { return true; } };
                } else {
                    options.items["Print Label(s)"] = { "name": amb_i18n.PRINT_LABELS, disabled: function (key, opt) { return true; } };
                }
                if (none_lab_tasks_found == 1) {
                    options.items["Print Label(s)"] = { "name": amb_i18n.PRINT_LABELS, disabled: function (key, opt) { return true; } };
                }
            }
            if(lab_tasks_found == 1){
				options.items["Task Comment"] = { "name": "Task Comment", disabled: function (key, opt) { return true; } };				
			}
            if (uniquePersonArr.length > 1 && (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0)) {
                options.items["Print Label(s)"] = { "name": amb_i18n.PRINT_LABELS, disabled: function (key, opt) { return true; } };
            }
            if (none_lab_tasks_found == 1 && lab_tasks_found == 1) {
                options.items["fold2"] = { "name": amb_i18n.PRINT_REQ, disabled: function (key, opt) { return true; } };
            }
            return options;
        }
    });
    $('#pwx_task_list_refresh_icon').html('<span class="pwx-refresh-icon" title="' + amb_i18n.REFRESH_LIST + '"></span>')
    $('#pwx_task_list_refresh_icon').on('click', function () {
        framecontentElem.empty();
        framecontentElem.html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
        start_pwx_timer()
        var start_ccl_timer = new Date();
        var sendArr = ["^MINE^", js_criterion.CRITERION.PRSNL_ID + ".0", js_criterion.CRITERION.POSITION_CD + ".0", "^" + pwx_task_global_from_date + "^", "^" + pwx_task_global_to_date + "^", pwx_current_set_location + ".0"];
        PWX_CCL_Request("amb_cust_mp_task_by_loc_dt", sendArr, true, function () {
            var end_ccl_timer = new Date();
            ccl_timer = (end_ccl_timer - start_ccl_timer) / 1000
            start_page_load_timer = new Date();
            if (pwx_task_load_counter == 0) {
                this.TLIST.sort(pwx_sort_by_task_date)
                RenderTaskList(this);
                pwx_task_load_counter += 1;
            }
            else {
                switch (pwx_task_header_id) {
                    case 'pwx_fcr_header_task_dt':
                        this.TLIST.sort(pwx_sort_by_task)
                        break;
                    case 'pwx_fcr_header_personname_dt':
                        this.TLIST.sort(pwx_sort_by_personname)
                        break;
                    case 'pwx_fcr_header_visitdate_dt':
                        this.TLIST.sort(pwx_sort_by_visitdate)
                        break;
                    case 'pwx_fcr_header_schdate_dt':
                        this.TLIST.sort(pwx_sort_by_task_date)
                        break;
                    case 'pwx_fcr_header_orderby_dt':
                        this.TLIST.sort(pwx_sort_by_order_by)
                        break;
                    case 'pwx_fcr_header_type_dt':
                        this.TLIST.sort(pwx_sort_by_task_type)
                        break;
                    case 'pwx_fcr_header_status_dt':
                        this.TLIST.sort(pwx_sort_by_status)
                        break;
                }
                if (pwx_task_sort_ind == "1") {
                    this.TLIST.reverse()
                }
                filterbar_timer = 0
                json_task_start_number = 0;
                json_task_end_number = 0;
                json_task_page_start_numbersAr = [];
                task_list_curpage = 1;
                //pwxstoreddata = this;
                RenderTaskListContent(this)
                pwx_task_load_counter += 1;
            }
        });
    });
    
    var end_filterbar_timer = new Date();
    filterbar_timer = (end_filterbar_timer - start_filterbar_timer) / 1000
    RenderTaskListContent(pwxdata)
}

function RenderTaskListContent(pwxdata) {
	var framecontentElem =  $('#pwx_frame_content')
    $.contextMenu('destroy', 'span.pwx_fcr_content_type_person_icon_dt');
	pwx_clear_patient_focus();
    var js_criterion = JSON.parse(m_criterionJSON);
    var start_content_timer = new Date();
    var fullOrderProv = $.map(pwxdata.TLIST, function (n, i) {
        return pwxdata.TLIST[i].ORDERING_PROVIDER;
    });
    var uniqueOrderProv = $.distinct(fullOrderProv);
    if (pwx_task_load_counter > 0) {
        $('#pwx_task_orderprov_filter').empty();
        var orderprovElem = $('#pwx_task_orderprov_filter')
        orderprovHTML = [];
        if (pwx_global_orderprovArr.length > 0 && pwx_global_orderprovFiltered == 1) {
            if (uniqueOrderProv.length > 0) {
                orderprovHTML.push('<span style="vertical-align:30%;">',amb_i18n.ORDERING_PROV,': </span><select id="task_orderprov" name="task_orderprov" multiple="multiple">');
                for (var i = 0; i < uniqueOrderProv.length; i++) {
                    var type_match = 0;
                    for (var y = 0; y < pwx_global_orderprovArr.length; y++) {
                        if (pwx_global_orderprovArr[y] == uniqueOrderProv[i]) {
                            type_match = 1;
                            break;
                        }
                    }
                    if (type_match == 1) {
                        orderprovHTML.push('<option selected="selected" value="', uniqueOrderProv[i], '">', uniqueOrderProv[i], '</option>');
                    }
                    else {
                        orderprovHTML.push('<option value="', uniqueOrderProv[i], '">', uniqueOrderProv[i], '</option>');
                    }
                }
                orderprovHTML.push('</select>');
            }
        }
        else {
            if (uniqueOrderProv.length > 0) {
                orderprovHTML.push('<span style="vertical-align:30%;">',amb_i18n.ORDERING_PROV,': </span><select id="task_orderprov" name="task_orderprov" multiple="multiple">');
                for (var i = 0; i < uniqueOrderProv.length; i++) {
                    orderprovHTML.push('<option selected="selected" value="', uniqueOrderProv[i], '">', uniqueOrderProv[i], '</option>');
                }
                orderprovHTML.push('</select>');
            }
        }
        $(orderprovElem).html(orderprovHTML.join(""))
        $("#task_orderprov").multiselect({
            height: "300",
            minWidth: "300",
            classes: "pwx_select_box",
            noneSelectedText: amb_i18n.SELECT_PROV,
            selectedList: 1
        });
    }

    $("#task_status").off("multiselectclose")
    $("#task_type").off("multiselectclose")
    $("#task_orderprov").off("multiselectclose")
    framecontentElem.off('click', 'span.pwx_fcr_content_type_detail_icon_dt')
    framecontentElem.off('click', 'span.pwx_fcr_content_type_person_icon_dt')
    framecontentElem.off('click', 'dt.pwx_fcr_content_task_abn_dt')
    $("#task_status").on("multiselectclose", function (event, ui) {
        framecontentElem.empty();
        framecontentElem.html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
        start_pwx_timer()
        start_page_load_timer = new Date();
        json_task_start_number = 0;
        json_task_end_number = 0;
        json_task_page_start_numbersAr = [];
        task_list_curpage = 1;
        RenderTaskListContent(pwxdata);
    });
    $("#task_type").on("multiselectclose", function (event, ui) {
        framecontentElem.empty();
        framecontentElem.html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
        start_pwx_timer()
        start_page_load_timer = new Date();
        json_task_start_number = 0;
        json_task_end_number = 0;
        json_task_page_start_numbersAr = [];
        task_list_curpage = 1;
        RenderTaskListContent(pwxdata);
    });
    $("#task_orderprov").on("multiselectclose", function (event, ui) {
        var array_of_checked_values = $("#task_orderprov").multiselect("getChecked").map(function () {
            return this.value;
        }).get();
        pwx_global_orderprovArr = jQuery.makeArray(array_of_checked_values);
        if (pwx_global_orderprovArr.length == uniqueOrderProv.length) {
            pwx_global_orderprovFiltered = 0
        } else {
            pwx_global_orderprovFiltered = 1
        }
        framecontentElem.empty();
        framecontentElem.html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
        start_pwx_timer()
        start_page_load_timer = new Date();
        json_task_start_number = 0;
        json_task_end_number = 0;
        json_task_page_start_numbersAr = [];
        task_list_curpage = 1;
        RenderTaskListContent(pwxdata);
    });
    $('#pwx_task_filterbar_page_prev').html("")
    $('#pwx_task_filterbar_page_prev').off()
    $('#pwx_task_filterbar_page_next').html("")
    $('#pwx_task_filterbar_page_next').off()
    var array_of_checked_values = $("#task_orderprov").multiselect("getChecked").map(function () {
        return this.value;
    }).get();
    pwx_global_orderprovArr = jQuery.makeArray(array_of_checked_values);
    var array_of_checked_values = $("#task_status").multiselect("getChecked").map(function () {
        return this.value;
    }).get();
    pwx_global_statusArr = jQuery.makeArray(array_of_checked_values);

    var array_of_checked_values = $("#task_type").multiselect("getChecked").map(function () {
        return this.value;
    }).get();
    pwx_global_typeArr = jQuery.makeArray(array_of_checked_values);
    var pwxcontentHTML = [];

    if (pwxdata.TLIST.length > 0) {
        //icon type
        if (pwx_task_sort_ind == '1') {
            var sort_icon = 'pwx-sort_up-icon';
        }
        else {
            var sort_icon = 'pwx-sort_down-icon';
        }
        //make the header
        pwxcontentHTML.push('<div id="pwx_frame_content_rows_header"><dl id="pwx_frame_rows_header_dl"><dt id="pwx_fcr_header_type_icon_dt">&nbsp;</dt>');
        if (pwx_task_header_id == 'pwx_fcr_header_personname_dt') {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_personname_dt">',amb_i18n.PATIENT,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
        }
        else {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_personname_dt">',amb_i18n.PATIENT,'</dt>');
        }
        if (pwx_task_header_id == 'pwx_fcr_header_visitdate_dt') {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_visitdate_dt">',amb_i18n.VISIT_DATE,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
        }
        else {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_visitdate_dt">',amb_i18n.VISIT_DATE,'</dt>');
        }
        if (pwx_task_header_id == 'pwx_fcr_header_task_dt') {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_task_dt">',amb_i18n.TASK_ORDER,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
        }
        else {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_task_dt">',amb_i18n.TASK_ORDER,'</dt>');
        }
        if (pwx_task_header_id == 'pwx_fcr_header_schdate_dt') {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_schdate_dt">',amb_i18n.TASK_DATE,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
        }
        else {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_schdate_dt">',amb_i18n.TASK_DATE,'</dt>');
        }
        if (pwx_task_header_id == 'pwx_fcr_header_orderby_dt') {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_orderby_dt">',amb_i18n.ORDERING_PROV,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
        }
        else {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_orderby_dt">',amb_i18n.ORDERING_PROV,'</dt>');
        }
        if (pwx_task_header_id == 'pwx_fcr_header_type_dt') {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_type_dt">',amb_i18n.TYPE,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
        }
        else {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_type_dt">',amb_i18n.TYPE,'</dt>');
        }

        pwxcontentHTML.push('</dl></div>');
		pwxcontentHTML.push('<div id="pwx_frame_content_rows">');
		pwxcontentHTML.push('<div class="pwx_form-menu" id="pwx_task_chart_menu" style="display:none;"><a class="pwx_result_link" id="pwx_task_chart_link">',amb_i18n.DONE,'</a></br><a class="pwx_result_link" id="pwx_task_chart_not_done_link">',amb_i18n.NOT_DONE,'</a></div>');
		pwxcontentHTML.push('<div class="pwx_form-menu" id="pwx_task_chart_done_menu" style="display:none;"><a class="pwx_result_link" id="pwx_task_chart_done_link">',amb_i18n.DONE,'</a></br><a class="pwx_result_link" id="pwx_task_chart_done_dt_tm_link">',amb_i18n.DONE_WITH_DATE_TIME,'</a></br><a class="pwx_result_link" id="pwx_task_chart_not_done_link2">',amb_i18n.NOT_DONE,'</a></div>');
		var pwx_row_color = ''
        var row_cnt = 0;
        var pagin_active = 0;
        var end_of_task_list = 0;
        json_task_start_number = json_task_end_number;
        if (task_list_curpage > json_task_page_start_numbersAr.length) {
            json_task_page_start_numbersAr.push(json_task_start_number)
        }
        for (var i = json_task_end_number; i < pwxdata.TLIST.length; i++) {
            //do the filtering
            var status_match = 0
            for (var cc = 0; cc < pwx_global_statusArr.length; cc++) {
                if (pwx_global_statusArr[cc] == pwxdata.TLIST[i].TASK_STATUS) {
                    status_match = 1;
                    break;
                }
            }
            var type_match = 0
            for (var cc = 0; cc < pwx_global_typeArr.length; cc++) {
                if (pwx_global_typeArr[cc] == pwxdata.TLIST[i].TASK_TYPE) {
                    type_match = 1;
                    break;
                }
            }
            var orderprov_match = 0
            for (var cc = 0; cc < pwx_global_orderprovArr.length; cc++) {
                if (pwxdata.TLIST[i].ORDERING_PROVIDER.indexOf(pwx_global_orderprovArr[cc]) != -1) {
                    orderprov_match = 1;
                    break;
                }
            }
            var task_row_visable = '';
            var task_row_zebra_type = '';
            if (status_match == 1 && type_match == 1 && orderprov_match == 1) {
                if (pwx_isOdd(row_cnt) == 1) {
                    task_row_zebra_type = " pwx_zebra_dark "
                }
                else {
                    task_row_zebra_type = " pwx_zebra_light "
                }
                row_cnt++
                /*
                if (pwxdata.TLIST[i].TASK_OVERDUE == 1 && pwxdata.TLIST[i].TASK_STATUS == 'Active') {
                var overdue_icon = '<span class="pwx-highprio-icon">&nbsp;</span>';
                }
                else {
                var overdue_icon = '';
                }
                */
                if (pwxdata.TLIST[i].TASK_STATUS == 'Discontinued' || pwxdata.TLIST[i].CAN_CHART_IND == 0) {
                    var grey_text = ' pwx_grey ';
                }
                else if (pwxdata.TLIST[i].TASK_TYPE_IND == 3 && pwxdata.TLIST[i].TASK_STATUS == 'Complete' && pwxdata.TLIST[i].NOT_DONE > 0) {
                    var grey_text = ' pwx_grey ';
                }
                else {
                    var grey_text = '';
                }
                pwxcontentHTML.push('<dl class="pwx_content_row', grey_text, task_row_zebra_type, '">');
                pwxcontentHTML.push('<dt class="pwx_fcr_content_status_dt">', pwxdata.TLIST[i].TASK_STATUS, '</dt>');
                pwxcontentHTML.push('<dt class="pwx_person_id_hidden">', pwxdata.TLIST[i].PERSON_ID, '</dt>');
                pwxcontentHTML.push('<dt class="pwx_encounter_id_hidden">', pwxdata.TLIST[i].ENCOUNTER_ID, '</dt>');
		pwxcontentHTML.push('<dt class="pwx_person_name_hidden">', pwxdata.TLIST[i].PERSON_NAME, '</dt>');
                pwxcontentHTML.push('<dt class="pwx_task_type_ind_hidden">', pwxdata.TLIST[i].TASK_TYPE_IND, '</dt>');
                pwxcontentHTML.push('<dt class="pwx_task_order_id_hidden">', pwxdata.TLIST[i].ORDER_ID, '</dt>');
                pwxcontentHTML.push('<dt class="pwx_task_resched_time_hidden">', pwxdata.TLIST[i].TASK_RESCHED_TIME, '</dt>');
                pwxcontentHTML.push('<dt class="pwx_task_comment_hidden">', pwxdata.TLIST[i].TASK_NOTE, '</dt>');
                pwxcontentHTML.push('<dt class="pwx_task_lab_notchart_hidden">', pwxdata.TLIST[i].NOT_DONE, '</dt>');
                pwxcontentHTML.push('<dt class="pwx_task_canchart_hidden">', pwxdata.TLIST[i].CAN_CHART_IND, '</dt>');
                pwxcontentHTML.push('<dt class="pwx_fcr_content_type_icon_dt"><div class="pwx_fcr_content_action_bar">&nbsp;</div>');
                if (pwxdata.TLIST[i].TASK_STATUS == 'Active') {
                    if (pwxdata.TLIST[i].TASK_TYPE_IND > 0) {
                        var taskmenuClass = 'pwx_task_need_chart_menu';
                    }
                    else {
                        var taskmenuClass = 'pwx_task_need_chart_done_menu';
                    }
                    if (pwxdata.TLIST[i].CAN_CHART_IND == 1) {
                        var taskmenuIcon = '<span class="pwx-icon_submenu_arrow-icon ' + taskmenuClass + ' ">&nbsp;</span>';
                        if (pwxdata.TLIST[i].TASK_TYPE_IND == 1) {
                            pwxcontentHTML.push('<span class="pwx-med_task-icon pwx_pointer_cursor" title="',amb_i18n.CHART_DONE,'">&nbsp;</span>', taskmenuIcon);
                        }
                        else if (pwxdata.TLIST[i].TASK_TYPE_IND == 2) {
                            pwxcontentHTML.push('<span class="pwx-form_task-icon pwx_pointer_cursor" title="',amb_i18n.CHART_DONE,'">&nbsp;</span>', taskmenuIcon);
                        }
                        else if (pwxdata.TLIST[i].TASK_TYPE_IND == 3) {
                            pwxcontentHTML.push('<span class="pwx-lab_task-icon pwx_pointer_cursor" title="',amb_i18n.CHART_DONE,'">&nbsp;</span>', taskmenuIcon);
                        }
                        else {
                            pwxcontentHTML.push('<span class="pwx-clip_task-icon pwx_pointer_cursor" title="',amb_i18n.CHART_DONE,'">&nbsp;</span>', taskmenuIcon);
                        }
                    }
                    else {
                        pwxcontentHTML.push('<span class="pwx-task_disabled-icon" title="',amb_i18n.TASK_NOT_AVAIL,'">&nbsp;</span>');
                    }
                }
                else if (pwxdata.TLIST[i].TASK_STATUS == 'Complete') {
                    var completeicon = '<span class="pwx-completed_grey-icon" title="' + amb_i18n.TASK_DONE + '"></span>';
                    if (pwxdata.TLIST[i].NOT_DONE > 0) {
                        completeicon = '<span class="pwx-complet_not_done_grey-icon" title="' + amb_i18n.TASK_NOT_DONE + '"></span>';
                    }
                    pwxcontentHTML.push(completeicon);
                }
                else if (pwxdata.TLIST[i].TASK_STATUS == 'Discontinued') {
                    pwxcontentHTML.push('<span class="pwx-cancelcircle_grey-icon" title="',amb_i18n.TASK_DISCONTINUED,'"></span>');
                }
                pwxcontentHTML.push('</dt>');
                //build the task column now to see if more that one line
                var task_colHTML = [];
                //add italic class if inprocess;
                if (pwxdata.TLIST[i].INPROCESS_IND == 1) { var italicClass = 'pwx_italic'; var italicTitle = 'title="' + amb_i18n.TASK_IN_PROCESS + '"' } else { var italicClass = ''; var italicTitle = '' }
                //display based on if task is lab or anything else
                if (pwxdata.TLIST[i].TASK_TYPE_IND == 3) {
                    task_colHTML.push('<dt class="pwx_fcr_content_task_dt ' + italicClass + '" ' + italicTitle + '><span class="pwx_fcr_content_type_ordname_dt">', pwxdata.TLIST[i].TASK_DISPLAY);
                    if (pwxdata.TLIST[i].POWERPLAN_IND > 0) {
                        task_colHTML.push('&nbsp;&nbsp;&nbsp;<span class="pwx-powerplan-icon"></span>');
                    }
                    task_colHTML.push('</span><span class="pwx_grey pwx_fcr_content_type_ascname_dt">', pwxdata.TLIST[i].ASC_NUM, '</span><span class="pwx_fcr_content_type_detail_icon_dt" title="',amb_i18n.VIEW_TASK_DETAILS,'"><span class="pwx_task_json_index_hidden">', i, '</span><span class="ui-icon ui-icon-carat-1-e"></span></span>');
                    var task_row_lines = '';
                    var task_id_collect = '';
                    for (var cc = 0; cc < pwxdata.TLIST[i].CONTAIN_LIST.length; cc++) {
                        task_colHTML.push('<div class="pwx_task_lab_container_hidden">');
                        task_colHTML.push('<span class="pwx_task_lab_line_text_hidden">', pwxdata.TLIST[i].CONTAIN_LIST[cc].CONTAIN_SENT, '</span>');
                        task_colHTML.push('<span class="pwx_task_lab_taskid_hidden">', pwxdata.TLIST[i].CONTAIN_LIST[cc].TASK_ID, '</span>');
                        task_colHTML.push('</div>');
                        task_colHTML.push('<div class="pwx_leftpad_20 pwx_grey pwx_lab_container_line_div">', pwxdata.TLIST[i].CONTAIN_LIST[cc].CONTAIN_SENT, '</div>');
                        task_row_lines += '<br />&nbsp;';
                        if (cc == 0) {
                            task_id_collect += pwxdata.TLIST[i].CONTAIN_LIST[cc].TASK_ID;
                        }
                        else {
                            task_id_collect += "," + pwxdata.TLIST[i].CONTAIN_LIST[cc].TASK_ID;
                        }
                    }
                    task_colHTML.push('</dt><span class="pwx_task_id_hidden">', task_id_collect, '</span>');
                }
                else {
                    task_colHTML.push('<dt class="pwx_fcr_content_task_dt  ' + italicClass + '" ' + italicTitle + '><span class="pwx_fcr_content_type_name_dt">', pwxdata.TLIST[i].TASK_DISPLAY);
                    if (pwxdata.TLIST[i].ORD_COMMENT != "--") {
                        task_colHTML.push('<span class="pwx-small-comment-icon" title="',amb_i18n.ORDER_COMM_DETECT,'">&nbsp;</span>');
                    }
                    else if (pwxdata.TLIST[i].TASK_NOTE != "--") {
                        task_colHTML.push('<span class="pwx-small-comment-icon" title="',amb_i18n.TASK_COMM_DETECT,'">&nbsp;</span>');
                    }
                    if (pwxdata.TLIST[i].POWERPLAN_IND > 0) {
                        task_colHTML.push('&nbsp;&nbsp;&nbsp;<span class="pwx-powerplan-icon">&nbsp;</span>');
                    }
                    if (pwxdata.TLIST[i].ORDER_CDL != "--") {
                        task_colHTML.push('&nbsp;<span class="pwx_grey pwx_extra_small_text">', pwxdata.TLIST[i].ORDER_CDL, '</span>');
                    }
                    task_colHTML.push('</span><span class="pwx_fcr_content_type_detail_icon_dt" title="',amb_i18n.VIEW_TASK_DETAILS,'"><span class="pwx_task_json_index_hidden">', i, '</span><span class="ui-icon ui-icon-carat-1-e"></span></span>',
                '</dt><span class="pwx_task_id_hidden">', pwxdata.TLIST[i].TASK_ID, '</span>');
                    var task_row_lines = '';
                }
                //display pt and visit date column
                pwxcontentHTML.push('<dt class="pwx_fcr_content_person_dt"><span class="pwx_fcr_content_type_personname_dt"><a title="',amb_i18n.OPEN_PT_CHART,'" class="pwx_result_link_bold">',
                pwxdata.TLIST[i].PERSON_NAME, '</a><span class="pwx_grey pwx_extra_small_text">&nbsp;&nbsp;', pwxdata.TLIST[i].AGE, ' ', pwxdata.TLIST[i].GENDER_CHAR, '</span></span>');
                pwxcontentHTML.push('<span class="pwx_fcr_content_type_person_icon_dt" title="',amb_i18n.VIEW_PT_DETAILS,'"><span class="pwx_task_json_index_hidden">', i, '</span><span class="pwx-line_menu-icon"></span></span>');
                if (task_row_lines == '<br />&nbsp;') { var lineheightVar = 17 } else { var lineheightVar = 16 };
                pwxcontentHTML.push('<span style="line-height:' + lineheightVar + 'px;">', task_row_lines, '</span></dt>');
				if(pwxdata.TLIST[i].VISIT_DT_UTC != "" && pwxdata.TLIST[i].VISIT_DT_UTC != "TZ") {
					var visitUTCDate = new Date();
					visitUTCDate.setISO8601(pwxdata.TLIST[i].VISIT_DT_UTC);
					pwxcontentHTML.push('<dt class="pwx_fcr_content_visitdate_dt">', visitUTCDate.format("shortDate3"), task_row_lines, '</dt>');
				} else {
					pwxcontentHTML.push('<dt class="pwx_fcr_content_visitdate_dt">--', task_row_lines, '</dt>');
				}
                //insert the task column here
                pwxcontentHTML.push(task_colHTML.join(""));
                if (pwxdata.TLIST[i].TASK_PRN_IND == 1) {
                    pwxcontentHTML.push('<dt class="pwx_fcr_content_schdate_dt" style="padding-bottom:2px;">PRN', task_row_lines, '</dt>');
                }
                else {
					//Shaun UTC Change
                    //pwxcontentHTML.push('<dt class="pwx_fcr_content_schdate_dt"><span style="padding-bottom:2px;">', pwxdata.TLIST[i].TASK_DATE, ' ', pwxdata.TLIST[i].TASK_TIME, ' ', task_row_lines, '</span></dt>');
					if(pwxdata.TLIST[i].TASK_DT_TM_UTC != "" && pwxdata.TLIST[i].TASK_DT_TM_UTC != "TZ") {
						var taskUTCDate = new Date();
						taskUTCDate.setISO8601(pwxdata.TLIST[i].TASK_DT_TM_UTC);
						pwxcontentHTML.push('<dt class="pwx_fcr_content_schdate_dt"><span style="padding-bottom:2px;">', taskUTCDate.format("longDateTime4"), ' ', task_row_lines, '</span></dt>');
					} else {
						pwxcontentHTML.push('<dt class="pwx_fcr_content_schdate_dt"><span style="padding-bottom:2px;">-- ', task_row_lines, '</span></dt>');
					}
                }
                pwxcontentHTML.push('<dt class="pwx_fcr_content_orderby_dt pwx_grey">', pwxdata.TLIST[i].ORDERING_PROVIDER, task_row_lines, '</dt>');
                //if abn add this here
                var abnDT = ""
                var abnmodStyle = ""
                if (pwxdata.TLIST[i].ABN_LIST.length > 0) {
                    abnDT = '<dt class="pwx_fcr_content_task_abn_dt" title="' + amb_i18n.ABN_TOOLTIP + '"><span style="display:none" class="pwx_abn_track_id_hidden">' + pwxdata.TLIST[i].ABN_TRACK_IDS + '</span><span style="display:none" class="pwx_abn_json_id_hidden">' + i + '</span><span class="pwx-abn-icon"></span></dt>';
                    abnmodStyle = 'style="max-width:7.5%;"'
                }

                pwxcontentHTML.push('<dt class="pwx_fcr_content_type_dt pwx_grey" ' + abnmodStyle + '>', pwxdata.TLIST[i].TASK_TYPE, '</dt>', abnDT);

                pwxcontentHTML.push('</dl>');
            }
            if (i + 1 == pwxdata.TLIST.length) {
                end_of_task_list = 1;
            }
            if (row_cnt == 100) {
                json_task_end_number = i + 1; //add one to start on next one not displayed
                pagin_active = 1;
                break;
            }
        }
        if (row_cnt == 0) {
            pwxcontentHTML.push('<dl class="pwx_content_noresfilter_row"><span class="pwx_noresult_text">',amb_i18n.SELECTED_FILTERS_NO_TASKS,'</span></dl>');
        }
    }
    else {
        pwxcontentHTML.push('<div id="pwx_frame_content_rows_header"></div><div id="pwx_frame_content_rows"><dl class="pwx_content_nores_row"><span class="pwx_noresult_text">',amb_i18n.NO_RESULTS,'</span></dl>');
    }
    pwxcontentHTML.push('</div>');
    framecontentElem.html(pwxcontentHTML.join(""))
    var end_content_timer = new Date();
    var start_event_timer = new Date();
    $('#pwx_list_total_count').html('<span class="pwx_grey">' + pwxdata.TLIST.length + ' ' + amb_i18n.TOTAL_ITEMS + '</span>')
    $('#pwx_fcr_header_schdate_dt').on('click', function () {
        pwx_task_sort(pwxdata, 'pwx_fcr_header_schdate_dt')
    });
    $('#pwx_fcr_header_orderby_dt').on('click', function () {
        pwx_task_sort(pwxdata, 'pwx_fcr_header_orderby_dt')
    });
    $('#pwx_fcr_header_task_dt').on('click', function () {
        pwx_task_sort(pwxdata, 'pwx_fcr_header_task_dt')
    });
    $('#pwx_fcr_header_personname_dt').on('click', function () {
        pwx_task_sort(pwxdata, 'pwx_fcr_header_personname_dt')
    });
    $('#pwx_fcr_header_visitdate_dt').on('click', function () {
        pwx_task_sort(pwxdata, 'pwx_fcr_header_visitdate_dt')
    });
    $('#pwx_fcr_header_type_dt').on('click', function () {
        pwx_task_sort(pwxdata, 'pwx_fcr_header_type_dt')
    });
    $('#pwx_task_pagingbar_cur_page').text(amb_i18n.PAGE + ': ' + task_list_curpage)
    //setup next paging button
    if (pagin_active == 1 && end_of_task_list != 1) {
        $('#pwx_task_filterbar_page_next').html('<span class="pwx-nextpage-icon"></span>')
        $('#pwx_task_filterbar_page_next').on('click', function () {
            framecontentElem.empty();
            framecontentElem.html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
            start_pwx_timer()
            start_page_load_timer = new Date();
            window.scrollTo(0, 0);
            task_list_curpage++
            RenderTaskListContent(pwxdata);
        });
    }
    else {
        $('#pwx_task_filterbar_page_next').html('<span class="pwx-nextpage_grey-icon"></span>')
    }
    //setup prev paging button
    if (json_task_start_number > 0) {
        $('#pwx_task_filterbar_page_prev').html('<span class="pwx-prevpage-icon"></span>')
        $('#pwx_task_filterbar_page_prev').on('click', function () {
            task_list_curpage--
            json_task_end_number = json_task_page_start_numbersAr[task_list_curpage - 1]
            framecontentElem.empty();
            framecontentElem.html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
            start_pwx_timer()
            start_page_load_timer = new Date();
            window.scrollTo(0, 0);
            RenderTaskListContent(pwxdata);
        });
    }
    else {
        $('#pwx_task_filterbar_page_prev').html('<span class="pwx-prevpage_grey-icon"></span>')
    }
    if (json_task_start_number > 0 || (pagin_active == 1 && end_of_task_list != 1)) {
        $('#pwx_frame_paging_bar_container').css('display', 'inline-block')
    }
    else {
        $('#pwx_frame_paging_bar_container').css('display', 'none')
    }

    $('span.pwx_fcr_content_type_name_dt, span.pwx_fcr_content_type_ordname_dt, dt.pwx_fcr_content_orderby_dt').each(function (index) {
        if (this.clientWidth < this.scrollWidth) {
            var titleText = $(this).text()
            $(this).attr("title", titleText)
        }
    });
    //single click menus
    $('#pwx_task_chart_done_menu').on('mouseleave', function (event) {
        $(this).css('display', 'none');
    });
    $('#pwx_task_chart_menu').on('mouseleave', function (event) {
        $(this).css('display', 'none');
    });
    $('#pwx_task_chart_link').on('click', function (e) {
        var taskSuccess = pwx_task_launch(pwx_task_submenu_clicked_person_id, pwx_task_submenu_clicked_task_id, 'CHART');
        if (taskSuccess == true) {
            $(pwx_task_submenu_clicked_row_elem).each(function (index) {
                var dlHeight = $(this).height()
                $(this).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#87C854').css('height', dlHeight).attr("title", amb_i18n.CHARTED_DONE_REFRESH)
            });
            if (pwx_task_submenu_clicked_task_type_ind == 3) {
                if (pwxdata.LABEL_PRINT_AUTO_OFF != "1") {
                    if (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0) {
                        var taskSuccess = pwx_task_label_print_launch(pwx_task_submenu_clicked_person_id, pwx_task_submenu_clicked_task_id);
                    }
                    else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRA") {
                        var orderIdlist = pwx_task_submenu_clicked_order_id
                        var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                        window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRA_LABEL','" + ccllinkparams + "',0)";
                    }
                    else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRASMALL") {
                        var orderIdlist = pwx_task_submenu_clicked_order_id
                        var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                        window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRASMALL','" + ccllinkparams + "',0)";
                    }
                    else {
                        var orderIdlist = pwx_task_submenu_clicked_order_id
                        var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                        window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_DYMO_LABEL','" + ccllinkparams + "',0)";
                    }
                }
                if (pwxdata.AUTOLOG_SPEC_IND == 1) { setTimeout(function () { PWX_CCL_Request_Specimen_Login("amb_cust_call_spec_auto_loc", pwx_task_submenu_clicked_task_id, true) }, 1000); }
            }
        }
        $('#pwx_task_chart_menu').css('display', 'none');
    });
    $('#pwx_task_chart_done_link').on('click', function (e) {
        var taskSuccess = pwx_task_launch(pwx_task_submenu_clicked_person_id, pwx_task_submenu_clicked_task_id, 'CHART_DONE');
        if (taskSuccess == true) {
            $(pwx_task_submenu_clicked_row_elem).each(function (index) {
                var dlHeight = $(this).height()
                $(this).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#87C854').css('height', dlHeight).attr("title", amb_i18n.CHARTED_DONE_REFRESH)
            });
        }
        $('#pwx_task_chart_done_menu').css('display', 'none');
    });
    $('#pwx_task_chart_done_dt_tm_link').on('click', function (e) {
        var taskSuccess = pwx_task_launch(pwx_task_submenu_clicked_person_id, pwx_task_submenu_clicked_task_id, 'CHART_DONE_DT_TM');
        if (taskSuccess == true) {
            $(pwx_task_submenu_clicked_row_elem).each(function (index) {
                var dlHeight = $(this).height()
                $(this).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#87C854').css('height', dlHeight).attr("title", amb_i18n.CHARTED_DONE_REFRESH)
            });
        }
        $('#pwx_task_chart_done_menu').css('display', 'none');
    });
    $('#pwx_task_chart_not_done_link, #pwx_task_chart_not_done_link2').on('click', function (e) {
        var taskSuccess = pwx_task_launch(pwx_task_submenu_clicked_person_id, pwx_task_submenu_clicked_task_id, 'CHART_NOT_DONE');
        if (taskSuccess == true) {
            $(pwx_task_submenu_clicked_row_elem).each(function (index) {
                var dlHeight = $(this).height()
                $(this).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#DF5E3E').css('height', dlHeight).attr("title", amb_i18n.CHARTED_NOT_DONE_REFRESH)
            });
        }
        $('#pwx_task_chart_menu').css('display', 'none');
        $('#pwx_task_chart_done_menu').css('display', 'none');
    });
    //person menu
    $.contextMenu({
        selector: 'span.pwx_fcr_content_type_person_icon_dt',
        trigger: 'left',
        zIndex: '9999',
        className: 'ui-widget',
        build: function ($trigger, e) {
            $($trigger).parents('dl.pwx_content_row').addClass('pwx_row_selected')
            json_index = $($trigger).children('span.pwx_task_json_index_hidden').text()
            var options = {
                items: {
                    "Visit Summary (Depart)": { "name": pwxdata.DEPART_LABEL, callback: function (key, opt) {
                        var dpObject = new Object();
                        dpObject = window.external.DiscernObjectFactory("DISCHARGEPROCESS");
                        dpObject.person_id = pwxdata.TLIST[json_index].PERSON_ID;
                        dpObject.encounter_id = pwxdata.TLIST[json_index].ENCOUNTER_ID;
                        dpObject.user_id = js_criterion.CRITERION.PRSNL_ID;
                        dpObject.LaunchDischargeDialog();
                    }
                    },
                    "fold1": {
                        "name": amb_i18n.CHART_FORMS,
                        "items": {},
                        disabled: false
                    },
                    "Patient Snapshot": { "name": amb_i18n.PATIENT_SNAPSHOT, callback: function (key, opt) {
                        PWX_CCL_Request_Person_Details("amb_cust_person_details_diag", pwxdata.TLIST[json_index].PERSON_ID, pwxdata.TLIST[json_index].ENCOUNTER_ID, false)
                    }
                    },
                    "sep5": "---------",
                    "fold3": {
                        "name": amb_i18n.OPEN_PT_CHART,
                        "items": {},
                        disabled: false
                    }
                }
            };

            if (pwxdata.FORMSLIST.length > 0) {
                for (var cc in pwxdata.FORMSLIST) {
                    options.items["fold1"].items[cc + "|forms"] = { "name": pwxdata.FORMSLIST[cc].FORM_NAME, callback: function (key, opt) { var keyArr = key.split("|"); pwx_form_launch(pwxdata.TLIST[json_index].PERSON_ID, pwxdata.TLIST[json_index].ENCOUNTER_ID, pwxdata.FORMSLIST[keyArr[0]].FORM_ID, 0.0, 0); } }
                }
                options.items["fold1"].items["Forms Menu"] = { "name": amb_i18n.ALL_FORMS, "className": "pwx_link_blue", callback: function (key, opt) { pwx_form_launch(pwxdata.TLIST[json_index].PERSON_ID, pwxdata.TLIST[json_index].ENCOUNTER_ID, 0.0, 0.0, 0); } }
            }
            else {
                options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
            }
            if (pwxdata.ALLOW_DEPART == 0) {
                options.items["Visit Summary (Depart)"] = { "name": pwxdata.DEPART_LABEL, disabled: function (key, opt) { return true; } };
            }
            if (js_criterion.CRITERION.VPREF.length > 0) {
                for (var cc in js_criterion.CRITERION.VPREF) {
                    options.items["fold3"].items[cc] = { "name": js_criterion.CRITERION.VPREF[cc].VIEW_CAPTION, callback: function (key, opt) {
                        var parameter_person_launch = '/PERSONID=' + pwxdata.TLIST[json_index].PERSON_ID + ' /ENCNTRID=' + pwxdata.TLIST[json_index].ENCOUNTER_ID + ' /FIRSTTAB=^' + js_criterion.CRITERION.VPREF[key].VIEW_CAPTION + '^'
                        APPLINK(0, "$APP_APPNAME$", parameter_person_launch)
                    }
                    };
                }
            }
            else {
                options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
            }
            return options;
        }
    });
    //task detail
    framecontentElem.on('click', 'span.pwx_fcr_content_type_detail_icon_dt', function (e) {
        $(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected').addClass('pwx_row_selected');
        var json_index = $(this).children('span.pwx_task_json_index_hidden').text()
        var task_detailText = [];
        task_detailText.push('<div class="pwx_modal_person_banner"><span class="pwx_modal_person_banner_name">', pwxdata.TLIST[json_index].PERSON_NAME, '</span>')
        task_detailText.push('<span class="pwx_modal_person_banner_details">',amb_i18n.DOB,':&nbsp;', pwxdata.TLIST[json_index].DOB, '</span>')
        task_detailText.push('<span class="pwx_modal_person_banner_details">',amb_i18n.AGE,':&nbsp;', pwxdata.TLIST[json_index].AGE, '</span>')
        task_detailText.push('<span class="pwx_modal_person_banner_details">',amb_i18n.GENDER,':&nbsp;', pwxdata.TLIST[json_index].GENDER, '</span>')
        task_detailText.push('</div></br></br>')
        if (pwxdata.TLIST[json_index].TASK_STATUS == 'Complete') {
            task_detailText.push('<dl class="pwx_task_detail_line"><dt>');
            if (pwxdata.TLIST[json_index].NOT_DONE > 0) {
                task_detailText.push('<span class="pwx-complet_not_done-icon"></span>',amb_i18n.NOT_DONE,':');
				var reasonCD = ""
				if(pwxdata.TLIST[json_index].NOT_DONE_REASON != "") {
					reasonCD = '<dl class="pwx_task_detail_line"><dt>' + amb_i18n.REASON + ':</dt><dd>' + pwxdata.TLIST[json_index].NOT_DONE_REASON + '</dd></dl>';
					if(pwxdata.TLIST[json_index].NOT_DONE_REASON_COMM != "") {
						reasonCD += '<dl class="pwx_task_detail_line"><dt>' + amb_i18n.REASON_COMM + ':</dt><dd>' + pwxdata.TLIST[json_index].NOT_DONE_REASON_COMM + '</dd></dl>';
					}
				}
            }
            else {
                task_detailText.push('<span class="pwx-completed-icon"></span>',amb_i18n.DONE,':');
				var reasonCD = ""
            }
			if(pwxdata.TLIST[json_index].CHARTED_DT_UTC != "" && pwxdata.TLIST[json_index].CHARTED_DT_UTC != "TZ") {
				var chartedUTCDate = new Date();
				chartedUTCDate.setISO8601(pwxdata.TLIST[json_index].CHARTED_DT_UTC);
				task_detailText.push('<span style="color:black;padding-left:5px;">', pwxdata.TLIST[json_index].CHARTED_BY, ' ',amb_i18n.ON,' ', chartedUTCDate.format("longDateTime4"), '</span></dt><dd>&nbsp</dd></dl>',
				reasonCD,'<dl class="pwx_task_detail_line"><div class="pwx_sub_sub-sec-hd">&nbsp;</div></dl>');
			} else {
			    task_detailText.push('<span style="color:black;padding-left:5px;">', pwxdata.TLIST[json_index].CHARTED_BY, ' ',amb_i18n.ON,' --</span></dt><dd>&nbsp</dd></dl>',
				reasonCD,'<dl class="pwx_task_detail_line"><div class="pwx_sub_sub-sec-hd">&nbsp;</div></dl>');
			}
        }
        if (pwxdata.TLIST[json_index].TASK_TYPE_IND == 3) {
            task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.ORDERED_AS,' (', pwxdata.TLIST[json_index].ORDER_CNT, '):</dt><dd>', pwxdata.TLIST[json_index].ORDERED_AS_NAME, '</dd></dl>');
            task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.ACCESSION_NUM,':</dt><dd>', pwxdata.TLIST[json_index].ASC_NUM, '</dd></dl>');
			if(pwxdata.TLIST[json_index].TASK_DT_TM_UTC != "" && pwxdata.TLIST[json_index].TASK_DT_TM_UTC != "TZ") {
				var taskUTCDate = new Date();
				taskUTCDate.setISO8601(pwxdata.TLIST[json_index].TASK_DT_TM_UTC);
				task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.TASK_DATE,':</dt><dd>', taskUTCDate.format("longDateTime4"), '</dd></dl>');
			} else {
				task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.TASK_DATE,':</dt><dd>--</dd></dl>');
			}
            task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.STATUS,':</dt><dd>', pwxdata.TLIST[json_index].DISPLAY_STATUS, '</dd></dl>');
            task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.TYPE,':</dt><dd>', pwxdata.TLIST[json_index].TASK_TYPE, '</dd></dl>');
			if(pwxdata.TLIST[json_index].VISIT_DT_UTC != "" && pwxdata.TLIST[json_index].VISIT_DT_UTC != "TZ") {
				var visitUTCDate = new Date();
				visitUTCDate.setISO8601(pwxdata.TLIST[json_index].VISIT_DT_UTC);
				task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.VISIT_DATE_LOC,':</dt><dd>', visitUTCDate.format("shortDate3"), ' | ', pwxdata.TLIST[json_index].VISIT_LOC, '</dd></dl>');
			} else {
				task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.VISIT_DATE_LOC,':</dt><dd>-- | ', pwxdata.TLIST[json_index].VISIT_LOC, '</dd></dl>');
			}
            for (var y = 0; y < pwxdata.TLIST[json_index].OLIST.length; y++) {
                task_detailText.push('<dl class="pwx_task_detail_line" style="padding-top:5px;"><dt class="pwx_no_wrap"><span class="pwx_order_info_title"><span class="pwx_semi_bold">',amb_i18n.ORDER,' ', (y + 1), ':</span>&nbsp;', pwxdata.TLIST[json_index].OLIST[y].ORDER_NAME, '</span></dt><div class="pwx_sub_sub-sec-hd">&nbsp;</div></dl>');
                if (pwxdata.TLIST[json_index].POWERPLAN_IND == 1) {
                    task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDER_PLAN,':</dt><dd>', pwxdata.TLIST[json_index].POWERPLAN_NAME, '</dd></dl>');
                }
				if(pwxdata.TLIST[json_index].ORDER_DT_TM_UTC != "" && pwxdata.TLIST[json_index].ORDER_DT_TM_UTC != "TZ") {
					var orderUTCDate = new Date();
					orderUTCDate.setISO8601(pwxdata.TLIST[json_index].ORDER_DT_TM_UTC);
					task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDERED_DATE,':</dt><dd>', orderUTCDate.format("longDateTime4"), '</dd></dl>');
				} else {
					task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDERED_DATE,':</dt><dd>--</dd></dl>');
				}
                task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDERING_PROV,':</dt><dd>', pwxdata.TLIST[json_index].OLIST[y].ORDERING_PROV, '</dd></dl>');
                task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDER_ID,':</dt><dd>', pwxdata.TLIST[json_index].OLIST[y].ORDER_ID, '</dd></dl>');
                task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.DIAGNOSIS,' (', pwxdata.TLIST[json_index].OLIST[y].DLIST.length, '):</dt>');
                if (pwxdata.TLIST[json_index].OLIST[y].DLIST.length > 0) {
                    task_detailText.push('</dl>');
                    task_detailText.push('<dl class="pwx_task_detail_line"><dt>&nbsp;</dt><dd class="pwx_normal_line_height pwx_extra_small_text pwx_hvr_order_info_diag_pad">');
                    for (var cc = 0; cc < pwxdata.TLIST[json_index].OLIST[y].DLIST.length; cc++) {
                        if (cc > 0) {
                            task_detailText.push('<br />');
                        }
                        if (pwxdata.TLIST[json_index].OLIST[y].DLIST[cc].CODE != '') {
                            task_detailText.push(pwxdata.TLIST[json_index].OLIST[y].DLIST[cc].DIAG, '<span class="pwx_grey"> (', pwxdata.TLIST[json_index].OLIST[y].DLIST[cc].CODE, ')</span>');
                        }
                        else {
                            task_detailText.push(pwxdata.TLIST[json_index].OLIST[y].DLIST[cc].DIAG);
                        }
                    }
                    task_detailText.push('</dd></dl>');
                }
                else {
                    task_detailText.push('<dd>--</dd></dl>');
                }
            }
        }
        else {
            task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.TASK,':</dt><dd>', pwxdata.TLIST[json_index].TASK_DESCRIB, '</dd></dl>');
            task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.ORDERED_AS,':</dt><dd>', pwxdata.TLIST[json_index].ORDERED_AS_NAME, '</dd></dl>');
			if(pwxdata.TLIST[json_index].TASK_DT_TM_UTC != "" && pwxdata.TLIST[json_index].TASK_DT_TM_UTC != "TZ") {
				var taskUTCDate = new Date();
				taskUTCDate.setISO8601(pwxdata.TLIST[json_index].TASK_DT_TM_UTC);
				task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.TASK_DATE,':</dt><dd>', taskUTCDate.format("longDateTime4"), '</dd></dl>');
			} else {
				task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.TASK_DATE,':</dt><dd>--</dd></dl>');
			}
			var formLink = "";
			if (pwxdata.TLIST[json_index].DFAC_ACTIVITY_ID > 0) {
				formLink = '&nbsp;&nbsp;<a class="pwx_blue_link" onClick="pwx_form_launch(' +  pwxdata.TLIST[json_index].PERSON_ID + ',' + pwxdata.TLIST[json_index].ENCOUNTER_ID + ',0.0,' + pwxdata.TLIST[json_index].DFAC_ACTIVITY_ID + ',1)">' + amb_i18n.OPEN_CHARTED_FORM + '</a>';
			}
            task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.STATUS,':</dt><dd>', pwxdata.TLIST[json_index].DISPLAY_STATUS, formLink,'</dd></dl>');
            task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.TYPE,':</dt><dd>', pwxdata.TLIST[json_index].TASK_TYPE, '</dd></dl>');
            task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.TASK_COMMS,':</dt><dd>', pwxdata.TLIST[json_index].TASK_NOTE, '</dd></dl>');
			if(pwxdata.TLIST[json_index].VISIT_DT_UTC != "" && pwxdata.TLIST[json_index].VISIT_DT_UTC != "TZ") {
				var visitUTCDate = new Date();
				visitUTCDate.setISO8601(pwxdata.TLIST[json_index].VISIT_DT_UTC);
				task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.VISIT_DATE_LOC,':</dt><dd>', visitUTCDate.format("shortDate3"), ' | ', pwxdata.TLIST[json_index].VISIT_LOC, '</dd></dl>');
			} else {
				task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.VISIT_DATE_LOC,':</dt><dd>-- | ', pwxdata.TLIST[json_index].VISIT_LOC, '</dd></dl>');
			}
            task_detailText.push('<dl class="pwx_task_detail_line" style="padding-top:5px;"><dt class="pwx_no_wrap"><span class="pwx_order_info_title pwx_semi_bold">',amb_i18n.ORDER_INFO,'</span></dt><div class="pwx_sub_sub-sec-hd">&nbsp;</div></dl>');
            if (pwxdata.TLIST[json_index].POWERPLAN_IND == 1) {
                task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDER_PLAN,':</dt><dd>', pwxdata.TLIST[json_index].POWERPLAN_NAME, '</dd></dl>');
            }

			if(pwxdata.TLIST[json_index].ORDER_DT_TM_UTC != "" && pwxdata.TLIST[json_index].ORDER_DT_TM_UTC != "TZ") {
				var orderUTCDate = new Date();
				orderUTCDate.setISO8601(pwxdata.TLIST[json_index].ORDER_DT_TM_UTC);
				task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDERED_DATE,':</dt><dd>', orderUTCDate.format("longDateTime4"), '</dd></dl>');
			} else {
				task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDERED_DATE,':</dt><dd>--</dd></dl>');
			}
            task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDERING_PROV,':</dt><dd>', pwxdata.TLIST[json_index].ORDERING_PROVIDER, '</dd></dl>');
            task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDER_ID,':</dt><dd>', pwxdata.TLIST[json_index].ORDER_ID, '</dd></dl>');
            task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDER_DETAILS,':</dt><dd>', pwxdata.TLIST[json_index].ORDER_CDL, '</dd></dl>');
            task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDER_COMMS,':</dt><dd>', pwxdata.TLIST[json_index].ORD_COMMENT, '</dd></dl>');
            task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.DIAGNOSIS,' (', pwxdata.TLIST[json_index].DLIST.length, '):</dt>');
            if (pwxdata.TLIST[json_index].DLIST.length > 0) {
                task_detailText.push('</dl>');
                task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_diag_pad"><dd class="pwx_normal_line_height pwx_extra_small_text">');
                for (var cc = 0; cc < pwxdata.TLIST[json_index].DLIST.length; cc++) {
                    if (pwxdata.TLIST[json_index].DLIST[cc].CODE != '') {
                        task_detailText.push(pwxdata.TLIST[json_index].DLIST[cc].DIAG, '<span class="pwx_grey"> (', pwxdata.TLIST[json_index].DLIST[cc].CODE, ')</span><br />');
                    }
                    else {
                        task_detailText.push(pwxdata.TLIST[json_index].DLIST[cc].DIAG, '<br />');
                    }
                }
                task_detailText.push('</dd></dl>');
            }
            else {
                task_detailText.push('<dd>--</dd></dl>');
            }
        }
        MP_ModalDialog.deleteModalDialogObject("TaskDetailModal")
        var taskDetailModal = new ModalDialog("TaskDetailModal")
             .setHeaderTitle(amb_i18n.TASK_DETAILS)
             .setTopMarginPercentage(10)
             .setRightMarginPercentage(30)
             .setBottomMarginPercentage(10)
             .setLeftMarginPercentage(30)
             .setIsBodySizeFixed(true)
             .setHasGrayBackground(true)
             .setIsFooterAlwaysShown(true);
        taskDetailModal.setBodyDataFunction(
             function (modalObj) {
                 modalObj.setBodyHTML('<div class="pwx_task_detail">' + task_detailText.join("") + '</div>');
             });
        var closebtn = new ModalButton("addCancel");
        closebtn.setText(amb_i18n.CLOSE).setCloseOnClick(true);
        taskDetailModal.addFooterButton(closebtn)
        MP_ModalDialog.addModalDialogObject(taskDetailModal);
        MP_ModalDialog.showModalDialog("TaskDetailModal")
    });

    //ABN launch link
    framecontentElem.on('click', 'dt.pwx_fcr_content_task_abn_dt', function () {
        // show dialog
        var abnProgramName = '';
        var trackId = $(this).children('.pwx_abn_track_id_hidden').text()
        var jsonId = $(this).children('.pwx_abn_json_id_hidden').text()
        var abnHTML = '<p class="pwx_small_text hvr_table"><span style="vertical-align:30%;">' + amb_i18n.ABN_TEMPLATE + ': </span><select id="abn_programs" name="abn_programs" multiple="multiple">'
        for (var cc = 0; cc < pwxdata.ABN_FORM_LIST.length; cc++) {
            abnHTML += '<option value="' + pwxdata.ABN_FORM_LIST[cc].PROGRAM_NAME + '">' + pwxdata.ABN_FORM_LIST[cc].PROGRAM_DESC + '</option>';
        }
        abnHTML += '</select></br></br>';
        abnHTML += '<table width="95%" ><tr><th>' + amb_i18n.ORDER + '</th><th>' + amb_i18n.ALERT_DATE + '</th><th>' + amb_i18n.ALERT_STATE + '</th></tr>';
        for (var cc = 0; cc < pwxdata.TLIST[jsonId].ABN_LIST.length; cc++) {
            abnHTML += '<tr><td class="abn_order_mne">' + pwxdata.TLIST[jsonId].ABN_LIST[cc].ORDER_DISP + '</td><td class="abn_alert_date">' + pwxdata.TLIST[jsonId].ABN_LIST[cc].ALERT_DATE +
            '</td><td class="abn_alert_state">' + pwxdata.TLIST[jsonId].ABN_LIST[cc].ALERT_STATE + '</td></tr>';
        }
        abnHTML += '</table></p>';
        //build the drop down
        MP_ModalDialog.deleteModalDialogObject("ABNModal")
        var abnModal = new ModalDialog("ABNModal")
                                .setHeaderTitle(amb_i18n.ABN)
                                .setTopMarginPercentage(15)
                                .setRightMarginPercentage(25)
                                .setBottomMarginPercentage(15)
                                .setLeftMarginPercentage(25)
                                .setIsBodySizeFixed(true)
                                .setHasGrayBackground(true)
                                .setIsFooterAlwaysShown(true);
        abnModal.setBodyDataFunction(
                            function (modalObj) {
                                modalObj.setBodyHTML('<div style="padding-top:10px;">' + abnHTML + '</div>');
                            });
        var printbtn = new ModalButton("PrintABN");
        printbtn.setText(amb_i18n.VIEW).setCloseOnClick(true).setIsDithered(true).setOnClickFunction(function () {
            var ccllinkparams = '^MINE^,^' + trackId + '^,^' + abnProgramName + '^';
            window.location = "javascript:CCLLINK('amb_cust_abn_print_wrapper','" + ccllinkparams + "',0)";
        });
        var closebtn = new ModalButton("abnCancel");
        closebtn.setText(amb_i18n.CANCEL).setCloseOnClick(true);
        abnModal.addFooterButton(printbtn)
        abnModal.addFooterButton(closebtn)
        MP_ModalDialog.addModalDialogObject(abnModal);
        MP_ModalDialog.showModalDialog("ABNModal")
        $("#abn_programs").multiselect({
            //height: loc_height,
            header: false,
            multiple: false,
            //minWidth: "250",
            classes: "pwx_select_box",
            noneSelectedText: amb_i18n.ABN_SELECT,
            selectedList: 1
        });
        $("#abn_programs").on("multiselectclick", function (event, ui) {
            abnProgramName = ui.value
            abnModal.setFooterButtonDither("PrintABN", false);
        })
        $(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected').addClass('pwx_row_selected');
    })
    //adjust heights based on screen size
    var toolbarH = $('#pwx_frame_toolbar').height() + 6;
    $('#pwx_frame_filter_bar').css('top', toolbarH + 'px');
    var filterbarH = $('#pwx_frame_filter_bar').height() + toolbarH;
    $('#pwx_frame_content_rows_header').css('top', filterbarH + 'px');
	var contentrowsH = filterbarH + 19;
	$('#pwx_frame_content_rows').css('top', contentrowsH + 'px');
	window.scrollTo(0,0);
    //timers!!
    var end_event_timer = new Date();
    var end_page_load_timer = new Date();
    var event_timer = (end_event_timer - start_event_timer) / 1000
    var content_timer = (end_content_timer - start_content_timer) / 1000
    var program_timer = (end_page_load_timer - start_page_load_timer) / 1000
    stop_pwx_timer()
    //$('#pwx_frame_content_rows').append('<dl id="pwx_list_timers_row" class="pwx_extra_small_text"><dt>CCL Timer: ' + ccl_timer + ' Page Load Timer: ' + program_timer + '</dt></dl>')
}

function PWX_CCL_Request_User_Pref(program, param1, param2, param3, async) {
    var info = new XMLCclRequest();
    info.onreadystatechange = function () {
        if (info.readyState == 4 && info.status == 200) {
            var jsonEval = JSON.parse(this.responseText);
            var recordData = jsonEval.JSON_RETURN;
            if (recordData.STATUS_DATA.STATUS != "S") {
                var error_text = amb_i18n.STATUS + ": " + this.status + " " + amb_i18n.REQUEST_TEXT + ": " + this.requestText;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert">' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
        }
    };
    var sendArr = ["^MINE^", param1 + ".0", "^" + param2 + "^", "^" + param3 + "^"];
    info.open('GET', program, async);
    info.send(sendArr.join(","));
}

//function to call a ccl script to remove prsnl_reltns or encounter_reltns
function PWX_CCL_Request_Task_Unchart(program, param1, param2, param3, param4, async) {
    var info = new XMLCclRequest();
    info.onreadystatechange = function () {
        if (info.readyState == 4 && info.status == 200) {
            var jsonEval = JSON.parse(this.responseText);
            var recordData = jsonEval.JSON_RETURN;
            if (recordData.STATUS_DATA.STATUS != "S") {
                var error_text = amb_i18n.STATUS + ": " + this.status + " " + amb_i18n.REQUEST_TEXT + ": " + this.requestText;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert" >' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
            else {
                $('dl.pwx_row_selected').each(function (index) {
                    var dlHeight = $(this).height()
                    $(this).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#36A7DA').css('height', dlHeight).attr("title", amb_i18n.UNCHART_REFRESH)
                });
                $('dl.pwx_row_selected').removeClass('pwx_row_selected')
            }
        }
    };
    var sendArr = ["^MINE^", "^" + param1 + "^", param2 + ".0", "^" + param3 + "^", "^" + param4 + "^"];
    info.open('GET', program, async);
    info.send(sendArr.join(","));
}
function PWX_CCL_Request_Task_Add_Task_Note(program, param1, param2, async) {
    var info = new XMLCclRequest();
    info.onreadystatechange = function () {
        if (info.readyState == 4 && info.status == 200) {
            var jsonEval = JSON.parse(this.responseText);
            var recordData = jsonEval.JSON_RETURN;
            if (recordData.STATUS_DATA.STATUS != "S") {
                var error_text = amb_i18n.STATUS + ": " + this.status + " " + amb_i18n.REQUEST_TEXT + ": " + this.requestText;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert" >' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
            else {
                $('dl.pwx_row_selected').each(function (index) {
                    var dlHeight = $(this).height()
                    $(this).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#FFE366').css('height', dlHeight).attr("title", amb_i18n.TASK_COMM_REFRESH)
                });
                $('dl.pwx_row_selected').removeClass('pwx_row_selected')
            }
        }
    };
    var sendArr = ["^MINE^", param1 , "^" + param2 + "^"];
    info.open('GET', program, async);
    info.send(sendArr.join(","));
}
function PWX_CCL_Request_Task_Reschedule(program, param1, param2, param3, async) {
    var info = new XMLCclRequest();
    info.onreadystatechange = function () {
        if (info.readyState == 4 && info.status == 200) {
            var jsonEval = JSON.parse(this.responseText);
            var recordData = jsonEval.JSON_RETURN;
            if (recordData.STATUS_DATA.STATUS != "S") {
                var error_text = amb_i18n.STATUS + ": " + this.status + " " + amb_i18n.REQUEST_TEXT + ": " + this.requestText;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert">' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
            else {
                $('dl.pwx_row_selected').each(function (index) {
                    var dlHeight = $(this).height()
                    $(this).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#FF8C18').css('height', dlHeight).attr("title", amb_i18n.RESCHEDULE_REFRESH)
                });
                $('dl.pwx_row_selected').removeClass('pwx_row_selected')
            }
        }
    };
    var sendArr = ["^MINE^", "^" + param1 + "^", "^" + param2 + "^", "^" + param3 + "^"];
    info.open('GET', program, async);
    info.send(sendArr.join(","));
}
function PWX_CCL_Request_Specimen_Login(program, param1, async) {
    var info = new XMLCclRequest();
    info.onreadystatechange = function () {
        if (info.readyState == 4 && info.status == 200) {
            var jsonEval = JSON.parse(this.responseText);
            var recordData = jsonEval.JSON_RETURN;
            if (recordData.STATUS_DATA.STATUS == "L") {
                var error_text = amb_i18n.SPEC_LOGIN_ERROR;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert" >' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
            else if (recordData.STATUS_DATA.STATUS == "F") {
                var error_text = amb_i18n.STATUS + ": " + this.status + " " + amb_i18n.REQUEST_TEXT + ": " + this.requestText;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert" >' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
        }
    };
    var sendArr = ["^MINE^", "^" + param1 + "^"];
    info.open('GET', program, async);
    info.send(sendArr.join(","));
}

function PWX_CCL_Request_Person_Details(program, param1, param2, async) {
    var info = new XMLCclRequest();
    info.onreadystatechange = function () {
        if (info.readyState == 4 && info.status == 200) {
            var jsonEval = JSON.parse(this.responseText);
            var recordData = jsonEval.PATIENT_INFO;
            if (recordData.STATUS_DATA.STATUS != "S") {
                var error_text = amb_i18n.STATUS + ": " + this.status + " " + amb_i18n.REQUEST_TEXT + ": " + this.requestText;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert">' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
            else {
                pwx_open_person_details(recordData)
            }
        }
    };
    var sendArr = ["^MINE^", param1 + ".0", param2 + ".0"];
    info.open('GET', program, async);
    info.send(sendArr.join(","));
}

/*START OF REFERENCE LAB PAGE*/
function pwx_sort_by_order_date(a, b) {
    if (a.ORDER_DT_TM_NUM < b.ORDER_DT_TM_NUM)
        return -1
    if (a.ORDER_DT_TM_NUM > b.ORDER_DT_TM_NUM)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_by_trans_date(a, b) {
    if (a.TRANSFER_DT_TM_NUM < b.TRANSFER_DT_TM_NUM)
        return -1
    if (a.TRANSFER_DT_TM_NUM > b.TRANSFER_DT_TM_NUM)
        return 1
    return 0 //default return value (no sorting)
}

function pwx_sort_by_labname(a, b) {
    var nameA = a.ORDERED_AS_NAME.toLowerCase(), nameB = b.ORDERED_AS_NAME.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_by_subtype(a, b) {
    var nameA = a.ACTIVITY_SUB_TYPE.toLowerCase(), nameB = b.ACTIVITY_SUB_TYPE.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}
function pwx_sort_by_tolocation(a, b) {
    var nameA = a.TRANSFER_TO_LOC.toLowerCase(), nameB = b.TRANSFER_TO_LOC.toLowerCase()
    if (nameA < nameB) //sort string ascending
        return -1
    if (nameA > nameB)
        return 1
    return 0 //default return value (no sorting)
}

function pwx_trans_reflab_sort(pwxObj, clicked_header_id) {
    $('#pwx_frame_content').empty();
    $('#pwx_frame_content').html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
    start_pwx_timer()
    start_page_load_timer = new Date();
    json_reflab_start_number = 0;
    json_reflab_end_number = 0;
    json_reflab_page_start_numbersAr = [];
    reflab_list_curpage = 1;
    if (clicked_header_id == pwx_reflab_trans_header_id) {
        if (pwx_reflab_trans_sort_ind == '0') {
            var sort_ind = '1'
        }
        else {
            var sort_ind = '0'
        }
        pwxObj.TLIST.reverse()
        pwx_reflab_trans_header_id = clicked_header_id
        pwx_reflab_trans_sort_ind = sort_ind
        RenderRefLabListContent(pwxObj);
    }
    else {
        switch (clicked_header_id) {
            case 'pwx_fcr_trans_header_orderdate_dt':
                pwxObj.TLIST.sort(pwx_sort_by_order_date)
                pwx_reflab_trans_header_id = clicked_header_id
                pwx_reflab_trans_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
            case 'pwx_fcr_trans_header_tolocation_dt':
                pwxObj.TLIST.sort(pwx_sort_by_tolocation)
                pwx_reflab_trans_header_id = clicked_header_id
                pwx_reflab_trans_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
            case 'pwx_fcr_trans_header_labname_dt':
                pwxObj.TLIST.sort(pwx_sort_by_labname)
                pwx_reflab_trans_header_id = clicked_header_id
                pwx_reflab_trans_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
            case 'pwx_fcr_trans_header_transdate_dt':
                pwxObj.TLIST.sort(pwx_sort_by_trans_date)
                pwx_reflab_trans_header_id = clicked_header_id
                pwx_reflab_trans_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
            case 'pwx_fcr_header_personname_dt':
                pwxObj.TLIST.sort(pwx_sort_by_personname)
                pwx_reflab_trans_header_id = clicked_header_id
                pwx_reflab_trans_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
        }
    }
}
function pwx_reflab_col_sort(pwxObj, clicked_header_id) {
    $('#pwx_frame_content').empty();
    $('#pwx_frame_content').html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
    start_pwx_timer()
    start_page_load_timer = new Date();
    json_reflab_start_number = 0;
    json_reflab_end_number = 0;
    json_reflab_page_start_numbersAr = [];
    reflab_list_curpage = 1;
    if (clicked_header_id == pwx_reflab_coll_header_id) {
        if (pwx_reflab_coll_sort_ind == '0') {
            var sort_ind = '1'
        }
        else {
            var sort_ind = '0'
        }
        pwxObj.TLIST.reverse()
        pwx_reflab_coll_header_id = clicked_header_id
        pwx_reflab_coll_sort_ind = sort_ind
        RenderRefLabListContent(pwxObj);
    }
    else {
        switch (clicked_header_id) {
            case 'pwx_fcr_header_orderdate_dt':
                pwxObj.TLIST.sort(pwx_sort_by_task_date)
                pwx_reflab_coll_header_id = clicked_header_id
                pwx_reflab_coll_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
            case 'pwx_fcr_header_col_subtype_dt':
                pwxObj.TLIST.sort(pwx_sort_by_subtype)
                pwx_reflab_coll_header_id = clicked_header_id
                pwx_reflab_coll_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
            case 'pwx_fcr_header_col_labname_dt':
                pwxObj.TLIST.sort(pwx_sort_by_labname)
                pwx_reflab_coll_header_id = clicked_header_id
                pwx_reflab_coll_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
            case 'pwx_fcr_header_col_orderprov_dt':
                pwxObj.TLIST.sort(pwx_sort_by_order_by)
                pwx_reflab_coll_header_id = clicked_header_id
                pwx_reflab_coll_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
            case 'pwx_fcr_header_personname_dt':
                pwxObj.TLIST.sort(pwx_sort_by_personname)
                pwx_reflab_coll_header_id = clicked_header_id
                pwx_reflab_coll_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
        }
    }
}


function pwx_reflab_sort(pwxObj, clicked_header_id) {
    $('#pwx_frame_content').empty();
    $('#pwx_frame_content').html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
    start_pwx_timer()
    start_page_load_timer = new Date();
    json_reflab_start_number = 0;
    json_reflab_end_number = 0;
    json_reflab_page_start_numbersAr = [];
    reflab_list_curpage = 1;
    if (clicked_header_id == pwx_reflab_header_id) {
        if (pwx_reflab_sort_ind == '0') {
            var sort_ind = '1'
        }
        else {
            var sort_ind = '0'
        }
        pwxObj.TLIST.reverse()
        pwx_reflab_header_id = clicked_header_id
        pwx_reflab_sort_ind = sort_ind
        RenderRefLabListContent(pwxObj);
    }
    else {
        switch (clicked_header_id) {
            case 'pwx_fcr_header_orderdate_dt':
                pwxObj.TLIST.sort(pwx_sort_by_order_date)
                pwx_reflab_header_id = clicked_header_id
                pwx_reflab_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
            case 'pwx_fcr_header_subtype_dt':
                pwxObj.TLIST.sort(pwx_sort_by_subtype)
                pwx_reflab_header_id = clicked_header_id
                pwx_reflab_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
            case 'pwx_fcr_header_labname_dt':
                pwxObj.TLIST.sort(pwx_sort_by_labname)
                pwx_reflab_header_id = clicked_header_id
                pwx_reflab_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
            case 'pwx_fcr_header_personname_dt':
                pwxObj.TLIST.sort(pwx_sort_by_personname)
                pwx_reflab_header_id = clicked_header_id
                pwx_reflab_sort_ind = '0'
                RenderRefLabListContent(pwxObj);
                break;
        }
    }
}
function refLabSubTab(pwxObj, from, clicked_id) {
    switch (clicked_id) {
        case 'pwx_inoffice_lab_tab':
            if (pwx_reflab_type_view != 1) {
                $('#pwx_frame_content').empty();
                $('#pwx_frame_content').html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
                start_pwx_timer()
                start_page_load_timer = new Date();
                json_reflab_start_number = 0;
                json_reflab_end_number = 0;
                json_reflab_page_start_numbersAr = [];
                reflab_list_curpage = 1;
                pwx_reflab_type_view = 1
                RenderRefLabList(pwxObj, from)
            }
            break;
        case 'pwx_outoffice_lab_tab':
            if (pwx_reflab_type_view != 2) {
                $('#pwx_frame_content').empty();
                $('#pwx_frame_content').html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
                start_pwx_timer()
                start_page_load_timer = new Date();
                json_reflab_start_number = 0;
                json_reflab_end_number = 0;
                json_reflab_page_start_numbersAr = [];
                reflab_list_curpage = 1;
                pwx_reflab_type_view = 2
                RenderRefLabList(pwxObj, from)
            }
            break;
        case 'pwx_transferred_lab_tab':
            if (pwx_reflab_type_view != 3) {
                $('#pwx_frame_content').empty();
                $('#pwx_frame_content').html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
                start_pwx_timer()
                start_page_load_timer = new Date();
                json_reflab_start_number = 0;
                json_reflab_end_number = 0;
                json_reflab_page_start_numbersAr = [];
                reflab_list_curpage = 1;
                pwx_reflab_type_view = 3
                RenderRefLabList(pwxObj, from)
            }
            break;
    }
}

pwx_get_reflab_selected = function (class_name) {
    var selectedElems = new Array(9);
    selectedElems[0] = new Array()
    selectedElems[1] = new Array()
    selectedElems[2] = new Array()
    selectedElems[3] = new Array()
    selectedElems[4] = new Array()
    selectedElems[5] = new Array()
    selectedElems[6] = new Array()
    selectedElems[7] = new Array()
    selectedElems[8] = new Array()
    $(class_name).each(function (index) {
        selectedElems[0].length = index + 1
        selectedElems[1].length = index + 1
        selectedElems[2].length = index + 1
        selectedElems[3].length = index + 1
        selectedElems[4].length = index + 1
        selectedElems[5].length = index + 1
        selectedElems[6].length = index + 1
        selectedElems[7].length = index + 1
        selectedElems[8].length = index + 1
        selectedElems[0][index] = $(this).children('span.pwx_task_id_hidden').text() + ".0";
        selectedElems[1][index] = $(this).children('dt.pwx_reflab_type_hidden').text()
        selectedElems[2][index] = $(this).children('dt.pwx_reflab_recieved_hidden').text()
        selectedElems[3][index] = $(this).children('dt.pwx_task_canchart_hidden').text()
        selectedElems[4][index] = $(this).children('dt.pwx_encounter_id_hidden').text() + ".0";
        selectedElems[5][index] = $(this)
        selectedElems[6][index] = $(this).children('dt.pwx_task_order_id_hidden').text() + ".0";
        selectedElems[7][index] = $(this).children('dt.pwx_reflab_trans_ind').text()
        selectedElems[8][index] = $(this).children('dt.pwx_person_id_hidden').text() + ".0";
    });
    return selectedElems;
}

pwx_get_selected_reflab_resched_time_limit = function (class_name) {
    var resched_detailsArr = new Array(2);
    resched_detailsArr[0] = $(class_name).children('dt.pwx_task_resched_time_hidden').text();
    resched_detailsArr[1] = $(class_name).children('dt.pwx_fcr_reflab_taskdate_hidden').text();
    return resched_detailsArr;
}

pwx_get_selected_reflab_unchart_data = function (class_name) {
    //var taskAr = $('.pwx_row_selected').children('.pwx_task_id_hidden').text();
    var unchartTaskArr = new Array();
    $(class_name).children('dt.pwx_fcr_content_labname_dt').children('div.pwx_task_lab_container_hidden').each(function (index) {
        var ar_cnt = unchartTaskArr.length
        unchartTaskArr.length = ar_cnt + 1
        unchartTaskArr[ar_cnt] = new Array(2);
        unchartTaskArr[ar_cnt][0] = $(this).children('span.pwx_task_lab_line_text_hidden').text();
        unchartTaskArr[ar_cnt][1] = $(this).children('span.pwx_task_lab_taskid_hidden').text() + ".0";
    });
    return unchartTaskArr;
}

pwx_reflab_selectall_check = function () {
    var transButtonOn = 1;
    if ($('dl.pwx_content_row.pwx_row_selected').length > 0) {
        $('dl.pwx_content_row.pwx_row_selected').each(function (index) {
            if ($(this).children('dt.pwx_reflab_trans_ind').text() == "0") {
                transButtonOn = 0;
            }
        });
    }
    else {
        transButtonOn = 0;
    }
    if (transButtonOn == 1) {
        //$('#pwx_reflab_transfer_btn').removeAttr('disabled')
        $('#pwx_transfer_btn_cntrl').removeClass('pwx_blue_button-cntrl_inactive').addClass('pwx_blue_button-cntrl')
    }
    else {
        //$('#pwx_reflab_transfer_btn').attr('disabled', 'disabled')
        $('#pwx_transfer_btn_cntrl').removeClass('pwx_blue_button-cntrl').addClass('pwx_blue_button-cntrl_inactive')
    }
}

pwx_reflab_collection_filter_change = function (pwxObj) {
	$('#context-menu-layer').trigger('mousedown'); //close all menus
    $('#pwx_frame_content').empty();
    $('#pwx_frame_content').html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
    start_pwx_timer()
    start_page_load_timer = new Date();
    json_reflab_start_number = 0;
    json_reflab_end_number = 0;
    json_reflab_page_start_numbersAr = [];
    reflab_list_curpage = 1;
    RenderRefLabListContent(pwxObj);
    var transButtonOn = 1;
    if ($('dl.pwx_content_row.pwx_row_selected').length > 0) {
        $('dl.pwx_content_row.pwx_row_selected').each(function (index) {
            if ($(this).children('dt.pwx_reflab_trans_ind').text() == "0") {
                transButtonOn = 0;
            }
        });
    }
    else {
        transButtonOn = 0;
    }
    if (transButtonOn == 1) {
        //$('#pwx_reflab_transfer_btn').removeAttr('disabled')
        $('#pwx_transfer_btn_cntrl').removeClass('pwx_blue_button-cntrl_inactive').addClass('pwx_blue_button-cntrl')
    }
    else {
        //$('#pwx_reflab_transfer_btn').attr('disabled', 'disabled')
        $('#pwx_transfer_btn_cntrl').removeClass('pwx_blue_button-cntrl').addClass('pwx_blue_button-cntrl_inactive')
    }
}

var pwx_reflab_type_view = 1; //1 pending collection //2 ready to transfer //3 is transferred
var pwx_reflab_collection_type_view = '2';
var pwx_reflab_header_id = "pwx_fcr_header_orderdate_dt";
var pwx_reflab_sort_ind = "0";
var pwx_reflab_trans_header_id = "pwx_fcr_trans_header_transdate_dt";
var pwx_reflab_trans_sort_ind = "1";
var pwx_reflab_coll_header_id = "pwx_fcr_header_orderdate_dt";
var pwx_reflab_coll_sort_ind = "0";
var pwx_reflab_get_type = "0";
var pwx_reflab_get_type_str = "All";
var pwx_reflab_global_date = "0";
var json_reflab_end_number = 0;
var json_reflab_start_number = 0;
var json_reflab_page_start_numbersAr = [];
var reflab_list_curpage = 1;
var pwx_reflab_submenu_clicked_task_id = "0";
var pwx_reflab_submenu_clicked_order_id = "0";
var pwx_reflab_submenu_clicked_person_id = "0";
var pwx_reflab_submenu_clicked_row_elem;
var pwx_reflab_to_location_filterArr = [];
var pwx_reflab_to_location_filterApplied = 0;
var pwx_reflab_result_filter = "All"

function RenderPWxRefLabFrame() {
    json_reflab_end_number = 0;
    json_reflab_start_number = 0;
    json_reflab_page_start_numbersAr = [];
    reflab_list_curpage = 1;
    var js_criterion = JSON.parse(m_criterionJSON);
    PWX_CCL_Request_User_Pref('amb_cust_mp_maintain_user_pref', js_criterion.CRITERION.PRSNL_ID, "PWX_MPAGE_MULTI_TASK_TAB_PREF", "REFLABS", true)
    //empty the div's
    $('#pwx_frame_head').empty();
    $('#pwx_frame_content').empty();
    $('#pwx_frame_filter_content').empty();
    $.contextMenu('destroy');
    pwx_task_load_counter = 0
    if (js_criterion.CRITERION.LOC_PREF_FOUND == 1) {
        pwx_current_set_location = js_criterion.CRITERION.LOC_PREF_ID
    }
    //display frame header
    var headelement = document.getElementById('pwx_frame_head');
    var pwxheadHTML = [];
    pwxheadHTML.push('<div id="pwx_frame_toolbar"><dt class="pwx_list_view_radio">');
    if (js_criterion.CRITERION.PWX_TASK_LIST_DISP == 1) {
        pwxheadHTML.push('<div class="pwx_tasklist-seg-cntrl" onclick="RenderPWxFrame()"><div id="tasklistLeft"></div><div id="tasklistCenter">',amb_i18n.ORDER_TASKS,'</div><div id="tasklistRight"></div></div>')
    }
    pwxheadHTML.push('<div class="pwx_reflab-seg-cntrl  tab-layout-active"><div id="refLabLeft"></div><div id="refLabCenter">',amb_i18n.REF_LAB,'</div><div id="refLabRight"></div></div>');
    pwxheadHTML.push('<dt id="pwx_reflab_progressbar_dt_label"></dt><dt id="pwx_reflab_progressbar_dt"></dt>')
    if (js_criterion.CRITERION.PWX_REFLAB_HELP_LINK != "") {
        pwxheadHTML.push('<dt class="pwx_toolbar_task_icon" id="pwx_help_page_icon"><a href=\'javascript: APPLINK(100,"', js_criterion.CRITERION.PWX_REFLAB_HELP_LINK, '","")\' class="pwx_no_text_decor" title="',amb_i18n.HELP_PAGE,'" onClick="">',
        '<span class="pwx-help-icon">&nbsp;</span></a></dt>');
    }
    pwxheadHTML.push('<dt class="pwx_toolbar_task_icon"><a class="pwx_no_text_decor" title="',amb_i18n.DESELECT_ALL,'" onClick="pwx_deselect_all(\'pwx_row_selected\');pwx_reflab_selectall_check()"> <span class="pwx-deselect_all-icon">&nbsp;</span></a></dt>');
    pwxheadHTML.push('<dt class="pwx_toolbar_task_icon"><a class="pwx_no_text_decor" title="',amb_i18n.SELECT_ALL,'" onClick="pwx_select_all(\'pwx_row_selected\');pwx_reflab_selectall_check()"><span class="pwx-select_all-icon">&nbsp;</span></a></dt>');
    pwxheadHTML.push('<dt id="pwx_location_list">');
    if (js_criterion.CRITERION.LOC_LIST.length > 0) {
        pwxheadHTML.push('<span class="pwx_location_list_lbl">',amb_i18n.LOCATION,': </span>');
		pwxheadHTML.push('<select id="ref_location" name="ref_location" style="width:300px;" data-placeholder="Choose a Location..." class="chzn-select"><option value=""></option>');
        var loc_height = 30;
        for (var i = 0; i < js_criterion.CRITERION.LOC_LIST.length; i++) {
            loc_height += 26;
            if (pwx_current_set_location == js_criterion.CRITERION.LOC_LIST[i].ORG_ID) {
                pwxheadHTML.push('<option value="', js_criterion.CRITERION.LOC_LIST[i].ORG_ID, '" selected="selected">', js_criterion.CRITERION.LOC_LIST[i].ORG_NAME, '</option>');
            }
            else {
                pwxheadHTML.push('<option value="', js_criterion.CRITERION.LOC_LIST[i].ORG_ID, '">', js_criterion.CRITERION.LOC_LIST[i].ORG_NAME, '</option>');
            }
        }
        if (loc_height > 300) { loc_height = 300; }
        pwxheadHTML.push('</select>');
    }
    else {
        pwxheadHTML.push(amb_i18n.NO_RELATED_LOC);
    }
    headelement.innerHTML = pwxheadHTML.join("");
	$('#ref_location').chosen({
		no_results_text : "No results matched"
	});
	$("#ref_location").on("change", function (event) {
        pwx_current_set_location = $("#ref_location").val();
        RenderDateRangeTaskList("", 'pwx_location', pwx_current_set_location);
        PWX_CCL_Request_User_Pref('amb_cust_mp_maintain_user_pref', js_criterion.CRITERION.PRSNL_ID, "PWX_MPAGE_ORG_TASK_LIST_LOCS", pwx_current_set_location, true);
    });
    //build filter here just do date at first
    var filterelement = document.getElementById('pwx_frame_filter_content');
    var pwxfilterbarHTML = [];
    pwxfilterbarHTML.push('<div id="pwx_frame_filter_bar"><div id="pwx_frame_filter_bar_container"><dl>');
    pwxfilterbarHTML.push('<dt id="pwx_reflab_subtabs_filter"></dt>')
    pwxfilterbarHTML.push('<dt id="pwx_date_picker" class="pwx_reflab_filter_bar_toppad"><label for="from"><span style="vertical-align:20%;">',amb_i18n.ORDER_DATE,': </span><input type="text" id="from" name="from" class="pwx_date_box" /></label></dt>');
    pwxfilterbarHTML.push('<dt class="pwx_reflab_transfer_btn_dt"></dt>');
    pwxfilterbarHTML.push('<dt class="pwx_task_filterbar_icon" id="pwx_task_info_icon"></dt>');
    pwxfilterbarHTML.push('<dt class="pwx_task_filterbar_icon" id="pwx_task_list_refresh_icon"></dt>');
    pwxfilterbarHTML.push('</dl><div id="pwx_frame_advanced_filters_container" style="display:none;"></div></div>');
    pwxfilterbarHTML.push('<div id="pwx_frame_paging_bar_container" style="display:none;"><dt id="pwx_task_filterbar_page_prev" class="pwx_task_pagingbar_page_icons"></dt><dt id="pwx_task_filterbar_page_next" class="pwx_task_pagingbar_page_icons"></dt><dt id="pwx_task_pagingbar_cur_page" class="pwx_grey"></dt><dt id="pwx_task_pagingbar_load_text"></dt><dt id="pwx_task_pagingbar_load_count" class="pwx_grey"></dt></div>');
    pwxfilterbarHTML.push('<dl><dt id="pwx_frame_filter_bar_bottom_pad"></dt><dl></div>');
    filterelement.innerHTML = pwxfilterbarHTML.join("");
    //function to handle a date range entry
    function RenderDateRangeTaskList(selectedDate, dateId, locId) {
        if (dateId == 'from') {
            current_from_date = selectedDate;
            pwx_reflab_global_date = selectedDate;
        }
        else if (dateId == 'pwx_location') {
            current_location_id = locId;
            if ($("#from").val() != "" && current_from_date == '') {
                $("#from").val("")
            }
        }
        if (current_from_date != '' && current_location_id > 0) {
            //both dates and location found load list
            $('#pwx_frame_content').empty();
            $('#pwx_frame_content').html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
            pwx_current_set_location = current_location_id;
            pwx_reflab_global_date = current_from_date;
            start_pwx_timer()
            var start_ccl_timer = new Date();
            var sendArr = ["^MINE^", js_criterion.CRITERION.PRSNL_ID + ".0", js_criterion.CRITERION.POSITION_CD + ".0", "^" + current_from_date + "^", current_location_id + ".0"];
            PWX_CCL_Request("amb_cust_mp_reflab_by_loc_dt", sendArr, true, function () {
                current_from_date = "";
                var end_ccl_timer = new Date();
                ccl_timer = (end_ccl_timer - start_ccl_timer) / 1000
                start_page_load_timer = new Date();

                pwx_reflab_header_id = 'pwx_fcr_header_orderdate_dt'
                pwx_reflab_sort_ind = '0'
                pwx_reflab_trans_header_id = 'pwx_fcr_trans_header_transdate_dt'
                pwx_reflab_trans_sort_ind = '1'
                pwx_reflab_coll_header_id = "pwx_fcr_header_orderdate_dt";
                pwx_reflab_coll_sort_ind = "0";
                var end_ccl_timer = new Date();
                ccl_timer = (end_ccl_timer - start_ccl_timer) / 1000
                //check counts and default tab based on counts
                if (this.INCNT == 0 && this.OUTCNT != 0) {
                    pwx_reflab_type_view = 2
                    if (this.READY_OUT_CNT == 0 && this.READY_IN_CNT != 0) {
                        pwx_reflab_collection_type_view = 1
                    }
                }
                else if (this.INCNT == 0 && this.OUTCNT == 0 && this.TRANSCNT != 0) {
                    pwx_reflab_type_view = 3
                    if (this.TRANS_OUT_CNT == 0 && this.TRANS_IN_CNT != 0) {
                        pwx_reflab_collection_type_view = 1
                    }
                }
                RenderRefLabList(this, pwx_reflab_global_date);
            });
        }
    }
    //set the date range datepickers
    $("#from").datepicker({
        dateFormat: "mm/dd/yy",
        showOn: "focus",
        changeMonth: true,
        changeYear: true,
        onSelect: function (selectedDate) {
            RenderDateRangeTaskList(selectedDate, this.id);
            $.datepicker._hideDatepicker();
        }
    });
    if (js_criterion.CRITERION.LOC_PREF_FOUND == 1) {
        pwx_current_set_location = js_criterion.CRITERION.LOC_PREF_ID
        RenderDateRangeTaskList("", 'pwx_location', pwx_current_set_location);
        if (pwx_reflab_global_date == "0") {
            var fromdate = Date.today().toString("MM/dd/yyyy");
            $('#from').datepicker("setDate", fromdate)
        }
        else {
            var fromdate = pwx_reflab_global_date;
            $('#from').datepicker("setDate", fromdate)
        }
        RenderDateRangeTaskList(fromdate, "from");
    }
}

function RenderRefLabList(pwxdata, from) {
    var start_filterbar_timer = new Date();
    json_task_start_number = 0;
    json_task_end_number = 0;
    json_task_page_start_numbersAr = [];
    task_list_curpage = 1;
    $(window).off('resize')
	var framecontentElem =  $('#pwx_frame_content')
    framecontentElem.off()
    $('#pwx_frame_filter_content').off()
    var js_criterion = JSON.parse(m_criterionJSON);
    //build the filter bar
    var pwxfilterbarHTML = [];
    if (pwx_reflab_type_view == 1) {
        pwxfilterbarHTML.push('<div class="pwx_lab_subtab-seg-cntrl subtab-layout-active" id="pwx_inoffice_lab_tab"><div id="inOfficeLeft"></div><div id="inOfficeCenter">', pwxdata.INOFFICE_LBL, ' (', pwxdata.INCNT, ')</div><div id="inOfficeRight"></div></div>')
    } else {
        pwxfilterbarHTML.push('<div class="pwx_lab_subtab-seg-cntrl" id="pwx_inoffice_lab_tab"><div id="inOfficeLeft"></div><div id="inOfficeCenter">', pwxdata.INOFFICE_LBL, ' (', pwxdata.INCNT, ')</div><div id="inOfficeRight"></div></div>')
    }
    if (pwx_reflab_type_view == 2) {
        pwxfilterbarHTML.push('<div class="pwx_lab_subtab-seg-cntrl subtab-layout-active" id="pwx_outoffice_lab_tab"><div id="outOfficeLeft"></div><div id="outOfficeCenter">', pwxdata.OUTOFFICE_LBL, ' (', pwxdata.OUTCNT, ')</div><div id="outOfficeRight"></div></div>')
    } else {
        pwxfilterbarHTML.push('<div class="pwx_lab_subtab-seg-cntrl" id="pwx_outoffice_lab_tab"><div id="outOfficeLeft"></div><div id="outOfficeCenter">', pwxdata.OUTOFFICE_LBL, ' (', pwxdata.OUTCNT, ')</div><div id="outOfficeRight"></div></div>')
    }
    if (pwx_reflab_type_view == 3) {
        pwxfilterbarHTML.push('<div class="pwx_lab_subtab-seg-cntrl subtab-layout-active" id="pwx_transferred_lab_tab"><div id="transferredLeft"></div><div id="transferredCenter">', pwxdata.TRANSORDERS_LBL, ' (', pwxdata.TRANSCNT, ')</div><div id="transferredRight"></div></div>')
    } else {
        pwxfilterbarHTML.push('<div class="pwx_lab_subtab-seg-cntrl" id="pwx_transferred_lab_tab"><div id="transferredLeft" ></div><div id="transferredCenter">', pwxdata.TRANSORDERS_LBL, ' (', pwxdata.TRANSCNT, ')</div><div id="transferredRight"></div></div>')
    }
    $('#pwx_reflab_subtabs_filter').html(pwxfilterbarHTML.join(""));
    $('#pwx_task_list_refresh_icon').html('<span class="pwx-refresh-icon" title="' + amb_i18n.REFRESH_LIST + '"></span>')
    pwxfilterbarHTML = []
    if (pwx_reflab_type_view == 2) {
        $('dt.pwx_reflab_transfer_btn_dt').html('<div class="pwx_blue_button-cntrl_inactive" id="pwx_transfer_btn_cntrl"><div class="pwx_blue_buttonLeft"></div><div class="pwx_blue_buttonCenter">' + amb_i18n.TRANSMIT + '</div><div class="pwx_blue_buttonRight"></div></div>').css('display', 'inline-block');
        pwxfilterbarHTML.push('<dt id="pwx_reflab_collection_filter" >')
        if (pwx_reflab_collection_type_view == 2) {
            pwxfilterbarHTML.push('<label for="pwx_tab2_col_radio_val2" ><input id="pwx_tab2_col_radio_val2" name="reflab_collection_radio" type="radio" checked="checked" value="2"><span style="vertical-align:30%;" title="',amb_i18n.COLLECTED_OUT_OFFICE_TOOLTIP,'">&nbsp;',amb_i18n.COLLECTED_OUT_OFFICE,' (', pwxdata.READY_OUT_CNT, ')</span></input></label>')
        } else {
            pwxfilterbarHTML.push('<label for="pwx_tab2_col_radio_val2" ><input id="pwx_tab2_col_radio_val2" name="reflab_collection_radio" type="radio" value="2"><span style="vertical-align:30%;" title="',amb_i18n.COLLECTED_OUT_OFFICE_TOOLTIP,'">&nbsp;',amb_i18n.COLLECTED_OUT_OFFICE,' (', pwxdata.READY_OUT_CNT, ')</span></input></label>')
        }
        if (pwx_reflab_collection_type_view == 1) {
            pwxfilterbarHTML.push('&nbsp;&nbsp;<label for="pwx_tab2_col_radio_val1" ><input id="pwx_tab2_col_radio_val1" name="reflab_collection_radio" type="radio" checked="checked" value="1"><span style="vertical-align:30%;" title="',amb_i18n.COLLECTED_IN_OFFICE_TOOLTIP,'">&nbsp;',amb_i18n.COLLECTED_IN_OFFICE,' (', pwxdata.READY_IN_CNT, ')</span></input></label>')
        } else {
            pwxfilterbarHTML.push('&nbsp;&nbsp;<label for="pwx_tab2_col_radio_val1" ><input id="pwx_tab2_col_radio_val1" name="reflab_collection_radio" type="radio" value="1"><span style="vertical-align:30%;" title="',amb_i18n.COLLECTED_IN_OFFICE_TOOLTIP,'">&nbsp;',amb_i18n.COLLECTED_IN_OFFICE,' (', pwxdata.READY_IN_CNT, ')</span></input></label>')
        }
        pwxfilterbarHTML.push('</dt>')
        pwxfilterbarHTML.push('<dt id="pwx_reflab_tolocation_filter" ></dt>')
        $('#pwx_frame_advanced_filters_container').css('display', 'inline-block')
    } else if (pwx_reflab_type_view == 3) {
        $('dt.pwx_reflab_transfer_btn_dt').html('').css('display', 'none')
        pwxfilterbarHTML.push('<dt id="pwx_reflab_collection_filter" >')
        if (pwx_reflab_collection_type_view == 2) {
            pwxfilterbarHTML.push('<label for="pwx_tab3_col_radio_val2" ><input id="pwx_tab3_col_radio_val2" name="reflab_collection_radio" type="radio" checked="checked" value="2"><span style="vertical-align:30%;" title="',amb_i18n.COLLECTED_OUT_OFFICE_TOOLTIP,'">&nbsp;',amb_i18n.COLLECTED_OUT_OFFICE,' (', pwxdata.TRANS_OUT_CNT, ')</span></input></label>')
        } else {
            pwxfilterbarHTML.push('<label for="pwx_tab3_col_radio_val2" ><input id="pwx_tab3_col_radio_val2" name="reflab_collection_radio" type="radio" value="2"><span style="vertical-align:30%;" title="',amb_i18n.COLLECTED_OUT_OFFICE_TOOLTIP,'">&nbsp;',amb_i18n.COLLECTED_OUT_OFFICE,' (', pwxdata.TRANS_OUT_CNT, ')</span></input></label>')
        }
        if (pwx_reflab_collection_type_view == 1) {
            pwxfilterbarHTML.push('&nbsp;&nbsp;<label for="pwx_tab3_col_radio_val1" ><input id="pwx_tab3_col_radio_val1" name="reflab_collection_radio" type="radio" checked="checked" value="1"><span style="vertical-align:30%;" title="',amb_i18n.COLLECTED_IN_OFFICE_TOOLTIP,'">&nbsp;',amb_i18n.COLLECTED_IN_OFFICE,' (', pwxdata.TRANS_IN_CNT, ')</span></input></label>')
        } else {
            pwxfilterbarHTML.push('&nbsp;&nbsp;<label for="pwx_tab3_col_radio_val1" ><input id="pwx_tab3_col_radio_val1" name="reflab_collection_radio" type="radio" value="1"><span style="vertical-align:30%;" title="',amb_i18n.COLLECTED_IN_OFFICE_TOOLTIP,'">&nbsp;',amb_i18n.COLLECTED_IN_OFFICE,'(', pwxdata.TRANS_IN_CNT, ')</span></input></label>')
        }
        pwxfilterbarHTML.push('</dt>')
        pwxfilterbarHTML.push('<dt id="pwx_reflab_tolocation_filter" ></dt>')
        pwxfilterbarHTML.push('<dt id="pwx_reflab_result_filter" ><span style="vertical-align:30%;">',amb_i18n.RESULT_STATUS,': </span><select id="reflab_results" name="reflab_results" multiple="multiple" width="150">')
        if (pwx_reflab_result_filter == "All") {
            pwxfilterbarHTML.push('<option selected="selected" value="All">',amb_i18n.ALL,'</option>')
        } else {
            pwxfilterbarHTML.push('<option value="All">',amb_i18n.ALL,'</option>')
        }
        if (pwx_reflab_result_filter == "Pending") {
            pwxfilterbarHTML.push('<option selected="selected" value="Pending">',amb_i18n.PENDING_RESULTS,'</option>')
        } else {
            pwxfilterbarHTML.push('<option value="Pending">',amb_i18n.PENDING_RESULTS,'</option>')
        }
        if (pwx_reflab_result_filter == "Results") {
            pwxfilterbarHTML.push('<option selected="selected" value="Results">',amb_i18n.RESULTS_REC,'</option>')
        } else {
            pwxfilterbarHTML.push('<option value="Results">',amb_i18n.RESULTS_REC,'</option>')
        }
        pwxfilterbarHTML.push('</select></dt>')
        $('#pwx_frame_advanced_filters_container').css('display', 'inline-block')
    }
    else {
        $('dt.pwx_reflab_transfer_btn_dt').html('').css('display', 'none')
        $('#pwx_frame_advanced_filters_container').css('display', 'none')
    }
    $('#pwx_frame_advanced_filters_container').html(pwxfilterbarHTML.join(""))
    if (pwx_reflab_type_view == 3) {
        var progBarValue = Math.round((pwxdata.RESULT_CNT / pwxdata.TRANSCNT) * 100);
        if (isNaN(progBarValue) == true) {
            progBarValue = 0
        }
        $('#pwx_reflab_progressbar_dt_label').html('<span class="pwx_grey">' + amb_i18n.RESULTS_REC + ' (' + progBarValue + '%):</span>')
        $('#pwx_reflab_progressbar_dt').attr('title', pwxdata.RESULT_CNT + ' ' + amb_i18n.OF + ' ' + pwxdata.TRANSCNT + ' ' + amb_i18n.RESULTS_REC).html('<div id="pwx_reflab_progressbar"></div>')
    }
    else {
        var progBarValue = Math.round((pwxdata.TRANSCNT / (pwxdata.INCNT + pwxdata.OUTCNT + pwxdata.TRANSCNT)) * 100)
        if (isNaN(progBarValue) == true) {
            progBarValue = 0
        }
        $('#pwx_reflab_progressbar_dt_label').html('<span class="pwx_grey">' + amb_i18n.TRANSMITTED + ' (' + progBarValue + '%):</span>')
        $('#pwx_reflab_progressbar_dt').attr('title', pwxdata.TRANSCNT + ' ' + amb_i18n.OF + ' ' + (pwxdata.INCNT + pwxdata.OUTCNT + pwxdata.TRANSCNT) + ' ' + amb_i18n.TRANSFERRED).html('<div id="pwx_reflab_progressbar"></div>')
    }
    $('#pwx_reflab_progressbar').progressbar({
        value: progBarValue
    });
    $('.pwx_lab_subtab-seg-cntrl').on('click', function () {
        var tabId = $(this).attr('id')
        refLabSubTab(pwxdata, from, tabId);
    })

    if (pwxdata.TASK_INFO_TEXT != "") {
        $('#pwx_task_info_icon').html('<a class="pwx_no_text_decor" title="' + amb_i18n.REF_LAB_INFO + '"> <span class="pwx-information-icon">&nbsp;</span></a>');

        $('#pwx_task_info_icon a').on('click', function () {
            MP_ModalDialog.deleteModalDialogObject("TaskInfoModal")
            var taskInfoModal = new ModalDialog("TaskInfoModal")
             .setHeaderTitle(amb_i18n.REF_LAB_INFO)
             .setShowCloseIcon(true)
             .setTopMarginPercentage(20)
             .setRightMarginPercentage(35)
             .setBottomMarginPercentage(35)
             .setLeftMarginPercentage(35)
             .setIsBodySizeFixed(true)
             .setHasGrayBackground(true)
             .setIsFooterAlwaysShown(false);
            taskInfoModal.setBodyDataFunction(
             function (modalObj) {
                 modalObj.setBodyHTML('<div class="pwx_task_detail">' + pwxdata.TASK_INFO_TEXT + '</div>');
             });
            MP_ModalDialog.addModalDialogObject(taskInfoModal);
            MP_ModalDialog.showModalDialog("TaskInfoModal")
        });
    }
    else {
        $('#pwx_task_info_icon').remove()
    }

    $('#pwx_task_list_refresh_icon').on('click', function () {
        var js_criterion = JSON.parse(m_criterionJSON);
        framecontentElem.empty();
        framecontentElem.html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
        start_pwx_timer()
        var start_ccl_timer = new Date();
        var sendArr = ["^MINE^", js_criterion.CRITERION.PRSNL_ID + ".0", js_criterion.CRITERION.POSITION_CD + ".0", "^" + pwx_reflab_global_date + "^", pwx_current_set_location + ".0"];
        PWX_CCL_Request("amb_cust_mp_reflab_by_loc_dt", sendArr, true, function () {
            var end_ccl_timer = new Date();
            ccl_timer = (end_ccl_timer - start_ccl_timer) / 1000
            start_page_load_timer = new Date();
            RenderRefLabList(this, from);
        });
    });
	
    if (pwx_reflab_type_view == 2) {
        $('#pwx_frame_filter_content').on('click', '.pwx_blue_button-cntrl#pwx_transfer_btn_cntrl ', function () {
            var js_criterion = JSON.parse(m_criterionJSON);
            var transferblob = { "TRANSFERS": { "TLIST": {}} };
            //var containidArr = [{ "CONTAINER_ID": 0 }, { "CONTAINER_ID": 1}]
            var containidArr = new Array();
            $('dl.pwx_row_selected').children('dt.pwx_fcr_content_labname_dt').children('div.pwx_task_lab_container_hidden').each(function (index) {
                var to_location = $(this).parents('dt.pwx_fcr_content_labname_dt').siblings('dt.pwx_fcr_content_action_dt').children('.pwx_fcr_content_action_move_dt').children('.pwx_reflab_to_location').text()
                containidArr.push({ "CONTAINER_ID": parseFloat($(this).children('span.pwx_task_lab_containid_hidden').text()), "TO_LOCATION": parseFloat(to_location) })
            });
            transferblob.TRANSFERS.TLIST = containidArr
            //alert(JSON.stringify(transferblob))
            var sendArr = ["^MINE^", js_criterion.CRITERION.PRSNL_ID + ".0"];
            MP_DCP_REFLAB_TRANSFER_Request("AMB_CUST_MP_REFLAB_TRANSFER", transferblob, sendArr, true);
        });
    }
    $("#reflab_results").multiselect({
        height: "80",
        header: false,
        multiple: false,
        minWidth: "150",
        classes: "pwx_select_box",
        selectedList: 1
    });
    $(window).on('resize', function () {
        //make sure fixed position for filter bar correct
        var toolbarH = $('#pwx_frame_toolbar').height() + 6;
        $('#pwx_frame_filter_bar').css('top', toolbarH + 'px');
        var filterbarH = $('#pwx_frame_filter_bar').height() + toolbarH;
		$('#pwx_frame_content_rows_header').css('top', filterbarH + 'px');
		var contentrowsH = filterbarH + 19;
		$('#pwx_frame_content_rows').css('top', contentrowsH + 'px');
        $('span.pwx_fcr_content_type_name_dt, span.pwx_fcr_content_type_ordname_dt, dt.pwx_fcr_content_col_orderprov_dt, dt.pwx_fcr_trans_content_tolocation_dt').each(function (index) {
            if (this.clientWidth < this.scrollWidth) {
                var titleText = $(this).text()
                $(this).attr("title", titleText)
            }
        });
        $(".pwx_to_location_class").css("width", "")
        $(".pwx_to_location_class").multiselect('refresh')
        var selectWidth = $(".pwx_fcr_content_action_move_dt").width()
        $(".pwx_to_location_class").css("width", selectWidth - 10)
        $(".pwx_to_location_class").multiselect('refresh')
    });
    //tab specifc workings
    if (pwx_reflab_type_view == 3) {
        switch (pwx_reflab_trans_header_id) {
            case 'pwx_fcr_trans_header_labname_dt':
                pwxdata.TLIST.sort(pwx_sort_by_labname)
                break;
            case 'pwx_fcr_trans_header_tolocation_dt':
                pwxdata.TLIST.sort(pwx_sort_by_tolocation)
                break;
            case 'pwx_fcr_trans_header_orderdate_dt':
                pwxdata.TLIST.sort(pwx_sort_by_order_date)
                break;
            case 'pwx_fcr_trans_header_transdate_dt':
                pwxdata.TLIST.sort(pwx_sort_by_trans_date)
                break;
            case 'pwx_fcr_header_personname_dt':
                pwxdata.TLIST.sort(pwx_sort_by_personname)
                break;
        }
        if (pwx_reflab_trans_sort_ind == "1") {
            pwxdata.TLIST.reverse()
        }
    }
    else if (pwx_reflab_type_view == 2) {
        switch (pwx_reflab_header_id) {
            case 'pwx_fcr_header_labname_dt':
                pwxdata.TLIST.sort(pwx_sort_by_labname)
                break;
            case 'pwx_fcr_header_subtype_dt':
                pwxdata.TLIST.sort(pwx_sort_by_suptype)
                break;
            case 'pwx_fcr_header_orderdate_dt':
                pwxdata.TLIST.sort(pwx_sort_by_order_date)
                break;
            case 'pwx_fcr_header_personname_dt':
                pwxdata.TLIST.sort(pwx_sort_by_personname)
                break;
        }

        if (pwx_reflab_sort_ind == "1") {
            pwxdata.TLIST.reverse()
        }
    }
    else if (pwx_reflab_type_view == 1) {
        switch (pwx_reflab_coll_header_id) {
            case 'pwx_fcr_header_col_labname_dt':
                pwxdata.TLIST.sort(pwx_sort_by_labname)
                break;
            case 'pwx_fcr_header_col_subtype_dt':
                pwxdata.TLIST.sort(pwx_sort_by_suptype)
                break;
            case 'pwx_fcr_header_col_orderprov_dt':
                pwxdata.TLIST.sort(pwx_sort_by_order_by)
                break;
            case 'pwx_fcr_header_orderdate_dt':
                pwxdata.TLIST.sort(pwx_sort_by_task_date)
                break;
            case 'pwx_fcr_header_personname_dt':
                pwxdata.TLIST.sort(pwx_sort_by_personname)
                break;
        }

        if (pwx_reflab_coll_sort_ind == "1") {
            pwxdata.TLIST.reverse()
        }
    }

    var end_filterbar_timer = new Date();
    filterbar_timer = (end_filterbar_timer - start_filterbar_timer) / 1000

    RenderRefLabListContent(pwxdata);

    var start_delegate_event_timer = new Date();
    //build the row events
    framecontentElem.on('mousedown', 'dl.pwx_content_row', function (e) {
        if (e.which == '3') {
            $(this).removeClass('pwx_row_selected').addClass('pwx_row_selected');
			var persId = $(this).children('dt.pwx_person_id_hidden').text();
			var encntrId = $(this).children('dt.pwx_encounter_id_hidden').text();
			var persName = $(this).children('dt.pwx_person_name_hidden').text();
			pwx_set_patient_focus(persId, encntrId, persName);
        }
        else {
            //$(this).toggleClass('pwx_row_selected');
			if($(this).hasClass('pwx_row_selected') === true) {
				$(this).removeClass('pwx_row_selected');
				pwx_clear_patient_focus();
			} else {
				$(this).addClass('pwx_row_selected');
				var persId = $(this).children('dt.pwx_person_id_hidden').text();
				var encntrId = $(this).children('dt.pwx_encounter_id_hidden').text();
				var persName = $(this).children('dt.pwx_person_name_hidden').text();
				pwx_set_patient_focus(persId, encntrId, persName);
			}
        }
        if (pwx_reflab_type_view == 2) {
            var transButtonOn = 1;
            if ($('dl.pwx_content_row.pwx_row_selected').length > 0) {
                $('dl.pwx_content_row.pwx_row_selected').each(function (index) {
                    if ($(this).children('dt.pwx_reflab_trans_ind').text() == "0") {
                        transButtonOn = 0;
                    }
                });
            }
            else {
                transButtonOn = 0;
            }
            if (transButtonOn == 1) {
                //$('#pwx_reflab_transfer_btn').removeAttr('disabled')
                $('#pwx_transfer_btn_cntrl').removeClass('pwx_blue_button-cntrl_inactive').addClass('pwx_blue_button-cntrl')
            }
            else {
                //$('#pwx_reflab_transfer_btn').attr('disabled', 'disabled')
                $('#pwx_transfer_btn_cntrl').removeClass('pwx_blue_button-cntrl').addClass('pwx_blue_button-cntrl_inactive')
            }
        }
    });
    $.contextMenu('destroy', 'dl.pwx_content_row');
    $.contextMenu({
        selector: 'dl.pwx_content_row',
        zIndex: '9999',
        className: 'ui-widget',
        build: function ($trigger, e) {
            $($trigger).addClass('pwx_row_selected')
            var taskInfo = pwx_get_reflab_selected('dl.pwx_row_selected');
            // alert(taskInfo[0][0] + ',' + taskInfo[1][0] + ',' + taskInfo[2][0] + ',');
            taskIdlist = taskInfo[0].join(',');
            orderIdlist = taskInfo[6].join(',');
            reschedule_TaskIds = taskInfo[0][0]
            var can_not_chart_found = 0;
            var transButtonOn = 1;
            for (var cc = 0; cc < taskInfo[1].length; cc++) {
                if (taskInfo[3][cc] == 0) {
                    can_not_chart_found = 1;
                }
                if (taskInfo[7][cc] == '0') {
                    transButtonOn = 0;
                }
            }
            var uniquePersonArr = []
            uniquePersonArr = $.grep(taskInfo[8], function (v, k) {
                return $.inArray(v, taskInfo[8]) === k;
            });
            var uniqueEncounterArr = []
            uniqueEncounterArr = $.grep(taskInfo[4], function (v, k) {
                return $.inArray(v, taskInfo[4]) === k;
            });
            var ccllinkparams = '^MINE^,^' + js_criterion.CRITERION.PWX_PATIENT_SUMM_PRG + '^,' + uniquePersonArr[0] + '.0,' + uniqueEncounterArr[0] + '.0';
            //Build options dependending on tab.
            if (pwx_reflab_type_view == 1) {
                var options = {
                    items: {
                        "Done": { "name": amb_i18n.DONE, callback: function (key, opt) {
                            var lab_taskAr = new Array()
                            for (var cc = 0; cc < taskInfo[0].length; cc++) {
                                var taskSuccess = pwx_task_launch(taskInfo[8][cc], taskInfo[0][cc], 'CHART');
                                if (taskSuccess == true) {
                                    var dlHeight = $(taskInfo[5][cc]).height()
                                    $(taskInfo[5][cc]).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#87C854').css('height', dlHeight).attr("title", amb_i18n.CHARTED_DONE_REFRESH)
                                    $(taskInfo[5][cc]).removeClass('pwx_row_selected')
                                    lab_taskAr.push(taskInfo[0][cc])
                                }
                            }
                            if (lab_taskAr.length > 0) {
                                if (pwxdata.LABEL_PRINT_AUTO_OFF != "1") {
                                    if (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0) {
                                        var taskSuccess = pwx_task_label_print_launch(uniquePersonArr[0], lab_taskAr.join(','));
                                    }
                                    else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRA") {
                                        var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                        window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRA_LABEL','" + ccllinkparams + "',0)";
                                    }
                                    else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRASMALL") {
                                        var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                        window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRASMALL','" + ccllinkparams + "',0)";
                                    }
                                    else {
                                        var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                        window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_DYMO_LABEL','" + ccllinkparams + "',0)";
                                    }
                                }
                                if (pwxdata.AUTOLOG_SPEC_IND == 1) { setTimeout(function () { PWX_CCL_Request_Specimen_Login("amb_cust_call_spec_auto_loc", lab_taskAr.join(','), true) }, 1000); }
                            }
                        }
                        },
                        "Not Done": { "name": amb_i18n.NOT_DONE, callback: function (key, opt) {
                            for (var cc = 0; cc < taskInfo[0].length; cc++) {
                                var taskSuccess = pwx_task_launch(taskInfo[8][cc], taskInfo[0][cc], 'CHART_NOT_DONE');
                                if (taskSuccess == true) {
                                    var dlHeight = $(taskInfo[5][cc]).height()
                                    $(taskInfo[5][cc]).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#DF5E3E').css('height', dlHeight).attr("title", amb_i18n.CHARTED_NOT_DONE_REFRESH)
                                    $(taskInfo[5][cc]).removeClass('pwx_row_selected')
                                }
                            }
                        }
                        },
                        "Reschedule": { "name": amb_i18n.RESCHEDULE, callback: function (key, opt) {
                            var time_check = pwx_get_selected_reflab_resched_time_limit('dl.pwx_row_selected');
                            var task_dt = Date.parse(time_check[1]);
                            var curDate = new Date()
                            var resched_limit_dt = curDate.addHours(time_check[0]);
                            $('#pwx_resched_dt_tm').val("")
                            $('#pwx-reschedule-btn').button('disable')
                            $("#pwx_resched_dt_tm").datetimepicker('option', 'minDate', new Date());
                            $("#pwx_resched_dt_tm").datetimepicker('option', 'maxDate', resched_limit_dt);
                            $("#pwx-resched-dialog-confirm").dialog('open')
                        }
                        },
                        "sep2": "---------",
                        "Print Label(s)": { "name": amb_i18n.PRINT_LABELS, callback: function (key, opt) {
                            if (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0) {
                                var taskSuccess = pwx_task_label_print_launch(uniquePersonArr[0], taskIdlist);
                            }
                            else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRA") {
                                var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                                orderIdlist = orderInfo.join(',');
                                var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRA_LABEL','" + ccllinkparams + "',0)";
                            }
                            else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRASMALL") {
                                var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                                orderIdlist = orderInfo.join(',');
                                var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRASMALL','" + ccllinkparams + "',0)";
                            }
                            else {
                                var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                                orderIdlist = orderInfo.join(',');
                                var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_DYMO_LABEL','" + ccllinkparams + "',0)";
                            }
                            $('dl.pwx_row_selected').removeClass('pwx_row_selected')
                        }
                        },
                        "fold2": { "name": amb_i18n.PRINT_REQ,
                            //"name": "Print Requisitions&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                            "items": {
                                "Selected Accession(s)": { "name": amb_i18n.SELECTED_ACC, callback: function (key, opt) {
                                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^,' + 0 + ',' + js_criterion.CRITERION.PRSNL_ID + '.0';
                                    window.location = "javascript:CCLLINK('amb_cust_mp_reflab_call_labreq','" + ccllinkparams + "',0)";
                                }
                                },
                                "Visit Accession(s)": { "name": amb_i18n.VISIT_ACC, callback: function (key, opt) {
                                    var ccllinkparams = '^MINE^,^^,' + uniqueEncounterArr[0] + ',' + js_criterion.CRITERION.PRSNL_ID + '.0';
                                    window.location = "javascript:CCLLINK('amb_cust_mp_reflab_call_labreq','" + ccllinkparams + "',0)";
                                }
                                }

                            }
                        },
                        "sep3": "---------",
                        "fold1": {
                            //"name": "Chart Forms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                            "name": amb_i18n.CHART_FORMS,
                            "items": {},
                            disabled: false
                        },
                        "sep4": "---------",
                        "Select All": { "name": amb_i18n.SELECT_ALL, callback: function (key, opt) { pwx_select_all('pwx_row_selected'); pwx_reflab_selectall_check() } },
                        "Deselect All": { "name": amb_i18n.DESELECT_ALL, callback: function (key, opt) { pwx_deselect_all('pwx_row_selected'); pwx_reflab_selectall_check() } },
                        "sep5": "---------",
                        "fold3": {
                            //"name": "Chart Forms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                            "name": amb_i18n.OPEN_PT_CHART,
                            "items": {},
                            disabled: false
                        }
                    }
                };

                if (uniqueEncounterArr.length > 1) {
                    options.items["fold2"].items["Visit Accession(s)"] = { "name": amb_i18n.VISIT_ACC, disabled: function (key, opt) { return true; } };
                    options.items["fold2"].items["Selected Accession(s)"] = { "name": amb_i18n.SELECTED_ACC, disabled: function (key, opt) { return true; } };
                    options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
                    options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
                } else {
                    if (pwxdata.FORMSLIST.length > 0) {
                        for (var cc in pwxdata.FORMSLIST) {
                            options.items["fold1"].items[cc + "|forms"] = { "name": pwxdata.FORMSLIST[cc].FORM_NAME, callback: function (key, opt) { var keyArr = key.split("|"); pwx_form_launch(uniquePersonArr[0], uniqueEncounterArr[0], pwxdata.FORMSLIST[keyArr[0]].FORM_ID, 0.0, 0); } }
                        }
                        options.items["fold1"].items["Forms Menu"] = { "name": amb_i18n.ALL_FORMS, "className": "pwx_link_blue", callback: function (key, opt) { pwx_form_launch(uniquePersonArr[0], uniqueEncounterArr[0], 0.0, 0.0, 0); } }
                    }
                    else {
                        options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
                    }
                    if (js_criterion.CRITERION.VPREF.length > 0) {
                        for (var cc in js_criterion.CRITERION.VPREF) {
                            options.items["fold3"].items[cc] = { "name": js_criterion.CRITERION.VPREF[cc].VIEW_CAPTION, callback: function (key, opt) {
                                var parameter_person_launch = '/PERSONID=' + uniquePersonArr[0] + ' /ENCNTRID=' + uniqueEncounterArr[0] + ' /FIRSTTAB=^' + js_criterion.CRITERION.VPREF[key].VIEW_CAPTION + '^'
                                APPLINK(0, "$APP_APPNAME$", parameter_person_launch)
                            }
                            }
                        }
                    }
                    else {
                        options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
                    }
                }
                if (uniquePersonArr.length > 1 && (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0)) {
                    options.items["Print Label(s)"] = { "name": amb_i18n.PRINT_LABELS, disabled: function (key, opt) { return true; } };
                }
                if (pwxdata.ALLOW_REQ_PRINT == 0 || uniquePersonArr.length > 1) {
                    options.items["fold2"] = { "name": amb_i18n.PRINT_REQ, disabled: function (key, opt) { return true; } };
                }

                if (taskInfo[0].length > 1) {
                    options.items["Reschedule"] = { "name": amb_i18n.RESCHEDULE, disabled: function (key, opt) { return true; } };
                }
                else {
                    //check reschedule
                    var time_check = pwx_get_selected_reflab_resched_time_limit('dl.pwx_row_selected');
                    if (time_check[0] < 1 || taskInfo[2] == 1) {
                        options.items["Reschedule"] = { "name": amb_i18n.RESCHEDULE, disabled: function (key, opt) { return true; } };
                    }
                }
                if (can_not_chart_found == 1) {
                    options.items["Done"] = { "name": amb_i18n.DONE, disabled: function (key, opt) { return true; } };
                    options.items["Not Done"] = { "name": amb_i18n.NOT_DONE, disabled: function (key, opt) { return true; } };
                    options.items["Reschedule"] = { "name": amb_i18n.RESCHEDULE, disabled: function (key, opt) { return true; } };
                }
            }
            else if (pwx_reflab_type_view == 2) {
                if (pwx_reflab_collection_type_view == '2') {
                    var options = {
                        items: {
                            "Transmit": { "name": amb_i18n.TRANSMIT, callback: function (key, opt) { $('#pwx_transfer_btn_cntrl').trigger('click') } },
                            "sep1": "---------",
                            "fold2": { "name": amb_i18n.PRINT_REQ,
                                //"name": "Print Requisitions&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                                "items": {
                                    "Selected Accession(s)": { "name": amb_i18n.SELECTED_ACC, callback: function (key, opt) {
                                        var ccllinkparams = '^MINE^,^' + orderIdlist + '^,' + 0 + ',' + js_criterion.CRITERION.PRSNL_ID + '.0';
                                        window.location = "javascript:CCLLINK('amb_cust_mp_reflab_call_labreq','" + ccllinkparams + "',0)";
                                    }
                                    },
                                    "Visit Accession(s)": { "name": amb_i18n.VISIT_ACC, callback: function (key, opt) {
                                        var ccllinkparams = '^MINE^,^^,' + uniqueEncounterArr[0] + ',' + js_criterion.CRITERION.PRSNL_ID + '.0';
                                        window.location = "javascript:CCLLINK('amb_cust_mp_reflab_call_labreq','" + ccllinkparams + "',0)";
                                    }
                                    }

                                }
                            },
                            "sep3": "---------",
                            "fold1": {
                                //"name": "Chart Forms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                                "name": amb_i18n.CHART_FORMS,
                                "items": {},
                                disabled: false
                            },
                            "sep4": "---------",
                            "Select All": { "name": amb_i18n.SELECT_ALL, callback: function (key, opt) { pwx_select_all('pwx_row_selected'); pwx_reflab_selectall_check() } },
                            "Deselect All": { "name": amb_i18n.DESELECT_ALL, callback: function (key, opt) { pwx_deselect_all('pwx_row_selected'); pwx_reflab_selectall_check() } },
                            "sep5": "---------",
                            "fold3": {
                                //"name": "Chart Forms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                                "name": amb_i18n.OPEN_PT_CHART,
                                "items": {},
                                disabled: false
                            }
                        }
                    };
                    if (transButtonOn == 0) {
                        options.items["Transmit"] = { "name": amb_i18n.TRANSMIT, disabled: function (key, opt) { return true; } };
                    }
                    if (uniqueEncounterArr.length > 1) {
                        options.items["fold2"].items["Visit Accession(s)"] = { "name": amb_i18n.VISIT_ACC, disabled: function (key, opt) { return true; } };
                        options.items["fold2"].items["Selected Accession(s)"] = { "name": amb_i18n.SELECTED_ACC, disabled: function (key, opt) { return true; } };
                        options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
                        options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
                    } else {
                        if (pwxdata.FORMSLIST.length > 0) {
                            for (var cc in pwxdata.FORMSLIST) {
                                options.items["fold1"].items[cc + "|forms"] = { "name": pwxdata.FORMSLIST[cc].FORM_NAME, callback: function (key, opt) { var keyArr = key.split("|"); pwx_form_launch(uniquePersonArr[0], uniqueEncounterArr[0], pwxdata.FORMSLIST[keyArr[0]].FORM_ID, 0.0, 0); } }
                            }
                            options.items["fold1"].items["Forms Menu"] = { "name": amb_i18n.ALL_FORMS, "className": "pwx_link_blue", callback: function (key, opt) { pwx_form_launch(uniquePersonArr[0], uniqueEncounterArr[0], 0.0, 0.0, 0); } }
                        }
                        else {
                            options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
                        }
                        if (js_criterion.CRITERION.VPREF.length > 0) {
                            for (var cc in js_criterion.CRITERION.VPREF) {
                                options.items["fold3"].items[cc] = { "name": js_criterion.CRITERION.VPREF[cc].VIEW_CAPTION, callback: function (key, opt) {
                                    var parameter_person_launch = '/PERSONID=' + uniquePersonArr[0] + ' /ENCNTRID=' + uniqueEncounterArr[0] + ' /FIRSTTAB=^' + js_criterion.CRITERION.VPREF[key].VIEW_CAPTION + '^'
                                    APPLINK(0, "$APP_APPNAME$", parameter_person_launch)
                                }
                                }
                            }
                        }
                        else {
                            options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
                        }
                    }
                    if (pwxdata.ALLOW_REQ_PRINT == 0 || uniquePersonArr.length > 1) {
                        options.items["fold2"] = { "name": amb_i18n.PRINT_REQ, disabled: function (key, opt) { return true; } };
                    }
                }
                else {
                    var options = {
                        items: {
                            "Transmit": { "name": amb_i18n.TRANSMIT, callback: function (key, opt) { $('#pwx_transfer_btn_cntrl').trigger('click') } },
                            "sep1": "---------",
                            "Unchart": { "name": amb_i18n.UNCHART, callback: function (key, opt) {
                                var unchartHTML = '<p class="pwx_small_text">';
                                var unchartArr = pwx_get_selected_reflab_unchart_data('dl.pwx_row_selected');
                                unchartHTML += amb_i18n.SELECT_UNCHART + ':';
                                for (var cc = 0; cc < unchartArr.length; cc++) {
                                    unchartHTML += '<br /><input type="checkbox" checked="checked" name="pwx_unchart_tasks" value="' + unchartArr[cc][1] + '" />' + unchartArr[cc][0];
                                }
                                unchartHTML += '</p>';
                                MP_ModalDialog.deleteModalDialogObject("UnchartTaskModal")
                                var unChartTaskModal = new ModalDialog("UnchartTaskModal")
                                .setHeaderTitle(amb_i18n.UNCHART_TASK)
                                .setTopMarginPercentage(20)
                                .setRightMarginPercentage(35)
                                .setBottomMarginPercentage(20)
                                .setLeftMarginPercentage(35)
                                .setIsBodySizeFixed(true)
                                .setHasGrayBackground(true)
                                .setIsFooterAlwaysShown(true);
                                unChartTaskModal.setBodyDataFunction(
                            function (modalObj) {
                                modalObj.setBodyHTML('<div style="padding-top:10px;">' + unchartHTML + '</div>');
                            });
                                var unchartbtn = new ModalButton("UnchartTask");
                                unchartbtn.setText(amb_i18n.UNCHART).setCloseOnClick(true).setOnClickFunction(function () {
                                    var taskidObj = $("input[name='pwx_unchart_tasks']:checked").map(function () { return $(this).val(); });
                                    var taskAr = jQuery.makeArray(taskidObj);
                                    taskIdlist = taskAr.join(',');
                                    if (taskIdlist != "") {
                                        PWX_CCL_Request_Task_Unchart('amb_cust_srv_task_unchart', taskIdlist, js_criterion.CRITERION.PRSNL_ID, '', '3', false);
                                    }
                                });
                                var closebtn = new ModalButton("unchartCancel");
                                closebtn.setText(amb_i18n.CANCEL).setCloseOnClick(true);
                                unChartTaskModal.addFooterButton(unchartbtn)
                                unChartTaskModal.addFooterButton(closebtn)
                                MP_ModalDialog.addModalDialogObject(unChartTaskModal);
                                MP_ModalDialog.showModalDialog("UnchartTaskModal")
                                $('input[name="pwx_unchart_tasks"]').on('change', function (event) {
                                    var any_checked = 0;
                                    $('input[name="pwx_unchart_tasks"]').each(function (index) {
                                        if ($(this).prop("checked") == true) {
                                            any_checked = 1;
                                        }
                                    });
                                    if (any_checked == 0) {
                                        unChartTaskModal.setFooterButtonDither("UnchartTask", true);
                                    }
                                    else {
                                        unChartTaskModal.setFooterButtonDither("UnchartTask", false);
                                    }
                                });
                            }
                            },
                            "sep2": "---------",
                            "Print Label(s)": { "name": amb_i18n.PRINT_LABELS, callback: function (key, opt) {
                                if (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0) {
                                    var taskSuccess = pwx_task_label_print_launch(uniquePersonArr[0], taskIdlist);
                                }
                                else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRA") {
                                    var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                                    orderIdlist = orderInfo.join(',');
                                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRA_LABEL','" + ccllinkparams + "',0)";
                                }
                                else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRASMALL") {
                                    var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                                    orderIdlist = orderInfo.join(',');
                                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRASMALL','" + ccllinkparams + "',0)";
                                }
                                else {
                                    var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                                    orderIdlist = orderInfo.join(',');
                                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_DYMO_LABEL','" + ccllinkparams + "',0)";
                                }
                            }
                            },

                            "fold2": { "name": amb_i18n.PRINT_REQ,
                                //"name": "Print Requisitions&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                                "items": {
                                    "Selected Accession(s)": { "name": amb_i18n.SELECTED_ACC, callback: function (key, opt) {
                                        var ccllinkparams = '^MINE^,^' + orderIdlist + '^,' + 0 + ',' + js_criterion.CRITERION.PRSNL_ID + '.0';
                                        window.location = "javascript:CCLLINK('amb_cust_mp_reflab_call_labreq','" + ccllinkparams + "',0)";
                                    }
                                    },
                                    "Visit Accession(s)": { "name": amb_i18n.VISIT_ACC, callback: function (key, opt) {
                                        var ccllinkparams = '^MINE^,^^,' + uniqueEncounterArr[0] + ',' + js_criterion.CRITERION.PRSNL_ID + '.0';
                                        window.location = "javascript:CCLLINK('amb_cust_mp_reflab_call_labreq','" + ccllinkparams + "',0)";
                                    }
                                    }

                                }
                            },
                            "sep3": "---------",
                            "fold1": {
                                //"name": "Chart Forms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                                "name": amb_i18n.CHART_FORMS,
                                "items": {},
                                disabled: false
                            },
                            "sep4": "---------",
                            "Select All": { "name": amb_i18n.SELECT_ALL, callback: function (key, opt) { pwx_select_all('pwx_row_selected'); pwx_reflab_selectall_check() } },
                            "Deselect All": { "name": amb_i18n.DESELECT_ALL, callback: function (key, opt) { pwx_deselect_all('pwx_row_selected'); pwx_reflab_selectall_check() } },
                            "sep5": "---------",
                            "fold3": {
                                //"name": "Chart Forms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                                "name": amb_i18n.OPEN_PT_CHART,
                                "items": {},
                                disabled: false
                            }
                        }
                    };
                    if (transButtonOn == 0) {
                        options.items["Transmit"] = { "name": amb_i18n.TRANSMIT, disabled: function (key, opt) { return true; } };
                    }
                    if (uniqueEncounterArr.length > 1) {
                        options.items["fold2"].items["Visit Accession(s)"] = { "name": amb_i18n.VISIT_ACC, disabled: function (key, opt) { return true; } };
                        options.items["fold2"].items["Selected Accession(s)"] = { "name": amb_i18n.SELECTED_ACC, disabled: function (key, opt) { return true; } };
                        options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
                        options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
                    } else {
                        if (pwxdata.FORMSLIST.length > 0) {
                            for (var cc in pwxdata.FORMSLIST) {
                                options.items["fold1"].items[cc + "|forms"] = { "name": pwxdata.FORMSLIST[cc].FORM_NAME, callback: function (key, opt) { var keyArr = key.split("|"); pwx_form_launch(uniquePersonArr[0], uniqueEncounterArr[0], pwxdata.FORMSLIST[keyArr[0]].FORM_ID, 0.0, 0); } }
                            }
                            options.items["fold1"].items["Forms Menu"] = { "name": amb_i18n.ALL_FORMS, "className": "pwx_link_blue", callback: function (key, opt) { pwx_form_launch(uniquePersonArr[0], uniqueEncounterArr[0], 0.0, 0.0, 0); } }
                        }
                        else {
                            options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
                        }
                        if (js_criterion.CRITERION.VPREF.length > 0) {
                            for (var cc in js_criterion.CRITERION.VPREF) {
                                options.items["fold3"].items[cc] = { "name": js_criterion.CRITERION.VPREF[cc].VIEW_CAPTION, callback: function (key, opt) {
                                    var parameter_person_launch = '/PERSONID=' + uniquePersonArr[0] + ' /ENCNTRID=' + uniqueEncounterArr[0] + ' /FIRSTTAB=^' + js_criterion.CRITERION.VPREF[key].VIEW_CAPTION + '^'
                                    APPLINK(0, "$APP_APPNAME$", parameter_person_launch)
                                }
                                }
                            }
                        }
                        else {
                            options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
                        }
                    }
                    if (uniquePersonArr.length > 1 && (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0)) {
                        options.items["Print Label(s)"] = { "name": amb_i18n.PRINT_LABELS, disabled: function (key, opt) { return true; } };
                    }
                    if (pwxdata.ALLOW_REQ_PRINT == 0 || uniquePersonArr.length > 1) {
                        options.items["fold2"] = { "name": amb_i18n.PRINT_REQ, disabled: function (key, opt) { return true; } };
                    }

                    if (taskInfo[0].length > 1 || can_not_chart_found == 1) {
                        options.items["Unchart"] = { "name": amb_i18n.UNCHART, disabled: function (key, opt) { return true; } };
                    }
                }
            }
            else if (pwx_reflab_type_view == 3) {
                if (pwx_reflab_collection_type_view == '2') {
                    var options = {
                        items: {
                            "fold2": { "name": amb_i18n.PRINT_REQ,
                                //"name": "Print Requisitions&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                                "items": {
                                    "Selected Accession(s)": { "name": amb_i18n.SELECTED_ACC, callback: function (key, opt) {
                                        var ccllinkparams = '^MINE^,^' + orderIdlist + '^,' + 0 + ',' + js_criterion.CRITERION.PRSNL_ID + '.0';
                                        window.location = "javascript:CCLLINK('amb_cust_mp_reflab_call_labreq','" + ccllinkparams + "',0)";
                                    }
                                    },
                                    "Visit Accession(s)": { "name": amb_i18n.VISIT_ACC, callback: function (key, opt) {
                                        var ccllinkparams = '^MINE^,^^,' + uniqueEncounterArr[0] + ',' + js_criterion.CRITERION.PRSNL_ID + '.0';
                                        window.location = "javascript:CCLLINK('amb_cust_mp_reflab_call_labreq','" + ccllinkparams + "',0)";
                                    }
                                    }

                                }
                            },
                            "sep3": "---------",
                            "fold1": {
                                //"name": "Chart Forms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                                "name": amb_i18n.CHART_FORMS,
                                "items": {},
                                disabled: false
                            },
                            "sep4": "---------",
                            "Select All": { "name": amb_i18n.SELECT_ALL, callback: function (key, opt) { pwx_select_all('pwx_row_selected'); pwx_reflab_selectall_check() } },
                            "Deselect All": { "name": amb_i18n.DESELECT_ALL, callback: function (key, opt) { pwx_deselect_all('pwx_row_selected'); pwx_reflab_selectall_check() } },
                            "sep5": "---------",
                            "fold3": {
                                //"name": "Chart Forms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                                "name": amb_i18n.OPEN_PT_CHART,
                                "items": {},
                                disabled: false
                            }
                        }
                    };
                    if (uniqueEncounterArr.length > 1) {
                        options.items["fold2"].items["Visit Accession(s)"] = { "name": amb_i18n.VISIT_ACC, disabled: function (key, opt) { return true; } };
                        options.items["fold2"].items["Selected Accession(s)"] = { "name": amb_i18n.SELECTED_ACC, disabled: function (key, opt) { return true; } };
                        options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
                        options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
                    } else {
                        if (pwxdata.FORMSLIST.length > 0) {
                            for (var cc in pwxdata.FORMSLIST) {
                                options.items["fold1"].items[cc + "|forms"] = { "name": pwxdata.FORMSLIST[cc].FORM_NAME, callback: function (key, opt) { var keyArr = key.split("|"); pwx_form_launch(uniquePersonArr[0], uniqueEncounterArr[0], pwxdata.FORMSLIST[keyArr[0]].FORM_ID, 0.0, 0); } }
                            }
                            options.items["fold1"].items["Forms Menu"] = { "name": amb_i18n.ALL_FORMS, "className": "pwx_link_blue", callback: function (key, opt) { pwx_form_launch(uniquePersonArr[0], uniqueEncounterArr[0], 0.0, 0.0, 0); } }
                        }
                        else {
                            options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
                        }
                        if (js_criterion.CRITERION.VPREF.length > 0) {
                            for (var cc in js_criterion.CRITERION.VPREF) {
                                options.items["fold3"].items[cc] = { "name": js_criterion.CRITERION.VPREF[cc].VIEW_CAPTION, callback: function (key, opt) {
                                    var parameter_person_launch = '/PERSONID=' + uniquePersonArr[0] + ' /ENCNTRID=' + uniqueEncounterArr[0] + ' /FIRSTTAB=^' + js_criterion.CRITERION.VPREF[key].VIEW_CAPTION + '^'
                                    APPLINK(0, "$APP_APPNAME$", parameter_person_launch)
                                }
                                }
                            }
                        }
                        else {
                            options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
                        }
                    }
                    if (pwxdata.ALLOW_REQ_PRINT == 0 || uniquePersonArr.length > 1) {
                        options.items["fold2"] = { "name": amb_i18n.PRINT_REQ, disabled: function (key, opt) { return true; } };
                    }
                }
                else {
                    var options = {
                        items: {
                            "Print Pickup List(s)": { "name": amb_i18n.PRINT_PICKUP, callback: function (key, opt) {
                                var transferlistFull = $('dl.pwx_content_row.pwx_row_selected').find('span.pwx_reflab_hidden_trans_id').map(function () {
                                    return $(this).text() + ".0";
                                })
                                var transferlistFullArr = jQuery.makeArray(transferlistFull);
                                var uniqueListArr = $.distinct(transferlistFullArr);
                                var ccllinkparams = '^MINE^,^' + uniqueListArr.join(",") + '^'
                                window.location = "javascript:CCLLINK('amb_cust_reflab_transfer_list','" + ccllinkparams + "',0)";
                            }
                            },
                            "Print Label(s)": { "name": amb_i18n.PRINT_LABELS, callback: function (key, opt) {
                                if (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0) {
                                    var taskSuccess = pwx_task_label_print_launch(uniquePersonArr[0], taskIdlist);
                                }
                                else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRA") {
                                    var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                                    orderIdlist = orderInfo.join(',');
                                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRA_LABEL','" + ccllinkparams + "',0)";
                                }
                                else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRASMALL") {
                                    var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                                    orderIdlist = orderInfo.join(',');
                                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRASMALL','" + ccllinkparams + "',0)";
                                }
                                else {
                                    var orderInfo = pwx_get_selected_order_id('dl.pwx_row_selected');
                                    orderIdlist = orderInfo.join(',');
                                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_DYMO_LABEL','" + ccllinkparams + "',0)";
                                }
                                $('dl.pwx_row_selected').removeClass('pwx_row_selected')
                            }
                            },
                            "fold2": { "name": amb_i18n.PRINT_REQ,
                                //"name": "Print Requisitions&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                                "items": {
                                    "Selected Accession(s)": { "name": amb_i18n.SELECTED_ACC, callback: function (key, opt) {
                                        var ccllinkparams = '^MINE^,^' + orderIdlist + '^,' + 0 + ',' + js_criterion.CRITERION.PRSNL_ID + '.0';
                                        window.location = "javascript:CCLLINK('amb_cust_mp_reflab_call_labreq','" + ccllinkparams + "',0)";
                                    }
                                    },
                                    "Visit Accession(s)": { "name": amb_i18n.VISIT_ACC, callback: function (key, opt) {
                                        var ccllinkparams = '^MINE^,^^,' + uniqueEncounterArr[0] + ',' + js_criterion.CRITERION.PRSNL_ID + '.0';
                                        window.location = "javascript:CCLLINK('amb_cust_mp_reflab_call_labreq','" + ccllinkparams + "',0)";
                                    }
                                    }

                                }
                            },
                            "sep3": "---------",
                            "fold1": {
                                //"name": "Chart Forms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                                "name": "Chart Forms",
                                "items": {},
                                disabled: false
                            },
                            "sep4": "---------",
                            "Select All": { "name": amb_i18n.SELECT_ALL, callback: function (key, opt) { pwx_select_all('pwx_row_selected'); pwx_reflab_selectall_check() } },
                            "Deselect All": { "name": amb_i18n.DESELECT_ALL, callback: function (key, opt) { pwx_deselect_all('pwx_row_selected'); pwx_reflab_selectall_check() } },
                            "sep5": "---------",
                            "fold3": {
                                //"name": "Chart Forms&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;",
                                "name": amb_i18n.OPEN_PT_CHART,
                                "items": {},
                                disabled: false
                            }
                        }
                    };
                    if (uniqueEncounterArr.length > 1) {
                        options.items["fold2"].items["Visit Accession(s)"] = { "name": amb_i18n.VISIT_ACC, disabled: function (key, opt) { return true; } };
                        options.items["fold2"].items["Selected Accession(s)"] = { "name": amb_i18n.SELECTED_ACC, disabled: function (key, opt) { return true; } };
                        options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
                        options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
                    } else {
                        if (pwxdata.FORMSLIST.length > 0) {
                            for (var cc in pwxdata.FORMSLIST) {
                                options.items["fold1"].items[cc + "|forms"] = { "name": pwxdata.FORMSLIST[cc].FORM_NAME, callback: function (key, opt) { var keyArr = key.split("|"); pwx_form_launch(uniquePersonArr[0], uniqueEncounterArr[0], pwxdata.FORMSLIST[keyArr[0]].FORM_ID, 0.0, 0); } }
                            }
                            options.items["fold1"].items["Forms Menu"] = { "name": amb_i18n.ALL_FORMS, "className": "pwx_link_blue", callback: function (key, opt) { pwx_form_launch(uniquePersonArr[0], uniqueEncounterArr[0], 0.0, 0.0, 0); } }
                        }
                        else {
                            options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
                        }
                        if (js_criterion.CRITERION.VPREF.length > 0) {
                            for (var cc in js_criterion.CRITERION.VPREF) {
                                options.items["fold3"].items[cc] = { "name": js_criterion.CRITERION.VPREF[cc].VIEW_CAPTION, callback: function (key, opt) {
                                    var parameter_person_launch = '/PERSONID=' + uniquePersonArr[0] + ' /ENCNTRID=' + uniqueEncounterArr[0] + ' /FIRSTTAB=^' + js_criterion.CRITERION.VPREF[key].VIEW_CAPTION + '^'
                                    APPLINK(0, "$APP_APPNAME$", parameter_person_launch)
                                }
                                }
                            }
                        }
                        else {
                            options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
                        }
                    }
                    if (uniquePersonArr.length > 1 && (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0)) {
                        options.items["Print Label(s)"] = { "name": amb_i18n.PRINT_LABELS, disabled: function (key, opt) { return true; } };
                    }
                    if (pwxdata.ALLOW_REQ_PRINT == 0 || uniquePersonArr.length > 1) {
                        options.items["fold2"] = { "name": amb_i18n.PRINT_REQ, disabled: function (key, opt) { return true; } };
                    }
                }

            }
            return options;
        }
    });

    framecontentElem.on('click', 'span.pwx_fcr_content_type_detail_icon_dt', function (e) {
        $(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected').addClass('pwx_row_selected');
        var json_index = $(this).children('span.pwx_task_json_index_hidden').text()
        var task_detailText = [];
        task_detailText.push('<div class="pwx_modal_person_banner"><span class="pwx_modal_person_banner_name">', pwxdata.TLIST[json_index].PERSON_NAME, '</span>')
        task_detailText.push('<span class="pwx_modal_person_banner_details">',amb_i18n.DOB,':&nbsp;', pwxdata.TLIST[json_index].DOB, '</span>')
        task_detailText.push('<span class="pwx_modal_person_banner_details">',amb_i18n.AGE,':&nbsp;', pwxdata.TLIST[json_index].AGE, '</span>')
        task_detailText.push('<span class="pwx_modal_person_banner_details">',amb_i18n.GENDER,':&nbsp;', pwxdata.TLIST[json_index].GENDER, '</span>')
        task_detailText.push('</div></br></br>')
        task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.ORDERED_AS,' (', pwxdata.TLIST[json_index].ORDER_CNT, '):</dt><dd>', pwxdata.TLIST[json_index].ORDERED_AS_NAME, '</dd></dl>');
        task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.ACCESSION_NUM,':</dt><dd>', pwxdata.TLIST[json_index].ASC_NUM, '</dd></dl>');
        if (pwxdata.TLIST[json_index].COLLECTED_IND == 1) {
			if(pwxdata.TLIST[json_index].TASK_DT_TM_UTC != "" && pwxdata.TLIST[json_index].TASK_DT_TM_UTC != "TZ") {
				var taskUTCDate = new Date();
				taskUTCDate.setISO8601(pwxdata.TLIST[json_index].TASK_DT_TM_UTC);
				task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.TASK_DATE,':</dt><dd>', taskUTCDate.format("longDateTime4"), '</dd></dl>');
			} else {
				task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.TASK_DATE,':</dt><dd>--</dd></dl>');
			}
        }
        task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.TYPE,':</dt><dd>', pwxdata.TLIST[json_index].ACTIVITY_SUB_TYPE, '</dd></dl>');
		if(pwxdata.TLIST[json_index].VISIT_DT_UTC != "" && pwxdata.TLIST[json_index].VISIT_DT_UTC != "TZ") {
			var visitUTCDate = new Date();
			visitUTCDate.setISO8601(pwxdata.TLIST[json_index].VISIT_DT_UTC);
			task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.VISIT_DATE_LOC,':</dt><dd>', visitUTCDate.format("shortDate3"), ' | ', pwxdata.TLIST[json_index].VISIT_LOC, '</dd></dl>');
		} else {
			task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.VISIT_DATE_LOC,':</dt><dd>-- | ', pwxdata.TLIST[json_index].VISIT_LOC, '</dd></dl>');
		}
        if (pwx_reflab_type_view == 3) {
			if (pwxdata.TLIST[json_index].COLLECTED_IND == 2) {
				if(pwxdata.TLIST[json_index].CONTAIN_LIST[0]) {
					if(pwxdata.TLIST[json_index].CONTAIN_LIST[0].COLLECTED_DT_UTC != "" && pwxdata.TLIST[json_index].CONTAIN_LIST[0].COLLECTED_DT_UTC != "TZ") {
						var collectUTCDate = new Date();
						collectUTCDate.setISO8601(pwxdata.TLIST[json_index].CONTAIN_LIST[0].COLLECTED_DT_UTC);
						task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.COLLECTED_DATE,':</dt><dd>', collectUTCDate.format("shortDate3"), '</dd></dl>');
					}
				}
			}
            task_detailText.push('<dl class="pwx_task_detail_line" style="padding-top:5px;"><dt class="pwx_no_wrap"><span class="pwx_order_info_title pwx_semi_bold">',amb_i18n.TRANSMIT_DETAILS,'</span></dt><div class="pwx_sub_sub-sec-hd">&nbsp;</div></dl>');
			if(pwxdata.TLIST[json_index].TRANSFER_DT_TM_UTC != "" && pwxdata.TLIST[json_index].TRANSFER_DT_TM_UTC != "TZ") {
				var transferUTCDate = new Date();
				transferUTCDate.setISO8601(pwxdata.TLIST[json_index].TRANSFER_DT_TM_UTC);
				task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.TRANSMIT_DATE,':</dt><dd>', transferUTCDate.format("longDateTime4"), '</dd></dl>')
			} else {
				task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.TRANSMIT_DATE,':</dt><dd>--</dd></dl>')
			}
            task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.SYSTEM_TRANS_INFO,':</dt><dd>',amb_i18n.LIST_NUM,' ', pwxdata.TLIST[json_index].TRANSFER_LIST_NUM, ', ',amb_i18n.ID,':', pwxdata.TLIST[json_index].TRANSFER_LIST_ID, '</dd></dl>')
            task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.LAB,':</dt><dd>', pwxdata.TLIST[json_index].TRANSFER_TO_LOC, '</dd></dl>')
            task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.TRANSMITTED_BY,':</dt><dd>', pwxdata.TLIST[json_index].TRANSFERRED_BY, '</dd></dl>')
        }
        else if (pwx_reflab_type_view == 2 && pwxdata.TLIST[json_index].COLLECTED_IND == 1) {
            task_detailText.push('<dl class="pwx_task_detail_line" style="padding-top:5px;"><dt class="pwx_no_wrap"><span class="pwx_order_info_title pwx_semi_bold">',amb_i18n.COLLECTION_DETAILS,'</span></dt><div class="pwx_sub_sub-sec-hd">&nbsp;</div></dl>');
            task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad hvr_table"><table><tr><th>',amb_i18n.CONTAINER,'</th><th>',amb_i18n.COLLECTED_DATE,'</th><th>',amb_i18n.COLLECTED_BY,'</th></tr>')
            for (var cc = 0; cc < pwxdata.TLIST[json_index].CONTAIN_LIST.length; cc++) {
				if(pwxdata.TLIST[json_index].CONTAIN_LIST[cc].COLLECTED_DT_UTC != "" && pwxdata.TLIST[json_index].CONTAIN_LIST[cc].COLLECTED_DT_UTC != "TZ") {
					var collectUTCDate = new Date();
					collectUTCDate.setISO8601(pwxdata.TLIST[json_index].CONTAIN_LIST[cc].COLLECTED_DT_UTC);
					task_detailText.push('<tr><td>', pwxdata.TLIST[json_index].CONTAIN_LIST[cc].CONTAIN_SENT, '</td><td>', collectUTCDate.format("longDateTime4"), '</td><td>', pwxdata.TLIST[json_index].CONTAIN_LIST[cc].COLLECTED_BY, '</td></tr>')
				} else {
					task_detailText.push('<tr><td>', pwxdata.TLIST[json_index].CONTAIN_LIST[cc].CONTAIN_SENT, '</td><td>--</td><td>', pwxdata.TLIST[json_index].CONTAIN_LIST[cc].COLLECTED_BY, '</td></tr>')
				}
            }
            task_detailText.push('</table></dl>')
        } else if (pwx_reflab_type_view == 2 && pwxdata.TLIST[json_index].COLLECTED_IND == 2) {
			if(pwxdata.TLIST[json_index].CONTAIN_LIST[0]) {
				if(pwxdata.TLIST[json_index].CONTAIN_LIST[0].COLLECTED_DT_UTC != "" && pwxdata.TLIST[json_index].CONTAIN_LIST[0].COLLECTED_DT_UTC != "TZ") {
					var collectUTCDate = new Date();
					collectUTCDate.setISO8601(pwxdata.TLIST[json_index].CONTAIN_LIST[0].COLLECTED_DT_UTC);
					task_detailText.push('<dl class="pwx_task_detail_line"><dt>',amb_i18n.COLLECTED_DATE,':</dt><dd>', collectUTCDate.format("shortDate3"), '</dd></dl>');
				}
			}
		}
        for (var y = 0; y < pwxdata.TLIST[json_index].OLIST.length; y++) {
            task_detailText.push('<dl class="pwx_task_detail_line" style="padding-top:5px;"><dt class="pwx_no_wrap"><span class="pwx_order_info_title"><span class="pwx_semi_bold">',amb_i18n.ORDER,' ', (y + 1), ':</span>&nbsp;', pwxdata.TLIST[json_index].OLIST[y].ORDER_NAME, '</span></dt><div class="pwx_sub_sub-sec-hd">&nbsp;</div></dl>');
			if(pwxdata.TLIST[json_index].ORDER_DT_TM_UTC != "" && pwxdata.TLIST[json_index].ORDER_DT_TM_UTC != "TZ") {
			var orderUTCDate = new Date();
			orderUTCDate.setISO8601(pwxdata.TLIST[json_index].ORDER_DT_TM_UTC);
			task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDERED_DATE,':</dt><dd>', orderUTCDate.format("longDateTime4"), '</dd></dl>');
			} else {
				task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDERED_DATE,':</dt><dd>--</dd></dl>');
			}
            task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDERING_PROV,':</dt><dd>', pwxdata.TLIST[json_index].OLIST[y].ORDERING_PROV, '</dd></dl>');
            task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.ORDER_ID,':</dt><dd>', pwxdata.TLIST[json_index].OLIST[y].ORDER_ID, '</dd></dl>');
            if (pwx_reflab_type_view == 3) {
                task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.RESULTS_REC,':</dt><dd>')
                if (pwxdata.TLIST[json_index].OLIST[y].RESULTS_IND == 1) {
                    task_detailText.push(amb_i18n.YES);
                } else {
                    task_detailText.push(amb_i18n.NO);
                }
                task_detailText.push('</dd></dl>');
            }
            task_detailText.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad"><dt>',amb_i18n.DIAGNOSIS,' (', pwxdata.TLIST[json_index].OLIST[y].DLIST.length, '):</dt>');
            if (pwxdata.TLIST[json_index].OLIST[y].DLIST.length > 0) {
                task_detailText.push('<dd>&nbsp;</dd></dl>');
                task_detailText.push('<dl class="pwx_task_detail_line"><dt>&nbsp;</dt><dd class="pwx_normal_line_height pwx_extra_small_text pwx_hvr_order_info_diag_pad">');
                for (var cc = 0; cc < pwxdata.TLIST[json_index].OLIST[y].DLIST.length; cc++) {
                    if (cc > 0) {
                        task_detailText.push('<br />');
                    }
                    if (pwxdata.TLIST[json_index].OLIST[y].DLIST[cc].CODE != '') {
                        task_detailText.push(pwxdata.TLIST[json_index].OLIST[y].DLIST[cc].DIAG, '<span class="pwx_grey"> (', pwxdata.TLIST[json_index].OLIST[y].DLIST[cc].CODE, ')</span>');
                    }
                    else {
                        task_detailText.push(pwxdata.TLIST[json_index].OLIST[y].DLIST[cc].DIAG);
                    }
                }
                task_detailText.push('</dd></dl>');
            }
            else {
                task_detailText.push('<dd>--</dd></dl>');
            }
        }
        MP_ModalDialog.deleteModalDialogObject("TaskDetailModal")
        var taskDetailModal = new ModalDialog("TaskDetailModal")
             .setHeaderTitle(amb_i18n.ORDER_DETAILS)
             .setTopMarginPercentage(10)
             .setRightMarginPercentage(20)
             .setBottomMarginPercentage(10)
             .setLeftMarginPercentage(20)
             .setIsBodySizeFixed(true)
             .setHasGrayBackground(true)
             .setIsFooterAlwaysShown(true);
        taskDetailModal.setBodyDataFunction(
             function (modalObj) {
                 modalObj.setBodyHTML('<div class="pwx_task_detail_no_pad">' + task_detailText.join("") + '</div>');
             });
        var closebtn = new ModalButton("addCancel");
        closebtn.setText(amb_i18n.CLOSE).setCloseOnClick(true);
        taskDetailModal.addFooterButton(closebtn)
        MP_ModalDialog.addModalDialogObject(taskDetailModal);
        MP_ModalDialog.showModalDialog("TaskDetailModal")
    });
    var pwxdialogHTML = []
    //create the reschedule modal
    pwxdialogHTML.push('<div id="pwx-resched-dialog-confirm"><p class="pwx_small_text"><label for="pwx_resched_dt_tm"><span style="vertical-align:30%;">',amb_i18n.RESCHEDULED_TO,': </span><input type="text" id="pwx_resched_dt_tm" name="pwx_resched_dt_tm" style="width: 125px; height:14px;" /></label></p></div>');
    $('#pwx_frame_filter_bar').after(pwxdialogHTML.join(""))


    $("#pwx-resched-dialog-confirm").dialog({
        resizable: false,
        height: 200,
        modal: true,
        autoOpen: false,
        title: amb_i18n.RESCHEDULE_TASK,
        buttons: [
            {
                text: amb_i18n.RESCHEDULE,
                id: "pwx-reschedule-btn",
                disabled: true,
                click: function () {
                    var real_date = Date.parse($("#pwx_resched_dt_tm").datetimepicker('getDate'))
                    var string_date = real_date.toString("MM/dd/yyyy HH:mm")
                    var resched_dt_tm = string_date.split(" ");
                    PWX_CCL_Request_Task_Reschedule('amb_cust_srv_task_reschedule', reschedule_TaskIds, resched_dt_tm[0], resched_dt_tm[1], false);
                    $(this).dialog("close");
                }
            },
            {
                text: amb_i18n.CANCEL,
                click: function () {
                    $(this).dialog("close");
                }
            }
        ]
    });
    $("#pwx_resched_dt_tm").datetimepicker({
        dateFormat: "mm/dd/yy",
        showOn: "focus",
        changeMonth: true,
        changeYear: true,
        showButtonPanel: true,
        ampm: true,
        timeFormat: "hh:mmtt",
        onSelect: function (dateText, inst) {
            if (dateText != "") {
                $('#pwx-reschedule-btn').button('enable')
            }
        }
    });
    framecontentElem.on('click', 'span.pwx-icon_submenu_arrow-icon.pwx_task_need_chart_menu', function (event) {
        pwx_reflab_submenu_clicked_row_elem = $(this).parents('dl.pwx_content_row')
        pwx_reflab_submenu_clicked_task_id = $(pwx_reflab_submenu_clicked_row_elem).children('span.pwx_task_id_hidden').html()  + ".0";
        pwx_reflab_submenu_clicked_order_id = $(pwx_reflab_submenu_clicked_row_elem).children('dt.pwx_task_order_id_hidden').html()  + ".0";
        pwx_reflab_submenu_clicked_person_id = $(pwx_reflab_submenu_clicked_row_elem).children('dt.pwx_person_id_hidden').html()  + ".0";
        $(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected')
        $('#pwx_task_chart_done_menu').css('display', 'none');
        var dt_pos = $(this).position();
        var test_var = document.documentElement.offsetHeight;
        var scrolled_bottom_var = $(document).scrollTop() + test_var
        if (($(this).offset().top + 40) > scrolled_bottom_var) {
            $('#pwx_task_chart_menu').css('top', dt_pos.top - 40);
        }
        else {
            $('#pwx_task_chart_menu').css('top', dt_pos.top);
        }
        $('#pwx_task_chart_menu').css('display', 'block');
    });

    framecontentElem.on('click', 'span.pwx-lab_task-icon.pwx_pointer_cursor', function (e) {
        cur_task_id = $(this).parents('dl.pwx_content_row').children('span.pwx_task_id_hidden').html() + ".0";
        cur_person_id = $(this).parents('dl.pwx_content_row').children('dt.pwx_person_id_hidden').html() + ".0";
        var taskSuccess = pwx_task_launch(cur_person_id, cur_task_id, 'CHART');
        $(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected')
        if (taskSuccess == true) {
            var dlHeight = $(this).parents('dl.pwx_content_row').height()
            $(this).siblings('div.pwx_fcr_content_action_bar').css('backgroundColor', '#87C854').css('height', dlHeight).attr("title", amb_i18n.CHARTED_DONE_REFRESH)
            if (pwxdata.LABEL_PRINT_AUTO_OFF != "1") {
                if (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0) {
                    var taskSuccess = pwx_task_label_print_launch(cur_person_id, cur_task_id);
                }
                else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRA") {
                    var orderIdlist = $(this).parents('dl.pwx_content_row').children('dt.pwx_task_order_id_hidden').html();
                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRA_LABEL','" + ccllinkparams + "',0)";
                }
                else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRASMALL") {
                    var orderIdlist = $(this).parents('dl.pwx_content_row').children('dt.pwx_task_order_id_hidden').html();
                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRASMALL','" + ccllinkparams + "',0)";
                }
                else {
                    var orderIdlist = $(this).parents('dl.pwx_content_row').children('dt.pwx_task_order_id_hidden').html();
                    var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                    window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_DYMO_LABEL','" + ccllinkparams + "',0)";
                }
            }
            if (pwxdata.AUTOLOG_SPEC_IND == 1) { setTimeout(function () { PWX_CCL_Request_Specimen_Login("amb_cust_call_spec_auto_loc", cur_task_id, true) }, 1000); }
        }
    });

    framecontentElem.on('click', 'span.pwx_fcr_content_type_personname_dt a', function () {
        var parentelement = $(this).parents('dt.pwx_fcr_content_person_dt')
        var parentpersonid = $(parentelement).siblings('.pwx_person_id_hidden').text()
        var parentencntridid = $(parentelement).siblings('.pwx_encounter_id_hidden').text()
        var parameter_person_launch = '/PERSONID=' + parentpersonid + ' /ENCNTRID=' + parentencntridid + ' /FIRSTTAB=^^'
        APPLINK(0, "$APP_APPNAME$", parameter_person_launch)
    });

    framecontentElem.on('click', 'span.pwx_reflab_relogin_lab', function (e) {
        var logintaskId = $(this).parents('dl.pwx_content_row').children('span.pwx_task_id_hidden').html() + ".0";
        PWX_CCL_Request_Specimen_Login("amb_cust_call_spec_auto_loc", logintaskId, true)
        setTimeout(function () { $('#pwx_task_list_refresh_icon').trigger('click') }, 1000);
    });
    framecontentElem.on('click', 'span.pwx_reflab_remove_trans_list', function (e) {
        var transListId = parseFloat($(this).children('span.pwx_reflab_hidden_trans_id').html())
        var containerObj = $(this).parents('dl.pwx_content_row').children('dt.pwx_fcr_content_labname_dt').children('div.pwx_task_lab_container_hidden').children('.pwx_task_lab_containid_hidden').map(function () {
            return $(this).text() + ".0";
        })
        var containerArr = jQuery.makeArray(containerObj);
        MP_DCP_REFLAB_REMOVE_FROM_LIST_Request("amb_cust_rmv_from_trans_list", transListId, containerArr.join(","), true)
    });
    framecontentElem.on('click', 'span.pwx_reflab_retransfer_link', function (e) {
        var transListId = parseFloat($(this).children('span.pwx_reflab_hidden_trans_id').html())
        MP_DCP_REFLAB_RETRANSFER_Request("amb_cust_mp_reflab_retransfer", transListId, true)
    });
    framecontentElem.on('click', 'span.pwx_reflab_lab_results', function (e) {
        cur_person_id = $(this).parents('dl.pwx_content_row').children('dt.pwx_person_id_hidden').html();
        cur_encntr_id = $(this).parents('dl.pwx_content_row').children('dt.pwx_encounter_id_hidden').html();
        //var parameter_person_launch = '/PERSONID=' + cur_person_id + ' /ENCNTRID=' + cur_encntr_id + ' /FIRSTTAB=^Laboratory^'
        //APPLINK(0, "$APP_APPNAME$", parameter_person_launch)
        var resultorderId = $(this).parents('dl.pwx_content_row').children('dt.pwx_task_order_id_hidden').html() + ".0";
        var json_index = $(this).children('span.pwx_task_json_index_hidden').text()
        var pname = pwxdata.TLIST[json_index].PERSON_NAME
        var pdob = pwxdata.TLIST[json_index].DOB
        var pers_age = pwxdata.TLIST[json_index].AGE
        var pgender = pwxdata.TLIST[json_index].GENDER
        MP_DCP_REFLAB_GET_ORDER_RESULTS_Request("amb_cust_mp_get_order_results", resultorderId, cur_person_id, pname, pdob, pers_age, pgender, true)
        $(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected')
    });
    framecontentElem.on('click', 'span.pwx_reflab_retransfer_success_link', function (e) {
        var transListId = parseFloat($(this).children('span.pwx_reflab_hidden_trans_id').html())
        MP_DCP_REFLAB_GET_LIST_DETAILS_Request("amb_cust_reflab_tranlist_dets", transListId, true)
    });
    //ABN launch link
    framecontentElem.on('click', 'dt.pwx_fcr_content_col_abn_dt', function () {
        // show dialog
        var abnProgramName = '';
        var trackId = $(this).children('.pwx_abn_track_id_hidden').text()
        var jsonId = $(this).children('.pwx_abn_json_id_hidden').text()
        var abnHTML = []
        abnHTML.push('<div class="pwx_modal_person_banner"><span class="pwx_modal_person_banner_name">', pwxdata.TLIST[jsonId].PERSON_NAME, '</span>')
        abnHTML.push('<span class="pwx_modal_person_banner_details">',amb_i18n.DOB,':&nbsp;', pwxdata.TLIST[jsonId].DOB, '</span>')
        abnHTML.push('<span class="pwx_modal_person_banner_details">',amb_i18n.AGE,':&nbsp;', pwxdata.TLIST[jsonId].AGE, '</span>')
        abnHTML.push('<span class="pwx_modal_person_banner_details">',amb_i18n.GENDER,':&nbsp;', pwxdata.TLIST[jsonId].GENDER, '</span>')
        abnHTML.push('</div>')
        abnHTML.push('<p class="pwx_small_text hvr_table"><span style="vertical-align:30%;">' + amb_i18n.ABN_TEMPLATE + ': </span><select id="abn_programs" name="abn_programs" multiple="multiple">')
        for (var cc = 0; cc < pwxdata.ABN_FORM_LIST.length; cc++) {
            abnHTML.push('<option value="' + pwxdata.ABN_FORM_LIST[cc].PROGRAM_NAME + '">' + pwxdata.ABN_FORM_LIST[cc].PROGRAM_DESC + '</option>');
        }
        abnHTML.push('</select></br></br>');
        abnHTML.push('<table width="95%" ><tr><th>' + amb_i18n.ORDER + '</th><th>' + amb_i18n.ALERT_DATE + '</th><th>' + amb_i18n.ALERT_STATE + '</th></tr>');
        for (var cc = 0; cc < pwxdata.TLIST[jsonId].ABN_LIST.length; cc++) {
            abnHTML.push('<tr><td class="abn_order_mne">' + pwxdata.TLIST[jsonId].ABN_LIST[cc].ORDER_DISP + '</td><td class="abn_alert_date">' + pwxdata.TLIST[jsonId].ABN_LIST[cc].ALERT_DATE +
            '</td><td class="abn_alert_state">' + pwxdata.TLIST[jsonId].ABN_LIST[cc].ALERT_STATE + '</td></tr>');
        }
        abnHTML.push('</table></p>');
        //build the drop down
        MP_ModalDialog.deleteModalDialogObject("ABNModal")
        var abnModal = new ModalDialog("ABNModal")
                                .setHeaderTitle(amb_i18n.ABN)
                                .setTopMarginPercentage(15)
                                .setRightMarginPercentage(25)
                                .setBottomMarginPercentage(15)
                                .setLeftMarginPercentage(25)
                                .setIsBodySizeFixed(true)
                                .setHasGrayBackground(true)
                                .setIsFooterAlwaysShown(true);
        abnModal.setBodyDataFunction(
                            function (modalObj) {
                                modalObj.setBodyHTML('<div class="pwx_task_detail_no_pad">' + abnHTML.join("") + '</div>');
                            });
        var printbtn = new ModalButton("PrintABN");
        printbtn.setText(amb_i18n.VIEW).setCloseOnClick(true).setIsDithered(true).setOnClickFunction(function () {
            var ccllinkparams = '^MINE^,^' + trackId + '^,^' + abnProgramName + '^';
            window.location = "javascript:CCLLINK('amb_cust_abn_print_wrapper','" + ccllinkparams + "',0)";
        });
        var closebtn = new ModalButton("abnCancel");
        closebtn.setText(amb_i18n.CANCEL).setCloseOnClick(true);
        abnModal.addFooterButton(printbtn)
        abnModal.addFooterButton(closebtn)
        MP_ModalDialog.addModalDialogObject(abnModal);
        MP_ModalDialog.showModalDialog("ABNModal")
        $("#abn_programs").multiselect({
            //height: loc_height,
            header: false,
            multiple: false,
            //minWidth: "250",
            classes: "pwx_select_box",
            noneSelectedText: amb_i18n.ABN_SELECT,
            selectedList: 1
        });
        $("#abn_programs").on("multiselectclick", function (event, ui) {
            abnProgramName = ui.value
            abnModal.setFooterButtonDither("PrintABN", false);
        })
        $(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected').addClass('pwx_row_selected');
    })
    var end_delegate_event_timer = new Date();
    delegate_event_timer = (end_delegate_event_timer - start_delegate_event_timer) / 1000

}

function RenderRefLabListContent(pwxdata) {
	var framecontentElem =  $('#pwx_frame_content')
    $.contextMenu('destroy', 'span.pwx_fcr_content_type_person_icon_dt');
	pwx_clear_patient_focus();
    var start_content_timer = new Date();
    $('#pwx_task_filterbar_page_prev').html("")
    $('#pwx_task_filterbar_page_prev').off()
    $('#pwx_task_filterbar_page_next').html("")
    $('#pwx_task_filterbar_page_next').off()
    $('#pwx_reflab_collection_filter input').off()
    $('#pwx_reflab_tolocation_filter').empty()
    //build the content
    var js_criterion = JSON.parse(m_criterionJSON);
    var pwxcontentHTML = [];
    if (pwxdata.TLIST.length > 0) {
        //if viw = 3 create the transferred layout otherwise use the collection layout for in/out of office
        if (pwx_reflab_type_view == 3) {
            //icon type
            if (pwx_reflab_trans_sort_ind == '1') {
                var sort_icon = 'pwx-sort_up-icon';
            }
            else {
                var sort_icon = 'pwx-sort_down-icon';
            }
            //make the header
            pwxcontentHTML.push('<div id="pwx_frame_content_rows_header"><dl id="pwx_frame_rows_header_dl">');
            if (pwx_reflab_trans_header_id == 'pwx_fcr_header_personname_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_personname_dt">',amb_i18n.PATIENT,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_personname_dt">',amb_i18n.PATIENT,'</dt>');
            }
            if (pwx_reflab_trans_header_id == 'pwx_fcr_trans_header_labname_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_trans_header_labname_dt">',amb_i18n.ORDER,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_trans_header_labname_dt">',amb_i18n.ORDER,'</dt>');
            }
            if (pwx_reflab_trans_header_id == 'pwx_fcr_trans_header_orderdate_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_trans_header_orderdate_dt">',amb_i18n.ORDERED,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_trans_header_orderdate_dt">',amb_i18n.ORDERED,'</dt>');
            }
            if (pwx_reflab_trans_header_id == 'pwx_fcr_trans_header_tolocation_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_trans_header_tolocation_dt">',amb_i18n.LAB,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_trans_header_tolocation_dt">',amb_i18n.LAB,'</dt>');
            }
            if (pwx_reflab_trans_header_id == 'pwx_fcr_trans_header_transdate_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_trans_header_transdate_dt">',amb_i18n.TRANSMIT_DATE,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_trans_header_transdate_dt">',amb_i18n.TRANSMIT_DATE,'</dt>');
            }
            pwxcontentHTML.push('<dt id="pwx_fcr_header_action_dt"><span style="padding-left:5px;">',amb_i18n.STATUS,'</span></dt>');
            pwxcontentHTML.push('<dt id="pwx_fcr_header_col_abn_dt">',amb_i18n.ABN,'</dt>');
            pwxcontentHTML.push('</dl></div>');
			pwxcontentHTML.push('<div id="pwx_frame_content_rows">');
            var pwx_row_color = ''
            var row_cnt = 0;
            var pagin_active = 0;
            var end_of_reflab_list = 0;
            json_reflab_start_number = json_reflab_end_number;
            if (reflab_list_curpage > json_reflab_page_start_numbersAr.length) {
                json_reflab_page_start_numbersAr.push(json_reflab_start_number)
            }
            for (var i = json_reflab_end_number; i < pwxdata.TLIST.length; i++) {

                var task_row_visable = '';
                var task_row_zebra_type = '';
                if (pwx_reflab_to_location_filterApplied == 1) {
                    var toLocationMatch = 0;
                    for (var cc = 0; cc < pwx_reflab_to_location_filterArr.length; cc++) {
                        if (pwx_reflab_to_location_filterArr[cc] == pwxdata.TLIST[i].TRANSFER_TO_LOC) {
                            toLocationMatch = 1;
                            break;
                        }
                    }
                }
                else {
                    var toLocationMatch = 1;
                }
                var resultMatch = 1;
                if (pwx_reflab_result_filter == "Pending") {
                    if (pwxdata.TLIST[i].RESULTS_IND == 1) {
                        resultMatch = 0;
                    }
                }
                else if (pwx_reflab_result_filter == "Results") {
                    if (pwxdata.TLIST[i].RESULTS_IND == 0) {
                        resultMatch = 0;
                    }
                }
                if (pwxdata.TLIST[i].LAB_IND == pwx_reflab_type_view && pwxdata.TLIST[i].COLLECTED_IND == pwx_reflab_collection_type_view && toLocationMatch == 1 && resultMatch == 1) {
                    if (pwx_isOdd(row_cnt) == 1) {
                        task_row_zebra_type = " pwx_zebra_dark "
                    }
                    else {
                        task_row_zebra_type = " pwx_zebra_light "
                    }
                    row_cnt++
                    pwxcontentHTML.push('<dl class="pwx_content_row', task_row_zebra_type, '">');
                    pwxcontentHTML.push('<dt class="pwx_encounter_id_hidden">', pwxdata.TLIST[i].ENCOUNTER_ID, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_person_id_hidden">', pwxdata.TLIST[i].PERSON_ID, '</dt>');
					pwxcontentHTML.push('<dt class="pwx_person_name_hidden">', pwxdata.TLIST[i].PERSON_NAME, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_task_order_id_hidden">', pwxdata.TLIST[i].ORDER_ID, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_task_resched_time_hidden">', pwxdata.TLIST[i].TASK_RESCHED_TIME, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_task_lab_notchart_hidden">', pwxdata.TLIST[i].NOT_DONE, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_task_canchart_hidden">', pwxdata.TLIST[i].CAN_CHART_IND, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_reflab_type_hidden">', pwxdata.TLIST[i].COLLECTED_IND, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_reflab_recieved_hidden">', pwxdata.TLIST[i].RECIEVED_IND, '</dt>');
					if(pwxdata.TLIST[i].TASK_DT_TM_UTC != ""  && pwxdata.TLIST[i].TASK_DT_TM_UTC != "TZ") {
						var taskUTCDate = new Date();
						taskUTCDate.setISO8601(pwxdata.TLIST[i].TASK_DT_TM_UTC);
						pwxcontentHTML.push('<dt class="pwx_fcr_reflab_taskdate_hidden">', taskUTCDate.format("longDateTime4"), '</dt>');
					} else {
						pwxcontentHTML.push('<dt class="pwx_fcr_reflab_taskdate_hidden"></dt>');
					}
                    var containerHTML = []
                    var task_row_lines = '';
                    var task_id_collect = '';
                    for (var cc = 0; cc < pwxdata.TLIST[i].CONTAIN_LIST.length; cc++) {
                        containerHTML.push('<div class="pwx_task_lab_container_hidden">');
                        containerHTML.push('<span class="pwx_task_lab_line_text_hidden">', pwxdata.TLIST[i].CONTAIN_LIST[cc].CONTAIN_SENT, '</span>');
                        containerHTML.push('<span class="pwx_task_lab_taskid_hidden">', pwxdata.TLIST[i].CONTAIN_LIST[cc].TASK_ID, '</span>');
                        containerHTML.push('<span class="pwx_task_lab_containid_hidden">', pwxdata.TLIST[i].CONTAIN_LIST[cc].CONTAINER_ID, '</span>');
                        containerHTML.push('</div>');
                        containerHTML.push('<div class="pwx_leftpad_20 pwx_grey pwx_lab_container_line_div">', pwxdata.TLIST[i].CONTAIN_LIST[cc].CONTAIN_SENT, '</div>');
                        task_row_lines += '<br />&nbsp;';
                        if (cc == 0) {
                            task_id_collect += pwxdata.TLIST[i].CONTAIN_LIST[cc].TASK_ID;
                        }
                        else {
                            task_id_collect += "," + pwxdata.TLIST[i].CONTAIN_LIST[cc].TASK_ID;
                        }
                    }
                    //add italic class if inprocess;
                    pwxcontentHTML.push('<dt class="pwx_fcr_content_person_dt pwx_no_border_left"><span class="pwx_fcr_content_type_personname_dt"><a title="',amb_i18n.OPEN_PT_CHART,'" class="pwx_result_link_bold">',
                    pwxdata.TLIST[i].PERSON_NAME, '</a><span class="pwx_grey pwx_extra_small_text">&nbsp;&nbsp;', pwxdata.TLIST[i].AGE, ' ', pwxdata.TLIST[i].GENDER_CHAR, '</span></span>');
                    pwxcontentHTML.push('<span class="pwx_fcr_content_type_person_icon_dt" title="',amb_i18n.VIEW_PT_DETAILS,'"><span class="pwx_task_json_index_hidden">', i, '</span><span class="pwx-line_menu-icon"></span></span>');
                    if (task_row_lines == '<br />&nbsp;') { var lineheightVar = 17 } else { var lineheightVar = 16 };
                    pwxcontentHTML.push('<span style="line-height:' + lineheightVar + 'px;">', task_row_lines, '</span></dt>');
                    pwxcontentHTML.push('<dt class="pwx_fcr_trans_content_labname_dt " ><span class="pwx_fcr_content_type_ordname_dt">', pwxdata.TLIST[i].ORDERED_AS_NAME);
                    pwxcontentHTML.push('</span><span class="pwx_grey pwx_fcr_content_type_ascname_dt">', pwxdata.TLIST[i].ASC_NUM, '</span><span class="pwx_fcr_content_type_detail_icon_dt" title="',amb_i18n.VIEW_TASK_DETAILS,'"><span class="pwx_task_json_index_hidden">', i, '</span><span class="ui-icon ui-icon-carat-1-e"></span></span>');
                    pwxcontentHTML.push(containerHTML.join(""));
                    pwxcontentHTML.push('</dt><span class="pwx_task_id_hidden">', task_id_collect, '</span>');
					if(pwxdata.TLIST[i].ORDER_DT_TM_UTC != "" && pwxdata.TLIST[i].ORDER_DT_TM_UTC != "TZ") {
						var orderUTCDate = new Date();
						orderUTCDate.setISO8601(pwxdata.TLIST[i].ORDER_DT_TM_UTC);
						pwxcontentHTML.push('<dt class="pwx_fcr_trans_content_orderdate_dt"><span style="padding-bottom:2px;">', orderUTCDate.format("shortDate3"), ' ', task_row_lines, '</span></dt>');
					} else {
						pwxcontentHTML.push('<dt class="pwx_fcr_trans_content_orderdate_dt"><span style="padding-bottom:2px;">-- ', task_row_lines, '</span></dt>');
					}
                    pwxcontentHTML.push('<dt class="pwx_fcr_trans_content_tolocation_dt">');
                    pwxcontentHTML.push(pwxdata.TLIST[i].TRANSFER_TO_LOC, task_row_lines);
                    pwxcontentHTML.push('</dt>');
                    pwxcontentHTML.push('<dt class="pwx_fcr_trans_content_transdate_dt">');
					if(pwxdata.TLIST[i].TRANSFER_DT_TM_UTC != "" && pwxdata.TLIST[i].TRANSFER_DT_TM_UTC != "TZ") {
						var transferUTCDate = new Date();
						transferUTCDate.setISO8601(pwxdata.TLIST[i].TRANSFER_DT_TM_UTC);
						pwxcontentHTML.push(transferUTCDate.format("longDateTime4"), task_row_lines);
					} else {
						pwxcontentHTML.push('--', task_row_lines);
					}
                    pwxcontentHTML.push('</dt>');
                    var readytoTrans = 0;
                    pwxcontentHTML.push('<dt class="pwx_fcr_content_action_dt">');
                    if (pwxdata.TLIST[i].RESULTS_IND == 1) {
                        pwxcontentHTML.push('<span class="pwx_fcr_content_action_indicator_dt pwx_reflab_ready_trans"></span><span class="pwx_fcr_content_action_move_dt"><span class="pwx_reflab_lab_results"><a class="pwx_blue_link">',amb_i18n.RESULTS_REC,'</a><span class="pwx_task_json_index_hidden" style="display:none !important;">', i, '</span></span></span>');
                    }
                    else if (pwxdata.TLIST[i].RESULTS_IND == 2) {
                        pwxcontentHTML.push('<span class="pwx_fcr_content_action_indicator_dt pwx_reflab_warning_trans"></span><span class="pwx_fcr_content_action_move_dt"><span class="pwx_reflab_lab_results"><a class="pwx_blue_link">',amb_i18n.PARTIAL_RESULTS,'</a><span class="pwx_task_json_index_hidden" style="display:none !important;">', i, '</span></span></span>');
                    }
                    else {
                        if (pwxdata.TLIST[i].OUTBOUND_IND == 1) {
							if (pwxdata.ALLOW_TRANSFER_IND == 1) {
								pwxcontentHTML.push('<span class="pwx_fcr_content_action_indicator_dt"></span><span class="pwx_fcr_content_action_move_dt"><span>',amb_i18n.TRANSMITTED,'</span></br><span class="pwx_reflab_retransfer_success_link"><a class="pwx_blue_link">',amb_i18n.RETRANSMIT,'</a><span class="pwx_reflab_hidden_trans_id" style="display:none;">', pwxdata.TLIST[i].TRANSFER_LIST_ID, '</span></span></span>');
							} else {
								pwxcontentHTML.push('<span class="pwx_fcr_content_action_indicator_dt"></span><span class="pwx_fcr_content_action_move_dt"><span>',amb_i18n.TRANSMITTED,'</span></span>');
							}
						}
                        else {
							if (pwxdata.ALLOW_TRANSFER_IND == 1) {
								pwxcontentHTML.push('<span class="pwx_fcr_content_action_indicator_dt pwx_reflab_unable_trans"></span><span class="pwx_fcr_content_action_move_dt" ><span title="',amb_i18n.ORDER_NOT_TRANS,'">',amb_i18n.NOT_TRANSMITTED,'</span></br><span class="pwx_reflab_retransfer_link"><a class="pwx_blue_link">',amb_i18n.RETRANSMIT,'</a><span class="pwx_reflab_hidden_trans_id" style="display:none;">', pwxdata.TLIST[i].TRANSFER_LIST_ID, '</span></span></span>');
							} else {
								pwxcontentHTML.push('<span class="pwx_fcr_content_action_indicator_dt pwx_reflab_unable_trans"></span><span class="pwx_fcr_content_action_move_dt" ><span title="',amb_i18n.ORDER_NOT_TRANS,'">',amb_i18n.NOT_TRANSMITTED,'</span></span>');
							}
						}
                    }
                    if (pwxdata.TLIST[i].ABN_LIST.length > 0) {
                        pwxcontentHTML.push('<dt class="pwx_fcr_content_col_abn_dt" title="',amb_i18n.ABN_TOOLTIP,'"><span style="display:none" class="pwx_abn_track_id_hidden">', pwxdata.TLIST[i].ABN_TRACK_IDS, '</span><span style="display:none" class="pwx_abn_json_id_hidden">', i, '</span><span class="pwx-abn-icon"></span></dt>');
                    }
                    else {
                        pwxcontentHTML.push('<dt class="pwx_fcr_content_col_abn_dt"></dt>')
                    }

                    pwxcontentHTML.push('</dt>');
                    pwxcontentHTML.push('<dt class="pwx_reflab_trans_ind" style="display:none;">', readytoTrans, '</dt>');
                    pwxcontentHTML.push('</dl>');
                }
                if (i + 1 == pwxdata.TLIST.length) {
                    end_of_reflab_list = 1;
                }
                if (row_cnt == 100) {
                    json_reflab_end_number = i + 1; //add one to start on next one not displayed
                    pagin_active = 1;
                    break;
                }
            }
            if (row_cnt == 0) {
                pwxcontentHTML.push('<dl class="pwx_content_noresfilter_row"><span class="pwx_noresult_text">',amb_i18n.SELECTED_FILTERS_NO_LABS,'</span></dl>');
            }

            if (row_cnt == 0) {
                $('#pwx_frame_rows_header_dl').after('<dl class="pwx_content_noresfilter_row"><span class="pwx_noresult_text">',amb_i18n.SELECTED_FILTERS_NO_LABS,'</span></dl>');
            }

        }
        else if (pwx_reflab_type_view == 2) {
            //icon type
            if (pwx_reflab_sort_ind == '1') {
                var sort_icon = 'pwx-sort_up-icon';
            }
            else {
                var sort_icon = 'pwx-sort_down-icon';
            }
            //make the header
            pwxcontentHTML.push('<div id="pwx_frame_content_rows_header"><dl id="pwx_frame_rows_header_dl">');
            if (pwx_reflab_header_id == 'pwx_fcr_header_personname_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_personname_dt">',amb_i18n.PATIENT,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_personname_dt">',amb_i18n.PATIENT,'</dt>');
            }
            if (pwx_reflab_header_id == 'pwx_fcr_header_labname_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_labname_dt">',amb_i18n.ORDER,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_labname_dt">',amb_i18n.ORDER,'</dt>');
            }
            if (pwx_reflab_header_id == 'pwx_fcr_header_orderdate_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_orderdate_dt">',amb_i18n.ORDER_DATE,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_orderdate_dt">',amb_i18n.ORDER_DATE,'</dt>');
            }
            if (pwx_reflab_header_id == 'pwx_fcr_header_subtype_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_subtype_dt">',amb_i18n.TYPE,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_subtype_dt">',amb_i18n.TYPE,'</dt>');
            }
            pwxcontentHTML.push('<dt id="pwx_fcr_header_action_dt"><span style="padding-left:5px;">',amb_i18n.STATUS,'</span></dt>');
            pwxcontentHTML.push('<dt id="pwx_fcr_header_col_abn_dt">',amb_i18n.ABN,'</dt>');
            pwxcontentHTML.push('</dl></div>');
			pwxcontentHTML.push('<div id="pwx_frame_content_rows">');
            var pwx_row_color = ''
            var row_cnt = 0;
            var pagin_active = 0;
            var end_of_reflab_list = 0;
            json_reflab_start_number = json_reflab_end_number;
            if (reflab_list_curpage > json_reflab_page_start_numbersAr.length) {
                json_reflab_page_start_numbersAr.push(json_reflab_start_number)
            }
            for (var i = json_reflab_end_number; i < pwxdata.TLIST.length; i++) {

                var task_row_visable = '';
                var task_row_zebra_type = '';
                if (pwx_reflab_to_location_filterApplied == 1) {
                    var toLocationMatch = 0;
                    for (var cc = 0; cc < pwx_reflab_to_location_filterArr.length; cc++) {
                        for (var yy = 0; yy < pwxdata.TLIST[i].TRANS_LOC.length; yy++) {
                            if (pwx_reflab_to_location_filterArr[cc] == pwxdata.TLIST[i].TRANS_LOC[yy].LOCATION_DISP) {
                                toLocationMatch = 1;
                                break;
                            }
                        }
                        if (toLocationMatch == 1) {
                            break;
                        }
                    }
                }
                else {
                    var toLocationMatch = 1;
                }
                if (pwxdata.TLIST[i].LAB_IND == pwx_reflab_type_view && pwxdata.TLIST[i].COLLECTED_IND == pwx_reflab_collection_type_view && toLocationMatch == 1) {
                    if (pwx_isOdd(row_cnt) == 1) {
                        task_row_zebra_type = " pwx_zebra_dark "
                    }
                    else {
                        task_row_zebra_type = " pwx_zebra_light "
                    }
                    row_cnt++
                    pwxcontentHTML.push('<dl class="pwx_content_row', task_row_zebra_type, '">');
                    pwxcontentHTML.push('<dt class="pwx_encounter_id_hidden">', pwxdata.TLIST[i].ENCOUNTER_ID, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_person_id_hidden">', pwxdata.TLIST[i].PERSON_ID, '</dt>');
					pwxcontentHTML.push('<dt class="pwx_person_name_hidden">', pwxdata.TLIST[i].PERSON_NAME, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_task_order_id_hidden">', pwxdata.TLIST[i].ORDER_ID, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_task_resched_time_hidden">', pwxdata.TLIST[i].TASK_RESCHED_TIME, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_task_lab_notchart_hidden">', pwxdata.TLIST[i].NOT_DONE, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_task_canchart_hidden">', pwxdata.TLIST[i].CAN_CHART_IND, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_reflab_type_hidden">', pwxdata.TLIST[i].COLLECTED_IND, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_reflab_recieved_hidden">', pwxdata.TLIST[i].RECIEVED_IND, '</dt>');
					if(pwxdata.TLIST[i].TASK_DT_TM_UTC != "" && pwxdata.TLIST[i].TASK_DT_TM_UTC != "TZ") {
						var taskUTCDate = new Date();
						taskUTCDate.setISO8601(pwxdata.TLIST[i].TASK_DT_TM_UTC);
						pwxcontentHTML.push('<dt class="pwx_fcr_reflab_taskdate_hidden">', taskUTCDate.format("longDateTime4"), '</dt>');
					} else {
						pwxcontentHTML.push('<dt class="pwx_fcr_reflab_taskdate_hidden"></dt>');
					}
                    //add italic class if inprocess;
                    var labnameHTML = []
                    labnameHTML.push('<span class="pwx_fcr_content_type_ordname_dt">', pwxdata.TLIST[i].ORDERED_AS_NAME);
                    labnameHTML.push('</span><span class="pwx_grey pwx_fcr_content_type_ascname_dt">', pwxdata.TLIST[i].ASC_NUM, '</span><span class="pwx_fcr_content_type_detail_icon_dt" title="',amb_i18n.VIEW_TASK_DETAILS,'"><span class="pwx_task_json_index_hidden">', i, '</span><span class="ui-icon ui-icon-carat-1-e"></span></span>');
                    var task_row_lines = '';
                    var task_id_collect = '';
                    for (var cc = 0; cc < pwxdata.TLIST[i].CONTAIN_LIST.length; cc++) {
                        labnameHTML.push('<div class="pwx_task_lab_container_hidden">');
                        labnameHTML.push('<span class="pwx_task_lab_line_text_hidden">', pwxdata.TLIST[i].CONTAIN_LIST[cc].CONTAIN_SENT, '</span>');
                        labnameHTML.push('<span class="pwx_task_lab_taskid_hidden">', pwxdata.TLIST[i].CONTAIN_LIST[cc].TASK_ID, '</span>');
                        labnameHTML.push('<span class="pwx_task_lab_containid_hidden">', pwxdata.TLIST[i].CONTAIN_LIST[cc].CONTAINER_ID, '</span>');
                        labnameHTML.push('</div>');
                        labnameHTML.push('<div class="pwx_leftpad_20 pwx_grey pwx_lab_container_line_div">', pwxdata.TLIST[i].CONTAIN_LIST[cc].CONTAIN_SENT, '</div>');
                        task_row_lines += '<br />&nbsp;';
                        if (cc == 0) {
                            task_id_collect += pwxdata.TLIST[i].CONTAIN_LIST[cc].TASK_ID;
                        }
                        else {
                            task_id_collect += "," + pwxdata.TLIST[i].CONTAIN_LIST[cc].TASK_ID;
                        }
                    }
                    pwxcontentHTML.push('<dt class="pwx_fcr_content_person_dt pwx_no_border_left"><span class="pwx_fcr_content_type_personname_dt"><a title="',amb_i18n.OPEN_PT_CHART,'" class="pwx_result_link_bold">',
                    pwxdata.TLIST[i].PERSON_NAME, '</a><span class="pwx_grey pwx_extra_small_text">&nbsp;&nbsp;', pwxdata.TLIST[i].AGE, ' ', pwxdata.TLIST[i].GENDER_CHAR, '</span></span>');
                    pwxcontentHTML.push('<span class="pwx_fcr_content_type_person_icon_dt" title="',amb_i18n.VIEW_PT_DETAILS,'"><span class="pwx_task_json_index_hidden">', i, '</span><span class="pwx-line_menu-icon"></span></span>');
                    if (task_row_lines == '<br />&nbsp;') { var lineheightVar = 17 } else { var lineheightVar = 16 };
                    pwxcontentHTML.push('<span style="line-height:' + lineheightVar + 'px;">', task_row_lines, '</span></dt>');
                    pwxcontentHTML.push('<dt class="pwx_fcr_content_labname_dt " >', labnameHTML.join(""))
                    pwxcontentHTML.push('</dt><span class="pwx_task_id_hidden">', task_id_collect, '</span>');
					if(pwxdata.TLIST[i].ORDER_DT_TM_UTC != "" && pwxdata.TLIST[i].ORDER_DT_TM_UTC != "TZ") {
						var orderUTCDate = new Date();
						orderUTCDate.setISO8601(pwxdata.TLIST[i].ORDER_DT_TM_UTC);
						pwxcontentHTML.push('<dt class="pwx_fcr_content_orderdate_dt"><span style="padding-bottom:2px;">', orderUTCDate.format("longDateTime4"), ' ', task_row_lines, '</span></dt>');
					} else {
						pwxcontentHTML.push('<dt class="pwx_fcr_content_orderdate_dt"><span style="padding-bottom:2px;"> ', task_row_lines, '</span></dt>');
					}
                    pwxcontentHTML.push('<dt class="pwx_fcr_content_subtype_dt"><span style="padding-bottom:2px;">', pwxdata.TLIST[i].ACTIVITY_SUB_TYPE, task_row_lines, '</span></dt>');
                    var readytoTrans = 0;
                    pwxcontentHTML.push('<dt class="pwx_fcr_content_action_dt">');
                    if (pwxdata.TLIST[i].NO_LOGIN_LOCATION != 1) {
                        if (pwxdata.TLIST[i].NOT_LOGIN_LOC != 1) {
                            if (pwxdata.ALLOW_TRANSFER_IND == 1) {
                                if (pwxdata.TLIST[i].TRANSFER_LIST_ID == 0) {
                                    if (pwxdata.TLIST[i].TRANS_LOC.length > 0) {
                                        if (pwxdata.TLIST[i].TRANS_LOC.length == 1) {
                                            pwxcontentHTML.push('<span class="pwx_fcr_content_action_indicator_dt pwx_reflab_ready_trans" title="',amb_i18n.LAB_RDY_TRANS,'"></span><span class="pwx_fcr_content_action_move_dt"><span class="pwx_lab_transfer_link pwx_semi_bold" title="', pwxdata.TLIST[i].TRANS_LOC[0].LOCATION_DISP, '">',
                                             pwxdata.TLIST[i].TRANS_LOC[0].LOCATION_DISP, '</span><span class="pwx_reflab_to_location" style="display:none;">', pwxdata.TLIST[i].TRANS_LOC[0].SR_RESOURCE_CD, '</span></span>');
                                            readytoTrans = 1;
                                        }
                                        else {
                                            pwxcontentHTML.push('<span class="pwx_fcr_content_action_indicator_dt"></span><span class="pwx_fcr_content_action_move_dt"><span class="pwx_lab_transfer_link"><span class="pwx_lab_transfer_loc_multi pwx_pointer_cursor"><a class="pwx_blue_link">',amb_i18n.SELECT_LAB_LOC,'</a></span>')
                                            pwxcontentHTML.push('</span><span class="pwx_reflab_to_location" style="display:none;"></span><span style="display:none;" class="pwx_task_json_index_hidden">', i, '</span></span>');
                                        }
                                    }
                                    else {
                                        pwxcontentHTML.push('<span class="pwx_fcr_content_action_indicator_dt pwx_reflab_unable_trans"></span><span class="pwx_fcr_content_action_move_dt"><span title="',amb_i18n.NO_LAB_ASSOC,'">',amb_i18n.NO_LAB_LOC,'</span></span>');
                                    }
                                }
                                else {
                                    pwxcontentHTML.push('<span class="pwx_fcr_content_action_indicator_dt pwx_reflab_warning_trans"></span><span class="pwx_fcr_content_action_move_dt"><span title="',amb_i18n.CONTAINER_ON_TRANS_LIST,'">',amb_i18n.CONTAINER_EXIST_LIST,'</span></br><span class="pwx_reflab_remove_trans_list"><a class="pwx_blue_link">',amb_i18n.REMOVE_FROM_LIST,'</a><span class="pwx_reflab_hidden_trans_id" style="display:none;">', pwxdata.TLIST[i].TRANSFER_LIST_ID, '</span></span></span>');
                                }
                            }
                            else {
                                pwxcontentHTML.push('<span class="pwx_fcr_content_action_indicator_dt"></span><span class="pwx_fcr_content_action_move_dt">',amb_i18n.NOT_ALLOW_TRANS,'</span>');
                            }
                        }
                        else {
                            pwxcontentHTML.push('<span class="pwx_fcr_content_action_indicator_dt pwx_reflab_unable_trans"></span><span class="pwx_fcr_content_action_move_dt"><span title="',amb_i18n.SPEC_NOT_LOGIN_LOC_TOOLTIP,'">',amb_i18n.SPEC_NOT_LOGIN,'</span></br><span class="pwx_reflab_relogin_lab"><a class="pwx_blue_link">',amb_i18n.LOGIN_TO_SPEC_LOC,'</a></span></span>');
                        }
                    }
                    else {
                        pwxcontentHTML.push('<span class="pwx_fcr_content_action_indicator_dt pwx_reflab_unable_trans"></span><span class="pwx_fcr_content_action_move_dt"><span title="',amb_i18n.SPEC_NO_LAB_LOC,'">',amb_i18n.NO_DEFAULT_SPEC_LOC,'</span></span>');
                    }
                    pwxcontentHTML.push('</dt>');
                    if (pwxdata.TLIST[i].ABN_LIST.length > 0) {
                        pwxcontentHTML.push('<dt class="pwx_fcr_content_col_abn_dt" title="',amb_i18n.ABN_TOOLTIP,'"><span style="display:none" class="pwx_abn_track_id_hidden">', pwxdata.TLIST[i].ABN_TRACK_IDS, '</span><span style="display:none" class="pwx_abn_json_id_hidden">', i, '</span><span class="pwx-abn-icon"></span></dt>');
                    }
                    else {
                        pwxcontentHTML.push('<dt class="pwx_fcr_content_col_abn_dt"></dt>')
                    }


                    pwxcontentHTML.push('<dt class="pwx_reflab_trans_ind" style="display:none;">', readytoTrans, '</dt>');
                    pwxcontentHTML.push('</dl>');
                }
                if (i + 1 == pwxdata.TLIST.length) {
                    end_of_reflab_list = 1;
                }
                if (row_cnt == 100) {
                    json_reflab_end_number = i + 1; //add one to start on next one not displayed
                    pagin_active = 1;
                    break;
                }
            }
            if (row_cnt == 0) {
                pwxcontentHTML.push('<dl class="pwx_content_noresfilter_row"><span class="pwx_noresult_text">',amb_i18n.SELECTED_FILTERS_NO_LABS,'</span></dl>');
            }

            if (row_cnt == 0) {
                $('#pwx_frame_rows_header_dl').after('<dl class="pwx_content_noresfilter_row"><span class="pwx_noresult_text">',amb_i18n.SELECTED_FILTERS_NO_LABS,'</span></dl>');
            }
        }
        else if (pwx_reflab_type_view == 1) {
            //icon type
            if (pwx_reflab_coll_sort_ind == '1') {
                var sort_icon = 'pwx-sort_up-icon';
            }
            else {
                var sort_icon = 'pwx-sort_down-icon';
            }
            //make the header
            pwxcontentHTML.push('<div id="pwx_frame_content_rows_header"><dl id="pwx_frame_rows_header_dl"><dt id="pwx_fcr_header_labtype_icon_dt">&nbsp;</dt>');

            if (pwx_reflab_coll_header_id == 'pwx_fcr_header_personname_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_personname_dt">',amb_i18n.PATIENT,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_personname_dt">',amb_i18n.PATIENT,'</dt>');
            }
            if (pwx_reflab_coll_header_id == 'pwx_fcr_header_col_labname_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_col_labname_dt">',amb_i18n.ORDER,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_col_labname_dt">',amb_i18n.ORDER,'</dt>');
            }
            if (pwx_reflab_coll_header_id == 'pwx_fcr_header_orderdate_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_orderdate_dt">',amb_i18n.TASK_DATE,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_orderdate_dt">',amb_i18n.TASK_DATE,'</dt>');
            }
            if (pwx_reflab_coll_header_id == 'pwx_fcr_header_col_subtype_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_col_subtype_dt">',amb_i18n.TYPE,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_col_subtype_dt">',amb_i18n.TYPE,'</dt>');
            }
            if (pwx_reflab_coll_header_id == 'pwx_fcr_header_col_orderprov_dt') {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_col_orderprov_dt">',amb_i18n.ORDERING_PROV,'<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
            }
            else {
                pwxcontentHTML.push('<dt id="pwx_fcr_header_col_orderprov_dt">',amb_i18n.ORDERING_PROV,'</dt>');
            }
            pwxcontentHTML.push('<dt id="pwx_fcr_header_col_abn_dt">',amb_i18n.ABN,'</dt>');
            pwxcontentHTML.push('</dl></div>');
			pwxcontentHTML.push('<div id="pwx_frame_content_rows">');
			pwxcontentHTML.push('<div class="pwx_form-menu" id="pwx_task_chart_menu" style="display:none;"><a class="pwx_result_link" id="pwx_task_chart_link">',amb_i18n.DONE,'</a></br><a class="pwx_result_link" id="pwx_task_chart_not_done_link2">',amb_i18n.NOT_DONE,'</a></div>');
            var pwx_row_color = ''
            var row_cnt = 0;
            var pagin_active = 0;
            var end_of_reflab_list = 0;
            json_reflab_start_number = json_reflab_end_number;
            if (reflab_list_curpage > json_reflab_page_start_numbersAr.length) {
                json_reflab_page_start_numbersAr.push(json_reflab_start_number)
            }
            for (var i = json_reflab_end_number; i < pwxdata.TLIST.length; i++) {

                var task_row_visable = '';
                var task_row_zebra_type = '';
                if (pwxdata.TLIST[i].LAB_IND == pwx_reflab_type_view) {
                    if (pwx_isOdd(row_cnt) == 1) {
                        task_row_zebra_type = " pwx_zebra_dark "
                    }
                    else {
                        task_row_zebra_type = " pwx_zebra_light "
                    }
                    row_cnt++
                    pwxcontentHTML.push('<dl class="pwx_content_row', task_row_zebra_type, '">');
                    pwxcontentHTML.push('<dt class="pwx_encounter_id_hidden">', pwxdata.TLIST[i].ENCOUNTER_ID, '</dt>');
					pwxcontentHTML.push('<dt class="pwx_person_name_hidden">', pwxdata.TLIST[i].PERSON_NAME, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_person_id_hidden">', pwxdata.TLIST[i].PERSON_ID, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_task_order_id_hidden">', pwxdata.TLIST[i].ORDER_ID, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_task_resched_time_hidden">', pwxdata.TLIST[i].TASK_RESCHED_TIME, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_task_lab_notchart_hidden">', pwxdata.TLIST[i].NOT_DONE, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_task_canchart_hidden">', pwxdata.TLIST[i].CAN_CHART_IND, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_reflab_type_hidden">', pwxdata.TLIST[i].COLLECTED_IND, '</dt>');
                    pwxcontentHTML.push('<dt class="pwx_reflab_recieved_hidden">', pwxdata.TLIST[i].RECIEVED_IND, '</dt>');
					if(pwxdata.TLIST[i].TASK_DT_TM_UTC != "" && pwxdata.TLIST[i].TASK_DT_TM_UTC != "TZ") {
						var taskUTCDate = new Date();
						taskUTCDate.setISO8601(pwxdata.TLIST[i].TASK_DT_TM_UTC);
						pwxcontentHTML.push('<dt class="pwx_fcr_reflab_taskdate_hidden">', taskUTCDate.format("longDateTime4"), '</dt>');
					}
					else {
						pwxcontentHTML.push('<dt class="pwx_fcr_reflab_taskdate_hidden"></dt>');
					}
                    pwxcontentHTML.push('<dt class="pwx_fcr_content_type_icon_dt"><div class="pwx_fcr_content_action_bar">&nbsp;</div>');
                    //pwxcontentHTML.push('<dt class="pwx_fcr_content_labtype_icon_dt">');
                    if (pwxdata.TLIST[i].CAN_CHART_IND == 1) {
                        var taskmenuIcon = '<span class="pwx-icon_submenu_arrow-icon pwx_task_need_chart_menu">&nbsp;</span>';
                        pwxcontentHTML.push('<span class="pwx-lab_task-icon pwx_pointer_cursor" title="',amb_i18n.COLLECT_SPEC,'">&nbsp;</span>', taskmenuIcon);
                    }
                    else {
                        pwxcontentHTML.push('<span class="pwx-task_disabled-icon" title="',amb_i18n.ACTIONS_NOT_AVAIL,'">&nbsp;</span>');
                    }
                    pwxcontentHTML.push('</dt>');
                    //add italic class if inprocess;
                    var labnameHTML = []
                    labnameHTML.push('<span class="pwx_fcr_content_type_ordname_dt">', pwxdata.TLIST[i].ORDERED_AS_NAME);
                    labnameHTML.push('</span><span class="pwx_grey pwx_fcr_content_type_ascname_dt">', pwxdata.TLIST[i].ASC_NUM, '</span><span class="pwx_fcr_content_type_detail_icon_dt" title="',amb_i18n.VIEW_TASK_DETAILS,'"><span class="pwx_task_json_index_hidden">', i, '</span><span class="ui-icon ui-icon-carat-1-e"></span></span>');
                    var task_row_lines = '';
                    var task_id_collect = '';
                    for (var cc = 0; cc < pwxdata.TLIST[i].CONTAIN_LIST.length; cc++) {
                        labnameHTML.push('<div class="pwx_task_lab_container_hidden">');
                        labnameHTML.push('<span class="pwx_task_lab_line_text_hidden">', pwxdata.TLIST[i].CONTAIN_LIST[cc].CONTAIN_SENT, '</span>');
                        labnameHTML.push('<span class="pwx_task_lab_taskid_hidden">', pwxdata.TLIST[i].CONTAIN_LIST[cc].TASK_ID, '</span>');
                        labnameHTML.push('<span class="pwx_task_lab_containid_hidden">', pwxdata.TLIST[i].CONTAIN_LIST[cc].CONTAINER_ID, '</span>');
                        labnameHTML.push('</div>');
                        labnameHTML.push('<div class="pwx_leftpad_20 pwx_grey pwx_lab_container_line_div">', pwxdata.TLIST[i].CONTAIN_LIST[cc].CONTAIN_SENT, '</div>');
                        task_row_lines += '<br />&nbsp;';
                        if (cc == 0) {
                            task_id_collect += pwxdata.TLIST[i].CONTAIN_LIST[cc].TASK_ID;
                        }
                        else {
                            task_id_collect += "," + pwxdata.TLIST[i].CONTAIN_LIST[cc].TASK_ID;
                        }
                    }
                    pwxcontentHTML.push('<dt class="pwx_fcr_content_person_dt"><span class="pwx_fcr_content_type_personname_dt"><a title="',amb_i18n.OPEN_PT_CHART,'" class="pwx_result_link_bold">',
                    pwxdata.TLIST[i].PERSON_NAME, '</a><span class="pwx_grey pwx_extra_small_text">&nbsp;&nbsp;', pwxdata.TLIST[i].AGE, ' ', pwxdata.TLIST[i].GENDER_CHAR, '</span></span>');
                    pwxcontentHTML.push('<span class="pwx_fcr_content_type_person_icon_dt" title="',amb_i18n.VIEW_PT_DETAILS,'"><span class="pwx_task_json_index_hidden">', i, '</span><span class="pwx-line_menu-icon"></span></span>');
                    if (task_row_lines == '<br />&nbsp;') { var lineheightVar = 17 } else { var lineheightVar = 16 };
                    pwxcontentHTML.push('<span style="line-height:' + lineheightVar + 'px;">', task_row_lines, '</span></dt>');
                    pwxcontentHTML.push('<dt class="pwx_fcr_content_col_labname_dt " >', labnameHTML.join(""))
                    pwxcontentHTML.push('</dt><span class="pwx_task_id_hidden">', task_id_collect, '</span>');
					if(pwxdata.TLIST[i].TASK_DT_TM_UTC != "" && pwxdata.TLIST[i].TASK_DT_TM_UTC != "TZ") {
						var taskUTCDate = new Date();
						taskUTCDate.setISO8601(pwxdata.TLIST[i].TASK_DT_TM_UTC);
						pwxcontentHTML.push('<dt class="pwx_fcr_content_orderdate_dt"><span style="padding-bottom:2px;">', taskUTCDate.format("longDateTime4"), ' ', task_row_lines, '</span></dt>');
					}
					else {
						pwxcontentHTML.push('<dt class="pwx_fcr_content_orderdate_dt"><span style="padding-bottom:2px;">-- ', task_row_lines, '</span></dt>');
					}
                    pwxcontentHTML.push('<dt class="pwx_fcr_content_col_subtype_dt"><span style="padding-bottom:2px;">', pwxdata.TLIST[i].ACTIVITY_SUB_TYPE, task_row_lines, '</span></dt>');
                    pwxcontentHTML.push('<dt class="pwx_fcr_content_col_orderprov_dt"><span style="padding-bottom:2px;">', pwxdata.TLIST[i].ORDERING_PROVIDER, task_row_lines, '</span></dt>');
                    if (pwxdata.TLIST[i].ABN_LIST.length > 0) {
                        pwxcontentHTML.push('<dt class="pwx_fcr_content_col_abn_dt" title="',amb_i18n.ABN_TOOLTIP,'"><span style="display:none" class="pwx_abn_track_id_hidden">', pwxdata.TLIST[i].ABN_TRACK_IDS, '</span><span style="display:none" class="pwx_abn_json_id_hidden">', i, '</span><span class="pwx-abn-icon"></span></dt>');
                    }
                    else {
                        pwxcontentHTML.push('<dt class="pwx_fcr_content_col_abn_dt"></dt>')
                    }
                    pwxcontentHTML.push('</dl>');
                }
                if (i + 1 == pwxdata.TLIST.length) {
                    end_of_reflab_list = 1;
                }
                if (row_cnt == 100) {
                    json_reflab_end_number = i + 1; //add one to start on next one not displayed
                    pagin_active = 1;
                    break;
                }
            }
            if (row_cnt == 0) {
                pwxcontentHTML.push('<dl class="pwx_content_noresfilter_row"><span class="pwx_noresult_text">',amb_i18n.SELECTED_FILTERS_NO_LABS,'</span></dl>');
            }

            if (row_cnt == 0) {
                $('#pwx_frame_rows_header_dl').after('<dl class="pwx_content_noresfilter_row"><span class="pwx_noresult_text">',amb_i18n.SELECTED_FILTERS_NO_LABS,'</span></dl>');
            }
        }
    }
    else {
        pwxcontentHTML.push('<div id="pwx_frame_content_rows_header"></div><div id="pwx_frame_content_rows"><dl class="pwx_content_nores_row"><span class="pwx_noresult_text">',amb_i18n.NO_RESULTS,'</span></dl>');
    }
    pwxcontentHTML.push('</div>');
    //display content
    framecontentElem.html(pwxcontentHTML.join(""));
    var end_content_timer = new Date();
    var start_event_timer = new Date();
    $('#pwx_task_pagingbar_cur_page').text(amb_i18n.PAGE + ': ' + reflab_list_curpage)
    //setup next paging button
    if (pagin_active == 1 && end_of_reflab_list != 1) {
        $('#pwx_task_filterbar_page_next').html('<span class="pwx-nextpage-icon"></span>')
        $('#pwx_task_filterbar_page_next').on('click', function () {
            framecontentElem.empty();
            framecontentElem.html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
            start_pwx_timer()
            start_page_load_timer = new Date();
            window.scrollTo(0, 0);
            reflab_list_curpage++
            RenderRefLabListContent(pwxdata);
        });
    }
    else {
        $('#pwx_task_filterbar_page_next').html('<span class="pwx-nextpage_grey-icon"></span>')
    }
    //setup prev paging button
    if (json_reflab_start_number > 0) {
        $('#pwx_task_filterbar_page_prev').html('<span class="pwx-prevpage-icon"></span>')
        $('#pwx_task_filterbar_page_prev').on('click', function () {
            reflab_list_curpage--
            json_task_end_number = json_reflab_page_start_numbersAr[reflab_list_curpage - 1]
            framecontentElem.empty();
            framecontentElem.html('<div id="pwx_loading_div"><span class="pwx_loading-spinner"></span><br/><span id="pwx_loading_div_time">0 ' + amb_i18n.SEC + '</span></div>');
            start_pwx_timer()
            start_page_load_timer = new Date();
            window.scrollTo(0, 0);
            RenderRefLabListContent(pwxdata);
        });
    }
    else {
        $('#pwx_task_filterbar_page_prev').html('<span class="pwx-prevpage_grey-icon"></span>')
    }
    if (json_reflab_start_number > 0 || pagin_active == 1) {
        $('#pwx_frame_paging_bar_container').css('display', 'inline-block')
    }
    else {
        $('#pwx_frame_paging_bar_container').css('display', 'none')
    }
    $('#pwxptsumm').on('click', function () {
        callCCLLINK(ccllinkparams)
    });
    $('span.pwx_fcr_content_type_name_dt, span.pwx_fcr_content_type_ordname_dt, dt.pwx_fcr_content_col_orderprov_dt, dt.pwx_fcr_trans_content_tolocation_dt').each(function (index) {
        if (this.clientWidth < this.scrollWidth) {
            var titleText = $(this).text()
            $(this).attr("title", titleText)
        }
    });
	/*
    //multiple lab locations dropdown
    $(".pwx_to_location_class").multiselect({
        header: false,
        minWidth: "50",
        multiple: false,
        classes: "pwx_select_box",
        noneSelectedText: 'Select Lab Location',
        selectedList: 1
    });
	$(".pwx_to_location_class").multiselect('refresh')
	var selectWidth = $(".pwx_fcr_content_action_move_dt").width()
	$(".pwx_to_location_class").css("width", selectWidth - 10)
	$(".pwx_to_location_class").multiselect('refresh')
    $(".pwx_to_location_class").on("multiselectclick", function (event, ui) {
        var toLocationID = ui.value
        $(this).parents('.pwx_fcr_content_action_move_dt').children('.pwx_reflab_to_location').html(toLocationID)
        $(this).parents('dl.pwx_content_row').children('.pwx_reflab_trans_ind').html("1")
        $(this).parents('dl.pwx_content_row').removeClass('pwx_row_selected').addClass('pwx_row_selected')
        var transButtonOn = 1;
        if ($('dl.pwx_content_row.pwx_row_selected').length > 0) {
            $('dl.pwx_content_row.pwx_row_selected').each(function (index) {
                if ($(this).children('dt.pwx_reflab_trans_ind').text() == "0") {
                    transButtonOn = 0;
                }
            });
        }
        else {
            transButtonOn = 0;
        }
        if (transButtonOn == 1) {
            //$('#pwx_reflab_transfer_btn').removeAttr('disabled')
            $('#pwx_transfer_btn_cntrl').removeClass('pwx_blue_button-cntrl_inactive').addClass('pwx_blue_button-cntrl')
        }
        else {
            //$('#pwx_reflab_transfer_btn').attr('disabled', 'disabled')
            $('#pwx_transfer_btn_cntrl').removeClass('pwx_blue_button-cntrl').addClass('pwx_blue_button-cntrl_inactive')
        }
    })
	*/
    //set action dt events
    //sorting events
    if (pwx_reflab_type_view == 1) {
        $('#pwx_fcr_header_orderdate_dt').on('click', function () {
            pwx_reflab_col_sort(pwxdata, 'pwx_fcr_header_orderdate_dt')
        });
        $('#pwx_fcr_header_col_subtype_dt').on('click', function () {
            pwx_reflab_col_sort(pwxdata, 'pwx_fcr_header_col_subtype_dt')
        });
        $('#pwx_fcr_header_col_labname_dt').on('click', function () {
            pwx_reflab_col_sort(pwxdata, 'pwx_fcr_header_col_labname_dt')
        });
        $('#pwx_fcr_header_col_orderprov_dt').on('click', function () {
            pwx_reflab_col_sort(pwxdata, 'pwx_fcr_header_col_orderprov_dt')
        });
        $('#pwx_fcr_header_personname_dt').on('click', function () {
            pwx_reflab_col_sort(pwxdata, 'pwx_fcr_header_personname_dt')
        });
        //add charting done events
        $('#pwx_task_chart_menu').on('mouseleave', function (event) {
            $(this).css('display', 'none');
        });
        $('#pwx_task_chart_link').on('click', function (e) {
            var taskSuccess = pwx_task_launch(pwx_reflab_submenu_clicked_person_id, pwx_reflab_submenu_clicked_task_id, 'CHART');
            if (taskSuccess == true) {
                $(pwx_reflab_submenu_clicked_row_elem).each(function (index) {
                    var dlHeight = $(this).height()
                    $(this).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#87C854').css('height', dlHeight).attr("title", amb_i18n.CHARTED_DONE_REFRESH)
                });
                if (pwxdata.LABEL_PRINT_AUTO_OFF != "1") {
                    if (pwxdata.LABEL_PRINT_TYPE == "BACKEND" || js_criterion.CRITERION.PWX_ADV_PRINT == 0) {
                        var taskSuccess = pwx_task_label_print_launch(pwx_reflab_submenu_clicked_person_id, pwx_reflab_submenu_clicked_task_id);
                    }
                    else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRA") {
                        var orderIdlist = pwx_reflab_submenu_clicked_order_id
                        var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                        window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRA_LABEL','" + ccllinkparams + "',0)";
                    }
                    else if (pwxdata.LABEL_PRINT_TYPE == "ZEBRASMALL") {
                        var orderIdlist = pwx_reflab_submenu_clicked_order_id
                        var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                        window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_ZEBRASMALL','" + ccllinkparams + "',0)";
                    }
                    else {
                        var orderIdlist = pwx_reflab_submenu_clicked_order_id
                        var ccllinkparams = '^MINE^,^' + orderIdlist + '^'
                        window.location = "javascript:CCLLINK('AMB_CUST_MP_REFLAB_DYMO_LABEL','" + ccllinkparams + "',0)";
                    }
                }
                if (pwxdata.AUTOLOG_SPEC_IND == 1) { setTimeout(function () { PWX_CCL_Request_Specimen_Login("amb_cust_call_spec_auto_loc", pwx_reflab_submenu_clicked_task_id, true) }, 1000); }
            }
            $('#pwx_task_chart_menu').css('display', 'none');
        });
        $('#pwx_task_chart_not_done_link2').on('click', function (e) {
            var taskSuccess = pwx_task_launch(pwx_reflab_submenu_clicked_person_id, pwx_reflab_submenu_clicked_task_id, 'CHART_NOT_DONE');

            if (taskSuccess == true) {
                $(pwx_reflab_submenu_clicked_row_elem).each(function (index) {
                    var dlHeight = $(this).height()
                    $(this).children('dt.pwx_fcr_content_type_icon_dt').children('div.pwx_fcr_content_action_bar').css('backgroundColor', '#DF5E3E').css('height', dlHeight).attr("title", amb_i18n.CHARTED_NOT_DONE_REFRESH)
                });
            }
            $('#pwx_task_chart_menu').css('display', 'none');
        });
    }
    else if (pwx_reflab_type_view == 2) {
        $('#pwx_fcr_header_orderdate_dt').on('click', function () {
            pwx_reflab_sort(pwxdata, 'pwx_fcr_header_orderdate_dt')
        });
        $('#pwx_fcr_header_subtype_dt').on('click', function () {
            pwx_reflab_sort(pwxdata, 'pwx_fcr_header_subtype_dt')
        });
        $('#pwx_fcr_header_labname_dt').on('click', function () {
            pwx_reflab_sort(pwxdata, 'pwx_fcr_header_labname_dt')
        });
        $('#pwx_fcr_header_personname_dt').on('click', function () {
            pwx_reflab_sort(pwxdata, 'pwx_fcr_header_personname_dt')
        });
        //action height
        $('dt.pwx_fcr_content_action_dt').each(function (index) {
            var dlHeight = $(this).siblings('dt.pwx_fcr_content_labname_dt').height()
            $(this).children('.pwx_fcr_content_action_indicator_dt').css('height', dlHeight).css('line-height', dlHeight + 'px')
        });
        $('#pwx_reflab_collection_filter input').on('change', function () {
            pwx_reflab_collection_type_view = $('#pwx_reflab_collection_filter input:checked').val()
            pwx_reflab_collection_filter_change(pwxdata)
        })
        var fullLabLoc = $.map(pwxdata.TLIST, function (n, i) {
            if (pwxdata.TLIST[i].LAB_IND == pwx_reflab_type_view) {
                if (pwxdata.TLIST[i].TRANS_LOC.length > 0) {
                    if (pwxdata.TLIST[i].TRANS_LOC.length > 1) {
                        var iterateLabLoc = $.map(pwxdata.TLIST[i].TRANS_LOC, function (y, cc) {
                            return pwxdata.TLIST[i].TRANS_LOC[cc].LOCATION_DISP
                        })
                        return iterateLabLoc
                    }
                    else {
                        return pwxdata.TLIST[i].TRANS_LOC[0].LOCATION_DISP;
                    }
                }
            }
            else {
                return null
            }

        });
        var uniqueLabLoc = $.distinct(fullLabLoc);
        if (uniqueLabLoc.length > 1) {
            var labLocHTML = []
            labLocHTML.push('<span style="vertical-align:30%;">Lab: </span><select id="reflab_to_location" name="reflab_to_location" multiple="multiple" width="220px">');
            for (var i = 0; i < uniqueLabLoc.length; i++) {
                if (pwx_reflab_to_location_filterApplied == 1) {
                    var type_match = 0;
                    for (var y = 0; y < pwx_reflab_to_location_filterArr.length; y++) {
                        if (pwx_reflab_to_location_filterArr[y] == uniqueLabLoc[i]) {
                            type_match = 1;
                            break;
                        }
                    }
                    if (type_match == 1) {
                        labLocHTML.push('<option selected="selected" value="', uniqueLabLoc[i], '">', uniqueLabLoc[i], '</option>');
                    }
                    else {
                        labLocHTML.push('<option value="', uniqueLabLoc[i], '">', uniqueLabLoc[i], '</option>');
                    }
                }
                else {
                    labLocHTML.push('<option selected="selected" value="', uniqueLabLoc[i], '">', uniqueLabLoc[i], '</option>');
                }
            }
            labLocHTML.push('</select>');
            $('#pwx_reflab_tolocation_filter').html(labLocHTML.join(""))
            $("#reflab_to_location").multiselect({
                height: "100",
                minWidth: "225",
                classes: "pwx_select_box",
                noneSelectedText: 'Select To Location',
                selectedList: 1
            });
            $("#reflab_to_location").on("multiselectclose", function (event, ui) {
                var array_of_checked_values = $("#reflab_to_location").multiselect("getChecked").map(function () {
                    return this.value;
                }).get();
                pwx_reflab_to_location_filterArr = jQuery.makeArray(array_of_checked_values);
                if (uniqueLabLoc.length == pwx_reflab_to_location_filterArr.length) {
                    pwx_reflab_to_location_filterApplied = 0
                } else {
                    pwx_reflab_to_location_filterApplied = 1
                }
                pwx_reflab_collection_filter_change(pwxdata)
            });
        }
	//multiple lab locations dropdown
		framecontentElem.off('click', 'span.pwx_lab_transfer_loc_multi')
		framecontentElem.on('click', 'span.pwx_lab_transfer_loc_multi', function () {
			var locJSONId = $(this).parents('.pwx_fcr_content_action_move_dt').children('.pwx_task_json_index_hidden').text()
			var loccontentElem = $(this).parents('.pwx_fcr_content_action_move_dt').children('.pwx_lab_transfer_link')
			var loccontentOldHTML = loccontentElem.html()
			var setLabLocation = loccontentElem.parents('.pwx_fcr_content_action_move_dt').children('.pwx_reflab_to_location').html();
			var setHTMLInd = loccontentElem.parents('dl.pwx_content_row').children('.pwx_reflab_trans_ind').html()
			var setIndicator = loccontentElem.parents('.pwx_fcr_content_action_dt').children('.pwx_fcr_content_action_indicator_dt').hasClass('pwx_reflab_ready_trans')
			var setTitle = loccontentElem.parents('.pwx_fcr_content_action_dt').children('.pwx_fcr_content_action_indicator_dt').attr('title')	
			
			var tempElemId = "pwx_to_location_dropdown_" + locJSONId
			var tempHTML = []
			tempHTML.push('<select class="pwx_to_location_class" id="', tempElemId, '" multiple="multiple" >')
			for (var cc = 0; cc < pwxdata.TLIST[locJSONId].TRANS_LOC.length; cc++) {
				if(pwxdata.TLIST[locJSONId].TRANS_LOC[cc].SR_RESOURCE_CD == setLabLocation) {
					var selectInd = 'selected="selected"'
				} else {
					var selectInd = ''
				}
				tempHTML.push('<option value="', pwxdata.TLIST[locJSONId].TRANS_LOC[cc].SR_RESOURCE_CD, '" ',selectInd,'>', pwxdata.TLIST[locJSONId].TRANS_LOC[cc].LOCATION_DISP, '</option>')
			}
			tempHTML.push('</select>');
			loccontentElem.html(tempHTML.join(""))
			$("#" + tempElemId).off("multiselectclick multiselectclose")
			$("#" + tempElemId).multiselect({
				header: false,
				minWidth: "50",
				multiple: false,
				classes: "pwx_select_box",
				noneSelectedText: amb_i18n.SELECT_LAB_LOC,
				autoOpen: true,
				selectedList: 1,
				position: {
                    my: "top",
                    at: "bottom",
                    collision: "flip"
                }
			});
			setTimeout(function () {  
				var selectWidth = $(".pwx_fcr_content_action_dt").width() - $(".pwx_fcr_content_action_indicator_dt").width()
				$("#" + tempElemId).css("width", selectWidth - 10)
				$("#" + tempElemId).multiselect('refresh')			
			},0);

			$("#" + tempElemId).on("multiselectclick multiselectclose", function (event, ui) {
				var toLocationID = ui.value
				if(toLocationID != undefined) {
					loccontentElem.parents('.pwx_fcr_content_action_move_dt').children('.pwx_reflab_to_location').html(toLocationID)
					loccontentElem.attr("title",ui.text)
					loccontentElem.html('<span class="pwx_lab_transfer_loc_multi pwx_pointer_cursor">' + ui.text + '</span>')
					loccontentElem.parents('dl.pwx_content_row').children('.pwx_reflab_trans_ind').html("1")
					loccontentElem.parents('dl.pwx_content_row').removeClass('pwx_row_selected').addClass('pwx_row_selected')
					loccontentElem.parents('.pwx_fcr_content_action_dt').children('.pwx_fcr_content_action_indicator_dt').addClass('pwx_reflab_ready_trans')
					loccontentElem.parents('.pwx_fcr_content_action_dt').children('.pwx_fcr_content_action_indicator_dt').attr('title',amb_i18n.LAB_RDY_TRANS)
					pwx_reflab_selectall_check();
				} else {
					loccontentElem.html(loccontentOldHTML);
					loccontentElem.parents('.pwx_fcr_content_action_move_dt').children('.pwx_reflab_to_location').html(setLabLocation);
					loccontentElem.parents('dl.pwx_content_row').children('.pwx_reflab_trans_ind').html(setHTMLInd)
					if(setIndicator == false) {
						loccontentElem.parents('.pwx_fcr_content_action_dt').children('.pwx_fcr_content_action_indicator_dt').removeClass('pwx_reflab_ready_trans')
					}
					loccontentElem.parents('.pwx_fcr_content_action_dt').children('.pwx_fcr_content_action_indicator_dt').attr('title',setTitle)
				}
				//$("#" + tempElemId).destroy()
			})
		});
    }
    else if (pwx_reflab_type_view == 3) {
        $('#pwx_fcr_trans_header_transdate_dt').on('click', function () {
            pwx_trans_reflab_sort(pwxdata, 'pwx_fcr_trans_header_transdate_dt')
        });
        $('#pwx_fcr_trans_header_tolocation_dt').on('click', function () {
            pwx_trans_reflab_sort(pwxdata, 'pwx_fcr_trans_header_tolocation_dt')
        });
        $('#pwx_fcr_trans_header_labname_dt').on('click', function () {
            pwx_trans_reflab_sort(pwxdata, 'pwx_fcr_trans_header_labname_dt')
        });
        $('#pwx_fcr_trans_header_orderdate_dt').on('click', function () {
            pwx_trans_reflab_sort(pwxdata, 'pwx_fcr_trans_header_orderdate_dt')
        });
        $('#pwx_fcr_header_personname_dt').on('click', function () {
            pwx_trans_reflab_sort(pwxdata, 'pwx_fcr_header_personname_dt')
        });
        //action height
        $('dt.pwx_fcr_content_action_dt').each(function (index) {
            var dlHeight = $(this).siblings('dt.pwx_fcr_trans_content_labname_dt').height()
            $(this).children('.pwx_fcr_content_action_indicator_dt').css('height', dlHeight).css('line-height', dlHeight + 'px')
        });
        $('#pwx_reflab_collection_filter input').on('change', function () {
            pwx_reflab_collection_type_view = $('#pwx_reflab_collection_filter input:checked').val()
            pwx_reflab_collection_filter_change(pwxdata)
        })
        $("#reflab_results").on("multiselectclick", function (event, ui) {
            pwx_reflab_result_filter = ui.value
            pwx_reflab_collection_filter_change(pwxdata)
        })
        var fullLabLoc = $.map(pwxdata.TLIST, function (n, i) {
            if (pwxdata.TLIST[i].LAB_IND == pwx_reflab_type_view) {
                return pwxdata.TLIST[i].TRANSFER_TO_LOC;
            }
            else {
                return null
            }

        });
        var uniqueLabLoc = $.distinct(fullLabLoc);
        if (uniqueLabLoc.length > 1) {
            var labLocHTML = []
            labLocHTML.push('<span style="vertical-align:30%;">Lab: </span><select id="reflab_to_location" name="reflab_to_location" multiple="multiple" width="220px">');
            for (var i = 0; i < uniqueLabLoc.length; i++) {
                if (pwx_reflab_to_location_filterApplied == 1) {
                    var type_match = 0;
                    for (var y = 0; y < pwx_reflab_to_location_filterArr.length; y++) {
                        if (pwx_reflab_to_location_filterArr[y] == uniqueLabLoc[i]) {
                            type_match = 1;
                            break;
                        }
                    }
                    if (type_match == 1) {
                        labLocHTML.push('<option selected="selected" value="', uniqueLabLoc[i], '">', uniqueLabLoc[i], '</option>');
                    }
                    else {
                        labLocHTML.push('<option value="', uniqueLabLoc[i], '">', uniqueLabLoc[i], '</option>');
                    }
                }
                else {
                    labLocHTML.push('<option selected="selected" value="', uniqueLabLoc[i], '">', uniqueLabLoc[i], '</option>');
                }
            }
            labLocHTML.push('</select>');
            $('#pwx_reflab_tolocation_filter').html(labLocHTML.join(""))
            $("#reflab_to_location").multiselect({
                height: "100",
                minWidth: "225",
                classes: "pwx_select_box",
                noneSelectedText: amb_i18n.SELECT_TO_LOCATION,
                selectedList: 1
            });
            $("#reflab_to_location").on("multiselectclose", function (event, ui) {
                pwx_reflab_to_location_filterApplied = 1
                var array_of_checked_values = $("#reflab_to_location").multiselect("getChecked").map(function () {
                    return this.value;
                }).get();
                pwx_reflab_to_location_filterArr = jQuery.makeArray(array_of_checked_values);
                pwx_reflab_collection_filter_change(pwxdata)
            });
        }
    }
    //person menu
    $.contextMenu({
        selector: 'span.pwx_fcr_content_type_person_icon_dt',
        trigger: 'left',
        zIndex: '9999',
        className: 'ui-widget',
        build: function ($trigger, e) {
            $($trigger).parents('dl.pwx_content_row').addClass('pwx_row_selected')
            json_index = $($trigger).children('span.pwx_task_json_index_hidden').text()
            var options = {
                items: {
                    "Visit Summary (Depart)": { "name": pwxdata.DEPART_LABEL, callback: function (key, opt) {
                        var dpObject = new Object();
                        dpObject = window.external.DiscernObjectFactory("DISCHARGEPROCESS");
                        dpObject.person_id = pwxdata.TLIST[json_index].PERSON_ID;
                        dpObject.encounter_id = pwxdata.TLIST[json_index].ENCOUNTER_ID;
                        dpObject.user_id = js_criterion.CRITERION.PRSNL_ID;
                        dpObject.LaunchDischargeDialog();
                    }
                    },
                    "fold1": {
                        "name": "Chart Forms",
                        "items": {},
                        disabled: false
                    },
                    "Patient Snapshot": { "name": amb_i18n.PATIENT_SNAPSHOT, callback: function (key, opt) {
                        PWX_CCL_Request_Person_Details("amb_cust_person_details_diag", pwxdata.TLIST[json_index].PERSON_ID, pwxdata.TLIST[json_index].ENCOUNTER_ID, false)
                    }
                    },
                    "sep5": "---------",
                    "fold3": {
                        "name": amb_i18n.OPEN_PT_CHART,
                        "items": {},
                        disabled: false
                    }
                }
            };

            if (pwxdata.FORMSLIST.length > 0) {
                for (var cc in pwxdata.FORMSLIST) {
                    options.items["fold1"].items[cc + "|forms"] = { "name": pwxdata.FORMSLIST[cc].FORM_NAME, callback: function (key, opt) { var keyArr = key.split("|"); pwx_form_launch(pwxdata.TLIST[json_index].PERSON_ID, pwxdata.TLIST[json_index].ENCOUNTER_ID, pwxdata.FORMSLIST[keyArr[0]].FORM_ID, 0.0, 0); } }
                }
                options.items["fold1"].items["Forms Menu"] = { "name": amb_i18n.ALL_FORMS, "className": "pwx_link_blue", callback: function (key, opt) { pwx_form_launch(pwxdata.TLIST[json_index].PERSON_ID, pwxdata.TLIST[json_index].ENCOUNTER_ID, 0.0, 0.0, 0); } }
            }
            else {
                options.items["fold1"] = { "name": amb_i18n.CHART_FORMS, disabled: function (key, opt) { return true; } };
            }
            if (pwxdata.ALLOW_DEPART == 0) {
                options.items["Visit Summary (Depart)"] = { "name": pwxdata.DEPART_LABEL, disabled: function (key, opt) { return true; } };
            }
            if (js_criterion.CRITERION.VPREF.length > 0) {
                for (var cc in js_criterion.CRITERION.VPREF) {
                    options.items["fold3"].items[cc] = { "name": js_criterion.CRITERION.VPREF[cc].VIEW_CAPTION, callback: function (key, opt) {
                        var parameter_person_launch = '/PERSONID=' + pwxdata.TLIST[json_index].PERSON_ID + ' /ENCNTRID=' + pwxdata.TLIST[json_index].ENCOUNTER_ID + ' /FIRSTTAB=^' + js_criterion.CRITERION.VPREF[key].VIEW_CAPTION + '^'
                        APPLINK(0, "$APP_APPNAME$", parameter_person_launch)
                    }
                    };
                }
            }
            else {
                options.items["fold3"] = { "name": amb_i18n.OPEN_PT_CHART, disabled: function (key, opt) { return true; } };
            }
            return options;
        }
    });
    //adjust heights based on screen size
    var toolbarH = $('#pwx_frame_toolbar').height() + 6;
    $('#pwx_frame_filter_bar').css('top', toolbarH + 'px');
    var filterbarH = $('#pwx_frame_filter_bar').height() + toolbarH;
	$('#pwx_frame_content_rows_header').css('top', filterbarH + 'px');
	var contentrowsH = filterbarH + 19;
	$('#pwx_frame_content_rows').css('top', contentrowsH + 'px');
	window.scrollTo(0,0);
    //timers
    var end_event_timer = new Date();
    var end_page_load_timer = new Date();
    var event_timer = (end_event_timer - start_event_timer) / 1000
    var content_timer = (end_content_timer - start_content_timer) / 1000
    var program_timer = (end_page_load_timer - start_page_load_timer) / 1000
    stop_pwx_timer()
    //$('#pwx_frame_content_rows').append('<dl id="pwx_list_timers_row" class="pwx_extra_small_text"><dt>CCL Timer: ' + ccl_timer + ' Page Load Timer: ' + program_timer + '</dt></dl>')
}








function MP_DCP_REFLAB_TRANSFER_Request(program, blobIn, paramAr, async) {
    //create spinning modal
    MP_ModalDialog.deleteModalDialogObject("RefTransmittingModal")
    var refTransmitModal = new ModalDialog("RefTransmittingModal")
                    .setHeaderTitle(amb_i18n.TRANSMITTING + '...')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(false)
                    .setShowCloseIcon(false);
    refTransmitModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;" style="float:left;width:100%;text-align:center;"><div class="pwx_loading-spinner" style="position:relative;width:32px;left:50%;margin-left:-16px;"></div></div>');
                });
    MP_ModalDialog.addModalDialogObject(refTransmitModal);
    MP_ModalDialog.showModalDialog("RefTransmittingModal")

    var info = new XMLCclRequest();
    info.onreadystatechange = function () {
        if (info.readyState == 4 && info.status == 200) {
            MP_ModalDialog.closeModalDialog("RefTransmittingModal")
            var jsonEval = JSON.parse(this.responseText);
            var recordData = jsonEval.JSON_RETURN;
            if (recordData.STATUS_DATA.STATUS == "S") {
				setTimeout(function () { 
					$('#pwx_task_list_refresh_icon').trigger('click')
					if (pwx_reflab_collection_type_view == '1') {
						var ccllinkparams = '^MINE^,^' + recordData.TRANS_LISTS + '^'
						window.location = "javascript:CCLLINK('amb_cust_reflab_transfer_list','" + ccllinkparams + "',0)";
					}
				}, 500);
            }
            else if (recordData.STATUS_DATA.STATUS == "T") {
                var error_text = amb_i18n.STATUS + ": " + this.status + " " + amb_i18n.REQUEST_TEXT + ": " + this.requestText;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert">' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + amb_i18n.UNABLE_ESO_ERROR + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
            else {
                var error_text = amb_i18n.STATUS + ": " + this.status + " " + amb_i18n.REQUEST_TEXT + ": " + this.requestText;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert">' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
        }
    };

    info.setBlobIn(JSON.stringify(blobIn));
    info.open('GET', program, async);
    info.send(paramAr.join(","));
}

function MP_DCP_REFLAB_REMOVE_FROM_LIST_Request(program, param1, param2, async) {
    var info = new XMLCclRequest();
    info.onreadystatechange = function () {
        //alert(info.readyState + ' ' + info.status)
        if (info.readyState == 4 && info.status == 200) {
            var jsonEval = JSON.parse(this.responseText);
            var recordData = jsonEval.JSON_RETURN;
            if (recordData.STATUS_DATA.STATUS == "S") {
                $('#pwx_task_list_refresh_icon').trigger('click')
            }
            else if (recordData.STATUS_DATA.STATUS == "D") {
                var error_text = amb_i18n.LIST_ALREADY_TRANS;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert">' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
            else {
                var error_text = amb_i18n.STATUS + ": " + this.status + " " + amb_i18n.REQUEST_TEXT + ": " + this.requestText;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert">' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
        }
    };

    var sendArr = ["^MINE^", param1 + ".0", "^" + param2 + "^"];
    info.open('GET', program, async);
    info.send(sendArr.join(","));
}

function MP_DCP_REFLAB_RETRANSFER_Request(program, param1, async) {
    var info = new XMLCclRequest();
    info.onreadystatechange = function () {
        //alert(info.readyState + ' ' + info.status)
        if (info.readyState == 4 && info.status == 200) {
            var jsonEval = JSON.parse(this.responseText);
            var recordData = jsonEval.JSON_RETURN;
            if (recordData.STATUS_DATA.STATUS == "S") {
                $('#pwx_task_list_refresh_icon').trigger('click')
            }
            else {
                var error_text = amb_i18n.STATUS + ": " + this.status + " " + amb_i18n.REQUEST_TEXT + ": " + this.requestText;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert">' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
        }
    };

    var sendArr = ["^MINE^", param1 + ".0"];
    info.open('GET', program, async);
    info.send(sendArr.join(","));
}

function MP_DCP_REFLAB_GET_LIST_DETAILS_Request(program, param1, async) {
    var info = new XMLCclRequest();
    info.onreadystatechange = function () {
        if (info.readyState == 4 && info.status == 200) {
            var jsonEval = JSON.parse(this.responseText);
            var recordData = jsonEval.JSON_RETURN;
            if (recordData.STATUS_DATA.STATUS == "S") {
                var detailsHTML = []
                detailsHTML.push('<span class="pwx_grey">',amb_i18n.FROM,': </span>', recordData.FROM_LOCATION, '<span class="pwx_grey">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;',amb_i18n.TO,': </span>', recordData.TO_LOCATION, '</br></br>')
                detailsHTML.push('<div class="hvr_table"><table><tr><th>',amb_i18n.PATIENT_NAME,'</th><th>',amb_i18n.GENDER,'</th><th>',amb_i18n.DOB,'</th><th>',amb_i18n.ACCESSION,'</th><th>',amb_i18n.ORDER,'</th><th>',amb_i18n.DESCRIPTION,'</th></tr>')
                for (var y = 0; y < recordData.CONTAIN_LIST.length; y++) {
                    detailsHTML.push('<tr>')
                    detailsHTML.push('<td>', recordData.CONTAIN_LIST[y].PATIENT_NAME, '</td>')
                    detailsHTML.push('<td>', recordData.CONTAIN_LIST[y].PATIENT_GENDER, '</td>')
                    detailsHTML.push('<td>', recordData.CONTAIN_LIST[y].PATIENT_DOB, '</td>')
                    detailsHTML.push('<td>', recordData.CONTAIN_LIST[y].ACCESSION, ' ', recordData.CONTAIN_LIST[y].ACCESSION_NUM, '</td>')
                    detailsHTML.push('<td>', recordData.CONTAIN_LIST[y].ORDER_LINE, '</td>')
                    detailsHTML.push('<td>', recordData.CONTAIN_LIST[y].CONTAINER_SENT, '</td>')
                    detailsHTML.push('</tr>')
                }
                detailsHTML.push('</table></div>')
                MP_ModalDialog.deleteModalDialogObject("ListDetailModal")
                var listDetailModal = new ModalDialog("ListDetailModal")
                    .setHeaderTitle(amb_i18n.TRANSMIT_LIST + ' #' + recordData.TRANSFER_LIST_NUM + ' on ' + recordData.TRANSFER_LIST_DT)
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(10)
                    .setBottomMarginPercentage(15)
                    .setLeftMarginPercentage(10)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                listDetailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + detailsHTML.join("") + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.CANCEL).setCloseOnClick(true);
                var retransferbtn = new ModalButton("retransfer");
                retransferbtn.setText(amb_i18n.RETRANSMIT).setCloseOnClick(true).setOnClickFunction(function () { MP_DCP_REFLAB_RETRANSFER_Request("amb_cust_mp_reflab_retransfer", param1, true) }); ;
                listDetailModal.addFooterButton(retransferbtn)
                listDetailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(listDetailModal);
                MP_ModalDialog.showModalDialog("ListDetailModal")
            }
            else {
                var error_text = amb_i18n.STATUS + ": " + this.status + " " + amb_i18n.REQUEST_TEXT + ": " + this.requestText;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert">' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
        }
    };

    var sendArr = ["^MINE^", param1 + ".0"];
    info.open('GET', program, async);
    info.send(sendArr.join(","));
}

function MP_DCP_REFLAB_GET_ORDER_RESULTS_Request(program, param1, param2, pname, pdob, person_age, pgender, async) {
    var info = new XMLCclRequest();
    info.onreadystatechange = function () {
        if (info.readyState == 4 && info.status == 200) {
            var jsonEval = JSON.parse(this.responseText);
            var recordData = jsonEval.JSON_RETURN;
            if (recordData.STATUS_DATA.STATUS == "S") {
                //alert(JSON.stringify(recordData))
                var detailsHTML = []
                detailsHTML.push('<div class="pwx_modal_person_banner"><span class="pwx_modal_person_banner_name">', pname, '</span>')
                detailsHTML.push('<span class="pwx_modal_person_banner_details">',amb_i18n.DOB,':&nbsp;', pdob, '</span>')
                detailsHTML.push('<span class="pwx_modal_person_banner_details">',amb_i18n.AGE,':&nbsp;', person_age, '</span>')
                detailsHTML.push('<span class="pwx_modal_person_banner_details">',amb_i18n.GENDER,':&nbsp;', pgender, '</span>')
                detailsHTML.push('</div></br></br>')
                for (var y = 0; y < recordData.ORDER_LIST.length; y++) {
                    detailsHTML.push('<dl class="pwx_task_detail_line" style="padding-top:5px;"><dt class="pwx_no_wrap"><span class="pwx_order_info_title">',amb_i18n.ORDER,' ', (y + 1), ':&nbsp;<span class="pwx_semi_bold">', recordData.ORDER_LIST[y].ORDER_NAME, '</span></dt><div class="pwx_sub_sub-sec-hd">&nbsp;</div></dl>');
                    if (recordData.ORDER_LIST[y].RESLIST.length > 0) {
                        detailsHTML.push('</br></br><dl class="pwx_task_detail_line"><dt>',amb_i18n.RESULT_DATE,':</dt><dd>', recordData.ORDER_LIST[y].RESLIST[0].RESULT_DATE, '</dd></dl>')
                        detailsHTML.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad hvr_table"><table><tr><th>',amb_i18n.RESULT,'</th><th>',amb_i18n.VALUE,'</th></tr>')
                        for (var z = 0; z < recordData.ORDER_LIST[y].RESLIST.length; z++) {
                            detailsHTML.push('<tr>')
                            var normalcy = "res-normal";
                            var normalcyMeaning = recordData.ORDER_LIST[y].RESLIST[z].NORMALCY_CD_MEAN
                            if (normalcyMeaning != null) {
                                if (normalcyMeaning === "LOW") {
                                    normalcy = "res-low";
                                } else {
                                    if (normalcyMeaning === "HIGH") {
                                        normalcy = "res-high";
                                    } else {
                                        if (normalcyMeaning === "CRITICAL" || normalcyMeaning === "EXTREMEHIGH" || normalcyMeaning === "PANICHIGH" || normalcyMeaning === "EXTREMELOW" || normalcyMeaning === "PANICLOW" || normalcyMeaning === "VABNORMAL" || normalcyMeaning === "POSITIVE") {
                                            normalcy = "res-severe";
                                        } else {
                                            if (normalcyMeaning === "ABNORMAL") {
                                                normalcy = "res-abnormal";
                                            }
                                        }
                                    }
                                }
                            }
                            var resDisp = ""
                            resDisp += '<span class="' + normalcy + '"><span class="res-ind" style="margin:2px .3em 1px 0 !important;">&nbsp;</span><a class="pwx_nocolor_link" onClick="pwx_result_view_launch(' + param2 + ',' + recordData.ORDER_LIST[y].RESLIST[z].EVENT_ID + ')">' + recordData.ORDER_LIST[y].RESLIST[z].RESULT_VAL + '</a></span><span class="pwx_extra_small_text pwx_grey">&nbsp;' + recordData.ORDER_LIST[y].RESLIST[z].RESULT_UNITS + '</span>'

                            var js_criterion = JSON.parse(m_criterionJSON);
                            js_criterion.CRITERION.PRSNL_ID
                            if (!isIntegerorFloat(recordData.ORDER_LIST[y].RESLIST[z].RESULT_VAL)) {
                                detailsHTML.push('<td>', recordData.ORDER_LIST[y].RESLIST[z].RESULT_NAME, '</td>')
                            }
                            else {
                                detailsHTML.push('<td><a class="pwx_result_link" onClick="pwx_launch_vitals_result_graphing(', param2, ',', recordData.ORDER_LIST[y].RESLIST[z].EVENT_CD, ',0,', js_criterion.CRITERION.PRSNL_ID, ',', js_criterion.CRITERION.POSITION_CD, ',', js_criterion.CRITERION.PPR_CD, ')">', recordData.ORDER_LIST[y].RESLIST[z].RESULT_NAME, '</a></td>')
                            }
                            detailsHTML.push('<td>', resDisp, '</td>')
                            detailsHTML.push('</tr>')
                        }
                        detailsHTML.push('</table></dl>')

                    }
                    else {
                        detailsHTML.push('<dl class="pwx_task_detail_line pwx_hvr_order_info_pad hvr_table"><table><tr><td><span class="pwx_grey">',amb_i18n.NO_RESULTS,'</span></td></tr></table></dl>')
                    }
                }
                MP_ModalDialog.deleteModalDialogObject("OrderResultsModal")
                var orderResultModal = new ModalDialog("OrderResultsModal")
                    .setHeaderTitle(amb_i18n.ORDER_RESULTS + ' (' + recordData.ORDER_LIST.length + ')')
                    .setTopMarginPercentage(15)
                    .setRightMarginPercentage(30)
                    .setBottomMarginPercentage(15)
                    .setLeftMarginPercentage(30)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                orderResultModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="pwx_task_detail_no_pad"><p class="pwx_small_text">' + detailsHTML.join("") + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.CLOSE).setCloseOnClick(true);
                orderResultModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(orderResultModal);
                MP_ModalDialog.showModalDialog("OrderResultsModal")
            }
            else {
                var error_text = amb_i18n.STATUS + ": " + this.status + " " + amb_i18n.REQUEST_TEXT + ": " + this.requestText;
                MP_ModalDialog.deleteModalDialogObject("TaskActionFail")
                var taskFailModal = new ModalDialog("TaskActionFail")
                    .setHeaderTitle('<span class="pwx_alert">' + amb_i18n.ERROR + '!</span>')
                    .setTopMarginPercentage(20)
                    .setRightMarginPercentage(35)
                    .setBottomMarginPercentage(30)
                    .setLeftMarginPercentage(35)
                    .setIsBodySizeFixed(true)
                    .setHasGrayBackground(true)
                    .setIsFooterAlwaysShown(true);
                taskFailModal.setBodyDataFunction(
                function (modalObj) {
                    modalObj.setBodyHTML('<div style="padding-top:10px;"><p class="pwx_small_text">' + error_text + '</p></div>');
                });
                var closebtn = new ModalButton("addCancel");
                closebtn.setText(amb_i18n.OK).setCloseOnClick(true);
                taskFailModal.addFooterButton(closebtn)
                MP_ModalDialog.addModalDialogObject(taskFailModal);
                MP_ModalDialog.showModalDialog("TaskActionFail")
            }
        }
    };

    var sendArr = ["^MINE^", "^" + param1 + "^", param2 + ".0"];
    info.open('GET', program, async);
    info.send(sendArr.join(","));
}

//create the result viewer launch function
pwx_result_view_launch = function (persId, eventId) {
    var pwxPVViewerMPage = window.external.DiscernObjectFactory('PVVIEWERMPAGE');
    pwxPVViewerMPage.CreateEventViewer(persId);
    pwxPVViewerMPage.AppendEvent(eventId);
    pwxPVViewerMPage.LaunchEventViewer();
}

function pwx_launch_vitals_result_graphing(personId, eventCd, groupID, userId, positionCd, pprCd) {
    //var js_criterion = JSON.parse(m_criterionJSON);
    var wParams = "left=0,top=0,width=1200,height=700,toolbar=no";
    var sParams = "^MINE^," + personId + ".0,0.0," + eventCd + ".0,^I:\\WININTEL\\static_content\\MasterSummary_V4\\discrete-graphing^," + groupID + ".0," + userId + ".0," + positionCd + ".0," + pprCd + ".0,2,5,200,^Last 2 years for all visits^";
    var graphCall = "javascript:CCLLINK('mp_retrieve_graph_results', '" + sParams + "',1)";
    //MP_Util.LogCclNewSessionWindowInfo(null, graphCall, "mp_core.js", "GraphResults");
    javascript: CCLNEWSESSIONWINDOW(graphCall, "_self", wParams, 0, 1);

}

function isIntegerorFloat(str) {
    var intRegex = /^\d+$/;
    var floatRegex = /^((\d+(\.\d *)?)|((\d*\.)?\d+))$/;
    if (intRegex.test(str) || floatRegex.test(str)) {
        return true;
    }
    else {
        return false;
    }
}