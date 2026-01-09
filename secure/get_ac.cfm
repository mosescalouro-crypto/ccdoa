<cfif!isDefined("url.id")>
	<cfthrow>
</cfif>

<cfquery datasource="CCDOA" name="results">
	SELECT *,
		CASE 
          WHEN sqft < 1250 THEN '1S'
          WHEN sqft BETWEEN 1250 AND 1999 THEN '1M'
          WHEN sqft BETWEEN 2000 AND 3499 THEN '2'
          ELSE '3'
        END as parking
    FROM aircraft
	WHERE id = #url.id#
</cfquery>

<cfoutput query="results">

	<form class="form ac_form" id="editACForm" method="POST">
		<input type="hidden" name="res_id" id="res_id" value="#id#">
        <div class="form-group">
          <label for="make" required>Aircraft Make</label>
          <input type="text" class="form-control" id="make_field" name="make" value="#make#" required>
        </div>
        <div class="form-group">
          <label for="model" required>Aircraft Model</label>
          <input type="text" class="form-control" id="model_field" name="model" value="#model#" required>
        </div>
        <div class="row">
          <div class="col-sm-6">
              <div class="form-group">
                <label for="length">Length <small>(ft)</small></label>
                <input type="text" class="form-control" name="length" placeholder="Optional" value="#length#">
              </div>
              <div class="form-group">
                <label for="width">Width <small>(ft)</small></label>
                <input type="text" class="form-control" name="width" placeholder="Optional" value="#width#">
              </div>
          </div>
          <div class="col-sm-6">
            <div class="form-group">
              <label for="heli">Helicopter?</label>
              <div class="checkbox">
                <label>
                  <input type="checkbox" name="heli"<cfif heli> checked</cfif>> Is Helicopter
                </label>
              </div>
            </div>
          </div>
        </div>
        <div class="row">
          <div class="col-sm-6">
              <div class="form-group">
                <label for="sqft">Square Footage</label>
                <input type="text" class="form-control" name="sqft" value="#sqft#">
              </div>
          </div>
          <div class="col-sm-6">
              <div class="form-group">
                <label for="parking">Parking Group</label>
                <input type="text" class="form-control" name="parking" placeholder="Calculated Automatically"  value="#parking#" readonly>
              </div>
          </div>
        </div>
        <div class="form-group">
          <label for="notes">Internal Admin Notes</label>
          <textarea name="notes" class="form-control" rows="3">#notes#</textarea>
        </div>
    </form>
</cfoutput>
