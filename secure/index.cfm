<cfif isDefined("url.statusChange") && isDefined("url.id")>
  <cfquery datasource="CCDOA" name="statusChange">
    UPDATE reservations
    <!--- SET status = status+1 --->
    SET status = #url.newStatus#
    where id = #url.id#
  </cfquery>
  
  <cfoutput>#serializeJSON(true)#</cfoutput>
  <cfabort>
</cfif>

<cfif isDefined("url.cancel_id")>
    <cfquery datasource="CCDOA" name="note">
        INSERT INTO notes (res_id,note,enteredBy)
        VALUES (
        	#url.cancel_id#
        	,'CANCELLED: #url.comment#'
        	,'#cookie.user_id#'
        )
    </cfquery>

    <cfquery datasource="CCDOA" name="cancelreservation">
        select * from reservations where id = #url.cancel_id#
    </cfquery>

    <cfif cancelreservation.recordcount GT 0>
        <cfquery datasource="CCDOA" name="waitlistedReservation">
            SELECT top 1 *
            FROM reservations r 
            INNER JOIN aircraft_view a on r.actype = a.id AND r.locationid = a.locationid
            WHERE r.locationid = '#cancelreservation.locationid#'
            AND ACType = '#cancelreservation.ACType#'
            AND (r.deleted = 0 OR r.deleted is null)
            AND r.confirmation = 0
            AND ('#cancelreservation.arrival#' <= departure) AND (arrival <= '#cancelreservation.departure#')
            order by r.id asc
        </cfquery>
        <cfif waitlistedReservation.recordcount GT 0>
            <cfquery datasource="CCDOA" name="updatereservation">
                UPDATE reservations
                SET confirmation = 1
                where id = #waitlistedReservation.id#
            </cfquery>
        </cfif>
        
    </cfif>
    <cfquery datasource="CCDOA" name="cancel">
        UPDATE reservations
        SET deleted = 1
        where id = #url.cancel_id#
    </cfquery>

    <cfoutput>#serializeJSON(true)#</cfoutput>
    <cfabort>
</cfif>



<cfif isDefined("url.restore_id")>
  <cfquery datasource="CCDOA" name="note">
    INSERT INTO notes (res_id,note,enteredBy)
    VALUES (
    	#url.restore_id#
    	,'RESTORED: #url.comment#'
    	,'#cookie.user_id#'
    )
  </cfquery>

  <cfquery datasource="CCDOA" name="cancel">
    UPDATE reservations
    SET deleted = 0
    where id = #url.restore_id#
  </cfquery>
  
  <cfoutput>#serializeJSON(true)#</cfoutput>
  <cfabort>
</cfif>

<cfif isDefined("url.paid_id")>
    <cfquery datasource="CCDOA" name="note">
        INSERT INTO notes (res_id,note,enteredBy)
        VALUES (
        	#url.paid_id#
        	,'FEE PAID: #url.comment#'
        	,'#cookie.user_id#'
        )
    </cfquery>

    <cfquery datasource="CCDOA" name="paid">
        UPDATE reservations
        SET feePayment = 1,
        confirmation = 1
        where id = #url.paid_id#
    </cfquery>

    <cfoutput>#serializeJSON(true)#</cfoutput>
    <cfabort>
</cfif>

<cfif isDefined("url.note_id")>
	<cfquery datasource="CCDOA" name="note">
		INSERT INTO notes (res_id,note,enteredBy)
		VALUES (
			#url.note_id#
			,'#url.comment#'
			,'#cookie.user_id#'
		)
	</cfquery>

    <cfoutput>#serializeJSON(true)#</cfoutput>
    <cfabort>
</cfif>


<cfinclude template="header.cfm">



<cfquery datasource="CCDOA" name="events">
  SELECT id,name,locationid FROM events 
  WHERE deleted = 0
  order by startDate asc
</cfquery>

