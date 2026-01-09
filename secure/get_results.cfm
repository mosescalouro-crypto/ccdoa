<cfparam name="form.1S" default="">
<cfparam name="form.1M" default="">
<cfparam name="form.3" default="">
<cfparam name="form.2" default="">
<cfif isDefined("event")>
	<cfif findNoCase("e-", event)>
		<cfset eventID = listToArray(event, "-")>
		<cfquery datasource="CCDOA" name="selectedEvent">
			select startDate,endDate,locationid from events
			where id = #eventID[2]#
		</cfquery>
	</cfif>
</cfif>

<cfquery datasource="CCDOA" name="results">
WITH res AS (
    SELECT max_res_id,exceeds_limit,
        CASE 
            WHEN e.locationid IS NOT NULL --- and confirmation=0 
			THEN 1  ELSE 0 
        END AS event,
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
        LEFT JOIN aircraft a 
            ON R.ACType = a.id OR R.actype = a.legacyid
        WHERE 0=0 
		---  and R.deleted = 0
    ) A
    LEFT JOIN eventcheck e
        ON e.locationid = A.locationid
        AND e.parking = A.parking
        AND 
        <!---(
            (e.startdate <= A.arrival AND e.enddate >= A.arrival) OR
            (e.startdate <= A.departure AND e.enddate >= A.departure)
        )
         That reservations are comming in side the event time Date 06D/08M/2025Y  
        OR
        --->
        <!---
		(
		 (A.arrival <= e.startdate AND A.departure >= e.enddate) OR
		 (A.arrival >= e.startdate AND A.departure <= e.enddate)
		)
        --->

		(
		    (A.arrival >= e.startDate AND A.arrival <= e.endDate)
		    OR
		    (A.arrival <= e.startDate AND A.departure >= e.startDate)
		)
		
)


