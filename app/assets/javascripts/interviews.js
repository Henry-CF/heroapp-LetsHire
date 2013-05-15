$(function () {
    $(".datetimepicker").datetimepicker().each(function (index, elem) {
        var isoTime = new Date($(elem).data('iso'));
        var new_id = elem.id.replace("scheduled_at", "scheduled_at_iso");
        if (new_id != elem.id) {
            var iso_elem = $("#" +  new_id);
            if (iso_elem) {
                iso_elem.val($(elem).data('iso'));
            }
        }
        $(elem).datetimepicker("setDate", isoTime);
    }).change(function () {
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
                interview.scheduled_at_iso = row.find('td:eq(1)').text();
                interview.duration = row.find('td:eq(2)').text();
                interview.modality = row.find('td:eq(3)').text();
            }

            return interview;
        }
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
            $.get("/interviews/interview_lineitem", function(data, status) {
                if (status == 'success') {
                    var newElem = $(data).appendTo('table.schedule_interviews tbody');
                    var timePicker = newElem.find("td .datetimepicker")
                    var isoTime = new Date(timePicker.data('iso'));
                    timePicker.datetimepicker().change(function() {
                        var isoVal = new Date(this.value).toISOString();
                        $(this).data('iso', isoVal)
                    }).datetimepicker("setDate", isoTime);
                }
            });
        });

        $('.submit_interviews').click(function() {
            var interviews = GetAllInterviews();
            $.post('/interviews/update_multiple',
                {
                    opening_candidate_id: $('#opening_candidate_id').val(),
                    interviews_attributes:interviews

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
