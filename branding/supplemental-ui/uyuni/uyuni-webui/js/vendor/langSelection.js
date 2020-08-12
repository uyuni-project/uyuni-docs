function selectLanguage(langId) {

    var str = window.location.pathname;
    var regexPattern =/\/..\// ;

    var matchCode = "/" + langId + "/" ;

    var newURL = str.replace(regexPattern, matchCode);
    window.location.href = newURL;

}
