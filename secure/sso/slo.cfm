<!-- /secure/sso/slo.cfm -->
<cftry>
  <!-- your SAML helper -->
  <cfset samlUtils = createObject("component","SAMLUtils")>

  <!-- where users land after SLO; also set this as Logout URL in Entra -->
  <cfset dest = "/secure/loggedout.cfm">

  <!-- If Entra is calling us (IdP-initiated), SAMLRequest will be on URL or form -->
  <cfset isIdPInitiated = structKeyExists(url,"SAMLRequest") OR structKeyExists(form,"SAMLRequest")>

  <cfif isIdPInitiated>
    <cflog file="saml" type="information" text="SLO: IdP-initiated request at #cgi.script_name#">

    <!-- Let your library validate & (optionally) craft a LogoutResponse -->
    <cfset logoutResult = samlUtils.ProcessSAMLLogoutRequest(
      idpName = "AuthIDPConfiguration",
      spName  = "AuthSPConfiguration"
    )>

    <cfif logoutResult.success>
      <!-- clear local session -->
      <cflock scope="session" type="exclusive" timeout="5">
        <cfset structClear(session)>
      </cflock>

      <!-- if your lib returns a response URL to send back to Entra, honor it -->
      <cfif structKeyExists(logoutResult,"responseURL") AND len(logoutResult.responseURL)>
        <cflocation url="#logoutResult.responseURL#" addtoken="false">
      </cfif>

      <!-- otherwise finish locally -->
      <cflocation url="#dest#" addtoken="false">
    <cfelse>
      <cflog file="saml" type="error"
             text="SLO error: #logoutResult.error.code# - #logoutResult.error.message#">
      <cfoutput><h2>Logout Failed</h2><p>#encodeForHTML(logoutResult.error.message)#</p></cfoutput>
      <cfabort>
    </cfif>

  <cfelse>
    <!-- SP-initiated SLO: build a LogoutRequest and redirect to Entra -->
    <cflog file="saml" type="information" text="SLO: SP-initiated start">

    <!-- If your library needs NameID / SessionIndex, set them here from session.saml -->
    <!-- Example (uncomment if your SAMLUtils exposes these): 
         samlUtils.setNameID( structKeyExists(session,'saml') ? session.saml.nameid : '' );
         samlUtils.setSessionIndex( structKeyExists(session,'saml') ? session.saml.sessionIndex : '' );
    -->

    <cfset sloURL = samlUtils.GenerateSAMLLogoutRequest(
      idpName     = "AuthIDPConfiguration",
      spName      = "AuthSPConfiguration",
      redirectURL = dest   <!-- RelayState / post-logout target -->
    )>

    <!-- clear local session before leaving -->
    <cflock scope="session" type="exclusive" timeout="5">
      <cfset structClear(session)>
    </cflock>

    <!-- hand off to Entra -->
    <cflocation url="#sloURL#" addtoken="false">
  </cfif>

  <cfcatch>
    <cflog file="saml" type="error" text="SLO exception: #cfcatch.type# - #cfcatch.message#">
    <cfoutput><h2>Logout Error</h2><p>#encodeForHTML(cfcatch.message)#</p></cfoutput>
    <cfabort>
  </cfcatch>
</cftry>
