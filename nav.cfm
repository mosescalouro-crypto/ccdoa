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
        
        .swal2-popup{
            width: 28% !important;
        }
        .swal2-actions{
            margin-bottom: 15px;
        }
        .swal2-confirm {
            background-color: #265a88 !important; 
            color: white !important;
            border: none !important;
            padding: 10px 40px !important;
            font-size: 16px !important;
        }
        .custom-confirm-btn {
            background-color: #7d2b2b !important; 
            color: white !important;
            font-weight: bold;
            padding: 10px 40px;
            border-radius: 5px;
            border: none;
        }

        .custom-cancel-btn {
            background-color: transparent !important;
            color: #7d2b2b !important;
            font-weight: bold;
            padding: 10px 40px;
            border-radius: 5px;
            border: 2px solid #265a88;
            margin-left: 20px;
        }

        .custom-cancel-btn:hover {
            background-color: #265a88 !important;
            color: white !important;
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
                <!--- <cfif isDefined('url.ap') AND isDefined('url.iframe') AND url.iframe EQ 'yes'>
                    <cfif url.ap EQ 'VGT'>
                        <a class="navbar-brand" style="padding-left: 14px;" href="/?ap=VGT&iframe=yes" alt="Logo">
                            <img src="/img/VGT.jpg">
                        </a>
                    <cfelse>
                        <a class="navbar-brand" style="padding-left: 10px;" href="/?ap=HND&iframe=yes" alt="Logo">
                            <img src="/img/HND.jpg">
                        </a>
                    </cfif>
                <cfelse> --->
                    <a class="navbar-brand" href="/" alt="Logo">
                        <img src="/img/logo-vgt-hnd-1070wx200h.png">
                    </a>
                <!--- </cfif> --->
            </div>
            <div class="collapse navbar-collapse" id="navbar">
                <ul class="nav navbar-nav">
                    <!---<li><a href="/?ap=LAS" target="_parent"><i class="fa-solid fa-calendar-check fa-fw"></i> LAS Reservations</a></li>--->
                    <!--- <cfif isDefined('url.ap') AND isDefined('url.iframe') AND url.iframe EQ 'yes'>
                        <cfif url.ap EQ 'VGT'>
                            <li><a href="/?ap=VGT&iframe=yes" target="_parent"><i class="fa-solid fa-calendar-check fa-fw"></i> VGT Reservations</a></li>
                        <cfelse>
                            <li><a href="/?ap=HND&iframe=yes" target="_parent"><i class="fa-solid fa-calendar-check fa-fw"></i> HND Reservations</a></li>
                        </cfif>
                    <cfelse> --->
                        <li><a href="/?ap=HND" target="_parent"><i class="fa-solid fa-calendar-check fa-fw"></i> HND Reservations</a></li>
                        <li><a href="/?ap=VGT" target="_parent"><i class="fa-solid fa-calendar-check fa-fw"></i> VGT Reservations</a></li>
                    <!--- </cfif> --->
                </ul>
            </div>
        </div>
    </nav>