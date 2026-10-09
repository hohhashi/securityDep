((win, doc) => {
var req = new XMLHttpRequest();
req.open("GET", "/-/Media/Ricoh/Common/cmn_g_header_footer/js/initBase.js", false);
req.send();
eval(req.responseText);
})(window, document);
