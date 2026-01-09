<cfinclude template="/header.cfm">

<cfheader name="Cache-Control" value="no-store, no-cache, must-revalidate, max-age=0">
<cfheader name="Pragma" value="no-cache">

<cfset iata = "HND">
<cfset AirportName = "Henderson">
<cfif isDefined("url.ap")>
	<cfif url.ap eq 'LAS' or url.ap eq 'VGT'>
		<cfset iata = url.ap>
		<cfset AirportName = 'North Las Vegas'>
	</cfif>
</cfif>

<cfif isDefined("form.grandTotal")>
	<cfquery datasource="CCDOA" name="isEvent">
		SELECT *,
		CASE
			WHEN feeStartDate <= '#departure#' AND feeEndDate >= '#arrival#'
			THEN 1
			ELSE 0
		END as chargeFee
		FROM [events]
		WHERE (startDate <= '#departure#' AND endDate >= '#arrival#')
		AND deleted = 0
		AND locationid = '#iata#'
	</cfquery>
	<cfset limiteventExeed = 0>
	<cfif isEvent.recordcount>

		<!--- Get parking group --->
		<cfquery name="getGroup" datasource="CCDOA">
		  SELECT 
			CASE 
			  WHEN sqft <= 1250 THEN '1S'
			  WHEN sqft > 1250 AND sqft < 2000 THEN '1M'
			  WHEN sqft >= 2000 AND sqft < 3500 THEN '2'
			  ELSE '3'
			END AS parkingGroup
		  FROM aircraft
		  WHERE id = <cfqueryparam value="#form.actype#" cfsqltype="cf_sql_integer">
		</cfquery>
		<cfset parkingGroup = getGroup.parkingGroup>
		<cfset limitColumn = "limit_" & parkingGroup>

		<!--- Get group limit from event --->
		<cfquery name="getEventLimit" datasource="CCDOA">
		  SELECT #limitColumn# AS groupLimit, startDate, endDate
		  FROM events
		  WHERE id = <cfqueryparam value="#isEvent.id#" cfsqltype="cf_sql_integer">
		</cfquery>
		<!--- Count current confirmed reservations in this group for the event time range --->
		<cfquery name="getGroupCount" datasource="CCDOA">
			SELECT COUNT(*) AS groupCount
			FROM reservations r
			INNER JOIN aircraft a ON r.ACType = a.id OR r.ACType = a.legacyID
			WHERE r.locationid = <cfqueryparam value="#form.locationid#" cfsqltype="cf_sql_varchar">
			AND r.deleted = 0
			AND r.confirmation = 1
			AND ('#getEventLimit.startDate#' <= r.departure) and ('#getEventLimit.endDate#' >= r.arrival)
			AND (
			  CASE 
				WHEN a.sqft <= 1250 THEN '1S'
				WHEN a.sqft > 1250 AND a.sqft < 2000 THEN '1M'
				WHEN a.sqft >= 2000 AND a.sqft < 3500 THEN '2'
				ELSE '3'
			  END
			) = <cfqueryparam value="#parkingGroup#" cfsqltype="cf_sql_varchar">
		</cfquery>
		<!--- Determine confirmation status --->
		<cfif getGroupCount.groupCount LT getEventLimit.groupLimit>
		  <cfset confirm = 1>
		<cfelse>
		  <cfset confirm = 0>
		  <cfset limiteventExeed = 1>
		</cfif>

	<cfelse>
		<cfquery datasource="CCDOA" name="overlap">
			SELECT 
				count(*) total, 
				max(pGroup) pGroup, 
				ISNULL(max(capacity),1) capacity,
				(SELECT pGroup from aircraft_view where id = #actype# and locationid = '#iata#') as pgroupName
			FROM reservations r
			INNER JOIN aircraft_view a on (r.actype = a.id OR a.legacyID = r.ACType) AND r.locationid = a.locationid
			WHERE r.locationid = '#iata#'
			AND r.deleted = 0
			AND r.confirmation = 1
			AND a.pGroup = (SELECT pGroup from aircraft_view where id = #actype# and locationid = '#iata#')
			AND ('#arrival#' <= departure) and (arrival <= '#departure#')
		</cfquery>
		<cfif overlap.total gte overlap.capacity>
			<cfset confirm = 0>
		<cfelse>
			<cfset confirm = 1>
		</cfif>
	</cfif>
	<!--- <cfif cgi.REMOTE_ADDR EQ '110.39.156.90'>
		<cfdump var="#isEvent#">
		<cfdump var="#getEventLimit#">
		<cfdump var="#getGroupCount#">
	    <cfdump var="#confirm#">
	    <!--- <cfabort> --->
	</cfif> --->
	<cfquery datasource="CCDOA" name="insert" result="insert_result">
		INSERT INTO reservations (
			[reg]
			,[ACType]
			,[name]
			,[company]
			,[arrival]
			,[departure]
			,[arrFrom]
			,[depTo]
			,[fuel_type]
			,[fuel_gal]
			,[fuel_prist]
			,[fuel_contract]
			,[gpu_hours]
			,[jumpstart]
			,[lavatory]
			,[water]
			,[oxygen]
			,[ox_portable]
			,[ox_fixed]
			,[ox_large]
			,[email]
			,[phone]
			,[callsign]
			,[estTotal]
			,[estText]
			,[notes]
			,[locationid]
			,[confirmation]
			,[deleted]
			,[status]
		)
		VALUES (
			'#UCASE(reg)#'
			,'#actype#'
			,'#last_name#, #first_name#'
			<cfif len(company)>
				,'#company#'
			<cfelse>
				,NULL
			</cfif>
			,'#arrival#'
			,'#departure#'
			,'#UCASE(arrFrom)#'
			,'#UCASE(depTo)#'
			<cfif len(gallons)>
				,'#fuel_type#'
				,'#gallons#'
				<cfif len(fuel_prist)>
					,'#fuel_prist#'
				<cfelse>
					,NULL
				</cfif>
				<cfif len(fuel_contract)>
					,'#fuel_contract#'
				<cfelse>
					,NULL
				</cfif>
			<cfelse>
				,NULL
				,NULL
				,NULL
				,NULL
			</cfif>
			,'#gpu#'
			<cfif len(jumpstart)>
				,'#jumpstart#'
			<cfelse>
				,NULL
			</cfif>
			<cfif len(lavatory)>
				,'#lavatory#'
			<cfelse>
				,NULL
			</cfif>
			<cfif len(water)>
				,'#water#'
			<cfelse>
				,NULL
			</cfif>
			<cfif len(oxygen)>
				,'#oxygen#'
				<cfif len(ox_portable)>
					<cfif ox_portable gt 0>
						,'#ox_portable#'
					<cfelse>
						,NULL
					</cfif>
				<cfelse>
					,NULL
				</cfif>
				<cfif len(ox_fixed)>
					<cfif ox_fixed gt 0>
						,'#ox_fixed#'
					<cfelse>
						,NULL
					</cfif>
				<cfelse>
					,NULL
				</cfif>
				<cfif len(ox_large)>
					<cfif ox_large gt 0>
						,'#ox_large#'
					<cfelse>
						,NULL
					</cfif>
				<cfelse>
					,NULL
				</cfif>
			<cfelse>
				,NULL
				,NULL
				,NULL
				,NULL
			</cfif>
			,'#email#'
			,'+#countryCode# #phone#'
			<cfif len(callsign)>
			,'#callsign#'
			<cfelse>
			,NULL
			</cfif>
			,'#grandTotal#'
			,'#estText#'
			,'#notes#'
			,'#locationid#'
			,#confirm#
			,0
			,1
		)
	</cfquery>

	<cfset conf_no = iata & '-' & numberFormat(evaluate(insert_result.identitycol + 10000), '000000')>

	<cfquery datasource='CCDOA' name="conf_update">
		UPDATE reservations
		SET conf_no = '#conf_no#'
		WHERE id = #insert_result.identitycol#
	</cfquery>

	<!--- use this query for exeed limit and global setting capacity --->
	<cfquery datasource='CCDOA' name=getExeedLimt>
		SELECT 
			S.*, 
			pg.*
		FROM (
			SELECT 
				R.id AS reservation_id,
				R.*, 
				a.sqft,
				ISNULL(e.exceeds_limit, 0) AS exceeds_limit,
				CASE 
					WHEN a.sqft <= 1250 THEN '1S'
					WHEN a.sqft > 1250 AND a.sqft < 2000 THEN '1M'
					WHEN a.sqft >= 2000 AND a.sqft < 3500 THEN '2'
					WHEN a.sqft >= 3500 THEN '3'
				END AS parking
			FROM RESERVATIONS R
			LEFT JOIN aircraft a ON R.ACType = a.id OR R.actype = a.legacyid
			LEFT JOIN eventcheck e 
				ON e.locationid = R.locationid
				AND (
					(e.startdate <= R.arrival AND e.enddate >= R.arrival)
					OR (e.startdate <= R.departure AND e.enddate >= R.departure)
				)
			WHERE R.id = #insert_result.identitycol#
			  AND R.deleted = 0
		) S
		JOIN parking_groups pg 
			ON S.locationid = pg.locationid AND pg.pGroup = S.parking
		WHERE S.reservation_id = #insert_result.identitycol#
	</cfquery>
	
	<cfif (getExeedLimt.exceeds_limit eq 0 OR getExeedLimt.exceeds_limit EQ 'No') AND getExeedLimt.CAPACITY GT 0 AND limiteventExeed EQ 0>

		<cfquery datasource='CCDOA' name=confirm>
			WITH res AS (
				SELECT max_res_id,exceeds_limit,
					CASE 
						WHEN e.locationid IS NOT NULL AND A.id > ISNULL(max_res_id, 0) and e.exceeds_limit= 'YES' THEN 1 
						ELSE 0 END AS event,
					A.*
				FROM (
					SELECT
						CASE 
							WHEN a.sqft <= 1250 THEN '1S'
							WHEN a.sqft > 1250 AND a.sqft < 2000 THEN '1M'
							WHEN a.sqft >= 2000 AND a.sqft < 3500 THEN '2'
							WHEN a.sqft >= 3500 THEN '3'
						END AS parking,
						R.*
					FROM RESERVATIONS R
					LEFT JOIN aircraft a ON R.ACType = a.id OR R.actype = a.legacyid
					WHERE R.deleted = 0
				) A
				LEFT JOIN eventcheck e ON e.locationid = A.locationid
				AND e.parking = A.parking
				AND (
					(e.startdate <= A.arrival AND e.enddate >= A.arrival) OR
					(e.startdate <= A.departure AND e.enddate >= A.departure)
				)
			)

			select * from res where id=#insert_result.identitycol# 

		</cfquery>

		<cfset formattedDate = DateFormat(confirm.Arrival, "mm/dd/yyyy")>
		<cfset eventfeeGroup = "fee_" & confirm.parking>

		<cfset chkEvtfeeGroup = 0>
		<cfif isEvent.recordcount GT 0>
			<cfif listFind("fee_1M,fee_1S,fee_2,fee_3", eventfeeGroup)>
				<cfset chkEvtfeeGroup = isEvent[eventfeeGroup]>
			<cfelse>
				<cfset chkEvtfeeGroup = 0>
			</cfif>

			<cfif chkEvtfeeGroup EQ 0 And isEvent.ppr EQ 0>
				<cfset subject = "Confirmed - #AirportName# #formattedDate# #confirm.reg#">
			<cfelseif  chkEvtfeeGroup EQ 0 And isEvent.ppr EQ 1>
				<cfset subject = "Confirmed - #AirportName# #formattedDate# #confirm.reg#">
			<cfelseif chkEvtfeeGroup GT 0 And isEvent.ppr EQ 1>
				<cfset subject = "Pending Event Fee Payment - #AirportName# #formattedDate# #confirm.reg#">
			<cfelse>
				<cfset subject = "#AirportName# Arrival Confirmation">
			</cfif>
		<cfelse>
			
			<cfif confirm.confirmation EQ 1>

				<cfif chkEvtfeeGroup EQ 0 >
					<cfset subject = "Confirmed - #AirportName# #formattedDate# #confirm.reg#">
				<cfelse>
					<cfset subject = "#AirportName# Arrival Confirmation">
				</cfif>
			<cfelse>
				<cfset subject = "#AirportName# Arrival Waitlisted">
			</cfif>
		</cfif>

	<cfelse>

		<cfquery datasource='CCDOA' name=confirm>
			WITH res AS (
				SELECT max_res_id,exceeds_limit,
					CASE 
						WHEN e.locationid IS NOT NULL AND A.id > ISNULL(max_res_id, 0) and e.exceeds_limit= 'YES' THEN 1 
						ELSE 0 END AS event,
					A.*
				FROM (
					SELECT
						CASE 
							WHEN a.sqft <= 1250 THEN '1S'
							WHEN a.sqft > 1250 AND a.sqft < 2000 THEN '1M'
							WHEN a.sqft >= 2000 AND a.sqft < 3500 THEN '2'
							WHEN a.sqft >= 3500 THEN '3'
						END AS parking,
						R.*
					FROM RESERVATIONS R
					LEFT JOIN aircraft a ON R.ACType = a.id OR R.actype = a.legacyid
					WHERE R.deleted = 0
				) A
				LEFT JOIN eventcheck e ON e.locationid = A.locationid
				AND e.parking = A.parking
				AND (
					(e.startdate <= A.arrival AND e.enddate >= A.arrival) OR
					(e.startdate <= A.departure AND e.enddate >= A.departure)
				)
			)

			select * from res where id=#insert_result.identitycol# and exceeds_limit='YES'

		</cfquery>

		<cfif confirm.recordcount GT 0>
			<cfset formattedDate = DateFormat(confirm.Arrival, "mm/dd/yyyy")>
			<cfset tailNumber = confirm.reg>
		<cfelse>
			<cfset formattedDate = DateFormat(getExeedLimt.Arrival, "mm/dd/yyyy")>
			<cfset tailNumber = getExeedLimt.reg>
		</cfif>
		<cfset eventfeeGroup = "fee_" & confirm.parking>
		<cfset chkEvtfeeGroup = 0>
		<cfif isEvent.recordcount GT 0>

			<cfif listFind("fee_1M,fee_1S,fee_2,fee_3", eventfeeGroup)>
				<cfset chkEvtfeeGroup = isEvent[eventfeeGroup]>
			<cfelse>
				<cfset chkEvtfeeGroup = 0>
			</cfif>

			<cfif chkEvtfeeGroup EQ 0 And isEvent.ppr EQ 0>
				<cfset subject = "WAITLISTED -#AirportName# #formattedDate# #tailNumber#">
			<cfelseif  chkEvtfeeGroup EQ 0 And isEvent.ppr EQ 1>
				<cfset subject = "WAITLISTED - #AirportName# #formattedDate# #tailNumber#">
			<cfelseif chkEvtfeeGroup GT 0 And isEvent.ppr EQ 1>
				<cfset subject = "WAITLISTED - #AirportName# #formattedDate# #tailNumber#">
			<cfelse>
				<cfset subject = "#AirportName# Arrival Waitlisted">
			</cfif>
		<cfelse>
			<cfif chkEvtfeeGroup EQ 0 >
				<cfset subject = "WAITLISTED - #AirportName# #formattedDate# #tailNumber#">
			<cfelse>
				<cfset subject = "#AirportName# Arrival Waitlisted">
			</cfif>
		</cfif>

	</cfif>

	<cfmail from="#iata# Reservations <ccdoa.reservations@mgn.com>"
		to="#form.email#"
		subject = "#subject#" 
		type="text/html">
		<cfinclude template="secure/email_Notification.cfm">

		<CFMAILPARAM name='Errors-To' value="mjc@mgn.com">
	</cfmail>

	<cfinclude template="secure/email_Notification.cfm">
	<script>
	    if (window.history.replaceState) {
		    window.history.replaceState(null, null, window.location.href);
	    }
	</script>
	<cfabort>
</cfif>

<cfquery datasource="CCDOA" name="fuel">
  SELECT * from fuel
  order by id asc
</cfquery>

<style>
	.formHide,
	.estHide { display: none; }

	.estHide div {
		margin: 0;
		padding: 0;
	}

	.well .page-header {
		border-bottom: 1px solid #ddd;
		margin: -9px 0 0 0;
	}

	.well h4 { 
		margin: 10px 0 5px 0;
		padding-top: 10px; 
	}

	#grandTotal h4 {
		border-top: 1px solid #ddd;
		padding-top: 15px;
	}

	#grandTotal b {
		font-size: 1.7rem;
	}

	.affix {
		width: 48% !important;
	}

	.error {
		font-size: 0.9em;
		font-weight: normal;
		color: red;
	}

	.reqLabel {
		color: red !important;
	}

	input.upper { text-transform: uppercase; }

	@media (max-width: 992px) {
		.affix {
		  position: static;
		  width: 100% !important;
		}
	}
    .g-recaptcha{
    	margin-bottom: 17px;
    }

