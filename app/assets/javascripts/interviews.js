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
    };


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


    if ($('table.schedule_interviews').length > 0) {


        // Read all rows and return an array of objects
        function GetAllInterviews()
        {
            var interviews = [];

            $('table.schedule_interviews tbody tr').each(function (index, value)
            {
                var row = GetRow(index);
                if (row == false) {
                    return false;
                }
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
                var interviewer_td = row.find('td:eq(5)');
                var user_ids = interviewer_td.data('user_ids');
                if (user_ids.length == 0) {
                    alert('No interviewers configured for row ' + (rowNum + 1));
                    return false;
                }
                var origin_user_ids = interviewer_td.data('origin_user_ids');
                if (origin_user_ids) {
                    //We have change
                    interview.user_ids = user_ids;
                }

            }
            return interview;
        }

        function update_schedule_interviews_table() {
            var opening_id = $('#opening_id').val();
            var candidate_id = $('#candidate_id').val();
            $('table.schedule_interviews tbody').empty();
            var active = opening_id && candidate_id;
            if (active) {
                $('.submit_interviews').show();
                $('.add_new_interview').show();
                var url = '/interviews/schedule_reload?opening_id=' + opening_id + '&candidate_id=' + candidate_id;
                $('table.schedule_interviews tbody').load(url, function(data, status) {
                    if (status == 'success') {
                        $(this).find('td .datetimepicker').each(function(index, elem) {
                            setup_datetimepicker(elem);
                        });
                        $(".iso-time").each(function (index, elem) {
                            elem.innerHTML = new Date(elem.innerHTML).toLocaleString();
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

        function select_existing_interviewers(container){
            var current_selected_user_ids = $('#interviewers_selection_container').data('user_ids');
            $(container).find('input:checkbox').each(function(index, elem) {
                if (current_selected_user_ids.indexOf(parseInt($(elem).val())) >=0) {
                    $(elem).prop('checked', true);
                }
            });
        }


        // We assume a1 and a2 don't have duplicated elements.
        function uniq_array_equal(a1, a2) {
            if (a1.length != a2.length) {
                return false;
            }
            for (var a1_i = 0; a1_i < a1.length; a1_i++) {
                if (a2.indexOf(a1[a1_i]) == -1) {
                    return false;
                }
            }
            for (var a2_i = 0; a2_i < a2.length; a2_i++) {
                if (a1.indexOf(a2[a2_i]) == -1) {
                    return false;
                }
            }
            return true;
        }


        function calculate_interviewers_change(interviewer_td) {
            var interviewers_selection_container = $("#interviewers_selection_container");
            var new_user_ids = interviewers_selection_container.data('user_ids');
            var old_user_ids = $(interviewer_td).data('user_ids');
            if (uniq_array_equal(new_user_ids, old_user_ids)) {
                //No change comparing to data before dialog open.
                return true;
            }
            $(interviewer_td).data('users', interviewers_selection_container.data('users').slice(0));
            $(interviewer_td).children().first().text(interviewers_selection_container.data('users').join());
            var original_user_ids = $(interviewer_td).data('origin_user_ids');
            if (!original_user_ids) {
                // Definitely a change comparing to content loading
                $(interviewer_td).data('origin_user_ids', old_user_ids.slice(0));
            } else {
                // Check whether we rollback to the original version
                if (uniq_array_equal(new_user_ids, original_user_ids)) {
                    $(interviewer_td).removeData('origin_user_ids');
                }
            }
            $(interviewer_td).data('user_ids', new_user_ids.slice(0));

            return true;
        }

        $('table.schedule_interviews').on('click', 'td .edit_interviewers', function() {
            var interviewer_td = $(this).parent().parent();
            $('#interviewers_selection_container').data('user_ids', interviewer_td.data('user_ids').slice(0));
            $('#interviewers_selection_container').data('users', interviewer_td.data('users').slice(0));
            $('#interviewers_selection').load('/participants', function(response, status) {
                if (status == 'success') {
                    select_existing_interviewers(this);
                    $("#interviewers_selection_container").show().dialog({
                        width : 400,
                        height: 500,
                        modal: true,
                        buttons: {
                            "OK": function() {
                                $("#interviewers_selection_container").hide().dialog( "close" );
                                calculate_interviewers_change(interviewer_td);
                            },
                            Cancel: function() {
                                $("#interviewers_selection_container").hide().dialog( "close" );
                            }
                        }
                    });
                }
            });
        });

        $('#interviewers_selection_container').delegate('.pagination a', 'click', function () {
            $('.pagination').html('Page is loading...');
            $('#interviewers_selection').load(this.href, function() {
                select_existing_interviewers(this);
            });
            return false;
        });

        $('#interviewers_selection_container').delegate('input:checkbox', 'change', function () {
            var user_ids= $('#interviewers_selection_container').data('user_ids');
            var users = $('#interviewers_selection_container').data('users');
            var current_val = parseInt($(this).val());
            var index = user_ids.indexOf(current_val);
            if (index >= 0) {
                user_ids.splice(index, 1);
                users.splice(index, 1);
            } else {
                user_ids.push(current_val);
                var str = $(this).parent().children('span').text();
                users.push(str);
            }
        });

        $('.add_new_interview').click(function() {
            var tbody = $('table.schedule_interviews tbody');
            if (tbody.find('tr').length >= 20) {
                alert('Too many interviews added.');
                return;
            }
            $.get("/interviews/schedule_add", function(data, status) {
                if (status == 'success') {
                    var newElem = $(data).appendTo('table.schedule_interviews tbody');
                    setup_datetimepicker(newElem.find("td .datetimepicker"));
                }
            });
        });

        $('.submit_interviews').click(function() {
            var interviews = GetAllInterviews();
            if (interviews == false) {
                return false;
            }
            $.post('/interviews/update_multiple',
                {
                    interviews: {
                        opening_id: $('#opening_id').val(),
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
