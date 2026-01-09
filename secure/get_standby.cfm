

<cfif isDefined("url.publicRelease")>

	<cfquery datasource="CCDOA" name="release">
		UPDATE reservations
		SET released = 1
		WHERE id = #url.cid#
	</cfquery>

<cfelseif isDefined("url.replaceConfirm")>

	<cfquery datasource="CCDOA" name="res">
		SELECT * from reservations
		where id = #url.id#
	</cfquery>

	<cfquery datasource="CCDOA" name="isEvent">
		SELECT *
		FROM [events]
		WHERE (startDate <= '#res.departure#' AND endDate >= '#res.arrival#')
		AND deleted = 0
		AND locationid = '#res.locationid#'
	</cfquery>

	<cfquery datasource="CCDOA" name="overlap">
		SELECT count(*) total, max(pGroup) pGroup, ISNULL(max(capacity),1) capacity
		FROM reservations r 
		INNER JOIN aircraft_view a on (r.actype = a.id OR r.actype = a.legacyid) AND r.locationid = a.locationid
		WHERE r.locationid = '#res.locationid#'
		AND r.id <> #url.cid#
		AND r.confirmation = 1
		AND (
			r.deleted = 0 
			OR (r.deleted = 1 AND r.released = 0)
			)
		AND ('#res.arrival#' <= departure) and (arrival <= '#res.departure#')
		AND a.pGroup = (SELECT pGroup from aircraft_view where id = #res.actype# and locationid = '#res.locationid#')
	</cfquery>

	<cfif isEvent.recordcount>
		<cfset event_capacity = isEvent["limit_" & overlap.pGroup]>

		<cfif overlap.total gte event_capacity>
			<cfset confirm = 0>
		<cfelse>
			<cfset confirm = 1>
		</cfif>
	<cfelse>
		<cfif overlap.total gte overlap.capacity>
			<cfset confirm = 0>
		<cfelse>
			<cfset confirm = 1>
		</cfif>
	</cfif>


		<div class="alert alert-success" role="alert">No conflicts detected.</div>
		<!---
			<cfif confirm>
	<cfelse>
		<div class="alert alert-danger" role="alert"><strong>Alert:</strong> conflicts detected.</div
	</cfif>--->

	<h4>Are you sure you want to confirm the selected reservation?</h4><br>

	<form class="form" method="POST" id="replaceConfirm">
		<input type="hidden" name="res_id" value="<cfoutput>#url.id#</cfoutput>">
		<input type="hidden" name="cid" value="<cfoutput>#url.cid#</cfoutput>">
		<div class="form-group form-group-sm">
			<label for="comment" class="control-label">Admin Comment</label>
			<textarea name="comment" class="form-control input-small"></textarea>
		</div>
		<button class="btn btn-success confirmSubmit">Confirm <i class="fa fa-check" aria-hidden="true"></i></button>
		<!---<button class="btn btn-danger confirmCancel">Cancel <i class="fa-solid fa-ban"></i></button>--->
	</form>

<cfelse>

	<cfquery datasource="CCDOA" name="cancelled">
		SELECT TOP 1
			r.id res_id, 
			conf_no,
			r.locationid locationid,
			reg, 
			callsign,
			name,
			arrival,
			departure,
			estTotal,
			status,
			deleted,
			confirmation,
			a.make ac_make,
			a.model ac_model,
			a.sqft ac_sqft,
			a.pGroup pGroup,
			CASE WHEN EXISTS (
					SELECT *
					FROM [events] AS event_check
					WHERE (startDate <= r.departure AND endDate >= r.arrival)
					AND locationid = r.locationid
				) THEN 1
				ELSE 0
			END as event
		FROM reservations r
		LEFT JOIN aircraft_view a on r.actype = a.id 
		WHERE r.id = #url.id#
	</cfquery>

	<cfquery datasource="CCDOA" name="results">
		SELECT 
			r.id res_id, 
			conf_no,
			r.locationid locationid,
			reg, 
			phone,
			name,
			arrival,
			departure,
			estTotal,
			status,
			deleted,
			confirmation,
			a.make ac_make,
			a.model ac_model,
			a.sqft ac_sqft,
			a.pGroup pGroup,
			CASE WHEN EXISTS (
					SELECT *
					FROM reservations AS lookup
					WHERE reg = r.reg
					AND arrival >= dateadd(hh, -2, r.arrival)
					AND arrival < r.arrival
					AND deleted = 0
				) THEN 1
				WHEN EXISTS (
					SELECT *
					FROM reservations AS lookup
					WHERE reg = r.reg
					AND arrival > r.arrival
					AND arrival <= dateadd(hh, 2, r.arrival) 
					AND deleted = 0
				) THEN 1
				WHEN EXISTS (
					SELECT *
					FROM reservations AS lookup
					WHERE reg = r.reg
					AND arrival = r.arrival
					AND id <> r.id
					AND deleted = 0
				) THEN 1
				ELSE 0
			END as dupe
		FROM reservations r
		INNER JOIN aircraft_view a on (r.actype = a.id OR r.actype = a.legacyid)
			AND r.locationid = a.locationid
		WHERE r.locationid = '#cancelled.locationid#'
		AND r.deleted = 0
		AND r.confirmation = 0
		AND ('#cancelled.arrival#' <= departure) and (arrival <= '#cancelled.departure#')
		AND a.pGroup = '#cancelled.pGroup#'
		
		order by r.id asc
	</cfquery>

	<table class="table table-striped table-hover table-condensed dataTable">
	  <thead>
	      <tr>
	        <th>ID #</th>
	        <th>Tail No</th>
	        <th>Name</th>
	        <th>Phone</th>
	        <th>Arrival Date</th>
	        <th>Departure Date</th>
	        <th></th>
	        <th>Stay Duration</th>
	        <th>Aircraft Type</th>
	        <th></th>
	      </tr>
	  </thead>
	  <tbody>
	  <cfoutput query="results">
	  	<!--- Stay duration --->
	  	<cfset hours = DateDiff('h',arrival,departure)>
		<cfset stayDays = hours \ 24>
		<cfset stayHours = hours Mod 24>

		<!--- Parking category --->
		<cfset parking = ''>
		<cfif ac_sqft lt 1250>
			<cfset parking = '1S'>
		<cfelseif ac_sqft gte 1250 AND ac_sqft lt 2000>
			<cfset parking = '1M'>
		<cfelseif ac_sqft gte 2000 AND ac_sqft lt 3500>
			<cfset parking = '2'>
		<cfelseif ac_sqft gte 3500>
			<cfset parking = '3'>
		</cfif>

	  	<tr>
	  		<td>#res_id#</td>
	  		<td>#reg#</td>
	  		<td>#name#</td>
	  		<td>#phone#</td>
	  		<td>#datetimeformat(arrival)#</td>
	  		<td>#datetimeformat(departure)#</td>
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
	  		<td><button class="btn btn-xs btn-success replaceConfirm" data-id="#res_id#" data-cid="#url.id#">Confirm <i class="fa fa-check" aria-hidden="true"></i></button></td>
	  </cfoutput>
	  </tbody>
	</table>
	<button id="publicRelease" class="btn btn-md btn-primary" data-cid="<cfoutput>#url.id#</cfoutput>">Release to Public</button>
</cfif>
