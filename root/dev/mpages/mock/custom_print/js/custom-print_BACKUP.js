/**
* Creates the custom HTML to render in the print window.
* @method frontEndCustomPrintExample
* @private
* @returns {undefined} nothing
*/

function providerGroupListTemplate(){
alert("patients");
}


function frontEndCustomPrintExample() {

	
    var createHTML = function(scriptReply) {
        var response = scriptReply.getResponse();
        if (response.STATUS_DATA.STATUS === "S") {
            var patients = response.PATIENTS;
	alert("patients");
            var completeMockData = response.MOCK_DATA;           
	alert("MOCK_DATA");
 var mockIndex = 0;
            /**
            * Creates the diagnosis HTML using mock data.
            * @param {Object} mockData - Mock Data information
            * @method getDiagnosisHTML
            * @private
            * @returns {String} Diagnosis html string
            */
            function getDiagnosisHTML(mockData) {
                return mockData.DIAGNOSIS.map(function(diagnosis) {
                    return "<div>" + diagnosis.NAME_DISP + "</div>";
                }).join("");
            }
            /**
            * Creates the Actions HTML using mock data.
            * @param {Object} mockData - Mock Data information
            * @method getActionsHTML
            * @private
            * @returns {String} Actions html string
            */
            function getActionsHTML(mockData) {
                return mockData.ACTIONS.map(function(action) {
                    return "<div>" + action.NAME_DISP + "</div>";
                }).join("");
            }
            /**
            * Creates Data time string to place in print window.
            * @method getCurrentDateTime
            * @private
            * @returns {String} Date Time String
            */
            function getCurrentDateTime() {
                var currentdate = new Date();
                var printedDateTime = (currentdate.getMonth() + 1) + "/"
                    + currentdate.getDate() + "/"
                    + currentdate.getFullYear() + " "
                    + currentdate.getHours() + ":"
                    + currentdate.getMinutes();
                return printedDateTime;
            }
            var printTemplateHTML = patients.map(function(patient, index) {
                mockIndex = (index + 1) % 2;
                var currentMockData = completeMockData[mockIndex];
                var diagnosisHTML = getDiagnosisHTML(currentMockData);
                var actionsHTML = getActionsHTML(currentMockData);
                var patientEntryHTML = [
                        '<tr class="table-row-1">',    
                            '<td class="location">',
                                '<div class="cell-content">',
                                    '<div>',
                                        patient.LOCATION_DATA.FACILITY,
                                    '</div>',
                                '</div>',
                            '</td>',
                            '<td class="location">',
                                '<div class="cell-content">',
                                    '<div>',
                                        patient.PATIENT_DATA.NAME_FULL,
                                    '</div>',
                                '</div>',
                            '</td>',
                            '<td class="location">',
                                '<div class="cell-content">',
                                    '<div>',
                                        patient.PATIENT_DATA.MRN,
                                    '</div>',
                                '</div>',
                            '</td>',
                            '<td class="location">',
                                '<div class="cell-content">',
                                    '<div>',
                                        patient.PRI_SER,
                                    '</div>',
                                '</div>',
                            '</td>',
                            '<td class="location">',
                                '<div class="cell-content">',
                                    '<div>',
                                        patient.ADMIT_DT,
                                    '</div>',
                                '</div>',
                            '</td>',
                            '<td class="location">',
                                '<div class="cell-content">',
                                    '<div>',
                                        patient.BIRTH_DT,
                                    '</div>',
                                '</div>',
                            '</td>',
                            '<td class="location">',
                                '<div class="cell-content">',
                                    '<div>',
                                        patient.AGE,
                                    '</div>',
                                '</div>',
                            '</td>',
                            '<td class="location">',
                                '<div class="cell-content">',
                                    '<div>',
                                        patient.WEIGHT,
                                    '</div>',
                                '</div>',
                            '</td>',
                            '<td class="location">',
                                '<div class="cell-content">',
                                    '<div>',
                                        patient.ILLNESS_SEV,
                                    '</div>',
                                '</div>',
                            '</td>',
                        '</tr>'
                ].join("");
                return patientEntryHTML;
            }).join("");
            // Add header to begining of the print page.
            var printTest = [
            '<div class="print-header">',
                '<div class="printed-by-user">',
                    '<span>',
                        'Printed By: ' + response.PERSON_PRINTING_NAME,
                    '</span>',
                '</div>',
                '<div class="print-title">',
                    '<span>',
                        'Patient Handoff',
                    '</span>',
                '</div>',
                '<div class="printed-date">',
                    '<span>',
                        getCurrentDateTime(),
                    '</span>',
                '</div>',
            '</div>'
            ].join("");
            //start the table tag
            var tableStart = [
                '<div class="table-container"><table>',
                    '<tr class="table-row-1">',
                        '<td class="location">',
                            '<div class="cell-header">Room & Bed</div>',
                        '</td>',
                        '<td class="location">',
                            '<div class="cell-header">Name</div>',
                        '</td>',
                        '<td class="location">',
                            '<div class="cell-header">MRN</div>',
                        '</td>',
                        '<td class="location">',
                            '<div class="cell-header">Primary Service</div>',
                        '</td>',
                        '<td class="location">',
                            '<div class="cell-header">Admit Date</div>',
                        '</td>',
                        '<td class="location">',
                            '<div class="cell-header">Date of Birth</div>',
                        '</td>',
                        '<td class="location">',
                            '<div class="cell-header">Age</div>',
                        '</td>',
                        '<td class="location">',
                            '<div class="cell-header">Weight for Calc</div>',
                        '</td>',
                        '<td class="location">',
                            '<div class="cell-header">Illness Severity</div>',
                        '</td>',
                    '</tr>'
            ].join("");
            //end the table tag
            var tableEnd = [
                '</table></div>'
            ].join("");
            printTemplateHTML = printTest + tableStart + printTemplateHTML + tableEnd;
            mountPrintContainer(printTemplateHTML);
        }
        else {
            logger.logJSError("Error in mp_wklist_cust_print_example script", this, "custom-print.js", "frontEndCustomPrintExample");
        }
    };
   // convert printData to an object
    var printDataObj = JSON.parse(printData);
   // remove Bedrock object as it is not used in the example and can be very large which could cause errors
   delete printDataObj.PRINT_OPTIONS.BEDROCK;
   // convert the new object back to a string preserving the .0s for the float values to prevent CCL conversion errors
   var jsonParamString = MP_Util.enhancedStringify(printDataObj, 0, 0, true, [
       "USER_ID",
       "POSITION_CD",
       "PERSON_ID",
       "ENCNTR_ID",
       "PPR_CD"
   ]);
   var scriptRequest = new ScriptRequest();
   scriptRequest.setProgramName("mp_wklist_patient_list");
   scriptRequest.setDataBlob(jsonParamString);
   scriptRequest.setParameterArray(["^MINE^"]);
   scriptRequest.setResponseHandler(createHTML);
   scriptRequest.setSkipQueueIndicator(true);
   scriptRequest.performRequest();
}



