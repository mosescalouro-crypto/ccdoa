<cftry>
	<cfexecute name="/var/www/html/ccdoa/admin/tasks/fuel_costs.sh" timeout="9000" errorVariable="error" variable="result"></cfexecute>

	<cfset prices = listToArray(result,'<hr class="clear" />',true,1)>

	<cfset fuel = structNew()>

	<cfloop array="#prices#" index="i">
		<cfif findNoCase("JET A", i)>
			<cfset fuel.jet_a = lsParseCurrency(REMatchNoCase('\$[0-9]*.?[0-9].?[0-9]',i)[1])>
		</cfif>

		<cfif findNoCase("100LL", i)>
			<cfif findNoCase("Self", i)>
				<cfset fuel.LL_s = lsParseCurrency(REMatchNoCase('\$[0-9]*.?[0-9].?[0-9]',i)[1])>
			<cfelseif findNoCase("Full", i)>
				<cfset fuel.LL_f = lsParseCurrency(REMatchNoCase('\$[0-9]*.?[0-9].?[0-9]',i)[1])>
			</cfif>
		</cfif>
	</cfloop>

	<cfloop collection="#fuel#" item="i">
		<cfif !isNumeric(fuel[i])>
			<cfthrow message="#i# value is not numeric.">
		</cfif>
	</cfloop>

	<cfquery datasource="CCDOA" name="update">
		UPDATE fuel
		SET rate = #fuel.jet_a#,
			updated = getdate()
		WHERE id = 1;

		UPDATE fuel
		SET rate = #fuel.LL_f#,
			updated = getdate()
		WHERE id = 2;

		UPDATE fuel
		SET rate = #fuel.LL_s#,
			updated = getdate()
		WHERE id = 3;
	</cfquery>
    <!--- save log in the database --->
    <cfquery datasource="CCDOA">
	    INSERT INTO ScheduleTaskLogs
	    (
	    	TaskName,
	    	Url, 
	    	RunStatus,
	    	Message, 
	    	ServerName
	    )
	    VALUES 
	    (
	    	'fuel cost update',
	    	'https://ccdoa.motioninfo.com/admin/tasks/fuel_costs.cfm',
	    	'Success', 
	    	'Task executed successfully',
	    	'#CGI.SERVER_NAME#'
	    );
	</cfquery>

    <cfoutput>Jet_A: #fuel.jet_a# <br> LL_F: #fuel.LL_f# <br> LL_S: #fuel.LL_s#</cfoutput>

	<cfcatch>
		<cfquery datasource="CCDOA">
		    INSERT INTO ScheduleTaskLogs
		    (
		    	TaskName,
		    	Url, 
		    	RunStatus,
		    	Message, 
		    	ServerName
		    )
		    VALUES 
		    (
		    	'fuel cost update',
		    	'https://ccdoa.motioninfo.com/admin/tasks/fuel_costs.cfm',
		    	'failed', 
		    	'Task executed failed',
		    	'#CGI.SERVER_NAME#'
		    );
		</cfquery>
		<cfmail from="venus@mgn.com"
			to="ben@mgn.com"
			subject="ALERT: CCDOA Fuel Price Failed"
			type="html">
		CCDOA Fuel Price update failed to complete. Check job.
		<br><br>
		Error:
		<br>
		<cfoutput>#cfcatch.Message#</cfoutput>
		</cfmail>
	</cfcatch>
</cftry>