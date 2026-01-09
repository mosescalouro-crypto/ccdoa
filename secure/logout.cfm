<!-- /secure/logout.cfm -->
<cfscript>
tenantId = "9148e003-3624-435d-99d6-bee88e1ce522"; // your tenant
dest     = "https://ccdoa.motioninfo.com/secure/loggedout.cfm";

try {
  // Use the same component name your ACS uses
  samlUtils = createObject("component","samlUtils");

  // If your SAMLUtils needs NameID/SessionIndex, set them here from session.saml
  // (uncomment if your helper exposes setters)
  // if (structKeyExists(session,"saml")) {
  //   samlUtils.setNameID(session.saml.nameid);
  //   samlUtils.setSessionIndex(session.saml.sessionIndex);
  // }

  sloURL = samlUtils.GenerateSAMLLogoutRequest(
    idpName     = "AuthIDPConfiguration",
    spName      = "AuthSPConfiguration",
    redirectURL = dest
  );

  lock scope="session" type="exclusive" timeout="5" { structClear(session); }
  location(url=sloURL, addtoken=false);

} catch (any e) {
  // Fallback: generic Entra logout

  msLogout = "https://login.microsoftonline.com/#tenantId#/oauth2/v2.0/logout"&"?post_logout_redirect_uri=#urlEncodedFormat(dest,'utf-8')#";
		   
  lock scope="session" type="exclusive" timeout="5" { structClear(session); }
  location(url=msLogout, addtoken=false);
}
</cfscript>
