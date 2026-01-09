    <style>
        .table {
            font-size: 0.85em;
        }

        .ui-widget {
            font-size: 0.9em;
            z-index: 99999;
        }

        .panel-heading .btn-sm {
            margin-top: -6px;
        }

        .button-checkbox i {
            font-size: 1.2em;
        }
        #page-wrapper {
            padding-top: 45px;
        }
        i.fa {
            font-size: 1.15em;
        }

        .navbar-brand {
            padding: 0px
        }

        .navbar-brand img {
            height: 50px
        }
    </style>

<div id="wrapper">

    <nav class="navbar navbar-default navbar-fixed-top">
        <div class="container-fluid" style="margin-top: 10px;margin-bottom: 10px;">
          <div class="navbar-header">
            <button type="button" class="navbar-toggle collapsed" data-toggle="collapse" data-target="#navbar" aria-expanded="false" aria-controls="navbar">
              <span class="sr-only">Toggle navigation</span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
              <span class="icon-bar"></span>
            </button>
            <a class="navbar-brand" href="/" alt="Logo">
              <!--- <img src="/img/ccdoa_logo.png"> --->
              <img src="/img/logo-vgt-hnd-1070wx200h.png">
            </a>
          </div>
          <div class="collapse navbar-collapse" id="navbar">
            <ul class="nav navbar-nav">
                <li<cfif FindNoCase('index.cfm',cgi.script_name)> class="active"</cfif>><a href="/secure/"><i class="fa-solid fa-calendar-check fa-fw"></i> Reservations</a></li>
                <li class="dropdown<cfif FindNoCase('standby.cfm',cgi.script_name)> active</cfif>">
		          <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"><i class="fa-solid fa-hourglass-half fa-fw"></i> Standby <span class="caret"></span></a>
		          <ul class="dropdown-menu">
	                <li><a href="/secure/standby.cfm">HND Standby</a></li>
                	<li><a href="/secure/standby.cfm?ap=VGT">VGT Standby</a></li>
		          </ul>
		        </li>
                <li class="dropdown<cfif FindNoCase('parking.cfm',cgi.script_name)> active</cfif>">
		          <a href="#" class="dropdown-toggle" data-toggle="dropdown" role="button" aria-haspopup="true" aria-expanded="false"><i class="fa fa-square-parking fa-fw"></i> Parking <span class="caret"></span></a>
		          <ul class="dropdown-menu">
	                <li><a href="/secure/parking.cfm">HND Parking</a></li>
                	<li><a href="/secure/parking.cfm?ap=VGT">VGT Parking</a></li>
		          </ul>
		        </li>
                <li<cfif FindNoCase('events.cfm',cgi.script_name)> class="active"</cfif>><a href="/secure/events.cfm"><i class="fa fa-calendar-days fa-fw"></i> Events</a></li>
                <li<cfif FindNoCase('aircraft.cfm',cgi.script_name)> class="active"</cfif>><a href="/secure/aircraft.cfm"><i class="fa fa-plane fa-fw"></i> Aircraft</a></li>
                <!--- <cfdump var="#cookie#" abort="false"/> --->
			<cfif StructKeyExists(cookie, "admin") AND cookie.admin EQ 1>

                <li<cfif FindNoCase('users.cfm',cgi.script_name)> class="active"</cfif>><a href="/secure/users.cfm"><i class="fa fa-users fa-fw"></i> Users</a></li>
			    <li<cfif FindNoCase('settings.cfm',cgi.script_name)> class="active"</cfif>><a href="/secure/settings.cfm" target="_parent"><i class="fa-solid fa-gear fa-fw"></i> Settings</a></li>
            	</cfif>
			</ul>

            <!--- Not sure why this logout function won't work --->
            <ul class="nav navbar-nav navbar-right">
                <li><a href="/secure/?logout" onclick="performLogout()" title="Logout" target="_parent"><i class="fa fa-sign-out fa-fw"></i></a></li>
            </ul>
          </div>
        </div>
    </nav>
    <script>
    function performLogout() {
        // Clear localStorage
        localStorage.removeItem("reservationSearchFilters");
        localStorage.removeItem("reservationDataTableSearch");
    }
</script>