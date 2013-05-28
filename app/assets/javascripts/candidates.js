// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can also rename this file to openings.js.coffee, and only keep the coffee script

$(function() {
    $('.fileupload').fileupload({
        name: "candidate[resume]"
    });

    if ($('.candidates_index_new_opening').length > 0 ||
        $('.candidate_new_opening').length > 0 ||
        $('#new_candidate').length > 0)
    {
        $('#department_id').attr('name', null);
        $('#openingid_select_wrapper').attr('id', 'candidate_openingid_select_wrapper');
        $('select#opening_id').attr('name', 'candidate[opening_ids]');

        $('body').delegate('select#department_id', 'change', function() {
            Common.reload_opening($(this), $('#candidate_openingid_select_wrapper'), 'candidate[opening_ids]');
        });

        var opening_selection_container = $("#opening_selection_container");
        function create_opening(id) {
            opening_selection_container.parent().get(0).setAttribute('action', '/candidates/' + id + '/create_opening');
            opening_selection_container.parent().dialog({
                modal: true,
                title: "Select Opening",
                width : '450px'});

        }

        $('.candidates_index_new_opening').click(function(event) {
            create_opening($(this).closest('tr').data('id'));
            return false;
        });

        $('.candidate_new_opening').click(function(event) {
            create_opening($('#candidate_id').val());
            return false;
        });
    }

    $(document).on('click', '.candidate-blacklist-link', function(event){
        event.stopPropagation();
        var candidate_id = $(this).attr('data-candidate-id');
        var div_id = "candidate-blacklist-dialog-" + candidate_id;

        $("div#" + div_id).dialog({
            height: 350,
            width: 450,
            modal: true,
            title: 'Deactive candidate',
            close: function(event, ui){
                $(this).dialog('destroy');
            }
        });
    });

    if ($('.dropdown-toggle').length > 0) {
        $('.dropdown-toggle').dropdown();
    }

    $('#candidates_viewfilter').click(function(event) {
        function getEventTarget(e) {
            e = e || window.event;
            return e.target || e.srcElement;
        }

        function getIndex(sender) {
            var aElements = sender.parentNode.parentNode.getElementsByTagName("a");
            var aElementsLength = aElements.length;

            var index;
            for (var i = 0; i < aElementsLength; i ++) {
                if (aElements[i] == sender) {
                    index = i;
                    return index;
                }
            }
        }

        function refreshCandidates(condition) {
            var xmlhttp = null;
            var url = null;
            if (condition == '') {
                url = '/candidates?partial';
            } else {
                url = '/candidates?partial&' + condition;
            }

            if (window.XMLHttpRequest) {
                xmlhttp = new XMLHttpRequest();
            } else if (window.ActiveXObject) {
                xmlhttp = new ActiveXObject("Microsoft.XMLHTTP");
            } 
            
            if (xmlhttp != null) {
                xmlhttp.onreadystatechange = function() {
                    if (xmlhttp.readyState == 4) { // loaded
                       if (xmlhttp.status == 200) { // ok
                           document.getElementById('all-candidates').innerHTML = xmlhttp.responseText;
                           if ($('.dropdown-toggle').length > 0) {
                               $('.dropdown-toggle').dropdown();
                           }
                       }
                       else {
                           alert("Problem retrieving data:" + xmlhttp.statusText);
                       }
                    }
                };
                xmlhttp.open("GET", url, true);
                xmlhttp.send(null);
            }
            else {
                alert("Your browser does not support XMLHTTP.");
            }
        }


        var target = getEventTarget(event);
        document.getElementById('candidates_filtername').innerHTML = target.innerHTML.toString();
        switch (getIndex(target)) {
            case 0: // View Active without openings
                refreshCandidates('no_openings');
                break;
            case 1: // View Active without Interviews
                refreshCandidates('no_interviews');
                break;
            case 2: // View interviewed candidates without final assessment
                refreshCandidates('without_assessment');
                break;
            case 3: // View interviewed candidates with final assessment
                refreshCandidates('with_assessment');
                break;
            case 4: // View Active
                refreshCandidates('with_opening');
                break;
            case 5: // View Inactive
                refreshCandidates('inactive');
                break;
            case 6: // View All
                refreshCandidates('all');
                break;
            default:
                alert('Invalid choice');
                break;
        }
    });

    $('#candidate_resume').change(function(event) {
        var maxsize = 10 * 1024 * 1024;

        if ($.browser.msie) {
            // microsoft ie
            //
            // It's not easy to achieve this functionality in IE, most likly,
            // IE configuration does forbidden ActiveXObject. Anyway, we have
            // done the server side file size limit mechanism.
        } else {
            // firefox, chrome
            if (this.files[0].size > maxsize) {
                alert('File size cannot be larger than 10M.');
                $(this).attr('value', '');
            }
        }
    });

    if ($('#candidate-assessment-btn').length > 0 ){
        $('#candidate-assessment-btn').click(function(e){
            $('div#candidate-assessment-dialog').dialog({
                modal: true,
                width: '700',
                height: '620',
                title: 'Assess Candidate'
            });
        });
    }

    $("ul.interviewline").each(function (index, elem) {
        elem.childNodes[0].innerHTML = new Date(elem.childNodes[0].innerHTML).toLocaleString();
    });
});