<style>
  .pagination,
  .dataTables_length {
    margin: 5px 0;
  }

  .pagination {
    float: right;
  }

  .formHide,
  .estHide { display: none; }

  .panel-title [data-toggle="collapse"]::after {
	    display: inline-block;
	    font-family: "FontAwesome";
	    font-size: 0.9em;
	    text-rendering: auto;
	    -webkit-font-smoothing: antialiased;
	    -moz-osx-font-smoothing: grayscale;
	  content: "\00a0\00a0\f078";
	}   

	.panel-title [data-toggle="collapse"].collapsed::after {
	  content: "\00a0\00a0\f054";
	}
    .btn-excel-custom{
        background-color: #398439 !important;
        color: white !important;
        border-color: #255625 !important;
    }
</style>

    <div class="row">
        <div class="col-lg-12">
            <h2 class="page-header">Reservation Management</h2>
        </div>
    </div>

    <div class="row">
        <div class="col-md-8">
          <form action="get_results.cfm" method="POST" id="searchForm">
            <input type="hidden" name="search" value="1">
            <div class="row">
              <div class="col-md-6">
                <div class="form-group">
                  <label for="criteria">Search Criteria:</label>
                  <input class="form-control" type="text" name="criteria" id="resSearchTerm" placeholder="Name/Email/Phone/Tail#/Conf#">
                </div>
              </div>
              <div class="col-md-6">
                <div class="form-group">
                  <label for="notes">Internal Admin Notes:</label>
                  <input class="form-control" type="text" name="notes">
                </div>
              </div>
            </div>
            <div class="collapse" id="advancedOptions">
              <div class="well">
                <div class="row">
                  <div class="col-lg-4">
                    <div class="form-group">
                      <label for="quickTurn">Drop Off or Pickup and Go?</label>
                      <br>
                      <label class="radio-inline">
                        <input type="radio" name="quickTurn" value="yes"> Yes
                      </label>
                      <label class="radio-inline">
                        <input type="radio" name="quickTurn" value="no"> No
                      </label>
                      <label class="radio-inline">
                        <input type="radio" name="quickTurn" value="" checked> Any
                      </label>
                    </div>
                  </div>
                  <div class="col-lg-4">
                    <div class="form-group">
                      <label for="resConf">Reservation Confirmation:</label>
                      <br>
                      <label class="radio-inline">
                        <input type="radio" name="resConf" value="reserved"> Reserved
                      </label>
                      <label class="radio-inline">
                        <input type="radio" name="resConf" value="wait"> Wait-listed
                      </label>
                      <label class="radio-inline">
                        <input type="radio" name="resConf" value="" checked> Any
                      </label>
                    </div>
                  </div>
                  <div class="col-lg-4">
                    <div class="form-group">
                      <label for="status">Reservation Status:</label>
                      <br>
                      <label class="radio-inline">
                        <input type="radio" name="status" value="1" checked> Active
                      </label>
                      <label class="radio-inline">
                        <input type="radio" name="status" value="0"> Canceled
                      </label>
                    </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-lg-12">
                    <div class="form-group">
                      <label>Services:</label>
                      <br>
                      <label class="checkbox-inline">
                        <input type="checkbox" name="fuel"> Fuel
                      </label>
                      <label class="checkbox-inline">
                        <input type="checkbox" name="gpu"> GPU
                      </label>
                      <label class="checkbox-inline">
                        <input type="checkbox" name="jumpstart"> Jump Start
                      </label>
                      <label class="checkbox-inline">
                        <input type="checkbox" name="lavatory"> Lavatory
                      </label>
                      <label class="checkbox-inline">
                        <input type="checkbox" name="water"> Potable Water
                      </label>
                      <label class="checkbox-inline">
                        <input type="checkbox" name="oxygen"> Oxygen
                      </label>
                      <label class="checkbox-inline">
                        <input type="checkbox" name="nitrogen"> Nitrogren
                      </label>
                      <label class="checkbox-inline">
                        <input type="checkbox" name="coffee"> Coffee
                      </label>
                      <label class="checkbox-inline">
                        <input type="checkbox" name="ice"> Ice
                      </label>
                      <label class="checkbox-inline">
                        <input type="checkbox" name="catering"> Catering
                      </label>
                    </div>
                  </div>
                </div>
                <div class="row">
                  <!--- <div class="col-lg-6">
                    <div class="form-group">
                      <label>Aircraft Groups:</label>
                      <br>
                      <label class="checkbox-inline">
                        <input type="checkbox" name="1S" checked> Group 1S
                      </label>
                      <label class="checkbox-inline">
                        <input type="checkbox" name="1M" checked> Group 1M
                      </label>
                      <label class="checkbox-inline">
                        <input type="checkbox" name="2" checked> Group 2
                      </label>
                      <label class="checkbox-inline">
                        <input type="checkbox" name="3" checked> Group 3
                      </label>
                    </div>
                  </div> --->
                  <div class="col-lg-6">
                    <div class="form-group form-group-sm">
                      <label>Timeframe:</label>
                      <br>
                      <select class="form-control" name="event" id="eventSelect">
                        <option Value='All'>All records</option>
                        <option value="r">Range</option>
                        <option value="d-7">Next 7 Days</option>
                        <option value="d-30" selected>Next 30 Days</option>
                        <option value="d-0">Today</option>
                        <option value="d-1">Tomorrow</option>
                        <cfoutput query="events">
                          <option value="e-#id#">#name# (#locationid#)</option>
                        </cfoutput>
                      </select>
                    </div>
                  </div>
                </div>
                <div class="row formHide" id="rangeFilter">
                  <div class="col-md-3 col-md-offset-6">
					<div class="form-group form-group-sm">
                      <label>Start:</label>
                      <br>
                      <input type="text" class="form-control datepicker" name="rangeStart" placeholder="Select date/time">
                    </div>
                  </div>
                  <div class="col-md-3">
					<div class="form-group form-group-sm">
                      <label>End:</label>
                      <br>
                      <input type="text" class="form-control datepicker" name="rangeEnd" placeholder="Select date/time">
                    </div>
                  </div>
                </div>
                <div class="row">
                  <div class="col-lg-6">
                    <div class="form-group">
                      <label for="airport">Airport</label>
                      <br>
                      <label class="radio-inline">
                        <input type="radio" name="airport" value="HND"> HND
                      </label>
                      <label class="radio-inline">
                        <input type="radio" name="airport" value="VGT"> VGT
                      </label>
                      <label class="radio-inline">
                        <input type="radio" name="airport" value="" checked> All
                      </label>
                    </div>
                  </div>
                  <div class="col-lg-6">
                    <div class="form-group">
                      <label for="airport">Event Fee Paid?</label>
                      <br>
                      <label class="radio-inline">
                        <input type="radio" name="eventFee" value="1"> Yes
                      </label>
                      <label class="radio-inline">
                        <input type="radio" name="eventFee" value="0"> No
                      </label>
                      <label class="radio-inline">
                        <input type="radio" name="eventFee" value="" checked> All
                      </label>
                    </div>
                  </div>
                </div>
              </div>
            </div>
            <div class="row">
              <div class="col-lg-12">
                <a href="##" class='btn btn-success pull-right' style="padding-left: 20px; padding-right: 20px;" onClick="refreshResults();">Reset <i class="fa-solid fa-refresh" aria-hidden="true"></i></a>
                <a href="##" class='btn btn-success pull-right' style="margin-right: 20px;" onClick="loadResults();">Search <i class="fa-solid fa-magnifying-glass"></i></a>
                <a class="btn btn-primary" data-toggle="collapse" id="optionsButton" href="#advancedOptions" aria-expanded="false" aria-controls="collapseExample">More Options</a>
              </div>
            </div>
          </form>
        </div>
        <div class="col-md-2 col-md-offset-2">
          <div class="panel panel-default">
            <div class="panel-heading"><b>Legend</b></div>
            <table class="table table-condensed">
              <tr>
                <td class="info">Waitlisted</td>
                <td><i class="fa-solid fa-star fa-fw" style="color: #265B89"></i> = Event</td>
              </tr>
              <tr>
                <td class="danger">Duplicate</td>
                <td><i class="fa-solid fa-bolt fa-fw" style="color: #FAB005"></i> = Quick Turn</td>
              </tr>
              <tr>
                <td class="success">Event Paid</td>
                <td></td>
              </tr>
            </table>
          </div>
        </div>
    </div>
    <hr>
    
    <div class="row">
        <div class="col-lg-12" id="searchResult"></div>
    </div>
    <div class="modal fade" id="detailsModal" tabindex="-1" role="dialog">
      <div class="modal-dialog modal-lg" role="document">
        <div class="modal-content">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-label="Close"><span aria-hidden="true">&times;</span></button>
            <h4 class="modal-title">Reservation</h4>
          </div>
          <div class="modal-body"></div>
        </div>
      </div>
    </div>

