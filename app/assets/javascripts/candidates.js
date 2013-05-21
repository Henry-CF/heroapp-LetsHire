// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can also rename this file to openings.js.coffee, and only keep the coffee script

$(function() {
    function reload_opening() {
        $('#department_id').attr('name', null);
        $('#openingid_select_wrapper').attr('id', 'candidate_openingid_select_wrapper');
        $('select#opening_id').attr('name', 'candidate[opening_ids]');
        var select_wrapper = $('#candidate_openingid_select_wrapper');
        $('select', select_wrapper).attr('disabled', true);
        var department_id = $('#department_id').val();
        var url = '/positions/opening_options?selected_department_id=' + department_id;
        return select_wrapper.load(url, function() {
            $('select#opening_id').attr('name', 'candidate[opening_ids]');
        });
    };

    if ($('.candidate_new_opening').length > 0 || $('#new_candidate').length > 0) {
        reload_opening();

        $('body').delegate('select#department_id', 'change', reload_opening);

        $('.candidate_new_opening').click(function(event) {
            var candidate_id = $('#candidate_id').val();
            if (candidate_id) {
                $('#opening_selection').load('/candidates/' + candidate_id + '/new_opening', function(response, status) {
                    if (status == 'success') {
                        $(this).find('select#department_id').attr('name', null);
                        $(this).find('#openingid_select_wrapper').attr('id', 'candidate_openingid_select_wrapper');
                        $(this).find('select#opening_id').attr('name', 'candidate[opening_ids]');
                        $(this).dialog({
                            modal: true,
                            title: "Assign Opening",
                            width : '500px'});
                    }
                });
            }
        });
    }

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
        document.getElementById('filtername').innerHTML = target.innerHTML.toString();
        switch (getIndex(target)) {
            case 0: // View Active
                refreshCandidates('active');
                break;
            case 1: // View Inactive
                refreshCandidates('inactive');
                break;
            case 2: // View Available
                refreshCandidates('available');
                break;
            case 3: // View All
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
});