select * from (
	
	
	
	SELECT event,max_res_id,exceeds_limit,
		r.id res_id, 
		conf_no,
		locationid,
		reg, 
		callsign,
		name,
		arrival,
		coalesce(departure,getdate()) departure,
		estTotal,
		status,
		deleted,
		confirmation,
		a.make ac_make,
		a.model ac_model,
		--- a.sqft ac_sqft,
		
		case when a.sqft <= 1250 then '1S' 
		when a.sqft >= 1250 and a.sqft < 2000 then '1M'
		when a.sqft >= 2000 and a.sqft < 3500 then '2'
		when a.sqft >= 3500 then '3' end as parking,			
		
		CASE WHEN EXISTS (
				SELECT *
				FROM reservations AS lookup
				WHERE reg = r.reg
				AND arrival >= dateadd(hh, -2, r.arrival)
				AND arrival < r.arrival
				 AND (deleted = 0 or deleted is null)
			) THEN 1
			WHEN EXISTS (
				SELECT *
				FROM reservations AS lookup
				WHERE reg = r.reg
				AND arrival > r.arrival
				AND arrival <= dateadd(hh, 2, r.arrival) 
				 AND (deleted = 0 or deleted is null)
			) THEN 1
			WHEN EXISTS (
				SELECT *
				FROM reservations AS lookup
				WHERE reg = r.reg
				AND arrival = r.arrival
				AND id <> r.id
				AND (deleted = 0 or deleted is null)
			) THEN 1
			ELSE 0
		END as dupe,
	
		feePayment
	FROM res 	r 
	
	LEFT JOIN aircraft a on r.ACType = a.id or r.actype=a.legacyid
	WHERE 0=0
	<cfif isDefined('form.criteria') and len(form.criteria)>
		AND (name like '%#form.criteria#%'
			OR email like '%#form.criteria#%'
			OR phone like '%#form.criteria#%'
			OR reg like '%#form.criteria#%'
			OR conf_no like '%#form.criteria#%')
	</cfif>
	<cfif isDefined("fuel")>
		AND fuel_gal IS NOT NULL
	</cfif>
	<cfif isDefined("gpu")>
		AND gpu_hours IS NOT NULL
	</cfif>
	<cfif isDefined("jumpstart")>
		AND jumpstart = 1
	</cfif>
	<cfif isDefined("lavatory")>
		AND lavatory = 1
	</cfif>
	<cfif isDefined("water")>
		AND water = 1
	</cfif>
	<cfif isDefined("oxygen")>
		AND oxygen = 1
	</cfif>
	<cfif isDefined("quickturn")>
		<cfif quickturn eq 'yes'>
			AND quickTurn = 1
		<cfelseif quickturn eq 'no'>
			AND quickTurn = 0
		</cfif>
	</cfif>
	<cfif isDefined("resconf")>
		<cfif resconf eq 'reserved'>
			AND confirmation = 1
		<cfelseif resconf eq 'wait'>
			AND confirmation = 0
		</cfif>
	</cfif>
	<cfif isDefined("status")>
		<cfif status>
			AND (deleted = 0 or deleted is null)
		<cfelseif !status>
			AND deleted = 1
		</cfif>
	</cfif>
	<cfif !isDefined("1S")>
		AND a.sqft >= 1250
	</cfif>
	<cfif !isDefined("1M")>
		AND a.sqft NOT BETWEEN 1250 AND 1999
	</cfif>
	<cfif !isDefined("2")>
		AND a.sqft NOT BETWEEN 2000 AND 3499
	</cfif>
	<cfif !isDefined("3")>
		AND a.sqft < 3500
	</cfif>
	<cfif isDefined("airport")>
		<cfif len(airport)>	
			AND locationid = '#airport#'
	</cfif>
	</cfif>
	<cfif isDefined("eventFee")>
		<cfif len(eventFee)>
			AND feePayment = #eventFee#
		</cfif>
	</cfif>
	<cfif isDefined("selectedEvent")>
		AND ('#selectedEvent.startDate#' <= r.departure AND '#selectedEvent.endDate#' >= r.arrival)
		AND locationid = '#selectedEvent.locationid#'
	</cfif>
	<cfif  findNoCase("d-", event)>
		<cfset days = listToArray(event, "-")>
	    <cfif days[2] EQ "7">
	        AND (arrival >= CAST(GETDATE() AS DATE) AND arrival < DATEADD(DAY, 7, CAST(GETDATE() AS DATE)))
	    
	    <cfelseif days[2] EQ "30">
	        AND (arrival >= CAST(GETDATE() AS DATE) AND arrival < DATEADD(DAY, 30, CAST(GETDATE() AS DATE)))
	    
	    <cfelseif days[2] EQ "0">
	        AND (CAST(arrival AS DATE) = CAST(GETDATE() AS DATE))
	    
	    <cfelseif days[2] EQ "1">
	        AND (CAST(arrival AS DATE) = DATEADD(DAY, 1, CAST(GETDATE() AS DATE)))
	    </cfif>
	</cfif>
	<cfif len(notes)>
		AND EXISTS (
			SELECT id from notes AS lookup
			WHERE note like '%#notes#%'
			AND res_id = r.id
			)
	</cfif>
	<cfif IsDate(rangeStart) && IsDate(rangeEnd)>
		AND arrival BETWEEN '#rangeStart#' AND '#rangeEnd#'
	</cfif>
	) AA
	order by arrival desc
</cfquery>

<cfquery datasource="CCDOA" name="parking_groups">
    SELECT DISTINCT pGroup FROM parking_groups
</cfquery>
<cfset pGroupList = "'" & Replace(ValueList(parking_groups.pGroup), ",", "','", "all") & "'">
<cfoutput>
<cfquery name="aircraftGroups" dbtype="query">
    SELECT parking as pGroup, COUNT(*) AS capacity
    FROM results
    WHERE 1=1
    <cfif form.airport EQ "">
        AND locationid IN ('HND', 'VGT','LAS')
    <cfelse>
        AND locationid = <cfqueryparam value="#form.airport#" cfsqltype="cf_sql_varchar">
    </cfif>
	AND parking IN  ('1S','1M','2','3')
    GROUP BY parking

</cfquery>

<cfquery name="rawResults" dbtype="query">
    SELECT parking AS pGroup, COUNT(*) AS capacity
    FROM results
    WHERE 1=1
    <cfif form.airport EQ "">
        AND locationid IN ('HND', 'VGT', 'LAS')
    <cfelse>
        AND locationid = <cfqueryparam value="#form.airport#" cfsqltype="cf_sql_varchar">
    </cfif>
    AND parking IN ('1S', '1M', '2', '3')
    GROUP BY parking
</cfquery>

