<!DOCTYPE html>
<html lang="en"> 
    
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="icon" type="image/png" href="https://aero.motioninfo.com/favicon.png">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>CCDOA Reservations</title>

    <link href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" rel="stylesheet">

    <!-- Optional theme -->
    <link href="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap-theme.min.css" rel="stylesheet">

    <script src="https://kit.fontawesome.com/d854434d71.js" crossorigin="anonymous"></script>

    <link href="//ajax.googleapis.com/ajax/libs/jqueryui/1.11.2/themes/smoothness/jquery-ui.min.css" rel="stylesheet">

    <!--- <script src="//code.jquery.com/jquery-latest.min.js"></script> --->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="//ajax.googleapis.com/ajax/libs/jqueryui/1.11.1/jquery-ui.min.js"></script>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-validate/1.20.0/jquery.validate.min.js" integrity="sha512-WMEKGZ7L5LWgaPeJtw9MBM4i5w5OSBlSjTjCtSnvFJGSVD26gE5+Td12qN5pvWXhuWaWcVwF++F7aqu9cvqP0A==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-validate/1.20.0/additional-methods.min.js" integrity="sha512-TiQST7x/0aMjgVTcep29gi+q5Lk5gVTUPE9XgN0g96rwtjEjLpod4mlBRKWHeBcvGBAEvJBmfDqh2hfMMmg+5A==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>

    <!-- Latest compiled and minified JavaScript -->
    <script src="//maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
    <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
    <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->

    <style>
        .table {
            font-size: 0.85em;
        }

        .table.normal-size {
            font-size: 1em !important;
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

        .dropdown-menu li.danger {
            background-color: #F2DEDE;
        }

        .dropdown-menu li.warning {
            background-color: #FCF8E3;
        }

        .loading-minHeight {
            min-height: 300px;
        }

        .loading,
        #loading,
        #loading_modal {
            background: url('/img/loading.gif') center no-repeat;
            min-height: 250px;
            margin: 0 auto;
            text-align: center;
        }

        #loading,
        #loading_modal {
            width: 300px;
            display: none;
        }
    </style>

</head>
<body>

<div id="wrapper">

    <cfinclude template="nav.cfm">

    <!-- Page Content -->
    <div id="page-wrapper">
        <div class="container-fluid">