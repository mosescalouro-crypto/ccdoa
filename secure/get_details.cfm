<cfif!isDefined("url.id")>
	<cfthrow>
</cfif>

<cfquery datasource="CCDOA" name="results">
	SELECT 
		r.id res_id, 
		status,
		confirmation,
		conf_no,
		reg, 
		name,
		email,
		phone,
		arrival,
		departure,
		arrFrom,
		depTo,
		locationid,
		actype,
		a.make ac_make,
		a.model ac_model,
		CASE 
			WHEN a.sqft <= 1250 THEN '1S'
			WHEN a.sqft BETWEEN 1251 AND 1999 THEN '1M'
			WHEN a.sqft BETWEEN 2000 AND 3499 THEN '2'
			WHEN a.sqft >= 3500 THEN '3' 
		END as ac_parking,
		f.type fuel,
		case WHEN f.rate != '' THEN f.rate ELSE 0 END as fuel_rate,
		<!---f.rate fuel_rate,--->
		fuel_gal,
		fuel_prist,
		fuel_contract,
		gpu_hours,
		jumpstart,
		CASE 
		    WHEN jumpstart IS NULL OR LTRIM(RTRIM(jumpstart)) = '' THEN 0
		    ELSE jumpstart
		END AS jumpstart,
		CASE 
		    WHEN lavatory IS NULL OR LTRIM(RTRIM(lavatory)) = '' THEN 0
		    ELSE lavatory
		END AS lavatory,
		CASE 
		    WHEN water IS NULL OR LTRIM(RTRIM(water)) = '' THEN 0
		    ELSE water
		END AS water,
		oxygen,
		ox_portable,
		ox_fixed,
		ox_large,
		CASE 
		    WHEN coffee IS NULL OR LTRIM(RTRIM(coffee)) = '' THEN 0
		    ELSE coffee
		END AS coffee,
		CASE 
		    WHEN ice IS NULL OR LTRIM(RTRIM(ice)) = '' THEN 0
		    ELSE ice
		END AS ice,
		CASE 
		    WHEN catering IS NULL OR LTRIM(RTRIM(catering)) = '' THEN 0
		    ELSE catering
		END AS catering,
		callsign,
		estTotal,
		estText,
		feePayment,
		CASE 
		    WHEN deleted IS NULL OR LTRIM(RTRIM(deleted)) = '' THEN 0
		    ELSE deleted
		END AS deleted,
		r.notes notes
	FROM reservations r
	LEFT JOIN aircraft a on r.ACType = a.id or actype=legacyid
	LEFT JOIN fuel f on r.fuel_type = f.id
	WHERE r.id = #url.id#
</cfquery>

