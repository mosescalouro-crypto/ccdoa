<cfinclude template="/header.cfm">
        <div class="container"><br><br><br>
            <div class="row">
                <div class="col-md-4 col-md-offset-4">
                    <div class="login-panel panel panel-default">
                        <div class="panel-heading">
                            <h3 class="panel-title">Please Sign In</h3>
                        </div>
                        <div class="panel-body">
                       <!-- /secure/loggedout.cfm -->
<cfoutput>
  <h2>You’ve been signed out</h2>
  <p><a href="https://launcher.myapps.microsoft.com/api/signin/580ee7af-1177-4462-aac0-68391a7bb129?tenantId=9148e003-3624-435d-99d6-bee88e1ce522">Sign in again</a></p>
</cfoutput>

                        </div>
                    </div>
                </div>
            </div>
        </div>

<cfinclude template="/footer.cfm">

