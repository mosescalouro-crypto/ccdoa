<cfif isDefined("url.del")>
	<cfquery datasource="CCDOA" name="delete">
		DELETE from users
		WHERE id = '#url.del#'
	</cfquery>
</cfif>
<cfif isDefined("url.id")>
	<cfquery datasource="CCDOA" name="user">
		SELECT * from users
		WHERE id = '#url.id#'
	</cfquery>

	<form class="form-horizontal" id="userForm">
	<cfoutput query="user">
		<input type="hidden" name="id" value="#id#">
		<div class="form-group">
			<label for="username" class="col-sm-3 control-label">Username</label>
			<div class="col-sm-9">
				<p class="form-control-static"><cfif len(trim(username))>#username#<cfelse><span class="text-danger">Registration Pending</span></cfif></p>
			</div>
		</div>
		<div class="form-group">
			<label for="first_name" class="col-sm-3 control-label">First Name</label>
			<div class="col-sm-9">
				<input type="text" class="form-control" name="first_name" value="#first_name#">
			</div>
		</div>
		<div class="form-group">
			<label for="last_name" class="col-sm-3 control-label">Last Name</label>
			<div class="col-sm-9">
				<input type="text" class="form-control" name="last_name" value="#last_name#">
			</div>
		</div>
		<div class="form-group">
			<label for="username" class="col-sm-3 control-label">Email</label>
			<div class="col-sm-9">
				<input type="email" class="form-control" name="email" placeholder="Email" value="#email#">
			</div>
		</div>
		<div class="form-group">
            <!--- <div class="col-sm-offset-3 col-sm-4">
                <div class="checkbox">
                    <label>
                        <input type="checkbox" name="admin"<cfif admin> checked</cfif>> Admin User
                    </label>
                </div>
            </div> --->
            <div class="col-sm-offset-3 col-sm-9">
                <div class="radio radiobox">
                    <label>
                        <input type="radio" name="role" value="1" <cfif user.admin EQ 1>  checked</cfif>> Admin
                    </label>
                    <label>
                        <input type="radio" name="role" value="2" <cfif user.admin EQ 2>  checked</cfif>> User
                    </label>
                    <label>
                        <input type="radio" name="role" value="3" <cfif user.admin EQ 3>  checked</cfif>> Read Only
                    </label>
                </div>
            </div>
        </div>
	</cfoutput>
	</form>

	<script type="text/javascript">

	$("#deleteUser").click(function(){
		var data = {
	        del: <cfoutput>#url.id#</cfoutput>
	    }

		if (confirm('Are you sure you want to delete this user?')) {
			$.get( "get_user.cfm", data, function( res ) {
				$('#userModal').modal('hide');
		    	loadUsers();
		    });
		}
	});

	</script>
</cfif>