function simpleIpassTemplate() {
    var createHTML = function(scriptReply) {
        var response = scriptReply.getResponse();
        if (response.STATUS_DATA.STATUS === "S") {
            var patients = response.PATIENTS;
            var completeMockData = response.MOCK_DATA;
            var mockIndex = 0;
            /**
            * Creates the diagnosis HTML using mock data.
            * @param {Object} mockData - Mock Data information
            * @method getDiagnosisHTML
            * @private
            * @returns {String} Diagnosis html string
            */
            function getDiagnosisHTML(mockData) {
                return mockData.DIAGNOSIS.map(function(diagnosis) {
                    return "<div>" + diagnosis.NAME_DISP + "</div>";
                }).join("");
            }
            /**
            * Creates the Actions HTML using mock data.
            * @param {Object} mockData - Mock Data information
            * @method getActionsHTML
            * @private
            * @returns {String} Actions html string
            */
            function getActionsHTML(mockData) {
                return mockData.ACTIONS.map(function(action) {
                    return "<div>" + action.NAME_DISP + "</div>";
                }).join("");
            }
            /**
            * Creates Data time string to place in print window.
            * @method getCurrentDateTime
            * @private
            * @returns {String} Date Time String
            */
            function getCurrentDateTime() {
                var currentdate = new Date();
                var printedDateTime = (currentdate.getMonth() + 1) + "/"
                    + currentdate.getDate() + "/"
                    + currentdate.getFullYear() + " "
                    + currentdate.getHours() + ":"
                    + currentdate.getMinutes();
                return printedDateTime;
            }
            var printTemplateHTML = patients.map(function(patient, index) {
                mockIndex = (index + 1) % 2;
                var currentMockData = completeMockData[mockIndex];
                var diagnosisHTML = getDiagnosisHTML(currentMockData);
                var actionsHTML = getActionsHTML(currentMockData);
                var patientEntryHTML = [
                        '<tr class="table-row-1">',    
                            '<td>',
                                '<div class="cell-content">',
                                    '<div>',
                                        'Name: ' + patient.NAME_FULL,
                                    '</div>',
                                    '<div>',
                                        'Date of Birth: ' + patient.BIRTH_DT,
                                    '</div>',
                                    '<div>',
                                        'Age: ' + patient.AGE,
                                    '</div>',
                                    '<div>',
                                        'Room & Bed: ' + patient.LOCATION,
                                    '</div>',
                                    '<div>',
                                        'MRN: ' + patient.MRN,
                                    '</div>',
                                    '<div>',
                                        'Admit Date: ' + patient.ADMIT_DT,
                                    '</div>',
                                    '<div>',
                                        'Cardiac Resuscitation Status: ' + patient.CARDIAC_RESUSCITATION_STATUS,
                                    '</div>',
                                    '<div>',
                                        'Respiratory Resuscitation Status: ' + patient.RESPIRATORY_RESUSCITATION_STATUS,
                                    '</div>',
                                '</div>',
                            '</td>',
                            '<td>',
                                '<div class="cell-content">',
                                    '<div>',
                                        patient.ILLNESS_SEV,
                                    '</div>',
                                '</div>',
                            '</td>',
                            '<td>',
                                '<div class="cell-content">',
                                    '<div>',
                                        patient.PATIENT_SUMMARY,
                                    '</div>',
                                '</div>',
                            '</td>',
                            '<td>',
                                '<div class="cell-content">',
                                    '<div>',
                                        patient.ACTIONS,
                                    '</div>',
                                '</div>',
                            '</td>',
                            '<td>',
                                '<div class="cell-content">',
                                    '<div>',
                                        patient.SIT_AWARE_TEXT,
                                    '</div>',
                                '</div>',
                            '</td>',
                            '<td>',
                                '<div class="cell-content">',
                                    '<div>',
                                        patient.WEIGHT,
                                    '</div>',
                                '</div>',
                            '</td>',
                        '</tr>'
                ].join("");
                return patientEntryHTML;
            }).join("");
            // Add header to begining of the print page.
            var printTest = [
            '<div class="print-header">',
                '<div class="printed-by-user">',
                    '<span>',
                        'Printed By: ' + response.PERSON_PRINTING_NAME,
                    '</span>',
                '</div>',
                '<div class="print-title">',
                    '<span>',
                        'Patient Handoff',
                    '</span>',
                '</div>',
                '<div class="printed-date">',
                    '<span>',
                        getCurrentDateTime(),
                    '</span>',
                '</div>',
            '</div>'
            ].join("");
            //start the table tag
            var tableStart = [
                '<div class="table-container"><table>',
                    '<tr class="table-row-1">',
                        '<td>',
                            '<div class="cell-header">Identifying Info</div>',
                        '</td>',
                        '<td>',
                            '<div class="cell-header">Illness Severity</div>',
                        '</td>',
                        '<td>',
                            '<div class="cell-header">Patient Summary</div>',
                        '</td>',
                        '<td>',
                            '<div class="cell-header">Action Items</div>',
                        '</td>',
                        '<td>',
                            '<div class="cell-header">Situational Awareness</div>',
                        '</td>',
                        '<td>',
                            '<div class="cell-header">Weight for Calc</div>',
                        '</td>',
                    '</tr>'
            ].join("");
            //end the table tag
            var tableEnd = [
                '</table></div>'
            ].join("");
            printTemplateHTML = printTest + tableStart + printTemplateHTML + tableEnd;
            mountPrintContainer(printTemplateHTML);
        }
        else {
            logger.logJSError("Error in simple_ipass_template script", this, "custom-print.js", "frontEndCustomPrintExample");
        }
    };
   // convert printData to an object
    var printDataObj = JSON.parse(printData);
   // remove Bedrock object as it is not used in the example and can be very large which could cause errors
   delete printDataObj.PRINT_OPTIONS.BEDROCK;
   // convert the new object back to a string preserving the .0s for the float values to prevent CCL conversion errors
   var jsonParamString = MP_Util.enhancedStringify(printDataObj, 0, 0, true, [
       "USER_ID",
       "POSITION_CD",
       "PERSON_ID",
       "ENCNTR_ID",
       "PPR_CD"
   ]);
   var scriptRequest = new ScriptRequest();
   scriptRequest.setProgramName("mp_wklist_simple_ipass");
   scriptRequest.setDataBlob(jsonParamString);
   scriptRequest.setParameterArray(["^MINE^"]);
   scriptRequest.setResponseHandler(createHTML);
   scriptRequest.setSkipQueueIndicator(true);
   scriptRequest.performRequest();
}

