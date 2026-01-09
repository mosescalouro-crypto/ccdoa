
<cftry>
    <!--- Create SAMLUtils component --->
    <cfset samlUtils = createObject("component", "samlUtils")>

    
    <!--- Check if this is ACS (IdP POST with SAMLResponse) --->
    <cfif structKeyExists(form, "SAMLResponse")>

        <cfset fullUrl = CGI.HTTP_HOST & CGI.SCRIPT_NAME>
        <cfif len(CGI.QUERY_STRING)>
            <cfset fullUrl &= "?" & CGI.QUERY_STRING>
        </cfif>
        <cfquery datasource="CCDOA">
            INSERT INTO SAML_Responses (FullURL,process,SAMLResponse)
            VALUES (
                '#fullUrl#',
                '1',
                <cfif isDefined('form.SAMLResponse')>
                    '#form.SAMLResponse#'
                <cfelse>
                    ,'test'
                </cfif>
            )
        </cfquery>
      <cfdump var="#form#">
        <!--- Process the SAML response --->
        <cfset samlResult = samlUtils.ProcessSAMLResponse(
            idpName = "AuthIDPConfiguration",
            spName  = "AuthSPConfiguration"
        )>
        <cfdump var="#samlResult#"><cfabort>
        <cfif samlResult.success>
		
		
		<cfset attrs = samlResult.ATTRIBUTES ?: {} />

<cfscript>
function claim(k){ if (!structKeyExists(attrs,k)) return ""; var v=attrs[k]; return isArray(v)?v[1]:v; }

// Your actual claims present in the dump:
oid     = claim("http://schemas.microsoft.com/identity/claims/objectidentifier");
upn     = claim("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"); // UPN/email
display = claim("http://schemas.microsoft.com/identity/claims/displayname");
given   = claim("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname");
surname = claim("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname");

// Mark session authenticated + stash identity
session.authenticated = true;
session.user = {
  id      : oid,
  username: upn,
  email   : upn,
  name    : display,
  given   : given,
  surname : surname,
  source  : "saml"
};
</cfscript>



	
            <!--- Save user info in session --->
            <cfset session.samlResponse   = samlResult>
            <cfset session.userAttributes = samlResult.ATTRIBUTES>
            <cfset session.authenticated  = true>

            <!--- Extract email if available --->
            <cfif structKeyExists(samlResult.ATTRIBUTES, "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress")>
                <cfset userEmail = samlResult.ATTRIBUTES["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"]>
                <cfoutput>Email: #userEmail#</cfoutput>

            <cfelse>	    
                <cfoutput>Email not found.</cfoutput>
            </cfif>

            <!--- Redirect to your app home/dashboard --->
          <cflocation url="/secure/" addtoken="false"> 

        <cfelse>
            <!--- Log and show error --->
            <cflog file="SSOTestProject" type="error" 
                   text="SAML Error: #samlResult.error.code# - #samlResult.error.message#">
            <cfoutput>
                <h2>SSO Error</h2>
                <p><strong>Error Code:</strong> #samlResult.error.code#</p>
                <p><strong>Message:</strong> #samlResult.error.message#</p>
            </cfoutput>
        </cfif>

    <cfelse>
        <!--- If no SAMLResponse, initiate login (AuthnRequest) --->
        <cfset redirectURL = "../../index.cfm">
        <cfset location = samlUtils.GenerateSAMLRequest(
            idpName    = "AuthIDPConfiguration",
            spName     = "AuthSPConfiguration",
            redirectURL = redirectURL
        )>

       <cflocation url="#location#" addtoken="false">

    </cfif>

    <cfcatch>
        <!--- Handle unexpected errors --->
       <cfdump var="#cfcatch#" label="SAML ACS Error"> 
        <cfabort>
    </cfcatch>
</cftry>