<!--- <cfoutput>[#url.id#] [#results.ac_parking#]</cfoutput> --->
<cfset fee_col = "fee_" & results.ac_parking>

<cfquery datasource="CCDOA" name="event">
	SELECT 
		name,
		ppr,
		#fee_col# as fee,
		startDate,
		endDate,
		feeStartDate,
		feeEndDate,
		CASE
			WHEN feeStartDate <= '#results.departure#' AND feeEndDate >= '#results.arrival#'
			THEN 1
			ELSE 0
		END as chargeFee
	FROM events
	WHERE deleted = 0
	AND (startDate <= '#results.departure#' AND endDate >= '#results.arrival#')
	AND locationid = '#results.locationid#'
</cfquery>


<cfif isDefined("url.edit")>
	<style>
	#actype_dropdown {
	    position: absolute;
	    z-index: 1000;
	    background: #fff;
	    border: 1px solid #ccc;
	    display: none;
	    max-height: 200px;  /* maximum height */
	    overflow-y: auto;   /* vertical scroll if content exceeds max height */
	}
	.actype_option {
	    padding: 5px 10px;
	    cursor: pointer;
	}
	.actype_option:hover {
	    background-color: #f0f0f0; /* highlight on hover */
	}
	</style>
	<cfoutput query="results">
		<form class="form-horizontal" method="POST" id="res_edit">
	        <input type="hidden" name="res_id" value="#results.res_id#">
	        <h4 class="page-header" style="margin-top: 10px">User Information</h4>
	          <div class="form-group form-group-sm">
	            <label for="name" class="col-sm-3 control-label">Name</label>
	            <div class="col-sm-6">
	              <input type="text" class="form-control" name="name" placeholder="Last name, First name" value="#results.name#">
	            </div>
	          </div>
	          <div class="form-group form-group-sm">
	            <label for="email" class="col-sm-3 control-label">Email</label>
	            <div class="col-sm-6">
	              <input type="email" class="form-control" name="email" value="#results.email#">
	            </div>
	          </div>
	          <div class="form-group form-group-sm">
	            <label for="phone" class="col-sm-3 control-label">Phone</label>
	            <div class="col-sm-6">
	              <input type="tel" class="form-control" name="phone" value="#results.phone#">
	            </div>
	          </div>
	        <h4 class="page-header">Aircraft</h4>
	          <div class="form-group form-group-sm">
	            <label for="reg" class="col-sm-3 control-label">Tail Number</label>
	            <div class="col-sm-6">
	              <input type="text" class="form-control" name="reg" value="#results.reg#">
	            </div>
	          </div>
	          <div class="form-group form-group-sm">
	            <label for="actype" class="col-sm-3 control-label">Aircraft Type</label>
	            <div class="col-sm-6">
	              <!--- <input type="text" class="form-control" id="actype" name="actype_name" placeholder="Search by model, select from list" value="#results.ac_make#, #results.ac_model#">
	              <input type="hidden" name="actype" id="actype_id" value="#results.actype#"> --->
	                <input type="text" id="actype" class="form-control" placeholder="Search by model" autocomplete="off" value="#results.ac_make# #results.ac_model#">
					<input type="hidden" id="actype_id" name="actype" value="#results.actype#">

					<div id="actype_dropdown"></div>

	            </div>
	          </div>
	          <div class="form-group form-group-sm">
	            <label for="callsign" class="col-sm-3 control-label">Callsign</label>
	            <div class="col-sm-6">
	              <input type="text" class="form-control" name="callsign" value="#results.callsign#">
	            </div>
	          </div>
	        <h4 class="page-header">Flight Information</h4>
	          <div class="form-group form-group-sm">
	              <label for="locationid" class="col-sm-3 control-label">Airport</label>
	              <div class="col-sm-6">
	              	<select name="locationid" class="form-control">
	              		<option<cfif locationid eq 'LAS'> selected</cfif>>LAS</option>
	              		<option<cfif locationid eq 'VGT'> selected</cfif>>VGT</option>
	              		<option<cfif locationid eq 'HND'> selected</cfif>>HND</option>
	              	</select>
	              </div>
	          </div>
	          <div class="form-group form-group-sm">
	              <label for="arrival" id="arrival" class="col-sm-3 control-label">Estimated Arrival</label>
	              <div class="col-sm-6">
	                <input type="text" class="form-control datepicker" name="arrival" placeholder="Select date & time" value="#datetimeformat(results.arrival, 'mm/dd/yyyy HH:nn')#">
	              </div>
	          </div>
	          <div class="form-group form-group-sm">
	              <label for="departure" class="col-sm-3 control-label">Estimated Departure</label>
	              <div class="col-sm-6">
	                <input type="text" class="form-control datepicker" name="departure" placeholder="Select date & time" value="#datetimeformat(results.departure, 'mm/dd/yyyy HH:nn')#">
	              </div>
	          </div>
	          <input type="button" class="btn btn-lg btn-primary pull-right resEditFormBTN" value="Submit">
	          <br clear="both">
	     </form>
	</cfoutput>

