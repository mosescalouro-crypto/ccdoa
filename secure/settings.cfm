<cfinclude template="/secure/header.cfm">
<!------>
<cfif !cookie.admin>
    <cflocation url="/secure/">
</cfif>

<div class="row">
    <div class="col-lg-12">
        <h2 class="page-header">Administrative Settings</h2>
    </div>
</div>

<cfquery datasource="CCDOA" name="parking_hnd">
  SELECT * from parking_groups
  WHERE locationid = 'HND'
  order by id
</cfquery>

<cfquery datasource="CCDOA" name="parking_vgt">
  SELECT * from parking_groups
  WHERE locationid = 'VGT'
  order by id
</cfquery>

<div class="row">
    <div class="col-lg-8">
        <div class="panel panel-default">
            <div class="panel-heading">
                <span class="pull-right">
                    <a id="parkingSave" class="btn btn-sm btn-primary" style="margin-top:-6px">Save</a>
                </span>
                <h3 class="panel-title">Parking Group Capacity Defaults</h3>
            </div>
            <div class="panel-body">
              <form class="form" id="parkingForm">
                <div class="row">
                  <div class="col-md-12">
                    <h4>Henderson</h4>
                  </div>
                </div>
                <div class="row">
                  <cfoutput query="parking_hnd">
                    <div class="col-md-3">
                      <div class="form-group">
                          <label for="username" class="control-label">Group #pGroup#</label>
                          <input type="text" class="form-control" name="#pGroup#_cap_hnd" value="#capacity#">
                      </div>
                    </div>
                  </cfoutput>
                </div>
                <div class="row">
                  <div class="col-md-12">
                    <h4>North Las Vegas</h4>
                  </div>
                </div>
                <div class="row">
                  <cfoutput query="parking_vgt">
                    <div class="col-md-3">
                      <div class="form-group">
                          <label for="username" class="control-label">Group #pGroup#</label>
                          <input type="text" class="form-control" name="#pGroup#_cap_vgt" value="#capacity#">
                      </div>
                    </div>
                  </cfoutput>
                </div>
              </form>
            </div>
        </div>
    </div>
</div>

<script type="text/javascript">

$(function() {

    $("#newUserForm").submit(function (event) {
    
        var $form = $(this);

        var formData = $form.serialize();

        formData += "&formName=" + $form.attr('id');

        $.ajax({
          type: "POST",
          url: "ajax_submit.cfm",
          data: formData
        }).error(function (data) {
          console.log(data);
          alert("Error: Email is already associated with a user account.");
        }).success(function () {
          $('#newUserModal #modalContent').html('<h4 class="text-center">Registration link sent.</h4>')
          setTimeout(function(){
             $('#newUserModal').modal('hide');  
           },2000);
          loadUsers();
        });

        event.preventDefault();
    });

    $("#parkingSave").click(function (event) {
    
        var $form = $("#parkingForm");

        var formData = $form.serialize();

        formData += "&formName=" + $form.attr('id');

        $.ajax({
            type: "POST",
            url: "ajax_submit.cfm",
            data: formData
        })
        .done(function () {
            alert("Success. Changes saved.");
        })
        .fail(function (data) {
            console.log(data);
            alert("Error: Changes not saved.");
        });

    });

});

</script>

<cfinclude template="/secure/footer.cfm">