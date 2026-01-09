<cfif!isDefined("url.id")>
	<cfthrow>
</cfif>

<cfquery datasource="CCDOA" name="results">
	SELECT 
		[id]
    ,[locationid]
    ,[startDate]
    ,[endDate]
    ,[name]
    ,[ppr]
    ,[limit_1S]
    ,[limit_1M]
    ,[limit_2]
    ,[limit_3]
    ,[fee_1S]
    ,[fee_1M]
    ,[fee_2]
    ,[fee_3]
    ,[feeStartDate]
    ,[feeEndDate]
    ,[updated]
    ,[updatedBy]
    ,[deleted]
	FROM events
	WHERE id = #url.id#
</cfquery>

<cfoutput query="results">
	<form class="form" method="POST" id="editEventForm">
        <input type="hidden" name="event_id" value="#id#">
         	<div class="form-group">
              <label for="make">Event Name</label>
              <input type="text" class="form-control" id="eventNameId" name="name" value="#name#">
              <div class="error-msg text-danger" id="eventNameError"></div>
            </div>
            <div class="row">
              <div class="col-sm-6">
                  <div class="form-group">
                    <label for="sqft">Start Date</label>
                    <input type="text" class="form-control datepicker" name="startDate" placeholder="Select date & time" value="#datetimeformat(startDate, 'mm/dd/yyyy HH:nn')#">
                    <div class="error-msg text-danger" id="startDateError"></div>
                  </div>
              </div>
              <div class="col-sm-6">
                  <div class="form-group">
                    <label for="parking">End Date</label>
                    <input type="text" class="form-control datepicker" name="endDate" placeholder="Select date & time" value="#datetimeformat(endDate, 'mm/dd/yyyy HH:nn')#">
                    <div class="error-msg text-danger" id="endDateError"></div>
                  </div>
              </div>
            </div>
            <div class="row">
              <div class="col-sm-6">
                  <div class="form-group">
                    <label for="fee">PPR Event?</label>
                    <br>
                    <label class="radio-inline">
                      <input type="radio" name="ppr" value="1"<cfif ppr> checked</cfif>> Yes
                    </label>
                    <label class="radio-inline">
                      <input type="radio" name="ppr" value="0"<cfif !ppr> checked</cfif>> No
                    </label>
                  </div>
              </div>
              <div class="col-sm-6">
                <div class="form-group">
                  <label for="airport">Airport</label>
                  <br>
                  <label class="radio-inline">
                    <input type="radio" name="locationid" value="HND"<cfif locationid eq 'HND'> checked</cfif>> HND
                  </label>
                  <label class="radio-inline">
                    <input type="radio" name="locationid" value="VGT"<cfif locationid eq 'VGT'> checked</cfif>> VGT
                  </label>
                </div>
              </div>
            </div>
            <div class="row">
              <div class="col-sm-6">
                  <div class="form-group">
                    <label for="sqft">Fee Start Date</label>
                    <input type="text" class="form-control datepicker" name="feeStartDate" placeholder="Select date & time" value="#datetimeformat(feeStartDate, 'mm/dd/yyyy HH:nn')#">
                    <div class="error-msg text-danger" id="feeStartDateError"></div>
                  </div>
              </div>
              <div class="col-sm-6">
                  <div class="form-group">
                    <label for="parking">Fee End Date</label>
                    <input type="text" class="form-control datepicker" name="feeEndDate" placeholder="Select date & time" value="#datetimeformat(feeEndDate, 'mm/dd/yyyy HH:nn')#">
                    <div class="error-msg text-danger" id="feeEndDateError"></div>
                  </div>
              </div>
            </div>
            <h4 class="page-header" style="margin-top: 10px">Parking Group Capacity and Fees</h4>
            <div class="row">
              <div class="col-sm-3">
                  <div class="form-group">
                    <label for="sqft">Group 1S</label>
                    <input type="text" class="form-control" name="limit_1S" value="#limit_1S#" placeholder="Capacity">
                  </div>
              </div>
              <div class="col-sm-3">
                  <div class="form-group">
                    <label for="sqft">Group 1M</label>
                    <input type="text" class="form-control" name="limit_1M" value="#limit_1M#" placeholder="Capacity">
                  </div>
              </div>
              <div class="col-sm-3">
                  <div class="form-group">
                    <label for="sqft">Group 2</label>
                    <input type="text" class="form-control" name="limit_2" value="#limit_2#" placeholder="Capacity">
                  </div>
              </div>
              <div class="col-sm-3">
                  <div class="form-group">
                    <label for="sqft">Group 3</label>
                    <input type="text" class="form-control" name="limit_3" value="#limit_3#" placeholder="Capacity">
                  </div>
              </div>
            </div>
            <div class="row">
              <div class="col-sm-3">
                  <div class="form-group">
                    <label for="sqft">Fee 1S</label>
                    <input type="text" class="form-control" name="fee_1S" value="#fee_1S#" placeholder="0.00">
                  </div>
              </div>
              <div class="col-sm-3">
                  <div class="form-group">
                    <label for="sqft">Fee 1M</label>
                    <input type="text" class="form-control" name="fee_1M" value="#fee_1M#" placeholder="0.00">
                  </div>
              </div>
              <div class="col-sm-3">
                  <div class="form-group">
                    <label for="sqft">Fee 2</label>
                    <input type="text" class="form-control" name="fee_2" value="#fee_2#" placeholder="0.00">
                  </div>
              </div>
              <div class="col-sm-3">
                  <div class="form-group">
                    <label for="sqft">Fee 3</label>
                    <input type="text" class="form-control" name="fee_3" value="#fee_3#" placeholder="0.00">
                  </div>
              </div>
            </div>
     </form>
</cfoutput>