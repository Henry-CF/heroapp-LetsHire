$(function () {
    $(".datetimepicker").datetimepicker().each(function (index, elem) {
        var isoTime = $("#interview_" + elem.name + "_iso").val();
        if (isoTime == "") {
            $(elem).datetimepicker("setDate", new Date());
            $("#interview_" + this.name + "_iso").val(new Date(elem.value).toISOString());
        } else {
            $(elem).datetimepicker("setDate", new Date(isoTime));
        }
    }).change(function () {
        $("#interview_" + this.name + "_iso").val(new Date(this.value).toISOString());
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
            interview.scheduled_at = row.find('td:eq(1)').text();
            interview.duration = row.find('td:eq(2)').text();
            interview.interview_type = row.find('td:eq(3)').text();
            interview.status = row.find('#status').val();
            return interview;
        }
        $('table.schedule_interviews').on('click', 'td i.icon-remove', function() {
            var row = $(this).parent().parent();
            row.remove();
        });

        $('.add_new_interview').click(function() {
            $.get("/interviews/interview_lineitem", function(data, status) {
                if (status == 'success') {
                    var tbody = $('table.schedule_interviews tbody');
                    tbody.append(data);
                }
            });
        });

        $('.submit_interviews').click(function() {
            var interviews = GetAllInterviews();
            $.post('/interviews/update_multiple',
                {
                    opening_candidate_id: $('#opening_candidate_id').val(),
                    interviews:interviews

                },
                function (response) {
                    console.log(response);
                }
            ).done(function() { alert("second success"); })
            .fail(function() { alert("error"); });
        });
    }



});