<!-- DateTimePicker -->
<link rel="stylesheet" href="/css/bootstrap-datetimepicker.min.css" />
<script src="//cdnjs.cloudflare.com/ajax/libs/moment.js/2.8.4/moment.min.js"></script>
<script src="/js/bootstrap-datetimepicker.min.js"></script>

<!-- jQuery Validation (works with jQuery 1.12.4) -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery-validate/1.19.5/jquery.validate.min.js"></script>

<!-- DataTables core + Bootstrap 3 integration -->
<link rel="stylesheet" href="https://cdn.datatables.net/1.10.25/css/dataTables.bootstrap.min.css" />
<script src="https://cdn.datatables.net/1.10.25/js/jquery.dataTables.min.js"></script>
<script src="https://cdn.datatables.net/1.10.25/js/dataTables.bootstrap.min.js"></script>

<!-- DataTables Buttons (Bootstrap 3 integration) -->
<link rel="stylesheet" href="https://cdn.datatables.net/buttons/1.7.1/css/buttons.bootstrap.min.css" />
<script src="https://cdn.datatables.net/buttons/1.7.1/js/dataTables.buttons.min.js"></script>
<script src="https://cdn.datatables.net/buttons/1.7.1/js/buttons.bootstrap.min.js"></script>

<!-- Export dependencies -->
<script src="https://cdnjs.cloudflare.com/ajax/libs/jszip/3.10.1/jszip.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.7/pdfmake.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/pdfmake/0.2.7/vfs_fonts.js"></script>

