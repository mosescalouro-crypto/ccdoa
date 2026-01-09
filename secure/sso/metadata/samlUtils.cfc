<cfcomponent displayname="SAMLUtils" output="false">
    <!--- <cffunction name="GenerateSAMLRequest" access="public" returntype="string" output="false" hint="Generates a SAML AuthnRequest and returns the redirect URL">
        <cfargument name="idpName" type="string" required="true">
        <cfargument name="spName" type="string" required="true">
        <cfargument name="redirectURL" type="string" required="true">

        <!--- Retrieve SAML settings from Application scope --->
        <cfif not structKeyExists(application, "security") or not structKeyExists(application.security, "samlsettings")>
            <cfthrow message="SAML settings not found in application scope">
        </cfif>
        <cfset var samlSettings = application.security.samlsettings>
        
        <!--- Find IdP configuration --->
        <cfset var idp = {}>
        <cfloop array="#samlSettings.idp#" index="item">
            <cfif item.name eq arguments.idpName>
                <cfset idp = item>
                <cfbreak>
            </cfif>
        </cfloop>
        <cfif structIsEmpty(idp)>
            <cfthrow message="IdP '#arguments.idpName#' not found in SAML settings">
        </cfif>

        <!--- Find SP configuration --->
        <cfset var sp = {}>
        <cfloop array="#samlSettings.sp#" index="item">
            <cfif item.name eq arguments.spName>
                <cfset sp = item>
                <cfbreak>
            </cfif>
        </cfloop>
        <cfif structIsEmpty(sp)>
            <cfthrow message="SP '#arguments.spName#' not found in SAML settings">
        </cfif>

        <!--- Generate a unique request ID --->
        <cfset var requestID = "id_" & replace(createUUID(), "-", "_", "all")>
        <!--- Current timestamp in ISO 8601 format --->
        <cfset var issueInstant = dateFormat(now(), "yyyy-mm-dd") & "T" & timeFormat(now(), "HH:mm:ss") & "Z">

        <!--- Construct SAML AuthnRequest XML --->
        <cfset var samlRequest = '<?xml version="1.0" encoding="UTF-8"?>
<samlp:AuthnRequest
    xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol"
    xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
    ID="#requestID#"
    Version="2.0"
    IssueInstant="#issueInstant#"
    ProtocolBinding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
    AssertionConsumerServiceURL="#xmlFormat(sp.acsURL)#"
    Destination="#xmlFormat(idp.ssoURL)#">
    <saml:Issuer>#xmlFormat(sp.entityId)#</saml:Issuer>
    <samlp:NameIDPolicy Format="urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress" AllowCreate="true"/>
