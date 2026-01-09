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

<cfquery datasource="CCDOA" name="cancelled">
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
  JOIN aircraft a on r.ACType = a.id OR R.ACTYPE=A.LEGACYID
  WHERE status = 1
  AND deleted = 1
  AND confirmation = 1
  AND (released = 0 or released is null)
  AND r.locationid = '#iata#'
  AND arrival > dateadd(hour, -6, @currentLocal)
  order by r.id desc
</cfquery>

<div class="row">
    <div class="col-lg-12">
        <h2 class="page-header"><cfoutput>#iata#</cfoutput> Wait List Clearance</h2>
    </div>
</div>

  <div class="row">
    <div class="col-lg-12">
        <h3 class="page-header">Cancelled Reservations Pending Release</h3>
    
    <cfif cancelled.recordcount>
       <cfspreadsheet action="write" filename="#ExpandPath('export/')#CCDOA_standby_#cookie.user_id#.xls" query="cancelled" overwrite="true">
        <cfif StructKeyExists(cookie, "admin") AND cookie.admin NEQ 3>
            <a href="export/<cfoutput>CCDOA_standby_#cookie.user_id#.xls</cfoutput>" target="_blank" class="btn btn-sm btn-success pull-right" title="Export Data to Excel"><i class="fa fa-file-excel-o" aria-hidden="true"></i> Excel Export</a>
        </cfif>
    </cfif>

      <table class="table table-striped table-hover table-condensed dataTable">
        <thead>
            <tr>
              <th>ID</th>
              <th>Conf #</th>
              <th>Tail No</th>
              <th>Name</th>
              <th>Arrival Date</th>
              <th>Departure Date</th>
              <th>Stay Duration</th>
              <th>Aircraft Type</th>
              <th>Parking</th>
              <th>Cost Est.</th>
              <!---<th></th>--->
            </tr>
        </thead>
        <tbody>
        <cfoutput query="cancelled">
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
            <cfif StructKeyExists(cookie, "admin") AND cookie.admin NEQ 3>
                <td><button class="btn btn-xs btn-primary" data-toggle="modal" data-target="##detailsModal" data-id="#res_id#"><i class="fa fa-search" aria-hidden="true"></i></button></td>
            </cfif>
        </cfoutput>
        </tbody>
      </table>
  </div>

  <div class="modal fade" id="detailsModal" tabindex="-1" role="dialog">
      <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
            <h4 class="modal-title">Waitlist Reservations</h4>
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

      $.get( "get_standby.cfm", data, function( res ) {
          modal.find('.modal-body').html( res );

          $("#publicRelease").click(function(){
            if (confirm('Are you sure you want to release this slot to the public for booking?'))
            {
              var button = $(this); // Button that triggered the modal
              var data = { 
                  cid: button.data('cid')
              }
              $.get( "get_standby.cfm?publicRelease", data, function( res ) {
                $('#detailsModal .modal-body').html('<h4 class="text-center">Reservation slot has been released to the public.</h4>')
                setTimeout(function(){
                    $('#detailsModal').modal('hide');
                    $('#detailsModal .modal-body').html('');
                    location.reload();
                },1500);
              });
            }
          });

          $(".replaceConfirm").click(function(){
            var button = $(this); // Button that triggered the modal
            var data = { 
                id: button.data('id'),
                cid: button.data('cid')
            }
            $.get( "get_standby.cfm?replaceConfirm", data, function( res ) {
                modal.find('.modal-body').html( res );

                $("#replaceConfirm").validate({
                  //debug: true,
                  ignore: [],
                  rules: {
                    comment: "required"
                  },
                  messages: {
                    comment: "Comment is required."
                  }
                });

                $("#replaceConfirm").submit(function (event) {
              
                  event.preventDefault();

                  var $form = $(this);

                  var formData = $form.serialize();

                  formData += "&formName=" + $form.attr('id');

                  $.ajax({
                    type: "POST",
                    url: "ajax_submit.cfm",
                    data: formData
                  }).error(function (data) {
                    console.log(data);
                    $('#detailsModal .modal-body').html('<h4 class="text-center text-danger">Error. Please contact Support.</h4>')
                  }).success(function () {
                    $('#detailsModal .modal-body').html('<h4 class="text-center">Reservation successfully confirmed.</h4>')
                    setTimeout(function(){
                        $('#detailsModal').modal('hide');
                        $('#detailsModal .modal-body').html('');
                        location.reload();
                    },1500);
                  });
                  
                });
            });
          });
      });
  });

});

</script>

<cfinclude template="/secure/footer.cfm">