<!-- Export buttons -->
<script src="https://cdn.datatables.net/buttons/1.7.1/js/buttons.html5.min.js"></script>
<script src="https://cdn.datatables.net/buttons/1.7.1/js/buttons.print.min.js"></script>



<script type="text/javascript">
var table;

$(function() {

    // Prevent Enter from submitting form
    $(document).keypress(function(e) {
        if (e.which == 13 && e.target.id == "searchCriteria") {
            e.stopPropagation();
            e.preventDefault();
        }
    });

    // Toggle Options Button
    $("#optionsButton").click(function() {
        $(this).text(function(i, text) {
            return text === "Less Options" ? "More Options" : "Less Options";
        })
    });

    // Event Select Change
    $('#eventSelect').change(function() {
        if ($(this).val() === 'r') {
            $("#rangeFilter").show();
        } else {
            $("#rangeFilter").hide();
            $('input[name="rangeStart"]').val('');
            $('input[name="rangeEnd"]').val('');
        }
    });

    // DateTimePicker
    $('.datepicker').datetimepicker({
        pickTime: true,
        format: 'MM/DD/YYYY HH:mm'
    });

    // Resend Email
    $(document).off('click', '#reSend').on('click', '#reSend', function() {
        var link = $(this);
        var data = { id: link.data('id') };
        $.get("email_send.cfm", data, function(res) {
            alert('Email Notification Sent.');
        });
    });

    // Cancel Reservation
    $('#cancelRes').click(function() {
        $('#cancelForm').toggle();
        $('#cancelRes').toggle();
    });

    $('.closePanel').click(function() {
        $('#cancelForm').toggle();
        $('#cancelRes').toggle();
    });

    // Restore Filters from LocalStorage
    var savedFilters = localStorage.getItem("reservationSearchFilters");
    if (savedFilters) {
        var filters = JSON.parse(savedFilters);
        filters.forEach(function(item) {
            var field = $('[name="' + item.name + '"]');
            if (field.attr('type') == 'radio' || field.attr('type') == 'checkbox') {
                field.each(function() {
                    if ($(this).val() == item.value) {
                        $(this).prop('checked', true);
                    }
                });
            } else {
                field.val(item.value);
            }
        });
        loadResults();
    } else {
        loadResults(); // First load
    }

    // jQuery Validation Methods
    var now = new Date();
    now.setDate(now.getDate() - 1);

    jQuery.validator.addMethod("minDate", function(value, element) {
        var myDate = new Date(value);
        return this.optional(element) || myDate > now;
    });

    jQuery.validator.addMethod("greaterThan", function(value, element, params) {
        if (!/Invalid|NaN/.test(new Date(value))) {
            return new Date(value) > new Date($(params).val());
        }
        return isNaN(value) && isNaN($(params).val()) ||
            (Number(value) > Number($(params).val()));
    }, 'Must be greater than {0}.');

});

