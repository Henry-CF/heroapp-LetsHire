// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can also rename this file to openings.js.coffee, and only keep the coffee script

$(function() {
    $('body').delegate('select#department_id', 'change', function(event) {
        var select_wrapper = $('#candidate_openingid_select_wrapper');
        $('select', select_wrapper).attr('disabled', true);
        var department_id = $(this).val();
        var url = '/positions/opening_options?selected_department_id=' + department_id;
        return select_wrapper.load(url, function() {
            $('select#opening_id').attr('name', 'candidate[opening_ids]');
        });
    });

    $('.new_opening').click(function(event) {
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
