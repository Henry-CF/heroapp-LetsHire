// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can also rename this file to openings.js.coffee, and only keep the coffee script
// below : http://jashkenas.github.com/coffee-script/
/*
$ ->
  $("select#opening_country").change (event) ->
    select_wrapper = $("#opening_state_wrapper")

    $("select", select_wrapper).attr("disabled", true)

    country_code = $(this).val()

    url = "/addresses/subregion_options?country_code=#{country_code}"
    select_wrapper.load(url)
*/
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

        var role_select_wrapper = $( '#' + role + '_id_select_wrapper');
        $('select', role_select_wrapper).attr('disabled', true);

        var url = "/departments/" + department_id + "/user_select?role=" + role;
        return role_select_wrapper.load(url);
    };

    $('select#opening_department_id').change(function(event) {
        var department_id = $(this).val();
        return reload_role_func(department_id, 'hiring_manager');
    });

    $("#opening_participant_tokens").tokenInput("/participants.json", {
        crossDomain: false,
        prePopulate: $("#opening_participant_tokens").data("pre")
    });
});