function refreshResults() {
    localStorage.removeItem("reservationSearchFilters");
    localStorage.removeItem("reservationDataTableSearch");
    resetSearchForm();
    loadResults();
}

function resetSearchForm() {
    $('#searchForm')[0].reset();
    $('.datepicker').val('');
    $('.pGroupCountCheckbox').prop('checked', false);
}

function loadResults(searchValue = "") {
    var formData = $('#searchForm').serializeArray();
    localStorage.setItem("reservationSearchFilters", JSON.stringify(formData));

    $("#searchResult").html("").addClass('loading');

    var form = $('#searchForm');
    $.ajax({
        url: form.attr('action'),
        type: form.attr('method'),
        data: form.serialize()
    }).done(function(resultHTML) {
        $("#searchResult").removeClass('loading').html(resultHTML);

        table = $('.dataTable').DataTable({
            responsive: true,
            iDisplayLength: 50,
            aaSorting: [],
            searching: true,
            oLanguage: { sSearch: "Filter Results: " },
            dom: "<'row'<'col-sm-4'l><'col-sm-4'f><'col-sm-4 text-right'B>>" +
                 "<'row'<'col-sm-12'tr>>" +
                 "<'row'<'col-sm-5'i><'col-sm-7'p>>",
            buttons: [
                {
                    extend: 'excelHtml5',             // Excel export button
                    text: 'Excel Export',
                    className: 'btn btn-sm btn-excel-custom',
                    exportOptions: {
                        columns: [0,1,2,3,4,5,6,7,8,9,10,11,12] // only these columns exported
                    }
                }
            ],
            initComplete: function() {
                var api = this.api();
                var container = $(api.table().container());
                var dtSearchValue = "";

                if (searchValue.trim() !== "") {
                    dtSearchValue = searchValue;
                } else {
                    var savedDTSearch = localStorage.getItem('reservationDataTableSearch');
                    if (savedDTSearch) {
                        dtSearchValue = savedDTSearch;
                    }
                }

                var searchInput = container.find('.dataTables_filter input');
                if (searchInput.length) {
                    searchInput.off('keyup change').on('keyup change', function() {
                        var val = $(this).val();
                        localStorage.setItem('reservationDataTableSearch', val);
                    });

                    if (dtSearchValue !== "") {
                        api.search(dtSearchValue).draw();
                        searchInput.val(dtSearchValue);
                    }
                }
            }
        });
        table.buttons().container().find('.buttons-excel').removeClass('btn-default');

        var selectedValues = $('.pGroupCountCheckbox:checked').map(function() {
            return $(this).val();
        }).get();
        var filterValue = '^(' + selectedValues.join('|') + ')$';
        table.column(13).search(filterValue, true, false).draw();

        $('#detailsModal').off('show.bs.modal').on('show.bs.modal', function(event) {
            var link = $(event.relatedTarget)
            var modal = $(this);
            var data = { id: link.data('id'), edit: link.data('edit') }
            $.get("get_details.cfm", data, function(res) {
                modal.find('.modal-body').html(res);
                $('#paidButton').click(function() {
                    $('#paidForm').toggle();
                    $('#paidButton').toggle();
                });
                $('.closePaid').click(function() {
                    $('#paidForm').toggle();
                    $('#paidButton').toggle();
                });
            });
        });

    });
}
</script>


<!--
<script type="text/javascript">