</style>

<link rel="stylesheet" href="/css/bootstrap-datetimepicker.min.css" />
<!-- SweetAlert2 CSS -->
<link href="https://cdn.jsdelivr.net/npm/sweetalert2@11/dist/sweetalert2.min.css" rel="stylesheet">
<script src="//cdnjs.cloudflare.com/ajax/libs/moment.js/2.8.4/moment.min.js"></script>
<script src="/js/bootstrap-datetimepicker.min.js"></script>
<script src="https://www.google.com/recaptcha/api.js" async defer></script>
<!-- SweetAlert2 JS -->
<script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>


<cfif isDefined('url.ap') AND isDefined('url.iframe') AND url.iframe EQ 'yes'>
<cfelse>
	<div class="row">
		<div class="col-md-12">
			<h2 class="page-header"><cfoutput>#UCase(iata)#</cfoutput> Notice of Arrival</h2>
		</div>
	</div>
</cfif>

<div class="row">
	<div <cfif isDefined('url.ap') AND isDefined('url.iframe') AND url.iframe EQ 'yes'> class="col-md-8" style="margin-left: 30px;" <cfelse> class="col-md-6"</cfif>>
	  <form class="form-horizontal" method="POST" id="res_form">
		<input type="hidden" name="locationid" value="<cfoutput>#iata#</cfoutput>">
		<input type="hidden" name="grandTotal">
		<input type="hidden" name="estText">
		<h3 class="page-header" style="margin-top: 10px">Your Information</h3>
		  <div class="form-group">
			<label for="first_name" class="col-sm-3 control-label">First Name <span class="reqLabel">*</span></label>
			<div class="col-sm-6">
			  <input type="text" class="form-control" name="first_name">
			</div>
		  </div>
		  <div class="form-group">
			<label for="last_name" class="col-sm-3 control-label">Last Name <span class="reqLabel">*</span></label>
			<div class="col-sm-6">
			  <input type="text" class="form-control" name="last_name">
			</div>
		  </div>          
		  <div class="form-group">
			<label for="last_name" class="col-sm-3 control-label">Company Name</label>
			<div class="col-sm-6">
			  <input type="text" class="form-control" name="company">
			</div>
		  </div>
		  <div class="form-group">
			<label for="email" class="col-sm-3 control-label">Email Address <span class="reqLabel">*</span></label>
			<div class="col-sm-6">
			  <input type="email" class="form-control" name="email" id="email">
			</div>
		  </div>
		  <div class="form-group">
			<label for="emailConf" class="col-sm-3 control-label">Confirm Email <span class="reqLabel">*</span></label>
			<div class="col-sm-6">
			  <input type="email" class="form-control" name="emailConf" id="emailConf">
			</div>
		  </div>
		  <div class="form-group">
			<label for="countryCode" class="col-sm-3 control-label">Country Code <span class="reqLabel">*</span></label>
			<div class="col-sm-6">
			  <!-- country codes (ISO 3166) and Dial codes. -->
				<select name="countryCode" class="form-control">
					<option data-countryCode="US" value="1" selected>USA (+1)</option>
					<option data-countryCode="CA" value="1">Canada (+1)</option>
					<option data-countryCode="MX" value="52">Mexico (+52)</option>
					<optgroup label="Other countries">
						<option data-countryCode="DZ" value="213">Algeria (+213)</option>
						<option data-countryCode="AD" value="376">Andorra (+376)</option>
						<option data-countryCode="AO" value="244">Angola (+244)</option>
						<option data-countryCode="AI" value="1264">Anguilla (+1264)</option>
						<option data-countryCode="AG" value="1268">Antigua &amp; Barbuda (+1268)</option>
						<option data-countryCode="AR" value="54">Argentina (+54)</option>
						<option data-countryCode="AM" value="374">Armenia (+374)</option>
						<option data-countryCode="AW" value="297">Aruba (+297)</option>
						<option data-countryCode="AU" value="61">Australia (+61)</option>
						<option data-countryCode="AT" value="43">Austria (+43)</option>
						<option data-countryCode="AZ" value="994">Azerbaijan (+994)</option>
						<option data-countryCode="BS" value="1242">Bahamas (+1242)</option>
						<option data-countryCode="BH" value="973">Bahrain (+973)</option>
						<option data-countryCode="BD" value="880">Bangladesh (+880)</option>
						<option data-countryCode="BB" value="1246">Barbados (+1246)</option>
						<option data-countryCode="BY" value="375">Belarus (+375)</option>
						<option data-countryCode="BE" value="32">Belgium (+32)</option>
						<option data-countryCode="BZ" value="501">Belize (+501)</option>
						<option data-countryCode="BJ" value="229">Benin (+229)</option>
						<option data-countryCode="BM" value="1441">Bermuda (+1441)</option>
						<option data-countryCode="BT" value="975">Bhutan (+975)</option>
						<option data-countryCode="BO" value="591">Bolivia (+591)</option>
						<option data-countryCode="BA" value="387">Bosnia Herzegovina (+387)</option>
						<option data-countryCode="BW" value="267">Botswana (+267)</option>
						<option data-countryCode="BR" value="55">Brazil (+55)</option>
						<option data-countryCode="BN" value="673">Brunei (+673)</option>
						<option data-countryCode="BG" value="359">Bulgaria (+359)</option>
						<option data-countryCode="BF" value="226">Burkina Faso (+226)</option>
						<option data-countryCode="BI" value="257">Burundi (+257)</option>
						<option data-countryCode="KH" value="855">Cambodia (+855)</option>
						<option data-countryCode="CM" value="237">Cameroon (+237)</option>
						<!---<option data-countryCode="CA" value="1">Canada (+1)</option>--->
						<option data-countryCode="CV" value="238">Cape Verde Islands (+238)</option>
						<option data-countryCode="KY" value="1345">Cayman Islands (+1345)</option>
						<option data-countryCode="CF" value="236">Central African Republic (+236)</option>
						<option data-countryCode="CL" value="56">Chile (+56)</option>
						<option data-countryCode="CN" value="86">China (+86)</option>
						<option data-countryCode="CO" value="57">Colombia (+57)</option>
						<option data-countryCode="KM" value="269">Comoros (+269)</option>
						<option data-countryCode="CG" value="242">Congo (+242)</option>
						<option data-countryCode="CK" value="682">Cook Islands (+682)</option>
						<option data-countryCode="CR" value="506">Costa Rica (+506)</option>
						<option data-countryCode="HR" value="385">Croatia (+385)</option>
						<option data-countryCode="CU" value="53">Cuba (+53)</option>
						<option data-countryCode="CY" value="90392">Cyprus North (+90392)</option>
						<option data-countryCode="CY" value="357">Cyprus South (+357)</option>
						<option data-countryCode="CZ" value="42">Czech Republic (+42)</option>
						<option data-countryCode="DK" value="45">Denmark (+45)</option>
						<option data-countryCode="DJ" value="253">Djibouti (+253)</option>
						<option data-countryCode="DM" value="1809">Dominica (+1809)</option>
						<option data-countryCode="DO" value="1809">Dominican Republic (+1809)</option>
						<option data-countryCode="EC" value="593">Ecuador (+593)</option>
						<option data-countryCode="EG" value="20">Egypt (+20)</option>
						<option data-countryCode="SV" value="503">El Salvador (+503)</option>
						<option data-countryCode="GQ" value="240">Equatorial Guinea (+240)</option>
						<option data-countryCode="ER" value="291">Eritrea (+291)</option>
						<option data-countryCode="EE" value="372">Estonia (+372)</option>
						<option data-countryCode="ET" value="251">Ethiopia (+251)</option>
						<option data-countryCode="FK" value="500">Falkland Islands (+500)</option>
						<option data-countryCode="FO" value="298">Faroe Islands (+298)</option>
						<option data-countryCode="FJ" value="679">Fiji (+679)</option>
						<option data-countryCode="FI" value="358">Finland (+358)</option>
						<option data-countryCode="FR" value="33">France (+33)</option>
						<option data-countryCode="GF" value="594">French Guiana (+594)</option>
						<option data-countryCode="PF" value="689">French Polynesia (+689)</option>
						<option data-countryCode="GA" value="241">Gabon (+241)</option>
						<option data-countryCode="GM" value="220">Gambia (+220)</option>
						<option data-countryCode="GE" value="7880">Georgia (+7880)</option>
						<option data-countryCode="DE" value="49">Germany (+49)</option>
						<option data-countryCode="GH" value="233">Ghana (+233)</option>
						<option data-countryCode="GI" value="350">Gibraltar (+350)</option>
						<option data-countryCode="GR" value="30">Greece (+30)</option>
						<option data-countryCode="GL" value="299">Greenland (+299)</option>
						<option data-countryCode="GD" value="1473">Grenada (+1473)</option>
						<option data-countryCode="GP" value="590">Guadeloupe (+590)</option>
						<option data-countryCode="GU" value="671">Guam (+671)</option>
						<option data-countryCode="GT" value="502">Guatemala (+502)</option>
						<option data-countryCode="GN" value="224">Guinea (+224)</option>
						<option data-countryCode="GW" value="245">Guinea - Bissau (+245)</option>
						<option data-countryCode="GY" value="592">Guyana (+592)</option>
						<option data-countryCode="HT" value="509">Haiti (+509)</option>
						<option data-countryCode="HN" value="504">Honduras (+504)</option>
						<option data-countryCode="HK" value="852">Hong Kong (+852)</option>
						<option data-countryCode="HU" value="36">Hungary (+36)</option>
						<option data-countryCode="IS" value="354">Iceland (+354)</option>
						<option data-countryCode="IN" value="91">India (+91)</option>
						<option data-countryCode="ID" value="62">Indonesia (+62)</option>
						<option data-countryCode="IR" value="98">Iran (+98)</option>
						<option data-countryCode="IQ" value="964">Iraq (+964)</option>
						<option data-countryCode="IE" value="353">Ireland (+353)</option>
						<option data-countryCode="IL" value="972">Israel (+972)</option>
						<option data-countryCode="IT" value="39">Italy (+39)</option>
						<option data-countryCode="JM" value="1876">Jamaica (+1876)</option>
						<option data-countryCode="JP" value="81">Japan (+81)</option>
						<option data-countryCode="JO" value="962">Jordan (+962)</option>
						<option data-countryCode="KZ" value="7">Kazakhstan (+7)</option>
						<option data-countryCode="KE" value="254">Kenya (+254)</option>
						<option data-countryCode="KI" value="686">Kiribati (+686)</option>
						<option data-countryCode="KP" value="850">Korea North (+850)</option>
						<option data-countryCode="KR" value="82">Korea South (+82)</option>
						<option data-countryCode="KW" value="965">Kuwait (+965)</option>
						<option data-countryCode="KG" value="996">Kyrgyzstan (+996)</option>
						<option data-countryCode="LA" value="856">Laos (+856)</option>
						<option data-countryCode="LV" value="371">Latvia (+371)</option>
						<option data-countryCode="LB" value="961">Lebanon (+961)</option>
						<option data-countryCode="LS" value="266">Lesotho (+266)</option>
						<option data-countryCode="LR" value="231">Liberia (+231)</option>
						<option data-countryCode="LY" value="218">Libya (+218)</option>
						<option data-countryCode="LI" value="417">Liechtenstein (+417)</option>
						<option data-countryCode="LT" value="370">Lithuania (+370)</option>
						<option data-countryCode="LU" value="352">Luxembourg (+352)</option>
						<option data-countryCode="MO" value="853">Macao (+853)</option>
						<option data-countryCode="MK" value="389">Macedonia (+389)</option>
						<option data-countryCode="MG" value="261">Madagascar (+261)</option>
						<option data-countryCode="MW" value="265">Malawi (+265)</option>
						<option data-countryCode="MY" value="60">Malaysia (+60)</option>
						<option data-countryCode="MV" value="960">Maldives (+960)</option>
						<option data-countryCode="ML" value="223">Mali (+223)</option>
						<option data-countryCode="MT" value="356">Malta (+356)</option>
						<option data-countryCode="MH" value="692">Marshall Islands (+692)</option>
						<option data-countryCode="MQ" value="596">Martinique (+596)</option>
						<option data-countryCode="MR" value="222">Mauritania (+222)</option>
						<option data-countryCode="YT" value="269">Mayotte (+269)</option>
						<!---<option data-countryCode="MX" value="52">Mexico (+52)</option>--->
						<option data-countryCode="FM" value="691">Micronesia (+691)</option>
						<option data-countryCode="MD" value="373">Moldova (+373)</option>
						<option data-countryCode="MC" value="377">Monaco (+377)</option>
						<option data-countryCode="MN" value="976">Mongolia (+976)</option>
						<option data-countryCode="MS" value="1664">Montserrat (+1664)</option>
						<option data-countryCode="MA" value="212">Morocco (+212)</option>
						<option data-countryCode="MZ" value="258">Mozambique (+258)</option>
						<option data-countryCode="MN" value="95">Myanmar (+95)</option>
						<option data-countryCode="NA" value="264">Namibia (+264)</option>
						<option data-countryCode="NR" value="674">Nauru (+674)</option>
						<option data-countryCode="NP" value="977">Nepal (+977)</option>
						<option data-countryCode="NL" value="31">Netherlands (+31)</option>
						<option data-countryCode="NC" value="687">New Caledonia (+687)</option>
						<option data-countryCode="NZ" value="64">New Zealand (+64)</option>
						<option data-countryCode="NI" value="505">Nicaragua (+505)</option>
						<option data-countryCode="NE" value="227">Niger (+227)</option>
						<option data-countryCode="NG" value="234">Nigeria (+234)</option>
						<option data-countryCode="NU" value="683">Niue (+683)</option>
						<option data-countryCode="NF" value="672">Norfolk Islands (+672)</option>
						<option data-countryCode="NP" value="670">Northern Marianas (+670)</option>
						<option data-countryCode="NO" value="47">Norway (+47)</option>
						<option data-countryCode="OM" value="968">Oman (+968)</option>
						<option data-countryCode="PW" value="680">Palau (+680)</option>
						<option data-countryCode="PA" value="507">Panama (+507)</option>
						<option data-countryCode="PG" value="675">Papua New Guinea (+675)</option>
						<option data-countryCode="PY" value="595">Paraguay (+595)</option>
						<option data-countryCode="PE" value="51">Peru (+51)</option>
						<option data-countryCode="PH" value="63">Philippines (+63)</option>
						<option data-countryCode="PL" value="48">Poland (+48)</option>
						<option data-countryCode="PT" value="351">Portugal (+351)</option>
						<option data-countryCode="PR" value="1787">Puerto Rico (+1787)</option>
						<option data-countryCode="QA" value="974">Qatar (+974)</option>
						<option data-countryCode="RE" value="262">Reunion (+262)</option>
						<option data-countryCode="RO" value="40">Romania (+40)</option>
						<option data-countryCode="RU" value="7">Russia (+7)</option>
						<option data-countryCode="RW" value="250">Rwanda (+250)</option>
						<option data-countryCode="SM" value="378">San Marino (+378)</option>
						<option data-countryCode="ST" value="239">Sao Tome &amp; Principe (+239)</option>
						<option data-countryCode="SA" value="966">Saudi Arabia (+966)</option>
						<option data-countryCode="SN" value="221">Senegal (+221)</option>
						<option data-countryCode="CS" value="381">Serbia (+381)</option>
						<option data-countryCode="SC" value="248">Seychelles (+248)</option>
						<option data-countryCode="SL" value="232">Sierra Leone (+232)</option>
						<option data-countryCode="SG" value="65">Singapore (+65)</option>
						<option data-countryCode="SK" value="421">Slovak Republic (+421)</option>
						<option data-countryCode="SI" value="386">Slovenia (+386)</option>
						<option data-countryCode="SB" value="677">Solomon Islands (+677)</option>
						<option data-countryCode="SO" value="252">Somalia (+252)</option>
						<option data-countryCode="ZA" value="27">South Africa (+27)</option>
						<option data-countryCode="ES" value="34">Spain (+34)</option>
						<option data-countryCode="LK" value="94">Sri Lanka (+94)</option>
						<option data-countryCode="SH" value="290">St. Helena (+290)</option>
						<option data-countryCode="KN" value="1869">St. Kitts (+1869)</option>
						<option data-countryCode="SC" value="1758">St. Lucia (+1758)</option>
						<option data-countryCode="SD" value="249">Sudan (+249)</option>
						<option data-countryCode="SR" value="597">Suriname (+597)</option>
						<option data-countryCode="SZ" value="268">Swaziland (+268)</option>
						<option data-countryCode="SE" value="46">Sweden (+46)</option>
						<option data-countryCode="CH" value="41">Switzerland (+41)</option>
						<option data-countryCode="SI" value="963">Syria (+963)</option>
						<option data-countryCode="TW" value="886">Taiwan (+886)</option>
						<option data-countryCode="TJ" value="7">Tajikstan (+7)</option>
						<option data-countryCode="TH" value="66">Thailand (+66)</option>
						<option data-countryCode="TG" value="228">Togo (+228)</option>
						<option data-countryCode="TO" value="676">Tonga (+676)</option>
						<option data-countryCode="TT" value="1868">Trinidad &amp; Tobago (+1868)</option>
						<option data-countryCode="TN" value="216">Tunisia (+216)</option>
						<option data-countryCode="TR" value="90">Turkey (+90)</option>
						<option data-countryCode="TM" value="7">Turkmenistan (+7)</option>
						<option data-countryCode="TM" value="993">Turkmenistan (+993)</option>
						<option data-countryCode="TC" value="1649">Turks &amp; Caicos Islands (+1649)</option>
						<option data-countryCode="TV" value="688">Tuvalu (+688)</option>
						<option data-countryCode="UG" value="256">Uganda (+256)</option>
						<option data-countryCode="GB" value="44">UK (+44)</option>
						<option data-countryCode="UA" value="380">Ukraine (+380)</option>
						<option data-countryCode="AE" value="971">United Arab Emirates (+971)</option>
						<option data-countryCode="UY" value="598">Uruguay (+598)</option>
						<!-- <option data-countryCode="US" value="1">USA (+1)</option> -->
						<option data-countryCode="UZ" value="7">Uzbekistan (+7)</option>
						<option data-countryCode="VU" value="678">Vanuatu (+678)</option>
						<option data-countryCode="VA" value="379">Vatican City (+379)</option>
						<option data-countryCode="VE" value="58">Venezuela (+58)</option>
						<option data-countryCode="VN" value="84">Vietnam (+84)</option>
						<option data-countryCode="VG" value="84">Virgin Islands - British (+1284)</option>
						<option data-countryCode="VI" value="84">Virgin Islands - US (+1340)</option>
						<option data-countryCode="WF" value="681">Wallis &amp; Futuna (+681)</option>
						<option data-countryCode="YE" value="969">Yemen (North)(+969)</option>
						<option data-countryCode="YE" value="967">Yemen (South)(+967)</option>
						<option data-countryCode="ZM" value="260">Zambia (+260)</option>
						<option data-countryCode="ZW" value="263">Zimbabwe (+263)</option>
					</optgroup>
				</select>
			</div>
		  </div>
			<div class="form-group">
				<label for="phone" class="col-sm-3 control-label">Phone <span class="reqLabel">*</span></label>
				<div class="col-sm-6">
				    <input type="tel" class="form-control" name="phone">
				</div>
			</div>
		    <h3 class="page-header">Aircraft</h3>
			<div class="form-group">
				<label for="reg" class="col-sm-3 control-label">Tail Number <span class="reqLabel">*</span></label>
				<div class="col-sm-6">
				    <input type="text" class="form-control upper" name="reg">
				</div>
			</div>
			<div class="form-group">
				<label for="actype" class="col-sm-3 control-label">Aircraft Type <span class="reqLabel">*</span></label>
				<div class="col-sm-6">
				    <input type="text" class="form-control" id="actype" name="actype_name" placeholder="Search by model, select from list">

				    <input type="hidden" name="actype" id="actype_id" value=''>
				</div>
			</div>
			<div class="form-group">
				<label for="callsign" class="col-sm-3 control-label">Callsign</label>
				<div class="col-sm-6">
				    <input type="text" class="form-control upper" name="callsign">
				</div>
			</div>
		    <h3 class="page-header">Flight Information</h3>
			<div class="form-group">
				<label for="origin" class="col-sm-3 control-label">Arrival From Airport <span class="reqLabel">*</span></label>
				<div class="col-sm-6">
				    <input type="text" class="form-control upper" name="arrFrom" placeholder="ICAO">
				</div>
			</div>
			<div class="form-group">
				<label for="destination" class="col-sm-3 control-label">Departure To Airport <span class="reqLabel">*</span></label>
				<div class="col-sm-6">
				    <input type="text" class="form-control upper" name="depTo" placeholder="ICAO">
				</div>
			</div>
			<div class="form-group">
				    <label for="arrival" id="arrival" class="col-sm-3 control-label">Estimated Arrival <span class="reqLabel">*</span></label>
				<div class="col-sm-6">
					<input type="text" class="form-control datepicker" name="arrival" placeholder="Select date & time">
				</div>
			</div>
		    <div class="form-group">
			    <label for="departure" class="col-sm-3 control-label">Estimated Departure <span class="reqLabel">*</span></label>
			    <div class="col-sm-6">
				    <input type="text" class="form-control datepicker" name="departure" placeholder="Select date & time">
			    </div>
		    </div>
		    <h3 class="page-header">Fuel</h3>
			<div class="form-group">
				<label for="fuel_type" class="col-sm-3 control-label">Fuel Type</label>
				<div class="col-sm-9">
					<cfoutput query="fuel">
					    <label class="radio-inline">
						    <input type="radio" name="fuel_type" value="#id#" data-rate="#rate#" data-type="#type#"> #type#
					    </label>
					</cfoutput>
					<label class="radio-inline">
						<input type="radio" name="fuel_type" value="" checked> None
					</label>
				</div>
			</div>
		    <div id="jetA_group" class="formHide">
			    <div class="form-group">
					<label for="fuel_prist" class="col-sm-3 control-label">Prist</label>
					<div class="col-sm-9">
					    <label class="radio-inline">
						    <input type="radio" name="fuel_prist" value="1"> Yes
					    </label>
					    <label class="radio-inline">
						    <input type="radio" name="fuel_prist" value="0" checked> No
					    </label>
					</div>
			    </div>
			    <div class="form-group">
				    <label for="fuel_contract" class="col-sm-3 control-label">Contract Fuel</label>
					<div class="col-sm-9">
					    <label class="radio-inline">
						    <input type="radio" name="fuel_contract" value="1"> Yes
					    </label>
					    <label class="radio-inline">
						    <input type="radio" name="fuel_contract" value="0" checked> No
					    </label>
					</div>
			    </div>
		    </div>
			<div class="form-group">
				<label for="gallons" class="col-sm-3 control-label">Fuel Volume</label>
				<div class="col-sm-6">
				    <input type="text" class="form-control" name="gallons" placeholder="Number of Gallons">
				</div>
			</div>

		    <h3 class="page-header">Services</h3>
			<div class="form-group">
				<label for="gpu" class="col-sm-3 control-label">Ground Power Unit</label>
				<div class="col-sm-6">
				    <input type="text" class="form-control" name="gpu" placeholder=".5 Hour Increments">
				</div>
			</div>
			<div class="form-group">
				<label for="jumpstart" class="col-sm-3 control-label">Jump Start</label>
				<div class="col-sm-9">
				    <label class="radio-inline">
					    <input type="radio" name="jumpstart" value="1"> Yes
				    </label>
				    <label class="radio-inline">
					    <input type="radio" name="jumpstart" value="0" checked> No
				    </label>
				</div>
			</div>
			<div class="form-group">
				<label for="lavatory" class="col-sm-3 control-label">Lavatory Service</label>
				<div class="col-sm-9">
				    <label class="radio-inline">
					    <input type="radio" name="lavatory" value="1"> Yes
				    </label>
				    <label class="radio-inline">
					    <input type="radio" name="lavatory" value="0" checked> No
				    </label>
				</div>
			</div>
			<div class="form-group">
				<label for="water" class="col-sm-3 control-label">Potable Water</label>
				<div class="col-sm-9">
				    <label class="radio-inline">
					    <input type="radio" name="water" value="1"> Yes
				    </label>
				    <label class="radio-inline">
					    <input type="radio" name="water" value="0" checked> No
				    </label>
				</div>
			</div>
			<div class="form-group">
				<label for="oxygen" class="col-sm-3 control-label">Need Oxygen</label>
				<div class="col-sm-9">
				    <label class="radio-inline">
					    <input type="radio" name="oxygen" value="1"> Yes
				    </label>
				    <label class="radio-inline">
					    <input type="radio" name="oxygen" value="0" checked> No
				    </label>
				</div>
			</div>
			<div class="formHide" id="oxygen_sub">
				<div class="form-group input-sm">
				    <label for="ox_portable" class="col-sm-4 col-sm-offset-1 control-label">Portable Oxygen Bottles</label>
				    <div class="col-sm-4">
					    <input type="text" class="form-control" name="ox_portable" placeholder="Quantity">
				    </div>
				</div>
				<div class="form-group input-sm">
				    <label for="ox_fixed" class="col-sm-4 col-sm-offset-1 control-label">Fixed Oxygen Bottles</label>
				    <div class="col-sm-4">
					    <input type="text" class="form-control" name="ox_fixed" placeholder="Quantity">
				    </div>
				</div>
				<div class="form-group input-sm">
				    <label for="ox_large" class="col-sm-4 col-sm-offset-1 control-label">Large Cabin Oxygen Bottles</label>
				    <div class="col-sm-4">
					    <input type="text" class="form-control" name="ox_large" placeholder="Quantity">
				    </div>
				</div>
			</div>

		    <h3 class="page-header">Comments</h3>
		    <div class="form-group">
			    <div class="col-sm-9">
				    <textarea rows="3" name="notes" class="form-control"></textarea>
			    </div>
		    </div>
			<div id="">
			    <div class="well" id="fee_container">
					<!--- <cfif cgi.REMOTE_ADDR EQ '110.39.156.90'> --->
					    <h3 class="page-header">Fees, Costs and Incentives</h3>
						<div id="estContainer">
							<div class="estHide" id="GroupEventFee">
							    <h4></h4>
							    <p>
								    <span id="text_eventEst"></span>
								    <b id="text_eventDesc"></b>
							    </p>
							</div>

							<div class="estHide" id="group_park">
							    <h4></h4>
							    <p>
								    <b id="text_parkEst"></b>
								    <span id="text_parkDesc"></span>
							    </p>
							</div>
							<div class="estHide" id="group_fuel">
							    <h4>Fuel Price Estimate</h4>
							    <p>
									<b id="text_fuelEst"></b><span id="text_fuelDesc"></span>
									<span class="estHide" id="text_prist"><br>($0.07 added per gallon for Prist)</span>
									<span class="estHide" id="text_discount"><br>($0.90 discount per gallon for purchase of 3000 gallons or more)</span>
							    </p>
							</div>
							<div class="estHide" id="group_svc">
							    <h4>Other Services</h4>
								<div class="estHide" id="gpuWrap"><b id="text_gpuEst"></b> - Ground Power Unit (Duration of <span id="text_gpuHrs"></span> at $25 each 1/2 hour)</div>
								<div class="estHide" id="jumpstartEst"><b>$20.00</b> - GPU Jump Start</div>
								<div class="estHide" id="lavatoryEst"><b>$50.00</b> - Lavatory Service</div>
								<div class="estHide" id="ox_portableWrap"><b id="text_ox_portableEst"></b> - Portable Oxygen Bottles (Quantity of <span id="text_ox_portableQuant"></span> at $90 each)</div>
								<div class="estHide" id="ox_fixedWrap"><b id="text_ox_fixedEst"></b> - Fixed Oxygen Bottles (Quantity of <span id="text_ox_fixedQuant"></span> at $150 each)</div>
								<div class="estHide" id="ox_largeWrap"><b id="text_ox_largeEst"></b> - Large Cabin Oxygen Bottles (Quantity of <span id="text_ox_largeQuant"></span> at $150 each)</div>
							</div>
						</div>
						<div id="grandTotal">
						    <h4>Estimated Total:</h4>
						    <b>$0.00</b>
						</div>
					<!--- <cfelse>
						<h4>Fee Estimator temporarily unavailable. Please click the link for current rates & charges</h4>
						<a href="https://fsweb.harryreidairport.com/fswebfile/af8c9c31-ae72-44b6-9da1-5386293ea46b/1402484/HND_VGT_Rates.pdf" target="_blank">View Rates & Charges</a>
					</cfif> --->
			    </div>
			</div>

            <div class="g-recaptcha" data-sitekey="6LdXicIrAAAAAKHJzEElz2yS228lEraV0XuUePn0"></div>


		    <input type="submit" class="btn btn-lg btn-primary">
		    <hr>
	    </form>
	</div>
	
