<cftry>
    <!--- Expand the time window for operations lookup --->
    <cfquery datasource="BQ" name="bq_ops">
        SELECT opid,local as localtime,optime,locationid,registration,op 
        FROM `x-guard-173415.Report.OPERATIONS` 
        WHERE OPTIME >= timestamp_sub(current_timestamp(),INTERVAL 72 HOUR)
        and locationid in ('LAS','VGT','HND')
    </cfquery>
    
    <!--- Process Arrivals --->
    <cfquery datasource="CCDOA" name="arrivals">
        declare @currentLocal datetime = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time';
        SELECT id,reg,arrival,locationid FROM reservations
        WHERE arrival between dateadd(hour, -2, @currentLocal) and dateadd(hour, 2, @currentLocal)
        and status = 1
    </cfquery>
    
    <cfoutput query="arrivals">
        <cfquery dbtype="query" name="op" maxrows="1">
            SELECT * from bq_ops
            WHERE registration = '#reg#'
            AND op = 'ARRIVAL'
            order by localtime desc
        </cfquery>
        <cfif op.recordcount>
            <!--- Check if this operation was already recorded --->
            <cfquery datasource="CCDOA" name="check_existing">
                SELECT resid FROM res_ops 
                WHERE resid = #id# AND opid = #op.opid#
            </cfquery>
            
            <cfif check_existing.recordcount EQ 0>
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
                        'ARRIVAL'
                    );
                </cfquery>
            </cfif>
        </cfif>
    </cfoutput>
    
    <!--- Process Departures - Look for ANY aircraft currently showing as parked --->
    <cfquery datasource="CCDOA" name="departures">
        SELECT id, reg, arrival, departure, locationid 
        FROM reservations
        WHERE status = 2
    </cfquery>
    
    <cfoutput query="departures">
        <!--- Look for departure operation in BigQuery --->
        <cfquery dbtype="query" name="op" maxrows="1">
            SELECT * from bq_ops
            WHERE registration = '#reg#'
            AND op = 'DEPARTURE'
            AND localtime > '#DateFormat(arrival, "yyyy-mm-dd")# #TimeFormat(arrival, "HH:mm:ss")#'
            order by localtime desc
        </cfquery>
        
        <cfif op.recordcount>
            <!--- Check if this operation was already recorded --->
            <cfquery datasource="CCDOA" name="check_existing">
                SELECT resid FROM res_ops 
                WHERE resid = #id# AND opid = #op.opid#
            </cfquery>
            
            <cfif check_existing.recordcount EQ 0>
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
                        'DEPARTURE'
                    );
                </cfquery>
            </cfif>
        <cfelse>
            <!--- If departure time has passed and no operation found, auto-mark as departed --->
            <cfif IsDate(departure) AND DateCompare(departure, Now()) LT 0>
                <cfset hoursSinceDeparture = DateDiff("h", departure, Now())>
                <cfif hoursSinceDeparture GT 2>
                    <cfquery datasource="CCDOA" name="auto_depart">
                        UPDATE reservations
                        SET status = 3
                        WHERE id = #id#;
                    </cfquery>
                </cfif>
            </cfif>
        </cfif>
    </cfoutput>
    
    <!--- Log success --->
    <cfquery datasource="CCDOA">
        INSERT INTO ScheduleTaskLogs
        (TaskName, Url, RunStatus, Message, ServerName)
        VALUES (
            'Tracking_aircraft',
            'https://ccdoa.motioninfo.com/admin/tasks/operations.cfm',
            'Success', 
            'Task executed successfully - Processed #arrivals.recordcount# arrivals, #departures.recordcount# potential departures',
            '#CGI.SERVER_NAME#'
        );
    </cfquery>
    
    <cfcatch type="any">
        <cfquery datasource="CCDOA">
            INSERT INTO ScheduleTaskLogs
            (TaskName, Url, RunStatus, Message, ServerName)
            VALUES (
                'Tracking_aircraft',
                'https://ccdoa.motioninfo.com/admin/tasks/operations.cfm',
                'failed', 
                'Error: #cfcatch.message# - #cfcatch.detail#',
                '#CGI.SERVER_NAME#'
            );
        </cfquery>
    </cfcatch>
</cftry>