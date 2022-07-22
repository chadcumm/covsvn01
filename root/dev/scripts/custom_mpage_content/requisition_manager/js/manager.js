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
		pwxheadHTML.push('<select id="task_location" name="task_location" multiple style="width:500px;" data-placeholder="Choose a Location..." class="chzn-select"><option value=""></option>'); //added multiple to location
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
    pwxfilterbarHTML.push('<div id="pwx_frame_advanced_filters_container" style="display:inline-block;">') //display advanced filters on first load
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
            PWX_CCL_Request("req_cust_mp_task_by_loc_dt", sendArr, true, function () {
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
                    statusHTML.push('<option value="', pwxdata.STATUS_LIST[i].STATUS, '">', pwxdata.STATUS_LIST[i].STATUS, '</option>');
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
        height: "200",
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
                            }

                        }
                    },
                    "sep3": "---------",
                    "Patient Summary": { "name": "Patient Summary", callback: function (key, opt) { callCCLLINK(ccllinkparams); } },
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
        PWX_CCL_Request("req_cust_mp_task_by_loc_dt", sendArr, true, function () {
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

	if (pwx_task_header_id == 'pwx_fcr_header_clerkstatus_dt') {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_clerkstatus_dt">','Clerk Status','<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
        }
        else {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_clerkstatus_dt">','Clerk Status','</dt>');
        }

        if (pwx_task_header_id == 'pwx_fcr_header_clerkcomment_dt') {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_clerkcomment_dt">','Comment','<span id="task_sort_tgl" class="', sort_icon, '" >&nbsp;</span></dt>');
        }
        else {
            pwxcontentHTML.push('<dt id="pwx_fcr_header_clerkcomment_dt">','Comment','</dt>');
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