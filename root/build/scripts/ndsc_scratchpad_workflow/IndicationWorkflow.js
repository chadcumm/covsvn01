var person_id = "";
var encounter_id = "";
var user_id = "";
var baseUrl = "";
var siteId = "";
var dsn = "";
var token = "";
var basePortalUrl = "";
var metadata = "";
var hasOriginalCacheKey = true;

function LaunchHTMLIndicationMode(personId, encounterId, userId, dsnId, site, url, apiToken) {
    person_id = personId;
    encounter_id = encounterId;
    user_id = userId;
    baseUrl = url;
    siteId = site;
    dsn = dsnId;
    token = apiToken;
    metadata = personId + "-" + encounterId + "-" + userId;
    GetConfigs(function (configData) {
        basePortalUrl = configData.Configuration.CernerBasePortalUrl;
        hasOriginalCacheKey = configData.Configuration.hasOwnProperty("CernerCacheKeyExam") && configData.Configuration.CernerCacheKeyExam.toLowerCase() === "true";
    });
};

function GetConfigs(callback) {
    $.ajax({
        type: "GET",
        url: baseUrl + "integration/cerner/configurations/",
        headers: { 'Authentication': token },
        async: false,
        contentType: "application/json",
        success: function (data, status, req) {
            callback(data);
        },
        error: function (req, status, error) {
        }
    });
};

function GetResults(callback) {
    $.ajax({
        type: "GET",
        url: baseUrl + "api/Integration/CernerOrder/GetOrderData?ids=" + dsn + "&siteId=" + siteId + "&isDsn=true",
        headers: { 'authentication': token },
        async: false,
        success: function (data, status, req) {
            var results = {};
            results.synonym_id = data.Responses[0].CustomerExamId;
            callback(results);
        },
        error: function (req, status, error) {
            ///TODO Change this logic
            APPLINK(0, "Powerchart.exe", "/PERSONID=" + person_id + " /ENCNTRID=" + encounter_id + " /FIRSTTAB=^Orders^");
        }
    });

};

function SetMetadata(examId) {

    if (!hasOriginalCacheKey) {
        metadata += "-" + examId;
    }
    $.ajax({
        type: "POST",
        url: baseUrl + "integration/cerner/setindicationsessiondetails/" + metadata + "/" + dsn,
        headers: { 'Authentication': token },
        async: false,
        contentType: "application/json",
        success: function (data, status, req) {
        },
        error: function (req, status, error) {
        }
    });
};

function receiveMessage(event) {

    var acrSelect = ".acrselect.org";
    var careSelect = ".careselect.org";
    var esriGuide = ".esriguide.org";
    if (((event.origin.indexOf(careSelect, (event.origin.length - careSelect.length)) !== -1)
        || (event.origin.indexOf(acrSelect, (event.origin.length - acrSelect.length)) !== -1)
        || (event.origin.indexOf(esriGuide, (event.origin.length - esriGuide.length)) !== -1))
        && event.data === dsn) {

        GetResults(function (results) {
            SetMetadata(results.synonym_id);
            var mpageOrders = "{ORDER|" + results.synonym_id + ".00|0|0|0|1}";
            MPAGES_EVENT("ORDERS", person_id + ".00|" + encounter_id + ".00|" + mpageOrders + "|24|{2|127}|32|1");
            APPLINK(0, "Powerchart.exe", "/PERSONID=" + person_id + " /ENCNTRID=" + encounter_id + " /FIRSTTAB=^Orders^");
        });
        return;
    }
    else {
        APPLINK(0, "Powerchart.exe", "/PERSONID=" + person_id + " /ENCNTRID=" + encounter_id + " /FIRSTTAB=^Orders^");
    }
};

window.addEventListener("message", receiveMessage, false);