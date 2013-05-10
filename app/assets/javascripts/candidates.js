// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can also rename this file to openings.js.coffee, and only keep the coffee script

$(function() {
    $('select#candidate_department_id').change(function(event) {
        var select_wrapper = $('#openingid_select_wrapper');
        $('select', select_wrapper).attr('disabled', true);
        var department_id = $(this).val();
        var url = "/positions/opening_options?selected_department_id=" + department_id;
        return select_wrapper.load(url);
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
