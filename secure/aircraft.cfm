<cfif isDefined("url.del_id")>
  <cfquery datasource="CCDOA" name="delete">
    DELETE FROM aircraft
    where id = '#url.del_id#'
  </cfquery>
  <cflocation url="aircraft.cfm">
  <cfabort>
</cfif>

<cfif isDefined("form.make")>
  <cfif isDefined("form.res_id")>
    <cfquery datasource="CCDOA" name="update">
      UPDATE aircraft
      SET make = '#make#',
          model = '#model#',
          <cfif len(trim(length)) and len(trim(width))>
            length = '#length#',
            width = '#width#',
          <cfelse>
            length = NULL,
            width = NULL,
          </cfif>
          sqft = '#sqft#',
          notes = '#notes#',
          <cfif isDefined("form.heli")>
            heli = 1,
          <cfelse>
            heli = 0,
          </cfif>
          updated = getdate()
      WHERE id = '#form.res_id#'
    </cfquery>
    <cflocation url="aircraft.cfm">
    <cfabort>
  <cfelse>
    <cfquery datasource="CCDOA" name="insert">
      INSERT INTO aircraft (make,model,length,width,sqft,notes,heli)
      VALUES (
          '#make#',
          '#model#',
          <cfif len(trim(length)) and len(trim(width))>
            '#length#',
            '#width#',
          <cfelse>
            NULL,
            NULL,
          </cfif>
          '#sqft#',
          '#notes#',
          <cfif isDefined("form.heli")>
            1
          <cfelse>
            0
          </cfif>
        )
    </cfquery>
    <cflocation url="aircraft.cfm">
    <cfabort>
  </cfif>  
</cfif>

<cfinclude template="header.cfm">

<style>
  .pagination,
  .dataTables_length {
    margin: 5px 0;
  }

  .pagination {
    float: right;
  }
</style>

<cfquery datasource="CCDOA" name="results">
    SELECT *,
      (select count(id) from reservations where ACType = aircraft.id) as resCount,
      CASE 
          WHEN sqft < 1250 THEN '1S'
          WHEN sqft BETWEEN 1250 AND 1999 THEN '1M'
          WHEN sqft BETWEEN 2000 AND 3499 THEN '2'
          ELSE '3'
      END as parking
    FROM aircraft
    order by make,model
</cfquery>

    <div class="row">
        <div class="col-lg-12">
            <h2 class="page-header">
                <cfif StructKeyExists(cookie, "admin") AND cookie.admin NEQ 3>
                    <button class="btn btn-success pull-right" data-toggle="modal" data-target="#newACModal"><i class="fa-solid fa-plus"></i> New Aircraft Type</button>
                </cfif>
              Aircraft Management
            </h2>
        </div>
    </div>

    <div class="row">
        <div class="col-lg-12" id="searchResult">
          <table class="table table-striped table-hover table-condensed dataTable">
            <thead>
                <tr>
                  <th>#</th>
                  <th>Aircraft Make</th>
                  <th>Aircraft Model</th>
                  <th>Heli?</th>
                  <th>Parking Group</th>
                  <th>Sq Ft</th>
                  <th>Len x Wdth</th>
                  <th>Reservation Count</th>
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
                <td>#make#</td>
                <td>#model#</td>
                <td><cfif heli><i class="fa-solid fa-helicopter text-success"></i></cfif></td>
                <td>#parking#</td>
                <td>#sqft#</td>
                <cfif length gt 0 AND width gt 0>
                  <td>#length# x #width#</td>
                <cfelse>
                  <td>Unknown</td>
                </cfif>
                <td>#resCount#</td>
                <td>#datetimeformat(updated)#</td>
                <cfif StructKeyExists(cookie, "admin") AND cookie.admin NEQ 3>
                    <td><button class="btn btn-xs btn-primary" data-toggle="modal" data-target="##detailsModal" data-id="#id#">
                        <i class="fa fa-gear" aria-hidden="true"></i></button>
                    </td>
                </cfif>
            </cfoutput>
            </tbody>
          </table>
        </div>
    </div>

    <div class="modal fade" id="newACModal" tabindex="-1" role="dialog">
      <div class="modal-dialog" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
            <h4 class="modal-title">New Aircraft Type</h4>
          </div>
          <div class="modal-body" id="modalContent">
            <form class="form ac_form" id="newACForm" method="POST">
                <div class="form-group">
                  <label for="make">Aircraft Make</label>
                  <input type="text" class="form-control" name="make" required>
                </div>
                <div class="form-group">
                  <label for="model">Aircraft Model</label>
                  <input type="text" class="form-control" name="model" required>
                </div>
                <div class="row">
                  <div class="col-sm-6">
                      <div class="form-group">
                        <label for="length">Length <small>(ft)</small></label>
                        <input type="text" class="form-control" name="length" placeholder="Optional">
                      </div>
                      <div class="form-group">
                        <label for="width">Width <small>(ft)</small></label>
                        <input type="text" class="form-control" name="width" placeholder="Optional">
                      </div>
                  </div>
                  <div class="col-sm-6">
                    <div class="form-group">
                      <label for="heli">Helicopter?</label>
                      <div class="checkbox">
                        <label>
                          <input type="checkbox" name="heli"> Is Helicopter
                        </label>
                      </div>
                    </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-sm-6">
                      <div class="form-group">
                        <label for="sqft">Square Footage</label>
                        <input type="text" class="form-control" name="sqft">
                      </div>
                  </div>
                  <div class="col-sm-6">
                      <div class="form-group">
                        <label for="parking">Parking Group</label>
                        <input type="text" class="form-control" name="parking" placeholder="Calculated Automatically" readonly>
                      </div>
                  </div>
                </div>
                <div class="form-group">
                  <label for="notes">Internal Admin Notes</label>
                  <textarea name="notes" class="form-control" rows="3"></textarea>
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
            <h4 class="modal-title">Aircraft Details</h4>
          </div>
          <div class="modal-body" id="modalContent">
          </div>
          <div class="modal-footer">
            <a id="deleteAC" class="btn btn-danger pull-left"><i class="glyphicon glyphicon-trash"></i> Delete Aircraft</a>
            <button type="submit" class="btn btn-primary editSubmit"><i class="glyphicon glyphicon-floppy-disk"></i> Save Changes</button>
          </div>
        </div>
      </div>
    </div>