function detailedIpassTemplate() {
    var createHTML = function(scriptReply) {
        var response = scriptReply.getResponse();
        if (response.STATUS_DATA.STATUS === "S") {
            var patients = response.PATIENTS;
            var completeMockData = response.MOCK_DATA;
            var mockIndex = 0;
            /**
            * Creates the diagnosis HTML using mock data.
            * @param {Object} mockData - Mock Data information
            * @method getDiagnosisHTML
            * @private
            * @returns {String} Diagnosis html string
            */
            function getDiagnosisHTML(mockData) {
                return mockData.DIAGNOSIS.map(function(diagnosis) {
                    return "<div>" + diagnosis.NAME_DISP + "</div>";
                }).join("");
            }
            /**
            * Creates the Actions HTML using mock data.
            * @param {Object} mockData - Mock Data information
            * @method getActionsHTML
            * @private
            * @returns {String} Actions html string
            */
            function getActionsHTML(mockData) {
                return mockData.ACTIONS.map(function(action) {
                    return "<div>" + action.NAME_DISP + "</div>";
                }).join("");
            }
            /**
            * Creates Data time string to place in print window.
            * @method getCurrentDateTime
            * @private
            * @returns {String} Date Time String
            */
            function getCurrentDateTime() {
                var currentdate = new Date();
                var printedDateTime = (currentdate.getMonth() + 1) + "/"
                    + currentdate.getDate() + "/"
                    + currentdate.getFullYear() + " "
                    + currentdate.getHours() + ":"
                    + currentdate.getMinutes();
                return printedDateTime;
            }
            var printTemplateHTML = patients.map(function(patient, index) {
                mockIndex = (index + 1) % 2;
                var currentMockData = completeMockData[mockIndex];
                var diagnosisHTML = getDiagnosisHTML(currentMockData);
                var actionsHTML = getActionsHTML(currentMockData);
                var patientEntryHTML = [
                        '<tr class="table-row-1">',    
                            '<td class="location">',
                                '<div class="cell-content">',
                                    '<div>',
                                        '<b><u>Identifying Info:</b></u>',
                                    '</div>',
                                    '<div>',
                                        'Name: ' + patient.NAME_FULL,
                                    '</div>',
                                    '<div>',
                                        'Date of Birth: ' + patient.BIRTH_DT,
                                    '</div>',
                                    '<div>',
                                        'Age: ' + patient.AGE,
                                    '</div>',
                                    '<div>',
                                        'Room & Bed: ' + patient.LOCATION,
                                    '</div>',
                                    '<div>',
                                        'MRN: ' + patient.MRN,
                                    '</div>',
                                    '<div>',
                                        'Admit Date: ' + patient.ADMIT_DT,
                                    '</div>',
                                    '<div>',
                                        'Weight for Calc: ' + patient.WEIGHT,
                                    '</div>',
                                    '<div>',
                                        'Cardiac Resuscitation Status: ' + patient.CARDIAC_RESUSCITATION_STATUS,
                                    '</div>',
                                    '<div>',
                                        'Respiratory Resuscitation Status: ' + patient.RESPIRATORY_RESUSCITATION_STATUS,
                                    '</div>',
                                    '<div>',
                                        '<br><b><u>Illness Severity:</u></b> ' + patient.ILLNESS_SEV,
                                    '</div>',
                                    '<div>',
                                        '<br><b><u>Patient Summary:</u></b> ' + patient.PATIENT_SUMMARY,
                                    '</div>',
                                    '<div>',
                                        '<br><b><u>Action Items:</u></b> ' + patient.ACTIONS,
                                    '</div>',
                                    '<div>',
                                        '<br><b><u>Situational Awareness:</u></b> ' + patient.SIT_AWARE_TEXT,
                                    '</div>',
                                '</div>',
                            '</td>',
                            '<td class="location">',
                                '<div class="cell-content">',
                                    '<div>',
                                        '<b><u>Problems:</u></b> ' + patient.PROBLEM,
                                    '</div>',
                                    '<div>',
                                        '<br><b><u>Active Inpatient Medication Orders:</u></b> ' + patient.ORDERS,
                                    '</div>',
                                    '<div>',
                                        '<br><b><u>Vital Signs:</u></b> ' + patient.VITAL_SIGN,
                                    '</div>',
                                    '<div>',
                                        '<br><b><u>Ins & Outs:</u></b> ' + patient.INS_AND_OUTS,
                                    '</div>',
                                '</div>',
                            '</td>',
                            '<td class="location">',
                                '<div class="cell-content">',
                                    '<div>',
                                        '<b><u>Labs:</u></b> ' + patient.LABS,
                                    '</div>',
                                    '<div>',
                                        '<br><b><u>Micro:</u></b> ' + patient.MICRO,
                                    '</div>',
                                '</div>',
                            '</td>',
                        '</tr>'
                ].join("");
                return patientEntryHTML;
            }).join("");
            // Add header to begining of the print page.
            var printTest = [
            '<div class="print-header">',
                '<div class="printed-by-user">',
                    '<span>',
                        'Printed By: ' + response.PERSON_PRINTING_NAME,
                    '</span>',
                '</div>',
                '<div class="print-title">',
                    '<span>',
                        'Patient Handoff',
                    '</span>',
                '</div>',
                '<div class="printed-date">',
                    '<span>',
                        getCurrentDateTime(),
                    '</span>',
                '</div>',
            '</div>'
            ].join("");
            //start the table tag
            var tableStart = [
                '<div class="table-container"><table>',
                    /*'<tr class="table-row-1">',
                        '<td class="location">',
                            '<div class="cell-header">Identifying Info</div>',
                        '</td>',
                        '<td class="location">',
                            '<div class="cell-header">Illness Severity</div>',
                        '</td>',
                        '<td class="location">',
                            '<div class="cell-header">Patient Summary</div>',
                        '</td>',
                        '<td class="location">',
                            '<div class="cell-header">Action Items</div>',
                        '</td>',
                        '<td class="location">',
                            '<div class="cell-header">Situational Awareness</div>',
                        '</td>',
                        '<td class="location">',
                            '<div class="cell-header">Weight for Calc</div>',
                        '</td>',
                    '</tr>'*/
            ].join("");
            //end the table tag
            var tableEnd = [
                '</table></div>'
            ].join("");
            printTemplateHTML = printTest + tableStart + printTemplateHTML + tableEnd;
            mountPrintContainer(printTemplateHTML);
        }
        else {
            logger.logJSError("Error in detailed_ipass_template script", this, "custom-print.js", "frontEndCustomPrintExample");
        }
    };
   // convert printData to an object
    var printDataObj = JSON.parse(printData);
   // remove Bedrock object as it is not used in the example and can be very large which could cause errors
   delete printDataObj.PRINT_OPTIONS.BEDROCK;
   // convert the new object back to a string preserving the .0s for the float values to prevent CCL conversion errors
   var jsonParamString = MP_Util.enhancedStringify(printDataObj, 0, 0, true, [
       "USER_ID",
       "POSITION_CD",
       "PERSON_ID",
       "ENCNTR_ID",
       "PPR_CD"
   ]);
   var scriptRequest = new ScriptRequest();
   scriptRequest.setProgramName("mp_wklist_detailed_ipass");
   scriptRequest.setDataBlob(jsonParamString);
   scriptRequest.setParameterArray(["^MINE^"]);
   scriptRequest.setResponseHandler(createHTML);
   scriptRequest.setSkipQueueIndicator(true);
   scriptRequest.performRequest();
}
/*
    This is intended as a very basic example of how to implement a selector when the custom print window opens and changing the content
    in the window based on the selection.
*/
function templateSelector(){
alert("patients");
    // create the basic HTML that provides a target element for the print content (main-content) and the modal window with the
    //    selction options.  An array is used to help illustrate the HTML structure that will be created.
    var content = [
        //'<button id="openModal" type="button">Template Selector</button>',
        '<div class="main-content"></div>',
        '<div class="page-overlay"></div>',
        '<div class="selector-modal">',
            '<div class="modal-content">',
                '<div class="modal-msg">Template Selector</div>',
                '<select>',
                    '<option value=0>Select a Template</option>',
                    '<option value=1>Simplified</option>',
                    '<option value=2>Detailed</option>',
                    '<option value=3>Provider List</option>',
		    '<option value=4>Provider Group List</option>',
                '</select>',
                '<div class="modal-btns">',
                    '<button id="okBtn" type="button">OK</button>',
                    '<button id="cancelBtn" type="button">Cancel</button>',
                '</div>',
        '</div>']
    // Add the content to the print window using the provided function
    mountPrintContainer(content.join(""));
    // Initialize the event handlers for the button clicks and selections
    initSelectorEvents();
}
/*
    This object contains the functions that will be called to open and close the selector modal and update the print content in
        .main-content when a selection is made and the OK button is clicked
*/
var selectorMethods = {
    closeModal: function() {
      // hide the template selector and background overlay by adding the hidden class using jQuery
      $(".page-overlay").addClass("hidden");
      $(".selector-modal").addClass("hidden");
    },
    openModal: function() {
      // hide the template selector and background overlay by removing the hidden class using jQuery
      $(".page-overlay").removeClass("hidden");
      $(".selector-modal").removeClass("hidden");
    },
    renderSelectedTemplate: function(templateId){
      var printContent = "";
      if(templateId == 1){
        //printContent = "You have rendered Simple Patient List";
        simpleIpassTemplate();
      }
      else if (templateId == 2){
        //printContent = "You have rendered Simple IPASS";
        //$(".main-content").html(printContent);
        detailedIpassTemplate();
      }
      else if(templateId == 3){
        //printContent = "You have rendered Detailed IPASS";
        //$(".main-content").html(printContent);
        frontEndCustomPrintExample();
      }
      else if(templateId == 4){
        //printContent = "You have rendered Detailed IPASS";
        //$(".main-content").html(printContent);
        providerGroupListTemplate();
      }

      // update the content to be printed using jQuery's html() function
    },
}
/*
    This function resgisters the click events using jQuery for when the Template Selector, OK and Cancel buttons are clicked
*/
function initSelectorEvents(){
    $("#cancelBtn").click(function(){
      selectorMethods.closeModal();
    });
    $("#openModal").click(function(){
      selectorMethods.openModal();
    })
    $("#okBtn").click(function(){
      var templateId = $(".modal-content select").val();
      // If a template has not been chosen, exit out of the function
      if(templateId == 0) {
        return;
      }
      // call the function to update the print content
      selectorMethods.renderSelectedTemplate(templateId);
      // reset the selector back to the placeholder for the next time if the modal is reopened
      $(".modal-content select").val(0);
      // close the Template Selector modal
      selectorMethods.closeModal();
    });
}