<cfinclude template="/secure/header.cfm">

<style>
.panel table, 
.panel table tbody, 
.panel table thead,
.panel table tfoot {
    display: block;
}

.panel table tbody, 
.panel table thead,
.panel table tfoot {
    overflow-y: scroll;
}

.panel table tbody {
  max-height: 250px;
  width: 100%;
}

.panel table tr {
    width: 100%;
    display: inline-table;
    table-layout: fixed;
}
</style>

<cfset iata = "HND">
<cfif isDefined("url.ap")>
  <cfif url.ap eq 'LAS' or url.ap eq 'VGT'>
    <cfset iata = url.ap>
  </cfif>
</cfif>

<cfquery datasource="CCDOA" name="groups">
  SELECT * FROM parking_groups
  where locationid = '#iata#'
</cfquery>

<cfquery datasource="CCDOA" name="events">
  SELECT id,name,locationid FROM events 
  WHERE deleted = 0
  and locationid = '#iata#'
  order by startDate asc
</cfquery>

<cfset event = 'h-6'>
<cfif isDefined("url.event")>
  <cfset event = url.event>
</cfif>

<cfif findNoCase("e-", event)>
  <cfset eventID = listToArray(event, "-")>
  <cfquery datasource="CCDOA" name="selectedEvent">
    select startDate,endDate,locationid from events
    where id = #eventID[2]#
  </cfquery>
</cfif>

