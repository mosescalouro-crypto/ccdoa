<cfinclude template="/secure/header.cfm">

<cfif NOT (StructKeyExists(cookie, "admin") AND cookie.admin EQ "true")>
    <cflocation url="/secure/">
</cfif>

<div class="row">
    <div class="col-lg-12">
        <h2 class="page-header">User Administration</h2>
    </div>
</div>
<style>
    .radiobox label {
        padding-right: 25px;
    }
</style>

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
                        <th>Name</th>
                        <th>Username</th>
                        <th>Email</th>
						<th>Admin</th>
                        <th>Last Login</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="usersTable">
                    <tr>
                        <td colspan="5" class="text-center">Loading users...</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
</div>

<div class="modal fade" id="newUserModal" tabindex="-1" role="dialog" aria-labelledby="newUserModalLabel">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title" id="newUserModalLabel">New User</h4>
      </div>
      <div class="modal-body">
        <form class="form-horizontal" id="newUserForm">
            <div class="form-group">
                <label for="email" class="col-sm-3 control-label">Email</label>
                <div class="col-sm-9">
                    <input type="email" class="form-control" name="email" placeholder="Registration Link Sent Here" required>
                </div>
            </div>
            <div class="form-group">
              <label for="first_name" class="col-sm-3 control-label">First Name</label>
              <div class="col-sm-9">
                <input type="text" class="form-control" name="first_name" required>
              </div>
            </div>
            <div class="form-group">
              <label for="last_name" class="col-sm-3 control-label">Last Name</label>
              <div class="col-sm-9">
                <input type="text" class="form-control" name="last_name" required>
              </div>
            </div>
            <div class="form-group">
                <!--- <div class="col-sm-offset-3 col-sm-4">
                    <div class="checkbox">
                        <label>
                            <input type="hidden" name="admin" value="0">
                            <input type="checkbox" name="admin" value="1"> Admin User
                        </label>
                    </div>
                </div> --->
                <div class="col-sm-offset-3 col-sm-9">
                    <div class="radio radiobox">
                        <label>
                            <input type="radio" name="role" value="1" checked> Admin
                        </label>
                        <label>
                            <input type="radio" name="role" value="2"> User
                        </label>
                        <label>
                            <input type="radio" name="role" value="3"> Read Only
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

<div class="modal fade" id="userModal" tabindex="-1" role="dialog" aria-labelledby="userModalLabel">
  <div class="modal-dialog" role="document">
    <div class="modal-content">
      <div class="modal-header">
        <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
        <h4 class="modal-title" id="userModalLabel">User Details</h4>
      </div>
      <div class="modal-body">
        <form id="userForm">
            <!-- Form fields will be dynamically loaded here -->
        </form>
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
        event.preventDefault();
        var formData = $(this).serialize();
        formData += "&formName=" + $(this).attr('id');

        $.ajax({
            type: "POST",
            url: "ajax_submit.cfm",
            data: formData
        }).fail(function (data) {
            console.error(data);
            alert("Error: " + (data.responseText || "Unknown error occurred."));
        }).done(function () {
            // Hide the form and show success message
            $('#newUserForm').hide();
            $('#newUserModal .modal-body').append('<div id="successMsg"><h4 class="text-center">Registration link sent.</h4></div>');

            // After 2s hide modal, reset form, and restore
            setTimeout(function() {
                $('#newUserModal').modal('hide');
            }, 2000);
            loadUsers();
        });
    });

    // When modal is hidden, reset form and UI
    $('#newUserModal').on('hidden.bs.modal', function () {
        $('#successMsg').remove();          // remove success message
        $('#newUserForm')[0].reset();       // reset form fields
        $('#newUserForm').show();           // show the form again
        // make sure "Admin" stays default
        $('#newUserForm input[name="role"][value="1"]').prop('checked', true);
    });


    $('#userModal').on('show.bs.modal', function (event) {
        var link = $(event.relatedTarget);
        var userId = link.data('userid');

        $.get("get_user.cfm", { id: userId }, function(res) {
            $('#userModal .modal-body').html(res);
        });
    });

    $("#updateUser").click(function (event) {
        event.preventDefault();
        var formData = $("#userForm").serialize();
        formData += "&formName=userForm";

        $.ajax({
            type: "POST",
            url: "ajax_submit.cfm",
            data: formData
        }).fail(function (data) {
            console.error(data);
            alert("Error: Changes not saved.");
        }).done(function () {
            $('#userModal').modal('hide');
            loadUsers();
        });
    });
});

function loadUsers() {
    var $table = $("#usersTable");
    $table.html('<tr><td colspan="5" class="text-center">Loading users...</td></tr>');

    $.ajax({
        url: "get_users.cfm",
        success: function(response) {
            $table.html(response);
        },
        error: function() {
            $table.html('<tr><td colspan="5" class="text-center text-danger">Failed to load users.</td></tr>');
        }
    });
}
</script>

<cfinclude template="/secure/footer.cfm">