<cfelse>
	<cfoutput query="results">
	  	<!--- Stay duration --->
	  	<!--- <cfset hours = DateDiff('h',arrival,departure)>
		<cfset stayDays = hours \ 24>
		<cfset stayHours = hours Mod 24> --->

		<div class="row">
			<div class="col-md-6">
				<div class="panel <cfif results.status NEQ ''>panel-success<cfelse>panel-danger</cfif>">
					<div class="panel-heading">
						<h3 class="panel-title">Schedule: <cfif results.confirmation eq 1>Reserved<cfelse>Wait-Listed</cfif></h3>
					</div>
					<table class="table">
		  				<tr>
		  					<td><i class="fa-solid fa-fw fa-plane-arrival"></i> Arrival from #results.arrFrom#:</td>
		  					<td>#datetimeformat(results.arrival)#</td>
		  				</tr>
		  				<tr>
		  					<td><i class="fa-solid fa-fw fa-plane-departure"></i> Departure to #results.depTo#:</td>
		  					<td>#datetimeformat(results.departure)#</td>
		  				</tr>
		  				<!---<tr>
		  					<td><i class="fa-regular fa-fw fa-clock"></i> Stay Duration:</td>
		  					<td>
		  						<cfif stayDays gt 0>
		 							#stayDays# day<cfif stayDays gt 1>s</cfif><cfif stayDays gt 0 AND stayHours gt 0>, </cfif>
		 						</cfif>
		 						<cfif stayHours gt 0>
		 							#stayHours# hrs
		 						</cfif>
		  					</td>
		  				</tr>--->
		  				<tr>
		  					<td <cfif results.status neq 0 AND (StructKeyExists(cookie, "admin") AND cookie.admin NEQ 3)> style="padding-top: 17px;"</cfif>><i class="fa-regular fa-fw fa-clock"></i> Flight Status:</td>
		  					<td>
		  						<cfif StructKeyExists(cookie, "admin") AND cookie.admin NEQ 3>
			  						<cfif results.status eq 0>
						  				Cancelled
						  			<cfelse>
							  			<select data-id="#res_id#" class="statusChange form-control form-control-sm" >
							  				<option value="1" <cfif results.status eq 1>selected</cfif>>Pending</option>
							  				<option value="2" <cfif results.status eq 2>selected</cfif>>Arrived</option>
							  				<option value="3" <cfif results.status eq 3>selected</cfif>>Departed</option>
							  			</select>
						  			</cfif>
						  		<cfelse>

						  			<cfif results.status eq 0>
						  				Cancelled
						  			<cfelseif results.status eq 1>
						  				Pending
						  			<cfelseif results.status eq 2>
						  				Arrived
						  			<cfelseif results.status eq 3>
						  				Departed
						  			</cfif>
						  		</cfif>
					  			<!--- &nbsp;&nbsp;&nbsp; --->
					  			<!--- <cfif status eq 1>
									<a href="javascript:void(0);" data-id="#res_id#" class="statusChange btn btn-xs btn-primary" ><i class="fa-solid fa-fw fa-plane-arrival"></i> Mark Arrived</a>
								<cfelseif status eq 2>
									<a href="javascript:void(0);" data-id="#res_id#"  class="statusChange btn btn-xs btn-primary" ><i class="fa-solid fa-fw fa-plane-departure"></i> Mark Departed</a>
								</cfif> --->
		  					</td>
		  				</tr>
		  			</table>
				</div>
			</div>
			<div class="col-md-6">
				<div class="panel panel-default">
					<div class="panel-heading">
						<h3 class="panel-title">
							<cfif StructKeyExists(cookie, "admin") AND cookie.admin NEQ 3>
								<button id="reSend" class="btn btn-primary btn-sm pull-right" data-id="#res_id#" type="button"><i class="fa-regular fa-paper-plane"></i> Re-Send</button>
							</cfif>
							Contact
						</h3>
					</div>
					<table class="table">
		  				<tr>
		  					<td><i class="fa-regular fa-fw fa-user"></i> Name:</td>
		  					<td>#results.name#</td>
		  				</tr>
		  				<tr>
		  					<td><i class="fa-regular fa-fw fa-at"></i> Email:</td>
		  					<td><a href="mailto:#email#">#results.email#</a></td>
		  				</tr>
		  				<tr>
		  					<td><i class="fa-solid fa-fw fa-phone"></i> Phone:</td>
		  					<td>#results.phone#</td>
		  				</tr>
		  			</table>
				</div>
			</div>
		</div>
		<div class="row">
			<div class="col-md-6">
				<div class="panel panel-default">
					<div class="panel-heading">
						<h3 class="panel-title">Aircraft</h3>
					</div>
					<table class="table">
		  				<tr>
		  					<td><i class="fa-solid fa-fw fa-hashtag"></i> Tail No:</td>
		  					<td>#results.reg#</td>
		  				</tr>
		  				<tr>
		  					<td><i class="fa-solid fa-fw fa-plane-up"></i> Type:</td>
		  					<td>#results.ac_make#, #results.ac_model#</td>
		  				</tr>
		  				<tr>
		  					<td><i class="fa-solid fa-fw fa-user"></i> Callsign:</td>
		  					<td>#results.callsign#</td>
		  				</tr>
		  				<tr>
		  					<td><i class="fa-solid fa-fw fa-square-parking"></i> Parking:</td>
		  					<td>#results.ac_parking#</td>
		  				</tr>
		  			</table>
				</div>
				<div class="panel panel-default">
					<div class="panel-heading">
						<h3 class="panel-title">Fuel</h3>
					</div>
					<table class="table">
						<cfif results.fuel_gal gt 0>
			  				<tr>
			  					<td><i class="fa-solid fa-fw fa-gas-pump"></i> Type:</td>
			  					<td>#results.fuel#</td>
			  				</tr>
			  				<tr>
			  					<td><i class="fa-solid fa-fw fa-hashtag"></i> Quantity:</td>
			  					<td>#results.fuel_gal# Gal</td>
			  				</tr>
			  				<tr>
			  					<td><i class="fa-solid fa-fw fa-dollar-sign"></i> Cost:</td>
			  					<td>#DollarFormat(evaluate(results.fuel_gal * results.fuel_rate))#</td>
			  				</tr>
				  		<cfelse>
				  			<tr>
			  					<td>No fuel requested</td>
			  				</tr>
				  		</cfif>
				  	</table>
				</div>
				<cfif event.recordcount>
					<div class="panel panel-info">
						<div class="panel-heading">
							<h3 class="panel-title">Event Info</h3>
						</div>
						<table class="table">
			  				<tr>
			  					<td><i class="fa-solid fa-fw fa-calendar-check"></i> Event:</td>
			  					<td>#event.name#<cfif event.ppr> <b>(PPR)</b></cfif></td>
			  				</tr>
			  				<tr>
			  					<td><i class="fa-solid fa-fw fa-dollar-sign"></i> Fee:</td>
			  					<td>
			  						<cfif event.chargeFee>
			  							#dollarFormat(event.fee)#&nbsp;&nbsp;&nbsp;
			  							<cfif results.feePayment EQ 1>
			  								<strong>PAID</strong>
			  							<cfelse>
			  								<cfif StructKeyExists(cookie, "admin") AND cookie.admin NEQ 3>
				  								<button id="paidButton" class="btn btn-xs btn-success"><i class="fa-solid fa-dollar-sign"></i> Mark Paid</button>
				  							</cfif>
			  								<div id="paidForm" class="panel panel-default formHide">
												<div class="panel-heading">
													<button class="btn btn-primary btn-xs pull-right closePaid"><i class="fa-solid fa-xmark"></i> Close</button>
													<h3 class="panel-title">Mark Fee Paid</h3>
												</div>
												<div class="panel-body">
													<form class="form" method="POST" id="mark_paid">
							        					<input type="hidden" name="paid_id" value="#res_id#">
							        					<div class="form-group form-group-sm">
								            				<label for="comment" class="control-label">Admin Comment</label>
								        					<textarea name="comment" class="form-control input-small"></textarea>
								        				</div>
														<button class="btn btn-success btn-sm pull-right paidConfirmBTN" type="button">Confirm Paid</button>
													</form>
												</div>
											</div>
			  							</cfif>
			  						<cfelse>
			  							$0 (Reservation does not fall within fee period)
			  						</cfif>
			  					</td>
			  				</tr>
			  			</table>
					</div>
				</cfif>
			</div>
			<div class="col-md-6">
				<div class="panel panel-default">
					<div class="panel-heading">
						<h3 class="panel-title">Selected Services</h3>
					</div>
					<table class="table table-bordered">
		  				<tr>
		  					<td>
		  						<cfif len(results.gpu_hours) And results.gpu_hours NEQ ''>
		  							<i class="fa-solid fa-fw fa-circle-check text-success"></i> GPU (#results.gpu_hours# hrs)
		  						<cfelse>
		  							<i class="fa-solid fa-fw fa-circle-xmark text-danger"></i> GPU
		  						</cfif>
		  					</td>
		  					<td>
		  						<cfif results.jumpstart NEQ '' and results.jumpstart NEQ 0>
		  							<i class="fa-solid fa-fw fa-circle-check text-success"></i> 
		  						<cfelse>
		  							<i class="fa-solid fa-fw fa-circle-xmark text-danger"></i> 
		  						</cfif>
		  						Jump Start
		  					</td>
		  				</tr>
		  				<tr>
		  					<td>
		  						<cfif results.lavatory NEQ '' and results.lavatory NEQ 0>
		  							<i class="fa-solid fa-fw fa-circle-check text-success"></i> 
		  						<cfelse>
		  							<i class="fa-solid fa-fw fa-circle-xmark text-danger"></i> 
		  						</cfif>
		  						Lavatory
		  					</td>
		  					<td>
		  						<cfif results.water NEQ '' and results.water NEQ 0>
		  							<i class="fa-solid fa-fw fa-circle-check text-success"></i> 
		  						<cfelse>
		  							<i class="fa-solid fa-fw fa-circle-xmark text-danger"></i> 
		  						</cfif>
		  						Potable Water
		  					</td>
		  				</tr>
		  				<tr>
		  					<td>
		  						<cfif  results.coffee NEQ '' and results.coffee NEQ 0>
		  							<i class="fa-solid fa-fw fa-circle-check text-success"></i> 
		  						<cfelse>
		  							<i class="fa-solid fa-fw fa-circle-xmark text-danger"></i> 
		  						</cfif>
		  						Coffee
		  					</td>
		  					<td>
		  						<cfif results.ice NEQ '' and results.ice NEQ 0>
		  							<i class="fa-solid fa-fw fa-circle-check text-success"></i> 
		  						<cfelse>
		  							<i class="fa-solid fa-fw fa-circle-xmark text-danger"></i> 
		  						</cfif>
		  						Ice
		  					</td>
		  				</tr>
		  				<tr>
		  					<td>
		  						<cfif results.catering NEQ '' and results.catering NEQ 0>
		  							<i class="fa-solid fa-fw fa-circle-check text-success"></i> 
		  						<cfelse>
		  							<i class="fa-solid fa-fw fa-circle-xmark text-danger"></i> 
		  						</cfif>
		  						Catering
		  					</td>
		  					<td>
		  					</td>
		  				</tr>
		  			</table>
				</div>
				<div class="panel panel-default">
					<div class="panel-heading">
						<button class="btn btn-primary btn-sm pull-right" type="button" data-toggle="collapse" data-target="##estText"><i class="fa-solid fa-magnifying-glass"></i> Details</button><h3 class="panel-title">Cost Estimate</h3>
					</div>
					<table class="table">
		  				<tr>
		  					<td><i class="fa-solid fa-fw fa-dollar-sign"></i> <b>Grand Total:</b></td>
		  					<td><b>#DollarFormat(estTotal)#</b></td>
		  				</tr>
		  			</table>
		  			<cfif len(estText)>
			  			<div class="panel-body collapse" id="estText">
			  				<cfset estText_clean = RemoveChars(estText, 1, 9)>
			  				<cfset estText_clean = Left(estText_clean, len(estText_clean)-3)>
			  					#estText_clean#
			  			</div>
		  			</cfif>
				</div>
				<cfif len(notes)>
					<div class="panel panel-default">
						<div class="panel-heading">
							<h3 class="panel-title">Client Comments</h3>
						</div>
						<table class="table">
			  				<tr>
			  					<td>#notes#</td>
			  				</tr>
			  			</table>
					</div>
				</cfif>
				<cfif status lt 3>
					<cfif !deleted>
						<cfif StructKeyExists(cookie, "admin") AND cookie.admin NEQ 3>
							<button id="cancelRes" class="btn btn-md btn-danger" data-id="#res_id#" style="margin-bottom: 10px;"><i class="fa-solid fa-fw fa-ban"></i> Cancel Reservation</button>
						</cfif>

						<div id="cancelForm" class="panel panel-default formHide">
							<div class="panel-heading">
								<button class="btn btn-primary btn-xs pull-right closePanel"><i class="fa-solid fa-xmark"></i> Close</button>
								<h3 class="panel-title">Cancel Reservation</h3>
							</div>
							<div class="panel-body">
								<form class="form" method="POST" id="res_cancel">
		        					<input type="hidden" name="cancel_id" value="#res_id#">
		        					<div class="form-group form-group-sm">
			            				<label for="comment" class="control-label">Admin Comment</label>
			        					<textarea name="comment" class="form-control comment input-small"></textarea>
			        				</div>
									<button class="btn btn-danger btn-sm pull-right confirmCancelBTN"  type="button">Confirm Cancellation</button>
								</form>
							</div>
						</div>

						<cfif results.confirmation eq 0 AND (StructKeyExists(cookie, "admin") AND cookie.admin NEQ 3)>
							<button id="cofirmFromWaitlist" class="btn btn-md btn-primary cofirmFromWaitlist" data-id="#res_id#" style="margin-bottom: 10px;"> Confirm from Waitlist</button>
						</cfif>
					<cfelse>
						<button id="cancelRes" class="btn btn-md btn-success" data-id="#res_id#" style="margin-bottom: 10px;"><i class="fa-solid fa-fw fa-ban"></i> Restore Reservation</button>

						<div id="cancelForm" class="panel panel-default formHide">
							<div class="panel-heading">
								<button class="btn btn-primary btn-xs pull-right closePanel"><i class="fa-solid fa-xmark"></i> Close</button>
								<h3 class="panel-title">Restore Reservation</h3>
							</div>
							<div class="panel-body">
								<form class="form" method="POST" id="res_cancel">
		        					<input type="hidden" name="restore_id" value="#res_id#">
		        					<div class="form-group form-group-sm">
			            				<label for="comment" class="control-label">Admin Comment</label>
			        					<textarea name="comment" class="form-control input-small"></textarea>
			        				</div>
									<button class="btn btn-success btn-sm pull-right restoreConfirmBTN" type="button">Confirm Restore</button>
								</form>
							</div>
						</div>
					</cfif>
				</cfif>
			</div>
		</div>
	    </div>
		<div class="row formHide" id="newNote">
			<div class="col-md-12">
				<div class="well well-sm">
				<form class="form" method="POST">
					<input type="hidden" name="note_id" value="#res_id#">
					<div class="form-group form-group-sm">
	    				<label for="comment" class="control-label">New Admin Note</label>
						<textarea name="comment" class="form-control input-small" rows="5"></textarea>
					</div>
					<button class="btn btn-primary btn-sm confirmSaveBTN" type="button"><i class="fa-regular fa-floppy-disk" ></i> Save Note</button>
				</form>
				</div>
			</div>
		</div>
		<div class="row">
			<div class="col-md-12">
				<cfquery DATASOURCE="CCDOA" name="thenotes">
		          Select * from notes n
		          LEFT JOIN users u on n.enteredBy = u.id
		          where res_id = #res_id#
		          order by entrydate desc
		          </cfquery>

				<div class="panel panel-default">
					<div class="panel-heading">
					    <h3 class="panel-title">
					    	<cfif StructKeyExists(cookie, "admin") AND cookie.admin NEQ 3>
						    	<button id="addNote" class="btn btn-primary btn-sm pull-right"><i class="fa-solid fa-plus"></i> New Note</button>
						    </cfif>
					    	<a data-toggle="collapse" class="collapsed" href="##metricsCollapse">Admin Notes <cfif thenotes.note NEQ 'NULL' AND thenotes.note NEQ ''>(#thenotes.recordcount#)</cfif></a>
					    </h3>
					</div>
					<div class="panel-collapse collapse" id="metricsCollapse">
					    <cfif thenotes.recordcount>
					        <ul class="list-group">
						        <cfloop query='thenotes'>
							        <li class="list-group-item">
							          	<!---<a class="pull-right" href="##" onclick="return confirm('Are you sure you want to delete this note?')" title="Delete"><i class="glyphicon glyphicon-remove fa-fw text-danger"></i></a>--->
							          	<cfif note NEQ 'NULL' AND note NEQ ''>
							          		<cfset pacificNow = dateTimeFormat(entrydate, "yyyy-mm-dd HH:nn:ss", "America/Los_Angeles")>
								          	<b><small>#dateformat(pacificNow)# by #last_name#, #first_name#</small></b>
								          	<p>#note#</p>
								        </cfif>
							        </li>
						        </cfloop>
					        </ul>

					    <cfelse>
					      There are no notes for this reservation.
					    </cfif>
					</div>
				</div>
		    </div>
		</div>
	</cfoutput>
</cfif>

<script>
	$(document).ready(function() {
		$('.statusChange').on('change', function(e) {
			e.preventDefault();
	
			if (!confirm('Are you sure you want to manually change this reservation status?')) {
				return;
			}
	
			const resId = $(this).data('id');
            const newStatus = $(this).val(); // <-- get selected status
			$.ajax({
				url: 'index.cfm?statusChange=1&id='+ resId + '&newStatus=' + newStatus,
				type: 'GET',
				success: function(response) {
					if(JSON.parse(response.trim())){
						// $("#detailsModal").modal("hide");
						loadResults($("input[type=search]").val())
					}
				},
				error: function(xhr, status, error) {
					alert('There was an error updating the status');
				}
			});
		});

		$(document).on("click", ".cofirmFromWaitlist", function (event) {
			if (!confirm('Are you sure you want to remove this record from waitlist?')) {
				return;
			}
			var recordID = $(this).data('id');
			$.ajax({
				type: "POST",
				url: "ajax_submit.cfm",
				data: {
					res_id : recordID,
					formName : "comfirmFromWaitlist"
				}
			})
			.success(function () {
				$('#detailsModal .modal-body').html('<h4 class="text-center">Reservation Updated.</h4>');
				loadResults($("input[type=search]").val());
				$('#detailsModal').modal('hide');
				$('#detailsModal .modal-body').html('');
			})
			.error(function (jqXHR, textStatus, errorThrown) {
				console.error("AJAX Error:", textStatus, errorThrown);
				alert("Error: Please correct and try again.");
			});
		});

		$(".confirmCancelBTN").on("click", function () {
			var recordID = $("input[name=cancel_id]").val();
			var comment = $(this).closest("form").find("textarea[name=comment]").val();

			$.ajax({
				url: 'index.cfm',
				type: 'GET',
				data: {
					cancel_id : recordID,
					comment : comment
				},
				success: function(response) {
					if(JSON.parse(response.trim())){
						$("#detailsModal").modal("hide");
						loadResults($("input[type=search]").val())
					}
				},
				error: function(xhr, status, error) {
					alert('There was an error updating the status');
				}
			});
		});

		$(".paidConfirmBTN").on("click", function () {
			var recordID = $("input[name=paid_id]").val();
			var comment = $(this).closest("form").find("textarea[name=comment]").val();

			$.ajax({
				url: 'index.cfm',
				type: 'GET',
				data: {
					paid_id : recordID,
					comment : comment
				},
				success: function(response) {
					if(JSON.parse(response.trim())){
						// var data = { id: recordID, MarkFee: '1' };
						var data = { id: recordID};
                        // Send the email using a GET request
                        $("#detailsModal").modal("hide");
						loadResults($("input[type=search]").val());
						// $.get("email_send.cfm", data, function(res) {
						    
						// }).fail(function(jqXHR, textStatus, errorThrown) {
						//     console.error('Email send failed:', textStatus, errorThrown);
						//     alert('Failed to send email.');
						// });
						
					}
				},
				error: function(xhr, status, error) {
					alert('There was an error updating the status');
				}
			});
		});

		$(".restoreConfirmBTN").on("click", function () {
			var recordID = $("input[name=restore_id]").val();
			var comment = $(this).closest("form").find("textarea[name=comment]").val();

			$.ajax({
				url: 'index.cfm',
				type: 'GET',
				data: {
					restore_id : recordID,
					comment : comment
				},
				success: function(response) {
					if(JSON.parse(response.trim())){
						$("#detailsModal").modal("hide");
						loadResults($("input[type=search]").val())
					}
				},
				error: function(xhr, status, error) {
					alert('There was an error updating the status');
				}
			});
		});

		$(".confirmSaveBTN").on("click", function () {
			var recordID = $("input[name=note_id]").val();
			var comment = $(this).closest("form").find("textarea[name=comment]").val();

			$.ajax({
				url: 'index.cfm',
				type: 'GET',
				data: {
					note_id : recordID,
					comment : comment
				},
				success: function(response) {
					if(JSON.parse(response.trim())){
						$("#detailsModal").modal("hide");
						loadResults($("input[type=search]").val())
					}
				},
				error: function(xhr, status, error) {
					alert('There was an error updating the status');
				}
			});
		});


		$('#cancelRes, .closePanel').on('click', function () {
			$('#cancelForm').toggle();
			$('#cancelRes').toggle();
		});

		$('#addNote').click(function(){
			$('#newNote').toggle();
		});

		$("#res_edit").validate({
			errorClass: "text-danger", // error messages will be red
	        errorElement: "span",
	        highlight: function(element) {
	            $(element).addClass("has-error"); // optional: add red border
	        },
	        unhighlight: function(element) {
	            $(element).removeClass("has-error");
	        },
	        rules: {
	            name: { required: true },
	            email: { required: true, email: true },
	            phone: { required: true },
	            arrival: { required: true },
	            departure: { required: true }
	        },
	        messages: {
	            name: "Please enter the name",
	            email: {
	                required: "Please enter the email",
	                email: "Please enter a valid email"
	            },
	            phone: "Please enter the phone number",
	            arrival: "Please select arrival date & time",
	            departure: "Please select departure date & time"
	        },
	        submitHandler: function(form) {
	            // Custom validation: arrival < departure
	            var arrival = new Date($("input[name=arrival]").val());
	            var departure = new Date($("input[name=departure]").val());

	            if(arrival >= departure){
	                alert("Arrival date & time must be less than Departure date & time.");
	                return false;
	            }

	            // AJAX submit
	            var $button = $(".resEditFormBTN");
	            var $form = $(form);
	            var searchFilters = $("input[type=search]").val();
	            var formData = $form.serialize();
	            formData += "&formName=" + $form.attr('id');

	            $.ajax({
	                type: "POST",
	                url: "ajax_submit.cfm",
	                data: formData,
	                success: function() {
	                    $('#detailsModal .modal-body').html('<h4 class="text-center">Reservation Updated.</h4>');
	                    loadResults(searchFilters);
	                    $('#detailsModal').modal('hide');
	                    $('#detailsModal .modal-body').html('');
	                },
	                error: function(jqXHR, textStatus, errorThrown) {
	                    console.error("AJAX Error:", textStatus, errorThrown);
	                    alert("Error: Please correct and try again.");
	                }
	            });

	            return false; // prevent default form submit
	        }
	    });

	    // Trigger validation on button click
	    $(".resEditFormBTN").click(function() {
	        $("#res_edit").submit();
	    });

		// $(".resEditFormBTN").on("click", function (event) {
		// 	event.preventDefault();

		// 	var $button = $(this);
		// 	var $form = $button.closest("form");
		// 	var searchFilters = $("input[type=search]").val();

		// 	var formData = $form.serialize();
		// 	formData += "&formName=" + $form.attr('id');

		// 	$.ajax({
		// 		type: "POST",
		// 		url: "ajax_submit.cfm",
		// 		data: formData
		// 	})
		// 	.success(function () {
		// 		$('#detailsModal .modal-body').html('<h4 class="text-center">Reservation Updated.</h4>');
		// 		loadResults(searchFilters);
		// 		$('#detailsModal').modal('hide');
		// 		$('#detailsModal .modal-body').html('');
		// 		window.location.reload();

		// 	})
		// 	.error(function (jqXHR, textStatus, errorThrown) {
		// 		console.error("AJAX Error:", textStatus, errorThrown);
		// 		alert("Error: Please correct and try again.");
		// 	});
		// });

		// $("#res_edit :input").change(function() {

	    //     actype = parseFloat($('input[name="actype"]').val());

	    // });

	    // $.widget('custom.mcautocomplete', $.ui.autocomplete, {
	    //     _create: function () {
	    //         this._super();
	    //         this.widget().menu("option", "items", "> :not(.ui-widget-header)");
	    //     },
	    //     _renderMenu: function (ul, items) {
	    //         var self = this,
	    //             thead;
	    //         if (this.options.showHeader) {
	    //             table = $('<div class="ui-widget-header" style="width:100%; border:none; border-bottom:1px solid #999"></div>');
	    //             $.each(this.options.columns, function (index, item) {
	    //                 table.append('<span style="padding:4px 0 3px 8px;float:left;width:' + item.width + ';">' + item.name + '</span>');
	    //             });
	    //             table.append('<div style="clear: both;"></div>');
	    //             ul.append(table);
	    //         }
	    //         $.each(items, function (index, item) {
	    //             self._renderItem(ul, item);
	    //         });
	    //     },
	    //     _renderItem: function (ul, item) {
	    //         var t = '',
	    //             result = '';
	    //         $.each(this.options.columns, function (index, column) {
	    //             t += '<span style="padding:0 4px;float:left;width:' + column.width + ';">' + item[column.valueField ? column.valueField : index] + '</span>'
	    //         });
	    //         result = $('<li></li>')
	    //             .data('ui-autocomplete-item', item)
	    //             .append('<a class="mcacAnchor">' + t + '<div style="clear: both;"></div></a>')
	    //             .appendTo(ul);
	    //         return result;
	    //     }
	    // });
	    // $("#actype").mcautocomplete({
	    //     showHeader: true,
	    //     columns: [{
	    //         name: 'Make',
	    //         width: '150px',
	    //         valueField: 'make'
	    //     }, {
	    //         name: 'Model',
	    //         width: '180px',
	    //         valueField: 'model'
	    //     }/*, {
	    //       name: 'Parking Group',
	    //         width: '180px',
	    //         valueField: 'parking'
	    //     }*/],
	    //     select: function (event, ui) {
	    //       this.value = (ui.item ? ui.item.make + ' ' + ui.item.model : '');
	    //       $('#actype_id').val(ui.item ? ui.item.id : '')
	    //       parkingSelected = ui.item.parking;
	    //       return false;
	    //     },
	    //     minLength: 1,
	    //     delay: 0,
	    //     source: "../ac_search.cfm"
	    // });

	    // Function to load options dynamically
	    var $input = $("#actype");
	    var $dropdown = $("#actype_dropdown");

	    // Function to populate dropdown
	    function populateDropdown(items) {
	        $dropdown.empty();
	        if(items.length === 0) {
	            $dropdown.hide();
	            return;
	        }
	        $.each(items, function(i, item) {
	            var $option = $('<div class="actype_option" style="padding:5px; cursor:pointer;"></div>');
	            $option.text(item.make + " " + item.model);
	            $option.data('item', item);
	            $dropdown.append($option);
	        });
	        $dropdown.show();
	    }

	    // AJAX search on input
	    $input.on('keyup', function() {
	        var term = $(this).val();
	        if(term.length < 1) {
	            $dropdown.hide();
	            return;
	        }

	        $.ajax({
	            url: "../ac_search.cfm",
	            type: "GET",
	            dataType: "json",
	            data: { term: term },
	            success: function(data) {
	                populateDropdown(data);
	            },
	            error: function(xhr, status, error) {
	                console.error("Error loading aircraft types:", error);
	            }
	        });
	    });

	    // Handle option click
	    $dropdown.on('click', '.actype_option', function() {
	        var item = $(this).data('item');
	        $input.val(item.make + " " + item.model);
	        $("#actype_id").val(item.id);
	        parkingSelected = item.parking;

	        $dropdown.hide();
	    });

	    // Hide dropdown if click outside
	    $(document).on('click', function(e) {
	        if(!$(e.target).closest("#actype, #actype_dropdown").length) {
	            $dropdown.hide();
	        }
	    });


	});
	</script>