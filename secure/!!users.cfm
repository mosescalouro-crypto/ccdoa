<cfinclude template="/secure/header.cfm">
<!--------------------------->
<cfif !cookie.admin>
    <cflocation url="/secure/">
</cfif>

<div class="row">
    <div class="col-lg-12">
        <h2 class="page-header">User Administration</h2>
    </div>
</div>

<div class="row">
    <div class="col-lg-8">
        <div class="panel panel-default">
            <div class="panel-heading">
                <span class="pull-right">
                    <a class="btn btn-sm btn-primary" style="margin-top:-6px" data-toggle="modal" data-target="#newUserModal">New User</a>
                </span>
                <h3 class="panel-title">User Accounts</h3>
            </div>
            <table class="table table-striped table-condensed">
                <thead>
                    <tr>
                        <th>Name</td>
                        <th>Username</th>
                        <th>Email</th>
                        <th>Last Login</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody id="usersTable"></tbody>
            </table>
        </div>
    </div>
</div>

<div class="modal fade" id="newUserModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title" id="myModalLabel">New User</h4>
      </div>
      <div class="modal-body" id="modalContent">
        <form class="form-horizontal" id="newUserForm">
            <div class="form-group">
                <label for="username" class="col-sm-3 control-label">Email</label>
                <div class="col-sm-9">
                    <input type="email" class="form-control" name="email" placeholder="Registration Link Sent Here">
                </div>
            </div>
            <div class="form-group">
              <label for="first_name" class="col-sm-3 control-label">First Name</label>
              <div class="col-sm-9">
                <input type="text" class="form-control" name="first_name">
              </div>
            </div>
            <div class="form-group">
              <label for="last_name" class="col-sm-3 control-label">Last Name</label>
              <div class="col-sm-9">
                <input type="text" class="form-control" name="last_name">
              </div>
            </div>
            <div class="form-group">
                <div class="col-sm-offset-3 col-sm-4">
                    <div class="checkbox">
                        <label>
                            <input type="checkbox" name="admin"> Admin User
                        </label>
                    </div>
                </div>
            </div>
            <button type="submit" class="btn btn-primary pull-right">Send Registration Link</button>
            <div class="clearfix"></div>
        </form>
      </div>
    </div>
  </div>
</div>

<div class="modal fade" id="userModal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title" id="myModalLabel">User Details</h4>
      </div>
      <div class="modal-body" id="modalContent">
      </div>
      <div class="modal-footer">
        <a id="deleteUser" class="btn btn-danger pull-left"><i class="glyphicon glyphicon-trash"></i> Delete User</a>
        <button id="updateUser" type="submit" class="btn btn-primary"><i class="glyphicon glyphicon-floppy-disk"></i> Save Changes</button>
      </div>
    </div>
  </div>
</div>

<script type="text/javascript">

$(function() {
    loadUsers();

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

    $('#userModal').on('show.bs.modal', function (event) {
        var link = $(event.relatedTarget) // Button that triggered the modal
        var modal = $(this);

        var data = { 
            id: link.data('userid')
        }

        $.get( "get_user.cfm", data, function( res ) {
            modal.find('.modal-body').html( res );
        });
    });

    $("#updateUser").click(function (event) {
    
        var $form = $("#userForm");

        var formData = $form.serialize();

        formData += "&formName=" + $form.attr('id');

        $.ajax({
            type: "POST",
            url: "ajax_submit.cfm",
            data: formData
        }).error(function (data) {
            console.log(data);
            alert("Error: Changes not saved.");
        }).success(function () {
            $('#userModal').modal('hide');
            loadUsers();
        });
    });
});

function loadUsers() {

    $("#usersTable").addClass('loading');
    $("#usersTable").html('');

    $.ajax({
      url: "get_users.cfm",
      context: document.body,
      success: function(responseText) {
        $("#usersTable").removeClass('loading');
        $("#usersTable").html(responseText);
      }
    });
}

$("#userRefresh").click(function(){
    loadUsers();
});

</script>

<cfinclude template="/secure/footer.cfm">