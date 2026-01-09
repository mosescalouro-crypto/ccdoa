<cfif isDefined("url.del_id")>
  <cfquery datasource="CCDOA" name="delete">
    update events
    set deleted = 1
    where id = #url.del_id#
  </cfquery>
  <cflocation url="events.cfm">
  <cfabort>

</cfif>

<cfif isDefined("form.startDate")>
    <cfif isDefined("form.event_id")>
        <cftry>
            <cfquery datasource="CCDOA" name="update">
                UPDATE events
                SET startDate = '#form.startDate#',
                  endDate = '#form.endDate#',
                  name = '#form.name#',
                  ppr = '#form.ppr#',
                  locationid = '#form.locationid#',
                  fee_1S = '#lsParseCurrency(form.fee_1S, 'en_us')#',
                  fee_1M = '#lsParseCurrency(form.fee_1M, 'en_us')#',
                  fee_2 = '#lsParseCurrency(form.fee_2, 'en_us')#',
                  fee_3 = '#lsParseCurrency(form.fee_3, 'en_us')#',
                  feeStartDate = '#form.feestartDate#',
                  feeEndDate = '#form.feeEndDate#',
                  limit_1S = '#form.limit_1S#',
                  limit_1M = '#form.limit_1M#',
                  limit_2 = '#form.limit_2#',
                  limit_3 = '#form.limit_3#',
                  updatedBy = '#cookie.user_id#',
                  updated = getdate()
                WHERE id = #form.event_id#
            </cfquery>

            <cfquery datasource="CCDOA" name="getEventOLDDetail">
                select * from events where id = #form.event_id#
            </cfquery>

            <cfquery datasource="CCDOA" name="getEventOLDDateReservations">
                select * from reservations
                where ('#getEventOLDDetail.startDate#' <= departure) and ('#getEventOLDDetail.endDate#' >= arrival)
                and deleted = 0 
                and locationid = '#getEventOLDDetail.locationid#'
                and confirmation = 0
            </cfquery>

            <cfoutput query="getEventOLDDateReservations">
                <cfquery datasource="CCDOA" name="overlap">
                    SELECT count(*) total, max(pGroup) pGroup, ISNULL(max(capacity),1) capacity
                    FROM reservations r 
                    INNER JOIN aircraft_view a on r.actype = a.id OR a.legacyID = r.ACType
                    AND r.locationid = a.locationid
                    WHERE r.locationid = '#getEventOLDDetail.locationid#'
                    AND r.deleted = 0
                    AND r.confirmation = 1
                    AND ('#getEventOLDDetail.startDate#' <= r.departure) and ('#getEventOLDDetail.endDate#' >= r.arrival)
                    <!---AND (arrival >= '#getEventOLDDetail.startDate#' ) and (departure <= '#getEventOLDDetail.endDate#')--->
                    AND a.pGroup = (SELECT pGroup from aircraft_view where id = #getEventOLDDateReservations.actype# and locationid = '#getEventOLDDetail.locationid#')
                </cfquery>
                <cfif getEventOLDDetail.recordcount>
                    <cfif StructKeyExists(getEventOLDDetail, "limit_" & overlap.pGroup)>
                        <cfset event_capacity = getEventOLDDetail["limit_" & overlap.pGroup]>
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
                </cfif>
                <cfquery datasource="CCDOA" name="updateReservations">
                    update reservations set confirmation = #confirm# where ID = #getEventOLDDateReservations.ID#
                </cfquery>

            </cfoutput>

            <!--- automatically update the reservation from waitlist to confirm on the base of group space --->
            <!--- <cfquery datasource="CCDOA" name="getPgroups">
                SELECT DISTINCT
                    CASE 
                        WHEN sqft < 1250 THEN '1S'
                        WHEN sqft BETWEEN 1250 AND 1999 THEN '1M'
                        WHEN sqft BETWEEN 2000 AND 3499 THEN '2'
                        ELSE '3'
                    END as groupName
                FROM aircraft
            </cfquery>
            <cfloop query="getPgroups">
                <cfquery datasource="CCDOA" name="getReservationsBeteenEvent">
                    SELECT *
                    FROM reservations r 
                    INNER JOIN aircraft_view a on r.actype = a.id AND r.locationid = a.locationid
                    WHERE r.locationid = '#getEventOLDDetail.locationid#'
                    AND r.deleted = 0
                    AND a.pGroup = '#getPgroups.groupName#'
                    AND ('#getEventOLDDetail.startDate#' <= departure) and ('#getEventOLDDetail.endDate#' >= arrival)
                    order by r.id asc
                </cfquery>

                <cfif getReservationsBeteenEvent.recordcount GT 0> 
                    <cfset i = 1>
                    <cfloop query="getReservationsBeteenEvent">
                        <cfset limitKey = "LIMIT_" & getPgroups.groupName>
                        <cfset limitValue = evaluate("form." & limitKey)>
                        <cfif i LTE limitValue>
                            <cfset isConfirmed = 1>
                        <cfelse>
                            <cfset isConfirmed = 0>
                        </cfif>
                        <cfquery datasource="CCDOA">
                            UPDATE reservations
                            SET confirmation = '#isConfirmed#'
                            WHERE id = <cfqueryparam value="#getReservationsBeteenEvent.id#" cfsqltype="cf_sql_integer">
                        </cfquery>
                        <cfset i = i + 1>
                    </cfloop>
                </cfif>
            </cfloop> --->

            <cfcatch>
                <cfdump var="#cfcatch#" abort="true">
            </cfcatch>
        </cftry>

        <cflocation url="events.cfm">

        <cfabort>
    <cfelse>  
        <cfif NOT isDefined("form.limit_1S") OR trim(form.limit_1S) EQ "">
          <cfset form.limit_1S = 0>
        </cfif>

        <cfif NOT isDefined("form.limit_1M") OR trim(form.limit_1M) EQ "">
            <cfset form.limit_1M = 0>
        </cfif>

        <cfif NOT isDefined("form.limit_2") OR trim(form.limit_2) EQ "">
            <cfset form.limit_2 = 0>
        </cfif>

        <cfif NOT isDefined("form.limit_3") OR trim(form.limit_3) EQ "">
            <cfset form.limit_3 = 0>
        </cfif>

        <cfif NOT isDefined("form.fee_1S") OR trim(form.fee_1S) EQ "">
            <cfset form.fee_1S = "0.0">
        </cfif>

        <cfif NOT isDefined("form.fee_1M") OR trim(form.fee_1M) EQ "">
            <cfset form.fee_1M = "0.0">
        </cfif>

        <cfif NOT isDefined("form.fee_2") OR trim(form.fee_2) EQ "">
            <cfset form.fee_2 = "0.0">
        </cfif>

        <cfif NOT isDefined("form.fee_3") OR trim(form.fee_3) EQ "">
            <cfset form.fee_3 = "0.0">
        </cfif>

        <cfquery datasource="CCDOA" name="insert">
            INSERT INTO events (
                startDate,
                endDate,
                name,
                ppr,
                locationid,
                feeStartDate,
                feeEndDate,
                fee_1S,
                fee_1M,
                fee_2,
                fee_3,
                limit_1S,
                limit_1M,
                limit_2,
                limit_3,
                updatedBy
            )
            VALUES (
              '#form.startDate#',
              '#form.endDate#',
              '#form.name#',
              '#form.ppr#',
              '#form.locationid#',
              '<cfif form.feestartdate is ''>#form.startdate#<cfelse>#form.feeStartDate#</cfif>'
              ,'<cfif form.feeenddate is ''>#form.enddate#<cfelse>#form.feeendDate#</cfif>',
              '#lsParseCurrency(form.fee_1S, 'en_us')#',
              '#lsParseCurrency(form.fee_1M, 'en_us')#',
              '#lsParseCurrency(form.fee_2, 'en_us')#',
              '#lsParseCurrency(form.fee_3, 'en_us')#',
              '#form.limit_1S#',
              '#form.limit_1M#',
              '#form.limit_2#',
              '#form.limit_3#',
              '#cookie.user_id#'
            )
        </cfquery>
        <!--- automatically update the reservation from waitlist to confirm on the base of group space --->
        <!--- <cfquery datasource="CCDOA" name="getgroups">
            SELECT DISTINCT
                CASE 
                    WHEN sqft < 1250 THEN '1S'
                    WHEN sqft BETWEEN 1250 AND 1999 THEN '1M'
                    WHEN sqft BETWEEN 2000 AND 3499 THEN '2'
                    ELSE '3'
                END as groupName
            FROM aircraft
        </cfquery>
        <cfloop query="getgroups">
            <cfquery datasource="CCDOA" name="getReservationBeteenEvent">
                SELECT *
                FROM reservations r 
                INNER JOIN aircraft_view a on r.actype = a.id AND r.locationid = a.locationid
                WHERE r.locationid = '#form.LOCATIONID#'
                AND r.deleted = 0
                AND a.pGroup = '#getgroups.groupName#'
                AND ('#form.STARTDATE#' <= departure) and ('#form.ENDDATE#' >= arrival)
                order by r.id asc
            </cfquery>

            <cfif getReservationBeteenEvent.recordcount GT 0> 
                <cfset i = 1>
                <cfloop query="getReservationBeteenEvent">
                    <cfset limitKey = "LIMIT_" & getgroups.groupName>
                    <cfset limitValue = evaluate("form." & limitKey)>
                    <cfif i LTE limitValue>
                        <cfset isConfirmed = 1>
                    <cfelse>
                        <cfset isConfirmed = 0>
                    </cfif>
                    <cfquery datasource="CCDOA">
                        UPDATE reservations
                        SET confirmation = '#isConfirmed#'
                        WHERE id = <cfqueryparam value="#getReservationBeteenEvent.id#" cfsqltype="cf_sql_integer">
                    </cfquery>
                    <cfset i = i + 1>
                </cfloop>
            </cfif>
        </cfloop> --->

        <cflocation url="events.cfm">
        <cfabort>
    </cfif>  
</cfif>

<cfinclude template="header.cfm">

<cfquery datasource="CCDOA" name="results">
  SELECT * FROM events e
  LEFT JOIN users u on e.updatedBy = u.id
  where e.deleted = 0
  order by e.startDate asc
</cfquery>

<style>
  .pagination,
  .dataTables_length {
    margin: 5px 0;
  }

  .pagination {
    float: right;
  }
</style>

    <div class="row">
        <div class="col-lg-12">
            <h2 class="page-header">
                <cfif StructKeyExists(cookie, "admin") AND cookie.admin NEQ 3>
                    <button class="btn btn-success pull-right" data-toggle="modal" data-target="#newEventModal"><i class="fa-solid fa-plus"></i> New Event</button>
                </cfif>
              Event Management
            </h2>
        </div>
    </div>

    <div class="row">
        <div class="col-lg-12" id="searchResult">
          <table class="table table-striped table-hover table-condensed dataTable">
            <thead>
                <tr>
                  <th>#</th>
                  <th>Start Date</th>
                  <th>End Date</th>
                  <th>Airport</th>
                  <th>Event Name</th>
                  <th>PPR?</th>
                  <th>Event Fee</th>
                  <th>Fee Start</th>
                  <th>Fee End</th>
                  <th>Modified</th>
                  <cfif StructKeyExists(cookie, "admin") AND cookie.admin NEQ 3>
                      <th>Edit</th>
                  </cfif>
                </tr>
            </thead>
            <tbody>
            <cfoutput query="results">
              <tr>
                <td>#id#</td>
                <td>#datetimeformat(startDate)#</td>
                <td>#datetimeformat(endDate)#</td>
                <td>#locationid#</td>
                <td>#name#</td>
                <td><cfif ppr>Yes<cfelse>No</cfif></td>
                <td>#dollarformat(fee_1S)#+</td>
                <td>#datetimeformat(feeStartDate)#</td>
                <td>#datetimeformat(feeEndDate)#</td>
                <td><small>#dateformat(updated)# by #last_name#, #first_name#</small></td>
                <cfif StructKeyExists(cookie, "admin") AND cookie.admin NEQ 3>
                    <td><button class="btn btn-xs btn-primary" data-toggle="modal" data-target="##detailsModal" data-id="#id#"><i class="fa fa-gear" aria-hidden="true"></i></button></td>
                </cfif>

            </cfoutput>
            </tbody>
          </table>
        </div>
    </div>

    <div class="modal fade" id="newEventModal" tabindex="-1" role="dialog">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
            <h4 class="modal-title">New Special Event</h4>
          </div>
          <div class="modal-body" id="modalContent">
            <form class="form event_form" id="newEventForm" method="POST">
                <div class="form-group">
                  <label for="name">Event Name</label>
                  <input type="text" class="form-control" id="eventNameId" name="name">
                  <div class="error-msg text-danger" id="eventNameError"></div>
                </div>
                <div class="row">
                  <div class="col-sm-6">
                      <div class="form-group">
                        <label for="startDate">Start Date</label>
                        <input type="text" class="form-control datepicker" name="startDate" placeholder="Select date & time">
                        <div class="error-msg text-danger" id="startDateError"></div>
                      </div>
                  </div>
                  <div class="col-sm-6">
                      <div class="form-group">
                        <label for="endDate">End Date</label>
                        <input type="text" class="form-control datepicker" name="endDate" placeholder="Select date & time">
                        <div class="error-msg text-danger" id="endDateError"></div>
                      </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-sm-6">
                      <div class="form-group">
                        <label for="fee">PPR Event?</label>
                        <br>
                        <label class="radio-inline">
                          <input type="radio" name="ppr" value="1"> Yes
                        </label>
                        <label class="radio-inline">
                          <input type="radio" name="ppr" value="0" checked> No
                        </label>
                      </div>
                  </div>
                  <div class="col-sm-6">
                    <div class="form-group">
                      <label for="airport">Airport</label>
                      <br>
                      <label class="radio-inline">
                        <input type="radio" name="locationid" value="HND" checked> HND
                      </label>
                      <label class="radio-inline">
                        <input type="radio" name="locationid" value="VGT"> VGT
                      </label>
                    </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-sm-6">
                      <div class="form-group">
                        <label for="sqft">Fee Start Date</label>
                        <input type="text" class="form-control datepicker" id="feeStartDate" name="feeStartDate" placeholder="Select date & time">
                        <div class="error-msg text-danger" id="feeStartDateError"></div>
                      </div>
                  </div>
                  <div class="col-sm-6">
                      <div class="form-group">
                        <label for="parking">Fee End Date</label>
                        <input type="text" class="form-control datepicker" id="feeStartDate" name="feeEndDate" placeholder="Select date & time">
                        <div class="error-msg text-danger" id="feeEndDateError"></div>
                      </div>
                  </div>
                </div>
                <h4 class="page-header" style="margin-top: 10px">Parking Group Capacity and Fees</h4>
                <div class="row">
                  <div class="col-sm-3">
                      <div class="form-group">
                        <label for="sqft">Group 1S</label>
                        <input type="text" class="form-control" name="limit_1S" placeholder="Capacity">
                      </div>
                  </div>
                  <div class="col-sm-3">
                      <div class="form-group">
                        <label for="sqft">Group 1M</label>
                        <input type="text" class="form-control" name="limit_1M" placeholder="Capacity">
                      </div>
                  </div>
                  <div class="col-sm-3">
                      <div class="form-group">
                        <label for="sqft">Group 2</label>
                        <input type="text" class="form-control" name="limit_2" placeholder="Capacity">
                      </div>
                  </div>
                  <div class="col-sm-3">
                      <div class="form-group">
                        <label for="sqft">Group 3</label>
                        <input type="text" class="form-control" name="limit_3" placeholder="Capacity">
                      </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-sm-3">
                      <div class="form-group">
                        <label for="sqft">Fee 1S</label>
                        <input type="text" class="form-control" name="fee_1S" placeholder="0.00">
                      </div>
                  </div>
                  <div class="col-sm-3">
                      <div class="form-group">
                        <label for="sqft">Fee 1M</label>
                        <input type="text" class="form-control" name="fee_1M" placeholder="0.00">
                      </div>
                  </div>
                  <div class="col-sm-3">
                      <div class="form-group">
                        <label for="sqft">Fee 2</label>
                        <input type="text" class="form-control" name="fee_2" placeholder="0.00">
                      </div>
                  </div>
                  <div class="col-sm-3">
                      <div class="form-group">
                        <label for="sqft">Fee 3</label>
                        <input type="text" class="form-control" name="fee_3" placeholder="0.00">
                      </div>
                  </div>
                </div>
            <div class="responseContainer"></div>
          </div>
          <div class="modal-footer">
            <button type="submit" class="btn btn-primary pull-right submitButton">Submit</button>
          </div>
          </form>
        </div>
      </div>
    </div>

    <div class="modal fade" id="detailsModal" tabindex="-1" role="dialog">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
            <h4 class="modal-title">Special Event Details</h4>
          </div>
          <div class="modal-body" id="modalContent">
          </div>
          <div class="modal-footer">
      
      <a class="deleteEvent btn btn-danger pull-left" data-id="#id#"><i class="glyphicon glyphicon-trash"></i> Delete Event</a>

            <button type="submit" class="btn btn-primary editSubmit"><i class="glyphicon glyphicon-floppy-disk"></i> Save Changes</button>
          </div>
        </div>
      </div>
    </div>

<!-- DataTables JavaScript -->
<script src="/js/dataTables/jquery.dataTables.min.js"></script>
<script src="/js/dataTables/dataTables.bootstrap.min.js"></script>

<link rel="stylesheet" href="/css/bootstrap-datetimepicker.min.css" />
<script src="//cdnjs.cloudflare.com/ajax/libs/moment.js/2.8.4/moment.min.js"></script>
<script src="/js/bootstrap-datetimepicker.min.js"></script>

<script type="text/javascript">

$(function() {
    
    function validateDates(form) {
        // Use the form context for all lookups
        let $form = $(form);
        console.log(form);

        let eventName    = $form.find('input[name="name"]').val();
        let startDate    = $form.find('input[name="startDate"]').val();
        let endDate      = $form.find('input[name="endDate"]').val();
        let feeStartDate = $form.find('input[name="feeStartDate"]').val();
        let feeEndDate   = $form.find('input[name="feeEndDate"]').val();
        
        $(form).find(".error-msg").html("");
        // Clear old errors within this form

        let isValid = true;

        if (!eventName) {
            $form.find("#eventNameError").html("Event Name is required.");
            isValid = false;
        }
        if (!startDate) {
            $form.find("#startDateError").html("Start Date is required.");
            isValid = false;
        }
        if (!endDate) {
            $form.find("#endDateError").html("End Date is required.");
            isValid = false;
        }
        if (startDate && endDate && new Date(endDate) <= new Date(startDate)) {
            $form.find("#endDateError").html("End Date must be after Start Date.");
            isValid = false;
        }
        if (!feeStartDate) {
            $form.find("#feeStartDateError").html("Fee Start Date is required.");
            isValid = false;
        }
        if (!feeEndDate) {
            $form.find("#feeEndDateError").html("Fee End Date is required.");
            isValid = false;
        }
        if (feeStartDate && feeEndDate && new Date(feeEndDate) <= new Date(feeStartDate)) {
            $form.find("#feeEndDateError").html("Fee End Date must be after Fee Start Date.");
            isValid = false;
        }

        return isValid;
    }

        // Run validation on input change
        // $('input[name="startDate"], input[name="endDate"], #feeStartDate, #feeEndDate,#eventNameId').on("change blur", function () {
        //     validateDates();
        // });


        // New form
    $('#newEventForm input').on('change blur', function() {
        validateDates(this.form);
    });
    $('#newEventForm').on('submit', function(e){
        if(!validateDates(this)) e.preventDefault();
    });

    // Edit form (delegated, for dynamically loaded forms)
    $(document).on('change blur', '#editEventForm input', function() {
        validateDates(this.form);
    });

    // Handle dynamic edit form submit
    $(document).on('click', '.editSubmit', function(e) {
        e.preventDefault();
        let form = $('#editEventForm')[0];
        if(validateDates(form)) {
            form.submit(); // Only submit if validation passes
        }
    });

   $('.dataTable').DataTable({
      responsive: true,
      "iDisplayLength": 50,
      "aaSorting": [],
      "searching": true,
      dom: "<'row'<'col-sm-4'l><'col-sm-4'f><'col-sm-4'p>>" +
              "<'row'<'col-sm-12'tr>>" +
          "<'row'<'col-sm-5'i><'col-sm-7'p>>",
    });

    // Initialize modal and load dynamic content
    $('#detailsModal').on('show.bs.modal', function (event) {
        const button = $(event.relatedTarget); // Button that triggered the modal
        const eventId = button.data('id'); // Get event ID from the button's data-id attribute
        const modal = $(this);

        // Load event details dynamically into the modal
        $.get('get_event.cfm', { id: eventId }, function (response) {
            modal.find('.modal-body').html(response);
        });

        // Set the event ID in the delete button's data-id attribute
        modal.find('.deleteEvent').attr('data-id', eventId);
    });

    $('.datepicker').datetimepicker({
      pickTime: true,
      format : 'MM/DD/YYYY HH:mm',
      minDate: new Date()
    });


});



// $('.editSubmit').on('click', function(e) {
//     e.preventDefault();
//     $('#editEventForm').submit();
// });


        // Handle delete event
        $('.deleteEvent').on('click', function (event) {
            event.preventDefault();
            const eventId = $(this).data('id'); // Get event ID from the button's data-id

            if (confirm('Are you sure you want to delete this event?')) {
                if (eventId) {
                    window.location.href = `events.cfm?del_id=${eventId}`; // Redirect to the delete URL
                } else {
                    alert('Event ID is missing. Unable to delete the event.');
                }
            }
        });


</script>

<cfinclude template="footer.cfm">