</div>


<script type="text/javascript">

	$(document).ready(function() {
	  $(window).keydown(function(event){
		if(event.keyCode == 13) {
		  event.preventDefault();
		  return false;
		}
	  });
	});

	$(function() {

	    var now = new Date();
	    now.setDate(now.getDate() - 1);

		jQuery.validator.addMethod("minDate", function (value, element) {
			var myDate = new Date(value);
			return this.optional(element) || myDate > now;
		});

	    jQuery.validator.addMethod("greaterThan", 
		function(value, element, params) {

			if (!/Invalid|NaN/.test(new Date(value))) {
				return new Date(value) > new Date($(params).val());
			}

			return isNaN(value) && isNaN($(params).val()) 
				|| (Number(value) > Number($(params).val())); 
		},'Must be greater than {0}.');

		$('.datepicker').datetimepicker({
			pickTime: true,
			format : 'MM/DD/YYYY HH:mm',
			minDate: new Date()
		});

	    $('input[name="oxygen"]').change(function() {
		    $('#oxygen_sub').toggle();
	    });

	    // $('#fee_container').affix({
		// offset: {
		//   top: 0,
		//   bottom: 0
		// }
	    // });

	    // // Fix width of fees container when affixed.
	    // $(window).on("resize scroll", function () {
		//   $('#fee_container.affix-top').width($('#fee_col').width() - 40);
		//   $('#fee_container.affix').width($('#fee_col').width() - 40);
	    // });

		function pluralize(word, count) {
			result = (count > 1) ?
			  word + 's' :
			  word;
			return result;
		}

	    $.validator.addMethod("halfIncrements", function(value, element) {
			return this.optional(element) || (2*value==2*value>>0);
		}, "Please use half hour increments");



		jQuery.validator.addMethod("check_date", function(value, element) {
		  var arrival = new Date($("input[name='arrival']").val());
		  var departure = new Date(value);

		  // Ensure valid date objects
		  if (isNaN(arrival.getTime()) || isNaN(departure.getTime())) {
			return false; // Invalid dates
		  }

		  return departure > arrival; // Departure must be after arrival
		}, 'Departure time must be after Arrival');



	    $.validator.addMethod('emailtld', function(val, elem){
			var filter = /^([a-zA-Z0-9_\.\-])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;

			if(!filter.test(val)) {
				return false;
			} else {
				return true;
			}
		}, '*');
	  
	    $.validator.addMethod("alphaNum", function(value, element) {
			return this.optional(element) || /^[^\W_]+$/i.test(value);
		}, "Please enter only letters and numbers.");

		// custom validator for actype + actype_name
		$.validator.addMethod("validAircraftType", function (value, element) {
		    var hiddenVal = $("#actype_id").val().trim();  // hidden field value
		    return hiddenVal.length > 0; // must have a selected ID
		}, "Aircraft Type is required. Please select a valid option from the list.");

		$("#res_form").validate({
			//debug: true,
			ignore: [],
			rules: {
				gpu: { 
					halfIncrements: true 
				},
				first_name: "required",
				last_name: "required",
				reg: {
					required: true,
					alphaNum: true,
					minlength: 2,
					maxlength: 7
				},
				actype_name: {
		            validAircraftType: true  // ✅ single validation for both
		        },
				origin: "required",
				arrFrom: {
					required: true,
					maxlength: 4
				},
				depTo: {
					required: true,
					maxlength: 4
				},
				email: {
					required: true,
					emailtld: true
				},
				emailConf: {
					equalTo: "#email"
				},
				phone: {
					required: true,
					//phoneUS: true
				},
				arrival: {
					required: true,
					minDate: true
				},
				departure: {
					required: true,
					minDate: true,
					check_date: true
				},
				ox_portable: {
					digits: true
				},
				ox_fixed: {
					digits: true
				},
				ox_large: {
					digits: true
				}
			},
			messages: {
			    firstname: "Please enter your first name.",
			    lastname: "Please enter your last name.",
			    email: "Please enter a valid email address.",
			    arrFrom: "Please enter airport ICAO code (i.e. KJFK)",
			    depTo: "Please enter airport ICAO code (i.e. KJFK)"
			    //phone: "Please enter a valid phone number."
			}
		});

        <!---<cfif cgi.REMOTE_ADDR EQ '110.39.156.90'>--->
	        function parkingCalc(arr, dep, sqft, fuel = 0, type = 'transient') {

				var nights, msg, rate_txt, heading;

				duration = Math.ceil(Math.abs(dep - arr) / (1000 * 60 * 60));
				duration_days = Math.floor(duration / 24);
				duration_hrs = Math.floor(duration % 24);
				duration_txt = '(Duration of ';

				if ( duration_days > 0 ) {
				    duration_txt = duration_txt + duration_days + pluralize(' day', duration_days);
				}

				if ( duration_days > 0 && duration_hrs > 0 ) {
				    duration_txt = duration_txt + ', ';
				}

				if ( duration_hrs > 0 ) {
				    duration_txt = duration_txt + duration_hrs + pluralize(' hour', duration_hrs);
				}

				heading = ( duration <= 6 ) ?
				  'Ramp Use <small>(6 hours max)</small>' :
				  'Transient Parking';

				if (type === 'transient') {
					if (duration <= 6) {
					    //  Less than or equal to 6 hours
					    if (sqft < 1250) {
						    if (fuel >= 20) {
						        var pTotal = 0;
						        rate_txt = '($22 waived with fuel purchase of 20+ gallons)';
						    } else {
						        var pTotal = 22;
						        rate_txt = '(Waived with fuel purchase of 20+ gallons)';
						    }
					    } else if (sqft < 2000) {
						    if (fuel >= 30) {
						        var pTotal = 0;
						        rate_txt = '($33 waived with fuel purchase of 30+ gallons)';
						    } else {
						        var pTotal = 33;
						        rate_txt = '(Waived with fuel purchase of 30+ gallons)';
						    }
					    } else if (sqft < 3500) {
						    if (fuel >= 40) {
						        var pTotal = 0;
						        rate_txt = '($66 waived with fuel purchase of 40+ gallons)';
						    } else {
						        var pTotal = 66;
						        rate_txt = '(Waived with fuel purchase of 40+ gallons)';
						    }
					    } else if (sqft < 6000) {
						    if (fuel >= 50) {
						        var pTotal = 0;
						        rate_txt = '($82.50 waived with fuel purchase of 50+ gallons)';
						    } else {
						        var pTotal = 82.5;
						        rate_txt = '(Waived with fuel purchase of 50+ gallons)';
						    }
					    } else if (sqft < 9000) {
						    if (fuel >= 200) {
						        var pTotal = 0;
						        rate_txt = '($150 waived with fuel purchase of 200+ gallons)';
						    } else {
						        var pTotal = 150;
						        rate_txt = '(Waived with fuel purchase of 200+ gallons)';
						    }
					    } else {
						    if (fuel >= 300) {
						        var pTotal = 0;
						        rate_txt = '($250 waived with fuel purchase of 300+ gallons)';
						    } else {
						        var pTotal = 250;
						        rate_txt = '(Waived with fuel purchase of 300+ gallons)';
						    }
					    }
					}

					  //  Between 6 and 24 hours
					else if (duration > 6 && duration <= 24) {
					    if (sqft < 1250) {
						    if (fuel >= 20) {
						        var pTotal = 0;
						        rate_txt = '($22 waived with fuel purchase of 20+ gallons)';
						    } else {
						        var pTotal = 22;
						        rate_txt = '(Waived with fuel purchase of 20+ gallons)';
						    }
					    } else if (sqft < 2000) {
						    if (fuel >= 150) {
						        var pTotal = 0;
						        rate_txt = '(Waived with fuel purchase of 150+ gallons)';
						    } else if (fuel >= 50) {
						        var pTotal = 27.5;
						        rate_txt = '($27.50 discounted with 50+ gallons)';
						    } else {
						        var pTotal = 55;
						        rate_txt = '($55 without fuel discount)';
						    }
					    } else if (sqft < 3500) {
						    if (fuel >= 250) {
						        var pTotal = 0;
						        rate_txt = '(Waived with fuel purchase of 250+ gallons)';
						    } else if (fuel >= 50) {
						        var pTotal = 55;
						        rate_txt = '($55 discounted with 50+ gallons)';
						    } else {
						        var pTotal = 110;
						        rate_txt = '($110 without fuel discount)';
						    }
					    } else if (sqft < 6000) {
						    if (fuel >= 300) {
						        var pTotal = 0;
						        rate_txt = '(Waived with fuel purchase of 300+ gallons)';
						    } else if (fuel >= 75) {
						        var pTotal = 82.5;
						        rate_txt = '($82.50 discounted with 75+ gallons)';
						    } else {
						        var pTotal = 165;
						        rate_txt = '($165 without fuel discount)';
						    }
					    } else if (sqft < 9000) {
						    if (fuel >= 300) {
						        var pTotal = 0;
						        rate_txt = '(Waived with fuel purchase of 300+ gallons)';
						    } else if (fuel >= 100) {
						        var pTotal = 150;
						        rate_txt = '($150 discounted with 100+ gallons)';
						    } else {
						        var pTotal = 300;
						        rate_txt = '($300 without fuel discount)';
						    }
					    } else {
						    if (fuel >= 400) {
						        var pTotal = 0;
						        rate_txt = '(Waived with fuel purchase of 400+ gallons)';
						    } else if (fuel >= 200) {
						        var pTotal = 300;
						        rate_txt = '($200 discount of $500 with 200+ gallons)';
						    } else {
						        var pTotal = 500;
						        rate_txt = '($500 without fuel discount)';
						    }
					    }
					}

					// More than 24 hours (discount only on first night)
					else {
					    let baseRate = 0;
					    let discountRate = 0;
					    let nights = Math.ceil(duration / 24);

					    // Get base rate per night based on sqft
					    if (sqft < 1250) baseRate = 22;
					    else if (sqft < 2000) baseRate = 55;
					    else if (sqft < 3500) baseRate = 110;
					    else if (sqft < 6000) baseRate = 165;
					    else if (sqft < 9000) baseRate = 300;
					    else baseRate = 500;
                        
                        discountRate = baseRate;
                        rate_txt = '(without fuel discount)';
					    // Apply fuel-based discount only for first night
					    if (sqft < 1250) {
					        if (fuel >= 20) {
					            discountRate = 0;
					            rate_txt = '(First night waived with 20+ gallons of fuel)';
					        }
					    } else if (sqft < 2000) {
					        if (fuel >= 150) {
					            discountRate = 0;
					            rate_txt = '(First night waived with 150+ gallons of fuel)';
					        } else if (fuel >= 50) {
					            discountRate = 27.5;
					            rate_txt = '(First night $27.50 discount with 50+ gallons)';
					        }
					    } else if (sqft < 3500) {
					        if (fuel >= 250) {
					            discountRate = 0;
					            rate_txt = '(First night waived with 250+ gallons of fuel)';
					        } else if (fuel >= 50) {
					            discountRate = 55;
					            rate_txt = '(First night $55 discount with 50+ gallons)';
					        }
					    } else if (sqft < 6000) {
					        if (fuel >= 300) {
					            discountRate = 0;
					            rate_txt = '(First night waived with 300+ gallons of fuel)';
					        } else if (fuel >= 75) {
					            discountRate = 82.5;
					            rate_txt = '(First night $82.50 discount with 75+ gallons)';
					        }
					    } else if (sqft < 9000) {
					        if (fuel >= 300) {
					            discountRate = 0;
					            rate_txt = '(First night waived with 300+ gallons of fuel)';
					        } else if (fuel >= 100) {
					            discountRate = 150;
					            rate_txt = '(First night $150 discount with 100+ gallons)';
					        }
					    } else {
					        if (fuel >= 400) {
					            discountRate = 0;
					            rate_txt = '(First night waived with 400+ gallons of fuel)';
					        } else if (fuel >= 200) {
					            discountRate = 300;
					            rate_txt = '(First night $200 discount with 200+ gallons of fuel)';
					        }
					    }

					    //  Apply discount to first night only
					    if (nights > 1) {
					        pTotal = discountRate + baseRate * (nights - 1);
					    } else {
					        pTotal = discountRate;
					    }

					    rate_txt = `$${(baseRate)} per night. ${rate_txt}`;
					    console.log(discountRate);
					}
					console.log('test111');
					console.log(rate_txt);

			    }
			    msg = `${duration_txt} ${rate_txt})`;
                return { pTotal, msg, heading };
			}

        <!---<cfelse>
	        function parkingCalc(arr, dep, pGrp, fuel = 0) {
				var nights, msg, rate_txt, heading;

				duration = Math.ceil(Math.abs(dep - arr) / (1000 * 60 * 60));
				duration_days = Math.floor(duration / 24);
				duration_hrs = Math.floor(duration % 24);
				duration_txt = '(Duration of ';

				if ( duration_days > 0 ) {
				    duration_txt = duration_txt + duration_days + pluralize(' day', duration_days);
				}

				if ( duration_days > 0 && duration_hrs > 0 ) {
				    duration_txt = duration_txt + ', ';
				}

				if ( duration_hrs > 0 ) {
				    duration_txt = duration_txt + duration_hrs + pluralize(' hour', duration_hrs);
				}

				heading = ( duration <= 6 ) ?
				  'Ramp Use <small>(6 hours max)</small>' :
				  'Transient Parking';
				
				switch( pGrp ) {
					case '1S':
						if ( duration <= 6 ) {
							if ( fuel >= 20 ) {
								var pTotal = 0;
								rate_txt = '($20 waived with fuel purchase of 20+ gallons)';
							} else {
								var pTotal = 20;
								rate_txt = '(Waived with fuel purchase of 20+ gallons)';
							}
						} else {
							nights = Math.ceil(duration / 24);

							rate_txt = '$20 per night. First night waived with fuel purchase of 20+ gallons.';

							if ( fuel >= 20 ) {
								nights = nights - 1;
							}

							var pTotal = nights * 20;
						}
					break;
				    case '1M':
						if ( duration <= 6 ) {
							if ( fuel >= 30 ) {
								var pTotal = 0;
								rate_txt = '($30 waived with fuel purchase of 30+ gallons)';
							} else {
								var pTotal = 30;
								rate_txt = '(Waived with fuel purchase of 30+ gallons)';
							}
						} else {
						    nights = Math.ceil(duration / 24);

						    if ( fuel >= 100 ) {
							    nights = nights - 1;
							    rate_txt = '$50 per night. First night waived with fuel purchase of 50+ gallons.';
						    } else {
							    rate_txt = '$50 per night. $15 discount on first night with fuel purchase of 50+ gallons.';
						    }

						    if ( fuel > 49 && fuel < 100 ) {
							    nights = nights - 0.3;
						    }

						    var pTotal = nights * 50;
						}
					break;
				    case '2':
						if ( duration <= 6 ) {
						    if ( fuel >= 40 ) {
							    var pTotal = 0;
							    rate_txt = '($60 waived with fuel purchase of 40+ gallons)';
						    } else {
							    var pTotal = 60;
							    rate_txt = '(Waived with fuel purchase of 40+ gallons)';
						    }
						} else {
						    nights = Math.ceil(duration / 24);

						    if ( fuel >= 250 ) {
							    nights = nights - 1;
							    rate_txt = '$100 per night. First night waived with fuel purchase of 250+ gallons.';
						    } else {
							    rate_txt = '$100 per night. $20 discount on first night with fuel purchase of 100+ gallons.';
						    }

						    if ( fuel > 99 && fuel < 250 ) {
							    nights = nights - 0.2;
						    }

						    var pTotal = nights * 100;
						}
					break;
					case '3':
						if ( duration <= 6 ) {
							if ( fuel >= 50 ) {
								var pTotal = 0;
								rate_txt = '($75 waived with fuel purchase of 50+ gallons)';
							} else {
								var pTotal = 75;
								rate_txt = '(waived with fuel purchase of 50+ gallons)';
							}
						} else {
						    nights = Math.ceil(duration / 24);

							if ( fuel >= 300 ) {
								nights = nights - 1;
								rate_txt = '$150 per night. First night waived with fuel purchase of 300+ gallons.';
							} else {
								rate_txt = '$150 per night. $35 discount on first night with fuel purchase of 75+ gallons.';
							}

							var pTotal = nights * 150;

							if ( fuel > 74 && fuel < 300 ) {
								var pTotal = pTotal - 35;
							}
						}
					break;
				}

				msg = duration_txt + ') ' + rate_txt;

				if ( typeof pTotal !== "undefined" ) {

				    return { pTotal, msg, heading };
				} else {
				    return;
				}
			}
        </cfif>--->
	    // Calculate parking cost
		

	    var parkingSelected;
	    var parkingsqft;

		// On page load, initialize event fee storage
		$('#GroupEventFee').data("fee", 0);

		// Event Fee calculation
		$('input[name="actype"], input[name="arrival"], input[name="departure"]').change(function () {
		    let actype = parseFloat($('input[name="actype"]').val());
		    let arrival = new Date($('input[name="arrival"]').val());
		    let departure = new Date($('input[name="departure"]').val());

		    calculateEventFee(actype, arrival, departure);
		});

		function calculateEventFee(actype, arrival, departure) {
		    if (actype && arrival < departure) {
                let formatDateTime = (date) => {
				    let pad = (n) => n < 10 ? '0' + n : n;
				    return date.getFullYear() + '-' +
				           pad(date.getMonth() + 1) + '-' +
				           pad(date.getDate()) + ' ' +
				           pad(date.getHours()) + ':' +
				           pad(date.getMinutes()) + ':' +
				           pad(date.getSeconds());
				};

				let arrivalISO = formatDateTime(arrival);
				let departureISO = formatDateTime(departure);

		        $.ajax({
		            url: "ccdoaForm.cfc?method=getEventFee",
		            type: "POST",
		            dataType: "json",
		            data: {
		                actype: actype,
		                arrival: arrivalISO,
		                departure: departureISO,
		                location: '<cfoutput>#iata#</cfoutput>'
		            },
		            success: function (response) {
		                if (response.SUCCESS === true && response.EVENTFEE != '') {
		                    $('#GroupEventFee h4').html('Event Name:' +response.EVENTNAME);
		                    $('#text_eventEst').html('Event Fee:');
		                    $('#text_eventDesc').html((response.EVENTFEE).toLocaleString('en-US', {
							    style: 'currency',
							    currency: 'USD',
						    }));

					        $('#GroupEventFee').data("fee", parseFloat(response.EVENTFEE));
		                    $('#GroupEventFee').show();
		                } else {
		                	$('#GroupEventFee h4').html('');
		                    $('#text_eventEst').html('');
		                    $('#text_eventDesc').html('');

		                    $('#GroupEventFee').data("fee", 0);
		                    $('#GroupEventFee').hide();
		                }
		                renderGrandTotal(); // ensure fee gets added
		            },
		            error: function (xhr, status, error) {
		                console.error("Error: " + error);
		            }
		        });
		    } else {
		        $('#GroupEventFee').data("fee", 0).hide();
		        renderGrandTotal();
		    }
		}


		function renderGrandTotal() {
		    const eventFee = Number($('#GroupEventFee').data("fee")) || 0;
		    const total = Number(grandTotal) + eventFee;

		    $('#grandTotal b').html(total.toLocaleString('en-US', {
		        style: 'currency',
		        currency: 'USD',
		    }));

		    $('input[name="grandTotal"]').val(total.toFixed(2));

		    // Save estimate text too
		    var estText = $("#estContainer").html();
		    $('input[name="estText"]').val("<![CDATA[" + estText + "]]>");
		}


		$("#res_form :input").change(function() {
			
			grandTotal = 0;

			// Flight fields
			actype = parseFloat($('input[name="actype"]').val());
			let actype_name = $('input[name="actype_name"]').val().trim();
			arrival = new Date($('input[name="arrival"]').val());
			departure = new Date($('input[name="departure"]').val());

			// Fuel fields
			fuel = $('input[name="fuel_type"]:checked');

			fuelRate = fuel.data("rate");
			fuelType = fuel.data("type");
			fuelVol = $('input[name="gallons"]').val().replace(/,/, '');
			if (fuel.val() === '') {
			    fuelVol = 0; // force it to zero if None is selected
			}
			fuelPrist = $('input[name="fuel_prist"]:checked').val();

			// Service fields
			gpu = parseFloat($('input[name="gpu"]').val());
			jumpstart = $('input[name="jumpstart"]:checked').val();
			lavatory = $('input[name="lavatory"]:checked').val();
			water = $('input[name="water"]:checked').val();
			oxygen = $('input[name="oxygen"]:checked').val();
			ox_portable = parseFloat($('input[name="ox_portable"]').val());
			ox_fixed = parseFloat($('input[name="ox_fixed"]').val());
			ox_large = parseFloat($('input[name="ox_large"]').val());

			if ( parkingSelected && arrival < departure ) {
			    <!---<cfif cgi.REMOTE_ADDR EQ '110.39.156.90'> --->
			    parkingEst = parkingCalc(arrival, departure, parkingsqft, fuelVol,type='transient');
			    <!---<cfelse>
			     parkingEst = parkingCalc(arrival, departure, parkingSelected, fuelVol);
			    </cfif>--->

			    $('#group_park h4').html(parkingEst.heading);
			  
			    $('#text_parkEst').html((parkingEst.pTotal).toLocaleString('en-US', {
				    style: 'currency',
				    currency: 'USD',
			    }));

			    $('#text_parkDesc').html(' ' + parkingEst.msg);

			    grandTotal += parkingEst.pTotal;

			    $('#group_park').show();
			} else {
			    $('#group_park').hide();
			}

			if ( fuelVol > 2999 ) {
			    fuelRate = fuelRate - 0.90;
			    $('#text_discount').show();
			} else {
			    $('#text_discount').hide();
			}

			if ( fuelRate && fuelVol > 0 ) {
			    fuelEst = Number(fuelVol) * fuelRate;

				if ( fuelPrist == 1 ) {
					fuelEst += Number(fuelVol) * 0.07;
					$('#text_prist').show();
				} else {
					$('#text_prist').hide();
				}

			    $('#text_fuelEst').html((fuelEst).toLocaleString('en-US', {
				    style: 'currency',
				    currency: 'USD',
			    }));

			    $('#text_fuelDesc').html(' - ' + fuelType + ' (' + fuelVol + ' gallons at $' + fuel.data("rate") + ' per gallon)');

			    grandTotal += fuelEst;

			    $('#group_fuel').show();
			} else {
			    $('#group_fuel').hide();
			    $('input[name="gallons"]').val('');
			}

			if ( fuelType == 'JetA' ) {
			  $('#jetA_group').show();
			} else {
			  $('#jetA_group').hide();
			}

			if ( gpu > 0 ) {
			    gpuEst = gpu * 50;

			    $('#text_gpuEst').html((gpuEst).toLocaleString('en-US', {
				    style: 'currency',
				    currency: 'USD',
			    }));

				if ( gpu > 1 ) {
					$('#text_gpuHrs').html(gpu + ' hours');
				} else {
					$('#text_gpuHrs').html(gpu + ' hour');
				}

			    grandTotal += gpuEst;

			    $('#gpuWrap').show();
			} else {
			    $('#gpuWrap').hide();
			}

			if ( jumpstart == 1 ) 
		    {      
		    	grandTotal += 20;

			    $('#jumpstartEst').show();
			} else {
			    $('#jumpstartEst').hide();
			}

			if ( lavatory == 1 ) {
			  grandTotal += 50;

			  $('#lavatoryEst').show();
			} else {
			  $('#lavatoryEst').hide();
			}

			if ( oxygen == 1 ) {
				if ( ox_portable > 0 ) {
					ox_portableEst = ox_portable * 90;

					$('#text_ox_portableEst').html((ox_portableEst).toLocaleString('en-US', {
					  style: 'currency',
					  currency: 'USD',
					}));

					$('#text_ox_portableQuant').html(ox_portable);

					grandTotal += ox_portableEst;

					$('#ox_portableWrap').show();
				} else {
					$('#ox_portableWrap').hide();
				}

				if ( ox_fixed > 0 ) {
					ox_fixedEst = ox_fixed * 150;

					$('#text_ox_fixedEst').html((ox_fixedEst).toLocaleString('en-US', {
					  style: 'currency',
					  currency: 'USD',
					}));

					$('#text_ox_fixedQuant').html(ox_fixed);

					grandTotal += ox_fixedEst;

					$('#ox_fixedWrap').show();
				} else {
					$('#ox_fixedWrap').hide();
				}

				if ( ox_large > 0 ) {
					ox_largeEst = ox_large * 150;

					$('#text_ox_largeEst').html((ox_largeEst).toLocaleString('en-US', {
					  style: 'currency',
					  currency: 'USD',
					}));

					$('#text_ox_largeQuant').html(ox_large);

					grandTotal += ox_largeEst;

					$('#ox_largeWrap').show();
				} else {
					$('#ox_largeWrap').hide();
				}
			}

			if(actype_name == ''){

				$('#actype_id').val('');
			}


			// Service section visibility
			if ( gpu > 0 || jumpstart == 1 || lavatory == 1 || oxygen == 1 ) { $('#group_svc').show(); } else { $('#group_svc').hide(); }

            renderGrandTotal();

			var estText = $("#estContainer").html();
			$('input[name="estText"]').val("<![CDATA[" + estText + "]]>");

		});

	    $.widget('custom.mcautocomplete', $.ui.autocomplete, {
			_create: function () {
				this._super();
				this.widget().menu("option", "items", "> :not(.ui-widget-header)");
			},
			_renderMenu: function (ul, items) {
				var self = this,
					thead;
				if (this.options.showHeader) {
					table = $('<div class="ui-widget-header" style="width:100%; border:none; border-bottom:1px solid #999"></div>');
					$.each(this.options.columns, function (index, item) {
						table.append('<span style="padding:4px 0 3px 8px;float:left;width:' + item.width + ';">' + item.name + '</span>');
					});
					table.append('<div style="clear: both;"></div>');
					ul.append(table);
				}
				$.each(items, function (index, item) {
					self._renderItem(ul, item);
				});
			},
			_renderItem: function (ul, item) {
				var t = '',
					result = '';
				$.each(this.options.columns, function (index, column) {
					t += '<span style="padding:0 4px;float:left;width:' + column.width + ';">' + item[column.valueField ? column.valueField : index] + '</span>'
				});
				result = $('<li></li>')
					.data('ui-autocomplete-item', item)
					.append('<a class="mcacAnchor">' + t + '<div style="clear: both;"></div></a>')
					.appendTo(ul);
				return result;
			}
		});
	    $("#actype").mcautocomplete({
			showHeader: true,
			columns: [{
				name: 'Make',
				width: '150px',
				valueField: 'make'
			}, {
				name: 'Model',
				width: '180px',
				valueField: 'model'
			}/*, {
			  name: 'Parking Group',
				width: '180px',
				valueField: 'parking'
			}*/],
			select: function (event, ui) {
			    this.value = (ui.item ? ui.item.make + ' ' + ui.item.model : '');
			    $('#actype_id').val(ui.item ? ui.item.id : '')
			    parkingSelected = ui.item.parking;
			    parkingsqft = ui.item.sqft;
			    console.log(ui.item)

			    $(this).trigger('change');

			    return false;
			},
			minLength: 1,
			delay: 0,
			source: "/ac_search.cfm"
	    });

	});
    
    $("#res_form").on("submit", function (e) {
	    e.preventDefault(); // stop default submit

	    var form = this; // keep reference to form

	    // 1️⃣ Validate fields with jQuery Validation
	    if (!$(form).valid()) {
	        return false; // if invalid fields, stop
	    }

	    // 2️⃣ Check reCAPTCHA client side
	    var response = grecaptcha.getResponse();
	    if (response.length === 0) {

	    	Swal.fire({
				icon: "error",
				title: 'Captcha Required',
				text: "Please complete the reCAPTCHA before submitting.",
				buttonsStyling: false,
				confirmButtonText: "Ok!",
				customClass: {
				confirmButton: "btn font-weight-bold btn-light-primary"
				}
			});
	        return false;
	    }

	    // 3️⃣ Call CFC to verify reCAPTCHA
	    $.ajax({
	        url: "ccdoaForm.cfc?method=submitrecaptcha",
	        type: "POST",
	        dataType: "json",
	        data: { "g-recaptcha-response": response }, // only send captcha
	        success: function (res) {
	            if (res.success) {
	                // ✅ reCAPTCHA OK → submit form normally
	                form.submit();
	            } else {
	            	Swal.fire({
						icon: "error",
						title: 'Captcha Failed',
						text: res.message || 'reCAPTCHA verification failed.',
						buttonsStyling: false,
						confirmButtonText: "Ok!",
						customClass: {
						confirmButton: "btn font-weight-bold btn-light-primary"
						}
					});
	                grecaptcha.reset(); // reset reCAPTCHA for retry
	            }
	        },
	        error: function () {
	        	Swal.fire({
					icon: "error",
					title: 'Server Error',
					text: 'Something went wrong. Please try again later.',
					buttonsStyling: false,
					confirmButtonText: "Ok!",
					customClass: {
					confirmButton: "btn font-weight-bold btn-light-primary"
					}
				});
	        }
	    });
	});
    
    $('input[name="fuel_type"]').on('change', function() {
	    const selectedValue = $(this).val();
	    if (selectedValue === '') {
	        $('input[name="gallons"]').val(''); // clear the gallons field
	    }
	});


</script>


<cfinclude template="/footer.cfm">
