// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can also rename this file to openings.js.coffee, and only keep the coffee script
// below : http://jashkenas.github.com/coffee-script/
$(function() {
    $("select#opening_country").change(function(event) {
        var country_code, state_select_wrapper, url;
        state_select_wrapper = $("#opening_state_wrapper");
        $("select", state_select_wrapper).attr("disabled", true);
        country_code = $(this).val();
        url = "/addresses/subregion_options?country_code=" + country_code;
        return state_select_wrapper.load(url);
    });

    var reload_role_func = function(department_id, role) {
        if (department_id.length <= 0) {
            department_id = '0'
        }

        var role_id = $( '#opening_' + role + '_id');
        $('select', role_id).attr('disabled', true);
        var old_value = role_id.val();
        var url = "/departments/" + department_id + "/user_select?role=" + role;
        return role_id.load(url, function() {
            var role_id = $( '#opening_' + role + '_id');
            role_id.attr('id', 'opening_' + role + '_id')
                .attr('name', 'opening[' + role + '_id]');
            role_id.val(old_value);
        });
    };

    $('#opening_recruiter_id').change(function(event){
        var current_user_id = $('#opening_recruiting_warn').attr('data_recruiter_id');
        if (current_user_id != $(this).val()){
            $('#opening_recruiting_warn').show();
        }else{
            $('#opening_recruiting_warn').hide();
        }
    });

    $('select#opening_department_id').change(function(event) {
        var department_id = $(this).val();
        return reload_role_func(department_id, 'hiring_manager');
    });

    if ($('#opening_hiring_manager_id').length > 0) {
        reload_role_func($('#opening_department_id')[0].value, 'hiring_manager');
    }


    if ($('#candidates_selection_container').length > 0) {
        var candidates_selection_container = $('#candidates_selection_container');


        Common.prepare_object_selection_container($('#candidates_selection'), null, function (checkbox) {
            var ids= candidates_selection_container.data('ids');
            var current_val = parseInt($(checkbox).val());
            var index = ids.indexOf(current_val);
            if (index >= 0) {
                ids.splice(index, 1);
            } else {
                ids.push(current_val);
            }
        });

        function assign_candidates(id, candidate_ids) {
            $.post('/openings/' + id + '/assign_candidates',
                {
                    candidates: candidate_ids
                })
                .done(function(response) {
                    if (!response.success) {
                        $('#error_messages').html('<p class="errors">' + response.messages + '</p>').parent().show();
                    } else {
                        $("#candidates_selection_container").hide().dialog( "close" );
                    }
                })
                .fail(function(jqXHR, textStatus, errorThrown) {
                    alert('fail');
                });
        }

        $('a.assign_candidates').click(function() {
            var opening_row = $(this).closest('tr');
            var opening_id = opening_row.data('id');
            if (opening_id == undefined) {
                return false;
            }
            $('#candidates_selection').load('/candidates/index_for_selection?exclude_opening_id=' + opening_id, function() {
                candidates_selection_container.data('ids', []);
                candidates_selection_container.show().dialog({
                    width : 400,
                    height: 500,
                    title: "Select Candidates",
                    modal: true,
                    buttons: {
                        "OK": function() {
                            assign_candidates(opening_id, candidates_selection_container.data('ids'));
                        },
                        Cancel: function() {
                            $("#candidates_selection_container").hide().dialog( "close" );
                        }
                    }
                });


            });
            return false;

        });
    }

    if ($('.dropdown-toggle').length > 0) {
        $('.dropdown-toggle').dropdown();
    }

    $('#openings_viewfilter').click(function(event) {
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

        function refreshOpenings(condition) {
            var xmlhttp = null;
            var url = null;
            if (condition == '') {
                url = '/openings?partial';
            } else {
                url = '/openings?partial&' + condition;
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
                           document.getElementById('all-openings').innerHTML = xmlhttp.responseText;
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
        document.getElementById('openings_filtername').innerHTML = target.innerHTML.toString();
        switch (getIndex(target)) {
            case 0: // View Mine
                refreshOpenings('owned_by_me');
                break;
            case 1: // View No Candidates
                refreshOpenings('no_candidates');
                break;
            case 2: // View All
                refreshOpenings('all');
                break;
            default:
                alert('Invalid choice');
                break;
        }
    });

});