<!--- Step 2: Ensure all groups exist (fill missing ones with capacity=0) --->
<cfloop list="1S,1M,2,3" index="p">
    <cfif NOT ListFind(ValueList(rawResults.pGroup), p)>
        <cfset QueryAddRow(rawResults, 1)>
        <cfset QuerySetCell(rawResults, "pGroup", p)>
        <cfset QuerySetCell(rawResults, "capacity", 0)>
    </cfif>
</cfloop>

<!--- Step 3: Add a sortOrder column --->
<cfset QueryAddColumn(rawResults, "sortOrder", "Integer", [])>

<!--- Step 4: Assign sort order values based on pGroup --->
<cfloop query="rawResults">
    <cfif rawResults.pGroup EQ "1S">
        <cfset sortValue = 1>
    <cfelseif rawResults.pGroup EQ "1M">
        <cfset sortValue = 2>
    <cfelseif rawResults.pGroup EQ "2">
        <cfset sortValue = 3>
    <cfelseif rawResults.pGroup EQ "3">
        <cfset sortValue = 4>
    <cfelse>
        <cfset sortValue = 5>
    </cfif>
    <cfset QuerySetCell(rawResults, "sortOrder", sortValue, rawResults.currentRow)>
</cfloop>

<!--- Step 5: Reorder using QoQ --->
<cfquery name="aircraftGroups" dbtype="query">
    SELECT pGroup, capacity
    FROM rawResults
    ORDER BY sortOrder
</cfquery>


</cfoutput>

<cfset total = 0 >
<cfif NOT structKeyExists(form,"selectedGroups")>
	<cfset form.selectedGroups = "">
</cfif>

<div class="container">
	<div class="row center-block">
		<div class="col-lg-12 text-center">
		<div class="form-group">
			<label style="margin-right: 10px;"><b>Aircraft Groups: </b> </label>
			<cfoutput query="aircraftGroups">
				<label class="checkbox-inline">
				<input type="checkbox" class="pGroupCountCheckbox" name="#pGroup#" value="#pGroup#"   <cfif listLen(form.selectedGroups) EQ 0 OR listFind(form.selectedGroups, trim(pGroup))>checked</cfif>> Group#pGroup#: <b>#capacity# </b>
				</label>
				<cfset total += capacity >
			</cfoutput>
			<span style="margin-left: 10px;"> Total: <b><cfoutput>#total#</cfoutput></b> </span>
		</div>
		
		</div>
		<!--- <div class="col-lg-6">
		<div class="form-group form-group-sm">
			<label>Timeframe:</label>
			<br>
			<select class="form-control" name="event" id="eventSelect">
			<option></option>
			<option value="r">Range</option>
			<option value="d-7">Next 7 Days</option>
			<option value="d-30">Next 30 Days</option>
			<option value="d-0">Today</option>
			<option value="d-1">Tomorrow</option>
			<cfoutput query="events">
				<option value="e-#id#">#name# (#locationid#)</option>
			</cfoutput>
			</select>
		</div>
		</div> --->
	</div>
</div>

<!--- <cfspreadsheet
	action="write"
	filename="#ExpandPath('export/')#CCDOA_reservations_#cookie.user_id#.xls"
	query="results"
	overwrite="true"> --->
	
<!---
<cfquery dbtype="query" name="excel_q">
	SELECT 
		res_id
		,Conf_no
		,Reg
		,Callsign
		,Name
		,Arrival
		,Departure
		,locationid
		,status
		,ac_make
		,ac_model
		,ac_sqft
	FROM results
</cfquery>

<cfset s = spreadsheetNew()>
<cfset filename = '#ExpandPath('export/')#CCDOA_export_#cookie.user_id#.xls'>

<cfset spreadsheetAddRow(s, "UTC,Local Time,ICAO Hex,Operation,Op ID,Runway,Registration,Callsign,AC Type,Engine Type,Manufacturer,Model,MGLW,Certification,B/I,Owner Name,Address,Address 2,City,State,Zip Code,Time on Ground,Runway Entry,Runway Exit,Gate Arrival Time,Gate Departure Timem,AAC,ADG,ORIGIN_DESTINATION,TouchNGo")>

<cfset spreadsheetFormatRow(s, { bold=true }, 1)>
<cfset spreadsheetAddRows(s, results)>