<!-- DataTables JavaScript -->
<script src="/js/dataTables/jquery.dataTables.min.js"></script>
<script src="/js/dataTables/dataTables.bootstrap.min.js"></script>

<script type="text/javascript">

$(function() {

   $('.dataTable').DataTable({
      responsive: true,
      "iDisplayLength": 50,
      "aaSorting": [],
      "searching": true,
      dom: "<'row'<'col-sm-4'l><'col-sm-4'f><'col-sm-4'p>>" +
              "<'row'<'col-sm-12'tr>>" +
          "<'row'<'col-sm-5'i><'col-sm-7'p>>",
    });

    $('#detailsModal').on('show.bs.modal', function (event) {
        var link = $(event.relatedTarget) // Button that triggered the modal
        var modal = $(this);

        var data = { 
            id: link.data('id')
        }

        $.get( "get_ac.cfm", data, function( res ) {
            modal.find('.modal-body').html( res );
        });
    });

});

$("body").on("change", ".ac_form :input", function() {
    
  theForm = $(this).closest("form");

  // Fields
  length = theForm.find('input[name="length"]');
  width = theForm.find('input[name="width"]');
  sqft = theForm.find('input[name="sqft"]');
  parking = theForm.find('input[name="parking"]');

  if ( parseFloat(length.val()) > 0 && parseFloat(width.val()) > 0 ) {
    sqft_calc = Math.ceil(parseFloat(length.val()) * parseFloat(width.val()));
    sqft.val(sqft_calc);
  }

  if ( parseFloat(sqft.val()) > 0 ) {
    if ( parseFloat(sqft.val()) < 1250 ) {
      parking.val('1S');
    } else if ( parseFloat(sqft.val()) > 1249 && parseFloat(sqft.val()) < 2000 ) {
      parking.val('1M');
    } else if ( parseFloat(sqft.val()) > 1999 && parseFloat(sqft.val()) < 3500 ) {
      parking.val('2');
    } else {
      parking.val('3');
    }
  } else {
    parking.val('');
  }

});

$(document).on('click', '.editSubmit', function(e) {
  e.preventDefault();

  const form = $('#detailsModal').find('#editACForm'); // find the form inside the modal
  const make = form.find('input[name="make"]').val()?.trim() || '';
  const model = form.find('input[name="model"]').val()?.trim() || '';

  console.log('Make:', make, 'Model:', model);

  if (make === '') {
    alert('Please fill the Aircraft Make input.');
    return false;
  }

  if (model === '') {
    alert('Please fill the Aircraft Model input.');
    return false;
  }

  form.submit(); // submit the dynamically loaded form
});



$('#deleteAC').on('click', function() {
  if ( confirm("Are you sure you want to delete this aircraft type?") == true ) {
    window.location.href = "aircraft.cfm?del_id=" + $("#res_id").val();
    return false;
  }
});

</script>

<cfinclude template="footer.cfm">