$(function () {
    if ($('.flexible_schedule_interviews').length > 0) {
        $('.flexible_schedule_interviews').click(function(event) {
            var opening_candidate_id = $('#opening_candidate_id').val();
            if (opening_candidate_id) {
                window.location = '/interviews/edit_multiple?opening_candidate_id=' + opening_candidate_id;
            } else {
                $('#opening_selection').load('/interviews/schedule_opening_selection', function(response, status) {
                    if (status == 'success') {
                        $(this).find('select#department_id').attr('name', null);
                        $(this).find('#openingid_select_wrapper').attr('id', 'interview_openingid_select_wrapper');
                        $(this).find('select#opening_id').attr('name', 'opening_id');
                        $(this).dialog({
                            modal: true,
                            title: "Select Opening",
                            width : '450px'});
                    }
                });
            }
        });


        $('body').delegate('select#department_id', 'change', function(event) {
            var select_wrapper = $('#interview_openingid_select_wrapper');
            $('select', select_wrapper).attr('disabled', true);
            var department_id = $(this).val();
            var url = '/positions/opening_options?selected_department_id=' + department_id;
            return select_wrapper.load(url, function() {
                $('select#opening_id').attr('name', 'opening_id');
            });
        });
    }

    if ($('.interview-feedback-btn').length > 0) {
        $('.interview-feedback-btn').click(function(event){
            var interview_id = $(this).attr('data-interview-id');
            var div_id = "interview-feedback-dialog-" + interview_id;
            $("div#" + div_id).dialog({
                height: 500,
                width: 600,
                modal: true,
                title: 'Add Feedback'
            });
        });
    }

    function setup_datetimepicker(elements) {
        $(elements).datetimepicker().each(function(index, elem) {
            var isoTime = new Date($(elem).data('iso'));
            var new_id = elem.id.replace("scheduled_at", "scheduled_at_iso");
            if (new_id != elem.id) {
                var iso_elem = $("#" +  new_id);
                if (iso_elem) {
                    iso_elem.val($(elem).data('iso'));
                }
            }
            $(elem).datetimepicker("setDate", isoTime);
        });
    }

    setup_datetimepicker($(".datetimepicker"));

    $("table.schedule_interviews tbody").delegate(".datetimepicker", "change", function () {
        var isoVal = new Date(this.value).toISOString();
        $(this).data('iso', isoVal);
        var new_id = this.id.replace("scheduled_at", "scheduled_at_iso");
        if (new_id != this.id) {
            var iso_elem = $("#" + new_id);
            if (iso_elem) {
                iso_elem.val(isoVal);
            }
        }
    });

    $(".iso-time").each(function (index, elem) {
        elem.innerHTML = new Date(elem.innerHTML).toLocaleString();
    });

    function toggleModality(modality) {
        if (typeof(modality) == "string") {
            if (modality.indexOf("phone") >= 0) {
                $(".toggle-location").hide();
                $(".toggle-phone").show();
            } else if (modality.indexOf("onsite") >= 0) {
                $(".toggle-location").show();
                $(".toggle-phone").hide();
            }
        }
    }

    toggleModality(
        $("#interview_modality").change(function () {
            toggleModality(this.value);
        }).val()
    );


    if ($("#interview_user_id").length > 0) {
        function reloadInterviewers() {
            var old_val = $("#interview_user_id").val();
            var opening_id = $('#opening_id').val();
            if (opening_id != undefined)  {
                var url = "/openings/" + opening_id + "/interviewers_select"
                if (!$("#only_favorite_interviewers").is(':checked')) {
                    url = url + "?mode=all";
                }
                $("#interview_user_id").load(url, function(response, status) {
                    if (status == 'success') {
                        $("#interview_user_id").attr('id', 'interview_user_id')
                          .attr('name', 'interview[user_id]');
                        $("#interview_user_id").val(old_val);
                    }
                });
            }
        };

        $("#only_favorite_interviewers").change(function() {
            reloadInterviewers();
        });

        reloadInterviewers();
    }


    if ($('table.schedule_interviews').length > 0) {
        // Read all rows and return an array of objects
        function GetAllInterviews()
        {
            var interviews = [];

            $('table.schedule_interviews tbody tr').each(function (index, value)
            {
                var row = GetRow(index);
                interviews.push(row);
            });

            return interviews;
        }

        // Read the row into an object
        function GetRow(rowNum)
        {
            var row = $('table.schedule_interviews tbody tr').eq(rowNum);

            var interview = {};

            interview.id = row.find('td:eq(0)').text();
            interview.status = row.find('#status').val();
            if (row.find('.icon-remove').length > 0) {
                interview.scheduled_at_iso = row.find('td:eq(1) input').data('iso');
                interview.duration = row.find('#duration').val();
                interview.modality = row.find('#modality').val();
            } else {
                interview.scheduled_at_iso = row.find('td:eq(1) label').data('iso');
                interview.duration = row.find('td:eq(2)').text();
                interview.modality = row.find('td:eq(3)').text();
            }

            return interview;
        }


        function update_schedule_interviews_table() {
            var opening_id = $('#opening_id').data('value');
            var candidate_id = $('#candidate_id').val();
            $('table.schedule_interviews tbody').empty();
            var active = opening_id && candidate_id;
            if (active) {
                $('.submit_interviews').show();
                $('.add_new_interview').show();
                var url = '/interviews/schedule_interviews_collection?opening_id=' + opening_id + '&candidate_id=' + candidate_id;
                $('table.schedule_interviews tbody').load(url, function(data, status) {
                    if (status == 'success') {
                        $(this).find('td .datetimepicker').each(function(index, elem) {
                            setup_datetimepicker(elem);
                        });
                    }
                });
            } else {
                $('.submit_interviews').hide();
                $('.add_new_interview').hide();
            }
        }

        $('#candidate_id').change(update_schedule_interviews_table);


        update_schedule_interviews_table();


        $('table.schedule_interviews').on('click', 'td i.icon-remove', function() {
            var row = $(this).parent().parent();
            row.remove();
        });

        $('.add_new_interview').click(function() {
            var tbody = $('table.schedule_interviews tbody');
            if (tbody.find('tr').length >= 20) {
                alert('Too many interviews added.');
                return;
            }
            $.get("/interviews/schedule_interviews_lineitem", function(data, status) {
                if (status == 'success') {
                    var newElem = $(data).appendTo('table.schedule_interviews tbody');
                    setup_datetimepicker(newElem.find("td .datetimepicker"));
                }
            });
        });

        $('.submit_interviews').click(function() {
            var interviews = GetAllInterviews();
            $.post('/interviews/update_multiple',
                {
                    interviews: {
                        opening_id: $('#opening_id').data('value'),
                        candidate_id: $('#candidate_id').val(),
                        interviews_attributes:interviews
                    }
                })
            .done(function(response) {
                if (!response.success) {
                    $('#error_messages').html('<p class="errors">' + response.messages + '</p>').parent().show();
                }
                else {
                    var url = $('#previous_url').data('value');
                    if (!url) {
                        url = "/interviews"
                    }
                    window.location = url;
                }
            })
            .fail(function(jqXHR, textStatus, errorThrown) {
                alert('fail');
            });
        });
    }



});
