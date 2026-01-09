<cfset samlUtils = createObject("component", "SAMLUtils")>

<!--- Check for IdP-initiated Logout (LogoutRequest in URL) --->
<cfif structKeyExists(url, "SAMLRequest")>
    <cftry>

        <cftry>
            <cfset logoutResult = samlUtils.ProcessSAMLLogoutRequest(idpName = "AuthIDPConfiguration",
            spName  = "AuthSPConfiguration")>
            <cfdump var="#logoutResult#" abort="true">
            <cfcatch>
                <!--- Fallback if SLO not supported --->
                <!--- <cflocation url="/SSOTestProject/logout.cfm" addtoken="no"> --->
                <!--- Handle errors --->
                <cfdump var="#cfcatch#" label="SAML ACS Error">
                <cfabort>
            </cfcatch>
        </cftry>


        <cfif logoutResult.success>
            <!--- Clear session --->
            <cfif structKeyExists(session, "authenticated")>
                <cflock scope="session" type="exclusive" timeout="5">
                    <cfset structDelete(session, "authenticated")>
                    <cfset structDelete(session, "userAttributes")>
                    <cfset structDelete(session, "samlResponse")>
                </cflock>
            </cfif>
            <!--- Redirect to logout success page --->
            <cflocation url="/SSOTestProject/logout.cfm" addtoken="no">
        <cfelse>
            <!--- Show error to user --->
            <cfoutput>
                <h2>Logout Failed</h2>
                <p><strong>Error Code:</strong> #logoutResult.error.code#</p>
                <p><strong>Message:</strong> #logoutResult.error.message#</p>
            </cfoutput>
        </cfif>

        <cfcatch>
            <cfoutput>
                <h2>Unexpected Logout Error</h2>
                <p><strong>Error:</strong> #cfcatch.message#</p>
                <p><strong>Detail:</strong> #cfcatch.detail#</p>
            </cfoutput>
        </cfcatch>
    </cftry>

<!--- SP-initiated logout --->
<cfelse>
    <!--- Clear session --->
    <!--- <cfif structKeyExists(session, "authenticated")>
        <cflock scope="session" type="exclusive" timeout="5">
            <cfset structDelete(session, "authenticated")>
            <cfset structDelete(session, "userAttributes")>
            <cfset structDelete(session, "samlResponse")>
        </cflock>
    </cfif> --->

    <!--- Generate LogoutRequest and redirect to IdP --->
    <cftry>
        <cfset logoutURL = samlUtils.GenerateSAMLLogoutRequest(idpName = "AuthIDPConfiguration",
            spName  = "AuthSPConfiguration", redirectURL="/")>

        <!--- <cfdump var="#logoutURL#"> --->
        <cflocation url="#logoutURL#" addtoken="no">
        <cfcatch>
            <!--- Fallback if SLO not supported --->
            <!--- <cflocation url="/SSOTestProject/logout.cfm" addtoken="no"> --->
            <!--- Handle errors --->
            <cfdump var="#cfcatch#" label="SAML ACS Error">
            <cfabort>
        </cfcatch>
    </cftry>
</cfif>
