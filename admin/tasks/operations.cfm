<cftry>
	<cfquery datasource="BQ" name="bq_ops">
		SELECT opid,local as localtime,optime,locationid,registration,op FROM `x-guard-173415.Report.OPERATIONS` 
		WHERE OPTIME >= timestamp_sub(current_timestamp(),INTERVAL 72 HOUR)
		and locationid in ('LAS','VGT','HND')
	</cfquery>

	<cfquery datasource="CCDOA" name="arrivals">
		declare @currentLocal datetime = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time';

		SELECT id,reg,arrival,locationid FROM reservations
		WHERE arrival between dateadd(hour, -2, @currentLocal) and dateadd(hour, 2, @currentLocal)
		and status = 1
	</cfquery>

	<cfoutput query="arrivals">
		<cfquery dbtype="query" name="op" maxrows=1>
			SELECT * from bq_ops
			WHERE registration = '#reg#'
			AND op = 'ARRIVAL'
			order by localtime desc
		</cfquery>

		<cfif op.recordcount>
			<cfquery datasource="CCDOA" name="update">
				UPDATE reservations
				SET status = 2
				WHERE id = #id#;

				INSERT INTO res_ops (resid,opid,locationid,optime,local,op)
				VALUES (
					#id#,
					#op.opid#,
					'#op.locationid#',
					'#op.optime#',
					'#op.localtime#',
					'#op.op#'
					);
			</cfquery>
		</cfif>
	</cfoutput>

	<cfquery datasource="CCDOA" name="departures">
		declare @currentLocal datetime = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time';

		SELECT id,reg,arrival,locationid FROM reservations
		WHERE status = 2
	</cfquery>

	<cfoutput query="departures">
		<cfquery dbtype="query" name="op" maxrows=1>
			SELECT * from bq_ops
			WHERE registration = '#reg#'
			AND op = 'DEPARTURE'
			order by localtime desc
		</cfquery>

		<cfif op.recordcount>
			<cfquery datasource="CCDOA" name="update">
				UPDATE reservations
				SET status = 3
				WHERE id = #id#;

				INSERT INTO res_ops (resid,opid,locationid,optime,local,op)
				VALUES (
					#id#,
					#op.opid#,
					'#op.locationid#',
					'#op.optime#',
					'#op.localtime#',
					'#op.op#'
					);
			</cfquery>
		</cfif>

	</cfoutput>

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
	    VALUES (
	    	'Tracking_aircraft',
	    	'https://ccdoa.motioninfo.com/admin/tasks/operations.cfm',
	    	'Success', 
	    	'Task executed successfully',
	    	'#CGI.SERVER_NAME#'
	    );
	</cfquery>
	
	<cfcatch type="any">
		<cfdump var="#cfcatch#">
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
		    	'Tracking_aircraft',
		    	'https://ccdoa.motioninfo.com/admin/tasks/operations.cfm',
		    	'failed', 
		    	'Task executed failed',
		    	'#CGI.SERVER_NAME#'
		    );
		</cfquery>
	</cfcatch>
</cftry>