<cfset spreadsheetWrite(s, filename, true)>
--->
<!--- <cfif StructKeyExists(cookie, "admin") AND cookie.admin NEQ 0>
    <a href="export/<cfoutput>CCDOA_reservations_#cookie.user_id#.xls</cfoutput>" target="_blank" class="btn btn-sm btn-success pull-right" title="Export Data to Excel"><i class="fa fa-file-excel-o" aria-hidden="true"></i> Excel Export</a>
</cfif> --->

<table class="table table-striped table-hover table-condensed dataTable">
  <thead>
      <tr>
      	<th>ID</th>
        <th>Conf #</th>
        <th>Tail No</th>
        <th>Callsign</th>
        <th>Name</th>
        <th></th>
        <th>Arrival Date</th>
        <th>Departure Date</th>
        <th>Airport</th>
        <th>Status</th>
        <th></th>
        <th>Stay Duration</th>
        <th>Aircraft Type</th>
        <th>Parking</th>
        <th>Cost Est.</th>
        <th width="140px"></th>
      </tr>
  </thead>
  <tbody>
  <cfoutput query="results">
  	<!--- Stay duration --->
  	<cfset hours = DateDiff('h',arrival,departure)>
	<cfset stayDays = hours \ 24>
	<cfset stayHours = hours Mod 24>

  	<tr<cfif confirmation neq 1>
  		 class="info"
  		<cfelseif dupe>
  		 class="danger"
  		<cfelseif feePayment eq 1>
  		 class="success"
  		</cfif>>
  		<td>#res_id#</td>
  		<td>#conf_no#</td>
  		<td>#reg#</td>
  		<td>#callsign#</td>
  		<td>#name#</td>
  		<td>
  			<cfif event>
  				<i class="fa-solid fa-star" style="color: ##265B89"></i>
  			</cfif>
  		</td>
  		<td>#datetimeformat(arrival)#</td>
  		<td>#datetimeformat(departure)#</td>
  		<td>#locationid#</td>
  		<td>
  			<cfif results.deleted EQ 1>
  				Cancelled
  			<cfelse>
  				<cfif status eq 1>
	  				Pending
	  			<cfelseif status eq 2>
	  				Arrived
	  			<cfelseif status eq 3>
	  				Departed
	  			</cfif>
  			</cfif>
  		</td>
  		<td>
  			<cfif hours lte 2>
  				<i class="fa-solid fa-bolt" style="color: ##FAB005"></i>
  			</cfif>
  		</td>
  		<td>
  			<cfif stayDays gt 0>
				#stayDays# day<cfif stayDays gt 1>s</cfif><cfif stayDays gt 0 AND stayHours gt 0>, </cfif>
			</cfif>
			<cfif stayHours gt 0>
				#stayHours# hr<cfif stayHours gt 1>s</cfif>
			</cfif>
			<cfif stayDays eq 0 and stayHours eq 0>
				< 1 hr
			</cfif>
  		</td>
  		<td>#ac_make#, #ac_model#</td>
  		<td>#parking#</td>
  		<td>#DollarFormat(estTotal)#</td>
  		<td>
  			<button class="btn btn-xs btn-primary" data-toggle="modal" data-target="##detailsModal" data-id="#res_id#"><i class="fa fa-search" aria-hidden="true"></i> Details</button><cfif status eq 1></cfif> 
  			<cfif StructKeyExists(cookie, "admin") AND cookie.admin NEQ 3>
	  			<button class="btn btn-xs btn-danger" data-toggle="modal" data-target="##detailsModal" data-id="#res_id#" data-edit="1"><i class="fa fa-pencil" aria-hidden="true"></i> Edit</button>
	  		</cfif>
  		</td>
  	</tr>
  </cfoutput>
  </tbody>
</table>

<script>
	$(document).ready(function() {
		$('.pGroupCountCheckbox').on('change', function () {
			var selectedValues = $('.pGroupCountCheckbox:checked').map(function () {
					return $(this).val();
				}).get();

				$('#searchForm input[name="selectedGroups"]').remove();

				$('<input>', {
					type: 'hidden',
					name: 'selectedGroups',
					value: selectedValues.join(',')
				}).appendTo('#searchForm');

				var filterValue = '^(' + selectedValues.join('|') + ')$';
				table.column(13).search(filterValue, true, false).draw();
		});
	});

</script>