$(function() {

    $(document).keypress(function(e) {
        if(e.which == 13 && e.target.id == "searchCriteria") {
            e.stopPropagation();
            e.preventDefault();
        }
    });

    $("#optionsButton").click(function () {
      $(this).text(function(i, text){
          return text === "Less Options" ? "More Options" : "Less Options";
      })
    });

    $('#eventSelect').change(function(){
	  if ($(this).val() === 'r') { 
	  	$("#rangeFilter").show();
	  } else {
	  	$("#rangeFilter").hide();
	  	$('input[name="rangeStart"]').val('');
	  	$('input[name="rangeEnd"]').val('');
	  }
	});

	$('.datepicker').datetimepicker({
	    pickTime: true,
	    format : 'MM/DD/YYYY HH:mm'
	  });

    loadResults();

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

});

function loadResults() {
  $("#searchResult").html('');
  $("#searchResult").addClass('loading');

  var form = $('#searchForm');

  $.ajax({
    url  : form.attr('action'),
    type : form.attr('method'),
    data : form.serialize()
  }).done(function(resultHTML) {
    $("#searchResult").removeClass('loading');
    $("#searchResult").html(resultHTML);

    $('.dataTable').DataTable({
            responsive: true,
            "iDisplayLength": 50,
            "aaSorting": [],
            "searching": true,
            "oLanguage": {
               "sSearch": "Filter Results: "
            },
            dom: "<'row'<'col-sm-4'l><'col-sm-4'f><'col-sm-4'p>>" +
                    "<'row'<'col-sm-12'tr>>" +
                "<'row'<'col-sm-5'i><'col-sm-7'p>>",
    });

    
    $('#detailsModal').off('show.bs.modal').on('show.bs.modal', function (event) {
	 
        var link = $(event.relatedTarget) // Button that triggered the modal
        var modal = $(this);

        var data = { 
            id: link.data('id'),
            edit: link.data('edit')
        }

        $.get( "get_details.cfm", data, function( res ) {
            modal.find('.modal-body').html( res );

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
		  $(document).on('click', '#reSend', function() {

         
            var link = $(this);

            var data = { 
                id: link.data('id')
            }

            $.get( "email_send.cfm", data, function( res ) {
              alert('Email Notification Sent.');
            });
          });

          $("#res_edit").submit(function (event) {
              
            event.preventDefault();
            
            var $form = $(this);

            var formData = $form.serialize();

            formData += "&formName=" + $form.attr('id');

            $.ajax({
              type: "POST",
              url: "ajax_submit.cfm",
              data: formData
            }).error(function (data) {
              console.log(data);
              alert("Error: Please correct and try again.");
            }).success(function () {
              $('#detailsModal .modal-body').html('<h4 class="text-center">Reservation Updated.</h4>')
              setTimeout(function(){
                  $('#detailsModal').modal('hide');
                  $('#detailsModal .modal-body').html('');
                  loadResults();
              },1500);
            });
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
              }, {
                name: 'Parking Group',
                  width: '180px',
                  valueField: 'parking'
              }],
              select: function (event, ui) {
                this.value = (ui.item ? ui.item.make + ' ' + ui.item.model : '');
                $('#actype_id').val(ui.item ? ui.item.id : '')
                parkingSelected = ui.item.parking;
                return false;
              },
              minLength: 1,
              delay: 0,
              source: "/ac_search.cfm"
          });

          $('#cancelRes').click(function(){
			  $('#cancelForm').toggle();
			  $('#cancelRes').toggle();
		  });

		  $('.closePanel').click(function(){
			  $('#cancelForm').toggle();
			  $('#cancelRes').toggle();
		  });

          $('#paidButton').click(function(){
			  $('#paidForm').toggle();
			  $('#paidButton').toggle();
		  });

		  $('.closePaid').click(function(){
			  $('#paidForm').toggle();
			  $('#paidButton').toggle();
		  });

		  $("#res_cancel").validate({
		    //debug: true,
		    ignore: [],
		    rules: {
		      comment: "required"
		    },
		    messages: {
		      comment: "Comment is required."
		    }
		  });

		  $('#addNote').click(function(){
			  $('#newNote').toggle();
		  });

		  $('.datepicker').datetimepicker({
              pickTime: true,
              format : 'MM/DD/YYYY HH:mm',
              minDate: new Date()
          });

        });
    });
  });
}

</script>

<cfinclude template="footer.cfm">