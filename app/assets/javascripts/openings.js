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
            var p = $(this);
            for (var i = 0; i < 5; i++) { p = p.parent(); }
            var opening_row = p;
            $('#candidates_selection').load('/candidates/index_for_selection', function() {
                candidates_selection_container.data('ids', []);
                candidates_selection_container.show().dialog({
                    width : 400,
                    height: 500,
                    title: "Select Candidates",
                    modal: true,
                    buttons: {
                        "OK": function() {
                            assign_candidates(opening_row.data('id'), candidates_selection_container.data('ids'));
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

});
