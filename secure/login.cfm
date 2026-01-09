
<cfinclude template="/header.cfm">
        <div class="container"><br><br><br>
            <div class="row">
                <div class="col-md-4 col-md-offset-4">
                    <div class="login-panel panel panel-default">
                        <div class="panel-heading">
                            <h3 class="panel-title">Please Sign In</h3>
                        </div>
                        <div class="panel-body">
                        <cfoutput>
                            <form role="form" action="#CGI.script_name#?#CGI.query_string#" method="Post">
                                <fieldset>
                                    <div class="form-group">
                                        <input class="form-control" placeholder="Username" name="j_username" type="text" autofocus>
                                    </div>
                                    <div class="form-group">
                                        <input class="form-control" placeholder="Password" name="j_password" type="password" value="">
                                    </div>
                                    <!-- Change this to a button or input when using this as a form -->
                                    <input type="submit" class="btn btn-lg btn-success btn-block" value="Log In">
                                    <a type="submit" class="btn btn-lg btn-success btn-block" href="https://launcher.myapps.microsoft.com/api/signin/580ee7af-1177-4462-aac0-68391a7bb129?tenantId=9148e003-3624-435d-99d6-bee88e1ce522">Login With SSO</a>
                                </fieldset>
                            </form>
                        </cfoutput>
                        </div>
                    </div>
                </div>
            </div>
        </div>

<cfinclude template="/footer.cfm">