</samlp:AuthnRequest>'>

        <!--- Base64 encode and URL encode the SAML request (skip compression) --->
        <cftry>
            <cfset var encoded = binaryEncode(toBinary(toBase64(samlRequest)), "base64")>
            <cfset var urlEncoded = urlEncodedFormat(encoded)>
            <cfcatch>
                <cfthrow message="Error encoding SAML request: #cfcatch.message#">
            </cfcatch>
        </cftry>

        <!--- Construct the redirect URL --->
        <cfset var redirect = idp.ssoURL & "?SAMLRequest=" & urlEncoded & "&RelayState=" & urlEncodedFormat(arguments.redirectURL)>
        <cfreturn redirect>
    </cffunction> --->

    <cffunction name="GenerateSAMLRequest" access="public" returntype="string" output="false" hint="Generates a SAML AuthnRequest and returns the redirect URL">
        <cfargument name="idpName" type="string" required="true">
        <cfargument name="spName" type="string" required="true">
        <cfargument name="redirectURL" type="string" required="true">

        <!--- Retrieve SAML settings from Application scope --->
        <cfif not structKeyExists(application, "security") or not structKeyExists(application.security, "samlsettings")>
            <cfthrow message="SAML settings not found in application scope">
        </cfif>
        <cfset var samlSettings = application.security.samlsettings>
        
        <!--- Find IdP configuration --->
        <cfset var idp = {}>
        <cfloop array="#samlSettings.idp#" index="item">
            <cfif item.name eq arguments.idpName>
                <cfset idp = item>
                <cfbreak>
            </cfif>
        </cfloop>
        <cfif structIsEmpty(idp)>
            <cfthrow message="IdP '#arguments.idpName#' not found in SAML settings">
        </cfif>

        <!--- Find SP configuration --->
        <cfset var sp = {}>
        <cfloop array="#samlSettings.sp#" index="item">
            <cfif item.name eq arguments.spName>
                <cfset sp = item>
                <cfbreak>
            </cfif>
        </cfloop>
        <cfif structIsEmpty(sp)>
            <cfthrow message="SP '#arguments.spName#' not found in SAML settings">
        </cfif>

        <!--- Generate a unique request ID --->
        <cfset var requestID = "id_" & replace(createUUID(), "-", "_", "all")>
        <!--- Current timestamp in ISO 8601 format --->
        <cfset var issueInstant = dateFormat(now(), "yyyy-mm-dd") & "T" & timeFormat(now(), "HH:mm:ss") & "Z">

        <!--- Construct SAML AuthnRequest XML --->
        <cfset var samlRequest = '<?xml version="1.0" encoding="UTF-8"?>
    <samlp:AuthnRequest
        xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol"
        xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
        ID="#requestID#"
        Version="2.0"
        IssueInstant="#issueInstant#"
        ProtocolBinding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST"
        AssertionConsumerServiceURL="#xmlFormat(sp.acsURL)#"
        Destination="#xmlFormat(idp.ssoURL)#">
        <saml:Issuer>#xmlFormat(sp.entityId)#</saml:Issuer>
        <samlp:NameIDPolicy Format="urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress" AllowCreate="true"/>
    </samlp:AuthnRequest>'>

        <!--- Deflate (compress), Base64 encode, then URL encode --->
        <cftry>
            <cfscript>
                // Convert XML string to bytes
                var bytes = charsetDecode(samlRequest, "UTF-8");

                // ByteArray output stream
                var baos = createObject("java", "java.io.ByteArrayOutputStream").init();

                // Deflater (raw DEFLATE, "true" means no ZLIB header)
                var deflater = createObject("java", "java.util.zip.Deflater").init(
                    createObject("java", "java.util.zip.Deflater").DEFLATED, true
                );

                // DeflaterOutputStream
                var dos = createObject("java", "java.util.zip.DeflaterOutputStream").init(baos, deflater);

                // Write XML bytes
                dos.write(bytes);
                dos.close();

                // Compressed bytes
                var compressed = baos.toByteArray();

                // Base64 encode
                var encoded = toBase64(compressed);

                // URL encode
                var urlEncoded = urlEncodedFormat(encoded);
            </cfscript>
            <cfcatch>
                <cfthrow message="Error encoding SAML request: #cfcatch.message#">
            </cfcatch>
        </cftry>

        <!--- Construct the redirect URL --->
        <cfset var redirect = idp.ssoURL & "?SAMLRequest=" & urlEncoded & "&RelayState=" & urlEncodedFormat(arguments.redirectURL)>
