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
                    'SAML Response not generated'
                </cfif>
            )
        </cfquery>

        <!--- Process the SAML response --->
        <cfset samlResult = samlUtils.ProcessSAMLResponse(
            idpName = "AuthIDPConfiguration",
            spName  = "AuthSPConfiguration"
        )>
        
        <cfif samlResult.success>

            <!--- Extract email if available --->
            <cfif structKeyExists(samlResult.ATTRIBUTES, "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name")>
                <cfset userEmail = samlResult.ATTRIBUTES["http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"]>
                <cfoutput>Email: #userEmail#</cfoutput>
            <cfelse>
                <cfoutput>Email not found.</cfoutput>
                <cfabort>
            </cfif>
            
            <!--- Lookup user --->
            <cfquery name="getlogData" datasource="CCDOA">
                SELECT top 1 id
                FROM SAML_Responses
                order by id desc
            </cfquery>
            <cfif getlogData.recordCount GT 0>
                <cfquery datasource="CCDOA">
                    Update SAML_Responses set Username = '#userEmail#' where id = '#getlogData.id#'
                </cfquery>
            </cfif>

            <!--- Lookup user --->
            <cfquery name="loginQuery" datasource="CCDOA">
                SELECT id, username, admin,hash
                FROM users
                WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#userEmail#">
            </cfquery>

            <cfif loginQuery.recordCount>
                <!--- Save session info --->
                <cfset session.userAttributes = samlResult.ATTRIBUTES>
                <cfset session.authenticated  = true>
                <cfset session.userID         = loginQuery.id>
                <cfset session.username       = loginQuery.username>
                <cfset session.isAdmin        = loginQuery.admin>
                <cfset session.sso            = true>

                <cfcookie name="user_id" value="#loginQuery.id#"></cfcookie>
                <cfcookie name="username" value="#loginQuery.username#"></cfcookie>
                <cfcookie name="admin" value="#loginQuery.admin#"></cfcookie>

                <!--- Assign roles for CF login system --->
                <cfset roles = "admin">
                <cfif loginQuery.admin EQ 1>
                    <cfset roles = "admin">
                <cfelseif loginQuery.admin EQ 2>
                    <cfset roles = "user">
                <cfelseif loginQuery.admin EQ 3>
                    <cfset roles = "Read Only">
                </cfif>
                
                <cflogin>
                    <cfloginuser 
                        name="#loginQuery.username#" 
                        password="#loginQuery.hash#" 
                        roles="#roles#">
                </cflogin>

                <!--- Redirect to dashboard --->
                <cflocation url="../../index.cfm" addtoken="false">

            <cfelse>
                <cfoutput>User not found.</cfoutput>
                <cfabort>
            </cfif>
            <!--- Redirect to your app home/dashboard --->
            <!--- <cflocation url="/index.cfm" addtoken="false"> --->

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
