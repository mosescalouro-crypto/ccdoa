<CFTRY>
    <cfif isDefined("url.id")>
        <cfquery datasource="CCDOA" name="confirm">
            WITH reserveconf AS (
                SELECT max_res_id,exceeds_limit,
                    CASE 
                        WHEN e.locationid IS NOT NULL AND A.id > ISNULL(max_res_id, 0) and e.exceeds_limit= 'YES' THEN 1 
                        ELSE 0 END AS event,
                    A.*
                FROM (
                    SELECT
                        CASE 
                            WHEN a.sqft <= 1250 THEN '1S'
                            WHEN a.sqft > 1250 AND a.sqft < 2000 THEN '1M'
                            WHEN a.sqft >= 2000 AND a.sqft < 3500 THEN '2'
                            WHEN a.sqft >= 3500 THEN '3'
                        END AS parking,
                        R.*
                    FROM RESERVATIONS R
                    LEFT JOIN aircraft a ON R.ACType = a.id OR R.actype = a.legacyid
                    WHERE R.deleted = 0
                ) A
                LEFT JOIN eventcheck e ON e.locationid = A.locationid
                    AND e.parking = A.parking
                    AND (
                        (e.startdate <= A.arrival AND e.enddate >= A.arrival) OR
                        (e.startdate <= A.departure AND e.enddate >= A.departure)
                    )
            ) select reserveconf.*,a.*,type from reserveconf
            LEFT JOIN aircraft a on reserveconf.ACType = a.id or actype=legacyid
            LEFT JOIN fuel f on reserveconf.fuel_type = f.id
            WHERE reserveconf.id = #url.id#
        </cfquery>

        <cfif confirm.recordcount neq 1>
            <cfthrow>
        </cfif>
        
        <cfif isDefined('url.MarkFee') and url.MarkFee EQ 1>
            <cfset reSend = false>
        <cfelse>
            <cfset reSend = true>
        </cfif>

        <cfoutput query="confirm">
            <cfif locationid eq 'HND'>
                <cfset AirportName = 'Henderson'>
            <cfelse>
                <cfset AirportName = 'North Las Vegas'>
            </cfif>

            <cfquery datasource="CCDOA" name="isEvent">
                SELECT *,
                CASE
                    WHEN feeStartDate <= '#confirm.departure#' AND feeEndDate >= '#confirm.arrival#'
                    THEN 1
                    ELSE 0
                END as chargeFee
                FROM [events]
                WHERE (startDate <= '#confirm.departure#' AND endDate >= '#confirm.arrival#')
                AND deleted = 0
                AND locationid = '#locationid#'
            </cfquery>

            <cfset iata = locationid>
            <cfset actype_name=''>
            <cfset formattedDate = DateFormat(confirm.Arrival, "mm/dd/yyyy")>
            <cfset eventfeeGroup = "fee_" & confirm.parking>
            <cfset chkEvtfeeGroup = 0>

            <cfif confirm.confirmation EQ 1>
                <cfif isEvent.recordcount GT 0>
                    <cfif isDefined('url.MarkFee') and url.MarkFee EQ 1>
                        <cfset chkEvtfeeGroup = confirm.feePayment>
                    <cfelse>
                        <cfif confirm.feePayment EQ 1>
                            <cfset chkEvtfeeGroup = confirm.feePayment>
                        <cfelse>
                            <cfif listFind("fee_1M,fee_1S,fee_2,fee_3", eventfeeGroup)>
                                <cfset chkEvtfeeGroup = isEvent[eventfeeGroup]>
                            <cfelse>
                                <cfset chkEvtfeeGroup = 0>
                            </cfif>
                        </cfif>
                    </cfif>

                    <cfif chkEvtfeeGroup EQ 0 And isEvent.ppr EQ 0>
                        <cfset subject = "Confirmed - #AirportName# #formattedDate# #confirm.reg#">
                    <cfelseif  chkEvtfeeGroup EQ 0 And isEvent.ppr EQ 1>
                        <cfset subject = "Confirmed - #AirportName# #formattedDate# #confirm.reg#">
                    <cfelseif chkEvtfeeGroup GT 0 And isEvent.ppr EQ 1>
                        <cfif isDefined('url.MarkFee') and url.MarkFee EQ 1>
                            <cfset subject = "Confirmed - #AirportName# #formattedDate# #confirm.reg#">
                        <cfelse>
                            <cfif confirm.feePayment EQ 1>
                                <cfset subject = "Confirmed - #AirportName# #formattedDate# #confirm.reg#">
                            <cfelse>
                                <cfset subject = "Pending Event Fee Payment - #AirportName# #formattedDate# #confirm.reg#">
                            </cfif>
                        </cfif>
                    <cfelse>
                        <cfset subject = "#AirportName# Arrival Confirmation">
                    </cfif>
                <cfelse>
                    <cfset subject = "Confirmed - #AirportName# #formattedDate# #confirm.reg#">
                </cfif>
            <cfelse>
                <cfif isEvent.recordcount GT 0>
                    <!--- <cfif isDefined('url.MarkFee') and url.MarkFee EQ 1>
                        <cfset chkEvtfeeGroup = confirm.feePayment>
                    <cfelse>
                    </cfif> --->
                    <cfif listFind("fee_1M,fee_1S,fee_2,fee_3", eventfeeGroup)>
                        <cfset chkEvtfeeGroup = isEvent[eventfeeGroup]>
                    <cfelse>
                        <cfset chkEvtfeeGroup = 0>
                    </cfif>

                    <cfif chkEvtfeeGroup EQ 0 And isEvent.ppr EQ 0>
                        <cfset subject = "WAITLISTED -#AirportName# #formattedDate# #confirm.reg#">
                    <cfelseif  chkEvtfeeGroup EQ 0 And isEvent.ppr EQ 1>
                        <cfset subject = "WAITLISTED - #AirportName# #formattedDate# #confirm.reg#">
                    <cfelseif chkEvtfeeGroup GT 0 And isEvent.ppr EQ 1>
                        <cfset subject = "WAITLISTED - #AirportName# #formattedDate# #confirm.reg#">
                    <cfelse>
                        <cfset subject = "#AirportName# Arrival Waitlisted">
                    </cfif>
                <cfelse>
                    <cfset subject = "WAITLISTED - #AirportName# #formattedDate# #confirm.reg#">
                </cfif>
            </cfif>
            <cfif confirm.confirmation EQ 0 AND isDefined('url.MarkFee') and url.MarkFee EQ 1>

            <cfelse>
                <cfmail from="#iata# Reservations <ccdoa.reservations@mgn.com>"
                    to="#confirm.email#"
                    subject = "#subject#" 
                    type="text/html">
                    <cfinclude template="/secure/email_template.cfm">

                    <CFMAILPARAM name='Errors-To' value="mjc@mgn.com">
                </cfmail>
            </cfif>
        </cfoutput>
    </cfif>
<cfcatch type="any">
    <cfmail 
        to="mjc@mgn.com" 
        from="errors@mgn.com" 
        subject="CF Error - insertNote Failure" 
        type="html">
        <h3>ColdFusion Error Occurred</h3>
        <p><strong>Message:</strong> #cfcatch.message#</p>
        <p><strong>Detail:</strong> #cfcatch.detail#</p>
        <p><strong>Stack Trace:</strong><br><pre>#cfcatch.stacktrace#</pre></p>
        <p><strong>Tag Context:</strong><br><pre>#serializeJSON(cfcatch.tagContext)#</pre></p>
    </cfmail>
</cfcatch>
</CFTRY>