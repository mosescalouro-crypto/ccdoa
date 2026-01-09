<cfcomponent displayname="SAMLUtils" output="false">
	<cffunction name="getEventFee" access="remote" returntype="struct" returnformat="json">
        <cfargument name="actype" type="string" required="true">
        <cfargument name="arrival" type="string" required="true">
        <cfargument name="departure" type="string" required="true">
        <cfargument name="location" type="string" required="true">

        <cfset var result = { success = false, eventName = '', eventFee = '', groupName = '' }>
        <cfquery datasource="CCDOA" name="isEvent">
			SELECT *,
			CASE
				WHEN feeStartDate <= '#departure#' AND feeEndDate >= '#arrival#'
				THEN 1
				ELSE 0
			END as chargeFee
			FROM [events]
			WHERE (startDate <= '#departure#' AND endDate >= '#arrival#')
			AND deleted = 0
			AND locationid = '#location#'
		</cfquery>

		<cfif isEvent.recordcount>
			<cfset eventTotalfee = 0>
			<cfset eventNames = ''>
			<cfloop query="isEvent">
				<!--- Get parking group --->
				<cfquery name="getGroup" datasource="CCDOA">
				    SELECT 
						CASE 
						  WHEN sqft <= 1250 THEN '1S'
						  WHEN sqft > 1250 AND sqft < 2000 THEN '1M'
						  WHEN sqft >= 2000 AND sqft < 3500 THEN '2'
						  ELSE '3'
					END AS parkingGroup
				    FROM aircraft
				    WHERE id = '#actype#'
				</cfquery>
				<cfset parkingGroup = getGroup.parkingGroup>
				<cfset limitColumn = "FEE_" & parkingGroup>
				<cfif StructKeyExists(isEvent, "FEE_" & parkingGroup) AND isEvent.chargeFee EQ 1>
					<cfset eventfee = isEvent["FEE_" & parkingGroup]>
				<cfelse>
					<cfset eventfee = 0> <!--- Default value if the column is missing --->
				</cfif>

				<cfset eventTotalfee += "#eventfee#">
				<cfset result.eventName = valueList(isEvent.NAME)>
			</cfloop>
			<cfset result.eventFee = "#eventTotalfee#">
			<cfset result.success = true>
			<cfset result.groupName = "#parkingGroup#">
		</cfif>
        <cfreturn result>
    </cffunction>

    <cffunction name="submitrecaptcha" access="remote" returnType="struct" returnformat="json">
        <cfset var result = { "success" = false, "message" = "" }>

        <cftry>
            <!--- Verify reCAPTCHA --->
            <!--- <cfset secretKey = "6Lc16r0rAAAAAI8G6f-YwbDZHGhMzza4Qw-G5omQ"> --->
            <cfset secretKey = "6LdXicIrAAAAAMSioaGNWvJhSVWje2EGPjiLwvN4">
            <cfset responseToken = trim(form["g-recaptcha-response"])>

            <cfif len(responseToken)>
                <cfhttp url="https://www.google.com/recaptcha/api/siteverify" method="post">
                    <cfhttpparam type="formField" name="secret" value="#secretKey#">
                    <cfhttpparam type="formField" name="response" value="#responseToken#">
                    <cfhttpparam type="formField" name="remoteip" value="#cgi.remote_addr#">
                </cfhttp>

                <cfset captchaResult = deserializeJSON(cfhttp.fileContent)>

                <cfif captchaResult.success>
                    <!--- ✅ reCAPTCHA OK → Insert into DB here --->
                    <!--- your insert query --->
                    <cfset result.success = true>
                    <cfset result.message = "reCAPTCHA verification successfully.">
                <cfelse>
                    <cfset result.message = "reCAPTCHA verification failed.">
                </cfif>
            <cfelse>
                <cfset result.message = "Missing reCAPTCHA response.">
            </cfif>

            <cfcatch>
                <cfset result.message = "Server error: #cfcatch.message#">
            </cfcatch>
        </cftry>

        <cfreturn result>
    </cffunction>

</cfcomponent>