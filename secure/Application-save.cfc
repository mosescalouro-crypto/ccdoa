
 
 <cfcomponent> 
<cfset THIS.name = "CCDOAAdmin"> 
<cfset THIS.Sessionmanagement="True"> 
<cfset THIS.ApplicationTimeout = CreateTimeSpan( 7, 0, 0, 0 ) />
<cfset THIS.SessionTimeout = CreateTimeSpan( 7, 0, 0, 0 ) />
<cfset THIS.loginstorage="session">

<cfset this.security = {
    samlsettings = {
        idp = [{
            name: "AuthIDPConfiguration",
            entityID: "https://sts.windows.net/9148e003-3624-435d-99d6-bee88e1ce522/",
            ssoURL: "https://login.microsoftonline.com/9148e003-3624-435d-99d6-bee88e1ce522/saml2",
            sloURL: "https://login.microsoftonline.com/9148e003-3624-435d-99d6-bee88e1ce522/saml2",
            ssoBinding: "POST",
            sloBinding: "REDIRECT",
            signMessage: true,
            signrequests: true,
            encryptrequests: false,
            signcertificate: "MIIC8DCCAdigAwIBAgIQG1EKwROtTatK/cgWGPxV6jANBgkqhkiG9w0BAQsFADA0MTIwMAYDVQQDEylNaWNyb3NvZnQgQXp1cmUgRmVkZXJhdGVkIFNTTyBDZXJ0aWZpY2F0ZTAeFw0yNTA3MjQxOTU4MzlaFw0yODA3MjQxOTU4MzlaMDQxMjAwBgNVBAMTKU1pY3Jvc29mdCBBenVyZSBGZWRlcmF0ZWQgU1NPIENlcnRpZmljYXRlMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAy9EZC9IoIkcv7wNZcVww+DO+OcHNbrPFFo19/Z0UYkYyGEVglncITdc3+kd3OaptVwfliGILEno/8t8o5uHi7XIh48q6HgRjizAFYtzLZ5tKjjWWr/86jlI5ECiZhuVM/iY0EDJG0W2MPoSUulaXdalzXi0q49m45F+a2wdUV4lyUWtPC1BdwRA9+In8dYTBqMKuIz4iSoqP8lQD2Hz/2Wr0qjBw1tpdVl6U0BMAr4iH5v7d6niJIo1qfXP80kXCYbNscLrs1P/b/JeKCjVdMh59hcVxXPF/Af2RO9KLhPBcmCvK6tmQJBazWPiXuDVOwd5OG76qvIoQggSYkUKz1QIDAQABMA0GCSqGSIb3DQEBCwUAA4IBAQC1iSnXr64Waz5p230yQZA1arIcat/orgje4X8lD4HfrDoJNrvc4exdKjqBOaUj2JsW+UwIMqD6THjTFt32XQ/YW4vTMLaqIFrpVgktvx1QeJdWqqEpcfO9MbYeWHYqTUeQ5WH8/IZfAH2cRGKuBnMp9gxIFnubmiwKhyuuB3jHNYYauqOBR6tihR/n6x0Kl+BgbxTaq7Q68EYZWEwJW2c++ifsmgWQMR6Wx/zM9cyrDbrP0asKo/NuWmspABbm0rj0tRKYGnR6goxJqzNncJkPjXwZinfkb69/sDql/BsRGzgWoZ7qm4dWpxy9wJQS0hnN+o5bz5wwYvGyfcBpDGeC"
        }],
        sp = [{
              name: "AuthSPConfiguration",
              entityId: "https://ccdoa.motioninfo.com/secure/sso/metadata/",
              acsURL: "https://ccdoa.motioninfo.com/secure/sso/metadata/",
              sloURL: "https://ccdoa.motioninfo.com/secure/sso/slo.cfm",
              acsbinding: "POST",
              slobinding: "REDIRECT",
              signrequests: false,
              wantassertionssigned: false,
              logoutresponsesigned: false,
              checkreplayattack: false,
              requeststore: "memory",
              requeststoretimeout: 300
        }]
    }
}>
 
<cffunction name="OnRequestStart">

    <cfargument name = "request" required="true"/> 

    <cfif IsDefined("url.logout")> 
        <cflogout>
    </cfif> 
    <cfset application.security = this.security>
    <cfscript>
        application.dateformat = 'mm/dd/yy';
        application.dateformat_long = 'mm/dd/yyyy';
        application.timeformat = 'HH:mm';
 
        setLocale("English (US)");
    </cfscript>
 
    <cflogin> 
        <cfif NOT IsDefined("cflogin")> 
            <cfinclude template="login.cfm"> 
            <cfabort> 
        <cfelse> 
            <cfif cflogin.name IS "" OR cflogin.password IS ""> 
                <cfoutput> 
                    <h2>You must enter text in both the User Name and Password fields. 
                    </h2> 
                </cfoutput> 
                <cfinclude template="login.cfm"> 
                <cfabort> 
            <cfelse>
                <!--- SHA1 (Apache) Hash --->
                <cfset hash = "{SHA}" & ToBase64(BinaryDecode(Hash(cflogin.password, "SHA1"), "Hex"))>

                <cfquery name="loginQuery" dataSource="CCDOA"> 
                    SELECT username from users
                    WHERE 
                        username = '#cflogin.name#' 
                        AND hash = '#hash#'
                </cfquery> 
                <cfif len(loginQuery.username)>
                    <cfset pacificNow = dateTimeFormat(now(), "yyyy-mm-dd HH:nn:ss", "America/Los_Angeles")>

                    <cfloginuser name="#cflogin.name#" Password = "#cflogin.password#" 
                        roles="">
					<cfquery name="loginQuery" dataSource="CCDOA"> 
                        Update users 
                        <!--- set LastLogin = getdate()--->
                        set LastLogin = '#pacificNow#'
                        WHERE username = '#cflogin.name#' 
					</cfquery>
                     <cfquery datasource="CCDOA" name="theUser">
                        SELECT id,username,first_name,last_name,email,admin from users
                        where username = '#cflogin.name#'
                      </cfquery>
                  
                      <cfcookie name="user_id" value="#theUser.id#"></cfcookie>
                      <cfcookie name="username" value="#theUser.username#"></cfcookie>
                      <cfcookie name="admin" value="#theUser.admin#"></cfcookie>
                <cfelse> 
                    <cfoutput> 
                        <H2>Your login information is not valid.<br> 
                        Please Try again</H2> 
                    </cfoutput>     
                    <cfinclude template="login.cfm"> 
                    <cfabort> 
                </cfif> 
            </cfif>     
        </cfif> 
    </cflogin> 
 
</cffunction> 
</cfcomponent>