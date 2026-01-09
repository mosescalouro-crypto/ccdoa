<cfif isDefined("form.formName")>
	<cfif form.formName eq 'res_edit'>
		<cfquery datasource="CCDOA" name="archive">
			INSERT INTO reservations_archive (
				[res_id]
				,[reg]
				,[ACType]
				,[name]
				,[arrival]
				,[departure]
				,[status]
				,[confirmation]
				,[estTotal]
				,[fuel_type]
				,[fuel_gal]
				,[fuel_prist]
				,[fuel_contract]
				,[gpu_hours]
				,[jumpstart]
				,[lavatory]
				,[water]
				,[oxygen]
				,[ox_portable]
				,[ox_fixed]
				,[ox_large]
				,[email]
				,[phone]
				,[notes]
				,[conf_no]
				,[quickTurn]
				,[coffee]
				,[ice]
				,[catering]
				,[locationid]
				,[callsign]
				,[edit_userid]
				,[edit_date]
			)
			SELECT [id]
				,[reg]
				,[ACType]
				,[name]
				,[arrival]
				,[departure]
				,[status]
				,[confirmation]
				,[estTotal]
				,[fuel_type]
				,[fuel_gal]
				,[fuel_prist]
				,[fuel_contract]
				,[gpu_hours]
				,[jumpstart]
				,[lavatory]
				,[water]
				,[oxygen]
				,[ox_portable]
				,[ox_fixed]
				,[ox_large]
				,[email]
				,[phone]
				,[notes]
				,[conf_no]
				,[quickTurn]
				,[coffee]
				,[ice]
				,[catering]
				,[locationid]
				,[callsign]
				,[edit_userid]
				,[edit_date]
			FROM reservations
			WHERE id = '#form.RES_ID#'
		</cfquery>
        <cfquery datasource="CCDOA" name="getreservation">
			SELECT r.id,
			    e.id as eventid,
			    r.confirmation,
			    CASE 
					WHEN a.sqft <= 1250 THEN '1S'
					WHEN a.sqft > 1250 AND a.sqft < 2000 THEN '1M'
					WHEN a.sqft >= 2000 AND a.sqft < 3500 THEN '2'
					ELSE '3'
					END AS parkingGroup
			FROM reservations r
			inner join aircraft a on a.id = r.ACType
			INNER JOIN dbo.events AS e ON (
				    (r.arrival >= e.startDate AND r.arrival <= e.endDate)
				    OR
				    (r.arrival <= e.startDate AND r.departure >= e.startDate)
				) AND r.locationid = e.locationid and e.deleted = 0
			WHERE r.id = '#form.RES_ID#'
		</cfquery>

				
		<cfquery datasource="CCDOA" name="isEvent">
			SELECT *
			FROM [events]
			WHERE (startDate <= '#form.departure#' AND endDate >= '#form.arrival#')
			AND deleted = 0
			AND locationid = '#form.locationid#'
		</cfquery>
        
		<cfif isEvent.recordcount>

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
			    WHERE id = <cfqueryparam value="#form.actype#" cfsqltype="cf_sql_integer">
			</cfquery>

			<cfset parkingGroup = getGroup.parkingGroup>
			<cfset limitColumn = "limit_" & parkingGroup>

			<!--- Get group limit from event --->
			<cfquery name="getEventLimit" datasource="CCDOA">
			    SELECT #limitColumn# AS groupLimit, startDate, endDate
			    FROM events
			    WHERE id = <cfqueryparam value="#isEvent.id#" cfsqltype="cf_sql_integer">
			</cfquery>

			<!--- Count current confirmed reservations in this group for the event time range --->
			<cfquery name="getGroupCount" datasource="CCDOA">
				SELECT COUNT(*) AS groupCount
				FROM reservations r
				INNER JOIN aircraft a ON r.actype = a.id OR a.legacyID = r.ACType
				WHERE r.locationid = <cfqueryparam value="#form.locationid#" cfsqltype="cf_sql_varchar">
				AND r.deleted = 0
				AND r.confirmation = 1
				AND ('#getEventLimit.startDate#' <= r.departure) and ('#getEventLimit.endDate#' >= r.arrival)
				AND (
				    CASE 
					WHEN a.sqft <= 1250 THEN '1S'
					WHEN a.sqft > 1250 AND a.sqft < 2000 THEN '1M'
					WHEN a.sqft >= 2000 AND a.sqft < 3500 THEN '2'
					ELSE '3'
				    END
				) = <cfqueryparam value="#parkingGroup#" cfsqltype="cf_sql_varchar">
			</cfquery>
            

			<cfif getreservation.recordcount GT 0 AND (getreservation.eventid EQ isEvent.id AND getreservation.parkingGroup EQ getGroup.parkingGroup)>
			    <cfset confirm = getreservation.confirmation>
			<cfelse> 
				<!--- Determine confirmation status --->
				<cfif getGroupCount.groupCount LT getEventLimit.groupLimit>
				  <cfset confirm = 1>
				<cfelse>
				  <cfset confirm = 0>
				</cfif>
			</cfif>

		<cfelse>
			<cfquery datasource="CCDOA" name="overlap">
				SELECT 
					count(*) total, 
					max(pGroup) pGroup, 
					ISNULL(max(capacity),1) capacity,
					(SELECT pGroup from aircraft_view where id = #form.actype# and locationid = 'HND') as pgroupName
				FROM reservations r
				INNER JOIN aircraft_view a on (r.actype = a.id OR a.legacyID = r.ACType) AND r.locationid = a.locationid
				WHERE r.locationid = '#form.locationid#'
				AND r.deleted = 0
				AND r.confirmation = 1
				AND a.pGroup = (SELECT pGroup from aircraft_view where id = #form.actype# and locationid = '#form.locationid#')
				AND ('#form.arrival#' <= departure) and (arrival <= '#form.departure#')
			</cfquery>

			<cfif overlap.total gte overlap.capacity>
				<cfset confirm = 0>
			<cfelse>
				<cfset confirm = 1>
			</cfif>
		</cfif>

		<!--- <cfquery datasource="CCDOA" name="overlap">
			SELECT count(*) total, max(pGroup) pGroup, ISNULL(max(capacity),1) capacity
			FROM reservations r 
			INNER JOIN aircraft_view a on r.actype = a.id 
				AND r.locationid = a.locationid
			WHERE r.locationid = '#form.locationid#'
			AND r.deleted = 0
			AND r.confirmation = 1
			AND ('#form.arrival#' <= departure) and (arrival <= '#form.departure#')
			AND a.pGroup = (SELECT pGroup from aircraft_view where id = #form.actype# and locationid = '#form.locationid#')
		</cfquery>

		<cfif isEvent.recordcount>
			<cfif StructKeyExists(isEvent, "limit_" & overlap.pGroup)>
				<cfset event_capacity = isEvent["limit_" & overlap.pGroup]>
				
			<cfelse>
				<cfset event_capacity = 0> <!--- Default value if the column is missing --->
			</cfif>

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
		</cfif> --->
        
		<cfquery datasource="CCDOA" name="update">
			UPDATE reservations
			SET email = '#form.email#',
				name = '#form.name#',
				phone = '#form.phone#',
				reg = '#form.reg#',
				actype = '#form.actype#',
				callsign = '#form.callsign#',
				locationid = '#form.locationid#',
				arrival = '#form.arrival#',
				departure = '#form.departure#',
				edit_userid = '#cookie.user_id#',
				confirmation = '#confirm#',
				edit_date = getdate()
			WHERE id = '#form.res_id#'
		</cfquery>


		<cfquery datasource="CCDOA" name="update">
			UPDATE reservations
			SET conf_no = LocationID +'-'+ FORMAT(id+10000, '000000') 
			WHERE locationid IS NOT NULL
			AND id = <cfqueryparam value="#form.res_id#" cfsqltype="cf_sql_integer">;
		</cfquery>


	<cfelseif form.formName eq 'userForm'>

		<cfquery datasource="CCDOA" name="update">
			UPDATE users
			SET email = '#form.email#',
				first_name = '#form.first_name#',
				last_name = '#form.last_name#',
				<cfif isDefined("form.role")>
					admin = #form.role#,
				<cfelse>
					admin = 0,
				</cfif>
				updated = getdate()
			WHERE id = '#form.id#'
		</cfquery>

	<cfelseif form.formName eq 'newUserForm'>
		<cfquery datasource="CCDOA" name="existing">
			SELECT * from users
			where email = '#form.email#'
		</cfquery>

		<cfif existing.recordcount>
			<cfif len(existing.username)>
				<cfthrow>
			<cfelse>
				<cfquery datasource="CCDOA" name="existing">
					DELETE from users
					where email = '#form.email#'
				</cfquery>
			</cfif>
		</cfif>

		<cfquery datasource="CCDOA" name="insert">
			INSERT INTO users (email,first_name,last_name,admin,updated)
			VALUES (
				'#form.email#',
				'#form.first_name#',
				'#form.last_name#',
				<cfif isDefined("form.role") and form.role neq '' >#form.role#<cfelse>0</cfif>,
				getdate()
			)
		</cfquery>

		<cfsavecontent variable="msg">Hello,
		<br><br>
		Please use the link below to set your account username and password.
		<br>
		<a href="http://ccdoa.motioninfo.com/register.cfm?e=<cfoutput>#form.email#</cfoutput>">http://ccdoa.motioninfo.com/register.cfm?e=<cfoutput>#form.email#</cfoutput></a>
		<br>
		(Please copy and paste this into your browser's address bar if the link doesn't work)
		<br><br>
		Have a wonderful day!!
		<br>
		<br><br>
		Thank you,
		<br>
		CCDOA Administration
		</cfsavecontent>

		<cfmail to = "#form.email#"
				from = "CCDOA Reservations <ccdoa@motioninfo.com>"
				subject = "CCDOA Reservations | Create your account" 
				type="text/html">
					
			#msg#
		</cfmail>

	<cfelseif form.formName eq 'parkingForm'>
        <!--- automatically update the reservation from waitlist to confirm on the base of group space --->
        <!--- <cfset locations = ["HND", "VGT"]>
		<cfset groups = ["1S", "1M", "2", "3"]>

		<!--- Loop over locations and groups --->
		<cfloop array="#locations#" index="loc">
		    <cfloop array="#groups#" index="grp">
		        <cfset fieldKey = "#grp#_CAP_#loc#">

		        <cfif structKeyExists(FORM, fieldKey)>
		            <cfset groupLimit = FORM[fieldKey]>

					<!--- Get all future reservations for group 3 --->
					<cfquery name="getRes" datasource="CCDOA">
					    SELECT r.id, r.arrival, r.departure, r.confirmation
						FROM reservations r
						INNER JOIN aircraft_view a ON r.actype = a.id AND r.locationid = a.locationid
						WHERE r.locationid = '#loc#'
						AND r.deleted = 0
						AND a.pGroup = '#grp#'
						AND r.departure >= GETDATE()
						AND NOT EXISTS (
						    SELECT 1
						    FROM events e
						    WHERE e.deleted = 0
						    AND e.locationid = r.locationid
						    AND e.endDate >= GETDATE()
						    AND (r.arrival < e.endDate AND r.departure > e.startDate)
						)
						ORDER BY r.id ASC
					</cfquery>

					<cfset reservations = getRes.recordcount>
					<cfset resList = []>

					<!--- Track confirmed reservations --->
					<cfloop query="getRes">
					    <cfset overlapCount = 0>
					    
					    <!--- Loop through already confirmed reservations to check overlap --->
					    <cfloop array="#resList#" index="confirmedRes">
					        <cfif (getRes.arrival LT confirmedRes.departure) AND (getRes.departure GT confirmedRes.arrival)>
					            <cfset overlapCount++>
					        </cfif>
					    </cfloop>

					    <cfif overlapCount LT groupLimit>
					        <!--- Confirm the reservation --->
					        <cfquery datasource="CCDOA">
					            UPDATE reservations
					            SET confirmation = 1
					            WHERE id = <cfqueryparam value="#getRes.id#" cfsqltype="cf_sql_integer">
					        </cfquery>
					        <!--- Add to confirmed list for future overlap checking --->
					        <cfset arrayAppend(resList, {
					            id: getRes.id,
					            arrival: getRes.arrival,
					            departure: getRes.departure
					        })>
					    <cfelse>
					        <!--- Set to waitlist --->
					        <cfquery datasource="CCDOA">
					            UPDATE reservations
					            SET confirmation = 0
					            WHERE id = <cfqueryparam value="#getRes.id#" cfsqltype="cf_sql_integer">
					        </cfquery>
					    </cfif>
					</cfloop>

				</cfif>
			</cfloop>
		</cfloop> --->

		<cfquery datasource="CCDOA" name="update">
			UPDATE parking_groups SET capacity = '#form.1S_cap_vgt#' WHERE pGroup = '1S' AND locationid = 'VGT';
			UPDATE parking_groups SET capacity = '#form.1M_cap_vgt#' WHERE pGroup = '1M' AND locationid = 'VGT';
			UPDATE parking_groups SET capacity = '#form.2_cap_vgt#' WHERE pGroup = '2' AND locationid = 'VGT';
			UPDATE parking_groups SET capacity = '#form.3_cap_vgt#' WHERE pGroup = '3' AND locationid = 'VGT';

			UPDATE parking_groups SET capacity = '#form.1S_cap_hnd#' WHERE pGroup = '1S' AND locationid = 'HND';
			UPDATE parking_groups SET capacity = '#form.1M_cap_hnd#' WHERE pGroup = '1M' AND locationid = 'HND';
			UPDATE parking_groups SET capacity = '#form.2_cap_hnd#' WHERE pGroup = '2' AND locationid = 'HND';
			UPDATE parking_groups SET capacity = '#form.3_cap_hnd#' WHERE pGroup = '3' AND locationid = 'HND';
		</cfquery>
	
	<cfelseif form.formName eq 'replaceConfirm'>
		<cfquery datasource="CCDOA" name="confirm">
			UPDATE reservations
			SET confirmation = 1
			WHERE id = #form.res_id#
		</cfquery>

		<cfquery datasource="CCDOA" name="release">
			UPDATE reservations
			SET released = 1
			WHERE id = #form.cid#
		</cfquery>

		<cfquery datasource="CCDOA" name="note">
		    INSERT INTO notes (res_id,note,enteredBy)
		    VALUES (
		    	#form.res_id#
		    	,'CONFIRMED: #form.comment#'
		    	,'#cookie.user_id#'
		    )
		</cfquery>

	<cfelseif form.formName eq 'comfirmFromWaitlist'>
		<cfquery datasource="CCDOA" name="confirm">
			UPDATE reservations
			SET confirmation = 1
			WHERE id = #form.res_id#
		</cfquery>

		
	</cfif>
</cfif>

<cfif isDefined("url.statusChange")>

	<cfquery datasource="CCDOA" name="update">
		UPDATE reservations
		SET status = status+1
		WHERE id = #url.id#
		and status < 3
	</cfquery>
	<cfmail to="mjc@mgn.com" from='mjc@MGN.COM' SUBJECT='TEST'> status+1
	#url.id#
	</CFMAIL>
	   <cftry>
	<cfinclude template='email_send.cfm'>
	
	        <cfcatch>
            <!--- Log the error --->
            <cfmail to="mjc@mgn.com" 
                    from="noreply@example.com" 
                    subject="Reservation Status Update Failed">
                An error occurred while updating the reservation status.<br>
                Error Detail: #cfcatch.message#<br>
                Stack Trace: #cfcatch.detail#
            </cfmail>
        </cfcatch>
    </cftry>
	
</cfif>