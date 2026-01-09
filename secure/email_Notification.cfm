
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns:v="urn:schemas-microsoft-com:vml">

    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
        <meta name="viewport" content="width=device-width; initial-scale=1.0; maximum-scale=1.0;" />
        <!--[if !mso]--><!-- -->
        <link href='https://fonts.googleapis.com/css?family=Work+Sans:300,400,500,600,700' rel="stylesheet">
        <link href='https://fonts.googleapis.com/css?family=Quicksand:300,400,700' rel="stylesheet">
        <!-- <![endif]-->

        <style type="text/css">
            body {
                width: 100%;
                background-color: #ffffff;
                margin: 0;
                padding: 0;
                -webkit-font-smoothing: antialiased;
                mso-margin-top-alt: 0px;
                mso-margin-bottom-alt: 0px;
                mso-padding-alt: 0px 0px 0px 0px;
            }
            
            p,
            h1,
            h2,
            h3,
            h4 {
                margin-top: 0;
                margin-bottom: 0;
                padding-top: 0;
                padding-bottom: 0;
            }
            
            span.preheader {
                display: none;
                font-size: 1px;
            }
            
            html {
                width: 100%;
            }
            
            table {
                font-size: 16px;
                border: 0;
            }

            .estHide {
            	display: none;
            }

            table h4 {
            	padding: 12px 0 4px 0;
            }
            /* ----------- responsivity ----------- */
            
            @media only screen and (max-width: 640px) {
                /*------ top header ------ */
                .main-header {
                    font-size: 20px !important;
                }
                .main-section-header {
                    font-size: 28px !important;
                }
                .show {
                    display: block !important;
                }
                .hide {
                    display: none !important;
                }
                .align-center {
                    text-align: center !important;
                }
                .no-bg {
                    background: none !important;
                }
                /*----- main image -------*/
                .main-image img {
                    width: 440px !important;
                    height: auto !important;
                }
                /* ====== divider ====== */
                .divider img {
                    width: 440px !important;
                }
                /*-------- container --------*/
                .container590 {
                    width: 440px !important;
                }
                .container580 {
                    width: 400px !important;
                }
                .main-button {
                    width: 220px !important;
                }
                /*-------- secions ----------*/
                .section-img img {
                    width: 320px !important;
                    height: auto !important;
                }
                .team-img img {
                    width: 100% !important;
                    height: auto !important;
                }
            }
            
            @media only screen and (max-width: 479px) {
                /*------ top header ------ */
                .main-header {
                    font-size: 18px !important;
                }
                .main-section-header {
                    font-size: 26px !important;
                }
                /* ====== divider ====== */
                .divider img {
                    width: 280px !important;
                }
                /*-------- container --------*/
                .container590 {
                    width: 280px !important;
                }
                .container590 {
                    width: 280px !important;
                }
                .container580 {
                    width: 260px !important;
                }
                /*-------- secions ----------*/
                .section-img img {
                    width: 280px !important;
                    height: auto !important;
                }
            }
        </style>
        <!-- [if gte mso 9]><style type=”text/css”>
            body {
            font-family: arial, sans-serif!important;
            }
            </style>
        <![endif]-->
    </head>

    <body class="respond" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0">
        <!-- header -->
        <table border="0" width="100%" cellpadding="0" cellspacing="0" bgcolor="ffffff">

            <tr>
                <td align="center">
                    <table border="0" align="center" width="590" cellpadding="0" cellspacing="0" class="container590">

                        <tr>
                            <td height="25" style="font-size: 25px; line-height: 25px;">&nbsp;</td>
                        </tr>

                        <tr>
                            <td align="center">

                                <table border="0" style="margin-top: 10%;" align="center" width="590" cellpadding="0" cellspacing="0" class="container590">

                                    <tr>
                                        <td align="center" height="70" style="height:70px;">
                                            <img width="200" border="0" style="display: block; width: 200px;" src="https://ccdoa.motioninfo.com/img/<cfoutput>#iata#</cfoutput>.jpg"/>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>

                        <tr>
                            <td height="25" style="font-size: 25px; line-height: 25px;">&nbsp;</td>
                        </tr>

                    </table>
                </td>
            </tr>
        </table>
        <!-- end header -->

        <!-- big image section -->
        <table border="0" width="100%" cellpadding="0" cellspacing="0" bgcolor="ffffff" class="bg_color">

            <tr>
                <td align="center">
                    <table border="0" align="center" width="590" cellpadding="0" cellspacing="0" class="container590">

                        <!-- <tr>
                            <td align="center">
                                <table border="0" width="40" align="center" cellpadding="0" cellspacing="0" bgcolor="eeeeee">
                                    <tr>
                                        <td height="2" style="font-size: 2px; line-height: 2px;">&nbsp;</td>
                                    </tr>
                                </table>
                            </td>
                        </tr>

                        <tr>
                            <td height="10" style="font-size: 20px; line-height: 20px;">&nbsp;</td>
                        </tr> -->

                        <tr>
                            <td align="center">
                                <table border="0" width="500" align="center" cellpadding="0" cellspacing="0" class="container590">
                                    <tr>
                                        <td align="center" style="color: #444444; font-size: 22px; font-family: 'Work Sans', Calibri, sans-serif; line-height: 24px;">

                                            <cfset formattedDate = DateFormat(confirm.Arrival, "mm/dd/yyyy")>
                                            <!-- isQuery(confirm) and confirm.recordcount eq 0 and conf_no is not ''  -->
                                            <cfif (getExeedLimt.exceeds_limit eq 0 OR getExeedLimt.exceeds_limit EQ 'No') AND getExeedLimt.CAPACITY GT 0 AND limiteventExeed EQ 0>
                                                <div style="line-height: 24px">
                                                    <cfset eventfeeGroup = "fee_" & confirm.parking>
                                                    <cfset chkEvtfeeGroup = 0>
                                                    <cfif isEvent.recordcount GT 0>

                                                        <cfif listFind("fee_1M,fee_1S,fee_2,fee_3", eventfeeGroup)>
                                                            <cfset chkEvtfeeGroup = isEvent[eventfeeGroup]>
                                                        <cfelse>
                                                            <cfset chkEvtfeeGroup = 0>
                                                        </cfif>

                                                        <cfif chkEvtfeeGroup EQ 0 And isEvent.ppr EQ 0>
                                                            <cfset subject = "Confirmed - #AirportName# #formattedDate#  #confirm.reg#">
                                                        <cfelseif  chkEvtfeeGroup EQ 0 And isEvent.ppr EQ 1>
                                                            <cfset subject = "Confirmed - #AirportName# #formattedDate#  #confirm.reg#">
                                                        <cfelseif chkEvtfeeGroup GT 0 And isEvent.ppr EQ 1 >
                                                            <cfset subject = "Pending Event Fee Payment - #AirportName# #formattedDate# #confirm.reg#">
                                                        <cfelse>
                                                            <cfset subject = "#AirportName# Arrival Confirmation">
                                                        </cfif>
                                                    <cfelse>
                                                        <cfif confirm.confirmation EQ 1>
                                                            <cfif chkEvtfeeGroup EQ 0 >
                                                                <cfset subject = "Confirmed - #AirportName# #formattedDate#  #confirm.reg#">
                                                            <cfelse>
                                                                <cfset subject = "#AirportName# Arrival Confirmation">
                                                            </cfif>
                                                        <cfelse>
                                                            <cfset subject = "#AirportName# Arrival Waitlisted">
                                                        </cfif>
                                                    </cfif>
                                                    <h3><cfoutput>#subject#</cfoutput></h3>
                                                </div>
                                            <cfelse>
                                                <cfif confirm.recordcount GT 0>
                                                    <cfset formattedDate = DateFormat(confirm.Arrival, "mm/dd/yyyy")>
                                                    <cfset tailNumber = confirm.reg>
                                                <cfelse>
                                                    <cfset formattedDate = DateFormat(getExeedLimt.Arrival, "mm/dd/yyyy")>
                                                    <cfset tailNumber = getExeedLimt.reg>
                                                </cfif>
                                                <div style="line-height: 24px; color: #C41E3A !important">
                                                    <cfoutput>
                                                        <cfif isEvent.recordcount GT 0>
                                                            <cfif listFind("fee_1M,fee_1S,fee_2,fee_3", eventfeeGroup)>
                                                                <cfset chkEvtfeeGroup = isEvent[eventfeeGroup]>
                                                            <cfelse>
                                                                <cfset chkEvtfeeGroup = 0>
                                                            </cfif>

                                                            <cfif chkEvtfeeGroup EQ 0 And isEvent.ppr EQ 0>
                                                                <cfset subject = "WAITLISTED <br> #AirportName# #formattedDate#  #tailNumber#">
                                                            <cfelseif  chkEvtfeeGroup EQ 0 And isEvent.ppr EQ 1>
                                                                <cfset subject = "WAITLISTED <br> #AirportName# #formattedDate#  #tailNumber#">
                                                            <cfelseif chkEvtfeeGroup GT 0 And isEvent.ppr EQ 1>
                                                                <cfset subject = "WAITLISTED <br> #AirportName# #formattedDate#  #tailNumber#">
                                                            <cfelse>
                                                                <cfset subject = "#AirportName# Arrival Waitlisted">
                                                            </cfif>
                                                        <cfelse>
                                                            <cfif chkEvtfeeGroup EQ 0 >
                                                                <cfset subject = "WAITLISTED <br> #AirportName# #formattedDate#  #tailNumber#">
                                                            <cfelse>
                                                                <cfset subject = "#AirportName# Arrival Waitlisted">
                                                            </cfif>
                                                        </cfif>
                                                        <h3>#subject#</h3>
                                                    </cfoutput>
                                                </div>
                                            </cfif> 
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>

                        <tr>
                            <td height="10" style="font-size: 20px; line-height: 20px;">&nbsp;</td>
                        </tr>

                        <tr>
                            <td align="center">
                                <table border="0" width="100%" align="center" cellpadding="0" cellspacing="0" class="container590">
                                    <tr>
                                        <td style="color: #444444; font-size: 18px !important; font-family: 'Work Sans', Calibri, sans-serif; line-height: 24px;">
                                            <cfset eventfeeGroup = "fee_" & confirm.parking>
                                            <cfset chkEvtfeeGroup = 0>
                                            <!--  isQuery(confirm) and confirm.recordcount eq 0  and conf_no is not '' -->
                                            <cfif (getExeedLimt.exceeds_limit eq 0 OR getExeedLimt.exceeds_limit EQ 'No') AND getExeedLimt.CAPACITY GT 0 AND limiteventExeed EQ 0>
                                                <div style="line-height: 24px">
                                                    <cfif isEvent.recordcount GT 0>
                                                        <cfif listFind("fee_1M,fee_1S,fee_2,fee_3", eventfeeGroup)>
                                                            <cfset chkEvtfeeGroup = isEvent[eventfeeGroup]>
                                                        <cfelse>
                                                            <cfset chkEvtfeeGroup = 0>
                                                        </cfif>

                                                        <cfif chkEvtfeeGroup EQ 0 And isEvent.ppr EQ 0>

                                                            <span style="text-align: center;display: block;">Notice of Arrival Confirmation</span><br><br>
                                                            Please note that an event <cfoutput><b>(#isEvent.name#)</b></cfoutput> will be taking place from <cfoutput>#DateFormat(isEvent.startdate, "mm/dd/yyyy")#</cfoutput> to <cfoutput>#DateFormat(isEvent.enddate, "mm/dd/yyyy")#</cfoutput> at <cfoutput>#iata#</cfoutput>.<br><br>

                                                        <cfelseif  chkEvtfeeGroup EQ 0 And isEvent.ppr EQ 1>

                                                            <span style="text-align: center;display: block;">Notice of Arrival Confirmation</span><br><br>
                                                            <b>Note:</b><br>
                                                            Please note that an event <cfoutput><b>(#isEvent.name#)</b></cfoutput> will be taking place from <cfoutput>#DateFormat(isEvent.startdate, "mm/dd/yyyy")#</cfoutput> to <cfoutput>#DateFormat(isEvent.enddate, "mm/dd/yyyy")#</cfoutput> at <cfoutput>#iata#</cfoutput>.<br><br>

                                                            Your "Confirmation Number" will serve as your PPR#. Please add this number when you file your flight plan. <br><br>

                                                        <cfelseif chkEvtfeeGroup GT 0 And isEvent.ppr EQ 1 >

                                                            <cfscript>
                                                                // Convert from local server time to UTC
                                                                utcStartDateTime = dateConvert("local2utc", isEvent.FEESTARTDATE);
                                                                utcEndDateTime = dateConvert("local2utc", isEvent.FEEENDDATE);

                                                                // Convert UTC to Local Pacific Time (assuming DST in effect: UTC -7)
                                                                localOffsetHours = -7;
                                                                localStartDateTime = dateAdd("h", localOffsetHours, utcStartDateTime);
                                                                localEndDateTime = dateAdd("h", localOffsetHours, utcEndDateTime);
                                                            </cfscript>

                                                            <span style="text-align: center;display: block;">Notice of Arrival Confirmation</span><br><br>
                                                            <b>Note:</b><br>
                                                            - Please note that an event <cfoutput><b>(#isEvent.name#)</b></cfoutput>  will be taking place from <cfoutput>#DateFormat(isEvent.startdate, "mm/dd/yyyy")#</cfoutput> to <cfoutput>#DateFormat(isEvent.enddate, "mm/dd/yyyy")#</cfoutput> at <cfoutput>#iata#</cfoutput>.<br><br>

                                                            - A $<cfoutput>#chkEvtfeeGroup#</cfoutput> Non-Refundable Special Event Fee will apply per turn for all transient aircraft from <cfoutput>#DateFormat(localStartDateTime, "dd-mmm-yyyy")# #TimeFormat(localStartDateTime, "HH:mm")# Pacific Time (#DateFormat(utcStartDateTime, "dd-mmm-yyyy")# #TimeFormat(utcStartDateTime, "HH:mm")#Z) - #DateFormat(localEndDateTime, "dd-mmm-yyyy")# #TimeFormat(localEndDateTime, "HH:mm")# Pacific Time (#DateFormat(utcEndDateTime, "dd-mmm-yyyy")# #TimeFormat(utcEndDateTime, "HH:mm")#Z)</cfoutput>. This fee applies to all arrivals. A Customer Service Representative will contact you for Payment and PPR# issuance.<br><br>
                                                        </cfif>
                                                    <cfelse>
                                                        <cfif confirm.confirmation EQ 1>
                                                            <cfif chkEvtfeeGroup EQ 0 >
                                                                <span style="text-align: center;display: block;">Notice of Arrival Confirmation</span><br><br>
                                                            </cfif>
                                                        <cfelse>
                                                            <span style="text-align: center;display: block;">Notice of Arrival waitlisted</span><br><br>
                                                        </cfif>
                                                    </cfif>
                                                </div>

                                                <table border="0" width="100%" cellpadding="0" cellspacing="0" bgcolor="ffffff">
												    <tr>
                                                        <cfif isEvent.recordcount GT 0 AND chkEvtfeeGroup GT 0 And isEvent.ppr EQ 1 AND isEvent.chargeFee EQ 1> 
                                                            <td align="center" colspan="2"><b>**Pending Event Fee Payment**</b></td>
                                                        <cfelse>
                                                            <cfif confirm.confirmation EQ 1>
                                                                <td align="right" style="padding-right: 15px"><b>CONFIRMATION #</b></td>
                                                                <td><b><h3><cfoutput>#conf_no#</cfoutput></h3></b></td>
                                                            </cfif>
                                                        </cfif>
                                                    </tr>
													<tr>
                                                        <td align="right" style="padding-right: 15px"><b>Name</b></td>
                                                        <td><cfoutput><cfif parameterexists(url.id)>#name#<cfelse>#first_name# #last_name#</cfif></cfoutput></td>
                                                    </tr>
													<tr>
                                                        <td align="right" style="padding-right: 15px"><b>Phone </b></td>
                                                        <td ><cfoutput>#phone#</cfoutput></td>
                                                    </tr>
													
													<tr>
                                                        <td align="right" style="padding-right: 15px"><b>Email </b></td>
                                                        <td ><cfoutput>#email#</cfoutput></td>
                                                    </tr>
                                                    <tr>
                                                        <td align="right" style="padding-right: 15px; min-width: 200px;"><b>Arrival from <cfoutput>#UCASE(arrFrom)#</cfoutput></b></td>
                                                        <td><cfoutput>#arrival#</cfoutput></td>
                                                    </tr>
                                                    <tr>
                                                        <td align="right" style="padding-right: 15px"><b>Departure to <cfoutput>#UCASE(depTo)#</cfoutput></b></td>
                                                        <td><cfoutput>#departure#</cfoutput></td>
                                                    </tr>
													
													<tr>
                                                        <td align="right" style="padding-right: 15px"></b></td>
                                                        <td></td>
                                                    </tr>
													
                                                    <tr>
                                                        <td align="right" style="padding-right: 15px"><b>Aircraft</b></td>
                                                        <td><cfoutput>#reg# - #actype_name#</cfoutput></td>
                                                    </tr>
                                                    <cfif confirm.estTotal GT 0>
                                                        <tr>
                                                            <td align="right" style="padding-right: 15px"><b>Estimated Fee</b></td>
                                                            <td><cfoutput>$#confirm.estTotal#</cfoutput></td>
                                                        </tr>
                                                    </cfif>

                                                </table>
																				
                                            <cfelse>
                                                <div style="line-height: 24px">
                                                    <span style="text-align: center; display: block;"><cfoutput>#AirportName#</cfoutput> Arrival Waitlisted</span><br><br>
                                                    <cfif isEvent.recordcount GT 0>

                                                        <cfif listFind("fee_1M,fee_1S,fee_2,fee_3", eventfeeGroup)>
                                                            <cfset chkEvtfeeGroup = isEvent[eventfeeGroup]>
                                                        <cfelse>
                                                            <cfset chkEvtfeeGroup = 0>
                                                        </cfif>

                                                        <cfif chkEvtfeeGroup EQ 0 And isEvent.ppr EQ 0>
                                                            Due to limited aircraft parking space during the time frame you selected, your reservation has been waitlisted.<br><br>

                                                            You will be notified by a Customer Service Representative if/when parking space becomes available.<br><br>

                                                            Please note that an event <cfoutput><b>(#isEvent.name#)</b></cfoutput> will be taking place from <cfoutput>#DateFormat(isEvent.startdate, "mm/dd/yyyy")#</cfoutput> to <cfoutput>#DateFormat(isEvent.enddate, "mm/dd/yyyy")#</cfoutput> at <cfoutput>#iata#</cfoutput>.<br><br>

                                                        <cfelseif  chkEvtfeeGroup EQ 0 And isEvent.ppr EQ 1>
                                                            Due to limited aircraft parking space during the time frame you selected, your reservation has been waitlisted.<br><br>

                                                            You will be notified by a Customer Service Representative if/when parking space becomes available.<br><br>

                                                            Please note that an event <cfoutput><b>(#isEvent.name#)</b></cfoutput> will be taking place from <cfoutput>#DateFormat(isEvent.startdate, "mm/dd/yyyy")#</cfoutput> to <cfoutput>#DateFormat(isEvent.enddate, "mm/dd/yyyy")#</cfoutput> at <cfoutput>#iata#</cfoutput>.
                                                            During this time frame a PPR# will be required. If you are cleared from the waitlist, you will receive a "Confirmation Number" that will serve as your PPR#.<br><br>

                                                        <cfelseif chkEvtfeeGroup GT 0 And isEvent.ppr EQ 1>
                                                            <cfscript>
                                                                // Convert from local server time to UTC
                                                                utcStartDateTime = dateConvert("local2utc", isEvent.FEESTARTDATE);
                                                                utcEndDateTime = dateConvert("local2utc", isEvent.FEEENDDATE);

                                                                // Convert UTC to Local Pacific Time (assuming DST in effect: UTC -7)
                                                                localOffsetHours = -7;
                                                                localStartDateTime = dateAdd("h", localOffsetHours, utcStartDateTime);
                                                                localEndDateTime = dateAdd("h", localOffsetHours, utcEndDateTime);
                                                            </cfscript>

                                                            Due to limited aircraft parking space during the period you selected your reservation has been waitlisted.<br><br>

                                                            You will be notified by a Customer Service Representative if/when parking space becomes available.<br><br>

                                                            Please note that an event <cfoutput><b>(#isEvent.name#)</b></cfoutput> will be taking place from <cfoutput>#DateFormat(isEvent.startdate, "mm/dd/yyyy")#</cfoutput> to <cfoutput>#DateFormat(isEvent.enddate, "mm/dd/yyyy")#</cfoutput> at <cfoutput>#iata#</cfoutput>.
                                                            Please note that for this event there will be a Special Event Fee.<br>
                                                            - A $<cfoutput>#chkEvtfeeGroup#</cfoutput> Non-Refundable Special Event Fee will apply per turn for all transient aircraft from <cfoutput>#DateFormat(localStartDateTime, "dd-mmm-yyyy")# #TimeFormat(localStartDateTime, "HH:mm")# Pacific Time (#DateFormat(utcStartDateTime, "dd-mmm-yyyy")# #TimeFormat(utcStartDateTime, "HH:mm")#Z) - #DateFormat(localEndDateTime, "dd-mmm-yyyy")# #TimeFormat(localEndDateTime, "HH:mm")# Pacific Time (#DateFormat(utcEndDateTime, "dd-mmm-yyyy")# #TimeFormat(utcEndDateTime, "HH:mm")#Z)</cfoutput>. This fee applies to all arrivals.<br><br>

                                                        <cfelse>
                                                            Due to limited aircraft parking space during the time frame you selected, your reservation has been waitlisted. <br><br>You will be notified by a Customer Service Representative if/when parking space becomes available.<br><br>

                                                        </cfif>
                                                    <cfelse>
                                                        <cfif chkEvtfeeGroup EQ 0 >
                                                            Due to limited aircraft parking space during the time frame you selected, your reservation has been waitlisted.<br><br>

                                                            You will be notified by a Customer Service Representative if/when parking space becomes available.<br><br>

                                                        <cfelse>
                                                            Due to limited aircraft parking space during the time frame you selected, your reservation has been waitlisted. <br><br>You will be notified by a Customer Service Representative if/when parking space becomes available.<br><br>

                                                        </cfif>
                                                    </cfif>
                                                </div>

                                                <table style="margin-top: -25px;" border="0" width="500" align="center" cellpadding="0" cellspacing="0" class="container590">
                                                    <tr>
                                                        <td align="center" style="color: #444444; font-size: 18px !important; font-family: 'Work Sans', Calibri, sans-serif; line-height: 24px;">
                                                            <br>
                                                            <table border="0" width="100%" cellpadding="0" cellspacing="0" bgcolor="ffffff">

                                                                <tr>
                                                                    <td align="right" style="padding-right: 15px"><b>Name</b></td>
                                                                    <td ><cfoutput><cfif parameterexists(name)> #name#<cfelse>#first_name# #last_name#</cfif></cfoutput></td>
                                                                </tr>
                                                                <tr>
                                                                    <td align="right" style="padding-right: 15px"><b>Phone </b></td>
                                                                    <td ><cfoutput>#phone#</cfoutput></td>
                                                                </tr>
                                                                
                                                                <tr>
                                                                    <td align="right" style="padding-right: 15px"><b>Email </b></td>
                                                                    <td ><cfoutput>#email#</cfoutput></td>
                                                                </tr>
                                                                
                                                                <tr>
                                                                    <td align="right" style="padding-right: 15px"></b></td>
                                                                    <td></td>
                                                                </tr>
                                                                
                                                                <tr>
                                                                    <td align="right" style="padding-right: 15px"><b>Aircraft</b></td>
                                                                    <td style="padding-left: 3px"><cfoutput>#reg# - #actype_name#</cfoutput></td>
                                                                </tr>
                                                                <cfif confirm.estTotal GT 0>
                                                                    <tr>
                                                                        <td align="right" style="padding-right: 15px"><b>Estimated Fee</b></td>
                                                                        <td><cfoutput>$#confirm.estTotal#</cfoutput></td>
                                                                    </tr>
                                                                </cfif>

                                                            </table>
                                                        </td>
                                                    </tr>
                                                </table>
                                            </cfif>
                                        </td>
                                    </tr>
                                </table>
							
							    
                            </td>
                        </tr>

                        <!-- <tr>
                            <td height="10" style="font-size: 20px; line-height: 20px;">&nbsp;</td>
                        </tr> -->
                        <cfif StructKeyExists(variables, "reSend") and !reSend>
                            <cfif isQuery(confirm) and confirm.recordcount eq 0  and conf_no is not ''>
                                <tr>
                                    <td align="center">
                                        <table border="0" width="100%" align="center" cellpadding="0" cellspacing="0" class="container590">
                                            <tr>
                                                <td align="center" style="color: #444444; font-size: 22px; font-family: 'Work Sans', Calibri, sans-serif; line-height: 24px;">
                                                    <div style="line-height: 36px">
                                                        Estimated Fees
                                                    </div>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>

                                <tr>
                                    <td align="center">
                                        <table border="0" width="500" align="center" cellpadding="0" cellspacing="0" class="container590">
                                            <tr>
                                                <td align="left" style="color: #444444; font-size: 14px !important; font-family: 'Work Sans', Calibri, sans-serif; line-height: 22px;">
                                                	<cfset estText_clean = RemoveChars(estText, 1, 9)>
        							  				<cfset estText_clean = Left(estText_clean, len(estText_clean)-3)>
                                                	<cfoutput>
                                                        #estText_clean#
                                                        <br>
                                                        <strong>Total: $#grandTotal#</strong>
                                                    </cfoutput>
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </cfif>
                        </cfif>
                    <!---
                        <tr>
                            <td align="center">
                                <table border="0" align="center" width="260" cellpadding="0" cellspacing="0" bgcolor="14437b" style="">

                                    <tr>
                                        <td height="10" style="font-size: 10px; line-height: 10px;">&nbsp;</td>
                                    </tr>

                                    <tr>
                                        <td align="center" style="color: #eeeeee; font-size: 18px; font-family: 'Work Sans', Calibri, sans-serif; line-height: 26px;">


                                            <div style="line-height: 26px; background-color: #14437b;">
                                                <a href="http://aero.motioninfo.com/reset_pw.cfm?n=<cfoutput>#UUID#</cfoutput>" style="color: #eeeeee; text-decoration: none;">RESET PASSWORD</a>
                                            </div>
                                        </td>
                                    </tr>

                                    <tr>
                                        <td height="10" style="font-size: 10px; line-height: 10px;">&nbsp;</td>
                                    </tr>

                                </table>
                            </td>
                        </tr>
                        --->
                        <!-- <tr>
                            <td height="30" style="font-size: 20px; line-height: 20px;">&nbsp;</td>
                        </tr> -->

                        <tr>
                            <td align="center">
                                <table border="0" width="40" align="center" cellpadding="0" cellspacing="0" bgcolor="eeeeee">
                                    <tr>
                                        <td height="2" style="font-size: 2px; line-height: 2px;">&nbsp;</td>
                                    </tr>
                                </table>
                            </td>
                        </tr>

                        <tr>
                            <td height="20" style="font-size: 20px; line-height: 20px;">&nbsp;</td>
                        </tr>

                        <tr>
                            <td align="center">
                                <table border="0" width="100%" align="center" cellpadding="0" cellspacing="0" class="container590">
                                    <tr>
                                        <td align="left" style="color: #444444; font-size: 16px; font-family: 'Work Sans', Calibri, sans-serif; line-height: 24px;">


                                            <div style="line-height: 24px">
                                                <cfif iata eq 'VGT'>
                                                    <cfset CS_email = 'nlva@lasairport.com'>
                                                    <cfset CS_phone = '(702) 261-3805'>
                                                <cfelse>
                                                    <cfset CS_email = 'customerservice@hnd.aero'>
                                                    <cfset CS_phone = '(702) 261-4831'>
                                                </cfif>

                                                Please contact the Customer Service Supervisor if you wish to make any changes:<br>
                                                <blockquote>Phone: <cfoutput>#CS_phone#</cfoutput><br>
                                                Email: <a href="mailto:<cfoutput>#CS_email#</cfoutput>"><cfoutput>#CS_email#</cfoutput></a></blockquote>
                                                <br>
                                                Thank you!
                                            </div>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>

                </td>
            </tr>

        </table>
        <!-- end section -->

    </body>

</html>