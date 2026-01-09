<cfcomponent>
  <!-- App/session config -->
  <cfset this.name               = "CCDOAAdmin">
  <cfset this.sessionManagement  = true>
  <cfset this.sessionType        = "J2EE"> <!-- use JSESSIONID -->
  <cfset this.setClientCookies   = true>
  <cfset this.sessionCookie      = { httpOnly:true, secure:true, sameSite:"None" }> <!-- critical for SAML POST -->
  <cfset this.applicationTimeout = createTimeSpan(7,0,0,0)>
  <cfset this.sessionTimeout     = createTimeSpan(7,0,0,0)>
  <cfset this.loginStorage       = "session">

  <!-- SAML settings -->
  <cfset application.security = {
    samlsettings = {
      idp = [{
        name            : "AuthIDPConfiguration",
        entityID        : "https://sts.windows.net/9148e003-3624-435d-99d6-bee88e1ce522/",
        ssoURL          : "https://login.microsoftonline.com/9148e003-3624-435d-99d6-bee88e1ce522/saml2",
        sloURL          : "https://login.microsoftonline.com/9148e003-3624-435d-99d6-bee88e1ce522/saml2",
        ssoBinding      : "POST",
        sloBinding      : "REDIRECT",
        signMessage     : true,
        signRequests    : true,
        encryptRequests : false,
	     signcertificate: "MIIC8DCCAdigAwIBAgIQG1EKwROtTatK/cgWGPxV6jANBgkqhkiG9w0BAQsFADA0MTIwMAYDVQQDEylNaWNyb3NvZnQgQXp1cmUgRmVkZXJhdGVkIFNTTyBDZXJ0aWZpY2F0ZTAeFw0yNTA3MjQxOTU4MzlaFw0yODA3MjQxOTU4MzlaMDQxMjAwBgNVBAMTKU1pY3Jvc29mdCBBenVyZSBGZWRlcmF0ZWQgU1NPIENlcnRpZmljYXRlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAy9EZC9IoIkcv7wNZcVww+DO+OcHNbrPFFo19/Z0UYkYyGEVglncITdc3+kd3OaptVwfliGILEno/8t8o5uHi7XIh48q6HgRjizAFYtzLZ5tKjjWWr/86jlI5ECiZhuVM/iY0EDJG0W2MPoSUulaXdalzXi0q49m45F+a2wdUV4lyUWtPC1BdwRA9+In8dYTBqMKuIz4iSoqP8lQD2Hz/2Wr0qjBw1tpdVl6U0BMAr4iH5v7d6niJIo1qfXP80kXCYbNscLrs1P/b/JeKCjVdMh59hcVxXPF/Af2RO9KLhPBcmCvK6tmQJBazWPiXuDVOwd5OG76qvIoQggSYkUKz1QIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQC1iSnXr64Waz5p230yQZA1arIcat/orgje4X8lD4HfrDoJNrvc4exdKjqBOaUj2JsW+UwIMqD6THjTFt32XQ/YW4vTMLaqIFrpVgktvx1QeJdWqqEpcfO9MbYeWHYqTUeQ5WH8/IZfAH2cRGKuBnMp9gxIFnubmiwKhyuuB3jHNYYauqOBR6tihR/n6x0Kl+BgbxTaq7Q68EYZWEwJW2c++ifsmgWQMR6Wx/zM9cyrDbrP0asKo/NuWmspABbm0rj0tRKYGnR6goxJqzNncJkPjXwZinfkb69/sDql/BsRGzgWoZ7qm4dWpxy9wJQS0hnN+o5bz5wwYvGyfcBpDGeC"
      
      }],
      sp = [{
        name                  : "AuthSPConfiguration",
        entityId              : "https://ccdoa.motioninfo.com/secure/sso/metadata/",
        acsURL                : "https://ccdoa.motioninfo.com/secure/sso/metadata/",  
        sloURL                : "https://ccdoa.motioninfo.com/secure/sso/slo.cfm",
        acsBinding            : "POST",
        sloBinding            : "REDIRECT",
        signRequests          : false,
        wantAssertionsSigned  : false,
        logoutResponseSigned  : false,
        checkReplayAttack     : true,
        requestStore          : "memory",
        requestStoreTimeout   : 300
      }]
    }
  }>
  
  <cffunction name="onRequestStart" access="public" returntype="boolean" output="false">
  


  
  <cfargument name="targetPage" type="string" required="true">
  <cfscript>
    var p = lcase(cgi.script_name);

    // Allow SAML endpoints to run unauthenticated
    // matches: /secure/sso/acs.cfm   OR  /secure/sso/metadata/ (or /metadata/index.cfm)  OR  /secure/sso/slo.cfm
    if ( reFindNoCase("^/secure/sso/(acs\.cfm|metadata(/index\.cfm)?|slo\.cfm)$", p) ) {
      return true;
    }

    // Allow the login page itself
    if ( p EQ "/secure/login.cfm" ) {
      return true;
    }

    // If under /secure/ and not authenticated, either process a posted local login or redirect to login
    if ( left(p,8) EQ "/secure/" && !structKeyExists(session,"authenticated") ) {

      // If a login form was posted, validate here (keeps logic out of cflogin)
      if ( structKeyExists(form,"username") && structKeyExists(form,"password") ) {
        var hashVal = "{SHA}" & toBase64( binaryDecode( hash(form.password,"SHA1"), "Hex") );
        var q = queryExecute(
          "SELECT username FROM users WHERE username = ? AND hash = ?",
          [ {value=form.username, cfsqltype="cf_sql_varchar"},
            {value=hashVal,     cfsqltype="cf_sql_varchar"} ],
          { datasource: "CCDOA" }
        );
        if ( q.recordCount ) {
          session.authenticated = true;
          // optional: set who they are
          session.user = { upn=form.username, source="local" };
          return true;
        } else {
          location(url="/secure/login.cfm?err=1", addtoken=false);
          return false;
        }
      }

      // No session, no form → go to login
      location(url="/secure/login.cfm", addtoken=false);
      return false;
    }

    return true;
  </cfscript>
</cffunction>


</cfcomponent>
