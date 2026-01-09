
<cfset iata = "HND">
<cfif structKeyExists(form, "ap") AND (form.ap eq "LAS" OR form.ap eq "VGT")>
    <cfset iata = form.ap>
</cfif>
<cfset event = "h-6">
<cfif structKeyExists(form, "event")>
    <cfset event = form.event>
</cfif>

<cfset selectedEvent = {}>

<cfif findNoCase("e-", event)>
    <cfset eventID = listToArray(event, "-")>
    <cfquery datasource="CCDOA" name="selectedEvent">
        SELECT startDate, endDate, locationid
        FROM events
        WHERE id = #eventID[2]#
    </cfquery>
</cfif>

<cfquery datasource="CCDOA" name="inbound">
    declare @currentLocal datetime = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time';

    SELECT 
        r.id AS res_id, 
        conf_no,
        locationid,
        reg, 
        name,
        arrival,
        departure,
        estTotal,
        status,
        a.make AS ac_make,
        a.model AS ac_model,
        a.sqft AS ac_sqft
    FROM reservations r
    JOIN aircraft a ON r.ACType = a.id
    WHERE r.status = 1
      AND r.deleted = 0
      AND r.locationid = '#iata#'

    <cfif structKeyExists(selectedEvent, "startDate") AND selectedEvent.recordCount>
        AND ('#selectedEvent.startDate#' <= r.departure AND '#selectedEvent.endDate#' >= r.arrival)
    </cfif>

    <cfif findNoCase("d-", event)>
        <cfset days = listToArray(event, "-")>
        AND datediff(dd, @currentLocal, arrival) = #days[2]#
    </cfif>

    <cfif findNoCase("h-", event)>
        <cfset hours = listToArray(event, "-")>
        AND arrival BETWEEN dateadd(hour, -6, @currentLocal) AND dateadd(hour, #hours[2]#, @currentLocal)
    </cfif>

    ORDER BY r.id DESC
</cfquery>

<cfset exportData = QueryNew(
    "ID,ConfNo,TailNo,Name,Arrival,Departure,Airport,Status,StayDuration,AircraftType,Parking,CostEst",
    "Integer,Varchar,Varchar,Varchar,Date,Date,Varchar,Varchar,Varchar,Varchar,Varchar,Double"
)>

<cfloop query="inbound">
    <cfset hoursDiff = DateDiff("h", arrival, departure)>
    <cfset stayDays = hoursDiff \ 24>
    <cfset stayHours = hoursDiff mod 24>

    <cfset statusText = "Pending">
    <cfif status eq 2> <cfset statusText = "Arrived"> </cfif>
    <cfif status eq 3> <cfset statusText = "Departed"> </cfif>
    <cfif status eq 0> <cfset statusText = "Cancelled"> </cfif>

    <cfset parking = "">
    <cfif ac_sqft lt 1250>
        <cfset parking = "1S">
    <cfelseif ac_sqft gte 1250 AND ac_sqft lt 2000>
        <cfset parking = "1M">
    <cfelseif ac_sqft gte 2000 AND ac_sqft lt 3500>
        <cfset parking = "2">
    <cfelseif ac_sqft gte 3500>
        <cfset parking = "3">
    </cfif>

    <cfset aircraftType = ac_make & ", " & ac_model>
    <cfset stayDuration = "">
    <cfif stayDays gt 0>
        <cfset stayDuration = stayDays & " day" & (stayDays gt 1 ? "s" : "") & (stayHours gt 0 ? ", " : "")>
    </cfif>
    <cfif stayHours gt 0>
        <cfset stayDuration = stayDuration & stayHours & " hrs">
    </cfif>

    <cfset QueryAddRow(exportData)>
    <cfset QuerySetCell(exportData, "ID", res_id)>
    <cfset QuerySetCell(exportData, "ConfNo", conf_no)>
    <cfset QuerySetCell(exportData, "TailNo", reg)>
    <cfset QuerySetCell(exportData, "Name", name)>
    <cfset QuerySetCell(exportData, "Arrival", arrival)>
    <cfset QuerySetCell(exportData, "Departure", departure)>
    <cfset QuerySetCell(exportData, "Airport", locationid)>
    <cfset QuerySetCell(exportData, "Status", statusText)>
    <cfset QuerySetCell(exportData, "StayDuration", stayDuration)>
    <cfset QuerySetCell(exportData, "AircraftType", aircraftType)>
    <cfset QuerySetCell(exportData, "Parking", parking)>
    <cfset QuerySetCell(exportData, "CostEst", estTotal)>
</cfloop>

<!--- Write Excel --->
<cfset filePath = ExpandPath("export/CCDOA_parking_#cookie.user_id#.xls")>
<cfspreadsheet action="write" filename="#filePath#" query="exportData" sheetname="Parking" overwrite="true">

<!--- Send to browser --->
<cffile action="readbinary" file="#filePath#" variable="fileContent">
<cfheader name="Content-Disposition" value="attachment;filename=CCDOA_parking_#cookie.user_id#.xls">
<cfcontent type="application/vnd.ms-excel" variable="#fileContent#" reset="true">
