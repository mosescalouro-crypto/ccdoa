<cfinclude template="/header.cfm">

    <style>
    @import url(//fonts.googleapis.com/css?family=Roboto);

	/****** LOGIN MODAL ******/
	.loginmodal-container {
	  padding: 30px;
	  max-width: 350px;
	  width: 100% !important;
	  background-color: #F7F7F7;
	  margin: 0 auto;
	  border-radius: 2px;
	  box-shadow: 0px 2px 2px rgba(0, 0, 0, 0.3);
	  overflow: hidden;
	  font-family: roboto;
	}

	.loginmodal-container h1 {
	  text-align: center;
	  font-size: 1.8em;
	  font-family: roboto;
	}

	.loginmodal-container h4 {
	  text-align: center;
	  font-family: roboto;
	}

	.loginmodal-container input[type=submit] {
	  width: 100%;
	  display: block;
	  margin-bottom: 10px;
	  position: relative;
	}

	.loginmodal-container input[type=text], input[type=password] {
	  height: 44px;
	  font-size: 16px;
	  width: 100%;
	  margin-bottom: 10px;
	  -webkit-appearance: none;
	  background: #fff;
	  border: 1px solid #d9d9d9;
	  border-top: 1px solid #c0c0c0;
	  /* border-radius: 2px; */
	  padding: 0 8px;
	  box-sizing: border-box;
	  -moz-box-sizing: border-box;
	}

	.loginmodal-container input[type=text]:hover, input[type=password]:hover {
	  border: 1px solid #b9b9b9;
	  border-top: 1px solid #a0a0a0;
	  -moz-box-shadow: inset 0 1px 2px rgba(0,0,0,0.1);
	  -webkit-box-shadow: inset 0 1px 2px rgba(0,0,0,0.1);
	  box-shadow: inset 0 1px 2px rgba(0,0,0,0.1);
	}

	.loginmodal {
	  text-align: center;
	  font-size: 14px;
	  font-family: 'Arial', sans-serif;
	  font-weight: 700;
	  height: 36px;
	  padding: 0 8px;
	/* border-radius: 3px; */
	/* -webkit-user-select: none;
	  user-select: none; */
	}

	.loginmodal-submit {
	  /* border: 1px solid #3079ed; */
	  border: 0px;
	  color: #fff;
	  text-shadow: 0 1px rgba(0,0,0,0.1); 
	  background-color: #4d90fe;
	  padding: 17px 0px;
	  font-family: roboto;
	  font-size: 14px;
	  /* background-image: -webkit-gradient(linear, 0 0, 0 100%,   from(#4d90fe), to(#4787ed)); */
	}

	.loginmodal-submit:hover {
	  /* border: 1px solid #2f5bb7; */
	  border: 0px;
	  text-shadow: 0 1px rgba(0,0,0,0.3);
	  background-color: #357ae8;
	  /* background-image: -webkit-gradient(linear, 0 0, 0 100%,   from(#4d90fe), to(#357ae8)); */
	}

	.loginmodal-container a {
	  text-decoration: none;
	  color: #666;
	  font-weight: 400;
	  text-align: center;
	  display: inline-block;
	  opacity: 0.6;
	  transition: opacity ease 0.5s;
	} 

	.login-help{
	  font-size: 12px;
	}
	</style>

            <div class="row">

<cfif !IsDefined("url.e") AND !IsDefined("form.submit") AND !IsDefined("url.thanks")>
	<h2>Error</h2>
<cfelseif IsDefined("form.e")>

	<cfset pass = form.pass>

	<!--- SHA1 (Apache) Hash --->
	<cfset hash = "{SHA}" & ToBase64(BinaryDecode(Hash(pass, "SHA1"), "Hex"))>

	<cfquery datasource="CCDOA" name="user_insert">
		UPDATE users
		SET username = '#form.user#',
			first_name = '#form.first_name#',
			last_name = '#form.last_name#',
			hash = '#hash#',
			updated = getdate()
		WHERE email = '#form.e#'
	</cfquery>

	<cflocation url="register.cfm?thanks">

<cfelseif IsDefined("url.thanks")>
	<div id="login-modal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	  <div class="modal-dialog">
			<div class="loginmodal-container">
				<h1>Thank You</h1>
				<hr>
				<div style="text-align:center;">
				<a href="http://ccdoa.motioninfo.com/secure/" style="color:white; opacity:1 !important" class="btn btn-lg btn-primary">Proceed to Login &#10140;</a>
				</div>
			</div>
		</div>
	  </div>
	  
<cfelse>

	<cfquery datasource="CCDOA" name="existing">
		SELECT * FROM users
		WHERE email = <cfqueryparam value='#url.e#' CFSQLType='CF_SQL_VARCHAR'>
	</cfquery>

	<br>

	<div id="login-modal" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
	  <div class="modal-dialog">
			<div class="loginmodal-container">
				<cfif !existing.recordcount>
					<h1>Error. Contact Support</h1>
					<cfabort>
				<cfelseif len(existing.username)>
					<h1>Error: Account already created.</h1>
					<hr>
					<div style="text-align:center;">
					<a href="http://ccdoa.motioninfo.com/secure/" style="color:white; opacity:1 !important" class="btn btn-lg btn-primary">Proceed to Login &#10140;</a>
					</div>
				<cfelse>
					<h1>Create Your Account</h1><br>
			  		<cfoutput>
			  		<form method="POST" role="form" data-toggle="validator">
						<div class="form-group">
							<input type="text" name="first_name" id="first_name" placeholder="First Name" class="form-control" required>
							<div class="help-block with-errors" style="font-size:0.8em"></div>
						</div>
						<div class="form-group">
							<input type="text" name="last_name" id="last_name" placeholder="Last Name" class="form-control" required>
							<div class="help-block with-errors" style="font-size:0.8em"></div>
						</div>
						<hr>
						<div class="form-group">
							<input type="text" name="user" class="form-control" placeholder="Username" data-remote="username_check.cfm" data-error="Username is not available" autofocus required>
							<div class="help-block with-errors" style="font-size:0.8em"></div>
						</div>
						<hr>
						<div class="form-group">
							<input type="password" name="pass" id="pass" placeholder="Password" data-minlength="6" class="form-control" data-error="Password must be at least 6 characters" required>
							<div class="help-block with-errors" style="font-size:0.8em"></div>
						</div>
						<div class="form-group">
							<input type="password" name="pass_conf" placeholder="Confirm password" class="form-control" data-match="##pass" data-match-error="Passwords don't match" required>
							<div class="help-block with-errors" style="font-size:0.8em"></div>
						</div>
						<br>
						<input type="hidden" name="e" value="#url.e#">
						<input type="submit" name="submit" class="login loginmodal-submit" value="Submit">
				  	</form>
				  	</cfoutput>	
				</cfif>
			</div>
		</div>
	  </div>


	<div class="row">
                <div class="col-md-10 col-md-offset-1">
                    <div class="row" style="border-top: 1px solid #ddd; padding-top: 10px; margin-top: 10%">
                        <div class="col-md-4 text-center">
                            <p><i class="fa fa-question-circle"></i> CCDOA Support:</p>
                        </div>
                        <div class="col-md-4 text-center">
                            <p><i class="fa fa-phone"></i> +1 555-123-4567</p>
                        </div>
                        <div class="col-md-4 text-center">
                            <p><i class="fa fa-envelope"></i> <a href="mailto:support@ccdoa.com">support@ccdoa.com</a></p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Latest compiled and minified JavaScript -->
        <script src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
    <script src="/js/validator.js"></script>


    </cfif>

<cfinclude template="/footer.cfm">