<!--- 
        <cfquery datasource="CCDOA">
            INSERT INTO SAML_Responses (FullURL,generate,SAMLResponse)
            VALUES (
                '#redirect#',
                '1',
                '#samlRequest#'
            )
        </cfquery> --->

        <cfreturn redirect>
    </cffunction>
    
    <cffunction name="ProcessSAMLResponse" access="public" returntype="struct" output="false" hint="Processes a SAML response from the IdP (Azure AD)">
        <cfargument name="idpName" type="string" required="true">
        <cfargument name="spName" type="string" required="true">

        <cfset var result = { success = false, attributes = {}, error = {} }>

        <cftry>
            <!--- Ensure SAML settings exist --->
            <cfif not structKeyExists(application, "security") or not structKeyExists(application.security, "samlsettings")>
                <cfset result.error = { code = "NO_SETTINGS", message = "SAML settings not found in application scope" }>
                <cfreturn result>
            </cfif>

            <cfset var samlSettings = application.security.samlsettings>
            <cfset var idp = {} />

            <!--- Find IdP config --->
            <cfloop array="#samlSettings.idp#" index="item">
                <cfif item.name eq arguments.idpName>
                    <cfset idp = item>
                    <cfbreak>
                </cfif>
            </cfloop>

            <cfif structIsEmpty(idp)>
                <cfset result.error = { code = "IDP_NOT_FOUND", message = "IdP '#arguments.idpName#' not found in SAML settings" }>
                <cfreturn result>
            </cfif>

            <!--- Verify form contains SAMLResponse --->
            <cfif not structKeyExists(form, "SAMLResponse")>
                <cfset result.error = { code = "NO_SAML_RESPONSE", message = "SAMLResponse not found in POST data" }>
                <cfreturn result>
            </cfif>

            <!--- Decode Base64 XML --->
            <cftry>
                <cfset var decoded = binaryDecode(form.SAMLResponse, "base64")>
                <cfset var xmlDoc = xmlParse(toString(decoded))>

                <!--- Optional: log only in dev --->
                <!--- <cflog file="SSO" type="information" text="Raw SAML Response XML: #toString(xmlDoc)#"> --->

                <cfcatch>
                    <cfset result.error = { code = "DECODE_ERROR", message = "Error decoding SAML response: #cfcatch.message#" }>
                    <cfreturn result>
                </cfcatch>
            </cftry>

            <!--- Validate Issuer --->
            <cfset var issuerNodes = xmlSearch(xmlDoc, "//*[local-name()='Issuer']")>
            <cfif arrayLen(issuerNodes) eq 0>
                <cfset result.error = { code = "NO_ISSUER", message = "Issuer not found in SAML response" }>
                <cfreturn result>
            </cfif>

            <cfset var issuer = issuerNodes[1].xmlText>

            <!--- Normalize trailing slash before compare --->
            <cfif right(issuer,1) neq "/">
                <cfset issuer &= "/" >
            </cfif>
            <cfif right(idp.entityID,1) neq "/">
                <cfset idp.entityID &= "/" >
            </cfif>

            <cfif issuer neq idp.entityID>
                <cfset result.error = { code = "INVALID_ISSUER", message = "Invalid issuer: #issuer#" }>
                <cfreturn result>
            </cfif>

            <!--- Extract attributes --->
            <cfset var attributes = {} />
            <cfset var attributeNodes = xmlSearch(xmlDoc, "//*[local-name()='AttributeStatement']/*[local-name()='Attribute']")>

            <cfloop array="#attributeNodes#" index="attr">
                <cfset var attrName = attr.xmlAttributes.Name>
                <cfset var values = []>
                <cfloop array="#attr.xmlChildren#" index="val">
                    <cfif structKeyExists(val, "xmlText")>
                        <cfset arrayAppend(values, val.xmlText)>
                    </cfif>
                </cfloop>
                <!--- If only one value, store as string, else array --->
                <cfif arrayLen(values) eq 1>
                    <cfset attributes[attrName] = values[1]>
                <cfelse>
                    <cfset attributes[attrName] = values>
                </cfif>
            </cfloop>

            <!--- Extract NameID --->
            <cfset var nameIDNodes = xmlSearch(xmlDoc, "//*[local-name()='NameID']")>
            <cfif arrayLen(nameIDNodes) eq 0>
                <cfset result.error = { code = "NO_NAMEID", message = "NameID not found in SAML response" }>
                <cfreturn result>
            </cfif>
            <cfset attributes["NameID"] = nameIDNodes[1].xmlText>

            <!--- Final Result --->
            <cfset result.success = true>
            <cfset result.attributes = attributes>
            <cfreturn result>

            <cfcatch>
                <cfset result.error = {
                    code = "EXCEPTION",
                    message = cfcatch.message,
                    detail = cfcatch.detail
                }>
                <cfreturn result>
            </cfcatch>
        </cftry>
    </cffunction>



    <!--- <cffunction name="ProcessSAMLResponse" access="public" returntype="struct" output="false" hint="Processes a SAML response from the IdP">
        <cfargument name="idpName" type="string" required="true">
        <cfargument name="spName" type="string" required="true">

        <cfset var result = { success = false, attributes = {}, error = {} }>

        <cftry>
            <!--- Retrieve SAML settings --->
            <cfif not structKeyExists(application, "security") or not structKeyExists(application.security, "samlsettings")>
                <cfthrow message="SAML settings not found in application scope">
            </cfif>
            <cfset var samlSettings = application.security.samlsettings>
            <cfset var idp = {}>
            <cfloop array="#samlSettings.idp#" index="item">
                <cfif item.name eq arguments.idpName>
                    <cfset idp = item>
                    <cfbreak>
                </cfif>
            </cfloop>
            <cfif structIsEmpty(idp)>
                <!--- <cfthrow message="IdP '#arguments.idpName#' not found in SAML settings"> --->
                <cfset result.error = { code = "IDP_NOT_FOUND", message = "IdP '#arguments.idpName#' not found in SAML settings" }>
                <cfreturn result>
            </cfif>
            
            <!--- Get and decode SAMLResponse from POST data --->
            <cfif not structKeyExists(form, "SAMLResponse")>
                <!--- <cfthrow message="SAMLResponse not found in POST data"> --->
                <cfset result.error = { code = "NO_SAML_RESPONSE", message = "SAMLResponse not found in POST data" }>
                <cfreturn result>
            </cfif>
            <cftry>
                <cfset var samlResponse = form.SAMLResponse>
                <cfset var decoded = binaryDecode(samlResponse, "base64")>
                <!--- Parse XML directly (response is uncompressed) --->
                <cfset var xmlDoc = xmlParse(toString(decoded))>
                <!--- Log raw XML for debugging --->
                <cflog file="SSOTestProject" type="information" text="Raw SAML Response XML: #toString(xmlDoc)#">
                <cfcatch>
                    <cfset result.error = { code = "NO_ISSUER", message = "Error decoding SAML response: #cfcatch.message#" }>
                    <cfreturn result>
                </cfcatch>
            </cftry>

            <!--- Validate issuer using namespace-agnostic XPath --->
            <cfset var issuerNodes = xmlSearch(xmlDoc, "//*[local-name()='Issuer']")>
            <cfif arrayLen(issuerNodes) eq 0>
                <!--- <cfthrow message="Issuer not found in SAML response"> --->
                <cfset result.error = { code = "NO_ISSUER", message = "Issuer not found in SAML response" }>
                <cfreturn result>
            </cfif>
            <cfset var issuer = issuerNodes[1].xmlText>
            <cfif issuer neq idp.entityID>
                <!--- <cfthrow message="Invalid issuer in SAML response: #issuer#"> --->
                <cfset result.error = { code = "INVALID_ISSUER", message = "Invalid issuer: #issuer#" }>
                <cfreturn result>
            </cfif>

            <!--- Extract attributes using namespace-agnostic XPath --->
            <cfset var attributes = {}>
            <cfset var attributeNodes = xmlSearch(xmlDoc, "//*[local-name()='AttributeStatement']/*[local-name()='Attribute']")>
            <cfloop array="#attributeNodes#" index="attr">
                <cfset var attrName = attr.xmlAttributes.Name>
                <cfset var attrValue = attr.xmlChildren[1].xmlText>
                <cfset attributes[attrName] = attrValue>
            </cfloop>

            <!--- Extract NameID using namespace-agnostic XPath --->
            <cfset var nameIDNodes = xmlSearch(xmlDoc, "//*[local-name()='NameID']")>
            <cfif arrayLen(nameIDNodes) eq 0>
                <!--- <cfthrow message="NameID not found in SAML response"> --->
                <cfset result.error = { code = "NO_NAMEID", message = "NameID not found in SAML response" }>
                <cfreturn result>
            </cfif>
            <cfset var nameID = nameIDNodes[1].xmlText>
            <cfset attributes["NameID"] = nameID>

            <!--- Return success result --->
            <cfset result.success = true>
            <cfset result.attributes = attributes>
            <cfreturn result>

            <cfcatch>
                <cfset result.error = {
                    code = "EXCEPTION",
                    message = cfcatch.message,
                    detail = cfcatch.detail
                }>
                <cfreturn result>
            </cfcatch>
        </cftry>
    </cffunction> --->

    <cffunction name="ProcessSAMLLogoutRequest" access="public" returntype="void" output="false" hint="Processes a SAML LogoutRequest from the IdP">
        <cfargument name="idpName" type="string" required="true">
        <cfargument name="spName" type="string" required="true">
        <cfset var result = { success = false, attributes = {}, error = {} }>

        <cftry>
            <!--- Retrieve SAML settings --->
            <cfif not structKeyExists(application, "security") or not structKeyExists(application.security, "samlsettings")>
                <!--- <cfthrow message="SAML settings not found in application scope"> --->
                <cfset result.error = { code = "SAML_settings_Found", message = "SAML settings not found in application scope" }>
                <cfreturn result>
            </cfif>
            <cfset var samlSettings = application.security.samlsettings>
            <cfset var idp = {}>
            <cfloop array="#samlSettings.idp#" index="item">
                <cfif item.name eq arguments.idpName>
                    <cfset idp = item>
                    <cfbreak>
                </cfif>
            </cfloop>
            <cfif structIsEmpty(idp)>
                <cfset result.error = { code = "IDP_NOT_FOUND", message = "IdP '#arguments.idpName#' not found in SAML settings" }>
                <cfreturn result>
            </cfif>

            <!--- Decode and parse SAML LogoutRequest --->
            <cfif not structKeyExists(url, "SAMLRequest")>
                <cfset result.error = { code = "SAML_Request_found", message = "SAMLRequest not found in URL" }>
                <cfreturn result>
            </cfif>
            <cftry>
                <cfset var samlRequest = url.SAMLRequest>
                <cfset var decoded = binaryDecode(samlRequest, "base64")>
                <!--- Assume request may not be compressed --->
                <cfset var xmlDoc = "">
                <cftry>
                    <cfset xmlDoc = xmlParse(toString(decoded))>
                    <cfcatch>
                        <!--- Try decompressing if direct parsing fails --->
                        <cfset var decompressed = decompress("deflate", decoded)>
                        <cfset xmlDoc = xmlParse(decompressed)>
                    </cfcatch>
                </cftry>
                <cfcatch>
                    <cfthrow message="Error decoding SAML LogoutRequest: #cfcatch.message#">
                </cfcatch>
            </cftry>

            <!--- Validate issuer --->
            <cfset var issuer = xmlSearch(xmlDoc, "//saml:Issuer")[1].xmlText>
            <cfif issuer neq idp.entityID>
                <cfset result.error = { code = "Invalid_issuer", message = "Invalid issuer in SAML LogoutRequest: #issuer#" }>
                <cfreturn result>
            </cfif>
            <cfset result.success = true>
            <cfreturn result>
            <cfcatch>
                <cfset result.error = {
                    code = "EXCEPTION",
                    message = cfcatch.message,
                    detail = cfcatch.detail
                }>
                <cfreturn result>
            </cfcatch>
        </cftry>

        <!--- Session is cleared in slo.cfm --->
    </cffunction>

    <cffunction name="GenerateSAMLLogoutRequest" access="public" returntype="string" output="false" hint="Generates a SAML LogoutRequest for SP-initiated logout">
        <cfargument name="idpName" type="string" required="true">
        <cfargument name="spName" type="string" required="true">
        <cfargument name="redirectURL" type="string" required="true">

        <!--- Retrieve SAML settings --->
        <cfif not structKeyExists(application, "security") or not structKeyExists(application.security, "samlsettings")>
            <cfthrow message="SAML settings not found in application scope">
        </cfif>
        <cfset var samlSettings = application.security.samlsettings>
        <cfset var idp = {}>
        <cfloop array="#samlSettings.idp#" index="item">
            <cfif item.name eq arguments.idpName>
                <cfset idp = item>
                <cfbreak>
            </cfif>
        </cfloop>
        <cfif structIsEmpty(idp)>
            <!--- <cfthrow message="IdP '#arguments.idpName#' not found in SAML settings"> --->
            <cfset result.error = { code = "IdP_not_found", message = "IdP '#arguments.idpName#' not found in SAML settings" }>
            <cfreturn result>
        </cfif>
        <cfset var sp = {}>
        <cfloop array="#samlSettings.sp#" index="item">
            <cfif item.name eq arguments.spName>
                <cfset sp = item>
                <cfbreak>
            </cfif>
        </cfloop>
        <cfif structIsEmpty(sp)>
            <!--- <cfthrow message="SP '#arguments.spName#' not found in SAML settings"> --->
            <cfset result.error = { code = "SP_not_found", message = "SP '#arguments.spName#' not found in SAML settings" }>
            <cfreturn result>
        </cfif>

        <!--- Ensure NameID exists from previous authentication --->
        <cfif not structKeyExists(session, "userAttributes") or not structKeyExists(session.userAttributes, "NameID")>
            <!--- <cfthrow message="NameID not found in session for logout"> --->
            <cfset result.error = { code = "NameID_not_found", message = "NameID not found in session for logout" }>
            <cfreturn result>
        </cfif>

        <!--- Generate a unique request ID --->
        <cfset var requestID = "id_" & replace(createUUID(), "-", "_", "all")>
        <cfset var issueInstant = dateFormat(now(), "yyyy-mm-dd") & "T" & timeFormat(now(), "HH:mm:ss") & "Z">

        <!--- Construct SAML LogoutRequest XML --->
        <cfset var samlRequest = '<?xml version="1.0" encoding="UTF-8"?>
<samlp:LogoutRequest
    xmlns:samlp="urn:oasis:names:tc:SAML:2.0:protocol"
    xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
    ID="#requestID#"
    Version="2.0"
    IssueInstant="#issueInstant#"
    Destination="#xmlFormat(idp.sloURL)#">
    <saml:Issuer>#xmlFormat(sp.entityId)#</saml:Issuer>
    <saml:NameID Format="urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress">#xmlFormat(session.userAttributes.NameID)#</saml:NameID>
</samlp:LogoutRequest>'>

        <!--- Base64 encode and URL encode (skip compression) --->
        <cftry>
            <cfset var encoded = binaryEncode(toBinary(toBase64(samlRequest)), "base64")>
            <cfset var urlEncoded = urlEncodedFormat(encoded)>
            <cfcatch>
                <cfthrow message="Error encoding SAML LogoutRequest: #cfcatch.message#">
            </cfcatch>
        </cftry>

        <!--- Construct redirect URL --->
        <cfset var redirect = idp.sloURL & "?SAMLRequest=" & urlEncoded & "&RelayState=" & urlEncodedFormat(arguments.redirectURL)>
        <cfreturn redirect>
    </cffunction>
</cfcomponent>