<cfquery datasource="CCDOA" name="inbound">
  declare @currentLocal datetime = getdate() AT TIME ZONE 'UTC' AT TIME ZONE 'Pacific Standard Time';

  SELECT 
    r.id res_id, 
    conf_no,
    locationid,
    reg, 
    name,
    arrival,
    departure,
    estTotal,
    status,
    a.make ac_make,
    a.model ac_model,
    a.sqft ac_sqft
  FROM reservations r
  JOIN aircraft a on r.ACType = a.id ---or actype=legacyid
  WHERE status = 1
  AND deleted = 0
  AND r.locationid = '#iata#'
  <cfif isDefined("selectedEvent")>
    AND ('#selectedEvent.startDate#' <= r.departure AND '#selectedEvent.endDate#' >= r.arrival)
    --AND locationid = '#selectedEvent.locationid#'
  </cfif>
  <cfif findNoCase("d-", event)>
    <cfset days = listToArray(event, "-")>
    AND datediff(dd, @currentLocal, arrival) = #days[2]#
  </cfif>
  <cfif findNoCase("h-", event)>
    <cfset hours = listToArray(event, "-")>
    AND arrival between dateadd(hour, -6, @currentLocal) and dateadd(hour, #hours[2]#, @currentLocal)
  </cfif>
  order by r.id desc
</cfquery>

<!--- <cfspreadsheet
  action="write"
  filename="#ExpandPath('export/')#CCDOA_parking_#cookie.user_id#.xls"
  query="inbound"
  overwrite="true"> --->

<div class="row">
    <div class="col-lg-12">
        <h2 class="page-header"><!---<span style="font-size: 1.5rem" class="pull-right">Refreshing in <b id="countdown"></b> sec</span>---><cfoutput>#iata#</cfoutput> Parking Outlook</h2>
    </div>
</div>

<div class="row">
  <cfoutput query="groups">
    <cfquery datasource="CCDOA" name="parked">
      SELECT 
        r.id res_id, 
        reg, 
        arrival,
        departure,
        a.sqft ac_sqft,
        a.make + ' ' + a.model as actype
      FROM reservations r
      JOIN aircraft a on r.ACType = a.id or actype=legacyid
      WHERE r.status = 2
      AND r.locationid = '#iata#'
      <cfif len(sqft_max)>
        AND a.sqft BETWEEN #sqft_min# AND #sqft_max#
      <cfelse>
        AND a.sqft >= #sqft_min#
      </cfif>
    </cfquery>

    <cfset statusColor = "success">
    <cfif capacity - parked.recordcount gt 0 AND capacity - parked.recordcount lt 3>
      <cfset statusColor = "warning">
    <cfelseif capacity - parked.recordcount lt 1>
      <cfset statusColor = "danger">
    </cfif>

    <div class="col-lg-3">
        <div class="panel panel-#statusColor#">
            <div class="panel-heading">
                <h3 class="panel-title">Group #pGroup# <span style="font-size:0.8em">(#parked.recordcount# of #capacity# slots)</span></h3>
            </div>
            <table class="table table-striped table-condensed">
                <thead>
                    <tr>
                        <th>Aircraft</th>
                        <th>Type</th>
                        <th>Est Departure</th>
                        <!---<th></th>--->
                    </tr>
                </thead>
                <tbody>
                <cfif parked.recordcount>
                  <cfloop query="parked">
                    <tr>
                      <td>#parked.reg#</td>
                      <td>#parked.actype#</td>
                      <td>#datetimeformat(parked.departure, 'dd-mmm-yyyy HH:mm')#</td>
                      <!---<td><button class="btn btn-xs btn-primary" data-toggle="modal" data-target="##detailsModal" data-id="#res_id#"><i class="fa fa-search" aria-hidden="true"></i></button></td>--->
                    </tr>
                  </cfloop>
                <cfelse>
                  <tr>
                      <td colspan=3>No aircraft of this size are currently parked.</td>
                    </tr>
                </cfif>
                </tbody>
            </table>
        </div>
    </div>
  </cfoutput>
  </div>

  <div class="row">
    <div class="col-lg-12">
        <h3 class="page-header">Inbound Reservations
          <!--- <form class="form pull-right" method="POST">
            <select name="timespan" class="form-control input-sm">
              <option value="h-6"<cfif event eq 'h-6'> selected</cfif>>6 Hours</option>
              <option value="h-12"<cfif event eq 'h-12'> selected</cfif>>12 Hours</option>
              <option value="d-0"<cfif event eq 'd-0'> selected</cfif>>Today</option>
              <option value="d-1"<cfif event eq 'd-1'> selected</cfif>>Tomorrow</option>
              <cfoutput query="events">
                <option value="e-#id#"<cfif event eq 'e-#id#'> selected</cfif>>#name# (#locationid#)</option>
              </cfoutput>
            </select>
          </form>
          <cfif StructKeyExists(cookie, "admin") AND cookie.admin NEQ 0>
            <a href="export/<cfoutput>CCDOA_parking_#cookie.user_id#.xls</cfoutput>" target="_blank" class="btn btn-sm btn-success pull-right" title="Export Data to Excel" style="margin-right:15px"><i class="fa fa-file-excel-o" aria-hidden="true"></i> Excel Export</a>
          </cfif> --->

            <form id="exportForm" action="exportParkingData.cfm" method="post" target="_blank" class="form pull-right" style="display:flex; align-items:center; flex-direction: row-reverse; gap:10px;">

                <!-- Dropdown -->
                <select name="event" class="form-control input-sm" id="timespanSelect">
                    <option value="h-6"<cfif event eq 'h-6'> selected</cfif>>6 Hours</option>
                    <option value="h-12"<cfif event eq 'h-12'> selected</cfif>>12 Hours</option>
                    <option value="d-0"<cfif event eq 'd-0'> selected</cfif>>Today</option>
                    <option value="d-1"<cfif event eq 'd-1'> selected</cfif>>Tomorrow</option>
                    <cfoutput query="events">
                        <option value="e-#id#"<cfif event eq 'e-#id#'> selected</cfif>>#name# (#locationid#)</option>
                    </cfoutput>
                </select>

                <!-- Export Button -->
                <button type="submit" class="btn btn-sm btn-success" title="Export Data to Excel">
                    <i class="fa fa-file-excel-o" aria-hidden="true"></i> Excel Export
                </button>

                <!-- Hidden inputs -->
                <input type="hidden" name="ap" value="<cfif isDefined('url.ap')><cfoutput>#url.ap#</cfoutput></cfif>">
                <cfloop collection="#form#" item="fKey">
                    <input type="hidden" name="#fKey#" value="#form[fKey]#">
                </cfloop>

            </form>
        </h3>
    
      <table class="table table-striped table-hover table-condensed dataTable">
        <thead>
            <tr>
              <th>ID</th>
              <th>Conf #</th>
              <th>Tail No</th>
              <th>Name</th>
              <th>Arrival Date</th>
              <th>Departure Date</th>
              <th>Airport</th>
              <th>Status</th>
              <th>Stay Duration</th>
              <th>Aircraft Type</th>
              <th>Parking</th>
              <th>Cost Est.</th>
              <!---<th></th>--->
            </tr>
        </thead>
        <tbody>
        <cfoutput query="inbound">
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
            <td>#conf_no#</td>
            <td>#reg#</td>
            <td>#name#</td>
            <td>#datetimeformat(arrival)#</td>
            <td>#datetimeformat(departure)#</td>
            <td>#locationid#</td>
            <td>
              <cfif status eq 1>
                Pending
              <cfelseif status eq 2>
                Arrived
              <cfelseif status eq 3>
                Departed
              <cfelseif status eq 0>
                Cancelled
              </cfif>
            </td>
            <td>
              <cfif stayDays gt 0>
              #stayDays# day<cfif stayDays gt 1>s</cfif><cfif stayDays gt 0 AND stayHours gt 0>, </cfif>
            </cfif>
            <cfif stayHours gt 0>
              #stayHours# hrs
            </cfif>
            </td>
            <td>#ac_make#, #ac_model#</td>
            <td>#parking#</td>
            <td>#DollarFormat(estTotal)#</td>
            <!---<td><button class="btn btn-xs btn-primary" data-toggle="modal" data-target="##detailsModal" data-id="#res_id#"><i class="fa fa-search" aria-hidden="true"></i> View Details</button></td>--->
        </cfoutput>
        </tbody>
      </table>
  </div>

  <div class="modal fade" id="detailsModal" tabindex="-1" role="dialog">
      <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
            <h4 class="modal-title">Reservation Details</h4>
          </div>
          <div class="modal-body"></div>
        </div>
      </div>
    </div>
</div>

<script type="text/javascript">

$(function() {

  $('#detailsModal').on('show.bs.modal', function (event) {
      var link = $(event.relatedTarget); // Button that triggered the modal
      var modal = $(this);

      var data = { 
          id: link.data('id')
      }

      $.get( "get_details.cfm", data, function( res ) {
          modal.find('.modal-body').html( res );

          $(".statusChange").click(function(){
            if (confirm('Are you sure you want to change the status of this reservation?')) {
              $.get( "ajax_submit.cfm?statusChange", data, function( res ) {
                  location.reload();
                });
            }
          });
      });
  });

  //countdown(60);

});

function countdown(remaining) {
  if(remaining === 0)
      location.reload(true);
  document.getElementById('countdown').innerHTML = remaining;
  setTimeout(function(){ countdown(remaining - 1); }, 1000);
}

</script>

<script>
    document.getElementById('timespanSelect').addEventListener('change', function() {
        var selected = this.value;
        var locationCode = '<cfoutput>#iata#</cfoutput>';
        var url = window.location.href.split('?')[0] + "?event=" + selected;

        // Include airport if it's VGT
        if(locationCode === 'VGT'){
            url += "&ap=" + locationCode;
        }

        window.location.href = url;
    });
</script>

<cfinclude template="/secure/footer.cfm">